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
import MorkDataModel from '../MorkDataModel.js';
import common from '../../pages/common_constants.js';
import mmsTable from '../../pages/mms_table.js';
// log 工具类
import mmsLog from '../../utils/MmsLog.js';

let morkDataModel = new MorkDataModel();
const TAG = 'ConversationModel ->';

export default class ConversationModel extends BaseModel {
    async queryMessageDetail(actionData, callback) {
        mmsLog.log(TAG + 'queryMessageDetail param:' + actionData);
        let featureAbility = actionData.featureAbility;
        let dataAbilityHelper = await featureAbility.getDataAbilityHelper(
            common.string.URI_MESSAGE_LOG
        );
        var resultColumns = this.buildResultColumns();
        let condition = this.buildQueryCondition(actionData);
        let managerUri = common.string.URI_MESSAGE_LOG + common.string.URI_MESSAGE_INFO_TABLE;
        dataAbilityHelper.query(managerUri, resultColumns, condition).then(resultSet => {
            let resultList = [];
            while (resultSet.goToNextRow()) {
                let result = {};
                this.dealBaseColumsData(result, resultSet);
                result.operatorServiceNumber = resultSet.getString(10);
                result.msgCode = resultSet.getString(11);
                result.isLock = resultSet.getString(12);
                result.isRead = resultSet.getString(13);
                result.isCollect = resultSet.getString(14);
                result.sessionType = resultSet.getString(15);
                result.retrNumber = resultSet.getString(16);
                result.isSubsection = resultSet.getString(17);
                result.sessionId = resultSet.getString(18);
                result.groupId = resultSet.getString(19);
                result.isSender = resultSet.getString(20);
                result.isSendReport = resultSet.getString(21);
                resultList.push(result);
            }
            callback(super.encapsulateReturnResult(common.int.SUCCESS, resultList));
        }).catch(error => {
            mmsLog.log(TAG + 'queryMessageDetail error:' + error);
            callback(super.encapsulateReturnResult(common.int.FAILURE));
        });
    }

    buildQueryCondition(actionData) {
        let ohosDataAbility = actionData.ohosDataAbility;
        let condition = new ohosDataAbility.DataAbilityPredicates();
        if (actionData.isDraft != null && actionData.isDraft) {
            condition.equalTo(mmsTable.messageInfo.groupId, actionData.groupId);
            condition.equalTo(mmsTable.messageInfo.msgState, actionData.sendStatus);
        }
        if (actionData.threadId != null) {
            let sessionId = actionData.threadId + common.string.EMPTY_STR;
            condition.equalTo(mmsTable.messageInfo.sessionId, sessionId);
        }
        if (actionData.threadIds != null && actionData.threadIds.length > 0) {
            let sessionIds = this.groupIdToString(actionData.threadIds);
            condition.in(mmsTable.messageInfo.sessionId, sessionIds);
        }
        if (actionData.msgIds != null && actionData.msgIds.length != 0) {
            condition.in(mmsTable.messageInfo.msgId, actionData.msgIds);
        }
        if (actionData.hasLock != null) {
            condition.equalTo(mmsTable.messageInfo.isLock, actionData.hasLock);
        }
        if (actionData.hasRead != null) {
            condition.equalTo(mmsTable.messageInfo.isRead, actionData.hasRead);
        }
        return condition;
    }

    buildBaseColumns() {
        var resultColumns = [
            mmsTable.messageInfo.msgId,
            // 接收者手机号
            mmsTable.messageInfo.receiverNumber,
            mmsTable.messageInfo.senderNumber,
            mmsTable.messageInfo.startTime,
            mmsTable.messageInfo.endTime,
            mmsTable.messageInfo.msgType,
            // sms = 0,mms,
            mmsTable.messageInfo.smsType,
            // 0-普通，1-通知
            mmsTable.messageInfo.msgTitle,
            mmsTable.messageInfo.msgContent,
            mmsTable.messageInfo.msgState
        ];
        return resultColumns;
    }

