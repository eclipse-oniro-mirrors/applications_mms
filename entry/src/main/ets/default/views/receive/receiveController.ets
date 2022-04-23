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
import appStorage from '../../utils/AppStorageUtil';
import HiLog from '../../utils/HiLog';
// 收件人
import prompt from '@system.prompt';
// JS公共常量
import common from '../../data/commonData';
import contractService from '../../service/ContractService';
import commonService from '../../service/CommonService'
import commonCtrl from '../../pages/conversation/common'
import featureAbility from '@ohos.ability.featureAbility';
import LooseObject from '../../data/LooseObject'

let ReceiveCtrl;

const TAG = 'ReceiveController';

export default class ReceiveController {
  private static sInstance: ReceiveController;
  commonCtrl = commonCtrl.getInstance();
  refresh: boolean = false;
  // 收件人信息(已经选择)
  selectContacts: Array<any> = [];
  contacts: Array<any> = [];
  // 收件人列表信息(所有的)
  contactsTemp: Array<any> = [];
  // 收件人内容
  myText: string = '';
  colorContact: string = '#000000';
  // true 焦点编辑状态(灰色), false无焦点状态(蓝色字体)
  isInputStatus: boolean = true;
  // true 显示搜索列表
  isShowSearch: boolean = true;
  strSelectContact: string = '';
  styleTextarea: string = 'select-contact-textarea';
  hasBlur: boolean = false;
  // 列表分页，页数
  page: number = 0;
  // 列表分页，数量
  limit: number = 10;
  // 联系人的总数
  totalMessage: number = 0;

  static getInstance() {
    if (ReceiveController.sInstance == null) {
      ReceiveController.sInstance = new ReceiveController();
    }
    return ReceiveController.sInstance;
  }

  onInit(call) {
    HiLog.i(TAG, "onInit()")
    //    this.$watch('paramContact', 'onPropertyChange');
    this.selectContacts = this.commonCtrl.paramContact.transmitContracts;
    if (this.selectContacts.length > 0) {
      let that = this;
      setTimeout(function () {
        that.setContactValue(call);
      }, 200);
      this.isShowSearch = false;
      this.setInputStatus(false);
    }
    this.requestItem()
    this.refresh = !this.refresh;
  }

  requestItem() {
    let count = this.page * this.limit;
    if (this.page === 0) {
      this.page++;
      this.queryContacts();
    } else if (count < this.totalMessage && this.contacts.length > (this.page - 1) * this.limit) {
      // 对Contacts的限制，是防止初始化时多次刷新请求
      this.page++;
      this.queryContacts();
    }
  }

  queryContacts() {
    let actionData = {
      page: this.page,
      limit: this.limit
    };
    // 查询联系人
    contractService.queryContact(actionData, contacts => {
      if (common.int.SUCCESS == contacts.code) {
        let response = this.contacts.concat(contacts.response);
        this.contacts = [];
        this.contacts = response;
        this.contactsTemp = this.contacts.slice(0);
      } else {
        HiLog.w(TAG, 'queryContacts, fail');
      }
    });
    // 统计数量
    contractService.countContact(actionData, contacts => {
      this.totalMessage = contacts.response;
    });
  }

  searchContacts(textValue, callback) {
    HiLog.i(TAG, 'searchContacts start');
    let actionData = {
      telephone: textValue,
    };
    contractService.searchContracts(actionData, res => {
      let code = res.code;
      if (common.int.SUCCESS == res.code) {
        this.contacts = [];
        this.contacts = res.response;
      } else {
        HiLog.w(TAG, 'searchContacts fail');
      }
      callback(code);
    });
  }
  // 过滤搜索词匹配联系人
  filterContacts(textValue) {
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
  }

  isPhoneNumber(str) {
    // 判断是否是数字
    let reg = /^\d{1,}$/;
    let pattern = new RegExp(reg);
    return pattern.test(str);
  }

  setInputStatus(flag) {
    this.isInputStatus = flag;
    if (!flag) {
      this.strSelectContact = this.setShowContactName();
    }
  }

