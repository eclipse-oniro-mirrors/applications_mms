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
import dataSharePredicates from '@ohos.data.dataSharePredicates';
import BaseModel from './BaseModel';
import DataShareHelper from './repository/DataShareHelper';
import HiLog from '../utils/HiLog';
import { BusinessError } from '@ohos.base';
import commonData, { SmsGroupRcsInfo, SmsRcsInfo } from '../data/commonData';
import mmsTable from '../data/tableData';
import { ValuesBucket } from '@kit.ArkData';
import MmsFileDeleteService from '../service/MmsFileDeleteService';

const TAG = 'MmsPartModel';
// 分批处理的数量
const PEER_PAGE_SIZE = 100;
// 以part表的msgId字段处理
const SMS_TABLE = 'SMSInfoTable';
// 以part表的groupId字段处理
const SMS_GROUP_TABLE = 'SMSInfoGroupIdTable';
// 以part表的rcsId字段处理
const RCS_TABLE = 'RCSInfoTable';

export default class MmsPartModel extends BaseModel {

  /**
   * 根据msgId/rcsId删除mms_part表
   *
   * @param smsMsgIds smsMsgIds
   * @param rcsMsgIds rcsMsgIds
   * @param context 上下文
   * @returns void
   */
  public async deleteByIds(smsMsgIds: SmsRcsInfo[], rcsMsgIds: SmsRcsInfo[], context: Context): Promise<void> {
    let dataHelper: dataShare.DataShareHelper | undefined = await DataShareHelper.getInstance().initSmsDB(context);
    if (!dataHelper) {
      HiLog.e(TAG, 'deleteByIds createDataShareHelper fail');
      return;
    }
    // 删除mms_part表之前需查询需要删除的mms_part表资源文件路径
    let mmsPartPaths: string[] = [];
    mmsPartPaths = await this.queryMmsPartPathsByIds(smsMsgIds, mmsPartPaths, dataHelper, rcsMsgIds);
    HiLog.w(TAG, `deleteByIds queryMmsPartPathInfo length: ${mmsPartPaths?.length}`);
    // 删除、更新mms_part表数据与相关的资源文件
    await this.deleteAndUpdateMmsPart(smsMsgIds, dataHelper, rcsMsgIds, mmsPartPaths, context);
  }

  public async queryMmsPartPathsByIds(smsMsgIds: SmsRcsInfo[], mmsPartPaths: string[],
    dataHelper: dataShare.DataShareHelper, rcsMsgIds: SmsRcsInfo[]) {
    // 根据mms_info表分批查询资源文件路径
    for (let i = 0; i < smsMsgIds.length; i += PEER_PAGE_SIZE) {
      mmsPartPaths =
        mmsPartPaths.concat(await this.queryMmsPartPathByIds(dataHelper, smsMsgIds.slice(i, i + PEER_PAGE_SIZE),
          SMS_TABLE));
    }
    // 根据rcs_info表分批查询资源文件路径
    for (let i = 0; i < rcsMsgIds.length; i += PEER_PAGE_SIZE) {
      mmsPartPaths =
        mmsPartPaths.concat(await this.queryMmsPartPathByIds(dataHelper, rcsMsgIds.slice(i, i + PEER_PAGE_SIZE),
          RCS_TABLE));
    }
    return mmsPartPaths;
  }

  /**
   * 删除、更新mmsPart表信息 然后删除沙箱中资源文件
   *
   * @param smsMsgIds smsMsgIds
   * @param dataHelper dataHelper
   * @param rcsMsgIds dataHelper
   * @param mmsPartPaths mmsPartPaths
   * @param context context
   */
  public async deleteAndUpdateMmsPart(smsMsgIds: SmsRcsInfo[], dataHelper: dataShare.DataShareHelper,
    rcsMsgIds: SmsRcsInfo[], mmsPartPaths: string[], context: Context) {
    if (!dataHelper) {
      HiLog.e(TAG, `queryMmsPartPathByIds param dataHelper is invalid`);
      return;
    }
    if (!context) {
      HiLog.e(TAG, `queryMmsPartPathByIds param context is invalid`);
      return;
    }
    // 根据mms_info表分批删除mms_part表 注意删除更新顺序不能颠倒
    for (let i = 0; i < smsMsgIds.length; i += PEER_PAGE_SIZE) {
      await this.deleteMmsPartByIds(dataHelper, smsMsgIds.slice(i, i + PEER_PAGE_SIZE), SMS_TABLE);
    }
    // 根据rcs_info表分批删除mms_part表 注意删除更新的顺序不能颠倒
    for (let i = 0; i < rcsMsgIds.length; i += PEER_PAGE_SIZE) {
      await this.deleteMmsPartByIds(dataHelper, rcsMsgIds.slice(i, i + PEER_PAGE_SIZE), RCS_TABLE);
    }
    // 根据mms_info表分批更新mms_part表 注意删除更新顺序不能颠倒
    for (let i = 0; i < smsMsgIds.length; i += PEER_PAGE_SIZE) {
      await this.updateMmsPartByIds(dataHelper, smsMsgIds.slice(i, i + PEER_PAGE_SIZE), SMS_TABLE);
    }
    // 根据rcs_info表分批更新mms_part表 注意删除更新的顺序不能颠倒
    for (let i = 0; i < rcsMsgIds.length; i += PEER_PAGE_SIZE) {
      await this.updateMmsPartByIds(dataHelper, rcsMsgIds.slice(i, i + PEER_PAGE_SIZE), RCS_TABLE);
    }
    // 删除沙箱中的资源文件
    if (mmsPartPaths.length > 0) {
      MmsFileDeleteService.getInstance().clearByAfterDataBaseDelete(mmsPartPaths, context);
    }
  }

