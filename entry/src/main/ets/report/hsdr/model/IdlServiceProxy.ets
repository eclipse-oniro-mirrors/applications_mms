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
import HiLog from '../../../utils/HiLog';
import ReportConstant from '../../common/ReportConstant';
import IConnectCloudResultCallback from '../interface/IConnectCloudResultCallback'
import IdlService, { ucsCallback, } from '../interface/IdlService'

const TAG = 'IdlServiceProxy';

export default class IdlServiceProxy implements IdlService {
  private proxy: rpc.IRemoteObject;

  /**
   * request to ucs.
   *
   * @param { rpc.IRemoteObject } proxy - the remote object proxy
   */
  public constructor(proxy: rpc.IRemoteObject) {
    this.proxy = proxy;
  }

  cloudConnect(serviceName: string, requestId: string, requestJsonStr: string[],
    cloudConnectCallback: IConnectCloudResultCallback): void {
    HiLog.i(TAG, 'cloudConnect send message');
    let option: rpc.MessageOption = new rpc.MessageOption();
    let data: rpc.MessageSequence = rpc.MessageSequence.create();
    let reply: rpc.MessageSequence = rpc.MessageSequence.create();
    data.writeInterfaceToken(ReportConstant.SECURITY_DESCRIPTOR);
    data.writeString(serviceName);
    data.writeString(requestId);
    data.writeStringArray(requestJsonStr);
    data.writeRemoteObject(cloudConnectCallback.asObject());
    this.proxy.sendMessageRequest(ReportConstant.COMMAND_CLOUD_CONNECT, data, reply, option)
      .then((result: rpc.RequestResult) => {
        if (result.errCode !== 0) {
          HiLog.e(TAG, `cloudConnect sendMessageRequest failed, errCode: ${result.errCode}`);
        }
        HiLog.i(TAG, 'cloudConnect sendMessageRequest success');
      })
      .catch((e: Error) => {
        HiLog.e(TAG, `cloudConnect sendMessageRequest failed, message: ${e.message}`);
      })
      .finally(() => {
        data.reclaim();
        reply.reclaim();
      });
  }

  requestUcs(serviceName: string, requestId: string, requestJsonStr: string[], callback: ucsCallback) {
    HiLog.i(TAG, 'requestUcs: send message');
    let option: rpc.MessageOption = new rpc.MessageOption();
    let data: rpc.MessageSequence = new rpc.MessageSequence();
    let reply: rpc.MessageSequence = new rpc.MessageSequence();
    data.writeInterfaceToken(ReportConstant.SECURITY_DESCRIPTOR);
    data.writeString(serviceName);
    data.writeString(requestId);
    data.writeStringArray(requestJsonStr);
    this.proxy.sendMessageRequest(ReportConstant.COMMAND_UCS_REQUEST, data, reply, option)
      .then((result: rpc.RequestResult) => {
        HiLog.i(TAG, `requestUcs sendMessageRequest: ${result.errCode}`);
        if (result.errCode === 0) {
          let errCode: number = result.reply.readInt();
          let resp: string[] = result.reply.readStringArray();
          HiLog.i(TAG, `requestUcs sendMessage: ${errCode}, resp:${resp}`);
          callback(errCode, resp);
        }
      })
      .catch((e: Error) => {
        HiLog.e(TAG, `requestUcs sendMessageRequest failed, message: ${e.message}`);
      })
      .finally(() => {
        data.reclaim();
        reply.reclaim();
      });
  }

  /**
   * request to ucs.
   *
   * @returns { rpc.IRemoteObject } returns the remote object proxy
   */
  public asObject(): rpc.IRemoteObject {
    return this.proxy;
  }
}