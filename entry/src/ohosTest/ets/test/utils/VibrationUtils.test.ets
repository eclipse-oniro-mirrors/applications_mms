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
import { describe, beforeAll, afterEach, afterAll, it, expect, MockKit, when,
  ArgumentMatchers } from '@ohos/hypium'
import commonData from '../../../../main/ets/data/commonData';
import { VibrationUtils } from '../../../../main/ets/utils/VibrationUtils';

export default function VibrationUtilsTest() {
  describe('VibrationUtilsTest', () => {


    it('should_log_error_when_vibrator_startVibration_fails', 0, async () => {
      VibrationUtils.onceVibration(commonData.VIBRATIONEFFECT.LONG_PRESS_MEDIUM);
      expect(VibrationUtils).not().assertUndefined();
    });
    it('should_log_error_when_vibrator_startVibration_1', 0, async () => {
      VibrationUtils.onceVibration('1.000');
      expect(VibrationUtils).not().assertUndefined();
    })

  })
}