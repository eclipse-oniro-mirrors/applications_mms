/**
 * Copyright (c) 2022 Huawei Device Co., Ltd.
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
import lazy WantAgent from '@ohos.app.ability.wantAgent';
import Notification from '@ohos.notificationManager';
import common from '../data/commonData';
import HiLog from '../utils/HiLog';
import ConversationService from './ConversationService';
import ConversationListService from '../service/ConversationListService';
import image from '@ohos.multimedia.image';
import LooseObject from '../data/LooseObject';
import resourceManager from '@ohos.resourceManager';
import lazy commonEvent from '@ohos.commonEvent';
import { resType } from './MmsSearchService';
import MmsPreferences from '../utils/MmsPreferences';
import notificationManager from '@ohos.notificationManager';
import { BusinessError } from '@ohos.base';
import lazy wantAgent from '@ohos.app.ability.wantAgent'
import globalNotificationManager from '@ohos.notificationManager'
import commonData from '../data/commonData';
import ConversationRcsService from './ConversationRcsService';
import dotCommon, { ConsumerBehaviorParams, dotNoNeedParmas } from '../utils/MmsDot/DotCommon';
import DotUtil from '../utils/MmsDot/DotUtils';
import DotEvent from '../utils/MmsDot/DotCommon';
import { getPixelMapFromFile } from '../utils/UserPhotoUtil';
// import rcs from '@ohos.telephony.rcs';
import promptAction from '@ohos.promptAction';
import YellowPageService from './yellowPageService';
import { util } from '@kit.ArkTS';
import StringUtil, { isJSONString } from '../utils/StringUtil';
import lazy { drawing } from '@kit.ArkGraphics2D';
import ReceiveService from '../StaticSubscriber/ReceiveService';
import { UnLockedNotifyService } from '../utils/UnLockedNotifyService';
import { screenLock, settings } from '@kit.BasicServicesKit';
import { NotificationType } from '../model/ComInfoModel';
import SharedPreferencesUtils from '../utils/SharedPreferencesUtils';
import TelephoneUtil from '../utils/TelephoneUtil';
import { Context } from '@kit.AbilityKit';
import Constant from '../data/Constant';
import { commonPasteboard } from '../data/Pasteboard';
import { BaseDataParameters, DataParameters, Response, StructText } from '../utils/TypesUtils';

export interface IBadgeContextInfo {
  appContext: Context,

  //事件信息
  updateBadgeEventCode: string
  //用于标识，用于标记业务流程。
  tracedId: string

}

/*
 *
 * */
export interface ISetBadgeContextInfo extends IBadgeContextInfo {
  unreadTotal: number
}

export interface MmsReplayParameters {
  pageFlag: string,
  contactObjects: Object,
  /*
    用于在通知栏点击进入短信详情区分服务号
   */
  notificationType: NotificationType,
  yellowPageId: string,
}

export interface MmsBlockedGuideParameters {
  pageFlag: string,
  slotId: number
}

export interface MmswantAgentInfo {
  wants: MmsWants[],
  operationType: WantAgent.OperationType,
  requestCode: Object,
  wantAgentFlags: WantAgent.WantAgentFlags[],
  extraInfo: MmsReplayParameters
};

interface MmsWants {
  deviceId: string,
  bundleName: string,
  abilityName: string,
  action: string,
  entities: Object[],
  type: string,
  uri: string
}

const label = 'notification_';
const TAG: string = 'NotificationService';
const SIM1_MUTE_ID = -10001;
const SIM2_MUTE_ID = -10002;
const SIM1_EXIT_MUTE_ID = -10003;
const SIM2_EXIT_MUTE_ID = -10004;
const SUPPORTSPEECHLANGUAGES = ['en-Latn-US', 'zh-Hans', 'zh-Hant']
let mContext: Context;

export default class NotificationService {
  private static sInstance: NotificationService = new NotificationService();
  private pictureImage?: image.PixelMap
  private page: number = 1;
  private total: number = 0;
  private sum: number = 0;

  static getInstance(context?: Context) {
    if (context) {
      mContext = context as Context
    }
    return NotificationService.sInstance;
  }

  constructor() {
    HiLog.i(TAG, 'new start');
  }

  /**
   * Send Notifications
   *
   * @param actionData
   */
  async sendNotify(actionData: LooseObject, context: Context, smsReceiveIdForDot?: number) {
    if (actionData.verCode && actionData.verCode.length > 0) {
      // 通知是验证码的情况
      this.verCodeSendNotify(actionData, context, smsReceiveIdForDot);
    } else {
      // 正常的通知
      this.normalMMSSendNotify(actionData, context, smsReceiveIdForDot);
    }
  }
  /**
   * 验证码短信的显示情况
   * @param actionData
   */
  private async verCodeSendNotify(actionData: LooseObject, context: Context, smsReceiveIdForDot?: number) {
    HiLog.w(TAG, `verCodeSendNotify, ver code event`)
    let wantAgentDataRead: LooseObject = {};
    let wantAgentDataCopyVerCode: LooseObject = {};
    let wantAgentDataNotification: LooseObject = {};
    let notificationType: NotificationType = NotificationType.NORMALMESSAGE;
    let res = await YellowPageService.getInstance()
      .judgeNoticeYellowPageExist(actionData, context)
    let isChatbotNumber: boolean = false;
    if (res.yellowPageId !== '') {
      notificationType = NotificationType.HASYELLOWPAGEMESSAGE;
    } else {
      notificationType = NotificationType.NORMALMESSAGE;
    }
    actionData.notificationType = notificationType;
    actionData.yellowPageId = res.yellowPageId;
    // Creating Want Information
    let wantAgentInfoCopy: wantAgent.WantAgentInfo = this.buildWantAgentInfoCopy(actionData);
    let wantAgentInfoRead: wantAgent.WantAgentInfo = this.buildWantAgentInfoRead(actionData);
    let wantAgentInfo: wantAgent.WantAgentInfo = this.buildWantAgentInfo(actionData);

    this.getWantAgent(wantAgentInfoRead, (data: Object) => { //标记已读
      wantAgentDataRead = data;
    });
    this.getWantAgent(wantAgentInfoCopy, (data: Object) => { //复制验证码
      wantAgentDataCopyVerCode = data;
    });
    this.getWantAgent(wantAgentInfo, (data: Object) => { //跳转信息应用
      wantAgentDataNotification = data;
    });

    let markStr: string = context.resourceManager.getStringSync($r('app.string.mark_as_read'));
    let copyStr: string = context.resourceManager.getStringSync($r('app.string.copy_verification_code'));

    let slotId: number = actionData.slotId;
    let resIdPixMap = await this.getIconPixelMap(150, 150, context, actionData);

    let contactObjects: LooseObject[] = [];
    let contactObjectsStr: string = '';
    contactObjectsStr = wantAgentInfo.extraInfo?.contactObjects;
    contactObjects = JSON.parse(contactObjectsStr);
    let contactStr: string = contactObjects[0]['contactName'] ? contactObjects[0]['contactName'] : res.name;
    if (!isChatbotNumber) {
        resIdPixMap = await this.dealNoticePageIcon(res, resIdPixMap, actionData);
    }
    actionData.message.title = contactStr;
    // not update photo
    let securityContent = JSON.stringify({ msgType: 'SMSOPT', inContacts: AppStorage.get('setinContacts'),
      occurTime: DotUtil.getInstance().setCurrentTime() });
    DotUtil.getInstance().securityReport(commonData.SECURITY_EVENT.IS_VER_CODE, securityContent);
    this.pushNotificationRequest(actionData, slotId, resIdPixMap, wantAgentDataCopyVerCode,
        copyStr, markStr, wantAgentDataRead, contactStr, context, true, wantAgentDataNotification, smsReceiveIdForDot);
  }

