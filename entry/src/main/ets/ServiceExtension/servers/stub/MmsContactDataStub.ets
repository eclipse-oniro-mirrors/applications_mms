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
import MmsContactDataProxy from '../proxy/MmsContactDataProxy';
import MmsContactDataProxyInterface from '../interface/MmsContactDataInterface';
import MmsContactDataClientProxy from '../proxy/MmsContactDataClientProxy';

const TAG = 'MmsContactDataStub';

export default abstract class MmsContactDataStub extends rpc.RemoteObject
  implements MmsContactDataProxyInterface {
  private static readonly DESCRIPTOR: string = 'idl.SpamShieldMmsService';
  private static readonly COMMAND_QUERY_BLOCK_MESSAGE_NUM = 2;
  private static readonly COMMAND_QUERY_PREF_BLOCK_MESSAGE_NUM = 3;

  constructor(des: string) {
    super(des);
  }

  asObject(): rpc.IRemoteObject {
    return this;
  }

  public static asInterface(object: rpc.IRemoteObject): MmsContactDataProxyInterface {
    let result: MmsContactDataProxyInterface;
    if (object == null) {
      HiLog.e(TAG, 'asInterface object is null');
      return new MmsContactDataClientProxy(object);
    }
    let broker: rpc.IRemoteBroker = object.getLocalInterface(MmsContactDataStub.DESCRIPTOR);
    if (broker != null) {
      result = broker as MmsContactDataProxyInterface;
    } else {
      result = new MmsContactDataClientProxy(object);
    }
    return result;
  }

  async onRemoteMessageRequest(code: number, data: rpc.MessageSequence,
    reply: rpc.MessageSequence, option: rpc.MessageOption): Promise<boolean> {
    HiLog.i(TAG, 'onRemoteMessageRequest called, code : ' + code);
    if (MmsContactDataStub.DESCRIPTOR !== data.readInterfaceToken()) {
      HiLog.e(TAG, 'DESCRIPTOR unmatched.');
      return false;
    }
    switch (code) {
      case MmsContactDataStub.COMMAND_QUERY_BLOCK_MESSAGE_NUM: {
        let phoneNumbers: string[] = data.readStringArray();
        try {
          let callbackVar = new MmsContactDataProxy(data.readRemoteObject());
          this.queryBlockedMessageNum(phoneNumbers, callbackVar);
        } catch (e) {
          HiLog.i(TAG, `readRemoteObject error. msg: ${e.message}, code: ${e.code}`);
          return false;
        }
        return true;
      }
      case MmsContactDataStub.COMMAND_QUERY_PREF_BLOCK_MESSAGE_NUM: {
        let phoneNumbers: string[] = data.readStringArray();
        try {
          let callbackVar = new MmsContactDataProxy(data.readRemoteObject());
          this.queryPrefBlockedMessageNum(phoneNumbers, callbackVar);
        } catch (e) {
          HiLog.i(TAG, `readRemoteObject error. msg: ${e.message}, code: ${e.code}`);
          return false;
        }
        return true;
      }
      default: {
        HiLog.e(TAG, 'invalid request code: ' + code);
        break;
      }
    }
    return false;
  }

  abstract queryBlockedMessageNum(phoneNumbers: string[], callback: ResultRPCCallback): void;

  abstract queryPrefBlockedMessageNum(phoneNumbers: string[], callback: ResultRPCCallback): void;
}