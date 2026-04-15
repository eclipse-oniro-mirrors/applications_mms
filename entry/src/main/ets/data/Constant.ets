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

export default class Constant {

  /**
   * 列表页分页查询功能的常量值.
   */
  public static readonly PAGE_INIT_NUM: number = 0;
  public static readonly REFRESH_INDEX_INIT_NUM: number = 1;
  public static readonly FIRST_PAGE_SIZE: number = 10;

  /**
   * SQL查询中的最大参数个数
   */
  public static readonly MAX_NUMBER_OF_PARAMS_IN_SQL = 300;

  /**
   * 已读未读标记
   */
  public static readonly UN_READ: number = 0;
  public static readonly READ: number = 1;

  /**
   * Constant value on the Conversation.
   */
  public static readonly MMS_INPUT_TEXTAREA_Id: string = 'mms_input_textarea_id';

  /**
   * 拦截骚扰的常量值.
   */
  public static readonly NO_BLOCK: number = 0;
  public static readonly BLOCK: number = 1;
  public static readonly BLOCKED_SESSION: number = -1;
  public static readonly SESSION_TYPE_BLOCKED: number = 3;
  public static readonly BLOCKED_NOTIFY_SWITCH_OPEN: string = '1';
  public static readonly BLOCKED_NOTIFY_SWITCH_CLOSED: string = '0';
  public static readonly BLOCKED_TO_CLOUD: number = 1;
  public static readonly BLOCKED_NOT_TO_CLOUD: number = 2;
  public static readonly BLOCKED_IS_VER_CODE: number = 6;
  public static readonly BLOCKED_CONTACT_PHONE_LAST: number = 7;
  public static readonly BLOCKED_SERVICE_DETECT_EVENT: string = 'blocked_service_detect_event';
  public static readonly BLOCKED_SERVICE_MMS_DETECT_EVENT: string = 'blocked_service_mms_detect_event';
  public static readonly BLOCKED_SERVICE_RCS_DETECT_EVENT: string = 'blocked_service_rcs_detect_event';
  // 骚扰拦截的原因
  public static readonly BLOCKED_REASON_LIST: number = 1;
  public static readonly BLOCKED_REASON_KEYWORDS: number = 3;
  public static readonly BLOCKED_REASON_STRANGE_NUMBER: number = 4;
  public static readonly BLOCKED_REASON_PREF_PHONE_NUMBER: number = 10;
  public static readonly BLOCKED_REASON_CLOUD: number = 1001;
  // 骚扰拦截云查类型
  public static readonly BLOCKED_TYPE_ADVERTISEMENT_MMS: number = 1200;
  public static readonly BLOCKED_TYPE_SPAM_MMS: number = 1300;
  // 骚扰拦截云查类型来源
  public static readonly BLOCKED_SOURCES_FRAUD: string = '3';
  public static readonly SESSION_CHANGE_WHITE: string = '100';
  // 骚扰拦截电话云查类型
  public static readonly BLOCKED_TYPE_CALL_FRAUD: number = 2;
  public static readonly BLOCKED_SOURCES_CALL_FRAUD: string = '5';
  // 国家反诈常量值
  public static readonly SESSION_NORMAL: number = 0;
  public static readonly SESSION_BLOCKED_FRAUD: number = 1;
  public static readonly BLOCKED_FRAUD_SETTINGS_SWITCH: string = 'settings.telephony.antifraud_center_switch';
  public static readonly BLOCKED_NUMBER_IDENTITY_SWITCH: string = 'settings.telephony.number_identity_switch';
  public static readonly BLOCKED_INTELL_SPAM_SIM1_SWITCH: string = 'spamshield_sim1_sms_switch_intell_spam';
  public static readonly BLOCKED_INTELL_SPAM_SIM2_SWITCH: string = 'spamshield_sim2_sms_switch_intell_spam';
  // 全民反诈
  public static readonly BLOCKED_BEST_MIND_SETTINGS_SWITCH: string = 'settings.telephony.antifraud_bestmind_switch';

  // 号码分类
  public static readonly TELEPHONE_TYPE_COMMON: number = 0;
  public static readonly TELEPHONE_TYPE_NOTICE: number = 1;
  public static readonly TELEPHONE_TYPE_YELLOW_PAGE: number = 2;
  public static readonly TELEPHONE_TYPE_ENTERPRISE: number = 3;
  public static readonly TELEPHONE_TYPE_PERSONAL_NUMBER: number = 4;

