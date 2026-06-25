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

import NotificationService from '../service/NotificationService';
import ConversationListService from '../service/ConversationListService';
import common from '../data/commonData';
import HiLog from './HiLog';
import LooseObject from '../data/LooseObject';
import StringUtil from './StringUtil';
import DeviceUtil from './DeviceUtil';
import TelephoneUtil from './TelephoneUtil';
import { EnhancedInfoTemporaryDataSource } from '../model/EnhancedInfoTemporaryDataSource';
import ConversationListController from '../pages/conversationlist/conversationListController';
import ConversationListResponse from '../model/conversationlist/ConversationListResponse';
import { ContactsParamMsg, WantUtil, Result } from './WantUtil';
import YellowPageModel from '../model/yellowPageModel';
import ReceiveService from '../StaticSubscriber/ReceiveService';

const TAG = 'WantUtilTools';

export interface IWantHelper {
    jump(context: Context, parameters: LooseObject, isSkipSmsHomePage: boolean, yellowPage: string): void;
}

class NotificationWantHelper implements IWantHelper {
    public static readonly wantHelperName: string = 'NotificationWantHelper';
    private static readonly abilityWantAction: string = 'mms.event.notification';
    private static readonly targetPageName: string = 'conversation';
    private pageInfos: NavPathStack
    private wantUtil: WantUtil
    private contactParams: ContactsParamMsg | null = null

    constructor(pageInfos: NavPathStack, wantTools: WantUtil) {
        this.pageInfos = pageInfos
        this.wantUtil = wantTools
    }

    /*
     * 解析通知消息传过来里联系人参数的合理性。
     * */
    public dealContactParams(contactObjects: string): ContactsParamMsg {
        HiLog.i(TAG, 'parser contact object for notification');
        let contactParams: ContactsParamMsg = new ContactsParamMsg();
        if (StringUtil.isEmpty(contactObjects)) {
            return contactParams;
        }
        let params: Array<LooseObject> = [];
        try {
            params = JSON.parse(contactObjects);
            let contactsNumber: string = common.STR.EMPTY_STR;
            let contactsName: string = common.STR.EMPTY_STR;
            let contactsNumberFormat: string = common.STR.EMPTY_STR;
            let rawContactIds: Array<string> = [];
            let length: number = params.length;
            for (let i = 0; i < params.length; i++) {
                let item: LooseObject = params[i];
                contactsNumber = contactsNumber + item.telephone + common.STR.COMMA;
                contactsNumberFormat = contactsNumberFormat + item.telephone + common.STR.COMMA;
                if (item.contactName) {
                    contactsName += (item.contactName + common.STR.COMMA);
                } else if (length > 1) {
                    contactsName += (item.telephone + common.STR.COMMA);
                }
                rawContactIds.push(item.contactId || '');
            }
            let telephone: string = contactsNumber.substring(0, contactsNumber.length - 1);
            contactsNumber = TelephoneUtil.dealTelephoneSort(telephone);
            contactParams.strContactsNumber = contactsNumber;
            contactParams.strContactsNumberFormat = contactsNumberFormat.substring(0, contactsNumberFormat.length - 1);
            contactParams.strContactsName = contactsName.substring(0, contactsName.length - 1);
            contactParams.contactsNum = length;
            contactParams.rawContactId = rawContactIds.join(common.STR.COMMA);
        } catch (error) {
            HiLog.e(TAG, 'dealContactParams failed, return!');
            return contactParams;
        }
        return contactParams;
    }

    /*
     * 校验参数的合理性
     * */
    private preCheck(parameters: LooseObject): boolean {
        if (parameters.pageFlag && parameters.pageFlag != NotificationWantHelper.targetPageName) {
            HiLog.e(TAG, 'want from notification has wrong pageFlag:' + parameters.pageFlag)
            return false
        }
        if (!parameters.contactObjects) {
            HiLog.e(TAG, 'want from notification has wrong contactObjects value is null or undefined');
            return false
        }
        this.contactParams = this.dealContactParams(parameters.contactObjects);
        let contactParams: ContactsParamMsg = this.contactParams as ContactsParamMsg
        if (contactParams.contactsNum == 0) {
            HiLog.e(TAG, 'want from notification has wrong contactObjects , number of contactsNum is 0');
            return false
        }
        return true
    }

