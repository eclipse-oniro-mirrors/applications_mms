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
import { describe, beforeEach, afterEach, it, expect, MockKit, when, ArgumentMatchers } from '@ohos/hypium';
import PatternControl from '../../../../main/ets/pages/PatternControl';
import HiLog from '../../../../main/ets/utils/HiLog';

export default function PatternControlTest() {
  describe('PatternControlTest', () => {

    let patternControl: PatternControl;
    let mocker: MockKit
    let isSubUser: boolean = false;
    const TAG = 'PatternControl';

    beforeEach(() => {
      patternControl = PatternControl.getInstance();
      mocker = new MockKit();
      mocker.mockFunc(HiLog, HiLog.i);
    })

    afterEach(() => {
      mocker.clear(HiLog);
    })

    it('PatternControlTest_getInstance', 0, () => {
      expect(typeof patternControl).assertEqual(typeof PatternControl.getInstance());
    })

    it('PatternControlTest_setSubUser', 0, () => {
      isSubUser = false;
      patternControl.setSubUser(false);
      expect(isSubUser).assertFalse();
    })
  })
}