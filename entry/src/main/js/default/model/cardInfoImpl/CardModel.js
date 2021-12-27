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

import BaseModel from '../BaseModel.js';
import common from '../../pages/common_constants.js';
import mmsLog from '../../../default/utils/MmsLog.js';
import telephonySMS from '@ohos.telephony.sms';
import telephonySim from '@ohos.telephony.sim';

const TAG = 'CardModel ->';

export default class CardModel extends BaseModel {
    getSimSpn(preferences) {
        telephonySim.getSimSpn(common.int.SIM_ONE, (err, value) => {
            if (err) {
                mmsLog.log('getSimSpn error = ' + err.message);
            } else {
                preferences.setValueForSwitch(common.string.KEY_OF_SIM_0_SPN, value);
                mmsLog.log('getSimSpn spn = ' + value);
            }
        });
        telephonySim.getSimSpn(common.int.SIM_TWO, (err, value) => {
            if (err) {
                mmsLog.log('getSimSpn error = ' + err.message);
            } else {
                preferences.setValueForSwitch(common.string.KEY_OF_SIM_1_SPN, value);
                mmsLog.log('getSimSpn spn = ' + value);
            }
        });
    }

    getSmscNumber(slotId, preferences, callback) {
        mmsLog.info(TAG + 'getSmscAddr,slotId:' + slotId);
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
                mmsLog.info(TAG + 'getSmNumber  smsNumber: error = ' + JSON.stringify(error));
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
                mmsLog.log(TAG + 'getAllSimMessages callback error cause :' + error.message);
                return;
            }
            for (let i = 0;i < msgArray.length; i++) {
                let data = {};
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
            callback(super.encapsulateReturnResult(common.int.SUCCESS, simMessageList));
        });
    }

    delSimMessage(actionData) {
        let index = actionData.index - 1;
        let msgIndex = actionData.indexOnSim;
        telephonySMS.delSimMessage(index, msgIndex, (error, value) => {
            if (error) {
                mmsLog.log(TAG + 'delSimMessage error cause: ' + error.message);
            } else {
                mmsLog.log(TAG + 'delSimMessage value cause: ' + value);
            }
        });
    }

    getSimCardNum(preferences) {
        mmsLog.log(TAG + 'getSimCardNum start' + telephonySim);
        telephonySim.hasSimCard(common.int.SIM_ONE, (error, value) => {
            if (error) {
                mmsLog.log(TAG + 'hasSimCard0 error cause: ' + error.message);
            } else {
                mmsLog.log(TAG + 'hasSimCard0 result: ' + value);
                let result = value ? common.bool.TRUE : common.bool.FALSE;
                preferences.setValueForSwitch(common.string.KEY_OF_SIM_0_EXIST_FLAG, result);
            }
        });
        telephonySim.hasSimCard(common.int.SIM_TWO, (error, value) => {
            if (error) {
                mmsLog.log(TAG + 'hasSimCard1 error cause: ' + error.message);
            } else {
                mmsLog.log(TAG + 'hasSimCard1 result: ' + value);
                let result = value ? common.bool.TRUE : common.bool.FALSE;
                preferences.setValueForSwitch(common.string.KEY_OF_SIM_1_EXIST_FLAG, result);
            }
        });
    }

    getSimTelephoneNumber(preferences) {
        mmsLog.log(TAG + 'getSimTelephoneNumber start');
        telephonySim.getSimTelephoneNumber(common.int.SIM_ONE, (error, value) => {
            if (error) {
                mmsLog.log('getSimTelephoneNumber error cause: ' + error.message);
            } else {
                mmsLog.log('getSimTelephoneNumber success: ' + value);
                preferences.setValueForSwitch(common.string.KEY_OF_SIM_0_NUMBER, value);
            }
        });
        telephonySim.getSimTelephoneNumber(common.int.SIM_TWO, (error, value) => {
            if (error) {
                mmsLog.log('getSimTelephoneNumber error cause: ' + error.message);
            } else {
                mmsLog.log('getSimTelephoneNumber success: ' + value);
                preferences.setValueForSwitch(common.string.KEY_OF_SIM_1_NUMBER, value);
            }
        });
    }
}