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
import { describe, beforeEach, it, expect, MockKit, when, ArgumentMatchers, afterEach, } from '@ohos/hypium';
import LooseObject from '../../../../../main/ets/data/LooseObject';
import { GlobalContext } from '../../../../../main/ets/MainAbility/GlobalHelper';
import common from "../../../../../main/ets/data/commonData"
import TelephoneUtil from '../../../../../main/ets/utils/TelephoneUtil';
import ConversationController, {
  mmsListType,
  selectContactType,
} from '../../../../../main/ets/pages/conversation/conversationController';
import HiLog from '../../../../../main/ets/utils/HiLog';
import MmsPreferences from '../../../../../main/ets/utils/MmsPreferences';
import myCommon from '@ohos.app.ability.common';
import { ValuesBucket } from '@ohos.data.ValuesBucket';
import ConversationListService from '../../../../../main/ets/service/ConversationListService';
import { Mms, PictureListData } from '../../../../../main/ets/utils/TypesUtils';
import SharedPreferencesUtils from '../../../../../main/ets/utils/SharedPreferencesUtils';
import DotUtil from '../../../../../main/ets/utils/MmsDot/DotUtils';
import ConversationService from '../../../../../main/ets/service/ConversationService';
import DataShareHelper from '../../../../../main/ets/model/repository/DataShareHelper';
import { dataShare, dataSharePredicates, DataShareResultSet } from '@kit.ArkData';
import ConversationDataSource from '../../../../../main/ets/model/ConversationDataSource';
import MySet from '../../MySet';
import { AsyncCallback, BusinessError } from '@kit.BasicServicesKit';
import ConversationListController from '../../../../../main/ets/pages/conversationlist/conversationListController';
import { window } from '@kit.ArkUI';
import settingService from '../../../../../main/ets/service/SettingService';
import commonEvent from '@ohos.commonEventManager';
import YellowPageService from '../../../../../main/ets/service/yellowPageService';
import StringUtil from '../../../../../main/ets/utils/StringUtil';
import { DTGlobalContext } from '../../../testability/TestAbility';
import { DraftUtils } from '../../../../../main/ets/utils/DraftUtils';
import { Context } from '@kit.AbilityKit';
import { EnhancedInfoTemporaryDataSource } from '../../../../../main/ets/model/EnhancedInfoTemporaryDataSource';

