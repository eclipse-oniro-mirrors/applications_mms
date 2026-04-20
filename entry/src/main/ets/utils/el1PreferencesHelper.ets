/**
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { preferences } from '@kit.ArkData';
import { common, contextConstant } from '@kit.AbilityKit';
import HiLog from './HiLog';

const TAG: string = 'El1PreferencesHelper';

class El1PreferencesHelper {
  private dataPreferences?: preferences.Preferences;

  init(context: Context) {
    if (context == null) {
      HiLog.e(TAG, 'init ctx is null');
      return;
    }
    if (this.dataPreferences) {
      HiLog.i(TAG, 'El1MmsDb is already ready');
      return;
    }
    let areaMode: contextConstant.AreaMode = contextConstant.AreaMode.EL1;
    let areaModeContext: common.Context;
    try {
      areaModeContext = context.createAreaModeContext(areaMode);
      // 首选项底层根据包名，默认配置GSKV存储模式，支持多进程
      let options: preferences.Options = { name: 'El1MmsDb'};
      this.dataPreferences = preferences.getPreferencesSync(areaModeContext, options);
      HiLog.i(TAG, 'init El1MmsDb ok');
    } catch (error) {
      HiLog.i(TAG, 'init error:%{public}s', JSON.stringify(error));
    }
  }

  set(key: string, value: preferences.ValueType) {
    if (!this.dataPreferences) {
      HiLog.i(TAG, 'this.dataPreferences is null');
      return;
    }
    try {
      this.dataPreferences.putSync(key, value);
    } catch (error) {
      HiLog.i(TAG, `set key ${key} error = ${JSON.stringify(error)}`);
    }
  }

  get(key: string, defValue: preferences.ValueType): preferences.ValueType {
    if (!this.dataPreferences) {
      HiLog.i(TAG, 'this.dataPreferences is null, use defValue');
      return defValue;
    }
    let value: preferences.ValueType = defValue;
    try {
      value = this.dataPreferences.getSync(key, defValue);
    } catch (error) {
      HiLog.i(TAG, `get key ${key} error = ${JSON.stringify(error)}`);
    }
    return value;
  }
}
export default new El1PreferencesHelper();