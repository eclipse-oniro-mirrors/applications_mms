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

import BaseModel from './BaseModel';
import common from '../data/commonData';
import LooseObject from '../data/LooseObject'
import HiLog from '../utils/HiLog';
import telephonySMS from '@ohos.telephony.sms';
import telephonySim from '@ohos.telephony.sim';

const TAG = 'CardModel';

export default class CardModel extends BaseModel {
    getSimSpn(preferences) {
        telephonySim.getSimSpn(common.int.SIM_ONE, (err, value) => {
            if (err) {
                HiLog.e(TAG, 'getSimSpn, SIM_ONE error: ' + JSON.stringify(err));
            } else {
                preferences.setValueForSwitch(common.string.KEY_OF_SIM_0_SPN, value);
                HiLog.i(TAG, 'getSimSpn, SIM_ONE spn=' + value);
            }
        });
        telephonySim.getSimSpn(common.int.SIM_TWO, (err, value) => {
            if (err) {
                HiLog.e(TAG, 'getSimSpn, SIM_TWO error: ' + JSON.stringify(err));
            } else {
                preferences.setValueForSwitch(common.string.KEY_OF_SIM_1_SPN, value);
                HiLog.i(TAG, 'getSimSpn, SIM_TWO spn=' + value);
            }
        });
    }

    getSmscNumber(slotId, preferences, callback) {
        HiLog.i(TAG, 'getSmscNumber, slotId:' + slotId);
        let smsNumber = common.string.EMPTY_STR;
        let simOne = preferences.getNewSmscOfSim1();
        let simTwo = preferences.getNewSmscOfSim2();
        if (slotId == common.int.SIM_ONE && simOne != common.string.EMPTY_STR) {
            smsNumber = simOne;
        } else if (slotId == common.int.SIM_TWO && simTwo != common.string.EMPTY_STR) {
            smsNumber = simTwo;
        } else {
            // 调用API获取
            telephonySMS.getSmscAddr(slotId).then((simPhoneNumber) => {
                smsNumber = simPhoneNumber;
                if (slotId == common.int.SIM_ONE) {
                    preferences.setValueForSwitch(common.string.KEY_OF_NEW_SIM_0_SMSC, simPhoneNumber);
                } else if (slotId == common.int.SIM_TWO) {
                    preferences.setValueForSwitch(common.string.KEY_OF_NEW_SIM_1_SMSC, simPhoneNumber);
                }
                callback(smsNumber);
            }).catch((error) => {
                HiLog.e(TAG, 'getSmscNumber, error: ' + JSON.stringify(error));
            });
        }
        callback(smsNumber);
    }

    queryMessageInSimCard(actionData, callback) {
        let index = actionData.index - 1;
        // 获取sim卡内信息的API目前未提供. 获取sim卡内短信
        let simMessageList = [];
        telephonySMS.getAllSimMessages(index, (error, msgArray) => {
            if (error) {
                HiLog.e(TAG, 'queryMessageInSimCard, error: ' + JSON.stringify(error));
                return;
            }
            for (let i = 0;i < msgArray.length; i++) {
                let data: LooseObject = {};
                data.image = '/common/icon/user_avatar_full_fill.svg';
                data.date = common.string.EMPTY_STR;
                data.time = common.string.EMPTY_STR;
                data.timeMillisecond = msgArray[i].shortMessage.scTimestamp;
                data.content = msgArray[i].shortMessage.visibleMessageBody;
                data.indexOnSim = msgArray[i].indexOnSim;
                data.isCbChecked = false;
                data.msgType = [0];
                data.type = 0;
                data.address = msgArray[i].shortMessage.visibleRawAddress;
                data.isMsm = false;
                simMessageList.push(data);
            }
            callback(this.encapsulateReturnResult(common.int.SUCCESS, simMessageList));
        });
    }

    delSimMessage(actionData) {
        let index = actionData.index - 1;
        let msgIndex = actionData.indexOnSim;
        telephonySMS.delSimMessage(index, msgIndex, (error, value) => {
            if (error) {
                HiLog.e(TAG, 'delSimMessage, error: ' + JSON.stringify(error));
            } else {
                HiLog.i(TAG, 'delSimMessage, value=' + value);
            }
        });
    }

    getSimCardNum(preferences) {
        HiLog.i(TAG, 'getSimCardNum start ' + telephonySim);
        telephonySim.hasSimCard(common.int.SIM_ONE, (error, value) => {
            if (error) {
                HiLog.e(TAG, 'getSimCardNum, SIM_ONE error: ' + JSON.stringify(error));
            } else {
                HiLog.i(TAG, 'getSimCardNum, SIM_ONE value=' + value);
                let result = value ? common.bool.TRUE : common.bool.FALSE;
                preferences.setValueForSwitch(common.string.KEY_OF_SIM_0_EXIST_FLAG, result);
            }
        });
        telephonySim.hasSimCard(common.int.SIM_TWO, (error, value) => {
            if (error) {
                HiLog.e(TAG, 'getSimCardNum, SIM_TWO error: ' + JSON.stringify(error));
            } else {
                HiLog.i(TAG, 'getSimCardNum, SIM_TWO value=' + value);
                let result = value ? common.bool.TRUE : common.bool.FALSE;
                preferences.setValueForSwitch(common.string.KEY_OF_SIM_1_EXIST_FLAG, result);
            }
        });
    }

    getSimTelephoneNumber(preferences) {
        HiLog.i(TAG, 'getSimTelephoneNumber start');
        telephonySim.getSimTelephoneNumber(common.int.SIM_ONE, (error, value) => {
            if (error) {
                HiLog.e(TAG, 'getSimTelephoneNumber, SIM_ONE error: ' + JSON.stringify(error));
            } else {
                HiLog.i(TAG, 'getSimTelephoneNumber, SIM_ONE value=' + value);
                preferences.setValueForSwitch(common.string.KEY_OF_SIM_0_NUMBER, value);
            }
        });
        telephonySim.getSimTelephoneNumber(common.int.SIM_TWO, (error, value) => {
            if (error) {
                HiLog.e(TAG, 'getSimTelephoneNumber, SIM_TWO error: ' + JSON.stringify(error));
            } else {
                HiLog.i(TAG, 'getSimTelephoneNumber, SIM_TWO value=' + value);
                preferences.setValueForSwitch(common.string.KEY_OF_SIM_1_NUMBER, value);
            }
        });
    }
}