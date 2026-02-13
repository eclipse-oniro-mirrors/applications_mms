/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
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
import LooseObject from '../data/LooseObject';
import HiLog from '../utils/HiLog';
import { getPixelMapFromFile } from '../utils/UserPhotoUtil';
import common from '../data/commonData';
import { fileUri } from '@kit.CoreFileKit';
import lazy { ComInfoModel } from '../model/ComInfoModel';
import StringUtil from '../utils/StringUtil';
import Constant from '../data/Constant';
import { ConfigurationConstant } from '@kit.AbilityKit';
import TelephoneUtil from '../utils/TelephoneUtil';
import FileUtils from '../utils/FileUtils';
import myCommon from '@ohos.app.ability.common';

const TAG = 'ContactAvatar'

@Component
@Reusable
export struct ContactAvatar {
  @Prop rawContactId: string | null = null;
  @Prop contactId: string | null = null;
  @Prop firstPhotoName: string = '';
  portraitColor: string | Resource  = '';
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
  // 是否服务号端口，默认非服务号端口
  @State isPubPort: boolean = false;
  private context = getContext(this) as myCommon.UIAbilityContext;
  @StorageProp('currentColorMode') currentMode: ConfigurationConstant.ColorMode =
    ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT;

  aboutToReuse(params: ESObject): void {
    let paramss: LooseObject = params as LooseObject;
    this.contactId = paramss.contactId;
    this.comInfoLogoUrl = paramss.comInfoLogoUrl;
    if (this.contactId) {
      this.photoPixelMap = null;
      getPixelMapFromFile(this.contactId, this.loadFromDB, (pixelMap: PixelMap | null) => {
        if (pixelMap) {
          this.photoPixelMap = pixelMap;
        }
      }, getContext(this))
    } else {
      this.getPubInfo();
    }

  }


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
    } else {
      this.getPubInfo();
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

  //获取企业服务号信息
  getPubInfo() {
    if (!this.phoneNumber) {
      return;
    }
    // this.isPubPort = IpMsgApi.isPubPort(this.phoneNumber);
    let hasImage = FileUtils.isHasLocationImage(this.context, this.phoneNumber);
    //判断，既不是ip端口号，又不是通知类型，不再请求服务号，防止重复打印
    if (!this.isPubPort && !TelephoneUtil.judgeIsInfoMsg(this.phoneNumber)) {
      return;
    }
    // 查询条件：
    // 1、智能信息开关打开并且是NOTICE、消息
    // 2、服务号端口（虚拟端口号）
    // if ((this.isSmartOpen && (this.smsType === common.sms_type.NOTICE) && !hasImage) || this.isPubPort) {
    //   PubInfoUtils.queryPubInfo(this.phoneNumber, (pubInfoData: NotificationProcessorModel.PubInfoData | null | undefined) => {
    //     this.updatePubInfo(pubInfoData);
    //   }).then((pubInfoData: NotificationProcessorModel.PubInfoData | null | undefined) => {
    //     this.updatePubInfo(pubInfoData);
    //   });
    // } else {
    //   HiLog.w(TAG, 'getPubInfo dont need query pubInfo.');
    // }
  }

  // private updatePubInfo(pubInfoData: NotificationProcessorModel.PubInfoData | null | undefined) {
  //   if (!pubInfoData) {
  //     HiLog.w(TAG, 'updatePubInfo query data is empty.');
  //     return;
  //   }
  //   // 更新logo，变化了才更新
  //   if (!StringUtil.isEmpty(pubInfoData.pubLogoUrl) && this.comInfoLogoUrl !== pubInfoData.pubLogoUrl) {
  //     this.comInfoLogoUrl = pubInfoData.pubLogoUrl;
  //     HiLog.w(TAG, 'updatePubInfo update logoURL.');
  //   }
  // }

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
    } else if (this.contactId && !this.photoPixelMap && !StringUtil.isEmpty(this.firstPhotoName)) {
      Text(this.firstPhotoName)
        .fontSize(this.fontSize ? this.fontSize + 'vp' : '16vp')
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.ohos_id_color_primary_contrary'))
        .height(this.imgSize)
        .width(this.imgSize)
        .textAlign(TextAlign.Center)
        .clip(new Circle({ width: this.imgSize, height: this.imgSize }))
        .accessibilityText(getContext(this).resourceManager.getStringSync($r('app.string.contact_avatar_button').id))
        .backgroundColor($r('app.color.mms_avatar_bg'))
    } else if (this.contactId && StringUtil.isEmpty(this.firstPhotoName)) {
      this.defaultContactAvatar()
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
    } else if (this.isSmartOpen && (this.isPubPort || TelephoneUtil.judgeIsInfoMsg(this.phoneNumber))
      && (this.comInfoLogoUrl || FileUtils.isHasLocationImage(this.context, this.phoneNumber))) {
      Image(FileUtils.isHasLocationImage(this.context, this.phoneNumber) ?
      FileUtils.getSandboxPath(this.context, this.phoneNumber) : this.comInfoLogoUrl)
        .objectFit(ImageFit.Fill)
        .width('40vp')
        .height('40vp')
        .draggable(false)
        .alt(Number(this.currentMode) == ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT?
        $rawfile('icon/ic_bell_default_light.svg'): $rawfile('icon/ic_bell_default_dark.svg'))
        .accessibilityText(getContext(this).resourceManager.getStringSync($r('app.string.contact_avatar_button').id))
        .clip(new Circle({ width: '40vp', height: '40vp' }))
        .syncLoad(FileUtils.isHasLocationImage(this.context, this.phoneNumber) ? true : false)
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
    } else if (this.smsType === common.sms_type.NOTICE) {
      this.defaultContactAvatar()
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
        .accessibilityText(getContext(this).resourceManager.getStringSync($r('app.string.contact_avatar_button').id))
        .backgroundColor($r('app.color.mms_avatar_bg'))
    }
  }

  @Builder
  defaultContactAvatar() {
    // 普通短信或者不是服务号端口，展示人像默认图，否则展示铃铛的icon
    if (this.smsType === common.sms_type.COMMON || (this.smsType === common.sms_type.RCS /*&&
      !IpMsgApi.isPubPort(this.phoneNumber)*/)) {
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
        .accessibilityText(getContext(this).resourceManager.getStringSync($r('app.string.contact_avatar_button').id))
        .syncLoad(true)
    }
  }
}