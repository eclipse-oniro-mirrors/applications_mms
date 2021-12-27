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
import mmsTable from '../../pages/mms_table.js';
import mmsLog from '../../utils/MmsLog.js';

const TAG = 'ConversationListModel ->';

export default class ConversationListModel extends BaseModel {

    async querySessionList(rdbStore, actionData) {
        mmsLog.log(TAG + 'querySessionList,db,actionData:' + actionData);
        let predicates = rdbStore.getRdbPredicates(common.tableName.SESSION);
        let numberType = actionData.numberType;
        if (numberType != null) {
            await predicates.equalTo(mmsTable.sessionField.smsType, numberType);
        }
        await predicates.orderByDesc(mmsTable.sessionField.time);
        await predicates.limitAs(actionData.limit);
        let offset = (actionData.page - 1) * actionData.limit;
        await predicates.offsetAs(offset);
        let resultSet = await rdbStore.getRdbStore().query(predicates);
        let sessionList = [];
        while (resultSet.goToNextRow()) {
            let item = await this.buildResultSet(resultSet);
            sessionList.push(item);
        }
        let result = {
            response: sessionList,
        }
        return result;
    }

    async querySessionByTelephone(rdbStore, telephone) {
        let predicates = rdbStore.getRdbPredicates(common.tableName.SESSION);
        if (telephone) {
            await predicates.equalTo(mmsTable.sessionField.telephone, telephone);
        }
        let resultSet = await rdbStore.getRdbStore().query(predicates);
        resultSet.goToFirstRow();
        let result = await this.buildResultSet(resultSet);
        return result;
    }

    async querySessionById(rdbStore, threadId) {
        let predicates = rdbStore.getRdbPredicates(common.tableName.SESSION);
        if (threadId) {
            await predicates.equalTo(mmsTable.sessionField.id, threadId);
        }
        let resultSet = await rdbStore.getRdbStore().query(predicates);
        resultSet.goToFirstRow();
        let result = await this.buildResultSet(resultSet);
        return result;
    }

    async searchSessionByTelephone(rdbStore, telephone, numberType) {
        let predicates = rdbStore.getRdbPredicates(common.tableName.SESSION);
        if (telephone != common.string.EMPTY_STR) {
            await predicates.like(mmsTable.sessionField.telephone, '%' + telephone + '%');
        }
        if (numberType != null) {
            await predicates.equalTo(mmsTable.sessionField.smsType, numberType);
        }
        let resultSet = await rdbStore.getRdbStore().query(predicates);
        let sessionList = [];
        while (resultSet.goToNextRow()) {
            let item = await this.buildResultSet(resultSet);
            sessionList.push(item);
        }
        return sessionList;
    }

    async buildResultSet(resultSet) {
        let result = {};
        result.id = await resultSet.getLong(resultSet.getColumnIndex(mmsTable.sessionField.id));
        result.time = await resultSet.getLong(resultSet.getColumnIndex(mmsTable.sessionField.time));
        result.hasDraft = await resultSet.getLong(resultSet.getColumnIndex(mmsTable.sessionField.hasDraft));
        result.smsType = await resultSet.getLong(resultSet.getColumnIndex(mmsTable.sessionField.smsType));
        result.telephone = await resultSet.getString(resultSet.getColumnIndex(mmsTable.sessionField.telephone));
        result.content = await resultSet.getString(resultSet.getColumnIndex(mmsTable.sessionField.content));
        result.contactsNum = await resultSet.getLong(resultSet.getColumnIndex(mmsTable.sessionField.contactsNum));
        result.unreadCount = await resultSet.getLong(resultSet.getColumnIndex(mmsTable.sessionField.unreadCount));
        result.messageCount = await resultSet.getLong(resultSet.getColumnIndex(mmsTable.sessionField.messageCount));
        result.hasMms = await resultSet.getLong(resultSet.getColumnIndex(mmsTable.sessionField.hasMms));
        result.sendingStatus = await resultSet.getLong(resultSet.getColumnIndex(mmsTable.sessionField.sendingStatus));
        result.hasAttachment = await resultSet.getLong(resultSet.getColumnIndex(mmsTable.sessionField.hasAttachment));
        result.hasLock = await resultSet.getLong(resultSet.getColumnIndex(mmsTable.sessionField.hasLock));
        result.telephoneFormat = result.telephone;
        return result;
    }

