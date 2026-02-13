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
import HiLog from '../../ets/utils/HiLog';
import sms from '@ohos.telephony.sms';
import StringUtil from '../../ets/utils/StringUtil';
import OperatorConfigUtil from '../utils/OperatorConfigUtil';
import sim from '@ohos.telephony.sim';
import SharedPreferencesUtils from '../../ets/utils/SharedPreferencesUtils';
import { BusinessError } from '@kit.BasicServicesKit';
import commonData from '../../ets/data/commonData';

const SPLIT_CHAR: string = ',';
const FRENCH_SPECIAL_CHARACTER_ONE: number = 0x0152;
const FRENCH_SPECIAL_CHARACTER_TWO: number = 0x0153;
const FRENCH_SPECIAL_CHARACTER_REPLACED_1: string = 'OE';
const FRENCH_SPECIAL_CHARACTER_REPLACED_2: string = 'oe';
const MAX_VALUE: number = 2147483647;
const SMS_7BIT_ENABLED_INT = 'sms_7bit_enabled_int';
const CHAR_7BIT_STRING = 'char_7bit_string';
const TAG: string = 'MessageUtils';
const GREEK_ALPHA: number[] = [
  0x3b4, 0x3c6, 0x3b3, 0x3bb, 0x38f, 0x3c9, 0x3ce, 0x3c0, 0x3c8, 0x3c2, 0x3c3, 0x3b8, 0x3be, 0x386, 0x391,
  0x3ac, 0x3b1, 0x392, 0x3b2, 0x388, 0x395, 0x3ad, 0x3b5, 0x389, 0x397, 0x3ae, 0x3b7, 0x38a, 0x390, 0x399,
  0x3aa, 0x3af, 0x3b9, 0x3ca, 0x39a, 0x3ba, 0x39c, 0x3bc, 0x39d, 0x3bd, 0x38c, 0x39f, 0x3bf, 0x3cc, 0x3a1,
  0x3c1, 0x3a4, 0x3c4, 0x3a7, 0x3c7, 0x38e, 0x3a5, 0x3ab, 0x3c5, 0x3cb, 0x3cd, 0x3b0, 0x3b6, 0x396,
  // for 88591
  0xc0, 0xc1, 0xc2, 0xc3, 0xc8, 0xca, 0xcb, 0xcc, 0xcd, 0xce, 0xcf, 0xd2, 0xd3, 0xd4, 0xd5, 0xd9, 0xda, 0xdb,
  0xdd, 0xe1, 0xe2, 0xe3, 0xe7, 0xea, 0xeb, 0xed, 0xee, 0xef, 0xf3, 0xf4, 0xf5, 0xfa, 0xfb, 0xfd, 0xff, 0x0152,
  0x0153, 0x151, 0x171, 0x150, 0x170, 0x105, 0x15B, 0x107, 0x17C, 0x17A, 0x119, 0xF3, 0x142, 0x144, 0x104, 0x15A,
  0x106, 0x17B, 0x179, 0x118, 0x141, 0x143, 0x013d, 0x013e, 0x010c, 0x010d, 0x010e, 0x010f, 0x011a, 0x011b, 0x0147,
  0x0148, 0x0158, 0x0159, 0x0160, 0x0161, 0x0164, 0x0165, 0x016e, 0x016f, 0x00dd, 0x00fd, 0x017d, 0x017e];