  checkReceive(call) {
    HiLog.i(TAG, 'checkReceive, isInputStatus: ' + this.isInputStatus);
    if (this.myText.trim() == common.string.EMPTY_STR) {
      this.setInputStatus(false);
      this.isShowSearch = false;
      return;
    }
    this.hasBlur = true;
    if (this.isPhoneNumber(this.myText)) {
      // 从联系人列表中获取信息
      let that = this;
      let selectContact: LooseObject = {};
      let hasSelect = false;
      for (let index in this.contacts) {
        let contract = this.contacts[index];
        if (contract.telephone == that.myText) {
          selectContact.headImage = 'icon/user_avatar_full_fill.svg';
          selectContact.contactName = contract.contactName;
          selectContact.telephone = contract.telephone;
          selectContact.telephoneFormat = contract.telephone;
          selectContact.select = false;
          hasSelect = true;
          break;
        }
      }
      if (!hasSelect) {
        selectContact.headImage = common.string.EMPTY_STR;
        selectContact.contactName = common.string.EMPTY_STR;
        selectContact.telephone = that.myText;
        selectContact.telephoneFormat = that.myText;
        selectContact.select = false;
      }
      HiLog.i(TAG, 'checkReceive, isPhoneNumber yes');
      this.selectContacts.push(selectContact);
      this.refresh = !this.refresh;
      this.setInputStatus(false);
      this.isShowSearch = false;
      this.setContactValue(call);
    } else {
      HiLog.i(TAG, 'checkReceive, isPhoneNumber no');
      prompt.showToast({
        // 无效收件人
        // @ts-ignore
        message: $r('app.string.invalid_receive', this.myText),
        duration: 1000,
      });
      this.myText = "";
      this.isShowSearch = true;
      this.setContactValue(call);
    }
  }

  searchChange(text, call) {
    HiLog.d(TAG, 'searchChange, start');
    if (this.checkSingle()) {
      this.setInputStatus(false);
      this.isShowSearch = false;
      return;
    }
    this.myText = text;
    if (!this.isInputStatus) {
      HiLog.w(TAG, 'searchChange, isInputStatus false');
      return;
    }
    this.searchContacts(this.myText, code => {
      if (code == common.int.SUCCESS && this.myText.trim() != "") {
        this.setContactValue(call);
        this.dealSearchData();
        this.setContactValue(call);
      } else {
        this.setContactValue(call);
      }
    });
  }

  dealSearchData() {
    if (this.myText.trim() == "") {
      this.contacts = this.contactsTemp.slice(0);
      //      this.$element('receiveTxt').focus({
      //        focus: true
      //      });
    } else {
      let textValue = this.myText.trim().toLowerCase();
      // 过滤逻辑
      this.filterContacts(textValue);
    }
  }

  setContactValue(call) {
    // 将收件人信息,传给调用的父组件
    call({
      // 选择联系人之前的输入框的内容
      contactValue: this.myText,
      // 已经选择的收件人信息
      selectContacts: this.selectContacts,
      // 焦点是否丢失
      hasBlur: this.hasBlur
    });
  }

  addContact(index, call) {
    let curItem = this.contacts[index];
    if (this.checkSingle()) {
      return;
    }
    if (curItem.telephone.toString().trim() == "") {
      prompt.showToast({
        // 无效收件人
        // @ts-ignore
        message: $r('app.string.invalid_receive', this.myText),
        duration: 1000,
      });
      return;
    }
    this.selectContacts.push(curItem);
    this.contactsTemp = this.contactsTemp.filter((item) => {
      return item.telephone != curItem.telephone
    });
    this.contacts.splice(index, 1);
    HiLog.i(TAG, 'addContact, length: ' + this.selectContacts.length);
    this.myText = '';
    if (this.selectContacts.length == 1) {
      this.setInputStatus(false);
      this.isShowSearch = false;
      this.setContactValue(call);
    } else {
      this.setInputStatus(true);
      this.isShowSearch = true;
      this.setContactValue(call);
    }
    HiLog.i(TAG, 'addContact, isInputStatus: ' + this.isInputStatus);
  }

  setShowContactName() {
    if (this.selectContacts.length == 0) {
      return '';
    }
    let myName = this.selectContacts[0].contactName.trim();
    if (myName == '') {
      myName = this.selectContacts[0].telephone;
    }
    if (this.selectContacts.length >= 2) {
      // name以及其他number个
      return $r('app.string.and_others', myName, this.selectContacts.length - 1)
    } else {
      return myName
    }
  }

  myContactFocus() {
    HiLog.i(TAG, 'myContactFocus, start');
    this.myText = common.string.EMPTY_STR;
    this.setInputStatus(true);
    this.isShowSearch = true;
  }

