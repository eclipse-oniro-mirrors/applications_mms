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
import cardService from '../../service/SimCardService.js';
import settingService from '../../service/SettingService.js';
import callService from '../../service/CallService.js';

// JS公共常量
import common from '../common_constants.js';

const TAG = 'JS->sms_center.js->';

export default {
    data: {
        // sim卡的数量
        simCount: 0,
        // 如果是2张卡，卡的索引
        index: 0,
        // 短信中心号码
        number: '',
        // dialog内输入的number
        numberInDialog: null,
        // 编辑短信中心号码时，如果只剩+号或没有内容时，确定按钮透明度变暗
        noneOrOnlyPlusStatus: null,
        // 菜单选项列表
        menuOptionList: []
    },
    onInit() {
        this.simCount = this.countOfSim;
        this.index = this.idx;
        this.getSmscNumber();
    },
    // 获取短信中心号码
    getSmscNumber() {
        mmsLog.info(TAG + 'getSmscNumber(): start');
        let actionData = {};
        actionData.index = this.index;
        actionData.preferences = this.$app.$def.preferences;
        let that = this;
        cardService.querySmscNumber(actionData, function (result) {
            if (result.code === common.int.SUCCESS) {
                mmsLog.info(TAG + 'getSmscNumber(): success');
                that.number = result.smsNumber;
                that.numberInDialog = that.number;
            } else {
                mmsLog.info(TAG + 'getSmscNumber(): fail');
            }
        });
    },
    onShow() {
        let tempMenuOptionList = [
            {
                icon: '/common/new_message.svg',
                content: this.$t('strings.message')
            },
            {
                icon: '/common/call.svg',
                content: this.$t('strings.phone')
            },
            {
                icon: '/common/new_contact.png',
                content: this.$t('strings.new_contact')
            }
        ];
        this.menuOptionList = tempMenuOptionList;
        this.$watch('number', 'autoHandleNumberChanged');
        this.$element('simpleDialog').focus();
    },
    // 当短信中心号码被修改后，由该方法处理
    autoHandleNumberChanged(newValue) {
        mmsLog.info(TAG + 'autoHandleNumberChanged(): newV = ' + newValue);
        let actionData = {};
        actionData.simCount = this.simCount;
        actionData.index = this.index;
        actionData.number = newValue;
        settingService.updateSmscNumber(actionData);
    },
    back() {
        router.back();
    },
    // 显示dialog
    showDialog() {
        this.$element('simpleDialog').show()
    },
    // 输入短信中心号码
    inputNumber(e) {
        let tempText = this.numberInDialog;
        if (this.judgeTextOnlyIncludeDigitAndPlus(e.text)) {
            if (e.text == '' || e.text == '+') {
                this.noneOrOnlyPlusStatus = true;
            } else {
                this.noneOrOnlyPlusStatus = false;
            }
            this.numberInDialog = e.text;
        } else {
            this.numberInDialog = e.text;
            this.numberInDialog = '';
            this.numberInDialog = tempText;
        }
    },
    // 判断输入的内容只包含0~9和'+'号
    judgeTextOnlyIncludeDigitAndPlus(str) {
        let reg = /^[+]?[0-9]*$/;
        let result = reg.test(str);
        return result;
    },
    // 点击'取消'，关闭dialog
    cancelSchedule() {
        this.numberInDialog = this.number;
        this.$element('simpleDialog').close();
    },
    // 点击确定，并关闭dialog
    setSchedule() {
        if (this.noneOrOnlyPlusStatus) {
            return;
        }
        this.number = this.numberInDialog;
        this.$element('simpleDialog').close();
        this.autoHandleNumberChanged(this.number);
        router.back();
    },
    // 分享短信中心dialog内选中的内容
    shareInSmsCenter(e) {
        if (e.value == common.string.EMPTY_STR) {
            return;
        }
        let actionData = {};
        actionData.content = e.value;
        settingService.shareSmsEnterSelectedText(actionData);
    },
    // 编辑短信中心dialog内选中的内容
    optionSelectInSmsCenter(e) {
        if (e.value == '') {
            return;
        }
        switch (e.index) {
            case 0:
            // 跳转至'新建信息'页面
                this.jumpToNewMessagePage(e.value);
                break;
            case 1:
            // 打电话，即呼叫前编辑
                this.callSmscNumber(e.value);
                break;
            case 2:
            // 添加为联系人(保存为已有联系人)
                this.saveSmscNumberToExistingContact(e.value);
                break;
            default:
                mmsLog.info(TAG + 'optionSelectInSmsCenter,code is not exit');
        }
    },
    // 跳转至'新建信息'页面
    jumpToNewMessagePage(telephone) {
        let actionData = {};
        actionData.content = telephone;
        router.push({
            uri: 'pages/conversation/conversation',
            params: {
                isNewMsg: true,
                telephone: telephone
            }
        });
    },
    // 将短信中心号码保存为已有联系人
    saveSmscNumberToExistingContact(telephone) {
        let messageCode = common.contractPage.PAGE_FLAG_SAVE_EXIST_CONTACT;
        let actionData = {};
        actionData.phoneNumber = telephone;
        this.jumpToContactsApp(messageCode, actionData);
    },
    // 呼叫短信中心号码
    callSmscNumber(telephone) {
        // 打电话
        mmsLog.info('call action');
        let param = {
            telephone: telephone
        };
        callService.call(param, result => {
            if (result.code == common.int.SUCCESS) {
                mmsLog.info('call success');
            } else {
                mmsLog.info('call error');
            }
        });
    },
    // 跳转至联系人app
    jumpToContactsApp(messageCode, actionData) {
        let commonService = this.$app.$def.commonService;
        let str = commonService.commonContractParam(actionData);
        let featureAbility = this.$app.$def.featureAbility;
        featureAbility.startAbility(str).then((data) => {
            mmsLog.info(TAG + 'jumpToContactsApp successful' + data);
        }).catch((error) => {
            mmsLog.error(TAG + 'jumpToContactsApp failed,Cause: ' + JSON.stringify(error));
        })
    }
}
