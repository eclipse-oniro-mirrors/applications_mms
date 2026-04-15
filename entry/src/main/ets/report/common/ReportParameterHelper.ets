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

import connection from '@ohos.net.connection';
import { cryptoFramework } from '@kit.CryptoArchitectureKit';
import Constant from '../../data/Constant';
import HiLog from '../../utils/HiLog';
import SsmUtils from '../../utils/SsmUtils';
import systemParameterEnhance from '@ohos.systemParameterEnhance';
import { BusinessError } from '@kit.BasicServicesKit';
import { ConnectCloudRequestParam, UcsResponseParam } from './ReportParams';
import deviceInfo from '@ohos.deviceInfo';
import { RequestParameter } from '../request/RequestParameter';
import SharedPreferencesUtils from '../../utils/SharedPreferencesUtils';
import ResourceUtils from '../../utils/ResourceUtils';
import { common } from '@kit.AbilityKit';
import ReportConstant from './ReportConstant';
import ReportUtil from '../ReportUtil';

const TAG = 'ReportParameterHelper';

export default class ReportParameterHelper {
  /**
   * generate random num.
   *
   * @returns { string } returns the random num
   */
  public static generateRandomNum(): string {
    let result: string = '';
    let rand: cryptoFramework.Random = cryptoFramework.createRandom();
    try {
      let randData: cryptoFramework.DataBlob = rand.generateRandomSync(Constant.RANDOM_NUMBER_BYTE_COUNT);
      if (randData !== null) {
        result = SsmUtils.uint8ArrayToHex(randData.data);
        result = parseInt(result, Constant.RADIX).toString();
        if (result.length > Constant.CLOUD_CONNECT_RANDOM_NUM_LENGTH) {
          return result.substring(0, Constant.CLOUD_CONNECT_RANDOM_NUM_LENGTH);
        } else {
          return Constant.CLOUD_CONNECT_DEFAULT_NUM;
        }
      } else {
        HiLog.e(TAG, '[generateRandomNum] get rand result fail!');
      }
    } catch (error) {
      let err: BusinessError = error as BusinessError;
      HiLog.e(TAG, `[generateRandomNum] error, ${err.code},${err.message}`);
    }
    return result;
  }

  /**
   * get connect cloud params.
   *
   * @param { RequestParameter } request - the request send to cloud.
   * @returns { string } returns the random num
   */
  public static getConnectCloudParams(request: RequestParameter): string {
    try {
      let resultContent: UcsResponseParam = JSON.parse(request.result?.join('') as string);
      let ucsResponseParam: UcsResponseParam = {
        data: resultContent.data,
        iv: resultContent.iv,
        ak: resultContent.ak
      }
      let authorization: string = ReportParameterHelper.getAuthorization(ucsResponseParam, request);
      let requestParam: ConnectCloudRequestParam = {
        method: 'POST',
        path: Constant.APPEAL_SMS_MARKER_CLOUD_PATH,
        headers: {
          params: [
            {
              name: 'Content-Type',
              value: 'application/x-encrypt-data;algo=aes-gcm'
            }, {
            name: 'Authorization',
            value: authorization
          }, {
            name: 'X-OpenHarmony-Version',
            value: deviceInfo.distributionOSVersion
          }
          ]
        },
        body: request.httpPayload,
        connectTimeout: ReportConstant.REPORT_CONNECT_CLOUD_TIMEOUT,
        readTimeout: ReportConstant.REPORT_CLOUD_READ_TIMEOUT
      }
      return JSON.stringify(requestParam);
    } catch (err) {
      let message = (err as BusinessError).message;
      HiLog.e(TAG, `[getConnectCloudParams] fail, message: ${message}`);
      return '';
    }
  }

  public static getAuthorization(ucsResponseParam: UcsResponseParam, request: RequestParameter): string {
    let result =
      `EXT-CLOUDSOA-HMAC-SHA256 ak=${ucsResponseParam.ak},timestamp=${request.timestamp},signature=${
      ucsResponseParam.data}`;
    return result;
  }

  /**
   * get callee id from preferences.
   *
   * @param { RequestParameter } request - the request send to cloud.
   * @returns { Promise<string> } returns the callee id
   */
  public static async getCalleeId(): Promise<string> {
    HiLog.i(TAG, '[getCalleeId] start');
    let generateCalleeIdTime: string | undefined = SharedPreferencesUtils.getFromPreferences(
      Constant.GENERATE_CALLEE_ID_TIME, '').toString();
    let calleeId: string = SharedPreferencesUtils.getFromPreferences(Constant.CALLEE_ID, '').toString();
    let timestamp: number = new Date().getTime();
    let timeDiff: number = timestamp - ((generateCalleeIdTime === '') ? 0 : parseInt(generateCalleeIdTime));
    HiLog.i(TAG, `[getCalleeId] timeDiff: ${timeDiff}`);
    if ((calleeId === '') || timeDiff > Constant.GENERATE_CALLEE_ID_TIMEOUT) {
      calleeId = ReportParameterHelper.generateRandomCalleeId();
      SharedPreferencesUtils.saveToPreferences(Constant.CALLEE_ID, calleeId);
      SharedPreferencesUtils.saveToPreferences(Constant.GENERATE_CALLEE_ID_TIME, timestamp.toString());
      HiLog.i(TAG, `[getCalleeId] calleeId: ${calleeId}, generate callee id timestamp:${timestamp}`);
    }
    let localCalleeId: string | undefined =
      SharedPreferencesUtils.getFromPreferences(Constant.CALLEE_ID, '').toString();
    return localCalleeId ?? '';
  }

