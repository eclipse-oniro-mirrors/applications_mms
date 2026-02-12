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
import HiLog from '../../utils/HiLog';
import ConversationController from '../../pages/conversation/conversationController';
import SharedPreferencesUtils from '../../utils/SharedPreferencesUtils';
import StringUtil from '../../utils/StringUtil';
import lazy { VCardUtil } from '../../utils/VCardUtil';
import Configuration from '@system.configuration';
import { ContactType } from '../../utils/TypesUtils';
import myCommon from '@ohos.app.ability.common';
import common from '../../data/commonData';
import { ContactInfo } from '../../utils/Contact'
import { VCardParser, VCardConstants, SelectedItemType } from '../../utils/VCardParser';
import { SavedFileInfo,  } from '../../utils/FileUtil';
import LooseObject, { isObjectType } from '../../data/LooseObject'

const TAG = 'MMContactsDialog';
const CONTACT_NAME = VCardConstants.PROPERTY_FN;
const TELEPHONE = VCardConstants.PROPERTY_TEL;
const EMAIL = VCardConstants.PROPERTY_EMAIL;
const ADDRESS = VCardConstants.PROPERTY_ADR;
const WEBSITE = VCardConstants.PROPERTY_URL;
const ORG = VCardConstants.PROPERTY_ORG;
const TITLE = VCardConstants.PROPERTY_TITLE;
const BDAY = VCardConstants.PROPERTY_BDAY;
const NICKNAME = VCardConstants.PROPERTY_NICKNAME;
const NOTE = VCardConstants.PROPERTY_NOTE;
const SAVE_VCARD = 2;
/**
 * 系统语言切换为镜像语言时，电话号码文字顺序不符合预期
 * 修改方式：插入控制字符'\u202A' +'\u202C'
 */
const CONTROL_CODE_START = '\u202A';
const CONTROL_CODE_END = '\u202C';
/**
 * Dialog for show vcard.
 */
@CustomDialog
export struct MMCheckVcardDialog {
  controller?: CustomDialogController;
  path: string = '';
  @State mConversationCtrl: ConversationController = ConversationController.getInstance();
  @State contacts: ContactTypeForUI[] = [{
    contactName: '',
    telephone: '',
    telephoneFormat: '',
    headImage: '',
    select: false,
    id: 0
  }]
  @State isSingleContactOrMultipleTel: boolean = false;
  @State filterAfterArr: ContactTypeForUI[] = [];
  private textDirection: string = Configuration.getLocale().dir;

  @Styles
  pressedStyles() {
    .backgroundColor($r('sys.color.ohos_id_color_click_effect'))
    .opacity(1)
  }

  async aboutToAppear() {
    HiLog.i(TAG, 'aboutToAppear');
    const context = getContext(this) as myCommon.UIAbilityContext;
    // get contacts from the vCard
    let contacts = await VCardUtil.getInstance().parseVCard(context, this.path, 0);
    this.contacts = [...contacts];
    //  is every item's name same
    this.isSingleContactOrMultipleTel = this.contacts.every(contact => {
      return contact.contactName === this.contacts[0].contactName && contact.id === this.contacts[0].id;
    })
    this.filterAfterArr = this.mConversationCtrl.mmCheckVcardDialogAppear(this.contacts, this.filterAfterArr);
  }

  build() {
    Column() {
      Text($r('app.string.view_vcard'))
        .width('calc(100% - 48vp)')
        .textAlign(TextAlign.Center)
        .fontSize($r('sys.float.Title_S'))
        .fontColor($r('sys.color.ohos_id_color_text_primary'))
        .lineHeight(26)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 15, left: 24, right: 24, bottom: 15 })
        .id('show_vcard_title')
        .maxFontScale(2)
      if (this.isSingleContactOrMultipleTel) {
        contactsNameAndTel({ contacts: this.contacts, isReceiveMessage: false })
      } else {
        onlyShowContactName({ contacts: this.filterAfterArr })
      }
      Flex({
        direction: FlexDirection.Row,
        justifyContent: FlexAlign.Center,
        alignItems: ItemAlign.Center
      }) {
        Button() {
          Text($r('app.string.msg_know'))
            .textAlign(TextAlign.Start)
            .fontSize($r('sys.float.Body_L'))
            .fontColor($r('sys.color.ohos_id_color_text_primary_activated'))
            .fontWeight(FontWeight.Medium)
            .fontFamily('HarmonyHeiTi')
            .constraintSize({ minHeight: 40 })
            .maxFontScale(2)
            .id(`button_ok`)
        }
        .backgroundColor($r('sys.color.ohos_id_color_background_transparent'))
        .layoutWeight(1)
        .onClick(() => {
          this.controller?.close();
        })
      }
      .width('100%')
      .padding({ top: 8, bottom: 16, left: 16, right: 16 })
    }
  }
}

interface ParamOfContactTypeForUIAndIndex {
  item: ContactTypeForUI
  index: number
}

interface ParamOfSelectedItemTypeAndIndex {
  item: SelectedItemType
  index: number
}
@Component
struct contactsNameAndTel {
  isReceiveMessage: boolean = false;
  @State contacts: ContactType[] = []
  @Prop selectedItemOfSingleContactVCard: SelectedItemType[];
  private textDirection: string = Configuration.getLocale().dir;
  @StorageProp('fontSizeScale') fontSizeScale: number = 1;

  setSelectedItemOfSingleContactVCard = (v: SelectedItemType[]) => {
  }

