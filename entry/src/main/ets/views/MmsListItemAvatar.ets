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
import LooseObject from '../data/LooseObject';
import { ContactAvatar } from '../views/ContactAvatar'

@Component
@Reusable
export struct MmsListItemAvatar {
  @State item: LooseObject = {};
  @Prop isMultipleSelectState: boolean = false;
  @Prop loadFromDB: boolean = false;
  @StorageLink('selectPhoneNumber') selectPhoneNumber: string = '';
  onClickHead: (event?: ClickEvent) => void = () => {
  };

  getRawContactId(index?: number): string {
    if (index !== undefined) {
      const rawContactId: string = this.item.rawContactId || '';
      return rawContactId.split(',')[index] || ''
    }
    return ''
  }

  aboutToReuse(params: LooseObject) {
    this.item = params.item;
    this.isMultipleSelectState = params.isMultipleSelectState;
  }

  build() {
    Column() {
      Stack() {
        //SMS message type. 0: common; 1: notification
        if (this.item.smsType === 0) {
          Flex({ justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center,
            wrap: (this.item.smsType === 0 && this.item.photoFirstNames.length > 2)
              ? FlexWrap.Wrap : FlexWrap.NoWrap }) {
            ForEach(this.item.photoFirstNames, (photoFirstName: LooseObject, index?: number) => {
              ContactAvatar({
                rawContactId: this.getRawContactId(index),
                contactId: this.item.contactId,
                firstPhotoName: photoFirstName.firstName,
                portraitColor: photoFirstName.portraitColor ? photoFirstName.portraitColor : this.item.portraitColor,
                imgSize: this.item.photoSize.width,
                loadFromDB: this.loadFromDB,
                fontSize: this.item.photoFirstNames.length > 1
                  ? 8 : 0
              }).margin({
                left: (this.item.photoFirstNames.length === 3 && index === 0) ? 5 : 0,
                right: (this.item.photoFirstNames.length === 3 && index === 0) ? 5 : 0
              })
            })
          }
          .width('40vp')
          .height('40vp')
        } else {
          Image($rawfile(this.item.icon))
            .objectFit(ImageFit.Fill)
            .width('40vp')
            .height('40vp')
            .draggable(false)
        }
        if (this.item.countOfUnread > 0) {
          Text(this.item.countOfUnread < 100 ?
          this.item.countOfUnread.toString() : '99+')
            .fontSize($r('sys.float.ohos_id_text_size_caption'))
            .align(Alignment.Center)
            .padding({
              left: this.item.countOfUnread > 9 ? 6 : 0,
              right: this.item.countOfUnread > 9 ? 6 : 0
            })
            .constraintSize({ minWidth: 20 })
            .height(20)
            .textAlign(TextAlign.Center)
            .backgroundColor($r('sys.color.ohos_id_color_badge_red'))
            .fontColor($r('sys.color.ohos_id_color_text_primary_contrary'))
            .offset({ x: 4, y: -4 })
            .border({
              width: 2,
              color: $r('sys.color.ohos_id_color_background'),
              radius: 50
            })
        }
      }
      .width('40vp')
      .height('40vp')
      .alignContent(Alignment.TopEnd)
    }
    .id('contact_avatar')
    .borderRadius({
      topLeft: 16,
      bottomLeft: 16,
    })
    .width('40vp')
    .height('100%')
    .onClick(this.onClickHead)
    .justifyContent(FlexAlign.Center)
  }
}