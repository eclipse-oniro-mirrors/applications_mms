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
// 会话列表
import router from '@system.router';
import Prompt from '@system.prompt';
import HiLog from '../../utils/HiLog'
import common from '../../data/commonData'
import commonEvent from '@ohos.commonEvent';
import conversationService from '../../service/ConversationService';
import conversationListService from '../../service/ConversationListService';
import LooseObject from '../../data/LooseObject'
import commonService from '../../service/CommonService';
import settingService from '../../service/SettingService';
import {commonPasteboard} from '../../data/Pasteboard';
import telephoneUtil from '../../utils/TelephoneUtil';
import callService from '../../service/CallService';
import sendMsgService from '../../service/SendMsgService'
import preferences from '../../utils/PreferencesUtil';
import dateUtil from '../../utils/DateUtil';
import appConfig from '../../app';
import rdbStore from '../../utils/RdbStoreUtil';
import featureAbility from '@ohos.ability.featureAbility';
import appStorage from '../../utils/AppStorageUtil';
import notificationService from '../../service/NotificationService';

const TAG = 'ConversationController';
const ANIMATION_DURATION = 1500;
const TRANSFORM_SCALE_MIN = '1.0';
const TRANSFORM_SCALE_MAX = '3.0';
const COMMON_FILE_SIZE_STRING = '/300KB';
const COMMON_FILE_SIZE = 300;

let conversationCtrl;
let commonEventData = null;

export default class ConversationController {
    // 短信列表刷新flag
    refresh: boolean = false;
    // 信息删除提示
    strMsgDeleteDialogTip: Resource;
    // 点击状态
    isClickStatus: boolean = false;
    // 信息是否加锁
    hasLockMsg: boolean = false;
    // 选择状态
    isSelectStatus: boolean = false;
    // 是否选择加锁信息
    isSelectLockMsg: boolean = false;
    // 更多操作
    isShowMoreOperation: boolean = false;
    // 判断是否为同一天 默认为 false
    isLessOneDay: boolean = false;
    // 判断是否达到全屏条件
    isShowFullScreen: boolean = false;
    // 判断是否达全选
    isMessageCheckAll: boolean = false;
    // 是否只是录音
    isOnlyAudio: boolean = false;
    // 删除个数
    selectDeleteMsgCount: number = 0;
    // 输入框输入的文本，也是要发送的短信的内容
    textValue: string = '';
    // 录音动画任务
    drawRecordingTaskId: number = 0;
    // tab选项页,0拍摄照片,1图片,2录音,3更多
    tabIndex: number = 1;
    // tab选项页文本内容
    tabTextList: Array<any> = [];
    // 录音状态
    isRecordingStatus: boolean = true;
    // 当前录音时间
    curRecordingTime: string = '00:00';
    // 当前录音文件的大小(KB)
    curSize: number = 0;
    // 开始录音时间
    startRecordTime: number = 0;
    // 是否含有sim卡
    haveSimCard: boolean = false;
    // 是否显示卡图标
    cardImage: boolean = false;
    // 是否飞行模式
    isFlightMode: boolean = false;
    // 信息附件大小提示
    msgSendTip: string = '';
    // 当前能否发送短信
    canSendMessage: boolean = false;
    // 当前编辑的是否为彩信
    isEditMms: boolean = false;
    // 当前编辑的彩信附件大小
    curEdtFileSize: number = 0;
    // 获取单选的时间显示
    mmsTime: string = '';
    // 是否是短信和彩信
    isMmsType: Resource;
    // 是否收件人
    isSendRecipient: boolean;
    // 联系人名字
    strContactsName: string = '';
    // 联系人电话号码
    strContactsNumber: string = '';
    // 联系人电话号码格式化
    strContactsNumberFormat: string = '';
    // 附件类型为名片
    isVCard: boolean = false;
    // 是否是新建信息
    isNewMsg: boolean = false;
    // 联系人数量
    contactsNum: number = 0;
    // 名片
    vCard: {};
    // 彩信编辑列表
    mmsEditList: Array<any> = [];
    // 信息列表
    mmsList: Array<any> = [];
    // 当前选中信息index
    mmsIndex: number = 0;
    // 初始x位置
    rawX: string = '';
    // 初始y位置
    rawY: string = '';
    // 图库中的缩略图
    pictureListFromGallery: Array<any> = [];
    // 选项卡标题
    tabTitleText: Resource;
    // 发送工具栏距离底部位置
    sendBarMarginBottom: number = 0;
    // 选项卡高度
    tabHeight: number = common.int.TAB_HEIGHT;
    // 恢复任务id
    restoreTimeoutId: number = 0;
    // 是否真正执行动画
    isTabHeightAnimation: boolean = false;
    // 0默认状态,1滑动状态,2全屏状态
    tabSlideStatus: number = 0;
    // 滑动距离
    slideDistance: number = 0;
    // 滑动的起点坐标
    slideStartPoint: LooseObject = {
        x: 0,
        y: 0
    };
    // 是否上滑动
    isTabSlideUp: number = 0;
    // 联系人列表，从联系人app那里获取的，作为发彩信时的附件
    contactListFromContactApp: Array<any> = [];
    // 卡槽
    slotId: number = 0;
    // 选择的联系人
    selectContacts: Array<any> = [];
    // 收件人输入框内容
    receiveContactValue: string = '';
    // 给receive传递的参数数据
    paramContact: LooseObject = {};
    // 控制最后div显示与隐藏
    isSendStatus: boolean = false;
    // 会话列表的id
    threadId: number = 0;
    // 是否是详情页面
    isDetail: boolean = true;
    // 需要重新发送的下标
    reSendIndex: number = 0;
    // 复制选项是否可见
    showText: boolean = true;
    // 搜索传来的值
    searchKey: string = '';
    // 是否是草搞
    isDraft: boolean = false;
    // 草稿的内容
    draftContent: string = '';
    draftGroupId: number = 0;
    // 是否可以双击取消发送
    recallMessagesFlag: boolean = false;
    // 双击取消状态
    doubleClickStatus: boolean = false;
    // 距离底部的动态变化标志
    distanceBottomFlag: boolean = false;
    // 详情页删除
    hasDetailDelete: boolean = false;
    // 是否存在联系人
    hasExitContract: boolean = false;
    // 新建页面进行取发送
    isNewRecallMessagesFlag: boolean = false;
    // 录音动画
    recordingAnimation: LooseObject = {};
    // 动画样式属性
    animationOptions: LooseObject = {};
    // 动画样式属性对象
    animationFrames: LooseObject = {};
    // 默认后置摄像头
    cameraPattern: string = 'back';
    pattern: string = '';
    // 是否锁
    hasLock: boolean = false;
    // 高亮信息类型
    highlightsType: number = 0;
    // 高亮信息内容
    highlightsText: string = '';
    timeFormat: string = '00:01';
    // 0 - 普通,1 - 通知
    smsType: number = 0;
    isPicCheckboxClicked: boolean = false;
    // 是否支持发送报告
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
    // 时间
    mmsDateSet: Set<any> = new Set();