  @Styles
  pressedStyles() {
    .backgroundColor($r('sys.color.ohos_id_color_click_effect'))
    .borderRadius($r('sys.float.corner_radius_level8'))
    .opacity(1)
  }

  aboutToAppear(): void {
    if (this.isReceiveMessage) {
      try {
        this.getSelectedItemOfSingleContactVCard();
      } catch (e) {
        HiLog.e(TAG, `getSelectedItemOfSingleContactVCard error ${JSON.stringify(e)}`)
        this.setSelectedItemOfSingleContactVCard([]);
      }
    }
  }

  // 转换 数组形式的联系人信息到 selectedItem 中
  convertArrContactInfoToSelectedItem(
    items: ESObject[],
    selectedItem: SelectedItemType[],
    key: string,
    valueKey?: string,
    typeKey?: string) {
    items.forEach((item:ESObject) => {
      let medium: SelectedItemType = new SelectedItemType()
      medium.key = key
      medium.value = valueKey ? item[valueKey] || '' : item || ''
      medium.type = typeKey ? item[typeKey] || '' : undefined
      medium.isSelect = this.contacts[0].select || false
      //报错
      // if (this.contacts) {
      //   medium.originContact = this.contacts.[0]||undefined
      // }
      selectedItem.push(medium);
    });
  };

  // 转换 字符串形式的联系人信息到 selectedItem 中
  convertStrContactInfoToSelectedItem(content: string, selectedItem: SelectedItemType[], key: string) {
    let medium: SelectedItemType = new SelectedItemType()
    medium.key = key
    medium.value = content
    medium.isSelect = this.contacts[0].select || false
    // medium.originContact = this.contacts?.[0]
    selectedItem.push(medium);
  };

  convertContactInfoToSelectedItem(copyContactsFirstItem: ContactType, selectedItemOfSingleContactVCard: SelectedItemType[]) {
    if (VCardUtil.getInstance().hasContactName(this.contacts)) {
      let medium: SelectedItemType = new SelectedItemType()
      medium.key = CONTACT_NAME
      medium.value =  copyContactsFirstItem?.contactName || ''
      medium.isSelect = copyContactsFirstItem?.select || false
      // medium.originContact = copyContactsFirstItem
      selectedItemOfSingleContactVCard.push(medium);
    }

    if (this.contacts[0].org?.length) {
      this.convertStrContactInfoToSelectedItem(
        this.contacts[0].org,
        selectedItemOfSingleContactVCard,
        ORG,
      )
    }
    if (this.contacts[0].title?.length) {
      this.convertStrContactInfoToSelectedItem(
        this.contacts[0].title,
        selectedItemOfSingleContactVCard,
        TITLE,
      )
    }

    if (this.contacts.length === 1 && this.contacts[0]?.telephone) {
      let medium: SelectedItemType = new SelectedItemType()
      medium.key = TELEPHONE
      medium.value =  this.contacts[0]?.telephone || ''
      medium.displayValue = this.contacts[0]?.telephoneFormat || ''
      medium.isSelect = this.contacts[0]?.select || false
      // medium.originContact =this.contacts[0]
      selectedItemOfSingleContactVCard.push(medium);
    } else if (this.contacts.length > 1) {
      const tempList: SelectedItemType[] = this.contacts.map(v => {

          let  tempItem: SelectedItemType =new SelectedItemType()
        tempItem.key=TELEPHONE
          tempItem.value= v?.telephone || ''
          tempItem. displayValue= v?.telephoneFormat || ''
          tempItem.isSelect=v?.select || false
          tempItem.originContact= v as ESObject

        return tempItem;
      });
      selectedItemOfSingleContactVCard.push(...tempList);
    }

    if (this.contacts[0].email?.length) {
      this.convertArrContactInfoToSelectedItem(
        this.contacts[0].email,
        selectedItemOfSingleContactVCard,
        EMAIL,
        'email',
        'labelName',
      )
    }

    if (this.contacts[0].website?.length) {
      this.convertArrContactInfoToSelectedItem(
        this.contacts[0].website,
        selectedItemOfSingleContactVCard,
        WEBSITE,
      )
    }

    if (this.contacts[0].address?.length) {
      this.convertArrContactInfoToSelectedItem(
        this.contacts[0].address,
        selectedItemOfSingleContactVCard,
        ADDRESS,
        'address',
        'labelName',
      )
    }

    if (this.contacts[0].bday?.length) {
      this.convertStrContactInfoToSelectedItem(
        this.contacts[0].bday,
        selectedItemOfSingleContactVCard,
        BDAY,
      )
    }

    if (this.contacts[0].nickName?.length) {
      this.convertStrContactInfoToSelectedItem(
        this.contacts[0].nickName,
        selectedItemOfSingleContactVCard,
        NICKNAME,
      )
    }

    if (this.contacts[0].note?.length) {
      this.convertStrContactInfoToSelectedItem(
        this.contacts[0].note,
        selectedItemOfSingleContactVCard,
        NOTE,
      )
    }
  }

  private getSelectedItemOfSingleContactVCard() {
    if (!this.contacts || this.contacts.length === 0) {
      this.setSelectedItemOfSingleContactVCard([]);
      return;
    }
    let selectedItemOfSingleContactVCard: SelectedItemType[] = [];
    let copyContactsFirstItem: ContactType =
      this.contacts?.[0] ? JSON.parse(JSON.stringify(this.contacts[0])) : {};
    copyContactsFirstItem.telephone = '';
    copyContactsFirstItem.telephoneFormat = '';

    this.convertContactInfoToSelectedItem(copyContactsFirstItem, selectedItemOfSingleContactVCard)

    this.setSelectedItemOfSingleContactVCard(selectedItemOfSingleContactVCard.filter((v, i, arr) => {
      if (v.key === CONTACT_NAME) {
        return true;
      } else {
        return arr.findIndex(item => (item.value === v.value) && (item.key === v.key)) === i;
      }
    }));
  }

