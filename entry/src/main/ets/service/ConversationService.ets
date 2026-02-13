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

import ConversationModel, { queryContactsAvatarInContactDataDataBase } from '../model/ConversationModel';
import ConversationRcsModel from '../model/ConversationRcsModel';
import common, { SmsGroupRcsInfo } from '../data/commonData';
import HiLog from '../utils//HiLog';
import ConversationListService, { ResObj } from './ConversationListService';
import TelephoneUtil from '../utils/TelephoneUtil';
import ContactsService from './ContactsService';
import LooseObject from '../data/LooseObject';
import { GlobalContext } from '../MainAbility/GlobalHelper';
import { WorkerWrapper } from '../workers/base/WorkerWrapper';
import myCommon from '@ohos.app.ability.common';
import { ValuesBucket } from '@ohos.data.ValuesBucket';
import ConversationListController, { messageType } from '../pages/conversationlist/conversationListController';
import { resType } from './MmsSearchService';
import  ConversationRcsService  from './ConversationRcsService';
import call from '@ohos.telephony.call';
import MmsUtil, { getIsMmsMapMessageByMmsSource } from '../utils/MmsUtil';
import { Mms } from '../utils/TypesUtils';
import commonData from '../data/commonData';
import DateUtil from '../utils/DateUtil';
import { SessionContactInfoForDB } from '../pages/conversation/conversationController';
import StringUtil from '../utils/StringUtil';
import hiTraceMeter from '@ohos.hiTraceMeter';
import TraceConstant from '../data/TraceConstant';
import BlockedUtil from '../utils/BlockedUtil';
import Constant from '../data/Constant';
import { EnhancedInfoTemporaryDataSource } from '../model/EnhancedInfoTemporaryDataSource';
import json from '@ohos.util.json';
import dotCommon, { dotNoNeedParmas } from '../utils/MmsDot/DotCommon';
import DotUtil from '../utils/MmsDot/DotUtils';
import SsmUtils from '../utils/SsmUtils';
import util from '@ohos.util';
import { HashMap, JSON, taskpool } from '@kit.ArkTS';
import { systemDateTime } from '@kit.BasicServicesKit';
import LocationUtil from '../utils/LocationUtil';
import { ChatbotParameters } from '../chatbot/utils/ChatbotEntitys';
import SharedPreferencesUtils from '../utils/SharedPreferencesUtils';
import ConversationIpService from './ConversationIpService';
import ObjectUtil from '../utils/ObjectUtil';
import MmsPartModel from '../model/MmsPartModel';

interface ConversationServiceParamType {
  valueBucket: ValuesBucket,
  context: Context
  actionData: LooseObject
}

export interface queryMmsInfoResult {
  code: number,
  abilityResult: Array<Record<string, number | string>>
}

const TAG: string = 'ConversationService';

export class ExpireQuerySessionCache {
  // 提供一种电话号码超时机制
  //
  private ttlOfMS: number = 500; //缓存超时时间，单位ms
  private keyOfPhoneCache: Record<string, number> = {}

  /*
   * 第一次电话号码查询时间
   * */
  public isNeedWait500MS(targetPhone: string): boolean {
    let currentTimeValue = systemDateTime.getTime(false);
    let sourceTimeValue = this.keyOfPhoneCache[targetPhone]
    if (!sourceTimeValue) {
      //没有阻拦过当前电话号码,默认放行。
      //之后的ttl ms时间之内,都是不放行的。
      HiLog.i(TAG,
        '[ExpireQuerySessionCache] [first query] ' + ' first query time [currentTimeValue] :' +
        String(currentTimeValue))
      this.keyOfPhoneCache[targetPhone] = currentTimeValue
      return false
    }
    if (Math.abs(currentTimeValue - sourceTimeValue) > this.ttlOfMS) {
      HiLog.i(TAG, '[ExpireQuerySessionCache] [ttl query] first query time [sourceTimeValue] :' +
      String(sourceTimeValue) + ' [currentTimeValue]: ' + String(currentTimeValue))
      return false
    }
    HiLog.i(TAG,
      '[ExpireQuerySessionCache] [need waiting]: is ttl no need wait : sourceTimeValue ' +
      String(sourceTimeValue) + ' [currentTimeValue]: ' + String(currentTimeValue))
    return true
  }

  public releasePhone(targetPhone: number) {

  }
}

export default class ConversationService {
  private static instance: ConversationService;
  private querySessionCache: ExpireQuerySessionCache;
  private conversationModel: ConversationModel = new ConversationModel();
  private conversationRcsModel: ConversationRcsModel =new ConversationRcsModel();
  private mmsPartModel: MmsPartModel = new MmsPartModel();
  public maxGroupId: number = 0;

  private constructor() {
    this.querySessionCache = new ExpireQuerySessionCache()
  }

  public static getInstance(): ConversationService {
    if (ConversationService.instance == null) {
      ConversationService.instance = new ConversationService();
    }
    return ConversationService.instance;
  }

  public static getTestInstance(): ConversationService {
    return new ConversationService();
  }

  public insertSmsMmsInfo(valueBucket: ValuesBucket, callback: Function, context: Context): void {
    if (valueBucket.session_id === null && StringUtil.isEmpty(valueBucket.msg_content as string)) {
      HiLog.w(TAG, ' insert emty message to SmsMmsInfo ')
      return;
    }
    HiLog.iw(TAG, `insertSmsMmsInfo sessionId is ${valueBucket.session_id}`)
    if (GlobalContext.getContext().getObject('DataWorker') != null) {
      (GlobalContext.getContext()
        .getObject('DataWorker') as WorkerWrapper).sendRequest(common.RUN_IN_WORKER_METHOD.insertSmsMmsInfo, {
        valueBucket: valueBucket,
        context: context
      } as ConversationServiceParamType, (res?: Object) => {
        if (callback) {
          callback(res);
        }
      });
    } else {
      this.conversationModel.insertSmsMmsInfo(valueBucket, callback, context);
    }
  }

  public deleteSmsMmsInfoPagination(context: Context, actionData: LooseObject, callback: Function | null): void {
    if (actionData.threadIds != null && actionData.threadIds.length > common.int.DELETE_PAGINATION_LENGTH) {
      HiLog.i(TAG, ' deleteDialogConfirm deleteSmsMmsInfoByCondition threadIds.length:' + actionData.threadIds.length)
      let threadIds: number[] = actionData.threadIds;
      for (let index = 0; index < threadIds.length; index += common.int.DELETE_PAGINATION_LENGTH) {
        let threadIdsTemp = threadIds.slice(index, index + common.int.DELETE_PAGINATION_LENGTH);
        actionData.threadIds = threadIdsTemp;
        HiLog.i(TAG, ' deleteDialogConfirm deleteSmfsMmsInfoByCondition index :' + index)
        this.deleteSmsMmsInfoByThreadId(context, actionData, callback);
      }
    } else {
      this.deleteSmsMmsInfoByThreadId(context, actionData, callback);
    }
  }

  //上面方法重写
  public deleteJnSmsMmsInfoPagination(context: Context, actionData: LooseObject, callback: Function | null): void {
    HiLog.i(TAG, ' deleteDialogConfirm deleteSmsMmsInfoByCondition index :' )
    if (actionData.uncheckedThreadIds != null &&
      actionData.uncheckedThreadIds.length > common.int.DELETE_PAGINATION_LENGTH) {
      HiLog.i(TAG, ' deleteDialogConfirm deleteJnSmsMmsInfoPagination length:' + actionData.uncheckedThreadIds.length)
      let threadIds: number[] = actionData.uncheckedThreadIds;
      for (let index = 0; index < threadIds.length; index += common.int.DELETE_PAGINATION_LENGTH) {
        let threadIdsTemp = threadIds.slice(index, index + common.int.DELETE_PAGINATION_LENGTH);
        actionData.uncheckedThreadIds = threadIdsTemp;
        HiLog.i(TAG, ' deleteDialogConfirm deleteSmsMmsInfoByCondition index :' + index)
        this.deleteSmsMmsInfoByJnThreadId(context, actionData, callback);
      }
    } else {
      this.deleteSmsMmsInfoByJnThreadId(context, actionData, callback);
    }
  }

  /**
   *  列表页批量删除会话调用
   *  1. 只查询彩信数据，根据groupId 批量删除彩信
   *  2. 删除sms_info
   *  3. 删除增强信息相关
   * @param actionData
   * @param callback
   * @param context
   */
  public deleteSmsMmsInfoByThreadId(context: Context, actionData: LooseObject, callback: Function | null, ): void {
    HiLog.i(TAG, 'deleteSmsMmsInfoByThreadIds begin');
    if (actionData.threadIds == null || actionData.threadIds.length == 0) {
      return;
    }
    HiLog.w(TAG, 'deleteSmsMmsInfoByThreadIds delete thread id is:' + JSON.stringify(actionData.threadIds));
    let actionDataTemp: LooseObject = {};
    actionDataTemp.threadIds = actionData.threadIds;
    actionDataTemp.msgType = common.MSG_TYPE.MMS;
    this.querySmsMmsInfoByCondition(context, actionDataTemp, (response: resType) => {
      if (response.code === common.int.SUCCESS && response.abilityResult && response.abilityResult.length > 0) {
        let groupIds: number[] = [];
        response.abilityResult.forEach((res) => {
          (res.msgType === common.MSG_TYPE.MMS) && groupIds.push(res.groupId);
        })
        let mmsActionData: LooseObject = {};
        if (groupIds.length > 0) {
          mmsActionData.groupIds = groupIds;
          HiLog.i(TAG, 'deleteSmsMmsInfoByCondition session mms delete----' + JSON.stringify(groupIds));
          this.deleteMmsInfoByCondition(context, mmsActionData, callback);
        }
      }
      this.deleteSmsInfoByCondition(context, actionData, callback);
    });
  }

  //上面方法重写
  public deleteSmsMmsInfoByJnThreadId(context: Context, actionData: LooseObject, callback: Function | null): void {
    HiLog.i(TAG, 'deleteSmsMmsInfoByJnThreadId begin');

    HiLog.w(TAG, 'deleteSmsMmsInfoByJnThreadId delete thread id is:' + JSON.stringify(actionData.threadIds));
    let actionDataTemp: LooseObject = {};
    if (actionData.uncheckedThreadIds !== null) {
      actionDataTemp.uncheckedThreadIds = actionData.uncheckedThreadIds;
    }
    actionDataTemp.msgType = common.MSG_TYPE.MMS;
    this.querySmsMmsInfoByCondition(context, actionDataTemp, (response: resType) => {
      if (response.code === common.int.SUCCESS && response.abilityResult && response.abilityResult.length > 0) {
        let groupIds: number[] = [];
        response.abilityResult.forEach((res) => {
          (res.msgType === common.MSG_TYPE.MMS) && groupIds.push(res.groupId);
        })
        let mmsActionData: LooseObject = {};
        if (groupIds.length > 0) {
          mmsActionData.groupIds = groupIds;
          HiLog.i(TAG, 'deleteSmsMmsInfoByCondition session mms delete----' + JSON.stringify(groupIds));
          this.deleteMmsInfoByCondition(context, mmsActionData, callback);
        }
      }
      this.deleteSmsInfoByCondition(context, actionData, callback);
    });
  }

  public deleteSmsMmsInfoByCondition(context: Context, actionData: LooseObject, callback: Function | null): void {
    HiLog.i(TAG, 'deleteSmsMmsInfoByCondition begin');
    if (actionData.threadIds && actionData.threadIds.length > 0) {
      HiLog.w(TAG, 'deleteSmsMmsInfoByCondition delete thread id is:' + JSON.stringify(actionData.threadIds));
      this.querySmsMmsInfoByCondition(context, actionData, (response: resType) => {
        if (response.code === common.int.SUCCESS && response.abilityResult && response.abilityResult.length > 0) {
          response.abilityResult.forEach((res) => {
            if (res.msgType === 1) {
              let groupId: number = res.groupId;
              let mmsActionData: Record<string, number> = {
                'groupId': groupId
              };
              HiLog.i(TAG, 'deleteSmsMmsInfoByCondition session mms delete----' + JSON.stringify(mmsActionData));
              this.deleteMmsInfoByCondition(context, mmsActionData, callback);
            }
          })
        }
        this.deleteSmsInfoByCondition(context, actionData, callback);
      });
    } else if (actionData.isDraft) {
      HiLog.i(TAG, 'deleteSmsMmsInfoByCondition content draft delete');
      this.deleteSmsInfoByCondition(context, actionData, callback);
    } else {
      if(actionData.groupIds?.length>0 || actionData.groupId!==undefined || actionData.msgId !== undefined) {
        this.deleteSmsInfoByCondition(context, actionData, callback);
      }
      if(actionData.smsType !== undefined  && actionData.currentTimeStamp !== undefined) {
        this.deleteSmsInfoByCondition(context, actionData, callback);
      }
      if (actionData.isFromGroupInfos) {
        this.deleteMmsPartInfo(actionData, context);
      } else {
        this.deleteMmsInfoByCondition(context, actionData, callback);
      }
    }
  }

