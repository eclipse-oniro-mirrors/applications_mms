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

import BaseModel from './BaseModel';
import common from '../data/commonData';
import EmitterConstant from '../data/EmitterConstant';
import HiLog from '../utils/HiLog';
import MmsPreferences from '../utils/MmsPreferences';
import telephonySMS from '@ohos.telephony.sms';
import telephonySim from '@ohos.telephony.sim';
import observer from '@ohos.telephony.observer';
import CommonEvent from '@ohos.commonEventManager';
import emitter from '@ohos.events.emitter'
import radio from '@ohos.telephony.radio';
import { BusinessError } from '@ohos.base';
import commonEventManager from '@ohos.commonEventManager';
import OperatorConfigUtil from '../../cust/utils/OperatorConfigUtil';
import SharedPreferencesUtils from '../utils/SharedPreferencesUtils';
import MessageUtil from '../../cust/utils/MessageUtil';
import StringUtil from '../utils/StringUtil';
import commonData from '../data/commonData';
import SimSlotIdUtils from '../utils/SimSlotIdUtils';
import { CountryIdUtil } from '../utils/CountryIdUtil';
import sim from '@ohos.telephony.sim';

const TAG = 'CardModel';

const PREFIX_SIM = 'SIM';
const PREFIX_ESIM = 'eSIM';

class SubscribeInfoObj {
  events: Array<string> = []
}

export enum SimCardSlotEnum {
  slot1 = 0,
  slot2 = 1
}

class CardModel extends BaseModel {
  public SIM_STATE_CHANGE_EVENT: emitter.InnerEvent = {
    eventId: EmitterConstant.EVENT_SIM_STATE_CHANGE,
    priority: emitter.EventPriority.HIGH
  }
  public SLOTID_CHANGE_EVENT: emitter.InnerEvent = {
    eventId: EmitterConstant.EVENT_SLOTID_CHANGE,
    priority: emitter.EventPriority.HIGH
  }
  private mSimStateArray: Array<telephonySim.SimState> = [telephonySim.SimState.SIM_STATE_UNKNOWN,
  telephonySim.SimState.SIM_STATE_UNKNOWN];
  private spn: string = '';
  private spnEventSubscriber?: commonEventManager.CommonEventSubscriber;
  private haveMultiSimCardReady: boolean = false;
  private haveSimCardReady: boolean = false;
  private mobileReg = new RegExp('^460(00|02|04|07|08|13)$');
  private unicomReg = new RegExp('^460(01|06|09|10)$');
  private telecomReg = new RegExp('^460(03|05|11|12)$');
  private context?: Context;
  private callbacks: Array<(value: observer.SimStateData) => void> = [];
  private callbacksSimaChangeForBeiDou: Array<(value: observer.SimStateData) => void> = [];
  public init(ctx: Context): void {
    try {
      HiLog.i(TAG, 'init start.');
      this.context = ctx;
      this.setMaxSimCountToMap();
      this.processShowName();
      this.addSimStateChangeListener();
      this.subscribeSpnObserver();
      this.getSimState();
    } catch (error) {
      HiLog.e(TAG, 'init error: ' + JSON.stringify(error));
    }
  }

  public deInit(): void {
    try {
      HiLog.i(TAG, 'deInit start.');
      this.mSimStateArray = [telephonySim.SimState.SIM_STATE_UNKNOWN, telephonySim.SimState.SIM_STATE_UNKNOWN];
      this.removeSimStateChangeListener();
      this.unsubscribeSpnObserver();
    } catch (error) {
      HiLog.e(TAG, 'deInit error: ' + JSON.stringify(error));
    }
  }

  private removeSimStateChangeForBeiDouListener(): void {
    for (let i = 0; i < telephonySim.getMaxSimCount(); i++) {
      observer.off('simStateChange', this.callbacksSimaChangeForBeiDou[i]);
    }
    this.callbacksSimaChangeForBeiDou = [];
  }

  public getSimCardState(simSlotID: SimCardSlotEnum) {
    return this.mSimStateArray[simSlotID]
  }

