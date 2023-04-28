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

import HiLog from "../utils/HiLog";
import common from "../data/commonData";
import telephoneUtil from "../utils/TelephoneUtil";
import LooseObject from "../data/LooseObject";
import ContactsModel from "../model/ContactsModel";

let mContactsModel = new ContactsModel();
const TAG = "ContractService";

export default {

    /**
     * Querying the contact list
     *
     * @param actionData
     * @callback callback
     */
    queryContact(actionData, callback) {
        // Obtain rawContractIds and query contacts.
        mContactsModel.queryContact(actionData, rawContractIds => {
            let result: LooseObject = {};
            actionData.contractIds = rawContractIds;
            // Based on rawContractIds
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
     * Counting the number of rows of contacts
     *
     * @param actionData
     * @callback callback
     */
    countContact(actionData, callback) {
        // Obtain rawContractIds and query contacts.
        mContactsModel.countContact(actionData, count => {
            let result: LooseObject = {};
            result.code = common.int.SUCCESS;
            result.response = count;
            callback(result);
        });
    },

    /**
     * Convert contact parameters
     *
     * @param contracts
     * @callback callback
     */
    async convertContracts(contracts, callback) {
        let messageList = [];
        for (let contract of contracts) {
            let item: LooseObject = {};
            item.contactName = contract.displayName;
            item.headImage = "icon/user_avatar_full_fill.svg";
            item.telephone = contract.detailInfo;
            item.telephoneFormat = contract.detailInfo;
            item.select = false;
            messageList.push(item);
        }
        callback(messageList);
    },

    /**
     * Process contact parameters
     *
     * @param contactObjects
     */
    dealContractParams(contactObjects) {
        if (contactObjects && contactObjects != common.string.EMPTY_STR) {
            let params = [];
            try {
                params = JSON.parse(contactObjects);
            } catch (Error) {
                HiLog.i(TAG, `JSON.parse error ${Error}`);
                return {};
            }
            let contactsNumber: string = common.string.EMPTY_STR;
            let contactsName: string = common.string.EMPTY_STR;
            let contactsNumberFormat: string = common.string.EMPTY_STR;
            let length: number = params.length;
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
     * Query a contact by mobile number.
     *
     * @param actionData
     * @callback callback
     */
    queryContactDataByTelephone(actionData, callback) {
        mContactsModel.queryContactDataByTelephone(actionData, contracts => {
            HiLog.i(TAG, "queryContactDataByTelephone, success");
            callback(contracts);
        });
    },

    /**
     * Fuzzy search for contacts
     *
     * @param actionData
     * @callback callback
     */
    searchContracts(actionData, callback) {
        let result: LooseObject = {};
        mContactsModel.searchContracts(actionData, res => {
            result.code = res.code
            if (res.code == common.int.SUCCESS) {
                result.response = this.dealSearchContracts(res.abilityResult);
                callback(result);
            }
        });
    },

    dealSearchContracts(contracts) {
        let searchContracts = []
        for (let item of contracts) {
            let searchContract: LooseObject = {};
            searchContract.headImage = "icon/user_avatar_full_fill.svg";
            searchContract.contactName = item.displayName;
            searchContract.telephone = item.detailInfo;
            searchContract.telephoneFormat = item.detailInfo;
            searchContracts.push(searchContract);
        }
        return searchContracts;
    },

    /**
     * Check whether a business card exists.
     *
     * @param actionData
     * @callback callback
     */
    judgeIsExitProfile(actionData, callback) {
        HiLog.i(TAG, "judgeIsExitProfile, start");
        mContactsModel.queryProfile(actionData, res => {
            let result = false;
            if (res > 0) {
                result = true;
            }
            callback(result);
        });
    }
}