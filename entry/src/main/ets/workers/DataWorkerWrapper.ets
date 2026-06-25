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
import { ValuesBucket } from '@ohos.data.ValuesBucket';
import LooseObject, { MyAny } from '../data/LooseObject';
import ConversationListResponse from '../model/conversationlist/ConversationListResponse';
import ConversationRcsModel from '../model/ConversationRcsModel';
import NetModel from '../model/NetModel';
import YellowPageModel from '../model/yellowPageModel';
import { LightWeightMap } from '@kit.ArkTS';

const TAG = 'DataWorkerWrapper'

export default class DataWorkerWrapper extends WorkerWrapper {
  private static sInstance: DataWorkerWrapper | null = null;

  private constructor() {
    super()
  }

  static getInstance() {
    if (DataWorkerWrapper.sInstance == null || DataWorkerWrapper.sInstance.mWorker == null) {
      HiLog.i(TAG, 'make DataWorkerWrapper.');
      DataWorkerWrapper.sInstance = new DataWorkerWrapper();
    }
    return DataWorkerWrapper.sInstance;
  }

  getWorkerType(): WorkerType {
    return WorkerType.DataWorker;
  }
}

export class DataWorkerTask extends WorkerTask {
  private static sInstance: DataWorkerTask | null = null;
  private mContactsModel: ContactsModel = new ContactsModel();
  private mConversationModel: ConversationModel = new ConversationModel();
  private mConversationRcsModel: ConversationRcsModel = new ConversationRcsModel();
  private mConversationListModel: ConversationListModel = new ConversationListModel();
  private mNetModel: NetModel = new NetModel();
  private mYellowPageModel: YellowPageModel = new YellowPageModel();

  private constructor(workerPort: ThreadWorkerGlobalScope) {
    super(workerPort);
  }

  static getInstance(workerPort: ThreadWorkerGlobalScope) {
    if (DataWorkerTask.sInstance == null || DataWorkerTask.sInstance.workerPort == null) {
      DataWorkerTask.sInstance = new DataWorkerTask(workerPort);
    }
    return DataWorkerTask.sInstance;
  }

  public runInWorker(request: string, callBack: Function, param?: Record<string, Object>) {
    switch (request) {
      case common.RUN_IN_WORKER_METHOD.queryContactDataByCondition:
        HiLog.i(TAG, 'worker request received: ' + request);
        this.mContactsModel.queryContactDataByCondition((param as Record<string, LooseObject>).actionData,
          (res: Object) => {
            HiLog.i(TAG, `queryContactDataByCondition result: ${JSON.stringify(res).length}`);
            if (callBack) {
              callBack(res);
            }
          }, (param as Record<string, Context>).context);
        break;
      case common.RUN_IN_WORKER_METHOD.queryContactDataSizeByCondition:
        this.mContactsModel.queryContactDataSizeByCondition((param as Record<string, LooseObject>).actionData,
          (res: Object) => {
            HiLog.i(TAG, `queryContactDataSizeByCondition result: ${JSON.stringify(res).length}`);
            if (callBack) {
              callBack(res);
            }
          }, (param as Record<string, Context>).context);
        break;
      case common.RUN_IN_WORKER_METHOD.queryCallLogByCondition:
        this.mContactsModel.queryCallLogByCondition((param as Record<string, LooseObject>).actionData,
          (res: Object) => {
            HiLog.i(TAG, `queryCallLogByCondition result: ${JSON.stringify(res).length}`);
            if (callBack) {
              callBack(res);
            }
          }, (param as Record<string, Context>).context);
        break;
      case common.RUN_IN_WORKER_METHOD.queryContactByCondition:
        HiLog.i(TAG, 'worker request received: ' + request);
        this.mContactsModel.queryContactByCondition((param as Record<string, LooseObject>).actionData,
          (res: Object) => {
            HiLog.i(TAG, `queryContactByCondition result: ${JSON.stringify(res).length}`);
            if (callBack) {
              callBack(res);
            }
          }, (param as Record<string, Context>).context);
        break;
      case common.RUN_IN_WORKER_METHOD.queryRecentContactByRow:
        this.mContactsModel.queryRecentContactByRow((param as Record<string, LooseObject>).actionData,
          (res: Object) => {
            HiLog.i(TAG, `queryContactByRow result back`);
            if (callBack) {
              callBack(res);
            }
          }, (param as Record<string, Context>).context);
        break;
      case common.RUN_IN_WORKER_METHOD.queryContactSizeByCondition:
        this.mContactsModel.queryContactSizeByCondition((param as Record<string, LooseObject>).actionData,
          (res: Object) => {
            HiLog.i(TAG, `queryContactSizeByCondition result: ${JSON.stringify(res).length}`);
            if (callBack) {
              callBack(res);
            }
          }, (param as Record<string, Context>).context);
        break;
      case common.RUN_IN_WORKER_METHOD.queryRawContactSizeByCondition:
        this.mContactsModel.queryRawContactSizeByCondition((param as Record<string, LooseObject>).actionData,
          (res: Object) => {
            HiLog.i(TAG, `queryRawContactSizeByCondition result: ${JSON.stringify(res).length}`);
            if (callBack) {
              callBack(res);
            }
          }, (param as Record<string, Context>).context);
        break;
      case common.RUN_IN_WORKER_METHOD.queryContactViewByCondition:
        this.mContactsModel.queryContactViewByCondition((param as Record<string, LooseObject>).actionData,
          (res: Object) => {
            HiLog.i(TAG, `queryContactViewByCondition result: ${JSON.stringify(res).length}`);
            if (callBack) {
              callBack(res);
            }
          }, (param as Record<string, Context>).context);
        break;
      default:
        this.runInWorkerMore(request, callBack, param);
        break;
    }
  }

