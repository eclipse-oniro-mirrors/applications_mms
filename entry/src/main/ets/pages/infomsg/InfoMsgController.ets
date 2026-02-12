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
import commonEvent from '@ohos.commonEventManager';
import router from '@system.router';
import common, { MarkRead } from '../../data/commonData';
import commonService from '../../service/CommonService';
import lazy { DateUtil } from '../../utils/DateUtil';
import LooseObject from '../../data/LooseObject'
import ConversationListService from '../../service/ConversationListService';
import HiLog from '../../utils/HiLog';
import NotificationService, { IBadgeContextInfo, ISetBadgeContextInfo } from '../../service/NotificationService';
import settingService from '../../service/SettingService';
import ConversationListDataSource from '../../model/ConversationListDataSource'
import StringUtil from '../../utils/StringUtil';
import { BusinessError } from '@ohos.base';
import ConversationListController, { ActionData, Params, messageType, Result  } from '../conversationlist/conversationListController';
import { GlobalContext } from '../../MainAbility/GlobalHelper';
import myCommon from '@ohos.app.ability.common';
import ConListController from '../conversationlist/conversationListController';
import dotCommon, { longPressDeParams, dotNoNeedParmas, onlyStateParam } from '../../utils/MmsDot/DotCommon';
import DotUtil from '../../utils/MmsDot/DotUtils';
import PanGestureUtil from '../../utils/PanGestureUtil';
import { SearchType } from '../../utils/SearchUtil';
import commonEventManager from '@ohos.commonEventManager';
import { Queue } from '@kit.ArkTS';
import { emitter, systemDateTime } from '@kit.BasicServicesKit';
import { ThreadObjectUtils } from '../../model/conversationlist/ThreadObjectUtils';
import EmitterConstant from '../../data/EmitterConstant';
import SharedPreferencesUtils from '../../utils/SharedPreferencesUtils';
import ConversationController from '../conversation/conversationController';
import ConversationService from '../../service/ConversationService';
import AccessibilityUtil from '../../utils/AccessibilityUtil';
import FileUtils from '../../utils/FileUtils';

export interface resType {
    code: number,
    response: LooseObject | PromiseLike<LooseObject>,
    abilityResult: LooseObject[],
}

const TAG = 'InfoMsgController'

export default class InfoMsgController {
    delDialogShow: boolean = false;
    commonEventData?: commonEvent.CommonEventSubscriber;
    public updateEventData?: commonEventManager.CommonEventSubscriber;
    public svgDelete: string = 'sys.symbol.trash';
    total: number = 0;
    strCheckBoxSelectTip?: Resource;
    strMsgDeleteDialogTip?: Resource;
    // Number of selected sessions
    conversationSelectedNumber: number = 0;
    // Indicates whether the multi-select state is selected.
    isMultipleSelectState: boolean = false;
    isSearchFocusable: boolean = false;
    // No The session list is selected.
    isConversationCheckAll: boolean = false;
    // Value entered in the search box on the information list page
    inputValueOfSearch: string = '';
    // List of search results
    public searchResultList: Record<string, messageType[]> = {
        'sessionList': [],
        'contentList': []
    };
    // Search Results Queue
    searchResultListQueue: Array<LooseObject> = [];
    // Search Text Queue
    searchTextQueue: Array<LooseObject> = [];
    // Queue timer start flag bit
    setTimeOutQueueFlag: boolean = false;
    // Indicates whether to perform redirection to avoid repeated redirection.
    isJumping: boolean = false;
    // Indicates whether to display the search return button. By default, the button is not displayed.
    isShowSearchBack: boolean = false;
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
    messageList: Array<messageType> = [];
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
    public totalMessageCount: number = 0;
    taskId: number = -1;
    refreshIndex: number = 0;
    // notification conversation list adapters
    conversationListDataSource: ConversationListDataSource = new ConversationListDataSource();
    public conListCtrl: ConListController = ConListController.getInstance();
    public pageInfos: NavPathStack = new NavPathStack();
    public queryTerminate = new Map<number, boolean>();
    public currentQueryTimeID: number = 0;
    // Used for redirecting unread message queues.
    public unReadQueue: Queue<number> = new Queue();
    public unReadListSize: number = 0;
    private static sInfoMsgCtrl: InfoMsgController | undefined = undefined;
    public longPressFingers: number = 0;
    public refreshTimeOut: number = 0;
    static getInstance() {
        if (!InfoMsgController.sInfoMsgCtrl) {
            InfoMsgController.sInfoMsgCtrl = new InfoMsgController();
            AppStorage.setAndLink('InfoMsgController', InfoMsgController.sInfoMsgCtrl);
        }
        return InfoMsgController.sInfoMsgCtrl;
    }

    public static release() {
        clearTimeout(InfoMsgController.getInstance().refreshTimeOut);
        InfoMsgController.sInfoMsgCtrl = undefined;
    }

    onInit(pageInfos: NavPathStack, context: Context) {
        HiLog.i(TAG, 'onInit');
        this.pageInfos = pageInfos;
        this.strCheckBoxSelectTip = $r('app.string.msg_select_all');
        this.strMsgDeleteDialogTip = $r('app.plural.msg_delete_dialog_tip2', this.conversationSelectedNumber,
            this.conversationSelectedNumber);
        HiLog.w(TAG,`unreadTotalOfInfo is: ${this.unreadTotalOfInfo}`)
    }

