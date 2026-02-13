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
import BaseModel from './BaseModel';
import dataShare from '@ohos.data.dataShare';
import commonData from '../data/commonData';
import dataSharePredicates from '@ohos.data.dataSharePredicates';
import { BusinessError } from '@ohos.base';
import HiLog from '../utils/HiLog';
import DataShareResultSet from '@ohos.data.DataShareResultSet';
import mmsTable from '../data/tableData';

const TAG = 'NetModel';
const MMS_APN_TYPE = 'mms';

export class NetInfo {
  profileId: number = -1;
  mccMnc: string = '';
  apnTypes: string = '';
  homeUrl: string = '';
}

export default class NetModel extends BaseModel {
  public async queryNetInfo(actionData: Record<string, string>, callback: Function, context: Context): Promise<void> {
    HiLog.i(TAG, 'queryNetInfo start');
    let dataHelper = await dataShare.createDataShareHelper(context, commonData.STR.URI_ROW_NET);
    let condition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    condition.contains(mmsTable.net.apnTypes, MMS_APN_TYPE)
    .and()
    .equalTo(mmsTable.net.mccMnc, actionData.mccMnc);
    let netUri: string = commonData.STR.URI_ROW_NET + commonData.STR.NET_DATA_URI + actionData.simId;
    dataHelper.query(netUri, condition, this.buildNetTableColumns()).then(resultSet => {
      HiLog.i(TAG, 'rowCount: ' + resultSet.rowCount);
      let resultList: Array<NetInfo> = [];
      if (resultSet.rowCount > 0) {
        while (resultSet.goToNextRow()) {
          resultList.push(this.buildNetDataResult(resultSet));
        }
      }
      callback(this.encapsulateReturnResult(commonData.int.SUCCESS, resultList));
      resultSet.close();
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'queryNetInfo fail, error: ' + JSON.stringify(error));
      callback(this.encapsulateReturnCode(commonData.int.FAILURE));
    });
  }

  private buildNetTableColumns(): Array<string> {
    let tableColumns: Array<string> = [
      mmsTable.net.profileId,
      mmsTable.net.mccMnc,
      mmsTable.net.apnTypes,
      mmsTable.net.homeUrl,
    ];
    return tableColumns;
  }

  private buildNetDataResult(resultSet: DataShareResultSet): NetInfo {
    let result: NetInfo = new NetInfo();
    result.profileId = Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.net.profileId)));
    result.mccMnc = resultSet.getString(resultSet.getColumnIndex(mmsTable.net.mccMnc));
    result.apnTypes = resultSet.getString(resultSet.getColumnIndex(mmsTable.net.apnTypes));
    result.homeUrl = resultSet.getString(resultSet.getColumnIndex(mmsTable.net.homeUrl));
    return result;
  }
}