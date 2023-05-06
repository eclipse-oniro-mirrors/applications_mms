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

import ConversationModel from "../model/ConversationModel";
import common from "../data/commonData";
import HiLog from "../utils//HiLog";
import ConversationListService from "./ConversationListService";
import telephoneUtils from "../utils/TelephoneUtil";
import ContactsService from "./ContactsService";
import LooseObject from "../data/LooseObject";

const TAG: string = "ConversationService";

export default class ConversationService {
  private static instance: ConversationService;
  private conversationModel: ConversationModel = new ConversationModel();

  private constructor() {
  }

  public static getInstance(): ConversationService {
    if (ConversationService.instance == null) {
      ConversationService.instance = new ConversationService();
    }
    return ConversationService.instance;
  }

  public insertSmsMmsInfo(valueBucket, callback, context): void {
    let mmsContext = context ? context : globalThis.mmsContext;
    if (globalThis.DataWorker != null) {
      globalThis.DataWorker.sendRequest(common.RUN_IN_WORKER_METHOD.insertSmsMmsInfo, {
        valueBucket: valueBucket,
        context: mmsContext
      }, res => {
        if (callback) {
          callback(res);
        }
      });
    } else {
      this.conversationModel.insertSmsMmsInfo(valueBucket, callback, mmsContext);
    }
  }

  public deleteSmsMmsInfoByCondition(actionData, callback, context): void {
    let mmsContext = context ? context : globalThis.mmsContext;
    if (globalThis.DataWorker != null) {
      globalThis.DataWorker.sendRequest(common.RUN_IN_WORKER_METHOD.deleteSmsMmsInfoByCondition, {
        actionData: actionData,
        context: mmsContext
      }, res => {
        if (callback) {
          callback(res);
        }
      });
    } else {
      this.conversationModel.deleteSmsMmsInfoByCondition(actionData, callback, mmsContext);
    }
  }

  public updateSmsMmsInfoByCondition(actionData, valueBucket, callback, context): void {
    let mmsContext = context ? context : globalThis.mmsContext;
    if (globalThis.DataWorker != null) {
      globalThis.DataWorker.sendRequest(common.RUN_IN_WORKER_METHOD.updateSmsMmsInfoByCondition, {
        actionData: actionData,
        valueBucket: valueBucket,
        context: mmsContext
      }, res => {
        if (callback) {
          callback(res);
        }
      });
    } else {
      this.conversationModel.updateSmsMmsInfoByCondition(actionData, valueBucket, callback, mmsContext);
    }
  }

  public querySmsMmsInfoByCondition(actionData, callback, context): void {
    let mmsContext = context ? context : globalThis.mmsContext;
    if (globalThis.DataWorker != null) {
      globalThis.DataWorker.sendRequest(common.RUN_IN_WORKER_METHOD.querySmsMmsInfoByCondition, {
        actionData: actionData,
        context: mmsContext
      }, res => {
        callback(res);
      });
    } else {
      this.conversationModel.querySmsMmsInfoByCondition(actionData, callback, mmsContext);
    }
  }

  public querySmsMmsInfoSizeByCondition(actionData, callback, context): void {
    let mmsContext = context ? context : globalThis.mmsContext;
    if (globalThis.DataWorker != null) {
      globalThis.DataWorker.sendRequest(common.RUN_IN_WORKER_METHOD.querySmsMmsInfoSizeByCondition, {
        actionData: actionData,
        context: mmsContext
      }, res => {
        callback(res);
      });
    } else {
      this.conversationModel.querySmsMmsInfoSizeByCondition(actionData, callback, mmsContext);
    }
  }

  public statisticalData(callback, context) {
    let mmsContext = context ? context : globalThis.mmsContext;
    if (globalThis.DataWorker != null) {
      globalThis.DataWorker.sendRequest(common.RUN_IN_WORKER_METHOD.statisticalData, {
        context: mmsContext
      }, res => {
        callback(res);
      });
    } else {
      this.conversationModel.statisticalData(callback, mmsContext);
    }
  }

  public queryMaxGroupId(callback, context): void {
    let mmsContext = context ? context : globalThis.mmsContext;
    if (globalThis.DataWorker != null) {
      globalThis.DataWorker.sendRequest(common.RUN_IN_WORKER_METHOD.queryMaxGroupId, {
        context: mmsContext
      }, res => {
        callback(res);
      });
    } else {
      this.conversationModel.queryMaxGroupId(callback, mmsContext);
    }
  }

