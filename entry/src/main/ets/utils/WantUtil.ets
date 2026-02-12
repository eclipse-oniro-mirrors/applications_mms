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

import NotificationService, { IBadgeContextInfo } from '../service/NotificationService';
import ContactService from '../service/ContactsService';
import ConversationListService from '../service/ConversationListService';
import common from '../data/commonData';
import HiLog from './HiLog';
import LooseObject from '../data/LooseObject';
import { GlobalContext } from '../MainAbility/GlobalHelper';
import commonData from '../data/commonData';
import StringUtil from './StringUtil';
import dotCommon, { onlyStateParam, notifyStateParam } from './MmsDot/DotCommon';
import DotUtil from './MmsDot/DotUtils';
import { DynamicLoader } from './DynamicLoader';
import DeviceUtil from './DeviceUtil';
import TelephoneUtil from './TelephoneUtil';
import { AddressInfo, Mms, ShareExtraData } from './TypesUtils';
import FileUtil from './FileUtil';
//import { systemShare } from '@kit.ShareKit';
import { EnhancedInfoTemporaryDataSource } from '../model/EnhancedInfoTemporaryDataSource';
import ConversationListController from '../pages/conversationlist/conversationListController';
import ConversationListResponse from '../model/conversationlist/ConversationListResponse';
import { IWantHelper, WantMaster } from './WantUtilTools';
import { BusinessError, systemDateTime } from '@kit.BasicServicesKit';
import ConversationController from '../pages/conversation/conversationController';

const TAG = 'WantUtil';

export class AbilityWant {
  deviceId: string = '';
  bundleName: string = '';
  abilityName: string = '';
  moduleName: string = '';
  uri: string = '';
  type: string = '';
  flags: number = -1;
  action: string = '';
  parameters: LooseObject = {};
  entities: string[] = [];
}

class PageFlag {
  public pageFlag: string = ''
}

export class Result {
  uri: string = '';
  params: LooseObject = {};
}

export class ContactsParamMsg {
  strContactsNumber: string = common.STR.EMPTY_STR;
  rawContactId: string = common.STR.EMPTY_STR;
  strContactsName: string = common.STR.EMPTY_STR;
  strContactsNumberFormat: string = common.STR.EMPTY_STR;
  contactsNum: number = 0
}

