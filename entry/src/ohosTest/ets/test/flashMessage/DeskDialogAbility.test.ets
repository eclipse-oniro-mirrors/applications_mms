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
import { beforeEach, describe, expect, it, MockKit } from '@ohos/hypium';
import DeskDialogAbility from '../../../../main/ets/flashMessage/DeskDialogAbility';
import HiLog from '../../../../main/ets/utils/HiLog';

export default function deskDialogAbilityTest() {
  describe('DeskDialogAbilityTest', () => {

    let deskDialogAbility: DeskDialogAbility;
    const TAG = 'DeskDialogAbility';

    beforeEach(() => {
      deskDialogAbility = new DeskDialogAbility();
    })

    it('deskDialogAbilityTest_onCreate', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog,HiLog.i);
      deskDialogAbility.onCreate({});
      mocker.verify('i',[TAG, 'ServiceExtensionAbility']).never();
      mocker.clear(HiLog);
    })

    it('deskDialogAbilityTest_onRequest', 0, () => {
      deskDialogAbility.onRequest({}, 0);
      expect(deskDialogAbility).not().assertUndefined();
    })

    it('deskDialogAbilityTest_onRequest_not_null', 0, () => {
      deskDialogAbility.onRequest({
        parameters: {
          event: 'FLASH_SAVE_MESSAGE',
          data: {parameters: {isNotificationFlag: false}}

        }
      }, 0);
      expect(deskDialogAbility).not().assertUndefined();
    })

    it('deskDialogAbilityTest_onRequest_not_null_isNotificationFlag_true', 0, () => {
      deskDialogAbility.onRequest({
        parameters: {
          event: 'FLASH_SAVE_MESSAGE',
          data: {parameters: {isNotificationFlag: true}}
        }
      }, 0);
      expect(deskDialogAbility).not().assertUndefined();
    })

    it('deskDialogAbilityTest_onDisconnect', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog,HiLog.i);
      deskDialogAbility.onDisconnect({});
      mocker.verify('i',[TAG, 'ServiceExtensionAbility']).never();
      mocker.clear(HiLog);
    })

    it('deskDialogAbilityTest_onDestroy', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog,HiLog.i);
      deskDialogAbility.onDestroy();
      mocker.verify('i',[TAG, 'ServiceExtensionAbility']).never();
      mocker.clear(HiLog);
    })
  })
}