  public isSimReady(slotId: number): boolean {
    return (this.mSimStateArray[slotId] == telephonySim.SimState.SIM_STATE_READY ||
      this.mSimStateArray[slotId] == telephonySim.SimState.SIM_STATE_LOADED);
  }

  private setMaxSimCountToMap(): void {
    MmsPreferences.getInstance().setValueToMap(common.STR.KEY_OF_MAX_SIM_COUNT, telephonySim.getMaxSimCount());
  }

  private getSimState(): void {
    HiLog.i(TAG, 'getSimState, start!');
    for (let i = 0; i < telephonySim.getMaxSimCount(); i++) {
      telephonySim.getSimState(i, (err, value) => {
        if (err) {
          HiLog.e(TAG, 'getSimState, slotId: ' + i + ', error: ' + JSON.stringify(err));
        } else {
          this.notifySimStateChange(i, value);
        }
      });
    }
  }

  private processShowName(): void {
    // process sim show name info
    HiLog.i(TAG, 'entry processShowName')
    for (let i = 0; i < telephonySim.getMaxSimCount(); i++) {
      HiLog.i(TAG, 'processShowName: slot id' + i)
      telephonySim.getSimAccountInfo(i, (err, iAccountInfo) => {
        if (err) {
          HiLog.e(TAG, 'processShowName:  slotId: ' + i + ', error: ' + JSON.stringify(err));
        } else {
          // when the showname is null  we can not unable to distinguish showname  is null or uesr not set showname
          let keyName:string=common.int.SIM_ONE === i?common.STR.KEY_OF_SIM_0_ShowName:common.STR.KEY_OF_SIM_1_ShowName;
          if (iAccountInfo.showName == null || iAccountInfo.showName == undefined || iAccountInfo.showName == 'null') {
            HiLog.i(TAG, 'processShowName:  slotId: ' + i + ' no show name ')
            //remove pre showname in case of prevalue
            MmsPreferences.getInstance().removeFromMap(keyName)
          }
          else {
            HiLog.i(TAG, 'processShowName:  slotId: ' + i + 'setValueToMap show name: ' + iAccountInfo.showName)
            MmsPreferences.getInstance().setValueToMap(keyName, iAccountInfo.showName);
          }
        }
      });
    }
  }

  private removeSimStateChangeListener(): void {
    for (let i = 0; i < telephonySim.getMaxSimCount(); i++) {
      observer.off('simStateChange', this.callbacks[i]);
    }
    this.callbacks = [];
  }

  private addSimStateChangeListener(): void {
    for (let i = 0; i < telephonySim.getMaxSimCount(); i++) {
      const callback = this.simStateChangeListenerCallback(i);
      this.callbacks.push(callback);
      observer.on('simStateChange', {
        slotId: i
      }, callback);
    }
  }

  private simStateChangeListenerCallback(i: number) {
    return (value: observer.SimStateData) => {
      let simState = value?.state;
      this.notifySimStateChange(i, simState);
      HiLog.i(TAG, 'simStateChange slotId: ' + i + ', simState: ' + simState);
      if (this.isSimReady(i)) {
        // sim卡状态变化获取国家码
        let countryId: string = CountryIdUtil.getCountryId();
        AppStorage.setOrCreate('country', countryId);
      }
    }
  }

  private notifySimStateChange(slotId: number, simState: telephonySim.SimState): void {
    HiLog.e(TAG, 'notifySimStateChange, start!' + slotId);
    let changed: boolean = (simState != this.mSimStateArray[slotId]);
    if (!changed) {
      return;
    }
    this.mSimStateArray[slotId] = simState;
    if (this.isSimReady(slotId)) {
      this.setSpnToMap(slotId);
      this.setSimInfo(slotId);
      this.setSimTelephoneNumberToMap(slotId);
      this.setSmscNumberToPref(slotId);
      OperatorConfigUtil.getInstance().initOperatorConfig();
    }
    this.setSimCardReadyFlagToMap(slotId, simState);
    this.setDefaultSlotToMap();
    let simStateValueChanged = AppStorage.get('simStateValueChanged') as boolean;
    AppStorage.setOrCreate('simStateValueChanged', !simStateValueChanged);
    emitter.emit(this.SIM_STATE_CHANGE_EVENT, {
      data: {
        'simState': simState,
        'slotId': slotId
      }
    });
  }

