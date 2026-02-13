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
import AvatarColor from '../../model/common/AvatarColor';
import { Highlight, HighlightsOptions } from '../../utils/Highlight';
import common from '../../data/commonData';
import ContactService from '../../service/ContactsService';
import CommonService from '../../service/CommonService';
import ConversationListService from '../../service/ConversationListService';
import ConversationListDataSource from '../../model/ConversationListDataSource';
import SettingService from '../../service/SettingService';
import TransmitSearchDataSource from '../../model/TransmitSearchListDataSource';
import { ActionData, messageType } from '../conversationlist/conversationListController';
import { BusinessError } from '@ohos.base';
import { MySearch } from './transmitSearchMsg';
import { GlobalContext } from '../../MainAbility/GlobalHelper';
import myCommon from '@ohos.app.ability.common';
import DeviceUtil from '../../utils/DeviceUtil';
import { MyParams } from './transmitMsgController';


const TAG = 'TransmitSearchController';

let TransmitSearchCtrl: TransmitSearchController;
export default class TransmitSearchController {
  private static sInstance: TransmitSearchController | undefined = undefined;
  transmitSearchListDataSource: TransmitSearchDataSource = new TransmitSearchDataSource();
  conversationListDataSource: ConversationListDataSource = new ConversationListDataSource();
  reg: RegExp = new RegExp('^[\\u4e00-\\u9fa5_a-zA-Z]+$');
  numberReg: RegExp = new RegExp('^[0-9]+$');
  inputText: string = '';
  highLight: Highlight = Highlight.getInstance();
  searchList: Array<LooseObject> = [];
  searchCount: number = 0;
  messageList: Array<messageType> = [];
  isShowHead: boolean = true;
  dialogMsg: LooseObject = {};
  threadId: number = 0;
  transmitContentList: Array<LooseObject> = [];
  telephone: string = '';
  pageInfos?: NavPathStack;
  mmsStatus: number = 0;
  public isRcs: boolean = false;

  static getInstance() {
    if (!TransmitSearchController.sInstance) {
      TransmitSearchController.sInstance = new TransmitSearchController();
    }
    return TransmitSearchController.sInstance;
  }

  public static release() {
    TransmitSearchController.sInstance = undefined;
  }

  init(pageInfos: NavPathStack) {
    this.pageInfos = pageInfos;
    if (DeviceUtil.isPC()) {
      let transmitParam = AppStorage.get('transmitSearchParam') as MyParams;
      if (transmitParam) {
        this.dialogMsg = transmitParam.dialogMsg;
        this.transmitContentList = transmitParam.transmitContentList;
        this.mmsStatus = this.dialogMsg.mmsStatus;
        this.isRcs = transmitParam.isRcs || false;
      }
    } else {
      let obj: Array<LooseObject> = this.pageInfos.getParamByName('TransmitSearchMsg') as LooseObject[];
      if (obj[0]?.dialogMsg) {
        this.dialogMsg = obj[0].dialogMsg;
        this.transmitContentList = obj[0].transmitContentList;
        this.mmsStatus = this.dialogMsg.mmsStatus;
      }
      this.isRcs = obj?.[0]?.isRcs || false;
    }
    this.queryPageMessages();
  }

  back() {
    this.refresh();
    this.pageInfos!.pop();
    return true;
  }

  queryPageMessages() {
    let hasAggregate: boolean = false;
    let result = SettingService.getSettingFlagForConvListPage();
    if (result) {
      hasAggregate = result.hasAggregate;
      this.isShowHead = result.isShowContactHeadIcon;
    }
    let actionData: LooseObject = {};
    if (hasAggregate) {
      actionData.smsType = common.sms_type.COMMON;
    }
    actionData.page = 1;
    actionData.limit = 20;
    actionData.orderByTimeDesc = true;
    actionData.sqlMethodQuery = true;
    actionData.queryOffset = 0;
      ConversationListService.getInstance().getSessionListResultNew(actionData,
        GlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext).then((data) => {
      HiLog.i(TAG, 'getSessionListResultNew response');
      if (data && data.response) {
        this.messageList = data.response;
        this.conversationListDataSource.refresh(this.messageList);
      } else {
        this.messageList = [];
      }
    });
  }

  search(context: Context, value: string) {
    this.inputText = value;
    if (this.inputText === common.STR.EMPTY_STR) {
      this.searchList = [];
      this.searchCount = 0;
      this.transmitSearchListDataSource.refresh([], false);
    } else {
      let actionData: LooseObject = {};
      actionData.transmitSearchInput = this.inputText.trim();
      actionData.hasDelete = '0';
      ContactService.getInstance().queryContactDataByCondition(actionData, (res:LooseObject) => {
        HiLog.i(TAG, 'queryContactDataByCondition response');
        if (res.abilityResult && res.abilityResult.length > 0) {
          this.dealSearchList(res.abilityResult);
        } else {
          this.searchList = [];
        }
        this.searchCount = this.searchList.length;
        this.transmitSearchListDataSource.refresh(this.searchList, false);
      }, context);
    }
  }