  public static generateRandomCalleeId(): string {
    let result: string = '';
    let rand: cryptoFramework.Random = cryptoFramework.createRandom();
    try {
      let randData: cryptoFramework.DataBlob = rand.generateRandomSync(Constant.CALLEE_ID_LENGTH);
      if (randData !== null) {
        result = SsmUtils.uint8ArrayToHex(randData.data);
      } else {
        HiLog.i(TAG, '[generateRandomCalleeId] get rand result fail!');
      }
    } catch (error) {
      let err: BusinessError = error as BusinessError;
      HiLog.e(TAG, `[generateRandomCalleeId] sync error, ${err.code},${err.message}`);
    }
    HiLog.i(TAG, `[generateRandomCalleeId] result: ${result}`);
    return result;
  }

  /**
   * get ip from connection.
   *
   * @param { common.UIAbilityContext } context - the context environment.
   * @returns { Promise<string> } returns ip
   */
  public static async getIp(context: common.UIAbilityContext): Promise<string> {
    let result: string = '';
    let ipAddresses: string[] = [];
    let allNets: connection.NetHandle[] = connection.getAllNetsSync();
    for (let net of allNets) {
      let netCap: connection.ConnectionProperties = connection.getConnectionPropertiesSync(net);
      HiLog.i(TAG, `[getIp] network type: ${netCap.interfaceName}`);
      if (!netCap.interfaceName.includes('wlan') && Array.isArray(netCap.dnses)) {
        ipAddresses = ReportParameterHelper.getCurrentNetCap(ipAddresses, netCap);
      }
    }
    result = ipAddresses.join(',').toString();
    return (result === '') ? await ReportParameterHelper.getDefaultIp(context) : result;
  }

  public static getCurrentNetCap(ipAddresses: string[], netCap: connection.ConnectionProperties): string[] {
    for (let i = 0; i < netCap.linkAddresses.length; i++) {
      let linkAddress: connection.LinkAddress = netCap.linkAddresses[i];
      if (linkAddress.address.family === 1) {
        ipAddresses.push(linkAddress.address.address);
      }
    }
    return ipAddresses;
  }

  private static async getDefaultIp(context: common.UIAbilityContext): Promise<string> {
    let fileName: string = systemParameterEnhance.getSync('', Constant.CLOUD_RAWFILE_NAME);
    try {
      let content: string = await ResourceUtils.getStringByFile(context.resourceManager, fileName);
      let defaultIp: string = JSON.parse(content).default_ip_address;
      return defaultIp;
    } catch (err) {
      let message = (err as BusinessError).message;
      HiLog.e(TAG, `[getDefaultIp] fail, message: ${message}`);
      return '';
    }
  }

  /**
   * get signature request.
   *
   * @param { RequestParameter } request - the request send to cloud.
   * @returns { RequestParameter } returns the new request
   */
  public static getSignatureRequest(request: RequestParameter): RequestParameter {
    try {
      let resultContent: UcsResponseParam = JSON.parse(request.result?.join('') as string);
      let ucsResponseParam: UcsResponseParam = {
        data: resultContent.data,
        iv: resultContent.iv,
        ak: resultContent.ak
      }
      let stringToSign: string = ReportUtil.getStringToSign(request.timestamp as number, ucsResponseParam,
        Constant.APPEAL_SMS_MARKER_CLOUD_PATH);
      let stringToSignContent: string[] = stringToSign.split('&');
      let httpPayload: string = '';
      if (stringToSignContent.length <= ReportConstant.HTTP_PAY_LOAD_INDEX) {
        return request;
      }
      httpPayload = stringToSignContent[ReportConstant.HTTP_PAY_LOAD_INDEX];
      let stringToSignEncode: string = ReportUtil.encodeAndEncryptBody(stringToSign);
      request.bodyEncode = stringToSignEncode;
      request.httpPayload = httpPayload;
      return request;
    } catch (err) {
      let message = (err as BusinessError).message;
      HiLog.e(TAG, `[getSignatureRequest] fail, message: ${message}`);
      return request;
    }
  }
}