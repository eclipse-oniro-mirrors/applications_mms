/**
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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
const TAG = 'SatellitePlane';
let dataShareHelper: dataShare.DataShareHelper;

export async function addAIFaceChangeModeListener(callback: Function, context?: Context) {
  HiLog.i(TAG, 'addSatellitePlaneModeListener');
  try {
    let mmsContext = context ? context : GlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext;
    initDb(mmsContext, callback);
  } catch (err) {
    HiLog.e(TAG, 'addSatellitePlaneModeListener error: code: ' + (err as BusinessError).code + ', message: ' + (err as BusinessError).message);
  }
}

function initDb(mmsContext: Context, callback: Function) {
  dataShare.createDataShareHelper(mmsContext, commonData.STR.SETTING_AI_FACE_CHANGE_MODE_URI, (err, data) => {
    if (err != undefined) {
      HiLog.e(TAG, 'addSatellitePlaneModeListener error: code: ' + (err as BusinessError).code + ', message: ' + (err as BusinessError).message);
      return;
    }
    dataShareHelper = data;
    try {
      dataShareHelper.on('dataChange', commonData.STR.SETTING_AI_FACE_CHANGE_MODE_URI, () => {
        HiLog.i(TAG, 'addSatellitePlaneModeListener dataChange');
        callback()
      });
      callback()
    } catch (err) {
      HiLog.e(TAG, 'addSatellitePlaneModeListener error: code: ' + (err as BusinessError).code + ', message: ' + (err as BusinessError).message);
    }
  });
}


export async function removeAIFaceChangeModeListener() {
  HiLog.i(TAG, 'removeSatellitePlaneListener');
  if (!dataShareHelper) {
    HiLog.e(TAG, 'removeSatellitePlaneListener dataShareHelper null');
    return;
  }
  try {
    dataShareHelper.off('dataChange', commonData.STR.SETTING_AI_FACE_CHANGE_MODE_URI);
  } catch (err) {
    HiLog.e(TAG, 'removeSatellitePlaneListener error: code: ' + (err as BusinessError).code + ', message: ' + (err as BusinessError).message);
  }
}

export async function queryFaceChangeDetectMode(callback: Function) {
  HiLog.i(TAG, 'queryFaceChangeDetectMode ');
  if (!dataShareHelper) {
    HiLog.e(TAG, 'queryFaceChangeDetectMode dataShareHelper null');
    return;
  }
  let condition = new dataSharePredicates.DataSharePredicates();
  try {
    condition.equalTo('KEYWORD', 'spamshield_message_live_detection');
    dataShareHelper.query(commonData.STR.SETTING_AI_FACE_CHANGE_MODE_URI, condition, []).then((resultSet) => {
      HiLog.i(TAG, 'queryFaceChangeDetectMode query succeed');
      if (resultSet.rowCount > 0) {
        resultSet.goToLastRow();
        let value = resultSet.getLong(resultSet.getColumnIndex('VALUE'));
        callback(value);
      } else {
        callback(0);
      }
      resultSet.close();
    }).catch((err: BusinessError) => {
      HiLog.e(TAG, 'queryFaceChangeDetectMode query in error: err: ' + JSON.stringify(err));
    });
  } catch (err) {
    HiLog.e(TAG, 'queryFaceChangeDetectMode query out error: code: ' + (err as BusinessError).code + ', message: ' + (err as BusinessError).message);
  }
}