  /**
   * 获取需要删除的资源文件路径
   *
   * @param dataHelper dataHelper
   * @param msgIdArray msgIdArray
   * @param tableName tableName
   * @returns 需要删除的资源文件路径集合
   */
  public async queryMmsPartPathByIds(dataHelper: dataShare.DataShareHelper,
    msgIdArray: SmsRcsInfo[], tableName: string): Promise<string[]> {
    if (!dataHelper) {
      HiLog.e(TAG, `queryMmsPartPathByIds param dataHelper is invalid`);
      return [];
    }
    if (msgIdArray.length === 0) {
      HiLog.e(TAG, `queryMmsPartPathByIds param msgIdArray is empty`);
      return [];
    }
    if (![SMS_TABLE, RCS_TABLE, SMS_GROUP_TABLE].includes(tableName)) {
      HiLog.e(TAG, `queryMmsPartPathByIds param tableName is invalid`);
      return [];
    }
    let managerUri = commonData.STR.URI_MESSAGE_LOG + commonData.STR.URI_MESSAGE_MMS_PART;
    let msgIds: number[] = [];
    let notCollectedMsgIds: number[] = [];
    for (let info of msgIdArray) {
      msgIds.push(info.msgId);
      if (info.isCollect === commonData.is_collect.NOT_FAVORITE) {
        notCollectedMsgIds.push(info.msgId);
      }
    }
    HiLog.i(TAG, `queryMmsPartPathByIds msgIds:${msgIds?.toString()}`);
    HiLog.i(TAG, `queryMmsPartPathByIds notCollectedMsgIds:${notCollectedMsgIds?.toString()}`);
    let condition: dataSharePredicates.DataSharePredicates =
      this.buildPartQueryInfoCondition(tableName, msgIds, notCollectedMsgIds);
    if (!condition) {
      HiLog.e(TAG, `queryMmsPartPathByIds param is empty`);
      return [];
    }
    let resultList: string[] = [];
    await dataHelper.query(managerUri, condition, [mmsTable.mmsPart.locationPath])
      .then(resultSet => {
        if (resultSet.rowCount > 0) {
          while (resultSet.goToNextRow()) {
            resultList.push(resultSet.getString(resultSet.getColumnIndex(mmsTable.mmsPart.locationPath)));
          }
        }
        resultSet.close();
        HiLog.i(TAG, `queryMmsPartPathByIds success res.length: ${resultSet?.rowCount}`);
      }).catch((error: BusinessError) => {
        HiLog.e(TAG, `queryMmsPartPathByIds fail, error:${JSON.stringify(error)}`);
      });
    return resultList;
  }

