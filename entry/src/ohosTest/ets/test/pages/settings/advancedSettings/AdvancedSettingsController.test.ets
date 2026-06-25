/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
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
import { describe, beforeEach, afterEach, it, expect, MockKit, when, ArgumentMatchers } from '@ohos/hypium';
import LooseObject from '../../../../../../main/ets/data/LooseObject';
import AdvancedSettingsController
  from '../../../../../../main/ets/pages/settings/advancedSettings/advancedSettingsController';
import HiLog from '../../../../../../main/ets/utils/HiLog';
import SharedPreferencesUtils from '../../../../../../main/ets/utils/SharedPreferencesUtils';
import common from '../../../../../../main/ets/data/commonData'
import DotUtil from '../../../../../../main/ets/utils/MmsDot/DotUtils';
import MmsPreferences from '../../../../../../main/ets/utils/MmsPreferences';
import MessageUtil from '../../../../../../main/cust/utils/MessageUtil';
import SettingModel from '../../../../../../main/ets/model/SettingsModel';
import { mSettingModel } from '../../../../../../main/ets/service/SettingService';

export default function advancedSettingsControllerTest() {
  describe('advancedSettingsControllerTest', () => {

    const TAG = 'AdvancedSettingsController';
    let advancedSettingsCtrl: AdvancedSettingsController;
    let mocker: MockKit;

    beforeEach(() => {
      advancedSettingsCtrl = AdvancedSettingsController.getTestInstance();
      mocker = new MockKit();
    })

    afterEach(() => {
      mocker.clear(advancedSettingsCtrl);
    })

    it('AdvancedSettingsController_getInstance',0,()=>{
      expect(typeof advancedSettingsCtrl).assertEqual(typeof AdvancedSettingsController.getInstance());
    })

    it('AdvancedSettingsController_onInit', 0, () => {
      let pageInfos: NavPathStack = new NavPathStack();
      advancedSettingsCtrl.onInit(pageInfos);
      expect(JSON.stringify(advancedSettingsCtrl.pageInfos)).assertEqual(JSON.stringify(pageInfos));
    })

    it('AdvancedSettingsController_onShow', 0, () => {
      mocker.mockFunc(HiLog, HiLog.i);
      advancedSettingsCtrl.onShow();
      mocker.verify('i', [TAG, 'onShow, start']).never();
      mocker.clear(HiLog);
    })

    it('AdvancedSettingsController_getAdvancedPageSwitchValue_true', 0, () => {
      let getFromPreferences: Function =
        mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences);
      when(getFromPreferences)('isAdvancedMode').afterReturn(true);
      when(getFromPreferences)(common.STR.KEY_OF_DELIVERY_REPORT_SWITCH).afterReturn(true);
      mocker.mockFunc(advancedSettingsCtrl, advancedSettingsCtrl.returnDeliveryReportResultInText);
      advancedSettingsCtrl.getAdvancedPageSwitchValue();
      expect(advancedSettingsCtrl.isAdvancedSecurity).assertTrue();
      mocker.clear(SharedPreferencesUtils);
    })

    it('AdvancedSettingsController_getAdvancedPageSwitchValue_false', 0, () => {
      let getFromPreferences: Function =
        mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences);
      when(getFromPreferences)('isAdvancedMode').afterReturn(false);
      when(getFromPreferences)(common.STR.KEY_OF_DELIVERY_REPORT_SWITCH).afterReturn(false);
      mocker.mockFunc(advancedSettingsCtrl, advancedSettingsCtrl.returnDeliveryReportResultInText);
      advancedSettingsCtrl.getAdvancedPageSwitchValue();
      expect(advancedSettingsCtrl.isAdvancedSecurity).assertFalse();
      mocker.clear(SharedPreferencesUtils);
    })

    it('AdvancedSettingsController_returnDeliveryReportResultInText_intValue_empty', 0, () => {
      advancedSettingsCtrl.returnDeliveryReportResultInText('');
      expect(advancedSettingsCtrl.checkedValueOfSms).assertFalse();
    })

    it('AdvancedSettingsController_returnDeliveryReportResultInText_intValue_0', 0, () => {
      advancedSettingsCtrl.returnDeliveryReportResultInText('0');
      expect(advancedSettingsCtrl.checkedValueOfSms).assertFalse();
    })

    it('AdvancedSettingsController_returnDeliveryReportResultInText_intValue_1', 0, () => {
      advancedSettingsCtrl.returnDeliveryReportResultInText('1');
      expect(advancedSettingsCtrl.checkedValueOfSms).assertTrue();
    })

    it('AdvancedSettingsController_returnDeliveryReportResultInText_intValue_2', 0, () => {
      advancedSettingsCtrl.returnDeliveryReportResultInText('2');
      expect(advancedSettingsCtrl.checkedValueOfSms).assertFalse();
    })

    it('AdvancedSettingsController_returnDeliveryReportResultInText_intValue_3', 0, () => {
      advancedSettingsCtrl.returnDeliveryReportResultInText('3');
      expect(advancedSettingsCtrl.checkedValueOfSms).assertTrue();
    })

    it('AdvancedSettingsController_clickSmsDiv', 0, () => {
      advancedSettingsCtrl.checkedValueOfSms = false;
      advancedSettingsCtrl.clickSmsDiv();
      expect(advancedSettingsCtrl.checkedValueOfSms).assertTrue();
    })

    it('AdvancedSettingsController_clickSmsCheckbox', 0, () => {
      advancedSettingsCtrl.clickSmsCheckbox(true);
      expect(advancedSettingsCtrl.checkedValueOfSms).assertTrue();
    })

    it('AdvancedSettingsController_clickMmsDiv', 0, () => {
      advancedSettingsCtrl.checkedValueOfSms = false;
      advancedSettingsCtrl.clickMmsDiv();
      expect(advancedSettingsCtrl.checkedValueOfMms).assertFalse();
    })

    it('AdvancedSettingsController_clickMmsCheckbox', 0, () => {
      advancedSettingsCtrl.clickMmsCheckbox(true);
      expect(advancedSettingsCtrl.checkedValueOfMms).assertTrue();
    })

    it('AdvancedSettingsController_cancelRestore', 0, () => {
      advancedSettingsCtrl.deliveryReportSwitch = "1";
      let res = false;
      when(mocker.mockFunc(advancedSettingsCtrl,
        advancedSettingsCtrl.returnDeliveryReportResultInText))(ArgumentMatchers.any)
        .afterAction(() => {
          res = true;
        });
      advancedSettingsCtrl.cancelRestore();
      expect(res).assertTrue();
    })

    it('AdvancedSettingsController_setRestore_checkedValueOfSms_true_checkedValueOfMms_true', 0, () => {
      mocker.mockFunc(advancedSettingsCtrl, advancedSettingsCtrl.returnDeliveryReportResultInText);
      mocker.mockFunc(advancedSettingsCtrl, advancedSettingsCtrl.autoHandleDeliveryReportValueChange);
      advancedSettingsCtrl.setRestore(true, true);
      expect(advancedSettingsCtrl.deliveryReportSwitch).assertEqual('3');
    })

    it('AdvancedSettingsController_setRestorecheckedValueOfSms_true_checkedValueOfMms_false', 0, () => {
      mocker.mockFunc(advancedSettingsCtrl, advancedSettingsCtrl.returnDeliveryReportResultInText);
      mocker.mockFunc(advancedSettingsCtrl, advancedSettingsCtrl.autoHandleDeliveryReportValueChange);
      advancedSettingsCtrl.setRestore(true, false);
      expect(advancedSettingsCtrl.deliveryReportSwitch).assertEqual('1');
    })

    it('AdvancedSettingsController_setRestore_false_checkedValueOfMms_true', 0, () => {
      mocker.mockFunc(advancedSettingsCtrl, advancedSettingsCtrl.returnDeliveryReportResultInText);
      mocker.mockFunc(advancedSettingsCtrl, advancedSettingsCtrl.autoHandleDeliveryReportValueChange);
      advancedSettingsCtrl.setRestore(false, true);
      expect(advancedSettingsCtrl.deliveryReportSwitch).assertEqual('2');
    })

    it('AdvancedSettingsController_setRestore_false_checkedValueOfMms_false', 0, () => {
      mocker.mockFunc(advancedSettingsCtrl, advancedSettingsCtrl.returnDeliveryReportResultInText);
      mocker.mockFunc(advancedSettingsCtrl, advancedSettingsCtrl.autoHandleDeliveryReportValueChange);
      advancedSettingsCtrl.setRestore(false, false);
      expect(advancedSettingsCtrl.deliveryReportSwitch).assertEqual('0');
    })

    it('AdvancedSettingsController_autoHandleDeliveryReportValueChange', 0, () => {
      let res = false;
      when(mocker.mockFunc(advancedSettingsCtrl,
        advancedSettingsCtrl.updateAdvancedPageSwitchValue))(ArgumentMatchers.any)
        .afterAction(() => {
          res = true;
        });
      advancedSettingsCtrl.autoHandleDeliveryReportValueChange("1");
      expect(res).assertTrue();
    })

    it('AdvancedSettingsController_updateAdvancedPageSwitchValue', 0, () => {
      let res = false;
      when(mocker.mockFunc(MmsPreferences.getInstance(),
        MmsPreferences.getInstance().setValueForSwitch))(common.STR.KEY_OF_DELIVERY_REPORT_SWITCH)
        .afterAction(() => {
          res = true;
        });
      when(mocker.mockFunc(HiLog, HiLog.i))(TAG).afterAction(() => {
        expect(res).assertTrue();
      })
      advancedSettingsCtrl.updateAdvancedPageSwitchValue(32001, {
        intValue: 1
      });
      mocker.clear(MmsPreferences.getInstance());
      mocker.clear(HiLog);
    })
  })
}