const GREEK_ABOUT_TO_7BIT: number[] = [
  0x394, 0x3A6, 0x393, 0x39B, 0x3A9, 0x3A9, 0x3A9, 0x3A0, 0x3A8, 0x3A3, 0x3A3, 0x398, 0x39E, 0x41, 0x41, 0x41, 0x41,
  0x42, 0x42, 0x45, 0x45, 0x45, 0x45, 0x48, 0x48, 0x48, 0x48, 0x49, 0x49, 0x49, 0x49, 0x49, 0x49, 0x49, 0x4b, 0x4b,
  0x4d, 0x4d, 0x4e, 0x4e, 0x4f, 0x4f, 0x4f, 0x4f, 0x50, 0x50, 0x54, 0x54, 0x58, 0x58, 0x59, 0x59, 0x59, 0x59, 0x59,
  0x59, 0x59, 0x5a, 0x5a,
  // for 88591
  0x41, 0x41, 0x41, 0x41, 0x45, 0x45, 0x45, 0x49, 0x49, 0x49, 0x49, 0x4f, 0x4f, 0x4f, 0x4f, 0x55, 0x55, 0x55,
  0x59, 0x61, 0x61, 0x61, 0xc7, 0x65, 0x65, 0x69, 0x69, 0x69, 0x6f, 0x6f, 0x6f, 0x75, 0x75, 0x79, 0x79,
  0x0152, 0x0153, 0x6f, 0x75, 0x4f, 0x55, 0x61, 0x73, 0x63, 0x7A, 0x7A, 0x65, 0x6F, 0x6C, 0x6E, 0x41, 0x53,
  0x43, 0x5A, 0x5A, 0x45, 0x4C, 0x4E, 0x004c, 0x006c, 0x0043, 0x0063, 0x0044, 0x0064, 0x0045, 0x0065, 0x004e,
  0x006e, 0x0052, 0x0072, 0x0053, 0x0073, 0x0054, 0x0074, 0x0055, 0x0075, 0x0059, 0x0079, 0x005a, 0x007a];

class MessageUtil {
  public static replaceForLossy7Bit(slotId: number, content: string, startIndex: number, endIndex: number): string {
    if (content == null || content == undefined || startIndex < 0 || startIndex > endIndex
      || startIndex > content.length) {
      HiLog.i(TAG, 'replaceForLossy7Bit param error startIndex:' + startIndex + ' endIndex:' + endIndex)
      return content;
    }
    let enabled7Bit: boolean =
      OperatorConfigUtil.getInstance().getOperatorConfig(slotId, SMS_7BIT_ENABLED_INT) === '1' ? true : false;
    if (!enabled7Bit) {
      HiLog.i(TAG, 'sevenBitEnabled is false')
      return content;
    }
    let char7Bit: string = OperatorConfigUtil.getInstance().getOperatorConfig(slotId, CHAR_7BIT_STRING);
    let charMappingRelationship: Map<number, number> = MessageUtil.get7bitsTable(char7Bit);
    let sResult: string = '';
    let targetChar: string;
    let convertedChar: number;
    let tempChar: string;
    for (let i = startIndex; i < endIndex; i++) {
      targetChar = content.charAt(i);
      convertedChar = MessageUtil.charReplace(targetChar, charMappingRelationship);
      tempChar = targetChar;
      if (convertedChar != MAX_VALUE) {
        tempChar = String.fromCharCode(convertedChar)
        if (convertedChar == FRENCH_SPECIAL_CHARACTER_ONE) {
          tempChar = FRENCH_SPECIAL_CHARACTER_REPLACED_1;
        } else if (convertedChar == FRENCH_SPECIAL_CHARACTER_TWO) {
          tempChar = FRENCH_SPECIAL_CHARACTER_REPLACED_2;
        }
      }
      sResult += tempChar;
    }
    return sResult;
  }

  private static get7bitsTable(char7Bit: string): Map<number, number> {
    let charMappingRelationship: Map<number, number> = new Map();
    if (char7Bit == null || char7Bit == undefined || char7Bit.length < 1) {
      HiLog.i(TAG, 'char7Bit is undefined or null or length<1')
      return charMappingRelationship;
    }
    let characterLossy7Bit: string[] = char7Bit.split('|');
    let characterAfterSplit: string[];
    let beforeLossy7Bit: number;
    let afterLossy7Bit: number;
    for (let i = 0; i < characterLossy7Bit.length; i++) {
      characterAfterSplit = characterLossy7Bit[i].split(SPLIT_CHAR);
      if (characterAfterSplit.length < 2) {
        HiLog.i(TAG, 'characterAfterSplit:' + JSON.stringify(characterAfterSplit))
        continue;
      }
      beforeLossy7Bit = Number(characterAfterSplit[0]);
      afterLossy7Bit = Number(characterAfterSplit[1]);
      charMappingRelationship.set(beforeLossy7Bit, afterLossy7Bit)
    }
    return charMappingRelationship;
  }

