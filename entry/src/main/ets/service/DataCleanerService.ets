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

import HiLog from '../utils/HiLog';
import SharedPreferencesUtils from '../utils/SharedPreferencesUtils';
import commonData from '../data/commonData';
import LooseObject from '../data/LooseObject';
import { messageType } from '../pages/conversationlist/conversationListController';
import ConversationService from './ConversationService';
import ConversationListService from './ConversationListService';
import { ValuesBucket } from '@kit.ArkData';

const TAG: string = 'DataCleanerService';
const KEY_NORAML: string = 'last_clean_unread_time_normal';
const KEY_INFO: string = 'last_clean_unread_time_info';
const CLEAN_INTEVAL: number = commonData.int.MILLISECOND_OF_ONE_MONTH;

// 用于数据清理
export default class DataCleanerService {
  private static sInstance: DataCleanerService;
  private lastNormalCleanTime: number = -1;
  private lastInfoCleanTime: number = -1;

  static getInstance() {
    if (DataCleanerService.sInstance == undefined) {
      DataCleanerService.sInstance = new DataCleanerService();
    }
    return DataCleanerService.sInstance;
  }

  static getTestInstance() {
    return new DataCleanerService();
  }

  constructor() {
    this.lastNormalCleanTime = SharedPreferencesUtils.getFromPreferences(KEY_NORAML, -1) as number;
    this.lastInfoCleanTime = SharedPreferencesUtils.getFromPreferences(KEY_INFO, -1) as number;
    HiLog.i(TAG, 'new DataCleanerService, lastNormalCleanTime:' + this.lastNormalCleanTime +
      ', lastInfoCleanTime:' + this.lastInfoCleanTime);
  }

  /**
   * 未读数据表间一致性处理，清理不一致数据
   *
   * 处理原则：以短信详情表为准计算未读数，如果session表中unreadcount不符，则更新session表
   * 不单独查询会话列表，基于传入的会话列表，查找会话对应的短信详情未读数，与会话的unreadcount进行比对
   *
   * @param messageList 需要清理的会话列表
   * @param type 会话列表类型 0: 普通会话， 1: 通知会话
   * @param callback 回调方法
   */
  public unReadClean(context: Context, messageList: Array<messageType>, type: number, callback: Function): void {
    HiLog.i(TAG, 'UnReadDataClean: unReadClean enter');
    const currentTime: number = Date.now();

    // 没清理过或当前时间已超过上次清理时间一个月
    if (type == 0) {
      if (this.lastNormalCleanTime == -1 || (currentTime - this.lastNormalCleanTime) >= CLEAN_INTEVAL) {
        this.excuteUnReadDataClean(context, messageList, type, callback);
      }
    } else if (type == 1) {
      if (this.lastInfoCleanTime == -1 || (currentTime - this.lastInfoCleanTime) >= CLEAN_INTEVAL) {
        this.excuteUnReadDataClean(context, messageList, type, callback);
      }
    } else {
      HiLog.w(TAG, 'UnReadDataClean: type uncorrect.');
      return;
    }
  }

  private excuteUnReadDataClean(context: Context, messageList: Array<messageType>,
    type: number, callback: Function): void {
    HiLog.i(TAG, 'UnReadDataClean: excuteUnReadDataClean enter');
    let sessionUnreadMap: Map<number, number> = new Map();
    let threadIds: Array<number> = [];
    for (let msg of messageList) {
      threadIds.push(msg.threadId);
      sessionUnreadMap.set(msg.threadId, msg.countOfUnread);
    }

    let needUpate: boolean = false;
    // 根据会话ids查询短信详情未读数
    let actionData: LooseObject = {};
    actionData.threadIds = threadIds;
    ConversationService.getInstance().querySmsMmsInfoByConditionAll(context, actionData, (res: LooseObject) => {
      if (res.code === commonData.int.SUCCESS) {
        HiLog.i(TAG, `UnReadDataClean: querySmsMmsInfoByCondition success`);
        // 统计每个会话的未读短信详情数
        if (res.abilityResult && res.abilityResult.length > 0) {
          let unreadCountMap: Map<number, number> = new Map();
          let list: Array<LooseObject> = res.abilityResult;
          list.forEach((message) => {
            let count = unreadCountMap.get(message.sessionId);
            if (count == undefined) {
              count = 0;
            }
            if (message.isRead == 0) {
              count++;
            }
            unreadCountMap.set(message.sessionId, count);
          })
          unreadCountMap.forEach((value: number, key: number) => {
            // 短信详情未读数与会话中未读数不一致，将会话中未读数更新为一致
            if (sessionUnreadMap.get(key) != value) {
              HiLog.i(TAG, 'UnReadDataClean: find inconsistent session, sessionUnreadCount: ' +
                sessionUnreadMap.get(key) + ', detailUnreadCount: ' + value);
              let updateActionData: LooseObject = {};
              updateActionData.threadId = key;

              let valueBucket: ValuesBucket = {
                unread_count: value
              };
              ConversationListService.getInstance().updateSessionByCondition(context, updateActionData, valueBucket,
                (res: LooseObject) => {
                if (res.code == commonData.int.FAILURE) {
                  HiLog.w(TAG, 'UnReadDataClean: updateSessionByCondition fail, threadId:' + updateActionData.threadId);
                }
              }, true);
              needUpate = true;
            }
          })
          if (callback) {
            callback(needUpate);
          }
        }
      } else {
        HiLog.i(TAG, 'UnReadDataClean: querySmsMmsInfoByCondition fail');
      }
    });
    // 不论清理是否成功均更新清理时间，防止不断重复触发清理
    if (type == 0) {
      SharedPreferencesUtils.saveToPreferences(KEY_NORAML, Date.now());
      this.lastNormalCleanTime = Date.now();
    } else if (type == 1) {
      SharedPreferencesUtils.saveToPreferences(KEY_INFO, Date.now());
      this.lastInfoCleanTime = Date.now();
    } else {
      HiLog.w(TAG, 'UnReadDataClean: type uncorrect.');
    }
  }
}