  @Builder
  singleContactPhones($$: ParamOfContactTypeForUIAndIndex) {
    Column() {
      Row() {
        Column() {
          Text(CONTROL_CODE_START + $$.item.telephoneFormat + CONTROL_CODE_END)
            .textAlign(TextAlign.Start)
            .fontFamily('HarmonyHeiTi')
            .fontSize($r('sys.float.Body_L'))
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Medium)
            .lineHeight(21)
            .margin({ left: 24, right: 24 })
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .maxLines(1)
            .maxFontScale(2)
            .id(`text_contact_phone`)
          Text(this.getMobileType( $$.item.telephoneType))
            .textAlign(TextAlign.Start)
            .fontFamily('HarmonyHeiTi')
            .fontSize($r('sys.float.Body_M'))
            .fontColor($r('sys.color.font_secondary'))
            .fontWeight(FontWeight.Regular)
            .maxFontScale(2)
            .lineHeight(19)
            .margin({ left: 24, right: 24 })
        }
        .constraintSize({ minHeight: 64 })
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.Center)
        .stateStyles({
          pressed: this.pressedStyles,
          normal: {
            .backgroundColor(Color.Transparent)
          }
        })
      }
      .width('100%')
    }
    .visibility(this.contacts[0]?.telephone ? Visibility.Visible : Visibility.None)
    .width('100%')
  }

  getMobileType(type: string | undefined) {
    if (type === common.PHONE_NUMBER_TYPE.CELL) {
      return $r('app.string.vcard_mobile')
    } else if (type ===  common.PHONE_NUMBER_TYPE.WORK || type === common.PHONE_NUMBER_TYPE.WORK_FAX) {
      return $r('app.string.vcard_worktel')
    } else if (type ===  common.PHONE_NUMBER_TYPE.HOME || type === common.PHONE_NUMBER_TYPE.HOME_FAX) {
      return $r('app.string.vcard_hometel')
    } else {
      return $r('app.string.vcard_othertel')
    }
  }

  getFieldName(key: string, type?: string) {
    if (key === EMAIL && type ===  ContactInfo.ContactCommonType.WORK) {
      return $r('app.string.vcard_workemail')
    } else if (key === EMAIL && type ===  ContactInfo.ContactCommonType.HOME) {
      return $r('app.string.vcard_personalemail')
    } else if (key === EMAIL) {
      return $r('app.string.vcard_othermail')
    } else if (key === ADDRESS && type === ContactInfo.ContactCommonType.WORK) {
      return $r('app.string.vcard_workaddress')
    } else if (key === ADDRESS && type ===  ContactInfo.ContactCommonType.HOME) {
      return $r('app.string.vcard_homeaddress')
    } else if (key === ADDRESS) {
      return $r('app.string.vcard_otheraddress')
    } else if (key === WEBSITE) {
      return $r('app.string.websiteLabelsGroup')
    } else if (key === ORG) {
      return $r('app.string.vcard_organisation')
    } else if (key === TITLE) {
      return $r('app.string.vcard_title')
    } else if (key === NICKNAME) {
      return $r('app.string.vcard_nickname')
    } else if (key === BDAY) {
      return $r('app.string.vcard_birthday')
    } else if (key === NOTE) {
      return $r('app.string.label_notes')
    } else {
      return ''
    }
  }

  @Builder
  singleContactPhonesOfReceive($$: ParamOfSelectedItemTypeAndIndex) {
    Column() {
      Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
        Column() {
          Text(CONTROL_CODE_START + ($$?.item?.displayValue || ' ') + CONTROL_CODE_END)
            .textAlign(TextAlign.Start)
            .fontFamily('HarmonyHeiTi')
            .fontSize($r('sys.float.Body_L'))
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Medium)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .constraintSize({ maxWidth: 'calc(100% - 32vp)' })
            .maxLines(1)
            .maxFontScale(2)
            .id(`text_contact_phone`)
          Text(this.getMobileType($$?.item?.originContact?.telephoneType))
            .textAlign(TextAlign.Start)
            .fontFamily('HarmonyHeiTi')
            .fontSize($r('sys.float.Body_M'))
            .fontColor($r('sys.color.font_secondary'))
            .fontWeight(FontWeight.Regular)
            .maxFontScale(2)
        }
        .constraintSize({ minHeight: 64 })
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.Center);

        Checkbox({ group: 'checkboxGroup' })
          .select(this.selectedItemOfSingleContactVCard[$$.index].isSelect)
          .onChange((value: boolean) => {
            this.selectedItemOfSingleContactVCard[$$.index].isSelect = value;
            this.setSelectedItemOfSingleContactVCard([...this.selectedItemOfSingleContactVCard]);
          })
          .width(20).height(20).margin(2)
          .shape(CheckBoxShape.CIRCLE);
      }
      .stateStyles({
        pressed: this.pressedStyles,
        normal: {
          .backgroundColor(Color.Transparent)
        }
      })
      .width('100%')
      .padding({ right: 24, left: 24 });
    }
    .visibility(this.contacts[0]?.telephone ? Visibility.Visible : Visibility.None)
    .width('100%')
  }

  @Builder
  singleContactName() {
    Column() {
      Row() {
        Column() {
          Text(this.contacts[0]?.contactName)
            .textAlign(TextAlign.Start)
            .fontFamily('HarmonyHeiTi')
            .fontSize($r('sys.float.Body_L'))
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Medium)
            .lineHeight(21)
            .margin({ left: 24, right: 24 })
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .maxLines(1)
            .maxFontScale(2)
            .id(`text_contact_phone`);
          Text($r('app.string.vcard_name'))
            .textAlign(TextAlign.Start)
            .fontFamily('HarmonyHeiTi')
            .fontSize($r('sys.float.Body_M'))
            .fontColor($r('sys.color.font_secondary'))
            .fontWeight(FontWeight.Regular)
            .maxFontScale(2)
            .lineHeight(19)
            .margin({ left: 24, right: 24 })
        }
        .constraintSize({ minHeight: 64 })
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.Center)
        .visibility(!VCardUtil.getInstance().hasContactName(this.contacts) ? Visibility.None : Visibility.Visible)
        .stateStyles({
          pressed: this.pressedStyles,
          normal: {
            .backgroundColor(Color.Transparent)
          }
        })
      }
      .width('100%');
    }
    .width('100%')
  }

  @Builder
  singleContactNameOfReceive($$: SelectedItemType) {
    Column() {
      Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
        Column() {
          Text($$.value)
            .textAlign(TextAlign.Start)
            .fontFamily('HarmonyHeiTi')
            .fontSize($r('sys.float.Body_L'))
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Medium)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .constraintSize({ maxWidth: 'calc(100% - 32vp)' })
            .maxLines(1)
            .maxFontScale(2)
            .id(`text_contact_phone`);
          Text($r('app.string.vcard_name'))
            .textAlign(TextAlign.Start)
            .fontFamily('HarmonyHeiTi')
            .fontSize($r('sys.float.Body_M'))
            .fontColor($r('sys.color.font_secondary'))
            .fontWeight(FontWeight.Regular)
            .maxFontScale(2)
        }
        .constraintSize({ minHeight: 64 })
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.Center);

        Checkbox({ group: 'checkboxGroup' })
          .select(this.selectedItemOfSingleContactVCard[0].isSelect)
          .onChange((value: boolean) => {
            this.selectedItemOfSingleContactVCard[0].isSelect = value;
            this.setSelectedItemOfSingleContactVCard([...this.selectedItemOfSingleContactVCard]);
          })
          .width(20)
          .height(20)
          .margin(2)
          .shape(CheckBoxShape.CIRCLE);
      }
      .padding({ right: 24, left: 24 })
      .width('100%')
      .visibility(!VCardUtil.getInstance().hasContactName(this.contacts) ? Visibility.None : Visibility.Visible)
      .stateStyles({
        pressed: this.pressedStyles,
        normal: {
          .backgroundColor(Color.Transparent)
        }
      });
    }
    .width('100%')
  }

  @Builder
  renderSendSingleContactVCard() {
    ListItem() {
      this.singleContactName();
    }
    if (this.contacts[0].org && this.contacts[0].org.length > 0) {
      this.singleContactStrInfoOfSend(this.contacts[0].org || '', ORG)
    }

    if (this.contacts[0].title && this.contacts[0].title.length > 0) {
      this.singleContactStrInfoOfSend(this.contacts[0].title || '', TITLE)
    }

    ForEach(this.contacts, (item: ContactTypeForUI, index: number) => {
      ListItem() {
        this.singleContactPhones({ item: item, index: index });
      };
    }, (item: ContactTypeForUI) => item.telephone)

    ForEach(this.contacts[0].email, (item: ContactInfo.Email) => {
      ListItem() {
        this.singleContactArrInfoOfSend(item, EMAIL, 'email');
      };
    })

    if (this.contacts[0].nickName && this.contacts[0].nickName.length > 0) {
      this.singleContactStrInfoOfSend(this.contacts[0].nickName || '', NICKNAME)
    }

    ForEach(this.contacts[0].website, (item: string) => {
      ListItem() {
        this.singleContactArrInfoOfSend(item, WEBSITE);
      };
    })

    ForEach(this.contacts[0].address, (item: ContactInfo.Address) => {
      ListItem() {
        this.singleContactArrInfoOfSend(item, ADDRESS, 'address');
      };
    })

    if (this.contacts[0].bday && this.contacts[0].bday.length > 0) {
      this.singleContactStrInfoOfSend(this.contacts[0].bday || '', BDAY)
    }

    if (this.contacts[0].note && this.contacts[0].note.length > 0) {
      this.singleContactStrInfoOfSend(this.contacts[0].note || '', NOTE)
    }
  }

  @Builder
  singleContactStrInfoOfSend(content: string, key: string) {
    Column() {
      Row() {
        Column() {
          Text(content)
            .textAlign(TextAlign.Start)
            .fontFamily('HarmonyHeiTi')
            .fontSize($r('sys.float.Body_L'))
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Medium)
            .lineHeight(21)
            .margin({ left: 24, right: 24 })
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .maxLines(1)
            .maxFontScale(2)
            .id(`text_contact_phone`);
          Text(this.getFieldName(key))
            .textAlign(TextAlign.Start)
            .fontFamily('HarmonyHeiTi')
            .fontSize($r('sys.float.Body_M'))
            .fontColor($r('sys.color.font_secondary'))
            .fontWeight(FontWeight.Regular)
            .maxFontScale(2)
            .lineHeight(19)
            .margin({ left: 24, right: 24 })
        }
        .constraintSize({ minHeight: 64 })
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.Center)
        .stateStyles({
          pressed: this.pressedStyles,
          normal: {
            .backgroundColor(Color.Transparent)
          }
        })
      }
      .width('100%');
    }
    .width('100%')
  }

  @Builder
  singleContactArrInfoOfSend(item: LooseObject|string, key: string, valueKey?: string) {
    Column() {
      Row() {
        Column() {
          Text(isObjectType(item) && valueKey ? (item[valueKey] || '') : (item || ''))
            .textAlign(TextAlign.Start)
            .fontFamily('HarmonyHeiTi')
            .fontSize($r('sys.float.Body_L'))
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Medium)
            .lineHeight(21)
            .margin({ left: 24, right: 24 })
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .maxLines(1)
            .maxFontScale(2)
            .id(`text_contact_phone`);
          Text(this.getFieldName(key, isObjectType(item) ? ((item as LooseObject).labelName) : ""))
            .textAlign(TextAlign.Start)
            .fontFamily('HarmonyHeiTi')
            .fontSize($r('sys.float.Body_M'))
            .fontColor($r('sys.color.font_secondary'))
            .fontWeight(FontWeight.Regular)
            .maxFontScale(2)
            .lineHeight(19)
            .margin({ left: 24, right: 24 })
        }
        .constraintSize({ minHeight: 64 })
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.Center)
        .stateStyles({
          pressed: this.pressedStyles,
          normal: {
            .backgroundColor(Color.Transparent)
          }
        })
      }
      .width('100%');
    }
    .width('100%')
  }

  @Builder
  renderReceiveSingleContactVCard() {
    ListItem() {
      this.singleContactNameOfReceive(this.selectedItemOfSingleContactVCard[0]);
    }

    ForEach(this.selectedItemOfSingleContactVCard,
      (item: SelectedItemType, index: number) => {
        if (item.key === TELEPHONE) {
          ListItem() {
            this.singleContactPhonesOfReceive({
              item: this.selectedItemOfSingleContactVCard[index],
              index: index
            });
          };
        } else if ([EMAIL, ADDRESS, WEBSITE].includes(item.key)) {
          ListItem() {
            this.singleContactArrInfoOfReceive({
              item: this.selectedItemOfSingleContactVCard[index],
              index: index
            });
          };
        } else if ([ORG, TITLE, NICKNAME, NOTE, BDAY].includes(item.key)) {
          ListItem() {
            this.singleContactStrInfoOfReceive({
              item: this.selectedItemOfSingleContactVCard[index],
              index: index
            });
          };
        }
      }, (item: ContactTypeForUI) => (JSON.stringify(item.telephone)))
  }

  getContactInfoLabel($$: SelectedItemType) {
    if ($$.key === ORG) {
      return $r('app.string.vcard_organisation')
    } else if ($$.key === TITLE) {
      return $r('app.string.vcard_title')
    } else if ($$.key === NICKNAME) {
      return $r('app.string.vcard_nickname')
    } else if ($$.key === BDAY) {
      return $r('app.string.vcard_birthday')
    } else if ($$.key === NOTE) {
      return $r('app.string.label_notes')
    } else {
      return ''
    }
  }

  @Builder
  singleContactArrInfoOfReceive($$: ParamOfSelectedItemTypeAndIndex) {
    Column() {
      Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
        Column() {
          Text($$?.item?.value || '')
            .textAlign(TextAlign.Start)
            .fontFamily('HarmonyHeiTi')
            .fontSize($r('sys.float.Body_L'))
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Medium)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .constraintSize({ maxWidth: 'calc(100% - 32vp)' })
            .maxLines(1)
            .maxFontScale(2)
            .id(`text_contact_phone`)
          Text(this.getFieldName($$?.item.key, $$?.item?.type))
            .textAlign(TextAlign.Start)
            .fontFamily('HarmonyHeiTi')
            .fontSize($r('sys.float.Body_M'))
            .fontColor($r('sys.color.font_secondary'))
            .fontWeight(FontWeight.Regular)
            .maxFontScale(2)
        }
        .constraintSize({ minHeight: 64 })
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.Center);

        Checkbox({ group: 'checkboxGroup' })
          .select(this.selectedItemOfSingleContactVCard[$$.index].isSelect)
          .onChange((value: boolean) => {
            this.selectedItemOfSingleContactVCard[$$.index].isSelect = value;
            this.setSelectedItemOfSingleContactVCard([...this.selectedItemOfSingleContactVCard]);
          })
          .width(20).height(20).margin(2)
          .shape(CheckBoxShape.CIRCLE);
      }
      .stateStyles({
        pressed: this.pressedStyles,
        normal: {
          .backgroundColor(Color.Transparent)
        }
      })
      .width('100%')
      .padding({ right: 24, left: 24 });
    }
    .visibility(this.contacts[0]?.telephone ? Visibility.Visible : Visibility.None)
    .width('100%')
  }

  @Builder
  singleContactStrInfoOfReceive($$: ParamOfSelectedItemTypeAndIndex) {
    Column() {
      Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
        Column() {
          Text($$.item.value)
            .textAlign(TextAlign.Start)
            .fontFamily('HarmonyHeiTi')
            .fontSize($r('sys.float.Body_L'))
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Medium)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .constraintSize({ maxWidth: 'calc(100% - 32vp)' })
            .maxLines(1)
            .maxFontScale(2)
            .id(`text_contact_phone`);
          Text(this.getContactInfoLabel($$.item))
            .textAlign(TextAlign.Start)
            .fontFamily('HarmonyHeiTi')
            .fontSize($r('sys.float.Body_M'))
            .fontColor($r('sys.color.font_secondary'))
            .fontWeight(FontWeight.Regular)
            .maxFontScale(2)
        }
        .constraintSize({ minHeight: 64 })
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.Center);

        Checkbox({ group: 'checkboxGroup' })
          .select(this.selectedItemOfSingleContactVCard[$$.index].isSelect)
          .onChange((value: boolean) => {
            this.selectedItemOfSingleContactVCard[$$.index].isSelect = value;
            this.setSelectedItemOfSingleContactVCard([...this.selectedItemOfSingleContactVCard]);
          })
          .width(20)
          .height(20)
          .margin(2)
          .shape(CheckBoxShape.CIRCLE);
      }
      .padding({ right: 24, left: 24 })
      .width('100%')
      .stateStyles({
        pressed: this.pressedStyles,
        normal: {
          .backgroundColor(Color.Transparent)
        }
      });
    }
    .width('100%')
  }

  build() {
    Column() {
      List() {
        if (this.isReceiveMessage && this.selectedItemOfSingleContactVCard?.[0]) {
          this.renderReceiveSingleContactVCard();
        } else {
          this.renderSendSingleContactVCard();
        }
      }
      .divider({
        strokeWidth: px2vp(1),
        color: $r('sys.color.ohos_id_color_list_separator'),
        startMargin: 24,
        endMargin: 24,
      })
      .width('100%')
      .constraintSize({ maxHeight: 300 })
    }
    .width('100%')
    .padding({
      left: 0,
      right: 0,
      bottom: 0
    })
  }
}