  private async deleteMmsPartInfo(actionData: LooseObject, context: Context) {
    if (!actionData || !context) {
      HiLog.e(TAG, `deleteMmsPartInfo param invalid`);
      return;
    }
    // 构建需要删除part表信息
    let groupIdIsMms: number[] = actionData.groupIdIsMms || [];
    let rcsIdIsMms: number[] = actionData.rcsIdIsMms || [];
    let groupIdIsCollect: number[] = actionData.groupIdIsCollect || [];
    let rcsIdIsCollect: number[] = actionData.rcsIdIsCollect || [];
    let groupIdNeedDeleteFile: number[] = actionData.groupIdNeedDeleteFile || [];
    let rcsIdNeedDeleteFile: number[] = actionData.rcsIdNeedDeleteFile || [];
    HiLog.i(TAG, `deleteMmsPartInfo param groupIdIsMms: ${groupIdIsMms?.toString()}`);
    HiLog.i(TAG, `deleteMmsPartInfo param rcsIdIsMms: ${rcsIdIsMms?.toString()}`);
    HiLog.i(TAG, `deleteMmsPartInfo param groupIdIsCollect: ${groupIdIsCollect?.toString()}`);
    HiLog.i(TAG, `deleteMmsPartInfo param rcsIdIsCollect: ${rcsIdIsCollect.toString()}`);
    HiLog.i(TAG, `deleteMmsPartInfo param groupIdNeedDeleteFile: ${groupIdNeedDeleteFile?.toString()}`);
    HiLog.i(TAG, `deleteMmsPartInfo param rcsIdNeedDeleteFile: ${rcsIdNeedDeleteFile?.toString()}`);
    if (groupIdIsMms.length === 0 && rcsIdIsMms.length === 0) {
      HiLog.w(TAG, `deleteMmsPartInfo groupIdIsMms and rcsIdIsMms is empty`);
      return;
    }
    // 构建需要删除的groupIds消息
    let smsGroupIds: SmsGroupRcsInfo[] = [];
    let smsGroup: SmsGroupRcsInfo;
    for (let groupId of groupIdIsMms) {
      smsGroup = new SmsGroupRcsInfo();
      smsGroup.msgId = groupId;
      if (groupIdIsCollect.includes(groupId)) {
        smsGroup.isCollect = commonData.is_collect.FAVORITE;
      } else {
        smsGroup.isCollect = commonData.is_collect.NOT_FAVORITE;
      }
      smsGroup.isNeedDeleteFile = groupIdNeedDeleteFile.includes(groupId);
      smsGroupIds.push(smsGroup);
    }
    // 构建需要删除的rcsInfo消息
    let rcsInfos: SmsGroupRcsInfo[] = [];
    let rcsInfo: SmsGroupRcsInfo;
    for (let rcsId of rcsIdIsMms) {
      rcsInfo = new SmsGroupRcsInfo();
      rcsInfo.msgId = rcsId;
      if (rcsIdIsCollect.includes(rcsId)) {
        rcsInfo.isCollect = commonData.is_collect.FAVORITE;
      } else {
        rcsInfo.isCollect = commonData.is_collect.NOT_FAVORITE;
      }
      rcsInfo.isNeedDeleteFile = rcsIdNeedDeleteFile.includes(rcsId);
      rcsInfos.push(rcsInfo);
    }
    this.mmsPartModel.deleteByGroupIdOrRcsIds(smsGroupIds, rcsInfos, context);
  }

  public deleteSmsInfoByCondition(context: Context, actionData: LooseObject, callback: Function | null): void {
    if (GlobalContext.getContext().getObject('DataWorker') != null) {
      (GlobalContext.getContext()
        .getObject('DataWorker') as WorkerWrapper).sendRequest(common.RUN_IN_WORKER_METHOD.deleteSmsMmsInfoByCondition, {
        actionData: actionData,
        context: context
      } as ConversationServiceParamType, (res?: Object) => {
        if (callback) {
          callback(res);
        }
      });
    } else {
      this.conversationModel.deleteSmsMmsInfoByCondition(actionData, callback, context);
    }
  }

  public updateSmsMmsInfoByCondition(context: Context, actionData: LooseObject, valueBucket: ValuesBucket,
    callback?: Function | null): void {
    if (GlobalContext.getContext().getObject('DataWorker') != null) {
      (GlobalContext.getContext()
        .getObject('DataWorker') as WorkerWrapper).sendRequest(common.RUN_IN_WORKER_METHOD.updateSmsMmsInfoByCondition, {
        actionData: actionData,
        valueBucket: valueBucket,
        context: context
      } as ConversationServiceParamType, (res?: Object) => {
        if (callback) {
          callback(res);
        }
      });
    } else {
      this.conversationModel.updateSmsMmsInfoByCondition(actionData, valueBucket, callback as Function, context);
    }
  }

  //仅用于批量更新 短/彩信发送状态
  public updateSmsMmsInfoStateByCondition(context: Context, actionData: LooseObject, valueBucket: ValuesBucket,
    callback?: Function | null): void {
    if (GlobalContext.getContext().getObject('DataWorker') != null) {
      (GlobalContext.getContext()
        .getObject('DataWorker') as WorkerWrapper).sendRequest(common.RUN_IN_WORKER_METHOD.updateSmsMmsInfoByCondition,
        {
          actionData: actionData,
          valueBucket: valueBucket,
          context: context
        } as ConversationServiceParamType, (res?: Object) => {
          if (callback) {
            callback(res);
          }
        });
    } else {
      this.conversationModel.updateSmsMmsInfoStateByCondition(actionData, valueBucket, callback as Function, context);
    }
  }

  public querySmsMmsInfoSlotIdByCondition(context: Context, phoneNumber: string, callback: Function): void {
    let actionData: Record<string, string> = {'phoneNumber': phoneNumber}
    if (GlobalContext.getContext().getObject('DataWorker') != null) {
      (GlobalContext.getContext().getObject('DataWorker') as WorkerWrapper).sendRequest(common.RUN_IN_WORKER_METHOD.querySmsMmsInfoSlotIdByCondition, {
        actionData: actionData,
        context: context
      } as ConversationServiceParamType, (res?: Object) => {
        callback(res);
      })
    } else {
      this.conversationModel.querySmsMmsInfoSlotIdByCondition(phoneNumber, callback, context);
    }
  }

  public querySmsMmsInfoByCondition(context: Context, actionData: LooseObject, callback: Function): void {
    if (GlobalContext.getContext().getObject('DataWorker') != null) {
      (GlobalContext.getContext()
        .getObject('DataWorker') as WorkerWrapper).sendRequest(common.RUN_IN_WORKER_METHOD.querySmsMmsInfoByCondition, {
        actionData: actionData,
        context: context
      } as ConversationServiceParamType, (res?: Object) => {
        callback(res);
      });
    } else {
      this.conversationModel.querySmsMmsInfoByCondition(actionData, callback, context);
    }
  }

  public querySmsMmsInfoByConditionAsync(context: Context, actionData: LooseObject): Promise<resType> {
    return new Promise((resolve) => {
      this.querySmsMmsInfoByCondition(context, actionData, (res: resType) => {
        resolve(res);
      });
    });
  }

  public querySmsMmsInfoByConditionAll(context: Context, actionData: LooseObject, callback: Function): void {
    if (GlobalContext.getContext().getObject('DataWorker') != null) {
      (GlobalContext.getContext()
        .getObject('DataWorker') as WorkerWrapper).sendRequest(common.RUN_IN_WORKER_METHOD.querySmsMmsInfoByConditionAll, {
        actionData: actionData,
        context: context
      } as ConversationServiceParamType, (res?: Object) => {
        callback(res);
      });
    } else {
      this.conversationModel.querySmsMmsInfoByConditionAll(actionData, callback, context);
    }
  }

  public queryMmsInfoByFavoriteCondition(context: Context, actionData: LooseObject, callback: Function): void{
    if (GlobalContext.getContext().getObject('DataWorker') != null) {
      (GlobalContext.getContext()
        .getObject('DataWorker') as WorkerWrapper).sendRequest(common.RUN_IN_WORKER_METHOD.queryMmsInfoByFavoriteCondition, {
        actionData: actionData,
        context: context
      } as ConversationServiceParamType, (res?: Object) => {
        callback(res);
      });
    } else {
      this.conversationModel.queryMmsInfoByFavoriteCondition(actionData, callback, context);
    }
  }

  public queryMmsInfoLastReadCondition(context: Context, actionData: LooseObject, callback: Function): void{
    if (GlobalContext.getContext().getObject('DataWorker') != null) {
      (GlobalContext.getContext()
        .getObject('DataWorker') as WorkerWrapper).sendRequest(common.RUN_IN_WORKER_METHOD.queryMmsInfoLastReadCondition, {
        actionData: actionData,
        context: context
      } as ConversationServiceParamType, (res?: Object) => {
        callback(res);
      });
    } else {
      this.conversationModel.queryMmsInfoLastReadMsgCondition(actionData, callback, context);
    }
  }

    public queryAllInfoByFavorite(context: Context, actionData: LooseObject, callback: Function): void {
        HiLog.i(TAG, 'queryAllInfoByFavorite In:')
        this.queryAllInfoByFavoriteCondition(context, actionData, (res1: resType) => {
            this.queryFavoriteMessageDetailResultAll(res1, actionData, callback, context, 0);
        });
    }

  public queryAllInfoByFavoriteCondition(context: Context, actionData: LooseObject, callback: Function): void{
    if (GlobalContext.getContext().getObject('DataWorker') != null) {
      (GlobalContext.getContext()
        .getObject('DataWorker') as WorkerWrapper).sendRequest(common.RUN_IN_WORKER_METHOD.queryAllInfoByFavoriteCondition, {
        actionData: actionData,
        context: context
      } as ConversationServiceParamType, (res?: Object) => {
        callback(res);
      });
    } else {
      this.conversationModel.queryAllInfoByFavoriteCondition(actionData, callback as Function, context);
    }
  }

  public querySmsMmsInfoSizeByCondition(actionData: LooseObject, callback: Function, context: Context): void {
    if (GlobalContext.getContext().getObject('DataWorker') != null) {
      (GlobalContext.getContext()
        .getObject('DataWorker') as WorkerWrapper).sendRequest(common.RUN_IN_WORKER_METHOD.querySmsMmsInfoSizeByCondition, {
        actionData: actionData,
        context: context
      } as ConversationServiceParamType, (res?: Object) => {
        callback(res);
      });
    } else {
      this.conversationModel.querySmsMmsInfoSizeByCondition(actionData, callback, context);
    }
  }

  public async queryAllInfoSizeByCondition(context: Context, actionData: LooseObject): Promise<number> {
    let promisesAll: Promise<number>[] = [];
    let smsMmsTotal: Promise<number> = new Promise((resolve) => {
      actionData.noRcs = true;
      this.querySmsMmsInfoSizeByCondition(actionData, (res: LooseObject) => {
        let smsMmsTotalRes: number = 0;
        if (res.code == common.int.SUCCESS && res.abilityResult != null) {
          smsMmsTotalRes = res.abilityResult;
        }
        resolve(smsMmsTotalRes);
      }, context);
    });
    let rcsTotal: Promise<number> = new Promise((resolve) => {
      actionData.notNeedBlock = true;
      ConversationRcsService.getInstance().queryRcsInfoSizeByCondition(actionData, (res: LooseObject) => {
        let rcsTotalRes: number = 0;
        if (res.code == common.int.SUCCESS && res.abilityResult != null) {
          rcsTotalRes = res.abilityResult;
        }
        resolve(rcsTotalRes);
      }, context);
    });
    promisesAll.push(smsMmsTotal);
    promisesAll.push(rcsTotal);
    let allInfoSizeRes = Promise.all(promisesAll);
    let allInfoSize: number = 0;
    allInfoSizeRes.then((smsMmsRcsCounts: number[]) => {
      allInfoSize = smsMmsRcsCounts[0] + smsMmsRcsCounts[1];
    });
    await allInfoSizeRes;
    HiLog.w(TAG,
      `[queryAllInfoSizeByCondition] allInfoSize: ${allInfoSize}, smsMmsTotal: ${smsMmsTotal}, rcsTotal: ${rcsTotal}}`);
    return allInfoSize;
  }

  public async getSmsMmsInfoSizeByCondition(actionData: LooseObject, context: Context): Promise<number> {
    actionData.page = null;
    let result: Promise<number> = new Promise((resolve) => {
      this.querySmsMmsInfoSizeByCondition(actionData, (res: LooseObject) => {
        let size: number = 0;
        if (res.code == common.int.SUCCESS && res.abilityResult != null) {
          size = res.abilityResult;
        }
        resolve(size);
      }, context);
    });
    return result;
  }

  public async getRcsMmsInfoSizeByCondition(actionData: LooseObject, context: Context): Promise<number> {
    actionData.page = null;
    let result: Promise<number> = new Promise((resolve) => {
      ConversationRcsService.getInstance().queryRcsInfoSizeByCondition(actionData, (res2: LooseObject) => {
        let size: number = 0;
        if (res2?.code == common.int.SUCCESS && res2?.abilityResult != null) {
          size = res2?.abilityResult;
        }
        resolve(size);
      }, context);
    });
    return result;
  }

  public statisticalData(callback: Function, context: Context) {
    if (GlobalContext.getContext().getObject('DataWorker') != null) {
      (GlobalContext.getContext()
        .getObject('DataWorker') as WorkerWrapper).sendRequest(common.RUN_IN_WORKER_METHOD.statisticalData, {
        context: context
      } as ConversationServiceParamType, (res?: Object) => {
        callback(res);
      });
    } else {
      this.conversationModel.statisticalData(callback, context);
    }
  }

  public selectInfoCount(callback: Function, context: Context) {
    if (GlobalContext.getContext().getObject('DataWorker') != null) {
      (GlobalContext.getContext()
        .getObject('DataWorker') as WorkerWrapper).sendRequest(common.RUN_IN_WORKER_METHOD.selectInfoCount, {
        context: context
      } as ConversationServiceParamType, (res?: Object) => {
        callback(res);
      });
    } else {
      this.conversationModel.selectInfoCount(callback, context);
    }
  }

  public async getSmsInfoCount(context: Context): Promise<number> {
    let result: Promise<number> = new Promise((resolve) => {
      this.selectInfoCount((res: LooseObject) => {
        let smsInfoCount: number = 0;
        if (res.code == common.int.SUCCESS && res.abilityResult != null) {
          smsInfoCount = (res.abilityResult.msgNumTotal as number);
        }
        resolve(smsInfoCount);
      }, context);
    });
    return result;
  }

  public selectContactId(callback: Function, context: Context) {
    if (GlobalContext.getContext().getObject('DataWorker') != null) {
      (GlobalContext.getContext()
        .getObject('DataWorker') as WorkerWrapper).sendRequest(common.RUN_IN_WORKER_METHOD.selectContactId, {
        context: context
      } as ConversationServiceParamType, (res?: Object) => {
        callback(res);
      });
    } else {
      this.conversationModel.selectContactId(callback, context);
    }
  }

  public async getContactId(context: Context): Promise<Map<string, string>> {
    let result: Promise<Map<string, string>> = new Promise((resolve) => {
      this.selectContactId((res: LooseObject) => {
        let map = new Map<string, string>();
        if (res.code == common.int.SUCCESS && res.abilityResult != null) {
          map = res.abilityResult;
        }
        resolve(map);
      }, context);
    });
    return result;
  }

