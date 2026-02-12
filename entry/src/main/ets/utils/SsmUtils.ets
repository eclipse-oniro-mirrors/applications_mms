/**
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import HiLog from './HiLog';
import MmsPreferences from './MmsPreferences';
import telephonySim from '@ohos.telephony.sim';
import StringUtil from './StringUtil';
import call from '@ohos.telephony.call';
import { BusinessError } from '@ohos.base';
import cryptoFramework from '@ohos.security.cryptoFramework';
import util from '@ohos.util';
import { Context } from '@kit.AbilityKit';
import SharedPreferencesUtils from './SharedPreferencesUtils';
import common from '../data/commonData';
import commonData from '../data/commonData';
import LooseObject from '../data/LooseObject';
import DotUtil from './MmsDot/DotUtils';
import dotCommon, {smsVerificationResult, SatelliteSMSReminderResult} from '../utils/MmsDot/DotCommon';
import { systemParameterEnhance } from '@kit.BasicServicesKit';

const TAG = 'SsmUtils';

/**
 * Handle file data
 */
export default class SsmUtils {
  /**
   * regex of dandelion to select.
   */
  public static CACTUS_REGEX = '「' + '[0-9A-Za-z]{6}' + '」';
  /** Whether cactus news */
  public static IS_CACTUS = 1;
  /** MESSAGE_SPLIT_INDEX_SIX */
  public static MESSAGE_SPLIT_INDEX_SIX = 6;
  /** MESSAGE_SPLIT_INDEX_EIGHT */
  public static MESSAGE_SPLIT_INDEX_EIGHT = 8;
  /** MESSAGE_SPLIT_INDEX_NIGHT */
  public static MESSAGE_SPLIT_INDEX_NIGHT = 9;

  public static async getLocalNumber(context: Context, slotId: number): Promise<string> {
    let localNumber = '';
    await telephonySim.getShowNumber(slotId).then(value => {
      localNumber = value;
      HiLog.i(TAG, 'getShowNumber by slotId: ' + slotId + ' localNumber is Empty: ' + StringUtil.isEmpty(localNumber));
    }).catch((err: BusinessError) => {
      HiLog.e(TAG, 'getShowNumber by slotId: ' + slotId + ' telephone number error: ' + JSON.stringify(err));
    });
    if (StringUtil.isEmpty(localNumber)) {
      await telephonySim.getSimTelephoneNumber(slotId).then(value => {
        localNumber = value;
        HiLog.i(TAG, 'getSimTelephoneNumber by localNumber is Empty');
      }).catch((err: BusinessError) => {
        HiLog.e(TAG, 'getSimTelephoneNumber error : ' + JSON.stringify(err));
      });
    }
    if (StringUtil.isEmpty(localNumber)) {
      if (slotId === 0) {
        localNumber = MmsPreferences.getInstance().getTelephoneNumberOfSim1();
      } else {
        localNumber = MmsPreferences.getInstance().getTelephoneNumberOfSim2();
      }
      HiLog.i(TAG, 'getCacheNumber by MmsPreferences: ' + slotId + ' localNumber is Empty: ' + StringUtil.isEmpty(localNumber));
    }

    if (StringUtil.isEmpty(localNumber)) {
      if (slotId === 0) {
        localNumber = SharedPreferencesUtils.getFromPreferences(common.STR.KEY_OF_SIM_0_NUMBER, '') as string;
      } else {
        localNumber = SharedPreferencesUtils.getFromPreferences(common.STR.KEY_OF_SIM_1_NUMBER, '') as string;
      }
      HiLog.i(TAG, 'getCache by SharedPreferencesUtils: ' + slotId + ' localNumber is Empty: ' + StringUtil.isEmpty(localNumber));
    }
    return localNumber;
  }

