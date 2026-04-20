/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
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
import { describe, beforeEach, it, expect, MockKit, ArgumentMatchers, when } from '@ohos/hypium';
import LooseObject from '../../../../../main/ets/data/LooseObject';
import { GlobalContext } from '../../../../../main/ets/MainAbility/GlobalHelper';
import { mmsListType } from '../../../../../main/ets/pages/conversation/conversationController';
import { messageType } from '../../../../../main/ets/pages/conversationlist/conversationListController';
import TransmitMsgController, {
  DialogMsg,
  MyParams
} from '../../../../../main/ets/pages/transmitmsg/transmitMsgController';
import ConversationListService, { ResponseType } from '../../../../../main/ets/service/ConversationListService';
import { TransmitContent } from '../../../../../main/ets/utils/TypesUtils';
import { ability, common, StartOptions, Want } from '@kit.AbilityKit';
import ContactService from '../../../../../main/ets/service/ContactsService';
import dateUtil, { DateFormatFactory, DateUtil } from '../../../../../main/ets/utils/DateUtil';
import DataShareHelper from '../../../../../main/ets/model/repository/DataShareHelper';
import { dataShare, dataSharePredicates, DataShareResultSet } from '@kit.ArkData';
import MySet from '../../MySet';
import { window } from '@kit.ArkUI';
import commonService from '../../../../../main/ets/service/CommonService';
import { DTGlobalContext } from '../../../testability/TestAbility';
import I18n from '@ohos.i18n';

