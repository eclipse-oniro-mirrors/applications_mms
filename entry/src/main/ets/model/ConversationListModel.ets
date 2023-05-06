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

import dataShare from '@ohos.data.dataShare';
import dataSharePredicates from '@ohos.data.dataSharePredicates';

import BaseModel from './BaseModel';
import common from '../data/commonData';
import mmsTable from '../data/tableData';
import HiLog from '../utils/HiLog';
import LooseObject from '../data/LooseObject';
import StringUtil from '../utils/StringUtil';

const TAG = "ConversationListModel";

export default class ConversationListModel extends BaseModel {
  public async insertSession(valueBucket, callback, context): Promise<void> {
    let dataHelper = await dataShare.createDataShareHelper(context, common.string.URI_MESSAGE_LOG);
    let managerUri: string = common.string.URI_MESSAGE_LOG + common.string.URI_MESSAGE_SESSION_TABLE;
    dataHelper.insert(managerUri, valueBucket).then(data => {
      if (callback) {
        callback(this.encapsulateReturnResult(common.int.SUCCESS, data));
      }
    }).catch(error => {
      HiLog.e(TAG, "insertSession fail, error: " + JSON.stringify(error));
      if (callback) {
        callback(this.encapsulateReturnCode(common.int.FAILURE));
      }
    });
  }

  public async deleteSessionByCondition(actionData, callback, context): Promise<void> {
    let dataHelper = await dataShare.createDataShareHelper(context, common.string.URI_MESSAGE_LOG);
    let condition: dataSharePredicates.DataSharePredicates = this.buildQuerySessionCondition(actionData);
    let managerUri: string = common.string.URI_MESSAGE_LOG + common.string.URI_MESSAGE_SESSION_TABLE;
    dataHelper.delete(managerUri, condition).then(data => {
      if (callback) {
        callback(this.encapsulateReturnResult(common.int.SUCCESS, data));
      }
    }).catch(error => {
      HiLog.e(TAG, "deleteSessionByCondition, error: " + JSON.stringify(error));
      if (callback) {
        callback(this.encapsulateReturnCode(common.int.FAILURE));
      }
    });
  }

  public async updateSessionByCondition(actionData, valueBucket, callback, context): Promise<void> {
    let dataHelper = await dataShare.createDataShareHelper(context, common.string.URI_MESSAGE_LOG);
    let condition: dataSharePredicates.DataSharePredicates = this.buildQuerySessionCondition(actionData);
    if (valueBucket == null) {
      HiLog.e(TAG, "updateSessionByCondition fail, valueBucket is null!");
      if (callback) {
        callback(this.encapsulateReturnCode(common.int.FAILURE));
      }
    }
    let managerUri: string = common.string.URI_MESSAGE_LOG + common.string.URI_MESSAGE_SESSION_TABLE;
    dataHelper.update(managerUri, condition, valueBucket).then(data => {
      if (callback) {
        callback(this.encapsulateReturnResult(common.int.SUCCESS, data));
      }
    }).catch(error => {
      HiLog.e(TAG, "updateSessionByCondition fail, error: " + JSON.stringify(error));
      if (callback) {
        callback(this.encapsulateReturnCode(common.int.FAILURE));
      }
    });
  }

  public async querySessionByCondition(actionData, callback, context): Promise<void> {
    let dataHelper = await dataShare.createDataShareHelper(context, common.string.URI_MESSAGE_LOG);
    let condition: dataSharePredicates.DataSharePredicates = this.buildQuerySessionCondition(actionData);
    let managerUri: string = common.string.URI_MESSAGE_LOG + common.string.URI_MESSAGE_SESSION_TABLE;
    dataHelper.query(managerUri, condition, this.buildSessionTableColumns()).then(resultSet => {
      let resultList: Array<LooseObject> = [];
      if (resultSet.rowCount > 0) {
        while (resultSet.goToNextRow()) {
          resultList.push(this.buildSessionResult(resultSet));
        }
      } else {
        resultSet.goToFirstRow();
        resultList.push(this.buildSessionResult(resultSet));
      }
      callback(this.encapsulateReturnResult(common.int.SUCCESS, resultList));
      resultSet.close();
    }).catch(error => {
      HiLog.e(TAG, "querySessionByCondition fail, error: " + JSON.stringify(error));
      callback(this.encapsulateReturnCode(common.int.FAILURE));
    });
  }

