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
import GrantInterface from '../interface/MmsUriGrantInterface';
import MmsUriGrantServiceProxy from '../proxy/MmsUriGrantServiceProxy';

const TAG = 'MmsUriGrantStub';

export default abstract class MmsUriGrantStub extends rpc.RemoteObject implements GrantInterface {
  private static readonly DESCRIPTOR: string = 'idl.PrivacyCenterMmsService';

  public static readonly COMMAND_GRANT_URI_PERMISSION = 1;

  constructor(des: string) {
    super(des);
  }

  asObject(): rpc.IRemoteObject {
    return this;
  }

  async onRemoteMessageRequest(code: number, data: rpc.MessageSequence,
    reply: rpc.MessageSequence, option: rpc.MessageOption): Promise<boolean> {
    HiLog.i(TAG, 'onRemoteMessageRequest called, code : ' + code);
    try {
      if (MmsUriGrantStub.DESCRIPTOR !== data.readInterfaceToken()) {
        HiLog.e(TAG, 'DESCRIPTOR unmatched.');
        return false;
      }
      switch (code) {
        case MmsUriGrantStub.COMMAND_GRANT_URI_PERMISSION: {
          let uriArray = data.readStringArray();
          let callbackVar = new MmsUriGrantServiceProxy(data.readRemoteObject());
          this.grantAccessAttachmentUrisPermission(uriArray, callbackVar);
          return true;
        }
        default: {
          HiLog.e(TAG, 'invalid request code: ' + code);
          break;
        }
      }
    } catch (err) {
      HiLog.e(TAG, 'onRemoteMessageRequest failed! err.code: ' + err?.code);
    }
    return false;
  }

  abstract grantAccessAttachmentUrisPermission(uriArray: Array<string>, callback: ResultRPCCallback): void;
}