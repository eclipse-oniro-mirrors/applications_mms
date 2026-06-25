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
import { notificationManager } from '@kit.NotificationKit';

export interface ConsumerBehaviorParams {
  PNAMEID?: string,
  PVERSIONID?: string,
  OTHER_PNAMEID?: string,
  SEND_STATE?: number,
  NUMBER_STATUS?: number,
  CARD_SELECT_STATUS?: number,
  STATE?: number | string,
  INPUT_STATE?: number,
  SELECT_STATE?: number,
  SMS_TYPE?: number,
  MSG_TYPE?: number,
  AVATAR_NUMBER?: number,
  CLICK_PAGE?: string,
  PAGE_STATE?: number,
  DIALOG_STATE?: number,
  CHECKBOX_STATE?: number,
  PRIVILEGE_STATUS?: number,
  OPTION?:number,
  CONFIRM?:number,
  TIME_STATUS?: number,
  TYPE_STATUS?: number,
  MMS_NUM?: number,
  IS_LOCATION?: number,
  SENDING_REQUIRED_TIME?: number | string,
  TYPE?: number,
  FAILURE_CAUSE?: number,
  LOCATION_AGREE?: number,
  IS_VER_CODE?: number,
  RCS_SWITCH?: number,
  DELIVERY_REPORT?: number,
  AUTO_DELETE?: number,
  AUTO_MMS_DOWNLOAD?: number,
  SMART_SWITCH?: number,
  AGGREGATE_STATE?: number,
  SHOW_HEAD_ICON?: number,
  MALICIOUS_CHECK?: number,
  PHONENUMBER?: string,
  PHONENUMBER_TYPE?: number,
  PHONENUMBER_LENGTH?: number,
  SLOTID?: number,
  SIM_TYPE?: number,
  SIM_INDEX?: number,
  BLOCKED_FLAG?: number,
  IS_BLOCKED?: number,
  BLOCKED_REASON?: number,
  BLOCKED_TYPE?: number,
  FAIL_REASON?: string,
  BADGE_NUMER?: number,
  BADGE_EVENT_CODE?: string,
  BADGE_RESULT?: string,//{'failure','success'}
  BADGE_RESULT_INFO?: string,
  SLID_DIRECTION?: number,
  SMS_STATUS?: number,
  WORD_SIZE?: number,
  READ_STATE?: number,
  PIN_STATE?: number,
  PHONE_NUMBER?: string, // 电话号码
  MCCMNC?: string, // 运营商
  /**
   * 消息类型 1:文本, 2:图片, 3:视频, 4:VCard, 5:录音，6:幻灯片彩信only, 7:位置, 8:主题(文字+图片、彩信only), 9:音乐文件, 10:文件,
   * 11:rcs应用号卡片, 12:rcs应用号卡片的视频富媒体缩略图文件
   */
  MSG_CONTENT?: number,
  SEND_RESULT?: number, // 发送结果 1成功 -1失败 2 正在发送 0业务上流程中断
  RETRY_TIME?: number, // 重试次数（彩信only）
  MSGID?: string, // 信息id
  PDU_LENGTH?: number,
  EXPIRATION_TIME?: string,
  MMS_SIZE?: number,
  INFO_PAGE_STATE?: number,
  JUMP_RESULT?: number,// 跳转结果 1成功 0失败
  MODE_NAME?: string,// 是否是 penglai 模式
  INVALID_COUNT_LIST?: number[], // 无效数据数量
}

export class SmsReceiveParams {
  public phoneNumber?: string = '';
  public phoneNumberType?: number = -1;
  public slotId?: number = -1;
  public msgType?: number = -1;
  public isVerMsg?: number = -1;
  public blockedFlag?: number = -1;
  public isBlocked?: number = -1;
  public blockedReason?: number = -2;
  public blockedType?: number = -1;
  public failReason?: string = '';
  public mccmnc?: string = '';
  public msgId?: string = '';
  public pduLength?: number = -1;
  public expirationTime?: string = '';
  public mmsSize?: number = -1;
}

export class SmsSwitchStatusParams implements ConsumerBehaviorParams {
  /**
   * 应用包名
   */
  public PNAMEID: string = '';
  /**
   * 应用版本
   */
  public PVERSIONID: string = '';
  /**
   * 允许通知
   */
  public IS_ENABLE_NOTIFICATION?: number = -1;
  /**
   * 通知渠道
   */
  public NOTIFICATION_CHANNELS?: string[]  = [];
  /**
   * 免打扰
   */
  public IS_FOCUS_MODE?: number = -1;
  /**
   * 通知信息整合
   */
  public IS_INTEGRATION?: number = -1;
  /**
   * 显示联系人头像
   */
  public SHOW_CONTANT_SWITCH?: number = -1;
  /**
   * 陌生号码和信息识别
   */
  public IS_IDENTITY?: number = -1;
  /**
   * 智能信息
   */
  public IS_OPEN_SMART?: number = -1;
  /**
   * 北斗开关
   */
  public SUMMER_STATUS?: number = -1;
  /**
   * 增强信息
   */
  public IS_RCS_STATE?: number = -1;
  /**
   * 送达报告
   */
  public DELIVERY_REPORT_SWITCH?: number = -1;
  /**
   * 自动下载彩信
   */
  public AUTO_RETRIEVE_MMS_SWITCH?: number = -1;
  /**
   * 自动删除通知信息
   */
  public AUTO_DELETE_INFO_SWITCH?: number = -1;
  /**
   * 信息语音播报
   */
  public SPEECH_BROADCAST_SWITCH?: number = -1;
  /**
   * 通知未读数量
   */
  public UNREAD_INFO?: number = 0;
  /**
   * 首页未读数量
   */
  public UNREAD_HOME?: number = 0;
  /**
   * 骚扰拦截数量
   */
  public UNREAD_BLOCK?: number = 0;
  /**
   * 卡1短信中心
   */
  public CARD_CENTER_NO1?: string = '';
  /**
   * 卡2短信中心
   */
  public CARD_CENTER_NO2?: string = '';
}

