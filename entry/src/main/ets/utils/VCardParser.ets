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
import HiLog from './HiLog';
import { ContactType } from './TypesUtils';
import image from '@ohos.multimedia.image';
import DateUtil from './DateUtil';
import FileUtil, { SavedFileInfo, SaveTextType } from './FileUtil';
import { Base64Interface, HOSBase64 } from './HOSBase64';
import { ContactInfo } from './Contact'
import fs from '@ohos.file.fs';

export class VCardConstants {
    public static readonly VERSION_V21 = '2.1';
    public static readonly PROPERTY_FN = 'FN';
    public static readonly PROPERTY_TEL = 'TEL';
    public static readonly PROPERTY_PHOTO = 'PHOTO';
    public static readonly PROPERTY_END = 'END';
    public static readonly PARAM_TYPE = 'TYPE';
    public static readonly PARAM_PATH = 'PATH';
    public static readonly PARAM_PHOTO = 'PHOTO;';
    public static readonly PARAM_BEGIN_VCARD = 'BEGIN:VCARD';
    public static readonly PARAM_END_VCARD = 'END:VCARD';
    public static readonly PROPERTY_ADR = 'ADR';
    public static readonly PROPERTY_EMAIL = 'EMAIL';
    public static readonly PROPERTY_NICKNAME = 'NICKNAME';
    public static readonly PROPERTY_NOTE = 'NOTE';
    public static readonly PROPERTY_ORG = 'ORG';
    public static readonly PROPERTY_TITLE = 'TITLE';
    public static readonly PROPERTY_URL = 'URL';
    public static readonly PROPERTY_BDAY = 'BDAY';
}

const TAG = 'VCardParser';

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

@Observed
export class SelectedItemType {
    public key: string = ''
    public value: string = ''
    public displayValue?: string
    public isSelect: boolean = true
    public originContact?: ContactTypeForUI
    public type?: string = ''
}

export class VCardParser{
    private static sInstance: VCardParser;
    private static readonly STATE_GROUP_OR_PROPERTY_NAME: number = 0;
    private static readonly STATE_PARAMS: number = 1;
    private static readonly STATE_PARAMS_IN_DQUOTE: number = 2;

    static getInstance() {
        if (VCardParser.sInstance == null) {
            VCardParser.sInstance = new VCardParser();
        }
        return VCardParser.sInstance;
    }

    getTypeValue(typeStr: string) {
        const typeArr = typeStr.split('=')
        return typeArr[1].trim()
    }

    /**
     * Generating a VCF File of Single Contact
     *
     * @param context
     * @param path
     * @param selectedItems
     * @returns
     */
    generateVcfForSingleContact(context: Context, path: string, selectedItems: SelectedItemType[]) {
        let vcard:string = fs.readTextSync(path);
        let mergeArr: string[] = [];
        let tempList: string[] = [];
        this.parseItemInter([vcard], 0, mergeArr);
        for (let i = 0; i < mergeArr.length; i++) {
            let propertyData: VCardProperty | null = this.parseItemsByStr(mergeArr[i]);
            if (!propertyData) {
                HiLog.w(TAG, 'parseVcardStr propertyData is null');
                continue;
            }

            let isSelectedProperty = this.isSelectedProperty(propertyData, selectedItems)
            if (isSelectedProperty) {
                tempList.push(mergeArr[i])
            }
        }
        let vcfContent: string = tempList.join('\r\n');
        let vcfFileInfo: SavedFileInfo = FileUtil.saveTextToSandBox(context, vcfContent, SaveTextType.VCF);
        return vcfFileInfo;
    }

    private isSelectedProperty(
        propertyData: VCardProperty,
        selectedItems: SelectedItemType[]
    ) {
        let name: string = propertyData.getName()!.toUpperCase();

        let rawValue: string = propertyData.getRawValue()!;
        if (['ADR', 'EMAIL', 'FN', 'N', 'NICKNAME', 'NOTE', 'ORG', 'TITLE'].includes((name))) {
            rawValue = decodeURI(String(rawValue).replace(new RegExp('=', 'g'), '%'));
        }
        if (name === 'ADR') {
            rawValue = rawValue.split(';').reduce((acc,item) => acc + item,'')
        }

        let param: string = propertyData.getParamMapString();
        let propertyType: string = '';
        if (param.includes('TYPE')) {
            propertyType = this.getTypeValue(param)
        }

        if (name === 'N') {
            return false
        }

        return !(selectedItems.some(item => (
                item.key.toUpperCase() === name &&
                    item.value === rawValue &&
                    (item.type ? item.type === propertyType : true) &&
                    item.isSelect === false
            )));
    }

