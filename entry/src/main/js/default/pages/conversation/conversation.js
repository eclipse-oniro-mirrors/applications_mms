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
import mmsLog from '../../../default/utils/MmsLog.js';
// 会话列表
import router from '@system.router';
import Prompt from '@system.prompt';

// JS公共常量
import common from '../common_constants.js'
import {commonPasteboard} from '../../../default/utils/Pasteboard.js';
import commonEvent from '@ohos.commonevent';
import conversationService from '../../service/ConversationService.js';
import callService from '../../service/CallService.js';
import settingService from '../../service/SettingService.js';
import simCardService from '../../service/SimCardService.js';
import contactService from '../../service/ContractService.js';
import conversationListService from '../../service/ConversationListService.js';
import commonService from '../../service/CommonService.js';
import notificationService from '../../service/NotificationService.js';
import telephoneUtil from '../../../default/utils/TelephoneUtil.js';

const ANIMATION_DURATION = 1500;
const TRANSFORM_SCALE_MIN = '1.0';
const TRANSFORM_SCALE_MAX = '3.0';
const COMMON_FILE_SIZE_STRING = '/300KB';
const COMMON_FILE_SIZE = 300;

export default {
    data: {
        // 信息删除提示
        strMsgDeleteDialogTip: '',
        // 点击状态
        isClickStatus: false,
        // 信息是否加锁
        hasLockMsg: false,
        // 选择状态
        isSelectStatus: false,
        // 是否选择加锁信息
        isSelectLockMsg: false,
        // 更多操作
        isShowMoreOperation: false,
        // 判断是否为同一天 默认为 false
        isLessOneDay: false,
        // 判断是否达到全屏条件
        isShowFullScreen: false,
        // 判断是否达全选
        isMessageCheckAll: false,
        // 是否只是录音
        isOnlyAudio: false,
        // 删除个数
        selectDeleteMsgCount: 0,
        // 输入框输入的文本，也是要发送的短信的内容
        textValue: '',
        // 录音动画任务
        drawRecordingTaskId: 0,
        // tab选项页,0拍摄照片,1图片,2录音,3更多
        tabIndex: 1,
        // tab选项页文本内容
        tabTextList: [],
        // 录音状态
        isRecordingStatus: true,
        // 当前录音时间
        curRecordingTime: '00:00',
        // 当前录音文件的大小(KB)
        curSize: 0,
        // 开始录音时间
        startRecordTime: 0,
        // 是否含有sim卡
        haveSimCard: false,
        // 是否显示卡图标
        cardImage: false,
        // 是否飞行模式
        isFlightMode: false,
        // 信息附件大小提示
        msgSendTip: '',
        // 当前能否发送短信
        canSendMessage: false,
        // 当前编辑的是否为彩信
        isEditMms: false,
        // 当前编辑的彩信附件大小
        curEdtFileSize: 0,
        // 获取单选的时间显示
        mmsTime: '',
        // 是否是短信和彩信
        isMmsType: '',
        // 是否收件人
        isSendRecipient: '',
        // 联系人名字
        strContactsName: '',
        // 联系人电话号码
        strContactsNumber: '',
        // 联系人电话号码格式化
        strContactsNumberFormat: '',
        // 附件类型为名片
        isVCard: false,
        // 是否是新建信息
        isNewMsg: false,
        // 联系人数量
        contactsNum: 0,
        // 名片
        vCard: {},
        // 彩信编辑列表
        mmsEditList: [],
        // 信息列表
        mmsList: [],
        // 当前选中信息index
        mmsIndex: 0,
        // 初始x位置
        rawX: '',
        // 初始y位置
        rawY: '',
        // 图库中的缩略图
        pictureListFromGallery: [],
        // 选项卡标题
        tabTitleText: '',
        // 发送工具栏距离底部位置
        sendBarMarginBottom: 0,
        // 选项卡高度
        tabHeight: common.int.TAB_HEIGHT,
        // 恢复任务id
        restoreTimeoutId: 0,
        // 是否真正执行动画
        isTabHeightAnimation: false,
        // 0默认状态,1滑动状态,2全屏状态
        tabSlideStatus: 0,
        // 滑动距离
        slideDistance: 0,
        // 滑动的起点坐标
        slideStartPoint: {
            x: 0,
            y: 0
        },
        // 是否上滑动
        isTabSlideUp: 0,
        // 联系人列表，从联系人app那里获取的，作为发彩信时的附件
        contactListFromContactApp: [],
        // 卡槽
        slotId: 0,
        // 选择的联系人
        selectContacts: [],
        // 收件人输入框内容
        receiveContactValue: '',
        // 给receive传递的参数数据
        paramContact: {},
        // 时间
        mmsDateSet: new Set(),
        // 控制最后div显示与隐藏
        isSendStatus: false,
        // 会话列表的id
        threadId: 0,
        // 是否是详情页面
        isDetail: true,
        // 需要重新发送的下标
        reSendIndex: 0,
        // 复制选项是否可见
        showText: true,
        // 搜索传来的值
        searchKey: '',
        // 是否是草搞
        isDraft: false,
        // 草稿的内容
        draftContent: '',
        draftGroupId: 0,
        // 是否可以双击取消发送
        recallMessagesFlag: false,
        // 双击取消状态
        doubleClickStatus: false,
        // 距离底部的动态变化标志
        distanceBottomFlag: false,
        // 详情页删除
        hasDetailDelete: false,
        // 是否存在联系人
        hasExitContract: false,
        // 新建页面进行取发送
        isNewRecallMessagesFlag: false,
        // 录音动画
        recordingAnimation: null,
        // 动画样式属性
        animationOptions: null,
        // 动画样式属性对象
        animationFrames: null,
        // 默认后置摄像头
        cameraPattern: 'back',
        pattern: '',
        // 是否锁
        hasLock: false,
        // 高亮信息类型
        highlightsType: 0,
        // 高亮信息内容
        highlightsText: '',
        // 公共订阅数据
        commonEventData: {},
        timeFormat: '00:01',
        // 0 - 普通,1 - 通知
        smsType: 0,
        isPicCheckboxClicked: false,
        // 是否支持发送报告
        hasReport: false,
        messageType: common.MESSAGE_TYPE.NORMAL,
        textareaDatasource: [],
        pptTotalCount: 0,
        selectedTextareaIdx: -1,
        hasImage: false,
        hasContent: false,
        hasVcard: false,
        mmsAddType: 0,
        picItemSelectedIndex: -1,
        slideDuration: 5,
        slideDurations: [],
        hasDouble: true,
        searchContent: ''
    },
    onInit() {
        mmsLog.info('JS_conversation: ' + 'onInit()......');
        this.initData();
        if(this.hasDouble) {
            this.initNewPageContracts();
            this.hasDouble = false;
        }
        this.initSendTip();
        this.setTabTitleText();
    },
    onShow() {
        mmsLog.info('JS_conversation: ' + 'onShow()......');
        this.mmsList = [];
        if (this.mmsDateSet.size > 0) {
            this.mmsDateSet.clear();
        }
        let preferences = this.$app.$def.preferences;
        this.haveSimCard = conversationService.judgeHasSimCard(preferences);
        // 判断发送按钮是否可点击
        this.judgeSendBtnCanClicked();
        // 初始化转发的数据
        this.initTransmitMeg();
        // 获取真实数据
        this.queryMessageDetail(this.strContactsNumber, this.threadId);
        // 获取取消发送的状态
        this.getSettingFlagForConvListPage();
        // 订阅PA
        this.subscribeDetail();
        // 判断联系人是否存在
        this.judgeContactExists();
        if (this.$app.$def.isFromFullScreen) {
            this.$app.$def.isFromFullScreen = false;
            // 判断是否是全屏发送
            this.judgeFullScreenSend(this.$app.$def.textValueOther);
            // 全屏页面的时候使用
            this.fullScreenSend();
        }
        // 转发发送
        this.transmitSend();
        // 外部应用获取数据
        this.dataFromPick();
    },
    onHide() {
        this.unSubscribeDetail();
    },
    initData() {
        this.strMsgDeleteDialogTip = this.$t('strings.msg_delete_dialog_tip2', {
            number: this.selectDeleteMsgCount
        });
        this.tabTextList = [
            this.$t('strings.msg_take_photos'),
            this.$t('strings.msg_picture'),
            this.$t('strings.msg_record'),
            this.$t('strings.more_low')
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
        this.pattern = this.$t('strings.camera_post');
        this.initSlideDurations();
    },
    initSlideDurations() {
        let arr = [];
        for (let i = 1; i <= 10; i++) {
            arr.push(i);
        }
        this.slideDurations = arr;
    },
    dataFromPick() {
        let indexPicPage = this.$app.$def.indexInShowPicPage;
        let checkedValuePicPage = this.$app.$def.checkedValueInShowPicPage;
        if (indexPicPage != null && this.pictureListFromGallery[indexPicPage].checkedValue != checkedValuePicPage) {
            this.pictureItemCheckboxOnchange(indexPicPage);
            this.$app.$def.indexInShowPicPage = null;
            this.$app.$def.checkedValueInShowPicPage = null;
        }
        let oneContact = this.$app.$def.oneContactInContactItemPickPage;
        if (oneContact != null) {
            this.contactListFromContactApp[0] = oneContact;
            this.$app.$def.oneContactInContactItemPickPage = null;
            setTimeout(() => {
                this.$element('select_text_or_vcard_to_send_dialog').show();
            }, 200);
        }
    },
    initNewPageContracts() {
        let transmitContracts = [];
        if (this.strContactsNumber) {
            let contactsNames = this.strContactsName.split(',');
            let telephones = this.strContactsNumber.split(',');
            let telephoneFormat = this.strContactsNumberFormat.split(',');
            for (let index in contactsNames) {
                let item = {};
                item.contactName = contactsNames[index];
                item.telephone = telephones[index];
                if (contactsNames[index] == common.string.EMPTY && telephoneFormat[index] == common.string.EMPTY) {
                    item.telephoneFormat = telephones[index];
                } else {
                    item.telephoneFormat = telephoneFormat[index];
                }
                item.headImage = common.string.EMPTY;
                item.select = false;
                transmitContracts.push(item);
            }
        }
        this.paramContact.transmitContracts = transmitContracts;
        this.paramContact.isSelectContact = false;
        this.paramContact.isNewRecallMessagesFlag = false;
    },
    // 设置草稿内容
    setDraft() {
        // 如果是草稿需要配展示草稿内容
        if (this.isDraft) {
            this.textValue = this.draftContent;
            this.canSendMessage = true;
            this.judgeFullScreenSend(this.textValue);
        }
    },
    // 清楚草稿
    cleanDraft() {
        this.isDraft = false;
        this.draftContent = common.string.EMPTY_STR;
    },
    // 全屏发送
    fullScreenSend() {
        var sendFlag = this.$app.$def.sendFlag;
        if (sendFlag) {
            let content = this.textValue;
            this.textValue = common.string.EMPTY_STR;
            this.isShowFullScreen = false;
            this.canSendMessage = false;
            this.newSend();
            setTimeout(() => {
                this.sendSms(content, common.string.EMPTY, this.isEditMms);
            }, 500);
        }
    },
    // 判断是否全屏展示
    judgeFullScreenSend(textValueOther) {
        this.textValue = textValueOther;
        if (this.textValue.length > common.int.FULL_SCREEN_SEND_LENGTH) {
            this.isShowFullScreen = true;
        } else {
            this.isShowFullScreen = false;
        }
    },
    // 初始化转发数据
    initTransmitMeg() {
        if (this.$app.$def.transmitFlag) {
            this.threadId = this.$app.$def.threadId;
            this.slotId = this.$app.$def.slotId;
            this.contactsNum = this.$app.$def.contactsNum;
            this.strContactsName = this.$app.$def.strContactsName;
            this.strContactsNumber = this.$app.$def.strContactsNumber;
            this.strContactsNumberFormat = this.$app.$def.strContactsNumberFormat;
            this.initNewPageContracts();
        }
    },
    // 转发发送
    transmitSend() {
        let transmitFlag = this.$app.$def.transmitFlag;
        let isSlideDetail = this.$app.$def.isSlideDetail;
        if (transmitFlag) {
            if(isSlideDetail) {
                this.isEditMms = true;
                this.mmsTransmitSend();
            } else {
                this.generalTransmitSend();
            }
        }
    },
    generalTransmitSend() {
        let transmitSource = this.$app.$def.transmitSource;
        let isSource = this.$app.$def.isContainerOriginSource;
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
    },
    mmsTransmitSend() {
        let mmsSource = this.$app.$def.mmsSource;
        let content = this.$app.$def.transmitContent;
        let actionData = {
            mmsSource: mmsSource,
            content: content,
            msgUriPath: common.string.EMPTY_STR
        };
        this.delayTransmitSend(actionData, this.isEditMms);
    },
    delayTransmitSend(element, isMms) {
        setTimeout(() => {
            this.sendSms(element.content, element.msgUriPath, isMms, element.mmsSource);
        }, 500);
    },
    // 判断联系人是否存在
    judgeContactExists() {
        let telephones = [this.strContactsNumber];
        let actionData = {
            telephones: telephones,
            featureAbility: this.$app.$def.featureAbility,
            ohosDataAbility: this.$app.$def.ohosDataAbility
        };
        conversationService.judgeContactExists(actionData, result => {
            this.hasExitContract = result;
        });
        if (this.strContactsName == common.string.EMPTY_STR) {
            this.hasExitContract = false;
        } else {
            this.hasExitContract = true;
        }
    },
    // 查询信息会话列表
    queryMessageDetail(telephone, threadId) {
        mmsLog.info('JS_conversation: queryMessageDetail,start');
        let actionData = {};
        if (telephone != common.string.EMPTY) {
            actionData.telephone = telephone;
        }
        if (threadId != common.string.EMPTY) {
            actionData.threadId = threadId;
        }
        actionData.featureAbility = this.$app.$def.featureAbility;
        actionData.ohosDataAbility = this.$app.$def.ohosDataAbility;
        actionData.contactsNum = this.contactsNum;
        conversationService.queryMessageDetail(actionData, result => {
            if (result.code == common.int.SUCCESS) {
                this.dealMessageDetailTime(result);
                this.dealMessageDetailContent(result);
                if (this.mmsList.length == 0 && this.isDraft) {
                    this.isNewMsg = true;
                }
            } else {
                mmsLog.info('JS_conversation: queryMessageDetail(), ' + 'Error: queryAllMessages() failed !!!');
            }
            this.deleteDraftData();
        });
    },
    dealItemContent(showType, content, mmsSource) {
        let strContent = content;
        if (showType == common.MESSAGE_SHOW_TYPE.THEME_NO_IMAGE || showType == common.MESSAGE_SHOW_TYPE.THEME_IMAGE) {
            if (content !== common.string.EMPTY_STR) {
                strContent = this.$t('strings.msg_theme') + ': ' + content;
            }
        } else if (showType == common.MESSAGE_SHOW_TYPE.PPT_NO_IMAGE) {
            strContent = (content == common.string.EMPTY_STR) ? this.$t('strings.msg_slide') : content;
        } else if (showType == common.MESSAGE_SHOW_TYPE.PPT_IMAGE) {
            if (mmsSource[0].msgType == common.MSG_ITEM_TYPE.THEME && content !== common.string.EMPTY_STR) {
                strContent = this.$t('strings.msg_theme') + ': ' + content;
            } else {
                strContent = (content == common.string.EMPTY_STR) ? this.$t('strings.msg_slide') : content;
            }
        }
        return strContent;
    },
    dealMessageDetailContent(result) {
        for (let item of result.response) {
            item.content = this.dealItemContent(item.msgShowType, item.content, item.mms);
        }
    },
    getMmsDataSource(mmsSource, first) {
        this.pptTotalCount = (first.msgType == common.MSG_ITEM_TYPE.THEME) ? -1 : 0;
        let mms = [];
        let textareas = [];
        mmsSource.forEach((source, index) => {
            this.pptTotalCount ++;
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
            let placeholder = this.$t('strings.enter_text');
            if (source.msgType == common.MSG_ITEM_TYPE.THEME) {
                placeholder = this.$t('strings.msg_theme');
            } else if (mmsSource[0].msgType == common.MSG_ITEM_TYPE.THEME && mmsSource.length == 2) {
                if (mmsObj) {
                    placeholder = this.$t('strings.msg_note_mms2');
                } else {
                    placeholder = this.$t('strings.msg_note_mms');
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
    },
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
    },
    dealMessageDetailTime(result) {
        if(result.response && result.response.length > 0) {
            let dateUtil = this.$app.$def.dateUtil;
            let resultList = [];
            for (let item of result.response) {
                item.timeMillisecond = parseInt(item.timeMillisecond);
                dateUtil.convertTimeStampToDateWeek(item, false, this);
                dateUtil.convertDateFormatForItem(item, false, this);
                if(item.sendStatus == common.int.SEND_DRAFT) {
                    this.dealDraftData(item);
                } else {
                    resultList.push(item);
                }
            }
            this.mmsList = resultList;
        }
    },
    dealDraftData(item) {
        this.isDraft = true;
        this.draftContent = item.content;
        this.draftGroupId = item.groupId;
        this.setDraft();
        if (item.isMsm) {
            this.isEditMms = true;
            this.setMmsDataSource(item.mms);
        } else {
            this.messageType = common.MESSAGE_TYPE.NORMAL;
        }
    },
    // 设置发送状态
    setCanSendMsgStatus() {
        if (this.receiveContactValue == common.string.EMPTY && this.selectContacts && this.selectContacts.length == 0) {
            this.canSendMessage = false;
        }
    },
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
    },
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
            mmsLog.info('setSmsTip, canSendMessage:' + this.canSendMessage + 'haveSimCard:' + this.haveSimCard);
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
    },
    // 获取当前彩信编辑的文件大小
    getCurEdtFileSize() {
        this.curEdtFileSize = 0;
        if (!this.isEditMms || this.mmsEditList.length == 0) {
            return;
        }
        for (let element of this.mmsEditList) {
            this.curEdtFileSize += element.fileSize;
        }
    },
    // 判断字符串是否包含中文
    checkChinese(str) {
        return escape(str).indexOf('%u') != -1;
    },
    onBackPress() {
        // 系统返回键,true代表拦截
        if (this.tabSlideStatus != 0) {
            // tab全屏
            this.restoreTabSlideStatus();
            return true;
        }
        if (this.isShowMoreOperation) {
            // tab显示状态
            this.setTabOperationStatus(false);
            this.distanceBottomFlag = false;
            return true;
        }
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
        return false;
    },
    titleBarBack() {
        if (this.tabSlideStatus != 0) {
            // tab全屏
            this.restoreTabSlideStatus();
            return;
        }
        if (this.isShowMoreOperation) {
            // tab显示状态
            this.setTabOperationStatus(false);
            this.distanceBottomFlag = false;
            return;
        }
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
        router.back();
    },
    insertAndUpdateSessionDraft(source) {
        let preferences = this.$app.$def.preferences;
        let hasReport = settingService.judgeIsDeliveryReport(preferences, this.isEditMms);
        let hasAttachment = commonService.judgeIsAttachment(source);
        let actionData = {
            receiveContactValue: common.string.EMPTY_STR,
            selectContacts: [],
            content: this.textValue,
            rdbStore: this.$app.$def.rdbStore,
            featureAbility: this.$app.$def.featureAbility,
            isReceive: false,
            ownNumber: common.string.EMPTY_STR,
            isSender: 0,
            hasDraft: 1,
            hasReport: hasReport,
            isMms : this.isEditMms,
            mmsSource: source,
            ohosDataAbility: this.$app.$def.ohosDataAbility,
            groupId: this.draftGroupId,
            messageType: this.messageType,
            hasAttachment: hasAttachment
        }
        let conversationListService = this.$app.$def.conversationListService;
        // 新建页面 草稿数据，需要进行保存
        if (this.isNewMsg && (this.textValue != common.string.EMPTY_STR || source.length !== 0)) {
            actionData.isNewMsg = true;
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
        else if (this.textValue != common.string.EMPTY_STR  || source.length !== 0) {
            actionData.isNewMsg = false;
            actionData.telephone = this.strContactsNumber;
            conversationListService.insertSessionDraft(actionData);
        }
    },
    dealSessionDraft(source) {
        // 新建存在草稿，只要选择的联系人或者内容为空,就要将草稿删除
        if (this.isNewMsg && this.isDraft) {
            if ((this.selectContacts.length == 0 && this.receiveContactValue == common.string.EMPTY_STR)
            || (this.textValue == common.string.EMPTY_STR && source.length == 0)) {
                let conversationListService = this.$app.$def.conversationListService;
                let rdbStore = this.$app.$def.rdbStore;
                let threadIds = [this.threadId];
                conversationListService.deleteMessageBySessionId(rdbStore, threadIds);
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
            if(item.isMsm) {
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
            let conversationListService = this.$app.$def.conversationListService;
            let rdbStore = this.$app.$def.rdbStore;
            conversationListService.updateById(rdbStore, threadIds, valueBucket);
            this.deleteDraftData();
            this.isDraft = false;
        }
    },
    // 点击联系人头像，跳转至联系人详情
    titleBarAvatar() {
        var actionData = {
            phoneNumber: this.strContactsNumber,
            pageFlag: common.contractPage.PAGE_FLAG_CONTACT_DETAILS
        };
        this.jumpToContract(actionData);
    },
    mmsListLongPress(index) {
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
            menuId = 'menu_long_press_mms';
        } else {
            menuId = 'menu_long_press';
        }
        this.mmsIndex = index;
        setTimeout(() => {
            this.$element(menuId).show({
                x: this.rawX,
                y: this.rawY
            });
        },100);
    },
    msgSendBarMore() {
        this.setTabOperationStatus(!this.isShowMoreOperation);
        if (this.isShowMoreOperation) {
            this.distanceBottomFlag = true;
            if (this.tabIndex == 1) {
                this.queryFromGallery();
            }
        } else {
            this.distanceBottomFlag = false;
        }
        this.$element('isInputMethod').focus({
            focus: false
        });
        setTimeout(() => {
            this.$element('conversationList').scrollBottom({
                smooth: false
            });
        }, 200);
    },
    touchStart(e) {
        this.rawX = e.touches[0].globalX;
        this.rawY = e.touches[0].globalY;
    },
    changeValue(e) {
        this.isInputMethod = true;
        this.textValue = e.text;
        if (e.text == null || e.text == common.string.EMPTY) {
            if (this.mmsEditList.length != 0) {
                this.canSendMessage = true;
            } else {
                this.canSendMessage = false;
            }
            return;
        }
        // 是否显示全屏
        if (this.isEditMms || e.lines < 4) {
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
    },
    touchChange() {
        // 点击输入栏后 更多栏关闭
        this.setTabOperationStatus(false);
        this.distanceBottomFlag = false;
    },
    setTabOperationStatus(flag) {
        this.isShowMoreOperation = flag;
        // 数值类,hml页面才会刷新
        if (flag) {
            this.sendBarMarginBottom = common.int.TAB_HEIGHT;
        } else {
            this.sendBarMarginBottom = 0;
        }
    },
    isPhoneNumber(str) {
        // 判断是否是数字
        let reg = /^\d{1,}$/;
        let pattern = new RegExp(reg);
        return pattern.test(str);
    },
    send() {
        mmsLog.info('JS_conversation: send button action');
        // 发送按钮置灰，不可发送信息
        if (!this.canSendMessage) {
            return;
        }
        // 新建状态切换到会话状态
        if (this.isNewMsg) {
            this.newSend();
        }
        this.isSendStatus = true;
        // 发送文本
        if (this.textValue != common.string.EMPTY || this.mmsEditList.length != 0 ||
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
    },
    resetMmsSource() {
        this.textareaDatasource = [];
        this.mmsEditList = [];
        this.pptTotalCount = 0;
        this.messageType = common.MESSAGE_TYPE.NORMAL;
        this.selectedTextareaIdx = -1;
    },
    deleteDraftData() {
        if (this.isDraft && this.draftGroupId > 0) {
            let groupIds = [this.draftGroupId];
            this.deleteMessageByGroupIds(groupIds);
            this.draftGroupId = 0;
        }
    },
    getThemeContent() {
        this.isEditMms = true;
        let content = '';
        let first = this.textareaDatasource[0].textValue;
        let text = this.textareaDatasource[1].textValue;
        if (first !== common.string.EMPTY_STR) {
            content = this.$t('strings.msg_theme') + ': ' + first;
        }
        if (text !== common.string.EMPTY_STR) {
            if (content === common.string.EMPTY_STR) {
                content = text;
            } else {
                content = content  + '\n' + text;
            }
        }
        return content;
    },
    getPPTType() {
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
    },
    getMsgShowType(item) {
        let type = common.MESSAGE_SHOW_TYPE.NORMAL;
        let slideString = this.$t('strings.msg_slide');
        if (this.messageType === common.MESSAGE_TYPE.NORMAL && this.mmsEditList.length <= 1) {
            type = common.MESSAGE_SHOW_TYPE.NORMAL;
            item.content = this.textValue;
        } else if (this.messageType === common.MESSAGE_TYPE.THEME && this.mmsEditList.length === 1) {
            type = common.MESSAGE_SHOW_TYPE.THEME_IMAGE;
            item.content = this.getThemeContent();
        } else {
            type = this.getgetMsgShowTypePpt(item, slideString);
        }
        if (type == common.MESSAGE_SHOW_TYPE.PPT_NO_IMAGE || type == common.MESSAGE_SHOW_TYPE.PPT_IMAGE) {
            if (item.content == common.string.EMPTY_STR) {
                item.content = slideString;
            }
        }
        return type;
    },
    getgetMsgShowTypePpt(item, slideString) {
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
            this.getgetMsgShowTypeContent(item, firstStr, slideString);
        }
        return type;
    },
    getgetMsgShowTypeContent(item, firstStr, slideString) {
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
    },
    getMmsSourceByTheme(sources, item, mms) {
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
    },
    getMmsSourceByItem(sources, mms) {
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
    },
    getMmsSourceFromDataSource() {
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
    },
    dealTextareaDataSource() {
        if (this.messageType == common.MESSAGE_TYPE.THEME) {
            let first = this.textareaDatasource[0];
            if (first.textValue == common.string.EMPTY_STR) {
                this.messageType = common.MESSAGE_TYPE.NORMAL;
                this.textValue = this.textareaDatasource[1].textValue;
                this.textareaDatasource = [];
            }
        }
    },
    getMmsSource() {
        let sources = [];
        this.dealTextareaDataSource();
        if (this.messageType === common.MESSAGE_TYPE.NORMAL) {
            sources = this.dealMmsEditList();
        } else {
            sources = this.getMmsSourceFromDataSource();
        }
        return sources;
    },
    dealMmsEditList() {
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
    },
    initSendItem(){
        // 获取当天是星期几
        let item = {};
        let dataUtil = this.$app.$def.dateUtil;
        item.date = common.string.EMPTY_STR;
        item.time = this.$t('strings.just_now');
        item.timeMillisecond = new Date().getTime();
        dataUtil.convertTimeStampToDateWeek(item, false, this);
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
        let preferences = this.$app.$def.preferences;
        item.hasReport = settingService.judgeIsDeliveryReport(preferences, item.isMsm);
        item.msgShowType = this.getMsgShowType(item);
        item.mmsSource = this.getMmsSource();
        item.isMsm = this.isEditMms;
        this.mmsList.push(item);
    },
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
    },
    deletePreview(index) {
        this.updatePreview(index);
        let deleteObj = this.mmsEditList[index];
        this.textareaDatasource = this.textareaDatasource.filter(item => {
            if (item.mms && item.mms.index === deleteObj.index) {
                item.mms = null;
            }
            return item;
        });
        this.mmsEditList.splice(index, 1);
        if (this.mmsEditList.length == 0) {
            this.judgeFullScreenSend(this.textValue);
            if (this.textValue == common.string.EMPTY && this.textareaDatasource.length == 0) {
                this.canSendMessage = false;
            }
            if (this.textareaDatasource.length == 0) {
                this.convertingSms();
            }
        }
    },
    sendInterval(actionData, mmsList) {
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
    },
    handleWithSend(actionData, item) {
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
    },
    sendMassMessage(content, item, hosts) {
        let sendNumber = hosts;
        this.insertInitData(sendNumber, content, item, result => {
            mmsLog.info('sendMassMessage, insertInitData:' + result);
            // 处理发送的结果
            this.threadId = result.rowId;
            item.groupId = result.groupId;
            item.id = result.initDatas[0].id;
            // 发送及处理发送结果
            this.dealSendResult(sendNumber, content, item, result.initDatas);
        });
    },
    insertInitData(sendNumber, content, item, callback) {
        let insertSendResults = [];
        for (let i = 0; i < sendNumber.length; i++) {
            let sendResult = {
                telephone: sendNumber[i],
                content: content,
                sendStatus: 1
            }
            if(item.isMsm) {
                let commonService = this.$app.$def.commonService;
                sendResult.content = commonService.getMmsContent(item.mmsSource);
            }
            insertSendResults.push(sendResult);
        }
        let preferences = this.$app.$def.preferences;
        let hasReport = settingService.judgeIsDeliveryReport(preferences, item.isMsm) ? 1 : 0;
        let hasAttachment = commonService.judgeIsAttachment(item.mmsSource);
        let actionData = {
            rdbStore: this.$app.$def.rdbStore,
            featureAbility: this.$app.$def.featureAbility,
            ohosDataAbility: this.$app.$def.ohosDataAbility,
            sendResults: insertSendResults,
            isReceive: false,
            ownNumber: common.string.EMPTY_STR,
            isSender: 0,
            hasDraft: this.isDraft,
            hasReport: hasReport,
            isMms : item.isMsm,
            mmsSource: item.mmsSource,
            hasAttachment: hasAttachment
        }
        conversationService.insertSessionAndDetail(actionData, callback);
    },
    dealSendResult(sendNumber, content, item, initDatas) {
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
            let sendMsgService = this.$app.$def.sendMsgService;
            let count = 0;
            if(!item.isMsm) {
                this.dealSmsSendResult(params, item, sendResult);
            } else {
                this.dealMmsSendResult(sendNumber, item, sendResult);
            }
        }
    },
    dealSmsSendResult(params, item, sendResult) {
        let sendMsgService = this.$app.$def.sendMsgService;
        sendMsgService.sendMessage(params, (sendStatus) => {
            mmsLog.info('sendMessage, sendStatus:' + sendStatus);
            item.sendStatus = sendStatus;
            if (sendStatus === common.int.SEND_MESSAGE_FAILED) {
                item.failuresNumber = item.failuresNumber + 1;
            }
            item.completeNumber = item.completeNumber + 1;
            sendResult.sendStatus = sendStatus;
            // 更新发送的状态
            this.updateDetail(this.threadId, sendResult);
        });
    },
    dealMmsSendResult(sendNumber, item, sendResult) {
        // 彩信发送
        sendResult.sendStatus = common.int.SEND_MESSAGE_SUCCESS;
        item.sendStatus = common.int.SEND_MESSAGE_SUCCESS;
        this.updateDetail(this.threadId, sendResult);
        // 这里会发送下彩信，用于接收使用
        if(sendNumber.length == 1 && sendResult.sendStatus == common.int.SEND_MESSAGE_SUCCESS) {
            setTimeout(() => {
                this.publishData(sendResult.telephone, item.mmsSource);
            }, 1000);
        }
        let sendMsgService = this.$app.$def.sendMsgService;
        let params = {
            mmsSource: item.mmsSource
        };
        sendMsgService.sendMmsMessage(params,  (sendStatus) => {});
    },
    publishData(telephone, mmsSource) {
        let actionData = {};
        actionData.telephone = telephone;
        actionData.mmsSource = mmsSource;
        // 发布给谁 notification 弹窗  发出去后应用是否能接收
        mmsLog.log('conversation.js ---> receive_message.publishData start:' + actionData);
        commonEvent.publish(common.string.MMS_SUBSCRIBER_EVENT, {
            bundleName: common.string.BUNDLE_NAME,
            isOrdered: false,
            data: JSON.stringify(actionData)
        }, (res) => {
            mmsLog.log('receive_message.publish callback res: ' + JSON.stringify(res));
        });
    },
    updateDetail(threadId, sendResult) {
        let sendResults = [];
        sendResults.push(sendResult);
        let actionData = {
            rdbStore: this.$app.$def.rdbStore,
            featureAbility: this.$app.$def.featureAbility,
            ohosDataAbility: this.$app.$def.ohosDataAbility,
            sendResults: sendResults,
            threadId: threadId
        }
        conversationService.updateSessionAndDetail(actionData);
    },
    getSendMessageId(initDatas, telephone) {
        for (let initData of initDatas) {
            if (initData.telephone == telephone) {
                return initData.id;
            }
        }
    },
    newSend() {
        mmsLog.info('newSend,selectContacts,size:' + this.selectContacts.length);
        // 先校验输入的内容是否有值
        if (this.receiveContactValue != common.string.EMPTY_STR) {
            if (!this.isPhoneNumber(this.receiveContactValue)) {
                // 无效收件人
                this.showToast(this.$t('strings.invalid_receive', {
                    str: this.receiveContactValue
                }));
                return;
            }
        }
        if(this.selectContacts.length > 0 && this.receiveContactValue != common.string.EMPTY_STR) {
            let selectContact = {
                telephone : this.receiveContactValue,
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
            return;
        }
        this.isNewMsg = false;
        // 如果设置取消发送，直接设置为true
        if (this.recallMessagesFlag) {
            this.isNewRecallMessagesFlag = true;
            this.paramContact.isNewRecallMessagesFlag = true;
        }
        // 当新建页面全屏跳转过来，需要获取下列表数据
        if (this.$app.$def.sendFlag) {
            this.queryOldMessageList(this.strContactsNumber);
        }
    },
    initNewSelectContacts(selectContacts) {
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
    },
    changeTabs(e) {
        this.tabIndex = e.index;
        this.setTabTitleText();
        if (this.tabIndex == common.MESSAGE_TAB_INDEX.TAB_AUDIO) {
            this.setRecordingStatus(false);
        } else if (this.tabIndex == common.MESSAGE_TAB_INDEX.TAB_PICTURE) {
            this.queryFromGallery();
        }
    },
    setRecordingStatus(flag) {
        this.isRecordingStatus = flag;
    },
    // 双击取消发送或者进入选择文本
    intentTextSelect(index) {
        let element = this.mmsList[index];
        // 双击取消发送
        if (this.recallMessagesFlag && element.cancelTimeCount > 0) {
            if (!this.doubleClickStatus) {
                this.doubleClickStatus = true;
                setTimeout(() => {
                    this.doubleClickStatus = false;
                }, 500);
                return;
            } else {
                this.textValue = element.content;
                if (this.textValue != common.string.EMPTY && !element.isMsm) {
                    this.judgeFullScreenSend(this.textValue);
                }
                this.mmsList.splice(index, 1);
                // 如果列表数据为空，并且是从新建页面传递过来的，返回新建页面
                this.dealNewRecallMessagesFlag(this.mmsList);
                // 将彩信的数据进行展示
                if (element.isMsm) {
                    // 在这里进行数据填充
                    this.setMmsDataSource(element.mmsSource);
                    this.isEditMms = true;
                }
                // 清除定时器
                clearTimeout(element.sendTimeoutId);
                clearInterval(element.sendIntervalId);
                this.judgeSendBtnCanClicked();
            }
        }
        if (this.isSelectStatus) {
            this.mmsList[index].isCbChecked = !this.mmsList[index].isCbChecked;
            this.setMessageCheckAll(common.int.CHECKBOX_SELECT_UNKNOWN);
            return;
        }
        if (!this.isClickStatus) {
            this.isClickStatus = true
            setTimeout(() => {
                this.isClickStatus = false;
            }, 500);
            return;
        }
        router.push({
            uri: 'pages/text_select/text_select',
            params: this.mmsList[index]
        })
    },
    setSelectStatus(isSelect) {
        this.isSelectStatus = isSelect;
    },
    copyText() {
        commonPasteboard.setPasteboard(this.mmsList[this.mmsIndex].content);
    },
    gotoTextSelect(idx) {
        router.push({
            uri: 'pages/text_select/text_select',
            params: this.mmsList[idx]
        })
    },
    longPressSelected(e) {
        var index = parseInt(e.value);
        switch (index) {
            case 0:
            // 复制
                this.copyText();
                break;
            case 1:
            // 转发
                this.transmitMsgSingle();
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
    },
    saveImage() {
        var actionData = {};
        actionData.threadId = this.mmsList[this.mmsIndex].threadId;
        actionData.pduId = this.mmsList[this.mmsIndex].pduId;
        conversationService.saveImage(actionData, result => {
            this.showToast(result);
        });
    },
    // 单条转发
    transmitMsgSingle() {
        // 单条信息转发
        let item = this.mmsList[this.mmsIndex];
        let transmitObj = {};
        let contactsName = common.string.EMPTY_STR;
        if (this.strContactsName && this.strContactsName != common.string.EMPTY_STR) {
            contactsName = this.$t('strings.transmitContentReceive', {
                name: this.strContactsName
            });
        } else {
            contactsName = this.$t('strings.transmitContentReceive', {
                name: this.strContactsNumberFormat
            });
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
        let transmitContent = item.isReceive ? contactsName : this.$t('strings.transmitContent');
        this.jumpTransmitMsg(transmitContent, transmitContentList, item.isMsm);
    },
    // 多条信息转发
    transmitMsg() {
        let contactsName = common.string.EMPTY_STR;
        let transmitContent = common.string.EMPTY_STR;
        if (this.strContactsName && this.strContactsName != common.string.EMPTY_STR) {
            contactsName = this.$t('strings.transmitContentReceive', {
                name: this.strContactsName
            });
            transmitContent = this.$t('strings.transmitContentMulti', {
                name: this.strContactsName
            });
        } else {
            contactsName = this.$t('strings.transmitContentReceive', {
                name: this.strContactsNumberFormat
            });
            transmitContent = this.$t('strings.transmitContentMulti', {
                name: this.strContactsNumberFormat
            });
        }
        let transmitResult = this.getTransmitContentList(contactsName);

        if (this.isMessageCheckAll) {
            this.isMessageCheckAll = false;
        }
        this.jumpTransmitMsg(transmitContent, transmitResult.transmitContentList, transmitResult.isMms);
    },
    getTransmitContentList(contactsName) {
        let result = {};
        let transmitContentList = [];
        let today = this.$t('strings.today');
        let yesterday = this.$t('strings.yesterday');
        for (let element of this.mmsList) {
            let transmitContentArray = {};
            if (element.isCbChecked) {
                let date = element.date.substring(0, element.date.length - 3);
                if (date == today || date == yesterday) {
                    let time = element.timeMillisecond;
                    date = this.getTime(time);
                }
                transmitContentArray.msgUriPath = element.msgUriPath ? element.msgUriPath : common.string.EMPTY_STR;
                transmitContentArray.date = date;
                transmitContentArray.content = element.content;
                if (element.isReceive) {
                    transmitContentArray.contactsName = contactsName;
                } else {
                    transmitContentArray.contactsName = this.$t('strings.transmitContentMe');
                }
                transmitContentArray.mms = element.mms;
                transmitContentArray.msgShowType = element.msgShowType;
                transmitContentArray.time = element.time;
                transmitContentArray.isMsm = element.isMsm;
                transmitContentArray.contentInfo = common.string.EMPTY_STR;
                transmitContentArray.msgType = element.msgType;
                transmitContentArray.audioTime = element.audioTime
                transmitContentList.push(transmitContentArray);
            }
        }
        result.transmitContentList = transmitContentList;
        return result;
    },
    jumpTransmitMsg(transmitContent, transmitContentList, isMms) {
        router.push({
            uri: 'pages/transmit_msg/transmit_msg',
            params: {
                doubleCard: this.cardImage,
                transmitContent: transmitContent,
                transmitContentList: transmitContentList,
                isMulti: true,
                isMms: isMms,
                isMyStartPage: false
            }
        });
    },
    // 删除弹框提示
    deleteDialogShow() {
        this.strMsgDeleteDialogTip = this.$t('strings.msg_delete_dialog_tip1');
        this.hasLockMsg = this.mmsList[this.mmsIndex].isLock;
        this.$element('delete_dialog').show();
    },
    // 更多
    more() {
        this.setTabOperationStatus(false);
        this.distanceBottomFlag = false;
        let item = this.mmsList[this.mmsIndex];
        item.isCbChecked = !item.isCbChecked;
        this.setSelectStatus(true);
        this.hasDetailDelete = false;
        this.setMessageCheckAll(common.int.CHECKBOX_SELECT_UNKNOWN);
        this.hasReport = item.hasReport;
        this.setGroupMoreMenu(item);
    },
    setGroupMoreMenu(item) {
        if(!item.isMsm) {
            this.hasContent = true;
            return;
        }
        let commonService = this.$app.$def.commonService;
        this.hasContent = commonService.judgeIsSelectText(item.mms);
        this.hasImage = commonService.judgeIsImage(item.mms);
        if(item.isMsm && item.mms.length == 1 && item.mms[0].type == common.MSG_ITEM_TYPE.CARD) {
            this.hasVcard = true;
        } else {
            this.hasVcard = false;
        }
    },
    longPressMore(e) {
        var index = parseInt(e.value);
        switch (index) {
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
    },
    longPressGroupMore(e) {
        var index = parseInt(e.value);
        switch (index) {
            case 0:
            // 删除
                this.deleteDetail();
                break;
            case 1:
            // 跳转至收件人页面
                router.push({
                    uri: 'pages/group_detail/group_detail',
                    params: {
                        contactsNum: this.contactsNum,
                        threadId: this.threadId
                    }
                });
                break;
            default:
                break;
        }
    },
    // 删除
    deleteDetail() {
        if (this.mmsList.length == 1) {
            this.strMsgDeleteDialogTip = this.$t('strings.msg_delete_dialog_tip3');
            this.$element('delete_dialog').show();
        } else {
            this.hasDetailDelete = true;
            this.isSelectStatus = true;
        }
    },
    // 新建联系人
    createNewContract(number) {
        var actionData = {};
        actionData.phoneNumber = number;
        actionData.pageFlag = common.contractPage.PAGE_FLAG_SAVE_CONTACT;
        this.jumpToContract(actionData);
    },
    // 呼叫前编辑
    callEditor(number) {
        var actionData = {};
        actionData.phoneNumber = number;
        actionData.pageFlag = common.contractPage.PAGE_FLAG_EDIT_BEFORE_CALLING;
        this.jumpToContract(actionData);
    },
    // 保存联系人
    existingContact(number) {
        var actionData = {};
        actionData.phoneNumber = number;
        actionData.pageFlag = common.contractPage.PAGE_FLAG_SAVE_EXIST_CONTACT;
        this.jumpToContract(actionData);
    },
    jumpGroupDetail(index) {
        router.push({
            uri: 'pages/group_detail/group_detail',
            params: {
                contactsNum: this.contactsNum,
                threadId: this.threadId,
                groupId: this.mmsList[index].groupId,
                time: this.mmsList[index].time,
                isDetail: this.isDetail,
                content: this.mmsList[index].content,
                slotId: this.slotId
            }
        });
    },
    // 在选择状态下，点击'更多'后弹出menu，然后选择
    moreSelected(e) {
        switch (e.value) {
            case '0':
            // 复制
                this.copyText();
                break;
            case '1':
            // 分享
                this.share();
                break;
            case '2':
            // 选择文本
                this.gotoTextSelect(this.mmsIndex);
                break;
            case '3':
            // 锁定
                this.lock();
                break;
            case '4':
            // 显示详情
                this.showDetails();
                break;
            case '5':
            // 取消锁定
                this.unlock();
                break;
            case '6':
            // 查看报告
                this.showReport(this.mmsIndex);
                break;
            case '7':
            // 保存附件
                this.saveImage();
                break;
            case '8':
            // 查询vCard详情
                this.showVcarDetail(this.mmsIndex);
                break;
            default:
                break;
        }
        // 退出多选模式
        this.exitMultiselect();
    },
    share() {
        for (let i = 0; i < this.mmsList.length; i++) {
            if (this.mmsList[i].isCbChecked == true) {
                var actionData = {};
                actionData.content = this.mmsList[i].content;
                conversationService.gotoShare(actionData, function (data) {
                    mmsLog.info('JS_conversation: ' + 'sendMessage......titleBarAvatar');
                });
            }
        }
    },
    lock() {
        this.updateLock(true);
    },
    unlock() {
        this.updateLock(false);
    },
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
        let actionData = {
            groupIds: groupIds,
            featureAbility: this.$app.$def.featureAbility,
            ohosDataAbility: this.$app.$def.ohosDataAbility,
            hasLock: hasLock
        };
        let that = this;
        conversationService.updateLock(actionData, function (result) {
            if (result.code == common.int.SUCCESS) {
                // 多选状态关闭
                that.isSelectStatus = false;
                that.cancleCheckedAll();
                mmsLog.info('Success: updateLock()');
            } else {
                mmsLog.info('Error: updateLock(() failed !!!');
            }
        });
        // 更新锁定状态
        this.updateSessionLock(isLock);
    },
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
                mmsLog.log('updateSessionLock, it is not all select unlock');
                return;
            }
        }
        // 如果是锁定，将状态更新为锁定
        let rdbStore = this.$app.$def.rdbStore;
        let conversationListService = this.$app.$def.conversationListService;
        conversationListService.updateById(rdbStore, threadIds, valueBucket);
    },
    showDetails() {
        for (let index = 0; index < this.mmsList.length; index++) {
            if (this.mmsList[index].isCbChecked == true) {
                var time = this.mmsList[index].timeMillisecond;
                var timeStash = this.getTime(time);
                this.mmsTime = timeStash + this.mmsList[index].time;
                if (this.mmsList[index].msgType == 0) {
                    this.isMmsType = this.$t('strings.sms');
                } else {
                    this.isMmsType = this.$t('strings.mms');
                }

                if (this.mmsList[index].isReceive) {
                    this.isSendRecipient = true;
                } else {
                    this.isSendRecipient = false;
                }
            }
        }
        this.$element('mms_details_dialog').show();
    },
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
    },
    showVcarDetail(mmsIndex) {

    },
    exitMultiselect() {
        // 退出多选状态
        this.isSelectStatus = false;
        this.cancleCheckedAll();
    },
    titleBarCancel() {
        // 取消按钮
        this.cancleCheckedAll();
        this.setSelectStatus(false);
    },
    listCheckBoxChange(index, e) {
        mmsLog.info('JS_conversation: ' + 'listCheckBoxChange  index:' + index);
        let item = this.mmsList[index];
        item.isCbChecked = e.checked;
        this.mmsIndex = index;
        this.hasReport = item.hasReport;
        this.setMessageCheckAll(common.int.CHECKBOX_SELECT_UNKNOWN);
        if(this.selectDeleteMsgCount == 1) {
            let item;
            for (let element of this.mmsList) {
                if (element.isCbChecked) {
                    item = element;
                    break;
                }
            }
            if(item != null) {
                this.setGroupMoreMenu(item);
            }
        }
    },
    clickGroupDelete() {
        if (this.selectDeleteMsgCount == 0) {
            return;
        }
        if (this.selectDeleteMsgCount == 1) {
            this.strMsgDeleteDialogTip = this.$t('strings.msg_delete_dialog_tip1');
        } else if (this.selectDeleteMsgCount == this.mmsList.length) {
            this.strMsgDeleteDialogTip = this.$t('strings.msg_delete_dialog_tip3');
        } else {
            this.strMsgDeleteDialogTip = this.$t('strings.msg_delete_dialog_tip2', {
                number: this.selectDeleteMsgCount
            });
        }
        this.hasLockMsg = (this.mmsList.some((element, index) => element.isCbChecked && element.isLock));
        this.$element('delete_dialog').show();
    },
    clickGroupTransmit() {
        if (this.selectDeleteMsgCount == 0) {
            return;
        }
        this.transmitMsg();
        this.setSelectStatus(false);
    },
    clickGroupStar() {
        if (this.selectDeleteMsgCount == 0) {
            return;
        }
        // 被收藏的数量
        let selectMsgCount = 0;
        // 被选中的数量
        let staredMsgCount = 0;
        // 被收藏的IDs
        let groupIds = [];
        for (let element of this.mmsList) {
            if (element.isCbChecked) {
                selectMsgCount++;
                if (element.isStared) {
                    staredMsgCount++;
                } else {
                    element.isStared = !element.isStared;
                    groupIds.push(element.groupId);
                }
                element.isCbChecked = !element.isCbChecked;
            }
        }
        if (selectMsgCount == staredMsgCount) {
            Prompt.showToast({
                message: this.$t('strings.info_is_stared'),
                duration: 2000,
                bottom: '150px'
            });
            this.isSelectStatus = false;
            this.cancleCheckedAll();
            return;
        }
        if (groupIds.length > 0) {
            // 收藏
            this.setSelectStatus(false);
            // 设置收藏标志位
            let actionData = {
                groupIds: groupIds,
                featureAbility: this.$app.$def.featureAbility,
                ohosDataAbility: this.$app.$def.ohosDataAbility,
                hasCollect: 1
            };
            conversationService.updateCollect(actionData, function (result) {
                if (result.code == common.int.SUCCESS) {
                    mmsLog.info('Success: updateCollect()');
                } else {
                    mmsLog.info('Error: updateCollect() failed !!!');
                }
            });
        }
    },
    clickGroupCheckAll() {
        for (let element of this.mmsList) {
            element.isCbChecked = !this.isMessageCheckAll;
        }
        if (this.isMessageCheckAll) {
            this.setMessageCheckAll(common.int.CHECKBOX_SELECT_NONE);
        } else {
            this.setMessageCheckAll(common.int.CHECKBOX_SELECT_ALL);
        }
    },
    // 跳转全屏页面
    jumpFullScreen() {
        router.push({
            uri: 'pages/full_screen_input/full_screen_input',
            params: {
                inputDetail: this.textValue,
                telephone: this.strContactsNumber,
                slotId: this.slotId,
                haveSimCard: this.haveSimCard
            },
        });
        this.$app.$def.isFromFullScreen = true;
    },
    jumpEmoji() {
        // 跳转笑脸
    },
    deleteDialogCancel() {
        // 取消弹出
        this.$element('delete_dialog').close();
        this.isSelectLockMsg = false;
    },
    tipDialogCancel() {
        // 取消tip
        this.$element('tip_dialog').close();
        this.mmsAddType = common.MSG_ITEM_TYPE.TEXT;
    },
    tipDialogConfirm() {
        if (this.mmsAddType == common.MSG_ITEM_TYPE.CARD) {
            this.deleteAllPreview();
            this.mmsEditList = [];
            this.clickToSelectVcard();
        } else if (this.mmsAddType == common.MSG_ITEM_TYPE.AUDIO) {
            this.isVCard = false;
            this.mmsEditList = [];
            this.addRecordAudio();
        } else if (this.mmsAddType == common.MSG_ITEM_TYPE.IMAGE || common.MSG_ITEM_TYPE.VIDEO) {
            this.isVCard = false;
            this.mmsEditList = [];
            this.pictureItemCheckboxOnchange(this.picItemSelectedIndex);
        }
        this.tipDialogCancel();
    },
    deleteDialogConfirm() {
        let groupIds = [];
        if (this.isSelectStatus) {
            let mmsListCopy = [];
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
            this.mmsList.splice(this.mmsIndex, 1);
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
        this.$element('delete_dialog').close();
    },
    updateLastItemContent() {
        let actionData = {
            mmsList: this.mmsList,
            threadId: this.threadId,
            rdbStore: this.$app.$def.rdbStore,
            isMessageDetail: true
        };
        let conversationListService = this.$app.$def.conversationListService;
        conversationListService.updateLastItemContent(actionData);
    },
    deleteMessageByGroupIds(groupIds) {
        let actionData = {
            groupIds: groupIds,
            featureAbility: this.$app.$def.featureAbility,
            ohosDataAbility: this.$app.$def.ohosDataAbility,
        };
        // 这里调用数据库的删除方法
        conversationService.deleteMessageByGroupIds(actionData);
    },
    deleteMessageById(threadId) {
        let threadIds = [threadId];
        // 删除数据库数据
        let actionData = {
            rdbStore: this.$app.$def.rdbStore,
            threadIds: threadIds,
            featureAbility: this.$app.$def.featureAbility,
            ohosDataAbility: this.$app.$def.ohosDataAbility
        };
        let conversationListService = this.$app.$def.conversationListService;
        conversationListService.deleteMessageById(actionData);
    },
    setSelectLockStatus() {
        // 删除锁定CheckBox勾选事件
        if (this.isSelectLockMsg == true) {
            this.isSelectLockMsg = false;
        } else {
            this.isSelectLockMsg = true;
        }
    },
    cancleCheckedAll() {
        for (let element of this.mmsList) {
            element.isCbChecked = false;
        }
    },
    setMessageCheckAll(type) {
        if (!this.isSelectStatus) {
            return;
        }
        if (type == common.int.CHECKBOX_SELECT_ALL) {
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
            this.selectDeleteMsgCount = 0;
            this.isMessageCheckAll = false;
            this.hasLock = false;
            this.hasReport = false;
        } else {
            // 默认为 CHECKBOX_SELECT_UNKNOWN,判断是否有未选中
            this.checkBoxSelectUnknow();
        }
    },
    checkBoxSelectUnknow() {
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
    },
    updatePreview(idx) {
        // 删除预览
        mmsLog.info('JS_conversation: ' + 'updatePreview idx :' + idx);
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
    },
    deleteAllPreview() {
        this.mmsEditList.forEach(mmsItem => {
            if (mmsItem.type != common.MSG_ITEM_TYPE.AUDIO) {
                this.dealPictureListFromGallery(mmsItem);
            }
        });
    },
    dealPictureListFromGallery(mmsItem) {
        this.pictureListFromGallery.forEach((item) => {
            if (item.path == mmsItem.uriPath) {
                item.checkedValue = false;
            }
        });
    },
    showMsgImage(index) {
        let that = this;
        let item = that.mmsList[index];
        // 双击取消发送
        if (that.recallMessagesFlag && item.cancelTimeCount > 0) {
            if (!that.doubleClickStatus) {
                that.doubleClickStatus = true;
                setTimeout(function () {
                    that.doubleClickStatus = false;
                }, 500);
            } else {
                if (item.content) {
                    that.textValue = item.content;
                }
                that.mmsList.splice(index, 1);
                // 如果列表数据为空，并且是从新建页面传递过来的，返回新建页面
                this.dealNewRecallMessagesFlag(that.mmsList);
                // 将彩信的数据进行展示
                this.setMmsDataSource(item.mmsSource);
                that.isEditMms = true;
                clearTimeout(item.sendTimeoutId);
                clearInterval(item.sendIntervalId);
                // 判断发送按钮是否高亮
                that.judgeSendBtnCanClicked();
            }
        }
    },
    showEdtImage(type, idx) {
        if (type != common.MSG_ITEM_TYPE.IMAGE) {
            return;
        }
        // 跳转图库,查看图片
        mmsLog.info('JS_conversation: ' + 'go to URL map depot');
    },
    playAudio(idx) {
        // 播放音频
        let curAudio = this.mmsEditList[idx];
        mmsLog.info('JS_conversation: ' + 'playAudio  idx :' + idx);
    },
    deletePreCard() {
        this.isVCard = false;
        this.mmsEditList = [];
        this.convertingSms();
        mmsLog.info('JS_conversation: ' + 'deletePreCard  isVCard :' + this.isVCard);
    },
    clickToJumpToGallery() {
        // 跳转到图库以选择图片
    },
    getPicturesFromGallery() {
        // 从图库里获取所有图片
    },
    clickToSelectPictureOnFullScreen(index) {
        if (this.isPicCheckboxClicked) {
            setTimeout(() => {
                this.isPicCheckboxClicked = false;
            }, 200)
            return;
        }
        // 全屏查看图片
        this.getCurEdtFileSize();
        router.push({
            uri: 'pages/full_screen_show_picture/full_screen_show_picture',
            params: {
                which: index + 1,
                total: this.pictureListFromGallery.length,
                checkedValue: this.pictureListFromGallery[index].checkedValue,
                path: this.pictureListFromGallery[index].path,
                type: this.pictureListFromGallery[index].type,
                totalFileSize: this.curEdtFileSize,
                fileSize: this.pictureListFromGallery[index].fileSize
            }
        })
    },
    addMmsToPpt(mmsObj) {
        this.pptTotalCount ++;
        let newObj = this.getPptObj();
        mmsObj.index = newObj.pptIndex;
        newObj.mms = mmsObj;
        this.textareaDatasource.push(newObj);
    },
    resetMmsEditListFromDatasource() {
        let list = [];
        this.textareaDatasource.forEach((item) => {
            if (item.mms) {
                list.push(item.mms);
            }
        });
        this.mmsEditList = list;
    },
    dealPptMms(mmsObj) {
        if (this.selectedTextareaIdx === -1) {
            this.addMmsToPpt(mmsObj);
        } else {
            let length = this.selectedTextareaIdx;
            if (this.messageType === common.MESSAGE_TYPE.THEME_AND_PPT) {
                if (this.selectedTextareaIdx === 0) {
                    length = 1;
                }
            }
            let isFind = false;
            for(let i = length; i < this.textareaDatasource.length; i++) {
                let item = this.textareaDatasource[i];
                if (!item.mms) {
                    this.selectedTextareaIdx = i;
                    mmsObj.index = item.pptIndex;
                    item.mms = mmsObj;
                    isFind = true;
                    break;
                }
            }
            if (!isFind) {
                this.addMmsToPpt(mmsObj);
                this.selectedTextareaIdx = this.textareaDatasource.length - 1;
            }
        }
        this.resetMmsEditListFromDatasource();
    },
    addMmsObj(mmsObj) {
        if (this.messageType === common.MESSAGE_TYPE.NORMAL) {
            this.mmsEditList.push(mmsObj);
        } else if (this.messageType === common.MESSAGE_TYPE.THEME) {
            let obj = this.textareaDatasource[1];
            obj.placeholder = this.$t('strings.msg_note_mms2');
            this.mmsEditList.push(mmsObj);
        } else {
            this.dealPptMms(mmsObj);
        }
    },
    deletePictures(index) {
        this.pictureListFromGallery[index].checkedValue = false;
        let obj = null;
        this.mmsEditList = this.mmsEditList.filter(item => {
            if (item.uriPath == this.pictureListFromGallery[index].path) {
                obj = item;
            }
            return item.uriPath != this.pictureListFromGallery[index].path;
        });
        this.textareaDatasource = this.textareaDatasource.filter(item => {
            if (item.mms && item.mms.index === obj.index) {
                item.mms = null;
            }
            return item;
        });
        this.curEdtFileSize -= this.pictureListFromGallery[index].fileSize;
        this.msgSendTip = Math.ceil(this.curEdtFileSize) + COMMON_FILE_SIZE_STRING;
        if (this.textareaDatasource.length == 0 && this.mmsEditList.length ==0) {
            this.convertingSms();
        }
    },
    dealMms() {
        if (this.mmsEditList.length == 1) {
            if (this.textareaDatasource.length == 0) {
                this.convertingMms();
            } else if (this.messageType == common.MESSAGE_TYPE.THEME) {
                let hasContent = this.getHasContent();
                if (!hasContent) {
                    this.convertingMms();
                }
            }
        }
    },
    getHasContent() {
        let hasContent = false;
        this.textareaDatasource.forEach((item) => {
            if (item.textValue != common.string.EMPTY_STR) {
                hasContent = true;
            }
        });
        return hasContent;
    },
    pictureItemCheckboxOnchange(index) {
        if (this.isVCard) {
            this.mmsAddType = common.MSG_ITEM_TYPE.IMAGE;
            this.picItemSelectedIndex = index;
            this.$element('tip_dialog').show();
            return;
        }
        this.isPicCheckboxClicked = true;
        // 点击图片上的checkbox，在输入框下的图片中
        this.getCurEdtFileSize();
        if (!this.pictureListFromGallery[index].checkedValue) {
            if (this.curEdtFileSize + this.pictureListFromGallery[index].fileSize > COMMON_FILE_SIZE) {
                this.showToast(this.$t('strings.attachment_failed'));
                return;
            }
            this.pictureListFromGallery[index].checkedValue = true;
            // 添加
            let mmsObj = {
                type: this.pictureListFromGallery[index].type,
                uriPath: this.pictureListFromGallery[index].path,
                fileSize: this.pictureListFromGallery[index].fileSize,
                time: '',
                index: -1
            };
            this.addMmsObj(mmsObj);
            this.curEdtFileSize += this.pictureListFromGallery[index].fileSize;
            this.msgSendTip = Math.ceil(this.curEdtFileSize) + COMMON_FILE_SIZE_STRING;
            this.dealMms();
        } else {
            // 删除
            this.deletePictures(index);
        }
        if (this.mmsEditList.length != 0) {
            if (this.textValue.length > common.int.FULL_SCREEN_SEND_LENGTH) {
                this.isShowFullScreen = false;
            }
        }
        // 全局选择的tabTitleText
        this.setTabTitleText();
        this.isOnlyAudio = !this.mmsEditList.some((item, index) => item.type !=common.MSG_ITEM_TYPE.AUDIO);
    },
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
        this.tabTitleText = size == 0 ? this.$t('strings.msg_unselected_tip') : this.$t('strings.msg_selected_tip', {
            number: size
        });
    },
    drawRecordingEffect() {
        this.recordingAnimation = this.$element('recording').animate(this.animationFrames, this.animationOptions);
        this.recordingAnimation.play();
        let beforeTime = this.startRecordTime;
        let that = this;
        this.drawRecordingTaskId = setInterval(() => {
            let curTime = new Date().getTime();
            if (curTime - beforeTime >= 1000) {
                that.setCurRecordingTime(curTime);
                beforeTime = curTime;
            }
        }, 30);
    },
    setCurRecordingTime(curTime) {
        let duration = curTime - this.startRecordTime;
        this.curSize = duration * 1.7 / 1000;
        if (this.curEdtFileSize + this.curSize > COMMON_FILE_SIZE) {
            this.setRecordingStatus(false);
            clearInterval(this.drawRecordingTaskId);
            this.drawRecordingTaskId = null;
            this.recordingAnimation.cancel();
            this.recordingAnimation = null;
            this.showToast(this.$t('strings.attachment_failed'));
            return;
        }
        let date = new Date(duration);
        this.curRecordingTime = (date.getMinutes() < 10 ? '0' + date.getMinutes() : date.getMinutes()) + ':';
        this.curRecordingTime += date.getSeconds() < 10 ? '0' + date.getSeconds() : date.getSeconds();
    },
    recordingStart() {
        this.setRecordingStatus(true);
        this.curRecordingTime = '00:00';
        this.startRecordTime = new Date().getTime();
        // js绘制录音效果
        this.drawRecordingEffect();
    },
    addRecordAudio() {
        this.setCurRecordingTime(new Date().getTime());
        this.curEdtFileSize += this.curSize;
        this.msgSendTip = Math.ceil(this.curEdtFileSize) + COMMON_FILE_SIZE_STRING;
        // 插入Json
        let mmsObj = {
            type: common.MSG_ITEM_TYPE.AUDIO,
            uriPath: '',
            fileSize: this.curSize,
            time: this.curRecordingTime,
            index: -1
        };
        this.addMmsObj(mmsObj);
        this.isOnlyAudio = !this.mmsEditList.some((item, index) => item.type != common.MSG_ITEM_TYPE.AUDIO);
        let idx = this.mmsEditList.length - 1;
        this.$element('mms_edt_list').scrollTo({
            index: idx
        });
        this.dealMms();
        if (this.tabSlideStatus != 0) {
            this.restoreTabSlideStatus();
        }
        this.setTabOperationStatus(false);
        // 重新请求输入框光标
        this.$element('isInputMethod').focus({
            focus: true
        });
    },
    convertingMms() {
        // 转化为彩信
        this.isEditMms = true;
        if (this.haveSimCard) {
            this.canSendMessage = true;
        }
        if (this.isNewMsg) {
            if (this.paramContact.transmitContracts != null && this.paramContact.transmitContracts.length > 0) {
                for (let element of this.paramContact.transmitContracts) {
                    this.dealSelectContacts(element);
                }
            }
            this.setCanSendMsgStatus();
        }
        this.showToast(this.$t('strings.converting_mms'));
    },
    dealSelectContacts(element) {
        let again = true;
        for (let contact of this.selectContacts) {
            if (element.telephone == contact.telephone) {
                again = false;
                break;
            }
        }
        if (again) {
            this.selectContacts.push({
                headImage: element.headImage,
                contactName: element.contactName,
                telephone: element.telephone,
                telephoneFormat: element.telephoneFormat,
                select: false
            });
        }
    },
    convertingSms() {
        // 转化为短信
        this.isEditMms = false;
        this.setSmsTip(this.textValue);
        this.showToast(this.$t('strings.converting_sms'));
    },
    recordingEnd() {
        this.setRecordingStatus(false);
        clearInterval(this.drawRecordingTaskId);
        this.recordingAnimation.cancel();
        this.recordingAnimation = null;
        // 判断时长
        if (this.curRecordingTime == this.timeFormat) {
            // 录音太短
            this.showToast(this.$t('strings.msg_record_short'));
            return;
        }
        // 结束录音
        if (this.isVCard) {
            // 提示已有内容替换
            this.mmsAddType = common.MSG_ITEM_TYPE.AUDIO;
            this.$element('tip_dialog').show();
            return;
        }
        this.addRecordAudio();
    },
    showVideoOperation(index) {
        // 跳转视频操作页面 后期添加带参跳转
        router.push({
            uri: 'pages/video_operation/video_operation'
        })
    },
    playMsgAudio(index) {
        let uriPath = this.mmsList[index];
        // 跳转播放音频
    },
    seTabHeightAnimation(isUpDirection, toHeight) {
        // 自定义动画
        let that = this;
        that.isTabHeightAnimation = true;
        let tabHeightTaskId = setInterval(() => {
            if (isUpDirection) {
                that.tabHeight += 6;
                if (that.tabHeight > common.int.FULL_HEIGHT - 200) {
                    that.tabSlideStatus = 2;
                }
                if (that.tabHeight >= toHeight) {
                    that.tabHeight = toHeight;
                    that.tabSlideStatus = 2;
                    clearInterval(tabHeightTaskId);
                    that.isTabHeightAnimation = false;
                }
            } else {
                that.tabHeight -= 6;
                if (that.tabHeight < common.int.FULL_HEIGHT - 200) {
                    that.tabSlideStatus = 1;
                }
                if (that.tabHeight <= toHeight) {
                    that.tabHeight = toHeight;
                    that.tabSlideStatus = 0;
                    clearInterval(tabHeightTaskId);
                    that.isTabHeightAnimation = false;
                }
            }
        }, 20);
    },
    tabSlideStart(e) {
        this.slideStartPoint.x = e.touches[0].localX;
        this.slideStartPoint.y = e.touches[0].localY;
    },
    tabSlideMove(e) {
        // 避免误触
        const FALSE_DISTANCE = 10;
        let x = e.touches[0].localX;
        let y = e.touches[0].localY;
        let distanceY = Math.abs(y - this.slideStartPoint.y);
        if (distanceY < FALSE_DISTANCE) {
            return;
        }
        if (Math.abs(x - this.slideStartPoint.x) > distanceY) {
            return;
        }
        this.slideDistance = distanceY - FALSE_DISTANCE;
        this.isTabSlideUp = this.slideStartPoint.y > y;
        this.tabSlideStatus = 1;
        if (this.isTabSlideUp) {
            this.tabHeight = common.int.TAB_HEIGHT + this.slideDistance;
            if (this.tabHeight > common.int.FULL_HEIGHT) {
                this.tabHeight = common.int.FULL_HEIGHT;
            }
            if (this.tabHeight > common.int.FULL_HEIGHT - 200) {
                this.tabSlideStatus = 2;
            }
        } else {
            this.tabHeight = common.int.FULL_HEIGHT - this.slideDistance;
            if (this.tabHeight < common.int.FULL_HEIGHT - 200) {
                this.tabSlideStatus = 1;
            }
            if (this.tabHeight < common.int.TAB_HEIGHT) {
                this.tabHeight = common.int.TAB_HEIGHT;
            }
        }
    },
    tabSlideEnd() {
        if (this.tabSlideStatus == 0) {
            return;
        }
        let that = this;
        if (that.isTabSlideUp) {
            // 上滑动
            if (that.slideDistance > 400) {
                // 上动画
                that.seTabHeightAnimation(true, common.int.FULL_HEIGHT);
            } else {
                // 延迟还原
                that.seTabHeightAnimation(false, common.int.TAB_HEIGHT);
            }
            return;
        }
        // 下滑动
        if (that.slideDistance > 150) {
            // 下动画
            that.seTabHeightAnimation(false, common.int.TAB_HEIGHT);
        } else {
            // 延迟还原
            that.seTabHeightAnimation(true, common.int.FULL_HEIGHT);
        }
    },
    tabSwipe(e) {
        // 快速滑动后触发
        if (this.isTabHeightAnimation) {
            return
        }
        if (e.direction == 'up') {
            this.seTabHeightAnimation(true, common.int.FULL_HEIGHT);
        } else if (e.direction == 'down') {
            this.seTabHeightAnimation(false, common.int.TAB_HEIGHT);
        }
    },
    restoreTabSlideStatus() {
        // 恢复选项卡状态
        this.tabSlideStatus = 0;
        this.tabHeight = common.int.TAB_HEIGHT;
    },
    clickCall() {
        this.call(this.strContactsNumber);
    },
    call(telephone) {
        // 打电话
        let param = {
            telephone: telephone
        };
        callService.call(param, result => {
            if (result.code == common.int.SUCCESS) {
                mmsLog.info('JS_conversation: call success');
            } else {
                mmsLog.info('JS_conversation: call error');
            }
        });
    },
    clickToSelectContact() {
        let actionData = {};
        actionData.pageFlag = common.contractPage.PAGE_FLAG_CHOOSE_CONTACTS;
        this.jumpToContractForResult(actionData);
    },
    async jumpToContractForResult(actionData) {
        let commonService = this.$app.$def.commonService;
        let featureAbility = this.$app.$def.featureAbility;
        let str = commonService.commonContractParam(actionData);
        let data = await featureAbility.startAbilityForResult(str);
        if (data.resultCode === 0) {
            this.contactListFromContactApp = [];
            this.dealContractParams(data.want.parameters.contactObjects);
            if (this.contactListFromContactApp.length === 1) {
                router.push({
                    uri: 'pages/contact_item_pick/contact_item_pick',
                    params: {
                        iconFromConvPage: this.contactListFromContactApp[0].icon,
                        nameFromConvPage: this.contactListFromContactApp[0].name,
                        telephoneNumFromConvPage: this.contactListFromContactApp[0].telephoneNum
                    }
                });
            } else {
                this.$element('select_text_or_vcard_to_send_dialog').show();
            }
        }
    },
    dealContractParams(contactObjects) {
        let params = JSON.parse(contactObjects);
        for (let element of params) {
            let contact = {};
            contact.icon = '/common/icon/user_avatar_full_fill.svg';
            contact.name = element.contactName;
            let item = {
                telephone: element.telephone,
                checked: false
            };
            contact.telephoneNum = [item];
            this.contactListFromContactApp.push(contact);
        }
    },
    clickToSelectText() {
        // 发送联系人附件时，选择以文本形式发送
        let varTextValue = common.string.EMPTY_STR;
        for (let i = 0; i < this.contactListFromContactApp.length; i++) {
            varTextValue += this.$t('strings.name1') + this.contactListFromContactApp[i].name;
            for (let j = 0; j < this.contactListFromContactApp[i].telephoneNum.length; j++) {
                if (this.contactListFromContactApp[i].telephoneNum[j]) {
                    varTextValue += '\n' + this.$t('strings.mobile3') +
                    this.contactListFromContactApp[i].telephoneNum[j].telephone;
                }
            }
            if (i != this.contactListFromContactApp.length - 1) {
                varTextValue += '\n---\n';
            }
        }
        this.textValue = varTextValue;
        this.clickToCloseVcardDialog();
        this.setTabOperationStatus(false);
        this.$refs.textArea.focus({
            focus: true
        });
    },
    clickToSelectVcard() {
        // 发送联系人附件时，选择以vCard形式发送
        this.isVCard = true;
        if (this.contactListFromContactApp.length == 1) {
            this.vCard.name = this.contactListFromContactApp[0].name;
            this.vCard.number = this.contactListFromContactApp[0].telephoneNum[0].telephone;
        } else {
            this.vCard.name = common.string.EMPTY_STR;
            this.vCard.number = common.string.EMPTY_STR;
            this.contactListFromContactApp.forEach((item, index) => {
                if (index == 0) {
                    this.vCard.name = item.name;
                } else {
                    this.vCard.name = this.vCard.name + ',' + item.name;
                }
            });
        }
        if (this.mmsEditList.length > 0) {
            this.mmsAddType = common.MSG_ITEM_TYPE.CARD;
            this.$element('tip_dialog').show();
        } else {
            let obj = {
                type: common.MSG_ITEM_TYPE.CARD,
                uriPath: this.vCard.name,
                time: this.vCard.number,
                fileSize: 0
            }
            this.mmsEditList.push(obj);
            this.contactListFromContactApp = [];
            if (this.textareaDatasource.length == 0 && this.mmsEditList.length == 1) {
                this.convertingMms();
            }
        }

        this.clickToCloseVcardDialog();
    },
    clickToCloseVcardDialog() {
        this.$element('select_text_or_vcard_to_send_dialog').close();
    },
    cliclToSelectSubject() {
        // 在输入框下方的'更多'里点击'主题'
        if (this.messageType === common.MESSAGE_TYPE.THEME) {
            this.textareaDatasource = [];
            this.messageType = common.MESSAGE_TYPE.NORMAL;
            this.isEditMms = false;
            return;
        } else if (this.messageType === common.MESSAGE_TYPE.THEME_AND_PPT) {
            this.textareaDatasource.shift();
            this.messageType = common.MESSAGE_TYPE.PPT;
            return;
        }
        let themeObj = {
            textValue: '',
            placeholder: this.$t('strings.msg_theme'),
            pptIndex: 0,
            mms: null
        }
        if (this.messageType === common.MESSAGE_TYPE.NORMAL) {
            let placeholder = this.$t('strings.msg_note_mms');
            if (this.mmsEditList.length > 0) {
                placeholder = this.$t('strings.msg_note_mms2');
            }
            let normal = {
                textValue: this.textValue,
                placeholder: placeholder,
                pptIndex: 0,
                mms: null
            }
            this.textareaDatasource.push(themeObj);
            this.textareaDatasource.push(normal);
            this.messageType = common.MESSAGE_TYPE.THEME;
        } else if (this.messageType === common.MESSAGE_TYPE.PPT) {
            this.textareaDatasource.unshift(themeObj);
            this.messageType = common.MESSAGE_TYPE.THEME_AND_PPT;
        }
    },
    cliclToSelectSlide() {
        // 在输入框下方的'更多'里点击'幻灯片'
        this.$element('slide_dialog').show();
    },
    clickToCloseSlideDialog() {
        this.$element('slide_dialog').close();
    },
    getPptObj() {
        let obj = {
            textValue: common.string.EMPTY_STR,
            placeholder: this.$t('strings.enter_text'),
            pptIndex: this.pptTotalCount,
            mms: null
        }
        return obj;
    },
    addPptObj() {
        this.pptTotalCount ++;
        let pptObj = this.getPptObj();
        this.textareaDatasource.push(pptObj);
    },
    addSlideFromThemeType() {
        let msgObj = this.textareaDatasource[this.textareaDatasource.length - 1];
        msgObj.pptIndex = 1;
        msgObj.placeholder = this.$t('strings.enter_text');
        msgObj.textValue = this.textValue;
        if (this.mmsEditList.length !== 0) {
            this.mmsEditList.forEach((item, index) => {
                if (index === 0) {
                    item.index = 1;
                    msgObj.mms = item;
                } else {
                    this.pptTotalCount ++;
                    let pptObj = this.getPptObj();
                    item.index = pptObj.pptIndex;
                    pptObj.mms = item;
                    this.textareaDatasource.push(pptObj);
                }
            });
            this.addPptObj();
        } else {
            this.addPptObj();
        }
    },
    addSlideFromNormalType() {
        if (this.mmsEditList.length === 0) {
            let pptObj1 = this.getPptObj();
            pptObj1.textValue = this.textValue;
            this.textareaDatasource.push(pptObj1);
            this.pptTotalCount ++;
            let pptObj2 = this.getPptObj();
            this.textareaDatasource.push(pptObj2);
        } else {
            this.mmsEditList.forEach((item, index) => {
                if (index !== 0) {
                    this.pptTotalCount ++;
                }
                let pptObj = this.getPptObj();
                item.index = pptObj.pptIndex;
                pptObj.mms = item;
                this.textareaDatasource.push(pptObj);
            });
            this.addPptObj();
        }
    },
    clickToAddSlide() {
        // 在弹出的幻灯片dialog里选择'添加幻灯片'
        if (this.pptTotalCount === 0) {
            this.pptTotalCount ++;
            if (this.messageType === common.MESSAGE_TYPE.THEME) {
                this.addSlideFromThemeType();
                this.messageType = common.MESSAGE_TYPE.THEME_AND_PPT;
            } else if (this.messageType === common.MESSAGE_TYPE.NORMAL) {
                this.addSlideFromNormalType();
                this.messageType = common.MESSAGE_TYPE.PPT;
            }
            this.showConvertingMms();
        } else {
            this.pptTotalCount ++;
            this.clickToAddMoreSlide();
        }
        this.clickToCloseSlideDialog();
    },
    clickToAddMoreSlide() {
        let obj = this.getPptObj();
        if (this.selectedTextareaIdx === -1) {
            this.textareaDatasource.push(obj);
        } else {
            this.textareaDatasource.splice(this.selectedTextareaIdx + 1, 0, obj);
            if (this.messageType === common.MESSAGE_TYPE.PPT) {
                this.textareaDatasource.forEach((item, index) => {
                    item.pptIndex = index + 1;
                });
            } else if (this.messageType === common.MESSAGE_TYPE.THEME_AND_PPT) {
                this.textareaDatasource.forEach((item, index) => {
                    item.pptIndex = index;
                });
            }
            let dataSource = JSON.parse(JSON.stringify(this.textareaDatasource));
            setTimeout(() => {
                this.textareaDatasource.forEach((item, index) => {
                    item.textValue = dataSource[index].textValue;
                });
            }, 200);
        }
    },
    showConvertingMms() {
        if(this.mmsEditList.length == 0) {
            if(this.textareaDatasource.length == 2 && this.messageType == common.MESSAGE_TYPE.PPT) {
                this.convertingMms();
            }
            if(this.messageType == common.MESSAGE_TYPE.THEME_AND_PPT && this.textareaDatasource.length == 3
            && this.textareaDatasource[0].content != common.string.EMPTY_STR) {
                this.convertingMms();
            }
        }
    },
    focus(item, idx) {
        this.selectedTextareaIdx = idx;
    },
    blur() {
        this.selectedTextareaIdx = -1;
    },
    setMessageStateToNormal() {
        this.textareaDatasource = [];
        this.messageType = common.MESSAGE_TYPE.NORMAL;
        this.pptTotalCount = 0;
        this.selectedTextareaIdx = -1;
    },
    setMessageStateToTheme() {
        this.messageType = common.MESSAGE_TYPE.THEME;
        let obj = this.textareaDatasource[1];
        let placeholder = this.$t('strings.msg_note_mms');
        if (this.mmsEditList.length > 0) {
            placeholder = this.$t('strings.msg_note_mms2');
        }
        obj.placeholder = placeholder;
        obj.pptIndex = 0;
        obj.mms = null;
        this.pptTotalCount = 0;
        this.selectedTextareaIdx = -1;
    },
    deleteSlideFromPptType() {
        if (this.selectedTextareaIdx === -1) {
            this.textareaDatasource.splice(this.textareaDatasource.length - 1, 1);
        } else if (this.textareaDatasource.length > this.selectedTextareaIdx) {
            this.textareaDatasource.splice(this.selectedTextareaIdx, 1);
        }
        if (this.selectedTextareaIdx === this.textareaDatasource.length) {
            this.selectedTextareaIdx = this.selectedTextareaIdx - 1;
        }
        this.pptTotalCount--;
        if (this.textareaDatasource.length === 1) {
            this.setMessageStateToNormal();
        }
        if (this.textareaDatasource.length > 0) {
            this.textareaDatasource.forEach((item, index) => {
                item.pptIndex = index + 1;
            });
        }
    },
    deleteSlideFromThemeAndPptType() {
        if (this.selectedTextareaIdx === -1 && this.selectedTextareaIdx === 0) {
            this.textareaDatasource.splice(this.textareaDatasource.length - 1, 1);
        } else if (this.textareaDatasource.length > this.selectedTextareaIdx) {
            this.textareaDatasource.splice(this.selectedTextareaIdx, 1);
        }
        this.pptTotalCount--;
        if (this.textareaDatasource.length === 2) {
            this.setMessageStateToTheme();
        } else if (this.textareaDatasource.length > 2) {
            this.textareaDatasource.forEach((item, index) => {
                item.pptIndex = index;
            });
            if (this.selectedTextareaIdx === this.textareaDatasource.length) {
                this.selectedTextareaIdx = this.selectedTextareaIdx - 1;
            }
        }
    },
    changeMmsOriginDataStatus() {
        if (this.mmsEditList.length === 0) {
            this.pictureListFromGallery.forEach((item) => {
                item.checkedValue = false;
            });
            return;
        }
        let paths = [];
        for(let mms of this.mmsEditList) {
            paths.push(mms.uriPath);
        }
        for (let pic of this.pictureListFromGallery) {
            if (paths.indexOf(pic.path) > -1) {
                pic.checkedValue = true;
            } else {
                pic.checkedValue = false;
            }
        }
    },
    clickToDeleteSlide() {
        if (this.messageType === common.MESSAGE_TYPE.PPT) {
            this.deleteSlideFromPptType();
        } else if (this.messageType === common.MESSAGE_TYPE.THEME_AND_PPT) {
            this.deleteSlideFromThemeAndPptType();
        }
        if (this.messageType === common.MESSAGE_TYPE.NORMAL || this.messageType === common.MESSAGE_TYPE.THEME) {
            if(this.mmsEditList.length > 0) {
                let obj = this.mmsEditList[0];
                obj.index = -1;
                this.mmsEditList.splice(1, this.mmsEditList.length - 1);
            }
        } else {
            this.resetMmsEditListFromDatasource();
        }
        this.changeMmsOriginDataStatus();
        this.clickToCloseSlideDialog();
        if((this.textareaDatasource.length == 0 || (this.textareaDatasource.length == 2
        && this.messageType == common.MESSAGE_TYPE.THEME)) && this.mmsEditList.length == 0) {
            this.convertingSms();
        }
    },
    changeMmsValue(e) {
        let item = this.textareaDatasource[this.selectedTextareaIdx];
        item.textValue = e.text;
        if(this.textareaDatasource.length == 2 && this.mmsEditList.length == 0 && e.text != common.string.EMPTY_STR
        && this.messageType == common.MESSAGE_TYPE.THEME) {
            this.convertingMms();
        }
        if(this.textareaDatasource.length == 0 && this.mmsEditList.length == 0 && e.text == common.string.EMPTY_STR
        && this.messageType == common.MESSAGE_TYPE.THEME) {
            this.convertingSms();
        }
    },
    clickToPreviewSlide() {
        let item = {};
        let mmsSource = this.getMmsSource();
        item.mms = mmsSource;
        this.clickMms(item, false);
    },
    clickMms(item, isShow) {
        router.push({
            uri: 'pages/slide_detail/slide_detail',
            params: {
                mms: item,
                threadId: this.threadId,
                isShowBottom: isShow
            }
        });
    },
    clickToShowDurationDialog() {
        this.$element('slideDurationDialog').show();
    },
    chooseSlideDuration(item) {
        this.slideDuration = item;
        this.$element('slideDurationDialog').close();
    },
    // 订阅公共事件
    subscribeDetail() {
        mmsLog.info('JS_conversation: subscribe()');
        let events = [common.string.RECEIVE_TRANSMIT_EVENT]
        let commonEventSubscribeInfo = {
            events: events
        };
        // 创建订阅信息
        commonEvent.createSubscriber(commonEventSubscribeInfo, this.createSubscriberCallBack.bind(this));
    },
    createSubscriberCallBack(err, data) {
        this.commonEventData = data;
        // 接收到订阅
        commonEvent.subscribe(this.commonEventData, this.subscriberCallBack.bind(this));
    },
    subscriberCallBack(err, data) {
        mmsLog.info('JS_conversation: eventData');
        // 接收短信更新
        setTimeout(() => {
            this.queryMessageDetail(this.strContactsNumber, this.threadId);
            let valueBucket = {
                'unread_count': 0,
            };
            let actionData = {
                threadIds: [this.threadId],
                rdbStore: this.$app.$def.rdbStore,
                featureAbility: this.$app.$def.featureAbility,
                ohosDataAbility: this.$app.$def.ohosDataAbility,
                hasRead: 0,
                valueBucket: valueBucket
            };
            notificationService.cancelMessageNotify(actionData, res => {
                actionData.hasRead = 1;
                conversationListService.markAllAsRead(actionData);
            });
        }, 500);
    },
    // 取消订阅
    unSubscribeDetail() {
        commonEvent.unsubscribe(this.commonEventData, () => {
            mmsLog.info('conversation unsubscribe');
        });
    },
    // 新建页面,返回的联系人数据
    setReceiveContactValue(e) {
        let receiveContactValue = e.detail.contactValue;
        let selectContacts = e.detail.selectContacts;
        let hasBlur = e.detail.hasBlur;
        let telephone = common.string.EMPTY_STR;
        this.setCanSendMessage(selectContacts, receiveContactValue);
        if (hasBlur && receiveContactValue != common.string.EMPTY_STR) {
            let index = -1;
            for(let i in selectContacts) {
                let contact = selectContacts[i];
                if(contact.telephone == receiveContactValue) {
                    index = i;
                    break;
                }
            }
            if(index >= 0) {
                selectContacts.splice(index, 1);
            }
        }
        if(receiveContactValue != common.string.EMPTY_STR) {
            this.receiveContactValue = receiveContactValue;
        } else {
            this.receiveContactValue = common.string.EMPTY_STR;
        }
        if(selectContacts.length > 0) {
            this.selectContacts = selectContacts;
        } else {
            this.selectContacts = [];
        }
        if (this.selectContacts.length > 0) {
            for (let element of this.selectContacts) {
                telephone = telephone + element.telephone + common.string.COMMA;
            }
        }
        if(this.receiveContactValue != common.string.EMPTY_STR) {
            telephone = telephone + this.receiveContactValue + common.string.COMMA;
        }
        if (telephone != common.string.EMPTY) {
            telephone = telephone.substring(0, telephone.length - 1);
        }
        this.initSendTip();
        this.queryOldMessageList(telephone);
    },
    setCanSendMessage(selectContacts, receiveContactValue) {
        if (this.textValue != common.string.EMPTY_STR || this.isEditMms) {
            if (this.canSendMessage) {
                if (selectContacts.length == 0 && receiveContactValue == common.string.EMPTY_STR) {
                    this.canSendMessage = false;
                }
            } else if ((selectContacts.length != 0 || receiveContactValue != common.string.EMPTY_STR)
            && this.haveSimCard) {
                this.canSendMessage = true;
            }
        }
    },
    queryOldMessageList(telephone) {
        if(telephone == common.string.EMPTY_STR) {
            return;
        }
        let conversationListService = this.$app.$def.conversationListService;
        let rdbStore = this.$app.$def.rdbStore;
        let number = telephoneUtil.dealTelephoneSort(telephone);
        conversationListService.querySessionByTelephone(rdbStore, number, res => {
            if (res.code == common.int.SUCCESS && res.response.id > 0) {
                this.threadId = res.response.id;
                this.queryMessageDetail(telephone, res.response.id);
            } else {
                this.threadId = 0;
                this.mmsList = [];
            }
        });
    },
    cardSelect(e) {
        this.slotId = e.value;
    },
    mmsDetailsCancel() {
        // 取消短信弹窗
        this.$element('mms_details_dialog').close();
    },
    getTime(nS) {
        var date = new Date(parseInt(nS));
        var year = date.getFullYear();
        var mon = date.getMonth() + 1;
        var day = date.getDate();
        return year + this.$t('strings.year') + mon + this.$t('strings.month') + day + this.$t('strings.day');
    },
    queryFromGallery() {
        // 从图库中获取图片和视频
        if (this.pictureListFromGallery.length != 0) {
            return;
        }
        let that = this;
        conversationService.queryFromGallery({}, function (result) {
            if (result.code == common.int.SUCCESS) {
                that.pictureListFromGallery = result.pictureListFromGallery;
            } else {
                mmsLog.info('JS_conversation: ' + 'Error: queryFromGallery() failed !!!');
            }
        });
    },
    sendSms(content, msgUriPath, isMms, mmsSource) {
        mmsLog.info('JS_conversation , sendSms start');
        // 全屏页面发送短信
        this.isSendStatus = true;
        // 初始化需要发送的数据
        this.initSendSms(content, msgUriPath, isMms, mmsSource);
        let actionData = {
            slotId: this.slotId,
            destinationHost: this.strContactsNumber,
            content: content,
            isEditMms: isMms
        };
        this.dealNewRecallMessagesFlag(this.mmsList);
        mmsLog.info('JS_conversation , sendSms send start');
        // 取消发送及正常发送方法
        this.sendInterval(actionData, this.mmsList);
        mmsLog.info('JS_conversation , sendSms send end');
        if (this.isEditMms) {
            this.isEditMms = false;
        }
        if (this.$app.$def.sendFlag) {
            this.$app.$def.sendFlag = false;
            this.$app.$def.textValueOther = common.string.EMPTY_STR;
        }
        if (this.$app.$def.transmitFlag) {
            this.$app.$def.transmitFlag = false;
        }
    },
    initSendSms(content, msgUriPath, isMms, mmsSource) {
        // 获取当天是星期几
        let item = {};
        item.date = common.string.EMPTY_STR;
        item.time = this.$t('strings.just');
        item.timeMillisecond = new Date().getTime();
        let dataUtil = this.$app.$def.dateUtil;
        dataUtil.convertTimeStampToDateWeek(item, false, this);
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
        let preferences = this.$app.$def.preferences;
        item.hasReport = settingService.judgeIsDeliveryReport(preferences, item.isMsm);
        item.mmsSource = mmsSource;
        if (this.isEditMms || isMms) {
            item.msgShowType = commonService.getDisplay(mmsSource);
            commonService.setItemMmsContent(item, mmsSource);
            item.content = this.dealItemContent(item.msgShowType, item.content, mmsSource);
        } else {
            item.msgShowType = common.MESSAGE_SHOW_TYPE.NORMAL;
        }
        this.mmsList.push(item);
    },
    cancelResend() {
        // 发送按钮点击取消按钮取消对话框
        this.$element('mms_fail_dialog').close();
        this.reSendIndex = 0;
    },
    resend() {
        // 需要删除的item
        let deleteItem = this.mmsList[this.reSendIndex];
        if(this.reSendIndex == 0) {
            this.mmsDateSet.clear();
        }
        // 删除当前的item
        this.mmsList.splice(this.reSendIndex, 1);
        // 删除数据库的数据
        let groupIds = [deleteItem.groupId];
        this.deleteMessageByGroupIds(groupIds);
        let item = this.initReSendItem(deleteItem);
        // 如果设置取消发送，直接设置为true
        this.dealNewRecallMessagesFlag(this.mmsList);
        this.$element('mms_fail_dialog').close();
        this.resendSms(this.strContactsNumber, item.content, item.isMsm, this.mmsList);
    },
    initReSendItem(deleteItem) {
        let item = {};
        item.content = deleteItem.content;
        item.msgType = deleteItem.msgType;
        item.isFullScreenImg = deleteItem.isFullScreenImg;
        item.msgUriPath = deleteItem.msgUriPath;
        item.audioTime = deleteItem.audioTime;
        item.isCbChecked = deleteItem.isCbChecked;
        item.isLock = deleteItem.isLock;
        item.isStared = deleteItem.isStared;
        item.isReceive = false;
        item.subId = this.slotId;
        item.groupId = deleteItem.groupId;
        item.isMsm = deleteItem.isMsm;
        item.failuresTelephone = deleteItem.failuresTelephone;
        item.completeNumber = deleteItem.completeNumber;
        item.failuresNumber = deleteItem.failuresNumber;
        // 取消发送数量
        if (this.contactsNum > common.int.MESSAGE_CODE_ONE) {
            item.cancelTimeCount = common.int.MESSAGE_CODE_ZERO;
        } else {
            item.cancelTimeCount = common.int.CANCEL_TIME_COUNT;
        }
        // 获取当天是星期几
        item.date = common.string.EMPTY_STR;
        item.time = this.$t('strings.just');
        item.timeMillisecond = new Date().getTime();
        let dataUtil = this.$app.$def.dateUtil;
        dataUtil.convertTimeStampToDateWeek(item, false, this);
        // 发送状态
        item.sendStatus = 1;
        if (this.contactsNum > 1 && !item.isMsm) {
            item.completeNumber = this.contactsNum - item.failuresNumber;
            item.failuresNumber = 0;
        }
        // 填充图片，用于取消发送使用
        item.mmsEditListTemp = this.fillmmsEditListTemp(item.msgUriPath, item.isMsm);
        let preferences = this.$app.$def.preferences;
        item.hasReport = settingService.judgeIsDeliveryReport(preferences, item.isMsm);
        item.msgShowType = deleteItem.msgShowType;
        if (deleteItem.mms != null) {
            item.mmsSource = deleteItem.mms;
        }
        if (deleteItem.mmsSource != null) {
            item.mmsSource = deleteItem.mmsSource;
        }
        this.mmsList.push(item);
        return item;
    },
    resendSms(destinationHost, content, isMsm, mmsList) {
        let actionData = {
            slotId: this.slotId,
            destinationHost: destinationHost,
            content: content,
            isEditMms: isMsm
        };
        if (this.contactsNum > common.int.MESSAGE_CODE_ONE) {
            // 判断当前的重新发送是在'群组'中，则不能双击取消发送
            this.handleWithSend(actionData, mmsList[mmsList.length - 1]);
        } else {
            // 若发送的是'个人'，则可以双击取消
            this.sendInterval(actionData, mmsList);
        }
    },
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
            this.paramContact.isNewRecallMessagesFlag = true;
        }
        if (count == common.int.MESSAGE_CODE_ZERO && this.isNewRecallMessagesFlag) {
            this.isNewMsg = true;
            this.isNewRecallMessagesFlag = false;
        }
    },
    fillmmsEditListTemp(msgUriPath, isMsm) {
        let mmsEditListTemp = [];
        if (this.recallMessagesFlag && isMsm) {
            let item = {};
            item.type = common.MSG_ITEM_TYPE.IMAGE;
            item.uriPath = msgUriPath;
            mmsEditListTemp.push(item);
        }
        return mmsEditListTemp;
    },
    resendOpen(index) {
        // 点击失败图片，唤起dialog
        this.$element('mms_fail_dialog').show();
        this.reSendIndex = index;
    },
    jumpToContactsCallingCard() {
        let actionData = {
            featureAbility: this.$app.$def.featureAbility,
            ohosDataAbility: this.$app.$def.ohosDataAbility,
        };
        contactService.judgeIsExitProfile(actionData, flag => {
            if (flag) {
                let jumpData = {
                    pageFlag: common.contractPage.PAGE_FLAG_CALLING_CARD
                }
                this.jumpToContract(jumpData);
            } else {
                mmsLog.info('jumpToCard is error');
            }
        })
    },
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
    },
    // 获取整合通知信息和显示联系人头像的开关值
    getSettingFlagForConvListPage() {
        let preferences = this.$app.$def.preferences;
        let result = settingService.getSettingFlagForConvListPage(preferences);
        if (result) {
            this.recallMessagesFlag = result.recallMessagesFlag;
        } else {
            mmsLog.info('getSettingFlagForConvListPage(): result is null');
        }
    },
    // 分享输入框输入的文本内容
    shareTextAtTextarea(e) {
        if (e.value == common.string.EMPTY_STR) {
            return;
        }
        let actionData = {};
        actionData.content = e.value;
    },
    // 搜索输入框输入的文本内容，需要跳转至'浏览器'app
    searchTextAtTextarea(e) {
        if (e.value == '') {
            return;
        }
        let messageCode = common.route.MESSAGE_CODE_JUMP_TO_BROWSER_TO_SEARCH;
        let actionData = {};
        actionData.content = e.value;
        // 跳转到 '浏览器'app
    },
    cutCamera() {
        // 切换前后置摄像头
        if (this.cameraPattern == 'back') {
            this.cameraPattern = 'front';
            this.pattern = this.$t('strings.camera_front');
        } else {
            this.cameraPattern = 'back';
            this.pattern = this.$t('strings.camera_post');
        }
    },
    shootButton() {
        mmsLog.log('camera success: ..............');
        // 相机拍摄按钮
        this.$element('cameraApp').takePhoto({
            quality: 'low',
            success: function (data) {
                mmsLog.log('camera  .get success: ' + data);
            },
            fail: function (data, code) {
                mmsLog.log('camera get fail, code: ' + code + ', data: ' + data);
            },
            complete: function () {
                mmsLog.log('camera  complete');
            }
        });
    },
    clickHighlights(obj) {
        let type = obj.detail.type;
        this.highlightsType = type;
        this.highlightsText = obj.detail.value;
        this.$element('highlightDialog').show();
    },
    cancelHighlightDialog() {
        this.$element('highlightDialog').close();
    },
    clickHighlightsDialogCell(obj) {
        let index = obj.detail;
        if (this.highlightsType === common.HIGHLIGHT_TYPE.TEL) {
            // 电话
            this.clickTelCellAction(index);
        } else if (this.highlightsType === common.HIGHLIGHT_TYPE.EMAIL) {
            // 邮箱
            this.clickEmailCellAction(index);
        } else if (this.highlightsType === common.HIGHLIGHT_TYPE.DATE) {
            // 时间
            this.clickDateCellAction(index);
        }
        this.cancelHighlightDialog();
    },
    clickTelCellAction(index) {
        switch (index) {
            case 0:
            // 呼叫
                this.call(this.highlightsText);
                break;
            case 1:
            // 呼叫前编辑
                this.callEditor(this.highlightsText);
                break;
            case 2:
            // 发送信息
                this.jumpToConversationPage(this.highlightsText);
                break;
            case 3:
            // 复制到剪贴板
                commonPasteboard.setPasteboard(this.highlightsText);
                break;
            case 4:
            // 新建联系人
                this.createNewContract(this.highlightsText);
                break;
            case 5:
            // 保存至已有联系人
                this.existingContact(this.highlightsText);
                break;
            default:
                mmsLog.info('clickTelCellAction, code is not exit');
        }
    },
    clickEmailCellAction(index) {
        switch (index) {
            case 0:
            // 发送信息
                this.jumpToConversationPage(this.highlightsText);
                break;
            case 1:
            // 发送邮件
                break;
            case 2:
            // 复制到剪贴板
                commonPasteboard.setPasteboard(this.highlightsText);
                break;
            case 3:
            // 新建联系人
                this.createNewContract(this.highlightsText);
                break;
            case 4:
            // 保存至已有联系人
                this.existingContact(this.highlightsText);
                break;
            default:
                mmsLog.info('clickEmailCellAction, code is not exit');
        }
    },
    clickDateCellAction(index) {
        if (index === 0) {
            // 新建日期提醒
        } else {
            // 复制到剪贴板
            commonPasteboard.setPasteboard(this.highlightsText);
        }
    },
    jumpToConversationPage(tel) {
        this.strContactsNumber = tel;
        this.contactsNum = 1;
    },
    showToast(msg) {
        Prompt.showToast({
            message: msg,
            duration: 2000,
        });
    },
    // 跳转联系人app
    jumpToContract(actionData) {
        let commonService = this.$app.$def.commonService;
        let str = commonService.commonContractParam(actionData);
        let featureAbility = this.$app.$def.featureAbility;
        featureAbility.startAbility(str).then((data) => {
            mmsLog.info('Js_conversation jumpToContract Data');
        }).catch((error) => {
            mmsLog.error('Js_conversation jumpToContract failed. Cause: ' + JSON.stringify(error));
        })
    },
}