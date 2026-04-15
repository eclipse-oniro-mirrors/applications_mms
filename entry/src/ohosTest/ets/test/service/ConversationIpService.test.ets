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
import { beforeEach, describe, expect, it } from '@ohos/hypium';
import { DTGlobalContext } from '../../testability/TestAbility';
import LooseObject from '../../../../main/ets/data/LooseObject';
import ConversationIpService from '../../../../main/ets/service/ConversationIpService';
import commonData from '../../../../main/ets/data/commonData';

export default function conversationIpServiceTest() {
  describe('conversationIpServiceTest', () => {
    let conversationIpService: ConversationIpService;
    let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;

    beforeEach(() => {
      conversationIpService = ConversationIpService.getTestInstance();
    })

    it('conversationIpServiceTest_getInstance', 0, () => {
      expect(typeof conversationIpService).assertEqual(typeof ConversationIpService.getInstance());
    })

    it('conversationIpServiceTest_updateIpMsgInfo', 0, () => {
      const item: LooseObject = {
        serviceCenter: commonData.serviceCenter.PUSH_OHOS_A2P,
      }
      const res: LooseObject = {};
      conversationIpService.updateIpMsgInfo(item, res);
      expect(res.isIpMsg).message('updateIpMsgInfo serviceCenter = PUSH_OHOS_A2P test failed.').assertTrue();

      const res2: LooseObject = {};
      item.serviceCenter = commonData.serviceCenter.PUSH_A2P;
      conversationIpService.updateIpMsgInfo(item, res2);
      expect(res.isSimpleIpMsg).message('updateIpMsgInfo serviceCenter = PUSH_A2P test failed.').assertTrue();

      const res3: LooseObject = {};
      item.serviceCenter = '';
      conversationIpService.updateIpMsgInfo(item, res3);
      expect(res.isIpMsg).message('updateIpMsgInfo serviceCenter = "" test failed.').assertTrue();
    })
  })
}