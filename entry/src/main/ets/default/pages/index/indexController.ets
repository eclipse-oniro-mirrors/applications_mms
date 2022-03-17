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

import abilityAccessCtrl from '@ohos.abilityAccessCtrl'
import appStorage from '../../utils/AppStorageUtil';
import bundle from '@ohos.bundle'
// JS公共常量
import common from '../../data/commonData';
import contactService from '../../service/ContractService';
import conversationListService from '../../service/ConversationListService';
import featureAbility from '@ohos.ability.featureAbility';
import LooseObject from '../../data/LooseObject'
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
    let insertPromise = this.verifyPermissions();
    insertPromise.then((requestPermissions) => {
      if (requestPermissions.length == 0 || requestPermissions == []) {
        this.getWant();
      } else {
        let context = featureAbility.getContext();
        context.requestPermissionsFromUser(requestPermissions, 1, (data) => {
          if (data.authResults == undefined) {
            return;
          }
          HiLog.i(TAG, "data authResults:" + JSON.stringify(data.authResults));
          for (let i = 0; i < data.authResults.length; i++) {
            if (data.authResults[i] == -1) {
              HiLog.i(TAG, 'Application requestPermissionsFromUser failed');
              return;
            }
          }
          this.getWant();
        });
        HiLog.i(TAG, 'Application requestPermissionsFromUser end');
      }
    }).catch((err) => {
      HiLog.e(TAG, 'verifyPermissions, error: ' + JSON.stringify(err));
    });
    // 初始化数据库
    this.initRdb();
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
      HiLog.i(TAG, 'initStorage, first done:' + prefIns);
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
      HiLog.i(TAG, 'getWant, want: ' + JSON.stringify(want));
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
      HiLog.e(TAG, 'getWant, failed Cause: ' + JSON.stringify(error));
    })
  },

  jump() {
    HiLog.i(TAG, "jump, pageFlag=" + this.pageFlag);
    let result = {
      uri: '',
      params: ''
    };
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
      HiLog.i(TAG, 'jumpIsNewPage, querySessionByTelephone res: ' + JSON.stringify(res));
      if (res.code == common.int.SUCCESS && res.response.id > 0) {
        result.params.threadId = res.response.id;
      } else {
        result.params.isNewMsg = true;
      }
      router.replace(result);
    });
  },

  async verifyPermissions() {
    let array: Array<string> = [
      "ohos.permission.READ_CONTACTS",
      "ohos.permission.READ_MESSAGES",
      "ohos.permission.SEND_MESSAGES",
      "ohos.permission.SET_TELEPHONY_STATE",
      "ohos.permission.GET_TELEPHONY_STATE",
      "ohos.permission.RECEIVE_SMS",
      "ohos.permission.PLACE_CALL"
    ];

    var bundleFlag = 0;
    var tokenID = undefined;
    var userID = 100;
    var appInfo = await bundle.getApplicationInfo('com.ohos.mms', bundleFlag, userID);
    tokenID = appInfo.accessTokenId;
    var atManager = abilityAccessCtrl.createAtManager();
    let requestPermissions: Array<string> = [];
    for (let i = 0;i < array.length; i++) {
      var result = await atManager.verifyAccessToken(tokenID, array[i]);
      HiLog.i(TAG, 'verifyPermissions %s', JSON.stringify(result));
      if (result != abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
        requestPermissions.push(array[i]);
      }
    }
    HiLog.i(TAG, 'verifyPermissions %s', JSON.stringify(requestPermissions));
    return requestPermissions;
  }
}