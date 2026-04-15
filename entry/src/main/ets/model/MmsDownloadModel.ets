/**
 * Copyright (c) 2024-2024 Huawei Device Co., Ltd.
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
import DataShareHelper from './repository/DataShareHelper';
import HiLog from '../utils/HiLog';
import { BusinessError } from '@ohos.base';
import commonData from '../data/commonData';
import mmsTable from '../data/tableData';
import LooseObject from '../data/LooseObject';
import ConversationModel from './ConversationModel';

const TAG = 'MmsDownloadModel';

export default class MmsDownloadModel extends BaseModel {
  private conversationModel: ConversationModel = new ConversationModel();
  public async queryUnDownloadMms(context: Context): Promise<LooseObject> {
    HiLog.i(TAG, 'queryUnDownloadMms start');
    let dataHelper:dataShare.DataShareHelper | undefined = await DataShareHelper.getInstance().initSmsDB(context);
    if (!dataHelper) {
      HiLog.e(TAG, '[queryUnDownloadMms] createDataShareHelper fail');
      return this.encapsulateReturnCode(commonData.int.FAILURE);
    }
    let condition: dataSharePredicates.DataSharePredicates = this.buildQueryUnDownloadMmsCondition();
    let managerUri = commonData.STR.URI_MESSAGE_LOG + commonData.STR.URI_MESSAGE_INFO_TABLE;
    let resultList: LooseObject[] = [];
    await dataHelper.query(managerUri, condition,
      this.conversationModel.buildMmsNotDownloadTableColumns()).then(resultSet => {
        if (resultSet.rowCount > 0) {
        while (resultSet.goToNextRow()) {
          resultList.push(this.conversationModel.buildMmsNotDownloadInfoResult(resultSet));
        }
      }
      resultSet.close();
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'queryUnDownloadMms fail, error: ' + JSON.stringify(error));
    });
    return this.encapsulateReturnResult(commonData.int.SUCCESS, resultList);
  }

  private buildQueryUnDownloadMmsCondition(): dataSharePredicates.DataSharePredicates {
    let condition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    condition.equalTo(mmsTable.messageInfo.msgState, commonData.int.MMS_NOT_DOWNLOAD);
    condition.and().equalTo(mmsTable.messageInfo.isBlocked, commonData.isBlocked.NOT_BLOCKED);
    return condition;
  }
}