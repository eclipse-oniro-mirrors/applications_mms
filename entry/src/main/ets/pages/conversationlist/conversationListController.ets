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
import common from "../../data/commonData"
import router from "@system.router";
import commonEvent from "@ohos.commonEventManager";
import DateUtil from "../../utils/DateUtil";
import featureAbility from "@ohos.ability.featureAbility";
import LooseObject from "../../data/LooseObject";
import messageService from "../../service/ConversationListService";
import HiLog from "../../utils/HiLog";
import SettingService from "../../service/SettingService"
import commonService from "../../service/CommonService";
import NotificationService from "../../service/NotificationService";
import ConversationListDataSource from "../../model/ConversationListDataSource"
import AvatarColor from "../../model/common/AvatarColor"
import dataShare from "@ohos.data.dataShare";

let ConversationCtrl;

const TAG = "ConversationListController";
const CONTACT_URI: string = "datashare:///com.ohos.contactsdataability/contacts/contact_data";
const CONTENT_URI: String = "datashare:///com.ohos.contactsdataability";

export default class ConversationListController {
    // Determine whether to perform initialization. (To avoid the onShow time sequence problem immediately after the
    // index is started.)
    private dataShareHelper;
    isInited: boolean = false;

    commonEventData: any = null;
    svgDelete: string = '';
    strCheckBoxSelectTip: Resource;
    strMsgDeleteDialogTip: Resource = null;
    // Total number of SMs
    total: number = 0;
    // Total number of notifications.
    totalOfInfo: number = 0;
    // Total number of unread messages.
    unreadTotal: number = 0;
    // Total number of unread notifications
    unreadTotalOfInfo: number = 0;
    // Number of selected sessions
    conversationSelectedNumber: number = 0;
    // Indicates whether the multi-select state is selected.
    isMultipleSelectState: boolean = false;
    // Indicates whether the session list is selected.
    isConversationCheckAll: boolean = false;
    // Value entered in the search box on the information list page
    inputValueOfSearch: string = '';
    inputValueOfSearchTemp: string = '';
    // Mark as read is hidden in the row where the notification is located. When there is unread information,
    // you can swipe left to view this icon.
    markAllAsReadForInfo: boolean = false;
    // Mark as read
    showMarkAllAsRead: boolean = false;
    // Delete. In each individual message line, swipe left on the screen.
    showDelete: boolean = false;
    // Indicates whether to lock. The default value is false. No.
    hasLockMsg: boolean = false;
    isSelectLockMsg: boolean = false;
    // Dynamically setting the height of the deleted pop-up window
    dialogHeight: string = '';
    // Data in the notification message
    messageListForInfo: Array<any> = [];
    // If the notification integration switch is turned on, the information is not a notification.
    // If the notification integration switch is not turned on, the information is all data.
    messageList: Array<any> = [];
    // List of search results
    searchResultList: LooseObject = {
        sessionList: [],
        contentList: []
    };
    // Search Results Queue
    searchResultListQueue: Array<any> = [];
    // Search Text Queue
    searchTextQueue: Array<any> = [];
    // Queue start flag bit
    queueFlag: boolean = false;
    // Queue timer start flag bit
    setTimeOutQueueFlag: boolean = false;
    // Number of search results
    countOfSearchResult: number = 0;
    // Indicates whether to perform redirection to avoid repeated redirection.
    isJumping: boolean = false;
    // Indicates whether to enable the notification integration switch. This switch is in the Settings area.
    hasAggregate: boolean = false;
    // Display contact avatar
    isShowContactHeadIcon: boolean = true;
    // Indicates whether to display the search return button. By default, the button is not displayed.
    isShowSearchBack: boolean = false;
    isSearchFocusable: boolean = false;
    // The transparent color of the mask is displayed during search.
    isSearchCoverage: boolean = false;
    // Display Query All Information
    isSearchStatus: boolean = true;
    // Whether to display session search
    isSearchConversation: boolean = false;
    // Show Spacer Lines
    isSearchInterval: boolean = false;
    // Display Single Information Search
    isSearchSms: boolean = false;
    // Show Search Status
    showSearchStatus: Resource;
    // Indicates whether to display the button for creating an SMS message.
    isNewSms: boolean = true;
    conversationName: string = '';
    // Check whether a common message (non-notification message) exists.
    hasNoOrdinaryMsg: boolean = false;
    // Check whether notification information exists.
    hasInfoMsg: boolean = true;
    // Update the UI.
    flushTranslate: boolean = true;
    // Length of the operation button
    operateBtnW: number = 145;
    // Data index of the current touch
    itemTouchedIdx: number = -1;
    // Left margin of notification message
    infoLeft: number = 0;
    // List pagination, number of pages
    page: number = 0;
    // List pagination, quantity
    limit: number = 0;
    reg: RegExp = /^[\u4e00-\u9fa5_a-zA-Z]+$/;
    delItem: number;
    // conversation list adapters
    conversationListDataSource: ConversationListDataSource = new ConversationListDataSource();

