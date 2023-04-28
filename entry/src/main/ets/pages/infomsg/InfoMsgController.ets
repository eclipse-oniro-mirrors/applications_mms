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
import common from "../../data/commonData";
import commonEvent from "@ohos.commonEventManager";
import commonService from "../../service/CommonService";
import dateUtil from "../../utils/DateUtil";
import featureAbility from "@ohos.ability.featureAbility";
import LooseObject from "../../data/LooseObject"
// Information List Service
import messageService from "../../service/ConversationListService";
// Log tool class
import HiLog from "../../utils/HiLog";
import MmsPreferences from "../../utils/MmsPreferences";
import NotificationService from "../../service/NotificationService";
// Notification Information
import router from "@system.router";
// Obtain the setting switch.
import settingService from "../../service/SettingService";
import ConversationListDataSource from "../../model/ConversationListDataSource"

const TAG = "InfoMsgController"

let sInfoMsgCtrl;

export default class InfoMsgController {
    delDialogShow: boolean = false;
    commonEventData: any = null;
    svgDelete: string = "icon/ic_public_delete.svg"
    total: number = 0;
    strCheckBoxSelectTip: Resource;
    strMsgDeleteDialogTip: Resource;
    // Number of selected sessions
    conversationSelectedNumber: number = 0;
    // Indicates whether the multi-select state is selected.
    isMultipleSelectState: boolean = false;
    isSearchFocusable: boolean = false;
    // No The session list is selected.
    isConversationCheckAll: boolean = false;
    // Value entered in the search box on the information list page
    inputValueOfSearch: string = '';
    // Indicates whether to lock. The default value is false. No.
    hasLockMsg: boolean = false;
    isSelectLockMsg: boolean = false;
    // List of search results
    searchResultList: LooseObject = {
        sessionList: [],
        contentList: []
    };
    // Search Results Queue
    searchResultListQueue: Array<any> = [];
    // Search Text Queue
    searchTextQueue: Array<any> = [];
    // Queue timer start flag bit
    setTimeOutQueueFlag: boolean = false;
    // Indicates whether to perform redirection to avoid repeated redirection.
    isJumping: boolean = false;
    // Indicates whether to display the search return button. By default, the button is not displayed.
    isShowSearchBack: boolean = false;
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
    // Display SMS messages when the search result is empty.
    isSearchNull: boolean = false;
    // Queue start flag bit
    queueFlag: boolean = false;
    // Show Search Status
    showSearchStatus: string = '';
    conversationName: string = '';
    // Number of unread notifications.
    unreadTotalOfInfo: number = 0;
    messageList: Array<any> = [];
    numberType: number = 1;
    // Indicates whether to display the contact profile picture.
    isShowContactHeadIcon: boolean = true;
    // Number of search results
    countOfSearchResult: number = 0;
    // Display Navigation Bar
    isNavigationBar: boolean = false;
    // Search status. Click the search box to enter the search status.
    searchStatus: boolean = false;
    // Indicates whether to display the toolbar. The toolbar is not displayed in the search state.
    showToolBar: boolean = true;
    // Update the UI.
    flushTranslate: boolean = true;
    // Length of the operation button
    operateBtnW: number = 145;
    // Data index of the current touch
    itemTouchedIdx: number = -1;
    // List pagination, quantity
    limit: number = 1000;
    // List pagination, number of pages
    page: number = 0;
    // Total number of messages
    totalMessage: number = 0;
    // notification conversation list adapters
    conversationListDataSource: ConversationListDataSource = new ConversationListDataSource();

    static getInstance() {
        if (sInfoMsgCtrl == null) {
            sInfoMsgCtrl = new InfoMsgController();
            AppStorage.SetAndLink("InfoMsgController", sInfoMsgCtrl);
        }
        return sInfoMsgCtrl;
    }

    onInit() {
        HiLog.i(TAG, "onInit");
        this.strCheckBoxSelectTip = $r("app.string.msg_select_all");
        this.strMsgDeleteDialogTip = $r("app.string.msg_delete_dialog_tip2", this.conversationSelectedNumber);
    }

    onShow() {
        HiLog.i(TAG, "onShow");
        this.isJumping = false;
        this.getSettingFlagForConvListPage();
        this.page = 0;
        this.requestItem();
        this.subscribeInfo();
        let actionData = {};
        NotificationService.getInstance().cancelMessageNotify(actionData, res => {
        });
    }

