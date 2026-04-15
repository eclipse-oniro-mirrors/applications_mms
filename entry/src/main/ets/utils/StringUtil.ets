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

import commonData from '../data/commonData';
import LooseObject, { isObjectType, MyAny } from '../data/LooseObject';
import HiLog from '../utils/HiLog';
import MeasureText from '@ohos.measure';
import myCommon from '@ohos.app.ability.common';
const TAG: string = 'StringUtil';
const NON_ALPHABET_REG: RegExp = new RegExp('[^\\x00-\\x80]', 'g');
const PAGE_ONE = 1;
const PAGE_TWO = 2;
const PAGE_THREE = 3;
const PAGE_ONE_OFFSET = 10;
const PAGE_TWO_OFFSET = 50;
const PAGE_THREE_OFFSET = 140;
const PAGE_MORE_OFFSET = 200;

class StringUtil {

  private nameReg: RegExp = new RegExp('[\\u3400-\\u4db5_\\u4e00-\\u9fa5_a-zA-Z1-9]');
  private allChineseReg: RegExp = new RegExp('^[\\u3400-\\u4db5_\\u4e00-\\u9fa5]+$');
  private hasChineseReg: RegExp = new RegExp('[\\u3400-\\u4db5_\\u4e00-\\u9fa5]');
  private hasEnglishReg: RegExp = new RegExp('[a-zA-Z]');
  private hasDigitalReg: RegExp = new RegExp('[1-9]');
  private defaultFormatRules: number[] = [3, 4, 4];
  private static readonly BEGIN_LENGTH: number = 3;
  private static readonly MIN_LENGTH: number = 7;
  private static readonly MASK_LENGTH: number = 4;
  private static readonly MASK_STRING: string = '****';

  /**
   * Get FirstName for contact name.
   *
   * @param name
   * @returns
   */
  public getFirstName(name: string): string {
    if (this.isEmpty(name)) {
      return commonData.STR.WHITE_SPACE;
    }
    if (this.nameReg.test(name)) {
      if (this.allChineseReg.test(name)) {
        return name.substring(name.length - 1, name.length);
      } else if (this.hasChineseReg.test(name)) {
        for (let index = name.length - 1; index >= 0; --index) {
          if (this.hasChineseReg.test(name[index])) {
            return name[index];
          }
        }
      } else if (this.hasEnglishReg.test(name[0])) {
        return name[0].toUpperCase();
      }
    }
    return commonData.STR.WHITE_SPACE;
  }

  /**
   * Calculates the index of the current string after the display space is added.
   * Chinese characters occupy two display spaces, and numbers and English letters occupy one display space.
   *
   * eg.1 textAddSpace('abc', 0, 2)     return 2
   * eg.2 textAddSpace('一二三', 0, 2)   return 1
   * eg.1 textAddSpace('abc', 2, -2)    return 0
   * eg.2 textAddSpace('一二三', 2, -2)  return 1
   *
   * @param text
   * @param index
   * @param space display space
   * @returns
   */
  public textAddSpace(text: string, index: number, space: number): number {
    if (index >= text.length) {
      return index;
    }
    let sign: number = Math.sign(space);
    let remainSpace: number = space;
    for (let i = index + sign * 1; i < text.length; i += sign * 1) {
      let charCode: number = text.charCodeAt(i)
      if (charCode > 0 && charCode < 128) {
        remainSpace -= sign * 1;
      } else {
        remainSpace -= sign * 2;
      }
      if (remainSpace === 0 || Math.sign(remainSpace) !== sign) {
        return i;
      }
    }
    return index + space;
  }

  public countNonAlphabet(str: string): number {
    let match: RegExpMatchArray | null = str.match(NON_ALPHABET_REG);
    return (!match ? 0 : match.length);
  }

  public getSessionNumber(page: number, pinSessionSize: number) {
    let total: number = 0;
    if (page === PAGE_ONE) {
      total = pinSessionSize + PAGE_ONE_OFFSET;
    } else if (page === PAGE_TWO) {
      total = pinSessionSize + PAGE_ONE_OFFSET + PAGE_TWO_OFFSET;
    } else if (page === PAGE_THREE) {
      total = pinSessionSize + PAGE_ONE_OFFSET + PAGE_TWO_OFFSET + PAGE_THREE_OFFSET;
    } else {
      pinSessionSize + PAGE_ONE_OFFSET + (page - PAGE_THREE) * PAGE_MORE_OFFSET +
        PAGE_THREE_OFFSET + PAGE_TWO_OFFSET;
    }
    HiLog.i(TAG, 'getSessionNumber total: ' + total);
    return total;
  }

