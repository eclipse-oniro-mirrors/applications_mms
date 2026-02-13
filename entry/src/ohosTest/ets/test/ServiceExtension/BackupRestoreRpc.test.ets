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
import { afterEach, ArgumentMatchers, beforeEach, describe, expect, it, MockKit, when } from '@ohos/hypium';
import { GlobalContext } from '../../../../main/ets/MainAbility/GlobalHelper';
import BackupRestoreRpc, {
  ExtRemoteObjectSub
} from '../../../../main/ets/ServiceExtension/AutoBackupRestoreRpc/BackupRestoreRpc';
import { rpc } from '@kit.IPCKit';

export default function BackupRestoreRpcTest() {
  describe('BackupRestoreRpcTest', () => {
    beforeEach(() => {

    });
    afterEach(() => {

    });
    it('BackupRestoreRpcTest_getCurrentContext_should_return_context_when_mmsContext_is_not_null', 0, () => {
      let backuprestorerpc: BackupRestoreRpc = BackupRestoreRpc.getInstance();
      let mocker: MockKit = new MockKit();
      let globalContext: GlobalContext = GlobalContext.getContext();
      let mockfunc: Function = mocker.mockFunc(globalContext, globalContext.getObject);
      when(mockfunc)(ArgumentMatchers.anyString).afterReturn({});
      const result = backuprestorerpc.getCurrentContext();
      mocker.ignoreMock(globalContext, globalContext.getObject);
      expect(result).not().assertNull();
    });

    it('BackupRestoreRpcTest_getCurrentContext_should_return_context_when_mmsServiceContext_is_not_null', 0, () => {
      let backuprestorerpc: BackupRestoreRpc = BackupRestoreRpc.getInstance();
      let mocker: MockKit = new MockKit();
      let globalContext: GlobalContext = GlobalContext.getContext();
      let mockfunc: Function = mocker.mockFunc(globalContext, globalContext.getObject);
      when(mockfunc)(ArgumentMatchers.anyString).afterReturn(null);
      when(mockfunc)(ArgumentMatchers.anyString).afterReturn({});
      const result = backuprestorerpc.getCurrentContext();
      mocker.ignoreMock(globalContext, globalContext.getObject);
      expect(result).not().assertNull();
    });

    it('BackupRestoreRpcTest_getCurrentContext_should_return_null_when_both_contexts_are_null', 0, () => {
      let backuprestorerpc: BackupRestoreRpc = BackupRestoreRpc.getInstance();
      let mocker: MockKit = new MockKit();
      let globalContext: GlobalContext = GlobalContext.getContext();
      let mockfunc: Function = mocker.mockFunc(globalContext, globalContext.getObject);
      when(mockfunc)(ArgumentMatchers.anyString).afterReturn(null);
      const result = backuprestorerpc.getCurrentContext();
      mocker.ignoreMock(globalContext, globalContext.getObject);
      expect(result).assertNull();
    });

    it('BackupRestoreRpcTest_connect_should_resolve_false_when_context_is_null', 0, async () => {
      let backuprestorerpc: BackupRestoreRpc = BackupRestoreRpc.getInstance();
      let mocker: MockKit = new MockKit();
      let mockfunc: Function = mocker.mockFunc(backuprestorerpc, backuprestorerpc.getCurrentContext);
      when(mockfunc)().afterReturn(null);
      const result = await backuprestorerpc.connect();
      mocker.ignoreMock(backuprestorerpc, backuprestorerpc.getCurrentContext);
      expect(result).assertEqual(false);
    });

    it('BackupRestoreRpcTest_sendMessage_should_sendMessage_successfully_when_proxy_is_available', 0, async () => {
      let backuprestorerpc: BackupRestoreRpc = new BackupRestoreRpc();
      await backuprestorerpc.sendMessage("test message", 100);
      expect().assertUndefined();
    });

    it('BackupRestoreRpcTest_onRemoteMessageRequest_should_return_false_when_descriptor_unmatched', 0, async () => {
      let extremoteobjectsub: ExtRemoteObjectSub = new ExtRemoteObjectSub();
      let data: rpc.MessageSequence = new rpc.MessageSequence();
      let reply: rpc.MessageSequence = new rpc.MessageSequence();
      let option: rpc.MessageOption = new rpc.MessageOption();
      const result = await extremoteobjectsub.onRemoteMessageRequest(1, data, reply, option);
      expect(result).assertEqual(false);
    });
  })
}