  public static async stringToSha256(plainText: string): Promise<string> {
    let str = '';
    if (StringUtil.isEmpty(plainText)) {
      return str;
    }
    let md = cryptoFramework.createMd('SHA256');
    let buff = new util.TextEncoder().encodeInto(plainText);
    let blob: cryptoFramework.DataBlob = {
      data: buff
    }

    let promiseMdUpdate = md.update(blob);
    await promiseMdUpdate.then(() => {
      let promiseMdDigest = md.digest();
      return promiseMdDigest;
    }).then(mdOutput => {
      let newBuff = SsmUtils.uint8ToHex(mdOutput.data) as string;
      str = newBuff.toString();
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, '[Promise]: error: ' + error.message);
    });
    return str;
  }

  static uint8ToHex(uint8arr: Uint8Array): string {
    let hexStr = '';
    for (let i = 0; i < uint8arr.length; i++) {
      let hex = uint8arr[i].toString(16);
      hex = hex.length === 1 ? '0' + hex : hex;
      hexStr += hex;
    }
    return hexStr;
  }

  private static async formatPhoneNumberToE164(localNumber: string, countryIso: string) {

    await call.formatPhoneNumberToE164(localNumber, countryIso).then((data) => {
      if (data !== null) {
        localNumber = data;
      }
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'formatPhoneNumberToE164 error: ' + JSON.stringify(error));
    });
    return localNumber;
  }

  public static async formatPhoneNumber(oriNumber: string, slotId: number): Promise<string> {
    if (StringUtil.isEmpty(oriNumber) || (slotId === undefined)) {
      HiLog.e(TAG, 'slotId or oriNumber is invalid');
      return oriNumber;
    }
    let countryIso: string = '';
    let localNumber: string = '';
    let timerId: number = -1;
    const timeout = new Promise<string>((reslove) => {
      timerId = setTimeout(() => {
        timerId = -1;
        HiLog.w(TAG, 'formatPhoneNumber timeOut');
        reslove('');
      }, 3000)
    })
    let formatPromise = telephonySim.getISOCountryCodeForSim(slotId).then(isoData => {
      countryIso = isoData;
      call.formatPhoneNumberToE164(oriNumber, countryIso).then((localNumberData) => {
        if (localNumberData != null) {
          localNumber = localNumberData;
        }
      })
    }).catch((err: BusinessError) => {
      HiLog.e(TAG, `getISOCountryCodeForSim by subId: ${slotId}, error code: ${err?.code}, message: ${err?.message}`);
    });
    try {
      await Promise.race([timeout, formatPromise]);
      if (timerId !== -1) {
        clearTimeout(timerId);
      }
    } catch (err) {
      HiLog.e(TAG, `getISOCountryCodeForSim race slotId: ${slotId}, error code: ${err?.code}, message: ${err?.message}`);
    };
    return localNumber;
  }

  public static async getMessage(bodyText: string, address: string, subId: number, context: Context): Promise<string> {
    HiLog.w(TAG, 'getMessage start');
    let phoneNumber = address;
    let countryIso: string = '';
    await telephonySim.getISOCountryCodeForSim(subId).then(data => {
      countryIso = data;
    }).catch((err: BusinessError) => {
      HiLog.e(TAG, 'getISOCountryCodeForSim by subId: ' + subId + ' iso error: ' + JSON.stringify(err));
    });

    if (!StringUtil.isEmpty(address)) {
      await call.formatPhoneNumberToE164(address, countryIso).then((data) => {
        if (data !== null) {
          phoneNumber = data;
        }
      }).catch((error: BusinessError) => {
        HiLog.e(TAG, 'formatPhoneNumberToE164 error: ' + JSON.stringify(error));
      });
    }

    if (phoneNumber.startsWith('+86')) {
      phoneNumber = phoneNumber.substring(3);
    }

    let messageString = '';
    if (context != null) {
      messageString = 'DANDELION_MESSAGE' + bodyText + phoneNumber;
    } else {
      messageString = bodyText + phoneNumber;
    }

    let stringSha256: string = await SsmUtils.stringToSha256(messageString);
    bodyText = bodyText + '\n' + '「' + stringSha256.substring(stringSha256.length - 6) + '」';
    HiLog.w(TAG, 'getMessage end');
    return bodyText;
  }

  static stringToUint8Array(str: string): Uint8Array {
    const decodedString = unescape(encodeURIComponent(str));
    const uint8Array = new Uint8Array(decodedString.length);
    for (let i = 0; i < decodedString.length; i++) {
      uint8Array[i] = decodedString.charCodeAt(i);
    }
    return uint8Array;
  }

  static stringToHex(str: string): string {
    let hex = '';
    for (let i = 0; i < str.length; i++) {
      const charCode = str.charCodeAt(i).toString(16);
      hex += charCode.length < 2 ? '0' + charCode : charCode;
    }
    return hex;
  }

  static uint8ArrayToHex(bytes: Uint8Array): string {
    let hex = '';
    for (let i = 0; i < bytes.length; i++) {
      const byteHex = bytes[i].toString(16);
      hex += byteHex.length === 1 ? '0' + byteHex : byteHex;
    }
    return hex;
  }

  static getPhoneNumberLast(phoneNumber: string, lastNum: number): string {
    let lastPhoneNumber: string = phoneNumber;
    if (phoneNumber?.length > lastNum) {
      lastPhoneNumber = phoneNumber.slice(-lastNum);
    }
    return lastPhoneNumber;
  }
}