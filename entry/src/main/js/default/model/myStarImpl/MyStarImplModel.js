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
// log 工具类
import mmsLog from '../../utils/MmsLog.js';
import mmsTable from '../../pages/mms_table.js';

const TAG = 'MyStarImplModel ->';

export default class MyStarImplModel extends BaseModel {
    async queryFavoriteMessageList(actionData, callback) {
        mmsLog.info(TAG + 'queryFavoriteMessageList param:' + actionData);
        let featureAbility = actionData.featureAbility;
        var dataHelper = await featureAbility.getDataAbilityHelper(
            common.string.URI_MESSAGE_LOG
        );
        var resultColumns = this.dealFavoriteResultColumns();
        let ohosDataAbility = actionData.ohosDataAbility;
        let condition = new ohosDataAbility.DataAbilityPredicates();
        condition.equalTo(mmsTable.messageInfo.isCollect, actionData.hasCollect);
        condition.limitAs(actionData.limit);
        let offset = (actionData.page - 1) * actionData.limit;
        condition.offsetAs(offset);
        let managerUri = common.string.URI_MESSAGE_LOG + common.string.URI_MESSAGE_INFO_TABLE;
        dataHelper.query(managerUri, resultColumns, condition).then(resultSet => {
            let resultList = [];
            while (resultSet.goToNextRow()) {
                let result = {};
                result.msgId = resultSet.getString(0);
                result.receiverNumber = resultSet.getString(1);
                result.senderNumber = resultSet.getString(2);
                result.startTime = resultSet.getString(3);
                result.endTime = resultSet.getString(4);
                result.msgType = resultSet.getString(5);
                result.msgTitle = resultSet.getString(6);
                result.msgContent = resultSet.getString(7);
                result.isCollect = resultSet.getString(8);
                result.sessionId = resultSet.getString(9);
                result.groupId = resultSet.getString(10);
                result.isSender = resultSet.getString(11);
                resultList.push(result);
            }
            callback(super.encapsulateReturnResult(common.int.SUCCESS, resultList));
        }).catch(error => {
            mmsLog.info(TAG + 'queryFavoriteMessageList error:' + error);
            callback(super.encapsulateReturnResult(common.int.FAILURE));
        });
    }

    dealFavoriteResultColumns() {
        var resultColumns = [
            mmsTable.messageInfo.msgId,
            mmsTable.messageInfo.receiverNumber,
            mmsTable.messageInfo.senderNumber,
            mmsTable.messageInfo.startTime,
            mmsTable.messageInfo.endTime,
            mmsTable.messageInfo.msgType,
            mmsTable.messageInfo.msgTitle,
            mmsTable.messageInfo.msgContent,
            mmsTable.messageInfo.isCollect,
            mmsTable.messageInfo.sessionId,
            mmsTable.messageInfo.groupId,
            mmsTable.messageInfo.isSender
        ];
        return resultColumns;
    }

    async countFavoriteList(actionData, callback) {
        mmsLog.info(TAG + 'countFavoriteList param:' + actionData);
        let featureAbility = actionData.featureAbility;
        var dataAbilityHelper = await featureAbility.getDataAbilityHelper(
            common.string.URI_MESSAGE_LOG
        );
        var resultColumns = [
            mmsTable.messageInfo.msgId,
        ];
        let ohosDataAbility = actionData.ohosDataAbility;
        let condition = new ohosDataAbility.DataAbilityPredicates();
        condition.equalTo(mmsTable.messageInfo.isCollect, actionData.hasCollect);
        let managerUri = common.string.URI_MESSAGE_LOG + common.string.URI_MESSAGE_INFO_TABLE;
        dataAbilityHelper.query(managerUri, resultColumns, condition).then(resultSet => {
            let count = 0;
            while (resultSet.goToNextRow()) {
                let result = {};
                result.msgId = resultSet.getString(0);
                count++;
            }
            callback(super.encapsulateReturnResult(common.int.SUCCESS, count));
        }).catch(error => {
            mmsLog.info(TAG + 'queryFavoriteMessageList error:' + error);
            callback(super.encapsulateReturnResult(common.int.FAILURE));
        });
    }
}