    buildResultColumns() {
        let bascColums = this.buildBaseColumns();
        var resultColumns = [
            mmsTable.messageInfo.operatorServiceNumber,
            mmsTable.messageInfo.msgCode,
            mmsTable.messageInfo.isLock,
            mmsTable.messageInfo.isRead,
            mmsTable.messageInfo.isCollect,
            mmsTable.messageInfo.sessionType,
            // 0 - 普通  1 - 广播 2 - 群发
            mmsTable.messageInfo.retryNumber,
            // 重发次数
            mmsTable.messageInfo.isSubsection,
            mmsTable.messageInfo.sessionId,
            mmsTable.messageInfo.groupId,
            mmsTable.messageInfo.isSender,
            mmsTable.messageInfo.isSendReport,
        ];
        return bascColums.concat(resultColumns);
    }

    async searchSmsMessageByContent(actionData, callback) {
        mmsLog.info(TAG + 'searchSmsMessageByContent param:' + actionData);
        let featureAbility = actionData.featureAbility;
        var dataAbilityHelper = await featureAbility.getDataAbilityHelper(
            common.string.URI_MESSAGE_LOG
        );
        var resultColumns = this.buildSearchResultColums();
        let ohosDataAbility = actionData.ohosDataAbility;
        let condition = new ohosDataAbility.DataAbilityPredicates();
        condition.like(mmsTable.messageInfo.msgContent, '%' + actionData.content + '%');
        condition.equalTo(mmsTable.messageInfo.msgType, 0);
        if (actionData.numberType != null) {
            condition.equalTo(mmsTable.messageInfo.smsType, actionData.numberType);
        }
        let resultList = [];
        let managerUri = common.string.URI_MESSAGE_LOG + common.string.URI_MESSAGE_INFO_TABLE;
        dataAbilityHelper.query(managerUri, resultColumns, condition).then(resultSet => {
            while (resultSet.goToNextRow()) {
                let result = {};
                this.dealBaseColumsData(result, resultSet);
                result.isCollect = resultSet.getString(10);
                result.sessionId = resultSet.getString(11);
                result.groupId = resultSet.getString(12);
                result.isSender = resultSet.getString(13);
                resultList.push(result);
            }
            callback(super.encapsulateReturnResult(common.int.SUCCESS, resultList));
        }).catch(error => {
            mmsLog.info(TAG + 'searchSmsMessageByContent error:' + error);
            callback(super.encapsulateReturnResult(common.int.FAILURE));
        });
    }

    buildSearchResultColums() {
        let bascColums = this.buildBaseColumns();
        var resultColumns = [
            mmsTable.messageInfo.isCollect,
            mmsTable.messageInfo.sessionId,
            mmsTable.messageInfo.groupId,
            mmsTable.messageInfo.isSender
        ];
        return bascColums.concat(resultColumns);
    }

    dealBaseColumsData(result, resultSet) {
        result.msgId = resultSet.getString(0);
        result.receiverNumber = resultSet.getString(1);
        result.senderNumber = resultSet.getString(2);
        result.startTime = resultSet.getString(3);
        result.endTime = resultSet.getString(4);
        result.msgType = resultSet.getString(5);
        result.smsType = resultSet.getString(6);
        result.msgTitle = resultSet.getString(7);
        result.msgContent = resultSet.getString(8);
        result.msgState = resultSet.getString(9);
    }

    async insertMessageDetail(actionData, callback) {
        let featureAbility = actionData.featureAbility;
        var dataAbilityHelper = await featureAbility.getDataAbilityHelper(
            common.string.URI_MESSAGE_LOG
        );
        let managerUri = common.string.URI_MESSAGE_LOG + common.string.URI_MESSAGE_INFO_TABLE;
        dataAbilityHelper.insert(managerUri, actionData.stringValue).then(data => {
            mmsLog.info(TAG + 'insertMessageDetail, success:' + data);
            callback(super.encapsulateReturnResult(common.int.SUCCESS, data));
        }).catch(error => {
            mmsLog.info(TAG + 'insertMessageDetail fail:' + error);
        });
    }

    async updateLock(actionData, callback) {
        mmsLog.info(TAG + 'updateLock , actionData = ' + actionData);
        let featureAbility = actionData.featureAbility;
        var dataAbilityHelper = await featureAbility.getDataAbilityHelper(
            common.string.URI_MESSAGE_LOG
        );
        var groupIds = this.groupIdToString(actionData.groupIds);
        let ohosDataAbility = actionData.ohosDataAbility;
        var condition = new ohosDataAbility.DataAbilityPredicates();
        condition.in(mmsTable.messageInfo.groupId, groupIds);
        var stringValue = {
            'is_lock': actionData.hasLock,
        };
        let managerUri = common.string.URI_MESSAGE_LOG + common.string.URI_MESSAGE_INFO_TABLE;
        dataAbilityHelper.update(managerUri, stringValue, condition).then((data) => {
            mmsLog.info(TAG + 'updateLock success! data = ' + data);
            callback(super.encapsulateReturnCode(common.int.SUCCESS));
        }).catch((err) => {
            mmsLog.info(TAG + 'updateLock err = ' + err);
            mmsLog.info(TAG + 'updateLock err = ' + JSON.stringify(err));
            callback(super.encapsulateReturnCode(common.int.FAILURE));
        });
    }