@Component
struct onlyShowContactName {
  @Styles
  pressedStyles() {
    .backgroundColor($r('sys.color.ohos_id_color_click_effect'))
    .borderRadius($r('sys.float.corner_radius_level8'))
    .opacity(1)
  }

  isAppearMultipleTimes: boolean = false;
  @Prop contacts: ContactTypeForUI[] = [];

  aboutToAppear(): void {

  }

  build() {
    Column() {
      List() {
        ForEach(this.contacts, (item: ContactTypeForUI, index: number) => {
          ListItem() {
            Column() {
                Text(item.contactName)
                  .textAlign(TextAlign.Start)
                  .fontFamily('HarmonyHeiTi')
                  .fontSize($r('sys.float.Body_L'))
                  .fontColor($r('sys.color.font_primary'))
                  .fontWeight(FontWeight.Medium)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .maxLines(1)
                  .lineHeight(21)
                  .id(`text_contact_name_${index}`)
                  .maxFontScale(2)
                  .constraintSize({ minHeight: 48 })
                  .padding({ left: 24, right: 24 })

              Divider()
                .vertical(false)
                .color($r('sys.color.ohos_id_color_list_separator'))
                .margin({ right: 24, left: 24 })
                .visibility(this.contacts.length - 1 === index ? Visibility.None : Visibility.Visible)
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
            .justifyContent(FlexAlign.Center)
            .stateStyles({
              pressed: this.pressedStyles,
              normal: {
                .backgroundColor(Color.Transparent)
              }
            })
          }
        }, (item: ContactTypeForUI) => item.telephone)
      }
      .width('100%')
      .constraintSize({ maxHeight: 200 })
    }
    .width('100%')
  }
}

/**
 * Dialog for save vcard.
 */

@CustomDialog
export struct MMSaveVcardDialog {
  controller?: CustomDialogController;
  path: string = '';
  private context = getContext(this) as myCommon.UIAbilityContext;
  @State contacts: ContactType[] = []
  @State isSingleContactOrMultipleTel: boolean = false;
  singleContacts: ContactType[] = []
  multipleTelContactsAfter: ContactType[] = []
  @State isOkButtonEnabled: boolean = true;
  confirmed: (savedFileInfo: SavedFileInfo) => void = () => {
  }
  cancel: () => void = () => {
    this.controller?.close();
  }