    async onShow(context: Context) {
        HiLog.i(TAG, 'onShow');
        this.countUnread(context);
        this.isJumping = false;
        this.getSettingFlagForConvListPage();
        this.page = 0;
        // 从详情返回的刷新延时一会儿，以确保草稿修改保存好了再刷新
        let isBackFromConversion: boolean = GlobalContext.getContext().getObject('backFromConversation') as boolean;
        // 防止onshow之前有其他外调用刷新页面与此时共同刷新引起的时序问题，停止正在刷新页面的操作
        this.queryTerminate[this.currentQueryTimeID] = true;
        this.clearOutOfDateVariables();
        if (isBackFromConversion) {
            this.taskId = setTimeout(() => {
                this.requestItem(context);
            }, 100)
        } else {
            this.requestItem(context);
        }
        this.subscribeInfo(context);
        let badgeContext: IBadgeContextInfo = {
            appContext: context,
            updateBadgeEventCode: TAG + '->onShow',
            tracedId: systemDateTime.getTime().toString(),
        }
        NotificationService.getInstance(context).updateBadgeNumberWithContext(badgeContext);
        HiLog.i(TAG, 'onShow NotificationService.cancelAllNotify()');
        NotificationService.getInstance().cancelAllNotify();
    }

    onHide() {
        HiLog.i(TAG, 'onConceal');
        this.queryTerminate[this.currentQueryTimeID] = true
        this.clearOutOfDateVariables();
        this.unsubscribeInfo();
    }
    // Querying List Data

    queryAllMessages(context: Context, queryTimeID: number) {
        this.queryPageMessages(context, this.page, StringUtil.getLimitForSession(this.page), queryTimeID, (isEnd) => {
            HiLog.i(TAG, 'isEnd: ' + isEnd + ', queryTerminate:' + queryTimeID);
            if (this.queryTerminate[queryTimeID]) {
                HiLog.i(TAG, 'queryTerminate: ' + this.queryTerminate[queryTimeID]);
                if (this.queryTerminate[this.currentQueryTimeID]) {
                    this.clearOutOfDateVariables();
                }
                return;
            }
            if (!isEnd) {
                this.page++;
                this.queryAllMessages(context, queryTimeID);
            } else {
                this.page = 0;
            }
        });
    }

    queryPageMessages(context: Context, page: number, limit: number, queryTimeID: number, callback?: (isEnd: boolean) => void) {
        let actionData: LooseObject = {};
        HiLog.iw(TAG, 'queryPageMessages, page:' + page + ',limit:' + limit);
        actionData.smsType = common.sms_type.NOTICE;
        actionData.page = page;
        actionData.limit = limit;
        actionData.orderByTimeDesc = true;
        actionData.isNeedMessageSort = true;
        ConversationListService.getInstance()
          .getSessionListResultNew(actionData, GlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext).then((data) => {
            // getSessionListResultNew 接口据库没有数据时返回为列表数量为1。当前修改牵涉接口多待后续修改。
            if (data?.response?.length === 1 && data?.response[0]?.threadId <= 0) {
                HiLog.w(TAG, 'queryPageMessages getSessionListResultNew return one invalid item');
                if (callback) {
                    callback(true);
                }
                return;
            }
            let queriedList: messageType[] = ThreadObjectUtils.jsonToObjArray(data.response as messageType[]);
            if (queriedList.length > 0) {
                this.doProcessTimeForInfoSessionListItem(context, queriedList);
            }
            this.total = this.refreshIndex + queriedList.length;
            let isEnd = this.total >= this.totalMessage || queriedList.length < limit;
            let count = 0;
            if (this.isMultipleSelectState) {
                queriedList.forEach((item: messageType) => {
                    this.messageList.slice(this.refreshIndex, this.messageList.length).some(oldItem => {
                        if (item.threadId === oldItem.threadId) {
                            item.isCbChecked = oldItem.isCbChecked;
                            return true;
                        }
                        return
                    });
                })
            }
            this.setUnReadQueue(actionData.page, queriedList);
            if (!this.queryTerminate[queryTimeID]) {
                this.conversationListDataSource.refreshPage(queriedList, this.refreshIndex, null, isEnd);
                this.messageList = this.conversationListDataSource.mmsList;
                HiLog.iw(TAG, 'queryPageMessages, this.totalMessage: ' + this.totalMessage +
                    ', this.total: ' + this.total + ', this.page: ' + this.page);
                this.refreshIndex = isEnd ? 0 : this.total;
                if (isEnd) {
                    this.messageList.forEach((item: messageType) => {
                        count += item.messageCount;
                        if (item.isDraft) {
                            count += 1;
                        }
                    });
                    this.totalMessageCount = count;
                }
            }
            if (callback) {
                callback(isEnd);
            }
        })
    }


    private doProcessTimeForInfoSessionListItem(context: Context, InfoMsgSessionList: messageType[]) {
        for (let session of InfoMsgSessionList) {
            DateUtil.convertDateFormatForItem(session);
           if (!StringUtil.isEmpty(session.telephoneFormat) &&
            FileUtils.isHasLocationImage(context, session.telephoneFormat)) {
                session.cachedComInfoUri = FileUtils.getSandboxPath(context, session.telephoneFormat);
            }
        }
    }

    private async setUnReadQueue(page: number, response: LooseObject[]) {
        if (page == 1) {
            HiLog.i(TAG, 'new Queue, page is 1');
            this.unReadQueue = new Queue();
            this.unReadListSize = 0;
        }
        for (let i = 0; i < response.length; i++) {
            if (response[i].countOfUnread && response[i].countOfUnread > 0) {
                this.unReadQueue.add(this.unReadListSize + i);
            }
        }
        this.unReadListSize += response.length;
    }

