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
class bool {
    public readonly TRUE: string = '1';
    public readonly FALSE: string = '0';
    public readonly NOT_SET: string = '-1';
}

class SwitchStatus {
    public readonly OPEN: number = 1;
    public readonly CLOSE: number = 0;
}

class route {
    // Update the value of the delivery report switch.
    public readonly MESSAGE_CODE_UPDATE_DELIVERY_REPORTS_VALUE: number = 32001;
    // Update the value of the function of automatically downloading MMS messages.
    public readonly MESSAGE_CODE_UPDATE_AUTO_RETRIEVE_MMS_VALUE: number = 32002;
    // Update the value of the switch for automatically deleting notification information.
    public readonly MESSAGE_CODE_UPDATE_AUTO_DELETE_INFO_MESSAGES_VALUE: number = 32004;
    // Update the value of the notification integration switch.
    public readonly MESSAGE_CODE_UPDATE_ARCHIVE_INFO_MESSAGES_VALUE: number = 30002;
    // Updates the value of the switch for displaying contact avatars.
    public readonly MESSAGE_CODE_UPDATE_SHOW_CONTACT_PROFILE_PICS_VALUE: number = 30004;
    // Restore the value of the advanced page switch.
    public readonly MESSAGE_CODE_RESTORE_ADVANCED_PAGE_SWITCH_VALUE: number = 30005;
    // update the value of switch speech broadcast.
    public readonly MESSAGE_CODE_UPDATE_SPEECH_BROADCAST_VALUE: number = 30006;
}

class int {
    // rcs text send max length
    public readonly RCS_SEND_MAX_LENGTH: number = 1300;
    // status code
    public readonly SUCCESS: number = 0;
    public readonly FAILURE: number = -1;
    public readonly INVALID: number = -1;
    public readonly INVALID_DATA: number = -1;
    // CheckBox select status code   1. Select all. 2. Do not select all. 3. Unknown.
    public readonly CHECKBOX_SELECT_ALL: number = 1;
    // None
    public readonly CHECKBOX_SELECT_NONE: number = 2;
    // Unknown
    public readonly CHECKBOX_SELECT_UNKNOWN: number = 3;
    public readonly MESSAGE_CODE_TWENTY_FIVE: number = 60;
    public readonly MESSAGE_CODE_THREE_FOUR_ZERO: number = 660;
    // Text
    public readonly TYPE_TEXT: number = 0;
    // Pictures
    public readonly TYPE_IMAGE: number = 1;
    // Audio
    public readonly TYPE_AUDIO: number = 2;
    // Video
    public readonly TYPE_VIDEO: number = 3;
    // 0
    public readonly MESSAGE_CODE_ZERO: number = 0;
    // 1
    public readonly MESSAGE_CODE_ONE: number = 1;
    // 2
    public readonly MESSAGE_CODE_TWO: number = 2;
    // 300
    public readonly MESSAGE_CODE_THREE_ZERO_ZERO: number = 300;
    // 1001
    public readonly MESSAGE_CODE_THOUSAND_ONE: number = 1001;
    // 1000
    public readonly MESSAGE_CODE_THOUSAND: number = 1000;
    public readonly MAX_RECIPIENT_DEFAULT_OF_SMC = 4;
    public readonly MAX_RECIPIENT_DEFAULT_OF_RCS: number = 100;
    public readonly MAX_DEFAULT_SIZE_OF_RCS_FILE_SENDING_MESSAGE: number = 500000000; //500MB
    // The SMS message is sent successfully.
    public readonly SEND_MESSAGE_SUCCESS: number = 0;
    // Sending
    public readonly SEND_MESSAGE_SENDING: number = 1;
    // sent msg, is_sender = 0
    public readonly SENT_MESSAGE: number = 0;
    // Failed to send the SMS message.
    public readonly SEND_MESSAGE_FAILED: number = 2;
    public readonly SEND_MESSAGE_READ: number = 8;
    // Draft Data Type
    public readonly SEND_DRAFT: number = 3;
    // downloading
    public readonly MMS_DOWNLOADING: number = 4;
    // downloaded
    public readonly MMS_DOWNLOADED: number = 5;
    // download failed
    public readonly MMS_DOWNLOAD_FAILED: number = 6;
    // not download
    public readonly MMS_NOT_DOWNLOAD: number = 7;
    public readonly RCS_SEND_OK:number = 9;
    public readonly SEND_MESSAGE_SATELLITE_WAITING: number = 10;
    public readonly RCS_SEND_CANCELED: number = 10;
    public readonly RCS_RECEIVING: number = 12;
    public readonly RCS_FIRST_RECEIVING: number = 13;
    public readonly RCS_RECEIVING_CANCEL: number = 14;
    // Width of the left slide control of the list
    public readonly OPERATE_DELETE_WIDTH: number = 80;
    public readonly OPERATE_UNREAD_WIDTH: number = 128;
    // Number of SIM cards
    public readonly SIM_COUNT: number = 2;
    // sim card 1
    public readonly SIM_ONE: number = 0;
    // sim card2
    public readonly SIM_TWO: number = 1;
    // slot 0
    public readonly SLOT_ZERO: number = 0;
    // slot 1
    public readonly SLOT_ONE: number = 1;
    // telephone last for digit.
    public readonly TELEPHONE_LAST_PART_LENGTH: number = 4;
    // 550 Default Height
    public readonly TAB_HEIGHT: number = 550;
    // 550+720tab Full screen height
    public readonly FULL_HEIGHT: number = 550 + 720;
    // Number of words in full screen
    public readonly FULL_SCREEN_SEND_LENGTH: number = 38;
    public readonly SMSMMSINFO_PAGE_THRESHOLD: number = 4000;
    public readonly DELETE_PAGINATION_LENGTH: number = 50;
    // Recent contacts
    public readonly RECENT_TOTAL_LIMIT: number = 20;
    public readonly RECENT_OFFSET_LIMIT: number = 0;
    public readonly MMS_FILE_MAX_SIZE: number = 300 * 1024;
    public readonly RCS_IMAGE_FACE_DETECT_MAX_SIZE: number = 2 * 1024 * 1024;
    public readonly MMS_AUDIO_FILE_MAX_SIZE: number = 280 * 1024;
    public readonly BYTE_CONVERSION_UNIT: number = 1024;
    public readonly MMS_ATTACHMENT_UPPER_LIMIT: number = 20;
    public readonly MMS_ATTACHMENT_UPPER_LIMIT_ENHANCED_INFO_MODE: number = 9;
    public readonly MILLISECOND_OF_ONE_MINUTE: number = 60000;
    public readonly MILLISECOND_OF_ONE_DAY: number = 86400000;
    public readonly MILLISECOND_OF_ONE_MONTH: number = 2592000000;
    public readonly TIME_OF_LAST_DELETE_NOTIFY_MMS: number = 0;
    public readonly SMS_MESSAGE_DELETE_TIME_NUMBER: number = 30;
    public readonly MESSAGE_MAX_WIDTH: number = 284;
    public readonly MMS_MESSAGE_MIN_WIDTH: number = 90;
    public readonly RCS_FILE_SIZE: number = 1024;
    public readonly RCS_FILE_MAX_SIZE: number = 1024 * 1024;
    public readonly RCS_RECORD_DURATION: number = 10;
    public readonly RCS_RECORD_MAX_DURATION: number = 60;
    public readonly RCS_RECORD_START_COUNTDOWN: number = 50;
    public readonly RCS_RECORD_COUNTDOWN_DURATION: number = 10;
    public readonly RCS_RECORD_CANCEL_COORDINATES: number = -200;
    public readonly RCS_AUDIO_DURATION_CONVERSION: number = 1000;
    // 详情页打开标记当前会话已读耗时
    public readonly MARK_ALL_TO_READ_MAX_COST_TIME: number = 200;
    // risk url record
    public readonly RISK_URL_RECORD_DEFAULT_ID: number = -1;
    public readonly RISK_URL_RECORD_CHECK_ONE_MAX_NUMBER: number = 5;
    public readonly RISK_URL_RECORD_CHECK_SYNC_MAX_NUMBER: number = 5 * this.RISK_URL_RECORD_CHECK_ONE_MAX_NUMBER;
    public readonly RISK_URL_RECORD_DEFAULT_VALUE: number = -1;
    // The navigation bar and the content area are displayed in stack.
    public readonly NAVIGATION_MODE_STACK: number = 0;
    // The navigation bar and the content area are displayed side by side.
    public readonly NAVIGATION_MODE_SPLIT: number = 1;
    // sms to mms threshold default value
    public readonly SMS_TO_MMS_THRESHOLD_DEFAULT: number = 11;
    // not support sms to mms
    public readonly NOT_SUPPORT_SMS_TO_MMS: number = -1;
    // Max retry time for mms download.
    public readonly MIN_RETRY_TIME: number = 0;
    public readonly MAX_RETRY_TIME: number = 3;
    public readonly RETRY_TIME_FIRST: number = 0;
    public readonly RETRY_TIME_SECOND: number = 1;
    public readonly RETRY_TIME_THIRD: number = 2;
    public readonly RETRY_TIME_INVALID: number = -1;
    public readonly RETRY_INTERVAL: number = 1000 * 60;
    public readonly RCS_CODE_LENGTH: number = 4;
    // Maximum magnification of the font
    public readonly MAX_FONT_SIZE_SCALE: number = 2;
    public readonly CHINESE_MAX_COUNT: number = 67; //中文大于70时拆短信（3+67,3+67），实际每条短信最长67
    public readonly ENGLISH_MAX_COUNT: number = 153; //英文大于160时拆成多条短信，实际每条短信最长153
    public readonly NUMBER_FIFTY_EIGHT: number = 56;
    public readonly NUMBER_TWO: number = 2;
    public readonly MESSAGE_UNREAD: number = 0;
    public readonly NUMBER_ZERO: number = 0;
    public readonly HDS_NAVIGATION_BAR_HEIGHT: number = 56; //NavDestination高度
    public readonly HDS_NAVIGATION_BAR_SUBTITLE_HEIGHT: number = 32; //NavDestination副标题高度
    public readonly SHOW_SESSION_FIRST: number = 7;
    // vCard
    public readonly TYPE_STATE_VCARD: number = 4;
    public readonly RESPOND_SUCCESS: number = 200;
    public readonly UPDATA_INFOMSG_UNREADCOUNT_TIME: number = 500;
    // 录音消息
    public readonly AUDIO_MESSAGE_MAX_WIDTH: number = 224;
    public readonly AUDIO_MESSAGE_MARGIN: number = 4;
    public readonly BACKUP_WORK_DELAY_TIME: number = 5000;

}