  /**
   * 获取信息主页数据库查询偏移量
   * @param page 第几页
   * @param pinSessionSize 置顶会话数量
   * @param isNeedPinNumberOffset 偏移量是否需要加置顶数量
   * @param deleteNumber 删除会话数量
   * returns 偏移量
   */
  public getConversionOffsetForSession(page: number, pinSessionSize: number, isNeedPinNumberOffset: boolean,
    deleteNumber: number): number {
    let offset: number = 0;
    HiLog.i(TAG, 'getConversionOffsetForSession pinSessionSize: ' + pinSessionSize +
      ' ,isNeedPinNumberOffset: ' + isNeedPinNumberOffset + ' ,deleteNumber: ' + deleteNumber);
    pinSessionSize = (pinSessionSize < 0) ? 0 : pinSessionSize;
    if (!isNeedPinNumberOffset) {
      if (page === PAGE_ONE) {
        offset = PAGE_ONE_OFFSET;
      } else if (page === PAGE_TWO) {
        offset = PAGE_ONE_OFFSET + PAGE_TWO_OFFSET;
      } else {
        offset = PAGE_ONE_OFFSET + (page - PAGE_THREE) * PAGE_MORE_OFFSET + PAGE_THREE_OFFSET + PAGE_TWO_OFFSET;
      }
    } else {
      if (page === PAGE_ONE) {
        offset = pinSessionSize + PAGE_ONE_OFFSET;
      } else if (page === PAGE_TWO) {
        offset = pinSessionSize + PAGE_ONE_OFFSET + PAGE_TWO_OFFSET;
      } else {
        offset = pinSessionSize + PAGE_ONE_OFFSET + (page - PAGE_THREE) * PAGE_MORE_OFFSET +
          PAGE_THREE_OFFSET + PAGE_TWO_OFFSET;
      }
    }
    offset -= deleteNumber;
    HiLog.i(TAG, 'getConversionOffsetForSession offset: ' + offset);
    return offset;
  }

  //分页偏移量 这里的page1代表第二页
  public getOffsetForSession(page: number): number {
    let offset: number = 0;
    if (page === 1) {
      offset = 0;
    } else if (page === 2) {
      offset = 50;
    } else {
      offset = (page - 3) * 200 + 140 + 50;
    }
    return offset;
  }
  //分页数据 这里的page1代表第二页
  public getLimitForSession(page: number): number {
    let limit: number = 0;
    if (page === 1) {
      limit = 50;
    } else if (page === 2) {
      limit = 140;
    } else {
      limit = 200;
    }
    return limit;
  }

  public getGroupIdsFromResultList(resultList: LooseObject[]): Array<number> {
    let groupIds: Array<number> = [];
    if (resultList != null) {
      for (let item of resultList) {
        if (item.groupId != null) {
          groupIds.push(item.groupId);
        }
      }
    }
    return groupIds;
  }

  public getOffsetForSmsMmsInfo(page: number, contactsNum: number): number {
    return page < 2 ? 0 : ((page - 2) * 300 + 20) * (contactsNum == 0 ? 1 : contactsNum);
  }

  public getLimitForSmsMmsInfo(page: number, contactsNum: number): number {
    return page == 1 ? 20 * (contactsNum == 0 ? 1 : contactsNum) : 300 * (contactsNum == 0 ? 1 : contactsNum);
  }

  public isEmpty(str: string | undefined | null): boolean {
    return  str === undefined || str === null || str.toString().trim() === '';
  }

  /**
   * 字符串去空，包括中间空格
   *
   * @param str str
   * @return trim str
   */
  public trimBlank(str: string): string | undefined {
    if (null === str || str === undefined) {
      return undefined;
    }
    return str.replace(new RegExp(' ', 'g'), '');
  }

  public removeSpace(str: string): string {
    if (this.isEmpty(str)) {
      return '';
    }
    return str.replace(new RegExp('[\\s]', 'g'), '');
  }

  public getPathTail(path: string | undefined): string {
    if (path === undefined || this.isEmpty(path)) {
      return '';
    }
    if (path.indexOf('/') === -1) {
      return '';
    }
    let arr = path.split('/');
    let result = arr[arr.length - 1];
    if (this.isEmpty(result)) {
      return '';
    }
    return result;
  }

