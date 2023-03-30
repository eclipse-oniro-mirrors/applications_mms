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
import HiLog from "../../utils/HiLog";
import prompt from "@system.prompt";
import common from "../../data/commonData";
import contractService from "../../service/ContractService";
import commonService from "../../service/CommonService"
import commonCtrl from "../../pages/conversation/common"
import LooseObject from "../../data/LooseObject"

const TAG = "ReceiveController";

export default class ReceiveController {
    private static sInstance: ReceiveController;
    commonCtrl = commonCtrl.getInstance();
    refresh: boolean = false;
    // Recipient information (selected)
    selectContacts: Array<any> = [];
    contacts: Array<any> = [];
    // Recipient list information (all)
    contactsTemp: Array<any> = [];
    // Recipient Content
    myText: string = '';
    // true: focus editing status (gray); false: no focus (blue)
    isInputStatus: boolean = true;
    // true Show Search List
    isShowSearch: boolean = true;
    strSelectContact: string = '';
    styleTextarea: string = "select-contact-textarea";
    hasBlur: boolean = false;
    // List pagination, number of pages
    page: number = 0;
    // List pagination, quantity
    limit: number = 10;
    // Total number of contacts
    totalMessage: number = 0;

    static getInstance() {
        if (ReceiveController.sInstance == null) {
            ReceiveController.sInstance = new ReceiveController();
        }
        return ReceiveController.sInstance;
    }

