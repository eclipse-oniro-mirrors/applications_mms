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

import HiLog from '../utils/HiLog';
import common, { MarkRead } from '../data/commonData';
import ConversationListModel from '../model/ConversationListModel';
import ConversationService from './ConversationService';
import ContactService from './ContactsService';
import TelephoneUtil from '../utils/TelephoneUtil';
import LooseObject from '../data/LooseObject'
import { BusinessError } from '@ohos.base';
import { ValuesBucket } from '@ohos.data.ValuesBucket';
import ConversationListController, { messageType } from '../pages/conversationlist/conversationListController';
import { resType } from './MmsSearchService';
import { GlobalContext } from '../MainAbility/GlobalHelper';
import WorkerWrapper from '../workers/base/WorkerWrapper';
import ConversationListResponse from '../model/conversationlist/ConversationListResponse';
import { ConversationListInfo } from '../model/conversationlist/ConversationListInfo';
import ConversationRcsService from './ConversationRcsService';
import { mmsListType, selectContactType } from '../pages/conversation/conversationController';
import json from '@ohos.util.json';
import { JSON } from '@kit.ArkTS';
import YellowPageService from '../service/yellowPageService';
import StringUtil from '../utils/StringUtil';
import commonData from '../data/commonData';
import MmsUtil, { isMmsMapMessageByMmsListType } from '../utils/MmsUtil';
import { Response, SessionContentTypeOfRcs } from '../utils/TypesUtils';
import SharedPreferencesUtils from '../utils/SharedPreferencesUtils';
import Constant from '../data/Constant';
import DatabaseMaintain from '../DatabaseMaintain/DatabaseMaintain';
import { ChatbotParameters } from '../chatbot/utils/ChatbotEntitys';
import NotificationService from './NotificationService';
import InfoMsgController from '../pages/infomsg/InfoMsgController';
import MmsFileDeleteService from './MmsFileDeleteService';
import FileUtils from '../utils/FileUtils';

const TAG = 'ConversationListService';

export class ChangeIdInfo {
  public delIdArr: string[] = [];
  public updateIdArr: string[] = [];
}

export class ResponseType {
  id: number = -1;
  time: number = -1;
  telephone: string = '';
  content: string = '';
  contactsNum: number = -1;
  smsType: number = -1;
  unreadCount: number = -1;
  sendStatus: number = -1;
  hasDraft: number = 1;
  messageCount: number = -1;
  hasMms: number = -1;
  hasAttachment: number = -1;
  telephoneFormat: string = '';
}

export interface ResObj {
  code?: number,
  abilityResult?: Array<ResponseType> | number | UnreadType,
  messageList?: Array<messageType>,
  response: ResponseType
}

export interface UnreadType {
  totalListCount: number,
  unreadCount: number,
  unreadTotalOfInfo: number
}

interface SendResultsType {
  id?: number,
  telephone: string,
  content: string,
  sendStatus: number
}

interface SelectContactsType {
  contactName: string,
  telephone: string,
  telephoneFormat: string,
  headImage: string,
  select: boolean
}

export interface ResultObj {
  messageList: LooseObject[],
  telephones: string[],
  telephonesForChatbot?: string[]
}

export interface GlobalThisType {
  actionData?: LooseObject,
  valueBucket?: ValuesBucket,
  context: Context
}

export interface ParamsOfUpdateSessionAfterRequestChatbot {
  context: Context
  contactName: string
  serviceId: string
}

export default class ConversationListService {
  private static instance: ConversationListService;
  private conversationListModel: ConversationListModel = new ConversationListModel();

  private constructor() {
  }

  public static getInstance(): ConversationListService {
    if (ConversationListService.instance == null) {
      ConversationListService.instance = new ConversationListService();
    }
    return ConversationListService.instance;
  }

  public static getTestInstance(): ConversationListService {
    return new ConversationListService();
  }

  public insertSession(valueBucket: ValuesBucket, callback: Function, context: Context): void {
        if (GlobalContext.getContext().getObject('DataWorker') != null) {
        (GlobalContext.getContext().getObject('DataWorker') as WorkerWrapper).sendRequest(common.RUN_IN_WORKER_METHOD.insertSession, {
        valueBucket: valueBucket,
        context: context
      } as GlobalThisType, (res: Object) => {
        if (callback) {
          callback(res);
        }
      });
    } else {
      this.conversationListModel.insertSession(valueBucket, callback, context);
    }
    GlobalContext.getContext().setObject('needToUpdate', true)
  }

  /**
   *  增加批量删除分页删除逻辑， 避免threadIds 过多造成数据库异常情况
   *  在原批量删除的地方调用为新的Pagination 方法，分页处理后调用原 deleteSessionByCondition 方法
   * @param actionData
   * @param callback
   * @param context
   */
  public deleteSessionByConditionPagination(actionData: LooseObject, callback: Function, context: Context): void {
    if (actionData.threadIds != null && actionData.threadIds.length > common.int.DELETE_PAGINATION_LENGTH) {
      let threadIds: number[] = actionData.threadIds;
      for (let index = 0; index < threadIds.length; index += common.int.DELETE_PAGINATION_LENGTH) {
        let threadIdsTemp = threadIds.slice(index, index + common.int.DELETE_PAGINATION_LENGTH);
        actionData.threadIds = threadIdsTemp;
        this.deleteSessionByCondition(actionData, callback, context);
      }
    } else {
      this.deleteSessionByCondition(actionData, callback, context);
    }
  }

  public deleteSession(actionData: LooseObject, callback: Function, context: Context): void {
    // 删除会话之前需先查询会话中引用沙箱中图片文件路径
    if (actionData['phoneNumbers']) {
      let telephones: [string] = actionData['phoneNumbers'] as [string];
      telephones.forEach((value, index) => {
        FileUtils.removeLocationImage(context, value);
      });
    }
    let mmsPartPath = [];
    // 删除会话之前需先查询会话中引用沙箱中资源文件路径
    this.queryMmsPartPathBySessionIds(actionData, async (res: []) => {
      if (res.length !== 0) {
        mmsPartPath = res;
      }
      const callbackWrapper = (res: LooseObject) => {
        if (callback) {
          callback(res);
        }
        if (res.code === common.int.SUCCESS) {
          // 删除会话中彩信引用沙箱中资源文件
          if (mmsPartPath.length > 0) {
            MmsFileDeleteService.getInstance().clearByAfterDataBaseDelete(mmsPartPath, context);
          }
          // 短信删除会话成功后需要调用智能信息清智能信息相关缓存数据
          let isDeleteCheck: boolean = common.deleteMessage.DELETECHECK === actionData.deleteMessage;
          let ports: string[] = isDeleteCheck ? actionData.phoneNumbers : actionData.uncheckedPhoneNumbers;
          // MmsOperate.deleteSessions(new DeleteSessionsParams(ports ?? [],
          //   isDeleteCheck ? MmsOperateCondition.IN : MmsOperateCondition.NOT_IN));
        }
      }
      this.handleDeleteSession(actionData, callbackWrapper, context);
    }, context);
  }

  public handleDeleteSession(actionData: LooseObject, callback: Function, context: Context): void {
    if (GlobalContext.getContext().getObject('DataWorker') != null) {
      (GlobalContext.getContext().getObject('DataWorker') as WorkerWrapper)
        .sendRequest(common.RUN_IN_WORKER_METHOD.deleteSessionSlice, {
        actionData: actionData,
        context: context
      } as GlobalThisType, (res: Object) => {
          if (callback) {
            callback(res);
          }
        });
    } else {
      HiLog.e(TAG, 'deleteSessionSlice NO DataWorker');
      this.conversationListModel.deleteSessionSlice(actionData, callback, context);
    }
  }

