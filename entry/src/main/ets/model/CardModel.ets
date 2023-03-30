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
import HiLog from "../utils/HiLog";
import MmsPreferences from "../utils/MmsPreferences";
import telephonySMS from "@ohos.telephony.sms";
import telephonySim from "@ohos.telephony.sim";
import observer from '@ohos.telephony.observer';
import CommonEvent from '@ohos.commonEventManager';
import emitter from '@ohos.events.emitter'
import radio from '@ohos.telephony.radio';

const TAG = "CardModel";

class CardModel extends BaseModel {
  public SIM_STATE_CHANGE_EVENT: emitter.InnerEvent = {
    eventId: common.int.EVENT_SIM_STATE_CHANGE,
    priority: emitter.EventPriority.HIGH
  }
  public SLOTID_CHANGE_EVENT: emitter.InnerEvent = {
    eventId: common.int.EVENT_SLOTID_CHANGE,
    priority: emitter.EventPriority.HIGH
  }
  private mSimStateArray: Array<telephonySim.SimState> = [telephonySim.SimState.SIM_STATE_UNKNOWN,
  telephonySim.SimState.SIM_STATE_UNKNOWN];
  private spn: string = '';
  private spnEventSubscriber: any;
  private haveMultiSimCardReady: boolean = false;
  private haveSimCardReady: boolean = false;

  public init(): void {
    try {
      HiLog.i(TAG, "init start.");
      this.setMaxSimCountToMap();
      this.getSimState();
      this.addSimStateChangeListener();
      this.subscribeSpnObserver();
    } catch (error) {
      HiLog.e(TAG, "init error: " + JSON.stringify(error));
    }
  }

  public deInit(): void {
    try {
      HiLog.i(TAG, "deInit start.");
      this.mSimStateArray = [telephonySim.SimState.SIM_STATE_UNKNOWN, telephonySim.SimState.SIM_STATE_UNKNOWN];
      this.removeSimStateChangeListener();
      this.unsubscribeSpnObserver();
    } catch (error) {
      HiLog.e(TAG, "deInit error: " + JSON.stringify(error));
    }
  }

  public isSimReady(slotId: number): boolean {
    return this.mSimStateArray[slotId] == telephonySim.SimState.SIM_STATE_READY
    || this.mSimStateArray[slotId] == telephonySim.SimState.SIM_STATE_LOADED;
  }

  private setMaxSimCountToMap(): void {
    MmsPreferences.getInstance().setValueToMap(common.string.KEY_OF_MAX_SIM_COUNT, telephonySim.getMaxSimCount());
  }

  private getSimState(): void {
    for (let i = 0; i < telephonySim.getMaxSimCount(); i++) {
      telephonySim.getSimState(i, (err, value) => {
        if (err) {
          HiLog.e(TAG, "getSimState, slotId: " + i + ", error: " + JSON.stringify(err));
        } else {
          this.notifySimStateChange(i, value);
        }
      });
    }
  }

  private removeSimStateChangeListener(): void {
    observer.off('simStateChange');
  }

  private addSimStateChangeListener(): void {
    for (let i = 0; i < telephonySim.getMaxSimCount(); i++) {
      observer.on('simStateChange', {
        slotId: i
      }, value => {
        let simState = value?.state;
        HiLog.i(TAG, "simStateChange slotId: " + i + ", simState: " + simState);
        this.notifySimStateChange(i, simState);
      });
    }
  }

  private notifySimStateChange(slotId: number, simState): void {
    let changed: boolean = (simState != this.mSimStateArray[slotId]);
    if (!changed) {
      return;
    }
    this.mSimStateArray[slotId] = simState;
    if (this.isSimReady(slotId)) {
      this.setSpnToMap(slotId);
      this.setSimTelephoneNumberToMap(slotId);
      this.setSmscNumberToPref(slotId);
    }
    this.setSimCardReadyFlagToMap(slotId, simState);
    this.setDefaultSlotToMap();
    emitter.emit(this.SIM_STATE_CHANGE_EVENT, {
      data: {
        "simState": simState,
        "slotId": slotId
      }
    });
  }

  private setSimCardReadyFlagToMap(slotId: number, simState): void {
    this.haveSimCardReady = this.isSimReady(common.int.SIM_ONE) || this.isSimReady(common.int.SIM_TWO);
    this.haveMultiSimCardReady = this.isSimReady(common.int.SIM_ONE) && this.isSimReady(common.int.SIM_TWO);
    HiLog.i(TAG, "updateSimCardReadyFlag slotId: " + slotId + ", simState: " + simState + ", haveSimCardReady: "
    + this.haveSimCardReady + ", haveMultiSimCardReady: " + this.haveMultiSimCardReady);
    MmsPreferences.getInstance().setValueToMap(common.string.KEY_OF_HAVE_MULTI_SIM_CARD_READY,
    this.haveMultiSimCardReady);
    MmsPreferences.getInstance().setValueToMap(common.string.KEY_OF_HAVE_SIM_CARD_READY, this.haveSimCardReady);
  }

