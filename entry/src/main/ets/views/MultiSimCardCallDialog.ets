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
import TelephoneUtil from '../utils/TelephoneUtil';
import Configuration from '@system.configuration';
import { LengthMetrics } from '@kit.ArkUI';
import common from '../data/commonData';
import MmsPreferences from '../utils/MmsPreferences';
import HiLog from '../utils/HiLog';
import AccessibilityUtil from '../utils/AccessibilityUtil';

const TAG = 'MultiSimCardCallDialog';

@Component
export struct MultiSimCardCallDialog {
  @Link builder: SelectDialogBuilder;
  private controller?: CustomDialogController;
  private textDirection: string = Configuration.getLocale().dir;
  @StorageProp('fontSizeScale') fontSizeScale: number = 1;

  @Styles normalStyles() {
    .backgroundColor(Color.Transparent)
    .padding({left: 8, right: 8})
  }
  @Styles pressedStyles() {
    .backgroundColor($r('sys.color.ohos_id_color_click_effect'))
    .borderRadius(14)
  }

  getCallIconBySlotId(slotId: number): Resource {
    let slotType = MmsPreferences.getInstance().getTypeOfSlot(slotId);
    let slotIndex = MmsPreferences.getInstance().getIndexOfSlot(slotId);
    HiLog.i(TAG, ` getCallIconBySlotId ${slotId},${slotType},${slotIndex}`);
    if (slotType === common.simType.ESIM) {
      return $r('app.media.phone_badge_esim');
    } else {
      return slotIndex === 1 ? $r('sys.symbol.phone_badge_1') : $r('sys.symbol.phone_badge_2');
    }
  }

  @Builder
  callIconBuilder(slotId: number) {
    if (MmsPreferences.getInstance().getTypeOfSlot(slotId) === common.simType.ESIM) {
      Image(this.getCallIconBySlotId(slotId))
        .size({ width: '24vp', height: '24vp' })
        .draggable(false)
        .fillColor($r('sys.color.icon_secondary'))
        .margin({ end: LengthMetrics.vp(16) })
    } else {
      SymbolGlyph(this.getCallIconBySlotId(slotId))
        .fontSize('24vp')
        .draggable(false)
        .fontColor([$r('sys.color.icon_secondary')])
        .margin({ end: LengthMetrics.vp(16) })
    }
  }

  @Builder
  nameAndPhone(item: MultiSimCardItems, index?: number) {
    Column() {
      Row(){
        Text(item.name)
          .fontSize($r('sys.float.ohos_id_text_size_body1'))
          .fontColor($r('sys.color.ohos_id_color_text_primary'))
          .fontWeight(FontWeight.Medium)
          .maxFontScale(2)
        if (this.builder.lastSimId == index) {
          Text($r('app.string.choose_sub_recommend_recently'))
            .fontSize($r('sys.float.ohos_id_text_size_body1'))
            .fontColor($r('sys.color.ohos_id_color_text_primary'))
            .fontWeight(FontWeight.Medium)
            .margin({ start: LengthMetrics.vp(5) })
            .maxFontScale(2)
        }
      }

      Text(TelephoneUtil.formatDisplayPhoneNum(item.phone ))
        .fontSize($r('sys.float.ohos_id_text_size_body2'))
        .fontColor($r('sys.color.ohos_id_color_text_secondary'))
        .fontWeight(FontWeight.Regular)
        .margin({top:2})
        .maxFontScale(2)
    }.alignItems(HorizontalAlign.Start)
  }

  build() {
    Column() {
      List() {
        ForEach(this.builder.multiSimCardItems, (item: MultiSimCardItems, index?: number) => {
          ListItem() {
            Row() {
              this.callIconBuilder(item?.slotId ?? 0);
              this.nameAndPhone(item, index)
            }.width('100%')
            .constraintSize({ minHeight: 24 + 40 * Math.min(2, this.fontSizeScale) })
            .justifyContent(FlexAlign.Start)
            .accessibilityText(index !== undefined ? AccessibilityUtil.getSimIconAccessibilityText(item?.slotId,
              getContext(this)) + ' ' + item.name + ' ' + TelephoneUtil.formatDisplayPhoneNum(item.phone) : '')
            .stateStyles({
              pressed: this.pressedStyles,
              normal: this.normalStyles
            })
          }.onClick(() => {
            if (index !== undefined) {
              this.confirm(index);
            }
          })
        })
      }
      .divider({
        strokeWidth: $r('app.float.settings_divider_strokeWidth'),
        color: $r('sys.color.comp_divider'),
        startMargin: 48,
        endMargin: 8,
      })
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.None)
    }
    .padding({left: 12, right: 12})
  }

  confirm(slotId: number) {
    this.controller?.close()
    if (this.builder.callback) {
      this.builder.callback(slotId);
    }
  }

  cancel() {
    this.controller?.close()
  }
}

export class MultiSimCardItems {
  public name: string = '';
  public img?: Resource;
  public phone: string = '';
  public slotId?: number = 0;
}

export interface Controller {
  close: () => void;
  open: () => void;
}

export class SelectDialogBuilder {
  public title: string = '';
  public multiSimCardItems: Array<MultiSimCardItems> = [];
  public lastSimId?: number = -1;
  public callback?: (simId: number) => void;
  public controller?: Controller;
}