class STR {
    public readonly RECEIVE_MESSAGE_USER_LOCK: string = 'settings.mms.receive_message_user_unlock';
    //if back to home
    public readonly IS_BACK_HOMEPAGE: string = 'isBackHomePage';
    public readonly SMS_TYPE: string = '0';
    // Empty String
    public readonly EMPTY_STR: string = '';
    // zero String
    public readonly STRING_ZERO: string = '0';
    // comma
    public readonly COMMA: string = ',';
    // split
    /*
     * 联系人名字格式:名字1, 名字2 中间使用:英文逗号+空格分割
     * 统一使用CONTACT_NAME_SPLIT进行分割
     * */
    public readonly CONTACT_NAME_SPLIT: string = ', ';
    public readonly SPLIT:string = '\n';
    public readonly NEWLINE:string = '\r\n';
    public readonly COLON:string = '：';
    public readonly LEFT_BRACKETS:string = '【';
    public readonly RIGHT_BRACKETS:string = '】';
    public readonly LEFT_ANGLE_BRACKETS:string = '「';
    public readonly RIGHT_ANGLE_BRACKETS:string = '」';
    // whitespace
    public readonly WHITE_SPACE: string = ' ';
    // bundleName
    public readonly BUNDLE_NAME: string = 'com.ohos.mms';
    // abilityName
    public readonly ABILITY_NAME: string = 'com.ohos.mms.MainAbility';
    // BundleName of a contact.
    public readonly CONTACT_BUNDLE_NAME: string = 'com.ohos.contacts';
    // BundleName of a serviceaccess.
    public readonly serviceaccess_BUNDLE_NAME: string = 'com.xxx.yyy.serviceaccess';
    // contact AbilityName
    public readonly CONTACT_ABILITY_NAME: string = 'com.ohos.contacts.MainAbility';
    public readonly CONVERGENT_SEARCH_NAME: string = 'com.xxx.yyy.hisearch';
    //从通知栏拉起短信
    public readonly LAUNCH_MMS_BY_NOTIFICATION: string = 'mms.event.notification';

    //从畅联联系人拉起短信
    public readonly LAUNCH_MMS_BY_MEETIME_SERVICE: string = 'com.ohos.meetimeservice';

    //从桌面拉起短信
    public readonly LAUNCH_MMS_BY_HOME: string = 'action.system.home';
    // Public entity
    public readonly COMMON_ENTITIES: string = 'entity.system.home';
    // Processing succeeded.
    public readonly SUCCESS: string = 'success';
    // Storage path of the lightweight preference database
    public readonly PATH_OF_PREFERENCES: string = '/PREFERENCES_FOR_MMS';
    // Notification information integration
    public readonly KEY_OF_INTEGRATION_SWITCH: string = 'integrationSwitch';
    // Display contact avatar
    public readonly KEY_OF_SHOW_CONTACT_SWITCH: string = 'showContactSwitch';
    // Display contact avatar
    public readonly KEY_OF_IS_RCS_OPEN_SWITCH: string = 'isUIOpenRcs';
    // Display contact avatar
    public readonly KEY_OF_IS_CHATBOT_OPEN_SWITCH: string = 'isUIChatbotOpenRcs';
    // Delivery Report
    public readonly KEY_OF_DELIVERY_REPORT_SWITCH: string = 'deliveryReportSwitch';
    // Privacy Statement Has Update
    public readonly KEY_OF_NEW_PRIVACY_STATEMENT: string = 'newPrivacyStatement';
    // Number of SIM cards
    public readonly KEY_OF_SIM_COUNT: string = 'simCount';
    //show name of SIM card 1
    public readonly KEY_OF_SIM_0_ShowName: string = 'simShowName0';
    //show name of SIM card 2
    public readonly KEY_OF_SIM_1_ShowName: string = 'simShowName1';
    // Carrier name of SIM card 1
    public readonly KEY_OF_SIM_0_SPN: string = 'simSpn0';
    // Carrier name of SIM card 2
    public readonly KEY_OF_SIM_1_SPN: string = 'simSpn1';
    // TYPE of slot 0
    public readonly KEY_OF_SLOT_0_TYPE: string = 'slotType0';
    // TYPE of slot 1
    public readonly KEY_OF_SLOT_1_TYPE: string = 'slotType1';
    // index of slot 0
    public readonly KEY_OF_SLOT_0_INDEX: string = 'slotIndex0';
    // index of slot 1
    public readonly KEY_OF_SLOT_1_INDEX: string = 'slotIndex1';
    // index name of slot 0
    public readonly KEY_OF_SLOT_0_INDEX_NAME: string = 'slotIndexName0';
    // index name of slot 1
    public readonly KEY_OF_SLOT_1_INDEX_NAME: string = 'slotIndexName1';
    // Whether SIM card 1 exists
    public readonly KEY_OF_SIM_0_EXIST_FLAG: string = 'simExistFlag0';
    // Whether SIM card 2 exists
    public readonly KEY_OF_SIM_1_EXIST_FLAG: string = 'simExistFlag1';
    // If the SMSC number of SIM card 1 is changed, the new SMSC number is changed.
    public readonly KEY_OF_NEW_SIM_0_SMSC: string = 'newSimSmsc0';
    // If the SMSC number of SIM card 2 is changed, the new SMSC number is changed.
    public readonly KEY_OF_NEW_SIM_1_SMSC: string = 'newSimSmsc1';
    // Mobile number of the SIM card
    public readonly KEY_OF_SIM_0_NUMBER: string = 'sim_0_number';
    public readonly KEY_OF_SIM_1_NUMBER: string = 'sim_1_number';
    public readonly KEY_OF_SELECTED_SLOTID: string = 'selected_slotId';
    public readonly KEY_OF_MAX_SIM_COUNT: string = 'maxSimCount';
    public readonly KEY_OF_HAVE_MULTI_SIM_CARD_READY: string = 'haveMultiSimCardReady';
    public readonly KEY_OF_HAVE_SIM_CARD_READY: string = 'haveSimCardReady';
    public readonly KEY_OF_DEFAULT_SLOT: string = 'defaultSlot';
    // 短信所有的未读数据,每次调用statisticalData函数时,都会保存到首选项中，冷启动时优先从首选项读取缓存值的未读短信数值。
    public readonly KEY_OF_UNREAD_TOTAL: string = 'unreadTotal';
    public readonly KEY_OF_UNREAD_INFO: string = 'unreadInfo';
    // 锁屏过来的短信通知集合
    public readonly KEY_OF_UNLOCK_SCREEN_NOTIFICATION: string = 'unLockedScreenForNotifications';
    // 数据迁移完成事件
    public readonly KEY_DATA_TO_EL5: string = 'smsrdb.event.StoreChanged';
    // 手机关机重启后是否解锁过
    public readonly KEY_OF_FIRST_USER_LOCKED: string = 'userFirstLocked';
    // 手机从未解锁收到短信通知组
    public readonly KEY_OF_MMS_SCREEN_LOCKED_NOTIFICATION_GROUP: string = 'MMS_SCREEN_LOCKED_NOTIFICATION_GROUP';
    /*
        1.用户重刷ROM首次开机且首次启动短信，会创建数据库文件；
        2.该标志位用于标志数据库文件是否创建成功；smsdb datashare helper创建成功即代码创库成功;
        3.创建成功后可以采用静默方式访问短信数据库；
        4.关键字：短信冷启动，性能问题，首页查询。
     * */
    public readonly KEY_OF_SMS_DATABASE_INIT_SUCCESS: string = 'smsDatabaseHasInitSuccess';
    // Events for Subscribing to Notifications     usual.event.SMS_RECEIVE_COMPLETED
    public readonly SUBSCRIBER_EVENT: string = 'usual.event.SMS_RECEIVE_COMPLETED';
    public readonly SUBSCRIBER_MMS_EVENT: string = 'usual.event.SMS_WAPPUSH_RECEIVE_COMPLETED';
    public readonly SUBSCRIBER_RCS_SEND_EVENT: string = 'usual.event.RCS_SEND_STATUS';
    public readonly SUBSCRIBER_RCS_RECV_EVENT: string = 'usual.event.RCS_RECEIVE_STATUS';
    public readonly SUBSCRIBER_FIRST_UNLOCK_EVENT: string = 'usual.event.USER_UNLOCKED';
    // 屏幕解锁公共事件
    public readonly SUBSCRIBER_SCREEN_UNLOCK_EVENT: string = 'usual.event.SCREEN_UNLOCKED';
    // 关机公共事件
    public readonly SUBSCRIBER_SHUTDOWN: string = 'usual.event.SHUTDOWN';
    // 开机公共事件
    public readonly SUBSCRIBER_BOOT_COMPLETED: string = 'usual.event.BOOT_COMPLETED';
    // 首次开机未解锁前收到信息拉起短信的自定义事件
    public readonly SUBSCRIBER_FIRST_LOCK_RECV_EVENT: string = 'usual.event.FIRST_LOCK_RECEIVE_STATUS';
    //read
    public readonly SUBSCRIBER_EVENT_READ: string = 'notification.event.readdata';
    // copy ver code
    public readonly SUBSCRIBER_EVENT_COPYVERCODE: string = 'notification.event.copyvercode';
    // Receiving and forwarding
    public readonly RECEIVE_TRANSMIT_EVENT: string = 'usual.event.RECEIVE_COMPLETED_TRANSMIT';
    // Receiving update event
    public readonly RECEIVE_UPDATE_EVENT: string = 'usual.event.RECEIVE_UPDATE_TRANSMIT';
    // 点击状态栏事件
    public readonly CLICK_STATUSBAR_EVENT: string = 'usual.event.CLICK_STATUSBAR';