    onInit(call) {
        HiLog.i(TAG, "onInit()")
        //    this.$watch("paramContact", "onPropertyChange");
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
            // The restriction on Contacts is to prevent multiple refresh requests during initialization.
            this.page++;
            this.queryContacts();
        }
    }

    queryContacts() {
        let actionData = {
            page: this.page,
            limit: this.limit
        };
        // Querying Contacts
        contractService.queryContact(actionData, contacts => {
            if (common.int.SUCCESS == contacts.code) {
                let response = this.contacts.concat(contacts.response);
                this.contacts = [];
                this.contacts = response;
                this.contactsTemp = this.contacts.slice(0);
            } else {
                HiLog.w(TAG, "queryContacts, fail");
            }
        });
        // Number of statistics
        contractService.countContact(actionData, contacts => {
            this.totalMessage = contacts.response;
        });
    }

    searchContacts(textValue, callback) {
        HiLog.i(TAG, "searchContacts start");
        let actionData = {
            telephone: textValue,
        };
        contractService.searchContracts(actionData, res => {
            let code = res.code;
            if (common.int.SUCCESS == res.code) {
                this.contacts = [];
                this.contacts = res.response;
            } else {
                HiLog.w(TAG, "searchContacts fail");
            }
            callback(code);
        });
    }

    // Filter search terms to match contacts
    filterContacts(textValue) {
        try {
            this.contacts = this.contactsTemp.filter((contact) => {
                if (contact.contactName && contact.contactName.toLowerCase().search(textValue) != -1) {
                    HiLog.i(TAG, "filterContacts, contactName");
                    return true;
                } else if (contact.telephone && contact.telephone.toLowerCase().search(textValue) != -1) {
                    HiLog.i(TAG, "filterContacts, telephone");
                    return true;
                }
                return false;
            });
        } catch (Error) {
            HiLog.i(TAG, `error message: ${JSON.stringify(Error)}`);
        }
    }

    isPhoneNumber(str) {
        // Determine whether the value is a number.
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
        HiLog.i(TAG, "checkReceive, isInputStatus: " + this.isInputStatus);
        if (this.myText.trim() == common.string.EMPTY_STR) {
            this.strSelectContact = this.setShowContactName();
            this.isShowSearch = false;
            return;
        }
        this.hasBlur = true;
        if (this.isPhoneNumber(this.myText)) {
            // Get information from the contact list
            let that = this;
            let selectContact: LooseObject = {};
            let hasSelect = false;
            for (let index in this.contacts) {
                let contract = this.contacts[index];
                if (contract.telephone == that.myText) {
                    selectContact.headImage = "icon/user_avatar_full_fill.svg";
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
            HiLog.i(TAG, "checkReceive, isPhoneNumber yes");
            this.selectContacts.push(selectContact);
            this.refresh = !this.refresh;
            this.setInputStatus(false);
            this.isShowSearch = false;
            this.setContactValue(call);
        } else {
            HiLog.i(TAG, "checkReceive, isPhoneNumber no");
            prompt.showToast({
                // Invalid Recipient
                // @ts-ignore
                message: $r("app.string.invalid_receive", this.myText),
                duration: 1000,
            });
            this.myText = "";
            this.isShowSearch = true;
            this.setContactValue(call);
        }
    }

    searchChange(text, call) {
        HiLog.d(TAG, "searchChange, start");
        if (this.checkSingle()) {
            this.setInputStatus(false);
            this.isShowSearch = false;
            return;
        }
        this.myText = text;
        if (!this.isInputStatus) {
            HiLog.w(TAG, "searchChange, isInputStatus false");
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
            //      this.$element("receiveTxt").focus({
            //        focus: true
            //      });
        } else {
            let textValue = this.myText.trim().toLowerCase();
            // Filtering logic
            this.filterContacts(textValue);
        }
    }

    setContactValue(call) {
        // Send recipient information to the invoked parent component.
        call({
            // Select the content of the text box before the contact.
            contactValue: this.myText,
            // Selected recipient information
            selectContacts: this.selectContacts,
            // Whether the focus is lost
            hasBlur: this.hasBlur
        });
    }

    addContact(index, call) {
        let curItem = this.contacts[index];
        if (this.checkSingle()) {
            return;
        }
        if (curItem != undefined && curItem.telephone != undefined && curItem.telephone.toString().trim() == "") {
            prompt.showToast({
                // Invalid Recipient
                // @ts-ignore
                message: $r("app.string.invalid_receive", this.myText),
                duration: 1000,
            });
            return;
        }
        this.selectContacts.push(curItem);
        this.contactsTemp = this.contactsTemp.filter((item) => {
            return item.telephone != curItem.telephone
        });
        this.contacts.splice(index, 1);
        HiLog.i(TAG, "addContact, length: " + this.selectContacts.length);
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
        HiLog.i(TAG, "addContact, isInputStatus: " + this.isInputStatus);
    }

    setShowContactName() {
        if (this.selectContacts.length == 0) {
            return '';
        }
        let myName = this.selectContacts[0]?.contactName.trim();
        let telephone = this.selectContacts[0]?.telephone
        if (!this.isPhoneNumber(telephone)) {
            myName = telephone.replace(new RegExp(/e|-|#|\*|\./, "g"), common.string.EMPTY_STR);
        } else {
            if (myName == "") {
                myName = telephone;
            }
        }
        if (this.selectContacts.length >= 2) {
            // name and other numbers
            return $r("app.string.and_others", myName, this.selectContacts.length - 1)
        } else {
            return myName
        }
    }

    myContactFocus() {
        HiLog.i(TAG, "myContactFocus, start");
        this.myText = common.string.EMPTY_STR;
        this.setInputStatus(true);
        this.isShowSearch = true;
    }

    myContactClick() {
        HiLog.i(TAG, "myContactClick, start");
        if (!this.isInputStatus) {
            this.myText = common.string.EMPTY_STR;
            this.setInputStatus(true);
            this.isShowSearch = true;
            // The TextArea control does not support focus.
            //      this.$element("receiveTxt").focus({
            //        focus: true
            //      });
        }
    }

    nameClick(idx, call) {
        HiLog.i(TAG, "click-->" + idx)
        if (this.selectContacts[idx].select) {
            let item = this.selectContacts.splice(idx, 1);
            // Deleted items are added to the collection to be searched.
            this.contactsTemp.push(item);
            if (item[0] != undefined && item[0].telephoneFormat != undefined &&
            item[0].telephoneFormat.toString().trim() != "") {
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
        actionData.pageFlag = common.contractPage.PAGE_FLAG_SINGLE_CHOOSE;
        this.jumpToContractForResult(actionData, call);
    }
    // Tap a contact's avatar to go to the contact details page.
    titleBarAvatar(index) {
        var actionData: LooseObject = {};
        actionData.phoneNumber = this.contacts[index]?.telephone;
        actionData.pageFlag = common.contractPage.PAGE_FLAG_CONTACT_DETAILS;
        this.jumpToContract(actionData);
    }
    // Switching to the Contacts app
    jumpToContract(actionData) {
        let str = commonService.commonContractParam(actionData);
        globalThis.mmsContext.startAbility(str).then((data) => {
        }).catch((error) => {
            HiLog.i(TAG, "jumpToContract failed");
        });
    }
    // Switching to the Contacts app
    async jumpToContractForResult(actionData, call) {
        let str = commonService.commonContractParam(actionData);
        var data = await globalThis.mmsContext.startAbilityForResult(str);
        if (data.resultCode == 0) {
            this.dealContractParams(data.want.parameters.contactObjects, call);
        }
    }

    dealContractParams(contactObjects, call) {
        this.selectContacts = [];
        let params = JSON.parse(contactObjects);
        if (this.checkSingle()) {
            return;
        }
        for (let element of params) {
            let selectContact: LooseObject = {};
            selectContact.headImage = "icon/user_avatar_full_fill.svg";
            selectContact.contactName = element.contactName;
            selectContact.telephone = element.telephone;
            selectContact.telephoneFormat = element.telephone;
            selectContact.select = false;
            this.selectContacts.push(selectContact);
        }
        if (params.length > 1 && this.checkSingle()) {
            this.selectContacts = [];
            return;
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

    // Currently, only one recipient is supported. You can enter only one recipient first.
    checkSingle() {
        if (this.selectContacts.length > 0) {
            prompt.showToast({
                // Invalid Recipient
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