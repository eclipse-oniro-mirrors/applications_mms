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

import { router, window } from '@kit.ArkUI';
import DotUtil from '../../utils/MmsDot/DotUtils';
import LowMemoryCameraController from './LowMemoryCameraController';

const TAG = 'LowMemoryCamera';
enum ButtonType {
  CLOSE = 0,
  PHOTO = 1,
  FLIP_LENS = 2,
}

@Entry
@Component
  /* 低内存相机主界面 */
struct LowMemoryCamera {
  private context = getContext(this);
  // 窗口切到后台时，返回上一页面
  @StorageLink('windowStageEventType') @Watch('windowStageEventTypeChange') windowStageEventType: window.WindowStageEventType =
    window.WindowStageEventType.SHOWN;

  windowStageEventTypeChange() {
    if (this.windowStageEventType === window.WindowStageEventType.HIDDEN) {
      setTimeout(() => {
        LowMemoryCameraController.releaseSession();
        router.back({ url: 'pages/index' });
      }, 200)
    }
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      XComponent({
        type: XComponentType.SURFACE,
        controller: LowMemoryCameraController.xComponentController
      })
        .onLoad(() => {
          LowMemoryCameraController.openCamera(this.context);
        })

      Row() {
        Column() {
          SymbolGlyph($r('sys.symbol.xmark'))
            .width(24)
            .height(24)
            .fontSize('24vp')
            .fontColor([$r('sys.color.font_on_primary')])
            .draggable(false)
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .border({ width: 1.5, color: $r('sys.color.font_on_primary'), radius: 22 })
        .onClick(() => {
          LowMemoryCameraController.releaseSession();
          router.back();
          DotUtil.getInstance().reportLowMemoryCamera(ButtonType.CLOSE);
        })

        Column() {
          Image($r('app.media.ic_camera_shoot_bar_take_photo'))
            .width(64)
            .height(64)
            .draggable(false)
        }
        .onClick(() => {
          LowMemoryCameraController.videoScreenshot();
          DotUtil.getInstance().reportLowMemoryCamera(ButtonType.PHOTO);
        })

        Column() {
          SymbolGlyph($r('sys.symbol.switch_camera'))
            .width(24)
            .height(24)
            .fontSize('24vp')
            .fontColor([$r('sys.color.font_on_primary')])
            .draggable(false)
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .border({ width: 1.5, color: $r('sys.color.white'), radius: 22 })
        .onClick(() => {
          LowMemoryCameraController.flipLens();
          DotUtil.getInstance().reportLowMemoryCamera(ButtonType.FLIP_LENS);
        })
      }
      .height(72)
      .width('100%')
      .padding({ left: 30, right: 30 })
      .margin({ bottom: 80 })
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)
    }.backgroundColor($r('sys.color.black'))
  }
}