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
interface sessionField {
    id: string;
    time: string;
    telephone: string;
    content: string;
    contactsNum: string;
    smsType: string;
    unreadCount: string;
    sendStatus: string;
    hasDraft: string;
    messageCount: string;
    hasMms: string;
    contactId: string;
    contactName: string;
    hasAttachment: string;
    yellowPageId: string;
    blockedType: string;
    pinningTime: string;
}
interface messageInfo {
    rcsId: string;
    msgId: string;
    slotId: string;
    receiverNumber: string;
    senderNumber: string;
    startTime: string;
    endTime: string;
    msgType: string;
    smsType: string;
    msgTitle: string;
    msgContent: string;
    msgState: string;
    msgCode: string
    msgCodeStr: string
    isRead: string
    isCollect: string
    sessionType: string
    sessionId: string
    groupId: string
    partType: string
    partLocationPath: string
    isSender: string
    isSendReport: string;
    isAdvancedSecurity: string;
    expiresTime: string;
    mmsPdu: string;
    isBlocked: string;
    blockedReason: string;
    blockedSources: string;
    blockedType: string;
    blockedTypeText: string;
    blockedPrefNumber: string;
    detectResContent: string;
    riskUrlBody: string;
    isReport: string;
    phoneNumber: string;
    formatPhoneNumber: string;
    isFraud: string;
}
interface rcsMessageInfo {
    rcsId: string;
    slotId: string;
    msgId: string;
    receiverNumber: string;
    senderNumber: string;
    startTime: string;
    endTime: string;
    rcsType: string;
    msgTitle: string;
    msgContent: string;
    msgState: string;
    isRead: string;
    sessionId: string;
    groupId: string;
    isSender: string;
    enrichedCallingType: string;
    errorCode: string;
    networkType: string;
    ownerAddr: string;
    privacyMode: string;
    protocol: string;
    replyPathPresent: string;
    seen: string;
    serviceCenter: string;
    serviceKind: string;
    isCollect: string;
    isAdvancedSecurity: string;
    receiveState: string;
    failReceiveContext: string;
    clurSize: string;
    totalSize: string;
    isBlocked: string;
    blockedReason: string;
    blockedSources: string;
    blockedType: string;
    blockedTypeText: string;
    blockedPrefNumber: string;
    detectResContent: string;
    riskUrlBody: string;
    isReport: string;
    phoneNumber: string;
    formatPhoneNumber: string;
}
interface contactColumns {
        id: string
        displayName: string
        contactedCount: string
        lastestContactedTime: string
        contactLastUpdatedTimestamp: string
    }
interface contactDataColumns {
        id: string
        contactId: string
        detailInfo: string
        typeId: string
        contentType: string
        displayName: string
        hasDelete: string
        primary: string
        rawContactId: string
        formatNumber: string
        blobData: string
    }
interface searchContactView {
    searchName: string
    contactId: string
    detailInfo: string
    contentType: string
    displayName: string
    hasDelete: string
}
interface mmsPart {
        id: string
        msgId: string
        groupId: string
        rcsId: string
        type: string
        ct: string
        locationPath: string
        content: string
        partSize: string
        partIndex: string
        recordingTime: string
        encode: string
        state: string
        isFraud: string
        referenceCount: string
    }

interface favorateInfo {
    msgId: string
    receiverNumber: string
    senderNumber: string
    keepTime: string
    startTime: string
    msgType: string
    smsType: string
    msgTitle: string
    msgContent: string
    sessionType: string
    groupId: string
    partType: string
    partLocationPath: string
    partSize: string
    recordingTime: string
    isSender: string
    rcsId: string
    detectResContent: string
}
interface smsSubsection {
    smsSubsectionId: string
    receiverNumber: string
    senderNumber: string
    isSender: string
    startTime: string
    endTime: string
    rawPdu: string
    format: string
    destPort: string
    subsectionIndex: string
    size: string
}
interface mmsProtocol {
        msgId: string
        bcc: string
        cc: string
        content_location: string
        date: string
        deliveryReport: string
        deliveryTime: string
        expiry: string
        type: string
        serialNumber: string
        category: string
        version: string
        size: string
        priority: string
        readReply: string
        reportAllowed: string
        responseStatus: string
        responseText: string
        senderVisibility: string
    }
interface net {
    profileId: string,
    mccMnc: string,
    apnTypes: string,
    homeUrl: string
}

