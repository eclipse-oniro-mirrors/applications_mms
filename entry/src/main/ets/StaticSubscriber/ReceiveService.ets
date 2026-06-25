/**
 * Copyright (c) 2024-2024 Huawei Device Co., Ltd.
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
import commonEvent from '@ohos.commonEventManager';
import telSim from '@ohos.telephony.sms';
import myCommon from '@ohos.app.ability.common';
import common from '../data/commonData';
import TelephoneUtil from '../utils/TelephoneUtil';
import commonService from '../service/CommonService';
import ConversationService from '../service/ConversationService';
import ConversationRcsService from '../service/ConversationRcsService';
import NotificationService, { ISetBadgeContextInfo } from '../service/NotificationService';
import LooseObject from '../data/LooseObject';
import ConversationListService from '../service/ConversationListService';
import ContactService from '../service/ContactsService';
import SharedPreferencesUtils from '../utils/SharedPreferencesUtils';
import { BusinessError } from '@ohos.base';
import { AbilityResult, Contact, DataParameters, MessageDetail, Response, sessionResult,
  SessionContentTypeOfRcs, RcsSendLoc, AddressInfo, LocationType,
  ContactType,
  StructText} from '../utils/TypesUtils';
// import rcs from '@ohos.telephony.rcs';
import commonData from '../data/commonData';
import oobeResult from '../oobe/oobeResult';
import mmsUtilCtr from '../utils/MmsUtil';
import statvfs from '@ohos.file.statvfs';
import util from '@ohos.util';
import ContactsService from '../service/ContactsService';
import { SessionContactInfoForDB } from '../pages/conversation/conversationController';
import DotUtil from '../utils/MmsDot/DotUtils';
import dotCommon, {
  dotNoNeedParmas,
  receiveParams,
} from '../utils/MmsDot/DotCommon';
import BlockedUtil from '../utils/BlockedUtil';
import { JSON } from '@kit.ArkTS';
import HiLog from '../utils/HiLog';
import Constant from '../data/Constant';
import { Want } from '@kit.AbilityKit';
import { Context } from '@ohos.abilityAccessCtrl';
import { GlobalContext } from '../MainAbility/GlobalHelper';
import { emitter, screenLock, StaticSubscriberExtensionContext, systemDateTime } from '@kit.BasicServicesKit';
import { SmartMmsServiceRpcService } from '../ServiceExtension/smartRpc/SmartMmsServiceRpcService';
import { dataShare, dataSharePredicates, ValuesBucket, DataShareResultSet } from '@kit.ArkData';
import DataShareHelper from '../model/repository/DataShareHelper';
import fs from '@ohos.file.fs';
import FileUtil from '../utils/FileUtil';
import ConversationRcsModel from '../model/ConversationRcsModel';
import ResourceUtils from '../utils/ResourceUtils';
import StringUtil from '../utils/StringUtil';
import YellowPageService from '../service/yellowPageService';
import backgroundTaskManager from '@ohos.resourceschedule.backgroundTaskManager';
import { mmsReceive } from '../views/MmsReceive/mmsReceiveMain';
import systemParameter from '@ohos.systemparameter';
import { AudioPlayerService } from '../service/AudioPlayerService';
//import { staticMap } from '@kit.MapKit';
import { VCardConstants, VCardParser } from '../utils/VCardParser';
import { UnLockedNotifyService } from '../utils/UnLockedNotifyService';
import {
  BotMessage,
  ChatbotCardMessageType,
  ChatbotParameters
} from '../chatbot/utils/ChatbotEntitys';
import lazy { getTime } from '../utils/SystemDateTimeUtil';
import DeviceUtil from '../utils/DeviceUtil';
import MmsUtil from '../utils/MmsUtil';
import cardModel from '../model/CardModel'
import { MarkInfoContactModel } from '../model/ComInfoModel';

type pduCallback = (data: LooseObject) => void;

const inRepairModeData: MessageDetail[] = [];
const numberTwo: number = 2;

export interface RcsMessage {
  msgId: string;
  slotId: Number;
  address: string;
  date: string;
  content: string;
  extraData?: object;
}

interface ParamsOfAddData {
  dstFileName: string,
  data: DataParameters,
  rcsMessageValue: RcsMessage,
  msgType: number,
  fileSize: string,
  remainingSpace: number,
  context: Context,
  chatbotParameters: ChatbotParameters | undefined
  videoThumbnailName?: string
}

interface ParamsSendNotification {
  telephone: string;
  msgId: number;
  content: string;
  context: Context;
  smsType: number;
  isFlashMms: boolean;
  type?: string;
  slotId?: number;
  verCode?: string;
  chatbotParameters?: ChatbotParameters | undefined;
  deliveryTime: number;
  isFirstUnlocked: boolean;
  startTime: string;
  smsReceiveIdForDot?: number;
  isMms?: boolean;
  rcsType?: number;
  isMute?: number;
  serviceCenter?: string;
  protocol?: number;
  blockedType?: number;
  blockedReason?: number;
}

interface ParamsSendSmsNotification {
  telephone: string,
  msgId: number,
  content: string,
  context: Context,
  smsType: number,
  isFlashMms: boolean,
  callback: Function,
  type?: string,
  slotId?: number,
  verCode?: string,
  chatbotParameters?: ChatbotParameters | undefined,
  deliveryTime: number,
  isFirstUnlocked: boolean,
  startTime: string,
  smsReceiveIdForDot?: number,
  rcsType: number,
  isMute?: number,
  serviceCenter?: string,
  protocol?: number,
  blockedType?: number,
  blockedReason?: number,
}

const TAG: string = 'ReceiveService';

export default class ReceiveService {
  private static sInstance: ReceiveService;

  // 申请的能效资源数量
  public releaseResourceNumber: number = 0;
  // 坚盾守护模式
  private isAdvancedMode: boolean = SharedPreferencesUtils.getFromPreferences('isAdvancedMode', false) as boolean;

  static getInstance() {
    if (ReceiveService.sInstance == null) {
      ReceiveService.sInstance = new ReceiveService();
    }
    return ReceiveService.sInstance;
  }

  public async sendRcsRecvBroadcast(data: DataParameters, context: Context): Promise<void> {
    HiLog.i(TAG, 'sendRcsRecvBroadcast: event: ' + data.data);
    if (data.data === commonData.RCS_RECEIVE_TYPE.RCS_RECEIVE_FILE_MESSAGE) {
      this.handleRcsReceiveFile(data, context);
    } else if (data.data === commonData.RCS_RECEIVE_TYPE.RCS_RECEIVE_FILE_SUCCESS) {
      let isIntercept = await this.interceptLaterReceiveBroadcastOnCanceledMessage(context, data.parameters.msgId);
      if (isIntercept === false) {
        if (data.parameters.fileType === 'video/mp4') {
          this.handleRcsReceiveFileAfterClick(data, context, () => {
            ConversationRcsService.getInstance().updateRcsInfoByMsgId(data.parameters.msgId, context, {
              'msg_state': commonData.int.SEND_MESSAGE_SUCCESS
            });
            this.publishRcsReceiveOKEvent(data.parameters.msgId);
          });
        } else {
          this.handleRcsReceiveFileAfterClick(data, context);
          ConversationRcsService.getInstance().updateRcsInfoByMsgId(data.parameters.msgId, context, {
            'msg_state': commonData.int.SEND_MESSAGE_SUCCESS
          });
          this.publishRcsReceiveOKEvent(data.parameters.msgId);
        }
      }
    } else if (data.data === 'RCS_RECEIVE_FILE_CANCEL') {
      ConversationRcsService.getInstance().updateRcsInfoByMsgId(data.parameters.msgId, context, {
        'msg_state': commonData.int.RCS_RECEIVING_CANCEL
      });
      this.publishRcsReceiveCancelEvent(data.parameters.msgId, true);
    } else if (data.data === commonData.RCS_RECEIVE_TYPE.RCS_RECEIVE_FILE_PROGRESS) {
      if (data.parameters.msgId) {
          let isIntercept = await this.interceptLaterReceiveBroadcastOnCanceledMessage(context, data.parameters.msgId);
          if (isIntercept === false) {
              ConversationRcsService.getInstance()
                  .updateRcsInfoByMsgIdOfProgressBroadcast(data.parameters.msgId,
                      context, data.parameters.clurSize, data.parameters.totalSize);
              ConversationRcsService.getInstance().updateRcsInfoByMsgId(data.parameters.msgId, context, {
                  'msg_state': commonData.int.RCS_RECEIVING
              });
              this.publishRcsProcessEvent(data.parameters.msgId, data.parameters.clurSize, true,
                  data.parameters.totalSize, 'receive');
          }
      } else {
        HiLog.e(TAG, 'msgId null');
      }
    } else if (data.data === commonData.RCS_RECEIVE_TYPE.RCS_RECEIVE_FILE_FAILED) {
        let isIntercept = await this.interceptLaterReceiveBroadcastOnCanceledMessage(context, data.parameters.msgId);
        if (isIntercept === false) {
            ConversationRcsService.getInstance().updateRcsInfoByMsgId(data.parameters.msgId, context, {
                'msg_state': commonData.int.SEND_MESSAGE_FAILED
            });
            this.publishRcsFailEvent(data.parameters.msgId)
        }
    }
  }

  extractFileName(filePath: string): string {
    const lastIndex = filePath.lastIndexOf('/');
    if (lastIndex !== -1) {
      return filePath.slice(lastIndex + 1);
    } else {
      return filePath;
    }
  }

  existThenRenameFile(filePath: string, fileName: string): string {
    let newFilePath: string = filePath + fileName;
    const lastIndexOfDot = fileName.lastIndexOf('.');
    if (lastIndexOfDot === -1) {
      return newFilePath;
    }
    const baseName = fileName.substring(0, lastIndexOfDot);
    const extension = fileName.substring(lastIndexOfDot);
    let cnt = 0;
    do {
      try {
        newFilePath = filePath + fileName;
        let ret = fs.accessSync(newFilePath);
        if (ret) {
          fileName = `${baseName}(${cnt})${extension}`;
          cnt++;
        } else {
          break;
        }
      } catch (error) {
        return newFilePath;
      }
    } while (true);

    newFilePath = filePath + fileName;
    return newFilePath;
  }

  public async handleRcsReceiveFile(data: DataParameters, context: Context,
    chatbotParameters?: ChatbotParameters, callback?: () => void): Promise<void> {
    HiLog.iw(TAG, `handleRcsReceive start! fileType:${data?.parameters?.fileType}`);
    let path = context.filesDir;
    let remainingSpace: number = 0;
    let fileName: string = FileUtil.formatFileName(data.parameters.fileName);
    try {
      let msgType: number = 0;
      let dstFileName: string = this.existThenRenameFile(path + '/', fileName);
      let fileSize: string = '';
      let tempFilterFileType =
        ['audio/amr', 'text/vcard', 'image/jpeg', 'image/png', 'image/gif', 'image/bmp', 'video/mp4', 'image/jpg'];
      if (tempFilterFileType.indexOf(data.parameters.fileType) === -1) {
        HiLog.w(TAG, 'handleRcsReceive: tempFilterFileType has not data.parameters.fileType');
        msgType = this.setRcsReceiveFileType(data);
        HiLog.w(TAG, 'handleRcsReceive: start msgType!' + msgType);
        if (!msgType) {
          this.rejectRcsReceiveFileOnclick(data.parameters.msgId, dstFileName, data.parameters.fileType);
          return;
        }
        fileSize = this.setRcsReceiveFileSize(data.parameters.totalSize);
      } else if (data.parameters.fileType === 'image/jpeg' || data.parameters.fileType === 'image/png' ||
        data.parameters.fileType === 'image/gif' || data.parameters.fileType === 'image/bmp' ||
        data.parameters.fileType === 'image/jpg') {
        HiLog.iw(TAG, 'handleRcsReceive: analysis File is Image');
        msgType = commonData.ENHANCED_INFO_ITEM_TYPE.IMAGE;
      } else if (data.parameters.fileType === 'video/mp4') {
        HiLog.iw(TAG, 'handleRcsReceive: analysis File is Video');
        msgType = commonData.ENHANCED_INFO_ITEM_TYPE.VIDEO;
      }
      if (msgType === commonData.ENHANCED_INFO_ITEM_TYPE.IMAGE || msgType === commonData.ENHANCED_INFO_ITEM_TYPE.FILE ||
        msgType === commonData.ENHANCED_INFO_ITEM_TYPE.AUDIO_FILE ||
        msgType === commonData.ENHANCED_INFO_ITEM_TYPE.VIDEO) {
        HiLog.iw(TAG, 'handleRcsReceive: handle IMAGE or FILE or AUDIO_FILE or VIDEO');
        remainingSpace = await statvfs.getFreeSize(path) / common.int.BYTE_CONVERSION_UNIT;
        let srcFileNAme: string = data.parameters.filePath;
        // let temp: rcs.RcsFileOptions = { msgId: data.parameters.msgId, dstFileName: dstFileName,
        //   srcFileName: srcFileNAme, fileType: data.parameters.fileType, extraParam: Object({}) };

        let videoThumbnailName = '';
        // if (msgType === commonData.ENHANCED_INFO_ITEM_TYPE.VIDEO) {
        //   videoThumbnailName = `${path}/VIDEO_${getTime(true) ?? Date.now()}.mp4`;
        //   temp.dstFileName = videoThumbnailName;
        // }
        if (chatbotParameters) {
          chatbotParameters.msgType = msgType;
        }
        // rcs.createFileMessage(temp).then(async (rcsMessageValue: RcsMessage) => {
        //   this.addData({
        //     dstFileName: dstFileName,
        //     data: data,
        //     rcsMessageValue: rcsMessageValue,
        //     msgType: msgType,
        //     fileSize: fileSize,
        //     remainingSpace: remainingSpace,
        //     context: context,
        //     chatbotParameters: chatbotParameters,
        //     videoThumbnailName: videoThumbnailName
        //   });
        // })
      } else {
        HiLog.iw(TAG, 'handleRcsReceive: handle File types other than (IMAGE or FILE or AUDIO_FILE)');
        this.handleRcsReceiveFileOnclick(data.parameters.msgId, dstFileName, data.parameters.fileType);
      }
    } catch (error) {
      HiLog.e(TAG, 'handleRcsReceive error: ' + JSON.stringify(error));
      if (callback) {
        callback();
      }
    }
  }

  setRcsReceiveFileType(data: DataParameters) {
    let fileExtension = data?.parameters?.fileName?.substring(data.parameters.fileName.lastIndexOf('.') +
      1).toLowerCase();
    HiLog.i(TAG, `handleRcsReceive setRcsReceiveFileType fileExtension: ${fileExtension}`);
    let msgType: number = 0
    if (data.parameters.fileType === 'audio/mpeg' || data.parameters.fileType === 'audio/mp4' ||
      (data.parameters.fileType === 'application/octet-stream' && fileExtension === 'aac')) {
      msgType = commonData.ENHANCED_INFO_ITEM_TYPE.AUDIO_FILE;
    } else if (data.parameters.fileType === 'text/plain' || data.parameters.fileType === 'application/txt' ||
      (data.parameters.fileType === 'application/octet-stream' && fileExtension === 'txt')) {
      msgType = commonData.ENHANCED_INFO_ITEM_TYPE.FILE;
    } else if (data.parameters.fileType === 'application/octet-stream' && fileExtension === 'vcf') {
      msgType = commonData.ENHANCED_INFO_ITEM_TYPE.VCARD;
    } else if (data.parameters.fileType === 'application/octet-stream' && ['heic', 'heif'].includes(fileExtension)) {
      msgType = commonData.ENHANCED_INFO_ITEM_TYPE.IMAGE;
    }
    return msgType;
  }

  setRcsReceiveFileSize(totalSize: number) {
    let fileSize: string = '';
    if (totalSize < commonData.int.RCS_FILE_SIZE) {
      fileSize = totalSize.toString() + 'B';
    } else if (totalSize > commonData.int.RCS_FILE_SIZE && totalSize < commonData.int.RCS_FILE_MAX_SIZE) {
      fileSize = (totalSize / commonData.int.RCS_FILE_SIZE).toFixed(2) + 'KB';
    } else {
      fileSize = (totalSize / commonData.int.RCS_FILE_MAX_SIZE).toFixed(2) + 'MB';
    }
    return fileSize;
  }

  public async rejectRcsReceiveFileOnclick(msgId: string, path: string, fileType: string): Promise<void> {
    HiLog.i(TAG, 'rejectRcsReceiveFileOnclick  receive file is not supported: ' + fileType);
    // let temp: rcs.RcsFileOptions = {
    //   msgId: msgId,
    //   dstFileName: path,
    //   srcFileName: '',
    //   fileType: fileType,
    //   extraParam: Object({}),
    // };
    // rcs.rejectFile(temp)
  }

  public judgeGeneralOrChatbot(msgType: number, actionData: MessageDetail, context: Context) {
    if (msgType === commonData.ENHANCED_INFO_ITEM_TYPE.IMAGE) {
      actionData.rcsMsgContent = ResourceUtils.getStringSync($r('app.string.attachment_send_picture'), context);
    } else if (msgType === commonData.ENHANCED_INFO_ITEM_TYPE.FILE) {
      actionData.rcsMsgContent = ResourceUtils.getStringSync($r('app.string.attachment_send_file'), context);
    } else if (msgType === commonData.ENHANCED_INFO_ITEM_TYPE.AUDIO_FILE) {
      actionData.rcsMsgContent = ResourceUtils.getStringSync($r('app.string.attachment_send_audio'), context);
    } else if (msgType === commonData.ENHANCED_INFO_ITEM_TYPE.VIDEO) {
      actionData.rcsMsgContent = ResourceUtils.getStringSync($r('app.string.attachment_send_video'), context);
    }
  }

  public addData(param: ParamsOfAddData) {
    HiLog.iw(TAG, 'addData');
    const dstFileName = param.dstFileName;
    const data = param.data;
    const rcsMessageValue = param.rcsMessageValue;
    const msgType = param.msgType;
    const fileSize = param.fileSize;
    const remainingSpace = param.remainingSpace;
    const context = param.context as myCommon.ServiceExtensionContext;
    const chatbotParameters = param.chatbotParameters;
    const videoThumbnailName = param.videoThumbnailName;

    let path1 = dstFileName;
    let isSecurityMode = mmsUtilCtr.checkAdvancedMode();
    let actionData: MessageDetail = new MessageDetail();
    actionData.deliveryTime = data.deliveryTime;
    actionData.isFirstUnlocked = data.isFirstUnlocked;
    actionData.msgId = data.parameters.msgId;
    actionData.slotId = rcsMessageValue.slotId as number;
    actionData.telephone = rcsMessageValue.address;
    actionData.content = dstFileName;
    actionData.starttime = rcsMessageValue.date;
    actionData.isMms = true;
    actionData.isFlashMms = data.parameters.isFlashMessage;
    if (chatbotParameters?.isChatbotMessage && chatbotParameters.mmsSource) {
      actionData.mmsSource = chatbotParameters.mmsSource;
    } else if (msgType === commonData.ENHANCED_INFO_ITEM_TYPE.VIDEO) {
      actionData.mmsSource = [
        {
          size: data.parameters.totalSize,
          type: commonData.ENHANCED_INFO_ITEM_TYPE.VIDEO,
          name: '',
          path: dstFileName,
          msgType: msgType,
        },
        {
          size: '',
          type: commonData.ENHANCED_INFO_ITEM_TYPE.VIDEO_THUMBNAIL,
          name: '',
          path: videoThumbnailName,
          msgType: msgType,
        }
      ];
    } else {
      actionData.mmsSource = [{
        size: (msgType != commonData.ENHANCED_INFO_ITEM_TYPE.IMAGE) ? fileSize : data.parameters.totalSize,
        type: msgType,
        name: '',
        path: path1,
        msgType: msgType,
      }];
    }
    actionData.rcsType = msgType;
    actionData.msgType = common.int.RCS_FIRST_RECEIVING;
    actionData.clurSize = data.parameters.clurSize;
    actionData.totalSize = data.parameters.totalSize;
    actionData.type = commonData.RCS_TYPE.RCS;
    actionData.isAdvancedSecurity = isSecurityMode ? 1 : 0;
    if (remainingSpace < common.int.MMS_ATTACHMENT_UPPER_LIMIT) {
      actionData.failReceiveContext = actionData.content;
      actionData.receiveState = common.int.SEND_MESSAGE_FAILED;
      this.publishAcceptFailureEvent(actionData);
      let encoder = new util.TextEncoder('utf-8');
      let bytes = encoder.encode(actionData.content);
      let messageSize = Math.ceil(bytes.length / common.int.BYTE_CONVERSION_UNIT);
      let receivedResource: Resource = $r('app.string.informationSize', JSON.stringify(messageSize));
      let receivedMsgSize: string = context.resourceManager.getStringSync(receivedResource,
        JSON.stringify(messageSize));
      actionData.content = receivedMsgSize;
    }

    if (chatbotParameters?.isChatbotMessage && chatbotParameters.isNotifyUserMessage) {
      if (msgType === commonData.ENHANCED_INFO_ITEM_TYPE.CHATBOT_CARD) {
        if (chatbotParameters.cardType === ChatbotCardMessageType.SINGLE_CARD &&
          chatbotParameters.cardContent?.message?.generalPurposeCard?.content?.title) {
          actionData.rcsMsgContent = chatbotParameters.cardContent.message.generalPurposeCard.content.title;
        } else if (chatbotParameters.cardType === ChatbotCardMessageType.MULTI_CARD &&
          chatbotParameters.cardContent?.message?.generalPurposeCardCarousel?.content?.[0]?.title) {
          actionData.rcsMsgContent = chatbotParameters.cardContent.message.generalPurposeCardCarousel.content[0].title;
        } else {
          actionData.rcsMsgContent = ResourceUtils.getStringSync($r('app.string.chatbot_rich_media_card_in_conversation_list'), context);
        }
      } else {
        //chatbot的处理
        this.judgeGeneralOrChatbot(msgType, actionData, context)
      }
    } else {
      //普通处理
      this.judgeGeneralOrChatbot(msgType, actionData, context)
    }
    actionData.chatbotParameters = chatbotParameters;
  }

  public async handleRcsReceiveFileAfterClick(data: DataParameters, context: Context,
    videoCallback?: () => void): Promise<void> {
    HiLog.iw(TAG, 'handleRcsReceiveFileAfterClick start!');
    let fileExtension = data?.parameters?.fileName?.substring(data.parameters.fileName.lastIndexOf('.') +
      1).toLowerCase();
    let path = context.filesDir;
    let remainingSpace: number = 0;
    try {
      remainingSpace = await statvfs.getFreeSize(path) / common.int.BYTE_CONVERSION_UNIT;
      let msgType: number = 0;
      let dstFileName: string = path + '/' + this.extractFileName(data.parameters.filePath);
      let tempFilterFileType = ['image/jpeg', 'image/png', 'image/gif', 'image/bmp', 'image/jpg'];
      if (data.parameters.fileType === 'audio/amr') {
        msgType = commonData.ENHANCED_INFO_ITEM_TYPE.AUDIO;
      } else if (data.parameters.fileType === 'text/vcard' ||
        (data.parameters.fileType === 'application/octet-stream' && fileExtension === 'vcf')) {
        msgType = commonData.ENHANCED_INFO_ITEM_TYPE.VCARD;
      } else if (tempFilterFileType.indexOf(data.parameters.fileType) !== -1) {
        msgType = commonData.ENHANCED_INFO_ITEM_TYPE.IMAGE;
      } else if (data.parameters.fileType === 'video/mp4') {
        msgType = commonData.ENHANCED_INFO_ITEM_TYPE.VIDEO;
      } else if (data.parameters.fileType === 'application/octet-stream' &&
        (['heic', 'heif'].includes(fileExtension))) {
        msgType = commonData.ENHANCED_INFO_ITEM_TYPE.IMAGE;
      }
      HiLog.w(TAG, 'handleRcsReceiveFileAfterClick end! msgType:' + msgType);
      let srcFileNAme: string = data.parameters.filePath;
      // let temp: rcs.RcsFileOptions = {
      //   msgId: data.parameters.msgId,
      //   dstFileName: dstFileName,
      //   srcFileName: srcFileNAme,
      //   fileType: data.parameters.fileType,
      //   extraParam: Object({}),
      // };
      // rcs.createFileMessage(temp).then(async (rcsMessageValue: RcsMessage) => {
      //   if (msgType === commonData.ENHANCED_INFO_ITEM_TYPE.VIDEO) {
      //     videoCallback?.();
      //     return;
      //   }
      //   this.addDataAfterClick(dstFileName, data, rcsMessageValue, msgType, srcFileNAme, remainingSpace, context);
      // })
    } catch (error) {
      HiLog.e(TAG, 'handleRcsReceive error: ' + JSON.stringify(error));
    }
  }

  public async addDataAfterClickPart(dstFileName: string, srcFileNAme: string, context: Context) {
    let locationPath: string = context.filesDir + '/' + this.extractFileName(srcFileNAme);
    let dataHelper: dataShare.DataShareHelper | undefined = await DataShareHelper.getInstance().initSmsDB(context);
    if (!dataHelper) {
      HiLog.e(TAG, `handleRcsReceiveFileAfterClick createDataShareHelper fail`);
      return;
    }
    this.updateRcsReceivedMmsInfoByConditionHandleCreate(locationPath, dataHelper, {
      'location_path': dstFileName
    });
  }

  getDuration(second: number) {
    if (isNaN(second)) {
      return '00:00'
    }
    let minute: number = 0;
    if (second >= 60) {
      minute = Math.floor(second / 60)
      second = second - minute * 60
    }
    return ((minute >= 10) ? minute : ('0' + minute)) + ':' +
      ((second >= 10) ? second : ('0' + second));
  }

  public async addDataAfterClickNext(dstFileName: string, data: DataParameters, rcsMessageValue: RcsMessage,
    msgType: number, srcFileNAme: string, remainingSpace: number, context: Context) {
    HiLog.iw(TAG, 'addDataAfterClickNext');
    let audioTime: string = '';
    if (msgType === commonData.ENHANCED_INFO_ITEM_TYPE.AUDIO) {
      if (parseInt(data.parameters.duration) as number > 0) {
        audioTime = data.parameters.duration;
      } else {
        audioTime = await AudioPlayerService.getInstance().getAudioDuration(dstFileName);
      }
      let audioDuration = parseInt(audioTime) / common.int.MESSAGE_CODE_THOUSAND;
      audioDuration = Math.floor(audioDuration);
      audioTime = this.getDuration(audioDuration)
    }
    let isSecurityMode = mmsUtilCtr.checkAdvancedMode();
    let actionData: MessageDetail = new MessageDetail;
    actionData.deliveryTime = data.deliveryTime;
    actionData.isFirstUnlocked = data.isFirstUnlocked;
    actionData.msgId = data.parameters.msgId;
    actionData.slotId = rcsMessageValue.slotId as number;
    actionData.telephone = rcsMessageValue.address;
    actionData.starttime = rcsMessageValue.date;
    actionData.isMms = true;
    actionData.isFlashMms = data.parameters.isFlashMessage;
    actionData.mmsSource = [{ duration: audioTime, size: data.parameters.totalSize, type: msgType,
      name: '', path: dstFileName, msgType: msgType }];
    actionData.rcsType = msgType;
    actionData.msgType = common.int.SEND_MESSAGE_SUCCESS;
    actionData.clurSize = data.parameters.clurSize;
    actionData.totalSize = data.parameters.totalSize;
    actionData.type = commonData.RCS_TYPE.RCS;
    actionData.isAdvancedSecurity = isSecurityMode ? 1 : 0;
    if (remainingSpace < common.int.MMS_ATTACHMENT_UPPER_LIMIT) {
      actionData.failReceiveContext = actionData.content;
      actionData.receiveState = common.int.SEND_MESSAGE_FAILED;
      this.publishAcceptFailureEvent(actionData);
      let encoder = new util.TextEncoder('utf-8');
      let bytes = encoder.encode(actionData.content);
      let messageSize = Math.ceil(bytes.length / common.int.BYTE_CONVERSION_UNIT);
      let receivedResource: Resource = $r('app.string.informationSize', JSON.stringify(messageSize));
      let receivedMsgSize: string = context.resourceManager.getStringSync(receivedResource,
        JSON.stringify(messageSize));
      actionData.content = receivedMsgSize;
    }
    let sessionContent: SessionContentTypeOfRcs | null = null;
    if (msgType === commonData.ENHANCED_INFO_ITEM_TYPE.AUDIO) {
      actionData.rcsMsgContent = ResourceUtils.getStringSync($r('app.string.attachment_send_audio'), context);
    } else if (msgType === commonData.ENHANCED_INFO_ITEM_TYPE.VCARD) {
      sessionContent = {
        isSendMessage: 0,
        contactNum: 0,
        contactName: '',
      };
      await this.writeContactToVcfFile(context, dstFileName, sessionContent);
      actionData.rcsMsgContent = ResourceUtils.getStringSync($r('app.string.attachment_send_vcard'), context);
    }
  }

  public async writeContactToVcfFile(context: Context, dstFileName: string,
    sessionContent: SessionContentTypeOfRcs | null) {
    HiLog.i(TAG, 'writeContactToVcfFile enter');
    let contacts: ContactType[] = [];
    let vcardText: string = '';
    try {
      vcardText = fs.readTextSync(dstFileName);
      contacts = await VCardParser.getInstance().parseVcardStr(context, vcardText, 1);
    } catch (e) {
      HiLog.i(TAG, 'writeContactToVcfFile parseVcard err:' + e);
    }
    let data = this.getVcardContactInfo(vcardText, contacts);
    if (data === '') {
      HiLog.i(TAG, 'writeContactToVcfFile data is Empty');
      return;
    }
    let contactIndexSet = new Set(contacts.map(v => v.index));
    if (contactIndexSet.size === 1) {
      let oppositeContactName: string = contacts[0].contactName || contacts[0].telephone || '';
      if (oppositeContactName) {
        oppositeContactName = oppositeContactName.replace(new RegExp('\\s*', 'g'), '');
        oppositeContactName = TelephoneUtil.formatDisplayPhoneNum(oppositeContactName);
      }
      if (sessionContent) {
        sessionContent.contactNum = 1;
        sessionContent.contactName = oppositeContactName;
      }
    } else {
      if (sessionContent) {
        sessionContent.contactNum = contactIndexSet.size;
      }
    }

    let fd: number = -1;
    try {
      fd = fs.openSync(dstFileName, fs.OpenMode.READ_WRITE).fd;
      fs.writeSync(fd, data);
    } catch (e) {
      HiLog.i(TAG, 'writeContactToVcfFile err:' + e);
    } finally {
      if (fd != -1) {
        fs.closeSync(fd);
      }
    }
  }

  private getVcardContactInfo(vcardText: string, contacts: ContactType[]): string {
    try {
      let contactsArr = vcardText.split(VCardConstants.PARAM_END_VCARD);
      HiLog.i(TAG, `getVcardContactInfo contacts length:` + contacts.length);
      let vcfInfo: string[] = [];
      for (let index = 0; index < contactsArr.length - 1; index++) {
        if (!contactsArr[index].includes('VERSION:2.1') && contactsArr[index].indexOf(VCardConstants.PARAM_PHOTO) != -1) {
          let base64Arr = contactsArr[index].split(VCardConstants.PARAM_PHOTO);
          let base64 = base64Arr[base64Arr.length - 1].replace(/\n[\t ]/g, '');
          if (base64Arr.length >= 1) {
            contactsArr[index] = base64Arr[0] + VCardConstants.PARAM_PHOTO + base64;
          }
        }
        let arr: string[] = [];
        if (contactsArr[index].indexOf('\r\n') != -1) {
          arr = contactsArr[index].split('\r\n');
        } else if (contactsArr[index].indexOf('\n') != -1) {
          arr = contactsArr[index].split('\n');
        }
        vcfInfo.push(VCardConstants.PARAM_BEGIN_VCARD);
        for (let i = 1; i < arr.length - 1; i++) {
          if (arr[i].startsWith('PATH;') && (arr[i + 1].startsWith(VCardConstants.PARAM_PHOTO) ||
            arr[i + 1].startsWith('END:'))) {
            let contactAvatarPath = arr[i].split(':');
            if (contactAvatarPath.length >= 1) {
              let path = contactAvatarPath[0] + ':' + contacts[index].photoPath ?? '';
              arr[i] = path;
            }
          } else if (!arr[i - 1].startsWith(VCardConstants.PARAM_PATH) &&
            arr[i].startsWith(VCardConstants.PARAM_PHOTO)) {
            let path = 'PATH;CHARSET=UTF-8;ENCODING=QUOTED-PRINTABLE:' + contacts[index].photoPath ?? '';
            let photoBase = arr[i];
            vcfInfo.push(path);
            vcfInfo.push(photoBase);
            break;
          }
          vcfInfo.push(arr[i]);
        }
        vcfInfo.push(VCardConstants.PARAM_END_VCARD);
      }
      let data = vcfInfo.join('\r\n');
      return data;
    } catch (e) {
      HiLog.i(TAG, 'getVcardContactInfo err:' + e);
      return '';
    }
  }

  public async addDataAfterClick(dstFileName: string, data: DataParameters, rcsMessageValue: RcsMessage,
    msgType: number, srcFileNAme: string, remainingSpace: number, context: Context) {
    if (msgType === common.ENHANCED_INFO_ITEM_TYPE.IMAGE) {
      this.addDataAfterClickPart(dstFileName, srcFileNAme, context);
    } else if (msgType > commonData.ENHANCED_INFO_ITEM_TYPE.IMAGE) {
      this.addDataAfterClickNext(dstFileName, data, rcsMessageValue, msgType, srcFileNAme, remainingSpace, context);
    }
  }

  public updateRcsReceivedMmsInfoByConditionHandleCreate(locationPath: string, dataHelper: dataShare.DataShareHelper,
    valueBucket: ValuesBucket) {
    let managerUri: string = common.STR.URI_MESSAGE_LOG + common.STR.URI_MESSAGE_MMS_PART;
    let condition = new dataSharePredicates.DataSharePredicates();
    condition.equalTo('location_path', locationPath);
    HiLog.i(TAG, 'updateRcsReceivedMmsInfoByCondition')
    dataHelper?.update(managerUri, condition, valueBucket).then().catch((error: BusinessError) => {
      HiLog.e(TAG, 'updateSmsMmsInfoByCondition fail, error: ' + JSON.stringify(error));
    });
    return;
  }

  public async handleRcsReceiveFileOnclick(msgId: string, path: string, fileType: string): Promise<void> {
    HiLog.i(TAG, `handleRcsReceiveFileOnclick rcs.acceptFile`);
    // let temp: rcs.RcsFileOptions = {
    //   msgId: msgId,
    //   dstFileName: path,
    //   srcFileName: '',
    //   fileType: fileType,
    //   extraParam: Object({}),
    // };
    // try {
    //   rcs.acceptFile(temp)
    // } catch (e) {
    //   HiLog.e(TAG, 'handleRcsReceiveFileOnclick error: ' + JSON.stringify(e));
    // }
  }

  private publishRcsReceiveOKEvent(msgId: string) {
    HiLog.i(TAG, 'publishRcsReceiveOKEvent, start');
    try {
      commonEvent.publish(common.STR.RCS_RECEIVE_FILE_OK, {
        bundleName: common.STR.BUNDLE_NAME,
        subscriberPermissions: ['ohos.permission.SEND_MESSAGES'],
        isOrdered: false,
        data: msgId,
      }, () => {
      });
    } catch (err) {
      HiLog.e(TAG, `Failed to publishRcsReceiveOKEvent, Code: ${err.code}, message: ${err.message}`);
    }
  }

  private publishRcsReceiveCancelEvent(msgId: string, cancelValue?: boolean) {
    HiLog.i(TAG, 'publishRcsReceiveCancelEvent, start');
    try {
      commonEvent.publish(common.STR.RCS_RECEIVE_FILE_CANCEL, {
        bundleName: common.STR.BUNDLE_NAME,
        subscriberPermissions: ['ohos.permission.SEND_MESSAGES'],
        isOrdered: false,
        data: msgId,
        parameters: { cancelValue: cancelValue },
      }, () => {
      });
    } catch (err) {
      HiLog.i(TAG, `Failed to publish common event. Code is ${err.code}, message is ${err.message}`);
    }
  }

  private publishRcsProcessEvent(msgId: string, clurSize: number, isExistInfoInRcsInfoWithMsgId: boolean,
    totalSize: number, type?: 'send' | 'receive') {
    HiLog.iw(TAG, 'publishRcsProcessEvent, start');
    try {
      commonEvent.publish(common.STR.RCS_SUBSCRIBER_FILE_PROGRESS_EVENT, {
        bundleName: common.STR.BUNDLE_NAME,
        subscriberPermissions: ['ohos.permission.SEND_MESSAGES'],
        isOrdered: false,
        data: msgId,
        parameters: {
          clurSize: clurSize,
          isExistInfoInRcsInfoWithMsgId: isExistInfoInRcsInfoWithMsgId,
          totalSize: totalSize,
          type: (type && type === 'receive') ? 'receive' : 'send'
        }
      }, () => {
      });
    } catch (err) {
      HiLog.i(TAG, `Failed to publish common event. Code is ${err.code}, message is ${err.message}`);
    }
  }

  public async sendAndReceiveRcsBroadcast(data: DataParameters, context: Context): Promise<void> {
    HiLog.i(TAG, 'sendAndReceiveRcsBroadcast');
    if (data.data === commonData.RCS_RECEIVE_TYPE.TEXT_RCS_DELIVERY_RECEIVE) {
      HiLog.iw(TAG, 'onReceiveEvent: RCS info' + 'data: ' + data.data);
      if (data.parameters.msgId) {
        ConversationRcsService.getInstance().queryRcsMmsInfoByMsgId(data.parameters.msgId, context, true);
        this.publishRcsDeliveryEvent(data.parameters.msgId);
        ConversationRcsService.getInstance().querySessionByMsgIdSendOK(data.parameters.msgId, context);
      } else {
        HiLog.e(TAG, 'msgId null');
      }
    }
    if (data.data === commonData.RCS_RECEIVE_TYPE.TEXT_RCS_FAIL_RECEIVE) {
      HiLog.iw(TAG, 'onReceiveEvent: RCS info' + 'data: ' + data.data);
      if (data.parameters.msgId) {
        let isIntercept: boolean =
          await this.interceptLaterSendBroadcastOnCanceledMessage(context, data.parameters.msgId);
        if (isIntercept === false) {
          ConversationRcsService.getInstance()
            .queryRcsMmsInfoByMsgIdSendFail(data.parameters.msgId, context);
          ConversationRcsService.getInstance()
            .querySessionByMsgIdSendFail(data.parameters.msgId, context);
          this.publishRcsFailEvent(data.parameters.msgId);
        }
      } else {
        HiLog.e(TAG, 'msgId null');
      }
    }
    if (data.parameters.isShow && data.parameters.mobilePhoneNumber) {
      try {
        // rcs.sendReadReceipt(data.parameters.mobilePhoneNumber, () => {});
      } catch (exception) {
        HiLog.e(TAG, 'sendAndReceiveRcsBroadcast, no have rcs exception: ' + JSON.stringify(exception));
      }
    }

    const readReportSwitchStatus = SharedPreferencesUtils.getFromPreferences('readFlag', '');
    HiLog.iw(TAG, `sendAndReceiveRcsBroadcast: readReportSwitchStatus ${readReportSwitchStatus}`);
    if (readReportSwitchStatus && data.data === commonData.RCS_RECEIVE_TYPE.TEXT_RCS_READ_RECEIVE) {
      HiLog.iw(TAG, 'onReceiveEvent: RCS info event TEXT_RCS_READ_RECEIVE');
      let isIntercept: boolean =
        await this.interceptLaterSendBroadcastOnCanceledMessage(context, data.parameters.msgId);
      if (isIntercept === false) {
        ConversationRcsService.getInstance().updateRcsInfoMessageToReadState(context, data.parameters.msgId);
        this.publishReadCommonEvent(data.parameters.msgId);
      }
    }
  }

  public dealSmsReceiveData(data: DataParameters, context: Context): void {
    this.handleSmsReceive(data, context)
    this.publishCommonEvent();
  }

  private publishCommonEvent() {
    HiLog.i(TAG, 'publishRefreshEvent, start');
    let publishData: LooseObject = {};
    publishData.needToUpdate = true;
    try {
      commonEvent.publish(common.STR.MMS_SUBSCRIBER_COMMON_EVENT, {
        bundleName: common.STR.BUNDLE_NAME,
        subscriberPermissions: ['ohos.permission.RECEIVE_SMS'],
        isOrdered: false,
        data: JSON.stringify(publishData),
      }, () => {
      });
    } catch (err) {
      HiLog.i(TAG, `Failed to publish common event. Code is ${err.code}, message is ${err.message}`);
    }
  }

  public publishAcceptFailureEvent(actionData: LooseObject) {
    HiLog.i(TAG, 'publishAcceptFailureEvent, start');
    try {
      commonEvent.publish(common.STR.RCS_SUBSCRIBER_FAIL_EVENT, {
        bundleName: common.STR.BUNDLE_NAME,
        subscriberPermissions: ['ohos.permission.RECEIVE_SMS'],
        isOrdered: false,
        data: JSON.stringify(actionData),
        parameters: actionData
      }, () => {
      });
    } catch (err) {
      HiLog.e(TAG, `Failed to publishAcceptFailureEvent, Code: ${err.code}, message: ${err.message}`);
    }
  }

  public publishReadCommonEvent(rcsId: string) {
    HiLog.i(TAG, 'publishReadCommonEvent, start');
    try {
      commonEvent.publish(common.STR.RCS_SUBSCRIBER_COMMON_EVENT, {
        bundleName: common.STR.BUNDLE_NAME,
        subscriberPermissions: ['ohos.permission.RECEIVE_SMS'],
        isOrdered: false,
        data: rcsId,
      }, () => {
      });
    } catch (err) {
      HiLog.i(TAG, `Failed to publish common event. Code is ${err.code}, message is ${err.message}`);
    }
  }

  private publishRcsDeliveryEvent(msgId: string) {
    HiLog.i(TAG, 'publishRcsDeliveryEvent, start');
    try {
      commonEvent.publish(common.STR.RCS_SUBSCRIBER_DELIVERY_EVENT, {
        bundleName: common.STR.BUNDLE_NAME,
        subscriberPermissions: ['ohos.permission.SEND_MESSAGES'],
        isOrdered: false,
        data: msgId,
      }, () => {
      });
    } catch (err) {
      HiLog.i(TAG, `Failed to publish common event. Code is ${err.code}, message is ${err.message}`);
    }
  }

  public async sendRcsSendBroadcast(data: DataParameters, context: Context) {
    if (data.data === commonData.RCS_RECEIVE_TYPE.RCS_FILE_SEND_OK_RECEIVE) {
      this.handleRCSFileSendOK(data, context);
    }
    if (data.data === commonData.RCS_RECEIVE_TYPE.TEXT_RCS_SEND_OK_RECEIVE) {
      this.handleRcsTextSendOKEvent(data, context);
    }
    let reportParams: Record<string, number | number[] | string | boolean> = {
      'slotId': data.parameters.slotId,
      'destinationHost': data.parameters.telephone,
      'msgType': common.ueMsgType.RCS,
      'msgContent': MmsUtil.getMsgContentByRcsType(Number(data.parameters.type)),
      'id': data.parameters.msgId,
    };
    // 发送失败
    if (data.data === commonData.RCS_RECEIVE_TYPE.TEXT_RCS_FAIL_RECEIVE ||
      data.data === commonData.RCS_RECEIVE_TYPE.RCS_FILE_SEND_FAILED_RECEIVE) {
      reportParams.sendResult = common.ueMsgSendType.FAILED;
      reportParams.failReason = data.parameters.failReason as string;
      DotUtil.getInstance().reportSendMessageCommon(reportParams);
    }
    // 发送成功
    if (data.data === commonData.RCS_RECEIVE_TYPE.TEXT_RCS_SEND_OK_RECEIVE ||
      data.data === commonData.RCS_RECEIVE_TYPE.RCS_FILE_SEND_OK_RECEIVE) {
      reportParams.sendResult = common.ueMsgSendType.SUCCESS;
      DotUtil.getInstance().reportSendMessageCommon(reportParams);
    }

    if (data.data === commonData.RCS_RECEIVE_TYPE.RCS_FILE_SEND_FAILED_RECEIVE) {
      if (data.parameters.msgId) {
              let isIntercept: boolean =
          await this.interceptLaterSendBroadcastOnCanceledMessage(context, data.parameters.msgId);
        if (isIntercept === false) {
        ConversationRcsService.getInstance()
          .queryRcsMmsInfoByMsgIdSendFail(data.parameters.msgId, context);
        ConversationRcsService.getInstance()
          .querySessionByMsgIdSendFail(data.parameters.msgId, context);
        this.publishRcsFailEvent(data.parameters.msgId);
        }
      } else {
        HiLog.e(TAG, 'msgId null');
      }
    }
    if (data?.data === commonData.RCS_RECEIVE_TYPE.FILE_RCS_PROGRESS) {
      HiLog.i(TAG, 'onReceiveEvent: RCS info event FILE_RCS_PROGRESS');
      if (data.parameters?.msgId) {
       let isIntercept: boolean =
          await this.interceptLaterSendBroadcastOnCanceledMessage(context, data.parameters.msgId);
        if (isIntercept === false) {
        ConversationRcsService.getInstance()
          .updateRcsInfoByMsgIdOfProgressBroadcast(data.parameters.msgId, context,
            data.parameters.clurSize, data.parameters.totalSize);
        this.publishRcsProcessEvent(data.parameters.msgId, data.parameters.clurSize,
          true, data.parameters.totalSize);
        }
      } else {
        HiLog.e(TAG, 'data.parameters?.msgId is empty');
      }
    }
    if (data?.data === commonData.RCS_RECEIVE_TYPE.RCS_SEND_FILE_CANCELED) {
      HiLog.iw(TAG, 'onReceiveEvent: RCS info event RCS_SEND_FILE_CANCELED');
      let msgState: number = AppStorage.get('cancelItemDirection_' + data.parameters.msgId) ? common.int.RCS_RECEIVING_CANCEL : common.int.RCS_SEND_CANCELED;
      let cancelValue: boolean | undefined = AppStorage.get('cancelItemDirection_' + data.parameters.msgId);
      if (data.parameters?.msgId) {
        ConversationRcsService.getInstance().updateRcsInfoByMsgId(data.parameters.msgId, context, { 'msg_state': msgState }, cancelValue);
        if (!AppStorage.get('cancelItemDirection_' + data.parameters.msgId)) {
          ConversationRcsService.getInstance().querySessionByMsgIdSendFail(data.parameters.msgId, getContext(this));
          this.publishRcsSendCanceledEvent(data.parameters.msgId);
        } else {
          this.publishRcsReceiveCancelEvent(data.parameters.msgId, cancelValue);
          AppStorage.delete('cancelItemDirection_' + data.parameters.msgId);
        }
      } else {
        HiLog.e(TAG, 'data.parameters?.msgId is empty');
      }
    }
  }

  private async handleRCSFileSendOK(data: DataParameters, context: Context) {
    if (data.parameters.msgId) {
      ConversationRcsService.getInstance().updateRcsInfoByMsgId(data.parameters.msgId, context, {
        'msg_state': commonData.int.RCS_SEND_OK
      });
      ConversationRcsService.getInstance().querySessionByMsgIdSendOK(data.parameters.msgId, context);
      // Rcs 消息发送成功率打点
      DotUtil.getInstance().reportSuccessRateForSendFinished(dotCommon.smsReceiveRecord.SUCCESS_RATE_TYPE_RCS);
      this.publishRcsSendOKEvent(data.parameters.msgId);
    } else {
      HiLog.e(TAG, 'msgId null');
    }
  }

  private async handleRcsTextSendOKEvent(data: DataParameters, context: Context) {
    if (data.parameters.msgId) {
      ConversationRcsService.getInstance().updateRcsInfoByMsgId(data.parameters.msgId, context, {
        'msg_state': commonData.int.RCS_SEND_OK
      });
      this.publishRcsSendOKEvent(data.parameters.msgId);
      // Rcs 消息发送成功率打点
      DotUtil.getInstance().reportSuccessRateForSendFinished(dotCommon.smsReceiveRecord.SUCCESS_RATE_TYPE_RCS);
    } else {
      HiLog.e(TAG, 'handleRcsTextSendOKEvent: msgId null');
    }
  }

  private publishRcsSendOKEvent(msgId: string) {
    HiLog.iw(TAG, 'publishRcsSendOKEvent, start');
    try {
      commonEvent.publish(common.STR.RCS_SUBSCRIBER_SEND_OK_EVENT, {
        bundleName: common.STR.BUNDLE_NAME,
        subscriberPermissions: ['ohos.permission.SEND_MESSAGES'],
        isOrdered: false,
        data: msgId,
      }, () => {
      });
    } catch (err) {
      HiLog.i(TAG, `Failed to publish common event. Code is ${err.code}, message is ${err.message}`);
    }
  }

  public publishRcsSendCanceledEvent(msgId: string) {
    HiLog.i(TAG, 'publishRcsSendCanceledEvent, start');
    try {
      commonEvent.publish(common.STR.RCS_SUBSCRIBER_FILE_SEND_CANCELED_EVENT, {
        bundleName: common.STR.BUNDLE_NAME,
        subscriberPermissions: ['ohos.permission.SEND_MESSAGES'],
        isOrdered: false,
        data: msgId
      }, () => {
      });
    } catch (err) {
      HiLog.i(TAG, `Failed to publish common event. Code is ${err.code}, message is ${err.message}`);
    }
  }
  public publishRcsFailEvent(msgId: string) {
    HiLog.iw(TAG, 'publishRcsFailEvent, start');
    try {
      commonEvent.publish(common.STR.RCS_SUBSCRIBER_FAIL_RECEIVE_EVENT, {
        bundleName: common.STR.BUNDLE_NAME,
        subscriberPermissions: ['ohos.permission.SEND_MESSAGES'],
        isOrdered: false,
        data: msgId,
      }, () => {
      });
    } catch (err) {
      HiLog.i(TAG, `Failed to publish common event. Code is ${err.code}, message is ${err.message}`);
    }
  }



  public pushEventToNotifyReceivedSuggestions(msgId: string, serviceId: string, suggestions: BotMessage): void {
    HiLog.i(TAG, 'pushEventNotifyReceivedSuggestions');
    commonEvent.publish(common.STR.RCS_SUBSCRIBER_CHATBOT_RECEIVED_SUGGESTIONS_EVENT, {
      bundleName: common.STR.BUNDLE_NAME,
      subscriberPermissions: ['ohos.permission.RECEIVE_SMS'],
      isOrdered: false,
      data: msgId,
      parameters: {
        serviceId: serviceId,
        botMessage: suggestions
      }
    }, () => {
    });
  }

  public async setReceiveLocIndo(actionData: MessageDetail, rcsMessageValue: RcsMessage, context: Context) {
    HiLog.i(TAG, 'handleRcsReceive setReceiveLocIndo enter');
    let receiveLoc: RcsSendLoc = JSON.parse(rcsMessageValue.content) as RcsSendLoc;
    actionData.content = decodeURIComponent(receiveLoc.body);
    let arrAddressInfo: [LooseObject] = [{
      'body': actionData.content,
      'longitude': receiveLoc.longitude,
      'latitude': receiveLoc.latitude,
      'accuracy': receiveLoc.accuracy,
    }];
    actionData.content = JSON.stringify(arrAddressInfo);
    actionData.content = actionData.content.slice(1, -1);
    actionData.isMms = true;
    actionData.rcsType = commonData.ENHANCED_INFO_ITEM_TYPE.MAP;
    actionData.rcsMsgContent = ResourceUtils.getStringSync($r('app.string.msg_location'), context);
    let location: LocationType = {
      latitude: Number(receiveLoc.latitude),
      longitude: Number(receiveLoc.longitude)
    }
  }

  connectServiceAbility(actionData: MessageDetail, location: LocationType) {
    HiLog.i(TAG, 'connectServiceAbility start');
    try {
      let context: StaticSubscriberExtensionContext = GlobalContext.getContext()
        .getObject('mmsStaticContext') as StaticSubscriberExtensionContext;
      let want: Want = {
        bundleName: 'com.ohos.mms',
        abilityName: 'ServiceExtAbility',
        parameters: {
          'serviceEvent': Constant.RCS_LOCATION_GET_THUMBNAILS,
          'data': actionData,
          'location': location
        }
      };
      context.startAbility(want);
      HiLog.i(TAG, 'connectServiceAbility end');
    } catch (error) {
      HiLog.e(TAG, 'connectServiceAbility, want ServiceExtAbility fail:' + JSON.stringify(error));
    }
  }

  public async getLocThumbnails(location: LocationType, actionData: MessageDetail, context: Context) {
    HiLog.i(TAG, 'getLocThumbnails enter');
    let markers: Record<string, LocationType>[] = [
      {
        'location': location
      }
    ]
    let mapOptions: Record<string, number | LocationType | Record<string, LocationType>[]> = {
      'location': location,
      'zoom': 16,
      'imageWidth': Constant.MAP_IMG_WIDTH,
      'imageHeight': Constant.MAP_IMG_HEIGHT,
      'scale': 2,
      'markers': markers
    }
    try {
      //let pixelMap: PixelMap = await staticMap.getMapImage(context, mapOptions as object as staticMap.StaticMapOptions);
      let locStrings: string[] = actionData.content.split(';');
      let addressInfo = new AddressInfo(location.latitude, location.longitude, locStrings[0] ?? '',
        locStrings[locStrings.length - 1] ?? '');
      let mapImgName: string = '';
      let jpegPath: string = '';
      // if (pixelMap) {
      //   mapImgName = addressInfo.buildMapImgName();
      //   jpegPath = '/data/storage/el2/base/haps/entry/files/' + mapImgName;
      //   await FileUtil.packPixelMapToSandBox(context, jpegPath, pixelMap, mapImgName);
      // }
      actionData.mmsSource = [{
        size: 0,
        duration: '',
        type: common.MM_ATTACHMENT_TYPE.SMIL,
      }, {
        size: 0,
        duration: '',
        type: commonData.ENHANCED_INFO_ITEM_TYPE.MAP,
        address: addressInfo,
      //  pixelMap: pixelMap ? pixelMap : '',
        path: jpegPath,
        name: mapImgName,
        msgType: commonData.ENHANCED_INFO_ITEM_TYPE.MAP,
        content: actionData.content
      }];
    } catch (error) {
      HiLog.e(TAG, 'getLocThumbnails, get map image fail:' + JSON.stringify(error));
    }
  }

  public async parsePDU(context: Context, data: DataParameters, complete: pduCallback) {
    HiLog.i(TAG, 'parsePDU')
    let netType: string = data.parameters.isCdma ? '3gpp2' : '3gpp';
    let promisesAll: Promise<telSim.ShortMessage>[] = [];
    data.parameters.pdus.forEach(pdu => {
      let promise = telSim.createMessage(this.convertStrArray(pdu), netType);
      promisesAll.push(promise);
    });
    let result: LooseObject = {};
    let createMessagePromise = Promise.all(promisesAll);
    createMessagePromise.then(shortMsgList => {
      result.code = common.int.SUCCESS;
      result.telephone = shortMsgList[0].visibleRawAddress;
      result.content = common.STR.EMPTY_STR;
      result.messageClass = shortMsgList[0].messageClass;
      result.startTime = shortMsgList[0].scTimestamp;
      shortMsgList.forEach(shortMessage => {
        result.content += shortMessage.visibleMessageBody;
      });
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'parsePDU, error: ' + (error));
      result.code = common.int.FAILURE;
      result.messageClass = 3;
    })
    await createMessagePromise;
    result.contactName = (await this.queryContactByPhone(context, result.telephone)).contactName;
    HiLog.i(TAG, `parsePDU complete`)
    complete(result);
  }


  public async handleSmsReceive(data: DataParameters, context: Context): Promise<void> {
    let isSecurityMode = mmsUtilCtr.checkAdvancedMode();
    let netType: string = data.parameters.isCdma ? '3gpp2' : '3gpp';
    // Synchronize wait operation
    let promisesAll: Promise<telSim.ShortMessage>[] = [];
    data.parameters.pdus.forEach(pdu => {
      let promise = telSim.createMessage(this.convertStrArray(pdu), netType);
      promisesAll.push(promise);
    });
    let result: LooseObject = {};
    let createMessagePromise = Promise.all(promisesAll);
    let flag: number = Constant.BLOCKED_NOT_TO_CLOUD;
    createMessagePromise.then(shortMsgList => {
      HiLog.w(TAG, 'dealSmsReceiveData start!');
      result.code = common.int.SUCCESS;
      result.telephone = shortMsgList[0].visibleRawAddress;
      result.content = common.STR.EMPTY_STR;
      result.startTime = shortMsgList[0].scTimestamp;
      shortMsgList.forEach(shortMessage => {
        result.content += shortMessage.visibleMessageBody;
      });
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'dealSmsReceiveData, error: ' + JSON.stringify(error));
      // 短信接收失败fault打点
      DotUtil.getInstance().reportFaultEvent(dotNoNeedParmas, dotCommon.faultEventName.SMS_RECIEVE_FAIL);
      result.code = common.int.FAILURE;
    });
    await createMessagePromise;
    if (data.data === commonData.TEXT_RECEIVE_TYPE.TEXT_SMS_RECEIVE) {
        HiLog.w(TAG, 'TEXT_SMS_RECEIVE:');
        // rcs.sendOtpInfo(result.content);
        return;
    }
    let actionData: MessageDetail = new MessageDetail;
    actionData.starttime = result.startTime;
    actionData.deliveryTime = data.deliveryTime;
    actionData.isFirstUnlocked = data.isFirstUnlocked;
    actionData.slotId = data.parameters.slotId;
    actionData.telephone = result.telephone;
    actionData.content = result.content;
    HiLog.w(TAG, 'handleSmsReceive actionData.content.length is :' + actionData?.content?.length +
      ', is null :' + (actionData?.content == ''));
    actionData.isMms = false;
    actionData.isFlashMms = data.parameters.isFlashMessage;
    actionData.mmsSource = [];
    actionData.isAdvancedSecurity = isSecurityMode ? 1 : 0;
    let flagResult = await BlockedUtil.getFlag(actionData.telephone, context);
    flag = flagResult.telephoneFlag;
    actionData.telephoneType = flagResult.telephoneType;
    actionData.telephoneDot = StringUtil.phoneMask(actionData.telephone);
    actionData.dotMsgType = common.MESSAGE_TYPE.SMS_OR_MMS;
    actionData.mccmnc = await cardModel.getMccmnc(data.parameters.slotId);
    if (actionData?.content == '') {
      actionData.receiveNull = dotCommon.smsReceiveRecord.SMS_RECEIVE_REASON_NULL_CONTENT;
    }
    this.checkVerMessage(actionData, flag);
    HiLog.i(TAG, 'handleSmsReceive checkBlockMessage');
    let msgList: number[] = [];
    msgList = SharedPreferencesUtils.getFromPreferences('msgList', []) as number[];
    msgList.push(Date.now());
    SharedPreferencesUtils.saveToPreferences('msgList', msgList);
    receiveParams.MSG_TYPE = 2;
    receiveParams.CARD_SELECT_STATUS = data.parameters.slotId;
    if (DeviceUtil.isSubDeviceWithConnected(context)) {
      DotUtil.getInstance().reportEvent(receiveParams, dotCommon.eventName.DISTRIBUTED_RECEIVE_SMS_EVENT);
    } else {
      DotUtil.getInstance().reportEvent(receiveParams, dotCommon.eventName.RECEIVE_SMS_EVENT);
    }
  }

  private checkVerMessage(actionData: MessageDetail, flag: number):void {
    HiLog.w(TAG, 'checkVerMessage start');
    let context: myCommon.ServiceExtensionContext = GlobalContext.getContext()
      .getObject('mmsStaticContext') as myCommon.ServiceExtensionContext;
    if (context == null) {
      context = GlobalContext.getContext()
        .getObject('DeskDialogContext') as myCommon.ServiceExtensionContext;
    }
    SmartMmsServiceRpcService.serviceInstance().connectService(actionData, flag, context);
  }

  public async handleSendMsgWithRepairMode(actionData: MessageDetail, context: Context): Promise<void> {
    HiLog.i(TAG, 'handleSendMsgWithRepairMode start!');
    let maintenanceMode = systemParameter.getSync('persist.hiviewcare.maintenancemode');
    if (maintenanceMode == 'true') {
      inRepairModeData.push(actionData);
      HiLog.w(TAG, 'maintenanceMode is true, cache msg len: ' + inRepairModeData.length);
      DotUtil.getInstance().addFailReason(actionData.smsReceiveIdForDot || 0,
        dotCommon.smsReceiveRecord.SMS_RECEIVE_REASON_NOTIFICATION_MAINTENANCE_MODE, true);
      return;
    } else {
      if (inRepairModeData.length > 0) {
        HiLog.i(TAG, 'maintenanceMode is false, need send cache msg len : ' + inRepairModeData.length);
        inRepairModeData.forEach(actionData => {
          this.insertMsgAndSendNotify(actionData, context);
        })
        inRepairModeData.length = 0;
      }
      this.insertMsgAndSendNotify(actionData, context);
    }
  }

  public async continueReceiveMms(actionData: LooseObject, context: Context) {
    HiLog.w(TAG, 'continueReceiveMms start!');
    let maintenanceMode = await systemParameter.get('persist.hiviewcare.maintenancemode').then((value: string) => {
      HiLog.e(TAG, 'maintenanceMode:' + value);
      return value;
    })
    if (maintenanceMode != 'true') {
      let resultReturn: Record<string, number | string | Context | Resource> = {
        'telephone': '',
        'msgId': -1,
        'content': context.resourceManager.getStringSync($r('app.string.attachment_no_subject')),
        'context': context
      }
      resultReturn.telephone = actionData.telephone;
      mmsReceive.setToSQL(context, (res: sessionResult) => {
        HiLog.i(TAG, 'continueReceiveMms setToSQL success');
        SharedPreferencesUtils.saveToPreferences('needToUpdateRecMsg', true);
        HiLog.w(TAG, 'received mms and set needToUpdateRecMsg to' +
          SharedPreferencesUtils.getFromPreferences('needToUpdateRecMsg', false));
        resultReturn.msgId = res.initDatas[0].id;
        let publishData: Record<string, number | string> = {};
        publishData.threadId = res.rowId;
        publishData.telephone = actionData.telephone;
        publishData.content = '';
        publishData.slotId = actionData.slotId;
        publishData.msgId = resultReturn.msgId;
        try {
          commonEvent.publish(common.STR.RECEIVE_TRANSMIT_EVENT, {
            bundleName: common.STR.BUNDLE_NAME,
            subscriberPermissions: ['ohos.permission.RECEIVE_MMS'],
            isOrdered: false,
            data: JSON.stringify(publishData),
            parameters: publishData
          }, () => {});
        } catch (err) {
          HiLog.e(TAG, `Failed to publish, Code: ${err.code}, message: ${err.message}`);
        }
        if (actionData.isBlocked != Constant.BLOCK) {
          ReceiveService.getInstance().sendNotification({
            telephone: String(resultReturn.telephone),
            msgId: Number(resultReturn.msgId),
            content: String(resultReturn.content),
            context: context,
            smsType: res.smsType,
            isFlashMms: false,
            deliveryTime: -1,
            isFirstUnlocked: false,
            startTime: '',
            isMms: true,
            blockedType: actionData.blockedType ?? -1,
            blockedReason: actionData.blockedReason ?? -1,
            slotId: actionData.slotId,
          }, context)
        }
        DotUtil.getInstance().addDotInfoReceiveParam(actionData.smsReceiveIdForDot || 0, true, resultReturn.msgId.toString());
        // 接收消息成功率打点
        DotUtil.getInstance()
          .reportSendReceiveSuccessRate(dotCommon.smsReceiveRecord.SUCCESS_RATE_TYPE_MMS,
            dotCommon.smsReceiveRecord.SUCCESS_RATE_BEHAVIOR_RECEIVE,
            dotCommon.smsReceiveRecord.SUCCESS_RATE_STATE_FINISHED);
        HiLog.w(TAG, `continueReceiveMms downloadMms actionData.isBlocked : ${actionData?.isBlocked}`);
        // 接收到彩信在被骚扰拦截的情况下不触发下载
        if (actionData.isBlocked !== Constant.BLOCK) {
          mmsReceive.downloadMms(actionData, context);
        }
      }, actionData);
    }
  }

  private async insertMsgAndSendNotify(actionData: MessageDetail, context: Context) : Promise<void> {
    HiLog.w(TAG, 'insertMsgAndSendNotify enter')
    const msgId = actionData.msgId;

    this.insertMessageDetailBy(actionData, (res: sessionResult) => {
      HiLog.w(TAG, 'insertMessageDetailBy finish,then callback releaseResourceNumber');
      SharedPreferencesUtils.saveToPreferences('needToUpdateRecMsg', true);
      HiLog.w(TAG, 'received sms and set needToUpdateRecMsg to' +
        SharedPreferencesUtils.getFromPreferences('needToUpdateRecMsg', false));
      if (!res || !Array.isArray(res.initDatas)) {
        HiLog.e(TAG, `Invalid response type: ${typeof res?.initDatas}`);
        return;
      }
      if (res.initDatas.length > 0) {
        actionData.starttime = res.initDatas[0].start_time ?? ''
      }
      actionData.msgId = res.initDatas[0]?.id?.toString();
      HiLog.w(TAG, `receive msessage msg id is: ${actionData.msgId}`);
      if (res.smsType == common.sms_type.NOTICE) {
        HiLog.w(TAG, 'is verCode continue');
        this.smartHandleNotification(actionData, res, context);
      } else {
        HiLog.w(TAG, 'is not verCode continue');
        this.handleNotification(actionData, res, context);
      }
      DotUtil.getInstance().addDotInfoReceiveParam(actionData.smsReceiveIdForDot || 0, false, actionData.msgId);
      // 接收消息成功率打点
      DotUtil.getInstance().reportSendReceiveSuccessRateForReceived(actionData);
    }, context);
  }

  private smartHandleNotification(actionData: MessageDetail, res: sessionResult, context: Context) {
    let extParam = new Map<string, string>([
      // ['channelType', actionData.protocol ? String(actionData.protocol) : String(ChannelType.TYPE_SMS)]
    ])
    // let req: NotificationProcessorModel.NotificationInfoReq = {
    //   phoneNum: (actionData?.chatbotParameters?.isChatbotMessage &&
    //   actionData.chatbotParameters.telephoneFromServiceId) ? actionData?.chatbotParameters.telephoneFromServiceId :
    //   actionData.telephone,
    //   msgId: actionData.msgId,
    //   rcsMsgId: actionData.rcsMsgId,
    //   msg: actionData.content,
    //   msgTime: new Date().getTime(),
    //   simIndex: actionData.slotId,
    //   centerNumber: Constant.SMART_CENTER_NUMBER,
    //   extParam: extParam
    // };
    let smartGetNotification: Promise<void> = new Promise(resolve => {
      // 连接成功了, 则走rpc识别的逻辑
      // NotificationProcessorApi.getNotificationInfo(req).then(notificationRes => {
      //   HiLog.w(TAG, 'getNotificationInfo finish, code length：' + notificationRes.code?.length);
      //   if (notificationRes.code !== Constant.SMART_MSG_NOT_VER) {
      //     actionData.verCode = notificationRes.code;
      //   }
      //   resolve();
      // }).catch((e: BusinessError) => {
      //   HiLog.e(TAG, 'getNotificationInfo catch e: ' + e.message);
      //   DotUtil.getInstance().addFailReason(actionData.smsReceiveIdForDot || 0,
      //     dotCommon.smsReceiveRecord.SMS_RECEIVE_REASON_SMART_NOTIFICATION_FAIL);
      //   resolve();
      // });
    })
    let smartTimeout: Promise<void> = new Promise(resolve => {
      setTimeout(() => {
        HiLog.i(TAG, 'getNotificationInfo delay protection');
        DotUtil.getInstance().addFailReason(actionData.smsReceiveIdForDot || 0,
          dotCommon.smsReceiveRecord.SMS_RECEIVE_REASON_SMART_NOTIFICATION_TIMEOUT);
        resolve();
      }, 2000)
    })
    Promise.race([smartGetNotification, smartTimeout]).then(value => {
      this.handleNotification(actionData, res, context);
    });
    // 智能短信IPC接口，已经不实际使用，因为小艺输入法的耦合保留，小艺适配后删除
    SmartMmsServiceRpcService.serviceInstance().serviceConnect(context as myCommon.ServiceExtensionContext)
      .then((connectStatus: boolean) => {
        if (!connectStatus) {
          HiLog.i(TAG, 'ServiceExtensionAbility vercode_service_event connected error');
          return;
        }
        HiLog.i(TAG, 'serviceConnect success');
        if (res.initDatas[0]?.msgId !== undefined) { // 小艺标记已读使用msgId查mms info区分类型
          actionData.msgId = res.initDatas[0]?.msgId.toString();
        }
        SmartMmsServiceRpcService.serviceInstance().sendInfoToSmart(actionData).then((resultData: MessageDetail) => {
          HiLog.i(TAG, 'sendInfoToSmart sendInfoToSmart success');
        }).catch((e: BusinessError) => {
          HiLog.i(TAG, 'sendInfoToSmart catch e: ' + e.message);
        }).finally(()=>{
          HiLog.i(TAG, 'sendInfoToSmart disConnect');
          SmartMmsServiceRpcService.serviceInstance().disConnect();
        });
      })
  }

  public updateMsgCode(actionData: MessageDetail, context: Context) {
    let actionInfo: LooseObject = {
      'msgId': actionData.msgId,
    }
    let valueBucket: ValuesBucket;
    if (actionData.verCode && !StringUtil.isEmpty(actionData.verCode) &&
      actionData.verCode !== Constant.SMART_MSG_NOT_VER) {
      HiLog.i(TAG, 'updateMsgCode has verCode');
      valueBucket = {
        'msg_code_str': actionData.verCode,
      }
      DotUtil.getInstance().addSmsReceiveNumberParam(actionData.smsReceiveIdForDot || 0,
        dotCommon.smsReceiveRecord.RECORD_KEY_IS_VER_MSG, dotCommon.smsReceiveRecord.RECORD_VALUE_YES);
    } else {
      HiLog.i(TAG, 'updateMsgCode is not verCode');
      valueBucket = {
        'msg_code': common.isSmartType.OTHER, // 非验证码字段用-1标识
      }
      DotUtil.getInstance().addSmsReceiveNumberParam(actionData.smsReceiveIdForDot || 0,
        dotCommon.smsReceiveRecord.RECORD_KEY_IS_VER_MSG, dotCommon.smsReceiveRecord.RECORD_VALUE_NO);
    }
    ConversationService.getInstance().updateSmsMmsInfoByCondition(context, actionInfo,
      valueBucket, (res:LooseObject) => {
      if (res.code == common.int.SUCCESS) {
        HiLog.i(TAG, 'updateMsgCode success');
      } else {
        HiLog.i(TAG, 'updateMsgCode failed, resultcode: ' + res.code);
      }
    });
    // 增加更新 rcs 验证码问题
    if (actionData.type == commonData.RCS_TYPE.RCS && actionData.rcsId !== undefined) {
      actionInfo = {
        'rcsId': actionData.rcsId,
      }
      if (valueBucket.msg_code_str) {
        valueBucket = {
          'service_kind': valueBucket.msg_code_str,
        }
        ConversationRcsService.getInstance().updateRcsServiceKindMsgCodeByRcsId(actionInfo, valueBucket, context,
          (res:LooseObject) => {
          if (res.code == common.int.SUCCESS) {
            HiLog.i(TAG, 'rcs updateMsgCode success');
          } else {
            HiLog.i(TAG, 'rcs updateMsgCode failed, resultcode: ' + res.code);
          }
        });
      }
    }

  }

  public handleMsgList() {
    let msgList: number[] = [];
    msgList = SharedPreferencesUtils.getFromPreferences('msgList', []) as number[];
    let currentTime: number = Date.now();
    let msgTime: number | undefined;
    // 获取最后一个元素
    msgTime = msgList.pop();
    if (msgTime == undefined) {
      HiLog.e(TAG, 'msglist empty error');
      return;
    }
    // 先看最近的一条消息有没有超1分钟
    if (currentTime > msgTime + common.int.MILLISECOND_OF_ONE_MINUTE) {
      HiLog.e(TAG, 'the last one message timeout');
      DotUtil.getInstance().reportEvent(dotNoNeedParmas, dotCommon.eventName.RECEIVE_MESSAGE_FAIL_TIMEOUT);
    } else {
      DotUtil.getInstance().reportEvent(dotNoNeedParmas, dotCommon.eventName.RECEIVE_MESSAGE_SUCCESS);
    }
    // 再往前看一条，因为如果不往前翻，永远发现不了超时的消息
    while (msgList.length > 0) {
      if (currentTime <= msgList[msgList.length - 1] + common.int.MILLISECOND_OF_ONE_MINUTE) {
        // 如果往前找一条，没超时，就停止，等下一次执行这个函数的时候会找到再前面的
        break;
      } else {
        HiLog.e(TAG, 'find one timeout message');
        msgList.pop();
        DotUtil.getInstance().reportEvent(dotNoNeedParmas, dotCommon.eventName.RECEIVE_MESSAGE_FAIL_TIMEOUT);
      }
    }
    SharedPreferencesUtils.saveToPreferences('msgList', msgList);
  }

  public async handleNotification(resultData: MessageDetail, res: sessionResult, context: Context): Promise<void> {
    this.updateMsgCode(resultData, context);
    if (resultData.type === commonData.RCS_TYPE.RCS && resultData.rcsMsgContent) {
      resultData.content = resultData.rcsMsgContent;
    }
    HiLog.i(TAG, 'handleNotification');
    let publishData: LooseObject = {};
    publishData.threadId = res.rowId;
    publishData.telephone = resultData.telephone;
    publishData.content = resultData.content;
    publishData.slotId = resultData.slotId;
    publishData.msgId = resultData.msgId;
    this.publishData(publishData);
    resultData.content =
      !StringUtil.isEmpty(resultData.ipNoticeContent) ? resultData.ipNoticeContent : resultData.content;
    this.sendSmsNotification({
      telephone: resultData.telephone,
      msgId: res.initDatas[0]?.id || 0,
      content: resultData.content,
      context: context,
      smsType: res.smsType,
      isFlashMms: resultData.isFlashMms,
      callback: () => {
      },
      type: resultData.type,
      slotId: resultData.slotId,
      verCode: resultData.verCode,
      chatbotParameters: resultData.chatbotParameters,
      deliveryTime: resultData.deliveryTime || -1,
      isFirstUnlocked: resultData.isFirstUnlocked || false,
      startTime: resultData.starttime || '',
      smsReceiveIdForDot: resultData.smsReceiveIdForDot || 0,
      rcsType: resultData.rcsType,
      isMute: resultData.isMute,
      serviceCenter: resultData.serviceCenter || '',
      protocol: resultData.protocol || 0,
      blockedType: resultData.blockedType ?? -1,
      blockedReason: resultData.blockedReason ?? -1,
    }, context)
  }

  public async insertMessageDetailBy(param: MessageDetail, callback: Function, context: Context) {
    HiLog.w(TAG, 'insertMessageDetailBy start!');
    let sendResults: LooseObject[] = [];
    let sendResult: LooseObject = {};
    sendResult.slotId = param.slotId;
    sendResult.telephone = param.telephone;
    if (param.telephone && param.telephone.startsWith('+')) {
      HiLog.i(TAG,'telephone start is +')
    }
    if (param.telephone && param.telephone.startsWith('+86')) {
      HiLog.i(TAG,'telephone start is +86')
    }
    sendResult.content = param.content;
    sendResult.isAdvancedSecurity = param.isAdvancedSecurity;
    sendResult.sendStatus = (param.msgType === common.int.RCS_FIRST_RECEIVING) ?
    common.int.RCS_FIRST_RECEIVING : common.int.SEND_MESSAGE_SUCCESS;
    sendResults.push(sendResult);
    let hasAttachment: boolean = commonService.judgeIsAttachment(param.mmsSource);
    let actionData: LooseObject = {};
    actionData.slotId = param.slotId;
    actionData.sendResults = sendResults;
    actionData.isReceive = true;
    actionData.ownNumber = common.STR.EMPTY_STR;
    actionData.isSender = true;
    actionData.isMms = param.isMms;
    actionData.mmsSource = param.mmsSource;
    actionData.hasAttachment = hasAttachment;
    actionData.isAdvancedSecurity = param.isAdvancedSecurity;
    actionData.smsReceiveIdForDot = param.smsReceiveIdForDot;
    if (param?.type === commonData.RCS_TYPE.RCS) {
      actionData.type = param.type;
      actionData.isSender = 1;
      actionData.msgId = param.msgId;
      actionData.isAdvancedSecurity = param.isAdvancedSecurity;
    }
    // IP消息
    if (commonData.serviceCenter.PUSH_OHOS_A2P === param?.serviceCenter) {
      actionData.ownerAddr = param.ownerAddr
      actionData.protocol = param.protocol
      actionData.serviceCenter = param.serviceCenter
    }
    actionData.receiveState = param.receiveState;
    actionData.failReceiveContext = param.failReceiveContext;
    actionData.sessionContacts = param?.chatbotParameters?.isChatbotMessage ? [{
      contactPhone: param.chatbotParameters.serviceId || '',
      contactName: param.chatbotParameters.serviceName || '',
      rawContactId: '',
      contactId: ''
    }] : [await this.queryContactByPhone(context, param.telephone, param.contactName)];
    actionData.isNeedSendNotice =
      await this.isNeedSendNotice(param?.chatbotParameters?.isChatbotMessage ? param.telephone :
      Number(param.telephone), context);
    actionData.isRcsType = param.rcsType;
    actionData.curSize = param.clurSize;
    actionData.totalSize = param.totalSize;
    actionData.isBlocked = param.isBlocked;
    actionData.blockedReason = param.blockedReason;
    actionData.blockedSources = param.blockedSources;
    actionData.blockedType = param.blockedType;
    actionData.blockedTypeText = param.blockedTypeText;
    actionData.blockedPrefNumber = param.blockedPrefNumber;
    actionData.verCode = param.verCode;
    actionData.chatbotParameters = param.chatbotParameters;
    let setinContacts: string = actionData.sessionContacts[0].contactName === commonData.STR.EMPTY_STR ?
    commonData.bool.FALSE : commonData.bool.TRUE;
    AppStorage.setOrCreate('setinContacts', setinContacts);
    ConversationService.getInstance().insertSessionAndDetail(actionData, callback, context);
  }

  /**
   * This interface is used to query contact information by number
   * to confirm the ID and name of the sender when receiving an SMS message.
   *
   * @param context
   * @param phone
   * @returns
   */
  public async queryContactByPhone(context: Context, phone: string, contactName?: string): Promise<SessionContactInfoForDB> {
    HiLog.i(TAG, 'queryContactByPhone start!');
    let telephoneQuery: Record<string, string[]> = {
      'telephones': [phone]
    };
    let contactInfo: SessionContactInfoForDB = {
      contactPhone: phone,
      contactName: '',
      rawContactId: '',
      contactId: ''
    };
    return new Promise<SessionContactInfoForDB>((resolve) => {
      ContactsService.getInstance().queryContactDataReceive(telephoneQuery, async (res: AbilityResult) => {
        this.queryContactDataByConditionResult(res, contactInfo);
        await this.notContactDealYellowPageInfo(contactInfo, context);
        if (!contactInfo.contactName && contactName) {
          contactInfo.contactName = contactName
        }
        resolve(contactInfo);
      }, context);
    })
  }

  private async notContactDealYellowPageInfo(contactInfo: SessionContactInfoForDB, context: Context) {
    if (StringUtil.isEmpty(contactInfo.contactName) && StringUtil.isEmpty(contactInfo.rawContactId)) {
      let res = await YellowPageService.getInstance().judgeYellowPageByTelephone(contactInfo.contactPhone, context);
      if (res.yellowPageId) {
        contactInfo.contactName = res.name;
      }
    }
  }

  public queryContactDataByConditionResult(res: AbilityResult, contactInfo: SessionContactInfoForDB) {
    if (res.code == commonData.int.FAILURE) {
      HiLog.e(TAG, 'Receive new message send query contact id failed');
    } else {
      HiLog.w(TAG, 'Receive new message send query contact id success');
      if (res.abilityResult.length > 0) {
        let result: Contact = (res.abilityResult as Contact[])[0];
        contactInfo.rawContactId = result.rawContactId ?? '';
        contactInfo.contactId = result.contactId ?? '';
        contactInfo.contactName = result.displayName ?? '';
      } else {
        HiLog.w(TAG, 'without result');
      }
    }
  }

  public convertStrArray(sourceStr: string): Array<number> {
    HiLog.i(TAG, 'convertStrArray start!');
    let wby: string = sourceStr;
    let length: number = wby.length;
    let isDouble: boolean = (length % numberTwo) === 0;
    let halfSize: number = Number.parseInt('' + length / numberTwo);
    HiLog.i(TAG, 'convertStrArray, length=' + length + ', isDouble=' + isDouble);
    if (isDouble) {
      let number0xArray: string[] = new Array(halfSize);
      for (let i = 0; i < halfSize; i++) {
        number0xArray[i] = '0x' + wby.substr(i * numberTwo, 2);
      }
      let numberArray: number[] = new Array(halfSize);
      for (let i = 0; i < halfSize; i++) {
        numberArray[i] = Number.parseInt(number0xArray[i], 16);
      }
      return numberArray;
    } else {
      let number0xArray: string[] = new Array(halfSize + 1);
      for (let i = 0; i < halfSize; i++) {
        number0xArray[i] = '0x' + wby.substr(i * numberTwo, 2);
      }
      number0xArray[halfSize] = '0x' + wby.substr((halfSize * numberTwo) + 1, 1);
      let numberArray: number[] = new Array(halfSize + 1);
      for (let i = 0; i < halfSize; i++) {
        numberArray[i] = Number.parseInt(number0xArray[i], 16);
      }
      let last0x = '0x' + wby.substr(wby.length - 1, 1);
      numberArray[halfSize] = Number.parseInt(last0x);
      return numberArray;
    }
  }

  public publishData(actionData: LooseObject): void {
    HiLog.i(TAG, 'publishData, start');
    try {
      commonEvent.publish(common.STR.RECEIVE_TRANSMIT_EVENT, {
        bundleName: common.STR.BUNDLE_NAME,
        subscriberPermissions: ['ohos.permission.RECEIVE_SMS'],
        isOrdered: false,
        data: JSON.stringify(actionData),
        parameters:actionData
      }, () => {
      });
    } catch (err) {
      HiLog.i(TAG, `Failed to publish common event. Code is ${err.code}, message is ${err.message}`);
    }
  }

  public sendNotification(options: ParamsSendNotification, context: Context): void {
    HiLog.w(TAG, 'sendNotification start');
    let condition: LooseObject = {};
    let contacts: Contact[] = [];
    let markInfo: MarkInfoContactModel = new MarkInfoContactModel();
    condition.telephones = [options.telephone];
    condition.hasDelete = '0';
    ContactService.getInstance().queryContactDataByCondition(condition, async (res: AbilityResult) => {
      if (res.code === common.int.FAILURE) {
        contacts = [];
        HiLog.e(TAG, 'sendNotification, error');
      } else {
        contacts = res.abilityResult;
        HiLog.i(TAG, 'sendNotification, success');
      }
      let actionData: LooseObject = this.dealContactParams(contacts, options.telephone);
      if (contacts.length === 0 && !TelephoneUtil.judgeIsInfoMsg(options.telephone)) {
        markInfo = await BlockedUtil.getNumberMarkInfo(context, options.telephone) as MarkInfoContactModel;
        if (markInfo.markSource !== 'WeLink') {
          markInfo.markContent = '';
        }
      }
      let title: string = options.telephone;
      if (contacts.length > 0) {
        title = contacts[contacts.length - 1].displayName
      } else if (options.chatbotParameters?.isChatbotMessage) {
        title = options.chatbotParameters.serviceName || '';
      } else if (!StringUtil.isEmpty(markInfo.markContent)) {
        title = markInfo.markContent;
        let data: Record<string, string> = {
          'contactName': markInfo.markContent,
          'telephone': options.telephone,
          'telephoneFormat': options.telephone,
          'contactId': ''
        }
        actionData.contactObjects = JSON.stringify([data]);
        this.updateMarkInfoContactName(context, options.telephone, markInfo.markContent);
      }
      let message: Record<string, string> = {
        'title': title,
        'text': options.content,
      };
      actionData.message = message;
      actionData.msgId = options.msgId;
      actionData.unreadTotal = 0;
      actionData.telephone = options.telephone;
      actionData.slotId = options.slotId;
      actionData.smsType = options.smsType;
      actionData.isFlashMms = options.isFlashMms;
      actionData.deliveryTime = options.deliveryTime;
      actionData.isFirstUnlocked = options.isFirstUnlocked;
      actionData.startTime = options.startTime;
      actionData.isMute = options.isMute;
      actionData.serviceCenter = options.serviceCenter;
      actionData.protocol = options.protocol;
      actionData.blockedType = options.blockedType;
      actionData.blockedReason = options.blockedReason;
      if (options.verCode) {
        actionData.verCode = options.verCode;
      }
      if (options.type !== undefined) {
        actionData.type = options.type;
      }
      if (options.isMms != null) {
        HiLog.w(TAG, 'isMms is not null!')
        actionData.isMms = options.isMms;
      }
      if (options.rcsType != undefined) {
        HiLog.w(TAG, 'rcsType is:' + options.rcsType);
        actionData.rcsType = options.rcsType;
      }
      HiLog.w(TAG, '[receive msg sendNotify]');
      ConversationListService.getInstance().statisticalData((res: Response) => {
        this.noticeData(res, actionData, options.context,
          options.chatbotParameters, options.smsReceiveIdForDot);
      }, options.context);
    }, options.context);
  }

  public sendSmsNotification(param: ParamsSendSmsNotification, context: Context): void {
    this.sendNotification({
      telephone: param.telephone,
      msgId: param.msgId,
      content: param.content,
      context: param.context,
      smsType: param.smsType,
      isFlashMms: param.isFlashMms,
      type: param.type,
      slotId: param.slotId,
      verCode: param.verCode,
      chatbotParameters: param.chatbotParameters,
      deliveryTime: param.deliveryTime,
      isFirstUnlocked: param.isFirstUnlocked,
      startTime: param.startTime,
      smsReceiveIdForDot: param.smsReceiveIdForDot,
      rcsType: param.rcsType,
      isMute: param.isMute,
      serviceCenter: param.serviceCenter,
      protocol: param.protocol,
      blockedType: param.blockedType,
      blockedReason: param.blockedReason,
    }, context)
    param.callback();
  }

  noticeData(res: Response, actionData: LooseObject, context: Context, chatbotParameters?: ChatbotParameters | undefined, smsReceiveIdForDot?: number): void {
    HiLog.i(TAG, 'noticeDatanoticeData');
    if (res.code == common.int.SUCCESS) {
      HiLog.w(TAG, 'res success')
      if (!screenLock.isLocked() || !UnLockedNotifyService.getInstance().dataIsMoveEL5) {
        actionData.unreadTotal = res.response.totalListCount;
        let badgeContext:ISetBadgeContextInfo={
          unreadTotal:res.response.totalListCount,
          appContext:context,
          updateBadgeEventCode:'noticeData',
          tracedId: systemDateTime.getTime().toString()
        }
      }
      if (!chatbotParameters || chatbotParameters?.isNotifyUserMessage) {
        let isOobe: boolean = oobeResult.getInstance().getMmsNoticeOobeFromUI(context);
        HiLog.i(TAG, `NotifyUserMessage oobe:${isOobe}`);
        if (!isOobe) {
          isOobe = !isOobe
        }
        this.oobeNeedSendNotice(!isOobe, actionData, context, smsReceiveIdForDot);
      }
    } else {
      HiLog.e(TAG, 'res failed');
    }
  }

  private async oobeNeedSendNotice(isOobe: boolean, actionData: LooseObject, context: Context,
    smsReceiveIdForDot?: number) {
    HiLog.i(TAG, `oobeNeedSendNotice`);
    if (!isOobe) {
      if (actionData.smsType == common.sms_type.NOTICE) {
        SharedPreferencesUtils.saveToPreferences('hasInfoMsgBool', true);
      }
      if (await this.isNeedSendNotice(actionData.telephone, context) && !actionData.isFlashMms) {
        HiLog.i(TAG, 'isNeedSendNotice success');
        NotificationService.getInstance(context).sendNotify(actionData, context, smsReceiveIdForDot);
        GlobalContext.getContext().setObject('conversationNeedToUpdate', true);
      } else {
        if (!this.isAdvancedMode) {
          this.rcsSendReadReceipt(actionData);
        }
        DotUtil.getInstance().addFailReason(smsReceiveIdForDot || 0,
          dotCommon.smsReceiveRecord.SMS_RECEIVE_REASON_DEFAULT_NOT_NOTIFY, true);
        HiLog.i(TAG, 'isNeedSendNotice failed');
        this.handleMsgList();
      }
    } else {
      DotUtil.getInstance().addFailReason(smsReceiveIdForDot || 0,
        dotCommon.smsReceiveRecord.SMS_RECEIVE_REASON_OOBE_NOT_NOTIFY, true);
      this.handleMsgList();
    }
  }

  public rcsSendReadReceipt(actionData: LooseObject) {
    HiLog.i(TAG, 'rcsSendReadReceipt');
    if (actionData == null) {
      HiLog.e(TAG, 'rcsSendReadReceipt actionData is null');
      return;
    }
    try {
      // rcs.sendReadReceipt(actionData.telephone, () => {});
    } catch (exception) {
      HiLog.e(TAG, 'oobeNeedSendNotice, no have rcs exception: ' + JSON.stringify(exception));
    }
  }

  public dealContactParams(contacts: Contact[], telephone: string): LooseObject {
    HiLog.i(TAG, 'dealContactParams success');
    let actionData: LooseObject = {};
    let params: LooseObject[] = [];
    if (contacts.length == 0) {
      HiLog.i(TAG, 'contacts length zero');
      let data: Record<string, string> = {
        'telephone': telephone,
      }
      params.push(data);
    } else {
      HiLog.i(TAG, 'have contacts');
      let contact: Contact = contacts[0];
      let data: Record<string, string> = {
        'contactName': contact.displayName,
        'telephone': telephone,
        'telephoneFormat': contact.detailInfo,
        'contactId': contact.contactId || ''
      }
      params.push(data);
    }
    actionData.contactObjects = JSON.stringify(params);
    return actionData;
  }

  private async isNeedSendNotice(sendTel: number | string, context: Context): Promise<boolean> {
    let notificationIsShow = SharedPreferencesUtils.getFromPreferences('notificationIsShow', false);
    let mobilePhoneNumber = await NotificationService.getInstance(context).getCurrentThreadMobilePhoneNumber();
    let isNeedSendNotice = notificationIsShow ? (TelephoneUtil.formatDisplayPhoneNumE164(mobilePhoneNumber.toString()) != TelephoneUtil.formatDisplayPhoneNumE164(sendTel.toString())) : true;
    HiLog.w(TAG, `isNeedSendNotice: notificationIsShow -> ${notificationIsShow}; isNeedSendNotice -> ${isNeedSendNotice}`);
    return isNeedSendNotice;
  }

  /**
   * intercept the later broadcast when the message status is send canceled
   */
  async interceptLaterSendBroadcastOnCanceledMessage(context: Context, msgId: string) {
    let isIntercept = false;
    if (!msgId) {
      return isIntercept;
    }

    let msgState = await this.queryRcsInfoMessageStatusByMsgId(context, msgId);
    if (msgState === common.int.RCS_SEND_CANCELED) {
      isIntercept = true;
      HiLog.iw(TAG, 'interceptLaterSendBroadcastOnCanceledMessage Intercept processing of send event broadcast!');
    }
    return isIntercept;
  }

  async queryRcsInfoMessageStatusByMsgId(context: Context, msgId: string) {
    if (!msgId) {
      return;
    }
    let condition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    condition.equalTo('msg_id', msgId);
    let resultSet: DataShareResultSet | void =
      await ConversationRcsModel.queryInRcsInfoByConditionAndColumns(context, condition, ['msg_state']);
    if (!resultSet) {
      HiLog.e(TAG, 'queryRcsInfoMessageStatusByMsgId query message status is failed');
      return;
    }
    if (!resultSet.rowCount) {
      HiLog.iw(TAG, 'queryRcsInfoMessageStatusByMsgId not query message with msgId');
      return;
    }
    resultSet.goToFirstRow();
    let msgState = resultSet.getLong(0) || undefined;
    resultSet.close();
    return msgState;
  }
 
  /**
   * intercept the later broadcast when the message status is Receive canceled
   */
  async interceptLaterReceiveBroadcastOnCanceledMessage(context: Context,
    msgId: string) {
    let isIntercept = false;
    if (!msgId) {
      return isIntercept;
    }
 
    let msgState = await this.queryRcsInfoMessageStatusByMsgId(context, msgId);
    if (msgState === common.int.RCS_RECEIVING_CANCEL) {
      isIntercept = true;
      HiLog.i(TAG, 'interceptLaterReceiveBroadcastOnCanceledMessage Intercept processing of Receive event broadcast!');
    }
    return isIntercept;
  }

  public applyEfficiencyResources(duration: number): void {
    this.releaseResourceNumber++;
    HiLog.i(TAG, 'applyEfficiencyResources releaseResourceNumber : ' + this.releaseResourceNumber);
    try {
      // 应用需要在后台保持活动状态，不被挂起, 可以设置超时时间
      let request: backgroundTaskManager.EfficiencyResourcesRequest = {
        resourceTypes: backgroundTaskManager.ResourceType.CPU,
        isApply: true,
        timeOut: duration,
        reason: 'receive mms',
        isPersist: false,
        isProcess: false,
      };
      backgroundTaskManager.applyEfficiencyResources(request);
      HiLog.i(TAG, 'applyRelease applyEfficiencyResources success');
    } catch (error) {
      HiLog.e(TAG, 'applyRelease applyEfficiencyResources error: ' + JSON.stringify(error));
    }
  }

  /**
   * 申请能效资源，不设置超时时间
   */
  public applyEfficiencyResourcesUnSetTimeOut(): void {
    this.releaseResourceNumber ++;
    HiLog.i(TAG, 'applyEfficiencyResourcesUnSetTimeOut releaseResourceNumber : ' + this.releaseResourceNumber);
    try {
      // 应用需要在后台保持活动状态，不设置超时时间，应用控制释放资源
      let request: backgroundTaskManager.EfficiencyResourcesRequest = {
        resourceTypes: backgroundTaskManager.ResourceType.CPU,
        isApply: true,
        reason: 'receive mms',
        isPersist: true,
        isProcess: false,
        timeOut: 0
      };
      backgroundTaskManager.applyEfficiencyResources(request);
      HiLog.i(TAG, 'applyEfficiencyResources success');
    } catch (error) {
      HiLog.e(TAG, `applyEfficiencyResources error:  ${error?.code}, message is ${error?.message}`);
    }
  }

  public reduceEfficiencyResources(): void {
    this.releaseResourceNumber--;
    HiLog.i(TAG, 'reduceEfficiencyResources releaseResourceNumber: ' + this.releaseResourceNumber);
    if (this.releaseResourceNumber <= 0) {
      this.releaseResourceNumber = 0;
      this.releaseEfficiencyResources();
    }
  }

  public releaseEfficiencyResources(): void {
    try {
      // 应用在后台完成了工作后，部分释放能效资源，按照应用释放
      let request: backgroundTaskManager.EfficiencyResourcesRequest = {
        resourceTypes: backgroundTaskManager.ResourceType.CPU,
        isApply: false,
        timeOut: 0,
        reason: 'receive mms',
        isPersist: false,
        isProcess: false,
      };
      backgroundTaskManager.applyEfficiencyResources(request);
      HiLog.i(TAG, 'releaseEfficiencyResources success');
    } catch (error) {
      HiLog.e(TAG, 'releaseEfficiencyResources error: ' + JSON.stringify(error));
    }
  }

  public handleNormalSMSForNoLockedScreen(data: DataParameters | null) {
    HiLog.i(TAG, 'first has locked screen')
    let want: Want = {
      bundleName: 'com.ohos.mms',
      abilityName: 'ServiceExtAbility',
    };
    if (data !== null) {
      want.parameters = {
        'serviceEvent': common.STR.SUBSCRIBER_FIRST_UNLOCK_EVENT,
        'data': data,
      }
    } else {
      want.parameters = {
        'serviceEvent': common.STR.SUBSCRIBER_SCREEN_UNLOCK_EVENT,
      }
    }
    let context: StaticSubscriberExtensionContext = GlobalContext.getContext()
      .getObject('mmsStaticContext') as StaticSubscriberExtensionContext;
    context.startAbility(want);
  }

  public startMmsAbilityAndSendNotify(data: DataParameters) {
    HiLog.i(TAG, 'startMmsAbilityAndSendNotify')
    let want: Want = {
      bundleName: 'com.ohos.mms',
      abilityName: 'ServiceExtAbility',
    };
    if (data !== null) {
      // 首次开机未解锁前的场景
      want.parameters = {
        'serviceEvent': common.STR.SUBSCRIBER_FIRST_LOCK_RECV_EVENT,
        'data': data,
      }
    }
    let context: StaticSubscriberExtensionContext = GlobalContext.getContext()
      .getObject('mmsStaticContext') as StaticSubscriberExtensionContext;
    context.startAbility(want);
  }

  /**
   * 针对welink联系人，更新用户信息
   * @param context
   * @param telephone 手机号
   * @param nameString 用户名称
   */
  updateMarkInfoContactName(context: Context, telephone: string, nameString: string) {
    let actionInfo: LooseObject = {
      'telephone': telephone,
    }
    let valueBucket: ValuesBucket = {
      'contact_name': nameString,
      'contact_id': '',
    }
    ConversationListService.getInstance()
      .updateSessionByCondition(context, actionInfo, valueBucket, null, true);
  }
}