  public runInWorkerMore(request: string, callBack: Function, param?: Record<string, Object>) {
    switch (request) {
      case common.RUN_IN_WORKER_METHOD.insertSmsMmsInfo:
        this.mConversationModel.insertSmsMmsInfo((param as Record<string, ValuesBucket>).valueBucket, (res: Object) => {
          HiLog.i(TAG, `insertSmsMmsInfo result: ${JSON.stringify(res).length}`);
          if (callBack) {
            callBack(res);
          }
        }, (param as Record<string, Context>).context);
        break;
      case common.RUN_IN_WORKER_METHOD.insertRcsMmsInfo:
        this.mConversationRcsModel.insertRcsMmsInfo((param as Record<string, ValuesBucket>).valueBucket,
          (res: Object) => {
            HiLog.i(TAG, `insertRcsMmsInfo result: ${JSON.stringify(res).length}`);
            if (callBack) {
              callBack(res);
            }
          }, (param as Record<string, Context>).context);
        break;
      case common.RUN_IN_WORKER_METHOD.deleteSmsMmsInfoByCondition:
        this.mConversationModel.deleteSmsMmsInfoByCondition((param as Record<string, LooseObject>).actionData,
          (res: Object) => {
            HiLog.i(TAG, `deleteSmsMmsInfoByCondition success`);
            if (callBack) {
              callBack(res);
            }
          }, (param as Record<string, Context>).context);
        break;
      case common.RUN_IN_WORKER_METHOD.deleteRcsInfoByCondition:
        this.mConversationRcsModel.deleteRcsInfoByCondition((param as Record<string, LooseObject>).actionData,
          (res: Object) => {
            HiLog.i(TAG, `deleteRcsInfoByCondition result: ${JSON.stringify(res).length}`);
            if (callBack) {
              callBack(res);
            }
          }, (param as Record<string, Context>).context);
        break;
      case common.RUN_IN_WORKER_METHOD.updateRecentUstTime:
        this.mConversationRcsModel.updateRcsInfoIsChatbotResentUseTime(
          (param as Record<string, LooseObject>).actionData,
          (param as Record<string, Context>).context);
        break;
      case common.RUN_IN_WORKER_METHOD.queryChatbotPermissions:
        this.mConversationRcsModel.queryChatbotPermissions(
          (param as Record<string, string>).serviceId,
          (param as Record<string, Context>).context,
          (res: number) => {
            if (callBack) {
              HiLog.i(TAG, `queryChatbotPermissions worker callBack`);
              callBack(res);
            }
          })
        break;
      case common.RUN_IN_WORKER_METHOD.updateChatbotPermissions:
        this.mConversationRcsModel.updateChatbotPermissions(
          (param as Record<string, string>).serviceId,
          (param as Record<string, number>).updateCount,
          (param as Record<string, Context>).context);
        break;
      default:
        this.runInWorkerUpdate(request, callBack, param);
        break;
    }
  }

