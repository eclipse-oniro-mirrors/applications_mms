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

import HiLog from '../../utils/HiLog';
import MMRecorderController from './MMRecorderController';
import Constant from '../../data/Constant';
import { GlobalContext } from '../../MainAbility/GlobalHelper';
import { BusinessError } from '@ohos.base';
import { AudioPlayerService } from '../../service/AudioPlayerService';
import DotUtil from '../../utils/MmsDot/DotUtils';
import dotCommon, { dotNoNeedParmas, timeStatusParams } from '../../utils/MmsDot/DotCommon';
import { abilityAccessCtrl } from '@kit.AbilityKit';
import myCommon from '@ohos.app.ability.common';
import lazy { SplitScreenManager, SplitScreenType } from '../../utils/SplitScreenManager'
import commonData from '../../data/commonData';

const TAG = 'MmRecorder ';

@Component
export default struct MMRecorder {
  audioPlayerService: AudioPlayerService = AudioPlayerService.getInstance();
  @State mmRecorderCtrl: MMRecorderController = MMRecorderController.getInstance();
  @State isAnimation: boolean = false;
  @State scaleSize: number = 1;
  @Link textareaFocusable: boolean;
  @Link showMMContentPicker: boolean;
  private isExceedSize: boolean = false;
  @Link recorderPermission: boolean;
  private isUpperLimit: boolean = false;
  @State isTouchDown: boolean = false;
  @State authResults: number = 0;
  private context = getContext(this) as myCommon.UIAbilityContext;
  @StorageProp('stopRecordTime') @Watch('watchStopRecord') pageHideTime: number = 0;
  @StorageLink('isExceedSize') @Watch('recordChange') changeToText: boolean = false;
  @Link isShow: boolean;
  @StorageProp('fontSizeScale') fontSizeScale: number = 1;
  //分屏通知
  @StorageLink('SplitScreenType') @Watch('splitScreenTypeChange') splitScreenType: SplitScreenType = SplitScreenManager.getInstance().getSplitScreenType()
  private replaceVcardCallBack:Function = () => {};

  aboutToAppear() {
    HiLog.i(TAG, 'aboutToAppear');
    this.mmRecorderCtrl.onInit();
    this.recorderPermission = this.mmRecorderCtrl.checkAccessToken('ohos.permission.MICROPHONE')
    HiLog.i(TAG, `this.recorderPermission:${this.recorderPermission}`);
    if (this.mmRecorderCtrl.scaleAnimator) {
      this.mmRecorderCtrl.scaleAnimator.onframe = (value: number) => {
        this.scaleSize = value;
      };
    }
  }

  watchStopRecord() {
    if (this.isTouchDown) {
      this.stopRecord();
    }
  }

  stopRecord(callback?: Function) {
    this.isTouchDown = false;
    this.isAnimation = false;
    this.mmRecorderCtrl.stopRecord(this.context, () => {
      focusControl.requestFocus(Constant.MMS_INPUT_TEXTAREA_Id);
      if (this.mmRecorderCtrl.isNeedTextareaFocus) {
        this.textareaFocusable = true;
        this.isShow = false;
        AppStorage.setOrCreate(commonData.STR.CREATE_NEW_CONVERSATION_FROM_RECORD, false);
      } else {
        this.showMMContentPicker = true;
      }
      if (callback) {
        callback(callback);
      }
    }, this.replaceVcardCallBack);
  }

  recordChange() {
    if (this.changeToText) {
      this.stopRecord();
      AppStorage.setOrCreate('isExceedSize', false)
    }
  }

  permissionOnSetting(context: Context) {
    HiLog.i(TAG, 'permissionOnSetting');
    let atManager = abilityAccessCtrl.createAtManager();
    atManager.requestPermissionOnSetting(context, ['ohos.permission.MICROPHONE'])
      .then((data: Array<abilityAccessCtrl.GrantStatus>) => {
        HiLog.i(TAG, 'requestPermissionOnSetting data : ' + data);
      }).catch((err: BusinessError) => {
        HiLog.i(TAG, 'requestPermissionOnSetting data : ' + JSON.stringify(err));
      });
  }