class NotificationWantHelper {
  private readonly abilityWantAction: string = 'mms.event.notification';
  private readonly targetPageName: string = 'conversation';
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
    if (parameters.pageFlag && parameters.pageFlag != this.targetPageName) {
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

  public jump(context: Context, parameters: LooseObject, isSkipSmsHomePage: boolean) {
    if (!this.preCheck(parameters)) {
      HiLog.e(TAG, 'notification input params failed with params check');
      return;
    }
    GlobalContext.getContext().setObject('isFromNotify', true)
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
      this.jumpToConversation(context, contactParams, result, isSkipSmsHomePage)
    })
  }

  private jumpToConversation(context: Context, contactParams: ContactsParamMsg, result: Result,
    isSkipSmsHomePage: boolean) {
    ConversationListService.getInstance()
      .querySessionByTelephone(contactParams.strContactsNumber, (res: LooseObject) => {
        if (res.code == common.int.SUCCESS && res.response.id > 0) {
          result.params.threadId = res.response.id;
          HiLog.i(TAG,'jumpToConversation from notification threadId is: ' + result.params.threadId);
          let actionData: LooseObject = {};
          actionData.threadId = res.response.id;
          actionData.hasRead = common.is_read.UN_READ;
          HiLog.i(TAG, 'cancelMessageNotify by threadid: ' + res.response.id);
          ConversationListService.getInstance().markAllToRead(context, actionData, (response: ConversationListResponse) => {
            HiLog.i(TAG, 'markAllToRead get response');
            if (response && response.code === common.int.SUCCESS) {
              HiLog.i(TAG, 'markAllToRead success and current thread has unread msg.start statisticalData')
              ConversationListController.getInstance().statisticalData(context);
            }
          });
          NotificationService.getInstance().cancelAllNotify();
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
        result.params.rawContactId = contactParams.rawContactId;
        if (isSkipSmsHomePage) {
          this.wantUtil.timeOutIdOfHideIndexPage && clearTimeout(this.wantUtil.timeOutIdOfHideIndexPage);
          this.wantUtil.timeOutIdOfHideIndexPage = null;
          AppStorage.setOrCreate('isHideIndexPage', false);
          EnhancedInfoTemporaryDataSource.getInstance().isHideIndexPage = false;
        }
        if (DeviceUtil.isFoldable() || DeviceUtil.isTablet() || DeviceUtil.isFloatingScreen()) {
          this.pageInfos.clear();
          if (result.params.isNewMsg) {
            this.pageInfos.replacePathByName('CreateNewConversation', result.params, false);
          } else {
            this.pageInfos.replacePathByName('Conversation', result.params, false);
          }
        } else {
          if (result.params.isNewMsg) {
            this.pageInfos.pushPathByName('CreateNewConversation', result.params, false);
          } else {
            this.pageInfos.pushPathByName('Conversation', result.params, false);
          }
        }
      }, context);
  }

  /*
   * 用于匹配是否从通知信息拉起短信
   * */
  match(wantActionStr: string): boolean {
    return wantActionStr == this.abilityWantAction
  }
}
export class WantUtil {
  public timeOutIdOfHideIndexPage: null | number = null;
  getWant(context: Context, pageInfos: NavPathStack) {
    HiLog.i(TAG, 'getWant start:');
    if(GlobalContext.getContext().getObject('abilityWant') == null) {
      HiLog.e(TAG, 'getWant abilityWant is null');
      return;
    }
    let abilityWant: AbilityWant = GlobalContext.getContext().getObject('abilityWant') as AbilityWant;
    GlobalContext.getContext().setObject('abilityWant', null)
    HiLog.i(TAG, 'ohos.aafwk.param.callerAbilityName: ' + JSON.stringify(abilityWant.parameters['ohos.aafwk.param.callerAbilityName']));
    HiLog.i(TAG, 'ohos.aafwk.param.callerBundleName: ' + JSON.stringify(abilityWant.parameters['ohos.aafwk.param.callerBundleName']));
    HiLog.i(TAG, 'ohos.aafwk.param.callerPid: ' + JSON.stringify(abilityWant.parameters['ohos.aafwk.param.callerPid']));
    HiLog.i(TAG, 'action: ' + JSON.stringify(abilityWant.action));
    let parameters = abilityWant.parameters;
    let yellowPageId: string = '';
    if (abilityWant.action === 'mms.event.notification') {
      AppStorage.setOrCreate('isFromNotification', true);
      AppStorage.setOrCreate('isFromNotificationUseByBackPressOnly', true);
      HiLog.i(TAG, 'want parameters notificationType ' + parameters.notificationType);
      yellowPageId = parameters.yellowPageId;
    }
    if (abilityWant.action === 'ohos.want.action.sendData' && parameters['ability.picker.records']) {
      ConversationController.getInstance().shareFileIsForward(parameters['ability.params.stream'],
        parameters['ohos.aafwk.param.callerBundleName']).then((isForward) => {
        if (!isForward) {
          HiLog.i(TAG, 'share file exceeded the maximum');
          return;
        }
        HiLog.i(TAG, 'share send data');
        // 从图库共享到信息，收起设置页半模态
        AppStorage.setOrCreate('isSettingShow', false)
        let param = this.buildTransmitParam(context, parameters, Object.keys(parameters['ability.picker.records']));
        DynamicLoader.getInstance().fire('TransmitMsg').then(() => {
          pageInfos.pushPathByName('TransmitMsg', param);
        });
      })
    } else if (abilityWant.action === 'ohos.want.action.detectSendMsg') {
      // 点击短信内容中识别的号码发送短信
      let parameters = abilityWant.parameters;
      let pageFlag = 'conversation';
      let contactParams: LooseObject = {};
      if (parameters.contactObjects) {
        contactParams = ContactService.getInstance().dealContactParams(parameters.contactObjects);
      }
      let isSkipSmsHomePage = this.parameterCompare(parameters, abilityWant.action);
      if (isSkipSmsHomePage) {
        this.hideHomePage();
      }
      this.jump(context, pageFlag, contactParams, pageInfos, isSkipSmsHomePage, yellowPageId);
    } else if (!StringUtil.isEmpty(abilityWant.uri) && (!StringUtil.isEmpty(abilityWant.action) &&
      'ohos.want.action.viewData' === abilityWant.action)) {
      this.deepLinkJump(context, abilityWant, pageInfos);
    } else if (!StringUtil.isEmpty(abilityWant.uri) ||
      (!StringUtil.isEmpty(abilityWant.action) && 'mms.event.notification' != abilityWant.action)) {
      HiLog.i(TAG, `Third-party application redirection`)
      this.thirdPartJump(context, abilityWant, pageInfos);
    } else if (abilityWant.parameters) {
      let parameters = abilityWant.parameters;
      parameters.yellowPageId = yellowPageId;
      let isSkipSmsHomePage = this.parameterCompare(parameters, abilityWant.action);
      HiLog.i(TAG, 'isSkipSmsHomePage = ' + isSkipSmsHomePage);
      if (isSkipSmsHomePage) {
        this.hideHomePage();
        // 仅用于从联系人、通知、聚合搜索进入信息列表或者详情页，设置模态页需收起
        AppStorage.setOrCreate('isSettingShow', false)
      }
      /*
       * 获取对应的分类
       * */
      let wantCategory = WantMaster.cls(parameters, abilityWant.action);
      HiLog.i(TAG, 'current wantCategory: ' + wantCategory)
      if (wantCategory !== WantMaster.unKnowCategory) {
        let wantHelper: IWantHelper | undefined = WantMaster.createWantHelper(wantCategory, pageInfos, this)
        if (wantHelper !== undefined) {
          (wantHelper as IWantHelper).jump(context, parameters, isSkipSmsHomePage, yellowPageId)
          return
        }
      }
      let pageFlag = '';
      if (parameters.pageFlag) {
        pageFlag = parameters.pageFlag;
        HiLog.i(TAG, 'pageFlag = ' + pageFlag);
      }
      let searchMsgId = undefined;
      if (parameters.searchMsgId) {
        searchMsgId = parameters.searchMsgId;
      }
      let searchContent = undefined;
      if (parameters.searchContent) {
        searchContent = parameters.searchContent;
      }
      let contactParams: LooseObject = {}
      if (parameters.contactObjects) {
        HiLog.i(TAG, 'getWant dealContactParams');
        contactParams = ContactService.getInstance().dealContactParams(parameters.contactObjects);
      }
      if (parameters.content) {
        contactParams.content = parameters.content;
        HiLog.i(TAG, 'parameters.content = ' + parameters.content.length);
      }
      if (searchMsgId != undefined && searchContent != undefined) {
        this.jump(context, pageFlag, contactParams, pageInfos, isSkipSmsHomePage, yellowPageId, searchMsgId, searchContent);
      } else {
        this.jump(context, pageFlag, contactParams, pageInfos, isSkipSmsHomePage, yellowPageId);
      }
    }
  }

