// @ts-nocheck

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

import LooseObject from "../../data/LooseObject"
import router from '@ohos.router';
import contactService from '../../service/ContractService';
import common from '../../data/commonData';
import commonService from '../../service/CommonService'
import conversationListService from "../../service/ConversationListService";
import AvatarColor from "../../model/common/AvatarColor";
import DateUtil from "../../utils/DateUtil";
import TransmitMsgDataSource from "../../model/TransmitMsgDataSource";
// Log tool class
import HiLog from "../../utils/HiLog";

const TAG = "TransmitMsgController"

export default class TransmitMsgController {
    private static sInstance: TransmitMsgController;
    private routerParams: LooseObject = router.getParams()
    // Total
    total: 0;
    // Information List
    contractsList: Array<any> = [];
    // List of contents forwarded by multiple messages
    transmitContentList: Array<any> = [];
    // Dual SIM card
    doubleCard: boolean = false;
    // Contents
    content: string = '';
    // MMS attachment address
    msgUriPath: string = '';
    // Number of Contacts
    contactsNum: number = 0;
    // Contact Name
    contactName: string = '';
    // Format the mobile number.
    telephoneFormat: string = '';
    // Multi-crowd hair only shows one person
    contactNameSplit: string = '';
    // Only one mobile phone number is displayed for multiple people.
    telephoneFormatSplit: string = '';
    // Mobile phone number
    telephone: string = '';
    // Whether selected
    isChecked: boolean = true;
    // Indicates whether the message is an MMS message.
    isMms: boolean = false;
    // Card 1
    simOne: number = 0;
    // Card 2
    simTwo: number = 1;
    // Sending SMS message ID
    threadId: string = '';
    // Forwarded Content Title
    transmitContent: string = '';
    // Formatted forwarding content
    transmitContentFormat: '';
    // Forwarding Content Editing Status Content
    transmitContentEdit: string = '';
    // Display Forwarding Dialog Box
    contractsPage: boolean = false;
    // The font size of the dialog title is displayed. When the number of characters is small, the large font is
    // displayed. When the number of characters is large, the small font is displayed.
    titleChecked: boolean = false;
    // Contact length threshold in dialog title
    contactNameLen: number = 20;
    // List pagination, number of pages
    page: number = 0;
    // Number of pages
    limit: number = 15;
    // Indicates whether the slide page is an MMS message.
    isSlideDetail: boolean = false;
    // MMS list data
    mmsSource: Array<any> = [];
    transmitItemSources: Array<any> = [];
    reg: RegExp = /^[\u4e00-\u9fa5_a-zA-Z]+$/;
    dialogMsg: LooseObject = {};
    DialogShow: false;
    transmitMsgDataSource: TransmitMsgDataSource = new TransmitMsgDataSource();

    static getInstance() {
        if (TransmitMsgController.sInstance == null) {
            TransmitMsgController.sInstance = new TransmitMsgController();
        }
        return TransmitMsgController.sInstance;
    }

    onInit() {
        // List of contents forwarded by multiple messages
        this.transmitContentList = router.getParams().transmitContentList;
        this.dialogMsg.transmitContentList = this.transmitContentList;
        this.dialogMsg.transmitContent = router.getParams().transmitContent;
        this.threadId = router.getParams().threadId;
    }

    onShow() {
        this.page = 0;
        this.requestItem();
    }

    // Obtaining List Data by Page
    requestItem() {
        let count = this.page * this.limit;
        if (this.page === 0) {
          this.page++;
          this.queryAllMessages();
        } else if (count < this.total && this.contractsList.length > (this.page - 1) * this.limit) {
          // The restriction on contractsList is to prevent multiple update requests during initialization.
          this.page++;
          this.queryAllMessages();
        }
    }

    // Queries all list information.
    queryAllMessages() {
        let that = this;
        let actionData: LooseObject = {};
        actionData.page = this.page;
        actionData.limit = this.limit;
        conversationListService.querySessionList(actionData, result => {
            if (result.code == common.int.SUCCESS) {
                this.contractsList = this.buildSessionList(result);;
                this.transmitMsgDataSource.refresh(this.contractsList);
                this.total = result.total;
                this.hasNoOrdinaryMsg = this.total == 0 ? true : false;
                this.hasInfoMsg = result.hasInfoMsg;
            }
        });
    }