  @Styles
  pressedStyles() {
    .backgroundColor($r('sys.color.ohos_id_color_click_effect'))
    .opacity(1)
  }

  @State selectedItemOfSingleContactVCard: SelectedItemType[] = [];

  async aboutToAppear() {
    // get contacts from the vCard
    let contacts = await VCardUtil.getInstance().parseVCard(this.context, this.path, 0);
    this.contacts = [...contacts];
    //  is every item's name same
    this.isSingleContactOrMultipleTel = contacts.every(contact => {
      return contact.contactName === contacts[0].contactName && contact.id === this.contacts[0].id;
    })
    HiLog.i(TAG, `aboutToAppear_isSingleContactOrMultipleTel:${this.isSingleContactOrMultipleTel}`);
    this.handleContacts();
  }

  /**
   * handle contacts arr.
   *
   * @param arr
   * @returns
   */
  initData(arr: ContactTypeForUI[]): ContactTypeForUI[] {
    let noTel: ContactTypeForUI = JSON.parse(JSON.stringify(arr[0]))
    let noName: ContactTypeForUI = JSON.parse(JSON.stringify(arr[0]))
    noName.contactName = '';
    let newContacts = arr.map(contact => {
      contact.contactName = '';
      return contact
    })
    return arr.length > 1 ? [noTel, ...newContacts] : (noTel.contactName === noName.telephone ? [noName] : [noTel])
  }

