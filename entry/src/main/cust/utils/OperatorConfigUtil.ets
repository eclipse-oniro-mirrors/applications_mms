/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
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
import HiLog from '../../ets/utils/HiLog';
import sim from '@ohos.telephony.sim';
import { BusinessError } from '@ohos.base';
import StringUtil from '../../ets/utils/StringUtil';
import MmsPreferences from '../../ets/utils/MmsPreferences';
import common from '../../ets/data/commonData';
import cardModel from '../../ets/model/CardModel'

const TAG: string = 'OperatorConfigUtil';

class OperatorConfigUtil {
  private static MAX_MESSAGE_SIZE: string = 'maxMessageSize';
  private static SMSC_ADDRESS: string = 'SMSCAddress';
  private static SMS_TO_MMS_THRESHOLD: string = 'sms_to_mms_threshold_int';
  private static opInstance: OperatorConfigUtil | undefined = undefined;
  private operatorConfigMap: Map<number, Array<sim.OperatorConfig>> = new Map();

  public static getInstance(): OperatorConfigUtil {
    if (!OperatorConfigUtil.opInstance) {
      OperatorConfigUtil.opInstance = new OperatorConfigUtil();
    }
    return OperatorConfigUtil.opInstance;
  }

  public static release() {
    if (OperatorConfigUtil.opInstance) {
      OperatorConfigUtil.opInstance = undefined
    }
  }

  public async initOperatorConfig(): Promise<void> {
    await sim.getOperatorConfigs(0).then((data: Array<sim.OperatorConfig>) => {
      HiLog.i(TAG, `getOperatorConfigs1 success, promise: data->${JSON.stringify(data)}`);
      this.operatorConfigMap.set(0, data)
    }).catch((err: BusinessError) => {
      HiLog.i(TAG, `getOperatorConfigs1 failed, promise: err->${JSON.stringify(err)}`);
    });
    await sim.getOperatorConfigs(1).then((data: Array<sim.OperatorConfig>) => {
      HiLog.i(TAG, `getOperatorConfigs2 success, promise: data->${JSON.stringify(data)}`);
      this.operatorConfigMap.set(1, data)
    }).catch((err: BusinessError) => {
      HiLog.i(TAG, `getOperatorConfigs2 failed, promise: err->${JSON.stringify(err)}`);
    });
  }

  /*
  get operator_config.json`
   */
  public getOperatorConfig(slotId: number, configKey: string): string {
    if (this.operatorConfigMap == null || this.operatorConfigMap.size < 1) {
      HiLog.i(TAG, 'getOperatorConfig is null');
      return '';
    }
    let configValue: string = '';
    let operatorConfigs = this.operatorConfigMap.get(slotId)
    if (operatorConfigs == null || operatorConfigs == undefined) {
      HiLog.i(TAG, 'operatorConfigs is null, slotId: ' + slotId);
      return '';
    }
    for (let index = 0; index < operatorConfigs.length; index++) {
      const operatorConfig: sim.OperatorConfig = operatorConfigs[index];
      if (configKey === operatorConfig.field) {
        configValue = operatorConfig.value;
        HiLog.i(TAG, 'getOperatorConfig has value');
        break;
      }
    }
    return configValue;
  }

  /**
   * Get the cust mms size.
   *
   * @param { number } defaultValue - the default value of mms size.
   * @returns { number } Returns the cust mms size
   */
  public getCustMMSSize(defaultValue: number): number {
    let slotId: number = MmsPreferences.getInstance().getSendMessageSlotId();
    let size: number = defaultValue;
    let maxSize: number = Number.parseInt(OperatorConfigUtil.getInstance().getOperatorConfig(
      slotId, OperatorConfigUtil.MAX_MESSAGE_SIZE));
    if (maxSize) {
      size = maxSize;
    }
    HiLog.i(TAG, 'getCustMMSSize size = ' + size);
    return size;
  }

  /**
   * Get the cust SMSC address.
   *
   * @param { number } slotId - the slot id.
   * @returns { string } Returns the cust SMSC address
   */
  public getCustSMSCAddress(slotId: number): string {
    let centerAddress: string = '';
    let custCenterAddress: string = OperatorConfigUtil.getInstance()
      .getOperatorConfig(slotId, OperatorConfigUtil.SMSC_ADDRESS);
    if (!StringUtil.isEmpty(custCenterAddress)) {
      centerAddress = custCenterAddress;
    }
    return centerAddress;
  }

  /**
   * Get the sms to mms threshold.
   *
   * @param { number } defaultValue - the default value
   * @returns { number } Returns the threshold
   */
  public getCustomSmsToMmsThreshold(defaultValue: number): number {
    let simOneThreshold: number = Number.MAX_SAFE_INTEGER;
    let simTwoThreshold: number = Number.MAX_SAFE_INTEGER;
    if (cardModel.isSimReady(common.int.SIM_ONE)) {
      let tempThreshold = Number.parseInt(OperatorConfigUtil.getInstance().getOperatorConfig(
        common.int.SIM_ONE, OperatorConfigUtil.SMS_TO_MMS_THRESHOLD));
      simOneThreshold = tempThreshold ? tempThreshold : defaultValue;
    }
    if (cardModel.isSimReady(common.int.SIM_TWO)) {
      let tempThreshold = Number.parseInt(OperatorConfigUtil.getInstance().getOperatorConfig(
        common.int.SIM_TWO, OperatorConfigUtil.SMS_TO_MMS_THRESHOLD));
      simTwoThreshold = tempThreshold ? tempThreshold : defaultValue;
    }
    let smsToMmsThreshold = Math.min(simOneThreshold, simTwoThreshold);
    if (smsToMmsThreshold === Number.MAX_SAFE_INTEGER) {
      smsToMmsThreshold = defaultValue;
    }
    HiLog.i(TAG, 'smsToMmsThreshold = ' + smsToMmsThreshold);
    return smsToMmsThreshold;
  }
}

export default OperatorConfigUtil;