    static getInstance() {
        if (ConversationCtrl == null) {
            ConversationCtrl = new ConversationListController();
        }
        return ConversationCtrl;
    }


    onInit() {
        HiLog.i(TAG, "onInit");
        this.isInited = true;
        this.svgDelete = "icon/ic_public_delete.svg";
        this.strCheckBoxSelectTip = $r("app.string.msg_select_all");
        this.strMsgDeleteDialogTip = $r("app.string.msg_delete_dialog_tip2", this.conversationSelectedNumber);
        this.showSearchStatus = $r("app.string.noMessages");
    }

    private async getDataAbilityHelper(context?) {
        if (this.dataShareHelper == undefined) {
            this.dataShareHelper = await featureAbility.acquireDataAbilityHelper(context ? context : globalThis.context, CONTENT_URI);
        }
        return this.dataShareHelper;
    }

    registerDataChangeObserver(callback, context?) {
        this.getDataAbilityHelper(context).then((dataAbilityHelper) => {
            if (dataAbilityHelper) {
                dataAbilityHelper.on("dataChange", CONTACT_URI, callback);
            }
        }).catch(error => {
            HiLog.w(TAG, 'error:%s' + JSON.stringify(error.message));
        });
    }

    unregisterDataChangeObserver(callback, context?) {
        this.getDataAbilityHelper(context).then((dataAbilityHelper) => {
            if (dataAbilityHelper) {
                dataAbilityHelper.off("dataChange", CONTACT_URI, callback);
            }
        }).catch(error => {
            HiLog.w(TAG, 'error:%s' + JSON.stringify(error.message));
        });
    }

    onShow() {
        HiLog.i(TAG, "onShow");
        if (!this.isInited) {
            HiLog.w(TAG, "is not init");
            return;
        }
        this.subscribe();
        this.isJumping = false;
        this.getSettingFlagForConvListPage();
        this.statisticalData();
        if (globalThis.needToUpdate && this.page == 0) {
            this.messageList = [];
            this.requestItem();
        }
    }

    onDestroy() {
        HiLog.i(TAG, "onDestroy");
        this.isInited = false;
    }

    onHide() {
        HiLog.i(TAG, "onHide");
        this.unSubscribe();
    }

    // Touch and hold a list to display the selection and deletion functions.
    conversationLongPress(index) {
        // Check whether the left slide button exists. If yes, the button cannot be clicked.
        if (this.messageList[index].isDelShow) {
            return;
        }
        // Touch and hold a list to display the selection and deletion functions.
        HiLog.i(TAG, "conversationLongPress, index: " + index);
        if (this.isMultipleSelectState) {
            this.messageList[index].isCbChecked = !this.messageList[index].isCbChecked;
        } else {
            this.isMultipleSelectState = true;
            this.messageList[index].isCbChecked = true;
        }
        this.setConversationCheckAll(common.int.CHECKBOX_SELECT_UNKNOWN);
    }