  public async querySessionSizeByCondition(actionData, callback, context): Promise<void> {
    let dataHelper = await dataShare.createDataShareHelper(context, common.string.URI_MESSAGE_LOG);
    let condition: dataSharePredicates.DataSharePredicates = this.buildQuerySessionCondition(actionData);
    let managerUri: string = common.string.URI_MESSAGE_LOG + common.string.URI_MESSAGE_SESSION_TABLE;
    dataHelper.query(managerUri, condition, this.buildSessionTableColumns()).then(resultSet => {
      callback(this.encapsulateReturnResult(common.int.SUCCESS, resultSet.rowCount));
    }).catch(error => {
      HiLog.e(TAG, "querySessionSizeByCondition, fail, error: " + JSON.stringify(error));
      callback(this.encapsulateReturnCode(common.int.FAILURE));
    });
  }

  private buildQuerySessionCondition(actionData): dataSharePredicates.DataSharePredicates {
    let condition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    condition.isNotNull(mmsTable.sessionField.id);
    if (actionData.smsType != null) {
      condition.and().equalTo(mmsTable.sessionField.smsType, actionData.smsType);
    }
    if (actionData.telephone != null) {
      condition.and().equalTo(mmsTable.sessionField.telephone, actionData.telephone);
    }
    if (actionData.telephone_like != null) {
      condition.and().like(mmsTable.sessionField.telephone, "%" + actionData.telephone_like + "%");
    }
    if (actionData.threadId != null) {
      condition.and().equalTo(mmsTable.sessionField.id, actionData.threadId);
    }
    if (actionData.threadIds != null && actionData.threadIds.length > 0) {
      condition.and().in(mmsTable.sessionField.id, actionData.threadIds);
    }
    if (actionData.unreadCount_greaterThan != null) {
      condition.and().greaterThan(mmsTable.sessionField.unreadCount, actionData.unreadCount_greaterThan);
    }
    if (actionData.orderByTimeDesc) {
      condition.orderByDesc(mmsTable.sessionField.time);
    }
    if (actionData.page != null && actionData.limit != null) {
      condition.limit(actionData.limit, StringUtil.getOffsetForSession(actionData.page));
    }
    return condition;
  }

  private buildSessionResult(resultSet): LooseObject {
    let result: LooseObject = {};
    result.id = Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.sessionField.id)));
    result.time = Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.sessionField.time)));
    result.telephone = resultSet.getString(resultSet.getColumnIndex(mmsTable.sessionField.telephone));
    result.content = resultSet.getString(resultSet.getColumnIndex(mmsTable.sessionField.content));
    result.contactsNum = Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.sessionField.contactsNum)));
    result.smsType = Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.sessionField.smsType)));
    result.unreadCount = Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.sessionField.unreadCount)));
    result.sendStatus = Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.sessionField.sendStatus)));
    result.hasDraft = Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.sessionField.hasDraft)));
    result.hasLock = Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.sessionField.hasLock)));
    result.messageCount = Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.sessionField.messageCount)));
    result.hasMms = Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.sessionField.hasMms)));
    result.hasAttachment = Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.sessionField.hasAttachment)));
    result.telephoneFormat = result.telephone;
    return result;
  }

  private buildSessionTableColumns(): Array<string> {
    let sessionTableColumns: Array<string> = [
    mmsTable.sessionField.id,
    mmsTable.sessionField.time,
    mmsTable.sessionField.telephone,
    mmsTable.sessionField.content,
    mmsTable.sessionField.contactsNum,
    mmsTable.sessionField.smsType,
    mmsTable.sessionField.unreadCount,
    mmsTable.sessionField.sendStatus,
    mmsTable.sessionField.hasDraft,
    mmsTable.sessionField.hasLock,
    mmsTable.sessionField.messageCount,
    mmsTable.sessionField.hasMms,
    mmsTable.sessionField.hasAttachment
    ];
    return sessionTableColumns;
  }
}