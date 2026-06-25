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

import common from '../data/commonData';
import SharedPreferencesUtils from './SharedPreferencesUtils';
import createOrGet from './SingleInstanceUtils';
import { sim } from '@kit.TelephonyKit';
import HiLog from '../utils/HiLog'

const TAG = 'MmsPreferences';
const activeTwoCard: number = 2;
const activeCard0: number = 0;
const activeCard1: number = 1;

/**
 * Obtaining a Lightweight Preference Database Instance
 * 老方法，不要用了，用SharedPreferencesUtils
 */
class MmsPreferences {
  private static sInstance: MmsPreferences;
  private static sMap = new Map<string, string | number | boolean>();

  getInstance(): MmsPreferences {
    if (MmsPreferences.sInstance == null) {
      MmsPreferences.sInstance = new MmsPreferences();
    }
    return MmsPreferences.sInstance;
  }

  public async initPreferences(): Promise<void> {
    this.initMapData();
  }

  /**
   * Init data to map
   */
  initMapData(): void {
    this.asyncGetValueFromPreferences(common.STR.KEY_OF_INTEGRATION_SWITCH);
    this.asyncGetValueFromPreferences(common.STR.KEY_OF_SHOW_CONTACT_SWITCH);
    this.asyncGetValueFromPreferences(common.STR.KEY_OF_DELIVERY_REPORT_SWITCH);
    this.asyncGetValueFromPreferences(common.STR.KEY_OF_SHOW_DEL_DIALOG);
    this.asyncGetValueFromPreferences(common.STR.TIME_OF_LAST_DELETE_NOTIFY_MMS);
  }

  /**
   * Get value from preferences
   */
  async getValueFromPreferences(key: string) {
    let value = SharedPreferencesUtils.getFromPreferences(key, common.STR.EMPTY_STR);
    return value;
  }

  /**
   * Async get value from preferences
   */
  async asyncGetValueFromPreferences(key: string): Promise<string> {
    let value = SharedPreferencesUtils.getFromPreferences(key, common.STR.EMPTY_STR);
    this.setValueToMap(key, value.toString());
    return value.toString();
  }

  /**
   * Obtains the value of the notification integration switch.
   */
  public getValueOfIntegrationSwitch(): string {
    return this.getValueFromMap(common.STR.KEY_OF_INTEGRATION_SWITCH, common.bool.TRUE) as string;
  }
  /**
   * Obtains the value of the switch for displaying contact avatars.
   */
  public getValueOfShowContactSwitch(): string {
    return this.getValueFromMap(common.STR.KEY_OF_SHOW_CONTACT_SWITCH, common.bool.TRUE) as string;
  }

  /**
   * Obtains the value of the delivery report switch.
   */
  public getValueOfDeliveryReportSwitch(): string {
    return this.getValueFromMap(common.STR.KEY_OF_DELIVERY_REPORT_SWITCH, common.DELIVERY_REPORTS.DISABLED) as string;
  }

  /**
   * Sets the value of the show delete notification switch.
   */
  public setShowDelDialog(state: string) {
    this.setValueForSwitch(common.STR.KEY_OF_SHOW_DEL_DIALOG, state)
  }

  /**
   * Gets the value of the show delete notification switch.
   */
  public getShowDelDialog(): string {
    return this.getValueFromMap(common.STR.KEY_OF_SHOW_DEL_DIALOG, common.bool.TRUE) as string;
  }

  public isMultiSimCardEnabled(): boolean {
    if (this.getMaxSimCount() === common.int.SIM_COUNT) {
      return true;
    }
    return false;
  }

  public getTimeOfLastDeleteNotifyMms(): number {
    return this.getValueFromMap(common.STR.TIME_OF_LAST_DELETE_NOTIFY_MMS,
      common.int.TIME_OF_LAST_DELETE_NOTIFY_MMS) as number;
  }

  public getMaxSimCount(): number {
    return this.getValueFromMap(common.STR.KEY_OF_MAX_SIM_COUNT, common.int.SIM_ONE) as number;
  }

  public haveMultiSimCardReady(): boolean {
    return this.getValueFromMap(common.STR.KEY_OF_HAVE_MULTI_SIM_CARD_READY, false) as boolean;
  }

  public haveSimCardReady(): boolean {
    return this.getValueFromMap(common.STR.KEY_OF_HAVE_SIM_CARD_READY, false) as boolean;
  }

  public getSpnOfSim1(): string {
    return this.getValueFromMap(common.STR.KEY_OF_SIM_0_SPN, common.STR.EMPTY_STR) as string;
  }

  public getSpnOfSim2(): string {
    return this.getValueFromMap(common.STR.KEY_OF_SIM_1_SPN, common.STR.EMPTY_STR) as string;
  }

  /**
   * 从sp中获取simType
   * @param slotId
   * @returns simType
   */
  public getTypeOfSlot(slotId: number = 0): number {
    if (slotId === 0) {
      return this.getValueFromMap(common.STR.KEY_OF_SLOT_0_TYPE, common.simType.PSIM) as number;
    } else {
      return this.getValueFromMap(common.STR.KEY_OF_SLOT_1_TYPE, common.simType.PSIM) as number;
    }
  }

  /**
   * 从sp中获取index
   * @param slotId
   * @returns index
   */
  public getIndexOfSlot(slotId: number = 0): number {
    if (slotId === 0) {
      return this.getValueFromMap(common.STR.KEY_OF_SLOT_0_INDEX, common.simType.PSIM) as number;
    } else {
      return this.getValueFromMap(common.STR.KEY_OF_SLOT_1_INDEX, common.simType.PSIM) as number;
    }
  }

