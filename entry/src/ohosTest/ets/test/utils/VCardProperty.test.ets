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
import { VCardProperty } from '../../../../main/ets/utils/VCardParser';

export default function VCardPropertyTest() {
  let vCardProperty = new VCardProperty();
  describe('VCardPropertyTest', () => {
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

    it('VCardPropertyTest_setName', 0, () => {
      vCardProperty.setName('VCardPropertyTest_setName');
      let name = vCardProperty.getName();
      expect(name).assertEqual('VCardPropertyTest_setName');
    })

    it('VCardPropertyTest_setName_not_null', 0, () => {
      vCardProperty.setName('VCardPropertyTest_setName');
      vCardProperty.setName('VCardPropertyTest_setName_TWO');
      let name = vCardProperty.getName();
      expect(name).assertEqual('VCardPropertyTest_setName_TWO');
    })

    it('VCardPropertyTest_addGroup', 0, () => {
      (vCardProperty as object)['mGroupList'] = null;
      vCardProperty.addGroup('VCardPropertyTest_addGroup');
      vCardProperty.addGroup('VCardPropertyTest_addGroup');
      let mGroupList = (vCardProperty as object)['mGroupList'] as Array<string>;
      expect(mGroupList.length).assertLarger(0);
    })

    it('VCardPropertyTest_addParameter_map', 0, () => {
      vCardProperty.addParameter('paramName', 'paramValue');
      let vCardPropertys = (vCardProperty as object)['mParameterMap'] as Map<string, Array<string> | Set<string>>;
      expect(vCardPropertys.size).assertLarger(0);
    })

    it('VCardPropertyTest_addParameter_map_push', 0, () => {
      vCardProperty.addParameter('paramName1', 'paramValue1');
      vCardProperty.addParameter('paramName1', 'paramValue2');
      let vCardPropertys = (vCardProperty as object)['mParameterMap'] as Map<string, Array<string> | Set<string>>;
      expect(vCardPropertys.size).assertLarger(0);
    })

    it('VCardPropertyTest_addParameter_set', 0, () => {
      vCardProperty.addParameter('TYPE', 'net');
      let vCardPropertys = (vCardProperty as object)['mParameterMap'] as Map<string, Array<string> | Set<string>>;
      expect(vCardPropertys.size).assertLarger(0);
    })

    it('VCardPropertyTest_setRawValue', 0, () => {
      vCardProperty.setRawValue('VCardPropertyTest_setRawValue');
      let rawValue = vCardProperty.getRawValue();
      expect(rawValue).assertEqual('VCardPropertyTest_setRawValue');
    })

    it('VCardPropertyTest_getName', 0, () => {
      vCardProperty.setName('VCardPropertyTest_getName');
      let name = vCardProperty.getName();
      expect(name).assertEqual('VCardPropertyTest_getName');
    })

    it('VCardPropertyTest_getRawValue', 0, () => {
      vCardProperty.setRawValue('VCardPropertyTest_getRawValue');
      let rawValue = vCardProperty.getRawValue();
      expect(rawValue).assertEqual('VCardPropertyTest_getRawValue');
    })
  })
}