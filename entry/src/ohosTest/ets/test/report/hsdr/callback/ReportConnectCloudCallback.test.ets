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
import { describe, it, expect, MockKit, when } from '@ohos/hypium';
import { rpc } from '@kit.IPCKit';
import ReportConstant from '../../../../../../main/ets/report/common/ReportConstant';
import ReportConnectCloudCallback from '../../../../../../main/ets/report/hsdr/callback/ReportConnectCloudCallback';
import { ConnectCloudResponseParam } from '../../../../../../main/ets/report/common/ReportParams';

export default function reportConnectCloudCallbackTest() {
  describe('ReportConnectCloudCallbackTest', () => {

    it('ReportConnectCloudCallback_onRemoteMessageRequest', 0, async () => {
      let option: rpc.MessageOption = new rpc.MessageOption()
      let data: rpc.MessageSequence = rpc.MessageSequence.create();
      let reply: rpc.MessageSequence = rpc.MessageSequence.create();
      data.writeInterfaceToken('test');
      data.writeString(ReportConstant.HSDR_ANTIFRAUD_NAME);
      data.writeInt(1);
      data.writeStringArray(['{}']);
      let callback: ReportConnectCloudCallback = new ReportConnectCloudCallback(
        (errCode: number, statusCode: number) => {
        });
      let res: boolean = await callback.onRemoteMessageRequest(1, data, reply, option);
      expect(res).assertFalse();
    })

    it('ReportConnectCloudCallback_onResult', 0, () => {
      let callback: ReportConnectCloudCallback = new ReportConnectCloudCallback(
        (errCode: number, statusCode: number) => {
        });
      let res = {
        httpStatus: 200,
        headers: '',
        body: JSON.stringify(JSON.stringify({statusCode:200}))
      } as ConnectCloudResponseParam;
      callback.onResult(200,
        [JSON.stringify(res)],
        (errCode: number) => {
          expect(errCode === 0).assertTrue();
        });
    })

    it('ReportConnectCloudCallback_onResult_errorCode_0', 0, () => {
      let callback: ReportConnectCloudCallback = new ReportConnectCloudCallback(
        (errCode: number, statusCode: number) => {
        });
      let res = {
        httpStatus: 200,
        headers: '',
        body: JSON.stringify(JSON.stringify({statusCode:200}))
      } as ConnectCloudResponseParam;
      callback.onResult(0,
        [JSON.stringify(res)],
        (errCode: number) => {
          expect(errCode === 0).assertTrue();
        });
    })
  })
}