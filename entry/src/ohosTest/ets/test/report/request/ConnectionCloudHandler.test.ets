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
import ConnectionCloudHandler from '../../../../../main/ets/report/request/ConnectionCloudHandler';
import { RequestParameter } from '../../../../../main/ets/report/request/RequestParameter';
import ReportParameterHelper from '../../../../../main/ets/report/common/ReportParameterHelper';

export default function connectionCloudHandlerTest() {
  describe('ConnectionCloudHandlerTest', () => {

    it('ConnectionCloudHandler_startRequest', 0, () => {
      let request: RequestParameter = {
        bodyEncode: 'body',
        errCode: 1,
        result: ['data', 'iv', 'ak'],
        httpPayload: 'httpPayload',
        timestamp: 123456789
      }
      let connectionCloudHandler: ConnectionCloudHandler = new ConnectionCloudHandler();
      const mocker: MockKit = new MockKit();
      let count: number = 1;
      let mockFuncOne: Function = mocker.mockFunc(ReportParameterHelper, ReportParameterHelper.getConnectCloudParams);
      when(mockFuncOne)(request).afterReturn(request);
      let mockFuncTwo: Function = mocker.mockFunc(ReportParameterHelper, ReportParameterHelper.generateRandomNum);
      when(mockFuncTwo)().afterReturn('123456');
      count++;
      connectionCloudHandler.startRequest(request);
      expect(count == 2).assertTrue();
    })
  })
}