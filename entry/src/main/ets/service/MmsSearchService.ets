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

import HiLog from '../utils/HiLog';
import ConversationListService from '../service/ConversationListService';
import ConversationService from './ConversationService';
import ContactsService from './ContactsService';
import common from '../data/commonData';
import LooseObject from '../data/LooseObject';
import { BusinessError } from '@ohos.base';
import { GlobalContext } from '../MainAbility/GlobalHelper';
import myCommon from '@ohos.app.ability.common';
import ConversationListResponse from '../model/conversationlist/ConversationListResponse';
import { ConversationListInfo } from '../model/conversationlist/ConversationListInfo';

export interface resType {
  code: number,
  response: LooseObject | PromiseLike<LooseObject>,
  abilityResult: LooseObject[],
}

const TAG: string = 'MmsSearchService';

export default class MmsSearchService {
  private static sInstance: MmsSearchService;

  static getInstance() {
    if (MmsSearchService.sInstance == null) {
      MmsSearchService.sInstance = new MmsSearchService();
    }
    return MmsSearchService.sInstance;
  }

  async searchMessage(context: Context, object: LooseObject, callback: Function) {
    let sessionListPromise: Promise<LooseObject> = new Promise((resolve, reject) => {
      this.searchBySession(context, object, (res: resType) => {
        if (res.code === common.int.SUCCESS) {
          resolve(res.response);
        } else {
          reject(res.code);
        }
      });
    });

    let messageListPromise: Promise<LooseObject> = new Promise((resolve, reject) => {
      this.searchByContent(context, object, (res: resType) => {
        if (res.code === common.int.SUCCESS) {
          resolve(res.response);
        } else {
          reject(res.code);
        }
      });
    });

    let resultMap: LooseObject = {};
    let result: LooseObject = {};
    Promise.all<LooseObject>([sessionListPromise, messageListPromise]).then((res) => {
      HiLog.i(TAG, 'search message success');
      result.code = common.int.SUCCESS;
      resultMap.sessionList = res[0];
      resultMap.messageList = res[1];
      result.resultMap = resultMap;
      callback(result);
    }).catch((err: BusinessError) => {
      HiLog.i(TAG, 'search message error: ' + JSON.stringify(err));
      result.code = common.int.FAILURE;
      callback(result);
    });
  }

  private searchBySession(context: Context, object: LooseObject, callback: Function) {
    HiLog.i(TAG, 'search message by session');
    let likeTelephonePromise: LooseObject = this.querySessionLikeTelephone(context, object);
    let contactPromise: LooseObject = this.querySessionByContact(context, object);
    let result: LooseObject = {};
    Promise.all<LooseObject>([likeTelephonePromise, contactPromise]).then(res => {
      HiLog.i(TAG, 'search by session success');
      result.code = common.int.SUCCESS;
      let likeTelephoneSessionList: Array<LooseObject> = res[0].sessionList;
      let contactSessionList: Array<LooseObject> = res[1].sessionList;
      let list = likeTelephoneSessionList.filter(item => {
        return contactSessionList.every(session => {
          return item.id != session.id;
        })
      });
      list = contactSessionList.concat(list);
      list.sort((sessionA, sessionB) => {
        return sessionB.timeMillisecond - sessionA.timeMillisecond;
      });
      result.response = this.dealSessionResult(list);
      callback(result);
    }).catch((err: BusinessError) => {
      HiLog.i(TAG, 'search by session error: ' + JSON.stringify(err));
      result.code = common.int.FAILURE;
      callback(result);
    });
  }

  async querySessionLikeTelephone(context: Context, object: LooseObject): Promise<LooseObject> {
    let sessionPromise: Promise<LooseObject> = new Promise((resolve, reject) => {
      ConversationListService.getInstance().querySessionLikeTelephone(object, (res: LooseObject) => {
        HiLog.i(TAG, 'query session like telephone response: ' + res.code);
        let result: LooseObject = {};
        result.sessionList = [];
        result.code = common.int.SUCCESS;
        if (res.sessionList && res.sessionList.length > 0) {
          result.sessionList = res.sessionList;
        }
        resolve(result);
      }, context);
    });
    return sessionPromise;
  }

  async querySessionByContact(context: Context, object: LooseObject): Promise<LooseObject> {
    let input: string = object.input.trim();
    let actionData: LooseObject = {};
    actionData.searchName = input;
    actionData.hasDelete = '0';
    let sessionPromise: Promise<LooseObject> = new Promise((resolve, reject) => {
      ContactsService.getInstance().queryContactDataByCondition(actionData, (res: LooseObject) => {
        HiLog.i(TAG, 'query session by contact data condition response: ' + res.code);
        let result: LooseObject = {};
        result.sessionList = [];
        result.code = common.int.SUCCESS;
        if (res.abilityResult && res.abilityResult.length > 0) {
          ConversationListService.getInstance().querySessionByTelephones(res.abilityResult, object,
            (session: Record<string, Object>) => {
            HiLog.i(TAG, 'query session by contact telephones response');
            result.sessionList = session.sessionList;
            resolve(result);
          }, context);
        } else {
          resolve(result);
        }
      }, context);
    });
    return sessionPromise;
  }

