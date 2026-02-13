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
import rdb from '@ohos.data.relationalStore';
import common from '@ohos.app.ability.common';
import HiLog from '../../utils/HiLog';
import DbConstants from './DbConstants';
import OldDBData from './OldDBData';
import FileUtils from '../../utils/FileUtils';
import StringUtil from '../../utils/StringUtil';
import BackupExtensionContext from '@ohos.file.BackupExtensionContext';
import contextConstant from '@ohos.app.ability.contextConstant';
import FileUtil from '../../utils/FileUtil';

const TAG = '[Copy-DbHelper-Mms]';

class CopyDbDataHelper {
  private rdbStoreHelper?: rdb.RdbStore;
  private version: string = '';

  public setVersion(version: string) {
    this.version = version;
  }

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

  public async copyPrefFileForClone(applicationContextPath: string, context: BackupExtensionContext):
    Promise<boolean> {
    HiLog.i(TAG, 'copyPrefFileForClone start.');
    if (context.area !== contextConstant.AreaMode.EL2) {
      context.area = contextConstant.AreaMode.EL2;
    }
    let srcClonePath: string = context.backupDir + 'restore/shared_pref';
    let desClonePath: string = applicationContextPath + '/pref';

    try {
      let isSrcClonePathExists: boolean = fs.accessSync(srcClonePath);
      if (!isSrcClonePathExists) {
        HiLog.e(TAG, 'srcClonePath is not exists');
        return false;
      }

      let isDesClonePathExists: boolean = fs.accessSync(desClonePath);
      if(!isDesClonePathExists){
        try {
          fs.mkdirSync(desClonePath);
        }catch(error) {
          HiLog.e(TAG, `Create desClonePath fialed, error code: ${error.code}`);
          return false;
        }
      }
      desClonePath = desClonePath + '/shared_pref.zip';
      fs.copyFileSync(srcClonePath, desClonePath);
      HiLog.i(TAG, 'copyPrefFileForClone success.');
      return true;
    } catch (error) {
      HiLog.e(TAG, `copyPrefFileForClone fialed, error: ${JSON.stringify(error)}`);
    }
    return false;
  }

  public async copyPrefFileForUpdate(applicationContextPath: string, context: BackupExtensionContext):
    Promise<boolean> {
    if (context.area !== contextConstant.AreaMode.EL2) {
      context.area = contextConstant.AreaMode.EL2;
    }
    let srcUpdatePath: string = context.backupDir + '/restore/com.xxx.mms/ce/shared_prefs/';
    let desUpdatePath: string = applicationContextPath;
    try {
      let isSrcUpdatePathExists: boolean = fs.accessSync(srcUpdatePath);
      if (!isSrcUpdatePathExists) {
        HiLog.e(TAG, 'srcUpdatePath is not exists');
        return false;
      }
      let isDesUpdatePathExists: boolean = fs.accessSync(desUpdatePath);
      if (!isDesUpdatePathExists) {
        try {
          fs.mkdirSync(desUpdatePath);
        } catch (error) {
          HiLog.e(TAG, `Create desUpdatePath fialed, error code: ${error.code}`);
          return false;
        }
      }
      if (isSrcUpdatePathExists && isDesUpdatePathExists) {
        HiLog.i(TAG, 'onRestore result: success');
        let ret1 = FileUtils.copyDir(srcUpdatePath, desUpdatePath);
        HiLog.i(TAG, `ret1: ${ret1}`);
        return ret1;
      }
      return false;
    } catch (error) {
      HiLog.e(TAG, `copyPrefFileForUpdate fialed, error: ${JSON.stringify(error)}`);
    }
    return false;
  }

  public async copyDbListFileForClone(applicationContextPath: string, context: BackupExtensionContext):
    Promise<boolean> {
    HiLog.i(TAG, `copyDbListFileForClone start`);
    if (context.area !== contextConstant.AreaMode.EL2) {
      context.area = contextConstant.AreaMode.EL2;
    }
    let readClonePath = applicationContextPath + '/rdb';
    let backupDir = context.backupDir + '/restore';
    try {
      const isClonePathExists = fs.accessSync(backupDir);
      if (!isClonePathExists) {
        HiLog.e(TAG, `ClonePathExists is not exists`);
        return false;
      }
      const isReadClonePathExists = fs.accessSync(readClonePath);
      if(!isReadClonePathExists){
        try {
          fs.mkdirSync(readClonePath);
        }catch(error) {
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
        fs.copyFileSync(srcPath, destPath);
      });
      HiLog.i(TAG, 'copyDbFile success');
      await this.queryPartInfo(context);
      HiLog.i(TAG, 'query table end');
      return true;
    } catch (error) {
      HiLog.i(TAG, `copyDbListFileForClone error: ${JSON.stringify(error)}`);
    }
    return false;
  }

