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
import LooseObject from "../../../data/LooseObject"
import HiLog from "../../../utils/HiLog";
import router from "@system.router";
import prompt from "@system.prompt";
import settingService from "../../../service/SettingService"
import common from "../../../data/commonData";

const TAG = "AdvancedSettingsController";

export default class AdvancedSettingsController {
    private static sInstance: AdvancedSettingsController;
    // Delivery Report SMS
    checkedValueOfSms: boolean = false;
    // Delivery Report MMS
    checkedValueOfMms: boolean = false;
    // Value of Delivery Report Switch
    deliveryReportSwitch: string = common.DELIVERY_REPORTS.DISABLED;
    // Delivery Report Text
    deliveryReportSwitchInText: Resource = $r("app.string.disabled");
    // Automatic MM Download Switch
    autoRetrieveMmsSwitch: string = common.AUTO_RETRIEVE_MMS.OFF;
    // Text for automatically downloading MMS messages
    autoRetrieveMmsSwitchInText: Resource | string = $r("app.string.off");
    // Cancel Sending Switch
    recallMessageSwitch: string = common.bool.FALSE;
    // Automatic Notification Deletion Switch
    autoDeleteInfoSwitch: string = common.bool.FALSE;
    // Indicates whether to automatically delete notification information. This parameter is a temporary variable.
    tempAutoDeleteInfoSwitch: string = common.bool.FALSE;
    // China Telecom
    snpNameOfChinaTelecom: string = '';
    // Number of SIM cards
    simCount: number = 0;
    // For one card, the name of the carrier.
    spnNameOfOneSimCard: string = '';
    // If there are two cards, the carrier name of card 1 is the name of card 1.
    firstSpnNameOfTwoSimCard: string = '';
    // If there are two cards, the carrier name of card 2 is the name of card 2.
    secondSpnNameOfTwoSimCard: string = '';
    refresh: boolean = false;

    static getInstance() {
        if (AdvancedSettingsController.sInstance == null) {
            AdvancedSettingsController.sInstance = new AdvancedSettingsController();
        }
        return AdvancedSettingsController.sInstance;
    }

    constructor() {
        HiLog.i(TAG, "constructor, start");
        this.getAdvancedPageSwitchValue();
    }

    onInit() {
        HiLog.i(TAG, "onInit, start");
    }

    onShow() {
        HiLog.i(TAG, "onShow, start");
    }