    groupIdToString(groupIds) {
        let ids = [];
        groupIds.forEach(item => {
            ids.push(item + '');
        });
        return ids;
    }

    async updateCollect(actionData, callback) {
        mmsLog.info(TAG + 'updateCollect , actionData = ' + actionData);
        let featureAbility = actionData.featureAbility;
        var dataAbilityHelper = await featureAbility.getDataAbilityHelper(
            common.string.URI_MESSAGE_LOG
        );
        var groupIds = this.groupIdToString(actionData.groupIds);
        let ohosDataAbility = actionData.ohosDataAbility;
        var condition = new ohosDataAbility.DataAbilityPredicates();
        condition.in(mmsTable.messageInfo.groupId, groupIds);
        var stringValue = {
            'is_collect': actionData.hasCollect,
        };
        let managerUri = common.string.URI_MESSAGE_LOG + common.string.URI_MESSAGE_INFO_TABLE;
        dataAbilityHelper.update(managerUri, stringValue, condition).then((data) => {
            mmsLog.info(TAG + 'updateCollect success! data = ' + data);
            callback(super.encapsulateReturnCode(common.int.SUCCESS));
        }).catch((err) => {
            mmsLog.info(TAG + 'updateCollect err = ' + err);
            mmsLog.info(TAG + 'updateCollect err = ' + JSON.stringify(err));
            callback(super.encapsulateReturnCode(common.int.FAILURE));
        });
    }

    async deleteMessageByIds(actionData) {
        mmsLog.info(TAG + 'deleteMessage, actionData :' + actionData);
        let featureAbility = actionData.featureAbility;
        var dataAbilityHelper = await featureAbility.getDataAbilityHelper(
            common.string.URI_MESSAGE_LOG
        );
        var msgIds = actionData.msgIds;
        let ohosDataAbility = actionData.ohosDataAbility;
        var condition = new ohosDataAbility.DataAbilityPredicates();
        condition.in(mmsTable.messageInfo.msgId, msgIds);
        let managerUri = common.string.URI_MESSAGE_LOG + common.string.URI_MESSAGE_INFO_TABLE;
        dataAbilityHelper.delete(managerUri, condition);
    }

    async deleteMessageByGroupIds(actionData) {
        mmsLog.info(TAG + 'deleteMessage by group id, actionData :' + actionData);
        let featureAbility = actionData.featureAbility;
        var dataAbilityHelper = await featureAbility.getDataAbilityHelper(
            common.string.URI_MESSAGE_LOG
        );
        var groupIds = this.groupIdToString(actionData.groupIds);
        let ohosDataAbility = actionData.ohosDataAbility;
        var condition = new ohosDataAbility.DataAbilityPredicates();
        condition.in(mmsTable.messageInfo.groupId, groupIds);
        let managerUri = common.string.URI_MESSAGE_LOG + common.string.URI_MESSAGE_INFO_TABLE;
        dataAbilityHelper.delete(managerUri, condition).then((data) => {
            mmsLog.info(TAG + 'deleteMessageByGroupIds success! data = ' + data);
        }).catch((err) => {
            mmsLog.info(TAG + 'deleteMessageByGroupIds err = ' + err);
        });
    }

    async deleteMessageBySessionIds(actionData) {
        mmsLog.info(TAG + 'deleteMessageBySessionIds, threadIds :' + actionData.threadIds);
        let featureAbility = actionData.featureAbility;
        var dataAbilityHelper = await featureAbility.getDataAbilityHelper(
            common.string.URI_MESSAGE_LOG
        );
        let threadIds = [];
        for (let id of actionData.threadIds) {
            let threadId = id + common.string.EMPTY_STR;
            threadIds.push(threadId);
        }
        let ohosDataAbility = actionData.ohosDataAbility;
        var condition = new ohosDataAbility.DataAbilityPredicates();
        condition.in(mmsTable.messageInfo.sessionId, threadIds);
        let managerUri = common.string.URI_MESSAGE_LOG + common.string.URI_MESSAGE_INFO_TABLE;
        dataAbilityHelper.delete(managerUri, condition).then((data) => {
            mmsLog.info(TAG + 'deleteMessageBySessionIds success! data = ' + data);
        }).catch((err) => {
            mmsLog.info(TAG + 'deleteMessageBySessionIds err = ' + err);
        });
    }

