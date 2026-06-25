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
import { describe, it, expect, MockKit, when, ArgumentMatchers } from '@ohos/hypium';
import { RequestParameter } from '../../../../../main/ets/report/request/RequestParameter';
import SignatureHandler from '../../../../../main/ets/report/request/SignatureHandler';
import { common } from '@kit.AbilityKit';
import { DTGlobalContext } from '../../../testability/TestAbility';
import ConnectionCloudHandler from '../../../../../main/ets/report/request/ConnectionCloudHandler';
import HiLog from '../../../../../main/ets/utils/HiLog';
import ReportParameterHelper from '../../../../../main/ets/report/common/ReportParameterHelper';
import ReportConnectServiceManager from '../../../../../main/ets/report/ReportConnectServiceManager';

export default function signatureHandlerTest() {
  describe('SignatureHandlerTest', () => {
    const TAG = 'BaseRequestHandler';
    it('SignatureHandler_startRequest_code_1', 0, () => {
      let request: RequestParameter = {
        bodyEncode: 'body',
        errCode: 1,
        result: ['data', 'iv', 'ak'],
        httpPayload: 'httpPayload',
        timestamp: 123456789
      };
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.i);
      let signatureHandler: SignatureHandler = new SignatureHandler();
      signatureHandler.startRequest(request);
      mocker.verify('i', [TAG, '[SignatureHandler] startRequest.']).never();
      mocker.clear(HiLog);
    })

    it('SignatureHandler_startRequest_length_0', 0, () => {
      let request: RequestParameter = {
        bodyEncode: 'body',
        errCode: 0,
        result: [],
        httpPayload: 'httpPayload',
        timestamp: 123456789
      };
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.i);
      when(mocker.mockFunc(ReportParameterHelper, ReportParameterHelper.getSignatureRequest))(ArgumentMatchers.any)
        .afterReturn({
          bodyEncode: 'body',
          errCode: 0,
          result: [],
          httpPayload: 'httpPayload',
          timestamp: 123456789
        });
      when(mocker.mockFunc(ReportParameterHelper, ReportParameterHelper.generateRandomNum))(ArgumentMatchers.any)
        .afterReturn('');
      let signatureHandler: SignatureHandler = new SignatureHandler();
      signatureHandler.startRequest(request);
      mocker.verify('i', [TAG, '[SignatureHandler] startRequest.']).never();
      mocker.clear(HiLog);
      mocker.clear(ReportParameterHelper);
    })

    it('SignatureHandler_startRequest', 0, () => {
      let request: RequestParameter = {
        bodyEncode: 'body',
        errCode: 0,
        result: ['data', 'iv', 'ak'],
        httpPayload: 'httpPayload',
        timestamp: 123456789
      };
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.i);
      when(mocker.mockFunc(ReportParameterHelper, ReportParameterHelper.getSignatureRequest))(ArgumentMatchers.any)
        .afterReturn({
          bodyEncode: 'body',
          errCode: 0,
          result: [],
          httpPayload: 'httpPayload',
          timestamp: 123456789
        });
      when(mocker.mockFunc(ReportParameterHelper, ReportParameterHelper.generateRandomNum))(ArgumentMatchers.any)
        .afterReturn('');
      mocker.mockFunc(ReportConnectServiceManager.getInstance(),
        ReportConnectServiceManager.getInstance().startRequestUcs);
      let signatureHandler: SignatureHandler = new SignatureHandler();
      signatureHandler.startRequest(request);
      expect(signatureHandler).not().assertUndefined();
      mocker.clear(HiLog);
      mocker.clear(ReportParameterHelper);
      mocker.clear(ReportConnectServiceManager.getInstance());
    })
  })
}