    getAdvancedPageSwitchValue() {
        HiLog.i(TAG, "getAdvancedPageSwitchValue, start");
        let that = this;
        settingService.getAdvancedPageSwitchValue(function (result) {
            if (result.code === common.int.SUCCESS) {
                let switchValue = result.abilityResult;
                that.deliveryReportSwitch = switchValue.deliveryReportSwitch;
                that.returnDeliveryReportResultInText(that.deliveryReportSwitch);
                that.autoRetrieveMmsSwitch = switchValue.autoRetrieveMmsSwitch;
                that.returnAutoRetrieveMmsResultInText(that.autoRetrieveMmsSwitch);
                that.recallMessageSwitch = switchValue.recallMessageSwitch;
                that.autoDeleteInfoSwitch = switchValue.autoDeleteInfoSwitch;
                that.tempAutoDeleteInfoSwitch = that.autoDeleteInfoSwitch;
                // Change the SIM card to switchValue.simCount after the SIM card functions properly.
                that.simCount = switchValue.simCount;
                if (that.simCount === 2) {
                    that.firstSpnNameOfTwoSimCard = switchValue.firstSpnNameOfTwoSimCard;
                    that.secondSpnNameOfTwoSimCard = switchValue.secondSpnNameOfTwoSimCard;
                } else {
                    that.spnNameOfOneSimCard = switchValue.spnNameOfOneSimCard;
                }
            } else {
                HiLog.w(TAG, "getAdvancedPageSwitchValue, failed");
            }
        });
    }
    // Returns the text version of the delivery report result based on an integer value
    returnDeliveryReportResultInText(intValue) {
        let tempValue;
        if (intValue == common.DELIVERY_REPORTS.DISABLED || intValue == '') {
            tempValue = $r("app.string.disabled");
            this.checkedValueOfSms = false;
            this.checkedValueOfMms = false;
        } else if (intValue == common.DELIVERY_REPORTS.SMS) {
            tempValue = $r("app.string.sms");
            this.checkedValueOfSms = true;
            this.checkedValueOfMms = false;
        } else if (intValue == common.DELIVERY_REPORTS.MMS) {
            tempValue = $r("app.string.mms");
            this.checkedValueOfSms = false;
            this.checkedValueOfMms = true;
        } else {
            tempValue = $r("app.string.sms_and_mms");
            this.checkedValueOfSms = true;
            this.checkedValueOfMms = true;
        }
        this.deliveryReportSwitchInText = tempValue;
        this.refresh = !this.refresh;
    }
    // Returns the text version of the delivery report result based on an integer value
    returnAutoRetrieveMmsResultInText(intValue) {
        let tempValue;
        if (intValue == common.AUTO_RETRIEVE_MMS.OFF) {
            tempValue = $r("app.string.off");
        } else if (intValue == common.AUTO_RETRIEVE_MMS.NOT_WHEN_ROAMING) {
            tempValue = $r("app.string.not_when_roaming");
        } else {
            tempValue = $r("app.string.always");
        }
        this.autoRetrieveMmsSwitchInText = tempValue;
    }
    // Back button
    back() {
        router.back();
    }
    // Restore the default values on the settings page.
    restoreSettingPageSwitchValue() {
        HiLog.i(TAG, "restoreSettingPageSwitchValue");
        let that = this;
        settingService.restoreSwitchValue(function (result) {
            if (result.code === common.int.SUCCESS) {
                that.deliveryReportSwitch = common.DELIVERY_REPORTS.DISABLED;
                that.returnDeliveryReportResultInText(common.DELIVERY_REPORTS.DISABLED);
                that.autoRetrieveMmsSwitch = common.AUTO_RETRIEVE_MMS.NOT_WHEN_ROAMING;
                that.returnAutoRetrieveMmsResultInText(common.AUTO_RETRIEVE_MMS.NOT_WHEN_ROAMING);
                that.recallMessageSwitch = common.bool.FALSE;
                that.autoDeleteInfoSwitch = common.bool.FALSE;
                that.tempAutoDeleteInfoSwitch = common.bool.FALSE;
                HiLog.i(TAG, "restoreSettingPageSwitchValue, success");
            } else {
                HiLog.w(TAG, "restoreSettingPageSwitchValue, failed");
            }
        });
    }
    // Click the text line.
    clickSmsDiv() {
        this.checkedValueOfSms = !this.checkedValueOfSms;
    }
    // Click Checkbox in the line of the message.
    clickSmsCheckbox(e) {
        this.checkedValueOfSms = e.checked;
    }
    // Click the MMS line.
    clickMmsDiv() {
        this.checkedValueOfMms = !this.checkedValueOfMms;
    }
    // Click Checkbox in the MMS line.
    clickMmsCheckbox(e) {
        this.checkedValueOfMms = e.checked;
    }
    // Cancel the configuration restoration dialog box.
    cancelRestore() {
        this.returnDeliveryReportResultInText(this.deliveryReportSwitch);
    }
    // delivery report dialog, OK
    setRestore(isOnOfSms: boolean, isOnOfMms: boolean) {
        this.checkedValueOfSms = isOnOfSms;
        this.checkedValueOfMms = isOnOfMms;
        this.deliveryReportSwitch = common.string.EMPTY_STR;
        if (this.checkedValueOfSms && this.checkedValueOfMms) {
            this.deliveryReportSwitch = common.DELIVERY_REPORTS.SMS_AND_MMS;
        } else if (this.checkedValueOfSms) {
            this.deliveryReportSwitch = common.DELIVERY_REPORTS.SMS;
        } else if (this.checkedValueOfMms) {
            this.deliveryReportSwitch = common.DELIVERY_REPORTS.MMS;
        } else {
            this.deliveryReportSwitch = common.DELIVERY_REPORTS.DISABLED;
        }
        this.returnDeliveryReportResultInText(this.deliveryReportSwitch);
        this.autoHandleDeliveryReportValueChange(this.deliveryReportSwitch);
    }
    // When the value of deliveryReportSwitch changes, this method is used to process the change.
    autoHandleDeliveryReportValueChange(newValue) {
        HiLog.i(TAG, "autoHandleDeliveryReportValueChange, newValue = " + newValue);
        let messageCode = common.route.MESSAGE_CODE_UPDATE_DELIVERY_REPORTS_VALUE;
        let actionData: LooseObject = {};
        actionData.intValue = newValue;
        this.updateAdvancedPageSwitchValue(messageCode, actionData);
    }
    // Displaying the "Automatic Download MMS" dialog
    showAutoRetrieveMmsDialog() {
        //    this.$element("auto-retrieve-mms-dialog").show();
    }
    // Click the corresponding option in the dialog box for automatically downloading MMs.
    clickDiv(idx) {
        this.autoRetrieveMmsSwitch = idx + common.string.EMPTY_STR;
        this.returnAutoRetrieveMmsResultInText(idx);
        //    this.$element("auto-retrieve-mms-dialog").close();
        this.autoHandleAutoRetrieveMmsValueChange(this.autoRetrieveMmsSwitch);
    }
    // Disable the automatic MM download dialog box.
    closeAutoRetrieveMmsDialog() {
        //    this.$element("auto-retrieve-mms-dialog").close();
    }
    // This method is used when the value of autoRetrieveMmsSwitch changes.
    autoHandleAutoRetrieveMmsValueChange(newValue) {
        HiLog.i(TAG, "autoHandleAutoRetrieveMmsValueChange, newValue = " + newValue);
        let messageCode = common.route.MESSAGE_CODE_UPDATE_AUTO_RETRIEVE_MMS_VALUE;
        let actionData: LooseObject = {};
        actionData.intValue = newValue;
        this.updateAdvancedPageSwitchValue(messageCode, actionData);
    }
    // Cancel Sending
    recallMsg(e) {
        let messageCode = common.route.MESSAGE_CODE_UPDATE_RECALL_MESSAGES_VALUE;
        let actionData: LooseObject = {};
        this.recallMessageSwitch = e.checked;
        if (this.recallMessageSwitch) {
            actionData.booleanValue = common.bool.TRUE;
        } else {
            actionData.booleanValue = common.bool.FALSE;
        }
        this.updateAdvancedPageSwitchValue(messageCode, actionData);
    }
    // Automatically delete notification information
    autoDeleteInfo(e) {
        let that = this;
        that.tempAutoDeleteInfoSwitch = e.checked;
        if (e.checked) {
            prompt.showDialog({
                title: $r("app.string.enable_auto_delete") + '',
                message: $r("app.string.enable_auto_delete_hint") + '',
                buttons: [
                    {
                        text: $r("app.string.cancel") + '', color: "#007DFF"
                    },
                    {
                        text: $r("app.string.enable") + '', color: "#007DFF"
                    }
                ],
                success: function (data) {
                    that.autoDeleteSuccess(data);
                },
                cancel: function () {
                    HiLog.i(TAG, "autoDeleteInfo, cancel");
                    that.tempAutoDeleteInfoSwitch = common.bool.FALSE;
                    that.autoDeleteInfoSwitch = common.bool.FALSE;
                }
            });
        } else {
            that.autoDeleteInfoSwitch = common.bool.FALSE;
            that.autoHandleAutoDeleteInfoValueChange(common.bool.FALSE);
        }
    }

