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

import sms from '@ohos.telephony.sms';
import HiLog from '../utils/HiLog';
import common from '../data/commonData';
import LooseObject from '../data/LooseObject';
import FileUtil from '../utils/FileUtil';
import MmsPreferences from '../utils/MmsPreferences';
import { GlobalContext } from '../MainAbility/GlobalHelper';
import myCommon from '@ohos.app.ability.common';
import { BusinessError } from '@ohos.base';
import MessageUtil from '../../cust/utils/MessageUtil';
import sim from '@ohos.telephony.sim';
import NetModel, { NetInfo } from '../model/NetModel';
import WorkerWrapper from '../workers/base/WorkerWrapper';
import SharedPreferencesUtils from '../utils/SharedPreferencesUtils';
import telephonySim from '@ohos.telephony.sim';
import hiTraceMeter from '@ohos.hiTraceMeter';
import TraceConstant from '../data/TraceConstant';
import DotUtil from '../utils/MmsDot/DotUtils';
import dotCommon, { dotSendParmas, dotNoNeedParmas, sendMmsParams,
  sendMessageCommonParams } from '../utils/MmsDot/DotCommon';
import DeviceUtil from '../utils/DeviceUtil';
import fs from '@ohos.file.fs';
import TimeUtils from '../pages/smc/utils/TimeUtils';
import StringUtil from '../utils/StringUtil';
import { Mms } from '../utils/TypesUtils';
import MmsUtil from '../utils/MmsUtil';
import UserUtil from '../utils/UserUtil';
import Constant from '../data/Constant';

const TAG = 'SendMsgService';
const SEND_REQ_MMS = '/SendReq.mms';
const INVALID_PARAMETER_ERROR_CODE = 8300001;
const DEFAULT_SMSC = '+7';

interface mmsType {
  from: Record<string, string | number>,
  to: Array<Record<string, string | number>>,
  contentType: string,
  transactionId: string,
  version: number,
  subject: string
}

interface NetInfoWrapper {
  actionData: Record<string, string>,
  context: Context
}

class SendMsgService {
  private netModel: NetModel = new NetModel();
  public mmsTypeDot: number = 0;
  /**
   * Sending sms messages
   *
   * @param params Including the card slot, phone number, and SMS message content
   * @callback callback Return the message sending status.
   */
  sendMessage(params: LooseObject, callback: Function) {
    HiLog.w(TAG, 'sendMessage start');
    try {
      let flag = SharedPreferencesUtils.getFromPreferences(
        common.STR.KEY_OF_DELIVERY_REPORT_SWITCH, common.DELIVERY_REPORTS.DISABLED) as string;
      dotSendParmas.CARD_SELECT_STATUS = Number(params.slotId) == 0 ? 1 : 2;
      if ((DeviceUtil.isSubDeviceWithConnected(getContext(this)))) {
        params.slotId = 0;
      }
      HiLog.i(TAG, 'DELIVERY REPORTS :' + flag);
      if (flag == common.DELIVERY_REPORTS.DISABLED || flag == common.DELIVERY_REPORTS.MMS) {
        this.sendMsgWithoutDeliveryReports(params, callback)
      } else {
        this.sendMsgWithDeliveryReports(params, callback)
      }
    } catch (error) {
      HiLog.e(TAG, 'sendMessage, sendMessage failed error: ' + JSON.stringify(error));
      callback(common.int.SEND_MESSAGE_FAILED);
      // 短信发送失败fault打点
      DotUtil.getInstance().reportFaultEvent(dotNoNeedParmas, dotCommon.faultEventName.SMS_SEND_FAIL);
    }
    HiLog.w(TAG, 'sendMessage end');
  }

