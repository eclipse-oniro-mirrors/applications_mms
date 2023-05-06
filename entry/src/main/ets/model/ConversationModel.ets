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

const TAG = "ConversationModel";


export default class ConversationModel extends BaseModel {
  public async insertSmsMmsInfo(valueBucket, callback, context): Promise<void> {
    let dataHelper = await dataShare.createDataShareHelper(context, common.string.URI_MESSAGE_LOG);
    let managerUri: string = common.string.URI_MESSAGE_LOG + common.string.URI_MESSAGE_INFO_TABLE;
    dataHelper.insert(managerUri, valueBucket).then(res => {
      if (callback) {
        callback(this.encapsulateReturnResult(common.int.SUCCESS, res));
      }
    }).catch(error => {
      HiLog.e(TAG, "insertSmsMmsInfo fail, error: " + JSON.stringify(error));
      if (callback) {
        callback(this.encapsulateReturnCode(common.int.FAILURE));
      }
    });
  }

  public async deleteSmsMmsInfoByCondition(actionData, callback, context): Promise<void> {
    let dataHelper = await dataShare.createDataShareHelper(context, common.string.URI_MESSAGE_LOG);
    let condition: dataSharePredicates.DataSharePredicates = this.buildQuerySmsMmsInfoCondition(actionData);
    let managerUri: string = common.string.URI_MESSAGE_LOG + common.string.URI_MESSAGE_INFO_TABLE;
    dataHelper.delete(managerUri, condition).then(res => {
      if (callback) {
        callback(this.encapsulateReturnResult(common.int.SUCCESS, res));
      }
    }).catch(error => {
      HiLog.e(TAG, "deleteSmsMmsInfoByCondition fail, error: " + JSON.stringify(error));
      if (callback) {
        callback(this.encapsulateReturnCode(common.int.FAILURE));
      }
    });
  }

  public async updateSmsMmsInfoByCondition(actionData, valueBucket, callback, context): Promise<void> {
    let dataHelper = await dataShare.createDataShareHelper(context, common.string.URI_MESSAGE_LOG);
    let condition: dataSharePredicates.DataSharePredicates = this.buildQuerySmsMmsInfoCondition(actionData);
    let managerUri = common.string.URI_MESSAGE_LOG + common.string.URI_MESSAGE_INFO_TABLE;
    dataHelper.update(managerUri, condition, valueBucket).then(res => {
      if (callback) {
        callback(this.encapsulateReturnResult(common.int.SUCCESS, res));
      }
    }).catch(error => {
      HiLog.e(TAG, "updateSmsMmsInfoByCondition fail, error: " + JSON.stringify(error));
      if (callback) {
        callback(this.encapsulateReturnCode(common.int.FAILURE));
      }
    });
  }

  public async querySmsMmsInfoByCondition(actionData, callback, context): Promise<void> {
    let dataHelper = await dataShare.createDataShareHelper(context, common.string.URI_MESSAGE_LOG);
    let condition: dataSharePredicates.DataSharePredicates = this.buildQuerySmsMmsInfoCondition(actionData);
    let managerUri = common.string.URI_MESSAGE_LOG + common.string.URI_MESSAGE_INFO_TABLE;
    dataHelper.query(managerUri, condition, this.buildSmsMmsInfoTableColumns()).then(resultSet => {
      let resultList: Array<LooseObject> = [];
      if (resultSet.rowCount > 0) {
        while (resultSet.goToNextRow()) {
          resultList.push(this.buildSmsMmsInfoResult(resultSet));
        }
      }
      callback(this.encapsulateReturnResult(common.int.SUCCESS, resultList));
      resultSet.close();
    }).catch(error => {
      HiLog.e(TAG, "querySmsMmsInfoByCondition fail, error: " + JSON.stringify(error));
      callback(this.encapsulateReturnCode(common.int.FAILURE));
    });
  }

