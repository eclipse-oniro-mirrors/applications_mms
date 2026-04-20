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

import HiLog from '../utils/HiLog';
import { getPixelMapFromFile } from '../utils/UserPhotoUtil';
import common from '../data/commonData';
import { fileUri } from '@kit.CoreFileKit';
import Constant from '../data/Constant';
import { ConfigurationConstant } from '@kit.AbilityKit';

// instrument ignore file
const TAG = 'SearchResultContactAvatar'

@Component
export struct SearchResultContactAvatar {
  @Prop rawContactId: string | null = null;
  @Prop contactId: string | null = null;
  @Prop firstPhotoName: string = '';
  portraitColor: Resource | null = null;
  @Prop imgSize: number = 40;
  @Prop loadFromDB: boolean = false;
  @Prop fontSize: number = 0;
  @Prop marginLength: number = 0;
  @Prop index: number = 0;
  @State photoPixelMap: PixelMap | null = null;
  @Prop hasYellowPageIcon: string = '';
  @Prop smsType: number = 0;
  @Prop avatarIcon: string = '';
  @Prop chatbotPageIcon?: string = '';
  @StorageLink('contactAvatarShow') @Watch('getPhotoPixelMap') contactAvatarShow: boolean = false;
  @Prop phoneNumber: string = '';
  @Prop yellowPageId: string = '';
  @Prop comInfoLogoUrl: string = '';
  @Prop isSmartOpen: boolean = false;
  @Prop blockedType: number = 0;
  @StorageProp('currentColorMode') currentMode: ConfigurationConstant.ColorMode =
    ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT;


  aboutToAppear() {
    if (this.contactId) {
      HiLog.i( TAG, 'contactId: ' + this.contactId + '; loadFromDB: ' + this.loadFromDB)
      HiLog.i( TAG, 'photoPixelMap:' + this.photoPixelMap )
      getPixelMapFromFile(this.contactId, this.loadFromDB, (pixelMap: PixelMap | null) => {
        if (pixelMap) {
          this.photoPixelMap = pixelMap;
        }
      }, getContext(this))
      HiLog.i( TAG, 'photoPixelMap:' + this.photoPixelMap )
    }
  }

  getPhotoPixelMap() {
    if (this.contactId) {
      getPixelMapFromFile(this.contactId, this.loadFromDB, (pixelMap: PixelMap | null) => {
        if (pixelMap) {
          this.photoPixelMap = pixelMap;
        } else {
          this.photoPixelMap = null;
        }
      }, getContext(this))
    }
  }

  build() {
    if (this.contactId && this.photoPixelMap) {
      Image(this.photoPixelMap)
        .objectFit(ImageFit.Fill)
        .width(this.imgSize)
        .height(this.imgSize)
        .draggable(false)
        .accessibilityText(getContext(this).resourceManager.getStringSync($r('app.string.contact_avatar_button').id))
        .clip(new Circle({ width: this.imgSize, height: this.imgSize }))
        .syncLoad(true)
    } else if (this.chatbotPageIcon) {
      Image(this.chatbotPageIcon?.startsWith('https') ? this.chatbotPageIcon :
      fileUri.getUriFromPath(this.chatbotPageIcon))
        .objectFit(ImageFit.Auto)
        .width('40vp')
        .height('40vp')
        .draggable(false)
        .accessibilityText(getContext(this).resourceManager.getStringSync($r('app.string.contact_avatar_button').id))
        .clip(new Circle({ width: '40vp', height: '40vp' }))
        .syncLoad(true)
        .alt(Number(this.currentMode) == ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT?
          $rawfile('icon/ic_bell_default_light.svg'): $rawfile('icon/ic_bell_default_dark.svg'))
        .backgroundColor($r('app.color.mms_avatar_bg'))
        .fillColor($r('sys.color.ohos_id_color_primary_contrary'))
    } else if (this.isSmartOpen && this.comInfoLogoUrl !== '') {
      Image(this.comInfoLogoUrl)
        .objectFit(ImageFit.Fill)
        .width('40vp')
        .height('40vp')
        .draggable(false)
        .accessibilityText(getContext(this).resourceManager.getStringSync($r('app.string.contact_avatar_button').id))
        .clip(new Circle({ width: '40vp', height: '40vp' }))
    } else if (this.hasYellowPageIcon) {
      Image('data:image/png;base64,' + this.hasYellowPageIcon)
        .draggable(false)
        .objectFit(ImageFit.Fill)
        .width(this.imgSize)
        .height(this.imgSize)
        .flexShrink(0)
        .accessibilityText(getContext(this).resourceManager.getStringSync($r('app.string.contact_avatar_button').id))
        .clip(new Circle({ width: this.imgSize, height: this.imgSize }))
        .border({ width: '1vp', style: BorderStyle.Solid, radius: '20vp',
          color: $r('sys.color.ohos_id_color_click_effect') })
        .syncLoad(true)
    } else if (this.firstPhotoName === common.STR.WHITE_SPACE) {
      this.defaultContactAvatar()
    } else if (this.blockedType === Constant.SESSION_BLOCKED_FRAUD) {
      this.defaultContactAvatar()
    } else {
      Text(this.firstPhotoName)
        .fontSize(this.fontSize ? this.fontSize + 'vp' : '16vp')
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.ohos_id_color_primary_contrary'))
        .height(this.imgSize)
        .width(this.imgSize)
        .textAlign(TextAlign.Center)
        .clip(new Circle({ width: this.imgSize, height: this.imgSize }))
        .backgroundColor($r('app.color.mms_avatar_bg'))
    }
  }

  @Builder
  defaultContactAvatar() {
    if (this.smsType === common.sms_type.COMMON || this.smsType === common.sms_type.RCS) {
      Image($rawfile('icon/ic_user_portrait.svg'))
        .objectFit(ImageFit.Fill)
        .width(this.imgSize)
        .height(this.imgSize)
        .clip(new Circle({ width: this.imgSize, height: this.imgSize }))
        .backgroundColor($r('app.color.mms_avatar_bg'))
        .foregroundColor($r('sys.color.ohos_id_color_primary_contrary'))
        .draggable(false)
        .accessibilityText(getContext(this).resourceManager.getStringSync($r('app.string.contact_avatar_button').id))
        .syncLoad(true)
    } else {
      Image($rawfile(this.avatarIcon))
        .width('40vp')
        .height('40vp')
        .draggable(false)
        .objectFit(ImageFit.Fill)
        .backgroundColor($r('app.color.mms_avatar_bg'))
        .fillColor($r('sys.color.ohos_id_color_primary_contrary'))
        .borderRadius(20)
        .padding(8)
        .syncLoad(true)
    }
  }
}