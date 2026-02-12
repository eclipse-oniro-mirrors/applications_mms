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
import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect, MockKit } from '@ohos/hypium'
import { copyDbDataHelper } from '../../../../../main/ets/backup/copyData/DbHelper'
import BackupExtensionContext from '@ohos.file.BackupExtensionContext';
import { common } from '@kit.AbilityKit';
import { resourceManager } from '@kit.LocalizationKit';
import { DTGlobalContext } from '../../../testability/TestAbility';
import HiLog from '../../../../../main/ets/utils/HiLog';

export default function DbHelperTest() {
  describe('DbHelperTest', () => {
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

    it('DbHelperTest_copyPrefFileForClone', 0, async () => {
      let context = {
        area:1,
        backupDir:'/storage/'
      } as BackupExtensionContext;
      context.area = 2;
      let result:boolean = await copyDbDataHelper.copyPrefFileForClone('', context)
      expect(result).assertEqual(false)
    })

    it('DbHelperTest_copyPrefFileForUpdate', 0, async () => {
      let context = {
        area:1,
        backupDir:'/storage/'
      } as BackupExtensionContext;
      context.area = 2;
      let result:boolean = await copyDbDataHelper.copyPrefFileForUpdate('', context)
      expect(result).assertEqual(false)
    })

    it('DbHelperTest_copyDbListFileForClone', 0, async () => {
      let context = {
        area:1,
        backupDir:'/storage/'
      } as BackupExtensionContext;
      context.area = 2;
      let result:boolean = await copyDbDataHelper.copyPrefFileForUpdate('', context)
      expect(result).assertEqual(false)
    })

    it('DbHelperTest_handleSmilFile', 0, async () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.w);
      let context = {
        resourceManager: {
          getStringSync: (resource: Resource, ...args: (string | number)[]): string => 'common.ExtensionContext'
        } as resourceManager.ResourceManager
      } as common.ExtensionContext;
      await copyDbDataHelper.handleSmilFile(context);
      mocker.verify('w', ['[Copy-DbHelper-Mms]', 'handleSmilFile start']).atLeast(1);
      mocker.clear(HiLog);
    })

    it('DbHelperTest_handleSmilFile_context', 0, async () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.w);
      let context = DTGlobalContext.getContext().getObject('mmsContext') as common.ExtensionContext;
      await copyDbDataHelper.handleSmilFile(context);
      mocker.verify('w', ['[Copy-DbHelper-Mms]', 'handleSmilFile start']).atLeast(1);
      mocker.clear(HiLog);
    })

    it('DbHelperTest_getPartFileName_if1', 0, async () => {
      let result = await copyDbDataHelper.getPartFileName(undefined);
      expect(result).assertEqual('');
    })
  })
}