export class NotificationSlotParams {
  public notificationType?: notificationManager.SlotType;
  public enabled?: boolean;
}

export class NotificationMuteParams {
  public PVERSIONID: string = '';
  public PNAMEID: string = '';
  public CARD_SELECT_STATUS: number = 0;
}

/**
* 短信收发成功率点位参数
  */
  export class MsgReceiveSendSuccessRateParams {
  public PNAMEID: string = '';
  public PVERSIONID: string = '';
  public TYPE: number = 0;
  public BEHAVIOR: number = 0;
  public STATE: number = 0;
}

/**
 * 彩信附件下载展示点位参数-ATTACHMENT_CONTENT
 */
export class AttachmentContent {
  public contentId: string = '';
  public fileName: string = '';
}

/**
 * 彩信附件下载展示点位参数
 */
export class ReceiveMessageDownloadParams {
  /**
   * 应用包名
   */
  public PNAMEID: string = '';
  /**
   * 应用版本
   */
  public PVERSIONID: string = '';
  /**
   *  发送端手机号码，掩码处理
   */
  public PHONE_NUMBER: string = '';
  /**
   * 本机运营商编码
   */
  public MCCMNC: string = '';
  /**
   * 彩信下载过期时间
   */
  public EXPIRATION_TIME: string = '';
  /**
   * 彩信附件大小-单位kb
   */
  public MMS_SIZE: number = 0;
  /**
   * 自动下载开关状态(0: 不自动下载, 1: 非漫游下载; 2: 所有网络下载; -1: 未设置)
   */
  public AUTO_DOWNLOAD_SWITCH: number = 0;
  /**
   * 是否下载成功(0: 未下载, 1: 下载失败, 2: 下载成功)
   */
  public DOWNLOAD_STATE: number = 0;
  /**
   * 重试次数
   */
  public RETRY_TIME: number = 0;
  /**
   * 1:文本 , 2: 图片, 3:视频 , 4: VCard，5：录音，6：幻灯片彩信only 7：位置；8：主题（文字+图片、彩信only）；9：音乐（彩信only）
   */
  public CONTENT_TYPE: string = '';
  /**
   * 彩信的模板，配置布局文件
   */
  public SMIL_CONTENT: string = '';
  /**
   * contentid、filename
   */
  public ATTACHMENT_CONTENT: string = '';
  /**
   * 下载失败的详细原因
   */
  public DOWNLOAD_DETAIL_ERROR: string = '';
  /**
   * 信息ID
   */
  public MSGID: string = '';
}

/**
 * 短信通知开关使能提醒点位参数
 */
export class RemindEnableNotificationParams implements ConsumerBehaviorParams {
  /**
   * 应用包名
   */
  public PNAMEID: string = '';
  /**
   * 应用版本
   */
  public PVERSIONID: string = '';
  /**
   * 累计提醒次数
   */
  public TIMES: number = 0;
  /**
   * 行为（1-允许；2-不允许）
   */
  public BEHAVIOR: number = 0;
  /**
   * 应用通知总开关状态(-1-未查询。0-关闭，1-打开)
   */
  public SWITCH_STATUS: number = -1;
  /**
   * 应用通知渠道开关状态(-1-未查询{渠道类型：开关状态}。开关状态：0-关闭，1-打开)
   */
  public SLOT_STATUS: string = '-1';
  /**
   * 最近一次的提醒时间(时间戳)
   */
  public LAST_REMIND_TIME: string = '';
  /**
   * 操作失败原因
   */
  public DETAIL_ERROR: string = '';
}

/**
 * 短信通知开关使能提醒点位参数--SLOT_STATUS
 */
export class NotificationSlotStatus {
  /**
   * 通知渠道类型
   */
  public slotType: number = 0;
  /**
   * 通知渠道开关状态(-1-未查询。0-关闭，1-打开)
   */
  public switchStatus: number = -1;
}

/*
 * 豁免特殊特殊情况下,CPU High的场景，通过打点进行豁免
 * */
export class CPUAndMEMParams {
  public PACKAGE_NAME: string = 'com.ohos.telephonydataability';
  public SCENE_ID: string = 'MMS_CPU_HIGH_AFTER_UPDATE_CONTACTS';
  public HAPPEN_TIME: number = 0;

  constructor() {
    this.HAPPEN_TIME = new Date().getTime()
  }
}

