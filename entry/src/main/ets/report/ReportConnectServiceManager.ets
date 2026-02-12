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

import HiLog from '../utils/HiLog';
import { UcsRequestParam } from './common/ReportParams';
import { common } from '@kit.AbilityKit';
import IdlServiceProxy from './hsdr/model/IdlServiceProxy';
import { ucsCallback } from './hsdr/interface/IdlService';
import IConnectCloudResultCallback from './hsdr/interface/IConnectCloudResultCallback';
import { rpc } from '@kit.IPCKit';
import { RequestParameter } from './request/RequestParameter';
import ReportConstant from './common/ReportConstant';
import bundleManager from '@ohos.bundle.bundleManager';
import { BusinessError } from '@kit.BasicServicesKit';

const TAG = 'ReportConnectServiceManager';

export default class ReportConnectServiceManager {
  private static instance: ReportConnectServiceManager;
  private mConnectionId: number = -1;
  private mIdlServiceProxy: IdlServiceProxy | undefined = undefined;
  private mContext: common.UIAbilityContext | undefined = undefined;

  private constructor() {
  }

  /**
   * get ReportConnectServiceManager instance
   *
   * @returns { ReportConnectServiceManager } returns ReportConnectServiceManager instance
   */
  public static getInstance(): ReportConnectServiceManager {
    if (!ReportConnectServiceManager.instance) {
      ReportConnectServiceManager.instance = new ReportConnectServiceManager();
    }
    return ReportConnectServiceManager.instance;
  }

  /**
   * init ReportConnectServiceManager.
   *
   * @param { common.UIAbilityContext } context - the context
   */
  public async initReportConnectServiceManager(context: common.UIAbilityContext): Promise<void> {
    this.mContext = context;
  }

  private startConnectService(remoteCallback: (remote: rpc.IRemoteObject) => void): void {
    let options: common.ConnectOptions = {
      onConnect(elementName: bundleManager.ElementName, remote: rpc.IRemoteObject) {
        if (remote === null) {
          HiLog.e(TAG, `[startConnectService] onConnect remote is null`);
          return;
        }
        remoteCallback(remote);
      },
      onDisconnect(elementName: bundleManager.ElementName) {
        HiLog.i(TAG, `[startConnectService] onDisconnect elementName: ${elementName}`);
      },
      onFailed(code: number) {
        HiLog.e(TAG, `[startConnectService] onFailed code: ${code}`);
      }
    };
    if (this.mContext) {
      this.mConnectionId = this.mContext.connectServiceExtensionAbility(ReportConstant.HSDR_SERVICE_WANT, options);
    }
  }

  /**
   * disconnect the serviceExtension of hsdr
   */
  public disconnectAbility(): void {
    HiLog.i(TAG, `disconnectAbility connectionId: ${this.mConnectionId}`);
    this.mContext?.disconnectServiceExtensionAbility(this.mConnectionId, (err: BusinessError, data: void) => {
      if (err.code === 0) {
        HiLog.i(TAG, 'disconnect ServiceExtension success');
      } else {
        HiLog.e(TAG, `disconnect ServiceExtension error: ${err.message}`);
      }
    });
    this.mIdlServiceProxy = undefined;
  }

  /**
   * start to request ucs
   *
   * @param { number } context - methodType the type of method, encryption or signature
   * @param { string } data - the encoded data
   * @param { string } serviceName - the service name
   * @param { string } requestId - the request id
   * @param { ucsCallback } callback - the callback of the request result
   */
  public startRequestUcs(methodType: number, data: string, serviceName: string, requestId: string,
    callback: ucsCallback): void {
    HiLog.i(TAG, `startRequestUcs methodType = ${methodType}`);
    if (this.mIdlServiceProxy === undefined) {
      this.startConnectService((remote: rpc.IRemoteObject) => {
        this.mIdlServiceProxy = new IdlServiceProxy(remote);
        this.startRequestUcsInner(methodType, data, serviceName, requestId, callback);
      });
    } else {
      this.startRequestUcsInner(methodType, data, serviceName, requestId, callback);
    }
  }

  /**
   * start to connect cloud
   *
   * @param { string } serviceName - the service name
   * @param { string } requestId - the request id
   * @param { string } requestJsonStr - use the required JSON character string.
   * @param { RequestParameter } request - parameter set required by the request
   */
  public startConnectCloud(serviceName: string, requestId: string, requestJsonStr: string,
    request: RequestParameter): void {
    HiLog.i(TAG, 'startConnectCloud');
    if (this.mIdlServiceProxy === undefined) {
      this.startConnectService((remote: rpc.IRemoteObject) => {
        this.mIdlServiceProxy = new IdlServiceProxy(remote);
        this.startConnectCloudInner(serviceName, requestId, requestJsonStr, request);
      });
    } else {
      this.startConnectCloudInner(serviceName, requestId, requestJsonStr, request);
    }
  }

  private startRequestUcsInner(methodType: number, data: string, serviceName: string, requestId: string,
    callback: ucsCallback) {
    HiLog.i(TAG, 'startRequestUcsInner');
    let ucsParam: UcsRequestParam = {
      method: methodType,
      data: data
    }
    this.mIdlServiceProxy?.requestUcs(serviceName, requestId, [JSON.stringify(ucsParam)],
      (errCode: number, result: string[]) => {
        callback(errCode, result);
      });
  }

  private startConnectCloudInner(serviceName: string, requestId: string, requestJsonStr: string,
    request: RequestParameter): void {
    HiLog.i(TAG, 'startConnectCloudInner');
    this.mIdlServiceProxy?.cloudConnect(serviceName, requestId, [requestJsonStr],
      request.connectCloudCallback as IConnectCloudResultCallback);
  }
}