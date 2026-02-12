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
import BackupExtensionContext from '@ohos.file.BackupExtensionContext';
import { GlobalContext } from '../../../../../main/ets/MainAbility/GlobalHelper';
import { common } from '@kit.AbilityKit';
import { resourceManager } from '@kit.LocalizationKit';
import { nextCopyDbDataHelper } from '../../../../../main/ets/backup/copyData/NextDbHelper';
import HiLog from '../../../../../main/ets/utils/HiLog';

export default function NextDbHelperTest() {
  describe('NextDbHelperTest', () => {
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

    it('NextDbHelperTest_copyPrefFileForClone', 0, async () => {
      let context = {
        area:1,
        backupDir:'/storage/',
        preferencesDir:'preferencesDir'
      } as BackupExtensionContext;
      let result:boolean = await nextCopyDbDataHelper.copyPrefFileForClone(context, '')
      expect(result).assertEqual(false)
    })

    it('NextDbHelperTest_copyPrefFileForClone_area_2', 0, async () => {
      let context = {
        area:1,
        backupDir:'/storage/',
        preferencesDir:'preferencesDir'
      } as BackupExtensionContext;
      context.area = 2;
      let result:boolean = await nextCopyDbDataHelper.copyPrefFileForClone(context, '')
      expect(result).assertEqual(false)
    })

    it('NextDbHelperTest_copyDbListFileForClone', 0, async () => {
      let context = {
        area:1,
        backupDir:'/storage/',
        filesDir:'filesDir'
      } as BackupExtensionContext;
      let result:boolean = await nextCopyDbDataHelper.copyDbListFileForClone(context, '')
      expect(result).assertEqual(false)
    })

    it('NextDbHelperTest_copyDbListFileForClone_area_2', 0, async () => {
      let context = {
        area:1,
        backupDir:'/storage/',
        filesDir:'filesDir'
      } as BackupExtensionContext;
      context.area = 2;
      let result:boolean = await nextCopyDbDataHelper.copyDbListFileForClone(context, '')
      expect(result).assertEqual(false)
    })

    it('NextDbHelperTest_delPrefDbFile', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.i);
      nextCopyDbDataHelper.delPrefDbFile('desClonePath');
      mocker.verify('i', ['[Next-Copy-DbHelper-Mms]', 'copyDbListFileForClone 1 clonePath is not file']).once();
      mocker.clear(HiLog);
    })
  })
}