  async sendMsgWithoutDeliveryReports(params: LooseObject, callback: Function) {
    let that = this
    HiLog.w(TAG, `sendMsgWithoutDeliveryReports, slotId: ${params.slotId}`);
    params.msgType = common.ueMsgType.SMS;
    params.msgContent = 1;
    params.sendResult = common.ueMsgSendType.SENDING;
    DotUtil.getInstance().reportSendMessageCommon(params);
    let smsc = await MessageUtil.getSmscNumberFromPref(Number(params.slotId));
    if (StringUtil.isEmpty(smsc)) {
      HiLog.w(TAG, `smsc is empty`);
      smsc = this.getDefaultSmsc(Number(params.slotId));
    }
    sms.sendShortMessage({
      // sms.sendMessage({
      slotId: Number(params.slotId),
      destinationHost: params.destinationHost,
      content: params.content,
      serviceCenter: smsc,
      sendCallback: (err, value) => {
        let sendStatus: number = common.int.SEND_MESSAGE_FAILED;
        if (err) {
          HiLog.w(TAG, 'sendMessage, sendCallback failed err: ' + JSON.stringify(err.message));
          sendStatus = common.int.SEND_MESSAGE_FAILED;
        } else {
          sendStatus = that.dealSendResult(value);
          if (sendStatus === common.int.SEND_MESSAGE_SUCCESS) {
            params.sendResult = common.ueMsgSendType.SUCCESS;
            DotUtil.getInstance().reportSendMessageCommon(params);
          } else {
            params.sendResult = common.ueMsgSendType.FAILED;
            params.failReason = `sendShortMessage failed result:${value.result}, sendStatus:${sendStatus},`+
              ` smsc: ${smsc}`;
            DotUtil.getInstance().reportSendMessageCommon(params);
          }
          HiLog.w(TAG, `sendMessage, sendCallback success result=${value.result}, sendStatus=${sendStatus}`);
        }
        callback(sendStatus);
      },
    }, (err: BusinessError) => {
      if (err) {
        params.sendResult = common.ueMsgSendType.FAILED;
        params.failReason = JSON.stringify(err) + ' smsc:' + smsc;
        DotUtil.getInstance().reportSendMessageCommon(params);
      }
      HiLog.w(TAG, 'sendShortMessage, sendCallback failed err: ' + JSON.stringify(err));
    });
    HiLog.w(TAG, 'sendMsgWithoutDeliveryReports end');
  }

  async sendMsgWithDeliveryReports(params: LooseObject, callback: Function) {
    let that = this
    HiLog.w(TAG, `sendMsgWithDeliveryReports, slotId: ${params.slotId}`);
    params.msgType = common.ueMsgType.SMS;
    params.msgContent = 1;
    params.sendResult = common.ueMsgSendType.SENDING;
    DotUtil.getInstance().reportSendMessageCommon(params);
    let smsc = await MessageUtil.getSmscNumberFromPref(Number(params.slotId));
    if (StringUtil.isEmpty(smsc)) {
      HiLog.w(TAG, `smsc is empty`);
      smsc = this.getDefaultSmsc(Number(params.slotId));
    }
    sms.sendShortMessage({
      // sms.sendMessage({
      slotId: Number(params.slotId),
      destinationHost: params.destinationHost,
      content: params.content,
      serviceCenter: smsc,
      sendCallback: (err, value) => {
        let sendStatus: number = common.int.SEND_MESSAGE_FAILED;
        if (err) {
          HiLog.w(TAG, 'sendMessage, sendCallback failed err: ' + JSON.stringify(err.message));
          sendStatus = common.int.SEND_MESSAGE_FAILED;
        } else {
          sendStatus = that.dealSendResult(value);
          HiLog.w(TAG, `sendMessage, sendCallback success result=${value.result}, sendStatus=${sendStatus}`);
        }
        if (sendStatus === common.int.SEND_MESSAGE_SUCCESS) {
          params.sendResult = common.ueMsgSendType.SUCCESS;
          DotUtil.getInstance().reportSendMessageCommon(params);
        } else {
          params.sendResult = common.ueMsgSendType.FAILED;
          params.failReason = `sendShortMessage failed result:${value.result}, sendStatus:${sendStatus},`+
            ` smsc: ${smsc}`;
          DotUtil.getInstance().reportSendMessageCommon(params);
        }
        callback(sendStatus);
      },
      deliveryCallback: (err, value) => {
        if (err) {
          HiLog.w(TAG, 'sendMessage, deliveryCallback failed err: ' + JSON.stringify(err.message));
          return;
        }
      }
    }, (err: BusinessError) => {
      if (err) {
        params.sendResult = common.ueMsgSendType.FAILED;
        params.failReason = JSON.stringify(err) + ' smsc:' + smsc;
        DotUtil.getInstance().reportSendMessageCommon(params);
      }
      HiLog.w(TAG, 'sendShortMessage, sendCallback failed err: ' + JSON.stringify(err));
    });
    HiLog.w(TAG, 'sendMsgWithDeliveryReports end');
  }