  private setSimCardReadyFlagToMap(slotId: number, simState: telephonySim.SimState): void {
    HiLog.e(TAG, 'setSimCardReadyFlagToMap, set!');
    this.haveSimCardReady = this.isSimReady(common.int.SIM_ONE) || this.isSimReady(common.int.SIM_TWO);
    this.haveMultiSimCardReady = this.isSimReady(common.int.SIM_ONE) && this.isSimReady(common.int.SIM_TWO);
    HiLog.i(TAG, 'updateSimCardReadyFlag slotId: ' + slotId + ', simState: ' + simState +
      ', haveSimCardReady: ' + this.haveSimCardReady + ', haveMultiSimCardReady: ' + this.haveMultiSimCardReady);
    MmsPreferences.getInstance().setValueToMap(common.STR.KEY_OF_HAVE_MULTI_SIM_CARD_READY,
      this.haveMultiSimCardReady);
    MmsPreferences.getInstance().setValueToMap(common.STR.KEY_OF_HAVE_SIM_CARD_READY, this.haveSimCardReady);
  }

  private setDefaultSlotToMap() {
    if (this.haveSimCardReady) {
      if (!this.haveMultiSimCardReady) {
        if (this.isSimReady(common.int.SIM_ONE)) {
          MmsPreferences.getInstance().setValueToMap(common.STR.KEY_OF_DEFAULT_SLOT, common.int.SIM_ONE);
        } else {
          MmsPreferences.getInstance().setValueToMap(common.STR.KEY_OF_DEFAULT_SLOT, common.int.SIM_TWO);
        }
      } else {
        telephonySim.getDefaultVoiceSlotId((error, slotId: number) => {
          if (error) {
            HiLog.w(TAG, 'getDefaultVoiceSlotId fail,set slotId to -1, error: ' + JSON.stringify(error));
            slotId = common.int.INVALID;
          }
          let subId: number = SimSlotIdUtils.getAvailableSlotId(slotId);
          MmsPreferences.getInstance().setValueToMap(common.STR.KEY_OF_DEFAULT_SLOT, subId);
        });
      }
    }
  }

  private setSimInfo(slotId: number) {
    let simType: number = -1;
    let simIndex: number = -1;
    let simIndexName: string = '';
    try {
      let simLabel: sim.SimLabel = sim.getSimLabelSync(slotId);
      simType = simLabel.simType;
      simIndex = Math.max(simLabel.index, 1);
      if (simType === common.simType.ESIM) {
        simIndexName = PREFIX_ESIM + ' ' + simIndex;
      } else {
        simIndexName = PREFIX_SIM + ' ' + simIndex;
      }
    } catch (err) {
      HiLog.e(TAG, `setSimInfo went wrong.${err?.code},${err?.msg}`);
    }
    HiLog.i(TAG,
      `setSimInfo slotId: ${slotId}, simType:${simType}, simIndex:${simIndex}, simIndexName:${simIndexName}`);
    if (common.int.SIM_ONE === slotId) {
      MmsPreferences.getInstance().setValueToMap(common.STR.KEY_OF_SLOT_0_TYPE, simType);
      MmsPreferences.getInstance().setValueToMap(common.STR.KEY_OF_SLOT_0_INDEX, simIndex);
      MmsPreferences.getInstance().setValueToMap(common.STR.KEY_OF_SLOT_0_INDEX_NAME, simIndexName);
    } else if (common.int.SIM_TWO === slotId) {
      MmsPreferences.getInstance().setValueToMap(common.STR.KEY_OF_SLOT_1_TYPE, simType);
      MmsPreferences.getInstance().setValueToMap(common.STR.KEY_OF_SLOT_1_INDEX, simIndex);
      MmsPreferences.getInstance().setValueToMap(common.STR.KEY_OF_SLOT_1_INDEX_NAME, simIndexName);
    }
    let type0 =
      MmsPreferences.getInstance().getValueFromMap(common.STR.KEY_OF_SLOT_0_TYPE, common.simType.PSIM) as number;
    let type1 =
      MmsPreferences.getInstance().getValueFromMap(common.STR.KEY_OF_SLOT_1_TYPE, common.simType.PSIM) as number;
    let index0 =
      MmsPreferences.getInstance().getValueFromMap(common.STR.KEY_OF_SLOT_0_INDEX, common.simType.PSIM) as number;
    let index1 =
      MmsPreferences.getInstance().getValueFromMap(common.STR.KEY_OF_SLOT_1_INDEX, common.simType.PSIM) as number;
    // 修正，当获取到的卡1和卡2的index相等时，分配到卡1和卡2
    if (type0 === type1 && type0 === common.simType.PSIM && index0 === index1 && index0 != -1) {
      MmsPreferences.getInstance().setValueToMap(common.STR.KEY_OF_SLOT_0_INDEX, 1);
      MmsPreferences.getInstance().setValueToMap(common.STR.KEY_OF_SLOT_0_INDEX_NAME, PREFIX_SIM + ' ' + 1);
      MmsPreferences.getInstance().setValueToMap(common.STR.KEY_OF_SLOT_1_INDEX, 2);
      MmsPreferences.getInstance().setValueToMap(common.STR.KEY_OF_SLOT_1_INDEX_NAME, PREFIX_SIM + ' ' + 2);
    }
  }

