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
import { describe, it, expect } from '@ohos/hypium';
import LooseObject from '../../../../main/ets/data/LooseObject';
import BaseModel from '../../../../main/ets/model/BaseModel'
import { ConversationListInfo } from '../../../../main/ets/model/conversationlist/ConversationListInfo';
import ConversationListResponse from '../../../../main/ets/model/conversationlist/ConversationListResponse';

export default function BaseModelTest() {

  describe('BaseModelTest', () => {

    it('BaseModel_encapsulateReturnCode', 0, () => {
      let baseModel = new BaseModel();
      let result: LooseObject = baseModel.encapsulateReturnCode(1);
      expect(result.code).assertEqual(1);
    })

    it('BaseModel_buildSessionReturnResult', 0, () => {
      let baseModel = new BaseModel();
      let code = 0;
      let resultList: Array<ConversationListInfo> = new Array<ConversationListInfo>();
      let response: ConversationListResponse = baseModel.buildSessionReturnResult(code, resultList);
      expect(response.code).assertEqual(code);
    })
  })
}