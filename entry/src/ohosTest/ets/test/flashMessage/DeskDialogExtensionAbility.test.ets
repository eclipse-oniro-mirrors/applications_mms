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
import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect, MockKit } from '@ohos/hypium'
import DeskDialogExtensionAbility from '../../../../main/ets/flashMessage/DeskDialogExtensionAbility';
import HiLog from '../../../../main/ets/utils/HiLog';
import { UIExtensionContentSession } from '@kit.AbilityKit';

export default function DeskDialogExtensionAbilityTest() {
  describe('DeskDialogExtensionAbilityTest', () => {

    const TAG = 'DeskDialogAbility';

    it('onSessionDestroy', 0, () => {
      let deskDialogExtensionAbility: DeskDialogExtensionAbility = new DeskDialogExtensionAbility();
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog,HiLog.i);
      deskDialogExtensionAbility.onSessionDestroy({
        loadContent: (path: string, storage?: LocalStorage | undefined): void => {}
      } as UIExtensionContentSession);
      mocker.verify('i',[TAG, 'CallBannerExtensionAbility start']).never();
      mocker.clear(HiLog);
    })

    it('onSessionCreate', 0, () => {
      let deskDialogExtensionAbility: DeskDialogExtensionAbility = new DeskDialogExtensionAbility();
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog,HiLog.i);
      deskDialogExtensionAbility.onSessionCreate({},{
        loadContent: (path: string, storage?: LocalStorage | undefined): void => {}
      } as UIExtensionContentSession);
      mocker.verify('i',[TAG, 'UIExtAbility onSessionDestroy']).never();
      mocker.clear(HiLog);
    })
  })
}