  handleContacts() {
    if (this.isSingleContactOrMultipleTel) {
      this.contacts = this.initData(this.contacts)
    } else {
      let nameArr: string[] = [];
      let newContacts: ContactTypeForUI[] = []
      for (let index = 0; index < this.contacts.length; index++) {
        if (!nameArr.includes(this.contacts[index].contactName) ||
            this.contacts[index].id && this.contacts[index].id != this.contacts[index - 1].id) {
          nameArr.push(this.contacts[index].contactName);
          // newContacts.push(this.contacts[index]!);
        }
      }
      this.contacts = [...newContacts]
    }
  }

  handleSelected() {
    this.isOkButtonEnabled = this.contacts.some(item => {
      return item.select;
    })
  }

  @Builder
  singleVcardSavePanelItem($$: ParamOfContactTypeForUIAndIndex) {
    Column() {
      Row() {
        Column() {
          Text($$.item.contactName ? $$.item.contactName : $$.item.telephoneFormat)
            .textAlign(TextAlign.Start)
            .fontSize($r('sys.float.ohos_id_text_size_sub_title2'))
            .fontColor($r('sys.color.ohos_id_color_text_primary'))
            .fontWeight(FontWeight.Medium)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .maxLines(1)
            .constraintSize({ maxWidth: 'calc(100% - 32vp)' })
          Text($$.item.contactName ? $r('app.string.vcard_name') : $r('app.string.vcard_mobile'))
            .textAlign(TextAlign.Start)
            .fontSize($r('sys.float.ohos_id_text_size_sub_title3'))
            .fontColor($r('sys.color.ohos_id_color_text_secondary'))
            .fontWeight(FontWeight.Regular).margin({ top: 2 })
        }
        .id('contact_name')
        .justifyContent(FlexAlign.Start).alignItems(HorizontalAlign.Start).width('70%');

        Checkbox({ group: 'checkboxGroup' })
          .select($$.item.select)
          .onChange((value: boolean) => {
            $$.item.select = value;
            this.handleSelected()
          }).width(20).height(20).margin(2).shape(CheckBoxShape.ROUNDED_SQUARE)
      }
      .width('100%')
      .height(64)
      .padding({ right: 24, left: 24 })
      .justifyContent(FlexAlign.SpaceBetween)
      .stateStyles({
        pressed: this.pressedStyles,
        normal: {
          .backgroundColor(Color.Transparent)
        }
      })
      .onClick(() => {
        $$.item.select = !$$.item.select;
      })
      Divider()
        .vertical(false)
        .color($r('sys.color.ohos_id_color_list_separator'))
        .margin({ right: 24, left: 24 })
        .visibility(this.contacts.length - 1 === $$.index ? Visibility.None : Visibility.Visible)
    }
    .width('100%')
  }