    async deleteMessageBySessionIdsAndLock(actionData) {
        mmsLog.info(TAG + 'deleteMessageBySessionIdsAndLock, threadIds:' + actionData);
        let featureAbility = actionData.featureAbility;
        let dataAbilityHelper = await featureAbility.getDataAbilityHelper(common.string.URI_MESSAGE_LOG);
        let threadIds = this.groupIdToString(actionData.threadIds);
        let ohosDataAbility = actionData.ohosDataAbility;
        var condition = new ohosDataAbility.DataAbilityPredicates();
        condition.equalTo(mmsTable.messageInfo.isLock, actionData.hasLock);
        condition.in(mmsTable.messageInfo.sessionId, threadIds);
        let managerUri = common.string.URI_MESSAGE_LOG + common.string.URI_MESSAGE_INFO_TABLE;
        dataAbilityHelper.delete(managerUri, condition).then((data) => {
            mmsLog.info(TAG + 'deleteMessageBySessionIdsAndLock success! data = ' + data);
        }).catch((err) => {
            mmsLog.info(TAG + 'deleteMessageBySessionIdsAndLock err = ' + err);
        });
    }

    async updateById(actionData, callback) {
        mmsLog.info(TAG + 'updateById , actionData = ' + actionData);
        let featureAbility = actionData.featureAbility;
        var dataAbilityHelper = await featureAbility.getDataAbilityHelper(
            common.string.URI_MESSAGE_LOG
        );
        var msgId = actionData.msgId;
        let ohosDataAbility = actionData.ohosDataAbility;
        var condition = new ohosDataAbility.DataAbilityPredicates();
        condition.equalTo(mmsTable.messageInfo.msgId, msgId);
        var stringValue = {
            'msg_state': actionData.sendStatus,
        };
        let managerUri = common.string.URI_MESSAGE_LOG + common.string.URI_MESSAGE_INFO_TABLE;
        dataAbilityHelper.update(managerUri, stringValue, condition).then((data) => {
            mmsLog.info(TAG + 'updateById success! data = ' + data);
            callback(super.encapsulateReturnCode(common.int.SUCCESS));
        }).catch((err) => {
            mmsLog.info(TAG + 'updateById err = ' + err);
            mmsLog.info(TAG + 'updateById err = ' + JSON.stringify(err));
            callback(super.encapsulateReturnCode(common.int.FAILURE));
        });
    }

    async markAllAsRead(actionData) {
        let featureAbility = actionData.featureAbility;
        var dataAbilityHelper = featureAbility.acquireDataAbilityHelper(common.string.URI_MESSAGE_LOG);
        let threadIds = [];
        for (let id of actionData.threadIds) {
            let threadId = id + common.string.EMPTY_STR;
            threadIds.push(threadId);
        }
        let ohosDataAbility = actionData.ohosDataAbility;
        var condition = new ohosDataAbility.DataAbilityPredicates();
        condition.in(mmsTable.messageInfo.sessionId, threadIds);
        var stringValue = {
            'is_read': actionData.hasRead
        };
        let managerUri = common.string.URI_MESSAGE_LOG + common.string.URI_MESSAGE_INFO_TABLE;
        dataAbilityHelper.update(managerUri, stringValue, condition).then((data) => {
            mmsLog.info(TAG + 'markAllAsRead success! data = ' + data);
        }).catch((err) => {
            mmsLog.info(TAG + 'markAllAsRead err = ' + err);
        });
    }

