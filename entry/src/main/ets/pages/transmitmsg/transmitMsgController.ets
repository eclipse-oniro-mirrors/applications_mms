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

import LooseObject from '../../data/LooseObject'
import ContactService from '../../service/ContactsService';
import common from '../../data/commonData';
import commonService from '../../service/CommonService'
import ConversationListService from '../../service/ConversationListService';
import AvatarColor from '../../model/common/AvatarColor';
import lazy { DateUtil } from '../../utils/DateUtil';
import TransmitMsgDataSource from '../../model/TransmitMsgDataSource';
import ConversationController, { mmsListType } from '../conversation/conversationController'
import HiLog from '../../utils/HiLog';
import { messageType } from '../conversationlist/conversationListController';
import { GlobalContext } from '../../MainAbility/GlobalHelper';
import myCommon from '@ohos.app.ability.common';
import { Mms, PageJumpType, TransmitContent, TransmitPageJumpParam } from '../../utils/TypesUtils';
import StringUtil from '../../utils/StringUtil';
import MMAttachmentAreaController from '../../views/AttachmentArea/MMAttachmentAreaController';
import { contact } from '@kit.ContactsKit';
import { BusinessError } from '@ohos.base';
import { DraftUtils } from '../../utils/DraftUtils';
import DeviceUtil from '../../utils/DeviceUtil';

class Params {
    threadId: number = -1
    doubleCard: boolean = false
    transmitContent: string = ''
    transmitContentList: Array<TransmitContent | Array<TransmitContent>> = []
    isMulti: boolean = false
    isMms: boolean = false
    isMyStartPage: boolean = false
    transmitContentDetail: string = ''
    mmsStatus: number = 0
    public isRcs?: boolean;
}

export class ContactsParamMsg {
    contactsNum?: number
    contactName: string = ''
    telephoneFormat: string = ''
    telephone: string = ''
    contactNameSplit?: string
    telephoneFormatSplit?: string
    rawContactId?:string = ''
}

class Data {
    resultCode: number = -1
    want: Want = new Want()
}

class Want {
    deviceId: string = ''
    bundleName: string = ''
    abilityName: string = ''
    moduleName: string = ''
    uri: string = ''
    type: string = ''
    flags: number = -1
    action: string = ''
    parameters: MyParameters = new MyParameters();
    entities = []
}

class MyParameters {
    contactObjects: string = ''
    moduleName: string = ''
}


class Result {
    code: number = -1
    response: Response = new Response()
}

class Response {
    id: number = -1
    time: number = -1
    telephone: string = ''
    content: string = ''
    contactsNum: number = -1
    smsType: number = -1
    unreadCount: number = -1
    sendStatus: number = -1
    hasDraft: number = -1
    messageCount: number = -1
    hasMms: number = -1
    hasAttachment: number = -1
    telephoneFormat: string = ''
}

class ContactInfo {
    telephone: string = ''
    telephoneFormat: string = ''
    contactName: string = ''
    contactId: number = 0
}
 
export class DialogMsg {
    transmitContentList: Array<TransmitContent | Array<TransmitContent>> = []
    transmitContent: string = ''
    transmitContentDetail: string | Record<number, string> = ''
    data?: contact.Contact[]
    contactsParam: ContactsParamMsg = new ContactsParamMsg()
    mmsStatus: number = 0
    transmitMmsList: Array<LooseObject> = []
}

export class MyParams {
    dialogMsg: DialogMsg = new DialogMsg()
    transmitContentList: Array<TransmitContent | Array<TransmitContent>> = []
    public isRcs: boolean = false;
}

const TAG = 'TransmitMsgController'

