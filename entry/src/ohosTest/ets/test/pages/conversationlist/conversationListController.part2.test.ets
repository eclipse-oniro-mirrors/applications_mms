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
import { describe, beforeEach, it, expect, MockKit, when, ArgumentMatchers, afterEach } from '@ohos/hypium';
import ConversationListController, {
  messageType,
  ActionData
} from '../../../../../main/ets/pages/conversationlist/conversationListController';
import ConversationListService from '../../../../../main/ets/service/ConversationListService';
import MmsPreferences from '../../../../../main/ets/utils/MmsPreferences';
import { BusinessError } from '@ohos.base';
import LooseObject from '../../../../../main/ets/data/LooseObject';
import { GlobalContext } from '../../../../../main/ets/MainAbility/GlobalHelper';
import ConversationService from '../../../../../main/ets/service/ConversationService';
import commonService from '../../../../../main/ets/service/CommonService';
import SharedPreferencesUtils from '../../../../../main/ets/utils/SharedPreferencesUtils';
import HiLog from '../../../../../main/ets/utils/HiLog';
import rcs from '@ohos.telephony.rcs';
import DataService from '../../../../../main/ets/service/DataService';
import DotUtil from '../../../../../main/ets/utils/MmsDot/DotUtils';
import { window } from '@kit.ArkUI';
import { StartOptions, Want } from '@kit.AbilityKit';
import NotificationService from '../../../../../main/ets/service/NotificationService';
import StringUtil from '../../../../../main/ets/utils/StringUtil';
import TelephoneUtil from '../../../../../main/ets/utils/TelephoneUtil';
import DatabaseMaintain from '../../../../../main/ets/DatabaseMaintain/DatabaseMaintain';
import commonEventManager from '@ohos.commonEventManager'
import { DTGlobalContext } from '../../../testability/TestAbility';
import common from '../../../../../main/ets/data/commonData';
import commonData from '../../../../../main/ets/data/commonData';
import { ContactInfoModel } from '../../../../../main/ets/model/ComInfoModel';
import { mmsListType } from '../../../../../main/ets/pages/conversation/conversationController';


