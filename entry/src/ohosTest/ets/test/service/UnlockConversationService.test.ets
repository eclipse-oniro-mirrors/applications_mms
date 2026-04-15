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
import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect, MockKit, when,
  ArgumentMatchers } from '@ohos/hypium'
import { GlobalContext } from '../../../../main/ets/MainAbility/GlobalHelper'
import UnlockConversationModel from '../../../../main/ets/model/UnlockConversationModel'
import UnlockConversationService from '../../../../main/ets/service/UnlockConversationService'
import WorkerWrapper from '../../../../main/ets/workers/base/WorkerWrapper'
import { DTGlobalContext } from '../../testability/TestAbility'

export default function UnlockConversationServiceTest() {
  describe('UnlockConversationServiceTest', () => {
    // Defines a test suite. Two parameters are supported: test suite name and test suite function.
    beforeAll(() => {
      // Presets an action, which is performed only once before all test cases of the test suite start.
      // This API supports only one parameter: preset action function.
    })
    beforeEach(() => {
      // Presets an action, which is performed before each unit test case starts.
      // The number of execution times is the same as the number of test cases defined by **it**.
      // This API supports only one parameter: preset action function.
    })
    afterEach(() => {
      // Presets a clear action, which is performed after each unit test case ends.
      // The number of execution times is the same as the number of test cases defined by **it**.
      // This API supports only one parameter: clear action function.
    })
    afterAll(() => {
      // Presets a clear action, which is performed after all test cases of the test suite end.
      // This API supports only one parameter: clear action function.
    })
    it('UnlockConversationService_getInstance', 0, () => {
      // Defines a test case. This API supports three parameters: test case name, filter parameter, and test case function.
      let a: UnlockConversationService = UnlockConversationService.getInstance()
      let b: UnlockConversationService = UnlockConversationService.getInstance()
      // Defines a variety of assertion methods, which are used to declare expected boolean conditions.
      expect(a).assertEqual(b)
    })
    it('UnlockConversationService_is_not_null', 0, async () => {
      let mocker: MockKit = new MockKit();
      let unlockConversationModel: UnlockConversationModel = new UnlockConversationModel();
      let mockFunction: Function =mocker.mockFunc(unlockConversationModel, unlockConversationModel.statisticalData);
      when(mockFunction)(ArgumentMatchers.any).afterReturnNothing();
      expect(unlockConversationModel).not().assertUndefined();
      mocker.ignoreMock(unlockConversationModel, unlockConversationModel.statisticalData);
    });

    it('UnlockConversationService_is_null', 0, async () => {
      let mocker: MockKit = new MockKit();
      let unlockConversationModel: UnlockConversationModel = new UnlockConversationModel();
      let mockFunction: Function =mocker.mockFunc(unlockConversationModel, unlockConversationModel.statisticalData);
      when(mockFunction)(ArgumentMatchers.any).afterReturnNothing();
      expect(unlockConversationModel).not().assertUndefined();
      mocker.ignoreMock(unlockConversationModel, unlockConversationModel.statisticalData);
    });
  })
}