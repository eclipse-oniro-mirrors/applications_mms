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

import commonEvent from '@ohos.commonEvent';
import common from '../default/data/commonData';
import mmsTable from '../default/data/tableData';
import telephoneUtils from '../default/utils/TelephoneUtil';
import HiLog from '../default/utils/HiLog';
import particleAbility from '@ohos.ability.particleAbility';
import ohosDataAbility from '@ohos.data.dataAbility';
import telSim from '@ohos.telephony.sms';
import ohosDataRdb from '@ohos.data.rdb';
import commonService from '../default/service/CommonService';
import http from '@ohos.net.http';
import notificationService from '../default/service/NotificationService';
import LooseObject from '../default/data/LooseObject'

// 数据库实例对象
var rdbStore = undefined;

const TAG = 'MmsManagerService'

let commonEventData = null;

export default class MmsManagerService {
    constructor() {
        this.addSubscriberListener();
        // 初始化数据库
        this.initRdb();
    }

    /**
     * add mms app subscriber
     */
    async addSubscriberListener() {
        let events = [common.string.SUBSCRIBER_EVENT, common.string.MMS_SUBSCRIBER_EVENT];
        let commonEventSubscribeInfo = {
            events: events
        };
        // 创建订阅信息
        commonEvent.createSubscriber(commonEventSubscribeInfo, this.createSubscriberCallBack.bind(this));
    }

    createSubscriberCallBack(err, data) {
        commonEventData = data;
        // 接收到订阅
        commonEvent.subscribe(commonEventData, this.subscriberCallBack.bind(this));
    }

    subscriberCallBack(err, data) {
        HiLog.i(TAG, 'subscriberCallBack, err: ' + JSON.stringify(err.message));
        // 短信接收
        if (data.event === common.string.SUBSCRIBER_EVENT) {
            this.dealSmsReceiveData(data);
        } else {
            // 彩信接收
            this.dealMmsReceiveData(data);
        }
    }

    async dealSmsReceiveData(data) {
        let netType = data.parameters.isCdma ? '3gpp2' : '3gpp';
        // 同步等待操作
        let promisesAll = [];
        data.parameters.pdus.forEach(pdu => {
            let promise = telSim.createMessage(this.convertStrArray(pdu), netType);
            promisesAll.push(promise);
        });

        let result: LooseObject = {};
        let createMessagePromise = Promise.all(promisesAll)
        createMessagePromise.then((shortMsgList) => {
            result.code = common.int.SUCCESS;
            result.telephone = telephoneUtils.formatTelephone(shortMsgList[0].visibleRawAddress);
            result.content = '';
            shortMsgList.forEach(shortMessage => {
                result.content += shortMessage.visibleMessageBody;
            })
        }).catch((err) => {
            HiLog.e(TAG, 'dealSmsReceiveData, err: ' + JSON.stringify(err.message));
            result.code = common.int.FAILURE;
        });
        await createMessagePromise;
        let actionData = {
            telephone: result.telephone,
            content: result.content,
            isMms: false,
            mmsSource: []
        }
        this.insertMessageDetailBy(actionData, res => {
            this.sendNotification(result.telephone, res.initDatas[0].id, result.content);
            this.publishData(result.telephone, result.content);
        });
    }

    dealMmsReceiveData(data) {
        let result = JSON.parse(data.data);
        this.saveAttachment(result.mmsSource);
        let content = commonService.getMmsContent(result.mmsSource);
        let actionData: LooseObject = {};
        actionData.telephone = result.telephone;
        actionData.content = content;
        actionData.isMms = true;
        actionData.mmsSource = result.mmsSource;
        this.insertMessageDetailBy(actionData, res => {
            let notificationContent = this.getNotificationContent(result.mmsSource, content);
            this.sendNotification(result.telephone, res.initDatas[0].id, notificationContent);
            this.publishData(result.telephone, result.content);
        });
    }

