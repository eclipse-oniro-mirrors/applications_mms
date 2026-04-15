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

import common from '../data/commonData';
import HiLog from '../utils//HiLog';
import ConversationListService, { ResObj } from './ConversationListService';
import LooseObject from '../data/LooseObject';
import { GlobalContext } from '../MainAbility/GlobalHelper';
import { WorkerWrapper } from '../workers/base/WorkerWrapper';
import myCommon from '@ohos.app.ability.common'
import { ValuesBucket } from '@ohos.data.ValuesBucket';
import ConversationRcsModel from '../model/ConversationRcsModel';
import dataSharePredicates from '@ohos.data.dataSharePredicates';
import DataShareResultSet from '@ohos.data.DataShareResultSet';
import { resType } from './MmsSearchService';

interface ConversationServiceParamType {
  valueBucket: ValuesBucket,
  context: Context
  actionData: LooseObject
}

export interface GlobalThisType {
  actionData?: LooseObject,
  valueBucket?: ValuesBucket,
  context: Context
}

const TAG: string = 'ConversationRcsService';

export default class ConversationRcsService {
  private static instance: ConversationRcsService;
  public conversationRcsModel: ConversationRcsModel = new ConversationRcsModel();

  private constructor() {
  }

  public static getInstance(): ConversationRcsService {
    if (ConversationRcsService.instance == null) {
      ConversationRcsService.instance = new ConversationRcsService();
    }
    return ConversationRcsService.instance;
  }

  public static getTestInstance(): ConversationRcsService {
    return new ConversationRcsService();
  }

  public insertRcsMmsInfo(valueBucket: ValuesBucket, callback: Function, context: Context): void {
    HiLog.i(TAG, `insertSmsMmsInfo DataWorker != null: `)
    if (GlobalContext.getContext().getObject('DataWorker') != null) {
      (GlobalContext.getContext()
        .getObject('DataWorker') as WorkerWrapper).sendRequest(common.RUN_IN_WORKER_METHOD.insertRcsMmsInfo, {
        valueBucket: valueBucket,
        context: context
      } as ConversationServiceParamType, (res?: Object) => {
        if (callback) {
          callback(res);
        }
      });
    } else {
      this.conversationRcsModel.insertRcsMmsInfo(valueBucket, callback, context);
    }
  }

  public queryRcsMmsInfoByMsgId(msgId: string, context: Context, isSend: boolean): void {
      let valueBucket: Record<string, number> = {
        'msg_state': 0
      };
      this.conversationRcsModel.updateRcsReceivedMmsInfoByCondition(msgId, valueBucket, context, false, isSend)

  }

  public updateRcsInfoByMsgId(msgId: string, context: Context, valueBucket: ValuesBucket,
    cancelValue?: boolean): void {
    this.conversationRcsModel.updateRcsReceivedMmsInfoByCondition(msgId, valueBucket, context, cancelValue);
  }

  public updateRcsInfoByMsgIdOfProgressBroadcast(msgId: string, context: Context, clurSize: number,
                                                 totalSize: number): void {
    let valueBucket: Record<string, number> = {
      'clur_size': clurSize,
      'total_size': totalSize,
    };
    this.conversationRcsModel.updateRcsReceivedMmsInfoByCondition(msgId, valueBucket, context)
  }

  public queryRcsMmsInfoByMsgIdSendFail(msgId: string, context: Context): void {
    let valueBucket: Record<string, number> = {
      'msg_state': 2
    };
    this.conversationRcsModel.updateRcsReceivedMmsInfoByCondition(msgId, valueBucket, context)
  }