  public parameterCompare(parameters: LooseObject, wantActionStr: string): boolean {
    if (parameters['ohos.aafwk.param.callerBundleName'] && parameters['ohos.aafwk.param.callerBundleName'] ==
    commonData.STR.CONTACT_BUNDLE_NAME) {
      AppStorage.setOrCreate('comeFromContact', true);
      AppStorage.setOrCreate(commonData.STR.IS_BACK_HOMEPAGE, true);
      return true;
    }
    if (parameters['ohos.aafwk.param.callerBundleName'] && parameters['ohos.aafwk.param.callerBundleName'] ==
    commonData.STR.CONVERGENT_SEARCH_NAME && parameters.pageFlag === 'conversation') {
      AppStorage.setOrCreate(commonData.STR.IS_BACK_HOMEPAGE, true);
      return true;
    }
    if (parameters['ohos.aafwk.param.callerBundleName'] && parameters['ohos.aafwk.param.callerBundleName'] ==
    commonData.STR.LAUNCH_MMS_BY_MEETIME_SERVICE && parameters.pageFlag === 'conversation') {
      return true;
    }
    if (wantActionStr == 'mms.event.notification') {
      AppStorage.setOrCreate(commonData.STR.IS_BACK_HOMEPAGE, true);
      return true;
    }
    if (parameters['ohos.aafwk.param.callerBundleName'] && parameters['ohos.aafwk.param.callerBundleName'] ==
    commonData.STR.serviceaccess_BUNDLE_NAME) {
      AppStorage.setOrCreate('comeFromServiceaccess', true);
    }
    return false;
  }

  private hideHomePage() {
    AppStorage.setOrCreate('isHideIndexPage', true);
    EnhancedInfoTemporaryDataSource.getInstance().isHideIndexPage = true;
    this.timeOutIdOfHideIndexPage = setTimeout(() => {
      AppStorage.setOrCreate('isHideIndexPage', false);
      EnhancedInfoTemporaryDataSource.getInstance().isHideIndexPage = false;
    }, 2000);
  }