  /**
   * 接收到消息, 非验证码的效果
   * @param actionData 验证码的信息
   */
  private async normalMMSSendNotify(actionData: LooseObject, context: Context, smsReceiveIdForDot?: number) {
    HiLog.w(TAG, 'sendNotify, event:')
    let wantAgentDataRead: LooseObject = {};
    let wantAgentDataNotification: LooseObject = {};
    let notificationType: NotificationType = NotificationType.NORMALMESSAGE;
    // 判断通知类型
    if (actionData.contactObjects && actionData.contactObjects.length > 0 && actionData.contactObjects[0]['contactId']) {
      notificationType = NotificationType.NORMALMESSAGE;
    } else if (actionData.contactObjects && actionData.contactObjects.length > 0 && actionData.contactObjects[0]['telephone'] &&
    actionData.contactObjects[0]['telephone'].startsWith('sip:') && actionData.contactObjects[0]['telephone'].includes('botplatform')) {
      notificationType = NotificationType.OTHERNOTICMESSAGE;
    } else {
      let res = await YellowPageService.getInstance()
        .judgeNoticeYellowPageExist(actionData, context)
      if ((actionData.logoUrl !== undefined && actionData.logoUrl !== '') || actionData.comName !== '') {
        notificationType = NotificationType.SERVICEACCOUNTMESSAGE;
      } else {
        if (res.yellowPageId !== '') {
          notificationType = NotificationType.HASYELLOWPAGEMESSAGE;
        } else {
          notificationType = NotificationType.NORMALMESSAGE;
        }
      }
      actionData.yellowPageId = res.yellowPageId;
    }
    actionData.notificationType = notificationType;
    // Creating Want Information
    let wantAgentInfo: wantAgent.WantAgentInfo = this.buildWantAgentInfo(actionData);
    let wantAgentInfoRead: wantAgent.WantAgentInfo = this.buildWantAgentInfoRead(actionData);

    this.getWantAgent(wantAgentInfoRead, (data: Object) => {
      wantAgentDataRead = data;
    });
    this.getWantAgent(wantAgentInfo, (data: Object) => {
      wantAgentDataNotification = data;
    });

    let titleStr: string = context.resourceManager.getStringSync($r('app.string.reply'));
    let markStr: string = context.resourceManager.getStringSync($r('app.string.mark_as_read'))
    let slotId: number = actionData.slotId;
    HiLog.i(TAG, 'sendNotify slotId: ' + slotId);
    let resIdPixMap = await this.getIconPixelMap(150, 150, context, actionData);
    let contactObjectsStr: string = '';
    let contactObjects: LooseObject[] = [];
    contactObjectsStr = wantAgentInfo.extraInfo?.contactObjects;
    contactObjects = JSON.parse(contactObjectsStr);
    let contactNameStr: string = contactObjects[0]['contactName'] ?
    contactObjects[0]['contactName'] : actionData.message.title;
    if (contactObjects && contactObjects.length > 0 && contactObjects[0]['contactId']) {
      getPixelMapFromFile(contactObjects[0]['contactId'], true, async (pixelMap: PixelMap | null) => {
        if (pixelMap !== null) {
          if (resIdPixMap !== null) {
            resIdPixMap.release();
          }
          HiLog.i(TAG, 'has pixelMap');
          this.pushNotificationRequest(actionData, slotId, pixelMap, wantAgentDataNotification,
            titleStr, markStr, wantAgentDataRead, contactNameStr, context, undefined, undefined, smsReceiveIdForDot);
        } else if (contactObjects && contactObjects.length > 0 && contactObjects[0]['contactName'] && contactObjects[0]['contactName'][0] && this.isFirstCharNonDigit(contactObjects[0]['contactName'][0])) {
          const firstName = StringUtil.getFirstName(contactObjects[0]['contactName']) || commonData.STR.WHITE_SPACE;
          let imagePixelMap = await this.dealNoticeFirstNameIcon(context, firstName);
          this.pushNotificationRequest(actionData, slotId, imagePixelMap, wantAgentDataNotification,
            titleStr, markStr, wantAgentDataRead, contactNameStr, context, undefined, undefined, smsReceiveIdForDot);
        } else {
          HiLog.i(TAG, 'has no pixelMap');
          this.pushNotificationRequest(actionData, slotId, resIdPixMap, wantAgentDataNotification,
            titleStr, markStr, wantAgentDataRead, contactNameStr, context, undefined, undefined, smsReceiveIdForDot);
        }
      }, context)
    } else {
      let res = await YellowPageService.getInstance()
        .judgeNoticeYellowPageExist(actionData, context)
      contactNameStr = res.name
      resIdPixMap = await this.dealNoticePageIcon(res, resIdPixMap, actionData);
      actionData.message.title = contactNameStr
      // not update photo
      this.pushNotificationRequest(actionData, slotId, resIdPixMap, wantAgentDataNotification,
        titleStr, markStr, wantAgentDataRead, contactNameStr, context, undefined, undefined, smsReceiveIdForDot);
    }
    let securityContent = JSON.stringify({ msgType: 'ORDINARY', inContacts: AppStorage.get('setinContacts'),
      occurTime: DotUtil.getInstance().setCurrentTime()} );
    DotUtil.getInstance().securityReport(commonData.SECURITY_EVENT.IS_VER_CODE, securityContent);
  }

  private isFirstCharNonDigit(str: string): boolean {
    const firstChar = str.charAt(0);
    return firstChar < '0' || firstChar > '9';
  }

