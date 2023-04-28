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

import BaseModel from "./BaseModel";
import common from "../data/commonData";
import HiLog from "../utils/HiLog";
import mmsTable from "../data/tableData";
import LooseObject from "../data/LooseObject"

import dataShare from "@ohos.data.dataShare";
import dataSharePredicates from "@ohos.data.dataSharePredicates";

import featureAbility from "@ohos.ability.featureAbility";
import dataAbility from "@ohos.data.dataAbility";

const TAG = "ContactsModel";

export default class ContactsModel extends BaseModel {
    async queryContactDataByIds(actionData, callback) {
        let dataHelper = await featureAbility.acquireDataAbilityHelper(globalThis.mmsContext, common.string.URI_ROW_CONTACTS);
        let resultColumns = [
            mmsTable.contactDataColumns.detailInfo,
            mmsTable.contactDataColumns.displayName,
        ];
        let condition = new dataAbility.DataAbilityPredicates();;
        let contactDataUri = common.string.URI_ROW_CONTACTS + common.string.CONTACT_DATA_URI;
        condition.in(mmsTable.contactDataColumns.contactId, actionData.contractIds);
        condition.and();
        condition.equalTo(mmsTable.contactDataColumns.typeId, "5");
        condition.and();
        condition.equalTo(mmsTable.contactDataColumns.hasDelete, "0");
        dataHelper.query(contactDataUri, resultColumns, condition).then(resultSet => {
            callback(this.dealResultSet(resultSet));
        }).catch(error => {
            HiLog.e(TAG, "queryContactDataByIds, error: " + JSON.stringify(error.message));
        });
    }

    async queryContactDataByTelephone(actionData, callback) {
        let telephoneDataHelp = await featureAbility.acquireDataAbilityHelper(globalThis.mmsContext,
                                common.string.URI_ROW_CONTACTS);
        let resultColumns = [
            mmsTable.contactDataColumns.detailInfo,
            mmsTable.contactDataColumns.displayName,
        ];
        let condition = new dataAbility.DataAbilityPredicates();;
        let contactDataUri = common.string.URI_ROW_CONTACTS + common.string.CONTACT_DATA_URI;
        condition.in(mmsTable.contactDataColumns.detailInfo, actionData.telephones);
        condition.and();
        condition.equalTo(mmsTable.contactDataColumns.typeId, "5");
        condition.and();
        condition.equalTo(mmsTable.contactDataColumns.hasDelete, "0");
        telephoneDataHelp.query(contactDataUri, resultColumns, condition).then(resultSet => {
            callback(this.dealResultSet(resultSet));
        }).catch(error => {
            HiLog.e(TAG, "queryContactDataByTelephone, error: " + JSON.stringify(error.message));
            callback([]);
        });
    }

    dealResultSet(resultSet) {
        let contracts = [];
        if (resultSet != undefined) {
            while (resultSet.goToNextRow()) {
                let contract: LooseObject = {};
                contract.detailInfo = resultSet.getString(0);
                contract.displayName = resultSet.getString(1);
                contracts.push(contract);
            }
        }
        return contracts;
    }

    async queryContact(actionData, callback) {
        let DAHelper = await featureAbility.acquireDataAbilityHelper(globalThis.mmsContext, common.string.URI_ROW_CONTACTS);
        let resultColumns = [
            mmsTable.contactColumns.id
        ];
        let condition = new dataAbility.DataAbilityPredicates();;
        let rawContactUri = common.string.URI_ROW_CONTACTS + common.string.CONTACT_URI;
        let offset = (actionData.page - 1) * actionData.limit;
        condition.limitAs(actionData.limit)
            .orderByDesc(mmsTable.contactColumns.lastestContactedTime)
            .offsetAs(offset);
        DAHelper.query(rawContactUri, resultColumns, condition).then(resultSet => {
            let rawContactIds = [];
            if (resultSet != undefined) {
                while (resultSet.goToNextRow()) {
                    rawContactIds.push(resultSet.getString(0));
                }
            }
            callback(rawContactIds);
        }).catch(error => {
            HiLog.e(TAG, "queryContact, error: " + JSON.stringify(error.message));
        });
    }

    async countContact(actionData, callback) {
        let DAHelper = await featureAbility.acquireDataAbilityHelper(globalThis.mmsContext, common.string.URI_ROW_CONTACTS);
        let resultColumns = [
            mmsTable.contactColumns.id
        ];
        let condition = new dataAbility.DataAbilityPredicates();;
        let rawContactUri = common.string.URI_ROW_CONTACTS + common.string.CONTACT_URI;
        condition.orderByDesc(mmsTable.contactColumns.lastestContactedTime);
        DAHelper.query(rawContactUri, resultColumns, condition).then(resultSet => {
            let count = 0;
            if (resultSet != undefined) {
                count = resultSet.rowCount;
            }
            callback(count);
        }).catch(error => {
            HiLog.e(TAG, "countContact, error: " + JSON.stringify(error.message));
        });
    }

    async searchContracts(actionData, callback) {
        let searchDataHelper = await featureAbility.acquireDataAbilityHelper(globalThis.mmsContext,
        common.string.URI_ROW_CONTACTS);
        let resultColumns = [
            mmsTable.searchContactView.detailInfo,
            mmsTable.searchContactView.displayName
        ];
        let condition = new dataAbility.DataAbilityPredicates();;
        let searchContactsUri = common.string.URI_ROW_CONTACTS + common.string.CONTACT_SEARCHE;
        condition.equalTo(mmsTable.searchContactView.contentType, "phone")
            .beginWrap()
            .contains(mmsTable.searchContactView.displayName, actionData.telephone)
            .or()
            .contains(mmsTable.searchContactView.detailInfo, actionData.telephone)
            .endWrap();
        searchDataHelper.query(searchContactsUri, resultColumns, condition).then(resultSet => {
            let contracts = this.dealResultSet(resultSet);
            callback(this.encapsulateReturnResult(common.int.SUCCESS, contracts));
        }).catch(error => {
            HiLog.e(TAG, "searchContracts, error: " + JSON.stringify(error.message));
            callback(this.encapsulateReturnCode(common.int.FAILURE));
        });
    }

    /**
     * Querying business card data
     *
     * @param actionData query parameters
     * @callback callback
     * @param context
     */
    async queryProfile(actionData, callback) {
        HiLog.i(TAG, "queryProfile start ");
        let DAHelper = await featureAbility.acquireDataAbilityHelper(globalThis.mmsContext, common.string.URI_ROW_CONTACTS);
        let resultColumns = [
            mmsTable.contactDataColumns.id,
        ];
        let condition = new dataAbility.DataAbilityPredicates();;
        let contactDataUri = common.string.URI_ROW_CONTACTS + common.string.PROFILE_DATA_URI;
        DAHelper.query(contactDataUri, resultColumns, condition).then(resultSet => {
            let count = 0;
            if (resultSet != undefined) {
                count = resultSet.rowCount;
                HiLog.i(TAG, "queryProfile, goToNextRow: " + count);
                resultSet.close();
            }
            callback(count);
        }).catch(error => {
            HiLog.e(TAG, "queryProfile, error: " + JSON.stringify(error.message));
        });
    }
}