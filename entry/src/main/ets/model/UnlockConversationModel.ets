/**
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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
import { BusinessError } from '@ohos.base';
import DataShareHelper from './repository/DataShareHelper';

const TAG = 'UnlockConversationModel';

// 适配屏幕解锁公共事件性能优化，请勿增加其他业务
export default class UnlockConversationModel extends BaseModel {
  public async statisticalData(callback: Function, context: Context) {
    let dataHelper:dataShare.DataShareHelper | undefined = await DataShareHelper.getInstance().initSmsDB(context);
    if (!dataHelper) {
      HiLog.e(TAG, '[statisticalData] createDataShareHelper fail');
      if (callback) {
        callback(this.encapsulateReturnCode(common.int.FAILURE));
      }
      return;
    }
    let resultColumns: string[] = [
      'totalListCount',
      'unreadCount',
      'unreadInfo',
      'unreadTotalOfInfo'
    ];
    let condition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    let managerUri: string = common.STR.URI_MESSAGE_LOG + common.STR.URI_MESSAGE_UNREAD_COUNT;
    dataHelper.query(managerUri, condition, resultColumns).then(resultSet => {
      let result: Record<string, number> = {
        'totalListCount': 0,
        'unreadCount': 0,
        'unreadInfo': 0,
        'unreadTotalOfInfo': 0
      };
      if (resultSet.rowCount > 0) {
        if (resultSet.goToLastRow()) {
          let totalListCount = resultSet.getLong(0);
          result.totalListCount = totalListCount < 0 ? 0 : totalListCount;
          let unreadCount = resultSet.getLong(1);
          result.unreadCount = unreadCount < 0 ? 0 : unreadCount;
          let unreadInfo = resultSet.getLong(2);
          result.unreadInfo = unreadInfo < 0 ? 0 : unreadInfo;
          let unreadTotalOfInfo = resultSet.getLong(3);
          result.unreadTotalOfInfo = unreadTotalOfInfo < 0 ? 0 : unreadTotalOfInfo;
          HiLog.i(TAG, 'totalListCount : ' + totalListCount + ' , unreadCount : ' + unreadCount +
            ' , unreadInfo : ' + unreadInfo + ' , unreadTotalOfInfo : ' + unreadTotalOfInfo)
        }
      }
      callback(this.encapsulateReturnResult(common.int.SUCCESS, result));
      resultSet.close();
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'statisticalData, error: ' + JSON.stringify(error));
      callback(this.encapsulateReturnCode(common.int.FAILURE));
    });
  }
}