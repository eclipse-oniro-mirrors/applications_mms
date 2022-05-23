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
/** 自定义弹出窗menu组件 */
@Component
export struct MmsMenu {
  @State showPopup: boolean = false;
  private menuItems: Array<any>
  private menuImage: Resource = $rawfile('icon/ic_public_more.svg');
  private sizeType: SizeType = SizeType.LG;
  private placement: Placement = Placement.Bottom;
  private defaultColor: Resource = $r("app.color.white");
  private menuText: Resource = null;
  private menuTextColor: Resource = $r("app.color.main_font_color");

  @Builder PopupBuilder() {
    Column() {
      List() {
        ForEach(this.menuItems, (item, index) => {
          ListItem() {
            Text(item.value)
              .fontSize(16)
              .lineHeight(21)
              .width("100%")
              .height(48)
              .padding({ left: 12, right: 12 })
              .fontWeight(FontWeight.Regular)
              .fontColor(item.enabled ? $r("app.color.main_font_color") : $r("app.color.main_font_color_40"))
              .onClick(() => {
                if (item.enabled) {
                  item.action();
                }
              })
          }
        }, item => JSON.stringify(item))
      }
      .listDirection(Axis.Vertical) // 排列方向
      .divider({ strokeWidth: 0.5, color: $r('app.color.divider_color'), startMargin: 12, endMargin: 12 }) // 每行之间的分界线
      .edgeEffect(EdgeEffect.Spring) // 滑动到边缘效果
      .chainAnimation(false) // 联动特效关闭
    }
    .backgroundColor(this.defaultColor)
    .width(this.sizeType == SizeType.LG ? 186 : 144)
    .borderRadius(16)
    .padding({ top: 4, bottom: 4, left: 4, right: 4 })
  }

  build() {
    Column() {
      Image(this.menuImage)
        .width(24)
        .height(24)
      if (this.menuText != null) {
        Text(this.menuText)
          .fontSize(10)
          .lineHeight(14)
          .fontColor(this.menuTextColor)
          .margin({ top: 3 })
      }
    }
    .onClick(() => {
      this.showPopup = !this.showPopup;
    })
    .bindPopup(this.showPopup, {
      builder: this.PopupBuilder,
      placement: this.placement,
      maskColor: $r("app.color.mask_color"),
      popupColor: $r("app.color.transparent_color"),
      enableArrow: false,
      onStateChange: (e) => {
        if (!e.isVisible) {
          this.showPopup = false;
        }
      }
    })
  }
}