  public queryMaxGroupId(callback: Function, context: Context): void {
    if (GlobalContext.getContext().getObject('DataWorker') != null) {
      (GlobalContext.getContext()
        .getObject('DataWorker') as WorkerWrapper).sendRequest(common.RUN_IN_WORKER_METHOD.queryMaxGroupId, {
        context: context
      } as ConversationServiceParamType, (res?: Object) => {
        callback(res);
      });
    } else {
      this.conversationModel.queryMaxGroupId(callback, context);
    }
  }

  public queryMaxGroupIdRcs(callback: Function, context: Context): void {
    if (GlobalContext.getContext().getObject('DataWorker') != null) {
      (GlobalContext.getContext()
        .getObject('DataWorker') as WorkerWrapper).sendRequest(common.RUN_IN_WORKER_METHOD.queryMaxGroupIdRcs, {
        context: context
      } as ConversationServiceParamType, (res?: Object) => {
        callback(res);
      });
    } else {
      this.conversationRcsModel.queryMaxGroupIdRcs(callback, context);
    }
  }

  public queryMaxGroupIdInMmsInfoTable(callback: (res: LooseObject) => void, context: Context): void {
    if (GlobalContext.getContext().getObject('DataWorker') != null) {
      (GlobalContext.getContext()
        .getObject('DataWorker') as WorkerWrapper).sendRequest(
        common.RUN_IN_WORKER_METHOD.queryMaxGroupIdInMmsInfoTable, {
        context: context
      } as ConversationServiceParamType, (res: LooseObject) => {
        callback(res);
      });
    } else {
      this.conversationModel.queryMaxGroupIdInMmsInfoTable(context, callback);
    }
  }

  public queryMessageDetailAll( context: Context, actionData: LooseObject, callback: Function, rcsCount:number): void {
    this.querySmsMmsInfoByConditionAll(context, actionData, (res1: resType) => {
      this.queryMessageDetailResultAll(res1, actionData, callback, context, rcsCount);
    });
  }

  public queryDraftBySessionId(threadId: number, context: Context): Promise<string[]> {
    return this.conversationModel.queryDraftByCondition(threadId, context);
  }

  public queryFavoriteMessageDetailResultAll(res1: resType, actionData: LooseObject, callback: Function,
      context: Context, rcsCount: number) {
        let result: LooseObject = {};
        let smsList: LooseObject[] = [];
        if (res1?.code == common.int.SUCCESS) {
            this.queryMmsInfoResponse(res1.abilityResult, (mmsResult: Array<LooseObject>) => {
              mmsResult.forEach(item1 => {
                let item = this.getFavoriteDetailItem(item1)
                smsList.push(item)
              })
              smsList.sort(this.sorting)
              result.code = common.int.SUCCESS;
              result.abilityResult = smsList;
              callback(result);
            }, context)
        } else {
            this.queryMessageDetailFail(result, callback)
        }
    }

  public queryFavoriteResultAll(actionData: LooseObject, callback: Function, context: Context): void {
    if (GlobalContext.getContext().getObject('DataWorker') != null) {
      (GlobalContext.getContext()
        .getObject('DataWorker') as WorkerWrapper).sendRequest(common.RUN_IN_WORKER_METHOD.queryFavoriteAllInfoByCondition,
        {
          actionData: actionData,
          context: context
        } as ConversationServiceParamType, (res?: Object) => {
          callback(res);
        });
    } else {
      this.conversationModel.queryFavoriteAllInfoByCondition(actionData, callback, context);
    }
  }

  getFavoriteDetailItem(item1: LooseObject): LooseObject {
    if (item1.rcsId === undefined || item1.rcsId === 0 || item1.rcsId === '') {
      item1.isRcs = common.MESSAGE_TYPE.SMS_OR_MMS;
    } else {
      item1.isRcs = common.MESSAGE_TYPE.RCS;
      item1.rcsId = item1.rcsId;
    }
    if (item1.isRcs == common.MESSAGE_TYPE.SMS_OR_MMS) {
      item1.isMsm = item1.msgType == common.MSG_TYPE.MMS ? true : false;
    } else {
      item1.isMsm = false;
    }
    item1.isReceive = item1.isSender == 0 ? false : true;
    item1.hasMms = item1.isMsm;
    if (item1.mmsList) {
      item1.mmsSource = MmsUtil.getMmsSourceFromRequest(item1.mmsList);
      item1.contentType = MmsUtil.getMmsContentType(item1.mmsSource, item1.msgTitle);
    }
    return item1
  }

  public queryMessageDetailResultAll(res1:resType, actionData: LooseObject, callback: Function,
    context: Context, rcsCount: number) {
    let result: LooseObject = {};
    let smsList: LooseObject[] = [];
    if (res1?.code == common.int.SUCCESS) {
      this.queryMmsInfoResponse(res1.abilityResult, (mmsResult: Array<LooseObject>) => {
        mmsResult.forEach(item1 => {
          if(item1.rcsId === undefined || item1.rcsId === 0 || item1.rcsId === '') {
            item1.isRcs = common.MESSAGE_TYPE.SMS_OR_MMS;
            item1.isIpMsg = false;
          }else{
            item1.isRcs = common.MESSAGE_TYPE.RCS;
            item1.isIpMsg = item1.serviceCenter === common.serviceCenter.PUSH_OHOS_A2P ||
              item1.serviceCenter === common.serviceCenter.PUSH_A2P;
            item1.rcsId = item1.rcsId;
            if (item1.serviceKind && item1.serviceKind.length >= commonData.int.RCS_CODE_LENGTH) {
              item1.msgCodeStr = item1.serviceKind;
            }
          }
          if (item1.smsType != '' + commonData.sms_type.RCS) {
            smsList.push(item1);
          }
        })
        smsList.sort(this.sorting)
        this.groupDetailMessage(context, smsList, actionData, (resultList: Array<LooseObject>) => {
          result.code = common.int.SUCCESS;
          result.response = resultList;
          callback(result);
        });
      }, context)
    } else {
      this.queryMessageDetailFail(result,callback)
    }
  }

  public queryMessageDetailFail(result:LooseObject,callback:Function){
    result.code = common.int.FAILURE
    HiLog.w(TAG, 'queryMessageDetail, failed');
    callback(result);
  }

  public queryRcsInfoByConditionResult(context: Context, res2: resType, result: LooseObject,
    callback: Function, smsList: Array<LooseObject>, actionData: LooseObject) {
    if (res2?.code == common.int.SUCCESS) {
      result.code = common.int.SUCCESS
      try {
        res2?.abilityResult.forEach(item2 => {
          item2.isRcs = common.MESSAGE_TYPE.RCS;
          item2.rcsId = item2.rcsId;
          smsList.push(item2);
        })
      } catch (err) {
        HiLog.i(TAG, 'queryMessageDetail res2 err: ' + err)
      }
      smsList.sort(this.sorting)
      this.groupDetailMessage(context, smsList, actionData, (resultList: Array<LooseObject>) => {
        result.response = resultList;
        callback(result);
      });
    } else {
      result.code = common.int.FAILURE
      HiLog.w(TAG, 'queryMessageDetail, failed');
      callback(result);
    }
  }

  public sorting(a: LooseObject, b: LooseObject): number{
    return a.startTime - b.startTime;
  }

  public convertConversationList(context: Context, mmsList: LooseObject[]): Array<LooseObject> {
    let resultList: LooseObject[] = [];
    let tempRcsId: number = -1;
    let tempSatelliteId: number = -1;
    let tempIsIpMsg: boolean = false;
    for (let item of mmsList) {
      let result: LooseObject = this.convertConversationListResult(context, item, tempRcsId, tempSatelliteId,
        tempIsIpMsg);
      tempRcsId = result.isRcs;
      tempIsIpMsg = result.isIpMsg;
      resultList.push(result);
    }
    return resultList;
  }

  public groupDetailMessage(context: Context, mmsList: LooseObject[],
    actionData: LooseObject, callback: Function): void {
    let details: LooseObject[] = this.convertConversationList(context, mmsList);
    if (actionData.contactsNum == 1) {
      callback(details);
      return;
    }
    let resultList: LooseObject[] = [];
    // Group by groupId.
    let detailMap = this.convertConversationMap(details);
    // by group
    let groupIds: IterableIterator<string> = detailMap.keys();
    for (let groupId of Array.from(groupIds)) {
      let groups = detailMap.get(groupId) as Record<string, Object>[];
      let result = groups[0];
      let failuresNumber: number = 0;
      let completeNumber: number = 0;
      let sendingNumber: number = 0;
      for (let index = 0; index < groups.length; index++) {
        let item = groups[index];
        let preItem: Record<string, Object> = {};
        if (index !== 0) {
          preItem = groups[index - 1];
          if (preItem.timeMillisecond > item.timeMillisecond) {
            result.timeMillisecond = preItem.timeMillisecond;
          } else {
            result.timeMillisecond = item.timeMillisecond;
          }
        }
        if (item.sendStatus == common.int.SEND_MESSAGE_FAILED) {
          failuresNumber++;
        } else if (item.sendStatus === common.int.SEND_MESSAGE_SENDING) {
          sendingNumber++;
        }
        if (item.sendStatus == common.int.SEND_MESSAGE_FAILED || item.sendStatus == common.int.SEND_MESSAGE_SUCCESS) {
          completeNumber++;
        }
        this.handleItemSendStatusInGroupSendSession(item, index, groups, result, sendingNumber, failuresNumber);
      }
      result.completeNumber = completeNumber;
      result.failuresNumber = failuresNumber;
      resultList.push(result);
    }
    // 群组会话详情在根据groupId 整合之后需重新根据timeMillisecondSorting排序之后计算一次showTitle
    resultList.sort(this.timeMillisecondSorting);
    let tempRcsId: number = -1;
    let tempSatelliteId: number = -1;
    let tempIsIpMsg: boolean = false;
    for (let item of resultList) {
      item.showTitle = tempIsIpMsg !== item.isIpMsg || tempRcsId !== item.isRcs;
      tempRcsId = item.isRcs;
      tempIsIpMsg = item.isIpMsg;
    }
    callback(resultList);
  }

  public timeMillisecondSorting(objectOne: LooseObject, objectTwo: LooseObject): number{
    return objectOne.timeMillisecond - objectTwo.timeMillisecond;
  }

  public handleItemSendStatusInGroupSendSession(item: Record<string, Object>, index: number,
    groups: Record<string, Object>[], result: Record<string, Object>, sendingNumber: number, failuresNumber: number) {
    if (item.isRcs && index === groups.length - 1) {
      result.sendStatus = item.sendStatus;
    } else if (!item.isRcs && index === groups.length - 1) {
      if (sendingNumber > 0) {
        result.sendStatus = common.int.SEND_MESSAGE_SENDING;
      } else if (failuresNumber > 0) {
        result.sendStatus = common.int.SEND_MESSAGE_FAILED;
      } else if (item.sendStatus !== common.int.SEND_DRAFT) {
        result.sendStatus = common.int.SEND_MESSAGE_SUCCESS;
      } else {
        result.sendStatus = item.sendStatus;
      }
    }
  }

  public convertConversationMap(details: Record<string, string>[]) {
    let conversationMap = new Map<string, Record<string, Object>[]>();
    // grouping
    for (let element of details) {
      if (conversationMap.has(element.groupId)) {
        let groups = conversationMap.get(element.groupId);
        if (groups != undefined) {
          groups.push(element);
        }
      } else {
        let groups: Record<string, string>[] = [];
        groups.push(element);
        conversationMap.set(element.groupId, groups);
      }
    }
    return conversationMap;
  }

  public insertSessionAndDetail(actionData: LooseObject, callback: Function, context: Context): void {
    hiTraceMeter.startTrace(TraceConstant.TRACE_CONVERSATION_INSERT_SESSION_DETAIL,
      TraceConstant.TRACE_CONVERSATION_INSERT_SESSION_DETAIL_ID);
    let sendResults: LooseObject[] = actionData.sendResults;
    let isReceive: boolean = actionData.isReceive;
    if (sendResults.length == 0) {
      HiLog.w(TAG, 'insertSessionAndDetail, sendResults.length == 0');
      return;
    }
    let param: LooseObject = this.dealSendResults(sendResults, actionData.chatbotParameters || {
      isChatbotMessage: actionData.isChatbot
    });
    if (String(actionData.blockedSources) == Constant.BLOCKED_SOURCES_FRAUD) {
      param.blockedType = Constant.SESSION_BLOCKED_FRAUD;
    } else {
      param.blockedType = Constant.SESSION_NORMAL;
    }
    let querySessionCallbackFunction:Function = (res: resType) => {
      let response: LooseObject = res.response;
      if (res.code == common.int.SUCCESS) {
        if (response.id <= 0) {
          // when create new session. (user create new session / receive new session)
          this.dealContactsNameOfSession(actionData, param);
          HiLog.i(TAG, 'dealNoExistSession session insert timestamp ' + param.timestamp);
          this.dealNoExistSession(isReceive, param, actionData, callback, context);
        } else {
          let abilityStatus = GlobalContext.getContext().getObject('abilityStatus');
          HiLog.i(TAG, 'dealNoExistSession session abilityStatus: ' + abilityStatus);
          if (abilityStatus === 'onBackground' || ((abilityStatus === 'onForeground') &&
	   (AppStorage.get('currentSessionId') !== undefined && AppStorage.get('currentSessionId') === Number(response.id)))) {
            // receiveSessionArray 数组: 记录短信在后台情况下收到新消息的sessionId，用于判断从桌面或后台进入会话时是否更新数据
            let receiveSessionArray: string[] = AppStorage.get('receiveSessionArray') ?? [];
            let sessionId: string = response.id;
            if (!receiveSessionArray.includes(sessionId)) {
              receiveSessionArray.push(sessionId);
            }
            AppStorage.setOrCreate('receiveSessionArray', receiveSessionArray)
          }
          HiLog.w(TAG, '[insertSessionAndDetail] isReceive: ' + isReceive);
          this.dealExistSession(response, param, actionData, callback, context);
        }
        hiTraceMeter.finishTrace(TraceConstant.TRACE_CONVERSATION_INSERT_SESSION_DETAIL,
          TraceConstant.TRACE_CONVERSATION_INSERT_SESSION_DETAIL_ID);
      } else {
        HiLog.w(TAG, 'insertSessionAndDetail, query database Error');
        if (isReceive) {
          DotUtil.getInstance().addFailReason(actionData.smsReceiveIdForDot ?? 0,
            dotCommon.smsReceiveRecord.SMS_RECEIVE_REASON_QUERY_SESSION_BY_TELEPHONE_FAIL, true);
        }
        hiTraceMeter.finishTrace(TraceConstant.TRACE_CONVERSATION_INSERT_SESSION_DETAIL,
          TraceConstant.TRACE_CONVERSATION_INSERT_SESSION_DETAIL_ID);
        return;
      }
    }
    // Check whether a session list has been created.
    // 目的:查询当前的电话号码是否需要延迟执行插入数据库操作
    // 背景:短信息没有把同一个号码的信息自动归类，比如最上面两条信息是同一个号码发的，但是还是显示为两条信息
    // 电话号码:A没有存储在会话列表中，同时收到A的两个的短信时，会因时序问题，同时插入数据库，生成两个数据库
    // 仿照延时锁的逻辑对电话号码A，进行锁保护。
    // 1000ms,收到A-1短信，1010ms，收到A-2短信，2000ms收到A-3短信
    if (!this.querySessionCache.isNeedWait500MS(param.telephone)) {
      ConversationListService.getInstance()
        .querySessionByTelephone(param.telephone, querySessionCallbackFunction, context, true,
          actionData.chatbotParameters);
    } else {
      setTimeout(() => {
        ConversationListService.getInstance()
          .querySessionByTelephone(param.telephone, querySessionCallbackFunction, context, true,
            actionData.chatbotParameters);
      }, 500);
    }
  }

