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

import common from '../../default/pages/common_constants.js';
import dataStorage from '@ohos.data.storage';
import featureAbility from '@ohos.ability.featureAbility';
import mmsLog from '../utils/MmsLog.js';
const TAG = 'PreferencesUtil.js->';

var prefIns = undefined;
/**
 * 获取轻量级偏好数据库实例
 */

export default {

    async initDataStorage() {
        let context = featureAbility.getContext();
        let path = await context.getFilesDir();
        prefIns = dataStorage.getStorageSync(path + common.string.PATH_OF_PREFERENCES);
    },

    getPreferencesInstance() {
        if (prefIns == null) {
            mmsLog.error(TAG + 'getPreferencesInstance(): failed to get preferences instance');
        }
        return prefIns;
    },

    /**
     * 获取值
     *
     * @param {string} key value值
     */
    getValue(key) {
        let prefIns = this.getPreferencesInstance();
        return prefIns.getSync(key, common.string.EMPTY_STR);
    },

    getValueOfIntegrationSwitch() {
        let prefIns = this.getPreferencesInstance();
        return prefIns.getSync(common.string.KEY_OF_INTEGRATION_SWITCH, common.bool.TRUE);
    },

    getValueOfMaliciousWebSwitch() {
        let prefIns = this.getPreferencesInstance();
        return prefIns.getSync(common.string.KEY_OF_MALICIOUS_WEB_SWITCH, common.bool.FALSE);
    },

    getValueOfShowContactSwitch() {
        let prefIns = this.getPreferencesInstance();
        return prefIns.getSync(common.string.KEY_OF_SHOW_CONTACT_SWITCH, common.bool.TRUE);
    },

    getValueOfDeliveryReportSwitch() {
        let prefIns = this.getPreferencesInstance();
        return prefIns.getSync(common.string.KEY_OF_DELIVERY_REPORT_SWITCH, common.DELIVERY_REPORTS.DISABLED);
    },

    getValueOfAutoRetrieveMmsSwitch() {
        let prefIns = this.getPreferencesInstance();
        return prefIns.getSync(common.string.KEY_OF_AUTO_RETRIEVE_SWITCH, common.AUTO_RETRIEVE_MMS.NOT_WHEN_ROAMING);
    },

    getValueOfRecallMessageSwitch() {
        let prefIns = this.getPreferencesInstance();
        return prefIns.getSync(common.string.KEY_OF_RECALL_MESSAGE_SWITCH, common.bool.FALSE);
    },

    getValueOfAutoDeleteInfoSwitch() {
        let prefIns = this.getPreferencesInstance();
        return prefIns.getSync(common.string.KEY_OF_AUTO_DELETE_INFO_SWITCH, common.bool.FALSE);
    },

    getCountOfSim() {
        let count = 0;
        if (this.getSim1ExistFlag() === common.bool.TRUE) {
            count++;
        }
        if (this.getSim2ExistFlag() == common.bool.TRUE) {
            count++;
        }
        return count;
    },

    /**
     * 获取sim卡1是否存在
     */
    getSim1ExistFlag() {
        let prefIns = this.getPreferencesInstance();
        return prefIns.getSync(common.string.KEY_OF_SIM_0_EXIST_FLAG, common.bool.FALSE);
    },

    getSim2ExistFlag() {
        let prefIns = this.getPreferencesInstance();
        return prefIns.getSync(common.string.KEY_OF_SIM_1_EXIST_FLAG, common.bool.FALSE);
    },

    getSpnOfSim1() {
        let prefIns = this.getPreferencesInstance();
        return prefIns.getSync(common.string.KEY_OF_SIM_0_SPN, common.string.EMPTY_STR);
    },

    getSpnOfSim2() {
        let prefIns = this.getPreferencesInstance();
        return prefIns.getSync(common.string.KEY_OF_SIM_1_SPN, common.string.EMPTY_STR);
    },

    getNewSmscOfSim1() {
        let prefIns = this.getPreferencesInstance();
        return prefIns.getSync(common.string.KEY_OF_NEW_SIM_0_SMSC, common.string.EMPTY_STR);
    },

    getNewSmscOfSim2() {
        let prefIns = this.getPreferencesInstance();
        return prefIns.getSync(common.string.KEY_OF_NEW_SIM_1_SMSC, common.string.EMPTY_STR);
    },

    /**
     * 给设置值
     */
    setValueForSwitch(keyOfSwitch, valueOfSwitch) {
        mmsLog.info('setValueForSwitch start:' + keyOfSwitch + 'valueOfSwitch:' + valueOfSwitch);
        prefIns.putSync(keyOfSwitch, valueOfSwitch);
        prefIns.flushSync();
    }
};