  /**
   * Construct text with ellipsis.
   * The effect of TextOverflow.Ellipsis isn't good enough.
   *
   * @param content Full content.
   * @param fontSizeFp Text component fontSize
   * @param maxWidthVp Text component width
   * @param ellipsisEnd Ellipsis in end or start.
   * @returns
   */
  public buildEllipsis(content: string, fontSizeFp: number, maxWidthVp: number, ellipsisEnd: boolean = true): string {
    let originWidthPx: number = MeasureText.measureText({ textContent: content, fontSize: fontSizeFp });
    let maxWidthPx: number = vp2px(maxWidthVp);
    if (originWidthPx < maxWidthPx) {
      return content;
    } else {
      let ellipsisWidth: number = MeasureText.measureText({ textContent: commonData.STR.ELLIPSIS_STR, fontSize: fontSizeFp });
      let contentMaxWidth: number = maxWidthPx - ellipsisWidth;
      let cutIndex: number = 0;
      let cutContent: string = content;
      let cutContentWidthPx: number = 0;
      let leftIndex: number = 0;
      let rightIndex: number = content.length;
      // 使用二分法压缩左右Index范围，当左右Index相差不大于1，即确定了最终的cutIndex
      while (rightIndex - leftIndex > 1) {
        cutIndex = ellipsisEnd ? Math.floor((rightIndex + leftIndex) / 2) : Math.ceil((rightIndex + leftIndex) / 2);
        cutContent = ellipsisEnd ? content.substring(0, cutIndex) : content.substring(cutIndex, content.length);
        cutContentWidthPx = MeasureText.measureText({ textContent: cutContent, fontSize: fontSizeFp });
        // 比较裁切结果，再依据结果”压缩“左右Index的范围
        if (cutContentWidthPx > contentMaxWidth) {
          if (ellipsisEnd) {
            rightIndex = cutIndex;
          } else {
            leftIndex = cutIndex;
          }
        } else {
          if (ellipsisEnd) {
            leftIndex = cutIndex;
          } else {
            rightIndex = cutIndex;
          }
        }
      }
      // Final check again.
      if (cutContentWidthPx > contentMaxWidth) {
        cutContent = ellipsisEnd ? content.substring(0, cutIndex - 1) : content.substring(cutIndex + 1, content.length);
      }
      if (ellipsisEnd) {
        return cutContent + commonData.STR.ELLIPSIS_STR;
      } else {
        return commonData.STR.ELLIPSIS_STR + cutContent;
      }
    }
  }

  /**
   * Formats a string with spaces
   *
   * @param text
   * @param formatRules rules
   * @returns
   */
  public formatWithSpace(text: string, formatRules: number[]): string {
    if (this.isEmpty(text)) {
      return commonData.STR.EMPTY_STR;
    }
    // Calculate the index of the space
    let spaceIndexes: number[] = [];
    let sum: number = 0;
    for (let i = 0; i < formatRules.length; i++) {
      sum += formatRules[i];
      spaceIndexes.push(sum + i);
    }
    spaceIndexes.pop();
    // Build a formatted string
    let chars: string[] = [];
    for (let char of text) {
      if (!this.isEmpty(char)) {
        if (spaceIndexes.indexOf(chars.length) !== -1) {
          chars.push(commonData.STR.WHITE_SPACE);
        }
        chars.push(char);
      }
    }
    return chars.join(commonData.STR.EMPTY_STR).trim();
  }

  /***
   * Format number with space and ignore em tag.
   * e.g.
   * formatWithSpaceIgnoreEmTag('1234<em>56</em>78901', [3, 4, 4]) => '123 4<em>56</em>7 8901'
   *
   * @param text
   * @param formatRules rules
   * @returns
   */
  public formatWithSpaceIgnoreEmTag(text: string, formatRules: number[] = this.defaultFormatRules): string {
    if (this.isEmpty(text)) {
      return commonData.STR.EMPTY_STR;
    }
    // Remove space
    text = text.replace(new RegExp('[\\s]', 'g'), '');
    // Calculate the index of the space
    let spaceIndexes: number[] = [];
    let sum: number = 0;
    for (let i = 0; i < formatRules.length; i++) {
      sum += formatRules[i];
      spaceIndexes.push(sum);
    }
    spaceIndexes.pop();
    // Build a formatted string
    let chars: string[] = [];
    let numberCount: number = 0;
    for (let i = 0; i < text.length; i++) {
      let char: string = text.charAt(i);
      chars.push(char);
      if (!isNaN(parseInt(char))) {
        numberCount ++;
        if (spaceIndexes.indexOf(numberCount) !== -1) {
          chars.push(commonData.STR.WHITE_SPACE);
        }
      }
    }
    return chars.join(commonData.STR.EMPTY_STR).trim();
  }

