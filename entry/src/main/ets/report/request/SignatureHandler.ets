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

import HiLog from '../../utils/HiLog';
import BaseRequestHandler from './BaseReportHandler';
import ReportConstant from '../common/ReportConstant';
import ReportParameterHelper from '../common/ReportParameterHelper';
import ReportConnectServiceManager from '../ReportConnectServiceManager';
import { RequestParameter } from './RequestParameter';

const TAG = 'BaseRequestHandler';

export default class SignatureHandler extends BaseRequestHandler {
  /**
   * start request
   *
   * @param { RequestParameter } request - the request send to cloud.
   */
  startRequest(request: RequestParameter): void {
    HiLog.i(TAG, '[SignatureHandler] startRequest.');
    if (request.errCode !== 0) {
      HiLog.e(TAG, '[SignatureHandler] connect hsdr failed. please check network');
      return;
    }
    request = ReportParameterHelper.getSignatureRequest(request);
    if (request.httpPayload?.length == 0) {
      HiLog.e(TAG, '[SignatureHandler] httpPayload is empty.');
      return;
    }
    let randomNum: string = ReportParameterHelper.generateRandomNum();
    ReportConnectServiceManager.getInstance().startRequestUcs(ReportConstant.UCS_SIGN_CODE,
      request.bodyEncode as string, ReportConstant.HSDR_ANTIFRAUD_NAME, randomNum,
      (errCode: number, result: string[]) => {
        request.errCode = errCode;
        request.result = result;
        if (this.nextHandler != undefined) {
          HiLog.i(TAG, '[SignatureHandler] start next Request.');
          this.nextHandler.startRequest(request);
        }
      });
  }
}