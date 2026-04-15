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
import BaseModel from './BaseModel';
import HiLog from '../utils/HiLog';
import dataShare from '@ohos.data.dataShare';
import dataSharePredicates from '@ohos.data.dataSharePredicates';
import DataShareHelper from './repository/DataShareHelper';
import { BusinessError } from '@ohos.base';
import common from '../data/commonData';
import mmsTable from '../data/tableData';
import LooseObject from '../data/LooseObject';
import DataShareResultSet from '@ohos.data.DataShareResultSet';

const TAG: string = 'YellowPageModel';

export default class YellowPageModel extends BaseModel {

  public async queryYellowPageListInfoByCondition(actionData: LooseObject,
    callback: Function, context: Context): Promise<void> {
    HiLog.i(TAG, '[queryYellowPageListInfoByCondition] start')
    let dataHelper: dataShare.DataShareHelper | undefined =
      await DataShareHelper.getInstance().initYellowPageDB(context);
    if (!dataHelper) {
      HiLog.e(TAG, `[queryYellowPageListInfoByCondition] createDataShareHelper fail`);
      if (callback) {
        callback(this.encapsulateReturnCode(common.int.FAILURE));
      }
      return;
    }
    let condition: dataSharePredicates.DataSharePredicates = this.buildQueryYellowPageListCondition(actionData);
    let contactDataUri: string = common.STR.URI_YELLOW_PAGE + common.STR.URI_YELLOW_PAGE_INFO_ALL;
    let finalResultSet: DataShareResultSet;
    dataHelper.query(contactDataUri, condition, this.buildYellowPageListColumns()).then(resultSet => {
      finalResultSet = resultSet;
      HiLog.i(TAG, '[queryYellowPageListInfoByCondition] proceed query, rowCount: ' + resultSet.rowCount);
      let resultList: LooseObject[] = [];
      if (resultSet.rowCount > 0) {
        while (resultSet.goToNextRow()) {
          resultList.push(this.buildYellowPageListResult(resultSet));
        }
      }
      callback(this.encapsulateReturnResult(common.int.SUCCESS, resultList));
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'queryYellowPageListInfoByCondition fail, error: ' + JSON.stringify(error));
      callback(this.encapsulateReturnCode(common.int.FAILURE));
    }).finally(() => {
      if (finalResultSet) {
        finalResultSet.close();
      }
    });
  }

  private buildYellowPageListColumns(): Array<string> {
    // part of yellow_page_view columns
    return [
      mmsTable.yellowPageInfo.id,
      mmsTable.yellowPageInfo.number,
      mmsTable.yellowPageInfo.name,
      mmsTable.yellowPageInfo.photo,
    ];
  }

  private buildYellowPageListResult(resultSet: DataShareResultSet): LooseObject {
    let result: LooseObject = {};
    result.id = resultSet.getString(resultSet.getColumnIndex(mmsTable.yellowPageInfo.id));
    result.number = resultSet.getString(resultSet.getColumnIndex(mmsTable.yellowPageInfo.number));
    result.name = resultSet.getString(resultSet.getColumnIndex(mmsTable.yellowPageInfo.name));
    result.photo = resultSet.getString(resultSet.getColumnIndex(mmsTable.yellowPageInfo.photo));
    return result;
  }

  private buildQueryYellowPageListCondition(actionData: LooseObject): dataSharePredicates.DataSharePredicates {
    let condition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    if (actionData.yellowPageIds != null && actionData.yellowPageIds.length > 0) {
      condition.and().in(mmsTable.yellowPageInfo.id, actionData.yellowPageIds);
    }
    if (actionData.telephones != null && actionData.telephones.length > 0) {
      condition.and().in(mmsTable.yellowPageInfo.number, actionData.telephones);
    }
    if (actionData.page != null && actionData.limit != null) {
      let offset: number = (actionData.page - 1) * actionData.limit;
      condition.and().limit(actionData.limit, offset);
    }
    if (actionData.searchName && actionData.searchName !== '') {
      condition.and().like(mmsTable.yellowPageInfo.name, '%' + actionData.searchName + '%');
    }
    if (actionData.transmitSearchInput && actionData.transmitSearchInput !== '') {
      condition.and()
        .beginWrap()
        .like(mmsTable.yellowPageInfo.name, '%' + actionData.transmitSearchInput + '%')
        .or()
        .like(mmsTable.yellowPageInfo.number, '%' + actionData.transmitSearchInput + '%')
        .endWrap();
    }
    return condition;
  }

  public async queryYellowPageInfoByCondition(actionData: LooseObject,
    context: Context): Promise<LooseObject> {
    HiLog.i(TAG, 'queryYellowPageInfoByCondition');
    let dataHelper: dataShare.DataShareHelper | undefined =
      await DataShareHelper.getInstance().initYellowPageDB(context);
    if (!dataHelper) {
      HiLog.e(TAG, `[queryYellowPageInfoByCondition] createDataShareHelper fail`);
      return this.encapsulateReturnCode(common.int.FAILURE);
    }
    let managerUri: string = common.STR.URI_YELLOW_PAGE + common.STR.URI_YELLOW_PAGE_INFO_ALL
    let condition: dataSharePredicates.DataSharePredicates = this.buildQueryYellowPageInfoByCondition(actionData);
    try {
      let resultSet = await dataHelper.query(managerUri, condition, ['*']);
      let resultList: LooseObject[] = [];
      if (resultSet.rowCount > 0) {
        while (resultSet.goToNextRow()) {
          resultList.push(this.buildYellowPageInfoResult(resultSet));
        }
      }
      resultSet.close();
      return this.encapsulateReturnResult(common.int.SUCCESS, resultList);
    } catch (error) {
      HiLog.e(TAG, 'queryYellowPageInfoByCondition fail, error: ' + JSON.stringify(error));
      return this.encapsulateReturnCode(common.int.FAILURE);
    };
  }

  private buildQueryYellowPageInfoByCondition(actionData: LooseObject):
    dataSharePredicates.DataSharePredicates {
    let condition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    if (actionData.telephone != null) {
      condition.equalTo(mmsTable.yellowPageInfo.number, actionData.telephone);
    }
    return condition;
  }

  private buildYellowPageInfoResult(resultSet: DataShareResultSet): LooseObject {
    let result: LooseObject = {};
    result.id = resultSet.getString(resultSet.getColumnIndex(mmsTable.yellowPageInfo.id));
    result.number = resultSet.getString(resultSet.getColumnIndex(mmsTable.yellowPageInfo.number));
    result.name = resultSet.getString(resultSet.getColumnIndex(mmsTable.yellowPageInfo.name));
    result.photo = resultSet.getString(resultSet.getColumnIndex(mmsTable.yellowPageInfo.photo));
    return result;
  }
}