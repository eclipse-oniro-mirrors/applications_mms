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
export default {
    DB: {
        MMSSMS: {
            config: {
                name: 'mmssms.db'
            },
            version: 1
        }
    },
    table: {
        // 会话表
        session:
        'CREATE TABLE IF NOT EXISTS session (' +
        'id INTEGER PRIMARY KEY AUTOINCREMENT, ' +
        'time INTEGER DEFAULT 0, ' +
        'telephone TEXT, ' +
        'content TEXT, ' +
        'contacts_num INTEGER DEFAULT 0, ' +
        'sms_type INTEGER DEFAULT 0, ' +
        'unread_count INTEGER DEFAULT 0, ' +
        'sending_status INTEGER DEFAULT 0, ' +
        'has_draft INTEGER DEFAULT 0,' +
        'has_lock INTEGER DEFAULT 0,' +
        'message_count INTEGER DEFAULT 0,' +
        'has_mms INTEGER DEFAULT 0,' +
        'has_attachment INTEGER DEFAULT 0' +
        ');',
    },
    // 会话列表对应的字段名称
    sessionField: {
        id: 'id', //session 表id   integer
        time: 'time', // 上条短信时间  integer
        telephone: 'telephone',//电话号码  TEXT
        content: 'content',// 短信内容     TEXT
        contactsNum: 'contacts_num', // 联系人数    integer
        smsType: 'sms_type',//短信类型    0-普通，1-通知    integer
        unreadCount: 'unread_count',// 未读短息数   integer
        sendStatus: 'sending_status',// 发送成功状态   0：成功 ，1 ：失败 ， 2 ： 发送中...   integer
        hasDraft: 'has_draft',//是否有草稿   0： 没有， 1：有  integer
        hasLock: 'has_lock',// 是否有锁   0： 沒有， 1：有  integer
        messageCount: 'message_count', //消息总数  integer
        hasMms: 'has_mms', //是否有新消息  0： 沒有， 1：有  integer
        hasAttachment: 'has_attachment' //是否有附件  0： 没有， 1：有  integer
    },
    // 短信详情对应字段名称
    messageInfo: {
        msgId: 'msg_id', //sms_mms_info 表id   integer
        receiverNumber: 'receiver_number', //接收方号码  TEXT
        senderNumber: 'sender_number', //发送方号码  TEXT
        startTime: 'start_time', //启始时间  TEXT
        endTime: 'end_time', //结束时间  TEXT
        msgType: 'msg_type', //消息类型  0主题、1图片、2视频、3音频、4文本、5名片 integer
        smsType: 'sms_type', //短息类型  0-普通，1-通知  integer
        msgTitle: 'msg_title', //消息标题  TEXT
        msgContent: 'msg_content', //消息内容  TEXT
        msgState: 'msg_state', //消息状态   0：成功 ，1 ：失败 ， 2 ： 发送中... integer
        operatorServiceNumber: 'operator_service_number', //操作员服务号码  TEXT
        msgCode: 'msg_code', //消息码  integer
        isLock: 'is_lock', //是否锁定  0-否，1-是  integer
        isRead: 'is_read', // 是否读取  0-已读，1-未读  integer
        isCollect: 'is_collect', //是否收藏  0-未收藏，1-已收藏  integer
        sessionType: 'session_type', //会话类型  0 - 普通  1 - 广播  2 - 群发  integer
        retryNumber: 'retry_number', //重试次数  integer
        isSubsection: 'is_subsection', //是否分支  0 - 否  1 - 是  integer
        sessionId: 'session_id', //会话Id  integer
        groupId: 'group_id', //群组ID  integer
        isSender: 'is_sender', //是否是发送方  0 - 接收方  1 - 发送方  integer
        isSendReport: 'is_send_report' //是否发送报告  0 - 否  1 - 是  integer
    },
    contactColumns: {
        id: 'id', // raw_contact_表 id
        displayName: 'display_name', // 显示名称
        contactedCount: 'contacted_count', // 联系次数
        lastestContactedTime: 'lastest_contacted_time', // 最近联系时间
    },
    contactDataColumns: {
        id: 'id', // raw_contact_表 id
        contactId: 'contact_id', // raw_contact_表 id
        detailInfo: 'detail_info',
        typeId: 'type_id', // raw_contact_表 id
        contentType: 'content_type', // raw_contact_表 id
        displayName: 'display_name', // 显示名称
        hasDelete: 'is_deleted' // 显示名称
    },
    searchContactView: {
        searchName: 'search_name',
        contactId: 'contact_id',
        detailInfo: 'detail_info',
        contentType: 'content_type',
        displayName: 'display_name', // 显示名称
        hasDelete: 'is_deleted' // 显示名称
    },
    // 彩信数据保存
    mmsPart: {
        msgId: 'msg_id',//mms_part 表id   integer
        groupId: 'group_id', // 群组ID   integer
        type: 'type', // 0主题、1图片、2视频、3音频、4文本、5名片    integer
        locationPath: 'location_path',//本地存储路径   TEXT
        content: 'content',//彩信文本内容    TEXT
        partSize: 'part_size',//彩信大小    TEXT
        partIndex: 'part_index',//彩信数据下标   integer
        recordingTime: 'recording_time',//录制音视频时间    TEXT
        encode: 'encode',//是否编码  0：不编码/不加密， 1：编码/加密   integer
        state: 'state'//发送成功状态 0：成功 ，1 ：失败 ， 2 ： 发送中...    integer
    },
    // 分区短信数据保存
    smsSubsection: {
        smsSubsectionId: 'sms_subsection_id',//sms_subsection 表id   integer
        receiverNumber: 'receiver_number', //接收方号码  TEXT
        senderNumber: 'sender_number', //发送方号码  TEXT
        isSender: 'is_sender',//是否是发送方  0 - 发送方  1 - 接收方  integer
        startTime: 'start_time',//启始时间  TEXT
        endTime: 'end_time',//结束时间  TEXT
        rawPdu: 'raw_pdu',//短信的PDU串   TEXT
        format: 'format',//格式化后的数据    integer
        destPort: 'dest_port',//目标端口    integer
        subsectionIndex: 'subsection_index',//小节索引    integer
        size: 'size'//大小   integer
    },
    // mms协议数据保存
    mmsProtocol: {
        msgId: 'msg_id',//mms_Protocol 表id   integer
        bcc: 'bcc', //bcc  TEXT
        cc: 'cc', //cc  TEXT
        content_location: 'content_location',//content_location  TEXT
        date: 'date',//date  TEXT
        deliveryReport: 'delivery_report',//deliveryReport  integer
        deliveryTime: 'delivery_time',//deliveryTime   TEXT
        expiry: 'expiry',//expiry    integer
        type: 'type',//type    integer
        serialNumber: 'serial_number',//serialNumber    TEXT
        category: 'category',//category    TEXT
        version: 'version',//version   integer
        size: 'size',//size   integer
        priority: 'priority',//priority   integer
        readReply: 'read_reply',//readReply   integer
        reportAllowed: 'report_allowed',//reportAllowed   integer
        responseStatus: 'response_status',//responseStatus   integer
        responseText: 'response_text',//responseText   TEXT
        senderVisibility: 'sender_visibility'//senderVisibility  integer
    }
}