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

import UIExtensionAbility from '@ohos.app.ability.UIExtensionAbility';
import Want from '@ohos.app.ability.Want';
import UIExtensionContentSession from '@ohos.app.ability.UIExtensionContentSession';
import HiLog from '../utils/HiLog';
import { display, window } from '@kit.ArkUI';

import { GlobalContext } from '../MainAbility/GlobalHelper';

/* instrument ignore file */

const TAG = 'PrivacyAbility';

/**
 * privacy management of Ability.
 */
export default class PrivacyAbility extends UIExtensionAbility {
  onCreate() {
    HiLog.i(TAG, 'PrivacyAbility onCreate');
  }

  /* instrument ignore file */
  onSessionCreate(want: Want, session: UIExtensionContentSession): void {
    // Main window is created, set main page for this ability
    HiLog.i(TAG, 'PrivacyAbility onSessionCreate');
    let param: Record<string, Object> = {
      'session': session
    }
    this.setSafeAreaInfo(session);
    GlobalContext.getContext().setObject('mmsContext', this.context);
    let storage: LocalStorage = new LocalStorage(param);
    session.loadContent('pages/privacy/privacyIndex', storage);
    session.setWindowBackgroundColor(Color.Transparent.toString());
    AppStorage.setOrCreate('currentColorMode', this.context.config.colorMode);
    AppStorage.setOrCreate('currentLanguage', this.context.resourceManager.getConfigurationSync().locale);
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

  onSessionDestroy(session: UIExtensionContentSession): void {
    try {
      session.sendData({
        'action': 'exit'
      });
    } catch (error) {
      HiLog.e(TAG, `session.sendData fail, err: ${JSON.stringify(error)}`);
    }
    HiLog.i(TAG, `UIExtAbility onSessionDestroy`);
  }

}