    saveAttachment(mmsSource) {
        for (let item of mmsSource) {
            let baseUrl = item.msgUriPath;
            let httpRequest = http.createHttp();
            httpRequest.request(common.string.MMS_URL,
                {
                    method: http.RequestMethod.GET,
                    header: {
                        'Content-Type': 'application/json',
                    },
                    extraData: baseUrl,
                    readTimeout: 50000,
                    connectTimeout: 50000
                }, (err, data) => {
                    HiLog.i(TAG, 'saveAttachment, err: ' + JSON.stringify(err.message));
                }
            );
        }
    }

    getNotificationContent(mmsSource, themeContent) {
        let content = common.string.EMPTY_STR;
        if (mmsSource.length === 1) {
            let item = mmsSource[0];
            switch (item.msgType) {
            // 主题
                case 0:
                    content = themeContent;
                    break;
            // 图片
                case 1:
                    content = '(picture)' + themeContent;
                    break;
            // 视频
                case 2:
                    content = '(video)' + themeContent;
                    break;
            // 音频
                case 3:
                    content = '(audio)' + themeContent;
                    break;
            }
        } else {
            content = '(slide)' +  mmsSource[0].content;
        }
        return content;
    }

    // 插入接收到的数据
    insertMessageDetailBy(param, callback) {
        let sendResults = [];
        let sendResult = {
            telephone: param.telephone,
            content: param.content,
            sendStatus: 0
        }
        sendResults.push(sendResult);
        let hasAttachment = commonService.judgeIsAttachment(param.mmsSource);
        let actionData: LooseObject = {};
        actionData.sendResults = sendResults;
        actionData.isReceive = true;
        actionData.ownNumber = common.string.EMPTY_STR;
        actionData.isSender = true;
        actionData.isMms = param.isMms;
        actionData.mmsSource = param.mmsSource;
        actionData.hasAttachment = hasAttachment;
        this.insertSessionAndDetail(actionData, callback);
    }

    convertStrArray(sourceStr) {
        let wby = sourceStr;
        let length = wby.length;
        let isDouble = (length % 2) == 0;
        let halfSize = parseInt('' + length / 2);
        HiLog.i(TAG, 'convertStrArray, length=' + length + ', isDouble=' + isDouble);
        if (isDouble) {
            let number0xArray = new Array(halfSize);
            for (let i = 0;i < halfSize; i++) {
                number0xArray[i] = '0x' + wby.substr(i * 2, 2);
            }
            let numberArray = new Array(halfSize);
            for (let i = 0;i < halfSize; i++) {
                numberArray[i] = parseInt(number0xArray[i], 16);
            }
            return numberArray;
        } else {
            let number0xArray = new Array(halfSize + 1);
            for (let i = 0;i < halfSize; i++) {
                number0xArray[i] = '0x' + wby.substr(i * 2, 2);
            }
            number0xArray[halfSize] = '0x' + wby.substr((halfSize * 2) + 1, 1);
            let numberArray = new Array(halfSize + 1);
            for (let i = 0;i < halfSize; i++) {
                numberArray[i] = parseInt(number0xArray[i], 16);
            }
            let last0x = '0x' + wby.substr(wby.length - 1, 1);
            numberArray[halfSize] = parseInt(last0x);
            return numberArray;
        }
    }

    // 取消订阅
    unsubscribe() {
        commonEvent.unsubscribe(commonEventData, () => {
            HiLog.i(TAG, 'unsubscribe success');
        });
    }

    // 初始化数据库
    async initRdb() {
        // 创建数据库表
        this.createRdbStore().then(async (ret) => {
            HiLog.i(TAG, 'initRdb, createRdbStore first done: ' + ret);
            await this.createTable(mmsTable.table.session);
        }).catch((err) => {
            HiLog.e(TAG, 'initRdb, createRdbStore error: ' + JSON.stringify(err.message));
        });
    }

    /**
     * 创建数据库
     */
    async createRdbStore() {
        HiLog.i(TAG, 'createRdbStore start');
        rdbStore = await ohosDataRdb.getRdbStore(mmsTable.DB.MMSSMS.config, mmsTable.DB.MMSSMS.version);
        HiLog.i(TAG, 'createRdbStore end');
    }

    /**
     * 创建数据库表
     */
    async createTable(table) {
        await rdbStore.executeSql(table, null);
    }