  private async dealNoticeFirstNameIcon(context: Context, name: string): Promise<PixelMap> {
    HiLog.i(TAG, 'dealNoticeFirstNameIcon');
    let defaultSize: image.Size = {
      'height': 150,
      'width': 150
    };
    let opts: image.DecodingOptions = {
      'index': 0,
      'sampleSize': 1,
      'rotate': 0,
      'editable': false,
      'desiredSize': defaultSize,
      'desiredRegion': {
        'size': defaultSize,
        'x': 0,
        'y': 0
      },
    };
    const resourceMgr: resourceManager.ResourceManager = context.resourceManager;
    const fileData = await resourceMgr.getRawFd('icon/user_portrait_background_only.svg');
    return new Promise<PixelMap>((resolve) => {
      const imageSource = image.createImageSource(fileData);
      imageSource.createPixelMap(opts).then((imagePixelMap) => {
        imageSource.release();
        let time = Date.now();
        HiLog.i(TAG, 'drawingIconWithPixelMap time start: ')
        this.drawingIconWithPixelMap(imagePixelMap, name);
        resolve(imagePixelMap);
      });
    });
  }

  private drawingIconWithPixelMap(imagePixelMap: image.PixelMap, name: string) {
    const canvas = new drawing.Canvas(imagePixelMap);
    const brush = new drawing.Brush();
    brush.setColor({
      alpha: 255,
      red: 255,
      green: 255,
      blue: 255
    });
    const font = new drawing.Font();
    font.setSize(75);
    const textBlob = drawing.TextBlob.makeFromString(name, font, drawing.TextEncoding.TEXT_ENCODING_UTF8);
    let bounds = textBlob.bounds();
    let textWidth = bounds.right + bounds.left;
    let textHeight = bounds.bottom + bounds.top;
    canvas.attachBrush(brush);
    canvas.drawTextBlob(textBlob, 150 / 2 - textWidth / 2, 150 / 2 - textHeight / 2);
    canvas.detachBrush();
  }

  private async dealNoticePageIcon(res: LooseObject, resIdPixMap: image.PixelMap, actionData: LooseObject) {
    HiLog.i(TAG, 'dealNoticePageIcon start')
    try {
      if (res.yellowPageId && !StringUtil.isEmpty(res.photo)) {
        resIdPixMap = this.dealNoticeYellowPageIcon(res, resIdPixMap);
      } else {
        resIdPixMap = await this.dealNotificationPageIcon(res, resIdPixMap, actionData)
      }
    } catch (e) {
      HiLog.i(TAG, 'dealNoticePageIcon err : ' + JSON.stringify(e))
    }
    return resIdPixMap;
  }

  private dealNoticeYellowPageIcon(res: LooseObject, resIdPixMap: image.PixelMap) {
    HiLog.i(TAG, 'dealNoticeYellowPageIcon start')
    let helper = new util.Base64Helper();
    let buffer: ArrayBuffer = helper.decodeSync(res.photo, util.Type.BASIC).buffer as ArrayBuffer;
    let imageSource = image.createImageSource(buffer);
    let defaultSize: image.Size = {
      'height': 150,
      'width': 150
    };
    let opts: image.DecodingOptions = {
      'index': 0,
      'sampleSize': 1,
      'rotate': 0,
      'editable': true,
      'desiredSize': defaultSize,
      'desiredRegion': {
        'size': {
          height: 0,
          width: 0
        },
        'x': 0, 'y': 0
      },
    };
    resIdPixMap = imageSource.createPixelMapSync(opts);
    imageSource.release();
    return resIdPixMap;
  }

  private async dealNotificationPageIcon(res: LooseObject, resIdPixMap: image.PixelMap, actionData: LooseObject) {
    HiLog.i(TAG, 'dealNotificationPageIcon start')
    if (actionData.smsType !== common.sms_type.COMMON) {
      let defaultSize: image.Size = {
        'height': 150,
        'width': 150
      };
      let opts: image.DecodingOptions = {
        'index': 0,
        'sampleSize': 1,
        'rotate': 0,
        'editable': false,
        'desiredSize': defaultSize,
        'desiredRegion': {
          'size': defaultSize,
          'x': 0, 'y': 0
        },
      };
      let resourceMgr: resourceManager.ResourceManager = mContext.resourceManager;
      let fileData = await resourceMgr.getRawFd('icon/user_portrait_bell.svg');
      let imageSource = image.createImageSource(fileData);
      resIdPixMap = await imageSource.createPixelMap(opts);
      imageSource.release();
    }
    return resIdPixMap;
  }

  private async dealBlockedGuideIcon(width: number, height: number, context: Context): Promise<PixelMap> {
    HiLog.w(TAG, 'dealBlockedGuideIcon start');
    let resId = $r('app.media.blocked_guide').id;
    let defaultSize: image.Size = {
      'height': height,
      'width': width
    };
    let opts: image.DecodingOptions = {
      'index': 0,
      'sampleSize': 1,
      'rotate': 0,
      'editable': false,
      'desiredSize': defaultSize,
      'desiredRegion': {
        'size': defaultSize,
        'x': 0,
        'y': 0
      },
    };
    let mgr: resourceManager.ResourceManager = context.resourceManager;
    HiLog.i(TAG, 'dealBlockedGuideIcon mgr:' + mgr);
    return new Promise<PixelMap>((resolve) => {
      mgr.getMediaContent(resId).then((value) => {
        HiLog.i(TAG, 'dealBlockedGuideIcon createPixelMap');
        let imageSource = image.createImageSource(value.buffer);
        imageSource.createPixelMap(opts).then((imagePixelMap) => {
          imageSource.release()
          resolve(imagePixelMap)
        });
      })
    });
  }

  assign(target: notificationManager.NotificationRequest,
    ...source: Object[]): notificationManager.NotificationRequest {
    for (const items of source) {
      for (const key of Object.keys(items)) {
        target[key] = Reflect.get(items, key)
      }
    }
    return target;
  }