    private clearOutOfDateVariables() {
        HiLog.i(TAG, 'clearOutOfDateVariables when search is terminated.');
        this.page = 0;
        this.refreshIndex = 0
        this.total = 0;
        this.totalMessage = 0;
        this.totalMessageCount = 0;
    }

    dealMmsListContent(element: LooseObject) {
        if (element.hasMms && element.hasAttachment) {
            if (element.content == common.STR.EMPTY_STR) {
                element.content = $r('app.string.attachment_no_subject');
            } else {
                element.content = $r('app.string.attachment', element.content);
            }
        }
        if (element.hasMms && !element.hasAttachment && element.content == common.STR.EMPTY_STR) {
            element.content = $r('app.string.no_subject');
        }
    }

    buildSessionList(result: LooseObject) {
        let res: Array<LooseObject> = [];
        result.response.forEach((item: LooseObject) => {
            // Inherit selected items
            this.messageList.some(oldItem => {
                if (item.threadId === oldItem.threadId) {
                    item.isCbChecked = oldItem.isCbChecked;
                    return true;
                }
                return
            });
            let obj: LooseObject = {};
            obj = item;
            obj.itemLeft = 0;
            obj.isDelShow = false;
            DateUtil.convertDateFormatForItem(item);
            this.dealMmsListContent(obj);
            res.push(obj);
        });
        return res;
    }

    requestItem(context: Context) {
        if (this.taskId != -1) {
            clearTimeout(this.taskId);
            this.taskId = -1;
        }
        let queryTimeID = new Date().getTime();
        this.queryTerminate[queryTimeID] = false;
        this.currentQueryTimeID = queryTimeID;
        if (this.page === 0) {
            this.page = 1;
            let actionData: LooseObject = {};
            actionData.smsType = common.sms_type.NOTICE;
                ConversationListService.getInstance().getSessionListSize(actionData, GlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext).then((value) => {
                this.totalMessage = value;
                if (value > 0) {
                    HiLog.i(TAG, 'currentQueryTimeID: ' + this.currentQueryTimeID);
                    this.queryAllMessages(context, queryTimeID);
                } else {
                    this.pageInfos?.pop()
                    this.page = 0;
                }
            })
        } else {
            HiLog.i(TAG, 'isLoading');
            this.taskId = setTimeout(() => {
                this.requestItem(context);
            }, 1000)
        }
    }
    // Return to the information list page.
    back() {
        // router.back({
        //     uri:'',
        //     params: {
        //         hasInfoMsg: this.total == 0 ? true : false
        //     }
        // });
        //todo
        AppStorage.SetOrCreate('backHasInfoMsg', this.total == 0 ? true : false);
        this.pageInfos?.pop();
    }
    // Tap More at the bottom of the screen
    clickMore() {
        //        this.$element('moreDialog').show();
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
        this.isSearchFocusable = false;
        this.inputValueOfSearch = common.STR.EMPTY_STR;
        this.isSearchStatus = true;
        this.isSearchNull = false;
        this.searchStatus = false;
        this.showToolBar = true;
    }

    checkedStatus(): Set<number | string> {
        return ConversationListController.getInstance().checkedStatus;
    }

    conversationLongPress(index: number) {
        // Check whether the left slide button exists. If yes, the button cannot be clicked.
        if (this.itemTouchedIdx >= 0 && this.messageList[this.itemTouchedIdx].isDelShow) {
            return;
        }
        // Touch and hold a list to display the selection and deletion functions.
        this.showToolBar = false;
        HiLog.i(TAG, 'conversationLongPress, index: ' + index);
        if (this.isMultipleSelectState) {
            this.messageList[index].isCbChecked = !this.messageList[index].isCbChecked;
        } else {
            this.messageList[index].isCbChecked = true;
            this.isMultipleSelectState = true;
            PanGestureUtil.addFirstSelect(index, this.messageList[index].isCbChecked, true)
        }
        this.setConversationCheckAll(common.int.CHECKBOX_SELECT_UNKNOWN);
        this.checkedStatus().add(this.messageList[index].threadId);
        this.sendSelectedEvent(this.messageList[index].threadId);
    }
    // Check whether all items are selected.
    setConversationCheckAll(type: number) {
        if (!this.isMultipleSelectState) {
            return;
        }
        if (type == common.int.CHECKBOX_SELECT_NONE) {
            this.conversationSelectedNumber = common.int.MESSAGE_CODE_ZERO;
            this.isConversationCheckAll = false;
            this.checkedStatus().clear();
            PanGestureUtil.refresh()
        } else if (type == common.int.CHECKBOX_SELECT_ALL) {
            this.conversationSelectedNumber = this.messageList.length;
            this.isConversationCheckAll = true;
            this.checkedStatus().clear();
            for (let index = 0; index < this.messageList.length; index++) {
                if (this.messageList[index].isCbChecked) {
                    this.checkedStatus().add(this.messageList[index].threadId);
                }
            }
            PanGestureUtil.addFirstSelect(0, true, true, this.messageList.length)
        } else {
            // The default value is CHECKBOX_SELECT_UNKNOWN. Check whether there is any unselected item.
            this.isConversationCheckAll = true;
            this.conversationSelectedNumber = common.int.MESSAGE_CODE_ZERO;
            this.messageList.forEach((item, index, array) => {
                if (item.isCbChecked) {
                    this.conversationSelectedNumber++;
                    this.checkedStatus().add(item.threadId);
                } else if (this.isConversationCheckAll) {
                    this.isConversationCheckAll = false;
                }
            });
        }
        if (!this.isConversationCheckAll) {
            // Non-Select All Status
            this.strCheckBoxSelectTip = $r('app.string.msg_select_all');
        } else {
            // Select All Status
            this.strCheckBoxSelectTip = $r('app.string.msg_deselect_all');
        }
    }

