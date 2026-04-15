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
import HiLog from './HiLog';
import { systemParameterEnhance } from '@kit.BasicServicesKit';

/**
 * 是否ADU样机设置key值
 */
export const IS_RETAIL_DEVICE = 'const.dfx.enable_retail';
export const EMPTY_STRING = '';
/**
 * 门店样机
 */
export const RETAIL_DEVICE = 'true';
const TAG = 'SystemPropertyUtils';

export class SystemPropertyUtils {
  /**
   * 是否ADU门店演示样机
   *
   * @returns true: 是 false：不是
   */
  public static isRetailDevice(): boolean {
    let isRetail = EMPTY_STRING;
    try {
      isRetail = systemParameterEnhance.getSync(IS_RETAIL_DEVICE);
    } catch (err) {
      HiLog.e(TAG, `isRetailDevice error. code: ${err?.code}, message: ${err?.message}`);
    }
    HiLog.i(TAG, `isRetail is ${isRetail}.`);
    return isRetail === RETAIL_DEVICE;
  }
}