    setConversationCheckAll(selectType) {
        // Check whether all items are selected.
        if (!this.isMultipleSelectState) {
            return;
        }
        if (selectType == common.int.CHECKBOX_SELECT_ALL) {
            this.conversationSelectedNumber = this.messageList.length;
            this.isConversationCheckAll = true;
        } else if (selectType == common.int.CHECKBOX_SELECT_NONE) {
            this.conversationSelectedNumber = common.int.MESSAGE_CODE_ZERO;
            this.isConversationCheckAll = false;
        } else {
            // The default value is CHECKBOX_SELECT_UNKNOWN. Check whether there is any unselected item.
            this.isConversationCheckAll = true;
            this.conversationSelectedNumber = 0;
            this.messageList.forEach((element, index, array) => {
                if (element.isCbChecked) {
                    this.conversationSelectedNumber++;
                } else if (this.isConversationCheckAll) {
                    this.isConversationCheckAll = false;
                }
            })
        }
        if (this.isConversationCheckAll) {
            // Select All Status
            this.strCheckBoxSelectTip = $r("app.string.msg_deselect_all");
        } else {
            // Non-Select All Status
            this.strCheckBoxSelectTip = $r("app.string.msg_select_all");
        }
    }

    backSearch() {
        this.isShowSearchBack = false;
        this.isSearchCoverage = false;
        //  this.$element("searchBox").focus({
        //    focus: false
        //  });
        this.isSearchFocusable = false
        this.inputValueOfSearch = common.string.EMPTY_STR;
        this.isSearchStatus = true;
        this.isNewSms = true;
        this.searchResultList.sessionList = [];
        this.searchResultList.contentList = [];
    }

    // Reset touch event, which is used to reset an item that has been moved by sliding left
    // when other buttons are pressed.
    resetTouch() {
        if (this.itemTouchedIdx !== -1) {
            let itemTouched = this.messageList[this.itemTouchedIdx];
            if (itemTouched == undefined) {
                return false;
            }
            if (itemTouched.isDelShow) {
                itemTouched.isDelShow = false;
                this.setListItemTransX(0);
                return true;
            }
        } else if (this.showMarkAllAsRead) {
            this.showMarkAllAsRead = false;
            this.setInfoItemTransX(0);
            return true;
        }
        return false;
    }

    // Touch event for information list
    touchStart(event: GestureEvent, index: number) {
        if (this.isMultipleSelectState) {
            return;
        }
        if (this.showMarkAllAsRead) {
            // If the last touch is a notification item, the notification item will be reset.
                  this.setInfoItemTransX(0);
                  setTimeout(() => {
                    this.showMarkAllAsRead = false;
                  }, 200);
        } else {
            // Check whether the current touch item is the same as that of a touch item.
            // If not, reset the previous touch item.
            if (this.itemTouchedIdx !== -1 && index !== this.itemTouchedIdx) {
                let itemTouched = this.messageList[this.itemTouchedIdx];
                if (itemTouched != undefined && itemTouched != null && itemTouched.isDelShow) {
                    this.setListItemTransX(0);
                    itemTouched.isDelShow = false;
                }
            }
        }
        this.itemTouchedIdx = index;
        let item = this.messageList[this.itemTouchedIdx];
        if (item.countOfUnread > 0) {
            this.operateBtnW = common.int.OPERATE_UNREAD_WIDTH;
        } else {
            this.operateBtnW = common.int.OPERATE_DELETE_WIDTH;
        }
    }

