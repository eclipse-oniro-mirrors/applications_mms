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
import { describe, it, expect, MockKit } from '@ohos/hypium';
import LooseObject from '../../../../main/ets/data/LooseObject';
import { CallService } from '../../../../main/ets/service/CallService';
import MmsPreferences from '../../../../main/ets/utils/MmsPreferences';


export default function callServiceTest() {
  describe('CallServiceTest', () => {

    it('CallService_fromString', 0, () => {
      let phoneNumber = '10086';
      let callPhone = CallService.fromString(phoneNumber);
      expect(callPhone.getNumber()).assertEqual(phoneNumber);
    })

    it('CallService_isDialEmergencyNum', 0, async () => {
      let phoneNumber = '10086';
      let res: boolean = await CallService.fromString(phoneNumber).isDialEmergencyNum();
      expect(res).assertFalse();
    })

    it('CallService_getNumber', 0, async () => {
      let callService: CallService = new CallService('10086');
      let res: string = callService.getNumber();
      expect(res).assertEqual('10086');
    })

    it('CallService_call', 0, () => {
      let callback: LooseObject = {
        "callback": null
      };
      let callService: CallService = new CallService('10086');
      let mocker = new MockKit();
      mocker.mockFunc(callService, callService.dial);
      callService.call(callback);
      mocker.verify('dial', [callback]).once();
      mocker.clear(callService);
    })

    it('CallService_dial_number_empty', 0, () => {
      let callService: CallService = new CallService('');
      let mocker = new MockKit();
      mocker.mockFunc(MmsPreferences.getInstance(),MmsPreferences.getInstance().getDefaultSlotId);
      callService.dial({});
      mocker.verify('getDefaultSlotId', []).never();
      mocker.clear(MmsPreferences.getInstance());
    })
  })
}