  public queryMmsPartPathBySessionIds(actionData: LooseObject, callback: Function, context: Context): void {
    if (GlobalContext.getContext().getObject('DataWorker') != null) {
      (GlobalContext.getContext().getObject('DataWorker') as WorkerWrapper)
        .sendRequest(common.RUN_IN_WORKER_METHOD.queryMmsPartPathBySessionIds, {
          actionData: actionData,
          context: context
        } as GlobalThisType, (res: Object) => {
          if (callback) {
            callback(res);
          }
        });
    } else {
      HiLog.e(TAG, 'queryMmsPartPathBySessionIds NO DataWorker');
      this.conversationListModel.queryMmsPartPathBySessionIds(actionData, callback, context);
    }
  }

  /**
   *  增加批量删除分页删除逻辑， 避免uncheckedThreadIds  过多造成数据库异常情况
   *  在原批量删除的地方调用为新的Pagination 方法，分页处理后调用原 deleteSessionByCondition 方法
   * @param actionData
   * @param callback
   * @param context
   */
  public deleteSessionByJnConditionPagination(actionData: LooseObject, callback: Function, context: Context): void {
    if (actionData.uncheckedThreadIds != null &&
      actionData.uncheckedThreadIds.length > common.int.DELETE_PAGINATION_LENGTH) {
      let threadIds: number[] = actionData.uncheckedThreadIds;
      for (let index = 0; index < threadIds.length; index += common.int.DELETE_PAGINATION_LENGTH) {
        let threadIdsTemp = threadIds.slice(index, index + common.int.DELETE_PAGINATION_LENGTH);
        actionData.uncheckedThreadIds = threadIdsTemp;
        this.deleteSessionByCondition(actionData, callback, context);
      }
    } else {
      this.deleteSessionByCondition(actionData, callback, context);
    }
  }
  
    /**
   *  替代原有分页批量删除逻辑，传递 uri 到底座，使用 sql 指令删除
   * @param actionData
   * @param callback
   * @param context
   */
  public deleteSessionByUriPagination(actionData: LooseObject, callback: Function, context: Context): void {
    if (actionData.deleteMessage === undefined) {
      HiLog.w(TAG, 'invalid delete operation ');
      return;
    }
    if (common.deleteMessage.DELETECHECK == actionData.deleteMessage) {
      actionData.sessionIDs = actionData.threadIds;
    } else if (common.deleteMessage.DELETEUNCHECK == actionData.deleteMessage ||
        common.deleteMessage.DELETEALL == actionData.deleteMessage) {
      actionData.sessionIDs = actionData.uncheckedThreadIds;
    } else {
      HiLog.w(TAG, 'invalid delete operation ');
      return;
    }
    if (actionData.sessionIDs == null) {
      HiLog.w(TAG, 'invalid delete sessionIDs ');
      return;
    }
    this.checkAndDeleteSession(actionData, callback, context);
  }

  public async checkAndDeleteSession(actionData: LooseObject, callback: Function, context: Context) {
    if (actionData.sessionIDs.length > common.int.DELETE_PAGINATION_LENGTH) {
      let threadIds: number[] = actionData.sessionIDs;
      for (let index = 0; index < threadIds.length; index += common.int.DELETE_PAGINATION_LENGTH) {
        let threadIdsTemp = threadIds.slice(index, index + common.int.DELETE_PAGINATION_LENGTH);
        actionData.sessionIDs = threadIdsTemp;
        let timeoutPromise = new Promise<boolean>((_, reject) => {
          setTimeout(() => reject(new Error('Request timed out')), 1000);
        });
        try {
          // add Promise.race timeout
          await Promise.race([
            this.processDeleteSession(actionData, callback, context), timeoutPromise])
            .then(() => {
              callback()
            });
        } catch (error) {
          HiLog.e(TAG, `checkAndUpdateContact error: ${error.message}`);
        }
      }
    } else {
      this.processDeleteSession(actionData, callback, context)
        .then(() => {
          callback()
        });
    }
  }

  public processDeleteSession(actionData: LooseObject, callback: Function, context: Context): Promise<void> {
    let process = new Promise<void>((resolve) => {
      this.deleteSession(actionData, async (res: LooseObject) => {
        HiLog.w(TAG, 'delete Session finished ');
        resolve();
      }, context);
    });
    return process;
  }

  public deleteSessionByCondition(actionData: LooseObject, callback: Function, context: Context): void {
        if (GlobalContext.getContext().getObject('DataWorker') != null) {
        (GlobalContext.getContext().getObject('DataWorker') as WorkerWrapper).sendRequest(common.RUN_IN_WORKER_METHOD.deleteSessionByCondition, {
        actionData: actionData,
        context: context
      } as GlobalThisType, (res: Object) => {
        if (callback) {
          callback(res);
        }
      });
    } else {
      this.conversationListModel.deleteSessionByCondition(actionData, callback, context);
    }
  }

  public updateSessionByCondition(context: Context, actionData: LooseObject, valueBucket: ValuesBucket,
    callback: Function | null, needUpdateSessionList?: boolean): void {
    if (GlobalContext.getContext().getObject('DataWorker') != null) {
      (GlobalContext.getContext().getObject('DataWorker') as WorkerWrapper).sendRequest(common.RUN_IN_WORKER_METHOD.updateSessionByCondition, {
        actionData: actionData,
        valueBucket: valueBucket,
        context: context
      } as GlobalThisType, (res: Object) => {
        if (callback) {
          callback(res);
        }
      });
    } else {
      this.conversationListModel.updateSessionByCondition(actionData, valueBucket, callback, context);
    }
    //因不能确定所有调用场景是否都需要更改此参数，故通过条件判断
    if (needUpdateSessionList) {
      GlobalContext.getContext().setObject('needToUpdate', true)
    }
  }

  /**
   * Batch update session by condition.
   *
   * @param context
   * @param conditions
   * @param valueBuckets
   * @param callback
   */
  public fetchRecentContactsAndBatchUpdateSession(
    context: Context,
    startUpdateTime: string,
    endUpdateTime: string,
    callback: Function
  ): void {
    let actionData: Record<string, string> = {
      'startUpdateTime': startUpdateTime,
      'endUpdateTime': endUpdateTime,
    }
    if (GlobalContext.getContext().getObject('DataWorker') != null) {
      (GlobalContext.getContext().getObject('DataWorker') as Object as WorkerWrapper)
        .sendRequest(common.RUN_IN_WORKER_METHOD.fetchRecentContactsAndBatchUpdateSession, {
          actionData: actionData,
          context: context
        } as GlobalThisType, (results: Object) => {
          callback(results as number[]);
        });
    } else {
      this.conversationListModel.fetchRecentContactsAndBatchUpdateSession(
        context, startUpdateTime, endUpdateTime, callback);
    }
  }

  public fetchRecentContactsAndBatchUpdateSessionTaskPool(
    startUpdateTime: string,
    endUpdateTime: string,
    callback: Function,
    context: Context
  ): void {
    this.conversationListModel.fetchRecentContactsAndBatchUpdateSession(
      context, startUpdateTime, endUpdateTime, callback);
  }

  public fetchRecentContactsAndBatchUpdateInfoTaskPool(context: Context, callback: Function): void {
    TelephoneUtil.updateInfoMsg(context, callback);
    SharedPreferencesUtils.init(context);
    SharedPreferencesUtils.saveToPreferencesTaskPool('updateInfoMsgVersion', Constant.UPDATE_MSG_VERSION_V2);
    DatabaseMaintain.getInstance().databaseCleanup(context);
  }

