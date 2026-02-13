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

import vcard from '@ohos.telephony.vcard';
import type common from '@ohos.app.ability.common';
import fs from '@ohos.file.fs';
import HiLog from './HiLog';
import FileUtil, { SavedFileInfo, SaveTextType } from './FileUtil';
import { ContactType } from './TypesUtils';
import TelephoneUtil from './TelephoneUtil';
import { ContactTypeForUI } from '../views/AttachmentArea/MMMoreDialog';
import { VCardParser } from './VCardParser';
import StringUtil from '../utils/StringUtil';
import LooseObject from '../data/LooseObject';
import MmsUtil from '../utils/MmsUtil';
import { BusinessError } from '@kit.BasicServicesKit';

const TAG = 'VCardUtil';

export class VCardUtil {
  private static mInstance: VCardUtil;

  public static getInstance() {
    if (!VCardUtil.mInstance) {
      VCardUtil.mInstance = new VCardUtil()
    }
    return VCardUtil.mInstance
  }
  /**
   * Import vcard from msg
   *
   * @param context
   * @param callback
   */
  public importVCard(context: common.UIAbilityContext, filePath: string, callback: Function): void {
    vcard.importVCard(context, filePath).then(() => {
      HiLog.i(TAG, 'VCardUtil#importVCard success.');
      callback(true);
    }).catch((error: BusinessError) => {
      HiLog.i(TAG, 'VCardUtil#importVCard failed: ' + JSON.stringify(error));
      callback(false);
    }).finally(() => {
      // 导入之后删除临时文件
      FileUtil.deleteFile(context, FileUtil.getFileName(filePath));
    });
  }

  // 判断是否是附件区的联系人ux 显示一行的场景：多个联系人、单个联系人只有号码、单个联系人只有名字。
  public isMulContactShow(contacts: ContactType[]) {
    let isMulContactShow = false
    const isSingleContactOrMultipleTel = this.isSingleContactOrMultipleTel(contacts)
    if (isSingleContactOrMultipleTel) {
      const hasContactName = this.hasContactName(contacts)
      const hasTelephone = contacts[0]?.telephoneFormat
      isMulContactShow = !hasContactName || !hasTelephone
    } else {
      isMulContactShow = true
    }
    return isMulContactShow
  }

  // 判断附件区所选择联系人中，单个联系人是否有名字
  public hasContactName(contacts: ContactType[]) {
    if (!contacts || contacts.length === 0) {
        return
    }
    let hasContactName = !StringUtil.isEmpty(contacts[0]?.contactName)
    const contactName = contacts[0]?.contactName
    const id = contacts[0]?.id
    contacts.forEach((item) => {
      if (item.id === id && item.telephone === contactName) {
        hasContactName = false
      }
    })
    return hasContactName
  }

  // 判断附件区所选择联系人中，是否是单个联系人或多个电话号码
  public isSingleContactOrMultipleTel(contacts: ContactType[]) {
    return contacts.every(contact => {
      return contact.contactName === contacts[0].contactName && contact.id === contacts[0].id;
    })
  }

  // 获得附件区所选择联系人的名字
  public getContactName(contacts: ContactType[]) {
    if (!contacts || contacts.length === 0) {
      return
    }
    const names: string[] = []
    contacts.forEach((contact: ContactType, index) => {
      if (index === 0 || contact.id !== contacts[index - 1]?.id) {
        contact.contactName ? names.push(contact.contactName) : names.push(contact.telephoneFormat)
      }
    })
    return names
  }

  /**
   * Generating a VCF File
   *
   * @param vcfItems
   * @returns
   */
  public generateVcf(context: Context, vcfItems: VcfItem[]): SavedFileInfo {
    let vcfItemStrings: string[] = [];
    for (let i = 0; i < vcfItems.length; i++) {
      let item: VcfItem = vcfItems[i];
      let nameDecodeStr: string = encodeURI(item.name).replace(new RegExp('%', 'g'), '=');
      let tempList = [
        'BEGIN:VCARD',
        'VERSION:2.1',
        `N;CHARSET=UTF-8;ENCODING=QUOTED-PRINTABLE:;${nameDecodeStr};;;`,
        `FN;CHARSET=UTF-8;ENCODING=QUOTED-PRINTABLE:${nameDecodeStr}`]
      let phones = item.phones.split(',');
      let telephoneTypes = item.telephoneTypes?.split(',');
      phones.forEach((phone,index) => {
        const typeStr = telephoneTypes ? telephoneTypes[index] : ''
        tempList.push(`TEL;${typeStr}:${phone}`);
      })
      if (item.photoPath) {
        tempList.push(`PATH;CHARSET=UTF-8;ENCODING=QUOTED-PRINTABLE:${item.photoPath}`);
      }
      if (item.avatarBase64Encoded) {
        tempList.push(`PHOTO;ENCODING=B;TYPE=JPEG:${item.avatarBase64Encoded}`);
      }
      tempList.push(`END:VCARD`);
      let vcfItemStr: string = tempList.join('\r\n');
      vcfItemStrings.push(vcfItemStr);
    }
    let vcfContent: string = vcfItemStrings.join('\r\n');
    let vcfFileInfo: SavedFileInfo = FileUtil.saveTextToSandBox(context, vcfContent, SaveTextType.VCF);
    return vcfFileInfo;
  }

