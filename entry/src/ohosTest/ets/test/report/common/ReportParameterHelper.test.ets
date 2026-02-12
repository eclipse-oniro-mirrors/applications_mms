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
import ReportParameterHelper from '../../../../../main/ets/report/common/ReportParameterHelper';
import { RequestParameter } from '../../../../../main/ets/report/request/RequestParameter';
import { common } from '@kit.AbilityKit';
import { DTGlobalContext } from '../../../testability/TestAbility';
import { UcsResponseParam } from '../../../../../main/ets/report/common/ReportParams';
import SharedPreferencesUtils from '../../../../../main/ets/utils/SharedPreferencesUtils';
import { connection } from '@kit.NetworkKit';
import ResourceUtils from '../../../../../main/ets/utils/ResourceUtils';
import ReportUtil from '../../../../../main/ets/report/ReportUtil';

export default function reportParameterHelperTest() {
  describe('ReportParameterHelperTest', () => {

    it('ReportParameterHelper_getConnectCloudParams', 0, () => {
      let mockData: UcsResponseParam = {
        data: 'data',
        iv: 'iv',
        ak: 'ak'
      };
      let request: RequestParameter = {
        bodyEncode: 'body',
        errCode: 1,
        result: [JSON.stringify(mockData)],
        httpPayload: 'httpPayload',
        timestamp: 123456789
      };
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(ReportParameterHelper, ReportParameterHelper.getAuthorization))(ArgumentMatchers.any)
        .afterReturn('');
      let result: string = ReportParameterHelper.getConnectCloudParams(request);
      mocker.clear(ReportParameterHelper);
      expect(result.length >= 0).assertTrue();
    })

    it('ReportParameterHelper_generateRandomNum', 0, () => {
      let result: string = ReportParameterHelper.generateRandomNum();
       expect(result.length >= 0).assertTrue();
    })

    it('ReportParameterHelper_getCalleeId', 0, async () => {
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences);
      when(mockFunc)('generateCalleeIdTime').afterReturn(new Date().getTime() - 7 * 24 * 60 * 60 * 1001);
      when(mockFunc)('calleeId').afterReturn('1');
      mocker.mockFunc(ReportParameterHelper, ReportParameterHelper.generateRandomCalleeId);
      mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.saveToPreferences);
      let newResult: string = await ReportParameterHelper.getCalleeId();
      expect(newResult).assertEqual('1');

      when(mockFunc)('generateCalleeIdTime').afterReturn(new Date().getTime());
      newResult = await ReportParameterHelper.getCalleeId();
      expect(newResult).assertEqual('1');
      mocker.clear(SharedPreferencesUtils);
      mocker.clear(ReportParameterHelper);
    })

    it('ReportParameterHelper_getAuthorization', 0, () => {
      let data: UcsResponseParam = {
        data: 'data',
        iv: 'iv',
        ak: 'ak'
      };
      let request: RequestParameter = {
        bodyEncode: 'body',
        errCode: 1,
        result: [JSON.stringify(data)],
        httpPayload: 'httpPayload',
        timestamp: 123456789
      };
      let result: string = ReportParameterHelper.getAuthorization(data, request);
      expect(result.length >= 0).assertTrue();
    })

    it('ReportParameterHelper_generateRandomCalleeId', 0, () => {
      let result: string = ReportParameterHelper.generateRandomCalleeId();
      expect(result.length >= 0).assertTrue();
    })

    it('ReportParameterHelper_getIp', 0, async () => {
      let context: common.UIAbilityContext =
        DTGlobalContext.getContext().getObject("mmsContext") as common.UIAbilityContext;
      let newResult: string = await ReportParameterHelper.getIp(context);
      expect(newResult.length >= 0).assertTrue();
    })

    it('ReportParameterHelper_getIp2', 0, async () => {
      let context: common.UIAbilityContext =
        DTGlobalContext.getContext().getObject("mmsContext") as common.UIAbilityContext;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(ResourceUtils, ResourceUtils.getStringByFile))(ArgumentMatchers.any)
        .afterReturn(JSON.stringify({
          default_ip_address: ''
        }));
      let newResult = await ReportParameterHelper.getIp(context);
      expect(newResult != '').assertFalse();

      mocker.clear(ResourceUtils);
    })

    it('ReportParameterHelper_getCurrentNetCap', 0, async () => {
      let res: string[] = ReportParameterHelper.getCurrentNetCap([], {
        linkAddresses: [{
          address: {
            address: '',
            family: 1
          } as connection.NetAddress
        } as connection.LinkAddress, {
          address: {
            address: '',
            family: 0
          } as connection.NetAddress
        } as connection.LinkAddress],
        interfaceName: '',
        domains: '',
        dnses: [],
        routes: [],
        mtu: 0
      } as connection.ConnectionProperties);
      expect(res[0]).assertEqual('');
    })

    it('ReportParameterHelper_getSignatureRequest', 0, () => {
      let mockData: UcsResponseParam = {
        data: 'data',
        iv: 'iv',
        ak: 'ak'
      };
      let request: RequestParameter = {
        bodyEncode: 'body',
        errCode: 1,
        result: [JSON.stringify(mockData)],
        httpPayload: 'httpPayload',
        timestamp: 123456789
      };
      let newRequest: RequestParameter = ReportParameterHelper.getSignatureRequest(request);
      expect(newRequest.httpPayload !== 'a').assertTrue();
    })

    it('ReportParameterHelper_getSignatureRequest1', 0, () => {
      let mockData: UcsResponseParam = {
        data: 'data',
        iv: 'iv',
        ak: 'ak'
      };
      let request: RequestParameter = {
        bodyEncode: 'body',
        errCode: 1,
        result: [JSON.stringify(mockData)],
        httpPayload: 'httpPayload',
        timestamp: 123456789
      };

      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(ReportUtil, ReportUtil.getStringToSign))(ArgumentMatchers.any)
        .afterReturn('yy&xx');
      let newRequest: RequestParameter = ReportParameterHelper.getSignatureRequest(request);
      expect(newRequest.httpPayload).assertEqual('httpPayload');

      mocker.clear(ReportUtil);
    })

    it('ReportParameterHelper_getSignatureRequest2', 0, () => {
      let mockData: UcsResponseParam = {
        data: 'data',
        iv: 'iv',
        ak: 'ak'
      };
      let request: RequestParameter = {
        bodyEncode: 'body',
        errCode: 1,
        result: [JSON.stringify(mockData)],
        httpPayload: 'httpPayload',
        timestamp: 123456789
      };

      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(ReportUtil, ReportUtil.getStringToSign))(ArgumentMatchers.any)
        .afterReturn('yy&xx&zzz&iii');
      when(mocker.mockFunc(ReportUtil, ReportUtil.encodeAndEncryptBody))(ArgumentMatchers.any)
        .afterReturn('');
      let newRequest: RequestParameter = ReportParameterHelper.getSignatureRequest(request);
      expect(newRequest.httpPayload !== 'b').assertTrue();

      mocker.clear(ReportUtil);
    })
  })
}