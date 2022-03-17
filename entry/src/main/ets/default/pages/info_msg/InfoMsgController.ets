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
import appStorage from '../../utils/AppStorageUtil';
import common from '../../data/commonData';
import commonEvent from '@ohos.commonEvent';
import commonService from '../../service/CommonService';
import dateUtil from '../../utils/DateUtil';
import featureAbility from '@ohos.ability.featureAbility';
import LooseObject from '../../data/LooseObject'
// 信息列表Service
import messageService from '../../service/ConversationListService';
// log工具类
import HiLog from '../../utils/HiLog';
import notificationService from '../../service/NotificationService';
// 通知信息
import router from '@system.router';
// 获取设置开关
import settingService from '../../service/SettingService';
const TAG = 'InfoMsgController'

let sInfoMsgCtrl;

let commonEventData = null;

export default class InfoMsgController {
    svgDelete: string = 'icon/ic_delete_m.svg'
    total: number = 0;
    strCheckBoxSelectTip: Resource;
    strMsgDeleteDialogTip: Resource;
    // 已经选中的会话条数
    conversationSelectedNumber: number = 0;
    // 是否处于多选状态
    isMultipleSelectState: boolean = false;
    isSearchFocusable: boolean = false;
    // 否会话列表处于全选状态
    isConversationCheckAll: boolean = false;
    // 信息列表页面搜索框输入的值
    inputValueOfSearch: string = '';
    // 是否锁定 默认false不锁定
    hasLockMsg: boolean = false;
    isSelectLockMsg: boolean = false;
    // 搜索结果列表
    searchResultList: LooseObject = {
        sessionList: [],
        contentList: []
    };
    // 搜索结果队列
    searchResultListQueue: Array<any> = [];
    // 搜索文本队列
    searchTextQueue: Array<any> = [];
    // 队列定时器启动标志位
    setTimeOutQueueFlag: boolean = false;
    // 是否真正进行跳转,避免重复跳转
    isJumping: boolean = false;
    // 是否显示搜索返回按钮 默认不显示
    isShowSearchBack: boolean = false;
    // 搜索的时候蒙层透明色展示
    isSearchCoverage: boolean = false;
    // 是否展示查询全部信息
    isSearchStatus: boolean = true;
    // 是否展示会话搜索
    isSearchConversation: boolean = false;
    // 是否展示间隔线
    isSearchInterval: boolean = false;
    // 是否展示单个信息搜索
    isSearchSms: boolean = false;
    // 搜索为空的时候展示短信
    isSearchNull: boolean = false;
    // 队列启动标志位
    queueFlag: boolean = false;
    // 显示搜索状态*/
    showSearchStatus: string = '';
    conversationName: string = '';
    // 未读的通知信息的条数
    unreadTotalOfInfo: number = 0;
    messageList: Array<any> = [];
    numberType: number = 1;
    // 是否显示联系人头像
    isShowContactHeadIcon: boolean = true;
    // 搜索结果的个数
    countOfSearchResult: number = 0;
    // 是否显示导航栏
    isNavigationBar: boolean = false;
    // 搜索状态，点击搜索框时进入搜索状态
    searchStatus: boolean = false;
    // 是否显示toolbar，搜索状态时不显示
    showToolBar: boolean = true;
    // 变化刷新UI
    flushTranslate: boolean = true;
    // 操作按钮的长度
    operateBtnW: number = 145;
    // 当前触摸的数据索引
    itemTouchedIdx: number = -1;
    // 列表分页，数量
    limit: number = 1000;
    // 列表分页，页数
    page: number = 0;
    // 信息总数
    totalMessage: number = 0;
    static getInstance() {
        if (sInfoMsgCtrl == null) {
            sInfoMsgCtrl = new InfoMsgController();
            appStorage.setAndLink('InfoMsgController', sInfoMsgCtrl);
        }
        return sInfoMsgCtrl;
    }
    onInit() {
        this.strCheckBoxSelectTip = $r("app.string.msg_select_all");
        this.strMsgDeleteDialogTip = $r("app.string.msg_delete_dialog_tip2", this.conversationSelectedNumber);
    }
    onShow() {
        this.isJumping = false;
        this.getSettingFlagForConvListPage();
        this.page = 0;
        this.requestItem();
        this.subscribeInfo();
    }
    onHide() {
        this.unsubscribeInfo();
    }
    // 查询列表数据
    queryAllMessages() {
        let actionData: LooseObject = {
            page: this.page,
            limit: this.limit,
        }
        actionData.numberType = this.numberType;
        messageService.querySessionList(actionData, result => {
            if (result.code == common.int.SUCCESS) {
                HiLog.i(TAG, 'queryAllMessages, Success');
                let res = this.buildSessionList(result);
                this.messageList = res;
                this.totalMessage = result.total;
                this.total = this.messageList.length;
                if (this.totalMessage === this.total) {
                    this.countUnread();
                }
            } else {
                HiLog.w(TAG,'queryAllMessages, failed');
            }
        });
    }
    dealMmsListContent(element) {
        if (element.hasMms && element.hasAttachment) {
            if (element.content == common.string.EMPTY_STR) {
                element.content = $r('app.string.attachment_no_subject');
            } else {
                element.content = $r('app.string.attachment', element.content);
            }
        }
        if (element.hasMms && !element.hasAttachment && element.content == common.string.EMPTY_STR) {
            element.content = $r('app.string.no_subject');
        }
    }
    buildSessionList(result) {
        let res = [];
        result.response.forEach(item => {
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
            // 对messageList的限制，是防止初始化时多次刷新请求
            this.page++;
            this.queryAllMessages();
        }
    }
    // 返回信息列表页面
    back() {
        router.back();
    }
    // 点击屏幕下方的更多
    clickMore() {
//        this.$element('moreDialog').show();
    }
    // 删除通知信息中的单条信息
    clickToDelete() {

    }
    clickSearchBack() {
        // 点击搜索返回按钮后
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
    // 搜索
    clickToSearch(text) {
        this.inputValueOfSearch = text;
        this.search(text);
    }
    // 在通知信息页面搜索
    search(text) {
        let actionData: LooseObject = {};
        actionData.inputValue = text
        this.searchTextAsync(actionData)
    }
    searchTextAsync(actionData) {
        actionData.numberType = this.numberType;
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
                if(content.isFavorite) {
                    content.name = $r('app.string.message_in_favorites');
                }
            });
        }
    }
    searchResultListEmpty() {
        this.searchResultList = {
            contentList: [],
            sessionList: []
        }
        // 显示信息列表
        this.isSearchStatus = true;
        if (this.isShowSearchBack) {
            this.isSearchCoverage = true;
        } else {
            this.isSearchCoverage = false;
        }
    }
    // 判断是否是多选状态
    searchTouchStart() {
        if (this.isMultipleSelectState) {
            return false;
        }
        this.searchStatus = true;
        this.showToolBar = false;
        // 搜索区域touchStart监控x > 125 && x < 600) && (y < 70 && y > 20
//        var x = event.touches[0].x;
//        if (isSearchType && x > 80 && x < 560) {
            // 是否显示新建按钮
            this.isShowSearchBack = true;
            // 蒙层展示
            this.isSearchCoverage = true;
            // 拉起输入法
            setTimeout(() => {
                this.isSearchFocusable = true;
            }, common.int.MESSAGE_CODE_THREE_ZERO_ZERO);
//        }
        this.resetTouch();
        return false;
    }
    // 长按单个列表，展示全选和删除
    conversationLongPress(index) {
        // 是否有左滑删除按钮存在，存在则不可点击
        if (this.itemTouchedIdx >= 0 && this.messageList[this.itemTouchedIdx].isDelShow) {
            return;
        }
        // 长按单个列表，展示全选和删除
        this.showToolBar = false;
        HiLog.i(TAG, 'conversationLongPress, index: ' + index);
        if (this.isMultipleSelectState) {
            this.messageList[index].isCbChecked = !this.messageList[index].isCbChecked;
        } else {
            this.messageList[index].isCbChecked = true;
            this.isMultipleSelectState = true;
        }
        this.setConversationCheckAll(common.int.CHECKBOX_SELECT_UNKNOWN);
    }
    // 检查是否全选
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
            // 默认为 CHECKBOX_SELECT_UNKNOWN,判断是否有未选中
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
            // 非全选状态
            this.strCheckBoxSelectTip = $r('app.string.msg_select_all');
        } else {
            // 全选状态
            this.strCheckBoxSelectTip = $r('app.string.msg_deselect_all');
        }
    }
    // 跳转至短信详情页面
    clickInfoToConversation(index) {
        if (this.resetTouch()) {
            return;
        }
        // 如果处于多选状态,响应CheckBox
        if (this.isMultipleSelectState) {
            this.messageList[index].isCbChecked = !this.messageList[index].isCbChecked;
            this.setConversationCheckAll(common.int.CHECKBOX_SELECT_UNKNOWN);
            return;
        }
        if (this.isJumping) {
            return;
        }
        this.isJumping = true;
        // 如果该联系人下有未读的信息，还需要向后端PA发送消息，使该联系人的所有信息标记为已读
        if (this.messageList[index].countOfUnread > common.int.MESSAGE_CODE_ZERO) {
            this.markAllAsReadByIndex(index);
        }
        this.jumpToConversationPage(this.messageList[index]);
    }
    // 跳转至会话详情页面
    jumpToConversationPage(item){
        HiLog.i(TAG, 'jumpToConversationPage, item: ' + JSON.stringify(item));
        router.push({
            uri: 'pages/conversation/conversation',
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
    // 搜索会话头像点击
    searchConversationHeadClick(index) {
        this.headClickedListener(this.searchResultList.sessionList[index]);
    }
    headClickedListener(item) {
        // 点击头像跳转至联系人详情页面或收件人列表页面
        if (this.isJumping) {
            return;
        }
        if(item.isFavorite != null && item.isFavorite) {
            return;
        }
        var telephone = item.telephone;
        var contactsNum = item.contactsNum;
        this.isJumping = true;
        if(contactsNum == common.int.MESSAGE_CODE_ONE) {
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
    // 跳转多人头像列表页面
    jumpToGroupDetail(threadId, contactsNum) {
        let actionData = {
            uri: 'pages/group_detail/group_detail',
            params: {
                threadId: threadId,
                contactsNum: contactsNum
            }
        };
        router.push(actionData);
    }
    // 跳转到会话详情
    searchConversationClick(index) {
        this.searchMmsClicked(this.searchResultList.sessionList[index]);
    }
    // 跳转到短信详情
    searchMmsClicked(item) {
        if(item.isFavorite) {
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
    // 单条信息头像点击跳转 判断跳转到联系人详情还是跳转到多个收件人的列表页面
    searchSmsHeadClick(index) {
        this.headClickedListener(this.searchResultList.contentList[index]);
    }
    // 点击跳转到会话详情页面
    searchSmsClick(index) {
        this.searchMmsClicked(this.searchResultList.contentList[index]);
    }
    // 手指滑动蒙层退出搜索模式
    searchCoverageClick() {
        this.backSearch();
    }
    // 统计未读个数
    countUnread() {
        let actionData: LooseObject = {
        };
        messageService.statisticalData(actionData, function (result) {
            if (result.code == common.int.SUCCESS) {
                HiLog.i(TAG, 'countUnread, statisticalData Success');
                // 通知信息的未读数
                this.unreadTotalOfInfo = result.response.unreadTotalOfInfo;
            } else {
                HiLog.w(TAG, 'countUnread, statisticalData failed');
            }
        });
    }
    // 把通知信息中未读的都标记为已读
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
            // 把联系人(参数类型为数组)的所有信息标记为已读
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
        notificationService.cancelMessageNotify(actionData, res => {
            HiLog.i(TAG, 'cancelMessageInfoNotify, success res: ' + res);
            callback();
        });
    }
    markAllAsRead(threadIds) {
        let tempMsgList = this.messageList;
        // 把联系人(参数类型为数组)的所有信息标记为已读
        let valueBucket = {
            'unread_count': 0,
        };
        let actionData: LooseObject = {};
        actionData.threadIds = threadIds;
        actionData.valueBucket = valueBucket;
        actionData.hasRead = 1;
        // 将标记已读的数据更新为0
        messageService.markAllAsRead(actionData);
        for (let msg of tempMsgList) {
            if(threadIds.indexOf(msg.threadId) > common.int.FAILURE) {
                // 控制列表的未读图标的显示
                msg.countOfUnread = common.int.MESSAGE_CODE_ZERO;
            }
        }
        this.messageList = tempMsgList;
        this.unreadTotalOfInfo = this.unreadTotalOfInfo - threadIds.length;
    }
    selectInMoreMenu(menuId: number) {
        if (menuId == 1) {
            // 删除
            this.isMultipleSelectState = true;
            this.showToolBar = false;
            this.setConversationCheckAll(common.int.CHECKBOX_SELECT_UNKNOWN);
        } else {
            // 跳转至骚扰拦截页面，该页面在'手机管家'app里
        }
    }
    // 按钮删除
    clickConversationDelete() {
        if (this.conversationSelectedNumber == common.int.MESSAGE_CODE_ZERO) {
            return;
        }
        if (this.conversationSelectedNumber == common.int.MESSAGE_CODE_ONE) {
            this.strMsgDeleteDialogTip = $r("app.string.msg_delete_dialog_tip1");
        } else if (this.conversationSelectedNumber == this.messageList.length) {
            this.strMsgDeleteDialogTip = $r("app.string.msg_delete_dialog_tip3");
            appStorage.setHasInfoMsg(false);
        } else {
            this.strMsgDeleteDialogTip = $r("app.string.msg_delete_dialog_tip2", this.conversationSelectedNumber);
        }
        this.hasLockMsg = (this.messageList.some((element, index) => element.isCbChecked && element.isLock));
    }
    // 取消弹出
    deleteDialogCancel() {
        if (this.isSelectLockMsg) {
            this.isSelectLockMsg = false;
        }
    }
    setSelectLock() {
        this.isSelectLockMsg = !this.isSelectLockMsg;
    }
    // 删除锁定CheckBox勾选事件
    setSelectLockChange(event) {
        this.isSelectLockMsg = event.checked;
    }
    deleteDialogConfirm() {
        let mmsList = [];
        let threadIds = [];
        let lockSessionIds = [];
        let actionData: LooseObject = {};
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
        this.total = mmsList.length;
        if (this.total == 0) {
            router.back();
        }
        this.deleteNotifyMessageInfo(threadIds, lockSessionIds, actionData, () => {
             this.deleteMessageInfoByThreadIds(threadIds, lockSessionIds, actionData);
        });
        if (this.itemTouchedIdx >= 0) {
            let item = this.messageList[this.itemTouchedIdx];
            this.setListItemTransX(0);
            item.isDelShow = false;
        }
    }
    deleteNotifyMessageInfo(threadIds, lockSessionIds, actionData, callback) {
        let sessionIds = [];
        if (lockSessionIds.length > 0) {
            sessionIds.push(lockSessionIds);
        }
        if (threadIds.length > 0) {
            sessionIds.push(threadIds);
        }
        actionData.hasRead = 0;
        actionData.threadIds = sessionIds;
        this.cancelMessageInfoNotify(actionData, callback);
    }
    deleteMessageInfoByThreadIds(threadIds, lockSessionIds, actionData) {
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
    // 全选/取消全选
    clickConversationCheckAll() {
        if (this.isConversationCheckAll) {
            // 全选-->取消全选
            for (let item of this.messageList) {
                item.isCbChecked = false;
            }
            this.setConversationCheckAll(common.int.CHECKBOX_SELECT_NONE);
        } else {
            // 非全选-->全选
            for (let item of this.messageList) {
                item.isCbChecked = true;
            }
            this.setConversationCheckAll(common.int.CHECKBOX_SELECT_ALL);
        }
    }
    onBackPress() {
        // 系统返回键,true代表拦截
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
    // 点击头像跳转至联系人详情页面或收件人列表页面
    clickToGroupDetail(index) {
        if (this.isJumping) {
            return;
        }
        this.isJumping = true;
        // 判断跳转到联系人详情还是跳转到多个收件人的列表页面
        var contactsNum = this.messageList[index].contactsNum;
        var telephone = this.messageList[index].telephone;
        if (contactsNum == common.int.MESSAGE_CODE_ONE) {
            var actionData = {
                phoneNumber: telephone,
                pageFlag: common.contractPage.PAGE_FLAG_CONTACT_DETAILS
            };
            this.jumpToContract(actionData);
        } else {
            let threadId = this.messageList[index].threadId;
            let contactsNum = this.messageList[index].contactsNum;
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
        // 查看当前触控的item是否是跟上一个触控的是同一个，若不是，将上一个复位
        if (this.itemTouchedIdx !== -1 && index !== this.itemTouchedIdx) {
            let itemTouched = this.messageList[this.itemTouchedIdx];
            this.setListItemTransX(0);
            itemTouched.isDelShow = false;
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
            if (item.isDelShow) {
                this.setListItemTransX(0);
                item.isDelShow = false;
                return true;
            }
        }
        return false;
    }
    touchMove(event: GestureEvent, index: number) {
        if (this.isMultipleSelectState) {
            return;
        }
        // offsetX是偏移量，值区间在[-operateBtnW, 0]
        let offsetX = event.offsetX;
        // 位移小于2，视为没有滑动
        if (Math.abs(offsetX) <= 2) {
            return;
        }
        let item = this.messageList[this.itemTouchedIdx];
        let transX = offsetX;
        if (item.isDelShow) {
            if (event.offsetX - this.operateBtnW <= 0) {
                transX = event.offsetX - this.operateBtnW
            } else {
                // 右滑到关闭
                transX = 0
            }
        } else {
            if (event.offsetX + this.operateBtnW >= 0) {
                transX = event.offsetX
            } else {
                // 左滑到最大宽度
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
        // offsetX是偏移量，值区间在[-operateBtnW, 0]
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
    // 订阅接收到的新消息
    subscribeInfo(){
        HiLog.i(TAG, 'subscribeInfo, start');
        let events = [common.string.RECEIVE_TRANSMIT_EVENT]
        let commonEventSubscribeInfo = {
            events : events
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
        // 用来刷新界面
        this.flushTranslate = !this.flushTranslate;
    }
    createSubscriberCallBack(err, data){
        commonEventData = data;
        // 接收到订阅
        commonEvent.subscribe(commonEventData, this.subscriberCallBack.bind(this));
    }
    subscriberCallBack(err, data){
        HiLog.i(TAG, 'subscriberCallBack data: ' + JSON.stringify(data));
        this.page = 1;
        this.queryAllMessages();
    }
    // 取消订阅
    unsubscribeInfo(){
        commonEvent.unsubscribe(commonEventData, () => {
            HiLog.i(TAG, 'unsubscribeInfo, success');
        });
    }
    // 跳转联系人app
    jumpToContract(actionData){
        var str = commonService.commonContractParam(actionData);
        featureAbility.startAbility(str).then((data) => {
            HiLog.i(TAG, 'jumpToContract, data: ' + JSON.stringify(data));
        }).catch((error) => {
            HiLog.e(TAG, 'jumpToContract, failed: ' + JSON.stringify(error));
        })
    }
    // 获取整合通知信息和显示联系人头像的开关值
    getSettingFlagForConvListPage() {
        let result = settingService.getSettingFlagForConvListPage();
        if(result) {
            this.isShowContactHeadIcon = result.isShowContactHeadIcon;
        }
    }
}
