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
import ResultRPCCallback from '../../callback/ResultRPCCallback';
import rpc from '@ohos.rpc';
import HiLog from '../../../utils/HiLog';

const TAG = 'MmsContactDataProxy'

export default class MmsContactDataProxy implements ResultRPCCallback {
  private static readonly DESCRIPTOR: string = 'idl.SpamShieldMmsService';
  private static readonly COMMAND_ON_RESULT = 2;
  private proxy: rpc.IRemoteObject;

  public constructor(proxy: rpc.IRemoteObject) {
    this.proxy = proxy;
  }

  public asObject(): rpc.IRemoteObject {
    return this.proxy;
  }

  onResult(errCode: number, result: string): void {
    let option = new rpc.MessageOption();
    let data = rpc.MessageSequence.create();
    let reply = rpc.MessageSequence.create();
    data.writeInterfaceToken(MmsContactDataProxy.DESCRIPTOR);
    data.writeInt(errCode);
    data.writeString(result);
    this.proxy.sendMessageRequest(MmsContactDataProxy.COMMAND_ON_RESULT, data, reply, option)
      .then((result: rpc.RequestResult) => {
      if (result.errCode !== 0) {
        HiLog.e(TAG, 'sendMessageRequest failed, errCode: ' + result.errCode);
      }
    }).catch((e: Error) => {
      HiLog.e(TAG, 'sendMessageRequest failed, message: ' + e.message);
    }).finally(() => {
      data.reclaim();
      reply.reclaim();
    });
  }
}