  @Builder
  loadContentRow() {
    if (!this.recorderPermission) {
      if (this.authResults !== -1) {
        this.loadNotAuthorized();
      } else if (this.authResults === -1) {
        this.loadContentNoPermission();
      }
    } else {
      RelativeContainer() {
        this.loadContentNormal();
        Text(this.mmRecorderCtrl.recorderTime)
          .fontSize($r('sys.float.ohos_id_text_size_body2'))
          .fontColor($r('sys.color.ohos_id_color_text_primary'))
          .fontWeight(FontWeight.Regular)
          .visibility(this.isAnimation ? Visibility.Visible : Visibility.Hidden)
          .alignRules({
            bottom: { anchor: '__container__', align: VerticalAlign.Center },
            middle: { anchor: '__container__', align: HorizontalAlign.Center }
          })
          .id('recordTime')
          .margin({ bottom: '40vp' })//中心按钮大小72/2=36.文字和按钮间距4，一共40
        Text($r('app.string.press_speak'))
          .fontSize($r('sys.float.ohos_id_text_size_body2'))
          .fontColor($r('sys.color.ohos_id_color_text_primary'))
          .fontWeight(FontWeight.Regular)
          .margin({ top: '40vp' })//中心按钮大小72/2=36.文字和按钮间距4，一共40
          .visibility(this.isAnimation ? Visibility.Hidden : Visibility.Visible)
          .alignRules({
            top: { anchor: '__container__', align: VerticalAlign.Center },
            middle: { anchor: '__container__', align: HorizontalAlign.Center }
          })
          .id('recordDescription')
          .accessibilityLevel('no')
      }
    }
  }

  @Builder
  loadNotAuthorized() {
    Column() {
      SymbolGlyph($r('sys.symbol.mic'))
        .height(72)
        .width(72)
        .fontSize('72vp')
        .draggable(false)
        .fontColor([$r('sys.color.ohos_fa_icon_primary')])
      Text($r('app.string.microphone_permission_prompt'))
        .fontSize($r('sys.float.ohos_id_text_size_body2'))
        .fontColor($r('sys.color.ohos_id_color_text_secondary'))
        .fontWeight(FontWeight.Regular)
      Row() {
        Text($r('app.string.allow_Camera'))
          .fontSize($r('sys.float.ohos_id_text_size_sub_title2'))
          .fontColor($r('sys.color.ohos_id_color_text_primary_activated'))
          .fontWeight(FontWeight.Medium)
      }
      .width(120)
      .height(40)
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .onClick(async () => {
        this.authResults = await this.mmRecorderCtrl.initPermission('ohos.permission.MICROPHONE');
        if (this.authResults === 0) {
          this.recorderPermission = true;
        }
        HiLog.i(TAG, `this.authResults:${this.authResults}`);
        HiLog.i(TAG, `this.recorderPermission:${this.recorderPermission}`);
      })
    }
    .height('100%')
    .width('100%')
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
  }
  @Builder
  loadContentNoPermission(){
    Column() {
      SymbolGlyph($r('sys.symbol.mic'))
        .height(72)
        .width(72)
        .fontSize('72vp')
        .draggable(false)
        .fontColor([$r('sys.color.ohos_fa_icon_primary')])
      Text($r('app.string.open_File_mic_permission_title'))
        .fontSize($r('sys.float.ohos_id_text_size_body2'))
        .fontColor($r('sys.color.ohos_id_color_text_secondary'))
        .fontWeight(FontWeight.Regular)
        .height(38)
        .textAlign(TextAlign.Center)
      Row() {
        Text($r('app.string.setting_permissions'))
          .fontSize($r('sys.float.ohos_id_text_size_sub_title2'))
          .fontColor($r('sys.color.ohos_id_color_text_primary_activated'))
          .fontWeight(FontWeight.Medium)
      }
      .width(120)
      .height(40)
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .onClick(() => {
        this.permissionOnSetting(getContext(this))
      })
    }
    .height('100%')
    .width('100%')
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .padding(28)
  }
  @Builder
  loadContentNormal(){
    Stack({ alignContent: Alignment.Center }) {
      this.loadStackContent();
    }
    .accessibilityText(getContext(this).resourceManager.getStringSync($r('app.string.press_speak').id))
    .accessibilityRole(AccessibilityRoleType.BUTTON)
    .accessibilityDescription(getContext(this).resourceManager.getStringSync($r('app.string.long_press_speak').id))
    .onClick(() => {})
    .alignRules({
      center: { anchor: '__container__', align: VerticalAlign.Center },
      middle: { anchor: '__container__', align: HorizontalAlign.Center }
    })
    .id('recordBtn')
    .onTouch((event) => {
      this.audioPlayerService.stopAudio()
      if (event === undefined) {
        HiLog.e(TAG, 'event is undefined in onTouch event');
        return;
      }
      if (event.type === TouchType.Down && !this.isTouchDown) {
        this.mmRecorderCtrl.checkCallState(() => {
          this.isTouchDown = true;
          this.isUpperLimit = this.mmRecorderCtrl.mmAreaController.isAttachmentUpperLimit();
          if (!this.isUpperLimit) {
            this.isExceedSize = this.mmRecorderCtrl.checkSizeIsExceeded();
            HiLog.i(TAG, 'size is exceed!');
            if (!this.isExceedSize) {
              this.isAnimation = true;
              this.mmRecorderCtrl.startRecord(this.context, (ready: boolean) => {
                if (!ready && this.isTouchDown || this.mmRecorderCtrl.checkMicState()) {
                  this.stopRecord();
                }
                // start Recording UE_DOT
                DotUtil.getInstance().reportEvent(dotNoNeedParmas, dotCommon.eventName.WRITE_HOLD_TO_SPEAK);
              });
              this.textareaFocusable = false;
            }
          }
        })
      } else if ((event.type === TouchType.Up || event.type === TouchType.Cancel) && this.isTouchDown) {
        this.touchUpMethod();
      }
    })
    .width($r('app.float.recording_button_width'))
    .height($r('app.float.recording_button_width'))
  }

