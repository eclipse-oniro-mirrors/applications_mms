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
function permissionDialogBuildContent(title: Resource, content: Resource,
  iconBackgroundColor: ResourceColor): void {
  Column() {
    Row(){
      Text(title)
        .fontSize($r('sys.float.Title_S'))
        .fontFamily('HarmonyHeiTi')
        .fontWeight(FontWeight.Bold)
        .fontColor($r('sys.color.font_primary'))
        .lineHeight(26)
        .textAlign(TextAlign.Center)
        .margin({ top: 15 })
        .width('100%')
    }.justifyContent(FlexAlign.Center)

    Row() {
      Text(content)
        .fontSize($r('sys.float.Body_L'))
        .fontFamily('HarmonyHeiTi')
        .fontWeight(FontWeight.Regular)
        .fontColor($r('sys.color.font_primary'))
        .lineHeight(21)
        .textAlign(TextAlign.Center)
        .width('100%')
    }.justifyContent(FlexAlign.Center)
    .width('100%')
    .margin({ top: 15 })
  }
}

@CustomDialog
export struct PermissionDialog {
  controller?: CustomDialogController;
  icon: Resource | null = null;
  title: Resource | null = null;
  mainContent: Resource | null = null;
  iconBackgroundColor: ResourceColor = '#FFFFFF';
  confirm: () => void = () => {
  };
  cancel: () => void = () => {
  };

  build() {
    if (this.title && this.mainContent) {
      Column() {
        Row() {
          permissionDialogBuildContent(this.title, this.mainContent, this.iconBackgroundColor)
        }
        .padding({
          left: 24,
          right: 24,
        })
        .margin({ bottom: 8 })
        .width('100%')
        .justifyContent(FlexAlign.Center)

        Row() {
          Button($r('app.string.cancel'))
            .width(154)
            .height(40)
            .onClick(this.cancel)
            .buttonStyle(ButtonStyleMode.TEXTUAL)

          Divider()
            .vertical(true)
            .height(24)
            .width(0.5)
            .strokeWidth('2px')
            .lineCap(LineCapStyle.Round)
            .margin({
              left: 7.75,
              right: 7.75,
              top: 8,
              bottom: 8
            })
            .color($r('sys.color.comp_divider'))
          Button($r('app.string.go_setting'))
            .width(154)
            .height(40)
            .buttonStyle(ButtonStyleMode.TEXTUAL)
            .onClick(this.confirm)
        }
        .width('100%')
        .height(40)
        .margin({ bottom: 16 })
        .justifyContent(FlexAlign.Center)
      }
      .width('100%')
      .backgroundColor($r('sys.color.ohos_id_color_dialog_bg'))
      .borderRadius($r('sys.float.corner_radius_level16'))
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.Center)
    }
  }
}

