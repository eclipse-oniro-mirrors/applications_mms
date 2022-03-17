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

import HiLog from '../utils/HiLog';
import ContactsModel from '../model/ContactsModel';
import common from '../data/commonData';
import telephoneUtil from '../utils/TelephoneUtil';
import LooseObject from '../data/LooseObject'

const TAG = 'ContractService';

let mContactsModel = new ContactsModel();

export default {

    /**
     * 查询联系人列表
     * @param actionData 入参
     * @return 结果集
     */
    queryContact(actionData, callback) {
        // 获取rawContractIds,去查询联系人
        mContactsModel.queryContact(actionData, rawContractIds => {
            let result: LooseObject = {};
            actionData.contractIds = rawContractIds;
            // 根据rawContractIds
            mContactsModel.queryContactDataByIds(actionData, contracts => {
                result.code = common.int.SUCCESS;
                this.convertContracts(contracts, messageList => {
                    result.response = messageList;
                    callback(result);
                });
            });
        });
    },

    /**
     * 统计联系人的行数
     * @param actionData 入参
     * @return 结果集
     */
    countContact(actionData, callback) {
        // 获取rawContractIds,去查询联系人
        mContactsModel.countContact(actionData, count => {
            let result: LooseObject = {};
            result.code = common.int.SUCCESS;
            result.response = count;
            callback(result);
        });
    },

    /**
     * 转换联系人参数
     * @param contracts 联系人列表
     * @return 转换后的数据
     */
    async convertContracts(contracts, callback) {
        let messageList = [];
        for (let contract of contracts) {
            let item: LooseObject = {};
            item.contactName = contract.displayName;
            item.headImage = 'icon/user_avatar_full_fill.svg';
            item.telephone = contract.detailInfo;
            item.telephoneFormat = contract.detailInfo;
            item.select = false;
            messageList.push(item);
        }
        callback(messageList);
    },

    /**
     * 处理联系人参数
     * @param contactObjects 联系人数据
     * @return 解析出来的参数
     */
    dealContractParams(contactObjects) {
        if (contactObjects && contactObjects != common.string.EMPTY_STR) {
            let params = JSON.parse(contactObjects);
            let contactsNumber = common.string.EMPTY_STR;
            let contactsName = common.string.EMPTY_STR;
            let contactsNumberFormat = common.string.EMPTY_STR;
            let length = params.length;
            for (let item of params) {
                contactsNumber = contactsNumber + item.telephone + common.string.COMMA;
                contactsNumberFormat = contactsNumberFormat + item.telephone + common.string.COMMA;
                if (item.contactsName) {
                    contactsName += (item.contactsName + common.string.COMMA);
                } else if (length > 1) {
                    contactsName += (item.telephone + common.string.COMMA);
                }
            }
            let telephnoe = contactsNumber.substring(0, contactsNumber.length - 1);
            contactsNumber = telephoneUtil.dealTelephoneSort(telephnoe);
            let contractParams = {
                strContactsNumber: contactsNumber,
                strContactsNumberFormat: contactsNumber,
                strContactsName: contactsName.substring(0, contactsName.length - 1),
                contactsNum: length,
            }
            return contractParams;
        }
    },

    /**
     * 根据手机号，查询联系人
     * @param actionData 参数
     * @param callback 回调
     */
    queryContactDataByTelephone(actionData, callback) {
        mContactsModel.queryContactDataByTelephone(actionData, contracts => {
            HiLog.i(TAG, 'queryContactDataByTelephone, success');
            callback(contracts);
        })
    },

    /**
     * 模糊查询联系人
     * @param actionData
     * @param callback
     */
    searchContracts(actionData, callback) {
        let result: LooseObject = {};
        mContactsModel.searchContracts(actionData, res => {
            result.code = res.code
            if(res.code == common.int.SUCCESS) {
                result.response = this.dealSearchContracts(res.abilityResult);
                callback(result);
            }
        })
    },
    dealSearchContracts(contracts) {
        let searchContracts = []
        for(let item of contracts) {
            let searchContract: LooseObject = {};
            searchContract.headImage = 'icon/user_avatar_full_fill.svg';
            searchContract.contactName = item.displayName;
            searchContract.telephone = item.detailInfo;
            searchContract.telephoneFormat = item.detailInfo;
            searchContracts.push(searchContract);
        }
        return searchContracts;
    },

    /**
     * 判断是否存在名片
     *
     * @param {Object} actionData 数据
     * @param {Object} callback 回调函数
     */
    judgeIsExitProfile(actionData, callback) {
        HiLog.i(TAG, 'judgeIsExitProfile, start');
        mContactsModel.queryProfile(actionData, res => {
            HiLog.i(TAG, 'judgeIsExitProfile, res: ' + res);
            let result = false;
            if (res > 0) {
                result = true;
            }
            callback(result);
        });
    }
}