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

import common from '../data/commonData';
import HiLog from '../utils//HiLog';
import LooseObject from '../data/LooseObject'
import conversationListService from './ConversationListService';
import conversationService from './ConversationService';
import { GlobalContext } from '../MainAbility/GlobalHelper';
import myCommon from '@ohos.app.ability.common';
import ConversationListResponse from '../model/conversationlist/ConversationListResponse';
import { ConversationListInfo } from '../model/conversationlist/ConversationListInfo';

const TAG = 'GroupDetailService';

export default class GroupDetailService {
  private static instance: GroupDetailService;

  public static getInstance(): GroupDetailService {
    if (GroupDetailService.instance == null) {
      GroupDetailService.instance = new GroupDetailService();
    }
    return GroupDetailService.instance;
  }

  public static getTestInstance(): GroupDetailService {
    return new GroupDetailService();
  }

  queryContactGroupDetail(context: Context, actionData:LooseObject, callback: Function): void {
    HiLog.i(TAG, 'queryContactGroupDetail');
    let result: LooseObject = {};
    // Query group information from SMS database
    conversationService.getInstance().querySmsMmsInfoByCondition(context, actionData, async (res: LooseObject)=> {
      result.code = res.code;
      if (res.code === common.int.SUCCESS) {
        HiLog.i(TAG, 'queryContactGroupDetail success');
        this.dealContactGroupName(result, res, actionData, callback);
      } else {
        callback(result);
        HiLog.i(TAG, 'Error: queryContactGroupDetail failed');
      }
  });
  }

  private dealContactGroupName(result: LooseObject, res: LooseObject, actionData: LooseObject, callback: Function) {
    let telephones: string[] = [];
    result.contactList = this.dealGroupDetail(res.abilityResult, telephones);
    conversationListService.getInstance().dealContactsName(telephones, actionData, result.contactList,
      (contactList: Record<string, Object>) => {
        result.contactList = contactList;
        conversationListService.getInstance().dealYellowPageNameSecond(telephones, actionData,
          result.contactList, (res1: LooseObject) => {
            result.contactList = res1;
            callback(result);
          }, GlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext);
      }, GlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext, true);
  }

  dealGroupDetail(groupDetails: Array<LooseObject>, telephones: string[]): Array<LooseObject> {
    let results: LooseObject[] = [];
    for (let groupDetail of groupDetails) {
      let item: LooseObject = {};
      item.name = common.STR.EMPTY_STR;
      item.date = common.STR.EMPTY_STR;
      item.time = common.STR.EMPTY_STR;
      if (groupDetail.msgState === common.int.SEND_MESSAGE_SUCCESS) {
        item.sendStatus = common.int.SEND_MESSAGE_SUCCESS;
      } else if (groupDetail.msgState === common.int.SEND_MESSAGE_SENDING) {
        item.sendStatus = common.int.SEND_MESSAGE_SENDING;
      } else {
        item.sendStatus = common.int.SEND_MESSAGE_FAILED;
      }
      telephones.push(groupDetail.receiverNumber);
      item.telephone = groupDetail.receiverNumber;
      item.telephoneFormat = groupDetail.receiverNumber;
      item.timeMillisecond = groupDetail.startTime;
      item.id = groupDetail.msgId;
      item.hasYellowPageIcon = common.STR.EMPTY_STR;
      item.yellowPageId = common.STR.EMPTY_STR;
      results.push(item);
    }
    return results;
  }

  queryContactList(context: Context, actionData: LooseObject, callback: Function) {
    HiLog.i(TAG, 'query contact list');
    let result: LooseObject = {};
    conversationListService.getInstance().querySessionByCondition(context, actionData,
      (res: ConversationListResponse) => {
      result.code = res.code;
      if (result.code === common.int.SUCCESS) {
        HiLog.i(TAG, 'query contact list result success');
        if (res.abilityResult.length > 0) {
          let list: ConversationListInfo = res.abilityResult[0];
          if (list.telephone != common.STR.EMPTY_STR) {
            let telephones: string[] = list.telephone.split(common.STR.COMMA);
            let contactList: LooseObject[] = [];
            for (let telephone of telephones) {
              let recipient: LooseObject = {};
              recipient.name = common.STR.EMPTY_STR;
              recipient.telephone = telephone;
              recipient.telephoneFormat = telephone;
              contactList.push(recipient);
            }
            conversationListService.getInstance().dealContactsName(telephones, actionData, contactList,
              (contactList: Record<string, Object>) => {
              result.contactList = contactList;
              callback(result);
            }, GlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext, true)
          }
        } else {
          result.contactList = [];
          callback(result);
        }
      } else {
        HiLog.i(TAG, 'query contact list result failed');
        result.contactList = [];
        callback(result);
      }
  });
  }
}