export let dotNoNeedParmas: ConsumerBehaviorParams = {};

export let otherEntranceParmas: ConsumerBehaviorParams = {
  OTHER_PNAMEID: ''
};
export let onlyStateParam: ConsumerBehaviorParams = {
  STATE: 0
}
export let notifyStateParam: ConsumerBehaviorParams = {
  STATE: 0
}
export let smsVerificationResult: ConsumerBehaviorParams = {
  SMS_TYPE: 0,
  STATE: 0,
}
export let dotSendParmas: ConsumerBehaviorParams = {
  SEND_STATE: 0,
  NUMBER_STATUS: 0,
  CARD_SELECT_STATUS: 0
};
export let newPageListParams: ConsumerBehaviorParams = {
  STATE: 0,
  NUMBER_STATUS: 0
};
export let writeEventParams: ConsumerBehaviorParams = {
  INPUT_STATE: 0
};
export let stateParam: ConsumerBehaviorParams = {
  STATE: 0,
  PAGE_STATE: 0,
  DIALOG_STATE: 0,
  CHECKBOX_STATE: 0,
  READ_STATE: 0,
  PIN_STATE: 0
};
export let seleteParam: ConsumerBehaviorParams = {
  SELECT_STATE: 0,
  MODE_NAME: '',
};
export let seleteFailParam: ConsumerBehaviorParams = {
  MODE_NAME: '',
};
export let selectStateParams: ConsumerBehaviorParams = {
  SELECT_STATE: 0,
  STATE: 0
};
export let receiveParams: ConsumerBehaviorParams = {
  CARD_SELECT_STATUS: 0,
  MSG_TYPE: 0
};
export let receiveIsVercode: ConsumerBehaviorParams = {
  IS_VER_CODE: 0
};
export let clickAvatarParams: ConsumerBehaviorParams = {
  AVATAR_NUMBER: 0,
  CLICK_PAGE: ''
}
export let contentMoreParams: ConsumerBehaviorParams = {
  AVATAR_NUMBER: 0,
  SELECT_STATE: 0
}
export let longPressDeParams: ConsumerBehaviorParams = {
  STATE: 0,
  PAGE_STATE: 0
}
export let blockedParams: ConsumerBehaviorParams = {
  OPTION:0,
  CONFIRM:0
}
export let timeStatusParams: ConsumerBehaviorParams = {
  TIME_STATUS: 0
}
export let mmsTypeParams: ConsumerBehaviorParams = {
  TYPE_STATUS: 0,
  SMS_STATUS: 0,
  MODE_NAME: ''
}
export let sendMmsParams: ConsumerBehaviorParams = {
  CARD_SELECT_STATUS: 0,
  MMS_NUM: 0,
  TYPE_STATUS: 0,
  SEND_STATE: 0,
  MODE_NAME: ''
}
export let sendRcsParams: ConsumerBehaviorParams = {
  CARD_SELECT_STATUS: 0,
  SEND_STATE: 0
}
export let settingSmartStatus: ConsumerBehaviorParams = {
  SMART_SWITCH: 0
}
export let settingRcsStatus: ConsumerBehaviorParams = {
  RCS_SWITCH: 0
}
export let settingAggregateStatus: ConsumerBehaviorParams = {
  AGGREGATE_STATE: 0
}
export let maliciousCheckStatus: ConsumerBehaviorParams = {
  MALICIOUS_CHECK: 0
}
export let settingShowHeadStatus: ConsumerBehaviorParams = {
  SHOW_HEAD_ICON: 0
}
export let settingReportStatus: ConsumerBehaviorParams = {
  DELIVERY_REPORT: 0
}
export let settingAutoDelStatus: ConsumerBehaviorParams = {
  AUTO_DELETE: 0
}
export let settingDownStatus: ConsumerBehaviorParams = {
  AUTO_MMS_DOWNLOAD: 0
}
export let sendRcsRecordParams: ConsumerBehaviorParams = {
  TIME_STATUS: 0,
  SLID_DIRECTION: 0
}
export let editWordSizeParams: ConsumerBehaviorParams = {
  WORD_SIZE: 0
}
export let rcsSendMsgParams: ConsumerBehaviorParams = {
  MSG_TYPE: 0,
}

// 短彩信、rcs发送流程打点参数
export let sendMessageCommonParams: ConsumerBehaviorParams = {
  PHONE_NUMBER: '', // 电话号码
  MCCMNC: '', // 运营商
  SLOTID: 0, // sim卡id(0: sim卡1, 1: sim卡2)
  MSG_TYPE: 0, // 消息类型(0: 短信 1: RCS 2:彩信)
  /**
   * 1:文本, 2:图片, 3:视频, 4:VCard, 5:录音，6:幻灯片彩信only, 7:位置, 8:主题(文字+图片、彩信only), 9:音乐文件, 10:文件,
   * 11:rcs应用号卡片, 12:rcs应用号卡片的视频富媒体缩略图文件
   */
  MSG_CONTENT: 0,
  SEND_RESULT: 0, // 发送结果 1成功 -1失败 2 正在发送 0业务上流程中断
  RETRY_TIME: 0, // 重试次数（彩信only）
  FAIL_REASON: '', // 失败原因
  MSGID: '', // 信息id
};

