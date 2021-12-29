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
// log 工具类
import mmsLog from '../../../default/utils/MmsLog.js';
import router from '@system.router';
import commonEvent from '@ohos.commonevent';
import common from '../common_constants.js';

export default {
    data: {
        svgDelete: '',
        strCheckBoxSelectTip: '',
        strMsgDeleteDialogTip: '',
        // 所有短信的总条数
        total: 0,
        // 通知信息的总条数
        totalOfInfo: 0,
        // 未读信息的总条数
        unreadTotal: 0,
        // 未读的通知信息总条数
        unreadTotalOfInfo: 0,
        // 已经选中的会话条数
        conversationSelectedNumber: 0,
        // 是否处于多选状态*/
        isMultipleSelectState: false,
        // 是否会话列表处于全选状态
        isConversationCheckAll: false,
        // 信息列表页面搜索框输入的值
        inputValueOfSearch: '',
        inputValueOfSearchTemp: '',
        // 通知信息所在行隐藏的'标记为已读'，当存在未读信息时，向左滑动屏幕才能看见该图标
        markAllAsReadForInfo: false,
        // 标记为已读
        showMarkAllAsRead: false,
        // 删除，在每条单独的消息那一行，向左滑动屏幕可见
        showDelete: false,
        // 是否锁定 默认false不锁定
        hasLockMsg: false,
        isSelectLockMsg: false,
        // 动态设置删除弹窗高度
        dialogHeight: '',
        // 通知信息内的数据
        messageListForInfo: [],
        // 如果通知信息整合开关打开，则是非通知信息，如果没有打开，则是所有数据
        messageList: [],
        // 搜索结果列表
        searchResultList: {
            sessionList: [],
            contentList: []
        },
        // 搜索结果队列
        searchResultListQueue: [],
        // 搜索文本队列
        searchTextQueue: [],
        // 队列启动标志位
        queueFlag: false,
        // 队列定时器启动标志位
        setTimeOutQueueFlag: false,
        // 搜索结果的个数
        countOfSearchResult: 0,
        // 是否真正进行跳转,避免重复跳转
        isJumping: false,
        // 通知信息整合开关'是否打开，该开关在设置里
        hasAggregate: false,
        // 显示联系人头像
        isShowContactHeadIcon: false,
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
        // 显示搜索状态
        showSearchStatus: '',
        // 是否显示新建短信按钮
        isNewSms: true,
        conversationName: '',
        // 搜索时显示搜索框所在div
        showInfoDivWhenSearchFlag: true,
        // 左滑的开始位置
        startX: 0,
        // 操作按钮的长度
        operateBtnW: 145,
        // 当前触摸的数据索引
        itemTouchedIdx: -1,
        // 通知信息的左边距
        infoLeft: 0,
        // 列表分页，页数
        page: 0,
        // 列表分页，数量
        limit: 100,
        // 公共订阅数据
        commonEventData: {}
    },
    onInit() {
        this.svgDelete = this.$t('svg.delete');
        this.strCheckBoxSelectTip = this.$t('strings.msg_select_all');
        this.strMsgDeleteDialogTip = this.$t('strings.msg_delete_dialog_tip2', {
            number: this.conversationSelectedNumber
        });
        this.showSearchStatus = this.$t('strings.noMessages');
    },
    onShow() {
        this.isJumping = false;
        this.subscribe()
        this.getSettingFlagForConvListPage();
        this.statisticalData();
        this.page = 0;
        this.messageList = [];
        this.requestItem();
        this.hasInfoMsg = this.$app.$def.globalData.hasInfoMsg;
        if (!this.hasInfoMsg && this.messageList.length == 0) {
            this.total = 0;
        }
    },
    onDestroy() {
        mmsLog.info(common.TAG.MsgList + 'onDestroy()......');
        this.unSubscribe();
    },
    onBackPress() {
        // 系统返回键,true代表拦截
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
    },
    // 分页获取列表数据
    requestItem() {
        let count = this.page * this.limit;
        if (this.page === 0) {
            this.page++;
            this.queryAllMessages();
        } else if (count < this.total && this.messageList.length > (this.page - 1) * this.limit) {
            // 对messageList的限制，是防止初始化时多次刷新请求
            this.page++;
            this.queryAllMessages();
        }
    },
    // 获取整合通知信息和显示联系人头像的开关值
    getSettingFlagForConvListPage() {
        let prefer = this.$app.$def.preferences;
        let result = settingService.getSettingFlagForConvListPage(prefer);
        if (result) {
            this.hasAggregate = result.hasAggregate;
            this.isShowContactHeadIcon = result.isShowContactHeadIcon;
        }
    },
    subscribe() {
        let events = [common.string.RECEIVE_TRANSMIT_EVENT]
        let commonEventSubscribeInfo = {
            events: events
        };
        commonEvent.createSubscriber(commonEventSubscribeInfo, this.createSubscriberCallBack.bind(this));
    },
    subscriberCallBack(err, data) {
        this.page = 1;
        this.queryAllMessages();
        // 统计未读的信息
        this.statisticalData();
    },
    // 取消订阅
    unSubscribe() {
        commonEvent.unsubscribe(this.commonEventData, () => {
            mmsLog.info('info_msg unsubscribe');
        });
    },
    createSubscriberCallBack(err, data) {
        this.commonEventData = data;
        // 接收到订阅
        commonEvent.subscribe(this.commonEventData, this.subscriberCallBack.bind(this));
    },
    // 统计数据
    statisticalData() {
        let actionData = {
            featureAbility: this.$app.$def.featureAbility,
            ohosDataAbility: this.$app.$def.ohosDataAbility,
        };
        let that = this;
        messageService.statisticalData(actionData, function (result) {
            if (result.code == common.int.SUCCESS) {
                mmsLog.info(common.TAG.MsgList + 'statisticalData Success');
                // 列表的总数
                that.unreadTotal = result.response.totalListCount;
                // 通知信息的未读数
                that.unreadTotalOfInfo = result.response.unreadTotalOfInfo;
            } else {
                mmsLog.info(common.TAG.MsgList + 'Error: statisticalData() failed !!!');
            }
        });
    },
    // 点击打开屏幕右上角的按钮，里面有设置
    clickToSettings() {
        this.$element('settingsMenu').show({
            x: common.int.MESSAGE_CODE_THREE_FOUR_ZERO,
            y: common.int.MESSAGE_CODE_TWENTY_FIVE
        });
    },
    // 打开屏幕右上角的按钮后，进行相应的操作
    onMenuSelected(e) {
        switch (e.value) {
            case '1':
                this.isMultipleSelectState = true;
                this.setConversationCheckAll(common.int.CHECKBOX_SELECT_UNKNOWN);
                break;
            case '2':
            // 跳转到收藏页面
                this.jumpToFavoritesPage();
                break;
            case '4':
            // 将所有未读的信息标记为已读
                this.clickToMarkAllAsRead();
                break;
            case '5':
            // 跳转至'设置'页面
                this.jumpToSettingsPage();
                break;
            default:
                mmsLog.info('onMenuSelected, code is exit');
        }
    },
    setConversationCheckAll(type) {
        // 检查是否全选
        if (!this.isMultipleSelectState) {
            return;
        }
        if (type == common.int.CHECKBOX_SELECT_ALL) {
            this.conversationSelectedNumber = this.messageList.length;
            this.isConversationCheckAll = true;
        } else if (type == common.int.CHECKBOX_SELECT_NONE) {
            this.conversationSelectedNumber = common.int.MESSAGE_CODE_ZERO;
            this.isConversationCheckAll = false;
        } else {
            // 默认为 CHECKBOX_SELECT_UNKNOWN,判断是否有未选中
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
            // 全选状态
            this.strCheckBoxSelectTip = this.$t('strings.msg_deselect_all');
        } else {
            // 非全选状态
            this.strCheckBoxSelectTip = this.$t('strings.msg_select_all');
        }
    },
    // 搜索
    clickToSearch(e) {
        this.inputValueOfSearch = e.text;
        this.search(e.text);
    },
    clickToConversation(index) {
        if (this.resetTouch()) {
            return;
        }
        // 跳转至短信详情页面
        mmsLog.info(common.TAG.MsgList + 'clickToConversation isMultipleSelectState: ' + this.isMultipleSelectState);
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
        this.jumpToConversationPage(this.messageList[index]);
        // 如果该联系人下有未读的信息，还需要向后端PA发送消息，使该联系人的所有信息标记为已读
        if (this.messageList[index].countOfUnread > common.int.MESSAGE_CODE_ZERO) {
            this.markAllAsReadByIndex(index);
        }
    },
    cancelMessageNotify(threadIds, callback) {
        let actionData = {
            featureAbility: this.$app.$def.featureAbility,
            ohosDataAbility: this.$app.$def.ohosDataAbility,
            hasRead: 0,
            threadIds: threadIds
        };
        notificationService.cancelMessageNotify(actionData, res => {
            mmsLog.info(common.TAG.MsgList + 'cancelMessageNotify success: ' + res);
            callback();
        });
    },
    // 跳转至通知信息页面
    clickToInfoMessages() {
        if (this.resetTouch()) {
            return;
        }
        if (this.isMultipleSelectState) {
            return;
        }
        router.push({
            uri: 'pages/info_msg/info_msg'
        })
    },
    clickToMarkAllAsRead() {
        // 把未读的标记为已读,这里处理的是信息列表中的值
        let threadIds = [];
        for (let mms of this.messageList) {
            if (mms.countOfUnread > common.int.MESSAGE_CODE_ZERO) {
                threadIds.push(mms.threadId);
            }
        }
        this.markAllAsRead(threadIds, this.messageList, false);

        // 把通知信息的标记为已读
        let actionData = {
            hasRead: 1,
            smsType: 1,
            rdbStore: this.$app.$def.rdbStore,
            featureAbility: this.$app.$def.featureAbility,
            ohosDataAbility: this.$app.$def.ohosDataAbility
        }
        messageService.markAllToRead(actionData);
        this.unreadTotalOfInfo = 0;
        this.unreadTotal = 0;

        // 取消所有的通知
        notificationService.cancelAllNotify();
    },
    markAllAsReadByIndex(index) {
        mmsLog.log(common.TAG.MsgList + 'markAllAsReadByIndex start !!!');
        let item = this.messageList[index];
        let threadIds = [item.threadId];
        this.cancelMessageNotify(threadIds, () => {
            // 把联系人(参数类型为数组)的所有信息标记为已读
            this.markAllAsRead(threadIds, this.messageList, false);
            // 信息item没有自动右滑
            this.setListItemTransX(0);
        });
    },
    markAllAsRead(threadIds, messageList, isInfo) {
        // 把联系人(参数类型为数组)的所有信息标记为已读
        let valueBucket = {
            'unread_count': 0,
        };
        let actionData = {
            threadIds: threadIds,
            rdbStore: this.$app.$def.rdbStore,
            valueBucket: valueBucket,
            featureAbility: this.$app.$def.featureAbility,
            ohosDataAbility: this.$app.$def.ohosDataAbility,
            hasRead : 1
        };
        let countOfUnread = 0;
        for (let mms of messageList) {
            if (threadIds.indexOf(mms.threadId) > common.int.FAILURE) {
                countOfUnread += mms.countOfUnread;
                // 控制列表的未读图标的显示
                mms.countOfUnread = common.int.MESSAGE_CODE_ZERO;
            }
        }
        this.unreadTotal -= countOfUnread;
        // 如果是通知信息
        if (isInfo) {
            this.unreadTotalOfInfo -= countOfUnread;
        }
        // 将标记已读的数据更新为0
        messageService.markAllAsRead(actionData);
    },
    // 跳转至新建信息页面
    clickToNewMessage() {
        if (this.isJumping) {
            return;
        }
        this.resetTouch();
        this.isJumping = true;
        this.jumpToNewMessagePage();
    },
    jumpToNewMessagePage(){
        router.push({
            uri: 'pages/conversation/conversation',
            params: {
                isNewMsg: true
            }
        });
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
        if (contactsNum > common.int.MESSAGE_CODE_ONE) {
            let threadId = this.messageList[index].threadId;
            let contactsNum = this.messageList[index].contactsNum;
            this.jumpToGroupDetailList(threadId, contactsNum);
        } else {
            var actionData = {};
            actionData.phoneNumber = telephone;
            actionData.pageFlag = common.contractPage.PAGE_FLAG_CONTACT_DETAILS;
            this.jumpToContract(actionData);
        }
    },
    // 跳转联系人app
    jumpToContract(actionData){
        let commonService = this.$app.$def.commonService;
        let str = commonService.commonContractParam(actionData);
        let featureAbility = this.$app.$def.featureAbility;
        featureAbility.startAbility(str).then((data) => {
            mmsLog.info(common.TAG.MsgList + 'jumpToContract,Data');
        }).catch((error) => {
            mmsLog.error(common.TAG.MsgList + 'jumpToContract,failed,Cause: ' + JSON.stringify(error));
        })
    },
    // 查询所有的列表信息
    queryAllMessages() {
        mmsLog.info('querySessions,start！！！！');
        let that = this;
        let actionData = {
            featureAbility: this.$app.$def.featureAbility,
            ohosDataAbility: this.$app.$def.ohosDataAbility
        };
        // 通知信息是否需要整合
        if(this.hasAggregate) {
            // 只查询非通知信息
            actionData.numberType = 0;
        }
        actionData.page = this.page;
        actionData.limit = this.limit;
        let rdbStore = this.$app.$def.rdbStore;
        let dateUtil = this.$app.$def.dateUtil;
        messageService.querySessionList(rdbStore, actionData, result => {
            if (result.code == common.int.SUCCESS) {
                mmsLog.info('querySessionList,success');
                let res = [];
                result.response.forEach(item => {
                    let obj = {};
                    obj = item;
                    obj.isDelShow = false;
                    obj.itemLeft = 0;
                    // 时间转换
                    dateUtil.convertDateFormatForItem(item, false, that);
                    // 处理彩信的内容展示
                    this.dealMmsListContent(item);
                    res.push(obj);
                });
                that.messageList = res;
                that.total = result.total;
                that.showInfoDivWhenSearchFlag = result.showInfoDivWhenSearchFlag;
            } else {
                mmsLog.info(common.TAG.MsgList + 'Error: queryAllMessages() failed !!!')
            }
        });
    },
    dealMmsListContent(item) {
        if(item.hasMms && item.hasAttachment) {
            if(item.content == common.string.EMPTY_STR) {
                item.content = this.$t('strings.attachment_no_subject');
            } else {
                item.content = this.$t('strings.attachment') + item.content;
            }
        }
        if(item.hasMms && !item.hasAttachment && item.content == common.string.EMPTY_STR) {
            item.content = this.$t('strings.no_subject');
        }
    },
    search(text) {
        // 在信息列表页面搜索
        let actionData = {}
        actionData.inputValue = text
        this.searchTextAsync(actionData);
    },
    searchTextAsync(actionData) {
        actionData.rdbStore = this.$app.$def.rdbStore;
        actionData.ohosDataAbility = this.$app.$def.ohosDataAbility;
        actionData.featureAbility = this.$app.$def.featureAbility;
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
    searchResultListEmpty() {
        this.searchResultList = {
            contentList: [],
            sessionList: []
        }
        this.isSearchStatus = true;
        this.showInfoDivWhenSearchFlag = true;
        if (this.isShowSearchBack) {
            this.isSearchCoverage = true;
        } else {
            this.isSearchCoverage = false;
        }
    },
    dealSearchResult(result) {
        this.searchResultList = {
            contentList: [],
            sessionList: []
        }
        this.showInfoDivWhenSearchFlag = false;
        this.isSearchStatus = false;
        this.isSearchCoverage = false;
        this.buildSearchResult(result);
        if (this.inputValueOfSearch === result.search) {
            this.searchResultList = result.resultMap;
        }
    },
    buildSearchResult(result) {
        let dateUtil = this.$app.$def.dateUtil;
        if (result.resultMap.contentList) {
            result.resultMap.contentList.forEach(content => {
                content.timeMillisecond = parseInt(content.timeMillisecond);
                dateUtil.convertDateFormatForItem(content, true, this);
                if(content.isFavorite) {
                    content.name = this.$t('strings.message_in_favorites');
                }
            });
        }
        if (result.resultMap.sessionList) {
            result.resultMap.sessionList.forEach(session => {
                session.timeMillisecond = parseInt(session.timeMillisecond);
                dateUtil.convertDateFormatForItem(session, true, this);
            });
        }
    },
    // 删除信息
    deleteMessage(telephoneArray){
        let actionData = {};
        actionData.telephoneNumbers = telephoneArray;
        messageService.deleteMessage(actionData);
    },
    // 跳转到详情页面
    jumpToConversationPage(item){
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
            }
        });
    },
    // 跳转到组详情页面
    jumpToGroupDetailList(threadId, contactsNum){
        router.push({
            uri: 'pages/group_detail/group_detail',
            params: {
                threadId: threadId,
                contactsNum: contactsNum
            }
        });
    },
    // 跳转到设置页面
    jumpToSettingsPage(){
        router.push({
            uri: 'pages/settings/settings',
            params: {
                pageFlag: 'settingsDetail',
            }
        })
    },
    // 跳转至收藏页面
    jumpToFavoritesPage(){
        router.push({
            uri: 'pages/my_star/my_star',
        });
    },
    conversationCheckboxChange(index, e) {
        this.messageList[index].isCbChecked = e.checked;
        this.setConversationCheckAll(common.int.CHECKBOX_SELECT_UNKNOWN);
    },
    // 长按单个列表，展示全选和删除
    conversationLongPress(index) {
        // 是否有左滑删除按钮存在，存在则不可点击
        if (this.itemTouchedIdx >= 0 && this.messageList[this.itemTouchedIdx].isDelShow) {
            return;
        }
        // 长按单个列表，展示全选和删除
        mmsLog.info(common.TAG.MsgList + 'conversationLongPress==>index:' + index);
        if (this.isMultipleSelectState) {
            this.messageList[index].isCbChecked = !this.messageList[index].isCbChecked;
        } else {
            this.isMultipleSelectState = true;
            this.messageList[index].isCbChecked = true;
        }
        this.setConversationCheckAll(common.int.CHECKBOX_SELECT_UNKNOWN);
    },
    clickConversationDelete() {
        // 按钮删除
        if (this.conversationSelectedNumber == common.int.MESSAGE_CODE_ZERO) {
            return;
        }
        // 删除一条
        if (this.conversationSelectedNumber == common.int.MESSAGE_CODE_ONE) {
            this.strMsgDeleteDialogTip = this.$t('strings.msg_delete_dialog_tip1');
        } else if (this.conversationSelectedNumber == this.messageList.length) {
            // 删除全部
            this.strMsgDeleteDialogTip = this.$t('strings.msg_delete_dialog_tip3');
        } else {
            // 删除多条
            this.strMsgDeleteDialogTip = this.$t('strings.msg_delete_dialog_tip2', {
                number: this.conversationSelectedNumber
            });
        }
        // 是否被锁定
        this.hasLockMsg = this.judgehasLockMsg();
        this.$element('delete_dialog').show();
    },
    judgehasLockMsg() {
        let hasLockMsg = false;
        for (let element of this.messageList) {
            if (element.isCbChecked && element.isLock) {
                hasLockMsg = true;
                break;
            }
        }
        return hasLockMsg;
    },
    clickConversationCheckAll() {
        // 全选/取消全选
        if (this.isConversationCheckAll) {
            for (let element of this.messageList) {
                element.isCbChecked = false;
            }
            this.setConversationCheckAll(common.int.CHECKBOX_SELECT_NONE);
        } else {
            // 非全选-->全选
            for (let element of this.messageList) {
                element.isCbChecked = true;
            }
            this.setConversationCheckAll(common.int.CHECKBOX_SELECT_ALL);
        }
    },
    exitConversationSelect() {
        // 退出多选deleteDialogCancel
        this.onBackPress();
    },
    deleteDialogCancel() {
        // 取消弹出
        this.$element('delete_dialog').close();
        if (this.isSelectLockMsg) {
            this.isSelectLockMsg = false;
        }
    },
    deleteDialogConfirm() {
        let mmsList = [];
        let threadIds = [];
        let lockThreadIds = [];
        let actionData = {
            rdbStore: this.$app.$def.rdbStore,
            featureAbility: this.$app.$def.featureAbility,
            ohosDataAbility: this.$app.$def.ohosDataAbility
        };
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
        // 设置为非多选状态
        this.isMultipleSelectState = false;
        this.isSelectLockMsg = false;
        this.messageList = mmsList;
        this.total = this.messageList.length;
        // 取消弹出
        this.$element('delete_dialog').close();
        this.deleteNotifyMessage(threadIds, lockThreadIds, actionData, () => {
            this.deleteMessageByThreadIds(threadIds, lockThreadIds, actionData);
        });
        this.setDelShow();
    },
    deleteNotifyMessage(threadIds, lockThreadIds, actionData, callback) {
        let sessionIds = [];
        if (threadIds.length > 0) {
            sessionIds.push(threadIds);
        }
        if (lockThreadIds.length > 0) {
            sessionIds.push(lockThreadIds);
        }
        actionData.threadIds = sessionIds;
        actionData.hasRead = 0;
        this.cancelMessageNotify(actionData, callback);
    },
    deleteMessageByThreadIds(threadIds, lockThreadIds, actionData) {
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
    },
    setSelectLockChange(e) {
        // 删除锁定CheckBox勾选事件
        this.isSelectLockMsg = e.checked;
    },
    setDelShow() {
        if (this.itemTouchedIdx >= 0) {
            let item = this.messageList[this.itemTouchedIdx];
            this.setListItemTransX(0);
            item.isDelShow = false;
        }
    },
    setSelectLock() {
        this.isSelectLockMsg = !this.isSelectLockMsg;
    },
    searchTouchStart(e) {
        // 判断是否是多选状态
        if (this.isMultipleSelectState) {
            return false;
        }
        let that = this
        // 搜索区域touchStart监控x > 125 && x < 600) && (y < 70 && y > 20
        var x = e.touches[0].localX;
        if (e.currentTarget.type === 'search' && x > 80 && x < 560) {
            this.isShowSearchBack = true;
            // 蒙层展示
            this.isSearchCoverage = true;
            // 是否显示新建按钮
            this.isNewSms = false;
            // 拉起输入法
            setTimeout(function () {
                that.$element('searchBox').focus({
                    focus: true
                })
            }, common.int.MESSAGE_CODE_THREE_ZERO_ZERO)
        }
        this.resetTouch();
        return false;
    },
    clickSearchBack() {
        // 点击搜索返回按钮后
        this.backSearch();
    },
    searchCoverageClick() {
        // 手指滑动蒙层退出搜索模式
        this.backSearch();
    },
    searchConversationClick(index) {
        // 跳转到会话详情
        let isSearchConversation = 0;
        this.searchMmsClicked(this.searchResultList.sessionList[index], isSearchConversation);
    },
    searchSmsClick(index) {
        // 点击单个信息
        let isSearchConversation = 1;
        this.searchMmsClicked(this.searchResultList.contentList[index], isSearchConversation);
    },
    searchConversationHeadClick(index) {
        // 搜索会话头像点击
        this.headClickedListener(this.searchResultList.sessionList[index]);
    },
    searchSmsHeadClick(index) {
        // 单条信息头像点击跳转 判断跳转到联系人详情还是跳转到多个收件人的列表页面
        this.headClickedListener(this.searchResultList.contentList[index]);
    },
    backSearch() {
        this.isShowSearchBack = false;
        this.isSearchCoverage = false;
        this.$element('searchBox').focus({
            focus: false
        });
        this.inputValueOfSearch = common.string.EMPTY_STR;
        this.isSearchStatus = true;
        this.isNewSms = true;
        this.searchResultList.sessionList = [];
        this.searchResultList.contentList = [];
    },
    headClickedListener(item) {
        // 点击头像跳转至联系人详情页面或收件人列表页面
        if (this.isJumping) {
            return;
        }
        // 收藏数据,头像不需要跳转
        if(item.isFavorite != null && item.isFavorite) {
            return;
        }
        this.isJumping = true;
        // 判断跳转到联系人详情还是跳转到多个收件人的列表页面
        var contactsNum = item.contactsNum;
        var telephone = item.telephone;
        if (contactsNum > common.int.MESSAGE_CODE_ONE) {
            let threadId = item.threadId;
            let contactsNum = item.contactsNum;
            this.jumpToGroupDetailList(threadId, contactsNum);
        } else {
            // 联系人提供js的跳转API
            var actionData = {};
            actionData.phoneNumber = telephone;
            actionData.pageFlag = common.contractPage.PAGE_FLAG_CONTACT_DETAILS;
            this.jumpToContract(actionData);
        }
    },
    searchMmsClicked(item, isSearchConversation) {
        if(item.isFavorite) {
            this.jumpToMyStar();
        } else {
            // 跳转到短信详情
            router.push({
                uri: 'pages/conversation/conversation',
                params: {
                    strContactsNumber: item.telephone,
                    strContactsNumberFormat: item.telephoneFormat,
                    strContactsName: item.name,
                    contactsNum: item.contactsNum,
                    threadId: item.threadId,
                    isDraft: item.isDraft,
                    searchContent: this.inputValueOfSearch
                }
            });
        }
    },
    jumpToMyStar() {
        router.push({
            uri: 'pages/my_star/my_star',
            params: {
                searchContent: this.inputValueOfSearch
            }
        });
    },
    // 重置触摸事件，用于其他按钮点击时复位已左滑移动的item
    resetTouch() {
        if (this.itemTouchedIdx !== -1) {
            let itemTouched = this.messageList[this.itemTouchedIdx];
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
    },
    // 重置上一个触摸事件，用于左滑item，定时器在此处是必须的，否则会响应到点击事件
    resetPreListItemTouch() {
        let itemTouched = this.messageList[this.itemTouchedIdx];
        if (itemTouched.isDelShow) {
            this.setListItemTransX(0);
            setTimeout(function () {
                itemTouched.isDelShow = false;
            }, 200);
        }
    },
    getTouchIndex(ele) {
        let itemIndex = -1;
        if (ele.classList[0] === 'messaging-body-item') {
            if (itemIndex === -1) {
                itemIndex = ele.classList[1].substring(5);
            }
        }
        return parseInt(itemIndex);
    },
    // 信息列表的触摸事件
    touchStart(event) {
        if (this.isMultipleSelectState) {
            return;
        }
        if (this.showMarkAllAsRead) {
            // 上一个触控的是通知item，则将通知item复位
            this.setInfoItemTransX(0);
            setTimeout(() => {
                this.showMarkAllAsRead = false;
            }, 200);
        } else {
            // 查看当前触控的item是否是跟上一个触控的是同一个，若不是，将上一个复位
            let touchIdx = this.getTouchIndex(event.currentTarget);
            if (this.itemTouchedIdx !== -1 && touchIdx !== this.itemTouchedIdx) {
                this.resetPreListItemTouch();
            }
        }
        this.startX = event.touches[0].globalX;
    },
    touchMove(event) {
        if (this.isMultipleSelectState) {
            return;
        }
        let moveX = event.touches[0].globalX;
        let disX = this.startX - moveX;
        // 位移小于2，视为没有滑动
        if (Math.abs(disX) <= 2) {
            return;
        }
        let ele = event.currentTarget;
        this.itemTouchedIdx = this.getTouchIndex(ele);
        let itemTouched = this.messageList[this.itemTouchedIdx];
        if (itemTouched.countOfUnread > 0) {
            this.operateBtnW = common.int.OPERATE_UNREAD_WIDTH;
        } else {
            this.operateBtnW = common.int.OPERATE_DELETE_WIDTH;
        }
        if (disX > 0) {
            if (itemTouched.isDelShow) {
                return;
            }
            let transX = disX;
            if (disX >= this.operateBtnW) {
                // 左滑到最大宽度
                transX = this.operateBtnW;
                itemTouched.isDelShow = true;
            }
            this.setListItemTransX(transX);
        } else if (disX < 0) {
            if (!itemTouched.isDelShow) {
                return;
            }
            if (disX > -this.operateBtnW) {
                this.setListItemTransX(disX);
            } else {
                itemTouched.isDelShow = false;
                this.setListItemTransX(0);
            }
        }
    },
    touchEnd(event) {
        if (this.isMultipleSelectState) {
            return;
        }
        let endX = event.changedTouches[0].globalX;
        let disX = this.startX - endX;
        // 位移小于2，视为没有滑动
        if (Math.abs(disX) <= 2) {
            return;
        }
        let itemTouched = this.messageList[this.itemTouchedIdx];
        if (disX < (this.operateBtnW / 2)) {
            // 小于一半 回原位置
            this.setListItemTransX(0);
            itemTouched.isDelShow = false;
        } else {
            // 大于一半 滑动到最大值
            this.setListItemTransX(this.operateBtnW);
            itemTouched.isDelShow = true;
        }
    },
    setListItemTransX(disX) {
        let itemTouched = this.messageList[this.itemTouchedIdx];
        if (itemTouched) {
            if (disX >= 0) {
                itemTouched.itemLeft = -disX;
            } else {
                itemTouched.itemLeft = -this.operateBtnW - disX;
            }
        }
    },
    deleteAction(idx) {
        let item = this.messageList[idx];
        this.strMsgDeleteDialogTip = this.$t('strings.msg_delete_dialog_tip1');
        item.isCbChecked = true;
        this.hasLockMsg = this.judgehasLockMsg();
        this.$element('delete_dialog').show();
    },
    // 通知信息item的触摸事件
    touchInfoStart(event) {
        if (this.isMultipleSelectState || this.unreadTotalOfInfo === 0) {
            return;
        }
        // 上一个触控的若是信息列表item，则将其复位
        if (this.itemTouchedIdx >= 0 && this.messageList.length > this.itemTouchedIdx) {
            this.resetPreListItemTouch();
        }
        this.startX = event.touches[0].globalX;
    },
    touchInfoMove(event) {
        if (this.isMultipleSelectState || this.unreadTotalOfInfo === 0) {
            return;
        }
        let moveX = event.touches[0].globalX;
        let disX = this.startX - moveX;
        // 位移小于2，视为没有滑动
        if (Math.abs(disX) <= 2) {
            return;
        }
        this.operateBtnW = common.int.OPERATE_DELETE_WIDTH;
        if (disX > 0) {
            if (this.showMarkAllAsRead) {
                return;
            }
            let transX = disX;
            if (disX >= this.operateBtnW) {
                // 左滑到最大宽度
                transX = this.operateBtnW;
                this.showMarkAllAsRead = true;
                this.itemTouchedIdx = -1;
            }
            this.setInfoItemTransX(transX);
        } else if (disX < 0) {
            if (!this.showMarkAllAsRead) {
                return;
            }
            if (disX > -this.operateBtnW) {
                this.setInfoItemTransX(disX);
            } else {
                this.showMarkAllAsRead = false;
                this.setInfoItemTransX(0);
            }
        }
    },
    touchInfoEnd(event) {
        if (this.isMultipleSelectState || this.unreadTotalOfInfo === 0) {
            return;
        }
        let endX = event.changedTouches[0].globalX;
        let disX = this.startX - endX;
        // 位移小于2，视为没有滑动
        if (Math.abs(disX) <= 2) {
            return;
        }
        if (disX < (this.operateBtnW / 2)) {
            // 小于一半 回原位置
            this.setInfoItemTransX(0);
            this.showMarkAllAsRead = false;
        } else {
            // 大于一半 滑动到最大值
            this.setInfoItemTransX(this.operateBtnW);
            this.showMarkAllAsRead = true;
            this.itemTouchedIdx = -1;
        }
    },
    setInfoItemTransX(disX) {
        if (disX >= 0) {
            this.infoLeft = -disX;
        } else {
            this.infoLeft = -this.operateBtnW - disX;
        }
    },
    markInfoAsRead() {
        this.unreadTotalOfInfo = 0;
        this.showMarkAllAsRead = false;
        this.setInfoItemTransX(0);
    },
    jumpToCamera() {
        router.push({
            uri: 'pages/test_camera/test_camera'
        })
    }
}