/**
 * Copyright (c) 2022 Huawei Device Co., Ltd.
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
import type common from '@ohos.app.ability.common';
import HiLog from '../../utils/HiLog';
import commonData from '../../data/commonData';
import EmitterConstant from '../../data/EmitterConstant';
import ContactsService from '../../service/ContactsService';
import commonService from '../../service/CommonService'
import commonCtrl from '../../pages/conversation/common'
import LooseObject from '../../data/LooseObject'
import emitter from '@ohos.events.emitter';
import TelephoneUtil from '../../utils/TelephoneUtil';
import { BusinessError } from '@ohos.base';
import myCommon from '@ohos.app.ability.common';
import { GlobalContext } from '../../MainAbility/GlobalHelper';
import ability from '@ohos.ability.ability';
import promptAction from '@ohos.promptAction';
import SearchUtil, { ContactsSchema, IdLabelValueSchema } from '../../utils/SearchUtil';
import { Highlight, HighlightsOptions } from '../../utils/Highlight';
import AvatarColor from '../../model/common/AvatarColor';
import StringUtil from '../../utils/StringUtil';
import MmsUtil from '../../utils/MmsUtil';
import { AbilityResult, Contact } from '../../utils/TypesUtils';
import picker from '@ohos.file.picker';
import fs from '@ohos.file.fs';
import MMAttachmentAreaController from '../AttachmentArea/MMAttachmentAreaController';
import ConversationController, { rcsFileInfo } from '../../pages/conversation/conversationController';
import { contact } from '@kit.ContactsKit';
import CreateNewConversationViewModle from '../../pages/conversation/CreateNewConversationViewModle';
import lazy { isSameTel } from '../../utils/TelephoneUtilEnhancde';
import { taskpool } from '@kit.ArkTS';
import { ContactsSearchUtil } from '../../utils/ContactsSearchUtil';
import AccessibilityUtil from '../../utils/AccessibilityUtil';

const TAG = 'ReceiveController';

export interface callType {
  contactValue: string,

  // Selected recipient information
  selectContacts: LooseObject[],

  // Whether the focus is lost
  hasBlur: boolean
}

class ReturnValueOfCheckReceive {
  public isCheckPass: boolean = false;
  public useCallBack: boolean = false;

  constructor(isCheckPass: boolean, useCallBack: boolean) {
    this.isCheckPass = isCheckPass;
    this.useCallBack = useCallBack;
  }
}

export default class ReceiveController {
  private static sInstance: ReceiveController;
  public receiveAddContactEVENT: emitter.InnerEvent = {
    eventId: EmitterConstant.EVENT_RECEIVE_ADD_CONTACT,
    priority: emitter.EventPriority.HIGH
  };
  public commonCtrl = commonCtrl.getInstance();
  public refresh: boolean = false;
  // Recipient information (selected)
  public selectContacts: Array<LooseObject> = [];
  public contacts: Array<LooseObject> = [];
  // Recipient list information (all)
  public contactsTemp: Array<LooseObject> = [];
  // Recipient Content
  public myText: string = '';
  // true: focus editing status (gray); false: no focus (blue)
  public isInputStatus: boolean = true;
  // true Show Search List
  public isShowSearch: boolean = true;
  public strSelectContact: string | Resource = '';
  public styleTextarea: string = 'select-contact-textarea';
  public hasBlur: boolean = false;
  // List pagination, number of pages
  public page: number = 0;
  // List pagination, quantity
  public limit: number = 10;
  // Total number of contacts
  public totalMessage: number = 0;
  public isFromContactPage: boolean = false;
  public caretPoint: number = 0;
  public caretPointFlag: boolean = false;
  public contactEmpty: Contact = {
    detailInfo: '',
    displayName: '',
    id: -1,
    rawContactId: ''
  };
  private task: taskpool.Task | undefined = undefined;
  private contactsSearchUtil: ContactsSearchUtil = ContactsSearchUtil.getInstance();
  public isHideTextArea: boolean = false;
  
  static getInstance() {
    if (ReceiveController.sInstance == null) {
      ReceiveController.sInstance = new ReceiveController();
    }
    return ReceiveController.sInstance;
  }

  onInit(context: Context, call: Function) {
    this.contacts = [];
    this.selectContacts = this.commonCtrl.paramContact.transmitContacts;
    this.isShowSearch = true;
    if (this.selectContacts != null && this.selectContacts.length > 0) {
      setTimeout(() => {
        this.setContactValue(call);
      }, 200);
      this.isShowSearch = false;
      this.setInputStatus(false);
    }
    this.requestItem(context);
    this.refresh = !this.refresh;
  }

  refreshContactDataOnPageShow(context: Context) {
    this.requestItem(context);
  }

  emitOnchangeInputStatus() {
    let changeInputStatusEvent: emitter.InnerEvent = {
      eventId: EmitterConstant.EVENT_CHANGE_NEW_INPUT_STATUS,
      priority: emitter.EventPriority.HIGH
    };
    emitter.on(changeInputStatusEvent, () => {
      this.setInputStatus(false);
      this.isShowSearch = false;
    });
  }

  requestItem(context: Context) {
    let count = this.page * this.limit;
    if (this.page === 0) {
      this.page++;
      this.queryContacts(context);
    } else if (count < this.totalMessage && this.contacts.length > (this.page - 1) * this.limit) {
      // The restriction on Contacts is to prevent multiple refresh requests during initialization.
      this.page++;
      this.queryContacts(context);
    }
  }

  queryContacts(context: Context) {
    let actionData: Record<string, number> = {
      'page': this.page,
      'limit': this.limit
    };
    // Number of statistics
    ContactsService.getInstance().queryContactSizeByCondition(actionData, (res: LooseObject) => {
      if (res.code == commonData.int.SUCCESS) {
        this.totalMessage = res.abilityResult;
      }
    }, context);
  }

  queryRecentContacts(context: Context) {
    ContactsService.getInstance().queryRecentContact((res: LooseObject) => {
      if (commonData.int.SUCCESS == res.code) {
        this.contacts = [];
        this.contacts = res.response;
        this.deleteRepetitionContacts(this.contacts, this.selectContacts);
        //刚进去新建消息页面,下面列表展示的是格式化后的手机号,由于格式化后手机号可能一样,所以先去重再展示
        let contacts = this.contacts.filter((item, index) =>
        this.contacts.findIndex(i => (TelephoneUtil.formatDisplayPhoneNum(item.telephoneFormat) ===
        TelephoneUtil.formatDisplayPhoneNum(i.telephoneFormat) && i.contactName === item.contactName)) === index);
        AppStorage.setOrCreate('mReceiveControllerContacts', contacts);
        this.contactsTemp = this.contacts.slice(0);
      } else {
        this.contacts = [];
        this.contactsTemp = this.contacts.slice(0);
        HiLog.w(TAG, 'queryContacts, fail');
      }
    }, context)
  }

  // Filter search terms to match contacts
  filterContacts(textValue: string) {
    try {
      this.contacts = this.contactsTemp.filter((contact) => {
        if (contact.contactName && contact.contactName.toLowerCase().search(textValue) != -1) {
          HiLog.i(TAG, 'filterContacts, contactName');
          return true;
        } else if (contact.telephone && contact.telephone.toLowerCase().search(textValue) != -1) {
          HiLog.i(TAG, 'filterContacts, telephone');
          return true;
        }
        return false;
      });
    } catch (Error) {
      HiLog.i(TAG, `error message: ${JSON.stringify(Error)}`);
    }
  }

  setInputStatus(flag: boolean) {
    this.isInputStatus = flag;
    let strSelectContact = this.setShowContactName();
    let hasChange: boolean = true;
    if ((typeof this.strSelectContact !== 'string' && typeof strSelectContact !== 'string')){
      if (JSON.stringify(this.strSelectContact.params) === JSON.stringify(strSelectContact.params)) {
        hasChange = false;
      }
    }
    if (!flag && hasChange) {
      this.strSelectContact = strSelectContact;
    }
    let innerEvent: emitter.InnerEvent = {
      eventId: EmitterConstant.EVENT_IS_INPUT_STATUS,
    };
    HiLog.d(TAG, 'this.selectContacts==' + this.selectContacts.length)
    let eventData: emitter.EventData = {
      data: {
        'isInputStatus': flag,
        'contactsLength': this.selectContacts.length,
        'strSelectContact': this.strSelectContact
      }
    }
    emitter.emit(innerEvent, eventData);
  }

  checkDuplicates() {
    let textValue: string = this.myText.replace(new RegExp('[\\s]', 'g'), '');
    for (let i = 0; i < this.selectContacts?.length; i++) {
      let contact: LooseObject = this.selectContacts[i];
      if (isSameTel(contact.telephone, textValue) || textValue == contact.contactName) {
        return true;
      }
    }
    return false;
  }

  isAllCommas(str: string): boolean {
    return str.replace(/ /g, '').match(/^( *,)*$/) !== null;
  }

  async checkReceive(callback: Function, isSmcSms?: boolean, isNewMessage?: boolean): Promise<ReturnValueOfCheckReceive> {
    HiLog.i(TAG, 'checkReceive, isInputStatus: ' + this.isInputStatus);
    if (this.myText == commonData.STR.EMPTY_STR) {
      HiLog.w(TAG, 'checkReceive: myText empty');
      this.strSelectContact = this.setShowContactName();
      return new ReturnValueOfCheckReceive(false, false);
    }
    if (this.selectContacts.length === commonData.int.MESSAGE_CODE_THOUSAND) {
      this.myText = commonData.STR.EMPTY_STR;
      this.showUpperLimitToast($r('app.string.too_many_recipients', commonData.int.MESSAGE_CODE_THOUSAND_ONE,
        commonData.int.MESSAGE_CODE_THOUSAND));
      return new ReturnValueOfCheckReceive(false, false);
    }
    if (isSmcSms && this.selectContacts.length >= commonData.int.MAX_RECIPIENT_DEFAULT_OF_SMC) {
      this.showUpperLimitToast($r('app.string.too_many_recipients', this.selectContacts.length + 1, commonData.int.MAX_RECIPIENT_DEFAULT_OF_SMC));
      return new ReturnValueOfCheckReceive(false, false);
    }
    this.hasBlur = true;
    let textValue: string = this.myText.replace(new RegExp('[\\s]', 'g'), '');
    // 检查是否是已添加的号码或联系人名称
    if (this.checkDuplicates()) {
      this.myText = commonData.STR.EMPTY_STR;
      MmsUtil.showToast({
        message: $r('app.string.remove_duplicate_numbers'),
        duration: 1000,
      });
      return new ReturnValueOfCheckReceive(false, false);
    }
    if (textValue.includes('-')){
      textValue = textValue.replace(new RegExp('-', 'g'), '')
    }
    if (TelephoneUtil.isPhoneNumber(textValue)) {
      // Get information from the contact list
      this.getInfomationFromContact(callback, isNewMessage)
      return new ReturnValueOfCheckReceive(true, true);//若此时使用callback，则第二个参数为true
    } else {
      HiLog.i(TAG, 'checkReceive, isPhoneNumber no');
      promptAction.showToast({
        // Invalid Recipient
        message: $r('app.string.invalid_receive', '<' + this.myText + '>'),
        duration: 1000,
      });
      this.myText = '';
      this.isShowSearch = true;
      this.setContactValue(callback);
      return new ReturnValueOfCheckReceive(false, true);//若此时使用callback，则第二个参数为true
    }
  }

  getInfomationFromContact(call: Function, isNewMessage?: boolean) {
    let that = this;
    let selectContact: LooseObject = {};
    let hasSelect = false;
    const textValue: string = that.myText.replace(new RegExp('[\\s]', 'g'), '');
    let rawContactId: string = '';
    for (let index = 0; index < this.contacts.length; ++index) {
      let contact = this.contacts[index];
      if (isSameTel(textValue, contact.telephone)) {
        selectContact.headImage = 'icon/user_avatar_full_fill.svg';
        selectContact.contactName = contact.contactName;
        selectContact.telephone = contact.telephone;
        selectContact.telephoneFormat = contact.telephone;
        selectContact.rawContactId = contact.rawContactId || '';
        selectContact.contactId = contact.contactId || '';
        selectContact.select = false;
        hasSelect = true;
        break;
      }
    }
    if (!hasSelect) {
      let actionData: LooseObject = {};
      actionData.telephones = [textValue];
      actionData.isFuzzyMatch = true;
      ContactsService.getInstance().queryContactDataByCondition(actionData, (res: AbilityResult) => {
        let contactsList: Contact[] = res.abilityResult;
        if (res.code === 0) {
          let contact: Contact = this.getContactsByFuzzMatch(contactsList, textValue)
          selectContact.headImage = 'icon/user_avatar_full_fill.svg';
          selectContact.contactName = contact.displayName;
          selectContact.telephone = contact.detailInfo;
          selectContact.telephoneFormat = contact.detailInfo;
          selectContact.rawContactId = contact.rawContactId;
          selectContact.contactId = contact.contactId;
          selectContact.select = false;
        } else {
          selectContact.headImage = commonData.STR.EMPTY_STR;
          selectContact.contactName = commonData.STR.EMPTY_STR;
          selectContact.telephone = textValue;
          selectContact.telephoneFormat = textValue;
          selectContact.rawContactId = commonData.STR.EMPTY_STR;
          selectContact.contactId = commonData.STR.EMPTY_STR;
          selectContact.select = false;
        }
        this.showSelectContact(call, selectContact, isNewMessage)
      }, (GlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext))
    } else {
      this.showSelectContact(call, selectContact, isNewMessage)
    }
  }

  showSelectContact(call: Function, selectContact: LooseObject, isNewMessage?: boolean) {
    HiLog.i(TAG, 'checkReceive, isPhoneNumber yes');
    this.selectContacts.push(selectContact);
    this.refresh = !this.refresh;
    this.myText = commonData.STR.EMPTY_STR;
    if (!isNewMessage) {
      this.setInputStatus(false);
    }
    if (this.selectContacts.length == 1) {
      this.isShowSearch = false;
      this.setContactValue(call);
      if (!isNewMessage) {
        this.requestMmsInputFocus();
      }
    } else {
      this.isShowSearch = true;
      this.setContactValue(call);
    }
  }

  getContactsByFuzzMatch(list: Contact[], telephone: string) {
    for (let info of list) {
      if (info.detailInfo === telephone) {
        return info;
      }
    }
    let contactsTemp: string[] = [];
    for (let info of list) {
      contactsTemp.push(info.detailInfo);
    }
    HiLog.i(TAG, 'getContactByFuzzMatch');
    let contactFormatPhoneNumber: string[] = TelephoneUtil.batchFormatPhoneNumber(contactsTemp);
    let formatTelephone = TelephoneUtil.formatDisplayPhoneNumE164(telephone);
    for (let i = 0; i < list.length; i++) {
      if (contactFormatPhoneNumber[i] === formatTelephone) {
        HiLog.i(TAG, 'getContactByFuzzMatch bingo');
        return list[i];
      }
    }
    HiLog.i(TAG, 'getContactByFuzzMatch return empty info');
    this.contactEmpty.detailInfo = telephone
    return this.contactEmpty;
  }

  searchChange(text: string,context: Context, call: Function, controller: TextAreaController) {
    HiLog.d(TAG, 'searchChange, start');
    if (!isNaN(parseInt(text))) {
      let point = controller.getCaretOffset().index;
      let demoText = TelephoneUtil.dynamicFormatPhone(text);
      if (demoText != text) {
        this.searchChangeCodex(text, point);
      } else {
        if (this.caretPointFlag) {
          controller.caretPosition(this.caretPoint);
          this.caretPointFlag = false;
        }
      }
      text = demoText;
    }
    this.myText = text;
    if(this.myText) {
      if (!this.isInputStatus) {
        HiLog.w(TAG, 'searchChange, isInputStatus false');
        this.myText = ''
        return;
      }
      if (this.task && !this.task.isDone()) {
        taskpool.cancel(this.task)
      }
      this.task = this.taskPoolSearch(this.myText,context, (code: number) => {
        if (code == commonData.int.SUCCESS) {
          this.dealSearchData();
          this.setContactValue(call);
        } else {
          this.setContactValue(call);
        }
      });
    } else {
      this.contacts = [];
      this.contactsTemp = this.contacts.slice(0);
    }
  }

  searchChangeCodex(text: string, point: number) {
    let before = text.substring(0, point).replace(new RegExp('[\\s]', 'g'), '');
    let demoText = TelephoneUtil.dynamicFormatPhone(text);
    let result = '';
    for (let i = 0; i < demoText.length; i++) {
      if (demoText.charAt(i) == ' ') {
        continue;
      }
      result += demoText.charAt(i);
      if (result == before) {
        this.caretPoint = i + 1;
        break;
      }
    }
    this.caretPointFlag = true;
  }

  taskPoolSearch(searchStr: string, context:Context,callback: Function) {
    let task: taskpool.Task = this.contactsSearchUtil.searchContactsWithTaskPool(searchStr, context, this, callback)
    return task;
  }

  formatContactData() {
    let tempArr: LooseObject[] = [];
    this.contacts.forEach((contact) => {
      tempArr.push({
        contactName: contact.displayName || contact.contactName,
        telephone: contact.detailInfo || contact.telephone,
        telephoneFormat: contact.detailInfo || contact.telephone,
        rawContactId: contact.rawContactId || '',
        contactId: contact.contactId || '',
        nameHighlights: contact.nameHighlights,
        phoneHighlights: contact.phoneHighlights,
        portraitColor: AvatarColor.background.Color[Math.abs(Number.parseInt(contact.rawContactId || '0', 10)) % 6],
        photoFirstName: StringUtil.getFirstName(contact.displayName || contact.contactName)
      })
    })
    this.contacts = tempArr;
  }

  dealSearchData() {
    if (this.myText?.trim() == '') {
      this.contacts = this.contactsTemp.slice(0);
    }
  }

  setContactValue(call: Function) {
    // Send recipient information to the invoked parent component.
    const textValue: string = this.myText.replace(new RegExp('[\\s]', 'g'), '');
    call({
      // Select the content of the text box before the contact.
      contactValue: textValue,
      // Selected recipient information
      selectContacts: this.selectContacts,
      // Whether the focus is lost
      hasBlur: this.hasBlur
    } as callType);
  }

  async addContact(index: number, call: Function, isBeidou?: boolean) {
    let curItem = this.contacts[index];
    if (curItem != undefined && curItem.telephone != undefined && curItem.telephone.toString().trim() == '') {
      MmsUtil.showToast({
        // Invalid Recipient
        message: $r('app.string.invalid_receive', this.myText),
        duration: 1000,
      });
      return;
    }
    this.selectContacts.push(curItem);
    for (let element of this.selectContacts) {
      element.select = false;
    }
    this.contactsTemp = this.contactsTemp.filter((item) => {
      return !isSameTel(item.telephone, curItem.telephone);
    });
    this.contacts.splice(index, 1);
    HiLog.i(TAG, 'addContact, length: ' + this.selectContacts.length);
    this.myText = '';
    if (this.selectContacts.length == 1) {
      this.setInputStatus(false);
      this.isShowSearch = false;
      this.setContactValue(call);
      this.requestMmsInputFocus();
    } else {
      this.setInputStatus(true);
      this.isShowSearch = true;
      this.setContactValue(call);
    }
    HiLog.i(TAG, 'addContact, isInputStatus: ' + this.isInputStatus);
  }

  setShowContactName(): string | Resource {
    if (this.selectContacts.length == 0) {
      return '';
    }
    let myName: string = this.selectContacts[0]?.contactName?.trim();
    if (myName === undefined) {
      myName = '';
    }
    let telephone: string = this.selectContacts[0]?.telephone;
    if (telephone === undefined || telephone === null) {
      HiLog.i(TAG, 'setShowContactName failed');
      return '';
    }
    if (!TelephoneUtil.isPhoneNumber(telephone)) {
      myName = telephone.replace(new RegExp('e|-|#|\\*|\\.', 'g'), commonData.STR.EMPTY_STR);
    } else {
      if (myName == '') {
        myName = telephone;
      }
    }
    AppStorage.setOrCreate('contactsCount', this.selectContacts.length);
    if (this.selectContacts.length >= 2) {
      // name and other numbers
      return $r('app.plural.and_others', this.selectContacts.length, myName, this.selectContacts.length - 1)
    } else {
      return myName
    }
  }

  myContactFocus() {
    HiLog.i(TAG, 'myContactFocus, start');
    this.myText = commonData.STR.EMPTY_STR;
    if (this.isFromContactPage) {
      this.isFromContactPage = false;
      return;
    }
    this.setInputStatus(true);
    this.isShowSearch = true;
  }

  deleteContactItem(call: Function) {
    this.selectContacts.pop();
    this.contactsTemp.push(this.selectContacts)
    this.refresh = !this.refresh;
    this.setContactValue(call);
  }

  myContactClick(scroller: Scroller, call?: Function) {
    HiLog.i(TAG, 'myContactClick, start');
    if (!this.isInputStatus) {
      this.myText = commonData.STR.EMPTY_STR;
      HiLog.i(TAG, 'this.isInputStatus: false');
      this.setInputStatus(true);
      this.isShowSearch = true;
      setTimeout(() => {
        scroller.scrollEdge(Edge.Bottom);
      }, 200);
      AccessibilityUtil.requestFocusForAccessibility('ContactFlex');
    }
    if (call) {
      call();
    }
  }

  nameClick(idx: number, call: Function, name?: string) {
    HiLog.i(TAG, 'click-->' + idx)
    if (this.selectContacts[idx] == null) {
      return;
    }
    if (this.selectContacts[idx].select) {
      AccessibilityUtil.announceForAccessibility(getContext(this)
        .resourceManager
        .getStringSync($r('app.string.creat_new_conversation_receive_deleted').id)
        .replace('%s', name as string));
      let item = this.selectContacts.splice(idx, 1);
      // Deleted items are added to the collection to be searched.
      this.contactsTemp.push(item);
      this.refresh = !this.refresh;
      let indexAccessId: string = 'ContactFlex';
      // 删除某个联系人后焦点重新聚焦到上一个
      let index = idx - 1 > 0 ? idx - 1 : 0;
      if (this.selectContacts.length - 1 >= index) {
        indexAccessId = this.selectContacts[index].telephone;
      }
      setTimeout(() => {
        AccessibilityUtil.requestFocusForAccessibility(indexAccessId);
      }, 50);
      this.setContactValue(call);
      return;
    }
    for (let element of this.selectContacts) {
      element.select = false;
    }
    this.selectContacts[idx].select = true;
    this.refresh = !this.refresh;
    setTimeout(() => {
      AccessibilityUtil.requestFocusForAccessibility(this.selectContacts[idx].telephone);
    }, 50);
  }

  async clickToContacts(call: Function) {
    HiLog.i(TAG, ` clickToContacts start`);
    if (this.selectContacts.length === commonData.int.MESSAGE_CODE_THOUSAND) {
      this.showUpperLimitToast($r('app.string.recipients_upper_limit', commonData.int.MESSAGE_CODE_THOUSAND));
      return;
    }

    let actionData: LooseObject = {};
    actionData.pageFlag = commonData.contactPage.PAGE_FLAG_MULTI_CHOOSE;
    actionData.isLimit = true;
    actionData.contactCount = this.selectContacts.length;
    this.jumpToContactForResult(actionData, call);
  }

  // Tap a contact's avatar to go to the contact details page.
  titleBarAvatar(index: number) {
    let actionData: LooseObject = {};
    actionData.phoneNumber = this.contacts[index]?.telephone;
    actionData.pageFlag = commonData.contactPage.PAGE_FLAG_CONTACT_DETAILS;
    this.jumpToContact(actionData);
  }

  // Switching to the Contacts app
  jumpToContact(actionData: LooseObject) {
    let str = commonService.commonContactParam(actionData);
    (GlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext).startAbility(str).then((data) => {
    }).catch((error: BusinessError) => {
      HiLog.i(TAG, 'jumpToContact failed');
    });
  }

  // Switching to the Contacts app
  async jumpToContactForResult(actionData: LooseObject, call: Function) {
    let str = commonService.commonContactParam(actionData);
    let data: ability.AbilityResult = await (GlobalContext.getContext()
      .getObject('mmsContext') as myCommon.UIAbilityContext).startAbilityForResult(str);
    if (data.resultCode == 0) {
      this.isFromContactPage = true;
      this.dealContactParams(data.want?.parameters?.contactObjects as string,  call);
    }
  }

  // UiExtension Contacts app batchSelectContactForResult
  batchSelectContactForResult(data: LooseObject, call: Function, isSmcSms?: boolean,) {
    if (data.length > 0) {
      this.isFromContactPage = true;
      this.dealContactParams(JSON.stringify(data), call, isSmcSms);
    } else {
      HiLog.i(TAG, 'no select contact')
    }
  }

  private async dealContactParams(contactObjects: string, call: Function, isSmcSms?: boolean) {
    let params: LooseObject[] = [];
    try {
      params = JSON.parse(contactObjects);
      if (params.length > 0) {
        if (isSmcSms) {
          HiLog.i(TAG, 'beidou before params length:' + params.length)
          params = params.slice(0, 4);
        } else {
          HiLog.i(TAG, 'before params length:' + params.length)
          params = params.slice(0, 100);
        }
      }
      HiLog.i(TAG, 'after params length:' + params.length)
      for (let i = 0; i < params.length; i++) {
        let element: contact.Contact = params[i];
        let telephonesStr = element.phoneNumbers ? element.phoneNumbers.map(v => (v.phoneNumber)).join(',') : '';
        if (telephonesStr.indexOf(',') !== -1) {
          let phoneNumbers = telephonesStr.split(',')
          for (let i = 0; i < phoneNumbers.length; i++) {
            let selectContact: LooseObject = {};
            selectContact.headImage = 'icon/user_avatar_full_fill.svg';
            selectContact.contactName = element.name?.fullName || '';
            selectContact.telephone = phoneNumbers[i];
            selectContact.telephoneFormat = phoneNumbers[i];
            selectContact.rawContactId = element.id || '';
            selectContact.contactId = element.id || '';
            selectContact.select = false;
            this.selectContacts.push(selectContact);
          }
        } else {
          let selectContact: LooseObject = {};
          selectContact.headImage = 'icon/user_avatar_full_fill.svg';
          selectContact.contactName = element.name?.fullName || '';
          selectContact.telephone = telephonesStr;
          selectContact.telephoneFormat = telephonesStr;
          selectContact.rawContactId = element.id || '';
          selectContact.contactId = element.id || '';
          selectContact.select = false;
          this.selectContacts.push(selectContact);
        }
      }
    } catch (e) {
      HiLog.e(TAG, 'dealContactParams failed, return!');
      return;
    }
    if (this.selectContacts.length > 0) {
      this.deleteRepetitionContacts(this.contacts, this.selectContacts);
      // 北斗消息最大支持4个联系人
      if (isSmcSms && this.selectContacts.length > 4) {
        HiLog.i(TAG, 'is smc message, selectContacts length:' + this.selectContacts.length);
        this.showUpperLimitToast($r('app.string.too_many_recipients', this.selectContacts.length,
          commonData.int.MAX_RECIPIENT_DEFAULT_OF_SMC));
        this.selectContacts = this.selectContacts.slice(0,4)
      }
      this.setInputStatus(false);
      this.isShowSearch = false;
      this.myText = commonData.STR.EMPTY_STR;
      this.setContactValue(call);
    }
    this.commonCtrl.paramContact.isSelectContact = false;
  }

  // Multiple Arrays Delete Contacts
  contactsDeduplication(selectContacts: LooseObject[], contacts: LooseObject[]) {
    selectContacts.filter(item => {
      contacts.map((value, index) => {
        if (isSameTel(item.telephone, value.telephone)) {
          contacts.splice(index, 1)
        }
      })
    })
    return contacts
  }

  // Delete Duplicate selectContacts
  deleteRepetitionContacts(contacts: LooseObject[], selectContacts: LooseObject[]) {
    let hasDuplicateNumber: boolean = false;
    this.contacts = this.contactsDeduplication(selectContacts, contacts);

    this.selectContacts = selectContacts.filter((item, index) => {
      if (selectContacts.findIndex(event => isSameTel(item.telephone, event.telephone)) !== index) {
        hasDuplicateNumber = true;
      }
      return selectContacts.findIndex(event => isSameTel(item.telephone, event.telephone)) === index;
    });

    if (hasDuplicateNumber) {
      MmsUtil.showToast({
        // Invalid Recipient
        message: $r('app.string.remove_duplicate_numbers'),
        duration: 1000,
      });
    }
  }

  showUpperLimitToast(message: Resource) {
    this.setInputStatus(false);
    this.isShowSearch = false;
    MmsUtil.showToast({
      message: message,
      duration: 1000,
    });
  }

  InputTextClear() {
    this.myText = '';
    this.commonCtrl.paramContact.transmitContacts = [];
    HiLog.i(TAG, 'InputTextClear');
  }

  setIsShowSearch(value: boolean) {
    this.isShowSearch = value;
  }
  setContacts(contacts: Array<LooseObject>) {
    this.contacts = [];
    this.contacts = contacts;
  }

  requestMmsInputFocus(): void {
    emitter.emit(this.receiveAddContactEVENT, {
    });
    HiLog.i(TAG, `requestMmsInputFocus`);
  }

  dealRefreshContact(context: Context): void {
    HiLog.i(TAG, 'dealRefreshContact enter');
    this.queryRecentContacts(context);
    let resList: string[] = [];
    for (let i = 0; i < this.selectContacts.length; i++) {
      resList.push(this.selectContacts[i].telephone);
    }
    if (resList.length == 0) {
      return;
    }

    let actionData: LooseObject = {};
    actionData.telephones = resList;
    actionData.hasDelete = '0';

    ContactsService.getInstance().queryContactDataByCondition(actionData, (res: AbilityResult) => {
      if (res.code == commonData.int.FAILURE) {
        return;
      }
      let map: Map<string, string> = new Map();
      let contacts: Contact[] = res.abilityResult;
      HiLog.i(TAG, 'dealRefreshContact res contacts.length = ' + contacts.length);
      if (contacts.length == 0) {
        for (let i = 0; i < this.selectContacts.length; i++) {
          this.selectContacts[i].contactName = '';
        }
        this.setInputStatus(false)
        return;
      }

      for (let i = 0; i < contacts.length; i++) {
        const phoneNum = TelephoneUtil.formatDisplayPhoneNum(contacts[i].detailInfo)
        map.set(phoneNum, contacts[i].displayName);
      }

      for (let i = 0; i < this.selectContacts.length; i++) {
        const phoneNum = TelephoneUtil.formatDisplayPhoneNum(this.selectContacts[i].telephone)
        if (map.has(phoneNum)) {
          this.selectContacts[i].contactName = map.get(phoneNum);
        } else {
          this.selectContacts[i].contactName = '';
        }
      }
      this.setInputStatus(false)

    }, (GlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext));
  }

  async selectContactsByPicker() {
    let contactSelectionOptions: contact.ContactSelectionOptions = {
      isMultiSelect: true
    };
    let result: void | contact.Contact[] = await contact.selectContacts(contactSelectionOptions).then((data) => {
      return data;
    }).catch((err: BusinessError) => {
      HiLog.e(TAG, `selectContactsByPicker fail, error: ${JSON.stringify(err)}`);
    });
    return result;
  }
  /**
   * jump to the contact page and select contacts.
   *
   * @param call
   */
  async jumpToContactForResultForMore(call: Function) {
    HiLog.i(TAG, 'jumpToContactForResultForMore start.');
    let actionData: LooseObject = {};
    actionData.pageFlag = commonData.contactPage.PAGE_FLAG_MULTI_CHOOSE;
    let str = commonService.commonContactParam(actionData);
    let data: ability.AbilityResult = await (GlobalContext.getContext()
      .getObject('mmsContext') as myCommon.UIAbilityContext).startAbilityForResult(str);
    if (data.resultCode == 0) {
      let params: LooseObject[] = [];
      let arr: LooseObject[] = [];
      try {
        params = JSON.parse(data.want?.parameters?.contactObjects as string);
        for (let i = 0; i < params.length; i++) {
          let element: LooseObject = params[i];
          let selectContact: LooseObject = {};
          selectContact.headImage = 'icon/user_avatar_full_fill.svg';
          selectContact.contactName = element.contactName;
          selectContact.telephone = element.telephone;
          selectContact.telephoneFormat = element.telephone;
          selectContact.select = false;
          arr.push(selectContact);
        }
      } catch (e) {
        HiLog.e(TAG, 'dealContactParams failed, return!');
        return;
      }
      call({
        // Select the content of the text box before the contact.
        contactValue: this.myText,
        // Selected recipient information
        selectContacts: arr,
        // Whether the focus is lost
        hasBlur: this.hasBlur
      } as callType);
    }
  }

  private getDocumentViewPickerOptions() {
    let documentSelectOptions = new picker.DocumentSelectOptions();
    documentSelectOptions.maxSelectNumber = 1;
    documentSelectOptions.defaultFilePathUri = '';
    documentSelectOptions.fileSuffixFilters = ['.txt', ...MMAttachmentAreaController.SUPPORTED_AUDIO_EXTENSION_NAMES];
    return documentSelectOptions;
  }

  private async judgeAll(documentSelectResult: Array<string>, call: Function, callback: Function) {
    let fileUri = documentSelectResult[0];
    HiLog.i(TAG, 'documentViewPicker.select to file succeed and uris are:' + fileUri);
    const fileName = fileUri.substring(fileUri.lastIndexOf('/') + 1);
    const pointIndex = fileName.lastIndexOf('.');
    const fileNameInfo = [fileName.slice(0, pointIndex), fileName.slice(pointIndex + 1)];
    let fileStr = fileNameInfo[0];
    let flag: boolean = false;
    if (/^[A-Za-z]+$/.test(fileStr) && fileStr.length > 255) {
      flag = true;
    } else if (/^[\u4E00-\u9FA5]+$/.test(fileStr) && fileStr.length > 28) {
      flag = true;
    }
    if (flag) {
      let msg: Resource = $r('app.string.rcs_file_name_extra_long');
      promptAction.showToast({ message: msg, duration: 2000 });
      return;
    }
    let file = fs.openSync(fileUri, fs.OpenMode.READ_ONLY);
    let fileSize = fs.statSync(file.fd).size;
    if (Number(fileSize) === 0) {
      callback();
      try {
      } finally {
        fs.closeSync(file);
      }
      return
    }
    let context = getContext(this) as common.UIAbilityContext;
    let isAMRAudioFile = (fileNameInfo[1].toUpperCase() === 'AMR');
    let dstPath = isAMRAudioFile ? `${context.filesDir}/MMS_RCS_${fileNameInfo[1]}${Date.now()}.${fileNameInfo[1]}` :
      context.filesDir + '/' + fileName;
    let buffer = new ArrayBuffer(fileSize);
    let destFile = fs.openSync(dstPath, fs.OpenMode.CREATE | fs.OpenMode.READ_WRITE);
    try {
      fs.readSync(file.fd, buffer);
      fs.writeSync(destFile.fd, buffer);
    } finally {
      fs.closeSync(file);
      fs.closeSync(destFile);
    }
    call({ name: fileName, filePath: fileUri, sandBoxPath: dstPath, size: fileSize,
      isAMRAudioFile: isAMRAudioFile } as rcsFileInfo);
  }
  /**
   * jump to the contact page and select contacts.
   *
   * @param call
   * @param handleReceiveContactsData 用于在新建会话页面中给收件人赋值
   */
  public async jumpToFileManagementForResultForMore(mIsNew: boolean,
    mCreateNewConversationViewModle: CreateNewConversationViewModle, mConversationCtrl: ConversationController,
    call: (receiverData: rcsFileInfo) => void, callback: () => void, handleReceiveContactsData?: () => Promise<void>) {
    HiLog.i(TAG, 'jumpToFileManagementForResultForMore start.');
    const documentSelectOptions = this.getDocumentViewPickerOptions();
    let documentViewPicker = new picker.DocumentViewPicker();
    documentViewPicker.select(documentSelectOptions).then(async (documentSelectResult: Array<string>) => {
      if (!documentSelectResult || documentSelectResult.length === 0) {
        HiLog.iw(TAG, 'documentViewPicker no select File');
        if (mIsNew) {
          mCreateNewConversationViewModle.changeVCardJumpBackNeedFresh();
        } else {
          mConversationCtrl.changeVCardJumpBackNeedFresh();
        }
        return;
      }
      if (handleReceiveContactsData) {
        await handleReceiveContactsData();
      }
      this.judgeAll(documentSelectResult, call, callback);
    }).catch((err: BusinessError) => {
      HiLog.e(TAG, `Invoke documentViewPicker.select failed, code is ${err.code}, message is ${err.message}`);
      call({ name: '', filePath: '', sandBoxPath: '', size: 0 } as rcsFileInfo);
    })
  }
}

export interface SearchContactResult {
  detailInfo: string;
  displayName: string;
  rawContactId: string;
  contactId: string;
  nameHighlights?: HighlightsOptions[],
  phoneHighlights?: HighlightsOptions[]
}