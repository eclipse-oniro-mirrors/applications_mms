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
@Builder
function wifiNoticeDialogBuildContent(title: Resource, content: Resource): void {
  Column() {
    Text(title)
      .fontSize($r('sys.float.Title_S'))
      .fontFamily('HarmonyHeiTi')
      .fontWeight(FontWeight.Bold)
      .fontColor($r('sys.color.font_primary'))
      .lineHeight(27)
      .textAlign(TextAlign.Center)

    Row() {
      Text(content)
        .fontSize($r('sys.float.Body_L'))
        .fontFamily('HarmonyHeiTi')
        .fontWeight(FontWeight.Regular)
        .fontColor($r('sys.color.font_primary'))
        .lineHeight(21)
        .textAlign(TextAlign.JUSTIFY)
    }.justifyContent(FlexAlign.Center)
    .margin({ top: 15.5 })
  }
}

@CustomDialog
export struct WifiNoticeDialog {
  controller?: CustomDialogController;
  title: Resource | null = null;
  mainContent: Resource | null = null;
  confirm: () => void = () => {
  };
  cancel: () => void = () => {
  };

  build() {
    if (this.title && this.mainContent) {
      Column() {
        Row() {
          wifiNoticeDialogBuildContent(this.title, this.mainContent)
        }
        .padding({
          left: 24,
          right: 24,
          top: 15
        })
        .margin({ bottom: 7.5 })
        .width('100%')
        .justifyContent(FlexAlign.Center)

        Row() {
          Button($r('app.string.cancel'))
            .layoutWeight(1)
            .buttonStyle(ButtonStyleMode.TEXTUAL)
            .onClick(this.cancel)

          Divider()
            .vertical(true)
            .height(24)
            .width(0.5)
            .strokeWidth('1px')
            .lineCap(LineCapStyle.Round)
            .margin({
              left: 3.75,
              right: 3.75,
              top: 8,
              bottom: 8
            })
            .color($r('sys.color.comp_divider'))
          Button($r('app.string.welcome_page_btn_continue_text'))
            .layoutWeight(1)
            .buttonStyle(ButtonStyleMode.TEXTUAL)
            .onClick(this.confirm)
        }
        .width('100%')
        .height(56)
        .padding({ bottom: 16, left: 16, right: 16 })
        .justifyContent(FlexAlign.Center)
      }
      .width('100%')
      .backgroundColor($r('sys.color.ohos_id_color_dialog_bg'))
      .borderRadius(32)
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.Center)
    }
  }
}

