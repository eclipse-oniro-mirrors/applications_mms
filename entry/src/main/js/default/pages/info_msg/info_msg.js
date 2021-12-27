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

// 信息列表Service
import messageService from '../../service/ConversationListService.js';
// 获取设置开关
import settingService from '../../service/SettingService.js';
import notificationService from '../../service/NotificationService.js';
// log工具类
import mmsLog from '../../../default/utils/MmsLog.js';
// 通知信息
import router from '@system.router';
import common from '../common_constants.js';
import commonEvent from '@ohos.commonevent';

export default {
    data: {
        total: 0,
        svgDelete: '',
        strCheckBoxSelectTip: '',
        strMsgDeleteDialogTip: '',
        // 已经选中的会话条数
        conversationSelectedNumber: 0,
        // 是否处于多选状态
        isMultipleSelectState: false,
        // 否会话列表处于全选状态
        isConversationCheckAll: false,
        // 信息列表页面搜索框输入的值
        inputValueOfSearch: '',
        // 是否锁定 默认false不锁定
        hasLockMsg: false,
        isSelectLockMsg: false,
        // 搜索结果列表
        searchResultList: {
            sessionList: [],
            contentList: []
        },
        // 搜索结果队列
        searchResultListQueue: [],
        // 搜索文本队列
        searchTextQueue: [],
        // 队列定时器启动标志位
        setTimeOutQueueFlag: false,
        // 是否真正进行跳转,避免重复跳转
        isJumping: false,
        // 是否显示搜索返回按钮 默认不显示
        isShowSearchBack: false,
        // 搜索的时候蒙层透明色展示
        isSearchCoverage: false,
        // 是否展示查询全部信息
        isSearchStatus: true,
        // 是否展示会话搜索
        isSearchConversation: false,
        // 是否展示间隔线
        isSearchInterval: false,
        // 是否展示单个信息搜索
        isSearchSms: false,
        // 搜索为空的时候展示短信
        isSearchNull: false,
        // 队列启动标志位
        queueFlag: false,
        // 显示搜索状态*/
        showSearchStatus: '',
        conversationName: '',
        // 未读的通知信息的条数
        unreadTotalOfInfo: 0,
        messageList: [],
        numberType: 1,
        // 是否显示联系人头像
        isShowContactHeadIcon: null,
        // 搜索结果的个数
        countOfSearchResult: 0,
        // 是否显示导航栏
        isNavigationBar: false,
        // 搜索状态，点击搜索框时进入搜索状态
        searchStatus: false,
        // 是否显示toolbar，搜索状态时不显示
        showToolBar: true,
        // 左滑的开始位置
        startX: 0,
        // 操作按钮的长度
        operateBtnW: 145,
        // 当前触摸的数据索引
        itemTouchedIdx: -1,
        // 列表分页，数量
        limit: 1000,
        // 列表分页，页数
        page: 0,
        // 信息总数
        totalMessage: 0
    },
    onInit() {
        this.svgDelete = this.$t('svg.delete');
        this.strCheckBoxSelectTip = this.$t('strings.msg_select_all');
        this.strMsgDeleteDialogTip = this.$t('strings.msg_delete_dialog_tip2', {
            number: this.conversationSelectedNumber
        });
    },
    onShow() {
        this.isJumping = false;
        this.getSettingFlagForConvListPage();
        this.page = 0;
        this.requestItem();
        this.subscribeInfo();
    },
    onHide() {
        this.unsubscribeInfo();
    },
    // 查询列表数据
    queryAllMessages() {
        let actionData = {
            page: this.page,
            limit: this.limit,
            featureAbility: this.$app.$def.featureAbility,
            ohosDataAbility: this.$app.$def.ohosDataAbility
        }
        actionData.numberType = this.numberType;
        let that = this;
        let rdbStore = this.$app.$def.rdbStore;
        messageService.querySessionList(rdbStore, actionData, result => {
            if (result.code == common.int.SUCCESS) {
                mmsLog.info(common.TAG.MsgInfo + 'queryAllMessages Success');
                let res = this.buildSessionList(result);
                that.messageList = res;
                that.totalMessage = result.total;
                that.total = that.messageList.length;
                if (that.totalMessage === that.total) {
                    that.countUnread();
                }
            } else {
                mmsLog.info(common.TAG.MsgInfo +'Error: queryAllMessages() failed !!!');
            }
        });
    },
    dealMmsListContent(element) {
        if (element.hasMms && element.hasAttachment) {
            if (element.content == common.string.EMPTY_STR) {
                element.content = this.$t('strings.attachment_no_subject');
            } else {
                element.content = this.$t('strings.attachment') + element.content;
            }
        }
        if (element.hasMms && !element.hasAttachment && element.content == common.string.EMPTY_STR) {
            element.content = this.$t('strings.no_subject');
        }
    },
    buildSessionList(result) {
        let res = [];
        let dateUtil = this.$app.$def.dateUtil;
        let that = this;
        result.response.forEach(item => {
            let obj = {};
            obj = item;
            obj.itemLeft = 0;
            obj.isDelShow = false;
            dateUtil.convertDateFormatForItem(item, true, that);
            this.dealMmsListContent(obj);
            res.push(obj);
        });
        return res;
    },
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
    },
    // 返回信息列表页面
    back() {
        router.back();
    },
    // 点击屏幕下方的更多
    clickMore() {
        this.$element('moreDialog').show();
    },
    // 删除通知信息中的单条信息
    clickToDelete() {

    },
    clickSearchBack() {
        // 点击搜索返回按钮后
        this.backSearch();
    },
    backSearch() {
        let that = this;
        that.isShowSearchBack = false;
        that.isSearchCoverage = false;
        that.$element('search').focus({
            focus: false
        });
        that.inputValueOfSearch = common.string.EMPTY_STR;
        that.isSearchStatus = true;
        that.isSearchNull = false;
        that.isNewSms = true;
        that.searchStatus = false;
        this.showToolBar = true;
    },
    // 搜索
    clickToSearch(e) {
        this.inputValueOfSearch = e.text;
        this.search(e.text);
    },
    // 在通知信息页面搜索
    search(text) {
        let actionData = {};
        actionData.inputValue = text
        this.searchTextAsync(actionData)
    },
    searchTextAsync(actionData) {
        actionData.rdbStore = this.$app.$def.rdbStore;
        actionData.ohosDataAbility = this.$app.$def.ohosDataAbility;
        actionData.featureAbility = this.$app.$def.featureAbility;
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
    },
    dealSearchResult(result) {
        this.searchResultList = {
            contentList: [],
            sessionList: []
        }
        this.isSearchStatus = false;
        this.showInfoDivWhenSearchFlag = false;
        this.isSearchCoverage = false;
        this.dealSearchResultTimeAndName(result);
        if (this.inputValueOfSearch === result.search) {
            this.searchResultList = result.resultMap;
        }
    },
    dealSearchResultTimeAndName(result) {
        let dateUtil = this.$app.$def.dateUtil;
        if (result.resultMap.sessionList) {
            result.resultMap.sessionList.forEach(session => {
                session.timeMillisecond = parseInt(session.timeMillisecond);
                dateUtil.convertDateFormatForItem(session, true, this);
            });
        }
        if (result.resultMap.contentList) {
            result.resultMap.contentList.forEach(content => {
                content.timeMillisecond = parseInt(content.timeMillisecond);
                dateUtil.convertDateFormatForItem(content, true, this);
                if(content.isFavorite) {
                    content.name = this.$t('strings.message_in_favorites');
                }
            });
        }
    },
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
    },
    // 判断是否是多选状态
    searchTouchStart(e) {
        if (this.isMultipleSelectState) {
            return false;
        }
        this.searchStatus = true;
        this.showToolBar = false;
        // 搜索区域touchStart监控x > 125 && x < 600) && (y < 70 && y > 20
        var x = e.touches[0].localX;

        if (e.currentTarget.type === 'search' && x > 80 && x < 560) {
            // 是否显示新建按钮
            this.isNewSms = false;
            this.isShowSearchBack = true;
            // 蒙层展示
            this.isSearchCoverage = true;
            // 拉起输入法
            setTimeout(() => {
                this.$element('search').focus({
                    focus: true
                });
            }, common.int.MESSAGE_CODE_THREE_ZERO_ZERO);
        }
        this.resetTouch();
        return false;
    },
    // 长按单个列表，展示全选和删除
    conversationLongPress(index) {
        // 是否有左滑删除按钮存在，存在则不可点击
        if (this.itemTouchedIdx >= 0 && this.messageList[this.itemTouchedIdx].isDelShow) {
            return;
        }
        // 长按单个列表，展示全选和删除
        this.showToolBar = false;
        mmsLog.info(common.TAG.MsgInfo + 'conversationLongPress==>index:' + index);
        if (this.isMultipleSelectState) {
            this.messageList[index].isCbChecked = !this.messageList[index].isCbChecked;
        } else {
            this.messageList[index].isCbChecked = true;
            this.isMultipleSelectState = true;
        }
        this.setConversationCheckAll(common.int.CHECKBOX_SELECT_UNKNOWN);
    },
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
            this.strCheckBoxSelectTip = this.$t('strings.msg_select_all');
        } else {
            // 全选状态
            this.strCheckBoxSelectTip = this.$t('strings.msg_deselect_all');
        }
    },
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
    },
    // 跳转至会话详情页面
    jumpToConversationPage(item) {
        mmsLog.info('jumpToConversationPage item: ' + item);
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
    },
    conversationCheckboxChange(index, e) {
        this.messageList[index].isCbChecked = e.checked;
        this.setConversationCheckAll(common.int.CHECKBOX_SELECT_UNKNOWN);
    },
    // 搜索会话头像点击
    searchConversationHeadClick(index) {
        this.headClickedListener(this.searchResultList.sessionList[index]);
    },
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
            var actionData = {};
            actionData.phoneNumber = telephone;
            actionData.pageFlag = common.contractPage.PAGE_FLAG_CONTACT_DETAILS;
            this.jumpToContract(actionData);
        } else {
            let threadId = item.threadId;
            let contactsNum = item.contactsNum;
            this.jumpToGroupDetail(threadId, contactsNum);
        }
    },
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
    },
    // 跳转到会话详情
    searchConversationClick(index) {
        this.searchMmsClicked(this.searchResultList.sessionList[index]);
    },
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
    },
    // 单条信息头像点击跳转 判断跳转到联系人详情还是跳转到多个收件人的列表页面
    searchSmsHeadClick(index) {
        this.headClickedListener(this.searchResultList.contentList[index]);
    },
    // 点击跳转到会话详情页面
    searchSmsClick(index) {
        this.searchMmsClicked(this.searchResultList.contentList[index]);
    },
    // 手指滑动蒙层退出搜索模式
    searchCoverageClick() {
        this.backSearch();
    },
    // 统计未读个数
    countUnread() {
        let actionData = {
            featureAbility: this.$app.$def.featureAbility,
            ohosDataAbility: this.$app.$def.ohosDataAbility,
        };
        let that = this;
        messageService.statisticalData(actionData, function (result) {
            if (result.code == common.int.SUCCESS) {
                mmsLog.info(common.TAG.MsgInfo + 'countUnread Success');
                // 通知信息的未读数
                that.unreadTotalOfInfo = result.response.unreadTotalOfInfo;
            } else {
                mmsLog.info(common.TAG.MsgInfo + 'Error: countUnread() failed !!!');
            }
        });
    },
    // 把通知信息中未读的都标记为已读
    clickToMarkAllAsReadForInfo() {
        let actionData = {
            hasRead: 1,
            smsType: 1,
            rdbStore: this.$app.$def.rdbStore,
            featureAbility: this.$app.$def.featureAbility,
            ohosDataAbility: this.$app.$def.ohosDataAbility
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
    },
    markAllAsReadByIndex(index) {
        let threadId = this.messageList[index].threadId;
        let threadIds = [threadId];
        this.cancelMessageInfoNotify(threadIds, () => {
            // 把联系人(参数类型为数组)的所有信息标记为已读
            this.markAllAsRead(threadIds, this.messageList);
            this.setListItemTransX(0);
        });
    },
    cancelMessageInfoNotify(threadIds, callback) {
        let actionData = {
            ohosDataAbility: this.$app.$def.ohosDataAbility,
            featureAbility: this.$app.$def.featureAbility,
            threadIds: threadIds,
            hasRead: 0
        };
        notificationService.cancelMessageNotify(actionData, res => {
            mmsLog.info(common.TAG.MsgInfo + 'cancelMessageInfoNotify success: ' + res);
            callback();
        });
    },
    markAllAsRead(threadIds, messageList) {
        // 把联系人(参数类型为数组)的所有信息标记为已读
        let valueBucket = {
            'unread_count': 0,
        };
        let actionData = {};
        actionData.threadIds = threadIds;
        actionData.rdbStore = this.$app.$def.rdbStore;
        actionData.valueBucket = valueBucket;
        actionData.featureAbility = this.$app.$def.featureAbility;
        actionData.ohosDataAbility = this.$app.$def.ohosDataAbility;
        actionData.hasRead = 1;
        // 将标记已读的数据更新为0
        messageService.markAllAsRead(actionData);
        for (let msg of messageList) {
            if(threadIds.indexOf(msg.threadId) > common.int.FAILURE) {
                // 控制列表的未读图标的显示
                msg.countOfUnread = common.int.MESSAGE_CODE_ZERO;
            }
        }
        this.unreadTotalOfInfo = this.unreadTotalOfInfo - threadIds.length;
    },
    selectInMoreMenu(e) {
        if (e.value == '1') {
            // 删除
            this.isMultipleSelectState = true;
            this.showToolBar = false;
            this.setConversationCheckAll(common.int.CHECKBOX_SELECT_UNKNOWN);
        } else {
            // 跳转至骚扰拦截页面，该页面在'手机管家'app里
        }
    },
    // 按钮删除
    clickConversationDelete() {
        if (this.conversationSelectedNumber == common.int.MESSAGE_CODE_ZERO) {
            return;
        }
        if (this.conversationSelectedNumber == common.int.MESSAGE_CODE_ONE) {
            this.strMsgDeleteDialogTip = this.$t('strings.msg_delete_dialog_tip1');
        } else if (this.conversationSelectedNumber == this.messageList.length) {
            this.strMsgDeleteDialogTip = this.$t('strings.msg_delete_dialog_tip3');
            this.$app.$def.globalData.hasInfoMsg = false;
        } else {
            this.strMsgDeleteDialogTip = this.$t('strings.msg_delete_dialog_tip2', {
                number: this.conversationSelectedNumber
            });
        }
        this.hasLockMsg = (this.messageList.some((element, index) => element.isCbChecked && element.isLock));
        this.$element('delete_dialog').show();
    },
    // 取消弹出
    deleteDialogCancel() {
        this.$element('delete_dialog').close();
        if (this.isSelectLockMsg) {
            this.isSelectLockMsg = false;
        }
    },
    setSelectLock() {
        this.isSelectLockMsg = !this.isSelectLockMsg;
    },
    // 删除锁定CheckBox勾选事件
    setSelectLockChange(e) {
        this.isSelectLockMsg = e.checked;
    },
    deleteDialogConfirm() {
        let mmsList = [];
        let threadIds = [];
        let lockSessionIds = [];
        let actionData = {
            rdbStore: this.$app.$def.rdbStore,
            featureAbility: this.$app.$def.featureAbility,
            ohosDataAbility: this.$app.$def.ohosDataAbility
        };
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
        this.$element('delete_dialog').close();
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
    },
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
    },
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
    },
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
    },
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
    },
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
            var actionData = {};
            actionData.phoneNumber = telephone;
            actionData.pageFlag = common.contractPage.PAGE_FLAG_CONTACT_DETAILS;
            this.jumpToContract(actionData);
        } else {
            let threadId = this.messageList[index].threadId;
            let contactsNum = this.messageList[index].contactsNum;
            this.jumpToGroupDetail(threadId, contactsNum);
        }
    },
    exitConversationSelect() {
        this.onBackPress();
    },
    touchStart(event) {
        if (this.isMultipleSelectState) {
            return;
        }
        // 查看当前触控的item是否是跟上一个触控的是同一个，若不是，将上一个复位
        let touchIdx = this.getTouchIndex(event.currentTarget);
        if (this.itemTouchedIdx !== -1 && touchIdx !== this.itemTouchedIdx) {
            let itemTouched = this.messageList[this.itemTouchedIdx];
            this.setListItemTransX(0);
            setTimeout(function () {
                itemTouched.isDelShow = false;
            }, 200);
        }
        this.startX = event.touches[0].globalX;
    },
    getTouchIndex(ele) {
        let index = -1;
        if (ele.classList[0] === 'messaging-body-item') {
            if (index === -1) {
                index = ele.classList[1].substring(5);
            }
        }
        return parseInt(index);
    },
    resetTouch() {
        if (this.itemTouchedIdx !== -1) {
            let item = this.messageList[this.itemTouchedIdx];
            if (item.isDelShow) {
                item.isDelShow = false;
                this.setListItemTransX(0);
                return true;
            }
        }
        return false;
    },
    touchMove(event) {
        if (this.isMultipleSelectState) {
            return;
        }
        let disX = this.startX - event.touches[0].globalX;
        if (Math.abs(disX) <= 2) {
            return;
        }
        let ele = event.currentTarget;
        this.itemTouchedIdx = this.getTouchIndex(ele);
        let item = this.messageList[this.itemTouchedIdx];
        if (item.countOfUnread > 0) {
            this.operateBtnW = common.int.OPERATE_UNREAD_WIDTH;
        } else {
            this.operateBtnW = common.int.OPERATE_DELETE_WIDTH;
        }
        if (disX > 0) {
            if (item.isDelShow) {
                return;
            }
            let transX = disX;
            if (disX >= this.operateBtnW) {
                // 左滑到最大宽度
                transX = this.operateBtnW;
                item.isDelShow = true;
            }
            this.setListItemTransX(transX);
        } else if (disX < 0) {
            if (!item.isDelShow) {
                return;
            }
            if (disX > -this.operateBtnW) {
                this.setListItemTransX(disX);
            } else {
                item.isDelShow = false;
                this.setListItemTransX(0);
            }
        }
    },
    deleteAction(idx) {
        let element = this.messageList[idx];
        this.strMsgDeleteDialogTip = this.$t('strings.msg_delete_dialog_tip1');
        element.isCbChecked = true;
        this.hasLockMsg = (this.messageList.some((element, index) => element.isCbChecked && element.isLock));
        this.$element('delete_dialog').show();
    },
    touchEnd(event) {
        if (this.isMultipleSelectState) {
            return;
        }
        let disX = this.startX - event.changedTouches[0].globalX;
        if (Math.abs(disX) <= 2) {
            return;
        }
        let item = this.messageList[this.itemTouchedIdx];
        if (disX < (this.operateBtnW / 2)) {
            // 小于一半 回原位置
            this.setListItemTransX(0);
            item.isDelShow = false;
        } else {
            // 大于一半 滑动到最大值
            this.setListItemTransX(this.operateBtnW);
            item.isDelShow = true;
        }
    },
    // 订阅接收到的新消息
    subscribeInfo(){
        mmsLog.info(common.TAG.MsgInfo + 'subscribe......');
        let events = [common.string.RECEIVE_TRANSMIT_EVENT]
        let commonEventSubscribeInfo = {
            events : events
        };
        commonEvent.createSubscriber(commonEventSubscribeInfo, this.createSubscriberCallBack.bind(this));
    },
    setListItemTransX(disX) {
        let item = this.messageList[this.itemTouchedIdx];
        if (item) {
            if (disX >= 0) {
                item.itemLeft = -disX;
            } else {
                item.itemLeft = -this.operateBtnW - disX;
            }
        }
    },
    createSubscriberCallBack(err, data){
        this.commonEventData = data;
        // 接收到订阅
        commonEvent.subscribe(this.commonEventData, this.subscriberCallBack.bind(this));
    },
    subscriberCallBack(err, data){
        let that = this;
        mmsLog.info(common.TAG.MsgInfo + 'eventData is: ' + data);
        this.page = 1;
        that.queryAllMessages();
    },
    // 取消订阅
    unsubscribeInfo(){
        commonEvent.unsubscribe(this.commonEventData, () => {
            mmsLog.info('info_msg unsubscribe');
        });
    },
    // 跳转联系人app
    jumpToContract(actionData){
        let commonService = this.$app.$def.commonService;
        var str = commonService.commonContractParam(actionData);
        let featureAbility = this.$app.$def.featureAbility;
        featureAbility.startAbility(str).then((data) => {
            mmsLog.info(common.TAG.MsgInfo + 'jumpToContract,data: ' + data);
        }).catch((error) => {
            mmsLog.error(common.TAG.MsgInfo + 'jumpToContract,failed: ' + JSON.stringify(error));
        })
    },
    // 获取整合通知信息和显示联系人头像的开关值
    getSettingFlagForConvListPage() {
        let preferences = this.$app.$def.preferences;
        let result = settingService.getSettingFlagForConvListPage(preferences);
        if (result) {
            this.isShowContactHeadIcon = result.isShowContactHeadIcon;
        }
    },
};
