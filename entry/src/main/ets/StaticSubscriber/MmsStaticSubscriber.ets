/**
 * Copyright (c) 2022-2023 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import StaticSubscriberExtensionAbility from '@ohos.application.StaticSubscriberExtensionAbility'
import { GlobalContext } from '../MainAbility/GlobalHelper';
import { JSON } from '@kit.ArkTS';
import ReceiveService from './ReceiveService';
import common from '../data/commonData';
import HiLog from '../utils/HiLog';
import NotificationService, { IBadgeContextInfo } from '../service/NotificationService';
import SharedPreferencesUtils from '../utils/SharedPreferencesUtils';
import { DataParameters } from '../utils/TypesUtils';
import { mmsReceive } from '../views/MmsReceive/mmsReceiveMain';
import DotUtil from '../utils/MmsDot/DotUtils';
import dotCommon, { notifyStateParam } from '../utils/MmsDot/DotCommon';
import LooseObject from '../data/LooseObject';
import DeskDialogConnection from '../flashMessage/DeskDialogConnection';
import oobeResult from '../oobe/oobeResult';
import DeviceUtil from '../utils/DeviceUtil';
import { UnLockedNotifyService } from '../utils/UnLockedNotifyService';
import { osAccount, screenLock, settings, systemDateTime } from '@kit.BasicServicesKit';
import ServiceExtAbility from './ServiceExtAbility';
import commonData from '../data/commonData';

const TAG: string = 'MmsStaticSubscriber';
const CHATBOT_EVENT_DATA = [
  commonData.RCS_RECEIVE_TYPE.TEXT_RCS_CHATBOT_RECEIVE,
  commonData.RCS_RECEIVE_TYPE.TEXT_RCS_LOCATION_CHATBOT_RECEIVE,
  commonData.RCS_RECEIVE_TYPE.TEXT_RCS_FILE_CHATBOT_RECEIVE
];
// 非接收消息的通知事件
const RCS_NOT_RECEIVE_EVENT = [
    commonData.RCS_RECEIVE_TYPE.TEXT_RCS_DELIVERY_RECEIVE,
    commonData.RCS_RECEIVE_TYPE.TEXT_RCS_READ_RECEIVE,
    commonData.RCS_RECEIVE_TYPE.TEXT_RCS_SEND_OK_RECEIVE,
    commonData.TEXT_RECEIVE_TYPE.TEXT_SMS_RECEIVE,
    commonData.RCS_RECEIVE_TYPE.TEXT_RCS_FAIL_RECEIVE,
    commonData.RCS_RECEIVE_TYPE.RCS_FILE_SEND_OK_RECEIVE,
    commonData.RCS_RECEIVE_TYPE.RCS_FILE_SEND_FAILED_RECEIVE,
    commonData.RCS_RECEIVE_TYPE.RCS_SEND_FILE_CANCELED,
    commonData.RCS_RECEIVE_TYPE.FILE_RCS_PROGRESS,
    commonData.RCS_RECEIVE_TYPE.RCS_RECEIVE_FILE_FAILED,
    commonData.RCS_RECEIVE_TYPE.RCS_RECEIVE_FILE_CANCEL,
    commonData.RCS_RECEIVE_TYPE.RCS_RECEIVE_FILE_PROGRESS,
    commonData.RCS_RECEIVE_TYPE.RCS_RECEIVE_FILE_SUCCESS
];
// 非接收消息的action
const NOT_RECEIVE_ACTION = [
    common.STR.SUBSCRIBER_EVENT_COPYVERCODE,
    common.STR.SUBSCRIBER_EVENT_READ
];
export default class MmsStaticSubscriber extends StaticSubscriberExtensionAbility {
    public receiveService = ReceiveService.getInstance();
    private unLockedNotifyService = UnLockedNotifyService.getInstance()
    private accountManager: osAccount.AccountManager = osAccount.getAccountManager();
    private isProcessingMessageUserUnlocked = false;

    public onReceiveEvent(data: DataParameters): void {
        GlobalContext.getContext().setObject('mmsStaticContext', this.context);
        HiLog.w(TAG, `onReceiveEvent, event: ${data.event}, action = ${data.parameters.action}`);
        SharedPreferencesUtils.init(this.context);

        // 启动短信6s后，会检查是否存在匿名信息。如果存在，说明首次解锁事件失效了。这里需要走匿名信息接收流程。
        if (data.event === common.STR.SUBSCRIBER_EVENT && data.data === commonData.STR.RECEIVE_MESSAGE_USER_LOCK) {
            if (this.unLockedNotifyService.dataIsMoveEL5) {
                this.handleFirstUnLockedScreenNotification(this.context);
            }
            HiLog.w(TAG, `settings.mms.receive_message_user_unlock return`);
            return;
        }
        if (data.parameters.action === common.STR.SUBSCRIBER_EVENT_READ) {
            HiLog.i(TAG, 'onReceiveEvent: SystemUI mark message read');
            NotificationService.getInstance(this.context).clickRead(data);
            notifyStateParam.STATE = 2;
            DotUtil.getInstance().reportEvent(notifyStateParam, dotCommon.eventName.NOTIFICATION_OPERATION);
        }
        if (data.parameters.action === common.STR.SUBSCRIBER_EVENT_COPYVERCODE) {
            HiLog.i(TAG, 'onReceiveEvent: SystemUI mark message copy ver code');
            NotificationService.getInstance(this.context).copyVerCode(data);
            notifyStateParam.STATE = 3;
            DotUtil.getInstance().reportEvent(notifyStateParam, dotCommon.eventName.NOTIFICATION_OPERATION);
        }
        this.receiveService.sendAndReceiveRcsBroadcast(data, this.context);
        if (data.event === common.STR.SUBSCRIBER_EVENT) {
            HiLog.i(TAG, `onReceiveEvent, data.data: ${data?.data}`);
            // 接收消息成功率打点
            this.reportSuccessRate(data);
            // 收到信息，针对闪信区别处理
            if (data.parameters.pdus && data.parameters.pdus.length > 0) {
                this.receiveService.parsePDU(this.context, data, result => {
                    HiLog.i(TAG, `PDU parse complete block`)
                    if (result.messageClass == 0) {
                        this.handleFlashSMS(data, result)
                    } else {
                        this.handleNormalSMS(data)
                    }
                })
            } else {
                this.handleNormalSMS(data)
            }
        } else if (data.event === common.STR.SUBSCRIBER_MMS_EVENT && !DeviceUtil.isSubDeviceWithConnected(this.context)) {
            // 分机只有一种场景可以收彩信：插sim卡时，分机是未连接或者空状态
            HiLog.w(TAG, `onReceiveEvent, mms event data.data: ${data?.data}`);
            this.handleNormalSMS(data, true)
        } else if (data.event === common.STR.SUBSCRIBER_FIRST_UNLOCK_EVENT) {
            HiLog.i(TAG, 'onReceiveEvent, usual.event.USER_UNLOCKED');
            let isOobe: boolean = oobeResult.getInstance().getMmsNoticeOobeFromUI(this.context);
            if (isOobe) {
                HiLog.e(TAG, 'oobe process, do not query mms');
                return;
            }
            setTimeout(async () => {
                if (this.unLockedNotifyService.dataIsMoveEL5) {
                    this.handleFirstUnLockedScreenNotification(this.context);
                }
            }, DeviceUtil.isPC() ? 1500 : 0);
        } else if (data.event === common.STR.SUBSCRIBER_SHUTDOWN) {
        } else if (data.event === common.STR.KEY_DATA_TO_EL5 && this.unLockedNotifyService.dataIsMoveEL5) {
            HiLog.i(TAG, 'onReceiveEvent, store change event: ' + data.event);
            // 如果前端进程是活跃状态，需要更新页面
            let want: Want = {
                bundleName: 'com.ohos.mms',
                abilityName: 'ServiceExtAbility',
                parameters: {
                    'serviceEvent': common.STR.KEY_DATA_TO_EL5,
                }
            };
            this.context.startAbility(want);
            // 数据迁移完成，更新未读数
            let badgeContext:IBadgeContextInfo={
                appContext:this.context,
                updateBadgeEventCode:'onReceiveEvent->KEY_DATA_TO_EL5',
                tracedId: systemDateTime.getTime().toString(),
            }
            NotificationService.getInstance(this.context).updateBadgeNumberWithContext(badgeContext);
        } else if (data.event === common.STR.SUBSCRIBER_BOOT_COMPLETED) {
            let isOobe: boolean = oobeResult.getInstance().getMmsNoticeOobeFromUI(this.context);
            if (isOobe) {
                HiLog.e(TAG, 'oobe process, do not query mms');
                return;
            }
            this.isOsAccountUnlocked().then((res: boolean) => {
                if (res) {
                    let want: Want = {
                        bundleName: 'com.ohos.mms',
                        abilityName: 'ServiceExtAbility',
                        parameters: {
                            'serviceEvent': common.STR.SUBSCRIBER_BOOT_COMPLETED,
                        }
                    };
                    this.context.startAbility(want);
                } else {
                    HiLog.i(TAG, 'no need to start com.ohos.telephonydataability for el1->el2');
                }
            })
        }
        HiLog.w(TAG, `onReceiveEvent end`);
    }

    private reportSuccessRate(data: DataParameters) {
        if (!data) {
            HiLog.w(TAG, `reportSuccessRate param invalid`);
            return;
        }
        let msgType: number;
        if (data?.data?.includes('RCS_') || data?.data?.includes('_RCS')) {
            msgType = dotCommon.smsReceiveRecord.SUCCESS_RATE_TYPE_RCS;
        } else {
            msgType = dotCommon.smsReceiveRecord.SUCCESS_RATE_TYPE_SMS;
        }
        if (RCS_NOT_RECEIVE_EVENT.includes(data?.data) || NOT_RECEIVE_ACTION.includes(data?.parameters?.action)) {
            HiLog.w(TAG, `reportSuccessRate is not receive event, event data: ${data?.data}`);
            return;
        }
        DotUtil.getInstance()
            .reportSendReceiveSuccessRate(msgType,
                dotCommon.smsReceiveRecord.SUCCESS_RATE_BEHAVIOR_RECEIVE,
                dotCommon.smsReceiveRecord.SUCCESS_RATE_STATE_START);
    }

    // 第一次解锁，针对接收的短信正常发送通知处理
    public async handleFirstUnLockedScreenNotification(context: Context) {
        if (this.isProcessingMessageUserUnlocked === true) {
            // 用户解锁事件和启动应用兜底冲突时，只执行一次。
            HiLog.e(TAG, 'isProcessingMessageUserUnlocked is true')
            return;
        }
        this.isProcessingMessageUserUnlocked = true;
        // 1.取消未解锁时发送的匿名通知
        UnLockedNotifyService.getInstance().cancelFirstUnlockedNotify()
        // 2.获取匿名通知数据列表
        this.unLockedNotifyService.queryUnLockedNotify((unlockedNotifications: [DataParameters]) =>{
            // 3.正常发送匿名通知
            HiLog.i(TAG, 'unlockedNotification length is : ' + unlockedNotifications.length)
            for (let unlockedNotification of unlockedNotifications) {
                HiLog.i(TAG, 'send unlocked notification ')
                if (unlockedNotification.event === common.STR.SUBSCRIBER_MMS_EVENT) {
                    if (!unlockedNotification.parameters?.isNotificationFlag) {
                        let str: string = JSON.stringify(unlockedNotification) as string;
                        mmsReceive.receivePduAndBaseInfo(this.context, str);
                        HiLog.i(TAG, 'onReceiveEvent, receivePduAndBaseInfo successful');
                    }
                } else {
                    this.handleNormalSMSForHasLockedScreen(unlockedNotification)
                }
            }
            // 静态订阅进程正常处理完匿名通知后，清理标记。 UIAbility就不需要再重试了。
            try {
                settings.setValueSync(context, commonData.STR.RECEIVE_MESSAGE_USER_LOCK, commonData.bool.FALSE);
            } catch (err) {
                HiLog.e(TAG, `setValueSync error, code: ${err.code}, message: ${err.message} `);
            }
            // 4.删除所有未第一次解锁的通知
            this.unLockedNotifyService.deleteUnLockedNotify(() => {}, context)
        }, context)
    }

    handleFlashSMS(data: DataParameters, result: LooseObject): void {
        data.parameters.isFlashMessage = true
        // 创建系统弹窗
        DeskDialogConnection.getInstance(this.context).jumpToConv({
            data : data,
            result : result,
        })
    }

    async isOsAccountUnlocked(): Promise<boolean> {
        try {
            const isOsAccountUnlocked = await this.accountManager.isOsAccountUnlocked();
            HiLog.i(TAG, `isOsAccountUnlocked is ${isOsAccountUnlocked}`)
            return isOsAccountUnlocked;
        } catch (error) {
            HiLog.i(TAG, `isOsAccountUnlocked exception: + ${JSON.stringify(error)}`)
            return false;
        }
    }

    async handleNormalSMS(data: DataParameters, isMms: boolean = false): Promise<void> {
        // 用户是否设置密码
        let isSecureMode = await screenLock.isSecureMode()
        HiLog.w(TAG, `isSecureMode ${isSecureMode} ` + `MoveEL2 ${this.unLockedNotifyService.dataIsMoveEL5}`)
        if (isSecureMode && this.unLockedNotifyService.dataIsMoveEL5) {
            //  用户是否解锁
            let isOsAccountUnlocked = await this.isOsAccountUnlocked()
            HiLog.w(TAG, `userunlocked ${isOsAccountUnlocked}`)
            if (isOsAccountUnlocked) {
                if (isMms) {
                    if (!data.parameters.isNotificationFlag) {
                        let str: string = JSON.stringify(data) as string;
                        mmsReceive.receivePduAndBaseInfo(this.context, str);
                        HiLog.w(TAG, 'onReceiveEvent, receivePduAndBaseInfo successful');
                    }
                } else {
                    this.handleNormalSMSForHasLockedScreen(data)
                }
            } else {
                // 首次开机未解锁，收到信息
                this.receiveService.startMmsAbilityAndSendNotify(data)
            }
        } else {
            HiLog.i(TAG, 'handleNormalSMS')
            if (isMms) {
                if (!data.parameters.isNotificationFlag) {
                    let str: string = JSON.stringify(data) as string;
                    mmsReceive.receivePduAndBaseInfo(this.context, str);
                    HiLog.i(TAG, 'onReceiveEvent, receivePduAndBaseInfo successful');
                }
            } else {
                this.handleNormalSMSForHasLockedScreen(data)
            }
        }
    }

    private handleNormalSMSForHasLockedScreen(data: DataParameters) {
        let dataObj = data.parameters;
        this.receiveService.sendRcsSendBroadcast(data, this.context);
        this.receiveService.sendRcsRecvBroadcast(data, this.context);
        if (!dataObj.isNotificationFlag) {
            HiLog.w(TAG, 'onReceiveEvent: sms message');
            this.receiveService.dealSmsReceiveData(data, this.context);
        }
    }
}