  private setSpnToMap(slotId: number): void {
    // get spn from sim card
    telephonySim.getSimSpn(slotId, (error, data) => {
      if (error || !data) {
        HiLog.w(TAG, 'getSpnFromSim fail, slotId: ' + slotId + ', data: ' + data +
          ', error: ' + JSON.stringify(error));
        this.setOperatorName(slotId);
      } else {
        this.notifySetSimSpnToMap(slotId, data);
      }
    });
  }

  private setOperatorName(slotId: number): void {
    // get spn from network
    radio.getOperatorName(slotId, (error, data) => {
      if (error || !data) {
        HiLog.w(TAG, 'getOperatorName fail, slotId: ' + slotId + ', data: ' +
          data + ', error: ' + JSON.stringify(error));
        this.setSimOperatorNumeric(slotId);
      } else {
        this.notifySetSimSpnToMap(slotId, data);
      }
    });
  }

  private setSimOperatorNumeric(slotId: number): void {
    // get plmn to replace spn
    telephonySim.getSimOperatorNumeric(slotId, (error, data) => {
      if (error || !data) {
        HiLog.w(TAG, 'getSimOperatorNumeric fail, slotId: ' + slotId + ', data: ' + data +
          ', error: ' + JSON.stringify(error));
      } else {
        this.notifySetSimSpnToMap(slotId, data);
        HiLog.i(TAG, 'getSimOperatorNumeric slotId: ' + slotId + ',spn:' + this.spn + '.data:' + data);
      }
    });
  }

  private notifySetSimSpnToMap(slotId: number, spn: string): void {
    HiLog.d(TAG, 'notifyUpdateSimSpn slotId: ' + slotId + ', spn: ' + spn);
    if (common.SPN_CHINA.MOBILE == spn || this.mobileReg.test(spn)) {
      AppStorage.setOrCreate('notifyUpdateSimSpn', spn);
      AppStorage.setOrCreate('simSlotIdIsShowRead', slotId);
    }
    let mmsContext = this.context ? this.context : getContext(this);
    this.spn = radio.getOperatorNameSync(slotId)
    if (mmsContext && !this.spn) {
      if (common.SPN_CHINA.MOBILE == spn || this.mobileReg.test(spn)) {
        this.spn = mmsContext?.resourceManager.getStringSync($r('app.string.china_mobile')
          .id);
      } else if (common.SPN_CHINA.TELECOM == spn || this.telecomReg.test(spn)) {
        this.spn = mmsContext?.resourceManager.getStringSync($r('app.string.china_telecom')
          .id);
      } else if (common.SPN_CHINA.UNICOM == spn || this.unicomReg.test(spn)) {
        this.spn = mmsContext?.resourceManager.getStringSync($r('app.string.china_unicom')
          .id);
      }else if (common.SPN_CHINA.BROADNET == spn || spn == common.SPN_NUMERIC.BROADNET) {
        this.spn = mmsContext?.resourceManager.getStringSync($r('app.string.china_broadnet')
          .id);
      } else {
        this.spn = spn
      }
    }
    if (common.int.SIM_ONE === slotId) {
      MmsPreferences.getInstance().setValueToMap(common.STR.KEY_OF_SIM_0_SPN, this.spn);
    } else if (common.int.SIM_TWO === slotId) {
      MmsPreferences.getInstance().setValueToMap(common.STR.KEY_OF_SIM_1_SPN, this.spn);
    }
  }

