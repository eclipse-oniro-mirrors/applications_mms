/**
 * Copyright (c) 2022 Huawei Device Co., Ltd.
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
import indexCtrl from './indexController'

@Entry
@Component
struct Index {
  @State mIndexCtrl: typeof indexCtrl = indexCtrl

  /**
   * 函数在创建自定义组件的新实例后，在执行其build函数之前执行。
   * 允许在aboutToAppear函数中改变状态变量，这些更改将在后续执行build函数中生效。
   */
  aboutToAppear() {
    this.mIndexCtrl.onInit();
  }

  /**
   * 函数在自定义组件析构消耗之前执行。
   * 不允许在aboutToDisappear函数中改变状态变量，特别是@Link变量的修改可能会导致应用程序行为不稳定。
   */
  aboutToDisappear() {
  }

  /**
   * 当此页面显示时触发一次。包括路由过程、应用进入前后台等场景，仅@Entry修饰的自定义组件生效。
   */
  onPageShow() {
    this.mIndexCtrl.onShow();
  }

  /**
   * 当此页面消失时触发一次。包括路由过程、应用进入前后台等场景，仅@Entry修饰的自定义组件生效。
   */
  onPageHide() {
    this.mIndexCtrl.onHide();
  }

   /**
    * 当用户点击返回按钮时触发，，仅@Entry修饰的自定义组件生效。
    * 返回true表示页面自己处理返回逻辑, 不进行页面路由。
    * 返回false表示使用默认的返回逻辑。
    * 不返回值会作为false处理。
    */
  onBackPress() {
  }

  build() {
    Flex({ direction: FlexDirection.Column }) {
    }
    .width('100%')
    .height('100%')
  }
}