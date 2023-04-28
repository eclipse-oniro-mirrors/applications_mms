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
import MorkDataModel from "./MorkDataModel";
import common from "../data/commonData";
import mmsTable from "../data/tableData";
import HiLog from "../utils/HiLog"
import LooseObject from "../data/LooseObject"
import dataShare from "@ohos.data.dataShare";
import dataSharePredicates from "@ohos.data.dataSharePredicates";
import featureAbility from "@ohos.ability.featureAbility";
import dataAbility from "@ohos.data.dataAbility";

const TAG = "ConversationModel";

let morkDataModel = new MorkDataModel();

export default class ConversationModel extends BaseModel {
    async queryMessageDetail(actionData, callback) {
        let dataAbilityHelper = await featureAbility.acquireDataAbilityHelper(globalThis.mmsContext, common.string.URI_MESSAGE_LOG);
        var resultColumns = this.buildResultColumns();
        let condition = this.buildQueryCondition(actionData);
        let managerUri = common.string.URI_MESSAGE_LOG + common.string.URI_MESSAGE_INFO_TABLE;
        dataAbilityHelper.query(managerUri, resultColumns, condition).then(resultSet => {
            let resultList = [];
            if( !resultSet.goToFirstRow() ) {
                callback(this.encapsulateReturnResult(common.int.SUCCESS, resultList));
                return;
            }
            if (resultSet != undefined) {
                do {
                    let result: LooseObject = {};
                    this.dealBaseColumnsData(result, resultSet);
                    result.operatorServiceNumber = resultSet.getString(resultSet.getColumnIndex("operator_service_number"));
                    result.msgCode = resultSet.getString(resultSet.getColumnIndex("msg_code"));
                    result.isLock = resultSet.getString(resultSet.getColumnIndex("is_lock"));
                    result.isRead = resultSet.getString(resultSet.getColumnIndex("is_read"));
                    result.isCollect = resultSet.getString(resultSet.getColumnIndex("is_collect"));
                    result.sessionType = resultSet.getString(resultSet.getColumnIndex("session_type"));
                    result.retryNumber = resultSet.getString(resultSet.getColumnIndex("retry_number"));
                    result.isSubsection = resultSet.getString(resultSet.getColumnIndex("is_subsection"));
                    result.sessionId = resultSet.getString(resultSet.getColumnIndex("session_id"));
                    result.groupId = resultSet.getString(resultSet.getColumnIndex("group_id"));
                    result.isSender = resultSet.getString(resultSet.getColumnIndex("is_sender"));
                    result.isSendReport = resultSet.getString(resultSet.getColumnIndex("is_send_report"));
                    resultList.push(result);
                } while (resultSet.goToNextRow())
            }
            callback(this.encapsulateReturnResult(common.int.SUCCESS, resultList));
        }).catch(error => {
            HiLog.e(TAG, "queryMessageDetail, error: " + JSON.stringify(error.message));
            callback(this.encapsulateReturnCode(common.int.FAILURE));
        });
    }

