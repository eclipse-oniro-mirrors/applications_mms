/**
 * Copyright (c) 2022-2025 Huawei Device Co., Ltd.
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
import MmsPreferences from '../utils/MmsPreferences';
import common from '../data/commonData';
import EmitterConstant from '../data/EmitterConstant';
import HiLog from '../utils/HiLog';
import emitter from '@ohos.events.emitter';
import DataService from '../service/DataService';
import simCardService from '../service/SimCardService';
import TelephoneUtil from '../utils/TelephoneUtil';
import Configuration from '@system.configuration';
import lazy { SplitScreenManager } from '../utils/SplitScreenManager'
import inputMethod from '@ohos.inputMethod';
import AccessibilityUtil from '../utils/AccessibilityUtil';

const TAG = 'MultiSimCardMenu '
/**
 * Custom multi-SimCard pop-up menu
 */
@Component
export struct MultiSimCardMenu {
  @StorageProp('fontSizeScale') fontSizeScale: number = 1;
  @State customPopup: boolean = false;
  @Link slotId: number;
  @Prop @Watch('destinationShow') onDestinationShow: boolean;
  @State subId: number = MmsPreferences.getInstance().getSelectedSlotId();
  @State @Watch('onCardImageIdChanged') cardImage?: number = MmsPreferences.getInstance().getSelectedSlotId();
  @State cardImageResource: Resource = $r('sys.symbol.simcard_fill_1_and_simcard_fill_2');
  @State private spnOfSim1: string = MmsPreferences.getInstance().getDispalyNameOfSim1();
  @State private spnOfSim2: string = MmsPreferences.getInstance().getDispalyNameOfSim2();
  @State private typeOfSlot0: number = MmsPreferences.getInstance().getTypeOfSlot(common.int.SLOT_ZERO);
  @State private typeOfSlot1: number = MmsPreferences.getInstance().getTypeOfSlot(common.int.SLOT_ONE);
  private telephoneNumberOfSim1: string = MmsPreferences.getInstance().getTelephoneNumberOfSim1();
  private telephoneNumberOfSim2: string = MmsPreferences.getInstance().getTelephoneNumberOfSim2();
  @State defCellularSlotId: number = 0;
  //sim卡1标识，添加空格是为了无障碍屏幕朗读的时候添加停顿
  private simOne: string = '1 ';
  //sim卡2标识，添加空格是为了无障碍屏幕朗读的时候添加停顿
  private simTwo: string = '2 ';
  @State keyboardFocused: boolean = false;
  @StorageLink('keyboardHeight') @Watch('onKeyboardChange') keyboardHeight: number = 0;
  @StorageLink('isVDEFoldPhoneAndFoldedState') @Watch('onFoldStatusChange') isVDEFoldPhoneAndFoldedState
    : boolean = false;
  @StorageLink('foldStatus') @Watch('getWallpaper') foldStatus
    : number = 0;
  @StorageLink('simStateValueChanged') @Watch('simStateValueChangedWatch') simStateChanged: boolean = false;
  @State isVDE: boolean = this.isVDEFoldPhoneAndFoldedState && this.foldStatus === 2 ? true : false

  private onFoldStatusChange(): void {
    if (this.isVDEFoldPhoneAndFoldedState) {
      HiLog.i(TAG, 'onFoldStatusChange :' + this.isVDEFoldPhoneAndFoldedState);
    } else {
      HiLog.i(TAG, 'onFoldStatusChange :' + this.isVDEFoldPhoneAndFoldedState);
    }
  }

  getWallpaper() {
    if (this.isVDEFoldPhoneAndFoldedState) {
      HiLog.i(TAG, 'onFoldStatusChange :' + this.isVDEFoldPhoneAndFoldedState);
      if (this.foldStatus === 2) {
        this.isVDE = true
      }else{
        this.isVDE = false
      }
      HiLog.i(TAG, 'isVDE :' + this.isVDE);
    } else {
      this.isVDE = false
      HiLog.i(TAG, 'onFoldStatusChange :' + this.isVDEFoldPhoneAndFoldedState);
    }
  }

  private onKeyboardChange() {
    if (this.keyboardHeight == 0) {
      this.keyboardFocused = false;
    } else {
      this.keyboardFocused = true;
    }
  }

  resetValues = () => {
  }

  destinationShow() {
    setTimeout(() => {
      this.onCardImageIdChanged();
    }, 30);
  }

