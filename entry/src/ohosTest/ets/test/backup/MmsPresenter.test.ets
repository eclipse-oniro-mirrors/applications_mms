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
import { describe, beforeEach, it, MockKit } from '@ohos/hypium';
import common from '@ohos.app.ability.common';
import MmsPresenter from '../../../../main/ets/backup/presenter/mms/MmsPresenter';
import { DTGlobalContext } from '../../testability/TestAbility';
import BackupExtensionContext from '@ohos.file.BackupExtensionContext';
import HiLog from '../../../../main/ets/utils/HiLog';

export default function MmsPresenterTest() {
  describe('MmsPresenterTest', () => {
    let mmsPresenter: MmsPresenter;

    beforeEach(() => {
      mmsPresenter = MmsPresenter.getInstance();
    })

    it('MmsPresenterTest_migrateDbFile', 0, () => {
      let backupContext = DTGlobalContext.getContext().getObject('mmsContext') as BackupExtensionContext;
      mmsPresenter.init();

      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.i);

      mmsPresenter.migrateDbFile(backupContext);

      mocker.verify('i', ['MmsModel', 'destPath : ']).never();

      mocker.clear(HiLog);
    });

    it('MmsPresenterTest_migratePrefFile', 0, () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as common.ExtensionContext;
      mmsPresenter.init();

      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.i);

      mmsPresenter.migratePrefFile(context);

      mocker.verify('i', ['MmsModel', 'migratePrefFile end.']).never();

      mocker.clear(HiLog);
    });

    it('MmsPresenterTest_migrateMmsPref', 0, () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as common.ExtensionContext;
      mmsPresenter.init();

      let path = context.preferencesDir;

      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.i);

      mmsPresenter.migrateMmsPref(context, path);

      mocker.verify('i', ['MmsModel', 'The mms_preferences.xml file dose not exist.']).never();

      mocker.clear(HiLog);
    });
  })
}