  /**
   * 通知类msg id的常量值.
   */
  public static readonly BLOCKED_NOTIFICATION_MSG_ID: number = -1;

  /**
   * 举报短信的常量值.
   */
  public static readonly GENERATE_CALLEE_ID_TIMEOUT = 7 * 24 * 60 * 60 * 1000;
  public static readonly CALLEE_ID_LENGTH = 16;
  public static readonly RADIX = 16;
  public static readonly CLOUD_CONNECT_DEFAULT_NUM = '123456';
  public static readonly CLOUD_CONNECT_RANDOM_NUM_LENGTH = 6;
  public static readonly RANDOM_NUMBER_BYTE_COUNT = 3;
  public static readonly CLOUD_RAWFILE_NAME = 'cloud_check_config.json';
  public static readonly CHATBOT_CONFIG_PATH = 'chatbot/chatbot_config.json';
  public static readonly APPEAL_SMS_MARKER_CLOUD_PATH = '/rms/v1/antiFraud/smsMarker';
  public static readonly CLOUD_CHECK_REQUEST_APP_ID = 'Mms';
  public static readonly GENERATE_CALLEE_ID_TIME = 'generateCalleeIdTime';
  public static readonly CALLEE_ID = 'calleeId';

  public static readonly MAP_IMG_WIDTH: number = 220;
  public static readonly MAP_IMG_HEIGHT: number = 125;
  /* [检测验证码] server */
  public static readonly VERCODE_SERVICE_EVENT: string = 'vercode_service_event';
  /**
   * 能效资源时间常量
   */
  public static readonly SMS_TIMEOUT: number = 18000;
  public static readonly MMS_TIMEOUT: number = 5 * 60 * 1000;
  public static readonly CHATBOT_TIMEOUT: number = 5 * 60 * 1000;
  public static readonly FILE_MIGRATION_TIMEOUT: number = 10 * 1000;
  /**
   * 无障碍屏幕朗读常量
   */
  public static readonly ACCESSIBILITY_SCREEN_READER_SWITCH_OPEN: string = '1';
  public static readonly ACCESSIBILITY_SCREEN_READER_SWITCH_CLOSED: string = '0';

  public static readonly SMART_CENTER_NUMBER: string = 'noUsed';

  /**
   * 智能短信字符串的开关状态 0：关闭, 1：打开
   */
  public static readonly SMART_SWITCH_OPEN: string = '1';
  public static readonly SMART_SWITCH_CLOSE: string = '0';
  /**
   * 智能卡片判断类型 0：全部, 1：验证码, 2:来去电提醒
   */
  public static readonly SMART_JUDGE_VER_TYPE: number = 1;
  /**
   * 智能卡片返回结果消息类型  1：验证码, 2:来去电提醒
   */
  public static readonly SMART_MSG_TYPE_VER: number = 1;
  /**
   * 智能信息解析验证码返回结果  '-1'：非验证码（异常情况）, 其他:正常验证码
   */
  public static readonly SMART_MSG_NOT_VER: string = '-1';
  /**
   * 更新infoMsg version
   */
  /* 升级更新version 版本为2
   */
  public static readonly UPDATE_MSG_VERSION_V4: number = 4;
  public static readonly UPDATE_MSG_VERSION_V2: number = 2;
  public static readonly NO_UPDATE_INFO_MSG_VERSION: number = 0;
  /**
   * 升级场景，同步卡片数据，每轮同步的数量
   */
  public static readonly UPDATE_SYNC_VCARD_INFO_PAGESIZE: number = 200;

  /**
   * RCS开关状态常量
   */
  public static readonly RCS_SWITCH_NAME = 'rcs_enhance_status';
  public static readonly RCS_SWITCH_ON: string = '1';
  public static readonly RCS_SWITCH_OFF: string = '0';
  public static readonly RCS_LOCATION_GET_THUMBNAILS: string = 'rcs_location_get_thumbnails';

  /**
   * 关怀模式
   */
  public static readonly SENIOR_MODE_THREE = 1.45;//关怀模式3挡

  /**
   * verde
   */
  public static readonly DEFAULT_FOLD_CONFIGURATION = '0,0,0,0';
  public static readonly FOLD_PRODUCT_TYPE_KEY = 'const.window.foldscreen.type';

