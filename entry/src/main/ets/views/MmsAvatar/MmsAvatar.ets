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
import { RedirectDetailParams } from '../../chatbot/utils/ChatbotEntitys';
import LooseObject from '../../data/LooseObject';
import { ContactAvatar } from '../ContactAvatar';
import DotUtil from '../../utils/MmsDot/DotUtils';
import dotCommon, { dotNoNeedParmas } from '../../utils/MmsDot/DotCommon';
import  MmsAvatarController from './MmsAvatarController';
interface photoFirstNameType{
  firstName: string,
  portraitColor: ResourceColor
}

@Component
export struct MmsAvatar {
  @Consume('pageInfos') pageInfos: NavPathStack
  @State item: LooseObject= {};
  private mmsAvatarController: MmsAvatarController = MmsAvatarController.getInstance();

  aboutToAppear() {
    this.mmsAvatarController.onShow(this.pageInfos as NavPathStack);
  }

  build() {
    Column() {
      if (this.item.smsType === 0) {
        Flex({ justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center,
          wrap: (this.item.smsType === 0 && this.item.photoFirstNames.length > 2)
            ? FlexWrap.Wrap : FlexWrap.NoWrap}) {
          ForEach(this.item.photoFirstNames, (photoFirstName: photoFirstNameType, index: number) => {
            ContactAvatar({
              hasYellowPageIcon: this.item.hasYellowPageIcon ?
                ((this.item.hasYellowPageIcon.split(',') as string[]).length > index ?
                this.item.hasYellowPageIcon.split(',')[index] : '') : '',
              rawContactId: this.item.rawContactId ?
                ((this.item.rawContactId.split(',') as string[]).length > index ?
                this.item.rawContactId.split(',')[index] : null) : null,
              contactId: this.item.contactId,
              firstPhotoName: photoFirstName.firstName,
              portraitColor: photoFirstName.portraitColor ? photoFirstName.portraitColor : this.item.portraitColor,
              imgSize: this.item.photoSize.width,
              fontSize: this.item.photoFirstNames.length > 1
                ? 8 : 0
            }).margin({
              left: (this.item.photoFirstNames.length === 3 && index === 0) ? 5 : 0,
              right: (this.item.photoFirstNames.length === 3 && index === 0) ? 5 : 0
            })
          })
        }
        .width(40)
        .height(40)
      } else {
        if (this.item.hasYellowPageIcon) {
          Flex({justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
            ContactAvatar({
              hasYellowPageIcon: this.item.hasYellowPageIcon
            })
          }
          .id('transmit_icon').width('40vp').height('40vp')
        } else if (this.item.chatbotPageIcon) {
          Flex({justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
            ContactAvatar({
              chatbotPageIcon: this.item.chatbotPageIcon
            })
          }
          .id('transmit_icon').width('40vp').height('40vp')
        } else {
          Image($rawfile(this.item.icon))
            .objectFit(ImageFit.Fill)
            .width(40)
            .height(40)
            .draggable(false)
            .backgroundColor($r('app.color.mms_avatar_bg'))
            .fillColor($r('sys.color.ohos_id_color_primary_contrary'))
            .borderRadius(20)
            .padding(8)
        }
      }
    }
    .width(40)
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      if (this.item.telephone.startsWith('sip:') &&
      this.item.telephone.includes('botplatform')) {
        let params: RedirectDetailParams = {
          id:  this.item.telephone,
          icon: this.item.chatbotPageIcon,
          name: this.item.name,
        }
        this.pageInfos.pushPathByName('RcsDetailsChatbotActivity', params);
        DotUtil.getInstance().reportEvent(dotNoNeedParmas, dotCommon.eventName.OPEN_CHATBOT_DETAIL);
      } else {
        this.mmsAvatarController.clickAvatar(this.item);
      }
    })
  }
}