  private dealContactsNameOfSession(actionData: LooseObject, param: LooseObject) {
    if (actionData.sessionContacts && actionData.sessionContacts.length > 0) {
      let telephones: string[] = (param.telephone ?? '').split(common.STR.COMMA);
      let contacts: SessionContactInfoForDB[] = actionData.sessionContacts as SessionContactInfoForDB[];
      // sort contacts by telephones
      contacts.sort((a, b) => {
        return telephones.indexOf(a.contactPhone) - telephones.indexOf(b.contactPhone);
      });
      HiLog.i(TAG, 'insertSessionAndDetail when without session. sort contacts done.');
      // build contact_id, contact_name
      contacts.forEach((item) => {
        item.contactName = StringUtil.isEmpty(item.contactName) ? item.contactPhone : item.contactName;
      });
      param.contactId = contacts.map((item) => {
        return item.contactId;
      }).join(common.STR.COMMA);
      param.rawContactId = contacts.map((item) => {
        return item.rawContactId;
      }).join(common.STR.COMMA);
      param.contactName = contacts.map((item) => {
        return item.contactName;
      }).join(common.STR.COMMA + common.STR.WHITE_SPACE);
      HiLog.i(TAG, 'insertSessionAndDetail when without session. build contact_id and contact_name done.');
    }
  }

  public dealNoExistSession(isReceive: boolean, param: LooseObject, actionData: LooseObject, callback: Function,
    context: Context): void {
    HiLog.w(TAG, '[dealNoExistSession] isReceive: ' + isReceive);
    let valueBucket: ValuesBucket = {
      'telephone': param.telephone,
      'content': param.content,
      'contacts_num': param.contactsNum,
      'sms_type': param.smsType,
      'sending_status': param.sendStatus,
      'has_draft': common.has_draft.NO,
      'time': param.timestamp,
      'message_count': 1,
      'has_mms': actionData.isMms ? common.has_mms.HAVE : common.has_mms.NO,
      'has_attachment': actionData.hasAttachment ? common.has_attachment.HAVE : common.has_attachment.NO,
      'contact_id': param.contactId ?? '',
      'contact_name': param.contactName ?? '',
      'blocked_type': param.blockedType,
      'pinning_time': 0,
    }

    let isMmsMapMessage: boolean = getIsMmsMapMessageByMmsSource(
      actionData?.isRcsType != undefined && actionData.isRcsType >= 0, actionData?.mmsSource);
    if (isMmsMapMessage) { //将彩信位置消息在sms_mms_info表中的msg_content置空，为了屏蔽主页的搜索功能
      valueBucket.content = '';
    }
    if (param.sendStatus === common.int.SEND_MESSAGE_FAILED) {
      HiLog.w(TAG, 'dealNoExistSession, sending_status is' + param.sendStatus);
    }
    if (BlockedUtil.isBlockLooseObject(actionData)) {
      //是拦截短信，不创建新会话
      HiLog.e(TAG, 'dealNoExistSession, is blocked');
      this.handleInsertMessageDetail(param, actionData, Constant.BLOCKED_SESSION, context, callback);
      return;
    }
    // HiLog.iw(TAG, `dealNoExistSession,smsType=${param.smsType},telephone=${Anonymizer.ohAegMaskPhone(param.telephone)}`);
    let isMmsAttachments: boolean = actionData.isMms && (actionData.mmsSource?.length > 1) &&
      (actionData.mmsSource?.[1]?.type === common.MM_ATTACHMENT_TYPE.VIDEO ||
        actionData.mmsSource?.[1]?.type === common.MM_ATTACHMENT_TYPE.IMAGE ||
        actionData.mmsSource?.[1]?.type === common.MM_ATTACHMENT_TYPE.AUDIO ||
        actionData.mmsSource?.[1]?.type === common.MM_ATTACHMENT_TYPE.VCARD);
    let receiveMsgType: boolean = (actionData.type === commonData.RCS_TYPE.RCS ||
      actionData.type === commonData.RCS_TYPE.RCS_SEND);
    // 是附件以及非RCS消息,mmsSource是附件携带的信息，以及附件携带彩信类型在数组[1]
    if (isMmsAttachments && !receiveMsgType) {
      valueBucket.content = '';
    }
    ConversationListService.getInstance().insertSession(valueBucket, (sessionResult: Record<string, number>) => {
      HiLog.i(TAG, 'dealNoExistSession, insertSession callback');
      if (sessionResult.code == common.int.FAILURE) {
        HiLog.e(TAG, 'dealNoExistSession, insertSession fail!');
        DotUtil.getInstance().addFailReason(actionData.smsReceiveIdForDot,
          dotCommon.smsReceiveRecord.SMS_RECEIVE_REASON_INSERT_SESSION_FAIL, true);
        DotUtil.getInstance().reportEvent(dotNoNeedParmas, dotCommon.eventName.RECEIVE_MESSAGE_FAIL_INSERT);
        callback(sessionResult);
        return;
      }
      // Invoke the SMS database to insert SMS messages.
      this.handleInsertMessageDetail(param, actionData, sessionResult.abilityResult, context, callback);
    }, context);
  }

  private handleInsertMessageDetail(param: LooseObject, actionData: LooseObject, sessionId: number,
                                    context: Context, callback: Function) {
    this.dealInsertMessageDetail(param, actionData, sessionId, (res: LooseObject) => {
      if (!res || !res.initDatas) {
        HiLog.e(TAG, '[dealInsertMessageDetail], res is null');
        return;
      }
      let result: Record<string, number | Array<LooseObject>> = {
        'rowId': sessionId,
        'initDatas': res.initDatas,
        'groupId': res.groupId,
        'smsType': param.smsType,
        'rcsId': res.initDatas[0]?.['rcs_id'],
        'code': res.code
      };
      this.insertMmsInfoList(res, actionData.mmsSource, context);
      callback(result);
    }, context);
  }

  public async dealExistSession(response: LooseObject, param: LooseObject, actionData: LooseObject, callback: Function,
    context: Context): Promise<void> {
    HiLog.w(TAG, '[dealExistSession] current unreadCount: ' + response.unreadCount);
    let hasDraft: number = response.hasDraft;
    if (actionData.hasDraft && hasDraft == 1) {
      hasDraft = 0;
    } else if (actionData.isReceive && hasDraft == 1) {
      hasDraft = common.has_draft.HAVE_ON_DISPLAY;
    }
    let valueBucket: ValuesBucket = {}
    if (hasDraft) {
      valueBucket = {
        'time': new Date().getTime(),
        'message_count': (response.messageCount + 1),
      }
    } else {
      valueBucket = {
        'content': param.content,
        'time': new Date().getTime(),
        'sending_status': param.sendStatus,
        'has_draft': hasDraft,
        'message_count': (response.messageCount + 1),
        'has_attachment': actionData.hasAttachment ? 1 : 0,
        'has_mms': actionData.isMms ? 1 : 0,
      }
    }
    if (String(actionData.blockedSources) == Constant.SESSION_CHANGE_WHITE ||
      String(actionData.blockedSources) == Constant.BLOCKED_SOURCES_FRAUD) {
      HiLog.i(TAG, 'dealExistSession blocked_type : ' + param.blockedType);
      valueBucket.blocked_type = param.blockedType;
    }
    if (param.sendStatus === common.int.SEND_MESSAGE_FAILED) {
      HiLog.w(TAG, 'dealExistSession sending_status is' + param.sendStatus);
    }
    if (param.telephone !== undefined && param.telephone !== response.telephone) {
      HiLog.i(TAG, 'dealExistSession telephone refresh');
      valueBucket.telephone = param.telephone;
    }
    let sessionId: number = response.id;
    let condition: LooseObject = {};
    condition.threadId = sessionId;
    HiLog.i(TAG, 'dealExistSession update timestamp ' + valueBucket.time);
    let isMmsVideo: boolean = actionData.isMms && (actionData.mmsSource?.length > 1) &&
      (actionData.mmsSource?.[1]?.type === common.MM_ATTACHMENT_TYPE.VIDEO ||
        actionData.mmsSource?.[1]?.type === common.MM_ATTACHMENT_TYPE.IMAGE ||
        actionData.mmsSource?.[1]?.type === common.MM_ATTACHMENT_TYPE.AUDIO ||
        actionData.mmsSource?.[1]?.type === common.MM_ATTACHMENT_TYPE.VCARD);
    let receiveMsgType: boolean = (actionData.type === commonData.RCS_TYPE.RCS ||
      actionData.type === commonData.RCS_TYPE.RCS_SEND);
    let isMmsMapMessage: boolean = getIsMmsMapMessageByMmsSource(
      actionData?.isRcsType != undefined && actionData.isRcsType >= 0, actionData?.mmsSource);
    //将彩信位置消息在sms_mms_info表中的msg_content置空，为了屏蔽主页的搜索功能
    if ((isMmsVideo || isMmsMapMessage) && !receiveMsgType) {
      valueBucket.content = '';
    }
    if (BlockedUtil.isBlockLooseObject(actionData)) {
      // 是拦截短信，只更新blockedType
      HiLog.i(TAG, 'dealExistSession, is blocked');
      this.handleInsertMessageDetail(param, actionData, sessionId, context, callback);
      if (String(actionData.blockedSources) == Constant.SESSION_CHANGE_WHITE ||
        String(actionData.blockedSources) == Constant.BLOCKED_SOURCES_FRAUD) {
        HiLog.i(TAG, 'dealExistSession, updateSessionByCondition blocked_type');
        let blockedValueBucket: ValuesBucket = {}
        blockedValueBucket = {
          'time': new Date().getTime(),
          'blocked_type': param.blockedType,
        }
        ConversationListService.getInstance().updateSessionByCondition(context, condition, blockedValueBucket, () => {
          HiLog.w(TAG, 'dealExistSession, is blocked updateSessionByCondition success');
          SharedPreferencesUtils.saveToPreferences('restoreBlocked', true);
          ConversationListController.getInstance().refreshConversationListData(context);
        }, true);
      }
      return;
    }
    ConversationListService.getInstance()
      .updateSessionByCondition(context, condition, valueBucket, (res: LooseObject) => {
        this.reportReceiveMessageDbError(actionData, Number(res.code),
          dotCommon.smsReceiveRecord.SMS_RECEIVE_REASON_SESSION_DB_UPDATE_FAIL);
      // Invoke the SMS database to insert SMS messages.
      this.handleInsertMessageDetail(param, actionData, sessionId, context, callback);
    }, true);
  }

  /**
   * 收消息时插入数据库失败时上报点位
   *
   * @param actionData 插入数据
   * @param resCode 插入数据库返回状态
   * @param failReason 失败原因
   */
  private reportReceiveMessageDbError(actionData: LooseObject, resCode: number, failReason: string): void {
    if ((actionData.isReceive ?? false) && !Number.isNaN(resCode) && resCode === common.int.FAILURE) {
      DotUtil.getInstance().addFailReason(actionData.smsReceiveIdForDot ?? 0, failReason, true);
      DotUtil.getInstance().reportEvent(dotNoNeedParmas, dotCommon.eventName.RECEIVE_MESSAGE_FAIL_INSERT);
    }
  }

  public dealInsertMessageDetail(param: LooseObject, actionData: LooseObject, threadId: number, callback: Function,
    context: Context): void {
    const tempFunction = (maxGroupId: number) => {
      this.insertMessageDetailByMaxGroupId(param, actionData, threadId, maxGroupId, (result: LooseObject) => {
        callback(result);
      }, context);
    };

    if (typeof actionData.groupId === 'number' && !isNaN(actionData.groupId)) {
      tempFunction(actionData.groupId);
    } else {
      this.queryMaxGroupIdInMmsInfoTable((res: LooseObject) => {
        let groupId: number = 0;
        if (res.code === common.int.SUCCESS) {
          groupId = Number(res.abilityResult);
          //这里是利用js单线程的特性，可以始终持有最大的groupId，修改了groupId重复的问题。
          this.maxGroupId = this.maxGroupId > groupId ? this.maxGroupId + 1 : groupId + 1;
          groupId = this.maxGroupId;
        } else {
          HiLog.w(TAG, 'dealInsertMessageDetail, queryMaxGroupId failed');
          callback(res);
        }
        tempFunction(groupId);
      }, context);
    }
  }