    /**
     * Generating a VCF File of Multiple Contacts
     *
     * @param context
     * @param path
     * @param selectedItems
     * @returns
     */
    generateVcfForMultipleContacts(context: Context, path: string, selectedItems: ContactType[]) {
        let vcard:string = fs.readTextSync(path);
        let contactsArr = vcard.split(VCardConstants.PARAM_END_VCARD);
        let tempList: string[] = [];
        for (let index = 0; index < contactsArr.length - 1; index++) {
            // 解析 vcard 时，将 index+1 存为 id ，所以用 index+1===id 判断是否是所选择的联系人
            const isSelectContact = !(selectedItems.some(item =>
                item.id === (index + 1) && item.select === false
            ))
            if (isSelectContact) {
                contactsArr[index] = contactsArr[index] + VCardConstants.PARAM_END_VCARD
                tempList.push(contactsArr[index])
            }
        }
        let vcfContent: string = tempList.join('\r\n');
        let vcfFileInfo: SavedFileInfo = FileUtil.saveTextToSandBox(context, vcfContent, SaveTextType.VCF);
        return vcfFileInfo;
    }

    // parse vcard info
    public async parseVcardStr(context: Context, vcard: string, status: number): Promise<ContactType[]> {
        HiLog .w(TAG, 'parseVcardStr enter');
        return new Promise(async (resolve) => {
            let contacts: ContactType[] = [];
            let contactsArr = vcard.split(VCardConstants.PARAM_END_VCARD);
            for (let index = 0; index < contactsArr.length - 1; index++) {
                let mergeArr: string[] = [];
                this.parseItemInter(contactsArr, index, mergeArr);
                let tempList: VCardParserResult = new VCardParserResult()
                for (let i = 0; i < mergeArr.length - 1; i++) {
                    if (mergeArr[i] === VCardConstants.PARAM_END_VCARD) {
                        break;
                    }
                    let propertyData: VCardProperty | null = this.parseItemsByStr(mergeArr[i]);
                    if (!propertyData) {
                        HiLog.w(TAG, 'parseVcardStr propertyData is null');
                        continue;
                    }

                    this.handleTempList(propertyData, tempList)

                    let propertyNameUpper: string = propertyData.getName()!.toUpperCase();
                    let propertyRawValue: string = propertyData.getRawValue()!;
                    if (propertyNameUpper === VCardConstants.PARAM_PATH && !status) {
                        tempList.photoPath = propertyRawValue;
                        continue;
                    } else if (propertyNameUpper === (VCardConstants.PROPERTY_PHOTO)) {
                        tempList.photoBase64 = propertyRawValue;
                        continue;
                    }
                }
                this.getContactsData(contacts, tempList, index, status);
            }
            resolve(contacts);
        });
    }

    handleTempList(propertyData: VCardProperty, tempList: VCardParserResult) {
        let propertyNameUpper: string = propertyData.getName()!.toUpperCase();
        let propertyRawValue: string = propertyData.getRawValue()!;
        let propertyType: string = propertyData.getType()!;
        let propertyParam: string = propertyData.getParamMapString();
        switch (propertyNameUpper) {
          case VCardConstants.PROPERTY_FN:
            tempList.name = decodeURI(String(propertyRawValue).replace(new RegExp('=', 'g'), '%'));
            break;
          case VCardConstants.PROPERTY_TEL:
            tempList.phoneNumber.push(propertyRawValue);
            tempList.phoneType?.push(propertyType)
            break;
          case VCardConstants.PROPERTY_EMAIL:
            const email = new ContactInfo.Email()
            email.email = propertyRawValue
            if (propertyParam.includes('TYPE')) {
              email.labelName = this.getTypeValue(propertyParam)
            }
            tempList.email.push(email)
            break;
          case VCardConstants.PROPERTY_ADR:
            const address = new ContactInfo.Address()
            address.address = decodeURI(String(propertyRawValue).replace(new RegExp('=', 'g'), '%'));
            address.address = address.address.split(';').reduce((acc,item) => acc + item,'')
            if (propertyParam.includes('TYPE')) {
              address.labelName = this.getTypeValue(propertyParam)
            }
            tempList.address.push(address)
            break;
          case VCardConstants.PROPERTY_URL:
            tempList.website.push(propertyRawValue)
            break;
          case VCardConstants.PROPERTY_ORG:
            tempList.org = decodeURI(String(propertyRawValue).replace(new RegExp('=', 'g'), '%'));
            break;
          case VCardConstants.PROPERTY_TITLE:
            tempList.title = decodeURI(String(propertyRawValue).replace(new RegExp('=', 'g'), '%'));
            break;
          case VCardConstants.PROPERTY_BDAY:
            tempList.bday = propertyRawValue;
            break;
          case VCardConstants.PROPERTY_NICKNAME:
            tempList.nickName = decodeURI(String(propertyRawValue).replace(new RegExp('=', 'g'), '%'));
            break;
          case VCardConstants.PROPERTY_NOTE:
            tempList.note = decodeURI(String(propertyRawValue).replace(new RegExp('=', 'g'), '%'));
            break;
          default:
            break;
        }
    }

