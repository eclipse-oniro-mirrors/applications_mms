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
                name: "mmssms.db"
            },
            version: 1
        }
    },
    table: {
        // Session table
        session:
        "CREATE TABLE IF NOT EXISTS session (" +
        "id INTEGER PRIMARY KEY AUTOINCREMENT, " +
        "time INTEGER DEFAULT 0, " +
        "telephone TEXT, " +
        "content TEXT, " +
        "contacts_num INTEGER DEFAULT 0, " +
        "sms_type INTEGER DEFAULT 0, " +
        "unread_count INTEGER DEFAULT 0, " +
        "sending_status INTEGER DEFAULT 0, " +
        "has_draft INTEGER DEFAULT 0," +
        "has_lock INTEGER DEFAULT 0," +
        "message_count INTEGER DEFAULT 0," +
        "has_mms INTEGER DEFAULT 0," +
        "has_attachment INTEGER DEFAULT 0" +
        ");",
    },
    // Name of the field corresponding to the session list
    sessionField: {
        id: "id", //session Table id   integer
        time: "time", // Last SMS message time  integer
        telephone: "telephone", //Phone number  TEXT
        content: "content", // SMS message content     TEXT
        contactsNum: "contacts_num", // Number of Contacts    integer
        smsType: "sms_type", //Sms Type    0-Common，1-Notice    integer
        unreadCount: "unread_count", // Number of unread SMs   integer
        sendStatus: "sending_status", // Sending success status   0：Success ，1 ：Fail ， 2 ： Sending...   integer
        hasDraft: "has_draft", //Whether there is a draft   0： no， 1：have  integer
        hasLock: "has_lock", // Whether there is a lock   0： no， 1：have  integer
        messageCount: "message_count", //Total number of messages  integer
        hasMms: "has_mms", //Whether there is a new message  0： no， 1：have  integer
        hasAttachment: "has_attachment" //Whether there are attachments  0： no， 1：have  integer
    },
    // Name of the field corresponding to the SMS message details.
    messageInfo: {
        msgId: "msg_id", //sms_mms_info Table id   integer
        slotId: "slot_id", //slot_id integer
        receiverNumber: "receiver_number", //Recipient number  TEXT
        senderNumber: "sender_number", //Sender number  TEXT
        startTime: "start_time", //Start Time  TEXT
        endTime: "end_time", //End Time  TEXT
        msgType: "msg_type", //Message Type  0 Subject、1 Pictures、2 Video、3 Audio、4 Text、5 business card    integer
        smsType: "sms_type", //SM Type  0-Common，1-Notice  integer
        msgTitle: "msg_title", //Message Title  TEXT
        msgContent: "msg_content", //Message content  TEXT
        msgState: "msg_state", //Message Status   0：Success ，1 ：fail ， 2 ： Sending... integer
        operatorServiceNumber: "operator_service_number", //Operator service number  TEXT
        msgCode: "msg_code", //Message Code  integer
        isLock: "is_lock", //Locked  0-No，1-Yes  integer
        isRead: "is_read", // Read or Not  0-Read，1-Unread  integer
        isCollect: "is_collect", //Favorites  0-Not favorited，1-Favorites  integer
        sessionType: "session_type", //Session Type  0 - Common  1 - broadcast  2 - Group Sending  integer
        retryNumber: "retry_number", //Retry Times  integer
        isSubsection: "is_subsection", //Branch  0 - NO  1 - Yes  integer
        sessionId: "session_id", //Session ID  integer
        groupId: "group_id", //Group ID  integer
        isSender: "is_sender", //Sender or Not  0 - Recipient  1 - Sender  integer
        isSendReport: "is_send_report" //Whether to send a report  0 - No  1 - Yes  integer
    },
    contactColumns: {
        id: "id", // raw_contact_table id
        displayName: "display_name", // Display Name
        contactedCount: "contacted_count", // Number of Contacts
        lastestContactedTime: "lastest_contacted_time", // Last Contact Time
    },
    contactDataColumns: {
        id: "id", // raw_contact_table id
        contactId: "contact_id", // raw_contact_table id
        detailInfo: "detail_info",
        typeId: "type_id", // raw_contact_table id
        contentType: "content_type", // raw_contact_table id
        displayName: "display_name", // Display Name
        hasDelete: "is_deleted" // hasDelete
    },
    searchContactView: {
        searchName: "search_name",
        contactId: "contact_id",
        detailInfo: "detail_info",
        contentType: "content_type",
        displayName: "display_name", // Display Name
        hasDelete: "is_deleted" // hasDelete
    },
    // Saving MMS data
    mmsPart: {
        msgId: "msg_id", //mms_part table id   integer
        groupId: "group_id", // Group ID   integer
        type: "type", // 0: theme; 1: picture; 2: video; 3: audio; 4: text; 5: business card    integer
        locationPath: "location_path", //Local storage path   TEXT
        content: "content", //MMS text content    TEXT
        partSize: "part_size", //MMS Size    TEXT
        partIndex: "part_index", //MMS data subscript   integer
        recordingTime: "recording_time", //Audio/Video Recording Time    TEXT
        encode: "encode", //Encoding or not  0: no encoding/encryption; 1: encoding/encryption   integer
        state: "state" //Sending success status 0: success; 1: failure; 2: sending...    integer
    },
    // Saving SMS data in partitions
    smsSubsection: {
        smsSubsectionId: "sms_subsection_id", //sms_subsection table id   integer
        receiverNumber: "receiver_number", //Recipient number  TEXT
        senderNumber: "sender_number", //Sender number  TEXT
        isSender: "is_sender", //Sender number  0 - Sender  1 - Recipient  integer
        startTime: "start_time", //Start Time  TEXT
        endTime: "end_time", //End Time  TEXT
        rawPdu: "raw_pdu", //PDU string of the SMS message   TEXT
        format: "format", //Formatted data    integer
        destPort: "dest_port", //Destination Port    integer
        subsectionIndex: "subsection_index", //Section Index    integer
        size: "size" //size   integer
    },
    // mms Protocol data saving
    mmsProtocol: {
        msgId: "msg_id", //mms_Protocol table id   integer
        bcc: "bcc", //bcc  TEXT
        cc: "cc", //cc  TEXT
        content_location: "content_location", //content_location  TEXT
        date: "date", //date  TEXT
        deliveryReport: "delivery_report", //deliveryReport  integer
        deliveryTime: "delivery_time", //deliveryTime   TEXT
        expiry: "expiry", //expiry    integer
        type: "type", //type    integer
        serialNumber: "serial_number", //serialNumber    TEXT
        category: "category", //category    TEXT
        version: "version", //version   integer
        size: "size", //size   integer
        priority: "priority", //priority   integer
        readReply: "read_reply", //readReply   integer
        reportAllowed: "report_allowed", //reportAllowed   integer
        responseStatus: "response_status", //responseStatus   integer
        responseText: "response_text", //responseText   TEXT
        senderVisibility: "sender_visibility" //senderVisibility  integer
    }
}