  private runInWorkerUpdate(request: string, callBack: Function, param?: Record<string, Object>) {
    switch (request) {
      case common.RUN_IN_WORKER_METHOD.updateSmsMmsInfoByCondition:
        this.mConversationModel.updateSmsMmsInfoByCondition((param as Record<string, LooseObject>).actionData,
          (param as Record<string, ValuesBucket>).valueBucket, (res: Object) => {
            HiLog.i(TAG, `updateSmsMmsInfoByCondition result: ${JSON.stringify(res).length}`);
            if (callBack) {
              callBack(res);
            }
          }, (param as Record<string, Context>).context);
        break;
      case common.RUN_IN_WORKER_METHOD.updateRcsMmsInfoByCondition:
        this.mConversationRcsModel.updateRcsMmsInfoByCondition((param as Record<string, LooseObject>).actionData,
          (param as Record<string, ValuesBucket>).valueBucket, (res: Object) => {
            HiLog.i(TAG, `updateRcsMmsInfoByCondition result: ${JSON.stringify(res).length}`);
            if (callBack) {
              callBack(res);
            }
          }, (param as Record<string, Context>).context);
        break;
      case common.RUN_IN_WORKER_METHOD.updateRcsReceivedMmsInfoByRcsId:
        this.mConversationRcsModel.updateRcsReceivedMmsInfoByRcsId((param as Record<string, LooseObject>).actionData,
          (param as Record<string, ValuesBucket>).valueBucket, (res: Object) => {
            HiLog.i(TAG, `updateRcsReceivedMmsInfoByRcsId result: ${JSON.stringify(res).length}`);
            if (callBack) {
              callBack(res);
            }
          }, (param as Record<string, Context>).context);
        break;
      case common.RUN_IN_WORKER_METHOD.updateRcsServiceKindMsgCodeByRcsId:
        this.updateRcsServiceKindMsgCodeByRcsId(callBack, param);
        break;
      case common.RUN_IN_WORKER_METHOD.updateRcsMmsInfoMarkRead:
        this.mConversationRcsModel.updateRcsMmsInfoMarkRead((param as Record<string, LooseObject>).actionData,
          (param as Record<string, ValuesBucket>).valueBucket, (res: Object) => {
            HiLog.i(TAG, `updateRcsMmsInfoMarkRead result: ${JSON.stringify(res).length}`);
            if (callBack) {
              callBack(res);
            }
          }, (param as Record<string, Context>).context);
        break;
      case common.RUN_IN_WORKER_METHOD.querySmsMmsInfoByCondition:
        this.querySmsMmsInfoByCondition(callBack, param)
        break;
      default:
        this.runInWorkerQuery(request, callBack, param);
        break;
    }
  }

  private querySmsMmsInfoByCondition(callBack: Function, param?: Record<string, Object>) {
    this.mConversationModel.querySmsMmsInfoByCondition((param as Record<string, LooseObject>).actionData,
      (res: Object) => {
        HiLog.i(TAG, `querySmsMmsInfoByCondition success.`);
        if (callBack) {
          callBack(res);
        }
      }, (param as Record<string, Context>).context);
  }

  private updateRcsServiceKindMsgCodeByRcsId(callBack: Function, param?: Record<string, Object>) {
    this.mConversationRcsModel.updateRcsServiceKindMsgCodeByRcsId((param as Record<string, LooseObject>).actionData,
      (param as Record<string, ValuesBucket>).valueBucket, (res: Object) => {
        HiLog.i(TAG, `updateRcsServiceKindMsgCodeByRcsId result: ${JSON.stringify(res).length}`);
        if (callBack) {
          callBack(res);
        }
      }, (param as Record<string, Context>).context);
  }