    buildSessionList(result) {
        let res = [];
        result.response.forEach(item => {
            // Inherit selected items
            this.contractsList.some(oldItem => {
                if (item.threadId === oldItem.threadId) {
                    item.isCbChecked = oldItem.isCbChecked;
                    return true;
                }
            });
            let obj: LooseObject = {};
            obj = item;
            obj.isDelShow = false;
            obj.itemLeft = 0;
            obj.photoFirstName = common.string.EMPTY_STR;
            if( obj.name !== common.string.EMPTY_STR && this.reg.test(obj.name.substring(0, 1))) {
                obj.photoFirstName = obj.name.substring(0, 1).toUpperCase();
            }
            obj.portraitColor = AvatarColor.background.Color[Math.abs(parseInt(obj.threadId, 10)) % 6];
            // Time conversion
            DateUtil.convertDateFormatForItem(item, false);
            // Processes the display of the MMS message content.
            this.dealMmsListContent(item);
            res.push(obj);
        });
        return res;
    }

    dealMmsListContent(item) {
        if (item.hasMms && item.hasAttachment) {
            if (item.content == common.string.EMPTY_STR) {
                item.content = $r("app.string.attachment_no_subject");
            } else {
                item.content = $r("app.string.attachment", item.content);
            }
        }
        if (item.hasMms && !item.hasAttachment && item.content == common.string.EMPTY_STR) {
            item.content = $r("app.string.no_subject");
        }
    }
    // A dialog box is displayed when you touch a recent contact.
    clickSendMessage(item) {
        this.contactName = item.conversation.name;
        let contactsParamMsg: LooseObject = {};
        contactsParamMsg.contactsNum = item.conversation.contactsNum;
        contactsParamMsg.contactName = item.conversation.name;
        contactsParamMsg.telephoneFormat = item.conversation.telephoneFormat;
        contactsParamMsg.telephone = item.conversation.telephone;
        contactsParamMsg.contactNameSplit = item.conversation.name.split(common.string.COMMA)[0];
        contactsParamMsg.telephoneFormatSplit = item.conversation.telephoneFormat.split(common.string.COMMA)[0];
        this.threadId = item.conversation.threadId;
        this.dialogMsg.contactsParam = contactsParamMsg;
        // Determine the font length of a contact.
        this.checkContactNameLen();
    }

    checkContactNameLen() {
        if (this.contactName != null && this.contactName.length > this.contactNameLen) {
            this.titleChecked = true;
        } else {
            this.titleChecked = false;
        }
    }

    jumpToSelectContracts(callback) {
        // The page for selecting a contact is displayed.
        let actionData: LooseObject = {};
        actionData.pageFlag = common.contractPage.PAGE_FLAG_SINGLE_CHOOSE;
        this.jumpToContractForResult(actionData, callback);
    }

    // Go to Contacts app
    async jumpToContractForResult(actionData, callback) {
        let str = commonService.commonContractParam(actionData);
        let data = await globalThis.mmsContext.startAbilityForResult(str);
        this.dialogMsg.data = data;
        if (data.resultCode == 0 && JSON.parse(data.want.parameters.contactObjects).length != 0) {
            this.DialogShow = true;
            let contactsParam = contactService.dealContractParams(data.want.parameters.contactObjects);
            let contactsParamMsg: LooseObject = {};
            contactsParamMsg.contactsNum = contactsParam.contactsNum;
            contactsParamMsg.contactName = contactsParam.strContactsName;
            contactsParamMsg.telephoneFormat = contactsParam.strContactsNumberFormat;
            contactsParamMsg.telephone = contactsParam.strContactsNumber;
            contactsParamMsg.contactNameSplit = contactsParam.strContactsName.split(common.string.COMMA)[0];
            contactsParamMsg.telephoneFormatSplit = contactsParam.strContactsNumberFormat.split(common.string.COMMA)[0];
            this.dialogMsg.contactsParam = contactsParamMsg;
            conversationListService.querySessionByTelephone(this.telephone, res => {
                let response = res.response;
                if (res.code === common.int.SUCCESS && response.id > 0) {
                    this.threadId = response.id;
                } else {
                    this.threadId = 0;
                }
                this.checkContactNameLen();
            });
            callback();

        }
    }

    // Include Forward Message Source Button Switch - SMS
    changeValue(item, e) {
        item.content = e.text;
    }

    transmit() {
        let params = {
            threadId: this.threadId,
            strContactsName: this.dialogMsg.contactsParam.contactName, //Contact Name
            strContactsNumber: this.dialogMsg.contactsParam.telephone, //Mobile phone number
            strContactsNumberFormat: this.dialogMsg.contactsParam.telephoneFormat, //Format the mobile number.
            transmitFlag: true, //Send Flag
            contractsPage: false, //Display Forwarding Dialog Box
            mmsSource: this.mmsSource, //MMS list data
            isSlideDetail: this.isSlideDetail,//Indicates whether the slide page is an MMS message.
            transmitSource: this.transmitContentList,//List of contents forwarded by multiple messages
            isContainerOriginSource: this.isChecked //Whether selected
        }
        router.replaceUrl({
            url: 'pages/conversation/conversation',
            params: params
        });
    }
}