    static getInstance() {
        if (conversationCtrl == null) {
            conversationCtrl = new ConversationController();
            appStorage.setAndLink('ConversationController', conversationCtrl);
        }
        return conversationCtrl;
    }

    onInit() {
        HiLog.i(TAG, 'onInit');
        this.initRouterData()
        this.initData()
        if (this.hasDouble) {
            this.initNewPageContracts();
            this.hasDouble = false;
        }
        this.initSendTip();
        //    this.setTabTitleText();
        // 获取真实数据,新建无需查询数据
        if (!this.isNewMsg) {
            this.queryMessageDetail(this.strContactsNumber, this.threadId);
        }
    }

    onShow() {
        HiLog.i(TAG, 'onShow');
        if (this.mmsDateSet.size > 0) {
            this.mmsDateSet.clear();
        }
        // 判断是否插入了电话卡
        this.haveSimCard = conversationService.judgeHasSimCard();
        // 判断发送按钮是否可点击
        this.judgeSendBtnCanClicked();
        // 初始化转发的数据
        this.initTransmitMeg();
        //    // 获取取消发送的状态
        //    this.getSettingFlagForConvListPage();
        // 订阅PA
        this.subscribeDetail();
        // 判断联系人是否存在
        this.judgeContactExists();
        //    if (this.$app.$def.isFromFullScreen) {
        //      this.$app.$def.isFromFullScreen = false;
        //      // 判断是否是全屏发送
        //      this.judgeFullScreenSend(this.$app.$def.textValueOther);
        //      // 全屏页面的时候使用
        //      this.fullScreenSend();
        //    }
        //    // 转发发送
        //    this.transmitSend();
        //    // 外部应用获取数据
        //    this.dataFromPick();
    }

    onHide() {
        this.unSubscribeDetail();
    }