    // MMS message receiving event
    public readonly MMS_SUBSCRIBER_EVENT: string = 'usual.event.MMS_RECEIVE_COMPLETED';
    public readonly RCS_SUBSCRIBER_FAIL_EVENT: string = 'usual.event.MMS_RECEIVE_FAIL';
    public readonly RCS_SUBSCRIBER_DELIVERY_EVENT: string = 'usual.event.RCS_DELIVERY_RECEIVE';
    public readonly RCS_SUBSCRIBER_SEND_OK_EVENT: string = 'mms.event.RCS_SEND_OK';
    public readonly RCS_SUBSCRIBER_NEW_SEND_EVENT: string = 'mms.event.RCS_NEW_SEND';
    public readonly RCS_RECEIVE_FILE_OK: string = 'usual.event.RCS_RECEIVE_FILE_OK';
    public readonly RCS_RECEIVE_FILE_CANCEL: string = 'usual.event.RCS_RECEIVE_FILE_CANCEL';
    public readonly RCS_SUBSCRIBER_FAIL_RECEIVE_EVENT: string = 'usual.event.RCS_FAIL_RECEIVE';
    public readonly RCS_SUBSCRIBER_FILE_PROGRESS_EVENT: string = 'mms.event.RCS_PROGRESS_RECEIVE';
    public readonly RCS_SUBSCRIBER_FILE_SEND_CANCELED_EVENT: string =
        'mms.event.RCS_SUBSCRIBER_FILE_SEND_CANCELED_EVENT';

    //chatbot
    public readonly RCS_SUBSCRIBER_CHATBOT_RECEIVED_SUGGESTIONS_EVENT: string =
      'mms.event.CHATBOT_RECEIVED_SUGGESTIONS';
    public readonly RCS_SUBSCRIBER_CHATBOT_CARD_DOWNLOAD_ORIGIN_FILE_DONE: string =
      'mms.event.CHATBOT_CARD_DOWNLOAD_ORIGIN_FILE_DONE';

    // staticSubscriber common event
    public readonly MMS_SUBSCRIBER_COMMON_EVENT: string = 'usual.event.SUBSCRIBER_COMMON_TRANSMIT';
    public readonly RCS_SUBSCRIBER_COMMON_EVENT: string = 'usual.event.RCS_SUBSCRIBER_COMMON_TRANSMIT';

    //Indicates that the system time zone has changed.
    public readonly COMMON_EVENT_TIME_CHANGED: string = 'usual.event.TIME_CHANGED';
    public readonly COMMON_EVENT_TIME_TICK: string = 'usual.event.TIME_TICK';
    public readonly SATELLITE_SUBSCRIBER_CONNECT_EVENT: string = 'event.custom.satellite.ACTION_SATELLITE_CONNECT'

    // Contact database
    public readonly URI_ROW_CONTACTS: string = 'datashare:///com.ohos.contactsdataability';
    // Contact Information
    public readonly CONTACT_DATA_URI: string = '/contacts/contact_data';
    // Calllog database
    public readonly URI_ROW_CALLLOG: string = 'datashare:///com.ohos.calllogability';
    // Contact calls calllog
    public readonly CONTACT_CALLLOG_URI: String = '/calls/calllog';
    // Business Card Contact
    public readonly PROFILE_DATA_URI: string = '/profile/raw_contact';
    // contacted information
    public readonly RAW_CONTACT_URI: string = '/contacts/raw_contact';
    // Querying Contacts
    public readonly CONTACT_SEARCHE: string = '/contacts/search_contact';
    // Contact Information
    public readonly CONTACT_URI: string = '/contacts/contact';
    // SMS database
    public readonly URI_MESSAGE_LOG: string = 'datashare:///com.ohos.smsmmsability';

    // silence database access session
    public readonly URI_SESSION_TABLE_PROXY: string = 'datashareproxy://com.ohos.telephonydataability/telephonydata';

    // silence contact database
    public readonly CONTACT_SILENCE_PROXY: string = 'datashareproxy://com.ohos.contactsdataability/contacts';
    public readonly URI_CONTACT_SILENCE_DATA: string = 'datashareproxy://com.ohos.contactsdataability/contacts/contact_data';
    public readonly URI_RAW_CONTACT_SILENCE_DATA: string = 'datashareproxy://com.ohos.contactsdataability/contacts/raw_contact';


    // sms_mms_info table
    public readonly URI_DELETE_TEMPORARY_DB: string = '/sms_mms/temporary_db';
    public readonly URI_MESSAGE_INFO_TABLE: string = '/sms_mms/sms_mms_info';
    public readonly URI_MESSAGE_INFO_ALL_TABLE: string = '/sms_mms/mms_info';
    public readonly URI_MESSAGE_CHATBOT_ALL_TABLE: string = '/sms_mms/chatbots';
    public readonly URI_SPECIFIC_CHATBOTS : string ='/sms_mms/specific_chatbots';
    // 定向优化查询详情页查询
    public readonly URI_MESSAGE_INFO_ALL_CUSTOMIZED_TABLE: string = '/sms_mms/mms_info_customized';
    public readonly URI_MESSAGE_INFO_SEARCH_INDEX_TABLE: string = '/sms_mms/msg_search_index';
    public readonly URI_MESSAGE_INFO_FAVORATE_TABLE: string = '/sms_mms/favorate_info';
    // rcs info table
    public readonly URI_RCS_MESSAGE_INFO_TABLE: string = '/sms_mms/rcs_info';
    // session table
    public readonly URI_MESSAGE_SESSION_TABLE: string = '/sms_mms/session';
    public readonly URI_MESSAGE_CONVERSION_SESSION: string = '/sms_mms/conversion_session';
    public readonly URI_MESSAGE_CONVERSION_NO_NOTIFY_SESSION: string = '/sms_mms/conversion_no_notify_session';
    // batch mark read
    public readonly URI_MESSAGE_BATCH_MARK_UNREAD: string = '/sms_mms/batch_mark_unread';
    // single mark read
    public readonly URI_MESSAGE_SINGLE_MARK_UNREAD: string = '/sms_mms/single_mark_unread';
    // matched recipient
    public readonly URI_MESSAGE_MATCHED_RECIPIENT: string = '/sms_mms/matched_recipient';
    // pdu for el1
    public readonly URI_MESSAGE_FIRST_UNLOCKED_TABLE: string = '/sms_mms/mms_pdu_lt';
    // pdu for el2
    public readonly URI_MESSAGE_FIRST_UNLOCKED_TABLE2: string = '/sms_mms/mms_pdu';
    // Statistic
    public readonly URI_MESSAGE_UNREAD_COUNT: string = '/sms_mms/sms_mms_info/unread_total';
    public readonly URI_MESSAGE_SELECT_INFO_COUNT: string = '/sms_mms/sms_mms_info/select_info_count';
    public readonly URI_MESSAGE_SELECT_CONTACT_ID: string = '/sms_mms/sms_mms_info/select_contact_id';
    public readonly URI_MESSAGE_DELETE_INVALID_SESSION: string = '/sms_mms/clean_invalid_session';

