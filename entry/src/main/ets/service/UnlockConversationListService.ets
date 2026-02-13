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

import HiLog from '../utils/HiLog';
import common from '../data/commonData';
import LooseObject from '../data/LooseObject'
import { resType } from './MmsSearchService';
import SharedPreferencesUtils from '../utils/SharedPreferencesUtils';
import UnlockConversationService from './UnlockConversationService';

const TAG = 'UnlockConversationListService';

// 适配屏幕解锁公共事件性能优化，请勿增加其他业务
export default class UnlockConversationListService {
  private static instance: UnlockConversationListService;

  private constructor() {
  }

  public static getInstance(): UnlockConversationListService {
    if (UnlockConversationListService.instance == null) {
      UnlockConversationListService.instance = new UnlockConversationListService();
    }
    return UnlockConversationListService.instance;
  }

  public statisticalData(callBack: Function, context: Context): void {
    SharedPreferencesUtils.init(context);
    let result: LooseObject = {};
    UnlockConversationService.getInstance().statisticalData((res: resType) => {
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
}