  /**
   * 如果从协议获取的短信中心号码为空，重新从本地获取（双升单时从双的mms_preferences.xml文件中解析的短信中心号码）
   *
   * @param slotId sim卡slotId
   * @return 短信中心号码
   */
  private getDefaultSmsc(slotId: number): string {
    let smsc: string = '';
    if (slotId === common.int.SIM_ONE) {
      smsc = MmsPreferences.getInstance().getNewSmscOfSim1();
    } else if (slotId === common.int.SIM_TWO) {
      smsc = MmsPreferences.getInstance().getNewSmscOfSim2();
    }
    // SIM卡无短信中心号码，使用兜底值。通信共享场景PC/PAD端无卡，兜底方案只适用手机
    if (StringUtil.isEmpty(smsc) && DeviceUtil.isPhone()) {
      HiLog.w(TAG, `getDefaultSmsc slotId: ${slotId}, empty value`);
      return DEFAULT_SMSC;
    }
    return smsc;
  }

  private dealSendResult(value: LooseObject) {
    let sendStatus = common.int.SEND_MESSAGE_SENDING;
    dotSendParmas.SEND_STATE = -1;
    if (value.result == sms.SendSmsResult.SEND_SMS_SUCCESS) {
      sendStatus = common.int.SEND_MESSAGE_SUCCESS;
      dotSendParmas.SEND_STATE = 1;
    } else {
      sendStatus = common.int.SEND_MESSAGE_FAILED;
      dotSendParmas.SEND_STATE = 2;
    }
    return sendStatus;
  }

  async sendMmsMessage(context: Context, params: Record<string, Array<string> | string | number | boolean>,
    mmsSource: Array<Mms>, callback: Function) {
    let slotId: number = params.slotId as number;
    HiLog.w(TAG, `sendMmsMessage, slotId: ${slotId}`);
    let to: Array<string> = params.to as Array<string>;
    let subject: string = params.subject as string;
    let mmsType = this.getMmsType(slotId, to, subject);
    let attachment =
      this.getAttachment(context, params.names as Array<string>, params.ct as Array<string>, params.basePath as string,
        params.content as string, mmsSource);
    try {
      let taskId = setInterval(async () => {
        let downloadListUsing = AppStorage.get('downloadListUsing') as boolean;
        if (!downloadListUsing) {
          AppStorage.setOrCreate('downloadListUsing', true);
          let downloadList = SharedPreferencesUtils.getFromPreferences('downloadList', []) as Array<number>;
          if (downloadList.length == 0) {
            clearInterval(taskId);
            // MMS code
            let reportParams: Record<string, number | number[] | string | boolean | string[]> = {
              'slotId': slotId,
              'destinationHost': params.destinationHost,
              'msgType': common.ueMsgType.MMS,
              'msgContent': MmsUtil.getMsgContentByMmsSource(mmsSource),
              'id': params.msgIdReport,
              'sendResult': common.ueMsgSendType.SENDING,
            };

            DotUtil.getInstance().reportSendMessageCommon(reportParams);
            let isEncode = await this.wrapperStepForEncodeMms(context, mmsType, attachment, reportParams);
            if (isEncode) {
              HiLog.i(TAG, `wrapperStepForEncodeMms success.`);
              let mmsCfg: sms.MmsConfig = {
                userAgent: 'OpenHarmony-Mms/2.0',
                userAgentProfile: getContext().resourceManager.getStringSync($r('app.string.uaprof_url'))
              };
              let slotId: number = params.slotId as number;
              sendMmsParams.CARD_SELECT_STATUS = slotId;
              sendMmsParams.TYPE_STATUS = this.mmsTypeDot;
              let mmsParams = await this.buildMmsparams(context, slotId, mmsCfg);
              HiLog.i(TAG, 'mmsParams');
              hiTraceMeter.startTrace(TraceConstant.TRACE_CONVERSATION_SMS_SEND_MMS,
                TraceConstant.TRACE_CONVERSATION_SMS_SEND_MMS_ID);
              this.sendMmsMethod(context as myCommon.UIAbilityContext, mmsParams, callback, reportParams);
            } else {
              AppStorage.setOrCreate('downloadListUsing', false);
              HiLog.i(TAG, `wrapperStepForEncodeMms falied.`);
              DotUtil.getInstance().reportEvent(dotNoNeedParmas, dotCommon.faultEventName.MMS_SEND_FAIL);
              callback('encodeFailed');
            }
          }
        }
      }, 500)
    } catch (error) {
      HiLog.e(TAG, `wrapperStepForEncodeMms fail, error:` + JSON.stringify(error));
      callback(error);
    }
    HiLog.w(TAG, 'sendMmsMessage end');
  }