    public jump(context: Context, parameters: LooseObject, isSkipSmsHomePage: boolean, yellowPageId: string) {
        if (!this.preCheck(parameters)) {
            HiLog.e(TAG, 'notification input params failed with params check');
            return;
        }
        let result: Result = {
            uri: '',
            params: {}
        };
        let contactParams: ContactsParamMsg = this.contactParams as ContactsParamMsg
        let formatPromiseList: Promise<string>[] = []
        // Format the redirected mobile number. xxx(xxxx)xxxx --->> xxx xxxx xxxx.
        formatPromiseList.push(TelephoneUtil.formatDisplayPhoneNumIntl(contactParams.strContactsNumber))
        formatPromiseList.push(TelephoneUtil.formatDisplayPhoneNumIntl(contactParams.strContactsNumberFormat))
        Promise.all(formatPromiseList).then((formatStrContactsNumber) => {
            // strContactsNumber Remove spaces. strContactsNumberFormat Contains Spaces.
            contactParams.strContactsNumber = TelephoneUtil.removeWhitespace(formatStrContactsNumber[0])
            contactParams.strContactsNumberFormat = formatStrContactsNumber[1]
            result.params = contactParams
        }
        ).then(() => {
            HiLog.i(TAG, 'jump to conversation page');
            this.jumpToConversation(context, contactParams, result, isSkipSmsHomePage, yellowPageId)
        })
    }

    private jumpToConversation(context: Context, contactParams: ContactsParamMsg,
        result: Result, isSkipSmsHomePage: boolean, yellowPageId: string) {
        ConversationListService.getInstance()
            .querySessionByTelephone(contactParams.strContactsNumber, async (res: LooseObject) => {
                if (res.code == common.int.SUCCESS && res.response.id > 0) {
                    result.params.threadId = res.response.id;
                    let actionData: LooseObject = {};
                    actionData.threadId = res.response.id;
                    actionData.hasRead = common.is_read.UN_READ;
                    HiLog.i(TAG, 'cancelMessageNotify by threadid: ' + res.response.id);
                    NotificationService.getInstance().cancelMessageNotify(context, actionData, () => {
                        ConversationListService.getInstance()
                            .markAllToRead(context, actionData, (response: ConversationListResponse) => {
                                HiLog.i(TAG, 'markAllToRead get response');
                                if (response && response.code === common.int.SUCCESS) {
                                    HiLog.i(TAG,
                                        'markAllToRead success and current thread has unread msg.start statisticalData')
                                    ConversationListController.getInstance().statisticalData(context);
                                }
                            });
                    });
                    result.params.isDraft = res.response.hasDraft as boolean
                    if (res.response.hasDraft as boolean && res.response.messageCount == 0) {
                        //special NewMsg only with draft
                        result.params.isNewMsgWithDraft = true;
                    } else {
                        result.params.isNewMsg = false;
                    }
                } else {
                    result.params.isNewMsg = true;
                }
                result.params.yellowPageId = yellowPageId;
                result.params.isFromNotice = true;
                result.params.rawContactId = contactParams.rawContactId;
                result.params.contactId = res?.response?.contactId;
                let isInfoMsg = await TelephoneUtil.judgeIsInfoMsg(result.params.strContactsNumber);
                if (isInfoMsg) {
                    result.params.smsType = 1;

                    result.params.icon = 'icon/ic_bell_fill.svg';
                }
                if (isSkipSmsHomePage) {
                    this.wantUtil.timeOutIdOfHideIndexPage && clearTimeout(this.wantUtil.timeOutIdOfHideIndexPage);
                    this.wantUtil.timeOutIdOfHideIndexPage = null;
                    AppStorage.setOrCreate('isHideIndexPage', false);
                    EnhancedInfoTemporaryDataSource.getInstance().isHideIndexPage = false;
                }
                this.pageInfos.clear();
                if (DeviceUtil.isFoldable() || DeviceUtil.isTablet() || DeviceUtil.isFloatingScreen()) {
                    if (result.params.isNewMsg) {
                        this.pageInfos.replacePathByName('CreateNewConversation', result.params, false);
                    } else {
                        this.pageInfos.replacePathByName('Conversation', result.params, false);
                    }
                } else {
                    if (result.params.isNewMsg) {
                        this.pageInfos.pushPathByName('CreateNewConversation', result.params, false);
                    } else {
                        const isOnlineRcs = AppStorage.get<boolean>('isOnlineRcs');
                        if (isOnlineRcs) {
                            ReceiveService.getInstance().rcsSendReadReceipt({
                                telephone: contactParams.strContactsNumber
                            });
                        }
                        this.pageInfos.pushPathByName('Conversation', result.params, false);
                    }
                }
            }, context);
    }

    /*
     * 用于匹配是否从通知信息正常拉起短信(区别于骚然拦截信息)
     * */
    public static match(abilityWantParams: LooseObject, wantActionStr: string): boolean {
        //检查参数的合理性
        if (!(abilityWantParams && abilityWantParams.pageFlag)) {
            return false
        }
        return wantActionStr == NotificationWantHelper.abilityWantAction &&
            abilityWantParams.pageFlag === NotificationWantHelper.targetPageName;
    }
}

class PageFlag {
    public pageFlag: string = ''
}