export default class TransmitMsgController {
    private static sInstance: TransmitMsgController;
    // Total
    public total: number = 0;
    // Information List
    public contactsList: Array<mmsListType> = [];
    // List of contents forwarded by multiple messages
    public transmitContentList: Array<TransmitContent | Array<TransmitContent>> = [];
    // Dual SIM card
    public doubleCard: boolean = false;
    // Contents
    public content: string = '';
    // MMS attachment address
    public msgUriPath: string = '';
    // Number of Contacts
    public contactsNum: number = 0;
    // Contact Name
    public contactName: string = '';
    // Format the mobile number.
    public telephoneFormat: string = '';
    // Multi-crowd hair only shows one person
    public contactNameSplit: string = '';
    // Only one mobile phone number is displayed for multiple people.
    public telephoneFormatSplit: string = '';
    // Mobile phone number
    public telephone: string = '';
    // Whether selected
    public isChecked: boolean = true;
    // Indicates whether the message is an MMS message.
    public isMms: boolean = false;
    // Card 1
    public simOne: number = 0;
    // Card 2
    public simTwo: number = 1;
    // Sending SMS message ID
    public threadId: number = 0;
    // Forwarded Content Title
    public transmitContent: string = '';
    // Formatted forwarding content
    public transmitContentFormat: string = '';
    // Forwarding Content Editing Status Content
    public transmitContentEdit: string = '';
    // Contact length threshold in dialog title
    public contactNameLen: number = 20;
    // List pagination, number of pages
    public page: number = 0;
    // Number of pages
    public limit: number = 15;
    public transmitItemSources: Array<LooseObject> = [];
    public reg: RegExp = new RegExp('^[\\u4e00-\\u9fa5_a-zA-Z]+$');
    public dialogMsg: DialogMsg = new DialogMsg();
    public DialogShow: boolean = false;
    public transmitMsgDataSource: TransmitMsgDataSource = new TransmitMsgDataSource();
    public pageInfos: NavPathStack = new NavPathStack();
    public transmitDialogController: CustomDialogController | null = null;
    public transmitMmsDialogController: CustomDialogController | null = null;
    public transmitDialogController1: CustomDialogController | null = null;
    public transmitMmsList: Array<LooseObject> = [];
    private conversationController: ConversationController = ConversationController.getInstance();
    private mMAttachmentAreaController: MMAttachmentAreaController = MMAttachmentAreaController.getInstance();
    public isRcs: boolean = false;
    public isPC: boolean = DeviceUtil.isPC()

    static getInstance() {
        if (TransmitMsgController.sInstance == null) {
            TransmitMsgController.sInstance = new TransmitMsgController();
        }
        return TransmitMsgController.sInstance;
    }

    async onInit(pageInfos: NavPathStack, transmitDialogController: CustomDialogController,
        mmsDialogController: CustomDialogController, TransmitDialogController1: CustomDialogController,
        context: myCommon.UIAbilityContext) {
        // List of contents forwarded by multiple messages
        this.pageInfos = pageInfos;
        let transmitData: Params | undefined = AppStorage.get('transmitParam')
        let params: Params = this.isPC && transmitData ? transmitData :
            this.pageInfos.getParamByIndex(this.pageInfos.size() - 1) as Params;
        HiLog.i(TAG, 'onInit enter');
        this.dialogMsg.transmitContent = params?.transmitContent;
        this.threadId = params.threadId;
        this.transmitDialogController = transmitDialogController;
        this.transmitMmsDialogController = mmsDialogController;
        this.transmitDialogController1 = TransmitDialogController1;
        this.dialogMsg.mmsStatus = params?.mmsStatus;
        this.isRcs = params?.isRcs || false;
        if (params?.mmsStatus !== common.TRANSMIT_MSG_STATUS.NO_MMS &&
            params?.mmsStatus !== common.TRANSMIT_MSG_STATUS.SHARE_SMS) {
            this.transmitContentList = this.dealTransmitContentList(params?.transmitContentList);
            this.dialogMsg.transmitContentList = this.transmitContentList;
            this.dialogMsg.transmitContentDetail = this.dealTransmitContentDetail();
        } else {
            this.transmitContentList = params?.transmitContentList;
            this.dialogMsg.transmitContentList = this.transmitContentList;
            this.dialogMsg.transmitContentDetail = params?.transmitContentDetail;
        }
    }

    onShow() {
        this.page = 0;
        //清空上一次查询的联系人数据，重新进行查询渲染
        this.contactsList = []
        this.transmitMsgDataSource.mmsList = this.contactsList
        this.requestItem();
    }

