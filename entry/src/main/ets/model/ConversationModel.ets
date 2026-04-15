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

import dataShare from '@ohos.data.dataShare';
import dataSharePredicates from '@ohos.data.dataSharePredicates';

import BaseModel from './BaseModel';
import common, { MarkRead } from '../data/commonData';
import mmsTable from '../data/tableData';
import HiLog from '../utils/HiLog';
import LooseObject from '../data/LooseObject';
import StringUtil from '../utils/StringUtil';
import { BusinessError } from '@ohos.base';
import { ValuesBucket } from '@ohos.data.ValuesBucket';
import DataShareResultSet from '@ohos.data.DataShareResultSet';
import DataShareHelper from './repository/DataShareHelper';
import Constant from '../data/Constant';
import commonData from '../data/commonData';
import dotCommon, { dotNoNeedParmas, invalidDataParmas } from '../utils/MmsDot/DotCommon';
import DotUtil from '../utils/MmsDot/DotUtils';
import { GlobalContext } from '../MainAbility/GlobalHelper';
import myCommon from '@ohos.app.ability.common';
import lazy { mmsListType } from '../pages/conversation/conversationController';
import { taskpool } from '@kit.ArkTS';
import { IQueryActionData, QuerySmsMmsInfoActionDataFactory } from './type/QuerySmsMmsInfoActionData';
import { hiSysEvent } from '@kit.PerformanceAnalysisKit';

const TAG = 'ConversationModel';


