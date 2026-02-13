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
import ResultRPCCallback from 'ets/ServiceExtension/callback/ResultRPCCallback';
import HiLog from '../../../utils/HiLog';
import MmsUriGrantController from '../../../pages/mmsurigrant/MmsUriGrantController';
import MmsUriGrantStub from '../stub/MmsUriGrantStub';

const TAG = 'MmsUriGrantHandler';
const ERROR_CODE = 200;
const GRANT_FAIL_CODE = 201;
const SUCCESS_CODE = 0;

export default class MmsUriGrantHandler extends MmsUriGrantStub {

  private grantController: MmsUriGrantController = new MmsUriGrantController();
  private targetBundleName?: string = '';

  constructor(handler: string, targetBundleName?: string) {
    super(handler);
    this.targetBundleName = targetBundleName;
  }

  async grantAccessAttachmentUrisPermission(uriArray: Array<string>, callback: ResultRPCCallback): Promise<void> {
    if (uriArray === null || uriArray === undefined || uriArray.length === 0) {
      HiLog.e(TAG, 'grantAccessAttachmentUrisPermission uriArr is null or length 0');
      callback.onResult(ERROR_CODE, 'error');
      return;
    }
    if (this.targetBundleName === undefined || this.targetBundleName === '') {
      HiLog.e(TAG, 'grantAccessAttachmentUrisPermission targetBundleName is undefined or null');
      return;
    }
    HiLog.i(TAG, 'grantAccessAttachmentUrisPermission uriArray.length: ' + uriArray.length);
    let failedUriArray: string[] = await this.grantController.grantUrisPermission(uriArray, this.targetBundleName);
    if (failedUriArray.length !== 0) {
      try {
        let failedUriJsonString: string = JSON.stringify(failedUriArray);
        callback.onResult(GRANT_FAIL_CODE, failedUriJsonString);
        HiLog.i(TAG, 'grantAccessAttachmentUrisPermission end');
        return;
      } catch (err) {
        HiLog.e(TAG, 'get failedUriJsonString failed! err.code:' + err?.code);
        callback.onResult(ERROR_CODE, 'JsonString err');
      }
    }
    callback.onResult(SUCCESS_CODE, 'success');
  }
}