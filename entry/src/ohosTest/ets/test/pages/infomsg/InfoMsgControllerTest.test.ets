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
import { describe, beforeEach, afterEach, it, expect, MockKit, when, ArgumentMatchers } from '@ohos/hypium';
import LooseObject from '../../../../../main/ets/data/LooseObject';
import ConversationListController, { ActionData, messageType } from '../../../../../main/ets/pages/conversationlist/conversationListController';
import InfoMsgController from '../../../../../main/ets/pages/infomsg/InfoMsgController';
import ConversationListService from '../../../../../main/ets/service/ConversationListService';
import { BusinessError, commonEventManager } from '@kit.BasicServicesKit';
import NotificationService from '../../../../../main/ets/service/NotificationService';
import StringUtil from '../../../../../main/ets/utils/StringUtil';
import DataCleanerService from '../../../../../main/ets/service/DataCleanerService';
import dateUtil, { DateUtil } from '../../../../../main/ets/utils/DateUtil';
import { dataShare } from '@kit.ArkData';
import DataShareHelper from '../../../../../main/ets/model/repository/DataShareHelper';
import ConversationService from '../../../../../main/ets/service/ConversationService';
import DotUtil from '../../../../../main/ets/utils/MmsDot/DotUtils';
import HiLog from '../../../../../main/ets/utils/HiLog';
import commonService, { StrTypeSet } from '../../../../../main/ets/service/CommonService';
import { GlobalContext } from '../../../../../main/ets/MainAbility/GlobalHelper';
import { StartOptions, Want } from '@kit.AbilityKit';
import settingService from '../../../../../main/ets/service/SettingService';
import { DTGlobalContext } from '../../../testability/TestAbility';

