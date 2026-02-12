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
import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect } from '@ohos/hypium'
import DataService from '../../../../main/ets/service/DataService'

export default function DataServiceTest() {
  describe('DataServiceTest', () => {
    // Defines a test suite. Two parameters are supported: test suite name and test suite function.
    it('DataServiceTest_getDefaultCellularDataSlotId_fail', 0, () => {
      DataService.getDefaultCellularDataSlotId().then((slotId) => {
        expect(slotId).assertEqual(1);
      });
    })
    it('DataServiceTest_getDefaultCellularDataSlotId_one', 0, () => {
      DataService.getDefaultCellularDataSlotId().then((slotId) => {
        expect(slotId).assertEqual(1);
      });

    })
    it('DataServiceTest_getDefaultCellularDataSlotId_two', 0, () => {
      DataService.getDefaultCellularDataSlotId().then((slotId) => {
        expect(slotId).assertEqual(1);
      });
    })
  })
}