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
import SharedPreferencesUtils from '../../../../../main/ets/utils/SharedPreferencesUtils';
import SettingsController from "../../../../../main/ets/pages/settings/settingsController";
import LooseObject from "../../../../../main/ets/data/LooseObject";
import HiLog from '../../../../../main/ets/utils/HiLog';
import DotUtil from '../../../../../main/ets/utils/MmsDot/DotUtils';
import { seleteParam, stateParam } from '../../../../../main/ets/utils/MmsDot/DotCommon';
import MmsPreferences from '../../../../../main/ets/utils/MmsPreferences';
import { mSettingModel } from '../../../../../main/ets/service/SettingService';


export default function settingsControllerTest() {
  describe('settingsControllerTest', () => {


    const TAG = 'SettingsController';

    beforeEach(() => {
      AppStorage.clear();
    })

    it('settingsController_onInit', 0, () => {
      let pageInfos: NavPathStack = new NavPathStack();
      let mocker: MockKit = new MockKit();
      let getFromPreferences: Function =
        mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences);
      when(getFromPreferences)(ArgumentMatchers.any).afterReturn(true);
      when(getFromPreferences)('isOpenRcs').afterReturn(false);
      when(getFromPreferences)('showContactSwitch').afterReturn(true);
      when(getFromPreferences)('integrationSwitch').afterReturn(true);
      when(getFromPreferences)('showContactSwitch').afterReturn(true);
      let settingsController: SettingsController = SettingsController.getInstance();

      settingsController.onInit(pageInfos);

      expect(JSON.stringify(settingsController.pageInfos)).assertEqual(JSON.stringify(pageInfos));

      mocker.clear(settingsController);
      mocker.clear(SharedPreferencesUtils);
    })

    it('settingsController_onShow', 0, () => {
      let mocker: MockKit = new MockKit();
      let getFromPreferences: Function =
        mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences);
      when(getFromPreferences)(ArgumentMatchers.any).afterReturn(true);
      when(getFromPreferences)('isOpenRcs').afterReturn(false);
      when(getFromPreferences)('showContactSwitch').afterReturn(true);
      when(getFromPreferences)('integrationSwitch').afterReturn(true);
      when(getFromPreferences)('showContactSwitch').afterReturn(true);
      let settingsController: SettingsController = SettingsController.getInstance();
      mocker.mockFunc(settingsController, settingsController.getSettingPageSwitchValue);

      settingsController.onShow();

      mocker.verify('getSettingPageSwitchValue', []).once();

      mocker.clear(settingsController);
      mocker.clear(SharedPreferencesUtils);
    })

    it('settingsController_getSettingPageSwitchValue', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.i);
      let getFromPreferences: Function =
        mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences);
      when(getFromPreferences)(ArgumentMatchers.any).afterReturn(true);
      when(getFromPreferences)('isOpenRcs').afterReturn(false);
      when(getFromPreferences)('showContactSwitch').afterReturn(true);
      when(getFromPreferences)('integrationSwitch').afterReturn(true);
      when(getFromPreferences)('showContactSwitch').afterReturn(true);
      let settingsController: SettingsController = SettingsController.getInstance();

      settingsController.getSettingPageSwitchValue();

      mocker.verify('getFromPreferences', ['isOpenRcs']).never();

      mocker.clear(HiLog);
      mocker.clear(SharedPreferencesUtils);
    })

    it('settingsController_integration_value_true_insOn_false_curBp_sm', 0, () => {
      AppStorage.setOrCreate('curBp', 'sm');
      let mocker: MockKit = new MockKit();
      let getFromPreferences: Function =
        mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences);
      when(getFromPreferences)(ArgumentMatchers.any).afterReturn(true);
      when(getFromPreferences)('isOpenRcs').afterReturn(false);
      when(getFromPreferences)('showContactSwitch').afterReturn(true);
      when(getFromPreferences)('integrationSwitch').afterReturn(true);
      when(getFromPreferences)('showContactSwitch').afterReturn(true);
      let settingsController: SettingsController = SettingsController.getInstance();
      mocker.mockFunc(DotUtil.getInstance(), DotUtil.getInstance().reportEvent);
      mocker.mockFunc(settingsController, settingsController.updateSettingPageSwitchValue);

      settingsController.integration(false);

      stateParam.STATE = 2;
      mocker.verify('reportEvent', [stateParam, 'SETTING_ARCHIVE_INFO_SMS']).once();

      mocker.clear(settingsController);
      mocker.clear(DotUtil.getInstance());
      mocker.clear(SharedPreferencesUtils);
    })

    it('settingsController_integration_value_true_insOn_true_curBp_md', 0, () => {
      AppStorage.setOrCreate('curBp', 'md');
      let mocker: MockKit = new MockKit();
      let getFromPreferences: Function =
        mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences);
      when(getFromPreferences)(ArgumentMatchers.any).afterReturn(true);
      when(getFromPreferences)('isOpenRcs').afterReturn(false);
      when(getFromPreferences)('showContactSwitch').afterReturn(true);
      when(getFromPreferences)('integrationSwitch').afterReturn(true);
      when(getFromPreferences)('showContactSwitch').afterReturn(true);
      let settingsController: SettingsController = SettingsController.getInstance();
      mocker.mockFunc(DotUtil.getInstance(), DotUtil.getInstance().reportEvent);
      mocker.mockFunc(settingsController, settingsController.updateSettingPageSwitchValue);

      settingsController.integration(true);

      stateParam.STATE = 1;
      mocker.verify('reportEvent', [stateParam, 'SETTING_ARCHIVE_INFO_SMS']).once();

      mocker.clear(settingsController);
      mocker.clear(DotUtil.getInstance());
      mocker.clear(SharedPreferencesUtils);
    })

    it('settingsController_jumpToMessageTonePage', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.i);
      let getFromPreferences: Function =
        mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences);
      when(getFromPreferences)(ArgumentMatchers.any).afterReturn(true);
      when(getFromPreferences)('isOpenRcs').afterReturn(false);
      when(getFromPreferences)('showContactSwitch').afterReturn(true);
      when(getFromPreferences)('integrationSwitch').afterReturn(true);
      when(getFromPreferences)('showContactSwitch').afterReturn(true);
      let settingsController: SettingsController = SettingsController.getInstance();

      settingsController.jumpToMessageTonePage()

      mocker.verify('getFromPreferences', ['isOpenRcs']).never();

      mocker.clear(HiLog);
      mocker.clear(SharedPreferencesUtils);
    })

    it('settingsController_showContact_isOn_false', 0, () => {
      AppStorage.setOrCreate('curBp', 'sm');
      let mocker: MockKit = new MockKit();
      let getFromPreferences: Function =
        mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences);
      when(getFromPreferences)(ArgumentMatchers.any).afterReturn(true);
      when(getFromPreferences)('isOpenRcs').afterReturn(false);
      when(getFromPreferences)('showContactSwitch').afterReturn(true);
      when(getFromPreferences)('integrationSwitch').afterReturn(true);
      when(getFromPreferences)('showContactSwitch').afterReturn(true);
      let settingsController: SettingsController = SettingsController.getInstance();
      mocker.mockFunc(DotUtil.getInstance(), DotUtil.getInstance().reportEvent);
      mocker.mockFunc(settingsController, settingsController.updateSettingPageSwitchValue);

      settingsController.showContact(false);

      seleteParam.SELECT_STATE = 1;
      mocker.verify('reportEvent', [seleteParam, 'SHOW_CONTACT_AVATAR']).once();

      mocker.clear(settingsController);
      mocker.clear(DotUtil.getInstance());
      mocker.clear(SharedPreferencesUtils);
    })

    it('settingsController_showContact_isOn_true', 0, () => {
      AppStorage.setOrCreate('curBp', 'md');
      let mocker: MockKit = new MockKit();
      let getFromPreferences: Function =
        mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences);
      when(getFromPreferences)(ArgumentMatchers.any).afterReturn(true);
      when(getFromPreferences)('isOpenRcs').afterReturn(false);
      when(getFromPreferences)('showContactSwitch').afterReturn(true);
      when(getFromPreferences)('integrationSwitch').afterReturn(true);
      when(getFromPreferences)('showContactSwitch').afterReturn(true);
      let settingsController: SettingsController = SettingsController.getInstance();
      mocker.mockFunc(DotUtil.getInstance(), DotUtil.getInstance().reportEvent);
      mocker.mockFunc(settingsController, settingsController.updateSettingPageSwitchValue);

      settingsController.showContact(true);

      seleteParam.SELECT_STATE = 0;
      mocker.verify('reportEvent', [seleteParam, 'SHOW_CONTACT_AVATAR']).once();

      mocker.clear(settingsController);
      mocker.clear(DotUtil.getInstance());
      mocker.clear(SharedPreferencesUtils);
    })

    it('settingsController_reStoreDeleteDialog', 0, () => {
      let mocker: MockKit = new MockKit();
      let getFromPreferences: Function =
        mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences);
      when(getFromPreferences)(ArgumentMatchers.any).afterReturn(true);
      when(getFromPreferences)('isOpenRcs').afterReturn(false);
      when(getFromPreferences)('showContactSwitch').afterReturn(true);
      when(getFromPreferences)('integrationSwitch').afterReturn(true);
      when(getFromPreferences)('showContactSwitch').afterReturn(true);
      let settingsController: SettingsController = SettingsController.getInstance();
      mocker.mockFunc(MmsPreferences.getInstance(), MmsPreferences.getInstance().setShowDelDialog);

      settingsController.reStoreDeleteDialog();

      mocker.verify('setShowDelDialog', ['1']).once();

      mocker.clear(MmsPreferences.getInstance());
      mocker.clear(SharedPreferencesUtils);
    })

    it('settingsController_restoreSettingsPageSwitchValue', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.i);
      let getFromPreferences: Function =
        mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences);
      when(getFromPreferences)(ArgumentMatchers.any).afterReturn(true);
      when(getFromPreferences)('isOpenRcs').afterReturn(false);
      when(getFromPreferences)('showContactSwitch').afterReturn(true);
      when(getFromPreferences)('integrationSwitch').afterReturn(true);
      when(getFromPreferences)('showContactSwitch').afterReturn(true);
      let settingsController: SettingsController = SettingsController.getInstance();
      mocker.mockFunc(MmsPreferences.getInstance(), MmsPreferences.getInstance().setValueForSwitch);

      settingsController.restoreSettingsPageSwitchValue();

      mocker.verify('getFromPreferences', ['isOpenRcs']).never();

      mocker.clear(HiLog);
      mocker.clear(SharedPreferencesUtils);
      mocker.clear(mSettingModel);
      mocker.clear(MmsPreferences.getInstance());
    })

    it('settingsController_advancedSetting', 0, () => {
      let mocker: MockKit = new MockKit();
      let getFromPreferences: Function =
        mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences);
      when(getFromPreferences)(ArgumentMatchers.any).afterReturn(true);
      when(getFromPreferences)('isOpenRcs').afterReturn(false);
      when(getFromPreferences)('showContactSwitch').afterReturn(true);
      when(getFromPreferences)('integrationSwitch').afterReturn(true);
      when(getFromPreferences)('showContactSwitch').afterReturn(true);
      let settingsController: SettingsController = SettingsController.getInstance();
      settingsController.advancedSetting();
      expect(JSON.stringify(settingsController.pageInfos.getParamByName('AdvancedSettings'))).assertEqual('[{}]');
      mocker.clear(SharedPreferencesUtils);
    })

    it('settingsController_privacyStateRedirection', 0, () => {
      let mocker: MockKit = new MockKit();
      let getFromPreferences: Function =
        mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences);
      when(getFromPreferences)(ArgumentMatchers.any).afterReturn(true);
      when(getFromPreferences)('isOpenRcs').afterReturn(false);
      when(getFromPreferences)('showContactSwitch').afterReturn(true);
      when(getFromPreferences)('integrationSwitch').afterReturn(true);
      when(getFromPreferences)('showContactSwitch').afterReturn(true);
      let settingsController: SettingsController = SettingsController.getInstance();
      settingsController.privacyStateRedirection();
      expect(JSON.stringify(settingsController.pageInfos.getParamByName('PrivacyState')[0]))
        .assertEqual(JSON.stringify({
          contentTag: 'prilab'
        }));
      mocker.clear(SharedPreferencesUtils);
    })

    it('settingsController_personalInformationListRedirection', 0, () => {
      let mocker: MockKit = new MockKit();
      let getFromPreferences: Function =
        mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences);
      when(getFromPreferences)(ArgumentMatchers.any).afterReturn(true);
      when(getFromPreferences)('isOpenRcs').afterReturn(false);
      when(getFromPreferences)('showContactSwitch').afterReturn(true);
      when(getFromPreferences)('integrationSwitch').afterReturn(true);
      when(getFromPreferences)('showContactSwitch').afterReturn(true);
      let settingsController: SettingsController = SettingsController.getInstance();
      settingsController.personalInformationListRedirection();
      expect(JSON.stringify(settingsController.pageInfos.getParamByName('PrivacyState'))).assertEqual(JSON.stringify([
        {
          "contentTag": "prilab"
        }, {
        contentTag: 'di'
      }]));
      mocker.clear(SharedPreferencesUtils);
    })

    it('settingsController_updateSettingPageSwitchValue', 0, () => {
      let mocker: MockKit = new MockKit();
      let getFromPreferences: Function =
        mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences);
      when(getFromPreferences)(ArgumentMatchers.any).afterReturn(true);
      when(getFromPreferences)('isOpenRcs').afterReturn(false);
      when(getFromPreferences)('showContactSwitch').afterReturn(true);
      when(getFromPreferences)('integrationSwitch').afterReturn(true);
      when(getFromPreferences)('showContactSwitch').afterReturn(true);
      let settingsController: SettingsController = SettingsController.getInstance();
      mocker.mockFunc(HiLog, HiLog.i);
      mocker.mockFunc(MmsPreferences.getInstance(), MmsPreferences.getInstance().setValueForSwitch);

      let messageCode: number = 32001;
      let actionData: LooseObject = {
        'booleanValue': '1'
      };
      settingsController.updateSettingPageSwitchValue(messageCode, actionData);

      mocker.verify('getFromPreferences', ['isOpenRcs']).never();

      mocker.clear(HiLog);
      mocker.clear(SharedPreferencesUtils);
      mocker.clear(MmsPreferences.getInstance());
    })
  })
}