  public dealInsertDraftData(param: LooseObject, actionData: LooseObject, threadId: number, callback: Function,
    context: Context): void {
    this.queryMaxGroupIdInMmsInfoTable((res) => {
      let groupId: number = 0;
      if (res.code == common.int.SUCCESS) {
        groupId = Number(res.abilityResult);
        this.maxGroupId = this.maxGroupId > groupId ? this.maxGroupId + 1 : groupId + 1;
        groupId = this.maxGroupId;
      } else {
        HiLog.w(TAG, 'dealInsertMessageDetail, queryMaxGroupId failed');
        callback(res);
      }
      let data: Record<string, number | string | boolean> = {
        'threadId': threadId,
        'sendStatus': common.int.SEND_DRAFT,
        'telephone': param.telephone,
        'isDraft': true
      };
      if (AppStorage.get(Constant.IS_CHANGE_DRAFT)) {
        //此处是groupId为0的时候查询删除的草稿id
        this.querySmsMmsInfoByCondition(context, data, (item: LooseObject) => {
          if (item && item.abilityResult && item.abilityResult[0]) {
            //这里保存删除草稿的id和电话号码，用于在融合搜中 把搜出来已经删除的草稿给过滤掉
            AppStorage.setOrCreate(Constant.DELETED_DRAFT_MSG_ID, item.abilityResult[0].msgId);
            AppStorage.setOrCreate(Constant.DELETED_DRAFT_NUMBER, item.abilityResult[0].receiverNumber);
          }
          this.deleteSmsMmsInfoByCondition(context, data, ()=>{
            this.insertMessageDetailByMaxGroupId(param, actionData, threadId, groupId, (result: LooseObject) => {
              callback(result);
            }, context);
          });
        });
      } else {
        this.deleteSmsMmsInfoByCondition(context, data, null)
        this.insertMessageDetailByMaxGroupId(param, actionData, threadId, groupId, (result: LooseObject) => {
          callback(result);
        }, context);
      }
    }, context);
  }

  public insertMessageDetailByMaxGroupId(param: LooseObject, actionData: LooseObject, threadId: number,
    maxGroupId: number, callback: Function, context: Context): void {
    let count: number = 0;
    let initDatas: LooseObject[] = [];
    let result: LooseObject = {};
    result.groupId = maxGroupId;
    let sendResults: LooseObject[] = actionData.sendResults;
    if (sendResults.length > 1) {
      // When multiple messages are sent to a group, the value of start_time must be the same.
      if (StringUtil.isEmpty(actionData.start_time)) {
        actionData.start_time = Date.now() + common.STR.EMPTY_STR;
      }
    }
    sendResults.forEach(async sendResult => {
      let valueBucket: LooseObject =[];
      if(actionData.type === commonData.RCS_TYPE.RCS || actionData.type === commonData.RCS_TYPE.RCS_SEND){
        valueBucket = await this.buildInsertRcsMmsRow(param, actionData, sendResult, threadId, maxGroupId, context);
        ConversationRcsService.getInstance().insertRcsMmsInfo(valueBucket, async (res: Record<string, string>) => {
          this.reportReceiveMessageDbError(actionData, Number(res.code),
            dotCommon.smsReceiveRecord.SMS_RECEIVE_REASON_RCS_INFO_DB_INSERT_FAIL);
          valueBucket = await this.buildInsertRcsSmsMmsRow(param, actionData, sendResult,
            maxGroupId, res.abilityResult, context, threadId);
          const rcsId = res.abilityResult;
          this.insertSmsMmsInfo(valueBucket, (res: Record<string, string>) => {
            this.reportReceiveMessageDbError(actionData, Number(res.code),
              dotCommon.smsReceiveRecord.SMS_RECEIVE_REASON_SMS_INFO_DB_INSERT_FAIL);
            count = this.insertSmsMmsInfoCallbackRcs(count, res, sendResult, initDatas, rcsId, actionData, result,
              callback, valueBucket);
          }, context);
        }, context);
      } else {
        valueBucket = await this.buildInsertSmsMmsRow(param, actionData, sendResult, maxGroupId, threadId );
        this.insertSmsMmsInfo(valueBucket, (res: Record<string, string>) => {
          this.reportReceiveMessageDbError(actionData, Number(res.code),
            dotCommon.smsReceiveRecord.SMS_RECEIVE_REASON_SMS_INFO_DB_INSERT_FAIL);
          count =
            this.insertSmsMmsInfoCallback(count, res, sendResult, initDatas, actionData, result, callback, valueBucket);
        }, context);
      }
    });
  }

  // 批量像mms插入数据
  public async batchInsertSmsMmsInfo(rcsInfoMap: Map<number, LooseObject>, context: Context): Promise<number> {
    let result: number = common.int.SUCCESS;
    if (rcsInfoMap.size == 0) {
      return result;
    }

    let valueBuckets: ValuesBucket[] = [];
    rcsInfoMap.forEach(item => {
      let valueBucket = this.buildRcsSmsMmsInfoByRcsInfo(item);
      valueBuckets.push(valueBucket);
    })

    return await this.conversationModel.batchInsertSmsMmsInfo(valueBuckets, context);
  }

  // 批量更新mms中的msg_content
  public async batchUpdateMsgContentByRcsIds(rcsContentMap: Map<number, string>, context: Context): Promise<number> {
    let result: number = common.int.SUCCESS;
    if (rcsContentMap.size == 0) {
      return result;
    }

    let valueBuckets: ValuesBucket[] = [];
    for (let entry of rcsContentMap.entries()) {
      let bucket: ValuesBucket = {
        'rcs_id': entry[0],
        'msg_content':this.buildSmsMmsRowMsgContent({content: entry[1]},
          {isRcsType: common.ENHANCED_INFO_ITEM_TYPE.CHATBOT_CARD})
      }
      valueBuckets.push(bucket);
    }
    return await this.conversationModel.batchUpdateSmsMmsInfo(valueBuckets, context);
  }

  private insertSmsMmsInfoCallback(count: number, res: Record<string, string>, sendResult: LooseObject,
    initDatas: LooseObject[],
    actionData: LooseObject, result: LooseObject, callback: Function, valueBucket: LooseObject) {
    count++;
    let initData: Record<string, number | string> = {
      'id': res.abilityResult,
      'telephone': sendResult.telephone,
      'rcs_id': 0,
      'start_time': valueBucket.start_time
    };
    initDatas.push(initData);
    if (count == actionData.sendResults.length) {
      result.initDatas = initDatas;
      callback(result);
    }
    return count;
  }

  private insertSmsMmsInfoCallbackRcs(count: number, res: Record<string, string>, sendResult: LooseObject,
    initDatas: LooseObject[], rcsId: string,
    actionData: LooseObject, result: LooseObject, callback: Function, valueBucket: LooseObject) {
    count++;
    let initData: Record<string, number | string> = {
      'msgId': res.abilityResult,
      'id': rcsId,  // 保持id与原来一致rcs消息为rcsId
      'telephone': sendResult.telephone,
      'rcs_id': rcsId,
      'start_time': valueBucket.start_time
    };
    initDatas.push(initData);
    if (count == actionData.sendResults.length) {
      result.initDatas = initDatas;
      callback(result);
    }
    return count;
  }

  private async buildInsertSmsMmsRow(param: LooseObject, actionData: LooseObject, sendResult: LooseObject,
    maxGroupId: number, threadId?: number ): Promise<LooseObject> {
    let valueBucket: ValuesBucket = this.buildInsertSmsMmsRowValueBucket(maxGroupId, threadId)
    if (sendResult.slotId != null) {
      valueBucket.slot_id = sendResult.slotId;
    }
    if (actionData.isReceive) {
      valueBucket.receiver_number = actionData.ownNumber ? actionData.ownNumber : common.STR.EMPTY_STR;
      valueBucket.sender_number = sendResult.telephone ? sendResult.telephone : common.STR.EMPTY_STR;
      valueBucket.is_read = actionData.isNeedSendNotice ? common.is_read.UN_READ : common.is_read.READ;
      valueBucket.mms_pdu = actionData.mmsPdu ? actionData.mmsPdu : common.STR.EMPTY_STR;
    } else {
      valueBucket.receiver_number = sendResult.telephone ? sendResult.telephone : common.STR.EMPTY_STR;
      valueBucket.sender_number = actionData.ownNumber ? actionData.ownNumber : common.STR.EMPTY_STR;
      valueBucket.is_read = common.is_read.READ;
    }
    if (sendResult.slotId != undefined) {
      valueBucket.phone_number = !StringUtil.isEmpty(valueBucket.receiver_number as string) ?
        valueBucket.receiver_number : valueBucket.sender_number;
      valueBucket.format_phone_number = await this.buildFormatPhoneNumber(valueBucket.phone_number as string,
          sendResult.slotId);
    }
    let time: string = actionData.start_time;
    if (time == null) {
      time = sendResult.time || (new Date().getTime() + common.STR.EMPTY_STR);
    } else {
      HiLog.i(TAG, 'Existing start time: ' + time + '. Skip Settings.');
    }
    valueBucket.start_time = time;
    valueBucket.end_time = actionData.endTime ? actionData.endTime : '';
    valueBucket.expires_time = actionData.expiresTime ? actionData.expiresTime : '';
    valueBucket.sms_type = param.smsType != null ? param.smsType : valueBucket.sms_type
    if (param.content != null) {
      valueBucket.msg_content = param.content;
    }
    if (param.msgTitle != null) {
      valueBucket.msg_title = param.msgTitle;
    }
    if (sendResult.sendStatus != null) {
      valueBucket.msg_state = sendResult.sendStatus;
    }
    this.judgeSmsValueBucket(actionData, valueBucket);
    return valueBucket;
  }

  // 通过rcs_info表中的信息构造sms_mms_info表数据，用于增强信息卡片消息同步
  private buildRcsSmsMmsInfoByRcsInfo(rcsInfo: LooseObject): ValuesBucket {
    let valueBucket: ValuesBucket = this.buildInsertSmsMmsRowValueBucket(rcsInfo.groupId, rcsInfo.sessionId);
    valueBucket.slot_id = rcsInfo.slotId;
    valueBucket.sender_number = rcsInfo.senderNumber;
    valueBucket.is_read = rcsInfo.isRead;
    valueBucket.phone_number = rcsInfo.senderNumber;
    valueBucket.start_time = rcsInfo.startTime;
    valueBucket.sms_type = commonData.sms_type.RCS;
    valueBucket.rcs_ID = rcsInfo.rcsId;

    valueBucket.msg_content = this.buildSmsMmsRowMsgContent({ content: rcsInfo.msgContent },
      { isRcsType: common.ENHANCED_INFO_ITEM_TYPE.CHATBOT_CARD });
    valueBucket.msg_state = rcsInfo.msgState;
    valueBucket.msg_type = common.MSG_TYPE.MMS;
    valueBucket.is_sender = rcsInfo.isSender;
    valueBucket.is_read = rcsInfo.isRead;
    return valueBucket;
  }

  private async buildInsertRcsSmsMmsRow(param: LooseObject, actionData: LooseObject, sendResult: LooseObject,
    maxGroupId: number, rcsId: string, context: Context, threadId?: number): Promise<LooseObject> {
    let valueBucket: ValuesBucket = this.buildInsertSmsMmsRowValueBucket(maxGroupId, threadId)
    if (sendResult.slotId != null) {
      valueBucket.slot_id = sendResult.slotId;
    }
    if (actionData.isReceive) {
      valueBucket.receiver_number = actionData.ownNumber ? actionData.ownNumber : common.STR.EMPTY_STR;
      valueBucket.sender_number = sendResult.telephone ? sendResult.telephone : common.STR.EMPTY_STR;
      valueBucket.is_read = common.is_read.READ;
      valueBucket.mms_pdu = actionData.mmsPdu ? actionData.mmsPdu : common.STR.EMPTY_STR;
    } else {
      valueBucket.receiver_number = sendResult.telephone ? sendResult.telephone : common.STR.EMPTY_STR;
      valueBucket.sender_number = actionData.ownNumber ? actionData.ownNumber : common.STR.EMPTY_STR;
      valueBucket.is_read = common.is_read.READ;
    }
    if (sendResult.slotId != undefined) {
      valueBucket.phone_number = !StringUtil.isEmpty(valueBucket.receiver_number as string) ?
        valueBucket.receiver_number : valueBucket.sender_number;
      valueBucket.format_phone_number = await this.buildFormatPhoneNumber(valueBucket.phone_number as string,
        sendResult.slotId);
    }
    let time: string = actionData.start_time;
    if (time == null) {
      time = sendResult.time || (new Date().getTime() + common.STR.EMPTY_STR);
    } else {
      HiLog.i(TAG, 'Existing start time: ' + time + '. Skip Settings.');
    }
    valueBucket.start_time = time;
    valueBucket.end_time = actionData.endTime ? actionData.endTime : '';
    valueBucket.expires_time = actionData.expiresTime ? actionData.expiresTime : '';
    valueBucket.sms_type = commonData.sms_type.RCS;
    valueBucket.rcs_id = rcsId
    if (param.content != null) {
      valueBucket.msg_content = this.buildSmsMmsRowMsgContent(param, actionData);
    }
    if (param.msgTitle != null) {
      valueBucket.msg_title = (actionData.isRcsType === 0) ? param.msgTitle : '' as string;
    }
    if (sendResult.sendStatus != null) {
      valueBucket.msg_state = sendResult.sendStatus;
    }
    this.judgeSmsValueBucket(actionData, valueBucket);
    return valueBucket;
  }

