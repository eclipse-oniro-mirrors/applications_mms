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

import HiLog from "../utils/HiLog";
import common from "../data/commonData";
import ConversationListModel from "../model/ConversationListModel";
import conversationService from "./ConversationService";
import contractService from "./ContractService";
import commonService from "./CommonService";
import telephoneUtils from "../utils/TelephoneUtil";
import LooseObject from "../data/LooseObject"

let conversationListModel = new ConversationListModel();
const TAG = "ConversationListService";

export default {
    /**
     * Querying list data
     *
     * @param actionData
     * @callback callback
     */
    querySessionList(actionData, callback) {
        // Querying Data Lists
        let result: LooseObject = {};
        let queryPromise = conversationListModel.querySessionList(actionData);
        // Obtains the total number of records.
        let countPromise = conversationListModel.countSessionList(actionData);
        // Check whether the notification information exists.
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
            result.hasInfoMsg = res[2];
            HiLog.i(TAG, "querySessionList, messageList length=" + messageList.length
            + ", total=" + result.total + ", hasInfoMsg=" + result.hasInfoMsg);
            this.dealContactsName(telephones, actionData, messageList, sessionList => {
                HiLog.i(TAG, "querySessionList, dealContactsName len=" + sessionList.length);
                result.response = sessionList;
                callback(result);
            });
        }).catch((err) => {
            HiLog.e(TAG, "querySessionList, error: " + JSON.stringify(err.message));
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
                item.icon = "icon/user_avatar_full_fill.svg";
            } else {
                item.icon = "icon/entrance_icon01.svg";
            }
            item.smsType = session.smsType;
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
        if (telephones.length == 0) {
            HiLog.w(TAG, "dealContactsName, has no telephones");
            callback(sessionLists);
            return;
        }
        contractService.queryContactDataByTelephone(actionData, contacts => {
            if (contacts.length == 0) {
                HiLog.w(TAG, "dealContactsName, has no contacts");
                callback(sessionLists);
            } else {
                // Convert the result to Map, key: mobile number, value: name
                let telephoneMap = this.getTelephoneMap(contacts);
                this.buildName(sessionLists, telephoneMap);
                callback(sessionLists);
            }
        });
    },

    getTelephoneMap(contacts) {
        let telephoneMap = new Map();
        for (let item of contacts) {
            if (item.displayName == common.string.EMPTY_STR) {
                telephoneMap.set(item.detailInfo, item.detailInfo);
            } else {
                telephoneMap.set(item.detailInfo, item.displayName);
            }
        }
        return telephoneMap;
    },

    buildName(sessionLists, telephoneMap) {
        // Match the result based on the mobile number.
        for (let session of sessionLists) {
            // Indicates the combination of multiple names. The names need to be displayed in combination.
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
        for (let telephone of telephones) {
            if (telephoneMap.has(telephone)) {
                name = name + telephoneMap.get(telephone) + common.string.COMMA;
            } else {
                name = name + telephone + common.string.COMMA;
            }
        }
        session.name = name.substring(0, name.length - 1);
    },

    /**
     * Check whether notification data exists.
     *
     * @callback callback
     */
    judgeIsNotificationData(callback) {
        let param = {
            numberType: 1,
            limit: 1,
            page: 1
        };
        this.querySessionByNumberType(param, res => {
            if (res.code == common.int.SUCCESS && res.response.length > 0) {
                callback(true);
            } else {
                callback(false);
            }
        });
    },

    /**
     * statistical data
     *
     * @param actionData
     * @callBack callBack
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
                    HiLog.w(TAG, "statisticalData, failed");
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
                "totalListCount": normalResult.totalListCount,
                "unreadCount": (normalResult.totalListCount - notifyResult),
                "unreadTotalOfInfo": notifyResult
            }
            let result = {
                code: common.int.SUCCESS,
                response: response
            }
            callBack(result);
        }).catch(err => {
            HiLog.e(TAG, "statisticalData, failed: " + JSON.stringify(err));
            let result = {
                code: common.int.FAILURE
            }
            callBack(result);
        });
    },

    /**
     * Delete data based on the primary key id.
     *
     * @param threadIds Session ID
     */
    deleteMessageById(actionData) {
        // Deletes data from the session list.
        conversationListModel.deleteMessageById(actionData.threadIds);
        // Deletes data from the information list.
        conversationService.deleteMessageBySessionIds(actionData);
    },

    /**
     * Delete data based on the primary key id.
     *
     * @param threadIds Session ID
     */
    deleteMessageBySessionId(threadIds) {
        // Deletes data from the session list.
        conversationListModel.deleteMessageById(threadIds);
        globalThis.needToUpdate = true;
    },

    /**
     * Update data based on the primary key id.
     *
     * @param threadIds Session ID
     * @param valueBucket
     */
    updateById(threadIds, valueBucket) {
        conversationListModel.updateById(threadIds, valueBucket);
        globalThis.needToUpdate = true;
    },

    /**
     * Marking a read SMS message
     *
     * @param actionData
     */
    markAllAsRead(actionData) {
        if (actionData.threadIds.length == 0) {
            return;
        }
        // Tag on session list read
        conversationListModel.markAllAsRead(actionData.threadIds, actionData.valueBucket);
        // SMS message read
        conversationService.markAllAsRead(actionData);
    },

    /**
     * Updates all unread information to read.
     *
     * @param actionData
     */
    markAllToRead(actionData) {
        conversationListModel.markAllToRead(actionData.smsType);
        conversationService.markAllToRead(actionData);
    },

    /**
     * Add a new session list
     *
     * @param valueBucket New data
     * @callback callback
     */
    insertSession(valueBucket, callback) {
        conversationListModel.insertSession(valueBucket, res => {
            callback(res);
        });
    },

    /**
     * Adding a session draft list
     *
     * @param valueBucket New Data
     * @callback callback
     */
    insertSessionDraft(actionData, callback) {
        let param = this.dealSendResults(actionData);
        // Check whether a session list has been created
        this.querySessionByTelephone(param.telephone, res => {
            let response = res.response;
            if(res.code == common.int.SUCCESS && response.id <= 0) {
                // If you modify the recipient in draft state and save the modification again, you need to delete the
                // unnecessary session draft before modification.
                if (actionData.threadId != 0) {
                    conversationListModel.deleteMessageById([actionData.threadId]);
                }
                this.dealInsertSession(param, actionData, callback);
            } else {
                this.deleteDraftDataOrUpdate(actionData, response, param, callback);
            }
            globalThis.needToUpdate = true;
        });
    },

    dealInsertSession(param, actionData, callback) {
        let valueBucket = {
            "telephone": param.telephone,
            "content": param.content,
            "contacts_num": param.contractsNum,
            "sms_type": param.smsType,
            "unread_count": 0,
            "sending_status": 1,
            "has_draft": 1,
            "time": param.timestamp,
            "has_mms": param.hasMms,
            "has_attachment": param.hasAttachment,
        }
        this.insertSession(valueBucket, sessionResult => {
            // Invoke the SMS database to insert SMS messages.
            let sessionId = sessionResult.rowId;
            conversationService.dealInsertMessageDetail(param, actionData, sessionId, res => {
                callback();
            });
        });
    },

    deleteDraftDataOrUpdate(actionData, response, param, callback) {
        if (actionData.groupId > 0) {
            let groupIds = [actionData.groupId];
            actionData.groupIds = groupIds;
            // Delete the original draft first.
            conversationService.deleteMessageByGroupIds(actionData);
        }
        if (actionData.content != common.string.EMPTY_STR || actionData.mmsSource.length > 0) {
            // Save New Draft
            this.updateDraftData(response, param, actionData, callback);
        } else {
            callback();
        }
    },

    updateDraftData(response, param, actionData, callback) {
        let sessionId = response.id;
        // Invoke the SMS database to insert SMS messages.
        let threadIds = [sessionId];
        let time = new Date();
        let valueBucket = {
            "content": param.content,
            "has_draft": 1,
            "time": time.getTime(),
            "has_attachment": param.hasAttachment,
            "has_mms": param.hasMms,
        }
        this.updateById(threadIds, valueBucket);
        conversationService.dealInsertMessageDetail(param, actionData, sessionId, res => {
            callback();
        });
    },

    dealSendResults(actionData) {
        let contractsNum = 1;
        let telephone = common.string.EMPTY_STR;
        if (actionData.isNewMsg) {
            let selectContacts = actionData.selectContacts;
            if (selectContacts.length > 1) {
                for (let contact of selectContacts) {
                    telephone = telephone + contact.telephone + common.string.COMMA;
                }
                // If it fails, then the session list turns out to be a failure.
                telephone = telephone.substring(0, telephone.length - 1);
                contractsNum = selectContacts.length;
            } else if (selectContacts.length == 1) {
                telephone = selectContacts[0]?.telephone;
            }
            let receiveContactValue = actionData.receiveContactValue;
            if (receiveContactValue != common.string.EMPTY_STR) {
                telephone = actionData.receiveContactValue;
            }
        } else {
            telephone = actionData.telephone;
        }
        let smsType = 0;
        if (contractsNum == 1 && telephoneUtils.judgeIsInfoMsg(telephone)) {
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
        if (actionData.isMms) {
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
     * Querying the session list by mobile number
     *
     * @param actionData
     * @callback callback
     */
    querySessionByNumberType(actionData, callback) {
        let result: LooseObject = {};
        let queryPromise = conversationListModel.querySessionList(actionData);
        Promise.all([queryPromise]).then((res) => {
            result.code = common.int.SUCCESS;
            result.response = res[0].response;
            HiLog.i(TAG, "querySessionList SUCCESS. len=" + result.response.length);
            callback(result);
        }).catch((err) => {
            HiLog.e(TAG, "querySessionByNumberType, error: " + JSON.stringify(err.message));
            result.code = common.int.FAILURE;
            callback(result);
        });
    },

    /**
     * Querying the session list by mobile number
     *
     * @param telephone
     * @callback callback
     */
    querySessionByTelephone(telephone, callback) {
        let result: LooseObject = {};
        if (telephone == null) {
            HiLog.w(TAG, "querySesByTele, telephone == null")
            result.code = common.int.FAILURE;
            callback(result);
        } else {
            HiLog.i(TAG, "querySesByTele, telephone != null")
            let queryPromise = conversationListModel.querySessionByTelephone(telephone);
            Promise.all([queryPromise]).then((res) => {
                result.code = common.int.SUCCESS;
                result.response = res[0];
                callback(result);
            }).catch((err) => {
                HiLog.e(TAG, "querySesByTele, error: " + JSON.stringify(err.message));
                result.code = common.int.FAILURE;
                callback(result);
            });
        }
    },

    /**
     * Querying the session list by mobile number
     *
     * @param telephone
     * @callback callback
     */
    querySessionById(threadId, callback) {
        let result: LooseObject = {};
        HiLog.i(TAG, "querySessionById, threadId:" + threadId);
        let queryPromise = conversationListModel.querySessionById(threadId);
        Promise.all([queryPromise]).then((res) => {
            result.code = common.int.SUCCESS;
            result.response = res[0];
            callback(result);
        }).catch((err) => {
            HiLog.e(TAG, "querySessionById, error: " + JSON.stringify(err.message));
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
                    count++;
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
        let content = item.content || '';
        let threadIds = [actionData.threadId];
        let hasAttachment = false;
        if (item.isMsm) {
            content = commonService.getMmsContent(item.mms);
            hasAttachment = true;
        }
        let valueBucket = {
            "content": content,
            "sending_status": item.sendStatus,
            "has_mms": item.isMsm ? 1 : 0,
            "has_attachment": hasAttachment ? 1 : 0,
            "message_count": length,
            "unread_count": 0
        };
        this.updateById(threadIds, valueBucket);
    },

    /**
     * Search message with text
     *
     * @param actionData
     * @callback callback
     */
    searchMessageWithLike(actionData, callback) {
        // Session Details Search Data
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
        // Information List Search Data
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
        Promise.all([sessionListPromise, contentListPromise]).then((res) => {
            result.code = common.int.SUCCESS;
            resultMap.sessionList = res[0];
            resultMap.contentList = res[1];
            result.resultMap = resultMap;
            result.search = searchText;
            callback(result);
        }).catch((err) => {
            HiLog.e(TAG, "searchMessageWithLike, error: " + JSON.stringify(err.message));
            result.code = common.int.FAILURE;
            callback(result);
        });
    },

    /**
     * Fuzzy match of the session list based on the mobile number
     *
     * @param actionData
     * @callback callback
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
            HiLog.e(TAG, "searchSessionByTelephone, error: " + JSON.stringify(err.message));
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
                nameFormatter += "<";
                nameFormatter += telephoneFormats[index];
                nameFormatter += ">";
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