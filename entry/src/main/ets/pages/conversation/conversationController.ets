// @ts-nocheck
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
import router from "@system.router";
import Prompt from "@system.prompt";
import commonEvent from "@ohos.commonEvent";
import emitter from '@ohos.events.emitter';
import HiLog from "../../utils/HiLog"
import common from "../../data/commonData"
import commonEvent from "@ohos.commonEventManager";
import conversationService from "../../service/ConversationService";
import conversationListService from "../../service/ConversationListService";
import LooseObject from "../../data/LooseObject"
import commonService from "../../service/CommonService";
import settingService from "../../service/SettingService";
import { commonPasteboard } from "../../data/Pasteboard";
import telephoneUtil from "../../utils/TelephoneUtil";
import callService from "../../service/CallService";
import sendMsgService from "../../service/SendMsgService"
import MmsPreferences from "../../utils/MmsPreferences";
import dateUtil from "../../utils/DateUtil";
import NotificationService from "../../service/NotificationService";
import simCardService from "../../service/SimCardService";
import commonCtrl from "./common";
import AvatarColor from "../../model/common/AvatarColor";

const TAG = "ConversationController";
const ANIMATION_DURATION = 1500;
const TRANSFORM_SCALE_MIN = "1.0";
const TRANSFORM_SCALE_MAX = "3.0";
const COMMON_FILE_SIZE_STRING = "/300KB";

export default class ConversationController {
    private static sInstance: ConversationController;
    commonEventData: any = null;
    commonCtrl = commonCtrl.getInstance();
    // SMS message list update flag
    refresh: boolean = false;
    // Message deletion prompt
    strMsgDeleteDialogTip: Resource;
    // Click Status
    isClickStatus: boolean = false;
    // Whether information is locked
    hasLockMsg: boolean = false;
    // Select Status
    isSelectStatus: boolean = false;
    // Whether to select lock information
    isSelectLockMsg: boolean = false;
    // More Actions
    isShowMoreOperation: boolean = false;
    // The default value is false for determining whether the current day is the same.
    isLessOneDay: boolean = false;
    // Check whether full-screen conditions are met.
    isShowFullScreen: boolean = false;
    // Check whether all the options are selected.
    isMessageCheckAll: boolean = false;
    // Is it just a recording?
    isOnlyAudio: boolean = false;
    // Deleted Count
    selectDeleteMsgCount: number = 0;
    // Text entered in the text box, which is also the content of the SMS message to be sent.
    textValue: string = '';
    // Recording Animation Tasks
    drawRecordingTaskId: number = 0;
    // Tab option page. 0: Take a photo; 1: Take a picture; 2: Record a record; 3: More
    tabIndex: number = 1;
    // Text content of the tab option page
    tabTextList: Array<any> = [];
    // Recording Status
    isRecordingStatus: boolean = true;
    // Current recording time
    curRecordingTime: string = "00:00";
    // Size of the current recording file (KB)
    curSize: number = 0;
    // Recording Start Time
    startRecordTime: number = 0;
    // Airplane mode
    isFlightMode: boolean = false;
    // Information Attachment Size Tips
    msgSendTip: string = '';
    // Whether SMS messages can be sent.
    canSendMessage: boolean = false;
    // Whether the currently edited message is an MMS message
    isEditMms: boolean = false;
    // Size of the MM attachment to be edited.
    curEdtFileSize: number = 0;
    // Obtains the time display of a single selection.
    mmsTime: string = '';
    // SMS and MMS
    isMmsType: Resource;
    // Recipient
    isSendRecipient: boolean;
    // Contact First Name
    strContactsName: string = '';
    // Contact Phone Number
    strContactsNumber: string = '';
    // Contact Phone Number Formatting
    strContactsNumberFormat: string = '';
    // The attachment type is business card.
    isVCard: boolean = false;
    // Indicates whether the information is created.
    isNewMsg: boolean = false;
    // Number of Contacts
    contactsNum: number = 0;
    // business card
    vCard: {};
    // MM Edit List
    mmsEditList: Array<any> = [];
    // Information List
    mmsList: Array<any> = [];
    // Index of the selected information
    mmsIndex: number = 0;
    // Initial x-position
    rawX: string = '';
    // Initial y-position
    rawY: string = '';
    // Thumbnails in Gallery
    pictureListFromGallery: Array<any> = [];
    // Tab Title
    tabTitleText: Resource;
    // Send Toolbar Distance from Bottom Position
    sendBarMarginBottom: number = 0;
    // Tab Height
    tabHeight: number = common.int.TAB_HEIGHT;
    // Restoration task ID.
    restoreTimeoutId: number = 0;
    // Whether the animation is actually executed
    isTabHeightAnimation: boolean = false;
    // 0: default; 1: slide; 2: full screen
    tabSlideStatus: number = 0;
    // Sliding distance
    slideDistance: number = 0;
    // Start point coordinate of the slide
    slideStartPoint: LooseObject = {
        x: 0,
        y: 0
    };
    // Whether to slide up
    isTabSlideUp: number = 0;
    // Contact list, which is obtained from the contact app and used as an attachment for sending MMS messages.
    contactListFromContactApp: Array<any> = [];
    // Card slot
    slotId: number = 0;
    // Selected Contacts
    selectContacts: Array<any> = [];
    // Content in the recipient text box
    receiveContactValue: string = '';
    // Controls the display and hiding of the last div.
    isSendStatus: boolean = false;
    // ID of the session list.
    threadId: number = 0;
    // Indicates whether the page is a details page.
    isDetail: boolean = true;
    // Subscript to be resent
    reSendIndex: number = 0;
    // Whether the replication option is visible
    showText: boolean = true;
    // Search for the value passed
    searchKey: string = '';
    // Is it grass?
    isDraft: boolean = false;
    // Contents of the draft
    draftContent: string = '';
    draftGroupId: number = 0;
    // Can I double-click to cancel sending
    recallMessagesFlag: boolean = false;
    // Double-click Cancel Status
    doubleClickStatus: boolean = false;
    // Dynamic change sign from bottom
    distanceBottomFlag: boolean = false;
    // Deleting a Details Page
    hasDetailDelete: boolean = false;
    // Whether a contact exists
    hasExitContract: boolean = false;
    // Create a page for fetching and sending.
    isNewRecallMessagesFlag: boolean = false;
    // Recording animation
    recordingAnimation: LooseObject = {};
    // Animation Style Properties
    animationOptions: LooseObject = {};
    // Animation Style Attribute Object
    animationFrames: LooseObject = {};
    // Default rear camera
    cameraPattern: string = "back";
    pattern: string = '';
    // Lock or Not
    hasLock: boolean = false;
    // Highlight Message Type
    highlightsType: number = 0;
    // Highlight Message Content
    highlightsText: string = '';
    timeFormat: string = "00:01";
    // 0: normal; 1: notification
    smsType: number = 0;
    isPicCheckboxClicked: boolean = false;
    // Whether to support sending reports
    hasReport: boolean = false;
    messageType: number = common.MESSAGE_TYPE.NORMAL;
    textareaDatasource: Array<any> = [];
    pptTotalCount: number = 0;
    selectedTextareaIdx: -1;
    hasImage: boolean = false;
    hasContent: boolean = false;
    hasVcard: boolean = false;
    mmsAddType: number = 0;
    picItemSelectedIndex: number = -1;
    slideDuration: number = 5;
    slideDurations: Array<any> = [];
    hasDouble: boolean = true;
    searchContent: string = '';
    // Time
    mmsDateSet: Set<any> = new Set();
    photoFirstName: string = '';
    portraitColor: string = '';
    reg: RegExp = /^[\u4e00-\u9fa5_a-zA-Z]+$/;
    scroller: Scroller = new Scroller();

    static getInstance() {
        if (ConversationController.sInstance == null) {
            ConversationController.sInstance = new ConversationController();
        }
        return ConversationController.sInstance;
    }

    onInit() {
        HiLog.i(TAG, "onInit");
        this.initRouterData();
        this.initData();
        if (this.hasDouble) {
            this.initNewPageContracts();
            this.hasDouble = false;
        }
        // Obtains the actual data. You do not need to query the data when creating new data.
        if (!this.isNewMsg) {
            this.queryMessageDetail(this.strContactsNumber, this.threadId, () => {
            });
            this.scroller.scrollToIndex(this.mmsList.length - 1)
        }
        NotificationService.getInstance().cancelMessageNotify({
            threadIds: this.threadId,
            hasRead: 0
        }, res => {});
    }

    onShow() {
        HiLog.i(TAG, "onShow");
        // Check whether the Send button can be clicked.
        this.judgeSendBtnCanClicked();
        // Subscribe to PA
        this.subscribeDetail();
        // Check whether a contact exists.
        this.judgeContactExists();
        // Initialize the forwarded data
        this.initTransmitMeg();
        // Forwarding and sending
        this.transmitSend();
    }

    onHide() {
        HiLog.i(TAG, "onHide");
        this.unSubscribeDetail();
    }

    initData() {
        this.strMsgDeleteDialogTip = $r("app.string.msg_delete_dialog_con_tip2",
            this.selectDeleteMsgCount
        );
        this.tabTextList = [
            //      $r("app.string.msg_take_photos"),
            //      $r("app.string.msg_picture"),
            //      $r("app.string.msg_record"),
            //      $r("app.string.more_low")
        ];
        this.animationOptions = {
            duration: ANIMATION_DURATION,
            easing: "linear",
            fill: "forwards",
            iterations: "Infinity",
        };
        this.animationFrames = [
            {
                transform: {
                    scale: TRANSFORM_SCALE_MIN
                }
            },
            {
                transform: {
                    scale: TRANSFORM_SCALE_MAX
                }
            }
        ];
        //    this.pattern = $r("app.string.camera_post");
        this.initSlideDurations();
    }

    initSlideDurations() {
        let arr = [];
        for (let i = 1; i <= 10; i++) {
            arr.push(i);
        }
        this.slideDurations = arr;
    }

    release() {
        this.textValue = '';
        this.receiveContactValue = '';
        this.isDraft = false;
        this.mmsList = [];
    }

