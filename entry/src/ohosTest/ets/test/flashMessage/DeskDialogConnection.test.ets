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
import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect, MockKit,
  ArgumentMatchers } from '@ohos/hypium'
import LooseObject from '../../../../main/ets/data/LooseObject';
import DeskDialogConnection from '../../../../main/ets/flashMessage/DeskDialogConnection';
import { GlobalContext } from '../../../../main/ets/MainAbility/GlobalHelper';
import myCommon from '@ohos.app.ability.common';
import { when } from '@ohos/hypium/src/main/module/mock/MockKit';
import HiLog from '../../../../main/ets/utils/HiLog';

export default function DeskDialogConnectionTest() {
  describe('DeskDialogConnectionTest', () => {

    const TAG: string = 'Banner_CLASS';

    it('DeskDialogConnectionTest_flashMessageShowLogic_if1', 0, () => {
      let context = (GlobalContext.getContext()
        .getObject('mmsContext')) as myCommon.UIAbilityContext;
      let dialogInfo: LooseObject = {};
      dialogInfo.result = {};
      dialogInfo.result.telephone = '11111';
      dialogInfo.result.content = '22222';
      let deskDialogConnection: DeskDialogConnection = DeskDialogConnection.getInstance(context);
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.i);
      when(mocker.mockFunc(deskDialogConnection,
        deskDialogConnection.flashMessageNeedShowNotification))(ArgumentMatchers.any).afterReturn(true);
      deskDialogConnection.flashMessageShowLogic(dialogInfo);
      mocker.clear(HiLog);
      mocker.clear(deskDialogConnection);
      expect(deskDialogConnection).not().assertUndefined();
    })

    it('DeskDialogConnectionTest_flashMessageShowLogic_if2', 0, () => {
      let context = (GlobalContext.getContext()
        .getObject('mmsContext')) as myCommon.UIAbilityContext;
      let dialogInfo: LooseObject = {};
      let deskDialogConnection: DeskDialogConnection = DeskDialogConnection.getInstance(context);
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.i);
      when(mocker.mockFunc(deskDialogConnection,
        deskDialogConnection.flashMessageNeedShowNotification))(ArgumentMatchers.any).afterReturn(false);
      deskDialogConnection.flashMessageShowLogic(dialogInfo);
      mocker.clear(HiLog);
      mocker.clear(deskDialogConnection);
      expect(deskDialogConnection).not().assertUndefined();
    })

    it('DeskDialogConnectionTest_flashMessageShowLogic_else_bannerStart_remote_null', 0, () => {
      let context = {
        connectServiceExtensionAbility: (want: Want, options: myCommon.ConnectOptions): number => {
          options.onConnect({
            bundleName: '', abilityName: ''
          }, null);
          return 1;
        }
      } as myCommon.UIAbilityContext;
      let dialogInfo: LooseObject = {};
      let deskDialogConnection: DeskDialogConnection = DeskDialogConnection.getInstance(context);
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.i);
      when(mocker.mockFunc(deskDialogConnection,
        deskDialogConnection.flashMessageNeedShowNotification))(ArgumentMatchers.any).afterReturn(false);
      deskDialogConnection.flashMessageShowLogic(dialogInfo);
      mocker.clear(HiLog);
      mocker.clear(deskDialogConnection);
      expect(deskDialogConnection).not().assertUndefined();
    })

    it('jumpToConv', 0, () => {
      let context = (GlobalContext.getContext()
        .getObject('mmsContext')) as myCommon.UIAbilityContext;
      let dialogInfo: LooseObject = {};
      let deskDialogConnection: DeskDialogConnection = DeskDialogConnection.getInstance(context);
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.i);
      deskDialogConnection.jumpToConv(dialogInfo);
      mocker.clear(HiLog);
      expect(deskDialogConnection).not().assertUndefined();
    })
  })
}