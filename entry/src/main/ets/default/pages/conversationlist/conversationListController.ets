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
import common from '../../data/commonData'
import router from '@system.router';
import commonEvent from '@ohos.commonEvent';
import dateUtil from '../../utils/DateUtil';
import featureAbility from '@ohos.ability.featureAbility';
import LooseObject from '../../data/LooseObject';
import messageService from '../../service/ConversationListService';
import HiLog from '../../utils/HiLog';
import rdbStore from '../../utils/RdbStoreUtil';
import SettingService from '../../service/SettingService'
import commonService from '../../service/CommonService';
import notificationService from '../../service/NotificationService';
import AppStorageUtil from '../../utils/AppStorageUtil';

let ConversationCtrl;

let commonEventData = null;

const TAG = 'ConversationListController';

export default class ConversationListController {
  svgDelete: string = '';
  strCheckBoxSelectTip: Resource;
  strMsgDeleteDialogTip: Resource;
  // 所有短信的总条数
  total: number = 0;
  // 通知信息的总条数
  totalOfInfo: number = 0;
  // 未读信息的总条数
  unreadTotal: number = 0;
  // 未读的通知信息总条数
  unreadTotalOfInfo: number = 0;
  // 已经选中的会话条数
  conversationSelectedNumber: number = 0;
  // 是否处于多选状态*/
  isMultipleSelectState: boolean = false;
  // 是否会话列表处于全选状态
  isConversationCheckAll: boolean = false;
  // 信息列表页面搜索框输入的值
  inputValueOfSearch: string = '';
  inputValueOfSearchTemp: string = '';
  // 通知信息所在行隐藏的'标记为已读'，当存在未读信息时，向左滑动屏幕才能看见该图标
  markAllAsReadForInfo: boolean = false;
  // 标记为已读
  showMarkAllAsRead: boolean = false;
  // 删除，在每条单独的消息那一行，向左滑动屏幕可见
  showDelete: boolean = false;
  // 是否锁定 默认false不锁定
  hasLockMsg: boolean = false;
  isSelectLockMsg: boolean = false;
  // 动态设置删除弹窗高度
  dialogHeight: string = '';
  // 通知信息内的数据
  messageListForInfo: Array<any> = [];
  //删除弹窗是否显示
  deleteDialogShow: boolean = false;
  // 如果通知信息整合开关打开，则是非通知信息，如果没有打开，则是所有数据
  messageList: Array<any> = [];
  // 搜索结果列表
  searchResultList: LooseObject = {
    sessionList: [],
    contentList: []
  };
  // 搜索结果队列
  searchResultListQueue: Array<any> = [];
  // 搜索文本队列
  searchTextQueue: Array<any> = [];
  // 队列启动标志位
  queueFlag: boolean = false;
  // 队列定时器启动标志位
  setTimeOutQueueFlag: boolean = false;
  // 搜索结果的个数
  countOfSearchResult: number = 0;
  // 是否真正进行跳转,避免重复跳转
  isJumping: boolean = false;
  // 通知信息整合开关'是否打开，该开关在设置里
  hasAggregate: boolean = true;
  // 显示联系人头像
  isShowContactHeadIcon: boolean = true;
  // 是否显示搜索返回按钮 默认不显示
  isShowSearchBack: boolean = false;
  isSearchFocusable: boolean = false;
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
  // 显示搜索状态
  showSearchStatus: Resource;
  // 是否显示新建短信按钮
  isNewSms: boolean = true;
  conversationName: string = '';
  // 搜索时显示搜索框所在div
  showInfoDivWhenSearchFlag: boolean = true;
  // 变化刷新UI
  flushTranslate: boolean = true;
  // 操作按钮的长度
  operateBtnW: number = 145;
  // 当前触摸的数据索引
  itemTouchedIdx: number = -1;
  // 通知信息的左边距
  infoLeft: number = 0;
  // 列表分页，页数
  page: number = 0;
  // 列表分页，数量
  limit: number = 1000;

  static getInstance() {
    if (ConversationCtrl == null) {
      ConversationCtrl = new ConversationListController();
      appStorage.setAndLink('ConListController', ConversationCtrl);
    }
    return ConversationCtrl;
  }

  onInit() {
    this.svgDelete = 'icon/ic_delete_m.svg';
    this.strCheckBoxSelectTip = $r("app.string.msg_select_all");
    this.strMsgDeleteDialogTip = $r("app.string.msg_delete_dialog_tip2", this.conversationSelectedNumber);
    this.showSearchStatus = $r("app.string.noMessages");
  };