  private setSimTelephoneNumberToMap(slotId: number): void {
    telephonySim.getShowNumber(slotId, (error, value) => {
      if (error) {
        HiLog.e(TAG, 'get slotId: ' + slotId + ' telephone number error: ' + JSON.stringify(error));
      } else {
        if (common.int.SIM_ONE === slotId) {
          MmsPreferences.getInstance().setValueToMap(common.STR.KEY_OF_SIM_0_NUMBER, value);
          SharedPreferencesUtils.saveToPreferences(common.STR.KEY_OF_SIM_0_NUMBER, value);
        } else {
          MmsPreferences.getInstance().setValueToMap(common.STR.KEY_OF_SIM_1_NUMBER, value);
          SharedPreferencesUtils.saveToPreferences(common.STR.KEY_OF_SIM_1_NUMBER, value);
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
    let subscribeInfo: SubscribeInfoObj = {
      events: ['usual.event.SPN_INFO_CHANGED0', 'usual.event.SPN_INFO_CHANGED1']
    };
    CommonEvent.createSubscriber(subscribeInfo, (err, data) => {
      if (err) {
        HiLog.e(TAG, 'subscribeSpnObserver error: ' + JSON.stringify(err))
        return
      }
      this.spnEventSubscriber = data;
      CommonEvent.subscribe(data, (err, data) => {
        if (data && data.parameters) {
          let spn: string = data.parameters.CUR_SPN ? data.parameters.CUR_SPN : data.parameters.CUR_PLMN;
          if (spn) {
            HiLog.i(TAG, 'SPN_INFO_CHANGED notify slotId: ' + data.parameters.CUR_SLOT_ID + ', spn: ' + spn);
            this.notifySetSimSpnToMap(data.parameters.CUR_SLOT_ID, spn);
          }
        }
      })
    });
  }

  private async setSmscNumberToPref(slotId: number) {
    if (slotId < common.int.SIM_ONE || slotId > common.int.SIM_TWO) {
      HiLog.e(TAG, 'setSmscNumberToPref fail due to slotId error');
      return;
    }
    // card为本设备所有插过的sim卡的总序号
    let card = await MessageUtil.getSimId(slotId);
    let smscFromPref: string = '';
    if (card != -1) {
      smscFromPref = SharedPreferencesUtils.getFromPreferences('SMSC' + card, '') as string;
    }
    await telephonySMS.getSmscAddr(slotId).then((smscFromInterface) => {
      if (StringUtil.isEmpty(smscFromPref) || !StringUtil.isEmpty(smscFromInterface)) {
        SharedPreferencesUtils.saveToPreferences('SMSC' + card, smscFromInterface);
      }
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'setSmscNumberToPref error: ' + JSON.stringify(error.message));
    });
  }

  public async getMccmnc(slotId: number) {
    HiLog.i(TAG, 'getMccmnc start slotId');
    try {
      let mccMnc = sim.getSimOperatorNumericSync(slotId);
      return mccMnc;
    } catch (e) {
      HiLog.i(TAG, 'getMcc error: ' + JSON.stringify(e));
      return '';
    }
  }
}

// Singleton
export default new CardModel();