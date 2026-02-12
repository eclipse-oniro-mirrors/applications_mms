/**
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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

import { LengthMetrics } from '@kit.ArkUI'
import { FontSizeScale } from '../data/Constant';

@Component
export default struct EnableNotificationDialogContent {
  @StorageProp('fontSizeScale') fontSizeScale: number = 1;

  build() {
    Scroll() {
      Column() {
        SymbolGlyph($r('sys.symbol.bell_fill'))
          .key('enableNotification_icon')
          .fontColor([$r('sys.color.icon_on_primary')])
          .fontSize('20vp')
          .width('32vp')
          .height('32vp')
          .borderRadius(16)
          .backgroundColor($r('sys.color.icon_emphasize'))
          .padding(6)
        Text($r('app.string.enable_notification_dialog_title'))
          .key('enableNotification_title')
          .fontColor($r('sys.color.ohos_id_color_text_primary'))
          .maxFontScale(3)
          .font({
            size: $r('sys.float.ohos_id_text_size_dialog_tittle'),
            weight: FontWeight.Bold
          })
          .margin({
            top: '16vp',
            bottom: '16vp'
          })

        Text($r('app.string.enable_notification_dialog_content'))
          .key('enableNotification_context')
          .fontColor($r('sys.color.ohos_id_color_text_primary'))
          .textAlign(TextAlign.Start)
          .font({
            size: $r('sys.float.ohos_id_text_size_body1'),
            weight: FontWeight.Regular
          })
          .maxFontScale(2)
      }
      .key('enableNotification_column')
      .margin({
        end: this.fontSizeScale > FontSizeScale.NORMAL ?
        LengthMetrics.resource($r('app.float.elements_margin_horizontal_middle')) :
        LengthMetrics.resource($r('app.float.padding_zero'))
      })
    }
    .key('enableNotification_content_Scroll')
  }
}