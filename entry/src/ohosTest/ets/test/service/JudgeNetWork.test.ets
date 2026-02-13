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
import { describe, it, expect} from '@ohos/hypium'
import JudgeNetWork from '../../../../main/ets/service/JudgeNetWork'

export default function JudgeNetWorkTest() {
  describe('JudgeNetWorkTest', () => {
    it('JudgeNetWorkTest_getInstance', 0, () => {
      let sInstanceNull: JudgeNetWork = JudgeNetWork.getInstance();
      expect(sInstanceNull).not().assertNull();
      let sInstance: JudgeNetWork = JudgeNetWork.getInstance();
      expect(sInstanceNull).assertEqual(sInstance);
    });

    it('JudgeNetWorkTest_judgeHasNet_netHandle_false', 0, () => {
      let sInstance: JudgeNetWork = JudgeNetWork.getInstance();
      let hasNet: boolean = sInstance.judgeHasNet();
      expect(hasNet).assertFalse();
    });
  })
}