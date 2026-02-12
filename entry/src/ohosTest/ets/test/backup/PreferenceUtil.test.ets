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
import { describe, it, expect, beforeEach } from '@ohos/hypium';
import { DTGlobalContext } from '../../testability/TestAbility';
import PreferenceUtil from '../../../../main/ets/backup/util/PreferenceUtil';
import myCommon from '@ohos.app.ability.common';
import data_preferences from '@ohos.data.preferences';

export default function PreferenceUtilTest() {
  describe('PreferenceUtilTest', () => {
    let mPreferenceUtil: PreferenceUtil
    beforeEach(() => {
      mPreferenceUtil = PreferenceUtil.getTestInstance();
    })

    it('PreferenceUtilTest_saveToPreferences', 0, async () => {
      let context = DTGlobalContext.getContext().getObject("mmsContext") as myCommon.UIAbilityContext;
      mPreferenceUtil.init(context);
      let attributeValue: string = "11";
      let result: Promise<void> = mPreferenceUtil.saveToPreferences("111", attributeValue);

      expect(JSON.stringify(result))
        .assertEqual(JSON.stringify(new Promise<void>(resolve => resolve())));
    })

    it('PreferenceUtilTest_isEmpty1', 0, () => {
      expect(mPreferenceUtil.isEmpty('')).assertTrue();
    })
  })
}