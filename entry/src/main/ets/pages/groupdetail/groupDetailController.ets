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

import HiLog from '../../utils/HiLog';
import LooseObject from '../../data/LooseObject';
import GroupDetailService from '../../service/GroupDetailService';
import common from '../../data/commonData';
import lazy { DateUtil } from '../../utils/DateUtil';
import AvatarColor from '../../model/common/AvatarColor';
import conversationService from '../../service/ConversationService';
import sendMsgService from '../../service/SendMsgService';
import ConversationListService from '../../service/ConversationListService';
import commonService from '../../service/CommonService';
import MmsPreferences from '../../utils/MmsPreferences';
import Prompt from '@system.prompt';
import { BusinessError } from '@ohos.base';
import { ActionData } from '../conversationlist/conversationListController';
import { GlobalContext } from '../../MainAbility/GlobalHelper';
import myCommon from '@ohos.app.ability.common';
import ConversationController, {
  mmsListType,
} from '../conversation/conversationController';
import DotUtil from '../../utils/MmsDot/DotUtils';
import dotCommon from '../../utils/MmsDot/DotCommon';

const TAG = 'GroupDetailController';

let groupDetailCtrl:GroupDetailController;

export default class GroupDetailController {
  // ID of the session list.
  threadId: number = 0;
  // group ID
  groupId: number = 0;
  // reSend content
  content: string = '';
  // Card slot
  slotId: number = 0;
  // total number of records sent
  sendAllCount: number = 0;
  // send SMS related data
  groupList: Array<mmsListType> = [];
  // whether to resend
  isAllResendBtnShow: boolean = false;
  // resend index
  resendIndex: number = -1;
  // 返回会话详情页之前是否需要刷新状态（重新发送按钮触发后需要刷新下详情页）
  isNeedRefreshBeforeBack: boolean = false;
  groupDetailService: GroupDetailService = GroupDetailService.getInstance();
  resendCount: number = 0;
  numberReg: RegExp = new RegExp('^[0-9]+$');
  pageInfos: NavPathStack = new NavPathStack();
  mConversationCtrl: ConversationController = ConversationController.getInstance();

  static getInstance() {
    if (groupDetailCtrl == null) {
      groupDetailCtrl = new GroupDetailController();
    }
    return groupDetailCtrl;
  }

  onInit(pageInfos: NavPathStack) {
    HiLog.i(TAG, 'onInit');
    this.pageInfos = pageInfos;
    this.initRouterData();
  }

  onShow(context: Context) {
    this.groupList = [];
    this.queryContactSendDetail(context);
  }

  onBackPress(context: Context) {
    HiLog.i(TAG, 'onBackPress');
    this.pageInfos.pop();
    if (this.isNeedRefreshBeforeBack) {
      GlobalContext.getContext().setObject('conversationNeedToUpdate', true);
      this.mConversationCtrl.refreshConversationData(context);
    }
    return true;
  }

  initRouterData() {
    let routerParams: Array<LooseObject> = this.pageInfos.getParamByName('GroupDetail') as Array<LooseObject>;
    this.threadId = routerParams[0].threadId;
    this.groupId = routerParams[0].groupId;
    this.content = routerParams[0].content;
    this.slotId = routerParams[0].slotId;
  }

  queryContactSendDetail(context: Context) {
    let actionData: LooseObject = {};
    actionData.threadId = this.threadId;
    actionData.groupId = this.groupId;
    // query the contact list details
    this.groupDetailService.queryContactGroupDetail(context, actionData, (result: LooseObject) => {
      let code:number = result.code;
      if (code == common.int.SUCCESS) {
        HiLog.i(TAG, 'queryContactSendDetail Success');
        this.convertTime(result.contactList);
        this.groupList = result.contactList;
        this.setAllResendBtnState();
      } else {
        HiLog.i(TAG, 'Error: queryContactSendDetail() failed');
      }
    });
  }

  convertTime(groupList: mmsListType[]) {
    for(let item of groupList) {
      DateUtil.convertTimeStampToDateWeek(item, false);
      DateUtil.convertDateFormatForItem(item);
    }
  }

  setAllResendBtnState () {
    let count: number = 0;
    let hasSendFail: boolean = false;
    for (let element of this.groupList) {
      if (element.sendStatus === common.int.SEND_MESSAGE_FAILED) {
        hasSendFail = true;
      } else {
        count ++;
      }
    }
    if (count === this.groupList.length) {
      hasSendFail = false;
    }
    this.isAllResendBtnShow = hasSendFail;
  }