  public queryMessageDetail(actionData, callback, context): void {
    this.querySmsMmsInfoByCondition(actionData, res => {
      let result: LooseObject = {};
      result.code = res.code;
      if (res.code == common.int.SUCCESS) {
        this.groupDetailMessage(res.abilityResult, actionData, resultList => {
          result.response = resultList;
          callback(result);
        });
      } else {
        HiLog.w(TAG, "queryMessageDetail, failed");
        callback(result);
      }
    }, context);
  }

  public convertConversationList(mmsList): Array<LooseObject> {
    let resultList: Array<LooseObject> = [];
    for (let item of mmsList) {
      let result: LooseObject = {};
      result.id = item.msgId;
      result.content = item.msgContent;
      result.isLock = item.isLock == 0 ? false : true;
      result.isStared = item.isCollect == 0 ? false : true;
      // Fields related to MMS messages
      result.msgType = 0;
      result.isFullScreenImg = true;
      result.read = item.isRead == 0 ? "0" : "1";
      if (item.msgState == 0) {
        result.sendStatus = common.int.SEND_MESSAGE_SUCCESS;
      } else if (item.msgState == 2) {
        result.sendStatus = common.int.SEND_MESSAGE_FAILED;
      } else if (item.msgState == 1) {
        result.sendStatus = common.int.SEND_MESSAGE_SENDING;
      } else {
        result.sendStatus = common.int.SEND_DRAFT;
      }
      result.subId = item.slotId;
      result.timeMillisecond = item.startTime;
      result.isMsm = item.msgType == 0 ? false : true;
      result.isCbChecked = false;
      result.isDraft = false;
      // Fields related to group-sending
      result.groupId = item.groupId;
      // Determine whether it is the receiver or sender.
      result.isReceive = item.isSender == 0 ? false : true;
      result.date = common.string.EMPTY_STR;
      result.time = common.string.EMPTY_STR;
      result.completeNumber = 0;
      result.failuresNumber = 0;
      result.hasReport = item.isSendReport == 0 ? false : true;
      if (!result.isMsm) {
        result.msgShowType = common.MESSAGE_SHOW_TYPE.NORMAL;
      }
      resultList.push(result);
    }
    return resultList;
  }

  public groupDetailMessage(mmsList, actionData, callback): void {
    let details: Array<LooseObject> = this.convertConversationList(mmsList);
    if (actionData.contactsNum == 1) {
      callback(details);
      return;
    }
    let resultList: Array<LooseObject> = [];
    // Group by groupId.
    let detailMap = this.convertConversationMap(details);
    // By group
    let groupIds = detailMap.keys();
    for (let groupId of groupIds) {
      let groups = detailMap.get(groupId);
      let result: LooseObject = groups[0];
      let failuresNumber = 0;
      let completeNumber = 0;
      for (let item of groups) {
        if (item.sendStatus == common.int.SEND_MESSAGE_FAILED) {
          failuresNumber++;
        }
        if (item.sendStatus == common.int.SEND_MESSAGE_FAILED || item.sendStatus == common.int.SEND_MESSAGE_SUCCESS) {
          completeNumber++;
        }
      }
      result.completeNumber = completeNumber;
      result.failuresNumber = failuresNumber;
      resultList.push(result);
    }
    callback(resultList);
  }

  public convertConversationMap(details) {
    let conversationMap = new Map();
    // grouping
    for (let element of details) {
      if (conversationMap.has(element.groupId)) {
        let groups = conversationMap.get(element.groupId);
        groups.push(element);
      } else {
        let groups = [];
        groups.push(element);
        conversationMap.set(element.groupId, groups);
      }
    }
    return conversationMap;
  }

  public insertSessionAndDetail(actionData, callback, context): void {
    let sendResults: Array<LooseObject> = actionData.sendResults;
    let isReceive: boolean = actionData.isReceive;
    if (sendResults.length == 0) {
      HiLog.w(TAG, "insertSessionAndDetail, sendResults.length == 0");
      return;
    }
    let param: LooseObject = this.dealSendResults(sendResults);
    // Check whether a session list has been created.
    ConversationListService.getInstance().querySessionByTelephone(param.telephone, res => {
      let response: LooseObject = res.response;
      if (res.code == common.int.SUCCESS && response.id <= 0) {
        this.dealNoExistSession(isReceive, param, actionData, callback, context);
      } else {
        this.dealExistSession(response, param, actionData, callback, context);
      }
    }, context);
  }

