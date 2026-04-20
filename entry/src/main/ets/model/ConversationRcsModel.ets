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
import common, { MarkRead } from '../data/commonData';
import mmsTable from '../data/tableData';
import HiLog from '../utils/HiLog';
import LooseObject from '../data/LooseObject';
import { BusinessError } from '@ohos.base';
import { ValuesBucket } from '@ohos.data.ValuesBucket';
import DataShareResultSet from '@ohos.data.DataShareResultSet';
import { ConversationRcsInfo } from './conversationlist/ConversationRcsInfo';
// import rcs from '@ohos.telephony.rcs';
import DataShareHelper from './repository/DataShareHelper';
import { GlobalContext } from '../MainAbility/GlobalHelper';
import myCommon from '@ohos.app.ability.common';
import { UnLockedNotifyService } from '../utils/UnLockedNotifyService';
import commonData from '../data/commonData';
import { systemDateTime } from '@kit.BasicServicesKit';

const TAG = 'ConversationRcsModel';

export default class ConversationRcsModel extends BaseModel {
  public async insertRcsMmsInfo(valueBucket: ValuesBucket, callback: Function, context: Context): Promise<void> {
    HiLog.i(TAG, `insertRcsMmsInfo`);
    let dataHelper: dataShare.DataShareHelper | undefined = await DataShareHelper.getInstance().initSmsDB(context);
    if (!dataHelper) {
      HiLog.e(TAG, `[insertRcsMmsInfo] createDataShareHelper fail`);
      if (callback) {
        callback(this.encapsulateReturnCode(common.int.FAILURE));
      }
      return;
    }
    this.insertRcsMmsInfoHandleCreate(valueBucket, dataHelper, callback);
    return;
  }

  public insertRcsMmsInfoHandleCreate(valueBucket: ValuesBucket, dataHelper: dataShare.DataShareHelper, callback: Function) {
    HiLog.i(TAG, `insertRcsMmsInfo insertRcsMmsInfoHandleCreate`);
    let managerUri: string = common.STR.URI_MESSAGE_LOG + common.STR.URI_RCS_MESSAGE_INFO_TABLE;
    try {
      dataHelper?.insert(managerUri, valueBucket).then((res: string | number | LooseObject) => {
        this.insertRcsMmsInfoHandleInsertSuccess(res, callback);
      }).catch((error: BusinessError) => {
        this.insertRcsMmsInfoHandleInsertFail(error, callback);
      });
    } catch (e) {
      HiLog.e(TAG, 'insertRcsMmsInfoHandleCreate insert rcs_info fail, error: ' + JSON.stringify(e));
    }
    return;
  }

  public insertRcsMmsInfoHandleInsertSuccess(res: string | number | LooseObject, callback: Function) {
    HiLog.i(TAG, `insertRcsMmsInfo insertRcsMmsInfoHandleInsertSuccess callback`);
    if (callback) {
      callback(this.encapsulateReturnResult(common.int.SUCCESS, res));
    }
    return;
  }

  public insertRcsMmsInfoHandleInsertFail(error: BusinessError, callback: Function) {
    HiLog.e(TAG, 'insertRcsMmsInfo insertRcsMmsInfoHandleInsertFail insert fail, error: ' + JSON.stringify(error));
    if (callback) {
      callback(this.encapsulateReturnCode(common.int.FAILURE));
    }
    return;
  }

