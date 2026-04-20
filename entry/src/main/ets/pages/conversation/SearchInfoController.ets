/**
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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

import LooseObject from "../../data/LooseObject";
import ConversationList from "../conversationlist/conversationList";
import common from '../../data/commonData';
import MmsSearchService from "../../service/MmsSearchService";
import { messageType } from "../conversationlist/conversationListController";
import HiLog from "../../utils/HiLog";

const TAG = 'SearchInfoController';

export class SearchInfoController {
  searchInfo: ConversationList

  constructor(SearchInfo: ConversationList) {
    this.searchInfo = SearchInfo;
  }

  public async querySMS(inputText: string, context: Context) {

    if (!inputText) {
      this.searchInfo.mConListCtrl.requestItem(context)
      AppStorage.set('isSearchResultEmpty', false)
      return;
    }
    const searchParams: LooseObject = {
      input: inputText,
      smsType: common.sms_type.COMMON // 1 对应普通短信，可根据需求扩展其他类型
    };
    try {
      const mmsSearchService = MmsSearchService.getInstance();
      mmsSearchService.searchMessage(getContext(this), searchParams, (result: LooseObject) => {
        if (result.code === common.int.SUCCESS) {
          let sessionList: messageType[] = result.resultMap.sessionList || [];
          // 更新列表数据源
          this.searchInfo.mConListCtrl.conversationListDataSource.refresh(sessionList);
          AppStorage.set('isSearchResultEmpty', sessionList.length === 0)
        } else {
          HiLog.e(TAG, 'Search error，code：' + result.code);
          this.searchInfo.mConListCtrl.conversationListDataSource.refresh([]);
          AppStorage.set('isSearchResultEmpty', true)
        }
      })
    } catch (error) {
      HiLog.e(TAG, 'error：' + JSON.stringify(error));
      this.searchInfo.mConListCtrl.conversationListDataSource.refresh([]);
      AppStorage.set('isSearchResultEmpty', true)
    }
  }
}