    insertSessionAndDetail(actionData, callback) {
        let sendResults = actionData.sendResults;
        let isReceive = actionData.isReceive;
        if (sendResults.length == 0) {
            return;
        }
        let value = this.dealSendResults(sendResults);

        // 先判断是否创建过会话列表
        this.querySessionByTelephone(value.telephone, res => {
            HiLog.i(TAG, 'insertSessionAndDetail, querySessionByTelephone code=' + res.code);
            let response = res.response;
            HiLog.i(TAG, 'insertSessionAndDetail, querySessionByTelephone response.id=' + response.id);
            if (res.code == common.int.SUCCESS && response.id <= 0) {
                this.insertNoExitingSession(isReceive, value, actionData, callback);
            } else {
                this.insertExitingSession(response, value, actionData, callback);
            }
        });
    }

    insertNoExitingSession(isReceive, value, actionData, callback) {
        let unreadCount = 0;
        if (isReceive) {
            unreadCount = 1;
        }
        let valueBucket = {
            'telephone': value.telephone,
            'content': value.content,
            'contacts_num': value.contractsNum,
            'sms_type': value.smsType,
            'unread_count': unreadCount,
            'sending_status': value.sendStatus,
            'has_draft': 0,
            'time': value.timestamp,
            'message_count': 1,
            'has_mms': actionData.isMms ? 1 : 0,
            'has_attachment': actionData.hasAttachment ? 1 : 0
        }
        this.insertSession(valueBucket, res => {
            // 这里调用短信数据库，插入短信信息
            this.dealInsertMessageDetail(value, actionData, res.rowId, initDatas => {
                let result = {
                    rowId: res.rowId,
                    initDatas: initDatas
                }
                callback(result);
            });
        });
    }

    insertExitingSession(response, param, actionData, callback) {
        let sessionId = response.id;
        // 这里调用短信数据库，插入短信信息
        let threadIds = [sessionId];
        let time = new Date();
        let unreadCount = 0;
        if(actionData.isReceive) {
            unreadCount = response.unreadCount;
            unreadCount = unreadCount + 1;
        }
        let messageCount = response.messageCount;
        messageCount = messageCount + 1;
        let valueBucket = {
            'content': param.content,
            'unread_count': unreadCount,
            'time': time.getTime(),
            'sending_status': param.sendStatus,
            'message_count': messageCount,
            'has_mms': actionData.isMms ? 1 : 0,
            'has_draft': 0,
            'has_attachment': actionData.hasAttachment ? 1 : 0
        };
        this.updateById(threadIds, valueBucket, res => {
            // 这里调用短信数据库，插入短信信息
            this.dealInsertMessageDetail(param, actionData, sessionId, initDatas => {
                let result = {
                    rowId: sessionId,
                    initDatas: initDatas
                }
                callback(result);
            });
        });
    }

    querySessionByTelephone(telephone, callback) {
        let result: LooseObject = {};
        let queryPromise = this.querySessionByTelephoneRdb(telephone);
        Promise.all([queryPromise]).then((res) => {
            result.code = common.int.SUCCESS;
            result.response = res[0];
            callback(result);
        }).catch((err) => {
            HiLog.e(TAG, 'querySessionByTelephone, error: ' + JSON.stringify(err.message));
            result.code = common.int.FAILURE;
            callback(result);
        });
    }

