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

import HiLog from '../utils/HiLog';
import common from '../data/commonData';
import LooseObject from '../data/LooseObject'
import MmsPreferences from '../utils/MmsPreferences'
import StringUtil from '../utils/StringUtil';
import sim from '@ohos.telephony.sim';
import call from '@ohos.telephony.call';

const TAG = 'CallService';

export class CallService {
  readonly number: string;

  constructor(number: string) {
    this.number = number;
  }

  static fromString(number: string): CallService {
    return new CallService(StringUtil.removeSpace(number));
  }

  public isDialEmergencyNum(): Promise<boolean> {
    let phoneNumber = this.number;
    let result: Promise<boolean> = new Promise((resolve) => {
      call.isEmergencyPhoneNumber(phoneNumber, (err, data) => {
        let isDialEmergencyNum: boolean = false;
        if (err) {
          HiLog.e(TAG, 'isEmergencyPhoneNumber error: ' + JSON.stringify(err));
        } else {
          HiLog.i(TAG, 'isEmergencyPhoneNumber data: ' + JSON.stringify(data));
          isDialEmergencyNum = data;
        }
        resolve(isDialEmergencyNum);
      });
    });
    return result;
  }

  public getNumber(): string {
    return this.number;
  }

  public call(callback?: LooseObject): void {
    this.dial(callback);
  }

  public async dial(options?: call.DialOptions, callback?: Function): Promise<void> {
    HiLog.i(TAG, 'dial start');
    if (StringUtil.isEmpty(this.number)) {
      HiLog.w(TAG, 'dial number is empty, return!');
      return;
    }
    HiLog.i(TAG, `dial options: ${options?.accountId}`);
    if (options == null) {
      let dialSlotId: number = MmsPreferences.getInstance().getDefaultSlotId();
      HiLog.w(TAG, `options is null, dial getDefaultSlotId: ${dialSlotId}`);
      if (sim.isSimActiveSync(common.int.SIM_ONE)) {
        dialSlotId = common.int.SIM_ONE;
      } else if (sim.isSimActiveSync(common.int.SIM_TWO)) {
        dialSlotId = common.int.SIM_TWO;
      }
      HiLog.w(TAG, `dial dialSlotId: ${dialSlotId}`);
      if (dialSlotId !== common.int.INVALID) {
        HiLog.w(TAG, `dial dialSlotId is not invalid, dialSlotId: ${dialSlotId}`);
        options = {
          accountId: dialSlotId,
        }
      }
    }
    try {
      call.dial(this.number, options, (error, value) => {
        if (error != null) {
          HiLog.e(TAG, `dial finish err: ${error}`);
        } else {
          HiLog.i(TAG, 'dial finish value: ' + value);
        }
        if (callback) {
          let result: LooseObject = {};
          result.code = error != null ? common.int.FAILURE : common.int.SUCCESS;
          result.value = value;
          callback(result);
        }
      });
    } catch (err) {
      HiLog.e(TAG, `dial error: ${err}`);
    }

  }
}