    touchMove(event: GestureEvent, index: number) {
        if (this.isMultipleSelectState) {
            return;
        }
        // offsetX indicates the offset. The value range is [-operateBtnW, 0].
        let offsetX = event.offsetX;
        // If the displacement is less than 2, there is no sliding.
        if (Math.abs(offsetX) <= 2) {
            return;
        }
        let item = this.messageList[this.itemTouchedIdx];
        let transX = offsetX;
        if (item.isDelShow) {
            if (event.offsetX - this.operateBtnW <= 0) {
                transX = event.offsetX - this.operateBtnW
            } else {
                // Slide right to close
                transX = 0
            }
        } else {
            if (event.offsetX + this.operateBtnW >= 0) {
                transX = event.offsetX
            } else {
                // Slide left to maximum width
                transX = 0 - this.operateBtnW;
            }
        }
        this.setListItemTransX(transX);
    }

    touchEnd(event: GestureEvent, index: number) {
        if (this.isMultipleSelectState) {
            return;
        }
        // offsetX indicates the offset. The value range is [-operateBtnW, 0].
        let offsetX = event.offsetX;
        let item = this.messageList[this.itemTouchedIdx];
        if (offsetX + (this.operateBtnW / 2) >= 0) {
            this.setListItemTransX(0);
            item.isDelShow = false;
        } else {
            this.setListItemTransX(0 - this.operateBtnW);
            item.isDelShow = true;
        }
    }

    setListItemTransX(transX) {
        let item = this.messageList[this.itemTouchedIdx];
        if (item) {
            if (transX <= 0) {
                item.itemLeft = transX;
            } else {
                item.itemLeft = 0;
            }
        }
        // Used to refresh the interface.
        this.flushTranslate = !this.flushTranslate;
    }

    setInfoItemTransX(disX) {
        if (disX >= 0) {
            this.infoLeft = -disX;
        } else {
            this.infoLeft = -this.operateBtnW - disX;
        }
    }

    clickConversationCheckAll() {
        // Select All/Deselect All
        if (this.isConversationCheckAll) {
            for (let element of this.messageList) {
                element.isCbChecked = false;
            }
            this.setConversationCheckAll(common.int.CHECKBOX_SELECT_NONE);
        } else {
            // Not Select All --> Select All
            for (let element of this.messageList) {
                element.isCbChecked = true;
            }
            this.setConversationCheckAll(common.int.CHECKBOX_SELECT_ALL);
        }
    }

    clickConversationDelete() {
        // Button Delete
        if (this.conversationSelectedNumber == common.int.MESSAGE_CODE_ZERO) {
            return;
        }
        // Delete a record.
        if (this.conversationSelectedNumber == common.int.MESSAGE_CODE_ONE) {
            this.strMsgDeleteDialogTip = $r("app.string.msg_delete_dialog_tip1");
        } else if (this.conversationSelectedNumber == this.messageList.length) {
            // Delete All
            this.strMsgDeleteDialogTip = $r("app.string.msg_delete_dialog_tip3");
        } else {
            // Delete multiple records.
            this.strMsgDeleteDialogTip = $r("app.string.msg_delete_dialog_tip2", this.conversationSelectedNumber);
        }
        // Locked or not
        this.hasLockMsg = this.judgehasLockMsg()
    }

    judgehasLockMsg() {
        let hasLockMsg = false;
        for (let element of this.messageList) {
            if (element.isCbChecked && element.isLock) {
                hasLockMsg = true;
                break;
            }
        }
        return hasLockMsg;
    }

    onBackPress() {
        HiLog.i(TAG, "onBackPress");
        // Key returned by the system. The value true indicates interception.
        if (this.isMultipleSelectState) {
            for (let element of this.messageList) {
                element.isCbChecked = false;
            }
            this.isMultipleSelectState = false;
            return true;
        }
        if (!this.isSearchStatus) {
            this.backSearch();
            return true;
        }
        return false;
    }