  private static charReplace(targetChar: string, charMappingRelationship: Map<number, number>): number {
    if (charMappingRelationship == undefined || charMappingRelationship == null || charMappingRelationship.size < 1) {
      charMappingRelationship = new Map<number, number>();
      for (let i = 0; i < GREEK_ALPHA.length; i++) {
        charMappingRelationship.set(GREEK_ALPHA[i], GREEK_ABOUT_TO_7BIT[i])
      }
    }
    let sChar = charMappingRelationship.get(targetChar.charCodeAt(0));
    return (sChar == undefined) ? MAX_VALUE : sChar;
  }

  /**
   * Get the cust SMSC address from shared preferences.
   *
   * @param { number } slotId - the slot id.
   * @returns { string } Returns the cust SMSC address
   */
  public static async getSmscNumberFromPref(slotId: number): Promise<string> {
    HiLog.w(TAG, 'getSmscNumberFromPref start');
    let smsc: string = '';
    //param card is simid
    let card = await MessageUtil.getSimId(slotId);
    if (card != -1) {
      smsc = SharedPreferencesUtils.getFromPreferences('SMSC' + card, '') as string;
    }
    if (StringUtil.isEmpty(smsc)) {
      HiLog.e(TAG, 'empty number in sharedPreference');
      smsc = OperatorConfigUtil.getInstance().getCustSMSCAddress(slotId);
    }
    if (StringUtil.isEmpty(smsc)) {
      HiLog.e(TAG, 'empty number in cust config');
      sms.getSmscAddr(slotId).then((data: string) => {
        if (StringUtil.isEmpty(data)) {
          HiLog.e(TAG, 'empty number in interface');
        } else {
          smsc = data;
          SharedPreferencesUtils.saveToPreferences('SMSC' + card, smsc);
        }
      }).catch((err: BusinessError) => {
        HiLog.e(TAG, `getSmscAddr failed, promise: err->${JSON.stringify(err)}`);
      });
    }
    HiLog.w(TAG, 'getSmscNumberFromPref end');
    return smsc;
  }

  public static async getSimId(slotId: number): Promise<Number> {
    return new Promise(async (resolve) => {
      let card: number = -1;
      // 设置超时时间为1000 ms;
      let timeoutId = setTimeout(() => {
        HiLog.e(TAG, 'getSimId timeout');
        resolve(card);
      }, 1000);
      let accountInfo = await sim.getSimAccountInfo(slotId);
      card = accountInfo.simId;
      // 如果函数已经完成，清除超时并返回结果
      if (card != undefined) {
        clearTimeout(timeoutId);
        resolve(card);
      }
    });
  }

  public static async getSMSCAddress(slotId: number): Promise<string> {
    return new Promise(async (resolve) => {
      let card: number = -1;
      // 设置超时时间为500 ms;
      let timeoutId = setTimeout(() => {
        HiLog.e(TAG, 'getSMSCAddress timeout');
        resolve('');
      }, 1000);
      let smscNumber: string | undefined = undefined;
      let accountInfo = await sim.getSimAccountInfo(slotId);
      card = accountInfo.simId;
      if (card != -1) {
        smscNumber = SharedPreferencesUtils.getFromPreferences('SMSC' + card, '') as string;
      }
      // 如果函数已经完成，清除超时并返回结果
      if (smscNumber != undefined) {
        clearTimeout(timeoutId);
        resolve(smscNumber);
      }
    });
  }

  /**
   * Check whether the text is an MMS message.
   *
   * @param { string } content - the message input
   * @returns { boolean } Returns the true if the content is an MMS message, Otherwise return false
   */
  public static async isMmsText(content: string): Promise<boolean> {
    if (StringUtil.isEmpty(content)) {
      HiLog.i(TAG, 'not support text to mms because empty input');
      return false;
    }
    let data: string[] = await sms.splitMessage(content);
    let messageCount: number = data.length;
    let smsToMmsThreshold = OperatorConfigUtil.getInstance().getCustomSmsToMmsThreshold(
      commonData.int.SMS_TO_MMS_THRESHOLD_DEFAULT);
    if (smsToMmsThreshold === commonData.int.NOT_SUPPORT_SMS_TO_MMS) {
      HiLog.i(TAG, 'not support text to mms because the capability is not supported');
      return false;
    }
    let result = messageCount >= smsToMmsThreshold;
    HiLog.i(TAG, 'result = ' + result);
    return result;
  }
}

export default MessageUtil;