  public async fetchRcsInfoAndBatchUpdateSmsMmsInfoTask(context: Context): Promise<number> {
    // 同步结果
    let syncResult: number = common.int.SUCCESS;
    let rcsTotal: number = 0;

    // 查询条件
    let rcsActionData: LooseObject = {};
    rcsActionData.rcsType = commonData.ENHANCED_INFO_ITEM_TYPE.CHATBOT_CARD;
    rcsActionData.pageSize = Constant.UPDATE_SYNC_VCARD_INFO_PAGESIZE;
    rcsActionData.pageNum = 1;
    let mmsActionData: LooseObject = {};
    let querySizeData: LooseObject = {
      rcsType: commonData.ENHANCED_INFO_ITEM_TYPE.CHATBOT_CARD
    }

    await ConversationService.getInstance().getRcsMmsInfoSizeByCondition(querySizeData, context).then((num: number) => {
      rcsTotal = num;
    }).catch((error: BusinessError) => {
      syncResult = common.int.FAILURE;
      HiLog.e(TAG, 'getRcsMmsInfoSizeByCondition fail, error: ' + JSON.stringify(error));
    });
    if (rcsTotal === 0) {
      return syncResult;
    }

    // 保存查询结果
    let rcsIds: number[] = [];
    let rcsContentMap = new Map<number, string>();
    let rcsInfoMap = new Map<number, LooseObject>();

    // 遍历查询更新插入
    for (let pageNum = 1; pageNum < Math.ceil(rcsTotal / rcsActionData.pageSize) + 1; pageNum++) {
      rcsActionData.pageNum = pageNum;
      rcsIds = [];
      rcsInfoMap.clear();
      rcsContentMap.clear();

      try {
        await ConversationRcsService.getInstance().queryRcsInfoByConditionAsync(rcsActionData, context).then(async (infoList: resType)=>{
          if (infoList.abilityResult.length == 0) {
            return;
          }
          infoList.abilityResult.forEach((item) => {
            rcsIds.push(item.rcsId);
            rcsInfoMap.set(item.rcsId, item);
          })

          // 根据id集合查询详情,内容为空的
          mmsActionData.rcsIds = rcsIds;
          await ConversationService.getInstance().querySmsMmsInfoByConditionAsync(context, mmsActionData).then(async (res: resType)=>{
            res.abilityResult.forEach((item) => {
              // 识别出需要更新的和插入的，rcsContentMap是需要更新内容的，rcsInfoMap是需要插入数据的
              if (rcsInfoMap.has(item.rcsId)) {
                // mms表中有rcsId，判断是已更新，还是需要更新，已更新，直接从map删除
                if (item.msgContent && item.msgContent.length > 0) {
                  rcsInfoMap.delete(item.rcsId);
                  return;
                }
                // 需要更新的
                rcsContentMap.set(item.rcsId, rcsInfoMap.get(item.rcsId)?.msgContent);
                rcsInfoMap.delete(item.rcsId);
              }
            });

            //批量更新
            await ConversationService.getInstance().batchUpdateMsgContentByRcsIds(rcsContentMap, context).then((res: number) => {
              syncResult = res === common.int.FAILURE ? common.int.FAILURE : syncResult;
            });
            // 剩下的是需要插入的
            await ConversationService.getInstance().batchInsertSmsMmsInfo(rcsInfoMap, context).then((res: number) => {
              syncResult = res === common.int.FAILURE ? common.int.FAILURE : syncResult;
            });
          })
        });
      } catch (e) {
        syncResult  = common.int.FAILURE;
        HiLog.e(TAG, 'fetchRcsInfoAndBatchUpdateSmsMmsInfoTask error, msg:' + json.stringify(e))
      }
    }
    return syncResult;
  }

  /**
   * Batch update session by delete contacts.
   *
   * @param context
   * @param conditions
   * @param valueBuckets
   * @param callback
   */
  public fetchDeleteContactsAndUpdateSession(rawContactIds: string[], context: Context, callback: Function): void {
    let actionData: Record<string, string[]> = {
      'rawContactIds': rawContactIds,
    }
    if (GlobalContext.getContext().getObject('DataWorker') != null) {
      (GlobalContext.getContext().getObject('DataWorker') as Object as WorkerWrapper)
        // 添加workWrapper
        .sendRequest(common.RUN_IN_WORKER_METHOD.fetchDeleteContactsAndUpdateSession, {
          actionData: actionData,
          context: context
        } as GlobalThisType, (results: Object) => {
          callback(results as number[]);
        });
    } else {
      this.conversationListModel.fetchDeleteContactsAndUpdateSession(context, rawContactIds, callback);
    }
  }

  public markAsReadFromReceive(actionData: LooseObject, callback: Function, context: Context): void {
        if (GlobalContext.getContext().getObject('DataWorker') != null) {
        (GlobalContext.getContext().getObject('DataWorker') as WorkerWrapper).sendRequest(common.RUN_IN_WORKER_METHOD.markAsReadFromReceive, {
        actionData: actionData,
        context: context
      } as GlobalThisType, (res: Object) => {
        callback(res);
      });
    } else {
      this.conversationListModel.markAsReadFromReceive(actionData, callback, context);
    }
  }

  public querySessionByCondition(context: Context, actionData: LooseObject, callback: Function): void {
    if (GlobalContext.getContext().getObject('DataWorker') != null) {
      (GlobalContext.getContext().getObject('DataWorker') as WorkerWrapper).sendRequest(common.RUN_IN_WORKER_METHOD.querySessionByCondition, {
        actionData: actionData,
        context: context
      } as GlobalThisType, (res) => {
        callback(res);
      });
    } else {
      this.conversationListModel.querySessionByCondition(actionData, callback, context);
    }
  }

  public queryMatchedRecipient(context: Context, actionData: LooseObject, callback: Function): void {
    if (GlobalContext.getContext().getObject('DataWorker') != null) {
      (GlobalContext.getContext().getObject('DataWorker') as WorkerWrapper).sendRequest(common.RUN_IN_WORKER_METHOD.queryMatchedRecipient, {
        actionData: actionData,
        context: context
      } as GlobalThisType, (res) => {
        callback(res);
      });
    } else {
      this.conversationListModel.queryMatchedRecipient(actionData, callback, context);
    }
  }

  /**
   * 根据会话id查询当前会话的对端手机号
   * @param context 上下文
   * @param threadId 会话id
   * @returns 当前会话的对端手机号
   */
  public async querySessionTelPhoneByThreadId(context: Context, threadId: number): Promise<string> {
    let mobilePhoneNumber = '';
    if (!context || !threadId) {
      HiLog.e(TAG, `querySessionTelPhoneByThreadId param invalid`);
      return mobilePhoneNumber;
    }
    let actionData: LooseObject = {
      threadId: threadId
    };
    let result: Promise<string> = new Promise((resolve) => {
      this.querySessionByCondition(context, actionData, (res: ConversationListResponse) => {
          if (res?.code === common.int.SUCCESS) {
            let responseList: ConversationListInfo[] = res.abilityResult as ConversationListInfo[];
            // querySessionByCondition 接口待整改，数据库没有数据时，返回的列表应该是空的才对,当前逻辑是返回一条。
            if (responseList?.length === 1 && responseList[0]?.id <= 0) {
              HiLog.i(TAG, 'db has no session,but return one empty session,do not need handle.');
            } else if (responseList?.length > 0) {
              HiLog.i(TAG, `querySessionTelPhoneByThreadId,result.length is ${responseList?.length}`);
              mobilePhoneNumber = responseList[0]?.telephone;
            } else {
              HiLog.w(TAG, 'querySessionTelPhoneByThreadId,result is empty.');
            }
          } else {
            HiLog.e(TAG, 'querySessionTelPhoneByThreadId,result is error.');
          }
          resolve(mobilePhoneNumber);
          HiLog.w(TAG, `querySessionTelPhoneByThreadId.length is ${mobilePhoneNumber?.length}`);
        })
    });
    return result;
  }

  public querySessionResultByCondition(actionData: LooseObject, callback: Function, context: Context): void {
    let useWorker: boolean = actionData.useWorker == undefined ? true : actionData.useWorker;
    HiLog.i(TAG, '[querySessionResultByCondition] useWorker=' + useWorker)
    if (GlobalContext.getContext().getObject('DataWorker') != null && useWorker) {
      (GlobalContext.getContext()
        .getObject('DataWorker') as WorkerWrapper).sendRequest(common.RUN_IN_WORKER_METHOD.querySessionResultByCondition,
        {
          actionData: actionData,
          context: context
        } as GlobalThisType, (res: Object) => {
          callback(res);
        });
    } else {
      this.conversationListModel.querySessionResultByCondition(actionData, callback, context);
    }
  }

