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
import dataShare from "@ohos.data.dataShare";
import dataSharePredicates from "@ohos.data.dataSharePredicates";

import BaseModel from "./BaseModel";
import common from "../data/commonData";
import HiLog from "../utils/HiLog";
import mmsTable from "../data/tableData";
import LooseObject from "../data/LooseObject"

const TAG = "ContactsModel";

export default class ContactsModel extends BaseModel {
  public async queryContactDataByCondition(actionData, callback, context): Promise<void> {
    let dataHelper = await dataShare.createDataShareHelper(context, common.string.URI_ROW_CONTACTS);
    let condition: dataSharePredicates.DataSharePredicates = this.buildQueryContactDataCondition(actionData);
    let contactDataUri: string = common.string.URI_ROW_CONTACTS + common.string.CONTACT_DATA_URI;
    dataHelper.query(contactDataUri, condition, this.buildContactDataTablePartColumns()).then(resultSet => {
      let resultList: Array<LooseObject> = [];
      if (resultSet.rowCount > 0) {
        while (resultSet.goToNextRow()) {
          resultList.push(this.buildContactDataResult(resultSet));
        }
      }
      callback(this.encapsulateReturnResult(common.int.SUCCESS, resultList));
      resultSet.close();
    }).catch(error => {
      HiLog.e(TAG, "queryContactDataByCondition fail, error: " + JSON.stringify(error));
      callback(this.encapsulateReturnCode(common.int.FAILURE));
    });
  }

  public async queryContactDataSizeByCondition(actionData, callback, context): Promise<void> {
    let dataHelper = await dataShare.createDataShareHelper(context, common.string.URI_ROW_CONTACTS);
    let condition: dataSharePredicates.DataSharePredicates = this.buildQueryContactDataCondition(actionData);
    let contactDataUri: string = common.string.URI_ROW_CONTACTS + common.string.CONTACT_DATA_URI;
    dataHelper.query(contactDataUri, condition, this.buildContactDataTablePartColumns()).then(resultSet => {
      callback(this.encapsulateReturnResult(common.int.SUCCESS, resultSet.rowCount));
      resultSet.close();
    }).catch(error => {
      HiLog.e(TAG, "queryContactDataSizeByCondition fail, error: " + JSON.stringify(error));
      callback(this.encapsulateReturnCode(common.int.FAILURE));
    });
  }

  public async queryContactByCondition(actionData, callback, context): Promise<void> {
    let dataHelper = await dataShare.createDataShareHelper(context, common.string.URI_ROW_CONTACTS);
    let condition: dataSharePredicates.DataSharePredicates = this.buildQueryContactCondition(actionData);
    let contactUri: string = common.string.URI_ROW_CONTACTS + common.string.CONTACT_URI;
    dataHelper.query(contactUri, condition, this.buildContactTablePartColumns()).then(resultSet => {
      let resultList: Array<LooseObject> = [];
      if (resultSet.rowCount > 0) {
        while (resultSet.goToNextRow()) {
          resultList.push(this.buildContactResult(resultSet));
        }
      }
      callback(this.encapsulateReturnResult(common.int.SUCCESS, resultList));
      resultSet.close();
    }).catch(error => {
      HiLog.e(TAG, "queryContactByCondition fail, error: " + JSON.stringify(error));
      callback(this.encapsulateReturnCode(common.int.FAILURE));
    });
  }

  public async queryContactSizeByCondition(actionData, callback, context): Promise<void> {
    let dataHelper = await dataShare.createDataShareHelper(context, common.string.URI_ROW_CONTACTS);
    let condition: dataSharePredicates.DataSharePredicates = this.buildQueryContactCondition(actionData);
    let contactUri: string = common.string.URI_ROW_CONTACTS + common.string.CONTACT_URI;
    dataHelper.query(contactUri, condition, this.buildContactTablePartColumns()).then(resultSet => {
      callback(this.encapsulateReturnResult(common.int.SUCCESS, resultSet.rowCount));
      resultSet.close();
    }).catch(error => {
      HiLog.e(TAG, "queryContactSizeByCondition fail, error: " + JSON.stringify(error));
      callback(this.encapsulateReturnCode(common.int.FAILURE));
    });
  }