  /**
   * 失败更新session
   * @param msgId
   * @param context
   * @returns
   */
  public async querySessionByMsgIdSendFail(msgId: string, context: Context): Promise<void> {
    HiLog.i(TAG, 'querySessionByMsgIdSendFail start');
    let queryCondition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    queryCondition.equalTo('msg_id', msgId);
    let resultSet: DataShareResultSet | void =
      await ConversationRcsModel.queryInRcsInfoByConditionAndColumns(context, queryCondition, ['session_id']);
    if (!resultSet) {
      HiLog.e(TAG, 'querySessionByMsgIdSendFail query message session is failed');
      return;
    }
    if (!resultSet.rowCount) {
      HiLog.i(TAG, 'querySessionByMsgIdSendFail not query message with msgId');
      return;
    }
    resultSet.goToFirstRow();
    let threadId = resultSet.getLong(0) || undefined;
    resultSet.close();
    HiLog.i(TAG, 'querySessionByMsgIdSendFail threadId:' + threadId);

    let valueBucket: ValuesBucket = {
      sending_status: common.int.SEND_MESSAGE_FAILED
    };
    let actionData: LooseObject = {};
    actionData.threadId = threadId;
    ConversationListService.getInstance()
      .updateSessionByCondition(context, actionData, valueBucket, null, true);
  }

  public updateRcsMmsInfoByCondition(context: Context, actionData: LooseObject,
    valueBucket: ValuesBucket, callback?: Function | null, ): void {
    HiLog.w(TAG, 'updateRcsMmsInfoByCondition start');
    if (GlobalContext.getContext().getObject('DataWorker') != null) {
      (GlobalContext.getContext()
        .getObject('DataWorker') as WorkerWrapper).sendRequest(common.RUN_IN_WORKER_METHOD.updateRcsMmsInfoByCondition, {
        actionData: actionData,
        valueBucket: valueBucket,
        context: context
      } as ConversationServiceParamType, (res?: Object) => {
        if (callback) {
          callback(res);
        }
      });
    } else {
      this.conversationRcsModel.updateRcsMmsInfoByCondition(actionData, valueBucket, callback as Function, context);
    }
    HiLog.w(TAG, 'updateRcsMmsInfoByCondition end');
  }

  public updateRcsReceivedMmsInfoByRcsId(context: Context, actionData: LooseObject,
    valueBucket: ValuesBucket, callback?: Function | null): void {
    if (GlobalContext.getContext().getObject('DataWorker') != null) {
      (GlobalContext.getContext()
        .getObject('DataWorker') as WorkerWrapper).sendRequest(common.RUN_IN_WORKER_METHOD.updateRcsReceivedMmsInfoByRcsId, {
        actionData: actionData,
        valueBucket: valueBucket,
        context: context
      } as ConversationServiceParamType, (res?: Object) => {
        if (callback) {
          callback(res);
        }
      });
    } else {
      this.conversationRcsModel.updateRcsReceivedMmsInfoByRcsId(actionData, valueBucket, callback as Function, context);
    }
  }


  public updateRcsServiceKindMsgCodeByRcsId(actionData: LooseObject,
    valueBucket: ValuesBucket, context: Context, callback?: Function | null): void {
    if (GlobalContext.getContext().getObject('DataWorker') != null) {
      (GlobalContext.getContext()
        .getObject('DataWorker') as WorkerWrapper).sendRequest(common.RUN_IN_WORKER_METHOD.updateRcsServiceKindMsgCodeByRcsId, {
        actionData: actionData,
        valueBucket: valueBucket,
        context: context
      } as ConversationServiceParamType, (res?: Object) => {
        if (callback) {
          callback(res);
        }
      });
    } else {
      this.conversationRcsModel.updateRcsServiceKindMsgCodeByRcsId(actionData,
        valueBucket, callback as Function, context);
    }
  }

  public updateRcsMmsInfoMarkRead(context: Context, actionData: LooseObject, valueBucket: ValuesBucket,
    callback?: Function | null): void {
    if (GlobalContext.getContext().getObject('DataWorker') != null) {
      (GlobalContext.getContext()
        .getObject('DataWorker') as WorkerWrapper).sendRequest(common.RUN_IN_WORKER_METHOD.updateRcsMmsInfoMarkRead, {
        actionData: actionData,
        valueBucket: valueBucket,
        context: context
      } as ConversationServiceParamType, (res?: Object) => {
        if (callback) {
          callback(res);
        }
      });
    } else {
      this.conversationRcsModel.updateRcsMmsInfoMarkRead(actionData, valueBucket, callback as Function, context);
    }
  }

