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
import { beforeEach, describe, it, MockKit } from '@ohos/hypium';
import BlockedListExtAbility from '../../../../main/ets/uiExtensionAbility/BlockedListExtAbility';
import { UIExtensionContentSession } from '@kit.AbilityKit';
import { GlobalContext } from '../../../../main/ets/MainAbility/GlobalHelper';
import HiLog from '../../../../main/ets/utils/HiLog';

export default function blockedListExtAbilityTest() {
  describe('blockedListExtAbilityTest', () => {

    const TAG = 'BlockedListExtAbility';
    let blockedListExtAbility:BlockedListExtAbility;

    beforeEach(()=>{
      blockedListExtAbility = new BlockedListExtAbility();

    })

    it('blockedListExtAbilityTest_onCreate', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog,HiLog.i);
      new BlockedListExtAbility().onCreate();
      mocker.verify('i',[TAG, 'BlockedListExtAbility onCreate']).never();
      mocker.clear(HiLog);
    })

    it('blockedListExtAbilityTest_onSessionCreate', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().setObject);
      mocker.mockFunc(HiLog,HiLog.i);

      blockedListExtAbility.onSessionCreate({}, {
        loadContent: (path: string, storage?: LocalStorage | undefined): void => {
        }
      } as UIExtensionContentSession);

      mocker.verify('i',[TAG, 'BlockedListExtAbility onSessionCreate']).never();

      mocker.clear(GlobalContext.getContext());
      mocker.clear(HiLog);
    })

    it('blockedListExtAbilityTest_onSessionDestroy', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog,HiLog.i);
      new BlockedListExtAbility().onSessionDestroy({} as UIExtensionContentSession);
      mocker.verify('i',[TAG, 'BlockedListExtAbility onSessionDestroy']).never();
      mocker.clear(HiLog);
    })

    it('blockedListExtAbilityTest_onForeground', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog,HiLog.i);
      new BlockedListExtAbility().onForeground();
      mocker.verify('i',[TAG, 'BlockedListExtAbility onForeground']).never();
      mocker.clear(HiLog);
    })

    it('blockedListExtAbilityTest_onBackground', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog,HiLog.i);
      new BlockedListExtAbility().onBackground();
      mocker.verify('i',[TAG, 'BlockedListExtAbility onBackground']).never();
      mocker.clear(HiLog);
    })

    it('blockedListExtAbilityTest_onDestroy', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog,HiLog.i);
      new BlockedListExtAbility().onDestroy();
      mocker.verify('i',[TAG, 'BlockedListExtAbility onDestroy']).never();
      mocker.clear(HiLog);
    })
  })
}