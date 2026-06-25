/**
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import { connection } from '@kit.NetworkKit';
import { BusinessError } from '@ohos.base';
import HiLog from './HiLog';

const TAG = 'NetUtils';

export class NetUtils {
  constructor() {
  }

  private static getNetCapabilities = async () => {
    try {
      let netHandle: connection.NetHandle | void =
        await connection.getDefaultNet().catch((err: BusinessError) => {
          HiLog.e(TAG, 'getNetCapabilities: getDefaultNet failed errCode:' + err.code + ',errMessage:' + err.message);
        });
      if (!netHandle || netHandle.netId === 0) {
        HiLog.iw(TAG, 'getNetCapabilities: netHandle is empty or no default network');
        return;
      }
      let netCapabilities: connection.NetCapabilities | void = await connection.getNetCapabilities(netHandle)
        .catch((err: BusinessError) => {
          HiLog.e(TAG, 'getNetCapabilities: getNetCapabilities failed errCode:' + err.code + ',errMessage:' +
          err.message);
        });
      return netCapabilities;
    } catch (e) {
      HiLog.e(TAG, `getNetCapabilities: failed, error: ${JSON.stringify(e)}`);
      return;
    }
  }

  public static async isConnectWifiNet() {
    try {
      const netCapabilities = await NetUtils.getNetCapabilities();
      if (!netCapabilities) {
        return false;
      }

      if (netCapabilities.bearerTypes.includes(connection.NetBearType.BEARER_WIFI) &&
      netCapabilities.networkCap &&
      netCapabilities.networkCap.includes(connection.NetCap.NET_CAPABILITY_VALIDATED)) {
        return true;
      }
      return false;
    } catch (e) {
      HiLog.e(TAG, `isConnectWifiNet failed, error: ${JSON.stringify(e)}`);
      return false;
    }
  }

  public static getNetConnectType = async (): Promise<'wifiNet' | 'cellularNet' | 'otherNet' | 'noNet'> => {
    const netCapabilities = await NetUtils.getNetCapabilities();
    if (!netCapabilities || !netCapabilities.bearerTypes || !netCapabilities.networkCap) {
      return 'noNet';
    }

    if (netCapabilities.networkCap.includes(connection.NetCap.NET_CAPABILITY_VALIDATED)) {
      if (netCapabilities.bearerTypes.includes(connection.NetBearType.BEARER_WIFI)) {
        return 'wifiNet';
      } else if (netCapabilities.bearerTypes.includes(connection.NetBearType.BEARER_CELLULAR)) {
        return 'cellularNet';
      } else {
        return 'otherNet';
      }
    } else {
      return 'noNet';
    }
  }

  public static isConnectWifiNetSync(): boolean {
    return NetUtils.isConnectNetSync(connection.NetBearType.BEARER_WIFI);
  }

  public static isConnectCellularNetSync(): boolean {
    return NetUtils.isConnectNetSync(connection.NetBearType.BEARER_CELLULAR);
  }

  private static isConnectNetSync(netBearType: connection.NetBearType): boolean {
    try {
      let netHandle: connection.NetHandle | void =
        connection.getDefaultNetSync();
      if (!netHandle || netHandle.netId === 0) {
        HiLog.i(TAG, 'isConnectWifiNet netHandle is empty or no default network');
        return false;
      }
      let netCapabilities: connection.NetCapabilities | void = connection.getNetCapabilitiesSync(netHandle);
      if (!netCapabilities) {
        return false;
      }
      if (netCapabilities.bearerTypes.includes(netBearType) &&
      netCapabilities.networkCap &&
      netCapabilities.networkCap.includes(connection.NetCap.NET_CAPABILITY_VALIDATED)) {
        return true;
      }
      return false;
    } catch (e) {
      HiLog.e(TAG, `isConnectWifiNet failed, error: ${JSON.stringify(e)}`);
      return false;
    }
  }

  public static async hasValidatedNet() {
    try {
      let data = await connection.getAllNets()
        .catch((err: BusinessError) => {
          HiLog.e(TAG, 'hasValidatedNet getAllNets failed errCode:' + err.code + ',errMessage:' + err.message);
        });
      if (!data || data.length === 0) {
        return false;
      }
      let itemNumber: Set<connection.NetHandle> = new Set(data);
      let dataNumber: connection.NetHandle[] = Array.from(itemNumber.values());
      for (let i = 0; i < dataNumber.length; i++) {
        let netCapabilities = connection.getNetCapabilitiesSync(dataNumber[i]);
        if (netCapabilities?.networkCap &&
          netCapabilities.networkCap.indexOf(connection.NetCap.NET_CAPABILITY_VALIDATED) > -1) {
          return true;
        }
      }
      return false;
    } catch (e) {
      HiLog.e(TAG, `hasValidatedNet failed error:${JSON.stringify(e)}`);
      return false;
    }
  }
}