  // deepLink 网页url跳转短信
  private deepLinkJump(context: Context, abilityWant: AbilityWant, pageInfos: NavPathStack) {
    HiLog.i(TAG, 'deepLinkJump start');
    let parameters = abilityWant.parameters;
    let uri: string = abilityWant.uri;
    let number: string = '';
    // 格式化处理 手机号，  body 内容
    if (uri.startsWith(commonData.deepLinkUrl.SMS)) {
      let uris = uri.split(':');
      if (!StringUtil.isEmpty(uris[1])) {
          let splitsStr = this.getSplitsStr(uris[1]);
          let params = uris[1].split(splitsStr);
          number = params[0].replace(new RegExp(';*','g'),'');
          if (uris[1].indexOf(splitsStr) != -1) {
            let body = params[1].indexOf('=') != -1 ? params[1].split('=')[1] : '';
            // 处理body 内容
            parameters.content = this.getDecodeURIComponentUrl(body);
          }
          this.buildPhone(number, parameters);
      }
    } else {
      // smsto 只处理 手机号
      let uris = uri.split(':');
      if (!StringUtil.isEmpty(uris[1])) {
        number = uris[1].replace(new RegExp(';*', 'g'), '');
        this.buildPhone(number, parameters);
      }
    }
      let chatbotNumber = 'sip:' + number + '@botplatform.rcs.chinamobile.com';
      ConversationListService.getInstance().querySessionByTelephone(chatbotNumber,
        async (res: LooseObject) => {
            HiLog.i(TAG, 'deepLinkJump is sms');
            let contactParams: LooseObject = {};
            if (parameters.contactObjects) {
              HiLog.i(TAG, 'getWant dealContactParams');
              contactParams = ContactService.getInstance().dealContactParams(parameters.contactObjects);
            }
            if (parameters.content) {
              contactParams.content = parameters.content;
              HiLog.i(TAG, 'parameters.content = ' + parameters.content.length);
            }
            this.jump(context, 'CreateNewConversation', contactParams, pageInfos);
        }, context);
  }

  private getSplitsStr(url: string): string {
    let splitsStr = '?';
    if (url.includes('?')) {
      splitsStr = '?';
    } else if (url.includes('&')) {
      splitsStr = '&';
    }
    return splitsStr;
  }

  private getDecodeURIComponentUrl(url: string): string {
    let decodeURI = url;
    try {
      decodeURI = decodeURIComponent(url);
    } catch (error) {
      HiLog.e(TAG, 'getDecodeURIComponentUrl decodeURI uri error:' + (error as BusinessError).message);
    }
    return decodeURI;
  }

  private thirdPartJump(context: Context, abilityWant: AbilityWant, pageInfos: NavPathStack) {
    let parameters = abilityWant.parameters;
    let pageFlag = '';
    let uri: string = abilityWant.uri;
    let phone: string = '';

    if (!StringUtil.isEmpty(parameters.sms_body)) {
      parameters.content = parameters.sms_body;
    }

    if (!StringUtil.isEmpty(parameters.address)) {
      pageFlag = 'CreateNewConversation';
      phone = parameters.address;
      this.buildPhone(phone, parameters);
    }

    if (uri.startsWith(commonData.THIRD_PART_URI.SMS)) {
      HiLog.w(TAG,` third part uri start is sms:`)
      let uris = uri.split(':');
      if (!StringUtil.isEmpty(uris[1])) {
        HiLog.w(TAG,` third part the back of :  has a number by sms`)
        pageFlag = 'CreateNewConversation';
        this.thirdPartParsingDataAndJumpToCreatNew(uris, parameters);
      } else {
        let param: Record<string, number | boolean | string | LooseObject[]> = this.buildThirdParam(parameters);
        pageInfos.pushPathByName('TransmitMsg', param);
      }
    } else if (uri.startsWith(commonData.THIRD_PART_URI.SMS_TO)) {
      HiLog.w(TAG,` third part uri start is smsto:`)
      let uris = uri.split(':');
      if (!StringUtil.isEmpty(uris[1])) {
        HiLog.w(TAG,` third part the back of :  has a number by smsto`)
        pageFlag = 'CreateNewConversation';
        this.thirdPartParsingDataAndJumpToCreatNew(uris, parameters);
      } else {
        let param: Record<string, number | boolean | string | LooseObject[]> = this.buildThirdParam(parameters);
        pageInfos.pushPathByName('TransmitMsg', param);
      }
    }

    let contactParams: LooseObject = {};
    if (parameters.contactObjects) {
      HiLog.i(TAG, 'getWant dealContactParams');
      contactParams = ContactService.getInstance().dealContactParams(parameters.contactObjects);
    }
    if (parameters.content) {
      contactParams.content = parameters.content;
      HiLog.i(TAG, 'parameters.content = ' + parameters.content.length);
    }
    this.jump(context, pageFlag, contactParams, pageInfos);
  }