  public convertResourceToString(resourceName: Resource, context: Context): string {
    let resourceString = '';
    if (context == null) {
      HiLog.e(TAG, `convertResourceToString context is null`);
      return resourceString;
    }
    if (context.resourceManager == null) {
      HiLog.e(TAG, `convertResourceToString resourceManager is null`);
      return resourceString;
    }
    try {
      HiLog.i(TAG, `convertResourceToString getStringSync id`);
      resourceString = context.resourceManager.getStringSync(resourceName.id);
    } catch (e) {
      HiLog.e(TAG, `getStringSync err e : ` + JSON.stringify(e));
    }
    return resourceString;
  }

  /**
   * Mask the sensitive string.
   *
   * @param str The string to be marked.
   * @returns The masked string.
   */
  public mask(str: string) : string {
    if (str === undefined || str === null) {
      return '';
    }
    if (str.length < StringUtil.MASK_LENGTH) {
      return str;
    }
    return StringUtil.MASK_STRING + str.slice(str.length - StringUtil.MASK_LENGTH);
  }

  /**
   * 对手机号进行脱敏，主要用于打印日志
   * 1. 当字符串长度 len：[0~ 4)时, 返回原值
   * 2. 当字符串长度 len：[4~ 7]时，保留最后4位，  后面加*，如 ****xxx
   * 4. 当字符串长度 len：[7~N]时, 保留前3位后4位，前面加*，如 xxx****xxxx
   *
   * @param str 字符串
   * @returns 脱敏后的字符串
   */
  public phoneMask(str: string): string {
    if (this.isEmpty(str)) {
      return '';
    }
    if (str.length < StringUtil.MASK_LENGTH) {
      return str;
    }
    let tailStr = StringUtil.MASK_STRING + str.slice(str.length - StringUtil.MASK_LENGTH);
    if (str.length <= StringUtil.MIN_LENGTH) {
      return tailStr;
    }
    return str.substring(0, StringUtil.BEGIN_LENGTH) + tailStr;
  }

  /**
   * 脱敏文件名
   *
   * @param fileName 文件名
   * @returns 脱敏后的文件名
   */
  public maskFileName(fileName: string): string {
    if (!fileName) {
      return fileName;
    }
    const fileLength = fileName.length;
    const prefixLength = 4;
    const suffixLength = 6;
    if (fileLength <= prefixLength + suffixLength) {
      return '***';
    }
    const prefix = fileName.substring(0, prefixLength);
    const suffix = fileName.substring(fileLength - suffixLength);
    return `${prefix}***${suffix}`;
  }

  /**
   * 判断当前两个字符串是否相互包含
   * 如果电话号码中包含联系人名称（contactName），或联系人名称中包含电话号啊，比如自发自收，电话号码是+86 xxxx，联系人名称是 xxxx
   * @param str1 联系人名称
   * @param str2 电话号码
   * @returns
   */
  public isContain(str1: string, str2: string): boolean {
    if (this.isEmpty(str1) || this.isEmpty(str2)) {
      return false;
    }
    if (str1.includes(str2) || str2.includes(str1)) {
      return true;
    }
    return false;
  }

}

// Singleton
export default new StringUtil();


export const isJSONString = (str: string) => {
  if (!str) {
    return false;
  }
  if (typeof str === 'string') {
    try {
      JSON.parse(str);
      return true;
    } catch (e) {
      HiLog.e(TAG, `isJSONString error ${e?.code} ${e?.message}`);
      return false;
    }
  }
  return false;
}

/**
 * 判断该字符串是否能被JSON解析成对象
 */
export const isObjectJSONString = (str: string | undefined) => {
  if (!str) {
    return false;
  }
  if (typeof str === 'string') {
    try {
      let temp = JSON.parse(str) as MyAny;
      if (!temp || !isObjectType(temp)) {
        return false;
      }
      return true;
    } catch (e) {
      HiLog.e(TAG, `isObjectJSONString error ${e?.code} ${e?.message}`);
      return false;
    }
  }
  return false;
}　