  aboutToAppear(){
    HiLog.i(TAG, 'entry aboutToAppear MultiSimCard')
    this.spnOfSim1 = MmsPreferences.getInstance().getDispalyNameOfSim1();
    this.spnOfSim2 = MmsPreferences.getInstance().getDispalyNameOfSim2();
    this.onCardImageIdChanged();
    let innerEvent: emitter.InnerEvent = {
      eventId: EmitterConstant.EVENT_RECEIVE_IN_CONTACT,
    };
    let subIdEvent: emitter.InnerEvent = {
      eventId: EmitterConstant.EVENT_CHANGE_SUBID_STATUS,
    }

    emitter.on(innerEvent, (data) => {
      this.subId = data?.data?.['slotId'];
      this.change();
    });
    emitter.on(subIdEvent, (data) => {
      this.subId = data?.data?.['subId'];
      this.change();
    });
    emitter.on(simCardService.SIM_STATE_CHANGE_EVENT, () => {
      DataService.getDefaultCellularDataSlotId().then(res => {
        if (this.defCellularSlotId !== res) {
          this.defCellularSlotId = res;
          this.change();
        }
      })
    });
    DataService.getDefaultCellularDataSlotId().then(res => {
      this.defCellularSlotId = res;
    })
  }

  aboutToDisappear(): void {
    HiLog.i(TAG, 'entry aboutToDisappear MultiSimCard')
    emitter.off(EmitterConstant.EVENT_RECEIVE_IN_CONTACT);
    emitter.off(EmitterConstant.EVENT_CHANGE_SUBID_STATUS);
    emitter.off(EmitterConstant.EVENT_SIM_STATE_CHANGE);
  }

  private getSimCardIcon(slotId: number): Resource {
    let slotType = MmsPreferences.getInstance().getTypeOfSlot(slotId);
    let slotIndex = MmsPreferences.getInstance().getIndexOfSlot(slotId);
    HiLog.i(TAG, ` getSimCardIcon ${slotId},${slotType},${slotIndex}`);
    if (slotType === common.simType.ESIM) {
      return $r('app.media.ic_simcard_e');
    } else {
      return slotIndex === 1 ? $r('app.media.ic_simcard_1') : $r('app.media.ic_simcard_2');
    }
  }

  private getSimCardIconBySymbol(slotId: number): Resource {
    let slotType = MmsPreferences.getInstance().getTypeOfSlot(slotId);
    let slotIndex = MmsPreferences.getInstance().getIndexOfSlot(slotId);
    HiLog.i(TAG, ` getSimCardIconBySymbol ${slotId},${slotType},${slotIndex}`);
    if (slotType === common.simType.ESIM) {
      return $r('app.media.ic_simcard_e');
    } else {
      return slotIndex === 1 ? $r('sys.symbol.simcard_1') : $r('sys.symbol.simcard_2');
    }
  }

  @Builder
  simCardIconMenuItem(slotId: number) {
    if (MmsPreferences.getInstance().getTypeOfSlot(slotId) === common.simType.ESIM) {
      Image(this.getSimCardIcon(slotId))
        .width(16)
        .height(16)
        .draggable(false)
        .fillColor($r('app.color.brand'))
    } else {
      SymbolGlyph(this.getSimCardIconBySymbol(slotId))
        .width(16)
        .height(16)
        .draggable(false)
        .fontSize('16vp')
        .fontColor([$r('app.color.brand'), $r('sys.color.icon_tertiary')])
        .renderingStrategy(SymbolRenderingStrategy.MULTIPLE_COLOR)
    }
  }

