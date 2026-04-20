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
import MmsContactInterface from '../interface/MmsContactInterface';

const TAG = 'MmsContactClientProxy'

export default class MmsContactClientProxy implements MmsContactInterface {
  public static readonly DESCRIPTOR: string = 'idl.MmsContactService';
  public static readonly COMMAND_NOTICE_DELETE_CONTACT_ID = 3;
  private proxy: rpc.IRemoteObject;

  public constructor(proxy: rpc.IRemoteObject) {
    this.proxy = proxy;
  }

  public asObject(): rpc.IRemoteObject {
    return this.proxy;
  }

  noticeToUpdateDeletedContact(delIdArr: string[], callback: ResultRPCCallback): void {
    if (this.proxy == null) {
      HiLog.e(TAG, 'restoreBlockedMessage proxy is null');
      return;
    }
    let option = new rpc.MessageOption();
    let data = rpc.MessageSequence.create();
    let reply = rpc.MessageSequence.create();
    data.writeInterfaceToken(MmsContactClientProxy.DESCRIPTOR);
    data.writeStringArray(delIdArr);
    data.writeRemoteObject(callback.asObject());
    this.proxy.sendMessageRequest(MmsContactClientProxy.COMMAND_NOTICE_DELETE_CONTACT_ID, data, reply, option)
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