    private getContactsData(contacts: ContactType[], tempList: VCardParserResult, index: number, status: number) {
        if (status === VCardParser.STATE_PARAMS) {
            contacts.push({
                contactName: tempList.name || '',
                telephone: '',
                telephoneFormat: '',
                headImage: '',
                select: true,
                id: index + 1,
                index: index,
                photoPath: tempList.photoPath,
                email: tempList.email,
                address: tempList.address,
                website: tempList.website,
                org: tempList.org,
                title: tempList.title,
                bday: tempList.bday,
                nickName: tempList.nickName,
                note: tempList.note,
            });
        } else {
            for (let i = 0; i < tempList.phoneNumber.length; i++) {
                contacts.push({
                    contactName: tempList.name || tempList.phoneNumber[i],
                    telephone: tempList.phoneNumber[i] || '',
                    telephoneFormat: tempList.phoneNumber[i] || '',
                    headImage: '',
                    select: true,
                    id: index + 1,
                    index: index,
                    avatarBase64Encoded: tempList.photoBase64 || '',
                    photoPath: tempList.photoPath || '',
                    telephoneType: tempList.phoneType ? tempList.phoneType[i] || '' : '',
                    email: tempList.email,
                    address: tempList.address,
                    website: tempList.website,
                    org: tempList.org,
                    title: tempList.title,
                    bday: tempList.bday,
                    nickName: tempList.nickName,
                    note: tempList.note,
                });
            }
            // 适配接收vcard，只有名字场景没有phoneNumber字段。
            if (tempList.phoneNumber.length === 0 && tempList.name) {
                contacts.push({
                    contactName: tempList.name,
                    telephone: '',
                    telephoneFormat: '',
                    headImage: '',
                    select: true,
                    id: index + 1,
                    index: index,
                    avatarBase64Encoded: tempList.photoBase64 || '',
                    photoPath: tempList.photoPath || '',
                    email: tempList.email,
                    address: tempList.address,
                    website: tempList.website,
                    org: tempList.org,
                    title: tempList.title,
                    bday: tempList.bday,
                    nickName: tempList.nickName,
                    note: tempList.note,
                });
            }
        }
    }

     parseItemInter(contactsArr: string[], index: number, mergeArr: string[]) {
        if (!contactsArr[index].includes('VERSION:2.1') && contactsArr[index].indexOf(VCardConstants.PARAM_PHOTO) != -1) {
            let base64Arr = contactsArr[index].split(VCardConstants.PARAM_PHOTO);
            let base64 = base64Arr[base64Arr.length - 1].replace(/\n[\t ]/g, '');
            if (base64Arr.length >= 1) {
                contactsArr[index] = base64Arr[0] + VCardConstants.PARAM_PHOTO + base64;
            }
        }
        let arr: string[] = [];
        if (contactsArr[index].indexOf('\r\n') != -1) {
            arr = contactsArr[index].split('\r\n');
        } else if (contactsArr[index].indexOf('\n') != -1) {
            arr = contactsArr[index].split('\n');
        }
        if (arr.length < 3) {
            HiLog.w(TAG, 'parseItemInter arr data error!');
            return;
        }
        if (arr[0] === '' && arr[1] === VCardConstants.PARAM_BEGIN_VCARD) {
            arr.splice(0, 1);
        }
        if (arr != null && arr.length > 1) {
            let startStr = arr[0];
            if (!this.judgeBeginVCard(startStr)) {
                return;
            }
        }

        for (let i = 0; i < arr.length; i++) {
            let str: string = arr[i];
            if (str.startsWith('=') || str.startsWith(';')) {
                str = mergeArr.pop() + str.substring(1, str.length);
                HiLog.w(TAG, `merge result:${str}`);
            }
            mergeArr.push(str);
        }
    }