export let searchFailReasonParmas: ConsumerBehaviorParams = {
  FAIL_REASON: ''
};

export let invalidDataParmas: ConsumerBehaviorParams = {
  INVALID_COUNT_LIST: []
};

/**
 * 信息是否是服务号信息打点参数
 */
export class MsgServiceNumberParams {
  public PNAMEID: string = '';
  public PVERSIONID: string = '';
  public PORNUM: string = '';
  public FROM: number = 0;
  public IS_HAS_SERVICE_LOGO: boolean = false;
  public IS_HAS_SERVICE_NAME: boolean = false;
}

class RecordKeyName {
  // Fail Reason for sms receive.
  public readonly SMS_RECEIVE_REASON_VERCODE_TIMEOUT: string = 'Verification code judgment timed out.';
  public readonly SMS_RECEIVE_REASON_BLOCK_CONNECT_FAIL: string = 'DetectSpam connect fail.';
  public readonly SMS_RECEIVE_REASON_BLOCK_ERROR_CODE: string = 'DetectSpam error code is:';
  public readonly SMS_RECEIVE_REASON_BLOCK_RESULT_IS_NULL: string = 'DetectSpam result is null.';
  public readonly SMS_RECEIVE_REASON_BLOCK_ABNORMAL_DISCONNECT: string = 'DetectSpam abnormal disconnect.';
  public readonly SMS_RECEIVE_REASON_BLOCK_IPC_FAIL: string = 'DetectSpam ipc fail code:';
  public readonly SMS_RECEIVE_REASON_BLOCK_CATCH: string = 'DetectSpam catch error code:';
  public readonly SMS_RECEIVE_REASON_BLOCK_NOT_NOTIFY: string = 'Spam message without notice.';
  public readonly SMS_RECEIVE_REASON_BLOCK_ON_SHOW: string = 'Spam message on show, no notice.';
  public readonly SMS_RECEIVE_REASON_INSERT_SESSION_FAIL: string = 'Insert session fail.';
  public readonly SMS_RECEIVE_REASON_SMART_NOTIFICATION_FAIL: string = 'Get smart notification fail.';
  public readonly SMS_RECEIVE_REASON_OOBE_NOT_NOTIFY: string = 'Oobe page without notification.';
  public readonly SMS_RECEIVE_REASON_DEFAULT_NOT_NOTIFY: string = 'Default without notification.';
  public readonly SMS_RECEIVE_REASON_PUBLISH_FAIL: string = 'Publish error code:';
  public readonly SMS_RECEIVE_REASON_PUBLISH_SUCCESS: string = 'Publish success';
  public readonly SMS_RECEIVE_REASON_NOTIFICATION_MAINTENANCE_MODE: string = 'In maintenance mode.';
  public readonly SMS_RECEIVE_REASON_SEND_BLOCKGUIDE: string = 'Send a block guide.';
  public readonly SMS_RECEIVE_REASON_SMART_NOTIFICATION_TIMEOUT: string = 'Smart sms interface timeout.';
  // 接收短彩信时用户开启了勿扰模式
  public readonly SMS_RECEIVE_REASON_DISTURB_MODE_ON: string = 'The disturbMode is on.';
  // 接收短信时Content 为空
  public readonly SMS_RECEIVE_REASON_NULL_CONTENT: string = 'Receive mms is null.';
  // 插入 sms_info 表失败
  public readonly SMS_RECEIVE_REASON_SMS_INFO_DB_INSERT_FAIL: string = 'SmsInfo database table insert fail.';
  // 插入 rcs_info 表失败
  public readonly SMS_RECEIVE_REASON_RCS_INFO_DB_INSERT_FAIL: string = 'RcsInfo database table insert fail.';
  // 更新 session 表失败
  public readonly SMS_RECEIVE_REASON_SESSION_DB_UPDATE_FAIL: string = 'Session database table update fail.';
  // 根据发送号码查询 session 表失败
  public readonly SMS_RECEIVE_REASON_QUERY_SESSION_BY_TELEPHONE_FAIL: string = 'Query session by telephone fail.';
  // 点击搜索结果时，session id无效
  public readonly SMS_SEARCH_CLICK_REASON: string = 'Invalid session id';
  public readonly RECORD_KEY_IS_VER_MSG: number = 1;
  public readonly RECORD_KEY_BLOCKED_TYPE: number = 2;
  public readonly RECORD_VALUE_YES: number = 1;
  public readonly RECORD_VALUE_NO: number = 0;
  /**
   * 短彩信接收-类型-彩信
   */
  public readonly SMS_RECEIVE_TYPE_MMS: number = 2;
  /**
   * 短信收发成功率-类型-短信
   */
  public readonly SUCCESS_RATE_TYPE_SMS: number = 1;
  /**
   * 短信收发成功率-类型-彩信
   */
  public readonly SUCCESS_RATE_TYPE_MMS: number = 2;
  /**
   * 短信收发成功率-类型-增强信息
   */
  public readonly SUCCESS_RATE_TYPE_RCS: number = 3;
  /**
   * 短信收发成功率-行为-接收
   */
  public readonly SUCCESS_RATE_BEHAVIOR_RECEIVE: number = 1;
  /**
   * 短信收发成功率-行为-发送
   */
  public readonly SUCCESS_RATE_BEHAVIOR_SEND: number = 2;
  /**
   * 短信收发成功率-行为-下载
   */
  public readonly SUCCESS_RATE_BEHAVIOR_DOWNLOAD: number = 3;
  /**
   * 短信收发成功率-状态-开始
   */
  public readonly SUCCESS_RATE_STATE_START: number = 0;
  /**
   * 短信收发成功率-状态-完成
   */
  public readonly SUCCESS_RATE_STATE_FINISHED: number = 1;
  /**
   * 彩信下载点位RECEIVE_MESSAGE_DOWNLOAD-是否下载成功-未下载
   */
  public readonly RECEIVE_MESSAGE_DOWNLOAD_STATE_NONE: number = 0;
  /**
   * 彩信下载点位RECEIVE_MESSAGE_DOWNLOAD-是否下载成功-下载失败
   */
  public readonly RECEIVE_MESSAGE_DOWNLOAD_STATE_FAIL: number = 1;
  /**
  * 彩信下载点位RECEIVE_MESSAGE_DOWNLOAD-是否下载成功-下载成功
  */
  public readonly RECEIVE_MESSAGE_DOWNLOAD_STATE_SUCCESS: number = 2;
  /**
   * 彩信下载点位RECEIVE_MESSAGE_DOWNLOAD-失败原因-下载超时
   */
  public readonly RECEIVE_MESSAGE_DOWNLOAD_FAIL_TIMEOUT: string = 'Mms download timeOut';
  /**
   * 彩信下载点位RECEIVE_MESSAGE_DOWNLOAD-失败原因-下载后解析内容为空
   */
  public readonly RECEIVE_MESSAGE_DOWNLOAD_FAIL_DECODE_MMS_EMPTY: string = 'decodeMMs is empty or undefined';
  /**
   * 彩信下载点位RECEIVE_MESSAGE_DOWNLOAD-失败模式-隐私空间模式下
   */
  public readonly MESSAGE_FAIL_DECODE_PRIVATE_AREA: string = ',scenarios is private space';
}

