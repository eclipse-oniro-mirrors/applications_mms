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
import LooseObject from '../../../data/LooseObject'
import HiLog from '../../../utils/HiLog';
import router from '@system.router';
import prompt from '@system.prompt';
import settingService from '../../../service/SettingService'
import common from '../../../data/commonData';
import MmsBoolean from '../../../data/MmsBoolean'
import emitter from '@ohos.events.emitter';
import simCardService from '../../../service/SimCardService'
import MmsPreferences from '../../../utils/MmsPreferences';
import { ActionData } from '../../conversationlist/conversationListController';
import sms from '@ohos.telephony.sms';
import { BusinessError } from '@ohos.base';
import { GlobalContext } from '../../../MainAbility/GlobalHelper';
import StringUtil from '../../../utils/StringUtil';
import OperatorConfigUtil from '../../../../cust/utils/OperatorConfigUtil';
import SharedPreferencesUtils from '../../../utils/SharedPreferencesUtils';
import preferences from '@ohos.data.preferences';
import dotCommon, { selectStateParams, stateParam } from '../../../utils/MmsDot/DotCommon';
import DotUtil from '../../../utils/MmsDot/DotUtils';
import commonEventManager from '@ohos.commonEventManager';
import Base from '@ohos.base';
import myCommon from '@ohos.app.ability.common';
import sim from '@ohos.telephony.sim';
import { SystemMode } from '../../../utils/SystemMode';
import MessageUtil from '../../../../cust/utils/MessageUtil';
import EmitterConstant from '../../../data/EmitterConstant';

const TAG = 'AdvancedSettingsController';

class Result {
    code: number = -1;
    abilityResult: AbilityResult = new AbilityResult()
}

class AbilityResult {
    deliveryReportSwitch: string = '';
}

export default class AdvancedSettingsController {
    private static sInstance: AdvancedSettingsController;
    // Delivery Report SMS
    checkedValueOfSms: boolean = false;
    // Delivery Report MMS
    checkedValueOfMms: boolean = false;
    // Value of Delivery Report Switch
    deliveryReportSwitch: string = common.DELIVERY_REPORTS.DISABLED;
    // Delivery Report Text
    deliveryReportSwitchInText: Resource = $r('app.string.disabled');
    refresh: boolean = false;
    pageInfos: NavPathStack = new NavPathStack();
    //Option button 1
    isCheckedValue: boolean = false;
    slotId: number = MmsPreferences.getInstance().getDefaultSlotId();
    checkedIndex: string = '';
    isAdvancedSecurity: preferences.ValueType = false;
    static getInstance() {
        if (AdvancedSettingsController.sInstance == null) {
            AdvancedSettingsController.sInstance = new AdvancedSettingsController();
        }
        return AdvancedSettingsController.sInstance;
    }

    static getTestInstance() {
      return new AdvancedSettingsController();
    }

    constructor() {
        HiLog.i(TAG, 'constructor, start');
        this.getAdvancedPageSwitchValue();
    }

    onInit(pageInfos: NavPathStack) {
      HiLog.i(TAG, 'onInit, start');
        this.pageInfos = pageInfos;
    }

    onShow() {
        HiLog.i(TAG, 'onShow, start');
    }