    initData() {
        this.strMsgDeleteDialogTip = $r('app.string.msg_delete_dialog_tip2',
            this.selectDeleteMsgCount
        );
        this.tabTextList = [
            //      $r('app.string.msg_take_photos'),
            //      $r('app.string.msg_picture'),
            //      $r('app.string.msg_record'),
            //      $r('app.string.more_low')
        ];
        this.animationOptions = {
            duration: ANIMATION_DURATION,
            easing: 'linear',
            fill: 'forwards',
            iterations: 'Infinity',
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
        //    this.pattern = $r('app.string.camera_post');
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
        this.isNewMsg = false;
        this.mmsList = [];
    }

    initNewPageContracts() {
        let transmitContracts = [];
        if (this.strContactsNumber) {
            let contactsNames = this.strContactsName.split(',');
            let telephones = this.strContactsNumber.split(',');
            let telephoneFormat = this.strContactsNumberFormat.split(',');
            for (let index in contactsNames) {
                let item: LooseObject = {};
                item.contactName = contactsNames[index];
                item.telephone = telephones[index];
                if (contactsNames[index] == common.string.EMPTY_STR && telephoneFormat[index] == common.string.EMPTY_STR) {
                    item.telephoneFormat = telephones[index];
                } else {
                    item.telephoneFormat = telephoneFormat[index];
                }
                item.headImage = common.string.EMPTY_STR;
                item.select = false;
                transmitContracts.push(item);
            }
        }
        this.paramContact.transmitContracts = transmitContracts;
        this.paramContact.isSelectContact = false;
        this.paramContact.isNewRecallMessagesFlag = false;
    }

    initRouterData() {
        this.strContactsName =
            router.getParams().strContactsName == undefined ? '' : router.getParams().strContactsName;
        this.strContactsNumber =
            router.getParams().strContactsNumber == undefined ? '' : router.getParams().strContactsNumber;
        this.strContactsNumberFormat =
            router.getParams().strContactsNumberFormat == undefined ? '' : router.getParams().strContactsNumberFormat;
        this.contactsNum = router.getParams().contactsNum == undefined ? 0 : router.getParams().contactsNum;
        this.threadId = router.getParams().threadId == undefined ? 0 : router.getParams().threadId;
        this.isDraft = router.getParams().isDraft == undefined ? false : router.getParams().isDraft;
        this.draftContent = router.getParams().draftContent == undefined ? '' : router.getParams().draftContent;
        this.searchContent = router.getParams().searchContent == undefined ? '' : router.getParams().searchContent;
        this.isNewMsg = router.getParams().isNewMsg == undefined ? false : router.getParams().isNewMsg;
    }

    titleBarCancel() {
        // 取消按钮
        this.cancleCheckedAll();
        this.setSelectStatus(false);
    }

    onBackPress() {
        //    // 系统返回键,true代表拦截
        //    if (this.tabSlideStatus != 0) {
        //      // tab全屏
        //      this.restoreTabSlideStatus();
        //      return true;
        //    }
        //    if (this.isShowMoreOperation) {
        //      // tab显示状态
        //      this.setTabOperationStatus(false);
        //      this.distanceBottomFlag = false;
        //      return true;
        //    }
        if (this.isSelectStatus) {
            // 多选状态
            this.isSelectStatus = false;
            this.cancleCheckedAll();
            return true;
        }
        let source = this.getMmsSource();
        // 不存在草稿或者需要更新草稿的操作
        this.insertAndUpdateSessionDraft(source);
        // 存在草稿的情况下，需要做下面的操作
        this.dealSessionDraft(source);
        this.release();
        return false;
    }

    titleBarBack() {
        //    if (this.tabSlideStatus != 0) {
        //      // tab全屏
        //      this.restoreTabSlideStatus();
        //      return;
        //    }
        //    if (this.isShowMoreOperation) {
        //      // tab显示状态
        //      this.setTabOperationStatus(false);
        //      this.distanceBottomFlag = false;
        //      return;
        //    }
        if (this.isSelectStatus) {
            // 多选状态
            this.isSelectStatus = false;
            this.cancleCheckedAll();
            return;
        }
        let source = this.getMmsSource();
        // 不存在草稿或者需要更新草稿的操作
        this.insertAndUpdateSessionDraft(source);
        // 存在草稿的情况下，需要做下面的操作
        this.dealSessionDraft(source);
        this.release();
        router.back();
    }

    insertAndUpdateSessionDraft(source) {
        let hasReport = settingService.judgeIsDeliveryReport(this.isEditMms);
        let hasAttachment = commonService.judgeIsAttachment(source);
        let actionData: LooseObject = {};
        actionData = {
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
        // 新建页面 草稿数据，需要进行保存
        if (this.isNewMsg && (this.textValue != common.string.EMPTY_STR || source.length !== 0)) {
            actionData.isNewMsg = true;
            HiLog.i(TAG, 'insertAndUpdateSessionDraft, isNewMsg=true')
            // 如果选择联系人不为空
            if (this.selectContacts.length > 0) {
                actionData.selectContacts = this.selectContacts;
                conversationListService.insertSessionDraft(actionData);
            }
            // 如果收件人输入栏不为空
            else if (this.receiveContactValue != common.string.EMPTY_STR) {
                actionData.receiveContactValue = this.receiveContactValue;
                conversationListService.insertSessionDraft(actionData);
            }
        }
        // 这里不是新建的场景
        else if (this.textValue != common.string.EMPTY_STR || source.length !== 0) {
            actionData.isNewMsg = false;
            actionData.telephone = this.strContactsNumber;
            HiLog.i(TAG, 'insertAndUpdateSessionDraft, isNewMsg=false')
            conversationListService.insertSessionDraft(actionData);
        }
    }

    dealSessionDraft(source) {
        // 新建存在草稿，只要选择的联系人或者内容为空,就要将草稿删除
        if (this.isNewMsg && this.isDraft) {
            HiLog.i(TAG, 'dealSessionDraft, start')
            if ((this.selectContacts.length == 0 && this.receiveContactValue == common.string.EMPTY_STR)
            || (this.textValue == common.string.EMPTY_STR && source.length == 0)) {
                let threadIds = [this.threadId];
                conversationListService.deleteMessageBySessionId(threadIds);
                this.deleteDraftData();
            }
        }

        // 设置草稿逻辑,文本内容为空,并且不是新建页面,需要更新会话列表数据
        if (!this.isNewMsg && this.isDraft && (this.textValue == common.string.EMPTY_STR && source.length == 0)) {
            // 先查询出列表中最后一个内容
            let length = this.mmsList.length;
            let item = this.mmsList[length - 1];
            // 在更新列表数据
            let threadIds = [this.threadId];
            let time = new Date();
            let content = item.content;
            let hasAttachment = false;
            if (item.isMsm) {
                content = commonService.getMmsContent(item.mms);
                hasAttachment = commonService.judgeIsAttachment(source);
            }
            let valueBucket = {
                'content': item.content,
                'has_draft': 0,
                'time': time.getTime(),
                'has_mms': item.isMsm ? 1 : 0,
                'has_attachment': hasAttachment ? 1 : 0
            }
            conversationListService.updateById(threadIds, valueBucket);
            this.deleteDraftData();
            this.isDraft = false;
        }
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
        HiLog.i(TAG, 'setMessageCheckAll, isSelectStatus=' + this.isSelectStatus);
        if (!this.isSelectStatus) {
            return;
        }
        if (type == common.int.CHECKBOX_SELECT_ALL) {
            HiLog.i(TAG, 'setMessageCheckAll, CHECKBOX_SELECT_ALL');
            this.selectDeleteMsgCount = this.mmsList.length;
            this.isMessageCheckAll = true;
            this.hasReport = false;
            let countLock = 0;
            // 判断一下是不是全部都被锁定
            for (let element of this.mmsList) {
                if (element.isCbChecked && element.isLock) {
                    countLock++;
                }
            }
            if (this.selectDeleteMsgCount == countLock) {
                this.hasLock = true;
            }
        } else if (type == common.int.CHECKBOX_SELECT_NONE) {
            HiLog.i(TAG, 'setMessageCheckAll, CHECKBOX_SELECT_NONE');
            this.selectDeleteMsgCount = 0;
            this.isMessageCheckAll = false;
            this.hasLock = false;
            this.hasReport = false;
        } else {
            // 默认为 CHECKBOX_SELECT_UNKNOWN,判断是否有未选中
            HiLog.i(TAG, 'setMessageCheckAll, else');
            this.checkBoxSelectUnknow();
        }
    }

    checkBoxSelectUnknow() {
        HiLog.i(TAG, 'checkBoxSelectUnknow, start');
        // 默认为 CHECKBOX_SELECT_UNKNOWN,判断是否有未选中
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
        // 如果选择的是一个，并且存在锁
        if (this.selectDeleteMsgCount == 1 && countLock > 0) {
            this.hasLock = true;
        } else {
            this.hasLock = false;
        }
        // 如果全部选中了，并且全部锁定了
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
        // API 7的时候，这个isOn不是boolean类型，打印出来是number类型，直接使用会有问题
        let isCheck: string = e
        //    this.messageList[index].isCbChecked = isCheck == '1' ? true : false;
        let item = this.mmsList[index];
        item.isCbChecked = isCheck == '1' ? true : false;
        HiLog.i(TAG, 'listCheckBoxChange, isCbChecked=' + item.isCbChecked + ', index=' + index + ', mmsIndex=' + this.mmsIndex);
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
            // 复制
                this.copyText();
                break;
            case 1:
            // 转发
            //        this.transmitMsgSingle();
                break;
            case 2:
            // 删除
                this.deleteDialogShow();
                break;
            case 3:
            // 选择文本
                this.gotoTextSelect(this.mmsIndex);
                break;
            case 4:
            // 更多
                this.more();
                break;
            case 5:
            // 保存
                this.saveImage();
                break;
            default:
                break;
        }
    }
    // 删除弹框提示
    deleteDialogShow() {
        this.strMsgDeleteDialogTip = $r("app.string.msg_delete_dialog_tip1");
        let item = this.mmsList[this.mmsIndex];
        item.isShowMsgLongMenu = false
        HiLog.i(TAG, 'deleteDialogShow, isShowMsgLongMenu=' + item.isShowMsgLongMenu);
        this.hasLockMsg = item.isLock;
        this.deleteDialog();
        if (!item.isMsm) {
            this.hasContent = true;
            return;
        }
    }
    // 更多
    more() {
        this.setTabOperationStatus(false);
        this.distanceBottomFlag = false;
        let item = this.mmsList[this.mmsIndex];

        item.isCbChecked = !item.isCbChecked;
        item.isShowMsgLongMenu = false;
        HiLog.i(TAG, 'more, isShowMsgLongMenu=' + item.isShowMsgLongMenu);
        this.setSelectStatus(true);
        this.hasDetailDelete = false;
        this.setMessageCheckAll(common.int.CHECKBOX_SELECT_UNKNOWN);
        this.hasReport = item.hasReport;
        this.setGroupMoreMenu(item);
    }

    setTabOperationStatus(flag) {
        this.isShowMoreOperation = flag;
        // 数值类,hml页面才会刷新
        if (flag) {
            this.sendBarMarginBottom = common.int.TAB_HEIGHT;
        } else {
            this.sendBarMarginBottom = 0;
        }
    }

    setSelectStatus(isSelect) {
        this.isSelectStatus = isSelect;
    }
    // 短信内容长按事件
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
            //      menuId = 'menu_long_press_mms';
        } else {
            //      menuId = 'menu_long_press';
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
        // 取消弹出
        this.isSelectLockMsg = false;
        HiLog.i(TAG, 'deleteDialogCancel, isSelectLockMsg=false')
    }

