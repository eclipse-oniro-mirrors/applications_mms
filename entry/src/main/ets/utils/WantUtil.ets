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

import router from "@system.router";

import ContactService from "../service/ContactsService";
import ConversationListService from "../service/ConversationListService";
import common from "../data/commonData";
import HiLog from "./HiLog";
import LooseObject from '../data/LooseObject';

const TAG = "WantUtil";

export default {

  getWant() {
    HiLog.i(TAG, "getWant start");
    if(globalThis.abilityWant == null) {
      return;
    }
    let abilityWant = globalThis.abilityWant;
    globalThis.abilityWant = null;

    if (abilityWant.hasOwnProperty("parameters")) {
        let parameters = abilityWant.parameters;
        let pageFlag = '';
        if (parameters.hasOwnProperty("pageFlag")) {
          pageFlag = parameters.pageFlag;
          HiLog.i(TAG, "pageFlag = " + pageFlag);
        }
        let contactParams = {}
        if (parameters.hasOwnProperty("contactObjects")) {
          contactParams = ContactService.getInstance().dealContactParams(parameters.contactObjects);
        }
        this.jump(pageFlag, contactParams);
      }
  },

  jump(pageFlag, contactParams) {
    let result = {
      uri: '',
      params: {}
    };
    HiLog.i(TAG, "want.pageFlag: " + pageFlag);
    switch (pageFlag) {
      case "conversation":
        result.uri = "pages/conversation/conversation";
        if (contactParams) {
          result.params = contactParams;
          this.jumpIsNewPage(result, contactParams);
        } else {
          router.push(result);
        }
        break;
      default:
        break;
    }
  },

  async jumpIsNewPage(result, contactParams) {
    // Check whether a session has been created for the current phone number in the SMS message.
    ConversationListService.getInstance().querySessionByTelephone(contactParams.strContactsNumber, res => {
      if (res.code == common.int.SUCCESS && res.response.id > 0) {
        result.params.threadId = res.response.id;
        let actionData: LooseObject = {};
        actionData.threadId = result.params.threadId;
        ConversationListService.getInstance().markAllToRead(actionData);
        if (res.response.hasDraft && res.response.messageCount == 0) {
          result.params.isNewMsg = true;
        } else {
          result.params.isNewMsg = false;
        }
      } else {
        result.params.isNewMsg = true;
      }
      router.push(result);
    }, null);
  },
}