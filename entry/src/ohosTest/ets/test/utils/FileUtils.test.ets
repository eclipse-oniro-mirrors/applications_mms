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
import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect, ArgumentMatchers, when,
  MockKit } from '@ohos/hypium'
import common from '@ohos.app.ability.common'
import { DTGlobalContext } from '../../testability/TestAbility'
import FileUtils from '../../../../main/ets/utils/FileUtils'
import { ListFileOptions } from '@kit.CoreFileKit'
import HiLog from '../../../../main/ets/utils/HiLog'

export default function FileUtilsTest() {
  describe('FileUtilsTest', () => {
    // Defines a test suite. Two parameters are supported: test suite name and test suite function.
    let context = DTGlobalContext.getContext().getObject('mmsContext') as common.ExtensionContext;
    beforeAll(() => {
      // Presets an action, which is performed only once before all test cases of the test suite start.
      // This API supports only one parameter: preset action function.
    });
    beforeEach(() => {
      // Presets an action, which is performed before each unit test case starts.
      // The number of execution times is the same as the number of test cases defined by **it**.
      // This API supports only one parameter: preset action function.
    });
    afterEach(() => {
      // Presets a clear action, which is performed after each unit test case ends.
      // The number of execution times is the same as the number of test cases defined by **it**.
      // This API supports only one parameter: clear action function.
    });
    afterAll(() => {
      // Presets a clear action, which is performed after all test cases of the test suite end.
      // This API supports only one parameter: clear action function.
    });

    it('FileUtilsTest_copyFile', 0, async () => {
      let srcPath: string = '/data/storage/el2/base/haps/entry/files';
      let dstPath: string = '/data/storage/el1/base/haps/entry/files';
      const boolFile = FileUtils.copyFile(srcPath, dstPath);
      expect(boolFile).assertEqual(false);
    })
    it('FileUtilsTest_copyDir', 0, async () => {
      let srcPath: string = '/data/storage/el2/base/haps/entry/files';
      let dstPath: string = '/data/storage/el1/base/haps/entry/files';
      const boolFile = FileUtils.copyDir(srcPath, dstPath);
      expect(boolFile).assertEqual(false);
    })
    it('FileUtilsTest_deleteFile', 0, async () => {
      let srcPath: string = '/data/storage/el1/base/haps/entry/files';
      const boolFile = FileUtils.deleteFile(srcPath);
      expect(boolFile).assertEqual(false);
    })
  })
}