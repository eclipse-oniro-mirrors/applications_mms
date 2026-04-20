/**
 * Copyright (c) 2023 Huawei Device Co., Ltd.
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

import data_preferences from '@ohos.data.preferences';
import HiLog from '../utils/HiLog';
import { BusinessError } from '@ohos.base'
import settings from '@ohos.settings';
import common from '../data/commonData';

const NAME: string = 'MmsStore';
const TAG: string = 'SharedPreferencesUtils';
export interface AttributesObject {
  key: string,
  value: string
}
export interface CovertObject {
  _name: string,
  _text: string,
  _type: string,
  _attributes: AttributesObject,
  _declaration: Object,
  _elements: CovertObject[]
}
class SharedPreferencesUtils {
  private mPreferences?: data_preferences.Preferences | null;
  private context?: Context;

  constructor() {
  }

  /*
   * init if Call From serviceAbility context is Null
   *@param ctx Context used for dataShare
   */
  init(ctx: Context) {
    if (ctx == null) {
      HiLog.e(TAG, 'init ctx is null');
      return
    }
    this.context = ctx.getApplicationContext();
    this.mPreferences = this.getPreferencesSync();
    HiLog.i(TAG, 'SharedPreferencesUtils init');
  }

  release() {
    this.mPreferences = null;
  }

  removePreferences(ctx: Context) {
    try {
      data_preferences.removePreferencesFromCacheSync(ctx, {name: NAME});
      this.mPreferences = null
      HiLog.i(TAG, 'removePreferences SUCCESS');
    } catch (err) {
      let code = (err as BusinessError).code;
      HiLog.i(TAG, 'Failed to remove preferences. code =' + code);
    }
  }

  /**
   * getFromPreferences
   *
   * @param key to be get
   * @param defValue get default to Preferences
   * @return the value get from Preferences
   */
  public getFromPreferences(key: string, defValue: data_preferences.ValueType):data_preferences.ValueType {
    if (this.context == null) {
      HiLog.e(TAG, 'getFromPreferences with invalid context, pls init first');
      return defValue;
    }
    let preferences: data_preferences.Preferences = this.getPreferencesSync()!;
    let value: data_preferences.ValueType = defValue;
    try {
      value = preferences.getSync(key, defValue);
    } catch(err) {
      let e: BusinessError = err as BusinessError;
      HiLog.e(TAG, 'Failed to get value code : ' + e.code + ' , message : ' + e.message);
    }
    return value;
  }

  public getFromPreferencesTaskPool(key: string, defValue: data_preferences.ValueType):data_preferences.ValueType {
    if (this.context == null) {
      HiLog.e(TAG, 'getFromPreferences with invalid context, pls init first');
      return defValue;
    }
    let preferences: data_preferences.Preferences = this.getPreferencesSync(true)!;
    let value: data_preferences.ValueType = defValue;
    try {
      value = preferences.getSync(key, defValue);
    } catch(err) {
      let e: BusinessError = err as BusinessError;
      HiLog.e(TAG, 'Failed to get value code : ' + e.code + ' , message : ' + e.message);
    }
    return value;
  }

  /**
   * saveToPreferences
   *
   * @param key save to Preferences
   * @param value save to Preferences
   */
  public saveToPreferences(key: string, value: data_preferences.ValueType) {
    if (this.context == null) {
      HiLog.e(TAG, 'saveToPreferences with invalid context, pls init first');
      return;
    }
    let preferences: data_preferences.Preferences = this.getPreferencesSync()!;
    try {
      preferences.putSync(key, value);
      preferences.flushSync();
      HiLog.i(TAG, `saveToPreferences put success key ${key}`);
    } catch(err) {
      let e: BusinessError = err as BusinessError;
      HiLog.e(TAG, 'saveToPreferences failed code : ' + e.code + ' , message : ' + e.message);
    }
  }

  /**
   * saveToPreferencesTaskPool
   *  TaskPool 等非主线程异步线程使用
   * @param key save to Preferences
   * @param value save to Preferences
   */
  public saveToPreferencesTaskPool(key: string, value: data_preferences.ValueType) {
    if (this.context == null) {
      HiLog.e(TAG, 'saveToPreferencesTaskPool with invalid context, pls init first');
      return;
    }
    let preferences: data_preferences.Preferences = this.getPreferencesSync(true)!;
    try {
      preferences.putSync(key, value);
      preferences.flush();
      HiLog.i(TAG, `saveToPreferencesTaskPool put success key ${key}`);
    } catch(err) {
      let e: BusinessError = err as BusinessError;
      HiLog.e(TAG, 'saveToPreferencesTaskPool failed code : ' + e.code + ' , message : ' + e.message);
    }
  }

  private getPreferencesNoCache() {
    try {
      let preferences: data_preferences.Preferences = data_preferences.getPreferencesSync(this.context, {name: NAME});
      this.mPreferences = preferences;
      return preferences;
    } catch (err) {
      HiLog.e(TAG, `getPreferencesSync error, code: ${err.code}, message: ${err.message} `);
      return null
    }
  }

  public deletePreferences(key: string) {
    HiLog.i(TAG, 'deletePreferences start');
    try {
      if (this.context == null) {
        HiLog.e(TAG, 'deletePreferences with invalid context, pls init first');
        return;
      }
      let preferences: data_preferences.Preferences = this.getPreferencesNoCache()!;
      preferences.deleteSync(key);
      preferences.flush();
      HiLog.i(TAG, 'deletePreferences success');
    } catch(err) {
      let e: BusinessError = err as BusinessError;
      HiLog.e(TAG, 'deletePreferences failed code : ' + e.code + ' , message : ' + e.message);
    }
  }

  public deletePreferencesTaskPool(key: string) {
    HiLog.i(TAG, 'deletePreferences start');
    try {
      if (this.context == null) {
        HiLog.e(TAG, 'deletePreferences with invalid context, pls init first');
        return;
      }
      let preferences: data_preferences.Preferences = this.getPreferencesSync(true)!;
      preferences.deleteSync(key);
      preferences.flush();
      HiLog.i(TAG, 'deletePreferences success');
    } catch(err) {
      let e: BusinessError = err as BusinessError;
      HiLog.e(TAG, 'deletePreferences failed code : ' + e.code + ' , message : ' + e.message);
    }
  }

  public deletePreferencesDelay() {
    HiLog.i(TAG, 'deletePreferencesDelay start');
    this.mPreferences = null;
    data_preferences.removePreferencesFromCacheSync(this.context as Context, {name: NAME});
    HiLog.i(TAG, 'deletePreferencesDelay success');
  }

  private getPreferencesSync(needGetPreferences?: boolean) {
    try {
      if (this.mPreferences == null || needGetPreferences) {
        let preferences: data_preferences.Preferences = data_preferences.getPreferencesSync(this.context, {name: NAME});
        this.mPreferences = preferences;
      }
      let preferences = this.mPreferences;
      return preferences;
    } catch (err) {
      HiLog.e(TAG, `getPreferencesSync error, code: ${err.code}, message: ${err.message} `);
      return null
    }
  }
}

export default new SharedPreferencesUtils();