  resendAll(context: Context) {
    let telephones: string[] = [];
    let contactFailedList: Array<mmsListType> = [];
    let contactOtherList: Array<mmsListType> = [];
    this.resendIndex = -1;
    // 重新发送后退出需要刷新下详情页
    this.isNeedRefreshBeforeBack = true;
    let time = new Date().getTime();
    this.groupList.forEach((item) => {
      if (item.sendStatus == common.int.SEND_MESSAGE_FAILED) {
        telephones.push(item.telephone);
        item.sendStatus = common.int.SEND_MESSAGE_SENDING;
        // update status to sending
        this.updateItemStatus(context, item, common.int.SEND_MESSAGE_SENDING, time);
        contactFailedList.push(item);
      } else {
        contactOtherList.push(item);
      }
    });
    this.refreshGroupList();
    this.updateConversationListStatus(context, common.int.SEND_MESSAGE_SENDING, time);

    this.groupList = contactFailedList.concat(contactOtherList);
    this.setAllResendBtnState();

    this.resendCount = 0;
    contactFailedList.forEach((item: mmsListType) => {
      this.resendSms(context, item, this.content, contactFailedList.length);
    });
  }

  updateItemStatus(context: Context, item:LooseObject, sendStatus:number, startTime?:number) {
    let actionData: Record<string,string> = {
      'msgId': item.id
    }
    let valueBucket: Record<string, number> = {
      'msg_state': sendStatus
    };
    if (startTime) {
      valueBucket['start_time'] = startTime;
      valueBucket['end_time'] = startTime;
    }
    // update status to conversation
    conversationService.getInstance().updateSmsMmsInfoByCondition(context, actionData, valueBucket, null);

    let deliveryReportSwitch: string = MmsPreferences.getInstance().getValueOfDeliveryReportSwitch();
    HiLog.i(TAG, 'updateDetail, sendStatus=' + sendStatus + ', deliveryReportSwitch=' + deliveryReportSwitch);
    if ((deliveryReportSwitch == common.DELIVERY_REPORTS.SMS_AND_MMS ||
    deliveryReportSwitch == common.DELIVERY_REPORTS.SMS) && sendStatus == common.int.SEND_MESSAGE_SUCCESS) {
      let msg: string = item.telephone;
      let receiveResource: Resource = $r('app.string.message_received', msg)
      let receivedMsg: string = (GlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext).resourceManager.getStringSync(receiveResource, msg);
      this.showToast(receivedMsg);
    }
  }

  showToast(msg:string) {
    Prompt.showToast({
      message: msg,
      duration: 2000
    });
  }

  updateConversationListStatus(context: Context, sendStatus:number, time?:number) {
    let valueBucket: Record<string, number> = {
      'sending_status': sendStatus
    }
    if (time) {
      valueBucket['time'] = time;
    }
    //update status to conversationList
    let condition: LooseObject = {};
    condition.threadId = this.threadId;
    ConversationListService.getInstance()
      .updateSessionByCondition(context, condition, valueBucket, () => {}, true);
    GlobalContext.getContext().setObject('needToUpdate', true);
  }

  resendSms(context: Context, item: mmsListType, content:string, telephoneLength:number) {
    let params: Record<string,number|string> = {
      'slotId': this.slotId,
      'destinationHost': item.telephone,
      'content': content
    };
      // 收发成功率打点-开始发送
      DotUtil.getInstance().reportSuccessRateForSendStart(dotCommon.smsReceiveRecord.SUCCESS_RATE_TYPE_SMS);
      sendMsgService.sendMessage(params, (sendStatus:number) => {
        HiLog.i(TAG, 'group detail send message status: ' + sendStatus);
        setTimeout(() => {
          this.dealSendResult(context, sendStatus, item, telephoneLength);
          this.setAllResendBtnState();
          if (sendStatus === common.int.SEND_MESSAGE_SUCCESS) {
            // Sms 消息发送成功打点
            DotUtil.getInstance().reportSuccessRateForSendFinished(dotCommon.smsReceiveRecord.SUCCESS_RATE_TYPE_SMS);
          }
        }, 500);
      });
  }

  refreshGroupList() {
    let list = this.groupList.splice(0);
    this.groupList.splice(0, this.groupList.length, ...list);
  }

