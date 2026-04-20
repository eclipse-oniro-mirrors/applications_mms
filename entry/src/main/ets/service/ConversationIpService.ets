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

import commonData from '../data/commonData';
import LooseObject from '../data/LooseObject';

export default class ConversationIpService {
  private static instance: ConversationIpService;

  public static getInstance(): ConversationIpService {
    if (ConversationIpService.instance == null) {
      ConversationIpService.instance = new ConversationIpService();
    }
    return ConversationIpService.instance;
  }

  public static getTestInstance(): ConversationIpService {
    return new ConversationIpService();
  }

  /**
   * 更新ip消息详情
   *
   * @param item rcs消息实体
   * @param result 处理后的结果集
   */
  public updateIpMsgInfo(item: LooseObject, result: LooseObject): void {
    if (item.serviceCenter === commonData.serviceCenter.PUSH_OHOS_A2P) {
      result.isIpMsg = true;
      result.ownerAddr = item.ownerAddr;
      result.serviceCenter = item.serviceCenter;
      // result.isSimpleIpMsg = IpMsgApi.isSimpleMsg(item.ownerAddr);
    } else if (item.serviceCenter === commonData.serviceCenter.PUSH_A2P) {
      // 双升单上来的ip消息当成固定文本的处理
      result.isIpMsg = true;
      result.ownerAddr = item.ownerAddr;
      result.serviceCenter = item.serviceCenter;
      result.isSimpleIpMsg = true;
    } else {
      result.isIpMsg = false;
      result.ownerAddr = '';
      result.isSimpleIpMsg = false;
    }
  }
}