export class RemindEnableNotificationKey {
  /**
   * 短信通知开关使能提醒-开关状态关闭
   */
  public static SWITCH_OFF: number = 0;
  /**
   * 短信通知开关使能提醒-开关状态打开
   */
  public static SWITCH_ON: number = 1;
  /**
   * 短信通知开关使能提醒-点击允许
   */
  public static BEHAVIOR_ALLOW: number = 1;
  /**
   * 短信通知开关使能提醒-点击不允许
   */
  public static BEHAVIOR_DENY: number = 2;
  /**
   * 短信通知开关使能提醒-默认
   */
  public static BEHAVIOR_DEFAULT: number = -1;
}

class eventName {
  public readonly SPEECH_BROADCAST_SWITCH = 'SPEECH_BROADCAST_SWITCH';
  public readonly SMSLIST_NEWPAGE = 'SMSLIST_NEWPAGE';
  public readonly OTHER_APP_PULL = 'OTHER_ENTRANCE_PULL_SMS';
  public readonly SENDING_SMS_EVENT = 'SENDING_SMS_EVENT';
  public readonly NEWPAGE_INPUT = 'NEW_INFO_SELECT_CONTACT';
  public readonly WRITE_SMS_EVENT = 'WRITE_SMS_EVENT';
  public readonly SENDING_FAILED_AND_RESEND = 'SENDING_FAILED_AND_RESEND';
  public readonly CONFIRM_RESEND_SMS_EVENT = 'CONFIRM_RESEND_SMS_EVENT';
  public readonly REPLY_TO_SMS_EVENT = 'REPLY_TO_SMS_EVENT';
  public readonly SETTING_ARCHIVE_INFO_SMS = 'SETTING_ARCHIVE_INFO_SMS';
  public readonly SETTING_ADVANCED_BUTTON = 'SETTING_ADVANCED_BUTTON';
  public readonly SET_ADVANCED_SELECT_EVENT = 'SET_ADVANCED_SELECT_EVENT';
  public readonly ADVANCED_SMS_CENTER_DIALOG = 'ADVANCED_SMS_CENTER_DIALOG';
  public readonly ADVANCED_SMS_CENTER_EVENT = 'ADVANCED_SMS_CENTER_EVENT';
  public readonly AUTO_DELETE_SMS_EVENT = 'AUTO_DELETE_SMS_EVENT';
  public readonly DELIVERY_REPORT_DIALOG_EVENT = 'DELIVERY_REPORT_DIALOG_EVENT';
  public readonly MORE_RESTORE_DEFAULT_DIALOG = 'MORE_RESTORE_DEFAULT_DIALOG';
  public readonly MORE_RESTORE_DEFAULT = 'MORE_RESTORE_DEFAULT';
  public readonly RECEIVE_SMS_EVENT = 'RECEIVE_SMS_EVENT';
  public readonly CLICK_TO_VIEW_SMS_EVENT = 'CLICK_TO_VIEW_SMS_EVENT';
  public readonly CLICK_NOTIFICATION_LIST = 'CLICK_NOTIFICATION_LIST';
  public readonly NOTIFICATION_LIST_OPERATION = 'NOTIFICATION_LIST_OPERATION';
  public readonly LIST_SWIPE_LEFT_READ = 'LIST_SWIPE_LEFT_READ';
  public readonly ADVANCED_RESTORE_DEFAULT_DIALOG = 'ADVANCED_RESTORE_DEFAULT_DIALOG';
  public readonly SWIPE_LEFT_TO_DELETE = 'SWIPE_LEFT_TO_DELETE';
  public readonly DELETE_SESSION_EVENT = 'DELETE_SESSION_EVENT';
  public readonly LONGPRESS_ONE_SMS = 'LONGPRESS_ONE_SMS';
  public readonly LONGPRESS_DELETE_MSG = 'LONGPRESS_DELETE_MSG';
  public readonly CLICK_AVATAR_EVENT = 'CLICK_AVATAR_EVENT';
  public readonly LIST_MORE_SELECT_EVENT = 'LIST_MORE_SELECT_EVENT';
  public readonly CONTENT_LONGPRESS = 'CONTENT_LONGPRESS';
  public readonly CONTENT_LONGPRESS_EVENT = 'CONTENT_LONGPRESS_EVENT';
  public readonly CONTENT_LONGPRESS_DELETE_EVENT = 'CONTENT_LONGPRESS_DELETE_EVENT';
  public readonly CONTENT_LONGPRESS_REPORT_EVENT = 'CONTENT_LONGPRESS_REPORT_EVENT';
  public readonly CONTENT_MORE_SELECT_ITEM = 'CONTENT_MORE_SELECT_ITEM';
  public readonly CONTENT_MORE_MORE_EVENT = 'CONTENT_MORE_MORE_EVENT';
  public readonly CONTENT_MORE_EVENT = 'CONTENT_MORE_EVENT';
  public readonly LIST_SWIPE_LEFT_EVENT = 'LIST_SWIPE_LEFT_EVENT';
  public readonly LONGPRESS_SELECT_CANCEL_DELETE = 'LONGPRESS_SELECT_CANCEL_DELETE';
  public readonly NOTICELIST_SWIPE_LEFT_READ = 'NOTICELIST_SWIPE_LEFT_READ';
  public readonly NOTICELIST_SWIPE_LEFT_EVENT = 'NOTICELIST_SWIPE_LEFT_EVENT';
  public readonly WRITE_ADD_ATTACHMENTS = 'WRITE_ADD_ATTACHMENTS';
  public readonly WRITE_ATTACHMENTS_AREA = 'WRITE_ATTACHMENTS_AREA';
  public readonly ADD_ATTACHMENT_GET_LOCATION_FAIL = 'ADD_ATTACHMENT_GET_LOCATION_FAIL';
  public readonly WRITE_HOLD_TO_SPEAK = 'WRITE_HOLD_TO_SPEAK';
  public readonly WRITE_COMPLETE_RECORDER = 'WRITE_COMPLETE_RECORDER';
  public readonly DELETE_ATTACHMENTS_AREA = 'DELETE_ATTACHMENTS_AREA';
  public readonly ADD_ATTACHMENT = 'ADD_ATTACHMENT';
  public readonly CLICK_MESSAGE_PAGE = 'CLICK_MESSAGE_PAGE';
  public readonly MESSAGE_MSM_PAGE = 'MESSAGE_MSM_PAGE';
  public readonly MESSAGE_MSM_PAGE_DELETE = 'MESSAGE_MSM_PAGE_DELETE';
  public readonly TOUCH_ATTACHMENTS_EVENT = 'TOUCH_ATTACHMENTS_EVENT';
  public readonly CLICK_SEARCH_BOX = 'CLICK_SEARCH_BOX';
  public readonly WRITE_CLICK_SEARCH_BOX = 'WRITE_CLICK_SEARCH_BOX';
  public readonly CLICK_SEARCH_RESULT = 'CLICK_SEARCH_RESULT';
  public readonly VIEW_MMS_MSG = 'VIEW_MMS_MSG';
  public readonly LONG_PRESS_SAVE_MMS = 'LONG_PRESS_SAVE_MMS';
  public readonly CLICK_DOWNLOAD_MMS = 'CLICK_DOWNLOAD_MMS';
  public readonly SHOW_CONTACT_AVATAR = 'SHOW_CONTACT_AVATAR';
  public readonly AUTO_DOWNLOAD_MMS = 'AUTO_DOWNLOAD_MMS';
  public readonly AUTO_DOWNLOAD_MMS_DIALOG = 'AUTO_DOWNLOAD_MMS_DIALOG';
  public readonly NOTIFICATION_RING_AND_SONG = 'NOTIFICATION_RING_AND_SONG';
  public readonly SEND_MMS = 'SEND_MMS';
  public readonly SEND_RCS_MSG = 'SEND_RCS_MSG';
  public readonly SATELLITE_MMS_JUMP_MAP = 'SATELLITE_MMS_JUMP_MAP';
  public readonly NOTIFICATION_OPERATION = 'NOTIFICATION_OPERATION';
  public readonly CPU_SCENE_ENTRY = 'CPU_SCENE_ENTRY';
  public readonly MEM_SCENE_ENTRY = 'MEM_SCENE_ENTRY';
  public readonly SETTING_SMART_MMS = 'SETTING_SMART_MMS';
  public readonly SETTING_RCS_MMS = 'SETTING_RCS_MMS';
  public readonly RCS_MMS_SWITCH_VALUE = 'RCS_MMS_SWITCH_VALUE';
  public readonly RCS_READ_REPORT_VALUE = 'RCS_READ_REPORT_VALUE';
  public readonly SETTING_MMS_PRIVACY_STATE = 'SETTING_MMS_PRIVACY_STATE';
  public readonly SETTING_MMS_PERSONAL_LIST = 'SETTING_MMS_PERSONAL_LIST';
  public readonly CONTENT_COPY_VERIFY_CODE = 'CONTENT_COPY_VERIFY_CODE';
  public readonly SETTING_NUMBER_IDENTIFICATION = 'SETTING_NUMBER_IDENTIFICATION';
  public readonly SETTING_RCS_MMS_STATE = 'SETTING_RCS_MMS_STATE';
  public readonly SETTING_SMART_MMS_STATE = 'SETTING_SMART_MMS_STATE';
  public readonly SETTING_AGGREGATE_STATUS = 'SETTING_AGGREGATE_STATUS';
  public readonly SETTING_MALICIOUS_CHECK_STATE = 'SETTING_MALICIOUS_CHECK_STATE';
  public readonly SETTING_SHOW_HEAD_ICON_STATE = 'SETTING_SHOW_HEAD_ICON_STATE';
  public readonly SETTING_AUTO_DOWNLOAD_MMS_STATE = 'SETTING_AUTO_DOWNLOAD_MMS_STATE';
  public readonly SETTING_DELIVERY_REPORT_STATE = 'SETTING_DELIVERY_REPORT_STATE';
  public readonly SETTING_AUTO_DELETE_SMS_STATE = 'SETTING_AUTO_DELETE_SMS_STATE';
  public readonly RECORDER_PERMISSION_BUTTON = 'RECORDER_PERMISSION_BUTTON';
  public readonly ADD_ATTACHMENT_RCS = 'ADD_ATTACHMENT_RCS';
  public readonly SMART_SHOW_BUBBLE_MAP = 'SMART_SHOW_BUBBLE_MAP';
  public readonly RECEIVE_MESSAGE_SUCCESS = 'RECEIVE_MESSAGE_SUCCESS';
  public readonly RECEIVE_MESSAGE_FAIL_TIMEOUT = 'RECEIVE_MESSAGE_FAIL_TIMEOUT';
  public readonly RECEIVE_MESSAGE_FAIL_INSERT = 'RECEIVE_MESSAGE_FAIL_INSERT';
  public readonly RECEIVE_MESSAGE_FAIL_VERCODE = 'RECEIVE_MESSAGE_FAIL_VERCODE';
  public readonly RECEIVE_MESSAGE_FAIL_BLOCK = 'RECEIVE_MESSAGE_FAIL_BLOCK';
  public readonly RECEIVE_MESSAGE_FAIL_NOTIFY = 'RECEIVE_MESSAGE_FAIL_NOTIFY';
  public readonly RECEIVE_MESSAGE_COMMON = 'RECEIVE_MESSAGE_COMMON';
  public readonly SET_BADGE_EVENT = 'SET_BADGE_EVENT';
  public readonly CHATBOT_SWITCH_CHANGE = 'CHATBOT_SWITCH_CHANGE';
  public readonly SMSLIST_SETTING = 'SMSLIST_SETTING';
  public readonly SM_CONTENT_SIZE = 'SM_CONTENT_SIZE';
  public readonly SM_SEND_RCSRECORD = 'SM_SEND_RCSRECORD';
  public readonly DISTRIBUTED_SEND_MSG_EVENT = 'DISTRIBUTED_SEND_MSG_EVENT';
  public readonly DISTRIBUTED_REPLY_TO_SMS_EVENT = 'DISTRIBUTED_REPLY_TO_SMS_EVENT';
  public readonly DISTRIBUTED_RECEIVE_SMS_EVENT = 'DISTRIBUTED_RECEIVE_SMS_EVENT';
  public readonly REPORT_CHATBOT = 'REPORT_CHATBOT';
  public readonly REPORT_CHATBOT_MESSAGE = 'REPORT_CHATBOT_MESSAGE';
  public readonly SHARE_LOCATION_INFO = 'SHARE_LOCATION_INFO';
  public readonly SHARE_DEVICE_INFO = 'SHARE_DEVICE_INFO';
  public readonly DISTURB = 'DISTURB';
  public readonly OPEN_CHATBOT_SETTING = 'OPEN_CHATBOT_SETTING';
  public readonly CALL_CHATBOT_NUMBER = 'CALL_CHATBOT_NUMBER';
  public readonly ENTER_CHATBOT_FROM_DETAIL = 'ENTER_CHATBOT_FROM_DETAIL';
  public readonly REMOVE_CHATBOT_FAVOURITES = 'REMOVE_CHATBOT_FAVOURITES';
  public readonly ADD_CHATBOT_FAVOURITES = 'ADD_CHATBOT_FAVOURITES';
  public readonly OPEN_CHATBOT_DETAIL = 'OPEN_CHATBOT_DETAIL';
  public readonly OPEN_CLICK_RECOMMEND_CHATBOT = 'OPEN_CLICK_RECOMMEND_CHATBOT';
  public readonly OPEN_CHATBOT_NEIGHBOR = 'OPEN_CHATBOT_NEIGHBOR';
  public readonly OPEN_CHATBOT_SCAN = 'OPEN_CHATBOT_SCAN';
  public readonly SEARCH_CHATBOT = 'SEARCH_CHATBOT';
  public readonly CLICK_CHATBOT = 'CLICK_CHATBOT';
  public readonly RCS_SEND_MSG = 'RCS_SEND_MSG';
  public readonly LONGPRESS_UNREAD = 'LONGPRESS_UNREAD';
  public readonly LONGPRESS_PIN = 'LONGPRESS_PIN';
  public readonly LIST_SWIPE_LEFT_PIN = 'LIST_SWIPE_LEFT_PIN';
  public readonly PANGESTURE_MULTIPLE_SELECT = 'PANGESTURE_MULTIPLE_SELECT';
  // 通知静默打点事件
  public readonly NOTIFICATION_MUTE_REPORT_EVENT = 'NOTIFICATION_MUTE_REPORT_EVENT';
  // 短信收发成功率 1.短信收发 2.彩信收发 3.增强信息收发 3.彩信下载
  public readonly MSG_SEND_RECEIVE_SUCCESS_RATE = 'MSG_SEND_RECEIVE_SUCCESS_RATE';
  // 彩信附件下载展示打点事件
  public readonly RECEIVE_MESSAGE_DOWNLOAD = 'RECEIVE_MESSAGE_DOWNLOAD';
  // 短信_短信基础功能_短信发送 （短彩信、rcs发送流程打点）
  public readonly SEND_MESSAGE_COMMON = 'SEND_MESSAGE_COMMON';
  // 低内存相机打点
  public readonly LOW_MEMORY_CAMERA = 'LOW_MEMORY_CAMERA';
  // 低内存相机预览页面打点
  public readonly LOW_MEMORY_CAMERA_PREVIEW = 'LOW_MEMORY_CAMERA_PREVIEW';
  // 标记验证码消息已读
  public readonly MARK_VER_MSG_READ = 'MARK_VER_MSG_READ';
  // 短信通知开关使能提醒
  public readonly REMIND_ENABLE_NOTIFICATION = 'REMIND_ENABLE_NOTIFICATION';
  /** RCS_向服务器查询应用号详情的查询结果上报 */
  public readonly CHATBOT_DETAILS_QUERY = 'CHATBOT_DETAILS_QUERY';
  /** 信息是否是服务号信息结果上报 */
  public readonly SMS_ISSERVICE_MSG = 'SMS_ISSERVICE_MSG';
  // 开关打点事件
  public readonly SMS_SWITCH_STATUS_REPORT_EVENT = 'SMS_SWITCH_STATUS_REPORT_EVENT';
  // 上一次开关运维打点时间戳
  public readonly SWITCH_STATUS_REPORT_TIME = 'SWITCH_STATUS_REPORT_TIME';
}

