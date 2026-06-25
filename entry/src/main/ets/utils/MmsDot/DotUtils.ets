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
import hiSysEvent from '@ohos.hiSysEvent';
import { BusinessError } from '@ohos.base';
import bundleManager from '@ohos.bundle.bundleManager';
import HiLog from '../HiLog';
import dotCommon, {
  ConsumerBehaviorParams,
  CPUAndMEMParams,
  MsgReceiveSendSuccessRateParams,
  NotificationMuteParams,
  NotificationSlotParams,
  ReceiveMessageDownloadParams,
  sendMessageCommonParams,
  SmsReceiveParams,
  MsgServiceNumberParams,
  SmsSwitchStatusParams
} from './DotCommon';
import { workScheduler } from '@kit.BackgroundTasksKit';
import securityGuard from '@ohos.security.securityGuard';
import { MessageDetail } from '../TypesUtils';
import LooseObject from '../../data/LooseObject';
import commonData from '../../data/commonData';
import MmsPreferences from '../MmsPreferences';
import StringUtil from '../StringUtil';
import { sim } from '@kit.TelephonyKit';
import { notificationManager } from '@kit.NotificationKit';
import { settings } from '@kit.BasicServicesKit';
import Constant from '../../data/Constant';
import SharedPreferencesUtils from '../SharedPreferencesUtils';
import common from '../../data/commonData'
import MessageUtil from '../../../cust/utils/MessageUtil';
import { JSON } from '@kit.ArkTS';
import TimeUtils from '../../pages/smc/utils/TimeUtils';

const TAG = 'DotUtil';
const DOMAIN = 'MMS_UE';
const DOMAIN_FAIL = 'MMS';
const BLOCKEDDOMAIN = 'SPAMSHIELD_UE';
const PNAMEID = 'com.ohos.mms';
// 1 week
const REPEATTIME = 1000 * 60 * 60 * 24 * 7;

export default class DotUtil {
  private static instance: DotUtil;
  versionNumber: string = '';
  private recordsForSmsReceive: Map<number, SmsReceiveParams> = new Map();
  private currentMaxKey = 0;

  public static getInstance(): DotUtil {
    if (!DotUtil.instance) {
      DotUtil.instance = new DotUtil();
    }
    return DotUtil.instance;
  }

  createSmsReceiveRecord(): number {
    let params: SmsReceiveParams = {};
    this.recordsForSmsReceive.set(++this.currentMaxKey, params);
    return this.currentMaxKey;
  }

  addSmsReceiveParam(smsReceiveIdForDot: number, msgDetail: LooseObject, isMms: boolean) {
    if (!this.recordsForSmsReceive.has(smsReceiveIdForDot)) {
      HiLog.e(TAG, 'addSmsReceiveParam fail, no record:' + smsReceiveIdForDot);
      return;
    }
    let smsReceiveParams = this.recordsForSmsReceive.get(smsReceiveIdForDot) || {};
    smsReceiveParams.phoneNumber = msgDetail.telephoneDot;
    smsReceiveParams.phoneNumberType = msgDetail.telephoneType;
    smsReceiveParams.slotId = msgDetail.slotId;
    smsReceiveParams.msgType = msgDetail.dotMsgType;
    smsReceiveParams.mccmnc = msgDetail.mccmnc;
    // 彩信
    if (isMms) {
      smsReceiveParams.msgType = dotCommon.smsReceiveRecord.SMS_RECEIVE_TYPE_MMS;
      smsReceiveParams.expirationTime = msgDetail.expiresTime;
      smsReceiveParams.mmsSize = msgDetail.msgSize;
      smsReceiveParams.pduLength = msgDetail.mmsPduLength;
    }
    smsReceiveParams.failReason = msgDetail.receiveNull;
  }

  addSmsReceiveBlockResult(smsReceiveIdForDot: number, blockResult: LooseObject) {
    if (!this.recordsForSmsReceive.has(smsReceiveIdForDot)) {
      HiLog.e(TAG, 'addSmsReceiveBlockResult fail, no record:' + smsReceiveIdForDot);
      return;
    }
    let smsReceiveParams = this.recordsForSmsReceive.get(smsReceiveIdForDot) || {};
    smsReceiveParams.isBlocked = blockResult.detectResult as number;
    smsReceiveParams.blockedReason = blockResult.decisionReason as number;
    smsReceiveParams.blockedType = blockResult.markType as number || -1;
  }