    deleteDialogConfirm() {
        this.setDelShow();
        let mmsList = [];
        let threadIds = [];
        let lockThreadIds = [];
        for (let element of this.messageList) {
            if (element.isCbChecked) {
                if (element.isLock && !this.isSelectLockMsg) {
                    lockThreadIds.push(element.threadId);
                    mmsList.push(element);
                } else {
                    threadIds.push(element.threadId);
                }
            } else {
                mmsList.push(element);
            }
        }
        // Set to non-multi-choice status
        this.isMultipleSelectState = false;
        this.isSelectLockMsg = false;
        this.messageList = mmsList;
        this.conversationListDataSource.refresh(this.messageList);
        this.total = this.messageList.length;
        this.hasNoOrdinaryMsg = this.total == 0 ? true : false;
        this.deleteNotifyMessage(threadIds, lockThreadIds, () => {
            this.deleteMessageByThreadIds(threadIds, lockThreadIds);
        });
    }

    deleteNotifyMessage(threadIds, lockThreadIds, callback) {
        let sessionIds = [];
        if (threadIds.length > 0) {
            sessionIds.push(threadIds);
        }
        if (lockThreadIds.length > 0) {
            sessionIds.push(lockThreadIds);
        }
        this.cancelMessageNotify(sessionIds, callback);
    }

    deleteMessageByThreadIds(threadIds, lockThreadIds) {
        let actionData: LooseObject = {};
        if (threadIds.length > 0) {
            actionData.threadIds = threadIds;
            messageService.deleteMessageById(actionData);
        }
        if (lockThreadIds.length > 0) {
            actionData.threadIds = lockThreadIds;
            actionData.isMessageDetail = false;
            messageService.dealMessageLockContent(actionData, res => {
                actionData.hasLock = 0;
                messageService.deleteMessageBySessionIdsAndLock(actionData);
            });
        }
    }

    deleteDialogCancel() {
        if (!this.isMultipleSelectState) {
            this.messageList[this.delItem].isCbChecked = false;
        }
        // Cancel Ejection
        if (this.isSelectLockMsg) {
            this.isSelectLockMsg = false;
        }
    }

    setDelShow() {
        if (this.itemTouchedIdx >= 0) {
            let item = this.messageList[this.itemTouchedIdx];
            this.setListItemTransX(0);
            item.isDelShow = false;
        }
    }

    clickToMarkAllAsRead() {
        // Mark unread as read. Here we deal with the values in the information list.
        let threadIds = [];
        for (let mms of this.messageList) {
            if (mms.countOfUnread > common.int.MESSAGE_CODE_ZERO) {
                threadIds.push(mms.threadId);
            }
        }

        this.cancelMessageNotify(threadIds, () => {
            // Marks the notification information as read.
            let actionData = {
                hasRead: 1,
                smsType: 1,
            }
            messageService.markAllToRead(actionData);
            this.unreadTotalOfInfo = 0;
            this.unreadTotal = 0;
            this.markAllAsRead(threadIds);
        });
    }

    jumpToSettingsPage() {
        router.push({
            uri: "pages/settings/settings",
            params: {
                pageFlag: "settingsDetail",
            }
        });
    }

    subscribe() {
        let events = [common.string.RECEIVE_TRANSMIT_EVENT]
        let commonEventSubscribeInfo = {
            events: events
        };
        commonEvent.createSubscriber(commonEventSubscribeInfo, this.createSubscriberCallBack.bind(this));

    }

    subscriberCallBack(err, data) {
        this.page = 0;
        this.messageList = [];
        this.requestItem();
        // Collecting Unread Information
        this.statisticalData();
    }

    // Unsubscribe
    unSubscribe() {
        HiLog.i(TAG, "unSubscribe");
        if (this.commonEventData != null) {
            commonEvent.unsubscribe(this.commonEventData, () => {
                HiLog.i(TAG, "unSubscribe, success");
            });
        }
    }

    createSubscriberCallBack(err, data) {
        this.commonEventData = data;
        // Received subscription
        commonEvent.subscribe(this.commonEventData, this.subscriberCallBack.bind(this));
    }

