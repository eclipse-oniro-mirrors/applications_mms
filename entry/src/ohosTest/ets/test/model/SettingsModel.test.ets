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
import { describe, beforeEach, it, expect, MockKit, when, ArgumentMatchers } from '@ohos/hypium';
import common from '../../../../main/ets/data/commonData';
import LooseObject from '../../../../main/ets/data/LooseObject';
import MmsPreferences from '../../../../main/ets/utils/MmsPreferences';
import SettingModel from '../../../../main/ets/model/SettingsModel';
import SharedPreferencesUtils from '../../../../main/ets/utils/SharedPreferencesUtils';

export default function settingModelTest() {
  describe('settingModelTest', () => {

    let mSettingModel: SettingModel;

    beforeEach(() => {
      mSettingModel = new SettingModel();
    })

    it('SettingModel_setOnSettingValueListener', 0, () => {
      let mocker: MockKit = new MockKit();
      let getFromPreferences: Function =
        mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences);
      when(getFromPreferences)(ArgumentMatchers.any).afterReturn('');

      mSettingModel.setOnSettingValueListener((result: LooseObject) => {
        expect(result.showContactSwitch).assertEqual('');
        mocker.clear(SharedPreferencesUtils);
      });

      mocker.clear(SharedPreferencesUtils);
    })

    it('SettingModel_getSettingValue', 0, () => {
      let mocker: MockKit = new MockKit();
      let getFromPreferences: Function =
        mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences);

      when(getFromPreferences)(ArgumentMatchers.any).afterReturn('');

      mSettingModel.getSettingValue((result: LooseObject) => {
        expect(result.code).assertEqual(0);
        mocker.clear(SharedPreferencesUtils);
      });

      mocker.clear(SharedPreferencesUtils);
    })

    it('SettingModel_getAdvancedPageSwitchValue_true', 0, () => {
      let mocker: MockKit = new MockKit();
      let getFromPreferences: Function =
        mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences);

      when(getFromPreferences)(ArgumentMatchers.any).afterReturn(true);

      mSettingModel.getAdvancedPageSwitchValue((result: LooseObject) => {
        expect(result.code).assertEqual(0);
        mocker.clear(SharedPreferencesUtils);
      });

      mocker.clear(SharedPreferencesUtils);
    })

    it('SettingModel_getAdvancedPageSwitchValue_false', 0, () => {
      let mocker: MockKit = new MockKit();
      let getFromPreferences: Function =
        mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences);

      when(getFromPreferences)(ArgumentMatchers.any).afterReturn('');

      when(getFromPreferences)('isAdvancedMode').afterReturn(false);

      mSettingModel.getAdvancedPageSwitchValue((result: LooseObject) => {
        expect(result.code).assertEqual(0);
        mocker.clear(SharedPreferencesUtils);
      });

      mocker.clear(SharedPreferencesUtils);
    })

    it('SettingModel_shareSmsEnterSelectedText', 0, () => {
      let actionData: LooseObject = {};
      mSettingModel.shareSmsEnterSelectedText(actionData, (result: LooseObject) => {
        expect(result.code).assertEqual(0);
      })
    })

    it('SettingModel_restoreSwitchValueToDefault', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(MmsPreferences.getInstance(), MmsPreferences.getInstance().setValueForSwitch);

      mSettingModel.restoreSwitchValueToDefault((result: LooseObject) => {
        expect(result.code).assertEqual(0);
      });

      mocker.clear(MmsPreferences.getInstance());
      mocker.clear(mSettingModel);
    })
  })
}