  @Builder
  singleVcardSavePanel() {
    Column() {
      List() {
        ForEach(this.contacts, (item: ContactTypeForUI, index: number) => {
          ListItem() {
            this.singleVcardSavePanelItem({ item: item, index: index })
          }
        }, (item: ContactTypeForUI) => item.telephone)
      }
      .width('100%')
      .constraintSize({ maxHeight: 200 })
    }
    .width('100%')
    .padding({
      left: 0,
      right: 0,
      bottom: 16
    })
  }

  onSaveButtonClick = async () => {
    if (!this.isOkButtonEnabled) {
      return
    }
    let origins = await VCardUtil.getInstance().parseVCard(this.context, this.path, SAVE_VCARD);
    if (!this.isSingleContactOrMultipleTel) {
      this.contacts.map(contact => {
        origins.map(origin => {
          if (origin.contactName === contact.contactName) {
            origin.select = contact.select
          }
        })
      })
      this.contacts = [...origins]
      let vcfFileInfo: SavedFileInfo = VCardParser.getInstance().generateVcfForMultipleContacts(
        this.context,
        this.path,
        this.contacts
      )
      this.confirmed(vcfFileInfo)
    } else {
      let vcfFileInfo: SavedFileInfo = VCardParser.getInstance().generateVcfForSingleContact(
        this.context,
        this.path,
        this.selectedItemOfSingleContactVCard
      )
      this.confirmed(vcfFileInfo)
    }
  }

  @Builder
  multiplesVcardSavePanelItem($$: ParamOfContactTypeForUIAndIndex) {
    Column() {
      Row() {
        Text($$.item.contactName)
          .textAlign(TextAlign.Start)
          .fontFamily('HarmonyHeiTi')
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Medium)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .constraintSize({ maxWidth: 'calc(100% - 32vp)' })
          .maxLines(1)
          .maxFontScale(2)
        Checkbox({ group: 'checkboxGroup' })
          .select($$.item.select)
          .onChange((value: boolean) => {
            $$.item.select = value;
            this.handleSelected()
          })
          .width(20)
          .height(20)
          .margin(2)
          .shape(CheckBoxShape.CIRCLE)
      }
      .id(`contact_name_${$$.index}`)
      .width('100%')
      .constraintSize({ minHeight: 48 })
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({ left: 24, right: 24 })
      .stateStyles({
        pressed: this.pressedStyles,
        normal: {
          .backgroundColor(Color.Transparent)
        }
      })
      .onClick(() => {
        $$.item.select = !$$.item.select;
      })

      Divider()
        .vertical(false)
        .color($r('sys.color.ohos_id_color_list_separator'))
        .margin({ right: 24, left: 24 })
        .visibility(this.contacts.length - 1 === $$.index ? Visibility.None : Visibility.Visible)
    }
    .width('100%')
  }