    onHide() {
        HiLog.i(TAG, "onHide");
        this.unsubscribeInfo();
    }
    // Querying List Data
    queryAllMessages() {
        let actionData: LooseObject = {
            page: this.page,
            limit: this.limit,
        }
        actionData.numberType = this.numberType;
        messageService.querySessionList(actionData, result => {
            if (result.code == common.int.SUCCESS) {
                HiLog.i(TAG, "queryAllMessages, Success");
                let res = this.buildSessionList(result);
                this.messageList = res;
                this.conversationListDataSource.refresh(this.messageList);
                this.totalMessage = result.total;
                this.total = this.messageList.length;
                if (this.totalMessage === this.total) {
                    this.countUnread();
                }
            } else {
                HiLog.w(TAG, "queryAllMessages, failed");
            }
        });
    }

    dealMmsListContent(element) {
        if (element.hasMms && element.hasAttachment) {
            if (element.content == common.string.EMPTY_STR) {
                element.content = $r("app.string.attachment_no_subject");
            } else {
                element.content = $r("app.string.attachment", element.content);
            }
        }
        if (element.hasMms && !element.hasAttachment && element.content == common.string.EMPTY_STR) {
            element.content = $r("app.string.no_subject");
        }
    }

    buildSessionList(result) {
        let res = [];
        result.response.forEach(item => {
            // Inherit selected items
            this.messageList.some(oldItem => {
                if (item.threadId === oldItem.threadId) {
                    item.isCbChecked = oldItem.isCbChecked;
                    return true;
                }
            });
            let obj: LooseObject = {};
            obj = item;
            obj.itemLeft = 0;
            obj.isDelShow = false;
            dateUtil.convertDateFormatForItem(item, false);
            this.dealMmsListContent(obj);
            res.push(obj);
        });
        return res;
    }

    requestItem() {
        let count = this.page * this.limit;
        if (this.page === 0) {
            this.page++;
            this.queryAllMessages();
        } else if (count < this.totalMessage && this.messageList.length > (this.page - 1) * this.limit) {
            // The restriction on messageList is to prevent multiple requests from being refreshed during initialization
            this.page++;
            this.queryAllMessages();
        }
    }
    // Return to the information list page.
    back() {
        router.back();
    }
    // Tap More at the bottom of the screen
    clickMore() {
        //        this.$element("moreDialog").show();
    }
    // Delete a single piece of information from a notification.
    clickToDelete() {

    }

    clickSearchBack() {
        // Click the search return button.
        this.backSearch();
    }

    backSearch() {
        this.isShowSearchBack = false;
        this.isSearchCoverage = false;
        this.isSearchFocusable = false;
        this.inputValueOfSearch = common.string.EMPTY_STR;
        this.isSearchStatus = true;
        this.isSearchNull = false;
        this.searchStatus = false;
        this.showToolBar = true;
    }
    // Search
    clickToSearch(text) {
        this.inputValueOfSearch = text;
        this.search(text);
    }
    // Search on the notification information page.
    search(text) {
        let actionData: LooseObject = {};
        actionData.inputValue = text
        this.searchTextAsync(actionData)
    }

    searchTextAsync(actionData) {
        actionData.numberType = this.numberType;
        messageService.searchMessageWithLike(actionData, result => {
            if (result.code == common.int.SUCCESS) {
                // Check whether the search result is empty before obtaining the search result.
                if (this.inputValueOfSearch !== common.string.EMPTY_STR) {
                    this.dealSearchResult(result);
                }
            } else {
                this.searchResultListEmpty();
            }
        });
    }

    dealSearchResult(result) {
        this.searchResultList = {
            contentList: [],
            sessionList: []
        }
        this.isSearchStatus = false;
        this.isSearchCoverage = false;
        this.dealSearchResultTimeAndName(result);
        if (this.inputValueOfSearch === result.search) {
            this.searchResultList = result.resultMap;
        }
    }

    dealSearchResultTimeAndName(result) {
        if (result.resultMap.sessionList) {
            result.resultMap.sessionList.forEach(session => {
                session.timeMillisecond = parseInt(session.timeMillisecond);
                dateUtil.convertDateFormatForItem(session, true);
            });
        }
        if (result.resultMap.contentList) {
            result.resultMap.contentList.forEach(content => {
                content.timeMillisecond = parseInt(content.timeMillisecond);
                dateUtil.convertDateFormatForItem(content, true);
                if (content.isFavorite) {
                    content.name = $r("app.string.message_in_favorites");
                }
            });
        }
    }

