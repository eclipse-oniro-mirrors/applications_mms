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
import LooseObject from "../data/LooseObject";
import HiLog from "./HiLog";

import createOrGet from "./SingleInstanceUtils";
import preferences from "@ohos.data.preferences";

const TAG = "MmsPreferences";

/**
 * Obtaining a Lightweight Preference Database Instance
 */
class MmsPreferences {
    private static sInstance: MmsPreferences;
    private static sMap = new Map<string, string>();
    private preferences: preferences.Preferences = undefined;
    private static readonly PREFERENCES_Mms_FORM_STORE = 'MmsStore'

    getInstance():MmsPreferences {
        if (MmsPreferences.sInstance == null) {
            MmsPreferences.sInstance = new MmsPreferences();
        }
        return MmsPreferences.sInstance;
    }

    public async initPreferences(): Promise<void> {
        if (this.preferences != undefined) {
            return;
        }

        try {
            this.preferences = await preferences.getPreferences(globalThis.mmsContext,
            MmsPreferences.PREFERENCES_Mms_FORM_STORE);
            HiLog.i(TAG, `initPreferences sucess`);
            this.initMapData();
        } catch (err) {
            HiLog.i(TAG, `initPreferences err ${err}`);
        }
    }

    /**
     * Init data to map
     */
    initMapData() {
        this.asyncGetValueFromPreferences(common.string.KEY_OF_INTEGRATION_SWITCH);
        this.asyncGetValueFromPreferences(common.string.KEY_OF_MALICIOUS_WEB_SWITCH);
        this.asyncGetValueFromPreferences(common.string.KEY_OF_SHOW_CONTACT_SWITCH);
        this.asyncGetValueFromPreferences(common.string.KEY_OF_DELIVERY_REPORT_SWITCH);
        this.asyncGetValueFromPreferences(common.string.KEY_OF_AUTO_RETRIEVE_SWITCH);
        this.asyncGetValueFromPreferences(common.string.KEY_OF_RECALL_MESSAGE_SWITCH);
        this.asyncGetValueFromPreferences(common.string.KEY_OF_AUTO_DELETE_INFO_SWITCH);
        this.asyncGetValueFromPreferences(common.string.KEY_OF_SIM_0_EXIST_FLAG);
        this.asyncGetValueFromPreferences(common.string.KEY_OF_SIM_1_EXIST_FLAG);
        this.asyncGetValueFromPreferences(common.string.KEY_OF_SIM_0_SPN);
        this.asyncGetValueFromPreferences(common.string.KEY_OF_NEW_SIM_0_SMSC);
        this.asyncGetValueFromPreferences(common.string.KEY_OF_NEW_SIM_1_SMSC);
        this.asyncGetValueFromPreferences(common.string.KEY_OF_SIM_0_NUMBER);
        this.asyncGetValueFromPreferences(common.string.KEY_OF_SIM_1_NUMBER);
        this.asyncGetValueFromPreferences(common.string.KEY_OF_SELECTED_SLOTID);
    }

    /**
     * Get value from preferences
     */
    async getValueFromPreferences(key:string) {
        if (this.preferences == undefined) {
            HiLog.i(TAG, `getValueFromPreferences preferences is undefined`);
            return common.string.EMPTY_STR;
        }
        try {
            let value = await this.preferences.get(key, common.string.EMPTY_STR);
            HiLog.i(TAG, "getValueFromPreferences(" + key + "):" + value);
            this.setValueToMap(key, value.toString());
            return value;
        } catch (err) {
            HiLog.i(TAG, "getValueFromPreferences(" + key + ") failed with err: " + JSON.stringify(err))
            return common.string.EMPTY_STR;
        }
    }

    /**
     * Async get value from preferences
     */
    async asyncGetValueFromPreferences(key:string):Promise<string> {
        if (this.preferences == undefined) {
            HiLog.i(TAG, `asyncGetValueByKeyFromPreferences preferences is undefined`);
            return common.string.EMPTY_STR;
        }
        let getPromise = this.preferences.get(key, common.string.EMPTY_STR);
        getPromise.then((value) => {
            HiLog.i(TAG, "asyncGetValueFromPreferences(" + key + "):" + value);
            this.setValueToMap(key, value.toString());
            return value;
        }).catch((err) => {
            HiLog.i(TAG, "asyncGetValueFromPreferences(" + key + ") failed with err: " + JSON.stringify(err))
            return common.string.EMPTY_STR;
        });
    }

    /**
     * Obtains the value of the notification integration switch.
     */
    getValueOfIntegrationSwitch():string {
        return this.getValueFromMap(common.string.KEY_OF_INTEGRATION_SWITCH, common.bool.TRUE);
    }

    /**
     * Obtains the value of the malicious URL identification switch.
     */
    getValueOfMaliciousWebSwitch():string {
        return this.getValueFromMap(common.string.KEY_OF_MALICIOUS_WEB_SWITCH, common.bool.FALSE);
    }

    /**
     * Obtains the value of the switch for displaying contact avatars.
     */
    getValueOfShowContactSwitch():string {
        return this.getValueFromMap(common.string.KEY_OF_SHOW_CONTACT_SWITCH, common.bool.TRUE);
    }

