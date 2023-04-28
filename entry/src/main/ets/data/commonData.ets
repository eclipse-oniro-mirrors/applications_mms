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
    bool: {
        TRUE: "1",
        FALSE: "0",
    },
    route: {
        // Update the value of the delivery report switch.
        MESSAGE_CODE_UPDATE_DELIVERY_REPORTS_VALUE: 32001,
        // Update the value of the function of automatically downloading MMS messages.
        MESSAGE_CODE_UPDATE_AUTO_RETRIEVE_MMS_VALUE: 32002,
        // Update the value of the send cancel switch.
        MESSAGE_CODE_UPDATE_RECALL_MESSAGES_VALUE: 32003,
        // Update the value of the switch for automatically deleting notification information.
        MESSAGE_CODE_UPDATE_AUTO_DELETE_INFO_MESSAGES_VALUE: 32004,
        // Update the value of the notification integration switch.
        MESSAGE_CODE_UPDATE_ARCHIVE_INFO_MESSAGES_VALUE: 30002,
        // Update the value of the malicious URL identification switch.
        MESSAGE_CODE_UPDATE_MALICIOUS_WEBSITE_IDENTIFICATION_VALUE: 30003,
        // Updates the value of the switch for displaying contact avatars.
        MESSAGE_CODE_UPDATE_SHOW_CONTACT_PROFILE_PICS_VALUE: 30004,
        // Restore the value of the advanced page switch.
        MESSAGE_CODE_RESTORE_ADVANCED_PAGE_SWITCH_VALUE: 30005
    },
    int: {
        // status code
        SUCCESS: 0,
        FAILURE: -1,
        // CheckBox select status code   1. Select all. 2. Do not select all. 3. Unknown.
        CHECKBOX_SELECT_ALL: 1,
        // None
        CHECKBOX_SELECT_NONE: 2,
        // Unknown
        CHECKBOX_SELECT_UNKNOWN: 3,
        MESSAGE_CODE_TWENTY_FIVE: 60,
        MESSAGE_CODE_THREE_FOUR_ZERO: 660,
        // Text
        TYPE_TEXT: 0,
        // Pictures
        TYPE_IMAGE: 1,
        // Audio
        TYPE_AUDIO: 2,
        // Video
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
        // The SMS message is sent successfully.
        SEND_MESSAGE_SUCCESS: 0,
        // Sending
        SEND_MESSAGE_SENDING: 1,
        // Failed to send the SMS message.
        SEND_MESSAGE_FAILED: 2,
        // Draft Data Type
        SEND_DRAFT: 3,
        // Width of the left slide control of the list
        OPERATE_DELETE_WIDTH: 80,
        OPERATE_UNREAD_WIDTH: 128,
        // Number of SIM cards
        SIM_COUNT: 2,
        // sim card 1
        SIM_ONE: 0,
        // sim card2
        SIM_TWO: 1,
        // 550 Default Height
        TAB_HEIGHT: 550,
        // 550+720tab Full screen height
        FULL_HEIGHT: 550 + 720,
        // Cancel SMS Countdown
        CANCEL_TIME_COUNT: 6,
        // Number of words in full screen
        FULL_SCREEN_SEND_LENGTH: 38,
        EVENT_SIM_STATE_CHANGE: 1,
        EVENT_SLOTID_CHANGE: 2,
    },
    string: {
        SMS_TYPE: "0",
        // Empty String
        EMPTY_STR: '',
        // comma
        COMMA: ",",
        // bundleName
        BUNDLE_NAME: "com.ohos.mms",
        // abilityName
        ABILITY_NAME: "com.ohos.mms.MainAbility",
        // BundleName of a contact.
        CONTRACT_BUNDLE_NAME: "com.ohos.contacts",
        // contact AbilityName
        CONTRACT_ABILITY_NAME: "com.ohos.contacts.MainAbility",
        // Public entity
        COMMON_ENTITIES: "entity.system.home",
        // Processing succeeded.
        SUCCESS: "success",
        // Storage path of the lightweight preference database
        PATH_OF_PREFERENCES: "/PREFERENCES_FOR_MMS",
        // Notification information integration
        KEY_OF_INTEGRATION_SWITCH: "integrationSwitch",
        // Malicious Website Identification
        KEY_OF_MALICIOUS_WEB_SWITCH: "maliciousWebSwitch",
        // Display contact avatar
        KEY_OF_SHOW_CONTACT_SWITCH: "showContactSwitch",
        // Delivery Report
        KEY_OF_DELIVERY_REPORT_SWITCH: "deliveryReportSwitch",
        // Automatically downloading MMs
        KEY_OF_AUTO_RETRIEVE_SWITCH: "autoRetrieveMmsSwitch",
        // Cancel Sending
        KEY_OF_RECALL_MESSAGE_SWITCH: "recallMessageSwitch",
        // Automatically delete notification information
        KEY_OF_AUTO_DELETE_INFO_SWITCH: "autoDeleteInfoSwitch",
        // Number of SIM cards
        KEY_OF_SIM_COUNT: "simCount",
        // Carrier name of SIM card 1
        KEY_OF_SIM_0_SPN: "simSpn0",
        // Carrier name of SIM card 2
        KEY_OF_SIM_1_SPN: "simSpn1",
        // Whether SIM card 1 exists
        KEY_OF_SIM_0_EXIST_FLAG: "simExistFlag0",
        // Whether SIM card 2 exists
        KEY_OF_SIM_1_EXIST_FLAG: "simExistFlag1",
        // If the SMSC number of SIM card 1 is changed, the new SMSC number is changed.
        KEY_OF_NEW_SIM_0_SMSC: "newSimSmsc0",
        // If the SMSC number of SIM card 2 is changed, the new SMSC number is changed.
        KEY_OF_NEW_SIM_1_SMSC: "newSimSmsc1",
        // Mobile number of the SIM card
        KEY_OF_SIM_0_NUMBER: "sim_0_number",
        KEY_OF_SIM_1_NUMBER: "sim_1_number",
        KEY_OF_SELECTED_SLOTID: "selected_slotId",
        KEY_OF_MAX_SIM_COUNT: "maxSimCount",
        KEY_OF_HAVE_MULTI_SIM_CARD_READY: "haveMultiSimCardReady",
        KEY_OF_HAVE_SIM_CARD_READY: "haveSimCardReady",
        KEY_OF_DEFAULT_SLOT: "defaultSlot",
        // Events for Subscribing to Notifications     usual.event.SMS_RECEIVE_COMPLETED
        SUBSCRIBER_EVENT: "usual.event.SMS_RECEIVE_COMPLETED",
        // Receiving and forwarding
        RECEIVE_TRANSMIT_EVENT: "usual.event.RECEIVE_COMPLETED_TRANSMIT",
        // MMS message receiving event
        MMS_SUBSCRIBER_EVENT: "usual.event.MMS_RECEIVE_COMPLETED",
        // Contact database
        URI_ROW_CONTACTS: "dataability:///com.ohos.contactsdataability",
        // Contact Information
        CONTACT_DATA_URI: "/contacts/contact_data",
        // Business Card Contact
        PROFILE_DATA_URI: "/profile/raw_contact",
        // Querying Contacts
        CONTACT_SEARCHE: "/contacts/search_contact",
        // Contact Information
        CONTACT_URI: "/contacts/contact",
        // SMS database
        URI_MESSAGE_LOG: "dataability:///com.ohos.smsmmsability",
        // Querying SMs
        URI_MESSAGE_INFO_TABLE: "/sms_mms/sms_mms_info",
        // Statistic
        URI_MESSAGE_UNREAD_COUNT: "/sms_mms/sms_mms_info/unread_total",
        // Get the largest groupID
        URI_MESSAGE_MAX_GROUP: "/sms_mms/sms_mms_info/max_group",
        // Querying MMS Messages
        URI_MESSAGE_MMS_PART: "/sms_mms/mms_part",
        AUDIO_NAME: "recording2021111512454545.amr",
        // MMSC
        MMS_URL: "http://mmsc.monternet.com"
    },
    DELIVERY_REPORTS: {
        // Closed
        DISABLED: "0",
        // SMS
        SMS: "1",
        // MMS
        MMS: "2",
        // SMS and MMS
        SMS_AND_MMS: "3"
    },
    AUTO_RETRIEVE_MMS: {
        // OFF
        OFF: "0",
        // Non-roaming
        NOT_WHEN_ROAMING: "1",
        // All networks
        ALWAYS: "2"
    },
    SPN_CHINA: {
        // TELECOM
        TELECOM: "中国电信",
        // MOBILE
        MOBILE: "CMCC",
        // UNICOM
        UNICOM: "China Unicom",
    },
    contractPage: {
        // Go to New Contact
        PAGE_FLAG_SAVE_CONTACT: "page_flag_save_contact",
        // Edit Before Call
        PAGE_FLAG_EDIT_BEFORE_CALLING: "page_flag_edit_before_calling",
        // Save to Existing Contacts
        PAGE_FLAG_SAVE_EXIST_CONTACT: "page_flag_save_exist_contact",
        // The page for selecting a contact is displayed after an SMS message is sent.
        PAGE_FLAG_SINGLE_CHOOSE: "page_flag_single_choose",
        // Select Contact List Page
        PAGE_FLAG_CHOOSE_CONTACTS: "page_flag_choose_contacts",
        // Contact details page
        PAGE_FLAG_CONTACT_DETAILS: "page_flag_contact_details",
        // The My Business Card page is displayed.
        PAGE_FLAG_CALLING_CARD: "page_flag_card_details",
        // Querying MMS Data
        URI_MESSAGE_MMS_PART: "/sms_mms/mms_part"
    },
    MESSAGE_TAB_INDEX: {
        TAB_CAMERA: 0,
        TAB_PICTURE: 1,
        TAB_AUDIO: 2,
        TAB_MORE: 3
    },
    HIGHLIGHT_TYPE: {
        // Common data
        NORMAL: 0,
        // email
        EMAIL: 1,
        // Website
        URL: 2,
        // Telephone
        TEL: 3,
        // Time
        DATE: 4,
        // Verification Code
        NUM: 5
    },
    MESSAGE_TYPE: {
        // General Information
        NORMAL: 0,
        // theme
        THEME: 1,
        // slideshow
        PPT: 2,
        // Themes and Slides
        THEME_AND_PPT: 3,
    },
    MESSAGE_SHOW_TYPE: {
        // Common SM style
        NORMAL: 0,
        // Does not contain the picture theme style
        THEME_NO_IMAGE: 1,
        // Does not include picture slide styles
        PPT_NO_IMAGE: 2,
        // Slideshow Styles with Pictures
        PPT_IMAGE: 3,
        // Include Image Theme Styles
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