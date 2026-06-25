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
import HiLog from '../../utils/HiLog';
import dataShare from '@ohos.data.dataShare';
import common from '../../data/commonData';
import hiTraceMeter from '@ohos.hiTraceMeter';
import TraceConstant from '../../data/TraceConstant';
import commonData from '../../data/commonData';
import SharedPreferencesUtils from '../../utils/SharedPreferencesUtils';
import { BusinessError } from '@kit.BasicServicesKit';

export default class DataShareHelper {
  private static TAG = 'DataShareHelper';
  private static instance: DataShareHelper | undefined = undefined;
  private smsDbHelper?: dataShare.DataShareHelper;
  private smsDbSessionHelper?: dataShare.DataShareHelper;
  private contactDbHelper?: dataShare.DataShareHelper;
  private callLogDbHelper?: dataShare.DataShareHelper;
  private settingDbHelper?: dataShare.DataShareHelper;
  private yellowPageDbHelper?: dataShare.DataShareHelper;
  private contactSlienceDbHelper?: dataShare.DataShareHelper;

  private constructor() {
  }

  public static getInstance(): DataShareHelper {
    if (!DataShareHelper.instance) {
      DataShareHelper.instance = new DataShareHelper();
    }
    return DataShareHelper.instance;
  }

  public static release() {
    if (DataShareHelper.instance) {
      DataShareHelper.instance.smsDbHelper?.close();
      DataShareHelper.instance.contactDbHelper?.off('dataChange',
        dataShare.SubscriptionType.SUBSCRIPTION_TYPE_EXACT_URI,
        common.STR.URI_ROW_CONTACTS + common.STR.CONTACT_DATA_URI);
      DataShareHelper.instance.contactDbHelper?.close().then(() => {
        HiLog.i(DataShareHelper.TAG, 'contactDbHelper close Success');
      }).catch((error: BusinessError) => {
        HiLog.e(DataShareHelper.TAG, 'contactDbHelper close fail, error: ' + JSON.stringify(error));
      });
      DataShareHelper.instance.yellowPageDbHelper?.close();
      DataShareHelper.instance.callLogDbHelper?.close();
      DataShareHelper.instance.settingDbHelper?.close();
      DataShareHelper.instance = undefined;
    }
  }

  public async initSilenceSmsDBSessionTable(context: Context): Promise<dataShare.DataShareHelper | undefined> {
    hiTraceMeter.startTrace(TraceConstant.TRACE_DB_SESSION_INIT, TraceConstant.TRACE_DB_SESSION_INIT_ID)
    if (!context) {
      HiLog.w(DataShareHelper.TAG, 'initSilenceSmsDBSessionTable context is empty')
      hiTraceMeter.finishTrace(TraceConstant.TRACE_DB_SESSION_INIT, TraceConstant.TRACE_DB_SESSION_INIT_ID)
      return undefined;
    }
    if (this.smsDbSessionHelper) {
      HiLog.i(DataShareHelper.TAG, 'initSilenceSmsDBSessionTable already init, return.')
      hiTraceMeter.finishTrace(TraceConstant.TRACE_DB_SESSION_INIT, TraceConstant.TRACE_DB_SESSION_INIT_ID)
      return Promise.resolve(this.smsDbSessionHelper);
    }
    try {
      HiLog.i(DataShareHelper.TAG, 'initSilenceSmsDBSessionTable start');
      this.smsDbSessionHelper = await dataShare.createDataShareHelper(context, common.STR.URI_SESSION_TABLE_PROXY,
        { isProxy: Boolean(true) } as dataShare.DataShareHelperOptions);
    } catch (error) {
      HiLog.w(DataShareHelper.TAG, 'initSilenceSmsDBSessionTable failed , error msg:' + JSON.stringify(error))
    }
    if (this.smsDbSessionHelper) {
      HiLog.i(DataShareHelper.TAG, 'initSilenceSmsDBSessionTable first init,success.')
      hiTraceMeter.finishTrace(TraceConstant.TRACE_DB_SESSION_INIT, TraceConstant.TRACE_DB_SESSION_INIT_ID)
      return Promise.resolve(this.smsDbSessionHelper);
    }
    hiTraceMeter.finishTrace(TraceConstant.TRACE_DB_SESSION_INIT, TraceConstant.TRACE_DB_SESSION_INIT_ID)
    return undefined;
  }