  addSmsReceiveNumberParam(smsReceiveIdForDot: number, recordKey: number, recordValue: number) {
    if (!this.recordsForSmsReceive.has(smsReceiveIdForDot)) {
      HiLog.e(TAG, 'addSmsReceiveNumberParam fail, no record:' + smsReceiveIdForDot);
      return;
    }
    let smsReceiveParams = this.recordsForSmsReceive.get(smsReceiveIdForDot) || {};
    HiLog.i(TAG, 'addSmsReceiveBlockResult recordKey:' + recordKey);
    HiLog.i(TAG, 'addSmsReceiveBlockResult recordValue:' + recordValue);
    switch (recordKey) {
      case dotCommon.smsReceiveRecord.RECORD_KEY_IS_VER_MSG:
        smsReceiveParams.isVerMsg = recordValue;
        break;
      case dotCommon.smsReceiveRecord.RECORD_KEY_BLOCKED_TYPE:
        smsReceiveParams.blockedFlag = recordValue;
        break;
      default:
        break;
    }
  }

  reportServiceNumberEvent(params: MsgServiceNumberParams, eventName: string) {
    this.updateMmsVersion().then(() => {
      params.PNAMEID = PNAMEID;
      params.PVERSIONID = this.versionNumber;
      let eventInfo: hiSysEvent.SysEventInfo = {
        domain: DOMAIN,
        name: eventName,
        eventType: hiSysEvent.EventType.BEHAVIOR,
        params: params
      };
      hiSysEvent.write(eventInfo, (error: BusinessError) => {
        if (error) {
          HiLog.e(TAG, 'reportStatisticEvent error, name is', eventName, JSON.stringify(error, ['error', 'message']));
        } else {
          HiLog.i(TAG, `reportStatisticEvent success, name is: ${JSON.stringify(eventName)}`);
        }
      })
    });
  }

  addDotInfoReceiveParam(smsReceiveIdForDot: number, isMms: boolean, recordValue: string) {
    if (!this.recordsForSmsReceive.has(smsReceiveIdForDot)) {
      HiLog.e(TAG, 'addDotInfoReceiveParam fail, no record:' + smsReceiveIdForDot);
      return;
    }
    let smsReceiveParams = this.recordsForSmsReceive.get(smsReceiveIdForDot) || {};
    HiLog.i(TAG, 'addDotInfoReceiveParam recordValue:' + recordValue);
    smsReceiveParams.msgId = recordValue;
    if (isMms) {
      this.reportSmsReceiveEvent(smsReceiveIdForDot);
    }
  }

  addFailReason(smsReceiveIdForDot: number, failReason: string, reportDirectly: boolean = false) {
    if (!this.recordsForSmsReceive.has(smsReceiveIdForDot)) {
      HiLog.e(TAG, 'addFailReason fail, no record:' + smsReceiveIdForDot);
      return;
    }
    let smsReceiveParams = this.recordsForSmsReceive.get(smsReceiveIdForDot) || {};
    smsReceiveParams.failReason =
      StringUtil.isEmpty(smsReceiveParams.failReason) ? failReason : smsReceiveParams.failReason + failReason;
    if (reportDirectly) {
      this.reportSmsReceiveEvent(smsReceiveIdForDot);
    }
  }

  reportSmsReceiveEvent(smsReceiveIdForDot: number) {
    if (!this.recordsForSmsReceive.has(smsReceiveIdForDot)) {
      HiLog.e(TAG, 'reportSmsReceiveEvent fail, no record:' + smsReceiveIdForDot);
      return;
    }
    let smsReceiveParams = this.recordsForSmsReceive.get(smsReceiveIdForDot) || {};
    let dotParams: ConsumerBehaviorParams = {
      PHONENUMBER: smsReceiveParams.phoneNumber,
      PHONENUMBER_TYPE: smsReceiveParams.phoneNumberType,
      SLOTID: smsReceiveParams.slotId,
      SIM_TYPE: MmsPreferences.getInstance().getTypeOfSlot(smsReceiveParams.slotId),
      SIM_INDEX: MmsPreferences.getInstance().getIndexOfSlot(smsReceiveParams.slotId),
      MSG_TYPE: smsReceiveParams.msgType,
      IS_VER_CODE: smsReceiveParams.isVerMsg,
      BLOCKED_FLAG: smsReceiveParams.blockedFlag,
      IS_BLOCKED: smsReceiveParams.isBlocked,
      BLOCKED_REASON: smsReceiveParams.blockedReason,
      BLOCKED_TYPE: smsReceiveParams.blockedType,
      FAIL_REASON: smsReceiveParams.failReason,
      MCCMNC: smsReceiveParams.mccmnc,
      MSGID: smsReceiveParams.msgId,
      PDU_LENGTH: smsReceiveParams.pduLength,
      EXPIRATION_TIME: smsReceiveParams.expirationTime,
      MMS_SIZE: smsReceiveParams.mmsSize
    };
    this.reportEvent(dotParams, dotCommon.eventName.RECEIVE_MESSAGE_COMMON);
    this.deleteSmsReceiveRecord(smsReceiveIdForDot);
  }

