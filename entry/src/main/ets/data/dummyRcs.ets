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

import HiLog from '../utils/HiLog';
import Rcs from '@ohos.telephony.rcs';

const TAG = 'dummyRcs';

interface RcsConfig {
    slotId: number;
    readReceiptEnabled: boolean;
};

interface RcsError {
    code: number;
    message: string;
}
interface RcsEvent {
    type: RcsEventType;
    params?: object;
}
enum RcsEventType {
    RCS_OFFLINE = 0,
    RCS_ONLINE = 1,
    RCS_OTP_MISSING = 2,
    RCS_MSISDN_MISSING = 3,
    RCS_RECEIVE_TEXT = 4,
    RCS_SEND_STATUS = 5,
}

interface RcsMessage {
    msgId: string;
    slotId: number;
    address: string;
    date: string;
    content: string;
    extraData?: object;
}

interface RcsSendOptions {
    destination: string;
    content: string;
    extraParam?: object;
}

interface RcsSendResultInfo {
    result: RcsSendResult;
    msgId: string;
}

enum RcsSendResult {
    RCS_SEND_SUCCESS = 0,
    RCS_SEND_RUNNING = 1,
    RCS_SEND_FAILURE = 2,
}

interface  RcsInterface {
    isRcsEnabled: () => boolean;
    isRcsSupported: (slotId?: number) => boolean;

    startRcs: (config: RcsConfig, cb: (err: RcsError) => void) => void;
    stopRcs: (cb: (err: RcsError) => void) => void;
    isRcsLoggedIn: () => boolean;
    sendOtpInfo:(otp: string) =>void;
    setReadReceipt: (readReceiptEnabled: boolean) => void;
    getReadReceipt: () => boolean;
    sendReadReceipt: (msgId: string, cb: (err: RcsError) => void) => void;
    createMessage: (msgId: string) => Promise<RcsMessage>;
    sendMessage: (options: Rcs.RcsSendOptions, callback: (err: RcsError, info:RcsSendResultInfo) => void) => void;
    resendMessage: (msgId: string) => Promise<void>;

    on: (type: 'event', callback: (message: RcsEvent) => void)=> void;
    off: (type: 'event', callback: (message: RcsEvent) => void)=> void;
}

const successObj: RcsError = {
    code: 0,
    message: ''
};

const onlineObj: RcsEvent = {
    type: RcsEventType.RCS_ONLINE
}

const resultInfo:RcsSendResultInfo = {
    result: RcsSendResult.RCS_SEND_SUCCESS,
    msgId: '1234-45632',
}

let otp_:string = '';
let readReceiptEnabled_:boolean = true;

let rcs : RcsInterface = {
    isRcsEnabled() {
        return true;
    },
    isRcsSupported(slotId?: number) {
        return true;
    },
    startRcs(config: RcsConfig, cb: (err: RcsError) => void) {
        HiLog.i(TAG, 'execute start');
        setTimeout(() => {
            HiLog.i(TAG, 'start completed');
            cb(successObj);
        }, 1000);
    },
    stopRcs(cb: (err: RcsError) => void) {
        HiLog.i(TAG, 'execute stop');
        setTimeout(() => {
            HiLog.i(TAG, 'stop completed');
            cb(successObj);
        }, 10);
    },
    isRcsLoggedIn() {
        return true;
    },
    sendOtpInfo(otp: string) {
        otp_ = otp;
    },
    setReadReceipt(readReceiptEnabled: boolean) {
        readReceiptEnabled_ = readReceiptEnabled;
    },
    getReadReceipt() {
        return readReceiptEnabled_;
    },
    sendReadReceipt(msgId: string, cb: (err: RcsError) => void) {
        HiLog.i(TAG, 'execute sendReadReceipt');
        setTimeout(() => {
            HiLog.i(TAG, 'sendReadReceipt completed');
            cb(successObj);
        }, 1000);
    },
    createMessage(msgId: string) {
        return new Promise((resolved:Function, reject:Function) => {
            let msg:RcsMessage = {
                msgId: '1234-5678',
                slotId: 0,
                address: '13913911391',
                date: '165432178684',
                content: 'aaaaaaa',
            };
            resolved(msg);
        });
    },
    sendMessage(options: Rcs.RcsSendOptions, cb: (err: RcsError, info:RcsSendResultInfo) => void) {
        HiLog.i(TAG, 'execute sendMessage');
        setTimeout(() => {
            HiLog.i(TAG, 'sendMessage completed');
            cb(successObj, resultInfo);
        }, 1000);
    },
    resendMessage(msgId: string) {
        return new Promise((resolved:Function, reject:Function) => {

            resolved();
        });
    },
    on(type: 'event', callback: (message: RcsEvent) => void){
        setTimeout(() => {
            callback(onlineObj)
        }, 10);
    },
    off(type: 'event', callback: (message: RcsEvent) => void){
        setTimeout(() => {
            callback(onlineObj)
        }, 10);
    },
};
export { rcs, RcsConfig, RcsMessage,RcsEvent,RcsSendResultInfo };
