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
import commonEvent from "@ohos.commonEventManager";
import telSim from "@ohos.telephony.sms";
import http from "@ohos.net.http";

import common from '../data/commonData';
import telephoneUtils from '../utils/TelephoneUtil';
import HiLog from '../utils/HiLog';
import commonService from '../service/CommonService';
import ConversationService from '../service/ConversationService';
import NotificationService from '../service/NotificationService';
import LooseObject from '../data/LooseObject'
import ConversationListService from '../service/ConversationListService';
import ContactService from '../service/ContactsService';

const TAG: string = 'MmsStaticSubscriber'

var StaticSubscriberExtensionAbility = globalThis.requireNapi('application.StaticSubscriberExtensionAbility');

export default class MmsStaticSubscriber extends StaticSubscriberExtensionAbility {

    public onReceiveEvent(data): void {
        HiLog.i(TAG, 'onReceiveEvent, event:' );
        if (data.event === common.string.SUBSCRIBER_EVENT) {
            this.dealSmsReceiveData(data, this.context);
        } else {
            this.dealMmsReceiveData(data, this.context);
        }
    }

    public async dealSmsReceiveData(data, context): Promise<void> {
        let netType: string = data.parameters.isCdma ? "3gpp2" : "3gpp";
        // Synchronize wait operation
        let promisesAll = [];
        data.parameters.pdus.forEach(pdu => {
            let promise = telSim.createMessage(this.convertStrArray(pdu), netType);
            promisesAll.push(promise);
        });
        let result: LooseObject = {};
        let createMessagePromise = Promise.all(promisesAll);
        createMessagePromise.then(shortMsgList => {
            result.code = common.int.SUCCESS;
            result.telephone = telephoneUtils.formatTelephone(shortMsgList[0].visibleRawAddress);
            result.content = common.string.EMPTY_STR;
            shortMsgList.forEach(shortMessage => {
                result.content += shortMessage.visibleMessageBody;
            });
        }).catch(error => {
            HiLog.e(TAG, "dealSmsReceiveData, error: " + JSON.stringify(error));
            result.code = common.int.FAILURE;
        });
        await createMessagePromise;
        let actionData: LooseObject = {};
        actionData.slotId = data.parameters.slotId;
        actionData.telephone = result.telephone;
        actionData.content = result.content;
        actionData.isMms = false;
        actionData.mmsSource = [];
        this.insertMessageDetailBy(actionData, res => {
            this.sendNotification(result.telephone, res.initDatas[0].id, result.content, context);
            this.publishData(result.telephone, result.content);
        }, context);
    }

    public dealMmsReceiveData(data, context): void {
        let result = JSON.parse(data.data);
        this.saveAttachment(result.mmsSource);
        let content: string = commonService.getMmsContent(result.mmsSource);
        let actionData: LooseObject = {};
        actionData.telephone = result.telephone;
        actionData.content = content;
        actionData.isMms = true;
        actionData.mmsSource = result.mmsSource;
        actionData.slotId = data.parameters.slotId;
        this.insertMessageDetailBy(actionData, res => {
            let notificationContent = this.getNotificationContent(result.mmsSource, content);
            this.sendNotification(result.telephone, res.initDatas[0].id, notificationContent, context);
            this.publishData(result.telephone, result.content);
        }, context);
    }

    public saveAttachment(mmsSource): void {
        for (let item of mmsSource) {
            let baseUrl = item.msgUriPath;
            let httpRequest = http.createHttp();
            httpRequest.request(common.string.MMS_URL,
                {
                    method: http.RequestMethod.GET,
                    header: {
                        "Content-Type": "application/json",
                    },
                    extraData: baseUrl,
                    readTimeout: 50000,
                    connectTimeout: 50000
                }, (err, data) => {
                    HiLog.i(TAG, "saveAttachment, err: " + JSON.stringify(err.message));
                }
            );
        }
    }

    public getNotificationContent(mmsSource, themeContent): string {
        let content: string = common.string.EMPTY_STR;
        if (mmsSource.length === 1) {
            let item = mmsSource[0];
            switch (item.msgType) {
                // Subject
                case 0:
                    content = themeContent;
                    break;
                // Pictures
                case 1:
                    content = "(picture)" + themeContent;
                    break;
                // Video
                case 2:
                    content = "(video)" + themeContent;
                    break;
                // Audio
                case 3:
                    content = "(audio)" + themeContent;
                    break;
            }
        } else {
            content = "(slide)" + mmsSource[0].content;
        }
        return content;
    }