class FaultEventName {
  public readonly SMS_SEND_FAIL = 'SMS_SEND_FAIL';
  public readonly SMS_RECIEVE_FAIL = 'SMS_RECIEVE_FAIL';
  public readonly MMS_SEND_FAIL = 'FAIL_SEND_MMS_MSG';
  public readonly MMS_RECIEVE_FAIL = 'FAIL_RECIEVE_MMS_MSG';
  public readonly SMS_DATABASE_ERROR = 'SMS_DATABASE_ERROR';
  // 统计无效数据打点事件
  public readonly STATISTIC_INVALID_COUNT = 'STATISTIC_INVALID_COUNT';
}

class commonData {
  public eventName = new eventName();
  public faultEventName = new FaultEventName();
  public smsReceiveRecord = new RecordKeyName();
}

export enum SatelliteSMSReminderResult {
  SUCCESS = 1,
  FAIL_EMPTY_LOCAL_NUMBER = 2,
  FAIL_INVALID_VALIDATE = 3,
  FAIL_NOT_MATCH_VALIDATION = 4,
  FAIL_SSM_VALIDATION_ERROR = 5,
}

/**
 * CHATBOT_DETAILS_QUERY 打点事件的参数类
 */
export class EventParamChatbotDetailsQuery {
  // 详情查询结果（success，failed）
  private static RESULT = 'RESULT';
  // 消息id
  private static MSGID = 'MSGID';
  // 失败原因
  private static FAIL_REASON = 'FAIL_REASON';
  private params: Record<string, string>;

  constructor(result: 'success' | 'failed', msgId: string, failReason: string) {
    this.params = {};
    this.params[EventParamChatbotDetailsQuery.RESULT] = result;
    this.params[EventParamChatbotDetailsQuery.MSGID] = msgId;
    this.params[EventParamChatbotDetailsQuery.FAIL_REASON] = failReason;
  }

  public getParams = (): Record<string, string> => {
    return this.params;
  }
}

export default new commonData();