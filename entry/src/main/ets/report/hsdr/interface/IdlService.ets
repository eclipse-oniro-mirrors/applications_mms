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

import rpc from '@ohos.rpc';
import IConnectCloudResultCallback from './IConnectCloudResultCallback';

export default interface IdlService extends rpc.IRemoteBroker {
  /**
   * cloud connect.
   *
   * @param { string } serviceName - the service name of the request
   * @param { string } requestId - the requestId of the request
   * @param { string[] } requestJsonStr - the request json string
   * @param { IConnectCloudResultCallback } connectCloudResultCallback - callback for notifying applications
   */
  cloudConnect(serviceName: string, requestId: string, requestJsonStr: string[],
    connectCloudResultCallback: IConnectCloudResultCallback): void;

  /**
   * request to ucs.
   *
   * @param { string } serviceName - the service name of the request
   * @param { string } requestId - the requestId of the request
   * @param { string[] } requestJsonStr - the request json string
   * @param { ucsCallback } callback - callback for notifying applications
   */
  requestUcs(serviceName: string, requestId: string, requestJsonStr: string[], callback: ucsCallback): void;
}

export type connectCloudCallback = (errCode: number) => void;

export type ucsCallback = (errCode: number, result: string[]) => void;