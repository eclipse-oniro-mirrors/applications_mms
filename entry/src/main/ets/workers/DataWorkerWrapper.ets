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

import { ThreadWorkerGlobalScope } from '@ohos.worker';

import { WorkerType } from './WorkFactory';
import WorkerWrapper from './base/WorkerWrapper';
import WorkerTask from './base/WorkerTask';
import common from '../data/commonData';
import ContactsModel from '../model/ContactsModel';
import ConversationModel from '../model/ConversationModel';
import ConversationListModel from '../model/ConversationListModel';
import HiLog from '../utils/HiLog';

const TAG = "DataWorkerWrapper"

export default class DataWorkerWrapper extends WorkerWrapper {
  private static sInstance: DataWorkerWrapper = null;

  private constructor() {
    super()
  }

  static getInstance() {
    HiLog.i(TAG, "getInstance in.");
    if (DataWorkerWrapper.sInstance == null || DataWorkerWrapper.sInstance.mWorker == null) {
      HiLog.i(TAG, "make DataWorkerWrapper.");
      DataWorkerWrapper.sInstance = new DataWorkerWrapper();
    }
    return DataWorkerWrapper.sInstance;
  }

  getWorkerType(): WorkerType {
    return WorkerType.DataWorker;
  }
}

export class DataWorkerTask extends WorkerTask {
  private static sInstance: DataWorkerTask = null;

  private mContactsModel: ContactsModel = new ContactsModel();

  private mConversationModel: ConversationModel = new ConversationModel();

  private mConversationListModel: ConversationListModel = new ConversationListModel();

  private constructor(workerPort: ThreadWorkerGlobalScope) {
    super(workerPort);
  }

  static getInstance(workerPort: ThreadWorkerGlobalScope) {
    HiLog.i(TAG, "getInstance in.");
    if (DataWorkerTask.sInstance == null || DataWorkerTask.sInstance.workerPort == null) {
      DataWorkerTask.sInstance = new DataWorkerTask(workerPort);
    }
    return DataWorkerTask.sInstance;
  }

  public runInWorker(request: string, callBack: (v?: any) => void, param?: any) {
    HiLog.i(TAG, `runInWorker ${request}`);
    switch (request) {
      case common.RUN_IN_WORKER_METHOD.queryContactDataByCondition:
        this.mContactsModel.queryContactDataByCondition(param.actionData, res => {
          HiLog.i(TAG, `queryContactDataByCondition result: ${JSON.stringify(res).length}`);
          if (callBack) {
            callBack(res);
          }
        }, param.context);
        break;
      case common.RUN_IN_WORKER_METHOD.queryContactDataSizeByCondition:
        this.mContactsModel.queryContactDataSizeByCondition(param.actionData, res => {
          HiLog.i(TAG, `queryContactDataSizeByCondition result: ${JSON.stringify(res).length}`);
          if (callBack) {
            callBack(res);
          }
        }, param.context);
        break;
      case common.RUN_IN_WORKER_METHOD.queryContactByCondition:
        this.mContactsModel.queryContactByCondition(param.actionData, res => {
          HiLog.i(TAG, `queryContactByCondition result: ${JSON.stringify(res).length}`);
          if (callBack) {
            callBack(res);
          }
        }, param.context);
        break;
      case common.RUN_IN_WORKER_METHOD.queryContactSizeByCondition:
        this.mContactsModel.queryContactSizeByCondition(param.actionData, res => {
          HiLog.i(TAG, `queryContactSizeByCondition result: ${JSON.stringify(res).length}`);
          if (callBack) {
            callBack(res);
          }
        }, param.context);
        break;
      case common.RUN_IN_WORKER_METHOD.queryRawContactSizeByCondition:
        this.mContactsModel.queryRawContactSizeByCondition(param.actionData, res => {
          HiLog.i(TAG, `queryRawContactSizeByCondition result: ${JSON.stringify(res).length}`);
          if (callBack) {
            callBack(res);
          }
        }, param.context);
        break;
      case common.RUN_IN_WORKER_METHOD.queryContactViewByCondition:
        this.mContactsModel.queryContactViewByCondition(param.actionData, res => {
          HiLog.i(TAG, `queryContactViewByCondition result: ${JSON.stringify(res).length}`);
          if (callBack) {
            callBack(res);
          }
        }, param.context);
        break;
      default:
        this.runInWorkerMore(request, callBack, param);
        break;
    }
  }

