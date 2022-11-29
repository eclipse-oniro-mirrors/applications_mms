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

import contactService from "../service/ContractService";
import conversationListService from "../service/ConversationListService";
import common from "../data/commonData";
import featureAbility from "@ohos.ability.featureAbility";
import HiLog from "./HiLog";
import router from "@system.router";

const TAG = "WantUtil";

export default {
  pageFlag: "0",
  contractParams: {},

  getWant() {
    HiLog.i(TAG, "getWant start");
      if (globalThis.abilityWant.hasOwnProperty("parameters")) {
        let parameters = globalThis.abilityWant.parameters;
        if (parameters.hasOwnProperty("pageFlag")) {
          this.pageFlag = parameters.pageFlag;
          HiLog.i(TAG, "pageFlag = " + this.pageFlag);
        }
        if (parameters.hasOwnProperty("contactObjects")) {
          this.contractParams = contactService.dealContractParams(parameters.contactObjects);
        }
      }
      // Page redirection
      this.jump();
  },

  jump() {
    let result = {
      uri: '',
      params: {}
    };
    HiLog.i(TAG, "want.pageFlag: " + this.pageFlag);
    switch (this.pageFlag) {
      case "conversation":
        result.uri = "pages/conversation/conversation";
        if (this.contractParams) {
          result.params = this.contractParams;
          this.jumpIsNewPage(result);
        } else {
          router.replace(result);
        }
        break;
      default:
        break;
    }
  },

  async jumpIsNewPage(result) {
    // Check whether a session has been created for the current phone number in the SMS message.
    conversationListService.querySessionByTelephone(this.contractParams.strContactsNumber, res => {
      if (res.code == common.int.SUCCESS && res.response.id > 0) {
        result.params.threadId = res.response.id;
        this.markAllAsRead(result.params.threadId);
        if (res.response.hasDraft && res.response.messageCount == 0) {
          result.params.isNewMsg = true;
        } else {
          result.params.isNewMsg = false;
        }
      } else {
        result.params.isNewMsg = true;
      }
      router.replace(result);
    });
  },

  markAllAsRead(threadId) {
    let actionData = {
      threadIds: [threadId],
      hasRead: 1,
      valueBucket: {
        "unread_count": 0
      }
    };
    conversationListService.markAllAsRead(actionData);
  }
}