  deleteSmsReceiveRecord(smsReceiveIdForDot: number) {
    if (this.recordsForSmsReceive.has(smsReceiveIdForDot)) {
      this.recordsForSmsReceive.delete(smsReceiveIdForDot);
    }
  }

  async updateMmsVersion(): Promise<void> {
    if (this.versionNumber != '') {
      return;
    }
    try {
      let bundleInfo: bundleManager.BundleInfo = await bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
      this.versionNumber = bundleInfo.versionName;
    } catch (err) {
      HiLog.i(TAG, `err: ${err}`);
    }
  }

  reportEvent(params: ConsumerBehaviorParams | NotificationMuteParams | MsgReceiveSendSuccessRateParams |
    ReceiveMessageDownloadParams, eventName: string) {
  try {
    this.updateMmsVersion().then(() => {
      params.PNAMEID = PNAMEID;
      params.PVERSIONID = this.versionNumber;
      let eventInfo: hiSysEvent.SysEventInfo = {
        domain: DOMAIN,
        name: eventName,
        eventType: hiSysEvent.EventType.BEHAVIOR,
        params: params
      };
      hiSysEvent.write(eventInfo).then(
        (_) => {
          HiLog.i(TAG, `reportEvent report success, name is: ${JSON.stringify(eventName)}`);
        }
      ).catch((error: BusinessError) => {
        HiLog.e(TAG, 'reportEvent report error, name is', eventName, JSON.stringify(error, ['error', 'message']));
      })
    })
  } catch (error) {
      HiLog.e(TAG, 'reportEvent catch report error', JSON.stringify(error, ['error', 'message']));
    }
  }

  /**
   * 短信收发成功率打点
   * @param type 类型-1.短信2.彩信3.增强信息
   * @param behavior 行为-1.接收2.发送3.下载
   * @param state 状态-1.开始2.完成
   */
  public reportSendReceiveSuccessRate(type: number, behavior: number, state: number) {
    if (Number.isNaN(type) || Number.isNaN(behavior) || Number.isNaN(state)) {
      HiLog.w(TAG, `reportSendReceiveSuccessRate params invalid type: ${type}.behavior:${behavior}.state:${state}`);
      return;
    }
    let param = new MsgReceiveSendSuccessRateParams();
    param.TYPE = type;
    param.BEHAVIOR = behavior;
    param.STATE = state;
    this.reportEvent(param, dotCommon.eventName.MSG_SEND_RECEIVE_SUCCESS_RATE);
  }

  /**
   * 短信收发成功率打点-接收成功打点
   * @param msg 消息详情
   */
  public reportSendReceiveSuccessRateForReceived(msg: MessageDetail) {
    if (!msg) {
      HiLog.w(TAG, `reportSendReceiveSuccessRateForReceived params invalid`);
      return;
    }
    let param = new MsgReceiveSendSuccessRateParams();
    if (msg?.type === commonData.RCS_TYPE.RCS || msg?.type === commonData.RCS_TYPE.RCS_SEND) {
      param.TYPE = dotCommon.smsReceiveRecord.SUCCESS_RATE_TYPE_RCS;
    } else if (msg?.isMms) {
      param.TYPE = dotCommon.smsReceiveRecord.SUCCESS_RATE_TYPE_MMS;
    } else {
      param.TYPE = dotCommon.smsReceiveRecord.SUCCESS_RATE_TYPE_SMS;
    }
    param.BEHAVIOR = dotCommon.smsReceiveRecord.SUCCESS_RATE_BEHAVIOR_RECEIVE;
    param.STATE = dotCommon.smsReceiveRecord.SUCCESS_RATE_STATE_FINISHED;
    this.reportEvent(param, dotCommon.eventName.MSG_SEND_RECEIVE_SUCCESS_RATE);
  }

