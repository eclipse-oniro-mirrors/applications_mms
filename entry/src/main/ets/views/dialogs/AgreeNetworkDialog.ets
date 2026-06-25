/**
 * Copyright (c) 2022 Huawei Device Co., Ltd.
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
import HiLog from '../../utils/HiLog';

const TAG = 'AgreeNetworkDialog';

@Component
export struct AgreeNetworkDialog {
  @StorageProp('fontSizeScale') fontSizeScale: number = 1;
  controller?: CustomDialogController;
  /**
   * Cancel Event
   */
  cancel: () => void = () => {};
  /**
   * Acknowledge Event
   */
  confirm: () => void = () => {};
  /**
   * Message content
   */
  msg?: string | Resource;
  msgDescription?: string | Resource;
  showDelDialog: boolean = false;

  aboutToAppear() {
    HiLog.i(TAG, 'aboutToAppear');
  }

  build() {
    Scroll() {
      Column() {
        SymbolGlyph($r('sys.symbol.worldclock_fill'))
          .fontSize('20vp')
          .fontColor([$r('sys.color.icon_on_primary')])
          .backgroundColor($r('sys.color.ohos_id_color_activated'))
          .padding(6)
          .borderRadius(32)
        Column() {
          Text(this.msg)
            .width('100%')
            .textAlign(TextAlign.Center)
            .fontSize(this.fontSizeScale >= 2 ? '40vp' : 20)
            .maxLines(2)
            .ellipsisMode(EllipsisMode.END)
            .fontColor($r('sys.color.ohos_id_color_text_primary'))
            .fontWeight(FontWeight.Bold)
            .fontFamily('HarmonyHeiTi')
            .margin({ top: 15, bottom: 15 })

          Text(this.msgDescription)
            .width('100%')
            .textAlign(TextAlign.Center)
            .fontSize($r('sys.float.ohos_id_text_size_body1'))
            .fontColor($r('sys.color.ohos_id_color_text_primary'))
            .fontWeight(FontWeight.Regular)
            .fontFamily('HarmonyHeiTi')
        }
      }
      .width('100%')
    }
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
    .scrollBar(BarState.Off)
  }
}