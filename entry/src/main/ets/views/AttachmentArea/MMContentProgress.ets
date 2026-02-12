/**
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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
interface MMContentImageProgressProps {
  progressValue: number
  progressWidth: number
  onCancelButtonClick: () => void
}

@Builder
export function MMContentImageProgress($$: MMContentImageProgressProps) {
  Row() {
    Progress({ value: 0, total: 100, type: ProgressType.Linear })
      .width($$.progressWidth)
      .height(24)
      .margin({ right: 12 })
      .style({ enableSmoothEffect: false })
      .value($$.progressValue)
      .color($r('app.color.brand'))
    Row(){
      SymbolGlyph($r('sys.symbol.xmark_circle_fill'))
        .width(24)
        .height(24)
        .draggable(false)
        .fontSize('24vp')
        .fontColor([$r('sys.color.ohos_id_color_tertiary')])
        .renderingStrategy(SymbolRenderingStrategy.MULTIPLE_COLOR)
        .onClick(() => {
          $$.onCancelButtonClick();
        })
        .accessibilityLevel('no')
    }
    .accessibilityText($r('app.string.cancel_button_double_click_operation'))
  }
  .margin({ top: 4 })
  .width($$.progressWidth + 36)
}