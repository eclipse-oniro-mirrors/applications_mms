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
import Window from '@ohos.window';
import window from '@ohos.window';
import HiLog from '../utils/HiLog';
import { BusinessError } from '@ohos.base';
import { display } from '@kit.ArkUI';

const TAG = 'GlobalHelper';

export class GlobalContext {
  public static release() {
    if (GlobalContext.instance) {
      GlobalContext.instance._objects = new Map<string, Object>();
      GlobalContext.instance = undefined
    }
  }

  private constructor() {
  }

  private static instance: GlobalContext | undefined = undefined;
  private _objects = new Map<string, Object>();

  public static getContext(): GlobalContext {
    if (!GlobalContext.instance) {
      GlobalContext.instance = new GlobalContext();
    }
    return GlobalContext.instance;
  }

  getObject(value: string): Object | Window.WindowStage {
    return this._objects.get(value) as Object;
  }

  setObject(key: string, objectClass: Object | null | Window.WindowStage): void {
    this._objects.set(key, objectClass as Object);
  }

  hasKey(key: string): boolean {
    return this._objects.has(key)
  }
}


/* 设置屏幕是否常亮(播放语音时需要保证页面常亮) */
export function setWindowKeepScreenState(isKeepScreenOn: boolean) {
  HiLog.i(TAG, 'setWindowKeepScreenState Start!');
  let windowStage = GlobalContext.getContext().getObject('mmsWindowStage') as window.WindowStage;
  windowStage.getMainWindow((err, data: window.Window) => {
    if (err.code) {
      HiLog.e(TAG, 'Failed to obtain the main window.');
      return;
    }
    let windowClass: window.Window = data;
    windowClass.setWindowKeepScreenOn(isKeepScreenOn, (err: BusinessError) => {
      if (err.code) {
        HiLog.e(TAG, `Failed to set the screen to be always on. Cause code: ${err.code}, message: ${err.message}`);
        return
      }
      HiLog.i(TAG, 'Succeeded in setting the screen to be always on.');
    });
  })
}

export function pxs2vps(pxs: number[]): Promise<number[]> {
  // this function is for px2vp which replace sdk px2vp
  // which cannot be used in the for  windows create stage because it  async
  let promise: Promise<number[]> = new Promise((resolve, reject) => {
    display.getAllDisplays().then((data) => {
      if (data && data.length > 0) {
        const displayClass = data[0]
        if (displayClass.densityPixels != 0) {
          let vps: number[] = []
          for (const px of pxs) {
            let vp = px / displayClass.densityPixels;
            vps.push(vp);
          }
          HiLog.i(TAG, `px2vp px:${pxs} vp:${vps}`);
          return resolve(vps);
        }
      }
      HiLog.e(TAG, 'getAllDisplays fail');
      return reject();
    }).catch((err: BusinessError) => {
      HiLog.e(TAG, 'getAllDisplays error: ' + JSON.stringify(err));
      return reject(err);
    })
  });
  return promise;
}