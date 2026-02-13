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

import { describe, beforeEach, it, MockKit, expect } from '@ohos/hypium';
import BackupExtension from '../../../../main/ets/backup/BackupExtension';
import { BundleVersion } from '@ohos.application.BackupExtensionAbility';
import HiLog from '../../../../main/ets/utils/HiLog';
import BackupExtensionContext from '@ohos.file.BackupExtensionContext';
import { DTGlobalContext } from '../../testability/TestAbility';
import { afterEach } from '@ohos/hypium/src/main/interface';

export default function BackupExtensionTest() {

  describe('BackupExtensionTest', () => {

    const TAG = 'BackupExtension-Mms';
    let backup: BackupExtension;
    let mocker: MockKit;

    beforeEach(() => {
      backup = new BackupExtension();
      mocker = new MockKit();
      mocker.mockFunc(HiLog, HiLog.i);
    })

    afterEach(() => {
      mocker.clear(HiLog);
    })

    it('BackupExtensionTest_onBackup', 0, () => {
      backup.context = DTGlobalContext.getContext().getObject('mmsContext') as BackupExtensionContext;

      backup.onBackup();
      mocker.verify('i', ['BackupExtension-Mms', 'onBackup init and save a time of copy temporary db in el1']).once();

    })

    it('BackupExtensionTest_onRestore_versionName_empty', 0, () => {
      let version: BundleVersion = {
        code: 1,
        name: ''
      };

      backup.onRestore(version);

      mocker.verify('i', [TAG, 'bundleVersion is error, onRestore failed.']).once();
    })

    it('BackupExtensionTest_onRestore_if2', 0, async () => {
      let version: BundleVersion = {
        code: 1,
        name: '0.0.0.0'
      };

      backup.context = DTGlobalContext.getContext().getObject('mmsContext') as BackupExtensionContext;

      await backup.onRestore(version);

      mocker.verify('i', [TAG, 'Upgrade from dual-framework to single-framework']).once();
    })

    it('BackupExtensionTest_onRestore_elseIf', 0, () => {
      let version: BundleVersion = {
        code: 1,
        name: '99.99.99.999'
      };

      backup.context = DTGlobalContext.getContext().getObject('mmsContext') as BackupExtensionContext;

      backup.onRestore(version);

      mocker.verify('i', [TAG, 'the preferencesDir undefined.']).never();
    })

    it('BackupExtensionTest_onRestore_else', 0, () => {
      let version: BundleVersion = {
        code: 1,
        name: "1.1.0.0"
      }
      backup.onRestore(version);

      mocker.verify('i', [TAG, 'the preferencesDir undefined.']).never();
    })

  })
}