export default function infoMsgControllerTest() {
  describe('infoMsgControllerTest', () => {

    const TAG = 'InfoMsgController'
    let infoMsgController: InfoMsgController;
    let mocker: MockKit;
    let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;

    beforeEach(() => {
      infoMsgController = new InfoMsgController();
      mocker = new MockKit();
    })

    afterEach(() => {
      mocker.clear(infoMsgController);
      AppStorage.clear();
    })

    it('InfoMsgController_onInit', 0, () => {
      let pageInfos: NavPathStack = new NavPathStack();

      infoMsgController.onInit(pageInfos, context);

      expect(JSON.stringify(infoMsgController.strCheckBoxSelectTip))
        .assertEqual(JSON.stringify($r('app.string.msg_select_all')));
    })

    it('InfoMsgController_onShow_inSearchMode_true', 0, () => {

      mocker.mockFunc(infoMsgController, infoMsgController.getSettingFlagForConvListPage);
      mocker.mockFunc(infoMsgController, infoMsgController.requestItem);
      mocker.mockFunc(infoMsgController, infoMsgController.subscribeInfo);
      mocker.mockFunc(NotificationService.getInstance(), NotificationService.getInstance().updateBadgeNumber);
      mocker.mockFunc(infoMsgController.conversationListDataSource,
        infoMsgController.conversationListDataSource.refresh);
      mocker.mockFunc(NotificationService.getInstance(), NotificationService.getInstance().cancelAllNotify);

      infoMsgController.onShow(context);

      mocker.verify('refreshSearch', []).never();
      mocker.clear(NotificationService.getInstance());
      mocker.clear(infoMsgController.conversationListDataSource);
    })

    it('InfoMsgController_onShow_inSearchMode_false', 0, () => {

      mocker.mockFunc(infoMsgController, infoMsgController.getSettingFlagForConvListPage);
      mocker.mockFunc(infoMsgController, infoMsgController.requestItem);
      mocker.mockFunc(infoMsgController, infoMsgController.subscribeInfo);
      mocker.mockFunc(NotificationService.getInstance(), NotificationService.getInstance().updateBadgeNumber);
      mocker.mockFunc(infoMsgController.conversationListDataSource,
        infoMsgController.conversationListDataSource.refresh);
      mocker.mockFunc(NotificationService.getInstance(), NotificationService.getInstance().cancelAllNotify);

      infoMsgController.onShow(context);

      mocker.verify('refreshSearch', []).never();

      mocker.clear(infoMsgController.conversationListDataSource);
      mocker.clear(NotificationService.getInstance());
    })

    it('InfoMsgController_onHide', 0, () => {
      mocker.mockFunc(infoMsgController, infoMsgController.unsubscribeInfo);

      infoMsgController.onHide();

      mocker.verify('unsubscribeInfo', []).once();
    })

    it('InfoMsgController_queryAllMessages_queryTerminate_false', 0, () => {
      when(mocker.mockFunc(ConversationListService.getInstance(),
        ConversationListService.getInstance().getSessionListResultNew))(ArgumentMatchers.any)
        .afterReturn(new Promise<LooseObject>(resolve => resolve({
          response: [{} as messageType]
        })));

      infoMsgController.isMultipleSelectState = false;
      infoMsgController.conversationListDataSource.mmsList = [{
        messageCount: 0,
        isDraft: false
      } as messageType];

      mocker.mockFunc(infoMsgController.conversationListDataSource,
        infoMsgController.conversationListDataSource.refreshPage);

      infoMsgController.queryTerminate.set(0, false);
      infoMsgController.refreshIndex = 0;
      infoMsgController.totalMessage = 1;
      infoMsgController.page = 0;

      when(mocker.mockFunc(StringUtil, StringUtil.getLimitForSession))(0).afterReturn(0);
      when(mocker.mockFunc(StringUtil, StringUtil.getLimitForSession))(1).afterReturn(2);

      mocker.mockFunc(infoMsgController, infoMsgController.queryAllMessages);
      mocker.mockFunc(infoMsgController, infoMsgController.countUnread);
      mocker.mockFunc(DataCleanerService.getInstance(), DataCleanerService.getInstance().unReadClean);

      infoMsgController.queryAllMessages(context, 0);

      expect(infoMsgController.page).assertEqual(0);

      mocker.clear(infoMsgController.conversationListDataSource);
      mocker.clear(ConversationListService.getInstance());
      mocker.clear(StringUtil);
      mocker.clear(DataCleanerService.getInstance());
    })

    it('InfoMsgController_queryPageMessages_isMultipleSelectState_true_threadId_equal', 0, () => {
      when(mocker.mockFunc(ConversationListService.getInstance(),
        ConversationListService.getInstance().getSessionListResultNew))(ArgumentMatchers.any)
        .afterReturn(new Promise<LooseObject>(resolve => resolve({
          response: [{
            threadId: 0,
            isCbChecked: false
          } as messageType]
        })));

      infoMsgController.page = 1;
      infoMsgController.total = 1;
      infoMsgController.totalMessage = 0;
      infoMsgController.messageList = [{
        threadId: 0,
        isCbChecked: false
      } as messageType];
      infoMsgController.conversationListDataSource.mmsList = [{
        messageCount: 0,
        isDraft: true
      } as messageType];
      infoMsgController.isMultipleSelectState = true;

      mocker.mockFunc(infoMsgController.conversationListDataSource,
        infoMsgController.conversationListDataSource.refreshPage);

      infoMsgController.queryPageMessages(context, 1, 1, 1, (isEnd) => {
        expect(isEnd).assertTrue();
      });

      mocker.clear(infoMsgController.conversationListDataSource);
      mocker.clear(ConversationListService.getInstance());
    })

    it('InfoMsgController_queryPageMessages_isMultipleSelectState_true_threadId_notEqual', 0, () => {
      when(mocker.mockFunc(ConversationListService.getInstance(),
        ConversationListService.getInstance().getSessionListResultNew))(ArgumentMatchers.any)
        .afterReturn(new Promise<LooseObject>(resolve => resolve({
          response: [{
            threadId: 1,
            isCbChecked: false
          } as messageType]
        })));

      infoMsgController.page = 1;
      infoMsgController.total = 1;
      infoMsgController.totalMessage = 1;
      infoMsgController.messageList = [{
        threadId: 0,
        isCbChecked: false
      } as messageType];
      infoMsgController.conversationListDataSource.mmsList = [{
        messageCount: 0,
        isDraft: false
      } as messageType];
      infoMsgController.isMultipleSelectState = true;

      mocker.mockFunc(infoMsgController.conversationListDataSource,
        infoMsgController.conversationListDataSource.refreshPage);

      infoMsgController.queryPageMessages(context, 1, 3, 1, (isEnd) => {
        expect(isEnd).assertTrue();
      });

      mocker.clear(infoMsgController.conversationListDataSource);
      mocker.clear(ConversationListService.getInstance());
    })

    it('InfoMsgController_queryPageMessages_isMultipleSelectState_false', 0, () => {
      when(mocker.mockFunc(ConversationListService.getInstance(),
        ConversationListService.getInstance().getSessionListResultNew))(ArgumentMatchers.any)
        .afterReturn(new Promise<LooseObject>(resolve => resolve({
          response: [{
            threadId: 1,
            isCbChecked: false
          } as messageType]
        })));

      infoMsgController.page = 1;
      infoMsgController.total = 1;
      infoMsgController.totalMessage = 2;
      infoMsgController.messageList = [{
        threadId: 0,
        isCbChecked: false
      } as messageType];
      infoMsgController.conversationListDataSource.mmsList = [{
        messageCount: 0,
        isDraft: false
      } as messageType];
      infoMsgController.isMultipleSelectState = false;

      mocker.mockFunc(infoMsgController.conversationListDataSource,
        infoMsgController.conversationListDataSource.refreshPage);

      infoMsgController.queryPageMessages(context, 1, 1, 1, (isEnd) => {
        expect(isEnd).assertFalse();
      });

      mocker.clear(infoMsgController.conversationListDataSource);
      mocker.clear(ConversationListService.getInstance());
    })

    it('InfoMsgController_dealMmsListContent_content_notEmpty', 0, () => {
      let element = {
        hasMms: true,
        hasAttachment: true,
        content: 'hello'
      } as LooseObject;

      infoMsgController.dealMmsListContent(element);

      expect(JSON.stringify((element.content as Resource).params)).assertEqual('["hello"]');
    })

    it('InfoMsgController_dealMmsListContent_content_empty', 0, () => {
      let element = {
        hasMms: true,
        hasAttachment: true,
        content: ''
      } as LooseObject;

      infoMsgController.dealMmsListContent(element);

      expect(JSON.stringify(element.content)).assertEqual(JSON.stringify($r('app.string.attachment_no_subject')));
    })

    it('InfoMsgController_dealMmsListContent_hasAttachment_false', 0, () => {
      let element = {
        hasMms: true,
        hasAttachment: false,
        content: ''
      } as LooseObject;

      infoMsgController.dealMmsListContent(element);

      expect(JSON.stringify(element.content)).assertEqual(JSON.stringify($r('app.string.no_subject')));
    })

    it('InfoMsgController_buildSessionList_threadId_equal', 0, () => {
      let response = [{
        hasMms: true,
        hasAttachment: false,
        content: '',
        threadId: 1,
        isCbChecked: true,
        timeMillisecond: '1699010047'
      }] as LooseObject;

      let result = {} as LooseObject;
      result.response = response;

      let message: messageType = new messageType();
      message.threadId = 1;
      message.isCbChecked = true;

      infoMsgController.messageList.push(message);

      mocker.mockFunc(dateUtil, DateUtil.convertDateFormatForItem);
      mocker.mockFunc(infoMsgController, infoMsgController.dealMmsListContent);

      expect(infoMsgController.buildSessionList(result)[0].itemLeft).assertEqual(0);

      mocker.clear(dateUtil);
    })

    it('InfoMsgController_buildSessionList_threadId_notEqual', 0, () => {
      let response = [{
        hasMms: true,
        hasAttachment: false,
        content: '',
        threadId: 2,
        isCbChecked: true,
        timeMillisecond: '1699010047'
      }] as LooseObject;

      let result = {} as LooseObject;
      result.response = response;

      let message: messageType = new messageType();
      message.threadId = 1;
      message.isCbChecked = true;

      infoMsgController.messageList.push(message);

      mocker.mockFunc(dateUtil, DateUtil.convertDateFormatForItem);
      mocker.mockFunc(infoMsgController, infoMsgController.dealMmsListContent);

      expect(infoMsgController.buildSessionList(result)[0].itemLeft).assertEqual(0);

      mocker.clear(dateUtil);

      mocker.clear(dateUtil);
    })

    it('InfoMsgController_requestItem_page_0_value_1', 0, () => {
      infoMsgController.taskId = -1;
      infoMsgController.page = 0;

      when(mocker.mockFunc(ConversationListService.getInstance(),
        ConversationListService.getInstance().getSessionListSize))(ArgumentMatchers.any)
        .afterReturn(new Promise<number>(resolve => resolve(1)));

      when(mocker.mockFunc(infoMsgController, infoMsgController.queryAllMessages))(ArgumentMatchers.any)
        .afterAction(() => {
          expect(infoMsgController.page).assertEqual(1);
        });

      infoMsgController.requestItem(context);

      mocker.clear(ConversationListService.getInstance());
    })

    it('InfoMsgController_requestItem_page_0_value_0', 0, () => {
      infoMsgController.taskId = -1;
      infoMsgController.page = 0;

      when(mocker.mockFunc(ConversationListService.getInstance(),
        ConversationListService.getInstance().getSessionListSize))(ArgumentMatchers.any)
        .afterReturn(new Promise<number>(resolve => resolve(0)));

      let res = false;
      when(mocker.mockFunc(infoMsgController, infoMsgController.queryAllMessages))(ArgumentMatchers.any)
        .afterAction(() => {
          res = true;
        });

      infoMsgController.requestItem(context);

      expect(res).assertFalse();

      mocker.clear(ConversationListService.getInstance());
    })

    it('InfoMsgController_requestItem_page_1', 0, () => {
      infoMsgController.taskId = 1;
      infoMsgController.page = 1;

      when(mocker.mockFunc(ConversationListService.getInstance(),
        ConversationListService.getInstance().getSessionListSize))(ArgumentMatchers.any)
        .afterReturn(new Promise<number>(resolve => resolve(0)));

      mocker.mockFunc(infoMsgController, infoMsgController.requestItem);

      infoMsgController.requestItem(context);

      expect(infoMsgController.page).assertEqual(1);
    })

    it('InfoMsgController_back_total_0', 0, () => {
      infoMsgController.total = 0;

      infoMsgController.back();

      expect(AppStorage.get('backHasInfoMsg')).assertTrue();
    })

    it('InfoMsgController_back_total_1', 0, () => {
      infoMsgController.total = 1;

      infoMsgController.back();

      expect(AppStorage.get('backHasInfoMsg')).assertFalse();
    })

    it('InfoMsgController_clickMore', 0, () => {
      infoMsgController.clickMore();

      expect(infoMsgController.delDialogShow).assertFalse();
    })

    it('InfoMsgController_clickToDelete', 0, () => {
      infoMsgController.clickToDelete();

      expect(infoMsgController.delDialogShow).assertFalse();
    })

    it('InfoMsgController_clickSearchBack', 0, () => {
      mocker.mockFunc(infoMsgController, infoMsgController.backSearch);

      infoMsgController.clickSearchBack();

      mocker.verify('backSearch', []).once();
    })

    it('InfoMsgController_backSearch', 0, () => {
      infoMsgController.backSearch();

      expect(infoMsgController.showToolBar).assertTrue();
    })

    it('InfoMsgController_conversationLongPress_itemTouchedIdx_1_isDelShow_true', 0, () => {
      infoMsgController.itemTouchedIdx = 1;
      infoMsgController.isMultipleSelectState = true;
      let message: messageType = new messageType();
      message.isDelShow = true;
      message.isCbChecked = false;
      let message1: messageType = new messageType();
      message1.isDelShow = false;
      message1.isCbChecked = false;
      infoMsgController.messageList = [message, message1];

      mocker.mockFunc(infoMsgController, infoMsgController.setConversationCheckAll);

      infoMsgController.conversationLongPress(0);

      expect(infoMsgController.messageList[0].isCbChecked).assertTrue();
    })

    it('InfoMsgController_conversationLongPress_isMultipleSelectState_true', 0, () => {
      infoMsgController.itemTouchedIdx = 0;
      infoMsgController.isMultipleSelectState = true;
      let message: messageType = new messageType();
      message.isDelShow = false;
      infoMsgController.messageList.push(message);

      mocker.mockFunc(infoMsgController, infoMsgController.setConversationCheckAll);

      infoMsgController.conversationLongPress(0);

      expect(infoMsgController.messageList[0].isCbChecked).assertTrue();
    })

    it('InfoMsgController_conversationLongPress_isMultipleSelectState_false', 0, () => {
      infoMsgController.itemTouchedIdx = 0;
      infoMsgController.isMultipleSelectState = false;
      let message: messageType = new messageType();
      message.isDelShow = false;
      infoMsgController.messageList.push(message);

      mocker.mockFunc(infoMsgController, infoMsgController.setConversationCheckAll);

      infoMsgController.conversationLongPress(0);

      expect(infoMsgController.isMultipleSelectState).assertTrue();
    })

    it('InfoMsgController_setConversationCheckAll_isMultipleSelectState_false', 0, () => {
      infoMsgController.isMultipleSelectState = false;

      infoMsgController.setConversationCheckAll(0);

      expect(infoMsgController.isConversationCheckAll).assertFalse();
    })

    it('InfoMsgController_setConversationCheckAll_type_2_isConversationCheckAll_false', 0, () => {
      infoMsgController.isMultipleSelectState = true;
      let message: messageType = new messageType();
      message.isDelShow = true;
      infoMsgController.messageList.push(message);
      let type: number = 2;
      infoMsgController.isConversationCheckAll = false;

      mocker.mockFunc(infoMsgController.conversationListDataSource,
        infoMsgController.conversationListDataSource.refresh);

      infoMsgController.setConversationCheckAll(type);

      expect(infoMsgController.isConversationCheckAll).assertFalse();
    })

    it('InfoMsgController_setConversationCheckAll_type_1_isConversationCheckAll_true', 0, () => {
      infoMsgController.isMultipleSelectState = true;
      let message: messageType = new messageType();
      message.isDelShow = true;
      infoMsgController.messageList.push(message);
      let type: number = 1;
      infoMsgController.isConversationCheckAll = true;

      mocker.mockFunc(infoMsgController.conversationListDataSource,
        infoMsgController.conversationListDataSource.refresh);

      infoMsgController.setConversationCheckAll(type);

      expect(infoMsgController.isConversationCheckAll).assertTrue();
    })

    it('InfoMsgController_setConversationCheckAll_type_3_isCbChecked_true', 0, () => {
      infoMsgController.isMultipleSelectState = true;
      let message: messageType = new messageType();
      message.isDelShow = true;
      message.isCbChecked = true;
      infoMsgController.messageList.push(message);
      let type: number = 3;
      infoMsgController.isConversationCheckAll = true;

      mocker.mockFunc(infoMsgController.conversationListDataSource,
        infoMsgController.conversationListDataSource.refresh);

      infoMsgController.setConversationCheckAll(type);

      expect(infoMsgController.isConversationCheckAll).assertTrue();
    })

    it('InfoMsgController_setConversationCheckAll_type_3_isCbChecked_false', 0, () => {
      infoMsgController.isMultipleSelectState = true;
      let message: messageType = new messageType();
      message.isDelShow = true;
      message.isCbChecked = false;
      infoMsgController.messageList.push(message);
      let type: number = 3;
      infoMsgController.isConversationCheckAll = true;

      mocker.mockFunc(infoMsgController.conversationListDataSource,
        infoMsgController.conversationListDataSource.refresh);

      infoMsgController.setConversationCheckAll(type);

      expect(infoMsgController.isConversationCheckAll).assertFalse();
    })

    it('InfoMsgController_clickInfoToConversation_resetTouch_true', 0, () => {
      when(mocker.mockFunc(infoMsgController, infoMsgController.resetTouch))()
        .afterReturn(true);

      infoMsgController.clickInfoToConversation(context, 1);

      mocker.verify('resetTouch', []).once();
    })

    it('InfoMsgController_clickInfoToConversation_isMultipleSelectState_true', 0, () => {
      when(mocker.mockFunc(infoMsgController, infoMsgController.resetTouch))()
        .afterReturn(false);
      mocker.mockFunc(infoMsgController, infoMsgController.setConversationCheckAll);
      mocker.mockFunc(infoMsgController.conversationListDataSource,
        infoMsgController.conversationListDataSource.notifyDataChange);

      infoMsgController.isMultipleSelectState = true;
      infoMsgController.messageList = [new messageType()];

      infoMsgController.clickInfoToConversation(context, 0);

      expect(infoMsgController.messageList[0].isCbChecked).assertTrue();

      mocker.clear(infoMsgController.conversationListDataSource);
    })

    it('InfoMsgController_clickInfoToConversation_curBp_sm', 0, () => {
      when(mocker.mockFunc(infoMsgController, infoMsgController.resetTouch))()
        .afterReturn(false);

      infoMsgController.isMultipleSelectState = false;
      infoMsgController.messageList = [new messageType()];
      infoMsgController.pageInfos.pushPathByName('Conversation', {} as LooseObject);

      AppStorage.setOrCreate('curBp', 'sm');

      infoMsgController.clickInfoToConversation(context, 0);

      expect(infoMsgController.isJumping).assertFalse();
    })

    it('InfoMsgController_clickInfoToConversation_curBp_bp', 0, () => {
      when(mocker.mockFunc(infoMsgController, infoMsgController.resetTouch))()
        .afterReturn(false);
      mocker.mockFunc(infoMsgController, infoMsgController.markAsReadByThread);
      mocker.mockFunc(infoMsgController, infoMsgController.jumpToConversationPage);

      infoMsgController.isMultipleSelectState = false;
      let message: messageType = new messageType();
      message.countOfUnread = 3;
      infoMsgController.messageList = [message];

      infoMsgController.pageInfos.pushPathByName('Conversation', {} as LooseObject);

      AppStorage.setOrCreate('curBp', 'bp');

      infoMsgController.clickInfoToConversation(context, 0);

      expect(infoMsgController.isJumping).assertTrue();
    })

    it('InfoMsgController_clickCheckBox', 0, () => {
      let message: messageType = new messageType();
      message.countOfUnread = 3;
      infoMsgController.messageList = [message];

      mocker.mockFunc(infoMsgController, infoMsgController.setConversationCheckAll);
      mocker.mockFunc(infoMsgController.conversationListDataSource,
        infoMsgController.conversationListDataSource.notifyDataChange);


      infoMsgController.clickCheckBox(context, 0, false);

      expect(infoMsgController.messageList[0].isCbChecked).assertFalse();

      mocker.clear(infoMsgController.conversationListDataSource);
    })

    it('InfoMsgController_jumpToConversationPage', 0, () => {
      let message: messageType = new messageType();
      message.yellowPageId = '';
      message.hasYellowPageIcon = '';
      message.rawContactId = '';
      message.telephone = '111';
      message.telephoneFormat = '';
      message.name = '1';
      message.contactsNum = 1;
      message.threadId = 1;
      message.isDraft = false;
      message.content = "1";
      message.smsType = 1;
      infoMsgController.inputValueOfSearch = "1";

      infoMsgController.messageList.push(message);

      infoMsgController.jumpToConversationPage(message);

      expect(infoMsgController.conListCtrl.isJumping).assertFalse();
    })

    it('InfoMsgController_searchConversationHeadClick', 0, () => {
      let message: messageType = {} as messageType;
      infoMsgController.searchResultList.sessionList = [message];
      mocker.mockFunc(infoMsgController, infoMsgController.headClickedListener);
      let index: number = 0;

      infoMsgController.searchConversationHeadClick(index);

      mocker.verify('headClickedListener', [message]).once();
    })

    it('InfoMsgController_headClickedListener_isJumping_true', 0, () => {
      let message: messageType = new messageType();

      infoMsgController.isJumping = true;

      infoMsgController.headClickedListener(message);

      expect(infoMsgController.isJumping).assertTrue();
    })

    it('InfoMsgController_headClickedListener_isFavorite_true', 0, () => {
      let message: messageType = new messageType();
      message.isFavorite = true;

      infoMsgController.isJumping = false;

      infoMsgController.headClickedListener(message);

      expect(infoMsgController.isJumping).assertFalse();
    })

    it('InfoMsgController_headClickedListener_contactsNum_1', 0, () => {
      let message: messageType = new messageType();
      message.isFavorite = false;
      message.contactsNum = 1;

      infoMsgController.isJumping = false;

      mocker.mockFunc(infoMsgController, infoMsgController.jumpToContact);

      infoMsgController.headClickedListener(message);

      expect(infoMsgController.isJumping).assertTrue();
    })

    it('InfoMsgController_headClickedListener_contactsNum_2', 0, () => {
      let message: messageType = new messageType();
      message.isFavorite = false;
      message.contactsNum = 2;

      infoMsgController.isJumping = false;

      mocker.mockFunc(infoMsgController, infoMsgController.jumpToGroupDetail);

      infoMsgController.headClickedListener(message);

      expect(infoMsgController.isJumping).assertTrue();
    })

    it('InfoMsgController_jumpToGroupDetail', 0, () => {
      infoMsgController.jumpToGroupDetail(1, 1);

      expect(infoMsgController.isJumping).assertFalse();
    })

    it('InfoMsgController_searchConversationClick', 0, () => {
      let message: messageType = {
        isFavorite: true
      } as messageType;
      infoMsgController.searchResultList = {
        'sessionList': [message],
        'contentList': []
      };
      infoMsgController.inputValueOfSearch = "11";

      mocker.mockFunc(infoMsgController, infoMsgController.searchMmsClicked);

      infoMsgController.searchConversationClick(0);

      mocker.verify('searchMmsClicked', [message]).once();
    })

    it('InfoMsgController_searchMmsClicked_isFavorite_true', 0, () => {
      let message: messageType = new messageType()
      message.isFavorite = true;

      mocker.mockFunc(infoMsgController, infoMsgController.jumpToConversationPage);

      infoMsgController.searchMmsClicked(message);

      mocker.verify('jumpToConversationPage', [message]).never();
    })

    it('InfoMsgController_searchMmsClicked_isFavorite_false', 0, () => {
      let message: messageType = new messageType()
      message.isFavorite = false;

      mocker.mockFunc(infoMsgController, infoMsgController.jumpToConversationPage);

      infoMsgController.searchMmsClicked(message);

      mocker.verify('jumpToConversationPage', [message]).once();
    })

    it('InfoMsgController_searchSmsHeadClick', 0, () => {
      let message: messageType = {
        isFavorite: true
      } as messageType;
      infoMsgController.searchResultList = {
        'sessionList': [],
        'contentList': [message]
      };
      infoMsgController.inputValueOfSearch = "11";

      mocker.mockFunc(infoMsgController, infoMsgController.headClickedListener);

      infoMsgController.searchSmsHeadClick(0);

      mocker.verify('headClickedListener', [message]).once();
    })

    it('InfoMsgController_searchSmsClick', 0, () => {
      let message: messageType = {
        isFavorite: true
      } as messageType;
      infoMsgController.searchResultList = {
        'sessionList': [],
        'contentList': [message]
      };
      infoMsgController.inputValueOfSearch = "11";

      mocker.mockFunc(infoMsgController, infoMsgController.searchMmsClicked);

      infoMsgController.searchSmsClick(0);

      mocker.verify('searchMmsClicked', [message]).once();
    })

    it('InfoMsgController_searchCoverageClick', 0, () => {
      mocker.mockFunc(infoMsgController, infoMsgController.backSearch);

      infoMsgController.searchCoverageClick();

      mocker.verify('backSearch', []).once();
    })

    it('InfoMsgController_countUnread', 0, () => {
      mocker.mockFunc(ConversationListService.getInstance(),
        ConversationListService.getInstance().statisticalData);

      infoMsgController.countUnread(context);

      expect(infoMsgController.unreadTotalOfInfo).assertEqual(0);

      mocker.clear(ConversationListService.getInstance());
    })

    it('InfoMsgController_clickToMarkAllAsReadForInfo_countOfUnread_1', 0, () => {
      infoMsgController.messageList = [];
      let message: messageType = new messageType();
      message.countOfUnread = 1;
      infoMsgController.messageList.push(message);

      let actionData: LooseObject = {};
      actionData.hasRead = 0;

      mocker.mockFunc(infoMsgController.conversationListDataSource,
        infoMsgController.conversationListDataSource.refresh);
      when(mocker.mockFunc(ConversationService.getInstance(),
        ConversationService.getInstance().getSmsMmsInfoSizeByCondition))(actionData)
        .afterReturn(0);
      when(mocker.mockFunc(ConversationListController.getInstance(),
        ConversationListController.getInstance().statisticalData))(ArgumentMatchers.any)
        .afterReturnNothing();
      when(mocker.mockFunc(DataShareHelper.getInstance(),
        DataShareHelper.getInstance().initSmsDB))(ArgumentMatchers.any)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(undefined)));

      ConversationListService.getInstance().markAllToRead(context, actionData);

      infoMsgController.clickToMarkAllAsReadForInfo(context);

      expect(infoMsgController.unreadTotalOfInfo).assertEqual(0);

      mocker.clear(DataShareHelper.getInstance());
      mocker.clear(ConversationService.getInstance());
      mocker.clear(ConversationListController.getInstance());
      mocker.clear(infoMsgController.conversationListDataSource);
    })

    it('InfoMsgController_clickToMarkAllAsReadForInfo_countOfUnread_0', 0, () => {
      infoMsgController.messageList = [];
      let message: messageType = new messageType();
      message.countOfUnread = 0;
      infoMsgController.messageList.push(message);

      let actionData: LooseObject = {};
      actionData.hasRead = 0;

      mocker.mockFunc(infoMsgController.conversationListDataSource,
        infoMsgController.conversationListDataSource.refresh);
      when(mocker.mockFunc(ConversationService.getInstance(),
        ConversationService.getInstance().getSmsMmsInfoSizeByCondition))(actionData)
        .afterReturn(0);
      when(mocker.mockFunc(ConversationListController.getInstance(),
        ConversationListController.getInstance().statisticalData))(ArgumentMatchers.any)
        .afterReturnNothing();
      when(mocker.mockFunc(DataShareHelper.getInstance(),
        DataShareHelper.getInstance().initSmsDB))(ArgumentMatchers.any)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(undefined)));

      ConversationListService.getInstance().markAllToRead(context, actionData);

      infoMsgController.clickToMarkAllAsReadForInfo(context);

      expect(infoMsgController.unreadTotalOfInfo).assertEqual(0);

      mocker.clear(DataShareHelper.getInstance());
      mocker.clear(ConversationService.getInstance());
      mocker.clear(ConversationListController.getInstance());
      mocker.clear(infoMsgController.conversationListDataSource);
    })

    it('InfoMsgController_markAllAsReadByIndex', 0, () => {
      infoMsgController.messageList = [];
      let message: messageType = new messageType();
      message.threadId = 1;

      let message1: messageType = new messageType();
      message1.threadId = 2;

      infoMsgController.messageList = [message, message1];
      infoMsgController.unreadTotalOfInfo = 2;

      when(mocker.mockFunc(DataShareHelper.getInstance(),
        DataShareHelper.getInstance().initSmsDB))(ArgumentMatchers.any)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(undefined)));
      when(mocker.mockFunc(ConversationService.getInstance(),
        ConversationService.getInstance().getSmsMmsInfoSizeByCondition))(ArgumentMatchers.any)
        .afterReturn(0);

      mocker.mockFunc(infoMsgController, infoMsgController.setListItemTransX);

      infoMsgController.markAsReadByThread(context, message);

      expect(infoMsgController.unreadTotalOfInfo).assertEqual(2);

      mocker.clear(DataShareHelper.getInstance());
      mocker.clear(ConversationService.getInstance());
    })

    it('InfoMsgController_handleMarkAsUnRead', 0, () => {
      infoMsgController.messageList = [];
      let message: messageType = new messageType();
      message.threadId = 1;

      let message1: messageType = new messageType();
      message1.threadId = 2;

      infoMsgController.messageList = [message, message1];
      infoMsgController.unreadTotalOfInfo = 2;

      when(mocker.mockFunc(DataShareHelper.getInstance(),
        DataShareHelper.getInstance().initSmsDB))(ArgumentMatchers.any)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(undefined)));
      when(mocker.mockFunc(ConversationService.getInstance(),
        ConversationService.getInstance().getSmsMmsInfoSizeByCondition))(ArgumentMatchers.any)
        .afterReturn(0);

      mocker.mockFunc(infoMsgController, infoMsgController.setListItemTransX);

      infoMsgController.handleMarkAsUnRead(context, message);

      expect(infoMsgController.unreadTotalOfInfo).assertEqual(3);

      mocker.clear(DataShareHelper.getInstance());
      mocker.clear(ConversationService.getInstance());
    })

    it('InfoMsgController_selectInMoreMenu_menuId_1', 0, () => {
      mocker.mockFunc(infoMsgController, infoMsgController.setConversationCheckAll);

      infoMsgController.selectInMoreMenu(1);

      expect(infoMsgController.isMultipleSelectState).assertTrue();
    })

    it('InfoMsgController_selectInMoreMenu_menuId_2', 0, () => {
      mocker.mockFunc(infoMsgController, infoMsgController.setConversationCheckAll);

      infoMsgController.selectInMoreMenu(2);

      expect(infoMsgController.isMultipleSelectState).assertFalse();
    })

    it('InfoMsgController_clickConversationDelete_conversationSelectedNumber_0', 0, () => {
      let res = false;
      when(mocker.mockFunc(DotUtil.getInstance(), DotUtil.getInstance().reportEvent))(ArgumentMatchers.any)
        .afterAction(() => {
          res = true;
        });

      infoMsgController.conversationSelectedNumber = 0;

      infoMsgController.clickConversationDelete();

      expect(res).assertFalse();
      mocker.clear(DotUtil.getInstance())
    })

    it('InfoMsgController_clickConversationDelete_conversationSelectedNumber_1', 0, () => {
      infoMsgController.conversationSelectedNumber = 1;

      let res = false;
      when(mocker.mockFunc(DotUtil.getInstance(), DotUtil.getInstance().reportEvent))(ArgumentMatchers.any)
        .afterAction(() => {
          res = true;
        });

      infoMsgController.clickConversationDelete();

      expect(res).assertTrue();
      mocker.clear(DotUtil.getInstance());
    })

    it('InfoMsgController_clickConversationDelete_conversationSelectedNumber_2', 0, () => {
      let res = false;
      when(mocker.mockFunc(DotUtil.getInstance(), DotUtil.getInstance().reportEvent))(ArgumentMatchers.any)
        .afterAction(() => {
          res = true;
        });

      infoMsgController.clickConversationDelete();

      expect(res).assertFalse();
      mocker.clear(DotUtil.getInstance());
    })

    it('InfoMsgController_clickConversationDelete_conversationSelectedNumber_3', 0, () => {
      let res = false;
      when(mocker.mockFunc(DotUtil.getInstance(), DotUtil.getInstance().reportEvent))(ArgumentMatchers.any)
        .afterAction(() => {
          res = true;
        });

      infoMsgController.conversationSelectedNumber = 3;

      infoMsgController.clickConversationDelete();

      expect(res).assertTrue();
      mocker.clear(DotUtil.getInstance());
    })

    it('InfoMsgController_checkSelectedNumberIsEmpty', 0, () => {
      expect(infoMsgController.checkSelectedNumberIsEmpty()).assertTrue();
    })

    it('InfoMsgController_deleteDialogConfirm_threadIds_empty', 0, () => {
      let message: messageType = new messageType();
      message.threadId = 1;
      message.isCbChecked = false;

      infoMsgController.messageList = [message];

      infoMsgController.deleteDialogConfirm(context);

      expect(infoMsgController.isMultipleSelectState).assertFalse();
    })

    it('InfoMsgController_deleteDialogConfirm_curBp_sm', 0, () => {
      let message: messageType = new messageType();
      message.threadId = 1;
      message.isCbChecked = true;

      let message1: messageType = new messageType();
      message1.threadId = 2;
      message1.isCbChecked = true;

      infoMsgController.messageList = [message, message1];
      infoMsgController.total = 0;

      AppStorage.setOrCreate('curBp', 'sm');

      mocker.mockFunc(NotificationService.getInstance(), NotificationService.getInstance().setBadgeNumber);

      when(mocker.mockFunc(DataShareHelper.getInstance(),
        DataShareHelper.getInstance().initSmsDB))(ArgumentMatchers.any)
        .afterReturn(new Promise<dataShare.DataShareHelper | undefined>(resolve => resolve(undefined)));

      mocker.mockFunc(infoMsgController.conListCtrl, infoMsgController.conListCtrl.statisticalData);


      infoMsgController.deleteDialogConfirm(context);

      expect(infoMsgController.isMultipleSelectState).assertFalse();

      mocker.clear(NotificationService.getInstance());
      mocker.clear(DataShareHelper.getInstance());
      mocker.clear(infoMsgController.conListCtrl);
    })

    it('InfoMsgController_deleteDialogConfirm_curBp_bp', 0, () => {
      let message: messageType = new messageType();
      message.threadId = 1;
      message.isCbChecked = true;

      let message1: messageType = new messageType();
      message1.threadId = 2;
      message1.isCbChecked = true;

      infoMsgController.messageList = [message, message1];
      infoMsgController.total = 0;

      AppStorage.setOrCreate('curBp', 'bp');

      mocker.mockFunc(NotificationService.getInstance(), NotificationService.getInstance().setBadgeNumber);

      when(mocker.mockFunc(DataShareHelper.getInstance(),
        DataShareHelper.getInstance().initSmsDB))(ArgumentMatchers.any)
        .afterReturn(new Promise<dataShare.DataShareHelper | undefined>(resolve => resolve(undefined)));

      mocker.mockFunc(infoMsgController.conListCtrl, infoMsgController.conListCtrl.statisticalData);


      infoMsgController.deleteDialogConfirm(context);

      expect(infoMsgController.isMultipleSelectState).assertFalse();

      mocker.clear(NotificationService.getInstance());
      mocker.clear(DataShareHelper.getInstance());
      mocker.clear(infoMsgController.conListCtrl);
    })

    it('InfoMsgController_deleteDialogConfirm_total_1', 0, () => {
      let message: messageType = new messageType();
      message.threadId = 1;
      message.isCbChecked = false;

      let message1: messageType = new messageType();
      message1.threadId = 2;
      message1.isCbChecked = true;

      let message2: messageType = new messageType();
      message2.threadId = 2;
      message2.isCbChecked = true;

      infoMsgController.messageList = [message, message1, message2];
      infoMsgController.total = 1;

      AppStorage.setOrCreate('curBp', 'bp');

      mocker.mockFunc(NotificationService.getInstance(), NotificationService.getInstance().setBadgeNumber);

      when(mocker.mockFunc(DataShareHelper.getInstance(),
        DataShareHelper.getInstance().initSmsDB))(ArgumentMatchers.any)
        .afterReturn(new Promise<dataShare.DataShareHelper | undefined>(resolve => resolve(undefined)));

      mocker.mockFunc(infoMsgController.conListCtrl, infoMsgController.conListCtrl.statisticalData);


      infoMsgController.deleteDialogConfirm(context);

      expect(infoMsgController.isMultipleSelectState).assertFalse();

      mocker.clear(NotificationService.getInstance());
      mocker.clear(DataShareHelper.getInstance());
      mocker.clear(infoMsgController.conListCtrl);
    })

    it('InfoMsgController_setDelShow', 0, () => {
      let message: messageType = new messageType();
      message.threadId = 1;
      message.isCbChecked = false;

      let message1: messageType = new messageType();
      message1.threadId = 2;
      message1.isCbChecked = true;

      let message2: messageType = new messageType();
      message2.threadId = 2;
      message2.isCbChecked = true;

      infoMsgController.messageList = [message, message1, message2];
      infoMsgController.itemTouchedIdx = 1;

      mocker.mockFunc(infoMsgController, infoMsgController.setListItemTransX);

      infoMsgController.setDelShow();

      mocker.verify('setListItemTransX', [0]).once();
    })

    it('InfoMsgController_setDelShow_itemTouchedIdx_minus1', 0, () => {
      infoMsgController.itemTouchedIdx = -1;

      mocker.mockFunc(infoMsgController, infoMsgController.setListItemTransX);

      infoMsgController.setDelShow();

      mocker.verify('setListItemTransX', [0]).never();
    })

    it('InfoMsgController_clickConversationCheckAll_isConversationCheckAll_true', 0, () => {
      let message: messageType = new messageType();
      message.threadId = 1;
      message.isCbChecked = false;

      let message1: messageType = new messageType();
      message1.threadId = 2;
      message1.isCbChecked = true;

      let message2: messageType = new messageType();
      message2.threadId = 2;
      message2.isCbChecked = true;

      infoMsgController.messageList = [message, message1, message2];
      infoMsgController.isConversationCheckAll = true;

      mocker.mockFunc(infoMsgController, infoMsgController.setConversationCheckAll);

      infoMsgController.clickConversationCheckAll();

      mocker.verify('setConversationCheckAll', [2]).once();
    })

    it('InfoMsgController_clickConversationCheckAll_isConversationCheckAll_false', 0, () => {
      let message: messageType = new messageType();
      message.threadId = 1;
      message.isCbChecked = false;

      let message1: messageType = new messageType();
      message1.threadId = 2;
      message1.isCbChecked = true;

      let message2: messageType = new messageType();
      message2.threadId = 2;
      message2.isCbChecked = true;

      infoMsgController.messageList = [message, message1, message2];
      infoMsgController.isConversationCheckAll = false;
      let res = false;

      when(mocker.mockFunc(infoMsgController, infoMsgController.setConversationCheckAll))(ArgumentMatchers.any)
        .afterAction(() => {
          res = true;
        });

      infoMsgController.clickConversationCheckAll();

      expect(res).assertTrue();
    })

    it('InfoMsgController_onBackPress_isMultipleSelectState_false', 0, () => {
      infoMsgController.isMultipleSelectState = false;

      mocker.mockFunc(infoMsgController, infoMsgController.setConversationCheckAll);

      expect(infoMsgController.onBackPress()).assertFalse();
    })

    it('InfoMsgController_onBackPress_isMultipleSelectState_true', 0, () => {
      let message: messageType = new messageType();
      message.threadId = 1;
      message.isCbChecked = false;

      infoMsgController.messageList = [message];
      infoMsgController.isMultipleSelectState = true

      mocker.mockFunc(infoMsgController, infoMsgController.setConversationCheckAll);

      expect(infoMsgController.onBackPress()).assertTrue();
    })

    it('InfoMsgController_clickToGroupDetail_isJumping_false_contactsNum_1', 0, () => {
      let message: messageType = new messageType();
      message.contactsNum = 1;
      message.telephone = '111';
      message.threadId = 1;

      infoMsgController.messageList = [message];
      infoMsgController.isMultipleSelectState = true;
      infoMsgController.isJumping = false;

      mocker.mockFunc(infoMsgController, infoMsgController.jumpToContact);

      infoMsgController.clickToGroupDetail(0);

      expect(infoMsgController.isJumping).assertTrue();
    })

    it('InfoMsgController_clickToGroupDetail_contactsNum_1_pubPort', 0, () => {
      let message: messageType = new messageType();
      message.contactsNum = 1;
      message.telephone = '000000111';
      message.threadId = 1;

      infoMsgController.messageList = [message];
      infoMsgController.isMultipleSelectState = true;
      infoMsgController.isJumping = false;

      infoMsgController.clickToGroupDetail(0);

      expect(infoMsgController.isJumping).assertTrue();
    })

    it('InfoMsgController_clickToGroupDetail_isJumping_false_contactsNum_2', 0, () => {
      let message: messageType = new messageType();
      message.contactsNum = 2;
      message.telephone = '111';
      message.threadId = 1;

      infoMsgController.messageList = [message];
      infoMsgController.isMultipleSelectState = true;
      infoMsgController.isJumping = false;

      mocker.mockFunc(infoMsgController, infoMsgController.jumpToGroupDetail);

      infoMsgController.clickToGroupDetail(0);

      expect(infoMsgController.isJumping).assertTrue();
    })


    it('InfoMsgController_clickToGroupDetail_isJumping_true', 0, () => {
      infoMsgController.isJumping = true;

      infoMsgController.clickToGroupDetail(0);

      expect(infoMsgController.isJumping).assertTrue();
    })

    it('InfoMsgController_exitConversationSelect', 0, () => {
      mocker.mockFunc(infoMsgController, infoMsgController.onBackPress);

      infoMsgController.exitConversationSelect();

      mocker.verify('onBackPress', []).once();
    })

    it('InfoMsgController_touchStart_itemTouchedIdx_1_isDelShow_true', 0, () => {
      let message: messageType = new messageType();
      message.contactsNum = 2;
      message.telephone = '111';
      message.threadId = 1;
      message.isDelShow = true;
      message.countOfUnread = 1;

      infoMsgController.messageList = [message, message];
      infoMsgController.isMultipleSelectState = false;
      infoMsgController.itemTouchedIdx = 1;

      infoMsgController.touchStart({} as GestureEvent, 0);

      expect(infoMsgController.operateBtnW).assertEqual(128);
    })

    it('InfoMsgController_touchStart_itemTouchedIdx_1_isDelShow_false', 0, () => {
      let message: messageType = new messageType();
      message.contactsNum = 2;
      message.telephone = '111';
      message.threadId = 1;
      message.isDelShow = false;
      message.countOfUnread = 0;

      infoMsgController.messageList = [message, message];
      infoMsgController.isMultipleSelectState = false;
      infoMsgController.itemTouchedIdx = 1;

      infoMsgController.touchStart({} as GestureEvent, 0);

      expect(infoMsgController.operateBtnW).assertEqual(80);
    })

    it('InfoMsgController_touchStart_itemTouchedIdx_0', 0, () => {
      let message: messageType = new messageType();
      message.contactsNum = 2;
      message.telephone = '111';
      message.threadId = 1;
      message.isDelShow = false;
      message.countOfUnread = 0;

      infoMsgController.messageList = [message, message];
      infoMsgController.isMultipleSelectState = false;
      infoMsgController.itemTouchedIdx = 0;

      infoMsgController.touchStart({} as GestureEvent, 0);

      expect(infoMsgController.operateBtnW).assertEqual(80);
    })

    it('InfoMsgController_resetTouch_itemTouchedIdx_0_isDelShow_false', 0, () => {
      let message: messageType = new messageType();
      message.isDelShow = false;

      infoMsgController.messageList = [message];
      infoMsgController.itemTouchedIdx = 0;

      expect(infoMsgController.resetTouch()).assertFalse();
    })

    it('InfoMsgController_resetTouch_itemTouchedIdx_0_isDelShow_true', 0, () => {
      let message: messageType = new messageType();
      message.isDelShow = true;

      infoMsgController.messageList = [message];
      infoMsgController.itemTouchedIdx = 0;

      mocker.mockFunc(infoMsgController, infoMsgController.setListItemTransX);

      expect(infoMsgController.resetTouch()).assertTrue();
    })

    it('InfoMsgController_touchMove_isMultipleSelectState_true', 0, () => {
      infoMsgController.isMultipleSelectState = true;
      let res = false;

      when(mocker.mockFunc(infoMsgController, infoMsgController.setListItemTransX))(ArgumentMatchers.any)
        .afterAction(() => {
          res = true;
        });

      infoMsgController.touchMove({
        offsetX: 1,
      } as GestureEvent, 0);

      expect(res).assertFalse();
    })

    it('InfoMsgController_touchMove_isMultipleSelectState_true_offsetX_lessThan2', 0, () => {
      infoMsgController.isMultipleSelectState = false;
      let res = false;

      when(mocker.mockFunc(infoMsgController, infoMsgController.setListItemTransX))(ArgumentMatchers.any)
        .afterAction(() => {
          res = true;
        });

      infoMsgController.touchMove({
        offsetX: 1,
      } as GestureEvent, 0);

      expect(res).assertFalse();
    })

    it('InfoMsgController_touchMove_isDelShow_true_if', 0, () => {
      let message: messageType = new messageType();
      message.isDelShow = true;

      infoMsgController.messageList = [message];
      infoMsgController.itemTouchedIdx = 0;
      infoMsgController.isMultipleSelectState = false;
      infoMsgController.operateBtnW = 1000;
      let res = false;

      when(mocker.mockFunc(infoMsgController, infoMsgController.setListItemTransX))(ArgumentMatchers.any)
        .afterAction(() => {
          res = true;
        });

      infoMsgController.touchMove({
        offsetX: 900,
      } as GestureEvent, 0);

      expect(res).assertTrue();
    })

    it('InfoMsgController_touchMove_isDelShow_true_else', 0, () => {
      let message: messageType = new messageType();
      message.isDelShow = true;

      infoMsgController.messageList = [message];
      infoMsgController.itemTouchedIdx = 0;
      infoMsgController.isMultipleSelectState = false;
      infoMsgController.operateBtnW = 100;

      mocker.mockFunc(infoMsgController, infoMsgController.setListItemTransX);

      infoMsgController.touchMove({
        offsetX: 900,
      } as GestureEvent, 0);

      mocker.verify('setListItemTransX', [0]).once();
    })

    it('InfoMsgController_touchMove_isDelShow_false_if', 0, () => {
      let message: messageType = new messageType();
      message.isDelShow = false;
      infoMsgController.messageList = [message];
      infoMsgController.itemTouchedIdx = 0;
      infoMsgController.isMultipleSelectState = false;
      infoMsgController.operateBtnW = 100;

      mocker.mockFunc(infoMsgController, infoMsgController.setListItemTransX);

      infoMsgController.touchMove({
        offsetX: 900,
      } as GestureEvent, 0);

      mocker.verify('setListItemTransX', [900]).once();
    })

    it('InfoMsgController_touchMove_isDelShow_false_else', 0, () => {
      let message: messageType = new messageType();
      message.isDelShow = false;

      infoMsgController.messageList = [message];
      infoMsgController.itemTouchedIdx = 0;
      infoMsgController.isMultipleSelectState = false;
      infoMsgController.operateBtnW = -1000;

      mocker.mockFunc(infoMsgController, infoMsgController.setListItemTransX);

      infoMsgController.touchMove({
        offsetX: 900,
      } as GestureEvent, 0);

      mocker.verify('setListItemTransX', [1000]).once();
    })

    it('InfoMsgController_deleteAction', 0, () => {
      let message: messageType = new messageType();
      message.isCbChecked = true;

      infoMsgController.messageList = [message];

      infoMsgController.deleteAction(0);

      expect(JSON.stringify(infoMsgController.strMsgDeleteDialogTip)).assertEqual(
        JSON.stringify($r('app.string.msg_delete_dialog_tip1'))
      );
    })

    it('InfoMsgController_touchEnd', 0, () => {
      infoMsgController.isMultipleSelectState = true;

      mocker.mockFunc(infoMsgController, infoMsgController.setListItemTransX);

      infoMsgController.touchEnd({
        offsetX: 900,
      } as GestureEvent, 0);

      mocker.verify('setListItemTransX', [0]).never();
    })

    it('InfoMsgController_touchEnd_if', 0, () => {
      let message: messageType = new messageType();
      message.isCbChecked = true;
      message.isDelShow = false;
      infoMsgController.messageList = [message];

      infoMsgController.isMultipleSelectState = false;
      infoMsgController.itemTouchedIdx = 0;
      infoMsgController.operateBtnW = 0;

      mocker.mockFunc(infoMsgController, infoMsgController.setListItemTransX);

      infoMsgController.touchEnd({
        offsetX: 900,
      } as GestureEvent, 0);

      mocker.verify('setListItemTransX', [0]).once();
    })

    it('InfoMsgController_touchEnd_else', 0, () => {
      let message: messageType = new messageType();
      message.isCbChecked = true;
      message.isDelShow = false;
      infoMsgController.messageList = [message];

      infoMsgController.itemTouchedIdx = 0;
      infoMsgController.isMultipleSelectState = false;
      infoMsgController.operateBtnW = 0;

      mocker.mockFunc(infoMsgController, infoMsgController.setListItemTransX);

      infoMsgController.touchEnd({
        offsetX: -900,
      } as GestureEvent, 0);

      mocker.verify('setListItemTransX', [0]).once();
    })

    it('InfoMsgController_subscribeInfo', 0, () => {
      let res = false;
      mocker.mockFunc(infoMsgController, infoMsgController.createSubscriberCallBack);
      mocker.mockFunc(infoMsgController, infoMsgController.createUpdateSubscriberCallBack);
      when(mocker.mockFunc(HiLog, HiLog.i))(ArgumentMatchers.any).afterAction(() => {
        res = true;
      });

      infoMsgController.subscribeInfo(context);

      expect(res).assertTrue();
    })

    it('InfoMsgController_setListItemTransX_transX_0', 0, () => {
      let message: messageType = new messageType();
      message.isCbChecked = true;

      infoMsgController.messageList = [message];
      infoMsgController.itemTouchedIdx = 0;
      infoMsgController.flushTranslate = false;

      infoMsgController.setListItemTransX(0);

      expect(infoMsgController.flushTranslate).assertTrue();
    })

    it('InfoMsgController_setListItemTransX_transX_1', 0, () => {
      let message: messageType = new messageType();
      message.isCbChecked = true;

      infoMsgController.messageList = [message];
      infoMsgController.itemTouchedIdx = 1;
      infoMsgController.flushTranslate = false;

      infoMsgController.setListItemTransX(0);

      expect(infoMsgController.flushTranslate).assertTrue();
    })

    it('InfoMsgController_setListItemTransX_item_undefined', 0, () => {
      infoMsgController.messageList = [];
      infoMsgController.itemTouchedIdx = 1;
      infoMsgController.flushTranslate = false;

      infoMsgController.setListItemTransX(0);

      expect(infoMsgController.flushTranslate).assertTrue();
    })

    it('InfoMsgController_updateData_if', 0, () => {
      mocker.mockFunc(infoMsgController.conListCtrl, infoMsgController.conListCtrl.statisticalData);

      infoMsgController.updateData(context, {} as BusinessError, {} as commonEventManager.CommonEventData);

      mocker.verify('statisticalData', []).never();
    })

    it('InfoMsgController_updateData', 0, () => {
      let message: messageType = new messageType();
      message.telephone = '1111';
      message.countOfUnread = 1;

      infoMsgController.messageList = [message];

      let res = false;
      when(mocker.mockFunc(infoMsgController.conListCtrl, infoMsgController.conListCtrl.statisticalData))()
        .afterAction(() => {
          res = true;
        });
      mocker.mockFunc(infoMsgController.conversationListDataSource,
        infoMsgController.conversationListDataSource.refresh);

      infoMsgController.updateData(context, {} as BusinessError, {
        parameters: {
          telephone: '1111'
        } as LooseObject
      } as commonEventManager.CommonEventData);

      expect(res).assertFalse();

      mocker.clear(infoMsgController.conListCtrl);
      mocker.clear(infoMsgController.conversationListDataSource);
    })

    it('InfoMsgController_updateData_noIf', 0, () => {
      let message: messageType = new messageType();
      message.telephone = '1112';
      message.countOfUnread = 1;

      infoMsgController.messageList = [message];
      let res = false;
      when(mocker.mockFunc(infoMsgController.conListCtrl, infoMsgController.conListCtrl.statisticalData))()
        .afterAction(() => {
          res = true;
        });
      mocker.mockFunc(infoMsgController.conversationListDataSource,
        infoMsgController.conversationListDataSource.refresh);

      infoMsgController.updateData(context, {} as BusinessError, {
        parameters: {
          telephone: '1111'
        } as LooseObject
      } as commonEventManager.CommonEventData);

      expect(res).assertFalse();

      mocker.clear(infoMsgController.conListCtrl);
      mocker.clear(infoMsgController.conversationListDataSource);
    })

    it('InfoMsgController_subscriberCallBack', 0, () => {
      infoMsgController.subscriberCallBack(context, {} as BusinessError, {
        parameters: {
          telephone: '1111'
        } as LooseObject
      } as commonEventManager.CommonEventData);

      expect(infoMsgController.page).assertEqual(1);
    })

    it('InfoMsgController_requestItemFromOther', 0, () => {
      infoMsgController.requestItemFromOther(context);

      expect(infoMsgController.page).assertEqual(1);
    })

    it('InfoMsgController_jumpToContact', 0, () => {
      let actionData: ActionData = {} as ActionData;
      let strTypeSet: StrTypeSet = {} as StrTypeSet;
      when(mocker.mockFunc(commonService, commonService.commonContactParam))()
        .afterReturn(strTypeSet);
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('mmsContext')
        .afterReturn({
          startAbility: (want: Want,
            options?: StartOptions | undefined): Promise<void> => new Promise<void>(resolve => {
            resolve()
          })
        });

      infoMsgController.jumpToContact(actionData);

      expect(infoMsgController.isJumping).assertFalse();

      mocker.clear(commonService);
      mocker.clear(GlobalContext.getContext());
    })

    it('InfoMsgController_jumpToContact_catch', 0, () => {
      let actionData: ActionData = {} as ActionData;
      let strTypeSet: StrTypeSet = {} as StrTypeSet;
      when(mocker.mockFunc(commonService, commonService.commonContactParam))()
        .afterReturn(strTypeSet);
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('mmsContext')
        .afterReturn({
          startAbility: (want: Want,
            options?: StartOptions | undefined): Promise<void> => new Promise<void>((resolve: () => void,
            reject: (reason: BusinessError) => void) => {
            reject({
              code: 1, message: 'error'
            } as BusinessError)
          })
        });

      infoMsgController.jumpToContact(actionData);

      expect(infoMsgController.isJumping).assertFalse();

      mocker.clear(commonService);
      mocker.clear(GlobalContext.getContext());
    })


    it('InfoMsgController_getSettingFlagForConvListPage', 0, () => {
      when(mocker.mockFunc(settingService, settingService.getSettingFlagForConvListPage))()
        .afterReturn({
          'isShowContactHeadIcon': true
        } as Record<string, boolean>);

      infoMsgController.getSettingFlagForConvListPage();

      expect(infoMsgController.isShowContactHeadIcon).assertTrue();

      mocker.clear(settingService);
    })

    it('TransmitMsgController_queryInfoPageMessages_isDraft_true_isEnd_true', 0, async () => {
      infoMsgController.totalMessage = 1;
      infoMsgController.page = 1;
      infoMsgController.total = 1;

      when(mocker.mockFunc(ConversationListService.getInstance(),
        ConversationListService.getInstance().getSessionListResultNew))(ArgumentMatchers.any)
        .afterReturn(new Promise<LooseObject>(resolve => resolve({
          response: [{
            messageCount: 1,
            isDraft: true
          }]
        } as LooseObject)));

      await infoMsgController.queryInfoPageMessages(1, 1, 1, 1, 1, (infoTotal: number,
        refreshIndex: number, totalOfInfoCount: number, isEnd: boolean) => {
        expect(refreshIndex).assertEqual(0);
      });

      mocker.clear(ConversationListService.getInstance());
    })

    it('TransmitMsgController_queryInfoPageMessages_isDraft_false_isEnd_true', 0, async () => {
      infoMsgController.totalMessage = 10;
      infoMsgController.page = 1;
      infoMsgController.total = 1;

      when(mocker.mockFunc(ConversationListService.getInstance(),
        ConversationListService.getInstance().getSessionListResultNew))(ArgumentMatchers.any)
        .afterReturn(new Promise<LooseObject>(resolve => resolve({
          response: [{
            messageCount: 1,
            isDraft: false
          }]
        } as LooseObject)));

      when(mocker.mockFunc(StringUtil, StringUtil.getLimitForSession))(1)
        .afterReturn(10);

      await infoMsgController.queryInfoPageMessages(1, 1, 1, 1, 1, (infoTotal: number,
        refreshIndex: number, totalOfInfoCount: number, isEnd: boolean) => {
        expect(refreshIndex).assertEqual(0);
      });

      mocker.clear(ConversationListService.getInstance());
      mocker.clear(StringUtil);
    })

    it('TransmitMsgController_queryInfoPageMessages_isDraft_false_isEnd_false', 0, async () => {
      infoMsgController.totalMessage = 10;
      infoMsgController.page = 1;
      infoMsgController.total = 1;

      when(mocker.mockFunc(ConversationListService.getInstance(),
        ConversationListService.getInstance().getSessionListResultNew))(ArgumentMatchers.any)
        .afterReturn(new Promise<LooseObject>(resolve => resolve({
          response: [{
            messageCount: 1,
            isDraft: false
          }]
        } as LooseObject)));

      when(mocker.mockFunc(StringUtil, StringUtil.getLimitForSession))(1)
        .afterReturn(0);

      await infoMsgController.queryInfoPageMessages(1, 1, 1, 1, 1, (infoTotal: number,
        refreshIndex: number, totalOfInfoCount: number, isEnd: boolean) => {
        expect(refreshIndex).assertEqual(1);
      });

      mocker.clear(ConversationListService.getInstance());
      mocker.clear(StringUtil);
    })

    it('TransmitMsgController_queryInfoPageMessages_catch', 0, async () => {
      infoMsgController.totalMessage = 10;
      infoMsgController.page = 1;
      infoMsgController.total = 1;
      let res = false;

      let error: BusinessError = {
        code: 1,
        message: 'error'
      } as BusinessError;

      when(mocker.mockFunc(ConversationListService.getInstance(),
        ConversationListService.getInstance().getSessionListResultNew))(ArgumentMatchers.any)
        .afterReturn(new Promise<LooseObject>((resolve: (value: LooseObject | PromiseLike<LooseObject>) => void,
          reject: (reason?: BusinessError) => void) => reject(error)));

      when(mocker.mockFunc(HiLog, HiLog.e))(TAG).afterAction(() => {
        res = true;
      })

      await infoMsgController.queryInfoPageMessages(1, 1, 1, 1, 1, (infoTotal: number,
        refreshIndex: number, totalOfInfoCount: number, isEnd: boolean) => {
      });

      expect(res).assertTrue();

      mocker.clear(ConversationListService.getInstance());
    })

    it('InfoMsgController_updateInfoMsg', 0, () => {
      infoMsgController.taskId = 1;
      infoMsgController.page = 1;

      when(mocker.mockFunc(ConversationListService.getInstance(),
        ConversationListService.getInstance().getSessionListSize))(ArgumentMatchers.any)
        .afterReturn(new Promise<number>(resolve => resolve(0)));

      mocker.mockFunc(infoMsgController, infoMsgController.requestItem);

      infoMsgController.requestItem(context);
      infoMsgController.updateInfoMsg(1, 0, 1);

      expect(infoMsgController.page).assertEqual(1);
    })
  })
}