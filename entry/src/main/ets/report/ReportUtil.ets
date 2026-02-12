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

import util from '@ohos.util';
import HiLog from '../utils/HiLog';
import SsmUtils from '../utils/SsmUtils';
import { UcsResponseParam } from './common/ReportParams';

const TAG: string = 'ReportUtil';

export default class ReportUtil {
  /**
   * encrypt body with encode
   *
   * @param { string } requestBody - the content need to encrypt
   * @returns {string } returns the encrypt body with encode
   */
  public static encodeAndEncryptBody(requestBody: string): string {
    HiLog.i(TAG, 'EncodeAndEncryptBody start ');
    let that: util.Base64Helper = new util.Base64Helper();
    let bodyEncode: string = that.encodeToStringSync(SsmUtils.stringToUint8Array(requestBody));
    return bodyEncode;
  }

  /**
   * get string to sign
   *
   * @param { number } timestamp - the timestamp
   * @param { UcsResponseParam } ucsResponseParam - the ucs response param
   * @param { string } cloudPath - the cloud path
   * @returns {string } returns the result to use sign
   */
  public static getStringToSign(timestamp: number, ucsResponseParam: UcsResponseParam, cloudPath: string): string {
    HiLog.i(TAG, '[getStringToSign] start');
    let httpMethod: string = 'POST';
    let that: util.Base64Helper = new util.Base64Helper();
    let iv: string = SsmUtils.stringToHex(ucsResponseParam.iv);
    let signature: string = SsmUtils.uint8ArrayToHex(that.decodeSync(ucsResponseParam.data));
    let httpPayload = `${iv}:${signature}`;
    let httpPayloadEncode: string = that.encodeToStringSync(SsmUtils.stringToUint8Array(httpPayload));
    let result: string =
      `${httpMethod}&${cloudPath}&&${httpPayloadEncode}&ak=${ucsResponseParam.ak}&timestamp=${timestamp}`;
    HiLog.i(TAG, '[getStringToSign] end');
    return result;
  }
}