    buildQueryCondition(actionData) {
        let condition = new dataAbility.DataAbilityPredicates();
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
            mmsTable.messageInfo.slotId,
            // Recipient Mobile Number
            mmsTable.messageInfo.receiverNumber,
            mmsTable.messageInfo.senderNumber,
            mmsTable.messageInfo.startTime,
            mmsTable.messageInfo.endTime,
            mmsTable.messageInfo.msgType,
            // sms = 0,mms,
            mmsTable.messageInfo.smsType,
            // 0: normal; 1: notification
            mmsTable.messageInfo.msgTitle,
            mmsTable.messageInfo.msgContent,
            mmsTable.messageInfo.msgState
        ];
        return resultColumns;
    }

    buildResultColumns() {
        let basicColumns = this.buildBaseColumns();
        var resultColumns = [
            mmsTable.messageInfo.operatorServiceNumber,
            mmsTable.messageInfo.msgCode,
            mmsTable.messageInfo.isLock,
            mmsTable.messageInfo.isRead,
            mmsTable.messageInfo.isCollect,
            mmsTable.messageInfo.sessionType,
            // 0: common; 1: broadcast; 2: group-send
            mmsTable.messageInfo.retryNumber,
            // Number of resending times
            mmsTable.messageInfo.isSubsection,
            mmsTable.messageInfo.sessionId,
            mmsTable.messageInfo.groupId,
            mmsTable.messageInfo.isSender,
            mmsTable.messageInfo.isSendReport,
        ];
        return basicColumns.concat(resultColumns);
    }

    async searchSmsMessageByContent(actionData, callback) {
        let dataAbilityHelper = await featureAbility.acquireDataAbilityHelper(globalThis.mmsContext, common.string.URI_MESSAGE_LOG);
        var resultColumns = this.buildSearchResultColumns();
        let condition = new dataAbility.DataAbilityPredicates();
        condition.like(mmsTable.messageInfo.msgContent, "%" + actionData.content + "%");
        condition.equalTo(mmsTable.messageInfo.msgType, 0);
        if (actionData.numberType != null) {
            condition.equalTo(mmsTable.messageInfo.smsType, actionData.numberType);
        }
        let resultList = [];
        let managerUri = common.string.URI_MESSAGE_LOG + common.string.URI_MESSAGE_INFO_TABLE;
        dataAbilityHelper.query(managerUri, resultColumns, condition).then(resultSet => {
            if (resultSet != undefined) {
                while (resultSet.goToNextRow()) {
                    let result: LooseObject = {};
                    this.dealBaseColumnsData(result, resultSet);
                    result.isCollect = resultSet.getString(resultSet.getColumnIndex("is_collect"));
                    result.sessionId = resultSet.getString(resultSet.getColumnIndex("session_id"));
                    result.groupId = resultSet.getString(resultSet.getColumnIndex("group_id"));
                    result.isSender = resultSet.getString(resultSet.getColumnIndex("is_sender"));
                    resultList.push(result);
                }
            }
            callback(this.encapsulateReturnResult(common.int.SUCCESS, resultList));
        }).catch(error => {
            HiLog.e(TAG, "searchSmsMessageByContent, error: " + JSON.stringify(error.message));
            callback(this.encapsulateReturnCode(common.int.FAILURE));
        });
    }

    buildSearchResultColumns() {
        let basicColumns = this.buildBaseColumns();
        var resultColumns = [
            mmsTable.messageInfo.isCollect,
            mmsTable.messageInfo.sessionId,
            mmsTable.messageInfo.groupId,
            mmsTable.messageInfo.isSender
        ];
        return basicColumns.concat(resultColumns);
    }

    dealBaseColumnsData(result, resultSet) {
        result.msgId = resultSet.getString(resultSet.getColumnIndex("msg_id"));
        result.slotId = resultSet.getString(resultSet.getColumnIndex("slot_id"));
        result.receiverNumber = resultSet.getString(resultSet.getColumnIndex("receiver_number"));
        result.senderNumber = resultSet.getString(resultSet.getColumnIndex("sender_number"));
        result.startTime = resultSet.getString(resultSet.getColumnIndex("start_time"));
        result.endTime = resultSet.getString(resultSet.getColumnIndex("end_time"));
        result.msgType = resultSet.getString(resultSet.getColumnIndex("msg_type"));
        result.smsType = resultSet.getString(resultSet.getColumnIndex("sms_type"));
        result.msgTitle = resultSet.getString(resultSet.getColumnIndex("msg_title"));
        result.msgContent = resultSet.getString(resultSet.getColumnIndex("msg_content"));
        result.msgState = resultSet.getString(resultSet.getColumnIndex("msg_state"));
    }

    async insertMessageDetail(actionData, callback) {
        HiLog.i(TAG, "insertMessageDetail, start")
        //TODO
        let dataAbilityHelper = await featureAbility.acquireDataAbilityHelper(globalThis.mmsContext, common.string.URI_MESSAGE_LOG);
        let managerUri = common.string.URI_MESSAGE_LOG + common.string.URI_MESSAGE_INFO_TABLE;
        dataAbilityHelper.insert(managerUri, actionData.stringValue).then(data => {
            callback(this.encapsulateReturnResult(common.int.SUCCESS, data));
        }).catch(error => {
            HiLog.e(TAG, "insertMessageDetail, fail: " + JSON.stringify(error.message));
            callback(this.encapsulateReturnCode(common.int.FAILURE));
        });
    }

    async updateLock(actionData, callback) {
        let dataAbilityHelper = await featureAbility.acquireDataAbilityHelper(globalThis.mmsContext, common.string.URI_MESSAGE_LOG);
        var groupIds = this.groupIdToString(actionData.groupIds);
        var condition = new dataAbility.DataAbilityPredicates();
        condition.in(mmsTable.messageInfo.groupId, groupIds);
        var stringValue = {
            "is_lock": actionData.hasLock,
        };
        let managerUri = common.string.URI_MESSAGE_LOG + common.string.URI_MESSAGE_INFO_TABLE;
        dataAbilityHelper.update(managerUri, stringValue, condition).then((data) => {
            callback(this.encapsulateReturnCode(common.int.SUCCESS));
        }).catch((err) => {
            HiLog.e(TAG, "updateLock, err: " + JSON.stringify(err.message));
            callback(this.encapsulateReturnCode(common.int.FAILURE));
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
        let dataAbilityHelper = await featureAbility.acquireDataAbilityHelper(globalThis.mmsContext, common.string.URI_MESSAGE_LOG);
        var groupIds = this.groupIdToString(actionData.groupIds);
        var condition = new dataAbility.DataAbilityPredicates();
        condition.in(mmsTable.messageInfo.groupId, groupIds);
        var stringValue = {
            "is_collect": actionData.hasCollect,
        };
        let managerUri = common.string.URI_MESSAGE_LOG + common.string.URI_MESSAGE_INFO_TABLE;
        dataAbilityHelper.update(managerUri, stringValue, condition).then((data) => {
            callback(this.encapsulateReturnCode(common.int.SUCCESS));
        }).catch((err) => {
            HiLog.e(TAG, "updateCollect, err: " + JSON.stringify(err.message));
            callback(this.encapsulateReturnCode(common.int.FAILURE));
        });
    }

    async deleteMessageByIds(actionData) {
        let dataAbilityHelper = await featureAbility.acquireDataAbilityHelper(globalThis.mmsContext, common.string.URI_MESSAGE_LOG);
        var msgIds = actionData.msgIds;
        let condition = new dataAbility.DataAbilityPredicates();
        condition.in(mmsTable.messageInfo.msgId, msgIds);
        let managerUri = common.string.URI_MESSAGE_LOG + common.string.URI_MESSAGE_INFO_TABLE;
        dataAbilityHelper.delete(managerUri, condition);
    }

    async deleteMessageByGroupIds(actionData) {
        let dataAbilityHelper = await featureAbility.acquireDataAbilityHelper(globalThis.mmsContext, common.string.URI_MESSAGE_LOG);
        var groupIds = this.groupIdToString(actionData.groupIds);
        let condition = new dataAbility.DataAbilityPredicates();
        condition.in(mmsTable.messageInfo.groupId, groupIds);
        let managerUri = common.string.URI_MESSAGE_LOG + common.string.URI_MESSAGE_INFO_TABLE;
        dataAbilityHelper.delete(managerUri, condition).then((data) => {
//            callback(this.encapsulateReturnCode(common.int.SUCCESS));
        }).catch((err) => {
            HiLog.e(TAG, "deleteMessageByGroupIds, err: " + JSON.stringify(err.message));
//            callback(this.encapsulateReturnCode(common.int.FAILURE));
        });
    }

    async deleteMessageBySessionIds(actionData) {
        let dataAbilityHelper = await featureAbility.acquireDataAbilityHelper(globalThis.mmsContext, common.string.URI_MESSAGE_LOG);
        let threadIds = [];
        for (let id of actionData.threadIds) {
            let threadId = id + common.string.EMPTY_STR;
            threadIds.push(threadId);
        }
        let condition = new dataAbility.DataAbilityPredicates();
        condition.in(mmsTable.messageInfo.sessionId, threadIds);
        let managerUri = common.string.URI_MESSAGE_LOG + common.string.URI_MESSAGE_INFO_TABLE;
        dataAbilityHelper.delete(managerUri, condition).then((data) => {
//            callback(this.encapsulateReturnCode(common.int.SUCCESS));
        }).catch((err) => {
            HiLog.e(TAG, "deleteMessageBySessionIds, err: " + JSON.stringify(err.message));
//            callback(this.encapsulateReturnCode(common.int.FAILURE));
        });
    }

    async deleteMessageBySessionIdsAndLock(actionData) {
        let dataAbilityHelper = await featureAbility.acquireDataAbilityHelper(globalThis.mmsContext, common.string.URI_MESSAGE_LOG);
        let threadIds = this.groupIdToString(actionData.threadIds);
        let condition = new dataAbility.DataAbilityPredicates();
        condition.equalTo(mmsTable.messageInfo.isLock, actionData.hasLock);
        condition.in(mmsTable.messageInfo.sessionId, threadIds);
        let managerUri = common.string.URI_MESSAGE_LOG + common.string.URI_MESSAGE_INFO_TABLE;
        dataAbilityHelper.delete(managerUri, condition).then((data) => {
//            callback(this.encapsulateReturnCode(common.int.SUCCESS));
        }).catch((err) => {
            HiLog.e(TAG, "deleteMessageBySessionIdsAndLock, err: " + JSON.stringify(err.message));
//            callback(this.encapsulateReturnCode(common.int.FAILURE));
        });
    }

    async updateById(actionData, callback) {
        let dataAbilityHelper = await featureAbility.acquireDataAbilityHelper(globalThis.mmsContext, common.string.URI_MESSAGE_LOG);
        var msgId = actionData.msgId;
        let condition = new dataAbility.DataAbilityPredicates();
        condition.equalTo(mmsTable.messageInfo.msgId, msgId);
        var stringValue = {
            "msg_state": actionData.sendStatus,
        };
        let managerUri = common.string.URI_MESSAGE_LOG + common.string.URI_MESSAGE_INFO_TABLE;
        dataAbilityHelper.update(managerUri, stringValue, condition).then((data) => {
            HiLog.i(TAG, "updateById, end");
            callback(this.encapsulateReturnCode(common.int.SUCCESS));
        }).catch((err) => {
            HiLog.e(TAG, "updateById, err: " + JSON.stringify(err.message));
            callback(this.encapsulateReturnCode(common.int.FAILURE));
        });
    }

    async markAllAsRead(actionData) {
        let dataAbilityHelper = await featureAbility.acquireDataAbilityHelper(globalThis.mmsContext, common.string.URI_MESSAGE_LOG);
        let threadIds = [];
        for (let id of actionData.threadIds) {
            let threadId = id + common.string.EMPTY_STR;
            threadIds.push(threadId);
        }
        let condition = new dataAbility.DataAbilityPredicates();
        condition.in(mmsTable.messageInfo.sessionId, threadIds);
        var stringValue = {
            "is_read": actionData.hasRead
        };
        let managerUri = common.string.URI_MESSAGE_LOG + common.string.URI_MESSAGE_INFO_TABLE;
        dataAbilityHelper.update(managerUri, stringValue, condition).then((data) => {
//            callback(this.encapsulateReturnCode(common.int.SUCCESS));
        }).catch((err) => {
            HiLog.e(TAG, "markAllAsRead, err: " + JSON.stringify(err.message));
//            callback(this.encapsulateReturnCode(common.int.FAILURE));
        });
    }

    async markAllToRead(actionData) {
        let dataAbilityHelper = await featureAbility.acquireDataAbilityHelper(globalThis.mmsContext, common.string.URI_MESSAGE_LOG);
        let condition = new dataAbility.DataAbilityPredicates();
        condition.equalTo(mmsTable.messageInfo.isRead, 0);
        condition.equalTo(mmsTable.messageInfo.smsType, actionData.smsType);
        var stringValue = {
            "is_read": actionData.hasRead
        };
        let managerUri = common.string.URI_MESSAGE_LOG + common.string.URI_MESSAGE_INFO_TABLE;
        dataAbilityHelper.update(managerUri, stringValue, condition).then((data) => {
//            callback(this.encapsulateReturnCode(common.int.SUCCESS));
        }).catch((err) => {
            HiLog.e(TAG, "markAllToRead, err: " + JSON.stringify(err.message));
//            callback(this.encapsulateReturnCode(common.int.FAILURE));
        });
    }

    async queryMaxGroupId(actionData, callback) {
        let dataAbilityHelper = await featureAbility.acquireDataAbilityHelper(globalThis.mmsContext, common.string.URI_MESSAGE_LOG);
        let resultColumns = [
            "maxGroupId"
        ];
        let condition = new dataAbility.DataAbilityPredicates();
        let managerUri = common.string.URI_MESSAGE_LOG + common.string.URI_MESSAGE_MAX_GROUP;
        dataAbilityHelper.query(managerUri, resultColumns, condition, (err, resultSet) => {
            HiLog.i(TAG, "queryMaxGroupId, query callback");
            let result: LooseObject = {};
            if (resultSet != undefined) {
                if (resultSet.goToLastRow()) {
                    result.maxGroupId = resultSet.getString(0);
                    HiLog.d(TAG, "queryMaxGroupId, maxGroupId=" + result.maxGroupId);
                }
            }
            callback(this.encapsulateReturnResult(common.int.SUCCESS, result));
        });
    }

    saveImage(actionData, callback) {
        var savedImageInfo = morkDataModel.saveImage();
        callback(this.encapsulateReturnResult(common.int.SUCCESS, savedImageInfo));
    }

    gotoShare(actionData, callback) {
        callback(this.encapsulateReturnCode(common.int.SUCCESS));
    }

    queryFromGallery(actionData, callback) {
        var pictureListFromGallery = morkDataModel.queryFromGallery();
        callback(this.encapsulateReturnResult(common.int.SUCCESS, pictureListFromGallery));
    }

    dealContractsTransmit(actionData, callback) {
        callback(this.encapsulateReturnCode(common.int.SUCCESS));
    }

    async queryMessageThirty(actionData, callback) {
        let dataAbilityHelper = await featureAbility.acquireDataAbilityHelper(globalThis.mmsContext, common.string.URI_MESSAGE_LOG);
        let timestamp = new Date().getTime();
        let lastTime = timestamp - 2592000000;
        let resultColumns = [
            mmsTable.messageInfo.msgId,
            mmsTable.messageInfo.sessionId
        ];
        let condition = new dataAbility.DataAbilityPredicates();
        condition.lessThan(mmsTable.messageInfo.endTime, lastTime);
        condition.equalTo(mmsTable.messageInfo.smsType, actionData.numberType);
        let managerUri = common.string.URI_MESSAGE_LOG + common.string.URI_MESSAGE_INFO_TABLE;
        dataAbilityHelper.query(managerUri, resultColumns, condition).then((resultSet) => {
            let mmsList = [];
            if (resultSet != undefined) {
                while (resultSet.goToNextRow()) {
                    let item: LooseObject = {};
                    item.msgId = resultSet.getString(0);
                    item.sessionId = resultSet.getString(1);
                    mmsList.push(item);
                }
            }
            callback(this.encapsulateReturnResult(common.int.SUCCESS, mmsList));
        }).catch((err) => {
            HiLog.e(TAG, "queryMessageThirty, err: " + JSON.stringify(err.message));
            callback(this.encapsulateReturnCode(common.int.FAILURE));
        });
    }

    async statisticsUnreadNotify(actionData, callback) {
        let mmsContext;
        if (actionData.mmsContext) {
            mmsContext = actionData.mmsContext;
        } else {
            mmsContext = globalThis.mmsContext;
        }
        let dataAbilityHelper = await featureAbility.acquireDataAbilityHelper(mmsContext, common.string.URI_MESSAGE_LOG);
        let condition = new dataAbility.DataAbilityPredicates();
        condition.equalTo(mmsTable.messageInfo.isRead, 0);
        condition.equalTo(mmsTable.messageInfo.smsType, 1);
        let resultColumns = [
            mmsTable.messageInfo.msgId
        ];
        let managerUri = common.string.URI_MESSAGE_LOG + common.string.URI_MESSAGE_INFO_TABLE;
        dataAbilityHelper.query(managerUri, resultColumns, condition).then((resultSet) => {
            let count = 0;
            if (resultSet != undefined) {
                count = resultSet.rowCount;
            }
            callback(this.encapsulateReturnResult(common.int.SUCCESS, count));
        }).catch((err) => {
            HiLog.e(TAG, "statisticsUnreadNotify, err: " + JSON.stringify(err.message));
            callback(this.encapsulateReturnCode(common.int.FAILURE));
        });
    }

    async searchMmsPartByContent(actionData, callback) {
        let dataAbilityHelper = await featureAbility.acquireDataAbilityHelper(globalThis.mmsContext, common.string.URI_MESSAGE_LOG);
        let resultColumns = this.buildMmsPartResultColumns();
        let condition = new dataAbility.DataAbilityPredicates();
        condition.like(mmsTable.mmsPart.content, "%" + actionData.content + "%");
        let managerUri = common.string.URI_MESSAGE_LOG + common.string.URI_MESSAGE_MMS_PART;
        dataAbilityHelper.query(managerUri, resultColumns, condition).then(resultSet => {
            let resultList = this.dealMmsPartResult(resultSet);
            callback(this.encapsulateReturnResult(common.int.SUCCESS, resultList));
        }).catch(error => {
            HiLog.e(TAG, "searchMmsPartByContent, error: " + JSON.stringify(error.message));
            callback(this.encapsulateReturnCode(common.int.FAILURE));
        });
    }

    async queryMmsPart(actionData, callback) {
        let dataAbilityHelper = await featureAbility.acquireDataAbilityHelper(globalThis.mmsContext, common.string.URI_MESSAGE_LOG);
        var resultColumns = this.buildMmsPartResultColumns();
        let condition = new dataAbility.DataAbilityPredicates();
        condition.in(mmsTable.mmsPart.msgId, actionData.msgIds);
        let managerUri = common.string.URI_MESSAGE_LOG + common.string.URI_MESSAGE_MMS_PART;
        dataAbilityHelper.query(managerUri, resultColumns, condition).then(resultSet => {
            let resultList = this.dealMmsPartResult(resultSet);
            callback(this.encapsulateReturnResult(common.int.SUCCESS, resultList));
        }).catch(error => {
            HiLog.e(TAG, "queryMmsPart, error: " + JSON.stringify(error.message));
            callback(this.encapsulateReturnCode(common.int.FAILURE));
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
        if (resultSet != undefined) {
            while (resultSet.goToNextRow()) {
                let result: LooseObject = {};
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
        }
        return resultList;
    }

    async deleteMmsPartByGroupIds(actionData) {
        let dataAbilityHelper = await featureAbility.acquireDataAbilityHelper(globalThis.mmsContext, common.string.URI_MESSAGE_LOG);
        let groupIds = this.groupIdToString(actionData.groupIds);
        let condition = new dataAbility.DataAbilityPredicates();
        condition.in(mmsTable.mmsPart.groupId, groupIds);
        let managerUri = common.string.URI_MESSAGE_LOG + common.string.URI_MESSAGE_MMS_PART;
        dataAbilityHelper.delete(managerUri, condition).then((data) => {
//            callback(this.encapsulateReturnCode(common.int.SUCCESS));
        }).catch((err) => {
            HiLog.e(TAG, "deleteMmsPartByGroupIds, err: " + JSON.stringify(err.message));
//            callback(this.encapsulateReturnCode(common.int.FAILURE));
        });
    }

    async batchInsertMmsPart(actionData, callback) {
        for (let stringValue of actionData.batchMmsParts) {
            this.insertMmsPart(actionData, stringValue, res => {
            });
        }
        callback(this.encapsulateReturnCode(common.int.SUCCESS));
    }

    async insertMmsPart(actionData, stringValue, callback) {
        let dataAbilityHelper = await featureAbility.acquireDataAbilityHelper(globalThis.mmsContext, common.string.URI_MESSAGE_LOG);
        let managerUri = common.string.URI_MESSAGE_LOG + common.string.URI_MESSAGE_MMS_PART;
        dataAbilityHelper.insert(managerUri, stringValue).then(data => {
            callback(this.encapsulateReturnResult(data, common.int.SUCCESS));
        }).catch(error => {
            HiLog.e(TAG, "insertMmsPart, error: " + JSON.stringify(error.message));
            callback(this.encapsulateReturnCode(common.int.FAILURE));
        });
    }

    async queryMessageLockBySessionId(actionData, callback) {
        let dataAbilityHelper = await featureAbility.acquireDataAbilityHelper(globalThis.mmsContext, common.string.URI_MESSAGE_LOG);
        var resultColumns = [mmsTable.messageInfo.isLock];
        let condition = new dataAbility.DataAbilityPredicates();
        let sessionId = actionData.threadId + common.string.EMPTY_STR;
        condition.equalTo(mmsTable.messageInfo.sessionId, sessionId);
        let managerUri = common.string.URI_MESSAGE_LOG + common.string.URI_MESSAGE_INFO_TABLE;
        dataAbilityHelper.query(managerUri, resultColumns, condition).then(resultSet => {
            let lockStatus = [];
            if (resultSet != undefined) {
                while (resultSet.goToNextRow()) {
                    let result: LooseObject = {};
                    result.isLock = resultSet.getString(0);
                    lockStatus.push(result);
                }
            }
            callback(this.encapsulateReturnResult(common.int.SUCCESS, lockStatus));
        }).catch(error => {
            HiLog.e(TAG, "queryMessageLockBySessionId, error: " + JSON.stringify(error.message));
            callback(this.encapsulateReturnCode(common.int.FAILURE));
        });
    }

    async queryGroupIdBySessionId(actionData, callback) {
        let dataAbilityHelper = await featureAbility.acquireDataAbilityHelper(globalThis.mmsContext, common.string.URI_MESSAGE_LOG);
        var resultColumns = [mmsTable.messageInfo.groupId];
        let condition = new dataAbility.DataAbilityPredicates();
        let threadIds = this.groupIdToString(actionData.threadIds);
        condition.in(mmsTable.messageInfo.sessionId, threadIds);
        let managerUri = common.string.URI_MESSAGE_LOG + common.string.URI_MESSAGE_INFO_TABLE;
        dataAbilityHelper.query(managerUri, resultColumns, condition).then(resultSet => {
            let groupIds = [];
            if (resultSet != undefined) {
                resultSet.goToFirstRow();
                do {
                    let groupId = resultSet.getString(0);
                    groupIds.push(groupId);
                } while (resultSet.goToNextRow());
            }
            callback(this.encapsulateReturnResult(common.int.SUCCESS, groupIds));
        }).catch(error => {
            HiLog.e(TAG, "queryGroupIdBySessionId, error: " + JSON.stringify(error.message));
            callback(this.encapsulateReturnCode(common.int.FAILURE));
        });
    }
}