    clearSelectedState(){
        if (this.checkedStatus().size > 0) {
            this.checkedStatus().clear();
            this.sendSelectedEvent(null);
        }
    }

    sendSelectedEvent(id: number | null) {
        let innerEvent: emitter.InnerEvent = {
            eventId: EmitterConstant.EVENT_CONVERSATION_LIST_SELECT_STATUES_CHANGE,
        };
        let eventData: emitter.EventData = {
            data: { 'id': id }
        };
        emitter.emit(innerEvent, eventData);
    }

    // The SM details page is displayed.
    clickInfoToConversation(context: Context, index: number) {
        HiLog.w(TAG, 'clickInfoToConversation');
        if (this.resetTouch()) {
            HiLog.i(TAG, `[clickInfoToConversation] this.resetTouch()`)
            return;
        }
        // If multiple options are selected, the system responds to CheckBox.
        if (this.isMultipleSelectState) {
            HiLog.i(TAG, `[clickInfoToConversation] this.isMultipleSelectState`)
            this.messageList[index].isCbChecked = !this.messageList[index].isCbChecked;
            PanGestureUtil.addFirstSelect(index, this.messageList[index].isCbChecked, true)
            if (this.messageList[index].isCbChecked) {
                this.checkedStatus().add(this.messageList[index].threadId);
            } else {
                this.checkedStatus().delete(this.messageList[index].threadId);
            }
            this.setConversationCheckAll(common.int.CHECKBOX_SELECT_UNKNOWN);
            this.sendSelectedEvent(this.messageList[index].threadId);
            return;
        }
        let pages: string[] = this.pageInfos?.getAllPathName();
        let curBp: string = AppStorage.get('curBp') as string;
        if (pages[pages.length - 1] === 'Conversation' && curBp === common.STR.DEVICE_MOBILE_PHONE) {
            // Add logs for ease of maintenance
            HiLog.i(TAG, `[clickInfoToConversation] this.isJumping is ${this.isJumping}`)
            return;
        }
        this.isJumping = true;
        ConversationController.getInstance().resetMmsSource();
        this.jumpToConversationPage(this.messageList[index]);
        onlyStateParam.STATE = 3;
        DotUtil.getInstance().reportEvent(onlyStateParam, dotCommon.eventName.CLICK_TO_VIEW_SMS_EVENT);
    }

    /**
     * 滑动多选多选框状态
     */
    public gesTureListCheckBox(index: number, startCbChecked: boolean) {
        this.messageList[index].isCbChecked = startCbChecked;
        if (this.messageList[index].isCbChecked) {
            this.checkedStatus().add(this.messageList[index].threadId);
        } else {
            this.checkedStatus().delete(this.messageList[index].threadId);
        }
        this.conversationSelectedNumber = this.messageList.filter((item) => {
            return item.isCbChecked
        }).length
        if (this.conversationSelectedNumber === this.messageList.length) {
            this.isConversationCheckAll = true
            this.strCheckBoxSelectTip = $r('app.string.msg_deselect_all');
        } else if (this.isConversationCheckAll) {
            this.isConversationCheckAll = false
            this.strCheckBoxSelectTip = $r('app.string.msg_select_all');
        }
        this.sendSelectedEvent(this.messageList[index].threadId);
    }

    clickCheckBox(context: Context, index: number, value: boolean) {
        this.clickInfoToConversation(context, index);
    }

    // The session details page is displayed.
    jumpToConversationPage(item: messageType) {
        HiLog.iw(TAG, `jumpToConversationPage start ${item.threadId}`)
        let curBp: string = AppStorage.get('curBp') as string;
        this.conListCtrl.isJumping = false;
        let params: Params = {
            yellowPageId: item.yellowPageId,
            hasYellowPageIcon: item.hasYellowPageIcon,
            icon: item.icon,
            rawContactId: item.rawContactId as string,
            strContactsNumber: item.telephone,
            strContactsNumberFormat: item.telephoneFormat,
            strContactsName: item.name,
            contactsNum: item.contactsNum,
            threadId: item.threadId,
            isDraft: item.isDraft,
            draftContent: item.content,
            searchContent: this.inputValueOfSearch,
            smsType: item.smsType,
            isNewMsgWithDraft: item?.messageCount == 0 && item?.isDraft,
            isFromInfoMsgView: true,
            messageCount: item.messageCount as number,
            photoFirstNames: item?.photoFirstNames,
            contactId:item.contactId,
        } as Params;
        if (item?.isDraft && item?.messageCount == 0 && !(item.telephone?.startsWith('sip:')
            && item.telephone?.includes('botplatform'))) {
            this.pageInfos.pushPathByName('CreateNewConversation', params)
        } else {
            this.pageInfos.pushPathByName('Conversation', params)
            if ((item.telephone?.startsWith('sip:') && item.telephone?.includes('botplatform'))) {
                DotUtil.getInstance().reportEvent(dotNoNeedParmas, dotCommon.eventName.CLICK_CHATBOT);
            }
        }
        HiLog.i(TAG, `jumpToConversationPage end`)
    }
    // Searching for a session avatar
    searchConversationHeadClick(index: number) {
        this.headClickedListener(this.searchResultList.sessionList[index]);
    }