    // 根据手机号,获取会话列表
    async querySessionByTelephoneRdb(telephone) {
        HiLog.i(TAG, 'querySessionByTelephoneRdb');
        // 创建查询条件对象
        let predicates = new ohosDataRdb.RdbPredicates(common.tableName.SESSION);
        // 如果为空，查询所有的列表数据
        if (telephone) {
            await predicates.equalTo(mmsTable.sessionField.telephone, telephone);
        }
        // 获取到结果集
        let resultSet = await rdbStore.query(predicates);
        // 获取第一条
        resultSet.goToFirstRow();
        let result: LooseObject = {};
        result.id = await resultSet.getLong(resultSet.getColumnIndex(mmsTable.sessionField.id));
        result.time = await resultSet.getLong(resultSet.getColumnIndex(mmsTable.sessionField.time));
        result.telephone = await resultSet.getString(resultSet.getColumnIndex(mmsTable.sessionField.telephone));
        result.content = await resultSet.getString(resultSet.getColumnIndex(mmsTable.sessionField.content));
        result.contactsNum = await resultSet.getLong(resultSet.getColumnIndex(mmsTable.sessionField.contactsNum));
        result.smsType = await resultSet.getLong(resultSet.getColumnIndex(mmsTable.sessionField.smsType));
        result.unreadCount = await resultSet.getLong(resultSet.getColumnIndex(mmsTable.sessionField.unreadCount));
        result.sendStatus = await resultSet.getLong(resultSet.getColumnIndex(mmsTable.sessionField.sendStatus));
        result.hasDraft = await resultSet.getLong(resultSet.getColumnIndex(mmsTable.sessionField.hasDraft));
        result.messageCount = await resultSet.getLong(resultSet.getColumnIndex(mmsTable.sessionField.messageCount));
        return result;
    }

    // 插入
    insertSession(valueBucket, callback) {
        this.insertSessionRdb(common.tableName.SESSION, valueBucket, callback);
    }

    insertSessionRdb(tableName, valueBucket, callback) {
        HiLog.i(TAG, 'insertSessionRdb');
        let insertPromise = rdbStore.insert(tableName, valueBucket);
        let result: LooseObject = {};
        insertPromise.then((ret) => {
            HiLog.i(TAG, 'insertSessionRdb, rowId: ' + ret);
            result.code = common.int.SUCCESS;
            result.rowId = ret;
            callback(result);
        }).catch((err) => {
            HiLog.e(TAG, 'insertSessionRdb, error: ' + JSON.stringify(err.message));
            result.code = common.int.FAILURE;
            callback(result);
        });
    }

    /**
     * 新增数据
     */
    async insert(tableName, valueBucket) {
        let promise = await rdbStore.insert(tableName, valueBucket);
        let rowId = 0;
        promise.then((ret) => {
            rowId = ret;
            HiLog.i(TAG, 'insert, first success: ' + rowId);
        }).catch((err) => {
            HiLog.e(TAG, 'insert, err: ' + JSON.stringify(err.message));
        })
        await promise;
        return rowId;
    }

    dealInsertMessageDetail(param, actionData, threadId, callback) {
        // 获取到最大的groupId
        this.queryMaxGroupId(actionData, res => {
            let maxGroupId = res == common.string.EMPTY_STR ? 0 : parseInt(res);
            maxGroupId = maxGroupId + 1;
            this.insertMessageDetailByGroupId(param, threadId, maxGroupId, actionData, callback);
        });
    }

    insertMessageDetailByGroupId(param, threadId, maxGroupId, actionData, callback) {
        let initDatas = [];
        let count = 0;
        let sendResults = actionData.sendResults;
        sendResults.forEach(sendResult => {
            let insertDetail = {
                receiverNumber: common.string.EMPTY_STR,
                senderNumber: common.string.EMPTY_STR,
                smsType: param.smsType,
                content: param.content,
                sendStatus: 0,
                sessionType: 0,
                threadId: threadId,
                isSender: actionData.isSender,
                groupId: maxGroupId,
                mmsSource: actionData.mmsSource,
                isMms: actionData.isMms,
                isRead: -1
            };
            if (actionData.isReceive) {
                insertDetail.receiverNumber = actionData.ownNumber;
                insertDetail.senderNumber = sendResult.telephone;
                insertDetail.isRead = 0;
            }
            this.insertMessageDetail(insertDetail, result => {
                count++;
                HiLog.i(TAG, 'insertMessageDetailByGroupId, result: ' + result);
                let initData = {
                    id: result,
                    telephone: sendResult.telephone
                };
                initDatas.push(initData);
                if (count == sendResults.length) {
                    callback(initDatas);
                }
            });
        })
    }

