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
import { describe, beforeEach, it, expect, MockKit, when } from '@ohos/hypium';
import MmsPreferences from '../../../../../main/ets/utils/MmsPreferences';
import OperatorConfigUtil from '../../../../../main/cust/utils/OperatorConfigUtil';

export default function operatorConfigUtilTest() {
  describe('operatorConfigUtilTest', () => {

    let operatorConfigUtil: OperatorConfigUtil;

    beforeEach(() => {
      operatorConfigUtil = OperatorConfigUtil.getInstance()
    })

    it('OperatorConfigUtilTest_getOperatorConfig_operatorConfigMap_size_0', 0, () => {
      operatorConfigUtil.initOperatorConfig();
      let res: string = operatorConfigUtil.getOperatorConfig(0, '');
      expect(res).assertEqual('');
    })

    it('OperatorConfigUtilTest_getCustMMSSize', 0, async () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(MmsPreferences.getInstance(), MmsPreferences.getInstance().getSendMessageSlotId))()
        .afterReturn(0);
      when(mocker.mockFunc(OperatorConfigUtil.getInstance(), OperatorConfigUtil.getInstance().getOperatorConfig))(0)
        .afterReturn(3072000);

      expect(operatorConfigUtil.getCustMMSSize(3072000)).assertEqual(3072000);

      mocker.clear(MmsPreferences.getInstance());
      mocker.clear(OperatorConfigUtil.getInstance());
    })

    it('OperatorConfigUtilTest_getCustSMSCAddress', 0, async () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(OperatorConfigUtil.getInstance(), OperatorConfigUtil.getInstance().getOperatorConfig))(0)
        .afterReturn(3072000);

      expect(operatorConfigUtil.getCustSMSCAddress(0)).assertEqual(3072000);

      mocker.clear(OperatorConfigUtil.getInstance());
    })
  })
}