    // statistical data
    statisticalData() {
        let actionData: LooseObject = {};
        let that = this;
        messageService.statisticalData(actionData, function (result) {
            if (result.code == common.int.SUCCESS) {
                // Total number of lists
                that.unreadTotal = result.response.totalListCount;
                // Unreading of notification messages
                that.unreadTotalOfInfo = result.response.unreadTotalOfInfo;
                let actionData = {};
                NotificationService.getInstance().cancelMessageNotify(actionData, res => {
                });
            } else {
                HiLog.w(TAG, "statisticalData, failed");
            }
        });
    }

    // Obtains the switch value for integrating notification information and displaying contact avatars.
    getSettingFlagForConvListPage() {
        let that = this;
        let result = SettingService.getSettingFlagForConvListPage();
        if (result) {
            that.hasAggregate = result.hasAggregate;
            that.isShowContactHeadIcon = result.isShowContactHeadIcon;
        }
    }

    // Obtaining List Data in Pagination Mode
    requestItem() {
        if (this.page === 0) {
            this.page++;
            this.queryAllMessages();
        } else {
            HiLog.i(TAG, "isLoading");
        }
    }

    // The notification page is displayed.
    clickToInfoMessages(hasAggregate, hasInfoMsg, isSearchStatus) {
        if (this.resetTouch()) {
            return;
        }
        if (this.isMultipleSelectState) {
            return;
        }
        router.push({
            uri: "pages/infomsg/InfoMsg"
        })
    }

    // Tap the avatar to go to the contact details page or recipient list page.
    clickToGroupDetail(index) {
        if (this.isJumping) {
            return;
        }
        this.isJumping = true;
        // Determine whether to redirect to the contact details page or to the list page of multiple recipients.
        var contactsNum = this.messageList[index]?.contactsNum;
        var telephone = this.messageList[index]?.telephone;
        if (contactsNum == common.int.MESSAGE_CODE_ONE) {
            var actionData = {
                phoneNumber: telephone,
                pageFlag: common.contractPage.PAGE_FLAG_CONTACT_DETAILS
            };
            this.jumpToContract(actionData);
        } else {
            let threadId = this.messageList[index]?.threadId;
            let contactsNum = this.messageList[index]?.contactsNum;
            this.jumpToGroupDetail(threadId, contactsNum);
        }
    }

    // Switching to the Contacts app
    jumpToContract(actionData) {
        let str = commonService.commonContractParam(actionData);
        globalThis.mmsContext.startAbility(str).then((data) => {
            HiLog.i(TAG, "jumpToContract, startAbility success");
        }).catch((error) => {
            HiLog.e(TAG, "jumpToContract, failed Cause: " + JSON.stringify(error.message));
        })
        this.isJumping = false;
    }

    // Go to the multi-faceted portrait list page.
    jumpToGroupDetail(threadId, contactsNum) {
        let actionData = {
            uri: "pages/group_detail/group_detail",
            params: {
                threadId: threadId,
                contactsNum: contactsNum
            }
        };
        this.isJumping = false;
        router.push(actionData);
    }

    setSelectLock() {
        this.isSelectLockMsg = !this.isSelectLockMsg;
    }

    setSelectLockChange(e) {
        // Delete the checkbox lockout event.
        this.isSelectLockMsg = e.checked;
    }

    // Querying All Lists
    queryAllMessages() {
        HiLog.i(TAG, "queryAllMessages, start");
        let that = this;
        if (this.page == 1) {
            this.limit = 50;
        } else {
            this.limit = 100;
        }
        let actionData: LooseObject = {};
        // Whether notification information needs to be integrated
        if (this.hasAggregate) {
            // Only non-notification information is queried.
            actionData.numberType = 0;
        }
        actionData.page = this.page;
        actionData.limit = this.limit;
        messageService.querySessionList(actionData, result => {
            HiLog.i(TAG, "querySessionList code=" + result.code);
            if (result.code == common.int.SUCCESS) {
                let res = this.buildSessionList(result);
                this.messageList = this.messageList.concat(res);
                this.conversationListDataSource.refresh(this.messageList);
                this.total = result.total;
                this.hasNoOrdinaryMsg = this.total == 0 ? true : false;
                this.hasInfoMsg = result.hasInfoMsg;
                if (this.messageList.length < this.total) {
                    this.page++;
                    setTimeout(() => {
                        this.queryAllMessages();
                    },this.page == 2 ? 200 : 100);
                } else {
                    this.page = 0;
                    globalThis.needToUpdate = false;
                }
            }
        });
    }

