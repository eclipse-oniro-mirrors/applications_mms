/**
 * Copyright (c) 2025-2025 Huawei Device Co., Ltd.
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

import { curves, LengthMetrics } from '@kit.ArkUI';
import HiLog from '../../utils/HiLog';
import common from '../../data/commonData';
import { AnimationViewModel } from './NavBarAnimationViewModel';

const TAG = 'CustomSettingsNavBar';

@Component
export struct CustomSettingsNavBar {
  @StorageLink('isSettingShow') isSettingShow: boolean = false;
  @StorageLink('curBp') curBp: string = common.STR.DEVICE_MOBILE_PHONE;
  @Consume('pageInfosSetting') pageInfosSettingStack: NavPathStack;
  @ObjectLink animationViewModel: AnimationViewModel;
  @Prop title: ResourceStr = '';
  // @Prop controller: PafWebViewController;
  @Prop isShowBackBtn: boolean = true;
  @Prop isShowCloseBtn: boolean = true;
  @Prop isNeedAnimation: boolean = true;
  onClose?: () => void;
  onCancel?: () => void;

  build() {
    Row() {
      Row() {
        if (this.isShowBackBtn) {
          Button({ type: ButtonType.Circle }) {
            SymbolGlyph($r('sys.symbol.chevron_backward'))
              .key('CustomSettingsNavBar_Back_Image')
              .fontSize('24vp')
              .fontColor([$r('sys.color.icon_primary')])
              .draggable(false)
          }
          .key('CustomSettingsNavBar_Back_Button')
          .width('40vp')
          .height('40vp')
          .margin({ end: LengthMetrics.vp(8) })
          .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
          .accessibilityGroup(true)
          .accessibilityText(getContext(this)
            .resourceManager
            .getStringSync($r('app.string.guide_action_text_previous').id))
          .opacity(this.isNeedAnimation ? this.animationViewModel.btnOpacity : 1)
          .onClick(() => {
            if (this.onCancel) {
              HiLog.i(TAG, 'onClick onCancel.');
              this.onCancel();
              return;
            }
            // if (this.controller) {
            //   this.controller.onBackPress();
            // } else {
            //   this.pageInfosSettingStack.pop();
            // }
          })
        }
        if (this.title !== '') {
          Column() {
            Text(this.title)
              .key('CustomSettingsNavBar_Column_Text')
              .fontSize($r('sys.float.ohos_id_text_size_headline8'))
              .fontWeight(FontWeight.Bold)
              .fontColor($r('sys.color.icon_primary'))
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .maxLines(1)
              .textAlign(TextAlign.Start)
          }
          .onClick(() => {
            this.onCancel
          })
          .layoutWeight(1)
          .justifyContent(FlexAlign.Start)
          .alignItems(HorizontalAlign.Start)
          .opacity(this.isNeedAnimation ? this.animationViewModel.titleOpacity : 1)
        }
      }
      .layoutWeight(1)

      if (this.isShowCloseBtn) {
        Button({ type: ButtonType.Circle }) {
          SymbolGlyph($r('sys.symbol.xmark'))
            .key('CustomSettingsNavBar_Close_Image')
            .fontSize('18vp')
            .fontColor([$r('sys.color.icon_primary')])
            .draggable(false)
        }
        .key('CustomSettingsNavBar_Close_Button')
        .width('40vp')
        .height('40vp')
        .margin({ start: LengthMetrics.vp(8) })
        .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
        .accessibilityGroup(true)
        .accessibilityText(getContext(this).resourceManager.getStringSync($r('app.string.off').id))
        .opacity(this.isNeedAnimation ? this.animationViewModel.btnOpacity : 1)
        .onClick(() => {
          if (this.onClose) {
            HiLog.i(TAG, 'onClick onClose.');
            this.onClose();
            return;
          }
          this.isSettingShow = false;
        })
      }
    }
    .key('CustomSettingsNavBar')
    .width('100%')
    .height('56vp')
    .margin({ top: '8vp' })
    .padding({
      left: '16vp',
      right: '16vp'
    })
    .translate(this.isNeedAnimation ? { x: this.animationViewModel.translateTitle } : undefined)
  }
}