    markAllToRead(actionData) {
        let featureAbility = actionData.featureAbility;
        var dataAbilityHelper = featureAbility.acquireDataAbilityHelper(common.string.URI_MESSAGE_LOG);
        let ohosDataAbility = actionData.ohosDataAbility;
        var condition = new ohosDataAbility.DataAbilityPredicates();
        condition.equalTo(mmsTable.messageInfo.isRead, 0);
        condition.equalTo(mmsTable.messageInfo.smsType, actionData.smsType);
        var stringValue = {
            'is_read': actionData.hasRead
        };
        let managerUri = common.string.URI_MESSAGE_LOG + common.string.URI_MESSAGE_INFO_TABLE;
        dataAbilityHelper.update(managerUri, stringValue, condition).then((data) => {
            mmsLog.info(TAG + 'markAllToRead success! data = ' + data);
        }).catch((err) => {
            mmsLog.info(TAG + 'markAllToRead err = ' + err);
        });
    }

    async queryMaxGroupId(actionData, callback) {
        mmsLog.info(TAG + 'queryMaxGroupId start:' + actionData);
        let featureAbility = actionData.featureAbility;
        let dataAbilityHelper = await featureAbility.getDataAbilityHelper(
            common.string.URI_MESSAGE_LOG
        );
        let resultColumns = [
            'maxGroupId'
        ];
        let ohosDataAbility = actionData.ohosDataAbility;
        let condition = new ohosDataAbility.DataAbilityPredicates();
        let managerUri = common.string.URI_MESSAGE_LOG + common.string.URI_MESSAGE_MAX_GROUP;
        dataAbilityHelper.query(managerUri, resultColumns, condition, (err, resultSet) => {
            let result = {};
            while (resultSet.goToNextRow()) {
                result.maxGroupId = resultSet.getString(0);
                mmsLog.info(TAG + 'queryMaxGroupId result = ' + result);
            }
            callback(super.encapsulateReturnResult(common.int.SUCCESS, result));
        });
    }

    saveImage(actionData, callback) {
        var savedImageInfo = morkDataModel.saveImage();
        callback(super.encapsulateReturnResult(common.int.SUCCESS, savedImageInfo));
    }

    gotoShare(actionData, callback) {
        callback(super.encapsulateReturnCode(common.int.SUCCESS));
    }

    queryFromGallery(actionData, callback) {
        var pictureListFromGallery = morkDataModel.queryFromGallery();
        callback(super.encapsulateReturnResult(common.int.SUCCESS, pictureListFromGallery));
    }

    dealContractsTransmit(actionData, callback) {
        callback(super.encapsulateReturnCode(common.int.SUCCESS));
    }

    async queryMessageThirty(actionData, callback) {
        let timestamp = new Date().getTime();
        let lastTime = timestamp - 2592000000;
        let ohosDataAbility = actionData.ohosDataAbility;
        let featureAbility = actionData.featureAbility;
        let dataAbilityHelper = await featureAbility.getDataAbilityHelper(
            common.string.URI_MESSAGE_LOG
        );
        let resultColumns = [
            mmsTable.messageInfo.msgId,
            mmsTable.messageInfo.sessionId
        ];
        let condition = new ohosDataAbility.DataAbilityPredicates();
        condition.lessThan(mmsTable.messageInfo.endTime, lastTime);
        condition.equalTo(mmsTable.messageInfo.smsType, actionData.numberType);
        let managerUri = common.string.URI_MESSAGE_LOG + common.string.URI_MESSAGE_INFO_TABLE;
        dataAbilityHelper.query(managerUri, resultColumns, condition).then((resultSet) => {
            let mmsList = [];
            while (resultSet.goToNextRow()) {
                let item = {};
                item.msgId = resultSet.getString(0);
                item.sessionId = resultSet.getString(1);
                mmsList.push(item);
            }
            callback(super.encapsulateReturnResult(common.int.SUCCESS, mmsList));
        }).catch((err) => {
            mmsLog.info(TAG + 'queryMessageThirty err = ' + err);
            callback(super.encapsulateReturnCode(common.int.FAILURE));
        });
    }

    statisticsUnreadNotify(actionData, callback) {
        let featureAbility = actionData.featureAbility;
        var dataAbilityHelper = featureAbility.acquireDataAbilityHelper(common.string.URI_MESSAGE_LOG);
        let ohosDataAbility = actionData.ohosDataAbility;
        var condition = new ohosDataAbility.DataAbilityPredicates();
        condition.equalTo(mmsTable.messageInfo.isRead, 0);
        condition.equalTo(mmsTable.messageInfo.smsType, 1);
        let resultColumns = [
            mmsTable.messageInfo.msgId
        ];
        let managerUri = common.string.URI_MESSAGE_LOG + common.string.URI_MESSAGE_INFO_TABLE;
        dataAbilityHelper.query(managerUri, resultColumns, condition).then((resultSet) => {
            let count = 0;
            while (resultSet.goToNextRow()) {
                count++;
            }
            callback(super.encapsulateReturnResult(common.int.SUCCESS, count));
        }).catch((err) => {
            mmsLog.info(TAG + 'statisticsUnreadNotify err = ' + err);
            callback(super.encapsulateReturnCode(common.int.FAILURE));
        });
    }

