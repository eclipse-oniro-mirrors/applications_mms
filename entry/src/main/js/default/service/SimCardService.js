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

import CardModel from '../model/cardInfoImpl/CardModel.js'

let cardModel = new CardModel();

import common from '../pages/common_constants.js';
import mmsLog from '../utils/MmsLog.js';

export default {

    /**
     * 设置SIM卡信息
     *
     * @param {Object} preferences 偏量数据库
     */
    simInfoHandler(preferences) {
        cardModel.getSimSpn(preferences);
    },

    /**
     * 查询短信中心号码
     * @param actionData 参数
     * @param callback 回调
     * @return
     */
    querySmscNumber(actionData, callback) {
        let result = {};
        let index = actionData.index - 1;
        mmsLog.log('querySmscNumber,slotId:' + index);
        cardModel.getSmscNumber(index, actionData.preferences, smsNumber => {
            result.code = common.int.SUCCESS;
            result.smsNumber = smsNumber;
            callback(result);
        });
    },

    /**
     * 查询sim卡短信信息
     * @param actionData 参数
     * @param callback 回调
     * @return
     */
    queryMessageInSimCard(actionData, callback) {
        cardModel.queryMessageInSimCard(actionData, callback);
    },

    /**
     * 获取sim卡的数量
     *
     * @param {Object} preferences 偏量数据库
     */
    initSimCardNum(preferences) {
        cardModel.getSimCardNum(preferences);
    },
    delSimMessage(actionData) {
        cardModel.delSimMessage(actionData);
    }
}