  public async parseVCard(context: Context, path: string, status: number): Promise<ContactType[]> {
    let contacts: ContactType[] = [];
    try {
      let vcardText = fs.readTextSync(path);
      contacts = await VCardParser.getInstance().parseVcardStr(context, vcardText, status);
      HiLog.i(TAG, 'parseVcard contacts number:' + contacts.length);
    } catch (e) {
      HiLog.i(TAG, 'parseVcard err:' + e);
    }
    return contacts;
  }

  public removeSameNumbers(newTelArr: string[]): string[] {
    let telephoneArr: string[] = [];
    newTelArr.forEach(telephone => {
      if (!telephoneArr.includes(telephone)) {
        telephoneArr.push(telephone);
      }
    })
    return telephoneArr;
  }

  /**
   * handle contacts arr.
   *
   * @param arr
   * @returns
   */
  public dealSelectedContactsToVcfItems(contactArr: ContactType[], isSave: boolean) {
    contactArr = contactArr.filter(contact => {
      return contact.select;
    })
    //  is every item's name same
    let isSingleNumber = contactArr.filter(contact => {
      return contact.contactName
    }).length <= 1
    let vcfItems: VcfItem[] = [];
    let vcfItem: VcfItem = {
      name: '',
      phones: '',
      id: 0,
      avatarBase64Encoded: '',
      photoPath: '',
      telephoneTypes: ''
    }
    if (isSingleNumber) {
      if (contactArr.length >= 1 && isSave) {
        let telNumber: string = '';
        let telTypes: string = '';
        telNumber = contactArr[0].telephone;
        telTypes = contactArr[0].telephoneType || '';
        vcfItem.name = contactArr[0].contactName ? contactArr[0].contactName : vcfItem.name
        vcfItem.avatarBase64Encoded = contactArr[0].avatarBase64Encoded || '';
        vcfItem.photoPath = contactArr[0].photoPath || '';
        for (let index = 1; index < contactArr.length; index++) {
          telNumber = telNumber + ',' + contactArr[index].telephone;
          telTypes = telTypes + ',' + (contactArr[index].telephoneType || '');
        }
        vcfItem.phones = telNumber;
        vcfItem.telephoneTypes = telTypes;
      } else {
        contactArr.map(contact => {
          vcfItem.name = contact.contactName ? contact.contactName : vcfItem.name
          vcfItem.phones = contact.telephone;
          vcfItem.avatarBase64Encoded = contact.avatarBase64Encoded || '';
          vcfItem.photoPath = contact.photoPath || '';
          vcfItem.telephoneTypes = contact.telephoneType || '';
        })
      }
      vcfItems.push(vcfItem);
    } else {
      let contactData: ContactType[] = [];
      contactArr.forEach(item => {
        let arr = contactData.filter(items => {
          return item.contactName == items.contactName && item.id == items.id;
        })
        if (arr.length < 1) {
          contactData.push(item);
        }
      })
      this.multContactsToVcfItems(contactData, contactArr, vcfItems);
    }
    return vcfItems;
  }

  private multContactsToVcfItems(contactData: ContactType[], contactArr: ContactType[], vcfItems: VcfItem[]) {
    contactData.forEach(contact => {
      for (let i = 0; i < contactArr.length; i++) {
        if (contact.contactName === contactArr[i].contactName && contact.id === contactArr[i].id &&
          contact.telephone != contactArr[i].telephone) {
          contact.telephone = contact.telephone + ',' + contactArr[i].telephone;
          contact.telephoneType = (contact.telephoneType || '') + ',' + (contactArr[i].telephoneType || '');
        }
      }
      let vcfItem: VcfItem | undefined = vcfItems.find((vcfItem) => {
        return vcfItem.name == contact.contactName && vcfItem.id == contact.id;
      });
      if (vcfItem) {
        vcfItem.phones = contact.telephone;
        vcfItem.telephoneTypes = contact.telephoneType;
      } else {
        vcfItem = {
          name: contact.contactName,
          phones: contact.telephone,
          id: contact.id ?? 0,
          avatarBase64Encoded: contact.avatarBase64Encoded || '',
          photoPath: contact.photoPath || '',
          telephoneTypes: contact.telephoneType,
        };
        vcfItems.push(vcfItem);
      }
    });
  }

  static isVcard(data: LooseObject): boolean {
    if (!data.isMsm || data.mmsSource.length === 0) {
      return false;
    } else {
      return data.mmsSource.some((item: LooseObject) => MmsUtil.isVcard(item.type));
    }
  }
}

export interface VcfItem {
  name: string,
  phones: string,
  id: number,
  avatarBase64Encoded: string,
  photoPath?: string,
  telephoneTypes?: string,
}