  public dealNoExistSession(isReceive, param, actionData, callback, context): void {
    let unreadCount: number = 0;
    if (isReceive) {
      unreadCount = 1;
    }
    let valueBucket: LooseObject = {
      "telephone": param.telephone,
      "content": param.content,
      "contacts_num": param.contactsNum,
      "sms_type": param.smsType,
      "unread_count": unreadCount,
      "sending_status": param.sendStatus,
      "has_draft": common.has_draft.NO,
      "time": param.timestamp,
      "message_count": 1,
      "has_mms": actionData.isMms ? common.has_mms.HAVE : common.has_mms.NO,
      "has_attachment": actionData.hasAttachment ? common.has_attachment.HAVE : common.has_attachment.NO
    }
    ConversationListService.getInstance().insertSession(valueBucket, sessionResult => {
      HiLog.i(TAG, "dealNoExistSession, insertSession callback");
      if (sessionResult.code == common.int.FAILURE) {
        HiLog.e(TAG, "dealNoExistSession, insertSession fail!");
        callback(sessionResult);
        return;
      }
      // Invoke the SMS database to insert SMS messages.
      this.dealInsertMessageDetail(param, actionData, sessionResult.abilityResult, res => {
        let result: LooseObject = {
          "rowId": sessionResult.abilityResult,
          "initDatas": res.initDatas,
          "groupId": res.groupId
        }
        callback(result);
      }, context);
    }, context);
  }

  public dealExistSession(response, param, actionData, callback, context): void {
    let unreadCount: number = 0;
    if (actionData.isReceive) {
      unreadCount = response.unreadCount + 1;
    }
    let hasDraft: number = response.hasDraft;
    if (actionData.hasDraft && hasDraft == 1) {
      hasDraft = 0;
    }
    let valueBucket: LooseObject = {
      "content": param.content,
      "unread_count": unreadCount,
      "time": new Date().getTime(),
      "sending_status": param.sendStatus,
      "has_draft": hasDraft,
      "message_count": (response.messageCount + 1),
      "has_attachment": actionData.hasAttachment ? 1 : 0,
      "has_mms": actionData.isMms ? 1 : 0,
    }
    let sessionId: number = response.id;
    let condition: LooseObject = {};
    condition.threadId = sessionId;
    ConversationListService.getInstance().updateSessionByCondition(condition, valueBucket, res => {
      // Invoke the SMS database to insert SMS messages.
      this.dealInsertMessageDetail(param, actionData, sessionId, res => {
        let result: LooseObject = {
          "rowId": sessionId,
          "initDatas": res.initDatas,
          "groupId": res.groupId
        }
        callback(result);
      }, context);
    }, context);
  }

  public dealInsertMessageDetail(param, actionData, threadId, callback, context): void {
    this.queryMaxGroupId(res => {
      let maxGroupId: number = 0;
      if (res.code == common.int.SUCCESS) {
        maxGroupId = Number(res.abilityResult) + 1;
      } else {
        HiLog.w(TAG, "dealInsertMessageDetail, queryMaxGroupId failed");
        callback(res);
      }
      this.insertMessageDetailByMaxGroupId(param, actionData, threadId, maxGroupId, result => {
        callback(result);
      }, context);
    }, context);
  }

  private insertMessageDetailByMaxGroupId(param, actionData, threadId, maxGroupId, callback, context): void {
    let count: number = 0;
    let initDatas: Array<LooseObject> = [];
    let result: LooseObject = {};
    result.groupId = maxGroupId;
    let sendResults = actionData.sendResults;
    sendResults.forEach(sendResult => {
      let valueBucket: LooseObject = this.buildInsertSmsMmsRow(param, actionData, sendResult, threadId, maxGroupId);
      this.insertSmsMmsInfo(valueBucket, res => {
        count++;
        let initData: LooseObject = {
          "id": res.abilityResult,
          "telephone": sendResult.telephone
        };
        initDatas.push(initData);
        if (count == actionData.sendResults.length) {
          result.initDatas = initDatas;
          callback(result);
        }
      }, context);
    });
  }

