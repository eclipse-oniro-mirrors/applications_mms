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

import ContactsModel from '../model/ContactsModel';
import ConversationModel from '../model/ConversationModel';
import common from '../data/commonData';
import HiLog from '../utils//HiLog';

import conversationListService from './ConversationListService';
import telephoneUtils from '../utils/TelephoneUtil';
import contractService from './ContractService';
import commonService from './CommonService';
import LooseObject from '../data/LooseObject'
import preferences from '../utils/PreferencesUtil';

const TAG = 'ConversationService';

let mContactsModel = new ContactsModel();
let mConversationModel = new ConversationModel();

export default {

    /**
     * 判断联系人是否存在
     * @param params 联系人电话号码
     * @param callback 联系人是否存在
     * @return
     */
    judgeContactExists(params, callback) {
        mContactsModel.queryContactDataByTelephone(params, function (result) {
            let hasExitContract = false;
            if (result.length >= 1) {
                // 联系人是否存在
                HiLog.i(TAG, 'judgeContactExists, queryContactDataByTelephone success');
                hasExitContract = true;
            }
            callback(hasExitContract);
        });
    },

    /**
     * 获取信息详情
     * @param params 电话号码/会话id
     * @param callback 返回信息内容
     * @return
     */
    queryMessageDetail(actionData, callback) {
        let result: LooseObject = {};
        HiLog.i(TAG, 'queryMessageDetail, start');
        mConversationModel.queryMessageDetail(actionData, res => {
            HiLog.i(TAG, 'queryMessageDetail, queryMessageDetail success')
            result.code = res.code;
            if (res.code == common.int.SUCCESS) {
                this.groupDetailMessage(res.abilityResult, actionData, resultList => {
                    result.response = resultList;
                    callback(result);
                });
            } else {
                HiLog.w(TAG, 'groupDetailMessage, failed');
                callback(result);
            }
        });
    },
    convertConversationList(mmsList) {
        let resultList = [];
        for (let item of mmsList) {
            let result: LooseObject = {};
            result.id = item.msgId;
            result.content = item.msgContent;
            result.isLock = item.isLock == 0 ? false : true;
            result.isStared = item.isCollect == 0 ? false : true;
            // 彩信相关字段
            result.msgType = 0;
            result.isFullScreenImg = true;
            result.read = item.isRead == 0 ? '0' : '1';
            if (item.msgState == 0) {
                result.sendStatus = common.int.SEND_MESSAGE_SUCCESS;
            } else if (item.msgState == 2) {
                result.sendStatus = common.int.SEND_MESSAGE_FAILED;
            } else if (item.msgState == 1){
                result.sendStatus = common.int.SEND_MESSAGE_SENDING;
            } else {
                result.sendStatus = common.int.SEND_DRAFT;
            }
            result.subId = 0;
            result.timeMillisecond = item.startTime;
            result.isMsm = item.msgType == 0 ? false : true;
            result.isCbChecked = false;
            result.isDraft = false;
            // 群发相关字段
            result.groupId = item.groupId;
            // 判断是接收方还是发送方
            result.isReceive = item.isSender == 0 ? false : true;
            result.date = common.string.EMPTY_STR;
            result.time = common.string.EMPTY_STR;
            result.completeNumber = 0;
            result.failuresNumber = 0;
            result.hasReport = item.isSendReport == 0 ? false : true;
            if (!result.isMsm) {
                result.msgShowType = common.MESSAGE_SHOW_TYPE.NORMAL;
            }
            resultList.push(result);
        }
        return resultList;
    },
    groupDetailMessage(mmsList, actionData, callback) {
        let details = this.convertConversationList(mmsList);
        let msgIds = [];
        if (actionData.contactsNum == 1) {
            for (let item of details) {
                if (item.isMsm) {
                    msgIds.push(item.id);
                }
            }
            this.dealMmsPartData(details, msgIds, actionData, res => {
                callback(res);
            });
            return;
        }
        let resultList = [];
        // 需要根据groupId 进行分组
        let detailMap = this.convertConversationMap(details);
        // 根据组进行
        let groupIds = detailMap.keys();
        for (let groupId of groupIds) {
            let groups = detailMap.get(groupId);
            let result = groups[0];
            let failuresNumber = 0;
            let completeNumber = 0;
            if (result.isMsm) {
                msgIds.push(result.id);
            }
            for (let item of groups) {
                if (item.sendStatus == common.int.SEND_MESSAGE_FAILED) {
                    failuresNumber++;
                }
                if (item.sendStatus == common.int.SEND_MESSAGE_FAILED ||
                item.sendStatus == common.int.SEND_MESSAGE_SUCCESS) {
                    completeNumber++;
                }
            }
            result.completeNumber = completeNumber;
            result.failuresNumber = failuresNumber;
            resultList.push(result);
        }
        this.dealMmsPartData(resultList, msgIds, actionData, res => {
            callback(res);
        });
    },
    dealMmsPartData(resultList, msgIds, actionData, callback) {
        if (msgIds.length == 0) {
            callback(resultList);
            return;
        }
        actionData.msgIds = msgIds;
        this.queryMmsPartByIds(actionData, res => {
            let mmsParts = res.response;
            let mmsPartMap = new Map();
            for (let item of mmsParts) {
                if (mmsPartMap.has(item.msgId)) {
                    let strings = mmsPartMap.get(item.msgId);
                    strings.push(item);
                } else {
                    let strings = [];
                    strings.push(item);
                    mmsPartMap.set(item.msgId, strings);
                }
            }
            for (let item of resultList) {
                if (mmsPartMap.has(item.id)) {
                    let mmsParts = mmsPartMap.get(item.id);
                    // 判断是否需要展示 0 普通样式, 1 主题, 2幻灯片,
                    item.mms = commonService.getMmsSource(mmsParts);
                    item.msgShowType = commonService.getDisplay(item.mms);
                    commonService.setItemMmsContent(item, item.mms);
                }
            }
            callback(resultList);
        });
    },
    convertConversationMap(details) {
        let conversationMap = new Map();
        // 分组
        for (let element of details) {
            if (conversationMap.has(element.groupId)) {
                let groups = conversationMap.get(element.groupId);
                groups.push(element);
            } else {
                let groups = [];
                groups.push(element);
                conversationMap.set(element.groupId, groups);
            }
        }
        return conversationMap;
    },

    /**
     * 插入会话详情及短信详情
     * @param sendResults 发送结果
     * @param threadId 会话列表ID
     * @param isReceive 是否接收
     * @return
     */
    insertSessionAndDetail(actionData, callback) {
        HiLog.i(TAG,'insertSessionAndDetail, start');
        let sendResults = actionData.sendResults;
        let isReceive = actionData.isReceive;
        if (sendResults.length == 0) {
            HiLog.w(TAG,'insertSessionAndDetail, sendResults.length == 0');
            return;
        }
        let param = this.dealSendResults(sendResults);
        // 先判断是否创建过会话列表
        conversationListService.querySessionByTelephone(param.telephone, res => {
            let response = res.response;
            if (res.code == common.int.SUCCESS && response.id <= 0) {
                this.dealNoExitingSession(isReceive, param, actionData, callback);
            } else {
                this.dealExitingSession(response, param, actionData, callback);
            }
        });
    },
    dealNoExitingSession(isReceive, param, actionData, callback) {
        let unreadCount = 0;
        if (isReceive) {
            unreadCount = 1;
        }
        let valueBucket = {
            'telephone': param.telephone,
            'content': param.content,
            'contacts_num': param.contractsNum,
            'sms_type': param.smsType,
            'unread_count': unreadCount,
            'sending_status': param.sendStatus,
            'has_draft': 0,
            'time': param.timestamp,
            'message_count': 1,
            'has_mms': actionData.isMms ? 1 : 0,
            'has_attachment': actionData.hasAttachment ? 1 : 0
        }
        conversationListService.insertSession(valueBucket, sessionResult => {
            HiLog.i(TAG, 'dealNoExitingSession, insertSession callback')
            // 这里调用短信数据库，插入短信信息
            this.dealInsertMessageDetail(param, actionData, sessionResult.rowId, res => {
                let result = {
                    rowId: sessionResult.rowId,
                    initDatas: res.initDatas,
                    groupId: res.groupId
                }
                callback(result);
            });
        });
    },
    dealExitingSession(response, param, actionData, callback) {
        HiLog.i(TAG, 'dealExitingSession')
        let sessionId = response.id;
        // 这里调用短信数据库，插入短信信息
        let threadIds = [sessionId];
        let time = new Date();
        let unreadCount = 0;
        if (actionData.isReceive) {
            unreadCount = response.unreadCount;
            unreadCount = unreadCount + 1;
        }
        let hasDraft = response.hasDraft;
        if (actionData.hasDraft && hasDraft == 1) {
            hasDraft = 0;
        }
        let messageCount = response.messageCount;
        messageCount = messageCount + 1;
        let valueBucket = {
            'content': param.content,
            'unread_count': unreadCount,
            'time': time.getTime(),
            'sending_status': param.sendStatus,
            'has_draft': hasDraft,
            'message_count': messageCount,
            'has_attachment': actionData.hasAttachment ? 1 : 0,
            'has_mms': actionData.isMms ? 1 : 0,
        }
        conversationListService.updateById(threadIds, valueBucket);
        // 这里调用短信数据库，插入短信信息
        this.dealInsertMessageDetail(param, actionData, sessionId, res => {
            let result = {
                rowId: sessionId,
                initDatas: res.initDatas,
                groupId: res.groupId
            }
            callback(result);
        });
    },
    dealInsertMessageDetail(param, actionData, threadId, callback) {
        HiLog.i(TAG, 'dealInsertMessageDetail')
        this.queryMaxGroupId(actionData, res => {
            let maxGroupId = 0;
            if (res.code === common.int.SUCCESS) {
                HiLog.i(TAG, 'dealInsertMessageDetail, queryMaxGroupId maxGroupId=' + res.response.maxGroupId)
                maxGroupId = res.response.maxGroupId == common.string.EMPTY_STR ? 0 : Number(res.response.maxGroupId);
                maxGroupId = maxGroupId + 1;
            } else {
                HiLog.w(TAG,'dealInsertMessageDetail, queryMaxGroupId failed');
                callback();
            }
            this.insertMessageDetailByMaxGroupId(param, actionData, threadId, maxGroupId, result => {
                callback(result);
            });
        });
    },
    insertMessageDetailByMaxGroupId(param, actionData, threadId, maxGroupId, callback) {
        let count = 0;
        let initDatas = [];
        let result: LooseObject = {};
        result.groupId = maxGroupId;
        let sendResults = actionData.sendResults;
        sendResults.forEach(sendResult => {
            let insertDetail = this.initInsertDetail(param, actionData, threadId, maxGroupId);
            if (actionData.isReceive) {
                insertDetail.receiverNumber = actionData.ownNumber;
                insertDetail.senderNumber = sendResult.telephone;
                insertDetail.isRead = 0;
            } else {
                insertDetail.receiverNumber = sendResult.telephone;
                insertDetail.senderNumber = actionData.ownNumber;
                insertDetail.isRead = 1;
            }
            insertDetail.sendStatus = sendResult.sendStatus;
            if (sendResult.sendStatus == common.int.SEND_MESSAGE_FAILED) {
                insertDetail.sendStatus = 2;
            } else if (sendResult.sendStatus == common.int.SEND_MESSAGE_SUCCESS) {
                insertDetail.sendStatus = 0;
            }
            if (sendResult.time != null) {
                insertDetail.time = sendResult.time;
            }
            this.insertMessageDetail(insertDetail, id => {
                HiLog.d(TAG, 'insertMessageDetailByMaxGroupId, insertMessageDetail id=' + id);
                count++;
                let initData = {
                    id: id,
                    telephone: sendResult.telephone
                };
                initDatas.push(initData);
                if (count == actionData.sendResults.length) {
                    result.initDatas = initDatas;
                    callback(result);
                }
            });
        })
    },
    initInsertDetail(param, actionData, threadId, maxGroupId) {
        HiLog.i(TAG, 'initInsertDetail')
        let insertDetail: LooseObject = {
            receiverNumber: common.string.EMPTY_STR,
            senderNumber: common.string.EMPTY_STR,
            smsType: param.smsType,
            content: param.content,
            sendStatus: 2,
            sessionType: 0,
            threadId: threadId,
            isSender: actionData.isSender,
            groupId: maxGroupId,
            time: common.string.EMPTY_STR,
            hasReport: actionData.hasReport,
            isMms: actionData.isMms,
            mmsSource: actionData.mmsSource,
            messageType: actionData.messageType
        };
        return insertDetail;
    },
    dealSendResults(sendResults) {
        HiLog.i(TAG, 'dealSendResults')
        let contractsNum = sendResults.length;
        let telephone = common.string.EMPTY_STR;
        let content = common.string.EMPTY_STR;
        // 发送成功
        let sendStatus = 0;
        let failSum = 0;
        let time = common.string.EMPTY_STR;
        for (let sendResult of sendResults) {
            telephone = telephone + sendResult.telephone + common.string.COMMA;
            content = sendResult.content;
            sendStatus = sendResult.sendStatus;
            if (sendResult.sendStatus == common.int.SEND_MESSAGE_FAILED) {
                failSum++;
            }
            if (sendResult.time != null) {
                time = sendResult.time;
            }
            if (sendResult.isMessageSim != null && sendResult.isMessageSim) {
                telephone = sendResult.telephone;
                contractsNum = 1;
            }
        }
        // 如果失败，那会话列表结果就是失败
        if (failSum > 0) {
            sendStatus = common.int.SEND_MESSAGE_FAILED;
        }
        telephone = telephone.substring(0, telephone.length - 1);
        let smsType = 0;
        if (contractsNum == 1 && telephoneUtils.judgeIsInfoMsg(telephone)) {
            smsType = 1;
        }
        let result: LooseObject = {};
        let timestamp = new Date().getTime();
        result.contractsNum = contractsNum;
        result.content = content;
        result.telephone = telephoneUtils.dealTelephoneSort(telephone);
        result.sendStatus = sendStatus;
        result.timestamp = time != common.string.EMPTY_STR ? time : timestamp;
        result.smsType = smsType;
        return result;
    },

    /**
     * 插入短信信息
     * @param actionData 会话IDs
     * @return
     */
    insertMessageDetail(param, callback) {
        let actionData: LooseObject = {};
        let time = new Date();
        let timeStr = param.time != common.string.EMPTY_STR ? param.time : time.getTime() + common.string.EMPTY_STR;
        var stringValue = {
            'receiver_number': param.receiverNumber,
            'sender_number': param.senderNumber,
            'start_time': timeStr,
            'end_time': timeStr,
            'msg_type': param.isMms ? '1' : '0',
            'sms_type': param.smsType,
            'msg_title': param.content,
            'msg_content': param.content,
            'msg_state': param.sendStatus,
            'operator_service_number': common.string.EMPTY_STR,
            'msg_code': common.string.EMPTY_STR,
            'session_id': param.threadId,
            'is_lock': '0',
            'is_read': param.isRead,
            'is_collect': '0',
            'session_type': param.sessionType,
            'is_sender': param.isSender,
            'group_id': param.groupId,
            'is_send_report': param.hasReport
        };
        actionData.stringValue = stringValue;
        actionData.featureAbility = param.featureAbility;
        mConversationModel.insertMessageDetail(actionData, result => {
            if (result.code == common.int.SUCCESS) {
                HiLog.i(TAG, 'insertMessageDetail, callback success')
                this.dealBatchInsertMmsPart(param, result, callback);
            } else {
                HiLog.w(TAG, 'insertMessageDetail, fail');
            }
        });
    },
    dealBatchInsertMmsPart(param, result, callback) {
        if (param.isMms) {
            param.msgId = result.abilityResult;
            this.batchInsertMmsPart(param, res => {
                callback(result.abilityResult);
            });
        } else {
            callback(result.abilityResult);
        }
    },
    batchInsertMmsPart(param, callback) {
        let actionData: LooseObject = {};
        actionData.featureAbility = param.featureAbility;
        let bacthmsParts = [];
        for (let mms of param.mmsSource) {
            let stringValue = {
                'msg_id': param.msgId,
                'group_id': param.groupId,
                'type': mms.msgType,
                'location_path': mms.msgUriPath,
                'content': mms.content,
                'recording_time': mms.time,
                'part_size': (mms.fileSize + ''),
                'state': param.messageType
            };
            bacthmsParts.push(stringValue);
        }
        actionData.bacthmsParts = bacthmsParts;
        mConversationModel.batchInsertMmsPart(actionData, callback);
    },
    updateSessionAndDetail(actionData) {
        let sendResults = actionData.sendResults;
        if (sendResults.length == 0) {
            return;
        }
        let param = this.dealSendResults(sendResults);
        // 更新会话列表的状态
        let threadIds = [actionData.threadId];
        let valueBucket = {
            'sending_status': param.sendStatus,
            'content': param.content
        }
        conversationListService.updateById(threadIds, valueBucket);
        // 更新信息列表的状态
        for (let sendResult of sendResults) {
            actionData.sendStatus = sendResult.sendStatus;
            if (sendResult.sendStatus == common.int.SEND_MESSAGE_FAILED) {
                actionData.sendStatus = 2;
            } else if (sendResult.sendStatus == common.int.SEND_MESSAGE_SUCCESS) {
                actionData.sendStatus = 0;
            } else {
                actionData.sendStatus = 1;
            }
            actionData.msgId = sendResult.id;
            this.updateById(actionData, result => {
            });
        }
    },

    /**
     * 根据会话ID,批量删除列表数据
     * @param threadIds 会话IDs
     * @return
     */
    deleteMessageBySessionIds(actionData) {
        mConversationModel.queryGroupIdBySessionId(actionData, res => {
            if (res.code == common.int.SUCCESS) {
                mConversationModel.deleteMessageBySessionIds(actionData);
                let groupIds = res.abilityResult;
                actionData.groupIds = groupIds;
                mConversationModel.deleteMmsPartByGroupIds(actionData);
            }
        });
    },

    /**
     * 根据ID,批量删除列表数据
     * @param 主键ID 会话IDs
     * @return
     */
    deleteMessageByIds(actionData) {
        mConversationModel.deleteMessageByIds(actionData);
    },
    deleteMessageBySessionIdsAndLock(actionData) {
        mConversationModel.deleteMessageBySessionIdsAndLock(actionData);
    },

    /**
     * 根据GroupID,批量删除列表数据
     * @param 主键ID 会话IDs
     * @return
     */
    deleteMessageByGroupIds(actionData) {
        mConversationModel.deleteMessageByGroupIds(actionData);
        // 删除彩信的数据
        mConversationModel.deleteMmsPartByGroupIds(actionData);
    },

    /**
     * 根据批量标记
     * @param actionData
     * @return
     */
    markAllAsRead(actionData) {
        mConversationModel.markAllAsRead(actionData);
    },

    /**
     * 根据批量标记
     * @param actionData
     * @return
     */
    markAllToRead(actionData) {
        mConversationModel.markAllToRead(actionData);
    },

    /**
     * 根据单个id,进行更新
     * @param actionData
     * @param callback
     */
    updateById(actionData, callback) {
        let result: LooseObject = {};
        mConversationModel.updateById(actionData, res => {
            result.code = res.code;
            callback(result);
        }).catch(e=> {
            HiLog.e(TAG, 'updateById, error: ' + JSON.stringify(e.message))
        });
    },

    /**
     * 判断卡是否存在
     */
    judgeHasSimCard() {
        let count = preferences.getCountOfSim();
        if (count > 0) {
            return true;
        }
        return false;
    },

    /**
     * 查询最大的groupId
     * @param actionData 参数
     * @param callBack 回调
     * @return
     */
    queryMaxGroupId(actionData, callBack) {
        let result: LooseObject = {};
        mConversationModel.queryMaxGroupId(actionData, res => {
            result.code = res.code;
            if (res.code == common.int.SUCCESS) {
                result.response = res.abilityResult;
            } else {
                HiLog.w(TAG, 'queryMaxGroupId, failed');
            }
            callBack(result);
        });
    },

    /**
     * 保存图片
     * @param params threadId，pduId
     * @param callback 保存状态
     * @return
     */
    saveImage(params, callback) {
        mConversationModel.saveImage(params, function (result) {
            let message = '';
            if (result.code == common.int.SUCCESS) {
                HiLog.i(TAG, 'saveImage, success');
                message = this.$t('strings.attachment_saved_to') + result.abilityResult.filePath
                + this.$t('strings.please_keep_it_secure');
            } else {
                HiLog.w(TAG, 'saveImage, error');
                message = this.$t('string.save_img_failed');
            }
            callback(message);
        });
    },

    /**
     * 分享
     * @param actionData 参数
     * @param callback 回调
     * @return
     */
    gotoShare(actionData, callback) {
        let result: LooseObject = {};
        mConversationModel.gotoShare(actionData, res => {
            result.code = res.code;
        });
        callback(result);
    },

    /**
     * 更新锁标记
     * @param actionData 参数
     * @param callback 回调
     * @return
     */
    updateLock(actionData, callback) {
        let result: LooseObject = {};
        mConversationModel.updateLock(actionData, res => {
            result.code = res.code;
            callback(result);
        });
    },

    /**
     * 更新收藏
     * @param actionData 参数
     * @param callback 回调
     * @return
     */
    updateCollect(actionData, callback) {
        let result: LooseObject = {};
        mConversationModel.updateCollect(actionData, res => {
            result.code = res.code;
            callback(result);
        });
    },

    /**
     * 模糊搜索，根据内容
     * @param actionData 参数
     * @return
     */
    searchMessageByContent(actionData, callback) {
        let smsPromise = new Promise((resolve, reject) => {
            this.searchSmsMessageByContent(actionData, res => {
                if (res.code === common.int.SUCCESS) {
                    resolve(res.response);
                } else {
                    reject(res.code);
                }
            });
        });
        // 信息列表搜索的数据
        let mmsPartPromise = new Promise((resolve, reject) => {
            this.searchMmsPartByContent(actionData, res => {
                if (res.code === common.int.SUCCESS) {
                    resolve(res.response);
                } else {
                    reject(res.code);
                }
            });
        });
        let result: LooseObject = {};
        Promise.all([smsPromise,mmsPartPromise]).then((res) => {
            result.code = common.int.SUCCESS;
            let resultList = [];
            resultList = resultList.concat(res[0]);
            resultList = resultList.concat(res[1]);
            result.response = this.dealMessageSort(resultList);
            callback(result);
        }).catch((err) => {
            HiLog.e(TAG, 'searchMessageByContent, error: ' + JSON.stringify(err.message));
            result.code = common.int.FAILURE;
            callback(result);
        });
    },
    dealMessageSort(resultList) {
        let favoriteList = [];
        let messageList = [];
        for(let item of resultList) {
            if(item.isFavorite) {
                favoriteList.push(item);
            } else {
                messageList.push(item);
            }
        }
        let response = [];
        // 收藏列表倒排
        if (favoriteList.length > 0) {
            // 倒排
            favoriteList.sort((a, b) => {
                return b.timeMillisecond - a.timeMillisecond
            });
            response = response.concat(favoriteList);
        }
        // 普通短信列表倒排
        if (messageList.length > 0) {
            // 倒排
            messageList.sort((a, b) => {
                return b.timeMillisecond - a.timeMillisecond
            })
            response = response.concat(messageList);
        }
        return response;
    },

    /**
     * 模糊搜索，根据内容
     * @param actionData 参数
     * @return
     */
    searchSmsMessageByContent(actionData, callback) {
        let searchText = actionData.inputValue;
        actionData.content = searchText;
        let result: LooseObject = {};
        // 这里需要掉用查询详情
        mConversationModel.searchSmsMessageByContent(actionData, res => {
            result.code = res.code;
            if (res.code == common.int.SUCCESS) {
                let telephones = [];
                let resultList = this.convertLikeConversation(res.abilityResult, searchText, telephones, new Map());
                this.dealContactsName(telephones, actionData, resultList, sessionList => {
                    result.response = sessionList;
                    callback(result);
                });
            } else {
                callback(result);
            }
        });
    },
    convertLikeConversation(mmsList, searchText, telephones, mmsPartMap) {
        let resultList = [];
        for (let item of mmsList) {
            let map: LooseObject = {};
            map.content = item.msgContent;
            if(mmsPartMap.has(item.msgId)) {
                map.content = mmsPartMap.get(item.msgId).content;
            }
            map.name = common.string.EMPTY_STR;
            map.telephone = item.receiverNumber;
            map.telephoneFormat = item.receiverNumber;
            if(item.isSender == 1) {
                map.telephone = item.senderNumber;
                map.telephoneFormat = item.senderNumber;
            }
            telephones.push(map.telephone);
            map.nameFormatter = map.name + '<' + map.telephoneFormat + '>';
            map.date = common.string.EMPTY_STR;
            map.time = common.string.EMPTY_STR;
            map.timeMillisecond = item.startTime;
            map.isFavorite = item.isCollect == 0 ? false : true;
            map.threadId = item.sessionId;
            if (item.smsType == 0) {
                map.icon = 'icon/user_avatar_full_fill.svg';
            } else {
                map.icon = 'icon/entrance_icon01.svg';
            }
            map.groupId = item.groupId;
            resultList.push(map);
        }
        return resultList;
    },
    dealContactsName(telephones, actionData, resultList, callback) {
        actionData.telephones = telephones;
        if (telephones.length == 0) {
            callback(resultList);
        }
        contractService.queryContactDataByTelephone(actionData, contacts => {
            let groupIdMap: LooseObject = {};
            if (contacts.length == 0) {
                groupIdMap = this.convertingMessageByGroup(resultList);
            } else {
                // 将结果转换为Map,key:手机号，value: 名称
                let telephoneMap = new Map();
                for (let item of contacts) {
                    if (item.displayName == common.string.EMPTY_STR) {
                        telephoneMap.set(item.detailInfo, item.detailInfo);
                    } else {
                        telephoneMap.set(item.detailInfo, item.displayName);
                    }
                }
                // 将结果根据手机号进行匹配
                groupIdMap = this.getGroupIdMap(resultList, telephoneMap);
            }
            let lists = [];
            let favoriteList = [];
            for (let key of Object.keys(groupIdMap)) {
                let value = groupIdMap[key];
                let contactsNums = value.telephone.split(common.string.COMMA);
                value.contactsNum = contactsNums.length;
                if (value.isFavorite) {
                    let temp = JSON.parse(JSON.stringify(value));
                    temp.icon = '/common/icon/icon_favorite.svg';
                    favoriteList.push(temp);
                    value.isFavorite = false;
                }
                lists.push(value);
            }
            // 将收藏的数据,放入到搜索的列表中
            if (favoriteList.length > 0) {
                lists = lists.concat(favoriteList);
            }
            callback(lists);
        });
    },
    getGroupIdMap(resultList, telephoneMap) {
        let groupIdMap: LooseObject = {};
        for (let map of resultList) {
            // 多人名称的组合,名称是需要组合展示
            if (telephoneMap.has(map.telephone)) {
                map.name = telephoneMap.get(map.telephone);
                map.nameFormatter = map.name + '<' + map.telephoneFormat + '>';
            } else {
                map.nameFormatter = map.telephoneFormat;
            }
            if (Object.keys(groupIdMap).indexOf(map.groupId) > -1) {
                let list = groupIdMap[map.groupId];
                list.name = list.name + common.string.COMMA + map.name;
                list.nameFormatter = list.nameFormatter + common.string.COMMA + map.nameFormatter;
                list.telephone = list.telephone + common.string.COMMA + map.telephone;
                list.telephoneFormat = list.telephoneFormat + common.string.COMMA + map.telephoneFormat;
            } else {
                groupIdMap[map.groupId] = map;
            }
        }
        return groupIdMap;
    },
    convertingMessageByGroup(resultList) {
        let groupIdMap: LooseObject = {};
        for (let element of resultList) {
            if (Object.keys(groupIdMap).indexOf(element.groupId) == -1) {
                groupIdMap[element.groupId] = element;
            }
        }
        return groupIdMap;
    },

    /**
     * 模糊搜索彩信，根据内容
     * @param actionData 参数
     * @return
     */
    searchMmsPartByContent(actionData, callback) {
        let searchText = actionData.inputValue;
        actionData.content = searchText;
        // 这里需要掉用查询详情
        let result: LooseObject = {};
        mConversationModel.searchMmsPartByContent(actionData, res => {
            result.code = res.code;
            if (res.code == common.int.SUCCESS) {
                let mmsPartMap = this.getMmsPartMap(res.abilityResult);
                actionData.msgIds = this.getMsgIds(mmsPartMap);
                if(actionData.msgIds.length == 0) {
                    result.response = [];
                    callback(result);
                    return;
                }
                this.buildMmsPartContacts(actionData, searchText, mmsPartMap, sessionList => {
                    result.response = sessionList;
                    callback(result);
                });
            } else {
                HiLog.w(TAG, 'searchMmsPartByContent, failed');
                callback(result);
            }
        });
    },
    buildMmsPartContacts(actionData, searchText, mmsPartMap, callback) {
        mConversationModel.queryMessageDetail(actionData, messageDetails => {
            let telephones = [];
            let mmsParts = messageDetails.abilityResult;
            let resultList = this.convertLikeConversation(mmsParts, searchText, telephones, mmsPartMap);
            this.dealContactsName(telephones, actionData, resultList, sessionList => {
                callback(sessionList);
            });
        });
    },
    getMmsPartMap(mmsParts) {
        let mmsPartMap = new Map();
        // 分组
        for (let element of mmsParts) {
            if (!mmsPartMap.has(element.msgId)) {
                mmsPartMap.set(element.msgId, element);
            }
        }
        return mmsPartMap;
    },
    getMsgIds(mmsPartMap) {
        let msgIds = [];
        for(let msgId of mmsPartMap.keys()) {
            msgIds.push(msgId);
        }
        return msgIds;
    },

    /**
     * 从图库中获取图片和视频
     * @param actionData 参数
     * @param callback 回调
     * @return
     */
    queryFromGallery(actionData, callback) {
        let result: LooseObject = {};
        mConversationModel.queryFromGallery(actionData, res => {
            result.code = res.code;
            result.pictureListFromGallery = res.abilityResult;
        });
        callback(result);
    },

    /**
     * 查询最近30天的短信
     * @param actionData 参数
     * @param callBack 回调
     * @return
     */
    queryMessageThirty(actionData, callBack) {
        let result: LooseObject = {};
        mConversationModel.queryMessageThirty(actionData, res => {
            result.code = res.code;
            if (res.code == common.int.SUCCESS) {
                result.response = res.abilityResult;
            } else {
                HiLog.w(TAG, 'queryMessageThirty, failed');
            }
            callBack(result);
        });
    },

    /**
     * 插入SIM卡中数据
     * @param actionData 参数
     * @param callback 回调
     */
    insertManageSimData(actionData, callback) {
        HiLog.i(TAG, 'insertManageSimData')
        let sendResults = actionData.sendResults;
        let value = this.dealSendResults(sendResults);
        // 先判断是否创建过会话列表
        conversationListService.querySessionByTelephone(value.telephone, res => {
            let response = res.response;
            if (res.code == common.int.SUCCESS && response.id < 0) {
                this.insertManageSimNoExiting(value, actionData, callback);
            } else {
                let sessionId = response.id;
                this.dealInsertMessageDetail(value, actionData, sessionId, res => {
                    let result = {
                        rowId: sessionId,
                        initDatas: res.initDatas,
                        groupId: res.groupId
                    }
                    callback(result);
                });
            }
        });
    },

    insertManageSimNoExiting(value, actionData, callback) {
        let valueBucket = {
            'telephone': value.telephone,
            'content': value.content,
            'contacts_num': value.contractsNum,
            'sms_type': value.smsType,
            'unread_count': 0,
            'sending_status': value.sendStatus,
            'has_draft': 0,
            'time': value.timestamp,
            'message_count': 1
        }
        conversationListService.insertSession(valueBucket, sessionResult => {
            // 这里调用短信数据库，插入短信信息
            this.dealInsertMessageDetail(value, actionData, sessionResult.rowId, res => {
                let result = {
                    rowId: sessionResult.rowId,
                    initDatas: res.initDatas,
                    groupId: res.groupId
                }
                callback(result);
            });
        });
    },

    /**
     * 统计未读通知个数
     * @param actionData
     * @param callback
     */
    statisticsUnreadNotify(actionData, callback) {
        mConversationModel.statisticsUnreadNotify(actionData, res => {
            if (res.code == common.int.SUCCESS) {
                callback(res.abilityResult);
            } else {
                HiLog.w(TAG,'statisticsUnreadNotify, failed');
                callback(0);
            }
        });
    },

    /**
     * 根据groupId 查询彩信的信息
     * @param actionData 条件
     * @param callback 返回值
     */
    queryMmsPartByIds(actionData, callback) {
        let result: LooseObject = {};
        mConversationModel.queryMmsPart(actionData, res => {
            result.code = res.code;
            if (res.code == common.int.SUCCESS) {
                result.response = res.abilityResult;
            } else {
                HiLog.w(TAG, 'queryMmsPartByIds, failed');
            }
            callback(result);
        });
    },

    /**
     * 根据SessionId获取锁的状态
     * @param actionData 参数
     * @param callback 返回信息内容
     * @return
     */
    queryMessageLockBySessionId(actionData, callback) {
        let result: LooseObject = {};
        HiLog.i(TAG, 'queryMessageLockBySessionId');
        mConversationModel.queryMessageLockBySessionId(actionData, res => {
            result.code = res.code;
            if (res.code == common.int.SUCCESS) {
                callback(res.abilityResult);
            } else {
                HiLog.w(TAG, 'queryMessageLockBySessionId, failed');
                callback(result);
            }
        });
    },
}