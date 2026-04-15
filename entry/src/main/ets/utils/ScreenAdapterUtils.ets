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

import { systemParameterEnhance } from '@kit.BasicServicesKit';
import LogUtils from '../utils/HiLog';
import Constant from '../data/Constant';


const TAG = 'ScreenAdapterUtils';

export enum FoldPhoneTypeValue {
  /**
   * 无效值
   */
  INVALID_VALUE = -1,
  /**
   * 直板机
   */
  STRAIGHT = 0,
  /**
   * 大折（内折）: X5
   */
  LARGE_FOLD = 1,
  /**
   * 小折叠（只有内折）: pocket
   */
  SMALL_FOLD = 2,
  /**
   * 外折: XS2
   */
  EXTERNAL_FOLD = 3,
  /**
   * 扩展新形态: verde
   */
  EXPANDING_NEW_FORM = 4,
}

export default class ScreenAdapterUtils {
  private static sScreenAdapterUtils: ScreenAdapterUtils;

  public static getInstance(): ScreenAdapterUtils {
    if (ScreenAdapterUtils.sScreenAdapterUtils == null) {
      ScreenAdapterUtils.sScreenAdapterUtils = new ScreenAdapterUtils();
    }
    return ScreenAdapterUtils.sScreenAdapterUtils;
  }

  public static getFoldAblePhoneProductType(): number {
    let foldTypeConfiguration = '';
    try {
      foldTypeConfiguration =
        systemParameterEnhance.getSync(Constant.FOLD_PRODUCT_TYPE_KEY, Constant.DEFAULT_FOLD_CONFIGURATION);
      LogUtils.i(TAG, `get foldTypeConfiguration:${foldTypeConfiguration}`);
      const result = foldTypeConfiguration.split(',');
      if (Array.isArray(result) && result.length > 0) {
        const foldType = Number(result[0]);
        return foldType;
      }
    } catch (err) {
      LogUtils.e(TAG, `get foldTypeConfiguration err:${err?.code}`);
    }
    return FoldPhoneTypeValue.INVALID_VALUE;
  }

  public isVDEFoldPhoneAndFoldedState(): boolean {
    const result = ScreenAdapterUtils.isNewFormFoldPhone()
    LogUtils.i(TAG, `isVDEFoldPhoneAndFoldedState: ${result}`);
    return result;
  }
  /**
   * 判断是否为扩展折叠产品verde
   */
  public static isNewFormFoldPhone(): boolean {
    return ScreenAdapterUtils.getFoldAblePhoneProductType() === FoldPhoneTypeValue.EXPANDING_NEW_FORM;
  }

  public isVDESquareScreen(): boolean {
    let currentWidthBreakpoint = AppStorage.get<number>('currentWidthBreakpoint');
    let currentHeightBreakpoint = AppStorage.get<number>('currentHeightBreakpoint');
    let result = false;
    if (currentWidthBreakpoint == WidthBreakpoint.WIDTH_SM && currentHeightBreakpoint == HeightBreakpoint.HEIGHT_MD) {
      result = true;
    }
    LogUtils.i(TAG, `isVDESquareScreen: ${result} , currentWidthBreakpoint: ${currentWidthBreakpoint} ,
     currentHeightBreakpoint: ${currentHeightBreakpoint}`);
    return result;
  }
}