  private async deleteMmsPartByIds(dataHelper: dataShare.DataShareHelper,
    msgIdArray: SmsRcsInfo[], tableName: string): Promise<void> {
    if (msgIdArray.length === 0) {
      HiLog.e(TAG, `deleteMmsPartByIds param is empty`);
      return;
    }
    if (![SMS_TABLE, RCS_TABLE, SMS_GROUP_TABLE].includes(tableName)) {
      HiLog.e(TAG, `deleteMmsPartByIds param tableName is invalid`);
      return;
    }
    let managerUri = commonData.STR.URI_MESSAGE_LOG + commonData.STR.URI_MESSAGE_MMS_PART;;
    let msgIds: number[] = [];
    let notCollectedMsgIds: number[] = [];
    for (let info of msgIdArray) {
      msgIds.push(info.msgId);
      if (info.isCollect === commonData.is_collect.NOT_FAVORITE) {
        notCollectedMsgIds.push(info.msgId);
      }
    }
    HiLog.i(TAG, `deleteMmsPartByIds msgIds: ${msgIds?.toString()}`);
    HiLog.i(TAG, `deleteMmsPartByIds notCollectedMsgIds: ${notCollectedMsgIds?.toString()}`);
    let condition: dataSharePredicates.DataSharePredicates =
      this.buildPartQueryInfoCondition(tableName, msgIds, notCollectedMsgIds);
    if (!condition) {
      HiLog.e(TAG, `deleteMmsPartByIds condition is invalid`);
      return;
    }
    await dataHelper.delete(managerUri, condition).then(res => {
      HiLog.i(TAG, `deleteMmsPartByIds success with res: ${res}`);
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, `deleteMmsPartByIds fail, error:${JSON.stringify(error)}`);
    });
  }

  private async updateMmsPartByIds(dataHelper: dataShare.DataShareHelper,
    msgIdArray: SmsRcsInfo[], tableName: string): Promise<void> {
    if (msgIdArray.length === 0) {
      HiLog.e(TAG, `updateMmsPartByIds param is empty`);
      return;
    }
    if (![SMS_TABLE, RCS_TABLE, SMS_GROUP_TABLE].includes(tableName)) {
      HiLog.e(TAG, `updateMmsPartByIds param tableName is invalid`);
      return;
    }
    let managerUri = commonData.STR.URI_MESSAGE_LOG + commonData.STR.URI_MESSAGE_MMS_PART;;
    let msgIds: number[] = [];
    for (let info of msgIdArray) {
      msgIds.push(info.msgId);
    }
    HiLog.i(TAG, `updateMmsPartByIds msgIds: ${msgIds?.toString()}`);
    let condition: dataSharePredicates.DataSharePredicates = this.buildPartUpdateInfoCondition(tableName, msgIds);
    if (!condition) {
      HiLog.e(TAG, `updateMmsPartByIds condition is invalid`);
      return;
    }
    let vp: ValuesBucket = {
      'reference_count': commonData.referenceCount.ONE
    }
    await dataHelper.update(managerUri, condition, vp).then(res => {
      HiLog.i(TAG, `updateMmsPartByIds success with res: ${res}`);
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, `updateMmsPartByIds fail, error:${JSON.stringify(error)}`);
    });
  }

  private buildPartQueryInfoCondition(table: string,
    msgIds: number[], notCollectedMsgIds: number[]): dataSharePredicates.DataSharePredicates {
    let condition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    // mmsPart表中引用计数等于1
    condition.beginWrap();
    if (table === SMS_TABLE) {
      condition.in(mmsTable.mmsPart.msgId, msgIds);
    }
    if (table === RCS_TABLE) {
      condition.in(mmsTable.mmsPart.rcsId, msgIds);
    }
    if (table === SMS_GROUP_TABLE) {
      condition.in(mmsTable.mmsPart.groupId, msgIds);
    }
    condition.and().equalTo(mmsTable.mmsPart.referenceCount, commonData.referenceCount.ONE);
    condition.endWrap();
    // mmsPart表中引用计数为默认值-1,需考虑只可以删除未被收藏的附件信息，已被收藏的不被删除
    if (notCollectedMsgIds.length > 0) {
      condition.or().beginWrap();
      if (table === SMS_TABLE) {
        condition.in(mmsTable.mmsPart.msgId, notCollectedMsgIds);
      }
      if (table === RCS_TABLE) {
        condition.in(mmsTable.mmsPart.rcsId, notCollectedMsgIds);
      }
      if (table === SMS_GROUP_TABLE) {
        condition.in(mmsTable.mmsPart.groupId, notCollectedMsgIds);
      }
      condition.and().equalTo(mmsTable.mmsPart.referenceCount, commonData.referenceCount.DEFAULT);
      condition.endWrap();
    }
    return condition;
  }

  private buildPartUpdateInfoCondition(table: string,
    msgIds: number[]): dataSharePredicates.DataSharePredicates {
    let condition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    // mmsPart表中引用计数大于1,需要更新引用计数为1
    if (table === SMS_TABLE) {
      condition.in(mmsTable.mmsPart.msgId, msgIds);
    }
    if (table === RCS_TABLE) {
      condition.in(mmsTable.mmsPart.rcsId, msgIds);
    }
    if (table === SMS_GROUP_TABLE) {
      condition.in(mmsTable.mmsPart.groupId, msgIds);
    }
    condition.and().equalTo(mmsTable.mmsPart.referenceCount, commonData.referenceCount.TWO);
    return condition;
  }

  /**
   * 根据groupId/rcsId删除mms_part表
   *
   * @param smsGroupIds smsGroupIds
   * @param rcsInfos rcsInfos
   * @param context 上下文
   * @returns void
   */
  public async deleteByGroupIdOrRcsIds(smsGroupIds: SmsGroupRcsInfo[], rcsInfos: SmsGroupRcsInfo[],
    context: Context): Promise<void> {
    if (!context) {
      HiLog.e(TAG, 'deleteByGroupIdOrRcsIds param context is invalid');
      return;
    }
    let dataHelper: dataShare.DataShareHelper | undefined = await DataShareHelper.getInstance().initSmsDB(context);
    if (!dataHelper) {
      HiLog.e(TAG, 'deleteByGroupIdOrRcsIds createDataShareHelper fail');
      return;
    }
    // 删除mms_part表之前需查询需要删除的mms_part表资源文件路径
    let mmsPartPaths: string[] = [];
    mmsPartPaths = await this.queryMmsPartPathsByGroupIdOrRcsIds(smsGroupIds, mmsPartPaths, dataHelper, rcsInfos);
    HiLog.w(TAG, `deleteByGroupIdOrRcsIds queryMmsPartPathInfo length: ${mmsPartPaths?.length}`);
    // 删除、更新mms_part表数据与相关的资源文件
    await this.deleteAndUpdateMmsPartByGroupIdOrRcsIds(smsGroupIds, dataHelper, rcsInfos, mmsPartPaths, context);
  }

  private async queryMmsPartPathsByGroupIdOrRcsIds(smsGroupIds: SmsGroupRcsInfo[], mmsPartPaths: string[],
    dataHelper: dataShare.DataShareHelper, rcsInfos: SmsGroupRcsInfo[]) {
    let smsMsgIds: SmsRcsInfo[] = [];
    let smsMsg: SmsRcsInfo;
    // 去除不需要删除沙箱资源文件的groupId
    for (let group of smsGroupIds) {
      smsMsg = new SmsRcsInfo();
      if (group.isNeedDeleteFile) {
        smsMsg.msgId = group.msgId;
        smsMsg.isCollect = group.isCollect;
        smsMsgIds.push(smsMsg);
      }
    }
    let rcsMsgIds: SmsRcsInfo[] = [];
    let rcsMsg: SmsRcsInfo;
    // 去除不需要删除沙箱资源文件的rcsId
    for (let rcs of rcsInfos) {
      rcsMsg = new SmsRcsInfo();
      if (rcs.isNeedDeleteFile) {
        rcsMsg.msgId = rcs.msgId;
        rcsMsg.isCollect = rcs.isCollect;
        rcsMsgIds.push(rcsMsg);
      }
    }
    HiLog.w(TAG,
      `queryMmsPartPathsByGroupIdOrRcsIds smsMsgIds.length: ${smsMsgIds?.length}, rcsMsgIds.length: ${rcsMsgIds?.length}`);
    if (smsMsgIds.length === 0 && rcsMsgIds.length === 0) {
      return mmsPartPaths;
    }
    // 根据mms_info表分批查询资源文件路径
    for (let i = 0; i < smsMsgIds.length; i += PEER_PAGE_SIZE) {
      mmsPartPaths =
        mmsPartPaths.concat(await this.queryMmsPartPathByIds(dataHelper, smsMsgIds.slice(i, i + PEER_PAGE_SIZE),
          SMS_GROUP_TABLE));
    }
    // 根据rcs_info表分批查询资源文件路径
    for (let i = 0; i < rcsMsgIds.length; i += PEER_PAGE_SIZE) {
      mmsPartPaths =
        mmsPartPaths.concat(await this.queryMmsPartPathByIds(dataHelper, rcsMsgIds.slice(i, i + PEER_PAGE_SIZE),
          RCS_TABLE));
    }
    return mmsPartPaths;
  }

  private async deleteAndUpdateMmsPartByGroupIdOrRcsIds(smsGroupIds: SmsGroupRcsInfo[],
    dataHelper: dataShare.DataShareHelper, rcsInfos: SmsGroupRcsInfo[], mmsPartPaths: string[], context: Context) {
    let smsMsgIds: SmsRcsInfo[] = [];
    let smsMsg: SmsRcsInfo;
    // 去除不需要删除沙箱资源文件的groupId
    for (let group of smsGroupIds) {
      smsMsg = new SmsRcsInfo();
      smsMsg.msgId = group.msgId;
      smsMsg.isCollect = group.isCollect;
      smsMsgIds.push(smsMsg);
    }
    let rcsMsgIds: SmsRcsInfo[] = [];
    let rcsMsg: SmsRcsInfo;
    // 去除不需要删除沙箱资源文件的rcsId
    for (let rcs of rcsInfos) {
      rcsMsg = new SmsRcsInfo();
      rcsMsg.msgId = rcs.msgId;
      rcsMsg.isCollect = rcs.isCollect;
    }
    HiLog.w(TAG,
      `deleteAndUpdateMmsPartByGroupIdOrRcsIds smsMsgIds.length: ${smsMsgIds?.length}, rcsMsgIds.length: ${rcsMsgIds?.length}`);
    if (smsMsgIds.length === 0 && rcsMsgIds.length === 0) {
      return mmsPartPaths;
    }
    // 根据mms_info表分批删除mms_part表 注意删除更新顺序不能颠倒
    for (let i = 0; i < smsMsgIds.length; i += PEER_PAGE_SIZE) {
      await this.deleteMmsPartByIds(dataHelper, smsMsgIds.slice(i, i + PEER_PAGE_SIZE), SMS_GROUP_TABLE);
    }
    // 根据rcs_info表分批删除mms_part表 注意删除更新的顺序不能颠倒
    for (let i = 0; i < rcsMsgIds.length; i += PEER_PAGE_SIZE) {
      await this.deleteMmsPartByIds(dataHelper, rcsMsgIds.slice(i, i + PEER_PAGE_SIZE), RCS_TABLE);
    }
    // 根据mms_info表分批更新mms_part表 注意删除更新顺序不能颠倒
    for (let i = 0; i < smsMsgIds.length; i += PEER_PAGE_SIZE) {
      await this.updateMmsPartByIds(dataHelper, smsMsgIds.slice(i, i + PEER_PAGE_SIZE), SMS_GROUP_TABLE);
    }
    // 根据rcs_info表分批更新mms_part表 注意删除更新的顺序不能颠倒
    for (let i = 0; i < rcsMsgIds.length; i += PEER_PAGE_SIZE) {
      await this.updateMmsPartByIds(dataHelper, rcsMsgIds.slice(i, i + PEER_PAGE_SIZE), RCS_TABLE);
    }
    // 删除沙箱中的资源文件
    if (mmsPartPaths.length > 0) {
      MmsFileDeleteService.getInstance().clearByAfterDataBaseDelete(mmsPartPaths, context);
    }
    return;
  }

  /**
   * 根据需要删除的资源文件路径locationPaths查询part表删除后是否还存在其他消息引用此路径
   *
   * @param locationPaths locationPaths
   * @param context 上下文
   * @returns mms_part表中存在的locationPaths
   */
  public async queryMmsPartPathByPaths(locationPaths: string[], context: Context): Promise<string[]> {
    if (!context) {
      HiLog.e(TAG, 'queryMmsPartPathByPaths param context is invalid');
      return [];
    }
    if (locationPaths.length === 0) {
      HiLog.e(TAG, `queryMmsPartPathByPaths param locationPaths is empty`);
      return [];
    }
    let dataHelper: dataShare.DataShareHelper | undefined = await DataShareHelper.getInstance().initSmsDB(context);
    if (!dataHelper) {
      HiLog.e(TAG, 'deleteByGroupIdOrRcsIds createDataShareHelper fail');
      return [];
    }
    let managerUri = commonData.STR.URI_MESSAGE_LOG + commonData.STR.URI_MESSAGE_MMS_PART;
    HiLog.i(TAG, `queryMmsPartPathByPaths locationPaths.length:${locationPaths?.length}`);
    let condition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    condition.in(mmsTable.mmsPart.locationPath, locationPaths);
    let resultList: string[] = [];
    await dataHelper.query(managerUri, condition, [mmsTable.mmsPart.locationPath])
      .then(resultSet => {
        HiLog.i(TAG, `queryMmsPartPathByPaths success res.length: ${resultSet?.rowCount}`);
        if (resultSet.rowCount > 0) {
          while (resultSet.goToNextRow()) {
            resultList.push(resultSet.getString(resultSet.getColumnIndex(mmsTable.mmsPart.locationPath)));
          }
        }
        resultSet.close();
        HiLog.i(TAG, `queryMmsPartPathByPaths resultList.length: ${resultList?.length}`);
      }).catch((error: BusinessError) => {
        HiLog.e(TAG, `queryMmsPartPathByPaths fail, error:${JSON.stringify(error)}`);
      });
    return resultList;
  }
}