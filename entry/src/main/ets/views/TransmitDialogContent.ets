/**
 * Copyright (c) 2023 Huawei Device Co., Ltd.
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

import LooseObject from '../data/LooseObject';
import TransmitMessageUtil from '../utils/TransmitMessageUtils';
import DeviceUtil from '../utils/DeviceUtil';
import HiLog from '../utils/HiLog';
import { LengthMetrics } from '@kit.ArkUI';
import MmsPreferences from '../utils/MmsPreferences';
import common from '../data/commonData';

const TAG = 'TransmitDialogTitle';

@Component
export struct TransmitDialogTitle {
  @StorageProp('fontSizeScale') fontSizeScale: number = 1;
  msg: LooseObject | null = null;
  @Link isChecked: boolean;

  build() {
    Column() {
      Row() {
        Text($r('app.string.tap_content_to_edit'))
          .fontSize(14)
          .fontColor($r('sys.color.ohos_id_color_text_secondary'))
      }
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Start)
      .margin({ top: 2, bottom: 2 })
      .visibility((!this.isChecked && TransmitMessageUtil.transmitContentCanEdit(this.msg)) ? Visibility.Visible :
      Visibility.None)
    }
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Center)
    .width('100%')
  }
}

@Component
export struct TransmitDialogBottom {
  @StorageProp('fontSizeScale') fontSizeScale: number = 1;
  @Link isCheckedEnabled: boolean;
  multiSimCard: boolean = false;
  cancel: () => void = () => {};
  simCardClick: (value: number) => void = (value) => {};
  confirm: () => void = () => {};
  @State isPC: boolean = DeviceUtil.isPC()

  aboutToAppear(): void {
    HiLog.i('TransmitDialogBottom', 'aboutToApper multiSimCard is:' + this.multiSimCard);
  }

  build() {
    Flex({ direction: this.multiSimCard ? FlexDirection.Column : FlexDirection.Row,
      justifyContent: FlexAlign.SpaceAround, alignItems: ItemAlign.Center }) {
      if (this.multiSimCard) {
        this.multiSimCardSenior();
        this.cancelButton()
      } else {
        this.cancelButton()
        if (!this.multiSimCard && !this.isPC) {
          Divider()
            .vertical(true)
            .width(8)
            .height(24)
            .color($r('sys.color.ohos_id_color_list_separator'));
        }
        this.forwardButton()
      }
    }
    .height(this.changeHeight())
    .margin({left: 16, right: 16})
  }

  @Builder
  forwardButton() {
    Row() {
      Button($r('app.string.msg_transmit'),
        { type: ButtonType.Normal, buttonStyle: this.isPC ? ButtonStyleMode.NORMAL : undefined, stateEffect: true })
        .fontColor($r('sys.color.ohos_id_color_text_primary_activated'))
        .maxFontScale(2)
        .borderRadius(this.isPC ? 8 : $r('sys.float.ohos_id_corner_radius_button'))
        .backgroundColor(this.isPC ? '#0C000000' : Color.Transparent)
        .width('100%')
        .height('40vp');
    }
    .margin({ start: this.isPC ? LengthMetrics.vp(8) : LengthMetrics.vp(4) })
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
    .height('100%')
    .layoutWeight(1)
    .enabled(this.isCheckedEnabled ? true : false)
    .onClick(() => {
      this.confirm();
    })
    .accessibilityRole(AccessibilityRoleType.BUTTON)
  }

  changeHeight() {
    let dialogHeight: number = 40;
    if (this.fontSizeScale < 1 && !this.multiSimCard) {
      dialogHeight = 40
    } else if (this.multiSimCard) {
      dialogHeight = ((this.fontSizeScale <= 2 ? this.fontSizeScale : 2) * 16 + 25) * 3
    } else if (this.fontSizeScale >= 1 && !this.multiSimCard) {
      dialogHeight = (this.fontSizeScale <= 2 ? this.fontSizeScale : 2) * 16 + 25
    }
    return dialogHeight;
  }

  private getForwardSimCardText(slotId: number): Resource {
    let slotType = MmsPreferences.getInstance().getTypeOfSlot(slotId);
    let slotIndex = MmsPreferences.getInstance().getIndexOfSlot(slotId);
    HiLog.i(TAG, ` getForwardSimCardText ${slotId},${slotType},${slotIndex}`);
    if (slotType === common.simType.ESIM) {
      return $r('app.string.forward_dialog_forward_esim', slotIndex);
    } else {
      return $r('app.string.forward_dialog_forward_sim', slotIndex);
    }
  }

  @Builder
  cancelButton() {
    Row() {
      Button($r('app.string.cancel'),
        { type: ButtonType.Normal, buttonStyle: this.isPC ? ButtonStyleMode.NORMAL : undefined, stateEffect: true })
        .fontColor($r('sys.color.ohos_id_color_text_primary_activated'))
        .borderRadius(this.isPC ? 8 : $r('sys.float.ohos_id_corner_radius_button'))
        .maxFontScale(2)
        .backgroundColor(this.isPC ? '#0C000000' : Color.Transparent)
        .width('100%')
        .height('40vp');
    }
    .margin({
      top: this.multiSimCard ? 4 : 0,
      bottom: this.multiSimCard ? 4 : 0,
      end: this.multiSimCard ? LengthMetrics.vp(0) : this.isPC ? LengthMetrics.vp(8) : LengthMetrics.vp(4)
      })
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
    .layoutWeight(1)
    .onClick(() => {
      this.cancel();
    })
    .height('100%')
    .accessibilityRole(AccessibilityRoleType.BUTTON)
  }

  @Builder
  multiSimCardSenior() {
    Row() {
      Button(this.getForwardSimCardText(common.int.SLOT_ZERO),
        { type: ButtonType.Normal, buttonStyle: this.isPC ? ButtonStyleMode.NORMAL : undefined, stateEffect: true })
        .fontColor($r('sys.color.ohos_id_color_text_primary_activated'))
        .maxFontScale(2)
        .borderRadius(this.isPC ? 8 : $r('sys.float.ohos_id_corner_radius_button'))
        .backgroundColor(this.isPC ? '#0C000000' : Color.Transparent)
        .width('100%')
        .height('40vp')
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
    .height('100%')
    .margin({
      bottom: 8,
    })
    .layoutWeight(1)
    .enabled(this.isCheckedEnabled ? true : false)
    .onClick(() => {
      this.simCardClick(1);
    })
    .accessibilityRole(AccessibilityRoleType.BUTTON)
    Row() {
      Button(this.getForwardSimCardText(common.int.SLOT_ONE),
        { type: ButtonType.Normal, buttonStyle: this.isPC ? ButtonStyleMode.NORMAL : undefined, stateEffect: true })
        .fontColor($r('sys.color.ohos_id_color_text_primary_activated'))
        .maxFontScale(2)
        .borderRadius(this.isPC ? 8 : $r('sys.float.ohos_id_corner_radius_button'))
        .backgroundColor(this.isPC ? '#0C000000' : Color.Transparent)
        .width('100%')
        .height('40vp')
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
    .height('100%')
    .margin({
      bottom: 4,
    })
    .layoutWeight(1)
    .enabled(this.isCheckedEnabled ? true : false)
    .onClick(() => {
      this.simCardClick(2);
    })
    .accessibilityRole(AccessibilityRoleType.BUTTON)
  }
}

@Component
export struct TransmitThirdPartDialogTitle {
  msg: LooseObject | null = null;
  @Link isChecked: boolean;

  build() {
        if(this.msg?.contactsParam.contactsNum > 1) {
          Text() {
            Span($r('app.string.contentSentTo', this.msg?.contactsParam.contactName == '' ?
            this.msg?.contactsParam.telephoneFormatSplit :
            this.msg?.contactsParam.contactNameSplit, this.getPluralPeopleShare(this.msg?.contactsParam.contactsNum)))
              .fontSize($r('sys.float.ohos_id_text_size_body1'))
              .fontColor($r('sys.color.ohos_id_color_text_primary'))
              .fontWeight(FontWeight.Medium)
          }
          .textAlign(TextAlign.Center)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .id('TransmitThirdPartDialogTitle_mutiContacts')
        } else {
          Text() {
            Span($r('app.string.contentSentContentToSingle', this.msg?.contactsParam.contactName == '' ?
            this.msg?.contactsParam.telephoneFormat : this.msg?.contactsParam.contactName))
              .fontSize($r('sys.float.ohos_id_text_size_body1'))
              .fontColor($r('sys.color.ohos_id_color_text_primary'))
              .fontWeight(FontWeight.Medium)
          }
          .textAlign(TextAlign.Start)
          .id('TransmitThirdPartDialogTitle_singleContacts')
        }
  }

  public getPluralPeopleShare(num: number) {
    return $r('app.plural.plural_people', num,
      num);
  }
}

@Component
export struct TransmitThirdPartDialogBottom {
  @Link isCheckedEnabled: boolean;
  multiSimCard: boolean = false;
  cancel: () => void = () => {};
  simCardClick: (value: number) => void = (value) => {};
  confirm: () => void = () => {};
  @StorageProp('fontSizeScale') fontSizeScale: number = 1;

  aboutToAppear(): void {
    HiLog.i('TransmitThirdPartDialogBottom', 'aboutToApper multiSimCard is:' + this.multiSimCard);
  }

  build() {
    Flex({
      direction: this.multiSimCard ? FlexDirection.Column : FlexDirection.Row,
      justifyContent: FlexAlign.SpaceAround,
      alignItems: ItemAlign.Center
    }) {

      if (this.multiSimCard) {
        Row() {
          Button({ type: ButtonType.Normal }){
            Text($r('app.string.send_dialog_send_sim', 1))
              .maxFontScale(2)
              .fontColor($r('sys.color.ohos_id_color_text_primary_activated'))
              .fontWeight(FontWeight.Medium)
          }
          .borderRadius($r('sys.float.ohos_id_corner_radius_button'))
          .opacity(this.isCheckedEnabled ? 1 : 0.4)
          .backgroundColor(Color.Transparent)
          .width('100%')
          .height('100%')
        }
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
        .height('100%')
        .margin({
          bottom: 8
        })
        .backgroundColor($r('sys.color.ohos_id_color_background_transparent'))
        .layoutWeight(1)
        .margin((this.fontSizeScale >= 1 && this.multiSimCard) ? {top: 2, bottom: 2} : {left: 0, right: 0})
        .enabled(this.isCheckedEnabled ? true : false)
        .onClick(() => {
          this.simCardClick(1);
        })

        Row() {
          Button({ type: ButtonType.Normal }){
            Text($r('app.string.send_dialog_send_sim', 2))
              .maxFontScale(2)
              .fontColor($r('sys.color.ohos_id_color_text_primary_activated'))
              .fontWeight(FontWeight.Medium)
          }
          .borderRadius($r('sys.float.ohos_id_corner_radius_button'))
          .opacity(this.isCheckedEnabled ? 1 : 0.4)
          .backgroundColor(Color.Transparent)
          .width('100%')
          .height('100%')
        }
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
        .margin({
          bottom: 4
        })
        .height('100%')
        .backgroundColor($r('sys.color.ohos_id_color_background_transparent'))
        .layoutWeight(1)
        .enabled(this.isCheckedEnabled ? true : false)
        .onClick(() => {
          this.simCardClick(2);
        })

        this.cancelButton()
      } else {
        this.cancelButton()
        if (!this.multiSimCard) {
          Divider()
            .vertical(true)
            .width(8)
            .height(24)
            .color($r('sys.color.ohos_id_color_list_separator'));
        }
        Row() {
          Button( { type: ButtonType.Normal }){
            Text($r('app.string.transmit_send'))
              .maxFontScale(2)
              .fontColor($r('sys.color.ohos_id_color_text_primary_activated'))
              .fontWeight(FontWeight.Medium)
          }
          .borderRadius($r('sys.float.ohos_id_corner_radius_button'))
          .opacity(this.isCheckedEnabled ? 1 : 0.4)
          .backgroundColor(Color.Transparent)
          .width('100%')
          .height('100%')
        }
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
        .height('100%')
        .backgroundColor($r('sys.color.ohos_id_color_background_transparent'))
        .layoutWeight(1)
        .margin({ start: LengthMetrics.vp(4) })
        .enabled(this.isCheckedEnabled ? true : false)
        .onClick(() => {
          this.confirm();
        })
      }
    }
    .height(this.changeHeight())
    .margin({ bottom: 16 })
  }

  @Builder
  cancelButton() {
    Row() {
      Button({ type: ButtonType.Normal }) {
        Text($r('app.string.cancel'))
          .maxFontScale(2)
          .fontColor($r('sys.color.ohos_id_color_text_primary_activated'))
          .fontWeight(FontWeight.Medium);
      }
      .borderRadius($r('sys.float.ohos_id_corner_radius_button'))
      .backgroundColor(Color.Transparent)
      .width('100%')
      .height('100%');
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
    .backgroundColor($r('sys.color.ohos_id_color_background_transparent'))
    .layoutWeight(1)
    .margin({
      top: this.multiSimCard ? 4 : 0,
      bottom: this.multiSimCard ? 4 : 0,
      end: this.multiSimCard ? LengthMetrics.vp(0) : LengthMetrics.vp(4)
    })
    .onClick(() => {
      this.cancel();
    })
    .height('100%')
  }

  changeHeight() {
    let dialogHeight: number = 40;
    if (this.fontSizeScale < 1 && !this.multiSimCard) {
      dialogHeight = 40
    } else if (this.multiSimCard) {
      dialogHeight = ((this.fontSizeScale <= 2 ? this.fontSizeScale : 2) * 16 + 25) * 3
    } else if (this.fontSizeScale >= 1 && !this.multiSimCard) {
      dialogHeight = (this.fontSizeScale <= 2 ? this.fontSizeScale : 2) * 16 + 25
    }
    return dialogHeight;
  }
}