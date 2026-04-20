/**
 * Copyright (c) 2024-2024 Huawei Device Co., Ltd.
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
import wantConstant from '@ohos.app.ability.wantConstant';
import uriPermissionManager from '@ohos.application.uriPermissionManager';
import fileUri from '@ohos.file.fileuri';
import HiLog from '../../utils/HiLog';

const TAG = 'MmsUriGrantController';

export default class MmsUriGrantController {
  private static sInstance: MmsUriGrantController | undefined = undefined;

  static getInstance() {
    if (!MmsUriGrantController.sInstance) {
      MmsUriGrantController.sInstance = new MmsUriGrantController();
    }
    return MmsUriGrantController.sInstance;
  }

  public async grantUrisPermission(uriArray: Array<string>, targetBundleName: string): Promise<string[]> {
    let failedUriArray: string[] = [];
    if (uriArray === null || uriArray === undefined || uriArray.length === 0) {
      HiLog.e(TAG, 'grantUrisPermission uriArray is null or length is 0!');
      return failedUriArray;
    }

    for (let uri of uriArray) {
      try {
        let fileUriObject = new fileUri.FileUri(uri);
        let formatUri: string = fileUriObject.toString();
        if (formatUri.indexOf('*') > -1) {
          // 不支持授权到带*的路径，其一是文件名不支持带*，其二是授权到*可能会导致权限放大
          HiLog.i(TAG, `grantUriPermission fail, can not grant file has *`);
          failedUriArray.push(uri);
          continue;
        }
        await uriPermissionManager.grantUriPermission(formatUri, wantConstant.Flags.FLAG_AUTH_READ_URI_PERMISSION,
          targetBundleName);
      } catch (err) {
        HiLog.e(TAG, 'grantUrisPermission failed! err.code: ' + err?.code);
        failedUriArray.push(uri);
      }
    }
    return failedUriArray;
  }
}