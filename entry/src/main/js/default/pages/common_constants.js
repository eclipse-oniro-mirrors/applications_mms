/**
 * Copyright (c) 2021 Huawei Device Co., Ltd.
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

export default {
    bool: {
        TRUE: '1',
        FALSE: '0',
    },
    route: {
        // 更新送达报告开关的值
        MESSAGE_CODE_UPDATE_DELIVERY_REPORTS_VALUE: 32001,
        // 更新自动下载彩信开关的值
        MESSAGE_CODE_UPDATE_AUTO_RETRIEVE_MMS_VALUE: 32002,
        // 更新取消发送开关的值
        MESSAGE_CODE_UPDATE_RECALL_MESSAGES_VALUE: 32003,
        // 更新自动删除通知信息开关的值
        MESSAGE_CODE_UPDATE_AUTO_DELETE_INFO_MESSAGES_VALUE: 32004,
        // 更新通知信息整合开关的值
        MESSAGE_CODE_UPDATE_ARCHIVE_INFO_MESSAGES_VALUE: 30002,
        // 更新恶意网址识别开关的值
        MESSAGE_CODE_UPDATE_MALICIOUS_WEBSITE_IDENTIFICATION_VALUE: 30003,
        // 更新显示联系人头像开关的值
        MESSAGE_CODE_UPDATE_SHOW_CONTACT_PROFILE_PICS_VALUE: 30004,
        // 还原高级页面开关的值
        MESSAGE_CODE_RESTORE_ADVANCED_PAGE_SWITCH_VALUE: 30005
    },
    int: {
        // status code
        SUCCESS: 0,
        FAILURE: -1,
        // CheckBox select status code 1 全选  2.全不选  3.未知
        CHECKBOX_SELECT_ALL: 1,
        // 全不选
        CHECKBOX_SELECT_NONE: 2,
        // 未知
        CHECKBOX_SELECT_UNKNOWN: 3,
        MESSAGE_CODE_TWENTY_FIVE: 60,
        MESSAGE_CODE_THREE_FOUR_ZERO: 660,
        // 文本
        TYPE_TEXT: 0,
        // 图片
        TYPE_IMAGE: 1,
        // 音频
        TYPE_AUDIO: 2,
        // 视频
        TYPE_VIDEO: 3,
        // 0
        MESSAGE_CODE_ZERO: 0,
        // 1
        MESSAGE_CODE_ONE: 1,
        // 2
        MESSAGE_CODE_TWO: 2,
        // 300
        MESSAGE_CODE_THREE_ZERO_ZERO: 300,
        // 1000
        MESSAGE_CODE_THOUSAND: 1000,
        // 发送短信成功
        SEND_MESSAGE_SUCCESS: 0,
        // 正在发送中
        SEND_MESSAGE_SENDING: 1,
        // 发送短信失败
        SEND_MESSAGE_FAILED: 2,
        // 草稿数据类型
        SEND_DRAFT: 3,
        // 列表左移滑动操作控件的宽度
        OPERATE_DELETE_WIDTH: 145,
        OPERATE_UNREAD_WIDTH: 230,
        // sim卡数量
        SIM_COUNT: 2,
        // sim卡1
        SIM_ONE: 0,
        // sim卡2
        SIM_TWO: 1,
        // 550默认高度
        TAB_HEIGHT: 550,
        // 550+720tab全屏高度
        FULL_HEIGHT: 550 + 720,
        // 取消短信倒计时
        CANCEL_TIME_COUNT: 6,
        // 全屏的字数
        FULL_SCREEN_SEND_LENGTH: 38,
    },
    string: {
        SMS_TYPE: '0',
        // 空字符串
        EMPTY_STR: '',
        // 逗号
        COMMA: ',',
        // 分号
        SEMICOLON: ';',
        // bundleName
        BUNDLE_NAME: 'com.ohos.mms',
        // abilityName
        ABILITY_NAME: 'com.ohos.mms.MainAbility',
        // 联系人的bundleName
        CONTRACT_BUNDLE_NAME: 'com.ohos.contacts',
        // 联系人AbilityName
        CONTRACT_ABILITY_NAME: 'com.ohos.contacts.MainAbility',
        // 公用的entity
        COMMON_ENTITIES: 'entity.system.home',
        // 处理成功
        SUCCESS: 'success',
        // 轻量级偏好数据库的存储路径
        PATH_OF_PREFERENCES: '/PREFERENCES_FOR_MMS',
        // 通知信息整合
        KEY_OF_INTEGRATION_SWITCH: 'integrationSwitch',
        // 恶意网址识别
        KEY_OF_MALICIOUS_WEB_SWITCH: 'maliciousWebSwitch',
        // 显示联系人头像
        KEY_OF_SHOW_CONTACT_SWITCH: 'showContactSwitch',
        // 送达报告
        KEY_OF_DELIVERY_REPORT_SWITCH: 'deliveryReportSwitch',
        // 自动下载彩信
        KEY_OF_AUTO_RETRIEVE_SWITCH: 'autoRetrieveMmsSwitch',
        // 取消发送
        KEY_OF_RECALL_MESSAGE_SWITCH: 'recallMessageSwitch',
        // 自动删除通知信息
        KEY_OF_AUTO_DELETE_INFO_SWITCH: 'autoDeleteInfoSwitch',
        // sim卡的个数
        KEY_OF_SIM_COUNT: 'simCount',
        // sim卡1的运营商名称
        KEY_OF_SIM_0_SPN: 'simSpn0',
        // sim卡2的运营商名称
        KEY_OF_SIM_1_SPN: 'simSpn1',
        // sim卡1是否存在
        KEY_OF_SIM_0_EXIST_FLAG: 'simExistFlag0',
        // sim卡2是否存在
        KEY_OF_SIM_1_EXIST_FLAG: 'simExistFlag1',
        // 如果sim卡1的短信中心号码被修改过，新的短信中心号码
        KEY_OF_NEW_SIM_0_SMSC: 'newSimSmsc0',
        // 如果sim卡2的短信中心号码被修改过，新的短信中心号码
        KEY_OF_NEW_SIM_1_SMSC: 'newSimSmsc1',
        // sim卡的手机号
        KEY_OF_SIM_0_NUMBER: 'sim_0_number',
        KEY_OF_SIM_1_NUMBER: 'sim_1_number',
        // 订阅通知的事件
        SUBSCRIBER_EVENT: 'usual.event.SMS_RECEIVE_COMPLETED',
        // 接收转发
        RECEIVE_TRANSMIT_EVENT: 'usual.event.RECEIVE_COMPLETED_TRANSMIT',
        // 彩信接收事件
        MMS_SUBSCRIBER_EVENT: 'usual.event.MMS_RECEIVE_COMPLETED',
        // 联系人数据库
        URI_ROW_CONTACTS: 'dataability:///com.ohos.contactsdataability',
        // 联系人信息
        CONTACT_DATA_URI: '/contacts/contact_data',
        // 名片联系人
        PROFILE_DATA_URI: '/profile/raw_contact',
        // 查询联系人
        CONTACT_SEARCHE: '/contacts/search_contact',
        // 联系人信息
        CONTACT_URI: '/contacts/contact',
        // 短信数据库
        URI_MESSAGE_LOG: 'dataability:///com.ohos.smsmmsability',
        // 查询短信
        URI_MESSAGE_INFO_TABLE: '/sms_mms/sms_mms_info',
        // 统计
        URI_MESSAGE_UNREAD_COUNT: '/sms_mms/sms_mms_info/unread_total',
        // 获取最大的groupID
        URI_MESSAGE_MAX_GROUP: '/sms_mms/sms_mms_info/max_group',
        // 查询彩信
        URI_MESSAGE_MMS_PART: '/sms_mms/mms_part',
        AUDIO_NAME: 'recording2021111512454545.amr',
        // 彩信中心
        MMS_URL: 'http://mmsc.monternet.com'
    },
    DELIVERY_REPORTS: {
        // 已关闭
        DISABLED: '0',
        // 短信
        SMS: '1',
        // 彩信
        MMS: '2',
        // 短信和彩信
        SMS_AND_MMS: '3'
    },
    AUTO_RETRIEVE_MMS: {
        // 关闭
        OFF: '0',
        // 非漫游时
        NOT_WHEN_ROAMING: '1',
        // 所有网络下
        ALWAYS: '2'
    },
    SPN_CHINA: {
        // 电信
        TELECOM: '中国电信',
        // 移动
        MOBILE: 'CMCC',
        // 联通
        UNICOM: 'China Unicom',
    },
    contractPage: {
        // 跳转至新建联系人
        PAGE_FLAG_SAVE_CONTACT: 'page_flag_save_contact',
        // 呼叫前编辑
        PAGE_FLAG_EDIT_BEFORE_CALLING: 'page_flag_edit_before_calling',
        // 保存至已有联系人
        PAGE_FLAG_SAVE_EXIST_CONTACT: 'page_flag_save_exist_contact',
        // 短信发送跳转到选择联系人界面
        PAGE_FLAG_MULT_CHOOSE: 'page_flag_mult_choose',
        // 选择联系人列表页面
        PAGE_FLAG_CHOOSE_CONTACTS: 'page_flag_choose_contacts',
        // 联系人详情页面
        PAGE_FLAG_CONTACT_DETAILS: 'page_flag_contact_details',
        // 跳转至我的名片界面
        PAGE_FLAG_CALLING_CARD: 'page_flag_card_details',
        // 查询彩信数据
        URI_MESSAGE_MMS_PART: '/sms_mms/mms_part'
    },
    MESSAGE_TAB_INDEX: {
        TAB_CAMERA: 0,
        TAB_PICTURE: 1,
        TAB_AUDIO: 2,
        TAB_MORE: 3
    },
    TAG: {
        // 信息列表首页
        MsgList: 'message_list  :',
        // 通知信息
        MsgInfo: 'message_info :'
    },
    HIGHLIGHT_TYPE: {
        // 普通数据
        NORMAL: 0,
        // 邮箱
        EMAIL: 1,
        // 网址
        URL: 2,
        // 电话
        TEL: 3,
        // 时间
        DATE: 4,
        // 验证码
        NUM: 5
    },
    tableName: {
        SESSION: 'session'
    },
    MESSAGE_TYPE: {
        // 普通信息
        NORMAL: 0,
        // 主题
        THEME: 1,
        // 幻灯片
        PPT: 2,
        // 主题和幻灯片
        THEME_AND_PPT: 3,
    },
    MESSAGE_SHOW_TYPE: {
        // 普通短信样式
        NORMAL: 0,
        // 不包含图片主题样式
        THEME_NO_IMAGE: 1,
        // 不包含图片幻灯片样式
        PPT_NO_IMAGE: 2,
        // 含图片幻灯片样式
        PPT_IMAGE: 3,
        // 含图片主题样式
        THEME_IMAGE: 4
    },
    MSG_ITEM_TYPE: {
        THEME: 0,
        IMAGE: 1,
        VIDEO: 2,
        AUDIO: 3,
        TEXT: 4,
        CARD: 5
    },
    TRANSMIT_ITEM_HEIGHT: {
        TEXT_HEIGHT: 150,
        THEME_HEIGHT: 200,
        THEME_IMAGE_HEIGHT: 300,
        PPT_IMAGE_HEIGHT: 220,
        DISTANCE: 20,
        TOTAL_HEIGHT: 650
    }
}