  @Builder creatFirstSimCardMenuItem() {
    ListItem() {
      Button({ type: ButtonType.Normal }) {
        Column() {
          Row() {
            this.simCardIconMenuItem(common.int.SIM_ONE);
            Text(this.spnOfSim1)
              .fontSize($r('sys.float.Subtitle_M'))
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.ohos_id_color_text_primary'))
              .padding(Configuration.getLocale().dir === 'rtl' ?
                { right: 4, left: 12 } : { left: 4, right: 12 })
              .maxLines(2)
              .heightAdaptivePolicy(TextHeightAdaptivePolicy.MAX_LINES_FIRST)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }

          Text(this.telephoneNumberOfSim1)
            .direction(Direction.Ltr)
            .padding(Configuration.getLocale().dir === 'rtl' ?
              { right: 20, top: 2 } : { left: 20, top: 2 })
            .fontSize($r('sys.float.Body_M'))
            .fontWeight(FontWeight.Regular)
            .fontColor($r('sys.color.ohos_id_color_text_secondary'))
        }
        .accessibilityText(AccessibilityUtil.getSimIconAccessibilityText(0, getContext(this)) +
        this.spnOfSim1 + ' ' + this.telephoneNumberOfSim1)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Start)
        .padding(Configuration.getLocale().dir === 'rtl' ?
          { right: 10, top: 8, bottom: 8 } : { left: 10, top: 8, bottom: 8 })
        .width('100%')
      }
      .backgroundColor($r('sys.color.ohos_id_color_background_transparent'))
      .borderRadius($r('sys.float.corner_radius_level8'))
      .width('100%')
      .onClick(() => {
        HiLog.i(TAG, 'click sim one');
        this.cardImage = common.int.SIM_ONE;
        MmsPreferences.getInstance().setValueToMap(common.STR.KEY_OF_SELECTED_SLOTID, this.cardImage);
        this.customPopup = ! this.customPopup;
        AppStorage.setOrCreate('simSlotId', common.int.SIM_ONE);
        this.resetValues();
      })
    }
    .id('creatFirstSimCardMenuItem_1')
  }
  @Builder creatSecondSimCardMenuItem() {
    ListItem() {
      Button({ type: ButtonType.Normal }) {
        Column() {
          Row() {
            this.simCardIconMenuItem(common.int.SIM_TWO);
            Text(this.spnOfSim2)
              .fontSize($r('sys.float.Subtitle_M'))
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.ohos_id_color_text_primary'))
              .padding(Configuration.getLocale().dir === 'rtl' ?
                { right: 4, left: 12 } : { left: 4, right: 12 })
              .maxLines(2)
              .heightAdaptivePolicy(TextHeightAdaptivePolicy.MAX_LINES_FIRST)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }

          Text(this.telephoneNumberOfSim2)
            .direction(Direction.Ltr)
            .padding(Configuration.getLocale().dir === 'rtl' ?
              { right: 20, top: 2 } : { left: 20, top: 2 })
            .fontSize($r('sys.float.Body_M'))
            .fontWeight(FontWeight.Regular)
            .fontColor($r('sys.color.ohos_id_color_text_secondary'))
        }
        .accessibilityText(AccessibilityUtil.getSimIconAccessibilityText(1, getContext(this)) +
        this.spnOfSim2 + ' ' + this.telephoneNumberOfSim2)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Start)
        .padding(Configuration.getLocale().dir === 'rtl' ?
          { right: 10, top: 8, bottom: 8 } : { left: 10, top: 8, bottom: 8 })
        .width('100%')
      }
      .backgroundColor($r('sys.color.ohos_id_color_background_transparent'))
      .borderRadius($r('sys.float.corner_radius_level8'))
      .width('100%')
      .onClick(() => {
        HiLog.i(TAG, 'click sim two');
        this.cardImage = common.int.SIM_TWO;
        MmsPreferences.getInstance().setValueToMap(common.STR.KEY_OF_SELECTED_SLOTID, this.cardImage);
        AppStorage.setOrCreate('simSlotId', common.int.SIM_TWO);
        this.customPopup = ! this.customPopup;
        this.resetValues();
      })
    }
    .id('creatFirstSimCardMenuItem_2')
  }

  @Builder PopupBuilder() {
    Column() {
      List() {
        this.creatFirstSimCardMenuItem()
        this.creatSecondSimCardMenuItem()
      }
      .listDirection(Axis.Vertical)
      .divider({
        strokeWidth: $r('app.float.settings_divider_strokeWidth'),
        color: $r('sys.color.ohos_id_color_list_separator'),
        startMargin: 32,
        endMargin: 12
      })
      .edgeEffect(EdgeEffect.Spring)
      .chainAnimation(false)
      .width(this.fontSizeScale > 1 ? 'auto' : '170vp' )
      .padding({ top: 4, bottom: 4, left: 4, right: 4 })
      .borderRadius(16)
    }
    .backgroundColor($r('sys.color.ohos_id_color_dialog_bg'))
    .height((this.fontSizeScale === 3.2 && this.keyboardFocused) ? '280vp' : 'auto')
  }

  @Builder
  multiSimCardIcon() {
    if ((this.typeOfSlot0 === common.simType.ESIM) || (this.typeOfSlot1 === common.simType.ESIM)) {
      Image(this.cardImageResource)
        .width(24)
        .height(24)
        .draggable(false)
    } else {
      SymbolGlyph(this.cardImageResource)
        .width(24)
        .height(24)
        .draggable(false)
        .fontSize('24vp')
        .fontColor([$r('app.color.brand'), $r('sys.color.icon_tertiary')])
        .renderingStrategy(SymbolRenderingStrategy.MULTIPLE_COLOR)
    }
  }

  change() {
    HiLog.i(TAG, 'this.cardImage from ' + this.cardImage + ' -> ' + this.subId);
    this.cardImage = this.subId;
    AppStorage.setOrCreate('simSlotId',this.subId);
  }

  simStateValueChangedWatch() {
    this.onCardImageIdChanged();
  }

  onCardImageIdChanged() {
    let activeSlotId = this.cardImage;
    let anotherSlotId = activeSlotId === common.int.SLOT_ZERO ? common.int.SLOT_ONE : common.int.SLOT_ZERO;
    this.typeOfSlot0 = MmsPreferences.getInstance().getTypeOfSlot(common.int.SIM_ONE);
    this.typeOfSlot1 = MmsPreferences.getInstance().getTypeOfSlot(common.int.SIM_TWO);
    let activeSlotType = activeSlotId === common.int.SLOT_ZERO ? this.typeOfSlot0 : this.typeOfSlot1;
    let anotherSlotType = activeSlotId === common.int.SLOT_ZERO ? this.typeOfSlot1 : this.typeOfSlot0;
    let activeSlotIndex = MmsPreferences.getInstance().getIndexOfSlot(activeSlotId);
    let anotherSlotIndex = MmsPreferences.getInstance().getIndexOfSlot(anotherSlotId);
    HiLog.i(TAG, ` onCardImageIdChanged activeSlotId:${activeSlotId},anotherSlotId:${anotherSlotId} `);
    let cardResource = this.getCardImageResource(activeSlotType, activeSlotIndex, anotherSlotType, anotherSlotIndex);
    if (cardResource) {
      this.cardImageResource = cardResource;
    }
  }

  getCardImageResource(activeSlotType: number, activeSlotIndex: number, anotherSlotType: number,
    anotherSlotIndex: number): Resource | null {
    HiLog.i(TAG,
      `getCardImageResource ${activeSlotType},${activeSlotIndex},${anotherSlotType},${anotherSlotIndex}`);
    if (activeSlotType === common.simType.PSIM) {
      // 激活的卡是sim卡
      if (anotherSlotType === common.simType.PSIM) {
        // 两个slot都是sim卡类型
        if (activeSlotIndex === 1) {
          return $r('sys.symbol.simcard_fill_1_and_simcard_fill_2');
        } else {
          return $r('sys.symbol.simcard_fill_2_and_simcard_fill_1');
        }
      } else {
        // 激活的卡是sim卡，另一张卡是esim卡
        if (activeSlotIndex === 1) {
          return $r("app.media.ic_simcard_fill_1_and_simcard_e");
        } else {
          return $r("app.media.ic_simcard_fill_2_and_simcard_e");
        }
      }
    } else {
      // 激活的卡是esim卡
      if (anotherSlotType === common.simType.PSIM) {
        // 激活的卡是esim卡，另一张卡是sim卡
        if (anotherSlotIndex === 1) {
          return $r('app.media.ic_simcard_fill_e_and_simcard_fill_1');
        } else {
          return $r('app.media.ic_simcard_fill_e_and_simcard_fill_2');
        }
      } else {
        // 两个slot都是esim卡类型，当前不支持
        return null;
      }
    }
  }

  getSelectIconText(slotId: number) :string{
    try {
      let slotType = MmsPreferences.getInstance().getTypeOfSlot(slotId);
      let slotIndex = MmsPreferences.getInstance().getIndexOfSlot(slotId);
      HiLog.i(TAG, ` getSelectIconText ${slotId},${slotType},${slotIndex}`);
      if (slotType === common.simType.ESIM) {
        return getContext(this).resourceManager.getStringSync($r('app.string.select_esim').id, slotIndex);
      } else {
        return getContext(this).resourceManager.getStringSync($r('app.string.select_sim').id, slotIndex.toString());
      }
    } catch (err) {
      HiLog.e(TAG, `getSelectIconText failed, code is ${err?.code}, message is ${err?.message}`);
    }
    return '';
  }

  build() {
    Row() {
      this.multiSimCardIcon();
      Blank()
        .width(4)
      Image($r('app.media.ic_public_spinner'))
        .width(12)
        .height(24)
        .draggable(false)
    }
    .accessibilityText(this.getSelectIconText(this.cardImage ?? 0))
    .size({ width: 40, height: 24 })
    .bindPopup(this.customPopup, {
      builder: this.PopupBuilder,
      placement: Placement.TopLeft,
      enableArrow: false,
      popupColor: $r('sys.color.ohos_id_color_background'),
      showInSubWindow: false,
      autoCancel: true,
      onStateChange: (e) => {
        if (!e.isVisible) {
          this.customPopup = false
        }
      }
    })
    .onClick(() => {
      this.customPopup = ! this.customPopup
      this.spnOfSim1 = MmsPreferences.getInstance().getDispalyNameOfSim1();
      this.spnOfSim2 = MmsPreferences.getInstance().getDispalyNameOfSim2();
      this.telephoneNumberOfSim1 =
        TelephoneUtil.formatDisplayPhoneNum(MmsPreferences.getInstance().getTelephoneNumberOfSim1());
      this.telephoneNumberOfSim2 =
        TelephoneUtil.formatDisplayPhoneNum(MmsPreferences.getInstance().getTelephoneNumberOfSim2());
      //分屏横屏模式下键盘弹出后导致bindPopup的弹出在键盘下面,点击后隐藏键盘
      if (this.isVDE || SplitScreenManager.getInstance().isLandscapeAndPhone) {
        inputMethod.getController().hideTextInput();
      }
    })
  }
}