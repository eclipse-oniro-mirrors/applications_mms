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

import BaseModel from '../BaseModel.js';
import common from '../../pages/common_constants.js';
import mmsLog from '../../../default/utils/MmsLog.js';
import mmsTable from '../../pages/mms_table.js';

const TAG = 'ContactsModel ->';

export default class ContactsModel extends BaseModel {
    async queryContactDataByIds(actionData, callback) {
        mmsLog.log(TAG + 'queryContactDataByIds, params:' + actionData);
        let featureAbility = actionData.featureAbility;
        let dataHelper = await featureAbility.getDataAbilityHelper(common.string.URI_ROW_CONTACTS);
        let resultColumns = [
            mmsTable.contactDataColumns.detailInfo,
            mmsTable.contactDataColumns.displayName,
        ];
        let ohosDataAbility = actionData.ohosDataAbility;
        let condition = new ohosDataAbility.DataAbilityPredicates();
        let contactDataUri = common.string.URI_ROW_CONTACTS + common.string.CONTACT_DATA_URI;
        condition.in(mmsTable.contactDataColumns.contactId, actionData.contractIds);
        condition.and();
        condition.equalTo(mmsTable.contactDataColumns.typeId, '5');
        condition.and();
        condition.equalTo(mmsTable.contactDataColumns.hasDelete, '0');
        dataHelper.query(contactDataUri, resultColumns, condition).then(resultSet => {
            callback(this.dealResultSet(resultSet));
        }).catch(error => {
            mmsLog.info('queryContactDataByIds error:' + error);
        });
    }

    async queryContactDataByTelephone(actionData, callback) {
        let featureAbility = actionData.featureAbility;
        let telephoneDataHelp = await featureAbility.getDataAbilityHelper(common.string.URI_ROW_CONTACTS);
        let resultColumns = [
            mmsTable.contactDataColumns.detailInfo,
            mmsTable.contactDataColumns.displayName,
        ];
        let ohosDataAbility = actionData.ohosDataAbility;
        let condition = new ohosDataAbility.DataAbilityPredicates();
        let contactDataUri = common.string.URI_ROW_CONTACTS + common.string.CONTACT_DATA_URI;
        condition.in(mmsTable.contactDataColumns.detailInfo, actionData.telephones);
        condition.and();
        condition.equalTo(mmsTable.contactDataColumns.typeId, '5');
        condition.and();
        condition.equalTo(mmsTable.contactDataColumns.hasDelete, '0');
        telephoneDataHelp.query(contactDataUri, resultColumns, condition).then(resultSet => {
            callback(this.dealResultSet(resultSet));
        }).catch(error => {
            mmsLog.info('queryContactDataByTelephone error:' + error);
        });
    }

    dealResultSet(resultSet) {
        let contracts = [];
        while (resultSet.goToNextRow()) {
            let contract = {};
            contract.detailInfo = resultSet.getString(0);
            contract.displayName = resultSet.getString(1);
            contracts.push(contract);
        }
        return contracts;
    }

    async queryContact(actionData, callback) {
        let featureAbility = actionData.featureAbility;
        let DAHelper = await featureAbility.getDataAbilityHelper(common.string.URI_ROW_CONTACTS);
        let resultColumns = [
            mmsTable.contactColumns.id
        ];
        let ohosDataAbility = actionData.ohosDataAbility;
        let condition = new ohosDataAbility.DataAbilityPredicates();
        let rawContactUri = common.string.URI_ROW_CONTACTS + common.string.CONTACT_URI;
        let offset = (actionData.page - 1) * actionData.limit;
        condition.limitAs(actionData.limit)
            .orderByDesc(mmsTable.contactColumns.lastestContactedTime)
            .offsetAs(offset);
        DAHelper.query(rawContactUri, resultColumns, condition).then(resultSet => {
            let rawContactIds = [];
            while (resultSet.goToNextRow()) {
                rawContactIds.push(resultSet.getString(0));
            }
            callback(rawContactIds);
        }).catch(error => {
            mmsLog.info('queryRowContact ,error:' + error);
        });
    }

    async countContact(actionData, callback) {
        let featureAbility = actionData.featureAbility;
        let DAHelper = await featureAbility.getDataAbilityHelper(common.string.URI_ROW_CONTACTS);
        let resultColumns = [
            mmsTable.contactColumns.id
        ];
        let ohosDataAbility = actionData.ohosDataAbility;
        let condition = new ohosDataAbility.DataAbilityPredicates();
        let rawContactUri = common.string.URI_ROW_CONTACTS + common.string.CONTACT_URI;
        condition.orderByDesc(mmsTable.contactColumns.lastestContactedTime);
        DAHelper.query(rawContactUri, resultColumns, condition).then(resultSet => {
            let count = 0;
            while (resultSet.goToNextRow()) {
                count++;
            }
            callback(count);
        }).catch(error => {
            mmsLog.info('countContact ,error:' + error);
        });
    }

    async searchContracts(actionData, callback) {
        mmsLog.log(TAG + 'searchContracts,actionData:' + actionData);
        let featureAbility = actionData.featureAbility;
        let searchDataHelper = await featureAbility.getDataAbilityHelper(common.string.URI_ROW_CONTACTS);
        let resultColumns = [
            mmsTable.searchContactView.detailInfo,
            mmsTable.searchContactView.displayName
        ];
        let ohosDataAbility = actionData.ohosDataAbility;
        let condition = new ohosDataAbility.DataAbilityPredicates();
        let searchContactsUri = common.string.URI_ROW_CONTACTS + common.string.CONTACT_SEARCHE;
        condition.equalTo(mmsTable.searchContactView.contentType, 'phone')
            .beginWrap()
            .contains(mmsTable.searchContactView.displayName, actionData.telephone)
            .or()
            .contains(mmsTable.searchContactView.detailInfo, actionData.telephone)
            .endWrap();
        searchDataHelper.query(searchContactsUri, resultColumns, condition).then(resultSet => {
            let contracts = this.dealResultSet(resultSet);
            callback(super.encapsulateReturnResult(common.int.SUCCESS, contracts));
        }).catch(error => {
            mmsLog.info(TAG + 'searchContracts contracts error:' + error);
            callback(super.encapsulateReturnCode(common.int.FAILURE));
        });
    }

    /**
     * 查询名片数据
     * @param actionData 查询参数
     * @param callback 回调
     */
    async queryProfile(actionData, callback) {
        mmsLog.log('jumpToCard  queryProfile is start ');
        let featureAbility = actionData.featureAbility;
        let DAHelper = await featureAbility.getDataAbilityHelper(common.string.URI_ROW_CONTACTS);
        mmsLog.log('jumpToCard  queryProfile is condition: '+ DAHelper);
        let resultColumns = [
            mmsTable.contactDataColumns.id,
        ];
        let ohosDataAbility = actionData.ohosDataAbility;
        let condition = new ohosDataAbility.DataAbilityPredicates();
        let contactDataUri = common.string.URI_ROW_CONTACTS + common.string.PROFILE_DATA_URI;
        DAHelper.query(contactDataUri, resultColumns, condition).then(resultSet => {
            let count = 0;
            while (resultSet.goToNextRow()) {
                count++;
            }
            mmsLog.log('jumpToCard  queryProfile is goToNextRow: ' + count);
            resultSet.close();
            callback(count);
        }).catch(error => {
            mmsLog.info('queryProfile error:' + error);
        });
    }
}