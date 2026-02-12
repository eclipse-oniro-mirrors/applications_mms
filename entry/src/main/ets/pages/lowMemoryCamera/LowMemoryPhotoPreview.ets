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
import { image } from '@kit.ImageKit';
import { display, router } from '@kit.ArkUI';
import LowMemoryCameraController from './LowMemoryCameraController';
import { BusinessError } from '@kit.BasicServicesKit';
import HiLog from '../../utils/HiLog';
import DotUtil from '../../utils/MmsDot/DotUtils';
import MMAttachmentAreaController from '../../views/AttachmentArea/MMAttachmentAreaController';
import { AlertDialog } from '@ohos.arkui.advanced.Dialog';

const TAG = 'LowMemoryPhotoPreview';
enum ButtonType {
  NOT_SAVE = 0,
  SAVE = 1,
}

@Entry
@Component
  /* 低内存相机预览照片界面 */
struct LowMemoryPhotoPreview {
  private context = getContext(this);
  private screenShot = AppStorage.get('pixelMaps') as image.PixelMap;
  private imageHeight = this.getImageHeight();

  getImageHeight () {
    try {
      return (display.getDefaultDisplaySync().width / 3) * 4
    } catch (err) {
      HiLog.e(TAG, `getDefaultDisplaySync error, code: ${err.code}, message: ${err.message},`);
      return 0
    }
  }

  private releasePixelMap() {
    if (this.screenShot !== undefined) {
      this.screenShot.release().then(() => {
        HiLog.i(TAG, `Succeeded in releasing pixelmap object`);
      }).catch((e: BusinessError) => {
        HiLog.i(TAG, `releasePixelMap fail, error: ${JSON.stringify(e)}`);
      })
    }
  }

  // 判断当前彩信附件区存在vcard后，弹框询问是否替换现有附件
  needReplaceVcard: CustomDialogController = new CustomDialogController({
    builder: AlertDialog({
      primaryTitle: $r('app.string.attachment_replace_tip'),
      content: $r('app.string.attachment_replace_dialog_tip'),
      primaryButton: {
        value: $r('app.string.cancel'),
        buttonStyle: ButtonStyleMode.TEXTUAL,
        action: () => {
          this.needReplaceVcard?.close();
        },
      },
      secondaryButton: {
        value: $r('app.string.ok'),
        buttonStyle: ButtonStyleMode.TEXTUAL,
        action: () => {
          MMAttachmentAreaController.getInstance().replaceVcard(this.context, async () => {
            await LowMemoryCameraController.setPicture(this.screenShot, this.context);
            LowMemoryCameraController.releaseSession();
            this.releasePixelMap();
          })
        }
      }
    }),
    alignment: DialogAlignment.Center,
    autoCancel: false,
  });

  onPageHide(): void {
    if (MMAttachmentAreaController.getInstance().hasNeedReplaceVcard()) {
      return;
    }
    this.releasePixelMap();
  }

  build() {
    Column() {
      Image(this.screenShot)
        .objectFit(ImageFit.Contain)
        .height(px2vp(this.imageHeight))
        .margin({ top: '78vp' })

      Row() {
        Column() {
          SymbolGlyph($r('sys.symbol.xmark'))
            .width(24)
            .height(24)
            .fontSize('24vp')
            .fontColor([$r('sys.color.font_on_primary')])
            .draggable(false)
        }
        .width(56)
        .height(56)
        .border({ radius: 28 })
        .backgroundColor($r('sys.color.icon_on_tertiary'))
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .onClick(() => {
          router.back();
          DotUtil.getInstance().reportLowMemoryPhotoPreview(ButtonType.NOT_SAVE);
        })

        Column() {
          SymbolGlyph($r('sys.symbol.checkmark'))
            .width(24)
            .height(24)
            .fontSize('24vp')
            .fontColor([$r('sys.color.font_on_primary')])
            .draggable(false)
        }
        .width(56)
        .height(56)
        .border({ radius: 28 })
        .backgroundColor($r('sys.color.icon_on_tertiary'))
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .onClick(async () => {
          DotUtil.getInstance().reportLowMemoryPhotoPreview(ButtonType.SAVE);
          if (MMAttachmentAreaController.getInstance().hasNeedReplaceVcard()) {
            this.needReplaceVcard.open();
            router.back({ url: 'pages/index' });
            return;
          }
          await LowMemoryCameraController.setPicture(this.screenShot, this.context);
          router.back({ url: 'pages/index' });
          LowMemoryCameraController.releaseSession();
        })
      }
      .height(72)
      .width('100%')
      .padding({ left: 24, right: 24 })
      .margin({ bottom: 80 })
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)
    }
    .backgroundColor($r('sys.color.black'))
    .height('100%')
    .justifyContent(FlexAlign.SpaceBetween)
  }
}