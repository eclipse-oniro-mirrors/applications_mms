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
  private static sMap = new Map<string, string | number | boolean>();
  private preferences: preferences.Preferences;
  private static readonly PREFERENCES_Mms_FORM_STORE = 'MmsStore'

  getInstance(): MmsPreferences {
    if (MmsPreferences.sInstance == null) {
      MmsPreferences.sInstance = new MmsPreferences();
    }
    return MmsPreferences.sInstance;
  }

  public async initPreferences(): Promise<void> {
    if (this.preferences != null) {
      return;
    }

    try {
      this.preferences = await preferences.getPreferences(globalThis.mmsContext,
      MmsPreferences.PREFERENCES_Mms_FORM_STORE);
      this.initMapData();
    } catch (err) {
      HiLog.i(TAG, `initPreferences err ${err}`);
    }
  }

  /**
   * Init data to map
   */
  initMapData(): void {
    this.asyncGetValueFromPreferences(common.string.KEY_OF_INTEGRATION_SWITCH);
    this.asyncGetValueFromPreferences(common.string.KEY_OF_MALICIOUS_WEB_SWITCH);
    this.asyncGetValueFromPreferences(common.string.KEY_OF_SHOW_CONTACT_SWITCH);
    this.asyncGetValueFromPreferences(common.string.KEY_OF_DELIVERY_REPORT_SWITCH);
    this.asyncGetValueFromPreferences(common.string.KEY_OF_AUTO_RETRIEVE_SWITCH);
    this.asyncGetValueFromPreferences(common.string.KEY_OF_RECALL_MESSAGE_SWITCH);
    this.asyncGetValueFromPreferences(common.string.KEY_OF_AUTO_DELETE_INFO_SWITCH);
  }

  /**
   * Get value from preferences
   */
  async getValueFromPreferences(key: string) {
    if (this.preferences == null) {
      HiLog.i(TAG, `getValueFromPreferences preferences is null`);
      return common.string.EMPTY_STR;
    }
    try {
      let value = await this.preferences.get(key, common.string.EMPTY_STR);
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
  async asyncGetValueFromPreferences(key: string): Promise<string> {
    if (this.preferences == null) {
      HiLog.i(TAG, `asyncGetValueByKeyFromPreferences preferences is null`);
      return common.string.EMPTY_STR;
    }
    let getPromise = this.preferences.get(key, common.string.EMPTY_STR);
    getPromise.then((value) => {
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
  public getValueOfIntegrationSwitch(): string {
    return <string> this.getValueFromMap(common.string.KEY_OF_INTEGRATION_SWITCH, common.bool.TRUE);
  }

  /**
   * Obtains the value of the malicious URL identification switch.
   */
  public getValueOfMaliciousWebSwitch(): string {
    return <string> this.getValueFromMap(common.string.KEY_OF_MALICIOUS_WEB_SWITCH, common.bool.FALSE);
  }

  /**
   * Obtains the value of the switch for displaying contact avatars.
   */
  public getValueOfShowContactSwitch(): string {
    return <string> this.getValueFromMap(common.string.KEY_OF_SHOW_CONTACT_SWITCH, common.bool.TRUE);
  }

  /**
   * Obtains the value of the delivery report switch.
   */
  public getValueOfDeliveryReportSwitch(): string {
    return <string> this.getValueFromMap(common.string.KEY_OF_DELIVERY_REPORT_SWITCH, common.DELIVERY_REPORTS.DISABLED);
  }

  /**
   * Obtains the value of the function of automatically downloading MMS messages.
   */
  public getValueOfAutoRetrieveMmsSwitch(): string {
    return <string> this.getValueFromMap(common.string.KEY_OF_AUTO_RETRIEVE_SWITCH,
    common.AUTO_RETRIEVE_MMS.NOT_WHEN_ROAMING);
  }

  /**
   * Obtains the value of the send cancel switch.
   */
  public getValueOfRecallMessageSwitch(): string {
    return <string> this.getValueFromMap(common.string.KEY_OF_RECALL_MESSAGE_SWITCH, common.bool.FALSE);
  }

  /**
   * Obtains the value of the automatic deletion notification switch.
   */
  public getValueOfAutoDeleteInfoSwitch(): string {
    return <string> this.getValueFromMap(common.string.KEY_OF_AUTO_DELETE_INFO_SWITCH, common.bool.FALSE);
  }

  public isMultiSimCardEnabled(): boolean {
    if (this.getMaxSimCount() === common.int.SIM_COUNT) {
      return true;
    }
    return false;
  }

  public getMaxSimCount(): number {
    return <number> this.getValueFromMap(common.string.KEY_OF_MAX_SIM_COUNT, common.int.SIM_ONE);
  }

  public haveMultiSimCardReady(): boolean {
    return <boolean> this.getValueFromMap(common.string.KEY_OF_HAVE_MULTI_SIM_CARD_READY, false);
  }

  public haveSimCardReady(): boolean {
    return <boolean> this.getValueFromMap(common.string.KEY_OF_HAVE_SIM_CARD_READY, false);
  }

  public getSpnOfSim1(): string {
    return <string> this.getValueFromMap(common.string.KEY_OF_SIM_0_SPN, common.string.EMPTY_STR);
  }

  public getSpnOfSim2(): string {
    return <string> this.getValueFromMap(common.string.KEY_OF_SIM_1_SPN, common.string.EMPTY_STR);
  }

  public getNewSmscOfSim1(): string {
    return <string> this.getValueFromMap(common.string.KEY_OF_NEW_SIM_0_SMSC, common.string.EMPTY_STR);
  }

  public getNewSmscOfSim2(): string {
    return <string> this.getValueFromMap(common.string.KEY_OF_NEW_SIM_1_SMSC, common.string.EMPTY_STR);
  }

  public getTelephoneNumberOfSim1(): string {
    return <string> this.getValueFromMap(common.string.KEY_OF_SIM_0_NUMBER, common.string.EMPTY_STR);
  }

  public getTelephoneNumberOfSim2(): string {
    return <string> this.getValueFromMap(common.string.KEY_OF_SIM_1_NUMBER, common.string.EMPTY_STR);
  }

  public getSelectedSlotId(): number {
    return <number> this.getValueFromMap(common.string.KEY_OF_SELECTED_SLOTID, common.int.SIM_ONE);
  }

  public getDefaultSlotId(): number {
    return <number> this.getValueFromMap(common.string.KEY_OF_DEFAULT_SLOT, common.int.SIM_ONE);
  }

  public getSendMessageSlotId(): number {
    let sendMsgSlotId: number = common.int.SIM_ONE;
    if (this.haveMultiSimCardReady()) {
      sendMsgSlotId = this.getSelectedSlotId();
    } else {
      sendMsgSlotId = this.getDefaultSlotId();
    }
    return sendMsgSlotId;
  }

  /**
   * Set a value to preferences
   *
   * @param keyOfSwitch
   * @param valueOfSwitch
   */
  public setValueForSwitch(keyOfSwitch: string, valueOfSwitch: string): void {
    this.setValueToMap(keyOfSwitch, valueOfSwitch);
    if (this.preferences == null) {
      HiLog.i(TAG, `setValueForSwitch preferences is null`);
      return
    }
    let putPromise = this.preferences.put(keyOfSwitch, valueOfSwitch);
    putPromise.then(() => {
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
  public getValueFromMap(key: string, defaultValue: string | number | boolean):
  string | number | boolean {
    let value = MmsPreferences.sMap.get(key);
    if (value == null) {
      value = defaultValue;
    }
    return value;
  }

  /**
   * Set key-value to map
   *
   * @param key
   * @param value
   */
  public setValueToMap(key: string, value: string | number | boolean): void {
    MmsPreferences.sMap.set(key, value);
  }
}

let dataStore = createOrGet(MmsPreferences, TAG);

export default dataStore as MmsPreferences;