  myContactClick() {
    HiLog.i(TAG, 'myContactClick, start');
    if (!this.isInputStatus) {
      this.myText = common.string.EMPTY_STR;
      this.setInputStatus(true);
      this.isShowSearch = true;
      // TextArea控件暂不支持focus
      //      this.$element('receiveTxt').focus({
      //        focus: true
      //      });
    }
  }

  nameClick(idx, call) {
    HiLog.i(TAG, "click-->" + idx)
    if (this.selectContacts[idx].select) {
      let item = this.selectContacts.splice(idx, 1);
      // 已经删除的添加到 需要搜索的集合
      this.contactsTemp.push(item);
      if (item[0].telephoneFormat.toString().trim() != "") {
        this.contacts.push(item[0]);
      }
      this.refresh = !this.refresh;
      this.setContactValue(call);
      return;
    }
    for (let element of this.selectContacts) {
      element.select = false;
    }
    this.selectContacts[idx].select = true;
    this.refresh = !this.refresh;
  }

  clickToContracts(call) {
    var actionData: LooseObject = {};
    actionData.pageFlag = common.contractPage.PAGE_FLAG_MULT_CHOOSE;
    this.jumpToContractForResult(actionData, call);
  }
  // 点击联系人头像，跳转至联系人详情
  titleBarAvatar(index) {
    var actionData: LooseObject = {};
    actionData.phoneNumber = this.contacts[index].telephone;
    actionData.pageFlag = common.contractPage.PAGE_FLAG_CONTACT_DETAILS;
    this.jumpToContract(actionData);
  }
  // 跳转联系人app
  jumpToContract(actionData) {
    let str = commonService.commonContractParam(actionData);
    featureAbility.startAbility(str).then((data) => {
    }).catch((error) => {
      HiLog.i(TAG, 'jumpToContract failed');
    });
  }
  // 跳转联系人app
  async jumpToContractForResult(actionData, call) {
    let str = commonService.commonContractParam(actionData);
    var data = await featureAbility.startAbilityForResult(str);
    if (data.resultCode == 0) {
      this.dealContractParams(data.want.parameters.contactObjects, call);
    }
  }

  dealContractParams(contactObjects, call) {
    let params = JSON.parse(contactObjects);
    if (params.length > 1 || this.checkSingle()) {
      return;
    }
    if (params.length == 1) {
      let element = params[0]
      let selectContact: LooseObject = {};
      selectContact.headImage = 'icon/user_avatar_full_fill.svg';
      selectContact.contactName = element.contactName;
      selectContact.telephone = element.telephone;
      selectContact.telephoneFormat = element.telephone;
      selectContact.select = false;
      this.selectContacts.push(selectContact);
    }
    if (this.selectContacts.length > 0) {
      this.deleteRepetitionContracts(this.contacts, this.selectContacts);
      this.setInputStatus(false);
      this.isShowSearch = false;
      this.setContactValue(call);
    }
    this.commonCtrl.paramContact.isSelectContact = false;
    this.commonCtrl.paramContact.isNewRecallMessagesFlag = false;
  }

  deleteRepetitionContracts(contacts, selectContacts) {
    let indexs = [];
    let count = 0;
    for (let item of contacts) {
      let telephone = item.telephone;
      for (let selectContact of selectContacts) {
        if (telephone == selectContact.telephone) {
          indexs.push(count);
          break;
        }
      }
      count++;
    }
    let selectContactIndexs = [];
    for (let i = 0; i < selectContacts.length; i++) {
      let telephone = selectContacts[i].telephone;
      for (let j = i + 1; j < selectContacts.length; j++) {
        if (telephone == selectContacts[j].telephone) {
          selectContactIndexs.push(i);
          break;
        }
      }
    }
    if (indexs.length > 0) {
      for (let index of indexs) {
        contacts.splice(index, 1);
      }
    }
    if (selectContactIndexs.length > 0) {
      for (let index of selectContactIndexs) {
        selectContacts.splice(index, 1);
      }
    }
  }

  // 目前只支持单个收件人，先规避操作只能输入一个收件人
  checkSingle() {
    if (this.selectContacts.length > 0) {
      prompt.showToast({
        // 无效收件人
        // @ts-ignore
        message: "只支持单个收件人",
        duration: 1000,
      });
      return true;
    } else {
      return false;
    }
  }
}