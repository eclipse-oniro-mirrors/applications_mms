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

import { describe, it, expect, MockKit, when, ArgumentMatchers } from '@ohos/hypium';
import common from '../../../../main/ets/data/commonData';
import LooseObject from '../../../../main/ets/data/LooseObject';
import MmsSettingService, { mSettingModel } from '../../../../main/ets/service/SettingService';
import MmsPreferences from '../../../../main/ets/utils/MmsPreferences';
import SharedPreferencesUtils from '../../../../main/ets/utils/SharedPreferencesUtils';

class Result {
  code: number = 0;
  abilityResult: string = ''
}

export default function settingServiceTest() {
  describe('SettingServiceTest', () => {

    it('SettingService_updateSettingValue', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(MmsPreferences.getInstance(), MmsPreferences.getInstance().setValueForSwitch);

      let messageCode = common.route.MESSAGE_CODE_UPDATE_DELIVERY_REPORTS_VALUE;
      let actionData: LooseObject = {};
      actionData.booleanValue = common.bool.TRUE;
      actionData.intValue = 0
      MmsSettingService.updateSettingValue(messageCode, actionData, (res: LooseObject) => {
        expect(res.code).assertEqual(0);
      });

      messageCode = common.route.MESSAGE_CODE_UPDATE_AUTO_RETRIEVE_MMS_VALUE;
      MmsSettingService.updateSettingValue(messageCode, actionData, (res: LooseObject) => {
        expect(res.code).assertEqual(0);
      });

      messageCode = common.route.MESSAGE_CODE_UPDATE_AUTO_DELETE_INFO_MESSAGES_VALUE;
      MmsSettingService.updateSettingValue(messageCode, actionData, (res: LooseObject) => {
        expect(res.code).assertEqual(0);
      });

      messageCode = common.route.MESSAGE_CODE_UPDATE_ARCHIVE_INFO_MESSAGES_VALUE;
      MmsSettingService.updateSettingValue(messageCode, actionData, (res: LooseObject) => {
        expect(res.code).assertEqual(0);
      });

      messageCode = common.route.MESSAGE_CODE_UPDATE_SHOW_CONTACT_PROFILE_PICS_VALUE;
      MmsSettingService.updateSettingValue(messageCode, actionData, (res: LooseObject) => {
        expect(res.code).assertEqual(0);
      });

      messageCode = 0;
      MmsSettingService.updateSettingValue(messageCode, actionData, (res: LooseObject) => {
      });

      mocker.clear(MmsPreferences.getInstance());
    })

    it('SettingService_getAdvancedPageSwitchValue', 0, () => {
      let mocker: MockKit = new MockKit();
      let getFromPreferences: Function =
        mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences);
      when(getFromPreferences)('isAdvancedMode').afterReturn(true);
      when(getFromPreferences)(common.STR.KEY_OF_DELIVERY_REPORT_SWITCH).afterReturn(true);

      MmsSettingService.getAdvancedPageSwitchValue((res: LooseObject) => {
        expect(res.code).assertEqual(0);
      });

      mocker.clear(SharedPreferencesUtils);
    })

    it('SettingService_judgeIsDeliveryReport', 0, () => {
      MmsPreferences.getInstance()
        .setValueForSwitch(common.STR.KEY_OF_DELIVERY_REPORT_SWITCH, common.DELIVERY_REPORTS.DISABLED);

      let result = MmsSettingService.judgeIsDeliveryReport(true);

      expect(result).assertFalse();
    })

    it('SettingService_judgeIsDeliveryReport1', 0, () => {
      MmsPreferences.getInstance()
        .setValueForSwitch(common.STR.KEY_OF_DELIVERY_REPORT_SWITCH, common.DELIVERY_REPORTS.SMS_AND_MMS);

      let result = MmsSettingService.judgeIsDeliveryReport(true);

      expect(result).assertTrue();
    })

    it('SettingService_judgeIsDeliveryReport2', 0, () => {
      MmsPreferences.getInstance()
        .setValueForSwitch(common.STR.KEY_OF_DELIVERY_REPORT_SWITCH, common.DELIVERY_REPORTS.SMS);

      let result = MmsSettingService.judgeIsDeliveryReport(false);

      expect(result).assertTrue();
    })

    it('SettingService_judgeIsDeliveryReport3', 0, () => {
      MmsPreferences.getInstance()
        .setValueForSwitch(common.STR.KEY_OF_DELIVERY_REPORT_SWITCH, common.DELIVERY_REPORTS.MMS);

      let result = MmsSettingService.judgeIsDeliveryReport(true);

      expect(result).assertTrue();
    })

    it('SettingService_setOnSettingValueListener', 0, () => {
      let mocker: MockKit = new MockKit();
      let getFromPreferences: Function =
        mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences);
      when(getFromPreferences)('isAdvancedMode').afterReturn(true);
      when(getFromPreferences)(common.STR.KEY_OF_INTEGRATION_SWITCH).afterReturn('1');
      when(getFromPreferences)(common.STR.KEY_OF_SHOW_CONTACT_SWITCH).afterReturn('1');

      MmsSettingService.setOnSettingValueListener((res: Record<string, boolean>) => {
        expect(res.integrationSwitch).assertTrue();
      });
      mocker.clear(SharedPreferencesUtils);
    })

    it('SettingService_setOnSettingValueListener1', 0, () => {
      let mocker: MockKit = new MockKit();
      let getFromPreferences: Function =
        mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences);
      when(getFromPreferences)('isAdvancedMode').afterReturn(true);
      when(getFromPreferences)(common.STR.KEY_OF_INTEGRATION_SWITCH).afterReturn('');
      when(getFromPreferences)(common.STR.KEY_OF_SHOW_CONTACT_SWITCH).afterReturn('');

      MmsSettingService.setOnSettingValueListener((res: Record<string, boolean>) => {
        expect(res.integrationSwitch).assertTrue();
      });
      mocker.clear(SharedPreferencesUtils);
    })

    it('SettingService_setOnSettingValueListener2', 0, () => {
      let mocker: MockKit = new MockKit();
      let getFromPreferences: Function =
        mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences);
      when(getFromPreferences)('isAdvancedMode').afterReturn(true);
      when(getFromPreferences)(common.STR.KEY_OF_INTEGRATION_SWITCH).afterReturn('0');
      when(getFromPreferences)(common.STR.KEY_OF_SHOW_CONTACT_SWITCH).afterReturn('0');

      MmsSettingService.setOnSettingValueListener((res: Record<string, boolean>) => {
        expect(res.integrationSwitch).assertFalse();
      });
      mocker.clear(SharedPreferencesUtils);
    })

    it('SettingService_shareSmsEnterSelectedText', 0, () => {
      let actionData: LooseObject = {
        "index": 1,
        "number": 10086
      };
      MmsSettingService.shareSmsEnterSelectedText(actionData);
      expect(actionData.index).assertEqual(1);
    })

    it('SettingService_getSettingFlagForConvListPage', 0, () => {
      let mocker: MockKit = new MockKit();
      let getFromPreferences: Function =
        mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences);
      when(getFromPreferences)('isAdvancedMode').afterReturn(true);
      when(getFromPreferences)(common.STR.KEY_OF_INTEGRATION_SWITCH).afterReturn('1');
      when(getFromPreferences)(common.STR.KEY_OF_SHOW_CONTACT_SWITCH).afterReturn('1');

      let res = MmsSettingService.getSettingFlagForConvListPage();
      expect(res.isShowContactHeadIcon).assertTrue();

      mocker.clear(SharedPreferencesUtils);
    })

    it('SettingService_getSettingFlagForConvListPage1', 0, () => {
      let mocker: MockKit = new MockKit();
      let getFromPreferences: Function =
        mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences);
      when(getFromPreferences)(common.STR.KEY_OF_INTEGRATION_SWITCH).afterReturn('');
      when(getFromPreferences)(common.STR.KEY_OF_SHOW_CONTACT_SWITCH).afterReturn('');

      let res = MmsSettingService.getSettingFlagForConvListPage();
      expect(res.isShowContactHeadIcon).assertTrue();

      mocker.clear(SharedPreferencesUtils);
    })

    it('SettingService_getSettingFlagForConvListPage2', 0, () => {
      let mocker: MockKit = new MockKit();
      let getFromPreferences: Function =
        mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences);
      when(getFromPreferences)('isAdvancedMode').afterReturn(true);
      when(getFromPreferences)(common.STR.KEY_OF_INTEGRATION_SWITCH).afterReturn('0');
      when(getFromPreferences)(common.STR.KEY_OF_SHOW_CONTACT_SWITCH).afterReturn('0');

      let res = MmsSettingService.getSettingFlagForConvListPage();
      expect(res.isShowContactHeadIcon).assertFalse();

      mocker.clear(SharedPreferencesUtils);
    })

    it('SettingService_calculateChecked', 0, () => {
      let simMessageList: Array<LooseObject> = [];
      let message1: LooseObject = {
        'isCbChecked': true,
        'number': 10086
      };
      simMessageList.push(message1);
      let res = MmsSettingService.calculateChecked(simMessageList, true);
      expect(res.count).assertEqual(1);
    })
  })
}