    deleteDialogConfirm() {
        let groupIds = [];
        let mmsListCopy = [];
        HiLog.i(TAG, 'deleteDialogConfirm, isSelectStatus=' + this.isSelectStatus);
        if (this.isSelectStatus) {
            // 通过filter删除选中的item
            for (let element of this.mmsList) {
                if (!element.isCbChecked || (element.isLock && !this.isSelectLockMsg)) {
                    mmsListCopy.push(element);
                } else {
                    groupIds.push(element.groupId);
                }
            }
            // 设置为非多选状态
            this.setSelectStatus(false);
            this.mmsList = mmsListCopy;
        } else if (!this.mmsList[this.mmsIndex].isLock || this.isSelectLockMsg) {
            let item = this.mmsList[this.mmsIndex];
            for (let i = 0; i < this.mmsList.length; i++) {
                if (this.mmsIndex == i) {
                    continue;
                } else {
                    mmsListCopy.push(this.mmsList[i]);
                }
            }
            this.mmsList = mmsListCopy;
            HiLog.i(TAG, 'deleteDialogConfirm, mmsList.length=' + this.mmsList.length);
            groupIds.push(item.groupId);
        }
        this.isSelectLockMsg = false;
        this.cancleCheckedAll();
        if (groupIds.length > 0) {
            this.deleteMessageByGroupIds(groupIds);
            // 判断删除后list长度是否为0
            if (this.mmsList.length === 0 && this.textValue === common.string.EMPTY_STR) {
                router.back();
                this.deleteMessageById(this.threadId);
            } else {
                this.updateSessionLock(false);
                this.updateLastItemContent();
            }
        }
        // 删除完成之后，需要判断数据是否全部删除
    }