  public queryRcsInfoSlotIdByCondition(phoneNumber: string, callback: Function, context: Context): void {
    let actionData: Record<string, string> = {'phoneNumber': phoneNumber}
    if (GlobalContext.getContext().getObject('DataWorker') != null) {
      (GlobalContext.getContext().getObject('DataWorker') as WorkerWrapper).sendRequest(
        common.RUN_IN_WORKER_METHOD.queryRcsInfoSlotIdByCondition, {
        actionData: actionData,
        context: context
      } as ConversationServiceParamType, (res?: Object) => {
        callback(res);
      })
    } else {
      this.conversationRcsModel.queryRcsInfoSlotIdByCondition(phoneNumber, callback, context);
    }
  }

  public queryRcsInfoByCondition(actionData: LooseObject, callback: Function, context: Context): void {
    if (GlobalContext.getContext().getObject('DataWorker') != null) {
      (GlobalContext.getContext()
        .getObject('DataWorker') as WorkerWrapper).sendRequest(common.RUN_IN_WORKER_METHOD.queryRcsInfoByCondition, {
        actionData: actionData,
        context: context
      } as ConversationServiceParamType, (res?: LooseObject) => {
        if (typeof res?.abilityResult !== 'number') {
          callback(res);
        }else{
          HiLog.i(TAG, 'queryRcsInfoByCondition res:' + res?.abilityResult)
          this.conversationRcsModel.queryRcsInfoByCondition(actionData, callback, context);
        }
      });
    } else {
      this.conversationRcsModel.queryRcsInfoByCondition(actionData, callback, context);
    }
  }

  public async queryRcsInfoByConditionAsync(actionData: LooseObject, context: Context): Promise<resType> {
    return new Promise((resolve) => {
      this.queryRcsInfoByCondition(actionData, (res: resType) => {
        resolve(res);
      }, context);
    });
  }

  public queryRcsInfoSizeByCondition(actionData: LooseObject, callback: Function, context: Context): void {
    if (GlobalContext.getContext().getObject('DataWorker') != null) {
      (GlobalContext.getContext()
        .getObject('DataWorker') as WorkerWrapper).sendRequest(common.RUN_IN_WORKER_METHOD.queryRcsInfoSizeByCondition, {
        actionData: actionData,
        context: context
      } as ConversationServiceParamType, (res?: Object) => {
        callback(res);
      });
    } else {
      this.conversationRcsModel.queryRcsInfoSizeByCondition(actionData, callback, context);
    }
  }

  public queryRcsIdByMsgId(msgId: string, callback: Function, context: Context): void {
    let actionData: LooseObject = {};
    actionData.msgId = msgId;
    if (GlobalContext.getContext().getObject('DataWorker') != null) {
      (GlobalContext.getContext()
        .getObject('DataWorker') as WorkerWrapper).sendRequest(common.RUN_IN_WORKER_METHOD.queryRcsIdByMsgId, {
        actionData: actionData,
        context: context
      } as ConversationServiceParamType, (res?: Object) => {
        callback(res);
      });
    } else {
      this.conversationRcsModel.queryRcsIdByMsgId(actionData, callback, context);
    }
  }

  queryRcsInfoSizeByConditionHandleResult(res: LooseObject): number {
    let size: number = 0;
    if (res.code == common.int.SUCCESS && res.abilityResult != null) {
      size = res.abilityResult as number;
    }
    return size;
  }

  public markAsReadFromReceiveRcs(actionData: LooseObject, callback: Function, context: Context): void {
    if (GlobalContext.getContext().getObject('DataWorker') != null) {
      (GlobalContext.getContext().getObject('DataWorker') as WorkerWrapper).sendRequest(common.RUN_IN_WORKER_METHOD.markAsReadFromReceiveRcs, {
        actionData: actionData,
        context: context
      } as GlobalThisType, (res: Object) => {
        callback(res);
      });
    } else {
      this.conversationRcsModel.markAsReadFromReceiveRcs(actionData, callback, context);
    }
  }

