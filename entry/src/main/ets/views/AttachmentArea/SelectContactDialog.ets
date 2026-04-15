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
import HiLog from '../../utils/HiLog';
import ConversationController from '../../pages/conversation/conversationController';
import { ContactType } from '../../utils/TypesUtils';
import myCommon from '@ohos.app.ability.common';
import ReceiveController from '../receive/receiveController';
import MMAttachmentAreaController from './MMAttachmentAreaController';
import { AlertDialog } from '@kit.ArkUI';
import CreateNewConversationViewModle from '../../pages/conversation/CreateNewConversationViewModle';
import { contact } from '@kit.ContactsKit';
import TelephoneUtil from '../../utils/TelephoneUtil';
import ConversationService from '../../service/ConversationService';
import { image } from '@kit.ImageKit';
import DateUtil from '../../utils/DateUtil';
import { util } from '@kit.ArkTS';
import FileUtil from '../../utils/FileUtil';
import LooseObject from '../../data/LooseObject';
import common from '../../data/commonData'
import dotCommon,{ mmsTypeParams } from '../../utils/MmsDot/DotCommon';
import DotUtil from '../../utils/MmsDot/DotUtils';

const TAG = 'SelectContactDialog';

@CustomDialog
export struct SelectContactDialog {
  private context = getContext(this) as myCommon.UIAbilityContext;
  private mmAreaController: MMAttachmentAreaController = MMAttachmentAreaController.getInstance();
  private contacts: contact.Contact[] = []
  private onTextValueChange: (value:string) => void = () => {};
  private afterContacts: ContactType[] = [];

  aboutToAppear(): void {
    this.handleContacts()
  }

  handleContacts() {
    let contactIds: number[] = [];
    let afterContacts: ContactType[] = this.contacts.map(contact => {
      let telephonesStr = contact.phoneNumbers ? contact.phoneNumbers.map(v => (v.phoneNumber)).join(',') : '';
      let telephoneFormatStr: string = contact?.phoneNumbers ?
      contact.phoneNumbers.map(v => TelephoneUtil.countryCodeFormatPhone(v.phoneNumber + '') as string).join(',') : '';
      // 联系人应用中，联系人号码id和联系人号码类型的对应关系
      const labelMap: LooseObject = {
        1: common.PHONE_NUMBER_TYPE.CELL,
        2: common.PHONE_NUMBER_TYPE.HOME,
        3: common.PHONE_NUMBER_TYPE.WORK,
        4: common.PHONE_NUMBER_TYPE.WORK_FAX,
        5: common.PHONE_NUMBER_TYPE.HOME_FAX,
        6: common.PHONE_NUMBER_TYPE.PAGER,
        7: common.PHONE_NUMBER_TYPE.VOICE,
        12: common.PHONE_NUMBER_TYPE.PREF,
      }
      let telephoneTypes = contact.phoneNumbers ? contact.phoneNumbers.map((v) => ((v?.labelId) ? labelMap[v.labelId] as string : '')).join(',') : '';
      if (contact.id) {
        contactIds.push(contact.id);
      };
      return {
        contactName: contact.name?.fullName || '',
        headImage: contact.portrait?.uri || '',
        telephone: telephonesStr,
        telephoneFormat: telephoneFormatStr,
        select: true,
        id: contact.id,
        telephoneType: telephoneTypes,
      } as ContactType;
    })
    ConversationService.getInstance()
    .queryContactsAvatarInContactDataDataBase(this.context, Array.from(new Set(contactIds)),
      async (res: LooseObject) => {
        let mapContactIdToAvatarBase64Encoded: Map<number, Uint8Array> = res?.abilityResult || new Map();
        for (let i = 0; (mapContactIdToAvatarBase64Encoded.size > 0 && i < afterContacts.length); i++) {
          if (!afterContacts[i]?.id) {
            continue;
          }
          let mapContactsBit = mapContactIdToAvatarBase64Encoded.get(afterContacts[i].id as number);
          let imageSource = image.createImageSource(mapContactsBit?.buffer);
          if (imageSource) {
            let pixelMap: PixelMap = await imageSource.createPixelMap({ desiredSize: { height: 128, width: 128 } });
            imageSource.release();
            let mapImgName: string = `PART_CONTACTS_${DateUtil.getTimeWithCount()}${'.jpg'}`;
            if (pixelMap) {
              let jpegPath = '/data/storage/el2/base/haps/entry/files/' + mapImgName;
              await FileUtil.packPixelMapToSandBox(this.context, jpegPath, pixelMap, mapImgName);
              pixelMap.release();
              afterContacts[i].photoPath = jpegPath;
            }
          }
          let base64Helper: util.Base64Helper = new util.Base64Helper();
          afterContacts[i].avatarBase64Encoded =
            mapContactsBit ? base64Helper.encodeToStringSync(mapContactsBit, util.Type.BASIC) : '';
        }
        this.afterContacts = afterContacts;
      })
  }