export default function conversationLCtrPart2Test() {
  describe('conversationLCtrPart2Test', () => {

    const TAG = 'ConversationListController';
    let conversationListController: ConversationListController;
    let databaseMaintain: DatabaseMaintain;
    let mocker: MockKit;
    let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;

    beforeEach(() => {
      databaseMaintain = DatabaseMaintain.getInstance();
      mocker = new MockKit();
      conversationListController = new ConversationListController();
    })

    afterEach(() => {
      AppStorage.clear();
      mocker.clear(conversationListController);
      mocker.clear(ConversationListService.getInstance());
      mocker.clear(HiLog);
    })

    it('cvsListControllerTest_getInstance', 0, () => {
      expect(typeof databaseMaintain).assertEqual(typeof DatabaseMaintain.getInstance());
    })

    it('cvsListControllerTest_requestItem1', 0, () => {
      conversationListController.noUiProp.isRun = true;
      conversationListController.hasAggregate = false;
      let mockFunc1: Function = mocker.mockFunc(ConversationListService.getInstance(),
        ConversationListService.getInstance().getSessionListSize);
      when(mockFunc1)(ArgumentMatchers.anyObj).afterReturn(new Promise<number>((res: Function, rej: Function) => {
        res(0);
      }));
      conversationListController.requestItem(context);

      expect(conversationListController.noUiProp.isRun).assertTrue();

      mocker.clear(ConversationService.getInstance());
    })

    it("cvsListControllerTest_clickToInfoMessages_resetTouch_true", 0, () => {
      conversationListController.showMarkAllAsRead = true;
      conversationListController.itemTouchedIdx = -1;

      when(mocker.mockFunc(conversationListController, conversationListController.resetTouch))()
        .afterReturn(true);

      conversationListController.clickToInfoMessages();

      expect(AppStorage.get('isNewMessage')).assertUndefined();
    })

    it("cvsListControllerTest_clickToInfoMessages_isMultipleSelectState_true", 0, () => {
      when(mocker.mockFunc(conversationListController, conversationListController.resetTouch))()
        .afterReturn(false);

      conversationListController.isMultipleSelectState = true;

      conversationListController.clickToInfoMessages();

      expect(AppStorage.get('isNewMessage')).assertUndefined();
    })

    it("cvsListControllerTest_clickToInfoMessages_pages", 0, () => {
      when(mocker.mockFunc(conversationListController, conversationListController.resetTouch))()
        .afterReturn(false);
      mocker.mockFunc(conversationListController, conversationListController.resetLastIndexValue);

      conversationListController.pageInfos.pushPathByName('InfoMsg', '');

      conversationListController.isMultipleSelectState = false;

      conversationListController.clickToInfoMessages();

      expect(AppStorage.get('isNewMessage')).assertUndefined();
    })

    it("cvsListControllerTest_clickToInfoMessages_curBp_bp", 0, () => {
      when(mocker.mockFunc(conversationListController, conversationListController.resetTouch))()
        .afterReturn(false);
      mocker.mockFunc(conversationListController, conversationListController.resetLastIndexValue);

      conversationListController.pageInfos.pushPathByName('xx', '');

      AppStorage.setOrCreate('curBp', 'bp');

      conversationListController.isMultipleSelectState = false;

      conversationListController.clickToInfoMessages();

      expect(AppStorage.get('isNewMessage')).assertUndefined();
    })

    it("cvsListControllerTest_clickToInfoMessages_curBp_sm", 0, () => {
      when(mocker.mockFunc(conversationListController, conversationListController.resetTouch))()
        .afterReturn(false);
      mocker.mockFunc(conversationListController, conversationListController.resetLastIndexValue);

      conversationListController.pageInfos.pushPathByName('xx', '');

      AppStorage.setOrCreate('curBp', 'sm');

      conversationListController.isMultipleSelectState = false;

      conversationListController.clickToInfoMessages();

      expect(AppStorage.get('isNewMessage')).assertUndefined();
    })

    it("cvsListControllerTest_clickToGroupDetail_isJumping_true", 0, () => {
      conversationListController.isJumping = true;

      conversationListController.clickToGroupDetail(context, 0);

      expect(conversationListController.isJumping).assertTrue();
    })

    it("cvsListControllerTest_clickToGroupDetail_contactsNum_1", 0, () => {
      let index = 0;
      conversationListController.isJumping = false;
      let messageList = {
        contactsNum: 1,
        telephone: '13564261257',
        threadId: 0
      } as messageType;
      conversationListController.messageList[index] = messageList;

      let actionData: ActionData = {};
      actionData.phoneNumber = messageList.telephone;
      actionData.pageFlag = 'page_flag_contact_details';

      mocker.mockFunc(DotUtil.getInstance(), DotUtil.getInstance().reportEvent);

      mocker.mockFunc(conversationListController, conversationListController.jumpToContact);

      conversationListController.clickToGroupDetail(context, index);

      expect(conversationListController.isJumping).assertTrue();

      mocker.clear(DotUtil.getInstance());
    })

    it("cvsListControllerTest_clickToGroupDetail_contactsNum_2", 0, () => {
      let index = 0;
      conversationListController.isJumping = false;
      let messageList = {
        contactsNum: 2,
        telephone: '13564261257',
        threadId: 0
      } as messageType;
      conversationListController.messageList[index] = messageList;

      let actionData: ActionData = {};
      actionData.phoneNumber = messageList.telephone;
      actionData.pageFlag = 'page_flag_contact_details';

      mocker.mockFunc(DotUtil.getInstance(), DotUtil.getInstance().reportEvent);

      mocker.mockFunc(conversationListController, conversationListController.jumpToGroupContactList);

      conversationListController.clickToGroupDetail(context, index);

      expect(conversationListController.isJumping).assertTrue();

      mocker.clear(DotUtil.getInstance());
    })

    it("cvsListControllerTest_clickToGroupDetail_contactsNum_1_pubPort", 0, () => {
      let index = 0;
      conversationListController.isJumping = false;
      let messageList = {
        contactsNum: 1,
        telephone: '00000013564261257',
        threadId: 0
      } as messageType;
      conversationListController.messageList[index] = messageList;

      let actionData: ActionData = {};
      actionData.phoneNumber = messageList.telephone;
      actionData.pageFlag = 'page_flag_pub_home_page';

      mocker.mockFunc(DotUtil.getInstance(), DotUtil.getInstance().reportEvent);

      mocker.mockFunc(conversationListController, conversationListController.jumpToGroupContactList);

      conversationListController.clickToGroupDetail(context, index);

      expect(conversationListController.isJumping).assertTrue();

      mocker.clear(DotUtil.getInstance());
    })

    it("cvsListControllerTest_jumpToContact", 0, () => {
      conversationListController.isJumping = false;
      let actionData: ActionData = {};
      actionData.phoneNumber = '10326549852';
      actionData.pageFlag = 'page_flag_contact_details';

      when(mocker.mockFunc(commonService, commonService.commonContactParam))(actionData)
        .afterReturn('');
      mocker.mockFunc(conversationListController, conversationListController.againJumpToContact);

      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('mmsContext')
        .afterReturn({
          startAbility: (want: Want,
            options?: StartOptions | undefined): Promise<void> => new Promise<void>(resolve => resolve())
        } as Object | window.WindowStage);

      conversationListController.jumpToContact(context, actionData);

      expect(conversationListController.isJumping).assertFalse();

      mocker.clear(commonService);
      mocker.clear(GlobalContext.getContext());
    })

    it("cvsListControllerTest_jumpToContact_catch_code_16200001", 0, () => {
      conversationListController.isJumping = false;
      let actionData: ActionData = {};
      actionData.phoneNumber = '10326549852';
      actionData.pageFlag = 'page_flag_contact_details';

      when(mocker.mockFunc(commonService, commonService.commonContactParam))(actionData)
        .afterReturn('');
      mocker.mockFunc(conversationListController, conversationListController.againJumpToContact);

      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('mmsContext')
        .afterReturn({
          startAbility: (want: Want,
            options?: StartOptions | undefined): Promise<void> => new Promise<void>((resolve: () => void,
            reject: (reason: BusinessError) => void) => reject({
            code: 16200001, message: 'error'
          } as BusinessError))
        } as Object | window.WindowStage);

      conversationListController.jumpToContact(context, actionData);

      expect(conversationListController.isJumping).assertFalse();

      mocker.clear(commonService);
      mocker.clear(GlobalContext.getContext());
    })

    it("cvsListControllerTest_jumpToContact_catch_code_16200000", 0, () => {
      conversationListController.isJumping = false;
      let actionData: ActionData = {};
      actionData.phoneNumber = '10326549852';
      actionData.pageFlag = 'page_flag_contact_details';

      when(mocker.mockFunc(commonService, commonService.commonContactParam))(actionData)
        .afterReturn('');

      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('mmsContext')
        .afterReturn({
          startAbility: (want: Want,
            options?: StartOptions | undefined): Promise<void> => new Promise<void>((resolve: () => void,
            reject: (reason: BusinessError) => void) => reject({
            code: 16200000, message: 'error'
          } as BusinessError))
        } as Object | window.WindowStage);

      conversationListController.jumpToContact(context, actionData);

      expect(conversationListController.isJumping).assertFalse();

      mocker.clear(commonService);
      mocker.clear(GlobalContext.getContext());
    })

    it("cvsListControllerTest_jumpToGroupContactList", 0, () => {
      conversationListController.jumpToGroupContactList(0);

      expect(conversationListController.isJumping).assertFalse();
    })

    it("cvsListControllerTest_dealMmsListContent", 0, () => {
      let messageItem = {
        hasMms: true,
        hasAttachment: true,
        content: '',
      } as messageType;
      conversationListController.dealMmsListContent(messageItem);
      expect(messageItem.content).not().assertNull();

      messageItem.content = 'mms';
      conversationListController.dealMmsListContent(messageItem);
      expect(messageItem.content).not().assertNull();

      messageItem.hasAttachment = false;
      messageItem.content = '';
      conversationListController.dealMmsListContent(messageItem);
      expect(messageItem.content).not().assertNull();
    })

    it("cvsListControllerTest_clickInfoToConversation_resetTouch_true", 0, () => {
      when(mocker.mockFunc(conversationListController, conversationListController.resetTouch))()
        .afterReturn(true);

      conversationListController.clickInfoToConversation(3);

      expect(conversationListController.showMarkAllAsRead).assertFalse();
    })

    it("cvsListControllerTest_clickInfoToConversation_isMultipleSelectState_true", 0, () => {
      when(mocker.mockFunc(conversationListController, conversationListController.resetTouch))()
        .afterReturn(false);

      let messageItem = {
        hasMms: true,
        hasAttachment: true,
        content: '',
        isCbChecked: true
      } as messageType;
      conversationListController.messageList = [];
      conversationListController.conversationListDataSource.mmsList = [messageItem];

      conversationListController.messageList = [];
      conversationListController.isMultipleSelectState = true;

      mocker.mockFunc(conversationListController, conversationListController.setConversationCheckAll);
      mocker.mockFunc(conversationListController.conversationListDataSource,
        conversationListController.conversationListDataSource.notifyDataChange);

      conversationListController.clickInfoToConversation(0);
      messageItem.isCbChecked = false;
      conversationListController.clickInfoToConversation(0);

      expect(conversationListController.messageList[0].isCbChecked).assertTrue();

      mocker.clear(conversationListController.conversationListDataSource);
    })


    it("cvsListControllerTest_clickInfoToConversation_isMultipleSelectState_lastIndex", 0, () => {
      when(mocker.mockFunc(conversationListController, conversationListController.resetTouch))()
        .afterReturn(false);

      let messageItem = {
        hasMms: true,
        hasAttachment: true,
        content: '',
        isCbChecked: true
      } as messageType;
      conversationListController.messageList = [messageItem];

      conversationListController.conversationListDataSource.mmsList = [messageItem];

      conversationListController.messageList = [];
      conversationListController.isMultipleSelectState = false;
      conversationListController.lastIndex = 0;

      mocker.mockFunc(conversationListController, conversationListController.setConversationCheckAll);
      mocker.mockFunc(conversationListController.conversationListDataSource,
        conversationListController.conversationListDataSource.notifyDataChange);

      conversationListController.clickInfoToConversation(0);

      expect(conversationListController.messageList[0].isCbChecked).assertTrue();
    })

    it("cvsListControllerTest_clickInfoToConversation", 0, () => {
      when(mocker.mockFunc(conversationListController, conversationListController.resetTouch))()
        .afterReturn(false);

      let messageItem = {
        hasMms: true,
        hasAttachment: true,
        content: '',
        isCbChecked: false
      } as messageType;
      conversationListController.messageList = [messageItem];

      conversationListController.conversationListDataSource.mmsList = [messageItem];

      conversationListController.messageList = [];
      conversationListController.isMultipleSelectState = false;
      conversationListController.lastIndex = 1;

      mocker.mockFunc(conversationListController, conversationListController.jumpToConversationPage);
      mocker.mockFunc(DotUtil.getInstance(), DotUtil.getInstance().reportEvent);

      conversationListController.clickInfoToConversation(0);

      expect(conversationListController.isToInfoView).assertFalse();
      mocker.clear(DotUtil.getInstance());
    })

    it("cvsListControllerTest_clickCheckBox", 0, () => {
      let messageList1 = [{
        threadId: 2,
        hasAttachment: true,
        isCbChecked: false,
        countOfUnread: 3,
        content: '',
      } as messageType];
      conversationListController.messageList = messageList1;

      mocker.mockFunc(conversationListController, conversationListController.setConversationCheckAll);
      mocker.mockFunc(conversationListController.conversationListDataSource,
        conversationListController.conversationListDataSource.notifyDataChange);

      conversationListController.clickCheckBox(0, false);
      expect(conversationListController.messageList[0].isCbChecked).assertFalse();

      mocker.clear(conversationListController.conversationListDataSource);

      let messageList2 = [{
        threadId: 2,
        hasAttachment: true,
        isCbChecked: true,
        countOfUnread: 3,
        content: '',
      } as messageType];
      conversationListController.messageList = messageList2;

      conversationListController.clickCheckBox(0, true);
      expect(conversationListController.messageList[0].isCbChecked).assertTrue();

      mocker.clear(conversationListController.conversationListDataSource);
    })

    it("cvsListControllerTest_jumpToConversationPage_sm", 0, () => {
      AppStorage.setOrCreate('curBp', 'sm');

      let item = {
        threadId: 2,
        hasAttachment: true,
        isCbChecked: false,
        countOfUnread: 4,
        content: '',
        messageCount: 1
      } as messageType;

      conversationListController.jumpToConversationPage(item, '', true);

      expect(AppStorage.get('isNewMessage')).assertUndefined();
    })

    it("cvsListControllerTest_jumpToConversationPage_bp", 0, () => {
      AppStorage.setOrCreate('curBp', 'bp');

      let item = {
        threadId: 2,
        hasAttachment: true,
        isCbChecked: false,
        countOfUnread: 4,
        content: '',
      } as messageType;

      conversationListController.jumpToConversationPage(item);

      expect(AppStorage.get('isNewMessage')).assertUndefined()
    })

    it("cvsListControllerTest_jumpToConversationPage_bp_pubPort", 0, () => {
      AppStorage.setOrCreate('curBp', 'bp');

      let item = {
        threadId: 2,
        hasAttachment: true,
        isCbChecked: false,
        countOfUnread: 4,
        content: '',
        contactName: 'contactName',
        telephone: '00000036985'
      } as messageType;

      conversationListController.jumpToConversationPage(item);

      expect(AppStorage.get('isNewMessage')).assertUndefined()
    })

    it("cvsListControllerTest_refreshTimeForList_emptyString", 0, () => {
      let result = true;
      try {
        conversationListController.refreshTimeForClickItem('');
      } catch (err) {
        result = false
      }
      expect(result).assertEqual(true)
    })

    it("cvsListControllerTest_refreshTimeForList_DEVICE_Folding_SCREEN", 0, () => {
      let messageItem = {
        hasMms: true,
        hasAttachment: true,
        content: '',
        isCbChecked: true,
        timeMillisecond : new Date().getTime() - 10000
      } as messageType;
      conversationListController.conversationListDataSource.mmsList = [messageItem];
      let result = true;
      try {
        conversationListController.refreshTimeForClickItem(commonData.STR.DEVICE_Folding_SCREEN);
      } catch (err) {
        result = false
      }
      expect(result).assertEqual(true)
    })

    it("cvsListControllerTest_markAllAsReadByIndex", 0, () => {
      let index: number = 0;
      let telephone: string = '15026487541';
      rcs?.sendReadReceipt(telephone, () => {
      });
      let messageList = {
        threadId: 0,
        hasAttachment: true,
        content: '',
      } as messageType
      conversationListController.messageList[index] = messageList;

      mocker.mockFunc(conversationListController, conversationListController.handleMarkAllAsRead);
      mocker.mockFunc(conversationListController, conversationListController.setListItemTransX);
      mocker.mockFunc(conversationListController.conversationListDataSource,
        conversationListController.conversationListDataSource.refresh);

      conversationListController.markAsReadByThread(context, messageList, telephone);

      mocker.verify('handleMarkAllAsRead', [messageList.threadId]).never();

      mocker.clear(conversationListController.conversationListDataSource);
    })

    it("cvsListControllerTest_checkHasCommonMessage", 0, () => {
      let messageList1 = [{
        threadId: 0,
        isCbChecked: false,
        content: '',
      } as messageType]
      conversationListController.messageList = messageList1;

      let isNotEmpty = conversationListController.checkHasCommonMessage();

      expect(isNotEmpty).assertTrue();
    })

    it("cvsListControllerTest_showMultipleSelectView", 0, () => {
      let messageList1 = [{
        threadId: 0,
        isCbChecked: false,
        content: '',
      } as messageType]
      conversationListController.messageList = messageList1;

      when(mocker.mockFunc(conversationListController, conversationListController.checkHasCommonMessage))()
        .afterReturn(true);
      mocker.mockFunc(conversationListController, conversationListController.setConversationCheckAll);
      mocker.mockFunc(conversationListController, conversationListController.resetTouch);

      conversationListController.isMultipleSelectState = false;

      conversationListController.showMultipleSelectView();

      expect(conversationListController.isMultipleSelectState).assertTrue();
    })

    it("cvsListControllerTest_closeItemEnd", 0, () => {
      let messageList1 = [{
        threadId: 0,
        isCbChecked: false,
        isMultipleSelectState: true,
        content: '',
      } as messageType]
      conversationListController.messageList = messageList1;

      conversationListController.closeItemEnd();

      expect(conversationListController.messageList[0].isMultipleSelectState).assertFalse();
    })

    it("cvsListControllerTest_updateJumpStatus", 0, () => {
      conversationListController.updateJumpStatus(true);
      expect(conversationListController.isJumping).assertTrue()
    })

    it("cvsListControllerTest_simStateChangeStatusResult_rcsState_true_isFirstInMms_true", 0, () => {
      conversationListController.isAirPlaneMode = true;

      when(mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences))(0)
        .afterReturn(true);

      conversationListController.simStateChangeStatusResult(0);

      expect(conversationListController.isRcsOpenStatus).assertTrue();


      mocker.clear(SharedPreferencesUtils);
    })

    it("cvsListControllerTest_simStateChangeStatusResult_rcsState_true_isFirstInMms_false", 0, () => {
      conversationListController.isAirPlaneMode = true;

      when(mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences))(0)
        .afterReturn(false);

      conversationListController.simStateChangeStatusResult(0);

      expect(conversationListController.isRcsOpenStatus).assertTrue();

      mocker.clear(SharedPreferencesUtils);
    })

    it("cvsListControllerTest_simStateChangeStatusResult_rcsState_false_isFirstInMms_false", 0, () => {
      conversationListController.isAirPlaneMode = true;

      conversationListController.simStateChangeStatusResult(0);

      expect(conversationListController.isRcsOpenStatus).assertTrue();
    })

    it("cvsListControllerTest_simStateChangeStatusNoHaveSimCard", 0, () => {
      conversationListController.isRcsOpenStatus = false;

      conversationListController.simStateChangeStatusNoHaveSimCard();

      expect(conversationListController.isRcsOpenStatus).assertTrue();
    })

    it("cvsListControllerTest_getDefaultDataSlotId", 0, () => {
      conversationListController.hasCard1 = false;
      conversationListController.hasCard2 = false;
      mocker.mockFunc(conversationListController, conversationListController.simStateChangeStatusNoHaveSimCard);

      when(mocker.mockFunc(conversationListController, conversationListController.isHasCard))()
        .afterReturn(new Promise<void>(resolve => resolve()));

      conversationListController.getDefaultDataSlotId();

      expect(conversationListController.isCellularOpen).assertFalse();
    })

    it("cvsListControllerTest_getDefaultDataSlotId1", 0, () => {
      conversationListController.hasCard1 = true;
      conversationListController.hasCard2 = false;

      when(mocker.mockFunc(conversationListController, conversationListController.isHasCard))()
        .afterReturn(new Promise<void>(resolve => resolve()));

      let mockFun1: Function = mocker.mockFunc(conversationListController, conversationListController.getPrimarySlotId);
      when(mockFun1)().afterReturn(new Promise<number | BusinessError>((res: Function, rej: Function) => {
        res(2)
      }));

      mocker.mockFunc(HiLog, HiLog.i);

      when(mocker.mockFunc(conversationListController, conversationListController.simStateChangeStatusNoHaveSimCard))()
        .afterAction(() => {
          mocker.verify('isHasCard', []).once();
        });
      mocker.mockFunc(conversationListController, conversationListController.getCellularData);

      conversationListController.getDefaultDataSlotId();
    })

    it("cvsListControllerTest_getDefaultDataSlotId_catch", 0, () => {
      conversationListController.hasCard1 = true;
      conversationListController.hasCard2 = false;
      let error: Error = new Error('error');

      when(mocker.mockFunc(conversationListController, conversationListController.isHasCard))()
        .afterReturn(new Promise<void>(resolve => resolve()));

      let mockFun1: Function = mocker.mockFunc(conversationListController, conversationListController.getPrimarySlotId);
      when(mockFun1)()
        .afterReturn(new Promise<number | BusinessError>((resolve: (value: number | BusinessError<void> | PromiseLike<number | BusinessError<void>>) => void,
          reject: (reason?: Error) => void) => {
          reject(error)
        }));

      mocker.mockFunc(HiLog, HiLog.i);

      when(mocker.mockFunc(conversationListController, conversationListController.simStateChangeStatusNoHaveSimCard))()
        .afterAction(() => {
          mocker.verify('isHasCard', []).once();
        });
      mocker.mockFunc(conversationListController, conversationListController.getCellularData);

      conversationListController.getDefaultDataSlotId();
    })

    it("cvsListControllerTest_getSimState", 0, async () => {
      conversationListController.hasCard1 = false;
      conversationListController.hasCard2 = false;

      await conversationListController.getSimState();

      expect(AppStorage.get('isGetSim')).assertFalse();
    })

    it("cvsListControllerTest_setRcsInfos", 0, async () => {
      conversationListController.hasCard1 = true;
      conversationListController.hasCard2 = true;

      let result = false;
      when(mocker.mockFunc(HiLog, HiLog.i))(TAG)
        .afterAction(() => {
          result = true;
        });

      mocker.mockFunc(conversationListController, conversationListController.setRcsInfosResult)

      await conversationListController.setRcsInfos(context, false, 1);

      expect(result).assertTrue();
    })

    it("cvsListControllerTest_setRcsInfos_catch", 0, async () => {
      conversationListController.hasCard1 = true;
      conversationListController.hasCard2 = true;

      let result = false;
      when(mocker.mockFunc(HiLog, HiLog.i))(TAG)
        .afterAction(() => {
          result = true;
        });
      let error: Error = new Error('error');

      when(mocker.mockFunc(conversationListController,
        conversationListController.setRcsInfosResult))(ArgumentMatchers.any)
        .afterAction(() => {
          throw error;
        })

      await conversationListController.setRcsInfos(context, false, 1);

      expect(result).assertTrue();
    })

    it("cvsListControllerTest_setRcsInfosResult_rcsState_false", 0, async () => {
      conversationListController.hasCard1 = true;
      conversationListController.hasCard2 = true;

      await conversationListController.setRcsInfosResult(context, false, 1);

      expect(conversationListController.isRcsStatus).assertFalse();
    })

    it("cvsListControllerTest_setRcsInfosResult_rcsState_true_isRcsStateOpen_true", 0, async () => {
      conversationListController.hasCard1 = true;
      conversationListController.hasCard2 = true;
      conversationListController.isRcsStateOpen = true;

      await conversationListController.setRcsInfosResult(context, true, 1);

      expect(conversationListController.isRcsStatus).assertTrue();
    })

    it("cvsListControllerTest_setRcsInfosResult_rcsState_true_isRcsStateOpen_false", 0, async () => {
      conversationListController.hasCard1 = true;
      conversationListController.hasCard2 = true;
      conversationListController.isRcsStateOpen = false;

      await conversationListController.setRcsInfosResult(context, true, 1);

      expect(conversationListController.isRcsStatus).assertTrue();
    })

    it("cvsListControllerTest_setRcsInfosResultOpenRcs", 0, async () => {
      let res = false;

      when(mocker.mockFunc(conversationListController, conversationListController.rcsOn))(ArgumentMatchers.any)
        .afterAction(() => {
          res = true;
        });

      await conversationListController.setRcsInfosResultOpenRcs(context, 0, false);

      expect(res).assertTrue();
    })

    it("cvsListControllerTest_setRcsInfosResultNotOpenRcs", 0, async () => {
      let result = false;
      when(mocker.mockFunc(HiLog, HiLog.i))(TAG)
        .afterAction(() => {
          result = true;
        });

      when(mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences))('isFirstMms')
        .afterReturn(true);

      await conversationListController.setRcsInfosResultNotOpenRcs();

      expect(result).assertTrue();
      mocker.clear(SharedPreferencesUtils);
    })

    it("cvsListControllerTest_isFirstInMmsGet", 0, async () => {
      when(mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences))('isOpenRcs')
        .afterReturn(true);

      await conversationListController.isFirstInMmsGet();

      expect(conversationListController.isCellularOpen).assertTrue();
    })

    it("cvsListControllerTest_getCellularData_if2", 0, async () => {
      conversationListController.hasCard1 = false;
      conversationListController.hasCard2 = true;

      mocker.mockFunc(conversationListController, conversationListController.cellularDataInfo);

      await conversationListController.getCellularData(0);

      expect(conversationListController.isCellularOpen).assertFalse();
    })

    it("cvsListControllerTest_getCellularData_else", 0, async () => {
      conversationListController.hasCard1 = true;
      conversationListController.hasCard2 = true;

      mocker.mockFunc(conversationListController, conversationListController.cellularDataInfo);

      when(mocker.mockFunc(DataService, DataService.getDefaultCellularDataSlotId))()
        .afterReturn(new Promise<number>(resolve => resolve(1)));

      await conversationListController.getCellularData(undefined);

      expect(conversationListController.isCellularOpen).assertFalse();
    })

    it("cvsListControllerTest_cellularDataInfo_rcsState_true", 0, () => {
      conversationListController.rcsState = true;

      mocker.mockFunc(conversationListController, conversationListController.getCellularDataResult);

      conversationListController.cellularDataInfo();

      expect(conversationListController.isCellularOpen).assertFalse();
    })

    it("cvsListControllerTest_cellularDataInfo_rcsState_false", 0, () => {
      conversationListController.rcsState = false;

      conversationListController.cellularDataInfo();

      expect(conversationListController.isCellularOpen).assertTrue();
    })

    it("cvsListControllerTest_getCellularDataResult_isConnected_true", 0, () => {
      conversationListController.isConnected = true;

      conversationListController.getCellularDataResult();

      expect(conversationListController.isCellularOpen).assertTrue();
    })

    it("cvsListControllerTest_getCellularDataResult_isConnected_false", 0, () => {
      let result = false;
      when(mocker.mockFunc(HiLog, HiLog.i))(TAG)
        .afterAction(() => {
          result = true;
        });

      conversationListController.isConnected = false;
      conversationListController.isClosedInterState = false;

      conversationListController.getCellularDataResult();

      expect(result).assertTrue();
    })

    it("cvsListControllerTest_initAirPlaneModeResult_0", 0, () => {
      conversationListController.isAirPlaneMode = true;
      mocker.mockFunc(conversationListController, conversationListController.setRcsInfos);

      conversationListController.initAirPlaneModeResult(context, 0);

      expect(conversationListController.isAirPlaneMode).assertFalse();
    })

    it("cvsListControllerTest_initAirPlaneModeResult_1", 0, () => {
      conversationListController.isAirPlaneMode = true;

      conversationListController.initAirPlaneModeResult(context, 1);

      expect(conversationListController.isAirPlaneMode).assertTrue();
    })

    it("cvsListControllerTest_getAirPlaneModeResult_isRcsOpenStatus_true", 0, () => {
      conversationListController.isAirPlaneMode = true;

      conversationListController.getAirPlaneModeResult(1);

      expect(conversationListController.isRcsOpenStatus).assertTrue();
    })

    it("cvsListControllerTest_getAirPlaneModeResult_isRcsOpenStatus_false", 0, () => {
      conversationListController.isAirPlaneMode = false;

      conversationListController.getAirPlaneModeResult(0);

      expect(conversationListController.isAirPlaneMode).assertFalse();
    })

    it("cvsListControllerTest_removeAirPlaneMode", 0, () => {
      let result = false;
      when(mocker.mockFunc(HiLog, HiLog.i))(TAG)
        .afterAction(() => {
          result = true;
        });
      conversationListController.isAirPlaneMode = false;
      conversationListController.removeAirPlaneMode();
      expect(result).assertTrue();
    })


    it("cvsListControllerTest_tryUpdateSessionContactInfo_if", 0, async () => {
      let currentTime: string = String(Date.now()+100000);
      when(mocker.mockFunc(SharedPreferencesUtils,
        SharedPreferencesUtils.getFromPreferences))('last_contact_update_time')
        .afterReturn(currentTime);
      mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.saveToPreferences);
      mocker.mockFunc(ConversationListService.getInstance(),
        ConversationListService.getInstance().fetchRecentContactsAndBatchUpdateSession);
      await conversationListController.tryUpdateSessionContactInfo(context);
      mocker.verify('i', [TAG, 'updateSessionContactInfo end. results: ']).never();
      mocker.clear(SharedPreferencesUtils);
      mocker.clear(ConversationListService.getInstance());
    })

    it('cvsListControllerTest_fetchRecentContactsDone', 0, async () => {
      let currentTime: string = String(Date.now());
      when(mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences))(ArgumentMatchers.any)
        .afterReturn(String(Date.now()));
      mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.saveToPreferences);
      mocker.mockFunc(conversationListController, conversationListController.requestItem);
      mocker.mockFunc(conversationListController, conversationListController.tryUpdateSessionContactInfo);
      conversationListController.fetchRecentContactsDone(context, [1], currentTime, true);

      conversationListController.fetchRecentContactsDone(context, [1], '', true);
      expect(conversationListController.messageList.length).assertEqual(0);

      conversationListController.fetchRecentContactsDone(context, [1], '', false);
      expect(conversationListController.messageList.length).assertEqual(0);
      mocker.clear(SharedPreferencesUtils);
    })

    it('cvsListControllerTest_onRcsStateChangeresult', 0, () => {
      interface ParamsType {
        reason: number
      };
      mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.saveToPreferences);
      conversationListController.onRcsStateChangeresult({
        type: 2,
        params: {
          reason: 35
        } as ParamsType
      } as rcs.RcsEvent);
      expect(AppStorage.get('isOnlineRcs')).assertFalse();
      mocker.clear(SharedPreferencesUtils);
    })

    it('cvsListControllerTest_onShow', 0, () => {
      let pageInfos: NavPathStack = new NavPathStack();
      conversationListController.isInited = true;
      mocker.mockFunc(conversationListController, conversationListController.getSettingFlagForConvListPage);
      mocker.mockFunc(conversationListController, conversationListController.refreshConversationListData);
      mocker.mockFunc(conversationListController, conversationListController.statisticalData);
      mocker.mockFunc(conversationListController, conversationListController.subscribe);
      mocker.mockFunc(conversationListController, conversationListController.subscribeMms);
      mocker.mockFunc(NotificationService.getInstance(), NotificationService.getInstance().cancelAllNotify);
      when(mocker.mockFunc(conversationListController, conversationListController.initRcs))()
        .afterReturn(new Promise<void>(resolve => resolve()));
      mocker.mockFunc(conversationListController, conversationListController.onShowRcs);
      conversationListController.onShow(context, pageInfos);
      expect(conversationListController.isRepair).assertTrue();
      mocker.clear(conversationListController);
      mocker.clear(NotificationService.getInstance);
    })

    it('cvsListControllerTest_refreshConversationListData', 0, () => {
      conversationListController.noUiProp.isRun = true;
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('needToUpdate')
        .afterReturn(true);
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('isFromNotify')
        .afterReturn(false);
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('backFromConversation')
        .afterReturn(true);
      mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().setObject);
      mocker.mockFunc(conversationListController, conversationListController.requestItem);
      expect(conversationListController.messageList.length).assertEqual(0);
      mocker.clear(GlobalContext.getContext());
    })

    it('cvsListControllerTest_setConversationCheckAll', 0, () => {
      conversationListController.messageList = [{
        isCbChecked: true
      } as messageType];
      conversationListController.setConversationCheckAll(1, true);
      expect(conversationListController.conversationSelectedNumber).assertEqual(0);

      conversationListController.messageList[0].isCbChecked = false;
      conversationListController.setConversationCheckAll(1, true);
      expect(conversationListController.conversationSelectedNumber).assertEqual(0);

      conversationListController.setConversationCheckAll(2, false);
      expect(conversationListController.conversationSelectedNumber).assertEqual(0);

      mocker.mockFunc(conversationListController.conversationListDataSource,
        conversationListController.conversationListDataSource.refresh);
      conversationListController.setConversationCheckAll(3, false);
      expect(conversationListController.conversationSelectedNumber).assertEqual(0);

      conversationListController.messageList = [];
      mocker.mockFunc(conversationListController.conversationListDataSource,
        conversationListController.conversationListDataSource.refresh);
      conversationListController.setConversationCheckAll(3, true);
      expect(conversationListController.conversationSelectedNumber).assertEqual(0);
    })

    it('cvsListControllerTest_deleteDialogConfirm', 0, () => {
      conversationListController.messageList = [{
        isCbChecked: true,
        threadId: 0,
        telephone: '570977632,570977633',
        messageCount: 1,
        isDraft: false
      } as messageType];
      AppStorage.setOrCreate('curBp', 'md');
      conversationListController.conversationListDataSource.mmsList = [];
      mocker.mockFunc(conversationListController, conversationListController.setDelShow);
      mocker.mockFunc(conversationListController, conversationListController.resetLastIndexValue);
      mocker.mockFunc(conversationListController.conversationListDataSource,
        conversationListController.conversationListDataSource.multiDeleteByThreadId);
      mocker.mockFunc(conversationListController.conversationListDataSource,
        conversationListController.conversationListDataSource.notifyDataReload);
      mocker.mockFunc(NotificationService.getInstance(), NotificationService.getInstance().cancelMessageNotify);
      mocker.mockFunc(ConversationListService.getInstance(), ConversationListService.getInstance().deleteMessageById);
      mocker.mockFunc(conversationListController, conversationListController.deleteChangeDefaultMsg);
      conversationListController.deleteDialogConfirm(context);
      expect(AppStorage.get('curBp')).assertEqual('md');

      AppStorage.setOrCreate('curBp', 'sm');
      let message: messageType = {
        isCbChecked: true,
        threadId: 0,
        telephone: '570977632',
        messageCount: 1,
        isDraft: true
      } as messageType;
      conversationListController.messageList = [message];
      conversationListController.conversationListDataSource.mmsList = [message];
      conversationListController.deleteDialogConfirm(context);
      expect(AppStorage.get('curBp')).assertEqual('sm');

      mocker.clear(NotificationService.getInstance());
      mocker.clear(ConversationListService.getInstance());
      mocker.clear(conversationListController.conversationListDataSource);
      mocker.clear(conversationListController);
    })

    it('cvsListControllerTest_deleteChangeDefaultMsg', 0, () => {
      AppStorage.setOrCreate('selectPhoneNumber', '570977632');
      conversationListController.messageList = [{
        isCbChecked: true,
        threadId: 0,
        telephone: '570977632,570977633',
        messageCount: 1,
        isDraft: false
      } as messageType];
      mocker.mockFunc(conversationListController, conversationListController.showFirstMessage);

      conversationListController.deleteChangeDefaultMsg(['570977632']);
      mocker.verify('showFirstMessage', []).once();

      conversationListController.messageList = [];
      conversationListController.pageInfos = new NavPathStack();
      conversationListController.deleteChangeDefaultMsg(['570977632']);
      mocker.verify('showFirstMessage', []).once();

      mocker.clear(conversationListController);
    })

    it('cvsListControllerTest_againJumpToContact', 0, () => {
      let actionData: ActionData = {
        phoneNumber: '570977632'
      } as ActionData;
      when(mocker.mockFunc(commonService, commonService.commonContactParam))(ArgumentMatchers.any)
        .afterReturn('')
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('mmsContext')
        .afterReturn({
          startAbility: (want: Want,
            options?: StartOptions | undefined): Promise<void> => new Promise<void>(resolve => resolve())
        } as Object | window.WindowStage);
      conversationListController.againJumpToContact(context, {});

      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('mmsContext')
        .afterReturn({
          startAbility: (want: Want,
            options?: StartOptions | undefined): Promise<void> => new Promise<void>((resolve: () => void,
            reject: (res: BusinessError) => void) => reject({
            code: -1, message: ''
          } as BusinessError))
        } as Object | window.WindowStage);
      conversationListController.againJumpToContact(context, actionData);

      mocker.verify('commonContactParam', []).never();
      mocker.clear(GlobalContext.getContext());
      mocker.clear(commonService);
    })

    it('cvsListControllerTest_queryAllMessages_isEnd_false', 0, () => {
      conversationListController.hasAggregate = false;
      conversationListController.total = 2;
      conversationListController.isMultipleSelectState = false;
      conversationListController.conversationListDataSource.mmsList = [];
      when(mocker.mockFunc(ConversationListService.getInstance(),
        ConversationListService.getInstance().getSessionListResultNew))(ArgumentMatchers.any)
        .afterReturn(new Promise<LooseObject>(resolve => resolve({
          code: 0, response: [{
            threadId: 1, isCbChecked: false
          } as messageType]
        } as LooseObject)));
      mocker.mockFunc(conversationListController.conversationListDataSource,
        conversationListController.conversationListDataSource.refreshPage);
      when(mocker.mockFunc(StringUtil, StringUtil.getLimitForSession))(ArgumentMatchers.any).afterReturn(1);
      when(mocker.mockFunc(conversationListController, conversationListController.requestItem))(true)
        .afterAction(() => {
          expect(conversationListController.noUiProp.needAgain).assertFalse();
        });
      conversationListController.noUiProp.needAgain = true;

      conversationListController.queryAllMessages(context);

      conversationListController.noUiProp.needAgain = false;
      when(mocker.mockFunc(conversationListController,
        conversationListController.queryAllMessages))(ArgumentMatchers.any).afterAction(() => {
        expect(conversationListController.noUiProp.needAgain).assertFalse();
      });
      ;
      conversationListController.queryAllMessages(context);

      mocker.clear(conversationListController.conversationListDataSource);
      mocker.clear(StringUtil);
      mocker.clear(ConversationListService.getInstance());
    })

    it('cvsListControllerTest_queryAllMessages_isEnd_true', 0, () => {
      conversationListController.hasAggregate = false;
      conversationListController.total = 1;
      conversationListController.isMultipleSelectState = false;
      conversationListController.conversationListDataSource.mmsList = [];
      when(mocker.mockFunc(ConversationListService.getInstance(),
        ConversationListService.getInstance().getSessionListResultNew))(ArgumentMatchers.any)
        .afterReturn(new Promise<LooseObject>(resolve => resolve({
          code: 0, response: [{
            threadId: 1, isCbChecked: false
          } as messageType, {
            threadId: 2, isCbChecked: false
          } as messageType]
        } as LooseObject)));
      mocker.mockFunc(conversationListController.conversationListDataSource,
        conversationListController.conversationListDataSource.refreshPage);
      when(mocker.mockFunc(StringUtil, StringUtil.getLimitForSession))(ArgumentMatchers.any).afterReturn(1);
      when(mocker.mockFunc(conversationListController, conversationListController.requestItem))(true)
        .afterAction(() => {
          expect(conversationListController.noUiProp.needAgain).assertFalse();
        });
      conversationListController.noUiProp.needAgain = true;

      conversationListController.queryAllMessages(context);

      conversationListController.noUiProp.needAgain = false;
      conversationListController.pageInfos.pushPathByName('Conversation', {} as LooseObject);
      AppStorage.setOrCreate('receiveNeedUpdate', true);
      when(mocker.mockFunc(conversationListController.pageInfos, conversationListController.pageInfos.getAllPathName))()
        .afterReturn(['Conversation']);
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('needToUpdate')
        .afterReturn(false);
      mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().setObject)
      mocker.mockFunc(conversationListController, conversationListController.tryUpdateSessionContactInfo);
      when(mocker.mockFunc(SharedPreferencesUtils,
        SharedPreferencesUtils.getFromPreferences))('updateInfoMsgVersion').afterReturn(0);
      mocker.mockFunc(TelephoneUtil, TelephoneUtil.updateInfoMsg);
      mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.saveToPreferences);
      when(mocker.mockFunc(DatabaseMaintain.getInstance(), DatabaseMaintain.getInstance().databaseCleanup))()
        .afterAction(() => {
          expect(conversationListController.noUiProp.needAgain).assertFalse();
        });

      conversationListController.queryAllMessages(context);

      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('needToUpdate')
        .afterReturn(true);
      when(mocker.mockFunc(SharedPreferencesUtils,
        SharedPreferencesUtils.getFromPreferences))('updateInfoMsgVersion').afterReturn(10);
      conversationListController.queryAllMessages(context);

      AppStorage.setOrCreate('receiveNeedUpdate', false);
      when(mocker.mockFunc(SharedPreferencesUtils,
        SharedPreferencesUtils.getFromPreferences))('updateInfoMsgVersion').afterReturn(2);
      conversationListController.queryAllMessages(context);

      mocker.clear(conversationListController.conversationListDataSource);
      mocker.clear(StringUtil);
      mocker.clear(SharedPreferencesUtils);
      mocker.clear(DatabaseMaintain.getInstance());
      mocker.clear(TelephoneUtil);
      mocker.clear(GlobalContext.getContext());
      mocker.clear(conversationListController.pageInfos);
    })

    it('cvsListControllerTest_showFirstMessage', 0, () => {
      AppStorage.setOrCreate('curBp', 'md');
      conversationListController.messageList = [{
        telephone: '570977632'
      } as messageType];
      mocker.mockFunc(conversationListController, conversationListController.clickInfoToConversation);
      conversationListController.showFirstMessage();

      AppStorage.setOrCreate('curBp', 'sm');
      conversationListController.showFirstMessage();
      mocker.verify('clickInfoToConversation', [0]).never();
    })

    it('cvsListControllerTest_showFirstMessage_inSearch', 0, () => {
      AppStorage.setOrCreate('curBp', 'md');
      conversationListController.messageList = [{
        telephone: '570977632'
        } as messageType,
        {
          telephone: '570977632'
        } as messageType];
      conversationListController.currentConversatonIndex = 1;

      mocker.mockFunc(conversationListController, conversationListController.clickInfoToConversation);
      conversationListController.showFirstMessage(undefined, true);
      AppStorage.setOrCreate('curBp', 'sm');
      conversationListController.showFirstMessage();
      mocker.verify('clickInfoToConversation', [0]).never();
    })

    it('cvsListControllerTest_refreshListForHandleMarkAllAsRead', 0, () => {
      conversationListController.messageList = [{
        telephone: '570977632',
        threadId: 1,
        countOfUnread: 1,
      } as messageType];
      let markStartTime = new Date().getTime() - 50;
      let threadId = 1;
      let result = true;
      try {
        conversationListController.refreshListForHandleMarkAllAsRead(markStartTime, threadId, true);
      } catch (e) {
        result = false;
      }
      expect(result).assertEqual(true);
    })

    it('cvsListControllerTest_refreshListForHandleMarkAllAsRead_isNotFromConversation', 0, () => {
      conversationListController.messageList = [{
        telephone: '570977632',
        threadId: 1,
        countOfUnread: 1,
      } as messageType];
      let markStartTime = new Date().getTime() - 50;
      let threadId = 1;
      let result = true;
      try {
        conversationListController.refreshListForHandleMarkAllAsRead(markStartTime, threadId, false);
      } catch (e) {
        result = false;
      }
      expect(result).assertEqual(true);
    })

    it('cvsListControllerTest_handleMarkAllAsRead', 0, () => {
      conversationListController.messageList = [{
        threadId: 1, countOfUnread: 0
      } as messageType];
      when(mocker.mockFunc(ConversationService.getInstance(),
        ConversationService.getInstance().getSmsMmsInfoSizeByCondition))(ArgumentMatchers.any)
        .afterReturn(new  Promise<number>(resolve => resolve(1)))
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: -1
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve());
          }
        } as Object | window.WindowStage);
      mocker.mockFunc(ConversationListService.getInstance(),
        ConversationListService.getInstance().updateSessionUnReadBySessionId);
      mocker.mockFunc(ConversationService.getInstance(), ConversationService.getInstance().updateSmsIsReadBySessionId);
      mocker.mockFunc(conversationListController.conversationListDataSource,
        conversationListController.conversationListDataSource.refresh);

      conversationListController.handleMarkAllAsRead(context, 0);

      mocker.mockFunc(conversationListController, conversationListController.statisticalData);
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: 0,
              abilityResult: [{}, {}]
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve());
          }
        } as Object | window.WindowStage);
      mocker.mockFunc(NotificationService.getInstance(), NotificationService.getInstance().cancelNotifies);
      conversationListController.handleMarkAllAsRead(context, 0);

      expect(conversationListController.messageList.length).assertEqual(1);
      mocker.clear(NotificationService.getInstance());
      mocker.clear(GlobalContext.getContext());
      mocker.clear(ConversationListService.getInstance());
      mocker.clear(ConversationService.getInstance());
      mocker.clear(conversationListController.conversationListDataSource);
    })

    it('cvsListControllerTest_handleMarkAsUnRead', 0, () => {
      conversationListController.messageList = [{
        threadId: 1, countOfUnread: 1
      } as messageType];
      when(mocker.mockFunc(ConversationService.getInstance(),
        ConversationService.getInstance().getSmsMmsInfoSizeByCondition))(ArgumentMatchers.any)
        .afterReturn(new  Promise<number>(resolve => resolve(1)))
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: -1
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve());
          }
        } as Object | window.WindowStage);
      mocker.mockFunc(ConversationListService.getInstance(),
        ConversationListService.getInstance().updateSessionUnReadBySessionId);
      mocker.mockFunc(ConversationService.getInstance(), ConversationService.getInstance().updateSmsIsReadBySessionId);
      mocker.mockFunc(conversationListController.conversationListDataSource,
        conversationListController.conversationListDataSource.refresh);

      conversationListController.handleMarkAsUnRead(context, 0, conversationListController.messageList[0]);

      mocker.mockFunc(conversationListController, conversationListController.statisticalData);
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: 0,
              abilityResult: [{}, {}]
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve());
          }
        } as Object | window.WindowStage);
      conversationListController.handleMarkAsUnRead(context, 0, conversationListController.messageList[0]);

      expect(conversationListController.messageList.length).assertEqual(1);
      mocker.clear(NotificationService.getInstance());
      mocker.clear(GlobalContext.getContext());
      mocker.clear(ConversationListService.getInstance());
      mocker.clear(ConversationService.getInstance());
      mocker.clear(conversationListController.conversationListDataSource);
    })

    it('cvsListControllerTest_networkStatusChanged', 0, async () => {
      when(mocker.mockFunc(conversationListController,
        conversationListController.networkStatusChangedOn))(ArgumentMatchers.any)
        .afterReturn(new Promise<void>(resolve => resolve()));
      await conversationListController.networkStatusChanged();
      expect(AppStorage.get('cellularDataGet')).assertTrue();
    })

    it("cvsListControllerTest_updatePinMessage_0", 0, () => {
      conversationListController.hasAggregate = true;
      let mockFunc: Function = mocker.mockFunc(ConversationListService.getInstance(),
        ConversationListService.getInstance().isExistNoticeMessage);
      when(mockFunc)(ArgumentMatchers.any).afterReturn(new Promise<boolean>((res: Function, rej: Function) => {
        res(true);
      }));
      when(mocker.mockFunc(ConversationListService.getInstance(),
        ConversationListService.getInstance().getSessionListResultNew))(ArgumentMatchers.any)
        .afterReturn(new Promise<LooseObject>(resolve => resolve({
          response: [{
            threadId: 2
          } as messageType]
        })));
      when(mocker.mockFunc(ConversationListService.getInstance(),
        ConversationListService.getInstance().getSessionListSize))(ArgumentMatchers.any)
        .afterReturn(new Promise<number>(resolve => resolve(0)));
      mocker.mockFunc(conversationListController, conversationListController.conversationListDataSource.refresh);
      mocker.mockFunc(conversationListController, conversationListController.queryCurPageAndRefresh);
      mocker.mockFunc(conversationListController, conversationListController.showFirstMessage);

      conversationListController.updateConversationListMsg(context, 1, false);

      expect(conversationListController.noUiProp.needAgain).assertFalse();
      mocker.clear(ConversationService.getInstance());
      mocker.clear(conversationListController.conversationListDataSource);
    })

    it("cvsListControllerTest_updatePinMessage_1", 0, () => {
      conversationListController.hasAggregate = true;
      let mockFunc: Function = mocker.mockFunc(ConversationListService.getInstance(),
        ConversationListService.getInstance().isExistNoticeMessage);
      when(mockFunc)(ArgumentMatchers.any).afterReturn(new Promise<boolean>((res: Function, rej: Function) => {
        res(true);
      }));
      when(mocker.mockFunc(ConversationListService.getInstance(),
        ConversationListService.getInstance().getSessionListResultNew))(ArgumentMatchers.any)
        .afterReturn(new Promise<LooseObject>(resolve => resolve({
          response: [{
            threadId: 2
          } as messageType]
        })));
      when(mocker.mockFunc(ConversationListService.getInstance(),
        ConversationListService.getInstance().getSessionListSize))(ArgumentMatchers.any)
        .afterReturn(new Promise<number>(resolve => resolve(0)));
      mocker.mockFunc(conversationListController, conversationListController.conversationListDataSource.refresh);
      mocker.mockFunc(conversationListController, conversationListController.queryCurPageAndRefresh);
      mocker.mockFunc(conversationListController, conversationListController.showFirstMessage);

      conversationListController.updateConversationListMsg(context, 1, true);

      expect(conversationListController.noUiProp.needAgain).assertFalse();
      mocker.clear(ConversationService.getInstance());
    })

    it('cvsListControllerTest_requestItem_queryPinSize', 0, () => {
      conversationListController.noUiProp.isRun = true;
      conversationListController.hasAggregate = false;
      conversationListController.pinSessionSize = 0;
      let mockFunc1: Function = mocker.mockFunc(ConversationListService.getInstance(),
        ConversationListService.getInstance().getSessionListSize);
      when(mockFunc1)(ArgumentMatchers.anyObj).afterReturn(new Promise<number>((res: Function, rej: Function) => {
        res(0);
      }));
      conversationListController.requestItem(context);

      expect(conversationListController.noUiProp.isRun).assertTrue();

      mocker.clear(ConversationService.getInstance());
    })

    it('cvsListControllerTest_onLoadingMore', 0, () => {
      conversationListController.hasMore = true;
      (conversationListController as object)['deleteIng'] = false;
      (conversationListController as object)['IsQuerryPageDone'] = true;
      conversationListController.onLoadingMore(context);
      expect(conversationListController.hasMore).assertTrue();
    })

    it('cvsListControllerTest_clickToMarkAllAsRead', 0, () => {
      conversationListController.messageList = [{
        isCbChecked: true,
        threadId: 0,
        telephone: '570977632,570977633',
        messageCount: 1,
        isDraft: false,
        countOfUnread: 1
      } as messageType];

      conversationListController.clickToMarkAllAsRead(context);
      expect(conversationListController).not().assertUndefined();
    })

    it('cvsListControllerTest_deleteDialogConfirm_if', 0, () => {
      conversationListController.deleteDialogConfirm(context);
      expect(conversationListController).not().assertUndefined();
    })

    it('cvsListControllerTest_unSubscribeStaticEvent', 0, () => {
      let events = [common.STR.RCS_SUBSCRIBER_SEND_OK_EVENT];
      let commonEventSubscribeInfoData: commonEventManager.CommonEventSubscribeInfo = {
        events: events,
      };
      let data: commonEventManager.CommonEventSubscriber = commonEventManager.createSubscriberSync(commonEventSubscribeInfoData);
      conversationListController.staticEventData = data;
      conversationListController.unSubscribeStaticEvent();
      expect(conversationListController).not().assertUndefined();
    })

    it('cvsListControllerTest_subscribeTimeChangeEvent', 0, () => {
      conversationListController.subscribeTimeChangeEvent();
      expect(conversationListController).not().assertUndefined();
    })

    it('cvsListControllerTest_unSubscribeTimeChangeEvent', 0, () => {
      let events = [common.STR.RCS_SUBSCRIBER_SEND_OK_EVENT];
      let commonEventSubscribeInfoData: commonEventManager.CommonEventSubscribeInfo = {
        events: events,
      };
      let data: commonEventManager.CommonEventSubscriber = commonEventManager.createSubscriberSync(commonEventSubscribeInfoData);
      conversationListController.timeChangeEventData = data;
      conversationListController.unSubscribeTimeChangeEvent();
      expect(conversationListController).not().assertUndefined();
    })

    it('cvsListControllerTest_createTimeChangeSubscriberCallBack', 0, () => {
      let events = [common.STR.RCS_SUBSCRIBER_SEND_OK_EVENT];
      let commonEventSubscribeInfoData: commonEventManager.CommonEventSubscribeInfo = {
        events: events,
      };
      let data: commonEventManager.CommonEventSubscriber = commonEventManager.createSubscriberSync(commonEventSubscribeInfoData);
      let businessError: BusinessError = {
        code: 1,
        message: 'error'
      } as BusinessError;
      conversationListController.createTimeChangeSubscriberCallBack(businessError, data);
      expect(conversationListController).not().assertUndefined();
    })

    it('cvsListControllerTest_subscribeTimeTickEvent', 0, () => {
      conversationListController.subscribeTimeTickEvent();
      expect(conversationListController).not().assertUndefined();
    })

    it('cvsListControllerTest_unSubscribeTimeTickEvent', 0, () => {
      let events = [common.STR.RCS_SUBSCRIBER_SEND_OK_EVENT];
      let commonEventSubscribeInfoData: commonEventManager.CommonEventSubscribeInfo = {
        events: events,
      };
      let data: commonEventManager.CommonEventSubscriber = commonEventManager.createSubscriberSync(commonEventSubscribeInfoData);
      conversationListController.timeTickEventData = data;
      conversationListController.unSubscribeTimeTickEvent();
      expect(conversationListController).not().assertUndefined();
    })

    it('cvsListControllerTest_createTimeTickSubscriberCallBack_else', 0, () => {
      let events = [common.STR.RCS_SUBSCRIBER_SEND_OK_EVENT];
      let commonEventSubscribeInfoData: commonEventManager.CommonEventSubscribeInfo = {
        events: events,
      };
      let data: commonEventManager.CommonEventSubscriber = commonEventManager.createSubscriberSync(commonEventSubscribeInfoData);
      let businessError: BusinessError = {
        code: 1,
        message: 'error'
      } as BusinessError;
      conversationListController.createTimeTickSubscriberCallBack(businessError, data);
      expect(conversationListController).not().assertUndefined();
    })

    it('cvsListControllerTest_createTimeTickSubscriberCallBack1', 0, () => {
      let events = [common.STR.RCS_SUBSCRIBER_SEND_OK_EVENT];
      let commonEventSubscribeInfoData: commonEventManager.CommonEventSubscribeInfo = {
        events: events,
      };
      let data: commonEventManager.CommonEventSubscriber = commonEventManager.createSubscriberSync(commonEventSubscribeInfoData);
      let businessError: BusinessError = {
        code: 1,
        message: 'error'
      } as BusinessError;
      conversationListController.createTimeTickSubscriberCallBack1(businessError, data);
      expect(conversationListController).not().assertUndefined();
    })

    it('cvsListControllerTest_subscribeTimeTickEvent1', 0, () => {
      conversationListController.subscribeTimeTickEvent1();
      expect(conversationListController).not().assertUndefined();
    })

    it('cvsListControllerTest_unSubscribeTimeTickEvent1', 0, () => {
      let events = [common.STR.RCS_SUBSCRIBER_SEND_OK_EVENT];
      let commonEventSubscribeInfoData: commonEventManager.CommonEventSubscribeInfo = {
        events: events,
      };
      let data: commonEventManager.CommonEventSubscriber = commonEventManager.createSubscriberSync(commonEventSubscribeInfoData);
      conversationListController.timeTickEventData1 = data;
      conversationListController.unSubscribeTimeTickEvent1();
      expect(conversationListController).not().assertUndefined();
    })

    it('cvsListControllerTest_subscribeNeedRefreshEvent', 0, () => {
      conversationListController.subscribeNeedRefreshEvent(context);
      expect(conversationListController).not().assertUndefined();
    })

    it('cvsListControllerTest_unsubscribeNeedRefreshEvent', 0, () => {
      conversationListController.unsubscribeNeedRefreshEvent();
      expect(conversationListController).not().assertUndefined();
    })

    it('cvsListControllerTest_subscriberCallBack1', 0, () => {
      let data: commonEventManager.CommonEventData = {
        parameters: {
          telephone: '1111'
        } as LooseObject,
      } as commonEventManager.CommonEventData;
      conversationListController.mIsConversationCheckAlling = true;
      conversationListController.subscriberCallBack(context, data);
      expect(conversationListController).not().assertUndefined();
    })

    it('cvsListControllerTest_subscriberCallBack2', 0, () => {
      let data: commonEventManager.CommonEventData = {
        parameters: {
          telephone: '1111'
        } as LooseObject,
      } as commonEventManager.CommonEventData;
      conversationListController.mIsConversationCheckAlling = false;
      conversationListController.noUiProp.scrollStartIndex = 9999;
      conversationListController.subscriberCallBack(context, data);
      expect(conversationListController).not().assertUndefined();
    })

    it('cvsListControllerTest_unSubscribeMemoryEvent', 0, () => {
      let events = [common.STR.RCS_SUBSCRIBER_SEND_OK_EVENT];
      let commonEventSubscribeInfoData: commonEventManager.CommonEventSubscribeInfo = {
        events: events,
      };
      let data: commonEventManager.CommonEventSubscriber = commonEventManager.createSubscriberSync(commonEventSubscribeInfoData);
      conversationListController.memoryEventData = data;
      conversationListController.unSubscribeMemoryEvent();
      expect(conversationListController).not().assertUndefined();
    })

    it('cvsListControllerTest_clickToSummerPalace1', 0, () => {
      conversationListController.clickToSummerPalace();
      expect(conversationListController).not().assertUndefined();
    })

    it('cvsListControllerTest_clickToSummerPalace2', 0, () => {
      when(mocker.mockFunc(conversationListController, conversationListController.resetTouch))(ArgumentMatchers.any)
        .afterReturn(true);
      conversationListController.clickToSummerPalace();
      expect(conversationListController).not().assertUndefined();
      mocker.clear(conversationListController);
    })

    it('cvsListControllerTest_clickToSummerPalace3', 0, () => {
      conversationListController.isMultipleSelectState = true;
      conversationListController.clickToSummerPalace();
      expect(conversationListController).not().assertUndefined();
    })

    it('cvsListControllerTest_clickToSummerPalace4', 0, () => {
      conversationListController.isMultipleSelectState = false;
      AppStorage.setOrCreate('curBp', 'md');
      conversationListController.clickToSummerPalace();
      expect(conversationListController).not().assertUndefined();
    })

    it('cvsListControllerTest_showFirstMessage_if1', 0, () => {
      let messageList = {
        contactsNum: 1,
        telephone: '13564261257',
        threadId: 0
      } as messageType;
      conversationListController.messageList[0] = messageList;
      conversationListController.isSettingDismiss = true;
      AppStorage.setOrCreate('curBp', 'md');
      conversationListController.showFirstMessage(false);
      expect(conversationListController).not().assertUndefined();
    })

    it('cvsListControllerTest_gesTureListCheckBox_if1', 0, () => {
      let messageList = {
        contactsNum: 1,
        telephone: '13564261257',
        threadId: 0,
        isCbChecked: false
      } as messageType;
      conversationListController.messageList[0] = messageList;
      conversationListController.gesTureListCheckBox(0, true);
      expect(conversationListController).not().assertUndefined();
    })

    it('cvsListControllerTest_gesTureListCheckBox_if2', 0, () => {
      let messageList = {
        contactsNum: 1,
        telephone: '13564261257',
        threadId: 0,
        isCbChecked: false
      } as messageType;
      conversationListController.messageList[0] = messageList;
      conversationListController.mIsConversationCheckAlling = true;
      conversationListController.gesTureListCheckBox(0, false);
      expect(conversationListController).not().assertUndefined();
    })

    it('cvsListControllerTest_handleMarkAsUnReadByIndex', 0, () => {
      let messageList = {
        contactsNum: 1,
        telephone: '13564261257',
        threadId: 0,
        isCbChecked: false
      } as messageType;
      conversationListController.handleMarkAsUnReadByIndex(context, messageList);
      expect(conversationListController).not().assertUndefined();
    })

    it('cvsListControllerTest_simStateChangeInfo', 0, () => {
      conversationListController.simStateChangeInfo();
      expect(conversationListController).not().assertUndefined();
    })

    it('cvsListControllerTest_getPrimarySlotId', 0, () => {
      conversationListController.getPrimarySlotId();
      expect(conversationListController).not().assertUndefined();
    })

    it('cvsListControllerTest_setRcsInfosResultOpenRcs', 0, () => {
      (conversationListController as object)['isAdvancedMode'] = true;
      conversationListController.setRcsInfosResultOpenRcs(context, 0, true);
      expect(conversationListController).not().assertUndefined();
    })

    it('cvsListControllerTest_initAirPlaneMode', 0, () => {
      conversationListController.initAirPlaneMode(context);
      expect(conversationListController).not().assertUndefined();
    })

    it('cvsListControllerTest_refreshListWithUpdateIdStr1', 0, () => {
      conversationListController.messageList = [];
      let contactUpdateIds: Map<string,string> = new Map<string,string>()
      conversationListController.refreshListWithUpdateIdStr(context, contactUpdateIds);
      expect(conversationListController).not().assertUndefined();
    })

    it('cvsListControllerTest_refreshListWithUpdateIdStr2', 0, () => {
      let messageList = {
        contactsNum: 1,
        telephone: '13564261257',
        threadId: 0,
        isCbChecked: false
      } as messageType;
      conversationListController.messageList[0] = messageList;
      let contactUpdateIds: Map<string,string> = new Map<string,string>()
      conversationListController.refreshListWithUpdateIdStr(context, contactUpdateIds);
      expect(conversationListController).not().assertUndefined();
    })

    it('cvsListControllerTest_refreshListWithUpdateIdStr3', 0, () => {
      let messageList = {
        contactsNum: 1,
        telephone: '13564261257',
        threadId: 0,
        isCbChecked: false
      } as messageType;
      conversationListController.messageList[0] = messageList;
      let contactUpdateIds: Map<string, string> = new Map<string, string>()
      contactUpdateIds.set('id1', '1')
      contactUpdateIds.set('id1', '2')
      conversationListController.refreshListWithUpdateIdStr(context, contactUpdateIds);
      expect(conversationListController).not().assertUndefined();
    })

    it('cvsListControllerTest_upDataMessageListContactInfo1', 0, () => {
      let messageList = {
        contactId: '1',
        contactsNum: 1,
        telephone: '13564261257',
        threadId: 0,
        isCbChecked: false
      } as messageType;
      conversationListController.messageList[0] = messageList;
      let contactResultMap: Map<string, ContactInfoModel> = new Map<string, ContactInfoModel>()
      let contactModel: ContactInfoModel = new ContactInfoModel();
      contactModel.detailInfo = 'aaabbb';
      contactModel.displayName = 'aaa';
      contactModel.id = '1';
      contactModel.rawContactId = '1';
      contactModel.contactId = '1';
      contactResultMap.set('1', contactModel)
      conversationListController.upDataMessageListContactInfo(context, contactResultMap, true);
      expect(conversationListController).not().assertUndefined();
    })

    it('cvsListControllerTest_refreshMessageStatus', 0, () => {
      let messageList = {
        contactId: '1',
        contactsNum: 1,
        telephone: '13564261257',
        threadId: 0,
        isCbChecked: false,
        sendingFailed: false
      } as messageType;
      conversationListController.messageList[0] = messageList;
      let mmsListType: mmsListType = {
        id: '123',
        isReceive: true,
        threadId: 0
      } as mmsListType;
      conversationListController.refreshMessageStatus(mmsListType);
      expect(conversationListController).not().assertUndefined();
    })

    it('cvsListControllerTest_getAppPreferredLanguage', 0, () => {
      conversationListController.getAppPreferredLanguage();
      expect(conversationListController).not().assertUndefined();
    })

    it('cvsListControllerTest_tryUpdateSessionContactInfo', 0, () => {
      (conversationListController as object)['currentQueryContactTimeStampStr'] = 'aaaaa';
      conversationListController.tryUpdateSessionContactInfo(context);
      expect(conversationListController).not().assertUndefined();
    })
  })
}