  public async queryRawContactSizeByCondition(actionData, callback, context): Promise<void> {
    let dataHelper = await dataShare.createDataShareHelper(context, common.string.URI_ROW_CONTACTS);
    let condition: dataSharePredicates.DataSharePredicates = this.buildQueryRawContactCondition(actionData);
    let rawContactUri: string = common.string.URI_ROW_CONTACTS + common.string.PROFILE_DATA_URI;
    dataHelper.query(rawContactUri, condition, this.buildRawContactTablePartColumns()).then(resultSet => {
      callback(this.encapsulateReturnResult(common.int.SUCCESS, resultSet.rowCount));
      resultSet.close();
    }).catch(error => {
      HiLog.e(TAG, "queryRawContactSizeByCondition fail, error: " + JSON.stringify(error));
      callback(this.encapsulateReturnCode(common.int.FAILURE));
    });
  }

  public async queryContactViewByCondition(actionData, callback, context): Promise<void> {
    let dataHelper = await dataShare.createDataShareHelper(context, common.string.URI_ROW_CONTACTS);
    let condition: dataSharePredicates.DataSharePredicates = this.buildQueryContactViewCondition(actionData);
    let searchContactViewUri: string = common.string.URI_ROW_CONTACTS + common.string.CONTACT_SEARCHE;
    dataHelper.query(searchContactViewUri, condition, this.buildRawContactViewPartColumns()).then(resultSet => {
      let resultList: Array<LooseObject> = [];
      if (resultSet.rowCount > 0) {
        while (resultSet.goToNextRow()) {
          resultList.push(this.buildContactViewResult(resultSet));
        }
      }
      callback(this.encapsulateReturnResult(common.int.SUCCESS, resultList));
      resultSet.close();
    }).catch(error => {
      HiLog.e(TAG, "queryContactViewByCondition fail, error: " + JSON.stringify(error));
      callback(this.encapsulateReturnCode(common.int.FAILURE));
    });
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
    mmsTable.searchContactView.displayName
    ];
  }

  private buildContactDataResult(resultSet): LooseObject {
    let result: LooseObject = {};
    result.detailInfo = resultSet.getString(resultSet.getColumnIndex(mmsTable.contactDataColumns.detailInfo));
    result.displayName = resultSet.getString(resultSet.getColumnIndex(mmsTable.contactDataColumns.displayName));
    return result;
  }

  private buildContactResult(resultSet): LooseObject {
    let result: LooseObject = {};
    result.id = Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.contactColumns.id)));
    return result;
  }

  private buildContactViewResult(resultSet): LooseObject {
    let result: LooseObject = {};
    result.detailInfo = resultSet.getString(resultSet.getColumnIndex(mmsTable.contactDataColumns.detailInfo));
    result.displayName = resultSet.getString(resultSet.getColumnIndex(mmsTable.contactDataColumns.displayName));
    return result;
  }

  private buildQueryContactDataCondition(actionData): dataSharePredicates.DataSharePredicates {
    let condition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    condition.equalTo(mmsTable.contactDataColumns.typeId, "5");
    if (actionData.hasDelete != null) {
      condition.and().equalTo(mmsTable.contactDataColumns.hasDelete, actionData.hasDelete);
    }
    if (actionData.contactIds != null && actionData.contactIds.length > 0) {
      condition.and().in(mmsTable.contactDataColumns.contactId, actionData.contactIds);
    }
    if (actionData.telephones != null && actionData.telephones.length > 0) {
      condition.and().in(mmsTable.contactDataColumns.detailInfo, actionData.telephones);
    }
    return condition;
  }

  private buildQueryContactCondition(actionData): dataSharePredicates.DataSharePredicates {
    let condition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    condition.isNotNull(mmsTable.contactColumns.id);
    if (actionData.page != null && actionData.limit != null) {
      let offset: number = (actionData.page - 1) * actionData.limit;
      condition.and().limit(actionData.limit, offset);
    }
    if (actionData.telephone != null) {
      condition.and()
        .equalTo(mmsTable.searchContactView.contentType, "phone")
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

  private buildQueryRawContactCondition(actionData): dataSharePredicates.DataSharePredicates {
    let condition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    return condition;
  }

  private buildQueryContactViewCondition(actionData): dataSharePredicates.DataSharePredicates {
    let condition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    condition.equalTo(mmsTable.searchContactView.contentType, "phone")
      .beginWrap()
      .contains(mmsTable.searchContactView.displayName, actionData.telephone)
      .or()
      .contains(mmsTable.searchContactView.detailInfo, actionData.telephone)
      .endWrap();
    return condition;
  }
}