    autoDeleteSuccess(data) {
        if (data.index == 0) {
            this.tempAutoDeleteInfoSwitch = common.bool.FALSE;
        } else {
            this.autoDeleteInfoSwitch = common.bool.TRUE;
            this.autoHandleAutoDeleteInfoValueChange(common.bool.TRUE);
        }
    }
    // This method is used when the value of autoDeleteInfoSwitch changes.
    autoHandleAutoDeleteInfoValueChange(newValue) {
        HiLog.i(TAG, "autoHandleAutoDeleteInfoValueChange, newValue = " + newValue);
        let messageCode = common.route.MESSAGE_CODE_UPDATE_AUTO_DELETE_INFO_MESSAGES_VALUE;
        let actionData: LooseObject = {};
        actionData.booleanValue = newValue;
        this.updateAdvancedPageSwitchValue(messageCode, actionData);
    }
    // The SMSC page is displayed.
    jumpToSmsCenterPage(index) {
        if (this.simCount == 0) {
            return;
        }
        router.push({
            uri: "pages/sms_center/sms_center",
            params: {
                idx: index,
                countOfSim: this.simCount
            }
        });
    }
    // The Manage SIM Card page is displayed.
    jumpToManageSimPage(index) {
        if (this.simCount == 0) {
            return;
        }
        router.push({
            uri: "pages/manage_sim/manage_sim",
            params: {
                idx: index,
                countOfSim: this.simCount
            }
        });
    }
    // Update Switch Value
    updateAdvancedPageSwitchValue(messageCode, actionData) {
        settingService.updateSettingValue(messageCode, actionData, function (result) {
            if (result.code == common.int.SUCCESS) {
                HiLog.i(TAG, "updateAdvancedPageSwitchValue, success");
            } else {
                HiLog.w(TAG, "updateAdvancedPageSwitchValue, failed");
            }
        });
    }
}