  /**
   * 短信收发成功率打点-RCS接收完成打点
   * @param msg 消息详情
   */
  public reportSendReceiveSuccessRateForRCSReceived() {
    let param = new MsgReceiveSendSuccessRateParams();
    param.TYPE = dotCommon.smsReceiveRecord.SUCCESS_RATE_TYPE_RCS;
    param.BEHAVIOR = dotCommon.smsReceiveRecord.SUCCESS_RATE_BEHAVIOR_RECEIVE;
    param.STATE = dotCommon.smsReceiveRecord.SUCCESS_RATE_STATE_FINISHED;
    this.reportEvent(param, dotCommon.eventName.MSG_SEND_RECEIVE_SUCCESS_RATE);
  }

  /**
   * 短信收发成功率打点-发送完成打点
   * @param type 消息类型
   */
  public reportSuccessRateForSendFinished(type: number) {
    if (Number.isNaN(type)) {
      HiLog.w(TAG, `reportSendReceiveSuccessRateForRCSSend params invalid type: ${type}`);
      return;
    }
    let param = new MsgReceiveSendSuccessRateParams();
    param.TYPE = type;
    param.BEHAVIOR = dotCommon.smsReceiveRecord.SUCCESS_RATE_BEHAVIOR_SEND;
    param.STATE = dotCommon.smsReceiveRecord.SUCCESS_RATE_STATE_FINISHED;
    this.reportEvent(param, dotCommon.eventName.MSG_SEND_RECEIVE_SUCCESS_RATE);
  }

  /**
   * 短信收发成功率打点-发送开始打点
   * @param type 消息类型
   */
  public reportSuccessRateForSendStart(type: number) {
    if (Number.isNaN(type)) {
      HiLog.w(TAG, `reportSendReceiveSuccessRateForRCSSend params invalid type: ${type}`);
      return;
    }
    let param = new MsgReceiveSendSuccessRateParams();
    param.TYPE = type;
    param.BEHAVIOR = dotCommon.smsReceiveRecord.SUCCESS_RATE_BEHAVIOR_SEND;
    param.STATE = dotCommon.smsReceiveRecord.SUCCESS_RATE_STATE_START;
    this.reportEvent(param, dotCommon.eventName.MSG_SEND_RECEIVE_SUCCESS_RATE);
  }

  reportFaultEvent(params: ConsumerBehaviorParams, eventName: string) {
    this.reportMaintenanceEvent(params,eventName,hiSysEvent.EventType.FAULT);
  }

  reportMaintenanceEvent(params: ConsumerBehaviorParams, eventName: string,eventType: hiSysEvent.EventType) {
    try {
      this.updateMmsVersion().then(() => {
        params.PNAMEID = PNAMEID;
        params.PVERSIONID = this.versionNumber;
        let eventInfo: hiSysEvent.SysEventInfo = {
          domain: DOMAIN_FAIL,
          name: eventName,
          eventType: eventType,
          params: params
        };
        hiSysEvent.write(eventInfo).then(
          (_) => {
            HiLog.i(TAG, `reportFaultEvent report success, name is: ${JSON.stringify(eventName)}`);
          }
        ).catch((error: BusinessError) => {
          HiLog.e(TAG, 'reportFaultEvent report error, name is', eventName,
            JSON.stringify(error, ['error', 'message']));
        })
      })
    } catch (error) {
      HiLog.e(TAG, 'reportFaultEvent catch report error', JSON.stringify(error, ['error', 'message']));
    }
  }

