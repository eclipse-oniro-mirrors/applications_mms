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

import curves from '@ohos.curves';
import HiLog from '../../utils/HiLog';

const TAG = 'AnimationViewModel';

/**
 * 动效viewModel
 */
@Observed
export class AnimationViewModel {
  /**
   * 标题水平位移
   */
  public translateTitle: number | string;
  /**
   * 标题透明度
   */
  public titleOpacity: number;
  /**
   * 按钮透明度
   */
  public btnOpacity: number;
  /**
   * 动效开关
   */
  public isNeedAnimation: boolean = true;

  /**
   * 构造函数
   *
   * @param translateTitle 标题水平位移
   * @param titleOpacity 标题透明度
   * @param backOpacity 按钮透明度
   */
  constructor(translateTitle: number | string, titleOpacity: number, backOpacity: number) {
    this.translateTitle = translateTitle;
    this.titleOpacity = titleOpacity;
    this.btnOpacity = backOpacity;
  }

  /**
   * 无需动效时，更新参数
   */
  public noAnimation() {
    HiLog.i(TAG, `noAnimation start`);
    this.isNeedAnimation = false;
    this.translateTitle = 0;
    this.titleOpacity = 1;
    this.btnOpacity = 1;
  }

  /**
   * 标题无需显示时，更新参数
   */
  public noTitle() {
    HiLog.i(TAG, `noTitle start`);
    this.isNeedAnimation = false;
    this.translateTitle = 0;
    this.titleOpacity = 0;
    this.btnOpacity = 0;
  }

  /**
   * 从父页面进入子页面时，子页面标题动效
   */
  public enterAnimation() {
    if (!this.isNeedAnimation) {
      HiLog.e(TAG, `no enterAnimation required`);
      return;
    }
    // 位移动效
    animateTo({
      curve: curves.interpolatingSpring(0.0, 1.0, 342.0, 37.0)
    }, () => {
      this.translateTitle = 0;
    });
    // 标题透明度动效
    animateTo({
      duration: 149.97,
      delay: 33.37,
      curve: Curve.Sharp
    }, () => {
      this.titleOpacity = 1;
    });
    // 按钮透明度
    animateTo({
      duration: 200,
      delay: 150,
      curve: Curve.Sharp
    }, () => {
      this.btnOpacity = 1;
    });
  }

  /**
   * 从子页面返回父页面时，子页面标题动效
   */
  public backAnimation() {
    if (!this.isNeedAnimation) {
      HiLog.e(TAG, `no backAnimation required`);
      return;
    }
    // 位移动效
    animateToImmediately({
      curve: curves.interpolatingSpring(0.0, 1.0, 342.0, 37.0), onFinish: () => {
      }
    }, () => {
      this.translateTitle = '40%';
    });
    // 标题透明度动效
    animateToImmediately({
      duration: 150,
      delay: 16.67,
      curve: Curve.Sharp,
      onFinish: () => {
      }
    }, () => {
      this.titleOpacity = 0;
    });
    // 按钮透明度
    animateToImmediately({
      duration: 66.67,
      delay: 0,
      curve: Curve.Sharp,
      onFinish: () => {
      }
    }, () => {
      this.btnOpacity = 0;
    });
  }
}