  public async querySmsMmsInfoSizeByCondition(actionData, callback, context): Promise<void> {
    let dataHelper = await dataShare.createDataShareHelper(context, common.string.URI_MESSAGE_LOG);
    let condition: dataSharePredicates.DataSharePredicates = this.buildQuerySmsMmsInfoCondition(actionData);
    let managerUri = common.string.URI_MESSAGE_LOG + common.string.URI_MESSAGE_INFO_TABLE;
    dataHelper.query(managerUri, condition, this.buildSmsMmsInfoTableColumns()).then(resultSet => {
      callback(this.encapsulateReturnResult(common.int.SUCCESS, resultSet.rowCount));
      resultSet.close();
    }).catch(error => {
      HiLog.e(TAG, "querySmsMmsInfoSizeByCondition fail, error: " + JSON.stringify(error));
      callback(this.encapsulateReturnCode(common.int.FAILURE));
    });
  }

  public async queryMaxGroupId(callback, context): Promise<void> {
    let dataHelper = await dataShare.createDataShareHelper(context, common.string.URI_MESSAGE_LOG);
    let resultColumns: Array<string> = ["maxGroupId"];
    let condition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    let managerUri: string = common.string.URI_MESSAGE_LOG + common.string.URI_MESSAGE_MAX_GROUP;
    dataHelper.query(managerUri, condition, resultColumns).then(resultSet => {
      let maxGroupId: number = 0;
      if (resultSet.rowCount > 0) {
        if (resultSet.goToLastRow()) {
          maxGroupId = (resultSet.getString(0) == common.string.EMPTY_STR) ? 0 : Number(resultSet.getString(0));
          HiLog.i(TAG, "queryMaxGroupId, maxGroupId: " + maxGroupId);
        }
      }
      callback(this.encapsulateReturnResult(common.int.SUCCESS, maxGroupId));
      resultSet.close();
    }).catch(error => {
      HiLog.e(TAG, "queryMaxGroupId fail, error: " + JSON.stringify(error));
      callback(this.encapsulateReturnCode(common.int.FAILURE));
    });
  }

  public async statisticalData(callback, context) {
    let dataHelper = await dataShare.createDataShareHelper(context, common.string.URI_MESSAGE_LOG);
    let resultColumns: Array<string> = [
      "totalListCount",
      "unreadCount",
      "unreadTotalOfInfo"
    ];
    let condition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    let managerUri: string = common.string.URI_MESSAGE_LOG + common.string.URI_MESSAGE_UNREAD_COUNT;
    dataHelper.query(managerUri, condition, resultColumns).then(resultSet => {
      let result: LooseObject = {
        "totalListCount": 0,
        "unreadCount": 0,
        "unreadTotalOfInfo": 0
      };
      if (resultSet.rowCount > 0) {
        if (resultSet.goToLastRow()) {
          result.totalListCount = Number(resultSet.getString(0));
          result.unreadCount = Number(resultSet.getString(1));
          result.unreadTotalOfInfo = Number(resultSet.getString(2));
        }
      }
      callback(this.encapsulateReturnResult(common.int.SUCCESS, result));
    }).catch(error => {
      HiLog.e(TAG, "statisticalData, error: " + JSON.stringify(error));
      callback(this.encapsulateReturnCode(common.int.FAILURE));
    });
  }

  private buildQuerySmsMmsInfoCondition(actionData): dataSharePredicates.DataSharePredicates {
    let condition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    condition.isNotNull(mmsTable.messageInfo.msgId)
    if (actionData.threadId != null) {
      let sessionId: string = actionData.threadId + common.string.EMPTY_STR;
      condition.and().equalTo(mmsTable.messageInfo.sessionId, sessionId);
    }
    if (actionData.hasLock != null) {
      condition.and().equalTo(mmsTable.messageInfo.isLock, actionData.hasLock);
    }
    if (actionData.hasRead != null) {
      condition.and().equalTo(mmsTable.messageInfo.isRead, actionData.hasRead);
    }
    if (actionData.smsType != null) {
      condition.and().equalTo(mmsTable.messageInfo.smsType, actionData.smsType);
    }
    if (actionData.msgId != null) {
      condition.and().equalTo(mmsTable.messageInfo.msgId, actionData.msgId);
    }
    if (actionData.isDraft != null && actionData.isDraft) {
      condition.and().equalTo(mmsTable.messageInfo.groupId, actionData.groupId);
      condition.and().equalTo(mmsTable.messageInfo.msgState, actionData.sendStatus);
    }
    if (actionData.threadIds != null && actionData.threadIds.length > 0) {
      condition.and().in(mmsTable.messageInfo.sessionId, actionData.threadIds);
    }
    if (actionData.msgIds != null && actionData.msgIds.length > 0) {
      condition.and().in(mmsTable.messageInfo.msgId, actionData.msgIds);
    }
    if (actionData.groupIds != null && actionData.groupIds.length > 0) {
      condition.and().in(mmsTable.messageInfo.groupId, actionData.groupIds);
    }
    if (actionData.groupId != null) {
      condition.and().equalTo(mmsTable.messageInfo.groupId, actionData.groupId);
    }
    return condition;
  }