    headClickedListener(item: messageType) {
        // Tap the avatar to go to the contact details page or recipient list page.
        if (this.isJumping) {
            return;
        }
        if (item.isFavorite != null && item.isFavorite as boolean) {
            return;
        }

        let telephone: string = item.telephone;
        let contactsNum: number = item.contactsNum;
        this.isJumping = true;
        if (contactsNum == common.int.MESSAGE_CODE_ONE) {
            let actionData: ActionData = {};
            actionData.phoneNumber = telephone;
            actionData.pageFlag = common.contactPage.PAGE_FLAG_CONTACT_DETAILS;
            this.jumpToContact(actionData);
        } else {
            let threadId: number = item.threadId;
            let contactsNum: number = item.contactsNum;
            this.jumpToGroupDetail(threadId, contactsNum);
        }
    }
    // Go to the multi-faceted portrait list page.
    jumpToGroupDetail(threadId: number, contactsNum: number) {
        // let actionData = {
        //     uri: 'pages/group_detail/group_detail',
        //     params: {
        //         threadId: threadId,
        //         contactsNum: contactsNum
        //     }
        // };
        HiLog.i(TAG, 'jumpToGroupDetail')
        this.isJumping = false;
        this.pageInfos.pushPathByName('GroupDetail', {
            threadId: threadId,
            contactsNum: contactsNum
        } as Params);
    }
    // Go to session details.
    searchConversationClick(index: number) {
        this.searchMmsClicked(this.searchResultList.sessionList[index]);
    }
    // Go to SMS details.
    searchMmsClicked(item: messageType) {
        if (item.isFavorite) {
            router.push({
                uri: 'pages/my_star/my_star',
                params: {
                    searchContent: this.inputValueOfSearch
                }
            });
        } else {
            this.jumpToConversationPage(item);
        }
    }
    // Clicking a profile picture to jump to the contact details page or the list page of multiple recipients
    searchSmsHeadClick(index: number) {
        this.headClickedListener(this.searchResultList.contentList[index]);
    }
    // The session details page is displayed.
    searchSmsClick(index: number) {
        this.searchMmsClicked(this.searchResultList.contentList[index]);
    }
    // Slide your finger to exit the search mode.
    searchCoverageClick() {
        this.backSearch();
    }
    // Counting the number of unread messages
    countUnread(context: Context) {
        ConversationListService.getInstance().statisticalData((result: Result) => {
            if (result.code == common.int.SUCCESS) {
                // Unreading of notification messages
                this.unreadTotalOfInfo = result.response.unreadTotalOfInfo;
                HiLog.iw(TAG, 'countUnread = ' + this.unreadTotalOfInfo);
            } else {
                HiLog.w(TAG, 'countUnread, statisticalData failed');
            }
        }, context);
    }

    //设置延时任务，点击全部已读后，刷新数据
    markTimetOutForClickMarkAllRead() {
        this.refreshTimeOut = setTimeout(() => {
            this.messageList.forEach((msg: messageType, index: number) => {
                msg.countOfUnread = common.int.MESSAGE_CODE_ZERO;
            })
            this.conversationListDataSource.refresh(this.messageList);
            this.messageList = this.conversationListDataSource.mmsList;
        }, common.int.UPDATA_INFOMSG_UNREADCOUNT_TIME);
    }
    // Mark all unread notifications as read.
    clickToMarkAllAsReadForInfo(context: Context) {
        HiLog.w(TAG, 'clickToMarkAllAsReadForInfo');
        HiLog.w(TAG,
            `this.totalMessage == ${this.totalMessage},  this.messageList.length = ${this.messageList.length}`);
        if (this.totalMessage > this.messageList.length) {
            this.markTimetOutForClickMarkAllRead();
            HiLog.w(TAG, 'clickToMarkAllAsReadForInfo data no load finish');
        }
        this.messageList.forEach((msg: messageType, index: number) => {
            msg.countOfUnread = common.int.MESSAGE_CODE_ZERO;
        })
        this.conversationListDataSource.refresh(this.messageList);
        this.messageList = this.conversationListDataSource.mmsList;
        let actionData: LooseObject = {};
        actionData.hasRead = common.is_read.UN_READ;
        actionData.smsType = common.sms_type.NOTICE;
        actionData.markReadType = MarkRead.allInfo;
        HiLog.w(TAG, 'clickToMarkAllAsReadForInfo NotificationService.cancelMessageNotify');
            ConversationListService.getInstance().markAllAsRead(context, actionData, () => {
                // 如果是折叠屏手机处于展开态，不仅刷新角标，还需要刷新会话未读数
                let curBp: string = AppStorage.get('curBp') as string;
                if (curBp != common.STR.DEVICE_MOBILE_PHONE) {
                    HiLog.w(TAG, '[clickToMarkAllAsReadForInfo] statisticalData');
                    this.conListCtrl.statisticalData(context);
                } else {
                    let badgeContext: IBadgeContextInfo = {
                        appContext: context,
                        updateBadgeEventCode: TAG + '->clickToMarkAllAsReadForInfo',
                        tracedId: systemDateTime.getTime().toString()
                    }
                    NotificationService.getInstance(context).updateBadgeNumberWithContext(badgeContext);
                }
            });
        this.unreadTotalOfInfo = 0;
        this.unReadQueue = new Queue();
        this.unReadListSize = 0;
        NotificationService.getInstance().cancelAllNotify();
    }


