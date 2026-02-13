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

export default class ReportConstant {
  /**
   * the hsdr antifraud service name
   */
  public static readonly HSDR_ANTIFRAUD_NAME: string = 'com.ohos.hsdr.antifraud';

  /**
   * the cloud afs root service name
   */
  public static readonly CLOUD_AFS_ROOT_NAME: string = 'com.xxx.cloud.afs.ROOT';

  /**
   * ucs code for encrypt
   */
  public static readonly UCS_ENCRYPT_CODE: number = 0;

  /**
   * ucs code for sign
   */
  public static readonly UCS_SIGN_CODE: number = 2;

  /**
   * http pay load index
   */
  public static readonly HTTP_PAY_LOAD_INDEX: number = 3;

  /**
   * report spam sms timeout
   */
  public static readonly REPORT_SMS_CONTENT_TIMEOUT: number = 3000;

  /**
   * report spam sms connect cloud fail
   */
  public static readonly REPORT_SMS_CONTENT_CONNECT_CLOUD_FAIL: number = 196616;

  /**
   * report connect cloud timeout
   */
  public static readonly REPORT_CONNECT_CLOUD_TIMEOUT: number = 5000;

  /**
   * report cloud read timeout
   */
  public static readonly REPORT_CLOUD_READ_TIMEOUT: number = 5000;

  /**
   * report success code
   */
  public static readonly REPORT_SUCCESS: number = 0;

  /**
   * report error code for param
   */
  public static readonly PARAM_ERROR: number = 400;

  /**
   * report error code for cloud inner error
   */
  public static readonly CLOUD_INNER_ERROR: number = 500;

  /**
   * connect cloud success code
   */
  public static readonly CONNECT_CLOUD_SUCCESS: number = 0;

  /**
   * connect anti fraud cloud success
   */
  public static readonly CONNECT_ANTI_FRAUD_CLOUD_SUCCESS_CODE: number = 200;

  /**
   * the security descriptor
   */
  public static readonly SECURITY_DESCRIPTOR: string = 'OHOS.Security.HSDR';

  /**
   * the command cloud connect type
   */
  public static readonly COMMAND_CLOUD_CONNECT: number = 2;

  /**
   * the command ucs request type
   */
  public static readonly COMMAND_UCS_REQUEST: number = 3;

  /**
   * the security descriptor of cloud connect callback
   */
  public static readonly SECURITY_CLOUD_CONNECT_DESCRIPTOR: string = 'OHOS.Security.CloudConnectCallback';

  /**
   * the cloud connect command callback
   */
  public static readonly CONNECT_CLOUD_COMMAND_CALLBACK: number = 1;

  /**
   * the want to start hsdr
   */
  public static readonly HSDR_SERVICE_WANT: Want = {
    'deviceId': '',
    'bundleName': 'com.ohos.hsdr',
    'abilityName': 'HSDRService',
  }
}