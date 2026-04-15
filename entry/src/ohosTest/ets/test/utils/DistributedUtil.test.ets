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
import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect, MockKit, when } from '@ohos/hypium'
import DeviceUtil from '../../../../main/ets/utils/DeviceUtil'
import DistributedUtil from '../../../../main/ets/utils/DistributedUtil'

export default function DistributedUtilTest() {
  describe('DistributedUtilTest', () => {
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
    })

    it('DistrubutedUtilTest_isPC_false', 0, async () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(DeviceUtil, DeviceUtil.isPC))().afterReturn(false);
      let result: boolean =await DistributedUtil.isOsAccountConstraintEnabled()
      mocker.clear(DeviceUtil);
      expect(result).assertFalse();
    })
  })
}
