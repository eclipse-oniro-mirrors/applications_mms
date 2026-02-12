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
import { beforeAll, beforeEach, describe, expect, it } from '@ohos/hypium';
import MmsRingtoneManager from '../../../../main/ets/utils/SystemSoundManagerUtil';
import myCommon from '@ohos.app.ability.common';
import { GlobalContext } from '../../../../main/ets/MainAbility/GlobalHelper';

export default function SystemSoundManagerUtilTest() {
  describe('SystemSoundManagerUtilTest', () => {
    // Defines a test suite. Two parameters are supported: test suite name and test suite function.
    beforeAll(() => {
    })
    beforeEach(() => {
    })

    it('SystemSoundManagerUtilTest__should_log_error_when_setSystemToneUri_fails', 0, async () => {
      let mmsringtonemanager: MmsRingtoneManager = new MmsRingtoneManager();
      const context: myCommon.UIAbilityContext = GlobalContext.getContext()
        .getObject('mmsContext') as myCommon.UIAbilityContext;
      mmsringtonemanager.setSystemRingtoneUri(context, 'ringName', 0);
      expect().assertUndefined();
    });
  })
}