  /**
   * 三方跳转新建（带手机号）
   * 
   * @param uris 三方跳转uri被分割成的数组（包含手机号）
   * @param parameters 三方跳转携带的参数
   */
  private thirdPartParsingDataAndJumpToCreatNew(uris: string[], parameters: LooseObject): void {
    if (uris[1].indexOf('?') != -1) {
      HiLog.w(TAG, 'third Part has ?');
      let params = uris[1].split('?');
      let number = params[0].replace(new RegExp(';*', 'g'), '');
      let body = '';
      if (params[1].indexOf('=') != -1) {
        body = params[1].split('=')[1];
      }
      parameters.content = decodeURIComponent(body);
      this.buildPhone(number, parameters);
    } else if (uris[1].startsWith('+')) {
      HiLog.w(TAG, 'third Part has +');
      const result = uris[1].replace(/[^+\d]/g, '');
      this.buildPhone(result, parameters);
    } else {
      HiLog.w(TAG, 'third Part no has ? and +');
      const result = uris[1].replace(/[^+\d]/g, '');
      this.buildPhone(result, parameters);
    }
  }

  private buildPhone(number: string, parameters: LooseObject) {
    HiLog.w(TAG, 'buildPhone start:');
    let arrStr: [LooseObject] = [{
      'telephone': number,
      'telephoneFormat': number
    }];
    parameters.contactObjects = JSON.stringify(arrStr);
  }

  private buildThirdParam(parameters: LooseObject): Record<string, string | number | boolean | LooseObject[]> {
    HiLog.i(TAG, 'buildThirdParam start:');
    return {
      'transmitContent': '',
      'transmitContentList': [
        {
          'content': parameters.content,
          'isMsm': false,
          'mms': [],
          'contentInfo': '',
          'contentType': 0
        }
      ],
      'mmsStatus': 3,
      'transmitContentDetail': parameters.content,
      'isRcs': parameters?.isRcs || false
    };
  }

  /**
   * 根据彩信位置文本内容生成对应的txt附件
   * @param context Context
   * @param text 彩信位置文本内容
   * @returns textSource Mms
   */
  private getMmsMapTextSourceByText(context: Context, text: string) {
    HiLog.i(TAG, 'getMmsMapTextSourceByText');
    if (!context || !text) {
      HiLog.i(TAG, 'getMmsMapTextSourceByText: context or text is empty');
      return null;
    }
    let textSource: Mms = {
      duration: '',
      type: common.MM_ATTACHMENT_TYPE.TEXT,
      path: '',
      name: '',
    }
    let textObj: Record<string, string> = FileUtil.writeTextToSandBox(context, text, false);
    textSource.path = textObj.path;
    textSource.name = textObj.name;
    return textSource;
  }

