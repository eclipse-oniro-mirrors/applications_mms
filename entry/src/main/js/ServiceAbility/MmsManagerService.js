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

import commonEvent from '@ohos.commonevent';
import common from '../default/pages/common_constants.js';
import mmsTable from '../default/pages/mms_table.js';
import telephoneUtils from '../default/utils/TelephoneUtil.js';
import mmsLog from '../default/utils/MmsLog.js';
import particleAbility from '@ohos.ability.particleability';
import ohosDataAbility from '@ohos.data.dataability';
import telSim from '@ohos.telephony.sms';
import ohosDataRdb from '@ohos.data.rdb';
import commonService from '../default/service/CommonService.js';
import http from '@ohos.net.http';
import notificationService from '../default/service/NotificationService.js';

// 数据库实例对象
var rdbStore = undefined;
var dataAbilityHelper = undefined;
var contactDataAbilityHelper = undefined;

// 数据库名称
const STORE_CONFIG = {
    name: 'mmssms.db',
}
const TAG = 'MmsManagerService.js ---> '

export default class CallManagerService {
    constructor() {
        this.addSubscriberListener();
        // 初始化数据库
        this.initRdb();
        // 初始化
        dataAbilityHelper = particleAbility.acquireDataAbilityHelper(common.string.URI_MESSAGE_LOG);
        contactDataAbilityHelper = particleAbility.acquireDataAbilityHelper(common.string.URI_ROW_CONTACTS);
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
        this.commonEventData = data;
        // 接收到订阅
        commonEvent.subscribe(this.commonEventData, this.subscriberCallBack.bind(this));
    }

    subscriberCallBack(err, data) {
        // 短信接收
        if (data.event === common.string.SUBSCRIBER_EVENT) {
            this.dealSmsReceiveData(data);
        } else {
            // 彩信接收
            this.dealMmsReceiveData(data);
        }
    }