  private async initDB(context: common.ExtensionContext, dbName: string): Promise<rdb.RdbStore | undefined> {
    if (!context) {
      HiLog.w(TAG, '[createDB] context is empty');
      return undefined;
    }
    if (this.rdbStoreHelper) {
      HiLog.i(TAG, '[createDB] return');
      return Promise.resolve(this.rdbStoreHelper);
    }
    try {
      const OLD_CONFIG: rdb.StoreConfig = {
        name: dbName,
        securityLevel: rdb.SecurityLevel.S1
      };
      HiLog.i(TAG, '[createDB] OLD_CONFIG');
      this.rdbStoreHelper = await rdb.getRdbStore(context, OLD_CONFIG);
    } catch (error) {
      HiLog.w(TAG, '[createDB] failed : ' + JSON.stringify(error));
    }
    if (this.rdbStoreHelper) {
      return Promise.resolve(this.rdbStoreHelper);
    }
    return undefined;
  }

  public getPartFileName(resultSet: rdb.ResultSet): string {
    if (resultSet === undefined) {
      HiLog.e(TAG, 'resultSet invalid.');
      return '';
    }
    let cl = resultSet.getString(resultSet.getColumnIndex(OldDBData.part.cl));
    let data = resultSet.getString(resultSet.getColumnIndex(OldDBData.part.Data));
    let name = resultSet.getString(resultSet.getColumnIndex(OldDBData.part.name));
    if (!StringUtil.isEmpty(cl)) {
      return cl;
    }
    if (!StringUtil.isEmpty(name)) {
      return name;
    }
    let dataFn = StringUtil.getPathTail(data)
    if (!StringUtil.isEmpty(dataFn)) {
      return dataFn;
    }
    return '';
  }

  public getThirdPartFileName(resultSet: rdb.ResultSet): string {
    if (resultSet === undefined) {
      HiLog.e(TAG, 'resultSet invalid.');
      return '';
    }
    let cl = resultSet.getString(resultSet.getColumnIndex(OldDBData.part.cl));
    let data = resultSet.getString(resultSet.getColumnIndex(OldDBData.part.Data));
    let name = resultSet.getString(resultSet.getColumnIndex(OldDBData.part.name));
    let dataFn = StringUtil.getPathTail(data)
    if (!StringUtil.isEmpty(dataFn)) {
      return dataFn;
    }
    if (!StringUtil.isEmpty(cl)) {
      return cl;
    }
    if (!StringUtil.isEmpty(name)) {
      return name;
    }
    return '';
  }

  private async queryPartInfo(context: common.ExtensionContext): Promise<void> {
    HiLog.e(TAG, `queryPartInfo start`)
    const partInfo = new rdb.RdbPredicates(DbConstants.OLD_PART_NAME);
    const rdbStore = await this.initDB(context, DbConstants.ClONE_DATABASE_NAME);
    if (rdbStore === undefined) {
      HiLog.e(TAG, `[queryPartInfo] failed : rdbStore === undefined`)
      return;
    }
    try{
      let failCount = 0;
      let successCount = 0;
      const queryPartColumn = [OldDBData.part.Id, OldDBData.part.ct,
        OldDBData.part.text, OldDBData.part.Data, OldDBData.part.cl, OldDBData.part.mid,
        OldDBData.part.name];
      const resultSet = await rdbStore.query(partInfo, queryPartColumn);
      if (resultSet == undefined || !resultSet.goToFirstRow()) {
        HiLog.w(TAG, 'no raw part found.');
        return;
      }
      const count = resultSet.rowCount;
      do{
        const mid = resultSet.getLong(resultSet.getColumnIndex(OldDBData.part.mid));
        const partId = resultSet.getLong(resultSet.getColumnIndex(OldDBData.part.Id));
        const ct = resultSet.getString(resultSet.getColumnIndex(OldDBData.part.ct));
        const partContent = resultSet.getString(resultSet.getColumnIndex(OldDBData.part.text));
        const data = resultSet.getString(resultSet.getColumnIndex(OldDBData.part.Data));
        let isSuccess = false;
        let fileDir = context.filesDir;
        let prefix = this.version.startsWith(DbConstants.ARD_CLONE_VERSION_NAME) ?
          mid?.toString() + '_' + partId?.toString() + '_' : '';
        HiLog.i(TAG, 'filesDir name:' + fileDir);
        if (fileDir) {
          let location = fileDir + '/';
          let fileName = prefix + this.getPartFileName(resultSet);
          if (ct === 'application/smil') {
            location = location + 'smil_' + mid?.toString() + '_' + partId?.toString() + '.xml';
            FileUtil.writeSmilToSandBox(partContent, location, mid, partId);
          } else if (ct === 'text/plain') {
            location = location + fileName;
            isSuccess = this.doDataStorage(location, partContent);
          } else if (ct === 'text/x-vCard' || ct === 'text/x-vcard') {
            location = location + StringUtil.getPathTail(data);
            isSuccess = await this.processLocation(partId, rdbStore, isSuccess, location);
          } else {
            location = location + fileName;
            isSuccess = await this.processLocation(partId, rdbStore, isSuccess, location);
          }
        }
        isSuccess ? successCount++ : failCount++;
      } while (resultSet.goToNextRow());
      resultSet.close();
      HiLog.i(TAG, 'pdu Total Migrations count: ' + count + ',Successful Migrations successCount: ' + successCount + 'Failed Migrations failCount: ' + failCount);
    } catch (error) {
      HiLog.w(TAG, 'query partInfo error : ' + JSON.stringify(error));
    }
  }

