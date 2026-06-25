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
import dataShare from '@ohos.data.dataShare';
import commonData from '../data/commonData';
import { dataSharePredicates } from '@kit.ArkData';
import DataShareHelper from '../model/repository/DataShareHelper';
import HiLog from '../utils/HiLog';
import { common } from '@kit.AbilityKit';
import { GlobalContext } from '../MainAbility/GlobalHelper';
import { BusinessError } from '@kit.BasicServicesKit';
import SharedPreferencesUtils from '../utils/SharedPreferencesUtils';
import InfoMsgController from '../pages/infomsg/InfoMsgController';
import PreferenceUtil from '../backup/util/PreferenceUtil';
import BackupExtensionContext from '@ohos.file.BackupExtensionContext';

const TAG = '[Database-Maintain]';

export default class DatabaseMaintain {
  private static instance: DatabaseMaintain | undefined = undefined;

  constructor() {
  }

  public static getInstance() {
    if (!DatabaseMaintain.instance) {
      DatabaseMaintain.instance = new DatabaseMaintain();
    }
    return DatabaseMaintain.instance;
  }

  public static release() {
    DatabaseMaintain.instance = undefined;
  }

  public getCurrentContext(): common.UIAbilityContext {
    let context = (GlobalContext.getContext().getObject('mmsContext') as common.UIAbilityContext);
    if (!context) {
      context = (GlobalContext.getContext()
        .getObject('mmsServiceContext') as common.UIAbilityContext) as common.UIAbilityContext;
    }
    return context;
  }

  public databaseCleanup(context: Context) {
    if (!this.checkNeedClean()) {
      return;
    }
    this.doInvalidSessionClean(context);
  }

  private checkNeedClean(): boolean {
    let curTime: number = new Date().getTime();
    let startTime = SharedPreferencesUtils.getFromPreferences(PreferenceUtil.DATABASE_CLONE_START_TIME, 0) as number;
    HiLog.e(TAG, `record start time (${startTime}), current (${curTime})`);
    if ((startTime == 0) || ((curTime - startTime) < 70 * 60 * 1000)) {
      return false;
    }
    return true;
  }

  public recordCloneStart(context: BackupExtensionContext) {
    let time: number = new Date().getTime();
    HiLog.e(TAG, 'record Clone Start ' + time);
    PreferenceUtil.getInstance().init(context);
    SharedPreferencesUtils.init(context);
    SharedPreferencesUtils.saveToPreferences(PreferenceUtil.DATABASE_CLONE_START_TIME, time);
  }

  public updateInfoMsgVersion(context: BackupExtensionContext) {
    HiLog.i(TAG, 'update Info MsgVersion ');
    PreferenceUtil.getInstance().init(context);
    SharedPreferencesUtils.init(context);
    SharedPreferencesUtils.saveToPreferences('updateInfoMsgVersion', 0);
    // 增加更新页面
    SharedPreferencesUtils.saveToPreferences('updateAfterClone', true);
  }

  private cleanRecords() {
    SharedPreferencesUtils.saveToPreferences(PreferenceUtil.DATABASE_CLONE_START_TIME, 0);
  }

  public async doInvalidSessionClean(context: Context) {
    HiLog.e(TAG, 'doInvalidSessionClean');
    let dataHelper = await DataShareHelper.getInstance().initSmsDB(this.getCurrentContext());
    dataHelper = dataHelper as dataShare.DataShareHelper;
    let managerUri: string = commonData.STR.URI_MESSAGE_LOG + commonData.STR.URI_MESSAGE_DELETE_INVALID_SESSION;
    dataHelper.delete(managerUri, new dataSharePredicates.DataSharePredicates()).then(res => {
      HiLog.e(TAG, `invalid session deletion finished with ${res} and refresh conversion list.`);
      this.cleanRecords();
      InfoMsgController.getInstance().requestItemFromOther(context);
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'invalid session deletion fail, error: ' + JSON.stringify(error));
    });
  }

}
