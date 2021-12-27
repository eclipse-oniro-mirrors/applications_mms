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
import mmsLog from '../../../../default/utils/MmsLog.js';
// 收件人
import prompt from '@system.prompt';
// JS公共常量
import common from '../../common_constants.js';
import contractService from '../../../service/ContractService.js';

const RECEIVE_TAG = 'receive.js -> ';

export default {
    props: ['paramContact'],
    data: {
        // 收件人信息(已经选择)
        selectContacts: [],
        contacts: [],
        // 收件人列表信息(所有的)
        contactsTemp: [],
        // 收件人内容
        myText: '',
        colorContact: '#000000',
        // true 焦点编辑状态(灰色), false无焦点状态(蓝色字体)
        isInputStatus: true,
        // true 显示搜索列表
        isShowSearch: true,
        strSelectContact: '',
        styleTextarea: 'select-contact-textarea',
        hasBlur: false,
        // 列表分页，页数
        page: 0,
        // 列表分页，数量
        limit: 10,
        // 联系人的总数
        totalMessage: 0
    },
    onInit() {
        this.selectContacts = this.paramContact.transmitContracts;
        this.$watch('paramContact', 'onPropertyChange');
        if (this.selectContacts.length > 0) {
            let that = this;
            setTimeout(function () {
                that.setContactValue();
            }, 200);
            this.isShowSearch = false;
            this.setInputStatus(false);
        }
    },
    requestItem() {
        let count = this.page * this.limit;
        if (this.page === 0) {
            this.page++;
            this.queryContacts();
        } else if (count < this.totalMessage && this.contacts.length > (this.page - 1) * this.limit) {
            // 对Contacts的限制，是防止初始化时多次刷新请求
            this.page++;
            this.queryContacts();
        }
    },
    queryContacts() {
        let actionData = {
            featureAbility: this.$app.$def.featureAbility,
            ohosDataAbility: this.$app.$def.ohosDataAbility,
            page: this.page,
            limit: this.limit
        };
        mmsLog.log('queryContacts, start:' + actionData);
        // 查询联系人
        contractService.queryContact(actionData, contacts => {
            mmsLog.log(RECEIVE_TAG + 'queryContact, contracts:' + contacts);
            if (common.int.SUCCESS == contacts.code) {
                let response = this.contacts.concat(contacts.response);
                this.contacts = [];
                this.contacts = response;
                this.contactsTemp = this.contacts.slice(0);
            } else {
                mmsLog.log('queryContacts, fail');
            }
        });
        // 统计数量
        contractService.countContact(actionData, contacts => {
            this.totalMessage = contacts.response;
        });
    },
    searchContacts(textValue, callback) {
        mmsLog.log(RECEIVE_TAG + 'searchContracts,contracts: start');
        let actionData = {
            telephone: textValue,
            featureAbility: this.$app.$def.featureAbility,
            ohosDataAbility: this.$app.$def.ohosDataAbility,
        };
        contractService.searchContracts(actionData, res => {
            let code = res.code;
            if (common.int.SUCCESS == res.code) {
                this.contacts = [];
                this.contacts = res.response;
            } else {
                mmsLog.log('queryContactByCondtion, fail');
            }
            callback(code);
        });
    },
    // 过滤搜索词匹配联系人
    filterContacts(textValue) {
        this.contacts = this.contactsTemp.filter((contact) => {
            if (contact.contactName && contact.contactName.toLowerCase().search(textValue) != -1) {
                mmsLog.info('jsRe searchChange contactName==>');
                return true;
            } else if (contact.telephone && contact.telephone.toLowerCase().search(textValue) != -1) {
                mmsLog.info('jsRe searchChange telephone==>');
                return true;
            }
            return false;
        });
    },
    isPhoneNumber(str) {
        // 判断是否是数字
        let reg = /^\d{1,}$/;
        let pattern = new RegExp(reg);
        return pattern.test(str);
    },
    setInputStatus(flag) {
        this.isInputStatus = flag;
        if (flag) {
            this.styleTextarea = 'select-contact-textarea';
        } else {
            this.styleTextarea = 'content-addressee-text';
            this.strSelectContact = this.setShowContactName();
        }
    },
    checkReceive() {
        mmsLog.info('jsRe checkReceive  isInputStatus:' + this.isInputStatus);
        if (this.myText.trim() == common.string.EMPTY_STR) {
            this.setInputStatus(false);
            this.isShowSearch = false;
            return;
        }
        this.hasBlur = true;
        if (this.isPhoneNumber(this.myText)) {
            // 从联系人列表中获取信息
            let that = this;
            let selectContact = {};
            let hasSelect = false;
            for (let index in this.contacts) {
                let contract = this.contacts[index];
                if (contract.telephone == that.myText) {
                    selectContact.headImage = '/common/icon/user_avatar_full_fill.svg';
                    selectContact.contactName = contract.contactName;
                    selectContact.telephone = contract.telephone;
                    selectContact.telephoneFormat = contract.telephone;
                    selectContact.select = false;
                    hasSelect = true;
                    break;
                }
            }
            if (!hasSelect) {
                selectContact.headImage = common.string.EMPTY_STR;
                selectContact.contactName = common.string.EMPTY_STR;
                selectContact.telephone = that.myText;
                selectContact.telephoneFormat = that.myText;
                selectContact.select = false;
            }
            mmsLog.info('jsRe isPhoneNumber  yes');
            this.selectContacts.push(selectContact);
            this.setInputStatus(false);
            this.isShowSearch = false;
            this.setContactValue();
        } else {
            mmsLog.info('jsRe isPhoneNumber  no');
            prompt.showToast({
                // 无效收件人
                message: this.$t('strings.invalid_receive', {
                    str: this.myText
                }),
                duration: 1000,
            });
            this.setInputStatus(false);
            this.isShowSearch = false;
        }
    },
    searchChange(e) {
        mmsLog.info('jsRe searchChange ==>');
        this.myText = e.text;
        if (!this.isInputStatus) {
            mmsLog.info('jsRe searchChange isInputStatus false');
            return;
        }
        this.searchContacts(this.myText, code => {
            if (code == common.int.SUCCESS) {
                this.setContactValue();
                mmsLog.info('jsRe searchChange textValue:' + this.myText);
                this.dealSearchData();
                this.setContactValue();
            }
        });
    },
    dealSearchData() {
        if (this.myText.trim() == common.int.SUCCESS) {
            this.contacts = this.contactsTemp.slice(0);
            this.$element('receiveTxt').focus({
                focus: true
            });
        } else {
            let textValue = this.myText.toLowerCase();
            // 过滤逻辑
            this.filterContacts(textValue);
            mmsLog.info('jsRe searchChange contact：' + JSON.stringify(this.contacts))
        }
    },
    setContactValue() {
        // 将收件人信息,传给调用的父组件
        this.$emit('eventReceive', {
            // 输入框的内容
            contactValue: this.myText,
            // 已经选择的收件人信息
            selectContacts: this.selectContacts,
            // 焦点是否丢失
            hasBlur: this.hasBlur
        });
    },
    addContact(index) {
        let curItem = this.contacts[index];
        this.selectContacts.push(curItem);
        this.contactsTemp = this.contactsTemp.filter((item) => {
            return item.telephone != curItem.telephone
        });
        this.contacts.splice(index, 1);
        mmsLog.info('jsRe addContact  length:' + this.selectContacts.length);
        this.myText = '';
        if (this.selectContacts.length == 1) {
            this.setInputStatus(false);
            this.isShowSearch = false;
            this.setContactValue();
        } else {
            this.setInputStatus(true);
            this.isShowSearch = true;
            this.setContactValue();
        }
        mmsLog.info('jsRe addContact  isInputStatus:' + this.isInputStatus);
    },
    setShowContactName() {
        if (this.selectContacts.length == 0) {
            return '';
        }
        let myName = this.selectContacts[0].contactName.trim();
        if (myName == '') {
            myName = this.selectContacts[0].telephone;
        }
        if (this.selectContacts.length >= 2) {
            // name以及其他number个
            return this.$t('strings.and_others', {
                name: myName,
                number: (this.selectContacts.length - 1)
            });
        } else {
            return myName
        }
    },
    myContactFocus() {
        mmsLog.info('jsRe myContactFocus ==>');
        this.myText = common.string.EMPTY_STR;
        this.setInputStatus(true);
        this.isShowSearch = true;
    },
    myContactClick() {
        mmsLog.info('jsRe myContactClick ==>');
        if (!this.isInputStatus) {
            this.myText = common.string.EMPTY_STR;
            this.setInputStatus(true);
            this.isShowSearch = true;
            this.$element('receiveTxt').focus({
                focus: true
            });
        }
    },
    nameClick(idx) {
        if (this.selectContacts[idx].select) {
            let item = this.selectContacts.splice(idx, 1);
            // 已经删除的添加到 需要搜索的集合
            this.contactsTemp.push(item);
            this.contacts.push(item[0]);
            return;
        }
        for (let element of this.selectContacts) {
            element.select = false;
        }
        this.selectContacts[idx].select = true;
    },
    clickToContracts() {
        var actionData = {};
        actionData.pageFlag = common.contractPage.PAGE_FLAG_MULT_CHOOSE;
        this.jumpToContractForResult(actionData);
    },
    // 点击联系人头像，跳转至联系人详情
    titleBarAvatar(index) {
        var actionData = {};
        actionData.phoneNumber = this.contacts[index].telephone;
        actionData.pageFlag = common.contractPage.PAGE_FLAG_CONTACT_DETAILS;
        this.jumpToContract(actionData);
    },
    // 跳转联系人app
    jumpToContract(actionData) {
        let commonService = this.$app.$def.commonService;
        let str = commonService.commonContractParam(actionData);
        let featureAbility = this.$app.$def.featureAbility;
        featureAbility.startAbility(str).then((data) => {
            mmsLog.info('jumpToContract,data: ' + JSON.stringify(data));
        }).catch((error) => {
            mmsLog.error('jumpToContract failed. Cause: ' + JSON.stringify(error));
        });
    },
    // 跳转联系人app
    async jumpToContractForResult(actionData) {
        let commonService = this.$app.$def.commonService;
        let featureAbility = this.$app.$def.featureAbility;
        let str = commonService.commonContractParam(actionData);
        var data = await featureAbility.startAbilityForResult(str);
        if (data.resultCode == 0) {
            this.dealContractParams(data.want.parameters.contactObjects);
        }
    },
    dealContractParams(contactObjects) {
        let params = JSON.parse(contactObjects);
        for (let element of params) {
            let selectContact = {};
            selectContact.headImage = '/common/icon/user_avatar_full_fill.svg';
            selectContact.contactName = element.contactName;
            selectContact.telephone = element.telephone;
            selectContact.telephoneFormat = element.telephone;
            selectContact.select = false;
            this.selectContacts.push(selectContact);
        }
        if (this.selectContacts.length > 0) {
            this.deleteRepetitionContracts(this.contacts, this.selectContacts);
            this.setInputStatus(false);
            this.isShowSearch = false;
            this.setContactValue();
        }
        this.paramContact.isSelectContact = false;
        this.paramContact.isNewRecallMessagesFlag = false;
    },
    deleteRepetitionContracts(contacts, selectContacts) {
        let indexs = [];
        let count = 0;
        for(let item of contacts) {
            let telephone = item.telephone;
            for(let selectContact of selectContacts) {
                if(telephone == selectContact.telephone) {
                    indexs.push(count);
                    break;
                }
            }
            count ++;
        }
        let selectContactIndexs = [];
        for(let i=0; i < selectContacts.length; i++) {
            let telephone = selectContacts[i].telephone;
            for(let j=i+1; j < selectContacts.length; j++) {
                if(telephone == selectContacts[j].telephone) {
                    selectContactIndexs.push(i);
                    break;
                }
            }
        }
        if(indexs.length > 0) {
            for(let index of indexs) {
                contacts.splice(index, 1);
            }
        }
        if(selectContactIndexs.length > 0) {
            for(let index of selectContactIndexs) {
                selectContacts.splice(index, 1);
            }
        }
    }
}