  private runInWorkerQuery(request: string, callBack: Function, param?: Record<string, Object>) {
    switch (request) {
      case common.RUN_IN_WORKER_METHOD.querySmsMmsInfoByConditionAll:
        this.mConversationModel.querySmsMmsInfoByConditionAll((param as Record<string, LooseObject>).actionData,
          (res: Object) => {
            if (callBack) {
              callBack(res);
            }
          }, (param as Record<string, Context>).context);
        break;
      case common.RUN_IN_WORKER_METHOD.queryMmsInfoByFavoriteCondition:
        this.mConversationModel.queryMmsInfoByFavoriteCondition((param as Record<string, LooseObject>).actionData,
          (res: Object) => {
            HiLog.i(TAG, `queryMmsInfoByFavoriteCondition result: ${JSON.stringify(res).length}`);
            if (callBack) {
              callBack(res);
            }
          }, (param as Record<string, Context>).context);
        break;
      case common.RUN_IN_WORKER_METHOD.queryAllInfoByFavoriteCondition:
        this.mConversationModel.queryAllInfoByFavoriteCondition((param as Record<string, LooseObject>).actionData,
          (res: Object) => {
            HiLog.i(TAG, `queryAllInfoByFavoriteCondition result: ${JSON.stringify(res).length}`);
            if (callBack) {
              callBack(res);
            }
          }, (param as Record<string, Context>).context);
        break;
      case common.RUN_IN_WORKER_METHOD.queryRcsInfoByCondition:
        this.mConversationRcsModel.queryRcsInfoByCondition((param as Record<string, LooseObject>).actionData,
          (res: Object) => {
            HiLog.i(TAG, `queryRcsInfoByCondition result: ${JSON.stringify(res).length}`);
            if (callBack) {
              callBack(res);
            }
          }, (param as Record<string, Context>).context);
        break;
      case common.RUN_IN_WORKER_METHOD.querySmsMmsInfoSlotIdByCondition:
        this.querySmsMmsInfoSlotIdByCondition(callBack, param)
        break;
      case common.RUN_IN_WORKER_METHOD.queryMaxGroupIdInMmsInfoTable:
        this.mConversationModel.queryMaxGroupIdInMmsInfoTable((param as Record<string, Context>).context,
          (res: LooseObject) => { callBack && callBack(res); });
        break;
      case common.RUN_IN_WORKER_METHOD.queryFavoriteAllInfoByCondition:
        this.mConversationModel.queryFavoriteAllInfoByCondition((param as Record<string, LooseObject>).actionData,
          (res: Object) => {
            HiLog.i(TAG, `queryFavoriteAllInfoByCondition result: ${JSON.stringify(res).length}`);
            if (callBack) {
              callBack(res);
            }
          }, (param as Record<string, Context>).context);
        break;
      case common.RUN_IN_WORKER_METHOD.queryMmsInfoLastReadCondition:
        this.mConversationModel.queryMmsInfoLastReadMsgCondition((param as Record<string, LooseObject>).actionData,
          (res: Object) => {
            HiLog.i(TAG, `queryMmsInfoLastReadMsgCondition result: ${JSON.stringify(res).length}`);
            if (callBack) {
              callBack(res);
            }
          }, (param as Record<string, Context>).context);
        break;
      default:
        this.runInWorkerRcs(request, callBack, param);
        break;
    }
  }

  private querySmsMmsInfoSlotIdByCondition(callBack: Function, param?: Record<string, Object>) {
    this.mConversationModel.querySmsMmsInfoSlotIdByCondition(
      (param as Record<string, LooseObject>).actionData.phoneNumber, (res: Object) => {
      HiLog.i(TAG, `querySmsMmsInfoSlotIdByCondition result: ${JSON.stringify(res).length}`)
      if (callBack) {
        callBack(res);
      }
    }, (param as Record<string, Context>).context);
  }