    initNewPageContracts() {
        let transmitContracts = [];
        if (this.strContactsNumber) {
            let contactsNames = this.strContactsName.split(",");
            let telephones = this.strContactsNumber.split(",");
            let telephoneFormat = this.strContactsNumberFormat.split(",");
            for (let index in contactsNames) {
                let item: LooseObject = {};
                item.contactName = contactsNames[index];
                item.telephone = telephones[index];
                if (contactsNames[index] == common.string.EMPTY_STR &&
                telephoneFormat[index] == common.string.EMPTY_STR) {
                    item.telephoneFormat = telephones[index];
                } else {
                    item.telephoneFormat = telephoneFormat[index];
                }
                item.headImage = common.string.EMPTY_STR;
                item.select = false;
                transmitContracts.push(item);
            }
        }
        this.commonCtrl.paramContact.transmitContracts = transmitContracts;
        this.commonCtrl.paramContact.isSelectContact = false;
        this.commonCtrl.paramContact.isNewRecallMessagesFlag = false;
    }

    initRouterData() {
        let routerParams: LooseObject = router.getParams();
        this.strContactsName =
            routerParams.strContactsName == undefined ? '' : routerParams.strContactsName;
        this.strContactsNumber =
            routerParams.strContactsNumber == undefined ? '' : routerParams.strContactsNumber;
        this.strContactsNumberFormat =
            routerParams.strContactsNumberFormat == undefined ? '' : routerParams.strContactsNumberFormat;
        this.contactsNum = routerParams.contactsNum == undefined ? 0 : routerParams.contactsNum;
        this.threadId = routerParams.threadId == undefined ? 0 : routerParams.threadId;
        this.isDraft = routerParams.isDraft == undefined ? false : routerParams.isDraft;
        this.draftContent = routerParams.draftContent == undefined ? '' : routerParams.draftContent;
        this.searchContent = routerParams.searchContent == undefined ? '' : routerParams.searchContent;
        this.isNewMsg = routerParams.isNewMsg == undefined ? false : routerParams.isNewMsg;
        this.portraitColor = AvatarColor.background.Color[Math.abs(parseInt(this.threadId, 10)) % 6];
        this.photoFirstNameDeal(this.strContactsName);
        this.dealSpecialPhoneNumber();
    }

    photoFirstNameDeal(strContactsName) {
        if(strContactsName !== common.string.EMPTY_STR && this.reg.test(strContactsName.substring(0, 1))) {
            this.photoFirstName = strContactsName.substring(0, 1).toUpperCase()
        } else {
            this.photoFirstName = '-1'
        }
    }

    // Handle invalid phone numbers that contain #, *, and dots in redirection from other applications.
    // Replace them with spaces.
    dealSpecialPhoneNumber() {
        if (!this.isPhoneNumber(this.strContactsNumber)) {
            this.strContactsNumber = this.replaceCode(this.strContactsNumber);
            this.strContactsNumberFormat = this.replaceCode(this.strContactsNumberFormat);
            if (this.strContactsName != common.string.EMPTY_STR) {
                this.strContactsName = common.string.EMPTY_STR;
            }
        }
    }