  public buildTransmitParam(context: Context, parameters: LooseObject,
    keys: string[]): Record<string, string | number | boolean | LooseObject[]> {
    let transmitContentList: LooseObject[] = [];
    let hasMms: boolean = false;
    //key值为分享过来的文件的类型枚举值
    // keys.forEach((key) => {
    //   HiLog.i(TAG, 'buildTransmitParam start!');
    //   let records: systemShare.SharedRecord[] = parameters['ability.picker.records'][key];
    //   let streams: string[] = parameters['ability.params.stream'];
    //   // record['2']保存content，record['4']保存filename
    //   // record['7']保存extraData (当前仅存 ct-资源格式类型)
    //   let record: systemShare.SharedRecord = records[0]
    //   //key的枚举值是没顺序的，{"0":0,"1":0}{"0":2,"1":2}，"0"的值为该种类文件的在文件列表中的第几位
    //   let index = record['0'] as number
    //   let fileName = record['4'] as string;
    //   let ct = '';
    //   let ctRecord = record['7'] ? record['7'] as Record<string, string> : null;
    //   ct = ctRecord ? ctRecord?.mmsShareTransferMmsCt : '';
    //   HiLog.i(TAG, `buildTransmitParam get ctRecord is : ${JSON.stringify(ctRecord)}`);
    //   let fileSuffix = '';
    //   if (!StringUtil.isEmpty(fileName)) {
    //     fileSuffix = fileName.substring(fileName.lastIndexOf('.') + 1);
    //   }
    //
    //   let obj: Record<string, string | boolean | Mms[] | number> = {
    //     'content': '', 'isMsm': false, 'mms': [], 'contentInfo': '', 'contentType': 0
    //   };
    //
    //   let type: number | undefined = -1
    //   if (key == 'general.text' || key == 'general.plain-text') {
    //     type = commonData.MM_ATTACHMENT_TYPE.TEXT
    //   } else if (record['7'] && !record['7'][ShareExtraData.MESSAGE_IS_RCS] &&
    //     record['7'][ShareExtraData.MESSAGE_TYPE] === commonData.MM_ATTACHMENT_TYPE.MAP) {//彩信位置消息分享到信息应用的场景
    //     type = commonData.MM_ATTACHMENT_TYPE.MAP;
    //     obj.isRcs = record['7'][ShareExtraData.MESSAGE_IS_RCS] ?? undefined;
    //   } else {
    //     type = this.getMmsType(key, streams != null && streams.length > 0 ? streams[index] : '');
    //   }
    //   if (type === commonData.MM_ATTACHMENT_TYPE.TEXT && fileSuffix.toLowerCase() != 'txt') {
    //     obj.content = record['2'] ? record['2'] : '';
    //     transmitContentList.push(obj);
    //   } else if (type === commonData.MM_ATTACHMENT_TYPE.TEXT && fileSuffix.toLowerCase() === 'txt') {
    //     let stream = streams[index];
    //     obj.content = FileUtil.getTextFileContent(stream);
    //     transmitContentList.push(obj);
    //   } else if (type !== undefined && streams && streams.length > 0 && streams[index] != null) {
    //     let stream = streams[index];
    //     let mmsSource: Mms[] = [];
    //     let path = '';
    //     let name = '';
    //     let uri = '';
    //     let text: string | undefined = undefined; //附件的text属性
    //     let content: string | undefined = undefined; //附件的content属性
    //     let address: AddressInfo | undefined = undefined; //附件的address属性
    //     // audio duration
    //     let duration: string = record['2'] ? record['2'] : ''; //附件的duration属性
    //     if (fileSuffix === 'txt') {
    //       type = commonData.ENHANCED_INFO_ITEM_TYPE.FILE;
    //     }
    //     if (stream.indexOf('file://com.ohos.mms') === -1) {
    //       path = FileUtil.writeMediaToSandBox(context, stream, type, true);
    //       name = FileUtil.getFileName(path);
    //     } else {
    //       name = FileUtil.getFileName(stream);
    //       uri = FileUtil.getFileFullDirectoryUri(stream);
    //       let sandboxPath = FileUtil.getSandboxPath(context);
    //       let uriArr = uri.split(sandboxPath);
    //       sandboxPath = uriArr.length > 1 ? sandboxPath + uriArr[uriArr.length - 1] : sandboxPath;
    //       path = sandboxPath + '/' + name;
    //
    //       const textValue: string | undefined = record['7']?.[ShareExtraData.MESSAGE_CONTENT];
    //       if (type === commonData.MM_ATTACHMENT_TYPE.MAP && textValue) { //彩信位置消息分享到信息应用的场景
    //         HiLog.i(TAG, `buildTransmitParam: handle mms Map mesaage`);
    //         content = textValue;
    //         obj.content = '';
    //         const longitude: number | undefined = record['7'][ShareExtraData.MESSAGE_LONGITUDE];
    //         const latitude: number | undefined = record['7'][ShareExtraData.MESSAGE_LATITUDE];
    //         let tempArray = textValue.split('\n');
    //         let addressInfo: AddressInfo = new AddressInfo(latitude ?? 0, longitude ?? 0, tempArray?.[0] ?? '',
    //           tempArray?.[1] ?? '');
    //         address = addressInfo;
    //         text = JSON.stringify(addressInfo);
    //         let textSource = this.getMmsMapTextSourceByText(context, textValue);
    //         if (textSource) {
    //           mmsSource.push(textSource);
    //         }
    //       }
    //     }
    //     let size = FileUtil.getFileSizeByPath(path);
    //     let mms: Mms = this.getMms(duration, type, path, type === commonData.MM_ATTACHMENT_TYPE.MAP ? String(size) :
    //     this.setFileSize(size), name, text, content, address);
    //     if (!StringUtil.isEmpty(ct)) {
    //       mms.ct = ct;
    //       HiLog.i(TAG, `buildTransmitParam mms.ct: ${mms?.ct}`);
    //     }
    //     mmsSource.push(mms);
    //     obj.mms = mmsSource;
    //     obj.isMsm = true;
    //     hasMms = true;
    //     transmitContentList.push(obj);
    //   }
    // });
    return {
      'transmitContent': '', 'transmitContentList': transmitContentList, 'transmitContentDetail': '',
      'mmsStatus': hasMms ? commonData.TRANSMIT_MSG_STATUS.SHARE_MMS : commonData.TRANSMIT_MSG_STATUS.SHARE_SMS,
    };
  }

