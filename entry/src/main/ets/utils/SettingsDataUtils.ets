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
import settings from '@ohos.settings';
import type { AsyncCallback } from '@ohos.base';
import HiLog from './HiLog';

const TAG: string = 'SettingsDataUtils';

export default class SettingsDataUtils {

  private static instance: SettingsDataUtils;

  private constructor() {}

  public static getInstance(): SettingsDataUtils {
    if (!SettingsDataUtils.instance) {
      SettingsDataUtils.instance = new SettingsDataUtils();
    }
    return SettingsDataUtils.instance;
  }

  registerKeyObserver(key: string, observer: AsyncCallback<void>, context: Context): boolean {
    try {
      return settings.registerKeyObserver(context, key,
        settings.domainName.DEVICE_SHARED, observer);
    } catch (e) {
      HiLog.e(TAG, `${key} registerKeyObserver err`);
      return false;
    }
  }

  unregisterKeyObserver(key: string, context: Context): boolean {
    return settings.unregisterKeyObserver(context, key, settings.domainName.DEVICE_SHARED);
  }
}