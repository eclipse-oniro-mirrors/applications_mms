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
import { describe, it, expect } from '@ohos/hypium';
import { copyDbDataHelper } from '../../../../main/ets/backup/copyData/DbHelper';
import { DTGlobalContext } from '../../testability/TestAbility';
import BackupExtensionContext from '@ohos.file.BackupExtensionContext';

export default function copyDbDataHelperTest() {
  describe('copyDbDataHelperTest', () => {

    it('CopyDbDataHelperTest_copyPrefFileForClone_if1', 0, async () => {
      let context = {
        area:1,
        backupDir:'/storage/'
      } as BackupExtensionContext;
      context.area = 2;

      let path = context.preferencesDir;

      let result = await copyDbDataHelper.copyPrefFileForClone(path, context);

      expect(result).assertFalse();
    })

    it('CopyDbDataHelperTest_copyPrefFileForClone_noIif', 0, async () => {
      let context = {
        area:1,
        backupDir:'/storage/'
      } as BackupExtensionContext;
      context.area = 1;

      let path = context.preferencesDir;

      let result = await copyDbDataHelper.copyPrefFileForClone(path, context);

      expect(result).assertFalse();
    })

    it('CopyDbDataHelperTest_copyPrefFileForUpdate_if1', 0, async () => {
      let context = {
        area:1,
        backupDir:'/storage/'
      } as BackupExtensionContext;
      context.area = 2;

      let path = context.preferencesDir;

      let result = await copyDbDataHelper.copyPrefFileForUpdate(path, context);

      expect(result).assertFalse();
    })

    it('CopyDbDataHelperTest_copyPrefFileForUpdate_noIf1', 0, async () => {
      let context = {
        area:1,
        backupDir:'/storage/'
      } as BackupExtensionContext;
      context.area = 1;

      let path = context.preferencesDir;

      let result = await copyDbDataHelper.copyPrefFileForUpdate(path, context);

      expect(result).assertFalse();
    })

    it('CopyDbDataHelperTest_copyDbListFileForClone_if1', 0, async () => {
      let context = {
        area:1,
        backupDir:'/storage/'
      } as BackupExtensionContext;
      context.area = 2;

      let path = context.databaseDir;

      let result = await copyDbDataHelper.copyDbListFileForClone(path, context);

      expect(result).assertFalse();
    })

    it('CopyDbDataHelperTest_copyDbListFileForClone_noIf1', 0, async () => {
      let context = {
        area:1,
        backupDir:'/storage/'
      } as BackupExtensionContext;
      context.area = 1;

      let path = context.databaseDir;

      let result = await copyDbDataHelper.copyDbListFileForClone(path, context);

      expect(result).assertFalse();
    })
  })
}