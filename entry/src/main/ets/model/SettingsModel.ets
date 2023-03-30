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

import BaseModel from "./BaseModel";
import common from "../data/commonData"
import HiLog from "../utils/HiLog";
import MmsPreferences from "../utils/MmsPreferences";
import telephonySMS from "@ohos.telephony.sms";
import LooseObject from "../data/LooseObject"

const TAG = "SettingModel";

export default class SettingModel extends BaseModel {
    setOnSettingValueListener(callback) {
        let data: LooseObject = {};
        data.integrationSwitch = MmsPreferences.getInstance().getValueOfIntegrationSwitch();
        data.maliciousWebSwitch = MmsPreferences.getInstance().getValueOfMaliciousWebSwitch();
        data.showContactSwitch = MmsPreferences.getInstance().getValueOfShowContactSwitch();
        callback(data);
    }

    getSettingValue(callback) {
        let settingValues: LooseObject = {};
        settingValues.hasAggregate = MmsPreferences.getInstance().getValueOfIntegrationSwitch();
        settingValues.isShowContactHeadIcon = MmsPreferences.getInstance().getValueOfShowContactSwitch();
        settingValues.recallMessagesFlag = MmsPreferences.getInstance().getValueOfRecallMessageSwitch();
        callback(this.encapsulateReturnResult(common.int.SUCCESS, settingValues));
    }

    getAdvancedPageSwitchValue(callback) {
        let result: LooseObject = {
            deliveryReportSwitch: false,
            autoRetrieveMmsSwitch: false,
            recallMessageSwitch: false,
            autoDeleteInfoSwitch: false
        };
        result.deliveryReportSwitch = MmsPreferences.getInstance().getValueOfDeliveryReportSwitch();
        result.autoRetrieveMmsSwitch = MmsPreferences.getInstance().getValueOfAutoRetrieveMmsSwitch();
        if (MmsPreferences.getInstance().getValueOfRecallMessageSwitch() == common.bool.TRUE) {
            result.recallMessageSwitch = true;
        }
        if (MmsPreferences.getInstance().getValueOfAutoDeleteInfoSwitch() == common.bool.TRUE) {
            result.autoDeleteInfoSwitch = true;
        }
        callback(this.encapsulateReturnResult(common.int.SUCCESS, result));
    }

    updateSmscNumber(actionData, callback) {
        let index = actionData.index - 1;
        let newTelNum = actionData.number;
        telephonySMS.setSmscAddr(index, newTelNum).then( value => {
            // If card 1
            if (index == common.int.SIM_ONE) {
                MmsPreferences.getInstance().setValueForSwitch(common.string.KEY_OF_NEW_SIM_0_SMSC, newTelNum);
            } else if (index == common.int.SIM_TWO) {
                MmsPreferences.getInstance().setValueForSwitch(common.string.KEY_OF_NEW_SIM_1_SMSC, newTelNum);
            }
            return this.encapsulateReturnResult(common.int.SUCCESS, common.string.SUCCESS)
        }).catch((error) => {
            HiLog.e(TAG, "updateSmscNumber, setSmscAddr, error: " + JSON.stringify(error.message));
            return this.encapsulateReturnCode(common.int.FAILURE);
        });
    }

    shareSmsEnterSelectedText(actionData, callback) {
        // The sharing API is not provided.
        callback(this.encapsulateReturnResult(common.int.SUCCESS, common.string.SUCCESS));
    }

    updateSwitchValue(keyOfSwitch, valueOfSwitch, callback) {
        MmsPreferences.getInstance().setValueForSwitch(keyOfSwitch, valueOfSwitch);
        callback(this.encapsulateReturnResult(common.int.SUCCESS, common.string.SUCCESS));
    }

    restoreSwitchValueToDefault(callback) {
        MmsPreferences.getInstance().setValueForSwitch(common.string.KEY_OF_INTEGRATION_SWITCH, common.bool.TRUE);
        MmsPreferences.getInstance().setValueForSwitch(common.string.KEY_OF_MALICIOUS_WEB_SWITCH, common.bool.FALSE);
        MmsPreferences.getInstance().setValueForSwitch(common.string.KEY_OF_SHOW_CONTACT_SWITCH, common.bool.TRUE);
        MmsPreferences.getInstance()
            .setValueForSwitch(common.string.KEY_OF_DELIVERY_REPORT_SWITCH, common.DELIVERY_REPORTS.DISABLED);
        MmsPreferences.getInstance().setValueForSwitch(common.string.KEY_OF_AUTO_RETRIEVE_SWITCH,
            common.AUTO_RETRIEVE_MMS.NOT_WHEN_ROAMING);
        MmsPreferences.getInstance().setValueForSwitch(common.string.KEY_OF_RECALL_MESSAGE_SWITCH, common.bool.FALSE);
        MmsPreferences.getInstance().setValueForSwitch(common.string.KEY_OF_AUTO_DELETE_INFO_SWITCH, common.bool.FALSE);
        callback(this.encapsulateReturnResult(common.int.SUCCESS, common.string.SUCCESS));
    }
}