  private dealSessionResult(list: Array<LooseObject>): Array<LooseObject> {
    let session: Array<LooseObject> = [];
    for (let index = 0; index < list?.length; index ++) {
      let item = list[index];
      if (index === 0) {
        item.isSessionFirst = true;
      } else {
        item.isSession = true;
      }
      if (item.name !== '') {
        item.nameFormatter = item.name + '<' + item.telephoneFormat + '>';
      }
      session.push(item);
    }
    return session;
  }

  private searchByContent(context: Context, object: LooseObject, callback: Function) {
    HiLog.i(TAG, 'search message by content');
    let actionData: LooseObject = {};
    actionData.content = object.input;
    if (object.smsType === 1) {
      actionData.smsType = object.smsType;
    }

    ConversationService.getInstance().querySmsMmsInfoByCondition(context, actionData, (res: resType) => {
      HiLog.i(TAG, 'querySmsMmsInfoByCondition success');
      let result: LooseObject = {};
      if (res.code == common.int.SUCCESS) {
        result.code = common.int.SUCCESS;
        let resultList = this.dealResult(res.abilityResult);
        let messageList = this.dealGroup(resultList.messageList);
        if (messageList.length === 0) {
          result.response = [];
          callback(result);
        } else {
          ConversationListService.getInstance().dealContactsName(resultList.telephones, actionData, messageList,
            (contactList: Record<string, Object>) => {
            result.response = contactList;
            callback(result);
          }, GlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext);
        }
      } else {
        result.code = common.int.FAILURE;
        HiLog.i(TAG, 'querySmsMmsInfoByCondition, failed');
        callback(result);
      }
    });
  }

  private dealGroup(mmsList: Array<LooseObject>): Array<LooseObject> {
    if (!mmsList || mmsList.length === 0) {
      return [];
    }
    let resultList: Array<LooseObject> = [];
    let group: Record<string, LooseObject> = {};
    let keys: Array<string> = [];
    for (let index = 0; index < mmsList.length; index++) {
      const element = mmsList[index];
      if (group[element.groupId]) {
        let obj = group[element.groupId];
        obj.telephone = obj.telephone + common.STR.COMMA + element.telephone;
        obj.telephoneFormat = obj.telephoneFormat + common.STR.COMMA + element.telephoneFormat;
        obj.contactsNum ++;
      } else {
        let groupObj: LooseObject = {};
        groupObj = element;
        groupObj.contactsNum = 1;
        group[element.groupId] = groupObj;
        keys.push(element.groupId);
      }
    }

    keys.forEach((key, index) => {
      let item = group[key];
      if (index === 0) {
        item.isMessageFirst = true;
      } else {
        item.isMessage = true;
      }
      resultList.push(item);
    });

    return resultList;
  }

  private dealResult(mmsList: Array<LooseObject>): LooseObject {
    let result: Record<string, LooseObject[]> = {
      'messageList': [],
      'telephones': []
    };
    if (!mmsList || mmsList.length === 0) {
      return result;
    }
    let messageList: Array<LooseObject> = [];
    let telephones: Array<LooseObject> = [];
    for (let index = 0; index < mmsList.length; index ++) {
      let item: LooseObject = mmsList[index];
      let map: LooseObject = {};
      map.content = item.msgContent;
      map.name = common.STR.EMPTY_STR;
      if (item.isSender === 1) {
        map.telephone = item.senderNumber;
        map.telephoneFormat = item.senderNumber;
      } else {
        map.telephone = item.receiverNumber;
        map.telephoneFormat = item.receiverNumber;
      }
      if (telephones.indexOf(map.telephone) < 0) {
        telephones.push(map.telephone);
      }
      map.time = common.STR.EMPTY_STR;
      map.timeMillisecond = Number.parseInt(item.startTime);
      if (item.smsType ==  common.sms_type.COMMON) {
        map.icon = 'icon/user_avatar_full_fill.svg';
      } else {
        map.icon = 'icon/ic_bell_fill.svg';
      }
      map.groupId = item.groupId;
      map.threadId = item.sessionId;
      map.smsType = item.smsType;
      map.isDraft = item.msgState == common.int.SEND_DRAFT ? true : false;
      map.msgId = item.msgId;
      messageList.push(map);
    }
    result.messageList = messageList;
    result.telephones = telephones;
    return result;
  }

  async getConversationSession(context: Context, actionData: LooseObject, callback: Function) {
    ConversationListService.getInstance().querySessionByCondition(context, actionData,
      (res: ConversationListResponse) => {
      HiLog.i(TAG, 'query session by threadId response');
      let obj: Record<string, string | boolean> = {
        'hasDraft': false,
        'draftContent': ''
      };
      if (res.code === common.int.SUCCESS && res.abilityResult && res.abilityResult.length > 0) {
        let result: ConversationListInfo = res.abilityResult[0];
        if (result.hasDraft == 1) {
          obj.hasDraft = true;
          obj.draftContent = result.content;
        }
      }
      callback(obj);
    });
  }
};