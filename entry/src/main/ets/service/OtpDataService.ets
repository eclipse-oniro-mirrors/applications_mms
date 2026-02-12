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

import HiLog from '../utils/HiLog';
import dataShare from '@ohos.data.dataShare';
import dataSharePredicates from '@ohos.data.dataSharePredicates';
import DataShareResultSet from '@ohos.data.DataShareResultSet';
import common from '../data/commonData';

const TAG = 'OtpDataService';

interface Err {
    code: number,
    message: string
}
let dataHelper: dataShare.DataShareHelper | undefined = undefined;

class OtpDataService {
    createHelper(context: Context){
        let uri = common.STR.URI_MESSAGE_LOG;
        let that = this;
        dataShare.createDataShareHelper(context, uri, (err, data) => {
            if (err !== undefined) {
                return;
            }
            that.getDataHelper(data);
        });
    }
    getDataHelper(data: dataShare.DataShareHelper | undefined = undefined){
        dataHelper = data;
        return dataHelper;
    }
    async queryData(queryNewDataKey: string, queryNewDataValue: string, context: Context): Promise<string|undefined> {
        this.createHelper(context);
        let that = this;
        let managerUri: string = common.STR.URI_MESSAGE_LOG + common.STR.URI_MESSAGE_INFO_TABLE;
        let da = new dataSharePredicates.DataSharePredicates();
        da.equalTo(queryNewDataKey, queryNewDataValue);
        dataHelper?.query(managerUri, da, []).then((data: DataShareResultSet) =>  {
           that.queryDataString(data);
        }). catch((err: Err) => {
            HiLog.e(TAG, `query error: code: ${err.code}, message: ${err.message} `);
        });
        return;
    }
    queryDataString(data: DataShareResultSet){
        let resultSet: DataShareResultSet;
        let getString: string = '';
        resultSet = data;
        if(resultSet.rowCount > 0){
            let isGoToLastRow: boolean = resultSet.goToLastRow();
            HiLog.i(TAG, 'resultSet.goToLastRow: ' + isGoToLastRow);
            let columnIndex = 11;
            getString = resultSet.getString(columnIndex) as string;
            HiLog.i(TAG, 'resultSet.getString: ' + getString);
        }
        resultSet.close();
        return getString;
    }
}
export default new OtpDataService;