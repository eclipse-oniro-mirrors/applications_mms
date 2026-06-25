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
import {
  BotMessage,
  ChatbotCardMessageType,
  PersistentMenu,
  RichCardMessage,
  BotDetails,
  ChatbotDirectory
} from './ChatbotEntitys';
import LooseObject, { isObjectType, MyAny } from '../../data/LooseObject';
import { plainToClass } from 'class-transformer';
import { cryptoFramework } from '@kit.CryptoArchitectureKit';
import { buffer, taskpool } from '@kit.ArkTS';
import { fileIo as fs } from '@kit.CoreFileKit';

/**
 * Decimal to hexadecimal
 * @param {*} val  decimal integer
 * @param {*} byteNum  How many bytes of hexadecimal,1 byte = 2 hexadecimal characters
 */
export function parseHex(val: number, byteNum: number): string {
  let num = BigInt(Number.parseInt(String(val)));
  let hexStr = '';
  let hexStrLength = byteNum * 2;
  let min = BigInt(-1 * Math.pow(2, 8 * byteNum - 1));
  let max = BigInt(Math.pow(2, 8 * byteNum - 1) - 1);
  if (num < min || num > max) {
    HiLog.w(TAG, `out of range,min is ${min},max is ${max},but val is ${num}.`);
    return '';
  } else if (num < 0) { //legal negative number
    //two's complement
    hexStr = (BigInt(Math.pow(2, 8 * byteNum)) + num).toString(16);
    if (hexStr.length < hexStrLength) {
      hexStr = 'f'.repeat(hexStrLength - hexStr.length) + hexStr;
    }
  } else { //legal positive number
    hexStr = num.toString(16);
    if (hexStr.length < hexStrLength) {
      hexStr = '0'.repeat(hexStrLength - hexStr.length) + hexStr;
    }
  }
  return hexStr;
}

const getSHA256String = (b: Uint8Array): string => {
  let resultString = '';
  let hex: string = '';
  b.forEach((bt) => {
    let tempNum = (bt & 0xFF);
    hex = (tempNum >= 0) ? tempNum.toString(16) : parseHex(tempNum, 4);
    if (hex.length < 2) {
      resultString += 0;
    }
    resultString += hex;
  })
  return resultString;
}
const TAG = 'ChatbotUtils';

export class ChatbotUtils {
  public static handlePersistentMenu(content: string): PersistentMenu | undefined {
  try {
    if (!content) {
      HiLog.e(TAG, `handlePersistentMenu: param is empty`);
      return undefined;
    }
    const jsonObject:BotDetails = JSON.parse(content);
    if (!jsonObject) {
      HiLog.e(TAG, `handlePersistentMenu: jsonObject is empty or is not Object Type`);
      return undefined;
    }

    const botMsgObj: BotDetails = plainToClass(BotDetails, jsonObject, { excludeExtraneousValues: true })
    return botMsgObj?.persistentMenu;
  } catch (e) {
    HiLog.e(TAG, 'ChatbotUtils error: ' + JSON.stringify(e));
    return undefined;
  }
}

  public static parseBotDetails(jsonPayload: string): BotDetails | null {
    let botMessage: BotDetails | null = null;
    if (!jsonPayload) {
      HiLog.e(TAG, `parseBotMessage: param is empty`);
      return botMessage;
    }
    try {
      let expiresArr = jsonPayload.split('expires')
      expiresArr[0] = expiresArr[0].replaceAll('-', ' ')
      let arr = expiresArr[0].split(' ')
      for (let i = 0; i < arr.length; i++) {
        arr[i] = arr[i].charAt(0).toUpperCase() + arr[i].slice(1)
      }
      expiresArr[0] = arr.join('')
      jsonPayload = expiresArr.join('expires');
      const jsonObject: BotDetails = JSON.parse(jsonPayload);
      if (!jsonObject) {
        HiLog.e(TAG, `parseBotMessage: jsonObject is empty or is not Object Type`);
        return null;
      }
      if (jsonObject.botinfo) {
        const botMsgObj: BotDetails = plainToClass(BotDetails, jsonObject, { excludeExtraneousValues: true })
        return botMsgObj;
      }

    } catch (e) {
      HiLog.e(TAG, 'parseBotMessage error: ' + JSON.stringify(e));
    }
    return botMessage;
  }

