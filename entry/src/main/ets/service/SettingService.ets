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

import SettingModel from '../model/SettingsModel';

import HiLog from '../utils/HiLog';
import common from '../data/commonData';
import LooseObject from '../data/LooseObject'
import MmsPreferences from '../utils/MmsPreferences';
import SharedPreferencesUtils from '../utils/SharedPreferencesUtils';

let mSettingModel = new SettingModel();

const TAG = 'SettingService';
export interface MmsSettingServiceType {
    setOnSettingValueListener: (callback: Function) => void,
    restoreSwitchValue: (callback: Function) => void,
    updateSettingValue: (code: number, actionData: LooseObject, callback: Function) => void,
    getAdvancedPageSwitchValue: (callback: Function) => void,
    shareSmsEnterSelectedText: (actionData: LooseObject) => void,
    getSettingFlagForConvListPage: () => (Record<string,boolean>),
    judgeIsDeliveryReport: (isMms: Object) => boolean,
    calculateChecked: (simMessageList:Array<LooseObject>, isAllSelect: Object) => LooseObject,

}

let MmsSettingService: MmsSettingServiceType = {

    /**
     * Set Initial Value
     *
     * @param {Object} callback
     */
    setOnSettingValueListener(callback: Function) {
        let result: Record<string,boolean> = {
            'integrationSwitch': false,
            'showContactSwitch': false,
        };
        mSettingModel.setOnSettingValueListener((settingValue: Record<string,Object>) => {
            if (settingValue.integrationSwitch === common.bool.TRUE || settingValue.integrationSwitch === '') {
                result.integrationSwitch = true;
            }
            if (settingValue.showContactSwitch === common.bool.TRUE || settingValue.showContactSwitch === '') {
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
    restoreSwitchValue(callback: Function) {
        mSettingModel.restoreSwitchValueToDefault(callback);
    },

    /**
     * Update related values
     * @param code     Updated code.
     * @param actionData     Updated Value
     * @param callback
     * @return
     */
    updateSettingValue(code: number, actionData: LooseObject, callback: Function) {
        switch (code) {
            case common.route.MESSAGE_CODE_UPDATE_DELIVERY_REPORTS_VALUE:
            // Delivery Report
                mSettingModel.updateSwitchValue(common.STR.KEY_OF_DELIVERY_REPORT_SWITCH,
                    actionData.intValue, callback);
                break;
            case common.route.MESSAGE_CODE_UPDATE_ARCHIVE_INFO_MESSAGES_VALUE:
            // Notification information integration
                mSettingModel.updateSwitchValue(common.STR.KEY_OF_INTEGRATION_SWITCH,
                    actionData.booleanValue, callback);
                break;
            case common.route.MESSAGE_CODE_UPDATE_SHOW_CONTACT_PROFILE_PICS_VALUE:
            // Display contact avatar
                mSettingModel.updateSwitchValue(common.STR.KEY_OF_SHOW_CONTACT_SWITCH,
                    actionData.booleanValue, callback);
                break;
            default:
                HiLog.w(TAG, 'updateSettingValue, code is not exit');
        }
    },

    /**
     * Obtains the switch value on the advanced settings page.
     *
     * @param {Object} callback
     */
    getAdvancedPageSwitchValue(callback: Function) {
        mSettingModel.getAdvancedPageSwitchValue(callback);
    },

    /**
     * Share the selected content in the SMSC dialog box.
     * @param actionData
     * @param callback
     * @return
     */
    shareSmsEnterSelectedText(actionData: LooseObject) {
        // The sharing API is not provided.
        mSettingModel.shareSmsEnterSelectedText(actionData, (result: Record<string,number>) => {
            if (result.code == common.int.SUCCESS) {
                HiLog.i(TAG, 'shareSmsEnterSelectedText, success');
            } else {
            }
        });
    },

    /**
     * Values of the notification information integration switch and whether to display contact avatars
     */
    getSettingFlagForConvListPage() {
        let result: Record<string,boolean> = {
            'isShowContactHeadIcon': false,
            'hasAggregate': false,
            'isDistributedFlag': false,
        };
        mSettingModel.getSettingValue((settingValue: LooseObject) => {
            if (settingValue.code === common.int.SUCCESS) {
                HiLog.i(TAG, 'getSettingFlagForConvListPage, Success');
                if (settingValue.abilityResult.isShowContactHeadIcon === common.bool.TRUE ||
                    settingValue.abilityResult.isShowContactHeadIcon === '') {
                    result.isShowContactHeadIcon = true;
                }
                if (settingValue.abilityResult.hasAggregate == common.bool.TRUE ||
                    settingValue.abilityResult.hasAggregate === '') {
                    result.hasAggregate = true;
                }
                if (settingValue.abilityResult.isDistributedFlag === 2 ||
                    settingValue.abilityResult.isDistributedFlag === '') {
                    result.isDistributedFlag = true;
                }
            } else {
                HiLog.w(TAG, 'getSettingFlagForConvListPage, fail');
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
    calculateChecked(simMessageList:Array<LooseObject>, isAllSelect) {
        let count = 0;
        let checkedList: LooseObject[] = [];
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

export default MmsSettingService
export { mSettingModel }