  private async runInWorkerRcs(request: string, callBack: Function, param?: Record<string, Object>) {
    switch (request) {
      case common.RUN_IN_WORKER_METHOD.queryRcsInfoSlotIdByCondition:
        this.mConversationRcsModel.queryRcsInfoSlotIdByCondition(
          (param as Record<string, LooseObject>).actionData.phoneNumber, (res: Object) => {
          HiLog.i(TAG, `queryRcsInfoSlotIdByCondition result: ${JSON.stringify(res).length}`)
          if (callBack) {
            callBack(res);
          }
        }, (param as Record<string, Context>).context);
        break;
      case common.RUN_IN_WORKER_METHOD.querySmsMmsInfoSizeByCondition:
        this.mConversationModel.querySmsMmsInfoSizeByCondition(
          (param as Record<string, LooseObject>).actionData, (res: Object) => {
          HiLog.i(TAG, `querySmsMmsInfoSizeByCondition result: ${JSON.stringify(res).length}`);
          if (callBack) {
            callBack(res);
          }
        }, (param as Record<string, Context>).context);
        break;
      case common.RUN_IN_WORKER_METHOD.queryRcsInfoSizeByCondition:
        this.mConversationRcsModel.queryRcsInfoSizeByCondition(
          (param as Record<string, LooseObject>).actionData, (res: Object) => {
          HiLog.i(TAG, `queryRcsInfoSizeByCondition result: ${JSON.stringify(res).length}`);
          if (callBack) {
            callBack(res);
          }
        }, (param as Record<string, Context>).context);
        break;
      case common.RUN_IN_WORKER_METHOD.queryRcsIdByMsgId:
        this.mConversationRcsModel.queryRcsIdByMsgId(
          (param as Record<string, LooseObject>).actionData, (res: Object) => {
          if (callBack) {
            callBack(res);
          }
        }, (param as Record<string, Context>).context);
        break;
      case common.RUN_IN_WORKER_METHOD.queryMaxGroupId:
        this.mConversationModel.queryMaxGroupId((res: Object) => {
          HiLog.i(TAG, `queryMaxGroupId result: ${JSON.stringify(res).length}`);
          if (callBack) {
            callBack(res);
          }
        }, (param as Record<string, Context>).context);
        break;
      case common.RUN_IN_WORKER_METHOD.queryMaxGroupIdRcs:
        this.mConversationRcsModel.queryMaxGroupIdRcs((res: Object) => {
          HiLog.i(TAG, `queryMaxGroupIdRcs result: ${JSON.stringify(res).length}`);
          if (callBack) {
            callBack(res);
          }
        }, (param as Record<string, Context>).context);
        break;
      case common.RUN_IN_WORKER_METHOD.updateSessionAfterRequestChatbot:
        let temp = param as Record<string, MyAny>;
        ConversationListModel.updateSessionAfterRequestChatbot(temp.context as Context, temp.contactName as string,
          temp.serviceId as string).then((res) => {
          if (callBack) {
            callBack(res);
          }
        });
        break;
      default:
        this.runInWorkerMms(request, callBack, param);
        break;
    }
  }

  public runInWorkerMms(request: string, callBack: Function, param?: Record<string, Object>) {
    switch (request) {
      case common.RUN_IN_WORKER_METHOD.statisticalData:
        this.mConversationModel.statisticalData((res: Object) => {
          HiLog.i(TAG, `statisticalData result: ${JSON.stringify(res).length}`);
          if (callBack) {
            callBack(res);
          }
        }, (param as Record<string, Context>).context);
        break;
      case common.RUN_IN_WORKER_METHOD.insertMmsInfo:
        this.mConversationModel.insertMmsInfo((param as Record<string, ValuesBucket>).valueBucket, (res: Object) => {
          HiLog.i(TAG, `insertMmsInfo result: ${JSON.stringify(res).length}`);
          if (callBack) {
            callBack(res);
          }
        }, (param as Record<string, Context>).context);
        break;
      case common.RUN_IN_WORKER_METHOD.queryMmsInfo:
        this.mConversationModel.queryMmsInfo((param as Record<string, LooseObject>).actionData, (res: Object) => {
          HiLog.i(TAG, `queryMmsInfo success`);
          if (callBack) {
            callBack(res);
          }
        }, (param as Record<string, Context>).context);
        break;
      case common.RUN_IN_WORKER_METHOD.queryMmsPartInfo:
        this.mConversationModel.queryMmsPartInfo((param as Record<string, LooseObject>).actionData,
          (res: LightWeightMap<number, string>) => {
          HiLog.i(TAG, `queryMmsPartInfo success`);
          if (callBack) {
            callBack(res);
          }
        }, (param as Record<string, Context>).context);
        break;
      case common.RUN_IN_WORKER_METHOD.updateMmsPartById:
        this.mConversationModel.updateMmsPartById((param as Record<string, LooseObject>).actionData, (res: Object) => {
          HiLog.i(TAG, `updateMmsPartById success`);
          if (callBack) {
            callBack(res);
          }
        }, (param as Record<string, Context>).context);
        break;
      case common.RUN_IN_WORKER_METHOD.deleteMmsInfoByCondition:
        this.mConversationModel.deleteMmsInfoByCondition((param as Record<string, LooseObject>).actionData,
          (res: Object) => {
            HiLog.i(TAG, `deleteMmsInfoByCondition success`);
            if (callBack) {
              callBack(res);
            }
          }, (param as Record<string, Context>).context);
        break;
      case common.RUN_IN_WORKER_METHOD.queryNetInfo:
        this.mNetModel.queryNetInfo((param as Record<string, LooseObject>).actionData, (res: Object) => {
          HiLog.i(TAG, `queryNetInfo result: ${JSON.stringify(res).length}`);
          if (callBack) {
            callBack(res);
          }
        }, (param as Record<string, Context>).context);
        break;
      case common.RUN_IN_WORKER_METHOD.queryMmsNotDownloadInfo:
        this.runInWorkerMmsNotDownloadInfo(callBack, param);
        break;
      default:
        this.runInWorkerMoreMore(request, callBack, param);
        break;
    }
  }

