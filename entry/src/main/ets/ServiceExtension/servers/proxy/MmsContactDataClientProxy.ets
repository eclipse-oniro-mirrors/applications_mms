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
import ResultRPCCallback from '../../callback/ResultRPCCallback';
import MmsContactDataInterface from '../interface/MmsContactDataInterface';

const TAG = 'MmsContactDataClientProxy'

export default class MmsContactDataClientProxy implements MmsContactDataInterface {
  public static readonly DESCRIPTOR: string = 'idl.SpamShieldMmsService';
  public static readonly COMMAND_QUERY_BLOCK_MESSAGE_NUM = 2;
  public static readonly COMMAND_QUERY_PREF_BLOCK_MESSAGE_NUM = 3;
  private proxy: rpc.IRemoteObject;

  public constructor(proxy: rpc.IRemoteObject) {
    this.proxy = proxy;
  }

  public asObject(): rpc.IRemoteObject {
    return this.proxy;
  }

  queryBlockedMessageNum(phoneNumbers: string[], callback: ResultRPCCallback): void {
    HiLog.i(TAG, 'queryBlockedMessageNum start');
    if (this.proxy == null) {
      HiLog.e(TAG, 'restoreBlockedMessage proxy is null');
      return;
    }
    let option = new rpc.MessageOption();
    let data = rpc.MessageSequence.create();
    let reply = rpc.MessageSequence.create();
    data.writeInterfaceToken(MmsContactDataClientProxy.DESCRIPTOR);
    data.writeStringArray(phoneNumbers);
    data.writeRemoteObject(callback.asObject());
    this.proxy.sendMessageRequest(MmsContactDataClientProxy.COMMAND_QUERY_BLOCK_MESSAGE_NUM, data, reply, option)
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

  queryPrefBlockedMessageNum(phoneNumbers: string[], callback: ResultRPCCallback): void {
    HiLog.i(TAG, 'queryPrefBlockedMessageNum start');
    if (this.proxy == null) {
      HiLog.e(TAG, 'restoreBlockedMessage proxy is null');
      return;
    }
    let option = new rpc.MessageOption();
    let data = rpc.MessageSequence.create();
    let reply = rpc.MessageSequence.create();
    data.writeInterfaceToken(MmsContactDataClientProxy.DESCRIPTOR);
    data.writeStringArray(phoneNumbers);
    data.writeRemoteObject(callback.asObject());
    this.proxy.sendMessageRequest(MmsContactDataClientProxy.COMMAND_QUERY_PREF_BLOCK_MESSAGE_NUM, data, reply, option)
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

