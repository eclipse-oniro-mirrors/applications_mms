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
import WantAgent from "@ohos.app.ability.wantAgent";
import Notification from "@ohos.notificationManager";
import common from "../data/commonData";
import HiLog from "../utils/HiLog";
import conversationService from "./ConversationService";
import LooseObject from "../data/LooseObject";
import messageService from "../service/ConversationListService";

var notificationManager = globalThis.requireNapi("notificationManager");
const label = "notification_";
const TAG = "NotificationService";

export default class NotificationService {
    private static sInstance: NotificationService;

    static getInstance() {
        if (NotificationService.sInstance == null) {
            NotificationService.sInstance = new NotificationService();
        }
        return NotificationService.sInstance;
    }

    constructor() {
        HiLog.i(TAG, "new start");
    }

    /**
     * Send Notifications
     *
     * @param actionData
     */
    sendNotify(actionData) {
        // Creating Want Information
        let wantAgentInfo = this.buildWantAgentInfo(actionData);
        // Constructing a Send Request
        let notificationRequest = this.buildNotificationRequest(actionData);
        this.getWantAgent(wantAgentInfo, (data) => {
            notificationRequest.wantAgent = data;
            notificationRequest.id = actionData.msgId;
            notificationRequest.label = label + actionData.msgId;
            if(Number(actionData.unreadTotal) >= 0){
                HiLog.i(TAG, `unreadTotal is: ${Number(actionData.unreadTotal)}`)
                notificationManager.setBadgeNumber(Number(actionData.unreadTotal));
            }
            Notification.publish(notificationRequest);
            HiLog.i(TAG, "sendNotify finished");
        });
    }

    /**
     * Create a wanted message to be sent.
     *
     * @param agentInfo
     * @callback callback
     */
    getWantAgent(agentInfo, callback) {
        WantAgent.getWantAgent(agentInfo).then(data1 => {
            callback(data1);
        });
    }

    /**
     * Constructing distributed startup parameters
     *
     * @param actionData
     */
    buildWantAgentInfo(actionData): any {
        let parameters = {
            pageFlag: "conversation",
            contactObjects: actionData.contactObjects
        };
        let wantAgentInfo = {
            wants: [
                {
                    deviceId: "",
                    bundleName: common.string.BUNDLE_NAME,
                    abilityName: common.string.ABILITY_NAME,
                    action: "mms.event.notification",
                    entities: [],
                    type: "MIMETYPE",
                    uri: "",
                }
            ],
            operationType: WantAgent.OperationType.START_ABILITY,
            requestCode: actionData.msgId,
            wantAgentFlags: [WantAgent.WantAgentFlags.CONSTANT_FLAG],
            extraInfo: parameters
        };
        return wantAgentInfo;
    }

    /**
     * Building notification parameters
     *
     * @param actionData
     */
    buildNotificationRequest(actionData): any {
        let message = actionData.message;
        let notificationRequest = {
            content: {
                contentType: Notification.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
                normal: {
                    title: message.title,
                    text: message.text
                },
            },
            wantAgent: '',
            slotType: Notification.SlotType.OTHER_TYPES,
            deliveryTime: new Date().getTime(),
            groupName: "MMS"
        };
        return notificationRequest;
    }

    cancelMessageNotify(actionData, callback) {
        conversationService.queryMessageDetail(actionData, res => {
            if (res.code == common.int.FAILURE || res.response.length == 0) {
                callback(common.int.FAILURE);
            }
            let count = 0;
            for (let item of res.response) {
                this.cancelNotify(parseInt(item.id), result => {
                    count++;
                    if (count == res.response.length) {
                        callback(common.int.SUCCESS);
                    }
                });
            }
        });
    }

    cancelNotify(msgId, callback) {
        Notification.cancel(msgId, label + msgId, (err, data) => {
            if (err) {
                HiLog.w(TAG, "cancelNotify, error: " + JSON.stringify(err.message));
                callback(common.int.FAILURE);
            }
            callback(common.int.SUCCESS);
        });
        let params: LooseObject = {};
        messageService.statisticalData(params, function (res) {
            if (res.code == common.int.SUCCESS) {
                notificationManager.setBadgeNumber(Number(res.response.totalListCount));
                HiLog.i(TAG, "sendNotification, callback actionData");
            }
        });
    }

    cancelAllNotify() {
        let promise = Notification.cancelAll();
        promise.then((ret) => {
        }).catch((err) => {
            HiLog.e(TAG, "cancelAllNotify, error: " + JSON.stringify(err.message));
        });
    }
};