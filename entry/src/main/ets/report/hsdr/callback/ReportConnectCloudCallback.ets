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

import ICloudConnectResultCallback, { onResultCallback } from '../interface/IConnectCloudResultCallback';
import HiLog from '../../../utils/HiLog';
import { ConnectCloudResponseParam } from '../../common/ReportParams';
import ReportConstant from '../../common/ReportConstant';
import { rpc } from '@kit.IPCKit';
import { BusinessError } from '@kit.BasicServicesKit';

const TAG = 'ReportConnectCloudCallback';

export default class ReportConnectCloudCallback extends rpc.RemoteObject implements ICloudConnectResultCallback {
  private callback: (errCode: number, statusCode: number) => void;

  constructor(callback: (errCode: number, statusCode: number) => void) {
    super('ReportConnectCloudCallback');
    this.callback = callback;
  }

  asObject(): rpc.IRemoteObject {
    return this;
  }

  /**
   * processes the result returned by the service
   *
   * @param { number } context - code the result code, indicating success or failure
   * @param { rpc.MessageSequence } data - the message sequence data
   * @param { rpc.MessageSequence } reply - the message sequence reply
   * @param { rpc.MessageOption } option - the message sequence option
   * @returns { Promise<boolean> } returns the report result
   */
  public async onRemoteMessageRequest(code: number, data: rpc.MessageSequence, reply: rpc.MessageSequence,
    option: rpc.MessageOption): Promise<boolean> {
    HiLog.i(TAG, `onRemoteMessageRequest called, code = ${code}`);
    let interfaceToken: string = data.readInterfaceToken();
    let requestId: string = data.readString();
    if (interfaceToken !== ReportConstant.SECURITY_CLOUD_CONNECT_DESCRIPTOR) {
      return false;
    }
    switch (code) {
      case ReportConstant.CONNECT_CLOUD_COMMAND_CALLBACK: {
        let errCodeVar: number = data.readInt();
        let resultVar: string[] = data.readStringArray();
        HiLog.i(TAG, `onRemoteMessageRequest called, errCodeVar = ${errCodeVar}`);
        let promise: Promise<void> = new Promise<void>((resolve, reject) => {
          this.onResult(errCodeVar, resultVar, (errCode: number) => {
            reply.writeInt(errCode);
            resolve();
          });
        });
        await promise;
        return true;
      }
      default:
        break;
    }
    return false;
  }

  /**
   * handler the return result.
   *
   * @param { number } errCode - the error code.
   * @param { string[] } result - array containing the results
   * @param { onResultCallback } callback - the result callback
   */
  public onResult(errCode: number, result: string[], callback: onResultCallback): void {
    if (errCode != ReportConstant.CONNECT_ANTI_FRAUD_CLOUD_SUCCESS_CODE) {
      HiLog.e(TAG, `cloud check fail. errCode: ${errCode}`);
      callback(ReportConstant.CONNECT_CLOUD_SUCCESS);
      return;
    }
    try {
      let resultContent: ConnectCloudResponseParam = JSON.parse(result.join(''));
      let statusCode: number = JSON.parse(JSON.parse(resultContent.body)).statusCode;
      HiLog.i(TAG, `cloud check end. errCode: ${errCode}`);
      this.callback(errCode, statusCode);
      callback(ReportConstant.CONNECT_CLOUD_SUCCESS);
    } catch (err) {
      let message = (err as BusinessError).message;
      HiLog.e(TAG, `[onResult] fail, message: ${message}`);
    }
  }
}