    public readonly URI_MESSAGE_DELETE_SESSION: string = '/sms_mms/delete_session';
    public readonly URI_MESSAGE_QUERY_MMS_PATHS_WITH_SESSIONIDS: string = '/sms_mms/query_mms_paths_with_sessionIds';
    // Get the largest groupID
    public readonly URI_MESSAGE_MAX_GROUP: string = '/sms_mms/sms_mms_info/max_group';
    // Querying MMS Messages
    public readonly URI_MESSAGE_MMS_PART: string = '/sms_mms/mms_part';
    public readonly AUDIO_NAME: string = 'recording2021111512454545.amr';
    // MMSC
    public readonly SETTING_AIRPLANE_MODE_URI: string = 'datashare:///com.ohos.settingsdata/entry/settingsdata/SETTINGSDATA?Proxy=true';
    public readonly SETTING_BEIDOU_MODE_URI: string = 'datashare:///com.ohos.settingsdata/entry/settingsdata/SETTINGSDATA?Proxy=true&key=is_smc_enabled';
    public readonly ON_SETTING_AIRPLANE_MODE_URI: string = 'datashare:///com.ohos.settingsdata/entry/settingsdata/SETTINGSDATA?Proxy=true&key=airplane_mode';
    public readonly QUERY_AIRPLANE_MODE_KEY: string = 'settings.telephony.airplanemode';

    public readonly SETTING_AI_FACE_CHANGE_MODE_URI: string = 'datashare:///com.ohos.settingsdata/entry/settingsdata/USER_SETTINGSDATA_SECURE_100?Proxy=true';

    //获取无效的数据
    public readonly URI_MESSAGE_INVALID_SESSION_COUNT: string = '/sms_mms/invalid_session';
    public readonly URI_MESSAGE_INVALID_INFO_COUNT: string = '/sms_mms/invalid_info';
    public readonly URI_MESSAGE_INVALID_RCS_INFO_COUNT: string = '/sms_mms/invalid_rcs_info';
    public readonly URI_MESSAGE_INVALID_RCS_INFO_MSG_COUNT: string = '/sms_mms/invalid_rcs_info_with_msg';
    public readonly URI_MESSAGE_INVALID_PART_INFO_COUNT: string = '/sms_mms/invalid_part_info';

    // MMS Retry List.
    public readonly MMS_RETRY_LIST: string = 'mms_retry_list';

    // Controls whether the dialog box is deleted
    public readonly KEY_OF_SHOW_DEL_DIALOG: string = 'is_show_del_dialog';
    public readonly FILE_FD = 'fd://';
    public readonly URI_ROW_NET: string = 'datashare:///com.ohos.pdpprofileability';
    public readonly NET_DATA_URI: string = '/net/pdp_profile?simId=';
    public readonly TIME_OF_LAST_DELETE_NOTIFY_MMS: string = 'last_delete_notification_msg_time';
    // Delete the sandbox resource files that have been deleted from data.
    public readonly DELETE_SANDBOX_FILES_TASK_LIST: string = 'delete_sandbox_files_task_list';
    public readonly DELETE_SANDBOX_FILES_SUB_TASK_PREFIX: string = 'delete_sandbox_files_sub_task_';
    public readonly IS_DELETE_SANDBOX_FILES_TASK_BEING_EXECUTED: string = 'is_delete_sandbox_files_task_being_execute';
    //The device is a mobile phone
    public readonly DEVICE_MOBILE_PHONE: string = 'sm';
    // The equipment is a folding machine
    public readonly DEVICE_Folding_SCREEN: string = 'md';
    // The device is a tablet
    public readonly DEVICE_FLAT_PLATE: string = 'lg';
    // The ellipsis.
    public readonly ELLIPSIS_STR: string = '…';
    // Em tag for search
    public readonly EM_TAG_START: string = '<em>';
    public readonly EM_TAG_END: string = '</em>';
    // The of last contact update time.
    public readonly KEY_OF_LAST_CONTACT_UPDATE_TIME: string = 'last_contact_update_time';
    // Blocked or access information.
    public readonly BLOCKED_ACCESS: string = '/contacts/contact_blocklist';
    // YellowPage DataBase
    public readonly URI_YELLOW_PAGE: string = 'datashare:///com.ohos.numbermarkability';
    // yellow_page_view table
    public readonly URI_YELLOW_PAGE_INFO_ALL: string = '/yellow_page_view';
    // risk url record table
    public readonly URI_MESSAGE_RISK_URL_RECORD_TABLE: string = '/sms_mms/risk_url_record';
    // Malicious URL switch on
    public readonly MALICIOUS_URL_SWITCH_ON: string = '1';
    public readonly UNIT_COMMON_VP: string = 'vp';
    public readonly BUBBLE_TEXT_DIRECTION: string = 'left';
    public readonly NUMBER_IDENTITY_SEITCH: string = 'settings.telephony.number_identity_switch';
    //短信状态变化，数据库通知应用
    public readonly SMS_MMS_SENT_RESULT_NOTIFY: string = 'SMS_MMS_SENT_RESULT_NOTIFY';
    //通话应用发送短信，短信直接入库，通知短信应用刷新首页列表
    public readonly MESSAGE_STATUS_CHANGE_NOTIFY: string = 'MESSAGE_STATUS_CHANGE_NOTIFY';
    // telephone last for digit.
    public readonly TELEPHONE_REPLACE_PART: string = '****';
    /**
     * Distributed scene
     1_sink：分机，状态是连接
     0_sink：分机，状态是未连接
     1_source：主机，状态是连接
     0_source：主机，状态是未连接
     */
    public readonly ONLY_RECEIVE_NOT_SEND: string = 'persist.distributed_scene.datafiles_trans_ctrl';
    public readonly KEY_OF_DISTRIBUTED_MODEM_STATE: string = 'distributed_modem_state';
    public readonly DISTRIBUTED_CALL_SMS_SHARING: string = 'distributed_call_sms_sharing';
    public readonly SUB_DEVICE: string = 'sink';
    public readonly SUB_DEVICE_WITH_UNCONNECTED: string = '0_sink';
    public readonly SUB_DEVICE_WITH_CONNECTED: string = '1_sink';
    public readonly MAIN_DEVICE: string = 'source';
    public readonly MAIN_DEVICE_WITH_UNCONNECTED: string = '0_source';
    public readonly MAIN_DEVICE_WITH_CONNECTED: string = '1_source';
    public readonly HAS_LIST: string = 'hasList';
    public readonly NO_LIST: string = 'noList';
    public readonly CREATE_NEW_CONVERSATION_FROM_RECORD: string = 'isFromRecord';

    public readonly RCS_CURRENT_NET_DNS_ADDRESS_LIST = 'RCS_CURRENT_NET_DNS_ADDRESS_LIST';

    // 从会话详情返回通知列表
    public readonly BACK_FROM_CONVERSATION: string = 'backFromConversation';

    public readonly RCS_IMAGE_TYPE = ['image/jpeg', 'image/png', 'image/gif', 'image/bmp', 'image/jpg'];
    /**
     *  code constraint.distributed.transmission.outgoing -发送和接收短信约束。
     */
    public readonly CONSTRAINT_DISTRIBUTED_TRANSMISSION_OUTGOING = 'constraint.distributed.transmission.outgoing';
    // 拖拽加入输入图片文件名前缀
    public readonly DRAG_IMG_PREFIX = 'DRAG_IMG_';
    // 拉起相册图库加入附件区文件名前缀
    public readonly GALLERY_PREFIX = 'Origin_GALLERY_';
    // 拉起相机拍摄加入附件区文件名前缀
    public readonly CAMERA_PREFIX = 'Origin_CAMERA_';
    // 录音文件名前缀
    public readonly RECORDING_PREFIX = 'recording_';
}

class DELIVERY_REPORTS {
    // Closed
    public readonly DISABLED: string = '0';
    // SMS
    public readonly SMS: string = '1';
    // MMS
    public readonly MMS: string = '2';
    // SMS and MMS
    public readonly SMS_AND_MMS: string = '3';
}

class SPN_CHINA {
    // TELECOM
    public readonly TELECOM: string = '中国电信';
    // MOBILE
    public readonly MOBILE: string = 'CMCC';
    // UNICOM
    public readonly UNICOM: string = 'China Unicom';
    // BROADNET
    public readonly BROADNET: string = '中国广电';
}

class SPN_NUMERIC {
    public readonly BROADNET: string = '46015';
}

class AUTO_RETRIEVE_MMS {
    // OFF
    public readonly OFF: string = '0';
    // Non-roaming
    public readonly NOT_WHEN_ROAMING: string = '1';
    // All networks
    public readonly ALWAYS: string = '2';

