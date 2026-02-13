/**
 * Copyright (c) 2022 Huawei Device Co., Ltd.
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

import dataShare from '@ohos.data.dataShare';
import dataSharePredicates from '@ohos.data.dataSharePredicates';
import BaseModel from './BaseModel';
import common, { GlobalContextKey, MarkRead} from '../data/commonData';
import mmsTable from '../data/tableData';
import HiLog from '../utils/HiLog';
import LooseObject from '../data/LooseObject';
import StringUtil, { isJSONString } from '../utils/StringUtil';
import ContactsModel from '../model/ContactsModel';
import AvatarColor from '../model/common/AvatarColor';
import { BusinessError } from '@ohos.base';
import { ValuesBucket } from '@ohos.data.ValuesBucket';
import DataShareResultSet from '@ohos.data.DataShareResultSet';
import { ConversationListInfo, ConversationListViewInfo } from './conversationlist/ConversationListInfo';
import ConversationListResponse from './conversationlist/ConversationListResponse';
import hiTraceMeter from '@ohos.hiTraceMeter';
import TraceConstant from '../data/TraceConstant';
import DataShareHelper from './repository/DataShareHelper';
import { SessionContactInfoForDB } from '../pages/conversation/conversationController';
import { AbilityResult, Contact, SessionContentTypeOfRcs, RcsSendLoc, ContactType,
  Response } from '../utils/TypesUtils';
import I18n from '@ohos.i18n';
import Constant from '../data/Constant';
import YellowPageService from '../service/yellowPageService';
import TelephoneUtil from '../utils/TelephoneUtil';
import YellowPageModel from './yellowPageModel';
import myCommon from '@ohos.app.ability.common';
import { Context } from '@kit.AbilityKit';
import SharedPreferencesUtils from '../utils/SharedPreferencesUtils';
import { ISmsDBDataShareHelper } from './type/ConversationParams';
import { GlobalContext } from '../MainAbility/GlobalHelper';
import { ChatbotUtils, stringToUint8Array } from '../chatbot/utils/ChatbotUtils';
import { HashSet, taskpool, util } from '@kit.ArkTS';
import { ISessionTelephoneInfo, QueryContactInfoInSessionActionData } from './type/ContactParams';
import { UnLockedNotifyService } from '../utils/UnLockedNotifyService';
import { fileIo as fs } from '@kit.CoreFileKit';
import ConversationListService from '../service/ConversationListService';
import BlockedUtil from '../utils/BlockedUtil';
import { BotMessage } from '../chatbot/utils/ChatbotEntitys';


const TAG = 'ConversationListModel';

class SizeObj {
  width: string = '';
  height: string = '';
}

class ConvertSessionListResult {
  //session的基本信息
  public messageList: [] = [];
  //需要查询联系人数据库的电话号码
  public telephones: string[] = [];
  //需要查询黄页数据库的电话号码
  public telephonesForYellowPage: string[] = [];
  //需要查询chatbot数据库的号码
  public telephonesForChatbot: string[] = [];
}

export default class ConversationListModel extends BaseModel {
  private contactsModel = new ContactsModel();
  private yellowPageModel: YellowPageModel = new YellowPageModel();
  numberReg: RegExp = new RegExp('^[0-9]+$');

  public async insertSession(valueBucket: ValuesBucket, callback: Function, context: Context): Promise<void> {
    HiLog.i(TAG, 'insertSession');
    let dataHelper:dataShare.DataShareHelper | undefined = await DataShareHelper.getInstance().initSmsDB(context);
    if (!dataHelper) {
      HiLog.e(TAG, '[insertSession] createDataShareHelper fail');
      if (callback) {
        callback(this.encapsulateReturnCode(common.int.FAILURE));
      }
      return;
    }
    let managerUri: string = common.STR.URI_MESSAGE_LOG + common.STR.URI_MESSAGE_SESSION_TABLE;
    dataHelper.insert(managerUri, valueBucket).then(data => {
      if (callback) {
        callback(this.encapsulateReturnResult(common.int.SUCCESS, data));
      }
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'insertSession fail, error: ' + JSON.stringify(error));
      if (callback) {
        callback(this.encapsulateReturnCode(common.int.FAILURE));
      }
    });
  }

  public async deleteSessionByCondition(actionData: LooseObject, callback: Function, context: Context): Promise<void> {
    HiLog.i(TAG, 'deleteSessionByCondition');
    let dataHelper = await DataShareHelper.getInstance().initSmsDB(context);
    if (!dataHelper) {
      HiLog.e(TAG, '[deleteSessionByCondition] createDataShareHelper fail');
      if (callback) {
        callback(this.encapsulateReturnCode(common.int.FAILURE));
      }
      return;
    }
    dataHelper = dataHelper as dataShare.DataShareHelper;
    let condition: dataSharePredicates.DataSharePredicates = this.buildQuerySessionCondition(actionData);
    let managerUri: string = common.STR.URI_MESSAGE_LOG + common.STR.URI_MESSAGE_SESSION_TABLE;
    dataHelper.delete(managerUri, condition).then(data => {
      HiLog.e(TAG, 'deleteSessionByCondition, success');
      if (callback) {
        callback(this.encapsulateReturnResult(common.int.SUCCESS, data));
      }
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'deleteSessionByCondition, error: ' + JSON.stringify(error));
      if (callback) {
        callback(this.encapsulateReturnCode(common.int.FAILURE));
      }
    });
  }
  
  public async deleteSessionSlice(actionData: LooseObject, callback: Function, context: Context): Promise<void> {
    let dataHelper = await DataShareHelper.getInstance().initSmsDB(context);
    if (!dataHelper) {
      HiLog.e(TAG, '[deleteSessionSlice] createDataShareHelper fail');
      if (callback) {
        callback(this.encapsulateReturnCode(common.int.FAILURE));
      }
      return;
    }
    dataHelper = dataHelper as dataShare.DataShareHelper;
    let condition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    let type: string = common.deleteMessage.DELETECHECK == actionData.deleteMessage ? 'IN' : 'NOT IN';
    condition.in(type, actionData.sessionIDs);
    if (actionData.smsType !== undefined) {
      condition.equalTo('sms_type', actionData.smsType);
    }
    HiLog.w(TAG, '[deleteSessionSlice] before delete');
    let managerUri: string = common.STR.URI_MESSAGE_LOG + common.STR.URI_MESSAGE_DELETE_SESSION;
    dataHelper.delete(managerUri, condition).then(data => {
      HiLog.w(TAG, 'deleteSessionByCondition, finished');
      if (callback) {
        callback(this.encapsulateReturnResult(common.int.SUCCESS, data));
      }
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'deleteSessionByCondition, error: ' + JSON.stringify(error));
      if (callback) {
        callback(this.encapsulateReturnCode(common.int.FAILURE));
      }
    });
  }

  public async queryMmsPartPathBySessionIds(actionData: LooseObject, callback: Function,
    context: Context): Promise<void> {
    let dataHelper = await DataShareHelper.getInstance().initSmsDB(context);
    if (!dataHelper) {
      HiLog.e(TAG, '[queryMmsPartPathBySessionIds] createDataShareHelper fail');
      if (callback) {
        callback([]);
      }
      return;
    }
    dataHelper = dataHelper as dataShare.DataShareHelper;
    let condition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    let type: string = common.deleteMessage.DELETECHECK == actionData.deleteMessage ? 'IN' : 'NOT IN';
    condition.in(type, actionData.sessionIDs);
    if (actionData.smsType !== undefined) {
      condition.equalTo('sms_type', actionData.smsType);
    }
    HiLog.w(TAG, '[queryMmsPartPathBySessionIds] before delete');
    let managerUri: string = common.STR.URI_MESSAGE_LOG + common.STR.URI_MESSAGE_QUERY_MMS_PATHS_WITH_SESSIONIDS;
    dataHelper.query(managerUri, condition, this.buildMmsPartPathTableColumns()).then(resultSet => {
      HiLog.w(TAG, 'queryMmsPartPathBySessionIds, finished');
      let resultList: string[] = [];
      if (resultSet?.rowCount > 0) {
        while (resultSet.goToNextRow()) {
          resultList.push(resultSet.getString(resultSet.getColumnIndex(mmsTable.mmsPart.locationPath)));
        }
      }
      resultSet.close();
      HiLog.w(TAG, 'queryMmsPartPathBySessionIds resultList.length:' + resultList.length);
      if (callback) {
        callback(resultList);
      }
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'queryMmsPartPathBySessionIds, error: ' + JSON.stringify(error));
      if (callback) {
        callback([]);
      }
    });
  }

  /**
   * Fetch recent contacts and batch update session.
   *
   * @param context
   * @param startUpdateTime
   * @param endUpdateTime
   */
  public async fetchRecentContactsAndBatchUpdateSession(
    context: Context,
    startUpdateTime: string,
    endUpdateTime: string,
    callback: Function
  ) {
    HiLog.i(TAG, '[fetchRecentContactsAndBatchUpdateSession] start.');
    // Fetch recent contacts.
    let contacts: SessionContactInfoForDB[] = await this.fetchRecentContacts(context, startUpdateTime, endUpdateTime);
    HiLog.i(TAG, '[fetchRecentContactsAndBatchUpdateSession] contacts.' + contacts.length);
    if (contacts.length <= 0) {
      HiLog.i(TAG, '[fetchRecentContactsAndBatchUpdateSession] without contacts, ignore update.');
      if (callback) {
        callback([]);
      }
      return;
    }
    if (callback) {
      callback(contacts);
    }

    // 分片查找的大小
    const chunkSize = 300;

    // 调用分片查找函数
    this.queryInChunks(contacts, chunkSize, (res: []) => {
      // 这里可以添加其他逻辑，例如处理查询完毕后的回调
      HiLog.i(TAG, `[fetchRecentContactsAndBatchUpdateSession] finish update`)
      SharedPreferencesUtils.init(context);
      SharedPreferencesUtils.saveToPreferencesTaskPool(common.STR.KEY_OF_LAST_CONTACT_UPDATE_TIME, endUpdateTime);
    }, context);
  }

  queryInChunks(contacts: SessionContactInfoForDB[], chunkSize: number, callback: Function, context: Context) {
    let telephones: string[] = [];
    contacts.forEach((item) => {
      telephones.push(item.contactPhone ?? '');
    });
    let telephoneChunks: string[][] = [];
    let contactsChunks: SessionContactInfoForDB[][] = [];
    for (let i = 0; i < contacts.length; i += chunkSize) {
      telephoneChunks.push(telephones.slice(i, Math.min(contacts.length, i + chunkSize)));
      contactsChunks.push(contacts.slice(i, Math.min(contacts.length, i + chunkSize)));
    }

    let index = 0;
    const processChunk = () => {
      if (index >= telephoneChunks.length) {
        if (callback) {
          callback([]);
        }
        return;
      }

      let telephoneChunk = telephoneChunks[index];
      let contactsChunk = contactsChunks[index];
      let actionData: LooseObject = {};
      actionData.telephones = telephoneChunk;
      this.querySessionByCondition(actionData, (res: ConversationListResponse) => {
        if (res.abilityResult && res.abilityResult.length > 0) {
          HiLog.i(TAG, '[fetchRecentContactsAndBatchUpdateSession] querySessionByCondition res.' +
          res.abilityResult.length + ' index：' + index);
          this.batchSessionContactInfo(res, telephoneChunk, contactsChunk, context, () => {
            index++;
            processChunk();
          });
        } else {
          index++;
          processChunk();
        }
      }, context);
    };
    processChunk();
  }


    public async fetchDeleteContactsAndUpdateSession(context: Context, rawDeletedContactIds: String[],
        callback: Function) {
        HiLog.i(TAG, '[fetchDeleteContactsAndUpdateSession] start.');
        // 寻找最近删除的联系人电话，存在一个ContactId有多个电话号码的情况
        let contacts: SessionContactInfoForDB[] = await this.fetchDeleteContacts(context, rawDeletedContactIds);
        let telephones: string[] = [];
        contacts.forEach((item) => {
            telephones.push(item.contactPhone ?? '');
        });
        // 分批处理，每批处理的数据不超过300,否则SQL可能报错
      this.queryInChunks(contacts, Constant.MAX_NUMBER_OF_PARAMS_IN_SQL, callback, context)
    }

  private async batchSessionContactInfo(
    res: ConversationListResponse,
    telephones: string[],
    contacts: SessionContactInfoForDB[],
    context: Context,
    callback: Function) {
    let valueBuckets: ValuesBucket[] = [];
    let conditions: Record<string, string>[] = [];

    // Create a Map for quick lookup
    let contactMap = new Map<string, Record<string, string>>();
    for (let contact of contacts) {
      let formatMmsPhone =
        TelephoneUtil.formatDisplayPhoneNum(contact.contactPhone).replace(new RegExp('[\\s]', 'g'), '');
      contactMap.set(formatMmsPhone, {
        'contact_id': contact.contactId,
        'contact_name': contact.contactName
      });
    }

    for (let item of res.abilityResult) {
      let valueBucket: ValuesBucket = {};
      let telephone = item.telephone;
      if (item.contactName) {
        let contactName = await this.fetchFirstContactName(telephone, context);
        if (contactName) {
          let formatMmsPhone = TelephoneUtil.formatDisplayPhoneNum(telephone).replace(new RegExp('[\\s]', 'g'), '');
          let tmpContact = contactMap.get(formatMmsPhone) ?? {};
          contactMap.set(formatMmsPhone, {
            'contact_id': tmpContact.contact_id,
            'contact_name': contactName });
        }
      }

      if (telephone.indexOf(common.STR.COMMA) === -1) {
        // Single Recipient
        let formatMmsPhone = TelephoneUtil.formatDisplayPhoneNum(item.telephone).replace(new RegExp('[\\s]', 'g'), '');
        valueBucket = contactMap.get(formatMmsPhone) ?? {};
      } else {
        // Multiple Recipients with comma-separated phone numbers
        // Update contact name and id based on phone number
        valueBucket = this.buildMultiContactValueBucket(item, contactMap);
      }

      if (valueBucket.contact_id != undefined) {
        conditions.push({
          'telephone': telephone
        });
        valueBuckets.push(valueBucket);
      }
    }

    this.batchUpdateSessionByCondition(context, conditions, valueBuckets, (results: number[]) => {
      HiLog.i(TAG, '[fetchRecentContactsAndBatchUpdateSession] end.');
      if (callback) {
        callback(results);
      }
    });
  }

  private async fetchFirstContactName(telephone: string, context: Context) {
    let actionData: LooseObject = {};
    let tmpTelephones: string[] = [];

    tmpTelephones.push(telephone);
    actionData.telephones = tmpTelephones;
    actionData.hasDelete = '0';
    return new Promise<string>((resolve) => this.contactsModel
      .queryContactDataByCondition(actionData, (res: AbilityResult) => {
        if (res.code == common.int.FAILURE) {
          HiLog.e(TAG, '[fetchFirst] queryContactDataByCondition failed.');
          resolve('');
          return;
        }
        if (res.abilityResult.length == 0) {
          HiLog.e(TAG, '[fetchFirst] queryContactDataByCondition without result.');
          resolve('');
          return;
        }

        HiLog.i(TAG, '[fetchFirst] queryContactDataByCondition success');
        resolve(res.abilityResult[0].displayName);
      }, context)
    );
  }

  // update single contact id and name

  // update multi contact id and name
  private buildMultiContactValueBucket(item: ConversationListInfo, contactMap: Map<string, Record<string, string>>) {
    let contactId = item.contactId;
    let contactName = item.contactName;
    let telephone = item.telephone;

    // Separate the phone number, ID, and name with a comma.
    let splitTels = telephone.split(common.STR.COMMA);
    let splitNames = contactName.split(common.STR.COMMA + common.STR.WHITE_SPACE);
    if (splitNames.length != splitTels.length) {
      splitNames = contactName.split(common.STR.COMMA);
    }
    let splitIds = contactId.split(common.STR.COMMA);

    for (let i = 0; i < splitTels.length; i++) {
      let formatPhone = TelephoneUtil.formatDisplayPhoneNum(splitTels[i]).replace(new RegExp('[\\s]', 'g'), '');
      let contact = contactMap.get(formatPhone);
      if (contact) {
        splitNames[i] = contact.contact_name;
        splitIds[i] = contact.contact_id;
      }
    }
    let joinId = splitIds.join(common.STR.COMMA);
    let joinName = splitNames.join(common.STR.COMMA + common.STR.WHITE_SPACE);
    let valueBucket: ValuesBucket = {
      contact_id: joinId,
      contact_name: joinName
    };
    return valueBucket;
  }

  /**
   * Fetch recent contacts
   *
   * @param context
   * @param startUpdateTime
   * @param endUpdateTime
   * @returns
   */
  public async fetchRecentContacts(context: Context, startUpdateTime: string, endUpdateTime: string) {
    HiLog.i(TAG, '[fetchRecentContacts] start. startTime: ' + startUpdateTime + ', endTime: ' + endUpdateTime);
    let timeQuery: Record<string, string> = {'startUpdateTime': startUpdateTime, 'endUpdateTime': endUpdateTime};
    return new Promise<SessionContactInfoForDB[]>((resolve) => this.contactsModel
      .queryContactDataByCondition(timeQuery, (res: AbilityResult) => {
      let contacts: SessionContactInfoForDB[] = [];
      if (res.code == common.int.FAILURE) {
        HiLog.i(TAG, '[fetchRecentContacts] queryContactDataByCondition failed.');
        resolve(contacts);
        return;
      }
      if (res.abilityResult.length <= 0) {
        HiLog.d(TAG, '[fetchRecentContacts] queryContactDataByCondition without result.');
        resolve(contacts);
        return;
      }
      contacts = (res.abilityResult as Contact[]).map((item) => {
        let formatPhone = TelephoneUtil.formatDisplayPhoneNum(item.detailInfo ?? '').replace(new RegExp('[\\s]', 'g'), '');
        return {
          contactPhone: formatPhone,
          contactName: item.displayName ?? '',
          rawContactId: item.rawContactId ?? '',
          contactId: item.contactId ?? ''
        } as SessionContactInfoForDB;
      });
      HiLog.i(TAG, '[fetchRecentContacts] queryContactDataByCondition success.');
      resolve(contacts);
      }, context)
    );
  }

    /**
     * Fetch delete contacts
     *
     * @param context
     * @param rawContactId
     * @returns
     */
    public async fetchDeleteContacts(context: Context, rawContactIds: String[]): Promise<SessionContactInfoForDB[]> {
        HiLog.i(TAG, '[fetchDeleteContacts] start, rawContactIds: ' + rawContactIds.join(','));
        let contactIds: LooseObject[] = rawContactIds;
        let actionData: LooseObject = {};
        actionData.contactIds = contactIds;
        actionData.hasDelete = '1';
        return new Promise<SessionContactInfoForDB[]>((resolve) => {
            this.contactsModel.queryContactDataByCondition(actionData, async (res: AbilityResult) => {
                await this.dealDeleteContacts(res, context, resolve);
            }, context);
        });
    }

    public async fetchDeleteContactList(context: Context,
        rawContactIdList: String[]): Promise<SessionContactInfoForDB[]> {
        let contactIds: LooseObject[] = rawContactIdList;
        let actionData: LooseObject = {};
        actionData.contactIds = contactIds;
        actionData.hasDelete = '1';
        return new Promise<SessionContactInfoForDB[]>((resolve) => {
            this.contactsModel.queryContactDataByCondition(actionData, async (res: AbilityResult) => {
                await this.dealDeleteContacts(res, context, resolve);
            }, context);
        });
    }


  private async dealDeleteContacts(res: AbilityResult, context: Context,
    resolve: (value: SessionContactInfoForDB[] | PromiseLike<SessionContactInfoForDB[]>) => void) {
    let contacts: SessionContactInfoForDB[] = [];
    if (res.code == common.int.FAILURE) {
      HiLog.i(TAG, '[fetchDeleteContacts] queryContactDataByCondition failed.');
    } else {
      if (res.abilityResult.length <= 0) {
        HiLog.d(TAG, '[fetchDeleteContacts] queryContactDataByCondition without result.');
      } else {
        contacts = await this.dealDeleteContactsInfo(res, context, contacts);
      }
    }
    resolve(contacts);
  }

  private async dealDeleteContactsInfo(res: AbilityResult, context: Context, contacts: SessionContactInfoForDB[]) {
    let result = await YellowPageService.getInstance()
      .judgeYellowPageByTelephone(res.abilityResult[0].detailInfo, context);
    let newDisplayName: string = common.STR.EMPTY_STR;
    if (result.yellowPageId) {
      newDisplayName = result.name;
    }
    contacts = (res.abilityResult as Contact[]).map((item) => {
      return {
        contactPhone: item.detailInfo ?? '',
        contactName: newDisplayName,
        rawContactId: '',
        contactId: ''
      } as SessionContactInfoForDB;
    });
    HiLog.i(TAG, '[fetchDeleteContacts] queryContactDataByCondition success.');
    return contacts;
  }

  /**
   * Batch update session by condition.
   *
   * @param context
   * @param conditions
   * @param valueBuckets
   * @param callback
   */
  public async batchUpdateSessionByCondition(
    context: Context,
    conditions: Record<string, string | number>[],
    valueBuckets: ValuesBucket[],
    callback: Function,
  ) {
    HiLog.i(TAG, '[batchUpdateSessionByCondition] start.');
    let failValues: number[] = valueBuckets.map((_) => common.int.FAILURE);
    if (conditions.length !== valueBuckets.length || valueBuckets.length === 0) {
      HiLog.e(TAG, '[batchUpdateSessionByCondition] Illegal arguments.');
      callback(failValues);
      return;
    }
    let dataHelper: dataShare.DataShareHelper | undefined = await DataShareHelper.getInstance().initSmsDB(context);
    if (!dataHelper) {
      HiLog.e(TAG, '[batchUpdateSessionByCondition] createDataShareHelper fail.');
      callback(failValues);
      return;
    }
    let predicates: dataSharePredicates.DataSharePredicates[] = conditions
      .map((item) => this.buildQuerySessionCondition(item));
    let sessionTableUri: string = common.STR.URI_MESSAGE_LOG + common.STR.URI_MESSAGE_SESSION_TABLE;
    let updatePromises: Promise<number>[] = predicates.map((item, index) => {
      return (dataHelper as dataShare.DataShareHelper).update(sessionTableUri, item, valueBuckets[index]);
    });
    Promise.allSettled(updatePromises)
      .then((results: LooseObject[]) => {
        let values: number[] = results.map((item) => Number(item.value) ?? -1);
        HiLog.i(TAG, '[batchUpdateSessionByCondition] end. result.length: ' + results.length);
        callback(values);
      })
      .catch((error: BusinessError) => {
        HiLog.i(TAG, '[batchUpdateSessionByCondition] fail. error: ' + JSON.stringify(error));
        callback(failValues);
      });
  }

  public async updateSessionByCondition(actionData: LooseObject, valueBucket: ValuesBucket, callback: Function | null, context: Context): Promise<void> {
    HiLog.i(TAG, 'updateSessionByCondition');
    let dataHelper = await DataShareHelper.getInstance().initSmsDB(context);
    if (!dataHelper) {
      HiLog.e(TAG, `[updateSessionByCondition] createDataShareHelper fail`);
      if (callback) {
        callback(this.encapsulateReturnCode(common.int.FAILURE));
      }
      return;
    }
    dataHelper = dataHelper as dataShare.DataShareHelper;
    let condition: dataSharePredicates.DataSharePredicates = this.buildQuerySessionCondition(actionData);
    if (valueBucket == null) {
      HiLog.e(TAG, 'updateSessionByCondition fail, valueBucket is null!');
      if (callback) {
        callback(this.encapsulateReturnCode(common.int.FAILURE));
      }
    }
    let managerUri: string = common.STR.URI_MESSAGE_LOG + common.STR.URI_MESSAGE_SESSION_TABLE;
    dataHelper.update(managerUri, condition, valueBucket).then((updateRowCount: number) => {
      HiLog.iw(TAG, `updateSessionByCondition success, updateRowCount: ${updateRowCount}`);
      if (callback) {
        callback(this.encapsulateReturnResult(common.int.SUCCESS, updateRowCount));
      }
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'updateSessionByCondition fail, error: ' + JSON.stringify(error));
      if (callback) {
        callback(this.encapsulateReturnCode(common.int.FAILURE));
      }
    });
  }

  public async markAsReadFromReceive(actionData: LooseObject, callback: Function, context: Context): Promise<void> {
    let dataHelper = await DataShareHelper.getInstance().initSmsDB(context);
    if (!dataHelper) {
      HiLog.e(TAG, `[markAsReadFromReceive] createDataShareHelper fail`);
      if (callback) {
        callback(this.encapsulateReturnCode(common.int.FAILURE));
      }
      return;
    }
    dataHelper = dataHelper as dataShare.DataShareHelper;
    let infoUri: string = common.STR.URI_MESSAGE_LOG + common.STR.URI_MESSAGE_SINGLE_MARK_UNREAD;
    let infoUpdateCondition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    if (actionData.isAfterNoReadButton && UnLockedNotifyService.getInstance().dataIsMoveEL5) {
      infoUpdateCondition.equalTo(mmsTable.messageInfo.phoneNumber, actionData.telephone).and().
      equalTo(mmsTable.messageInfo.msgContent, actionData.msgContent).and().
      equalTo(mmsTable.messageInfo.startTime, actionData.startTime).and().
      equalTo('msg_type', actionData.msgType);
    } else {
      infoUpdateCondition.equalTo(mmsTable.messageInfo.msgId, actionData.threadIds).and().
      equalTo('msg_type', actionData.msgType);
    }
    let bucketValue: Record <string, number> = {
      'is_read': common.is_read.READ
    }
    if (dataHelper !== undefined) {
      try {
        dataHelper.update(infoUri, infoUpdateCondition, bucketValue, (res) => {
          dataHelper?.notifyChange(common.STR.URI_MESSAGE_LOG + common.STR.URI_MESSAGE_SESSION_TABLE);
          if (callback) {
            callback(res);
          }
        });
      } catch (e) {
        HiLog.e(TAG, 'markAsReadFromReceiveNotice error: ' + JSON.stringify(e));
      }
    }
  }

  /*
   * 返回查询session表的最优DataShareHelper
   * 1. useSilenceDB == true
   * 1.1 优先返回使用静默访问的DataShareHelper
   * 1.2 静默访问创建DataShareHelper失败，使用非静默方式的DataShareHelper
   * 2. useSilenceDB == false ,返回默认的useSilenceDB == true
   * */
  private async getBestSessionDataHelper(useSilenceDB: boolean, context: Context): Promise<ISmsDBDataShareHelper> {
    let managerUri: string = common.STR.URI_MESSAGE_LOG + common.STR.URI_MESSAGE_SESSION_TABLE;
    let dataHelper: dataShare.DataShareHelper | undefined = undefined
    if (!useSilenceDB) {
      dataHelper = await DataShareHelper.getInstance().initSmsDB(context);
    } else {
      dataHelper = await DataShareHelper.getInstance().initSilenceSmsDBSessionTable(context)
      if (dataHelper) {
        managerUri = common.STR.URI_SESSION_TABLE_PROXY
      } else {
        HiLog.e(TAG, '[getBestSessionDataHelper] useSilenceDB failed switch to smsDB data helper')
        dataHelper = await DataShareHelper.getInstance().initSmsDB(context);
      }
    }
    let result: ISmsDBDataShareHelper = {
      dataHelper: dataHelper,
      managerUri: managerUri
    }
    return result
  }

  public async querySessionByCondition(actionData: LooseObject, callback: Function, context: Context): Promise<void> {
    if (actionData.sqlMethodQuery) {
      this.queryConversionSessionByCondition(actionData, (res: ConversationListResponse) => {
        callback(res);
      }, context)
    } else {
      this.querySessionInfoByCondition(actionData, (res: ConversationListResponse) => {
        callback(res);
      }, context)
    }
  }

  public async queryMatchedRecipient(actionData: LooseObject, callback: Function, context: Context): Promise<void> {
    HiLog.i(TAG, '[queryMatchedRecipient] before query')
    let useSilenceDB = false
    if (actionData.useSilenceDB != undefined) {
      useSilenceDB = actionData.useSilenceDB
    }
    HiLog.i(TAG, '[queryMatchedRecipient] useSilenceDB: ' + useSilenceDB)
    let dbInfo: ISmsDBDataShareHelper = await this.getBestSessionDataHelper(useSilenceDB, context)
    let dataHelper: dataShare.DataShareHelper | undefined = dbInfo.dataHelper
    let managerUri: string = '';
    if (actionData.telephone && actionData.telephone.length > 0 && actionData.telephone.includes(',')) {
      managerUri = common.STR.URI_MESSAGE_LOG + common.STR.URI_MESSAGE_MATCHED_RECIPIENT;
    } else {
      managerUri = dbInfo.managerUri;
    }
    HiLog.i(TAG, '[queryMatchedRecipient] managerUri : ' + managerUri);
    HiLog.w(TAG, `queryMatchedRecipient, telephone.length:${actionData?.telephone?.length}`);
    if (!dataHelper) {
      HiLog.e(TAG, `[queryMatchedRecipient] createDataShareHelper fail`);
      callback(this.buildSessionReturnResult(common.int.FAILURE, []));
      return;
    }
    dataHelper = dataHelper as dataShare.DataShareHelper;
    let isFuzzyMatch: boolean = actionData.isFuzzyMatch != null ? actionData.isFuzzyMatch : false;
    let condition: dataSharePredicates.DataSharePredicates = this.buildQuerySessionCondition(actionData, isFuzzyMatch);
    HiLog.i(TAG, '[queryMatchedRecipient] before query, isFuzzyMatch: ' + isFuzzyMatch);
    dataHelper.query(managerUri, condition, this.buildSessionTableColumns()).then(resultSet => {
      HiLog.i(TAG, '[queryMatchedRecipient] proceed query, rowCount: ' + resultSet.rowCount)
      hiTraceMeter.startTrace(TraceConstant.TRACE_DB_PARSE_SESSION_DATA, TraceConstant.TRACE_DB_PARSE_SESSION_DATA_ID)
      let resultList: ConversationListInfo[] = [];
      if (resultSet.rowCount > 0) {
        while (resultSet.goToNextRow()) {
          resultList.push(this.buildSessionResult(resultSet));
        }
      } else {
        if (!actionData.telephone_like && !actionData.telephones) {
          resultSet.goToFirstRow();
          resultList.push(this.buildSessionResult(resultSet));
        }
      }
      hiTraceMeter.finishTrace(TraceConstant.TRACE_DB_PARSE_SESSION_DATA, TraceConstant.TRACE_DB_PARSE_SESSION_DATA_ID)
      HiLog.i(TAG, 'queryMatchedRecipient resultList.length:' + resultList.length)
      callback(this.buildSessionReturnResult(common.int.SUCCESS, resultList));
      resultSet.close();
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'queryMatchedRecipient fail, error: ' + JSON.stringify(error));
      callback(this.buildSessionReturnResult(common.int.FAILURE, []));
    });
  }

  public async queryConversionSessionByCondition(actionData: LooseObject, callback: Function,
    context: Context): Promise<void> {
    HiLog.i(TAG, '[queryConversionSessionByCondition] before query');
    let dataHelper: dataShare.DataShareHelper | undefined = await DataShareHelper.getInstance().initSmsDB(context);
    if (!dataHelper) {
      HiLog.e(TAG, `[queryConversionSessionByCondition] createDataShareHelper fail`);
      callback(this.encapsulateReturnCode(common.int.FAILURE));
      return;
    }
    let managerUri: string = common.STR.URI_MESSAGE_LOG + common.STR.URI_MESSAGE_CONVERSION_SESSION;
    let condition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    if (actionData.page != null && actionData.limit != null) {
      let offset = actionData.queryOffset as number ?? 0;
      condition.limit(actionData.limit, offset);
    }
    if (actionData.smsType != null) {
      managerUri = common.STR.URI_MESSAGE_LOG + common.STR.URI_MESSAGE_CONVERSION_NO_NOTIFY_SESSION;
    }
    dataHelper.query(managerUri, condition, this.buildSessionTableColumns()).then(resultSet => {
      HiLog.i(TAG, '[queryConversionSessionByCondition] proceed query, rowCount: ' + resultSet.rowCount)
      hiTraceMeter.startTrace(TraceConstant.TRACE_DB_PARSE_SESSION_DATA, TraceConstant.TRACE_DB_PARSE_SESSION_DATA_ID)
      let resultList: ConversationListInfo[] = [];
      if (resultSet.rowCount > 0) {
        while (resultSet.goToNextRow()) {
          resultList.push(this.buildSessionResult(resultSet));
        }
      } else {
        if (!actionData.telephone_like && !actionData.telephones) {
          resultSet.goToFirstRow();
          resultList.push(this.buildSessionResult(resultSet));
        }
      }
      hiTraceMeter.finishTrace(TraceConstant.TRACE_DB_PARSE_SESSION_DATA, TraceConstant.TRACE_DB_PARSE_SESSION_DATA_ID)
      HiLog.i(TAG, 'queryConversionSessionByCondition resultList.length:' + resultList.length)
      callback(this.buildSessionReturnResult(common.int.SUCCESS, resultList));
      resultSet.close();
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'queryConversionSessionByCondition fail, error: ' + JSON.stringify(error));
      callback(this.buildSessionReturnResult(common.int.FAILURE, []));
    });
  }

  public async querySessionInfoByCondition(actionData: LooseObject, callback: Function,
    context: Context): Promise<void> {
    let useSilenceDB = false
    if (actionData.useSilenceDB != undefined) {
      useSilenceDB = actionData.useSilenceDB
    }
    HiLog.i(TAG, '[querySessionInfoByCondition] useSilenceDB: ' + useSilenceDB)
    let dbInfo: ISmsDBDataShareHelper = await this.getBestSessionDataHelper(useSilenceDB, context)
    let dataHelper: dataShare.DataShareHelper | undefined = dbInfo.dataHelper
    let managerUri: string = dbInfo.managerUri
    if (!dataHelper) {
      HiLog.e(TAG, `[querySessionInfoByCondition] createDataShareHelper fail`);
      callback(this.buildSessionReturnResult(common.int.FAILURE, []));
      return;
    }
    dataHelper = dataHelper as dataShare.DataShareHelper;
    let isFuzzyMatch: boolean = actionData.isFuzzyMatch != null ? actionData.isFuzzyMatch : false;
    let condition: dataSharePredicates.DataSharePredicates = this.buildQuerySessionCondition(actionData, isFuzzyMatch);
    HiLog.i(TAG, '[querySessionInfoByCondition] before query, isFuzzyMatch: ' + isFuzzyMatch);
    dataHelper.query(managerUri, condition, this.buildSessionTableColumns()).then(resultSet => {
      HiLog.i(TAG, '[querySessionInfoByCondition] proceed query, rowCount: ' + resultSet.rowCount)
      hiTraceMeter.startTrace(TraceConstant.TRACE_DB_PARSE_SESSION_DATA, TraceConstant.TRACE_DB_PARSE_SESSION_DATA_ID)
      let resultList: ConversationListInfo[] = [];
      if (resultSet.rowCount > 0) {
        while (resultSet.goToNextRow()) {
          resultList.push(this.buildSessionResult(resultSet));
        }
      } else {
        if (!actionData.telephone_like && !actionData.telephones) {
          resultSet.goToFirstRow();
          resultList.push(this.buildSessionResult(resultSet));
        }
      }
      hiTraceMeter.finishTrace(TraceConstant.TRACE_DB_PARSE_SESSION_DATA, TraceConstant.TRACE_DB_PARSE_SESSION_DATA_ID)
      HiLog.i(TAG, 'querySessionInfoByCondition resultList.length:' + resultList.length)
      callback(this.buildSessionReturnResult(common.int.SUCCESS, resultList));
      resultSet.close();
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'querySessionInfoByCondition fail, error: ' + JSON.stringify(error));
      callback(this.buildSessionReturnResult(common.int.FAILURE, []));
    });
  }

  public querySessionResultByCondition(actionData: LooseObject, callback: Function, context: Context):
    Promise<LooseObject> {
    return new Promise((resolve, reject) => {
      this.querySessionByCondition(actionData, (res: ConversationListResponse) => {
        let sessionListData = new ConvertSessionListResult();
        if (res.code === common.int.SUCCESS && res.abilityResult !== null) {
          sessionListData = this.getConvertSessionListResult(
            res.abilityResult,
            context,
            actionData.isNeedMessageSort
          );
        }
        let result: Promise<Array<LooseObject>> = new Promise<Array<LooseObject>>((resolve, reject) => {
          HiLog.w(TAG, 'querySessionResultByCondition dealBlockedFraudName');
          resolve(BlockedUtil.dealBlockedFraudName(sessionListData.telephones, sessionListData.messageList, context));
        });
        result.then(() => {
          HiLog.w(TAG, 'querySessionResultByCondition dealContactsName');
          return this.dealContactsName(sessionListData.telephones, sessionListData.messageList, context);
        }).then(() => {
          HiLog.w(TAG, 'querySessionResultByCondition dealYellowPageName');
          return this.dealYellowPageName(sessionListData.telephonesForYellowPage, sessionListData.messageList, context);
        }).then(() => {
          HiLog.w(TAG, 'querySessionResultByCondition querySessionResultByCondition callback');
          // 准备最终结果
          let result: LooseObject = {};
          result.response = sessionListData.messageList;
          callback(result);
        });
      }, context);
    });
  }

  private dealContactsName(telephones: string[], sessionLists: [], context: Context): Promise<Array<LooseObject>> {
    return new Promise((resolve, reject) => {
      if (telephones.length == 0) {
        HiLog.w(TAG, 'dealContactsName, has no telephones');
        resolve(sessionLists);
      } else {
        HiLog.w(TAG, 'dealContactsName in sessionLists:' + sessionLists.length + ' , telephones:' + telephones.length)
        // 针对群发可能存在大量重复号码，对telephones 做出去重操作
        let telephonesSet: HashSet<string> = new HashSet();
        let telephonesArr: string[] = [];
        telephones.forEach(item => {
          if (!telephonesSet.has(item)) {
            telephonesSet.add(item);
            telephonesArr.push(item);
          }
        })
        HiLog.w(TAG, 'dealContactsName in telephones deduplicate:' + telephonesArr.length)
        let queryContactActionData: ISessionTelephoneInfo = new QueryContactInfoInSessionActionData(telephonesArr);

        let firstQueryContactFlag = false;
        try {
          firstQueryContactFlag = AppStorage.get(GlobalContextKey.QUERY_CONTACT_DATA_ON_COLD_START_UP) as boolean;
        } catch (error) {
          HiLog.i(TAG, 'dealContactsName not first time query')
        }
        if (firstQueryContactFlag) {
          queryContactActionData.useSilenceDB = true;
          AppStorage.setOrCreate(GlobalContextKey.QUERY_CONTACT_DATA_ON_COLD_START_UP, false)
        }

        if (telephonesArr.length < 990) {
          this.contactsModel.queryContactDataInSession(queryContactActionData, (res: LooseObject) => {
            HiLog.w(TAG, 'dealContactsName, res.code = ' + res.code);
            if (res.code == common.int.FAILURE || res.abilityResult.length == 0) {
              HiLog.w(TAG, 'dealContactsName, has no contacts');
              resolve(this.buildSessionNames([], sessionLists, context));
            } else {
              resolve(this.buildSessionNames(res.abilityResult, sessionLists, context));
            }
          }, context);
        } else {
          // sql拼接条件大于1000 会出现异常，导致联系人信息无法查到， 大于1000 修改为分组查询
          this.contactsModel.batchQueryContactDataByCondition(queryContactActionData, (res: LooseObject) => {
            HiLog.w(TAG, 'batchQuery dealContactsName, res.code = ' + res.code);
            if (res.code == common.int.FAILURE || res.abilityResult.length == 0) {
              HiLog.w(TAG, 'batchQuery dealContactsName, has no contacts');
              resolve(this.buildSessionNames([], sessionLists, context));
            } else {
              resolve(this.buildSessionNames(res.abilityResult, sessionLists, context));
            }
          }, context);
        }

      }
    });
  }

  private dealYellowPageName(telephones: string[], sessionLists: [], context: Context): Promise<Array<LooseObject>> {
    return new Promise((resolve, reject) => {
      if (telephones.length === 0) {
        HiLog.w(TAG, 'dealYellowPageName, has no telephones');
        resolve(sessionLists);
        return;
      }
      let queryYellowPageActionData: LooseObject = {}
      queryYellowPageActionData.telephones = telephones;
      this.yellowPageModel.queryYellowPageListInfoByCondition(queryYellowPageActionData, (res: LooseObject) => {
        if (res.code == common.int.FAILURE || res.abilityResult.length == 0) {
          HiLog.w(TAG, 'dealYellowPageName, has no YellowPage');
          resolve(this.buildSessionNamesByYellowPage([], sessionLists, context));
        } else {
          resolve(this.buildSessionNamesByYellowPage(res.abilityResult, sessionLists, context));
        }
      }, context);
    });
  }

  public async querySessionSizeByCondition(actionData: LooseObject, callback: Function, context: Context): Promise<void> {
    HiLog.i(TAG, 'querySessionSizeByCondition');
    let dataHelper = await DataShareHelper.getInstance().initSmsDB(context);
    if (!dataHelper) {
      HiLog.e(TAG, `[querySessionSizeByCondition] createDataShareHelper fail`);
      if (callback) {
        callback(this.encapsulateReturnCode(common.int.FAILURE));
      }
      return;
    }
    dataHelper = dataHelper as dataShare.DataShareHelper;
    let condition: dataSharePredicates.DataSharePredicates = this.buildQuerySessionCondition(actionData);
    let managerUri: string = common.STR.URI_MESSAGE_LOG + common.STR.URI_MESSAGE_SESSION_TABLE;
    dataHelper.query(managerUri, condition, ['count(*) as total']).then(resultSet => {
        if (resultSet.rowCount <= 0) {
          resultSet.close();
          callback(this.encapsulateReturnCode(common.int.FAILURE));
          return;
        }
        resultSet.goToFirstRow();
        let sessionTotal = resultSet.getLong(resultSet.getColumnIndex('total'));
        HiLog.i(TAG, 'querySessionSizeByCondition, total: ' + sessionTotal);
        callback(this.encapsulateReturnResult(common.int.SUCCESS, sessionTotal));
        resultSet.close();
        return;
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'querySessionSizeByCondition, fail, error: ' + JSON.stringify(error));
      callback(this.encapsulateReturnCode(common.int.FAILURE));
    });
  }

  private buildQuerySessionCondition(actionData: LooseObject,
    isFuzzyMatch: boolean = false): dataSharePredicates.DataSharePredicates {
    let condition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    condition.isNotNull(mmsTable.sessionField.id);
    if (actionData.smsType != null) {
      condition.and().equalTo(mmsTable.sessionField.smsType, actionData.smsType);
    }
    if (actionData.telephone != null && !actionData.isChatbotMessage) {
      this.sessionFiledTelephone(actionData, condition, isFuzzyMatch);
    } else if (actionData.telephone && actionData.isChatbotMessage) {
      condition.and().equalTo(mmsTable.sessionField.telephone, actionData.telephone);
    }
    if (actionData.telephone_like != null) {
      condition.and().like(mmsTable.sessionField.telephone, '%' + actionData.telephone_like + '%');
    }
    if (actionData.threadId != null) {
      condition.and().equalTo(mmsTable.sessionField.id, actionData.threadId);
    }
    if (actionData.threadIds != null && actionData.threadIds.length > 0) {
      condition.and().in(mmsTable.sessionField.id, actionData.threadIds);
    }
    //添加未选中条件
    if (actionData.uncheckedThreadIds != null && actionData.uncheckedThreadIds.length > 0) {
      condition.and().notIn(mmsTable.sessionField.id, actionData.uncheckedThreadIds);
    }
    if (actionData.messageCount != null) {
      condition.and().equalTo(mmsTable.sessionField.messageCount, actionData.messageCount);
    }
    if (actionData.unreadCount_greaterThan != null) {
      condition.and().greaterThan(mmsTable.sessionField.unreadCount, actionData.unreadCount_greaterThan);
    }
    condition.and().notEqualTo(mmsTable.sessionField.smsType, Constant.SESSION_TYPE_BLOCKED);
    if (actionData.telephones && actionData.telephones.length > 0) {
      condition.beginWrap().and().in(mmsTable.sessionField.telephone, actionData.telephones);
      actionData.telephones.forEach((telephone: string) => {
        telephone = TelephoneUtil.formatDisplayPhoneNum(telephone).replace(new RegExp('[\\s]', 'g'), '');
        condition.or().beginsWith(mmsTable.sessionField.telephone, telephone);
        condition.or().contains(mmsTable.sessionField.telephone, telephone);
        condition.or().endsWith(mmsTable.sessionField.telephone, telephone);
      });
      condition.endWrap();
    }
    HiLog.i(TAG, 'buildQuerySessionCondition, actionData.orderByTimeDesc' + actionData.orderByTimeDesc);
    if (actionData.orderByTimeDesc) {
      condition.orderByDesc(mmsTable.sessionField.pinningTime).orderByDesc(mmsTable.sessionField.time);
    }
    if (actionData.page != null && actionData.limit != null) {
      condition.limit(actionData.limit, StringUtil.getOffsetForSession(actionData.page));
    }
    if (actionData.sessionIds != null) {
      condition.and().in(mmsTable.sessionField.id, actionData.sessionIds);
    }
    if (actionData.queryPinSessionSize) {
      condition.and().notEqualTo(mmsTable.sessionField.pinningTime, 0);
    }
    return condition;
  }

  private sessionFiledTelephone(actionData: LooseObject, condition: dataSharePredicates.DataSharePredicates,
    isFuzzyMatch: boolean = false) {
    let telPhoneOriStr: string =
      isFuzzyMatch && actionData.telephoneFuzzyMatch ? actionData.telephoneFuzzyMatch : actionData.telephone;
    let telPhoneStr: string = (telPhoneOriStr as string).replace(new RegExp('[\\s]', 'g'), '');
    let contactsNum: number = telPhoneStr.split(',').length;
    //通知消息 1065795555 formatDisplayPhoneNum后会变成 01065795555;通知消息也不做后几位匹配
    let isInfoMsg = TelephoneUtil.judgeIsInfoMsg(telPhoneStr);
    //如果尾数小于等于7位，直接全等对比;群聊也直接全等对比;通知消息也做全等对比
    HiLog.i(TAG, 'sessionFiledTelephone isInfoMsg : ' + isInfoMsg);
    if (telPhoneStr.length <= 7 || contactsNum > 1 || isInfoMsg) {
      HiLog.w(TAG, `queryMatchedRecipient, case1 telPhoneStr.length:${telPhoneStr?.length}`);
      condition.and().equalTo(mmsTable.sessionField.telephone, telPhoneStr);
    } else {
      //增加contactsNum字段的判断，防止单聊通过endsWith匹配到群聊。通过CSPTest注入数据contactsNum可能是0
      condition.and().in(mmsTable.sessionField.contactsNum, [0, 1]);
      if (isFuzzyMatch) {
        //去掉国家码和空格后,取后7位进行匹配
        HiLog.w(TAG, `queryMatchedRecipient, case2 isFuzzyMatch telPhoneStr.length:${telPhoneStr?.length}`);
        condition.and().endsWith(mmsTable.sessionField.telephone, telPhoneStr.substring(telPhoneStr.length - 7));
      } else {
        //去掉国家码和空格后,endsWith去数据库匹配。为了实现有国家码的号码和不带国家码的号码会话合并
        HiLog.w(TAG, `queryMatchedRecipient, case2 isNotFuzzyMatch telPhoneStr${telPhoneStr?.length}`);
        condition.and().endsWith(mmsTable.sessionField.telephone,
          TelephoneUtil.formatDisplayPhoneNum(telPhoneStr).replace(new RegExp('[\\s]', 'g'), ''));
      }
    }
  }

  private buildSessionResult(resultSet: DataShareResultSet): ConversationListInfo {
    let id: number=Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.sessionField.id)));
    let time: number=Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.sessionField.time)));
    let telephone: string=resultSet.getString(resultSet.getColumnIndex(mmsTable.sessionField.telephone));
    let content: string=resultSet.getString(resultSet.getColumnIndex(mmsTable.sessionField.content));
    if (content.length === 0) {
      HiLog.w(TAG, 'content.length = 0')
    }
    let contactsNum: number=Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.sessionField.contactsNum)));
    let smsType: number=Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.sessionField.smsType)));
    let unreadCount: number=Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.sessionField.unreadCount)));
    let sendStatus: number=Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.sessionField.sendStatus)));
    let hasDraft: number=Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.sessionField.hasDraft)));
    let messageCount: number=Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.sessionField.messageCount)));
    let hasMms: number=Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.sessionField.hasMms)));
    let hasAttachment: number=Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.sessionField.hasAttachment)));
    let yellowPageId: string = resultSet.getString(resultSet.getColumnIndex(mmsTable.sessionField.yellowPageId));
    let blockedType: number = Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.sessionField.blockedType)));
    let pinningTime: number = Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.sessionField.pinningTime)));

    // Contacts id
    let contactId: string = '';
    if (resultSet.columnNames.indexOf(mmsTable.sessionField.contactId) !== -1) {
      contactId = resultSet.getString(resultSet.getColumnIndex(mmsTable.sessionField.contactId)) || '';
    }
    // Contacts name
    let contactName: string = '';
     if (resultSet.columnNames.indexOf(mmsTable.sessionField.contactName) !== -1) {
       contactName = resultSet.getString(resultSet.getColumnIndex(mmsTable.sessionField.contactName)) || '';
     }
    let result: ConversationListInfo = new ConversationListInfo(id, time, telephone, content, contactsNum, smsType,
      unreadCount, sendStatus, hasDraft, messageCount, hasMms, contactId, contactName, hasAttachment,
      telephone, yellowPageId, blockedType, pinningTime);
     if (!id || id == 0) {
       HiLog.w(TAG, 'query conversation the result may be empty!')
     }
    if (unreadCount > 0) {
      //维测日志，用于解决用户看不到未读消息的问题
      HiLog.w(TAG, 'smsMms badge unreadCount: ' + unreadCount + ' thread: ' + id)
      HiLog.w(TAG, 'smsMms badge last update time: ' + time + ' thread: ' + id)
    }
    return result;
  }

  private buildMmsPartPathTableColumns(): Array<string> {
    let mmsPartPathTableColumns: string[] = [
      mmsTable.mmsPart.locationPath
    ];
    return mmsPartPathTableColumns;
  }

  private buildSessionTableColumns(): Array<string> {
    let sessionTableColumns: string[] = [
    mmsTable.sessionField.id,
    mmsTable.sessionField.time,
    mmsTable.sessionField.telephone,
    mmsTable.sessionField.content,
    mmsTable.sessionField.contactsNum,
    mmsTable.sessionField.smsType,
    mmsTable.sessionField.unreadCount,
    mmsTable.sessionField.sendStatus,
    mmsTable.sessionField.hasDraft,
    mmsTable.sessionField.messageCount,
    mmsTable.sessionField.hasMms,
    mmsTable.sessionField.hasAttachment,
    mmsTable.sessionField.contactId,
    mmsTable.sessionField.contactName,
    mmsTable.sessionField.yellowPageId,
    mmsTable.sessionField.blockedType,
    mmsTable.sessionField.pinningTime
    ];
    return sessionTableColumns;
  }

  /*
   * 1.完成数据库查询数据向业务数据的转换
   * 2.整理出需要查询联系人数据库的电话号码
   * 3.整理出需要查询黄页数据库的电话号码
   * */
  private getConvertSessionListResult(sessionList: Array<ConversationListInfo>,
    context: Context, isNeedMessageSort: boolean = false): ConvertSessionListResult {
    let is24HourTime: boolean = I18n.System.is24HourClock();
    GlobalContext.getContext().setObject('is24HourTime', is24HourTime);
    let result: ConvertSessionListResult = new ConvertSessionListResult();
    if (sessionList == null) {
      return result;
    }
    let messageList: ConversationListViewInfo[] = [];
    let telephones: string[] = [];
    let telephonesForYellowPage: string[] = [];
    let telephonesForChatbot: string[] = [];
    this.dealGetConvertSessionListResult(sessionList, messageList, context);
    if (isNeedMessageSort) {
      messageList = this.setPinMsgSequence(messageList);
    }
    messageList.forEach((item) => {
      if (item.contactsNum > 1) {
        let telephoneSplit: string[] = item.telephone.split(common.STR.COMMA);
        for (let item of telephoneSplit) {
          telephones.push(item);
          telephonesForYellowPage.push(item);
        }
      } else {
        telephones.push(item.telephone);
        if (item.telephone.startsWith('sip:') && item.telephone.includes('botplatform')) {
          telephonesForChatbot.push(item.telephone);
        } else if (item.smsType == common.sms_type.NOTICE) {
          telephonesForYellowPage.push(item.telephone);
        }
      }
    })
    result.messageList = messageList as [];
    result.telephones = telephones as [];
    result.telephonesForYellowPage = telephonesForYellowPage as [];
    result.telephonesForChatbot = telephonesForChatbot as [];
    return result;
  }

  private dealGetConvertSessionListResult(sessionList: ConversationListInfo[], messageList: ConversationListViewInfo[],
    context: Context) {
    for (let session of sessionList) {
      let sessionView = new ConversationListViewInfo(session);
      this.dealMmsListContent(sessionView, context);
      messageList.push(sessionView);
    }
  }

  private dealMmsListContent(item: ConversationListViewInfo, context: Context) {
    if (item?.hasMms && item.hasAttachment) {
      let fileExtension: string = '';
      if (item.originContent.startsWith('/data/storage/el2/base/haps/entry/files/')) {
        fileExtension = item.originContent.substring(item.originContent.lastIndexOf('.') + 1);
        fileExtension = fileExtension.toLowerCase();
      }
      let imageFileExtensions = ['jpeg', 'jpg', 'png', 'gif', 'bmp', 'heic', 'heif'];
      if (imageFileExtensions.includes(fileExtension)) {
        item.content = $r('app.string.attachment_picture');
      } else if (fileExtension === 'amr' || fileExtension === 'm4a' || fileExtension === 'mp3' ||
        fileExtension === 'aac') {
        item.content = $r('app.string.attachment_audio');
      } else if (fileExtension === 'txt' || fileExtension === 'flac') {
        item.content = $r('app.string.attachment_file');
      } else if (fileExtension === 'mp4' || fileExtension === '3gp') {
        item.content = $r('app.string.attachment_video');
      } else if (isJSONString(item.originContent)) {
        item.content = this.getConversationLastMessageTips(item, context);
      } else if (StringUtil.isEmpty(item.originContent)) {
        item.content = $r('app.string.attachment_no_subject');
      } else {
        item.content = $r('app.string.attachment', item.originContent);
      }
    } else if (item.hasMms && !item.hasAttachment) {
      if (StringUtil.isEmpty(item.content as string)) {
        item.content = $r('app.string.no_subject');
      } else {
        if (isJSONString(item.originContent)) {
          item.content = this.getConversationLastMessageTips(item, context);
        } else {
          item.content = item.originContent
        }
      }
    }
  }

  private getConversationLastRcsVCardMessageTips(itemContentObject: LooseObject, item: LooseObject) {
    if (!itemContentObject || !item || itemContentObject.contactNum === undefined) {
      return $r('app.string.attachment_no_subject');
    }
    let tempObj: SessionContentTypeOfRcs = {
      isSendMessage: itemContentObject.isSendMessage ?? -1,
      contactNum: itemContentObject.contactNum ?? 0,
      contactName: itemContentObject.contactName ?? '',
    }
    if (tempObj.contactNum === 1) {
      let oppositeContactName: string = item.contactName || item.telephone || '';
      let formatOppositeContactName = oppositeContactName;
      if (oppositeContactName) {
        oppositeContactName = oppositeContactName.replace(new RegExp('\\s*', 'g'), '');
        formatOppositeContactName = TelephoneUtil.formatDisplayPhoneNum(oppositeContactName);
      }

      if (item.contactsNum === 1) { //Rcs one-to-one chat session
        if (tempObj.isSendMessage === 1) {
          return $r('app.string.rcs_ft_type_vcard_send', tempObj.contactName || '', formatOppositeContactName);
        } else if (tempObj.isSendMessage === 0) {
          return $r('app.string.rcs_ft_type_vcard_single_recv', tempObj.contactName || '', formatOppositeContactName);
        } else {
          return $r('app.string.attachment_vcard');
        }
      } else if (item.contactsNum > 1 && tempObj.isSendMessage === 1) { //Rcs group-send session
        return $r('app.string.list_summary_vcard', tempObj.contactName || '');
      } else {
        return $r('app.string.attachment_no_subject');
      }
    } else {
      return $r('app.string.attachment_vcard');
    }
  }

  private getConversationLastMessageTips(item: LooseObject, context: Context): Resource | string {
    if (!item?.content) {
      return $r('app.string.attachment_no_subject');
    }
    try {
      let value: LooseObject = JSON.parse(item.content);
      if (!value) {
        return $r('app.string.attachment_no_subject');
      }
      if (!(value instanceof Object)) {
        return $r('app.string.attachment_no_subject');
      }
      if (this.getLastMessageTips(value)) {
        return $r('app.string.msg_location_attachment');
      }

      if (ChatbotUtils.isChatbotCardMessageContent(value)) {
        return ChatbotUtils.getChatbotCardMessageSummary(context, value as BotMessage);
      }
      return this.getConversationLastRcsVCardMessageTips(value, item);
    } catch (error) {
      HiLog.e(TAG, `getConversationLastMessageTips error: ${JSON.stringify(error)}`);
      return $r('app.string.attachment_no_subject');
    }
  }

  private getLastMessageTips(value: LooseObject) {
    let tempObjLoc: RcsSendLoc = {
      body: value?.body ?? '',
      latitude: value?.latitude ?? '',
      longitude: value?.latitude ?? '',
      accuracy: value?.latitude ?? '',
    }
    if (tempObjLoc?.body && tempObjLoc?.latitude && tempObjLoc?.longitude && tempObjLoc?.accuracy) {
      return true;
    }
    return false;
  }

  public buildSessionNames(contacts: Array<LooseObject>, sessionLists: Array<LooseObject>, context: Context,
    isFromGroup: boolean = false) {
    let telephoneMap: Map<string, LooseObject> = new Map();
    //实现每个session的电话号码同步化。
    let sessionFormatPhoneNumber: string[] = this.getSessionFormatPhoneNumber(contacts, sessionLists, telephoneMap);
    let needUpdateSessionMap: Map<string, LooseObject> = new Map();
    HiLog.w(TAG,'updataContactInfoToSessionDb session');
    for (let i = 0; i < sessionLists.length; i++) {
      let session = sessionLists[i];
      //格式化后的电话号码，先用session.telephone的查询，如果查不到，再使用格式化后的查询
      let regExp = new RegExp('[\\s]', 'g');
      let formatTelephone = TelephoneUtil.formatDisplayPhoneNum(session.telephone).replace(regExp,'');
      if (session.contactsNum > 1) {
        this.dealMultiName(session, telephoneMap);
      } else if (telephoneMap.has(session.telephone)) {
        let item = telephoneMap.get(session.telephone);
        if (!isFromGroup && item && !StringUtil.isEmpty(session.threadId) &&
          (StringUtil.isEmpty(session.contactName) || session.contactName !== item.name)) {
          needUpdateSessionMap.set(session.threadId, item);
        }
        session.name = item?.name;
        session.rawContactId = item?.rawContactId;
        session.contactId = item?.contactId;
      } else if (telephoneMap.has(formatTelephone)) {
        HiLog.i(TAG, 'formatTelephone has data')
        let item = telephoneMap.get(formatTelephone);
        if (!isFromGroup && item && !StringUtil.isEmpty(session.threadId) &&
          (StringUtil.isEmpty(session.contactName) || session.contactName !== item.name)) {
          needUpdateSessionMap.set(session.threadId, item);
        }
        session.name = item?.name;
        session.rawContactId = item?.rawContactId;
        session.contactId = item?.contactId;
      } else {
        let sessionFormatTelephone = sessionFormatPhoneNumber[i];
        if (telephoneMap.has(sessionFormatTelephone)) {
          HiLog.i(TAG, 'sessionFormatTelephone has data')
          let item = telephoneMap.get(sessionFormatTelephone);
          if (!isFromGroup && item && !StringUtil.isEmpty(session.threadId) &&
            (StringUtil.isEmpty(session.contactName) || session.contactName !== item.name)) {
            needUpdateSessionMap.set(session.threadId, item);
          }
          session.name = item?.name;
          session.rawContactId = item?.rawContactId;
          session.contactId = item?.contactId;
        } else {
          //如果当前session表中，contactid不为空，但是在联系人数据库中未找到，说明被删除了，需要更新session表中联系人信息
          if (!StringUtil.isEmpty(session.contactId) && !StringUtil.isEmpty(session.threadId)) {
            let item: LooseObject = {}
            item.name = '';
            item.id = ''
            item.contactId = '';
            item.rawContactId = '';
            needUpdateSessionMap.set(session.threadId, item);
          }
        }
        // 不需要调用telephoneMapForEach去做国家码匹配，统一用Format之后的号码进行比较，这样做最多可以节约80%的时间。
      }
      this.processSessionName(session);
    }
    if (!isFromGroup && needUpdateSessionMap.size > 0) {
      HiLog.i(TAG, 'needUpdateSeeionMap size is:' + needUpdateSessionMap.size);
      taskpool.execute(updataContactInfoToSessionDb,
        needUpdateSessionMap, context).then(() => {
        HiLog.i(TAG, 'session db updata success by empty contact info')
      })
    }
    HiLog.i(TAG, 'buildSessionNames, sessionLists:' + sessionLists.length);
    return sessionLists;
  }

  private getSessionFormatPhoneNumber(contacts: LooseObject[], sessionLists: LooseObject[],
    telephoneMap: Map<string, LooseObject>) {
    let contactsTemp: string[] = [];
    for (let item of contacts) {
      contactsTemp.push(item.detailInfo);
    }
    let sessionTemp: string[] = [];
    for (let item of sessionLists) {
      sessionTemp.push(item.telephone);
    }
    let contactFormatPhoneNumber: string[] = TelephoneUtil.batchFormatPhoneNumber(contactsTemp);
    let sessionFormatPhoneNumber: string[] = TelephoneUtil.batchFormatPhoneNumber(sessionTemp);
    for (let i = 0; i < contacts.length; i++) {
      let item = contacts[i];
      let obj: LooseObject = {};
      obj.id = item.id;
      obj.rawContactId = item.rawContactId || '';
      obj.contactId = item.contactId || '';
      if (item.displayName == common.STR.EMPTY_STR) {
        obj.name = item.detailInfo;
      } else {
        obj.name = item.displayName;
      }
      let regExp = new RegExp('[\\s]', 'g');
      let formatTelephone = TelephoneUtil.formatDisplayPhoneNum(item.detailInfo).replace(regExp,'');
      if (!telephoneMap.has(item.detailInfo)) {
        telephoneMap.set(item.detailInfo, obj);
        telephoneMap.set(contactFormatPhoneNumber[i], obj);
      }
      if (!telephoneMap.has(formatTelephone)) {
        telephoneMap.set(formatTelephone, obj);
        telephoneMap.set(contactFormatPhoneNumber[i], obj);
      }
    }
    return sessionFormatPhoneNumber;
  }

  public buildSessionNamesByYellowPage(yellowPages: LooseObject[], sessionLists: LooseObject[], context: Context) {
    let yellowPageMap: Map<string, LooseObject> = new Map();
    for (let item of yellowPages) {
      let obj: LooseObject = {};
      obj.rawYellowPageId = item.id || '';
      obj.yellowPageIcon = item.photo || '';
      obj.yellowPageName = item.name || '';
      yellowPageMap.set(item.number, obj);
    }

    let sessionArray: LooseObject[] = [];
    for (let session of sessionLists) {
      if (session.contactsNum > 1) {
        this.dealMultiNameByYellowPage(session, yellowPageMap, sessionArray);
      } else if (StringUtil.isEmpty(session?.rawContactId) && yellowPageMap.has(session.telephone)) {
        let item = yellowPageMap.get(session.telephone);
        session.name = item?.yellowPageName;
        session.hasYellowPageIcon = item?.yellowPageIcon;

        if (StringUtil.isEmpty(session.yellowPageId) || session.yellowPageId !== item?.rawYellowPageId) {
          session.yellowPageId = item?.rawYellowPageId;
          sessionArray.push(session);
        }
      }
    }

    this.updateYellowData(sessionArray, context);
    return sessionLists;
  }

  public async updateYellowData(sessionArray: LooseObject[], context: Context): Promise<void> {
    HiLog.w(TAG, 'updateYellowData sessionArray ' + sessionArray.length)
    if (sessionArray == undefined || sessionArray.length == 0) {
      return;
    }

    let conditions: Record<string, string>[] = [];
    let valueBuckets: ValuesBucket[] = [];

    for (let i = 0; i < sessionArray.length; i++) {
      conditions.push({
        'telephone': sessionArray[i].telephone
      })
      valueBuckets.push(this.buildSessionValueBucket(sessionArray[i]));
    }

    this.batchUpdateSessionByCondition(context, conditions, valueBuckets, () => {});
  }

  private buildSessionValueBucket(session: LooseObject): ValuesBucket {
    return {
      'contact_name': session.name ?? '',
      'yellow_page_id': session.yellowPageId,
    };
  }

  private dealMultiNameByYellowPage(session: LooseObject, yellowPageMap: Map<string, LooseObject>,
    sessionArray: LooseObject[]): void {
    let telephones: string[] = session.telephone?.split(common.STR.COMMA);
    let rawContactIds: string[] = session.rawContactId?.split(common.STR.COMMA);
    let contactNames: string[] = session.name?.split(common.STR.CONTACT_NAME_SPLIT);
    if (telephones == null || telephones.length <= 0) {
      HiLog.e(TAG, 'telephones is null or length <= 0');
      return;
    }
    let names: string = common.STR.EMPTY_STR;
    let yellowPageIds: string = common.STR.EMPTY_STR;
    let hasYellowPageIcons: string = common.STR.EMPTY_STR;
    for (let i = 0; i < telephones.length; i++) {
      if (StringUtil.isEmpty(rawContactIds[i]) && yellowPageMap.has(telephones[i])) {
        let obj = yellowPageMap.get(telephones[i]);
        names = names + obj?.yellowPageName + common.STR.CONTACT_NAME_SPLIT;
        yellowPageIds = yellowPageIds + obj?.rawYellowPageId + common.STR.COMMA;
        hasYellowPageIcons = hasYellowPageIcons + obj?.yellowPageIcon + common.STR.COMMA;
      } else {
        names = names + contactNames[i] + common.STR.CONTACT_NAME_SPLIT;
        yellowPageIds = yellowPageIds + '' + common.STR.COMMA;
        hasYellowPageIcons = hasYellowPageIcons + '' + common.STR.COMMA;
      }
    }

    session.contactName = names.substring(0, names.length - 2);
    session.name = session.contactName
    session.hasYellowPageIcon = hasYellowPageIcons.substring(0, hasYellowPageIcons.length - 1);

    if (StringUtil.isEmpty(session.yellowPageId) ||
      session.yellowPageId !== yellowPageIds.substring(0, yellowPageIds.length - 1)) {
      session.yellowPageId = yellowPageIds.substring(0, yellowPageIds.length - 1);
      sessionArray.push(session);
    }
  }

  private dealMultiName(session: LooseObject, telephoneMap: Map<string, LooseObject>): void {
    let telephones: string[] = session.telephone.split(common.STR.COMMA);
    let telephonesFormatPhoneNumber: string[] = TelephoneUtil.batchFormatPhoneNumber(telephones);
    if (telephones == null || telephones.length <= 0) {
      HiLog.e(TAG, 'telephones is null or length <= 0');
      return;
    }
    let name: string = common.STR.EMPTY_STR;
    let rawContactId: string[] = [];
    let contactId: string[] = [];
    let contactsNameList: string[] = [];
    for (let i = 0; i < telephones.length; i++) {
      if (telephoneMap.has(telephones[i])) {
        let obj = telephoneMap.get(telephones[i]);
        name = name + obj?.name + common.STR.COMMA + ' ';
        rawContactId.push(obj?.rawContactId)
        contactId.push(obj?.contactId)
        contactsNameList.push(obj?.name); // only name is need.
      } else if (telephoneMap.has(telephonesFormatPhoneNumber[i])) {
        let obj = telephoneMap.get(telephonesFormatPhoneNumber[i]);
        name = name + obj?.name + common.STR.COMMA + ' ';
        rawContactId.push(obj?.rawContactId)
        contactsNameList.push(obj?.name); // only name is need.
        contactId.push(obj?.contactId)
      } else {
        name = name + telephones[i] + common.STR.COMMA + ' ';
        rawContactId.push('');
        contactId.push('');
        contactsNameList.push(telephones[i]); // only telephone is need.
      }
    }
    session.rawContactId = rawContactId.join(common.STR.COMMA);
    session.name = name.substring(0, name.length - 2);
    session.contactsNameList = contactsNameList;
    session.contactId = contactId.join(common.STR.COMMA);
  }

  private processSessionName(obj: LooseObject) {
    obj.isDelShow = false;
    obj.itemLeft = 0;
    obj.photoFirstNames = [];
    obj.rawContactId = obj.rawContactId;
    obj.contactId = obj.contactId;
    // processing group hair avatars
    let names: string[] = obj.name.split(common.STR.COMMA + ' ');
    for (let index = 0; index < names.length; index++) {
      let name: string = names[index];
      let photoFirstObj: LooseObject = {};
      let portraitColor: string | Resource = AvatarColor.background.Color[0];
      photoFirstObj.portraitColor = portraitColor;
      photoFirstObj.firstName = StringUtil.getFirstName(name);
      obj.photoFirstNames.push(photoFirstObj);
      if (index === 3) {
        break;
      }
    }
    obj.photoSize = this.getPhotoFirstNamesSize(obj.photoFirstNames);
    return obj;
  }

  private getPhotoFirstNamesSize(names: LooseObject[]) {
    let size: SizeObj = {
      width: '',
      height: ''
    };
    size.width = names.length > 1 ? '18' : '40';
    size.height = size.width;
    return size;
  }

  public async processMarkRead(actionData: LooseObject, context?: Context, callback?: Function | null) {
    let dataHelper:dataShare.DataShareHelper | undefined = await DataShareHelper.getInstance().initSmsDB(context!);
    if (!dataHelper) {
      HiLog.e(TAG, '[processMarkRead] createDataShareHelper fail');
      if (callback) {
        callback(this.encapsulateReturnCode(common.int.FAILURE));
      }
      return;
    }
    try {
      let condition: dataSharePredicates.DataSharePredicates = this.buildConditionForMarkRead(actionData);
      let managerUri = common.STR.URI_MESSAGE_LOG + common.STR.URI_MESSAGE_BATCH_MARK_UNREAD;
      const va: ValuesBucket = {
        'is_read': 1
      }
      dataHelper.update(managerUri, condition, va).then((data: number) => {
        HiLog.iw(TAG, 'processMarkRead succeed, data : ' + data);
        dataHelper?.notifyChange(common.STR.URI_MESSAGE_LOG + common.STR.URI_MESSAGE_SESSION_TABLE);
        if (callback) {
          callback(this.encapsulateReturnResult(common.int.SUCCESS, data));
        }
      }).catch((err: BusinessError) => {
        HiLog.e(TAG, `processMarkRead error: code: ${err.code}, message: ${err.message} `);
        if (callback) {
          callback(this.encapsulateReturnCode(common.int.FAILURE));
        }
      });
    } catch (err) {
      let code = (err as BusinessError).code;
      let message = (err as BusinessError).message;
      HiLog.e(TAG, `processMarkRead error: code: ${code}, message: ${message} `);
      if (callback) {
        callback(this.encapsulateReturnCode(common.int.FAILURE));
      }
    };
  }

  public async updateSessionUnReadBySessionId(actionData: LooseObject, va: ValuesBucket, callback: Function, context?: Context) {
    let mmsContext: Context = context ? context : GlobalContext.getContext()
      .getObject('mmsContext') as myCommon.UIAbilityContext;
    let dataHelper:dataShare.DataShareHelper | undefined = await DataShareHelper.getInstance().initSmsDB(mmsContext);
    if (!dataHelper) {
      HiLog.e(TAG, '[updateSessionUnReadBySessionId] createDataShareHelper fail');
      return;
    }

    try {
      let condition: dataSharePredicates.DataSharePredicates = this.buildSmsIsReadBySessionId(actionData);
      let managerUri = common.STR.URI_MESSAGE_LOG + common.STR.URI_MESSAGE_SESSION_TABLE;
      dataHelper.update(managerUri, condition, va).then((data: number) => {
        HiLog.i(TAG, 'markRead session succeed, data : ' + data);
      }).catch((err: BusinessError) => {
        HiLog.e(TAG, `markRead session error: code: ${err.code}, message: ${err.message} `);
      });
    } catch (err) {
      let code = (err as BusinessError).code;
      let message = (err as BusinessError).message;
      HiLog.e(TAG, `markRead session error: code: ${code}, message: ${message} `);
    };
  }

  private buildSmsIsReadBySessionId(actionData: LooseObject) : dataSharePredicates.DataSharePredicates {
    let condition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    if (actionData.markReadType == MarkRead.single) {
      condition.equalTo(mmsTable.sessionField.id, actionData.threadId);
      return condition;
    }
    if (actionData.markReadType == MarkRead.allInfo) {
      condition.in(mmsTable.sessionField.smsType, [common.sms_type.NOTICE]);
      return condition;
    }
    if (actionData.markReadType == MarkRead.all) {
      return condition;
    }
    throw new Error('buildSmsIsReadBySessionId condition not match');
  }

  private buildConditionForMarkRead(actionData: LooseObject) : dataSharePredicates.DataSharePredicates {
    let condition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    if (actionData.markReadType == MarkRead.single) {
      condition.equalTo('mark_read_way', MarkRead.single);
      condition.equalTo(mmsTable.sessionField.id, actionData.threadId);
      return condition;
    }
    if (actionData.markReadType == MarkRead.allInfo) {
      condition.equalTo('mark_read_way', MarkRead.allInfo);
      return condition;
    }
    if (actionData.markReadType == MarkRead.all) {
      condition.equalTo('mark_read_way', MarkRead.all);
      return condition;
    }
    throw new Error('buildSmsIsReadBySessionId condition not match');
  }

  public async updateAttachmentByCondition(actionData: LooseObject, valueBucket: ValuesBucket,
    context: Context): Promise<void> {
    HiLog.i(TAG, 'updateAttachmentByCondition');
    let dataHelper = await DataShareHelper.getInstance().initSmsDB(context);
    if (!dataHelper) {
      HiLog.e(TAG, `[updateAttachmentByCondition] createDataShareHelper fail`);
      return;
    }
    if (valueBucket == null) {
      HiLog.e(TAG, 'updateAttachmentByCondition fail, valueBucket is null!');
      return;
    }
    dataHelper = dataHelper as dataShare.DataShareHelper;
    let condition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    condition.equalTo(mmsTable.sessionField.id, actionData.sessionId);
    condition.and().equalTo(mmsTable.sessionField.content, '');
    let managerUri: string = common.STR.URI_MESSAGE_LOG + common.STR.URI_MESSAGE_SESSION_TABLE;
    dataHelper.update(managerUri, condition, valueBucket).then((updateRowCount: number) => {
      if (updateRowCount) {
        HiLog.i(TAG, 'updateAttachmentByCondition, update row conut' + updateRowCount);
      }
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'updateAttachmentByCondition fail, error: ' + JSON.stringify(error));
    });
  }

  private setPinMsgSequence(messageList: ConversationListViewInfo[]): ConversationListViewInfo[] {
    let pinTimeList = messageList.filter(item => item.pinningTime !== 0);
    let noPinTimeList = messageList.filter(item => item.pinningTime === 0);
    let processedRecords = pinTimeList.map(items => {
      let maxTime = Math.max(items.timeMillisecond, items.pinningTime);
      let processedRecord: processedRecord = { ConversationListViewInfo : items, timeKey : maxTime }
      return processedRecord;
    });
    processedRecords.sort((a, b) => b.timeKey - a.timeKey);
    let originalMsgList = processedRecords.map(item=> item.ConversationListViewInfo);
    // let originalMsgList = processedRecords.map(({ timeKey, ...rest }) => rest);
    messageList = [...originalMsgList, ...noPinTimeList];
    return messageList;
  }

  public async updateSessionByPinningTime(actionData: LooseObject, valueBucket: ValuesBucket, callback: Function,
    context: Context): Promise<void> {
    HiLog.i(TAG, 'updateSessionByPinningTime');
    let dataHelper = await DataShareHelper.getInstance().initSmsDB(context);
    if (!dataHelper) {
      HiLog.e(TAG, `[updateSessionByPinningTime] createDataShareHelper fail`);
      callback();
      return;
    }
    dataHelper = dataHelper as dataShare.DataShareHelper;
    let condition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    condition.equalTo(mmsTable.sessionField.id, actionData.sessionId);
    let managerUri: string = common.STR.URI_MESSAGE_LOG + common.STR.URI_MESSAGE_SESSION_TABLE;
    dataHelper.update(managerUri, condition, valueBucket).then((updateRowCount: number) => {
      if (updateRowCount) {
        HiLog.i(TAG, 'updateSessionByPinningTime, update row conut' + updateRowCount);
      }
      callback();
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'updateSessionByPinningTime fail, error: ' + JSON.stringify(error));
      callback();
    });
  }

  /**
   * 根据condition和valuesBucket更新session表
   * @returns 是否更新成功
   */
  private static updateSessionByConditionAndValue = async (context: Context, value: ValuesBucket,
    condition: dataSharePredicates.DataSharePredicates) => {
    let dataHelper: dataShare.DataShareHelper | undefined = await DataShareHelper.getInstance().initSmsDB(context);
    if (!dataHelper) {
      HiLog.e(TAG, 'updateSessionByConditionAndValue: createDataShareHelper fail');
      return false;
    }

    try {
      const managerUri = common.STR.URI_MESSAGE_LOG + common.STR.URI_MESSAGE_SESSION_TABLE;
      let res = await dataHelper.update(managerUri, condition, value).then(() => {
        HiLog.i(TAG, 'updateSessionByConditionAndValue: update success');
        return true;
      }).catch((e: BusinessError) => {
        HiLog.e(TAG, `updateSessionByConditionAndValue: update error: ${e?.code} ${e?.message}`);
        return false;
      });
      return res;
    } catch (e) {
      HiLog.e(TAG, `updateSessionByConditionAndValue error: ${e?.code} ${e?.message}`);
      return false;
    }
  }

  /**
   * 在向服务器请求应用号详情后，根据应用号名称更新会话表
   * @param context Context
   * @param contactName 会话的联系人名称
   * @param serviceId 应用号的服务器ID
   * @returns 是否更新成功
   */
  public static updateSessionAfterRequestChatbot = async (context: Context, contactName: string, serviceId: string) => {
    HiLog.i(TAG, 'updateSessionAfterRequestChatbot');
    if (!context || !serviceId) {
      HiLog.e(TAG, 'updateSessionAfterRequestChatbot: context or serviceId empty');
      return false;
    }

    const CONTACT_NAME = 'contact_name';
    const TELEPHONE = 'telephone';
    try {
      let value: ValuesBucket = {};
      value[CONTACT_NAME] = contactName;
      let condition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
      condition.equalTo(TELEPHONE, serviceId);
      return await ConversationListModel.updateSessionByConditionAndValue(context, value, condition);
    } catch (e) {
      HiLog.e(TAG, `updateSessionAfterRequestChatbot error: ${e?.code} ${e?.message}`);
      return false;
    }
  }

  /**
   * 更新指定sessionId的会话
   * @param actionData 更新条件对象
   * @param valueBucket 需要更新的数据
   * @param callback 返回更新结果的回调函数
   * @param context Context
   */
  public async updateSessionContent(actionData: LooseObject, valueBucket: ValuesBucket, callback: Function | null,
    context: Context): Promise<void> {
    HiLog.i(TAG, 'updateSessionContent');
    let dataHelper = await DataShareHelper.getInstance().initSmsDB(context);
    if (!dataHelper) {
      HiLog.e(TAG, `[updateSessionContent] createDataShareHelper fail`);
      if (callback) {
        callback(this.encapsulateReturnCode(common.int.FAILURE));
      }
      return;
    }
    dataHelper = dataHelper as dataShare.DataShareHelper;
    let condition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    condition.equalTo(mmsTable.sessionField.id, actionData.sessionId);
    if (valueBucket == null) {
      HiLog.e(TAG, 'updateSessionContent fail, valueBucket is null!');
      if (callback) {
        callback(this.encapsulateReturnCode(common.int.FAILURE));
      }
      return;
    }
    let managerUri: string = common.STR.URI_MESSAGE_LOG + common.STR.URI_MESSAGE_SESSION_TABLE;
    dataHelper.update(managerUri, condition, valueBucket).then((updateRowCount: number) => {
      HiLog.i(TAG, `updateSessionContent success, updateRowCount: ${updateRowCount}`);
      if (callback) {
        callback(this.encapsulateReturnResult(common.int.SUCCESS, updateRowCount));
      }
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'updateSessionContent fail, error: ' + JSON.stringify(error));
      if (callback) {
        callback(this.encapsulateReturnCode(common.int.FAILURE));
      }
    });
  }
}

/**
 * 根据联系人数据去更新session表中联系人信息，防止融合搜搜索联系人名称搜索不到数据
 * @param needsUpdataSessionMap ：需要更新的session
 * @param context
 * @returns
 */
@Concurrent
export async function updataContactInfoToSessionDb(needsUpdataSessionMap: Map<string, LooseObject>,
  context: Context): Promise<void> {
  needsUpdataSessionMap.forEach((value: LooseObject, key: string) => {
    if (value !== undefined) {
      let valueBucket: ValuesBucket = {
        'contact_name': value.name,
        'contact_id': value.contactId || '',
      }
      let actionInfo: ValuesBucket = {
        'threadId': key,
      }
      HiLog.w('updataContactInfoToSessionDb','need contact info. session id is: ' + key);
      ConversationListService.getInstance()
        .updateSessionByCondition(context, actionInfo, valueBucket, (res: Object) => {
          HiLog.e('updataContactInfoToSessionDb', 'updateSessionByContact result: ' + JSON.stringify(res));
        }, true);
    }
  });
}

interface processedRecord {
  ConversationListViewInfo: ConversationListViewInfo,
  timeKey: number
}