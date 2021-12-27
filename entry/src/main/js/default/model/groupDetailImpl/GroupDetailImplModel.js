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

const TAG = 'GroupDetailImplModel ->';

export default class GroupDetailImplModel extends BaseModel {
    async queryGroupDetail(actionData, callback) {
        mmsLog.info(TAG + 'queryGroupDetail param:' + actionData);
        let featureAbility = actionData.featureAbility;
        var dataAbilityHelper = await featureAbility.getDataAbilityHelper(
            common.string.URI_MESSAGE_LOG
        );
        var resultColumns = [
            mmsTable.messageInfo.msgId,
            mmsTable.messageInfo.receiverNumber,
            mmsTable.messageInfo.senderNumber,
            mmsTable.messageInfo.startTime,
            mmsTable.messageInfo.endTime,
            mmsTable.messageInfo.msgType,
            mmsTable.messageInfo.msgContent,
            mmsTable.messageInfo.msgState
        ];
        let ohosDataAbility = actionData.ohosDataAbility;
        let condition = new ohosDataAbility.DataAbilityPredicates();
        condition.equalTo(mmsTable.messageInfo.sessionId, actionData.threadId);
        condition.equalTo(mmsTable.messageInfo.groupId, actionData.groupId);
        let managerUri = common.string.URI_MESSAGE_LOG + common.string.URI_MESSAGE_INFO_TABLE;
        dataAbilityHelper.query(managerUri, resultColumns, condition).then(resultSet => {
            let resultList = [];
            while (resultSet.goToNextRow()) {
                let result = {};
                result.msgId = resultSet.getString(0);
                result.receiverNumber = resultSet.getString(1);
                result.senderNumber = resultSet.getString(2);
                result.startTime = resultSet.getString(3);
                result.endTime = resultSet.getString(4);
                result.msgType = resultSet.getString(5);
                result.msgContent = resultSet.getString(6);
                result.msgState = resultSet.getString(7);
                resultList.push(result);
            }
            ;
            callback(super.encapsulateReturnResult(common.int.SUCCESS, resultList));
        }).catch(error => {
            mmsLog.info(TAG + 'queryGroupDetail error:' + error);
            callback(super.encapsulateReturnResult(common.int.FAILURE));
        });
    }
}