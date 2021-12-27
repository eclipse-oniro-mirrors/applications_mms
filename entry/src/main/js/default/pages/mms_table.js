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
        id: 'id',
        time: 'time',
        telephone: 'telephone',
        content: 'content',
        contactsNum: 'contacts_num',
        smsType: 'sms_type',
        unreadCount: 'unread_count',
        sendingStatus: 'sending_status',
        hasDraft: 'has_draft',
        hasLock: 'has_lock',
        messageCount: 'message_count',
        hasMms: 'has_mms',
        hasAttachment: 'has_attachment'
    },
    // 短信详情对应字段名称
    messageInfo: {
        msgId: 'msg_id',
        receiverNumber: 'receiver_number',
        senderNumber: 'sender_number',
        startTime: 'start_time',
        endTime: 'end_time',
        msgType: 'msg_type',
        smsType: 'sms_type',
        msgTitle: 'msg_title',
        msgContent: 'msg_content',
        msgState: 'msg_state',
        operatorServiceNumber: 'operator_service_number',
        msgCode: 'msg_code',
        isLock: 'is_lock',
        isRead: 'is_read',
        isCollect: 'is_collect',
        sessionType: 'session_type',
        retryNumber: 'retry_number',
        isSubsection: 'is_subsection',
        sessionId: 'session_id',
        groupId: 'group_id',
        isSender: 'is_sender',
        isSendReport: 'is_send_report'
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
        msgId: 'msg_id',
        groupId: 'group_id', // 群组ID
        type: 'type', // 0主题、1图片、2视频、3音频、4文本、5名片
        locationPath: 'location_path',
        content: 'content',
        partSize: 'part_size',
        partIndex: 'part_index',
        recordingTime: 'recording_time',
        encode: 'encode',
        state: 'state'
    }
}