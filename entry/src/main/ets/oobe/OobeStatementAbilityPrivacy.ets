/**
 * Copyright (c) 2022 Huawei Device Co., Ltd.
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

import UIExtensionAbility from '@ohos.app.ability.UIExtensionAbility';
import Want from '@ohos.app.ability.Want';
import UIExtensionContentSession from '@ohos.app.ability.UIExtensionContentSession';
import HiLog from '../utils/HiLog';
import { display, window } from '@kit.ArkUI';
import { ConfigurationConstant } from '@kit.AbilityKit';

const TAG = 'OobeStatementAbilityPrivacy';

export interface extensionProperties {
  session?: UIExtensionContentSession;
}

export default class OobeStatementAbilityPrivacy extends UIExtensionAbility {

  onForeground() {
    HiLog.i(TAG, `Ability onForeground`)
  }

  onBackground() {
    HiLog.i(TAG, `Ability onBackground`)
  }

  onDestroy() {
    HiLog.i(TAG, `Ability onDestroy`)
  }

  onSessionCreate(want: Want, session: UIExtensionContentSession) {
    HiLog.i(TAG, 'Ability onSessionCreate');
    let localStorage: LocalStorage = new LocalStorage({
      session: session,
    } as extensionProperties);
    this.setSafeAreaInfo(session);
    session.loadContent('pages/privacy/privacyStateMiddle', localStorage);
    try {
      this.context?.getApplicationContext()?.setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT);
      AppStorage.setOrCreate('foldStatus', display.getFoldStatus());
    } catch (err) {
      HiLog.e(TAG, `Failed to getFoldStatus, Code: ${err.code}, message: ${err.message}`);
    }
    try {
      display.on('foldStatusChange', (foldStatus: display.FoldStatus) => {
        HiLog.i(TAG, 'on--foldStatusChangefoldStatus=' + foldStatus);
        AppStorage.setOrCreate('foldStatus', foldStatus);
      })
    } catch (exception) {
      HiLog.e(TAG, 'Failed code');
    }
  }

  setSafeAreaInfo(session: UIExtensionContentSession): void {
    HiLog.i(TAG, `setSafeAreaInfo`);
    let extensionWindow = session.getUIExtensionHostWindowProxy();
    let statusBarHeight = extensionWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM).topRect.height;
    let naviIndicatorHeight = extensionWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR)
      .bottomRect.height;
    AppStorage.setOrCreate<number>('statusBarHeight', px2vp(statusBarHeight));
    AppStorage.setOrCreate<number>('naviIndicatorHeight', px2vp(naviIndicatorHeight));
    HiLog.i(TAG, `statusBar : ${px2vp(statusBarHeight)}, naviBar : ${px2vp(naviIndicatorHeight)}`);
  }

  onSessionDestroy(session: UIExtensionContentSession) {
    HiLog.i(TAG, `Ability onSessionDestroy`);
  }
}