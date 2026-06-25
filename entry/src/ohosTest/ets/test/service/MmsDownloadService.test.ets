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
import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect, MockKit, when } from '@ohos/hypium'

import { GlobalContext } from '../../../../main/ets/MainAbility/GlobalHelper';
import MmsDownloadService from '../../../../main/ets/service/MmsDownloadService';
import { mmsInfo } from '../../../../main/ets/utils/TypesUtils';
import { DTGlobalContext } from '../../testability/TestAbility';

export default function MmsDownloadServiceTest() {
  describe('MmsDownloadServiceTest', () => {
    // Defines a test suite. Two parameters are supported: test suite name and test suite function.
    let mocker: MockKit;
    let mmsDownloadService: MmsDownloadService;
    beforeEach(() => {
      mocker = new MockKit();
      mmsDownloadService = MmsDownloadService.getInstance();
    })

    it('MmsDownloadServiceTest_getInstance', 0, () => {
      let mmsDownloadService1: MmsDownloadService = MmsDownloadService.getInstance();
      expect(typeof mmsDownloadService1).assertEqual(typeof mmsDownloadService);
    })
    it('MmsDownloadServiceTest_queryUnDownloadMms', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      mmsDownloadService.queryUnDownloadMms(context).then((result) => {
        expect(result.length > 0).assertFalse();
      });
    })
    it('MmsDownloadServiceTest_queryUnDownloadMms_false', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      mmsDownloadService.queryUnDownloadMms(context).then((result) => {
        expect(result.length > 0).assertFalse();
      });

    })
  })
}