    markAsReadByThread(context: Context, item: messageType) {
        HiLog.i(TAG, 'markAsReadByThread')
        let threadId: number = item.threadId;
        let actionData: LooseObject = {};
        actionData.threadId = threadId;
        actionData.hasRead = common.is_read.UN_READ;
        HiLog.w(TAG, '[info session markAllAsReadByIndex] sessionId: ' + threadId + ', unreadCount: ' + item.countOfUnread);
        NotificationService.getInstance().cancelMessageNotify(context, actionData, () => {
            ConversationListService.getInstance().markAllToRead(context, actionData, () => {
                this.countUnread(context);
            });
            let badgeContext: IBadgeContextInfo = {
                appContext: context,
                updateBadgeEventCode: TAG + '->markAsReadByThread',
                tracedId: systemDateTime.getTime().toString(),
            }
            NotificationService.getInstance(context).updateBadgeNumberWithContext(badgeContext);
        });
        let noticeUnreadMessageNumber = this.unreadTotalOfInfo - item.countOfUnread;
        HiLog.i(TAG, 'click item mark read button unreadTotalOfInfo number: ' + this.unreadTotalOfInfo +
            'noticeUnreadMessageNumber: ' + noticeUnreadMessageNumber);
        /**
         * 如果发生异常，出现负数，则将未读数量置为0
         **/
        this.unreadTotalOfInfo = noticeUnreadMessageNumber < 0 ? 0 : noticeUnreadMessageNumber;
        item.countOfUnread = common.int.MESSAGE_CODE_ZERO;
        this.setListItemTransX(0);
        item.isDelShow = false;
    }

    handleMarkAsUnRead(context: Context,item: messageType) {
        let actionData: LooseObject = {};
        let threadId: number = item.threadId;
        actionData.sessionId = threadId;
        HiLog.w(TAG, 'handleMarkAsUnRead  threadId:' + threadId);
        ConversationService.getInstance().queryMmsInfoLastReadCondition(context, actionData, async (res: resType) => {
            if (res.code == common.int.FAILURE || res.abilityResult.length == 0) {
                HiLog.w(TAG, 'handleMarkAsUnRead: query sms_mms_info fail, return!');
                return;
            }
            HiLog.i(TAG, 'handleMarkAsUnRead get response');
            let item = res.abilityResult[res.abilityResult.length -1];
            let mmsActionData: Record<string, number> = {
                'msgId': item.msgId
            }
            let valueBucket: Record<string, number> = {
                'is_read': common.int.MESSAGE_UNREAD
            }
            ConversationService.getInstance().updateSmsMmsInfoByCondition(context, mmsActionData,
                valueBucket, (res: LooseObject) => {
                    if (res.code == common.int.SUCCESS) {
                        HiLog.i(TAG, 'handleMarkAsUnRead success');
                    } else {
                        HiLog.i(TAG, 'handleMarkAsUnRead failed, resultcode: ' + res.code);
                    }
                    this.countUnread(context);
                });
            let badgeContext: IBadgeContextInfo = {
                appContext: context,
                updateBadgeEventCode: TAG + '->handleMarkAsUnRead',
                tracedId: systemDateTime.getTime().toString(),
            }
            NotificationService.getInstance(context).updateBadgeNumberWithContext(badgeContext);
        });
        ConversationListService.getInstance().updateSessionRead(context, threadId);
        item.countOfUnread = common.int.MESSAGE_CODE_ONE;
        this.setListItemTransX(0);
        this.unreadTotalOfInfo = this.unreadTotalOfInfo + 1;
        item.isDelShow = false;
    }