  onShow() {
    HiLog.i(TAG, 'onShow');
    this.isJumping = false;
    this.subscribe()
    this.getSettingFlagForConvListPage();
    this.statisticalData();
    this.page = 0;
    this.messageList = [];
    this.requestItem();
    let hasInfoMsg = false;
    hasInfoMsg = AppStorageUtil.getHasInfoMsg();
    if (!hasInfoMsg && this.messageList.length == 0) {
      this.total = 0;
    }
  };

  onDestroy() {
    HiLog.i(TAG, 'onDestroy');
    this.unSubscribe();
  };

  // 长按单个列表，展示全选和删除
  conversationLongPress(index) {
    // 是否有左滑删除按钮存在，存在则不可点击
    if (this.messageList[index].isDelShow) {
      return;
    }
    // 长按单个列表，展示全选和删除
    HiLog.i(TAG, 'conversationLongPress, index: ' + index);
    if (this.isMultipleSelectState) {
      this.messageList[index].isCbChecked = !this.messageList[index].isCbChecked;
    } else {
      this.isMultipleSelectState = true;
      this.messageList[index].isCbChecked = true;
    }
    this.setConversationCheckAll(common.int.CHECKBOX_SELECT_UNKNOWN);
  };

  setConversationCheckAll(selectType) {
    // 检查是否全选
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
      this.strCheckBoxSelectTip = $r("app.string.msg_deselect_all");
    } else {
      // 非全选状态
      this.strCheckBoxSelectTip = $r("app.string.msg_select_all");
    }
  };

  //点击联系人
  clickToConversation(index) {
    if (this.resetTouch()) {
      return;
    }
    // 跳转至短信详情页面
    HiLog.i(TAG, 'clickToConversation, isMultipleSelectState: ' + this.isMultipleSelectState);
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
  };

  backSearch() {
    this.isShowSearchBack = false;
    this.isSearchCoverage = false;
    //  this.$element('searchBox').focus({
    //    focus: false
    //  });
    this.isSearchFocusable = false
    this.inputValueOfSearch = common.string.EMPTY_STR;
    this.isSearchStatus = true;
    this.isNewSms = true;
    this.searchResultList.sessionList = [];
    this.searchResultList.contentList = [];
  };

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
  };

  // 信息列表的触摸事件
  touchStart(event: GestureEvent, index: number) {
    if (this.isMultipleSelectState) {
      return;
    }
    if (this.showMarkAllAsRead) {
      // 上一个触控的是通知item，则将通知item复位
      //      this.setInfoItemTransX(0);
      //      setTimeout(() => {
      //        this.showMarkAllAsRead = false;
      //      }, 200);
    } else {
      // 查看当前触控的item是否是跟上一个触控的是同一个，若不是，将上一个复位
      if (this.itemTouchedIdx !== -1 && index !== this.itemTouchedIdx) {
        let itemTouched = this.messageList[this.itemTouchedIdx];
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
  };

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
  };

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
  };

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
  };

  setInfoItemTransX(disX) {
    if (disX >= 0) {
      this.infoLeft = -disX;
    } else {
      this.infoLeft = -this.operateBtnW - disX;
    }
  };

  markInfoAsRead() {
    this.unreadTotalOfInfo = 0;
    this.showMarkAllAsRead = false;
    this.setInfoItemTransX(0);
  };

  jumpToCamera() {
    router.push({
      uri: 'pages/test_camera/test_camera'
    })
  };

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
  };

  clickConversationDelete() {
    // 按钮删除
    if (this.conversationSelectedNumber == common.int.MESSAGE_CODE_ZERO) {
      return;
    }
    // 删除一条
    if (this.conversationSelectedNumber == common.int.MESSAGE_CODE_ONE) {
      this.strMsgDeleteDialogTip = $r("app.string.msg_delete_dialog_tip1");
    } else if (this.conversationSelectedNumber == this.messageList.length) {
      // 删除全部
      this.strMsgDeleteDialogTip = $r("app.string.msg_delete_dialog_tip3");
    } else {
      // 删除多条
      this.strMsgDeleteDialogTip = $r("app.string.msg_delete_dialog_tip2", this.conversationSelectedNumber);
    }
    // 是否被锁定
    this.hasLockMsg = this.judgehasLockMsg()
    this.deleteDialogShow = true
    //    this.$element('delete_dialog').show();
  };

  judgehasLockMsg() {
    let hasLockMsg = false;
    for (let element of this.messageList) {
      if (element.isCbChecked && element.isLock) {
        hasLockMsg = true;
        break;
      }
    }
    return hasLockMsg;
  };

  onBackPress() {
    // 系统返回键,true代表拦截
    if (this.isMultipleSelectState) {
      for (let element of this.messageList) {
        element.isCbChecked = false;
      }
      this.isMultipleSelectState = false;
    }
    if (!this.isSearchStatus) {
      this.backSearch();
    }
  };

  deleteDialogConfirm() {
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
    // 设置为非多选状态
    this.isMultipleSelectState = false;
    this.isSelectLockMsg = false;
    this.messageList = mmsList;
    this.total = this.messageList.length;
    if (threadIds.length > 0) {
      let actionData = {
        threadIds: threadIds
      };
      messageService.deleteMessageById(actionData);
    }

    if (lockThreadIds.length > 0) {
      let actionData: LooseObject = {};
      actionData.threadIds = lockThreadIds;
      messageService.dealMessageLockContent(actionData, res => {
        actionData.hasLock = 0;
        messageService.deleteMessageBySessionIdsAndLock(actionData);
      });
    }
  };

  deleteDialogCancel() {
    // 取消弹出
    if (this.isSelectLockMsg) {
      this.isSelectLockMsg = false;
    }
  };

  setDelShow() {
    if (this.itemTouchedIdx >= 0) {
      let item = this.messageList[this.itemTouchedIdx];
      this.setListItemTransX(0);
      item.isDelShow = false;
    }
  };

  jumpToFavoritesPage() {
    router.push({
      uri: 'pages/my_star/my_star',
    });
  };

  clickToMarkAllAsRead() {
    // 把未读的标记为已读,这里处理的是信息列表中的值
    let threadIds = [];
    for (let mms of this.messageList) {
      if (mms.countOfUnread > common.int.MESSAGE_CODE_ZERO) {
        threadIds.push(mms.threadId);
      }
    }
    this.markAllAsRead(threadIds);

    // 把通知信息的标记为已读
    let actionData = {
      hasRead: 1,
      smsType: 1,
    }
    messageService.markAllToRead(actionData);
    this.unreadTotalOfInfo = 0;
    this.unreadTotal = 0;
  };

  jumpToSettingsPage() {
    // 暂时跳转到高级设置且只显示一个送达报告开关
    router.push({
      uri: 'pages/settings/advancedSettings/advancedSettings'
    });
  };

  subscribe() {
    let events = [common.string.RECEIVE_TRANSMIT_EVENT]
    let commonEventSubscribeInfo = {
      events: events
    };
    commonEvent.createSubscriber(commonEventSubscribeInfo, this.createSubscriberCallBack.bind(this));

  };

  subscriberCallBack(err, data) {
    this.page = 1;
    this.queryAllMessages();
    // 统计未读的信息
    this.statisticalData();
  };

  // 取消订阅
  unSubscribe() {
    HiLog.i(TAG, 'unSubscribe');
    commonEvent.unsubscribe(commonEventData, () => {
      HiLog.i(TAG, 'unSubscribe, success');
    });
  };

  createSubscriberCallBack(err, data) {
    commonEventData = data;
    // 接收到订阅
    commonEvent.subscribe(commonEventData, this.subscriberCallBack.bind(this));
  };

  // 统计数据
  statisticalData() {
    let actionData: LooseObject = {};
    let that = this;
    messageService.statisticalData(actionData, function (result) {
      if (result.code == common.int.SUCCESS) {
        // 列表的总数
        that.unreadTotal = result.response.totalListCount;
        // 通知信息的未读数
        that.unreadTotalOfInfo = result.response.unreadTotalOfInfo;
      } else {
        HiLog.w(TAG, 'statisticalData, failed');
      }
    });
  };

  // 获取整合通知信息和显示联系人头像的开关值
  getSettingFlagForConvListPage() {
    let result = SettingService.getSettingFlagForConvListPage();
    if (result) {
      this.hasAggregate = result.hasAggregate;
      this.isShowContactHeadIcon = result.isShowContactHeadIcon;
    }
  };

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
  };

  // 跳转至通知信息页面
  clickToInfoMessages() {
    if (this.resetTouch()) {
      return;
    }
    if (this.isMultipleSelectState) {
      return;
    }
    router.push({
      uri: 'pages/info_msg/InfoMsg'
    })
  };

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
  };

  // 跳转联系人app
  jumpToContract(actionData) {
    let str = commonService.commonContractParam(actionData);
    featureAbility.startAbility(str).then((data) => {
      HiLog.i(TAG, 'jumpToContract, startAbility success');
    }).catch((error) => {
      HiLog.e(TAG, 'jumpToContract, failed Cause: ' + JSON.stringify(error.message));
    })
  };

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
  };

  setSelectLock() {
    this.isSelectLockMsg = !this.isSelectLockMsg;
  };

  setSelectLockChange(e) {
    // 删除锁定CheckBox勾选事件
    this.isSelectLockMsg = e.checked;
  };


  // 查询所有的列表信息
  queryAllMessages() {
    HiLog.i(TAG, 'queryAllMessages, start');
    let that = this;
    let actionData: LooseObject = {};
    // 通知信息是否需要整合
    if (this.hasAggregate) {
      // 只查询非通知信息
      actionData.numberType = 0;
    }
    actionData.page = this.page;
    actionData.limit = this.limit;
    messageService.querySessionList(actionData, result => {
      if (result.code == common.int.SUCCESS) {
        let res = [];
        result.response.forEach(item => {
          let obj: LooseObject = {};
          obj = item;
          obj.isDelShow = false;
          obj.itemLeft = 0;
          // 时间转换
          dateUtil.convertDateFormatForItem(item, false);
          // 处理彩信的内容展示
          this.dealMmsListContent(item);
          res.push(obj);
        });
        this.messageList = res;
        this.total = result.total;
        this.showInfoDivWhenSearchFlag = result.showInfoDivWhenSearchFlag;
      }
    });
  };

  dealMmsListContent(item) {
    if (item.hasMms && item.hasAttachment) {
      if (item.content == common.string.EMPTY_STR) {
        item.content = $r('app.string.attachment_no_subject');
      } else {
        item.content = $r('app.string.attachment', item.content);
      }
    }
    if (item.hasMms && !item.hasAttachment && item.content == common.string.EMPTY_STR) {
      item.content = $r('app.string.no_subject');
    }
  };

  // 把通知信息中未读的都标记为已读
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
    this.cancelMessageInfoNotify(threadIds, () => {
      messageService.markAllToRead(actionData);
      this.unreadTotalOfInfo = 0;
    });
  };

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
      if (threadIds.indexOf(msg.threadId) > common.int.FAILURE) {
        // 控制列表的未读图标的显示
        msg.countOfUnread = common.int.MESSAGE_CODE_ZERO;
      }
    }
    this.messageList = tempMsgList;
    this.unreadTotalOfInfo = this.unreadTotalOfInfo - threadIds.length;
    HiLog.i(TAG, 'markAllAsRead, unreadTotalOfInfo=' + this.unreadTotalOfInfo)
  };

  cancelMessageInfoNotify(threadIds, callback) {
    let actionData = {
      threadIds: threadIds,
      hasRead: 0
    };
    notificationService.cancelMessageNotify(actionData, res => {
      callback();
    });
  };

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
  };

  // 跳转至会话详情页面
  jumpToConversationPage(item) {
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
  };

  markAllAsReadByIndex(index) {
    let threadId = this.messageList[index].threadId;
    let threadIds = [threadId];
    this.cancelMessageInfoNotify(threadIds, () => {
      // 把联系人(参数类型为数组)的所有信息标记为已读
      this.markAllAsRead(threadIds);
      this.setListItemTransX(0);
    });
  };

  deleteAction(idx) {
    let element = this.messageList[idx];
    this.strMsgDeleteDialogTip = $r("app.string.msg_delete_dialog_tip1");
    element.isCbChecked = true;
    this.hasLockMsg = this.judgehasLockMsg();
  };

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
        //        that.$element('searchBox').focus({
        //          focus: true
        //        })
      }, common.int.MESSAGE_CODE_THREE_ZERO_ZERO)
    }
    this.resetTouch();
    return false;
  };

  // 搜索
  clickToSearch(inputContent) {
    this.inputValueOfSearch = inputContent;
    this.search(inputContent);
  };

  search(text) {
    // 在信息列表页面搜索
    let actionData: LooseObject = {}
    actionData.inputValue = text
    this.searchTextAsync(actionData);
  };

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
  };

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
  };

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
  };

  buildSearchResult(result) {

    if (result.resultMap.contentList) {
      result.resultMap.contentList.forEach(content => {
        content.timeMillisecond = parseInt(content.timeMillisecond);
        dateUtil.convertDateFormatForItem(content, true);
        if (content.isFavorite) {
          content.name = $r('app.string.message_in_favorites');
        }
      });
    }
    if (result.resultMap.sessionList) {
      result.resultMap.sessionList.forEach(session => {
        session.timeMillisecond = parseInt(session.timeMillisecond);
        dateUtil.convertDateFormatForItem(session, true);
      });
    }
  };
}
