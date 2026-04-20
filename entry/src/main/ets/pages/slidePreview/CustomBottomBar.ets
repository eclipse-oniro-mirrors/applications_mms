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

interface BarStyleType {
  iconName?: Resource,
  iconFontColor?: ResourceColor[],
  textName?: Resource,
  textFontColor?: ResourceColor
  isDisabled?: boolean,
  isHidden?: boolean
}

const TAG = 'BottomBar'

export declare class BottomBarOption {
  public barStyle: BarStyleType;
  public clickAction?: (() => void) | null
}

@Component
export struct BottomBar {
  barStyle: BarStyleType = {};
  clickAction: (() => void) | null = null;
  defaultIconFontColor: ResourceColor[] = [$r('sys.color.ohos_id_color_primary')];
  defaultTextFontColor: ResourceColor = $r('sys.color.ohos_id_color_toolbar_text');

  @Styles
  normalStylesMenu(){
    .backgroundColor(Color.Transparent)
  }

  @Styles
  pressedStylesMenu(){
    .backgroundColor($r('sys.color.ohos_id_color_click_effect'))
    .borderRadius($r('sys.float.ohos_id_corner_radius_clicked'))
  }

  @Styles
  actionButtonPressStyles(){
    .stateStyles({
      normal: this.normalStylesMenu,
      pressed: this.pressedStylesMenu
    })
  }

  build() {
    Column() {
      Column() {
        SymbolGlyph(this.barStyle?.iconName)
          .width(24)
          .height(24)
          .margin({ top: 5 })
          .draggable(false)
          .fontColor(this.barStyle?.iconFontColor || this.defaultIconFontColor)
          .fontSize('24vp')
        Text(this.barStyle?.textName)
          .fontSize('10vp')
          .margin({ top: 4 })
          .fontColor(this.barStyle?.textFontColor || this.defaultTextFontColor)
          .fontWeight(FontWeight.Medium)
      }
      .height('100%')
      .width('100%')
      .actionButtonPressStyles()
      .borderRadius(8)
      .justifyContent(FlexAlign.Center)
    }
    .width('20%')
    .height('100%')
    .opacity(this.barStyle?.isDisabled ? 0.4 : 1)
    .enabled(!this.barStyle?.isDisabled)
    .visibility(this.barStyle?.isHidden ? Visibility.None : Visibility.Visible)
    .onClick(() => {
      if (this.clickAction !== null && typeof this.clickAction === 'function') {
        this.clickAction()
      }
    })
  }
}