    // Obtaining List Data by Page
    requestItem() {
        let count = this.page * this.limit;
        if (this.page === 0) {
          this.page++;
          this.queryAllMessages();
        } else if (count < this.total && this.contactsList.length > (this.page - 1) * this.limit) {
          // The restriction on contactsList is to prevent multiple update requests during initialization.
          this.page++;
          this.queryAllMessages();
        }
    }

    // Queries all list information.
    queryAllMessages() {
        let actionData: LooseObject = {};
        actionData.page = this.page;
        actionData.limit = this.limit;
        actionData.orderByTimeDesc = true;
        actionData.sqlMethodQuery = true;
        actionData.queryOffset = 0;
        ConversationListService.getInstance().querySessionList(actionData, (result: LooseObject) => {
            if (result.code == common.int.SUCCESS) {
                this.contactsList = this.buildSessionList(result);
                //与上一次查询数据长度相同时直接覆盖联系人列表数组，不会触发lazyforeach的ui刷新
                this.transmitMsgDataSource.refresh(this.contactsList);
                this.total = result.total;
            }
        }, GlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext);
    }

    buildSessionList(result: LooseObject): mmsListType[]{
        let res: mmsListType[] = [];
        result.response.forEach((item: mmsListType) => {
            // 服务号端口（虚拟端口号）不支持接收短信，转发列表过滤掉
            // if (IpMsgApi.isPubPort(item.telephone)) {
            //     return;
            // }
            // Inherit selected items
            this.contactsList.some(oldItem => {
                if (item.threadId === oldItem.threadId) {
                    item.isCbChecked = oldItem.isCbChecked;
                    return true;
                }
                return
            });
            let obj: mmsListType;
            obj = item;
            obj.isDelShow = false;
            obj.itemLeft = 0;
            obj.photoFirstName = common.STR.EMPTY_STR;
            if( obj.name !== common.STR.EMPTY_STR && this.reg.test(obj.name.substring(0, 1))) {
                obj.photoFirstName = obj.name.substring(0, 1).toUpperCase();
            }
            obj.portraitColor = AvatarColor.background.Color[Math.abs(obj.threadId) % 6];
            // Time conversion
            DateUtil.convertDateFormatForItem(item);
            // Processes the display of the MMS message content.
            this.dealMmsListContent(item);
            res.push(obj);
        });
        return res;
    }

    dealMmsListContent(item: mmsListType) {
        if (item.hasMms && item.hasAttachment) {
            if (item.content == common.STR.EMPTY_STR) {
                item.content = $r('app.string.attachment_no_subject');
            } else {
                item.content = $r('app.string.attachment', item.content);
            }
        }
        if (item.hasMms && !item.hasAttachment && item.content == common.STR.EMPTY_STR) {
            item.content = $r('app.string.no_subject');
        }
    }
    // A dialog box is displayed when you touch a recent contact.
    clickSendMessage(item: messageType) {
        this.contactName = item?.name;
        let contactsParamMsg: ContactsParamMsg = new ContactsParamMsg();
        contactsParamMsg.contactsNum = item?.contactsNum;
        contactsParamMsg.contactName = item?.name;
        contactsParamMsg.telephoneFormat = item?.telephoneFormat;
        contactsParamMsg.telephone = item?.telephone;
        contactsParamMsg.contactNameSplit = item?.name.split(common.STR.COMMA)[0];
        contactsParamMsg.telephoneFormatSplit = item?.telephoneFormat.split(common.STR.COMMA)[0];
        contactsParamMsg.rawContactId = item?.rawContactId || '';
        this.threadId = item?.threadId;
        this.dialogMsg.contactsParam = contactsParamMsg;
        this.contactsNum = contactsParamMsg.contactsNum;
    }