    /**
     * Obtains the value of the delivery report switch.
     */
    getValueOfDeliveryReportSwitch():string {
        return this.getValueFromMap(common.string.KEY_OF_DELIVERY_REPORT_SWITCH, common.DELIVERY_REPORTS.DISABLED);
    }

    /**
     * Obtains the value of the function of automatically downloading MMS messages.
     */
    getValueOfAutoRetrieveMmsSwitch():string {
        return this.getValueFromMap(common.string.KEY_OF_AUTO_RETRIEVE_SWITCH,
        common.AUTO_RETRIEVE_MMS.NOT_WHEN_ROAMING);
    }

    /**
     * Obtains the value of the send cancel switch.
     */
    getValueOfRecallMessageSwitch():string {
        return this.getValueFromMap(common.string.KEY_OF_RECALL_MESSAGE_SWITCH, common.bool.FALSE);
    }

    /**
     * Obtains the value of the automatic deletion notification switch.
     */
    getValueOfAutoDeleteInfoSwitch():string {
        return this.getValueFromMap(common.string.KEY_OF_AUTO_DELETE_INFO_SWITCH, common.bool.FALSE);
    }

    /**
     * Obtains the number of SIM cards.
     */
    getCountOfSim():number {
        let count = 0;
        if (this.getValueFromMap(common.string.KEY_OF_SIM_0_EXIST_FLAG, common.bool.FALSE) === common.bool.TRUE) {
            count++;
        }
        if (this.getValueFromMap(common.string.KEY_OF_SIM_1_EXIST_FLAG, common.bool.FALSE) === common.bool.TRUE) {
            count++;
        }
        return count;
    }

    /**
     * Check if the multicard is in place
     */
    isMultiSimCardEnabled():boolean {
        if (this.getCountOfSim() === common.int.SIM_COUNT) {
            return true;
        }
        return false;
    }

    /**
     * Check whether SIM card 1 exists.
     */
    getSim1ExistFlag():string {
        return this.getValueFromMap(common.string.KEY_OF_SIM_0_EXIST_FLAG, common.bool.TRUE);
    }

    /**
     * Check whether SIM card 2 exists.
     */
    getSim2ExistFlag():string {
        return this.getValueFromMap(common.string.KEY_OF_SIM_1_EXIST_FLAG, common.bool.FALSE);
    }

    /**
     * Obtain the carrier name of SIM card 1.
     */
    getSpnOfSim1():string {
        return this.getValueFromMap(common.string.KEY_OF_SIM_0_SPN, common.string.EMPTY_STR);
    }

    /**
     * Obtain the carrier name of SIM card 2.
     */
    getSpnOfSim2():string {
        return this.getValueFromMap(common.string.KEY_OF_SIM_1_SPN, common.string.EMPTY_STR);
    }

    /**
     * Obtain the new SMSC number of SIM card 1. If the number has been changed,
     */
    getNewSmscOfSim1():string {
        return this.getValueFromMap(common.string.KEY_OF_NEW_SIM_0_SMSC, common.string.EMPTY_STR);
    }

    /**
     * Obtain the new SMSC number of SIM card 2. If the number has been changed,
     */
    getNewSmscOfSim2():string {
        return this.getValueFromMap(common.string.KEY_OF_NEW_SIM_1_SMSC, common.string.EMPTY_STR);
    }

    /**
     * Obtain the telephone number of SIM card 1.
     */
    getTelephoneNumberOfSim1():string {
        return this.getValueFromMap(common.string.KEY_OF_SIM_0_NUMBER, common.string.EMPTY_STR);
    }

    /**
     * Obtain the telephone number of SIM card 2.
     */
    getTelephoneNumberOfSim2():string {
        return this.getValueFromMap(common.string.KEY_OF_SIM_1_NUMBER, common.string.EMPTY_STR);
    }

    /**
     * Set a value to preferences
     *
     * @param keyOfSwitch
     * @param valueOfSwitch
     */
    setValueForSwitch(keyOfSwitch: string, valueOfSwitch: string): void {
        this.setValueToMap(keyOfSwitch, valueOfSwitch);
        if (this.preferences == undefined) {
            HiLog.i(TAG, `setValueForSwitch preferences is undefined`);
            return
        }
        let putPromise = this.preferences.put(keyOfSwitch, valueOfSwitch);
        putPromise.then(() => {
            HiLog.i(TAG, "setValueForSwitch key: " + keyOfSwitch + ",value: " + valueOfSwitch + "  success");
            this.preferences.flush();
        }).catch((err) => {
            HiLog.i(TAG, `setValueForSwitch failed with err: ${err}`);
        });
    }

    /**
     * Get value from map by key
     *
     * @param key
     * @param defaultValue
     */
    getValueFromMap(key: string, defaultValue: string): string {
        let value = MmsPreferences.sMap.get(key);
        if (value == undefined || value == null) {
            value = defaultValue;
        }
        HiLog.i(TAG, "getValueFromMap key: " + key + ",value: " + value);
        return value;
    }

    /**
     * Set key-value to map
     *
     * @param key
     * @param value
     */
    setValueToMap(key: string, value: string): void {
        HiLog.i(TAG, "setValueToMap key: " + key + ",value: " + value);
        MmsPreferences.sMap.set(key, value);
    }
}

let dataStore = createOrGet(MmsPreferences, TAG);

export default dataStore as MmsPreferences;