  private buildInsertSmsMmsRow(param, actionData, sendResult, threadId, maxGroupId): LooseObject {
    let valueBucket: LooseObject = {
      "slot_id": common.int.SIM_ONE,
      "receiver_number": common.string.EMPTY_STR,
      "sender_number": common.string.EMPTY_STR,
      "start_time": common.string.EMPTY_STR,
      "end_time": common.string.EMPTY_STR,
      "msg_type": common.MESSAGE_TYPE.NORMAL,
      "sms_type": common.sms_type.COMMON,
      "msg_title": common.string.EMPTY_STR,
      "msg_content": common.string.EMPTY_STR,
      "msg_state": common.int.SEND_MESSAGE_SENDING,
      "operator_service_number": common.string.EMPTY_STR,
      "msg_code": common.string.EMPTY_STR,
      "session_id": threadId,
      "is_lock": common.is_lock.NO,
      "is_read": common.is_read.UN_READ,
      "is_collect": common.is_collect.NOT_FAVORITE,
      "session_type": common.session_type.COMMON,
      "is_sender": common.is_sender.NO,
      "group_id": maxGroupId,
      "is_send_report": common.is_send_report.NO
    };
    if (sendResult.slotId != null) {
      valueBucket.slot_id = sendResult.slotId;
    }
    if (actionData.isReceive) {
      valueBucket.receiver_number = actionData.ownNumber ? actionData.ownNumber : common.string.EMPTY_STR;
      valueBucket.sender_number = sendResult.telephone ? sendResult.telephone : common.string.EMPTY_STR;
      valueBucket.is_read = common.is_read.UN_READ;
    } else {
      valueBucket.receiver_number = sendResult.telephone ? sendResult.telephone : common.string.EMPTY_STR;
      valueBucket.sender_number = actionData.ownNumber ? actionData.ownNumber : common.string.EMPTY_STR;
      valueBucket.is_read = common.is_read.READ;
    }
    let time: string = sendResult.time;
    if (time == null) {
      time = new Date().getTime() + common.string.EMPTY_STR;
    }
    valueBucket.start_time = time;
    valueBucket.end_time = time;
    if (param.isMms != null && param.isMms) {
      valueBucket.msg_type = common.MESSAGE_TYPE.THEME;
    }
    if (param.smsType != null) {
      valueBucket.sms_type = param.smsType;
    }
    if (param.content != null) {
      valueBucket.msg_title = param.content;
      valueBucket.msg_content = param.content;
    }
    if (sendResult.sendStatus != null) {
      valueBucket.msg_state = sendResult.sendStatus;
    }
    if (actionData.isSender != null) {
      valueBucket.is_sender = actionData.isSender;
    }
    if (actionData.hasReport != null) {
      valueBucket.is_send_report = actionData.hasReport;
    }
    return valueBucket;
  }

  public dealSendResults(sendResults: Array<LooseObject>): LooseObject {
    let contactsNum: number = sendResults.length;
    let telephone: string = common.string.EMPTY_STR;
    let content: string = common.string.EMPTY_STR;
    let sendStatus: number = common.int.SEND_MESSAGE_SUCCESS;
    let failSum: number = 0;
    let time: string = common.string.EMPTY_STR;
    for (let sendResult of sendResults) {
      telephone = telephone + sendResult.telephone + common.string.COMMA;
      content = sendResult.content;
      sendStatus = sendResult.sendStatus;
      if (sendResult.sendStatus == common.int.SEND_MESSAGE_FAILED) {
        failSum++;
      }
      if (sendResult.time != null) {
        time = sendResult.time;
      }
      if (sendResult.isMessageSim != null && sendResult.isMessageSim) {
        telephone = sendResult.telephone;
        contactsNum = 1;
      }
    }
    // If it fails, then the session list turns out to be a failure.
    if (failSum > 0) {
      sendStatus = common.int.SEND_MESSAGE_FAILED;
    }
    telephone = telephone.substring(0, telephone.length - 1);
    let smsType: number = common.sms_type.COMMON;
    if (contactsNum == 1 && telephoneUtils.judgeIsInfoMsg(telephone)) {
      smsType = common.sms_type.NOTICE;
    }
    let result: LooseObject = {};
    let timestamp: number = new Date().getTime();
    result.contactsNum = contactsNum;
    result.content = content;
    result.telephone = telephoneUtils.dealTelephoneSort(telephone);
    result.sendStatus = sendStatus;
    result.timestamp = time != common.string.EMPTY_STR ? time : timestamp;
    result.smsType = smsType;
    return result;
  }

