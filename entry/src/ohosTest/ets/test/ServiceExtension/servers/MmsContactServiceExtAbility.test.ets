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
import { describe, it } from '@ohos/hypium';
import { MockKit } from '@ohos/hypium/src/main/module/mock/MockKit';
import MmsContactServiceExtAbility from '../../../../../main/ets/ServiceExtension/servers/MmsContactServiceExtAbility';
import HiLog from '../../../../../main/ets/utils/HiLog';

export default function mmsContactServiceExtAbilityTest() {
  describe('mmsContactServiceExtAbilityTest', () => {

    const TAG = 'MmsContactServiceExtAbility';

    it('mmsContactServiceExtAbility_onCreate', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.i);

      new MmsContactServiceExtAbility().onCreate({} as Want);

      mocker.verify('i', [TAG, 'MmsContactServiceExtAbility onCreate']).never();

      mocker.clear(HiLog);
    })

    it('mmsContactServiceExtAbility_onRequest', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.i);

      new MmsContactServiceExtAbility().onRequest({} as Want, 0);

      mocker.verify('i', [TAG, 'MmsContactServiceExtAbility onRequest']).never();

      mocker.clear(HiLog);
    })

    it('mmsContactServiceExtAbility_onConnect', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.i);

      new MmsContactServiceExtAbility().onConnect({} as Want);

      mocker.verify('i', [TAG, 'MmsContactServiceExtAbility onConnect']).never();

      mocker.clear(HiLog);
    })

    it('mmsContactServiceExtAbility_onDisconnect', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.i);

      new MmsContactServiceExtAbility().onDisconnect({} as Want);

      mocker.verify('i', [TAG, 'MmsContactServiceExtAbility onDisconnect']).never();

      mocker.clear(HiLog);
    })

    it('mmsContactServiceExtAbility_onDestroy', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.i);

      new MmsContactServiceExtAbility().onDestroy();

      mocker.verify('i', [TAG, 'MmsContactServiceExtAbility onDestroy']).never();

      mocker.clear(HiLog);
    })
  })
}