    // check if is vcard begin
    private judgeBeginVCard(str: string): boolean {
        let strArray: string[] = str.split(':');
        let length = strArray.length;
        if (length == 2 && strArray[0].trim().toLowerCase() == ('BEGIN').toLowerCase() &&
            strArray[1].trim().toLowerCase() == ('VCARD').toLowerCase()) {
            return true
        }
        HiLog.i(TAG, 'judgeBeginVCard false:' + str);
        return false;
    }

    // parse vcard item
    private parseItemsByStr(str: string): VCardProperty | null {
        HiLog.i(TAG, 'parseItemsByStr enter');
        if (str == '') {
            HiLog.i(TAG, 'parseItemsByStr str is null');
            return null;
        }
        let propertyData: VCardProperty | null = this.constructPropertyData(str);
        if (!propertyData) {
            HiLog.i(TAG, 'parseItemsByStr propertyData is null');
            return null;
        }
        return propertyData;
    }

    private constructPropertyData(line: string): VCardProperty | null {
        let propertyData: VCardProperty = new VCardProperty();

        let length: number = line.length;
        if (length > 0 && line.charAt(0) == '#') {
            HiLog.i(TAG, 'VCardInvalidCommentLineException');
            return null;
        }

        let state: number = VCardParser.STATE_GROUP_OR_PROPERTY_NAME;
        let nameIndex: number = 0;
        // This loop is developed so that we don't have to take care of bottle neck here.
        // Refactor carefully when you need to do so.
        for (let i = 0; i < length; i++) {
            let ch: string = line.charAt(i);
            switch (state) {
              case VCardParser.STATE_GROUP_OR_PROPERTY_NAME: {
                if (ch == ':') { // End of a property name.
                    let propertyName: string = line.substring(nameIndex, i);
                    propertyData.setName(propertyName);
                    propertyData.setRawValue(i < length - 1 ? line.substring(i + 1) : '');
                    return propertyData;
                } else if (ch == '.') { // Each group is followed by the dot.
                    let groupName: string = line.substring(nameIndex, i);
                    if (groupName.length == 0) {
                        HiLog.w(TAG, 'Empty group found. Ignoring.');
                    } else {
                        propertyData.addGroup(groupName);
                    }
                    nameIndex = i + 1; // Next should be another group or a property name.
                } else if (ch == ';') { // End of property name and beginneng of parameters.
                    let propertyName: string = line.substring(nameIndex, i);
                    propertyData.setName(propertyName);
                    nameIndex = i + 1;
                    state = VCardParser.STATE_PARAMS; // Start parameter parsing.
                }
                break;
              }
              case VCardParser.STATE_PARAMS: {
                if (ch == '"') {
                    if (VCardConstants.VERSION_V21.toLowerCase() == (this.getVersionstring().toLowerCase())) {
                        HiLog.w(TAG, 'Double-quoted params found in vCard 2.1. ' + 'Silently allow it');
                    }
                    state = VCardParser.STATE_PARAMS_IN_DQUOTE;
                } else if (ch == ';') { // Starts another param.
                    this.handleParams(propertyData, line.substring(nameIndex, i));
                    nameIndex = i + 1;
                } else if (ch == ':') { // End of param and beginenning of values.
                    this.handleParams(propertyData, line.substring(nameIndex, i));
                    propertyData.setRawValue(i < length - 1 ? line.substring(i + 1) : '');
                    // 添加 type 类型
                    const typeMatch = line.match(/TEL;(.+?):/);
                    if (typeMatch && typeMatch[1]) {
                        const typeStr = typeMatch[1]
                        // 解析vcard 的 tel type
                        if (typeStr.includes('TYPE')) {
                            const typeArr = typeStr.split('=')
                            propertyData.setType(typeArr[1]);
                        } else {
                            propertyData.setType(typeStr);
                        }
                        return propertyData;
                    }
                    return propertyData;
                }
                break;
              }
              case VCardParser.STATE_PARAMS_IN_DQUOTE: {
                if (ch == '"') {
                    if (VCardConstants.VERSION_V21.toLowerCase() == (this.getVersionstring().toLowerCase())) {
                        HiLog.w(TAG, 'Double-quoted params found in vCard 2.1. ' +
                            'Silently allow it');
                    }
                    state = VCardParser.STATE_PARAMS;
                }
                break;
              }
            }
        }
        HiLog.w(TAG, "Invalid line: '\' + line + '\'");
        return propertyData;
    }