  sendMmsMethod(context: myCommon.UIAbilityContext, mmsParams: sms.MmsParams, callback: Function,
    reportParams: Record<string, number | number[] | string | boolean | string[]>) {
    HiLog.w(TAG, `sendMmsMethod, slotId: ${mmsParams.slotId}`);
    sms.sendMms(context, mmsParams, async (err: BusinessError) => {
      hiTraceMeter.finishTrace(TraceConstant.TRACE_CONVERSATION_SMS_SEND_MMS,
        TraceConstant.TRACE_CONVERSATION_SMS_SEND_MMS_ID);
      HiLog.i(TAG, `sendMms result: ` + JSON.stringify(err));
      AppStorage.setOrCreate('downloadListUsing', false);
      if (err) {
        reportParams.sendResult = common.ueMsgSendType.FAILED;
        reportParams.failReason = 'err: ' + err.message + ', error code: ' + err.code;
        // 判断错误码为8300001+mmsc为空+隐私空间 上报隐私空间发送失败点位
        if (err?.code === Constant.SMS_ERROR_CODE_INVALID_PARAMETER && StringUtil.isEmpty(mmsParams.mmsc) &&
          await UserUtil.isPrivateAccount()) {
          HiLog.e(TAG, `sendMms fail user space: private space`);
          reportParams.failReason += dotCommon.smsReceiveRecord.MESSAGE_FAIL_DECODE_PRIVATE_AREA;
        }
        DotUtil.getInstance().reportSendMessageCommon(reportParams);
        HiLog.e(TAG, 'sendMms fail, err : ' + err.message + ', error code: ' + err.code);
        callback(err);
      } else {
        HiLog.w(TAG, 'sendMms success');
        reportParams.sendResult = common.ueMsgSendType.SUCCESS;
        DotUtil.getInstance().reportSendMessageCommon(reportParams);
        callback();
      }
    });
  }

  async buildMmsparams(context: Context, slotId: number, mmsCfg: sms.MmsConfig): Promise<sms.MmsParams> {
    let mmsc = await this.getMmsc(context, slotId);
    let path = FileUtil.getSandboxPath(context) + SEND_REQ_MMS;
    let mmsParams: sms.MmsParams = {
      slotId: slotId,
      mmsc: mmsc,
      data: path,
      mmsConfig: mmsCfg
    }
    return mmsParams;
  }

  private getMmsType(slotId: number, to: Array<string>, subjectValue: string): mmsType {
    HiLog.i(TAG, 'getMmsType');
    let from: string = '';
    // Obtaining the local phone number
    if (slotId === 0) {
      from = MmsPreferences.getInstance().getTelephoneNumberOfSim1();
    } else {
      from = MmsPreferences.getInstance().getTelephoneNumberOfSim1();
    }
    let typeFrom: Record<string, string | number> = {
      'address': from + '/TYPE=PLMN',
      'charset': sms.MmsCharSets.UTF_8
    }

    let toArray: Array<Record<string, string | number>> = [];
    to.forEach((item) => {
      let toAddress: Record<string, string | number> = {
        'address': item + '/TYPE=PLMN',
        'charset': sms.MmsCharSets.UTF_8
      };
      toArray.push(toAddress);
    });
    let type: mmsType = {
      from: typeFrom,
      to: toArray,
      contentType: 'application/vnd.wap.multipart.related',
      transactionId: '1',
      version: sms.MmsVersionType.MMS_VERSION_1_2,
      subject: subjectValue
    };
    return type;
  }