  delAttachmentArea: CustomDialogController = new CustomDialogController({
    builder: AlertDialog({
      primaryTitle: $r('app.string.attachment_replace_tip'),
      content: $r('app.string.attachment_replace_dialog_tip'),
      primaryButton: {
        value: $r('app.string.cancel'),
        buttonStyle: ButtonStyleMode.TEXTUAL,
        action: () => {
          this.delAttachmentArea?.close();
        },
      },
      secondaryButton: {
        value: $r('app.string.ok'),
        buttonStyle: ButtonStyleMode.TEXTUAL,
        action: () => {
          this.mmAreaController.resetMmsAndDeleteSource(this.context);
          this.addContacts(true);
        }
      }
    }),
    alignment: DialogAlignment.Center,
    autoCancel: false,
  });

  controller?: CustomDialogController;

  cancel: () => void = () => {
    this.controller?.close();
  }

  async addContacts(fromReplace: boolean = false) {
    if (!this.afterContacts || this.afterContacts.length === 0) {
      HiLog.i(TAG, 'onContactClick: selectContactsByPicker No selection');
      return;
    }
    // 这里要判断是新增会话还是现有会话
    await this.mmAreaController.setMmsVcard(this.context, this.afterContacts, fromReplace);
    // 添加vcard到附件区后，通过input聚焦，拉起键盘
    this.onTextValueChange('')
  }

  async onTextContactClick() {
    this.controller?.close();
    if (!this.contacts || this.contacts.length === 0) {
      HiLog.i(TAG, 'onContactClick: selectContactsByPicker No selection');
      return;
    }
    let text = ''
    this.contacts.forEach((contact, index) => {
      let hasContactName: boolean = !(this.afterContacts[index].telephone || '').includes(contact.name?.fullName as string)
      if (hasContactName) {
        text += `${this.context?.resourceManager.getStringSync($r('app.string.vcard_name'))}：${contact.name?.fullName}`
        if (contact.phoneNumbers?.length) {
          text += `\n`
        }
      }
      if (contact.phoneNumbers?.length) {
        contact.phoneNumbers.forEach((item, index) => {
          let phoneCounts = contact.phoneNumbers?.length || 0
          // text += `${item?.labelName}：${item.phoneNumber}`
          text += `${this.context?.resourceManager.getStringSync($r('app.string.vcard_mobile'))}：${item.phoneNumber}`
          if (phoneCounts > 0 && index !== phoneCounts - 1) {
            text += `\n`
          }
        })
      }
      if (index !== (this.contacts && this.contacts.length) as number - 1) {
        text += `\n---\n`
      }
    })
    this.onTextValueChange(text)
  }

  async onVcardContactClick() {
    // 添加联系人附件打点
    mmsTypeParams.TYPE_STATUS = common.int.TYPE_STATE_VCARD;
    DotUtil.getInstance().reportEvent(mmsTypeParams, dotCommon.eventName.ADD_ATTACHMENT);
    this.controller?.close()
    if (this.mmAreaController.mmDisplaySource.length > 0) {
      this.delAttachmentArea.open()
    } else {
      this.addContacts()
    }
  }

  // instrument ignore next
  build() {
    Column() {
      Text($r('app.string.attach_contacts'))
        .width('calc(100% - 48vp)')
        .textAlign(TextAlign.Center)
        .fontSize($r('sys.float.Title_S'))
        .fontColor($r('sys.color.font_primary'))
        .lineHeight(26)
        .fontWeight(FontWeight.Bold)
        .margin({
          top: 15,
          left: 24,
          right: 24,
          bottom: 15
        })
        .maxFontScale(2)
      Text($r('app.string.text'))
        .width('100%')
        .fontSize($r('sys.float.Body_L'))
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Medium)
        .lineHeight(21)
        .opacity(1)
        .padding({
          top: 13,
          left: 24,
          right: 24,
          bottom: 14
        })
        .maxFontScale(2)
        .backgroundColor(Color.Pink)
        .stateStyles({
          pressed: {
            .backgroundColor($r('sys.color.ohos_id_color_click_effect'))
          },
          normal: {
            .backgroundColor(Color.Transparent)
          }
        })
        .onClick(() => {
          this.onTextContactClick()
        })
      Divider().color($r('sys.color.comp_divider'))
        .margin({ right: 24, left: 24 }).height(1);
      Text($r('app.string.mms_vCard'))
        .width('100%')
        .fontSize($r('sys.float.Body_L'))
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Medium)
        .lineHeight(21)
        .padding({
          top: 13,
          left: 24,
          right: 24,
          bottom: 14
        })
        .maxFontScale(2)
        .stateStyles({
          pressed: {
            .backgroundColor($r('sys.color.ohos_id_color_click_effect'))
          },
          normal: {
            .backgroundColor(Color.Transparent)
          }
        })
        .onClick(() => {
          this.onVcardContactClick()
        })
      Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
        Button() {
          Text($r('app.string.cancel'))
            .textAlign(TextAlign.Center)
            .fontSize($r('sys.float.Body_L'))
            .fontColor($r('sys.color.font_emphasize'))
            .fontWeight(FontWeight.Medium)
            .fontFamily('HarmonyHeiTi')
            .constraintSize({ minHeight: 40 })
            .maxFontScale(2)
        }
        .backgroundColor($r('sys.color.ohos_id_color_background_transparent'))
        .layoutWeight(1)
        .onClick(() => {
          this.cancel()
        })
      }
      .margin({ top: 8, left: 16, right: 16, bottom: 16 })
    }
    .width('100%')
  }
}