  private runInWorkerMmsNotDownloadInfo(callBack: Function, param?: Record<string, Object>) {
    this.mConversationModel.queryMmsNotDownloadInfo((param as Record<string, LooseObject>).actionData,
      (res: Object) => {
        HiLog.i(TAG, `queryMmsNotDownloadInfo result: ${JSON.stringify(res).length}`);
        if (callBack) {
          callBack(res);
        }
      }, (param as Record<string, Context>).context);
  }

  public runInWorkerMoreMore(request: string, callBack: Function, param?: Record<string, Object>) {
    switch (request) {
      case common.RUN_IN_WORKER_METHOD.insertSession:
        this.mConversationListModel.insertSession((param as Record<string, ValuesBucket>).valueBucket,
          (res: Object) => {
            HiLog.i(TAG, `insertSession result: ${JSON.stringify(res).length}`);
            if (callBack) {
              callBack(res);
            }
          }, (param as Record<string, Context>).context);
        break;
      case common.RUN_IN_WORKER_METHOD.deleteSessionByCondition:
        this.mConversationListModel.deleteSessionByCondition((param as Record<string, LooseObject>).actionData,
          (res: Object) => {
            HiLog.i(TAG, `deleteSessionByCondition result: ${JSON.stringify(res).length}`);
            if (callBack) {
              callBack(res);
            }
          }, (param as Record<string, Context>).context);
        break;
      case common.RUN_IN_WORKER_METHOD.deleteSessionSlice:
        this.mConversationListModel.deleteSessionSlice((param as Record<string, LooseObject>).actionData,
          (res: Object) => {
            if (callBack) {
              callBack(res);
            }
          }, (param as Record<string, Context>).context);
        break;
      case common.RUN_IN_WORKER_METHOD.queryMmsPartPathBySessionIds:
        this.mConversationListModel.queryMmsPartPathBySessionIds((param as Record<string, LooseObject>).actionData,
          (res: Object) => {
            if (callBack) {
              callBack(res);
            }
          }, (param as Record<string, Context>).context);
        break;
      case common.RUN_IN_WORKER_METHOD.updateSessionByCondition:
        this.mConversationListModel.updateSessionByCondition((param as Record<string, LooseObject>).actionData,
          (param as Record<string, ValuesBucket>).valueBucket, (res: Object) => {
            HiLog.i(TAG, `updateSessionByCondition result: ${JSON.stringify(res).length}`);
            if (callBack) {
              callBack(res);
            }
          }, (param as Record<string, Context>).context);
        break;
      case common.RUN_IN_WORKER_METHOD.querySessionByCondition:
        this.mConversationListModel.querySessionByCondition((param as Record<string, LooseObject>).actionData,
          (res: ConversationListResponse) => {
            HiLog.i(TAG, `querySessionByCondition result: ${JSON.stringify(res).length}`);
            if (callBack) {
              callBack(res);
            }
          }, (param as Record<string, Context>).context);
        break;
      case common.RUN_IN_WORKER_METHOD.queryMatchedRecipient:
        this.mConversationListModel.queryMatchedRecipient((param as Record<string, LooseObject>).actionData,
          (res: ConversationListResponse) => {
            HiLog.i(TAG, `queryMatchedRecipient result: ${JSON.stringify(res).length}`);
            if (callBack) {
              callBack(res);
            }
          }, (param as Record<string, Context>).context);
        break;
      default:
        this.runInWorkerMorePart1(request, callBack, param);
        break;
    }
  }