    replaceCode(str) {
        if (str != null && str.length != 0) {
            return str.replace(new RegExp(/e|-|#|\*|\./, "g"), common.string.EMPTY_STR);
        } else {
            return common.string.EMPTY_STR;
        }
    }

    titleBarCancel() {
        // Cancel button
        this.cancleCheckedAll();
        this.setSelectStatus(false);
    }

    onBackPress() {
        if (this.isSelectStatus) {
            // Multi-choice status
            this.isSelectStatus = false;
            this.cancleCheckedAll();
            return true;
        }
        let source = this.getMmsSource();
        this.insertAndUpdateSessionDraft(source, ()=> {
            this.release();
            router.back();
        });
        return true;
    }

    insertAndUpdateSessionDraft(source, callback) {
        // Create a draft. If the selected contact or content is empty, delete the draft.
        if (this.isNewMsg && this.isDraft) {
            if ((this.selectContacts.length == 0 && this.receiveContactValue == common.string.EMPTY_STR) ||
            (this.textValue == common.string.EMPTY_STR && source.length == 0)) {
                conversationListService.deleteMessageBySessionId([this.threadId]);
                this.deleteDraftData();
            }
        }
        let hasReport = settingService.judgeIsDeliveryReport(this.isEditMms);
        let hasAttachment = commonService.judgeIsAttachment(source);
        let actionData: LooseObject = {};
        actionData = {
            slotId: this.slotId,
            threadId: this.threadId,
            receiveContactValue: common.string.EMPTY_STR,
            selectContacts: [],
            content: this.textValue,
            isReceive: false,
            ownNumber: common.string.EMPTY_STR,
            isSender: 0,
            hasDraft: 1,
            hasReport: hasReport,
            isMms: this.isEditMms,
            mmsSource: source,
            groupId: this.draftGroupId,
            messageType: this.messageType,
            hasAttachment: hasAttachment
        }
        // The draft does not exist or the draft needs to be updated. The draft data on the new page needs to be saved.
        if (this.textValue != common.string.EMPTY_STR || source.length !== 0) {
            actionData.isNewMsg = this.isNewMsg;
            if (this.isNewMsg) {
                // If the selected contact is not empty
                if (this.selectContacts.length > 0) {
                    actionData.selectContacts = this.selectContacts;
                    conversationListService.insertSessionDraft(actionData, callback);
                }
                // If the recipient input field is not empty
                else if (this.receiveContactValue != common.string.EMPTY_STR) {
                    actionData.receiveContactValue = this.receiveContactValue;
                    // If the number entered in the text box is invalid, the system does not save the draft when the
                    // Back key is pressed.
                    if (this.isPhoneNumber(this.receiveContactValue)) {
                        conversationListService.insertSessionDraft(actionData, callback);
                    } else if (this.isDraft) {
                        // If the current draft is in draft state and the entered number is invalid, the current draft
                        // is deleted.
                        conversationListService.deleteMessageBySessionId([this.threadId]);
                        this.deleteDraftData();
                        callback();
                    } else {
                        callback();
                    }
                } else {
                    callback();
                }
            } else {
                // This is not a new scenario.
                actionData.telephone = this.strContactsNumber;
                conversationListService.insertSessionDraft(actionData, callback);
            }
        } else if (!this.isNewMsg && this.isDraft) {
            // If a draft exists, perform the following operations:
            this.dealSessionDraft(source);
            callback();
        } else {
            callback();
        }
    }

    // When the draft logic is set, the text content is empty and the page is not created, the session list data needs
    // to be updated.
    dealSessionDraft(source) {
        // Query the last content in the list
        let length = this.mmsList.length;
        let item = this.mmsList[length - 1];
        // Updating list data
        let threadIds = [this.threadId];
        let time = new Date();
        let content = item.content;
        let hasAttachment = false;
        if (item.isMsm) {
            content = commonService.getMmsContent(item.mms);
            hasAttachment = commonService.judgeIsAttachment(source);
        }
        let valueBucket = {
            "content": item.content,
            "has_draft": 0,
            "time": time.getTime(),
            "has_mms": item.isMsm ? 1 : 0,
            "has_attachment": hasAttachment ? 1 : 0
        }
        conversationListService.updateById(threadIds, valueBucket);
        this.deleteDraftData();
        this.isDraft = false;
    }

    cancleCheckedAll() {
        for (let element of this.mmsList) {
            element.isCbChecked = false;
        }
    }

    clickGroupCheckAll() {
        for (let element of this.mmsList) {
            element.isCbChecked = !this.isMessageCheckAll;
        }
        if (this.isMessageCheckAll) {
            this.setMessageCheckAll(common.int.CHECKBOX_SELECT_NONE);
        } else {
            this.setMessageCheckAll(common.int.CHECKBOX_SELECT_ALL);
        }
    }

    setMessageCheckAll(type) {
        HiLog.i(TAG, "setMessageCheckAll, isSelectStatus=" + this.isSelectStatus);
        if (!this.isSelectStatus) {
            return;
        }
        if (type == common.int.CHECKBOX_SELECT_ALL) {
            HiLog.i(TAG, "setMessageCheckAll, CHECKBOX_SELECT_ALL");
            this.selectDeleteMsgCount = this.mmsList.length;
            this.isMessageCheckAll = true;
            this.hasReport = false;
            let countLock = 0;
            // Check whether all of them are locked.
            for (let element of this.mmsList) {
                if (element.isCbChecked && element.isLock) {
                    countLock++;
                }
            }
            if (this.selectDeleteMsgCount == countLock) {
                this.hasLock = true;
            }
        } else if (type == common.int.CHECKBOX_SELECT_NONE) {
            HiLog.i(TAG, "setMessageCheckAll, CHECKBOX_SELECT_NONE");
            this.selectDeleteMsgCount = 0;
            this.isMessageCheckAll = false;
            this.hasLock = false;
            this.hasReport = false;
        } else {
            // The default value is CHECKBOX_SELECT_UNKNOWN. Check whether there is any unselected item.
            HiLog.i(TAG, "setMessageCheckAll, else");
            this.checkBoxSelectUnknow();
        }
    }

    checkBoxSelectUnknow() {
        HiLog.i(TAG, "checkBoxSelectUnknow, start");
        // The default value is CHECKBOX_SELECT_UNKNOWN. Check whether there is any unselected item.
        this.isMessageCheckAll = true;
        this.selectDeleteMsgCount = 0;
        let countLock = 0;
        let countReport = 0;
        for (let element of this.mmsList) {
            if (element.isCbChecked) {
                this.selectDeleteMsgCount++;
            } else if (this.isMessageCheckAll) {
                this.isMessageCheckAll = false;
            }
            if (element.isCbChecked && element.isLock) {
                countLock++;
            }
            if (element.isCbChecked && element.hasReport) {
                countReport++;
            }
        }
        // If one is selected and there is a lock
        if (this.selectDeleteMsgCount == 1 && countLock > 0) {
            this.hasLock = true;
        } else {
            this.hasLock = false;
        }
        // If all are checked and all are locked
        if (this.selectDeleteMsgCount == countLock) {
            this.hasLock = true;
        }
        if (countReport == 1) {
            this.hasReport = true;
        } else {
            this.hasReport = false;
        }
    }

    listCheckBoxChange(index, e) {
        // When API 7 is used, the isOn type is not boolean but is of the number type. If the isOn type is displayed,
        // an error may occur.
        let isCheck: string = e
        //    this.messageList[index].isCbChecked = isCheck == "1" ? true : false;
        let item = this.mmsList[index];
        item.isCbChecked = isCheck == "1" ? true : false;
        HiLog.i(TAG, `listCheckBoxChange, isCbChecked=${item.isCbChecked}, index=${index}, mmsIndex=${this.mmsIndex}`);
        this.mmsIndex = index;
        this.hasReport = item.hasReport;
        this.setMessageCheckAll(common.int.CHECKBOX_SELECT_UNKNOWN);
        if (this.selectDeleteMsgCount == 1) {
            let item;
            for (let element of this.mmsList) {
                if (element.isCbChecked) {
                    item = element;
                    break;
                }
            }
            if (item != null) {
                this.setGroupMoreMenu(item);
            }
        }
    }

    setGroupMoreMenu(item) {
        if (!item.isMsm) {
            this.hasContent = true;
            return;
        }
        this.hasContent = commonService.judgeIsSelectText(item.mms);
        this.hasImage = commonService.judgeIsImage(item.mms);
        if (item.isMsm && item.mms.length == 1 && item.mms[0].type == common.MSG_ITEM_TYPE.CARD) {
            this.hasVcard = true;
        } else {
            this.hasVcard = false;
        }
    }

    longPressSelected(index) {
        switch (index) {
            case 0:
            // duplicating
                this.copyText();
                break;
            case 1:
            // Forwarding
                this.transmitMsgSingle();
                break;
            case 2:
            // Delete
                this.deleteDialogShow();
                break;
            case 3:
            // Select Text
                this.gotoTextSelect(this.mmsIndex);
                break;
            case 4:
            // more
                this.more();
                break;
            case 5:
            // Save
                this.saveImage();
                break;
            default:
                break;
        }
    }

    // Initializing Forwarding Data
    initTransmitMeg() {
        let routerParams: LooseObject = router.getParams();
        if (routerParams.transmitFlag) {
            this.threadId = routerParams.threadId;
            this.slotId = MmsPreferences.getInstance().getSendMessageSlotId();
            this.contactsNum = this.contactsNum;
            this.strContactsName = routerParams.strContactsName;
            this.strContactsNumber = routerParams.strContactsNumber;
            this.strContactsNumberFormat = routerParams.strContactsNumberFormat;
            this.initNewPageContracts();
        }
    }

    // Forwarding and sending
    transmitSend() {
        // Send Flag
        let transmitFlag = router.getParams().transmitFlag;
        //Indicates whether the slide page is an MMS message.
        let isSlideDetail = router.getParams().isSlideDetail;
        if (transmitFlag) {
            if(isSlideDetail) {
                // Indicates whether the currently edited message is an MMS message.
                this.isEditMms = true;
                //this.mmsTransmitSend();
            } else {
                this.generalTransmitSend();
            }
        }
    }

    generalTransmitSend() {
        let transmitSource = router.getParams().transmitSource;
        let isSource = router.getParams().isContainerOriginSource;
        this.canSendMessage = false;
        for (let element of transmitSource) {
            let content = common.string.EMPTY_STR;
            if (isSource && !element.isMsm) {
                content = element.contentInfo + element.content;
            } else {
                content = element.content;
            }
            let actionData = {
                content: content,
                mmsSource: element.mms,
                msgUriPath: element.msgUriPath
            };
            this.delayTransmitSend(actionData, element.isMsm);
        }
    }

    delayTransmitSend(element, isMms) {
        this.queryMessageDetail(this.strContactsNumber, this.threadId, () => {
            this.sendSms(element.content, element.msgUriPath, isMms, element.mmsSource);
        });
    }

    sendSms(content, msgUriPath, isMms, mmsSource): void {
        // Sending an SMS Message on a Full-Screen Page
        this.isSendStatus = true;
        // Initialize the data to be sent.
        this.initSendSms(content, msgUriPath, isMms, mmsSource);
        this.slotId = MmsPreferences.getInstance().getSendMessageSlotId();
        let actionData: LooseObject = {
            slotId: this.slotId,
            destinationHost: this.strContactsNumber,
            content: content,
            isEditMms: isMms
        };
        this.dealNewRecallMessagesFlag(this.mmsList);
        HiLog.i(TAG, 'sendSms send start');
        // Cancel Sending and Normal Sending Methods
        this.sendInterval(actionData, this.mmsList);
        HiLog.i(TAG, 'sendSms send end');
        if (this.isEditMms) {
            this.isEditMms = false;
        }
    }

    initSendSms(content, msgUriPath, isMms, mmsSource) {
        // Obtain the day of the week.
        let item: LooseObject = {};
        item.date = common.string.EMPTY_STR;
        item.time = $r('app.string.just');
        item.timeMillisecond = new Date().getTime();
        dateUtil.convertTimeStampToDateWeek(item, false);
        dateUtil.fullDate(item);
        item.content = content;
        if (isMms) {
            item.msgType = common.MSG_ITEM_TYPE.IMAGE;
            item.msgUriPath = msgUriPath;
        }
        item.isFullScreenImg = false;
        let time = (this.mmsEditList.length != 0 && (this.mmsEditList[0].type == 3 || this.mmsEditList[0].type == 5)) ?
        this.mmsEditList[0].time : common.string.SUCCESS;
        item.audioTime = time;
        item.isCbChecked = false;
        item.isLock = false;
        item.isStared = false;
        item.isReceive = false;
        item.sendStatus = 1;
        item.subId = this.slotId;
        item.isMsm = isMms;
        this.contactsNum = this.strContactsNumber.split(',').length;
        item.contactsNum = this.contactsNum;
        item.cancelTimeCount = common.int.CANCEL_TIME_COUNT;
        item.mmsEditListTemp = this.fillmmsEditListTemp(msgUriPath, isMms);
        if (this.contactsNum > 1) {
            item.completeNumber = 0;
            item.failuresNumber = 0;
        }
        item.hasReport = settingService.judgeIsDeliveryReport(item.isMsm);
        item.mmsSource = mmsSource;
        if (this.isEditMms || isMms) {
            item.msgShowType = commonService.getDisplay(mmsSource);
            commonService.setItemMmsContent(item, mmsSource);
            item.content = this.dealItemContent(item.msgShowType, item.content, mmsSource);
        } else {
            item.msgShowType = common.MESSAGE_SHOW_TYPE.NORMAL;
        }
        this.mmsList.push(item);
    }

    fillmmsEditListTemp(msgUriPath, isMsm) {
        let mmsEditListTemp = [];
        if (this.recallMessagesFlag && isMsm) {
            let item = {};
            item.type = common.MSG_ITEM_TYPE.IMAGE;
            item.uriPath = msgUriPath;
            mmsEditListTemp.push(item);
        }
        return mmsEditListTemp;
    }

    dealNewRecallMessagesFlag(mmsList) {
        let count = common.int.MESSAGE_CODE_ZERO;
        for (let index in mmsList) {
            let item = mmsList[index];
            if (!item.isDraft) {
                count++;
            }
        }
        if (count == common.int.MESSAGE_CODE_ONE) {
            this.isNewRecallMessagesFlag = true;
            this.commonCtrl.paramContact.isNewRecallMessagesFlag = true;
        }
        if (count == common.int.MESSAGE_CODE_ZERO && this.isNewRecallMessagesFlag) {
            this.isNewMsg = true;
            this.isNewRecallMessagesFlag = false;
        }
    }

    // Single Forwarding
    transmitMsgSingle() {
        // Forwarding a single message
        let item: LooseObject = this.mmsList[this.mmsIndex];
        let transmitObj: LooseObject = {};
        let contactsName: string | Resource = common.string.EMPTY_STR;
        if (this.strContactsName && this.strContactsName != common.string.EMPTY_STR) {
            contactsName = $r('app.string.transmitContentReceive', this.strContactsName);
        } else {
            contactsName = $r('app.string.transmitContentReceive', this.strContactsNumberFormat);
        }
        transmitObj.contactsName = contactsName;
        transmitObj.isMsm = item.isMsm;
        transmitObj.msgShowType = item.msgShowType;
        transmitObj.mms = item.mms;
        transmitObj.content = item.content;
        transmitObj.msgUriPath = item.msgUriPath ? item.msgUriPath : common.string.EMPTY_STR;
        transmitObj.contentInfo = common.string.EMPTY_STR;
        transmitObj.msgType = item.msgType;
        let transmitContentList = [];
        transmitContentList.push(transmitObj);
        let transmitContent = item.isReceive ? contactsName : $r('app.string.transmitContent');
        this.jumpTransmitMsg(transmitContent, transmitContentList, item.isMsm);
    }

    jumpTransmitMsg(transmitContent, transmitContentList, isMms) {
        router.push({
            uri: 'pages/transmitmsg/transmitMsg',
            params: {
                threadId: this.threadId,
                doubleCard: false,
                transmitContent: transmitContent,
                transmitContentList: transmitContentList,
                isMulti: true,
                isMms: isMms,
                isMyStartPage: false
            }
        });
    }

    // Delete a dialog box.
    deleteDialogShow() {
        this.strMsgDeleteDialogTip = $r("app.string.msg_delete_dialog_con_tip1");
        let item = this.mmsList[this.mmsIndex];
        item.isShowMsgLongMenu = false
        HiLog.i(TAG, "deleteDialogShow, isShowMsgLongMenu=" + item.isShowMsgLongMenu);
        this.hasLockMsg = item.isLock;
        if (!item.isMsm) {
            this.hasContent = true;
            return;
        }
    }

    // more
    more() {
        this.setTabOperationStatus(false);
        this.distanceBottomFlag = false;
        let item = this.mmsList[this.mmsIndex];

        item.isCbChecked = !item.isCbChecked;
        item.isShowMsgLongMenu = false;
        HiLog.i(TAG, "more, isShowMsgLongMenu=" + item.isShowMsgLongMenu);
        this.setSelectStatus(true);
        this.hasDetailDelete = false;
        this.setMessageCheckAll(common.int.CHECKBOX_SELECT_UNKNOWN);
        this.hasReport = item.hasReport;
        this.setGroupMoreMenu(item);
    }

    setTabOperationStatus(flag) {
        this.isShowMoreOperation = flag;
        // Value type. The HTML page is refreshed only when the value type is numeric.
        if (flag) {
            this.sendBarMarginBottom = common.int.TAB_HEIGHT;
        } else {
            this.sendBarMarginBottom = 0;
        }
    }

    setSelectStatus(isSelect) {
        this.isSelectStatus = isSelect;
    }

    // Event of pressing and holding an SMS message
    mmsListLongPress(index) {
        for (let i = 0; i < this.mmsList.length; i++) {
            if (index == i) {
                this.mmsList[index].isShowMsgLongMenu = true;
            } else {
                this.mmsList[i].isShowMsgLongMenu = false;
            }
        }
        this.refresh = !this.refresh
        this.mmsIndex = index;
        if (this.isSelectStatus) {
            this.mmsList[index].isCbChecked = !this.mmsList[index].isCbChecked;
            this.setMessageCheckAll(common.int.CHECKBOX_SELECT_UNKNOWN);
            return;
        }
        this.hasContent = false;
        this.hasImage = false;
        let item = this.mmsList[index];
        let menuId = common.string.EMPTY_STR;
        if (item.isMsm) {
            this.setGroupMoreMenu(item);
            //      menuId = "menu_long_press_mms";
        } else {
            //      menuId = "menu_long_press";
        }
        //    setTimeout(() => {
        //      this.$element(menuId).show({
        //        x: this.rawX,
        //        y: this.rawY
        //      });
        //    },100);
    }

    touchStart(e) {
        this.rawX = e.globalX;
        this.rawY = e.globalY;

    }

    deleteDialogCancel() {
        // Cancel Ejection
        this.isSelectLockMsg = false;
        HiLog.i(TAG, "deleteDialogCancel, isSelectLockMsg=false")
    }

    deleteDialogConfirm() {
        let groupIds = [];
        let mmsListCopy = [];
        HiLog.i(TAG, "deleteDialogConfirm, isSelectStatus=" + this.isSelectStatus);
        if (this.isSelectStatus) {
            // Delete the selected item through the filter.
            for (let element of this.mmsList) {
                if (!element.isCbChecked || (element.isLock && !this.isSelectLockMsg)) {
                    this.setDateShow(element, mmsListCopy);
                    mmsListCopy.push(element);
                } else {
                    groupIds.push(element.groupId);
                }
            }
            // Set to non-multi-choice status
            this.setSelectStatus(false);
            this.mmsList = mmsListCopy;
        } else if ((this.mmsList[this.mmsIndex] != undefined && !this.mmsList[this.mmsIndex].isLock) || this.isSelectLockMsg) {
            let item = this.mmsList[this.mmsIndex];
            for (let i = 0; i < this.mmsList.length; i++) {
                if (this.mmsIndex == i) {
                    continue;
                } else {
                    this.setDateShow(this.mmsList[i], mmsListCopy);
                    mmsListCopy.push(this.mmsList[i]);
                }
            }
            this.mmsList = mmsListCopy;
            HiLog.i(TAG, "deleteDialogConfirm, mmsList.length=" + this.mmsList.length);
            groupIds.push(item.groupId);
        }
        this.isSelectLockMsg = false;
        this.cancleCheckedAll();
        if (groupIds.length > 0) {
            this.deleteMessageByGroupIds(groupIds);
            // Check whether the length of the deleted list is 0.
            if (this.mmsList.length === 0 && this.textValue === common.string.EMPTY_STR) {
                globalThis.needToUpdate = true;
                this.deleteMessageById(this.threadId);
                router.back();
            } else {
                this.updateSessionLock(false);
                this.updateLastItemContent();
            }
        }
        // After the deletion is complete, check whether all data is deleted.
    }

    deleteMessageByGroupIds(groupIds) {
        let actionData = {
            groupIds: groupIds,
        };
        // Invoke the database deletion method.
        conversationService.deleteMessageByGroupIds(actionData);
    }

    // Updates the lock status of the session list.
    updateSessionLock(isLock) {
        let threadIds = [this.threadId];
        let hasLock = isLock ? 1 : 0;
        let valueBucket = {
            "has_lock": hasLock,
        }
        if (!isLock) {
            // If you want to unlock the status, you must unlock all the statuses before unlocking the statuses.
            let unlockCount = 0;
            for (let element of this.mmsList) {
                if (!element.isLock) {
                    unlockCount++;
                }
            }
            if (unlockCount != this.mmsList.length) {
                HiLog.w(TAG, "updateSessionLock, it is not all select unlock");
                return;
            }
        }
        // If it is locked, update the status to locked.
        conversationListService.updateById(threadIds, valueBucket);
    }

    updateLastItemContent() {
        let actionData = {
            mmsList: this.mmsList,
            threadId: this.threadId,
        };
        conversationListService.updateLastItemContent(actionData);
    }

    deleteMessageById(threadId) {
        let threadIds = [threadId];
        // Deleting Database Data
        let actionData = {
            threadIds: threadIds,
        };
        conversationListService.deleteMessageById(actionData);
    }

    clickGroupDelete() {
        if (this.selectDeleteMsgCount == 0) {
            return;
        }
        if (this.selectDeleteMsgCount == 1) {
            this.strMsgDeleteDialogTip = $r("app.string.msg_delete_dialog_con_tip1");
        } else if (this.selectDeleteMsgCount == this.mmsList.length) {
            this.strMsgDeleteDialogTip = $r("app.string.msg_delete_dialog_con_tip3");
        } else {
            this.strMsgDeleteDialogTip = $r("app.string.msg_delete_dialog_con_tip2", this.selectDeleteMsgCount);
        }
        this.hasLockMsg = (this.mmsList.some((element, index) => element.isCbChecked && element.isLock));
    }

    // Check whether a contact exists.
    judgeContactExists() {
        let telephones = [this.strContactsNumber];
        let actionData = {
            telephones: telephones
        };
        conversationService.judgeContactExists(actionData, result => {
            this.hasExitContract = result;
        });
        if (this.strContactsName == common.string.EMPTY_STR) {
            this.hasExitContract = false;
        } else {
            this.hasExitContract = true;
        }
    }

    /**
     * Obtain information details.
     *
     * @param telephone
     * @param threadId
     * @param callback
     */
    queryMessageDetail(telephone, threadId, callback) {
        let actionData: LooseObject = {};
        if (telephone != common.string.EMPTY_STR) {
            actionData.telephone = telephone;
        }
        if (threadId != common.string.EMPTY_STR) {
            actionData.threadId = threadId;
        }
        actionData.contactsNum = this.contactsNum;
        conversationService.queryMessageDetail(actionData, result => {
            if (result.code == common.int.SUCCESS) {
                this.initIsShowMsgLongMenu(result);
                this.dealMessageDetailTime(result);
                this.dealMessageDetailContent(result);
                if (this.mmsList.length == 0 && this.isDraft) {
                    HiLog.i(TAG, "queryMessageDetail, isNewMsg = true");
                    this.isNewMsg = true;
                }
            } else {
                HiLog.w(TAG, "queryMessageDetail, failed");
            }
            if (this.isDraft) {
                this.setDraft();
            }
            this.deleteDraftData();
            callback();
        });
    }

    initIsShowMsgLongMenu(result) {
        for (let item of result.response) {
            item.isShowMsgLongMenu = false;
        }
    }

    dealItemContent(showType, content, mmsSource) {
        let strContent = content;
        if (showType == common.MESSAGE_SHOW_TYPE.THEME_NO_IMAGE || showType == common.MESSAGE_SHOW_TYPE.THEME_IMAGE) {
            if (content !== common.string.EMPTY_STR) {
                strContent = $r("app.string.msg_theme") + ": " + content;
            }
        } else if (showType == common.MESSAGE_SHOW_TYPE.PPT_NO_IMAGE) {
            strContent = (content == common.string.EMPTY_STR) ? $r("app.string.msg_slide") : content;
        } else if (showType == common.MESSAGE_SHOW_TYPE.PPT_IMAGE) {
            if (mmsSource[0].msgType == common.MSG_ITEM_TYPE.THEME && content !== common.string.EMPTY_STR) {
                strContent = $r("app.string.msg_theme") + ": " + content;
            } else {
                strContent = (content == common.string.EMPTY_STR) ? $r("app.string.msg_slide") : content;
            }
        }
        return strContent;
    }

    dealMessageDetailContent(result) {
        for (let item of result.response) {
            item.content = this.dealItemContent(item.msgShowType, item.content, item.mms);
        }
    }

    dealMessageDetailTime(result) {
        if (result.response && result.response.length > 0) {
            let resultList = [];
            for (let item of result.response) {
                item.timeMillisecond = parseInt(item.timeMillisecond);
                dateUtil.fullDate(item);
                dateUtil.convertTimeStampToDateWeek(item, false);
                this.setDateShow(item, resultList);
                dateUtil.convertDateFormatForItem(item, false);
                if (item.sendStatus == common.int.SEND_DRAFT) {
                    this.dealDraftData(item);
                } else {
                    resultList.push(item);
                }
            }
            this.mmsList = resultList;
        }
    }

    deleteDraftData() {
        if (this.isDraft && this.draftGroupId > 0) {
            let groupIds = [this.draftGroupId];
            this.deleteMessageByGroupIds(groupIds);
            this.draftGroupId = 0;
        }
    }

    getMmsDataSource(mmsSource, first) {
        this.pptTotalCount = (first.msgType == common.MSG_ITEM_TYPE.THEME) ? -1 : 0;
        let mms = [];
        let textareas = [];
        mmsSource.forEach((source, index) => {
            this.pptTotalCount++;
            let mmsObj = null;
            if (source.msgType == common.MSG_ITEM_TYPE.AUDIO ||
            source.msgType == common.MSG_ITEM_TYPE.IMAGE ||
            source.msgType == common.MSG_ITEM_TYPE.VIDEO) {
                mmsObj = {
                    type: source.msgType,
                    uriPath: source.msgUriPath,
                    time: source.time,
                    index: this.pptTotalCount,
                    fileSize: first.fileSize
                };
                mms.push(mmsObj);
            }
            let placeholder = $r("app.string.enter_text");
            if (source.msgType == common.MSG_ITEM_TYPE.THEME) {
                placeholder = $r("app.string.msg_theme");
            } else if (mmsSource[0].msgType == common.MSG_ITEM_TYPE.THEME && mmsSource.length == 2) {
                if (mmsObj) {
                    placeholder = $r("app.string.msg_note_mms2");
                } else {
                    placeholder = $r("app.string.msg_note_mms");
                }
                this.pptTotalCount = 0;
            }
            let obj = {
                textValue: source.content,
                placeholder: placeholder,
                pptIndex: this.pptTotalCount,
                mms: mmsObj
            };
            textareas.push(obj);
        });
        this.mmsEditList = mms;
        this.textareaDatasource = textareas;
    }

    setMmsDataSource(mmsSource) {
        this.mmsEditList = [];
        this.textareaDatasource = [];
        let first = mmsSource[0];
        this.messageType = first.messageType;
        if (this.messageType == common.MESSAGE_TYPE.NORMAL) {
            let arr = [];
            mmsSource.forEach(item => {
                let obj = {
                    type: item.msgType,
                    uriPath: item.msgUriPath,
                    time: item.time,
                    fileSize: item.fileSize
                }
                arr.push(obj);
            });
            this.mmsEditList = arr;
        } else {
            this.getMmsDataSource(mmsSource, first);
        }
    }

    dealDraftData(item) {
        this.isDraft = true;
        this.draftContent = item.content;
        this.draftGroupId = item.groupId;
        if (item.isMsm) {
            this.isEditMms = true;
            this.setMmsDataSource(item.mms);
        } else {
            this.messageType = common.MESSAGE_TYPE.NORMAL;
        }
    }
    // Set Draft Content
    setDraft() {
        // If the content is a draft, the draft content needs to be displayed.
        if (this.isDraft) {
            this.textValue = this.draftContent;
            this.canSendMessage = MmsPreferences.getInstance().haveSimCardReady();
        }
    }

    updateDetail(threadId, sendResult) {
        let sendResults = [];
        sendResults.push(sendResult);
        let actionData = {
            sendResults: sendResults,
            threadId: threadId
        }
        conversationService.updateSessionAndDetail(actionData);
        let sendStatus = sendResult.sendStatus
        let deliveryReportSwitch = MmsPreferences.getInstance().getValueOfDeliveryReportSwitch();
        HiLog.i(TAG, "updateDetail, sendStatus=" + sendStatus + ", deliveryReportSwitch=" + deliveryReportSwitch)
        if ((deliveryReportSwitch == common.DELIVERY_REPORTS.SMS_AND_MMS ||
        deliveryReportSwitch == common.DELIVERY_REPORTS.SMS) &&
        sendStatus == common.int.SEND_MESSAGE_SUCCESS) {
            let msg = this.strContactsNumber + " 已收到消息！"
            this.showToast(msg)
        }
    }

    showToast(msg) {
        Prompt.showToast({
            message: msg,
            duration: 2000,
        });
    }

    // Setting the Sending Status
    setCanSendMsgStatus() {
        if (this.receiveContactValue == common.string.EMPTY_STR && this.selectContacts.length == 0) {
            this.canSendMessage = false;
        }
    }

    // Obtains the size of the current MMS file.
    getCurEdtFileSize() {
        this.curEdtFileSize = 0;
        if (!this.isEditMms || this.mmsEditList.length == 0) {
            return;
        }
        for (let element of this.mmsEditList) {
            this.curEdtFileSize += element.fileSize;
        }
    }

    dealMmsSendResult(sendNumber, item, sendResult) {
        HiLog.i(TAG, "dealMmsSendResult, start")
        // MMS Sending
        sendResult.sendStatus = common.int.SEND_MESSAGE_SUCCESS;
        item.sendStatus = common.int.SEND_MESSAGE_SUCCESS;
        this.updateDetail(this.threadId, sendResult);
        // The MMS message will be sent for receiving and using.
        if (sendNumber.length == 1 && sendResult.sendStatus == common.int.SEND_MESSAGE_SUCCESS) {
            setTimeout(() => {
                //        this.publishData(sendResult.telephone, item.mmsSource);
            }, 1000);
        }
        let params = {
            mmsSource: item.mmsSource
        };
        sendMsgService.sendMmsMessage(params, (sendStatus) => {
        });
    }

    dealSmsSendResult(params, item, sendResult) {
        sendMsgService.sendMessage(params, (sendStatus) => {
            HiLog.i(TAG, "dealSmsSendResult, sendMessage sendStatus: " + sendStatus);
            item.sendStatus = sendStatus;
            if (sendStatus === common.int.SEND_MESSAGE_FAILED) {
                item.failuresNumber = item.failuresNumber + 1;
            }
            item.completeNumber = item.completeNumber + 1;
            sendResult.sendStatus = sendStatus;
            // Update sending status
            this.updateDetail(this.threadId, sendResult);
            this.refresh = !this.refresh
        });
    }

    getSendMessageId(initDatas, telephone) {
        for (let initData of initDatas) {
            if (initData.telephone == telephone) {
                return initData.id;
            }
        }
    }

    convertingSms() {
        // Convert to SMS
        this.isEditMms = false;
        this.showToast($r("app.string.converting_sms"));
    }

    dealSendResult(actionData, item, initDatas) {
        HiLog.i(TAG, "dealSendResult, start")
        // Add sending information to the list.
        let sendNumbers: Array<string> = actionData.hosts;
        let content: string = actionData.content;
        for (let i = 0; i < sendNumbers.length; i++) {
            let params: LooseObject = {
                slotId: actionData.slotId,
                destinationHost: sendNumbers[i],
                content: content,
            };
            let id = this.getSendMessageId(initDatas, sendNumbers[i]);
            let sendResult: LooseObject = {
                id: id,
                telephone: sendNumbers[i],
                content: content,
            }
            if (!item.isMsm) {
                this.dealSmsSendResult(params, item, sendResult);
            } else {
                this.dealMmsSendResult(sendNumbers, item, sendResult);
            }
        }
    }

    insertInitData(actionData, item, callback): void {
        let sendNumbers: Array<string> = actionData.hosts;
        let insertSendResults: Array<LooseObject> = [];
        for (let i = 0; i < sendNumbers.length; i++) {
            let sendResult: LooseObject = {
                slotId: actionData.slotId,
                telephone: sendNumbers[i],
                content: actionData.content,
                sendStatus: common.int.SEND_MESSAGE_SENDING
            }
            if (item.isMsm) {
                sendResult.content = commonService.getMmsContent(item.mmsSource);
            }
            insertSendResults.push(sendResult);
        }
        let hasReport: number = settingService.judgeIsDeliveryReport(item.isMsm) ? 1 : 0;
        let hasAttachment: boolean = commonService.judgeIsAttachment(item.mmsSource);
        let actionData_: LooseObject = {
            sendResults: insertSendResults,
            isReceive: false,
            ownNumber: common.string.EMPTY_STR,
            isSender: 0,
            hasDraft: this.isDraft,
            hasReport: hasReport,
            isMms: item.isMsm,
            mmsSource: item.mmsSource,
            hasAttachment: hasAttachment
        }
        conversationService.insertSessionAndDetail(actionData_, callback);
    }

    changeReceiveContactValue(value) {
        this.receiveContactValue = value
    }

    updatePreview(idx) {
        // Delete Preview
        HiLog.i(TAG, "updatePreview, idx: " + idx);
        // If not audio (picture or video) is deleted from the preview, you need to change the value of
        // checkbox in the thumbnail of the gallery.
        if (this.mmsEditList[idx].type != common.MSG_ITEM_TYPE.AUDIO) {
            let that = this;
            this.pictureListFromGallery.forEach(function (item) {
                if (item.path == that.mmsEditList[idx].uriPath) {
                    item.checkedValue = false;
                    that.curEdtFileSize -= that.mmsEditList[idx].fileSize;
                    that.msgSendTip = Math.ceil(that.curEdtFileSize) + COMMON_FILE_SIZE_STRING;
                }
            });
        }
        this.isOnlyAudio = !this.mmsEditList.some((item, index) => item.type != common.MSG_ITEM_TYPE.AUDIO);
        if (this.mmsEditList.length == 0) {
            this.convertingSms();
        }
    }

    initSendItem() {
        // Obtains the day of the week.
        HiLog.i(TAG, "initSendItem, start")
        let item: LooseObject = {};
        item.date = common.string.EMPTY_STR;
        item.time = $r("app.string.justNow");
        item.timeMillisecond = new Date().getTime();
        dateUtil.convertTimeStampToDateWeek(item, false);
        dateUtil.fullDate(item);
        item.content = this.textValue;
        item.msgType = this.mmsEditList.length != 0 ? this.mmsEditList[0].type : common.MSG_ITEM_TYPE.TEXT;
        item.isFullScreenImg = false;
        item.msgUriPath = this.mmsEditList.length != 0 ? this.mmsEditList[0].uriPath : common.string.EMPTY_STR;
        let time = (this.mmsEditList.length != 0 && (this.mmsEditList[0].type == 3 || this.mmsEditList[0].type == 5)) ?
            this.mmsEditList[0].time : common.string.SUCCESS;
        item.audioTime = time;
        item.isCbChecked = false;
        item.isLock = false;
        item.isStared = false;
        item.isReceive = false;
        item.sendStatus = 1;
        item.cancelTimeCount = common.int.CANCEL_TIME_COUNT;
        item.subId = this.slotId;
        item.mmsEditListTemp = this.mmsEditList;
        if (this.contactsNum > 1) {
            item.completeNumber = 0;
            item.failuresNumber = 0;
        }
        item.hasReport = settingService.judgeIsDeliveryReport(item.isMsm);
        item.msgShowType = this.getMsgShowType(item);
        item.mmsSource = this.getMmsSource();
        item.isMsm = this.isEditMms;
        this.setDateShow(item, this.mmsList);
        this.mmsList.push(item);
        this.refresh = !this.refresh
    }
    // Check whether the time on the top of each SMS message is displayed.
    setDateShow(item, list) {
        item.dateShow = true;
        let tempDateId = item.date.id;
        let tempWeekId = item.week.id;
        if (list.length > 0) {
            item.dateShow =
            (tempDateId != (list[list.length-1]).date.id)
            && (tempWeekId != (list[list.length-1]).week.id)
        }
    }

    getMmsSource() {
        HiLog.i(TAG, "getMmsSource, start")
        let sources = [];
        this.dealTextareaDataSource();
        if (this.messageType === common.MESSAGE_TYPE.NORMAL) {
            sources = this.dealMmsEditList();
        } else {
            sources = this.getMmsSourceFromDataSource();
        }
        return sources;
    }

    dealTextareaDataSource() {
        HiLog.i(TAG, "dealTextareaDataSource, start")
        if (this.messageType == common.MESSAGE_TYPE.THEME) {
            let first = this.textareaDatasource[0];
            if (first.textValue == common.string.EMPTY_STR) {
                this.messageType = common.MESSAGE_TYPE.NORMAL;
                this.textValue = this.textareaDatasource[1].textValue;
                this.textareaDatasource = [];
            }
        }
    }

    dealMmsEditList() {
        HiLog.i(TAG, "dealMmsEditList, start")
        let sources = [];
        if (this.mmsEditList.length != 0) {
            this.mmsEditList.forEach((item, index) => {
                let mms = {
                    msgType: item.type,
                    msgUriPath: item.uriPath,
                    content: common.string.EMPTY_STR,
                    time: item.time,
                    fileSize: item.fileSize
                }
                if (index === 0) {
                    mms.content = this.textValue;
                }
                sources.push(mms);
            });
        }
        return sources;
    }

    getMmsSourceFromDataSource() {
        HiLog.i(TAG, "getMmsSourceFromDataSource, start")
        let sources = [];
        this.textareaDatasource.forEach((item, index) => {
            let mms = {
                msgType: common.MSG_ITEM_TYPE.TEXT,
                msgUriPath: '',
                content: item.textValue,
                time: '',
                fileSize: 0
            };
            if (index === 0 && (this.messageType === common.MESSAGE_TYPE.THEME ||
            this.messageType === common.MESSAGE_TYPE.THEME_AND_PPT)) {
                mms.msgType = common.MSG_ITEM_TYPE.THEME;
                sources.push(mms);
            } else if (this.messageType === common.MESSAGE_TYPE.THEME) {
                sources.push(mms);
                sources = this.getMmsSourceByTheme(sources, item, mms);
            } else {
                if (item.mms) {
                    mms.msgType = item.mms.type;
                    mms.msgUriPath = item.mms.uriPath;
                    mms.time = item.mms.time;
                    mms.fileSize = item.mms.fileSize;
                }
                sources.push(mms);
            }
        });
        return sources;
    }

    getMmsSourceByTheme(sources, item, mms) {
        HiLog.i(TAG, "getMmsSourceByTheme, start")
        if (this.mmsEditList.length === 1) {
            let first = this.mmsEditList[0];
            sources.unshift({
                msgType: first.type,
                msgUriPath: first.uriPath,
                content: item.textValue,
                time: first.time,
                fileSize: first.fileSize
            });
        } else {
            this.getMmsSourceByItem(sources, mms);
        }
        let arr = JSON.parse(JSON.stringify(sources));
        return arr;
    }

    getMmsSourceByItem(sources, mms) {
        HiLog.i(TAG, "getMmsSourceByItem, start")
        this.mmsEditList.forEach((list, i) => {
            if (i === 0) {
                mms.msgType = list.type;
                mms.msgUriPath = list.uriPath;
                mms.time = list.time;
                mms.fileSize = list.fileSize;
            } else {
                let mmsObj = {
                    msgType: list.type,
                    msgUriPath: list.uriPath,
                    content: common.string.EMPTY_STR,
                    time: list.time,
                    fileSize: list.fileSize
                };
                sources.push(mmsObj);
            }
        });
    }

    getMsgShowType(item) {
        HiLog.i(TAG, "getMsgShowType, start")
        let type = common.MESSAGE_SHOW_TYPE.NORMAL;
        let slideString = "msg_slide";
        if (this.messageType === common.MESSAGE_TYPE.NORMAL && this.mmsEditList.length <= 1) {
            type = common.MESSAGE_SHOW_TYPE.NORMAL;
            item.content = this.textValue;
        } else if (this.messageType === common.MESSAGE_TYPE.THEME && this.mmsEditList.length === 1) {
            type = common.MESSAGE_SHOW_TYPE.THEME_IMAGE;
            item.content = this.getThemeContent();
        } else {
            type = this.getMsgShowTypePpt(item, slideString);
        }
        if (type == common.MESSAGE_SHOW_TYPE.PPT_NO_IMAGE || type == common.MESSAGE_SHOW_TYPE.PPT_IMAGE) {
            if (item.content == common.string.EMPTY_STR) {
                item.content = slideString;
            }
        }
        return type;
    }

    getMsgShowTypePpt(item, slideString) {
        HiLog.i(TAG, "getMsgShowTypePpt, start")
        let type = common.MESSAGE_SHOW_TYPE.NORMAL;
        let hasSource = this.textareaDatasource.length > 0 ? true : false;
        let firstStr = hasSource ? this.textareaDatasource[0].textValue : common.string.EMPTY_STR;
        if (this.mmsEditList.length === 0) {
            type = common.MESSAGE_SHOW_TYPE.PPT_NO_IMAGE;
            if (this.messageType === common.MESSAGE_TYPE.THEME ||
            this.messageType === common.MESSAGE_TYPE.THEME_AND_PPT) {
                item.content = this.getThemeContent();
            } else {
                item.content = (firstStr == common.string.EMPTY_STR) ? slideString : firstStr;
            }
        } else {
            type = this.getPPTType();
            this.getMsgShowTypeContent(item, firstStr, slideString);
        }
        return type;
    }

    getPPTType() {
        HiLog.i(TAG, "getPPTType, start")
        let type = common.MESSAGE_SHOW_TYPE.NORMAL;
        if (this.messageType === common.MESSAGE_TYPE.NORMAL && this.mmsEditList.length > 0) {
            type = common.MESSAGE_SHOW_TYPE.PPT_IMAGE;
        } else {
            let firstMms = null;
            if (this.messageType === common.MESSAGE_TYPE.THEME && this.mmsEditList.length > 1) {
                firstMms = this.mmsEditList[0];
            } else if (this.messageType === common.MESSAGE_TYPE.THEME_AND_PPT) {
                firstMms = this.textareaDatasource[1].mms;
            } else {
                firstMms = this.textareaDatasource[0].mms;
            }
            if (this.mmsEditList.length >= 1 && firstMms &&
            (firstMms.type === common.MSG_ITEM_TYPE.IMAGE || firstMms.type === common.MSG_ITEM_TYPE.VIDEO)) {
                type = common.MESSAGE_SHOW_TYPE.PPT_IMAGE;
            } else {
                type = common.MESSAGE_SHOW_TYPE.PPT_NO_IMAGE;
            }
        }
        return type;
    }

    getMsgShowTypeContent(item, firstStr, slideString) {
        HiLog.i(TAG, "getMsgShowTypeContent, start")
        if (this.messageType === common.MESSAGE_TYPE.THEME_AND_PPT ||
        this.messageType === common.MESSAGE_TYPE.THEME) {
            item.content = this.getThemeContent();
        } else {
            let content = common.string.EMPTY_STR;
            if (this.messageType === common.MESSAGE_TYPE.NORMAL) {
                content = (this.textValue == common.string.EMPTY_STR) ? slideString : this.textValue;
            } else {
                content = (firstStr == common.string.EMPTY_STR) ? slideString : firstStr;
            }
            item.content = content;
        }
    }

    getThemeContent() {
        HiLog.i(TAG, "getThemeContent, start")
        this.isEditMms = true;
        let content = '';
        let first = this.textareaDatasource[0].textValue;
        let text = this.textareaDatasource[1].textValue;
        if (first !== common.string.EMPTY_STR) {
            content = $r("app.string.msg_theme") + ": " + first;
        }
        if (text !== common.string.EMPTY_STR) {
            if (content === common.string.EMPTY_STR) {
                content = text;
            } else {
                content = content + "\n" + text;
            }
        }
        return content;
    }

    sendMassMessage(actionData, item) {
        this.insertInitData(actionData, item, result => {
            // Processing the sent result
            if (this.threadId != result.rowId) {
                // When modifying the recipient information, click Send and delete the session before the modification.
                conversationListService.deleteMessageBySessionId([this.threadId]);
            }
            this.threadId = result.rowId;
            this.portraitColor = AvatarColor.background.Color[Math.abs(parseInt(this.threadId, 10)) % 6];
            item.groupId = result.groupId;
            item.id = result.initDatas[0].id;
            this.refresh = !this.refresh
            // Sending and processing the sending result
            this.dealSendResult(actionData, item, result.initDatas);
        });
    }

    clearMsm() {
        if (this.isEditMms) {
            this.isEditMms = false;
        }
        // Deleting the preview image of an MMS message
        if (this.mmsEditList.length != 0) {
            for (let index in this.mmsEditList) {
                this.updatePreview(index);
            }
            this.mmsEditList = [];
        }
    }

    resetMmsSource() {
        this.textareaDatasource = [];
        this.mmsEditList = [];
        this.pptTotalCount = 0;
        this.messageType = common.MESSAGE_TYPE.NORMAL;
        this.selectedTextareaIdx = -1;
    }

    send() {
        HiLog.i(TAG, "send, start");
        // The Send button is dimmed and messages cannot be sent.
        if (!this.canSendMessage) {
            HiLog.w(TAG, "send, canSendMessage=false");
            return;
        }
        // Switching from the new state to the session state
        if (this.isNewMsg) {
            HiLog.i(TAG, "send, isNewMsg=true");
            this.newSend(() => {
                this.sendDataRefresh();
            });
        } else {
            this.sendDataRefresh();
        }
    }

    sendDataRefresh() {
        this.isSendStatus = true;
        this.slotId = MmsPreferences.getInstance().getSendMessageSlotId();
        if (this.textValue != common.string.EMPTY_STR || this.mmsEditList.length != 0 ||
        this.textareaDatasource.length != 0) {
            this.initSendItem();
        }
        let actionData: LooseObject = {
            slotId: this.slotId,
            destinationHost: this.strContactsNumber,
            content: this.textValue,
            isEditMms: this.isEditMms
        };
        // Real SMS Sending
        this.sendInterval(actionData, this.mmsList);
        this.textValue = common.string.EMPTY_STR;
        this.canSendMessage = false;
        this.isShowFullScreen = false;
        this.clearMsm();
        this.resetMmsSource();
        this.setTabOperationStatus(false);
        this.distanceBottomFlag = false;
        this.receiveContactValue = common.string.EMPTY_STR;
        this.selectContacts = [];
        this.isNewMsg = false;
    }

    isPhoneNumber(str) {
        // Determine whether the value is a number.
        let reg = /^\d{1,}$/;
        let pattern = new RegExp(reg);
        return pattern.test(str);
    }

    newSend(callback) {
        // Check whether the entered content has a value.
        if (this.receiveContactValue != common.string.EMPTY_STR) {
            if (!this.isPhoneNumber(this.receiveContactValue)) {
                // Invalid Recipient
                this.showToast($r("app.string.invalid_receive", this.receiveContactValue))
                HiLog.w(TAG, "newSend, PhoneNumber is invalidate");
                return;
            }
        }
        if (this.selectContacts.length > 0 && this.receiveContactValue != common.string.EMPTY_STR) {
            let selectContact = {
                telephone: this.receiveContactValue,
                telephoneFormat: this.receiveContactValue,
                contactName: common.string.EMPTY_STR
            }
            let selectContacts = this.selectContacts;
            selectContacts.push(selectContact);
            this.initNewSelectContacts(selectContacts);
        } else if (this.selectContacts.length > 0) {
            this.initNewSelectContacts(this.selectContacts);
        } else if (this.receiveContactValue != common.string.EMPTY_STR) {
            this.contactsNum = 1;
            this.strContactsNumber = this.receiveContactValue;
            this.strContactsNumberFormat = this.receiveContactValue;
        } else {
            HiLog.w(TAG, "newSend, the contact condition is not met.")
            return;
        }
        this.isNewMsg = false;
        // To cancel sending, set this parameter to true.
        if (this.recallMessagesFlag) {
            this.isNewRecallMessagesFlag = true;
            this.commonCtrl.paramContact.isNewRecallMessagesFlag = true;
        }
        // When the new page is displayed in full screen mode, the following table data needs to be obtained.
        if (true) {
            this.queryOldMessageList(this.strContactsNumber, callback);
        }
    }

    queryOldMessageList(telephone, callback) {
        HiLog.i(TAG, "queryOldMessageList, start");
        if (telephone == common.string.EMPTY_STR) {
            return;
        }
        let number = telephoneUtil.dealTelephoneSort(telephone);
        conversationListService.querySessionByTelephone(number, res => {
            HiLog.i(TAG, "queryOldMessageList, querySessionByTelephone res.response.id: " + res.response.id)
            if (res.code == common.int.SUCCESS && res.response.id > 0) {
                if (this.threadId != res.response.id) {
                    // When modifying the recipient information, click Send and delete the session before the
                    // modification.
                    conversationListService.deleteMessageBySessionId([this.threadId]);
                }
                this.threadId = res.response.id;
                this.portraitColor = AvatarColor.background.Color[Math.abs(parseInt(this.threadId, 10)) % 6];
                this.queryMessageDetail(telephone, res.response.id, callback);
                this.scroller.scrollToIndex(this.mmsList.length - 1)
            } else {
                callback();
            }
        });
    }

    initNewSelectContacts(selectContacts) {
        HiLog.i(TAG, "initNewSelectContacts, start");
        let contactsNumber = common.string.EMPTY_STR;
        let contactsName = common.string.EMPTY_STR;
        let contactsNumberFormat = common.string.EMPTY_STR;
        let contacts = telephoneUtil.dealSelectContactsSort(selectContacts);
        let length = contacts.length;
        for (let index in contacts) {
            let item = contacts[index];
            contactsNumber = contactsNumber + item.telephone + common.string.COMMA;
            contactsNumberFormat = contactsNumberFormat + item.telephoneFormat + common.string.COMMA;
            if (item.contactName != common.string.EMPTY_STR) {
                contactsName += (item.contactName + common.string.COMMA);
            }
        }
        this.strContactsNumber = contactsNumber.substring(0, contactsNumber.length - 1);
        this.strContactsName = contactsName.substring(0, contactsName.length - 1);
        this.photoFirstNameDeal(this.strContactsName);
        this.strContactsNumberFormat = contactsNumberFormat.substring(0, contactsNumberFormat.length - 1);
        this.contactsNum = length;
    }

    handleWithSend(actionData, item) {
        // Sending request processing
        let hosts: Array<string> = [];
        if (actionData.destinationHost.indexOf(",") == -1) {
            // single-shot
            hosts.push(actionData.destinationHost);
        } else {
            // Group Sending
            for (let host of actionData.destinationHost.split(",")) {
                hosts.push(telephoneUtil.formatTelephone(host));
            }
        }
        actionData.hosts = hosts;
        this.sendMassMessage(actionData, item);
    }

    sendInterval(actionData, mmsList) {
        // Send Timer
        let item = mmsList[mmsList.length - 1];
        if (this.recallMessagesFlag) {
            item.intervalSendStatus = true;
            // Second countdown timer after the Send button is clicked
            item.sendIntervalId = setInterval(function () {
                item.cancelTimeCount--;
            }, 1000);
            // Transmit timer, which is sent after 6s.
            item.sendTimeoutId = setTimeout(() => {
                item.cancelTimeCount = 0;
                // Clear Timer
                clearTimeout(item.sendTimeoutId);
                clearInterval(item.sendIntervalId);
                this.handleWithSend(actionData, item);
            }, 6000);
        } else {
            this.handleWithSend(actionData, item);
        }
    }

    changeValue(e) {
        this.textValue = e;
        if (e == null || e == common.string.EMPTY_STR) {
            if (this.mmsEditList.length != 0) {
                this.canSendMessage = true;
            } else {
                this.canSendMessage = false;
            }
            return;
        }
        // Whether to display full screen
        if (this.isEditMms) {
            this.isShowFullScreen = false;
        } else {
            this.isShowFullScreen = true;
        }
        if (this.isNewMsg) {
            if (this.receiveContactValue == '' && this.selectContacts.length == 0) {
                this.canSendMessage = false;
                return;
            }
        }
        if (this.textValue.length == 0) {
            this.canSendMessage = false;
            return;
        } else {
            this.canSendMessage = MmsPreferences.getInstance().haveSimCardReady() && !this.isFlightMode;
        }
        if (this.isNewMsg) {
            this.setCanSendMsgStatus();
        }
    }

    setTabTitleText() {
        // TabTitleText selected globally
        if (this.tabIndex != 1) {
            // Non-picture page
            this.tabTitleText = this.tabTextList[this.tabIndex];
            return;
        }
        // On the image selection page, the number of selected images is displayed.
        let size = 0;
        for (let element of this.pictureListFromGallery) {
            if (element.checkedValue) {
                size++;
            }
        }
        this.tabTitleText = size == 0 ? $r("app.string.msg_unselected_tip") : $r("app.string.msg_selected_tip", {
            number: size
        });
    }

    // Check whether the sending icon can be highlighted.
    judgeSendBtnCanClicked() {
        if (MmsPreferences.getInstance().haveSimCardReady() && (this.mmsEditList.length != 0 ||
        this.textValue != common.string.EMPTY_STR || this.textareaDatasource.length !== 0)) {
            if (this.isNewMsg) {
                if ((this.receiveContactValue !== '' && this.isPhoneNumber(this.receiveContactValue))
                || this.selectContacts.length !== 0) {
                    this.canSendMessage = true;
                }
            } else {
                this.canSendMessage = true;
            }
        }
    }

    // Subscribing to Public Events
    subscribeDetail() {
        HiLog.i(TAG, "subscribeDetail, start");
        let events = [common.string.RECEIVE_TRANSMIT_EVENT]
        let commonEventSubscribeInfo = {
            events: events
        };
        // Creating Subscription Information
        commonEvent.createSubscriber(commonEventSubscribeInfo, this.createSubscriberCallBack.bind(this));
    }

    createSubscriberCallBack(err, data) {
        this.commonEventData = data;
        // Received subscription
        commonEvent.subscribe(this.commonEventData, this.subscriberCallBack.bind(this));
    }

    subscriberCallBack(err, data) {
        HiLog.i(TAG, "subscriberCallBack, start");
        globalThis.needToUpdate = true;
        // Receiving SMS Updates
        setTimeout(() => {
            this.queryMessageDetail(this.strContactsNumber, this.threadId, () => {
            });
            this.scroller.scrollToIndex(this.mmsList.length - 1);
            let valueBucket: LooseObject = {
                "unread_count": 0,
            };
            let actionData: LooseObject = {
                threadIds: [this.threadId],
                hasRead: 0,
                valueBucket: valueBucket
            };
            NotificationService.getInstance().cancelMessageNotify(actionData, res => {
                actionData.hasRead = 1;
                conversationListService.markAllAsRead(actionData);
            });
            let lastItem: LooseObject = this.mmsList[this.mmsList.length - 1];
            if (lastItem != null && lastItem.subId != null) {
                this.notifySlotIdChange(lastItem.subId);
            }
        }, 500);
    }

    // Unsubscribe
    unSubscribeDetail() {
        if (this.commonEventData != null) {
            commonEvent.unsubscribe(this.commonEventData, () => {
                HiLog.i(TAG, "unSubscribeDetail, unsubscribe");
            });
        }
    }

    notifySlotIdChange(slotId: number): void {
        if (MmsPreferences.getInstance().getSelectedSlotId() != slotId) {
            MmsPreferences.getInstance().setValueToMap(common.string.KEY_OF_SELECTED_SLOTID, slotId);
            HiLog.i(TAG, "notifySlotIdChange, emit slotId: " + slotId);
            emitter.emit(simCardService.SLOTID_CHANGE_EVENT, {
                data: {
                    "slotId": slotId
                }
            });
        }
    }

    // In the selection mode, tap More. In the displayed menu, select
    moreSelected(e) {
        HiLog.i(TAG, "moreSelected, e: " + JSON.stringify(e))
        switch (e) {
            case "0":
            // duplicating
                this.copyText();
                break;
            case 1:
            // Share
                this.share();
                break;
            case 2:
            // Select Text
                this.gotoTextSelect(this.mmsIndex);
                break;
            case 3:
            // lock
                this.lock();
                break;
            case 4:
            // Show Details
                this.showDetails();
                break;
            case 5:
            // Unlock
                this.unlock();
                break;
            case 6:
            // View Reports
                this.showReport(this.mmsIndex);
                break;
            case 7:
            // Save Attachments
                this.saveImage();
                break;
            case 8:
            // Querying vCard Details
                this.showVcarDetail(this.mmsIndex);
                break;
            default:
                break;
        }
        // Exit the multi-selection mode.
        this.exitMultiselect();
    }

    copyText() {
        commonPasteboard.setPasteboard(this.mmsList[this.mmsIndex].content);
    }

    share() {
        for (let i = 0; i < this.mmsList.length; i++) {
            if (this.mmsList[i].isCbChecked == true) {
                var actionData: LooseObject = {};
                actionData.content = this.mmsList[i].content;
                conversationService.gotoShare(actionData, function (data) {
                    HiLog.i(TAG, "share, gotoShare callback");
                });
            }
        }
    }

    gotoTextSelect(idx) {
        router.push({
            uri: "pages/text_select/text_select",
            params: this.mmsList[idx]
        })
    }

    lock() {
        this.updateLock(true);
    }

    unlock() {
        this.updateLock(false);
    }

    updateLock(isLock) {
        // Select Content Lock
        let groupIds = [];
        for (let element of this.mmsList) {
            if (element.isCbChecked) {
                element.isLock = isLock;
                groupIds.push(element.groupId);
            }
        }
        let hasLock = isLock ? 1 : 0;
        let actionData: LooseObject = {};
        actionData = {
            groupIds: groupIds,
            hasLock: hasLock
        };
        let that = this;
        conversationService.updateLock(actionData, function (result) {
            if (result.code == common.int.SUCCESS) {
                // Multi-Select Status Off
                that.isSelectStatus = false;
                that.cancleCheckedAll();
                HiLog.i(TAG, "updateLock, Success");
            } else {
                HiLog.w(TAG, "updateLock, failed");
            }
        });
        // Update Lock Status
        this.updateSessionLock(isLock);
    }

    showDetails() {
        for (let index = 0; index < this.mmsList.length; index++) {
            if (this.mmsList[index].isCbChecked == true) {
                var time = this.mmsList[index].timeMillisecond;
                var timeStash = this.getTime(time);
                this.mmsTime = timeStash + this.mmsList[index].time;
                if (this.mmsList[index].msgType == 0) {
                    this.isMmsType = $r("app.string.sms");
                } else {
                    this.isMmsType = $r("app.string.mms");
                }

                if (this.mmsList[index].isReceive) {
                    this.isSendRecipient = true;
                } else {
                    this.isSendRecipient = false;
                }
            }
        }
        //    this.$element("mms_details_dialog").show();
    }

    showReport(mmsIndex) {
        // View Reports
        let item = this.mmsList[mmsIndex];
        router.push({
            uri: "pages/queryreport/queryReport",
            params: {
                isMsm: item.isMsm,
                telephone: this.strContactsNumber,
                sendStatus: item.sendStatus,
                timeMillisecond: item.timeMillisecond
            },
        });
    }

    saveImage() {
        var actionData: LooseObject = {};
        actionData.threadId = this.mmsList[this.mmsIndex]?.threadId;
        actionData.pduId = this.mmsList[this.mmsIndex]?.pduId;
        conversationService.saveImage(actionData, result => {
            this.showToast(result);
        });
    }

    showVcarDetail(mmsIndex) {

    }

    exitMultiselect() {
        // Exit the multi-selection state.
        this.isSelectStatus = false;
        this.cancleCheckedAll();
    }

    longPressMore(e) {
        switch (e) {
            case 0:
            // delete
                this.deleteDetail();
                break;
            case 1:
            // New Contact
                this.createNewContract(this.strContactsNumber);
                break;
            case 2:
            // Save to Existing Contacts
                this.existingContact(this.strContactsNumber);
                break;
            case 3:
            // Edit Before Call
                this.callEditor(this.strContactsNumber);
                break;
            case 4:
            // Add to Blocklist
                this.callEditor(this.strContactsNumber);
                break;
            case 5:
            // View Contacts
                this.titleBarAvatar();
                break;
            default:
                break;
        }
    }

    // Delete
    deleteDetail() {
        if (this.mmsList.length == 1) {
            this.strMsgDeleteDialogTip = $r("app.string.msg_delete_dialog_con_tip3");
        } else {
            this.hasDetailDelete = false;
            this.isSelectStatus = true;
        }
    }

    // New Contact
    createNewContract(number) {
        var actionData: LooseObject = {};
        actionData.phoneNumber = number;
        actionData.pageFlag = common.contractPage.PAGE_FLAG_SAVE_CONTACT;
        this.jumpToContract(actionData);
    }

    // Edit Before Call
    callEditor(number) {
        var actionData: LooseObject = {};
        actionData.phoneNumber = number;
        actionData.pageFlag = common.contractPage.PAGE_FLAG_EDIT_BEFORE_CALLING;
        this.jumpToContract(actionData);
    }

    // Save to Existing Contacts
    existingContact(number) {
        var actionData: LooseObject = {};
        actionData.phoneNumber = number;
        actionData.pageFlag = common.contractPage.PAGE_FLAG_SAVE_EXIST_CONTACT;
        this.jumpToContract(actionData);
    }

    // Switching to the Contacts app
    jumpToContract(actionData) {
        let str = commonService.commonContractParam(actionData);
        globalThis.mmsContext.startAbility(str).then((data) => {
            HiLog.i(TAG, "jumpToContract, startAbility Success");
        }).catch((error) => {
            HiLog.e(TAG, "jumpToContract, failed. Cause: " + JSON.stringify(error.message));
        })
    }

    // Tap a contact's avatar to go to the contact details page.
    titleBarAvatar() {
        var actionData = {
            phoneNumber: this.strContactsNumber,
            pageFlag: common.contractPage.PAGE_FLAG_CONTACT_DETAILS
        };
        this.jumpToContract(actionData);
    }

    clickCall() {
        this.call(this.strContactsNumber);
    }

    call(telephone) {
        // Calling
        callService.call(telephone, result => {
            if (result.code == common.int.SUCCESS) {
                HiLog.i(TAG, "call success");
            } else {
                HiLog.w(TAG, "call failed");
            }
        });
    }

    getTime(nS) {
        var date = new Date(parseInt(nS));
        var year = date.getFullYear();
        var mon = date.getMonth() + 1;
        var day = date.getDate();
        return year; // + $r("app.string.year") + mon + $r("app.string.month") + day + $r("app.string.day");
    }

    // Contact data returned on the new page
    setReceiveContactValue(receiverData) {
        let selectContacts = receiverData.selectContacts;
        let receiveContactValue = selectContacts.length > 0 ? common.string.EMPTY_STR : receiverData.contactValue;
        let hasBlur = receiverData.hasBlur;
        let telephone = common.string.EMPTY_STR;
        this.textValue = common.string.EMPTY_STR;
        this.setCanSendMessage(selectContacts, receiveContactValue)
        if (hasBlur && receiveContactValue != common.string.EMPTY_STR) {
            let index = -1;
            for (let i = 0; i < selectContacts.length; i++) {
                let contact = selectContacts[i];
                if (contact.telephone == receiveContactValue) {
                    index = i;
                    break;
                }
            }
            if (index >= 0) {
                selectContacts.splice(index, 1);
            }
        }
        if (receiveContactValue != common.string.EMPTY_STR) {
            this.receiveContactValue = receiveContactValue;
        } else {
            this.receiveContactValue = common.string.EMPTY_STR;
        }
        if(selectContacts.length > 0) {
            for (let item of selectContacts) {
                if (!this.isPhoneNumber(item.telephone)) {
                    item.telephone = this.replaceCode(item.telephone);
                    item.telephoneFormat = this.replaceCode(item.telephoneFormat);
                    if (item.contactName != common.string.EMPTY_STR) {
                        item.contactName = common.string.EMPTY_STR;
                    }
                }
                if (this.selectContacts.length > 1) {
                    break
                }
                this.selectContacts = selectContacts;
            }
        } else {
            this.selectContacts = [];
        }
        if (this.selectContacts.length > 0) {
            for (let element of this.selectContacts) {
                telephone += element.telephone + common.string.COMMA;
            }
        }
        if (this.receiveContactValue != common.string.EMPTY_STR) {
            telephone += this.receiveContactValue + common.string.COMMA;
        }
        if (telephone != common.string.EMPTY_STR) {
            telephone = telephone.substring(0, telephone.length - 1);
        }
        if (!hasBlur && telephone != "") {
            this.queryOldMessageList(telephone, null);
        }
    }

    setCanSendMessage(selectContacts, receiveContactValue) {
        if (this.textValue != common.string.EMPTY_STR || this.isEditMms) {
            if (this.canSendMessage) {
                if (selectContacts.length == 0 && receiveContactValue == common.string.EMPTY_STR) {
                    this.canSendMessage = false;
                }
            } else if ((selectContacts.length != 0 || receiveContactValue != common.string.EMPTY_STR)
            && MmsPreferences.getInstance().haveSimCardReady()) {
                this.canSendMessage = true;
            }
        }
    }
}