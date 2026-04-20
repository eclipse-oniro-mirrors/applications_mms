/**
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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

@Extend(Button)
function buttonStyles() {
  .type(ButtonType.Circle)
  .height(40)
  .width(40)
  .borderRadius($r('sys.float.corner_radius_level4'))
  .buttonStyle(ButtonStyleMode.NORMAL)
  .stateEffect(true)
}

//标题需要的变量类
class TitleVariableClass {
  public pageTitle: Resource = $r('app.string.new_message')
}

@Builder
export function NavDestinationHeaderView($$: TitleVariableClass) {
  Row() {
    Button() {
      SymbolGlyph($r('sys.symbol.chevron_backward'))
        .fontColor([$r('sys.color.ohos_id_color_primary')])
        .fontSize('24vp')
        .width('24vp')
        .height('24vp')
        .draggable(false)
    }
    .buttonStyles()
    .onClick(() => {
    })

    Text($$.pageTitle)
      .fontSize($r('sys.float.ohos_id_text_size_headline8'))
      .fontColor($r('sys.color.ohos_id_color_text_primary'))
      .fontWeight(FontWeight.Bold)
      .margin({ left: 8 })
  }
  .alignItems(VerticalAlign.Center)
  .constraintSize({
    minHeight: $r('app.float.id_item_height_large')
  })
  .width('100%')
}