    public readonly NOT_SET = '-1';
}

class MESSAGE_SHOW_TYPE {
    // Common SM style
    public readonly NORMAL: number = 0;
    // Does not contain the picture theme style
    public readonly THEME_NO_IMAGE: number = 1;
    // Does not include picture slide styles
    public readonly PPT_NO_IMAGE: number = 2;
    // Slideshow Styles with Pictures
    public readonly PPT_IMAGE: number = 3;
    // Include Image Theme Styles
    public readonly THEME_IMAGE: number = 4;
    // Display in the form of a MMS location card
    public readonly MAP: number = 5;
}

class VdeBlockedExistence {
    public readonly DEFAULT: number = -1;
    public readonly HAVE_DATA: number = 1;
    public readonly NO_DATA: number = 0;
}

class contactPage {
    // Go to New Contact
    public readonly PAGE_FLAG_SAVE_CONTACT: string = 'page_flag_save_contact';
    // Edit Before Call
    public readonly PAGE_FLAG_EDIT_BEFORE_CALLING: string = 'page_flag_edit_before_calling';
    // Save to Existing Contacts
    public readonly PAGE_FLAG_SAVE_EXIST_CONTACT: string = 'page_flag_save_exist_contact';
    // The page for selecting a contact is displayed after an SMS message is sent.
    public readonly PAGE_FLAG_SINGLE_CHOOSE: string = 'page_flag_single_choose';
    // Select Contact List Page
    public readonly PAGE_FLAG_CHOOSE_CONTACTS: string = 'page_flag_choose_contacts';
    // Contact details page
    public readonly PAGE_FLAG_CONTACT_DETAILS: string = 'page_flag_contact_details';
    // The My Business Card page is displayed.
    public readonly PAGE_FLAG_CALLING_CARD: string = 'page_flag_card_details';
    // Querying MMS Data
    public readonly URI_MESSAGE_MMS_PART: string = '/sms_mms/mms_part';
    // The page for selecting multi contact
    public readonly PAGE_FLAG_MULTI_CHOOSE: string = 'page_flag_multi_choose';
}

class MESSAGE_TAB_INDEX {
    public readonly TAB_CAMERA: number = 0;
    public readonly TAB_PICTURE: number = 1;
    public readonly TAB_AUDIO: number = 2;
    public readonly TAB_MORE: number = 3;
}

class HIGHLIGHT_TYPE {
    // Common data
    public readonly NORMAL: number = 0;
    // email
    public readonly EMAIL: number = 1;
    // Website
    public readonly URL: number = 2;
    // Telephone
    public readonly TEL: number = 3;
    // Time
    public readonly DATE: number = 4;
    // Verification Code
    public readonly NUM: number = 5;
}

class MSG_ITEM_TYPE {
    public readonly THEME: number = 0;
    public readonly IMAGE: number = 1;
    public readonly VIDEO: number = 2;
    public readonly AUDIO: number = 3;
    public readonly TEXT: number = 4;
    public readonly CARD: number = 5;
}

class TRANSMIT_ITEM_HEIGHT {
    public readonly TEXT_HEIGHT: number = 150;
    public readonly THEME_HEIGHT: number = 200;
    public readonly THEME_IMAGE_HEIGHT: number = 300;
    public readonly PPT_IMAGE_HEIGHT: number = 220;
    public readonly DISTANCE: number = 20;
    public readonly TOTAL_HEIGHT: number = 650;
}


/**
 * rcs的消息类型： 0 文本; 1 图片; 2 视频; 3 语音; 4 联系人卡片; 5和6暂未使用; 8 文件消息; 9 音频消息; 10 位置消息; 11 rcs应用号卡片;
 * 12 rcs应用号卡片的视频富媒体缩略图文件
 */
class ENHANCED_INFO_ITEM_TYPE {//same as MM_ATTACHMENT_TYPE except Text 0
    public readonly TEXT: number = 0;
    public readonly IMAGE: number = 1;
    public readonly VIDEO: number = 2;
    public readonly AUDIO: number = 3;
    public readonly VCARD: number = 4;
    public readonly THEME: number = 5;
    public readonly SLIDE: number = 6;
    public readonly FILE: number = 8;
    public readonly AUDIO_FILE: number = 9;
    public readonly MAP: number = 10;
    public readonly CHATBOT_CARD: number = 11;
    public readonly VIDEO_THUMBNAIL: number = 12;
}

class UeMsgSendType {
    public readonly FAILED: number = -1; // 发送失败
    public readonly RETURN: number = 0; // 业务上中断
    public readonly SUCCESS: number = 1; // 发送成功
    public readonly SENDING: number = 2; // 发送中
}

class UeMsgType {
    public readonly SMS: number = 0; // 短信
    public readonly RCS: number = 1; // 增强信息
    public readonly MMS: number = 2; // 彩信
}

class UeMsgContent {
    public readonly TEXT: number = 1; // 文本
    public readonly IMAGE: number = 2; // 图片
    public readonly VIDEO: number = 3; // 视频
    public readonly VCARD: number = 4; // VCard
    public readonly AUDIO: number = 5; // 录音
    public readonly SLIDE: number = 6; // 幻灯片彩信only
    public readonly MAP: number = 7; // 位置
    public readonly THEME: number = 8; // 主题(文字+图片、彩信only)
    public readonly AUDIO_FILE: number = 9; // 音乐文件
    public readonly FILE: number = 10; // 文件
    public readonly CHATBOT_CARD: number = 11; // rcs应用号卡片
    public readonly VIDEO_THUMBNAIL: number = 12; // rcs应用号卡片的视频富媒体缩略图文件
}

class RCS_SEND_MSG {
    public readonly TEXT: number = 0;
    public readonly IMAGE: number = 1;
    public readonly VIDEO: number = 2;
    public readonly MAP: number = 3;
    public readonly VCARD: number = 4;
    public readonly THEME: number = 5;
    public readonly AUDIO: number = 6;
    public readonly FILE: number = 7;
}

/**
 * 骚扰拦截页面类型
 */
class BlockedPageType {
    /**
     * 初始页面
     */
    public readonly DEFAULT: number = -1;
    /**
     * 骚扰拦截设置页面
     */
    public readonly SETTING_PAGE: number = 0;
    /**
     * 骚扰拦截信息列表页面
     */
    public readonly LIST_PAGE: number = 1;
}

/**
 * 查询信息表结果
 */
export class SmsRcsInfo {
    /**
     * 信息id（sms、rcs）
     */
    public msgId: number = -1;
    /**
     * 信息是否被收藏
     */
    public isCollect: number = -1;
}

/**
 * 删除mmsPart表信息
 */
export class SmsGroupRcsInfo {
    /**
     * 信息id（sms groupId、rcs id）
     */
    public msgId: number = -1;
    /**
     * 信息是否被收藏
     */
    public isCollect: number = -1;
    /**
     * 是否需要删除资源文件
     */
    public isNeedDeleteFile: boolean = false;
}

class EnhancedInfoRichMediaTypeInRCSService {
    public readonly IMAGE: number = 0;
    public readonly AUDIO: number = 1;
    public readonly VIDEO: number = 2;
    public readonly FILE: number = 3;
    public readonly AUDIO_FILE: number = 3;
    public readonly VCARD: number = 4;
}