    async searchMmsPartByContent(actionData, callback) {
        mmsLog.info(TAG + 'searchMmsPartByContent param:' + actionData);
        let featureAbility = actionData.featureAbility;
        var dataAbilityHelper = await featureAbility.getDataAbilityHelper(
            common.string.URI_MESSAGE_LOG
        );
        let ohosDataAbility = actionData.ohosDataAbility;
        let resultColumns = this.buildMmsPartResultColumns();
        let condition = new ohosDataAbility.DataAbilityPredicates();
        condition.like(mmsTable.mmsPart.content, '%' + actionData.content + '%');
        let managerUri = common.string.URI_MESSAGE_LOG + common.string.URI_MESSAGE_MMS_PART;
        dataAbilityHelper.query(managerUri, resultColumns, condition).then(resultSet => {
            let resultList = this.dealMmsPartResult(resultSet);
            callback(super.encapsulateReturnResult(common.int.SUCCESS, resultList));
        }).catch(error => {
            mmsLog.info(TAG + 'searchMmsPartByContent error:' + error);
            callback(super.encapsulateReturnResult(common.int.FAILURE));
        });
    }

    async queryMmsPart(actionData, callback) {
        mmsLog.log(TAG + 'queryMmsPart param:' + actionData);
        let featureAbility = actionData.featureAbility;
        let dataAbilityHelper = await featureAbility.getDataAbilityHelper(
            common.string.URI_MESSAGE_LOG
        );
        var resultColumns = this.buildMmsPartResultColumns();
        let ohosDataAbility = actionData.ohosDataAbility;
        let condition = new ohosDataAbility.DataAbilityPredicates();
        condition.in(mmsTable.mmsPart.msgId, actionData.msgIds);
        let managerUri = common.string.URI_MESSAGE_LOG + common.string.URI_MESSAGE_MMS_PART;
        dataAbilityHelper.query(managerUri, resultColumns, condition).then(resultSet => {
            let resultList = this.dealMmsPartResult(resultSet);
            callback(super.encapsulateReturnResult(common.int.SUCCESS, resultList));
        }).catch(error => {
            mmsLog.log(TAG + 'queryMmsPart error:' + error);
            callback(super.encapsulateReturnResult(common.int.FAILURE));
        });
    }

    buildMmsPartResultColumns() {
        let resultColumns = [
            mmsTable.mmsPart.msgId,
            mmsTable.mmsPart.groupId,
            mmsTable.mmsPart.type,
            mmsTable.mmsPart.locationPath,
            mmsTable.mmsPart.content,
            mmsTable.mmsPart.recordingTime,
            mmsTable.mmsPart.partSize,
            mmsTable.mmsPart.state
        ];
        return resultColumns;
    }

    dealMmsPartResult(resultSet) {
        let resultList = [];
        while (resultSet.goToNextRow()) {
            let result = {};
            result.msgId = resultSet.getString(0);
            result.groupId = resultSet.getString(1);
            result.type = resultSet.getString(2);
            result.locationPath = resultSet.getString(3);
            result.content = resultSet.getString(4);
            result.recordingTime = resultSet.getString(5);
            result.fileSize = resultSet.getString(6);
            result.messageType = resultSet.getString(7);
            resultList.push(result);
        }
        return resultList;
    }

    async deleteMmsPartByGroupIds(actionData) {
        mmsLog.info(TAG + 'deleteMmsPartByGroupIds by group id, actionData :' + actionData);
        let featureAbility = actionData.featureAbility;
        let dataAbilityHelper = await featureAbility.getDataAbilityHelper(
            common.string.URI_MESSAGE_LOG
        );
        let groupIds = this.groupIdToString(actionData.groupIds);
        let ohosDataAbility = actionData.ohosDataAbility;
        let condition = new ohosDataAbility.DataAbilityPredicates();
        condition.in(mmsTable.mmsPart.groupId, groupIds);
        let managerUri = common.string.URI_MESSAGE_LOG + common.string.URI_MESSAGE_MMS_PART;
        dataAbilityHelper.delete(managerUri, condition).then((data) => {
            mmsLog.info(TAG + 'deleteMmsPartByGroupIds success! data = ' + data);
        }).catch((err) => {
            mmsLog.info(TAG + 'deleteMmsPartByGroupIds err = ' + err);
        });
    }