class BlockedGuideFlag {
    public pageFlag: string = ''
    public slotId: number = 0
}

class BlockedListWantHelper implements IWantHelper {
    public static readonly wantHelperName: string = 'BlockedListWantHelper';
    private static readonly abilityWantAction: string = 'mms.event.notification';
    private static readonly targetPageName: string = 'blockedList';
    private pageInfos: NavPathStack
    private wantUtil: WantUtil

    constructor(pageInfos: NavPathStack, wantTools: WantUtil) {
        this.pageInfos = pageInfos
        this.wantUtil = wantTools
    }

    jump(context: Context, parameters: LooseObject, isSkipSmsHomePage: boolean): void {
        if (isSkipSmsHomePage) {
            this.wantUtil.timeOutIdOfHideIndexPage && clearTimeout(this.wantUtil.timeOutIdOfHideIndexPage);
            this.wantUtil.timeOutIdOfHideIndexPage = null;
            AppStorage.setOrCreate('isHideIndexPage', false);
            EnhancedInfoTemporaryDataSource.getInstance().isHideIndexPage = false;
        }
        this.pageInfos.pushPathByName('BlockedPage', {
            pageFlag: 'BlockedPageDetail'
        } as PageFlag)
    }

    public static match(abilityWantParams: LooseObject, wantActionStr: string): boolean {
        //检查参数的合理性
        if (!(abilityWantParams && abilityWantParams.pageFlag)) {
            return false
        }
        return wantActionStr == BlockedListWantHelper.abilityWantAction &&
            abilityWantParams.pageFlag === BlockedListWantHelper.targetPageName;
    }
}

class BlockedGuideWantHelper implements IWantHelper {
    public static readonly wantHelperName: string = 'BlockedGuideWantHelper';
    private static readonly abilityWantAction: string = 'mms.event.notification';
    private static readonly targetPageName: string = 'blockedGuidePage';
    private pageInfos: NavPathStack
    private wantUtil: WantUtil

    constructor(pageInfos: NavPathStack, wantTools: WantUtil) {
        this.pageInfos = pageInfos
        this.wantUtil = wantTools
    }

    jump(context: Context, parameters: LooseObject, isSkipSmsHomePage: boolean): void {
        if (isSkipSmsHomePage) {
            this.wantUtil.timeOutIdOfHideIndexPage && clearTimeout(this.wantUtil.timeOutIdOfHideIndexPage);
            this.wantUtil.timeOutIdOfHideIndexPage = null;
            AppStorage.setOrCreate('isHideIndexPage', false);
            EnhancedInfoTemporaryDataSource.getInstance().isHideIndexPage = false;
        }
        let slotId: number = parameters.slotId;
        this.pageInfos.pushPathByName('BlockedGuidePage', {
            pageFlag: 'BlockedGuidePageDetail',
            slotId : slotId
        } as BlockedGuideFlag)
        HiLog.i(TAG, 'jump slotId : ' + slotId);
    }

    public static match(abilityWantParams: LooseObject, wantActionStr: string): boolean {
        // 检查参数的合理性
        if (!(abilityWantParams && abilityWantParams.pageFlag)) {
            return false
        }
        return wantActionStr == BlockedGuideWantHelper.abilityWantAction &&
            abilityWantParams.pageFlag === BlockedGuideWantHelper.targetPageName;
    }
}

/*
 * 背景：短信会被各种应用拉起，该类会对拉起源进行区分，返回对应的处理者
 * */
export class WantMaster {
    static readonly unKnowCategory = 'unKnowCategory'

    /*
     * 根据对应的参数确认wantHelper的类型
     * */
    static cls(abilityWantParams: LooseObject, wantActionStr: string): string {
        if (NotificationWantHelper.match(abilityWantParams, wantActionStr)) {
            return NotificationWantHelper.wantHelperName
        }
        if (BlockedListWantHelper.match(abilityWantParams, wantActionStr)) {
            return BlockedListWantHelper.wantHelperName
        }
        if (BlockedGuideWantHelper.match(abilityWantParams, wantActionStr)) {
            return BlockedGuideWantHelper.wantHelperName
        }
        return WantMaster.unKnowCategory
    }

    /*
     * 创建对应的wantHelper的接口
     * */
    static createWantHelper(wantHelperName: string, pageInfos: NavPathStack,
        wantTools: WantUtil): IWantHelper | undefined {
        if (wantHelperName == NotificationWantHelper.wantHelperName) {
            return new NotificationWantHelper(pageInfos, wantTools)
        }
        if (wantHelperName == BlockedListWantHelper.wantHelperName) {
            return new BlockedListWantHelper(pageInfos, wantTools)
        }
        if (wantHelperName == BlockedGuideWantHelper.wantHelperName) {
            return new BlockedGuideWantHelper(pageInfos, wantTools)
        }
        return undefined
    }
}