class RUN_IN_WORKER_METHOD {
    // Contacts
    public readonly queryContactDataByCondition: string = 'queryContactDataByCondition';
    public readonly queryContactDataSizeByCondition: string = 'queryContactDataSizeByCondition';
    public readonly queryContactByCondition: string = 'queryContactByCondition';
    public readonly queryContactSizeByCondition: string = 'queryContactSizeByCondition';
    public readonly queryRawContactSizeByCondition: string = 'queryRawContactSizeByCondition';
    public readonly queryContactViewByCondition: string = 'queryContactViewByCondition';
    public readonly queryRecentContactByRow: string = 'queryRecentContactByRow';
    public readonly queryCallLogByCondition: string = 'queryCallLogByCondition';
    // detail
    public readonly insertSmsMmsInfo: string = 'insertSmsMmsInfo';
    public readonly insertRcsMmsInfo: string = 'insertRcsMmsInfo';
    public readonly insertAccessInfo: string = 'insertAccessInfo';
    public readonly deleteSmsMmsInfoByCondition: string = 'deleteSmsMmsInfoByCondition';
    public readonly deleteRcsInfoByCondition: string = 'deleteRcsInfoByCondition';
    public readonly deleteBlockedRcsInfoByCondition: string = 'deleteBlockedRcsInfoByCondition';
    public readonly deleteBlockedSmsInfoByCondition: string = 'deleteBlockedSmsInfoByCondition';
    public readonly deleteBlockedMmsInfoByCondition: string = 'deleteBlockedMmsInfoByCondition';
    public readonly deleteBlockInfoByCondition: string = 'deleteBlockInfoByCondition';
    public readonly updateBlockedSmsInfoByCondition: string = 'updateBlockedSmsInfoByCondition';
    public readonly updateBlockedRcsInfoByCondition: string = 'updateBlockedRcsInfoByCondition';
    public readonly updateAccessInfoByCondition: string = 'updateAccessInfoByCondition';
    public readonly updateSmsMmsInfoByCondition: string = 'updateSmsMmsInfoByCondition';
    public readonly updateRcsMmsInfoByCondition: string = 'updateRcsMmsInfoByCondition';
    public readonly updateRcsMmsInfoMarkRead: string = 'updateRcsMmsInfoMarkRead';
    public readonly updateRcsReceivedMmsInfoByRcsId: string = 'updateRcsReceivedMmsInfoByRcsId';
    public readonly updateRcsServiceKindMsgCodeByRcsId: string = 'updateRcsServiceKindMsgCodeByRcsId';
    public readonly querySmsMmsInfoByCondition: string = 'querySmsMmsInfoByCondition';
    public readonly querySmsMmsInfoByConditionAll: string = 'querySmsMmsInfoByConditionAll';
    public readonly querySmsMmsSearchIndexByCondition: string = 'querySmsMmsSearchIndexByCondition';
    public readonly queryMmsInfoByFavoriteCondition: string = 'queryMmsInfoByFavoriteCondition';
    public readonly queryMmsInfoLastReadCondition: string = 'queryMmsInfoFirstMsgCondition';
    public readonly queryAllInfoByFavoriteCondition: string = 'queryAllInfoByFavoriteCondition';
    public readonly queryAccessAllInfoByCondition: string = 'queryAccessAllInfoByCondition';
    public readonly queryFavoriteAllInfoByCondition: string = 'queryFavoriteAllInfoByCondition';
    // Block
    public readonly queryBlockedAllInfoByCondition: string = 'queryBlockedAllInfoByCondition';
    public readonly queryBlockedFromSmsInfo: string = 'queryBlockedFromSmsInfo';
    public readonly queryBlockedFromRcsInfo: string = 'queryBlockedFromRcsInfo';
    public readonly queryBlockedMmsInfoByCondition: string = 'queryBlockedMmsInfoByCondition';
    public readonly queryBlockedInfoByPhoneNumberCondition: string = 'queryBlockedInfoByPhoneNumberCondition';
    public readonly queryBlockedInfoByBatchPhoneNumberCondition: string = 'queryBlockedInfoByBatchPhoneNumberCondition';
    public readonly queryBlockedInfoByPrefPhoneNumber: string = 'queryBlockedInfoByPrefPhoneNumber';
    public readonly queryContactBlockList: string = 'queryContactBlockList';
    public readonly queryContactBlockListByPrefPhoneNumber: string = 'queryContactBlockListByPrefPhoneNumber';

    // YellowPage
    public readonly queryYellowPageInfoByCondition: string = 'queryYellowPageInfoByCondition';
    public readonly queryYellowPageListInfoByCondition: string = 'queryYellowPageListInfoByCondition';

    public readonly queryRcsInfoByCondition: string = 'queryRcsInfoByCondition';
    public readonly querySmsMmsInfoSlotIdByCondition: string = 'querySmsMmsInfoSlotIdByCondition';
    public readonly queryRcsInfoSlotIdByCondition: string = 'queryRcsInfoSlotIdByCondition';
    public readonly querySmsMmsInfoSizeByCondition: string = 'querySmsMmsInfoSizeByCondition';
    public readonly queryRcsInfoSizeByCondition: string = 'queryRcsInfoSizeByCondition';
    public readonly queryRcsIdByMsgId: string = 'queryRcsIdByMsgId';
    public readonly queryMaxGroupId: string = 'queryMaxGroupId';
    public readonly queryMaxGroupIdRcs: string = 'queryMaxGroupIdRcs';
    public readonly queryMaxGroupIdInMmsInfoTable = 'queryMaxGroupIdInMmsInfoTable';
    public readonly statisticalData: string = 'statisticalData';
    public readonly selectInfoCount: string = 'selectInfoCount';
    public readonly selectContactId: string = 'selectContactId';
    public readonly insertMmsInfo: string = 'insertMmsInfo';
    public readonly queryMmsInfo: string = 'queryMmsInfo';
    public readonly queryMmsPartInfo: string = 'queryMmsPartInfo';
    public readonly updateMmsPartById: string = 'updateMmsPartById';
    public readonly deleteMmsInfoByCondition: string = 'deleteMmsInfoByCondition';
    public readonly updateSessionUnReadBySessionId: string = 'updateSessionUnReadBySessionId';
    public readonly processMarkRead: string = 'processMarkRead';
    public readonly updateSmsIsReadBySessionId: string = 'updateSmsIsReadBySessionId';
    public readonly updateRcsIsReadBySessionId: string = 'updateRcsIsReadBySessionId';
    public readonly batchUpdateSessionByCondition: string = 'batchUpdateSessionByCondition';
    public readonly updateSmsInfoSmsTypeBySessionIds: string = 'updateSmsInfoSmsTypeBySessionIds';
    public readonly updateRcsInfoIsSenderBySessionIds: string = 'updateRcsInfoIsSenderBySessionIds';
    // list
    public readonly insertSession: string = 'insertSession';
    public readonly deleteSessionByCondition: string = 'deleteSessionByCondition';
    public readonly deleteSessionSlice: string = 'deleteSessionSlice';
    public readonly queryMmsPartPathBySessionIds: string = 'queryMmsPartPathBySessionIds';
    public readonly updateSessionByCondition: string = 'updateSessionByCondition';
    public readonly fetchRecentContactsAndBatchUpdateSession: string = 'fetchRecentContactsAndBatchUpdateSession';
    public readonly fetchDeleteContactsAndUpdateSession: string = 'fetchDeleteContactsAndUpdateSession';
    public readonly querySessionByCondition: string = 'querySessionByCondition';
    public readonly queryMatchedRecipient: string = 'queryMatchedRecipient';
    public readonly querySessionResultByCondition: string = 'querySessionResultByCondition';
    public readonly querySessionSizeByCondition: string = 'querySessionSizeByCondition';
    public readonly markAsReadFromReceive: string = 'markAsReadFromReceive';
    public readonly markAsReadFromReceiveRcs: string = 'markAsReadFromReceiveRcs';
    public readonly queryNetInfo: string = 'queryNetInfo';
    public readonly queryMmsNotDownloadInfo: string = 'queryMmsNotDownloadInfo';
    public readonly querySessionId: string = 'querySessionId';
    public readonly updateAttachmentByCondition: string = 'updateAttachmentByCondition';
    public readonly updateSessionPinningTimeBySessionId: string = 'updateSessionPinningTimeBySessionId';
    public readonly updateSessionBySessionId: string = 'updateSessionBySessionId';
    // Satellite
    public readonly queryLocationData: string = 'queryLocationData';
    public readonly queryNumberData: string = 'queryNumberData';
    //Chatbot
    public readonly updateRecentUstTime: string = 'updateRecentUstTime';
    // Chatbot Permissions
    public readonly updateChatbotPermissions: string = 'updateChatbotPermissions';
    public readonly queryChatbotPermissions: string = 'queryChatbotPermissions';
    public readonly updateSessionAfterRequestChatbot = 'updateSessionAfterRequestChatbotFromService';
}

class is_read {
    public readonly UN_READ: number = 0;
    public readonly READ: number = 1;
}

class sms_type {
    public readonly COMMON: number = 0;
    public readonly NOTICE: number = 1;
    public readonly RCS: number = 99;
}

class DeleteMessage {
    //0全选删除
    public readonly DELETEALL: number = 0;
    //1删除除选中外的
    public readonly DELETEUNCHECK: number = 1;
    //2删除选中的
    public readonly DELETECHECK: number = 2;
}

class session_type {
    public readonly COMMON: number = 0;
    public readonly BROADCAST: number = 1;
    public readonly GROUP_SEND: number = 2;
}

class is_lock {
    public readonly NO: number = 0;
    public readonly YES: number = 1;
}

class is_report {
    public readonly NO_REPORT: number = 0;
    public readonly REPORT: number = 1;
}

class is_collect {
    public readonly NOT_FAVORITE: number = 0;
    public readonly FAVORITE: number = 1;
}

class ReferenceCount {
    /**
     * mms_part 表引用计数字段，历史数据默认值
     */
    public readonly DEFAULT: number = -1;
    /**
     * mms_part 表引用计数字段，对应的信息详情数据未被收藏、或已收藏但原信息已被删除
     */
    public readonly ONE: number = 1;
    /**
     * mms_part 表引用计数字段，对应的信息详情数据已被收藏同时原信息未被删除
     */
    public readonly TWO: number = 2;
}

class IsBlocked {
    public readonly NOT_BLOCKED: number = 0;
    public readonly BLOCKED: number = 1;
}

class BlockedType {
    public readonly ACCESS: number = 1;
    public readonly BLOCK: number = 0;
    public readonly PREF_BLOCK: number = 2;
}


class IsSmartType {
    // 智能信息方识别为验证码短信
    public readonly IS_VER: number = 1;
    // 智能信息方识无法识别短信内容
    public readonly OTHER: number = -1;
}

