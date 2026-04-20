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
import dataPreferences from '@ohos.data.preferences';
import common from '@ohos.app.ability.common';
import Hilog from './HiLog';
import { BusinessError } from '@ohos.base';
import preferences from '@ohos.data.preferences';

const TAG = 'EmergencyWarningPreferencesUtils';

export default class RcsDataPreferences {
  private static sInstance: RcsDataPreferences;
  private rcsInfoPreferences: dataPreferences.Preferences | null = null;
  private static readonly RCS_INFO_PREFERENCES_NAME = 'rcs_info_preferences_name';

  private constructor() {
  }

  static getInstance() {
    if (!RcsDataPreferences.sInstance) {
      RcsDataPreferences.sInstance = new RcsDataPreferences();
    }
    return RcsDataPreferences.sInstance;
  }

  isRcsInfoPreferencesExist() {
    return Boolean(this.rcsInfoPreferences);
  }

  getSyncByPreferences(key: string, defValue: preferences.ValueType) {
    return this.rcsInfoPreferences?.getSync(key, defValue) || defValue;
  }

  async getByPreferences(key: string, defValue: preferences.ValueType) {
    const value = await this.rcsInfoPreferences?.get(key, defValue);
    return value || defValue;
  }

  async hasByPreferences(key: string): Promise<boolean> {
    let tempBol: boolean | undefined | void = false;
    try {
      tempBol = await this.rcsInfoPreferences?.has(key).catch((e: Object) => {
        Hilog.e(TAG, `hasByPreferences error: ${JSON.stringify(e)}`);
      });
    } catch (e) {
      Hilog.e(TAG, `hasByPreferences error: ${JSON.stringify(e)}`);
    }
    return tempBol || false;
  }

  async putAndFlushInPreferences(key: string, value: dataPreferences.ValueType) {
    if (this.rcsInfoPreferences) {
      this.rcsInfoPreferences.putSync(key, value);
      await this.flushEmergencyWarningInfoPreferences();
    }
  }

  async deleteAndFlushInPreferences(key: string) {
    if (this.rcsInfoPreferences) {
      this.rcsInfoPreferences.deleteSync(key);
      await this.flushEmergencyWarningInfoPreferences();
    }
  }

  async loadRcsInfoPreferences(context: common.Context, callback?: () => void) {
    let options: dataPreferences.Options = {
      name: RcsDataPreferences.RCS_INFO_PREFERENCES_NAME
    };

    try {
      await dataPreferences.getPreferences(context, options)
        .then((object: dataPreferences.Preferences) => {
          this.rcsInfoPreferences = object;
          Hilog.i(TAG, 'Succeeded in getting preferences.');
          if (callback) {
            callback()
          }
        }).catch((err: BusinessError) => {
          this.rcsInfoPreferences = null;
          Hilog.e(TAG, 'Failed to get preferences. code =' + err.code + ', message =' + err.message);
          if (callback) {
            callback()
          }
        });
    } catch (e) {
      this.rcsInfoPreferences = null;
      Hilog.e(TAG, 'Failed to get preferences, error:' + JSON.stringify(e));
      if (callback) {
        callback()
      }
    }
  }

  private async flushEmergencyWarningInfoPreferences() {
    if (!this.rcsInfoPreferences) {
      return;
    }

    try {
      await this.rcsInfoPreferences.flush().then(() => {
        Hilog.i(TAG, 'Succeeded in flushing.');
      }).catch((err: BusinessError) => {
        let code = (err as BusinessError).code;
        let message = (err as BusinessError).message;
        Hilog.e(TAG, `Failed to flush. Code:${code}, message:${message}`);
      })
    } catch (err) {
      let code = (err as BusinessError).code;
      let message = (err as BusinessError).message;
      Hilog.e(TAG, `Failed to flush. Code:${code}, message:${message}`);
    }
  }
}