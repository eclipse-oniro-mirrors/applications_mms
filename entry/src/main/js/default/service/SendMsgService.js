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

import sms from '@ohos.telephony.sms';
import mmsLog from '../utils/MmsLog.js';
import common from '../pages/common_constants.js';
import http from '@ohos.net.http';

export default {

    /**
     * 发送短信
     * @param params 包含卡槽，电话号码，短信内容
     * @param callback 返回发送信息状态
     * @return
     */
    sendMessage(params, callback) {
        mmsLog.info('sendMessage,params:' + params);
        sms.sendMessage({
            slotId: params.slotId,
            destinationHost: params.destinationHost,
            content: params.content,
            sendCallback: (err, value) => {
                let sendStatus;
                if (err) {
                    mmsLog.info('sendMessageService send message call back error');
                    sendStatus = common.int.SEND_MESSAGE_FAILED;
                } else {
                    mmsLog.info('sendMessageService send message call back success result = ' + value.result);
                    sendStatus = this.dealSendResult(value);
                }
                callback(sendStatus);
            },
            deliveryCallback: (err, value) => {
                if (err) {
                    mmsLog.info('sendMessageService send message deliveryCallback err');
                    return;
                }
                mmsLog.info('sendMessageService send message deliveryCallback success sendResult = ' + value.pdu);
            }
        });
    },
    dealSendResult(value) {
        let sendStatus = common.int.SEND_MESSAGE_SENDING;
        if (value.result == sms.SEND_SMS_SUCCESS) {
            sendStatus = common.int.SEND_MESSAGE_SUCCESS;
        } else {
            sendStatus = common.int.SEND_MESSAGE_FAILED;
        }
        return sendStatus;
    },
    sendMmsMessage(params, callback) {
        mmsLog.info('sendMmsMessage,params:' + params);
        let httpRequest = http.createHttp();
        httpRequest.request(common.string.MMS_URL,
            {
                method: 'POST',
                header: {
                    'Content-Type': 'application/vnd.wap.mms-message',
                    'Accept': 'Accept',
                    'Accept-Language': 'Accept-Language'
                },
                extraData: JSON.stringify(params),
                readTimeout: 60000,
                connectTimeout: 60000
            }, (err, data) => {
                let sendStatus;
                if (!err) {
                    mmsLog.info('sendMmsMessage error:' + JSON.stringify(data));
                    sendStatus = common.int.SEND_MESSAGE_SUCCESS;
                } else {
                    mmsLog.info('error:' + err.data);
                    sendStatus = common.int.SEND_MESSAGE_SUCCESS;
                }
                callback(sendStatus);
            }
        );
    }
};