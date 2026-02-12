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
import { messageType } from '../../pages/conversationlist/conversationListController';
import HiLog from '../../utils/HiLog';


const TAG: string = 'ThreadObjectUtils';

/**
 * 会话对象操作类
 */
export class ThreadObjectUtils {
  /**
   * 将json格式强转的messageType，转换成对应的class数组
   *
   * @param source 原数组
   * @returns 对应的class数组
   */
  public static jsonToObjArray(source: messageType[]): messageType[] {
    if (!source) {
      return [];
    }
    HiLog.i(TAG, `jsonToObjArray enter ${source.length}`);
    let res: messageType[] = [];
    try {
      if (Array.isArray(source)) {
        for (let i = 0; i < source.length; i++) {
          res.push(new messageType());
          ThreadObjectUtils.deepCopyThread(res[i], source[i]);
        }
      }
    } catch (err) {
      HiLog.e(TAG, ` jsonToObjArray failed, code is ${err?.code}, message is ${err?.message}`);
    }
    return res;
  }

  /**
   * 会话对象群组深拷贝
   *
   * @param target 目标对象数组
   * @param source 源对象数组
   */
  public static deepCopyThreadArray(target: messageType[], source: messageType[]): void {
    if (!source || !target) {
      return;
    }
    HiLog.i(TAG, `deepCopyThreadArray enter ${source.length}`);
    try {
      if (Array.isArray(source)) {
        target = target || [];
        for (let i = 0; i < source.length; i++) {
          if (i >= target.length) {
            HiLog.i(TAG, ` deepCopyThreadArray push ${i} `);
            target.push(new messageType());
          }
          ThreadObjectUtils.deepCopyThread(target[i], source[i]);
        }
        let offset: number = (target.length - source.length);
        if (offset > 0) {
          HiLog.i(TAG, `deepCopyThreadArray offset ${offset}`);
          target.splice(target.length - offset, offset);
        }
      }
    } catch (err) {
      HiLog.e(TAG, ` deepCopyThreadArray failed, code is ${err?.code}, message is ${err?.message}`);
    }
  }

  /**
   * 会话对象群组区间深拷贝
   *
   * @param target 目标对象数组
   * @param source 源对象数组
   * @param startIndex  需要刷新的头节点index
   * @param count 需要刷新的个数
   */
  public static deepCopyThreadArrayInterval(target: messageType[], source: messageType[], startIndex: number,
    count: number): void {
    if (!source || !target) {
      return;
    }
    HiLog.i(TAG, `deepCopyThreadArrayInterval enter ${target.length},${source.length},${startIndex},${count}`);
    try {
      if (Array.isArray(source)) {
        target = target || [];
        for (let i = 0; i < count; i++) {
          ThreadObjectUtils.deepCopyThread(target[startIndex+i], source[i]);
        }
      }
    } catch (err) {
      HiLog.e(TAG, ` deepCopyThreadArrayInterval failed, code is ${err?.code}, message is ${err?.message}`);
    }
  }

  /**
   * 会话对象深拷贝
   *
   * @param target 目标对象
   * @param source 源对象
   */
  public static deepCopyThread(target: messageType, source: messageType): void {
    if (!source || !target) {
      return;
    }
    try {
      target.mmsSource = source.mmsSource;
      target.isMsm = source.isMsm;
      target.msgContent = source.msgContent;
      target.name = source.name;
      target.contactsNum = source.contactsNum;
      target.content = source.content;
      target.countOfUnread = source.countOfUnread;
      target.icon = source.icon;
      target.smsType = source.smsType;
      target.isCbChecked = source.isCbChecked;
      target.sendingFailed = source.sendingFailed;
      target.telephone = source.telephone;
      target.telephoneFormat = source.telephoneFormat;
      target.contactName = source.contactName;
      target.threadId = source.threadId;
      target.timeMillisecond = source.timeMillisecond;
      target.isDraft = source.isDraft;
      target.time = source.time;
      target.messageCount = source.messageCount;
      target.hasMms = source.hasMms;
      target.hasAttachment = source.hasAttachment;
      target.detailTime = source.detailTime;
      target.portraitColor = source.portraitColor;
      target.isDelShow = source.isDelShow;
      target.itemLeft = source.itemLeft;
      target.yellowPageId = source.yellowPageId;
      target.hasYellowPageIcon = source.hasYellowPageIcon;
      target.photoFirstNames = source.photoFirstNames;
      target.contactsNameList = source.contactsNameList;
      target.photoSize = source.photoSize;
      target.isFavorite = source.isFavorite;
      target.contactId = source.contactId;
      target.rawContactId = source.rawContactId;
      target.isMultipleSelectState = source.isMultipleSelectState;
      target.isDisplayDraftText = source.isDisplayDraftText;
      target.isReceive = source.isReceive;
      target.startTime = source.startTime;
      target.groupId = source.groupId;
      target.id = source.id;
      target.msgId = source.msgId;
      target.mmsPdu = source.mmsPdu;
      target.hasReport = source.hasReport;
      target.fullDate = source.fullDate;
      target.timeOfSms = source.timeOfSms;
      target.week = source.week;
      target.fullDateParams = source.fullDateParams;
      target.timeOfSmsParams = source.timeOfSmsParams;
      target.contentType = source.contentType;
      target.isRcs = source.isRcs;
      target.senderNumber = source.senderNumber;
      target.itemTime = source.itemTime;
      target.msgTitle = source.msgTitle;
      target.isChatbotMessage = source.isChatbotMessage;
      target.chatbotAvatarUri = source.chatbotAvatarUri;
      target.rcsType = source.rcsType;
      target.blockedType = source.blockedType;
      target.pinningTime = source.pinningTime;
      target.chatbotPageIcon = source.chatbotPageIcon;
      target.cachedComInfoUri = source.cachedComInfoUri;
      target.comInfoUri = source.comInfoUri;
    } catch (err) {
      HiLog.e(TAG, `deepCopyThread failed, code is ${err?.code}, message is ${err?.message}`);
    }
  }
}