  private getAttachment(context: Context, names: Array<string>, ct: Array<string>,
    basePath: string, realPath: string, mmsSource: Array<Mms>): Array<sms.MmsAttachment> {
    HiLog.i(TAG, 'getAttachment');
    let attachment: Array<sms.MmsAttachment> = [];
    names.forEach((name: string, index) => {
      let dotPosition = name.indexOf('.');
      let fileFormat: string = name.substring(dotPosition + 1);
      let contentType: string = '';
      if (dotPosition === -1) {
        contentType = ct[index];
        HiLog.w(TAG, 'dotPosition is -1, ct[index] is ' + ct[index]);
      } else {
        const fileType = mmsSource.find(item => item.name === name)?.type
        this.mmsTypeDot = this.getSendFileTypeDot(fileFormat?.toLowerCase(), fileType);
        contentType = this.getSendFileType(fileFormat?.toLowerCase());
      }
      let path: string;
      if (name.toString().indexOf('.xml') > 0) {
        path = (basePath || FileUtil.getSandboxPath(context)) + '/' + name;
      } else {
        path = (basePath || FileUtil.getSandboxPath(context)) + '/';
        if (fs.accessSync(realPath)) {
          let dirArray: string[] = realPath.split('/');
          let tempTimeDir = dirArray[dirArray.length - 2];
          if (TimeUtils.isValidTimestamp(tempTimeDir)) {
            path += tempTimeDir + '/';
          }
        }
        path += name;
      }
      let obj: sms.MmsAttachment = {
        'path': path,
        'fileName': name,
        'contentId': `<${name}>`,
        'contentLocation': name,
        'contentDisposition': sms.DispositionType.ATTACHMENT,
        'contentTransferEncoding': 'binary',
        'contentType': contentType,
        'isSmil': (fileFormat === 'xml' || fileFormat === 'smi' || fileFormat === 'smil') ? true : false,
        'inBuff': [],
        'charset': sms.MmsCharSets.UTF_8
      };

      attachment.push(obj);
    });
    // 判断附件点位是否是幻灯片
    const contentType = mmsSource && MmsUtil.getMmsContentType(mmsSource);
    if(MmsUtil.isSlideHasImage(contentType) || MmsUtil.isSlideNoImage(contentType)) {
      this.mmsTypeDot = 6
    }
    return attachment;
  }

  private getSendFileType(format: string): string {
    HiLog.i(TAG, 'getSendFileType')
    let fileType: string = '';
    if (format === 'amr' || format === 'm4a') {
      fileType = 'audio/' + format;
    } else if (format === 'mp4' || format === 'webm' || format === 'mov' || format === 'm4v' || format === 'avi' ||
      format === '3gp') {
      fileType = 'video/' + format;
    } else if (format === 'txt') {
      fileType = 'text/plain';
    } else if (format === 'xml' || format === 'smi' || format === 'smil') {
      fileType = 'application/smil';
    } else if (format === 'jpeg' || format === 'jpg' || format === 'gif' || format === 'png' || format === 'webp' ||
      format === 'heif' || format === 'heic' || format === 'bmp') {
      fileType = 'image/*';
    } else if (format === 'vcf') {
      fileType = 'text/x-vCard';
    } else {
      fileType = '';
    }
    return fileType;
  }

  // Type of the attachment returned by dotting(DOT)
  private getSendFileTypeDot(format: string, type?: number): number {
    let fileType: number = 0;
    if (format === 'amr' || format === 'm4a') {
      fileType = 3;
    } else if (format === 'mp4' || format === 'webm' || format === 'mov' || format === 'm4v' || format === 'avi' ||
      format === '3gp') {
      fileType = 2;
    } else if (format === 'jpeg' || format === 'jpg' || format === 'gif' || format === 'png' || format === 'webp' ||
      format === 'heif' || format === 'heic' || format === 'bmp') {
      fileType = type === common.MM_ATTACHMENT_TYPE.MAP ? 5 : 1;
    } else if (format === 'vcf') {
      fileType = 4;
    } else {
      fileType = 0;
    }
    return fileType;
  }

