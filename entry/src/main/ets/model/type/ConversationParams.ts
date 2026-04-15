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
import { dataShare } from '@kit.ArkData';

export interface IQueryMsgDetailSizeInfo {
  threadId: number,
  needDistinct: boolean,
  contactsNum?: number
}

export interface IQueryMessageDetailAll {
  actionDataName: string,
  page: number,
  threadId: number,
  contactsNum: number,
  limit?: number,
  offset?: number,
  isCustomSearch?: boolean,
}

export interface IQueryMessageDetailInfo {
  isDraft: boolean
  currentPage: number,
  threadId: number,
  contactsNum: number,
  isDownloadQuery?: boolean,
  resultTotal?: number,
  lastListSize?: number,
  queryTimeID: number,
  startIndex: number,
  needInitMmsList?: boolean,
  notNeedScrollToEnd?: boolean
  /** 是否在会话页面初始化请求消息列表数据的时候调用 */
  isCallOnInitRequestMessageList?: boolean
}

/*
 * 查询smsDb时，返回的Data share helper和访问数据库链接
 * */
export interface ISmsDBDataShareHelper {
  dataHelper: dataShare.DataShareHelper | undefined,
  managerUri: string
}