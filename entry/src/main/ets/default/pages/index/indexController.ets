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

import appStorage from '../../utils/AppStorageUtil';
// JS公共常量
import common from '../../data/commonData';
import contactService from '../../service/ContractService';
import conversationListService from '../../service/ConversationListService';
import featureAbility from '@ohos.ability.featureAbility';
import HiLog from '../../utils/HiLog';
import mmsTable from '../../data/tableData';
import preferences from '../../utils/PreferencesUtil';
import rdbStore from '../../utils/RdbStoreUtil';
import router from '@system.router';
import simCardService from '../../service/SimCardService';

const TAG = 'IndexController';

export default {
  uri: common.string.EMPTY_STR,

  pageFlag: 'conversationList',

  contractParams: null,

  onInit() {
    this.initPermissions()
    // 初始化数据库
    this.initRdb();
  },

  async initPermissions() {
    let requestPermissions: Array<string> = [
      "ohos.permission.READ_CONTACTS",
      "ohos.permission.READ_MESSAGES",
      "ohos.permission.SEND_MESSAGES",
      "ohos.permission.RECEIVE_SMS"
    ];
    let context = featureAbility.getContext();
    context.requestPermissionsFromUser(requestPermissions, 1, (data) => {
      if (data.authResults == undefined) {
        return;
      }
      for (let i = 0; i < data.authResults.length; i++) {
        if (data.authResults[i] == -1) {
          HiLog.i(TAG, 'Application requestPermissionsFromUser failed');
          return;
        }
      }
      this.getWant();
    });
    HiLog.i(TAG, 'Application requestPermissionsFromUser end');
  },

  onShow() {
    this.initStorage();
  },

  onHide() {
  },

  async initRdb() {
    // 创建数据库表
    HiLog.i(TAG, 'initRdb');
    rdbStore.createTable(mmsTable.table.session).then(() => {
      HiLog.i(TAG, 'initRdb, createTable done');
    });
  },

  initStorage() {
    preferences.initDataStorage().then((prefIns) => {
      appStorage.setPreferences(prefIns);
      // 获取simCount
      this.initSimCardNum(preferences);
      // 获取卡的运营商
      this.simInfoProcessor(preferences);
    }).catch((err) => {
      HiLog.e(TAG, 'initStorage, failed: ' + err.message);
    });
  },

  initSimCardNum(preferences) {
    simCardService.initSimCardNum(preferences);
  },

  // 处理Sim卡相关的信息(sim卡的数量以及运营商的名字)
  simInfoProcessor(preferences) {
    simCardService.simInfoHandler(preferences);
  },

  getWant() {
    featureAbility.getWant().then((want) => {
      if (want.hasOwnProperty("uri")) {
        this.uri = want.uri;
      }
      if (want.hasOwnProperty("parameters")) {
        let parameters = want.parameters;
        if (parameters.hasOwnProperty("pageFlag")) {
          this.pageFlag = parameters.pageFlag;
        }
        if (parameters.hasOwnProperty("contactObjects")) {
          this.contractParams = contactService.dealContractParams(parameters.contactObjects);
        }
      }
      // 页面跳转
      this.jump();
    }).catch((error) => {
      HiLog.e(TAG, 'getWant, failed Cause: ' + JSON.stringify(error.message));
    })
  },

  jump() {
    let result = {
      uri: '',
      params: ''
    };
    HiLog.i(TAG, 'want.pageFlag: ' + this.pageFlag);
    switch (this.pageFlag) {
      case 'conversationList':
        result.uri = 'pages/conversationlist/conversationList';
        router.replace(result);
        break;
      case 'conversation':
        result.uri = 'pages/conversation/conversation';
        if (this.contractParams) {
          result.params = this.contractParams;
          this.jumpIsNewPage(result);
        } else {
          router.replace(result);
        }
        break;
      default:
        result.uri = common.string.EMPTY_STR;
        break;
    }
  },

  jumpIsNewPage(result) {
    // 判断是否
    conversationListService.querySessionByTelephone(this.contractParams.strContactsNumber, res => {
      if (res.code == common.int.SUCCESS && res.response.id > 0) {
        result.params.threadId = res.response.id;
        this.markAllAsRead(result.params.threadId);
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
        'unread_count': 0
      }
    };
    conversationListService.markAllAsRead(actionData);
  }
}