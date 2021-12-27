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
import prompt from '@system.prompt';
import settingService from '../../service/SettingService.js'
import common from '../common_constants.js';

const TAG = 'JS->advanced_settings.js->';

export default {
    data: {
        // 送达报告短信
        checkedValueOfSms: null,
        // 送达报告彩信
        checkedValueOfMms: null,
        // 送达报告开关的值
        deliveryReportSwitch: null,
        // 送达报告文本
        deliveryReportSwitchInText: null,
        // 自动下载彩信开关
        autoRetrieveMmsSwitch: null,
        // 自动下载彩信开关文本
        autoRetrieveMmsSwitchInText: null,
        // 取消发送开关
        recallMessageSwitch: null,
        // 自动删除通知信息开关
        autoDeleteInfoSwitch: null,
        // 自动删除通知信息开关，临时变量
        tempAutoDeleteInfoSwitch: null,
        // 中国电信
        snpNameOfChinaTelecom: common.SPN_CHINA.TELECOM,
        // sim卡的数量
        simCount: null,
        // 如果是1张卡，运营商的名字
        spnNameOfOneSimCard: null,
        // 如果是2张卡，卡1运营商的名字
        firstSpnNameOfTwoSimCard: null,
        // 如果是2张卡，卡2运营商的名字
        secondSpnNameOfTwoSimCard: null
    },
    onInit() {
        mmsLog.info(TAG + 'onInit(): start');
    },
    onShow() {
        this.getAdvancedPageSwitchValue();
    },
    getAdvancedPageSwitchValue() {
        mmsLog.info(TAG + 'initializeAdvancedPage(): start');
        let that = this;
        let preferences = this.$app.$def.preferences;
        settingService.getAdvancedPageSwitchValue(preferences, function (result) {
            mmsLog.info(TAG + 'getAdvancedPageSwitchValue(): success' + result);
            if (result.code === common.int.SUCCESS) {
                mmsLog.info(TAG + 'getAdvancedPageSwitchValue(): success');
                let switchValue = result.abilityResult;
                that.deliveryReportSwitch = switchValue.deliveryReportSwitch;
                that.returnDeliveryReportResultInText(that.deliveryReportSwitch);
                that.autoRetrieveMmsSwitch = switchValue.autoRetrieveMmsSwitch;
                that.returnAutoRetrieveMmsResultInText(that.autoRetrieveMmsSwitch);
                that.recallMessageSwitch = switchValue.recallMessageSwitch;
                that.autoDeleteInfoSwitch = switchValue.autoDeleteInfoSwitch;
                that.tempAutoDeleteInfoSwitch = that.autoDeleteInfoSwitch;
                // 等sim卡功能好,需要换成 switchValue.simCount;
                that.simCount = switchValue.simCount;
                if (that.simCount === 2) {
                    that.firstSpnNameOfTwoSimCard = switchValue.firstSpnNameOfTwoSimCard;
                    that.secondSpnNameOfTwoSimCard = switchValue.secondSpnNameOfTwoSimCard;
                } else {
                    that.spnNameOfOneSimCard = switchValue.spnNameOfOneSimCard;
                }
            } else {
                mmsLog.info(TAG + 'getAdvancedPageSwitchValue(): fail');
            }
        });
    },
    // 根据整数值返回文本版的送达报告结果
    returnDeliveryReportResultInText(intValue) {
        let tempValue = common.string.EMPTY_STR;
        if (intValue == common.DELIVERY_REPORTS.DISABLED) {
            tempValue = this.$t('strings.disabled');
            this.checkedValueOfSms = false;
            this.checkedValueOfMms = false;
        } else if (intValue == common.DELIVERY_REPORTS.SMS) {
            tempValue = this.$t('strings.sms');
            this.checkedValueOfSms = true;
            this.checkedValueOfMms = false;
        } else if (intValue == common.DELIVERY_REPORTS.MMS) {
            tempValue = this.$t('strings.mms');
            this.checkedValueOfSms = false;
            this.checkedValueOfMms = true;
        } else {
            tempValue = this.$t('strings.sms_and_mms');
            this.checkedValueOfSms = true;
            this.checkedValueOfMms = true;
        }
        this.deliveryReportSwitchInText = tempValue;
    },
    // 根据整数值返回文本版的送达报告结果
    returnAutoRetrieveMmsResultInText(intValue) {
        let tempValue = common.string.EMPTY_STR;
        if (intValue == common.AUTO_RETRIEVE_MMS.OFF) {
            tempValue = this.$t('strings.off');
        } else if (intValue == common.AUTO_RETRIEVE_MMS.NOT_WHEN_ROAMING) {
            tempValue = this.$t('strings.not_when_roaming');
        } else {
            tempValue = this.$t('strings.always');
        }
        this.autoRetrieveMmsSwitchInText = tempValue;
    },
    // 返回按键
    back() {
        router.back();
    },
    // 展示还原配置的弹框
    showDialog() {
        let that = this;
        prompt.showDialog({
            message: this.$t('strings.restore_all_default_settings'),
            buttons: [
                {
                    text: this.$t('strings.cancel'),
                    color: '#007DFF'
                },
                {
                    text: this.$t('strings.restore'),
                    color: '#007DFF'
                }
            ],
            success: function (data) {
                mmsLog.info(TAG + 'showDialog->success: index = ' + data.index);
                if (data.index == 1) {
                    // 还原
                    that.restoreSettingPageSwitchValue();
                }
            },
            cancel: function () {
                mmsLog.info(TAG + 'showDialog->cancel: dialog cancel callback');
            }
        });
    },
    // 还原设置页面的默认值
    restoreSettingPageSwitchValue() {
        let that = this;
        let preferences = this.$app.$def.preferences;
        settingService.restoreSwitchValue(preferences, function (result) {
            if (result.code === common.int.SUCCESS) {
                that.deliveryReportSwitch = common.DELIVERY_REPORTS.DISABLED;
                that.returnDeliveryReportResultInText(common.DELIVERY_REPORTS.DISABLED);
                that.autoRetrieveMmsSwitch = common.AUTO_RETRIEVE_MMS.NOT_WHEN_ROAMING;
                that.returnAutoRetrieveMmsResultInText(common.AUTO_RETRIEVE_MMS.NOT_WHEN_ROAMING);
                that.recallMessageSwitch = common.bool.FALSE;
                that.autoDeleteInfoSwitch = common.bool.FALSE;
                that.tempAutoDeleteInfoSwitch = common.bool.FALSE;
                mmsLog.info(TAG + 'restoreSettingPageSwitchValue(): success');
            } else {
                mmsLog.info(TAG + 'restoreSettingPageSwitchValue(): fail');
            }
        });
    },
    // 显示'送达报告'dialog
    showDeliveryReport() {
        this.$element('delivery-report-dialog').show();
    },
    // 点击短信那行
    clickSmsDiv() {
        this.checkedValueOfSms = !this.checkedValueOfSms;
    },
    // 点击短信那行的checkbox
    clickSmsCheckbox(e) {
        this.checkedValueOfSms = e.checked;
    },
    // 点击彩信那行
    clickMmsDiv() {
        this.checkedValueOfMms = !this.checkedValueOfMms;
    },
    // 点击彩信那行的checkbox
    clickMmsCheckbox(e) {
        this.checkedValueOfMms = e.checked;
    },
    // 取消还原配置的弹框
    cancelRestore() {
        this.returnDeliveryReportResultInText(this.deliveryReportSwitch);
        this.$element('delivery-report-dialog').close();
    },
    // 送达报告dialog，确定
    setRestore() {
        this.deliveryReportSwitch = common.string.EMPTY_STR;
        if (this.checkedValueOfSms && this.checkedValueOfMms) {
            this.deliveryReportSwitch = common.DELIVERY_REPORTS.SMS_AND_MMS;
        } else if(this.checkedValueOfSms) {
            this.deliveryReportSwitch = common.DELIVERY_REPORTS.SMS;
        } else if(this.checkedValueOfMms) {
            this.deliveryReportSwitch = common.DELIVERY_REPORTS.MMS;
        } else {
            this.deliveryReportSwitch = common.DELIVERY_REPORTS.DISABLED;
        }
        this.returnDeliveryReportResultInText(this.deliveryReportSwitch);
        this.$element('delivery-report-dialog').close();
        this.autoHandleDeliveryReportValueChange(this.deliveryReportSwitch);
    },
    // 当deliveryReportSwitch开关的值变化时，由该方法处理
    autoHandleDeliveryReportValueChange(newValue) {
        mmsLog.info(TAG + 'autoHandleDeliveryReportValueChange(): newV = ' + newValue);
        let messageCode = common.route.MESSAGE_CODE_UPDATE_DELIVERY_REPORTS_VALUE;
        let actionData = {};
        actionData.intValue = newValue;
        actionData.preferences = this.$app.$def.preferences;
        this.updateAdvancedPageSwitchValue(messageCode, actionData);
    },
    // 显示'自动下载彩信'dialog
    showAutoRetrieveMmsDialog() {
        this.$element('auto-retrieve-mms-dialog').show();
    },
    // 点击'自动下载彩信'dialog内相应的选项
    clickDiv(idx) {
        this.autoRetrieveMmsSwitch = idx + common.string.EMPTY_STR;
        this.returnAutoRetrieveMmsResultInText(idx);
        this.$element('auto-retrieve-mms-dialog').close();
        this.autoHandleAutoRetrieveMmsValueChange(this.autoRetrieveMmsSwitch);
    },
    // 关闭'自动下载彩信'dialog
    closeAutoRetrieveMmsDialog() {
        this.$element('auto-retrieve-mms-dialog').close();
    },
    // 当autoRetrieveMmsSwitch开关的值变化时，由该方法处理
    autoHandleAutoRetrieveMmsValueChange(newValue) {
        mmsLog.info(TAG + 'autoHandleAutoRetrieveMmsValueChange(): newV = ' + newValue);
        let messageCode = common.route.MESSAGE_CODE_UPDATE_AUTO_RETRIEVE_MMS_VALUE;
        let actionData = {};
        actionData.intValue = newValue;
        actionData.preferences = this.$app.$def.preferences;
        this.updateAdvancedPageSwitchValue(messageCode, actionData);
    },
    // 取消发送
    recallMsg(e) {
        let messageCode = common.route.MESSAGE_CODE_UPDATE_RECALL_MESSAGES_VALUE;
        let actionData = {};
        this.recallMessageSwitch = e.checked;
        actionData.preferences = this.$app.$def.preferences;
        if (this.recallMessageSwitch) {
            actionData.booleanValue = common.bool.TRUE;
        } else {
            actionData.booleanValue = common.bool.FALSE;
        }
        this.updateAdvancedPageSwitchValue(messageCode, actionData);
    },
    // 自动删除通知信息
    autoDeleteInfo(e) {
        let that = this;
        this.tempAutoDeleteInfoSwitch = e.checked;
        if (e.checked) {
            prompt.showDialog({
                title: that.$t('strings.enable_auto_delete'),
                message: that.$t('strings.enable_auto_delete_hint'),
                buttons: [
                    {text: that.$t('strings.cancel'), color: '#007DFF'},
                    {text: that.$t('strings.enable'), color: '#007DFF'}
                ],
                success: function (data) {
                    that.autoDeleteSuccess(data);
                },
                cancel: function () {
                    mmsLog.info(TAG + 'autoDeleteInfo(): cancel: dialog cancel callback');
                    that.tempAutoDeleteInfoSwitch = false;
                    that.autoDeleteInfoSwitch = false;
                }
            });
        } else {
            that.autoDeleteInfoSwitch = false;
            that.autoHandleAutoDeleteInfoValueChange(common.bool.FALSE);
        }
    },
    autoDeleteSuccess(data) {
        if (data.index == 0) {
            this.tempAutoDeleteInfoSwitch = false;
        } else {
            this.autoDeleteInfoSwitch = true;
            this.autoHandleAutoDeleteInfoValueChange(common.bool.TRUE);
        }
    },
    // 当autoDeleteInfoSwitch开关的值变化时，由该方法处理
    autoHandleAutoDeleteInfoValueChange(newValue) {
        mmsLog.info(TAG + 'autoHandleAutoDeleteInfoValueChange(): newV = ' + newValue);
        let messageCode = common.route.MESSAGE_CODE_UPDATE_AUTO_DELETE_INFO_MESSAGES_VALUE;
        let actionData = {};
        actionData.preferences = this.$app.$def.preferences;
        actionData.booleanValue = newValue;
        this.updateAdvancedPageSwitchValue(messageCode, actionData);
    },
    // 跳转至'短信中心'页面
    jumpToSmsCenterPage(index) {
        if (this.simCount == 0) {
            return;
        }
        router.push({
            uri: 'pages/sms_center/sms_center',
            params: {
                idx: index,
                countOfSim: this.simCount
            }
        });
    },
    // 跳转至'管理Sim卡'页面
    jumpToManageSimPage(index) {
        if (this.simCount == 0) {
            return;
        }
        router.push({
            uri: 'pages/manage_sim/manage_sim',
            params: {
                idx: index,
                countOfSim: this.simCount
            }
        });
    },
    // 更新开关值
    updateAdvancedPageSwitchValue(messageCode, actionData) {
        settingService.updateSettingValue(messageCode, actionData, function (result) {
            if (result.code == common.int.SUCCESS) {
                mmsLog.info(TAG + 'updateAdvancedPageSwitchValue(): success');
            } else {
                mmsLog.info(TAG + 'updateAdvancedPageSwitchValue(): fail');
            }
        });
    }
}
