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

@Component
export default struct ManageSimBubbleText {
  private bubbleTextBorderRadius: Array<number> = []; // Fillet size, two parameters in total
  private bubbleTextDirection: string = ''; // left: upper left corner right: upper right corner
  private content: string = ''; // Bubble Display Content
  private bubbleTextBackgroundColor?: Resource | string; // Bubble background color
  @State showMenu: boolean = false;

  build() {
    Row() {
      Text(this.content)
        .fontSize(16)
        .lineHeight(21)
        .fontColor($r('sys.color.ohos_id_color_text_primary'))
        .fontWeight(FontWeight.Regular)
    }
    .padding({ left: 12, right: 12, top: 8, bottom: 8 })
    .backgroundColor(this.bubbleTextBackgroundColor)
    .borderRadius(this.bubbleTextDirection == 'right' ?
      { topLeft: this.bubbleTextBorderRadius[1], topRight: this.bubbleTextBorderRadius[0],
        bottomLeft: this.bubbleTextBorderRadius[1], bottomRight: this.bubbleTextBorderRadius[1] } :
      { topLeft: this.bubbleTextBorderRadius[0], topRight: this.bubbleTextBorderRadius[1],
        bottomLeft: this.bubbleTextBorderRadius[1], bottomRight: this.bubbleTextBorderRadius[1] })
    .flexBasis('auto')
  }
}

