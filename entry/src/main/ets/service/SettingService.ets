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

import SettingModel from "../model/SettingsModel";

let mSettingModel = new SettingModel();
import HiLog from "../utils/HiLog";
import common from "../data/commonData";
import LooseObject from "../data/LooseObject"
import MmsPreferences from "../utils/MmsPreferences";

const TAG = "SettingService";

export default {

    /**
     * Set Initial Value
     *
     * @param {Object} callback
     */
    setOnSettingValueListener(callback) {
        let result: LooseObject = {
            integrationSwitch: false,
            maliciousWebSwitch: false,
            showContactSwitch: false,
        };
        mSettingModel.setOnSettingValueListener(settingValue => {
            if (settingValue.integrationSwitch === common.bool.TRUE || settingValue.integrationSwitch === '') {
                result.integrationSwitch = true;
            }
            if (settingValue.maliciousWebSwitch === common.bool.TRUE || settingValue.integrationSwitch === '') {
                result.maliciousWebSwitch = true;
            }
            if (settingValue.showContactSwitch === common.bool.TRUE || settingValue.integrationSwitch === '') {
                result.showContactSwitch = true;
            }
        });
        callback(result);
    },

    /**
     * Restore Page Defaults
     *
     * @param {Object} callback
     */
    restoreSwitchValue(callback) {
        mSettingModel.restoreSwitchValueToDefault(callback);
    },

    /**
     * Update related values
     * @param code     Updated code.
     * @param actionData     Updated Value
     * @param callback
     * @return
     */
    updateSettingValue(code, actionData, callback) {
        switch (code) {
            case common.route.MESSAGE_CODE_UPDATE_DELIVERY_REPORTS_VALUE:
            // Delivery Report
                mSettingModel.updateSwitchValue(common.string.KEY_OF_DELIVERY_REPORT_SWITCH,
                    actionData.intValue, callback);
                break;
            case common.route.MESSAGE_CODE_UPDATE_AUTO_RETRIEVE_MMS_VALUE:
            // Automatically downloading MMs
                mSettingModel.updateSwitchValue(common.string.KEY_OF_AUTO_RETRIEVE_SWITCH,
                    actionData.intValue, callback);
                break;
            case common.route.MESSAGE_CODE_UPDATE_RECALL_MESSAGES_VALUE:
            // Cancel Sending
                mSettingModel.updateSwitchValue(common.string.KEY_OF_RECALL_MESSAGE_SWITCH,
                    actionData.booleanValue, callback);
                break;
            case common.route.MESSAGE_CODE_UPDATE_AUTO_DELETE_INFO_MESSAGES_VALUE:
            // Automatically delete notification information
                mSettingModel.updateSwitchValue(common.string.KEY_OF_AUTO_DELETE_INFO_SWITCH,
                    actionData.booleanValue, callback);
                break;
            case common.route.MESSAGE_CODE_UPDATE_ARCHIVE_INFO_MESSAGES_VALUE:
            // Notification information integration
                mSettingModel.updateSwitchValue(common.string.KEY_OF_INTEGRATION_SWITCH,
                    actionData.booleanValue, callback);
                break;
            case common.route.MESSAGE_CODE_UPDATE_MALICIOUS_WEBSITE_IDENTIFICATION_VALUE:
            // Malicious Website Identification
                mSettingModel.updateSwitchValue(common.string.KEY_OF_MALICIOUS_WEB_SWITCH,
                    actionData.booleanValue, callback);
                break;
            case common.route.MESSAGE_CODE_UPDATE_SHOW_CONTACT_PROFILE_PICS_VALUE:
            // Display contact avatar
                mSettingModel.updateSwitchValue(common.string.KEY_OF_SHOW_CONTACT_SWITCH,
                    actionData.booleanValue, callback);
                break;
            default:
                HiLog.w(TAG, "updateSettingValue, code is not exit");
        }
    },

    /**
     * Obtains the switch value on the advanced settings page.
     *
     * @param {Object} callback
     */
    getAdvancedPageSwitchValue(callback) {
        mSettingModel.getAdvancedPageSwitchValue(callback);
    },

    /**
     * Updating SMSC Numbers
     * @param actionData
     * @param callback
     * @return
     */
    updateSmscNumber(actionData) {
        mSettingModel.updateSmscNumber(actionData, result => {
            if (result.code == common.int.SUCCESS) {
                HiLog.i(TAG, "updateSmscNumber, success");
            } else {
                HiLog.w(TAG, "updateSmscNumber, fail");
            }
        });
    },

    /**
     * Share the selected content in the SMSC dialog box.
     * @param actionData
     * @param callback
     * @return
     */
    shareSmsEnterSelectedText(actionData) {
        // The sharing API is not provided.
        mSettingModel.shareSmsEnterSelectedText(actionData, result => {
            if (result.code == common.int.SUCCESS) {
                HiLog.i(TAG, "shareSmsEnterSelectedText, success");
            } else {
            }
        });
    },

    /**
     * Values of the notification information integration switch and whether to display contact avatars
     */
    getSettingFlagForConvListPage() {
        let result: LooseObject = {
            isShowContactHeadIcon: false,
            hasAggregate: false,
            recallMessagesFlag: false,
        };
        mSettingModel.getSettingValue(settingValue => {
            if (settingValue.code === common.int.SUCCESS) {
                HiLog.i(TAG, "getSettingFlagForConvListPage, Success");
                if (settingValue.abilityResult.isShowContactHeadIcon === common.bool.TRUE ||
                    settingValue.abilityResult.isShowContactHeadIcon === '') {
                    result.isShowContactHeadIcon = true;
                }
                if (settingValue.abilityResult.hasAggregate == common.bool.TRUE ||
                    settingValue.abilityResult.hasAggregate === '') {
                    result.hasAggregate = true;
                }
                if (settingValue.abilityResult.recallMessagesFlag == common.bool.TRUE ||
                    settingValue.abilityResult.recallMessagesFlag === '') {
                    result.recallMessagesFlag = true;
                }
            } else {
                HiLog.w(TAG, "getSettingFlagForConvListPage, fail");
            }
        });
        return result;
    },

    /**
     * Determine whether a delivery report is required.
     *
     * @param {boolean} isMms    MMS or not
     */
    judgeIsDeliveryReport(isMms) {
        let deliveryReportSwitch = MmsPreferences.getInstance().getValueOfDeliveryReportSwitch();
        if (deliveryReportSwitch === common.DELIVERY_REPORTS.DISABLED) {
            return false;
        }
        // For MMS and SMS messages, true is returned.
        if (deliveryReportSwitch === common.DELIVERY_REPORTS.SMS_AND_MMS) {
            return true;
        }
        // A delivery report is available only when a message is sent.
        if (deliveryReportSwitch == common.DELIVERY_REPORTS.SMS && !isMms) {
            return true;
        }
        // Delivery reports are available only when MMS messages are sent.
        if (deliveryReportSwitch == common.DELIVERY_REPORTS.MMS && isMms) {
            return true;
        }
        return false;
    },

    /**
     * Calculate Selected Values
     * @param mmsList
     * @param isAllSelect
     */
    calculateChecked(simMessageList, isAllSelect) {
        let count = 0;
        let checkedList = [];
        let result: LooseObject = {};
        let switchOff = false;
        for (let item of simMessageList) {
            // If you select all
            if (isAllSelect || item.isCbChecked) {
                switchOff = true;
            }
            if (switchOff) {
                checkedList.push(item);
                count++;
            }
            switchOff = false;
        }
        result.count = count;
        result.checkedList = checkedList;
        return result;
    },
}