  public querySessionSizeByCondition(actionData: LooseObject, callback: Function, context: Context): void {
    if (GlobalContext.getContext().getObject('DataWorker') != null) {
      (GlobalContext.getContext().getObject('DataWorker') as WorkerWrapper).sendRequest(common.RUN_IN_WORKER_METHOD.querySessionSizeByCondition, {
        actionData: actionData,
        context: context
      } as GlobalThisType, (res: Object) => {
        callback(res);
      });
    } else {
      this.conversationListModel.querySessionSizeByCondition(actionData, callback, context);
    }
  }

  public async getSessionListSize(actionData: LooseObject, context: Context): Promise<number> {
    let condition: LooseObject = {};
    condition.smsType = actionData.smsType;
    let result: Promise<number> = new Promise((resolve) => {
      this.querySessionSizeByCondition(condition, (res: ResObj) => {
        let size: number = 0;
        if (res.code == common.int.SUCCESS && res.abilityResult != null) {
          size = (res.abilityResult as number);
        }
        resolve(size);
      }, context);
    });
    return result;
  }

  public async queryPinSessionSize(actionData: LooseObject, context: Context): Promise<number> {
    let result: Promise<number> = new Promise((resolve) => {
      this.querySessionSizeByCondition(actionData, (res: ResObj) => {
        let size: number = 0;
        if (res.code == common.int.SUCCESS && res.abilityResult != null) {
          size = (res.abilityResult as number);
        }
        resolve(size);
      }, context);
    });
    return result;
  }

  public getSessionListResult(actionData: LooseObject, context: Context): Promise<LooseObject> {
    let result: Promise<LooseObject> = new Promise((resolve) => {
      this.querySessionByCondition(context, actionData, (res: ConversationListResponse) => {
        let result: ResultObj = {
          messageList: [],
          telephones: [],
          telephonesForChatbot: []
        };
        if (res.code == common.int.SUCCESS && res.abilityResult != null) {
          result = this.getConvertSessionListResult(res.abilityResult);
        }
        resolve(result);
      })
    });
    return result;
  }

  public getSessionListResultNew(actionData: LooseObject, context: Context): Promise<LooseObject> {
    let result: Promise<LooseObject> = new Promise((resolve) => {
      this.querySessionResultByCondition(actionData, (result: resType) => {
        resolve(result);
      }, context)
    });
    return result;
  }

  public isExistNoticeMessage(context: Context): Promise<boolean> {
    let result: Promise<boolean> = new Promise((resolve) => {
      let actionData: LooseObject = {};
      actionData.smsType = common.sms_type.NOTICE;
      this.querySessionSizeByCondition(actionData, (res: ResObj) => {
        let isExistNoticeMessage: boolean = false;
        if (res.code == common.int.SUCCESS && res.abilityResult != null && res.abilityResult > 0) {
          isExistNoticeMessage = true;
        }
        resolve(isExistNoticeMessage);
      }, context);
    });
    return result;
  }

