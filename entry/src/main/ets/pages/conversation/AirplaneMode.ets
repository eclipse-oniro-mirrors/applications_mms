/**
 * Copyright (c) 2023 Huawei Device Co., Ltd.
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


import HiLog from '../../utils/HiLog';
import dataShare from '@ohos.data.dataShare'
import dataSharePredicates from '@ohos.data.dataSharePredicates';
import commonData from '../../data/commonData';
import { BusinessError } from '@ohos.base';
import { GlobalContext } from '../../MainAbility/GlobalHelper';
import myCommon from '@ohos.app.ability.common';
import DataShareResultSet from '@ohos.data.DataShareResultSet';
import SharedPreferencesUtils from '../../utils/SharedPreferencesUtils';

const TAG = 'AirplaneMode';
let dataShareHelper: dataShare.DataShareHelper;

export async function addAirPlaneModeListener(callback: Function, context: Context) {
  HiLog.w(TAG, 'addAirPlaneModeListener');
  try {
      dataShare.createDataShareHelper(context, commonData.STR.SETTING_AIRPLANE_MODE_URI, (err, data) => {
      if (err != undefined) {
        HiLog.e(TAG, 'addAirPlaneModeListener error: code: ' + (err as BusinessError).code + ', message: ' + (err as BusinessError).message);
        return;
      }
      dataShareHelper = data;
      try {
        dataShareHelper.on('dataChange', commonData.STR.ON_SETTING_AIRPLANE_MODE_URI, () => {
          HiLog.i(TAG, 'addAirPlaneModeListener dataChange');
          queryAirPlaneMode(callback);
        });
        queryAirPlaneMode(callback);
      } catch (err) {
        HiLog.e(TAG, 'addAirPlaneModeListener error: code: ' + (err as BusinessError).code + ', message: ' + (err as BusinessError).message);
      }
    });
  } catch (err) {
    HiLog.e(TAG, 'addAirPlaneModeListener error: code: ' + (err as BusinessError).code + ', message: ' + (err as BusinessError).message);
  }
}

export async function removeAirPlaneModeListener() {
  HiLog.i(TAG, 'removeAirPlaneModeListener');
  if (!dataShareHelper) {
    HiLog.e(TAG, 'removeAirPlaneModeListener dataShareHelper null');
    return;
  }
  try {
    dataShareHelper.off('dataChange', commonData.STR.ON_SETTING_AIRPLANE_MODE_URI);
  } catch (err) {
    HiLog.e(TAG, 'removeAirPlaneModeListener error: code: ' + (err as BusinessError).code + ', message: ' + (err as BusinessError).message);
  }
}


export async function queryAirPlaneMode(callback: Function) {
  HiLog.i(TAG, 'queryAirPlaneMode ');
  if (!dataShareHelper) {
    HiLog.e(TAG, 'queryAirPlaneMode dataShareHelper null');
    return;
  }
  let condition = new dataSharePredicates.DataSharePredicates();
  try {
    condition.equalTo('KEYWORD', commonData.STR.QUERY_AIRPLANE_MODE_KEY);
    let dataShareResultSet: DataShareResultSet;
    dataShareHelper.query(commonData.STR.ON_SETTING_AIRPLANE_MODE_URI, condition, []).then((resultSet) => {
      HiLog.i(TAG, 'queryAirPlaneMode query succeed');
      dataShareResultSet = resultSet;
      if (resultSet.rowCount > 0) {
        resultSet.goToLastRow();
        let value = resultSet.getLong(resultSet.getColumnIndex('VALUE'));
        HiLog.i(TAG, 'queryAirPlaneStatus success value: ' + value);
        SharedPreferencesUtils.saveToPreferences('AirPlaneMode', value);
        callback(value);
      } else {
        callback(0);
      }
    }).catch((err: BusinessError) => {
      HiLog.e(TAG, 'queryAirPlaneMode query in error: err: ' + JSON.stringify(err));
    }).finally(() => {
      if (dataShareResultSet) {
        dataShareResultSet.close();
      }
    });
  } catch (err) {
    HiLog.e(TAG, 'queryAirPlaneMode query out error: code: ' + (err as BusinessError).code + ', message: ' + (err as BusinessError).message);
  }
}