  private static setSuggestionType(jsonObject: LooseObject, botMsgObj: BotMessage) {
    if (jsonObject.suggestions) {
      if (botMsgObj && botMsgObj.suggestions) {
        for (let suggestion of botMsgObj.suggestions) {
          suggestion.trafficType = botMsgObj.TrafficType;
          suggestion.contributionId = botMsgObj.contributionId;
        }
      }
    }
  }

  /**
   * Parse json String to BotMessage Entity
   *
   * @param jsonPayload the json result get from chatbot server
   */
  public static parseBotMessage(jsonPayload: string): BotMessage | null {
    let botMessage: BotMessage | null = null;
    if (!jsonPayload) {
      HiLog.e(TAG, `parseBotMessage: param is empty`);
      return botMessage;
    }
    try {
      const tempObject: MyAny = JSON.parse(jsonPayload);
      if (!tempObject || !isObjectType(tempObject)) {
        HiLog.e(TAG, `parseBotMessage: jsonObject is empty or is not Object Type`);
        return null;
      }
      const jsonObject = tempObject as LooseObject;
      if (jsonObject.message) {
        const botMsgObj: BotMessage = plainToClass(BotMessage, jsonObject, { excludeExtraneousValues: true })
        ChatbotUtils.setSuggestionType(jsonObject as LooseObject, botMsgObj);
        return botMsgObj;
      }

      if (jsonObject.suggestions) {
        botMessage = plainToClass(BotMessage, jsonObject, { excludeExtraneousValues: true });
        if (botMessage && botMessage.suggestions) {
          for (let suggestion of botMessage.suggestions) {
            suggestion.trafficType = botMessage.TrafficType;
            suggestion.contributionId = botMessage.contributionId;
          }
        }
      } else {
        botMessage = new BotMessage();
      }

      if (botMessage && (jsonObject.generalPurposeCard || jsonObject.generalPurposeCardCarousel)) {
        const richCardMessage: RichCardMessage = plainToClass(RichCardMessage, jsonObject, {
          excludeExtraneousValues: true
        });
        botMessage.message = richCardMessage;
      }
      return botMessage;
    } catch (e) {
      HiLog.e(TAG, 'parseBotMessage error: ' + JSON.stringify(e));
      botMessage = null;
    }
    return botMessage;
  }

  public static getChatbotCardType = (botMessage: BotMessage) => {
    let cardType: ChatbotCardMessageType | null = null;
    if (botMessage?.message?.generalPurposeCard) {
      cardType = ChatbotCardMessageType.SINGLE_CARD;
    } else if (botMessage?.message?.generalPurposeCardCarousel) {
      cardType = ChatbotCardMessageType.MULTI_CARD;
    }
    return cardType;
  }
  public static parsePersistMenuMessage = (jsonPayload: string) => {
    let menu: PersistentMenu | null = null;
    if (!jsonPayload) {
      return menu;
    }
    try {
      const jsonObject: MyAny = JSON.parse(jsonPayload);
      if (!jsonObject || !isObjectType(jsonObject)) {
        HiLog.e(TAG, `parsePersistMenuMessage: jsonObject is empty or is not Object Type`);
        return null;
      }
      menu = plainToClass(PersistentMenu, jsonObject, { excludeExtraneousValues: true });
    } catch (e) {
      HiLog.e(TAG, 'parse parsePersistMenuMessage json exception: ' + JSON.stringify(e));
    }
    return menu;
  }

  /***
   * parse string file name to md5
   *
   * @param originString origin filename
   * @return string md5 str
   */
  public static getEncryptValue(originString: string): string {
    if (!originString) {
      return '';
    }
    try {
      let md = cryptoFramework.createMd('SHA256');
      md.updateSync({ data: new Uint8Array(buffer.from(originString, 'utf-8').buffer) });
      let mdResult = md.digestSync();
      let hexStr: string = getSHA256String(mdResult.data);
      return hexStr.toUpperCase();
    } catch (e) {
      HiLog.e(TAG, 'getEncryptValue error: ' + JSON.stringify(e));
    }
    return '';
  }

  /**
   * check whether filename invalid
   *
   * @param name text filename
   * @return true invalid name
   */
  public static isValidName(name: string): boolean {
    if (!name) {
      return false;
    }
    return true;
  }