  private buildSmsMmsRowMsgContent(param: LooseObject, actionData: LooseObject): string {
    if (actionData.isRcsType === common.ENHANCED_INFO_ITEM_TYPE.TEXT) {
      return param.content;
    }

    if (actionData.isRcsType === common.ENHANCED_INFO_ITEM_TYPE.CHATBOT_CARD) {
      let contentStr: string = '';
      let msgContent: string = param.content;
      if (msgContent == undefined) {
        return contentStr;
      }
      try {
        let content: LooseObject = JSON.parse(msgContent) as LooseObject;
        if (content == undefined || content.message == undefined) {
          return contentStr;
        }
        let message: LooseObject = content.message;
        if (JSON.has(message, 'generalPurposeCard')) {
          let title = message.generalPurposeCard.content.title ?
            message.generalPurposeCard.content.title + String.fromCharCode(10) : '';
          contentStr = contentStr.concat(title, message.generalPurposeCard.content.description ?? '');
        }
        if (JSON.has(message, 'generalPurposeCardCarousel')) {
          let contentArray: LooseObject[] = message.generalPurposeCardCarousel.content;
          let contentStrArray: string[] = [];
          contentArray.forEach(content => {
            let title = content.title ? content.title + String.fromCharCode(10) : '';
            let description = content.description ? content.description + String.fromCharCode(10) : '';
            contentStrArray.push(title, description);
          })
          contentStr = contentStrArray.join('');
        }
      } catch (err) {
        HiLog.e(TAG, 'buildSmsMmsRowMsgContent err, msg = '+ json.stringify(err));
      }
      return contentStr;
    }
    return '';
  }

  private judgeSmsValueBucket(actionData: LooseObject, valueBucket: ValuesBucket) {
    if (actionData.isMms != null && actionData.isMms) {
      HiLog.i(TAG, 'buildInsertSmsMmsRow is mms');
      valueBucket.msg_type = common.MSG_TYPE.MMS;
    }
    if (actionData.isSender != null) {
      valueBucket.is_sender = actionData.isSender;
    }
    if (actionData.hasReport != null) {
      valueBucket.is_send_report = actionData.hasReport;
    }
    if (actionData.isAdvancedSecurity != null) {
      valueBucket.is_advanced_security = actionData.isAdvancedSecurity;
    }
    this.judgeBlockValueBucket(actionData, valueBucket);
  }

  private async buildFormatPhoneNumber(phoneNumber: string, slotId: number): Promise<string> {
    if (StringUtil.isEmpty(phoneNumber)) {
      return '';
    }
    return await SsmUtils.formatPhoneNumber(phoneNumber, slotId);
  }

  public async buildInsertRcsMmsRow(param: LooseObject, actionData: LooseObject, sendResult: LooseObject,
    threadId: number, maxGroupId: number, context: Context): Promise<LooseObject> {
    let valueBucket: ValuesBucket = this.buildRcsMmsValueBucket(threadId, maxGroupId);
    // 只有单的ip才有插入RCS表的动作
    const isIpMsg = commonData.serviceCenter.PUSH_OHOS_A2P === actionData.serviceCenter;
    if (sendResult.slotId != null) {
      valueBucket.slot_id = sendResult.slotId as number;
    }
    if (actionData.isRcsType && actionData.isSender === 1 && actionData.totalSize) {
      valueBucket.total_size = actionData.totalSize;
    }
    if (actionData.isReceive) {
      valueBucket.receiver_number = actionData.ownNumber ? actionData.ownNumber : common.STR.EMPTY_STR;
      valueBucket.sender_number = sendResult.telephone ? sendResult.telephone : common.STR.EMPTY_STR;
      valueBucket.is_read = actionData.isNeedSendNotice ? common.is_read.UN_READ : common.is_read.READ;
      // IP消息
      if (isIpMsg) {
        valueBucket.owner_addr = actionData.ownerAddr
        valueBucket.protocol = actionData.protocol
        valueBucket.service_center = actionData.serviceCenter
      }
    } else {
      valueBucket.receiver_number = sendResult.telephone ? sendResult.telephone : common.STR.EMPTY_STR;
      valueBucket.sender_number = actionData.ownNumber ? actionData.ownNumber : common.STR.EMPTY_STR;
      valueBucket.is_read = common.is_read.READ;
    }
    if (sendResult.slotId != undefined) {
      valueBucket.phone_number = !StringUtil.isEmpty(valueBucket.receiver_number as string) ?
        valueBucket.receiver_number : valueBucket.sender_number;
      valueBucket.format_phone_number = await this.buildFormatPhoneNumber(valueBucket.phone_number as string,
        sendResult.slotId);
    }
    let time: string = sendResult.time as string;
    if (time == null) {
      time = new Date().getTime() + common.STR.EMPTY_STR;
    }
    if(actionData.starttime!=null) {
      valueBucket.start_time = actionData.starttime as string;
    }else{
      valueBucket.start_time = time;
    }
    if (!isIpMsg) {
      valueBucket.end_time = time;
    }
    this.buildInsertRcsRow(actionData, valueBucket, param);
    if (param.content != null) {
      valueBucket.msg_title = (valueBucket.rcs_type === 0 && !isIpMsg) ? param.content : '' as string;
      valueBucket.msg_content = param.content as string;
    }
    if (sendResult.sendStatus != null) {
      valueBucket.msg_state = sendResult.sendStatus;
    }
    this.judgeRcsMmsValueBucket(actionData, valueBucket);
    return valueBucket;
  }
  private buildInsertRcsRow(actionData: LooseObject, valueBucket: ValuesBucket, param: LooseObject) {
    if (actionData.type === commonData.RCS_TYPE.RCS || actionData.type === commonData.RCS_TYPE.RCS_SEND) {
      if (actionData.isRcsType != null) {
        valueBucket.rcs_type = actionData.isRcsType as string;
      }
      HiLog.i(TAG, 'valueBucket.rcs_type:' + valueBucket.rcs_type);
    } else {
      if (param.smsType != null) {
        valueBucket.rcs_type = param.smsType as string;
      }
    }
  }
  private judgeRcsMmsValueBucket(actionData: LooseObject, valueBucket: ValuesBucket) {
    if (actionData.isSender != null) {
      valueBucket.is_sender = actionData.isSender;
    }
    if (actionData.hasReport != null && actionData.type === commonData.RCS_TYPE.RCS) {
      valueBucket.is_send_report = actionData.hasReport;
    }
    if(actionData.msgId!=null){
      valueBucket.msg_id=actionData.msgId;
    }
    if (actionData.isAdvancedSecurity != null) {
      valueBucket.is_advanced_security = actionData.isAdvancedSecurity;
    }
    if(actionData.receiveState!=null){
      valueBucket.receive_state = actionData.receiveState;
    }
    if(actionData.failReceiveContext!=null){
      valueBucket.fail_receive_context = actionData.failReceiveContext;
    }
    this.judgeBlockValueBucket(actionData, valueBucket);
  }

  private judgeBlockValueBucket(actionData: LooseObject, valueBucket: ValuesBucket) {
    if (actionData.isBlocked != null) {
      valueBucket.is_blocked = actionData.isBlocked;
      if (actionData.isBlocked == Constant.BLOCK) {
        valueBucket.is_read = common.is_read.READ;
      }
    }
    if (actionData.blockedReason != null) {
      valueBucket.blocked_reason = actionData.blockedReason;
    }
    if (actionData.blockedSources != null) {
      valueBucket.blocked_sources = actionData.blockedSources;
    }
    if (actionData.blockedType != null) {
      valueBucket.blocked_type = actionData.blockedType;
    }
    if (actionData.blockedTypeText != null) {
      valueBucket.blocked_type_text = actionData.blockedTypeText;
    }
    if (actionData.blockedPrefNumber != null) {
      valueBucket.blocked_pref_number = actionData.blockedPrefNumber;
    }
  }

  private buildRcsMmsValueBucket(threadId: number, maxGroupId: number): ValuesBucket {
    return {
      'slot_id': common.int.SIM_ONE,
      'receiver_number': common.STR.EMPTY_STR,
      'sender_number': common.STR.EMPTY_STR,
      'start_time': common.STR.EMPTY_STR,
      'end_time': common.STR.EMPTY_STR,
      'rcs_type': common.sms_type.COMMON,
      'msg_title': common.STR.EMPTY_STR,
      'msg_content': common.STR.EMPTY_STR,
      'msg_state': common.int.SEND_MESSAGE_SENDING,
      'is_lock': common.is_lock.NO,
      'is_read': common.is_read.UN_READ,
      'session_id': threadId,
      'group_id': maxGroupId,
      'msg_id': '0',
      'is_sender': common.is_sender.NO,
      'enriched_calling_type': 0,
      'error_code': 0,
      'network_type': '',
      'owner_addr': '',
      'privacy_mode': 0,
      'protocol': 0,
      'reply_path_present': 0,
      'seen': 0,
      'service_center': '',
      'service_kind': '',
      'is_collect': 0,
      'is_advanced_security': common.ADVANCED_SECURITY_MODE.ORDINARY,
      'receive_state': 0,
      'fail_receive_context': '',
      'total_size': 0,
      'clur_size': 0,
      'phone_number': common.STR.EMPTY_STR,
      'format_phone_number': common.STR.EMPTY_STR,
    };
  }

  public dealSendResults(sendResults: Array<LooseObject>, chatbotParameters?: ChatbotParameters): LooseObject {
    let contactsNum: number = sendResults.length;
    let telephone: string = common.STR.EMPTY_STR;
    let content: string = common.STR.EMPTY_STR;
    let msgTitle: string = common.STR.EMPTY_STR;
    let sendStatus: number = common.int.SEND_MESSAGE_SUCCESS;
    let failSum: number = 0;
    let time: string = common.STR.EMPTY_STR;
    for (let sendResult of sendResults) {
      telephone = telephone + sendResult.telephone + common.STR.COMMA;
      content = sendResult.content;
      msgTitle = sendResult.msgTitle;
      sendStatus = sendResult.sendStatus;
      if (sendResult.sendStatus == common.int.SEND_MESSAGE_FAILED) {
        failSum++;
      }
      if (sendResult.time != null) {
        time = sendResult.time;
      }
      if (sendResult.isMessageSim != null && sendResult.isMessageSim) {
        telephone = sendResult.telephone;
        contactsNum = 1;
      }
    }
    // If it fails, then the session list turns out to be a failure.
    if (failSum > 0) {
      sendStatus = common.int.SEND_MESSAGE_FAILED;
    }
    telephone = telephone.substring(0, telephone.length - 1);
    let smsType: number = common.sms_type.COMMON;
    if (chatbotParameters?.isChatbotMessage || (contactsNum == 1 && TelephoneUtil.judgeIsInfoMsg(telephone))) {
      smsType = common.sms_type.NOTICE;
    } else if (telephone?.startsWith('sip:') && telephone?.includes('botplatform')) {
      smsType = common.sms_type.NOTICE;
    }
    HiLog.i(TAG, 'notification smsType: ' + smsType);
    let result: LooseObject = {};
    let timestamp: number = new Date().getTime();
    result.contactsNum = contactsNum;
    result.content = content;
    result.msgTitle = msgTitle;
    result.telephone = TelephoneUtil.dealTelephoneSort(telephone);
    result.sendStatus = sendStatus;
    result.timestamp = time != common.STR.EMPTY_STR ? time : timestamp;
    result.smsType = smsType;
    return result;
  }

  public updateSessionAndDetail(context: Context, sendType: boolean, actionData: LooseObject,
    sendNumbersLength: number, msgId: string, resendStateIsRcs?: boolean): void {
    let sendResults: LooseObject[] = actionData.sendResults;
    if (sendResults.length == 0) {
      return;
    }
    // conversation list groups
    // 此处调用处传递的sendResults的数量为1 群聊会话需要单独加判断sendNumbersLength > 1 条件
    if (sendResults.length === sendNumbersLength || sendNumbersLength > 1) {
      let param: LooseObject = this.dealSendResults(sendResults);
      let sendStatus: number = param.sendStatus as number;
      if (sendNumbersLength > 1 && !ObjectUtil.isUndefAndNull(sendResults[0].groupSendStatus)) {
        sendStatus = sendResults[0].groupSendStatus as number;
        HiLog.i(TAG, 'updateSessionAndDetail group sending_status is : ' + sendStatus);
      }
      // Update the status of the session list.
      let valueBucket: ValuesBucket = {
        'sending_status': sendStatus,
        'content': param.content
      }
      if (param.sendStatus === common.int.SEND_MESSAGE_FAILED) {
        HiLog.i(TAG, 'updateSessionAndDetail sending_status is : ' + param.sendStatus);
      }
      ConversationListService.getInstance().updateSessionByCondition(context, actionData, valueBucket, null, true);
    }
    // Update the status of the information list.
    for (let sendResult of sendResults) {
      actionData.sendStatus = sendResult.sendStatus;
      if (sendResult.sendStatus == common.int.SEND_MESSAGE_FAILED) {
        actionData.sendStatus = common.int.SEND_MESSAGE_FAILED;
      } else if (sendResult.sendStatus == common.int.SEND_MESSAGE_SUCCESS) {
        actionData.sendStatus = common.int.SEND_MESSAGE_SUCCESS;
      }else if (sendResult.sendStatus == common.int.RCS_SEND_OK) {
        actionData.sendStatus = common.int.RCS_SEND_OK;
      } else {
        actionData.sendStatus = common.int.SEND_MESSAGE_SENDING;
      }
      actionData.msgId = sendResult.id;
      sendType = this.updateSessionAndDetailPart(context, resendStateIsRcs, msgId, actionData, sendType, sendResult);
    }
  }

