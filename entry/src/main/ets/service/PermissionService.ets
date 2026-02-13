/**
 * Copyright (c) 2023 Huawei Device Co., Ltd.
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

import abilityAccessCtrl, { Permissions } from '@ohos.abilityAccessCtrl';
import bundleManager from '@ohos.bundle.bundleManager';
import HiLog from '../utils/HiLog';
import commonData from '../data/commonData';
import { GlobalContext } from '../MainAbility/GlobalHelper';
import myCommon from '@ohos.app.ability.common';

const TAG = 'PermissionService';
let appFlags = bundleManager.ApplicationFlag.GET_APPLICATION_INFO_WITH_PERMISSION;

class PermissionService {
  getAppAccessToken(callback: Function) {
    bundleManager.getApplicationInfo(commonData.STR.BUNDLE_NAME, appFlags, (err, data) => {
      if (err) {
        HiLog.e(TAG, 'getApplicationInfo failed: %{public}s' + err.message);
        callback('');
      } else {
        HiLog.i(TAG, 'getApplicationInfo successfully');
        callback(data.accessTokenId);
      }
    });
  }

  checkAccessToken(permissionName: Permissions, callback: Function) {
    let atManager = abilityAccessCtrl.createAtManager();
    this.getAppAccessToken((tokenID: number) => {
      let hasPermission = atManager.verifyAccessTokenSync(tokenID, permissionName);
      HiLog.i(TAG, `getAppAccessToken success, hasPermission---->${JSON.stringify(hasPermission)}`);
      if (hasPermission === -1) {
        callback(false);
      } else {
        callback(true);
      }
    });
  }

  initPermission(permissionName: Permissions, callback: Function) {
    let atManager = abilityAccessCtrl.createAtManager();
    let permissions: Array<Permissions> = [];
    permissions.push(permissionName);
    let context = (GlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext);
    atManager.requestPermissionsFromUser(context, permissions, (err, data) => {
      if (err) {
        HiLog.i(TAG, `requestPermissionsFromUser fail, err->${JSON.stringify(err)}`);
        callback(false);
      } else {
        HiLog.i(TAG, 'requestPermissionsFromUser success');
        // -1 If the permission is not authorized, the permission has been set. You need to modify the permission in Settings.
        // 0 Authorized.
        // 2 If the request is not authorized, the request is invalid.
        if (data?.authResults && data?.authResults.length > 0) {
          if (data?.authResults[0] === 0) {
            callback(true);
          } else {
            callback(false);
          }
        } else {
          callback(false);
        }
      }
    });
  }
}

export default new PermissionService();