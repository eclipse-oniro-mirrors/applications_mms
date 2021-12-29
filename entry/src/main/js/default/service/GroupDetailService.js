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

import GroupDetailImplModel from '../model/groupDetailImpl/GroupDetailImplModel.js'

const groupDetailImplModel = new GroupDetailImplModel();
import common from '../pages/common_constants.js';
import mmsLog from '../utils//MmsLog.js';
import contractService from '../service/ContractService.js';
import conversationListService from '../service/ConversationListService.js';

const TAG = 'GroupDetailService ->';

export default {

    /**
     * 判断是否需要全部重新发送
     * @param contactList 发送短信的列表
     * @param callback 回调函数
     * @return
     */
    judgeIsAllSendFail(contactList, callback) {
        let count = 0;
        let isAllSendFail = false;
        for (let element of contactList) {
            if (element.sendStatus == 2) {
                isAllSendFail = true;
            } else {
                count++;
            }
        }
        if (count == contactList.length) {
            isAllSendFail = false;
        }
        callback(isAllSendFail);
    },

    /**
     * 查询详情的相关数据列表
     * @param isDetail 是否查询详情
     * @param actionData groupId/threadId
     * @param callback 回调函数
     * @return
     */
    queryContactSendDetail(isDetail, actionData, callback) {
        if (isDetail) {
            this.queryGroupDetail(actionData, res => {
                callback(res);
            });
        } else {
            this.queryRecipients(actionData, res => {
                callback(res);
            });
        }
    },
    queryGroupDetail(actionData, callback) {
        let result = {};
        mmsLog.log(TAG + 'queryGroupDetail start');
        groupDetailImplModel.queryGroupDetail(actionData, res => {
            mmsLog.log(TAG + 'groupDetailByParams Success');
            result.code = res.code;
            if (res.code == common.int.SUCCESS) {
                let telephones = [];
                result.contactList = this.dealGroupDetail(res.abilityResult, telephones);
                this.dealContactsName(telephones, actionData, result.contactList, contactList => {
                    result.contactList = contactList;
                    callback(result);
                });
            } else {
                mmsLog.info(TAG + 'Error: queryContactSendDetail failed !!!');
            }
            callback(result);
        });
    },
    queryRecipients(actionData, callback) {
        let result = {};
        let rdbStore = actionData.rdbStore;
        let threadId = actionData.threadId;
        mmsLog.log(TAG + 'querySessionById start');
        conversationListService.querySessionById(rdbStore, threadId, res => {
            result.code = res.code;
            if (res.code == common.int.SUCCESS && res.response.telephone != common.string.EMPTY_STR) {
                let telephones = res.response.telephone.split(common.string.COMMA);
                let contactList = [];
                for (let telephone of telephones) {
                    let recipient = {};
                    recipient.contactName = common.string.EMPTY_STR;
                    recipient.telephone = telephone;
                    recipient.telephoneFormat = telephone;
                    contactList.push(recipient);
                }
                this.dealContactsName(telephones, actionData, contactList, contactList => {
                    result.contactList = contactList;
                    callback(result);
                });
            }
        });
    },
    dealGroupDetail(groupDetails, telephones) {
        let results = [];
        for (let groupDetail of groupDetails) {
            let item = {};
            item.contactName = common.string.EMPTY_STR;
            item.date = common.string.EMPTY_STR;
            item.time = common.string.EMPTY_STR;
            if (groupDetail.msgState == 0) {
                item.sendStatus = common.int.SEND_MESSAGE_SUCCESS;
            } else if (groupDetail.msgState == 1) {
                item.sendStatus = common.int.SEND_MESSAGE_FAILED;
            } else {
                item.sendStatus = common.int.SEND_MESSAGE_SENDING;
            }
            telephones.push(groupDetail.receiverNumber);
            item.telephone = groupDetail.receiverNumber;
            item.telephoneFormat = groupDetail.receiverNumber;
            item.timeMillisecond = groupDetail.startTime;
            item.id = groupDetail.msgId;
            results.push(item);
        }
        return results;
    },
    dealContactsName(telephones, actionData, contactList, callback) {
        actionData.telephones = telephones;
        if (telephones.length == 0) {
            callback(contactList);
        }
        contractService.queryContactDataByTelephone(actionData, contacts => {
            if (contacts.length == 0) {
                callback(contactList);
            }
            // 将结果转换为Map,key:手机号，value: 名称
            let telephoneMap = new Map();
            for (let item of contacts) {
                telephoneMap.set(item.detailInfo, item.displayName);
            }
            // 将结果根据手机号进行匹配
            for (let session of contactList) {
                if (telephoneMap.has(session.telephone)) {
                    session.contactName = telephoneMap.get(session.telephone);
                }
            }
            callback(contactList);
        });
    },
}