class is_send_report {
    public readonly NO: number = 0;
    public readonly YES: number = 1;
}

class is_sender {
    public readonly NO: number = 0;
    public readonly YES: number = 1;
}

class has_draft {
    public readonly NO: number = 0;
    public readonly HAVE: number = 1;
    public readonly HAVE_ON_DISPLAY: number = 2;
}

class has_mms {
    public readonly NO: number = 0;
    public readonly HAVE: number = 1;
}

class has_attachment {
    public readonly NO: number = 0;
    public readonly HAVE: number = 1;
}

class FIRST_NAME_TYPE {
    // The initial letter of the SMS name is not a character
    public readonly NOT_CHARACTER: string = '-1';
    // Group sms
    public readonly GROUP_SMS: string = '-2';
}

class recent_contacts {
    public readonly type: string = 'recent_contacts';
    public readonly rawType: string = 'raw_recent_contacts';
    public readonly rowId: string = 'raw_contact_id';
    public readonly sortKey: string = 'contacted_count';
    public readonly sortSecondEY: string = 'lastest_contacted_time';
    public readonly isDeleted: string = 'is_deleted';
}

class MM_ATTACHMENT_TYPE {
    public readonly MMS_NOT_DOWNLOAD = -1;
    public readonly SMIL: number = 0;
    public readonly IMAGE: number = 1;
    public readonly VIDEO: number = 2;
    public readonly AUDIO: number = 3;
    public readonly VCARD: number = 4;
    public readonly THEME: number = 5;
    public readonly SLIDE: number = 6;
    public readonly TEXT: number = 7;
    public readonly MAP: number = 8;
}

class MMSelectAttachmentType {
    public readonly CAMERA: number = 0;
    public readonly GALLERY: number = 1;
    public readonly RECORD: number = 2;
    public readonly CONTACT: number = 3;
    public readonly MAP: number = 4;
}

class MMS_CONTENT_TYPE {
    // Output as is
    public readonly ORIGIN: number = 0;
    // Slideshow with pictures
    public readonly SLIDE_CONTAINS_IMAGE: number = 1;
    // Slideshow without pictures
    public readonly SLIDE_NO_IMAGE: number = 2;
    // vCard
    public readonly VCARD: number = 3;
    // file
    public readonly FILE: number = 4;
}

class PhoneNumberType {
    public readonly CELL: string = 'CELL';
    public readonly HOME: string = 'HOME';
    public readonly WORK: string = 'WORK';
    public readonly WORK_FAX: string = 'WORK;FAX';
    public readonly HOME_FAX: string = 'HOME;FAX';
    public readonly PAGER: string = 'PAGER';
    public readonly VOICE: string = 'VOICE';
    public readonly PREF: string = 'PREF';
}

class MSG_TYPE {
    // General Information
    public readonly NORMAL: number = 0;
    // MMS
    public readonly MMS: number = 1;
}

class MEDIA_STATUS {
    public readonly IDLE: string = 'idle';
    public readonly INITIALIZED: string = 'initialized';
    public readonly PREPARED: string = 'prepared';
    public readonly PLAYING: string = 'playing';
    public readonly PAUSED: string = 'paused';
    public readonly COMPLETED: string = 'completed';
    public readonly STOPPED: string = 'stopped';
    public readonly RELEASED: string = 'released';
    public readonly STARTED: string = 'started';
    public readonly ERROR: string = 'error';
}

class MEDIA_PARAMETER {
    public readonly AUDIO_BITRATE: number = 16000;
    public readonly AUDIO_CHANNELS: number = 1;
    public readonly AUDIO_SAMPLE_RATE: number = 32000;
    public readonly VIDEO_BITRATE: number = 16000;
    public readonly VIDEO_FRAME_WIDTH: number = 320;
    public readonly VIDEO_FRAME_HEIGHT: number = 240;
    public readonly VIDEO_FRAME_RATE: number = 15;
}

class TAB_TYPE {
    public readonly CAMERA: number = 0;
    public readonly PICTURE: number = 1;
    public readonly AUDIO: number = 2;
    public readonly MAP: number = 3;
}

class RCS_RECEIVE_TYPE{
    public readonly TEXT_RCS_RECEIVE: string = 'TEXT_RCS_RECEIVE';
    public readonly TEXT_RCS_READ_RECEIVE: string = 'TEXT_RCS_READ_RECEIVE';
    public readonly TEXT_RCS_DELIVERY_RECEIVE: string = 'TEXT_RCS_DELIVERY_RECEIVE';
    public readonly TEXT_RCS_FAIL_RECEIVE: string = 'TEXT_RCS_FAIL_RECEIVE';
    public readonly RCS_FILE_RECEIVE: string = 'RCS_FILE_RECEIVE';
    public readonly RCS_RECEIVE_LOCATION_MESSAGE: string = 'RCS_RECEIVE_LOCATION_MESSAGE';
    public readonly RCS_RECEIVE_FILE_MESSAGE: string = 'RCS_RECEIVE_FILE_MESSAGE';
    public readonly RCS_RECEIVE_FILE_SUCCESS: string = 'RCS_RECEIVE_FILE_SUCCESS';
    public readonly RCS_RECEIVE_FILE_CANCEL: string = 'RCS_RECEIVE_FILE_CANCEL';
    public readonly RCS_RECEIVE_FILE_FAILED: string = 'RCS_RECEIVE_FILE_FAILED';
    public readonly RCS_FILE_SEND_OK_RECEIVE: string = 'RCS_SEND_FILE_SUSSESS';
    public readonly TEXT_RCS_SEND_OK_RECEIVE: string = 'TEXT_RCS_SEND_OK_RECEIVE';
    public readonly RCS_FILE_SEND_FAILED_RECEIVE: string = 'RCS_SEND_FILE_FAILED';
    public readonly FILE_RCS_PROGRESS: string = 'RCS_SEND_FILE_PROGRESS';
    public readonly RCS_SEND_FILE_CANCELED: string = 'RCS_SEND_FILE_CANCEL';
    public readonly RCS_RECEIVE_FILE_PROGRESS: string = 'RCS_RECEIVE_FILE_PROGRESS';
    public readonly RCS_LOCATION_RECEIVE: string = 'RCS_LOCATION_RECEIVE';
    public readonly RCS_CHATBOT_RECEIVE: string = 'TEXT_RCS_CHATBOT_RECEIVE';
    // chatbot message
    /** 普通文本消息|suggestions列表|chatbot卡片 */
    public readonly TEXT_RCS_CHATBOT_RECEIVE = 'TEXT_RCS_CHATBOT_RECEIVE';
    /** 文件消息，包括语音、图片、txt文件、vCard、音频文件 */
    public readonly TEXT_RCS_FILE_CHATBOT_RECEIVE = 'TEXT_RCS_FILE_CHATBOT_RECEIVE';
    /** 位置消息 */
    public readonly TEXT_RCS_LOCATION_CHATBOT_RECEIVE = 'TEXT_RCS_LOCATION_CHATBOT_RECEIVE';
}

class RcsChatBotType {
    public readonly RCS_CHATBOT_RECEIVE_TEXT:number = 0;
}

class TEXT_RECEIVE_TYPE{
    public readonly TEXT_SMS_RECEIVE:string='DATA_SMS_RECEIVE'
}

class RCS_TYPE{
    public readonly RCS: string = 'rcs';
    public readonly RCS_SEND: string = 'rcs_send';
    public readonly MMS_SEND: string = 'mms_send';
}

class MMS_AUDIO_STATUS {
    public readonly NO_AUDIO: number = -1;
    public readonly HAS_AUDIO: number = 0;
    public readonly ONLY_AUDIO: number = 1;
}

class TRANSMIT_MSG_STATUS {
    public readonly NO_MMS: number = 0;
    public readonly ALL_MMS: number = 1;
    public readonly HAS_MMS_SMS: number = 2;
    public readonly THIRD_PART_MMS: number = 3;
    public readonly SHARE_MMS: number = 4;
    public readonly SHARE_SMS: number = 5;
}

class THIRD_PART_URI {
    public readonly SMS_TO: string = 'smsto:';
    public readonly SMS: string = 'sms:';
}

class DeepLinkUrl {
    public readonly SMS_TO: string = 'smsto:';
    public readonly SMS: string = 'sms:';
}

class ADVANCED_SECURITY_MODE {
    public readonly ORDINARY: number = 0;
    public readonly ADVANCED_SE: number = 1;
}

class MESSAGE_TYPE {
    public readonly SMS_OR_MMS: number = 0;
    public readonly RCS: number = 1;
}

class AudioRecorderErrorCode {
    // The microphone is occupied.
    public readonly MICROPHONE_IN_USE: number = 5400102;
    // Recording failure due to other reasons
    public readonly RECORDER_ERROR: number = 5400103;
    // message is Record failed by audio interrupt
    public readonly AUDIO_INTERRUPT: number = 5400107;
}

class PromptToast {
    public readonly DURATION: number = 2000;
}