    // Go to Contacts app
    async jumpToContactForResult(context: Context) {
        contact.selectContacts({
            isMultiSelect: true
        }, (err: BusinessError, data) => {
            if (err) {
                HiLog.e(TAG, `selectContact callback: err->${JSON.stringify(err)}`);
                return;
            }
            HiLog.i(TAG, 'selectContact callback: success');
            if (data.length === 0) {
                return
            }
            if (this.isPC) {
                AppStorage.setOrCreate('isTransmitShow', false);
                AppStorage.setOrCreate('isFavoriteTransmitShow', false);
                AppStorage.setOrCreate('isTransmitSearch', false);
            }
            this.dialogMsg.data = data;
            let contactObjects: Array<LooseObject> = []
            for (let i = 0; i < data.length; i++) {
                let contactInfo: ContactInfo = new ContactInfo()
                let numbers = data[i].phoneNumbers || []
                for (let j = 0; j < numbers.length; j++) {
                    contactInfo.telephone = numbers[j].phoneNumber
                    contactInfo.telephoneFormat = numbers[j].phoneNumber
                    contactInfo.contactName = data[i].name?.fullName || ''
                    contactInfo.contactId = data[i].id || 0
                }
                contactObjects.push(contactInfo)
            }
            let contactsParam = ContactService.getInstance().dealContactParams(JSON.stringify(contactObjects) as string);
            let contactsParamMsg: ContactsParamMsg = new ContactsParamMsg();
            contactsParamMsg.contactsNum = contactsParam?.contactsNum;
            contactsParamMsg.contactName = contactsParam?.strContactsName;
            contactsParamMsg.telephoneFormat = contactsParam?.strContactsNumberFormat;
            contactsParamMsg.telephone = contactsParam?.strContactsNumber;
            contactsParamMsg.contactNameSplit = contactsParam?.strContactsName.split(common.STR.COMMA)[0];
            contactsParamMsg.telephoneFormatSplit = contactsParam?.strContactsNumberFormat.split(common.STR.COMMA)[0];
            contactsParamMsg.rawContactId = contactsParam?.rawContactId;
            this.dialogMsg.contactsParam = contactsParamMsg;
            this.contactsNum = contactsParamMsg.contactsNum == undefined ? 0:contactsParamMsg.contactsNum;
            this.jumpToContactForResultCheckDialog();
            ConversationListService.getInstance().querySessionByTelephone(contactsParam?.strContactsNumber, (res: Result) => {
                let response: Response = res.response;
                if (res.code === common.int.SUCCESS && response.id > 0) {
                    this.threadId = response.id;
                } else {
                    this.threadId = 0;
                }
            }, context);
        });
    }

    private jumpToContactForResultCheckDialog() {
        if (this.dialogMsg.mmsStatus === common.TRANSMIT_MSG_STATUS.NO_MMS) {
            if (this.transmitDialogController !== null) {
                this.transmitDialogController.open();
            }
        } else if (this.dialogMsg.mmsStatus === common.TRANSMIT_MSG_STATUS.THIRD_PART_MMS ||
            this.dialogMsg.mmsStatus === common.TRANSMIT_MSG_STATUS.SHARE_MMS ||
            this.dialogMsg.mmsStatus === common.TRANSMIT_MSG_STATUS.SHARE_SMS) {
            if (this.transmitDialogController1 !== null) {
                this.transmitDialogController1.open();
            }
        } else if (this.transmitMmsDialogController !== null) {
            setTimeout(() => {
                this.transmitMmsDialogController?.open();
            }, 50);
        }
    }

    // Include Forward Message Source Button Switch - SMS
    changeValue(item: LooseObject, e: LooseObject) {
        item.content = e.text;
    }

    transmit(value: boolean, isTransmit: boolean): void {
        let params: Record<string, number | boolean | string | LooseObject[] | Record<number, string>> = {
            'threadId': this.threadId,
            'strContactsName': this.dialogMsg?.contactsParam?.contactName, //Contact Name
            'strContactsNumber': this.dialogMsg?.contactsParam?.telephone, //Mobile phone number
            'strContactsNumberFormat': this.dialogMsg?.contactsParam?.telephoneFormat, //Format the mobile number.
            'transmitSource': this.transmitContentList,//List of contents forwarded by multiple messages
            'isContainerOriginSource': value,
            'transmitContent': this.dialogMsg?.transmitContent,
            'transmitContentDetail': this.dialogMsg?.transmitContentDetail,
            'isFromTransmitView': true,
            'mmsStatus': this.dialogMsg?.mmsStatus,
            'rawContactId': this.dialogMsg?.contactsParam?.rawContactId || '',
            'contactsNum': this.contactsNum,
        }
        GlobalContext.getContext().setObject('transmitFlag', isTransmit)
        this.pageInfos.pop();
        this.pageInfos.replacePathByName('Conversation', params);
    }