    dealSendResults(sendResults) {
        let contractsNum = sendResults.length;
        let telephone = common.string.EMPTY_STR;
        let content = common.string.EMPTY_STR;
        // 发送成功
        let sendStatus = 0;
        for (let sendResult of sendResults) {
            telephone = telephone + sendResult.telephone + common.string.COMMA;
            content = sendResult.content;
            sendStatus = sendResult.sendStatus;
        }
        telephone = telephone.substring(0, telephone.length - 1);
        let smsType = 0;
        if (contractsNum == 1 && telephoneUtils.judgeIsInfoMsg(telephone)) {
            smsType = 1;
        }
        let timestamp = new Date().getTime();
        let result: LooseObject = {};
        result.contractsNum = contractsNum;
        result.telephone = telephoneUtils.dealTelephoneSort(telephone);
        result.content = content;
        result.sendStatus = sendStatus;
        result.smsType = smsType;
        result.timestamp = timestamp;
        return result;
    }

    insertMessageDetail(value, callback) {
        let actionData: LooseObject = {};
        let time = new Date();
        let timeStr = time.getTime() + common.string.EMPTY_STR;
        var stringValue = {
            'receiver_number': value.receiverNumber,
            'sender_number': value.senderNumber,
            'start_time': timeStr,
            'end_time': timeStr,
            'msg_type': value.isMms ? '1' : '0',
            'sms_type': value.smsType,
            'msg_title': value.content,
            'msg_content': value.content,
            'msg_state': value.sendStatus,
            'operator_service_number': common.string.EMPTY_STR,
            'msg_code': common.string.EMPTY_STR,
            'session_id': value.threadId,
            'is_lock': '0',
            'is_read': value.isRead,
            'is_collect': '0',
            'session_type': value.sessionType,
            'is_subsection': '0',
            'is_sender': value.isSender,
            'is_send_report': 0,
            'group_id': value.groupId
        };
        actionData.stringValue = stringValue;
        this.insertMessageDetailRdb(actionData, msgId => {
            HiLog.i(TAG, 'insertMessageDetail, msgId: ' + msgId);
            if (value.isMms) {
                value.msgId = msgId;
                this.batchInsertMmsPart(value);
            }
            callback(msgId);
        });
    }

    batchInsertMmsPart(value) {
        let bacthmsParts = [];
        for (let source of value.mmsSource) {
            let stringValue = {
                'msg_id': value.msgId,
                'group_id': value.groupId,
                'type': source.msgType,
                'location_path': source.msgUriPath,
                'content': source.content,
                'recording_time': source.time,
                'part_size': source.fileSize
            };
            bacthmsParts.push(stringValue);
        }
        for(let stringValue of bacthmsParts) {
            this.insertMmsPart(stringValue);
        }
    }

    async insertMmsPart(stringValue) {
        let dataAbilityHelper = await particleAbility.acquireDataAbilityHelper(common.string.URI_MESSAGE_LOG);
        let managerUri = common.string.URI_MESSAGE_LOG + common.string.URI_MESSAGE_MMS_PART;
        dataAbilityHelper.insert(managerUri, stringValue).then(data => {
        }).catch(error => {
            HiLog.e(TAG, 'insertMmsPart, fail: ' + JSON.stringify(error.meaasge));
        });
    }

    // 插入单个短信信息
    async insertMessageDetailRdb(actionData, callback) {
        // 获取DataAbilityHelper对象
        let managerUri = common.string.URI_MESSAGE_LOG + common.string.URI_MESSAGE_INFO_TABLE;
        let dataAbilityHelper = await particleAbility.acquireDataAbilityHelper(common.string.URI_MESSAGE_LOG);
        let promise = dataAbilityHelper.insert(managerUri, actionData.stringValue);
        await promise.then(data => {
            callback(data);
        }).catch(error => {
            HiLog.e(TAG, 'insertMessageDetailRdb, fail: ' + JSON.stringify(error.message));
        });
    }

    /**
     * 根据主键ID,更新数据
     * @param threadIds 会话ID
     * @return
     */
    async updateById(threadIds, valueBucket, callback) {
        HiLog.i(TAG, 'updateById, threadIds: ' + JSON.stringify(threadIds));
        if (threadIds.length != 0) {
            for (let threadId of threadIds) {
                // 创建查询条件对象
                let predicates = new ohosDataRdb.RdbPredicates(common.tableName.SESSION);
                await predicates.equalTo(mmsTable.sessionField.id, threadId);
                this.update(predicates, valueBucket, res => {
                    callback(res);
                });
            }

        }
    }

