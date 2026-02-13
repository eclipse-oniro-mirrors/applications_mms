/**
 * Copyright (c) 2022 Huawei Device Co., Ltd.
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
import common from '../data/commonData';
import HiLog from './HiLog';
import call from '@ohos.telephony.call';
import LooseObject from '../data/LooseObject';
import i18n from '@ohos.i18n';
import { BusinessError } from '@ohos.base';
import StringUtil from './StringUtil';
import commonData from '../data/commonData';
import ConversationListService from '../service/ConversationListService';
import ConversationListResponse from '../model/conversationlist/ConversationListResponse';
import { ConversationListInfo } from '../model/conversationlist/ConversationListInfo';
import { ValuesBucket } from '@kit.ArkData';
import { ResponseType} from '../service/ConversationListService'
import ConversationService from '../service/ConversationService';
import { ArrayList } from '@kit.ArkTS';
import { CountryIdUtil } from './CountryIdUtil';

const TAG = 'TelephoneUtil';

const infoMegTelephone: Array<string> = [
  // 国家类服务号码
  '9', '95', '100', '101', '106', '108', '111', '116', '118', '123', '400', '800', '1212', '000000', '114', '0898',
  '12580', '12520', '12583', '0452',
  // 国家类区行政号码开头
  '\\d{2,4}12123$', '\\d{2,4}12329$', '^02[0-9]', '010', '^05[34]', '^07[56]',
];

const judgIsNumberReg = /^[0-9]+$/;

export class I18nPhoneNumberFormat {
  public instancePhoneNumberFormat: i18n.PhoneNumberFormat;
  private constructor() {
    this.instancePhoneNumberFormat = new
      i18n.PhoneNumberFormat(i18n.System.getSystemRegion(), { type: 'NATIONAL' });
  }
  private static instance: I18nPhoneNumberFormat;
  static getInstance(): I18nPhoneNumberFormat {
    if (I18nPhoneNumberFormat.instance == undefined) {
      I18nPhoneNumberFormat.instance = new I18nPhoneNumberFormat();
    }
    return I18nPhoneNumberFormat.instance;
  }
}

class I18nPhoneNumberFormatE164 {
  private phoneNumberFormatMap: Map<string, string> = new Map();

  public instancePhoneNumberFormatE164: i18n.PhoneNumberFormat;

  private constructor() {
    this.instancePhoneNumberFormatE164 = new i18n.PhoneNumberFormat(i18n.System.getSystemRegion(), { type: 'E164' });
  }

  private static instance: I18nPhoneNumberFormatE164;

  static getInstance(): I18nPhoneNumberFormatE164 {
    if (I18nPhoneNumberFormatE164.instance == undefined) {
      I18nPhoneNumberFormatE164.instance = new I18nPhoneNumberFormatE164();
    }
    return I18nPhoneNumberFormatE164.instance;
  }

  public static release(): void {
    //温启动后程序关闭后，释放map，防止有干扰
    if (I18nPhoneNumberFormatE164.instance) {
      I18nPhoneNumberFormatE164.instance.phoneNumberFormatMap = new Map();
    }
  }

  public savePhoneNumber(telephone: string, formatNumber: string) {
    if (StringUtil.isEmpty(telephone) || StringUtil.isEmpty(formatNumber)) {
      return;
    }
    // 多次调用format接口的返回结果应当是一样的，没有必要反复存储
    if (!this.phoneNumberFormatMap.has(telephone)) {
      this.phoneNumberFormatMap.set(telephone, formatNumber);
    }
  }

  public getFormatPhoneNumber(telephone: string): string {
    if (StringUtil.isEmpty(telephone)) {
      return '';
    }
    return this.phoneNumberFormatMap.get(telephone) ?? '';
  }
}

class TelephoneUtil {
  /**
   * 短信最大长度-防止正则共计
   */
  private static readonly SMS_MSG_LENGTH: number = 512;
  /**
   * 签名的最大字符长度-40
   */
  private static readonly SIGNATURE_LENGTH: number = 40;

  /**
   * AIM短信签名正则表达式-匹配头部的签名
   */
  private static readonly HEAD_SQUARE_BRACKET_REGULAR: RegExp =
    new RegExp('^((?:\\s*(?:【([^【】]{1,40}?)】|\\[([^\\[\\]]{1,40}?)\\]))?)');
  /**
   * AIM短信签名正则表达式-匹配尾部的签名
   */
  private static readonly TAILED_SQUARE_BRACKET_REGULAR: RegExp =
    new RegExp('((?:(?:【([^【】]{1,40}?)】|\\[([^\\[\\]]{1,40}?)\\])\\s*)?)$');
  /**
   * AIM短信签名正则表达式-匹配中括号里面的内容[]or【】 bracket
   */
  private static readonly BRACKET_SQUARE_BRACKET_REGULAR: RegExp =
    new RegExp('(?:【([^【】]{1,40}?)】|\\[([^\\[\\]]{1,40}?)\\])');

  public judgeIsInfoMsg(telephone: string): boolean {
    if (telephone == null || telephone == common.STR.EMPTY_STR) {
      return false;
    }
    let regexSymbol = new RegExp('\\,')
    if (regexSymbol.test(telephone)) {
      return false;
    }
    let regex = new RegExp('^(0086|\\+?86|\\+)?(' + infoMegTelephone.join('|') + ')');
    return regex.test(telephone);
  }

  public updateInfoMsg(context: Context, callback: Function) {
    let actionData: LooseObject = {
      'smsType': 0,
    }
    let convList: ConversationListInfo[] = [];
    ConversationListService.getInstance().querySessionByCondition(context, actionData,
      (res: ConversationListResponse) => {
      if (res.code === common.int.SUCCESS) {
        convList = res.abilityResult
        this.buildUpdateInfo(convList, context, callback);
      } else {
        HiLog.i(TAG, 'has no normal sms');
        callback();
      }
    });
  }

  private buildUpdateInfo(convList: ConversationListInfo[], context: Context, callback: Function) {
    HiLog.i(TAG, `convList len: ${convList.length}`);
    let threadIdArr: number[] = [];
    convList.forEach(item => {
      if (this.judgeIsInfoMsg(item.telephone)) {
        threadIdArr.push(item.id);
      }
    });
    let vp: ValuesBucket = {
      'sms_type': 1
    };
    let actionData: Record<string, number[]> = {
      'threadIds': threadIdArr
    };
    let actionDataSession: LooseObject = {
      'threadIds' : threadIdArr
    }
    if (threadIdArr.length > 0) {
      let p1: Promise<LooseObject> = new Promise((resolve, reject) => {
        ConversationListService.getInstance().updateSessionByCondition(context, actionDataSession,
          vp, (res: LooseObject) => {
            if (res.code === common.int.SUCCESS) {
              HiLog.i(TAG, 'updateSessionByCondition success');
              resolve(res);
            } else {
              HiLog.e(TAG, 'updateSessionByCondition failed');
              reject(res);
            }
          });
      });
      let p2: Promise<LooseObject> = new Promise((resolve, reject) => {
        ConversationService.getInstance().updateSmsInfoSmsTypeBySessionIds(actionData, (res: LooseObject) => {
          if (res.code === common.int.SUCCESS) {
            HiLog.i(TAG, 'updateSmsInfoSmsTypeBySessionIds success');
            resolve(res);
          } else {
            HiLog.e(TAG, 'updateSmsInfoSmsTypeBySessionIds failed');
            reject(res);
          }
        }, context);
      });
      Promise.allSettled([p1, p2]).then((values) => {
        callback();
      });
    } else {
      callback();
    }
  }

  public formatTelephones(telephones: string): string {
    let formatTelephones: string = telephones;
    if (telephones == null || telephones == common.STR.EMPTY_STR) {
      return formatTelephones;
    }
    let telephoneArray: Array<string> = [];
    for (let telephone of telephones.split(',')) {
      telephoneArray.push(telephone);
    }
    if (telephoneArray.length > 1) {
      formatTelephones = telephoneArray.join(',');
    } else {
      formatTelephones = telephoneArray[0];
    }
    return formatTelephones;
  }

  /**
   *  format the phone number according to countryCode with i18n.PhoneNumberFormat
   *
   * @param phone
   * @returns
   */
  public countryCodeFormatPhone(phone: string) {
    if (StringUtil.isEmpty(phone)) {
      return commonData.STR.EMPTY_STR;
    }
    if (phone.startsWith('sip:') && phone.concat('@')) {
      return phone;
    }
    if (!this.judgIsNumberWithTelephoneNumber(phone)) {
      return phone;
    }
    let countryId: string = AppStorage.get('country') as string;
    if (countryId === undefined || countryId === '') {
      countryId = CountryIdUtil.getCountryId();
      AppStorage.setOrCreate('country', countryId);
    }
    // 根据国家码，使用TYPING类型，格式化电话号码
    let phoneNumberFmt = new i18n.PhoneNumberFormat(countryId, { type: 'TYPING' });
    let phoneNumber: string = phone;
    let formatResult: string = '';
    for (let i = 0; i < phoneNumber.length; i++) {
      formatResult += phoneNumber.charAt(i);
      formatResult = phoneNumberFmt.format(formatResult);
    }
    return formatResult;
  }


  public dealSelectContactsSort(selectContacts: Array<LooseObject>): Array<LooseObject> {
    if (selectContacts.length == 0) {
      return new Array<LooseObject>();
    }
    let result: Array<LooseObject> = [];
    let telephone = common.STR.EMPTY_STR;
    let contactsMap = new Map<string, LooseObject>();
    for (let item of selectContacts) {
      telephone = telephone + item.telephone + common.STR.COMMA;
      if (!contactsMap.has(item.telephone)) {
        contactsMap.set(item.telephone, item);
      }
      contactsMap.set('rawContactId', item.rawContactId);
      contactsMap.set('contactId', item.contactId);
    }
    telephone = this.dealTelephoneSort(telephone.substring(0, telephone.length - 1));
    let telephones = telephone.split(common.STR.COMMA);
    for (let element of telephones) {
      if (contactsMap.has(element)) {
        result.push(contactsMap.get(element) as LooseObject);
      }
    }
    return result;
  }

  public dealTelephoneSort(telephone: string): string {
    if (telephone == null || telephone == common.STR.EMPTY_STR) {
      return common.STR.EMPTY_STR;
    }
    let result = common.STR.EMPTY_STR;
    let telephones = telephone.split(common.STR.COMMA);
    // If there is only one mobile number, no sorting is required.
    if (telephones.length == 1) {
      return telephone;
    }
    let telephoneMap = new Map<number, string[]>();
    let indexs: Array<number> = [];
    let count = 0;
    // grouping
    for (let item of telephones) {
      if (telephoneMap.has(item.length)) {
        let strings: string[] = telephoneMap.get(item.length) as string[];
        strings.push(item);
      } else {
        let strings: string[] = [];
        strings.push(item);
        telephoneMap.set(item.length, strings);
        indexs[count++] = item.length;
      }
    }
    // Sort from Large to Small
    this.bubbleSort(indexs, count);
    for (let index of indexs) {
      let arrs: string[] = telephoneMap.get(index) as string[];
      this.bubbleSort(arrs, arrs.length);
      for (let arr of arrs) {
        result = result + arr + common.STR.COMMA;
      }
    }
    // Obtain the corresponding results and pair them.
    return result.substring(0, result.length - 1);
  }

  /**
   * Bubble sort, sorted in ascending order.
   * @param arr
   * @param length
   */
  public bubbleSort(arr: string[] | number[], length: number): void {
    // A minimum value is generated from the back to the front at a time, and the final position of a number
    // in the sequence can be determined at a time.
    for (let i = 0; i < length - 1; i++) {
      // Improvement of bubbling so that the sequence is ordered if no reversal occurs in one pass
      for (let j = length - 1; j > i; j--) {
        // A minimum value pops up from the back at a time.
        if (arr[j] < arr[j - 1]) {
          // Reverse order occurs, then swap
          let temple = arr[j];
          arr[j] = arr[j - 1];
          arr[j - 1] = temple;
        }
      }
    }
  }

  public isPhoneNumber(str: string): boolean {
    // Determine whether the value is a number.
    let reg: RegExp = new RegExp('^(\\+)?\\d{1,}$');
    let pattern = new RegExp(reg);
    return pattern.test(str);
  }

  public getLastForDigit(str: string, strLen: number): string {
    if (str == null || strLen <= common.int.TELEPHONE_LAST_PART_LENGTH) {
      return '';
    }
    return '****' + str.slice(-common.int.TELEPHONE_LAST_PART_LENGTH);
  }

  public initPhoneNumberFormat() {
    // 首次构造PhoneNumberFormat会触发资源加载，因此提前调用可提升后续首次调用的性能
    I18nPhoneNumberFormat.getInstance();
    I18nPhoneNumberFormatE164.getInstance();
  }

  public release() {
    // 短信温启动之后，程序关闭后，需要显式释放一部分资源
    I18nPhoneNumberFormatE164.release();

  }

  public formatDisplayPhoneNum(phoneNumber: string): string {
    try {
      if (!this.judgIsNumberWithTelephoneNumber(phoneNumber)) {
        return phoneNumber;
      }
      //先去空格
      phoneNumber = phoneNumber.replace(/\s*/g, '');
      let systemLanguage = i18n.System.getSystemLanguage();
      // 阿拉伯语的数字不是阿拉伯数字
      if (systemLanguage.toLowerCase() == 'ar') {
        //dev和主干分支号码返回值不一致，主干返回值多了个+86
        if (phoneNumber.startsWith('+86')) {
          phoneNumber = phoneNumber.substring(3)
        }
        return phoneNumber;
      }
      //先用 national 格式化一次
      let nationalPhoneNumberFormat = I18nPhoneNumberFormat.getInstance().instancePhoneNumberFormat;
      let isNumberNationalValid: boolean = nationalPhoneNumberFormat.isValidNumber(phoneNumber);
      let nationalFormatNumber = isNumberNationalValid ? nationalPhoneNumberFormat.format(phoneNumber) : phoneNumber;
      let nationalFormatNumberTemp = nationalFormatNumber.replace(/\s*/g, '');
      let nationalFormatNumLen = nationalFormatNumberTemp.length;
      let originNumLen = phoneNumber.length;
      if (nationalFormatNumLen <= originNumLen &&
        nationalFormatNumberTemp === phoneNumber.substring(originNumLen - nationalFormatNumLen)) {
        return nationalFormatNumber;
      }
      //如果经过以上处理不符合条件，再用e164格式化
      let e164phoneNumberFormat = I18nPhoneNumberFormatE164.getInstance().instancePhoneNumberFormatE164;
      let isNumberE164Valid: boolean = e164phoneNumberFormat.isValidNumber(phoneNumber);
      let e164FormatNumber = isNumberE164Valid ? e164phoneNumberFormat.format(phoneNumber) : phoneNumber;
      return e164FormatNumber;
    } catch (error) {
      let err: BusinessError = error as BusinessError;
      HiLog.e(TAG, `formatPhoneNum failed, error code: ${err.code}, message: ${err.message}.`);
    }
    return phoneNumber;
  }

  // 默认使用cache中的数据，也保存当前format结果到cache中，能够节省下次format的时间；
  // 也可以通过传递参数isUsingCache/isSavingCache不使用/不存储Cache。
  public formatDisplayPhoneNumE164(phoneNumber: string, isUsingCache: boolean = true, isSavingCache = true): string {
    try {
      if (!this.judgIsNumberWithTelephoneNumber(phoneNumber)) {
        return phoneNumber;
      }
      let instance = I18nPhoneNumberFormatE164.getInstance();
      if (isUsingCache) {
        let cacheNumber = instance.getFormatPhoneNumber(phoneNumber);
        if (!StringUtil.isEmpty(cacheNumber)) {
          return cacheNumber;
        }
      }
      let phoneNumberFormat = instance.instancePhoneNumberFormatE164;
      let isNumberValid: boolean = phoneNumberFormat.isValidNumber(phoneNumber);
      let formatNumber = isNumberValid ? phoneNumberFormat.format(phoneNumber) : phoneNumber;
      if (isSavingCache) {
        instance.savePhoneNumber(phoneNumber, formatNumber);
      }
      return formatNumber;
    } catch (error) {
      let err: BusinessError = error as BusinessError;
      HiLog.e(TAG, `formatPhoneNum failed, error code: ${err.code}, message: ${err.message}.`);
    }
    return phoneNumber;
  }

  public batchFormatPhoneNumber(oriNumber: string[]): string[] {
    if (oriNumber == null || oriNumber.length == 0) {
      return [];
    }
    let result: string[] = [];
    for (let num of oriNumber) {
      let formatNum = this.formatDisplayPhoneNumE164(num);
      result.push(formatNum);
    }
    return result;
  }
  
  public batchNationalFormatPhoneNumber(oriNumber: string[]): string[] {
    if (oriNumber == null || oriNumber.length == 0) {
      return [];
    }
    let result: string[] = [];
    for (let num of oriNumber) {
      let formatNum = this.nationalFormatNumber(num);
      result.push(formatNum);
    }
    return result;
  }

  /**
   * 找到匹配号码的会话
   * @param list 符合模糊匹配规则的所有会话
   * @param telephone 需要进行匹配的号码
   * @returns 最终匹配的会话
   */
  public getTelephoneByFuzzMatch(list: ResponseType[], telephone: string): ResponseType {
    let contactsTemp: string[] = [];
    for (let info of list) {
      contactsTemp.push(info.telephone);
      if (info.telephone === telephone) {
        // 如果有全等匹配的号码，直接返回
        return info;
      }
    }
    HiLog.i(TAG, 'getTelephoneByFuzzMatch');

    let contactFormatPhoneNumber: string[] = this.batchFormatPhoneNumber(contactsTemp);
    let formatTelephone = this.formatDisplayPhoneNumE164(telephone);
    for (let i = 0; i < list.length; i++) {
      if (contactFormatPhoneNumber[i] === formatTelephone) {
        HiLog.i(TAG, 'getTelephoneByFuzzMatch bingo');
        return list[i];
      }
    }

    let contactNationalPhoneNumbers: string[] = this.batchNationalFormatPhoneNumber(contactsTemp);
    let nationalFormatTelephone = this.nationalFormatNumber(telephone);
    if (StringUtil.isEmpty(nationalFormatTelephone)) {
      HiLog.i(TAG, 'nationalFormatNumber is null');
      return new ConversationListInfo();
    } else {
      nationalFormatTelephone = nationalFormatTelephone.replaceAll(/\s/g, '');
    }
    for (let i = 0; i < list.length; i++) {
      let contactNationalPhoneNumber = contactNationalPhoneNumbers[i];
      if (!StringUtil.isEmpty(contactNationalPhoneNumber)) {
        contactNationalPhoneNumber = contactNationalPhoneNumber.replaceAll(/\s/g, '');
      }
      if (contactNationalPhoneNumber == nationalFormatTelephone) {
        HiLog.i(TAG, 'getNationalTelephoneByFuzzMatch bingo');
        return list[i];
      }
    }

    HiLog.i(TAG, 'getTelephoneByFuzzMatch end');
    return new ConversationListInfo();
  }

  nationalFormatNumber(number: string): string {
    if (number === undefined || number === null) {
      HiLog.e(TAG, 'nationalFormatNumber number is null');
      return '';
    }
    if (!number.trim()) {
      return number;
    }
    // type取值"NATIONAL"
    let phoneNumberFormat: i18n.PhoneNumberFormat = I18nPhoneNumberFormat.getInstance().instancePhoneNumberFormat;
    let isNumberValid: boolean = phoneNumberFormat.isValidNumber(number);
    let formatNumber: string = isNumberValid ? phoneNumberFormat.format(number) : number;
    return formatNumber;
  }

  /**
   * Dynamically format the number in the input.
   *
   * @param phone
   * @returns
   */
  public dynamicFormatPhone(phone: string): string {
    phone = (phone ?? '').replace(new RegExp('[\\s]', 'g'), '');
    if (StringUtil.isEmpty(phone)) {
      return commonData.STR.EMPTY_STR;
    }
    let formatRules: number [] = [];
    if (phone.length === 8) {
      formatRules = [4, 4];
    } else if (phone.length === 12) {
      formatRules = [2, 3, 3, 4];
    } else if (phone.length === 11) {
      formatRules = [3, 4, 4];
    }
    return StringUtil.formatWithSpace(phone, formatRules);
  }

  public isDomesticTelephone(telephone: string): boolean {
    let result: boolean = false;
    if (telephone == null || telephone == common.STR.EMPTY_STR) {
        HiLog.e(TAG, `isDomesticTelephone telephone is null`);
        return result;
    }
    if (telephone.startsWith('+86') || telephone.startsWith('86') || telephone.startsWith('0086')) {
        HiLog.i(TAG, `isDomesticTelephone startsWith 86`);
        result = true;
    }
    return result;
  }

  public isSpMms(telephone: string): boolean {
    let result = false;
    if (telephone.startsWith('1068') || telephone.startsWith('1069') ||
        telephone.startsWith('1065')) {
        result = true;
    }
    return result;
  }

  public async formatDisplayPhoneNumIntl(phoneNumber: string): Promise<string> {
    let countryId = '';
    if (StringUtil.isEmpty(phoneNumber)) {
      HiLog.e(TAG, 'formatDisplayPhoneNumIntl phoneNumber is empty');
      return '';
    }
    try {
      countryId = i18n.System.getSystemRegion();
    } catch (error) {
      countryId = 'CN';
    }
    if (countryId === 'CN') {
      return await this.formatNumberForChineseCodePlan(countryId, phoneNumber);
    } else {
      return this.formatDisplayPhoneNum(phoneNumber);
    }
  }

  private async formatNumberForChineseCodePlan(countryId: string, phoneNumber: string): Promise<string> {
    if (!this.judgIsNumberWithTelephoneNumber(phoneNumber)) {
      return phoneNumber;
    }
    let options: call.NumberFormatOptions = {
      countryCode: countryId
    };
    if (StringUtil.isEmpty(phoneNumber)) {
      HiLog.e(TAG, 'formatNumberForChineseCodePlan phoneNumber is empty');
      return '';
    }
    let formatNumber: string = await call.formatPhoneNumber(phoneNumber, options);
    if (StringUtil.isEmpty(formatNumber)) {
      formatNumber = phoneNumber;
    }
    return formatNumber;
  }

  public removeWhitespace(telephone: string): string {
    if (StringUtil.isEmpty(telephone)) {
      HiLog.e(TAG, 'removeWhitespace telephone is empty');
      return '';
    }
    return telephone.replace(/\s/g, '');
  }

  /**
   * 从短信原文获取短信签名
   *
   * @param message 短信原文
   * @return 短信签名列表
   */

  public getSmsSignature(message: string): ArrayList<string> {
    let smsSignatureList: ArrayList<string> = new ArrayList();
    if (StringUtil.isEmpty(message)) {
      return smsSignatureList;
    }

    const trimMessage: string = message.trim();

    // 获取短信原文头部的签名
    let headStr: string = TelephoneUtil.getCorpPattern(TelephoneUtil.HEAD_SQUARE_BRACKET_REGULAR, trimMessage);
    // 是否是【xxx】或[xxx]格式(整个短信原文就是一个中括号)标志
    if (!StringUtil.isEmpty(headStr) && headStr.length === trimMessage.length) {
      return smsSignatureList;
    }
    try {
      // if (!StringUtil.isEmpty(headStr) &&
      //   TelephoneUtil.stringToUint8Array(headStr).byteLength <= TelephoneUtil.SIGNATURE_LENGTH) {
      //   let headBracketStr: string =
      //     TelephoneUtil.getCorpPattern(TelephoneUtil.BRACKET_SQUARE_BRACKET_REGULAR, headStr);
      //   if (headBracketStr.length > 0) {
      //     let s: string | undefined = StringUtil.trimBlank(headBracketStr);
      //     if (s !== undefined && !StringUtil.isEmpty(s)) {
      //       smsSignatureList.add(s);
      //     }
      //   }
      // }
    } catch (e) {
      HiLog.e(TAG, `Obtains the character length failed: ${e.message}} `);
    }
    // 获取短信原文尾部的签名
    let tailedStr: string = TelephoneUtil.getCorpPattern(TelephoneUtil.TAILED_SQUARE_BRACKET_REGULAR, trimMessage);
    try {
      // if (!StringUtil.isEmpty(tailedStr) &&
      //   TelephoneUtil.stringToUint8Array(tailedStr).byteLength <= TelephoneUtil.SIGNATURE_LENGTH) {
      //   let tailedBracketStr: string =
      //     TelephoneUtil.getCorpPattern(TelephoneUtil.BRACKET_SQUARE_BRACKET_REGULAR, tailedStr);
      //   if (tailedBracketStr.length > 0) {
      //     let s: string | undefined = StringUtil.trimBlank(tailedBracketStr);
      //     if (s !== undefined && !StringUtil.isEmpty(s)) {
      //       smsSignatureList.add(s);
      //     }
      //   }
      // }
    } catch (e) {
      HiLog.e(TAG, `Obtains the character length failed: ${e.message}} `);
    }
    HiLog.i(TAG, `Obtains the character length failed:` + smsSignatureList.length);
    return smsSignatureList;
  }

  /**
   * 获取正则匹配后的字符串
   *
   * @param pattern 正则表达式
   * @param msg 传入的要匹配的字符串
   * @return 符合正则表达式的字符串
   */
  private static getCorpPattern(regex: RegExp, msg: string): string {
    let groups: RegExpExecArray | null = regex.exec(msg);
    if (groups !== null) {
      for (let i = 1; i < groups.length; i++) {
        if (!StringUtil.isEmpty(groups[i])) {
          return groups[i];
        }
      }
    }
    return '';
  }

  // private static stringToUint8Array(str: string): Uint8Array {
  //   return aegisInner.Coder.UTF8.decode(str);
  // }

  /**
   * 判断电话号码是不是非纯数字
   */
  judgIsNumberWithTelephoneNumber(phoneNumber: string): boolean {
    if (StringUtil.isEmpty(phoneNumber)){
      return false;
    }
    // 如果存在+号，先去+号，再判断是否是纯数字
    if (phoneNumber.startsWith('+')) {
      let phone = phoneNumber.slice(1);
      if (!judgIsNumberReg.test(phone)) {
        return false;
      } else {
        return true;
      }
    } else {
      if (!judgIsNumberReg.test(phoneNumber)) {
        return false;
      } else {
        return true;
      }
    }
  }
}

// Singleton
export default new TelephoneUtil();