    private handleParams(propertyData: VCardProperty, params: string): void {
        const strArray: string[] = params.split('=', 2);
        if (strArray.length == 2) {
            let paramName: string = strArray[0].trim().toUpperCase();
            let paramValue: string = strArray[1].trim();
            if (paramName === 'TYPE') {
                this.handleType(propertyData, paramValue);
            }
        } else {
            this.handleParamWithoutName(propertyData, strArray[0]);
        }
    }

    private handleParamWithoutName(propertyData: VCardProperty, paramValue: string): void {
        this.handleType(propertyData, paramValue);
    }

    private handleType(propertyData: VCardProperty, ptypeval: string): void {
        propertyData.addParameter(VCardConstants.PARAM_TYPE, ptypeval);
    }

    /**
     * @return {@link VCardConfig#VERSION_30}
     */
    private getVersionstring(): string {
        return VCardConstants.VERSION_V21;
    }
}

export class StringBuilder {
    private mBuffer: string[] = [];
    private mIndex = 0;

    constructor() {
    }

    public append(content: string) {
        this.mIndex += this.mBuffer.push(content);
        return this;
    }

    public toString(): string {
        return this.mBuffer.slice(0, this.mIndex).join('');
    }
}

export class VCardProperty {
    private mName: string = '';
    private mType: string = '';
    private mGroupList: Array<string> = [];
    private mParameterMap: Map<string, Array<string> | Set<string>> = new Map();
    private mRawValue: string = '';

    public getParamMapString(): string {
        let str = '';
        let index = 0;
        this.mParameterMap.forEach((values, key, map) => {
            let valueString = '';
            values.forEach((v: string) => {
                valueString += v + ' ';

            })
            str += `${key} = ${valueString}`
            if (index++ < this.mParameterMap.size - 1) {
                str += ','
            }
        })
        return str;
    }

    public toString() {
        return `VCardProperty{mName='${this.mName}' , groupList=${this.mGroupList} , mParamterMap:{${this.getParamMapString()}} ,
     rawValue:'${this.mRawValue}' }`;
    }

    public setName(name: string) {
        if (this.mName != null) {
            HiLog.w('VCardProperty', `Property name is re-defined (existing: ${this.mName}, requested: ${name}`);
        }
        this.mName = name;
    }

    public setType(type: string) {
        if (this.mType != null) {
            HiLog.w('VCardProperty', `Property type is re-defined (existing: ${this.mType}, requested: ${type}`);
        }
        this.mType = type;
    }

    public setParameter(paramName: string, paramValue: string): void {
        this.mParameterMap.clear();
        this.addParameter(paramName, paramValue);
    }

    public getType(): string | null {
        return this.mType;
    }

    public addGroup(group: string) {
        if (this.mGroupList == null) {
            this.mGroupList = [];
        }
        this.mGroupList.push(group);
    }

    public addParameter(paramName: string, paramValue: string) {
        let values: Array<string> | Set<string>;
        if (!this.mParameterMap.has(paramName)) {
            if (paramName === ('TYPE')) {
                values = new Set<string>();
            } else {
                values = [];
            }
            this.mParameterMap.set(paramName, values);
        } else {
            values = this.mParameterMap.get(paramName)!;
        }

        if (values instanceof Array) {
            values.push(paramValue);
        } else {
            values.add(paramValue);
        }
    }

    public setRawValue(rawValue: string): void {
        this.mRawValue = rawValue;
    }

    public getName(): string | null {
        return this.mName;
    }

    public getRawValue(): string | null {
        return this.mRawValue;
    }

    public getGroupList(): string[] {
        return this.mGroupList;
    }

    public getParameterMap(): Map<string, Array<string> | Set<string>> {
        return this.mParameterMap;
    }

    public getParameters(type: string): Array<string> | Set<string> | undefined {
        return this.mParameterMap.get(type);
    }
}

export class VCardParserResult {
    public name: string = ''
    public phoneNumber: string[] = []
    public photoBase64: string = ''
    public photoPath: string = ''
    public phoneType?: string[] = []
    public email: ContactInfo.Email[] = []
    public address: ContactInfo.Address[] = []
    public website: string[] = []
    public org: string = ''
    public title: string = ''
    public bday: string = ''
    public nickName: string = ''
    public note: string = ''
}