interface yellowPageInfo {
    id: string;
    photo: string;
    name: string;
    number: string;
}

interface blockedAccessInfo {
    types: string,
    phoneNumber: string,
    timeStamp: string,
    interceptionMsgCount: string
}

interface riskUrlRecord {
    id: string,
    sessionId: string,
    msgId: string,
    rcsId: string,
    msgType: string,
    riskUrl: string,
    riskType: string,
    urlIndex: string,
    packageName: string,
    createTime: string,
    numberOfRetries: string,
    checkType: string,
    lastUpdateTime: string,
}

interface Chatbots {
  serviceId: string
  serviceName: string
  lastSuggestedList: string
}
interface tableData {
    sessionField: sessionField
    messageInfo: messageInfo
    rcsMessageInfo: rcsMessageInfo
    contactColumns: contactColumns
    contactDataColumns: contactDataColumns
    searchContactView: searchContactView
    mmsPart: mmsPart
    favorateInfo: favorateInfo
    smsSubsection: smsSubsection
    mmsProtocol: mmsProtocol
    net: net
    blockedAccessInfo: blockedAccessInfo
    yellowPageInfo: yellowPageInfo
    riskUrlRecord: riskUrlRecord
    chatbots: Chatbots
}
export default {
    // Name of the field corresponding to the session list
    sessionField: {
        id: 'id', //session Table id   integer
        time: 'time', // Last SMS message time  integer
        telephone: 'telephone', //Phone number  TEXT
        content: 'content', // SMS message content     TEXT
        contactsNum: 'contacts_num', // Number of Contacts    integer
        smsType: 'sms_type', //Sms Type    0-Common，1-Notice    integer
        unreadCount: 'unread_count', // Number of unread SMs   integer
        sendStatus: 'sending_status', // Sending success status   0：Success ，1 ：Fail ， 2 ： Sending...   integer
        hasDraft: 'has_draft', //Whether there is a draft   0： no， 1：have  integer
        messageCount: 'message_count', //Total number of messages  integer
        hasMms: 'has_mms', //Whether there is a new message  0： no， 1：have  integer
        contactId: 'contact_id', // Contacts id
        contactName: 'contact_name', // Contacts name
        hasAttachment: 'has_attachment', //Whether there are attachments  0： no， 1：have  integer
        yellowPageId: 'yellow_page_id',
        blockedType: 'blocked_type',
        pinningTime: 'pinning_time'
    },
    // Name of the field corresponding to the SMS favorites.
    favorateInfo: {
        msgId: 'msg_id',
        receiverNumber: 'receiver_number',
        senderNumber: 'sender_number',
        keepTime: 'keep_time',
        startTime: 'start_time',
        msgType: 'msg_type',
        smsType: 'sms_type',
        msgTitle: 'msg_title',
        msgContent: 'msg_content',
        sessionType: 'session_type',
        groupId: 'group_id',
        partType: 'part_type',
        partLocationPath: 'part_location_path',
        partSize: 'part_size',
        recordingTime: 'recording_time',
        isSender: 'is_sender',
        rcsId: 'rcs_id',
        detectResContent: 'detect_res_content'
    },
    // Name of the field corresponding to the SMS message details.
    messageInfo: {
        msgId: 'msg_id', //sms_mms_info Table id   integer
        slotId: 'slot_id', //slot_id integer
        receiverNumber: 'receiver_number', //Recipient number  TEXT
        senderNumber: 'sender_number', //Sender number  TEXT
        startTime: 'start_time', //Start Time  TEXT
        endTime: 'end_time', //End Time  TEXT
        msgType: 'msg_type', //Message Type  0 Subject、1 Pictures、2 Video、3 Audio、4 Text、5 business card    integer
        smsType: 'sms_type', //SM Type  0-Common，1-Notice  integer
        msgTitle: 'msg_title', //Message Title  TEXT
        msgContent: 'msg_content', //Message content  TEXT
        msgState: 'msg_state', //Message Status   0：Success ，1 ：fail ， 2 ： Sending... integer
        msgCode: 'msg_code', //Message Code  integer
        msgCodeStr: 'msg_code_str', //Message Code string
        isRead: 'is_read', // Read or Not
        isCollect: 'is_collect', //Favorites  0-Not favorited，1-Favorites  integer
        sessionType: 'session_type', //Session Type  0 - Common  1 - broadcast  2 - Group Sending  integer
        sessionId: 'session_id', //Session ID  integer
        groupId: 'group_id', //Group ID  integer
        partType: 'part_type',
        partLocationPath: 'part_location_path',
        isSender: 'is_sender', //Sender or Not  0 - Recipient  1 - Sender  integer
        isSendReport: 'is_send_report', //Whether to send a report  0 - No  1 - Yes  integer
        isAdvancedSecurity: 'is_advanced_security', //Advanced Security Mode or Not
        expiresTime: 'expires_time',
        mmsPdu: 'mms_pdu',
        isBlocked: 'is_blocked',
        blockedReason: 'blocked_reason',
        blockedSources: 'blocked_sources',
        blockedType: 'blocked_type',
        blockedTypeText: 'blocked_type_text',
        blockedPrefNumber: 'blocked_pref_number',
        rcsId: 'rcs_id',
        detectResContent: 'detect_res_content',
        riskUrlBody: 'risk_url_body',
        isReport: 'is_report',
        phoneNumber: 'phone_number',
        formatPhoneNumber: 'format_phone_number',
        isFraud: 'is_fraud'
    },
    rcsMessageInfo: {
        rcsId: 'rcs_id', //rcs_info Table id   integer
        slotId: 'slot_id', //slot_id integer
        msgId: 'msg_id', //sms_mms_info Table id   integer
        receiverNumber: 'receiver_number',
        senderNumber: 'sender_number',
        startTime: 'start_time', //Start Time  TEXT
        endTime: 'end_time', //End Time  TEXT
        rcsType: 'rcs_type', //Message Type commonData.ENHANCED_INFO_ITEM_TYPE
        msgTitle: 'msg_title', //Message Title  TEXT
        msgContent: 'msg_content', //Message content  TEXT
        msgState: 'msg_state', //Message Status   0：Success ，1 ：fail ， 2 ： Sending... integer
        isRead: 'is_read', // Read or Not
        sessionId: 'session_id', //Session ID  integer
        groupId: 'group_id', //Group ID  integer
        isSender: 'is_sender', //Sender or Not  0 - Recipient  1 - Sender  integer
        enrichedCallingType: 'enriched_calling_type',
        errorCode: 'error_code',
        networkType: 'network_type',
        ownerAddr: 'owner_addr',
        privacyMode: 'privacy_mode',
        protocol: 'protocol',
        replyPathPresent: 'reply_path_present',
        seen: 'seen',
        serviceCenter: 'service_center',
        serviceKind: 'service_kind',
        isCollect:'is_collect',
        isAdvancedSecurity: 'is_advanced_security', //Advanced Security Mode or Not
        receiveState: 'receive_state',
        failReceiveContext: 'fail_receive_context',
        clurSize: 'clur_size',
        totalSize: 'total_size',
        isBlocked: 'is_blocked',
        blockedReason: 'blocked_reason',
        blockedSources: 'blocked_sources',
        blockedType: 'blocked_type',
        blockedTypeText: 'blocked_type_text',
        blockedPrefNumber: 'blocked_pref_number',
        detectResContent: 'detect_res_content',
        riskUrlBody: 'risk_url_body',
        isReport: 'is_report',
        phoneNumber: 'phone_number',
        formatPhoneNumber: 'format_phone_number'
    },
    contactColumns: {
        id: 'id', // raw_contact_table id
        displayName: 'display_name', // Display Name
        contactedCount: 'contacted_count', // Number of Contacts
        lastestContactedTime: 'lastest_contacted_time', // Last Contact Time
        contactLastUpdatedTimestamp: 'contact_last_updated_timestamp' // Contact Last Updated Time
    },
    contactDataColumns: {
        id: 'id', // raw_contact_table id
        contactId: 'contact_id', // raw_contact_table id
        detailInfo: 'detail_info',
        typeId: 'type_id', // raw_contact_table id
        contentType: 'content_type', // raw_contact_table id
        displayName: 'display_name', // Display Name
        hasDelete: 'is_deleted', // hasDelete
        primary: 'extend5', // primary
        rawContactId: 'raw_contact_id', //rawContactId
        formatNumber: 'format_phone_number', // format_phone_number
        blobData: 'blob_data'
    },
    searchContactView: {
        searchName: 'search_name',
        contactId: 'contact_id',
        detailInfo: 'detail_info',
        contentType: 'content_type',
        displayName: 'display_name', // Display Name
        hasDelete: 'is_deleted' // hasDelete
    },
    // Saving MMS data
    mmsPart: {
        id: 'id',
        msgId: 'msg_id', //mms_part table id   integer
        groupId: 'group_id', // Group ID   integer
        rcsId: 'rcs_id', // rcs ID   integer
        type: 'type', // 0: theme; 1: picture; 2: video; 3: audio; 4: text; 5: business card    integer
        ct: 'ct', //content type TEXT
        locationPath: 'location_path', //Local storage path   TEXT
        content: 'content', //MMS text content    TEXT
        partSize: 'part_size', //MMS Size    TEXT
        partIndex: 'part_index', //MMS data subscript   integer
        recordingTime: 'recording_time', //Audio/Video Recording Time    TEXT
        encode: 'encode', //Encoding or not  0: no encoding/encryption; 1: encoding/encryption   integer
        state: 'state', //Sending success status 0: success; 1: failure; 2: sending...    integer
        isFraud: 'is_fraud',
        referenceCount: 'reference_count'
    },
    // Saving SMS data in partitions
    smsSubsection: {
        smsSubsectionId: 'sms_subsection_id', //sms_subsection table id   integer
        receiverNumber: 'receiver_number', //Recipient number  TEXT
        senderNumber: 'sender_number', //Sender number  TEXT
        isSender: 'is_sender', //Sender number  0 - Sender  1 - Recipient  integer
        startTime: 'start_time', //Start Time  TEXT
        endTime: 'end_time', //End Time  TEXT
        rawPdu: 'raw_pdu', //PDU string of the SMS message   TEXT
        format: 'format', //Formatted data    integer
        destPort: 'dest_port', //Destination Port    integer
        subsectionIndex: 'subsection_index', //Section Index    integer
        size: 'size' //size   integer
    },
    // mms Protocol data saving
    mmsProtocol: {
        msgId: 'msg_id', //mms_Protocol table id   integer
        bcc: 'bcc', //bcc  TEXT
        cc: 'cc', //cc  TEXT
        content_location: 'content_location', //content_location  TEXT
        date: 'date', //date  TEXT
        deliveryReport: 'delivery_report', //deliveryReport  integer
        deliveryTime: 'delivery_time', //deliveryTime   TEXT
        expiry: 'expiry', //expiry    integer
        type: 'type', //type    integer
        serialNumber: 'serial_number', //serialNumber    TEXT
        category: 'category', //category    TEXT
        version: 'version', //version   integer
        size: 'size', //size   integer
        priority: 'priority', //priority   integer
        readReply: 'read_reply', //readReply   integer
        reportAllowed: 'report_allowed', //reportAllowed   integer
        responseStatus: 'response_status', //responseStatus   integer
        responseText: 'response_text', //responseText   TEXT
        senderVisibility: 'sender_visibility' //senderVisibility  integer
    },
    net: {
        profileId: 'profile_id',
        mccMnc: 'mccmnc',
        apnTypes: 'apn_types',
        homeUrl: 'home_url'
    },
    // Name of the blocked or access list
    blockedAccessInfo: {
        types: 'types',
        phoneNumber: 'phone_number',
        timeStamp: 'time_stamp',
        interceptionMsgCount: 'interception_msg_count'
    },
    // Name of the field corresponding to the yellow page details
    yellowPageInfo: {
        id: '_ID', // yellow page phone id   integer
        photo: 'photo', // yellow page photo   TEXT
        name: 'name', // yellow page name   TEXT
        number: 'number' // phone number   TEXT
    },
    // Name of the field corresponding to risk url record
    riskUrlRecord: {
        id: 'id', // risk url Record table id integer
        sessionId: 'session_id', // session id
        msgId: 'msg_id', // mms_Protocol table id   integer
        rcsId: 'rcs_id', // rcs_info Table id   integer
        msgType: 'msg_type', // message type rcs or msg integer
        riskUrl: 'risk_url', // risk url TEXT
        riskType: 'risk_type', // risk type default is -1, UrlThreatType integer
        urlIndex: 'url_index', // url index in message content integer
        packageName: 'package_name', // package name TEXT
        createTime: 'create_time', // risk url record create time TEXT
        numberOfRetries: 'number_of_retries', // retry number integer
        checkType: 'check_type', // check type   integer
        lastUpdateTime: 'last_update_time', // last update time TEXT
    },
    chatbots: {
        serviceId: 'service_id',
        serviceName: 'service_name',
        lastSuggestedList: 'last_suggested_list'
    }
} as tableData