    handUpdateMsgList(threadId: number, index: number) {
        // 触发会话列表刷新，更新会话头像上的未读数
        let tempMsgList: Array<messageType> = this.messageList;
        for (let msg of tempMsgList) {
            if (msg.threadId == threadId) {
                // 刷新会话头像上的未读数
                msg.countOfUnread = common.int.MESSAGE_CODE_ONE;
                HiLog.i(TAG, 'handUpdateMsgList  countOfUnread: ' + msg.countOfUnread);
                break;
            }
        }
        this.messageList = tempMsgList;
        HiLog.i(TAG, ' handUpdateMsgList this.messageList index: ' + index);
        this.conversationListDataSource.notifyDataChange(index);
        this.setListItemTransX(0);
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
            this.strMsgDeleteDialogTip = $r('app.string.msg_delete_dialog_tip1');
            longPressDeParams.STATE = 1;
        } else if (this.conversationSelectedNumber == this.messageList.length) {
            this.strMsgDeleteDialogTip = $r('app.string.msg_delete_dialog_tip3');
            longPressDeParams.STATE = 3;
        } else {
            HiLog.i(TAG, 'strMsgDeleteDialogTip msgDeleteDialogTip2');
            this.strMsgDeleteDialogTip = $r('app.plural.msg_delete_dialog_tip2', this.conversationSelectedNumber, this.conversationSelectedNumber);
            longPressDeParams.STATE = 2;
        }
        // 通知长按-删除打点
        longPressDeParams.PAGE_STATE = 2;
        DotUtil.getInstance().reportEvent(longPressDeParams, dotCommon.eventName.LONGPRESS_DELETE_MSG);
    }

    checkSelectedNumberIsEmpty() {
        return this.conversationSelectedNumber == common.int.MESSAGE_CODE_ZERO
    }

    deleteDialogConfirm(context: Context) {
        HiLog.w(TAG, '[deleteInfoSessions] unreadTotalOfInfo: ' + this.unreadTotalOfInfo +
            ', totalUnread: ' + this.conListCtrl.unreadTotal);
        this.setDelShow();
        let mmsList: Array<messageType> = [];
        let threadIds: Array<number> = [];
        let deletedSessionsUnreadTotal: number = 0;
        animateTo({ duration: 200 }, () => {
            for (let element of this.messageList) {
                if (element.isCbChecked) {
                    deletedSessionsUnreadTotal += element.countOfUnread;
                    threadIds.push(element.threadId);
                    this.totalMessageCount -= element.messageCount;
                    if (element.isDraft) {
                        this.totalMessageCount -= 1;
                    }
                } else {
                    mmsList.push(element);
                }
            }
            HiLog.w(TAG, '[deleteInfoSessions] deleted session count: ' + threadIds.length +
                ', deletedSessionsUnreadTotal: ' + deletedSessionsUnreadTotal);
            this.isMultipleSelectState = false;
            PanGestureUtil.refresh()
            this.showToolBar = true;
            this.checkedStatus().clear();
            this.conversationListDataSource.multiDeleteByThreadId(new Set(threadIds));
            this.messageList = this.conversationListDataSource.mmsList;
        })
        this.sendUpdateAccessibilityStr();
        this.total = mmsList.length;
        let actionData: LooseObject = {};
        if(threadIds.length == 0){
            HiLog.i(TAG, 'deleteDialogConfirm no thread');
            return;
        }
        actionData.threadIds = threadIds;
        actionData.hasRead = common.is_read.UN_READ;
        HiLog.i(TAG, 'deleteDialogConfirm  NotificationService.cancelMessageNotify');
        NotificationService.getInstance().cancelMessageNotify(context, actionData, () => {});
        actionData.hasRead = undefined;
        actionData.deleteMessage = common.deleteMessage.DELETECHECK;
        ConversationListService.getInstance().deleteSessionByUriPagination(actionData, () => {
            this.conListCtrl.statisticalData(context);
            if (this.total == 0) {
                //todo
                AppStorage.SetOrCreate('backHasInfoMsg', this.total == 0 ? true : false);
                let curBp: string = AppStorage.get('curBp') as string
                SharedPreferencesUtils.saveToPreferences("hasInfoMsgBool", false);
                if (curBp === common.STR.DEVICE_MOBILE_PHONE) {
                    this.pageInfos?.pop();
                } else {
                    this.pageInfos?.clear()
                    AppStorage.setOrCreate('indexNeedShow', !(AppStorage.get('indexNeedShow') as boolean))
                }
            }
        }, context);
    }
    sendUpdateAccessibilityStr() {
        let innerEvent: emitter.InnerEvent = {
            eventId: EmitterConstant.EVENT_CONVERSATION_LIST_ACCESSIBILITY_TEXT_CHANGE,
        };
        emitter.emit(innerEvent);
    }

    setDelShow() {
        if (this.itemTouchedIdx >= 0) {
            let item = this.messageList[this.itemTouchedIdx];
            this.setListItemTransX(0);
            item.isDelShow = false;
        }
    };

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
        this.sendSelectedEvent(null);
    }

    onBackPress() {
        // Key returned by the system. The value true indicates interception.
        HiLog.i(TAG, 'onBackPress');
        if (this.isMultipleSelectState) {
            HiLog.i(TAG, 'onBackPress isMultipleSelectState');
            for (let element of this.messageList) {
                element.isCbChecked = false;
            }
            this.isMultipleSelectState = false;
            PanGestureUtil.refresh()
            this.showToolBar = true;
            return true;
        }
        return false;
    }
    // Tap the avatar to go to the contact details page or recipient list page.
    clickToGroupDetail(index: number) {
        if (this.isJumping) {
            return;
        }
        this.isJumping = true;
        // Determine whether to redirect to the contact details page or to the list page of multiple recipients.
        let contactsNum = this.messageList[index]?.contactsNum;
        let telephone = this.messageList[index]?.telephone;
        if (contactsNum > common.int.MESSAGE_CODE_ONE) {
            let threadId = this.messageList[index]?.threadId;
            let contactsNum = this.messageList[index]?.contactsNum;
            this.jumpToGroupDetail(threadId, contactsNum);
        } else {
            let actionData: Record<string, string | number> = {
                'phoneNumber': telephone,
                'pageFlag': common.contactPage.PAGE_FLAG_CONTACT_DETAILS
            };
            this.jumpToContact(actionData);
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

    deleteAction(idx: number) {
        let element = this.messageList[idx];
        this.strMsgDeleteDialogTip = $r('app.string.msg_delete_dialog_tip1');
        element.isCbChecked = true;
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
    subscribeInfo(context: Context) {
        HiLog.i(TAG, 'subscribeInfo, start');
        let events = [common.STR.RECEIVE_TRANSMIT_EVENT]
        interface  commonEventSubscribeInfoType {
            events: string[],
            publisherPermission: string;
        }
        let commonEventSubscribeInfoData: commonEventSubscribeInfoType = {
            events: events,
            publisherPermission: 'ohos.permission.RECEIVE_SMS'
        };
        let commonEventSubscribeInfo = commonEventSubscribeInfoData;
        commonEvent.createSubscriber(commonEventSubscribeInfo, (args1,args2) => {this.createSubscriberCallBack(context, args1, args2)});
        let eventsUpdate = [common.STR.RECEIVE_UPDATE_EVENT];
        let commonUpdateEventSubscribeInfoData: commonEventSubscribeInfoType = {
            events: eventsUpdate,
            publisherPermission: 'ohos.permission.RECEIVE_SMS'
        };
        let commonUpdateEventSubscribeInfo = commonUpdateEventSubscribeInfoData;
        commonEvent.createSubscriber(commonUpdateEventSubscribeInfo, (args1, args2) => {
            this.createUpdateSubscriberCallBack(context, args1, args2)
        });
    }

    setListItemTransX(transX: number) {
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
    createSubscriberCallBack(context: Context, err: BusinessError, data: commonEvent.CommonEventSubscriber) {
        this.commonEventData = data;
        // Received subscription
        commonEvent.subscribe(this.commonEventData, (args1,args2) => {this.subscriberCallBack(context, args1, args2)});
    }

    createUpdateSubscriberCallBack(context: Context, err: BusinessError, data: commonEventManager.CommonEventSubscriber) {
        this.updateEventData = data;
        // Received subscription
        commonEvent.subscribe(this.updateEventData, (args1, args2) => {
            this.updateData(context, args1, args2);
        });
    }

    updateData(context: Context, err: BusinessError, data: commonEventManager.CommonEventData) {
        if (data == null || data.parameters == null) {
            HiLog.w(TAG, 'updateData, data or data.parameters is null, return');
            return;
        }

        this.messageList.forEach(element => {
            if (element.telephone == data.parameters?.telephone) {
                element.countOfUnread --;
            }
        });
        this.conversationListDataSource.refresh(this.messageList);
        this.messageList = this.conversationListDataSource.mmsList;
        HiLog.w(TAG, '[updateData]');
        this.conListCtrl.statisticalData(context);
    }

    subscriberCallBack(context: Context, err: BusinessError, data: commonEvent.CommonEventData) {
        this.queryTerminate[this.currentQueryTimeID] = true;
        this.clearOutOfDateVariables();
        HiLog.w(TAG,'get new message in infoMsg');
        this.unreadTotalOfInfo += 1;
        this.requestItem(context);
    }

    /**
     * 其他地方更新通信消息后刷新页面--1.自动删除通知消息 2.克隆完成
     *
     * @param context 上下文
     */
    public requestItemFromOther(context: Context) {
        if (!context) {
            HiLog.w(TAG, 'requestItemForAutoDelete failed, param is invalid');
            return;
        }
        this.queryTerminate[this.currentQueryTimeID] = true;
        this.clearOutOfDateVariables();
        this.requestItem(context);
    }

    // Unsubscribe
    unsubscribeInfo() {
        if (this.commonEventData != null) {
            commonEvent.unsubscribe(this.commonEventData, () => {
                HiLog.i(TAG, 'unsubscribeInfo, success');
            });
            commonEvent.unsubscribe(this.updateEventData, () => {
                HiLog.i(TAG, 'unSubscribe, success');
            });
            this.commonEventData = undefined;
        }
    }
    // Switching to the Contacts app
    jumpToContact(actionData: ActionData) {
        let str = commonService.commonContactParam(actionData);
            (GlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext).startAbility(str).then((data) => {
        }).catch((error: BusinessError) => {
            HiLog.e(TAG, 'jumpToContact, failed: ' + JSON.stringify(error.message));
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
    async queryInfoPageMessages(page: number, limit: number, infoTotal: number, totalOfInfoCount: number,
                                refreshIndex: number,
                                callback?: (infoTotal: number,
                                            refreshIndex: number, totalOfInfoCount: number, isEnd: boolean) => void) {
        let actionData: LooseObject = {};
        actionData.smsType = common.sms_type.NOTICE;
        actionData.page = page;
        actionData.limit = limit;
        actionData.orderByTimeDesc = true;
        try {
            let data = await ConversationListService.getInstance()
                .getSessionListResultNew(actionData, GlobalContext.getContext()
                    .getObject('mmsContext') as myCommon.UIAbilityContext);

            infoTotal = refreshIndex + data.response.length
            let isEnd = infoTotal >= this.totalMessage ||
                data.response.length < StringUtil.getLimitForSession(this.page);
            let count = 0;
            for (let i = 0; i < data.response.length; i++) {
                count += data.response[i].messageCount;
                if (data.response[i].isDraft) {
                    count += 1;
                }
            }
            HiLog.i(TAG, 'queryInfoPageMessages totalOfInfoCount ===== ' + count);
            totalOfInfoCount = count;
            refreshIndex = isEnd ? 0 : this.total;
            if (callback) {
                callback(infoTotal, refreshIndex, totalOfInfoCount, isEnd);
            }
        } catch (error) {
            HiLog.e(TAG, 'queryInfoPageMessages fail, error: ' + JSON.stringify(error));
        }
    }

    updateInfoMsg(threadId: number, time: number, index: number) {
        HiLog.i(TAG, 'updateInfoMsg threadId: ' + threadId + ', messageList: ' + this.messageList.length);
        let tempList = this.messageList.slice();
        for (let i = 0; i < tempList.length; i++) {
            if (tempList[i].threadId === threadId) {
                tempList[i].pinningTime = time;
                break;
            }
        }
        let pinTimeList = tempList.filter(item => item.pinningTime !== 0);
        let noPinTimeList = tempList.filter(item => item.pinningTime === 0);
        noPinTimeList.sort((a, b) => (b.timeMillisecond as number) - (a.timeMillisecond as number));
        let processedRecords = pinTimeList.map(items => {
            let maxTime = Math.max(items.timeMillisecond as number, items.pinningTime);
            return {item:items, timeKey: maxTime } as originalMsg;
        });
        processedRecords.sort((a, b) => b.timeKey - a.timeKey);
        let originalMsgList = processedRecords.map(item=> item.item);
        let endList: messageType[] = [];
        ThreadObjectUtils.deepCopyThreadArray(endList, [...originalMsgList, ...noPinTimeList]);
        this.conversationListDataSource.refresh(endList, 'updateInfoMsg');
        setTimeout(() => {
            let accessContent = 'infoMsg' + index;
            AccessibilityUtil.requestFocusForAccessibility(accessContent);
        }, 100);
    }
}
interface originalMsg {
    item: messageType,
    timeKey: number
}