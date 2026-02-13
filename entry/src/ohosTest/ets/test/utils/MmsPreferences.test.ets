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
import {
  describe,
  beforeEach,
  afterEach,
  it,
  expect,
  MockKit,
  when,
  ArgumentMatchers
} from '@ohos/hypium';
import MmsPreferences from '../../../../main/ets/utils/MmsPreferences';
import SharedPreferencesUtils from '../../../../main/ets/utils/SharedPreferencesUtils';
import common from '../../../../main/ets/data/commonData';

export default function mmsPreferencesTest() {
  describe('mmsPreferencesTest', () => {
    let mmsPreferences = MmsPreferences.getInstance();
    let mocker: MockKit;

    beforeEach(() => {
      mocker = new MockKit();
    })
    afterEach(() => {
      mocker.clear(mmsPreferences);
      AppStorage.clear();
    })

    it('MmsPreferencesTest_initPreferences', 0, async () => {
      mocker.mockFunc(mmsPreferences, mmsPreferences.initMapData);
      await mmsPreferences.initPreferences();
      mocker.verify('initMapData', []).once();
    })

    it('MmsPreferencesTest_initMapData', 0, () => {
      mocker.mockFunc(mmsPreferences, mmsPreferences.asyncGetValueFromPreferences);
      mmsPreferences.initMapData()
      mocker.verify('asyncGetValueFromPreferences', ['integrationSwitch']).once();
    })

    it('MmsPreferencesTest_getValueFromPreferences', 0, async () => {
      when(mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences))('key')
        .afterReturn(true);
      expect(await mmsPreferences.getValueFromPreferences('key')).assertTrue();
      mocker.clear(SharedPreferencesUtils);
    })

    it('MmsPreferencesTest_asyncGetValueFromPreferences', 0, async () => {
      when(mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences))('key')
        .afterReturn(1);
      mocker.mockFunc(mmsPreferences, mmsPreferences.setValueToMap);
      expect(await mmsPreferences.asyncGetValueFromPreferences('key')).assertEqual('1');
      mocker.clear(SharedPreferencesUtils);
    })

    it('MmsPreferencesTest_getValueOfIntegrationSwitch', 0, () => {
      when(mocker.mockFunc(mmsPreferences, mmsPreferences.getValueFromMap))('integrationSwitch')
        .afterReturn('1');
      expect(mmsPreferences.getValueOfIntegrationSwitch()).assertEqual('1')
    })

    it('MmsPreferencesTest_getValueOfShowContactSwitch', 0, () => {
      when(mocker.mockFunc(mmsPreferences, mmsPreferences.getValueFromMap))(ArgumentMatchers.any)
        .afterReturn('1');
      expect(mmsPreferences.getValueOfShowContactSwitch()).assertEqual('1')
    })

    it('MmsPreferencesTest_getValueOfDeliveryReportSwitch', 0, () => {
      when(mocker.mockFunc(mmsPreferences, mmsPreferences.getValueFromMap))(ArgumentMatchers.any)
        .afterReturn('1');
      expect(mmsPreferences.getValueOfDeliveryReportSwitch()).assertEqual('1')
    })
    it('MmsPreferencesTest_setShowDelDialog', 0, () => {
      mocker.mockFunc(mmsPreferences, mmsPreferences.setValueForSwitch);
      mmsPreferences.setShowDelDialog('')
      mocker.verify('setValueForSwitch', ['is_show_del_dialog', '']).once();
    })

    it('MmsPreferencesTest_getShowDelDialog', 0, () => {
      mocker.mockFunc(mmsPreferences, mmsPreferences.getValueFromMap);
      mmsPreferences.getShowDelDialog()
      mocker.verify('getValueFromMap', [common.STR.KEY_OF_SHOW_DEL_DIALOG, common.bool.TRUE]).once();
    })

    it('MmsPreferencesTest_isMultiSimCardEnabled_true', 0, () => {
      when(mocker.mockFunc(mmsPreferences, mmsPreferences.getMaxSimCount))(ArgumentMatchers.any)
        .afterReturn(common.int.SIM_COUNT);
      expect(mmsPreferences.isMultiSimCardEnabled()).assertTrue();
    })

    it('MmsPreferencesTest_isMultiSimCardEnabled_false', 0, () => {
      when(mocker.mockFunc(mmsPreferences, mmsPreferences.getMaxSimCount))(ArgumentMatchers.any)
        .afterReturn(0);
      expect(mmsPreferences.isMultiSimCardEnabled()).assertFalse();
    })

    it('MmsPreferencesTest_getTimeOfLastDeleteNotifyMms', 0, () => {
      when(mocker.mockFunc(mmsPreferences, mmsPreferences.getValueFromMap))(ArgumentMatchers.any)
        .afterReturn('1');
      expect(mmsPreferences.getTimeOfLastDeleteNotifyMms()).assertEqual('1')
    })

    it('MmsPreferencesTest_getMaxSimCount', 0, () => {
      when(mocker.mockFunc(mmsPreferences, mmsPreferences.getValueFromMap))(ArgumentMatchers.any)
        .afterReturn('1');
      expect(mmsPreferences.getMaxSimCount()).assertEqual('1')
    })

    it('MmsPreferencesTest_haveMultiSimCardReady', 0, () => {
      when(mocker.mockFunc(mmsPreferences, mmsPreferences.getValueFromMap))(ArgumentMatchers.any)
        .afterReturn('1');
      expect(mmsPreferences.haveMultiSimCardReady()).assertEqual('1')
    })

    it('MmsPreferencesTest_haveSimCardReady', 0, () => {
      when(mocker.mockFunc(mmsPreferences, mmsPreferences.getValueFromMap))(ArgumentMatchers.any)
        .afterReturn('1');
      expect(mmsPreferences.haveSimCardReady()).assertEqual('1')
    })

    it('MmsPreferencesTest_getSpnOfSim1', 0, () => {
      when(mocker.mockFunc(mmsPreferences, mmsPreferences.getValueFromMap))(ArgumentMatchers.any)
        .afterReturn('1');
      expect(mmsPreferences.getSpnOfSim1()).assertEqual('1')
    })

    it('MmsPreferencesTest_getSpnOfSim2', 0, () => {
      when(mocker.mockFunc(mmsPreferences, mmsPreferences.getValueFromMap))(ArgumentMatchers.any)
        .afterReturn('1');
      expect(mmsPreferences.getSpnOfSim2()).assertEqual('1')
    })

    it('MmsPreferencesTest_getDispalyNameOfSim1_true_empty', 0, () => {
      mmsPreferences.setValueToMap(common.STR.KEY_OF_SIM_0_ShowName, '');
      when(mocker.mockFunc(mmsPreferences, mmsPreferences.getSpnOfSim1))(ArgumentMatchers.any)
        .afterReturn('0');
      expect(mmsPreferences.getDispalyNameOfSim1()).assertEqual('0');
      mmsPreferences.removeFromMap(common.STR.KEY_OF_SIM_0_ShowName);
    })

    it('MmsPreferencesTest_getDispalyNameOfSim1_true_notEmpty', 0, () => {
      mmsPreferences.setValueToMap(common.STR.KEY_OF_SIM_0_ShowName, 'xx');
      when(mocker.mockFunc(mmsPreferences, mmsPreferences.getSpnOfSim1))(ArgumentMatchers.any)
        .afterReturn('0');
      expect(mmsPreferences.getDispalyNameOfSim1()).assertEqual('xx');
      mmsPreferences.removeFromMap(common.STR.KEY_OF_SIM_0_ShowName);
    })

    it('MmsPreferencesTest_getDispalyNameOfSim2_true_notEmpty', 0, () => {
      mmsPreferences.setValueToMap(common.STR.KEY_OF_SIM_1_ShowName, 'xx');
      expect(mmsPreferences.getDispalyNameOfSim2()).assertEqual('xx');
      mmsPreferences.removeFromMap(common.STR.KEY_OF_SIM_1_ShowName);
    })

    it('MmsPreferencesTest_getDispalyNameOfSim2_true_empty', 0, () => {
      mmsPreferences.setValueToMap(common.STR.KEY_OF_SIM_1_ShowName, '');
      when(mocker.mockFunc(mmsPreferences, mmsPreferences.getSpnOfSim2))(ArgumentMatchers.any)
        .afterReturn('0');
      expect(mmsPreferences.getDispalyNameOfSim2()).assertEqual('0');
      mmsPreferences.removeFromMap(common.STR.KEY_OF_SIM_1_ShowName);
    })

    it('MmsPreferencesTest_getNewSmscOfSim1', 0, () => {
      when(mocker.mockFunc(mmsPreferences, mmsPreferences.getValueFromMap))(ArgumentMatchers.any)
        .afterReturn('1');
      expect(mmsPreferences.getNewSmscOfSim1()).assertEqual('1')
    })

    it('MmsPreferencesTest_getNewSmscOfSim2', 0, () => {
      when(mocker.mockFunc(mmsPreferences, mmsPreferences.getValueFromMap))(ArgumentMatchers.any)
        .afterReturn('1');
      expect(mmsPreferences.getNewSmscOfSim2()).assertEqual('1')
    })

    it('MmsPreferencesTest_getTelephoneNumberOfSim1', 0, () => {
      when(mocker.mockFunc(mmsPreferences, mmsPreferences.getValueFromMap))(ArgumentMatchers.any)
        .afterReturn('1');
      expect(mmsPreferences.getTelephoneNumberOfSim1()).assertEqual('1')
    })

    it('MmsPreferencesTest_getTelephoneNumberOfSim2', 0, () => {
      when(mocker.mockFunc(mmsPreferences, mmsPreferences.getValueFromMap))(ArgumentMatchers.any)
        .afterReturn('1');
      expect(mmsPreferences.getTelephoneNumberOfSim2()).assertEqual('1')
    })

    it('MmsPreferencesTest_getSelectedSlotId', 0, () => {
      when(mocker.mockFunc(mmsPreferences, mmsPreferences.getValueFromMap))(ArgumentMatchers.any)
        .afterReturn('1');
      expect(mmsPreferences.getSelectedSlotId()).assertEqual('1')
    })

    it('MmsPreferencesTest_setTimeOfLastDeleteNotifyMms', 0, () => {
      mocker.mockFunc(mmsPreferences, mmsPreferences.setValueForSwitch);
      mmsPreferences.setTimeOfLastDeleteNotifyMms(0);
      mocker.verify('setValueForSwitch', [common.STR.TIME_OF_LAST_DELETE_NOTIFY_MMS, '0']).once();
    })

    it('MmsPreferencesTest_getSendMessageSlotId_true', 0, () => {
      when(mocker.mockFunc(mmsPreferences, mmsPreferences.haveMultiSimCardReady))()
        .afterReturn(true);
      when(mocker.mockFunc(mmsPreferences, mmsPreferences.getSelectedSlotId))()
        .afterReturn(1);
      expect(mmsPreferences.getSendMessageSlotId()).assertEqual(1);
    })

    it('MmsPreferencesTest_getSendMessageSlotId_false', 0, () => {
      when(mocker.mockFunc(mmsPreferences, mmsPreferences.haveMultiSimCardReady))()
        .afterReturn(false);
      when(mocker.mockFunc(mmsPreferences, mmsPreferences.getDefaultSlotId))()
        .afterReturn(1);
      expect(mmsPreferences.getSendMessageSlotId()).assertEqual(1);
    })

    it('MmsPreferencesTest_getSendMessageSlotIdOfRcs_true', 0, () => {
      when(mocker.mockFunc(mmsPreferences, mmsPreferences.haveMultiSimCardReady))()
        .afterReturn(true);
      expect(mmsPreferences.getSendMessageSlotIdOfRcs()).assertEqual(common.int.SIM_ONE);
    })

    it('MmsPreferencesTest_getSendMessageSlotIdOfRcs_true_appstorage', 0, () => {
      AppStorage.setOrCreate('simSlotId', 0);
      when(mocker.mockFunc(mmsPreferences, mmsPreferences.haveMultiSimCardReady))()
        .afterReturn(true);
      expect(mmsPreferences.getSendMessageSlotIdOfRcs()).assertEqual(0);
    })

    it('MmsPreferencesTest_getSendMessageSlotIdOfRcs_false', 0, () => {
      when(mocker.mockFunc(mmsPreferences, mmsPreferences.haveMultiSimCardReady))()
        .afterReturn(false);
      when(mocker.mockFunc(mmsPreferences, mmsPreferences.getDefaultSlotId))()
        .afterReturn(1);
      expect(mmsPreferences.getSendMessageSlotIdOfRcs()).assertEqual(1);
    })

    it('MmsPreferencesTest_setValueForSwitch', 0, () => {
      mocker.mockFunc(mmsPreferences, mmsPreferences.setValueToMap);
      mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.saveToPreferences);
      mmsPreferences.setValueForSwitch('', '');
      mocker.verify('setValueToMap', ['', '']).once();
      mocker.clear(SharedPreferencesUtils);
      mmsPreferences.removeFromMap('');
    })

    it('MmsPreferencesTest_getValueFromMap_hasValue', 0, () => {
      mmsPreferences.setValueToMap('key','value');
      expect(mmsPreferences.getValueFromMap('key', '')).assertEqual('value');
      mmsPreferences.removeFromMap('key');
    })

    it('MmsPreferencesTest_getValueFromMap_valueUndefined', 0, () => {
      when(mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences))(ArgumentMatchers.any)
        .afterReturn('');
      expect(mmsPreferences.getValueFromMap('key', '')).assertEqual('');
      mocker.clear(SharedPreferencesUtils);
    })

    it('MmsPreferencesTest_hasKeyFromMap', 0, () => {
      mmsPreferences.removeFromMap('key');
      expect(mmsPreferences.hasKeyFromMap('key')).assertFalse();
    })

    it('MmsPreferencesTest_removeFromMap', 0, () => {
      mmsPreferences.setValueToMap('key','value');
      expect(mmsPreferences.removeFromMap('key')).assertTrue();
      mmsPreferences.removeFromMap('key');
    })
  })
}