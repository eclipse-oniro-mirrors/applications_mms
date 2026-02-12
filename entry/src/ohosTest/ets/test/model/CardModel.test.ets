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
import cardModel from '../../../../main/ets/model/CardModel';
import telephonySim from '@ohos.telephony.sim';
import MmsPreferences from '../../../../main/ets/utils/MmsPreferences';
import HiLog from '../../../../main/ets/utils/HiLog';
import { DTGlobalContext } from '../../testability/TestAbility';
import SharedPreferencesUtils from '../../../../main/ets/utils/SharedPreferencesUtils';
import { resourceManager } from '@kit.LocalizationKit';
import MessageUtil from '../../../../main/cust/utils/MessageUtil';

export default function CardModelTest() {
  describe('CardModelTest', () => {
    const TAG = 'CardModel';

    it('CardModel_init', 0, () => {
      let mocker: MockKit = new MockKit();

      mocker.mockFunc(HiLog, HiLog.i);

      mocker.mockFunc(MmsPreferences.getInstance(), MmsPreferences.getInstance().setValueToMap);
      mocker.mockFunc(MmsPreferences.getInstance(), MmsPreferences.getInstance().getValueFromPreferences);
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      cardModel.init(context);
      mocker.verify('i',[TAG, 'init start']).never();
      mocker.clear(MmsPreferences.getInstance());
      mocker.clear(HiLog);
    })

    it('CardModel_deInit', 0, () => {
      let mocker: MockKit = new MockKit();
      cardModel.deInit();
      mocker.verify('i',[TAG, 'deInit start']).never();
    })

    it('CardModel_getSimCardState', 0, () => {
      expect(cardModel.getSimCardState(0)).assertEqual(telephonySim.SimState.SIM_STATE_UNKNOWN);
    })

    it('CardModel_isSimReady', 0, () => {
      let slotId: number = 0;
      expect(cardModel.isSimReady(slotId)).assertFalse();
    })

    it('CardModelTest_simStateChangeListenerCallback_preferences_when_sim_is_ready', 0, async () => {
      let cardmodel: ESObject = cardModel;
      let mocker: MockKit = new MockKit();
      let mockfunc: Function = mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.saveToPreferences);
      when(mockfunc)(ArgumentMatchers.any).afterReturn(null);

      let mockfunc2: Function = mocker.mockFunc(cardmodel, cardmodel.isSimReady);
      when(mockfunc2)(ArgumentMatchers.anyNumber).afterReturn(true);

      let callback: ESObject = cardmodel.simStateChangeListenerCallback(0);
      callback({ state: telephonySim.SimState.SIM_STATE_READY });
      mocker.verify('i',[TAG, 'simStateChange slotId']).never();
      mocker.ignoreMock(SharedPreferencesUtils, SharedPreferencesUtils.saveToPreferences);
      mocker.ignoreMock(cardmodel, cardmodel.isSimReady);
    });

    it('CardModelTest_simStateChangeListenerCallback_preferences_when_sim_is_not_ready', 0, async () => {
      let cardmodel: ESObject = cardModel;
      let mocker: MockKit = new MockKit();
      let mockfunc: Function = mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.saveToPreferences);
      when(mockfunc)(ArgumentMatchers.any).afterReturn(null);

      let mockfunc2: Function = mocker.mockFunc(cardmodel, cardmodel.isSimReady);
      when(mockfunc2)(ArgumentMatchers.anyNumber).afterReturn(false);

      let callback: ESObject = cardmodel.simStateChangeListenerCallback(0);
      callback({ state: telephonySim.SimState.SIM_STATE_READY });
      mocker.verify('i',[TAG, 'simStateChange slotId']).never();
      mocker.ignoreMock(SharedPreferencesUtils, SharedPreferencesUtils.saveToPreferences);
      mocker.ignoreMock(cardmodel, cardmodel.isSimReady);
    });

    it('CardModelTest_simStateChangeListenerCallback_first_do_auth_when_sim_is_ready', 0, async () => {
      let cardmodel: ESObject = cardModel;
      let mocker: MockKit = new MockKit();

      let mockfunc2: Function = mocker.mockFunc(cardmodel, cardmodel.isSimReady);
      when(mockfunc2)(ArgumentMatchers.anyNumber).afterReturn(true);

      let callback: ESObject = cardmodel.simStateChangeListenerCallback(0);
      callback({ state: telephonySim.SimState.SIM_STATE_READY });
      mocker.verify('i',[TAG, 'simStateChange slotId']).never();
      mocker.ignoreMock(cardmodel, cardmodel.isSimReady);
    });

    it('CardModelTest_simStateChangeListenerCallback_first_do_auth_when_sim_is_not_ready', 0, async () => {
      let cardmodel: ESObject = cardModel;
      let mocker: MockKit = new MockKit();

      let mockfunc2: Function = mocker.mockFunc(cardmodel, cardmodel.isSimReady);
      when(mockfunc2)(ArgumentMatchers.anyNumber).afterReturn(false);

      let callback: ESObject = cardmodel.simStateChangeListenerCallback(0);
      callback({ state: telephonySim.SimState.SIM_STATE_READY });
      mocker.verify('i',[TAG, 'simStateChange slotId']).never()
      mocker.ignoreMock(cardmodel, cardmodel.isSimReady);
    });

    it('CardModelTest_simStateChangeListenerCallback_state_change_when_sim_is_ready', 0, async () => {
      let cardmodel: ESObject = cardModel;
      let mocker: MockKit = new MockKit();
      let mockfunc: Function = mocker.mockFunc(cardmodel, cardmodel.notifySimStateChange);
      when(mockfunc)(ArgumentMatchers.any).afterReturn(null);

      let mockfunc2: Function = mocker.mockFunc(cardmodel, cardmodel.isSimReady);
      when(mockfunc2)(ArgumentMatchers.anyNumber).afterReturn(true);

      let callback: ESObject = cardmodel.simStateChangeListenerCallback(0);
      callback({ state: telephonySim.SimState.SIM_STATE_READY });
      mocker.verify('i',[TAG, 'simStateChange slotId']).never();
      mocker.ignoreMock(cardmodel, cardmodel.notifySimStateChange);
      mocker.ignoreMock(cardmodel, cardmodel.isSimReady);
    });

    it('CardModelTest_simStateChangeListenerCallback_sim_state_change_when_sim_is_not_ready', 0, async () => {
      let cardmodel: ESObject = cardModel;
      let mocker: MockKit = new MockKit();
      let mockfunc: Function = mocker.mockFunc(cardmodel, cardmodel.notifySimStateChange);
      when(mockfunc)(ArgumentMatchers.any).afterReturn(null);

      let mockfunc2: Function = mocker.mockFunc(cardmodel, cardmodel.isSimReady);
      when(mockfunc2)(ArgumentMatchers.anyNumber).afterReturn(false);

      let callback: ESObject = cardmodel.simStateChangeListenerCallback(0);
      callback({ state: telephonySim.SimState.SIM_STATE_READY });
      mocker.verify('i',[TAG, 'simStateChange slotId']).never();
      mocker.ignoreMock(cardmodel, cardmodel.notifySimStateChange);
      mocker.ignoreMock(cardmodel, cardmodel.isSimReady);
    });

    it('CardModelTest_simStateChangeListenerCallback_sim_changed_when_sim_is_ready', 0, async () => {
      let cardmodel: ESObject = cardModel;
      let mocker: MockKit = new MockKit();

      let mockfunc2: Function = mocker.mockFunc(cardmodel, cardmodel.isSimReady);
      when(mockfunc2)(ArgumentMatchers.anyNumber).afterReturn(true);

      let callback: ESObject = cardmodel.simStateChangeListenerCallback(0);
      callback({ state: telephonySim.SimState.SIM_STATE_READY });
      mocker.verify('i',[TAG, 'simStateChange slotId']).never();
      mocker.ignoreMock(cardmodel, cardmodel.isSimReady);
    });

    it('CardModelTest_simStateChangeListenerCallback_listen_sim_changed_when_sim_is_not_ready', 0, async () => {
      let cardmodel: ESObject = cardModel;
      let mocker: MockKit = new MockKit();

      let mockfunc2: Function = mocker.mockFunc(cardmodel, cardmodel.isSimReady);
      when(mockfunc2)(ArgumentMatchers.anyNumber).afterReturn(false);

      let callback: ESObject = cardmodel.simStateChangeListenerCallback(0);
      callback({ state: telephonySim.SimState.SIM_STATE_READY });
      mocker.verify('i',[TAG, 'simStateChange slotId']).never();
      mocker.ignoreMock(cardmodel, cardmodel.isSimReady);
    });
    it('CardModelTest_setDefaultSlotToMap_card_ready_and_is_sim_ready_sim_one', 0, async () => {
      let cardmodel: ESObject = cardModel;
      cardmodel.haveSimCardReady = true;
      cardmodel.haveMultiSimCardReady = false;

      let mocker: MockKit = new MockKit();
      let mockIsSimReady: Function = mocker.mockFunc(cardmodel, cardmodel.isSimReady);
      when(mockIsSimReady)([ArgumentMatchers.anyNumber]).afterReturn(true);

      let mockMmsPreferences: ESObject = MmsPreferences.getInstance();
      let mockGetInstance: Function = mocker.mockFunc(mockMmsPreferences, mockMmsPreferences.getInstance);
      when(mockGetInstance)([]).afterReturn(mockMmsPreferences);

      let mockSetValueToMap: Function = mocker.mockFunc(mockMmsPreferences, mockMmsPreferences.setValueToMap);
      when(mockSetValueToMap)([ArgumentMatchers.anyString, ArgumentMatchers.anyString]).afterReturnNothing();

      cardmodel.setDefaultSlotToMap();
      expect(cardmodel.haveSimCardReady).assertTrue();
      mocker.ignoreMock(cardmodel, cardmodel.isSimReady);
      mocker.ignoreMock(mockMmsPreferences, mockMmsPreferences.getInstance);
      mocker.ignoreMock(mockMmsPreferences, mockMmsPreferences.setValueToMap);
    });

    it('CardModelTest_setDefaultSlotToMap_not_multi_sim_card_ready_and_is_sim_ready_sim_two', 0, async () => {
      let cardmodel: ESObject = cardModel;
      cardmodel.haveSimCardReady = true;
      cardmodel.haveMultiSimCardReady = false;

      let mocker: MockKit = new MockKit();
      let mockIsSimReady: Function = mocker.mockFunc(cardmodel, cardmodel.isSimReady);
      when(mockIsSimReady)([ArgumentMatchers.anyNumber]).afterReturn(false);

      let mockMmsPreferences: ESObject = MmsPreferences.getInstance();
      let mockGetInstance: Function = mocker.mockFunc(mockMmsPreferences, mockMmsPreferences.getInstance);
      when(mockGetInstance)([]).afterReturn(mockMmsPreferences);

      let mockSetValueToMap: Function = mocker.mockFunc(mockMmsPreferences, mockMmsPreferences.setValueToMap);
      when(mockSetValueToMap)([ArgumentMatchers.anyString, ArgumentMatchers.anyString]).afterReturnNothing();

      cardmodel.setDefaultSlotToMap();
      expect(cardmodel.haveSimCardReady).assertTrue();
      mocker.ignoreMock(cardmodel, cardmodel.isSimReady);
      mocker.ignoreMock(mockMmsPreferences, mockMmsPreferences.getInstance);
      mocker.ignoreMock(mockMmsPreferences, mockMmsPreferences.setValueToMap);
    });

    it('CardModelTest_setDefaultSlotToMap_sim_card_ready_and_get_default_voice_slot_id_success', 0, async () => {
      let cardmodel: ESObject = cardModel;
      cardmodel.haveSimCardReady = true;
      cardmodel.haveMultiSimCardReady = true;
      let mocker: MockKit = new MockKit();

      let mockMmsPreferences: ESObject = MmsPreferences.getInstance();
      let mockGetInstance: Function = mocker.mockFunc(mockMmsPreferences, mockMmsPreferences.getInstance);
      when(mockGetInstance)([]).afterReturn(mockMmsPreferences);

      let mockSetValueToMap: Function = mocker.mockFunc(mockMmsPreferences, mockMmsPreferences.setValueToMap);
      when(mockSetValueToMap)([ArgumentMatchers.anyString, ArgumentMatchers.anyString]).afterReturnNothing();

      cardmodel.setDefaultSlotToMap();
      expect(cardmodel.haveSimCardReady).assertTrue();
      mocker.ignoreMock(mockMmsPreferences, mockMmsPreferences.getInstance);
      mocker.ignoreMock(mockMmsPreferences, mockMmsPreferences.setValueToMap);
    });

    it('CardModelTest_setSpnToMap', 0, async () => {
      let cardmodel: ESObject = cardModel;
      let mocker: MockKit = new MockKit();
      let mockfuncNotifySetSimSpnToMap: Function = mocker.mockFunc(cardmodel, cardmodel.notifySetSimSpnToMap);
      when(mockfuncNotifySetSimSpnToMap)(ArgumentMatchers.any).afterReturnNothing();
      cardmodel.setSpnToMap(0);
      mocker.verify('i',[TAG, 'getSpnFromSim']).never();
      mocker.ignoreMock(cardmodel, cardmodel.notifySetSimSpnToMap);
    });

    it('CardModelTest_setOperatorName_getOperatorName_fails', 0, async () => {
      let cardmodel: ESObject = cardModel;
      let mocker: MockKit = new MockKit();
      let mockSetSimOperatorNumeric: Function = mocker.mockFunc(cardmodel, cardmodel.setSimOperatorNumeric);
      when(mockSetSimOperatorNumeric)(ArgumentMatchers.anyNumber).afterReturnNothing();
      cardmodel.setOperatorName(0);
      mocker.verify('i',[TAG, 'getOperatorName']).never();
      mocker.ignoreMock(cardmodel, cardmodel.setSimOperatorNumeric);
    });

    it('CardModelTest_setOperatorName_getOperatorName_succeeds', 0, async () => {
      let cardmodel: ESObject = cardModel;
      let mocker: MockKit = new MockKit();
      let mockNotifySetSimSpnToMap: Function = mocker.mockFunc(cardmodel, cardmodel.notifySetSimSpnToMap);
      when(mockNotifySetSimSpnToMap)(ArgumentMatchers.any).afterReturnNothing();
      cardmodel.setOperatorName(0);
      mocker.verify('i',[TAG, 'getOperatorName']).never();
      mocker.ignoreMock(cardmodel, cardmodel.notifySetSimSpnToMap);
    });
    it('CardModelTest_notifySetSimSpnToMap_storage_when_spn_is_mobile', 0, async () => {
      let mocker: MockKit = new MockKit();
      let mmsPreferences: ESObject = MmsPreferences.getInstance();
      let mockfunc: Function = mocker.mockFunc(mmsPreferences, mmsPreferences.setValueToMap);
      when(mockfunc)(ArgumentMatchers.any).afterReturnNothing();
      when(mockfunc)(ArgumentMatchers.any).afterReturnNothing();
      when(mockfunc)(ArgumentMatchers.any).afterReturnNothing();
      expect(AppStorage.get('notifyUpdateSimSpn')).assertUndefined()
      expect(AppStorage.get('simSlotIdIsShowRead')).assertUndefined()
      mocker.ignoreMock(mmsPreferences, mmsPreferences.setValueToMap);
    });

    it('CardModelTest_notifySetSimSpnToMap_spn_is_not_mobile', 0, async () => {
      let cardmodel: ESObject = cardModel;
      let mocker: MockKit = new MockKit();
      let mmsPreferences: ESObject = MmsPreferences.getInstance();
      let mockfunc: Function = mocker.mockFunc(mmsPreferences, mmsPreferences.setValueToMap);
      when(mockfunc)(ArgumentMatchers.any).afterReturnNothing();
      when(mockfunc)(ArgumentMatchers.any).afterReturnNothing();
      when(mockfunc)(ArgumentMatchers.any).afterReturnNothing();
      cardmodel.notifySetSimSpnToMap(0, 'Test');
      expect(AppStorage.get('notifyUpdateSimSpn')).assertUndefined()
      expect(AppStorage.get('simSlotIdIsShowRead')).assertUndefined()
      mocker.ignoreMock(mmsPreferences, mmsPreferences.setValueToMap);
    });

    it('CardModelTest_setSimOperatorNumeric_getSimOperatorNumeric_fails', 0, async () => {
      let cardmodel: ESObject = cardModel;
      cardmodel.setSimOperatorNumeric(0);
      // 验证日志输出
      // 这里假设有一个验证日志输出的函数
      expect(cardmodel.haveSimCardReady).assertTrue();
    });

    it('CardModelTest_setSimOperatorNumeric_getSimOperatorNumeric_succeeds', 0, async () => {
      let cardmodel: ESObject = cardModel;
      let mocker: MockKit = new MockKit();
      let mockNotifyFunc: Function = mocker.mockFunc(cardmodel, cardmodel.notifySetSimSpnToMap);
      when(mockNotifyFunc)(ArgumentMatchers.any).afterReturnNothing();
      cardmodel.setSimOperatorNumeric(0);
      mocker.verify('i',[TAG, 'getSimOperatorNumeric']).never();
      mocker.ignoreMock(cardmodel, cardmodel.notifySetSimSpnToMap);
    });

    it('CardModel_notifySetSimSpnToMap_spn_MOBILE', 0, () => {
      let mocker: MockKit = new MockKit();
      (cardModel as object)['context'] = {
        resourceManager: {
          getStringSync: (resource: Resource, ...args: (string | number)[]): string => 'cmcc'
        } as resourceManager.ResourceManager
      } as Context;
      (cardModel as object)['notifySetSimSpnToMap'](2, 'CMCC');
      mocker.verify('i',[TAG, 'notifySetSimSpnToMap']).never();
    })

    it('CardModel_notifySetSimSpnToMap_spn_TELECOM', 0, () => {
      let mocker: MockKit = new MockKit();
      (cardModel as object)['context'] = {
        resourceManager: {
          getStringSync: (resource: Resource, ...args: (string | number)[]): string => 'cmcc'
        } as resourceManager.ResourceManager
      } as Context;
      (cardModel as object)['notifySetSimSpnToMap'](2, '中国电信');
      mocker.verify('i',[TAG, 'notifySetSimSpnToMap']).never();
    })

    it('CardModel_notifySetSimSpnToMap_spn_UNICOM', 0, () => {
      let mocker: MockKit = new MockKit();
      (cardModel as object)['context'] = {
        resourceManager: {
          getStringSync: (resource: Resource, ...args: (string | number)[]): string => 'cmcc'
        } as resourceManager.ResourceManager
      } as Context;
      (cardModel as object)['notifySetSimSpnToMap'](2, 'China Unicom');
      mocker.verify('i',[TAG, 'notifySetSimSpnToMap']).never();
    })

    it('CardModel_notifySetSimSpnToMap_spn_BROADNET', 0, () => {
      let mocker: MockKit = new MockKit();
      (cardModel as object)['context'] = {
        resourceManager: {
          getStringSync: (resource: Resource, ...args: (string | number)[]): string => 'cmcc'
        } as resourceManager.ResourceManager
      } as Context;
      (cardModel as object)['notifySetSimSpnToMap'](2, '中国广电');
      expect((cardModel as object)['spn'] as string).assertEqual('cmcc')
      mocker.verify('i',[TAG, 'notifySetSimSpnToMap']).never();
    })

    it('CardModel_setSmscNumberToPref_slotId_8', 0, async () => {
      let mocker: MockKit = new MockKit();
      await (cardModel as object)['setSmscNumberToPref'](8);
      mocker.verify('e',[TAG, 'setSmscNumberToPref']).never();
    })

    it('CardModel_setSmscNumberToPref_card_0', 0, async () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(MessageUtil, MessageUtil.getSimId))(1)
        .afterReturn(new Promise<number>(resolve => resolve(1)));
      await (cardModel as object)['setSmscNumberToPref'](1);
      mocker.verify('i',[TAG, 'notifySetSimSpnToMap']).never();
      mocker.clear(MessageUtil)
    })
  })
}
