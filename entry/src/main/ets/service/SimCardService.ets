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

import CardModel from "../model/CardModel"
import common from "../data/commonData";
import LooseObject from "../data/LooseObject"
import HiLog from "../utils/HiLog";

let cardModel = new CardModel();

const TAG = "SimCardService";

export default {

    /**
     * Setting SIM Card Information
     *
     * @param {Object} preferences         bias database
     */
    simInfoHandler() {
        cardModel.getSimSpn();
    },

    /**
     * Querying SMSC Numbers
     * @param actionData
     * @param callback
     * @return
     */
    querySmscNumber(actionData, callback) {
        let result: LooseObject = {};
        let index = actionData.index - 1;
        HiLog.i(TAG, "query SMSC number, slotId=" + index);
        cardModel.getSmscNumber(index, smsNumber => {
            result.code = common.int.SUCCESS;
            result.smsNumber = smsNumber;
            callback(result);
        });
    },

    /**
     * Querying SIM Card SMS Messages
     * @param actionData
     * @param callback
     * @return
     */
    queryMessageInSimCard(actionData, callback) {
        cardModel.queryMessageInSimCard(actionData, callback);
    },

    /**
     * Obtains the number of SIM cards.
     *
     * @param {Object} preferences
     */
    initSimCardNum() {
        cardModel.getSimCardNum();
    },

    delSimMessage(actionData) {
        cardModel.delSimMessage(actionData);
    },

    /**
     * Obtains the telephoneNumber from SIM cards.
     */
    getSimTelephoneNumber() {
        cardModel.getSimTelephoneNumber();
    }
}