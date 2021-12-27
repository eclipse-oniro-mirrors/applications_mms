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

import BaseModel from '../BaseModel.js';
import common from '../../pages/common_constants.js';
import mmsLog from '../../../default/utils/MmsLog.js';
import telephonySMS from '@ohos.telephony.sms';

const TAG = 'SettingModel.js->';

export default class SettingModel extends BaseModel {
    setOnSettingValueListener(preferences, callback) {
        let data = {};
        data.integrationSwitch = preferences.getValueOfIntegrationSwitch();
        data.maliciousWebSwitch = preferences.getValueOfMaliciousWebSwitch();
        data.showContactSwitch = preferences.getValueOfShowContactSwitch();
        mmsLog.info(TAG + 'setOnSettingValueListener(): data = ' + JSON.stringify(data));
        callback(data);
    }

    getSettingValue(preferences, callback) {
        let settingValues = {};
        settingValues.hasAggregate = preferences.getValueOfIntegrationSwitch();
        settingValues.isShowContactHeadIcon = preferences.getValueOfShowContactSwitch();
        settingValues.recallMessagesFlag = preferences.getValueOfRecallMessageSwitch();
        mmsLog.info(TAG + 'getSettingValue(): settingValues = ' + settingValues);
        callback(super.encapsulateReturnResult(common.int.SUCCESS, settingValues));
    }

    getAdvancedPageSwitchValue(preferences, callback) {
        let result = {
            deliveryReportSwitch: false,
            autoRetrieveMmsSwitch: false,
            recallMessageSwitch: false,
            autoDeleteInfoSwitch: false
        };
        result.deliveryReportSwitch = preferences.getValueOfDeliveryReportSwitch();
        result.autoRetrieveMmsSwitch = preferences.getValueOfAutoRetrieveMmsSwitch();
        if (preferences.getValueOfRecallMessageSwitch() == common.bool.TRUE) {
            result.recallMessageSwitch = true;
        }
        if (preferences.getValueOfAutoDeleteInfoSwitch() == common.bool.TRUE) {
            result.autoDeleteInfoSwitch = true;
        }
        result.simCount = preferences.getCountOfSim();
        if (result.simCount == common.int.SIM_COUNT) {
            result.firstSpnNameOfTwoSimCard = preferences.getSpnOfSim1();
            result.secondSpnNameOfTwoSimCard = preferences.getSpnOfSim2();
        } else {
            if (preferences.getSim1ExistFlag() == common.bool.TRUE) {
                result.spnNameOfOneSimCard = preferences.getSpnOfSim1();
            } else if (preferences.getSim2ExistFlag() == common.bool.TRUE) {
                result.spnNameOfOneSimCard = preferences.getSpnOfSim2();
            } else {
                result.spnNameOfOneSimCard = common.string.EMPTY_STR;
            }
        }
        callback(super.encapsulateReturnResult(common.int.SUCCESS, result));
    }

    updateSmscNumber(actionData, callback) {
        let index = actionData.index - 1;
        let newTelNum = actionData.number;
        let preferences = actionData.preferences;
        mmsLog.log(TAG + 'setSmscAddr actionData:' + actionData);
        telephonySMS.setSmscAddr(index, newTelNum, (value) => {
            mmsLog.log(TAG + 'setSmscAddr ,value :' + value);
            // 如果是卡1
            if(index == common.int.SIM_ONE) {
                preferences.setValueForSwitch(common.string.KEY_OF_NEW_SIM_0_SMSC, newTelNum);
            } else if(index == common.int.SIM_TWO) {
                preferences.setValueForSwitch(common.string.KEY_OF_NEW_SIM_1_SMSC, newTelNum);
            }
            callback(super.encapsulateReturnResult(common.int.SUCCESS, common.string.SUCCESS));
        }).catch((error) => {
            mmsLog.info(TAG + 'setSmscAddr  smsNumber: error = ' + error);
            callback(super.encapsulateReturnCode(common.int.FAILURE));
        });
    }

    shareSmsEnterSelectedText(actionData, callback) {
        // 分享API目前未提供
        callback(super.encapsulateReturnResult(common.int.SUCCESS, common.string.SUCCESS));
    }

    updateSwitchValue(prefer, keyOfSwitch, valueOfSwitch, callback) {
        prefer.setValueForSwitch(keyOfSwitch, valueOfSwitch);
        callback(super.encapsulateReturnResult(common.int.SUCCESS, common.string.SUCCESS));
    }

    restoreSwitchValueToDefault(preferences, callback) {
        preferences.setValueForSwitch(common.string.KEY_OF_INTEGRATION_SWITCH, common.bool.TRUE);
        preferences.setValueForSwitch(common.string.KEY_OF_MALICIOUS_WEB_SWITCH, common.bool.FALSE);
        preferences.setValueForSwitch(common.string.KEY_OF_SHOW_CONTACT_SWITCH, common.bool.TRUE);
        preferences.setValueForSwitch(common.string.KEY_OF_DELIVERY_REPORT_SWITCH, common.DELIVERY_REPORTS.DISABLED);
        preferences.setValueForSwitch(common.string.KEY_OF_AUTO_RETRIEVE_SWITCH,
            common.AUTO_RETRIEVE_MMS.NOT_WHEN_ROAMING);
        preferences.setValueForSwitch(common.string.KEY_OF_RECALL_MESSAGE_SWITCH, common.bool.FALSE);
        preferences.setValueForSwitch(common.string.KEY_OF_AUTO_DELETE_INFO_SWITCH, common.bool.FALSE);
        callback(super.encapsulateReturnResult(common.int.SUCCESS, common.string.SUCCESS));
    }
}