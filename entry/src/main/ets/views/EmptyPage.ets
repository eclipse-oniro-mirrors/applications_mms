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

@Component
export struct EmptyPage {
  icon: Resource = $rawfile('icon/ic_massage_m.svg')
  emptyDescription: Resource = $r('app.string.noMessages')
  fullPage: boolean = true
  fixedPageHeight: boolean = true
  customBackgroundColor: Color | undefined | Resource = Color.Transparent

  build() {
    Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
      Column() {
        Image(this.icon)
          .width($r('app.float.empty_image_width'))
          .height($r('app.float.empty_image_height'))
        Text(this.emptyDescription)
          .margin({ top: $r('app.float.empty_text_top_margin') })
          .fontWeight(FontWeight.Regular)
          .fontFamily('HarmonyHeiTi')
          .fontSize($r('app.float.conversation_list_no_message_fs'))
          .fontColor($r('sys.color.ohos_id_color_text_tertiary'))
      }
      // .margin({ top: '40%' })
      .offset({ y: -60 })
    }
    .backgroundColor(this.customBackgroundColor)
    .height('100%')
    .width('100%')
  }
}