  private async wrapperStepForEncodeMms(context: Context, mmsType: mmsType,
    attachment: Array<sms.MmsAttachment>,
    reportParams: Record<string, number | number[] | string | boolean | string[]>): Promise<boolean> {
    try {
      HiLog.i(TAG, 'wrapperStepForEncodeMms');
      // Invoke the encoding interface.
      let encodeData = await sms.encodeMms({
        messageType: sms.MessageType.TYPE_MMS_SEND_REQ, mmsType, attachment
      });
      HiLog.i(TAG, `encodeMms Success, data length: ${encodeData.length}`);
      let data: ArrayBufferLike = new Uint8Array(encodeData).buffer;
      // Writing MMS PDUs to the Sandbox
      let pduPath = FileUtil.getSandboxPath(context) + SEND_REQ_MMS;
      FileUtil.writeToSandBox(context, pduPath, data, SEND_REQ_MMS);
      return true;
    } catch (error) {
      HiLog.i(TAG, `wrapperStepForEncodeMms error: ` + JSON.stringify(error as BusinessError));
      reportParams.sendResult = common.ueMsgSendType.FAILED;
      reportParams.failReason = JSON.stringify(error as BusinessError);
      DotUtil.getInstance().reportSendMessageCommon(reportParams);
      if (error.code === INVALID_PARAMETER_ERROR_CODE) {
        for (let index = 0; index < attachment.length; index++) {
          const element = attachment[index];
          this.logFileNameMsg(element.fileName);
        }
      }
      return false;
    }
  }

  private logFileNameMsg(name: string | undefined): void {
    if (!name) {
      HiLog.e(TAG, `attachment file name is invalid`);
      return;
    }
    let names = name.split('.');
    if (names.length === 2 && names[0].length > 4) {
      HiLog.w(TAG, `attachment file name length: ${name.length} name: ${StringUtil.mask(names[0]) + '.' + names[1]}`);
    } else {
      HiLog.w(TAG, `attachment file name length: ${name.length}`);
    }
  }

  public queryNetInfo(context: Context, actionData: Record<string, string>, callback: Function): void {
    if (GlobalContext.getContext().getObject('DataWorker') != null) {
      (GlobalContext.getContext()
        .getObject('DataWorker') as WorkerWrapper).sendRequest(common.RUN_IN_WORKER_METHOD.queryNetInfo, {
        actionData: actionData,
        context: context
      } as NetInfoWrapper, (res) => {
        callback(res);
      });
    } else {
      this.netModel.queryNetInfo(actionData, callback, context);
    }
  }

  async getMmsc(context: Context, slotId: number) {
    HiLog.i(TAG, 'getMmsc start slotId: ' + slotId);
    try {
      let mccMnc = sim.getSimOperatorNumericSync(slotId);
      let info = await telephonySim.getSimAccountInfo(slotId);
      let simId: string = String(info.simId);
      let actionData: Record<string, string> = {
        'mccMnc': mccMnc,
        'simId': simId
      };
      let result: Promise<string> = new Promise((resolve) => {
        let mmsc: string = '';
        this.queryNetInfo(context, actionData, (result: Record<string, number | NetInfo[]>) => {
          let list: NetInfo[] = [];
          if (result.code == common.int.SUCCESS && result.abilityResult != null) {
            list = result.abilityResult as NetInfo[];
          }
          if (list.length > 0) {
            mmsc = list[0].homeUrl;
          }
          resolve(mmsc);
        });
      });
      return result;
    } catch (e) {
      HiLog.i(TAG, 'getMmsc error: ' + JSON.stringify(e));
      return '';
    }
  }

  convertResourceToString(context: Context, simName: Resource) {
    HiLog.i(TAG, 'convertResourceToString');
    let simNameString = context.resourceManager.getStringSync(simName);
    return simNameString;
  }
}

export default new SendMsgService();