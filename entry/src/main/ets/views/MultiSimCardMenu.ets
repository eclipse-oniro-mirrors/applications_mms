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
import MmsPreferences from "../utils/MmsPreferences";
import common from "../data/commonData";

/**
 * Custom multi-SimCard pop-up menu
 */
@Component
export struct MultiSimCardMenu {
  @Prop slotId: number;
  private spnOfSim1: string = MmsPreferences.getInstance().getSpnOfSim1();
  private spnOfSim2: string = MmsPreferences.getInstance().getTelephoneNumberOfSim2();
  private telephoneNumberOfSim1: string = MmsPreferences.getInstance().getTelephoneNumberOfSim1();
  private telephoneNumberOfSim2: string = MmsPreferences.getInstance().getTelephoneNumberOfSim2();

  @Builder PopupBuilder() {
    Column() {
      List() {
        ListItem() {
          Button({ type: ButtonType.Normal }) {
            Column() {
              Row() {
                Image($rawfile('icon/icon_mms_sim_card_1.svg'))
                  .width(15)
                  .height(18)
                Text(this.spnOfSim1)
                  .fontSize('16vp')
                  .fontWeight(FontWeight.Medium)
                  .fontColor($r("sys.color.ohos_id_color_text_primary"))
                  .padding({ left: 2 })
              }
              Text(this.telephoneNumberOfSim1)
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
            this.slotId = common.int.SIM_ONE;
            MmsPreferences.getInstance().setValueToMap(common.string.KEY_OF_SELECTED_SLOTID, this.slotId);
          })
        }
        ListItem() {
          Button({ type: ButtonType.Normal }) {
            Column() {
              Row() {
                Image($rawfile('icon/icon_mms_sim_card_2.svg'))
                  .width(15)
                  .height(18)
                Text(this.spnOfSim2)
                  .fontSize('16vp')
                  .fontWeight(FontWeight.Medium)
                  .fontColor($r("sys.color.ohos_id_color_text_primary"))
                  .padding({ left: 2 })
              }
              Text(this.telephoneNumberOfSim2)
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
            this.slotId = common.int.SIM_TWO;
            MmsPreferences.getInstance().setValueToMap(common.string.KEY_OF_SELECTED_SLOTID, this.slotId);
          })
        }
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
    Row() {
      Image(this.slotId == 0 ? $rawfile("icon/ic_message_card1.svg") : $rawfile("icon/ic_message_card2.svg"))
        .width(24)
        .height(24)
      Image($rawfile("icon/ic_public_spinner.svg"))
        .width(12)
        .height(24)
    }
    .size({ width: 36, height: 24 })
    .bindMenu(this.PopupBuilder)
    .onClick(() => {
      this.spnOfSim1 = MmsPreferences.getInstance().getSpnOfSim1();
      this.spnOfSim2 = MmsPreferences.getInstance().getSpnOfSim2();
      this.telephoneNumberOfSim1 = MmsPreferences.getInstance().getTelephoneNumberOfSim1();
      this.telephoneNumberOfSim2 = MmsPreferences.getInstance().getTelephoneNumberOfSim2();
    })
  }
}