    public insertMessageDetailBy(param, callback, context): void {
        let sendResults: Array<LooseObject> = [];
        let sendResult: LooseObject = {};
        sendResult.slotId = param.slotId;
        sendResult.telephone = param.telephone;
        sendResult.content = param.content;
        sendResult.sendStatus = common.int.SEND_MESSAGE_SUCCESS;
        sendResults.push(sendResult);

        let hasAttachment: boolean = commonService.judgeIsAttachment(param.mmsSource);
        let actionData: LooseObject = {};
        actionData.slotId = param.slotId;
        actionData.sendResults = sendResults;
        actionData.isReceive = true;
        actionData.ownNumber = common.string.EMPTY_STR;
        actionData.isSender = true;
        actionData.isMms = param.isMms;
        actionData.mmsSource = param.mmsSource;
        actionData.hasAttachment = hasAttachment;
        ConversationService.getInstance().insertSessionAndDetail(actionData, callback, context);
    }

    public convertStrArray(sourceStr): Array<number> {
        let wby: string = sourceStr;
        let length: number = wby.length;
        let isDouble: boolean = (length % 2) == 0;
        let halfSize: number = parseInt('' + length / 2);
        HiLog.i(TAG, "convertStrArray, length=" + length + ", isDouble=" + isDouble);
        if (isDouble) {
            let number0xArray = new Array(halfSize);
            for (let i = 0;i < halfSize; i++) {
                number0xArray[i] = "0x" + wby.substr(i * 2, 2);
            }
            let numberArray = new Array(halfSize);
            for (let i = 0;i < halfSize; i++) {
                numberArray[i] = parseInt(number0xArray[i], 16);
            }
            return numberArray;
        } else {
            let number0xArray = new Array(halfSize + 1);
            for (let i = 0;i < halfSize; i++) {
                number0xArray[i] = "0x" + wby.substr(i * 2, 2);
            }
            number0xArray[halfSize] = "0x" + wby.substr((halfSize * 2) + 1, 1);
            let numberArray = new Array(halfSize + 1);
            for (let i = 0;i < halfSize; i++) {
                numberArray[i] = parseInt(number0xArray[i], 16);
            }
            let last0x = "0x" + wby.substr(wby.length - 1, 1);
            numberArray[halfSize] = parseInt(last0x);
            return numberArray;
        }
    }

    public publishData(telephone, content): void {
        HiLog.i(TAG, "publishData, start");
        let actionData = {
            telephone: telephone,
            content: content
        };
        commonEvent.publish(common.string.RECEIVE_TRANSMIT_EVENT, {
            bundleName: common.string.BUNDLE_NAME,
            subscriberPermissions: ['ohos.permission.RECEIVE_SMS'],
            isOrdered: false,
            data: JSON.stringify(actionData)
        }, (res) => {
        });
    }

    public sendNotification(telephone, msgId, content, context): void {
        let condition: LooseObject = {};
        condition.telephones = [telephone];
        ContactService.getInstance().queryContactDataByCondition(condition, res => {
            HiLog.i(TAG, "sendNotification, callback");
            if (res.code == common.int.FAILURE) {
                return;
            }
            let contacts: Array<LooseObject> = res.abilityResult;
            let actionData: LooseObject = this.dealContactParams(contacts, telephone);
            if (content.length > 15) {
                content = content.substring(0, 15) + "...";
            }
            let title: string = telephone;
            if(contacts.length > 0) {
                title = contacts[0].displayName
            }
            let message: LooseObject = {
                "title": title,
                "text": content,
            };
            actionData.message = message;
            actionData.msgId = msgId;
            actionData.unreadTotal = 0;
            NotificationService.getInstance().sendNotify(actionData);
            ConversationListService.getInstance().statisticalData(res => {
                if (res.code == common.int.SUCCESS) {
                    NotificationService.getInstance().setBadgeNumber(Number(res.response.totalListCount));
                }
            }, context);
        }, context);
    }

    public dealContactParams(contacts, telephone): LooseObject {
        let actionData: LooseObject = {};
        let params: Array<LooseObject> = [];
        if (contacts.length == 0) {
            params.push({
                telephone: telephone,
            });
        } else {
            let contact: LooseObject = contacts[0];
            params.push({
                contactsName: contact.displayName,
                telephone: telephone,
                telephoneFormat: contact.detailInfo,
            });
        }
        actionData.contactObjects = JSON.stringify(params);
        return actionData;
    }
}