    buildSessionList(result) {
        let res = [];
        result.response.forEach(item => {
            // Inherit selected items
            if(this.isMultipleSelectState) {
                this.messageList.some(oldItem => {
                    if (item.threadId === oldItem.threadId) {
                        item.isCbChecked = oldItem.isCbChecked;
                        return true;
                    }
                });
            }
            let obj: LooseObject = {};
            obj = item;
            obj.isDelShow = false;
            obj.itemLeft = 0;
            obj.photoFirstName = common.string.EMPTY_STR;
            if( obj.name !== common.string.EMPTY_STR && this.reg.test(obj.name.substring(0, 1))) {
                obj.photoFirstName = obj.name.substring(0, 1).toUpperCase();
            }
            obj.portraitColor = AvatarColor.background.Color[Math.abs(parseInt(obj.threadId, 10)) % 6];
            // Time Conversion
            DateUtil.convertDateFormatForItem(item, false);
            // Processes MMS content display.
            this.dealMmsListContent(item);
            res.push(obj);
        });
        return res;
    }

    dealMmsListContent(item) {
        if (item.hasMms && item.hasAttachment) {
            if (item.content == common.string.EMPTY_STR) {
                item.content = $r("app.string.attachment_no_subject");
            } else {
                item.content = $r("app.string.attachment", item.content);
            }
        }
        if (item.hasMms && !item.hasAttachment && item.content == common.string.EMPTY_STR) {
            item.content = $r("app.string.no_subject");
        }
    }

    // Mark all unread notifications as read.
    clickToMarkAllAsReadForInfo() {
        let actionData = {
            hasRead: 1,
            smsType: 1,
        }
        let threadIds = [];
        for (let msg of this.messageList) {
            msg.countOfUnread = common.int.MESSAGE_CODE_ZERO;
            threadIds.push(msg.threadId);
        }
        this.cancelMessageNotify(threadIds, () => {
            messageService.markAllToRead(actionData);
            this.unreadTotalOfInfo = 0;
        });
    }

    markAllAsRead(threadIds) {
        let tempMsgList = this.messageList;
        // Mark the information corresponding to threadIds as read.
        let valueBucket = {
            "unread_count": 0,
        };
        let actionData: LooseObject = {};
        actionData.threadIds = threadIds;
        actionData.valueBucket = valueBucket;
        actionData.hasRead = 1;
        // Update data marked read to 0
        messageService.markAllAsRead(actionData);
        for (let msg of tempMsgList) {
            if (threadIds.indexOf(msg.threadId) > common.int.FAILURE) {
                // Controls the display of unread icons in the list
                msg.countOfUnread = common.int.MESSAGE_CODE_ZERO;
            }
        }
        this.messageList = tempMsgList;
        this.conversationListDataSource.refresh(this.messageList);
    }

    cancelMessageNotify(threadIds, callback) {
        let actionData = {
            threadIds: threadIds,
            hasRead: 0
        };
        NotificationService.getInstance().cancelMessageNotify(actionData, res => {
            callback();
        });
    }