  public async queryMaxGroupIdRcs(callback: Function, context: Context): Promise<void> {
    HiLog.i(TAG, 'queryMaxGroupIdRcs, IN: ');
    let dataHelper:dataShare.DataShareHelper | undefined = await DataShareHelper.getInstance().initSmsDB(context);
    if (!dataHelper) {
      HiLog.e(TAG, `[queryMaxGroupIdRcs] createDataShareHelper fail`);
      if (callback) {
        callback(this.encapsulateReturnCode(common.int.FAILURE));
      }
      return;
    }
    let resultColumns: Array<string> = ['maxGroupId'];
    // let condition: dataSharePredicates.DataSharePredicates = ConversationRcsModel.buildRcsInfoSlotIdCondition(phoneNumber)
    let condition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    let managerUri: string = common.STR.URI_MESSAGE_LOG + common.STR.URI_RCS_MESSAGE_INFO_TABLE;
    dataHelper.query(managerUri, condition, ['*']).then(resultSet => {
      let maxGroupId: number = 0;
      let resultList: Array<ConversationRcsInfo> = [];
      if (resultSet.rowCount > 0) {
        if (resultSet.goToLastRow()) {
          resultList.push(this.buildRcsInfoResult(resultSet));
          if(resultList.length!==0) {
            maxGroupId = resultList[0].groupId;
          }
        }
      }
      callback(this.encapsulateReturnResult(common.int.SUCCESS, maxGroupId));
      resultSet.close();
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'queryMaxGroupIdRcs fail, error: ' + JSON.stringify(error));
      callback(this.encapsulateReturnCode(common.int.FAILURE));
    });
  }

  public async queryRcsInfoSlotIdByCondition(phoneNumber: string, callback: Function, context: Context): Promise<void> {
    HiLog.i(TAG, `queryRcsInfoSlotIdByCondition`);
    let dataHelper:dataShare.DataShareHelper | undefined = await DataShareHelper.getInstance().initSmsDB(context);
    if (!dataHelper) {
      HiLog.e(TAG, `[queryRcsInfoSlotIdByCondition] createDataShareHelper fail`);
      if (callback) {
        callback(this.encapsulateReturnCode(common.int.FAILURE));
      }
      return;
    }
    this.queryRcsInfoSlotIdByConditionHandleCreate(dataHelper, callback, phoneNumber);
    return;
  }

  public queryRcsInfoSlotIdByConditionHandleCreate(dataHelper: dataShare.DataShareHelper, callback: Function, phoneNumber: string) {
    HiLog.i(TAG, `queryRcsInfoSlotIdByCondition queryRcsInfoSlotIdByConditionHandleCreate`);
    let managerUri = common.STR.URI_MESSAGE_LOG + common.STR.URI_RCS_MESSAGE_INFO_TABLE;
    let condition: dataSharePredicates.DataSharePredicates = this.buildRcsInfoSlotIdCondition(phoneNumber)
    dataHelper?.query(managerUri, condition, ['slot_id']).then((resultSet: DataShareResultSet) => {
      this.queryRcsInfoSlotIdByConditionQuerySuccess(resultSet, callback);
      resultSet.close();
    }).catch((error: BusinessError) => {
      this.queryRcsInfoSlotIdByConditionQueryFail(error, callback);
    })
    return;
  }

  public queryRcsInfoSlotIdByConditionQuerySuccess(resultSet: DataShareResultSet, callback: Function) {
    HiLog.i(TAG, `queryRcsInfoSlotIdByCondition queryRcsInfoSlotIdByConditionQuerySuccess`);
    let slotId = -1;
    if (resultSet.rowCount > 0) {
      resultSet.goToFirstRow();
      slotId = resultSet.getLong(0);
    }
    callback(this.encapsulateReturnResult(common.int.SUCCESS, slotId));
    resultSet.close();
    return;
  }

  public queryRcsInfoSlotIdByConditionQueryFail(error: BusinessError, callback: Function) {
    HiLog.e(TAG, 'queryRcsInfoSlotIdByCondition queryRcsInfoSlotIdByConditionQueryFail fail, error: ' + JSON.stringify(error));
    callback(this.encapsulateReturnCode(common.int.FAILURE));
    return;
  }

  public async queryRcsInfoByCondition(actionData: LooseObject, callback: Function, context: Context): Promise<void> {
    HiLog.i(TAG, 'queryRcsInfoByCondition');
    let dataHelper: dataShare.DataShareHelper | undefined = await DataShareHelper.getInstance().initSmsDB(context);
    if (!dataHelper) {
      HiLog.e(TAG, `[queryRcsInfoByCondition] createDataShareHelper fail`);
      if (callback) {
        callback(this.encapsulateReturnCode(common.int.FAILURE));
      }
      return;
    }
    this.queryRcsInfoByConditionHandleCreate(actionData, callback, dataHelper);
    return;
  }

  public queryRcsInfoByConditionHandleCreate(actionData: LooseObject, callback: Function, dataHelper: dataShare.DataShareHelper) {
    HiLog.i(TAG, 'queryRcsInfoByCondition queryRcsInfoByConditionHandleCreate');
    let condition: dataSharePredicates.DataSharePredicates = this.buildQueryRcsInfoCondition(actionData);
    HiLog.i(TAG, 'queryRcsInfoByCondition queryRcsInfoByConditionHandleCreate condition.threadId: ' + actionData.threadId);
    let managerUri = common.STR.URI_MESSAGE_LOG + common.STR.URI_RCS_MESSAGE_INFO_TABLE;
    dataHelper?.query(managerUri, condition, this.buildRcsInfoTableColumns()).then((resultSet: DataShareResultSet) => {
      this.queryRcsInfoByConditionHandleQuerySuccess(resultSet, callback);
      resultSet.close();
    }).catch((error: BusinessError) => {
      this.queryRcsInfoByConditionHandleQueryFail(error, callback);
    });
    return;
  }

  public queryRcsInfoByConditionHandleQuerySuccess(resultSet: DataShareResultSet, callback: Function) {
    HiLog.i(TAG, 'queryRcsInfoByCondition queryRcsInfoByConditionHandleQuerySuccess resultSet.rowCount: ' + JSON.stringify(resultSet.rowCount));
    let resultList: Array<ConversationRcsInfo> = [];
    if (resultSet.rowCount > 0) {
      while (resultSet.goToNextRow()) {
        resultList.push(this.buildRcsInfoResult(resultSet));
        HiLog.i(TAG, 'queryRcsInfoByCondition queryRcsInfoByConditionHandleQuerySuccess actionData: ' + JSON.stringify(resultList.length));
      }
    }
    callback(this.encapsulateReturnResult(common.int.SUCCESS, resultList));
    resultSet.close();
    return;
  }

  public queryRcsInfoByConditionHandleQueryFail(error: BusinessError, callback: Function) {
    HiLog.e(TAG, 'queryRcsInfoByCondition queryRcsInfoByConditionHandleQueryFail fail, error: ' + JSON.stringify(error));
    callback(this.encapsulateReturnCode(common.int.FAILURE));
    return;
  }

  public async queryRcsInfoSizeByCondition(actionData: LooseObject, callback: Function, context: Context): Promise<void> {
    HiLog.i(TAG, 'queryRcsInfoSizeByCondition');
    let dataHelper:dataShare.DataShareHelper | undefined = await DataShareHelper.getInstance().initSmsDB(context);
    if (!dataHelper) {
      HiLog.e(TAG, `[queryRcsInfoSizeByCondition] createDataShareHelper fail`);
      if (callback) {
        callback(this.encapsulateReturnCode(common.int.FAILURE));
      }
      return;
    }
    let condition: dataSharePredicates.DataSharePredicates = this.buildQueryRcsInfoCondition(actionData);
    let managerUri = common.STR.URI_MESSAGE_LOG + common.STR.URI_RCS_MESSAGE_INFO_TABLE;
    let queryStr = 'count(distinct group_id) as total';
    if (actionData.contactsNum && actionData.contactsNum == 1) {
      queryStr = 'count(*) as total'
    }
    dataHelper.query(managerUri, condition, [queryStr]).then((resultSet: DataShareResultSet) => {
      if (resultSet.rowCount <= 0) {
        resultSet.close();
        callback(this.encapsulateReturnCode(common.int.FAILURE));
        return;
      }
      resultSet.goToFirstRow();
      let rcsTotal = resultSet.getLong(resultSet.getColumnIndex('total'));
      HiLog.i(TAG, 'queryRcsInfoSizeByCondition, total: ' + rcsTotal);
      callback(this.encapsulateReturnResult(common.int.SUCCESS, rcsTotal));
      resultSet.close();
      return;
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'queryRcsInfoByCondition fail, error: ' + JSON.stringify(error));
      callback(this.encapsulateReturnCode(common.int.FAILURE));
    });
    return;
  }

  public async queryRcsIdByMsgId(actionData: LooseObject, callback: Function, context: Context): Promise<void> {
    HiLog.i(TAG, 'queryRcsIdByMsgId');
    HiLog.i(TAG, 'shike conversationRcsModel msg_Id' + actionData.msgId);
    let dataHelper:dataShare.DataShareHelper | undefined = await DataShareHelper.getInstance().initSmsDB(context);
    if (!dataHelper) {
      HiLog.e(TAG, `[queryRcsIdByMsgId] createDataShareHelper fail`);
      if (callback) {
        callback(this.encapsulateReturnCode(common.int.FAILURE));
      }
      return;
    }
    let condition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    condition.equalTo('msg_id', actionData.msgId);
    condition.equalTo('rcs_type', 1);
    let managerUri = common.STR.URI_MESSAGE_LOG + common.STR.URI_RCS_MESSAGE_INFO_TABLE;
    let resultList: LooseObject[] = [];
    dataHelper.query(managerUri, condition, [mmsTable.rcsMessageInfo.rcsId]).then((resultSet: DataShareResultSet) => {
      HiLog.i(TAG, 'queryRcsIdByMsgId response rowCount:' + resultSet.rowCount);
      if (resultSet.rowCount > 0) {
        while (resultSet.goToNextRow()) {
          let result: LooseObject = {};
          result.rcsId = resultSet.getString(resultSet.getColumnIndex(mmsTable.rcsMessageInfo.rcsId));
          resultList.push(result);
        }
        if (callback) {
          callback(resultList);
        }
      }
      resultSet.close();
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'queryRcsIdByMsgId fail, error: ' + JSON.stringify(error));
      callback(this.encapsulateReturnCode(common.int.FAILURE));
    });
    return;
  }

  public queryRcsInfoSizeByConditionHandleCreate(actionData: LooseObject, callback: Function, dataHelper: dataShare.DataShareHelper) {
    HiLog.i(TAG, 'queryRcsInfoSizeByConditionHandleCreate');
    let condition: dataSharePredicates.DataSharePredicates = this.buildQueryRcsInfoCondition(actionData);
    let managerUri = common.STR.URI_MESSAGE_LOG + common.STR.URI_RCS_MESSAGE_INFO_TABLE;
    dataHelper?.query(managerUri, condition, this.buildRcsInfoTableColumns()).then((resultSet: DataShareResultSet) => {
      HiLog.i(TAG, 'queryRcsInfoSizeByCondition resultSet.rowCount: ' + JSON.stringify(resultSet.rowCount))
      callback(this.encapsulateReturnResult(common.int.SUCCESS, resultSet.rowCount));
      resultSet.close();
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'queryRcsInfoByCondition fail, error: ' + JSON.stringify(error));
      callback(this.encapsulateReturnCode(common.int.FAILURE));
    });
    return;
  }

  public async updateRcsReceivedMmsInfoByCondition(msgId: string, valueBucket: ValuesBucket, context: Context,
    cancelValue?: boolean, isSend?: boolean): Promise<void> {
    HiLog.iw(TAG, 'updateRcsMmsInfoByCondition In');
    let dataHelper:dataShare.DataShareHelper | undefined = await DataShareHelper.getInstance().initSmsDB(context);
    if (!dataHelper) {
      HiLog.iw(TAG, 'updateRcsMmsInfoByCondition dataHelper null');
      return;
    }
    this.updateRcsReceivedMmsInfoByConditionHandleCreate(msgId, dataHelper, valueBucket, cancelValue, isSend);
    return;
  }

  public async updateRcsReceivedMmsInfoByRcsId(actionData: LooseObject, valueBucket: ValuesBucket, callback: Function | null, context: Context): Promise<void> {
    let dataHelper:dataShare.DataShareHelper | undefined = await DataShareHelper.getInstance().initSmsDB(context);
    if (!dataHelper) {
      HiLog.e(TAG, `[updateRcsReceivedMmsInfoByRcsId] createDataShareHelper fail`);
      if (callback) {
        callback(this.encapsulateReturnCode(common.int.FAILURE));
      }
      return;
    }
    let condition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    condition.equalTo('rcs_id',actionData.rcsId);
    let managerUri: string = common.STR.URI_MESSAGE_LOG + common.STR.URI_RCS_MESSAGE_INFO_TABLE;
    dataHelper.update(managerUri, condition, valueBucket).then((res: number) => {
      if (callback) {
        callback(this.encapsulateReturnResult(common.int.SUCCESS, res));
      }
    })
    return;
  }

  public async updateRcsServiceKindMsgCodeByRcsId(actionData: LooseObject,
    valueBucket: ValuesBucket, callback: Function | null, context: Context): Promise<void> {
    let dataHelper:dataShare.DataShareHelper | undefined = await DataShareHelper.getInstance().initSmsDB(context);
    if (!dataHelper) {
      HiLog.e(TAG, `[updateRcsServiceKindMsgCodeByRcsId] createDataShareHelper fail`);
      if (callback) {
        callback(this.encapsulateReturnCode(common.int.FAILURE));
      }
      return;
    }
    let condition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    condition.equalTo('rcs_id',actionData.rcsId);
    condition.and().isNotNull('service_kind');
    let managerUri: string = common.STR.URI_MESSAGE_LOG + common.STR.URI_RCS_MESSAGE_INFO_TABLE;
    dataHelper.update(managerUri, condition, valueBucket).then((res: number) => {
      if (callback) {
        callback(this.encapsulateReturnResult(common.int.SUCCESS, res));
      }
    })
    return;
  }


  public updateRcsReceivedMmsInfoByConditionHandleCreate(msgId: string, dataHelper: dataShare.DataShareHelper,
    valueBucket: ValuesBucket, cancelValue?: boolean, isSend?: boolean) {
    // let condition: dataSharePredicates.DataSharePredicates = this.buildQuerySmsMmsInfoCondition(actionData);
    let managerUri: string = common.STR.URI_MESSAGE_LOG + common.STR.URI_RCS_MESSAGE_INFO_TABLE;
    let condition = new dataSharePredicates.DataSharePredicates();
    condition.equalTo('msg_id', msgId);
    if (cancelValue) {
      condition.and().equalTo('is_sender', '1');
    }
    if (isSend) {
      condition.and().equalTo('is_sender', '0');
    }
    condition.and().notEqualTo('msg_state', '0');
    HiLog.iw(TAG, 'updateRcsReceivedMmsInfoByCondition')
    dataHelper?.update(managerUri, condition, valueBucket).then().catch((error: BusinessError) => {
      HiLog.e(TAG, 'updateSmsMmsInfoByCondition fail, error: ' + JSON.stringify(error));
    });
    return;
  }

  public async updateRcsMmsInfoMarkRead(actionData: LooseObject, valueBucket: ValuesBucket, callback: Function | null, context: Context): Promise<void> {
    let dataHelper:dataShare.DataShareHelper | undefined = await DataShareHelper.getInstance().initSmsDB(context);
    if (!dataHelper) {
      HiLog.e(TAG, `[updateRcsMmsInfoMarkRead] createDataShareHelper fail`);
      if (callback) {
        callback(this.encapsulateReturnCode(common.int.FAILURE));
      }
      return;
    }
    let condition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    condition.equalTo('session_id',actionData.threadId);
    condition.equalTo('is_sender','1');
    condition.equalTo('is_read','0');
    let managerUri: string = common.STR.URI_MESSAGE_LOG + common.STR.URI_RCS_MESSAGE_INFO_TABLE;
    dataHelper.update(managerUri, condition, valueBucket).then((res: number) => {
      if (callback) {
        callback(this.encapsulateReturnResult(common.int.SUCCESS, res));
      }
    })
    return;
  }

  public async updateRcsMmsInfoByCondition(actionData: LooseObject, valueBucket: ValuesBucket, callback: Function | null, context: Context): Promise<void> {
    let dataHelper:dataShare.DataShareHelper | undefined = await DataShareHelper.getInstance().initSmsDB(context);
    if (!dataHelper) {
      HiLog.e(TAG, `[updateRcsMmsInfoByCondition] createDataShareHelper fail`);
      if (callback) {
        callback(this.encapsulateReturnCode(common.int.FAILURE));
      }
      return;
    }
    this.updateRcsMmsInfoByConditionHandleCreate(actionData, valueBucket, callback, dataHelper);
    return;
  }

  public updateRcsMmsInfoByConditionHandleCreate(actionData: LooseObject, valueBucket: ValuesBucket, callback: Function | null, dataHelper: dataShare.DataShareHelper) {
    let condition: dataSharePredicates.DataSharePredicates = this.buildQueryRcsMmsInfoCondition(actionData);
    let managerUri = common.STR.URI_MESSAGE_LOG + common.STR.URI_RCS_MESSAGE_INFO_TABLE;
    HiLog.i(TAG, 'updateRcsMmsInfoByCondition')
    dataHelper?.update(managerUri, condition, valueBucket).then((res: number) => {
      HiLog.i(TAG, 'updateRcsMmsInfoByCondition callback')
      if (callback) {
        callback(this.encapsulateReturnResult(common.int.SUCCESS, res));
      }
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'updateRcsMmsInfoByCondition fail, error: ' + JSON.stringify(error));
      if (callback) {
        callback(this.encapsulateReturnCode(common.int.FAILURE));
      }
    });
    return;
  }

  public async deleteRcsInfoByCondition(actionData: LooseObject, callback: Function | null, context: Context): Promise<void> {
    let dataHelper:dataShare.DataShareHelper | undefined = await DataShareHelper.getInstance().initSmsDB(context);
    if (!dataHelper) {
      HiLog.e(TAG, `[deleteRcsInfoByCondition] createDataShareHelper fail`);
      if (callback) {
        callback(this.encapsulateReturnCode(common.int.FAILURE));
      }
      return;
    }
    // let condition: dataSharePredicates.DataSharePredicates = this.buildQueryRcsMmsInfoCondition(actionData);
    let condition = new dataSharePredicates.DataSharePredicates();
    if(actionData.groupIdRcs!==undefined){
      condition.equalTo('group_id', actionData.groupIdRcs);
    }else if(actionData.groupIdsRcs!==undefined){
      condition.in('group_id', actionData.groupIdsRcs)
    }else if(actionData.threadIds!==undefined){
      condition.in('session_id', actionData.threadIds)
    } else if (actionData.uncheckedThreadIds !== undefined) {
      condition.notIn('session_id', actionData.uncheckedThreadIds);
    }
    let managerUri: string = common.STR.URI_MESSAGE_LOG + common.STR.URI_RCS_MESSAGE_INFO_TABLE;
    dataHelper.delete(managerUri, condition).then(res => {
      if(actionData.msgIdsRcs!==undefined){
        if(!actionData.isReSendRcs) {
           // rcs.deleteMessages(actionData.msgIdsRcs);
        }
      }
      if(actionData.phoneNumbers!==undefined){
        for (let index = 0; index < actionData.phoneNumbers?.length; index++) {
          if(!actionData.isReSendRcs) {
            // rcs.deleteConversation(actionData.phoneNumbers[index])
          }
        }
      }
      if (callback) {
        callback(this.encapsulateReturnResult(common.int.SUCCESS, res));
      }
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'deleteSmsMmsInfoByCondition fail, error: ' + JSON.stringify(error));
      if (callback) {
        callback(this.encapsulateReturnCode(common.int.FAILURE));
      }
    });
  }
  private buildQueryRcsInfoCondition(actionData: LooseObject): dataSharePredicates.DataSharePredicates {
    let condition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    condition.isNotNull(mmsTable.rcsMessageInfo.rcsId);
    HiLog.i(TAG, 'queryRcsInfoByCondition buildQueryRcsInfoCondition actionData: ' + actionData.threadId + '/' + actionData.needDistinct);
    if (actionData.rcsId != null) {
      condition.and().equalTo(mmsTable.messageInfo.rcsId, actionData.rcsId);
    }
    if (actionData.threadId != null) {
      condition.and().equalTo(mmsTable.rcsMessageInfo.sessionId, actionData.threadId);
    } else if (actionData.threadIds && actionData.threadIds.length > 0) {
      condition.and().in(mmsTable.rcsMessageInfo.sessionId, actionData.threadIds);
    } else if (actionData.uncheckedThreadIds && actionData.uncheckedThreadIds.length > 0) {
      condition.and().notIn(mmsTable.rcsMessageInfo.sessionId, actionData.uncheckedThreadIds);
    }
    if (actionData.rcsType) {
      condition.and().equalTo(mmsTable.rcsMessageInfo.rcsType, actionData.rcsType);
    }
    if (actionData.pageSize && actionData.pageNum) {
      condition.limit(actionData.pageSize, actionData.pageSize*(actionData.pageNum-1));
    }

    if (actionData.msgId) {
      condition.and().equalTo(mmsTable.messageInfo.msgId, actionData.msgId);
    }
    if (actionData.notNeedBlock) {
      condition.and().equalTo(mmsTable.messageInfo.isBlocked, 0);
    }
    return condition;
  }

  private buildQueryRcsMmsInfoCondition(actionData: LooseObject): dataSharePredicates.DataSharePredicates {
    HiLog.i(TAG, 'buildQueryRcsMmsInfoCondition actionData: ');
    let condition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    condition.isNotNull(mmsTable.messageInfo.msgId);
    if (actionData?.sendResults?.length > 0) {
      if (actionData.sendResults[0].id != null) {
        condition.and().equalTo(mmsTable.rcsMessageInfo.rcsId, actionData.sendResults[0].id);
      }
    }
    HiLog.i(TAG, 'buildQueryRcsMmsInfoCondition condition: ');
    return condition;
  }

  public async markAsReadFromReceiveRcs(actionData: LooseObject, callback: Function, context: Context): Promise<void> {
    let dataHelper:dataShare.DataShareHelper | undefined = await DataShareHelper.getInstance().initSmsDB(context);
    if (!dataHelper) {
      HiLog.e(TAG, `[markAsReadFromReceiveRcs] createDataShareHelper fail`);
      if (callback) {
        callback(this.encapsulateReturnCode(common.int.FAILURE));
      }
      return;
    }
    let infoUri: string = common.STR.URI_MESSAGE_LOG + common.STR.URI_MESSAGE_SINGLE_MARK_UNREAD;
    let infoUpdateCondition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    HiLog.i(TAG, 'markAsReadFromReceiveRcs rcsId:' + mmsTable.rcsMessageInfo.rcsId +
      'markAsReadFromReceiveRcs threadIds:' + actionData.threadIds);
    if (actionData.isAfterNoReadButton && UnLockedNotifyService.getInstance().dataIsMoveEL5) {
      infoUpdateCondition.equalTo(mmsTable.messageInfo.phoneNumber, actionData.telephone).and().
      equalTo(mmsTable.messageInfo.msgContent, actionData.msgContent).and().
      equalTo(mmsTable.messageInfo.startTime, actionData.startTime).and().
      equalTo('msg_type', actionData.msgType);
    } else {
      infoUpdateCondition.equalTo(mmsTable.messageInfo.msgId, actionData.threadIds).and().
      equalTo('msg_type', actionData.msgType);
    }
    let bucketValue: Record<string, number> = {
      'is_read': common.is_read.READ
    }
    if (dataHelper) {
      try {
        dataHelper.update(infoUri, infoUpdateCondition, bucketValue, (res) => {
          dataHelper?.notifyChange(common.STR.URI_MESSAGE_LOG + common.STR.URI_MESSAGE_SESSION_TABLE);
          callback(res);
        });
      } catch (e) {
        HiLog.e(TAG, 'markAsReadFromReceiveNotice error: ' + JSON.stringify(e));
      }
    }
  }

  private buildRcsInfoTableColumns(): Array<string> {
    let resultColumns: Array<string> = [
      mmsTable.rcsMessageInfo.rcsId,
      mmsTable.rcsMessageInfo.slotId,
      mmsTable.rcsMessageInfo.msgId,
      mmsTable.rcsMessageInfo.receiverNumber,
      mmsTable.rcsMessageInfo.senderNumber,
      mmsTable.rcsMessageInfo.startTime,
      mmsTable.rcsMessageInfo.endTime,
      mmsTable.rcsMessageInfo.rcsType,
      mmsTable.rcsMessageInfo.msgTitle,
      mmsTable.rcsMessageInfo.msgContent,
      mmsTable.rcsMessageInfo.msgState,

      mmsTable.rcsMessageInfo.enrichedCallingType,
      mmsTable.rcsMessageInfo.errorCode,
      mmsTable.rcsMessageInfo.isRead,
      mmsTable.rcsMessageInfo.networkType,
      mmsTable.rcsMessageInfo.ownerAddr,
      mmsTable.rcsMessageInfo.privacyMode,
      mmsTable.rcsMessageInfo.sessionId,
      mmsTable.rcsMessageInfo.groupId,
      mmsTable.rcsMessageInfo.isSender,
      mmsTable.rcsMessageInfo.protocol,
      mmsTable.rcsMessageInfo.replyPathPresent,
      mmsTable.rcsMessageInfo.seen,
      mmsTable.rcsMessageInfo.serviceCenter,
      mmsTable.rcsMessageInfo.serviceKind,
      mmsTable.rcsMessageInfo.isCollect,
      mmsTable.rcsMessageInfo.isAdvancedSecurity,
      mmsTable.rcsMessageInfo.receiveState,
      mmsTable.rcsMessageInfo.failReceiveContext,
      mmsTable.rcsMessageInfo.isReport,
      mmsTable.rcsMessageInfo.detectResContent
    ];
    return resultColumns;
  }

  private buildRcsInfoResult(resultSet: DataShareResultSet): ConversationRcsInfo {
    let rcsId: number = Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.rcsMessageInfo.rcsId)));
    let slotId: number = Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.rcsMessageInfo.slotId)));
    let msgId: string = resultSet.getString(resultSet.getColumnIndex(mmsTable.rcsMessageInfo.msgId));
    let receiverNumber: string = resultSet.getString(resultSet.getColumnIndex(mmsTable.rcsMessageInfo.receiverNumber));
    let senderNumber: string = resultSet.getString(resultSet.getColumnIndex(mmsTable.rcsMessageInfo.senderNumber));
    let startTime: number = Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.rcsMessageInfo.startTime)));
    let rcsType: number = Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.rcsMessageInfo.rcsType)));
    let enrichedCallingType: number = Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.rcsMessageInfo.enrichedCallingType)));
    let msgTitle: string = resultSet.getString(resultSet.getColumnIndex(mmsTable.rcsMessageInfo.msgTitle));
    let msgContent: string = resultSet.getString(resultSet.getColumnIndex(mmsTable.rcsMessageInfo.msgContent));
    let msgState: number = Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.rcsMessageInfo.msgState)));

    let networkType: string = resultSet.getString(resultSet.getColumnIndex(mmsTable.rcsMessageInfo.networkType));
    let errorCode: number = Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.rcsMessageInfo.errorCode)));
    let isRead: number = Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.rcsMessageInfo.isRead)));
    let ownerAddr: string = resultSet.getString(resultSet.getColumnIndex(mmsTable.rcsMessageInfo.ownerAddr));
    let privacyMode: number = Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.rcsMessageInfo.privacyMode)));
    let protocol: number = Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.rcsMessageInfo.protocol)));
    let sessionId: number = Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.rcsMessageInfo.sessionId)));
    let groupId: number = Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.rcsMessageInfo.groupId)));
    let isSender: number = Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.rcsMessageInfo.isSender)));
    let replyPathPresent: number = Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.rcsMessageInfo.replyPathPresent)));
    let seen: number = Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.rcsMessageInfo.seen)));
    let serviceCenter: string = resultSet.getString(resultSet.getColumnIndex(mmsTable.rcsMessageInfo.serviceCenter));
    let serviceKind: string = resultSet.getString(resultSet.getColumnIndex(mmsTable.rcsMessageInfo.serviceKind));
    let endTime: string = resultSet.getString(resultSet.getColumnIndex(mmsTable.rcsMessageInfo.endTime));
    let isCollect: number = Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.rcsMessageInfo.isCollect)));
    let isAdvancedSecurity: number = Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.rcsMessageInfo.isAdvancedSecurity)));
    let receiveState: number = resultSet.getLong(resultSet.getColumnIndex(mmsTable.rcsMessageInfo.receiveState));
    let failReceiveContext: string = resultSet.getString(resultSet.getColumnIndex(mmsTable.rcsMessageInfo.failReceiveContext));
    let isReport: number = resultSet.getLong(resultSet.getColumnIndex(mmsTable.rcsMessageInfo.isReport));
    let detectResContent: string = resultSet.getString(resultSet.getColumnIndex(mmsTable.rcsMessageInfo.
      detectResContent));
    let result: ConversationRcsInfo = new ConversationRcsInfo(rcsId, slotId, receiverNumber, senderNumber, startTime,
      endTime, rcsType, msgTitle, msgContent, msgState, isRead, sessionId, groupId, isSender, msgId,
      enrichedCallingType, errorCode, networkType, ownerAddr, privacyMode, protocol, replyPathPresent, seen,
      serviceCenter, serviceKind, isCollect, isAdvancedSecurity, receiveState, failReceiveContext, isReport,
      detectResContent);
    return result;
  }

  private buildRcsInfoSlotIdCondition(phoneNumber: string): dataSharePredicates.DataSharePredicates {
    let condition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    condition.isNotNull(mmsTable.rcsMessageInfo.rcsId);
    if (phoneNumber != null && phoneNumber.length > 0) {
      condition.equalTo('receiver_number', phoneNumber)
        .or().equalTo('sender_number', phoneNumber);
      condition.orderByDesc('end_time');
      condition.limit(1, 0);
    }
    return condition;
  }

  public static async queryInRcsInfoByConditionAndColumns(context: Context,
    condition: dataSharePredicates.DataSharePredicates,
    columns: string[]) {
    let dataHelper: dataShare.DataShareHelper | undefined;
    try {
      dataHelper = await DataShareHelper.getInstance().initSmsDB(context);
    } catch (e) {
      HiLog.e(TAG, `queryInRcsInfoByCondition createDataShareHelper fail, error: ${JSON.stringify(e)}`);
      return;
    }
    if (!dataHelper) {
      HiLog.e(TAG, `queryInRcsInfoByCondition createDataShareHelper fail`);
      return;
    }

    let managerUri = common.STR.URI_MESSAGE_LOG + common.STR.URI_RCS_MESSAGE_INFO_TABLE;
    let resultSet: DataShareResultSet | void;
    try {
      resultSet = await dataHelper?.query(managerUri, condition, columns)
        .catch((error: BusinessError) => {
          HiLog.e(TAG, `queryInRcsInfoByCondition query fail, error: ${error.code} ${error.message}`);
        });
    } catch (e) {
      HiLog.e(TAG, `queryInRcsInfoByCondition query fail, error: ${JSON.stringify(e)}`);
      return;
    }
    return resultSet;
  }

  public async updateRcsIsReadBySessionId(actionData: LooseObject, callback?: Function | null, context?: Context) {
    let mmsContext: Context = context ? context : GlobalContext.getContext()
      .getObject('mmsContext') as myCommon.UIAbilityContext;
    let dataHelper:dataShare.DataShareHelper | undefined = await DataShareHelper.getInstance().initSmsDB(mmsContext);
    if (!dataHelper) {
      HiLog.e(TAG, '[updateIsReadBySessionId] createDataShareHelper fail');
      if (callback) {
        callback(this.encapsulateReturnCode(common.int.FAILURE));
      }
      return;
    }

    try {
      let condition: dataSharePredicates.DataSharePredicates = this.buildRcsIsReadBySessionId(actionData);
      let managerUri = common.STR.URI_MESSAGE_LOG + common.STR.URI_RCS_MESSAGE_INFO_TABLE;
      const va: ValuesBucket = {
        'is_read': 1
      }
      dataHelper.update(managerUri, condition, va).then((data: number) => {
        HiLog.i(TAG, 'markRead rcsInfo succeed, data : ' + data);
        if (callback) {
          callback(this.encapsulateReturnResult(common.int.SUCCESS, data));
        }
      }).catch((err: BusinessError) => {
        HiLog.e(TAG, `[updateRcsIsReadBySessionId] error: code: ${err.code}, message: ${err.message} `);
        if (callback) {
          callback(this.encapsulateReturnCode(common.int.FAILURE));
        }
      });
    } catch (err) {
      let code = (err as BusinessError).code;
      let message = (err as BusinessError).message;
      HiLog.e(TAG, `[updateRcsIsReadBySessionId] error: code: ${code}, message: ${message} `);
      if (callback) {
        callback(this.encapsulateReturnCode(common.int.FAILURE));
      }
    };
  }

  private buildRcsIsReadBySessionId(actionData: LooseObject) : dataSharePredicates.DataSharePredicates {
    let condition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    if (actionData.markReadType == MarkRead.single) {
      condition.equalTo(mmsTable.rcsMessageInfo.sessionId, actionData.threadId);
      return condition;
    }
    if (actionData.markReadType == MarkRead.allInfo) {
      condition.in(mmsTable.rcsMessageInfo.sessionId, actionData?.threadIds || []);
      return condition;
    }
    if (actionData.markReadType == MarkRead.all) {
      return condition;
    }
    throw new Error('buildSmsIsReadBySessionId condition not match');
  }

  public async updateRcsInfoIsSenderBySessionIds(actionData: Record<string, number[]>,
    callback: Function, context: Context) {
    HiLog.i(TAG, 'updateRcsInfoIsSenderBySessionIds start! :');
    let dataHelper: dataShare.DataShareHelper | undefined = await DataShareHelper.getInstance().initSmsDB(context);
    try {
      if (!dataHelper) {
        HiLog.e(TAG, '[updateRcsInfoIsSenderBySessionIds] createDataShareHelper fail');
        if (callback) {
          callback(this.encapsulateReturnCode(common.int.FAILURE));
        }
        return;
      }
      let managerUri = common.STR.URI_MESSAGE_LOG + common.STR.URI_RCS_MESSAGE_INFO_TABLE;
      let condition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
      let threadIds: number[] = actionData.threadIds;
      condition.in('session_id', threadIds);
      condition.equalTo('is_sender', 1);
      let vp: ValuesBucket = {
        'is_sender': 5
      };
      let data = await dataHelper.update(managerUri, condition, vp);
      if (callback) {
        callback(this.encapsulateReturnResult(common.int.SUCCESS, data));
      }
    } catch (e) {
      HiLog.w(TAG, 'updateRcsInfoIsSenderBySessionIds error : ' + JSON.stringify(e));
      if (callback) {
        callback(this.encapsulateReturnCode(common.int.FAILURE));
      }
    }
  }

  public async updateRcsInfoIsChatbotResentUseTime(actionData: LooseObject, context: Context) {
    HiLog.i(TAG, 'updateRcsInfoIsSenderBySessionIds start! :');
    try {
      let dataHelper: dataShare.DataShareHelper | undefined = await DataShareHelper.getInstance().initSmsDB(context);
      let managerUri: string = commonData.STR.URI_MESSAGE_LOG + '/sms_mms/chatbots';
      if (!dataHelper) {
        HiLog.i(TAG, '[insertSession] createDataShareHelper fail');
        return;
      }
      let condition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
      if (actionData && actionData.id) {
        condition.equalTo('service_id', actionData.id)
      } else {
        condition.equalTo('service_id', actionData.strContactsNumber)
      }

      let time: number = 0
      try {
        time = systemDateTime.getTime(false)
      } catch (e) {
        let error = e as BusinessError;
        HiLog.i(TAG, `Failed to get time. message: ${error.message}, code: ${error.code}`);
      }
      let value: ValuesBucket = {
        'recent_use_time': String(time)
      };
      dataHelper.update(managerUri, condition, value).then(() => {
        HiLog.i(TAG, 'updateCurrentUsedTime success');
      }).catch((error: BusinessError) => {
        HiLog.e(TAG, 'updateCurrentUsedTime fail, error: ' + JSON.stringify(error));
      });
    } catch (e) {
      HiLog.w(TAG, 'updateRcsInfoIsSenderBySessionIds error : ' + JSON.stringify(e));
    }
  }

  public async queryChatbotPermissions(serviceId: string, context: Context, callback: Function) {
    HiLog.i(TAG, 'queryChatbotPermissions enter');
    let dataHelper: dataShare.DataShareHelper | undefined =
      await DataShareHelper.getInstance().initSmsDB(context);
    let managerUri: string = commonData.STR.URI_MESSAGE_LOG + commonData.STR.URI_MESSAGE_CHATBOT_ALL_TABLE;
    let condition = new dataSharePredicates.DataSharePredicates();
    condition.equalTo('service_id', serviceId)
    let shareStateComeKu: number = 0
    await dataHelper?.query(managerUri, condition, ['disturb', 'share_info']).then((res) => {
      res.goToFirstRow()
      shareStateComeKu = res.getLong(res.getColumnIndex('share_info'))
      callback(shareStateComeKu);
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'getSettingPageSwitchValue error is ' + JSON.stringify(error));
    });
  }

  public async updateChatbotPermissions(serviceId: string, updateCount: number, context: Context) {
    HiLog.i(TAG, 'updateChatbotPermissions enter')
    //更新数据库
    let dataHelper: dataShare.DataShareHelper | undefined =
      await DataShareHelper.getInstance().initSmsDB(context);
    let managerUri: string = commonData.STR.URI_MESSAGE_LOG + commonData.STR.URI_MESSAGE_CHATBOT_ALL_TABLE;
    let condition = new dataSharePredicates.DataSharePredicates();
    condition.equalTo('service_id', serviceId)
    let value: ValuesBucket = {
      'share_info': updateCount,
    };
    await dataHelper?.update(managerUri, condition, value).then((res) => {
      HiLog.e(TAG, 'updateSmsMmsInfoByCondition success ');
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'updateSmsMmsInfoByCondition fail, error: ' + JSON.stringify(error));
    });
  }

  public async updateRcsInfoByConditionAndValuesBucket(context: Context | undefined,
    condition: dataSharePredicates.DataSharePredicates | undefined, valueBucket: ValuesBucket | undefined) {
    if (!context || !condition || !valueBucket) {
      HiLog.i(TAG, 'updateRcsInfoByConditionAndValuesBucket params empty');
    }
    let dataHelper: dataShare.DataShareHelper | undefined = await DataShareHelper.getInstance().initSmsDB(context!);
    if (!dataHelper) {
      HiLog.i(TAG, 'updateRcsInfoByConditionAndValuesBucket dataHelper null');
      return;
    }
    try {
      await dataHelper.update(common.STR.URI_MESSAGE_LOG + common.STR.URI_RCS_MESSAGE_INFO_TABLE,
        condition, valueBucket).then((res) => {
        HiLog.i(TAG, 'updateRcsInfoByConditionAndValuesBucket success res: ' + JSON.stringify(res));
      }).catch((error: BusinessError) => {
        HiLog.e(TAG, 'updateRcsInfoByConditionAndValuesBucket failed, error: ' + JSON.stringify(error));
      });
    } catch (e) {
      HiLog.e(TAG, 'updateRcsInfoByConditionAndValuesBucket error: ' + JSON.stringify(e));
    }
  }
}