  getMms(duration: string, type: number, path: string, size: string, name: string, text?: string,
    content?: string, address?: AddressInfo): Mms {
    let mms: Mms = {
      duration: duration,
      type: type,
      path: path,
      name: name,
      size: size,
      text: text,
      content: content,
      address: address
    };
    return mms;
  }

  setFileSize(totalSize: number) {
    let fileSize: string = '';
    if (totalSize < commonData.int.RCS_FILE_SIZE) {
      fileSize = totalSize.toString() + 'B';
    } else if (totalSize > commonData.int.RCS_FILE_SIZE && totalSize < commonData.int.RCS_FILE_MAX_SIZE) {
      fileSize = (totalSize / commonData.int.RCS_FILE_SIZE).toFixed(2) + 'KB';
    } else {
      fileSize = (totalSize / commonData.int.RCS_FILE_MAX_SIZE).toFixed(2) + 'MB';
    }
    return fileSize;
  }

  getMmsType(record: string, stream: string): number | undefined {
    let isOnlineRcs = AppStorage.get('isOnlineRcs') as boolean;
    let utd = record;
    HiLog.i(TAG, 'getMmsType utd: ' + utd);
    if (utd === 'general.image' || utd === 'com.microsoft.bmp' || utd === 'general.jpeg' || utd === 'general.gif' ||
      utd === 'general.png' || utd === 'general.heic' || utd === 'general.heif') {
      return commonData.MM_ATTACHMENT_TYPE.IMAGE;
    } else if (utd === 'general.audio' || utd === 'general.mp3' || utd === 'general.m4a' || utd === 'general.mp2' ||
      utd === 'com.microsoft.waveform-audio' || utd === 'general.mpeg-4-audio' || utd === 'general.flac'
      || utd === 'general.aac') {
      if (isOnlineRcs && stream.indexOf('.m4a') != -1) {
        return 9;
      }
      return commonData.MM_ATTACHMENT_TYPE.AUDIO;
    } else if (utd === 'general.video' || utd === 'general.mpeg-4' || utd === 'org.matroska.mkv') {
      return commonData.MM_ATTACHMENT_TYPE.VIDEO;
    } else if (utd === 'general.text' || utd === 'general.plain-text') {
      return commonData.MM_ATTACHMENT_TYPE.TEXT;
    } else if (utd === 'general.vcard') {
      return commonData.MM_ATTACHMENT_TYPE.VCARD;
    }
    return undefined;
  }

  jump(context: Context, pageFlag: string, contactParams: LooseObject, pageInfos: NavPathStack, isSkipSmsHomePage?: boolean,
    yellowPageId: String = '', searchMsgId?: number, searchContent?: string) {
    let result: Result = {
      uri: '',
      params: {}
    };
    HiLog.i(TAG, 'want.pageFlag: ' + pageFlag);
    const showIndexPage = () => {
      if (isSkipSmsHomePage) {
        this.timeOutIdOfHideIndexPage && clearTimeout(this.timeOutIdOfHideIndexPage);
        this.timeOutIdOfHideIndexPage = null;
        AppStorage.setOrCreate('isHideIndexPage', false);
        EnhancedInfoTemporaryDataSource.getInstance().isHideIndexPage = false;
      }
    }
    switch (pageFlag) {
      case 'CreateNewConversation':
      case 'conversation':
        GlobalContext.getContext().setObject('isFromNotify', true)
        notifyStateParam.STATE = 1;
        DotUtil.getInstance().reportEvent(notifyStateParam, dotCommon.eventName.NOTIFICATION_OPERATION);
        onlyStateParam.STATE = 2;
        DotUtil.getInstance().reportEvent(onlyStateParam, dotCommon.eventName.CLICK_TO_VIEW_SMS_EVENT);
        if (contactParams) {
          result.params = contactParams;
          result.params.yellowPageId = yellowPageId;
          if (searchMsgId != undefined && searchContent != undefined) {
            result.params.msgId = searchMsgId;
            result.params.searchContent = searchContent;
          }
          this.jumpIsNewPage(context, result, contactParams, pageInfos, isSkipSmsHomePage);
        } else {
          result.uri = 'CreateNewConversation';
          HiLog.e(TAG, 'contactParams is null can not jump to correct conversation page')
          if (DeviceUtil.isFoldable() || DeviceUtil.isTablet() || DeviceUtil.isFloatingScreen()) {
            pageInfos.clear();
            pageInfos.replacePathByName(result.uri, result.params, false);
          } else {
            pageInfos.pushPathByName(result.uri, result.params, false);
          }
          showIndexPage();
        }
        break;
      case 'blockedList':
        showIndexPage();
        pageInfos.pushPathByName('BlockedPage', {
          pageFlag: 'BlockedPageDetail'
        } as PageFlag)
        break;
      case 'blockedGuidePage':
        showIndexPage();
        pageInfos.pushPathByName('BlockedGuidePage', {
          pageFlag: 'BlockedGuidePageDetail'
        } as PageFlag)
        break;
      case 'conversationList':
        pageInfos.clear();
        showIndexPage();
        AppStorage.set(commonData.STR.IS_BACK_HOMEPAGE, false);
        break;
      default:
        showIndexPage();
        break;
    }
  }

