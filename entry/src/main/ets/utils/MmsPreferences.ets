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

import common from "../data/commonData";
import dataStorage from "@ohos.data.storage";
import featureAbility from "@ohos.ability.featureAbility";
import HiLog from "./HiLog";

const TAG = "MmsPreferences";

/**
 * Obtaining a Lightweight Preference Database Instance
 */
export default class MmsPreferences {
    private static sInstance: MmsPreferences;
    private mPref = null;

    static getInstance() {
        if (MmsPreferences.sInstance == null) {
            MmsPreferences.sInstance = new MmsPreferences();
        }
        return MmsPreferences.sInstance;
    }

    async initPreferences() {
        if (this.mPref == null) {
            let context = globalThis.mmsContext;
            let path = await context.getFilesDir();
            this.mPref = await dataStorage.getStorage(path + common.string.PATH_OF_PREFERENCES);
            HiLog.i(TAG, "init preferences finish");
        }
    }

    /**
     * Obtaining Values
     *
     * @param {string} key value
     */
    getValue(key) {
        if (this.mPref !== null) {
            return this.mPref.getSync(key, common.string.EMPTY_STR);
        } else {
            HiLog.w(TAG, "mPref is null, get " + key + " fail.");
            return common.string.EMPTY_STR;
        }
    }

    /**
     * Obtains the value of the notification integration switch.
     */
    getValueOfIntegrationSwitch() {
        if (this.mPref !== null) {
            return this.mPref.getSync(common.string.KEY_OF_INTEGRATION_SWITCH, common.bool.TRUE);
        } else {
            HiLog.w(TAG, "mPref is null, get " + common.string.KEY_OF_INTEGRATION_SWITCH + " fail.");
            return common.bool.TRUE;
        }
    }

    /**
     * Obtains the value of the malicious URL identification switch.
     */
    getValueOfMaliciousWebSwitch() {
        if (this.mPref !== null) {
            return this.mPref.getSync(common.string.KEY_OF_MALICIOUS_WEB_SWITCH, common.bool.FALSE);
        } else {
            HiLog.w(TAG, "mPref is null, get " + common.string.KEY_OF_MALICIOUS_WEB_SWITCH + " fail.");
            return common.bool.FALSE;
        }
    }

    /**
     * Obtains the value of the switch for displaying contact avatars.
     */
    getValueOfShowContactSwitch() {
        if (this.mPref !== null) {
            return this.mPref.getSync(common.string.KEY_OF_SHOW_CONTACT_SWITCH, common.bool.TRUE);
        } else {
            HiLog.w(TAG, "mPref is null, get " + common.string.KEY_OF_SHOW_CONTACT_SWITCH + " fail.");
            return common.bool.TRUE;
        }
    }

    /**
     * Obtains the value of the delivery report switch.
     */
    getValueOfDeliveryReportSwitch() {
        if (this.mPref !== null) {
            return this.mPref.getSync(common.string.KEY_OF_DELIVERY_REPORT_SWITCH, common.DELIVERY_REPORTS.DISABLED);
        } else {
            HiLog.w(TAG, "mPref is null, get " + common.string.KEY_OF_DELIVERY_REPORT_SWITCH + " fail.");
            return common.DELIVERY_REPORTS.DISABLED;
        }
    }

    /**
     * Obtains the value of the function of automatically downloading MMS messages.
     */
    getValueOfAutoRetrieveMmsSwitch() {
        if (this.mPref !== null) {
            return this.mPref.getSync(common.string.KEY_OF_AUTO_RETRIEVE_SWITCH,
            common.AUTO_RETRIEVE_MMS.NOT_WHEN_ROAMING);
        } else {
            HiLog.w(TAG, "mPref is null, get " + common.string.KEY_OF_AUTO_RETRIEVE_SWITCH + " fail.");
            return common.AUTO_RETRIEVE_MMS.NOT_WHEN_ROAMING;
        }
    }

