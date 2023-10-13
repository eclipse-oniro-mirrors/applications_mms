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

import HiLog from '../utils/HiLog';
import common from '../data/commonData';
import ConversationListModel from '../model/ConversationListModel';
import ConversationService from './ConversationService';
import ContactService from './ContactsService';
import commonService from './CommonService';
import telephoneUtils from '../utils/TelephoneUtil';
import LooseObject from '../data/LooseObject'

const TAG = "ConversationListService";

export default class ConversationListService {
  private static instance: ConversationListService;
  private conversationListModel: ConversationListModel = new ConversationListModel();

  private constructor() {
  }

  public static getInstance(): ConversationListService {
    if (ConversationListService.instance == null) {
      ConversationListService.instance = new ConversationListService();
    }
    return ConversationListService.instance;
  }

  public insertSession(valueBucket, callback, context): void {
    let mmsContext = context ? context : globalThis.mmsContext;
    if (globalThis.DataWorker != null) {
      globalThis.DataWorker.sendRequest(common.RUN_IN_WORKER_METHOD.insertSession, {
        valueBucket: valueBucket,
        context: mmsContext
      }, res => {
        if (callback) {
          callback(res);
        }
      });
    } else {
      this.conversationListModel.insertSession(valueBucket, callback, mmsContext);
    }
    globalThis.needToUpdate = true;
  }

  public deleteSessionByCondition(actionData, callback, context): void {
    let mmsContext = context ? context : globalThis.mmsContext;
    if (globalThis.DataWorker != null) {
      globalThis.DataWorker.sendRequest(common.RUN_IN_WORKER_METHOD.deleteSessionByCondition, {
        actionData: actionData,
        context: mmsContext
      }, res => {
        if (callback) {
          callback(res);
        }
      });
    } else {
      this.conversationListModel.deleteSessionByCondition(actionData, callback, mmsContext);
    }
    globalThis.needToUpdate = true;
  }

  public updateSessionByCondition(actionData, valueBucket, callback, context): void {
    let mmsContext = context ? context : globalThis.mmsContext;
    if (globalThis.DataWorker != null) {
      globalThis.DataWorker.sendRequest(common.RUN_IN_WORKER_METHOD.updateSessionByCondition, {
        actionData: actionData,
        valueBucket: valueBucket,
        context: mmsContext
      }, res => {
        if (callback) {
          callback(res);
        }
      });
    } else {
      this.conversationListModel.updateSessionByCondition(actionData, valueBucket, callback, mmsContext);
    }
    globalThis.needToUpdate = true;
  }

  public querySessionByCondition(actionData, callback, context): void {
    let mmsContext = context ? context : globalThis.mmsContext;
    if (globalThis.DataWorker != null) {
      globalThis.DataWorker.sendRequest(common.RUN_IN_WORKER_METHOD.querySessionByCondition, {
        actionData: actionData,
        context: mmsContext
      }, res => {
        callback(res);
      });
    } else {
      this.conversationListModel.querySessionByCondition(actionData, callback, mmsContext);
    }
  }

  public querySessionSizeByCondition(actionData, callback, context): void {
    let mmsContext = context ? context : globalThis.mmsContext;
    if (globalThis.DataWorker != null) {
      globalThis.DataWorker.sendRequest(common.RUN_IN_WORKER_METHOD.querySessionSizeByCondition, {
        actionData: actionData,
        context: mmsContext
      }, res => {
        callback(res);
      });
    } else {
      this.conversationListModel.querySessionSizeByCondition(actionData, callback, mmsContext);
    }
  }

  public async getSessionListSize(actionData, context): Promise<number> {
    let condition: LooseObject = {};
    condition.smsType = actionData.smsType;
    let result: Promise<number> = new Promise((resolve) => {
      this.querySessionSizeByCondition(condition, res => {
        let size: number = 0;
        if (res.code == common.int.SUCCESS && res.abilityResult != null) {
          size = res.abilityResult;
        }
        resolve(size);
      }, context);
    });
    return result;
  }

  public getSessionListResult(actionData, context): Promise<LooseObject> {
    let result: Promise<LooseObject> = new Promise((resolve) => {
      this.querySessionByCondition(actionData, res => {
        let result: LooseObject = {
          "messageList": [],
          "telephones": []
        };
        if (res.code == common.int.SUCCESS && res.abilityResult != null) {
          result = this.getConvertSessionListResult(res.abilityResult);
        }
        resolve(result);
      }, context)
    });
    return result;
  }