export default class ConversationModel extends BaseModel {
  public async deleteTemporaryDb(callback: Function, context: Context) {
    let dataHelper:dataShare.DataShareHelper | undefined = await DataShareHelper.getInstance().initSmsDB(context);
    if (!dataHelper) {
      HiLog.e(TAG, '[deleteTemporaryDb] createDataShareHelper fail');
      if (callback) {
        callback(0);
      }
      return;
    }
    dataHelper = dataHelper as dataShare.DataShareHelper;
    let condition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    let managerUri: string = common.STR.URI_MESSAGE_LOG + common.STR.URI_DELETE_TEMPORARY_DB;
    dataHelper.delete(managerUri, condition).then(res => {
      if (callback) {
        callback(res);
      }
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'deleteTemporaryDb fail, error: ' + JSON.stringify(error));
      if (callback) {
        callback(0);
      }
    });
  }

  public async batchInsertSmsMmsInfo(valueBuckets: ValuesBucket[], context: Context): Promise<number> {
    let dataHelper:dataShare.DataShareHelper | undefined = await DataShareHelper.getInstance().initSmsDB(context);
    if (!dataHelper) {
      HiLog.e(TAG, '[batchInsertSmsMmsInfo] createDataShareHelper fail');
      return common.int.FAILURE;
    }

    let result: number = common.int.SUCCESS;
    dataHelper = dataHelper as dataShare.DataShareHelper;
    let managerUri: string = common.STR.URI_MESSAGE_LOG + common.STR.URI_MESSAGE_INFO_TABLE;
    await dataHelper.batchInsert(managerUri, valueBuckets).then(res => {
      if (res < 0) {
        result = common.int.FAILURE;
      }
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'batchInsertSmsMmsInfo fail, error: ' + JSON.stringify(error));
      result = common.int.FAILURE;
    });
    return result;
  }

  public async insertSmsMmsInfo(valueBucket: ValuesBucket, callback: Function, context: Context): Promise<void> {
    let dataHelper:dataShare.DataShareHelper | undefined = await DataShareHelper.getInstance().initSmsDB(context);
    if (!dataHelper) {
      HiLog.e(TAG, '[insertSmsMmsInfo] createDataShareHelper fail');
      if (callback) {
        callback(this.encapsulateReturnCode(common.int.FAILURE));
      }
      return;
    }
    dataHelper = dataHelper as dataShare.DataShareHelper;
    let managerUri: string = common.STR.URI_MESSAGE_LOG + common.STR.URI_MESSAGE_INFO_TABLE;
    dataHelper.insert(managerUri, valueBucket).then(res => {
      if (callback) {
        callback(this.encapsulateReturnResult(common.int.SUCCESS, res));
      }
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'insertSmsMmsInfo fail, error: ' + JSON.stringify(error));
      if (callback) {
        callback(this.encapsulateReturnCode(common.int.FAILURE));
      }
    });
  }

  public async deleteSmsMmsInfoByCondition(actionData: LooseObject, callback: Function | null, context: Context): Promise<void> {
    let dataHelper:dataShare.DataShareHelper | undefined = await DataShareHelper.getInstance().initSmsDB(context);
    if (!dataHelper) {
      HiLog.e(TAG, '[deleteSmsMmsInfoByCondition] createDataShareHelper fail');
      if (callback) {
        callback(this.encapsulateReturnCode(common.int.FAILURE));
      }
      return;
    }
    let condition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    if (actionData.deleteMessage === common.deleteMessage.DELETEALL) {
      condition = this.buildDeleteAllSmsMmsInfoCondition(actionData);
    } else if (actionData.deleteMessage === common.deleteMessage.DELETEUNCHECK) {
      condition = this.buildDeleteUnCheckSmsMmsInfoCondition(actionData);
    } else {
      condition = this.buildQuerySmsMmsInfoCondition(actionData);
    }
    let managerUri: string = common.STR.URI_MESSAGE_LOG + common.STR.URI_MESSAGE_INFO_TABLE;
    HiLog.e(TAG, 'deleteSmsMmsInfoByCondition start, group id is ' + JSON.stringify(actionData.groupId));
    dataHelper.delete(managerUri, condition).then(res => {
      HiLog.e(TAG, 'deleteSmsMmsInfoByCondition success res.length: ' + JSON.stringify(res).length);
      if (callback) {
        callback(this.encapsulateReturnResult(common.int.SUCCESS, res));
      }
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'deleteSmsMmsInfoByCondition fail, error: ' + JSON.stringify(error));
      if (callback) {
        callback(this.encapsulateReturnCode(common.int.FAILURE));
      }
    });
  }

  public async updateSmsMmsInfoByCondition(actionData: LooseObject, valueBucket: ValuesBucket, callback: Function | null, context: Context): Promise<void> {
    let dataHelper:dataShare.DataShareHelper | undefined = await DataShareHelper.getInstance().initSmsDB(context);
    if (!dataHelper) {
      HiLog.e(TAG, '[updateSmsMmsInfoByCondition] createDataShareHelper fail');
      if (callback) {
        callback(this.encapsulateReturnCode(common.int.FAILURE));
      }
      return;
    }
    let condition: dataSharePredicates.DataSharePredicates = this.buildQuerySmsMmsInfoCondition(actionData);
    let managerUri = common.STR.URI_MESSAGE_LOG + common.STR.URI_MESSAGE_INFO_TABLE;
    dataHelper.update(managerUri, condition, valueBucket).then((res: number) => {
      if (callback) {
        callback(this.encapsulateReturnResult(common.int.SUCCESS, res));
      }
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'updateSmsMmsInfoByCondition fail, error: ' + JSON.stringify(error));
      if (callback) {
        callback(this.encapsulateReturnCode(common.int.FAILURE));
      }
    });
  }

  public async batchUpdateSmsMmsInfo(valueBuckets: ValuesBucket[], context: Context): Promise<number> {
    let dataHelper:dataShare.DataShareHelper | undefined = await DataShareHelper.getInstance().initSmsDB(context);
    if (!dataHelper) {
      HiLog.e(TAG, '[batchUpdateSmsMmsInfo] createDataShareHelper fail');
      return common.int.FAILURE;
    }

    let result: number = common.int.SUCCESS;
    let managerUri = common.STR.URI_MESSAGE_LOG + common.STR.URI_MESSAGE_INFO_TABLE;
    valueBuckets.forEach(async (bucket) => {
      let condition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
      condition.equalTo('rcs_id', bucket.rcs_id as number);
      // 更新单条
      await dataHelper!.update(managerUri, condition, bucket).then((res: number) => {
        if (res < 0) {
          result = common.int.FAILURE;
        }
      }).catch((error: BusinessError) => {
        HiLog.e(TAG, 'batchUpdateSmsMmsInfo fail, error: ' + JSON.stringify(error));
        result = common.int.FAILURE;
      });
    });
    return result;
  }

  /**
   * 根据msgIds查询存在的信息id集合
   *
   * @param msgIds 信息id集合
   * @param context 上下文
   * @returns 存在的信息id集合
   */
  public async querySmsMmsInfoByMsgIds(msgIds: number[], context: Context): Promise<number[]> {
    if (!context || !msgIds || msgIds.length < 1) {
      HiLog.e(TAG, 'querySmsMmsInfoByMsgIds params invalid');
      return [];
    }
    let dataHelper:dataShare.DataShareHelper | undefined = await DataShareHelper.getInstance().initSmsDB(context);
    if (!dataHelper) {
      HiLog.e(TAG, 'querySmsMmsInfoByMsgIds createDataShareHelper fail');
      return [];
    }
    let resultMsgId: number[] = [];
    let condition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    condition.in(mmsTable.messageInfo.msgId, msgIds);
    let managerUri = common.STR.URI_MESSAGE_LOG + common.STR.URI_MESSAGE_INFO_TABLE;
    try {
      let resultSet = await dataHelper.query(managerUri, condition, []);
      HiLog.i(TAG, `querySmsMmsInfoByMsgIds resultSet.length:${resultSet?.rowCount}`);
      if (resultSet.rowCount > 0) {
        while (resultSet.goToNextRow()) {
          resultMsgId.push(resultSet.getLong(resultSet.getColumnIndex('msg_id')));
        }
      }
      resultSet.close();
    } catch (error) {
      HiLog.e(TAG, 'querySmsMmsInfoByMsgIds fail, error: ' + JSON.stringify(error));
    }
    HiLog.i(TAG, `querySmsMmsInfoByMsgIds resultMsgId.length:${resultMsgId?.length}`);
    return resultMsgId;
  }

  /**
   * 根据rcsIds查询存在的信息id集合
   *
   * @param rcsIds 信息id集合
   * @param context 上下文
   * @returns 存在的信息id集合
   */
  public async queryRCSInfoByMsgIds(rcsIds: number[], context: Context): Promise<number[]> {
    if (!context || !rcsIds || rcsIds.length < 1) {
      HiLog.e(TAG, 'queryRCSInfoByMsgIds params invalid');
      return [];
    }
    let dataHelper:dataShare.DataShareHelper | undefined = await DataShareHelper.getInstance().initSmsDB(context);
    if (!dataHelper) {
      HiLog.e(TAG, 'queryRCSInfoByMsgIds createDataShareHelper fail');
      return [];
    }
    let resultRcsId: number[] = [];
    let condition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    condition.in(mmsTable.rcsMessageInfo.rcsId, rcsIds);
    let managerUri = common.STR.URI_MESSAGE_LOG + common.STR.URI_RCS_MESSAGE_INFO_TABLE;
    try {
      let resultSet = await dataHelper.query(managerUri, condition, []);
      HiLog.i(TAG, `queryRCSInfoByMsgIds resultSet.length:${resultSet?.rowCount}`);
      if (resultSet.rowCount > 0) {
        while (resultSet.goToNextRow()) {
          resultRcsId.push(resultSet.getLong(resultSet.getColumnIndex('rcs_id')));
        }
      }
      resultSet.close();
    } catch (error) {
      HiLog.e(TAG, 'queryRCSInfoByMsgIds fail, error: ' + JSON.stringify(error));
    }
    HiLog.i(TAG, `queryRCSInfoByMsgIds resultRcsId.length:${resultRcsId?.length}`);
    return resultRcsId;
  }

  public async updateSmsMmsInfoStateByCondition(actionData: LooseObject, valueBucket: ValuesBucket,
    callback: Function | null, context: Context): Promise<void> {
    let dataHelper: dataShare.DataShareHelper | undefined = await DataShareHelper.getInstance().initSmsDB(context);
    if (!dataHelper) {
      HiLog.e(TAG, '[updateSmsMmsInfoStateByCondition] createDataShareHelper fail');
      if (callback) {
        callback(this.encapsulateReturnCode(common.int.FAILURE));
      }
      return;
    }
    let condition: dataSharePredicates.DataSharePredicates = this.buildQuerySmsMmsInfoStatusCondition(actionData);
    let managerUri = common.STR.URI_MESSAGE_LOG + common.STR.URI_MESSAGE_INFO_TABLE;
    dataHelper.update(managerUri, condition, valueBucket).then((res: number) => {
      if (callback) {
        callback(this.encapsulateReturnResult(common.int.SUCCESS, res));
      }
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'updateSmsMmsInfoStateByCondition fail, error: ' + JSON.stringify(error));
      if (callback) {
        callback(this.encapsulateReturnCode(common.int.FAILURE));
      }
    });
  }

  public async insertMsgFavorite(valueBucket: ValuesBucket, callback: Function | null,
    context: Context): Promise<void> {
    let dataHelper:dataShare.DataShareHelper | undefined = await DataShareHelper.getInstance().initSmsDB(context);
    if (!dataHelper) {
      if (callback) {
        callback(this.encapsulateReturnCode(common.int.FAILURE));
      }
      return;
    }
    dataHelper = dataHelper as dataShare.DataShareHelper;
    let managerUri: string = common.STR.URI_MESSAGE_LOG + common.STR.URI_MESSAGE_INFO_FAVORATE_TABLE;
    try {
      dataHelper.insert(managerUri, valueBucket).then(res => {
        if (callback) {
          callback(this.encapsulateReturnResult(common.int.SUCCESS, res));
        }
      })
    } catch (err) {
      if (callback) {
        callback(this.encapsulateReturnCode(common.int.FAILURE));
      }
    }
  }

  public async deleteFavorite(msgId: string | number, callback: Function | null, context: Context): Promise<void> {
    let dataHelper:dataShare.DataShareHelper | undefined = await DataShareHelper.getInstance().initSmsDB(context);
    if (!dataHelper) {
      if (callback) {
        callback(this.encapsulateReturnCode(common.int.FAILURE));
      }
      return;
    }
    let managerUri: string = common.STR.URI_MESSAGE_LOG + common.STR.URI_MESSAGE_INFO_FAVORATE_TABLE;
    let condition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    condition.equalTo('msg_id', msgId)

    dataHelper.delete(managerUri, condition).then(res => {
      if (callback) {
        callback(this.encapsulateReturnResult(common.int.SUCCESS, res));
      }
    }).catch((error: BusinessError) => {
      if (callback) {
        callback(this.encapsulateReturnCode(common.int.FAILURE));
      }
    });
  }

  public async updateSmsMmsInfoByRcsID(actionData: LooseObject, valueBucket: ValuesBucket,
    callback: Function | null, context: Context): Promise<void> {
    let dataHelper: dataShare.DataShareHelper | undefined = await DataShareHelper.getInstance().initSmsDB(context);
    if (!dataHelper) {
      HiLog.e(TAG, '[updateSmsMmsInfoByRcsID] createDataShareHelper fail');
      if (callback) {
        callback(this.encapsulateReturnCode(common.int.FAILURE));
      }
      return;
    }
    let condition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    condition.equalTo(mmsTable.messageInfo.rcsId, actionData.rcsId)
    let managerUri = common.STR.URI_MESSAGE_LOG + common.STR.URI_MESSAGE_INFO_TABLE;
    dataHelper.update(managerUri, condition, valueBucket).then((res: number) => {
      if (callback) {
        callback(this.encapsulateReturnResult(common.int.SUCCESS, res));
      }
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'updateSmsMmsInfoByRcsID fail, error: ' + JSON.stringify(error));
      if (callback) {
        callback(this.encapsulateReturnCode(common.int.FAILURE));
      }
    });
  }

  public async querySmsMmsInfoSlotIdByCondition(phoneNumber: string, callback: Function, context: Context): Promise<void> {
    let dataHelper:dataShare.DataShareHelper | undefined = await DataShareHelper.getInstance().initSmsDB(context);
    if (!dataHelper) {
      HiLog.e(TAG, '[querySmsMmsInfoSlotIdByCondition] createDataShareHelper fail');
      if (callback) {
        callback(this.encapsulateReturnCode(common.int.FAILURE));
      }
      return;
    }
    let managerUri = common.STR.URI_MESSAGE_LOG + common.STR.URI_MESSAGE_INFO_TABLE;
    let condition: dataSharePredicates.DataSharePredicates = this.buildSmsMmsInfoSlotIdCondition(phoneNumber)
    dataHelper.query(managerUri, condition, ['slot_id']).then((resultSet) => {
      let slotId = -1;
      if (resultSet.rowCount > 0) {
        resultSet.goToFirstRow();
        slotId = resultSet.getLong(0);
      }
      callback(this.encapsulateReturnResult(common.int.SUCCESS, slotId));
      resultSet.close();
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'querySmsMmsInfoSlotIdByCondition fail, error: ' + JSON.stringify(error));
      callback(this.encapsulateReturnCode(common.int.FAILURE));
    })
  }

  public async querySmsMmsInfoRcsIdByCondition(msgId: string, context: Context) {
    HiLog.i(TAG, 'querySmsMmsInfoRcsIdByCondition start! :');
    let rcsId = 0;
    let dataHelper: dataShare.DataShareHelper | undefined = await DataShareHelper.getInstance().initSmsDB(context);
    try {
      if (!dataHelper) {
        HiLog.e(TAG, '[querySmsMmsInfoRcsIdByCondition] createDataShareHelper fail');
        return rcsId;
      }
      let managerUri = common.STR.URI_MESSAGE_LOG + common.STR.URI_MESSAGE_INFO_TABLE;
      let condition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
      condition.equalTo('msg_id', msgId)
      let resultSet = await dataHelper.query(managerUri, condition, ['rcs_id'])
      if (resultSet != undefined && resultSet.goToFirstRow()) {
        rcsId = resultSet.getLong(0);
      }
      resultSet.close();
      return rcsId;
    } catch (e) {
      HiLog.w(TAG, 'query RcsId error : ' + JSON.stringify(e));
      return rcsId;
    }
  }

  public async querySmsMmsInfoByCondition(actionData: LooseObject, callback: Function, context: Context): Promise<void> {
    let dataHelper:dataShare.DataShareHelper | undefined = await DataShareHelper.getInstance().initSmsDB(context);
    if (!dataHelper) {
      HiLog.e(TAG, '[querySmsMmsInfoByCondition] createDataShareHelper fail');
      if (callback) {
        callback(this.encapsulateReturnCode(common.int.FAILURE));
      }
      return;
    }
    let condition: dataSharePredicates.DataSharePredicates = this.buildQuerySmsMmsInfoCondition(actionData);
    let managerUri = common.STR.URI_MESSAGE_LOG + common.STR.URI_MESSAGE_INFO_TABLE;
    HiLog.i(TAG, '[querySmsMmsInfoByCondition] before query')
    dataHelper.query(managerUri, condition, this.buildSmsMmsInfoTableColumns()).then(resultSet => {
      HiLog.i(TAG, '[querySmsMmsInfoByCondition] proceed query, rowCount: ' + resultSet.rowCount)
      let resultList: LooseObject[] = [];
      if (resultSet.rowCount > 0) {
        while (resultSet.goToNextRow()) {
          resultList.push(this.buildSmsMmsInfoResult(resultSet));
        }
      }
      HiLog.i(TAG, '[querySmsMmsInfoByCondition] proceed query before callback')
      callback(this.encapsulateReturnResult(common.int.SUCCESS, resultList));
      resultSet.close();
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'querySmsMmsInfoByCondition fail, error: ' + JSON.stringify(error));
      callback(this.encapsulateReturnCode(common.int.FAILURE));
    });
  }

  public async querySmsMmsInfoByConditionAll(actionData: LooseObject, callback: Function, context: Context): Promise<void> {
    let dataHelper:dataShare.DataShareHelper | undefined = await DataShareHelper.getInstance().initSmsDB(context);
    if (!dataHelper) {
      HiLog.e(TAG, '[querySmsMmsInfoByConditionAll] createDataShareHelper fail');
      if (callback) {
        callback(this.encapsulateReturnCode(common.int.FAILURE));
      }
      return;
    }
    let queryActionData: IQueryActionData | undefined = QuerySmsMmsInfoActionDataFactory.create(actionData);
    //1.未来逐步将已知的查询转移到QuerySmsMmsInfoActionDataFactory进行创建,避免随意添加查询条件影响性能和功能;
    //2.对于未知的查询场景，还是用this.buildQuerySmsMmsInfoCondition(actionData)进行兜底.
    let condition: dataSharePredicates.DataSharePredicates | undefined = undefined
    let managerUri = common.STR.URI_MESSAGE_LOG + common.STR.URI_MESSAGE_INFO_ALL_CUSTOMIZED_TABLE;
    if (queryActionData !== undefined && queryActionData.loadData(actionData)) {
      condition = queryActionData.buildQueryCondition();
      HiLog.i(TAG, 'use: ' + queryActionData.actionDataName)
    } else {
      condition = this.buildQuerySmsMmsInfoCondition(actionData)
      managerUri = common.STR.URI_MESSAGE_LOG + common.STR.URI_MESSAGE_INFO_ALL_TABLE;
    }
    HiLog.i(TAG, 'querySmsMmsInfoByConditionAll query uri is: ' + managerUri);
    HiLog.i(TAG, 'querySmsMmsInfoByConditionAll before query');
    dataHelper.query(managerUri, condition, ['*']).then(resultSet => {
      HiLog.i(TAG, 'querySmsMmsInfoByConditionAll query count:' + resultSet.rowCount);
      let resultList: Array<LooseObject> = [];
      if (resultSet.rowCount > 0) {
        while (resultSet.goToNextRow()) {
          resultList.push(this.buildMmsRcsInfoResult(resultSet));
        }
      }
      HiLog.i(TAG, 'querySmsMmsInfoByConditionAll success:' + resultList.length);
      callback(this.encapsulateReturnResult(common.int.SUCCESS, resultList));
      resultSet.close();
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'querySmsMmsInfoByCondition fail, error: ' + JSON.stringify(error));
      // 短信数据库异常fault打点
      DotUtil.getInstance().reportFaultEvent(dotNoNeedParmas, dotCommon.faultEventName.SMS_DATABASE_ERROR);
      callback(this.encapsulateReturnCode(common.int.FAILURE));
    });
  }

  /**
   * 通过msgId和threadId查询出对应会话中对应短信的index，用于搜索跳转
   *
   * @param actionData 搜索参数
   * @param context 上下文
   * @returns 对应会话中对应短信的index
   */
  public async querySmsMmsSearchIndexByCondition(actionData: LooseObject, context: Context): Promise<number> {
    HiLog.i(TAG, 'querySmsMmsSearchIndexByCondition start! :');
    let finalRank = -1;

    let dataHelper: dataShare.DataShareHelper | undefined = await DataShareHelper.getInstance().initSmsDB(context);
    try {
      if (!dataHelper) {
        HiLog.e(TAG, 'querySmsMmsSearchIndexByCondition createDataShareHelper fail');
        return finalRank;
      }
      let managerUri = common.STR.URI_MESSAGE_LOG + common.STR.URI_MESSAGE_INFO_SEARCH_INDEX_TABLE;
      let condition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
      condition.and().equalTo('msgId', Number(actionData?.msgId));
      condition.and().equalTo('threadId', Number(actionData?.threadId));
      condition.and().equalTo('sessionType', Number(actionData?.contactsNum) > 1 ? 1 : 0);
      let resultSet = await dataHelper.query(managerUri, condition, ['final_rank'])
      if (resultSet != undefined && resultSet.goToFirstRow()) {
        finalRank = resultSet.getLong(resultSet.getColumnIndex('final_rank'));
        finalRank--;
      }
      resultSet.close();
      return finalRank;
    } catch (err) {
      HiLog.e(TAG, ` querySmsMmsSearchIndexByCondition failed, code is ${err?.code}, message is ${err?.message}`);
      return finalRank;
    }
  }

  public async queryMmsInfoByFavoriteCondition(actionData: LooseObject,
                                               callback: Function, context: Context): Promise<void> {
    let dataHelper:dataShare.DataShareHelper | undefined = await DataShareHelper.getInstance().initSmsDB(context);
    if (!dataHelper) {
      HiLog.e(TAG, '[queryMmsInfoByFavoriteCondition] createDataShareHelper fail');
      if (callback) {
        callback(this.encapsulateReturnCode(common.int.FAILURE));
      }
      return;
    }
    let condition: dataSharePredicates.DataSharePredicates = this.buildQueryMmsInfoFavoriteCondition(actionData);
    let managerUri = common.STR.URI_MESSAGE_LOG + common.STR.URI_MESSAGE_MMS_PART;
    dataHelper.query(managerUri, condition, this.buildMmsInfoFavoriteTableColumns()).then(resultSet => {
      let resultList: Array<LooseObject> = [];
      if (resultSet.rowCount > 0) {
        while (resultSet.goToNextRow()) {
          resultList.push(this.buildMmsInfoFavoriteResult(resultSet));
        }
      }
      callback(this.encapsulateReturnResult(common.int.SUCCESS, resultList));
      resultSet.close();
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'querySmsMmsInfoByFavoriteCondition fail, error: ' + JSON.stringify(error));
      callback(this.encapsulateReturnCode(common.int.FAILURE));
    });
  }

  public async queryMmsInfoLastReadMsgCondition(actionData: LooseObject,
    callback: Function, context: Context): Promise<void> {
    let dataHelper:dataShare.DataShareHelper | undefined = await DataShareHelper.getInstance().initSmsDB(context);
    if (!dataHelper) {
      HiLog.e(TAG, '[queryMmsInfoLastReadMsgCondition] createDataShareHelper fail');
      if (callback) {
        callback(this.encapsulateReturnCode(common.int.FAILURE));
      }
      return;
    }
    let condition: dataSharePredicates.DataSharePredicates = this.buildQueryMmsInfoLastReadCondition(actionData);
    let managerUri = common.STR.URI_MESSAGE_LOG + common.STR.URI_MESSAGE_INFO_ALL_TABLE;
    dataHelper.query(managerUri, condition, this.buildMmsInfoLastReadTableColumns()).then(resultSet => {
      let resultList: Array<LooseObject> = [];
      HiLog.i(TAG, '[queryMmsInfoLastReadMsgCondition] createDataShareHelper rowCount:' + resultSet.rowCount);
      if (resultSet.rowCount > 0) {
        while (resultSet.goToNextRow()) {
          resultList.push(this.buildMmsInfoLastReadResult(resultSet));
        }
      }
      callback(this.encapsulateReturnResult(common.int.SUCCESS, resultList));
      resultSet.close();
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'queryMmsInfoLastReadMsgCondition fail, error: ' + JSON.stringify(error));
      callback(this.encapsulateReturnCode(common.int.FAILURE));
    });
  }

  public async queryFavoriteAllInfoByCondition(actionData: LooseObject,
    callback: Function, context: Context): Promise<void> {
    let dataHelper: dataShare.DataShareHelper | undefined = await DataShareHelper.getInstance().initSmsDB(context);
    if (!dataHelper) {
      HiLog.e(TAG, '[queryFavoriteAllInfoByCondition] createDataShareHelper fail');
      if (callback) {
        callback(this.encapsulateReturnCode(common.int.FAILURE));
      }
      return;
    }
    let condition: dataSharePredicates.DataSharePredicates = this.buildQueryFavoriteAllInfoCondition(actionData);
    let managerUri = common.STR.URI_MESSAGE_LOG + common.STR.URI_MESSAGE_INFO_FAVORATE_TABLE;
    let finaResultSet: DataShareResultSet;
    dataHelper.query(managerUri, condition, this.buildMmsFavoriteinfoTableColumns()).then(resultSet => {
      finaResultSet = resultSet;
      let resultList: Array<LooseObject> = [];
      if (resultSet.rowCount > 0) {
        while (resultSet.goToNextRow()) {
          resultList.push(this.buildFavoriteInfoResult(resultSet));
        }
      }
      callback(this.encapsulateReturnResult(common.int.SUCCESS, resultList));
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'queryFavoriteAllInfoByCondition fail, error: ' + JSON.stringify(error));
      callback(this.encapsulateReturnCode(common.int.FAILURE));
    }).finally(()=>{
      if (finaResultSet) {
        finaResultSet.close();
      }
    });
  }

  public async queryAllInfoByFavoriteCondition(actionData: LooseObject,
                                               callback: Function, context: Context):Promise<void> {
    HiLog.i(TAG, 'queryRcsMmsInfoByMsgId queryRcsMmsInfoByMsgIdHandleQuery');
    let dataHelper:dataShare.DataShareHelper | undefined = await DataShareHelper.getInstance().initSmsDB(context);
    if (!dataHelper) {
      HiLog.e(TAG, '[queryAllInfoByFavoriteCondition] createDataShareHelper fail');
      if (callback) {
        callback(this.encapsulateReturnCode(common.int.FAILURE));
      }
      return;
    }
    let managerUri: string = common.STR.URI_MESSAGE_LOG + common.STR.URI_MESSAGE_INFO_FAVORATE_TABLE;
    let condition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    dataHelper.query(managerUri, condition, ['*']).then(resultSet => {
      let resultList: Array<LooseObject> = [];
      if (resultSet.rowCount > 0) {
        while (resultSet.goToNextRow()) {
          resultList.push(this.buildMmsRcsInfoResult(resultSet));
        }
      }
      callback(this.encapsulateReturnResult(common.int.SUCCESS, resultList));
      resultSet.close();
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'queryAllInfoByFavoriteCondition fail, error: ' + JSON.stringify(error));
      callback(this.encapsulateReturnCode(common.int.FAILURE));
    });
  }

  public async queryAllInfoSizeByCondition(actionData: LooseObject,
                                           callback: Function, context: Context): Promise<void> {
    let dataHelper: dataShare.DataShareHelper | undefined = await DataShareHelper.getInstance().initSmsDB(context);
    if (!dataHelper) {
      HiLog.e(TAG, '[queryAllInfoSizeByCondition] createDataShareHelper fail');
      if (callback) {
        callback(this.encapsulateReturnCode(common.int.FAILURE));
      }
      return;
    }
    let condition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    if (actionData.threadId != null) {
      if (actionData.needDistinct) {
        condition.groupBy([mmsTable.messageInfo.groupId]).distinct();
        condition.and().equalTo(mmsTable.messageInfo.sessionId, actionData.threadId);
      } else {
        condition.and().equalTo(mmsTable.messageInfo.sessionId, actionData.threadId);
      }
    }
    condition.and().equalTo(mmsTable.messageInfo.isBlocked, Constant.NO_BLOCK);
    let managerUri = common.STR.URI_MESSAGE_LOG + common.STR.URI_MESSAGE_INFO_ALL_TABLE;
    HiLog.i(TAG, 'queryAllInfoSizeByCondition begin');
    dataHelper.query(managerUri, condition, ['*']).then(resultSet => {
      callback(this.encapsulateReturnResult(common.int.SUCCESS, resultSet.rowCount));
      resultSet.close();
      HiLog.i(TAG, 'queryAllInfoSizeByCondition end');
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'queryAllInfoSizeByCondition fail, error: ' + JSON.stringify(error));
      callback(this.encapsulateReturnCode(common.int.FAILURE));
    });
  }

  public async querySmsMmsInfoSizeByCondition(actionData: LooseObject, callback: Function, context: Context): Promise<void> {
    let dataHelper:dataShare.DataShareHelper | undefined = await DataShareHelper.getInstance().initSmsDB(context);
    if (!dataHelper) {
      HiLog.e(TAG, '[querySmsMmsInfoSizeByCondition] createDataShareHelper fail');
      if (callback) {
        callback(this.encapsulateReturnCode(common.int.FAILURE));
      }
      return;
    }
    let condition: dataSharePredicates.DataSharePredicates = this.buildQuerySmsMmsInfoCondition(actionData);
    condition.and().equalTo(mmsTable.messageInfo.isBlocked, Constant.NO_BLOCK);
    let managerUri = common.STR.URI_MESSAGE_LOG + common.STR.URI_MESSAGE_INFO_TABLE;
    let queryStr = 'count(distinct group_id) as total';
    if (actionData.contactsNum && actionData.contactsNum == 1) {
      queryStr = 'count(*) as total'
    }
    dataHelper.query(managerUri, condition, [queryStr]).then((resultSet: DataShareResultSet) => {
      if (resultSet.rowCount <= 0) {
        resultSet.close();
        callback(this.encapsulateReturnCode(common.int.FAILURE));
        return;
      }
      resultSet.goToFirstRow();
      let smsMmsTotal = resultSet.getLong(resultSet.getColumnIndex('total'));
      HiLog.i(TAG, 'querySmsMmsInfoSizeByCondition, total: ' + smsMmsTotal);
      callback(this.encapsulateReturnResult(common.int.SUCCESS, smsMmsTotal));
      resultSet.close();
      return;
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'querySmsMmsInfoSizeByCondition fail, error: ' + JSON.stringify(error));
      callback(this.encapsulateReturnCode(common.int.FAILURE));
    });
  }

  public async queryMaxGroupId(callback: Function, context: Context): Promise<void> {
    let dataHelper:dataShare.DataShareHelper | undefined = await DataShareHelper.getInstance().initSmsDB(context);
    if (!dataHelper) {
      HiLog.e(TAG, '[queryMaxGroupId] createDataShareHelper fail');
      if (callback) {
        callback(this.encapsulateReturnCode(common.int.FAILURE));
      }
      return;
    }
    let resultColumns: Array<string> = ['maxGroupId'];
    let condition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    let managerUri: string = common.STR.URI_MESSAGE_LOG + common.STR.URI_MESSAGE_MAX_GROUP;
    dataHelper.query(managerUri, condition, resultColumns).then(resultSet => {
      let maxGroupId: number = 0;
      if (resultSet.rowCount > 0) {
        if (resultSet.goToLastRow()) {
          maxGroupId = (resultSet.getString(0) == common.STR.EMPTY_STR) ? 0 : Number(resultSet.getString(0));
          HiLog.w(TAG, 'queryMaxGroupId, maxGroupId: ' + maxGroupId);
        }
      }
      callback(this.encapsulateReturnResult(common.int.SUCCESS, maxGroupId));
      resultSet.close();
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'queryMaxGroupId fail, error: ' + JSON.stringify(error));
      callback(this.encapsulateReturnCode(common.int.FAILURE));
    });
  }

  public async statisticalData(callback: Function, context: Context) {
    let dataHelper:dataShare.DataShareHelper | undefined = await DataShareHelper.getInstance().initSmsDB(context);
    if (!dataHelper) {
      HiLog.e(TAG, '[statisticalData] createDataShareHelper fail');
      if (callback) {
        callback(this.encapsulateReturnCode(common.int.FAILURE));
      }
      return;
    }
    let resultColumns: Array<string> = [
      'totalListCount',
      'unreadCount',
      'unreadInfo',
      'unreadTotalOfInfo'
    ];
    let condition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    let managerUri: string = common.STR.URI_MESSAGE_LOG + common.STR.URI_MESSAGE_UNREAD_COUNT;
    dataHelper.query(managerUri, condition, resultColumns).then(resultSet => {
      let result: Record<string, number> = {
        'totalListCount': 0,
        'unreadCount': 0,
        'unreadInfo': 0,
        'unreadTotalOfInfo': 0
      };
      // resultSet是否有有效返回值
      let isReturnEffectiveValue: boolean = false;
      if (resultSet.rowCount > 0) {
        if (resultSet.goToLastRow()) {
          let totalListCount = resultSet.getLong(0);
          result.totalListCount = totalListCount < 0 ? 0 : totalListCount;
          let unreadCount = resultSet.getLong(1);
          result.unreadCount = unreadCount < 0 ? 0 : unreadCount;
          let unreadInfo = resultSet.getLong(2);
          result.unreadInfo = unreadInfo < 0 ? 0 : unreadInfo;
          let unreadTotalOfInfo = resultSet.getLong(3);
          result.unreadTotalOfInfo = unreadTotalOfInfo < 0 ? 0 : unreadTotalOfInfo;
          isReturnEffectiveValue = true;
          HiLog.i(TAG, '[statisticalData] totalListCount: ' + totalListCount + ', unreadCount: ' + unreadCount +
            ', unreadInfo: ' + unreadInfo + ', unreadTotalOfInfo: ' + unreadTotalOfInfo);
        }
      }
      if (isReturnEffectiveValue) {
        callback(this.encapsulateReturnResult(common.int.SUCCESS, result));
      } else {
        HiLog.w(TAG, `statisticalData, isReturnEffectiveValue is false`);
        callback(this.encapsulateReturnCode(common.int.FAILURE));
      }
      resultSet.close();
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'statisticalData, error: ' + JSON.stringify(error));
      callback(this.encapsulateReturnCode(common.int.FAILURE));
    });
  }

  public async selectInfoCount(callback: Function, context: Context) {
    HiLog.i(TAG, `selectInfoCount start`)
    let dataHelper:dataShare.DataShareHelper | undefined = await DataShareHelper.getInstance().initSmsDB(context);
    if (!dataHelper) {
      HiLog.e(TAG, '[statisticalData] createDataShareHelper fail');
      if (callback) {
        callback(this.encapsulateReturnCode(common.int.FAILURE));
      }
      return;
    }
    let resultColumns: Array<string> = [
      'msgNumTotal',
      'rcsNumTotal',
      'totalNum'
    ];
    let condition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    let managerUri: string = common.STR.URI_MESSAGE_LOG + common.STR.URI_MESSAGE_SELECT_INFO_COUNT;
    dataHelper.query(managerUri, condition, resultColumns).then(resultSet => {
      let result: Record<string, number> = {
        'msgNumTotal': 0,
        'rcsNumTotal': 0,
        'totalNum': 0
      };
      if (resultSet.rowCount > 0) {
        if (resultSet.goToLastRow()) {
          let msgNumTotal = resultSet.getLong(0);
          result.msgNumTotal = msgNumTotal < 0 ? 0 : msgNumTotal;
          let rcsNumTotal = resultSet.getLong(1);
          result.rcsNumTotal = rcsNumTotal < 0 ? 0 : rcsNumTotal;
          let totalNum = resultSet.getLong(2);
          result.totalNum = totalNum < 0 ? 0 : totalNum;
          HiLog.i(TAG, 'msgNumTotal : ' + msgNumTotal + ' , rcsNumTotal : ' + rcsNumTotal +
            ' , totalNum : ' + totalNum)
        }
      }
      callback(this.encapsulateReturnResult(common.int.SUCCESS, result));
      resultSet.close();
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'selectInfoCount, error: ' + JSON.stringify(error));
      callback(this.encapsulateReturnCode(common.int.FAILURE));
    });
  }

  public async selectContactId(callback: Function, context: Context) {
    HiLog.i(TAG, `selectContactId start`)
    let dataHelper:dataShare.DataShareHelper | undefined = await DataShareHelper.getInstance().initSmsDB(context);
    if (!dataHelper) {
      HiLog.e(TAG, '[statisticalData] createDataShareHelper fail');
      if (callback) {
        callback(this.encapsulateReturnCode(common.int.FAILURE));
      }
      return;
    }
    let resultColumns: Array<string> = [
      'telephone',
      'contact_id'
    ];
    let condition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    let managerUri: string = common.STR.URI_MESSAGE_LOG + common.STR.URI_MESSAGE_SELECT_CONTACT_ID;
    dataHelper.query(managerUri, condition, resultColumns).then(resultSet => {
      let sessionContactIdMap = new Map<string, string>();
      if (resultSet.rowCount > 0) {
        while (resultSet.goToNextRow()) {
          let telephone = resultSet.getString(resultSet.getColumnIndex(mmsTable.sessionField.telephone));
          let contactId = resultSet.getString(resultSet.getColumnIndex(mmsTable.sessionField.contactId));
          sessionContactIdMap.set(telephone, contactId);
        }
      }
      callback(this.encapsulateReturnResult(common.int.SUCCESS, sessionContactIdMap));
      resultSet.close();
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'selectContactId, error: ' + JSON.stringify(error));
      callback(this.encapsulateReturnCode(common.int.FAILURE));
    });
  }

  private buildQueryMmsInfoFavoriteCondition(actionData: LooseObject): dataSharePredicates.DataSharePredicates {
    let condition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    if (actionData.rcsId) {
      condition.and().equalTo(mmsTable.mmsPart.rcsId, actionData.rcsId);
    }
    if (actionData.msgId) {
      condition.and().equalTo(mmsTable.mmsPart.msgId, actionData.msgId);
    }
    condition.and()
    condition.orderByDesc(mmsTable.mmsPart.msgId);
    return condition;
  }

  private buildQueryMmsInfoLastReadCondition(actionData: LooseObject): dataSharePredicates.DataSharePredicates {
    let condition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    HiLog.i(TAG, '[buildQueryMmsInfoLastReadCondition] createDataShareHelper sessionId:' + actionData.sessionId);
    if (actionData.sessionId) {
      condition.and().equalTo(mmsTable.messageInfo.sessionId, actionData.sessionId);
    }
    condition.and().equalTo(mmsTable.messageInfo.isRead, 1);
    condition.and().equalTo(mmsTable.messageInfo.isBlocked, 0);
    condition.limit(1, 0);
    condition.orderByDesc(mmsTable.messageInfo.startTime);
    return condition;
  }

  private buildQueryFavoriteAllInfoCondition(actionData: LooseObject): dataSharePredicates.DataSharePredicates {
    let condition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    condition.isNotNull(mmsTable.favorateInfo.msgId)
    condition.and()
    condition.orderByDesc(mmsTable.favorateInfo.msgId);
    return condition;
  }

  public buildQuerySmsMmsInfoFavoriteCondition(actionData:LooseObject) : dataSharePredicates.DataSharePredicates {
    let condition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    condition.isNotNull(mmsTable.messageInfo.msgId)
    if (actionData.isCollect != null) {
      condition.equalTo(mmsTable.messageInfo.isCollect, 1)
      condition.and()
      condition.orderByDesc(mmsTable.messageInfo.startTime);
    }
    return condition;
  }

  private buildQuerySmsMmsInfoCondition(actionData: LooseObject): dataSharePredicates.DataSharePredicates {
    let condition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    if (actionData.isNoReceiverDraft) {
      condition.isNull(mmsTable.messageInfo.sessionId);
    } else {
      condition.isNotNull(mmsTable.messageInfo.msgId)
      if (actionData.threadId != null) {
        if (actionData.needDistinct) {
          condition.groupBy([mmsTable.messageInfo.groupId]).distinct();
          condition.and().equalTo(mmsTable.messageInfo.sessionId, actionData.threadId);
        } else {
          condition.and().equalTo(mmsTable.messageInfo.sessionId, actionData.threadId);
        }
      }
      this.buildConditionFromQuerySmsMmsInfo(actionData, condition);
      if (actionData.uncheckedThreadIds != null && actionData.uncheckedThreadIds.length > 0) {
        condition.and().notIn(mmsTable.messageInfo.sessionId, actionData.uncheckedThreadIds);
      }
      if (actionData.page != null) {
        let limit: number = StringUtil.getLimitForSmsMmsInfo(actionData.page, actionData.contactsNum);
        let offset: number = StringUtil.getOffsetForSmsMmsInfo(actionData.page, actionData.contactsNum);
        if (actionData.isCustomSearch) {
          limit = actionData.limit;
          offset = actionData.offset;
        }
        condition.limit(limit, offset);
      }
      if (actionData.content && actionData.content !== '') {
        condition.and().like(mmsTable.messageInfo.msgContent, '%' + actionData.content + '%');
        condition.orderByDesc(mmsTable.messageInfo.startTime);
      } else {
        condition.orderByDesc(mmsTable.messageInfo.startTime);
      }
      if (actionData.smsType !== undefined && actionData.currentTimeStamp !== undefined) {
        condition.and().equalTo(mmsTable.messageInfo.smsType, actionData.smsType).and().beginWrap()
          .lessThan('start_time', actionData.currentTimeStamp - 0 - common.int.MILLISECOND_OF_ONE_MONTH)
          .endWrap()
      }
      if (actionData.threadId && actionData.orderByTimeDesc && actionData.limit) {
        condition.and()
          .equalTo(mmsTable.messageInfo.sessionId, actionData.threadId)
          .orderByDesc(mmsTable.sessionField.time)
          .limit(1, 1);
      }
      if (actionData.noRcs != undefined && actionData.noRcs) {
        condition.and().lessThan(mmsTable.messageInfo.smsType, common.sms_type.RCS)
      }
    }
    return condition;
  }

  private buildQuerySmsMmsInfoStatusCondition(actionData: LooseObject): dataSharePredicates.DataSharePredicates {
    let condition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    condition.isNotNull(mmsTable.messageInfo.msgId)
    if (actionData.msgIds != null && actionData.msgIds.length > 0) {
      condition.and().in(mmsTable.messageInfo.msgId, actionData.msgIds);
    }
    return condition;
  }

  private buildDeleteAllSmsMmsInfoCondition(actionData: LooseObject): dataSharePredicates.DataSharePredicates {
    let condition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    if (actionData.smsType != null) {
      //只删除信息，不删除通知
      condition.beginWrap().equalTo(mmsTable.messageInfo.smsType, actionData.smsType).endWrap();
    } else {
      //所有信息都删除
      condition.beginWrap().notEqualTo(mmsTable.messageInfo.smsType, -1).endWrap();
    }
    return condition;
  }

  private buildDeleteUnCheckSmsMmsInfoCondition(actionData: LooseObject): dataSharePredicates.DataSharePredicates {
    let condition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    //添加未选中条件
    if (actionData.uncheckedThreadIds != null && actionData.uncheckedThreadIds.length > 0) {
      condition.and().notIn(mmsTable.messageInfo.sessionId, actionData.uncheckedThreadIds);
    }
    return condition;
  }

  private buildConditionFromQuerySmsMmsInfo(actionData: LooseObject,
    condition: dataSharePredicates.DataSharePredicates) {
    if (actionData.hasRead != null) {
      condition.and().equalTo(mmsTable.messageInfo.isRead, actionData.hasRead);
    }
    if (actionData.smsType != null) {
      condition.and().equalTo(mmsTable.messageInfo.smsType, actionData.smsType);
    }
    if (actionData.msgId != null) {
      condition.and().equalTo(mmsTable.messageInfo.msgId, actionData.msgId);
    }
    if (actionData.rcsId != null) {
      condition.and().equalTo(mmsTable.messageInfo.rcsId, actionData.rcsId);
    }
    if (actionData.rcsIds != null && actionData.rcsIds.length > 0) {
      condition.and().in('rcs_id', actionData.rcsIds);
    }
    condition.and().equalTo(mmsTable.messageInfo.isBlocked, Constant.NO_BLOCK);
    if (actionData.isDraft != null && actionData.isDraft) {
      condition.and().equalTo(mmsTable.messageInfo.groupId, actionData.groupId);
      condition.and().equalTo(mmsTable.messageInfo.msgState, actionData.sendStatus);
    }
    if (actionData.threadIds != null && actionData.threadIds.length > 0) {
      condition.and().in(mmsTable.messageInfo.sessionId, actionData.threadIds);
    }

    if (actionData.msgIds != null && actionData.msgIds.length > 0) {
      condition.and().in(mmsTable.messageInfo.msgId, actionData.msgIds);
    }
    if (actionData.groupIds != null && actionData.groupIds.length > 0) {
      condition.and().in(mmsTable.messageInfo.groupId, actionData.groupIds);
    }
    if (actionData.groupId != null) {
      condition.and().equalTo(mmsTable.messageInfo.groupId, actionData.groupId);
    }
    if (actionData.msgType != null) {
      condition.and().equalTo(mmsTable.messageInfo.msgType, actionData.msgType);
    }
    if (actionData.msgState != null) {
      condition.and().equalTo(mmsTable.messageInfo.msgState, actionData.msgState);
    }
  }

  private buildMmsInfoFavoriteTableColumns(): Array<string> {
    let resultColumns: Array<string> = [
    mmsTable.mmsPart.msgId,
    mmsTable.mmsPart.rcsId,
    mmsTable.mmsPart.partIndex,
    mmsTable.mmsPart.type,
    mmsTable.mmsPart.locationPath,
    mmsTable.mmsPart.partSize,
    mmsTable.mmsPart.content,
    mmsTable.mmsPart.recordingTime,
      mmsTable.mmsPart.ct,
    ]
    return resultColumns
  }

  private buildMmsInfoLastReadTableColumns(): Array<string> {
    let resultColumns: Array<string> = [
      mmsTable.messageInfo.msgId,
      mmsTable.messageInfo.rcsId,
    ]
    return resultColumns
  }

  private buildMmsFavoriteinfoTableColumns(): Array<string> {
    let resultColumns: Array<string> = [
      mmsTable.favorateInfo.msgId,
      mmsTable.favorateInfo.rcsId,
      mmsTable.favorateInfo.partLocationPath,
      mmsTable.favorateInfo.partType,
      mmsTable.favorateInfo.partSize,
      mmsTable.favorateInfo.recordingTime,
      mmsTable.favorateInfo.receiverNumber,
      mmsTable.favorateInfo.senderNumber,
      mmsTable.favorateInfo.keepTime,
      mmsTable.favorateInfo.startTime,
      mmsTable.favorateInfo.msgType,
      mmsTable.favorateInfo.smsType,
      mmsTable.favorateInfo.msgTitle,
      mmsTable.favorateInfo.msgContent,
      mmsTable.favorateInfo.sessionType,
      mmsTable.favorateInfo.groupId,
      mmsTable.favorateInfo.isSender,
      mmsTable.favorateInfo.detectResContent
    ]
    return resultColumns
  }

  private buildSmsMmsInfoTableColumns(): Array<string> {
    let resultColumns: Array<string> = [
    mmsTable.messageInfo.msgId,
    mmsTable.messageInfo.rcsId,
    mmsTable.messageInfo.slotId,
    mmsTable.messageInfo.receiverNumber,
    mmsTable.messageInfo.senderNumber,
    mmsTable.messageInfo.startTime,
    mmsTable.messageInfo.endTime,
    mmsTable.messageInfo.msgType,
    mmsTable.messageInfo.smsType,
    mmsTable.messageInfo.msgTitle,
    mmsTable.messageInfo.msgContent,
    mmsTable.messageInfo.msgState,

    mmsTable.messageInfo.msgCode,
    mmsTable.messageInfo.msgCodeStr,
    mmsTable.messageInfo.isRead,
    mmsTable.messageInfo.isCollect,
    mmsTable.messageInfo.sessionType,
    mmsTable.messageInfo.sessionId,
    mmsTable.messageInfo.groupId,
    mmsTable.messageInfo.isSender,
    mmsTable.messageInfo.isSendReport,
    mmsTable.messageInfo.isAdvancedSecurity,
    mmsTable.messageInfo.expiresTime,
    mmsTable.messageInfo.mmsPdu,
    mmsTable.messageInfo.detectResContent,
    mmsTable.messageInfo.isReport
    ];
    return resultColumns;
  }

  private buildMmsInfoFavoriteResult(resultSet:DataShareResultSet):LooseObject {
    let result: LooseObject = {};
    result.msgId = Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.mmsPart.msgId)));
    result.rcsId = Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.mmsPart.rcsId)));
    result.partIndex = Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.mmsPart.partIndex)));
    result.type = Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.mmsPart.type)));
    result.ct = resultSet.getString(resultSet.getColumnIndex(mmsTable.mmsPart.ct));
    result.locationPath = resultSet.getString(resultSet.getColumnIndex(mmsTable.mmsPart.locationPath));
    result.content = resultSet.getString(resultSet.getColumnIndex(mmsTable.mmsPart.content));
    result.partSize = resultSet.getString(resultSet.getColumnIndex(mmsTable.mmsPart.partSize));
    result.recordingTime = resultSet.getString(resultSet.getColumnIndex(mmsTable.mmsPart.recordingTime));
    return result;
  }

  private buildMmsInfoLastReadResult(resultSet:DataShareResultSet):LooseObject {
    let result: LooseObject = {};
    result.msgId = Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.messageInfo.msgId)));
    result.rcsId = Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.messageInfo.rcsId)));
    return result;
  }

  private buildFavoriteInfoResult(resultSet: DataShareResultSet): LooseObject {
    let result: LooseObject = {};
    result.msgId = Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.favorateInfo.msgId)));
    result.rcsId = Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.favorateInfo.rcsId)));
    result.type = Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.favorateInfo.partType)));
    result.locationPath = resultSet.getString(resultSet.getColumnIndex(mmsTable.favorateInfo.partLocationPath));
    result.partSize = resultSet.getString(resultSet.getColumnIndex(mmsTable.favorateInfo.partSize));
    result.recordingTime = resultSet.getString(resultSet.getColumnIndex(mmsTable.favorateInfo.recordingTime));
    result.content = resultSet.getString(resultSet.getColumnIndex(mmsTable.favorateInfo.msgContent));
    result.partIndex = 0;
    result.ct = '';
    return result;
  }

  private buildSmsMmsInfoResult(resultSet: DataShareResultSet): LooseObject {
    let result: LooseObject = {};
    result.msgId = Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.messageInfo.msgId)));
    result.rcsId = Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.messageInfo.rcsId)));
    result.slotId = Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.messageInfo.slotId)));
    result.receiverNumber = resultSet.getString(resultSet.getColumnIndex(mmsTable.messageInfo.receiverNumber));
    result.senderNumber = resultSet.getString(resultSet.getColumnIndex(mmsTable.messageInfo.senderNumber));
    result.startTime = resultSet.getString(resultSet.getColumnIndex(mmsTable.messageInfo.startTime));
    result.endTime = resultSet.getString(resultSet.getColumnIndex(mmsTable.messageInfo.endTime));
    result.msgType = Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.messageInfo.msgType)));
    result.smsType = Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.messageInfo.smsType)));
    result.msgTitle = resultSet.getString(resultSet.getColumnIndex(mmsTable.messageInfo.msgTitle));
    result.msgContent = resultSet.getString(resultSet.getColumnIndex(mmsTable.messageInfo.msgContent));
    result.msgState = Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.messageInfo.msgState)));

    result.msgCode = Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.messageInfo.msgCode)));
    result.msgCodeStr = resultSet.getString(resultSet.getColumnIndex(mmsTable.messageInfo.msgCodeStr));
    result.isReport = Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.messageInfo.isReport)));
    result.isRead = Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.messageInfo.isRead)));
    result.isCollect = Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.messageInfo.isCollect)));
    result.sessionType = Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.messageInfo.sessionType)));
    result.sessionId = Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.messageInfo.sessionId)));
    result.groupId = Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.messageInfo.groupId)));
    result.isSender = Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.messageInfo.isSender)));
    result.isSendReport = Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.messageInfo.isSendReport)));
    result.isAdvancedSecurity = Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.messageInfo.isAdvancedSecurity)));
    result.expiresTime = Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.messageInfo.expiresTime)));
    result.mmsPdu = resultSet.getString(resultSet.getColumnIndex(mmsTable.messageInfo.mmsPdu));
    result.detectResContent = resultSet.getString(resultSet.getColumnIndex(mmsTable.messageInfo.detectResContent));
    return result;
  }

  private buildMmsRcsInfoResult(resultSet: DataShareResultSet): LooseObject {
    let result: LooseObject = {};
    result.slotId = resultSet.getLong(resultSet.getColumnIndex(mmsTable.messageInfo.slotId));
    result.receiverNumber = resultSet.getString(resultSet.getColumnIndex(mmsTable.messageInfo.receiverNumber));
    result.senderNumber = resultSet.getString(resultSet.getColumnIndex(mmsTable.messageInfo.senderNumber));
    result.startTime = resultSet.getLong(resultSet.getColumnIndex(mmsTable.rcsMessageInfo.startTime));
    result.endTime = resultSet.getString(resultSet.getColumnIndex(mmsTable.messageInfo.endTime));
    result.smsType = resultSet.getLong(resultSet.getColumnIndex(mmsTable.messageInfo.smsType));
    result.msgTitle = resultSet.getString(resultSet.getColumnIndex(mmsTable.messageInfo.msgTitle));
    result.msgContent = resultSet.getString(resultSet.getColumnIndex(mmsTable.messageInfo.msgContent));
    result.msgState = resultSet.getLong(resultSet.getColumnIndex(mmsTable.messageInfo.msgState));
    result.clurSize = resultSet.getLong(resultSet.getColumnIndex(mmsTable.rcsMessageInfo.clurSize));
    result.totalSize = resultSet.getLong(resultSet.getColumnIndex(mmsTable.rcsMessageInfo.totalSize));
    result.msgCode = resultSet.getLong(resultSet.getColumnIndex(mmsTable.messageInfo.msgCode));
    result.msgCodeStr = resultSet.getString(resultSet.getColumnIndex(mmsTable.messageInfo.msgCodeStr));
    result.isRead = resultSet.getLong(resultSet.getColumnIndex(mmsTable.messageInfo.isRead));
    result.isCollect = resultSet.getLong(resultSet.getColumnIndex(mmsTable.messageInfo.isCollect));
    result.sessionType = resultSet.getLong(resultSet.getColumnIndex(mmsTable.messageInfo.sessionType));
    result.sessionId = resultSet.getLong(resultSet.getColumnIndex(mmsTable.messageInfo.sessionId));
    result.groupId = resultSet.getLong(resultSet.getColumnIndex(mmsTable.messageInfo.groupId));
    result.partType = resultSet.getLong(resultSet.getColumnIndex(mmsTable.messageInfo.partType));
    result.partLocationPath = resultSet.getString(resultSet.getColumnIndex(mmsTable.messageInfo.partLocationPath));
    result.isSender = resultSet.getLong(resultSet.getColumnIndex(mmsTable.messageInfo.isSender));
    result.isSendReport = resultSet.getLong(resultSet.getColumnIndex(mmsTable.messageInfo.isSendReport));
    result.isAdvancedSecurity = resultSet.getLong(resultSet.getColumnIndex(mmsTable.messageInfo.isAdvancedSecurity));
    result.rcsId = resultSet.getLong(resultSet.getColumnIndex(mmsTable.rcsMessageInfo.rcsId));
    if (result.rcsId === undefined || result.rcsId === 0 || result.rcsId === '') {
      result.msgId = resultSet.getLong(resultSet.getColumnIndex(mmsTable.rcsMessageInfo.msgId));
      result.msgType = resultSet.getLong(resultSet.getColumnIndex(mmsTable.messageInfo.msgType));
      result.riskUrlBody = resultSet.getString(resultSet.getColumnIndex(mmsTable.messageInfo.riskUrlBody))
      result.isReport = resultSet.getString(resultSet.getColumnIndex(mmsTable.messageInfo.isReport));
    } else {
      result.msgId = resultSet.getString(resultSet.getColumnIndex(mmsTable.rcsMessageInfo.msgId));
      result.rcsType = resultSet.getLong(resultSet.getColumnIndex(mmsTable.rcsMessageInfo.rcsType));
      result.riskUrlBody = resultSet.getString(resultSet.getColumnIndex(mmsTable.rcsMessageInfo.riskUrlBody))
      result.isReport = resultSet.getString(resultSet.getColumnIndex(mmsTable.rcsMessageInfo.isReport));
    }
    result.detectResContent = resultSet.getString(resultSet.getColumnIndex(mmsTable.messageInfo.detectResContent));
    this.buildPart(result, resultSet);
    return result;
  }

  private buildPart(result: LooseObject, resultSet: DataShareResultSet) {
    result.enrichedCallingType = resultSet.getLong(
      resultSet.getColumnIndex(mmsTable.rcsMessageInfo.enrichedCallingType));
    result.networkType = resultSet.getString(resultSet.getColumnIndex(mmsTable.rcsMessageInfo.networkType));
    result.errorCode = resultSet.getLong(resultSet.getColumnIndex(mmsTable.rcsMessageInfo.errorCode));
    result.ownerAddr = resultSet.getString(resultSet.getColumnIndex(mmsTable.rcsMessageInfo.ownerAddr));
    result.privacyMode = resultSet.getLong(resultSet.getColumnIndex(mmsTable.rcsMessageInfo.privacyMode));
    result.protocol = resultSet.getLong(resultSet.getColumnIndex(mmsTable.rcsMessageInfo.protocol));
    result.replyPathPresent = resultSet.getLong(
      resultSet.getColumnIndex(mmsTable.rcsMessageInfo.replyPathPresent));
    result.seen = resultSet.getLong(resultSet.getColumnIndex(mmsTable.rcsMessageInfo.seen));
    result.serviceCenter = resultSet.getString(resultSet.getColumnIndex(mmsTable.rcsMessageInfo.serviceCenter));
    result.serviceKind = resultSet.getString(resultSet.getColumnIndex(mmsTable.rcsMessageInfo.serviceKind));
    result.receiveState = resultSet.getLong(resultSet.getColumnIndex(mmsTable.rcsMessageInfo.receiveState));
    result.failReceiveContext = resultSet.getString(
      resultSet.getColumnIndex(mmsTable.rcsMessageInfo.failReceiveContext));
    result.expiresTime = Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.messageInfo.expiresTime)));
    result.mmsPdu = resultSet.getString(resultSet.getColumnIndex(mmsTable.messageInfo.mmsPdu));
  }

  private buildSmsMmsInfoSlotIdCondition(phoneNumber: string): dataSharePredicates.DataSharePredicates {
    let condition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    condition.isNotNull(mmsTable.messageInfo.msgId)
    condition.and().equalTo(mmsTable.messageInfo.isBlocked, Constant.NO_BLOCK);
    if (phoneNumber != null && phoneNumber.length > 0) {
      condition.equalTo('receiver_number', phoneNumber)
        .or().equalTo('sender_number', phoneNumber)
      condition.orderByDesc('start_time');
      condition.limit(1, 0);
    }
    return condition;
  }

  public async insertMmsInfo(valueBucket: ValuesBucket, callback: Function, context: Context): Promise<void> {
    HiLog.w(TAG, 'insertMmsInfo start');
    let dataHelper:dataShare.DataShareHelper | undefined = await DataShareHelper.getInstance().initSmsDB(context);
    if (!dataHelper) {
      HiLog.e(TAG, '[insertMmsInfo] createDataShareHelper fail');
      if (callback) {
        callback(this.encapsulateReturnCode(common.int.FAILURE));
      }
      return;
    }
    let managerUri: string = common.STR.URI_MESSAGE_LOG + common.STR.URI_MESSAGE_MMS_PART;
    dataHelper.insert(managerUri, valueBucket).then(res => {
      if (callback) {
        HiLog.i(TAG, 'insertMmsInfo success');
        callback(this.encapsulateReturnResult(common.int.SUCCESS, res));
      }
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'insertMmsInfo fail, error: ' + JSON.stringify(error));
      if (callback) {
        callback(this.encapsulateReturnCode(common.int.FAILURE));
      }
    });
  }

  public async queryMmsPartInfo(actionData: LooseObject, callback: Function, context: Context) {
    let dataHelper:dataShare.DataShareHelper | undefined = await DataShareHelper.getInstance().initSmsDB(context);
    if (!dataHelper) {
      HiLog.e(TAG, '[queryMmsPartInfo] createDataShareHelper fail');
      return;
    }
    let condition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    if (actionData.msgId) {
      condition.equalTo(mmsTable.mmsPart.msgId, actionData.msgId);
    }
    if (actionData.rcsId) {
      condition.equalTo(mmsTable.mmsPart.rcsId, actionData.rcsId);
    }
    condition.equalTo(mmsTable.mmsPart.type, 1);
    let managerUri = common.STR.URI_MESSAGE_LOG + common.STR.URI_MESSAGE_MMS_PART;
    let resultList: Array<LooseObject> = [];
    dataHelper.query(managerUri, condition, [mmsTable.mmsPart.id, mmsTable.mmsPart.locationPath, mmsTable.mmsPart.partSize]).then(resultSet => {
      HiLog.i(TAG, 'queryMmsPartInfo response rowCount:' + resultSet.rowCount);
      if (resultSet.rowCount > 0) {
        while (resultSet.goToNextRow()) {
          let result: LooseObject = {};
          result.mmsPartId = resultSet.getLong(resultSet.getColumnIndex(mmsTable.mmsPart.id));
          result.locationPath = resultSet.getString(resultSet.getColumnIndex(mmsTable.mmsPart.locationPath));
          result.partSize = resultSet.getString(resultSet.getColumnIndex(mmsTable.mmsPart.partSize));
          resultList.push(result);
        }
        if (callback) {
          callback(resultList);
        }
      }
      resultSet.close();
    })
    return;
  }

  public async updateMmsPartById(actionData: LooseObject, callback: Function, context: Context) {
    let dataHelper:dataShare.DataShareHelper | undefined = await DataShareHelper.getInstance().initSmsDB(context);
    if (!dataHelper) {
      HiLog.e(TAG, '[updateMmsPartById] createDataShareHelper fail');
      return;
    }
    let vp: ValuesBucket|null = null;
    try {
      let condition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
      if (actionData?.mmsPartId) {
        condition.equalTo(mmsTable.mmsPart.id, actionData.mmsPartId);
        vp = {
          'is_fraud': actionData.isFraud
        }
      } else {
        // 收藏时更新mms_part表的引用计数为2
        vp = {
          'reference_count': commonData.referenceCount.TWO
        }
        if (actionData?.rcsId) {
          condition.equalTo(mmsTable.mmsPart.rcsId, actionData.rcsId)
            .and().beginWrap().equalTo(mmsTable.mmsPart.referenceCount, 1)
            .or().equalTo(mmsTable.mmsPart.referenceCount, -1).endWrap();
        } else if (actionData?.msgId) {
          condition.equalTo(mmsTable.mmsPart.msgId, actionData.msgId)
            .and().beginWrap().equalTo(mmsTable.mmsPart.referenceCount, 1)
            .or().equalTo(mmsTable.mmsPart.referenceCount, -1).endWrap();
        } else {
          HiLog.e(TAG, '[updateMmsPartById] param actionData invalid');
          return;
        }
      }
      let managerUri = common.STR.URI_MESSAGE_LOG + common.STR.URI_MESSAGE_MMS_PART;
      let data = await dataHelper.update(managerUri, condition, vp);
      if (callback) {
        callback(this.encapsulateReturnResult(common.int.SUCCESS, data));
      }
    } catch (e) {
      HiLog.w(TAG, 'updateMmsPartById error : ' + JSON.stringify(e));
      if (callback) {
        callback(this.encapsulateReturnCode(common.int.FAILURE));
      }
    }
  }

  public async queryMmsInfo(actionData: LooseObject, callback: Function, context: Context) {
    let dataHelper:dataShare.DataShareHelper | undefined = await DataShareHelper.getInstance().initSmsDB(context);
    if (!dataHelper) {
      HiLog.e(TAG, '[queryMmsInfo] createDataShareHelper fail');
      if (callback) {
        callback(this.encapsulateReturnCode(common.int.FAILURE));
      }
      return;
    }
    let condition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    let isEmpty = true;
    if (actionData.queryMsgIds?.length > 0) {
      condition.in(mmsTable.messageInfo.msgId, actionData.queryMsgIds);
      isEmpty = false;
    }
    if (actionData.queryRcsIds?.length > 0) {
      if (isEmpty) {
        condition.in(mmsTable.messageInfo.rcsId, actionData.queryRcsIds);
      } else {
        condition.or().in(mmsTable.messageInfo.rcsId, actionData.queryRcsIds);
      }
      isEmpty = false;
    }
    if (isEmpty) {
      HiLog.i(TAG, 'queryMmsInfo return empty list.');
      callback(this.encapsulateReturnResult(common.int.SUCCESS, []));
      return;
    }
    let managerUri = common.STR.URI_MESSAGE_LOG + common.STR.URI_MESSAGE_MMS_PART;
    HiLog.i(TAG, 'queryMmsInfo before query');
    dataHelper.query(managerUri, condition, null).then(resultSet => {
      HiLog.i(TAG, 'queryMmsInfo response rowCount:' + resultSet.rowCount);
      let resultList: Array<Record<string, number | string>> = [];
      if (resultSet.rowCount > 0) {
        while (resultSet.goToNextRow()) {
          let result: Record<string, number | string> = this.buildMmsInfoResult(resultSet);
          resultList.push(result);
        }
      }
      HiLog.i(TAG, 'queryMmsInfo response success:' + resultList.length);
      resultSet.close();
      callback(this.encapsulateReturnResult(common.int.SUCCESS,
        resultList.sort((a, b) => Number(a.type) - Number(b.type))));
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'queryMmsInfo fail, error: ' + JSON.stringify(error));
      callback(this.encapsulateReturnCode(common.int.FAILURE));
    });
  }

  public async deleteMmsInfoByCondition(actionData: LooseObject, callback: Function | null, context: Context): Promise<void> {
    HiLog.i(TAG, 'deleteMmsInfoByCondition start');
    let dataHelper:dataShare.DataShareHelper | undefined = await DataShareHelper.getInstance().initSmsDB(context);
    if (!dataHelper) {
      HiLog.e(TAG, '[deleteMmsInfoByCondition] createDataShareHelper fail');
      if (callback) {
        callback(this.encapsulateReturnCode(common.int.FAILURE));
      }
      return;
    }
    let condition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    if (actionData.groupId) {
      condition.beginWrap().isNull('rcs_id').or().equalTo('rcs_id', 0).endWrap()
      condition.and().equalTo('group_id', actionData.groupId)
    } else if (actionData.groupIds?.length > 0) {
      condition.beginWrap().isNull('rcs_id').or().equalTo('rcs_id', 0).endWrap()
      condition.and().in('group_id', actionData.groupIds)
    } else if (actionData.rcsId) {
      condition.equalTo('rcs_id', actionData.rcsId);
    } else if (actionData.rcsIds?.length > 0) {
      condition.in('rcs_id', actionData.rcsIds);
    } else if (actionData.msgId) {
      condition.equalTo('msg_id', actionData.msgId);
    } else {
      HiLog.i(TAG, 'deleteMmsInfoByCondition condition is empty');
      return;
    }
    let managerUri: string = common.STR.URI_MESSAGE_LOG + common.STR.URI_MESSAGE_MMS_PART;
    dataHelper.delete(managerUri, condition).then(res => {
      if (callback) {
        HiLog.i(TAG, 'deleteMmsInfoByCondition response success');
        callback(this.encapsulateReturnResult(common.int.SUCCESS, res));
      }
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'deleteMmsInfoByCondition fail, error: ' + JSON.stringify(error));
      if (callback) {
        callback(this.encapsulateReturnCode(common.int.FAILURE));
      }
    });
  }

  buildMmsInfoResult(resultSet: DataShareResultSet): Record<string, number | string> {
    let msgId: number = Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.messageInfo.msgId)));
    let groupId: number = Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.messageInfo.groupId)));
    let rcsId: number = Number(resultSet.getString(resultSet.getColumnIndex('rcs_id')));
    let partIndex: number = Number(resultSet.getString(resultSet.getColumnIndex('part_index')));
    let partSize: string = resultSet.getString(resultSet.getColumnIndex('part_size'));
    let recordingTime: string = resultSet.getString(resultSet.getColumnIndex('recording_time'));
    let type: number = Number(resultSet.getString(resultSet.getColumnIndex('type')));
    let ct: string = resultSet.getString(resultSet.getColumnIndex(mmsTable.mmsPart.ct));
    let path: string = resultSet.getString(resultSet.getColumnIndex('location_path'));
    let encode: number = Number(resultSet.getString(resultSet.getColumnIndex('encode')));
    let state: number = Number(resultSet.getString(resultSet.getColumnIndex('state')));
    let content: string = resultSet.getString(resultSet.getColumnIndex('content'));
    let clurSize: number = Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.rcsMessageInfo.clurSize)));
    let totalSize: number = Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.rcsMessageInfo.totalSize)));
    let isFraud = resultSet.getLong(resultSet.getColumnIndex(mmsTable.mmsPart.isFraud)) == 1 ? 1 : 0;
    let result: Record<string, number | string> = {
      'msgId': msgId,
      'groupId': groupId,
      'partIndex': partIndex,
      'partSize': partSize,
      'recordingTime': recordingTime,
      'type': type,
      'ct': ct,
      'path': path,
      'encode': encode,
      'state': state,
      'content': content,
      'rcsId': rcsId,
      'clurSize': clurSize,
      'totalSize': totalSize,
      'isFraud': isFraud
    };
    return result;
  }

  async queryMmsNotDownloadInfo(actionData: Record<string, string>, callback: Function, context: Context) {
    let dataHelper:dataShare.DataShareHelper | undefined = await DataShareHelper.getInstance().initSmsDB(context);
    if (!dataHelper) {
      HiLog.e(TAG, '[queryMmsNotDownloadInfo] createDataShareHelper fail');
      if (callback) {
        callback(this.encapsulateReturnCode(common.int.FAILURE));
      }
      return;
    }
    let condition: dataSharePredicates.DataSharePredicates = this.buildQueryMmsNotDownloadInfo(actionData);
    let managerUri = common.STR.URI_MESSAGE_LOG + common.STR.URI_MESSAGE_INFO_TABLE;
    dataHelper.query(managerUri, condition, this.buildMmsNotDownloadTableColumns()).then(resultSet => {
      let resultList: Array<LooseObject> = [];
      if (resultSet.rowCount > 0) {
        while (resultSet.goToNextRow()) {
          resultList.push(this.buildMmsNotDownloadInfoResult(resultSet));
        }
      }
      callback(this.encapsulateReturnResult(common.int.SUCCESS, resultList));
      resultSet.close();
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'queryMmsNotDownloadInfo fail, error: ' + JSON.stringify(error));
      callback(this.encapsulateReturnCode(common.int.FAILURE));
    });
  }

  private buildQueryMmsNotDownloadInfo(actionData: LooseObject) : dataSharePredicates.DataSharePredicates {
    let condition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    condition.isNotNull(mmsTable.messageInfo.msgId)
    condition.and()
    condition.equalTo(mmsTable.messageInfo.mmsPdu, actionData.mmsPdu);
    return condition;
  }

  public buildMmsNotDownloadTableColumns(): Array<string> {
    let resultColumns: Array<string> = [
      mmsTable.messageInfo.msgId,
      mmsTable.messageInfo.slotId,
      mmsTable.messageInfo.sessionId,
      mmsTable.messageInfo.groupId,
      mmsTable.messageInfo.isAdvancedSecurity,
      mmsTable.messageInfo.expiresTime,
      mmsTable.messageInfo.mmsPdu,
      mmsTable.messageInfo.phoneNumber,
      mmsTable.messageInfo.msgState
    ];
    return resultColumns;
  }

  public buildMmsNotDownloadInfoResult(resultSet: DataShareResultSet): Record<string, number | string> {
    let result: LooseObject = {};
    result.id = resultSet.getString(resultSet.getColumnIndex(mmsTable.messageInfo.msgId));
    result.subId = resultSet.getLong(resultSet.getColumnIndex(mmsTable.messageInfo.slotId));
    result.sessionId = resultSet.getLong(resultSet.getColumnIndex(mmsTable.messageInfo.sessionId));
    result.groupId = resultSet.getLong(resultSet.getColumnIndex(mmsTable.messageInfo.groupId));
    result.isAdvancedSecurity = resultSet.getLong(resultSet.getColumnIndex(mmsTable.messageInfo.isAdvancedSecurity));
    result.expiresTime = Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.messageInfo.expiresTime)));
    result.mmsPdu = resultSet.getString(resultSet.getColumnIndex(mmsTable.messageInfo.mmsPdu));
    result.msgState = Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.messageInfo.msgState)));
    result.phoneNumber = resultSet.getString(resultSet.getColumnIndex(mmsTable.messageInfo.phoneNumber));
    return result;
  }

  public async queryMaxGroupIdInMmsInfoTable(context: Context, callback?: (res: LooseObject) => void) {
    HiLog.i(TAG, 'queryMaxGroupIdInMmsInfoTable start');
    let promise = new Promise<number | null>((resolve, reject) => {
      this.queryMaxGroupId((result: LooseObject) => {
        callback && callback(result);
        let maxGroupId = 0;
        if (result.code === common.int.SUCCESS) {
          maxGroupId = result.abilityResult;
          resolve(maxGroupId);
        } else {
          resolve(null);
        }
      }, context);
    })
    return await promise;
  }

  public async updateSmsIsReadBySessionId(actionData: LooseObject, context: Context, callback?: Function | null) {
    let dataHelper: dataShare.DataShareHelper | undefined = await DataShareHelper.getInstance().initSmsDB(context);
    if (!dataHelper) {
      HiLog.e(TAG, '[updateIsReadBySessionId] createDataShareHelper fail');
      if (callback) {
        callback(this.encapsulateReturnCode(common.int.FAILURE));
      }
      return;
    }

    try {
      let condition: dataSharePredicates.DataSharePredicates = this.buildSmsIsReadBySessionId(actionData);
      let managerUri = common.STR.URI_MESSAGE_LOG + common.STR.URI_MESSAGE_INFO_TABLE;
      const va: ValuesBucket = {
        'is_read': 1
      }
      dataHelper.update(managerUri, condition, va).then((data: number) => {
        HiLog.i(TAG, 'markRead smsInfo succeed, data : ' + data);
        if (callback) {
          callback(this.encapsulateReturnResult(common.int.SUCCESS, data));
        }
      }).catch((err: BusinessError) => {
        HiLog.e(TAG, `[updateSmsIsReadBySessionId] error: code: ${err.code}, message: ${err.message} `);
        if (callback) {
          callback(this.encapsulateReturnCode(common.int.FAILURE));
        }
      });
    } catch (err) {
      let code = (err as BusinessError).code;
      let message = (err as BusinessError).message;
      HiLog.e(TAG, `[updateSmsIsReadBySessionId] error: code: ${code}, message: ${message} `);
      if (callback) {
        callback(this.encapsulateReturnCode(common.int.FAILURE));
      }
    }
  }

  private buildSmsIsReadBySessionId(actionData: LooseObject) : dataSharePredicates.DataSharePredicates {
    let condition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    if (actionData.markReadType == MarkRead.single) {
      condition.equalTo(mmsTable.messageInfo.sessionId, actionData.threadId);
      condition.and().equalTo(mmsTable.rcsMessageInfo.isRead, 0);
      return condition;
    }
    if (actionData.markReadType == MarkRead.allInfo) {
      condition.in(mmsTable.messageInfo.sessionId, actionData?.threadIds || []);
      return condition;
    }
    if (actionData.markReadType == MarkRead.all) {
      return condition;
    }
    throw new Error('buildSmsIsReadBySessionId condition not match');
  }

  public async queryDraftByCondition(threadId: number, context: Context) {
    HiLog.i(TAG, 'querySessionDraftByCondition start! :');
    let result: string[] = [];
    let dataHelper: dataShare.DataShareHelper | undefined = await DataShareHelper.getInstance().initSmsDB(context);
    try {
      if (!dataHelper) {
        HiLog.e(TAG, '[queryDraftByCondition] createDataShareHelper fail');
        return result;
      }
      let managerUri = common.STR.URI_MESSAGE_LOG + common.STR.URI_MESSAGE_INFO_TABLE;
      let condition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
      condition.equalTo('session_id', threadId);
      condition.equalTo('msg_state', commonData.int.SEND_DRAFT);
      condition.orderByDesc('start_time')
      let resultSet = await dataHelper.query(managerUri, condition, ['msg_type', 'msg_content'])
      if (resultSet != undefined && resultSet.goToFirstRow()) {
        let msgType = resultSet.getString(resultSet.getColumnIndex('msg_type'));
        let msgContext = resultSet.getString(resultSet.getColumnIndex('msg_content'));
        HiLog.i(TAG, 'query msgType : ' + msgType);
        result.push(msgType);
        result.push(msgContext);
      }
      resultSet.close();
      return result;
    } catch (e) {
      HiLog.w(TAG, 'query queryDraftByCondition error : ' + JSON.stringify(e));
      return result;
    }
  }

  public async updateSmsInfoSmsTypeBySessionIds(actionData: Record<string, number[]>,
    callback: Function, context: Context) {
    HiLog.i(TAG, 'updateSmsInfoSmsTypeBySessionId start! :');
    let dataHelper: dataShare.DataShareHelper | undefined = await DataShareHelper.getInstance().initSmsDB(context);
    try {
      if (!dataHelper) {
        HiLog.e(TAG, '[updateSmsInfoSmsTypeBySessionId] createDataShareHelper fail');
        if (callback) {
          callback(this.encapsulateReturnCode(common.int.FAILURE));
        }
        return;
      }
      let managerUri = common.STR.URI_MESSAGE_LOG + common.STR.URI_MESSAGE_INFO_TABLE;
      let condition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
      let threadIds: number[] = actionData.threadIds;
      condition.in('session_id', threadIds);
      condition.equalTo('sms_type', 0);
      let vp: ValuesBucket = {
        'sms_type': 1
      };
      let data = await dataHelper.update(managerUri, condition, vp);
      if (callback) {
        callback(this.encapsulateReturnResult(common.int.SUCCESS, data));
      }
    } catch (e) {
      HiLog.w(TAG, 'updateSmsInfoSmsTypeBySessionId error : ' + JSON.stringify(e));
      if (callback) {
        callback(this.encapsulateReturnCode(common.int.FAILURE));
      }
    }
  }

  async querySessionId(actionData: Record<string, string>, callback: Function, context: Context) {
    let dataHelper:dataShare.DataShareHelper | undefined = await DataShareHelper.getInstance().initSmsDB(context);
    if (!dataHelper) {
      HiLog.e(TAG, '[querySessionId] createDataShareHelper fail');
      if (callback) {
        callback(0);
      }
      return;
    }
    let condition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    condition.equalTo(mmsTable.messageInfo.msgId, actionData.msgId);
    let managerUri = common.STR.URI_MESSAGE_LOG + common.STR.URI_MESSAGE_INFO_TABLE;
    dataHelper.query(managerUri, condition, [mmsTable.messageInfo.sessionId]).then(resultSet => {
      let sessionId: number = 0;
      if (resultSet.rowCount > 0) {
        resultSet.goToFirstRow();
        sessionId = resultSet.getLong(resultSet.getColumnIndex(mmsTable.messageInfo.sessionId));
      }
      callback(sessionId);
      resultSet.close();
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'querySessionId fail, error: ' + JSON.stringify(error));
      callback(0);
    });
  }

  /**
   * 获取无效的数据
   */
  public async getInvalidDataFromDb(context: Context, url: string, counts:number[]) {
    let dataHelper:dataShare.DataShareHelper | undefined = await DataShareHelper.getInstance().initSmsDB(context);
    if (!dataHelper) {
      HiLog.e(TAG, '[statisticalData] createDataShareHelper fail');
      return;
    }
    let condition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    dataHelper.query(common.STR.URI_MESSAGE_LOG + url, condition, ['*']).then(resultSet => {
      HiLog.i(TAG,'invalid data count: ' + resultSet.rowCount + ' from url: ' + url);
      let isReturnEffectiveValue: boolean = false;
      if (resultSet?.rowCount > 0) {
        isReturnEffectiveValue = true;
        while (resultSet.goToNextRow()) {
          if (url === common.STR.URI_MESSAGE_INVALID_SESSION_COUNT ||
            url === common.STR.URI_MESSAGE_INVALID_PART_INFO_COUNT) {
            HiLog.i(TAG, 'invalid id is: ' + resultSet.getLong(resultSet.getColumnIndex('id')));
          } else if (url === common.STR.URI_MESSAGE_INVALID_INFO_COUNT) {
            HiLog.i(TAG, 'invalid msg_id: ' + resultSet.getLong(resultSet.getColumnIndex('msg_id')));
          } else if (url === common.STR.URI_MESSAGE_INVALID_RCS_INFO_COUNT ||
            url === common.STR.URI_MESSAGE_INVALID_RCS_INFO_MSG_COUNT) {
            HiLog.i(TAG, 'invalid rcs_id: ' + resultSet.getLong(resultSet.getColumnIndex('rcs_id')));
          }
        }
      }
      counts.push(resultSet?.rowCount);
      let sum = 0;
      if (counts.length > 4) {
        for (let i = 0; i < counts.length; i++) {
          sum += counts[i];
        }
        HiLog.w(TAG, `reportFaultEvent report counts: ${JSON.stringify(counts)}`);
        if (sum > 0) {
          invalidDataParmas.INVALID_COUNT_LIST = counts;
          DotUtil.getInstance()
            .reportMaintenanceEvent(invalidDataParmas, dotCommon.faultEventName.STATISTIC_INVALID_COUNT,
              hiSysEvent.EventType.STATISTIC);
        }
      } else {
        HiLog.w(TAG, `reportFaultEvent report no has counts: `);
      }
      if (isReturnEffectiveValue) {

      } else {
        HiLog.w(TAG, `invalid, isReturnEffectiveValue is false`);
      }
      resultSet.close();
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'invalid, error: ' + JSON.stringify(error));
    });
  }

  /**
   * 在增强信息消息详情表rcs_info中查询指定rcsId的消息的类型和内容
   * @param rcsId 增强信息消息的id, 表的主键
   * @param context Context
   * @returns { Promise<string[]> } {string[]}: 消息的类型和内容
   */
  public async queryMsgContentByRcsId(rcsId: number, context: Context): Promise<string[]> {
    HiLog.i(TAG, 'querySmsMmsInfoRcsIdByCondition start! :');
    let dataHelper: dataShare.DataShareHelper | undefined = await DataShareHelper.getInstance().initSmsDB(context);
    let result: string[] = [];
    try {
      if (!dataHelper) {
        HiLog.e(TAG, '[querySmsMmsInfoRcsIdByCondition] createDataShareHelper fail');
        return result;
      }
      let managerUri: string = common.STR.URI_MESSAGE_LOG + common.STR.URI_RCS_MESSAGE_INFO_TABLE;
      let condition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
      condition.equalTo('rcs_id', rcsId)
      let resultSet = await dataHelper.query(managerUri, condition, ['msg_content', 'rcs_type'])
      if (resultSet != undefined && resultSet.goToFirstRow()) {
        let rcsType = resultSet.getString(resultSet.getColumnIndex('rcs_type'));
        let msgContent = resultSet.getString(resultSet.getColumnIndex('msg_content'));
        HiLog.i(TAG, 'query rcsType : ' + rcsType);
        result.push(rcsType);
        result.push(msgContent);
      }
      resultSet.close();
      return result;
    } catch (e) {
      HiLog.e(TAG, `queryMsgContentByRcsId: error: ${e?.code} ${e?.message}`);
      return result;
    }
  }
}