  async jumpIsNewPage(context: Context, result: Result, contactParams: LooseObject, pageInfos: NavPathStack, isSkipSmsHomePage?: boolean) {
    HiLog.i(TAG, 'jumpIsNewPage start:');
    if (contactParams.contactsNum as number == 1) {
      if (!contactParams.strContactsName) {
        let actionData: LooseObject = {};
        actionData.telephones = [contactParams.strContactsNumber];
        actionData.isFuzzyMatch = true;
        await ContactService.getInstance().getStrContactsName(context, actionData, contactParams);
      }
      // Format the redirected mobile number. xxx(xxxx)xxxx --->> xxx xxxx xxxx.
      contactParams.strContactsNumber = await TelephoneUtil.formatDisplayPhoneNumIntl(contactParams.strContactsNumber);
      // strContactsNumber Remove spaces. strContactsNumberFormat Contains Spaces.
      contactParams.strContactsNumber = TelephoneUtil.removeWhitespace(contactParams.strContactsNumber)
      contactParams.strContactsNumberFormat =
        await TelephoneUtil.formatDisplayPhoneNumIntl(contactParams.strContactsNumberFormat);
    }
    // Check whether a session has been created for the current phone number in the SMS message.
    ConversationListService.getInstance().querySessionByTelephone(contactParams.strContactsNumber, (res: LooseObject) => {
      if (res.code == common.int.SUCCESS && res.response.id > 0) {
        result.params.threadId = res.response.id;
        HiLog.i(TAG,'querySessionByTelephone from notification threadId is: ' + result.params.threadId);
        let actionData: LooseObject = {};
        actionData.threadId = result.params.threadId;
        ConversationListService.getInstance().markAllToRead(context, actionData,(update: Object)=>{
          let badgeContext: IBadgeContextInfo = {
            appContext: context,
            updateBadgeEventCode: 'jumpIsNewPage',
            tracedId: systemDateTime.getTime().toString(),
          }
          NotificationService.getInstance(context).updateBadgeNumberWithContext(badgeContext);
        });
        result.params.isDraft = res.response.hasDraft as boolean
        if (res.response.hasDraft as boolean && res.response.messageCount == 0) {
          //special NewMsg only with draft
          result.params.isNewMsgWithDraft = true;
          result.params.isNewMsg = true;
        } else {
          result.params.isNewMsg = false;
        }
      } else {
        result.params.isNewMsg = true;
      }
      result.params.rawContactId = contactParams.rawContactId;
      if (isSkipSmsHomePage) {
        this.timeOutIdOfHideIndexPage && clearTimeout(this.timeOutIdOfHideIndexPage);
        this.timeOutIdOfHideIndexPage = null;
        AppStorage.setOrCreate('isHideIndexPage', false);
        EnhancedInfoTemporaryDataSource.getInstance().isHideIndexPage = false;
      }
      pageInfos.clear();
      if (DeviceUtil.isFoldable() || DeviceUtil.isTablet() || DeviceUtil.isFloatingScreen()) {
        if (result.params.isNewMsg) {
          pageInfos.replacePathByName('CreateNewConversation', result.params, false);
        } else {
          pageInfos.replacePathByName('Conversation', result.params, false);
        }
      } else {
        if (result.params.isNewMsg) {
          pageInfos.pushPathByName('CreateNewConversation', result.params, false);
        } else {
          pageInfos.pushPathByName('Conversation', result.params, false);
        }
      }
    }, context);
  }
}

export default  new WantUtil()