  pushNotificationRequest(actionData: LooseObject, slotId: number, pixelMap: PixelMap | undefined,
    wantAgentDataNotification: Object, titleStr: string, markStr: string,
    wantAgentDataRead: Object, contactObject: string, context: Context, isVerCode?: boolean, toInfoAgent?: Object,
    smsReceiveIdForDot?: number) {
    HiLog.w(TAG, 'pushNotificationRequest start');
    let message: Record<string, string> = actionData.message;
    let structureTitle: string = message.title;
    let expandedTitle: string = contactObject;
    let aggregationValue: boolean = isVerCode || actionData.smsType == common.sms_type.COMMON ? true : false;
    HiLog.i(TAG, 'aggregationValue: ' + aggregationValue);
    HiLog.i(TAG, `pushNotificationRequest isMms: ${actionData?.isMms}`);
    let deliveryTime = new Date().getTime();
    let notificationRequest: notificationManager.NotificationRequest = {
      content: {
        notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_LONG_TEXT,
        longText: {
          title: structureTitle,
          text: message.text,
          longText: message.text,
          briefText: message.text,
          expandedTitle: expandedTitle,
          additionalText: '',
        },
      },
      extraInfo: {
        testBanner: true,
        SystemToneType: slotId,
      },
      unifiedGroupInfo: {
        extraInfo: {
          skipAggregate: aggregationValue
        }
      },
      // notificationSlotType在发通知前赋值
      deliveryTime: (actionData.isFirstUnlocked || actionData.isAfterReSendNotification) &&
      UnLockedNotifyService.getInstance().dataIsMoveEL5 ?
      actionData.deliveryTime : deliveryTime,
      groupName: 'MMS',
      id: actionData.msgId,
      label: label + actionData.msgId,
    };
    if (isVerCode) {
      notificationRequest.classification = 'ANS_VERIFICATION_CODE'
    }
    actionData.isReSendNotUseSpeechBroadcast = actionData.isAfterReSendNotification;
    if (actionData.isFirstUnlocked || actionData.isAfterReSendNotification) {
      HiLog.w(TAG, 'pushNotificationRequest notificationControlFlags closeSound and closeVibration');
      const notificationControlFlagsObj: LooseObject = {
        notificationControlFlags: Notification.NotificationControlFlagStatus.NOTIFICATION_STATUS_CLOSE_SOUND |
        Notification.NotificationControlFlagStatus.NOTIFICATION_STATUS_CLOSE_VIBRATION
      }
      notificationRequest = this.assign(notificationRequest, notificationControlFlagsObj);
    }
    if (isVerCode && toInfoAgent) {
      // 左边 的 大图标右下角的小图标
      HiLog.i(TAG, `send actionButtons to notificationRequest.`);
      notificationRequest.overlayIcon = pixelMap;
      notificationRequest.wantAgent = toInfoAgent;
        notificationRequest.actionButtons = [{
          title: markStr,
          wantAgent: wantAgentDataRead
        }, {
          title: titleStr,
          wantAgent: wantAgentDataNotification
        }];
    } else {
      this.notificationBarLayout(notificationRequest, wantAgentDataNotification, pixelMap, titleStr,
        markStr, wantAgentDataRead, actionData, deliveryTime, context);
    }
    let isMms: boolean = actionData?.isMms || false;
    this.setPublishNotificationSlotType(actionData, isVerCode ?? false, notificationRequest);
    this.publishNotification(isMms, notificationRequest, smsReceiveIdForDot, async () => {
    });
  }

  private setPublishNotificationSlotType(actionData: LooseObject, isVerCode: boolean,
    notificationRequest: notificationManager.NotificationRequest) {
    /* 首次开机重启重新发送通知 CUSTOMER_SERVICE
       普通消息的通知渠道：
        1.云查 + 广告营销类消息取值为 CONTENT_INFORMATION
        2.首次开机重启重新发送通知 CUSTOMER_SERVICE
        3.个人消息、验证码消息为 SOCIAL_COMMUNICATION
        4.服务类消息取值为 SERVICE_INFORMATION
    */
    if (actionData?.blockedType === Constant.BLOCKED_TYPE_ADVERTISEMENT_MMS &&
      actionData?.blockedReason === Constant.BLOCKED_REASON_CLOUD) {
      // 广告营销类
      notificationRequest.notificationSlotType = notificationManager.SlotType.CONTENT_INFORMATION;
    } else if ((actionData.isFirstUnlocked || actionData.isAfterReSendNotification) &&
    UnLockedNotifyService.getInstance().dataIsMoveEL5) {
      // 首次开机解锁重新发送通知
      notificationRequest.notificationSlotType = notificationManager.SlotType.CUSTOMER_SERVICE;
    } else if (TelephoneUtil.judgeIsInfoMsg(actionData?.telephone ?? '') && !isVerCode) {
      // 非验证码的服务类消息
      notificationRequest.notificationSlotType = notificationManager.SlotType.SERVICE_INFORMATION;
    } else {
      // 个人消息 & 验证码消息
      notificationRequest.notificationSlotType = notificationManager.SlotType.SOCIAL_COMMUNICATION;
    }
  }

  private isFocusMode(): boolean {
    //读取设置查询是否开启免打扰模式
    try {
      let focusMode: string = settings.getValueSync(mContext, 'focus_mode_enable',
        Constant.FOCUS_MODE_ENABLE_SWITCH_CLOSED, settings.domainName.USER_SECURITY);
      if (focusMode === Constant.FOCUS_MODE_ENABLE_SWITCH_OPEN) {
        HiLog.iw(TAG, 'FocusMode is opened.');
        return true;
      }
      return false;
    } catch (exception) {
      HiLog.e(TAG, 'Get focusMode err: ' + JSON.stringify(exception));
      return false;
    }
  }

  /**
   * 如果当前在会话详情页，从首选项中获取当前会话的对端手机号
   * @returns 当前会话的对端手机号
   */
  public async getCurrentThreadMobilePhoneNumber(): Promise<string> {
    let phoneNumber = '';
    let currentThreadId = SharedPreferencesUtils.getFromPreferences('currentThreadId', '');
    const threadId = JSON.stringify(currentThreadId);
    // sp中存储当前详情页为空或为'0',代表当前不在会话详情页。无需查询当前会话的手机号码
    if (StringUtil.isEmpty(threadId) || threadId === common.STR.STRING_ZERO) {
      HiLog.e(TAG, 'getCurrentThreadMobilePhoneNumber threadId is empty');
      return phoneNumber;
    }
    HiLog.i(TAG, `getCurrentThreadMobilePhoneNumber threadId is ${threadId}`);
    phoneNumber =
      await ConversationListService.getInstance().querySessionTelPhoneByThreadId(mContext, Number(threadId));
    return phoneNumber;
  }

  notificationBarLayout(notificationRequest: notificationManager.NotificationRequest, wantAgentDataNotification: Object,
    pixelMap: PixelMap | undefined, titleStr: string, markStr: string, wantAgentDataRead: Object,
    actionData: LooseObject, deliveryTime: number, context: Context) {
    notificationRequest.wantAgent = wantAgentDataNotification;
    notificationRequest.actionButtons = [{
      title: markStr,
      wantAgent: wantAgentDataRead
    }, {
      title: titleStr,
      wantAgent: wantAgentDataNotification
    }];
    if (pixelMap !== undefined) {
      notificationRequest.overlayIcon = pixelMap;
    }
    HiLog.i(TAG, 'screen is unLocked')
  }