  public isExistNoticeMessage(context): Promise<boolean> {
    let result: Promise<boolean> = new Promise((resolve) => {
      let actionData: LooseObject = {};
      actionData.smsType = common.sms_type.NOTICE;
      this.querySessionSizeByCondition(actionData, res => {
        let isExistNoticeMessage: boolean = false;
        if (res.code == common.int.SUCCESS && res.abilityResult != null && res.abilityResult > 0) {
          isExistNoticeMessage = true;
        }
        resolve(isExistNoticeMessage);
      }, context);
    });
    return result;
  }

  public querySessionList(actionData, callback, context): void {
    let result: LooseObject = {};
    let queryPromise: Promise<LooseObject> = this.getSessionListResult(actionData, context);
    let countPromise: Promise<number> = this.getSessionListSize(actionData, context);
    let noticePromise: Promise<boolean> = this.isExistNoticeMessage(context);
    Promise.all([queryPromise, countPromise, noticePromise]).then(res => {
      result.code = common.int.SUCCESS;
      result.total = res[1];
      result.hasInfoMsg = res[2];
      result.response = [];
      HiLog.i(TAG, "querySessionList, sessionList.length: " + res[0].messageList.length + ", total=" + result.total
      + ", hasInfoMsg=" + result.hasInfoMsg);
      if (result.total > 0) {
        this.dealContactsName(res[0].telephones, actionData, res[0].messageList, res => {
          result.response = res;
          callback(result);
        }, context);
      } else {
        callback(result);
      }
    }).catch(error => {
      HiLog.e(TAG, "querySessionList, error: " + JSON.stringify(error));
      result.code = common.int.FAILURE;
      callback(result);
    });
  }

  private getConvertSessionListResult(sessionList): LooseObject {
    let result: LooseObject = {
      "messageList": [],
      "telephones": []
    };
    if (sessionList == null) {
      return result;
    }
    let messageList: Array<LooseObject> = [];
    let telephones: Array<LooseObject> = [];
    for (let session of sessionList) {
      let item: LooseObject = {};
      item.name = common.string.EMPTY_STR;
      item.contactsNum = session.contactsNum;
      item.content = session.content;
      item.countOfUnread = session.unreadCount;
      if (session.smsType == common.sms_type.COMMON) {
        item.icon = "icon/user_avatar_full_fill.svg";
      } else {
        item.icon = "icon/entrance_icon01.svg";
      }
      item.smsType = session.smsType;
      item.isCbChecked = false;
      item.isLock = false;
      item.sendingFailed = session.sendStatus == common.int.SEND_MESSAGE_FAILED ? true : false;
      item.telephone = session.telephone;
      if (item.contactsNum > 1) {
        let telephoneSplit = item.telephone.split(common.string.COMMA);
        for (let item of telephoneSplit) {
          telephones.push(item);
        }
      } else {
        telephones.push(item.telephone);
      }
      item.telephoneFormat = session.telephoneFormat;
      item.threadId = session.id;
      item.timeMillisecond = session.time;
      item.isDraft = session.hasDraft == 1 ? true : false;
      item.isLock = session.hasLock == 1 ? true : false;
      item.time = common.string.EMPTY_STR;
      item.messageCount = session.messageCount;
      item.hasMms = session.hasMms == 1 ? true : false;
      item.hasAttachment = session.hasAttachment == 1 ? true : false;
      messageList.push(item);
    }
    result.messageList = messageList;
    result.telephones = telephones;
    return result;
  }

  private dealContactsName(telephones, actionData, sessionLists, callback, context) {
    if (telephones.length == 0) {
      HiLog.w(TAG, "dealContactsName, has no telephones");
      callback(sessionLists);
      return;
    }
    actionData.telephones = telephones;
    actionData.hasDelete = "0";
    ContactService.getInstance().queryContactDataByCondition(actionData, res => {
      if (res.code == common.int.FAILURE || res.abilityResult.length == 0) {
        HiLog.w(TAG, "dealContactsName, has no contacts");
        callback(sessionLists);
      } else {
        callback(this.buildSessionNames(res.abilityResult, sessionLists));
      }
    }, context);
  }

  private buildSessionNames(contacts, sessionLists) {
    let telephoneMap = new Map();
    for (let item of contacts) {
      if (item.displayName == common.string.EMPTY_STR) {
        telephoneMap.set(item.detailInfo, item.detailInfo);
      } else {
        telephoneMap.set(item.detailInfo, item.displayName);
      }
    }
    for (let session of sessionLists) {
      if (session.contactsNum > 1) {
        this.dealMultiName(session, telephoneMap);
      } else if (telephoneMap.has(session.telephone)) {
        session.name = telephoneMap.get(session.telephone);
      }
    }
    return sessionLists;
  }