    getAdvancedPageSwitchValue() {
        HiLog.i(TAG, 'getAdvancedPageSwitchValue, start');
        let that = this;
        this.isAdvancedSecurity = SharedPreferencesUtils.getFromPreferences('isAdvancedMode', '');
        settingService.getAdvancedPageSwitchValue((result: Result) => {
            if (result.code === common.int.SUCCESS) {
                let switchValue: AbilityResult = result.abilityResult;
                that.deliveryReportSwitch = switchValue.deliveryReportSwitch;
                that.returnDeliveryReportResultInText(that.deliveryReportSwitch);
            } else {
                HiLog.w(TAG, 'getAdvancedPageSwitchValue, failed');
            }
        });
    }
    // Returns the text version of the delivery report result based on an integer value
    returnDeliveryReportResultInText(intValue: string) {
        let tempValue: Resource | null = null
        if (intValue == common.DELIVERY_REPORTS.DISABLED || intValue == '') {
            tempValue = $r('app.string.disabled');
            this.checkedValueOfSms = false;
            this.checkedValueOfMms = false;
        } else if (intValue == common.DELIVERY_REPORTS.SMS) {
            tempValue = $r('app.string.sms');
            this.checkedValueOfSms = true;
            this.checkedValueOfMms = false;
        } else if (intValue == common.DELIVERY_REPORTS.MMS) {
            tempValue = $r('app.string.mms');
            this.checkedValueOfSms = false;
            this.checkedValueOfMms = true;
        } else {
            tempValue = $r('app.string.sms_and_mms');
            this.checkedValueOfSms = true;
            this.checkedValueOfMms = true;
        }
        this.deliveryReportSwitchInText = tempValue;
        this.refresh = !this.refresh;
    }
    // Back button
    back() {
        this.pageInfos.pop();
    }
    // Restore the default values on the settings page.
    restoreSettingPageSwitchValue() {
        HiLog.i(TAG, 'restoreSettingPageSwitchValue');
        let that = this;
        settingService.restoreSwitchValue((result: Result) => {
            if (result.code === common.int.SUCCESS) {
                that.deliveryReportSwitch = common.DELIVERY_REPORTS.DISABLED;
                that.returnDeliveryReportResultInText(common.DELIVERY_REPORTS.DISABLED);
                HiLog.i(TAG, 'restoreSettingPageSwitchValue, success');
            } else {
                HiLog.w(TAG, 'restoreSettingPageSwitchValue, failed');
            }
        });
    }
    // Click the text line.
    clickSmsDiv() {
        this.checkedValueOfSms = !this.checkedValueOfSms;
    }
    // Click Checkbox in the line of the message.
    clickSmsCheckbox(e: boolean) {
        this.checkedValueOfSms = e;
    }
    // Click the MMS line.
    clickMmsDiv() {
        this.checkedValueOfMms = !this.checkedValueOfMms;
    }
    // Click Checkbox in the MMS line.
    clickMmsCheckbox(e: boolean) {
        this.checkedValueOfMms = e;
    }
    // Cancel the configuration restoration dialog box.
    cancelRestore() {
        this.returnDeliveryReportResultInText(this.deliveryReportSwitch);
    }
    // delivery report dialog, OK
    setRestore(isOnOfSms: boolean, isOnOfMms: boolean) {
        this.checkedValueOfSms = isOnOfSms;
        this.checkedValueOfMms = isOnOfMms;
        this.deliveryReportSwitch = common.STR.EMPTY_STR;
        if (this.checkedValueOfSms && this.checkedValueOfMms) {
            this.deliveryReportSwitch = common.DELIVERY_REPORTS.SMS_AND_MMS;
            selectStateParams.SELECT_STATE = 3;
        } else if (this.checkedValueOfSms) {
            this.deliveryReportSwitch = common.DELIVERY_REPORTS.SMS;
            selectStateParams.SELECT_STATE = 1;
        } else if (this.checkedValueOfMms) {
            this.deliveryReportSwitch = common.DELIVERY_REPORTS.MMS;
            selectStateParams.SELECT_STATE = 2;
        } else {
            this.deliveryReportSwitch = common.DELIVERY_REPORTS.DISABLED;
            selectStateParams.SELECT_STATE = 0;
        }
        this.returnDeliveryReportResultInText(this.deliveryReportSwitch);
        this.autoHandleDeliveryReportValueChange(this.deliveryReportSwitch);
    }
    // When the value of deliveryReportSwitch changes, this method is used to process the change.
    autoHandleDeliveryReportValueChange(newValue: string) {
        HiLog.iw(TAG, 'autoHandleDeliveryReportValueChange, newValue = ' + newValue);
        let messageCode = common.route.MESSAGE_CODE_UPDATE_DELIVERY_REPORTS_VALUE;
        let actionData: LooseObject = {};
        actionData.intValue = newValue;
        this.updateAdvancedPageSwitchValue(messageCode, actionData);
    }
    // Update Switch Value
    updateAdvancedPageSwitchValue(messageCode: number, actionData: LooseObject) {
        settingService.updateSettingValue(messageCode, actionData, (result: Result) => {
            if (result.code == common.int.SUCCESS) {
                HiLog.i(TAG, 'updateAdvancedPageSwitchValue, success');
            } else {
                HiLog.w(TAG, 'updateAdvancedPageSwitchValue, failed');
            }
        });
    }
}