  public updateSessionAndDetail(actionData): void {
    let sendResults: Array<LooseObject> = actionData.sendResults;
    if (sendResults.length == 0) {
      return;
    }
    let param: LooseObject = this.dealSendResults(sendResults);
    // Update the status of the session list.
    let valueBucket: LooseObject = {
      "sending_status": param.sendStatus,
      "content": param.content
    }
    ConversationListService.getInstance().updateSessionByCondition(actionData, valueBucket, null, null);
    // Update the status of the information list.
    for (let sendResult of sendResults) {
      actionData.sendStatus = sendResult.sendStatus;
      if (sendResult.sendStatus == common.int.SEND_MESSAGE_FAILED) {
        actionData.sendStatus = common.int.SEND_MESSAGE_FAILED;
      } else if (sendResult.sendStatus == common.int.SEND_MESSAGE_SUCCESS) {
        actionData.sendStatus = common.int.SEND_MESSAGE_SUCCESS;
      } else {
        actionData.sendStatus = common.int.SEND_MESSAGE_SENDING;
      }
      actionData.msgId = sendResult.id;
      let valueBucket: LooseObject = {
        "msg_state": actionData.sendStatus,
      };
      this.updateSmsMmsInfoByCondition(actionData, valueBucket, null, null);
    }
  }

  public saveImage(actionData, callback, context): void {
    callback("saveImage function to be developed!");
  }

  public gotoShare(actionData, callback, context): void {
    callback("gotoShare function to be developed!");
  }

  public dealContactsName(telephones, actionData, resultList, callback, context): void {
    actionData.telephones = telephones;
    actionData.hasDelete = "0";
    if (telephones.length == 0) {
      callback(resultList);
    }
    ContactsService.getInstance().queryContactDataByCondition(actionData, res => {
      let groupIdMap: LooseObject = {};
      if (res.code == common.int.FAILURE || res.abilityResult.length == 0) {
        groupIdMap = this.convertingMessageByGroup(resultList);
      } else {
        // Convert the result to Map, key: mobile number, value: name
        let telephoneMap = new Map();
        let contacts: Array<LooseObject> = res.abilityResult;
        for (let item of contacts) {
          if (item.displayName == common.string.EMPTY_STR) {
            telephoneMap.set(item.detailInfo, item.detailInfo);
          } else {
            telephoneMap.set(item.detailInfo, item.displayName);
          }
        }
        // Match the result based on the mobile number.
        groupIdMap = this.getGroupIdMap(resultList, telephoneMap);
      }
      let lists = [];
      let favoriteList = [];
      for (let key of Object.keys(groupIdMap)) {
        let value = groupIdMap[key];
        let contactsNums = value.telephone.split(common.string.COMMA);
        value.contactsNum = contactsNums.length;
        if (value.isFavorite) {
          let temp = JSON.parse(JSON.stringify(value));
          temp.icon = "/common/icon/icon_favorite.svg";
          favoriteList.push(temp);
          value.isFavorite = false;
        }
        lists.push(value);
      }
      // Add favorite data to the search list.
      if (favoriteList.length > 0) {
        lists = lists.concat(favoriteList);
      }
      callback(lists);
    }, context);
  }

  public getGroupIdMap(resultList, telephoneMap): LooseObject {
    let groupIdMap: LooseObject = {};
    for (let map of resultList) {
      // Indicates the combination of multiple names. The names need to be displayed in combination.
      if (telephoneMap.has(map.telephone)) {
        map.name = telephoneMap.get(map.telephone);
        map.nameFormatter = map.name + "<" + map.telephoneFormat + ">";
      } else {
        map.nameFormatter = map.telephoneFormat;
      }
      if (Object.keys(groupIdMap).indexOf(map.groupId) > -1) {
        let list = groupIdMap[map.groupId];
        list.name = list.name + common.string.COMMA + map.name;
        list.nameFormatter = list.nameFormatter + common.string.COMMA + map.nameFormatter;
        list.telephone = list.telephone + common.string.COMMA + map.telephone;
        list.telephoneFormat = list.telephoneFormat + common.string.COMMA + map.telephoneFormat;
      } else {
        groupIdMap[map.groupId] = map;
      }
    }
    return groupIdMap;
  }

  public convertingMessageByGroup(resultList): LooseObject {
    let groupIdMap: LooseObject = {};
    for (let element of resultList) {
      if (Object.keys(groupIdMap).indexOf(element.groupId) == -1) {
        groupIdMap[element.groupId] = element;
      }
    }
    return groupIdMap;
  }

  public statisticsUnreadNotify(callback, context): void {
    let actionData: LooseObject = {};
    actionData.hasRead = common.is_read.UN_READ;
    actionData.smsType = common.sms_type.NOTICE;
    this.querySmsMmsInfoSizeByCondition(actionData, res => {
      if (res.code == common.int.SUCCESS) {
        callback(res.abilityResult);
      } else {
        HiLog.w(TAG, "statisticsUnreadNotify fail!");
        callback(0);
      }
    }, context);
  }
}