    async batchInsertMmsPart(actionData, callback) {
        for (let stringValue of actionData.bacthmsParts) {
            this.insertMmsPart(actionData, stringValue, res => {
                mmsLog.info(TAG + 'batchInsertMmsPart, res:' + JSON.stringify(res));
            });
        }
        callback(super.encapsulateReturnCode(common.int.SUCCESS));
    }

    async insertMmsPart(actionData, stringValue, callback) {
        let featureAbility = actionData.featureAbility;
        let dataAbilityHelper = await featureAbility.getDataAbilityHelper(
            common.string.URI_MESSAGE_LOG
        );
        let managerUri = common.string.URI_MESSAGE_LOG + common.string.URI_MESSAGE_MMS_PART;
        dataAbilityHelper.insert(managerUri, stringValue).then(data => {
            mmsLog.info(TAG + 'insertMmsPart, success:' + data);
            callback(super.encapsulateReturnResult(data, common.int.SUCCESS));
        }).catch(error => {
            mmsLog.info(TAG + 'insertMmsPart fail:' + error);
            callback(super.encapsulateReturnCode(common.int.FAILURE));
        });
    }

    async queryMessageLockBySessionId(actionData, callback) {
        mmsLog.info(TAG + 'queryMessageLockBySessionId param:' + actionData);
        let featureAbility = actionData.featureAbility;
        let dataAbilityHelper = await featureAbility.getDataAbilityHelper(
            common.string.URI_MESSAGE_LOG
        );
        var resultColumns = [mmsTable.messageInfo.isLock];
        let ohosDataAbility = actionData.ohosDataAbility;
        let condition = new ohosDataAbility.DataAbilityPredicates();
        let sessionId = actionData.threadId + common.string.EMPTY_STR;
        condition.equalTo(mmsTable.messageInfo.sessionId, sessionId);
        let managerUri = common.string.URI_MESSAGE_LOG + common.string.URI_MESSAGE_INFO_TABLE;
        dataAbilityHelper.query(managerUri, resultColumns, condition).then(resultSet => {
            let lockStatus = [];
            while (resultSet.goToNextRow()) {
                let result = {};
                result.isLock = resultSet.getString(0);
                lockStatus.push(result);
            }
            callback(super.encapsulateReturnResult(common.int.SUCCESS, lockStatus));
        }).catch(error => {
            mmsLog.info(TAG + 'queryMessageLockBySessionId error:' + error);
            callback(super.encapsulateReturnResult(common.int.FAILURE));
        });
    }

    async queryGroupIdBySessionId(actionData, callback) {
        mmsLog.info(TAG + 'queryGroupIdBySessionId param:' + actionData);
        let featureAbility = actionData.featureAbility;
        let dataAbilityHelper = await featureAbility.getDataAbilityHelper(
            common.string.URI_MESSAGE_LOG
        );
        var resultColumns = [mmsTable.messageInfo.groupId];
        let ohosDataAbility = actionData.ohosDataAbility;
        let condition = new ohosDataAbility.DataAbilityPredicates();
        let threadIds = this.groupIdToString(actionData.threadIds);
        condition.in(mmsTable.messageInfo.sessionId, threadIds);
        let managerUri = common.string.URI_MESSAGE_LOG + common.string.URI_MESSAGE_INFO_TABLE;
        dataAbilityHelper.query(managerUri, resultColumns, condition).then(resultSet => {
            let groupIds = [];
            resultSet.goToFirstRow();
            do {
                let groupId = resultSet.getString(0);
                groupIds.push(groupId);
            } while (resultSet.goToNextRow());
            callback(super.encapsulateReturnResult(common.int.SUCCESS, groupIds));
        }).catch(error => {
            mmsLog.info(TAG + 'queryGroupIdBySessionId error:' + error);
            callback(super.encapsulateReturnResult(common.int.FAILURE));
        });
    }
}