  public resetLockScreenNotification(context: Context) {
    HiLog.i(TAG, 'resetLockScreenNotification')

    // 1.获取所有锁屏的通知
    UnLockedNotifyService.getInstance().queryUnLockedNotify((unlockedNotifications: [LooseObject]) =>{
      // 2.重新正常发送通知
      let isAfterReSendNotification: boolean = false;
      for (let unlockedNotification of unlockedNotifications) {
        if (unlockedNotification.isAfterReSendNotification) {
          isAfterReSendNotification = unlockedNotification.isAfterReSendNotification
          this.sendNotify(unlockedNotification, context)
        }
      }
      // 3.删除所有普通未解锁的通知
      if (isAfterReSendNotification) {
        UnLockedNotifyService.getInstance().deleteUnLockedNotify(() => {}, context)
      }
    }, context)
  }


  async sendBlockedNotify(actionData: LooseObject, context: Context, smsReceiveIdForDot?: number) {
    HiLog.i(TAG, 'sendBlockedNotify start');
    let wantAgentDataNotification: LooseObject = {};
    // Creating Want Information
    let wantAgentInfo: wantAgent.WantAgentInfo = this.buildBlockedWantAgentInfo(actionData);
    this.getWantAgent(wantAgentInfo, (data: Object) => {
      wantAgentDataNotification = data
    });
    let resId = $r('app.media.ic_user_portrait').id;
    //下面这行代码去掉会导致骚扰拦截没有通知
    let resIdPixMap = await this.getIconPixelMap(150, 150, context, actionData);
    let slotId: number = MmsPreferences.getInstance().getDefaultSlotId();
    this.pushBlockedNotificationRequest(actionData, slotId, wantAgentDataNotification, smsReceiveIdForDot);
  }

  pushBlockedNotificationRequest(actionData: LooseObject, slotId: number,
    wantAgentDataNotification: Object, smsReceiveIdForDot?: number) {
    HiLog.w(TAG, 'pushBlockedNotificationRequest start');
    let message: Record<string, string> = actionData.message;
    let notificationRequest: notificationManager.NotificationRequest = {
      content: {
        notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_LONG_TEXT,
        longText: {
          title: message.title,
          text: message.text,
          longText: message.text,
          briefText: message.text,
          expandedTitle: message.title,
          additionalText: ''
        },
      },
      extraInfo: {
        testBanner: true,
        systemToneType: slotId
      },
      wantAgent: wantAgentDataNotification,
      notificationSlotType: notificationManager.SlotType.OTHER_TYPES,
      deliveryTime: new Date().getTime(),
      groupName: 'BLOCKED',
      id: actionData.msgId,
      label: label + actionData.msgId,
    };
    this.publishNotification(false, notificationRequest, smsReceiveIdForDot);
  }

  async sendBlockedGuideNotify(actionData: LooseObject, context: Context) {
    HiLog.i(TAG, 'sendBlockedGuideNotify start');
    if (actionData == null) {
      HiLog.e(TAG, 'sendBlockedGuideNotify actionData is null');
      return;
    }
    let wantAgentDataNotification: LooseObject = {};
    // Creating Want Information
    let wantAgentInfo: wantAgent.WantAgentInfo = this.buildBlockedGuideWantAgentInfo(actionData);
    this.getWantAgent(wantAgentInfo, (data: Object) => {
      wantAgentDataNotification = data
    });
    let resId = $r('app.media.ic_user_portrait').id;
    //下面这行代码去掉会导致骚扰拦截没有通知
    let resIdPixMap = await this.dealBlockedGuideIcon(150, 150, context);
    let slotId: number = MmsPreferences.getInstance().getDefaultSlotId();
    this.pushBlockedGuideNotificationRequest(actionData, slotId, resIdPixMap, wantAgentDataNotification);
  }

  pushBlockedGuideNotificationRequest(actionData: LooseObject, slotId: number, resIdPixMap: PixelMap,
    wantAgentDataNotification: Object) {
    HiLog.w(TAG, 'pushBlockedGuideNotificationRequest start');
    let message: Record<string, string> = actionData.message;
    let notificationRequest: notificationManager.NotificationRequest = {
      content: {
        notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_LONG_TEXT,
        longText: {
          title: message.title,
          text: message.text,
          longText: message.text,
          briefText: message.text,
          expandedTitle: message.title,
          additionalText: ''
        },
      },
      extraInfo: {
        testBanner: true,
        systemToneType: slotId
      },
      wantAgent: wantAgentDataNotification,
      notificationSlotType: notificationManager.SlotType.OTHER_TYPES,
      deliveryTime: new Date().getTime(),
      groupName: 'GUIDE_BLOCKED',
      id: actionData.msgId,
      label: label + actionData.msgId,
    };
    notificationRequest.smallIcon = resIdPixMap;
    this.publishNotification(false, notificationRequest);
  }