  public runInWorkerMorePart1(request: string, callBack: Function, param?: Record<string, Object>) {
    switch (request) {
      case common.RUN_IN_WORKER_METHOD.markAsReadFromReceive:
        this.mConversationListModel.markAsReadFromReceive((param as Record<string, LooseObject>).actionData,
          (res: Object) => {
            if (callBack) {
              callBack(res);
            }
          }, (param as Record<string, Context>).context);
        break;
      case common.RUN_IN_WORKER_METHOD.markAsReadFromReceiveRcs:
        this.mConversationRcsModel.markAsReadFromReceiveRcs((param as Record<string, LooseObject>).actionData,
          (res: Object) => {
            HiLog.i(TAG, `markAsReadFromReceiveRcs result: ${JSON.stringify(res)}`);
            if (callBack) {
              callBack(res);
            }
          }, (param as Record<string, Context>).context);
        break;
      case common.RUN_IN_WORKER_METHOD.querySessionResultByCondition:
        this.mConversationListModel.querySessionResultByCondition((param as Record<string, LooseObject>).actionData,
          (res: Object) => {
            HiLog.i(TAG, `querySessionResultByCondition done.`);// 不要打印长度，性能比较差，300条消息要8ms。
            if (callBack) {
              callBack(res);
            }
          }, (param as Record<string, Context>).context);
        break;
      case common.RUN_IN_WORKER_METHOD.querySessionSizeByCondition:
        this.mConversationListModel.querySessionSizeByCondition((param as Record<string, LooseObject>).actionData,
          (res: Object) => {
            HiLog.i(TAG, `querySessionSizeByCondition result: ${JSON.stringify(res).length}`);
            if (callBack) {
              callBack(res);
            }
          }, (param as Record<string, Context>).context);
        break;
      case common.RUN_IN_WORKER_METHOD.fetchRecentContactsAndBatchUpdateSession:
        this.fetchRecentContactsAndBatchUpdateSession(callBack, param)
        break;
      default:
        this.runInWorkerYellowPage(request, callBack, param);
        break;
    }
  }

  private fetchRecentContactsAndBatchUpdateSession(callBack: Function, param?: Record<string, Object>) {
    this.mConversationListModel.fetchRecentContactsAndBatchUpdateSession(
      (param as Record<string, Context>).context,
      (param as Record<string, Record<string, string>>).actionData.startUpdateTime,
      (param as Record<string, Record<string, string>>).actionData.endUpdateTime, (results: Object) => {
      HiLog.i(TAG, `fetchRecentContactsAndBatchUpdateSession results Len: ${(results as number[]).length}`);
      if (callBack != null) {
        callBack(results);
      }
    });
  }

  private runInWorkerYellowPage(request: string, callBack: Function, param?: Record<string, Object>) {
    HiLog.i(TAG, `runInWorkerNewPage`);
    switch (request) {
      case common.RUN_IN_WORKER_METHOD.queryYellowPageInfoByCondition:
        this.mYellowPageModel.queryYellowPageInfoByCondition((param as Record<string, LooseObject>).actionData,
          (param as Record<string, Context>).context).then((res: Object) => {
          this.callBackDetails(res, 'queryYellowPageInfoByCondition', callBack);
        });
        break;
      case common.RUN_IN_WORKER_METHOD.fetchDeleteContactsAndUpdateSession:
        this.mConversationListModel.fetchDeleteContactsAndUpdateSession(
          (param as Record<string, Context>).context,
          (param as Record<string, Record<string, string[]>>).actionData.rawContactIds, (results: Object) => {
          HiLog.i(TAG, `fetchDeleteContactsAndUpdateSession results Len: ${(results as number[]).length}`);
          if (callBack != null) {
            callBack(results);
          }
        });
        break;
      case common.RUN_IN_WORKER_METHOD.queryYellowPageListInfoByCondition:
        this.mYellowPageModel.queryYellowPageListInfoByCondition((param as Record<string, LooseObject>).actionData,
          (res: Object) => {
            HiLog.i(TAG, `queryYellowPageListInfoByCondition result: ${JSON.stringify(res).length}`);
            if (callBack) {
              callBack(res);
            }
          }, (param as Record<string, Context>).context);
        break;
      default:
        this.runInWorkerMorePart2(request, callBack, param);
        break;
    }
  }