export const queryContactsAvatarInContactDataDataBase = (context: Context, contactIds: number[],
  callback: Function | undefined) => {
  let task = new taskpool.Task(queryContactsAvatarInContactDataData, context, contactIds);
  taskpool.execute(task).then((res: LooseObject) => {
    callback?.(res);
  });
}

@Concurrent
async function queryContactsAvatarInContactDataData(context: Context, contactIds: number[]) {
  HiLog.iw('ConversationModel', `queryContactsAvatarInContactDataData start contactIds: ${contactIds?.toString()}`);
  let dataHelper:dataShare.DataShareHelper | undefined = await DataShareHelper.getInstance().initContactDB(context);
  let result: LooseObject = {};
  if (!dataHelper) {
    HiLog.e('ConversationModel', `[queryContactsAvatarInContactDataData] createDataShareHelper fail`);
      result.code = common.int.FAILURE;
      return result;
  }
  let dataBaseUri = common.STR.URI_ROW_CONTACTS + common.STR.CONTACT_DATA_URI;
  let condition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
  condition.in(mmsTable.contactDataColumns.contactId, contactIds);
  condition.and().equalTo(mmsTable.contactDataColumns.typeId, 8);// 8 refers to the avatar properties of the contact.
  let columns: string[] = [mmsTable.contactDataColumns.contactId, mmsTable.contactDataColumns.blobData];
  let resultSet: void | DataShareResultSet;
  try {
    resultSet = await dataHelper.query(dataBaseUri, condition, columns).catch((error: BusinessError) => {
      HiLog.e('ConversationModel', '[queryContactsAvatarInContactDataData] query fail, error: ' + JSON.stringify(error));
    });
  } catch (e) {
    HiLog.e('ConversationModel', '[queryContactsAvatarInContactDataData] query fail, error: ' + JSON.stringify(e));
  }

  if (!resultSet) {
    HiLog.e('ConversationModel', '[queryContactsAvatarInContactDataData] query resultSet is empty');
    result.code = common.int.FAILURE;
    return result;
  }
  let mapContactIdToAvatarBase64Encoded: Map<number, Uint8Array> = new Map();
  if (resultSet.rowCount > 0) {
    try {
      while (resultSet.goToNextRow()) {
        let id = resultSet.getDouble(resultSet.getColumnIndex(mmsTable.contactDataColumns.contactId));
        if (!id) {
          continue;
        }
        let avatarBlob = resultSet.getBlob(resultSet.getColumnIndex(mmsTable.contactDataColumns.blobData));
        mapContactIdToAvatarBase64Encoded.set(id, avatarBlob);
      }
    } catch (e) {
      HiLog.e('ConversationModel', `queryContactsAvatarInContactDataData data error: ${JSON.stringify(e)}`);
    }
  }
  HiLog.iw('ConversationModel',
    `queryContactsAvatarInContactDataData result.size:${mapContactIdToAvatarBase64Encoded?.size}`);
  resultSet.close();
  result.code = common.int.SUCCESS;
  result.abilityResult = mapContactIdToAvatarBase64Encoded;
  return result;
}