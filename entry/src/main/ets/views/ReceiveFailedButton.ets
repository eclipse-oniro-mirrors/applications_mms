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
import commonData from '../data/commonData';
import { mmsListType } from '../pages/conversation/conversationController';

@Component
export struct ReceiveFailedButton {
  @ObjectLink mmsItem: mmsListType;
  @Prop contactsNum: number;
  onReceiveFailedButtonClick = () => {
  }

  build() {
    Row() {
      if ((this.contactsNum == 1 &&
        this.mmsItem.receiveState == commonData.int.SEND_MESSAGE_FAILED) ||
        this.mmsItem.sendStatus == commonData.int.SEND_MESSAGE_FAILED) {
        Row() {
          Image($rawfile('icon/ic_public_error.svg'))
            .width(16)
            .height(16)
            .fillColor($r('sys.color.warning'))
            .objectFit(ImageFit.Fill)
        }
        .accessibilityLevel('yes')
        .onClick(() => {
          this.onReceiveFailedButtonClick()
        })
      }
    }
  }
}