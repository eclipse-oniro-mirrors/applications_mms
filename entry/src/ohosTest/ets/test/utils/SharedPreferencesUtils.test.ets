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
import { describe, it, expect } from '@ohos/hypium';
import sharedPreferencesUtils from '../../../../main/ets/utils/SharedPreferencesUtils';
import data_preferences from '@ohos.data.preferences';
import { Context } from '@kit.AbilityKit';
import { DTGlobalContext } from '../../testability/TestAbility';
import settings from '@ohos.settings';
import createOrGet from '../../../../main/ets/utils/SingleInstanceUtils';

export default function sharedPreferencesUtilsTest() {
  describe('sharedPreferencesUtilsTest', () => {

    it('sharedPreferencesUtilsTest_getFromPreferences_context_null', 0, () => {
      (sharedPreferencesUtils as object)['context'] = null;
      let res: data_preferences.ValueType = sharedPreferencesUtils.getFromPreferences('key', 1);
      expect(res).assertEqual(1);
    })

    it('sharedPreferencesUtilsTest_getFromPreferencesTaskPool_context_null', 0, () => {
      (sharedPreferencesUtils as object)['context'] = null;
      let res: data_preferences.ValueType = sharedPreferencesUtils.getFromPreferencesTaskPool('key', 1);
      expect(res).assertEqual(1);
    })

    it('sharedPreferencesUtilsTest_saveToPreferences_context_null', 0, () => {
      (sharedPreferencesUtils as object)['context'] = null;
      sharedPreferencesUtils.saveToPreferences('key', 1);
      expect(sharedPreferencesUtils).not().assertUndefined();
    })

    it('sharedPreferencesUtilsTest_saveToPreferencesTaskPool_context_null', 0, () => {
      (sharedPreferencesUtils as object)['context'] = null;
      sharedPreferencesUtils.saveToPreferencesTaskPool('key', 1);
      expect(sharedPreferencesUtils).not().assertUndefined();
    })

    it('sharedPreferencesUtilsTest_deletePreferences', 0, () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      (sharedPreferencesUtils as object)['context'] = context;
      sharedPreferencesUtils.deletePreferences('key');
      expect(sharedPreferencesUtils).not().assertUndefined();
    })

    it('sharedPreferencesUtilsTest_deletePreferences_context_null', 0, () => {
      (sharedPreferencesUtils as object)['context'] = null;
      sharedPreferencesUtils.deletePreferences('key');
      expect(sharedPreferencesUtils).not().assertUndefined();
    })

    it('sharedPreferencesUtilsTest_deletePreferencesTaskPool_context_null', 0, () => {
      (sharedPreferencesUtils as object)['context'] = null;
      sharedPreferencesUtils.deletePreferencesTaskPool('key');
      expect(sharedPreferencesUtils).not().assertUndefined();
    })

    it('sharedPreferencesUtilsTest_getPreferencesSync_mPreferences_null', 0, () => {
      (sharedPreferencesUtils as object)['mPreferences'] = null;
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      (sharedPreferencesUtils as object)['context'] = context;
      (sharedPreferencesUtils as object)['getPreferencesSync'](true);
      expect(sharedPreferencesUtils).not().assertUndefined();
    })

    it('SingleInstanceUtilsTest_createOrGet', 0, () => {
      let result1 = createOrGet<Test>(Test, 'test')
      let result2 = createOrGet<Test>(Test, 'test')
      expect(typeof result1).assertEqual(typeof result2);
    })

  })
}

class Test {

}