    async countSessionList(rdbStore, actionData) {
        let predicates = rdbStore.getRdbPredicates(common.tableName.SESSION);
        let numberType = actionData.numberType;
        if (numberType != null) {
            await predicates.equalTo(mmsTable.sessionField.smsType, numberType);
        }
        let resultSet = await rdbStore.getRdbStore().query(predicates);
        let count = 0;
        while (resultSet.goToNextRow()) {
            count++;
        }
        let result = {
            total: count,
        }
        return result;
    }

    async statisticalData(actionData, callback) {
        let featureAbility = actionData.featureAbility;
        let dataAbilityHelper = await featureAbility.getDataAbilityHelper(
            common.string.URI_MESSAGE_LOG
        );
        let resultColumns = [
            'totalListCount',
            'unreadCount',
            'unreadTotalOfInfo'
        ];
        let ohosDataAbility = actionData.ohosDataAbility;
        let condition = new ohosDataAbility.DataAbilityPredicates();
        let managerUri = common.string.URI_MESSAGE_LOG + common.string.URI_MESSAGE_UNREAD_COUNT;
        dataAbilityHelper.query(managerUri, resultColumns, condition, (err, resultSet) => {
            let result = {};
            while (resultSet.goToNextRow()) {
                result.totalListCount = resultSet.getString(0);
                result.unreadCount = resultSet.getString(1);
                result.unreadTotalOfInfo = resultSet.getString(2);
            }
            callback(super.encapsulateReturnResult(common.int.SUCCESS, result));
        });
    }

    async markAllAsRead(rdbStore, threadIds, valueBucket) {
        mmsLog.info(TAG + 'markAllAsReadById, threadIds:' + JSON.stringify(threadIds));
        this.updateById(rdbStore, threadIds, valueBucket);
    }

    async markAllToRead(rdbStore, smsType) {
        let predicates = rdbStore.getRdbPredicates(common.tableName.SESSION);
        predicates.equalTo(mmsTable.sessionField.sms_type, smsType);
        predicates.greaterThan(mmsTable.sessionField.unread_count, 0);
        let valueBucket = {
            'unread_count': 0
        };
        rdbStore.update(predicates, valueBucket);
    }

    async updateById(rdbStore, threadIds, valueBucket) {
        if (threadIds.length != 0) {
            for (let threadId of threadIds) {
                let predicates = rdbStore.getRdbPredicates(common.tableName.SESSION);
                await predicates.equalTo(mmsTable.sessionField.id, threadId);
                rdbStore.update(predicates, valueBucket);
            }
        }
    }

    async deleteMessageById(rdbStore, threadIds) {
        mmsLog.info(TAG + 'deleteMessageById, threadIds:' + threadIds);
        if (threadIds.length != 0) {
            for (let threadId of threadIds) {
                let predicates = rdbStore.getRdbPredicates(common.tableName.SESSION);
                await predicates.equalTo(mmsTable.sessionField.id, threadId);
                rdbStore.deleteItem(predicates);
            }
        }
    }

    insertSession(rdbStore, tableName, valueBucket, callback) {
        let insertPromise = rdbStore.insert(tableName, valueBucket);
        let result = {};
        insertPromise.then((ret) => {
            mmsLog.log(TAG + 'insertSession rowId:' + ret);
            result.code = common.int.SUCCESS;
            result.rowId = ret;
            callback(result);
        }).catch((err) => {
            mmsLog.log(TAG + 'insertSession error: ' + err);
            result.code = common.int.FAILURE;
            callback(result);
        });
    }
}