  public runInWorkerMore(request: string, callBack: (v?: any) => void, param?: any) {
    HiLog.i(TAG, `runInWorkerMore ${request}`);
    switch (request) {
      case common.RUN_IN_WORKER_METHOD.insertSmsMmsInfo:
        this.mConversationModel.insertSmsMmsInfo(param.valueBucket, res => {
          HiLog.i(TAG, `insertSmsMmsInfo result: ${JSON.stringify(res).length}`);
          if (callBack) {
            callBack(res);
          }
        }, param.context);
        break;
      case common.RUN_IN_WORKER_METHOD.deleteSmsMmsInfoByCondition:
        this.mConversationModel.deleteSmsMmsInfoByCondition(param.actionData, res => {
          HiLog.i(TAG, `deleteSmsMmsInfoByCondition result: ${JSON.stringify(res).length}`);
          if (callBack) {
            callBack(res);
          }
        }, param.context);
        break;
      case common.RUN_IN_WORKER_METHOD.updateSmsMmsInfoByCondition:
        this.mConversationModel.updateSmsMmsInfoByCondition(param.actionData, param.valueBucket, res => {
          HiLog.i(TAG, `updateSmsMmsInfoByCondition result: ${JSON.stringify(res).length}`);
          if (callBack) {
            callBack(res);
          }
        }, param.context);
        break;
      case common.RUN_IN_WORKER_METHOD.querySmsMmsInfoByCondition:
        this.mConversationModel.querySmsMmsInfoByCondition(param.actionData, res => {
          HiLog.i(TAG, `querySmsMmsInfoByCondition result: ${JSON.stringify(res).length}`);
          if (callBack) {
            callBack(res);
          }
        }, param.context);
        break;
      case common.RUN_IN_WORKER_METHOD.querySmsMmsInfoSizeByCondition:
        this.mConversationModel.querySmsMmsInfoSizeByCondition(param.actionData, res => {
          HiLog.i(TAG, `querySmsMmsInfoSizeByCondition result: ${JSON.stringify(res).length}`);
          if (callBack) {
            callBack(res);
          }
        }, param.context);
        break;
      case common.RUN_IN_WORKER_METHOD.queryMaxGroupId:
        this.mConversationModel.queryMaxGroupId(res => {
          HiLog.i(TAG, `queryMaxGroupId result: ${JSON.stringify(res).length}`);
          if (callBack) {
            callBack(res);
          }
        }, param.context);
        break;
      case common.RUN_IN_WORKER_METHOD.statisticalData:
        this.mConversationModel.statisticalData(res => {
          HiLog.i(TAG, `statisticalData result: ${JSON.stringify(res).length}`);
          if (callBack) {
            callBack(res);
          }
        }, param.context);
        break;
      default:
        this.runInWorkerMoreMore(request, callBack, param);
        break;
    }
  }

  public runInWorkerMoreMore(request: string, callBack: (v?: any) => void, param?: any) {
    HiLog.i(TAG, `runInWorkerMoreMore ${request}`);
    switch (request) {
      case common.RUN_IN_WORKER_METHOD.insertSession:
        this.mConversationListModel.insertSession(param.valueBucket, res => {
          HiLog.i(TAG, `insertSession result: ${JSON.stringify(res).length}`);
          if (callBack) {
            callBack(res);
          }
        }, param.context);
        break;
      case common.RUN_IN_WORKER_METHOD.deleteSessionByCondition:
        this.mConversationListModel.deleteSessionByCondition(param.actionData, res => {
          HiLog.i(TAG, `deleteSessionByCondition result: ${JSON.stringify(res).length}`);
          if (callBack) {
            callBack(res);
          }
        }, param.context);
        break;
      case common.RUN_IN_WORKER_METHOD.updateSessionByCondition:
        this.mConversationListModel.updateSessionByCondition(param.actionData, param.valueBucket, res => {
          HiLog.i(TAG, `updateSessionByCondition result: ${JSON.stringify(res).length}`);
          if (callBack) {
            callBack(res);
          }
        }, param.context);
        break;
      case common.RUN_IN_WORKER_METHOD.querySessionByCondition:
        this.mConversationListModel.querySessionByCondition(param.actionData, res => {
          HiLog.i(TAG, `querySessionByCondition result: ${JSON.stringify(res).length}`);
          if (callBack) {
            callBack(res);
          }
        }, param.context);
        break;
      case common.RUN_IN_WORKER_METHOD.querySessionSizeByCondition:
        this.mConversationListModel.querySessionSizeByCondition(param.actionData, res => {
          HiLog.i(TAG, `querySessionSizeByCondition result: ${JSON.stringify(res).length}`);
          if (callBack) {
            callBack(res);
          }
        }, param.context);
        break;
      default:
        HiLog.w(TAG, `${request} not allow!!!`);
        break;
    }
  }
}