  private dealMultiName(session, telephoneMap): void {
    let telephones: Array<string> = session.telephone.split(common.string.COMMA);
    let name: string = common.string.EMPTY_STR;
    for (let telephone of telephones) {
      if (telephoneMap.has(telephone)) {
        name = name + telephoneMap.get(telephone) + common.string.COMMA;
      } else {
        name = name + telephone + common.string.COMMA;
      }
    }
    session.name = name.substring(0, name.length - 1);
  }

  public statisticalData(callBack, context): void {
    let normalPromise = new Promise<LooseObject>((resolve) => {
      ConversationService.getInstance().statisticalData(res => {
        if (res.code == common.int.SUCCESS) {
          resolve(res.abilityResult);
        } else {
          HiLog.w(TAG, "statisticalData, failed");
        }
      }, context);
    });
    let notifyPromise = new Promise<number>((resolve) => {
      ConversationService.getInstance().statisticsUnreadNotify(res => {
        resolve(res);
      }, context);
    });
    let result: LooseObject = {};
    Promise.all([normalPromise, notifyPromise]).then(res => {
      let normalResult: LooseObject = res[0];
      let notifyResult: number = res[1];
      result.code = common.int.SUCCESS;
      let response: LooseObject = {};
      response.totalListCount = normalResult.totalListCount;
      response.unreadCount = normalResult.totalListCount - notifyResult;
      response.unreadTotalOfInfo = notifyResult;
      result.response = response;
      callBack(result);
    }).catch(error => {
      HiLog.e(TAG, "statisticalData, failed: " + JSON.stringify(error));
      result.code = common.int.FAILURE;
      callBack(result);
    });
  }

  public deleteMessageById(actionData, callback, context): void {
    // Deletes data from the session list.
    this.deleteSessionByCondition(actionData, callback, context);
    // Deletes data from the information list.
    ConversationService.getInstance().deleteSmsMmsInfoByCondition(actionData, null, null);
  }

  public markAllToRead(actionData) {
    actionData.unreadCount_greaterThan = 0;
    let sessionValueBucket: LooseObject = {
      "unread_count": 0
    };
    this.updateSessionByCondition(actionData, sessionValueBucket, null, null);

    actionData.hasRead = common.is_read.UN_READ;
    let smsMmsInfoValueBucket: LooseObject = {
      "is_read": common.is_read.READ
    };
    ConversationService.getInstance().updateSmsMmsInfoByCondition(actionData, smsMmsInfoValueBucket, null, null);
  }

  /**
   * Adding a session draft list
   *
   * @param valueBucket New Data
   * @callback callback
   */
  public insertSessionDraft(actionData, callback, context): void {
    let param: LooseObject = this.dealSendResults(actionData);
    // Check whether a session list has been created
    this.querySessionByTelephone(param.telephone, res => {
      if (res.code == common.int.SUCCESS && res.response.id <= 0) {
        // If you modify the recipient in draft state and save the modification again, you need to delete the
        // unnecessary session draft before modification.
        if (actionData.threadId != 0 && actionData.isDraft) {
          this.deleteSessionByCondition(actionData, null, null);
        }
        this.dealInsertSession(param, actionData, callback, context);
      } else {
        this.deleteDraftDataOrUpdate(actionData, res.response, param, callback, context);
      }
      globalThis.needToUpdate = true;
    }, context);
  }

  public dealInsertSession(param, actionData, callback, context): void {
    let valueBucket: LooseObject = {
      "telephone": param.telephone,
      "content": param.content,
      "contacts_num": param.contactsNum,
      "sms_type": param.smsType,
      "unread_count": 0,
      "sending_status": common.int.SEND_MESSAGE_SENDING,
      "has_draft": common.has_draft.HAVE,
      "time": param.timestamp,
      "has_mms": param.hasMms,
      "has_attachment": param.hasAttachment,
    }
    this.insertSession(valueBucket, sessionResult => {
      // Invoke the SMS database to insert SMS messages.
      let sessionId: number = sessionResult.abilityResult;
      ConversationService.getInstance().dealInsertMessageDetail(param, actionData, sessionId, res => {
        callback();
      }, context);
    }, context);
  }

  public deleteDraftDataOrUpdate(actionData, response, param, callback, context): void {
    if (actionData.groupId > 0) {
      ConversationService.getInstance().deleteSmsMmsInfoByCondition(actionData, null, null);
    }
    if (actionData.content != common.string.EMPTY_STR || actionData.mmsSource.length > 0) {
      // Save New Draft
      this.updateDraftData(response, param, actionData, callback, context);
    } else {
      if (callback) {
        callback();
      }
    }
  }

