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
import { beforeEach, it, describe, MockKit, when, expect } from '@ohos/hypium';
import { MmsWindowsManager } from '../../../../main/ets/utils/WindowsManager';
import { window } from '@kit.ArkUI';
import { GlobalContext } from '../../../../main/ets/MainAbility/GlobalHelper';
import myCommon from '@ohos.app.ability.common';
import HiLog from '../../../../main/ets/utils/HiLog';

export default function windowsManagerTest() {
  describe('windowsManagerTest', () => {

    let windowsManager: MmsWindowsManager;
    let mocker: MockKit
    const TAG: string = 'WindowsManager';

    beforeEach(() => {
      windowsManager = MmsWindowsManager.getInstance();
      mocker = new MockKit();
    })

    it('windowsManagerTest_initForPhone', 0, () => {
      let window: window.Window = {} as window.Window;
      let context: myCommon.UIAbilityContext = (GlobalContext.getContext()
        .getObject('mmsContext') as myCommon.UIAbilityContext);
      mocker.mockFunc(windowsManager, windowsManager.setImmersive);
      windowsManager.initForPhone(window, context);
      mocker.verify('setImmersive', [context]).once();
      mocker.clear(windowsManager);
    })

    it('windowsManagerTest_initForPhone_null', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.e);
      let context: myCommon.UIAbilityContext = (GlobalContext.getContext()
        .getObject('mmsContext') as myCommon.UIAbilityContext);
      windowsManager.initForPhone(null, context);
      mocker.verify('e', [TAG, 'window is undefined']).never();
      mocker.clear(HiLog)
    })

    it('windowsManagerTest_setImmersive', 0, () => {
      let context: myCommon.UIAbilityContext = {
        config: {
          colorMode: 0
        }
      } as myCommon.UIAbilityContext;
      let window: window.Window = {
        setWindowLayoutFullScreen: (isLayoutFullScreen: boolean): Promise<void> => {
          return new Promise<void>(resolve => resolve())
        }
      } as window.Window;
      windowsManager.initForPhone(window, context);
      windowsManager.setImmersive(context);
      let mWindowsManager = (windowsManager as object)['mainWindow'] as window.Window | undefined;
      expect(mWindowsManager).not().assertUndefined();
    })

    it('windowsManagerTest_setImmersive_colorMode_1', 0, () => {
      let context: myCommon.UIAbilityContext = {
        config: {
          colorMode: 1
        }
      } as myCommon.UIAbilityContext;
      let window: window.Window = {
        setWindowLayoutFullScreen: (isLayoutFullScreen: boolean) : Promise<void> => {
          return new Promise<void>(resolve => resolve())
        }
      } as window.Window;
      windowsManager.initForPhone(window, context);
      windowsManager.setImmersive(context);
      let mWindowsManagers = (windowsManager as object)['mainWindow'] as window.Window | undefined;
      expect(mWindowsManagers).not().assertUndefined();
    })
  })
}