  dealSearchList(list: Array<LooseObject>) {
    let searchArr: Array<LooseObject> = [];
    list.forEach((item) => {
      if (item.detailInfo !== common.STR.EMPTY_STR) {
        let portraitColor: string|Resource = common.STR.EMPTY_STR;
        if (item.id !== common.STR.EMPTY_STR) {
          portraitColor = AvatarColor.background.Color[Math.abs(Number.parseInt(item.id, 10)) % 6];
        }
        item.portraitColor = portraitColor;

        let name: string = item.displayName;
        if (name !== common.STR.EMPTY_STR && this.reg.test(name.substring(0, 1))) {
          let firstName: string = name.substring(0, 1).toUpperCase();
          item.firstName = firstName;
        } else {
          item.firstName = common.STR.EMPTY_STR;
        }
        let nameHighlights: Array<HighlightsOptions> = [];
        nameHighlights = this.highLight.getHighlightTexts(item.displayName, this.inputText);
        item.nameHighlights = nameHighlights;

        let infoHighlights: Array<HighlightsOptions> = [];
        infoHighlights = this.highLight.getHighlightTexts(item.detailInfo, this.inputText);
        item.infoHighlights = infoHighlights;

        searchArr.push(item);
      }
    });
    this.searchList = searchArr;
  }

  refresh() {
    this.inputText = '';
    this.searchList = [];
    this.searchCount = 0;
  }

  refreshSearchList(isExpand: boolean) {
    this.transmitSearchListDataSource.refresh(this.searchList, isExpand);
  }

  getSearchListCount() {
    return this.transmitSearchListDataSource.totalCount();
  }

  isDividerShow(isExpand: boolean, index: number) {
    let isShow: boolean = true;
    if (!isExpand) {
      if (this.searchList.length < 3) {
        if (index === this.searchList.length - 1) {
          isShow = false;
        }
      } else {
        if (index === 2) {
          isShow = false;
        }
      }
    } else {
      if (index === this.searchList.length - 1) {
        isShow = false;
      }
    }
    return isShow;
  }

  judgeInputIsNumber() {
    if (this.numberReg.test(this.inputText)) {
      return true;
    }
    return false;
  }

  clickAvatar(item: MySearch) {
    HiLog.i(TAG, 'click avatar');
    let telephone: string = item?.detailInfo;
    let actionData: Record<string, string> = {
      'phoneNumber': telephone,
      'pageFlag': common.contactPage.PAGE_FLAG_CONTACT_DETAILS
    };
    this.jumpToContact(actionData);
  }

  jumpToContact(actionData: LooseObject) {
    HiLog.i(TAG, 'jump to contact');
    let str = CommonService.commonContactParam(actionData);
      (GlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext).startAbility(str).then((data) => {
      HiLog.i(TAG, 'jumpToContact, startAbility success');
    }).catch((error: BusinessError) => {
      HiLog.e(TAG, 'jumpToContact, failed Cause: ' + JSON.stringify(error.message));
    })
  }

  clickContactAction(item: MySearch) {
    let contactsParamMsg: LooseObject = {};
    contactsParamMsg.contactsNum = 1;
    contactsParamMsg.contactName = item.displayName;
    contactsParamMsg.telephoneFormat = item.detailInfo;
    contactsParamMsg.telephone = item.detailInfo;
    contactsParamMsg.rawContactId = item.rawContactId;
    contactsParamMsg.contactNameSplit = item.displayName.split(common.STR.COMMA)[0];
    contactsParamMsg.telephoneFormatSplit = item.detailInfo.split(common.STR.COMMA)[0];
    this.dialogMsg.contactsParam = contactsParamMsg;
    this.telephone = item.detailInfo;
  }

  clickPhone() {
    let phone: string = this.inputText;
    let contactsParamMsg: LooseObject = {};
    contactsParamMsg.contactsNum = 1;
    contactsParamMsg.contactName = phone;
    contactsParamMsg.telephoneFormat = phone;
    contactsParamMsg.telephone = phone;
    contactsParamMsg.contactNameSplit = phone;
    contactsParamMsg.telephoneFormatSplit = phone;
    this.dialogMsg.contactsParam = contactsParamMsg;
    this.telephone = phone;
  }

  getThreadId(context: Context, callback: Function) {
    ConversationListService.getInstance().querySessionByTelephone(this.telephone, (res:LooseObject) => {
      let response: LooseObject = res.response;
      if (res.code === common.int.SUCCESS && response.id > 0) {
        this.threadId = response.id;
      } else {
        this.threadId = 0;
      }
      callback();
    }, context);
  }

  transmit(context: Context, value: boolean) {
    this.getThreadId(context, () => {
      GlobalContext.getContext().setObject('transmitFlag', true)
      if (!DeviceUtil.isPC()) {
        this.pageInfos!.pop();
      }
      let params: Record<string, number | boolean | string | LooseObject[]> = {
        'threadId': this.threadId,
        'strContactsName': this.dialogMsg?.contactsParam?.contactName, //Contact Name
        'strContactsNumber': this.dialogMsg?.contactsParam?.telephone, //Mobile phone number
        'strContactsNumberFormat': this.dialogMsg?.contactsParam?.telephoneFormat, //Format the mobile number.
        'transmitSource': this.transmitContentList, //List of contents forwarded by multiple messages
        'isContainerOriginSource': value,
        'transmitContent': this.dialogMsg?.transmitContent,
        'transmitContentDetail': this.dialogMsg?.transmitContentDetail,
        'isFromTransmitView': true,
        'mmsStatus': this.dialogMsg?.mmsStatus,
        'rawContactId': this.dialogMsg?.contactsParam?.rawContactId || ''
      }
      this.pageInfos!.pushPathByName('Conversation', params);
    });
  }
}