  reportBlockedEvent(params: ConsumerBehaviorParams, eventName: string) {
    try {
      this.updateMmsVersion().then(() => {
        params.PNAMEID = PNAMEID;
        params.PVERSIONID = this.versionNumber;
        let eventInfo: hiSysEvent.SysEventInfo = {
          domain: BLOCKEDDOMAIN,
          name: eventName,
          eventType: hiSysEvent.EventType.BEHAVIOR,
          params: params
        };
        hiSysEvent.write(eventInfo).then(
          (_) => {
            HiLog.i(TAG, `reportBlockedEvent report success, name is: ${JSON.stringify(eventName)}`);
          }
        ).catch((error: BusinessError) => {
          HiLog.e(TAG, 'reportBlockedEvent report error, name is', eventName, JSON.stringify(error, ['error', 'message']));
        })
      })
    } catch (error) {
      HiLog.e(TAG, 'reportBlockedEvent catch report error', JSON.stringify(error, ['error', 'message']));
    }
  }

  reportStatisticEvent(params: ConsumerBehaviorParams, eventName: string) {
    this.updateMmsVersion().then(() => {
      params.PNAMEID = PNAMEID;
      params.PVERSIONID = this.versionNumber;
      let eventInfo: hiSysEvent.SysEventInfo = {
        domain: DOMAIN,
        name: eventName,
        eventType: hiSysEvent.EventType.STATISTIC,
        params: params
      };
      hiSysEvent.write(eventInfo, (error: BusinessError) => {
        if (error) {
          HiLog.e(TAG, 'reportStatisticEvent error, name is', eventName, JSON.stringify(error, ['error', 'message']));
        } else {
          HiLog.i(TAG, `reportStatisticEvent success, name is: ${JSON.stringify(eventName)}`);
        }
      })
    });
  }

  reportCpuEvent(params: CPUAndMEMParams) {
    try {
      let eventName: string = 'CPU_SCENE_ENTRY';
      this.updateMmsVersion().then(() => {
        let eventInfo: hiSysEvent.SysEventInfo = {
          domain: 'PERFORMANCE',
          name: eventName,
          eventType: hiSysEvent.EventType.BEHAVIOR,
          params: params
        };
        hiSysEvent.write(eventInfo).then(
          (_) => {
            HiLog.i(TAG, 'reportEvent report success, name is: ' + eventName);
          }
        ).catch((error: BusinessError) => {
          HiLog.e(TAG, 'reportEvent report error, name is', eventName, JSON.stringify(error, ['error', 'message']));
        })
      })
    } catch (error) {
      HiLog.e(TAG, 'reportEvent catch report error', JSON.stringify(error, ['error', 'message']));
    }
  }

  public startStatisticReport() {
    workScheduler.obtainAllWorks().then((workList) => {
      if (workList.length) {
        return;
      }
      const workInfo: workScheduler.WorkInfo = {
        workId: 10086,
        bundleName: PNAMEID,
        abilityName: 'MmsReporterWorkSchedulerAbility',
        isRepeat: true,
        isPersisted: true,
        repeatCycleTime: REPEATTIME
      }
      try {
        workScheduler.startWork(workInfo);
        HiLog.i(TAG, `startStatisticReport SUCCESS`);
      } catch (err) {
        HiLog.e(TAG, `startStatisticReport failed, code is ${err.code}, message is ${err.message}`);
      }
    })
  }

  public setCurrentTime(): string {
    let date = new Date();
    return date.getTime().toString();
  }

  /**
   * 通知静默打点
   * @param slotId sim卡id
   */
  public reportNotificationMute(slotId: number) {
    if (Number.isNaN(slotId)) {
      HiLog.w(TAG, `reportNotificationMute params invalid slotId: ${slotId}`);
      return;
    }
    let param = new NotificationMuteParams();
    param.CARD_SELECT_STATUS = slotId;
    this.reportEvent(param, dotCommon.eventName.NOTIFICATION_MUTE_REPORT_EVENT);
  }

  /**
   * 短信_短信基础功能_附件_相机_低内存相机界面
   * @param type 按钮类型
   */
  public reportLowMemoryCamera(type: number) {
    let dotParams: ConsumerBehaviorParams = {
      TYPE: type,
    };
    this.reportEvent(dotParams, dotCommon.eventName.LOW_MEMORY_CAMERA);
  }

  /**
   * 短信_短信基础功能_附件_相机_低内存相机拍照后预览界面
   * @param type 按钮类型
   */
  public reportLowMemoryPhotoPreview(type: number) {
    let dotParams: ConsumerBehaviorParams = {
      TYPE: type,
    };
    this.reportEvent(dotParams, dotCommon.eventName.LOW_MEMORY_CAMERA_PREVIEW);
  }