  private updateSessionAndDetailPart(context: Context, resendStateIsRcs: boolean | undefined, msgId: string,
                                     actionData: LooseObject, sendType: boolean, sendResult: LooseObject) {
    if (resendStateIsRcs === true) {
      let valueBucket: ValuesBucket = {
        'msg_id': msgId,
        'msg_state': actionData.sendStatus,
      };
      let mapImageMsgIdToData = EnhancedInfoTemporaryDataSource.getInstance().mapImageMsgIdToData;
      if (msgId && mapImageMsgIdToData?.get(msgId)?.isExistInfoInRcsInfoWithMsgId === false) {
        let clurSize = EnhancedInfoTemporaryDataSource.getInstance()
          .mapImageMsgIdToData.get(msgId)?.clurSize || 0;
        let totalSize = EnhancedInfoTemporaryDataSource.getInstance()
          .mapImageMsgIdToData.get(msgId)?.totalSize || 0;
        valueBucket['clur_size'] = clurSize;
        valueBucket['total_size'] = totalSize;
      }
      ConversationRcsService.getInstance().updateRcsMmsInfoByCondition(context, actionData, valueBucket, null);
    } else if (resendStateIsRcs === false) {
      let valueBucket: ValuesBucket = {
        'msg_state': actionData.sendStatus,
      };
      this.updateSmsMmsInfoByCondition(context, actionData, valueBucket, null);
    } else if (resendStateIsRcs == undefined) {
      if (sendType) {
        sendType = sendResult.isRcs;
      }
      if (sendType) {
        let valueBucket: ValuesBucket = {
          'msg_id': msgId,
          'msg_state': actionData.sendStatus,
        };
        let mapImageMsgIdToData = EnhancedInfoTemporaryDataSource.getInstance().mapImageMsgIdToData;
        if (msgId && mapImageMsgIdToData?.get(msgId)?.isExistInfoInRcsInfoWithMsgId === false) {
          let clurSize = EnhancedInfoTemporaryDataSource.getInstance()
            .mapImageMsgIdToData.get(msgId)?.clurSize || 0;
          let totalSize = EnhancedInfoTemporaryDataSource.getInstance()
            .mapImageMsgIdToData.get(msgId)?.totalSize || 0;
          valueBucket['clur_size'] = clurSize;
          valueBucket['total_size'] = totalSize;
        }
        ConversationRcsService.getInstance()
          .updateRcsMmsInfoByCondition(context, actionData, valueBucket, null);
      } else {
        let valueBucket: ValuesBucket = {
          'msg_state': actionData.sendStatus,
        };
        this.updateSmsMmsInfoByCondition(context, actionData, valueBucket, null);
      }
    }
    return sendType;
  }

  public saveImage(actionData: LooseObject, callback: Function, context: Context): void {
    callback('saveImage function to be developed!');
  }

  public gotoShare(actionData: LooseObject, callback: Function, context: Context): void {
    callback('gotoShare function to be developed!');
  }

  public dealContactsName(context: Context, telephones: string[], actionData: LooseObject,
    resultList: LooseObject[], callback: Function): void {
    actionData.telephones = telephones;
    actionData.hasDelete = '0';
    if (telephones.length == 0) {
      callback(resultList);
    }
    ContactsService.getInstance().queryContactDataByCondition(actionData, (res: resType) => {
      let groupIdMap: Record<string, Record<string, Object>> = {};
      if (res.code == common.int.FAILURE || res.abilityResult.length == 0) {
        groupIdMap = this.convertingMessageByGroup(resultList);
      } else {
        // Convert the result to Map, key: mobile number, value: name
        let telephoneMap = new Map<string, LooseObject>();
        let contacts:LooseObject[]  = res.abilityResult;
        for (let item of contacts) {
          if (item.displayName == common.STR.EMPTY_STR) {
            telephoneMap.set(item.detailInfo, item.detailInfo);
          } else {
            telephoneMap.set(item.detailInfo, item.displayName);
          }
        }
        // Match the result based on the mobile number.
        groupIdMap = this.getGroupIdMap(resultList, telephoneMap);
      }
      let lists: Record<string, Object>[] = [];
      let favoriteList: Record<string, Object>[] = [];
      for (let key of Object.keys(groupIdMap)) {
        let value = groupIdMap[key];
        let contactsNums: string[] = (value.telephone as string).split(common.STR.COMMA);
        value.contactsNum = contactsNums.length;
        if (value.isFavorite) {
          let temp: LooseObject = JSON.parse(JSON.stringify(value))!;
          temp.icon = '/common/icon/icon_favorite.svg';
          favoriteList.push(temp);
          value.isFavorite = false;
        }
        lists.push(value);
      }
      // Add favorite data to the search list.
      if (favoriteList.length > 0) {
        lists = lists.concat(favoriteList);
      }
      callback(lists);
    }, context);
  }

  public getGroupIdMap(resultList: LooseObject[], telephoneMap: Map<string, LooseObject>): LooseObject {
    let groupIdMap: Record<string, Record<string, Object>> = {};
    for (let map of resultList) {
      // Indicates the combination of multiple names. The names need to be displayed in combination.
      if (telephoneMap.has(map.telephone)) {
        map.name = telephoneMap.get(map.telephone);
        map.nameFormatter = map.name + '<' + map.telephoneFormat + '>';
      } else {
        map.nameFormatter = map.telephoneFormat;
      }
      if (Object.keys(groupIdMap).indexOf(map.groupId) > -1) {
        let list = groupIdMap[map.groupId];
        list.name = list.name + common.STR.COMMA + map.name;
        list.nameFormatter = list.nameFormatter + common.STR.COMMA + map.nameFormatter;
        list.telephone = list.telephone + common.STR.COMMA + map.telephone;
        list.telephoneFormat = list.telephoneFormat + common.STR.COMMA + map.telephoneFormat;
      } else {
        groupIdMap[map.groupId] = map;
      }
    }
    return groupIdMap;
  }

  public convertingMessageByGroup(resultList: LooseObject[]): LooseObject {
    let groupIdMap: Record<string, Record<string, Object>> = {};
    for (let element of resultList) {
      if (Object.keys(groupIdMap).indexOf(element.groupId) == -1) {
        groupIdMap[element.groupId] = element;
      }
    }
    return groupIdMap;
  }

  public statisticsUnreadNotify(callback: Function, context: Context): void {
    let actionData: LooseObject = {};
    actionData.hasRead = common.is_read.UN_READ;
    actionData.smsType = common.sms_type.NOTICE;
    this.querySmsMmsInfoSizeByCondition(actionData, (res: ResObj) => {
      if (res.code == common.int.SUCCESS) {
        callback(res.abilityResult);
      } else {
        HiLog.w(TAG, 'statisticsUnreadNotify fail!');
        callback(0);
      }
    }, context);
  }

  insertMmsInfoList(smsRes: LooseObject, mmsSource: Array<Mms>, mmsContext: Context) {
    HiLog.iw(TAG, 'insertMmsInfoList start');
    if (smsRes.initDatas && smsRes.initDatas.length > 0 && mmsSource && mmsSource.length > 0) {
      smsRes.initDatas.forEach((sms: LooseObject) => {
        mmsSource.forEach((item: Mms) => {
          let valueBucket: ValuesBucket = {
            'msg_id': (sms.rcs_id === 0 || !sms.rcs_id) ? sms.id : 0,
            'group_id': smsRes.groupId,
            'part_index': -1,
            'part_size': item.size ? item.size : common.STR.EMPTY_STR,
            'recording_time': item.duration ? item.duration : '',
            'type': item.type,
            'location_path': item.path ? item.path : common.STR.EMPTY_STR,
            'encode': 0,
            'state': 0,
            'ct': item.ct ?? common.STR.EMPTY_STR,
            'content': (item.type === commonData.ENHANCED_INFO_ITEM_TYPE.MAP) ? (item.content ?? '') :
              (item.text ? item.text : ''),
            // 资源文件附件引用计数-初始为1，其他模块复用（如收藏）引用计数 +1 （历史数据默认为-1）
            'reference_count': commonData.referenceCount.ONE,
            'rcs_id': sms.rcs_id,
          };
          this.insertMmsInfo(valueBucket, (res: LooseObject) => {
            if (res.code == common.int.SUCCESS) {
              HiLog.w(TAG, 'insertMmsInfo success');
            } else {
              HiLog.e(TAG, 'insertMmsInfo failed');
            }
          }, mmsContext);
        });
      })
    }
  }

  public insertMmsInfo(valueBucket: ValuesBucket, callback: Function, context: Context): void {
    if (GlobalContext.getContext().getObject('DataWorker') != null) {
      (GlobalContext.getContext()
        .getObject('DataWorker') as WorkerWrapper).sendRequest(common.RUN_IN_WORKER_METHOD.insertMmsInfo, {
        valueBucket: valueBucket,
        context: context
      } as ConversationServiceParamType, (res?: Object) => {
        if (callback) {
          callback(res);
        }
      });
    } else {
      this.conversationModel.insertMmsInfo(valueBucket, callback, context);
    }
  }

  public queryMmsPartInfo(actionData: LooseObject, callback: Function, context: Context) {
    HiLog.i(TAG, 'queryMmsPartInfo start mmsPartId:' + JSON.stringify(actionData));
    if (GlobalContext.getContext().getObject('DataWorker') != null) {
      (GlobalContext.getContext()
        .getObject('DataWorker') as WorkerWrapper).sendRequest(common.RUN_IN_WORKER_METHOD.queryMmsPartInfo, {
        actionData: actionData,
        context: context
      } as ConversationServiceParamType, (res?: LooseObject) => {
        if (callback) {
          callback(res);
        }
      });
    } else {
      this.conversationModel.queryMmsPartInfo(actionData, callback, context);
    }
  }

  public updateMmsPartById(mmsPartId: number, isFraud: number, callback: Function, context: Context): void {
    HiLog.iw(TAG, 'updateMmsPartById start, mmsPartId :' + mmsPartId + ', isFraud: ' + isFraud);
    let actionData: LooseObject = {};
    actionData.mmsPartId = mmsPartId;
    actionData.isFraud = isFraud;
    if (GlobalContext.getContext().getObject('DataWorker') != null) {
      (GlobalContext.getContext()
        .getObject('DataWorker') as WorkerWrapper).sendRequest(common.RUN_IN_WORKER_METHOD.updateMmsPartById, {
        actionData: actionData,
        context: context
      } as ConversationServiceParamType, (res?: Object) => {
        if (callback) {
          callback(res);
        }
      });
    } else {
      this.conversationModel.updateMmsPartById(actionData, callback, context);
    }
  }

  public updateMmsPartByCondition(context: Context, actionData: LooseObject, callback?: Function | null): void {
    if (GlobalContext.getContext().getObject('DataWorker') != null) {
      (GlobalContext.getContext()
        .getObject('DataWorker') as WorkerWrapper).sendRequest(common.RUN_IN_WORKER_METHOD.updateMmsPartById, {
        actionData: actionData,
        context: context
      } as ConversationServiceParamType, (res?: Object) => {
        if (callback) {
          callback(res);
        }
      });
    } else {
      if (callback) {
        this.conversationModel.updateMmsPartById(actionData, callback, context);
      }else {
        this.conversationModel.updateMmsPartById(actionData,()=>{}, context);
      }
    }
  }


  queryMmsInfoResponse(smsData: Array<LooseObject>, callback: Function, context: Context) {
    HiLog.i(TAG, 'queryMmsInfoResponse start smsData.length:' + smsData.length);
    let queryMsgIds: string[] = [];
    let queryRcsIds: string[] = [];
    for (let smsDataItem of smsData) {
      let rcsId: number = smsDataItem.rcsId;
      if (!Number.isInteger(smsDataItem.msgId) && rcsId > 0) {
        queryRcsIds.push(rcsId.toString());
      } else if (Number.isInteger(smsDataItem.msgId)) {
        queryMsgIds.push(smsDataItem.msgId);
      } else {
        HiLog.i(TAG, 'queryMmsInfo unknown msg.');
      }
    }
    this.queryMmsInfo(queryMsgIds, queryRcsIds, (res: queryMmsInfoResult) => {
      HiLog.i(TAG, 'queryMmsInfo response: ' + res.code);
      if (res.code == common.int.SUCCESS) {
        this.queryMmsInfoResult(smsData, res);
        callback(smsData);
      } else {
        callback(smsData);
      }
    }, context);
  }

  queryMmsInfoResult(smsData: Array<LooseObject>, res: queryMmsInfoResult) {
    let mmsList: Record<string, number | string>[] = res.abilityResult;
    let rcsMmsInfoMap = new HashMap<string, Record<string, string | number>[]>();
    let mmsMmsInfoMap = new HashMap<string, Record<string, string | number>[]>();
    for (let index = 0; index < mmsList?.length; index++) {
      let mms: Record<string, string | number> = mmsList[index];
      if (mms.rcsId) {
        // 保存到RCS的数据里面
        let value: Record<string, string | number>[] = rcsMmsInfoMap.get(mms.rcsId as string) || [];
        value.push(mms);
        rcsMmsInfoMap.set(mms.rcsId as string, value);
      } else {
        if (mms.type == common.MM_ATTACHMENT_TYPE.VIDEO) {
          let path: string = mms.path as string;
          let videoPath: string = path.replace('mp4', 'jpeg');
          videoPath = videoPath.replace('VIDEO', 'IMG_VIDEO');
          mms.imagePath = videoPath;
        }
        // 保存到MMS的数据里面
        let value: Record<string, string | number>[] = mmsMmsInfoMap.get(mms.msgId as string) || [];
        value.push(mms);
        mmsMmsInfoMap.set(mms.msgId as string, value);
      }
    }
    smsData.forEach(sms => { // 短信数据（会话表、RCS表）里面的数据和查询到的part表数据进行匹配
      if (sms.msgType !== 0) {
        sms.mmsList = [];
        if (sms.rcsType) {
          sms.mmsList = rcsMmsInfoMap.get(sms.rcsId) || [];
        } else {
          sms.mmsList = mmsMmsInfoMap.get(sms.msgId) || [];
        }
      }
    });
  }

  private queryMmsInfoResultPart(sms: LooseObject, mms: Record<string, string | number>) {
    if (sms.rcsType && sms.rcsId === mms.rcsId) {
      sms.mmsList.push(mms);
    }
    if (!mms.rcsId) {
      if (sms.msgId === mms.msgId && mms.type == common.MM_ATTACHMENT_TYPE.VIDEO) {
        let path: string = mms.path as string;
        let videoPath: string = path.replace('mp4', 'jpeg');
        videoPath = videoPath.replace('VIDEO', 'IMG_VIDEO');
        mms.imagePath = videoPath;
        sms.mmsList.push(mms);
      } else if (sms.msgId === mms.msgId) {
        sms.mmsList.push(mms);
      }
    }
  }

  queryMmsInfo(queryMsgIds: string[], queryRcsIds: string[], callback: Function, context: Context) {
    let actionData: LooseObject = {};
    actionData.queryMsgIds = queryMsgIds;
    actionData.queryRcsIds = queryRcsIds;
    if (GlobalContext.getContext().getObject('DataWorker') != null) {
      (GlobalContext.getContext()
        .getObject('DataWorker') as WorkerWrapper).sendRequest(common.RUN_IN_WORKER_METHOD.queryMmsInfo, {
        actionData: actionData,
        context: context,
      } as ConversationServiceParamType, (res?: Object) => {
        callback(res);
      });
    } else {
      this.conversationModel.queryMmsInfo(actionData, callback, context);
    }
  }

