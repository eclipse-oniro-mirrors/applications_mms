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

import HiLog from '../utils/HiLog';
import { osAccount } from '@kit.BasicServicesKit';
import { call } from '@kit.TelephonyKit';

const TAG: string = 'UserUtil';

class UserUtil {

  private PRIMARY_ACCOUNT: number = 100;

  //判断是主用户还是子用户
  public async isPrimaryAccount() {
    try {
      const accountManager = osAccount.getAccountManager();
      if (accountManager === null || accountManager === undefined) {
        HiLog.e(TAG, 'getAccountManager is null.');
        return true;
      }
      let accountId: number = await accountManager.getOsAccountLocalId();
      return accountId === this.PRIMARY_ACCOUNT;
    } catch (err) {
      HiLog.e(TAG, 'getOsAccountLocalId: ' + JSON.stringify(err));
    }
    return true;
  }

  //判断是主用户还是子用户
  public async isMainUser(): Promise<boolean> {
    HiLog.i(TAG, 'isMainUser hasVoiceCapability : ' + call.hasVoiceCapability() + ' , isPrimaryAccount : ' + await this.isPrimaryAccount());
    if (call.hasVoiceCapability() && await this.isPrimaryAccount()) {
       return true;
    }
    return false;
  }

  /**
   * 当前用户类型是否为隐私空间用户
   *
   * @returns
   */
  public async isPrivateAccount() {
    let accountType = await this.getAccountType();
    return accountType === osAccount.OsAccountType.PRIVATE;
  }

  /**
   * 获取当前用户类型
   *
   * @returns
   */
  public async getAccountType(): Promise<osAccount.OsAccountType> {
    let accountManager: osAccount.AccountManager = osAccount.getAccountManager();
    let accountType: osAccount.OsAccountType = -1;
    if (accountManager === null || accountManager === undefined) {
      HiLog.e(TAG, 'getAccountType getAccountManager is null.');
      return accountType;
    }
    try {
      accountType = await accountManager.getOsAccountType();
      HiLog.w(TAG, `getAccountType is:${accountType}`);
    } catch (err) {
      HiLog.e(TAG, `getAccountType failed,code:${err?.code},msg:${err?.message}`);
    }
    return accountType;
  }
}

// Singleton
export default new UserUtil();