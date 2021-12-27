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
// JS公共常量
import common from '../common_constants.js';
import settingService from '../../service/SettingService.js'
import contractService from '../../service/ContractService.js'
import commonService from '../../service/CommonService.js'

// 搜索的数量
const SEARCH_TOTAL = 3;
// 文本长度
const TEXT_LENGTH = 2;
const TAG = 'transmit_search.js ->';

export default {
    data: {
        // 所有短信的总条数
        total: 0,
        // 通知信息内的数据
        messageListForInfo: [],
        // 如果通知信息整合开关打开，则是非通知信息+非大麦通知，如果没有打开，则是所有数据
        messageList: [],
        // 搜索结果列表
        searchResultList: [],
        // 搜索结果的个数
        countOfSearchResult: 0,
        // 是否展示通知信息
        hasInfoMsg: false,
        // 通知信息整合开关'是否打开，该开关在设置里
        hasAggregate: false,
        // 搜索匹配到的联系人
        contactsMatching: [],
        // 搜索匹配到的联系人备份
        contactsMatchingBackup: [],
        // 是否搜到联系人
        searchMatchResult: false,
        // 搜索状态
        showSearchStatus: '',
        // 信息列表
        contractsList: [],
        // 多条信息转发的内容列表
        transmitContentList: [],
        // 双卡
        doubleCard: false,
        // 内容
        content: '',
        // 联系人名称
        contactName: '',
        // 格式化手机号
        telephoneFormat: '',
        // 手机号
        telephone: '',
        // 是否被选中
        isChecked: true,
        // 发送短信ID
        threadId: 0,
        // 是否是彩信
        isMms: false,
        // 是否是多条信息转发
        isMulti: false,
        // 转发内容标题
        transmitContent: '',
        // 格式化后的转发内容
        transmitContentFormat: '',
        // 转发多条内容备份，用于比较原值
        transmitContentsBackup: [],
        // 是否禁用checkbox
        isDisabled: false,
        // 转发多条内容
        transmitContents: [],
        // 操作类型
        operatorType: 4,
        // 是否展示转发弹框
        contractsPage: false,
        // dialog标题字体大小展示，字数少时展示大字体，字数多时展示小字体
        titleChecked: false,
        // dialog标题中联系人长度临界值
        contactNameLen: 25,
        // 卡1
        simOne: 0,
        // 卡2
        simTwo: 1,
        // 是否输入文本
        isInputText: false,
        // 搜索联系人数量文本提示
        contactsFoundText: '',
        // 是否展开或者收起文本
        openOrRetract: true,
        // 显示展开或者收起文本
        showOpenOrRetract: '',
        // 转发内容编辑状态内容备份，用于对比原值
        transmitContentEditBackup: '',
        // 转发内容编辑状态内容
        transmitContentEdit: '',
        // 搜索到的总数
        searchTotal: 0,
        // 一行的像素大小
        rowPixel: 48,
        // list列表最大的高度
        maxListPixel: 350,
        // 每一行的字符数量
        rowCharacterNum: 18,
        // dialog中的list动态高度
        dynamicHeight: 0,
        // 判断输入的号码大于三位，显示发送至该输入的号码
        judgeSendInputText: false,
        // 输入框中的值
        myText: '',
        // 文本在list中的索引
        textIndex: 0,
        // 多条内容转发是否包含文本
        includeTextSMS: true,
        // 转发内容是否可以发送，若为空，则不能发送
        isCanSend: false,
        // 是否显示联系人头像
        isShowContactHeadIcon: true,
        // 是否是彩信幻灯片页面
        isSlideDetail: false,
        // 彩信列表的数据
        mmsSource: [],
        // 分页页数
        page: 1,
        // 分页数量
        limit: 10,
        transmitItemSources: []
    },
    onInit() {
        this.queryAllMessages();
        this.getSettingFlagForConvListPage();
        this.showSearchStatus = this.$t('strings.there_is_no_match');
        this.showOpenOrRetract = this.$t('strings.contacts_open');
    },
    onShow() {
        this.$element('search').focus();
    },
    // 应用初始化时加载该用户的所有短信
    queryAllMessages() {
        let actionData = {};
        let rdbStore = this.$app.$def.rdbStore;
        actionData.page = this.page;
        actionData.limit = this.limit;
        actionData.featureAbility = this.$app.$def.featureAbility;
        actionData.ohosDataAbility = this.$app.$def.ohosDataAbility;
        let conversationListService = this.$app.$def.conversationListService;
        conversationListService.querySessionList(rdbStore, actionData, result => {
            if (result.code == common.int.SUCCESS) {
                this.messageList = result.response;
                this.total = this.messageList.length;
            } else {
                mmsLog.info(TAG + 'Error: queryAllMessages() failed !!!');
            }
        });
    },
    // 获取整合通知信息和显示联系人头像的开关值
    getSettingFlagForConvListPage() {
        let preferences = this.$app.$def.preferences;
        let result = settingService.getSettingFlagForConvListPage(preferences);
        if (result) {
            this.hasInfoMsg = result.hasAggregate;
        }
    },
    // 过滤搜索词匹配联系人
    filterContacts(textValue) {
        this.contactsMatching = this.contacts.filter((contact) => {
            if (contact.contactName && contact.contactName.toLowerCase().search(textValue) != -1) {
                mmsLog.info(TAG + 'jsRe searchChange contactName==>');
                return true;
            } else if (contact.telephone && contact.telephone.toLowerCase().search(textValue) != -1) {
                mmsLog.info('jsRe searchChange telephone==>');
                return true;
            }
            return false;
        });
    },
    // 在信息列表页面搜索
    clickToSearch(e) {
        this.myText = e.text;
        let reg = /^[0-9]*$/;
        let textValue = common.string.EMPTY_STR;
        // 判断输入内容为全数字将空格去除,用于正确匹配
        if (reg.test(textValue)) {
            textValue = this.myText.replace(/\s*/g, '');
        } else {
            textValue = this.myText;
        }
        if (textValue == common.string.EMPTY_STR) {
            this.contactsMatching = [];
            this.searchMatchResult = false;
            this.isInputText = false;
        } else {
            this.setJudgeSendInputText(reg, textValue);
            textValue = textValue.toLowerCase();
            // 过滤逻辑
            this.searchContacts(textValue, code => {
                if (code == common.int.SUCCESS) {
                    this.dealSearchContactsResult();
                }
            });
            mmsLog.info(TAG + 'jsRe searchChange contactsMatching success');
        }
    },
    dealSearchContactsResult() {
        this.searchTotal = this.contactsMatching.length;
        if (this.searchTotal > 0) {
            this.contactsMatchingBackup = this.contactsMatching;
            this.searchMatchResult = true;
            this.contactsFoundText = this.$t('strings.contacts_found', {
                number: this.searchTotal
            });
            if (this.searchTotal > SEARCH_TOTAL && this.openOrRetract) {
                this.contactsMatching = this.contactsMatchingBackup.slice(0, SEARCH_TOTAL);
            }
        } else {
            this.searchMatchResult = false;
        }
        this.isInputText = true;
    },
    queryOldMessageList(telephone) {
        if (telephone == common.string.EMPTY_STR) {
            return;
        }
        let rdbStore = this.$app.$def.rdbStore;
        let listService = this.$app.$def.conversationListService;
        listService.querySessionByTelephone(rdbStore, telephone, result => {
            if (result.code == common.int.SUCCESS && result.response.id > 0) {
                this.threadId = result.response.id;
            } else {
                this.threadId = 0;
            }
        });
    },
    setJudgeSendInputText(reg, textValue) {
        if (this.myText.length > TEXT_LENGTH && reg.test(textValue)) {
            this.judgeSendInputText = true;
        } else {
            this.judgeSendInputText = false;
        }
    },
    searchContacts(textValue, callback) {
        mmsLog.log(TAG + 'searchContracts , contracts: start');
        let actionData = {
            telephone: textValue,
            featureAbility: this.$app.$def.featureAbility,
            ohosDataAbility: this.$app.$def.ohosDataAbility,
        };
        contractService.searchContracts(actionData, res => {
            let code = res.code;
            if (common.int.SUCCESS == res.code) {
                this.contactsMatching = [];
                this.contactsMatching = res.response;
            } else {
                mmsLog.log(TAG + 'searchContracts, fail');
            }
            callback(code);
        });
    },
    // 点击返回按钮退出搜索模式
    clickSearchBack() {
        router.back();
    },
    // 点击蒙层退出搜索模式
    searchCoverageClick() {
        router.back();
    },
    // 检查联系人长度值，调整字体大小
    checkContactNameLen() {
        if (this.contactName != null && this.contactName.length > this.contactNameLen) {
            this.titleChecked = true;
        } else {
            this.titleChecked = false;
        }
    },
    // 点击list，获取发送的dialog
    clickSendMessage(index) {
        if (this.contactsMatching[index].contactName) {
            this.contactName = this.contactsMatching[index].contactName;
            // 判断联系人长度大于20，显示小号字体
            this.checkContactNameLen();
        }
        this.telephoneFormat = this.contactsMatching[index].telephoneFormat;
        this.telephone = this.contactsMatching[index].telephone;
        this.queryOldMessageList(this.telephone);
        if (!this.isSlideDetail) {
            this.transmitContentAssembly();
            this.dynamicHeight = commonService.getTransmitContentHeight(this.transmitContentList);
            // 唤醒dialog
            this.$element('dialog').show();
        } else {
            this.$element('dialog_transmit').show();
        }
    },
    // 点击输入发送的号码，获取发送的dialog
    clickShowDialog() {
        this.contactName = common.string.EMPTY_STR;
        this.telephoneFormat = this.myText;
        this.telephone = this.myText;
        // 判断联系人长度大于20，显示小号字体
        if (this.myText.length > this.contactNameLen) {
            this.titleChecked = true;
        } else {
            this.titleChecked = false;
        }
        if(!this.isSlideDetail) {
            this.transmitContentAssembly();
            this.dynamicHeight = commonService.getTransmitContentHeight(this.transmitContentList);
            this.$element('dialog').show();
        } else {
            this.$element('dialog_transmit').show();
        }
    },
    // 是否选中判断
    clickChecked(e) {
        this.isChecked = e.checked;
        this.transmitContentAssembly();
    },
    // 转发
    transmit(slotId) {
        this.$app.$def.slotId = slotId;
        this.$app.$def.threadId = this.threadId;
        this.$app.$def.strContactsName = this.contactName;
        this.$app.$def.strContactsNumber = this.telephone;
        this.$app.$def.strContactsNumberFormat = this.telephoneFormat;
        this.$app.$def.transmitFlag = true;
        this.$app.$def.transmitContent = this.isChecked ?
            this.transmitContentFormat : this.transmitContentEdit;
        this.$app.$def.transmitContents = this.transmitContents;
        this.contractsPage = false;
        this.$app.$def.mmsSource = this.mmsSource;
        this.$app.$def.isSlideDetail = this.isSlideDetail;
        this.$app.$def.transmitSource = this.transmitContentList;
        this.$app.$def.isContainerOriginSource = this.isChecked;
        router.replace({
            uri: 'pages/conversation/conversation'
        });
    },
    // 转发内容封装
    transmitContentAssembly() {
        this.includeTextSMS = commonService.checkIsMms(this.transmitContentList);
        if (!this.includeTextSMS) {
            return;
        }
        let number = 0;
        this.transmitContentList.forEach((item) => {
            item.contentInfo = common.string.EMPTY_STR;
            if (!item.isMsm) {
                if (number == 0) {
                    item.contentInfo = this.transmitContent + '\n';
                    number ++;
                }
                if (this.transmitContentList.length > 1) {
                    item.contentInfo = item.contentInfo + item.date + ' ';
                    item.contentInfo = item.contentInfo + item.time + ' ' + item.contactsName + '\n';
                }
            }
        });
    },
    // 包含转发信息来源按钮切换-短信
    changeValue(item, e) {
        item.content = e.text;
    },
    // 轻触其他地方取消对话框
    cancelDialog() {
        this.resetTransmitContent();
    },
    // 用于联系人列表展开收回
    openRetract() {
        if (this.openOrRetract) {
            this.openOrRetract = false;
            this.showOpenOrRetract = this.$t('strings.contacts_retract');
            this.contactsMatching = [];
            this.contactsMatching = this.contactsMatchingBackup;
        } else {
            this.openOrRetract = true;
            this.showOpenOrRetract = this.$t('strings.contacts_open');
            this.contactsMatching = [];
            if (this.searchTotal > 3 && this.openOrRetract) {
                this.contactsMatching = this.contactsMatchingBackup.slice(0, 3);
            }
        }
    },
    // 重置转发内容
    resetTransmitContent() {
        if (!this.isMms) {
            this.transmitContentEdit = this.transmitContentEditBackup;
        } else {
            this.transmitContentsBackup.forEach((element, index) => {
                if (element.msgUriPath == common.string.EMPTY_STR) {
                    this.transmitContents[index].content = element.contentEditBackup;
                }
            });
        }
    },
    // 点击联系人头像，跳转至联系人详情
    titleBarAvatar(index) {
        var actionData = {};
        actionData.phoneNumber = this.contactsMatching[index].telephone;
        actionData.pageFlag = common.contractPage.PAGE_FLAG_CONTACT_DETAILS;
        this.jumpToContract(actionData);
    },
    // 跳转联系人app
    jumpToContract(actionData) {
        let commonService = this.$app.$def.commonService;
        var str = commonService.commonContractParam(actionData);
        let featureAbility = this.$app.$def.featureAbility;
        featureAbility.startAbility(str).then((data) => {
            mmsLog.info('transmit_search.js --->  Data: ' + data);
        }).catch((error) => {
            mmsLog.error('transmit_search.js ---> failed: ' + JSON.stringify(error));
        })
    },
    // 点击取消按钮取消对话框
    cancelTransmit() {
        this.resetTransmitContent();
        if(this.isSlideDetail) {
            this.$element('dialog_transmit').close();
        } else {
            this.$element('dialog').close();
        }
    }
}