  public updateRcsIsReadBySessionId(context: Context, actionData: LooseObject, callback?: Function | null): void {
    if (GlobalContext.getContext().getObject('DataWorker') != null) {
      (GlobalContext.getContext().getObject('DataWorker') as WorkerWrapper).sendRequest(common.RUN_IN_WORKER_METHOD.updateRcsIsReadBySessionId, {
        actionData: actionData,
        context: context
      } as GlobalThisType, (res: Object) => {
        if (callback) {
          callback(res);
        }
      });
    } else {
      this.conversationRcsModel.updateRcsIsReadBySessionId(actionData, callback, context);
    }
  }

  public updateRcsInfoIsSenderBySessionIds(actionData: Record<string, number[]>, callback: Function,
    context: Context): void {
    if (GlobalContext.getContext().getObject('DataWorker') != null) {
      (GlobalContext.getContext().getObject('DataWorker') as WorkerWrapper)
        .sendRequest(common.RUN_IN_WORKER_METHOD.updateRcsInfoIsSenderBySessionIds, {
        actionData: actionData,
        context: context
      } as GlobalThisType, (res: Object) => {
        if (callback) {
          callback(res);
        }
      });
    } else {
      this.conversationRcsModel.updateRcsInfoIsSenderBySessionIds(actionData, callback, context);
    }
  }

  /**
   * 发送成功更新session
   * @param msgId
   * @param context
   * @returns
   */
  public async querySessionByMsgIdSendOK(msgId: string, context: Context): Promise<void> {
    HiLog.iw(TAG, 'querySessionByMsgIdSendOK start');
    let queryCondition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    queryCondition.equalTo('msg_id', msgId);
    let resultSet: DataShareResultSet | void =
      await ConversationRcsModel.queryInRcsInfoByConditionAndColumns(context, queryCondition, ['session_id']);
    if (!resultSet) {
      HiLog.e(TAG, 'querySessionByMsgIdSendOK query message session is failed');
      return;
    }
    if (!resultSet.rowCount) {
      HiLog.iw(TAG, 'querySessionByMsgIdSendOK not query message with msgId');
      return;
    }
    resultSet.goToFirstRow();
    let threadId = resultSet.getLong(0) || undefined;
    resultSet.close();
    HiLog.iw(TAG, 'querySessionByMsgIdSendOK threadId:' + threadId);

    let valueBucket: ValuesBucket = {
      sending_status: common.int.SEND_MESSAGE_SUCCESS
    };
    let actionData: LooseObject = {};
    actionData.threadId = threadId;
    ConversationListService.getInstance()
      .updateSessionByCondition(context, actionData, valueBucket, null, true);
  }

  public updateRcsInfoMessageToReadState(context: Context, msgId: string): void {
    if (!context || !msgId) {
      return;
    }
    let valueBucket: Record<string, number> = {
      'msg_state': common.int.SEND_MESSAGE_READ
    };
    let condition = new dataSharePredicates.DataSharePredicates();
    condition.equalTo('msg_id', msgId);
    condition.and().equalTo('is_sender', common.is_sender.NO);
    this.conversationRcsModel.updateRcsInfoByConditionAndValuesBucket(context, condition, valueBucket);
  }

  public async updateRcsInfoMessageToReadStateByCondition(context: Context, rcsId: number,
    isRead: number): Promise<void> {
    if (!context || !rcsId) {
      return;
    }
    let valueBucket: Record<string, number> = {
      'is_read': isRead
    };
    let condition = new dataSharePredicates.DataSharePredicates();
    condition.equalTo('rcs_id', rcsId);
    await this.conversationRcsModel.updateRcsInfoByConditionAndValuesBucket(context, condition, valueBucket);
  }
}