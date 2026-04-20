/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import ServiceExtensionAbility from '@ohos.app.ability.ServiceExtensionAbility';
import Want from '@ohos.app.ability.Want';
import { GlobalContext } from '../MainAbility/GlobalHelper';
import SharedPreferencesUtils from '../utils/SharedPreferencesUtils';
import ReceiveService from './ReceiveService';
import HiLog from '../utils/HiLog';
import { DataParameters, LocationType, MessageDetail, mmsInfoBaseParam } from '../utils/TypesUtils';
import Constant from '../data/Constant';
import LooseObject from '../data/LooseObject';
import lazy { smartMmsInit } from './ServiceExtTools';
import common from '../data/commonData';
import DotUtil from '../utils/MmsDot/DotUtils';
import NotificationService from '../service/NotificationService';
import ConversationListController from '../pages/conversationlist/conversationListController';
import ConversationController from '../pages/conversation/conversationController';
import { UnLockedNotifyService } from '../utils/UnLockedNotifyService';
import { settings } from '@kit.BasicServicesKit';

const TAG = 'ServiceExtAbility';

export default class ServiceExtAbility extends ServiceExtensionAbility {
  public receiveService = ReceiveService.getInstance();

  onCreate(want: Want) {
    HiLog.i(TAG, 'ServiceExtensionAbility onCreate');
    smartMmsInit(this.context);
    GlobalContext.getContext().setObject('mmsServiceContext', this.context);
    SharedPreferencesUtils.init(this.context);
  }

  async onRequest(want: Want, startId: number) {
    HiLog.i(TAG, 'ServiceExtensionAbility onRequest');
    if (want == null) {
      HiLog.e(TAG, 'ServiceExtensionAbility onRequest onRequest is null');
      return;
    }
    if (want.parameters == null) {
      HiLog.e(TAG, 'ServiceExtensionAbility onRequest parameters is null');
      return;
    }
    let serviceEvent: string = want.parameters.serviceEvent as string;
    switch (serviceEvent) {
      case Constant.BLOCKED_SERVICE_MMS_DETECT_EVENT:
        HiLog.w(TAG, 'ServiceExtensionAbility mms detect event start');
        let mmsData: LooseObject = want.parameters.data as LooseObject;
        this.receiveService.continueReceiveMms(mmsData, this.context);
        let mmsReceiveIdForDot = DotUtil.getInstance().createSmsReceiveRecord();
        mmsData.smsReceiveIdForDot = mmsReceiveIdForDot;
        DotUtil.getInstance().addSmsReceiveParam(mmsReceiveIdForDot, mmsData, true);
        HiLog.i(TAG, 'mms applyEfficiencyResources');
        this.receiveService.applyEfficiencyResources(Constant.MMS_TIMEOUT);
        break;
      case Constant.VERCODE_SERVICE_EVENT:
        HiLog.w(TAG, 'ServiceExtensionAbility verCodeCheck start');
        let verCodeData: MessageDetail = want.parameters.data as MessageDetail;
        let smsReceiveIdForDot = DotUtil.getInstance().createSmsReceiveRecord();
        verCodeData.smsReceiveIdForDot = smsReceiveIdForDot;
        DotUtil.getInstance().addSmsReceiveParam(smsReceiveIdForDot, verCodeData, false);
        this.receiveService.handleSendMsgWithRepairMode(verCodeData, this.context);
        break;
      case Constant.RCS_LOCATION_GET_THUMBNAILS:
        break;
      case common.STR.SUBSCRIBER_FIRST_UNLOCK_EVENT:
        break;
      case common.STR.SUBSCRIBER_SCREEN_UNLOCK_EVENT:
        HiLog.i(TAG, 'reset notification start ' + serviceEvent);
        NotificationService.getInstance(this.context).resetLockScreenNotification(this.context);
        this.receiveService.applyEfficiencyResources(Constant.SMS_TIMEOUT);
        HiLog.i(TAG, 'reset notification end ' + serviceEvent);
        break;
      case common.STR.KEY_DATA_TO_EL5:
        this.onDBMoveCompletedChange();
        HiLog.i(TAG, 'data move to el5')
        this.receiveService.applyEfficiencyResources(Constant.SMS_TIMEOUT);
        break;
      case common.STR.SUBSCRIBER_FIRST_LOCK_RECV_EVENT:
        if (UnLockedNotifyService.getInstance().dataIsMoveEL5) {
          let notificationData = want.parameters.data as DataParameters;
          if (notificationData) {
            // 匿名通知来了，需要先设置标记 1
            try {
              settings.setValueSync(this.context, common.STR.RECEIVE_MESSAGE_USER_LOCK, common.bool.TRUE);
            } catch (err) {
              HiLog.e(TAG, `setValueSync error, code: ${err.code}, message: ${err.message} `);
            }
            let val = settings.getValueSync(this.context, common.STR.RECEIVE_MESSAGE_USER_LOCK, common.bool.NOT_SET);
            HiLog.i(TAG, `first lock receive notification data， settings.mms.receive_message_user_unlock = ${val}`);
            UnLockedNotifyService.getInstance().sendFirstLockReceiveNotify(notificationData, this.context)
          }
          HiLog.i(TAG, 'first lock event: ' + serviceEvent);
        }
        break;
      case Constant.BLOCKED_SERVICE_RCS_DETECT_EVENT:
      case common.STR.SUBSCRIBER_BOOT_COMPLETED:
        // 无密码的时候，不会收到user_unlock事件，使用BOOT_COMPLETED代替。
        // 用户首次输入密码解锁，使用拉起数据库进程进行数据迁移。这里保活30s。
        HiLog.i(TAG, 'begin file migration ' + serviceEvent);
        this.receiveService.applyEfficiencyResources(Constant.FILE_MIGRATION_TIMEOUT);
        // 增删改查会拉起数据库。
        UnLockedNotifyService.getInstance().queryUnLockedNotify(() => {}, this.context)
        break;
      default: {
        HiLog.e(TAG, 'invalid request serviceEvent: ' + serviceEvent);
        break;
      }
    }
  }
  // 二次挂载事件，触发首页提前刷新
  private onDBMoveCompletedChange() {
    let mConListCtrl = ConversationListController.getInstance();
    GlobalContext.getContext().setObject('needToUpdate', true);
    mConListCtrl.lastIndex = -1;
    mConListCtrl.getSettingFlagForConvListPage();
    mConListCtrl.refreshConversationListData(this.context);
  }

  onDisconnect(want: Want) {
    HiLog.i(TAG, 'ServiceExtensionAbility onDisconnect');
  }

  onDestroy() {
    HiLog.w(TAG, `ServiceExtensionAbility onDestroy, releaseResourceNumber ${ReceiveService.getInstance().releaseResourceNumber}`);
  }
}