  /**
   * 短信_短信基础功能_短信发送打点
   * @param params 上报参数
   */
  public reportSendMessageCommon(params: LooseObject) {
    sendMessageCommonParams.PHONE_NUMBER = StringUtil.phoneMask(params.destinationHost);
    try {
      let mccMnc = sim.getSimOperatorNumericSync(params.slotId);
      sendMessageCommonParams.MCCMNC = mccMnc;
    } catch (e) {
      HiLog.i(TAG, 'getMmsc error: ' + JSON.stringify(e));
    }
    sendMessageCommonParams.SLOTID = params.slotId;
    sendMessageCommonParams.MSG_TYPE = params.msgType;
    sendMessageCommonParams.MSG_CONTENT = params.msgContent;
    sendMessageCommonParams.SEND_RESULT = params.sendResult;
    sendMessageCommonParams.MSGID = params.id as string;
    sendMessageCommonParams.FAIL_REASON = params.failReason;
    DotUtil.getInstance().reportEvent(sendMessageCommonParams, dotCommon.eventName.SEND_MESSAGE_COMMON);
  }

  public securityReport(systemEventId: number, content: string) {
    /* 上报安全事件 */
    let event: securityGuard.SecurityEvent = {
      eventId: systemEventId,
      version: 'v1.0',
      content: content
    };
    try {
      securityGuard.reportSecurityEvent(event);
    } catch (error) {
      console.error(`reportSecurityEvent input arg invalid, code: ${error.code}, msg: ${error.message}`)
    }
  }

  private async setNotificationEnable(dotParams: SmsSwitchStatusParams): Promise<void> {
    try {
      let isRemind: boolean = await notificationManager.isNotificationEnabled();
      dotParams.IS_ENABLE_NOTIFICATION = isRemind ? common.switch.OPEN : common.switch.CLOSE;
    } catch (error) {
      HiLog.e(TAG, `get isNotificationEnabled error, code is:${error?.code},message is ${error?.message}`);
    }
  }

  private setFocusMode(context: Context, dotParams: SmsSwitchStatusParams): void {
    try {
      let isFocusMode: string = settings.getValueSync(context, 'focus_mode_enable',
        Constant.FOCUS_MODE_ENABLE_SWITCH_CLOSED, settings.domainName.USER_SECURITY);
      dotParams.IS_FOCUS_MODE = Number(isFocusMode);
    } catch (error) {
      HiLog.e(TAG, `get isFocusMode error, code is:${error?.code},message is ${error?.message}`);
    }
  }

  private setUnReadNumber(dotParams: SmsSwitchStatusParams) : void {
    // 通知未读数量
    let unReadInfo: number = SharedPreferencesUtils.getFromPreferences(common.STR.KEY_OF_UNREAD_INFO, 0) as number;
    dotParams.UNREAD_INFO = unReadInfo;
    // 首页未读数量
    let unReadHome: number = SharedPreferencesUtils.getFromPreferences(common.STR.KEY_OF_UNREAD_TOTAL, 0) as number;
    dotParams.UNREAD_HOME = unReadHome;
    // 骚扰拦截数量
    let unReadBlock: number = SharedPreferencesUtils.getFromPreferences('unReadBlockedNum', 0) as number;
    dotParams.UNREAD_BLOCK = unReadBlock;
  }

  private async setCenterNumber(dotParams: SmsSwitchStatusParams): Promise<void> {
    // 卡1短信中心
    let haveSimCard = MmsPreferences.getInstance().haveSimCardReady();
    let multiSimCard = MmsPreferences.getInstance().haveMultiSimCardReady();
    if (haveSimCard) {
      let slotId = multiSimCard ? 0 : MmsPreferences.getInstance().getDefaultSlotId();
      let number1: string = await MessageUtil.getSmscNumberFromPref(slotId);
      dotParams.CARD_CENTER_NO1 = StringUtil.phoneMask(number1);
    }
    // 卡2短信中心
    if (haveSimCard && multiSimCard) {
      let number2: string = await MessageUtil.getSmscNumberFromPref(1);
      dotParams.CARD_CENTER_NO2 = StringUtil.phoneMask(number2);
    }
  }

