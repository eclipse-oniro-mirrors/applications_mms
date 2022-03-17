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

import appStorage from './AppStorageUtil';
import common from '../data/commonData';
import dataStorage from '@ohos.data.storage';
import featureAbility from '@ohos.ability.featureAbility';
import HiLog from './HiLog';
const TAG = 'PreferencesUtil';

var prefIns = undefined;

/**
 * 获取轻量级偏好数据库实例
 */
export default {

    async initDataStorage() {
        let context = featureAbility.getContext();
        let path = await context.getFilesDir();
        return dataStorage.getStorageSync(path + common.string.PATH_OF_PREFERENCES);
    },

    getPreferencesInstance() {
        return appStorage.getPreferences();
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

    /**
     * 获取通知信息整合开关的值
     */
    getValueOfIntegrationSwitch() {
        let prefIns = this.getPreferencesInstance();
        return prefIns.getSync(common.string.KEY_OF_INTEGRATION_SWITCH, common.bool.TRUE);
    },

    /**
     * 获取恶意网址识别开关的值
     */
    getValueOfMaliciousWebSwitch() {
        let prefIns = this.getPreferencesInstance();
        return prefIns.getSync(common.string.KEY_OF_MALICIOUS_WEB_SWITCH, common.bool.FALSE);
    },

    /**
     * 获取显示联系人头像开关的值
     */
    getValueOfShowContactSwitch() {
        let prefIns = this.getPreferencesInstance();
        return prefIns.getSync(common.string.KEY_OF_SHOW_CONTACT_SWITCH, common.bool.TRUE);
    },

    /**
     * 获取送达报告开关的值
     */
    getValueOfDeliveryReportSwitch() {
        let prefIns = this.getPreferencesInstance();
        return prefIns.getSync(common.string.KEY_OF_DELIVERY_REPORT_SWITCH, common.DELIVERY_REPORTS.DISABLED);
    },

    /**
     * 获取自动下载彩信开关的值
     */
    getValueOfAutoRetrieveMmsSwitch() {
        let prefIns = this.getPreferencesInstance();
        return prefIns.getSync(common.string.KEY_OF_AUTO_RETRIEVE_SWITCH, common.AUTO_RETRIEVE_MMS.NOT_WHEN_ROAMING);
    },

    /**
     * 获取取消发送开关的值
     */
    getValueOfRecallMessageSwitch() {
        let prefIns = this.getPreferencesInstance();
        return prefIns.getSync(common.string.KEY_OF_RECALL_MESSAGE_SWITCH, common.bool.FALSE);
    },

    /**
     * 获取自动删除通知信息开关的值
     */
    getValueOfAutoDeleteInfoSwitch() {
        let prefIns = this.getPreferencesInstance();
        return prefIns.getSync(common.string.KEY_OF_AUTO_DELETE_INFO_SWITCH, common.bool.FALSE);
    },

    /**
     * 获取sim卡的个数
     */
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

    /**
     * 获取sim卡2是否存在
     */
    getSim2ExistFlag() {
        let prefIns = this.getPreferencesInstance();
        return prefIns.getSync(common.string.KEY_OF_SIM_1_EXIST_FLAG, common.bool.FALSE);
    },

    /**
     * 获取sim卡1的运营商名字
     */
    getSpnOfSim1() {
        let prefIns = this.getPreferencesInstance();
        return prefIns.getSync(common.string.KEY_OF_SIM_0_SPN, common.string.EMPTY_STR);
    },

    /**
     * 获取sim卡2的运营商名字
     */
    getSpnOfSim2() {
        let prefIns = this.getPreferencesInstance();
        return prefIns.getSync(common.string.KEY_OF_SIM_1_SPN, common.string.EMPTY_STR);
    },

    /**
     * 获取sim卡1的新的短信中心号码，如果被修改过
     */
    getNewSmscOfSim1() {
        let prefIns = this.getPreferencesInstance();
        return prefIns.getSync(common.string.KEY_OF_NEW_SIM_0_SMSC, common.string.EMPTY_STR);
    },

    /**
     * 获取sim卡2的新的短信中心号码，如果被修改过
     */
    getNewSmscOfSim2() {
        let prefIns = this.getPreferencesInstance();
        return prefIns.getSync(common.string.KEY_OF_NEW_SIM_1_SMSC, common.string.EMPTY_STR);
    },

    /**
     * 给设置值
     */
    setValueForSwitch(keyOfSwitch, valueOfSwitch) {
        let prefIns = this.getPreferencesInstance();
        HiLog.i(TAG, 'setValueForSwitch, keyOfSwitch=' + keyOfSwitch + ', valueOfSwitch=' + valueOfSwitch);
        prefIns.putSync(keyOfSwitch, valueOfSwitch);
        prefIns.flushSync();
    }
}