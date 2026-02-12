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

import Constant from '../data/Constant';
import ConversationController from '../pages/conversation/conversationController';
import lazy { DateUtil } from '../utils/DateUtil';
import HiLog from '../utils/HiLog';
import { ReportSmsContentFailParam, SmsContentReportRequestInfo, SmsReportParams, } from './common/ReportParams';
import deviceInfo from '@ohos.deviceInfo';
import BaseRequestHandler from './request/BaseReportHandler';
import EncryptionHandler from './request/EncryptionHandler';
import SignatureHandler from './request/SignatureHandler';
import ConnectionCloudHandler from './request/ConnectionCloudHandler';
import ReportConnectCloudCallback from './hsdr/callback/ReportConnectCloudCallback';
import HiFaultEventUtil from './event/HiFaultEventUtil';
import ReportUtil from './ReportUtil';
import { common } from '@kit.AbilityKit';
import ReportConnectServiceManager from './ReportConnectServiceManager';
import { RequestParameter } from './request/RequestParameter';
import ReportParameterHelper from './common/ReportParameterHelper';
import ReportConstant from './common/ReportConstant';

const TAG = 'ReportSpamMessageManager';

export default class ReportSpamMessageManager {
  private static instance: ReportSpamMessageManager;
  private mContext: common.UIAbilityContext | undefined = undefined;
  private constructor() {
  }

  /**
   * get ReportSpamMessageManager instance
   *
   * @returns { ReportSpamMessageManager } returns ReportSpamMessageManager instance
   */
  public static getInstance(): ReportSpamMessageManager {
    if (!ReportSpamMessageManager.instance) {
      ReportSpamMessageManager.instance = new ReportSpamMessageManager();
    }
    return ReportSpamMessageManager.instance;
  }

  /**
   * init ReportSpamMessageManager.
   *
   * @param { common.UIAbilityContext } context - the context
   */
  public async initReportSpamMessageManager(context: common.UIAbilityContext): Promise<void> {
    this.mContext = context;
    await ReportConnectServiceManager.getInstance().initReportConnectServiceManager(context);
  }

  /**
   * start to report spam sms
   *
   * @param { common.UIAbilityContext } context - the context
   * @param { string } msgStr - the sms content
   * @param { string } senderNum - the sender number
   * @returns { Promise<boolean> } returns the report result
   */
  public async reportSmsContent(context: common.UIAbilityContext, msgStr: string, senderNum: string): Promise<boolean> {
    let taskId: number = -1;
    let timeTask: Promise<boolean> = new Promise<boolean>((resolve, reject) => {
      taskId = setTimeout(() => {
        ConversationController.getInstance().showReportToast($r('app.string.messageReportFailed'),
          ConversationController.reportScreenPadding);
        HiLog.d(TAG, 'reportSmsContent timeout');
        ReportConnectServiceManager.getInstance().disconnectAbility();
        return reject('timeout');
      }, ReportConstant.REPORT_SMS_CONTENT_TIMEOUT);
    });
    let reportSmsContentTask: Promise<boolean> = new Promise<boolean>(async (resolve, reject) => {
      let startTime: number = new Date().getTime();
      if (!(DateUtil.isDataValid(context))) {
        HiLog.e(TAG, '[reportSmsContent] context is invalid, please check!');
        return;
      }
      let params: SmsReportParams = {
        senderNum: senderNum,
        startTime: startTime,
        msgStr: msgStr
      }
      let reportRes: boolean = await this.fetchReportSmsContentRtd(params);
      clearTimeout(taskId);
      HiLog.i(TAG, '[reportSmsContent] success');
      ReportConnectServiceManager.getInstance().disconnectAbility();
      return resolve(reportRes);
    });
    return Promise.race([reportSmsContentTask, timeTask]);
  }

  public async fetchReportSmsContentRtd(params: SmsReportParams): Promise<boolean> {
    HiLog.d(TAG, 'fetchReportSmsContentRtd');
    return new Promise<boolean>((resolve, reject) => {
      this.reportSmsContentInner(params, (errCode: number, statusCode: number) => {
        if (errCode != ReportConstant.CONNECT_ANTI_FRAUD_CLOUD_SUCCESS_CODE) {
          ReportConnectServiceManager.getInstance().disconnectAbility();
          HiLog.e(TAG, 'fetchReportSmsContentRtd fail.');
          this.reportSmsContentFault(params, ReportConstant.REPORT_SMS_CONTENT_CONNECT_CLOUD_FAIL);
        }
        HiLog.i(TAG, `statusCode: ${statusCode}`);
        switch (statusCode) {
          case ReportConstant.REPORT_SUCCESS:
            HiLog.i(TAG, '[fetchReportSmsContentRtd] report sms content success',);
            return resolve(true);
          case ReportConstant.PARAM_ERROR:
            HiLog.e(TAG, '[fetchReportSmsContentRtd] report param error');
            break;
          case ReportConstant.CLOUD_INNER_ERROR:
            HiLog.e(TAG, '[fetchReportSmsContentRtd] cloud inner error');
            break;
          default:
            HiLog.e(TAG, '[fetchReportSmsContentRtd] report other error');
            break;
        }
      })
    });
  }

  public async reportSmsContentInner(params: SmsReportParams,
    callback: (errCode: number, statusCode: number) => void): Promise<void> {
    HiLog.i(TAG, 'reportSmsContentInner start');
    if (!(DateUtil.isDataValid(this.mContext))) {
      HiLog.e(TAG, '[reportSmsContentInner] params is invalid, please check!');
      return;
    }
    let smsReportCloudConnectCallback: ReportConnectCloudCallback =
      new ReportConnectCloudCallback(callback);
    let newestCalleeId: string = await ReportParameterHelper.getCalleeId();
    let ipAddress: string = await ReportParameterHelper.getIp(this.mContext as common.UIAbilityContext);
    let requestInfo: SmsContentReportRequestInfo = {
      appId: Constant.CLOUD_CHECK_REQUEST_APP_ID,
      eventTimestamp: new Date().getTime(),
      textMsg: params.msgStr,
      senderNumber: params.senderNum,
      receiverId: newestCalleeId,
      ip: ipAddress,
      deviceType: deviceInfo.deviceType
    }
    this.startHandlerRequest(JSON.stringify(requestInfo), smsReportCloudConnectCallback);
  }

  public startHandlerRequest(requestBody: string, callback: ReportConnectCloudCallback): void {
    let bodyEncode: string = ReportUtil.encodeAndEncryptBody(requestBody);
    let encryptionHandler: BaseRequestHandler = new EncryptionHandler();
    let signatureHandler: BaseRequestHandler = new SignatureHandler();
    let connectionCloudHandler: BaseRequestHandler = new ConnectionCloudHandler();
    encryptionHandler.setNextRequestHandler(signatureHandler);
    signatureHandler.setNextRequestHandler(connectionCloudHandler);
    let request: RequestParameter = {
      bodyEncode: bodyEncode,
      timestamp: new Date().getTime(),
      connectCloudCallback: callback
    }
    encryptionHandler.startRequest(request);
  }

  public reportSmsContentFault(params: SmsReportParams, faultErrCode: number): void {
    let endTime: number = new Date().getTime();
    let reportParam: ReportSmsContentFailParam = {
      senderNumber: params.senderNum,
      reportContent: params.msgStr,
      reportDuration: endTime - params.startTime,
      reportFailReason: faultErrCode
    }
    HiFaultEventUtil.reportSmsContentFail(reportParam);
  }
}