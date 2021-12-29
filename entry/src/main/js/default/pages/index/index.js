/**
 * Copyright (c) 2021 Huawei Device Co., Ltd.
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
import router from '@system.router';

// JS公共常量
import common from '../common_constants.js';
import mmsLog from '../../../default/utils/MmsLog.js';
import contactService from '../../service/ContractService.js';
import mmsTable from '../../pages/mms_table.js';
import simCardService from '../../service/SimCardService.js';

const TAG = 'index.js --->';

export default {
    data: {
        uri: common.string.EMPTY_STR,
        pageFlag: 'conversationList',
        contractParams: null
    },
    onInit() {
        // 初始化数据库
        this.initRdb();
    },
    onShow() {
        this.initStorage();
        this.getWant();
    },
    async initRdb() {
        // 创建数据库表
        let rdbStore = this.$app.$def.rdbStore;
        rdbStore.createRdbStore().then(async (ret) => {
            mmsLog.log(' logMessage createRdbStore first done: ' + ret);
            await rdbStore.createTable(mmsTable.table.session);
        }).catch((err) => {
            mmsLog.log(' logMessage error insert first done: ' + err);
        });
    },
    initStorage() {
        let preferences = this.$app.$def.preferences;
        preferences.initDataStorage().then((ret) => {
            mmsLog.log('initStorage first done:' + ret);
            // 获取simCount
            this.initSimCardNum(preferences);
            // 获取卡的运营商
            this.simInfoProcessor(preferences);
        }).catch((err) => {
            mmsLog.log('initStorage first done:' + err);
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
        let featureAbility = this.$app.$def.featureAbility;
        featureAbility.getWant().then((Want) => {
            mmsLog.log('getWant,start');
            let parameters = Want.parameters;
            if (parameters) {
                if (parameters.pageFlag) {
                    this.pageFlag = parameters.pageFlag;
                }
                this.contractParams = contactService.dealContractParams(parameters.contactObjects);
            }
            if (Want.uri != common.string.EMPTY_STR) {
                this.pageFlag = Want.uri;
            }
            // 页面跳转
            this.jump();
        }).catch((error) => {
            mmsLog.error('Operation failed. Cause: ' + JSON.stringify(error));
        })
    },
    jump() {
        let result = {};
        switch (this.pageFlag) {
            case 'conversationList':
                result.uri = 'pages/conversation_list/conversation_list';
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
        let conversationListService = this.$app.$def.conversationListService;
        let rdbStore = this.$app.$def.rdbStore;
        let sessionListPromise = new Promise((resolve) => {
            let strContactsNumber = this.contractParams.strContactsNumber;
            conversationListService.querySessionByTelephone(rdbStore, strContactsNumber, res => {
                resolve(res);
            });
        });
        Promise.all([sessionListPromise]).then(res => {
            if (res[0].code == common.int.SUCCESS && res[0].response.id > 0) {
                result.params.threadId = res[0].response.id;
            } else {
                result.params.isNewMsg = true;
            }
            mmsLog.log(TAG + 'jump,start');
            router.replace(result);
        }).catch(err => {
            mmsLog.log(TAG + 'jumpIsNewPage:' + err);
        });
    }
}