  /**
   * 从sp中获取IndexName
   * @param slotId
   * @returns IndexName
   */
  public getIndexNameOfSlot(slotId: number = 0): string {
    if (slotId === 0) {
      return this.getValueFromMap(common.STR.KEY_OF_SLOT_0_INDEX_NAME, common.STR.EMPTY_STR) as string;
    } else {
      return this.getValueFromMap(common.STR.KEY_OF_SLOT_1_INDEX_NAME, common.STR.EMPTY_STR) as string;
    }
  }

  public getDispalyNameOfSim1(): string {
    let value = MmsPreferences.sMap.get(common.STR.KEY_OF_SIM_0_ShowName);
    if (value == null || value == '') {
      return this.getSpnOfSim1();
    }
    return value as string
  }

  public getDispalyNameOfSim2(): string {
    let value = MmsPreferences.sMap.get(common.STR.KEY_OF_SIM_1_ShowName);
    if (value == null || value == '') {
      return this.getSpnOfSim2();
    }
    return value as string
  }

  public getNewSmscOfSim1(): string {
    return this.getValueFromMap(common.STR.KEY_OF_NEW_SIM_0_SMSC, common.STR.EMPTY_STR) as string;
  }

  public getNewSmscOfSim2(): string {
    return this.getValueFromMap(common.STR.KEY_OF_NEW_SIM_1_SMSC, common.STR.EMPTY_STR) as string;
  }

  public getTelephoneNumberOfSim1(): string {
    return this.getValueFromMap(common.STR.KEY_OF_SIM_0_NUMBER, common.STR.EMPTY_STR) as string;
  }

  public getTelephoneNumberOfSim2(): string {
    return this.getValueFromMap(common.STR.KEY_OF_SIM_1_NUMBER, common.STR.EMPTY_STR) as string;
  }

  public getSelectedSlotId(): number {
    return this.getValueFromMap(common.STR.KEY_OF_SELECTED_SLOTID, common.int.SIM_ONE) as number;
  }

  public getDefaultSlotId(): number {
    return this.getValueFromMap(common.STR.KEY_OF_DEFAULT_SLOT, common.int.SIM_ONE) as number;
  }

  public setTimeOfLastDeleteNotifyMms(value: number) {
    this.setValueForSwitch(common.STR.TIME_OF_LAST_DELETE_NOTIFY_MMS, value.toString());
  }

  public getSendMessageSlotId(): number {
    let sendMsgSlotId: number = common.int.SIM_ONE;
    let isSim0Active: boolean = sim.isSimActiveSync(common.int.SIM_ONE);
    let isSim1Active: boolean = sim.isSimActiveSync(common.int.SIM_TWO);
    let isSim0Ready: sim.SimState = sim.getSimStateSync(common.int.SIM_ONE);
    let isSim1Ready: sim.SimState = sim.getSimStateSync(common.int.SIM_TWO);
    HiLog.i(TAG, `isSim0Active: ${JSON.stringify(isSim0Active)}, isSim1Active: ${JSON.stringify(isSim1Active)}`);
    HiLog.i(TAG, `isSim0Ready: ${JSON.stringify(isSim0Ready)}, isSim1Ready: ${JSON.stringify(isSim1Ready)}`);
    let isSim0CanSend: boolean = (isSim0Active && (isSim0Ready == sim.SimState.SIM_STATE_READY ||
      isSim0Ready == sim.SimState.SIM_STATE_LOADED));
    let isSim1CanSend: boolean = (isSim1Active && (isSim1Ready == sim.SimState.SIM_STATE_READY ||
      isSim1Ready == sim.SimState.SIM_STATE_LOADED));
    if (isSim0CanSend && isSim1CanSend) {
      sendMsgSlotId = this.getSelectedSlotId();
      HiLog.i(TAG, `twoCardsCanSend, KEY_OF_SELECTED_SLOTID sendMsgSlotId: ${JSON.stringify(sendMsgSlotId)}`);
    } else {
      sendMsgSlotId = isSim0CanSend ? common.int.SIM_ONE : common.int.SIM_TWO;
      HiLog.i(TAG, `oneCardsCanSend, KEY_OF_SELECTED_SLOTID sendMsgSlotId: ${JSON.stringify(sendMsgSlotId)}`);
    }
    return sendMsgSlotId;
  }

  public getSendMessageSlotIdOfRcs(): number {
    let sendMsgSlotId: number = common.int.SIM_ONE;
    if (this.haveMultiSimCardReady()) {
      sendMsgSlotId = AppStorage.get<number>('simSlotId') || common.int.SIM_ONE;
    } else {
      sendMsgSlotId = this.getDefaultSlotId();
    }
    return sendMsgSlotId;
  }

  /**
   * 老方法，不要用了，用SharedPreferencesUtils
   *
   * @param keyOfSwitch
   * @param valueOfSwitch
   */
  public setValueForSwitch(keyOfSwitch: string, valueOfSwitch: string): void {
    this.setValueToMap(keyOfSwitch, valueOfSwitch);
    SharedPreferencesUtils.saveToPreferences(keyOfSwitch, valueOfSwitch);
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
    if (value == undefined) {
      return SharedPreferencesUtils.getFromPreferences(key, defaultValue) as string | number | boolean;
    }
    if (value == null) {
      value = defaultValue;
    }
    return value;
  }

  /**
   *  Whether the key exists or not
   *
   * @param key
   */
  public hasKeyFromMap(key: string): boolean {
    return MmsPreferences.sMap.has(key);
  }

  /**
   * Delete from map by key
   *
   * @param key
   */
  public removeFromMap(key: string): boolean {
    return MmsPreferences.sMap.delete(key);
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