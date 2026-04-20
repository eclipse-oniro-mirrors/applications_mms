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
import MmsContactProxy from '../proxy/MmsContactProxy';
import MmsContactProxyInterface from '../interface/MmsContactInterface';
import MmsContactClientProxy from '../proxy/MmsContactClientProxy';

const TAG = 'MmsContactStub';

export default abstract class MmsContactStub extends rpc.RemoteObject
  implements MmsContactProxyInterface {
  private static readonly DESCRIPTOR: string = 'idl.MmsContactService';
  private static readonly COMMAND_NOTICE_DELETE_CONTACT_ID = 3;

  constructor(des: string) {
    super(des);
  }

  asObject(): rpc.IRemoteObject {
    return this;
  }

  public static asInterface(object: rpc.IRemoteObject): MmsContactProxyInterface {
    let result: MmsContactProxyInterface;
    if (object == null) {
      HiLog.e(TAG, 'asInterface object is null');
      return new MmsContactClientProxy(object);
    }
    let broker: rpc.IRemoteBroker = object.getLocalInterface(MmsContactStub.DESCRIPTOR);
    if (broker != null) {
      result = broker as MmsContactProxyInterface;
    } else {
      result = new MmsContactClientProxy(object);
    }
    return result;
  }

  async onRemoteMessageRequest(code: number, data: rpc.MessageSequence,
    reply: rpc.MessageSequence, option: rpc.MessageOption): Promise<boolean> {
    HiLog.i(TAG, 'onRemoteMessageRequest called, code : ' + code);
    if (MmsContactStub.DESCRIPTOR !== data.readInterfaceToken()) {
      HiLog.e(TAG, 'DESCRIPTOR unmatched.');
      return false;
    }
    switch (code) {
      case MmsContactStub.COMMAND_NOTICE_DELETE_CONTACT_ID: {
        let delIdArr = data.readStringArray();
        try {
          let callbackVar = new MmsContactProxy(data.readRemoteObject());
          this.noticeToUpdateDeletedContact(delIdArr, callbackVar);
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

  abstract noticeToUpdateDeletedContact(delIdArr: string[], callback: ResultRPCCallback): void;
}