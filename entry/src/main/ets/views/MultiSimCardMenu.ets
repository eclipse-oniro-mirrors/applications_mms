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

/**
 * Custom multi-SimCard pop-up menu
 */
@Component
export struct MultiSimCardMenu {
  @Prop slotId: number;
  private cardImage: boolean;
  private multiSimCardItems: Array<any>;

  @Builder PopupBuilder() {
    Column() {
      List() {
        ForEach(this.multiSimCardItems, (item, index) => {
          ListItem() {
            Button({type: ButtonType.Normal}) {
              Column(){
                Row() {
                  Image(item.img)
                    .width(15)
                    .height(18)
                  Text(item.operator)
                    .fontSize('16vp')
                    .fontWeight(FontWeight.Medium)
                    .fontColor($r("sys.color.ohos_id_color_text_primary"))
                    .padding({ left: 2 })
                }
                Text(item.mobileNumber)
                  .padding({ left: 19, top: 2 })
                  .fontSize('14vp')
                  .fontWeight(FontWeight.Regular)
                  .fontColor($r("sys.color.ohos_id_color_text_secondary"))
              }
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Start)
              .padding({ left: 16 })
              .width('100%')
            }
            .backgroundColor($r("sys.color.ohos_id_color_background_transparent"))
            .width('100%')
            .height('64vp')
            .onClick(() => {
              item.action();
            })
          }
        })
      }
      .listDirection(Axis.Vertical)
      .divider({
        strokeWidth: 0.5,
        color: $r("sys.color.ohos_id_color_list_separator"),
        startMargin: 17,
        endMargin: 17
      })
      .edgeEffect(EdgeEffect.Spring)
      .chainAnimation(false)
      .width('170vp')
      .height('136vp')
      .borderRadius(16)
    }
  }

  build() {
    if (this.cardImage) {
      Row() {
        Image(this.slotId == 0 ? $rawfile("icon/ic_message_card1.svg") : $rawfile("icon/ic_message_card2.svg"))
          .width(22)
          .height(22)
        Image($rawfile("icon/icon_down.svg"))
          .width(16)
          .height(22)
      }
      .bindMenu(this.PopupBuilder)
    }
  }
}