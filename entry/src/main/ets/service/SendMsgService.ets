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

import sms from "@ohos.telephony.sms";
import HiLog from "../utils/HiLog";
import common from "../data/commonData";
import http from "@ohos.net.http";

const TAG = "SendMsgService"

export default {

    /**
     * Sending sms messages
     *
     * @param params Including the card slot, phone number, and SMS message content
     * @callback callback Return the message sending status.
     */
    sendMessage(params, callback) {
        sms.sendMessage({
            slotId: params.slotId,
            destinationHost: params.destinationHost,
            content: params.content,
            sendCallback: (err, value) => {
                let sendStatus;
                if (err) {
                    HiLog.w(TAG, "sendMessage, sendCallback failed err: " + JSON.stringify(err.message));
                    sendStatus = common.int.SEND_MESSAGE_FAILED;
                } else {
                    sendStatus = this.dealSendResult(value);
                    HiLog.i(TAG, `sendMessage, sendCallback success result=${value.result}, sendStatus=${sendStatus}`);
                }
                callback(sendStatus);
            },
            deliveryCallback: (err, value) => {
                if (err) {
                    HiLog.w(TAG, "sendMessage, deliveryCallback failed err: " + JSON.stringify(err.message));
                    return;
                }
            }
        });
    },

    dealSendResult(value) {
        let sendStatus = common.int.SEND_MESSAGE_SENDING;
        if (value.result == sms.SendSmsResult.SEND_SMS_SUCCESS) {
            sendStatus = common.int.SEND_MESSAGE_SUCCESS;
        } else {
            sendStatus = common.int.SEND_MESSAGE_FAILED;
        }
        return sendStatus;
    },

    sendMmsMessage(params, callback) {
        let httpRequest = http.createHttp();
        httpRequest.request(common.string.MMS_URL,
            {
                method: http.RequestMethod.POST,
                header: {
                    "Content-Type": "application/vnd.wap.mms-message",
                    "Accept": "Accept",
                    "Accept-Language": "Accept-Language"
                },
                extraData: JSON.stringify(params),
                readTimeout: 60000,
                connectTimeout: 60000
            }, (err, data) => {
                let sendStatus;
                if (err) {
                    HiLog.i(TAG, "sendMmsMessage, error: " + JSON.stringify(err.message));
                    sendStatus = common.int.SEND_MESSAGE_FAILED;
                } else {
                    sendStatus = common.int.SEND_MESSAGE_SUCCESS;
                }
                callback(sendStatus);
            }
        );
    }
};