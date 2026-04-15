/**
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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
import { Highlight, HighlightsOptions, HighlightType } from '../../utils/Highlight';
import HiLog from '../../utils/HiLog';

const TAG = 'LocationPermissionDialog';

@Preview
@CustomDialog
export struct LocationPermissionDialog {
  controller?: CustomDialogController;
  pageStack?: NavPathStack;
  confirmAction?: () => void;
  cancelAction?: () => void;
  privacyAction?: () => void;


  private cancelClick() {
    this.controller?.close();
    HiLog.i(TAG, 'User disagree location privacy.')
    if (this.cancelAction) {
      this.cancelAction();
    }
  }

  private agreeClick() {
    this.controller?.close();
    HiLog.i(TAG, 'User agree location privacy.')
    if (this.confirmAction) {
      this.confirmAction();
    }
  }
  private privacyClick() {
    this.controller?.close();
    HiLog.i(TAG, 'User open location privacy.')
    if (this.privacyAction) {
      this.privacyAction();
    }
  }

  build() {
    Column() {
      Text($r('app.string.location_privacy_dialog_title'))
        .width('100%')
        .textAlign(TextAlign.Start)
        .fontSize($r('sys.float.ohos_id_text_size_headline8'))
        .fontColor($r('sys.color.ohos_id_color_text_primary'))
        .lineHeight(27)
        .fontWeight(FontWeight.Medium)
        .margin({ bottom: 16 })

      Text($r('app.string.location_privacy_dialog_subtitle'))
        .width('100%')
        .textAlign(TextAlign.Start)
        .fontSize($r('sys.float.ohos_id_text_size_headline9'))
        .fontColor($r('sys.color.ohos_id_color_text_primary'))
        .lineHeight(21)
        .fontWeight(FontWeight.Regular)
        .margin({ bottom: 16 })

      this.textContent()
      this.menus()
    }
    .width('100%')
    .padding({ left: 24, right: 24, top: 14, bottom: 16 })
  }

  @Builder
  menus() {
    Row() {
      Button() {
        Text($r('app.string.cancel'))
          .textAlign(TextAlign.Center)
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.ohos_id_color_text_primary_activated'))
          .fontWeight(FontWeight.Medium)
          .fontFamily('HarmonyHeiTi')
          .lineHeight(21)
      }
      .backgroundColor($r('sys.color.ohos_id_color_background_transparent'))
      .layoutWeight(1)
      .height(40)
      .onClick(() => {this.cancelClick()})

      Divider()
        .vertical(true)
        .strokeWidth('2px')
        .height(24)
        .color($r('sys.color.ohos_id_color_list_separator'))

      Button() {
        Text($r('app.string.agree'))
          .textAlign(TextAlign.Center)
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.ohos_id_color_text_primary_activated'))
          .fontWeight(FontWeight.Medium)
          .fontFamily('HarmonyHeiTi')
          .lineHeight(21)
      }
      .backgroundColor($r('sys.color.ohos_id_color_background_transparent'))
      .layoutWeight(1)
      .height(40)
      .onClick(() => {this.agreeClick()})
    }
    .width('100%')
  }

  @Builder
  textContent() {
    Text() {
      ForEach(Highlight.getInstance().resourceStrToHighlight(
        $r('app.string.location_privacy_dialog_hint'),
        $r('app.string.location_privacy_dialog_hint_1'),
        $r('app.string.location_privacy_dialog_hint_2'),
        $r('app.string.location_privacy_dialog_hint_3'),
        $r('app.string.location_privacy_dialog_hint_4')
      ), (item: HighlightsOptions, index: number) => {
        this.newLocalBuilder(item, index)
      })
    }
    .width('100%')
    .textAlign(TextAlign.Start)
    .fontSize($r('sys.float.ohos_id_text_size_sub_title3'))
    .lineHeight(21)
    .margin({ bottom: 8 })
  }

  @Builder
  newLocalBuilder(item: HighlightsOptions, index: number) {
    if (item.type === HighlightType.normal) {
      Span(item.text);
    } else {
      Span(item.text)
        .fontWeight(FontWeight.Bold)
        .fontColor(
          // The "network" and "location" color is black.(RTL layout is not adapted!)
          (index === 1 || index === 3 || index === 4)
            ? $r('sys.float.ohos_id_text_size_sub_title3')
            : $r('sys.color.ohos_id_color_text_primary_activated')
        )
        .onClick(() => {
          this.privacyClick();
        });
    }
  }

}