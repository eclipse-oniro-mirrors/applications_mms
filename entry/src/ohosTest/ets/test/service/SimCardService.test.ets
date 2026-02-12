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
import { describe, it, MockKit } from '@ohos/hypium';
import SimCardService from '../../../../main/ets/service/SimCardService';
import cardModel from '../../../../main/ets/model/CardModel';
import { commonEventManager } from '@kit.BasicServicesKit';
import { DTGlobalContext } from '../../testability/TestAbility';

export default function simCardServiceTest() {
  describe('simCardServiceTest', () => {

    it('simCardServiceTest_init', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(cardModel, cardModel.init);

      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;

      SimCardService.init(context);

      mocker.verify('init', [context]).once();

      mocker.clear(cardModel);
    })

    it('simCardServiceTest_deInit', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(cardModel, cardModel.deInit);

      SimCardService.deInit();

      mocker.verify('deInit', []).once();

      mocker.clear(cardModel);
    })

    it('simCardServiceTest_isSimReady', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(cardModel, cardModel.isSimReady);

      SimCardService.isSimReady(0);

      mocker.verify('isSimReady', [0]).once();

      mocker.clear(cardModel);
    })
  })
}