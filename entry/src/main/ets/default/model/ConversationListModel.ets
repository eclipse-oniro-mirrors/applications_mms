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

import BaseModel from './BaseModel';
import common from '../data/commonData';
import dataAbility from '@ohos.data.dataAbility';
import mmsTable from '../data/tableData';
import HiLog from '../utils/HiLog';
import LooseObject from '../data/LooseObject'
import rdbStore from '../utils/RdbStoreUtil';
import featureAbility from '@ohos.ability.featureAbility';

const TAG = 'ConversationListModel';

export default class ConversationListModel extends BaseModel {
    async querySessionList(actionData) {
        let predicates = rdbStore.getRdbPredicates(common.tableName.SESSION);
        let numberType = actionData.numberType;
        if (numberType != null) {
            await predicates.equalTo(mmsTable.sessionField.smsType, numberType);
        }
        await predicates.orderByDesc(mmsTable.sessionField.time);
        await predicates.limitAs(actionData.limit);
        let offset = (actionData.page - 1) * actionData.limit;
        await predicates.offsetAs(offset);
        let resultSet = await rdbStore.query(predicates);
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

    async querySessionByTelephone(telephone) {
        HiLog.i(TAG, ', querySessionByTelephone start')
        let predicates = rdbStore.getRdbPredicates(common.tableName.SESSION);
        if (telephone) {
            await predicates.equalTo(mmsTable.sessionField.telephone, telephone);
        }
        let resultSet = await rdbStore.query(predicates);
        resultSet.goToFirstRow();
        let result = await this.buildResultSet(resultSet);
        return result;
    }

    async querySessionById(threadId) {
        let predicates = rdbStore.getRdbPredicates(common.tableName.SESSION);
        if (threadId) {
            await predicates.equalTo(mmsTable.sessionField.id, threadId);
        }
        let resultSet = await rdbStore.query(predicates);
        resultSet.goToFirstRow();
        let result = await this.buildResultSet(resultSet);
        return result;
    }

    async searchSessionByTelephone(telephone, numberType) {
        let predicates = rdbStore.getRdbPredicates(common.tableName.SESSION);
        if (telephone != common.string.EMPTY_STR) {
            await predicates.like(mmsTable.sessionField.telephone, '%' + telephone + '%');
        }
        if (numberType != null) {
            await predicates.equalTo(mmsTable.sessionField.smsType, numberType);
        }
        let resultSet = await rdbStore.query(predicates);
        let sessionList = [];
        while (resultSet.goToNextRow()) {
            let item = await this.buildResultSet(resultSet);
            sessionList.push(item);
        }
        return sessionList;
    }

    async buildResultSet(resultSet) {
        let result: LooseObject = {};
        result.id = await Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.sessionField.id)));
        result.time = await Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.sessionField.time)));
        result.hasDraft = await Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.sessionField.hasDraft)));
        result.smsType = await Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.sessionField.smsType)));
        result.telephone = await resultSet.getString(resultSet.getColumnIndex(mmsTable.sessionField.telephone));
        result.content = await resultSet.getString(resultSet.getColumnIndex(mmsTable.sessionField.content));
        result.contactsNum = await Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.sessionField.contactsNum)));
        result.unreadCount = await Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.sessionField.unreadCount)));
        result.messageCount = await Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.sessionField.messageCount)));
        result.hasMms = await Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.sessionField.hasMms)));
        result.sendStatus = await Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.sessionField.sendStatus)));
        result.hasAttachment = await Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.sessionField.hasAttachment)));
        result.hasLock = await Number(resultSet.getString(resultSet.getColumnIndex(mmsTable.sessionField.hasLock)));
        result.telephoneFormat = result.telephone;
        return result;
    }

    async countSessionList(actionData) {
        let predicates = rdbStore.getRdbPredicates(common.tableName.SESSION);
        let numberType = actionData.numberType;
        if (numberType != null) {
            await predicates.equalTo(mmsTable.sessionField.smsType, numberType);
        }
        let resultSet = await rdbStore.query(predicates);
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
        let dataAbilityHelper = await featureAbility.acquireDataAbilityHelper(
            common.string.URI_MESSAGE_LOG
        );
        let resultColumns = [
            'totalListCount',
            'unreadCount',
            'unreadTotalOfInfo'
        ];
        let condition = new dataAbility.DataAbilityPredicates();
        let managerUri = common.string.URI_MESSAGE_LOG + common.string.URI_MESSAGE_UNREAD_COUNT;
        dataAbilityHelper.query(managerUri, resultColumns, condition, (err, resultSet) => {
            let result: LooseObject = {};
            while (resultSet.goToNextRow()) {
                result.totalListCount = resultSet.getString(0);
                result.unreadCount = resultSet.getString(1);
                result.unreadTotalOfInfo = resultSet.getString(2);
            }
            HiLog.i(TAG, 'statisticalData, result:' + JSON.stringify(result));
            callback(this.encapsulateReturnResult(common.int.SUCCESS, result));
        });
    }

    async markAllAsRead(threadIds, valueBucket) {
        HiLog.i(TAG, 'markAllAsRead, threadIds:' + JSON.stringify(threadIds));
        this.updateById(threadIds, valueBucket);
    }

    async markAllToRead(smsType) {
        let predicates = rdbStore.getRdbPredicates(common.tableName.SESSION);
        predicates.equalTo(mmsTable.sessionField.smsType, smsType);
        predicates.greaterThan(mmsTable.sessionField.unreadCount, 0);
        let valueBucket = {
            'unread_count': 0
        };
        rdbStore.update(predicates, valueBucket);
    }

    async updateById(threadIds, valueBucket) {
        HiLog.i(TAG, ', updateById, threadIds: ' + JSON.stringify(threadIds))
        if (threadIds.length != 0) {
            for (let threadId of threadIds) {
                let predicates = rdbStore.getRdbPredicates(common.tableName.SESSION);
                await predicates.equalTo(mmsTable.sessionField.id, threadId);
                rdbStore.update(predicates, valueBucket);
                HiLog.d(TAG, ', update SESSION TAB end')
            }
        }
    }

    async deleteMessageById(threadIds) {
        HiLog.i(TAG, 'deleteMessageById, threadIds: ' + JSON.stringify(threadIds));
        if (threadIds.length != 0) {
            for (let threadId of threadIds) {
                let predicates = rdbStore.getRdbPredicates(common.tableName.SESSION);
                await predicates.equalTo(mmsTable.sessionField.id, threadId);
                rdbStore.deleteItem(predicates);
                HiLog.d(TAG, ', delete SESSION TAB end')
            }
        }
    }

    insertSession(tableName, valueBucket, callback) {
        let insertPromise = rdbStore.insert(tableName, valueBucket);
        let result: LooseObject = {};
        insertPromise.then((ret) => {
            HiLog.i(TAG, 'insertSession, rowId:' + ret);
            result.code = common.int.SUCCESS;
            result.rowId = ret;
            callback(result);
        }).catch((err) => {
            HiLog.e(TAG, 'insertSession, error: ' + JSON.stringify(err));
            result.code = common.int.FAILURE;
            callback(result);
        });
    }
}