/**
 * Copyright (c) 2023 Huawei Device Co., Ltd.
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

import { BusinessError } from '@ohos.base';
import mms from '@ohos.telephony.sms';
import fs from '@ohos.file.fs';
import { ValuesBucket } from '@ohos.data.ValuesBucket';
import FileUtil from '../../utils/FileUtil';
import HiLog from '../../utils/HiLog';
import ConversationListService from '../../service/ConversationListService'
import ConversationService from '../../service/ConversationService'
import LooseObject from '../../data/LooseObject'
import common from '../../data/commonData';
import { fileData, mmsRecDataType } from './mmsReceiveType'
import { Mms, mmsInfo, AddressInfo } from '../../utils/TypesUtils';
import lazy { DateUtil } from '../../utils/DateUtil';
import { GlobalContext } from '../../MainAbility/GlobalHelper';
import myCommon from '@ohos.app.ability.common';
import commonEvent from '@ohos.commonEventManager';
import { Context } from '@ohos.abilityAccessCtrl';
import mmsUtilCtr from '../../utils/MmsUtil';
import SharedPreferencesUtils from '../../utils/SharedPreferencesUtils';
import commonData from '../../data/commonData';
import MmsPreferences from '../../utils/MmsPreferences';
import data from '@ohos.telephony.data';
import radio from '@ohos.telephony.radio';
import { addAirPlaneModeListener } from '../../pages/conversation/AirplaneMode';
import MmsUtil from '../../utils/MmsUtil';
import ReceiveService from '../../StaticSubscriber/ReceiveService';
import BlockedUtil from '../../utils/BlockedUtil';
import Constant from '../../data/Constant';
import { StaticSubscriberExtensionContext } from '@kit.BasicServicesKit';
import DotUtil from '../../utils/MmsDot/DotUtils';
import dotCommon, {
  AttachmentContent,
  dotNoNeedParmas,
  ReceiveMessageDownloadParams,
  receiveParams
} from '../../utils/MmsDot/DotCommon';
import { AudioPlayerService } from '../../service/AudioPlayerService';
import MmsDownloadService from '../../service/MmsDownloadService';
import { JSON, taskpool } from '@kit.ArkTS';
import { startDownloadMMsFunction } from '../../utils/MmsUtil';
import StringUtil from '../../utils/StringUtil';
import { mmsListType } from '../../pages/conversation/conversationController';
import { StorageMessageTimeout } from '../../pages/conversation/StorageMessageTimeout';
import { AiFaceChangeUtils } from '../../utils/AiFaceChangeUtils';
import NotificationService from '../../service/NotificationService';
import Base from '@ohos.base';
import { sim } from '@kit.TelephonyKit';
import CardModel from '../../model/CardModel';
import TelephoneUtil from '../../utils/TelephoneUtil';
import FileUtils from '../../utils/FileUtils';
import { FilePathOfSmilBody, XmlUtil } from '../../utils/XmlUtil';
import UserUtil from '../../utils/UserUtil';

const TAG = 'mmsReceiveMain'
const TIME_LENGTH = 13;
const MMS_STATE = 1;  // 彩信点击下载后还未更新UI上状态为下载中
const PART_CT = '10000';

class decodeMMs {
  phone: string = ''
  fileList: Array<fileData> = []
  msgContent: string = ''
  subject?: string = ''
}

interface SmilBodyFileList {
  content: string;
  imgPathList: FilePathOfSmilBody[] | undefined
}

interface LocationContentData {
  messageType: number;
  locationFileList: SmilBodyFileList[];
}

interface ConvertObject {
  _name: string,
  _text: string,
  _type: string,
  _attributes: Record<string, string>,
  _declaration: string,
  _elements: ConvertObject[]
}

export default class mmsReceive {
  static mmsDownLoadState: Map<number, number> = new Map();
  public static async receivePduAndBaseInfo(context: StaticSubscriberExtensionContext, data: string) {
    HiLog.w(TAG, 'receivePduAndBaseInfo');
    if (!data) {
      HiLog.e(TAG, 'receivePduAndBaseInfo null');
      return false;
    }
    let recData: mmsRecDataType = JSON.parse(data) as mmsRecDataType;
    let slotId = recData.parameters.slotId;
    let pdu: string = recData.parameters.rawData;
    let encodeData: number[] = [];
    for (let i = 0; i < pdu.length; i += 2) {
      encodeData.push(Number('0x' + pdu.slice(i, i + 2)));
    }
    let decodeData: mms.MmsInformation = await mms.decodeMms(encodeData)
    let mmsType: mms.MmsNotificationInd = decodeData.mmsType as mms.MmsNotificationInd;
    if (mmsType.from?.address) {
      // 接收消息成功率打点
      // 因发送彩信后，对端收到彩信后也会发送一条回执广播通知（移动）。在收到广播通知时因与接收一条彩信的 event、事件data 的类型完全相同，
      // 仅通过数据解析后是否含有address参数可以区分（收到广播），所以接收到彩信开始接收点位放置此处
      DotUtil.getInstance()
        .reportSendReceiveSuccessRate(dotCommon.smsReceiveRecord.SUCCESS_RATE_TYPE_MMS,
          dotCommon.smsReceiveRecord.SUCCESS_RATE_BEHAVIOR_RECEIVE,
          dotCommon.smsReceiveRecord.SUCCESS_RATE_STATE_START);
      let phone: string = mmsType.from.address.split('/TYPE=PLMN')[0]
      if (!phone) {
        phone = '';
      }
      HiLog.iw(TAG, `receivePduAndBaseInfo, phone:${StringUtil.phoneMask(phone)}, length:${phone?.length}`);
      let actionData: LooseObject = mmsReceive.buildActionData(decodeData, slotId, phone, pdu);
      actionData.mccmnc = await CardModel.getMccmnc(slotId);
      let flagResult = await BlockedUtil.getFlag(actionData.telephone, context);
      actionData.telephoneType = flagResult.telephoneType;
      BlockedUtil.checkBlockMms(actionData, Constant.BLOCKED_NOT_TO_CLOUD, context);
    }
    return true;
  }

  public static async handleFirstUnlockEvent(context: StaticSubscriberExtensionContext) {
    HiLog.i(TAG, 'handleFirstUnlockEvent start');
    let want: Want = {
      bundleName: 'com.ohos.mms',
      abilityName: 'ServiceExtAbility',
      parameters: {
        'serviceEvent': common.STR.SUBSCRIBER_FIRST_UNLOCK_EVENT,
      }
    };
    context.startAbility(want);
  }

  private static async checkUnDownloadAndUnexpiredMms(context: Context): Promise<mmsInfo[]> {
    HiLog.i(TAG, 'checkUnDownloadAndUnexpiredMms start');
    let needDownloadMmsList: mmsInfo[] = [];
    await MmsDownloadService.getInstance().queryUnDownloadMms(context).then((res?: mmsInfo[]) => {
      if (res != undefined && res.length > 0) {
        HiLog.i(TAG, 'undownloaded mms number: ' + res.length);
        let dateNow = Date.now();
        res.forEach((item) => {
          if (dateNow < Number(item.expiresTime)) {
            item.isMsm = true;
            needDownloadMmsList.push(item);
            HiLog.i(TAG, 'an unexpired mms push success');
          }
        })
        if (needDownloadMmsList.length == 0) {
          HiLog.e(TAG, 'all undownload mms already expired');
          return;
        }
      }
    });
    return needDownloadMmsList;
  }

  private static buildActionData(decodeData: mms.MmsInformation, slotId: number,
    phone: string, pdu: string): LooseObject {
    HiLog.i(TAG, 'buildActionData start');
    let actionData: LooseObject = {};
    actionData.slotId = slotId;
    actionData.telephone = phone;
    actionData.telephoneDot = StringUtil.phoneMask(actionData.telephone)
    actionData.content = '';
    actionData.isReceive = true;
    actionData.isMms = true;
    actionData.hasAttachment = false;
    actionData.mmsSource = [{
      size: decodeData.mmsType['messageSize'],
      duration: '',
      type: -1,
      path: '',
      name: '',
    }];
    actionData.mmsPdu = pdu;
    actionData.msgSize = decodeData.mmsType['messageSize'];
    actionData.mmsPduLength = pdu.length;
    actionData.isSender = common.is_sender.YES;
    let expiresTime = `${decodeData.mmsType['expiry']}`;
    actionData.expiresTime = expiresTime;
    let isSecurityMode = mmsUtilCtr.checkAdvancedMode();
    actionData.isAdvancedSecurity = isSecurityMode ? 1 : 0;
    if (expiresTime.length < TIME_LENGTH) {
      let zeroNumber = TIME_LENGTH - expiresTime.length;
      for (let i = 0; i < zeroNumber; i++) {
        actionData.expiresTime += '0'
      }
    }
    return actionData;
  }

  static downloadMms(actionData: LooseObject, context: Context) {
    HiLog.w(TAG, 'downloadMms');
    // 接收到彩信后不进行下载需要进行能效资源释放
    mmsReceive.reduceEfficiencyResource();
  }

  private static reduceEfficiencyResource() {
    let receiveService = ReceiveService.getInstance();
    HiLog.w(TAG, 'reduceEfficiencyResources, releaseResourceNumber: ' + receiveService.releaseResourceNumber);
    receiveService.reduceEfficiencyResources();
  }


  public static async changeStateToDowning(data: mmsInfo, context: Context) {
    let state = mmsReceive.mmsDownLoadState.get(data.id);
    if (state === MMS_STATE) {
      HiLog.e(TAG, 'changeStateToDowning mms is downloading');
      return false;
    }
    mmsReceive.mmsDownLoadState.set(data.id, MMS_STATE);
    HiLog.w(TAG, 'changeStateToDowning msgId:' + data.id);
    let mmsActionData: Record<string, number> = {
      'groupId': data.groupId,
      'msgId': data.id
    }
    let valueBucket: Record<string, number> = {
      'msg_state': common.int.MMS_DOWNLOADING
    }
    ConversationService.getInstance().updateSmsMmsInfoByCondition(context, mmsActionData, valueBucket, (res?: Object) => {
      let publishData: Record<string, boolean> = {};
      publishData.needToUpdate = true;
      publishData.notNeedScrollToEnd = true;
      try {
        commonEvent.publish(common.STR.RECEIVE_TRANSMIT_EVENT, {
          bundleName: common.STR.BUNDLE_NAME,
          subscriberPermissions: ['ohos.permission.RECEIVE_MMS'],
          isOrdered: false,
          data: JSON.stringify(publishData),
          parameters: publishData
        }, () => {
        });
      } catch (err) {
        HiLog.i(TAG, `Failed to publish common event. Code is ${err.code}, message is ${err.message}`);
      }
    });
    let taskId = setTimeout(() => {
      mmsReceive.mmsDownLoadState.delete(data.id);
      clearTimeout(taskId);
    }, 5000);
    // 改变彩信状态为下载中，手动点击或者自动下载触发，打点
    DotUtil.getInstance().reportEvent(dotNoNeedParmas, dotCommon.eventName.CLICK_DOWNLOAD_MMS);
    return true;
  }

  /**
   * start to download mms info.
   *
   * @param data Mms data
   * @param isManual true: indicates manual download and no retry is required. false: Automatic download need retry.
   * @param mmsContext Context
   * @returns
   */
  public static async startDownloadMMs(data: mmsInfo, isManual: boolean, mmsContext: Context) {
    HiLog.w(TAG, 'startDownloadMMs id:' + data.id);
    //开启彩信下载定时器
    let mmsData = new mmsListType();
    mmsData.id = data.id;
    mmsData.isMsm = data.isMsm;
    mmsData.telephone = data.telephone;
    mmsData.slotId = data.subId;
    mmsData.expiresTime = data.expiresTime;
    let storageMessageTimeout: StorageMessageTimeout = StorageMessageTimeout.getInstance();
    storageMessageTimeout.sendMessageStorageAndTimeout(mmsData, true);
    return await startDownloadMMsFunction(data, isManual, common.int.RETRY_TIME_INVALID, mmsContext);
  }

  public static async insertMmsPart(valueBucket: ValuesBucket, mmsContext?: Context) {
    HiLog.w(TAG, 'insertMmsPart');
    let context = mmsContext ? mmsContext :
      (GlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext)
    ConversationService.getInstance().insertMmsInfo(valueBucket, (res: LooseObject) => {
      if (res.code == common.int.SUCCESS) {
        HiLog.i(TAG, 'insertMmsPart success');
      } else {
        HiLog.e(TAG, 'insertMmsPart failed');
      }
    }, context);
  }

  public static async queryMmsPartInfo(msgId: string, callback: Function, mmsContext?: Context) {
    HiLog.i(TAG, 'queryMmsPartInfo');
    let context = mmsContext ? mmsContext :
      (GlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext)
    let actionData: LooseObject = {};
    actionData.msgId = msgId;
    ConversationService.getInstance().queryMmsPartInfo(actionData, (res: LooseObject) => {
      if (callback) {
        callback(res);
      }
    }, context);
  }

  public static async updateMmsPartById(mmsPartId: number, isFraud: number, mmsContext?: Context) {
    HiLog.i(TAG, 'updateMmsPartById');
    let context = mmsContext ? mmsContext :
      (GlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext)
    ConversationService.getInstance().updateMmsPartById(mmsPartId, isFraud, (res: LooseObject) => {
      if (res.code == common.int.SUCCESS) {
        HiLog.i(TAG, 'updateMmsPartById success');
      } else {
        HiLog.i(TAG, 'updateMmsPartById failed');
      }
    }, context);
  }

  public static async changeStateToSuccess(data: LooseObject, decodeMMs: LooseObject, slotId: number,
    context: Context, hasAttachment: boolean, isMmsMapMessage?: boolean) {
    HiLog.i(TAG, 'changeStateToSuccess');
    if (hasAttachment || !StringUtil.isEmpty(decodeMMs.subject)) {
      HiLog.i(TAG, 'has attachment except txt, or have subject need update session');
      ConversationService.getInstance().querySessionId(data.id, (res: number) => {
        HiLog.i(TAG, 'changeStateToSuccess, query session id: ' + res);
        if (res == 0) {
          HiLog.e(TAG, 'changeStateToSuccess, query session fail');
          return;
        }
        let valueBucket: ValuesBucket = {
          'has_attachment': hasAttachment ? common.has_attachment.HAVE : common.has_attachment.NO,
          'content': StringUtil.isEmpty(decodeMMs.subject) ? '' : decodeMMs.subject
        }
        let actionData: LooseObject = {};
        actionData.sessionId = res;
        ConversationListService.getInstance().updateAttachmentByCondition(actionData, valueBucket, context)
      }, context);
      GlobalContext.getContext().setObject('needToUpdate', true);
    }
    let mmsActionData: Record<string, number> = {
      'groupId': data.groupId,
      'msgId': data.id
    }
    let valueBucket: Record<string, number | string> = {
      'mms_pdu': '',
      'msg_content': isMmsMapMessage ? '' : decodeMMs.msgContent,
      'msg_title': decodeMMs.subject,
      'msg_state': 0
    }
    ConversationService.getInstance().updateSmsMmsInfoByCondition(context, mmsActionData, valueBucket, (res: object) => {
      let publishData: Record<string, boolean> = {};
      publishData.needToUpdate = true;
      publishData.msgId = data.id;
      publishData.notNeedScrollToEnd = true;
      try {
        commonEvent.publish(common.STR.RECEIVE_TRANSMIT_EVENT, {
          bundleName: common.STR.BUNDLE_NAME,
          subscriberPermissions: ['ohos.permission.RECEIVE_MMS'],
          isOrdered: false,
          data: JSON.stringify(publishData),
          parameters: publishData
        }, (err: Base.BusinessError) => {
          HiLog.e(TAG, `publish failed, err cause: ${JSON.stringify(err)}.`);
        });
      } catch (err) {
        HiLog.i(TAG, `Failed to publish common event. Code is ${err.code}, message is ${err.message}`);
      }
    });
    // 成功下载、解析彩信后打点
    receiveParams.MSG_TYPE = 3;
    receiveParams.CARD_SELECT_STATUS = slotId;
    DotUtil.getInstance().reportEvent(receiveParams, dotCommon.eventName.RECEIVE_SMS_EVENT);
    DotUtil.getInstance()
      .reportSendReceiveSuccessRate(dotCommon.smsReceiveRecord.SUCCESS_RATE_TYPE_MMS,
        dotCommon.smsReceiveRecord.SUCCESS_RATE_BEHAVIOR_DOWNLOAD,
        dotCommon.smsReceiveRecord.SUCCESS_RATE_STATE_FINISHED);
  }

  public static async dealReceiveFailed(data: mmsInfo, needRetry: boolean, context: Context): Promise<boolean> {
    if (needRetry) {
      let mmsId = data.id;
      let retryTimes = MmsUtil.getRetryTime(mmsId);
      if (retryTimes < common.int.MAX_RETRY_TIME) {
        HiLog.e(TAG, 'dealReceiveFailed mmsId: ' + mmsId + ' retryTimes: ' + retryTimes);
        // 启动一个异步任务
        await mmsReceive.startDownloadMmsTaskPoolTask(retryTimes, common.int.RETRY_INTERVAL, data, context);
        MmsUtil.increasesRetryTime(mmsId);
        return true;
      } else {
        // 清空重试次数
        MmsUtil.clearRetryTime(mmsId);
        mmsReceive.changeStateToFailed(data, context);
        // 能效资源释放
        let receiveService = ReceiveService.getInstance();
        HiLog.i(TAG, 'reduceEfficiencyResources, releaseResourceNumber: ' +
        receiveService.releaseResourceNumber);
        receiveService.reduceEfficiencyResources();
        return false;
      }
    } else {
      mmsReceive.changeStateToFailed(data, context);
      return false;
    }
  }

  public static async startDownloadMmsTaskPoolTask(retryTimes: number, retryInterval: number, data: mmsInfo,
    context: Context) {
    let task: taskpool.Task = new taskpool.Task(startDownloadMMsFunction, data, false, retryTimes, context);
    taskpool.executeDelayed(retryInterval, task).then((result) => {
      HiLog.e(TAG, 'startDownloadMmsTaskPoolTask done, result:' + result);
    });
  }

  public static async changeStateToFailed(data: mmsInfo, context: Context) {
    let mmsActionData: Record<string, number> = {
      'groupId': data.groupId,
      'msgId': data.id
    }
    let valueBucket: Record<string, number> = {
      'msg_state': commonData.int.MMS_DOWNLOAD_FAILED
    }
    ConversationService.getInstance().updateSmsMmsInfoByCondition(context, mmsActionData,
      valueBucket, (res: object) => {
      let publishData: Record<string, boolean> = {};
      publishData.needToUpdate = true;
      try {
        commonEvent.publish(common.STR.RECEIVE_TRANSMIT_EVENT, {
          bundleName: common.STR.BUNDLE_NAME,
          subscriberPermissions: ['ohos.permission.RECEIVE_MMS'],
          isOrdered: false,
          data: JSON.stringify(publishData),
          parameters: publishData
        }, () => {
        });
      } catch (err) {
        HiLog.i(TAG, `Failed to publish common event. Code is ${err.code}, message is ${err.message}`);
      }
    });
  }

  public static async mmsKeepAndDecode(context: Context, dlDataRes: mms.MmsInformation, sandPath: string
    , mmsType: mms.MmsNotificationInd, param: ReceiveMessageDownloadParams) {
    HiLog.i(TAG, 'mmsKeepAndDecode');
    let fileList: fileData[] = []
    let msgContent: string = ''
    if (!dlDataRes.attachment) {
      HiLog.e(TAG, 'attachment array is null');
      msgContent = context.resourceManager.getStringSync($r('app.string.mms_empty_content'));
      let phone: string = ''
      if (mmsType?.from) {
        HiLog.e(TAG, 'mmsType.from');
        phone = mmsType.from.address.split('/TYPE=PLMN')[0]
      }
      return mmsReceive.buildDecodeMMs(phone, fileList, msgContent, '')
    }
    sandPath = sandPath + '/' + new Date().getTime();
    // 创建时间戳目录，保证目录唯一
    fs.mkdirSync(sandPath);
    let attachmentContents: AttachmentContent[] = [];
    let elementSrcArr = await mmsReceive.mmsKeepAndDecodeSmil(dlDataRes, sandPath, attachmentContents, fileList);
    HiLog.w(TAG, `attachment length: ${dlDataRes?.attachment.length}`);
    for (let i: number = 0; i < dlDataRes.attachment.length; i++) {
      if (!dlDataRes.attachment[i]) {
        HiLog.e(TAG, `attachment ${i} is null, download mms failed`);
        break
      }
      let mmsAttachment: mms.MmsAttachment = dlDataRes.attachment[i];
      if (mmsAttachment.contentType === 'application/smil') {
        HiLog.w(TAG, `attachment ${i} is smil`);
        continue;
      }
      let attachmentContent: AttachmentContent = new AttachmentContent();
      attachmentContent.contentId = mmsAttachment.contentId;
      attachmentContent.fileName = mmsAttachment.fileName ?? '';
      attachmentContents.push(attachmentContent);
      HiLog.e(TAG, `attachment index: ${i}, contentId: ${StringUtil.maskFileName(mmsAttachment.contentId)}, `+
        `contentLocation: ${StringUtil.maskFileName(mmsAttachment.contentLocation)}, fileName:  `+
        `${StringUtil.maskFileName(mmsAttachment.fileName === undefined ? '' : mmsAttachment.fileName)}`);
      let fileName: string = mmsReceive.getAvailAbleFileNameFromSmil(elementSrcArr, mmsAttachment);
      HiLog.w(TAG, `attachment ${i} final fileName: ${fileName}`);
      let formatFileName = FileUtil.formatFileName(fileName);
      let inBuff: number[] = mmsAttachment.inBuff || []
      if (inBuff.length === 0) {
        HiLog.e(TAG, 'inBuff.length is 0, download mms failed');
      }
      if (StringUtil.isEmpty(formatFileName) || inBuff.length === 0) {
        HiLog.e(TAG, 'formatFileName or inBuff lenght is 0, download mms failed');
        // 如果有smil文件，但smil中的名称和内存中附件对象的三个属性名称都不匹配时，需要特殊处理：使用pdu中的cl进行命名存储
        formatFileName = mmsAttachment.contentLocation;
      }
      let contentType = mmsAttachment.contentType
      // 待写入的文件内容
      let data = new Uint8Array(inBuff).buffer;
      let fileMode = fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE;
      if (contentType === 'application/smil') {
        fileMode |= fs.OpenMode.TRUNC;
      }
      try {
        // 使用附件结构体的filename作为文件名
        let file: fs.File = await fs.open(sandPath + '/' + formatFileName, fileMode);
        // Write the attachment, including the .smil file, to the sandbox directory of the application.
        let length: number = await fs.write(file.fd, data);
        HiLog.w(TAG, 'write contentType: ' + contentType + ' and length: ' + length);
        let fileData: fileData = {
          fileType: contentType,
          path: file.path,
          name: file.name
        }
        if (fileData.fileType === 'text/plain') {
          let content: string = mmsReceive.fileToContext(file.path);
          msgContent += content
          HiLog.w(TAG, `mmsKeepAndDecode attachment is text/plain`);
        } else {
          fileList.push(fileData)
          HiLog.w(TAG, `mmsKeepAndDecode attachment is not text/plain`);
        }
        fs.close(file.fd);
      } catch (err) {
        HiLog.w(TAG, 'mmsKeepAndDecode write file error' + JSON.stringify(err));
      }
    }
    if (!mmsType.from) {
      return false
    }
    let phone: string = mmsType.from.address.split('/TYPE=PLMN')[0]
    let mmsTypeFromDataRes: mms.MmsRetrieveConf = dlDataRes.mmsType as mms.MmsRetrieveConf;
    param.ATTACHMENT_CONTENT = JSON.stringify(attachmentContents);
    return mmsReceive.buildDecodeMMs(phone, fileList, msgContent, mmsTypeFromDataRes.subject || '');
  }

  /**
   * 从smil文件解析的附件scr数组中匹配有效的fileName
   *
   * @param elementSrcArr smil文件解析的附件scr数组
   * @param mmsAttachment 附件数据
   *
   * @returns 附件名称
   */
  private static getAvailAbleFileNameFromSmil(elementSrcArr: string[] | false,
    mmsAttachment: mms.MmsAttachment): string {
    let fileName: string = '';
    if (Array.isArray(elementSrcArr) && elementSrcArr.length > 0) {
      for (let i = 0; i < elementSrcArr.length; i++) {
        let availableSrc = mmsReceive.getAvailablAttachFileName(elementSrcArr[i]);
        let availableContentId = mmsReceive.getAvailablAttachFileName(mmsAttachment.contentId);
        let availableFileName = mmsReceive.getAvailablAttachFileName(mmsAttachment.fileName as string);
        let availablContentLocation = mmsReceive.getAvailablAttachFileName(mmsAttachment.contentLocation);
        if (!StringUtil.isEmpty(availablContentLocation) && availableSrc === availablContentLocation) {
          fileName = availablContentLocation;
          HiLog.w(TAG, 'elementSrcArr includes attachment contentLocation:' + StringUtil.maskFileName(fileName));
          break;
        } else if (!StringUtil.isEmpty(availableContentId) && availableSrc === availableContentId) {
          fileName = availableContentId;
          HiLog.w(TAG, 'elementSrcArr includes attachment contentId:' + StringUtil.maskFileName(fileName));
          break;
        } else if (!StringUtil.isEmpty(availableFileName) && availableSrc === availableFileName) {
          fileName = availableFileName;
          HiLog.w(TAG, 'elementSrcArr includes attachment fileName:' + StringUtil.maskFileName(fileName));
          break;
        }
      }
      if (StringUtil.isEmpty(fileName)) {
        HiLog.w(TAG, 'elementSrcArr not includes attachment name');
        fileName = mmsReceive.getAvailAbleFileName(mmsAttachment);
      }
    } else {
      HiLog.w(TAG, 'elementSrcArr is empty');
      fileName = mmsReceive.getAvailAbleFileName(mmsAttachment);
    }
    return fileName;
  }

  /**
   * 当smil文件解析的src数组中匹配不到有效的fileName时保持获取fileName的老逻辑
   * @param mmsAttachment 附件数据
   *
   * @returns 保存到沙箱时要用的附件fileName
   */
  private static getAvailAbleFileName(mmsAttachment: mms.MmsAttachment): string {
    let fileName: string = mmsReceive.getAvailablAttachFileName(mmsAttachment.contentId);
    if (StringUtil.isEmpty(fileName)) {
      HiLog.w(TAG, 'mmsAttachment contentId is empty');
      fileName = mmsAttachment.fileName || '';
    }
    return fileName;
  }

  /**
   * 从协议下载完彩信后，解析彩信中的smil文件，并返回smile文件elements中的附件src数组
   *
   * @param dlDataRes 彩信信息
   * @param sandPath 彩信附件保存的沙箱文件夹目录
   * @param attachmentContents 保存附件的数组
   * @param fileList 彩信文件数组
   *
   * @returns smile文件elements中的附件src数组
   */
  public static async mmsKeepAndDecodeSmil(dlDataRes: mms.MmsInformation, sandPath: string
    , attachmentContents: AttachmentContent[], fileList: fileData[]) {
    HiLog.i(TAG, 'mmsKeepAndDecodeSmil');
    if (!dlDataRes.attachment) {
      HiLog.e(TAG, 'mmsKeepAndDecodeSmil attachment array is null, download mms failed');
      return false
    }
    for (let i: number = 0; i < dlDataRes.attachment.length; i++) {
      if (!dlDataRes.attachment[i]) {
        HiLog.e(TAG, `mmsKeepAndDecodeSmil attachment ${i} is null, download mms failed`);
        break;
      }
      let mmsAttachment: mms.MmsAttachment = dlDataRes.attachment[i]
      if (mmsAttachment.contentType !== 'application/smil') {
        continue;
      }
      let attachmentContent: AttachmentContent = new AttachmentContent();
      attachmentContent.contentId = mmsAttachment.contentId;
      attachmentContent.fileName = mmsAttachment.fileName ?? '';
      attachmentContents.push(attachmentContent);
      let fileName = mmsReceive.getSmilFileName(mmsAttachment);
      let formatFileName = FileUtil.formatFileName(fileName);
      let inBuff: number[] = mmsAttachment.inBuff || []
      if (inBuff.length === 0) {
        HiLog.e(TAG, 'mmsKeepAndDecodeSmil inBuff.length is 0, download mms failed');
      }
      if (StringUtil.isEmpty(formatFileName) || inBuff.length === 0) {
        HiLog.e(TAG, 'mmsKeepAndDecodeSmil formatFileName or inBuff lenght is 0, download mms failed');
        break;
      }
      let contentType = mmsAttachment.contentType
      // 待写入的文件内容
      let data = new Uint8Array(inBuff).buffer;
      let fileMode = fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE;
      if (contentType === 'application/smil') {
        fileMode |= fs.OpenMode.TRUNC;
      }
      try {
        // 使用附件结构体的filename作为文件名
        let file: fs.File = await fs.open(sandPath + '/' + formatFileName, fileMode);
        let length: number = await fs.write(file.fd, data);
        HiLog.w(TAG, 'mmsKeepAndDecodeSmil write contentType: ' + contentType + ' and length: ' + length);
        let fileData: fileData = {
          fileType: contentType,
          path: file.path,
          name: file.name
        }
        fileList.push(fileData)
        fs.close(file.fd);
      } catch (err) {
        HiLog.w(TAG, 'mmsKeepAndDecodeSmil write file error' + JSON.stringify(err));
      }
      break;
    }
    if (fileList.length > 0) {
      let fileData: fileData = fileList[0];
      // smil文件解析
      let parStrArr: ConvertObject[] = MmsUtil.getSmilParStrData(fileData.path);
      let elementSrcArr: string[] = [];
      if (Array.isArray(parStrArr) && parStrArr.length > 0) {
        // 从smil的element中文件中获取
        parStrArr.forEach((part, index) => {
          part._elements?.forEach((attach, index) => {
            if (attach._attributes['src'] === null) {
              HiLog.e(TAG, index + 'the attach has no src');
            } else {
              HiLog.w(TAG, 'mmsKeepAndDecodeSmil elementSrc:' + StringUtil.maskFileName(attach._attributes['src']));
              elementSrcArr.push(attach._attributes['src']);
            }
          })
        })
      }
      return elementSrcArr;
    } else {
      HiLog.e(TAG, 'mmsKeepAndDecodeSmil smil invalid');
      return false;
    }
  }

  private static getSmilFileName(mmsAttachment: mms.MmsAttachment): string {
    let fileName = '';
    if (!StringUtil.isEmpty(mmsAttachment.contentLocation)) {
      fileName = mmsAttachment.contentLocation;
    } else if (!StringUtil.isEmpty(mmsAttachment.fileName)) {
      fileName = mmsAttachment.fileName as string;
    } else if (!StringUtil.isEmpty(mmsAttachment.contentId)) {
      fileName = mmsAttachment.contentId;
    } else {
      HiLog.e(TAG, 'getSmilFileName invalid');
    }
    return fileName;
  }

  private static getAvailablAttachFileName(str: string): string {
    if (str.startsWith('cid:')) {
      str = str.replace('cid:', '');
    }
    // 检查字符串是否以<开头和>结尾
    if (str.startsWith('<') && str.endsWith('>')) {
      // 使用 slice 方法去掉首尾的括号
      str = str.slice(1, -1);
    }
    return str;
  }

  private static buildDecodeMMs(phone: string, fileList: fileData[], msgContent: string, subject?: string): decodeMMs {
    let res = new decodeMMs()
    res.phone = phone
    res.fileList = fileList
    res.msgContent = msgContent
    res.subject = subject
    return res
  }

  public static async setToSQL(context: Context, callback: Function, data: LooseObject) {
    HiLog.w(TAG, 'setToSQL');
    ConversationListService.getInstance().querySessionByTelephone(data.telephone, async (res: LooseObject) => {
      let response: LooseObject = res.response;
      let sendResults: Array<LooseObject> = [];
      let sendResult: LooseObject = {};
      sendResult.slotId = data.slotId;
      sendResult.telephone = data.telephone;
      sendResult.content = data.content;
      sendResult.sendStatus = common.int.MMS_NOT_DOWNLOAD;
      sendResult.isAdvancedSecurity = data.isAdvancedSecurity;
      sendResults.push(sendResult);
      if (sendResults.length == 0) {
        HiLog.e(TAG, 'setToSQL FAILED');
        return;
      }
      let ConvService = ConversationService.getInstance();
      let param: LooseObject = ConvService.dealSendResults(sendResults);
      if (String(data.blockedSources) == Constant.BLOCKED_SOURCES_FRAUD) {
        param.blockedType = Constant.SESSION_BLOCKED_FRAUD;
      } else {
        param.blockedType = Constant.SESSION_NORMAL;
      }
      data.sendResults = sendResults;
      let notificationIsShow = SharedPreferencesUtils.getFromPreferences('notificationIsShow', false);
      let mobilePhoneNumber = await NotificationService.getInstance(context).getCurrentThreadMobilePhoneNumber();
      data.isNeedSendNotice = notificationIsShow ? (mobilePhoneNumber !== String(data.telephone)) : true;
      if (res.code == common.int.SUCCESS && response.id <= 0) {
        ConvService.dealNoExistSession(true, param, data, callback, context);
      } else {
        ConvService.dealExistSession(response, param, data, callback, context);
      }
    }, context);

  }

  public static fileToContext(url: string) {
    return fs.readTextSync(url);
  }

  public static convertStrArray(sourceStr: string): Array<number> {
    HiLog.i(TAG, 'convertStrArray');
    let wby: string = sourceStr;
    let length: number = wby.length;
    let isDouble: boolean = (length % 2) == 0;
    let halfSize: number = Number.parseInt('' + length / 2);
    HiLog.i(TAG, 'convertStrArray, length=' + length + ', isDouble=' + isDouble);
    if (isDouble) {
      let number0xArray: string[] = new Array(halfSize);
      for (let i = 0; i < halfSize; i++) {
        number0xArray[i] = '0x' + wby.substr(i * 2, 2);
      }
      let numberArray: number[] = new Array(halfSize);
      for (let i = 0; i < halfSize; i++) {
        numberArray[i] = Number.parseInt(number0xArray[i], 16);
      }
      return numberArray;
    } else {
      let number0xArray: string[] = new Array(halfSize + 1);
      for (let i = 0; i < halfSize; i++) {
        number0xArray[i] = '0x' + wby.substr(i * 2, 2);
      }
      number0xArray[halfSize] = '0x' + wby.substr((halfSize * 2) + 1, 1);
      let numberArray: number[] = new Array(halfSize + 1);
      for (let i = 0; i < halfSize; i++) {
        numberArray[i] = Number.parseInt(number0xArray[i], 16);
      }
      let last0x = '0x' + wby.substr(wby.length - 1, 1);
      numberArray[halfSize] = Number.parseInt(last0x);
      return numberArray;
    }
  }

  public static createDownloadMmsTask(data: mmsInfo, mmsParam: mms.MmsParams, context: Context,
    sandPath: string, mmsType: mms.MmsNotificationInd, isManual: boolean, retryTimes: number) {
    let taskId = setInterval(() => {
      HiLog.i(TAG, 'downloadSetInterval: ' + data.id + ', retryTimes:' + retryTimes);
      let isInRetry = retryTimes > common.int.RETRY_TIME_INVALID;
      if (isInRetry) {
        clearInterval(taskId);
        mmsReceive.downloadMmsProcess(mmsParam, context, data, sandPath, mmsType, isManual, retryTimes);
        return;
      }
      // 下面会执行AppStorage，而AppStorage不适用于子线程，走进去会报错，因此不走下面的代码。
      let downloadListUsing = AppStorage.get('downloadListUsing') as boolean;
      HiLog.i(TAG, 'download downloadListUsing: ' + downloadListUsing)
      if (!downloadListUsing) {
        AppStorage.setOrCreate('downloadListUsing', true);
        let downloadList = SharedPreferencesUtils.getFromPreferences('downloadList', []) as Array<number>;
        let index = downloadList.findIndex(item => item == data.id)
        HiLog.i(TAG, 'downloadIdList is: ' + JSON.stringify(downloadList) + ',index is:' + index)
        if (index <= 5 && index >= 0) {
          AppStorage.setOrCreate('downloadListUsing', false);
          HiLog.i(TAG, 'downloading id: ' + data.id)
          clearInterval(taskId);
          mmsReceive.downloadMmsProcess(mmsParam, context, data, sandPath, mmsType, isManual, retryTimes);
        } else if (index < 0) {
          downloadList.push(data.id);
          SharedPreferencesUtils.saveToPreferences('downloadList', downloadList);
          AppStorage.setOrCreate('downloadListUsing', false);
        }
      }
    }, 500)
  }

  private static judgeRcsAudio(decodeMMs: decodeMMs | boolean): boolean {
    HiLog.w(TAG, 'judgeRcsAudio');
    let decodeMms: decodeMMs = decodeMMs as decodeMMs;
    let isRcsAudioStatus: boolean = false;
    if (decodeMms.fileList.length == 1 && decodeMms.fileList[0].fileType.startsWith('audio')) {
      isRcsAudioStatus = true;
    }
    HiLog.w(TAG, 'judgeRcsAudio isRcsAudioStatus:' + isRcsAudioStatus)
    return isRcsAudioStatus;
  }

  public static downloadMmsProcess(mmsParam: mms.MmsParams, context: Context, data: mmsInfo,
    sandPath: string, mmsType: mms.MmsNotificationInd, isManual: boolean, retryTimes: number) {
    HiLog.i(TAG, 'downloadMmsProcess');
    let isNeedRetryAgain = false;
    let isInRetryProcess = retryTimes > common.int.RETRY_TIME_INVALID;
    let param = new ReceiveMessageDownloadParams();
    mmsReceive.initReceiveDownloadParam(param, data, retryTimes, mmsParam);
    mms.downloadMms(context, mmsParam).then(async () => {
      HiLog.i(TAG, 'download success id:' + data.id);
      if (!isInRetryProcess) {
        AppStorage.setOrCreate('downloadListUsing', true);
      }
      let downloadList = SharedPreferencesUtils.getFromPreferences('downloadList', []) as Array<number>;
      let index = downloadList.findIndex(item => item == data.id);
      downloadList.splice(index, 1);
      SharedPreferencesUtils.saveToPreferences('downloadList', downloadList);
      if (!isInRetryProcess) {
        AppStorage.setOrCreate('downloadListUsing', false);
      }
      HiLog.w(TAG, 'downloadFinish');
      let dlDataRes: mms.MmsInformation = await mms.decodeMms(mmsParam.data)
      let decodeMMs = await mmsReceive.mmsKeepAndDecode(context, dlDataRes, sandPath, mmsType, param);
      let isOnlyAudioStatus: boolean = mmsReceive.judgeRcsAudio(decodeMMs);
      if (decodeMMs) {
        let actionData: LooseObject = {};
        actionData.groupId = data.groupId;
        ConversationService.getInstance().deleteMmsInfoByCondition(context, actionData, () => {
          mmsReceive.decodeMmsData(decodeMMs as decodeMMs, context, data, isOnlyAudioStatus, mmsParam.slotId, param);
        });
        return;
      } else {
        // 短信下载状态为失败
        param.DOWNLOAD_STATE = dotCommon.smsReceiveRecord.RECEIVE_MESSAGE_DOWNLOAD_STATE_FAIL;
        param.DOWNLOAD_DETAIL_ERROR = dotCommon.smsReceiveRecord.RECEIVE_MESSAGE_DOWNLOAD_FAIL_DECODE_MMS_EMPTY;
        DotUtil.getInstance().reportEvent(param, dotCommon.eventName.RECEIVE_MESSAGE_DOWNLOAD);
        // If the message is sent manually, do not need to retry.
        isNeedRetryAgain = await mmsReceive.dealReceiveFailed(data, !isManual, context);
        return;
      }
    }).catch(async (error: BusinessError) => {
      HiLog.e(TAG, 'downloadMms or decodeMms, failed. Cause: ' + JSON.stringify(error));
      if (!isInRetryProcess) {
        AppStorage.setOrCreate('downloadListUsing', true);
      }
      // 彩信接收失败fault打点
      DotUtil.getInstance().reportFaultEvent(dotNoNeedParmas, dotCommon.faultEventName.MMS_RECIEVE_FAIL);
      // 短信下载状态为失败
      param.DOWNLOAD_STATE = dotCommon.smsReceiveRecord.RECEIVE_MESSAGE_DOWNLOAD_STATE_FAIL;
      param.DOWNLOAD_DETAIL_ERROR = JSON.stringify(error);
      if (error?.code === Constant.SMS_ERROR_CODE_UN_KNOW && await UserUtil.isPrivateAccount()) {
        HiLog.e(TAG, `download failed user space: private space`);
        param.DOWNLOAD_DETAIL_ERROR += dotCommon.smsReceiveRecord.MESSAGE_FAIL_DECODE_PRIVATE_AREA;
      }
      DotUtil.getInstance().reportEvent(param, dotCommon.eventName.RECEIVE_MESSAGE_DOWNLOAD);
      let downloadList = SharedPreferencesUtils.getFromPreferences('downloadList', []) as Array<number>;
      let index = downloadList.findIndex(item => item == data.id);
      if (index >= 0) {
        HiLog.i(TAG, 'download failed id:' + data.id)
        downloadList.splice(index, 1);
        SharedPreferencesUtils.saveToPreferences('downloadList', downloadList);
      }
      if (!isInRetryProcess) {
        AppStorage.setOrCreate('downloadListUsing', false);
      }
      // If the message is sent manually, do not need to retry.
      isNeedRetryAgain = await mmsReceive.dealReceiveFailed(data, !isManual, context);
      return;
    }).finally(() => {
      // isManual有如下两层含义：
      // 一个是接收时自动下载，自动重试3次；而对于手动下载的，不进行重试（因为重试时间太长了，用户无法等待1分钟甚至几分钟的下载中的状态）。
      // 另外一个是重试需要保证进程存活，申请了能效资源的，因此释放掉时候这里要延迟释放；
      if (isNeedRetryAgain) {
        HiLog.e(TAG, 'reduceEfficiencyResources, wait for a moment to download mms.');
      } else {
        let receiveService = ReceiveService.getInstance();
        HiLog.i(TAG, 'reduceEfficiencyResources, releaseResourceNumber: ' +
          receiveService.releaseResourceNumber);
        receiveService.reduceEfficiencyResources();
      }
      // 下载完成之后删除从框架接口下载的XXX_RetrieveConfXX.mms 文件
      FileUtils.deleteFile(mmsParam?.data);
    })
  }

  private static initReceiveDownloadParam(param: ReceiveMessageDownloadParams, data: mmsInfo, retryTimes: number,
    mmsParam: mms.MmsParams) {
    param.PHONE_NUMBER = StringUtil.phoneMask(data.telephone);
    param.EXPIRATION_TIME = data.expiresTime;
    param.RETRY_TIME = retryTimes;
    param.MCCMNC = sim.getSimOperatorNumericSync(mmsParam.slotId);
    param.MSGID = data.id ? data.id.toString() : '';
  }

  private static getMapMetadataKey2ValueInSmil = (fileList: fileData[]) => {
    let smilFile = fileList.find(v => (v.fileType === 'application/smil'));
    if (!smilFile?.path) {
      return null;
    }
    try {
      let str = fs.readTextSync(smilFile.path);
      let smilObject = XmlUtil.convertToJSObject(str);
      if (!smilObject) {
        return null;
      }
      return XmlUtil.getMetadataFromXmlNode(smilObject);
    } catch (e) {
      HiLog.e(TAG, `getMapMetadataKey2ValueInSmil error: ${e?.code} ${e?.message}`);
    }
    return null;
  }

  private static async decodeMmsData(decodeMMs: decodeMMs, context: Context, data: mmsInfo,
    isOnlyAudioStatus: boolean, slotId: number, param: ReceiveMessageDownloadParams) {
    HiLog.i(TAG, 'decodeMmsData');
    let smilePath: undefined | string = '';
    let audioFlag: boolean = false;
    audioFlag = decodeMMs.fileList.some(item => item.fileType.includes('audio'))
    if (audioFlag && !isOnlyAudioStatus) {
      smilePath = decodeMMs.fileList.find(item => item?.fileType && item?.fileType == 'application/smil')?.path
      HiLog.i(TAG, 'decodeMmsData audioFlag: ' + audioFlag);
    }
    let hasAttachment: boolean = mmsReceive.checkHasAttachment(decodeMMs.fileList);
    let locationContentData: LocationContentData | null = mmsReceive.getLocationContentData(decodeMMs);
    decodeMMs.fileList.forEach(async (ele, index) => {
      await mmsReceive.insertMmsPartProcess(ele, data, index, smilePath, audioFlag, isOnlyAudioStatus, param, context,
        locationContentData);
    })
    await mmsReceive.saveContentToText(data, decodeMMs as LooseObject, param, context);
    MmsUtil.clearRetryTime(data.id);
    // 此时短信下载已成功
    param.DOWNLOAD_STATE = dotCommon.smsReceiveRecord.RECEIVE_MESSAGE_DOWNLOAD_STATE_SUCCESS;
    param.MMS_SIZE = Math.ceil(param.MMS_SIZE / common.int.BYTE_CONVERSION_UNIT);
    DotUtil.getInstance().reportEvent(param, dotCommon.eventName.RECEIVE_MESSAGE_DOWNLOAD);
    await mmsReceive.changeStateToSuccess(data, decodeMMs, slotId, context, hasAttachment,
      locationContentData?.messageType === common.MM_ATTACHMENT_TYPE.MAP);
  }

  private static parseLocationMessageContent = (content: string | number | Resource | undefined) => {
    try {
      if (!content || typeof content !== 'string') {
        return null;
      }
      let tempArray = content.split('\n');
      if (tempArray.length < 3) {
        return null;
      }
      return tempArray;
    } catch (e) {
      HiLog.e(TAG, `parseLocationMessageContent error: ${e?.code} ${e?.message}`);
    }
    return null;
  }

  private static getLocationContentData(decodeMMs: decodeMMs): LocationContentData | null {
    HiLog.i(TAG, 'getLocationContentData');
    let mapMetadataKey2Value: Map<string, string> | null = null;
    let imgPathList: FilePathOfSmilBody[][] | null = null;
    let smilFile = decodeMMs.fileList.find(v => (v.fileType === 'application/smil'));
    if (smilFile?.path) {
      let str = fs.readTextSync(smilFile.path);
      let smilObject = XmlUtil.convertToJSObject(str);
      if (smilObject) {
        mapMetadataKey2Value = XmlUtil.getMetadataFromXmlNode(smilObject);
        imgPathList = XmlUtil.getImgPathListFromXmlNode(smilObject);
      }
    }

    if (!mapMetadataKey2Value) {
      HiLog.e(TAG, `getLocationContentData: mapMetadataKey2Value empty`);
      return null;
    }

    let messageType: number = -1;
    let locationFileList: SmilBodyFileList[] = [];
    let tempString: string | undefined = mapMetadataKey2Value.get(Constant.MMS_LOCATION_MESSAGE_IN_SLIDE_SMIL);
    if (tempString) { //包含彩信位置附件的幻灯片消息
      let indexList = tempString.split(commonData.STR.COMMA);
      for (let i = 0; i < indexList.length; i++) {
        let coordinateString = mapMetadataKey2Value.get(`${Constant.COORDINATE_IN_SMIL}_${indexList[i]}`);
        let msgContent = mapMetadataKey2Value.get(`${Constant.MMS_LOCATION_CONTENT_IN_SLIDE_SMIL}_${indexList[i]}`);
        if (!coordinateString && !msgContent) {
          continue;
        }

        let tempArray = mmsReceive.parseLocationMessageContent(msgContent);
        let itemFilePathList: undefined | FilePathOfSmilBody[] = imgPathList?.[indexList[i]];
        if (coordinateString) {
          const coordinate = coordinateString.split(commonData.STR.COMMA);
          locationFileList.push({
            imgPathList: itemFilePathList,
            content: JSON.stringify(new AddressInfo(Number(coordinate[1]) || 0,
              Number(coordinate[0]) || 0, tempArray?.[0] ?? '', tempArray?.[1] ?? ''
            ))
          });
        } else {
          locationFileList.push({
            imgPathList: itemFilePathList,
            content: JSON.stringify(new AddressInfo(0, 0, tempArray?.[0] ?? '',
              tempArray?.[1] ?? ''))
          });
        }
      }
      messageType = commonData.MM_ATTACHMENT_TYPE.SLIDE;
    } else if (mapMetadataKey2Value.get(Constant.MMS_MESSAGE_TYPE_IN_SMIL) ===
    Constant.LOCATION_MMS_MESSAGE_TYPE) { //位置消息
      let tempArray = mmsReceive.parseLocationMessageContent(decodeMMs.msgContent);
      locationFileList.push({
        imgPathList: imgPathList?.[0],
        content: JSON.stringify(new AddressInfo(
          Number(mapMetadataKey2Value.get(Constant.LATITUDE_IN_SMIL) ?? 0),
          Number(mapMetadataKey2Value.get(Constant.LONGITUDE_IN_SMIL) ?? 0),
          tempArray?.[0] ?? '', tempArray?.[1] ?? ''))
      });
      messageType = commonData.MM_ATTACHMENT_TYPE.MAP;
    }
    HiLog.i(TAG, 'getLocationContentData: messageType: ' + messageType);
    return {
      messageType: messageType,
      locationFileList: locationFileList
    };
  }

  public static async insertMmsPartProcess(item: fileData, data: mmsInfo, index: number, smilePath: undefined | string,
    audioFlag: boolean, isOnlyAudioStatus: boolean, param: ReceiveMessageDownloadParams, context: Context,
    locationContentData: LocationContentData | null) {
    let size = FileUtil.getFileSizeByPath(item.path);
    let fileName = FileUtil.getFileName(item.path);
    HiLog.i(TAG, `insertMmsPartProcess: item part_index: ${index}, fileType: ${item.fileType}, fileName: ${fileName}`);
    let valueBucket: ValuesBucket = {
      'msg_id': data.id,
      'group_id': data.groupId,
      'part_index': index,
      'part_size': size,
      'recording_time': '',
      'type': -1,
      'location_path': item.path,
      'encode': 0,
      'state': 0,
      'content': '',
      // 资源文件附件引用计数-初始为1，其他模块复用（如收藏）引用计数 +1 （历史数据默认为-1）
      'reference_count': commonData.referenceCount.ONE,
      'ct': item.fileType
    };
    let imageFileExtensions = ['jpeg', 'jpg', 'png', 'gif', 'bmp', 'heic', 'heif'];
    let fileExtension = item.path.substring(item.path.lastIndexOf('.') + 1);
    fileExtension = fileExtension.toLowerCase();
    if (item.fileType == 'application/smil') {
      smilePath = item.path;
      valueBucket.type = common.MM_ATTACHMENT_TYPE.SMIL;
      // 彩信下载点位信息记录
      mmsReceive.dealReceiveMessageDownloadSimlContent(smilePath, param);
      await mmsReceive.insertMmsPart(valueBucket, context);
    } else if (item.fileType.includes('x-vCard') || item.fileType.includes('x-vcard')) {
      valueBucket.type = common.MM_ATTACHMENT_TYPE.VCARD;
      await mmsReceive.insertMmsPart(valueBucket, context);
    } else if (item.fileType.includes('image') || imageFileExtensions.includes(fileExtension)) {
      let tempObject = locationContentData?.locationFileList?.find(v => (v && v.imgPathList?.[0]?.src === fileName));
      if (locationContentData?.locationFileList &&
        locationContentData.messageType === common.MM_ATTACHMENT_TYPE.SLIDE && tempObject) { //包含彩信位置附件的幻灯片
        valueBucket.type = common.MM_ATTACHMENT_TYPE.MAP;
        valueBucket.content = tempObject.content ?? '';
      } else if (locationContentData && locationContentData.messageType === common.MM_ATTACHMENT_TYPE.MAP) { //彩信位置消息
        valueBucket.type = common.MM_ATTACHMENT_TYPE.MAP;
        valueBucket.content = locationContentData.locationFileList?.[0]?.content ?? '';
      } else { //图片附件
        valueBucket.type = common.MM_ATTACHMENT_TYPE.IMAGE;
      }
      await mmsReceive.insertMmsPart(valueBucket, context);
    } else if (item.fileType.includes('video') || item.fileType.includes('media')) {
      valueBucket.type = common.MM_ATTACHMENT_TYPE.VIDEO;
      let videoName = FileUtil.getFileName(item.path);
      FileUtil.writeVideoFirstFrameImageToSandBox(context, item.path, videoName);
      await mmsReceive.insertMmsPart(valueBucket, context);
    } else if (item.fileType.includes('audio')) {
      valueBucket.type = common.MM_ATTACHMENT_TYPE.AUDIO;
      if (audioFlag && isOnlyAudioStatus) {
        let audioTime: string = '';
        audioTime = await AudioPlayerService.getInstance().getAudioDuration(item.path);
        let audioDuration = parseInt(audioTime);
        if (isNaN(audioDuration)) {
          HiLog.e(TAG, 'getAudioDuration fail, cannot obtain precise time of audio');
          valueBucket.recording_time = DateUtil.formatMilliseconds('0');
        } else {
          audioDuration = audioDuration / common.int.MESSAGE_CODE_THOUSAND;
          audioDuration = Math.floor(audioDuration);
          if (audioDuration == 0) {
            audioDuration++;
          }
          audioTime = (audioDuration >= common.int.RCS_RECORD_MAX_DURATION) ? '01:00' : ((audioDuration >= common
            .int.RCS_RECORD_DURATION) ? ('00:' + audioDuration.toString()) : '00:0' + audioDuration.toString());
          valueBucket.recording_time = audioTime;
        }
        await mmsReceive.insertMmsPart(valueBucket, context);
      } else if (audioFlag && smilePath && smilePath?.length > 0) {
        let filePath = smilePath;
        let str = fs.readTextSync(filePath);
        str = str.toLowerCase();
        let recordTime = str.substring(str.indexOf('dur="') + 5, str.indexOf('"', str.indexOf('dur="') + 5))
          .replace('ms', ''); // Must use " NOT ALLOW MODIFY IT!
        HiLog.i(TAG, 'audioSmileDur is:' + str.substring(str.indexOf('dur="') + 5,
          str.indexOf('"', str.indexOf('dur="') + 5))) // Must use " NOT ALLOW MODIFY IT!
        if (recordTime.indexOf('s') >= 0) {
          recordTime = String(Number(recordTime.replace('s', '')) * 1000)
        }
        valueBucket.recording_time = DateUtil.formatMilliseconds(recordTime);
        await mmsReceive.insertMmsPart(valueBucket, context);
      }
    } else {
      HiLog.i(TAG, 'mms file format unknown');
    }
    param.MMS_SIZE += size;
    param.CONTENT_TYPE = (StringUtil.isEmpty(param.CONTENT_TYPE) ? '' : param.CONTENT_TYPE + ',') + valueBucket.type;
  }

  private static dealReceiveMessageDownloadSimlContent(smilePath: string, param: ReceiveMessageDownloadParams) {
    let smilStr: string = '';
    try {
      if (!StringUtil.isEmpty(smilePath)) {
        smilStr = fs.readTextSync(smilePath);
      }
    } catch (err) {
      HiLog.e(TAG, `getSmilFileContent err.code: ${err?.code}, err.msg:${err?.message}`);
    }
    param.SMIL_CONTENT = smilStr;
  }

  public static async saveContentToText(data: mmsInfo, decodeMMs: LooseObject, param: ReceiveMessageDownloadParams,
    context: Context) {
    HiLog.i(TAG, 'isSmilFormatCorrect start');
    let content: string = decodeMMs.msgContent;
    if (content && content.length > 0) {
      let valueBucket: ValuesBucket = {
        'msg_id': data.id,
        'group_id': data.groupId,
        'part_index': decodeMMs.fileList.length,
        'part_size': 0,
        'recording_time': '',
        'type': -1,
        'location_path': '',
        'encode': 0,
        'state': 0,
        // 资源文件附件引用计数-初始为1，其他模块复用（如收藏）引用计数 +1 （历史数据默认为-1）
        'reference_count': commonData.referenceCount.ONE,
        'content': content,
        'ct': ''
      };
      valueBucket.type = common.MM_ATTACHMENT_TYPE.TEXT;
      let result = FileUtil.writeTextToSandBox(context, content, false);
      valueBucket.location_path = result.path;
      let size = FileUtil.getFileSizeByPath(result.path);
      valueBucket.part_size = size;
      if (decodeMMs.msgContent === context?.resourceManager.getStringSync($r('app.string.mms_empty_content'))) {
        valueBucket.ct = PART_CT;
      }
      await mmsReceive.insertMmsPart(valueBucket, context);
      // 彩信下载点位信息记录
      param.MMS_SIZE += size;
      param.CONTENT_TYPE = StringUtil.isEmpty(param.CONTENT_TYPE) ? '' : (param.CONTENT_TYPE + ',') + valueBucket.type;
    }
  }

  public static checkHasAttachment(fileList: fileData[]): boolean {
    let attachment: boolean = false;
    for (let index = 0; index < fileList.length; index++) {
      if (fileList[index].fileType.includes('image') || fileList[index].fileType.includes('video') ||
      fileList[index].fileType.includes('media') || fileList[index].fileType.includes('audio') || fileList[index].fileType.includes('x-vCard')) {
        attachment = true;
        break;
      }
    }
    return attachment;
  }
}

export { mmsReceive }