  public querySessionList(actionData: LooseObject, callback: Function, context: Context): void {
    let result: LooseObject = {};
    let queryPromise: Promise<LooseObject> = this.getSessionListResult(actionData, context);
    let countPromise: Promise<number> = this.getSessionListSize(actionData, context);
    let noticePromise: Promise<boolean> = this.isExistNoticeMessage(context);
    Promise.all<boolean | number | LooseObject>([queryPromise, countPromise, noticePromise]).then(res => {
      result.code = common.int.SUCCESS;
      result.total = res[1];
      result.hasInfoMsg = res[2];
      result.response = [];
      HiLog.i(TAG, 'querySessionList, sessionList.length: ' + (res[0] as LooseObject).messageList.length +
          ', total=' + result.total + ', hasInfoMsg=' + result.hasInfoMsg);
      if (result.total > 0) {
        this.dealContactsName((res[0] as LooseObject).telephones, actionData, (res[0] as LooseObject).messageList,
          (res1: ResObj) => {
          result.messageList = res1;
          this.dealYellowPageNameSecond((res[0] as LooseObject).telephones, actionData,
            result.messageList, (res2: ResObj) => {
              result.response = res2;
              HiLog.i(TAG, 'querySessionResultByCondition,res:')
              callback(result);
          }, context);
        }, context);
      } else {
        callback(result);
      }
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'querySessionList, error: ' + JSON.stringify(error));
      result.code = common.int.FAILURE;
      callback(result);
    });
  }

  private getConvertSessionListResult(sessionList: Array<ConversationListInfo>): ResultObj {
    let result: ResultObj = {
      messageList: [],
      telephones: [],
      telephonesForChatbot: []
    };
    if (sessionList == null) {
      return result;
    }
    let messageList: Array<LooseObject> = [];
    let telephones: Array<string> = [];
    let telephonesForChatbot: string[] = [];
    for (let session of sessionList) {
      let item: LooseObject = this.dealConvertSessionListItem(session);
      if (item.contactsNum > 1) {
        let telephoneSplit: string[] = item.telephone.split(common.STR.COMMA);
        for (let item of telephoneSplit) {
          telephones.push(item);
        }
      } else {
        telephones.push(item.telephone);
        if (item.telephone.startsWith('sip:') && item.telephone.includes('botplatform')) {
          telephonesForChatbot.push(item.telephone);
        }
      }
      messageList.push(item);
    }
    result.messageList = messageList;
    result.telephones = telephones;
    result.telephonesForChatbot = telephonesForChatbot
    return result;
  }

  private dealConvertSessionListItem(session: ConversationListInfo) {
    let item: LooseObject = {};
    item.name = common.STR.EMPTY_STR;
    item.contactsNum = session.contactsNum;
    item.content = session.content;
    item.countOfUnread = session.unreadCount;
    if (session.smsType == common.sms_type.COMMON) {
      item.icon = 'icon/user_avatar_full_fill.svg';
    } else {
      item.icon = 'icon/ic_bell_fill.svg';
    }
    item.smsType = session.smsType;
    item.isCbChecked = false;
    item.sendingFailed = session.sendStatus == common.int.SEND_MESSAGE_FAILED ? true : false;
    item.telephone = session.telephone;
    item.telephoneFormat = session.telephoneFormat;
    item.threadId = session.id;
    item.timeMillisecond = session.time;
    item.isDraft = session.hasDraft == 1 ? true : false;
    item.time = common.STR.EMPTY_STR;
    item.messageCount = session.messageCount;
    item.hasMms = session.hasMms == 1 ? true : false;
    item.hasAttachment = session.hasAttachment == 1 ? true : false;
    item.id = session.id;
    item.hasYellowPageIcon = common.STR.EMPTY_STR;
    item.yellowPageId = common.STR.EMPTY_STR;
    return item;
  }

  public dealContactsName(telephones: string[], actionData: LooseObject,
    sessionLists: LooseObject[], callback: Function, context: Context, isFromGroup: boolean = false) {
    if (telephones.length == 0) {
      HiLog.w(TAG, 'dealContactsName, has no telephones');
      callback(sessionLists);
      return;
    }
    actionData.telephones = telephones;
    actionData.hasDelete = '0';
    ContactService.getInstance().queryContactDataByCondition(actionData, (res: resType) => {
      if (res.code == common.int.FAILURE || res.abilityResult.length == 0) {
        HiLog.w(TAG, 'dealContactsName, has no contacts');
        callback(this.conversationListModel.buildSessionNames([], sessionLists, context, isFromGroup));
      } else {
        callback(this.conversationListModel.buildSessionNames(res.abilityResult, sessionLists, context, isFromGroup));
      }
    }, context);
  }

  public dealYellowPageNameSecond(telephones: string[], actionData: LooseObject, sessionLists: LooseObject[],
    callback: Function, context: Context) {
    if (telephones.length == 0) {
      HiLog.w(TAG, 'dealYellowPageNameSecond, has no telephones');
      callback(sessionLists);
      return;
    }
    actionData.telephones = telephones;
    YellowPageService.getInstance().queryYellowPageListInfoByCondition(actionData, (res: resType) => {
      if (res.code == common.int.FAILURE || res.abilityResult.length == 0) {
        HiLog.w(TAG, 'dealYellowPageNameSecond, has no YellowPage');
        callback(this.conversationListModel.buildSessionNamesByYellowPage([], sessionLists, context));
      } else {
        callback(this.conversationListModel.buildSessionNamesByYellowPage(res.abilityResult, sessionLists, context));
      }
    }, context);
  }

  public statisticalData(callBack: Function, context: Context): void {
    let result: LooseObject = {};
    ConversationService.getInstance().statisticalData((res: resType) => {
      if (res.code == common.int.SUCCESS) {
        let abilityResult = (res.abilityResult as LooseObject);
        result.code = common.int.SUCCESS;
        let response: LooseObject = {};
        // 全部类型未读消息
        response.totalListCount = abilityResult.totalListCount;
        // 未读普通总数
        response.unreadCount = abilityResult.unreadCount;
        // 未读通知消息 = 未读消息总数+未读通知消息总数,待通知和普通通知拆分时，再拆开统计
        response.unreadTotalOfInfo = abilityResult.unreadInfo + abilityResult.unreadTotalOfInfo;
        HiLog.w(TAG, '[statisticalData] update preference unread, totalUnread: ' + response.totalListCount +
          ', unreadTotalOfInfo: ' + response.unreadTotalOfInfo);
        NotificationService.getInstance().setBadgeNumber(response.totalListCount);
        InfoMsgController.getInstance().unreadTotalOfInfo = response.unreadTotalOfInfo;
        ConversationListController.getInstance().unreadTotalOfInfo = response.unreadTotalOfInfo;
        ConversationListController.getInstance().unreadTotal = response.totalListCount;
        SharedPreferencesUtils.saveToPreferences(common.STR.KEY_OF_UNREAD_TOTAL, response.totalListCount);
        SharedPreferencesUtils.saveToPreferences(common.STR.KEY_OF_UNREAD_INFO, response.unreadTotalOfInfo);
        result.response = response;
        callBack(result);
      } else {
        HiLog.w(TAG, 'statisticalData, failed');
        result.code = common.int.FAILURE;
        callBack(result);
      }
    }, context as Context);
  }

  public deleteMessageById(actionData: LooseObject, callback: Function, context: Context): void {
    // Deletes data from the session list.
    // 新增修改为分页删除
    let threadIds: number[] = actionData.threadIds;
    this.deleteSessionByConditionPagination(actionData, () => {}, context);
    // Deletes data from the information list.
    actionData.threadIds = threadIds;
    ConversationService.getInstance().deleteSmsMmsInfoPagination(context, actionData, callback);
  }

  //删除场景：未选中传入数据库
  public deleteMessageByJnCheckedId(actionData: LooseObject, callback: Function, context: Context): void {
    // Deletes data from the session list.
    // 新增修改为分页删除
    let threadIds: number[] = actionData.uncheckedThreadIds;
    this.deleteSessionByJnConditionPagination(actionData, () => {}, context);
    // Deletes data from the information list.
    actionData.uncheckedThreadIds = threadIds;
    ConversationService.getInstance().deleteJnSmsMmsInfoPagination(context, actionData, callback);

  }

  public updateSessionRead(context: Context, threadId: number) {
    let queryActionData: LooseObject = {};
    queryActionData.threadId = threadId;
    queryActionData.markReadType = MarkRead.single;
    let valueBucket: Record<string, number> = {
      'unread_count': 1
    }
    this.updateSessionUnReadBySessionId(queryActionData, valueBucket, ()=>{}, context);
  }

  public markAllToRead(context: Context, actionData: LooseObject, smsMmsInfoCallback?: Function | null) {
    HiLog.i(TAG, 'markAllToRead');
    actionData.unreadCount_greaterThan = 0;
    let queryActionData: LooseObject = {};
    // 特定会话已读传入threadId，标记多会话已读的情况传入threadIds；如果未携带threadId/threadIds，直接return，防止误标记
    if (actionData.threadId != null) {
      HiLog.w(TAG, `mark to read threadId: ${json.stringify(actionData.threadId)}`)
      queryActionData.threadId = actionData.threadId;
      queryActionData.markReadType = MarkRead.single;
      this.processBatchRead(context, queryActionData, smsMmsInfoCallback);
      return;
    } else if (actionData.threadIds != null) {
      HiLog.w(TAG, `Shouldn't be able to get in.`)
    } else {
      HiLog.w(TAG, 'markAllToRead has no threadId or threadIds parameter');
      return;
    }

    // 查询当前会话是否有未读数，没有未读数不再更新数据库
  }

  // 保底方法，如果用户存在session表已更新，但详情未更新的情况，允许主会话列表点击标记全部已读时不再查询session表未读数，直接更新
  public markAllAsRead(context: Context, actionData: LooseObject, sessionCallback?: Function | null,
                       smsMmsInfoCallback?: Function | null, ) {
    this.processBatchRead(context, actionData, sessionCallback);
  }

  private handleMarkAllToReadError(sessionCallback?: Function | null, smsMmsInfoCallback?: Function | null): void {
    if (sessionCallback) {
      sessionCallback(new ConversationListResponse(common.int.FAILURE,[]));
    }
    if (smsMmsInfoCallback) {
      let result: LooseObject = {};
      result.code = common.int.FAILURE;
      smsMmsInfoCallback(result);
    }
  }

  /**
   * Adding a session draft list
   *
   * @param valueBucket New Data
   * @callback callback
   */
  public insertSessionDraft(actionData: LooseObject, callback: Function, context: Context): void {
    let param = this.dealSendResults(actionData);
    if (actionData.selectContacts && actionData.selectContacts.length > 0) {
      let telephones: string[] = (param.telephone ?? '').split(common.STR.COMMA);
      let contacts: selectContactType[] = actionData.selectContacts as selectContactType[];
      contacts.forEach((item) => {
        item.contactName = StringUtil.isEmpty(item.contactName) ? item.telephone : item.contactName
      })
      contacts.sort((a, b) => {
        return telephones.indexOf(a.telephone) - telephones.indexOf(b.telephone);
      })
    }
    // Check whether a session list has been created
    this.querySessionByTelephone(param.telephone, (res: ResObj) => {
      if (res.code == common.int.SUCCESS && res.response) {
        if (res.response.id <= 0) {
          // If you modify the recipient in draft state and save the modification again, you need to delete the
          // unnecessary session draft before modification.
          if (actionData.threadId != 0 && actionData.isDraft) {
            this.deleteSessionByCondition(actionData, () => {}, context);
          }
          this.dealInsertSession(param, actionData, callback, context);
        } else {
          HiLog.i(TAG, 'deleteDraftDataOrUpdate');
          if (actionData.isNewMsg && actionData.threadId !== res.response.id) {
            this.deleteSessionByCondition(actionData, () => {}, context);
          }
          this.deleteDraftDataOrUpdate(actionData, res.response, param, callback, context);
        }
      } else {
        HiLog.e(TAG, 'querySessionByTelephone fail');
      }
      GlobalContext.getContext().setObject('needToUpdate', true)
    }, context);
  }

  public dealInsertSession(param: LooseObject, actionData: LooseObject, callback: Function, context: Context): void {
    let contactsId: string[] = [];
    let contactsName: string[] = [];
    if (actionData.selectContacts) {
      (actionData.selectContacts as selectContactType[]).forEach((cnt: selectContactType) => {
        contactsId.push(cnt.rawContactId || '');
        contactsName.push(cnt.contactName || '');
      });
    }
    let valueBucket: ValuesBucket = {
      telephone: param.telephone,
      content: param.content,
      contacts_num: param.contactsNum,
      sms_type: param.smsType,
      unread_count: 0,
      sending_status: common.int.SEND_MESSAGE_SENDING,
      has_draft: common.has_draft.HAVE,
      time: param.timestamp,
      has_mms: param.hasMms,
      has_attachment: param.hasAttachment,
      contact_id: contactsId.join(common.STR.COMMA),
      contact_name: contactsName.join(common.STR.COMMA),
    }
    HiLog.i(TAG, 'insertSession start');
    this.insertSession(valueBucket, (sessionResult: ResObj) => {
      // Invoke the SMS database to insert SMS messages.
      HiLog.i(TAG, 'insertSession success');
      let sessionId: number = sessionResult.abilityResult as number;
      ConversationService.getInstance().dealInsertMessageDetail(param, actionData, sessionId, (res: LooseObject) => {
        HiLog.i(TAG, 'dealInsertMessageDetail success');
        ConversationService.getInstance()
          .insertMmsInfoList(res, actionData.mmsSource, context);
        callback();
      }, context as Context);
    }, context);
  }

  public deleteDraftDataOrUpdate(actionData: LooseObject, response: ResponseType,
    param: LooseObject, callback: Function, context: Context): void {
    if (actionData.groupId > 0) {
      ConversationService.getInstance().deleteSmsMmsInfoByCondition(context, actionData, () => {});
    }
    if (actionData.content != common.STR.EMPTY_STR || actionData.mmsSource.length > 0) {
      // Save New Draft
      this.updateDraftData(response, param, actionData, callback, context);
    } else {
      if (callback) {
        callback();
      }
    }
  }

  public updateDraftData(response: ResponseType, param: LooseObject,
    actionData: LooseObject, callback: Function, context: Context): void {
    let valueBucket: ValuesBucket = {
      content: param.content,
      has_draft: common.has_draft.HAVE,
      time: new Date().getTime(),
      has_attachment: param.hasAttachment,
      has_mms: param.hasMms,
    }
    let sessionId: number = response.id;
    let condition: LooseObject = {};
    condition.threadId = sessionId;
    this.updateSessionByCondition(context, condition, valueBucket, () => {
      callback();
    }, true);
    ConversationService.getInstance().dealInsertDraftData(param, actionData, sessionId,(res: LooseObject) => {
      if (res.initDatas && res.initDatas.length > 0 && AppStorage.get(Constant.IS_CHANGE_DRAFT)) {
        //保存插入草稿的id和草稿内容
        AppStorage.setOrCreate(Constant.INSERT_DRAFT_MSG_ID, res.initDatas[0].id);
        AppStorage.setOrCreate(Constant.INSERT_DRAFT_MSG_CONTENT, actionData.content);
        AppStorage.delete(Constant.IS_CHANGE_DRAFT);
      }
      ConversationService.getInstance()
        .insertMmsInfoList(res, actionData.mmsSource, context);
    }, context as Context);
  }

  public dealSendResults(actionData: LooseObject): LooseObject {
    let contactsNum: number = 1;
    let telephone: string = common.STR.EMPTY_STR;
    if (actionData.isNewMsg) {
      let selectContacts: SelectContactsType[] = actionData.selectContacts;
      if (selectContacts.length > 1) {
        for (let contact of selectContacts) {
          telephone = telephone + contact.telephone + common.STR.COMMA;
        }
        // If it fails, then the session list turns out to be a failure.
        telephone = telephone.substring(0, telephone.length - 1);
        contactsNum = selectContacts.length;
      } else if (selectContacts.length == 1) {
        telephone = selectContacts[0]?.telephone;
      }
      let receiveContactValue: string = actionData.receiveContactValue;
      if (receiveContactValue != common.STR.EMPTY_STR) {
        telephone = actionData.receiveContactValue;
      }
    } else {
      telephone = actionData.telephone;
    }
    let smsType: number = common.sms_type.COMMON;
    if (contactsNum == 1 && TelephoneUtil.judgeIsInfoMsg(telephone)) {
      smsType = common.sms_type.NOTICE;
    } else if (telephone?.startsWith('sip:') && telephone?.includes('botplatform')) {
      smsType = common.sms_type.NOTICE;
    }
    let sendResult: SendResultsType = {
      telephone: telephone,
      content: actionData.content as string,
      sendStatus: common.int.SEND_DRAFT
    }
    actionData.sendResults = [sendResult];
    let timestamp = new Date().getTime();
    let result: LooseObject = {};
    result.contactsNum = contactsNum;
    result.telephone = TelephoneUtil.dealTelephoneSort(telephone);
    result.content = actionData.content;
    result.sendStatus = common.int.SEND_MESSAGE_SENDING;
    result.smsType = smsType;
    result.timestamp = timestamp;
    result.hasMms = actionData.isMms ? 1 : 0;
    result.hasAttachment = actionData.hasAttachment ? 1 : 0;

    return result;
  }

  public querySessionByTelephone(telephone: string, callback: Function, context: Context,
    isFuzzyMatch = false, chatbotParameters?: ChatbotParameters): void {
    let result: LooseObject = {};
    if (telephone == null) {
      HiLog.w(TAG, 'querySessionByTelephone, telephone is null!');
      result.code = common.int.FAILURE;
      callback(result);
    } else {
      HiLog.i(TAG, 'querySessionByTelephone, telephone != null');
      let actionData: LooseObject = {};
      actionData.telephone = telephone;
      if (isFuzzyMatch) {
        actionData.isFuzzyMatch = true;
      }

      if (chatbotParameters?.isChatbotMessage) {
        actionData.isChatbotMessage = true;
        actionData.isFuzzyMatch = false;
      }
      if (actionData.telephone && actionData.telephone.length > 0 && actionData.telephone.includes(',')) {
        this.queryGroupSessionByTelephone(context, actionData, callback, result);
      } else {
        this.querySingleSessionByTelephone(context, actionData, callback, result, isFuzzyMatch);
      }
    }
  }

  private querySingleSessionByTelephone(context: Context, actionData: LooseObject, callback: Function, result: LooseObject,
    isFuzzyMatch: boolean) {
    this.querySessionByCondition(context, actionData, (res: ConversationListResponse) => {
      if (res.code == common.int.FAILURE) {
        HiLog.w(TAG, 'query session by telephone failse');
        callback(res);
      } else {
        HiLog.iw(TAG, 'query session by telephone success');
        result.code = common.int.SUCCESS;
        if (isFuzzyMatch) {
          result.response = TelephoneUtil.getTelephoneByFuzzMatch((res.abilityResult as ResponseType[]),
            actionData.telephone);
          if (!result.response) {
            HiLog.w(TAG, 'isFuzzyMatch query session by telephone success, but no has session in session db ');
          }
        } else {
          result.response = (res.abilityResult as ResponseType[])[0];
          if (!result.response) {
            HiLog.w(TAG, 'not isFuzzyMatch query session by telephone success, but no has session in session db ');
          }
        }
        callback(result);
      }
    });
  }

  private queryGroupSessionByTelephone(context: Context, actionData: LooseObject, callback: Function, result: LooseObject) {
    this.queryMatchedRecipient(context, actionData, (res: ConversationListResponse) => {
      if (res.code == common.int.FAILURE) {
        HiLog.w(TAG, 'query session by telephone failse');
        callback(res);
      } else {
        HiLog.i(TAG, 'query session by telephone success');
        result.code = common.int.SUCCESS;
        result.response = (res.abilityResult as ResponseType[])[0];
        if (!result.response) {
          HiLog.w(TAG, 'not isFuzzyMatch query session by telephone success, but no has session in session db ');
        }
        callback(result);
      }
    });
  }

  private checkMmsAttachmentOfRcs(item: mmsListType) {
    if (!item || !item.mmsSource) {
      return common.has_attachment.NO;
    }
    for (let index = 0; index < item.mmsSource.length; index++) {
      if (item.mmsSource[index].type !== commonData.MM_ATTACHMENT_TYPE.SMIL) {
        return common.has_attachment.HAVE;
      }
    }
    return common.has_attachment.NO;
  }

  private checkMmsAttachment(item: mmsListType) {
    if (!item || !item.mmsSource) {
      return common.has_attachment.NO;
    }
    for (let index = 0; index < item.mmsSource.length; index++) {
      if (item.mmsSource[index].ct?.includes('image') || item.mmsSource[index].ct?.includes('video') ||
      item.mmsSource[index].ct?.includes('media') || item.mmsSource[index].ct?.includes('audio') ||
      item.mmsSource[index].ct?.includes('text/x-vCard')) {
        return common.has_attachment.HAVE;
      }
      if (item.mmsSource?.[index]?.type === common.MM_ATTACHMENT_TYPE.IMAGE ||
        item.mmsSource?.[index]?.type === common.MM_ATTACHMENT_TYPE.VIDEO ||
        item.mmsSource?.[index]?.type === common.MM_ATTACHMENT_TYPE.AUDIO ||
        item.mmsSource?.[index]?.type === common.MM_ATTACHMENT_TYPE.VCARD ||
        item.mmsSource?.[index]?.type === common.MM_ATTACHMENT_TYPE.MAP) {
        return common.has_attachment.HAVE;
      }
    }
    return common.has_attachment.NO;
  }

  private getContentOfLastSmsMmsItem(lastSmsMmsItem: mmsListType) {
    if (!lastSmsMmsItem) {
      return '';
    }
    if (!lastSmsMmsItem.isMsm) {
      return lastSmsMmsItem.content;
    }
    if (isMmsMapMessageByMmsListType(false, lastSmsMmsItem)) { //彩信位置消息
      return '';
    }
    return lastSmsMmsItem.msgTitle;
  }

  private getContentOfLastRcsItem(lastRcsItem: mmsListType) {
    if (!lastRcsItem) {
      return '';
    }
    if (lastRcsItem.rcsType === commonData.ENHANCED_INFO_ITEM_TYPE.TEXT ||
      lastRcsItem.rcsType === commonData.ENHANCED_INFO_ITEM_TYPE.CHATBOT_CARD) {
      return lastRcsItem.content;
    }
    if (!lastRcsItem.mmsSource || !Array.isArray(lastRcsItem.mmsSource) || lastRcsItem.mmsSource.length === 0) {
      return '';
    }
    let richMessageSourceInfo = lastRcsItem.mmsSource.find(v => (v.type !== commonData.MM_ATTACHMENT_TYPE.SMIL));
    if (!richMessageSourceInfo) {
      return '';
    }

    let richMessageContent = '';
    if (MmsUtil.isAudio(richMessageSourceInfo.type) ||
      richMessageSourceInfo.type === common.ENHANCED_INFO_ITEM_TYPE.AUDIO_FILE ||
      lastRcsItem.rcsType === common.ENHANCED_INFO_ITEM_TYPE.IMAGE) {
      richMessageContent = richMessageSourceInfo.path || '';
    } else if (MmsUtil.isVideo(richMessageSourceInfo.type)) {
      richMessageContent = richMessageSourceInfo.path || '';
    } else if (MmsUtil.isVcard(richMessageSourceInfo.type)) {
      let contact = richMessageSourceInfo.contacts;
      let tempObj: SessionContentTypeOfRcs = {
        isSendMessage: 1,
        contactNum: contact?.length || 0,
        contactName: ''
      }
      let contactIndexSet = new Set(contact?.map(v => v.index));
      if (contactIndexSet.size === 1 && contact && contact[0]?.contactName) {
        tempObj.contactName = contact[0].contactName || '';
      }
      richMessageContent = JSON.stringify(tempObj);
    } else if (MmsUtil.isFile(richMessageSourceInfo.type)) {
      richMessageContent =
        richMessageSourceInfo.copyPath ? richMessageSourceInfo.copyPath : richMessageSourceInfo.path;
    } else if (MmsUtil.isRcsMap(richMessageSourceInfo.type) && richMessageSourceInfo.address) {
      let accuracy: number = 0;
      let arrLocInfo: string = richMessageSourceInfo.address.name + ';' + richMessageSourceInfo.address.address;
      let arrAddressInfo: [LooseObject] = [{
        'body': arrLocInfo,
        'longitude': richMessageSourceInfo.address.longitude.toString(),
        'latitude': richMessageSourceInfo.address.latitude.toString(),
        'accuracy': accuracy.toString(),
      }];
      let addressJson: string = JSON.stringify(arrAddressInfo);
      addressJson = addressJson.slice(1, -1);
      richMessageContent = addressJson;
    }
    return richMessageContent;
  }

  /**
   * 根据会话的消息列表的最后一条消息的数据更新会话数据
   * 主要用于在会话列表页面中的会话最新消息显示
   *
   * @param actionData
   * @param callback
   * @param context
   * @param isClearDraft 是否需要清除会话的草稿标记
   * @param messageCount 会话的消息总条数，不包括草稿
   */
  public updateLastItemContent(actionData: LooseObject, callback: Function, context: Context,
    isClearDraft?: boolean, messageCount?: number): void {
    let valueBucket: ValuesBucket = {
      content: common.STR.EMPTY_STR,
      time: 0,
      sending_status: common.int.SEND_MESSAGE_FAILED,
      has_mms: common.has_mms.NO,
      has_attachment: common.has_attachment.NO,
      message_count: (messageCount !== undefined && messageCount >= 0) ? messageCount : actionData.mmsList.length,
      // unread_count: 0
    };
    if (isClearDraft) {
      valueBucket.has_draft = common.has_draft.NO;
    }
    let length: number = actionData.mmsList.length;
    if (length > 0) {
      let item: LooseObject = actionData.mmsList[length - 1];
      let contentStr: string = item.content;
      valueBucket.content = (item?.isRcs) ? this.getContentOfLastRcsItem(item as mmsListType) as string :
          this.getContentOfLastSmsMmsItem(item as mmsListType) as string;
      valueBucket.time = item.timeMillisecond;
      valueBucket.sending_status = (item?.isRcs && item.sendStatus === common.int.RCS_SEND_CANCELED) ?
      common.int.SEND_MESSAGE_FAILED : item.sendStatus;
      valueBucket.has_mms = item.isMsm ? common.has_mms.HAVE : common.has_mms.NO;
      valueBucket.has_attachment = item?.isMsm ? (item.isRcs ? this.checkMmsAttachmentOfRcs(item as mmsListType) :
      this.checkMmsAttachment(item as mmsListType)) : common.has_attachment.NO;
      //如果当前分页查询未查完，会导致actionData.mmsList.length小于实际值，
      //如果更新成0，后续会在进入再次进入当前会话时插入正确的值
    }
    let condition: Record<string,number> = {
      'threadId': actionData.threadId
    };
    this.updateSessionByCondition(context, condition, valueBucket, callback);
  }

  public querySessionLikeTelephone(object: LooseObject, callback: Function, context: Context): void {
    HiLog.i(TAG, 'querySessionLikeTelephone');
    let actionData: LooseObject = {};
    actionData.telephone_like = object.input;
    if (object.smsType === 1) {
      actionData.smsType = object.smsType;
    }
    this.getSessionResult(actionData, callback, context);
  }

  public querySessionByTelephones(contactResult: LooseObject, object: LooseObject,
    callback: Function, context: Context): void {
    HiLog.i(TAG, 'querySessionByTelephones');
    let telephones: Array<string> = [];
    contactResult.forEach((item: LooseObject) => {
      telephones.push(item.detailInfo);
    });
    let actionData: LooseObject = {};
    actionData.telephones = telephones;
    if (object.smsType === 1) {
      actionData.smsType = object.smsType;
    }
    this.getSessionResult(actionData, callback, context);
  }

  private getSessionResult(actionData: LooseObject, callback: Function, context: Context) {
    this.querySessionByCondition(context, actionData, async (res: ConversationListResponse) => {
      if (res.code == common.int.FAILURE) {
        callback(res);
      } else {
        let result: LooseObject = {};
        result.code = common.int.SUCCESS;
        let sessionObj: ResultObj = {
          messageList: [],
          telephones: []
        };
        if (res.code == common.int.SUCCESS && res.abilityResult != null) {
          sessionObj = this.dealQuerySessionByConditionDetails(context, sessionObj, res, actionData, result, callback);
        } else {
          callback(result);
        }
      }
    });
  }

  private dealQuerySessionByConditionDetails(context: Context,
    sessionObj: ResultObj, res: ConversationListResponse, actionData: LooseObject, result: LooseObject,
    callback: Function) {
    sessionObj = this.getConvertSessionListResult(res.abilityResult);
    this.dealContactsName(sessionObj.telephones, actionData, sessionObj.messageList, (res: LooseObject[]) => {
      sessionObj.messageList = res;
      this.dealYellowPageNameSecond(sessionObj.telephones,
        actionData, sessionObj.messageList, (res1: LooseObject) => {
          result.sessionList = res1;
          HiLog.i(TAG, 'querySessionResultByCondition,res:' + res1.length);
          callback(result);
        }, context);
    }, context);
    return sessionObj;
  }

  public updateSessionUnReadBySessionId(actionData: LooseObject, va: ValuesBucket, callback: Function, context: Context): void {
    if (GlobalContext.getContext().getObject('DataWorker') != null) {
      (GlobalContext.getContext().getObject('DataWorker') as WorkerWrapper)
        .sendRequest(common.RUN_IN_WORKER_METHOD.updateSessionUnReadBySessionId, {
        actionData: actionData,
        valueBucket: va,
        context: context
      } as GlobalThisType, (res: Object) => {
        callback(res);
      });
    } else {
      this.conversationListModel.updateSessionUnReadBySessionId(actionData, va, callback, context);
    }
  }

  public processBatchRead(context: Context, actionData: Record<string, string>, callback?: Function | null): void {
    if (GlobalContext.getContext().getObject('DataWorker') != null) {
      (GlobalContext.getContext().getObject('DataWorker') as WorkerWrapper).sendRequest(common.RUN_IN_WORKER_METHOD.processMarkRead, {
        actionData: actionData,
        context: context
      } as GlobalThisType, (res: Object) => {
        if (callback) {
          callback(res);
        }
      });
    } else {
      this.conversationListModel.processMarkRead(actionData, context, callback);
    }
  }

  public batchUpdateSessionByCondition(conditions: Record<string, string | number>[],
    valueBuckets: ValuesBucket[], callback: Function, context: Context): void {
    let actionData: LooseObject = {
      'conditions': conditions,
      'valueBuckets': valueBuckets
    }
    if (GlobalContext.getContext().getObject('DataWorker') != null) {
      (GlobalContext.getContext().getObject('DataWorker') as WorkerWrapper).sendRequest(common.RUN_IN_WORKER_METHOD.batchUpdateSessionByCondition, {
        actionData: actionData,
        context: context
      } as GlobalThisType, (res: Object) => {
        callback(res);
      });
    } else {
      this.conversationListModel.batchUpdateSessionByCondition(context, conditions, valueBuckets, callback);
    }
  }

  public updateAttachmentByCondition(actionData: LooseObject, valueBucket: ValuesBucket,
    context: Context): void {
    if (GlobalContext.getContext().getObject('DataWorker') != null) {
      (GlobalContext.getContext().getObject('DataWorker') as WorkerWrapper)
        .sendRequest(common.RUN_IN_WORKER_METHOD.updateAttachmentByCondition, {
        actionData: actionData,
        valueBucket: valueBucket,
        context: context
      } as GlobalThisType);
    } else {
      this.conversationListModel.updateAttachmentByCondition(actionData, valueBucket, context);
    }
  }

  public updateSessionPinningTime(sessionId: number, time: number, callback: Function, context: Context): void {
    let actionData: LooseObject = {};
    actionData.sessionId = sessionId;
    const valueBucket: ValuesBucket = {
      'pinning_time': time
    }
    this.updateSessionPinningTimeBySessionId(actionData, valueBucket, callback, context)
  }

  public updateSessionPinningTimeBySessionId(actionData: LooseObject, valueBucket: ValuesBucket, callback: Function,
    context: Context): void {
    if (GlobalContext.getContext().getObject('DataWorker') != null) {
      (GlobalContext.getContext().getObject('DataWorker') as WorkerWrapper)
        .sendRequest(common.RUN_IN_WORKER_METHOD.updateSessionPinningTimeBySessionId, {
          actionData: actionData,
          valueBucket: valueBucket,
          context: context
      } as GlobalThisType, () => {
        callback();
      });
    } else {
      this.conversationListModel.updateSessionByPinningTime(actionData, valueBucket, callback, context);
    }
  }

  /**
   * 在向服务器请求应用号详情后，根据应用号名称更新会话表
   * @param context Context
   * @param contactName 会话的联系人名称
   * @param serviceId 应用号的服务器ID
   */
  public async updateSessionAfterRequestChatbot(context: Context, contactName: string, serviceId: string) {
    if (GlobalContext.getContext().getObject('DataWorker') != null) {
      HiLog.i(TAG, 'updateSessionAfterRequestChatbot with worker');
      (GlobalContext.getContext().getObject('DataWorker') as WorkerWrapper)
        .sendRequest(common.RUN_IN_WORKER_METHOD.updateSessionAfterRequestChatbot, {
          context: context,
          contactName: contactName,
          serviceId: serviceId
        } as ParamsOfUpdateSessionAfterRequestChatbot, (res) => {
          HiLog.i(TAG, 'updateSessionAfterRequestChatbot with worker callback, result: ' + res);
          if (res) {
            //会话名称变更刷新会话列表
            GlobalContext.getContext().setObject('needToUpdate', true);
          }
        });
    } else {
      let res = await ConversationListModel.updateSessionAfterRequestChatbot(context, contactName, serviceId);
      if (res) {
        //会话名称变更刷新会话列表
        GlobalContext.getContext().setObject('needToUpdate', true);
      }
    }
  }

  /**
   * 更新指定sessionId的会话
   * @param context Context
   * @param sessionId 会话Id
   * @param valueBucket 要更新的数据
   * @param callback 返回更新结果的回调函数
   * @param needUpdateSessionList 是否需要从数据库重新读取数据以更新会话列表
   */
  public updateSessionBySessionId(context: Context, sessionId: number, valueBucket: ValuesBucket,
    callback: Function | null, needUpdateSessionList?: boolean): void {
    let actionData: LooseObject = {};
    actionData.sessionId = sessionId;
    if (GlobalContext.getContext().getObject('DataWorker') != null) {
      (GlobalContext.getContext().getObject('DataWorker') as WorkerWrapper)
        .sendRequest(common.RUN_IN_WORKER_METHOD.updateSessionBySessionId, {
          actionData: actionData,
          valueBucket: valueBucket,
          context: context
        } as GlobalThisType, (res: Object) => {
          if (callback) {
            callback(res);
          }
        });
    } else {
      this.conversationListModel.updateSessionContent(actionData, valueBucket, callback, context);
    }
    //因不能确定所有调用场景是否都需要更改此参数，故通过条件判断
    if (needUpdateSessionList) {
      GlobalContext.getContext().setObject('needToUpdate', true)
    }
  }
}