    deleteMessageByGroupIds(groupIds) {
        let actionData = {
            groupIds: groupIds,
        };
        // 这里调用数据库的删除方法
        conversationService.deleteMessageByGroupIds(actionData);
    }
    // 更新会话列表的锁状态
    updateSessionLock(isLock) {
        let threadIds = [this.threadId];
        let hasLock = isLock ? 1 : 0;
        let valueBucket = {
            'has_lock': hasLock,
        }
        if (!isLock) {
            // 如果是取消锁定,必须是全部取消锁定,才可以将状态进行解锁
            let unlockCount = 0;
            for (let element of this.mmsList) {
                if (!element.isLock) {
                    unlockCount++;
                }
            }
            if (unlockCount != this.mmsList.length) {
                HiLog.w(TAG, 'updateSessionLock, it is not all select unlock');
                return;
            }
        }
        // 如果是锁定，将状态更新为锁定
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
        // 删除数据库数据
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
            this.strMsgDeleteDialogTip = $r("app.string.msg_delete_dialog_tip1");
        } else if (this.selectDeleteMsgCount == this.mmsList.length) {
            this.strMsgDeleteDialogTip = $r("app.string.msg_delete_dialog_tip3");
        } else {
            this.strMsgDeleteDialogTip = $r("app.string.msg_delete_dialog_tip2", this.selectDeleteMsgCount);
        }
        this.hasLockMsg = (this.mmsList.some((element, index) => element.isCbChecked && element.isLock));
        this.deleteDialog();
    }

    deleteDialog() {
        AlertDialog.show(
            {
                message: this.strMsgDeleteDialogTip,
                alignment: DialogAlignment.Bottom,
                offset: {
                    dx: 0, dy: -30
                },
                primaryButton: {
                    value: $r("app.string.cancel"),
                    action: () => {
                        this.deleteDialogCancel()
                    }
                },
                secondaryButton: {
                    value: $r("app.string.delete"),
                    fontColor: Color.Red,
                    action: () => {
                        this.deleteDialogConfirm()
                    }
                },
                cancel: () => {
                    HiLog.i(TAG, 'deleteDialog, cancel')
                }
            }
        )
    }
    // 判断联系人是否存在
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
       * 获取信息详情
       * @param params 电话号码/会话id
       * @param callback 返回信息内容
       * @return
       */
    // 查询信息会话列表
    queryMessageDetail(telephone, threadId) {
        HiLog.i(TAG, 'queryMessageDetail, start');
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
                this.initIsShowMsgLongMenu(result)
                this.dealMessageDetailTime(result);
                this.dealMessageDetailContent(result);
                if (this.mmsList.length == 0 && this.isDraft) {
                    HiLog.i(TAG, 'queryMessageDetail, isNewMsg = true');
                    this.isNewMsg = true;
                    return;
                }
            } else {
                HiLog.w(TAG, 'queryMessageDetail, failed');
            }
            this.deleteDraftData();
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
                strContent = $r('app.string.msg_theme') + ': ' + content;
            }
        } else if (showType == common.MESSAGE_SHOW_TYPE.PPT_NO_IMAGE) {
            strContent = (content == common.string.EMPTY_STR) ? $r('app.string.msg_slide') : content;
        } else if (showType == common.MESSAGE_SHOW_TYPE.PPT_IMAGE) {
            if (mmsSource[0].msgType == common.MSG_ITEM_TYPE.THEME && content !== common.string.EMPTY_STR) {
                strContent = $r('app.string.msg_theme') + ': ' + content;
            } else {
                strContent = (content == common.string.EMPTY_STR) ? $r('app.string.msg_slide') : content;
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
                dateUtil.convertTimeStampToDateWeek(item, false);
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
            let placeholder = $r('app.string.enter_text');
            if (source.msgType == common.MSG_ITEM_TYPE.THEME) {
                placeholder = $r('app.string.msg_theme');
            } else if (mmsSource[0].msgType == common.MSG_ITEM_TYPE.THEME && mmsSource.length == 2) {
                if (mmsObj) {
                    placeholder = $r('app.string.msg_note_mms2');
                } else {
                    placeholder = $r('app.string.msg_note_mms');
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
        this.receiveContactValue = this.strContactsNumber
        this.setDraft();
        if (item.isMsm) {
            this.isEditMms = true;
            this.setMmsDataSource(item.mms);
        } else {
            this.messageType = common.MESSAGE_TYPE.NORMAL;
        }
    }
    // 设置草稿内容
    setDraft() {
        // 如果是草稿需要配展示草稿内容
        if (this.isDraft) {
            this.textValue = this.draftContent;
            this.canSendMessage = this.haveSimCard;
            //      this.judgeFullScreenSend(this.textValue);
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
        let deliveryReportSwitch = preferences.getValueOfDeliveryReportSwitch();
        HiLog.i(TAG, 'updateDetail, sendStatus=' + sendStatus + ', deliveryReportSwitch=' + deliveryReportSwitch)
        if ((deliveryReportSwitch == common.DELIVERY_REPORTS.SMS_AND_MMS ||
        deliveryReportSwitch == common.DELIVERY_REPORTS.SMS) &&
        sendStatus == common.int.SEND_MESSAGE_SUCCESS) {
            let msg = this.strContactsNumber + ' 已收到消息！'
            this.showToast(msg)
        }
    }

    showToast(msg) {
        Prompt.showToast({
            message: msg,
            duration: 2000,
        });
    }
    // 设置发送状态
    setCanSendMsgStatus() {
        if (this.receiveContactValue == common.string.EMPTY_STR && this.selectContacts && this.selectContacts.length == 0) {
            HiLog.d(TAG, 'setCanSendMsgStatus: ' + this.canSendMessage)
            this.canSendMessage = false;
        }
    }

    initSendTip() {
        if (this.isEditMms) {
            // 彩信
            this.getCurEdtFileSize();
            this.canSendMessage = true;
            // 新建页面 收件人是否未空
            if (this.isNewMsg) {
                this.setCanSendMsgStatus();
            }
            this.msgSendTip = this.curEdtFileSize + COMMON_FILE_SIZE_STRING;
            return;
        }
        this.setSmsTip(this.textValue);
    }

    setSmsTip(str) {
        // 设置短信提示信息
        let len = str.length;
        let msgSize;
        let curCanInputSize;
        if (len == 0) {
            this.canSendMessage = false;
            this.msgSendTip = common.string.EMPTY_STR;
            return;
        } else {
            this.canSendMessage = this.haveSimCard && !this.isFlightMode;
        }
        if (this.isNewMsg) {
            this.setCanSendMsgStatus();
        }
        if (this.checkChinese(str)) {
            msgSize = Math.ceil(len / 70);
            curCanInputSize = len % 70 == 0 ? 0 : 70 - len % 70;
        } else {
            msgSize = Math.ceil(len / 160);
            curCanInputSize = len % 160 == 0 ? 0 : 160 - len % 160;
        }
        this.msgSendTip = curCanInputSize + '/' + msgSize;
    }
    // 获取当前彩信编辑的文件大小
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
        HiLog.i(TAG, 'dealMmsSendResult, start')
        // 彩信发送
        sendResult.sendStatus = common.int.SEND_MESSAGE_SUCCESS;
        item.sendStatus = common.int.SEND_MESSAGE_SUCCESS;
        this.updateDetail(this.threadId, sendResult);
        // 这里会发送下彩信，用于接收使用
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
        HiLog.i(TAG, 'dealSmsSendResult, start')
        sendMsgService.sendMessage(params, (sendStatus) => {
            HiLog.i(TAG, 'dealSmsSendResult, sendMessage sendStatus: ' + sendStatus);
            item.sendStatus = sendStatus;
            if (sendStatus === common.int.SEND_MESSAGE_FAILED) {
                item.failuresNumber = item.failuresNumber + 1;
            }
            item.completeNumber = item.completeNumber + 1;
            sendResult.sendStatus = sendStatus;
            // 更新发送的状态
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
        // 转化为短信
        this.isEditMms = false;
        this.setSmsTip(this.textValue);
        this.showToast($r('app.string.converting_sms'));
    }

    dealSendResult(sendNumber, content, item, initDatas) {
        HiLog.i(TAG, 'dealSendResult, start')
        // 添加发送信息到list中
        for (let i = 0; i < sendNumber.length; i++) {
            let params = {
                slotId: this.slotId,
                destinationHost: sendNumber[i],
                content: content,
            };
            let id = this.getSendMessageId(initDatas, sendNumber[i]);
            let sendResult = {
                id: id,
                telephone: sendNumber[i],
                content: content,
            }
            let count = 0;
            if (!item.isMsm) {
                this.dealSmsSendResult(params, item, sendResult);
            } else {
                this.dealMmsSendResult(sendNumber, item, sendResult);
            }
        }
    }

    insertInitData(sendNumber, content, item, callback) {
        HiLog.i(TAG, 'insertInitData, start')
        let insertSendResults = [];
        for (let i = 0; i < sendNumber.length; i++) {
            let sendResult = {
                telephone: sendNumber[i],
                content: content,
                sendStatus: 1
            }
            if (item.isMsm) {
                sendResult.content = commonService.getMmsContent(item.mmsSource);
            }
            insertSendResults.push(sendResult);
        }
        let hasReport = settingService.judgeIsDeliveryReport(item.isMsm) ? 1 : 0;
        let hasAttachment = commonService.judgeIsAttachment(item.mmsSource);
        let actionData = {
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
        conversationService.insertSessionAndDetail(actionData, callback);
    }

    changeReceiveContactValue(value) {
        this.receiveContactValue = value
    }

    updatePreview(idx) {
        // 删除预览
        HiLog.i(TAG, 'updatePreview, idx: ' + idx);
        // 如果预览这里删除的不是音频(图片或视频)，还需要改变图库缩略图中checkbox的值
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
        // 获取当天是星期几
        HiLog.i(TAG, 'initSendItem, start')
        let item: LooseObject = {};
        item.date = common.string.EMPTY_STR;
        item.time = $r("app.string.justNow");
        item.timeMillisecond = new Date().getTime();
        dateUtil.convertTimeStampToDateWeek(item, false);
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
        this.mmsList.push(item);
        this.refresh = !this.refresh
    }

    getMmsSource() {
        HiLog.i(TAG, 'getMmsSource, start')
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
        HiLog.i(TAG, 'dealTextareaDataSource, start')
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
        HiLog.i(TAG, 'dealMmsEditList, start')
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
        HiLog.i(TAG, 'getMmsSourceFromDataSource, start')
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
        HiLog.i(TAG, 'getMmsSourceByTheme, start')
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
        HiLog.i(TAG, 'getMmsSourceByItem, start')
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
        HiLog.i(TAG, 'getMsgShowType, start')
        let type = common.MESSAGE_SHOW_TYPE.NORMAL;
        let slideString = 'msg_slide';
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
        HiLog.i(TAG, 'getMsgShowTypePpt, start')
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
        HiLog.i(TAG, 'getPPTType, start')
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
        HiLog.i(TAG, 'getMsgShowTypeContent, start')
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
        HiLog.i(TAG, 'getThemeContent, start')
        this.isEditMms = true;
        let content = '';
        let first = this.textareaDatasource[0].textValue;
        let text = this.textareaDatasource[1].textValue;
        if (first !== common.string.EMPTY_STR) {
            content = $r('app.string.msg_theme') + ': ' + first;
        }
        if (text !== common.string.EMPTY_STR) {
            if (content === common.string.EMPTY_STR) {
                content = text;
            } else {
                content = content + '\n' + text;
            }
        }
        return content;
    }

    sendMassMessage(content, item, hosts) {
        HiLog.i(TAG, 'sendMassMessage, start')
        let sendNumber = hosts;
        this.insertInitData(sendNumber, content, item, result => {
            // 处理发送的结果
            this.threadId = result.rowId;
            item.groupId = result.groupId;
            item.id = result.initDatas[0].id;
            this.refresh = !this.refresh
            // 发送及处理发送结果
            this.dealSendResult(sendNumber, content, item, result.initDatas);
        });
    }

    clearMsm() {
        if (this.isEditMms) {
            this.isEditMms = false;
        }
        // 删除彩信发送时候的预览图片
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
        HiLog.i(TAG, 'send, start');
        // 发送按钮置灰，不可发送信息
        if (!this.canSendMessage) {
            HiLog.w(TAG, 'send, canSendMessage=false');
            return;
        }
        // 新建状态切换到会话状态
        if (this.isNewMsg) {
            HiLog.i(TAG, 'send, isNewMsg=true');
            this.newSend();
        }
        this.isSendStatus = true;
        // 发送文本
        if (this.textValue != common.string.EMPTY_STR || this.mmsEditList.length != 0 ||
        this.textareaDatasource.length != 0) {
            this.initSendItem();
        }
        let actionData = {
            slotId: this.slotId,
            destinationHost: this.strContactsNumber,
            content: this.textValue,
            isEditMms: this.isEditMms
        };
        // 真实的发送短信
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
    }

    isPhoneNumber(str) {
        // 判断是否是数字
        let reg = /^\d{1,}$/;
        let pattern = new RegExp(reg);
        return pattern.test(str);
    }

    newSend() {
        // 先校验输入的内容是否有值
        if (this.receiveContactValue != common.string.EMPTY_STR) {
            if (!this.isPhoneNumber(this.receiveContactValue)) {
                // 无效收件人
                this.showToast($r('app.string.invalid_receive', this.receiveContactValue))
                HiLog.w(TAG, 'newSend, PhoneNumber is invalidate');
                //        return;
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
            HiLog.w(TAG, 'newSend, the contact condition is not met.')
            return;
        }
        this.isNewMsg = false;
        // 如果设置取消发送，直接设置为true
        if (this.recallMessagesFlag) {
            this.isNewRecallMessagesFlag = true;
            this.paramContact.isNewRecallMessagesFlag = true;
        }
        // 当新建页面全屏跳转过来，需要获取下列表数据
        if (true) {
            this.queryOldMessageList(this.strContactsNumber);
        }
    }

    queryOldMessageList(telephone) {
        HiLog.i(TAG, 'queryOldMessageList, start');
        if (telephone == common.string.EMPTY_STR) {
            return;
        }
        let number = telephoneUtil.dealTelephoneSort(telephone);
        conversationListService.querySessionByTelephone(number, res => {
            HiLog.i(TAG, 'queryOldMessageList, querySessionByTelephone res.response.id: ' + res.response.id)
            if (res.code == common.int.SUCCESS && res.response.id > 0) {
                this.threadId = res.response.id;
                this.queryMessageDetail(telephone, res.response.id);
            } else {
                this.threadId = 0;
            }
        });
    }

    initNewSelectContacts(selectContacts) {
        HiLog.i(TAG, 'initNewSelectContacts, start');
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
            } else {
                contactsName += (item.telephone + common.string.COMMA);
            }
        }
        this.strContactsNumber = contactsNumber.substring(0, contactsNumber.length - 1);
        this.strContactsName = contactsName.substring(0, contactsName.length - 1);
        this.strContactsNumberFormat = contactsNumberFormat.substring(0, contactsNumberFormat.length - 1);
        this.contactsNum = length;
    }

    handleWithSend(actionData, item) {
        HiLog.i(TAG, "handleWithSend, start")
        // 发送请求处理
        let host = actionData.destinationHost;
        let index = host.indexOf(',');
        let hosts = [];
        if (index == -1) {
            // 单发
            hosts.push(actionData.destinationHost);
        } else {
            // 群发
            hosts = actionData.destinationHost.split(',');
        }
        this.sendMassMessage(actionData.content, item, hosts);
    }

    sendInterval(actionData, mmsList) {
        HiLog.i(TAG, "sendInterval, start");
        // 发送定时器
        let item = mmsList[mmsList.length - 1];
        if (this.recallMessagesFlag) {
            item.intervalSendStatus = true;
            // 点击发送按钮后，秒数倒计时定时器
            item.sendIntervalId = setInterval(function () {
                item.cancelTimeCount--;
            }, 1000);
            // 发送定时器，超过6s发送
            item.sendTimeoutId = setTimeout(() => {
                item.cancelTimeCount = 0;
                // 清除定时器
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
        // 是否显示全屏
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
        // 设置短信的提示
        this.setSmsTip(this.textValue);
    }

    setTabTitleText() {
        // 全局选择的tabTitleText
        if (this.tabIndex != 1) {
            // 非图片页
            this.tabTitleText = this.tabTextList[this.tabIndex];
            return;
        }
        // 图片选择页,显示选择个数size
        let size = 0;
        for (let element of this.pictureListFromGallery) {
            if (element.checkedValue) {
                size++;
            }
        }
        this.tabTitleText = size == 0 ? $r('app.string.msg_unselected_tip') : $r('app.string.msg_selected_tip', {
            number: size
        });
    }
    // 检测发送图标是否可以高亮
    judgeSendBtnCanClicked() {
        if (this.haveSimCard &&
        (this.mmsEditList.length != 0 ||
        this.textValue != common.string.EMPTY_STR ||
        this.textareaDatasource.length !== 0)) {
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
    // 初始化转发数据
    initTransmitMeg() {
        //    if (AppStorage.getTransmitFlag()) {
        //      this.threadId = AppStorage.getThreadId;
        //      this.slotId = AppStorage.getSlotId;
        //      this.contactsNum = AppStorage.getContactsNum;
        //      this.strContactsName = AppStorage.getStrContactsName;
        //      this.strContactsNumber = AppStorage.getStrContactsNumber;
        //      this.strContactsNumberFormat = AppStorage.getStrContactsNumberFormat;
        //      this.initNewPageContracts();
        //    }
    }
    // 订阅公共事件
    subscribeDetail() {
        HiLog.i(TAG, 'subscribeDetail, start');
        let events = [common.string.RECEIVE_TRANSMIT_EVENT]
        let commonEventSubscribeInfo = {
            events: events
        };
        // 创建订阅信息
        commonEvent.createSubscriber(commonEventSubscribeInfo, this.createSubscriberCallBack.bind(this));
    }

    createSubscriberCallBack(err, data) {
        commonEventData = data;
        // 接收到订阅
        commonEvent.subscribe(commonEventData, this.subscriberCallBack.bind(this));
    }

    subscriberCallBack(err, data) {
        HiLog.i(TAG, 'subscriberCallBack, start');
        // 接收短信更新
        setTimeout(() => {
            this.queryMessageDetail(this.strContactsNumber, this.threadId);
            let valueBucket = {
                'unread_count': 0,
            };
            let actionData = {
                threadIds: [this.threadId],
                hasRead: 0,
                valueBucket: valueBucket
            };
            notificationService.cancelMessageNotify(actionData, res => {
                actionData.hasRead = 1;
                conversationListService.markAllAsRead(actionData);
            });
        }, 500);
    }
    // 取消订阅
    unSubscribeDetail() {
        commonEvent.unsubscribe(commonEventData, () => {
            HiLog.i(TAG, 'unSubscribeDetail, unsubscribe');
        });
    }
    // 在选择状态下，点击'更多'后弹出menu，然后选择
    moreSelected(e) {
        HiLog.i(TAG, 'moreSelected, e: ' + JSON.stringify(e))
        switch (e) {
            case '0':
            // 复制
                this.copyText();
                break;
            case 1:
            // 分享
                this.share();
                break;
            case 2:
            // 选择文本
                this.gotoTextSelect(this.mmsIndex);
                break;
            case 3:
            // 锁定
                this.lock();
                break;
            case 4:
            // 显示详情
                this.showDetails();
                break;
            case 5:
            // 取消锁定
                this.unlock();
                break;
            case 6:
            // 查看报告
                this.showReport(this.mmsIndex);
                break;
            case 7:
            // 保存附件
                this.saveImage();
                break;
            case 8:
            // 查询vCard详情
                this.showVcarDetail(this.mmsIndex);
                break;
            default:
                break;
        }
        // 退出多选模式
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
                    HiLog.i(TAG, 'share, gotoShare callback');
                });
            }
        }
    }

    gotoTextSelect(idx) {
        router.push({
            uri: 'pages/text_select/text_select',
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
        // 选择内容锁定
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
                // 多选状态关闭
                that.isSelectStatus = false;
                that.cancleCheckedAll();
                HiLog.i(TAG, 'updateLock, Success');
            } else {
                HiLog.w(TAG, 'updateLock, failed');
            }
        });
        // 更新锁定状态
        this.updateSessionLock(isLock);
    }

    showDetails() {
        for (let index = 0; index < this.mmsList.length; index++) {
            if (this.mmsList[index].isCbChecked == true) {
                var time = this.mmsList[index].timeMillisecond;
                var timeStash = this.getTime(time);
                this.mmsTime = timeStash + this.mmsList[index].time;
                if (this.mmsList[index].msgType == 0) {
                    this.isMmsType = $r('app.string.sms');
                } else {
                    this.isMmsType = $r('app.string.mms');
                }

                if (this.mmsList[index].isReceive) {
                    this.isSendRecipient = true;
                } else {
                    this.isSendRecipient = false;
                }
            }
        }
        //    this.$element('mms_details_dialog').show();
    }

    showReport(mmsIndex) {
        // 查看报告
        let item = this.mmsList[mmsIndex];
        router.push({
            uri: 'pages/query_report/query_report',
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
        actionData.threadId = this.mmsList[this.mmsIndex].threadId;
        actionData.pduId = this.mmsList[this.mmsIndex].pduId;
        conversationService.saveImage(actionData, result => {
            this.showToast(result);
        });
    }

    showVcarDetail(mmsIndex) {

    }

    exitMultiselect() {
        // 退出多选状态
        this.isSelectStatus = false;
        this.cancleCheckedAll();
    }

    longPressMore(e) {
        switch (e) {
            case 0:
            // 删除
                this.deleteDetail();
                break;
            case 1:
            // 新建联系人
                this.createNewContract(this.strContactsNumber);
                break;
            case 2:
            // 保存至已有联系人
                this.existingContact(this.strContactsNumber);
                break;
            case 3:
            // 呼叫前编辑
                this.callEditor(this.strContactsNumber);
                break;
            case 4:
            // 加入黑名单
                this.callEditor(this.strContactsNumber);
                break;
            case 5:
            // 查看联系人
                this.titleBarAvatar();
                break;
            default:
                break;
        }
    }
    // 删除
    deleteDetail() {
        if (this.mmsList.length == 1) {
            this.strMsgDeleteDialogTip = $r('app.string.msg_delete_dialog_tip3');
            this.deleteDialog();
        } else {
            this.hasDetailDelete = false;
            this.isSelectStatus = true;
        }
    }
    // 新建联系人
    createNewContract(number) {
        var actionData: LooseObject = {};
        actionData.phoneNumber = number;
        actionData.pageFlag = common.contractPage.PAGE_FLAG_SAVE_CONTACT;
        this.jumpToContract(actionData);
    }
    // 呼叫前编辑
    callEditor(number) {
        var actionData: LooseObject = {};
        actionData.phoneNumber = number;
        actionData.pageFlag = common.contractPage.PAGE_FLAG_EDIT_BEFORE_CALLING;
        this.jumpToContract(actionData);
    }
    // 保存至已有联系人
    existingContact(number) {
        var actionData: LooseObject = {};
        actionData.phoneNumber = number;
        actionData.pageFlag = common.contractPage.PAGE_FLAG_SAVE_EXIST_CONTACT;
        this.jumpToContract(actionData);
    }
    // 跳转联系人app
    jumpToContract(actionData) {
        let str = commonService.commonContractParam(actionData);
        featureAbility.startAbility(str).then((data) => {
            HiLog.i(TAG, 'jumpToContract, startAbility Success');
        }).catch((error) => {
            HiLog.e(TAG, 'jumpToContract, failed. Cause: ' + JSON.stringify(error.message));
        })
    }
    // 点击联系人头像，跳转至联系人详情
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
        // 打电话
        let param = {
            telephone: telephone
        };
        callService.call(param, result => {
            if (result.code == common.int.SUCCESS) {
                HiLog.i(TAG, 'call, call success');
            } else {
                HiLog.w(TAG, 'call, call failed');
            }
        });
    }
    // 判断字符串是否包含中文
    checkChinese(str) {
        return escape(str).indexOf('%u') != -1;
    }

    getTime(nS) {
        var date = new Date(parseInt(nS));
        var year = date.getFullYear();
        var mon = date.getMonth() + 1;
        var day = date.getDate();
        return year; // + $r('app.string.year') + mon + $r('app.string.month') + day + $r('app.string.day');
    }

    // 新建页面,返回的联系人数据
    setReceiveContactValue(e) {
        this.receiveContactValue = e.contactValue;
        this.setCanSendMessage(this.receiveContactValue)
    }

    setCanSendMessage(/*selectContacts, */receiveContactValue) {
        if (this.textValue != common.string.EMPTY_STR || this.isEditMms) {
            if (this.canSendMessage) {
                if (/*selectContacts.length == 0 && */receiveContactValue == common.string.EMPTY_STR) {
                    this.canSendMessage = false;
                }
            } else if ((/*selectContacts.length != 0 || */receiveContactValue != common.string.EMPTY_STR)
            && this.haveSimCard) {
                this.canSendMessage = true;
            }
        }
    }
}