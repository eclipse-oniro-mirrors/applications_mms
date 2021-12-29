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
import router from '@system.router';
import settingService from '../../service/SettingService.js';
import contactService from '../../service/ContractService.js';
import common from '../common_constants.js';
import commonService from '../../service/CommonService.js'

const TAG = 'transmit_msg.js ->';

export default {
    data: {
        // 总数
        total: 0,
        // 信息列表
        contractsList: [],
        // 多条信息转发的内容列表
        transmitContentList: [],
        // 双卡
        doubleCard: false,
        // 内容
        content: '',
        // 彩信附件地址
        msgUriPath: '',
        // 联系人数量
        contactsNum: 0,
        // 联系人名称
        contactName: '',
        // 格式化手机号
        telephoneFormat: '',
        // 多人群发只展示一个人
        contactNameSplit: '',
        // 多人群发只展示一个手机号
        telephoneFormatSplit: '',
        // 手机号
        telephone: '',
        // 是否被选中
        isChecked: true,
        // 是否是彩信
        isMms: false,
        // 卡1
        simOne: 0,
        // 卡2
        simTwo: 1,
        // 发送短信ID
        threadId: '',
        // 是否是多条信息转发
        isMulti: false,
        // 转发内容标题
        transmitContent: '',
        // 转发内容编辑状态内容
        transmitContentEdit: '',
        // 转发内容编辑状态内容备份，用于对比原值
        transmitContentEditBackup: '',
        // 转发多条内容备份，用于比较原值
        transmitContentsBackup: [],
        // 是否禁用checkbox
        isDisabled: false,
        // 操作类型
        operatorType: 4,
        // 是否展示转发弹框
        contractsPage: false,
        // dialog标题字体大小展示，字数少时展示大字体，字数多时展示小字体
        titleChecked: false,
        // dialog标题中联系人长度临界值
        contactNameLen: 20,
        // 一行的像素大小
        rowPixel: 48,
        // list列表最大的高度
        maxListPixel: 380,
        // 每一行的字符数量
        rowCharacterNum: 18,
        // dialog中的list动态高度
        dynamicHeight: 0,
        // 文本在list中的索引
        textIndex: 0,
        // 多条内容转发是否包含文本
        includeTextSMS: true,
        // 转发内容是否可以发送，若为空，则不能发送
        isCanSend: false,
        // 分页页数
        page: 0,
        // 分页数量
        limit: 15,
        // 是否显示联系人头像
        isShowContactHeadIcon: true,
        // 是否是收藏页面
        isMyStartPage: false,
        // 是否是彩信幻灯片页面
        isSlideDetail: false,
        // 彩信列表的数据
        mmsSource: [],
        transmitItemSources: []
    },
    onInit() {
        this.total = this.contractsList.length;
        mmsLog.info('transmitMsg onInit() !!!');
    },
    onShow() {
        mmsLog.info('transmitMsg onShow() !!!');
        // 获取是否显示头像的状态
        this.getSettingFlagForConvListPage();
        // 判断联系人字体长度
        this.checkContactNameLen();
        // 查询文本在list中的索引
        this.queryTestIndex();
    },
    // 获取整合通知信息和显示联系人头像的开关值
    getSettingFlagForConvListPage() {
        let preferences = this.$app.$def.preferences;
        let result = settingService.getSettingFlagForConvListPage(preferences);
        if (result) {
            this.isShowContactHeadIcon = result.isShowContactHeadIcon;
        }
    },
    checkContactNameLen() {
        if (this.contactName != null && this.contactName.length > this.contactNameLen) {
            this.titleChecked = true;
        } else {
            this.titleChecked = false;
        }
    },
    // 显示转发弹框
    showTransmitDialog() {
        let that = this;
        setTimeout(function () {
            if (that.contractsPage) {
                that.isChecked = true;
                that.transmitContentAssembly();
                that.dynamicHeight = commonService.getTransmitContentHeight(that.transmitContentList);
                if (that.contactName != null || that.contactName != '') {
                    that.$element('dialog').show();
                }
            }
        }, 200);
    },
    // 查找文本索引位置
    queryTestIndex() {
        for (let index = 0; index < this.transmitContentList.length; index++) {
            if (!this.transmitContentList[index].msgUriPath) {
                this.textIndex = index;
                break;
            }
        }
    },
    requestItem() {
        mmsLog.info('requestItem,start---------');
        let count = this.page * this.limit;
        if (this.page === 0) {
            this.page++;
            this.queryAllMessages();
        } else if (count < this.total && this.contractsList.length > (this.page - 1) * this.limit) {
            // 对messageList的限制，是防止初始化时多次刷新请求
            this.page++;
            this.queryAllMessages();
        }
    },
    // 查询列表数据
    queryAllMessages() {
        let that = this;
        let actionData = {
            featureAbility: this.$app.$def.featureAbility,
            ohosDataAbility: this.$app.$def.ohosDataAbility
        };
        actionData.page = this.page;
        actionData.limit = this.limit;
        let rdbStore = this.$app.$def.rdbStore;
        let conversationListService = this.$app.$def.conversationListService;
        conversationListService.querySessionList(rdbStore, actionData, result => {
            mmsLog.info(TAG + 'querySessionList,success');
            if (result.code == common.int.SUCCESS) {
                that.contractsList = that.contractsList.concat(result.response);
                that.total = that.contractsList.length;
            } else {
                mmsLog.info(TAG + 'Error: queryAllMessages() failed !!!');
            }
        });
    },
    // 点击list.获取发送的dialog
    clickSendMessage(index) {
        this.contactsNum = this.contractsList[index].contactsNum;
        this.contactName = this.contractsList[index].name;
        this.telephoneFormat = this.contractsList[index].telephoneFormat;
        this.telephone = this.contractsList[index].telephone;
        this.threadId = this.contractsList[index].threadId;
        this.contactNameSplit = this.contactName.split(',')[0];
        this.telephoneFormatSplit = this.telephoneFormat.split(',')[0];
        // 判断联系人字体长度
        this.checkContactNameLen();
        if(this.isSlideDetail) {
            this.$element('dialog_transmit').show();
        } else {
            this.isChecked = true;
            this.transmitContentAssembly();
            this.dynamicHeight = commonService.getTransmitContentHeight(this.transmitContentList);
            // 唤醒dialog
            this.$element('dialog').show();
        }
    },
    // 是否选中判断
    clickChecked(e) {
        this.isChecked = e.checked;
        this.transmitContentAssembly();
    },
    transmit(slotId) {
        mmsLog.info('transmit,start');
        this.$app.$def.slotId = slotId;
        this.$app.$def.threadId = this.threadId;
        this.$app.$def.contactsNum = this.contactsNum;
        this.$app.$def.strContactsName = this.contactName;
        this.$app.$def.strContactsNumber = this.telephone;
        this.$app.$def.strContactsNumberFormat = this.telephoneFormat;
        this.$app.$def.transmitFlag = true;
        this.$app.$def.transmitContent = common.string.EMPTY_STR;
        this.$app.$def.mmsSource = this.mmsSource;
        this.$app.$def.isSlideDetail = this.isSlideDetail;
        this.$app.$def.transmitSource = this.transmitContentList;
        this.$app.$def.isContainerOriginSource = this.isChecked;
        this.contractsPage = false;
        if (this.isMyStartPage || this.isSlideDetail) {
            router.replace({
                uri: 'pages/conversation/conversation'
            });
        } else {
            router.back();
        }
    },
    // 转发内容封装
    transmitContentAssembly() {
        this.includeTextSMS = commonService.checkIsMms(this.transmitContentList);
        if (!this.includeTextSMS) {
            return;
        }
        let number = 0;
        this.transmitContentList.forEach((element) => {
            element.contentInfo = common.string.EMPTY_STR;
            if (!element.isMsm) {
                if (number == 0) {
                    element.contentInfo = this.transmitContent + '\n';
                    number ++;
                }
                if (this.transmitContentList.length > 1) {
                    element.contentInfo = element.contentInfo + element.date + ' ';
                    element.contentInfo = element.contentInfo + element.time + ' ' + element.contactsName + '\n';
                }
            }
        });
    },
    // 包含转发信息来源按钮切换-短信
    changeValue(item, e) {
        item.content = e.text;
    },
    // 重置转发内容
    resetTransmitContent() {
        if (this.isMms) {
            this.transmitContentsBackup.forEach((element, index) => {
                if (element.msgUriPath == common.string.EMPTY_STR) {
                    this.transmitContents[index].content = element.contentEditBackup;
                }
            });
        } else {
            this.transmitContentEdit = this.transmitContentEditBackup;
        }
    },
    // 点击取消按钮取消对话框
    cancelTransmit() {
        this.resetTransmitContent();
        if(this.isSlideDetail) {
            this.$element('dialog_transmit').close();
        } else {
            this.$element('dialog').close();
        }
    },
    // 轻触其他地方取消对话框
    cancelDialog() {
        this.resetTransmitContent();
    },
    cancel() {
        router.back();
    },
    // 跳转到搜索页面
    jumpSearchClick() {
        let isMulti = false;
        if (this.isMulti) {
            isMulti = true;
        }
        router.push({
            uri: 'pages/transmit_search/transmit_search',
            params: {
                doubleCard: this.doubleCard,
                content: this.content,
                msgUriPath: this.msgUriPath,
                transmitContent: this.transmitContent,
                transmitContentList: this.transmitContentList,
                isMulti: isMulti,
                isMms: this.isMms,
                isSlideDetail: this.isSlideDetail,
                mmsSource: this.mmsSource
            }
        });
    },
    // 跳转到选择联系人页面
    jumpToSelectContracts() {
        // 跳转到选择联系人页面
        var actionData = {};
        actionData.pageFlag = common.contractPage.PAGE_FLAG_MULT_CHOOSE;
        this.jumpToContractForResult(actionData);
    },
    // 点击头像，单人跳转联系人，多人跳转收件人详情
    clickToGroupDetail(index) {
        // 判断跳转到联系人详情还是跳转到多个收件人的列表页面
        let contactsNum = this.contractsList[index].contactsNum;
        let telephone = this.contractsList[index].telephone;
        let threadId = this.contractsList[index].threadId;
        if (contactsNum > 1) {
            this.jumpToGroupDetailList(threadId, contactsNum);
        } else {
            var actionData = {};
            actionData.phoneNumber = telephone;
            actionData.pageFlag = common.contractPage.PAGE_FLAG_CONTACT_DETAILS;
            this.jumpToContractDetail(actionData);
        }
    },
    // 跳转联系人app
    jumpToContractDetail(actionData) {
        let commonService = this.$app.$def.commonService;
        let str = commonService.commonContractParam(actionData);
        mmsLog.info('jumpToContractDetail,result:' + str);
        let featureAbility = this.$app.$def.featureAbility;
        featureAbility.startAbility(str).then((data) => {
            mmsLog.info('jumpToContractDetail, data: ' + data);
        }).catch((error) => {
            mmsLog.error('jumpToContractDetail failed. Cause: ' + JSON.stringify(error));
        });
    },
    // 跳转联系人app
    async jumpToContractForResult(actionData) {
        let commonService = this.$app.$def.commonService;
        let str = commonService.commonContractParam(actionData);
        let featureAbility = this.$app.$def.featureAbility;
        let data = await featureAbility.startAbilityForResult(str);
        if (data.resultCode == 0) {
            this.contractsPage = true;
            let contactsParam = contactService.dealContractParams(data.want.parameters.contactObjects);
            this.contactsNum = contactsParam.contactsNum;
            this.contactName = contactsParam.strContactsName;
            this.telephoneFormat = contactsParam.strContactsNumberFormat;
            this.telephone = contactsParam.strContactsNumber;
            this.contactNameSplit = contactsParam.strContactsName.split(common.string.COMMA)[0];
            this.telephoneFormatSplit = contactsParam.strContactsNumberFormat.split(common.string.COMMA)[0];
            let conversationListService = this.$app.$def.conversationListService;
            let rdbStore = this.$app.$def.rdbStore;
            conversationListService.querySessionByTelephone(rdbStore, this.telephone, res => {
                let response = res.response;
                if (res.code === common.int.SUCCESS && response.id > 0) {
                    this.threadId = response.id;
                } else {
                    this.threadId = 0;
                }
                this.showTransmitDialog();
            });
        }
    },
    // 跳转多人头像列表页面
    jumpToGroupDetailList(sessionId, contactsNum) {
        let actionData = {
            uri: 'pages/group_detail/group_detail',
            params: {
                threadId: sessionId,
                contactsNum: contactsNum
            }
        }
        router.push(actionData);
    },
}