  private async getSwitchStatusParams(context: Context): Promise<SmsSwitchStatusParams> {
    HiLog.i(TAG, 'getSwitchStatusParams');
    let dotParams: SmsSwitchStatusParams = new SmsSwitchStatusParams();
    // 1.允许通知 isEnableNotification 1开启 0未开启
    await this.setNotificationEnable(dotParams);
    // 2.通知渠道集合 {"enabled":true,"notificationType":1},{"enabled":true,"notificationType":4}
    dotParams.NOTIFICATION_CHANNELS =  await this.getNotificationChannels();
    // 3.免打扰 isFocusMode 1开启 0未开启
    this.setFocusMode(context, dotParams);
    // 4.通知信息整合 1开启 0关闭
    let isIntegration: string = SharedPreferencesUtils.getFromPreferences(common.STR.KEY_OF_INTEGRATION_SWITCH,
      common.bool.FALSE) as string;
    dotParams.IS_INTEGRATION = Number(isIntegration);
    // 6.显示联系人头像 1开启 0关闭
    let showContactStatus: string = SharedPreferencesUtils.getFromPreferences(common.STR.KEY_OF_SHOW_CONTACT_SWITCH,
      common.bool.NOT_SET) as string;
    dotParams.SHOW_CONTANT_SWITCH = Number(showContactStatus);
    // 7.陌生号码和信息识别 1开启 0关闭
    let isIdentity: string = settings.getValueSync(context, common.STR.NUMBER_IDENTITY_SEITCH, common.bool.FALSE);
    dotParams.IS_IDENTITY = Number(isIdentity);
    // 8.智能信息
    let isOpenSmart = SharedPreferencesUtils.getFromPreferences('isOpenSmart', common.bool.FALSE) as boolean;
    dotParams.IS_OPEN_SMART = isOpenSmart ? common.switch.OPEN : common.switch.CLOSE;
    // 10.增强信息 1开启 0关闭
    let rcsState: boolean = SharedPreferencesUtils.getFromPreferences('isUIOpenRcs', false) as boolean
    dotParams.IS_RCS_STATE = rcsState ? common.switch.OPEN : common.switch.CLOSE;
    // 11.送达报告 3短信和彩信 2彩信 1短信 0关闭
    let deliveryReportSwitch: string = SharedPreferencesUtils.getFromPreferences(
      common.STR.KEY_OF_DELIVERY_REPORT_SWITCH, common.DELIVERY_REPORTS.DISABLED) as string;
    dotParams.DELIVERY_REPORT_SWITCH = Number(deliveryReportSwitch);
    // 未读角标
    this.setUnReadNumber(dotParams);
    // 短信中心
    await this.setCenterNumber(dotParams);
    return dotParams;
  }

  private async getNotificationChannels(): Promise<string[]> {
    return new Promise<string[]>((resolve) => {
      const MMS_BUNDLE: notificationManager.BundleOption = { bundle: commonData.STR.BUNDLE_NAME };
      let slots: string[] = [];
      notificationManager.getSlotsByBundle(MMS_BUNDLE).then((data: Array<notificationManager.NotificationSlot>) => {
        data.forEach((slot) => {
          HiLog.i(TAG,
            `getNotificationChannels getSlotsByBundle,type:${slot?.notificationType}.enabled:${slot?.enabled}`);
          let slotU = new NotificationSlotParams();
          slotU.enabled = slot?.enabled;
          slotU.notificationType = slot?.notificationType;
          slots.push(JSON.stringify(slotU));
        })
        resolve(slots);
      }).catch((err: BusinessError) => {
        HiLog.e(TAG, `getNotificationChannels getSlotsfailed,code is:${err?.code},message is ${err?.message}`);
        resolve(slots);
      });
    });
  }

  public switchStatusReport(context: Context): void {
    let lastRemindTime = SharedPreferencesUtils.getFromPreferences('SWITCH_STATUS_REPORT_TIME', '')
    const sinceLastRemindHours: number = (Date.now() - Number(lastRemindTime)) / TimeUtils.ONE_HOUR;
    if (sinceLastRemindHours < 24) {
      HiLog.i(TAG, 'No more than 24 hours since last report.')
      return;
    }
    this.getSwitchStatusParams(context).then((param: SmsSwitchStatusParams) => {
      this.reportEvent(param, dotCommon.eventName.SMS_SWITCH_STATUS_REPORT_EVENT);
      SharedPreferencesUtils.saveToPreferences(dotCommon.eventName.SWITCH_STATUS_REPORT_TIME, Date.now().toString());
    });
  }
}