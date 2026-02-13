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
} from '../../../../../main/ets/pages/conversationlist/conversationListController';
import { TransmitInfoType } from '../../../../../main/ets/pages/conversation/conversationController';
import ConversationListService from '../../../../../main/ets/service/ConversationListService';
import { BusinessError } from '@ohos.base';
import commonEventManager from '@ohos.commonEventManager';
import LooseObject from '../../../../../main/ets/data/LooseObject';
import dateUtil, { DateUtil } from '../../../../../main/ets/utils/DateUtil';
import { GlobalContext } from '../../../../../main/ets/MainAbility/GlobalHelper';
import ConversationService from '../../../../../main/ets/service/ConversationService';
import DataShareHelper from '../../../../../main/ets/model/repository/DataShareHelper';
import common from '@ohos.app.ability.common';
import SharedPreferencesUtils from '../../../../../main/ets/utils/SharedPreferencesUtils';
import { dataShare, DataShareResultSet } from '@kit.ArkData';
import type { AsyncCallback } from '@ohos.base';
import HiLog from '../../../../../main/ets/utils/HiLog';
import rcs from '@ohos.telephony.rcs';
import NotificationService from '../../../../../main/ets/service/NotificationService';
import DataService from '../../../../../main/ets/service/DataService';
import MySet from '../../MySet';
import SettingService from '../../../../../main/ets/service/SettingService';
import simCardService from '../../../../../main/ets/service/SimCardService';
import { BaseDataParameters } from '../../../../../main/ets/utils/TypesUtils';
import DotUtil from '../../../../../main/ets/utils/MmsDot/DotUtils';
import { window } from '@kit.ArkUI';
import { DTGlobalContext } from '../../../testability/TestAbility';
import AccessibilityUtil from '../../../../../main/ets/utils/AccessibilityUtil';