  public async initSilenceContactDataTable(context: Context): Promise<dataShare.DataShareHelper | undefined> {
    hiTraceMeter.startTrace(TraceConstant.TRACE_CONTACT_DB_INIT_SLIENCE, TraceConstant.TRACE_CONTACT_DB_INIT_SLIENCE_ID)
    if (!context) {
      HiLog.w(DataShareHelper.TAG, 'initSilenceContactDataTable context is empty')
      hiTraceMeter.finishTrace(TraceConstant.TRACE_CONTACT_DB_INIT_SLIENCE,
        TraceConstant.TRACE_CONTACT_DB_INIT_SLIENCE_ID)
      return undefined;
    }
    if (this.contactSlienceDbHelper) {
      HiLog.i(DataShareHelper.TAG, 'initSilenceContactDataTable already init, return.')
      hiTraceMeter.finishTrace(TraceConstant.TRACE_CONTACT_DB_INIT_SLIENCE,
        TraceConstant.TRACE_CONTACT_DB_INIT_SLIENCE_ID)
      return Promise.resolve(this.contactSlienceDbHelper);
    }
    try {
      HiLog.i(DataShareHelper.TAG, 'initSilenceContactDataTable start: ' + common.STR.URI_CONTACT_SILENCE_DATA);
      this.contactSlienceDbHelper = await dataShare.createDataShareHelper(context, common.STR.CONTACT_SILENCE_PROXY,
        { isProxy: Boolean(true) } as dataShare.DataShareHelperOptions);
    } catch (error) {
      HiLog.w(DataShareHelper.TAG, 'initSilenceContactDataTable failed , error msg:' + JSON.stringify(error))
    }
    if (this.contactSlienceDbHelper) {
      HiLog.i(DataShareHelper.TAG, 'initSilenceContactDataTable first init,success.')
      hiTraceMeter.finishTrace(TraceConstant.TRACE_CONTACT_DB_INIT_SLIENCE,
        TraceConstant.TRACE_CONTACT_DB_INIT_SLIENCE_ID)
      return Promise.resolve(this.contactSlienceDbHelper);
    }
    hiTraceMeter.finishTrace(TraceConstant.TRACE_CONTACT_DB_INIT_SLIENCE,
      TraceConstant.TRACE_CONTACT_DB_INIT_SLIENCE_ID)
    return undefined;
  }

  public async initSmsDB(context: Context, waitTime?:  number): Promise<dataShare.DataShareHelper | undefined> {
    hiTraceMeter.startTrace(TraceConstant.TRACE_DB_INIT, TraceConstant.TRACE_DB_INIT_ID)
    if (!context) {
      HiLog.w(DataShareHelper.TAG, 'initSmsDB context is empty')
      hiTraceMeter.finishTrace(TraceConstant.TRACE_DB_INIT, TraceConstant.TRACE_DB_INIT_ID)
      return undefined;
    }
    if (this.smsDbHelper) {
      HiLog.i(DataShareHelper.TAG, 'initSmsDB already init, return.')
      hiTraceMeter.finishTrace(TraceConstant.TRACE_DB_INIT, TraceConstant.TRACE_DB_INIT_ID)
      return Promise.resolve(this.smsDbHelper);
    }
    try {
      HiLog.i(DataShareHelper.TAG, 'initSmsDB start');
      if (waitTime) {
        let option: dataShare.DataShareHelperOptions = {
          waitTime: waitTime,
        }
        HiLog.i(DataShareHelper.TAG, `initSmsDB start ${waitTime}`);
        this.smsDbHelper = await dataShare.createDataShareHelper(context, common.STR.URI_MESSAGE_LOG, option);
      } else {
        this.smsDbHelper = await dataShare.createDataShareHelper(context, common.STR.URI_MESSAGE_LOG);
      }
      SharedPreferencesUtils.saveToPreferences(common.STR.KEY_OF_SMS_DATABASE_INIT_SUCCESS, true);
    } catch (error) {
      HiLog.w(DataShareHelper.TAG, 'initSmsDB failed , error msg:' + JSON.stringify(error))
    }
    if (this.smsDbHelper) {
      HiLog.i(DataShareHelper.TAG, 'initSmsDB first init,success.')
      hiTraceMeter.finishTrace(TraceConstant.TRACE_DB_INIT, TraceConstant.TRACE_DB_INIT_ID)
      return Promise.resolve(this.smsDbHelper);
    }
    hiTraceMeter.finishTrace(TraceConstant.TRACE_DB_INIT, TraceConstant.TRACE_DB_INIT_ID)
    return undefined;
  }