  private runInWorkerMorePart2(request: string, callBack: Function, param?: Record<string, Object>) {
    HiLog.i(TAG, `runInWorkerMorePart2`);
    switch (request) {
      case common.RUN_IN_WORKER_METHOD.selectInfoCount:
        this.mConversationModel.selectInfoCount((res:Object) => {
          HiLog.i(TAG, `selectInfoCount result: ${JSON.stringify(res).length}`);
          if (callBack) {
            callBack(res);
          }
        }, (param as Record<string, Context>).context);
        break;
      case common.RUN_IN_WORKER_METHOD.selectContactId:
        this.mConversationModel.selectContactId((res: Object) => {
          HiLog.i(TAG, `selectContactId result: ${JSON.stringify(res).length}`);
          if (callBack) {
            callBack(res);
          }
        }, (param as Record<string, Context>).context);
        break;
      default:
        this.runInWorkerMorePart3(request, callBack, param);
        break;
    }
  }

  private runInWorkerMorePart3(request: string, callBack: Function, param?: Record<string, Object>) {
    HiLog.i(TAG, `runInWorkerMorePart3`);
    switch (request) {
      case common.RUN_IN_WORKER_METHOD.updateSessionUnReadBySessionId:
        this.mConversationListModel.updateSessionUnReadBySessionId((param as Record<string, LooseObject>).actionData,
          (param as Record<string, ValuesBucket>).valueBucket,
          callBack, (param as Record<string, Context>).context);
        break;
      case common.RUN_IN_WORKER_METHOD.processMarkRead:
        this.mConversationListModel.processMarkRead((param as Record<string, LooseObject>).actionData,
          (param as Record<string, Context>).context, callBack);
        break;
      case common.RUN_IN_WORKER_METHOD.updateSmsIsReadBySessionId:
        this.mConversationModel.updateSmsIsReadBySessionId((param as Record<string, LooseObject>).actionData,
          (param as Record<string, Context>).context, callBack);
        break;
      case common.RUN_IN_WORKER_METHOD.updateRcsIsReadBySessionId:
        this.mConversationRcsModel.updateRcsIsReadBySessionId((param as Record<string, LooseObject>).actionData,
          callBack, (param as Record<string, Context>).context);
        break;
      case common.RUN_IN_WORKER_METHOD.batchUpdateSessionByCondition:
        this.mConversationListModel.batchUpdateSessionByCondition((param as Record<string, Context>).context,
          (param as Record<string, LooseObject>).actionData.conditions,
          (param as Record<string, LooseObject>).actionData.valueBuckets,
          callBack);
        break;
      case common.RUN_IN_WORKER_METHOD.updateSmsInfoSmsTypeBySessionIds:
        this.mConversationModel.updateSmsInfoSmsTypeBySessionIds((param as Record<string, LooseObject>).actionData,
          callBack, (param as Record<string, Context>).context);
        break;
      case common.RUN_IN_WORKER_METHOD.updateRcsInfoIsSenderBySessionIds:
        this.mConversationRcsModel.updateRcsInfoIsSenderBySessionIds((param as Record<string, LooseObject>).actionData,
          callBack, (param as Record<string, Context>).context);
        break;
      case common.RUN_IN_WORKER_METHOD.querySessionId:
        this.mConversationModel.querySessionId((param as Record<string, LooseObject>).actionData, callBack,
          (param as Record<string, Context>).context);
        break;
      case common.RUN_IN_WORKER_METHOD.updateAttachmentByCondition:
        this.mConversationListModel.updateAttachmentByCondition((param as Record<string, LooseObject>).actionData,
          (param as Record<string, ValuesBucket>).valueBucket,
          (param as Record<string, Context>).context);
        break;
      case common.RUN_IN_WORKER_METHOD.updateSessionPinningTimeBySessionId:
        this.mConversationListModel.updateSessionByPinningTime((param as Record<string, LooseObject>).actionData,
          (param as Record<string, ValuesBucket>).valueBucket, callBack, (param as Record<string, Context>).context);
        break;
      case common.RUN_IN_WORKER_METHOD.updateSessionBySessionId:
        this.mConversationListModel.updateSessionContent((param as Record<string, LooseObject>).actionData,
          (param as Record<string, ValuesBucket>).valueBucket, callBack, (param as Record<string, Context>).context);
      default:
        HiLog.w(TAG, `not allow!!!`);
        break;
    }
  }

  private callBackDetails(res: Object, content: string, callBack: Function) {
    HiLog.i(TAG, content);
    if (callBack) {
      callBack(res);
    }
  }
}