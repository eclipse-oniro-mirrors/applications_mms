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
import { connection } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';

export default class JudgeNetWork {
  public static netConnection: connection.NetConnection | undefined = undefined;
  private static sInstance: JudgeNetWork;

  static getInstance() {
    if (JudgeNetWork.sInstance == null) {
      JudgeNetWork.sInstance = new JudgeNetWork();
    }
    return JudgeNetWork.sInstance;
  }


  public judgeHasNet(): boolean {
    try { // 获取当前网络连接
      let netHandle = connection.getDefaultNetSync();

      // 0-100 为系统预留的连接
      if (!netHandle || netHandle.netId < 100) {
        return false;
      }

      // 获取连接的属性
      let netCapability = connection.getNetCapabilitiesSync(netHandle);
      let cap = netCapability.networkCap;
      // instrument ignore if
      if (!cap) {
        return false;
      }

      for (let em of cap) {
        // instrument ignore if
        if (connection.NetCap.NET_CAPABILITY_VALIDATED === em) {
          return true;
        }
      }
    } catch (e) {
      let err = e as BusinessError;
      console.info('get netInfo error ：' + JSON.stringify(err));
    }
    return false;
  }

}