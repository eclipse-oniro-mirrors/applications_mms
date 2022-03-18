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

// log 工具类
import HiLog from '../utils/HiLog';
// 公共常量
import common from '../data/commonData';

// 获取假数据
import ConversationListModel from '../model/ConversationListModel';

let conversationListModel = new ConversationListModel();
import conversationService from './ConversationService';
import contractService from './ContractService';
import commonService from './CommonService';
import telephoneUtils from '../utils/TelephoneUtil';
import LooseObject from '../data/LooseObject'

const TAG = 'ConversationListService';

export default {
    /**
     * 查询列表数据
     * @param actionData 查询参数
     * @param tableName 表明
     * @return
     */
    querySessionList(actionData, callback) {
        // 查询数据列表
        let result: LooseObject = {};
        let queryPromise = conversationListModel.querySessionList(actionData);
        // 获取总的条数
        let countPromise = conversationListModel.countSessionList(actionData);
        // 判断通知信息是否存在
        let notificationPromise = new Promise((resolve) => {
            this.judgeIsNotificationData(res => {
                resolve(res);
            });
        });
        Promise.all([queryPromise, countPromise, notificationPromise]).then((res) => {
            result.code = common.int.SUCCESS;
            let telephones = [];
            let messageList = this.convertSessionList(res[0].response, telephones);
            result.total = res[1].total;
            result.showInfoDivWhenSearchFlag = res[2];
            this.dealContactsName(telephones, actionData, messageList, sessionList => {
                result.response = sessionList;
                HiLog.i(TAG, 'querySessionList, dealContactsName callback');
                callback(result);
            });
        }).catch((err) => {
            HiLog.e(TAG, 'querySessionList, error: ' + JSON.stringify(err.message));
            result.code = common.int.FAILURE;
            callback(result);
        });
    },
    convertSessionList(sessionList, telephones) {
        let messageList = [];
        for (let session of sessionList) {
            let item: LooseObject = {};
            item.name = common.string.EMPTY_STR;
            item.contactsNum = session.contactsNum;
            item.content = session.content;
            item.countOfUnread = session.unreadCount;
            if (session.smsType == 0) {
                item.icon = 'icon/user_avatar_full_fill.svg';
            } else {
                item.icon = 'icon/entrance_icon01.svg';
            }
            item.isCbChecked = false;
            item.isLock = false;
            item.sendingFailed = session.sendStatus == common.int.SEND_MESSAGE_FAILED ? true : false;
            item.telephone = session.telephone;
            if (item.contactsNum > 1) {
                let telephoneSplit = item.telephone.split(common.string.COMMA);
                for (let item of telephoneSplit) {
                    telephones.push(item);
                }
            } else {
                telephones.push(item.telephone);
            }
            item.telephoneFormat = session.telephoneFormat;
            item.threadId = session.id;
            item.timeMillisecond = session.time;
            item.isDraft = session.hasDraft == 1 ? true : false;
            item.isLock = session.hasLock == 1 ? true : false;
            item.time = common.string.EMPTY_STR;
            item.messageCount = session.messageCount;
            item.hasMms = session.hasMms == 1 ? true : false;
            item.hasAttachment = session.hasAttachment == 1 ? true : false;
            messageList.push(item);
        }
        return messageList;
    },
    dealContactsName(telephones, actionData, sessionLists, callback) {
        actionData.telephones = telephones;
        if(telephones.length == 0) {
            callback(sessionLists);
            return;
        }
        contractService.queryContactDataByTelephone(actionData, contacts => {
            if(contacts.length == 0) {
                callback(sessionLists);
            } else {
                // 将结果转换为Map,key:手机号，value: 名称
                let telephoneMap = this.getTelephoneMap(contacts);
                this.buildName(sessionLists, telephoneMap);
                callback(sessionLists);
            }
        });
    },
    getTelephoneMap(contacts) {
        let telephoneMap = new Map();
        for(let item of contacts) {
            if (item.displayName == common.string.EMPTY_STR) {
                telephoneMap.set(item.detailInfo, item.detailInfo);
            } else {
                telephoneMap.set(item.detailInfo, item.displayName);
            }
        }
        return telephoneMap;
    },
    buildName(sessionLists, telephoneMap) {
        // 将结果根据手机号进行匹配
        for (let session of sessionLists) {
            // 多人名称的组合,名称是需要组合展示
            if (session.contactsNum > 1) {
                this.dealMultiName(session, telephoneMap);
            } else if (telephoneMap.has(session.telephone)) {
                session.name = telephoneMap.get(session.telephone);
            }
        }
    },
    dealMultiName(session, telephoneMap) {
        let telephones = session.telephone.split(common.string.COMMA);
        let name = common.string.EMPTY_STR;
        for(let telephone of telephones) {
            if(telephoneMap.has(telephone)) {
                name = name + telephoneMap.get(telephone) + common.string.COMMA;
            } else {
                name = name + telephone + common.string.COMMA;
            }
        }
        session.name = name.substring(0, name.length - 1);
    },

    /**
     * 判断是否存在通知信息的数据
     * @param callback 返回
     */
    judgeIsNotificationData(callback) {
        let param = {
            numberType: 1,
            limit: 1,
            page: 1
        };
        this.querySessionByNumberType(param, res => {
            if(res.code == common.int.SUCCESS && res.response.length > 0) {
                callback(true);
            } else {
                callback(false);
            }
        });
    },

    /**
     * 统计数据
     * @param actionData 参数
     * @param callBack 回调
     * @return
     */
    statisticalData(actionData, callBack) {
        let normalPromise = new Promise<LooseObject>((resolve) => {
            conversationListModel.statisticalData(actionData, res => {
                let result: LooseObject = {};
                result.code = res.code;
                if (res.code == common.int.SUCCESS) {
                    result.response = res.abilityResult;
                    resolve(result.response);
                } else {
                    HiLog.w(TAG, 'statisticalData, failed');
                }
            });
        });
        let notifyPromise = new Promise<number>((resolve) => {
            conversationService.statisticsUnreadNotify(actionData, res => {
                resolve(res);
            });
        });
        Promise.all([normalPromise, notifyPromise]).then(res => {
            let normalResult = res[0];
            let notifyResult = res[1];
            let response = {
                'totalListCount': normalResult.totalListCount,
                'unreadCount': (normalResult.totalListCount - notifyResult),
                'unreadTotalOfInfo': notifyResult
            }
            let result = {
                code: common.int.SUCCESS,
                response: response
            }
            callBack(result);
        }).then(err => {
            HiLog.e(TAG, 'statisticalData, failed: ' + JSON.stringify(err));
            let result = {
                code: common.int.FAILURE
            }
            callBack(result);
        });

    },

    /**
     * 根据主键ID,删除数据
     * @param threadIds 会话ID
     * @return
     */
    deleteMessageById(actionData) {
        // 删除会话列表的数据
        conversationListModel.deleteMessageById(actionData.threadIds);
        // 删除信息列表的数据
        conversationService.deleteMessageBySessionIds(actionData);
    },

    /**
     * 根据主键ID,删除数据
     * @param threadIds 会话ID
     */
    deleteMessageBySessionId(threadIds) {
        // 删除会话列表的数据
        conversationListModel.deleteMessageById(threadIds);
    },

    /**
     * 根据主键ID,更新数据
     * @param threadIds 会话ID
     * @return
     */
    updateById(threadIds, valueBucket) {
        conversationListModel.updateById(threadIds, valueBucket);
    },

    /**
     * 标记已读短信
     * @param threadIds 会话ID
     * @param valueBucket 标记已读的数量
     * @return
     */
    markAllAsRead(actionData) {
        if(actionData.threadIds.length == 0) {
            return;
        }
        // 会话列表上的标记已读
        conversationListModel.markAllAsRead(actionData.threadIds, actionData.valueBucket);
        // 短信信息的已读
        conversationService.markAllAsRead(actionData);
    },

    /**
     * 更新所有未读信息为已读
     * @param actionData
     */
    markAllToRead(actionData) {
        conversationListModel.markAllToRead(actionData.smsType);
        conversationService.markAllToRead(actionData);
    },

    /**
     * 新增会话列表
     * @param valueBucket 新增的数据
     * @param callback 回调
     * @return
     */
    insertSession(valueBucket, callback) {
        conversationListModel.insertSession(common.tableName.SESSION, valueBucket, res => {
            callback(res);
        });
    },

    /**
     * 新增会话草稿列表
     * @param valueBucket 新增的数据
     * @param callback 回调
     * @return
     */
    insertSessionDraft(actionData) {
        let param = this.dealSendResults(actionData);
        // 先判断是否创建过会话列表
        this.querySessionByTelephone(param.telephone, res => {
            let response = res.response;
            if(res.code == common.int.SUCCESS && response.id <= 0) {
                this.dealInsertSession(param, actionData);
            } else {
                this.deleteDraftDataOrUpdate(actionData, response, param);
            }
        });
    },
    dealInsertSession(param, actionData) {
        let valueBucket = {
            'telephone': param.telephone,
            'content': param.content,
            'contacts_num': param.contractsNum,
            'sms_type': param.smsType,
            'unread_count': 0,
            'sending_status': 1,
            'has_draft': 1,
            'time': param.timestamp,
            'has_mms': param.hasMms,
            'has_attachment': param.hasAttachment,
        }
        this.insertSession(valueBucket, sessionResult => {
            // 这里调用短信数据库，插入短信信息
            let sessionId = sessionResult.rowId;
            conversationService.dealInsertMessageDetail(param, actionData, sessionId, res => {
            });
        });
    },
    deleteDraftDataOrUpdate(actionData, response, param) {
        if(actionData.groupId > 0) {
            let groupIds = [actionData.groupId];
            actionData.groupIds = groupIds;
            // 先删除原来的草稿
            conversationService.deleteMessageByGroupIds(actionData);
        }
        if(actionData.content != common.string.EMPTY_STR || actionData.mmsSource.length > 0) {
            // 存入新的草稿
            this.updateDraftData(response, param, actionData);
        }
    },
    updateDraftData(response, param ,actionData) {
        let sessionId = response.id;
        // 这里调用短信数据库，插入短信信息
        let threadIds = [sessionId];
        let time = new Date();
        let valueBucket = {
            'content': param.content,
            'has_draft': 1,
            'time': time.getTime(),
            'has_attachment': param.hasAttachment,
            'has_mms': param.hasMms,
        }
        this.updateById(threadIds, valueBucket);
        conversationService.dealInsertMessageDetail(param, actionData, sessionId, res => {
        });
    },
    dealSendResults(actionData) {
        let contractsNum = 1;
        let telephone = common.string.EMPTY_STR;
        if(actionData.isNewMsg) {
            let selectContacts = actionData.selectContacts;
            if(selectContacts.length > 1) {
                for(let contact of selectContacts) {
                    telephone = telephone + contact.telephone + common.string.COMMA;
                }
                // 如果失败，那会话列表结果就是失败
                telephone = telephone.substring(0, telephone.length-1);
                contractsNum = selectContacts.length;
            } else if (selectContacts.length == 1) {
                telephone = selectContacts[0].telephone;
            }
            let receiveContactValue = actionData.receiveContactValue;
            if(receiveContactValue != common.string.EMPTY_STR) {
                telephone = actionData.receiveContactValue;
            }
        } else {
            telephone = actionData.telephone;
        }
        let smsType = 0;
        if(contractsNum == 1 && telephoneUtils.judgeIsInfoMsg(telephone)) {
            smsType = 1;
        }
        let sendResult = {
            telephone: telephone,
            content: actionData.content,
            sendStatus: common.int.SEND_DRAFT
        }
        actionData.sendResults = [sendResult];
        let timestamp = new Date().getTime();
        let result: LooseObject = {};
        result.contractsNum = contractsNum;
        result.telephone = telephoneUtils.dealTelephoneSort(telephone);
        result.content = actionData.content;
        if(actionData.isMms) {
            result.content = commonService.getMmsContent(actionData.mmsSource);
        }
        result.sendStatus = 1;
        result.smsType = smsType;
        result.timestamp = timestamp;
        result.hasMms = actionData.isMms ? 1 : 0;
        result.hasAttachment = actionData.hasAttachment ? 1 : 0;
        return result;
    },

    /**
     * 根据手机号查询会话列表
     * @param telephone 手机号
     * @return
     */
    querySessionByNumberType(actionData, callback) {
        let result: LooseObject = {};
        let queryPromise = conversationListModel.querySessionList(actionData);
        Promise.all([queryPromise]).then((res) => {
            result.code = common.int.SUCCESS;
            result.response = res[0].response;
            callback(result);
        }).catch((err) => {
            HiLog.e(TAG, 'querySessionByNumberType, error: ' + JSON.stringify(err.message));
            result.code = common.int.FAILURE;
            callback(result);
        });
    },

    /**
     * 根据手机号查询会话列表
     * @param telephone 手机号
     * @return
     */
    querySessionByTelephone(telephone, callback) {
        let result: LooseObject = {};
        if(telephone == null) {
            HiLog.w(TAG, 'querySessionByTelephone, telephone == null')
            result.code = common.int.FAILURE;
            callback(result);
        } else {
            HiLog.i(TAG, 'querySessionByTelephone, telephone != null')
            let queryPromise = conversationListModel.querySessionByTelephone(telephone);
            Promise.all([queryPromise]).then((res) => {
                result.code = common.int.SUCCESS;
                result.response = res[0];
                callback(result);
            }).catch((err) => {
                HiLog.e(TAG, ', querySessionByTelephone, error: ' + JSON.stringify(err.message));
                result.code = common.int.FAILURE;
                callback(result);
            });
        }
    },

    /**
     * 根据手机号查询会话列表
     * @param telephone 手机号
     * @return
     */
    querySessionById(threadId, callback) {
        let result: LooseObject = {};
        HiLog.i(TAG, 'querySessionById, threadId:' + threadId);
        let queryPromise = conversationListModel.querySessionById(threadId);
        Promise.all([queryPromise]).then((res) => {
            result.code = common.int.SUCCESS;
            result.response = res[0];
            callback(result);
        }).catch((err) => {
            HiLog.e(TAG, 'querySessionById, error: ' + JSON.stringify(err.message));
            result.code = common.int.FAILURE;
            callback(result);
        });
    },
    deleteMessageBySessionIdsAndLock(actionData) {
        conversationService.deleteMessageBySessionIdsAndLock(actionData);
    },
    dealMessageLockContent(actionData, callback) {
        let threadIds = actionData.threadIds;
        let length = threadIds.length;
        let count = 0;
        for (let id of threadIds) {
            actionData.threadId = id;
            if (!actionData.isMessageDetail) {
                actionData.hasLock = 1;
            }
            conversationService.queryMessageDetail(actionData, res => {
                if (res.code == common.int.SUCCESS && res.response.length > 0) {
                    count ++;
                    actionData.mmsList = res.response;
                    this.updateLastItemContent(actionData);
                }
                if (count == length) {
                    callback(common.int.SUCCESS);
                }
            });
        }
    },
    updateLastItemContent(actionData) {
        let length = actionData.mmsList.length;
        let item = actionData.mmsList[length - 1];
        let content = item.content;
        let threadIds = [actionData.threadId];
        let hasAttachment = false;
        if (item.isMsm) {
            content = commonService.getMmsContent(item.mms);
            hasAttachment = true;
        }
        let valueBucket = {
            'content': content,
            'sending_status': item.sendStatus,
            'has_mms': item.isMsm ? 1 : 0,
            'has_attachment': hasAttachment ? 1 : 0,
            'message_count': length,
            'unread_count': 0
        };
        this.updateById(threadIds, valueBucket);
    },
    /**
     * 搜索
     * @param actionData 参数
     * @param callback 回调
     * @return
     */
    searchMessageWithLike(actionData, callback) {
        // 会话详情搜索数据
        let searchText = actionData.inputValue;
        let sessionListPromise = new Promise((resolve, reject) => {
            this.searchSessionByTelephone(actionData, res => {
                if (res.code === common.int.SUCCESS) {
                    resolve(res.response);
                } else {
                    reject(res.code);
                }
            });
        });
        // 信息列表搜索的数据
        let contentListPromise = new Promise((resolve, reject) => {
            conversationService.searchMessageByContent(actionData, res => {
                if (res.code === common.int.SUCCESS) {
                    resolve(res.response);
                } else {
                    reject(res.code);
                }
            });
        });
        let resultMap: LooseObject = {};
        let result: LooseObject = {};
        Promise.all([sessionListPromise,contentListPromise]).then((res) => {
            result.code = common.int.SUCCESS;
            resultMap.sessionList = res[0];
            resultMap.contentList = res[1];
            result.resultMap = resultMap;
            result.search = searchText;
            callback(result);
        }).catch((err) => {
            HiLog.e(TAG, 'searchMessageWithLike, error: ' + JSON.stringify(err.message));
            result.code = common.int.FAILURE;
            callback(result);
        });
    },

    /**
     * 根据手机号模糊匹配会话列表
     * @param actionData 数据库实例
     */
    async searchSessionByTelephone(actionData, callback) {
        let result: LooseObject = {};
        let telephone = actionData.inputValue;
        let numberType = actionData.numberType;
        let queryPromise = conversationListModel.searchSessionByTelephone(telephone, numberType);
        queryPromise.then((res) => {
            result.code = common.int.SUCCESS;
            let telephones = [];
            let messageList = this.convertSessionList(res, telephones);
            this.dealContactsName(telephones, actionData, messageList, sessionList => {
                result.response = this.dealSessionLikeData(sessionList);
                callback(result);
            });
        }).catch((err) => {
            HiLog.e(TAG, 'searchSessionByTelephone, error: ' + JSON.stringify(err.message));
            result.code = common.int.FAILURE;
            callback(result);
        });
    },
    dealSessionLikeData(mmList) {
        let sessionList = [];
        for (let item of mmList) {
            let map: LooseObject = {}
            map.name = item.name;
            map.threadId = item.threadId;
            map.telephone = item.telephone;
            map.telephoneFormat = item.telephoneFormat;
            map.contactsNum = item.contactsNum;
            map.isDraft = item.isDraft;
            let names = item.name.split(common.string.COMMA);
            let telephones = item.telephone.split(common.string.COMMA);
            let telephoneFormats = item.telephoneFormat.split(common.string.COMMA);
            let nameFormatter = common.string.EMPTY_STR;
            let index = 0;
            for (let name of names) {
                nameFormatter += (name == null || name == common.string.EMPTY_STR ? telephones[index] : name);
                nameFormatter += '<';
                nameFormatter += telephoneFormats[index];
                nameFormatter += '>';
                if (index < telephones.length - 1) {
                    nameFormatter += common.string.COMMA;
                }
                index++;
            }
            map.nameFormatter = nameFormatter;
            map.date = common.string.EMPTY_STR;
            map.time = common.string.EMPTY_STR;
            map.timeMillisecond = item.timeMillisecond;
            map.size = item.messageCount;
            map.icon = item.icon;
            sessionList.push(map);
        }
        return sessionList;
    }
}