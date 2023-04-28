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

import { WorkerType } from "./WorkFactory"
import WorkerWrapper from "./base/WorkerWrapper"
import WorkerTask from "./base/WorkerTask"
import { ThreadWorkerGlobalScope } from '@ohos.worker';
import ContactsModel from '../model/ContactsModel';
import ConversationModel from '../model/ConversationModel';
import HiLog from '../utils/HiLog';

const TAG = "DataWorkerWrapper"

export default class DataWorkerWrapper extends WorkerWrapper {
  private static sInstance: DataWorkerWrapper = undefined;

  private constructor() {
    super()
  }

  static getInstance() {
    HiLog.i(TAG, "getInstance in.");
    if (DataWorkerWrapper.sInstance == undefined || DataWorkerWrapper.sInstance.mWorker == undefined) {
      HiLog.i(TAG, "make DataWorkerWrapper.");
      DataWorkerWrapper.sInstance = new DataWorkerWrapper();
    }
    return DataWorkerWrapper.sInstance;
  }

  getWorkerType(): WorkerType {
    return WorkerType.DataWorker;
  }
}

export enum DataWorkerConstant {
  "searchContracts",
  "queryContact",
  "queryContactDataByIds",
  "countContact",
  "queryContactDataByTelephone",
  "queryProfile",
  "queryMessageDetail",
  "queryMmsPart",
  "queryMaxGroupId",
  "insertMessageDetail",
  "batchInsertMmsPart",
  "queryGroupIdBySessionId",
  "deleteMessageBySessionIds",
  "deleteMmsPartByGroupIds",
  "deleteMessageByGroupIds",
  "deleteMessageBySessionIdsAndLock",
  "markAllAsRead",
  "markAllToRead",
  "updateById",
  "updateLock",
  "updateCollect"
}

export class DataWorkerTask extends WorkerTask {
  private static sInstance: DataWorkerTask = undefined;

  private mContactsModel: ContactsModel = new ContactsModel();

  private mConversationModel: ConversationModel = new ConversationModel();

  private constructor(workerPort: ThreadWorkerGlobalScope) {
    super(workerPort);
  }

  static getInstance(workerPort: ThreadWorkerGlobalScope) {
    HiLog.i(TAG, "getInstance in.");
    if (DataWorkerTask.sInstance == undefined || DataWorkerTask.sInstance.workerPort == undefined) {
      DataWorkerTask.sInstance = new DataWorkerTask(workerPort);
    }
    return DataWorkerTask.sInstance;
  }

