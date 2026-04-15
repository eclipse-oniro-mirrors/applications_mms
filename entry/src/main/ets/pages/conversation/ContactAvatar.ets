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
import { inputMethod } from '@kit.IMEKit';
import { clickAvatarParams } from '../../utils/MmsDot/DotCommon';
import { getPixelMapFromFile } from '../../utils/UserPhotoUtil';
import ConversationController from './conversationController';
import DotUtil from '../../utils/MmsDot/DotUtils';
import common from '../../data/commonData';
import dotCommon from '../../utils/MmsDot/DotCommon';
import myCommon from '@ohos.app.ability.common';

@Component
export default struct ContactAvatar {
  @Link conversationCtrl: ConversationController;
  @Prop @Watch('doChangeContact') rawContactId: string = '';
  @State photoPixelMap: PixelMap | null = null;
  @State textareaFocusable: boolean = true;
  private context = getContext(this) as myCommon.UIAbilityContext;
  @StorageProp('contactPhotoChanged') @Watch('doChangePhoto') contactId: string = '';

  aboutToAppear() {
    if (!this.context) {
      this.context = getContext(this) as myCommon.UIAbilityContext;
    }
    if (this.rawContactId) {
      getPixelMapFromFile(this.rawContactId, true, (pixelMap: PixelMap | null) => {
        this.photoPixelMap = pixelMap
      })
    } else {
      this.photoPixelMap = null;
    }
  }

  aboutToDisappear(): void {
    this.photoPixelMap?.release();
  }

  doChangeContact() { // delete contact
    if (!this.rawContactId) {
      this.photoPixelMap = null;
    }
  }

  doChangePhoto() { //change photo
    if (this.contactId.split('-')[0] === this.rawContactId && this.rawContactId) {
      const contactsPhotoMap: Record<string, PixelMap> = AppStorage.get('contactsPhotoMap') || {};
      this.photoPixelMap = contactsPhotoMap[this.rawContactId] || null
    }
  }

  build() {
    if (this.conversationCtrl.smsType != 0) {

      Image($rawfile('icon/ic_bell_fill.svg'))
        .objectFit(ImageFit.Fill)
        .width(40)
        .height(40)
        .draggable(false)
        .clip(new Circle({ width: 40, height: 40 }))
        .onClick(() => {
          this.conversationCtrl.titleBarAvatar(this.context);
        })

    } else if (this.photoPixelMap) {
      Image(this.photoPixelMap)
        .objectFit(ImageFit.Fill)
        .width(40)
        .height(40)
        .draggable(false)
        .clip(new Circle({ width: 40, height: 40 }))
        .onClick(() => {
          this.conversationCtrl.titleBarAvatar(this.context);
        })
    } else if (!this.rawContactId || this.conversationCtrl.strContactsName === '' ||
      this.conversationCtrl.photoFirstName === common.FIRST_NAME_TYPE.NOT_CHARACTER) {
      Image($rawfile('icon/ic_user_portrait.svg'))
        .objectFit(ImageFit.Fill)
        .width(40)
        .height(40)
        .draggable(false)
        .id('topContactPicture')
        .clip(new Circle({ width: 40, height: 40 }))
        .accessibilityText(getContext(this).resourceManager.getStringSync($r('app.string.contact_avatar_button').id))
        .backgroundColor(this.conversationCtrl.portraitColor)
        .onClick(() => {
          this.conversationCtrl.titleBarAvatar(this.context);
          this.textareaFocusable = false;
          // The requestFocus is not always very reliable.
          // Call hideTextInput make double insurance.
          if (canIUse('SystemCapability.MiscServices.InputMethodFramework')) {
            inputMethod.getController().hideTextInput();
          }
          // 详情-点击单人头像打点
          clickAvatarParams.CLICK_PAGE = 'conversation';
          DotUtil.getInstance().reportEvent(clickAvatarParams, dotCommon.eventName.CLICK_AVATAR_EVENT);
        })
    } else {
      Text(this.conversationCtrl.photoFirstName)
        .fontSize($r('sys.float.Title_S'))
        .fontWeight(FontWeight.Medium)
        .fontColor(Color.White)
        .height('40vp')
        .width('40vp')
        .textAlign(TextAlign.Center)
        .clip(new Circle({ width: '40vp', height: '40vp' }))
        .backgroundColor(this.conversationCtrl.portraitColor)
        .onClick(() => {
          this.conversationCtrl.titleBarAvatar(this.context);
          this.textareaFocusable = false;
          // The requestFocus is not always very reliable.
          // Call hideTextInput make double insurance.
          if (canIUse('SystemCapability.MiscServices.InputMethodFramework')) {
            inputMethod.getController().hideTextInput();
          }
        })
    }
  }
}