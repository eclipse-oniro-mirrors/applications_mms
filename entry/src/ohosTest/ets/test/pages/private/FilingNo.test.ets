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
import { it } from "@ohos/hypium";
import { expect } from "@ohos/hypium";
import { when } from "@ohos/hypium";
import { ArgumentMatchers } from "@ohos/hypium";
import { MockKit } from "@ohos/hypium";
import { describe } from "@ohos/hypium";
import { FilingNo } from "../../../../../main/ets/pages/privacy/FilingNo";
import HiLog from "../../../../../main/ets/utils/HiLog";
import { DTGlobalContext } from "../../../testability/TestAbility";
import { common } from "@kit.AbilityKit";
import { hilog } from "@kit.PerformanceAnalysisKit";


export default function FilingNoTest() {
  describe('FilingNoTest', () => {
    // Defines a test suite. Two parameters are supported: test suite name and test suite function.
    it('FilingNoTest_getInstance', 0, () => {
      let result1 = FilingNo.getInstance();
      let result2 = FilingNo.getInstance();
      expect(result1).assertDeepEquals(result2);
    })

    it('FilingNoTest_implicitStartBrowserAbility', 0, async () => {
      let mocker: MockKit = new MockKit();
      let instance: FilingNo = FilingNo.getInstance();
      mocker.mockFunc(instance, instance.implicitStartBrowserAbility);
      await instance.implicitStartBrowserAbility()
      mocker.verify('implicitStartBrowserAbility',[]).once();
      mocker.verify('implicitStartBrowserAbility',[]).atLeast(1);
      mocker.clear(instance);
    })
  })
}

