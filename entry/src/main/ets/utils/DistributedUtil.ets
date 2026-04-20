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
import DeviceUtil from './DeviceUtil';
import HiLog from './HiLog';
import { osAccount } from '@kit.BasicServicesKit';
import common from '../data/commonData';

const TAG = 'DistributedUtil';

export default class DistributedUtil {
  /**
   * The distributed communication SMS supports the user space-level control interface.
   * The value false indicates that the control is not required,
   * and the value true indicates that the SMS can only be received but cannot be sent.
   * @returns
   */
  static async isOsAccountConstraintEnabled() {
    if (!DeviceUtil.isPC()) {
      return false;
    }
    try {
      const accountManager = osAccount.getAccountManager();
      let accountId: number = await accountManager.getOsAccountLocalId();
      const isOsAccountConstraintEnabled = await accountManager.isOsAccountConstraintEnabled(accountId,
        common.STR.CONSTRAINT_DISTRIBUTED_TRANSMISSION_OUTGOING);
      HiLog.i(TAG, `isOsAccountConstraintEnabled: ${isOsAccountConstraintEnabled}`);
      return isOsAccountConstraintEnabled;
    } catch (error) {
      HiLog.e(TAG, `isOsAccountConstraintEnabled exception: ${JSON.stringify(error)}`);
      return false;
    }
  }
}