  private touchUpMethod() {
    HiLog.i(TAG, 'touchType up or cancel');
    if (!this.isExceedSize && !this.isUpperLimit) {
      this.stopRecord(() => {
        // stop Recording UE_DOT
        DotUtil.getInstance().reportEvent(timeStatusParams, dotCommon.eventName.WRITE_COMPLETE_RECORDER);
      });
    } else {
      AppStorage.setOrCreate(commonData.STR.CREATE_NEW_CONVERSATION_FROM_RECORD, false);
      this.isTouchDown = false;
      this.isExceedSize = false;
      this.isUpperLimit = false;
    }
  }

  @Builder
  loadStackContent(){
    Row() {
    }
    .width(72)
    .height(72)
    .zIndex(1)
    .borderRadius(36)
    .backgroundColor($r('app.color.mms_recordering_bg'))
    .borderColor($r('sys.color.ohos_id_color_floating_button_shadow_start'))
    .borderWidth(0.5)
    .scale({ x: this.scaleSize, y: this.scaleSize })

    Row() {
      Row() {
        SymbolGlyph($r('sys.symbol.mic_fill'))
          .height('36vp')
          .width('36vp')
          .fontSize('36vp')
          .draggable(false)
          .fontColor([$r('sys.color.ohos_fa_icon_primary')])
      }
      .justifyContent(FlexAlign.Center)
      .height(72)
      .width(72)
      .borderRadius(36)
      .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
    }
    .justifyContent(FlexAlign.Center)
    .height(72)
    .width(72)
    .borderRadius(36)
    .backgroundColor(this.isAnimation ? Color.Transparent : $r('sys.color.ohos_id_color_list_card_bg'))
    .zIndex(2)
  }

  build() {
    Column(){
      Row(){
        Text($r('app.string.msg_record'))
          .padding({ left: '4vp' })
          .fontSize(this.fontSizeScale <= 2 ? this.fontSizeScale * 20 + 'vp' : 2 * 20 + 'vp')
          .fontColor($r('sys.color.ohos_id_color_text_primary'))
          .fontWeight(FontWeight.Bold)
          .height('100%')
        Blank();
        Row(){
          SymbolGlyph($r('sys.symbol.xmark'))
            .width('18vp')
            .height('18vp')
            .fontSize('18vp')
            .fontColor([$r('sys.color.ohos_id_color_primary')])

        }.width('40vp')
        .height('40vp')
        .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
        .justifyContent(FlexAlign.Center)
        .borderRadius('20vp')
        .accessibilityText(getContext(this).resourceManager.getStringSync($r('app.string.cancel_button').id))
        .onClick(()=>{
          this.isShow = false;
          AppStorage.setOrCreate(commonData.STR.CREATE_NEW_CONVERSATION_FROM_RECORD, false);
        })
      }
      .justifyContent(FlexAlign.Center)
      .padding({ left: 16, right: 16 })
      .width('100%')
      .height('56vp')
      .margin({top:8})
      Row() {
        this.loadContentRow();
      }
      .width('100%')
      .backgroundColor($r('sys.color.ohos_id_color_list_card_bg'))
      .layoutWeight(1)
      Blank().height('56vp').margin({bottom:8})
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('sys.color.ohos_id_color_list_card_bg'))
    .borderRadius({ topLeft: 32, topRight: 32 })
    .expandSafeArea([SafeAreaType.KEYBOARD, SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }

  splitScreenTypeChange() {
    this.mmRecorderCtrl.resetAnimator();
  }
}