    jumpToSearchContact() {
        HiLog.i(TAG, 'jumpToSearchContact')
        let params: MyParams = new MyParams();
        params.dialogMsg = this.dialogMsg;
        params.transmitContentList = this.transmitContentList;
        params.isRcs = this.isRcs;
        if (this.isPC) {
            AppStorage.setOrCreate('isTransmitSearch', true);
            AppStorage.setOrCreate('transmitSearchParam', params);
        } else {
            this.pageInfos.pushPathByName('TransmitSearchMsg', params);
        }
    }

    // Processes the forwarded content and combines similar common SMs into an array.
    dealTransmitContentList(list: Array<TransmitContent | Array<TransmitContent>>): Array<TransmitContent | Array<TransmitContent>> {
        HiLog.i(TAG, 'dealTransmitContentList');
        let isPreMsg: boolean = false;
        let transmitList: Array<TransmitContent | Array<TransmitContent>> = [];
        list?.forEach((detail: TransmitContent | Array<TransmitContent>, index: number) => {
            if (!(detail instanceof Array) && !detail.isMsm) {
                if (detail.mms && detail.mms.length !== 0) {
                    transmitList.push(detail);
                    isPreMsg = false;
                } else {
                    HiLog.i(TAG, 'dealTransmitContentList is not mms');
                    let arr: Array<TransmitContent> = [];
                    if (isPreMsg) {
                        arr = transmitList[transmitList.length - 1] as Array<TransmitContent>;
                        arr.push(detail);
                    } else {
                        arr.push(detail);
                        transmitList.push(arr);
                        isPreMsg = true;
                    }
                }
            } else {
                HiLog.i(TAG, 'dealTransmitContentList is mms');
                transmitList.push(detail);
                isPreMsg = false;
            }
        });
        return transmitList;
    }

    dealTransmitContentDetail(): Record<number, string> {
        HiLog.i(TAG, 'dealTransmitContentDetail');
        let contentObj: Record<number, string> = {};
        this.transmitContentList.forEach((list, index) => {
            if (list instanceof Array) {
                let msgContent: string = this.getMsgContent(list);
                if (Object.values(contentObj).length === 0) {
                    contentObj[index] = msgContent;
                } else {
                    let content = contentObj[index];
                    if (content) {
                        content = msgContent;
                    }
                    contentObj[index] = msgContent;
                }
            }
        });
        return contentObj;
    }

    getMsgContent(msgItem: Array<TransmitContent>): string {
        HiLog.i(TAG, 'getMsgContent transmit')
        let content = '';
        msgItem.forEach((item: TransmitContent, idx: number) => {
            if (idx === 0) {
                content = item.content;
            } else {
                content = content + '\n' + ' ' + '\n' + item.content;
            }
        });
        return content;
    }

    saveDraftAndTransmit(value: boolean, pageInfos: NavPathStack, isTransmit: boolean) {
        // 无论转发给当前会话还是别的会话，须先保存草稿
        this.conversationController.setDraftModel(() => {
            DraftUtils.getInstance().saveDraft(getContext(this), () => {
                this.transmit(value, isTransmit)
            })
        })
    }


  public static handleTransmitPageJump = (transmitPageJumpParam: TransmitPageJumpParam,
    pageInfos: NavPathStack | undefined) => {
    if (!transmitPageJumpParam?.pageName) {
      HiLog.e(TAG, 'handleTransmitPageJump: transmitPageJumpParam or transmitPageJumpParam.pageName empty');
      return;
    }
    if (!pageInfos) {
      HiLog.e(TAG, 'handleTransmitPageJump: pageInfos empty');
      return;
    }
    if (transmitPageJumpParam.type === PageJumpType.PUSH_PATH_BY_NAME) {
      HiLog.i(TAG, 'handleTransmitPageJump: PUSH_PATH_BY_NAME');
      try {
        pageInfos.pushPathByName(transmitPageJumpParam.pageName, transmitPageJumpParam.params ?? new Object());
      } catch (e) {
        HiLog.e(TAG, `handleTransmitPageJump: PUSH_PATH_BY_NAME error: ${e?.code} ${e?.message}`);
      }
    }
  }
}
