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

import BaseModel from './BaseModel';
import common from '../data/commonData'
import HiLog from '../utils/HiLog';
import MmsPreferences from '../utils/MmsPreferences';
import telephonySMS from '@ohos.telephony.sms';
import LooseObject from '../data/LooseObject'
import { BusinessError } from '@ohos.base';
import SharedPreferencesUtils from '../utils/SharedPreferencesUtils';
import settings from '@ohos.settings';
import { GlobalContext } from '../MainAbility/GlobalHelper';

const TAG = 'SettingModel';

export default class SettingModel extends BaseModel {
    setOnSettingValueListener(callback: Function) {
        let data: LooseObject = {};
        data.integrationSwitch = SharedPreferencesUtils.getFromPreferences(common.STR.KEY_OF_INTEGRATION_SWITCH,
            common.bool.FALSE)
        let context = getContext(this);
        data.showContactSwitch = this.getShowContactSwitchValue();
        callback(data);
    }

    getSettingValue(callback: Function) {
        let settingValues: LooseObject = {};
        settingValues.hasAggregate = SharedPreferencesUtils.getFromPreferences(common.STR.KEY_OF_INTEGRATION_SWITCH,
            common.bool.FALSE)
        settingValues.isShowContactHeadIcon = this.getShowContactSwitchValue();
        settingValues.isDistributedFlag = SharedPreferencesUtils.getFromPreferences(
            common.STR.ONLY_RECEIVE_NOT_SEND,
            0)
        callback(this.encapsulateReturnResult(common.int.SUCCESS, settingValues));
    }

    getShowContactSwitchValue(): string {
        let showContactSwitchValue: string = SharedPreferencesUtils.getFromPreferences(
            common.STR.KEY_OF_SHOW_CONTACT_SWITCH,
            common.bool.NOT_SET) as string;
        if (showContactSwitchValue == common.bool.NOT_SET) {
            HiLog.i(TAG, 'showContactSwitch initialize!');
            SharedPreferencesUtils.saveToPreferences(common.STR.KEY_OF_SHOW_CONTACT_SWITCH,
                common.bool.TRUE);
            showContactSwitchValue = common.bool.TRUE;
        }
        return showContactSwitchValue;
    }

    getAdvancedPageSwitchValue(callback: Function) {
        let isAdvancedSecurity = SharedPreferencesUtils.getFromPreferences('isAdvancedMode', '');
        HiLog.i(TAG, 'isAdvancedSecurity' + isAdvancedSecurity);
        let result: Record<string, Boolean | string> = {
            'deliveryReportSwitch': false,
        };
        result.deliveryReportSwitch = SharedPreferencesUtils.getFromPreferences(
            common.STR.KEY_OF_DELIVERY_REPORT_SWITCH, common.DELIVERY_REPORTS.DISABLED) as string;
        HiLog.i(TAG, 'getAdvancedPageSwitchValue:' + JSON.stringify(result))
        callback(this.encapsulateReturnResult(common.int.SUCCESS, result));
    }

    shareSmsEnterSelectedText(actionData: LooseObject, callback: Function) {
        // The sharing API is not provided.
        callback(this.encapsulateReturnResult(common.int.SUCCESS, common.STR.SUCCESS));
    }

    updateSwitchValue(keyOfSwitch: string, valueOfSwitch: string, callback: Function) {
        MmsPreferences.getInstance().setValueForSwitch(keyOfSwitch, valueOfSwitch);
        callback(this.encapsulateReturnResult(common.int.SUCCESS, common.STR.SUCCESS));
    }

    restoreSwitchValueToDefault(callback: Function) {
        MmsPreferences.getInstance().setValueForSwitch(common.STR.KEY_OF_INTEGRATION_SWITCH, common.bool.FALSE);
        MmsPreferences.getInstance().setValueForSwitch(common.STR.KEY_OF_SHOW_CONTACT_SWITCH, common.bool.TRUE);
        MmsPreferences.getInstance()
            .setValueForSwitch(common.STR.KEY_OF_DELIVERY_REPORT_SWITCH, common.DELIVERY_REPORTS.DISABLED);
        callback(this.encapsulateReturnResult(common.int.SUCCESS, common.STR.SUCCESS));
    }

    static getDistributedModemState(context: Context) {
        return settings.getValueSync(context, common.STR.KEY_OF_DISTRIBUTED_MODEM_STATE, common.bool.FALSE);
    }

    static getDistributedSwitchState(context: Context) {
        return settings.getValueSync(context, common.STR.DISTRIBUTED_CALL_SMS_SHARING, common.bool.FALSE);
    }
}