  dealSendResult(context: Context, result:number, item: mmsListType, telephoneLength:number) {
    this.resendCount ++;
    // update database and item status
    item.sendStatus = result;
    let time = new Date().getTime();
    item.time = $r('app.string.justNow');
    item.timeMillisecond = time;
    DateUtil.convertTimeStampToDateWeek(item, false);
    DateUtil.fullDate(item);
    // update conversation item status
    this.updateItemStatus(context, item, item.sendStatus);

    // resend single mms refresh item
    if (this.resendIndex >= 0 && this.groupList.length > this.resendIndex) {
      this.groupList[this.resendIndex] = item;
    } else {
      this.refreshGroupList();
    }
    this.resendIndex = -1;

    // update conversation list status
    if (this.resendCount === telephoneLength) {
      let failedNumber: number = 0;
      let hasSending: boolean = false;
      for (let groupItem of this.groupList) {
        if (groupItem.sendStatus === common.int.SEND_MESSAGE_SENDING) {
          hasSending = true;
          break;
        }
        if (groupItem.sendStatus === common.int.SEND_MESSAGE_FAILED) {
          failedNumber ++;
        }
      }
      if (hasSending) {
        this.updateConversationListStatus(context, common.int.SEND_MESSAGE_SENDING);
      } else if (failedNumber === 0) {
        this.updateConversationListStatus(context, common.int.SEND_MESSAGE_SUCCESS);
      } else {
        this.updateConversationListStatus(context, common.int.SEND_MESSAGE_FAILED);
      }
    }
  }

  getPhotoName(index: number): string {
    // get first name initials
    let photoFirstName: string = common.STR.EMPTY_STR;
    if (this.groupList.length > index) {
      let group: LooseObject = this.groupList[index];
      let photoNames: Array<LooseObject> = group.photoFirstNames;
      if (photoNames.length > 0) {
        let photoName: LooseObject = photoNames[0];
        photoFirstName = photoName.firstName;
      }
    }
    return photoFirstName;
  }

  getPortraitColor(index: number): Resource {
    // Obtain the background color of the avatar
    let length: number = AvatarColor.background.Color.length;
    let color: Resource = AvatarColor.background.Color[0];
    color = AvatarColor.background.Color[this.threadId % length];
    if (this.groupList.length > index) {
      let group: LooseObject = this.groupList[index];
      let photoNames: Array<LooseObject> = group.photoFirstNames;
      if (photoNames.length > 0) {
        let photoName: LooseObject = photoNames[0];
        if (photoName.portraitColor && photoName.portraitColor !== common.STR.EMPTY_STR) {
          color = photoName.portraitColor;
        } else if (group.telephone !== common.STR.EMPTY_STR && this.numberReg.test(group.telephone.substring(group.telephone.length - 1))) {
          let lastNumber: string = group.telephone.substring(group.telephone.length - 1);
          color = AvatarColor.background.Color[Number(lastNumber) % 6];
        }
      }
    }
    return color;
  }

  setResendIndex(index: number) {
    this.resendIndex = index;
  }

  resendMsg(context: Context) {
    if (this.resendIndex < 0 || this.groupList.length <= this.resendIndex) {
      return;
    }
    // 重新发送后退出需要刷新下详情页
    this.isNeedRefreshBeforeBack = true;
    let item = this.groupList[this.resendIndex];
    item.sendStatus = common.int.SEND_MESSAGE_SENDING;
    this.groupList.splice(this.resendIndex, 1, item);
    this.refreshGroupList();
    this.setAllResendBtnState();
    let time = new Date().getTime();
    // update status to sending
    this.updateItemStatus(context, item, common.int.SEND_MESSAGE_SENDING, time);
    this.updateConversationListStatus(context, common.int.SEND_MESSAGE_SENDING, time);

    this.resendCount = 0;
    this.resendSms(context, item as mmsListType, this.content, 1);
  }

  clickToContactDetail(index: number) {
    let contact = this.groupList[index];
    let actionData: ActionData = {};
    actionData.phoneNumber = contact.telephone;
    actionData.pageFlag = common.contactPage.PAGE_FLAG_CONTACT_DETAILS;
    this.jumpToContactDetail(actionData);
  }

  async jumpToContactDetail(actionData:ActionData) {
    let contactParam = commonService.commonContactParam(actionData);
      (GlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext).startAbility(contactParam).then((data) => {
      HiLog.i(TAG, 'jumpToContact, startAbility Success');
    }).catch((error:BusinessError) => {
      HiLog.e(TAG, 'jumpToContact, failed. Cause: ' + JSON.stringify(error.message));
    });
  }
}