  private buildSmsMmsInfoTableColumns(): Array<string> {
    let resultColumns: Array<string> = [
    mmsTable.messageInfo.msgId,
    mmsTable.messageInfo.slotId,
    mmsTable.messageInfo.receiverNumber,
    mmsTable.messageInfo.senderNumber,
    mmsTable.messageInfo.startTime,
    mmsTable.messageInfo.endTime,
    mmsTable.messageInfo.msgType,
    mmsTable.messageInfo.smsType,
    mmsTable.messageInfo.msgTitle,
    mmsTable.messageInfo.msgContent,
    mmsTable.messageInfo.msgState,

    mmsTable.messageInfo.operatorServiceNumber,
    mmsTable.messageInfo.msgCode,
    mmsTable.messageInfo.isLock,
    mmsTable.messageInfo.isRead,
    mmsTable.messageInfo.isCollect,
    mmsTable.messageInfo.sessionType,
    mmsTable.messageInfo.retryNumber,
    mmsTable.messageInfo.isSubsection,
    mmsTable.messageInfo.sessionId,
    mmsTable.messageInfo.groupId,
    mmsTable.messageInfo.isSender,
    mmsTable.messageInfo.isSendReport
    ];
    return resultColumns;
  }

  private buildSmsMmsInfoResult(resultSet): LooseObject {
    let result: LooseObject = {};
    result.msgId = Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.messageInfo.msgId)));
    result.slotId = Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.messageInfo.slotId)));
    result.receiverNumber = resultSet.getString(resultSet.getColumnIndex(mmsTable.messageInfo.receiverNumber));
    result.senderNumber = resultSet.getString(resultSet.getColumnIndex(mmsTable.messageInfo.senderNumber));
    result.startTime = resultSet.getString(resultSet.getColumnIndex(mmsTable.messageInfo.startTime));
    result.endTime = resultSet.getString(resultSet.getColumnIndex(mmsTable.messageInfo.endTime));
    result.msgType = Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.messageInfo.msgType)));
    result.smsType = Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.messageInfo.smsType)));
    result.msgTitle = resultSet.getString(resultSet.getColumnIndex(mmsTable.messageInfo.msgTitle));
    result.msgContent = resultSet.getString(resultSet.getColumnIndex(mmsTable.messageInfo.msgContent));
    result.msgState = Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.messageInfo.msgState)));

    result.operatorServiceNumber = resultSet.getString(resultSet.getColumnIndex(mmsTable.messageInfo.operatorServiceNumber));
    result.msgCode = Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.messageInfo.msgCode)));
    result.isLock = Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.messageInfo.isLock)));
    result.isRead = Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.messageInfo.isRead)));
    result.isCollect = Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.messageInfo.isCollect)));
    result.sessionType = Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.messageInfo.sessionType)));
    result.retryNumber = Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.messageInfo.retryNumber)));
    result.isSubsection = Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.messageInfo.isSubsection)));
    result.sessionId = Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.messageInfo.sessionId)));
    result.groupId = Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.messageInfo.groupId)));
    result.isSender = Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.messageInfo.isSender)));
    result.isSendReport = Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.messageInfo.isSendReport)));
    return result;
  }
}