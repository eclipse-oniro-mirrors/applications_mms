/**
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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

import commonData from '../../data/commonData';
import LooseObject from '../../data/LooseObject';
import ConversationService from '../../service/ConversationService';
import HiLog from '../../utils/HiLog';
import SharedPreferencesUtils from '../../utils/SharedPreferencesUtils';
import { mmsListType } from './conversationController';
import common from '../../data/commonData';
import { taskpool } from '@kit.ArkTS';
import { dataShare, dataSharePredicates, preferences } from '@kit.ArkData';
import DataShareHelper from '../../model/repository/DataShareHelper';
import { BusinessError } from '@kit.BasicServicesKit';
import StringUtil from '../../utils/StringUtil';
import dotCommon, {
  ReceiveMessageDownloadParams,
} from '../../utils/MmsDot/DotCommon';
import { sim } from '@kit.TelephonyKit';
import DotUtil from '../../utils/MmsDot/DotUtils';
import MmsUtil from '../../utils/MmsUtil';

const TAG = 'StorageMessageTimeout';

const smsTimeout: number = 60 * 1000;
const mmsTimeout: number = 120 * 1000;
const mmsDownloadTimeout: number = 6 * 60 * 1000;

export class StorageMessage {
  public id: number = 0;
  public startTime: number = 0;
  public isMsm: boolean = true;
  public isDownLoad: boolean = false;

  constructor(id: number, startTime: number, isMsm: boolean, isDownLoad: boolean = false) {
    this.id = id;
    this.startTime = startTime;
    this.isMsm = isMsm;
    this.isDownLoad = isDownLoad;
  }
}

export class StorageMessageTimeout {
  private static sInstance: StorageMessageTimeout | undefined = undefined;
  public context: Context | null = null;
  //倒计时的消息
  private messageTimer: Map<number | string, number> = new Map<number | string, number>();
  public static storageMessageListName: string = 'StorageMessageIDList';

  static getInstance() {
    if (!StorageMessageTimeout.sInstance) {
      StorageMessageTimeout.sInstance = new StorageMessageTimeout();
    }
    return StorageMessageTimeout.sInstance;
  }

  public sendMessageStorageAndTimeout(item: mmsListType, isDownLoad: boolean = false) {
    let currentTime = new Date().getTime();
    let timeoutTime: number = isDownLoad ? mmsDownloadTimeout : (item.isMsm ? mmsTimeout : smsTimeout);
    HiLog.i(TAG, `sendMessageStorageAndTimeout messageid: ${item?.id}, timeoutTime: ${timeoutTime}`);
    let storageMessageItem = JSON.stringify(new StorageMessage(Number(item.id), currentTime, item.isMsm, isDownLoad));
    let storageMessageList =
      SharedPreferencesUtils.getFromPreferences(StorageMessageTimeout.storageMessageListName, []) as Array<string>;
    storageMessageList = storageMessageList.filter((val)=>{
      let storageMessageValue: StorageMessage = JSON.parse(val)
      return storageMessageValue.id != item.id
    })
    storageMessageList.push(storageMessageItem)
    HiLog.i(TAG, `sendMessageStorageAndTimeout storageMessageList.size is: ${storageMessageList?.length}`);
    SharedPreferencesUtils.saveToPreferences(StorageMessageTimeout.storageMessageListName, storageMessageList)
    if (this.messageTimer.has(item.id)) {
      HiLog.i(TAG, `The messageTimer has the same id.`);
      clearTimeout(this.messageTimer.get(item.id));
      this.messageTimer.delete(item.id);
    }
    let timeoutID = setTimeout(() => {
      HiLog.w(TAG, `The message status is updated when the timer expires. msgId:${item.id}`);
      this.messageTimer.delete(item.id);
      this.searchForSmsMmsInfo(item, (msgItem: LooseObject) => {
        if (msgItem == undefined) {
          HiLog.e(TAG, `The msgItem is undefined`);
          return;
        }
        if (msgItem.msgState == commonData.int.SEND_MESSAGE_SENDING) {
          item.msgState = commonData.int.SEND_MESSAGE_FAILED;
          item.sendStatus = commonData.int.SEND_MESSAGE_FAILED;
          this.updateMessageStatusForSmsMmsInfoWithItem(item);
          if (item.isMsm) {
            this.reportSendMmsFail(item);
          }
        } else if (msgItem.msgState == commonData.int.MMS_DOWNLOADING) {
          item.msgState = commonData.int.MMS_DOWNLOAD_FAILED;
          item.sendStatus = commonData.int.MMS_DOWNLOAD_FAILED;
          this.updateMessageStatusForSmsMmsInfoWithItem(item);
          this.reportDownLoadFail(item);
        }
      })
      let storageMessageList =
        SharedPreferencesUtils.getFromPreferences(StorageMessageTimeout.storageMessageListName, []) as Array<string>;
      let index = storageMessageList.indexOf(storageMessageItem)
      storageMessageList.splice(index, 1)
      SharedPreferencesUtils.saveToPreferences(StorageMessageTimeout.storageMessageListName, storageMessageList)
    }, timeoutTime)
    this.messageTimer.set(item.id, timeoutID)
  }

  private reportSendMmsFail(item: mmsListType) {
    let reportParams: Record<string, number | number[] | string | boolean | string[]> = {
      'slotId': item.slotId,
      'destinationHost': item.receiverNumber,
      'msgType': common.ueMsgType.MMS,
      'msgContent': MmsUtil.getMsgContentByMmsSource(item.mmsSource),
      'id': item.id,
      'sendResult': common.ueMsgSendType.RETURN,
    };
    DotUtil.getInstance().reportSendMessageCommon(reportParams);
  }

  private reportDownLoadFail(data: mmsListType) {
    let param = new ReceiveMessageDownloadParams();
    param.PHONE_NUMBER = StringUtil.phoneMask(data.telephone);
    param.EXPIRATION_TIME = data.expiresTime;
    param.RETRY_TIME = common.int.RETRY_TIME_INVALID;
    param.MCCMNC = sim.getSimOperatorNumericSync(data.slotId);
    param.MSGID = data.id ? data.id.toString() : '';
    param.DOWNLOAD_STATE = dotCommon.smsReceiveRecord.RECEIVE_MESSAGE_DOWNLOAD_STATE_FAIL;
    param.DOWNLOAD_DETAIL_ERROR = dotCommon.smsReceiveRecord.RECEIVE_MESSAGE_DOWNLOAD_FAIL_TIMEOUT;
    DotUtil.getInstance().reportEvent(param, dotCommon.eventName.RECEIVE_MESSAGE_DOWNLOAD);
  }

  private searchForSmsMmsInfo(item: mmsListType, callback: Function) {
    HiLog.i(TAG, `searchForSmsMmsInfo start`);
    if (!item.id) {
      HiLog.e(TAG, `searchForSmsMmsInfo no itemID`);
      return
    }
    if (this.context == null) {
      HiLog.e(TAG, `context is null`);
      return;
    }
    let actionData: LooseObject = {
      'msgId': item.id,
    }
    ConversationService.getInstance().querySmsMmsInfoByCondition(this.context, actionData, (result: LooseObject) => {
      if (result.code === common.int.SUCCESS && result.abilityResult != null) {
        let msgItem: LooseObject = result.abilityResult[0];
        callback(msgItem);
      }
    })
  }

  private updateMessageStatusForSmsMmsInfoWithItem(item: mmsListType) {
    HiLog.w(TAG, `updateMessageStatusForSmsMmsInfoWithItme start:${item.id}`);
    if (!item.id) {
      HiLog.e(TAG, `updateMessageStatusForSmsMmsInfoWithItme no itemID`);
      return
    }
    if (this.context == null) {
      HiLog.e(TAG, `context is null`);
      return;
    }
    let actionData: Record<string, number | string> = {
      'msgId': item.id,
    }
    let valueBucket: Record<string, number> = {
      'msg_state': item.sendStatus
    }
    ConversationService.getInstance()
      .updateSmsMmsInfoByCondition(this.context, actionData, valueBucket, (res: LooseObject) => {
      if (res.code == common.int.SUCCESS) {
        HiLog.i(TAG, 'updateMsgState success');
      } else {
        HiLog.i(TAG, 'updateMsgState failed, resultcode: ' + res.code);
      }
    });
  }

  public checkOutMessageStorageByTaskPool() {
    let storageMessageStrList =
      SharedPreferencesUtils.getFromPreferences(StorageMessageTimeout.storageMessageListName, []) as Array<string>;
    let storageMessageList = storageMessageStrList.map((item) => {
      return JSON.parse(item) as StorageMessage;
    })
    HiLog.i(TAG, `checkOutMessageStorageByTaskPool-storageMessageList is :${JSON.stringify(storageMessageStrList)}`);
    if (storageMessageList.length > 0) {
      taskpool.execute(checkOutMessageStorage, storageMessageList, mmsTimeout, smsTimeout, mmsDownloadTimeout,
        this.context).then((value: Object) => {
        let messageIDList = value as number[];
        HiLog.i(TAG, `checkOutMessageStorageByTaskPool-messageIDList is :${messageIDList.toString()}`);
        storageMessageStrList = storageMessageStrList.filter((item: string) => {
          let storeMessage = JSON.parse(item) as StorageMessage;
          return messageIDList.indexOf(storeMessage.id) == -1
        })
        HiLog.i(TAG,
          `checkOutMessageStorageByTaskPool end storageMessageList is :${JSON.stringify(storageMessageStrList)}`);
        SharedPreferencesUtils.saveToPreferences(StorageMessageTimeout.storageMessageListName, storageMessageStrList);
      })
    } else {
      HiLog.i(TAG, '-storageMessageList is []');
    }
  }
}

@Concurrent
function checkOutMessageStorage(storageMessageList: StorageMessage[], mmsTimeout: number, smsTimeout: number,
  mmsDownloadTimeout: number, context: Context): number[] {
  let messageIDList: number[] = []
  storageMessageList.forEach(async (item) => {
    let currentTime = new Date().getTime();
    let timeoutTime: number = item.isDownLoad ? mmsDownloadTimeout : (item.isMsm ? mmsTimeout : smsTimeout);
    let messageItem = new mmsListType;
    messageItem.id = item.id;
    messageItem.isMsm = item.isMsm;
    let timeMillisecond: number = Number(item.startTime);
    let sms = new Date(Number(timeMillisecond));
    let itemStarTime = sms.getTime();
    HiLog.i('StorageMessageTimeout',
      `checkOutMessageStorage msgId:${messageItem.id},isMsm:${messageItem.isMsm},timeOut:${timeMillisecond},itemStarTime:${itemStarTime}`);
    if (currentTime - itemStarTime > timeoutTime) {
      messageIDList.push(item.id);
      let conditionArgs = new dataSharePredicates.DataSharePredicates();
      conditionArgs.equalTo('msg_id', item.id);
      let dataHelper: dataShare.DataShareHelper | undefined = await DataShareHelper.getInstance().initSmsDB(context);
      if (!dataHelper) {
        HiLog.e('StorageMessageTimeout', 'createDataShareHelper fail');
        return;
      }
      let managerUri = common.STR.URI_MESSAGE_LOG + common.STR.URI_MESSAGE_INFO_TABLE;
      dataHelper.query(managerUri, conditionArgs, ['msg_id', 'msg_state']).then(async resultSet => {
        let msgState: number = -1;
        if (resultSet.rowCount > 0) {
          while (resultSet.goToNextRow()) {
            msgState = Number(resultSet.getString(resultSet.getColumnIndex('msg_state')))
          }
        }
        resultSet.close();
        let status: boolean = false;
        if (msgState == commonData.int.SEND_MESSAGE_SENDING) {
          messageItem.msgState = commonData.int.SEND_MESSAGE_FAILED;
          messageItem.sendStatus == commonData.int.SEND_MESSAGE_FAILED;
          status = true;
        } else if (msgState == commonData.int.MMS_DOWNLOADING) {
          messageItem.msgState = commonData.int.MMS_DOWNLOAD_FAILED;
          messageItem.sendStatus = commonData.int.MMS_DOWNLOAD_FAILED;
          status = true;
        }
        if (status) {
          let conditionArgs = new dataSharePredicates.DataSharePredicates();
          conditionArgs.equalTo('msg_id', item.id);
          let valueBucket: Record<string, number> = {
            'msg_state': messageItem.msgState
          }
          let dataHelper: dataShare.DataShareHelper | undefined =
            await DataShareHelper.getInstance().initSmsDB(context);
          if (!dataHelper) {
            HiLog.e('StorageMessageTimeout', 'createDataShareHelper fail');
            return;
          }
          let managerUri = common.STR.URI_MESSAGE_LOG + common.STR.URI_MESSAGE_INFO_TABLE;
          dataHelper.update(managerUri, conditionArgs, valueBucket).then((res: number) => {
            HiLog.e('StorageMessageTimeout', 'updateSmsMmsInfoByCondition success, number: ' + res);
          }).catch((error: BusinessError) => {
            HiLog.e('StorageMessageTimeout', 'updateSmsMmsInfoByCondition fail, error: ' + JSON.stringify(error));
          });
        }
      }).catch((error: BusinessError) => {
        HiLog.e('StorageMessageTimeout', 'querySmsMmsInfoByCondition fail, error: ' + JSON.stringify(error));
      });
    } else {
      HiLog.i('StorageMessageTimeout', 'the timer not expires');
    }
  });
  return messageIDList;
}