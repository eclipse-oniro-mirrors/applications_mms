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


import myCommon from '@ohos.app.ability.common';
import HiLog   from './HiLog';
import window from '@ohos.window';


const TAG: string = 'WindowsManager';

export class MmsWindowsManager {
  private mainWindow: window.Window | undefined = undefined;
  private static instance:MmsWindowsManager;

  private constructor() {
  }

  /**
   * Get MmsWindowsManager Single Instance
   */
  public static getInstance(): MmsWindowsManager {
    if (!MmsWindowsManager.instance){
      MmsWindowsManager.instance = new MmsWindowsManager();
    }
    return MmsWindowsManager.instance
  }

  /**
   * set mainWindow of App
   *
   * @param window
   */
  public initForPhone(window: window.Window, context: myCommon.UIAbilityContext): void {
    if (!window) {
      HiLog.e(TAG, `window is undefined`);
      return;
    }
    this.mainWindow = window;
    this.setImmersive(context);
  }
  /**
   * For the immersive effect, it is necessary to add
   * padding for app pages
   */
  public setImmersive(context: myCommon.UIAbilityContext): void {
    HiLog.d(TAG, 'setNavigationBarColor start');
    // this.mainWindow?.setWindowLayoutFullScreen(true); //防止标题上移
    let currentColorMode = context.config.colorMode;
    const systemBarProperties: window.SystemBarProperties = {
      statusBarColor: '#00000000',
      isStatusBarLightIcon: false,
      statusBarContentColor: currentColorMode ? '#ff000000' : '#ffffffff',
      navigationBarColor: '#00000000',
      navigationBarContentColor: '#ff000000',
    };
    try {
      this.mainWindow?.setWindowSystemBarProperties(systemBarProperties);
    } catch (err) {
      HiLog.e(TAG, `setNavigationBarColor err: ${err}`);
    }
  }
}