    async dealSmsReceiveData(data) {
        // 同步等待操作
        let createMessagePromise = telSim.createMessage(this.convertStrArray(data.data), '3gpp');
        let result = {};
        createMessagePromise.then((shortMessage) => {
            mmsLog.log(TAG + 'shortMessage visibleMessageBody = ' + shortMessage);
            result.code = common.int.SUCCESS;
            result.telephone = telephoneUtils.formatTelephone(shortMessage.visibleRawAddress);
            result.content = shortMessage.visibleMessageBody;
        }).catch((err) => {
            mmsLog.log(TAG + 'createShortMessage err ' + err.message);
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
        let actionData = {
            telephone: result.telephone,
            content: content,
            isMms: true,
            mmsSource: result.mmsSource
        }
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
                    method: 'GET',
                    header: {
                        'Content-Type': 'application/json',
                    },
                    extraData: baseUrl,
                    readTimeout: 50000,
                    connectTimeout: 50000
                }, (err, data) => {
                    mmsLog.log(TAG + 'saveAttachment err:' + err + ' data:' + data);
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
        let actionData = {
            sendResults: sendResults,
            isReceive: true,
            ownNumber: common.string.EMPTY_STR,
            isSender: 1,
            isMms: param.isMms,
            mmsSource: param.mmsSource,
            hasAttachment: hasAttachment
        }
        this.insertSessionAndDetail(actionData, callback);
    }

    convertStrArray(sourceStr) {
        let wby = sourceStr;
        let length = wby.length;
        let isDouble = (length % 2) == 0;
        let halfSize = parseInt(length / 2);
        mmsLog.log(TAG + 'length......' + length);
        if (isDouble) {
            mmsLog.log(TAG + 'isDouble......' + isDouble);
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
            mmsLog.log('pdu error...');
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
        commonEvent.unsubscribe(this.commonEventData, () => {
            mmsLog.log('conversation_list unsubscribe');
        });
    }

    // 初始化数据库
    async initRdb() {
        // 创建数据库表
        this.createRdbStore().then(async (ret) => {
            mmsLog.log(' logMessage createRdbStore first done: ' + ret);
            await this.createTable(mmsTable.table.session);
        }).catch((err) => {
            mmsLog.log(' logMessage error insert first done: ' + err);
        });
    }

    /**
     * 创建数据库
     */
    async createRdbStore() {
        mmsLog.log(TAG + ' createRdbStore start');
        rdbStore = await ohosDataRdb.getRdbStore(STORE_CONFIG, 1);
        mmsLog.log(TAG + ' createRdbStore end');
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
            mmsLog.log(TAG + 'insertSessionAndDetail,querySessionByTelephone:' + res);
            let response = res.response;
            if (res.code == common.int.SUCCESS && response.id < 0) {
                this.insertNoExitingSession(isReceive, value, actionData, callback);
            } else {
                this.insertExitingSession(response, value, actionData, callback);
            }
        });
        mmsLog.log(TAG + 'insertSessionAndDetail,end');
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
            mmsLog.log(TAG + 'insertSession,rowId:' + res);
            this.dealInsertMessageDetail(value, actionData, res.rowId, initDatas => {
                mmsLog.log(TAG + 'dealInsertMessageDetail,initDatas:' + initDatas);
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
            mmsLog.log(TAG + 'updateById,res:' + res);
            // 这里调用短信数据库，插入短信信息
            this.dealInsertMessageDetail(param, actionData, sessionId, initDatas => {
                mmsLog.log('dealInsertMessageDetail,initDatas:' + initDatas);
                let result = {
                    rowId: sessionId,
                    initDatas: initDatas
                }
                callback(result);
            });
        });
    }

    querySessionByTelephone(telephone, callback) {
        let result = {};
        let queryPromise = this.querySessionByTelephoneRdb(telephone);
        Promise.all([queryPromise]).then((res) => {
            mmsLog.log('querySessionByTelephone,result:' + res[0]);
            result.code = common.int.SUCCESS;
            result.response = res[0];
            callback(result);
        }).catch((err) => {
            mmsLog.log('querySessionByTelephone error: ' + err);
            result.code = common.int.FAILURE;
            callback(result);
        });
    }

    // 根据手机号,获取会话列表
    async querySessionByTelephoneRdb(telephone) {
        // 创建查询条件对象
        let predicates = new ohosDataRdb.RdbPredicates(common.tableName.SESSION);
        mmsLog.log('querySessionByTelephoneRdb, predicates:' + predicates);
        // 如果为空，查询所有的列表数据
        if (telephone) {
            await predicates.equalTo(mmsTable.sessionField.telephone, telephone);
        }
        mmsLog.log('querySessionByTelephoneRdb, rdbStore:' + rdbStore);
        // 获取到结果集
        let resultSet = await rdbStore.query(predicates);
        // 获取第一条
        resultSet.goToFirstRow();
        let result = {};
        result.id = await resultSet.getLong(resultSet.getColumnIndex(mmsTable.sessionField.id));
        result.time = await resultSet.getLong(resultSet.getColumnIndex(mmsTable.sessionField.time));
        result.telephone = await resultSet.getString(resultSet.getColumnIndex(mmsTable.sessionField.telephone));
        result.content = await resultSet.getString(resultSet.getColumnIndex(mmsTable.sessionField.content));
        result.contactsNum = await resultSet.getLong(resultSet.getColumnIndex(mmsTable.sessionField.contactsNum));
        result.smsType = await resultSet.getLong(resultSet.getColumnIndex(mmsTable.sessionField.smsType));
        result.unreadCount = await resultSet.getLong(resultSet.getColumnIndex(mmsTable.sessionField.unreadCount));
        result.sendingStatus = await resultSet.getLong(resultSet.getColumnIndex(mmsTable.sessionField.sendingStatus));
        result.hasDraft = await resultSet.getLong(resultSet.getColumnIndex(mmsTable.sessionField.hasDraft));
        result.messageCount = await resultSet.getLong(resultSet.getColumnIndex(mmsTable.sessionField.messageCount));
        return result;
    }

    // 插入
    insertSession(valueBucket, callback) {
        this.insertSessionRdb(common.tableName.SESSION, valueBucket, callback);
    }

    insertSessionRdb(tableName, valueBucket, callback) {
        let insertPromise = this.insert(tableName, valueBucket);
        let result = {};
        insertPromise.then((ret) => {
            mmsLog.log('insertSession rowId:' + ret);
            result.code = common.int.SUCCESS;
            result.rowId = ret;
            callback(result);
        }).catch((err) => {
            mmsLog.log('insertSession error: ' + err);
            result.code = common.int.FAILURE;
            callback(result);
        });
    }

    /**
     * 新增数据
     */
    async insert(tableName, valueBucket) {
        mmsLog.log('insert,enter:' + rdbStore);
        let promise = rdbStore.insert(tableName, valueBucket);
        let rowId = 0;
        promise.then((ret) => {
            rowId = ret;
        }).catch((err) => {
            mmsLog.log(TAG + ' insert first done: ' + err);
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
        for (let sendResult of sendResults) {
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
                isMms: actionData.isMms
            };
            if (actionData.isReceive) {
                insertDetail.receiverNumber = actionData.ownNumber;
                insertDetail.senderNumber = sendResult.telephone;
                insertDetail.isRead = 0;
            }
            this.insertMessageDetail(insertDetail, result => {
                count++;
                mmsLog.log(TAG + 'insertMessageDetail,result:' + result);
                let initData = {
                    id: result,
                    telephone: sendResult.telephone
                };
                initDatas.push(initData);
                if (count == sendResults.length) {
                    callback(initDatas);
                }
            });
        }
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
        let result = {};
        result.contractsNum = contractsNum;
        result.telephone = telephoneUtils.dealTelephoneSort(telephone);
        result.content = content;
        result.sendStatus = sendStatus;
        result.smsType = smsType;
        result.timestamp = timestamp;
        return result;
    }

    insertMessageDetail(value, callback) {
        let actionData = {};
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
        mmsLog.log(TAG + 'insertMessageDetail stringValue:' + stringValue);
        actionData.stringValue = stringValue;
        this.insertMessageDetailRdb(actionData, msgId => {
            mmsLog.log(TAG + 'insertMessageDetailRdb msgId:' + msgId);
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
        mmsLog.log(TAG + 'batchInsertMmsPart stringValue' + bacthmsParts);
        for(let stringValue of bacthmsParts) {
            this.insertMmsPart(stringValue);
        }
    }

    async insertMmsPart(stringValue) {
        let managerUri = common.string.URI_MESSAGE_LOG + common.string.URI_MESSAGE_MMS_PART;
        dataAbilityHelper.insert(managerUri, stringValue).then(data => {
            mmsLog.log(TAG + 'insertMmsPart, success:' + data);
        }).catch(error => {
            mmsLog.log(TAG + 'insertMmsPart fail:' + error);
        });
    }

    // 插入单个短信信息
    async insertMessageDetailRdb(actionData, callback) {
        // 获取DataAbilityHelper对象
        let managerUri = common.string.URI_MESSAGE_LOG + common.string.URI_MESSAGE_INFO_TABLE;
        dataAbilityHelper.insert(managerUri, actionData.stringValue).then(data => {
            mmsLog.log('dataAbilityHelper, success:' + data);
            callback(data);
        }).catch(error => {
            mmsLog.log('insertMessageDetail fail:' + error);
        });
    }

    /**
     * 根据主键ID,更新数据
     * @param threadIds 会话ID
     * @return
     */
    async updateById(threadIds, valueBucket, callback) {
        mmsLog.log('updateById, threadIds:' + threadIds);
        if (threadIds.length != 0) {
            for (let threadId of threadIds) {
                // 创建查询条件对象
                let predicates = new ohosDataRdb.RdbPredicates(common.tableName.SESSION);
                await predicates.equalTo(mmsTable.sessionField.id, threadId);
                this.update(predicates, valueBucket, res => {
                    mmsLog.log(TAG + 'updated row count: ' + res);
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
            mmsLog.log(TAG + 'queryMaxGroupId, end:' + res);
            callBack(res.maxGroupId);
        });
    }

    // 获取最大的groupId
    async queryMaxGroupIdDb(actionData, callback) {
        mmsLog.log('queryMaxGroupIdDb dataAbilityHelper :' + dataAbilityHelper);
        let resultColumns = [
            'maxGroupId'
        ];
        let condition = new ohosDataAbility.DataAbilityPredicates();
        let managerUri = common.string.URI_MESSAGE_LOG + common.string.URI_MESSAGE_MAX_GROUP;
        dataAbilityHelper.query(managerUri, resultColumns, condition, (err, resultSet) => {
            let result = {};
            while (resultSet.goToNextRow()) {
                result.maxGroupId = resultSet.getString(0);
                mmsLog.log(TAG + 'queryMaxGroupId result = ' + result);
            }
            callback(result);
        });
    }

    /**
     * commonEvent publish data
     */
    publishData(telephone, content) {
        let actionData = {};
        actionData.telephone = telephone;
        actionData.content = content;
        mmsLog.log('receive_message.publishData start');
        commonEvent.publish(common.string.RECEIVE_TRANSMIT_EVENT, {
            bundleName: common.string.BUNDLE_NAME,
            isOrdered: false,
            data: JSON.stringify(actionData)
        }, (res) => {
            mmsLog.log('receive_message.publish callback res: ' + res);
        });
    }

    async sendNotification(telephone, msgId, content) {
        let telephones = [telephone];
        this.queryContactDataByTelephone(telephones, async (contracts) => {
            mmsLog.log('queryContactDataByTelephone contracts:' + contracts);
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
        let actionData = {};
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
        let condition = new ohosDataAbility.DataAbilityPredicates();
        let contactDataUri = common.string.URI_ROW_CONTACTS + common.string.CONTACT_DATA_URI;
        condition.in(mmsTable.contactDataColumns.detailInfo, telephones);
        condition.and();
        condition.equalTo(mmsTable.contactDataColumns.type_id, '5');
        contactDataAbilityHelper.query(contactDataUri, resultColumns, condition).then(resultSet => {
            let contracts = [];
            while (resultSet.goToNextRow()) {
                let contract = {};
                contract.detailInfo = resultSet.getString(0);
                contract.displayName = resultSet.getString(1);
                contracts.push(contract);
            }
            callback(contracts);
        }).catch(error => {
            mmsLog.log('queryContactDataByTelephone error:' + error);
        });
    }
}