  public updateDraftData(response, param, actionData, callback, context): void {
    let valueBucket: LooseObject = {
      "content": param.content,
      "has_draft": common.has_draft.HAVE,
      "time": new Date().getTime(),
      "has_attachment": param.hasAttachment,
      "has_mms": param.hasMms,
    }
    if (response == undefined || response == null) {
      return
    }
    let sessionId: number = response.id;
    let condition: LooseObject = {};
    condition.threadId = sessionId;
    this.updateSessionByCondition(condition, valueBucket, null, null);
    ConversationService.getInstance().dealInsertMessageDetail(param, actionData, sessionId, res => {
      if (callback) {
        callback();
      }
    }, context);
  }

  public dealSendResults(actionData): LooseObject {
    let contactsNum: number = 1;
    let telephone: string = common.string.EMPTY_STR;
    if (actionData.isNewMsg) {
      let selectContacts = actionData.selectContacts;
      if (selectContacts.length > 1) {
        for (let contact of selectContacts) {
          telephone = telephone + contact.telephone + common.string.COMMA;
        }
        // If it fails, then the session list turns out to be a failure.
        telephone = telephone.substring(0, telephone.length - 1);
        contactsNum = selectContacts.length;
      } else if (selectContacts.length == 1) {
        telephone = selectContacts[0]?.telephone;
      }
      let receiveContactValue = actionData.receiveContactValue;
      if (receiveContactValue != common.string.EMPTY_STR) {
        telephone = actionData.receiveContactValue;
      }
    } else {
      telephone = actionData.telephone;
    }
    let smsType: number = common.sms_type.COMMON;
    if (contactsNum == 1 && telephoneUtils.judgeIsInfoMsg(telephone)) {
      smsType = common.sms_type.NOTICE;
    }
    let sendResult: LooseObject = {
      telephone: telephone,
      content: actionData.content,
      sendStatus: common.int.SEND_DRAFT
    }
    actionData.sendResults = [sendResult];
    let timestamp = new Date().getTime();
    let result: LooseObject = {};
    result.contactsNum = contactsNum;
    result.telephone = telephoneUtils.dealTelephoneSort(telephone);
    result.content = actionData.content;
    if (actionData.isMms) {
      result.content = commonService.getMmsContent(actionData.mmsSource);
    }
    result.sendStatus = common.int.SEND_MESSAGE_SENDING;
    result.smsType = smsType;
    result.timestamp = timestamp;
    result.hasMms = actionData.isMms ? 1 : 0;
    result.hasAttachment = actionData.hasAttachment ? 1 : 0;

    return result;
  }

  public querySessionByTelephone(telephone, callback, context): void {
    let result: LooseObject = {};
    if (telephone == null) {
      HiLog.w(TAG, "querySessionByTelephone, telephone is null!");
      result.code = common.int.FAILURE;
      callback(result);
    } else {
      HiLog.i(TAG, "querySessionByTelephone, telephone != null");
      let actionData: LooseObject = {};
      actionData.telephone = telephone;
      this.querySessionByCondition(actionData, res => {
        if (res.code == common.int.FAILURE) {
          callback(res);
        } else {
          result.code = common.int.SUCCESS;
          result.response = res.abilityResult[0];
          callback(result);
        }
      }, context);
    }
  }

  public dealMessageLockContent(actionData, callback, context): void {
    let threadIds = actionData.threadIds;
    let length: number = threadIds.length;
    let count: number = 0;
    for (let id of threadIds) {
      actionData.threadId = id;
      if (!actionData.isMessageDetail) {
        actionData.hasLock = 1;
      }
      ConversationService.getInstance().queryMessageDetail(actionData, res => {
        if (res.code == common.int.SUCCESS && res.response.length > 0) {
          count++;
          actionData.mmsList = res.response;
          this.updateLastItemContent(actionData, null, null);
        }
        if (count == length) {
          callback(common.int.SUCCESS);
        }
      }, context);
    }
  }

  public updateLastItemContent(actionData, callback, context): void {
    let valueBucket: LooseObject = {
      "content": common.string.EMPTY_STR,
      "sending_status": common.int.SEND_MESSAGE_FAILED,
      "has_mms": common.has_mms.NO,
      "has_attachment": common.has_attachment.NO,
      "message_count": 0,
      "unread_count": 0
    };
    let length: number = actionData.mmsList.length;
    if (length > 0) {
      let item: LooseObject = actionData.mmsList[length - 1];
      valueBucket.content = item.isMsm ? commonService.getMmsContent(item.mms) : item.content;
      valueBucket.sending_status = item.sendStatus;
      valueBucket.has_mms = item.isMsm ? common.has_mms.HAVE : common.has_mms.NO;
      valueBucket.has_attachment = item.isMsm ? common.has_attachment.HAVE : common.has_attachment.NO;
      valueBucket.message_count = length;
    }
    let condition: LooseObject = {
      threadId: actionData.threadId
    };
    this.updateSessionByCondition(condition, valueBucket, callback, context);
  }
}