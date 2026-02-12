/**
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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

import { abilityAccessCtrl, Permissions } from '@kit.AbilityKit';
import { bundleManager } from '@kit.AbilityKit';
import commonData from '../data/commonData';
import HiLog from './HiLog';
import DotUtil from './MmsDot/DotUtils';

const TAG: string = 'AccessCtrlUtils';

export class AccessCtrlUtils {
  public static checkReadContactsAccessToken(): void {
    try {
      if (!AccessCtrlUtils.checkAccessToken('ohos.permission.READ_CONTACTS')) {
        // 确认无权限，增加打点
        let reportParams: Record<string, string> = {
          'failReason' : 'ohos.permission.READ_CONTACTS error'
        };
        DotUtil.getInstance().reportSendMessageCommon(reportParams);
      }
    } catch (err) {
      // 异常不用打点
      HiLog.w(TAG, `checkReadContactsAccessToken catch error msg: ${err.message}, code: ${err.code}`);
    }
  }

  private static checkAccessToken(permissionName: Permissions): boolean {
      let atManager = abilityAccessCtrl.createAtManager();
      let info = bundleManager.getApplicationInfoSync(commonData.STR.BUNDLE_NAME,
        bundleManager.ApplicationFlag.GET_APPLICATION_INFO_WITH_PERMISSION)
      let hasPermission = atManager.verifyAccessTokenSync(info.accessTokenId, permissionName);
      HiLog.w(TAG, `checkAccessToken ${hasPermission}`);
      return hasPermission === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED;
  }
}