  public async initContactDB(context: Context): Promise<dataShare.DataShareHelper | undefined> {
    hiTraceMeter.startTrace(TraceConstant.TRACE_CONTACT_DB_INIT, TraceConstant.TRACE_CONTACT_DB_INIT_ID)
    if (!context) {
      HiLog.w(DataShareHelper.TAG, 'initContactDB context is empty')
      hiTraceMeter.finishTrace(TraceConstant.TRACE_CONTACT_DB_INIT, TraceConstant.TRACE_CONTACT_DB_INIT_ID)
      return undefined;
    }
    if (this.contactDbHelper) {
      HiLog.i(DataShareHelper.TAG, 'initContactDB already init, return.')
      hiTraceMeter.finishTrace(TraceConstant.TRACE_CONTACT_DB_INIT, TraceConstant.TRACE_CONTACT_DB_INIT_ID)
      return Promise.resolve(this.contactDbHelper);
    }
    try {
      this.contactDbHelper = await dataShare.createDataShareHelper(context, common.STR.URI_ROW_CONTACTS);
    } catch (error) {
      HiLog.w(DataShareHelper.TAG, 'initContactDB failed , error msg:' + JSON.stringify(error))
    }
    if (this.contactDbHelper) {
      HiLog.i(DataShareHelper.TAG, 'initContactDB first init,success.')
      hiTraceMeter.finishTrace(TraceConstant.TRACE_CONTACT_DB_INIT, TraceConstant.TRACE_CONTACT_DB_INIT_ID)
      return Promise.resolve(this.contactDbHelper);
    }
    hiTraceMeter.finishTrace(TraceConstant.TRACE_CONTACT_DB_INIT, TraceConstant.TRACE_CONTACT_DB_INIT_ID)
    return undefined;
  }

  public async initCallLogDB(context: Context): Promise<dataShare.DataShareHelper | undefined> {
    if (!context) {
      HiLog.w(DataShareHelper.TAG, 'initContactDB context is empty')
      return undefined;
    }
    if (this.callLogDbHelper) {
      HiLog.i(DataShareHelper.TAG, 'initContactDB already init, return.')
      return Promise.resolve(this.callLogDbHelper);
    }
    try {
      this.callLogDbHelper = await dataShare.createDataShareHelper(context, common.STR.URI_ROW_CALLLOG);
    } catch (error) {
      HiLog.w(DataShareHelper.TAG, 'initContactDB failed , error msg:' + JSON.stringify(error))
    }
    if (this.callLogDbHelper) {
      HiLog.i(DataShareHelper.TAG, 'initContactDB first init,success.')
      return Promise.resolve(this.callLogDbHelper);
    }
    return undefined;
  }

  public unInitSmsDB(): void {
    this.smsDbHelper = undefined;
    HiLog.i(DataShareHelper.TAG, 'unInitSmsDB success.')
  }

  public unInitContactDB(): void {
    this.contactDbHelper = undefined;
    HiLog.i(DataShareHelper.TAG, 'contactDbHelper success.')
  }

  public unInitCallLogDB(): void {
    this.callLogDbHelper = undefined;
    HiLog.i(DataShareHelper.TAG, 'callLogDbHelper success.')
  }


  public async initYellowPageDB(context: Context): Promise<dataShare.DataShareHelper | undefined> {
    hiTraceMeter.startTrace(TraceConstant.TRACE_YELLOW_PAGE_DB_INIT, TraceConstant.TRACE_YELLOW_PAGE_DB_INIT_ID)
    if (!context) {
      HiLog.w(DataShareHelper.TAG, 'initYellowPageDB context is empty')
      hiTraceMeter.finishTrace(TraceConstant.TRACE_YELLOW_PAGE_DB_INIT, TraceConstant.TRACE_YELLOW_PAGE_DB_INIT_ID)
      return undefined;
    }
    if (this.yellowPageDbHelper) {
      HiLog.i(DataShareHelper.TAG, 'initYellowPageDB already init, return.')
      hiTraceMeter.finishTrace(TraceConstant.TRACE_YELLOW_PAGE_DB_INIT, TraceConstant.TRACE_YELLOW_PAGE_DB_INIT_ID)
      return Promise.resolve(this.yellowPageDbHelper);
    }
    try {
      this.yellowPageDbHelper = await dataShare.createDataShareHelper(context, common.STR.URI_YELLOW_PAGE);
    } catch (error) {
      HiLog.w(DataShareHelper.TAG, 'initYellowPageDB failed , error msg:' + JSON.stringify(error))
    }
    if (this.yellowPageDbHelper) {
      HiLog.i(DataShareHelper.TAG, 'initYellowPageDB first init,success.')
      hiTraceMeter.finishTrace(TraceConstant.TRACE_YELLOW_PAGE_DB_INIT, TraceConstant.TRACE_YELLOW_PAGE_DB_INIT_ID)
      return Promise.resolve(this.yellowPageDbHelper);
    }
    hiTraceMeter.finishTrace(TraceConstant.TRACE_YELLOW_PAGE_DB_INIT, TraceConstant.TRACE_YELLOW_PAGE_DB_INIT_ID)
    return undefined;
  }
}