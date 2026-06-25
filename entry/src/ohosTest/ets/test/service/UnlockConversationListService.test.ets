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
import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect, MockKit,
  ArgumentMatchers,
  when} from '@ohos/hypium'
import LooseObject from '../../../../main/ets/data/LooseObject';
import { resType } from '../../../../main/ets/service/MmsSearchService';
import UnlockConversationListService from '../../../../main/ets/service/UnlockConversationListService';
import UnlockConversationService from '../../../../main/ets/service/UnlockConversationService';
import HiLog from '../../../../main/ets/utils/HiLog';
import SharedPreferencesUtils from '../../../../main/ets/utils/SharedPreferencesUtils';
import { DTGlobalContext } from '../../testability/TestAbility';

export default function UnlockConversationListServiceTest() {
  describe('UnlockConversationListServiceTest', () => {
    it('UnlockConversationListServiceTest_instance', 0, () => {
      let instance1: ESObject = UnlockConversationListService.getInstance();
      let instance2: ESObject = UnlockConversationListService.getInstance();
      expect(instance1).assertEqual(instance2);
    });
    it('UnlockConversationListServiceTest_UnlockConversationListService_instance', 0, () => {
      let unlockconversationlistservice: UnlockConversationListService = UnlockConversationListService.getInstance();
      expect(unlockconversationlistservice).assertInstanceOf('Object');
    });

    it('UnlockConversationListServiceTest_UnlockConversationService_instance', 0, () => {
      let unlockconversationservice: UnlockConversationService = new UnlockConversationService();
      expect(unlockconversationservice).assertInstanceOf('Object');
    });

    it('UnlockConversationListServiceTest_HiLog_instance', 0, () => {
      let hilog: HiLog = new HiLog();
      expect(hilog).assertInstanceOf('Object');
    });

    it('UnlockConversationListServiceTest_LooseObject_instance', 0, () => {
      let looseObject: LooseObject = {};
      expect(looseObject).assertInstanceOf('Object');
    });

    it('UnlockConversationListServiceTest_resType_instance', 0, () => {
      let resTypeInstance: resType = {
        code: 0,
        response: {},
        abilityResult: []
      };
      expect(resTypeInstance).assertInstanceOf('Object');
    });

    it('UnlockConversationListServiceTest_SharedPreferencesUtils_instance', 0, () => {
      let sharedPreferencesUtils: ESObject = SharedPreferencesUtils;
      expect(sharedPreferencesUtils).assertInstanceOf('Object');
    });

    it('UnlockConversationListServiceTest_statisticalData_success', 0, async () => {
      let callBack: Function = (res: LooseObject) => {};
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let unlockconversationlistservice: UnlockConversationListService = UnlockConversationListService.getInstance();
      let mocker: MockKit = new MockKit();

      let mockInit: Function = mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.init);
      when(mockInit)(ArgumentMatchers.any).afterReturnNothing();

      let mockSaveToPreferences: Function = mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.saveToPreferences);
      when(mockSaveToPreferences)(ArgumentMatchers.any).afterReturnNothing();
      when(mocker.mockFunc(UnlockConversationService, UnlockConversationService.getInstance))(ArgumentMatchers.any)
        .afterReturn({
          statisticalData: (callback: Function, context: Context) => {
            callback({
              code: 0,
              response: {} as LooseObject,
              abilityResult: [{totalListCount: 1, unreadCount: 1, unreadInfo: 'unreadInfo', unreadTotalOfInfo: 'unreadTotalOfInfo'} as LooseObject],
            })
          }
        });
      unlockconversationlistservice.statisticalData(callBack, context);
      expect(unlockconversationlistservice).not().assertUndefined();
      mocker.clear(SharedPreferencesUtils)
      mocker.clear(UnlockConversationService)
    });

    it('UnlockConversationListServiceTest_statisticalData_fails', 0, async () => {
      let callBack: Function = (res: LooseObject) => {};
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let unlockconversationlistservice: UnlockConversationListService = UnlockConversationListService.getInstance();
      let mocker: MockKit = new MockKit();

      let mockInit: Function = mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.init);
      when(mockInit)(ArgumentMatchers.any).afterReturnNothing();

      let mockSaveToPreferences: Function = mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.saveToPreferences);
      when(mockSaveToPreferences)(ArgumentMatchers.any).afterReturnNothing();
      when(mocker.mockFunc(UnlockConversationService, UnlockConversationService.getInstance))(ArgumentMatchers.any)
        .afterReturn({
          statisticalData: (callback: Function, context: Context) => {
            callback({
              code: -1,
              response: {} as LooseObject,
              abilityResult: [{} as LooseObject],
            })
          }
        });
      unlockconversationlistservice.statisticalData(callBack, context);
      expect(unlockconversationlistservice).not().assertUndefined();
      mocker.clear(SharedPreferencesUtils)
      mocker.clear(UnlockConversationService)
    });
  })
}