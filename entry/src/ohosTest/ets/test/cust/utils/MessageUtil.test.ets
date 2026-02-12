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
import MmsPreferences from '../../../../../main/ets/utils/MmsPreferences';
import StringUtil from '../../../../../main/ets/utils/StringUtil';
import MessageUtil from '../../../../../main/cust/utils/MessageUtil';
import OperatorConfigUtil from '../../../../../main/cust/utils/OperatorConfigUtil';

export default function MessageUtilTest() {
  describe('MessageUtilTest', () => {

    it('MessageUtilTest_replaceForLossy7Bit_startIndex_minus1', 0, async () => {
      expect(MessageUtil.replaceForLossy7Bit(0, '', -1, 0)).assertEqual('');
    })

    it('MessageUtilTest_replaceForLossy7Bit_startIndex_11_endIndex_0', 0, async () => {
      expect(MessageUtil.replaceForLossy7Bit(0, '', 1, 0)).assertEqual('');
    })

    it('MessageUtilTest_replaceForLossy7Bit_enabled7Bit_false', 0, async () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(OperatorConfigUtil.getInstance(), OperatorConfigUtil.getInstance().getOperatorConfig))(0)
        .afterReturn('2');
      expect(MessageUtil.replaceForLossy7Bit(0, 'xx', 0, 1)).assertEqual('xx');
      mocker.clear(OperatorConfigUtil.getInstance());
    })

    it('MessageUtilTest_replaceForLossy7Bit_enabled7Bit_true', 0, async () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(OperatorConfigUtil.getInstance(), OperatorConfigUtil.getInstance().getOperatorConfig))(0)
        .afterReturn('1');
      expect(MessageUtil.replaceForLossy7Bit(0, 'xx', 0, 1)).assertEqual('x');
      mocker.clear(OperatorConfigUtil.getInstance());
    })

    it('MessageUtilTest_getSmscNumberFromPref1', 0, async () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(MmsPreferences.getInstance(), MmsPreferences.getInstance().getNewSmscOfSim2))()
        .afterReturn('');
      expect(await MessageUtil.getSmscNumberFromPref(1)).assertEqual('');
      mocker.clear(MmsPreferences.getInstance());
    })

    it('MessageUtilTest_getSmscNumberFromPref_smscNumber_empty', 0, async () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(MmsPreferences.getInstance(), MmsPreferences.getInstance().getNewSmscOfSim1))()
        .afterReturn('');
      when(mocker.mockFunc(MessageUtil, MessageUtil.getSMSCAddress))(0)
        .afterReturn(new Promise<string>(resolve => resolve('')));
      when(mocker.mockFunc(OperatorConfigUtil.getInstance(), OperatorConfigUtil.getInstance().getCustSMSCAddress))(0)
        .afterReturn('');
      let result: string = await MessageUtil.getSmscNumberFromPref(0);
      expect(result.length >= 0).assertTrue();
      mocker.clear(MmsPreferences.getInstance());
      mocker.clear(MessageUtil);
      mocker.clear(OperatorConfigUtil.getInstance());
    })

    it('MessageUtilTest_getSMSCAddress', 0, async () => {
      await OperatorConfigUtil.getInstance().initOperatorConfig();
      MessageUtil.getSMSCAddress(1).then(res => {
        expect(res).assertEqual('');
      });
    })
    it('MessageUtilTest_isMmsText_content_is_empty', 0, async () => {
      let mocker: MockKit = new MockKit();
      let mockfunc: Function = mocker.mockFunc(StringUtil, StringUtil.isEmpty);
      when(mockfunc)(ArgumentMatchers.anyString).afterReturn(true);
      const result: ESObject = await MessageUtil.isMmsText("content");
      expect(result).assertEqual(false);
      mocker.ignoreMock(StringUtil, StringUtil.isEmpty);
    });
  })
}