class MessageHomeDelete {
    public readonly MAX_HEAD_ANGLE: number = 17;
    public readonly MAX_BODY_ANGLE: number = 10;
    public readonly DELETE_SWIPE_HEAD_WIDTH: number = 64;
    public readonly DELETE_SWIPE_BODY_WIDTH: number = 120;
    public readonly DELETE_SWIPE_HEAD_TWOBUTTON_WIDTH: number = 166;
    public readonly DELETE_SWIPE_BODY_TWOBUTTON_WIDTH: number = 224;
    public readonly ANGLE_RADIO: number = 12;
    public readonly ACTION_AREA_DISTANCE: number = 56;
    public readonly MAX_SCALE_RATIO: number = 1.1;
}

class VibrationEffect {
    public readonly LIGHT = 'haptic.slide.light';
    public readonly LONG_PRESS_LIGHT = 'haptic.long_press_light';
    public readonly DRAG = 'haptic.drag';
    public readonly HEAVY = 'haptic.long_press.heavy';
    public readonly LONG_PRESS_MEDIUM = 'haptic.long_press_medium';
    public readonly THRESHOLD = 'haptic.threshold';
    public readonly DELETE_LONG_PRESS = 'haptic.delete_long_press';
    public readonly DELETE_LONG_PRESS_DOUBLE = 'haptic.common.delete_long_press';
}

class MsgDataStatus {
    public readonly DEFAULT: string = '1';
    public readonly MSG_NO_EMPTY: string = '2';
    public readonly MSG_EMPTY: string = '3';
}

export enum MarkRead {
    single = 1,
    allInfo = 2,
    all = 3
}

/*
 * 用来定义GlobalContext的key值
 * */
export class GlobalContextKey {
    /*
     * 1. 应用冷启动时：true
     * 2. 查询首页数据之后：false
     * 3. 关键字：冷启动，性能，首屏数据查询
     * */
    public static readonly QUERY_FIRST_PAGE_ON_COLD_START_UP: string = 'QUERY_FIRST_PAGE_ON_COLD_START_UP'

    public static readonly QUERY_CONTACT_DATA_ON_COLD_START_UP: string = 'QUERY_CONTACT_DATA_ON_COLD_START_UP'

    /*
     * 是否跳转至文件预览
     * 1. 默认/刚进入详情：false
     * 2. 进入图片、视频预览：true
     * */
    public static readonly IS_JUMP_TO_PREVIEW: string = 'IS_JUMP_TO_PREVIEW'
}
export class NotificationLocal {
    public readonly NOTIFICATION_LOCAL_SCREEN_CHANGE: 'change' = 'change'
}

export class SecurityEventId {
    public readonly IS_VER_CODE: number = 0x009001000;
    public readonly RISK_URL: number = 0x009001001;
    public readonly OPEN_SPAM_SMS: number = 0x009001002;
}

export class WebviewPageMenuId {
    public readonly REPORT_ID: number = 1;
    public readonly SHARE_ID: number = 2;
    public readonly SERVICE_KIND: number = 8;
    public readonly DEVICE_SHARE_SERVICE_KIND: number = 9;
    public readonly TIME_ZONE_TIME = 28800000;
    public readonly MAP_ZOOM: number = 16;
    public readonly SHARE_DEVICE_INFO: number = 1;
    public readonly SHARE_GEOGRAPHY_LOCATION: number = 2;
    public readonly SHARE_DEVICE_AND_LOCATION: number = 3;
}

export class SlideActionType {
    public readonly START: string = 'onActionStart';
    public readonly UPDATE: string = 'onActionUpdate';
    public readonly END: string = 'onActionEnd';
}
/**
 * 增強信息入口Enum
 */
export class RcsFromType {
    public readonly CHATBOT_PAGE: string = 'chatbot_page';
    public readonly RCS_CHATBOT_PAGE: string = 'rcs_chatbot_page';
}

export class ServiceCenter {
    // 单的IP消息
    public readonly PUSH_OHOS_A2P: string = 'push.ohos.a2p';
    // 双的IP消息
    public readonly PUSH_A2P: string = 'push.a2p';
}

/**
 * sim卡类型
 */
export class SimType {
    public readonly PSIM: number = 0;
    public readonly ESIM: number = 1;
}

export class MmsMapConstant {
  /** 地图的缩放级别 */
  public readonly MAP_ZOOM: number = 15;
  /** 比例 */
  public readonly SCALE: number = 2;
  /** 图片的宽度 */
  public readonly IMAGE_WIDTH: number = 450;
  /** 图片宽高比 */
  public readonly ASPECT_RATIO: number = 16 / 9;
}

class commonData {

    public bool = new bool();

    public switch = new SwitchStatus();

    public route = new route();

    public int = new int();

    public STR = new STR();

    public DELIVERY_REPORTS = new DELIVERY_REPORTS();

    public AUTO_RETRIEVE_MMS = new AUTO_RETRIEVE_MMS();

    public SPN_CHINA = new SPN_CHINA();

    public SPN_NUMERIC = new SPN_NUMERIC();

    public contactPage = new contactPage();

    public MESSAGE_TAB_INDEX = new MESSAGE_TAB_INDEX();

    public HIGHLIGHT_TYPE = new HIGHLIGHT_TYPE();

    public MESSAGE_SHOW_TYPE = new MESSAGE_SHOW_TYPE();

    public MSG_ITEM_TYPE = new MSG_ITEM_TYPE();

    public ENHANCED_INFO_ITEM_TYPE = new ENHANCED_INFO_ITEM_TYPE();

    public ENHANCED_INFO_RICH_MEDIA_TYPE_IN_RCS_SERVICE = new EnhancedInfoRichMediaTypeInRCSService();

    public TRANSMIT_ITEM_HEIGHT = new TRANSMIT_ITEM_HEIGHT();

    public RUN_IN_WORKER_METHOD = new RUN_IN_WORKER_METHOD();

    public sms_type = new sms_type();

    public deleteMessage = new DeleteMessage();

    public is_read = new is_read();

    public session_type = new session_type();

    public is_lock = new is_lock();

    public is_report = new is_report();

    public is_collect = new is_collect();

    public referenceCount = new ReferenceCount();

    public isBlocked = new IsBlocked();

    public blockedType = new BlockedType();

    public is_send_report = new is_send_report();

    public is_sender = new is_sender();

    public has_draft = new has_draft();

    public has_mms =  new has_mms();

    public has_attachment = new has_attachment();

    public FIRST_NAME_TYPE = new FIRST_NAME_TYPE();

    public recent_contacts = new recent_contacts();

    public MM_ATTACHMENT_TYPE = new MM_ATTACHMENT_TYPE();

    public MM_SELECT_ATTACHMENT_TYPE = new MMSelectAttachmentType()

    public MMS_CONTENT_TYPE = new MMS_CONTENT_TYPE();

    public PHONE_NUMBER_TYPE = new PhoneNumberType();

    public MSG_TYPE = new MSG_TYPE();

    public MEDIA_STATUS = new MEDIA_STATUS();

    public MEDIA_PARAMETER = new MEDIA_PARAMETER();

    public TAB_TYPE  = new TAB_TYPE();

    public RCS_RECEIVE_TYPE = new RCS_RECEIVE_TYPE();

    public rcsChatBotType = new RcsChatBotType();

    public vdeBlockedExistence = new VdeBlockedExistence();

    public deepLinkUrl = new DeepLinkUrl();

    public TEXT_RECEIVE_TYPE = new TEXT_RECEIVE_TYPE();

    public RCS_TYPE = new RCS_TYPE();

    public MMS_AUDIO_STATUS = new MMS_AUDIO_STATUS();

    public TRANSMIT_MSG_STATUS = new TRANSMIT_MSG_STATUS();

    public THIRD_PART_URI = new THIRD_PART_URI();

    public ADVANCED_SECURITY_MODE = new ADVANCED_SECURITY_MODE();

    public MESSAGE_TYPE = new MESSAGE_TYPE();

    public AUDIO_RECORDER_ERROR_CODE = new AudioRecorderErrorCode();

    public PROMPT_TOAST = new PromptToast();

    public MESSAGEHOME_DELETE = new MessageHomeDelete();

    public VIBRATIONEFFECT = new VibrationEffect();

    public isSmartType = new IsSmartType();

    public notificationLocal = new NotificationLocal()

    public MSG_DATA_STATUS = new MsgDataStatus()

    public SECURITY_EVENT = new SecurityEventId()

    public WEBVIEW_MENU_ID = new WebviewPageMenuId()

    public SLIDE_ACTION_TYPE = new SlideActionType()

    public RCS_SEND_MSG = new RCS_SEND_MSG()

    public blockedPageType = new BlockedPageType();
    public rcsFromType = new RcsFromType();

    public serviceCenter = new ServiceCenter()

    public ueMsgSendType = new UeMsgSendType();

    public ueMsgType = new UeMsgType();

    public ueMsgContent = new UeMsgContent();

    public simType = new SimType();

    public MMS_MAP_CONSTANT = new MmsMapConstant;
}


export default new commonData();