  private publishNotification(isMms: boolean, notificationRequest: notificationManager.NotificationRequest,
    smsReceiveIdForDot?: number, callback?: Function) {
    if (this.isFocusMode()){
      DotUtil.getInstance().addFailReason(smsReceiveIdForDot || 0,
        dotCommon.smsReceiveRecord.SMS_RECEIVE_REASON_DISTURB_MODE_ON);
    }
    HiLog.w(TAG, `publishNotification param notificationSlotType: ${notificationRequest.notificationSlotType}`);
    notificationManager.publish(notificationRequest).then(() => {
      HiLog.w(TAG, 'publish success');
      if (callback) {
        callback();
      }
      DotUtil.getInstance().addFailReason(smsReceiveIdForDot || 0,
        dotCommon.smsReceiveRecord.SMS_RECEIVE_REASON_PUBLISH_SUCCESS, true);
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'publish error: ' + JSON.stringify(error));
      DotUtil.getInstance().addFailReason(smsReceiveIdForDot || 0,
        dotCommon.smsReceiveRecord.SMS_RECEIVE_REASON_PUBLISH_FAIL + JSON.stringify(error) + '.', true);
      DotUtil.getInstance().reportEvent(dotNoNeedParmas, dotCommon.eventName.RECEIVE_MESSAGE_FAIL_NOTIFY);
    })
    let receiveService = ReceiveService.getInstance();
    // 彩信接收后会自动下载，此时不可释放能效资源，否则会造成下载异常。彩信下载完成后会进行能效资源的释放
    if (!isMms) {
      receiveService.reduceEfficiencyResources();
    }
    receiveService.handleMsgList();
  }

  async getIconPixelMap(width: number, height: number, context: Context, actionData: LooseObject): Promise<PixelMap> {
    HiLog.w(TAG, 'getIconPixelMap success');
    let resId = $r('app.media.ic_user_portrait').id;
    let defaultSize: image.Size = {
      'height': height,
      'width': width
    };
    let opts: image.DecodingOptions = {
      'index': 0,
      'sampleSize': 1,
      'rotate': 0,
      'editable': false,
      'desiredSize': defaultSize,
      'desiredRegion': {
        'size': defaultSize,
        'x': 0,
        'y': 0
      },
    };
    let mgr: resourceManager.ResourceManager = context.resourceManager;
    let isNoticeType: boolean = (actionData.smsType === common.sms_type.NOTICE);
    let nameString:string = isNoticeType ? 'icon/user_portrait_bell.svg' : 'icon/ic_user_portrait_new.svg';
    HiLog.i(TAG, 'getIconPixelMap mgr:' + mgr);
    return new Promise<PixelMap>((resolve) => {
      mgr.getMediaContent(resId).then((value) => {
        HiLog.i(TAG, 'getIconPixelMap createPixelMap');
        let imageSource = image.createImageSource(value.buffer);
        HiLog.i(TAG, 'getIconPixelMap imageSource');
        imageSource.createPixelMap(opts).then((imagePixelMap) => {
          imageSource.release();
          resolve(imagePixelMap);
        }).catch((err: BusinessError) => {
          HiLog.e(TAG, `getIconPixelMap error: code: ${err.code}, message: ${err.message}`);
          let resourceMgr: resourceManager.ResourceManager = context.resourceManager;
          resourceMgr.getRawFd(nameString).then(fileDate => {
            let imageSource = image.createImageSource(fileDate);
            imageSource.createPixelMap(opts).then((catchPixelMap) => {
              imageSource.release();
              resolve(catchPixelMap);
            })
          })
        })
      }).catch((err: BusinessError) => {
        HiLog.e(TAG, `getMediaContent error: code: ${err.code}, message: ${err.message}`);
        let resourceMgr: resourceManager.ResourceManager = context.resourceManager;
        resourceMgr.getRawFd(nameString).then(fileDate => {
          let imageSource = image.createImageSource(fileDate);
          imageSource.createPixelMap(opts).then((catchPixelMap) => {
            imageSource.release();
            resolve(catchPixelMap);
          })
        })
      })
    })
  }

  public async clickRead(data: DataParameters) {
    HiLog.w(TAG, '[clickRead in notice]');
    const parameters: BaseDataParameters = data.parameters;
    let id: number = parameters.id;
    let telephone: string = parameters.telephone;
    let type: string = parameters.type;
    let actionData: LooseObject = {};
    actionData.threadIds = id;
    actionData.hasRead = common.is_read.UN_READ;
    actionData.telephone = telephone;
    actionData.type = type;
    actionData.isAfterNoReadButton = parameters.isAfterNoReadButton
    actionData.startTime = parameters.deliveryTime
    actionData.msgContent = parameters.msgContent
    HiLog.i(TAG, 'clickRead actionData.type:' + JSON.stringify(actionData.type))
    if (actionData.type === commonData.RCS_TYPE.RCS) {
      actionData.msgType = 'rcs_info';
      this.markAsReadFromReceiveRcs(actionData);
    } else {
      actionData.msgType = 'sms_mms_info';
      this.markAsReadFromReceive(actionData);
    }
  }

  /**
   *  copy ver code action
   * @param data: notification data
   */
  public async copyVerCode(data: DataParameters) {
    if (data && data.parameters && data.parameters.code) {
      HiLog.i(TAG, 'copy ver code success');
      this.clickRead(data)
      let copyText = `${data.parameters.code}`;
      commonPasteboard.setPasteboard(copyText);
      promptAction.showToast({
        message: mContext.resourceManager.getStringSync($r('app.string.copied_to_clipboard')),
        duration: 2000
      });
    } else {
      HiLog.i(TAG, 'copy ver code fail ');
      promptAction.showToast({
        message: mContext.resourceManager.getStringSync($r('app.string.copy_failed')),
        duration: 2000
      });
    }
  }

  public markAsReadFromReceive(actionData: LooseObject) {
    ConversationListService.getInstance().markAsReadFromReceive(actionData, (unReadCount: number) => {
      ConversationListService.getInstance().statisticalData((result: Response) => {
        if (result.code == common.int.SUCCESS) {
          // Total number of lists
          let unreadTotal = result.response.totalListCount;
          HiLog.i(TAG, 'markAsReadFromReceive, unreadTotal change to: ' + unreadTotal);
          let updateData: LooseObject = {};
          updateData.unReadCount = unreadTotal;
          updateData.telephone = actionData.telephone;
          updateData.threadIds = actionData.threadIds;
          try {
            commonEvent.publish(common.STR.RECEIVE_UPDATE_EVENT, {
              bundleName: common.STR.BUNDLE_NAME,
              subscriberPermissions: ['ohos.permission.RECEIVE_SMS'],
              isOrdered: false,
              data: JSON.stringify(updateData),
              parameters: updateData
            }, (res) => {});
          } catch (err) {
            HiLog.i(TAG, `Failed to publish common event. Code is ${err.code}, message is ${err.message}`);
          }
        } else {
          HiLog.w(TAG, 'statisticalData, failed');
        }
      }, mContext);
    }, mContext);
  }

  public markAsReadFromReceiveRcs(actionData: LooseObject) {
    ConversationRcsService.getInstance().markAsReadFromReceiveRcs(actionData, (unReadCount: number) => {
      ConversationListService.getInstance().statisticalData((result: Response) => {
        if (result.code == common.int.SUCCESS) {
          // Total number of lists
          let unreadTotal = result.response.totalListCount;
          HiLog.i(TAG, 'markAsReadFromReceiveRcs, unreadTotal change to: ' + unreadTotal);
          let updateData: LooseObject = {};
          updateData.unReadCount = unreadTotal;
          updateData.telephone = actionData.telephone;
          updateData.threadIds = actionData.threadIds;
          try {
            commonEvent.publish(common.STR.RECEIVE_UPDATE_EVENT, {
              bundleName: common.STR.BUNDLE_NAME,
              subscriberPermissions: ['ohos.permission.RECEIVE_SMS'],
              isOrdered: false,
              data: JSON.stringify(updateData),
              parameters: updateData
            }, (res) => {
            });
          } catch (err) {
            HiLog.i(TAG, `Failed to publish common event. Code is ${err.code}, message is ${err.message}`);
          }
        } else {
          HiLog.w(TAG, 'statisticalData, failed');
        }
      }, mContext);
    }, mContext);
    this.rcsSendReadReceipt(actionData);
  }

  private rcsSendReadReceipt(actionData: LooseObject) {
    if (actionData == null) {
      HiLog.e(TAG, 'rcsSendReadReceipt actionData is null');
      return;
    }
    try {
      // rcs.sendReadReceipt(actionData.telephone, () => {
      // });
    } catch (exception) {
      HiLog.e(TAG, 'oobeNeedSendNotice, no have rcs exception: ' + JSON.stringify(exception));
    }
  }

  buildWantAgentInfoRead(actionData: LooseObject): wantAgent.WantAgentInfo {
    HiLog.i(TAG, 'buildWantAgentInfoRead: ' + actionData);
    let data: LooseObject = {}
    data.action = 'notification.event.readdata';
    data.id = actionData.msgId;
    data.unreadTotal = actionData.unreadTotal;
    data.senderNumber = actionData.senderNumber;
    data.telephone = actionData.telephone;
    data.type = actionData.type;
    if (actionData.isAfterReSendNotification) {
      data.startTime = actionData.startTime;
      data.msgContent = actionData.message.text;
    }
    let wantAgentInfo: wantAgent.WantAgentInfo = {
      wants: [{
        action: 'usual.event.SMS_RECEIVE_COMPLETED',
        parameters: data,
        deviceId: '',
        bundleName: common.STR.BUNDLE_NAME,
        abilityName: common.STR.ABILITY_NAME
      }],
      actionType: WantAgent.OperationType.SEND_COMMON_EVENT,
      requestCode: actionData.msgId,
    };
    return wantAgentInfo;
  }

  /**
   * 创建 通知的 复制验证码 want
   * @param actionData
   * @returns
   */
  buildWantAgentInfoCopy(actionData: LooseObject): wantAgent.WantAgentInfo {
    let data: LooseObject = {}
    data.action = common.STR.SUBSCRIBER_EVENT_COPYVERCODE;
    data.id = actionData.msgId;
    data.unreadTotal = actionData.unreadTotal;
    data.senderNumber = actionData.senderNumber;
    data.telephone = actionData.telephone;
    data.type = actionData.type;
    data.code = actionData.verCode;
    let wantAgentInfo: wantAgent.WantAgentInfo = {
      wants: [{
        action: common.STR.SUBSCRIBER_EVENT,
        parameters: data,
      }],
      actionType: WantAgent.OperationType.SEND_COMMON_EVENT,
      requestCode: actionData.msgId,
      wantAgentFlags: [wantAgent.WantAgentFlags.CONSTANT_FLAG],
    };
    return wantAgentInfo;
  }

  buildWantAgentInfoReplay(actionData: LooseObject): MmswantAgentInfo {
    HiLog.i(TAG, 'buildWantAgentInfoRead: ' + actionData);
    let parameters: MmsReplayParameters = {
      pageFlag: 'conversation',
      contactObjects: actionData.contactObjects,
      notificationType: 0,
      yellowPageId: ''
    };
    let wantAgentInfo: MmswantAgentInfo = {
      wants: [
        {
          deviceId: '',
          bundleName: common.STR.BUNDLE_NAME,
          abilityName: common.STR.ABILITY_NAME,
          action: 'notification.event.message',
          entities: [],
          type: 'MIMETYPE',
          uri: '',
        }
      ],
      operationType: WantAgent.OperationType.START_ABILITY,
      requestCode: actionData.msgId,
      wantAgentFlags: [WantAgent.WantAgentFlags.CONSTANT_FLAG],
      extraInfo: parameters
    };
    return wantAgentInfo;
  }

  /**
   * Create a wanted message to be sent.
   *
   * @param agentInfo
   * @callback callback
   */
  getWantAgent(agentInfo: wantAgent.WantAgentInfo, callback: Function) {
    WantAgent.getWantAgent(agentInfo).then(data1 => {
      HiLog.i(TAG, 'getWantAgent, success');
      callback(data1);
    }).catch((err: BusinessError) => {
      HiLog.e(TAG, 'getWantAgent, error: ' + JSON.stringify(err.message));
    });
  }

  /**
   * Constructing distributed startup parameters
   *
   * @param actionData
   */
  buildWantAgentInfo(actionData: LooseObject): wantAgent.WantAgentInfo {
    let parameters: MmsReplayParameters = {
      pageFlag: 'conversation',
      contactObjects: actionData.contactObjects,
      notificationType: actionData.notificationType,
      yellowPageId: actionData.yellowPageId
    };
    let wantAgentInfo: wantAgent.WantAgentInfo = {
      wants: [
        {
          deviceId: '',
          bundleName: common.STR.BUNDLE_NAME,
          abilityName: common.STR.ABILITY_NAME,
          action: 'mms.event.notification',
          entities: [],
          type: 'MIMETYPE',
          uri: '',
        }
      ],
      actionType: WantAgent.OperationType.START_ABILITY,
      requestCode: actionData.msgId,
      wantAgentFlags: [WantAgent.WantAgentFlags.CONSTANT_FLAG],
      extraInfo: parameters
    };
    return wantAgentInfo;
  }

  /**
   * buildBlockedWantAgentInfo
   *
   * @param actionData
   */
  buildBlockedWantAgentInfo(actionData: LooseObject): wantAgent.WantAgentInfo {
    let parameters: MmsReplayParameters = {
      pageFlag: 'blockedList',
      contactObjects: actionData.contactObjects,
      notificationType: 0,
      yellowPageId: ''
    };
    let wantAgentInfo: wantAgent.WantAgentInfo = {
      wants: [
        {
          deviceId: '',
          bundleName: common.STR.BUNDLE_NAME,
          abilityName: common.STR.ABILITY_NAME,
          action: 'mms.event.notification',
          entities: [],
          type: 'MIMETYPE',
          uri: '',
        }
      ],
      actionType: WantAgent.OperationType.START_ABILITY,
      requestCode: actionData.msgId,
      wantAgentFlags: [WantAgent.WantAgentFlags.CONSTANT_FLAG],
      extraInfo: parameters
    };
    return wantAgentInfo;
  }

  /**
   * buildBlockedGuideWantAgentInfo
   *
   * @param actionData
   */
  buildBlockedGuideWantAgentInfo(actionData: LooseObject): wantAgent.WantAgentInfo {
    let parameters: MmsBlockedGuideParameters = {
      pageFlag: 'blockedGuidePage',
      slotId: actionData.slotId
    };
    HiLog.i(TAG, 'buildBlockedGuideWantAgentInfo slotId : ' + actionData.slotId);
    let wantAgentInfo: wantAgent.WantAgentInfo = {
      wants: [
        {
          deviceId: '',
          bundleName: common.STR.BUNDLE_NAME,
          abilityName: common.STR.ABILITY_NAME,
          action: 'mms.event.notification',
          entities: [],
          type: 'MIMETYPE',
          uri: '',
        }
      ],
      actionType: WantAgent.OperationType.START_ABILITY,
      requestCode: actionData.msgId,
      wantAgentFlags: [WantAgent.WantAgentFlags.CONSTANT_FLAG],
      extraInfo: parameters
    };
    return wantAgentInfo;
  }

  /**
   * Building notification parameters
   *
   * @param actionData
   */
  buildNotificationRequest(actionData: LooseObject): notificationManager.NotificationRequest {
    HiLog.w(TAG, 'buildNotificationRequest');
    let message: Record<string, string> = actionData.message;
    let notificationRequest: notificationManager.NotificationRequest = {
      content: {
        notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
        normal: {
          title: message.title,
          text: message.text
        },
      },
      wantAgent: undefined,
      notificationSlotType: notificationManager.SlotType.SOCIAL_COMMUNICATION,
      deliveryTime: new Date().getTime(),
      groupName: 'MMS'
    };
    return notificationRequest;
  }

  public async cancelMessageNotify(context: Context, actionData: LooseObject, callback: Function): Promise<void> {
    this.total = await ConversationService.getInstance().getSmsMmsInfoSizeByCondition(actionData, context);
    HiLog.w(TAG, '[cancelMessageNotify] session unread total: ' + this.total);
    if (this.total > common.int.SMSMMSINFO_PAGE_THRESHOLD) {
      actionData.page = this.page;
    }
    ConversationService.getInstance().querySmsMmsInfoByCondition(context, actionData, (res: resType) => {
      if (res.code == common.int.FAILURE || res.abilityResult.length == 0) {
        if (callback != null) {
          callback(common.int.FAILURE);
        }
        HiLog.w(TAG, 'cancelMessageNotify: query sms_mms_info fail, return!');
        return;
      }
      this.cancelNotifies(res.abilityResult);
      this.sum += res.abilityResult.length;
      HiLog.i(TAG, 'cancelMessageNotify, cancel list length: ' + res.abilityResult.length + ', this.sum: ' +
      this.sum + ', this.total: ' + this.total + ', this.page: ' + this.page);
      if (this.sum < this.total) {
        this.page++;
        setTimeout(() => {
          this.cancelMessageNotify(context, actionData, callback);
        }, 200);
      } else {
        this.page = 1;
        this.total = 0;
        this.sum = 0;
        if (callback) {
          callback(common.int.SUCCESS);
        }
      }
    });
  }

  public cancelNotifies(messageList: Array<LooseObject>, callback?: Function): void {
    let count = 0;
    HiLog.i(TAG, 'cancelNotifies start ');
    for (let item of messageList) {
      this.cancelNotify(Number(item.msgId), () => {
        count++;
        if (count == messageList.length && callback != null) {
          callback(common.int.SUCCESS);
        }
      });
    }
  }

  cancelNotify(msgId: number, callback: Function) {
    HiLog.i(TAG, 'cancelNotify start');
    Notification.cancel(msgId, label + msgId, (err, data) => {
      if (err) {
        callback(common.int.FAILURE);
        return;
      }
      callback(common.int.SUCCESS);
    });
  }

  cancelAllNotify() {
    HiLog.i(TAG, 'cancelAllNotify, start: ');
    let promise = Notification.cancelGroup('MMS');
    promise.then((ret) => {
    }).catch((err: BusinessError) => {
      HiLog.e(TAG, 'cancelAllNotify, error: ' + JSON.stringify(err.message));
    });
  }

  public setBadgeNumber(unreadTotal: number): void {
    HiLog.w(TAG, 'setBadgeNumber, unreadTotal: ' + unreadTotal);
    globalNotificationManager.setBadgeNumber(unreadTotal);
  }

  public setBadgeNumberWithContext(contextInfo: ISetBadgeContextInfo): void {
    HiLog.w(TAG, '[before]\t[%{public}s]->[%{public}s]\tsetBadgeNumber:[%{public}d]',
      contextInfo.updateBadgeEventCode,
      contextInfo.tracedId, contextInfo.unreadTotal)
    let cancelTimeoutId = setTimeout(() => {
      DotUtil.getInstance().reportStatisticEvent({
        BADGE_EVENT_CODE: contextInfo.updateBadgeEventCode,
        BADGE_NUMER: contextInfo.unreadTotal,
        BADGE_RESULT: 'failure',
        BADGE_RESULT_INFO: 'callBackTimeOut'
      } as ConsumerBehaviorParams, DotEvent.eventName.SET_BADGE_EVENT)
    }, 2000)
    try {
      globalNotificationManager.setBadgeNumber(contextInfo.unreadTotal, () => {
        clearTimeout(cancelTimeoutId)
        DotUtil.getInstance().reportStatisticEvent({
          BADGE_EVENT_CODE: contextInfo.updateBadgeEventCode,
          BADGE_NUMER: contextInfo.unreadTotal,
          BADGE_RESULT: 'success',
          BADGE_RESULT_INFO: 'success'
        } as ConsumerBehaviorParams, DotEvent.eventName.SET_BADGE_EVENT)
        HiLog.w(TAG, '[after ]\t[%{public}s]->[%{public}s]\tsetBadgeNumber', contextInfo.updateBadgeEventCode,
          contextInfo.tracedId)
      });
    } catch (error) {
      clearTimeout(cancelTimeoutId)
      DotUtil.getInstance().reportStatisticEvent({
        BADGE_EVENT_CODE: contextInfo.updateBadgeEventCode,
        BADGE_NUMER: contextInfo.unreadTotal,
        BADGE_RESULT: 'failure',
        BADGE_RESULT_INFO: 'setBadgeNumberError:' + JSON.stringify(error)
      } as ConsumerBehaviorParams, DotEvent.eventName.SET_BADGE_EVENT)
      HiLog.w(TAG, 'setBadgeNumber error! error detail info : %{public}', JSON.stringify(error));
    }
  }

  public updateBadgeNumberWithContext(contextInfo: IBadgeContextInfo): void {
    HiLog.w(TAG, 'updateBadge Number');
    ConversationListService.getInstance().statisticalData((res: resType) => {
      if (res.code == common.int.SUCCESS) {
        let badgeContext: ISetBadgeContextInfo = {
          unreadTotal:Number((res.response as LooseObject).totalListCount),
          appContext:contextInfo.appContext,
          updateBadgeEventCode:contextInfo.updateBadgeEventCode,
          tracedId: contextInfo.tracedId,
        }
        this.setBadgeNumberWithContext(badgeContext);
      }
    }, contextInfo.appContext);
  }

  public updateBadgeNumber(context: Context): void {
    HiLog.w(TAG, 'updateBadge Number');
    ConversationListService.getInstance().statisticalData((res: resType) => {}, context);
  }
};