    /**
     * 更新接口
     * @param predicates 更新条件
     * @param predicates 更新值
     * @return
     */
    async update(predicates, valueBucket, callback) {
        let changedRows = await rdbStore.update(valueBucket, predicates);
        callback(changedRows);
    }

    /**
     * 查询最大的groupId
     * @param actionData 参数
     * @param callBack 回调
     * @return
     */
    queryMaxGroupId(actionData, callBack) {
        this.queryMaxGroupIdDb(actionData, res => {
            HiLog.i(TAG, 'queryMaxGroupId, callback');
            callBack(res.maxGroupId);
        });
    }

    // 获取最大的groupId
    async queryMaxGroupIdDb(actionData, callback) {
        let dataAbilityHelper = await particleAbility.acquireDataAbilityHelper(common.string.URI_MESSAGE_LOG);
        let resultColumns = [
            'maxGroupId'
        ];
        let condition = new ohosDataAbility.DataAbilityPredicates();
        let managerUri = common.string.URI_MESSAGE_LOG + common.string.URI_MESSAGE_MAX_GROUP;
        dataAbilityHelper.query(managerUri, resultColumns, condition, (err, resultSet) => {
            let result: LooseObject = {};
            while (resultSet.goToNextRow()) {
                result.maxGroupId = resultSet.getString(0);
            }
            callback(result);
        }).catch(error => {
            HiLog.e(TAG, 'queryMaxGroupIdDb, error: ' + JSON.stringify(error.message));
        });
    }

    /**
     * commonEvent publish data
     */
    publishData(telephone, content) {
        HiLog.i(TAG, 'publishData, start');
        let actionData = {
            telephone: telephone,
            content: content
        };
        commonEvent.publish(common.string.RECEIVE_TRANSMIT_EVENT, {
            bundleName: common.string.BUNDLE_NAME,
            isOrdered: false,
            data: JSON.stringify(actionData)
        }, (res) => {
        });
    }

    async sendNotification(telephone, msgId, content) {
        let telephones = [telephone];
        this.queryContactDataByTelephone(telephones, async (contracts) => {
            HiLog.i(TAG, 'sendNotification, callback');
            let actionData = this.dealContactParams(contracts, telephone);
            if (content.length > 15) {
                content = content.substring(0, 15) + '...';
            }
            let message = {
                title: content,
                text: content,
            };
            actionData.message = message;
            actionData.msgId = msgId;
            notificationService.sendNotify(actionData);
        });
    }

    dealContactParams(contracts, telephone) {
        let actionData: LooseObject = {};
        let params = [];
        if(contracts.length == 0) {
            params.push({
                telephone: telephone,
            });
        } else {
            let contact = contracts[0];
            params.push({
                contactsName: contact.displayName,
                telephone: telephone,
                telephoneFormat: contact.detailInfo,
            });
        }
        actionData.contactObjects = JSON.stringify(params);
        return actionData;
    }

    async queryContactDataByTelephone(telephones, callback) {
        let resultColumns = [
            mmsTable.contactDataColumns.detailInfo,
            mmsTable.contactDataColumns.displayName,
        ];
        let contactDataAbilityHelper = await particleAbility.acquireDataAbilityHelper(common.string.URI_ROW_CONTACTS);
        let condition = new ohosDataAbility.DataAbilityPredicates();
        let contactDataUri = common.string.URI_ROW_CONTACTS + common.string.CONTACT_DATA_URI;
        condition.in(mmsTable.contactDataColumns.detailInfo, telephones);
        condition.and();
        condition.equalTo(mmsTable.contactDataColumns.typeId, '5');
        contactDataAbilityHelper.query(contactDataUri, resultColumns, condition).then(resultSet => {
            let contracts = [];
            while (resultSet.goToNextRow()) {
                let contract = {
                    detailInfo: resultSet.getString(0),
                    displayName: resultSet.getString(1)
                };
                contracts.push(contract);
            }
            callback(contracts);
        }).catch(error => {
            HiLog.e(TAG, 'queryContactDataByTelephone error: ' + JSON.stringify(error.message));
        });
    }
}