  /**
   * 会话详情页
   */
  //查询会话详情页数据
  public static readonly ACTION_DATA_NAME_QUERY_SMS_MMS_INFO_ALL = 'QuerySmsMmsInfoByConditionAll';
  // 连续表情按钮点击间隔
  public static readonly CLICK_EMOJI_BUTTON_TIME_INTERVAL: number = 200;
  /**
   * 短信协议侧错误码常量
   */
  // 未知错误
  public static readonly SMS_ERROR_CODE_UN_KNOW: number = 8300999;
  // 参数无效
  public static readonly SMS_ERROR_CODE_INVALID_PARAMETER: number = 8300001;
  /**
   * 通信共享 短信开关
   */
  public static readonly DISTRIBUTED_CALL_SMS_SHARING_OFF = 0;
  public static readonly DISTRIBUTED_CALL_SMS_SHARING_ON = 1;

  /**
   * 删除草稿的信息，用于在融合搜中 把搜出来已经删除的草稿给过滤掉
   */
  public static readonly DELETED_DRAFT_MSG_ID = 'DeletedDraftMsgId';
  public static readonly DELETED_DRAFT_NUMBER = 'DeletedDraftPhoneNumber';
  public static readonly INSERT_DRAFT_MSG_ID = 'InsertDraftMsgID';
  public static readonly INSERT_DRAFT_MSG_CONTENT = 'InsertDraftMsgContent';
  public static readonly WHETHER_NOT_SEARCH_INSERT_DRAFT_MSG = 'WhetherNotSearchInsertDraftMsg'; //是否没有搜索到插入的草稿
  public static readonly IS_SECOND_REFRESH_SEARCH = 'IsSecondRefreshSearch';//是否是第二次更新查询
  public static readonly IS_CHANGE_DRAFT = 'IsChangeDraft';//是否是修改草稿
  public static readonly IS_DELETE_MESSAGE = 'isDeleteMessage';// 是否是删除会话详情中信息
  public static readonly IS_FAVORITE_CHANGE = 'isFavoriteChange';
  /**
   * 免打扰模式常量
   */
  public static readonly FOCUS_MODE_ENABLE_SWITCH_OPEN: string = '1';
  public static readonly FOCUS_MODE_ENABLE_SWITCH_CLOSED: string = '0';

  /**
   * 会话列表的两个会话之间的分割线的高度
   * 单位px
   */
  public static readonly HEIGHT_OF_CONVERSATION_LIST_DIVIDER: number = 1;
  /**
   * smil中的彩信消息类型的key，放在meta标签里
   */
  public static readonly MMS_MESSAGE_TYPE_IN_SMIL = 'mmsMessageType';
  /**
   * smil中的彩信位置附件的索引列表，放在幻灯片消息的meta标签里
   */
  public static readonly MMS_LOCATION_MESSAGE_IN_SLIDE_SMIL = 'mmsLocationMessageIndexList';
  /**
   * smil中的彩信位置附件的内容，放在幻灯片消息的meta标签里
   */
  public static readonly MMS_LOCATION_CONTENT_IN_SLIDE_SMIL = 'mmsLocationAttachContentInSlideSmil';
  /**
   * smil中的位置消息经度的key，放在meta标签里
   */
  public static readonly LONGITUDE_IN_SMIL = 'location_message_longitude';
  /**
   * smil中的位置消息纬度的key，放在meta标签里
   */
  public static readonly LATITUDE_IN_SMIL = 'location_message_latitude';
  /**
   * smil中的位置消息坐标的key，放在meta标签里
   */
  public static readonly COORDINATE_IN_SMIL = 'location_message_coordinate';
  /**
   * smil中的彩信位置消息类型的value
   */
  public static readonly LOCATION_MMS_MESSAGE_TYPE = 'Location';
  /**
   * 未读提醒红点相关参数
   */
  public static readonly BADGE_SIZE_NORMAL: number = 16;
  public static readonly BADGE_SIZE_MAX: number = 24;
  public static readonly BADGE_FONT_NORMAL: string = '10vp';
  public static readonly BADGE_FONT_MAX: string = '16vp';
}

/**
 * 字体缩放比例
 *
 */
export class FontSizeScale {
  public static readonly SMALL: number = 0.85;
  public static readonly NORMAL: number = 1;
  public static readonly LARGE: number = 1.15;
  public static readonly EXTRA_LARGE: number = 1.3;
  public static readonly HUGE: number = 1.45;
  public static readonly HUGE_2: number = 1.75;
  public static readonly HUGE_3: number = 2;
  public static readonly HUGE_4: number = 3.2;
}