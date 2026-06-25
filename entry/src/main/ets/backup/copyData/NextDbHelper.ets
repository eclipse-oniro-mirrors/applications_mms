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

import fs from '@ohos.file.fs';
import HiLog from '../../utils/HiLog';
import BackupExtensionContext from '@ohos.file.BackupExtensionContext';
import contextConstant from '@ohos.app.ability.contextConstant';
import data_preferences from '@ohos.data.preferences';
import SharedPreferencesUtils from '../../utils/SharedPreferencesUtils';
import settings from '@ohos.settings';
import commonData from '../../data/commonData';
import ConversationList from '../../pages/conversationlist/conversationList';
import DbConstants from './DbConstants';
import PreferenceConstant from '../../data/PreferenceConstant';

const TAG = '[Next-Copy-DbHelper-Mms]';

class NextCopyDbDataHelper {
  private getClonePathListFile(clonePath: string): string[] {
    try {
      const isClonePathExists = fs.accessSync(clonePath);
      HiLog.i(TAG, `getClonePathListFile isClonePathExists: ${isClonePathExists}`);
      if (!isClonePathExists) {
        return [];
      }
      return fs.listFileSync(clonePath);
    } catch (error) {
      HiLog.i(TAG, 'getClonePathListFile catch error');
      return [];
    }
  }

  public async copyPrefFileForClone(context: BackupExtensionContext, versionName: string):
    Promise<boolean> {
    HiLog.i(TAG, 'copyPrefFileForClone start.');
    if (versionName.startsWith(DbConstants.I_CLONE_VERSION_NAME)) {
      return true;
    }
    if (context.area !== contextConstant.AreaMode.EL2) {
      context.area = contextConstant.AreaMode.EL2;
    }
    let srcClonePath: string = context.backupDir + 'restore/data/storage/el2/base/preferences';
    let desClonePath: string = context.preferencesDir;
    try {
      let isSrcClonePathExists: boolean = fs.accessSync(srcClonePath);
      if (!isSrcClonePathExists) {
        HiLog.e(TAG, 'srcClonePath is not exists');
        return false;
      }
      let isDesClonePathExists: boolean = fs.accessSync(desClonePath);
      if (!isDesClonePathExists) {
        try {
          fs.mkdirSync(desClonePath);
        } catch (error) {
          HiLog.e(TAG, `Create desClonePath fialed, error code: ${error.code}`);
          return false;
        }
      } else {
        this.delPrefDbFile(desClonePath);
      }
      const listFileName = this.getClonePathListFile(srcClonePath);
      if (listFileName === undefined || listFileName === null || listFileName.length === 0) {
        HiLog.i(TAG, 'copyDbListFileForClone 1 clonePath is not file');
        return false;
      }
      listFileName.forEach((value: string) => {
        const srcPath = `${srcClonePath}/${value}`;
        if (value.indexOf('MmsStore') > -1) {
          value = 'back' + value;
          const destPath = `${desClonePath}/${value}`;
          fs.copyFileSync(srcPath, destPath);
        }
      });
      let preferences: data_preferences.Preferences =
        data_preferences.getPreferencesSync(context, { name: 'backMmsStore' });
      let value = preferences.getAllSync();
      SharedPreferencesUtils.init(context);
      let arr: [string, Object][] = Object.entries(value)
      let chatBotHasChanged = false
      // 短信通知提醒需要在克隆和恢复时读取旧机值之前将本机的值清空，避免旧机无key时，未覆盖新机的值导致还继续使用新机的旧值。
      SharedPreferencesUtils.saveToPreferences(PreferenceConstant.IS_REMINDED_ENABLE_NOTIFICATION, '');
      for (let key of arr) {
        SharedPreferencesUtils.saveToPreferences(key[0], key[1]);
        if (key[0] === commonData.STR.KEY_OF_IS_RCS_OPEN_SWITCH) {
          if (!chatBotHasChanged) {
            SharedPreferencesUtils.saveToPreferences('isUIChatbotOpenRcs', key[1] as boolean);
          }
        }
        if (key[0] === commonData.STR.KEY_OF_IS_CHATBOT_OPEN_SWITCH) {
          chatBotHasChanged = true;
        }
      }
      return true;
    } catch (error) {
      HiLog.e(TAG, `copyPrefFileForClone fialed, error: ${JSON.stringify(error)}`);
    } finally {
      // 删除备份preference
      this.delPrefDbFile(desClonePath);
    }
    return false;
  }

  public async copyDbListFileForClone(context: BackupExtensionContext, versionName: string):
    Promise<boolean> {
    HiLog.i(TAG, `copyDbListFileForClone start`);
    if (context.area !== contextConstant.AreaMode.EL2) {
      context.area = contextConstant.AreaMode.EL2;
    }
    let readClonePath = context.filesDir;
    let backupDir: string = '';
    if (versionName.startsWith(DbConstants.I_CLONE_VERSION_NAME)) {
      backupDir = context.backupDir + 'restore/mms';
    } else {
      backupDir = context.backupDir + 'restore/data/storage/el2/base/haps/entry/files';
    }
    try {
      const isClonePathExists = fs.accessSync(backupDir);
      if (!isClonePathExists) {
        HiLog.e(TAG, `ClonePathExists is not exists`);
        return false;
      }
      const isReadClonePathExists = fs.accessSync(readClonePath);
      if (!isReadClonePathExists) {
        try {
          fs.mkdirSync(readClonePath);
        } catch (error) {
          HiLog.i(TAG, `readClonePath: ${error.code}`);
        }
      }
      const listFileName = this.getClonePathListFile(backupDir);
      if (listFileName === undefined || listFileName === null || listFileName.length === 0) {
        HiLog.i(TAG, 'copyDbListFileForClone clonePath is not file');
        return false;
      }
      listFileName.forEach((value: string) => {
        const srcPath = `${backupDir}/${value}`;
        const destPath = `${readClonePath}/${value}`;
        if (fs.statSync(srcPath).isFile()) {
          fs.copyFileSync(srcPath, destPath);
        } else if (fs.statSync(srcPath).isDirectory()) {
          try {
            fs.copyDirSync(srcPath, readClonePath);
          } catch (error) {
            HiLog.i(TAG,
              `copyDbListFileForClone error: ${JSON.stringify(error)}`);
          }
        } else {
          HiLog.e(TAG, 'invalid src file ');
        }
      });
      HiLog.i(TAG, 'copyDbFile success');
      return true;
    } catch (error) {
      HiLog.i(TAG, `copyDbListFileForClone error: ${JSON.stringify(error)}`);
    }
    return false;
  }

  public delPrefDbFile(desClonePath: string): void {
    const listFileName = this.getClonePathListFile(desClonePath);
    if (listFileName === undefined || listFileName === null || listFileName.length === 0) {
      HiLog.i(TAG, 'copyDbListFileForClone 1 clonePath is not file');
      return;
    }
    HiLog.i(TAG, `delPrefDbFile listFileName: ${listFileName}`);
    listFileName.forEach((value: string) => {
      if (value.indexOf('backMmsStore') > -1) {
        const destPath = `${desClonePath}/${value}`;
        fs.unlinkSync(destPath);
      }
    });
  }

}

export const nextCopyDbDataHelper: NextCopyDbDataHelper = new NextCopyDbDataHelper();