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

import BaseModel from "./BaseModel";
import common from "../data/commonData";
import LooseObject from "../data/LooseObject"
import HiLog from "../utils/HiLog";
import MmsPreferences from "../utils/MmsPreferences";
import telephonySMS from "@ohos.telephony.sms";
import telephonySim from "@ohos.telephony.sim";

const TAG = "CardModel";

export default class CardModel extends BaseModel {
    getSimSpn() {
        telephonySim.getSimSpn(common.int.SIM_ONE, (err, value) => {
            if (err) {
                HiLog.e(TAG, "getSimSpn, SIM_ONE error: " + JSON.stringify(err.message));
            } else {
                MmsPreferences.getInstance().setValueForSwitch(common.string.KEY_OF_SIM_0_SPN, value);
            }
        });
        telephonySim.getSimSpn(common.int.SIM_TWO, (err, value) => {
            if (err) {
                HiLog.e(TAG, "getSimSpn, SIM_TWO error: " + JSON.stringify(err.message));
            } else {
                MmsPreferences.getInstance().setValueForSwitch(common.string.KEY_OF_SIM_1_SPN, value);
            }
        });
    }

    getSmscNumber(slotId, callback) {
        let smsNumber = common.string.EMPTY_STR;
        let simOne = MmsPreferences.getInstance().getNewSmscOfSim1();
        let simTwo = MmsPreferences.getInstance().getNewSmscOfSim2();
        if (slotId == common.int.SIM_ONE && simOne != common.string.EMPTY_STR) {
            smsNumber = simOne;
        } else if (slotId == common.int.SIM_TWO && simTwo != common.string.EMPTY_STR) {
            smsNumber = simTwo;
        } else {
            // Invoke the API to obtain the information.
            telephonySMS.getSmscAddr(slotId).then((simPhoneNumber) => {
                smsNumber = simPhoneNumber;
                if (slotId == common.int.SIM_ONE) {
                    MmsPreferences.getInstance().setValueForSwitch(common.string.KEY_OF_NEW_SIM_0_SMSC, simPhoneNumber);
                } else if (slotId == common.int.SIM_TWO) {
                    MmsPreferences.getInstance().setValueForSwitch(common.string.KEY_OF_NEW_SIM_1_SMSC, simPhoneNumber);
                }
                callback(smsNumber);
            }).catch((error) => {
                HiLog.e(TAG, "get SMSC number error: " + JSON.stringify(error.message));
            });
        }
        callback(smsNumber);
    }

    queryMessageInSimCard(actionData, callback) {
        let index = actionData.index - 1;
        // Currently, the API for obtaining SIM card information is not provided. Obtaining SIM card SMS messages
        let simMessageList = [];
        telephonySMS.getAllSimMessages(index, (error, msgArray) => {
            if (error) {
                HiLog.e(TAG, "queryMessageInSimCard, error: " + JSON.stringify(error.message));
                return;
            }
            for (let i = 0;i < msgArray.length; i++) {
                let data: LooseObject = {};
                data.image = "/common/icon/user_avatar_full_fill.svg";
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
                HiLog.e(TAG, "delSimMessage, error: " + JSON.stringify(error.message));
            } else {
            }
        });
    }

    getSimCardNum() {
        telephonySim.hasSimCard(common.int.SIM_ONE, (error, value) => {
            if (error) {
                HiLog.e(TAG, "getSimCardNum, SIM_ONE error: " + JSON.stringify(error.message));
            } else {
                let result = value ? common.bool.TRUE : common.bool.FALSE;
                MmsPreferences.getInstance().setValueForSwitch(common.string.KEY_OF_SIM_0_EXIST_FLAG, result);
            }
        });
        telephonySim.hasSimCard(common.int.SIM_TWO, (error, value) => {
            if (error) {
                HiLog.e(TAG, "getSimCardNum, SIM_TWO error: " + JSON.stringify(error.message));
            } else {
                let result = value ? common.bool.TRUE : common.bool.FALSE;
                MmsPreferences.getInstance().setValueForSwitch(common.string.KEY_OF_SIM_1_EXIST_FLAG, result);
            }
        });
    }

    getSimTelephoneNumber() {
        HiLog.i(TAG, "get sim telephone number start");
        telephonySim.getSimTelephoneNumber(common.int.SIM_ONE, (error, value) => {
            if (error) {
                HiLog.e(TAG, "get SIM_ONE telephone number error: " + JSON.stringify(error.message));
            } else {
                MmsPreferences.getInstance().setValueForSwitch(common.string.KEY_OF_SIM_0_NUMBER, value);
            }
        });
        telephonySim.getSimTelephoneNumber(common.int.SIM_TWO, (error, value) => {
            if (error) {
                HiLog.e(TAG, "get SIM_TWO telephone number error: " + JSON.stringify(error.message));
            } else {
                MmsPreferences.getInstance().setValueForSwitch(common.string.KEY_OF_SIM_1_NUMBER, value);
            }
        });
    }
}