export default function transmitMsgControllerTest() {
  describe('transmitMsgControllerTest', () => {

    let transmitMsgController: TransmitMsgController;
    let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;

    beforeEach(() => {
      transmitMsgController = TransmitMsgController.getInstance();
      transmitMsgController.pageInfos = new NavPathStack();
    })

    it('TransmitMsgController_onInit_mmsStatus_0', 0, () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(transmitMsgController, transmitMsgController.dealTransmitContentList))(ArgumentMatchers.any)
        .afterReturn([]);
      when(mocker.mockFunc(transmitMsgController, transmitMsgController.dealTransmitContentDetail))()
        .afterReturn({
          0: 'xx'
        } as Record<number, string>);
      let pageInfos: NavPathStack = new NavPathStack();
      let dialog = {} as CustomDialogController;
      pageInfos.pushPathByName('TransmitMsg', {
        transmitContent: "1,2",
        threadId: 1,
        mmsStatus: 0,
        transmitContentList: [],
      } as LooseObject);
      transmitMsgController.onInit(pageInfos, dialog, dialog, dialog, getContext() as common.UIAbilityContext);
      mocker.clear(transmitMsgController);
    })

    it('TransmitMsgController_onInit_mmsStatus_1', 0, () => {
      let pageInfos: NavPathStack = new NavPathStack();
      let dialog = {} as CustomDialogController;
      pageInfos.pushPathByName('TransmitMsg', {
        transmitContent: "1,2",
        threadId: 1,
        mmsStatus: 1,
        transmitContentList: [],
      } as LooseObject);
      transmitMsgController.onInit(pageInfos, dialog, dialog, dialog, getContext() as common.UIAbilityContext);
    })

    it('TransmitMsgController_onShow', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(transmitMsgController, transmitMsgController.requestItem);
      transmitMsgController.onShow();
      expect(transmitMsgController.page).assertEqual(0);
      mocker.clear(transmitMsgController);
    })

    it('TransmitMsgController_requestItem_page_0', 0, () => {
      transmitMsgController.page = 0;
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(transmitMsgController, transmitMsgController.queryAllMessages);
      transmitMsgController.requestItem();
      expect(transmitMsgController.page).assertEqual(1);
      mocker.clear(transmitMsgController);
    })

    it('TransmitMsgController_requestItem_page_1', 0, () => {
      transmitMsgController.page = 1;
      transmitMsgController.total = 10;
      transmitMsgController.limit = 1;
      transmitMsgController.contactsList = [new mmsListType(), new mmsListType()];
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(transmitMsgController, transmitMsgController.queryAllMessages);
      transmitMsgController.requestItem();
      expect(transmitMsgController.page).assertEqual(2);
      mocker.clear(transmitMsgController);
    })

    it('TransmitMsgController_queryAllMessages', 0, () => {
      let result = false;
      let queryPromise: Promise<LooseObject> = new Promise<LooseObject>(resolve => resolve({} as LooseObject));
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(Promise, Promise.all))(ArgumentMatchers.any)
        .afterReturn(new Promise<(number | boolean | LooseObject)[]>(resolve => resolve([{
          messageList: []
        }, 1, true])));
      when(mocker.mockFunc(transmitMsgController, transmitMsgController.buildSessionList))(ArgumentMatchers.any)
        .afterAction(() => {
          result = true;
          return [];
        });
      when(mocker.mockFunc(ConversationListService.getInstance(),
        ConversationListService.getInstance().getSessionListResult))(ArgumentMatchers.any)
        .afterReturn(queryPromise);
      when(mocker.mockFunc(ConversationListService.getInstance(),
        ConversationListService.getInstance().getSessionListSize))(ArgumentMatchers.any)
        .afterReturn(new Promise<number>(resolve => resolve(0)));
      when(mocker.mockFunc(ConversationListService.getInstance(),
        ConversationListService.getInstance().isExistNoticeMessage))(ArgumentMatchers.any)
        .afterReturn(new Promise<boolean>(resolve => resolve(false)));
      when(mocker.mockFunc(Promise, Promise.all))(ArgumentMatchers.any)
        .afterReturn(new Promise<LooseObject>(resolve => resolve({
          '1': 0,
          '2': false
        } as LooseObject)));
      when(mocker.mockFunc(transmitMsgController.transmitMsgDataSource,
        transmitMsgController.transmitMsgDataSource.refresh))(ArgumentMatchers.any)
        .afterAction(() => {
          expect(result).assertTrue();
        });
      transmitMsgController.queryAllMessages();
      mocker.clear(Promise);
      mocker.clear(transmitMsgController.transmitMsgDataSource);
      mocker.clear(transmitMsgController);
      mocker.clear(ConversationListService.getInstance());
    })

    it('TransmitMsgController_buildSessionList_threadId_0', 0, () => {
      let mmsListType0: mmsListType = {
        name: '',
        threadId: 0
      } as mmsListType;
      transmitMsgController.contactsList = [mmsListType0];
      let mmsListType: mmsListType = {
        name: 'roxy',
        threadId: 0
      } as mmsListType;
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(DateUtil, DateUtil.convertDateFormatForItem);
      mocker.mockFunc(transmitMsgController, transmitMsgController.dealMmsListContent);
      let result: LooseObject = {};
      result.response = [mmsListType];

      when(mocker.mockFunc(DateFormatFactory, DateFormatFactory.createDateTimeShortFormat))(ArgumentMatchers.any)
        .afterReturn(new Intl.DateTimeFormat(I18n.System.getSystemLocale(), {
          dateStyle: 'short'
        }));
      let result1: mmsListType[] = transmitMsgController.buildSessionList(result);
      expect(result1[0].threadId).assertEqual(0);
      mocker.clear(transmitMsgController);
      mocker.clear(DateFormatFactory);
      mocker.clear(DateUtil);
    })

    it('TransmitMsgController_buildSessionList_threadId_01', 0, () => {
      let mmsListType0: mmsListType = {
        name: '',
        threadId: 0,
      } as mmsListType;
      transmitMsgController.contactsList = [mmsListType0];
      let mmsListType: mmsListType = {
        name: 'roxy',
        threadId: 1
      } as mmsListType;
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(DateUtil, DateUtil.convertDateFormatForItem);
      mocker.mockFunc(transmitMsgController, transmitMsgController.dealMmsListContent);
      when(mocker.mockFunc(DateFormatFactory, DateFormatFactory.createDateTimeShortFormat))(ArgumentMatchers.any)
        .afterReturn(new Intl.DateTimeFormat(I18n.System.getSystemLocale(), {
          dateStyle: 'short'
        }));
      let result: LooseObject = {};
      result.response = [mmsListType];
      let result1: mmsListType[] = transmitMsgController.buildSessionList(result);
      expect(result1[0].threadId).assertEqual(1);
      mocker.clear(transmitMsgController);
      mocker.clear(DateUtil);
      mocker.clear(DateFormatFactory);
    })

    it('TransmitMsgController_buildSessionList_pubPort', 0, () => {
      let mmsListType0: mmsListType = {
        name: '',
        threadId: 0,
        telephone: '00000012365'
      } as mmsListType;
      transmitMsgController.contactsList = [mmsListType0];
      let mmsListType: mmsListType = {
        name: 'roxy',
        threadId: 1,
        telephone: '12365'
      } as mmsListType;
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(dateUtil, DateUtil.convertDateFormatForItem);
      mocker.mockFunc(transmitMsgController, transmitMsgController.dealMmsListContent);
      let result: LooseObject = {};
      result.response = [mmsListType];
      let result1: mmsListType[] = transmitMsgController.buildSessionList(result);
      expect(result1[0].telephone).assertEqual('12365');
      mocker.clear(transmitMsgController);
      mocker.clear(dateUtil);
    })

    it('TransmitMsgController_dealMmsListContent_1', 0, () => {
      let listType: mmsListType = new mmsListType();
      listType.hasMms = true;
      listType.hasAttachment = true;
      listType.content = '';
      transmitMsgController.dealMmsListContent(listType);
      expect(JSON.stringify(listType.content))
        .assertEqual(JSON.stringify($r('app.string.attachment_no_subject')));
    })

    it('TransmitMsgController_dealMmsListContent_2', 0, () => {
      let listType: mmsListType = new mmsListType();
      listType.hasMms = true;
      listType.hasAttachment = true;
      listType.content = 'hello';
      transmitMsgController.dealMmsListContent(listType);
      expect(JSON.stringify(listType.content))
        .assertEqual(JSON.stringify($r('app.string.attachment', 'hello')));
    })

    it('TransmitMsgController_dealMmsListContent_3', 0, () => {
      let listType: mmsListType = new mmsListType();
      listType.hasMms = true;
      listType.hasAttachment = false;
      listType.content = '';
      transmitMsgController.dealMmsListContent(listType);
      expect(JSON.stringify((listType.content)))
        .assertEqual(JSON.stringify($r('app.string.no_subject')));
    })

    it('TransmitMsgController_clickSendMessage', 0, () => {
      let item: messageType = new messageType();
      item.name = '';
      transmitMsgController.clickSendMessage(item);
      expect(transmitMsgController.contactName).assertEqual('');
    })

    it('TransmitMsgController_jumpToSelectContacts_resultCode_0', 0, () => {
      transmitMsgController.dialogMsg.mmsStatus = 0;
      transmitMsgController.transmitDialogController = {
        open: () => {
        }
      } as CustomDialogController;
      let contactObj: LooseObject = {
        contactsNum: 1,
        strContactsNumberFormat: '',
        strContactsNumber: '570977632',
        strContactsName: 'roxy,mike',
        rawContactId: 1,
      };

      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(ContactService.getInstance(),
        ContactService.getInstance().dealContactParams))(ArgumentMatchers.any).afterReturn(contactObj);
      let contactObjStr: string = JSON.stringify([contactObj]);
      let data: ability.AbilityResult = {
        resultCode: 0,
        want: {
          parameters: {
            contactObjects: contactObjStr
          }
        }
      } as ability.AbilityResult;
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('mmsContext')
        .afterReturn({
          startAbilityForResult: (want: Want, options?: StartOptions | undefined): Promise<ability.AbilityResult> =>
          new Promise<ability.AbilityResult>(resolve => resolve(data))
        });
      transmitMsgController.jumpToContactForResult(context);
      expect(JSON.stringify(transmitMsgController.dialogMsg.data)).assertUndefined();
      mocker.clear(ContactService.getInstance());
      mocker.clear(GlobalContext.getContext());
    })

    it('TransmitMsgController_jumpToSelectContacts_resultCode_3', 0, () => {
      let dialogMsg: DialogMsg = new DialogMsg();
      dialogMsg.mmsStatus = 3;
      transmitMsgController.dialogMsg = dialogMsg;
      transmitMsgController.transmitDialogController1 = {
        open: () => {
        }
      } as CustomDialogController;
      let contactObj: LooseObject = {
        contactsNum: 1,
        strContactsNumberFormat: '',
        strContactsNumber: '570977632',
        strContactsName: 'roxy,mike',
        rawContactId: 1,
      };
      let contactObjStr: string = JSON.stringify([contactObj]);
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(ContactService.getInstance(), ContactService.getInstance().dealContactParams))('xxx')
        .afterReturn(contactObj);
      let data: ability.AbilityResult = {
        resultCode: 0,
        want: {
          parameters: {
            contactObjects: contactObjStr
          }
        }
      } as ability.AbilityResult;
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('mmsContext')
        .afterReturn({
          startAbilityForResult: (want: Want, options?: StartOptions | undefined): Promise<ability.AbilityResult> =>
          new Promise<ability.AbilityResult>(resolve => resolve(data))
        });
      when(mocker.mockFunc(DataShareHelper.getInstance(),
        DataShareHelper.getInstance().initSmsDB))(ArgumentMatchers.any)
        .afterReturn({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve(new MySet()))
        } as dataShare.DataShareHelper);

      transmitMsgController.jumpToContactForResult(context);
      expect(transmitMsgController.contactsNum).assertEqual(0);
      mocker.clear(ContactService.getInstance());
      mocker.clear(GlobalContext.getContext());
      mocker.clear(DataShareHelper.getInstance());
    })

    it('TransmitMsgController_jumpToSelectContacts_resultCode_2', 0, () => {
      let dialogMsg: DialogMsg = new DialogMsg();
      dialogMsg.mmsStatus = 2;
      transmitMsgController.transmitMmsDialogController = {
        open: () => {
        }
      } as CustomDialogController;
      let contactObj = {
        contactsNum: 1,
        strContactsNumberFormat: '',
        strContactsNumber: '570977632',
        strContactsName: 'roxy,mike',
        rawContactId: 1,
      } as LooseObject;

      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(ContactService.getInstance(), ContactService.getInstance().dealContactParams))('xxx')
        .afterReturn(contactObj);
      let contactObjStr: string = JSON.stringify([contactObj]);
      let data: ability.AbilityResult = {
        resultCode: 0,
        want: {
          parameters: {
            contactObjects: contactObjStr
          }
        }
      } as ability.AbilityResult;
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('mmsContext')
        .afterReturn({
          startAbilityForResult: (want: Want, options?: StartOptions | undefined): Promise<ability.AbilityResult> =>
          new Promise<ability.AbilityResult>(resolve => resolve(data))
        });
      when(mocker.mockFunc(DataShareHelper.getInstance(),
        DataShareHelper.getInstance().initSmsDB))(ArgumentMatchers.any)
        .afterReturn(new Promise<dataShare.DataShareHelper | undefined>(resolve => resolve(undefined)));
      transmitMsgController.jumpToContactForResult(context);
      expect(transmitMsgController.contactsNum).assertEqual(0);
      mocker.clear(ContactService.getInstance());
      mocker.clear(GlobalContext.getContext());
      mocker.clear(DataShareHelper.getInstance());
    })

    it('TransmitMsgController_changeValue', 0, () => {
      let item: LooseObject = {
        content: ''
      };
      let e: LooseObject = {
        text: 'xx'
      };
      transmitMsgController.changeValue(item, e);
      expect(item.content).assertEqual('xx');
    })

    it('TransmitMsgController_transmit_true', 0, () => {
      transmitMsgController.threadId = 0;
      transmitMsgController.pageInfos.pushPathByName('Conversation', {
        threadId: 0
      } as LooseObject);
      transmitMsgController.pageInfos.pushPathByName('Conversation', {
        threadId: 0
      } as LooseObject);
      transmitMsgController.transmit(true, true);
      expect(((transmitMsgController.pageInfos.getParamByName('Conversation')[0]) as LooseObject).threadId)
        .assertEqual(0);
    })

    it('TransmitMsgController_jumpToSearchContact', 0, () => {
      transmitMsgController.jumpToSearchContact();
      expect((transmitMsgController.pageInfos.getParamByName('TransmitSearchMsg')[0] as MyParams).isRcs).assertFalse();
    })

    it('TransmitMsgController_dealTransmitContentList_array', 0, () => {
      let list1: Array<TransmitContent> = [{
        info: '',
        content: '',
        contactsName: '',
        isMsm: false,
        msgShowType: -1,
        msgUriPath: '',
        contentInfo: '',
        contentType: -1,
      } as TransmitContent];
      let list: Array<TransmitContent | Array<TransmitContent>> = [list1];
      let res: Array<TransmitContent | Array<TransmitContent>> = transmitMsgController.dealTransmitContentList(list);
      expect(JSON.stringify(res[0])).assertEqual(JSON.stringify(list1));
    })

    it('TransmitMsgController_dealTransmitContentList_obj_mms_length_1', 0, () => {
      let obj: TransmitContent = {
        info: '',
        content: '',
        contactsName: '',
        isMsm: false,
        msgShowType: -1,
        msgUriPath: '',
        contentInfo: '',
        contentType: -1,
        mms: [{
          duration: '',
          type: 1,
          path: '',
          name: '',
        }]
      } as TransmitContent;
      let list: Array<TransmitContent | Array<TransmitContent>> = [obj];
      let res: Array<TransmitContent | Array<TransmitContent>> = transmitMsgController.dealTransmitContentList(list);
      expect(JSON.stringify(res[0])).assertEqual(JSON.stringify(obj));
    })

    it('TransmitMsgController_dealTransmitContentList_obj_mms_length_0', 0, () => {
      let obj: TransmitContent = {
        info: '',
        content: '',
        contactsName: '',
        isMsm: false,
        msgShowType: -1,
        msgUriPath: '',
        contentInfo: '',
        contentType: -1,
        mms: []
      } as TransmitContent;
      let obj1: TransmitContent = {
        info: '',
        content: '',
        contactsName: '',
        isMsm: false,
        msgShowType: -1,
        msgUriPath: '',
        contentInfo: '',
        contentType: -1,
        mms: []
      } as TransmitContent;
      let list: Array<TransmitContent | Array<TransmitContent>> = [obj, obj1];
      let res: Array<TransmitContent | Array<TransmitContent>> = transmitMsgController.dealTransmitContentList(list);
      expect(JSON.stringify(res[0])).assertEqual(JSON.stringify([obj, obj1]));
    })

    it('TransmitMsgController_dealTransmitContentDetail_array', 0, () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(transmitMsgController, transmitMsgController.getMsgContent))(ArgumentMatchers.any)
        .afterReturn('');
      let transmitContentArr: Array<TransmitContent> = [];
      let transmitContentArr1: Array<TransmitContent> = [];
      let transmitContent: TransmitContent = new TransmitContent();
      transmitContent.content = "111";
      let transmitContent1: TransmitContent = new TransmitContent();
      transmitContent1.content = "222";
      transmitContentArr.push(transmitContent);
      transmitContentArr1.push(transmitContent1);
      transmitMsgController.transmitContentList = [transmitContentArr, transmitContentArr1];
      expect(transmitMsgController.dealTransmitContentDetail()[0]).assertEqual('');
      mocker.clear(transmitMsgController);
    })

    it('TransmitMsgController_dealTransmitContentDetail_obj', 0, () => {
      let transmitContent: TransmitContent = new TransmitContent();
      transmitContent.content = "111";
      transmitMsgController.transmitContentList = [];
      transmitMsgController.transmitContentList.push(transmitContent);
      expect(JSON.stringify(transmitMsgController.dealTransmitContentDetail())).assertEqual('{}');
    })

    it('TransmitMsgController_getMsgContent_index_0', 0, () => {
      let msgItem: Array<TransmitContent> = [{
        info: '',
        content: '',
        contactsName: '',
        isMsm: false,
        msgShowType: -1,
        msgUriPath: '',
        contentInfo: '',
        contentType: -1,
      }];
      expect(transmitMsgController.getMsgContent(msgItem)).assertEqual('');
    })

    it('TransmitMsgController_getMsgContent_index_1', 0, () => {
      let msgItem: Array<TransmitContent> = [{
        info: '',
        content: '',
        contactsName: '',
        isMsm: false,
        msgShowType: -1,
        msgUriPath: '',
        contentInfo: '',
        contentType: -1,
      }, {
        info: '',
        content: '',
        contactsName: '',
        isMsm: false,
        msgShowType: -1,
        msgUriPath: '',
        contentInfo: '',
        contentType: -1,
      }];
      expect(transmitMsgController.getMsgContent(msgItem)).assertEqual('\n' + ' ' + '\n');
    })

    it('TransmitMsgController_saveDraftAndTransmit_threadId_0', 0, () => {
      let pageInfos: NavPathStack = new NavPathStack();
      pageInfos.pushPathByName('xx', {
        threadId: 0
      } as LooseObject);
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(transmitMsgController, transmitMsgController.transmit);
      transmitMsgController.saveDraftAndTransmit(false, pageInfos, true);
      mocker.verify('transmit', [false]).never();
      mocker.clear(transmitMsgController);
    })

    it('TransmitMsgController_saveDraftAndTransmit_threadId_null', 0, () => {
      transmitMsgController.threadId = 1;
      let pageInfos: NavPathStack = new NavPathStack();
      pageInfos.pushPathByName('xx', {
        threadId: null
      } as LooseObject);
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(transmitMsgController, transmitMsgController.transmit);
      transmitMsgController.saveDraftAndTransmit(false, pageInfos, true);
      mocker.verify('transmit', [false]).never();
      mocker.clear(transmitMsgController);
    })

  })
}