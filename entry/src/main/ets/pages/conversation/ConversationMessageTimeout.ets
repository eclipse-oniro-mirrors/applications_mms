/**
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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

import { commonEventManager } from '@kit.BasicServicesKit';
import HiLog from '../../utils/HiLog';
import ConversationController, { BaseItemType, mmsListType } from './conversationController';
import common from '../../data/commonData';
import { AsyncCallback, BusinessError } from '@ohos.base';
import CheckUtil from '../../utils/CheckUtil';
import ConversationDataSource from '../../model/ConversationDataSource';
import commonData from '../../data/commonData';
import ConversationService from '../../service/ConversationService';
import { ValuesBucket } from '@ohos.data.ValuesBucket';
import ConversationListService from '../../service/ConversationListService';
import LooseObject from '../../data/LooseObject';
import SharedPreferencesUtils from '../../utils/SharedPreferencesUtils';
import { StorageMessage, StorageMessageTimeout } from './StorageMessageTimeout';


const TAG = 'ConversationMessageTimeout';

const smsTimeout: number = 60 * 1000;
const mmsTimeout: number = 120 * 1000;
const mmsDownLoadTimeout: number = 6 * 60 * 1000;


export class MessageTimeout {
    private statusChangeEventSubscriber: commonEventManager.CommonEventSubscriber | null = null;
    //sending messsages
    private messageSending: Array<mmsListType> = [];
    //倒计时的消息
    private messageTimer: Map<number | string, number> = new Map<number | string, number>()
    private isDraft: boolean = false;
    private threadId: number = 0;
    private mmsList: Array<mmsListType> = [];
    public context: Context | null = null;

    public messageTimeoutProcessing(listArray: Array<mmsListType>, isDraft: boolean, threadId: number,
        isFirst: boolean = false) {
        if (isFirst) {
            this.isDraft = isDraft;
            this.threadId = threadId;
        } else if (this.threadId !== threadId) {
            HiLog.i(TAG, `Not the current session data`);
            return
        }
        if (!isFirst && this.mmsList.length == listArray.length) {
            HiLog.i(TAG, `all data same as first data `);
            return;
        }
        this.mmsList = listArray;
        this.isDraft = isDraft;
        this.threadId = threadId;
        this.messageSending = this.mmsList.filter(item => {
            return (item.msgState === commonData.int.SEND_MESSAGE_SENDING &&
                item.isSender === commonData.int.SENT_MESSAGE);
        });

        HiLog.i(TAG, `messageTimeoutProcessing start`);

        //已经超时的msgID 批量处理
        let timeoutMsgIDs: (number | string)[] = [];
        this.messageSending.forEach((item: mmsListType, index: number) => {
            let currentTime = new Date().getTime()

            let timeMillisecond: number = Number(item.timeMillisecond);
            let sms = new Date(Number(timeMillisecond));
            let itemStarTime = sms.getTime();

            if (!item?.isRcs) {
                //短信超时时间60秒 彩信120秒
                let timeoutTime: number = item.isMsm ? mmsTimeout : smsTimeout

                if (currentTime - itemStarTime > timeoutTime) {
                    item.msgState = commonData.int.SEND_MESSAGE_FAILED;
                    item.sendStatus = commonData.int.SEND_MESSAGE_FAILED;
                    HiLog.i(TAG, `Messages that have timed out`);
                    timeoutMsgIDs.push(item.id)
                    let index = this.mmsList.indexOf(item);
                    //如果是最后一条消息还需要同步更新sssion表
                    if (!this.isDraft && index === this.mmsList.length - 1) {
                        this.updateMessageStatusForSessionWithItem(item)
                    }

                } else {
                    if (this.messageTimer.get(item.id) !== undefined) {
                        HiLog.i(TAG, `The timer is not re-created when the timer exists.`);
                        return;
                    }
                    let messageTimeout = timeoutTime - (currentTime - itemStarTime);
                    let timeoutID = setTimeout(() => {
                        HiLog.i(TAG, `The message status is updated when the timer expires.`);
                        this.messageTimer.delete(item.id);
                        item.msgState = commonData.int.SEND_MESSAGE_FAILED;
                        item.sendStatus = commonData.int.SEND_MESSAGE_FAILED;
                        this.updateMessageStatusForSmsMmsInfoWithItme(item);
                        let index = this.mmsList.indexOf(item);
                        //如果是最后一条消息还需要同步更新sssion表
                        if (!this.isDraft && index === this.mmsList.length - 1) {
                            this.updateMessageStatusForSessionWithItem(item)
                        }
                        ConversationDataSource.getInstance().updateByIndex(index);
                    }, messageTimeout);

                    this.messageTimer.set(item.id, timeoutID)
                }
            }

        })
        if (timeoutMsgIDs.length > 0) {
            this.updateMessageStatusForMsgIDs(timeoutMsgIDs)
        }
    }

    public messageDownloadTimeout(item: mmsListType) {
        HiLog.i(TAG, `creat message download timeout: msgId:${item.id}`);
        if (this.messageTimer.has(item.id)) {
            HiLog.i(TAG, `the messageTimer has existence`);
            clearTimeout(this.messageTimer.get(item.id));
            this.messageTimer.delete(item.id);
        }
        let timeoutID = setTimeout(() => {
            this.messageTimer.delete(item.id);
            HiLog.i(TAG, `message download timeout start`);
            let actionData: LooseObject = {
                'msgId': item.id,
            }
            if (this.context == null) {
                HiLog.e(TAG, `context is null`);
                return;
            }
            ConversationService.getInstance()
                .querySmsMmsInfoByCondition(this.context, actionData, (result: LooseObject) => {
                    if (result.code === common.int.SUCCESS && result.abilityResult != null) {
                        let msgItem: LooseObject = result.abilityResult[0];
                        if (msgItem == undefined) {
                            HiLog.i(TAG, `The msgItem is undefined`);
                            return;
                        }
                        if (msgItem.msgState == commonData.int.MMS_DOWNLOADING) {
                            let messageList = this.mmsList.filter((val) => {
                                return val.id == item.id
                            })
                            if (messageList.length < 1) {
                                HiLog.e(TAG, `The mmsList does not contain the message corresponding to the ID.`);
                                return;
                            }
                            let messageItem = messageList[0];
                            messageItem.id = item.id;
                            messageItem.msgState = commonData.int.MMS_DOWNLOAD_FAILED;
                            messageItem.sendStatus = commonData.int.MMS_DOWNLOAD_FAILED;
                            this.updateMessageStatusForSmsMmsInfoWithItme(messageItem);
                            let index = this.mmsList.indexOf(messageItem);
                            //如果是最后一条消息还需要同步更新sssion表
                            if (!this.isDraft && index === this.mmsList.length - 1) {
                                this.updateMessageStatusForSessionWithItem(messageItem)
                            }
                            ConversationDataSource.getInstance().updateByIndex(index);
                        } else {
                            HiLog.i(TAG, `message status downLoading has changed`);
                        }
                    }
                })
        }, mmsDownLoadTimeout);
        this.messageTimer.set(item.id, timeoutID)
    }

    public checkMessageDownloadTimeout() {
        HiLog.i(TAG, `check out message download status start`);
        let storageMessageList =
            SharedPreferencesUtils.getFromPreferences(StorageMessageTimeout.storageMessageListName,
                []) as Array<string>;
        storageMessageList.forEach((item) => {
            let storeMessage = JSON.parse(item) as StorageMessage;
            if (storeMessage.isDownLoad) {
                HiLog.i(TAG, `checkMessageDownloadTimeout storeMessage  msgId:${storeMessage.id}`);
                let currentTime = new Date().getTime();
                let timeMillisecond: number = Number(storeMessage.startTime);
                let sms = new Date(Number(timeMillisecond));
                let itemStarTime = sms.getTime();
                if (currentTime - itemStarTime < mmsDownLoadTimeout) {
                    HiLog.i(TAG, `checkMessageDownloadTimeout creat message download time out -` +
                        (mmsDownLoadTimeout - currentTime + itemStarTime));
                    if (this.messageTimer.has(storeMessage.id)) {
                        HiLog.i(TAG, `checkMessageDownloadTimeout The messageTimer has the same id.`);
                        clearTimeout(this.messageTimer.get(storeMessage.id));
                        this.messageTimer.delete(storeMessage.id);
                    }
                    let timeoutID = setTimeout(() => {
                        HiLog.i(TAG, `checkMessageDownloadTimeout message download timeout start`);
                        this.messageTimer.delete(storeMessage.id);
                        let storageMessageList =
                            SharedPreferencesUtils.getFromPreferences(StorageMessageTimeout.storageMessageListName,
                                []) as Array<string>;
                        let index = storageMessageList.indexOf(item)
                        storageMessageList.splice(index, 1)
                        SharedPreferencesUtils.saveToPreferences(StorageMessageTimeout.storageMessageListName,
                            storageMessageList)
                        let actionData: LooseObject = {
                            'msgId': storeMessage.id,
                        }
                        if (this.context == null) {
                            HiLog.e(TAG, `checkMessageDownloadTimeout context is null`);
                            return;
                        }
                        ConversationService.getInstance()
                            .querySmsMmsInfoByCondition(this.context, actionData, (result: LooseObject) => {
                                if (result.code === common.int.SUCCESS && result.abilityResult != null) {
                                    let msgItem: LooseObject = result.abilityResult[0];
                                    if (msgItem == undefined) {
                                        HiLog.i(TAG, `checkMessageDownloadTimeout The msgItem is undefined`);
                                        return;
                                    }
                                    if (msgItem.msgState == commonData.int.MMS_DOWNLOADING) {
                                        let messageList = this.mmsList.filter((val) => {
                                            return val.id == storeMessage.id
                                        })
                                        if (messageList.length < 1) {
                                            HiLog.e(TAG, `checkMessageDownloadTimeout The mmsList does not contain the message corresponding to the ID.`);
                                            return;
                                        }
                                        let messageItem = messageList[0];
                                        messageItem.id = storeMessage.id;
                                        messageItem.msgState = commonData.int.MMS_DOWNLOAD_FAILED;
                                        messageItem.sendStatus = commonData.int.MMS_DOWNLOAD_FAILED;
                                        this.updateMessageStatusForSmsMmsInfoWithItme(messageItem);
                                        let index = this.mmsList.indexOf(messageItem);
                                        //如果是最后一条消息还需要同步更新sssion表
                                        if (!this.isDraft && index === this.mmsList.length - 1) {
                                            this.updateMessageStatusForSessionWithItem(messageItem)
                                        }
                                        ConversationDataSource.getInstance().updateByIndex(index);
                                    } else {
                                        HiLog.i(TAG, `message status downLoading has changed`);
                                    }
                                }
                            })
                    }, (mmsDownLoadTimeout - currentTime + itemStarTime));
                    this.messageTimer.set(storeMessage.id, timeoutID)
                } else {
                    HiLog.i(TAG, `checkMessageDownloadTimeout storeMessage already timeOut`);
                    let storageMessageList =
                        SharedPreferencesUtils.getFromPreferences(StorageMessageTimeout.storageMessageListName,
                            []) as Array<string>;
                    let index = storageMessageList.indexOf(item)
                    storageMessageList.splice(index, 1)
                    SharedPreferencesUtils.saveToPreferences(StorageMessageTimeout.storageMessageListName,
                        storageMessageList)
                    let actionData: LooseObject = {
                        'msgId': storeMessage.id,
                    }
                    if (this.context == null) {
                        HiLog.e(TAG, `checkMessageDownloadTimeout context is null`);
                        return;
                    }
                    ConversationService.getInstance()
                        .querySmsMmsInfoByCondition(this.context, actionData, (result: LooseObject) => {
                            if (result.code === common.int.SUCCESS && result.abilityResult != null) {
                                let msgItem: LooseObject = result.abilityResult[0];
                                if (msgItem == undefined) {
                                    HiLog.i(TAG, `checkMessageDownloadTimeout The msgItem is undefined`);
                                    return;
                                }
                                if (msgItem.msgState == commonData.int.MMS_DOWNLOADING) {
                                    let changeItem = new mmsListType();
                                    changeItem.id = storeMessage.id;
                                    changeItem.msgState = commonData.int.MMS_DOWNLOAD_FAILED;
                                    changeItem.sendStatus = commonData.int.MMS_DOWNLOAD_FAILED;
                                    this.updateMessageStatusForSmsMmsInfoWithItme(changeItem);
                                    let messageList = this.mmsList.filter((val) => {
                                      return val.id == storeMessage.id
                                    })
                                    if (messageList.length > 0) {
                                        let messageItem = messageList[0];
                                        changeItem.msgState = commonData.int.MMS_DOWNLOAD_FAILED;
                                        changeItem.sendStatus = commonData.int.MMS_DOWNLOAD_FAILED;
                                        let index = this.mmsList.indexOf(messageItem);
                                        ConversationDataSource.getInstance().updateByIndex(index);
                                        //如果是最后一条消息还需要同步更新sssion表
                                        if (!this.isDraft && index === this.mmsList.length - 1) {
                                            this.updateMessageStatusForSessionWithItem(messageItem)
                                        }
                                        ConversationDataSource.getInstance().updateByIndex(index);
                                    }
                                } else {
                                    HiLog.i(TAG, `checkMessageDownloadTimeout message status downLoading has changed`);
                                }
                            }
                        })
                }
            }
        })
    }

    private updateMessageStatusForMsgIDs(msgIDs: Array<number | string>) {
        if (msgIDs.length == 0) {
            HiLog.e(TAG, `No msgid can be updated.`);
            return
        }
        if (this.context == null) {
            HiLog.e(TAG, `context is null`);
            return;
        }
        let actionData: Record<string, Array<number | string>> = {
            'msgIds': msgIDs,
        }
        let valueBucket: Record<string, number> = {
            'msg_state': commonData.int.SEND_MESSAGE_FAILED
        }
        ConversationService.getInstance()
            .updateSmsMmsInfoStateByCondition(this.context, actionData, valueBucket, (res: LooseObject) => {
                if (res.code == common.int.SUCCESS) {
                    HiLog.i(TAG, 'update all MsgState success');
                } else {
                    HiLog.i(TAG, 'update all MsgState failed, resultcode: ' + res.code);
                }
            });
    }
    private updateMessageStatusForSmsMmsInfoWithItme(item: mmsListType) {
        HiLog.i(TAG, `updateMessageStatusForSmsMmsInfoWithItme start, msgId:${item?.id}, msgState:${item?.sendStatus}`);
        if (!item.id) {
            HiLog.e(TAG, `updateMessageStatusForSmsMmsInfoWithItme no itemID`);
            return
        }
        if (this.context == null) {
            HiLog.e(TAG, `context is null`);
            return;
        }
        let actionData: Record<string, number | string> = {
            'msgId': item.id,
        }
        let valueBucket: Record<string, number> = {
            'msg_state': item.sendStatus
        }
        ConversationService.getInstance()
            .updateSmsMmsInfoByCondition(this.context, actionData, valueBucket, (res: LooseObject) => {
            if (res.code == common.int.SUCCESS) {
                HiLog.i(TAG, 'updateMsgState success');
            } else {
                HiLog.i(TAG, 'updateMsgState failed, resultcode: ' + res.code);
            }
        });
    }

    private updateMessageStatusForSessionWithItem(item: mmsListType) {
        HiLog.i(TAG,
            `updateMessageStatusForSessionWithItem start, threadId:${this.threadId}, msgState:${item?.sendStatus}`);
        if (!this.threadId) {
            HiLog.e(TAG, `updateMessageStatusForSessionWithItem no threadID`);
            return
        }
        if (this.context == null) {
            HiLog.e(TAG, `context is null`);
            return
        }
        let sessionActionData: Record<string, number> = {
            'threadId': this.threadId
        }
        let sessionValueBucket: ValuesBucket = {
            'sending_status': item.sendStatus
        };
        ConversationListService.getInstance()
            .updateSessionByCondition(this.context, sessionActionData, sessionValueBucket, (res: LooseObject) => {
                if (res.code == common.int.SUCCESS) {
                    HiLog.i(TAG, 'updateSendingStatus success');
                } else {
                    HiLog.i(TAG, 'updateSendingStatus failed, resultcode: ' + res.code);
                }
            }, true);
    }

    private clearAllTimer() {
        HiLog.i(TAG, `clearAllTimer`);
        this.messageTimer.forEach((value, key) => {
            clearInterval(value)
        })
        this.messageTimer = new Map<number | string, number>();
    }

    // Subscribing to Public Events
    public subscribeDetail() {
        HiLog.i(TAG, `subscribeDetail`);
        let eventsStatusFromDB = [common.STR.SMS_MMS_SENT_RESULT_NOTIFY]
        let commonStatusChangeEventSubscribeInfo: commonEventManager.CommonEventSubscribeInfo = {
            events: eventsStatusFromDB
        };
        commonEventManager.createSubscriber(commonStatusChangeEventSubscribeInfo, (args1, args2) => {
            this.createSubscriberStatusChangeCallBack(args1, args2)
        });
    }

    private createSubscriberStatusChangeCallBack(err: BusinessError, data: commonEventManager.CommonEventSubscriber) {
        this.statusChangeEventSubscriber = data;
        try {
            commonEventManager.subscribe(this.statusChangeEventSubscriber, (arg1, arg2) => {

                if (!CheckUtil.hasBarProperty(arg2, 'parameters')) {
                    HiLog.e(TAG, 'createSubscriberStatusChangeCallBack, data don`t have dataParameters');
                    return;
                }

                if (!CheckUtil.hasBarProperty(arg2.parameters as commonEventManager.CommonEventData, 'msgId')) {
                    HiLog.e(TAG, 'createSubscriberStatusChangeCallBack, parameters don`t have msg_id');
                    return;
                }
                let msgID: number = arg2.parameters?.msgId;
                let msgStatus: number = arg2.parameters?.msgState;
                let msgType: number = arg2.parameters?.msgType;
                if (this.messageTimer.get(msgID)) {
                    HiLog.i(TAG, `createSubscriberStatusChangeCallBack clear Timer`);
                    let value = this.messageTimer.get(msgID);
                    clearInterval(value);
                    for (let i = 0; i < this.messageSending.length; i++) {
                        let item = this.messageSending[i];
                        if (item.id == msgID) {
                            item.msgState = msgStatus;
                            item.sendStatus = msgStatus;
                            let index = this.mmsList.indexOf(item);
                            //如果是最后一条消息还需要同步更新sssion表
                            if (!this.isDraft && index === this.mmsList.length - 1) {
                                this.updateMessageStatusForSessionWithItem(item)
                            }
                            HiLog.i(TAG, `createSubscriberStatusChangeCallBack update UI`);
                            ConversationDataSource.getInstance().updateByIndex(index);
                            break;
                        }
                    }
                } else {
                    HiLog.i(TAG, 'createSubscriberStatusChangeCallBack, data don`t have timer');
                }
            });
        } catch (error) {
            let err: BusinessError = error as BusinessError;
            HiLog.i(TAG, 'subscribe, error');
        }

    }

    // Unsubscribe
    private unSubscribeDetail() {
        if (this.statusChangeEventSubscriber != null) {
            commonEventManager.unsubscribe(this.statusChangeEventSubscriber, () => {
                HiLog.i(TAG, 'statusChangeEventSubscriber, unsubscribe ');
            });
            this.statusChangeEventSubscriber = null;
        }
    }

    public clearSubscribeAndTimer() {
        this.unSubscribeDetail();
        this.clearAllTimer()
        this.messageSending = [];
        this.threadId = 0;
        this.mmsList = [];
    }
}