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
import HiLog from '../utils/HiLog';
import mmsTable from '../data/tableData';
import LooseObject from '../data/LooseObject'
import { BusinessError } from '@ohos.base';
import DataShareResultSet from '@ohos.data.DataShareResultSet';
import hiTraceMeter from '@ohos.hiTraceMeter';
import TraceConstant from '../data/TraceConstant';
import DataShareHelper from './repository/DataShareHelper';
import TelephoneUtil from '../utils/TelephoneUtil';
import { ISessionTelephoneInfo } from './type/ContactParams';

const TAG = 'ContactsModel';

export default class ContactsModel extends BaseModel {
  public async queryContactDataByCondition(actionData: LooseObject, callback: Function,
    context: Context): Promise<void> {
    hiTraceMeter.startTrace(TraceConstant.TRACE_QUERY_CONTRACT_DATA_BY_CONDITION,
      TraceConstant.TRACE_QUERY_CONTRACT_DATA_BY_CONDITION_ID);
    let dataHelper:dataShare.DataShareHelper | undefined = await DataShareHelper.getInstance().initContactDB(context);
    if (!dataHelper) {
      HiLog.e(TAG, `[queryContactDataByCondition] createDataShareHelper fail`);
      if (callback) {
        callback(this.encapsulateReturnCode(common.int.FAILURE));
      }
      return;
    }
    let condition: dataSharePredicates.DataSharePredicates = this.buildQueryContactDataCondition(actionData);
    let contactDataUri: string = common.STR.URI_ROW_CONTACTS + common.STR.CONTACT_DATA_URI;
    HiLog.i(TAG, '[queryContactDataByCondition] before query')
    dataHelper.query(contactDataUri, condition, this.buildContactDataColumns()).then(resultSet => {
      HiLog.w(TAG, '[queryContactDataByCondition] proceed query, rowCount: ' + resultSet.rowCount)
      let resultList: LooseObject[] = [];
      if (resultSet.rowCount > 0) {
        while (resultSet.goToNextRow()) {
          resultList.push(this.buildContactDataResult(resultSet));
        }
      }
      HiLog.i(TAG, '[queryContactDataByCondition] proceed query before callback')
      callback(this.encapsulateReturnResult(common.int.SUCCESS, resultList));
      hiTraceMeter.finishTrace(TraceConstant.TRACE_QUERY_CONTRACT_DATA_BY_CONDITION,
        TraceConstant.TRACE_QUERY_CONTRACT_DATA_BY_CONDITION_ID);
      resultSet.close();
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'queryContactDataByCondition fail, error: ' + JSON.stringify(error));
      callback(this.encapsulateReturnCode(common.int.FAILURE));
      hiTraceMeter.finishTrace(TraceConstant.TRACE_QUERY_CONTRACT_DATA_BY_CONDITION,
        TraceConstant.TRACE_QUERY_CONTRACT_DATA_BY_CONDITION_ID);
    });
  }

  /*
   * 本函数专门为短信首页拼装联系人名字使用, 静默访问。
   * */
  public async queryContactDataInSessionSilence(actionData: ISessionTelephoneInfo, callback: Function,
    context: Context): Promise<void> {
    hiTraceMeter.startTrace(TraceConstant.TRACE_QUERY_CONTRACT_DATA_BY_CONDITION,
      TraceConstant.TRACE_QUERY_CONTRACT_DATA_BY_CONDITION_ID);
    let dataHelper = await DataShareHelper.getInstance().initSilenceContactDataTable(context);
    if (!dataHelper) {
      HiLog.e(TAG, `[queryContactDataInSessionSilence] createDataShareHelper fail`);
      if (callback) {
        callback(this.buildSessionReturnResult(common.int.FAILURE, []));
      }
      return;
    }
    let silenceContactDataUri: string = common.STR.URI_CONTACT_SILENCE_DATA;
    let contactResultList: LooseObject[] = [];
    let rowContactResultList: LooseObject[] = [];
    let resultSet: DataShareResultSet | undefined = undefined;
    let rowResultSet: DataShareResultSet | undefined = undefined;
    try {
      let conditionContact: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
      conditionContact.equalTo(mmsTable.contactDataColumns.typeId, '5');
      this.conditionOrTelephones(actionData.telephones, conditionContact, false);
      HiLog.i(TAG, '[queryContactDataInSessionSilence] before query');
      resultSet = await dataHelper.query(silenceContactDataUri,
        conditionContact, ['id', 'detail_info', 'raw_contact_id']);
      HiLog.i(TAG, '[queryContactDataInSessionSilence] proceed query, rowCount: ' + resultSet.rowCount);
      if (resultSet.rowCount <= 0) {
        callback(this.encapsulateReturnResult(common.int.SUCCESS, []));
        resultSet.close();
        return;
      }
      while (resultSet.goToNextRow()) {
        let result: LooseObject = {};
        result.id = resultSet.getLong(resultSet.getColumnIndex(mmsTable.contactDataColumns.id));
        result.detailInfo = resultSet.getString(resultSet.getColumnIndex(mmsTable.contactDataColumns.detailInfo));
        result.rawContactId = resultSet.getString(resultSet.getColumnIndex(mmsTable.contactDataColumns.rawContactId));
        contactResultList.push(result);
      }
      resultSet.close();
      let rowContactIds: number[] = [];
      for (let index = 0; index < contactResultList.length; index++) {
        rowContactIds.push(contactResultList[index].rawContactId);
      }
      let silenceRowContactDataUri: string = common.STR.URI_RAW_CONTACT_SILENCE_DATA;
      let conditionRawContact: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
      conditionRawContact.in('id', rowContactIds);
      conditionRawContact.equalTo(mmsTable.contactDataColumns.hasDelete, '0')
      HiLog.i(TAG, '[queryContactDataInSessionSilence] row contact before query');
      rowResultSet = await dataHelper.query(silenceRowContactDataUri,
        conditionRawContact, ['id', 'display_name', 'contact_id']);
      HiLog.i(TAG, '[queryContactDataInSessionSilence] proceed query, rowContactCount: ' + rowResultSet.rowCount);
      if (rowResultSet.rowCount <= 0) {
        callback(this.encapsulateReturnResult(common.int.SUCCESS, []));
        rowResultSet.close();
        return;
      }
      while (rowResultSet.goToNextRow()) {
        let result: LooseObject = {};
        result.id = rowResultSet.getLong(rowResultSet.getColumnIndex(mmsTable.contactDataColumns.id));
        result.displayName = rowResultSet.getString(
          rowResultSet.getColumnIndex(mmsTable.contactDataColumns.displayName));
        result.contactId = rowResultSet.getString(
          rowResultSet.getColumnIndex((mmsTable.contactDataColumns.contactId)));
        rowContactResultList.push(result);
      }
      rowResultSet.close();
      let resultList: LooseObject[] = [];
      if (contactResultList.length > 0 && rowContactResultList.length > 0) {
        for (let i = 0; i < contactResultList.length; i++) {
          let result: LooseObject = {};
          const contact = contactResultList[i];
          for (let j = 0; j < rowContactResultList.length; j++) {
            let rowContact = rowContactResultList[j];
            if (contact.rawContactId == rowContact.id) {
              result.id = contact.id;
              result.detailInfo = contact.detailInfo;
              result.rawContactId = contact.rawContactId;
              result.displayName = rowContact.displayName;
              result.contactId = rowContact.contactId;
              resultList.push(result);
            }
          }
        }
      }
      callback(this.encapsulateReturnResult(common.int.SUCCESS, resultList));
    } catch (err) {
      HiLog.e(TAG, `[queryContactDataInSessionSilence] fail to query, msg: ${err.message}, code: ${err.code}`);
      callback(this.encapsulateReturnResult(common.int.FAILURE, []));
    } finally {
      if (resultSet && !resultSet.isClosed) {
        resultSet.close();
      }
      if (rowResultSet && !rowResultSet.isClosed) {
        rowResultSet.close()
      }
    }

  }


  /*
   * 本函数专门为短信首页拼装联系人名字使用。
   * */
  public async queryContactDataInSession(actionData: ISessionTelephoneInfo, callback: Function,
    context: Context): Promise<void> {
    if (actionData.useSilenceDB) {
      return this.queryContactDataInSessionSilence(actionData, callback, context);
    }
    hiTraceMeter.startTrace(TraceConstant.TRACE_QUERY_CONTRACT_DATA_BY_CONDITION,
      TraceConstant.TRACE_QUERY_CONTRACT_DATA_BY_CONDITION_ID);
    let dataHelper:dataShare.DataShareHelper | undefined = await DataShareHelper.getInstance().initContactDB(context);
    if (!dataHelper) {
      HiLog.e(TAG, `[queryContactDataInSession] createDataShareHelper fail`);
      if (callback) {
        callback(this.encapsulateReturnCode(common.int.FAILURE));
      }
      return;
    }
    let condition: dataSharePredicates.DataSharePredicates = actionData.buildQueryContactDataCondition();
    let contactDataUri: string = common.STR.URI_ROW_CONTACTS + common.STR.CONTACT_DATA_URI;
    HiLog.i(TAG, '[queryContactDataInSession] before query')
    dataHelper.query(contactDataUri, condition, actionData.buildContactDataColumns()).then(resultSet => {
      HiLog.i(TAG, '[queryContactDataInSession] proceed query, rowCount: ' + resultSet.rowCount)
      let resultList: LooseObject[] = [];
      if (resultSet.rowCount > 0) {
        while (resultSet.goToNextRow()) {
          resultList.push(actionData.buildContactDataResult(resultSet));
        }
      }
      HiLog.i(TAG, '[queryContactDataInSession] proceed query before callback')
      callback(this.encapsulateReturnResult(common.int.SUCCESS, resultList));
      hiTraceMeter.finishTrace(TraceConstant.TRACE_QUERY_CONTRACT_DATA_BY_CONDITION,
        TraceConstant.TRACE_QUERY_CONTRACT_DATA_BY_CONDITION_ID);
      resultSet.close();
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, '[queryContactDataInSession] fail, error: ' + JSON.stringify(error));
      callback(this.encapsulateReturnCode(common.int.FAILURE));
      hiTraceMeter.finishTrace(TraceConstant.TRACE_QUERY_CONTRACT_DATA_BY_CONDITION,
        TraceConstant.TRACE_QUERY_CONTRACT_DATA_BY_CONDITION_ID);
    });
  }

  public async batchQueryContactDataByCondition(actionData: LooseObject, callback: Function, context: Context):
    Promise<void> {
    let telephonesArr: string[] = actionData.telephones;
    HiLog.i(TAG, '[batchQueryContactDataByCondition] start.');
    if (telephonesArr.length === 0) {
      HiLog.e(TAG, '[batchUpdateSessionByCondition] Illegal arguments.');
      callback(this.encapsulateReturnCode(common.int.FAILURE));
      return;
    }
    let queryPromises: Promise<LooseObject>[] = []
    // 处理拼接条件 990 个电话号码一组进行查询
    for (let i = 0; i < telephonesArr.length; i += 990) {
      let copyArr = telephonesArr.slice(i, i + 990);
      let copyActionData: LooseObject = {};
      copyActionData.telephones = copyArr;
      copyActionData.hasDelete = '0';
      let result: Promise<LooseObject> = new Promise((resolve) => {
        this.queryContactDataByCondition(copyActionData, (res: LooseObject) => {
          HiLog.w(TAG, 'batchQueryContactDataByCondition dealContactsName, res.code = ' + res.code);
          if (res.code == common.int.FAILURE || res.abilityResult.length == 0) {
            HiLog.w(TAG, 'dealContactsName, has no contacts');
            resolve([]);
          } else {
            resolve(res.abilityResult);
          }
        }, context);
      });
      queryPromises.push(result);
    }
    HiLog.i(TAG, '[batchQueryContactDataByCondition] before query')
    let resultList = Promise.all(queryPromises);
    let allInfo: LooseObject = {};
    resultList.then((results: LooseObject[]) => {
      HiLog.w(TAG, '[batchQueryContactDataByCondition] end. result.length: ' + results.length);
      let abilityResult: LooseObject[] = []
      results.forEach((item) => {
        (item as []).forEach((k) => {
          abilityResult.push(k);
        })
      } )
      HiLog.w(TAG, '[batchQueryContactDataByCondition] end. abilityResult.length: ' + abilityResult.length);
      allInfo = this.encapsulateReturnResult(common.int.SUCCESS, abilityResult);
      callback(allInfo);
    });
  }

  public async queryCallLogByCondition(actionData: LooseObject, callback: Function, context: Context): Promise<void> {
    hiTraceMeter.startTrace(TraceConstant.TRACE_QUERY_CALL_LOG_BY_CONDITION,
      TraceConstant.TRACE_QUERY_CALL_LOG_BY_CONDITION_ID);
    let dataHelper:dataShare.DataShareHelper | undefined = await DataShareHelper.getInstance().initCallLogDB(context);
    if (!dataHelper) {
      HiLog.e(TAG, `[queryCallLogByCondition] createDataShareHelper fail`);
      if (callback) {
        callback(this.encapsulateReturnCode(common.int.FAILURE));
      }
      return;
    }
    let condition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    let phoneNumber: string = actionData.phoneNumber;
    condition.equalTo('phone_number', phoneNumber);
    condition.orderByDesc('create_time');
    condition.limit(1,0);
    let contactDataUri: string = common.STR.URI_ROW_CALLLOG + common.STR.CONTACT_CALLLOG_URI;
    dataHelper.query(contactDataUri, condition, ['*']).then((resultSet) => {
      resultSet.goToFirstRow();
      let slotId: number = resultSet.getLong(resultSet.getColumnIndex('slot_id'));
      callback(this.encapsulateReturnResult(common.int.SUCCESS, slotId));
      hiTraceMeter.finishTrace(TraceConstant.TRACE_QUERY_CALL_LOG_BY_CONDITION,
        TraceConstant.TRACE_QUERY_CALL_LOG_BY_CONDITION_ID);
      resultSet.close();
    }).catch((err: BusinessError) => {
      HiLog.e(TAG, `query error: code: ${err?.code}, message: ${err?.message} `);
      callback(this.encapsulateReturnCode(common.int.FAILURE));
      hiTraceMeter.finishTrace(TraceConstant.TRACE_QUERY_CALL_LOG_BY_CONDITION,
        TraceConstant.TRACE_QUERY_CALL_LOG_BY_CONDITION_ID);
    })
  }

  public async queryContactDataSizeByCondition(actionData: LooseObject, callback: Function, context: Context): Promise<void> {
    hiTraceMeter.startTrace(TraceConstant.TRACE_QUERY_CONTACT_DATA_SIZE_BY_CONDITION,
      TraceConstant.TRACE_QUERY_CONTACT_DATA_SIZE_BY_CONDITION_ID);
    let dataHelper:dataShare.DataShareHelper | undefined = await DataShareHelper.getInstance().initContactDB(context);
    if (!dataHelper) {
      HiLog.e(TAG, `[queryContactDataSizeByCondition] createDataShareHelper fail`);
      if (callback) {
        callback(this.encapsulateReturnCode(common.int.FAILURE));
      }
      return;
    }
    let condition: dataSharePredicates.DataSharePredicates = this.buildQueryContactDataCondition(actionData);
    let contactDataUri: string = common.STR.URI_ROW_CONTACTS + common.STR.CONTACT_DATA_URI;
    dataHelper.query(contactDataUri, condition, this.buildContactDataTablePartColumns()).then(resultSet => {
      callback(this.encapsulateReturnResult(common.int.SUCCESS, resultSet.rowCount));
      hiTraceMeter.finishTrace(TraceConstant.TRACE_QUERY_CONTACT_DATA_SIZE_BY_CONDITION,
        TraceConstant.TRACE_QUERY_CONTACT_DATA_SIZE_BY_CONDITION_ID);
      resultSet.close();
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'queryContactDataSizeByCondition fail, error: ' + JSON.stringify(error));
      hiTraceMeter.finishTrace(TraceConstant.TRACE_QUERY_CONTACT_DATA_SIZE_BY_CONDITION,
        TraceConstant.TRACE_QUERY_CONTACT_DATA_SIZE_BY_CONDITION_ID);
      callback(this.encapsulateReturnCode(common.int.FAILURE));
    });
  }

  public async queryContactByCondition(actionData: LooseObject, callback: Function, context: Context): Promise<void> {
    hiTraceMeter.startTrace(TraceConstant.TRACE_QUERY_CONTACT_BY_CONDITION,
      TraceConstant.TRACE_QUERY_CONTACT_BY_CONDITION_ID);
    let dataHelper:dataShare.DataShareHelper | undefined = await DataShareHelper.getInstance().initContactDB(context);
    if (!dataHelper) {
      HiLog.e(TAG, `[queryContactByCondition] createDataShareHelper fail`);
      if (callback) {
        callback(this.encapsulateReturnCode(common.int.FAILURE));
      }
      return;
    }
    let condition: dataSharePredicates.DataSharePredicates = this.buildQueryContactCondition(actionData);
    let contactUri: string = common.STR.URI_ROW_CONTACTS + common.STR.CONTACT_URI;
    dataHelper.query(contactUri, condition, this.buildContactTablePartColumns()).then(resultSet => {
      let resultList: Array<LooseObject> = [];
      if (resultSet.rowCount > 0) {
        while (resultSet.goToNextRow()) {
          resultList.push(this.buildContactResult(resultSet));
        }
      }
      callback(this.encapsulateReturnResult(common.int.SUCCESS, resultList));
      hiTraceMeter.finishTrace(TraceConstant.TRACE_QUERY_CONTACT_BY_CONDITION,
        TraceConstant.TRACE_QUERY_CONTACT_BY_CONDITION_ID);
      resultSet.close();
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'queryContactByCondition fail, error: ' + JSON.stringify(error));
      callback(this.encapsulateReturnCode(common.int.FAILURE));
      hiTraceMeter.finishTrace(TraceConstant.TRACE_QUERY_CONTACT_BY_CONDITION,
        TraceConstant.TRACE_QUERY_CONTACT_BY_CONDITION_ID);
    });
  }

  public async queryContactSizeByCondition(actionData: LooseObject, callback: Function, context: Context): Promise<void> {
    hiTraceMeter.startTrace(TraceConstant.TRACE_QUERY_CONTACT_SIZE_BY_CONDITION,
      TraceConstant.TRACE_QUERY_CONTACT_SIZE_BY_CONDITION_ID);
    let dataHelper:dataShare.DataShareHelper | undefined = await DataShareHelper.getInstance().initContactDB(context);
    if (!dataHelper) {
      HiLog.e(TAG, `[queryContactSizeByCondition] createDataShareHelper fail`);
      if (callback) {
        callback(this.encapsulateReturnCode(common.int.FAILURE));
      }
      return;
    }
    let condition: dataSharePredicates.DataSharePredicates = this.buildQueryContactCondition(actionData);
    let contactUri: string = common.STR.URI_ROW_CONTACTS + common.STR.CONTACT_URI;
    dataHelper.query(contactUri, condition, this.buildContactTablePartColumns()).then(resultSet => {
      callback(this.encapsulateReturnResult(common.int.SUCCESS, resultSet.rowCount));
      hiTraceMeter.finishTrace(TraceConstant.TRACE_QUERY_CONTACT_SIZE_BY_CONDITION,
        TraceConstant.TRACE_QUERY_CONTACT_SIZE_BY_CONDITION_ID);
      resultSet.close();
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'queryContactSizeByCondition fail, error: ' + JSON.stringify(error));
      callback(this.encapsulateReturnCode(common.int.FAILURE));
      hiTraceMeter.finishTrace(TraceConstant.TRACE_QUERY_CONTACT_SIZE_BY_CONDITION,
        TraceConstant.TRACE_QUERY_CONTACT_SIZE_BY_CONDITION_ID);
    });
  }

  public async queryRawContactSizeByCondition(actionData: LooseObject, callback: Function, context: Context): Promise<void> {
    hiTraceMeter.startTrace(TraceConstant.TRACE_QUERY_RAW_CONTACT_SIZE_BY_CONDITION,
      TraceConstant.TRACE_QUERY_RAW_CONTACT_SIZE_BY_CONDITION_ID);
    let dataHelper:dataShare.DataShareHelper | undefined = await DataShareHelper.getInstance().initContactDB(context);
    let condition: dataSharePredicates.DataSharePredicates = this.buildQueryRawContactCondition(actionData);
    if (!dataHelper) {
      HiLog.e(TAG, `[queryRawContactSizeByCondition] createDataShareHelper fail`);
      if (callback) {
        callback(this.encapsulateReturnCode(common.int.FAILURE));
      }
      return;
    }
    let rawContactUri: string = common.STR.URI_ROW_CONTACTS + common.STR.PROFILE_DATA_URI;
    dataHelper.query(rawContactUri, condition, this.buildRawContactTablePartColumns()).then(resultSet => {
      callback(this.encapsulateReturnResult(common.int.SUCCESS, resultSet.rowCount));
      hiTraceMeter.finishTrace(TraceConstant.TRACE_QUERY_RAW_CONTACT_SIZE_BY_CONDITION,
        TraceConstant.TRACE_QUERY_RAW_CONTACT_SIZE_BY_CONDITION_ID);
      resultSet.close();
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'queryRawContactSizeByCondition fail, error: ' + JSON.stringify(error));
      callback(this.encapsulateReturnCode(common.int.FAILURE));
      hiTraceMeter.finishTrace(TraceConstant.TRACE_QUERY_RAW_CONTACT_SIZE_BY_CONDITION,
        TraceConstant.TRACE_QUERY_RAW_CONTACT_SIZE_BY_CONDITION_ID);
    });
  }

  public async queryRecentContactByRow(actionData: LooseObject, callback: Function, context: Context): Promise<void> {
    hiTraceMeter.startTrace(TraceConstant.TRACE_QUERY_RECENT_CONTACT_BY_ROW,
      TraceConstant.TRACE_QUERY_RECENT_CONTACT_BY_ROW_ID);
    let dataHelper:dataShare.DataShareHelper | undefined = await DataShareHelper.getInstance().initContactDB(context);
    if (!dataHelper) {
      HiLog.e(TAG, `[queryRecentContactByRow] createDataShareHelper fail`);
      if (callback) {
        callback(this.encapsulateReturnCode(common.int.FAILURE));
      }
      return;
    }
    let condition: dataSharePredicates.DataSharePredicates = this.buildQueryRecentContactByRowCondition(actionData);
    let contactDataUri: string = common.STR.URI_ROW_CONTACTS + common.STR.CONTACT_DATA_URI;
    dataHelper.query(contactDataUri, condition, this.buildRecentContactColumns()).then(resultSet => {
      let resultList: Array<LooseObject> = [];
      if (resultSet.rowCount > 0) {
        while (resultSet.goToNextRow()) {
          let resultData = this.buildRecentContactResult(resultSet)
          resultList.push(resultData);
        }
      }
      resultSet.close();
      callback(this.encapsulateReturnResult(common.int.SUCCESS, resultList));
      hiTraceMeter.finishTrace(TraceConstant.TRACE_QUERY_RECENT_CONTACT_BY_ROW,
        TraceConstant.TRACE_QUERY_RECENT_CONTACT_BY_ROW_ID);
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'queryContactDataByCondition fail, error: ' + JSON.stringify(error));
      callback(this.encapsulateReturnCode(common.int.FAILURE));
      hiTraceMeter.finishTrace(TraceConstant.TRACE_QUERY_RECENT_CONTACT_BY_ROW,
        TraceConstant.TRACE_QUERY_RECENT_CONTACT_BY_ROW_ID);
    });
  }

  public async queryContactViewByCondition(actionData: LooseObject, callback: Function, context: Context): Promise<void> {
    hiTraceMeter.startTrace(TraceConstant.TRACE_QUERY_CONTACT_VIEW_BY_CONDITION,
      TraceConstant.TRACE_QUERY_CONTACT_VIEW_BY_CONDITION_ID);
    let dataHelper:dataShare.DataShareHelper | undefined = await DataShareHelper.getInstance().initContactDB(context);
    if (!dataHelper) {
      HiLog.e(TAG, `[queryContactViewByCondition] createDataShareHelper fail`);
      if (callback) {
        callback(this.encapsulateReturnCode(common.int.FAILURE));
      }
      return;
    }
    let condition: dataSharePredicates.DataSharePredicates = this.buildQueryContactViewCondition(actionData);
    let searchContactViewUri: string = common.STR.URI_ROW_CONTACTS + common.STR.CONTACT_SEARCHE;
    dataHelper.query(searchContactViewUri, condition, this.buildRawContactViewPartColumns()).then(resultSet => {
      let resultList: Array<LooseObject> = [];
      if (resultSet.rowCount > 0) {
        while (resultSet.goToNextRow()) {
          resultList.push(this.buildContactViewResult(resultSet));
        }
      }
      callback(this.encapsulateReturnResult(common.int.SUCCESS, resultList));
      hiTraceMeter.finishTrace(TraceConstant.TRACE_QUERY_CONTACT_VIEW_BY_CONDITION,
        TraceConstant.TRACE_QUERY_CONTACT_VIEW_BY_CONDITION_ID);
      resultSet.close();
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'queryContactViewByCondition fail, error: ' + JSON.stringify(error));
      callback(this.encapsulateReturnCode(common.int.FAILURE));
      hiTraceMeter.finishTrace(TraceConstant.TRACE_QUERY_CONTACT_VIEW_BY_CONDITION,
        TraceConstant.TRACE_QUERY_CONTACT_VIEW_BY_CONDITION_ID);
    });
  }

  private buildContactDataColumns(): Array<string> {
    // part of contact_data table columns
    return [
    mmsTable.contactDataColumns.detailInfo,
    mmsTable.contactDataColumns.displayName,
    mmsTable.contactDataColumns.id,
    mmsTable.contactDataColumns.rawContactId,
    mmsTable.contactDataColumns.contactId,
    ];
  }

  private buildRecentContactColumns(): Array<string> {
    // part of contact_data table columns
    return [
    mmsTable.contactDataColumns.detailInfo,
    mmsTable.contactDataColumns.displayName,
    mmsTable.contactDataColumns.id,
    mmsTable.contactDataColumns.primary,
    mmsTable.contactDataColumns.rawContactId,
    mmsTable.contactDataColumns.contactId,
    common.recent_contacts.sortKey,
    common.recent_contacts.sortSecondEY,
    ];
  }

  private buildContactDataTablePartColumns(): Array<string> {
    // part of contact_data table columns
    return [
    mmsTable.contactDataColumns.detailInfo,
    mmsTable.contactDataColumns.displayName,
    ];
  }

  private buildContactTablePartColumns(): Array<string> {
    // part of contact table columns
    return [
    mmsTable.contactColumns.id
    ];
  }

  private buildRawContactTablePartColumns(): Array<string> {
    // part of raw_contact table columns
    return [
    mmsTable.contactDataColumns.id
    ];
  }

  private buildRawContactViewPartColumns(): Array<string> {
    // part of contact view table columns
    return [
    mmsTable.searchContactView.detailInfo,
    mmsTable.searchContactView.displayName,
    mmsTable.contactDataColumns.rawContactId
    ];
  }

  private buildContactDataResult(resultSet: DataShareResultSet): LooseObject {
    let result: LooseObject = {};
    result.detailInfo = resultSet.getString(resultSet.getColumnIndex(mmsTable.contactDataColumns.detailInfo));
    result.displayName = resultSet.getString(resultSet.getColumnIndex(mmsTable.contactDataColumns.displayName));
    result.id = Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.contactDataColumns.id)));
    result.rawContactId = resultSet.getString(resultSet.getColumnIndex(mmsTable.contactDataColumns.rawContactId));
    result.contactId = resultSet.getString(resultSet.getColumnIndex(mmsTable.contactDataColumns.contactId));
    if (result.contactId !== common.STR.EMPTY_STR && result.displayName === common.STR.EMPTY_STR) {
      HiLog.e(TAG, '[buildContactDataResult] Contact Query error.contactId ' + result.contactId);
    }
    return result;
  }

  private buildRecentContactResult(resultSet: DataShareResultSet): LooseObject {
    let result: LooseObject = {};
    result.detailInfo = resultSet.getString(resultSet.getColumnIndex(mmsTable.contactDataColumns.detailInfo));
    result.displayName = resultSet.getString(resultSet.getColumnIndex(mmsTable.contactDataColumns.displayName));
    result.id = Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.contactDataColumns.id)));
    result.primary = Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.contactDataColumns.primary)));
    result.rawContactId = resultSet.getString(
      resultSet.getColumnIndex(mmsTable.contactDataColumns.rawContactId));
    result.contactId = resultSet.getString(
      resultSet.getColumnIndex(mmsTable.contactDataColumns.contactId));
    result.connectedCount = Number(resultSet.getString(
      resultSet.getColumnIndex(common.recent_contacts.sortKey)));
    result.lastestedTime = resultSet.getString(
      resultSet.getColumnIndex(common.recent_contacts.sortSecondEY));
    return result;
  }

  private buildContactResult(resultSet: DataShareResultSet): LooseObject {
    let result: LooseObject = {};
    result.id = Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.contactColumns.id)));
    return result;
  }

  private buildContactViewResult(resultSet: DataShareResultSet): LooseObject {
    let result: LooseObject = {};
    result.detailInfo = resultSet.getString(resultSet.getColumnIndex(mmsTable.contactDataColumns.detailInfo));
    result.displayName = resultSet.getString(resultSet.getColumnIndex(mmsTable.contactDataColumns.displayName));
    result.rawContactId = resultSet.getString(resultSet.getColumnIndex(mmsTable.contactDataColumns.rawContactId));
    return result;
  }

  private buildQueryContactDataCondition(actionData: LooseObject): dataSharePredicates.DataSharePredicates {
    let condition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    condition.equalTo(mmsTable.contactDataColumns.typeId, '5');
    let isFuzzyMatch: boolean = actionData.isFuzzyMatch !== null ? actionData.isFuzzyMatch : false;
    if (actionData.hasDelete != null) {
      condition.and().equalTo(mmsTable.contactDataColumns.hasDelete, actionData.hasDelete);
    }
    if (actionData.contactIds != null && actionData.contactIds.length > 0) {
      condition.and().in(mmsTable.contactDataColumns.contactId, actionData.contactIds);
    }
    if (actionData.telephones != null && actionData.telephones.length > 0) {
      this.conditionOrTelephones(actionData.telephones, condition, isFuzzyMatch);
    }
    if (actionData.page != null && actionData.limit != null) {
      let offset: number = (actionData.page - 1) * actionData.limit;
      condition.and().limit(actionData.limit, offset);
    }
    if (actionData.searchName && actionData.searchName !== '') {
      condition.and().like(mmsTable.contactDataColumns.displayName, '%' + actionData.searchName + '%');
    }
    if (actionData.transmitSearchInput && actionData.transmitSearchInput !== '') {
      condition.and()
        .beginWrap()
        .like(mmsTable.contactDataColumns.displayName, '%' + actionData.transmitSearchInput + '%')
        .or()
        .like(mmsTable.contactDataColumns.detailInfo, '%' + actionData.transmitSearchInput + '%')
        .endWrap();
    }
    if (actionData.startUpdateTime) {
      condition.and().greaterThan(mmsTable.contactColumns.contactLastUpdatedTimestamp, actionData.startUpdateTime);
    }
    if (actionData.endUpdateTime) {
      condition.and().lessThanOrEqualTo(mmsTable.contactColumns.contactLastUpdatedTimestamp, actionData.endUpdateTime);
    }
    return condition;
  }

  private conditionOrTelephones(telephones: string[], condition: dataSharePredicates.DataSharePredicates,
    isFuzzyMatch: boolean) {
    condition.beginWrap();
    let arr: string[] = [];
    let regExp = new RegExp('[\\s]', 'g');
    for (let i = 0; i < telephones.length; i++) {
      let telPhone = telephones[i];
      //如果电话号码尾数小于等于7位，直接全等匹配
      if (telPhone.length <= 7) {
        condition.and().beginWrap().equalTo(mmsTable.contactDataColumns.formatNumber, telPhone).or()
          .equalTo(mmsTable.contactDataColumns.detailInfo, telPhone).endWrap();
        arr.push(telPhone);
        this.orCondition(telephones, condition, i);
      } else {
        if (isFuzzyMatch) {
          let tel = TelephoneUtil.formatDisplayPhoneNum(telPhone).replace(regExp, '');
          condition.beginWrap().endsWith(mmsTable.contactDataColumns.formatNumber, tel.substring(tel.length - 7)).or()
            .endsWith(mmsTable.contactDataColumns.detailInfo, tel.substring(tel.length - 7)).endWrap();
          this.orCondition(telephones, condition, i);
        } else {
          let tel = TelephoneUtil.formatDisplayPhoneNum(telPhone).replace(regExp, '');
          condition.beginWrap().endsWith(mmsTable.contactDataColumns.formatNumber, tel).or()
            .endsWith(mmsTable.contactDataColumns.detailInfo, tel).endWrap();
          arr.push(tel);
          this.orCondition(telephones, condition, i);
        }
      }
      if (i == telephones.length - 1) {
        condition.endWrap();
      }
    }
  }

  orCondition(telephones: string[], condition: dataSharePredicates.DataSharePredicates, i: number) {
    if (i < telephones.length - 1) {
      //或的关系匹配
      condition.or();
    }
  }

  private buildQueryContactCondition(actionData: LooseObject): dataSharePredicates.DataSharePredicates {
    let condition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    condition.isNotNull(mmsTable.contactColumns.id);
    if (actionData.page != null && actionData.limit != null) {
      let offset: number = (actionData.page - 1) * actionData.limit;
      condition.and().limit(actionData.limit, offset);
    }
    if (actionData.telephone != null) {
      condition.and()
        .equalTo(mmsTable.searchContactView.contentType, 'phone')
        .beginWrap()
        .contains(mmsTable.searchContactView.displayName, actionData.telephone)
        .or()
        .contains(mmsTable.searchContactView.detailInfo, actionData.telephone)
        .endWrap();
    }
    if (actionData.orderByTimeDesc != null) {
      condition.orderByDesc(mmsTable.contactColumns.lastestContactedTime);
    }
    return condition;
  }

  private buildQueryRawContactCondition(actionData: LooseObject): dataSharePredicates.DataSharePredicates {
    let condition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    return condition;
  }

  private buildQueryRecentContactByRowCondition(actionData: LooseObject): dataSharePredicates.DataSharePredicates {
    let condition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    switch (actionData.type) {
      case common.recent_contacts.type:
        condition.equalTo(mmsTable.contactDataColumns.typeId, '5')
          .and()
          .equalTo(common.recent_contacts.isDeleted, 0);
        condition.greaterThan(common.recent_contacts.sortKey, 0)
          .orderByDesc(common.recent_contacts.sortKey)
          .limit(common.int.RECENT_TOTAL_LIMIT, common.int.RECENT_OFFSET_LIMIT)
          .and()
          .orderByDesc(common.recent_contacts.sortSecondEY)
        break;
      default:
        HiLog.e(TAG, 'buildQueryRecentContactByRowCondition un_know type');
        break;
    }
    return condition;
  }

  public buildQueryContactViewCondition(actionData: LooseObject): dataSharePredicates.DataSharePredicates {
    let condition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    condition.equalTo(mmsTable.searchContactView.contentType, 'phone')
      .beginWrap()
      .contains(mmsTable.searchContactView.displayName, actionData.telephone)
      .or()
      .contains(mmsTable.searchContactView.detailInfo, actionData.telephone)
      .endWrap()
      .and()
      .equalTo(mmsTable.searchContactView.hasDelete, 0);
    return condition;
  }

}