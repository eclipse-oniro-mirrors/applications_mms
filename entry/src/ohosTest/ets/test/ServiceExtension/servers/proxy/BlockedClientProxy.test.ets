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
import { describe, expect, it, MockKit } from '@ohos/hypium';
import { rpc } from '@kit.IPCKit';
import BlockedClientProxy from '../../../../../../main/ets/ServiceExtension/servers/proxy/BlockedClientProxy';
import HiLog from '../../../../../../main/ets/utils/HiLog';

export default function blockedClientProxyTest() {
  describe('blockedClientProxyTest', () => {

    it('blockedClientProxyTest_asObject', 0, () => {
      let proxy: rpc.IRemoteObject = {} as rpc.IRemoteObject;
      let result: rpc.IRemoteObject = new BlockedClientProxy(proxy).asObject();

      expect(JSON.stringify(result)).assertEqual('{}');
    })

    it('blockedClientProxyTest_restoreBlockedMessage', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.e);
      new BlockedClientProxy(null).restoreBlockedMessage([], {
        onResult: (errCode: number, result: string): void => {
          throw new Error('Function not implemented.');
        },
        asObject: (): rpc.IRemoteObject => {
          throw new Error('Function not implemented.');
        }
      });
      mocker.verify('e', ['BlockedClientProxy', 'restoreBlockedMessage proxy is null']).never();
      mocker.clear(HiLog);
    })
  })
}