  runInWorker(request: string, callBack: (v?: any) => void, param?: any) {
    HiLog.i(TAG, `runInWorker ${request}`);
    switch (request) {
      case DataWorkerConstant[DataWorkerConstant.searchContracts]:
        this.mContactsModel.searchContracts(param.actionData, (data) => {
          HiLog.i(TAG, `searchContracts result: ${JSON.stringify(data).length}`);
          callBack(data);
        });
        break;
      case DataWorkerConstant[DataWorkerConstant.queryContact]:
        this.mContactsModel.queryContact(param.actionData, (data) => {
          HiLog.i(TAG, `queryContact result: ${JSON.stringify(data).length}`);
          callBack(data);
        });
        break;
      case DataWorkerConstant[DataWorkerConstant.queryContactDataByIds]:
        this.mContactsModel.queryContactDataByIds(param.actionData, (data) => {
          HiLog.i(TAG, `queryContactDataByIds result: ${JSON.stringify(data).length}`);
          callBack(data);
        });
        break;
      case DataWorkerConstant[DataWorkerConstant.countContact]:
        this.mContactsModel.countContact(param.actionData, (data) => {
          HiLog.i(TAG, `countContact result: ${JSON.stringify(data).length}`);
          callBack(data);
        });
        break;
      case DataWorkerConstant[DataWorkerConstant.queryContactDataByTelephone]:
        this.mContactsModel.queryContactDataByTelephone(param.actionData, (data) => {
          HiLog.i(TAG, `queryContactDataByTelephone result: ${JSON.stringify(data).length}`);
          callBack(data);
        });
        break;
      case DataWorkerConstant[DataWorkerConstant.queryProfile]:
        this.mContactsModel.queryProfile(param.actionData, (data) => {
          HiLog.i(TAG, `queryProfile result: ${JSON.stringify(data).length}`);
          callBack(data);
        });
        break;
      case DataWorkerConstant[DataWorkerConstant.queryMessageDetail]:
        this.mConversationModel.queryMessageDetail(param.actionData, (data) => {
          HiLog.i(TAG, `queryMessageDetail result: ${JSON.stringify(data).length}`);
          callBack(data);
        });
        break;
      case DataWorkerConstant[DataWorkerConstant.queryMmsPart]:
        this.mConversationModel.queryMmsPart(param.actionData, (data) => {
          HiLog.i(TAG, `queryMmsPart result: ${JSON.stringify(data).length}`);
          callBack(data);
        });
        break;
      case DataWorkerConstant[DataWorkerConstant.queryMaxGroupId]:
        this.mConversationModel.queryMaxGroupId(param.actionData, (data) => {
          HiLog.i(TAG, `queryMaxGroupId result: ${JSON.stringify(data).length}`);
          callBack(data);
        });
        break;
      case DataWorkerConstant[DataWorkerConstant.insertMessageDetail]:
        this.mConversationModel.insertMessageDetail(param.actionData, (data) => {
          HiLog.i(TAG, `insertMessageDetail result: ${JSON.stringify(data).length}`);
          callBack(data);
        });
        break;
      case DataWorkerConstant[DataWorkerConstant.batchInsertMmsPart]:
        this.mConversationModel.batchInsertMmsPart(param.actionData, (data) => {
          HiLog.i(TAG, `batchInsertMmsPart result: ${JSON.stringify(data).length}`);
          callBack(data);
        });
        break;
      case DataWorkerConstant[DataWorkerConstant.queryGroupIdBySessionId]:
        this.mConversationModel.queryGroupIdBySessionId(param.actionData, (data) => {
          HiLog.i(TAG, `queryGroupIdBySessionId result: ${JSON.stringify(data).length}`);
          callBack(data);
        });
        break;
      case DataWorkerConstant[DataWorkerConstant.deleteMessageBySessionIds]:
//        this.mConversationModel.deleteMessageBySessionIds(param.actionData, (data) => {
//          HiLog.i(TAG, `deleteMessageBySessionIds result: ${JSON.stringify(data).length}`);
//          callBack(data);
//        });
        break;
      case DataWorkerConstant[DataWorkerConstant.deleteMmsPartByGroupIds]:
//        this.mConversationModel.deleteMmsPartByGroupIds(param.actionData, (data) => {
//          HiLog.i(TAG, `deleteMmsPartByGroupIds result: ${JSON.stringify(data).length}`);
//          callBack(data);
//        });
        break;
      case DataWorkerConstant[DataWorkerConstant.deleteMessageByGroupIds]:
//        this.mConversationModel.deleteMessageByGroupIds(param.actionData, (data) => {
//          HiLog.i(TAG, `deleteMessageByGroupIds result: ${JSON.stringify(data).length}`);
//          callBack(data);
//        });
        break;
      case DataWorkerConstant[DataWorkerConstant.deleteMessageBySessionIdsAndLock]:
//        this.mConversationModel.deleteMessageBySessionIdsAndLock(param.actionData, (data) => {
//          HiLog.i(TAG, `deleteMessageBySessionIdsAndLock result: ${JSON.stringify(data).length}`);
//          callBack(data);
//        });
        break;
      case DataWorkerConstant[DataWorkerConstant.markAllAsRead]:
//        this.mConversationModel.markAllAsRead(param.actionData, (data) => {
//          HiLog.i(TAG, `markAllAsRead result: ${JSON.stringify(data).length}`);
//          callBack(data);
//        });
        break;
      case DataWorkerConstant[DataWorkerConstant.markAllToRead]:
//        this.mConversationModel.markAllToRead(param.actionData, (data) => {
//          HiLog.i(TAG, `markAllToRead result: ${JSON.stringify(data).length}`);
//          callBack(data);
//        });
        break;
      case DataWorkerConstant[DataWorkerConstant.updateById]:
        this.mConversationModel.updateById(param.actionData, (data) => {
          HiLog.i(TAG, `updateById result: ${JSON.stringify(data).length}`);
          callBack(data);
        });
        break;
      case DataWorkerConstant[DataWorkerConstant.updateLock]:
        this.mConversationModel.updateLock(param.actionData, (data) => {
          HiLog.i(TAG, `updateLock result: ${JSON.stringify(data).length}`);
          callBack(data);
        });
        break;
      case DataWorkerConstant[DataWorkerConstant.updateCollect]:
        this.mConversationModel.updateCollect(param.actionData, (data) => {
          HiLog.i(TAG, `updateCollect result: ${JSON.stringify(data).length}`);
          callBack(data);
        });
        break;
      default:
        HiLog.w(TAG, `${request} not allow!!!`)
        break;
    }
  }
}