  @Builder
  multiplesVcardSavePanel() {
    Column() {
      List() {
        ForEach(this.contacts, (item: ContactTypeForUI, index: number) => {
          ListItem() {
           this.multiplesVcardSavePanelItem({item: item, index: index});
          }
        }, (item: ContactTypeForUI) => item.telephoneFormat)
      }
      .width('100%')
      .constraintSize({ maxHeight: 200 })
    }
    .width('100%')
  }

  private setSelectedItemOfSingleContactVCard(v: SelectedItemType[]) {
    this.selectedItemOfSingleContactVCard = v;
    if (this.selectedItemOfSingleContactVCard &&
    this.selectedItemOfSingleContactVCard.some(v => (v && v.isSelect === true))) {
      this.isOkButtonEnabled = true;
    } else {
      this.isOkButtonEnabled = false;
    }
  }

  build() {
    Column() {
      Text($r('app.string.save_to_contacts'))
        .width('calc(100% - 48vp)')
        .textAlign(TextAlign.Center)
        .fontSize($r('sys.float.Title_S'))
        .fontColor($r('sys.color.ohos_id_color_text_primary'))
        .lineHeight(26)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 15, left: 24, right: 24, bottom: 15 })
        .id('save_vcard_title')
        .maxFontScale(2)
      if (this.isSingleContactOrMultipleTel) {
        contactsNameAndTel({
          contacts: this.contacts,
          isReceiveMessage: true,
          selectedItemOfSingleContactVCard: this.selectedItemOfSingleContactVCard,
          setSelectedItemOfSingleContactVCard: (v: SelectedItemType[]) => {
            this.setSelectedItemOfSingleContactVCard(v);
          }
        });
      } else {
        this.multiplesVcardSavePanel();
      }
      Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
        Button() {
          Text($r('app.string.cancel'))
            .textAlign(TextAlign.Start).fontSize($r('sys.float.Body_L'))
            .fontColor($r('sys.color.ohos_id_color_text_primary_activated'))
            .fontWeight(FontWeight.Medium).fontFamily('HarmonyHeiTi').constraintSize({ minHeight: 40 })
            .maxFontScale(2)
        }
        .id('button_cancel').backgroundColor($r('sys.color.ohos_id_color_background_transparent'))
        .layoutWeight(1)
        .onClick(() => {
          this.cancel()
        })

        Divider().vertical(true).color($r('sys.color.ohos_id_color_list_separator'))
          .margin({ right: 8, left: 8 }).height(24);

        Button() {
          Text($r('app.string.save'))
            .textAlign(TextAlign.Start)
            .fontSize($r('sys.float.Body_L'))
            .fontColor($r('sys.color.ohos_id_color_text_primary_activated'))
            .fontWeight(FontWeight.Medium)
            .fontFamily('HarmonyHeiTi')
            .constraintSize({ minHeight: 40 })
            .maxFontScale(2)
            .opacity(this.isOkButtonEnabled ? 1 : 0.4)
            .enabled(this.isOkButtonEnabled ? true : false)
        }
        .id('button_confirm')
        .backgroundColor($r('sys.color.ohos_id_color_background_transparent'))
        .layoutWeight(1)
        .onClick(this.onSaveButtonClick)
      }
      .width('100%')
      .padding({ top: 8, bottom: 16, left: 16, right: 16 })
    }
  }
}

/**
 * Dialog for import vcard.
 */
@CustomDialog
export struct MMAskIsImportDialog {
  controller?: CustomDialogController;
  confirmed: () => void = () => {
  }

  build() {
    Column() {
      Text($r('app.string.msg_import_contacts_from_vCard'))
        .textAlign(TextAlign.Center)
        .fontSize($r('sys.float.Title_S'))
        .fontColor($r('sys.color.ohos_id_color_text_primary'))
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .constraintSize({ minHeight: 26 })
        .maxFontScale(2)
        .id('text_confirm_import')
        .padding({ top: 15, left: 24, right: 24, bottom: 15 })
      Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
        Button() {
          Text($r('app.string.cancel'))
            .textAlign(TextAlign.Start)
            .fontSize($r('sys.float.Body_L'))
            .fontColor($r('sys.color.ohos_id_color_text_primary_activated'))
            .fontWeight(FontWeight.Medium)
            .fontFamily('HarmonyHeiTi')
            .constraintSize({ minHeight: 40 })
            .maxFontScale(2)
        }
        .id('button_cancel')
        .backgroundColor($r('sys.color.ohos_id_color_background_transparent'))
        .layoutWeight(1)
        .onClick(() => {
          this.controller?.close();
        })

        Divider()
          .vertical(true)
          .color($r('sys.color.ohos_id_color_list_separator'))
          .height(24)
        Button() {
          Text($r('app.string.ok'))
            .textAlign(TextAlign.Start)
            .fontSize($r('sys.float.Body_L'))
            .fontColor($r('sys.color.ohos_id_color_text_primary_activated'))
            .fontWeight(FontWeight.Medium)
            .fontFamily('HarmonyHeiTi')
            .constraintSize({ minHeight: 40 })
            .maxFontScale(2)
        }
        .id('button_save')
        .backgroundColor($r('sys.color.ohos_id_color_background_transparent'))
        .layoutWeight(1)
        .onClick(() => {
          this.confirmed()
        })
      }
      .margin({ top: 8, bottom: 16 })
      .height(40)
    }.width('100%')
  }
}

/**
 * Item type for contact dialog
 */
export class ContactTypeForUI {
  public contactName: string = '';
  public telephone: string = '';
  public telephoneFormat: string = '';
  public headImage: string = '';
  public select: boolean = false;
  public rawContactId?: string;
  public id?: number;
  public telephoneType?: string;
}