  public deleteMmsInfoByCondition(context: Context, actionData: LooseObject, callback: Function | null): void {
    if (GlobalContext.getContext().getObject('DataWorker') != null) {
      (GlobalContext.getContext()
        .getObject('DataWorker') as WorkerWrapper).sendRequest(common.RUN_IN_WORKER_METHOD.deleteMmsInfoByCondition, {
        actionData: actionData,
        context: context
      } as ConversationServiceParamType, (res?: Object) => {
        if (callback) {
          callback(res);
        }
      });
    } else {
      this.conversationModel.deleteMmsInfoByCondition(actionData, callback, context);
    }
  }

  checkWhetherHasMms(smsData: Array<LooseObject>): boolean {
    HiLog.i(TAG, 'checkWhetherHasMms');
    let hasMms: boolean = false;
    for (let index = 0; index < smsData.length; index++) {
      const element = smsData[index];
      if (element.msgType === common.MSG_TYPE.MMS) {
        HiLog.i(TAG, 'has mms');
        hasMms = true;
        break;
      }
    }
    return hasMms;
  }
  private hasRcsMsg(rcsCount?:number):boolean{
    return rcsCount!=undefined&&rcsCount>0;
  }


  insertNoReceiverDraft(context: Context, actionData: LooseObject) {
    HiLog.i(TAG, 'insertNoReceiverDraft')
    let initDatas: LooseObject[] = [];
    this.queryMaxGroupIdInMmsInfoTable(async(res) => {
      let groupId: number = 0;
      if (res.code == common.int.SUCCESS) {
        groupId = Number(res.abilityResult);
        this.maxGroupId = this.maxGroupId > groupId ? this.maxGroupId + 1 : groupId + 1;
        groupId = this.maxGroupId;
      } else {
        HiLog.w(TAG, 'dealInsertMessageDetail, queryMaxGroupId failed');
        return;
      }
      HiLog.i(TAG, 'maxGroupId is:' + JSON.stringify(groupId))
      let param = ConversationListService.getInstance().dealSendResults(actionData);
      let valueBucket: LooseObject = [];
      valueBucket = await this.buildInsertSmsMmsRow(param, actionData, {
        sendStatus: common.int.SEND_DRAFT
      }, groupId);
      valueBucket.is_read = common.is_read.READ;
      this.insertSmsMmsInfo(valueBucket, (res: Record<string, string>) => {
        let initData: Record<string, number | string> = {
          'id': res.abilityResult,
        };
        initDatas.push(initData);
        let result: LooseObject = {};
        result.initDatas = initDatas;
        result.groupId = groupId;
        ConversationService.getInstance()
          .insertMmsInfoList(result, actionData.mmsSource, context);
      }, context);
    }, context);
  }

  queryMessageNoReceiverDraft(context: Context, actionData: LooseObject, callback: Function, rcsCount: number): void {
    HiLog.i(TAG, 'queryMessageNoReceiverDraft In:')
    this.querySmsMmsInfoByConditionAll(context, actionData, (res1: resType) => {
      if (res1.code == common.int.FAILURE) {
        HiLog.e(TAG, 'querySmsMmsInfoByConditionAll FAILURE')
        return
      }
      if (res1.abilityResult && res1.abilityResult.length != undefined && res1.abilityResult.length > 0) {
        res1.abilityResult = res1.abilityResult.filter((item: LooseObject) => item.receiverNumber == '' && item.senderNumber == '');
        this.queryMessageDetailResultAll(res1, actionData, callback, context, rcsCount);
      }
    });
  }

  buildInsertSmsMmsRowValueBucket(maxGroupId: number, threadId?: number) {
    let valueBucket: ValuesBucket = {
      'slot_id': common.int.SIM_ONE,
      'receiver_number': common.STR.EMPTY_STR,
      'sender_number': common.STR.EMPTY_STR,
      'start_time': common.STR.EMPTY_STR,
      'end_time': common.STR.EMPTY_STR,
      'msg_type': common.MSG_TYPE.NORMAL,
      'sms_type': common.sms_type.COMMON,
      'msg_title': common.STR.EMPTY_STR,
      'msg_content': common.STR.EMPTY_STR,
      'msg_state': common.int.SEND_MESSAGE_SENDING,
      'mms_pdu': common.STR.EMPTY_STR,
      'msg_code': common.STR.EMPTY_STR,
      'msg_code_str': common.STR.EMPTY_STR,
      'session_id': threadId ? threadId : null,
      'is_lock': common.is_lock.NO,
      'is_read': common.is_read.UN_READ,
      'is_collect': common.is_collect.NOT_FAVORITE,
      'session_type': common.session_type.COMMON,
      'is_sender': common.is_sender.NO,
      'group_id': maxGroupId,
      'is_send_report': common.is_send_report.NO,
      'is_advanced_security': common.ADVANCED_SECURITY_MODE.ORDINARY,
      'expires_time': common.STR.EMPTY_STR
    };
    return valueBucket;
  }

  queryCtFromMmsInfo(item: LooseObject, result: LooseObject) {
    let list : LooseObject = item.mmsList;
    for ( list of item.mmsList ) {
      if (list.ct.startsWith('image', 'audio') || list.ct.startsWith('audio')) {
        result.ct = list.ct;
      }
    }
    return result;
  }

  convertConversationListResult(context: Context, item: LooseObject, tempRcsId: number, tempSatelliteId: number,
    tempIsIpMsg: boolean = false) {
    let result: LooseObject = {};
    result.showTitle = tempIsIpMsg !== item.isIpMsg || tempRcsId !== item.isRcs;
    result.id = item.msgId;
    if (item && item.mmsList ) {
      this.queryCtFromMmsInfo(item, result);
    } else {
      result.ct = '';
    }
    ConversationIpService.getInstance().updateIpMsgInfo(item, result);
    result.rcsId = item.rcsId;
    result.content = item.msgContent;
    result.detectResContent = item.detectResContent;
    result.isRcs = item.isRcs as number;
    result.smsType = item.smsType;
    if (item.isCollect) {
      result.is_collect = item.isCollect == 0 ? false : true;
    } else {
      result.is_collect = false
    }
    // Fields related to MMS messages
    result.msgType = item.msgType;
    result.isFullScreenImg = true;
    result.isReport = item.isReport;
    result.senderNumber = item.senderNumber;
    result.read = item.isRead == 0 ? '0' : '1';
    result.sendStatus = item.msgState;
    result.receiveState = item.receiveState;
    result.failReceiveContext = item.failReceiveContext;
    result.subId = item.slotId;
    result.msgCode = item.msgCode;
    result.msgCodeStr = item.msgCodeStr;
    result.receiverNumber = item.receiverNumber;
    result.startTime = item.startTime;
    result.msgTitle = item.msgTitle;
    result.sessionType = item.sessionType;
    result.groupId = item.groupId;
    result.isSender = item.isSender;
    result.telephone = item.isSender ? item.senderNumber : item.receiverNumber;
    result.detectResContent = item.detectResContent;

    this.convertConversationListResultPart(context, item, result);
    return result;
  }

  private convertConversationListResultPart(context: Context, item: LooseObject, result: LooseObject) {
    if (item.isRcs == common.MESSAGE_TYPE.SMS_OR_MMS) {
      result.isMsm = item.msgType == common.MSG_TYPE.MMS ? true : false;
    } else {
      result.isMsm = item.rcsType ? true : false;
    }
    result.timeMillisecond = item.startTime;
    result.isCbChecked = false;
    result.isDraft = false;
    // Fields related to group-sending
    result.groupId = item.groupId;
    // Determine whether it is the receiver or sender.
    result.isReceive = item.isSender == 0 ? false : true;
    result.date = common.STR.EMPTY_STR;
    result.time = common.STR.EMPTY_STR;
    result.completeNumber = 0;
    result.failuresNumber = 0;
    result.isAdvancedSecurity = item.isAdvancedSecurity === 1 ? true : false;
    result.hasReport = item.isSendReport ? (item.isSendReport == 0 ? false : true) : false;
    result.isShowMsgLongMenu = false;
    this.convertList(result, item);
    result.mmsPdu = item.mmsPdu;
    result.msgState = item.msgState;
    result.expiresTime = item.expiresTime;
    result.rcsType = item.rcsType;
    result.clurSize = item.clurSize;
    result.totalSize = item.totalSize;
    result.riskUrlBody = item.riskUrlBody;
    result.receiverNumber = item.receiverNumber;
    result.startTime = item.startTime;
    result.msgTitle = item.msgTitle;
    result.sessionType = item.sessionType;
    result.groupId = item.groupId;
    result.isSender = item.isSender;
    result.detectResContent = item.detectResContent;
    result.isFraud = item.isFraud;
  }

  private convertList(result: LooseObject, item: LooseObject) {
    HiLog.i(TAG, `[convertList] result.isMsm: ${result.isMsm}`);
    if (!result.isMsm) { // text
      result.msgShowType = common.MESSAGE_SHOW_TYPE.NORMAL;
      result.contentType = common.MMS_CONTENT_TYPE.ORIGIN;
    } else { //rich media
      HiLog.i(TAG, `[convertList] item.isRcs: ${item.isRcs}`);
      if (item.isRcs == common.MESSAGE_TYPE.SMS_OR_MMS) {
        result.mmsSource = MmsUtil.getMmsSourceFromRequest(item.mmsList, (type: number) => {
          result.msgShowType = type;
        });
        result.contentType = MmsUtil.getMmsContentType(result.mmsSource, result.msgTitle);
      } else { //Enhanced Info
        result.msgShowType = common.MESSAGE_SHOW_TYPE.NORMAL;
        result.mmsSource = MmsUtil.getRcsSourceFromRequest(item.mmsList, result.content);
        HiLog.i(TAG, `[convertList] item.rcsType: ${item.rcsType}`);
        if (item.rcsType === commonData.ENHANCED_INFO_ITEM_TYPE.IMAGE) {
          result.contentType = MmsUtil.getMmsContentType(result.mmsSource);
          result.content = '';
        } else if (item.rcsType === commonData.ENHANCED_INFO_ITEM_TYPE.VCARD) {
          result.contentType = common.MMS_CONTENT_TYPE.VCARD;
          result.content = '';
        } else if (item.rcsType === commonData.ENHANCED_INFO_ITEM_TYPE.FILE) {
          result.contentType = common.MMS_CONTENT_TYPE.FILE;
          result.content = '';
        } else if (item.rcsType === commonData.ENHANCED_INFO_ITEM_TYPE.CHATBOT_CARD) {
          result.contentType = common.MMS_CONTENT_TYPE.ORIGIN;
        } else {
          result.contentType = common.MMS_CONTENT_TYPE.ORIGIN;
          result.content = '';
        }
      }
    }
    HiLog.i(TAG, `[convertList] result.contentType: ${result.contentType}`);
  }

  queryNotDownloadInfo(actionData: Record<string, string>, callback: Function, context: Context) {
    if (GlobalContext.getContext().getObject('DataWorker') != null) {
      (GlobalContext.getContext()
        .getObject('DataWorker') as WorkerWrapper).sendRequest(common.RUN_IN_WORKER_METHOD.queryMmsNotDownloadInfo, {
        actionData: actionData,
        context: context
      } as ConversationServiceParamType, (res?: Object) => {
        callback(res);
      });
    } else {
      this.conversationModel.queryMmsNotDownloadInfo(actionData, callback, context);
    }
  }

  queryMmsNotDownloadInfo(actionData: Record<string, string>, callback: Function, context: Context) {
    this.queryNotDownloadInfo(actionData, (res: resType) => {
      if (res.code == commonData.int.SUCCESS && res.abilityResult && res.abilityResult.length > 0) {
        HiLog.i(TAG, 'queryMmsNotDownloadInfo success');
        let list: LooseObject[] = res.abilityResult;
        callback(list[0]);
      } else {
        HiLog.e(TAG, 'queryMmsNotDownloadInfo failed');
        callback();
      }
    }, context);
  }

  public updateSmsIsReadBySessionId(context: Context, actionData: Record<string, string>, callback?: Function | null) {
    if (GlobalContext.getContext().getObject('DataWorker') != null) {
      (GlobalContext.getContext()
        .getObject('DataWorker') as WorkerWrapper).sendRequest(common.RUN_IN_WORKER_METHOD.updateSmsIsReadBySessionId, {
        actionData: actionData,
        context: context
      } as ConversationServiceParamType, (res?: Object) => {
        if (callback) {
          callback(res);
        }
      });
    } else {
      this.conversationModel.updateSmsIsReadBySessionId(actionData, context, callback);
    }
  }

  public updateSmsInfoSmsTypeBySessionIds(actionData: Record<string, number[]>, callback: Function, context: Context) {
    if (GlobalContext.getContext().getObject('DataWorker') != null) {
      (GlobalContext.getContext()
        .getObject('DataWorker') as WorkerWrapper).sendRequest(common.RUN_IN_WORKER_METHOD.updateSmsInfoSmsTypeBySessionIds, {
        actionData: actionData,
        context: context
      } as ConversationServiceParamType, (res?: Object) => {
        if (callback) {
          callback(res);
        }
      });
    } else {
      this.conversationModel.updateSmsInfoSmsTypeBySessionIds(actionData, callback, context);
    }
  }

  public queryContactsAvatarInContactDataDataBase(context: Context, contactIds: number[],
    callback: (res: LooseObject) => void): void {
    queryContactsAvatarInContactDataDataBase(context, contactIds, (res: LooseObject) => {
      callback(res);
    })
  }

  querySessionId(msgId: number, callback: Function, context: Context) {
    let actionData: LooseObject = {};
    actionData.msgId = msgId;
    if (GlobalContext.getContext().getObject('DataWorker') != null) {
      (GlobalContext.getContext()
        .getObject('DataWorker') as WorkerWrapper).sendRequest(common.RUN_IN_WORKER_METHOD.querySessionId, {
        actionData: actionData,
        context: context
      } as ConversationServiceParamType, (res: Object) => {
        callback(res);
      });
    } else {
      this.conversationModel.querySessionId(actionData, callback, context);
    }
  }
}