  public async handleSmilFile(context: common.ExtensionContext): Promise<void> {
    HiLog.w(TAG, `handleSmilFile start`)
    const partInfo = new rdb.RdbPredicates(DbConstants.PART_NAME);
    const rdbStore = await this.initDB(context, DbConstants.UPGRADE_DATABASE_NAME);
    if (rdbStore === undefined) {
      HiLog.e(TAG, `[handleSmilFile] failed : rdbStore === undefined`)
      return;
    }
    try{
      let failCount = 0;
      let successCount = 0;
      const queryPartColumn = [OldDBData.part.Id, OldDBData.part.ct,
        OldDBData.part.text, OldDBData.part.mid];
      const resultSet = await rdbStore.query(partInfo, queryPartColumn);
      if (resultSet == undefined || !resultSet.goToFirstRow()) {
        HiLog.w(TAG, 'handleSmilFile no raw part found.');
        return;
      }
      const count = resultSet.rowCount;
      do{
        const mid = resultSet.getLong(resultSet.getColumnIndex(OldDBData.part.mid));
        const partId = resultSet.getLong(resultSet.getColumnIndex(OldDBData.part.Id));
        const ct = resultSet.getString(resultSet.getColumnIndex(OldDBData.part.ct));
        const partContent = resultSet.getString(resultSet.getColumnIndex(OldDBData.part.text));
        let isSuccess = false;
        let fileDir = context.filesDir;
        HiLog.i(TAG, 'filesDir name:' + fileDir);
        if (fileDir) {
          let location = fileDir + '/';
          if (ct === 'application/smil') {
            location = location + 'smil_' + mid?.toString() + '_' + partId?.toString() + '.xml';
            FileUtil.writeSmilToSandBox(partContent, location, mid, partId);
          }
        }
        isSuccess ? successCount++ : failCount++;
      } while (resultSet.goToNextRow());
      resultSet.close();
      HiLog.i(TAG, 'handleSmilFile pdu Total Migrations count: ' + count + ',Successful Migrations successCount: ' +
        successCount + 'Failed Migrations failCount: ' + failCount);
    } catch (error) {
      HiLog.w(TAG, 'handleSmilFile error : ' + JSON.stringify(error));
    }
  }

  private async processLocation(partId: number, rdbStore: rdb.RdbStore, isSuccess: boolean, location: string) {
    try {
      const filesInfo = new rdb.RdbPredicates(DbConstants.OLD_FILES_NAME);
      filesInfo.equalTo(OldDBData.files.Id, partId);
      const canResultSet = await rdbStore.query(filesInfo, [OldDBData.files.fileData]);
      if (canResultSet != undefined && canResultSet.goToFirstRow()) {
        const fileData: Uint8Array = canResultSet.getBlob(canResultSet.getColumnIndex(OldDBData.files.fileData));
        isSuccess = this.doDataStorage(location, fileData.buffer);
      }
      canResultSet.close();
    } catch (e) {
      HiLog.w(TAG, 'query file error : ' + JSON.stringify(e));
    }
    return isSuccess;
  }

  private doDataStorage(path: string, data: ArrayBuffer | string): boolean {
    try {
      const writeFile = fs.openSync(path, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      fs.writeSync(writeFile.fd, data);
      HiLog.w(TAG, 'do fileStorage end');
      fs.closeSync(writeFile);
      return true;
    }catch (e) {
      HiLog.w(TAG, 'do fileStorage error : ' + JSON.stringify(e));
      return false;
    }
  }
}
export const copyDbDataHelper: CopyDbDataHelper = new CopyDbDataHelper();