  public static isExistFile = (path: string): boolean => {
    try {
      return fs.accessSync(path);
    } catch (e) {
      HiLog.e(TAG, 'isExistFile error: ' + JSON.stringify(e));
      return false;
    }
  }
  public static isChatbotCardMessageContent = (jsonObject: LooseObject): boolean => {
    if ((jsonObject.message && isObjectType(jsonObject.message)) ||
      (jsonObject.message?.generalPurposeCard && isObjectType(jsonObject.message?.generalPurposeCard)) ||
      (jsonObject.message?.generalPurposeCardCarousel &&
      isObjectType(jsonObject.message?.generalPurposeCardCarousel))) {
      return true;
    }
    return false;
  }

  /**
   * 是否为Rcs应用号号码
   * @param param 需检测的号码
   * @returns { boolean } 检测结果
   */
  public static isChatbotNumber(param: string | undefined): boolean {
    return Boolean(param && param.startsWith('sip:') && param.includes('@botplatform'));
  }
  public static getTelephoneFromServiceId = (serviceId: string) => {
    if (ChatbotUtils.isChatbotNumber(serviceId)) {
      const start = serviceId.indexOf(':') + 1; // 跳过sip:
      const end = serviceId.lastIndexOf('@botplatform');
      if (start === -1 || end === -1) {
        return serviceId;
      }
      return serviceId.slice(start, end);
    } else {
      return serviceId;
    }
  }

  /**
   * 获取增信息应用号的serviceId中的数字号码
   * @param serviceId 应用号的服务器ID
   * @param isChatbotNumber 是否是Rcs应用号号码
   * @returns { string } 应用号的serviceId中的数字号码
   */
  public static getTelephoneFromChatbotServiceId(serviceId: string, isChatbotNumber: boolean): string {
    if (isChatbotNumber) {
      const start = serviceId.indexOf(':') + 1; // 跳过sip:
      const end = serviceId.lastIndexOf('@botplatform');
      if (start === -1 || end === -1) {
        return serviceId;
      }
      return serviceId.slice(start, end);
    } else {
      return serviceId;
    }
  }
  public static parseChatbotDirectory = (jsonPayload: string) => {
    let menu: ChatbotDirectory | null = null;
    if (!jsonPayload) {
      return menu;
    }
    try {
      const jsonObject: MyAny = JSON.parse(jsonPayload);
      if (!jsonObject || !isObjectType(jsonObject)) {
        HiLog.e(TAG, `parseChatbotDirectory: jsonObject is empty or is not Object Type`);
        return null;
      }
      menu = plainToClass(ChatbotDirectory, jsonObject, { excludeExtraneousValues: true });
    } catch (e) {
      HiLog.e(TAG, 'parse parseChatbotDirectory json exception: ' + JSON.stringify(e));
    }
    return menu;
  }

  /**
   * 获取增强信息应用号卡片的消息内容的概要，用于主页会话列表项和骚扰拦截消息记录中的消息内容展示
   * @param context Context
   * @param msgContent 应用号卡片消息内容
   * @returns 应用号卡片消息内容的概要
   */
  public static getChatbotCardMessageSummary(context: Context, msgContent: BotMessage | undefined): string {
    let summary = `${context.resourceManager.getStringSync(
      $r('app.string.chatbot_rich_media_card_in_conversation_list').id)}`;
    if (!msgContent?.message) {
      return summary;
    }

    if (msgContent.message.generalPurposeCard?.content?.title) {//单卡片消息
      summary = msgContent.message.generalPurposeCard.content.title;
    } else if (msgContent.message.generalPurposeCardCarousel?.content?.[0]?.title) {//多卡片消息，取第一个卡片的标题
      summary = msgContent.message.generalPurposeCardCarousel.content[0].title;
    }
    return summary;
  }
}

export function stringToUint8Array(str: string) {
  let arr: number[] = [];
  for (let i = 0, j = str.length; i < j; ++i) {
    arr.push(str.charCodeAt(i));
  }
  let tmpUint8Array = new Uint8Array(arr);
  return tmpUint8Array;
}

/**
 * 中止任务池中的长时任务，在长时任务执行完成后调用。中止后，执行长时任务的线程可能会被回收。
 * @param task 需要中止的长时任务。
 */
export function terminateLongTask(task: taskpool.LongTask): void {
  try {
    if (task) {
      taskpool.terminateTask(task);
    }
  } catch (e) {
    HiLog.e(TAG, `terminateTask error, code: ${e?.code} ${e?.message}`);
  }
}