    searchResultListEmpty() {
        this.searchResultList = {
            contentList: [],
            sessionList: []
        }
        // Display Information List
        this.isSearchStatus = true;
        if (this.isShowSearchBack) {
            this.isSearchCoverage = true;
        } else {
            this.isSearchCoverage = false;
        }
    }
    // Check whether the multi-choice status is selected.
    searchTouchStart() {
        if (this.isMultipleSelectState) {
            return false;
        }
        this.searchStatus = true;
        this.showToolBar = false;
        // Search area touchStart monitoring
        // x > 125 && x < 600) && (y < 70 && y > 20
        //        var x = event.touches[0].x;
        //        if (isSearchType && x > 80 && x < 560) {
        // Show New Button
        this.isShowSearchBack = true;
        // Mask Display
        this.isSearchCoverage = true;
        // Start the input method.
        setTimeout(() => {
            this.isSearchFocusable = true;
        }, common.int.MESSAGE_CODE_THREE_ZERO_ZERO);
        //        }
        this.resetTouch();
        return false;
    }
    // Touch and hold a list to display the selection and deletion functions.
    conversationLongPress(index) {
        // Check whether the left slide button exists. If yes, the button cannot be clicked.
        if (this.itemTouchedIdx >= 0 && this.messageList[this.itemTouchedIdx].isDelShow) {
            return;
        }
        // Touch and hold a list to display the selection and deletion functions.
        this.showToolBar = false;
        HiLog.i(TAG, "conversationLongPress, index: " + index);
        if (this.isMultipleSelectState) {
            this.messageList[index].isCbChecked = !this.messageList[index].isCbChecked;
        } else {
            this.messageList[index].isCbChecked = true;
            this.isMultipleSelectState = true;
        }
        this.setConversationCheckAll(common.int.CHECKBOX_SELECT_UNKNOWN);
    }
    // Check whether all items are selected.
    setConversationCheckAll(type) {
        if (!this.isMultipleSelectState) {
            return;
        }
        if (type == common.int.CHECKBOX_SELECT_NONE) {
            this.conversationSelectedNumber = common.int.MESSAGE_CODE_ZERO;
            this.isConversationCheckAll = false;
        } else if (type == common.int.CHECKBOX_SELECT_ALL) {
            this.conversationSelectedNumber = this.messageList.length;
            this.isConversationCheckAll = true;
        } else {
            // The default value is CHECKBOX_SELECT_UNKNOWN. Check whether there is any unselected item.
            this.isConversationCheckAll = true;
            this.conversationSelectedNumber = common.int.MESSAGE_CODE_ZERO;
            this.messageList.forEach((item, index, array) => {
                if (item.isCbChecked) {
                    this.conversationSelectedNumber++;
                } else if (this.isConversationCheckAll) {
                    this.isConversationCheckAll = false;
                }
            });
        }
        if (!this.isConversationCheckAll) {
            // Non-Select All Status
            this.strCheckBoxSelectTip = $r("app.string.msg_select_all");
        } else {
            // Select All Status
            this.strCheckBoxSelectTip = $r("app.string.msg_deselect_all");
        }
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
    // Searching for a session avatar
    searchConversationHeadClick(index) {
        this.headClickedListener(this.searchResultList.sessionList[index]);
    }

    headClickedListener(item) {
        // Tap the avatar to go to the contact details page or recipient list page.
        if (this.isJumping) {
            return;
        }
        if (item.isFavorite != null && item.isFavorite) {
            return;
        }
        var telephone = item.telephone;
        var contactsNum = item.contactsNum;
        this.isJumping = true;
        if (contactsNum == common.int.MESSAGE_CODE_ONE) {
            var actionData: LooseObject = {};
            actionData.phoneNumber = telephone;
            actionData.pageFlag = common.contractPage.PAGE_FLAG_CONTACT_DETAILS;
            this.jumpToContract(actionData);
        } else {
            let threadId = item.threadId;
            let contactsNum = item.contactsNum;
            this.jumpToGroupDetail(threadId, contactsNum);
        }
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
    // Go to session details.
    searchConversationClick(index) {
        this.searchMmsClicked(this.searchResultList.sessionList[index]);
    }
    // Go to SMS details.
    searchMmsClicked(item) {
        if (item.isFavorite) {
            router.push({
                uri: "pages/my_star/my_star",
                params: {
                    searchContent: this.inputValueOfSearch
                }
            });
        } else {
            this.jumpToConversationPage(item);
        }
    }
    // Clicking a profile picture to jump to the contact details page or the list page of multiple recipients
    searchSmsHeadClick(index) {
        this.headClickedListener(this.searchResultList.contentList[index]);
    }
    // The session details page is displayed.
    searchSmsClick(index) {
        this.searchMmsClicked(this.searchResultList.contentList[index]);
    }
    // Slide your finger to exit the search mode.
    searchCoverageClick() {
        this.backSearch();
    }
    // Counting the number of unread messages
    countUnread() {
        let actionData: LooseObject = {};
        let that = this;
        messageService.statisticalData(actionData, function (result) {
            if (result.code == common.int.SUCCESS) {
                // Unreading of notification messages
                that.unreadTotalOfInfo = result.response.unreadTotalOfInfo;
                HiLog.i(TAG, "countUnread = " + that.unreadTotalOfInfo);
            } else {
                HiLog.w(TAG, "countUnread, statisticalData failed");
            }
        });
    }
    // Mark all unread notifications as read.
    clickToMarkAllAsReadForInfo() {
        let actionData = {
            hasRead: 1,
            smsType: 1
        }
        let threadIds = [];
        for (let msg of this.messageList) {
            msg.countOfUnread = common.int.MESSAGE_CODE_ZERO;
            threadIds.push(msg.threadId);
        }
        this.cancelMessageInfoNotify(threadIds, () => {
            messageService.markAllToRead(actionData);
            this.unreadTotalOfInfo = 0;
        });
    }

    markAllAsReadByIndex(index) {
        let item = this.messageList[index];
        let threadId = item.threadId;
        let threadIds = [threadId];
        this.cancelMessageInfoNotify(threadIds, () => {
            // Marks all information about a contact (argument type: array) as read.
            this.markAllAsRead(threadIds);
            this.setListItemTransX(0);
            item.isDelShow = false;
        });
    }

    cancelMessageInfoNotify(threadIds, callback) {
        let actionData = {
            threadIds: threadIds,
            hasRead: 0
        };
        NotificationService.getInstance().cancelMessageNotify(actionData, res => {
            callback();
        });
    }

    markAllAsRead(threadIds) {
        let tempMsgList = this.messageList;
        // Marks all information about a contact (argument type: array) as read.
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
        this.unreadTotalOfInfo = this.unreadTotalOfInfo - threadIds.length;
    }

    selectInMoreMenu(menuId: number) {
        if (menuId == 1) {
            // Delete
            this.isMultipleSelectState = true;
            this.showToolBar = false;
            this.setConversationCheckAll(common.int.CHECKBOX_SELECT_UNKNOWN);
        } else {
            // The harassment blocking page is displayed, which is in the Phone Manager app.
        }
    }
    // Button Delete
    clickConversationDelete() {
        if (this.conversationSelectedNumber == common.int.MESSAGE_CODE_ZERO) {
            return;
        }
        if (this.conversationSelectedNumber == common.int.MESSAGE_CODE_ONE) {
            this.strMsgDeleteDialogTip = $r("app.string.msg_delete_dialog_tip1");
        } else if (this.conversationSelectedNumber == this.messageList.length) {
            this.strMsgDeleteDialogTip = $r("app.string.msg_delete_dialog_tip3");
        } else {
            this.strMsgDeleteDialogTip = $r("app.string.msg_delete_dialog_tip2", this.conversationSelectedNumber);
        }
        this.hasLockMsg = (this.messageList.some((element, index) => element.isCbChecked && element.isLock));
    }

    checkSelectedNumberIsEmpty() {
        return this.conversationSelectedNumber == common.int.MESSAGE_CODE_ZERO
    }
    // Cancel Ejection
    deleteDialogCancel() {
        if (this.isSelectLockMsg) {
            this.isSelectLockMsg = false;
        }
    }

    setSelectLock() {
        this.isSelectLockMsg = !this.isSelectLockMsg;
    }
    // Delete the checkbox lockout event.
    setSelectLockChange(event) {
        this.isSelectLockMsg = event.checked;
    }

    deleteDialogConfirm() {
        this.setDelShow();
        let mmsList = [];
        let threadIds = [];
        let lockSessionIds = [];
        for (let item of this.messageList) {
            if (item.isCbChecked) {
                if (item.isLock && !this.isSelectLockMsg) {
                    lockSessionIds.push(item.threadId);
                    mmsList.push(item);
                } else {
                    threadIds.push(item.threadId);
                }
            } else {
                mmsList.push(item);
            }
        }
        this.isMultipleSelectState = false;
        this.showToolBar = true;
        this.isSelectLockMsg = false;
        this.messageList = mmsList;
        this.conversationListDataSource.refresh(this.messageList);
        this.total = mmsList.length;
        if (this.total == 0) {
            router.back();
        }
        this.deleteNotifyMessageInfo(threadIds, lockSessionIds, () => {
            this.deleteMessageInfoByThreadIds(threadIds, lockSessionIds);
        });
    }

    setDelShow() {
        if (this.itemTouchedIdx >= 0) {
            let item = this.messageList[this.itemTouchedIdx];
            this.setListItemTransX(0);
            item.isDelShow = false;
        }
    };

    deleteNotifyMessageInfo(threadIds, lockSessionIds, callback) {
        let sessionIds = [];
        if (lockSessionIds.length > 0) {
            sessionIds.push(lockSessionIds);
        }
        if (threadIds.length > 0) {
            sessionIds.push(threadIds);
        }
        this.cancelMessageInfoNotify(sessionIds, callback);
    }

    deleteMessageInfoByThreadIds(threadIds, lockSessionIds) {
        let actionData: LooseObject = {};
        if (threadIds.length > 0) {
            actionData.threadIds = threadIds;
            messageService.deleteMessageById(actionData);
        }
        if (lockSessionIds.length > 0) {
            actionData.threadIds = lockSessionIds;
            messageService.dealMessageLockContent(actionData, res => {
                actionData.hasLock = 0;
                messageService.deleteMessageBySessionIdsAndLock(actionData);
            });
        }
    }
    // Select All/Deselect All
    clickConversationCheckAll() {
        if (this.isConversationCheckAll) {
            // Select All --> Deselect All
            for (let item of this.messageList) {
                item.isCbChecked = false;
            }
            this.setConversationCheckAll(common.int.CHECKBOX_SELECT_NONE);
        } else {
            // Not Select All --> Select All
            for (let item of this.messageList) {
                item.isCbChecked = true;
            }
            this.setConversationCheckAll(common.int.CHECKBOX_SELECT_ALL);
        }
    }

    onBackPress() {
        // Key returned by the system. The value true indicates interception.
        if (this.isMultipleSelectState) {
            for (let element of this.messageList) {
                element.isCbChecked = false;
            }
            this.isMultipleSelectState = false;
            this.showToolBar = true;
            return true;
        }
        return false;
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

    exitConversationSelect() {
        this.onBackPress();
    }

    touchStart(event: GestureEvent, index: number) {
        if (this.isMultipleSelectState) {
            return;
        }
        // Check whether the current touch item is the same as that of a touch item.
        // If not, reset the previous touch item.
        if (this.itemTouchedIdx !== -1 && index !== this.itemTouchedIdx) {
            let itemTouched = this.messageList[this.itemTouchedIdx];
            if (itemTouched != undefined && itemTouched != null && itemTouched.isDelShow) {
                this.setListItemTransX(0);
                itemTouched.isDelShow = false;
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

    resetTouch() {
        if (this.itemTouchedIdx !== -1) {
            let item = this.messageList[this.itemTouchedIdx];
            if (item == undefined) {
                return false;
            }
            if (item.isDelShow) {
                item.isDelShow = false;
                this.setListItemTransX(0);
                return true;
            }
        }
        return false;
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

    deleteAction(idx) {
        let element = this.messageList[idx];
        this.strMsgDeleteDialogTip = $r("app.string.msg_delete_dialog_tip1");
        element.isCbChecked = true;
        this.hasLockMsg = (this.messageList.some((element, index) => element.isCbChecked && element.isLock));
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
    // Subscribe to New Messages Received
    subscribeInfo() {
        HiLog.i(TAG, "subscribeInfo, start");
        let events = [common.string.RECEIVE_TRANSMIT_EVENT]
        let commonEventSubscribeInfo = {
            events: events
        };
        commonEvent.createSubscriber(commonEventSubscribeInfo, this.createSubscriberCallBack.bind(this));
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

    createSubscriberCallBack(err, data) {
        this.commonEventData = data;
        // Received subscription
        commonEvent.subscribe(this.commonEventData, this.subscriberCallBack.bind(this));
    }

    subscriberCallBack(err, data) {
        this.page = 1;
        this.queryAllMessages();
    }
    // Unsubscribe
    unsubscribeInfo() {
        if (this.commonEventData != null) {
            commonEvent.unsubscribe(this.commonEventData, () => {
                HiLog.i(TAG, "unsubscribeInfo, success");
            });
        }
    }
    // Switching to the Contacts app
    jumpToContract(actionData) {
        var str = commonService.commonContractParam(actionData);
        globalThis.mmsContext.startAbility(str).then((data) => {
        }).catch((error) => {
            HiLog.e(TAG, "jumpToContract, failed: " + JSON.stringify(error.message));
        })
        this.isJumping = false;
    }
    // Obtains the switch value for integrating notification information and displaying contact avatars.
    getSettingFlagForConvListPage() {
        let result = settingService.getSettingFlagForConvListPage();
        if (result) {
            this.isShowContactHeadIcon = result.isShowContactHeadIcon;
        }
    }
}
