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
import el1PreferencesHelper from '../../../../main/ets/utils/el1PreferencesHelper';
import { preferences } from '@kit.ArkData';

export default function el1PreferencesHelperTest() {
  describe('el1PreferencesHelperTest', () => {
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

    it('el1PreferencesHelperTest_set', 0, () => {
      el1PreferencesHelper.set('test', 1);
      (el1PreferencesHelper as object)['dataPreferences'] = {
        putSync: (key: string, value: preferences.ValueType): void => {},
        getSync: (key: string, defValue: preferences.ValueType): preferences.ValueType => {
          return 1;
      }
      } as preferences.Preferences;
      expect(el1PreferencesHelper.get('test', 6)).assertEqual(1);
    })

    it('el1PreferencesHelperTest_get_defValue', 0, () => {
      (el1PreferencesHelper as object)['dataPreferences'] = undefined;
      el1PreferencesHelper.set('test', 1);
      expect(el1PreferencesHelper.get('test', 6)).assertEqual(6);
    })
  })
}