export default function conversationLCtrPart1Test() {
  describe('conversationLCtrPart1Test', () => {

    const TAG = 'ConversationListController';
    let conversationListController: ConversationListController;
    let mocker: MockKit;
    let context: Context = GlobalContext.getContext().getObject('mmsContext') as Context;

    beforeEach(() => {
      mocker = new MockKit();
      conversationListController = new ConversationListController();
    })

    afterEach(() => {
      AppStorage.clear();
      mocker.clear(conversationListController);
      mocker.clear(ConversationListService.getInstance());
      mocker.clear(HiLog);
    })

    it('getInstance', 0, () => {
      expect(typeof ConversationListController.getInstance()).assertEqual(typeof conversationListController);
    })


    it("conversationListControllerTest_updateData", 0, () => {
      let err: BusinessError = {
        code: 404,
        name: "",
        message: "出错了"
      };
      let data: commonEventManager.CommonEventData = {
        event: "common.STR.RECEIVE_UPDATE_EVENT",
        code: 0,
        data: "",
        parameters: {
          event: "", telephone: "10001", unreadTotal: 1
        }
      };

      let messageList = [{
        threadId: 2,
        telephone: "10001",
        countOfUnread: 1
      } as messageType];

      conversationListController.messageList = messageList;
      let queryActionData: LooseObject = {};
      queryActionData.threadId = messageList[0].threadId;

      mocker.mockFunc(conversationListController.conversationListDataSource,
        conversationListController.conversationListDataSource.refresh);
      mocker.mockFunc(conversationListController, conversationListController.statisticalData);

      conversationListController.updateData(context, err, data);

      mocker.verify('statisticalData', []).never();

      mocker.clear(conversationListController.conversationListDataSource);
    })

    it("cvsListControllerTest_registerDataChangeObserver", 0, () => {
      let context = (GlobalContext.getContext().getObject('mmsContext') as common.UIAbilityContext);

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initContactDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper | undefined>(resolve => resolve({
          on: (event: "dataChange", type: dataShare.SubscriptionType, uri: string,
            callback: AsyncCallback<dataShare.ChangeInfo, void>): void => {
            callback({} as BusinessError, {} as dataShare.ChangeInfo);
          }
        } as dataShare.DataShareHelper)));

      conversationListController.registerDataChangeObserver((err: BusinessError, data: dataShare.ChangeInfo) => {
        expect(JSON.stringify(err)).assertEqual('{}');
      }, context);

      mocker.clear(DataShareHelper.getInstance());
    })

    it("cvsListControllerTest_registerDataChangeObserver_catch", 0, () => {
      let context = (GlobalContext.getContext().getObject('mmsContext') as common.UIAbilityContext);

      mocker.mockFunc(HiLog, HiLog.w);

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initContactDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper | undefined>((resolve: (value: dataShare.DataShareHelper | PromiseLike<dataShare.DataShareHelper>) => void,
          reject: (reason?: BusinessError) => void) => reject({
          message: 'error'
        } as BusinessError)));

      conversationListController.registerDataChangeObserver((err: BusinessError, data: dataShare.ChangeInfo) => {
      }, context);

      mocker.verify('w', [TAG, 'error:%s' + JSON.stringify('error')]).once;

      mocker.clear(DataShareHelper.getInstance());

    })

    it("cvsListControllerTest_unregisterDataChangeObserver", 0, () => {
      let context = (GlobalContext.getContext().getObject('mmsContext') as common.UIAbilityContext);

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initContactDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper | undefined>(resolve => resolve({
          off: (event: "dataChange", type: dataShare.SubscriptionType, uri: string,
            callback: AsyncCallback<dataShare.ChangeInfo, void>): void => {
            callback({} as BusinessError, {} as dataShare.ChangeInfo);
          }
        } as dataShare.DataShareHelper)));

      conversationListController.unregisterDataChangeObserver((err: BusinessError, data: dataShare.ChangeInfo) => {
        expect(JSON.stringify(err)).assertEqual('{}');
      }, context);

      mocker.clear(DataShareHelper.getInstance());
    })

    it("cvsListControllerTest_unregisterDataChangeObserver_catch", 0, () => {
      let context = (GlobalContext.getContext().getObject('mmsContext') as common.UIAbilityContext);

      mocker.mockFunc(HiLog, HiLog.w);
      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initContactDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper | undefined>((resolve: (value: dataShare.DataShareHelper | PromiseLike<dataShare.DataShareHelper>) => void,
          reject: (reason?: BusinessError) => void) => reject({
          message: 'error'
        } as BusinessError)));

      conversationListController.unregisterDataChangeObserver((err: BusinessError, data: dataShare.ChangeInfo) => {
      }, context);

      mocker.verify('w', [TAG, 'error:%s' + JSON.stringify('error')]).once;

      mocker.clear(DataShareHelper.getInstance());

    })

    it("cvsListControllerTest_onRcsStateChange", 0, () => {
      mocker.mockFunc(HiLog, HiLog.i);
      when(mocker.mockFunc(conversationListController, conversationListController.rcsOn))(ArgumentMatchers.any)
        .afterReturn(new Promise<void>(resolve => resolve()));

      conversationListController.onRcsStateChange();

      mocker.verify('i', [TAG, 'onRcsStateChange Invoking']).once;
    })

    it("cvsListControllerTest_onRcsStateChange_catch", 0, () => {
      mocker.mockFunc(HiLog, HiLog.i);
      when(mocker.mockFunc(conversationListController, conversationListController.rcsOn))(ArgumentMatchers.any)
        .afterReturn(new Promise<void>((resolve: () => void,
          reject: (error: Error) => void) => reject(new Error('error'))));

      conversationListController.onRcsStateChange();

      mocker.verify('i', [TAG, 'onRcsStateChange Invoking']).once;
    })

    it("cvsListControllerTest_onRcsStateChangeresult_type_1", 0, async () => {
      await conversationListController.onRcsStateChangeresult({
        type: 1
      } as rcs.RcsEvent);

      expect(AppStorage.get('isOnlineRcs')).assertTrue();

      AppStorage.clear();
    })

    it("cvsListControllerTest_onRcsStateChangeresult_type_2", 0, async () => {
      await conversationListController.onRcsStateChangeresult({
        type: 2
      } as rcs.RcsEvent);

      expect(AppStorage.get('isOnlineRcs')).assertFalse();

      AppStorage.clear();
    })


    it("cvsListControllerTest_onShow_isInited_false", 0, () => {
      conversationListController.isInited = false;
      let pageInfos: NavPathStack = new NavPathStack();
      let transmitInfoTypeList = [{
        isRcs: 1,
        content: 'string',
        contactsName: 'ResourceStr',
        isMsm: true,
        msgShowType: 2,
        msgUriPath: 'string',
        contentInfo: 'string',
        contentType: 3,
        info: 'string',
        mms: []
      } as TransmitInfoType];

      pageInfos.pushPathByName('Conversation', {
        threadId: 1,
        strContactsName: '11',
        strContactsNumber: '123456',
        strContactsNumberFormat: '123456',
        isFromTransmitView: true,
        isContainerOriginSource: true,
        transmitSource: transmitInfoTypeList
      } as LooseObject);

      AppStorage.setOrCreate('backHasInfoMsg', true);

      conversationListController.onShow(context, pageInfos);

      expect(conversationListController.isJumping).assertFalse();
    })

    it("cvsListControllerTest_onShowRcs", 0, () => {
      mocker.mockFunc(conversationListController, conversationListController.networkStatusChanged);
      mocker.mockFunc(conversationListController, conversationListController.setRcsInfosResult);
      mocker.mockFunc(conversationListController, conversationListController.getCellularData);
      mocker.mockFunc(conversationListController, conversationListController.getSimState);
      mocker.mockFunc(conversationListController, conversationListController.getAirPlaneMode);
      mocker.mockFunc(conversationListController, conversationListController.onRcsStateChange);

      conversationListController.onShowRcs(context);

      mocker.verify('onRcsStateChange', []).once();
    })


    it('cvsListControllerTest_refreshConversationListData_isBlockedListBack_true', 0, () => {
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('backFromConversation')
        .afterReturn(true);

      conversationListController.refreshConversationListData(context);

      mocker.clear(GlobalContext.getContext());
    })

    it('cvsListControllerTest_refreshConversationListData_needToUpdate_true', 0, () => {
      conversationListController.noUiProp.isRun = false;
      let getObject: Function = mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject);
      when(getObject)('backFromConversation').afterReturn(false);
      when(getObject)('needToUpdate').afterReturn(true);

      mocker.mockFunc(conversationListController, conversationListController.requestItem);
      conversationListController.noUiProp.isRun = false;

      conversationListController.refreshConversationListData(context);

      expect(conversationListController.messageList.length).assertEqual(0);
      mocker.clear(GlobalContext.getContext());
    })

    it('cvsListControllerTest_refreshConversationListData_isFromNotify_true', 0, () => {
      let getObject: Function = mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject);
      when(getObject)('backFromConversation').afterReturn(false);
      when(getObject)('needToUpdate').afterReturn(false);
      when(getObject)('isFromNotify').afterReturn(true);
      mocker.mockFunc(conversationListController, conversationListController.requestItem);
      conversationListController.noUiProp.isRun = false;

      conversationListController.refreshConversationListData(context);

      expect(conversationListController.messageList.length).assertEqual(0);

      mocker.clear(GlobalContext.getContext());
    })

    it('cvsListControllerTest_refreshConversationListData_isBackFromConversion_true', 0, () => {
      let getObject: Function = mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject);
      when(getObject)('backFromConversation').afterReturn(true);
      when(getObject)('needToUpdate').afterReturn(true);
      when(getObject)('isFromNotify').afterReturn(false);
      conversationListController.noUiProp.isRun = true;

      mocker.mockFunc(conversationListController, conversationListController.requestItem);
      conversationListController.noUiProp.isRun = false;

      conversationListController.refreshConversationListData(context);

      expect(conversationListController.messageList.length).assertEqual(0);

      mocker.clear(GlobalContext.getContext());
    })

    it('cvsListControllerTest_refreshConversationListData_needToUpdate_false_isTimeTick_false', 0, () => {
      let getObject: Function = mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject);
      when(getObject)('backFromConversation').afterReturn(false);
      when(getObject)('needToUpdate').afterReturn(false);
      when(getObject)('isFromNotify').afterReturn(false);
      when(getObject)('is24HourTimeChange').afterReturn(false);
      when(getObject)('TimeTick').afterReturn(true);
      mocker.mockFunc(conversationListController, conversationListController.requestItem);
      mocker.mockFunc(conversationListController.conversationListDataSource,
        conversationListController.conversationListDataSource.refresh);
      mocker.mockFunc(dateUtil, DateUtil.convertDateFormatForItem);
      conversationListController.noUiProp.isRun = true;
      conversationListController.messageList = [{} as messageType];

      conversationListController.refreshConversationListData(context);

      expect(GlobalContext.getContext().getObject('TimeTick')).assertTrue();

      mocker.clear(GlobalContext.getContext());
      mocker.clear(conversationListController.conversationListDataSource);
      mocker.clear(dateUtil);
    })

    it('cvsListControllerTest_refreshConversationListData_needToUpdate_false_is24Change_true', 0, () => {
      let getObject: Function = mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject);
      when(getObject)('backFromConversation').afterReturn(false);
      when(getObject)('needToUpdate').afterReturn(false);
      when(getObject)('isFromNotify').afterReturn(false);
      when(getObject)('is24HourTimeChange').afterReturn(true);
      when(getObject)('TimeTick').afterReturn(false);

      mocker.mockFunc(conversationListController, conversationListController.requestItem);
      mocker.mockFunc(conversationListController.conversationListDataSource,
        conversationListController.conversationListDataSource.refresh);
      mocker.mockFunc(dateUtil, DateUtil.convertDateFormatForItem);
      conversationListController.noUiProp.isRun = false;
      conversationListController.messageList = [{} as messageType];

      conversationListController.refreshConversationListData(context);

      expect(GlobalContext.getContext().getObject('is24HourTimeChange')).assertTrue();


      mocker.clear(GlobalContext.getContext());
      mocker.clear(conversationListController.conversationListDataSource);
      mocker.clear(dateUtil);
    })

    it("cvsListControllerTest_onDestroy", 0, () => {
      mocker.mockFunc(conversationListController, conversationListController.unSubscribeStaticEvent);
      mocker.mockFunc(conversationListController, conversationListController.unSubscribeMemoryEvent);
      mocker.mockFunc(conversationListController, conversationListController.unSubscribeTimeChangeEvent);
      mocker.mockFunc(conversationListController, conversationListController.unSubscribeTimeTickEvent);
      mocker.mockFunc(conversationListController, conversationListController.getAirPlaneMode);
      mocker.mockFunc(conversationListController, conversationListController.unsubscribeNeedRefreshEvent);

      conversationListController.onDestroy();

      mocker.verify('unsubscribeNeedRefreshEvent', []).once();
    })

    it("cvsListControllerTest_onHide", 0, () => {
      mocker.mockFunc(conversationListController, conversationListController.unSubscribe);

      conversationListController.onHide();

      mocker.verify('unSubscribe', []).once();
    })

    it('cvsListControllerTest_conversationLongPress_isDelShow_true', 0, () => {
      let messageList1 = [{
        threadId: 0,
        isDelShow: true,
        hasAttachment: true,
        content: '',
      } as messageType]
      conversationListController.messageList = messageList1;

      conversationListController.conversationLongPress(0);

      expect(conversationListController.messageList[0].isDelShow).assertTrue();
    })

    it("cvsListControllerTest_conversationLongPress_isMultipleSelectState_true", 0, () => {
      let messageList = [{
        threadId: 0,
        isDelShow: false,
        isCbChecked: false,
        hasAttachment: true,
        content: '',
      } as messageType]
      conversationListController.messageList = messageList;
      conversationListController.isMultipleSelectState = true;


      mocker.mockFunc(conversationListController, conversationListController.setConversationCheckAll);
      mocker.mockFunc(conversationListController, conversationListController.clickConversationCheckAll);
      mocker.mockFunc(conversationListController.conversationListDataSource,
        conversationListController.conversationListDataSource.notifyDataChange);

      conversationListController.conversationLongPress(0);

      expect(conversationListController.messageList[0].isCbChecked).assertTrue();

      mocker.clear(conversationListController.conversationListDataSource);
    })

    it("cvsListControllerTest_conversationLongPress_isMultipleSelectState_false", 0, () => {
      let messageList = [{
        threadId: 0,
        isDelShow: false,
        isCbChecked: false,
        hasAttachment: true,
        content: '',
      } as messageType]
      conversationListController.messageList = messageList;
      conversationListController.isMultipleSelectState = false;

      mocker.mockFunc(conversationListController, conversationListController.setConversationCheckAll);
      mocker.mockFunc(conversationListController, conversationListController.clickConversationCheckAll);
      mocker.mockFunc(conversationListController.conversationListDataSource,
        conversationListController.conversationListDataSource.notifyDataChange);

      conversationListController.conversationLongPress(0);

      expect(conversationListController.messageList[0].isCbChecked).assertTrue();

      mocker.clear(conversationListController.conversationListDataSource);
    })

    it("cvsListControllerTest_setConversationCheckAll", 0, () => {
      conversationListController.isMultipleSelectState = false;
      conversationListController.setConversationCheckAll(1);
      expect(conversationListController.isConversationCheckAll).assertFalse();
    })

    it("cvsListControllerTest_setConversationCheckAll_1_isCbChecked_true", 0, () => {
      conversationListController.isMultipleSelectState = true;
      conversationListController.isConversationCheckAll = true;
      let messageList1 = [{
        isCbChecked: true,
      } as messageType];
      conversationListController.messageList = messageList1;
      conversationListController.setConversationCheckAll(1);
      expect(conversationListController.isConversationCheckAll).assertTrue();
    })

    it("cvsListControllerTest_setConversationCheckAll_1_isCbChecked_false", 0, () => {
      conversationListController.isMultipleSelectState = true;
      conversationListController.isConversationCheckAll = false;
      let messageList1 = [{
        isCbChecked: false,
      } as messageType];
      conversationListController.messageList = messageList1;
      conversationListController.setConversationCheckAll(1);
      expect(!conversationListController.isConversationCheckAll).assertTrue();
    })

    it("cvsListControllerTest_setConversationCheckAll_2", 0, () => {
      conversationListController.isMultipleSelectState = true;
      conversationListController.setConversationCheckAll(2);

      expect(conversationListController.isConversationCheckAll).assertFalse();
    })

    it("cvsListControllerTest_setConversationCheckAll_3_isCbChecked_false", 0, () => {
      let messageList = [{
        threadId: 0,
        isDelShow: false,
        isCbChecked: false,
        hasAttachment: true,
        content: '',
      } as messageType]
      conversationListController.messageList = messageList;
      conversationListController.conversationSelectedNumber = 1;

      mocker.mockFunc(conversationListController.conversationListDataSource,
        conversationListController.conversationListDataSource.refresh);

      conversationListController.setConversationCheckAll(3, false);

      expect(conversationListController.isConversationCheckAll).assertFalse();

      mocker.clear(conversationListController.conversationListDataSource);
    })

    it("cvsListControllerTest_setConversationCheckAll_3_isCbChecked_true", 0, () => {
      let messageList = [{
        threadId: 0,
        isDelShow: false,
        isCbChecked: true,
        hasAttachment: true,
        content: '',
      } as messageType]
      conversationListController.messageList = messageList;
      conversationListController.conversationSelectedNumber = 2;
      mocker.mockFunc(conversationListController.conversationListDataSource,
        conversationListController.conversationListDataSource.refresh);

      conversationListController.setConversationCheckAll(3, true);

      expect(conversationListController.isConversationCheckAll).assertFalse();

      mocker.clear(conversationListController.conversationListDataSource);
    })

    it('cvsListControllerTest_resetTouch', 0, () => {
      conversationListController.itemTouchedIdx = 0;
      conversationListController.messageList = [];

      let result = conversationListController.resetTouch();

      expect(result).assertFalse();
    })

    it('cvsListControllerTest_resetTouch1', 0, () => {
      conversationListController.itemTouchedIdx = 0
      let messageList1 = [{
        isDelShow: true
      } as messageType]
      conversationListController.messageList = messageList1;

      let result = conversationListController.resetTouch();

      expect(result).assertTrue();
    })

    it('cvsListControllerTest_resetTouch2', 0, () => {
      conversationListController.itemTouchedIdx = -1;
      conversationListController.showMarkAllAsRead = true;

      mocker.mockFunc(conversationListController, conversationListController.setInfoItemTransX);


      let result = conversationListController.resetTouch();

      expect(result).assertTrue();
    })

    it('cvsListControllerTest_resetTouch3', 0, () => {
      conversationListController.itemTouchedIdx = -1;
      conversationListController.showMarkAllAsRead = false;

      let result = conversationListController.resetTouch();

      expect(result).assertFalse();
    })

    it('cvsListControllerTest_touchStart', 0, () => {
      conversationListController.isMultipleSelectState = true;

      mocker.mockFunc(conversationListController, conversationListController.setInfoItemTransX);

      conversationListController.touchStart({} as GestureEvent, 0);

      mocker.verify('setInfoItemTransX', []).never();
    })

    it('cvsListControllerTest_touchStart_showMarkAllAsRead_true', 0, () => {
      conversationListController.isMultipleSelectState = false;
      conversationListController.showMarkAllAsRead = true;

      mocker.mockFunc(conversationListController, conversationListController.setInfoItemTransX);

      conversationListController.touchStart({} as GestureEvent, 0);

      mocker.verify('setInfoItemTransX', [0]).once();
    })

    it('cvsListControllerTest_touchStart_showMarkAllAsRead_false', 0, () => {
      conversationListController.isMultipleSelectState = false;
      conversationListController.showMarkAllAsRead = false;
      conversationListController.itemTouchedIdx = 1;

      let messageList = [{
        threadId: 0,
        isDelShow: false,
        isCbChecked: true,
        hasAttachment: true,
        content: '',
      } as messageType, {
        threadId: 0,
        isDelShow: true,
        isCbChecked: true,
        hasAttachment: true,
        content: '',
        countOfUnread: 1
      } as messageType];
      conversationListController.messageList = messageList;

      mocker.mockFunc(conversationListController, conversationListController.setListItemTransX);

      conversationListController.touchStart({} as GestureEvent, 0);

      expect(conversationListController.operateBtnW).assertEqual(80);
    })

    it('cvsListControllerTest_touchStart_showMarkAllAsRead_false_countOfUnread_0', 0, () => {
      conversationListController.isMultipleSelectState = false;
      conversationListController.showMarkAllAsRead = false;
      conversationListController.itemTouchedIdx = 0;

      let messageList = [{
        threadId: 0,
        isDelShow: false,
        isCbChecked: true,
        hasAttachment: true,
        content: '',
      } as messageType, {
        threadId: 0,
        isDelShow: false,
        isCbChecked: true,
        hasAttachment: true,
        content: '',
        countOfUnread: 1
      } as messageType
      ]
      conversationListController.messageList = messageList;

      mocker.mockFunc(conversationListController, conversationListController.setInfoItemTransX);

      conversationListController.touchStart({} as GestureEvent, 1);

      expect(conversationListController.operateBtnW).assertEqual(128);
    })

    it('cvsListControllerTest_touchStart_item_undefined', 0, () => {
      conversationListController.isMultipleSelectState = false;
      conversationListController.showMarkAllAsRead = false;
      conversationListController.itemTouchedIdx = 2;

      let messageList = [{
        threadId: 0,
        isDelShow: false,
        isCbChecked: true,
        hasAttachment: true,
        content: '',
      } as messageType, {
        threadId: 0,
        isDelShow: false,
        isCbChecked: true,
        hasAttachment: true,
        content: '',
        countOfUnread: 1
      } as messageType]
      conversationListController.messageList = messageList;

      mocker.mockFunc(conversationListController, conversationListController.setInfoItemTransX);

      conversationListController.touchStart({} as GestureEvent, 0);

      mocker.verify('setInfoItemTransX', []).never();
    })

    it('cvsListControllerTest_touchMove_isMultipleSelectState_true', 0, () => {
      conversationListController.isMultipleSelectState = true;

      let event: GestureEvent = {
        offsetX: -10,
        offsetY: 10
      } as GestureEvent;

      mocker.mockFunc(conversationListController, conversationListController.setListItemTransX);

      conversationListController.touchMove(event, 0);

      mocker.verify('setListItemTransX', []).never();
    })

    it('cvsListControllerTest_touchMove_isDelShow_true_if', 0, () => {
      conversationListController.isMultipleSelectState = false;
      conversationListController.showMarkAllAsRead = false;
      conversationListController.itemTouchedIdx = 0;
      conversationListController.operateBtnW = 10;

      let event: GestureEvent = {
        offsetX: 10,
        offsetY: 10
      } as GestureEvent;

      let messageList = [{
        threadId: 0,
        isDelShow: true,
        isCbChecked: true,
        hasAttachment: true,
        content: '',
      } as messageType];
      conversationListController.messageList = messageList;

      mocker.mockFunc(conversationListController, conversationListController.setListItemTransX);

      conversationListController.touchMove(event, 0);

      mocker.verify('setListItemTransX', [0]).once();
    })

    it('cvsListControllerTest_touchMove_isDelShow_true_else', 0, () => {
      conversationListController.isMultipleSelectState = false;
      conversationListController.showMarkAllAsRead = false;
      conversationListController.itemTouchedIdx = 0;
      conversationListController.operateBtnW = 10;

      let event: GestureEvent = {
        offsetX: 11,
        offsetY: 10
      } as GestureEvent;

      let messageList = [{
        threadId: 0,
        isDelShow: true,
        isCbChecked: true,
        hasAttachment: true,
        content: '',
      } as messageType];
      conversationListController.messageList = messageList;

      mocker.mockFunc(conversationListController, conversationListController.setListItemTransX);

      conversationListController.touchMove(event, 0);

      mocker.verify('setListItemTransX', [0]).once();
    })

    it('cvsListControllerTest_touchMove_isDelShow_false_if', 0, () => {
      conversationListController.isMultipleSelectState = false;
      conversationListController.showMarkAllAsRead = false;
      conversationListController.itemTouchedIdx = 0;
      conversationListController.operateBtnW = 10;

      let event: GestureEvent = {
        offsetX: 10,
        offsetY: 10
      } as GestureEvent;

      let messageList = [{
        threadId: 0,
        isDelShow: false,
        isCbChecked: true,
        hasAttachment: true,
        content: '',
      } as messageType];
      conversationListController.messageList = messageList;

      mocker.mockFunc(conversationListController, conversationListController.setListItemTransX);

      conversationListController.touchMove(event, 0);

      mocker.verify('setListItemTransX', [10]).once();
    })

    it('cvsListControllerTest_touchMove_isDelShow_false_else', 0, () => {
      conversationListController.isMultipleSelectState = false;
      conversationListController.showMarkAllAsRead = false;
      conversationListController.itemTouchedIdx = 0;
      conversationListController.operateBtnW = -1;

      let event: GestureEvent = {
        offsetX: -10,
        offsetY: 10
      } as GestureEvent;

      let messageList = [{
        threadId: 0,
        isDelShow: false,
        isCbChecked: true,
        hasAttachment: true,
        content: '',
      } as messageType];
      conversationListController.messageList = messageList;

      mocker.mockFunc(conversationListController, conversationListController.setListItemTransX);

      conversationListController.touchMove(event, 0);

      mocker.verify('setListItemTransX', [1]).once();
    })

    it('cvsListControllerTest_touchEnd_isMultipleSelectState_true', 0, () => {
      conversationListController.isMultipleSelectState = true;

      let event: GestureEvent = {
        offsetX: -10,
        offsetY: 10
      } as GestureEvent;

      mocker.mockFunc(conversationListController, conversationListController.setListItemTransX);

      conversationListController.touchEnd(event, 0);

      mocker.verify('setListItemTransX', []).never();
    })

    it('cvsListControllerTest_touchEnd_isMultipleSelectState_false_if', 0, () => {
      conversationListController.isMultipleSelectState = false;
      conversationListController.operateBtnW = 1;
      conversationListController.itemTouchedIdx = 0;

      let event: GestureEvent = {
        offsetX: 10,
        offsetY: 10
      } as GestureEvent;

      let messageList = [{
        threadId: 0,
        isDelShow: false,
        isCbChecked: true,
        hasAttachment: true,
        content: '',
      } as messageType];
      conversationListController.messageList = messageList;

      mocker.mockFunc(conversationListController, conversationListController.setListItemTransX);

      conversationListController.touchEnd(event, 0);

      mocker.verify('setListItemTransX', [0]).once();
    })

    it('cvsListControllerTest_touchEnd_isMultipleSelectState_false_else', 0, () => {
      conversationListController.isMultipleSelectState = false;
      conversationListController.operateBtnW = 1;
      conversationListController.itemTouchedIdx = 0;

      let event: GestureEvent = {
        offsetX: -10,
        offsetY: 10
      } as GestureEvent;
      let messageList = [{
        threadId: 0,
        isDelShow: false,
        isCbChecked: true,
        hasAttachment: true,
        content: '',
      } as messageType];
      conversationListController.messageList = messageList;

      mocker.mockFunc(conversationListController, conversationListController.setListItemTransX);

      conversationListController.touchEnd(event, 0);

      mocker.verify('setListItemTransX', [-1]).once();
    })

    it('cvsListControllerTest_setListItemTransX', 0, () => {
      conversationListController.itemTouchedIdx = 0;
      let messageList1 = [{
        isDelShow: true,
        itemLeft: 2
      } as messageType];
      conversationListController.messageList = messageList1;

      conversationListController.setListItemTransX(1);

      expect(conversationListController.messageList[0].itemLeft).assertEqual(0)
    })

    it('cvsListControllerTest_setListItemTransX1', 0, () => {
      conversationListController.itemTouchedIdx = 0;
      let messageList1 = [{
        isDelShow: true,
        itemLeft: 2
      } as messageType];
      conversationListController.messageList = messageList1;

      conversationListController.setListItemTransX(-1);

      expect(conversationListController.messageList[0].itemLeft).assertEqual(-1)
    })

    it('cvsListControllerTest_setInfoItemTransX_minus1', 0, () => {
      conversationListController.operateBtnW = 0;

      conversationListController.setInfoItemTransX(-1);

      expect(conversationListController.infoLeft).assertEqual(1);
    })

    it('cvsListControllerTest_setInfoItemTransX_1', 0, () => {
      conversationListController.operateBtnW = 0;

      conversationListController.setInfoItemTransX(1);

      expect(conversationListController.infoLeft).assertEqual(-1);
    })

    it('cvsListControllerTest_clickConversationDelete', 0, () => {
      conversationListController.conversationSelectedNumber = 0;
      mocker.mockFunc(DotUtil.getInstance(), DotUtil.getInstance().reportEvent);

      conversationListController.clickConversationDelete();

      expect(JSON.stringify(conversationListController.strMsgDeleteDialogTip?.params)).assertUndefined();

      mocker.clear(DotUtil.getInstance());
    })

    it('cvsListControllerTest_clickConversationDelete1', 0, () => {
      conversationListController.conversationSelectedNumber = 1;
      mocker.mockFunc(DotUtil.getInstance(), DotUtil.getInstance().reportEvent);

      conversationListController.clickConversationDelete();

      expect(conversationListController.conversationSelectedNumber).assertEqual(1);

      mocker.clear(DotUtil.getInstance());
    })

    it('cvsListControllerTest_clickConversationDelete2', 0, () => {
      conversationListController.conversationSelectedNumber = 2;
      let messageList1 = [{
        isCbChecked: false,
        isDelShow: true,
        itemLeft: 2
      } as messageType, {
        isCbChecked: false,
        isDelShow: true,
        itemLeft: 0
      } as messageType];
      conversationListController.messageList = messageList1;
      mocker.mockFunc(DotUtil.getInstance(), DotUtil.getInstance().reportEvent);

      conversationListController.clickConversationDelete();

      expect(conversationListController.conversationSelectedNumber).assertEqual(2);

      mocker.clear(DotUtil.getInstance());
    })

    it('cvsListControllerTest_clickConversationDelete3', 0, () => {
      conversationListController.conversationSelectedNumber = 3;
      let messageList1 = [{
        isCbChecked: false,
        isDelShow: true,
        itemLeft: 2
      } as messageType, {
        isCbChecked: false,
        isDelShow: true,
        itemLeft: 0
      } as messageType];
      conversationListController.messageList = messageList1;
      mocker.mockFunc(DotUtil.getInstance(), DotUtil.getInstance().reportEvent);

      conversationListController.clickConversationDelete();

      expect(conversationListController.conversationSelectedNumber).assertEqual(3);

      mocker.clear(DotUtil.getInstance());
    })

    it('cvsListControllerTest_clickConversationDelete_if3', 0, () => {
      conversationListController.conversationSelectedNumber = 3;
      conversationListController.total = 3;

      conversationListController.clickConversationDelete();

      expect(conversationListController.conversationSelectedNumber).assertEqual(3);
    })

    it('cvsListControllerTest_onBackPress', 0, () => {
      conversationListController.isMultipleSelectState = false;
      let messageList = [{
        isCbChecked: true
      } as messageType]
      conversationListController.messageList = messageList;

      conversationListController.onBackPress(context);

      expect(conversationListController.isMultipleSelectState).assertFalse();
    })

    it('cvsListControllerTest_onBackPress1', 0, () => {
      conversationListController.isMultipleSelectState = false;

      let result: boolean = conversationListController.onBackPress(context);

      expect(result).assertTrue()
    })

    it('cvsListControllerTest_onBackPress2', 0, () => {
      conversationListController.isMultipleSelectState = false;

      let result: boolean = conversationListController.onBackPress(context);

      expect(result).assertFalse()
    })

    it('cvsListControllerTest_onBackPress3', 0, () => {
      conversationListController.isMultipleSelectState = true;
      let messageList = [{
        isCbChecked: true
      } as messageType]
      conversationListController.messageList = messageList;

      let result: boolean = conversationListController.onBackPress(context);

      expect(result).assertTrue()
    })

    it('cvsListControllerTest_resetLastIndexValue', 0, () => {
      conversationListController.resetLastIndexValue();

      expect(conversationListController.lastIndex).assertEqual(-1);
    })

    it('cvsListControllerTest_deleteDialogCancel', 0, () => {
      conversationListController.isMultipleSelectState = false;
      conversationListController.delItem = 0
      let messageList1 = [{
        isCbChecked: true
      } as messageType];
      conversationListController.messageList = messageList1;

      conversationListController.deleteDialogCancel();

      expect(conversationListController.messageList[0].isCbChecked).assertFalse()
    })

    it('cvsListControllerTest_deleteDialogCancel1', 0, () => {
      conversationListController.isMultipleSelectState = true;

      conversationListController.deleteDialogCancel();

      expect(conversationListController.isMultipleSelectState).assertTrue();
    })

    it('cvsListControllerTest_setDelShow', 0, () => {
      let messageList1 = [{
        isCbChecked: true,
        isDelShow: false
      } as messageType];
      conversationListController.messageList = messageList1;
      conversationListController.itemTouchedIdx = 0;

      mocker.mockFunc(conversationListController, conversationListController.setListItemTransX);

      conversationListController.setDelShow();

      mocker.verify('setListItemTransX', [0]).once();
    })

    it('cvsListControllerTest_markInfoMsgAllAsRead', 0, () => {
      conversationListController.markInfoMsgAllAsRead();

      expect(AppStorage.get('unreadTotalOfInfo')).assertEqual(0);
    })

    it('cvsListControllerTest_jumpToSettingsPage_bp', 0, () => {
      AppStorage.setOrCreate('curBp', 'bp');

      conversationListController.jumpToSettingsPage();

      expect(AppStorage.get('selectPhoneNumber')).assertEqual('');
    })

    it('cvsListControllerTest_jumpToSettingsPage_sm', 0, () => {
      AppStorage.setOrCreate('curBp', 'sm');

      conversationListController.jumpToSettingsPage();

      expect(JSON.stringify(conversationListController.pageInfos.getParamByName('Settings')))
        .assertEqual('[{"pageFlag":"settingsDetail"}]');
    })

    it("cvsListControllerTest_jumpToFavoritesPage_sm", 0, () => {
      AppStorage.setOrCreate('curBp', 'sm');

      conversationListController.jumpToFavoritesPage();

      expect(conversationListController.lastIndex).assertEqual(-1);
    })

    it("cvsListControllerTest_jumpToFavoritesPage_bp", 0, () => {
      AppStorage.setOrCreate('curBp', 'bp');

      conversationListController.jumpToFavoritesPage();

      expect(conversationListController.lastIndex).assertEqual(-1);
    })

    it("cvsListControllerTest_subscribe", 0, () => {
      let result = false;
      mocker.mockFunc(conversationListController, conversationListController.createSubscriberCallBack);
      when(mocker.mockFunc(conversationListController,
        conversationListController.createUpdateSubscriberCallBack))(ArgumentMatchers.any)
        .afterAction(() => {
          result = true;
        });

      conversationListController.subscribe(context);

      expect(result).assertFalse();
    })

    it("cvsListControllerTest_subscriberCallBack", 0, () => {
      mocker.mockFunc(conversationListController, conversationListController.requestItem);
      mocker.mockFunc(conversationListController, conversationListController.statisticalData);
      let err: BusinessError = {
        code: 1, message: 'error'
      } as BusinessError;
      let data: commonEventManager.CommonEventData = {} as commonEventManager.CommonEventData;
      conversationListController.subscriberCallBack(context, data);
      expect(conversationListController.messageList.length).assertEqual(0);
      mocker.clear(simCardService);
    })

    it("cvsListControllerTest_unSubscribe", 0, () => {
      conversationListController.needRefreshEventData = {} as commonEventManager.CommonEventSubscriber;
      mocker.mockFunc(HiLog, HiLog.i);
      conversationListController.unSubscribe();
      expect(conversationListController.commonEventData).assertUndefined();
    })

    it("cvsListControllerTest_acceptFailureEvent", 0, () => {
      let result = false;
      when(mocker.mockFunc(conversationListController,
        conversationListController.createAcceptFailureCallBack))(ArgumentMatchers.any)
        .afterAction(() => {
          result = true;
        });
      conversationListController.acceptFailureEvent();
      expect(result).assertFalse();
    })

    it("cvsListControllerTest_getSettingFlagForConvListPage", 0, () => {
      let mySet: DataShareResultSet = new MySet();
      mySet.rowCount = 1;
      when(mocker.mockFunc(SettingService, SettingService.getSettingFlagForConvListPage))()
        .afterReturn({
          hasAggregate: false,
          isShowContactHeadIcon: false
        });
      conversationListController.getSettingFlagForConvListPage();
      expect(conversationListController.hasAggregate).assertFalse();
      mocker.clear(SettingService);
    })

    it("cvsListControllerTest_requestItem_firstPageCount_1_sessionSize_0", 0, () => {
      conversationListController.noUiProp.isRun = false;
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

      conversationListController.requestItem(context);

      expect(conversationListController.noUiProp.needAgain).assertFalse();
      mocker.clear(ConversationService.getInstance());
    })

    it("cvsListControllerTest_requestItem_firstPageCount_1_sessionSize_2", 0, () => {
      conversationListController.noUiProp.isRun = false;
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
        .afterReturn(new Promise<number>(resolve => resolve(2)));
      mocker.mockFunc(conversationListController, conversationListController.conversationListDataSource.refresh);
      mocker.mockFunc(conversationListController, conversationListController.queryCurPageAndRefresh);
      mocker.mockFunc(conversationListController, conversationListController.showFirstMessage);
      mocker.mockFunc(conversationListController, conversationListController.queryAllMessages);

      conversationListController.requestItem(context);

      expect(conversationListController.noUiProp.needAgain).assertFalse();

      mocker.clear(ConversationService.getInstance());
      mocker.clear(ConversationListService.getInstance());
    })

    it("cvsListControllerTest_deleteAction_hasInfoMsg_false", 0, () => {
      let messageList1 = [{
        threadId: 0,
        isCbChecked: false,
        content: '',
      } as messageType];
      conversationListController.messageList = messageList1;
      conversationListController.hasInfoMsg=false;

      conversationListController.deleteAction(0);
    })

    it("cvsListControllerTest_deleteAction_hasInfoMsg_true", 0, () => {
      conversationListController.messageList = [];
      conversationListController.hasInfoMsg=true;

      conversationListController.deleteAction(0);

      expect(conversationListController.messageDataStatus).assertEqual('2');
    })

    it("cvsListControllerTest_deleteAction_hasInfoMsg_false_list_length_0", 0, () => {
      conversationListController.messageList = [];
      conversationListController.hasInfoMsg=false;

      conversationListController.deleteAction(0);

      expect(conversationListController.messageDataStatus).assertEqual('3');
    })
  })
}