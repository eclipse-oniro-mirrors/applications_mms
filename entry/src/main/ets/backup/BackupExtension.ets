/**
 * Copyright (c) 2022-2023 Huawei Device Co., Ltd.
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
import BackupExtensionAbility, { BundleVersion } from '@ohos.application.BackupExtensionAbility';
import HiLog from '../utils/HiLog';
import MmsPresenter from './presenter/mms/MmsPresenter';
import { copyDbDataHelper } from './copyData/DbHelper';
import DbConstants from './copyData/DbConstants';
import DatabaseMaintain from '../DatabaseMaintain/DatabaseMaintain';
import { nextCopyDbDataHelper } from './copyData/NextDbHelper';
import SharedPreferencesUtils from '../utils/SharedPreferencesUtils';
import BackupRestoreProgress from './BackupRestoreProgress';
import taskPool from '@ohos.taskpool';
import { BusinessError } from '@kit.BasicServicesKit';

const TAG = 'BackupExtension-Mms';

@Concurrent
async function updateProgress(progress: BackupRestoreProgress): Promise<Object> {
  const TAG = 'BackupExtension-Mms';
  HiLog.i(TAG, `onRestoreFunction start`);
  return await new Promise<Object>((resolve, reject) => {
    const id = setInterval(() => {
      if (progress.isFinish()) {
        clearInterval(id);
        resolve(0);
      }
      progress.updateProcessCount(progress.getProcessCount() + 1);
      HiLog.i(TAG, `updateProgress: ${progress.getProcessCount()}`);
    }, 2000) // 2000: 2s触发一次进度更新, 一共2 * totalCount秒
  });
}

export default class BackupExtension extends BackupExtensionAbility {
  private restoreProgress: BackupRestoreProgress | undefined = undefined;
  private updateProgressTask: taskPool.LongTask | undefined = undefined;
  private updateProgressPromise: Promise<Object> | undefined = undefined;

  onBackup() {
  }

  private startProgress() {
    if (!this.restoreProgress) {
      this.restoreProgress = new BackupRestoreProgress();
    }
    if (this.updateProgressTask) {
      taskPool.terminateTask(this.updateProgressTask);
    }
    this.updateProgressTask = new taskPool.LongTask(updateProgress, this.restoreProgress);
    try {
      this.updateProgressPromise = taskPool.execute(this.updateProgressTask, taskPool.Priority.HIGH);
    } catch (error) {
      HiLog.e(TAG, `startProgress execute error. Code is ${error.code}, message is ${error.message}`);
    }
  }

  private async finishProgress(): Promise<void> {
    if (!this.restoreProgress) {
      HiLog.e(TAG, 'finishProgress invalid');
      return;
    }
    this.restoreProgress.finish();
    if (this.updateProgressPromise) {
      HiLog.i(TAG, 'finishProgress: wait promise');
      await this.updateProgressPromise;
      HiLog.i(TAG, 'finishProgress: promise done');
    }
    this.restoreProgress.updateProcessCount(this.restoreProgress.getTotalCount());
    if (this.updateProgressTask) {
      HiLog.i(TAG, 'finishProgress: terminate task');
      try {
        taskPool.terminateTask(this.updateProgressTask);
      } catch (error) {
        HiLog.e(TAG, `finishProgress terminate task error. Code is ${error.code}, message is ${error.message}`);
      }
    }
  }

  async onRestore(bundleVersion: BundleVersion): Promise<void> {
    HiLog.i(TAG, 'onRestore start.');
    let versionName: string = bundleVersion.name;
    HiLog.i(TAG, `bundleVersion name: ${versionName}`);
    if (!versionName || versionName.length === 0) {
      HiLog.i(TAG, 'bundleVersion is error, onRestore failed.');
      return;
    }
    this.startProgress();
    // await SmartMmsBackupExtensionHelper.onRestoreHandler(bundleVersion, this.context);
    const presenter: MmsPresenter = MmsPresenter.getInstance();
    presenter.init();
    DatabaseMaintain.getInstance().recordCloneStart(this.context);
    if (versionName.startsWith(DbConstants.UPDATE_VERSION_NAME)) {
      // Upgrade from XXX to YYY
      HiLog.i(TAG, 'Upgrade from XXX to YYY');
      await presenter.migrateDbFile(this.context!);
      let perfUpdatePath: string = this.context ? this.context.preferencesDir : '';
      if (perfUpdatePath) {
        let isCopySuccess = await copyDbDataHelper.copyPrefFileForUpdate(perfUpdatePath, this.context!);
        isCopySuccess && await presenter.migrateMmsPref(this.context!, perfUpdatePath);
      } else {
        HiLog.e(TAG, 'the preferencesDir undefined.');
      }
    } else if (versionName == DbConstants.CLONE_VERSION_NAME ||
      versionName == DbConstants.ARD_CLONE_VERSION_NAME) {
      // Data migration from XXX to YYY
      copyDbDataHelper.setVersion(versionName);
      const applicationContextPath: string = this.context ? this.context.databaseDir : '';
      if (applicationContextPath) {
        HiLog.i(TAG, 'onRestore Data migration from XXX to YYY');
        await copyDbDataHelper.copyDbListFileForClone(applicationContextPath, this.context!);
      }
      const perfContextPath: string = this.context ? this.context.preferencesDir : '';
      if (perfContextPath) {
        let isCopyDbSuccess = await copyDbDataHelper.copyPrefFileForClone(perfContextPath, this.context!);
        isCopyDbSuccess && await presenter.migratePrefFile(this.context!);
      } else {
        HiLog.e(TAG, 'the preferencesDir undefined.');
      }
    } else {
      // 单单恢复时如果有新增目录需要恢复时处理 需要在备份恢复框架配置文件 backup_config.json中includes配置项中增加目录
      HiLog.i(TAG, 'onRestore Data migration from a single frame to a single frame');
      await nextCopyDbDataHelper.copyDbListFileForClone(this.context!, versionName);
      await nextCopyDbDataHelper.copyPrefFileForClone(this.context!, versionName);
    }
    DatabaseMaintain.getInstance().updateInfoMsgVersion(this.context);
    await this.finishProgress();
    HiLog.i(TAG, 'onRestore end.');
  }

  onProcess(): string {
    try {
      HiLog.i(TAG, `onProcess start`);
      if (this.restoreProgress == undefined) {
        this.restoreProgress = new BackupRestoreProgress();
      }
      let result: string = this.restoreProgress.getProgress();
      HiLog.i(TAG, `onProcess result: ${result}`);
      return result;
    } catch (error) {
      HiLog.e(TAG, `onProcess failed error code: ${error.code} error name: ${error.message}`);
      return '';
    }
  }
}