export default function conversationControllerPart1Test() {
  describe('conversationControllerTest1', () => {

    const TAG = 'ConversationController1';
    let mConversationCtrl: ConversationController;
    let mocker: MockKit;
    let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;

    beforeEach(() => {
      mocker = new MockKit();
      mConversationCtrl = ConversationController.getInstance();
    })

    afterEach(() => {
      mocker.clear(mConversationCtrl);
      mocker.clear(MmsPreferences.getInstance());
      mocker.clear(GlobalContext.getContext());
      mocker.clear(DataShareHelper.getInstance());
      mocker.clear(ConversationService.getInstance());
      AppStorage.clear();
    })

    it('ConversationControllerTest_getInstance', 0, () => {
      expect(typeof mConversationCtrl).assertEqual(typeof ConversationController.getInstance());
    })

    it('ConversationControllerTest_handleSendReportable_deliveryReportSwitch_2', 0, () => {
      let getValueOfDeliveryReportSwitch: Function =
        mocker.mockFunc(MmsPreferences.getInstance(), MmsPreferences.getInstance().getValueOfDeliveryReportSwitch);
      when(getValueOfDeliveryReportSwitch)().afterReturn(2);

      mConversationCtrl.handleSendReportable();

      expect(mConversationCtrl.sendReportable).assertTrue();
      mocker.clear(MmsPreferences.getInstance());
    })

    it('ConversationControllerTest_handleSendReportable_deliveryReportSwitch_3', 0, () => {
      let getValueOfDeliveryReportSwitch: Function =
        mocker.mockFunc(MmsPreferences.getInstance(), MmsPreferences.getInstance().getValueOfDeliveryReportSwitch);
      when(getValueOfDeliveryReportSwitch)().afterReturn(3);

      mConversationCtrl.handleSendReportable();

      expect(mConversationCtrl.sendReportable).assertTrue();
      mocker.clear(MmsPreferences.getInstance());
    })

    it('ConversationControllerTest_onInit', 0, () => {
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.handleSendReportable);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.resetMmsArea);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.resetData);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.initData);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.initRouterData);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.initYellowPageData);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.initNewPageContacts);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.appearSubscribe);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.subscribeStaticEvent);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.initCurrentQueryTimeID);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.getHasSimCard);
      mocker.mockFunc(mConversationCtrl.mAdvancedSettingsCtrl,
        mConversationCtrl.mAdvancedSettingsCtrl.getAdvancedPageSwitchValue);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.obtainSessionInformation);
      when(mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences))(ArgumentMatchers.any)
        .afterReturn(true);
      mocker.mockFunc(EnhancedInfoTemporaryDataSource.getInstance(), EnhancedInfoTemporaryDataSource.getInstance().clearMapImageMsgIdToData);

      mocker.mockFunc(DotUtil.getInstance(), DotUtil.getInstance().reportEvent);

      AppStorage.setOrCreate('comeFromContact', true);

      let pageInfos: NavPathStack = new NavPathStack();
      mConversationCtrl.onInit(context, pageInfos);

      mocker.verify('obtainSessionInformation', [context]).once();
      AppStorage.setOrCreate('comeFromContact', false);
      mConversationCtrl.onInit(context, pageInfos);

      mocker.clear(mConversationCtrl);
      mocker.clear(DotUtil.getInstance());
      mocker.clear(EnhancedInfoTemporaryDataSource.getInstance());
      mocker.clear(SharedPreferencesUtils);
      mocker.clear(mConversationCtrl.mAdvancedSettingsCtrl);
      AppStorage.clear();
    })

    it('ConversationControllerTest_initYellowPageData_empty_true', 0, async () => {
      when(mocker.mockFunc(StringUtil,
        StringUtil.isEmpty))(ArgumentMatchers.any)
        .afterReturn(true);
      when(mocker.mockFunc(YellowPageService.getInstance(),
        YellowPageService.getInstance().judgeYellowPageByTelephone))(ArgumentMatchers.any)
        .afterReturn(new Promise<LooseObject>(resolve => resolve({
          yellowPageId: '1',
          name: 'name',
        } as LooseObject)));

      await mConversationCtrl.initYellowPageData(context);

      expect(mConversationCtrl.smsType).assertEqual(1);

      mocker.clear(StringUtil);
      mocker.clear(YellowPageService.getInstance());
    })

    it('ConversationControllerTest_initYellowPageData_empty_false', 0, async () => {
      when(mocker.mockFunc(StringUtil,
        StringUtil.isEmpty))(ArgumentMatchers.any)
        .afterReturn(false);
      await mConversationCtrl.initYellowPageData(context);
      mocker.clear(StringUtil);

      when(mocker.mockFunc(StringUtil,
        StringUtil.isEmpty))(ArgumentMatchers.any)
        .afterReturn(true);
      when(mocker.mockFunc(YellowPageService.getInstance(),
        YellowPageService.getInstance().judgeYellowPageByTelephone))(ArgumentMatchers.any)
        .afterReturn(new Promise<LooseObject>(resolve => resolve({
          yellowPageId: undefined,
          name: 'name',
        } as LooseObject)));
      await mConversationCtrl.initYellowPageData(context);

      expect(mConversationCtrl.smsType).assertEqual(1);

      mocker.clear(StringUtil);
      mocker.clear(YellowPageService.getInstance());
    })



    it('ConversationControllerTest_obtainSessionInformation_isNewMsg_true_contactsNum_0', 0, () => {
      mConversationCtrl.isNewMsg = true;
      mConversationCtrl.contactsNum = 0;
      let mmsList0: mmsListType = new mmsListType();
      mmsList0.isRcs = 0;
      mmsList0.timeMillisecond = 0;
      mmsList0.dateShow = true;
      mmsList0.showTitle = true;
      let mmsList1: mmsListType = new mmsListType();
      mmsList1.isRcs = 0;
      mmsList1.timeMillisecond = 1;
      mmsList1.dateShow = true;
      mmsList1.showTitle = true;
      let mmsList2: mmsListType = new mmsListType();
      mmsList2.isRcs = 0;
      mmsList2.timeMillisecond = 1;
      mmsList2.dateShow = true;
      mmsList2.showTitle = true;
      let mmsList: mmsListType[] = [mmsList0, mmsList1, mmsList2];
      mocker.mockFunc(ConversationDataSource.getInstance(), ConversationDataSource.getInstance().refresh);
      when(mocker.mockFunc(MmsPreferences.getInstance(), MmsPreferences.getInstance().getSendMessageSlotId))()
        .afterReturn(1);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.updateSimSlotId);
      when(mocker.mockFunc(DraftUtils, DraftUtils.getInstance))()
        .afterReturn({
          queryNoReceiverDraft: (context: Context, callBack: Function) => {
            callBack({ code: 0, response: [] })
          },
          getDraftTextData:(context: Context, threadId: number, callback: Function) => {}
        });
      mConversationCtrl.obtainSessionInformation(context);
      mocker.clear(DraftUtils);

      mocker.verify('updateSimSlotId', [1]).once();
      when(mocker.mockFunc(DraftUtils, DraftUtils.getInstance))()
        .afterReturn({
          queryNoReceiverDraft: (context: Context, callBack: Function) => {
            callBack({ code: -1, response: [] })
          },
          getDraftTextData:(context: Context, threadId: number, callback: Function) => {}
        });
      mConversationCtrl.obtainSessionInformation(context);
      mocker.clear(DraftUtils);

      when(mocker.mockFunc(DraftUtils, DraftUtils.getInstance))()
        .afterReturn({
          queryNoReceiverDraft: (context: Context, callBack: Function) => {
            callBack({ code: 0, response: mmsList })
          },
          getDraftTextData:(context: Context, threadId: number, callback: Function) => {}
        });
      mConversationCtrl.obtainSessionInformation(context);

      mocker.clear(ConversationDataSource.getInstance());
      mocker.clear(MmsPreferences.getInstance());
      mocker.clear(mConversationCtrl);
      mocker.clear(DraftUtils);
    })

    it('ConversationControllerTest_obtainSessionInformation_isNewMsg_true_contactsNum_1', 0, () => {
      mConversationCtrl.isNewMsg = true;
      mConversationCtrl.contactsNum = 1;

      mocker.mockFunc(ConversationDataSource.getInstance(), ConversationDataSource.getInstance().refresh);
      when(mocker.mockFunc(MmsPreferences.getInstance(), MmsPreferences.getInstance().getSendMessageSlotId))()
        .afterReturn(1);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.updateSimSlotId);

      mConversationCtrl.obtainSessionInformation(context);

      mocker.verify('updateSimSlotId', [1]).once();

      mocker.clear(ConversationDataSource.getInstance());
      mocker.clear(MmsPreferences.getInstance());
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_obtainSessionInformation_isNewMsg_false_searchMsgId_empty', 0, () => {
      mConversationCtrl.isNewMsg = false;
      mConversationCtrl.currentQueryTimeID = 1;
      mConversationCtrl.contactsNum = 1;
      mConversationCtrl.threadId = 0;
      mConversationCtrl.isDraft = false;
      mConversationCtrl.vCardJumpBack = false;
      mConversationCtrl.haveTwoCards = true;
      mConversationCtrl.queryTerminate.set(0, 1);

      when(mocker.mockFunc(ConversationService.getInstance(),
        ConversationService.getInstance().queryAllInfoSizeByCondition))(ArgumentMatchers.any)
        .afterReturn(new Promise<number>(resolve => resolve(1)));

      mocker.mockFunc(mConversationCtrl, mConversationCtrl.deleteDraftData);
      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.getHasSimCard))()
        .afterAction(() => new Promise<void>(resolve => resolve()));
      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.twoCardsJudging))()
        .afterAction(() => {
          mocker.verify('getHasSimCard', []).once();
        });

      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('mmsContext')
        .afterReturn(undefined);

      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: 0,
              abilityResult: [{
                receiverNumber: '',
                senderNumber: ''
              }] as LooseObject[]
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve());
          }
        } as Object | window.WindowStage);

      mConversationCtrl.obtainSessionInformation(context);
      mocker.clear(mConversationCtrl);
      mocker.clear(GlobalContext.getContext());
      mocker.clear(ConversationService.getInstance());
    })

    it('ConversationControllerTest_obtainSessionInformation_isNewMsg_false_searchMsgId_1', 0, () => {
      mConversationCtrl.isNewMsg = false;
      mConversationCtrl.currentQueryTimeID = 1;
      mConversationCtrl.contactsNum = 1;
      mConversationCtrl.threadId = 0;
      mConversationCtrl.isDraft = false;
      mConversationCtrl.vCardJumpBack = false;
      mConversationCtrl.haveTwoCards = false;
      mConversationCtrl.queryTerminate.set(0, 1);

      let pageInfos: NavPathStack = new NavPathStack();
      pageInfos.pushPathByName('', {
        'strContactsName': '',
        'strContactsNumber': '',
        'strContactsNumberFormat': '',
        'contactsNum': '',
        'contactsNameList': [],
        'threadId': '',
        'isDraft': '',
        'draftContent': '',
        'searchContent': '',
        'isNewMsg': '',
        'isConversationNewMsg': '',
        'photoFirstNames': '',
        'msgId': '2',
        'content': '',
        'rawContactId': '',
        'yellowPageId': '',
        'hasYellowPageIcon': '',
        'icon': '',
        'smsType': '',
        'isNewMsgWithDraft': ''
      } as LooseObject);
      mConversationCtrl.pageInfos = pageInfos;
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.photoFirstNameDeal);

      mConversationCtrl.initRouterData(context);
      mocker.clear(mConversationCtrl);

      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('mmsContext')
        .afterReturn(undefined);

      mocker.mockFunc(mConversationCtrl, mConversationCtrl.deleteDraftData);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.jumpToIndex);
      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.getHasSimCard))()
        .afterAction(() => {
          mocker.verify('jumpToIndex', []).never();
          return new Promise<void>(resolve => resolve())
        });

      when(mocker.mockFunc(ConversationService.getInstance(),
        ConversationService.getInstance().queryAllInfoSizeByCondition))(ArgumentMatchers.any)
        .afterReturn(new Promise<number>(resolve => resolve(1)));

      mConversationCtrl.obtainSessionInformation(context);
      mocker.clear(mConversationCtrl);
      mocker.clear(GlobalContext.getContext());
      mocker.clear(ConversationService.getInstance());
    })

    it('ConversationControllerTest_obtainSessionInformation_isNewMsg_false_catch', 0, () => {
      mConversationCtrl.isNewMsg = false;
      mConversationCtrl.currentQueryTimeID = 1;
      mConversationCtrl.contactsNum = 1;
      mConversationCtrl.threadId = 0;
      mConversationCtrl.isDraft = false;
      mConversationCtrl.vCardJumpBack = false;
      mConversationCtrl.haveTwoCards = false;
      mConversationCtrl.queryTerminate.set(0, 1);

      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('mmsContext')
        .afterReturn(undefined);

      when(mocker.mockFunc(ConversationService.getInstance(),
        ConversationService.getInstance().queryAllInfoSizeByCondition))(ArgumentMatchers.any)
        .afterReturn(new Promise<number>(resolve => resolve(1)));

      mocker.mockFunc(mConversationCtrl, mConversationCtrl.deleteDraftData);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.jumpToIndex);
      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.getHasSimCard))()
        .afterAction(() => {
          mocker.verify('jumpToIndex', []).never();
          return new Promise<void>((resolve: () => void, reject: (res: BusinessError) => void) => reject({
            code: -1, message: 'error'
          } as BusinessError))
        });

      mConversationCtrl.obtainSessionInformation(context);

      mocker.clear(mConversationCtrl);
      mocker.clear(GlobalContext.getContext());
      mocker.clear(ConversationService.getInstance());
    })

    it('ConversationControllerTest_resetMmsArea', 0, () => {
      mConversationCtrl.isNewMsg = false;
      mConversationCtrl.textValue = '';
      mConversationCtrl.isDraft = false;
      mConversationCtrl.mAttachAreaCtrl.mmDisplaySource = [];

      mocker.mockFunc(mConversationCtrl, mConversationCtrl.resetMmsSource);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.release);
      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.getDraftActionData))(ArgumentMatchers.any)
        .afterReturn({} as LooseObject);

      mConversationCtrl.resetMmsArea();

      mocker.verify('resetMmsSource', []).once();
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_shouldEnableSendButtonForSlot_1', 0, () => {
      mConversationCtrl.haveTwoCards = true;
      mConversationCtrl.shouldEnableSendButtonForSlot(1);
      expect(mConversationCtrl.shouldEnableSendButtonForSlot(1)).assertTrue();
      mConversationCtrl.haveTwoCards = false;
    })

    it('ConversationControllerTest_shouldEnableSendButtonForSlot_0', 0, () => {
      mConversationCtrl.shouldEnableSendButtonForSlot(0);
      expect(mConversationCtrl.shouldEnableSendButtonForSlot(0)).assertTrue();
    })

    it('ConversationControllerTest_changeIsRcsMms', 0, () => {
      mConversationCtrl.isRcsMms = false;

      mConversationCtrl.changeIsRcsMms(true, true);
      mConversationCtrl.changeIsRcsMms(true, false);

      expect(mConversationCtrl.isRcsMms).assertTrue();
    })

    it('ConversationControllerTest_updateIsAllCardActive', 0, () => {
      when(mocker.mockFunc(MmsPreferences.getInstance(), MmsPreferences.getInstance().haveSimCardReady))()
        .afterReturn(true);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.setCanSendMsgStatus);

      mConversationCtrl.isNewMsg = true;

      mConversationCtrl.updateIsAllCardActive();

      expect(mConversationCtrl.canSendMessage).assertTrue();

      mocker.clear(MmsPreferences.getInstance());
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_updateIsAllCardActive_canSendMessage_true_length_0', 0,
      () => {
        when(mocker.mockFunc(MmsPreferences.getInstance(), MmsPreferences.getInstance().haveSimCardReady))()
          .afterReturn(true);

        mConversationCtrl.isNewMsg = false;

        mConversationCtrl.updateIsAllCardActive();

        expect(mConversationCtrl.canSendMessage).assertFalse();

        mocker.clear(MmsPreferences.getInstance());
      })

    it('ConversationControllerTest_updateIsAllCardActive_canSendMessage_true_textValue_notEmpty',
      0, () => {
        when(mocker.mockFunc(MmsPreferences.getInstance(), MmsPreferences.getInstance().haveSimCardReady))()
          .afterReturn(true);

        mConversationCtrl.isNewMsg = false;
        mConversationCtrl.textValue = 'xx';

        mConversationCtrl.updateIsAllCardActive();

        expect(mConversationCtrl.canSendMessage).assertTrue();

        mocker.clear(MmsPreferences.getInstance());
      })

    it('ConversationControllerTest_updateIsAllCardActive_canSendMessage_false', 0, () => {
      when(mocker.mockFunc(MmsPreferences.getInstance(), MmsPreferences.getInstance().haveSimCardReady))()
        .afterReturn(false);

      mConversationCtrl.isNewMsg = false;
      mConversationCtrl.textValue = 'xx';

      mConversationCtrl.updateIsAllCardActive();

      expect(mConversationCtrl.canSendMessage).assertFalse();

      mocker.clear(MmsPreferences.getInstance());
    })

    it('ConversationControllerTest_updateSimSlotId', 0, () => {
      mocker.mockFunc(MmsPreferences.getInstance(), MmsPreferences.getInstance().setValueToMap);

      mConversationCtrl.updateSimSlotId(1);

      expect(mConversationCtrl.slotId).assertEqual(0);

      mocker.clear(MmsPreferences.getInstance());
    })

    it('ConversationControllerTest_initTransmit', 0, () => {
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.initTransmitMeg);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.transmitSend);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.getDraftTextData);

      mConversationCtrl.initTransmit(context);

      mocker.verify('transmitSend', [context]).once();
      mocker.clear(mConversationCtrl);

      mocker.mockFunc(mConversationCtrl, mConversationCtrl.initTransmitMeg);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.transmitSend);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.getDraftTextData);
      mConversationCtrl.draftModel = null;
      mConversationCtrl.initTransmit(context);
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_RefreshConversationData', 0, () => {
      when(mocker.mockFunc(GlobalContext.getContext(),
        GlobalContext.getContext().getObject))('conversationNeedToUpdate')
        .afterReturn({} as Object | window.WindowStage);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.queryMessageDetail);
      let res = false;
      when(mocker.mockFunc(GlobalContext.getContext(),
        GlobalContext.getContext().setObject))('conversationNeedToUpdate')
        .afterAction(() => {
          res = true;
        });

      mConversationCtrl.refreshConversationData(context);
      expect(res).assertTrue();
      mocker.clear(mConversationCtrl);
      mocker.clear(GlobalContext.getContext());
    })

    it('ConversationControllerTest_RefreshConversationData_getObject_null', 0, () => {
      let res = false;
      when(mocker.mockFunc(GlobalContext.getContext(),
        GlobalContext.getContext().getObject))('conversationNeedToUpdate')
        .afterAction(() => {
          res = true;
          return null;
        });
      mConversationCtrl.refreshConversationData(context);
      expect(res).assertTrue();
      mocker.clear(GlobalContext.getContext());
    })

    it('ConversationControllerTest_OnHide', 0, () => {
      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.unSubscribeDetail))()
        .afterAction(() => {
          mConversationCtrl.commonEventData = undefined;
        });
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.unSubscribeStaticEvent);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.unSubscribeDeliveryEvent);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.unsubscribeProcessEventSubscriber);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.unsubscribeSendOKEventSubscriber);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.unsubscribeReceiveOkEventSubscriber);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.unsubscribeReceiveCancelEventSubscriber);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.unsubscribeFailEventSubscriber);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.unsubscribeRcsSendCanceledEvent);
      mocker.mockFunc(mConversationCtrl.queryTerminate, mConversationCtrl.queryTerminate.delete);
      mocker.mockFunc(mConversationCtrl.queryTerminate, mConversationCtrl.queryTerminate.set);
      mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().setObject);

      mConversationCtrl.onHide();

      expect(mConversationCtrl.commonEventData).assertUndefined();

      mocker.clear(mConversationCtrl.queryTerminate);
      mocker.clear(mConversationCtrl);
      mocker.clear(GlobalContext.getContext());
    })

    it('ConversationControllerTest_sendOKReceiveEvent', 0, () => {
      mocker.mockFunc(HiLog, HiLog.e);

      mConversationCtrl.sendOKReceiveEvent(()=>{});

      mocker.verify('e', [TAG, 'sendOKReceiveEvent subscribe failed, data or data.data is null']).never();

      mocker.clear(HiLog);
    })

    it('ConversationControllerTest_subscribeRcsSendCanceledEvent', 0, () => {
      mocker.mockFunc(HiLog, HiLog.e);

      mConversationCtrl.subscribeRcsSendCanceledEvent();

      mocker.verify('e', [TAG, 'sendOKReceiveEvent subscribe failed, data or data.data is null']).never();

      mocker.clear(HiLog);
    })

    it('ConversationControllerTest_unSubscribeRcsSendCanceledEvent', 0, () => {
      mocker.mockFunc(HiLog, HiLog.i);
      mConversationCtrl.unsubscribeRcsSendCanceledEvent();
      (mConversationCtrl as object)['rcsSendCanceledEventSubscriber'] = null;
      mConversationCtrl.unsubscribeRcsSendCanceledEvent();
      mocker.verify('i', [TAG, 'unsubscribeRcsSendCanceledEvent success']).never();
      mocker.clear(HiLog);
    })

    it('ConversationControllerTest_GetDataParameters', 0, () => {
      let result = mConversationCtrl.getDataParameters();
      expect(JSON.stringify(result)).assertEqual(JSON.stringify({}));
    })

    it('ConversationControllerTest_GetDataParametersPhone', 0, () => {
      let result = mConversationCtrl.getDataParametersPhone();
      expect(result).assertEqual('');
    })

    it('ConversationControllerTest_unSubscribeStaticEvent', 0, () => {
      mocker.mockFunc(HiLog, HiLog.i);
      mConversationCtrl.unSubscribeStaticEvent();
      mocker.verify('i', [TAG, 'unsubscribe staticEventData, success']).never();
      mocker.clear(HiLog);
    })

    it('ConversationControllerTest_initData', 0, () => {
      mConversationCtrl.initData();
      expect(mConversationCtrl.isMessageCheckAll).assertFalse();
    })

    it('ConversationControllerTest_initAirPlaneMode', 0, () => {
      mConversationCtrl.initAirPlaneMode(context);
      expect(mConversationCtrl.isAirPlaneMode).assertFalse();
    })

    it('ConversationControllerTest_GetAirPlaneMode', 0, () => {
      mocker.mockFunc(HiLog, HiLog.i);

      mConversationCtrl.getAirPlaneMode();

      mocker.verify('i', [TAG, 'getAirPlaneMode callback']).never();

      mocker.clear(HiLog);
    })

    it('ConversationControllerTest_RemoveAirPlaneMode', 0, () => {
      mConversationCtrl.removeAirPlaneMode();
      expect(mConversationCtrl.isAirPlaneMode).assertFalse();
    })

    it('ConversationControllerTest_release', 0, () => {
      mConversationCtrl.release();

      expect(mConversationCtrl.mmsList.length).assertEqual(0);
    })

    it('ConversationControllerTest_unSubscribeDeliveryEvent_deliveryEventData_null', 0, () => {
      mConversationCtrl.unSubscribeDeliveryEvent(null, ()=>{});
      expect(mConversationCtrl.isAirPlaneMode).assertFalse();
    })

    it('ConversationControllerTest_initRouterData', 0, () => {
      let pageInfos: NavPathStack = new NavPathStack();
      pageInfos.pushPathByName('', {
        'strContactsName': 'name',
        'strContactsNumber': '570977632',
        'strContactsNumberFormat': '570977632',
        'contactsNum': '570977632',
        'contactsNameList': ['roxy'],
        'threadId': '1',
        'isDraft': 'false',
        'draftContent': 'xx',
        'searchContent': 'xx',
        'isNewMsg': 'false',
        'isConversationNewMsg': false,
        'photoFirstNames': 'ro',
        'msgId': '2',
        'content': 'xx',
        'rawContactId': 'xx',
        'yellowPageId': 'xx',
        'hasYellowPageIcon': false,
        'icon': 'xx',
        'smsType': '2',
        'isNewMsgWithDraft': false,
        'isFromInfoMsgView': false
      } as LooseObject);
      mConversationCtrl.pageInfos = pageInfos;


      mocker.mockFunc(mConversationCtrl, mConversationCtrl.photoFirstNameDeal);

      mConversationCtrl.initRouterData(context);
      expect(mConversationCtrl.isNewMsgWithDraft).assertFalse();
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_initRouterDatamsgId_empty_isFromInfoMsgView_true', 0, () => {
      let pageInfos: NavPathStack = new NavPathStack();
      pageInfos.pushPathByName('', {
        'strContactsName': 'name',
        'strContactsNumber': '570977632',
        'strContactsNumberFormat': '570977632',
        'contactsNum': '570977632',
        'contactsNameList': ['roxy'],
        'threadId': '1',
        'isDraft': 'false',
        'draftContent': 'xx',
        'searchContent': 'xx',
        'isNewMsg': 'false',
        'isConversationNewMsg': false,
        'photoFirstNames': 'ro',
        'msgId': '',
        'content': 'xx',
        'rawContactId': 'xx',
        'yellowPageId': 'xx',
        'hasYellowPageIcon': false,
        'icon': 'xx',
        'smsType': '2',
        'isNewMsgWithDraft': false,
        'isFromInfoMsgView': true
      } as LooseObject);
      mConversationCtrl.pageInfos = pageInfos;


      mocker.mockFunc(mConversationCtrl, mConversationCtrl.photoFirstNameDeal);

      mConversationCtrl.initRouterData(context);
      expect(mConversationCtrl.isNewMsgWithDraft).assertFalse();
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_formatDisplayPhoneNum', 0, () => {
      mConversationCtrl.strContactsName = '15380881598';
      mConversationCtrl.formatStrContactsNumberFormat = '15380881598';
      mConversationCtrl.strContactsNumberFormat = '15380881598';
      when(mocker.mockFunc(TelephoneUtil, TelephoneUtil.countryCodeFormatPhone))(ArgumentMatchers.any)
        .afterReturn('15380881598');
      mConversationCtrl.formatDisplayPhoneNum();
      expect(mConversationCtrl.contactsNameIsNotEqualToContactsNumberFormat).assertFalse();
      mocker.clear(TelephoneUtil);
    })

    it('ConversationControllerTest_formatDisplayPhoneNum_contactsNum_3', 0, () => {
      mConversationCtrl.contactsNum = 3;
      mConversationCtrl.strContactsNumber = "8888,9999";
      mConversationCtrl.strContactsName = ',9999,name3';
      mConversationCtrl.rawContactId = '1,2';
      mConversationCtrl.strContactsNumberFormat = ',xxxx,xxxx';

      when(mocker.mockFunc(TelephoneUtil, TelephoneUtil.countryCodeFormatPhone))(ArgumentMatchers.any)
        .afterReturn('');

      mConversationCtrl.formatDisplayPhoneNum();
      expect(mConversationCtrl.contactsNameIsNotEqualToContactsNumberFormat).assertFalse();
      mocker.clear(TelephoneUtil);
    })

    it('ConversationControllerTest_receiveOkEventSubscribeCallback_mmsSource_empty', 0, () => {
      let err: BusinessError = {} as BusinessError;
      let data: commonEvent.CommonEventData = {
        data: '102'
      } as commonEvent.CommonEventData;
      let mmsList = [
        {
          id: '101',
          isRcs: 1,
          threadId: 2,
          isCbChecked: true,
          is_collect: false,
          isIpMsg: false,
          isSimpleIpMsg: false
        } as mmsListType,
        {
          id: '102',
          isRcs: 1,
          rcsType: 2,
          threadId: 2,
          isCbChecked: true,
          mmsSource: [],
          is_collect: true,
          isIpMsg: true,
          isSimpleIpMsg: false
        } as mmsListType];
      mConversationCtrl.mmsList = mmsList;
      mConversationCtrl.receiveOkEventSubscribeCallback(undefined, data);
      expect(mConversationCtrl).not().assertUndefined();
    })

    it('ConversationControllerTest_receiveOkEventSubscribeCallback_VIDEO', 0, () => {
      let err: BusinessError = {} as BusinessError;
      let data: commonEvent.CommonEventData = {
        data: '102'
      } as commonEvent.CommonEventData;
      let mmsList = [
        {
          id: '101',
          isRcs: 1,
          threadId: 2,
          isCbChecked: true,
          is_collect: false,
          isIpMsg: false,
          isSimpleIpMsg: false
        } as mmsListType,
        {
          id: '102',
          isRcs: 1,
          rcsType: 2,
          threadId: 2,
          isCbChecked: true,
          mmsSource: [{
            type: 1,
            path: 'src',
            name: ''
          } as Mms,{
            type: 2,
            path: 'src',
            name: ''
          } as Mms,{
            type: 12,
            path: 'src',
            name: ''
          } as Mms],
          is_collect: true,
          isIpMsg: true,
          isSimpleIpMsg: false
        } as mmsListType];
      mConversationCtrl.mmsList = mmsList;
      mConversationCtrl.receiveOkEventSubscribeCallback(undefined, data);
      expect(mConversationCtrl).not().assertUndefined();
    })

    it('ConversationControllerTest_receiveOkEventSubscribeCallback_err', 0, () => {
      let err: BusinessError = {} as BusinessError;
      let data: commonEvent.CommonEventData = {
        data: '102'
      } as commonEvent.CommonEventData;
      let mmsList = [
        {
          id: '101',
          isRcs: 1,
          threadId: 2,
          isCbChecked: true,
          is_collect: false,
          isIpMsg: false,
          isSimpleIpMsg: false
        } as mmsListType,
        {
          id: '102',
          isRcs: 1,
          rcsType: 1,
          threadId: 2,
          isCbChecked: true,
          mmsSource: [{
            type: 1,
            path: 'src',
            name: ''
          } as Mms,{
            type: 2,
            path: 'src',
            name: ''
          } as Mms,{
            type: 12,
            path: 'src',
            name: ''
          } as Mms],
          is_collect: true,
          isIpMsg: true,
          isSimpleIpMsg: false
        } as mmsListType];
      mConversationCtrl.mmsList = mmsList;
      mConversationCtrl.receiveOkEventSubscribeCallback(err, data);
      mConversationCtrl.receiveOkEventSubscribeCallback(undefined, undefined);
      mConversationCtrl.receiveOkEventSubscribeCallback(undefined, data);
      expect(mConversationCtrl).not().assertUndefined();
    })

    it('ConversationControllerTest_receiveOkReceiveEvent', 0, () => {
      mocker.mockFunc(HiLog, HiLog.i);

      mConversationCtrl.receiveOkReceiveEvent();

      mocker.verify('i', [TAG, 'receiveOkReceiveEvent subscribe failed, data or data.data is null']).never();

      mocker.clear(HiLog);
    })

    it('ConversationControllerTest_receiveCancelReceiveEvent', 0, () => {
      mocker.mockFunc(HiLog, HiLog.i);

      mConversationCtrl.receiveCancelReceiveEvent();

      mocker.verify('i', [TAG, 'receiveOkReceiveEvent subscribe failed, data or data.data is null']).never();

      mocker.clear(HiLog);
    })

    it('ConversationControllerTest_processReceiveEvent', 0, () => {
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.processReceiveEventPartNext);

      mConversationCtrl.processReceiveEvent();

      mocker.verify('processReceiveEventPartNext', []).never();
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_updateMmsListItemStatusOfRcs_mmsListItem_undefined', 0, () => {
      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.findMmsListItemByMsgIdOfRcs))('')
        .afterReturn(undefined);

      mConversationCtrl.updateMmsListItemStatusOfRcs('', 1);

      expect(mConversationCtrl.findMmsListItemByMsgIdOfRcs('')).assertUndefined();
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_updateMmsListItemStatusOfRcs', 0, () => {
      let mmsListItem: mmsListType | undefined = new mmsListType();

      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.findMmsListItemByMsgIdOfRcs))('')
        .afterReturn(mmsListItem);

      mocker.mockFunc(mConversationCtrl, mConversationCtrl.resetItem);

      mConversationCtrl.updateMmsListItemStatusOfRcs('', 1);

      mmsListItem.sendStatus = 1;

      mocker.verify('resetItem', [mmsListItem]).once();
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_findMmsListItemByMsgIdOfRcs_mmsListLength_0', 0, () => {
      mConversationCtrl.mmsList = [];
      mConversationCtrl.findMmsListItemByMsgIdOfRcs('');
      expect(mConversationCtrl).not().assertUndefined();
    })

    it('ConversationControllerTest_findMmsListItemByMsgIdOfRcs_mmsListLength_1', 0, () => {
      let mmsListType: mmsListType = {
        id: '123'
      } as mmsListType;

      mConversationCtrl.mmsList = [mmsListType];

      let result: mmsListType | undefined = mConversationCtrl.findMmsListItemByMsgIdOfRcs('123');

      expect(JSON.stringify(result)).assertEqual(JSON.stringify(mmsListType));
    })

    it('ConversationControllerTest_findMmsListItemByMsgIdOfRcs', 0, () => {
      let mmsListType: mmsListType = {
        id: '123',
        isReceive: true
      } as mmsListType;

      mConversationCtrl.mmsList = [mmsListType,{
        id: '123',
        isReceive: false
      } as mmsListType];

      mConversationCtrl.findMmsListItemByMsgIdOfRcs('123', true);
      mConversationCtrl.findMmsListItemByMsgIdOfRcs('123', false);

      expect(mConversationCtrl).not().assertUndefined();
    })

    it('ConversationControllerTest_findMmsListItemByMsgIdOfRcs_index_minus1', 0, () => {
      let mmsListType: mmsListType = {
        id: 1
      } as mmsListType;

      mConversationCtrl.mmsList = [mmsListType];

      expect(mConversationCtrl.findMmsListItemByMsgIdOfRcs('')).assertUndefined();
    })

    it('ConversationControllerTest_findMmsListItemByRcsIdOfRcs_rcsId_undefined', 0, () => {
      expect(mConversationCtrl.findMmsListItemByRcsIdOfRcs(undefined)).assertUndefined();
    })

    it('ConversationControllerTest_findMmsListItemByRcsIdOfRcs_mmsListLength_0', 0, () => {
      mConversationCtrl.findMmsListItemByRcsIdOfRcs(1);
      expect(mConversationCtrl.mmsList.length).assertEqual(1);
    })

    it('ConversationControllerTest_findMmsListItemByRcsIdOfRcs_mmsListLength_1', 0, () => {
      let mmsListType: mmsListType = {
        rcsId: 1
      } as mmsListType;

      mConversationCtrl.mmsList = [mmsListType];

      let result: mmsListType | undefined = mConversationCtrl.findMmsListItemByRcsIdOfRcs(1);

      expect(JSON.stringify(result)).assertEqual(JSON.stringify(mmsListType));
    })

    it('ConversationControllerTest_findMmsListItemByRcsIdOfRcs_index_minus1', 0, () => {
      let mmsListType: mmsListType = {
        rcsId: 0
      } as mmsListType;

      mConversationCtrl.mmsList = [mmsListType];

      expect(mConversationCtrl.findMmsListItemByRcsIdOfRcs(1)).assertUndefined();
    })

    it('ConversationControllerTest_findMmsListItemByRcsIdOfRcs_mmsList_Length_0', 0, () => {
      mConversationCtrl.mmsList = [];
      expect(mConversationCtrl.findMmsListItemByRcsIdOfRcs(1)).assertUndefined();
    })

    it('ConversationControllerTest_checkMmsListCbSelectedItem', 0, () => {
      let mmsListType: mmsListType = {
        isCbChecked: true
      } as mmsListType;
      let mmsListType2: mmsListType = {
        isCbChecked: true
      } as mmsListType;

      let mmsList: mmsListType[] = [mmsListType, mmsListType2];

      expect(mConversationCtrl.checkMmsListCbSelectedItem(mmsList)).assertUndefined();
    })

    it('ConversationControllerTest_checkMmsListCbSelectedItem_isMsm_false', 0, () => {
      let mmsListType: mmsListType = {
        isCbChecked: true,
        isMsm: false
      } as mmsListType;

      let mmsList: mmsListType[] = [mmsListType];

      expect(mConversationCtrl.checkMmsListCbSelectedItem(mmsList)).assertUndefined();
    })

    it('ConversationControllerTest_checkMmsListCbSelectedItem_isMsm_true', 0, () => {
      let mmsListType: mmsListType = {
        isCbChecked: true,
        isMsm: true
      } as mmsListType;

      let mmsList: mmsListType[] = [mmsListType];

      expect(JSON.stringify(mConversationCtrl.checkMmsListCbSelectedItem(mmsList)))
        .assertEqual(JSON.stringify(mmsListType));
    })

    it('ConversationControllerTest_resetSelectData_isSendOk_true_sendStatus_8', 0, () => {
      let item: mmsListType = {
        id: '1',
        isCbChecked: true,
        isMsm: true,
        sendStatus: 0
      } as mmsListType;

      let rcsItem: mmsListType = {
        id: '1',
        isCbChecked: true,
        isMsm: true,
        sendStatus: 0
      } as mmsListType;

      mConversationCtrl.updateUIStateRcs(item, '1', true, rcsItem, 8);

      expect(rcsItem.sendStatus).assertEqual(0);
    })

    it('ConversationControllerTest_resetSelectData_isSendOk_true_sendStatus_9', 0, () => {
      let item: mmsListType = {
        id: '1',
        isCbChecked: true,
        isMsm: true,
        sendStatus: 0
      } as mmsListType;

      let rcsItem: mmsListType = {
        id: '1',
        isCbChecked: true,
        isMsm: true,
        sendStatus: 0
      } as mmsListType;

      mConversationCtrl.updateUIStateRcs(item, '1', true, rcsItem, 9);

      expect(rcsItem.sendStatus).assertEqual(0);
    })

    it('ConversationControllerTest_resetSelectData_isSendOk_true_sendStatus_14', 0, () => {
      let item: mmsListType = {
        id: '1',
        isCbChecked: true,
        isMsm: true,
        sendStatus: 0
      } as mmsListType;

      let rcsItem: mmsListType = {
        id: '1',
        isCbChecked: true,
        isMsm: true,
        sendStatus: 0
      } as mmsListType;

      mConversationCtrl.updateUIStateRcs(item, '1', true, rcsItem, 14);

      expect(rcsItem.sendStatus).assertEqual(0);
    })

    it('ConversationControllerTest_resetSelectData_isSendOk_true_sendStatus_0', 0, () => {
      let item: mmsListType = {
        id: '1',
        isCbChecked: true,
        isMsm: true,
        sendStatus: 0
      } as mmsListType;

      let rcsItem: mmsListType = {
        id: '1',
        isCbChecked: true,
        isMsm: true,
        sendStatus: 0
      } as mmsListType;

      mConversationCtrl.updateUIStateRcs(item, '1', true, rcsItem, 0);

      expect(rcsItem.sendStatus).assertEqual(0);
    })

    it('ConversationControllerTest_resetSelectData_isSendOk_false_sendStatus_0', 0, () => {
      let item: mmsListType = {
        id: '1',
        isCbChecked: true,
        isMsm: true,
        sendStatus: 0
      } as mmsListType;

      let rcsItem: mmsListType = {
        id: '1',
        isCbChecked: true,
        isMsm: true,
        sendStatus: 0
      } as mmsListType;

      mConversationCtrl.updateUIStateRcs(item, '1', false, rcsItem, 0);

      expect(rcsItem.sendStatus).assertEqual(0);
    })

    it('ConversationControllerTest_resetSelectData_msgId_2', 0, () => {
      let item: mmsListType = {
        id: '1',
        isCbChecked: true,
        isMsm: true,
        sendStatus: 0
      } as mmsListType;

      let rcsItem: mmsListType = {
        id: '1',
        isCbChecked: true,
        isMsm: true,
        sendStatus: 0
      } as mmsListType;

      mConversationCtrl.updateUIStateRcs(item, '2', true, rcsItem, 8);

      expect(rcsItem.sendStatus).assertEqual(0);
    })

    it('ConversationControllerTest_photoFirstNameDeal_strContactsName_hasComma', 0, () => {
      mConversationCtrl.photoFirstNameDeal('roxy,', [{
        portraitColor: '', firstName: 'zhang'
      }], (photoFirstName: string, portraitColor: string | Resource) => {
        expect(photoFirstName).assertEqual('-2');
      });
    })

    it('ConversationControllerTest_photoFirstNameDeal_allChinese', 0, () => {
      mConversationCtrl.photoFirstNameDeal('荣生', [{
        portraitColor: '', firstName: 'zhang'
      }], (photoFirstName: string, portraitColor: string | Resource) => {
        expect(photoFirstName).assertEqual('生');
      });
    })

    it('ConversationControllerTest_photoFirstNameDeal_hasChinese', 0, () => {
      mConversationCtrl.photoFirstNameDeal('荣生rongsheng', [{
        portraitColor: '', firstName: 'zhang'
      }], (photoFirstName: string, portraitColor: string | Resource) => {
        expect(photoFirstName).assertEqual('生');
      });
    })

    it('ConversationControllerTest_photoFirstNameDeal_hasEnglish', 0, () => {
      mConversationCtrl.photoFirstNameDeal('rongsheng', [{
        portraitColor: '', firstName: 'zhang'
      }], (photoFirstName: string, portraitColor: string | Resource) => {
        expect(photoFirstName).assertEqual('R');
      });
    })

    it('ConversationControllerTest_photoFirstNameDeal_other', 0, () => {
      mConversationCtrl.photoFirstNameDeal('*', [{
        portraitColor: 'xxx', firstName: 'zhang'
      }], (photoFirstName: string, portraitColor: string | Resource) => {
        expect(portraitColor).assertEqual('xxx');
      });
    })

    it('ConversationControllerTest_photoFirstNameDeal_strContactsName_empty', 0, () => {
      mConversationCtrl.photoFirstNameDeal('', [{
        portraitColor: 'xxx', firstName: 'zhang'
      }], (photoFirstName: string, portraitColor: string | Resource) => {
        expect(portraitColor).assertEqual('xxx');
      });
    })

    it('ConversationControllerTest_photoFirstNameDeal_strContactsName_portraitColor_empty', 0, () => {
      mConversationCtrl.photoFirstNameDeal('', [{
        portraitColor: '', firstName: 'zhang'
      }], (photoFirstName: string, portraitColor: string | Resource) => {
        expect(photoFirstName).assertEqual(' ');
      });
    })

    it('ConversationControllerTest_dealSpecialPhoneNumber', 0, () => {
      mConversationCtrl.strContactsNumber = "*111"
      mConversationCtrl.strContactsNumberFormat = "111";
      mConversationCtrl.strContactsName = "*111";
      when(mocker.mockFunc(TelephoneUtil, TelephoneUtil.isPhoneNumber))(mConversationCtrl.strContactsNumber)
        .afterReturn(false);
      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.replaceCode))(ArgumentMatchers.any)
        .afterReturn('111');
      mConversationCtrl.dealSpecialPhoneNumber();
      expect("").assertEqual(mConversationCtrl.strContactsName);
      mocker.clear(TelephoneUtil);
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_dealSpecialPhoneNumber_strContactsName_empty', 0, () => {
      mConversationCtrl.strContactsNumber = "111"
      mConversationCtrl.strContactsNumberFormat = "111";
      mConversationCtrl.strContactsName = "";
      when(mocker.mockFunc(TelephoneUtil, TelephoneUtil.isPhoneNumber))(mConversationCtrl.strContactsNumber)
        .afterReturn(false);
      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.replaceCode))(ArgumentMatchers.any)
        .afterReturn('111');
      mConversationCtrl.dealSpecialPhoneNumber();

      expect("").assertEqual(mConversationCtrl.strContactsName);
      mocker.clear(TelephoneUtil);
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_dealSpecialPhoneNumber_noIf', 0, () => {
      mConversationCtrl.strContactsNumber = "111"
      mConversationCtrl.strContactsNumberFormat = "111";
      mConversationCtrl.strContactsName = "";

      when(mocker.mockFunc(TelephoneUtil, TelephoneUtil.isPhoneNumber))(mConversationCtrl.strContactsNumber)
        .afterReturn(true);
      mConversationCtrl.dealSpecialPhoneNumber();

      expect("").assertEqual(mConversationCtrl.strContactsName);
      mocker.clear(TelephoneUtil);
    })

    it('ConversationControllerTest_ReplaceCode', 0, () => {
      mConversationCtrl.replaceCode("");

      expect(mConversationCtrl).not().assertUndefined();

      mConversationCtrl.replaceCode("22222");

      expect(mConversationCtrl).not().assertUndefined();
    })

    it('ConversationControllerTest_titleBarCancel', 0, () => {
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.cancelCheckedAll);
      mocker.mockFunc(ConversationDataSource.getInstance(), ConversationDataSource.getInstance().refresh);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.resetSelectData);
      mConversationCtrl.mmsList = [];
      let mms: mmsListType = new mmsListType();
      mms.isCbChecked = true;
      mConversationCtrl.mmsList.push(mms);
      mConversationCtrl.titleBarCancel();
      expect(mConversationCtrl.mmsList[0].isCbChecked).assertTrue();
      mocker.clear(ConversationDataSource.getInstance());
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_OnBackPress_isSelectStatus_true', 0, () => {
      mConversationCtrl.isSelectStatus = true;
      mConversationCtrl.isBackToIndex = true;
      when(mocker.mockFunc(GlobalContext.getContext(),GlobalContext.getContext().getObject))('mmsContext')
        .afterReturn({
          moveAbilityToBackground:(): Promise<void> => new Promise<void>(resolve => resolve())
        } as Object | window.WindowStage)

      mocker.mockFunc(mConversationCtrl, mConversationCtrl.removeEmitter);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.resetSelectData);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.resetMmsCount);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.cancelCheckedAll);
      mocker.mockFunc(ConversationDataSource.getInstance(), ConversationDataSource.getInstance().refresh);

      let res: boolean = mConversationCtrl.onBackPress(context, false, false);
      expect(res).assertTrue();

      mocker.clear(ConversationDataSource.getInstance());
      mocker.clear(GlobalContext.getContext());
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_OnBackPress_isSelectStatus_false_isBackHomePage_false', 0, () => {
      mConversationCtrl.isSelectStatus = false;
      mConversationCtrl.isBackToIndex = true;
      AppStorage.setOrCreate('isBackHomePage', false);
      when(mocker.mockFunc(GlobalContext.getContext(),GlobalContext.getContext().getObject))('mmsContext')
        .afterReturn({
          moveAbilityToBackground:(): Promise<void> => new Promise<void>(resolve => resolve())
        } as Object | window.WindowStage)

      mocker.mockFunc(mConversationCtrl, mConversationCtrl.removeEmitter);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.resetSelectData);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.resetMmsCount);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.cancelCheckedAll);
      mocker.mockFunc(ConversationDataSource.getInstance(), ConversationDataSource.getInstance().refresh);

      let res: boolean = mConversationCtrl.onBackPress(context, true, false);
      expect(res).assertFalse();

      mocker.clear(ConversationDataSource.getInstance());
      mocker.clear(GlobalContext.getContext());
      mocker.clear(mConversationCtrl);
      AppStorage.clear();
    })

    it('ConversationControllerTest_OnBackPress_isSelectStatus_true_yOffset_0', 0, () => {
      mConversationCtrl.isSelectStatus = true;
      mConversationCtrl.isBackToIndex = true;
      mConversationCtrl.yOffset = 0;
      when(mocker.mockFunc(GlobalContext.getContext(),GlobalContext.getContext().getObject))('mmsContext')
        .afterReturn({
          moveAbilityToBackground:(): Promise<void> => new Promise<void>(resolve => resolve())
        } as Object | window.WindowStage)

      mocker.mockFunc(mConversationCtrl, mConversationCtrl.removeEmitter);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.resetSelectData);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.resetMmsCount);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.cancelCheckedAll);
      mocker.mockFunc(ConversationDataSource.getInstance(), ConversationDataSource.getInstance().refresh);

      let res: boolean = mConversationCtrl.onBackPress(context, false, false);
      expect(res).assertTrue();

      mocker.clear(ConversationDataSource.getInstance());
      mocker.clear(GlobalContext.getContext());
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_OnBackPress_isSelectStatus_false_isBackHomePage_true', 0, () => {
      mConversationCtrl.isSelectStatus = false;
      mConversationCtrl.isBackToIndex = true;
      AppStorage.setOrCreate('isBackHomePage', true);
      AppStorage.setOrCreate('isFromNotificationUseByBackPressOnly', false);
      when(mocker.mockFunc(GlobalContext.getContext(),GlobalContext.getContext().getObject))('mmsContext')
        .afterReturn({
          moveAbilityToBackground:(): Promise<void> => new Promise<void>(resolve => resolve())
        } as Object | window.WindowStage)

      mocker.mockFunc(mConversationCtrl, mConversationCtrl.removeEmitter);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.resetSelectData);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.resetMmsCount);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.cancelCheckedAll);
      mocker.mockFunc(ConversationDataSource.getInstance(), ConversationDataSource.getInstance().refresh);

      let res: boolean = mConversationCtrl.onBackPress(context, false, false);
      expect(res).assertTrue();

      mocker.clear(ConversationDataSource.getInstance());
      mocker.clear(GlobalContext.getContext());
      mocker.clear(mConversationCtrl);
      AppStorage.clear();
    })

    it('ConversationControllerTest_OnBackPress_isFromNotificationUseByBackPressOnly_true', 0, () => {
      mConversationCtrl.isSelectStatus = false;
      mConversationCtrl.isBackToIndex = true;
      AppStorage.setOrCreate('isBackHomePage', true);
      AppStorage.setOrCreate('isFromNotificationUseByBackPressOnly', true);
      when(mocker.mockFunc(GlobalContext.getContext(),GlobalContext.getContext().getObject))('mmsContext')
        .afterReturn({
          moveAbilityToBackground:(): Promise<void> => new Promise<void>(resolve => resolve())
        } as Object | window.WindowStage)

      mocker.mockFunc(mConversationCtrl, mConversationCtrl.removeEmitter);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.resetSelectData);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.resetMmsCount);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.cancelCheckedAll);
      mocker.mockFunc(ConversationDataSource.getInstance(), ConversationDataSource.getInstance().refresh);

      let res: boolean = mConversationCtrl.onBackPress(context, false, false);
      expect(res).assertFalse();

      mocker.clear(ConversationDataSource.getInstance());
      mocker.clear(GlobalContext.getContext());
      mocker.clear(mConversationCtrl);
      AppStorage.clear();
    })

    it('ConversationControllerTest_OnBackPress_isSelectStatus_false_isBackToIndex_true', 0, () => {
      mConversationCtrl.isSelectStatus = false;
      mConversationCtrl.isBackToIndex = true;
      mConversationCtrl.isNewMsg = false;
      mConversationCtrl.isDraft = false;
      mConversationCtrl.textValue = '';
      mConversationCtrl.pageInfos = new NavPathStack();
      AppStorage.setOrCreate('curBp', 'md');
      mConversationCtrl.pictureCtrl.pictureList = [{
        image: '',
        selected: false,
        photoType: 0,
        mediaUri: '',
        pixelMap: {
          release: (callback: AsyncCallback<void, void>): void => {
          }
        } as PixelMap,
        index: 0
      } as PictureListData];
      when(mocker.mockFunc(GlobalContext.getContext(),GlobalContext.getContext().getObject))('mmsContext')
        .afterReturn({
          moveAbilityToBackground:(): Promise<void> => new Promise<void>(resolve => resolve())
        } as Object | window.WindowStage)
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.removeEmitter);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.resetMmsSource);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.release);
      mocker.mockFunc(ConversationListController.getInstance(), ConversationListController.getInstance().onShow);
      mocker.mockFunc(mConversationCtrl.pictureCtrl.pictureDataSource,
        mConversationCtrl.pictureCtrl.pictureDataSource.refresh);
      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.getDraftActionData))(ArgumentMatchers.any)
        .afterReturn({mmsSource: []});

      let res: boolean = mConversationCtrl.onBackPress(context, false, false);

      expect(res).assertFalse();
      mocker.clear(ConversationListController.getInstance());
      mocker.clear(mConversationCtrl.pictureCtrl.pictureDataSource);
      mocker.clear(mConversationCtrl);
      mocker.clear(GlobalContext.getContext());
      AppStorage.clear();
    })

    it('ConversationControllerTest_OnBackPress_isSelectStatus_false_isBackToIndex_false_pageInfos', 0, () => {
      mConversationCtrl.isSelectStatus = false;
      mConversationCtrl.isBackToIndex = false;
      mConversationCtrl.isNewMsg = false;
      mConversationCtrl.isDraft = false;
      mConversationCtrl.pageInfos = new NavPathStack();
      mConversationCtrl.textValue = '';
      mConversationCtrl.pageInfos.pushPathByName('InfoMsg', [{} as LooseObject]);
      AppStorage.setOrCreate('curBp', 'sm');
      mConversationCtrl.pictureCtrl.pictureList = [{
        image: '',
        selected: false,
        photoType: 0,
        mediaUri: '',
        pixelMap: {
          release: (callback: AsyncCallback<void, void>): void => {
          }
        } as PixelMap,
        index: 0
      } as PictureListData];
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.removeEmitter);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.resetMmsSource);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.release);
      mocker.mockFunc(mConversationCtrl.pictureCtrl.pictureDataSource,
        mConversationCtrl.pictureCtrl.pictureDataSource.refresh);
      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.getDraftActionData))(ArgumentMatchers.any)
        .afterReturn({mmsSource:[]});
      when(mocker.mockFunc(DraftUtils.getInstance(), DraftUtils.getInstance().saveDraft))(ArgumentMatchers.any)
        .afterReturnNothing;
      let res: boolean = mConversationCtrl.onBackPress(context, false, false);
      expect(res).assertTrue();

      mocker.clear(mConversationCtrl.pictureCtrl.pictureDataSource);
      mocker.clear(DraftUtils.getInstance());
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_OnBackPress_isSelectStatus_false_isBackToIndex_false_pageInfos_null', 0, () => {
      mConversationCtrl.isSelectStatus = false;
      mConversationCtrl.isBackToIndex = false;
      mConversationCtrl.isNewMsg = false;
      mConversationCtrl.isDraft = false;
      mConversationCtrl.pageInfos = undefined;
      mConversationCtrl.textValue = '';
      AppStorage.setOrCreate('curBp', 'sm');
      mConversationCtrl.pictureCtrl.pictureList = [{
        image: '',
        selected: false,
        photoType: 0,
        mediaUri: '',
        pixelMap: {
          release: (callback: AsyncCallback<void, void>): void => {
          }
        } as PixelMap,
        index: 0
      } as PictureListData];
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.removeEmitter);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.resetMmsSource);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.release);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.saveDraft);
      mocker.mockFunc(mConversationCtrl.pictureCtrl.pictureDataSource,
        mConversationCtrl.pictureCtrl.pictureDataSource.refresh);
      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.getDraftActionData))(ArgumentMatchers.any)
        .afterReturn({mmsSource:[]});
      when(mocker.mockFunc(DraftUtils.getInstance(), DraftUtils.getInstance().saveDraft))(ArgumentMatchers.any)
        .afterReturnNothing;
      let res: boolean = mConversationCtrl.onBackPress(context, false, false);
      expect(res).assertFalse();
      mConversationCtrl.pageInfos = new NavPathStack();

      mocker.clear(mConversationCtrl.pictureCtrl.pictureDataSource);
      mocker.clear(DraftUtils.getInstance());
      mocker.clear(mConversationCtrl);
      AppStorage.clear();
    })

    it('ConversationControllerTest_OnBackPress_isSelectStatus_false_isBackToIndex_false_pageInfos_empty', 0, () => {
      mConversationCtrl.isSelectStatus = false;
      mConversationCtrl.isBackToIndex = false;
      mConversationCtrl.isNewMsg = false;
      mConversationCtrl.isDraft = false;
      mConversationCtrl.textValue = '';
      mConversationCtrl.pageInfos = new NavPathStack();
      AppStorage.setOrCreate('curBp', 'md');
      mConversationCtrl.pictureCtrl.pictureList = [{
        image: '',
        selected: false,
        photoType: 0,
        mediaUri: '',
        pixelMap: {
          release: (callback: AsyncCallback<void, void>): void => {
          }
        } as PixelMap,
        index: 0
      } as PictureListData];

      mocker.mockFunc(mConversationCtrl, mConversationCtrl.removeEmitter);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.resetMmsSource);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.release);
      mocker.mockFunc(mConversationCtrl.pictureCtrl.pictureDataSource,
        mConversationCtrl.pictureCtrl.pictureDataSource.refresh);
      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.getDraftActionData))(ArgumentMatchers.any)
        .afterReturn({});
      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.saveDraft))(ArgumentMatchers.any).afterReturnNothing;

      let res: boolean = mConversationCtrl.onBackPress(context, false, false);

      expect(res).assertFalse();

      mocker.clear(mConversationCtrl.pictureCtrl.pictureDataSource);
    })

    it('ConversationControllerTest_resetSelectData', 0, () => {
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.setSelectStatus);
      mConversationCtrl.resetSelectData();
      expect(mConversationCtrl.selectDeleteMsgCount).assertEqual(0);
      mocker.clear(mConversationCtrl);
      mocker.clear(mConversationCtrl.pictureCtrl.pictureDataSource);
    })

    it('ConversationControllerTest_insertAndUpdateSessionDraft_isNewMsg_true_isDraft_true', 0, () => {
      mConversationCtrl.isNewMsg = true;
      mConversationCtrl.isDraft = true;
      mConversationCtrl.textValue = '';

      let source: Mms[] = [];
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.deleteDraftData);
      mocker.mockFunc(ConversationListService.getInstance(),
        ConversationListService.getInstance().deleteSessionByCondition);
      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.getDraftActionData))(source)
        .afterReturn({
          isNewMsg: false,
          telephone: '7777'
        } as LooseObject);

      mocker.clear(ConversationListService.getInstance());
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_insertAndUpdateSessionDraft_isNewMsg_true_isDraft_true_textValue_notEmpty', 0,
      () => {
        mConversationCtrl.isNewMsg = true;
        mConversationCtrl.isDraft = true;
        mConversationCtrl.textValue = 'xxx';
        mConversationCtrl.selectContacts = [];

        let source: Mms[] = [];
        mocker.mockFunc(mConversationCtrl, mConversationCtrl.deleteDraftData);
        mocker.mockFunc(ConversationListService.getInstance(),
          ConversationListService.getInstance().deleteSessionByCondition);
        when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.getDraftActionData))(source)
          .afterReturn({
            isNewMsg: false,
            telephone: '7777'
          } as LooseObject);
        mocker.clear(ConversationListService.getInstance());
        mocker.clear(mConversationCtrl);
      })

    it('ConversationControllerTest_insertAndUpdateSessionDraft_isNewMsg_true_isDraft_true_selectContacts_notEmpty', 0,
      () => {
        mConversationCtrl.isNewMsg = true;
        mConversationCtrl.isDraft = true;
        mConversationCtrl.textValue = '';
        mConversationCtrl.selectContacts = [{
          telephone: '',
          telephoneFormat: '',
          contactName: '',
          rawContactId: '1'
        } as selectContactType];

        let source: Mms[] = [];
        mocker.mockFunc(mConversationCtrl, mConversationCtrl.deleteDraftData);
        mocker.mockFunc(ConversationListService.getInstance(),
          ConversationListService.getInstance().deleteSessionByCondition);
        when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.getDraftActionData))(source)
          .afterReturn({
            isNewMsg: false,
            telephone: '7777'
          } as LooseObject);
        mocker.clear(ConversationListService.getInstance());
        mocker.clear(mConversationCtrl);
      })

    it('ConversationControllerTest_insertAndUpdateSessionDraft_isNewMsg_true_isDraft_true_textValue_selectContacts_notEmpty',
      0,
      () => {
        mConversationCtrl.isNewMsg = true;
        mConversationCtrl.isDraft = true;
        mConversationCtrl.textValue = 'xxx';
        mConversationCtrl.selectContacts = [{
          telephone: '',
          telephoneFormat: '',
          contactName: '',
          rawContactId: '1'
        } as selectContactType];

        let source: Mms[] = [];
        mocker.mockFunc(mConversationCtrl, mConversationCtrl.deleteDraftData);
        mocker.mockFunc(ConversationListService.getInstance(),
          ConversationListService.getInstance().deleteSessionByCondition);
        when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.getDraftActionData))(source)
          .afterReturn({
            isNewMsg: false,
            telephone: '7777'
          } as LooseObject);
        mocker.clear(ConversationListService.getInstance());
        mocker.clear(mConversationCtrl);
      })

    it('ConversationControllerTest_insertAndUpdateSessionDraft_isNewMsg_false_isDraft_true_textValue_selectContacts_notEmpty',
      0,
      () => {
        mConversationCtrl.isNewMsg = false;
        mConversationCtrl.isDraft = true;
        mConversationCtrl.textValue = 'xxx';
        mConversationCtrl.selectContacts = [{
          telephone: '',
          telephoneFormat: '',
          contactName: '',
          rawContactId: '1'
        } as selectContactType];

        let source: Mms[] = [];
        mocker.mockFunc(ConversationListService.getInstance(),
          ConversationListService.getInstance().insertSessionDraft);
        when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.getDraftActionData))(source)
          .afterReturn({
            isNewMsg: false,
            telephone: '7777'
          } as LooseObject);
        mocker.verify('getDraftActionData', [source]).never();

        mocker.clear(ConversationListService.getInstance());
        mocker.clear(mConversationCtrl);
      })

    it('ConversationControllerTest_insertAndUpdateSessionDraft_isNewMsg_false_isDraft_true_textValue_selectContacts_empty',
      0,
      () => {
        mConversationCtrl.isNewMsg = false;
        mConversationCtrl.isDraft = true;
        mConversationCtrl.textValue = '';
        mConversationCtrl.selectContacts = [];

        let source: Mms[] = [];
        when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.getDraftActionData))(source)
          .afterReturn({
            isNewMsg: false,
            telephone: '7777'
          } as LooseObject);
        mocker.clear(mConversationCtrl);
      })

    it('ConversationControllerTest_insertAndUpdateSessionDraft_isNewMsg_true_isDraft_false_textValue_selectContacts_empty',
      0,
      () => {
        mConversationCtrl.isNewMsg = true;
        mConversationCtrl.isDraft = false;
        mConversationCtrl.textValue = '';
        mConversationCtrl.selectContacts = [];

        let source: Mms[] = [];
        mocker.mockFunc(DotUtil.getInstance(), DotUtil.getInstance().reportFaultEvent);
        when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.getDraftActionData))(source)
          .afterReturn({
            isNewMsg: false,
            telephone: '7777'
          } as LooseObject);
        mocker.clear(DotUtil.getInstance());
        mocker.clear(mConversationCtrl);
      })

    it('ConversationControllerTest_insertAndUpdateSessionDraft_isNewMsg_false_isDraft_false_textValue_selectContacts_empty',
      0,
      () => {
        mConversationCtrl.isNewMsg = false;
        mConversationCtrl.isDraft = false;
        mConversationCtrl.textValue = '';
        mConversationCtrl.selectContacts = [];

        let source: Mms[] = [];
        when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.getDraftActionData))(source)
          .afterReturn({
            isNewMsg: false,
            telephone: '7777'
          } as LooseObject);
        mocker.clear(mConversationCtrl);
      })

    it('ConversationControllerTest_getDraftActionData', 0, () => {
      when(mocker.mockFunc(settingService, settingService.judgeIsDeliveryReport))(ArgumentMatchers.any).afterReturn(false);
      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.getDraftActionData))([]).afterReturn({})
      expect(JSON.stringify(mConversationCtrl.getDraftActionData([]))).assertEqual(undefined)
      mocker.clear(settingService);
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_getDraftActionData_source_length_1', 0, () => {
      let source = {
        type: 0
      } as Mms;
      when(mocker.mockFunc(settingService, settingService.judgeIsDeliveryReport))(ArgumentMatchers.any).afterReturn(false);
      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.getDraftActionData))(source).afterReturn({})
      expect(JSON.stringify(mConversationCtrl.getDraftActionData([source]))).assertEqual(undefined)
      mocker.clear(settingService);
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_getDraftActionData_source_length_1_isEditMms_true', 0, () => {
      mConversationCtrl.isEditMms = true;
      mConversationCtrl.isDraft=false;
      let source = {
        type: 0
      } as Mms;
      when(mocker.mockFunc(settingService, settingService.judgeIsDeliveryReport))(ArgumentMatchers.any).afterReturn(false);
      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.getDraftActionData))([]).afterReturn({})
      expect(JSON.stringify(mConversationCtrl.getDraftActionData([source]))).assertEqual(undefined)
      mocker.clear(settingService);
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_deleteDraftWithNewMessage_selectContacts', 0, () => {
      mConversationCtrl.selectContacts = [{
        telephone: '570988765',
        telephoneFormat: '570988765',
        contactName: '570988765',
        rawContactId: '1'
      }];
      mConversationCtrl.threadId = 100001;
      mConversationCtrl.selectContactsMap.set(100001, mConversationCtrl.selectContacts);

      let actionData: LooseObject = {
        'selectContacts': [],
        'receiveContactValue': ''
      };
      let callback = () => {
      };

      mocker.mockFunc(ConversationListService.getInstance(), ConversationListService.getInstance().insertSessionDraft);

      mocker.verify('insertSessionDraft', [actionData, callback, undefined]).never();

      mocker.clear(ConversationListService.getInstance());
    })

    it('ConversationControllerTest_deleteDraftWithNewMessage_receiveContactValue_isPhoneNumber_true', 0, () => {
      mConversationCtrl.threadId = 100001;
      mConversationCtrl.selectContactsMap.set(100001, []);
      mConversationCtrl.receiveContactValue = 'xx';
      mConversationCtrl.isDraft = true;
      let actionData: LooseObject = {
        'selectContacts': [],
        'receiveContactValue': ''
      };
      let callback = () => {
      };

      mocker.mockFunc(ConversationListService.getInstance(),
        ConversationListService.getInstance().insertSessionDraft);
      when(mocker.mockFunc(TelephoneUtil, TelephoneUtil.isPhoneNumber))(ArgumentMatchers.any)
        .afterReturn(true);

      mocker.verify('deleteDraftData', []).never();

      mocker.clear(ConversationListService.getInstance());
      mocker.clear(TelephoneUtil);
    })

    it('ConversationControllerTest_deleteDraftWithNewMessage_receiveContactValue_isDraft_true', 0, () => {
      mConversationCtrl.threadId = 100001;
      mConversationCtrl.selectContactsMap.set(100001,[]);
      mConversationCtrl.receiveContactValue = 'xx';
      mConversationCtrl.isDraft = true;
      let actionData: LooseObject = {
        'selectContacts': [],
        'receiveContactValue': ''
      };
      let callback = () => {
      };
      mocker.mockFunc(ConversationListService.getInstance(),
        ConversationListService.getInstance().insertSessionDraft);
      mocker.mockFunc(ConversationListService.getInstance(),
        ConversationListService.getInstance().deleteSessionByCondition);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.deleteDraftData);
      when(mocker.mockFunc(TelephoneUtil, TelephoneUtil.isPhoneNumber))(ArgumentMatchers.any)
        .afterReturn(false);

      mocker.verify('deleteDraftData', []).never();

      mocker.clear(ConversationListService.getInstance());
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_deleteDraftWithNewMessage_receiveContactValue_isDraft_false', 0, () => {
      mConversationCtrl.threadId = 100001;
      mConversationCtrl.selectContactsMap.set(100001, []);
      mConversationCtrl.receiveContactValue = 'xx';
      mConversationCtrl.isDraft = false;
      let actionData: LooseObject = {
        'selectContacts': [],
        'receiveContactValue': ''
      };
      let callback = () => {
      };

      when(mocker.mockFunc(TelephoneUtil, TelephoneUtil.isPhoneNumber))(ArgumentMatchers.any)
        .afterReturn(false);
      expect(actionData.receiveContactValue).assertEqual('');
      mocker.clear(TelephoneUtil);
    })

    it('ConversationControllerTest_deleteDraftWithNewMessage_receiveContactValue_empty', 0, () => {
      mConversationCtrl.threadId = 100001;
      mConversationCtrl.selectContactsMap.set(100001, []);
      mConversationCtrl.receiveContactValue = '';
      mConversationCtrl.isDraft = false;
      let actionData: LooseObject = {
        'selectContacts': [],
        'receiveContactValue': ''
      };
      let callback = () => {
      };

      mocker.mockFunc(ConversationService.getInstance(), ConversationService.getInstance().insertNoReceiverDraft);

      mocker.verify('insertNoReceiverDraft', [actionData]).never();
      mocker.clear(ConversationService.getInstance());
    })

    it('ConversationControllerTest_DealSessionDraft', 0, () => {
      mocker.mockFunc(ConversationListService.getInstance(),
        ConversationListService.getInstance().updateSessionByCondition);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.deleteDraftData);

      expect(false).assertEqual(mConversationCtrl.isDraft);

      mocker.clear(mConversationCtrl);
      mocker.clear(ConversationListService.getInstance());
    })

    it('ConversationControllerTest_DealSessionDraft_mmsList_length_1_isMsm_true', 0, () => {
      mConversationCtrl.mmsList = [{
        content: '1',
        timeMillisecond: 0,
        isMsm: true
      } as mmsListType];
      mocker.mockFunc(ConversationListService.getInstance(),
        ConversationListService.getInstance().updateSessionByCondition);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.deleteDraftData);

      expect(false).assertEqual(mConversationCtrl.isDraft);

      mocker.clear(ConversationListService.getInstance());
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_DealSessionDraft_mmsList_length_1_isMsm_false', 0, () => {
      mConversationCtrl.mmsList = [{
        content: '1',
        timeMillisecond: 0,
        isMsm: false
      } as mmsListType];
      mocker.mockFunc(ConversationListService.getInstance(),
        ConversationListService.getInstance().updateSessionByCondition);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.deleteDraftData);

      expect(false).assertEqual(mConversationCtrl.isDraft);

      mocker.clear(ConversationListService.getInstance());
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_CancelCheckedAll', 0, () => {
      let mms: mmsListType = new mmsListType();
      mms.content = "111";
      mms.isCbChecked = true;
      mConversationCtrl.mmsList = [];
      mConversationCtrl.mmsList.push(mms);
      mConversationCtrl.cancelCheckedAll();

      expect(mConversationCtrl.mmsList[0].isCbChecked).assertFalse();
    })

    it('ConversationControllerTest_ClickGroupCheckAll_isMessageCheckAll_false', 0, () => {
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.setMessageCheckAll);

      let mms: mmsListType = new mmsListType();
      mms.content = "1111";
      mms.isCbChecked = true;
      mConversationCtrl.isMessageCheckAll = false;
      mConversationCtrl.mmsList.push(mms);

      mConversationCtrl.clickGroupCheckAll();

      mocker.verify('setMessageCheckAll', [1]).once();
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_ClickGroupCheckAll_isMessageCheckAll_true', 0, () => {
      mocker.mockFunc(ConversationDataSource.getInstance(),
        ConversationDataSource.getInstance().refresh);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.setMessageCheckAll);

      let mms: mmsListType = new mmsListType();
      mms.content = "1111";
      mms.isCbChecked = true;
      mConversationCtrl.isMessageCheckAll = true;
      mConversationCtrl.mmsList.push(mms);

      mConversationCtrl.clickGroupCheckAll();

      mocker.verify('setMessageCheckAll', [2]).once();

      mocker.clear(ConversationDataSource.getInstance());
      mocker.clear(mConversationCtrl);
    })


    it('ConversationControllerTest_mmsFavorite', 0, () => {
      mocker.mockFunc(ConversationService.getInstance(),
        ConversationService.getInstance().updateSmsMmsInfoByCondition);

      let mmsList = [{
        id: '',
        isRcs: 0,
        threadId: 2,
        isCbChecked: true
      } as mmsListType,
        {
          id: '',
          isRcs: 1,
          threadId: 2,
          isCbChecked: false
        } as mmsListType,
        {
          id: '',
          isRcs: 1,
          threadId: 2,
          isCbChecked: true
        } as mmsListType];
      mConversationCtrl.mmsList = mmsList;

      mocker.mockFunc(ConversationService.getInstance(), ConversationService.getInstance().updateSmsMmsInfoByCondition);
      when(mocker.mockFunc(DataShareHelper.getInstance(),
        DataShareHelper.getInstance().initSmsDB))(ArgumentMatchers.any)
        .afterReturn(new Promise<dataShare.DataShareHelper | undefined>(resolve => resolve(undefined)));

      mConversationCtrl.mmsFavorite(context);

      let valueBucket: ValuesBucket = {
        'is_collect': common.is_collect.FAVORITE,
      }
      let actionData: LooseObject = {
        'msgId': '',
      };

      mocker.verify('updateSmsMmsInfoByCondition', [actionData, valueBucket, null, null]).never();
      mocker.clear(ConversationService.getInstance());
      mocker.clear(DataShareHelper.getInstance());
    })

    it('ConversationControllerTest_saveMmsDetect_isRcs_0', 0, () => {
      let res = false;
      when(mocker.mockFunc(ConversationService.getInstance(),
        ConversationService.getInstance().updateSmsMmsInfoByCondition))(ArgumentMatchers.any)
        .afterAction(() => {
          res = true;
        });

      mConversationCtrl.saveMmsDetect(context, 0, '', 0);

      expect(res).assertTrue();
    })


    it('ConversationControllerTest_SetMessageCheckAll_isSelectStatus_false', 0, () => {
      let type: number = 1;
      mConversationCtrl.isSelectStatus = false;

      mConversationCtrl.setMessageCheckAll(type);

      expect(mConversationCtrl.hasReport).assertFalse();
    })

    it('ConversationControllerTest_SetMessageCheckAll_type_1', 0, () => {
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.judgeOnlyAudio);
      let type: number = 1;
      mConversationCtrl.isSelectStatus = true;
      let mms: mmsListType = new mmsListType();
      mms.content = "111";
      mms.isCbChecked = true;
      mConversationCtrl.mmsList = [];
      mConversationCtrl.mmsList.push(mms);

      mConversationCtrl.setMessageCheckAll(type);

      expect(mConversationCtrl.hasReport).assertFalse();
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_SetMessageCheckAll_type_2', 0, () => {
      let type: number = 2;
      mConversationCtrl.isSelectStatus = true;
      let mms1: mmsListType = new mmsListType();
      mms1.content = "111";
      mms1.isCbChecked = true;
      mConversationCtrl.mmsList = [];
      mConversationCtrl.mmsList.push(mms1);

      mConversationCtrl.setMessageCheckAll(type);

      expect(mConversationCtrl.hasReport).assertFalse();
    })

    it('ConversationControllerTest_SetMessageCheckAll_type_3', 0, () => {
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.checkBoxSelectUnknow);

      let type: number = 3;
      mConversationCtrl.isSelectStatus = true;
      let mms1: mmsListType = new mmsListType();
      mms1.content = "111";
      mms1.isCbChecked = true;
      mConversationCtrl.mmsList = [];
      mConversationCtrl.mmsList.push(mms1);

      mConversationCtrl.setMessageCheckAll(type);

      mocker.verify('checkBoxSelectUnknow', []).once();
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_CheckBoxSelectUnknow_true', 0, () => {
      mConversationCtrl.selectDeleteMsgCount = 1;
      let mms: mmsListType = new mmsListType();
      mms.content = "111";
      mms.isCbChecked = true;
      mms.hasReport = true;
      mConversationCtrl.mmsList = [];
      mConversationCtrl.mmsList.push(mms);
      mConversationCtrl.checkBoxSelectUnknow();

      expect(mConversationCtrl.hasReport).assertTrue();
    })

    it('ConversationControllerTest_CheckBoxSelectUnknow_false', 0, () => {
      let mms1: mmsListType = new mmsListType();
      mms1.content = "111";
      mms1.isCbChecked = false;
      mms1.hasReport = false;
      mConversationCtrl.mmsList = [];
      mConversationCtrl.mmsList.push(mms1);
      mConversationCtrl.checkBoxSelectUnknow();

      expect(mConversationCtrl.hasReport).assertFalse();;
    })

    it('ConversationControllerTest_listCheckBoxChange', 0, () => {
      let mms: mmsListType = new mmsListType();
      mms.content = "111";
      mms.isCbChecked = true;
      mms.hasReport = true;
      mConversationCtrl.mmsList = [];
      mConversationCtrl.mmsList.push(mms);

      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.checkMmsListCbSelectedItem))(mConversationCtrl.mmsList)
        .afterReturn(mms);

      mocker.mockFunc(mConversationCtrl, mConversationCtrl.setMessageCheckAll);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.setGroupMoreMenu);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.judgeOnlyAudio);
      mocker.mockFunc(ConversationDataSource.getInstance(), ConversationDataSource.getInstance().refresh);

      mConversationCtrl.listCheckBoxChange(0, true);

      expect(0).assertEqual(mConversationCtrl.mmsIndex);

      mocker.clear(ConversationDataSource.getInstance());
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_listCheckBoxChange_e_true', 0, () => {
      let mms: mmsListType = new mmsListType();
      mms.content = "111";
      mms.isCbChecked = true;
      mms.hasReport = true;
      mConversationCtrl.mmsList = [];
      mConversationCtrl.mmsList.push(mms);

      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.checkMmsListCbSelectedItem))(mConversationCtrl.mmsList)
        .afterReturn(mms);

      mocker.mockFunc(mConversationCtrl, mConversationCtrl.setMessageCheckAll);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.setGroupMoreMenu);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.judgeOnlyAudio);
      mocker.mockFunc(ConversationDataSource.getInstance(), ConversationDataSource.getInstance().refresh);

      mConversationCtrl.listCheckBoxChange(0, false);

      expect(0).assertEqual(mConversationCtrl.mmsIndex);

      mocker.clear(ConversationDataSource.getInstance());
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_listCheckBoxChange_selectDeleteMsgCount_1', 0, () => {
      let mms: mmsListType = new mmsListType();
      mms.content = "111";
      mms.isCbChecked = true;
      mms.hasReport = true;
      let mms1: mmsListType = new mmsListType();
      mms1.content = "111";
      mms1.isCbChecked = false;
      mms1.hasReport = false;

      mConversationCtrl.mmsList = [mms, mms1];

      mConversationCtrl.selectDeleteMsgCount = 1;

      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.checkMmsListCbSelectedItem))(mConversationCtrl.mmsList)
        .afterReturn(mms);

      mocker.mockFunc(mConversationCtrl, mConversationCtrl.setMessageCheckAll);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.setGroupMoreMenu);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.judgeOnlyAudio);
      mocker.mockFunc(ConversationDataSource.getInstance(), ConversationDataSource.getInstance().refresh);

      mConversationCtrl.listCheckBoxChange(0, true);

      expect(0).assertEqual(mConversationCtrl.mmsIndex);

      mocker.clear(ConversationDataSource.getInstance());
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_multiSelectMmsMsg_isCbChecked_true_isMsm_true', 0, () => {
      let mms: mmsListType = new mmsListType();
      mms.content = "111";
      mms.isCbChecked = true;
      mms.hasReport = true;
      mms.isMsm = true;
      mConversationCtrl.mmsList = [];
      mConversationCtrl.mmsList.push(mms);

      mConversationCtrl.multiSelectMmsMsg(0);

      expect(-1).assertEqual(mConversationCtrl.mmsCount);
    })

    it('ConversationControllerTest_multiSelectMmsMsg_isCbChecked_false', 0, () => {
      let mms: mmsListType = new mmsListType();
      mms.content = "111";
      mms.isCbChecked = false;
      mms.hasReport = true;
      mms.isMsm = true;
      mConversationCtrl.mmsList = [];
      mConversationCtrl.mmsList.push(mms);
      mConversationCtrl.mmsCount=0;

      mConversationCtrl.multiSelectMmsMsg(0);

      expect(1).assertEqual(mConversationCtrl.mmsCount);
    })

    it('ConversationControllerTest_resetMmsCount', 0, () => {
      mConversationCtrl.resetMmsCount();
      expect(mConversationCtrl.mmsCount).assertEqual(0);
    })

    it('ConversationControllerTest_judgeOnlyAudio', 0, () => {
      let mmsList: mmsListType = new mmsListType();
      mmsList.content = "111";
      mmsList.isCbChecked = true;
      mmsList.hasReport = true;
      mConversationCtrl.mmsList = [];
      mConversationCtrl.mmsList.push(mmsList);
      mConversationCtrl.judgeOnlyAudio()
      expect(mConversationCtrl.audioStatus).assertEqual(-1)
    })

    it('ConversationControllerTest_judgeOnlyAudio1', 0, () => {
      let mmsList: mmsListType = new mmsListType();
      mmsList.content = "111";
      mmsList.isCbChecked = true;
      mmsList.hasReport = true;
      mmsList.mmsSource = [{
        duration: '',
        type: common.MM_ATTACHMENT_TYPE.IMAGE,
        path: 'data/file/123.png',
        name: '123'
      }];
      mConversationCtrl.mmsList = [];
      mConversationCtrl.mmsList.push(mmsList);
      mConversationCtrl.judgeOnlyAudio()
      expect(mConversationCtrl.audioStatus).assertEqual(-1)
    })

    it('ConversationControllerTest_judgeOnlyAudio2', 0, () => {
      let mmsList: mmsListType = new mmsListType();
      mmsList.content = "";
      mmsList.isCbChecked = true;
      mmsList.hasReport = true;
      mmsList.mmsSource = [{
        duration: '',
        type: common.MM_ATTACHMENT_TYPE.AUDIO,
        path: 'data/file/123.png',
        name: '123'
      }];
      mConversationCtrl.mmsList = [];
      mConversationCtrl.mmsList.push(mmsList);
      mConversationCtrl.judgeOnlyAudio()
      expect(mConversationCtrl.audioStatus).assertEqual(1)
    })

    it('ConversationControllerTest_judgeOnlyAudio3', 0, () => {
      let mmsList: mmsListType = new mmsListType();
      mmsList.content = "111";
      mmsList.isCbChecked = true;
      mmsList.hasReport = true;
      mmsList.mmsSource = [];
      mConversationCtrl.mmsList = [];
      mConversationCtrl.mmsList.push(mmsList);
      let mmsList1: mmsListType = new mmsListType();
      mmsList1.content = "111";
      mmsList1.isCbChecked = true;
      mmsList1.hasReport = true;
      mmsList1.mmsSource = [{
        duration: '',
        type: common.MM_ATTACHMENT_TYPE.AUDIO,
        path: 'data/file/123.png',
        name: '123'
      }];
      mConversationCtrl.mmsList.push(mmsList1);
      mConversationCtrl.judgeOnlyAudio()
      expect(mConversationCtrl.audioStatus).assertEqual(0)
    })

    it('ConversationControllerTest_setGroupMoreMenu_isMsm_true', 0, () => {
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.judgeOnlyAudio);
      let mmsList: mmsListType = new mmsListType();
      mmsList.content = "111";
      mmsList.isCbChecked = true;
      mmsList.isMsm = true;
      mConversationCtrl.setGroupMoreMenu(mmsList);
      mocker.verify('judgeOnlyAudio',[]).once();
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_setGroupMoreMenu_isMsm_false', 0, () => {
      let mmsList: mmsListType = new mmsListType();
      mmsList.content = "111";
      mmsList.isCbChecked = true;
      mmsList.isMsm = false;
      mConversationCtrl.setGroupMoreMenu(mmsList);
      expect(mConversationCtrl.hasContent).assertTrue();
    })

    it('ConversationControllerTest_LongPressSelected_case0', 0, () => {
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.copyText);

      mConversationCtrl.mmsIndex = 0
      let mmsList = new mmsListType();
      mmsList.content = "111";
      mConversationCtrl.mmsList.push(mmsList);
      mConversationCtrl.longPressSelected(context, 0);

      mocker.verify('copyText', []).once();
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_LongPressSelected_case1', 0, () => {
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.transmitMsg);

      let index: number = 1;
      mConversationCtrl.mmsIndex = 0;

      mConversationCtrl.longPressSelected(context, index);

      mocker.verify('transmitMsg', [context, 1]).never();
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_LongPressSelected_case2', 0, () => {
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.deleteDialogShow);

      let index: number = 2;
      mConversationCtrl.mmsIndex = 0;
      let mms = new mmsListType();
      mms.isCbChecked = false;
      mms.content = "111";
      mConversationCtrl.mmsList.push(mms);

      mConversationCtrl.longPressSelected(context, index);

      mocker.verify('deleteDialogShow', []).once();
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_LongPressSelected_case3', 0, () => {
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.gotoTextSelect);

      let index: number = 3;
      mConversationCtrl.mmsIndex = 0;

      mConversationCtrl.longPressSelected(context, index);

      mocker.verify('gotoTextSelect', [0]).once();
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_LongPressSelected_case4', 0, () => {
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.more);

      let index: number = 4;
      mConversationCtrl.mmsIndex = 0;

      mConversationCtrl.longPressSelected(context, index);

      mocker.verify('more', []).once();
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_LongPressSelected_case5', 0, () => {
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.saveImage);

      let index: number = 5;
      mConversationCtrl.mmsIndex = 0;

      mConversationCtrl.longPressSelected(context, index);

      mocker.verify('saveImage', [context]).once();
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_LongPressSelected_case6', 0, () => {
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.reportDialogShow);

      let index: number = 6;
      mConversationCtrl.mmsIndex = 0;

      mConversationCtrl.longPressSelected(context, index);

      mocker.verify('reportDialogShow', []).once();
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_LongPressSelected_default', 0, () => {
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.reportDialogShow);

      let index: number = 7;
      mConversationCtrl.mmsIndex = 0;

      mConversationCtrl.longPressSelected(context, index);

      mocker.verify('reportDialogShow', []).never();
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_InitTransmitMeg_pageInfos_isFromTransmitView_true', 0, () => {
      mConversationCtrl.isBackToIndex = false;
      mocker.mockFunc(MmsPreferences.getInstance(), MmsPreferences.getInstance().getSendMessageSlotId);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.initNewPageContacts);

      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))("transmitFlag")
        .afterReturn({} as Object | window.WindowStage);
      mConversationCtrl.strContactsNumber = "";
      mConversationCtrl.pageInfos = new NavPathStack();
      mConversationCtrl.pageInfos.pushPathByName('Conversation', {
        threadId: 1,
        strContactsName: '',
        strContactsNumber: '',
        strContactsNumberFormat: '',
        rawContactId: '',
        isFromTransmitView: true,
        contactsNum: 0,
        isDraft: false,
        draftContent: '',
        searchContent: ''
      } as LooseObject);
      mConversationCtrl.initTransmitMeg();
      expect(mConversationCtrl.isBackToIndex).assertTrue();
      mocker.clear(MmsPreferences.getInstance());
      mocker.clear(GlobalContext.getContext());
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_InitTransmitMeg_pageInfos_isFromTransmitView_false', 0, () => {
      mConversationCtrl.isBackToIndex = false;
      mocker.mockFunc(MmsPreferences.getInstance(), MmsPreferences.getInstance().getSendMessageSlotId);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.initNewPageContacts);

      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))("transmitFlag")
        .afterReturn({} as Object | window.WindowStage);
      mConversationCtrl.strContactsNumber = "";
      mConversationCtrl.pageInfos = new NavPathStack();
      mConversationCtrl.pageInfos.pushPathByName('Conversation', {
        threadId: 1,
        strContactsName: '',
        strContactsNumber: '',
        strContactsNumberFormat: '',
        rawContactId: '',
        isFromTransmitView: false,
        contactsNum: 0,
        isDraft: false,
        draftContent: '',
        searchContent: ''
      } as LooseObject);
      mConversationCtrl.initTransmitMeg();
      expect(mConversationCtrl.isBackToIndex).assertFalse();
      mocker.clear(MmsPreferences.getInstance());
      mocker.clear(GlobalContext.getContext());
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_ResetData', 0, () => {
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.release);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.resetSelectData);
      mConversationCtrl.resetData();
      expect(false).assertEqual(mConversationCtrl.isMessageCheckAll);
      mocker.clear(mConversationCtrl);
    })
  })
}