    // The SM details page is displayed.
    clickInfoToConversation(index) {
        if (this.resetTouch()) {
            return;
        }
        // If multiple options are selected, the system responds to CheckBox.
        if (this.isMultipleSelectState) {
            this.messageList[index].isCbChecked = !this.messageList[index].isCbChecked;
            this.setConversationCheckAll(common.int.CHECKBOX_SELECT_UNKNOWN);
            return;
        }
        if (this.isJumping) {
            return;
        }
        this.isJumping = true;
        // If the contact has unread information, a message needs to be sent to the backend PA to mark all information
        // of the contact as read.
        if (this.messageList[index]?.countOfUnread > common.int.MESSAGE_CODE_ZERO) {
            this.markAllAsReadByIndex(index);
        }
        this.jumpToConversationPage(this.messageList[index]);
    }

    // The session details page is displayed.
    jumpToConversationPage(item) {
        router.push({
            uri: "pages/conversation/conversation",
            params: {
                strContactsNumber: item.telephone,
                strContactsNumberFormat: item.telephoneFormat,
                strContactsName: item.name,
                contactsNum: item.contactsNum,
                threadId: item.threadId,
                isDraft: item.isDraft,
                draftContent: item.content,
                searchContent: this.inputValueOfSearch
            }
        });
    }

    markAllAsReadByIndex(index) {
        let threadId = this.messageList[index]?.threadId;
        let threadIds = [threadId];
        this.cancelMessageNotify(threadIds, () => {
            // Mark the information corresponding to the contact index as read.
            this.markAllAsRead(threadIds);
            this.setListItemTransX(0);
            this.statisticalData();
        });
    }

    deleteAction(idx) {
        this.delItem = idx;
        let element = this.messageList[idx];
        this.strMsgDeleteDialogTip = $r("app.string.msg_delete_dialog_tip1");
        element.isCbChecked = true;
        this.hasLockMsg = this.judgehasLockMsg();
    }

    // 搜索
    clickToSearch(inputContent) {
        this.inputValueOfSearch = inputContent;
        this.search(inputContent);
    }

    search(text) {
        // 在信息列表页面搜索
        let actionData: LooseObject = {}
        actionData.inputValue = text
        this.searchTextAsync(actionData);
    }

    searchTextAsync(actionData) {
        messageService.searchMessageWithLike(actionData, result => {
            if (result.code == common.int.SUCCESS) {
                // 获取搜索返回的结果先做判空处理
                if (this.inputValueOfSearch !== common.string.EMPTY_STR) {
                    this.dealSearchResult(result);
                }
            } else {
                this.searchResultListEmpty();
            }
        });
    }

    searchResultListEmpty() {
        this.searchResultList = {
            contentList: [],
            sessionList: []
        }
        this.isSearchStatus = true;
        this.hasInfoMsg = true;
        if (this.isShowSearchBack) {
            this.isSearchCoverage = true;
        } else {
            this.isSearchCoverage = false;
        }
    }

    dealSearchResult(result) {
        this.searchResultList = {
            contentList: [],
            sessionList: []
        }
        this.hasInfoMsg = false;
        this.isSearchStatus = false;
        this.isSearchCoverage = false;
        this.buildSearchResult(result);
        if (this.inputValueOfSearch === result.search) {
            this.searchResultList = result.resultMap;
        }
    }

    buildSearchResult(result) {
        if (result.resultMap.contentList) {
            result.resultMap.contentList.forEach(content => {
                content.timeMillisecond = parseInt(content.timeMillisecond);
                DateUtil.convertDateFormatForItem(content, true);
                if (content.isFavorite) {
                    content.name = $r("app.string.message_in_favorites");
                }
            });
        }
        if (result.resultMap.sessionList) {
            result.resultMap.sessionList.forEach(session => {
                session.timeMillisecond = parseInt(session.timeMillisecond);
                DateUtil.convertDateFormatForItem(session, true);
            });
        }
    }

    checkHasCommonMessage() {
        return this.messageList.length > 0;
    }

    showMultipleSelectView() {
        this.resetTouch();
        if (this.checkHasCommonMessage()) {
            this.isMultipleSelectState = true;
            this.setConversationCheckAll(common.int.CHECKBOX_SELECT_UNKNOWN)
        }
    }
}