  private setDefaultSlotToMap() {
    if (this.haveSimCardReady) {
      if (!this.haveMultiSimCardReady) {
        if (this.isSimReady(common.int.SIM_ONE)) {
          MmsPreferences.getInstance().setValueToMap(common.string.KEY_OF_DEFAULT_SLOT, common.int.SIM_ONE);
        } else {
          MmsPreferences.getInstance().setValueToMap(common.string.KEY_OF_DEFAULT_SLOT, common.int.SIM_TWO);
        }
      } else {
        telephonySim.getDefaultVoiceSlotId((error, slotId: number) => {
          if (error) {
            HiLog.e(TAG, "getDefaultVoiceSlotId error, slotId: " + slotId + ", error: " + JSON.stringify(error));
          } else {
            MmsPreferences.getInstance().setValueToMap(common.string.KEY_OF_DEFAULT_SLOT, slotId);
          }
        });
      }
    }
  }

  private setSpnToMap(slotId: number): void {
    // get spn from sim card
    telephonySim.getSimSpn(slotId, (error, data) => {
      if (error || !data) {
        HiLog.w(TAG, "getSpnFromSim fail, slotId: " + slotId + ", data: " + data + ", error: "
        + JSON.stringify(error));
      } else {
        this.notifySetSimSpnToMap(slotId, data);
        return;
      }
    });
    // get spn from network
    radio.getOperatorName(slotId, (error, data) => {
      if (error || !data) {
        HiLog.w(TAG, "getSpnFromSim fail, slotId: " + slotId + ", data: " + data + ", error: "
        + JSON.stringify(error));
      } else {
        this.notifySetSimSpnToMap(slotId, data);
        return;
      }
    });
    // get plmn to replace spn
    telephonySim.getSimOperatorNumeric(slotId, (error, data) => {
      if (error || !data) {
        HiLog.w(TAG, "getSimOperatorNumeric fail, slotId: " + slotId + ", data: " + data + ", error: "
        + JSON.stringify(error));
      } else {
        if (common.int.SIM_ONE === slotId) {
          MmsPreferences.getInstance().setValueToMap(common.string.KEY_OF_SIM_0_SPN, this.spn);
        } else {
          MmsPreferences.getInstance().setValueToMap(common.string.KEY_OF_SIM_1_SPN, this.spn);
        }
        return;
      }
    });
  }

  private notifySetSimSpnToMap(slotId: number, spn: string): void {
    HiLog.d(TAG, "notifyUpdateSimSpn slotId: " + slotId + ", spn: " + spn);
    this.spn = spn;
    if (common.SPN_CHINA.MOBILE == spn) {
      this.spn = globalThis.mmsContext.resourceManager.getStringSync($r('app.string.china_mobile').id);
    } else if (common.SPN_CHINA.TELECOM == spn) {
      this.spn = globalThis.mmsContext.resourceManager.getStringSync($r('app.string.china_telecom').id);
    } else if (common.SPN_CHINA.UNICOM == spn) {
      this.spn = globalThis.mmsContext.resourceManager.getStringSync($r('app.string.china_unicom').id);
    }
    if (common.int.SIM_ONE === slotId) {
      MmsPreferences.getInstance().setValueToMap(common.string.KEY_OF_SIM_0_SPN, this.spn);
    } else {
      MmsPreferences.getInstance().setValueToMap(common.string.KEY_OF_SIM_1_SPN, this.spn);
    }
  }

  private setSimTelephoneNumberToMap(slotId: number): void {
    telephonySim.getSimTelephoneNumber(slotId, (error, value) => {
      if (error) {
        HiLog.e(TAG, "get slotId: " + slotId + " telephone number error: " + JSON.stringify(error));
      } else {
        if (common.int.SIM_ONE === slotId) {
          MmsPreferences.getInstance().setValueToMap(common.string.KEY_OF_SIM_0_NUMBER, value);
        } else {
          MmsPreferences.getInstance().setValueToMap(common.string.KEY_OF_SIM_1_NUMBER, value);
        }
      }
    });
  }

  private unsubscribeSpnObserver() {
    if (this.spnEventSubscriber) {
      CommonEvent.unsubscribe(this.spnEventSubscriber);
    }
  }

  private subscribeSpnObserver() {
    let subscribeInfo = {
      events: ['usual.event.SPN_INFO_CHANGED']
    };
    CommonEvent.createSubscriber(subscribeInfo, (err, data) => {
      if (err) {
        HiLog.e(TAG, "subscribeSpnObserver error: " + JSON.stringify(err))
        return
      }
      this.spnEventSubscriber = data;
      CommonEvent.subscribe(data, (err, data) => {
        if (data && data.parameters) {
          let spn = data.parameters.CUR_SPN ? data.parameters.CUR_SPN : data.parameters.CUR_PLMN;
          if (spn) {
            HiLog.i(TAG, "SPN_INFO_CHANGED notify slotId: " + data.parameters.CUR_SLOT_ID + ", spn: " + spn);
            this.notifySetSimSpnToMap(data.parameters.CUR_SLOT_ID, spn);
          }
        }
      })
    });
  }

  private setSmscNumberToPref(slotId: number): void {
    telephonySMS.getSmscAddr(slotId).then((simPhoneNumber) => {
      if (slotId == common.int.SIM_ONE) {
        MmsPreferences.getInstance().setValueForSwitch(common.string.KEY_OF_NEW_SIM_0_SMSC, simPhoneNumber);
      } else if (slotId == common.int.SIM_TWO) {
        MmsPreferences.getInstance().setValueForSwitch(common.string.KEY_OF_NEW_SIM_1_SMSC, simPhoneNumber);
      }
    }).catch((error) => {
      HiLog.e(TAG, "setSmscNumberToPref error: " + JSON.stringify(error.message));
    });
  }
}

// Singleton
export default new CardModel();