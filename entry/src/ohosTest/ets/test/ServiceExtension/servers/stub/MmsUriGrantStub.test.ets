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
import { ArgumentMatchers, describe, expect, it, MockKit, when } from '@ohos/hypium';
import MmsUriGrantStub from '../../../../../../main/ets/ServiceExtension/servers/stub/MmsUriGrantStub';
import { rpc } from '@kit.IPCKit';
import MmsUriGrantHandler from '../../../../../../main/ets/ServiceExtension/servers/service/MmsUriGrantHandler';

export default function MmsUriGrantStubTest() {
  describe('MmsUriGrantStubTest', () => {
    it('MmsUriGrantStubTest_code_is_COMMAND_GRANT_URI_PERMISSION', 0, async () => {
      let mmsurigrantstub: MmsUriGrantStub = new MmsUriGrantHandler("test","targetBundleName");
      let mocker: MockKit = new MockKit();
      let data: rpc.MessageSequence = new rpc.MessageSequence();
      let reply: rpc.MessageSequence = new rpc.MessageSequence();
      let option: rpc.MessageOption = new rpc.MessageOption();

      let mockGrantAccessAttachmentUrisPermission: Function = mocker.mockFunc(mmsurigrantstub, mmsurigrantstub.grantAccessAttachmentUrisPermission);
      when(mockGrantAccessAttachmentUrisPermission)(ArgumentMatchers.any).afterReturnNothing();

      const result: ESObject = await mmsurigrantstub.onRemoteMessageRequest(MmsUriGrantStub.COMMAND_GRANT_URI_PERMISSION, data, reply, option);
      mocker.clear(mmsurigrantstub);
      expect(result).assertEqual(false);
    });

    it('MmsUriGrantStubTest_exception_occurs', 0, async () => {
      let mmsurigrantstub: MmsUriGrantStub = new MmsUriGrantHandler("test");
      let data: rpc.MessageSequence = new rpc.MessageSequence();
      let reply: rpc.MessageSequence = new rpc.MessageSequence();
      let option: rpc.MessageOption = new rpc.MessageOption();
      const result: ESObject = await mmsurigrantstub.onRemoteMessageRequest(MmsUriGrantStub.COMMAND_GRANT_URI_PERMISSION, data, reply, option);
      expect(result).assertEqual(false);
    });
  })
}