    /**
     * Obtains the value of the send cancel switch.
     */
    getValueOfRecallMessageSwitch() {
        if (this.mPref !== null) {
            return this.mPref.getSync(common.string.KEY_OF_RECALL_MESSAGE_SWITCH, common.bool.FALSE);
        } else {
            HiLog.w(TAG, "mPref is null, get " + common.string.KEY_OF_RECALL_MESSAGE_SWITCH + " fail.");
            return common.bool.FALSE;
        }
    }

    /**
     * Obtains the value of the automatic deletion notification switch.
     */
    getValueOfAutoDeleteInfoSwitch() {
        if (this.mPref !== null) {
            return this.mPref.getSync(common.string.KEY_OF_AUTO_DELETE_INFO_SWITCH, common.bool.FALSE);
        } else {
            HiLog.w(TAG, "mPref is null, get " + common.string.KEY_OF_AUTO_DELETE_INFO_SWITCH + " fail.");
            return common.bool.FALSE;
        }
    }

    /**
     * Obtains the number of SIM cards.
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
    }

    /**
     * Check whether SIM card 1 exists.
     */
    getSim1ExistFlag() {
        if (this.mPref !== null) {
            return this.mPref.getSync(common.string.KEY_OF_SIM_0_EXIST_FLAG, common.bool.FALSE);
        } else {
            HiLog.w(TAG, "mPref is null, get " + common.string.KEY_OF_SIM_0_EXIST_FLAG + " fail.");
            return common.bool.FALSE;
        }
    }

    /**
     * Check whether SIM card 2 exists.
     */
    getSim2ExistFlag() {
        if (this.mPref !== null) {
            return this.mPref.getSync(common.string.KEY_OF_SIM_1_EXIST_FLAG, common.bool.FALSE);
        } else {
            HiLog.w(TAG, "mPref is null, get " + common.string.KEY_OF_SIM_1_EXIST_FLAG + " fail.");
            return common.bool.FALSE;
        }
    }

    /**
     * Obtain the carrier name of SIM card 1.
     */
    getSpnOfSim1() {
        if (this.mPref !== null) {
            return this.mPref.getSync(common.string.KEY_OF_SIM_0_SPN, common.string.EMPTY_STR);
        } else {
            HiLog.w(TAG, "mPref is null, get " + common.string.KEY_OF_SIM_0_SPN + " fail.");
            return common.string.EMPTY_STR;
        }
    }

    /**
     * Obtain the carrier name of SIM card 2.
     */
    getSpnOfSim2() {
        if (this.mPref !== null) {
            return this.mPref.getSync(common.string.KEY_OF_SIM_1_SPN, common.string.EMPTY_STR);
        } else {
            HiLog.w(TAG, "mPref is null, get " + common.string.KEY_OF_SIM_1_SPN + " fail.");
            return common.string.EMPTY_STR;
        }
    }

    /**
     * Obtain the new SMSC number of SIM card 1. If the number has been changed,
     */
    getNewSmscOfSim1() {
        if (this.mPref !== null) {
            return this.mPref.getSync(common.string.KEY_OF_NEW_SIM_0_SMSC, common.string.EMPTY_STR);
        } else {
            HiLog.w(TAG, "mPref is null, get " + common.string.KEY_OF_NEW_SIM_0_SMSC + " fail.");
            return common.string.EMPTY_STR;
        }
    }

    /**
     * Obtain the new SMSC number of SIM card 2. If the number has been changed,
     */
    getNewSmscOfSim2() {
        if (this.mPref !== null) {
            return this.mPref.getSync(common.string.KEY_OF_NEW_SIM_1_SMSC, common.string.EMPTY_STR);
        } else {
            HiLog.w(TAG, "mPref is null, get " + common.string.KEY_OF_NEW_SIM_1_SMSC + " fail.");
            return common.string.EMPTY_STR;
        }
    }

    /**
     * Set a value for
     */
    setValueForSwitch(keyOfSwitch, valueOfSwitch) {
        if (this.mPref !== null) {
            this.mPref.putSync(keyOfSwitch, valueOfSwitch);
            this.mPref.flushSync();
        } else {
            HiLog.w(TAG, "mPref is null, set " + keyOfSwitch + " fail.");
        }
    }
}