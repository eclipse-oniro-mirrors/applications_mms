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
import { GlobalContext } from '../../../../../main/ets/MainAbility/GlobalHelper';
import TelephoneUtil from '../../../../../main/ets/utils/TelephoneUtil';
import ConversationController, {
  ActionData,
  mmsEditListTempType,
  mmsListType,
  mmsSourceItem,
  TransmitInfoType,
  TransmitSourceType,
} from '../../../../../main/ets/pages/conversation/conversationController';
import DataShareHelper from '../../../../../main/ets/model/repository/DataShareHelper';
import { dataShare, dataSharePredicates, DataShareResultSet, ValuesBucket } from '@kit.ArkData';
import ConversationDataSource from '../../../../../main/ets/model/ConversationDataSource';
import MySet from '../../MySet';
import { window } from '@kit.ArkUI';
import rcs from '@ohos.telephony.rcs';
import { AddressInfo, Mms } from '../../../../../main/ets/utils/TypesUtils';
import ConversationService from '../../../../../main/ets/service/ConversationService';
import MessageUtil from '../../../../../main/cust/utils/MessageUtil';
import ConversationListService from '../../../../../main/ets/service/ConversationListService';
import settingService from '../../../../../main/ets/service/SettingService';
import commonData from '../../../../../main/ets/data/commonData';
import FileUtil from '../../../../../main/ets/utils/FileUtil';
import myCommon from '@ohos.app.ability.common';
import dateUtil, { DateUtil } from '../../../../../main/ets/utils/DateUtil';
import MmsUtil from '../../../../../main/ets/utils/MmsUtil';
import { systemShare } from '@kit.ShareKit';
import { resourceManager } from '@kit.LocalizationKit';
import LooseObject from '../../../../../main/ets/data/LooseObject';
import ConversationListController from '../../../../../main/ets/pages/conversationlist/conversationListController';
import { DTGlobalContext } from '../../../testability/TestAbility';
import { shareMessage,
  shareMmsMessage } from '../../../../../main/ets/pages/conversation/ConversationComponentAndTools';
import HiLog from '../../../../../main/ets/utils/HiLog';
import { commonEventManager } from '@kit.BasicServicesKit';

export default function conversationControllerPart2Test() {
  describe('conversationControllerTest2', () => {

    let mConversationCtrl: ConversationController;
    let mocker: MockKit;
    const TAG = 'ConversationController';
    let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;

    beforeEach(() => {
      mocker = new MockKit();
      mConversationCtrl = ConversationController.getInstance();
    })

    afterEach(() => {
      mocker.clear(mConversationCtrl);
      mocker.clear(TelephoneUtil);
      mocker.clear(ConversationListService.getInstance());
      mocker.clear(ConversationService.getInstance());
      mocker.clear(ConversationService);
      mocker.clear(MessageUtil);
      mocker.clear(dateUtil);
      mocker.clear(MmsUtil);
      mocker.clear(settingService);
      mocker.clear(ConversationDataSource.getInstance());
      mocker.clear(GlobalContext.getContext());
      mocker.clear(ConversationListController.getInstance());
      mocker.clear(DataShareHelper.getInstance());
      AppStorage.clear();
    })

    it('ConversationControllerTest_changeVCardJumpBack', 0, () => {
      mConversationCtrl.changeVCardJumpBack();
      expect(mConversationCtrl.vCardJumpBack).assertTrue();
    })

    it('ConversationControllerTest_getIsNew', 0, () => {
      expect(mConversationCtrl.getIsNew()).assertFalse();
    })

    it('ConversationControllerTest_isCall', 0, () => {
      expect(mConversationCtrl.isCall()).assertFalse();
    })

    it('ConversationControllerTest_subscribeStaticEvent', 0, () => {
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.createStaticSubscriberCallBack);
      mConversationCtrl.subscribeStaticEvent(context);
      expect(mConversationCtrl.mmsList.length).assertEqual(4);
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_initAirPlaneMode', 0, () => {
      mConversationCtrl.initAirPlaneMode(context);
      expect(mConversationCtrl.isAirPlaneMode).assertFalse();
    })

    it('ConversationControllerTest_processReceiveEventPartNext_isExistInfoInRcsInfoWithMsgId_false', 0, async () => {
      let res = false;
      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.resetItem))(ArgumentMatchers.any)
        .afterAction(() => {
          res = true;
        });

      mConversationCtrl.processReceiveEventPartNext(false, '', '', 0, 0);

      expect(res).assertFalse();
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_processReceiveEventPartNext_isExistInfoInRcsInfoWithMsgId_true_receive_mmsList_empty',
      0, () => {
        let res = false;
        when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.resetItem))(ArgumentMatchers.any)
          .afterAction(() => {
            res = true;
          });
        mConversationCtrl.mmsList = [];

        mConversationCtrl.processReceiveEventPartNext(true, '', 'receive', 0, 0);

        expect(res).assertFalse();
        mocker.clear(mConversationCtrl);
      })

    it('ConversationControllerTest_processReceiveEventPartNext_isExistInfoInRcsInfoWithMsgId_true_receive_num_2', 0,
      () => {
        let res = false;
        when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.resetItem))(ArgumentMatchers.any)
          .afterAction(() => {
            res = true;
          });
        mConversationCtrl.mmsList = [{
          id: '1',
          isReceive: true
        } as mmsListType, {
          id: '2',
          isReceive: true
        } as mmsListType, {
          id: '1',
          isReceive: true
        } as mmsListType];

        mConversationCtrl.processReceiveEventPartNext(true, '1', 'receive', 0, 0);

        expect(res).assertTrue();
        mocker.clear(mConversationCtrl);
      })

    it('ConversationControllerTest_processReceiveEventPartNext_isExistInfoInRcsInfoWithMsgId_true_receive_num_0', 0,
      () => {
        let res = false;
        when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.resetItem))(ArgumentMatchers.any)
          .afterAction(() => {
            res = true;
          });
        mConversationCtrl.mmsList = [{
          id: '3',
          isReceive: true
        } as mmsListType, {
          id: '2',
          isReceive: true
        } as mmsListType, {
          id: '4',
          isReceive: true
        } as mmsListType];

        mConversationCtrl.processReceiveEventPartNext(true, '1', 'receive1', 0, 0);

        expect(res).assertFalse();
        mocker.clear(mConversationCtrl);
      })

    it('ConversationControllerTest_unsubscribeProcessEventSubscriber_processEventSubscriber_null', 0, () => {
      mConversationCtrl.unsubscribeProcessEventSubscriber();
      expect(mConversationCtrl).not().assertUndefined();
      let processEventSubscriber: commonEventManager.CommonEventSubscriber | null = (mConversationCtrl as object)['processEventSubscriber'];
      (mConversationCtrl as object)['processEventSubscriber'] = null;
      mConversationCtrl.unsubscribeProcessEventSubscriber();
      (mConversationCtrl as object)['processEventSubscriber'] = processEventSubscriber;
    })

    it('ConversationControllerTest_unsubscribeSendOKEventSubscriber_sendOKEventSubscriber_null', 0, () => {
      let mocker:MockKit = new MockKit();
      mocker.mockFunc(HiLog,HiLog.e);
      mConversationCtrl.unsubscribeSendOKEventSubscriber(null, ()=>{});
      mocker.verify('e',[TAG, 'unsubscribeSendOKEventSubscriber: sendOKEventSubscriber empty']).never();
      (mConversationCtrl as object)['failEventData'] = false;
      mConversationCtrl.unsubscribeSendOKEventSubscriber(null, ()=>{});
      (mConversationCtrl as object)['failEventData'] = true;
      mocker.clear(HiLog);
    })

    it('ConversationControllerTest_unsubscribeReceiveOkEventSubscriber_receiveOkEventSubscriber_null', 0, () => {
      mConversationCtrl.unsubscribeReceiveOkEventSubscriber();
      expect(mConversationCtrl).not().assertUndefined();
      let receiveOkEventSubscriber: commonEventManager.CommonEventSubscriber | null = (mConversationCtrl as object)['receiveOkEventSubscriber'];
      (mConversationCtrl as object)['receiveOkEventSubscriber'] = null;
      mConversationCtrl.unsubscribeReceiveOkEventSubscriber();
      (mConversationCtrl as object)['receiveOkEventSubscriber'] = receiveOkEventSubscriber;
    })

    it('ConversationControllerTest_unsubscribeReceiveCancelEventSubscriber_receiveCancelEventSubscriber_null', 0, () => {
        mConversationCtrl.unsubscribeReceiveCancelEventSubscriber();
        expect(JSON.stringify(mConversationCtrl.failEventData)).not().assertUndefined();
      let receiveCancelEventSubscriber: commonEventManager.CommonEventSubscriber | null = (mConversationCtrl as object)['receiveCancelEventSubscriber'];
      (mConversationCtrl as object)['receiveCancelEventSubscriber'] = null;
      mConversationCtrl.unsubscribeReceiveCancelEventSubscriber();
      (mConversationCtrl as object)['receiveCancelEventSubscriber'] = receiveCancelEventSubscriber;
      })

    it('ConversationControllerTest_unsubscribeFailEventSubscriber_failEventData_null', 0, () => {
      mConversationCtrl.unsubscribeFailEventSubscriber();
      expect(mConversationCtrl).not().assertUndefined();
      mConversationCtrl.failEventData = {} as commonEventManager.CommonEventSubscriber;
      mConversationCtrl.unsubscribeFailEventSubscriber();
      mConversationCtrl.failEventData = null;
    })



    it('ConversationControllerTest_networkStatusChangedOn', 0, () => {
      mConversationCtrl.networkStatusChangedOn((message: rcs.RcsEvent) => {
      });
      expect(mConversationCtrl.mmsList.length).assertEqual(1);
    })

    it('ConversationControllerTest_networkStateChange', 0, () => {
      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.networkStatusChangedOn))(ArgumentMatchers.any)
        .afterThrow('error');
      mConversationCtrl.networkStateChange();
      expect(mConversationCtrl.mmsList.length).assertEqual(1);
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_networkStateChange2', 0, () => {
      mConversationCtrl.networkStateChange();
      expect(mConversationCtrl.mmsList.length).assertEqual(1);
    })

    it('ConversationControllerTest_transmitSend_mmsStatus_1', 0, () => {
      let params: TransmitSourceType = {
        threadId: 0,
        strContactsName: '',
        strContactsNumber: '',
        strContactsNumberFormat: '',
        transmitSource: [{
          isRcs: 0,
          content: '',
          contactsName: '',
          isMsm: false,
          msgShowType: 0,
          msgUriPath: '',
          contentInfo: '',
          contentType: 0,
          info: '',
          mms: [{
            duration: '',
            type: commonData.MM_ATTACHMENT_TYPE.AUDIO,
            path: 'data/file/123.png',
            name: '123'
          }]
        } as TransmitInfoType,{
          isRcs: 1,
          content: '',
          contactsName: '',
          isMsm: false,
          msgShowType: 0,
          msgUriPath: '',
          contentInfo: '',
          contentType: 0,
          info: '',
          mms: [{
            duration: '',
            type: commonData.ENHANCED_INFO_ITEM_TYPE.CHATBOT_CARD,
            path: 'data/file/123.png',
            name: '123'
          }]
        } as TransmitInfoType,{
          isRcs: 1,
          content: '',
          contactsName: '',
          isMsm: false,
          msgShowType: 0,
          msgUriPath: '',
          contentInfo: '',
          contentType: 0,
          info: '',
          mms: [{
            duration: '',
            type: commonData.ENHANCED_INFO_ITEM_TYPE.MAP,
            path: 'data/file/123.png',
            name: '123'
          }]
        } as TransmitInfoType,{
          isRcs: 1,
          content: '',
          contactsName: '',
          isMsm: false,
          msgShowType: 0,
          msgUriPath: '',
          contentInfo: '',
          contentType: 0,
          info: '',
          mms: [{
            duration: '',
            type: commonData.ENHANCED_INFO_ITEM_TYPE.FILE,
            path: 'data/file/123.png',
            name: '123'
          }]
        } as TransmitInfoType],
        isContainerOriginSource: false,
        transmitContent: '',
        transmitContentDetail: '',
        isFromTransmitView: false,
        mmsStatus: 4,
      }
      mConversationCtrl.pageInfos = new NavPathStack();
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.resetData);
      let res = false;
      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.generalTransmitMmsSend))(ArgumentMatchers.any)
        .afterAction(() => {
          res = true
        });
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('transmitFlag')
        .afterReturn({} as Object | window.WindowStage);
      mConversationCtrl.pageInfos.pushPathByName('', {
        mmsStatus: 1
      } as TransmitSourceType);
      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.deleteRcsTypeIfNoSupport))(ArgumentMatchers.any)
        .afterReturn(params);
      mConversationCtrl.transmitSend(context);

      mocker.clear(mConversationCtrl);
      mocker.clear(GlobalContext.getContext());
      expect(res).assertFalse();
    })

    it('ConversationControllerTest_transmitSend_mmsStatus_0', 0, () => {
      mConversationCtrl.pageInfos = new NavPathStack();
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.resetData);
      let res = false;
      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.generalTransmitMmsSend))(ArgumentMatchers.any)
        .afterAction(() => {
          res = true
        });
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('transmitFlag')
        .afterReturn({} as Object | window.WindowStage);
      mConversationCtrl.pageInfos.pushPathByName('', {
        mmsStatus: 0
      } as TransmitSourceType);

      mConversationCtrl.transmitSend(context);

      expect(res).assertFalse();
      mocker.clear(mConversationCtrl);
      mocker.clear(GlobalContext.getContext());
    })

    it('ConversationControllerTest_generalTransmitSend_isContainerOriginSource_true_contentLength_0', 0, () => {
      let res = false;
      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.delayTransmitSend))(ArgumentMatchers.any)
        .afterAction(() => {
          res = true;
        });

      let params: TransmitSourceType = {
        threadId: 1,
        strContactsName: '',
        strContactsNumber: '',
        strContactsNumberFormat: '',
        transmitSource: [{
          content: '',
          info: 'xx',
        } as TransmitInfoType,
          {
            content: '',
            info: '',
          } as TransmitInfoType],
        isContainerOriginSource: true,
        transmitContent: '',
        transmitContentDetail: '',
        isFromTransmitView: false,
        mmsStatus: 1,
      } as TransmitSourceType;

      mConversationCtrl.generalTransmitSend(context, params);

      expect(res).assertTrue();
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_generalTransmitSend_isContainerOriginSource_true_contentLength_0_info_undefined', 0,
      () => {
        let res = false;
        when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.delayTransmitSend))(ArgumentMatchers.any)
          .afterAction(() => {
            res = true;
          });

        let params: TransmitSourceType = {
          threadId: 1,
          strContactsName: '',
          strContactsNumber: '',
          strContactsNumberFormat: '',
          transmitSource: [{
            content: '',
          } as TransmitInfoType,
            {
              content: '',
              info: 'xxx',
            } as TransmitInfoType],
          isContainerOriginSource: true,
          transmitContent: '',
          transmitContentDetail: '',
          isFromTransmitView: false,
          mmsStatus: 1,
        } as TransmitSourceType;

        mConversationCtrl.generalTransmitSend(context, params);

        expect(res).assertTrue();
        mocker.clear(mConversationCtrl);
      })

    it('ConversationControllerTest_generalTransmitSend_isContainerOriginSource_true_contentLength_680', 0, () => {
      let str = '1234567890';
      let res = false;
      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.delayTransmitSend))(ArgumentMatchers.any)
        .afterAction(() => {
          res = true;
        });

      let params: TransmitSourceType = {
        threadId: 1,
        strContactsName: '',
        strContactsNumber: '',
        strContactsNumberFormat: '',
        transmitSource: [{
          content: str.repeat(68),
          info: '',
        } as TransmitInfoType,
          {
            content: '',
            info: '',
          } as TransmitInfoType],
        isContainerOriginSource: true,
        transmitContent: '',
        transmitContentDetail: '',
        isFromTransmitView: false,
        mmsStatus: 1,
      } as TransmitSourceType;

      mConversationCtrl.generalTransmitSend(context, params);

      expect(res).assertTrue();
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_generalTransmitSend_isContainerOriginSource_false_contentLength_680', 0, () => {
      let res = false;
      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.delayTransmitSend))(ArgumentMatchers.any)
        .afterAction(() => {
          res = true;
        });

      let params: TransmitSourceType = {
        threadId: 1,
        strContactsName: '',
        strContactsNumber: '',
        strContactsNumberFormat: '',
        transmitSource: [{
          content: '',
          info: '',
        } as TransmitInfoType,
          {
            content: '',
            info: '',
          } as TransmitInfoType],
        isContainerOriginSource: true,
        transmitContent: '',
        transmitContentDetail: '',
        isFromTransmitView: false,
        mmsStatus: 1,
      } as TransmitSourceType;

      mConversationCtrl.generalTransmitSend(context, params);

      expect(res).assertTrue();
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_delayTransmitSend_contentsLength_0', 0, () => {
      let element: ActionData = {
        contents: [],
        mmsSource: [{} as Mms]
      };

      mConversationCtrl.delayTransmitSend(context, element, false);

      expect(mConversationCtrl.mmsList.length).assertEqual(1);
    })

    it('ConversationControllerTest_delayTransmitSend_contentsLength_1', 0, () => {
      mConversationCtrl.isDraft = false;
      mConversationCtrl.threadId = 1;
      mConversationCtrl.contactsNum = 1;
      mConversationCtrl.currentQueryTimeID = 1;
      mConversationCtrl.queryTerminate.set(1, 1);
      ;
      mConversationCtrl.vCardJumpBack = false;
      mConversationCtrl.queryTerminate.set(1, 1);
      let element: ActionData = {
        contents: ['1'],
        mmsSource: [{} as Mms]
      };
      let res = false;
      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.sendSms))(ArgumentMatchers.any)
        .afterAction(() => {
          res = true;
        });
      let conversationService: ConversationService = ConversationService.getTestInstance();
      when(mocker.mockFunc(ConversationService, ConversationService.getInstance))().afterReturn(conversationService);
      when(mocker.mockFunc(conversationService,
        conversationService.queryAllInfoSizeByCondition))(ArgumentMatchers.any)
        .afterReturn(new  Promise<number>(resolve => resolve(1)));
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.deleteDraftData);
      when(mocker.mockFunc(DataShareHelper.getInstance(),
        DataShareHelper.getInstance().initSmsDB))(ArgumentMatchers.any)
        .afterReturn(new Promise<dataShare.DataShareHelper | undefined>(resolve => resolve(undefined)));

      mConversationCtrl.delayTransmitSend(context, element, false);

      expect(res).assertFalse();

      mocker.clear(ConversationService);
      mocker.clear(conversationService);
      mocker.clear(DataShareHelper.getInstance());
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_delayTransmitSend_contentsLength_2', 0, async () => {
      mConversationCtrl.isDraft = false;
      mConversationCtrl.threadId = 1;
      mConversationCtrl.contactsNum = 1;
      mConversationCtrl.currentQueryTimeID = 1;
      mConversationCtrl.queryTerminate.set(1, 1);
      mConversationCtrl.vCardJumpBack = false;
      mConversationCtrl.slotId = 0;
      mConversationCtrl.isEditMms = false;
      mConversationCtrl.isRcsMms = true;
      let mmsType: mmsListType = new mmsListType();
      mmsType.isRcs = 1;
      mmsType.showTitle = '';
      mmsType.rcsType = 0;
      mmsType.mmsSource = [];
      mConversationCtrl.mmsList = [mmsType];

      let element: ActionData = {
        contents: ['1', '2'],
        mmsSource: [{} as Mms]
      };
      mocker.mockFunc(HiLog, HiLog.i);
      when(mocker.mockFunc(MessageUtil, MessageUtil.replaceForLossy7Bit))(mConversationCtrl.slotId)
        .afterReturn('');
      let conversationService: ConversationService = ConversationService.getTestInstance();
      when(mocker.mockFunc(ConversationService, ConversationService.getInstance))().afterReturn(conversationService);
      when(mocker.mockFunc(conversationService,
        conversationService.queryAllInfoSizeByCondition))(ArgumentMatchers.any)
        .afterReturn(new  Promise<number>(resolve => resolve(1)));

      mocker.mockFunc(ConversationListService.getInstance(),
        ConversationListService.getInstance().deleteSessionByCondition);
      when(mocker.mockFunc(settingService,
        settingService.judgeIsDeliveryReport))(ArgumentMatchers.any)
        .afterReturn(0);
      when(mocker.mockFunc(TelephoneUtil,
        TelephoneUtil.judgeIsInfoMsg))(ArgumentMatchers.any)
        .afterReturn(false);
      when(mocker.mockFunc(TelephoneUtil,
        TelephoneUtil.dealTelephoneSort))(ArgumentMatchers.any)
        .afterReturn('22222');

      mocker.mockFunc(mConversationCtrl, mConversationCtrl.deleteDraftData);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.initSendSms);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.getSendText);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.setRcsMsgType);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.sendMessage);

      when(mocker.mockFunc(DataShareHelper.getInstance(),
        DataShareHelper.getInstance().initSmsDB))(ArgumentMatchers.any)
        .afterReturn(new Promise<dataShare.DataShareHelper | undefined>(resolve => resolve(undefined)));

      mConversationCtrl.delayTransmitSend(context, element, false);
      mocker.verify('i', [TAG, 'delayTransmitSend element']).never();
      mocker.clear(HiLog)
      mocker.clear(TelephoneUtil);
      mocker.clear(MessageUtil);
      mocker.clear(ConversationService);
      mocker.clear(conversationService);
      mocker.clear(settingService);
      mocker.clear(ConversationListService.getInstance());
      mocker.clear(DataShareHelper.getInstance());
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_generalTransmitMmsSend_isSource_true', 0, () => {
      let params: TransmitSourceType = {
        threadId: 1,
        strContactsName: '',
        strContactsNumber: '',
        strContactsNumberFormat: '',
        transmitSource: [{
          content: '',
          info: '',
        } as TransmitInfoType,
          {
            content: '',
            info: '',
          } as TransmitInfoType],
        isContainerOriginSource: true,
        transmitContent: '',
        transmitContentDetail: '',
        isFromTransmitView: false,
        mmsStatus: 1,
      } as TransmitSourceType;
      let res = true;
      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.delayTransmitMmsSend))(ArgumentMatchers.any)
        .afterAction(() => {
          res = true;
        });

      when(mocker.mockFunc(mConversationCtrl,
        mConversationCtrl.createNewSourcePath))(ArgumentMatchers.any)
        .afterReturn([]);

      mConversationCtrl.generalTransmitMmsSend(context, params);

      expect(res).assertTrue();
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_generalTransmitMmsSend_isSource_false', 0, () => {
      let params: TransmitSourceType = {
        threadId: 1,
        strContactsName: '',
        strContactsNumber: '',
        strContactsNumberFormat: '',
        transmitSource: [{
          content: '',
          info: '',
        } as TransmitInfoType,
          {
            content: '',
            info: '',
          } as TransmitInfoType],
        isContainerOriginSource: false,
        transmitContent: '',
        transmitContentDetail: '',
        isFromTransmitView: false,
        mmsStatus: 1,
      } as TransmitSourceType;
      let res = true;
      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.delayTransmitMmsSend))(ArgumentMatchers.any)
        .afterAction(() => {
          res = true;
        });

      when(mocker.mockFunc(mConversationCtrl,
        mConversationCtrl.createNewSourcePath))(ArgumentMatchers.any)
        .afterReturn([]);

      mConversationCtrl.generalTransmitMmsSend(context, params);

      expect(res).assertTrue();
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_createNewSourcePath_IMAGE', 0, () => {
      let mmsSource: mmsSourceItem[] = [{
        mms: [{
          type: commonData.MM_ATTACHMENT_TYPE.IMAGE,
          path: '',
          name: ''
        } as Mms] as Mms[],
        content: ''
      } as mmsSourceItem];
      when(mocker.mockFunc(FileUtil, FileUtil.writeMediaToSandBox))(ArgumentMatchers.any)
        .afterReturn('/');
      when(mocker.mockFunc(FileUtil, FileUtil.getFileName))(ArgumentMatchers.any)
        .afterReturn('name');

      let res: mmsSourceItem[] = mConversationCtrl.createNewSourcePath(context, mmsSource, false, '');

      expect(res[0].mms[0].type).assertEqual(commonData.MM_ATTACHMENT_TYPE.IMAGE);
      mocker.clear(FileUtil);
    })

    it('ConversationControllerTest_createNewSourcePath_AUDIO', 0, () => {
      let mmsSource: mmsSourceItem[] = [];
      let addr: AddressInfo = new AddressInfo(0, 1, 'src', 'src');
      addr.name = 'src';
      mmsSource.push({
        mms: [{
          type: 1,
          path: '',
          name: ''
        } as Mms] as Mms[],
        content: '',
        contentType: 1,
        fullMmsSource:[{
          type: commonData.MM_ATTACHMENT_TYPE.IMAGE,
          path: '',
          name: ''
        } as Mms,{
          type: commonData.ENHANCED_INFO_ITEM_TYPE.MAP,
          path: '',
          name: ''
        } as Mms,{
          type: commonData.ENHANCED_INFO_ITEM_TYPE.MAP,
          path: '',
          name: '',
          address: addr
        } as Mms,{
          type: commonData.MM_ATTACHMENT_TYPE.TEXT,
          path: '',
          name: ''
        } as Mms]
      } as mmsSourceItem);
      when(mocker.mockFunc(MmsUtil, MmsUtil.isSlideType))(ArgumentMatchers.any)
        .afterReturn(false);
      when(mocker.mockFunc(FileUtil, FileUtil.writeMediaToSandBox))(ArgumentMatchers.any)
        .afterReturn('/');
      when(mocker.mockFunc(FileUtil, FileUtil.getFileName))(ArgumentMatchers.any)
        .afterReturn('name');

      let res: mmsSourceItem[] = mConversationCtrl.createNewSourcePath(context, mmsSource, false, '', true);

      expect(res[0].mms[0].type).assertEqual(commonData.MM_ATTACHMENT_TYPE.IMAGE);
      mocker.clear(MmsUtil);
      mocker.clear(FileUtil);
    })

    it('ConversationControllerTest_createNewSourcePath_VIDEO', 0, () => {
      let mmsSource: mmsSourceItem[] = [{
        mms: [{
          type: 3,
          path: '',
          name: ''
        } as Mms] as Mms[],
        content: ''
      } as mmsSourceItem];
      when(mocker.mockFunc(FileUtil, FileUtil.writeMediaToSandBox))(ArgumentMatchers.any)
        .afterReturn('/');
      when(mocker.mockFunc(FileUtil, FileUtil.getFileName))(ArgumentMatchers.any)
        .afterReturn('name');

      let res: mmsSourceItem[] = mConversationCtrl.createNewSourcePath(context, mmsSource, false, '');

      expect(res[0].mms[0].type).assertEqual(3);
      mocker.clear(FileUtil);
    })

    it('ConversationControllerTest_createNewSourcePath_FILE', 0, () => {
      let mmsSource: mmsSourceItem[] = [{
        mms: [{
          type: commonData.MM_ATTACHMENT_TYPE.VIDEO,
          path: '',
          name: ''
        } as Mms,{
          type: 2,
          path: '',
          name: ''
        } as Mms,{
          type: 12,
          path: '',
          name: ''
        } as Mms] as Mms[],
        content: ''
      } as mmsSourceItem];
      when(mocker.mockFunc(FileUtil, FileUtil.writeMediaToSandBox))(ArgumentMatchers.any)
        .afterReturn('/');
      when(mocker.mockFunc(FileUtil, FileUtil.getFileName))(ArgumentMatchers.any)
        .afterReturn('name');

      let res: mmsSourceItem[] = mConversationCtrl.createNewSourcePath(context, mmsSource, false, '', true);

      expect(res[0].mms[0].type).assertEqual(2);
      mocker.clear(FileUtil);
    })

    it('ConversationControllerTest_createNewSourcePath_8', 0, () => {
      let mmsSource: mmsSourceItem[] = [{
        mms: [{
          type: 8,
          path: '',
          name: ''
        } as Mms],
        content: ''
      } as mmsSourceItem];
      let res = false;
      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.readFileContent))(ArgumentMatchers.any)
        .afterAction(() => {
          res = true;
        });

      mConversationCtrl.createNewSourcePath(context, mmsSource, false, '', true);

      expect(res).assertFalse();
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_queryMessageDetailCallBack_mmsSourceLength_1', 0, async () => {
      let mmsSource: mmsSourceItem[] = [{
        mms: [{
          type: 8,
          path: '',
          name: ''
        } as Mms],
        content: ''
      } as mmsSourceItem];
      let res = false;
      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.sendSms))(ArgumentMatchers.any)
        .afterAction(() => {
          res = true;
        });

      await mConversationCtrl.queryMessageDetailCallBack(context, mmsSource, false);

      expect(res).assertTrue();
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_queryMessageDetailCallBack_mmsSourceLength_2_isMaxGroupIdEffective_false', 0,
      async () => {
        let mmsSource: mmsSourceItem[] = [{
          mms: [{
            type: 8,
          } as Mms],
          content: ''
        } as mmsSourceItem, {
          mms: [{
            type: 8
          } as Mms],
          content: ''
        } as mmsSourceItem];
        let res = false;
        when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.sendSms))(ArgumentMatchers.any)
          .afterAction(() => {
            res = true;
          });
        when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('mmsContext')
          .afterReturn({} as myCommon.UIAbilityContext);
        when(mocker.mockFunc(DataShareHelper.getInstance(),
          DataShareHelper.getInstance().initSmsDB))(ArgumentMatchers.any)
          .afterReturn(new Promise<dataShare.DataShareHelper | undefined>(resolve => resolve(undefined)))

        await mConversationCtrl.queryMessageDetailCallBack(context, mmsSource, false);

        expect(res).assertTrue();
        mocker.clear(mConversationCtrl);
        mocker.clear(GlobalContext.getContext());
        mocker.clear(DataShareHelper.getInstance());
      })

    it('ConversationControllerTest_queryMessageDetailCallBack_mmsSourceLength_2_isMaxGroupIdEffective_true', 0,
      async () => {
        let mmsSource: mmsSourceItem[] = [{
          mms: [{
            type: 8
          } as Mms],
          content: ''
        } as mmsSourceItem, {
          mms: [{
            type: 8
          } as Mms],
          content: ''
        } as mmsSourceItem];
        let res = false;
        when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.sendSms))(ArgumentMatchers.any)
          .afterAction(() => {
            res = true;
          });
        when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('mmsContext')
          .afterReturn({} as myCommon.UIAbilityContext);
        let myset: DataShareResultSet = new MySet();
        myset.rowCount = 1;
        when(mocker.mockFunc(DataShareHelper.getInstance(),
          DataShareHelper.getInstance().initSmsDB))(ArgumentMatchers.any)
          .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
            query: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
              columns: string[]): Promise<DataShareResultSet> =>
            new Promise<DataShareResultSet>(resolve => resolve(myset))
          } as dataShare.DataShareHelper)));

        await mConversationCtrl.queryMessageDetailCallBack(context, mmsSource, false);

        expect(res).assertTrue();
        mocker.clear(mConversationCtrl);
        mocker.clear(GlobalContext.getContext());
        mocker.clear(DataShareHelper.getInstance());
      })


    it('ConversationControllerTest_readFileContent', 0, () => {
      mocker.mockFunc(FileUtil, FileUtil.writeTextToSandBox);
      let mms: Mms = {
        duration: 'string',
        type: 1,
        path: 'string',
        name: 'string',
        text: 'string',
        isOnAudio: false,
        pixelMap: {} as PixelMap,
        imagePath: 'string',
        size: 'string',
        copyPath: 'string',
        index: 0,
        galleryPath: 'string',
        isRcs: false,
        pageNum: 1,
        pageCount: 1,
        content: 'string',
        contacts: [],
        isOriginalImage: false
      }
      mConversationCtrl.readFileContent(context, mms);
      mocker.clear(FileUtil);
      expect(mConversationCtrl.isRcsMms).assertTrue();
    })

    it('ConversationControllerTest_delayTransmitMmsSend_length_0', 0, () => {
      let mmsSource: mmsSourceItem[] = [];
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.queryMessageDetailCallBack);
      mConversationCtrl.delayTransmitMmsSend(context, mmsSource, false);
      mocker.verify('queryMessageDetailCallBack', [mmsSource]).never();
      mocker.clear(mConversationCtrl);
      mocker.clear(FileUtil);
    })

    it('ConversationControllerTest_delayTransmitMmsSend_length_1', 0, () => {
      mConversationCtrl.isDraft = false;
      mConversationCtrl.threadId = 1;
      mConversationCtrl.contactsNum = 1;
      mConversationCtrl.currentQueryTimeID = 1;
      mConversationCtrl.queryTerminate.set(1, 1);
      let mmsSource: mmsSourceItem[] = [{
        content: '',
        mms: []
      }];
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.queryMessageDetailCallBack);

      let conversationService: ConversationService = ConversationService.getTestInstance();
      when(mocker.mockFunc(ConversationService, ConversationService.getInstance))().afterReturn(conversationService);
      when(mocker.mockFunc(conversationService,
        conversationService.queryAllInfoSizeByCondition))(ArgumentMatchers.any)
        .afterReturn(new  Promise<number>(resolve => resolve(1)));
      when(mocker.mockFunc(DataShareHelper.getInstance(),
        DataShareHelper.getInstance().initSmsDB))(ArgumentMatchers.any)
        .afterReturn(new Promise<dataShare.DataShareHelper | undefined>(resolve => resolve(undefined)));

      mConversationCtrl.delayTransmitMmsSend(context, mmsSource, false);

      mocker.verify('queryMessageDetailCallBack', [mmsSource]).never();

      mocker.clear(ConversationService);
      mocker.clear(conversationService);
      mocker.clear(mConversationCtrl);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('ConversationControllerTest_sendSms', 0, () => {
      mConversationCtrl.isEditMms = true;
      when(mocker.mockFunc(MessageUtil, MessageUtil.replaceForLossy7Bit))(mConversationCtrl.slotId)
        .afterReturn('');
      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.getSendText))(ArgumentMatchers.any)
        .afterReturn('');
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.initSendSms);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.sendInterval);

      mConversationCtrl.sendSms(context, 'xx', false, [], false, () => {
      }, 0);

      expect(mConversationCtrl.isEditMms).assertTrue();
      mocker.clear(MessageUtil);
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_sendSms_isEditMms_false', 0, () => {
      mConversationCtrl.isEditMms = false;
      when(mocker.mockFunc(MessageUtil, MessageUtil.replaceForLossy7Bit))(mConversationCtrl.slotId)
        .afterReturn('');
      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.getSendText))(ArgumentMatchers.any)
        .afterReturn('');
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.initSendSms);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.sendInterval);

      mConversationCtrl.sendSms(context, 'xx', false, [], false, () => {
      }, null);

      expect(mConversationCtrl.isEditMms).assertFalse();
      mocker.clear(MessageUtil);
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_shareMmsMessage_path_empty_isAudio_true', 0, () => {
      let listTyp: mmsListType = new mmsListType();
      listTyp.mmsSource = [{
        type: 1,
        path: '',
        duration: ''
      } as Mms];
      expect(shareMmsMessage(listTyp)).assertUndefined();
    })

    it('ConversationControllerTest_shareMmsMessage_type_minus1_path_empty_isAudio_true', 0, () => {
      let listTyp: mmsListType = new mmsListType();
      listTyp.mmsSource = [{
        type: -1,
        path: '/',
        duration: ''
      } as Mms];
      expect(shareMmsMessage(listTyp)).assertUndefined();
    })

    it('ConversationControllerTest_shareMmsMessage_type_3_path_empty_isAudio_true', 0, () => {
      let listTyp: mmsListType = new mmsListType();
      listTyp.mmsSource = [{
        type: 3,
        path: '/',
        duration: ''
      } as Mms];

      when(mocker.mockFunc(MmsUtil, MmsUtil.isAudio))(3).afterReturn(true);
      expect(JSON.stringify(shareMmsMessage(listTyp))).assertUndefined();
      mocker.clear(MmsUtil);
    })

    it('ConversationControllerTest_shareMmsMessage_type_1_path_empty_isImage_true', 0, () => {
      let listTyp: mmsListType = new mmsListType();
      listTyp.mmsSource = [{
        type: 1,
        path: '/',
        duration: ''
      } as Mms];
      when(mocker.mockFunc(MmsUtil, MmsUtil.isAudio))(3).afterReturn(false);
      when(mocker.mockFunc(MmsUtil, MmsUtil.isAudio))(1).afterReturn(true);
      expect(JSON.stringify(shareMmsMessage(listTyp))).assertUndefined();
      mocker.clear(MmsUtil);
    })

    it('ConversationControllerTest_shareMmsMessage_type_2_path_empty_isImage_true', 0, () => {
      let listTyp: mmsListType = new mmsListType();
      listTyp.mmsSource = [{
        type: 2,
        path: '/',
        duration: ''
      } as Mms];
      when(mocker.mockFunc(MmsUtil, MmsUtil.isAudio))(3).afterReturn(false);
      when(mocker.mockFunc(MmsUtil, MmsUtil.isAudio))(1).afterReturn(false);
      when(mocker.mockFunc(MmsUtil, MmsUtil.isVideo))(2).afterReturn(true);
      expect(JSON.stringify(shareMmsMessage(listTyp))).assertUndefined();
      mocker.clear(MmsUtil);
    })

    it('ConversationControllerTest_shareMessage_target_undefined', 0, async () => {
      let listTyp: mmsListType = new mmsListType();
      listTyp.isCbChecked = false;
      listTyp.mmsSource = [{
        type: 2,
        path: '/',
        duration: ''
      } as Mms];
      mConversationCtrl.mmsList = [listTyp];

      await shareMessage(listTyp, context);
      expect(mConversationCtrl.mmsList[0].isCbChecked).assertFalse();
    })

    it('ConversationControllerTest_shareMessage_isMsm_true', 0, async () => {
      let listTyp: mmsListType = new mmsListType();
      listTyp.isCbChecked = true;
      listTyp.isMsm = true;
      listTyp.mmsSource = [{
        type: 2,
        path: '/',
        duration: ''
      } as Mms];
      mConversationCtrl.mmsList = [listTyp];

      await shareMessage(listTyp, context);
      expect(mConversationCtrl.mmsList[0].isCbChecked).assertTrue();
    })

    it('ConversationControllerTest_shareMessage_isMsm_false', 0, async () => {
      let listTyp: mmsListType = new mmsListType();
      listTyp.isCbChecked = false;
      listTyp.isMsm = true;
      listTyp.mmsSource = [{
        type: 2,
        path: '/',
        duration: ''
      } as Mms];
      mConversationCtrl.mmsList = [listTyp];

      when(mocker.mockFunc(mConversationCtrl, shareMmsMessage))(ArgumentMatchers.any)
        .afterReturn({} as systemShare.SharedData | undefined);

      await shareMessage(listTyp, context);
      expect(mConversationCtrl.mmsList[0].isCbChecked).assertFalse();
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_shareMessage_catch', 0, async () => {
      let listTyp: mmsListType = new mmsListType();
      listTyp.isCbChecked = false;
      listTyp.isMsm = true;
      listTyp.mmsSource = [{
        type: 2,
        path: '/',
        duration: ''
      } as Mms];
      mConversationCtrl.mmsList = [listTyp];

      await shareMessage(listTyp, context);
      expect(mConversationCtrl.mmsList[0].isCbChecked).assertFalse();
    })

    it('ConversationControllerTest_initSendSms_isMms_false_isRcsMms_true_contactsNum_2',
      0, () => {
        mConversationCtrl.isRcsMms = true;
        mConversationCtrl.strContactsNumber = '1111,2222';

        when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.getSendText))(ArgumentMatchers.any)
          .afterReturn('');
        mocker.mockFunc(DateUtil, DateUtil.convertTimeStampToDateWeek);
        mocker.mockFunc(DateUtil, DateUtil.fullDate);
        when(mocker.mockFunc(settingService, settingService.judgeIsDeliveryReport))(ArgumentMatchers.any)
          .afterReturn(false);
        when(mocker.mockFunc(MmsUtil, MmsUtil.getMmsContentType))(ArgumentMatchers.any)
          .afterReturn(0);
        mocker.mockFunc(ConversationDataSource.getInstance(), ConversationDataSource.getInstance().refresh);

        mConversationCtrl.initSendSms(context, '', false, [], false, false);

        expect(mConversationCtrl.mmsList[0].failuresNumber).assertEqual(0);
        mocker.clear(mConversationCtrl);
        mocker.clear(DateUtil);
        mocker.clear(settingService);
        mocker.clear(MmsUtil);
        mocker.clear(ConversationDataSource.getInstance());
      })

    it('ConversationControllerTest_initSendSms_isMms_true_isRcsMms_false_contactsNum_1',
      0, () => {
        mConversationCtrl.isRcsMms = false;
        mConversationCtrl.strContactsNumber = '1111';

        let mmsSource: Array<Mms> = [];
        when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.getSmilSource))(ArgumentMatchers.any)
          .afterReturn({});
        mocker.mockFunc(mmsSource, mmsSource.unshift);
        when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.getSendText))(ArgumentMatchers.any)
          .afterReturn('');
        mocker.mockFunc(DateUtil, DateUtil.convertTimeStampToDateWeek);
        mocker.mockFunc(DateUtil, DateUtil.fullDate);
        when(mocker.mockFunc(settingService, settingService.judgeIsDeliveryReport))(ArgumentMatchers.any)
          .afterReturn(false);
        when(mocker.mockFunc(MmsUtil, MmsUtil.getMmsContentType))(ArgumentMatchers.any)
          .afterReturn(0);
        mocker.mockFunc(ConversationDataSource.getInstance(), ConversationDataSource.getInstance().refresh);

        mConversationCtrl.initSendSms(context, '', true, mmsSource, false, false);

        expect(mConversationCtrl.mmsList[0].failuresNumber).assertEqual(0);
        mocker.clear(mConversationCtrl);
        mocker.clear(DateUtil);
        mocker.clear(settingService);
        mocker.clear(MmsUtil);
        mocker.clear(ConversationDataSource.getInstance());
      })

    it('ConversationControllerTest_isNeedTransmitTip_mmsSource_length_1', 0, () => {
      let listTyp: mmsListType = new mmsListType();
      listTyp.isMsm = true;
      listTyp.isCbChecked = true;
      listTyp.mmsSource = [{
        type: 3,
        path: '/',
        duration: ''
      } as Mms];
      mConversationCtrl.mmsList = [listTyp];

      mocker.mockFunc(mConversationCtrl, mConversationCtrl.setDateShow);

      let res = mConversationCtrl.isNeedTransmitTip();

      expect(res).assertTrue();
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_isNeedTransmitTip_mmsSource_length_4', 0, () => {
      let listTyp: mmsListType = new mmsListType();
      listTyp.isMsm = true;
      listTyp.isCbChecked = true;
      listTyp.mmsSource = [{
        type: 1,
        path: '/',
        duration: ''
      } as Mms, {
        type: 2,
        path: '/',
        duration: ''
      } as Mms, {
        type: 3,
        path: '/',
        duration: ''
      } as Mms, {
        type: 0,
        path: '/',
        duration: ''
      } as Mms];
      mConversationCtrl.mmsList = [listTyp];

      mocker.mockFunc(mConversationCtrl, mConversationCtrl.setDateShow);

      let res = mConversationCtrl.isNeedTransmitTip();

      expect(res).assertFalse();
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_isNeedTransmitTip_isMsm_false', 0, () => {
      let listTyp: mmsListType = new mmsListType();
      listTyp.isMsm = false;
      listTyp.isCbChecked = true;
      listTyp.mmsSource = [{
        type: 1,
        path: '/',
        duration: ''
      } as Mms, {
        type: 2,
        path: '/',
        duration: ''
      } as Mms, {
        type: 3,
        path: '/',
        duration: ''
      } as Mms, {
        type: 0,
        path: '/',
        duration: ''
      } as Mms];
      mConversationCtrl.mmsList = [listTyp];

      mocker.mockFunc(mConversationCtrl, mConversationCtrl.setDateShow);

      let res = mConversationCtrl.isNeedTransmitTip();

      expect(res).assertFalse();
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_transmitMsg_length_4_index_1_strContactsName_notEmpty_isMsm_false', 0, () => {
      mConversationCtrl.strContactsName = 'name';
      mConversationCtrl.strContactsNumberFormat = '1111';

      let listTyp: mmsListType = new mmsListType();
      listTyp.isMsm = false;
      listTyp.isCbChecked = true;
      listTyp.isRcs = 1;
      listTyp.rcsType = 2;
      listTyp.mmsSource = [{
        type: 1,
        path: '/',
        duration: ''
      } as Mms, {
        type: 2,
        path: '/',
        duration: ''
      } as Mms, {
        type: 3,
        path: '/',
        duration: ''
      } as Mms, {
        type: 0,
        path: '/',
        duration: ''
      } as Mms];

      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.buildSelectedArr))(0)
        .afterReturn([listTyp, listTyp, listTyp, listTyp]);
      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.getTransmitInfo))(ArgumentMatchers.any)
        .afterReturn('');
      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.getTransmitSource))(ArgumentMatchers.any)
        .afterReturn([]);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.jumpTransmitMsg);
      when(mocker.mockFunc(GlobalContext.getContext(),
        GlobalContext.getContext().getObject))('mmsContext')
        .afterReturn({
          resourceManager: {
            getStringSync: (resource: Resource, ...args: (string | number)[]): string => 'xx'
          } as resourceManager.ResourceManager
        } as Object | window.WindowStage);

      mConversationCtrl.transmitMsg(context, 0);

      expect(mConversationCtrl.mmsEditList.length).assertEqual(0);
      mocker.clear(mConversationCtrl);
      mocker.clear(GlobalContext.getContext());
    })

    it('ConversationControllerTest_transmitMsg_length_1_index_0_strContactsName_empty_isMsm_true_isReceive_true', 0,
      () => {
        mConversationCtrl.strContactsName = '';
        mConversationCtrl.strContactsNumberFormat = '1111';

        let listTyp: mmsListType = new mmsListType();
        listTyp.isMsm = true;
        listTyp.isReceive = true;
        listTyp.isCbChecked = true;
        listTyp.isRcs = 1;
        listTyp.rcsType = 2;
        listTyp.mmsSource = [{
          type: 1,
          path: '/',
          duration: ''
        } as Mms];

        when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.buildSelectedArr))(0)
          .afterReturn([listTyp]);
        when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.getTransmitInfo))(ArgumentMatchers.any)
          .afterReturn('');
        when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.getTransmitSource))(ArgumentMatchers.any)
          .afterReturn([]);
        mocker.mockFunc(mConversationCtrl, mConversationCtrl.jumpTransmitMsg);
        when(mocker.mockFunc(GlobalContext.getContext(),
          GlobalContext.getContext().getObject))('mmsContext')
          .afterReturn({
            resourceManager: {
              getStringSync: (resource: Resource, ...args: (string | number)[]): string => 'xx'
            } as resourceManager.ResourceManager
          } as Object | window.WindowStage);

        mConversationCtrl.transmitMsg(context, 0);

        expect(mConversationCtrl.mmsEditList.length).assertEqual(0);
        mocker.clear(mConversationCtrl);
        mocker.clear(GlobalContext.getContext());
      })

    it('ConversationControllerTest_transmitMsg_length_1_index_0_strContactsName_empty_isMsm_undefined_isReceive_false',
      0, () => {
        mConversationCtrl.strContactsName = '';
        mConversationCtrl.strContactsNumberFormat = '1111';

        let listTyp: mmsListType = new mmsListType();
        listTyp.isReceive = false;
        listTyp.isCbChecked = true;
        listTyp.mmsSource = [{
          type: 1,
          path: '/',
          duration: ''
        } as Mms];

        when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.buildSelectedArr))(0)
          .afterReturn([listTyp]);
        when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.getTransmitInfo))(ArgumentMatchers.any)
          .afterReturn('');
        when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.getTransmitSource))(ArgumentMatchers.any)
          .afterReturn([]);
        mocker.mockFunc(mConversationCtrl, mConversationCtrl.jumpTransmitMsg);
        when(mocker.mockFunc(GlobalContext.getContext(),
          GlobalContext.getContext().getObject))('mmsContext')
          .afterReturn({
            resourceManager: {
              getStringSync: (resource: Resource, ...args: (string | number)[]): string => 'xx'
            } as resourceManager.ResourceManager
          } as Object | window.WindowStage);

        mConversationCtrl.transmitMsg(context, 0);

        expect(mConversationCtrl.mmsEditList.length).assertEqual(0);
        mocker.clear(mConversationCtrl);
        mocker.clear(GlobalContext.getContext());
      })

    it('ConversationControllerTest_buildSelectedArr_length_1_index_0', 0, () => {
      let listTyp: mmsListType = new mmsListType();
      listTyp.isReceive = false;
      listTyp.isCbChecked = true;
      listTyp.mmsSource = [{
        type: 1,
        path: '/',
        duration: ''
      } as Mms];
      mConversationCtrl.mmsList = [listTyp];

      let res: Array<mmsListType> = mConversationCtrl.buildSelectedArr(0);

      expect(res.length).assertEqual(1);
    })

    it('ConversationControllerTest_buildSelectedArr_length_1_index_1_isCbChecked_true_audioStatus_0_mmsSource_length_4_isMsm_true',
      0, () => {
        mConversationCtrl.audioStatus = 0;

        let listTyp: mmsListType = new mmsListType();
        listTyp.isReceive = false;
        listTyp.isMsm = true;
        listTyp.isCbChecked = true;
        listTyp.mmsSource = [{
          type: 1,
          path: '/',
          duration: ''
        } as Mms, {
          type: 1,
          path: '/',
          duration: ''
        } as Mms, {
          type: 1,
          path: '/',
          duration: ''
        } as Mms, {
          type: 1,
          path: '/',
          duration: ''
        } as Mms];
        mConversationCtrl.mmsList = [listTyp];

        let res: Array<mmsListType> = mConversationCtrl.buildSelectedArr(1);

        expect(res.length).assertEqual(1);
      })

    it('ConversationControllerTest_buildSelectedArr_length_1_index_1_isCbChecked_true_audioStatus_0_mmsSource_length_1_isMsm_true_type_3',
      0, () => {
        mConversationCtrl.audioStatus = 0;

        let listTyp: mmsListType = new mmsListType();
        listTyp.isReceive = false;
        listTyp.isMsm = true;
        listTyp.isCbChecked = true;
        listTyp.mmsSource = [{
          type: 3,
          path: '/',
          duration: ''
        } as Mms];
        mConversationCtrl.mmsList = [listTyp];

        let res: Array<mmsListType> = mConversationCtrl.buildSelectedArr(1);

        expect(res.length).assertEqual(0);
      })

    it('ConversationControllerTest_buildSelectedArr_length_1_index_1_isCbChecked_true_audioStatus_0_mmsSource_length_1_isMsm_true_type_1',
      0, () => {
        mConversationCtrl.audioStatus = 0;

        let listTyp: mmsListType = new mmsListType();
        listTyp.isReceive = false;
        listTyp.isMsm = true;
        listTyp.isCbChecked = true;
        listTyp.mmsSource = [{
          type: 1,
          path: '/',
          duration: ''
        } as Mms];
        mConversationCtrl.mmsList = [listTyp];

        let res: Array<mmsListType> = mConversationCtrl.buildSelectedArr(1);

        expect(res.length).assertEqual(1);
      })

    it('ConversationControllerTest_buildSelectedArr_length_1_index_1_isCbChecked_true_audioStatus_0_isMsm_false', 0,
      () => {
        mConversationCtrl.audioStatus = 0;

        let listTyp: mmsListType = new mmsListType();
        listTyp.isReceive = false;
        listTyp.isMsm = false;
        listTyp.isCbChecked = true;
        listTyp.mmsSource = [{
          type: 1,
          path: '/',
          duration: ''
        } as Mms];
        mConversationCtrl.mmsList = [listTyp];

        let res: Array<mmsListType> = mConversationCtrl.buildSelectedArr(1);

        expect(res.length).assertEqual(1);
      })

    it('ConversationControllerTest_buildSelectedArr_length_1_index_1_isCbChecked_false', 0, () => {
      mConversationCtrl.audioStatus = 0;

      let listTyp: mmsListType = new mmsListType();
      listTyp.isReceive = false;
      listTyp.isMsm = false;
      listTyp.isCbChecked = false;
      listTyp.mmsSource = [{
        type: 1,
        path: '/',
        duration: ''
      } as Mms];
      mConversationCtrl.mmsList = [listTyp];

      let res: Array<mmsListType> = mConversationCtrl.buildSelectedArr(1);

      expect(res.length).assertEqual(0);
    })

    it('ConversationControllerTest_getTransmitSource_length_0', 0, () => {
      mConversationCtrl.audioStatus = 0;

      let mmsSource: Array<Mms> = [];

      let res: Mms[] = mConversationCtrl.getTransmitSource(mmsSource);

      expect(res.length).assertEqual(0);
    })

    it('ConversationControllerTest_getTransmitSource_length_1_type_0', 0, () => {
      mConversationCtrl.audioStatus = 0;

      let mmsSource: Array<Mms> = [{
        type: 0
      } as Mms];

      let res: Mms[] = mConversationCtrl.getTransmitSource(mmsSource);

      expect(res.length).assertEqual(0);
    })

    it('ConversationControllerTest_getTransmitSource_length_1_type_1', 0, () => {
      mConversationCtrl.audioStatus = 0;

      let mmsSource: Array<Mms> = [{
        type: 1
      } as Mms];

      let res: Mms[] = mConversationCtrl.getTransmitSource(mmsSource);

      expect(res.length).assertEqual(1);
    })

    it('ConversationControllerTest_getTransmitInfo_isReceive_false', 0, () => {let context = {
      resourceManager: {
        getStringSync: (resource: Resource, ...args: (string | number)[]): string => 'xx'
      } as resourceManager.ResourceManager
    } as Context;
      let listTyp: mmsListType = new mmsListType();
      listTyp.isReceive = false;
      listTyp.timeOfSms = '12345s';
      listTyp.fullDate = '0';

      mocker.mockFunc(DateUtil, DateUtil.fullDate);
      when(mocker.mockFunc(GlobalContext.getContext(),
        GlobalContext.getContext().getObject))('mmsContext')
        .afterReturn({
          resourceManager: {
            getStringSync: (resource: Resource, ...args: (string | number)[]): string => 'xx'
          } as resourceManager.ResourceManager
        } as Object | window.WindowStage);

      let res: string = mConversationCtrl.getTransmitInfo(context, listTyp, '');

      expect(res).assertEqual('0 12345 xx:');
      mocker.clear(GlobalContext.getContext());
      mocker.clear(DateUtil);
    })

    it('ConversationControllerTest_getTransmitInfo_isReceive_true', 0, () => {
      let listTyp: mmsListType = new mmsListType();
      listTyp.isReceive = true;
      listTyp.timeOfSms = '345678s';
      listTyp.fullDate = '0';

      mocker.mockFunc(DateUtil, DateUtil.fullDate);
      when(mocker.mockFunc(GlobalContext.getContext(),
        GlobalContext.getContext().getObject))('mmsContext')
        .afterReturn({
          resourceManager: {
            getStringSync: (resource: Resource): string => 'xx'
          } as resourceManager.ResourceManager
        } as Object | window.WindowStage);

      let res: string = mConversationCtrl.getTransmitInfo(context, listTyp, 'xx');

      expect(res).assertEqual('0 345678 xx:');
      mocker.clear(DateUtil);
      mocker.clear(GlobalContext.getContext());
    })

    it('ConversationControllerTest_jumpTransmitMsg', 0, () => {
      mConversationCtrl.pageInfos = new NavPathStack();
      mConversationCtrl.jumpTransmitMsg('', '', [], 0);

      expect(mConversationCtrl.pageInfos.getAllPathName()[0]).assertEqual('TransmitMsg');
      mConversationCtrl.isPC = true;
      mConversationCtrl.jumpTransmitMsg('', '', [], 0);
      expect(mConversationCtrl).not().assertUndefined();
      AppStorage.clear();
    })

    it('ConversationControllerTest_reportDialogShow_isMsm_false', 0, () => {
      let listTyp: mmsListType = new mmsListType();
      listTyp.isShowMsgLongMenu = false;
      listTyp.isMsm = false;
      listTyp.timeOfSms = {
        id: 0,
        type: 0,
        params: [],
        bundleName: '',
        moduleName: ''
      };
      mConversationCtrl.mmsList = [listTyp];
      mConversationCtrl.mmsIndex = 0;

      mConversationCtrl.reportDialogShow();

      expect(mConversationCtrl.hasContent).assertTrue();
    })

    it('ConversationControllerTest_reportDialogShow_isMsm_true', 0, () => {
      let listTyp: mmsListType = new mmsListType();
      listTyp.isShowMsgLongMenu = false;
      listTyp.isMsm = true;
      listTyp.timeOfSms = {
        id: 0,
        type: 0,
        params: [],
        bundleName: '',
        moduleName: ''
      };
      mConversationCtrl.mmsList = [listTyp];
      mConversationCtrl.mmsIndex = 0;

      mConversationCtrl.reportDialogShow();

      expect(mConversationCtrl.hasContent).assertTrue();
    })

    it('ConversationControllerTest_deleteDialogShow_isMsm_false', 0, () => {
      let listTyp: mmsListType = new mmsListType();
      listTyp.isShowMsgLongMenu = false;
      listTyp.isMsm = false;
      mConversationCtrl.mmsList = [listTyp];
      mConversationCtrl.mmsIndex = 0;

      mConversationCtrl.deleteDialogShow();

      expect(mConversationCtrl.hasContent).assertTrue();
    })

    it('ConversationControllerTest_deleteDialogShow_isMsm_true', 0, () => {
      let listTyp: mmsListType = new mmsListType();
      listTyp.isShowMsgLongMenu = false;
      listTyp.isMsm = true;
      mConversationCtrl.mmsList = [listTyp];
      mConversationCtrl.mmsIndex = 0;

      mConversationCtrl.deleteDialogShow();

      expect(mConversationCtrl.hasContent).assertTrue();
    })

    it('ConversationControllerTest_favorite', 0, () => {
      let listTyp: mmsListType = new mmsListType();
      listTyp.isCbChecked = true;
      mConversationCtrl.mmsList = [listTyp];

      mConversationCtrl.favorite();

      expect(mConversationCtrl.mmsList[0].isCbChecked).assertFalse();
    })

    it('ConversationControllerTest_more_isCbChecked_false_isMsm_true', 0, () => {
      let listTyp: mmsListType = new mmsListType();
      listTyp.isCbChecked = false;
      listTyp.isMsm = true;
      listTyp.hasReport = false;
      listTyp.isShowMsgLongMenu = false;
      mConversationCtrl.mmsList = [listTyp];

      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.checkMmsListCbSelectedItem))(ArgumentMatchers.any)
        .afterReturn(listTyp);
      mocker.mockFunc(ConversationDataSource.getInstance(), ConversationDataSource.getInstance().refresh);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.setSelectStatus);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.setMessageCheckAll);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.setGroupMoreMenu);

      mConversationCtrl.more();

      expect(mConversationCtrl.hasReport).assertFalse();
      mocker.clear(mConversationCtrl);
      mocker.clear(ConversationDataSource.getInstance());
    })

    it('ConversationControllerTest_more_isCbChecked_false_isMsm_false', 0, () => {
      let listTyp: mmsListType = new mmsListType();
      listTyp.isCbChecked = false;
      listTyp.isMsm = false;
      listTyp.hasReport = false;
      listTyp.isShowMsgLongMenu = false;
      mConversationCtrl.mmsList = [listTyp];

      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.checkMmsListCbSelectedItem))(ArgumentMatchers.any)
        .afterReturn(listTyp);
      mocker.mockFunc(ConversationDataSource.getInstance(), ConversationDataSource.getInstance().refresh);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.setSelectStatus);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.setMessageCheckAll);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.setGroupMoreMenu);

      mConversationCtrl.more();

      expect(mConversationCtrl.hasReport).assertFalse();
      mocker.clear(mConversationCtrl);
      mocker.clear(ConversationDataSource.getInstance());
    })

    it('ConversationControllerTest_more_isCbChecked_true_isMsm_false', 0, () => {
      let listTyp: mmsListType = new mmsListType();
      listTyp.isCbChecked = true;
      listTyp.isMsm = false;
      listTyp.hasReport = false;
      listTyp.isShowMsgLongMenu = false;
      mConversationCtrl.mmsList = [listTyp];

      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.checkMmsListCbSelectedItem))(ArgumentMatchers.any)
        .afterReturn(listTyp);
      mocker.mockFunc(ConversationDataSource.getInstance(), ConversationDataSource.getInstance().refresh);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.setSelectStatus);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.setMessageCheckAll);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.setGroupMoreMenu);

      mConversationCtrl.more();

      expect(mConversationCtrl.hasReport).assertFalse();
      mocker.clear(mConversationCtrl);
      mocker.clear(ConversationDataSource.getInstance());
    })

    it('ConversationControllerTest_setTabOperationStatus_false', 0, () => {
      mConversationCtrl.setTabOperationStatus(false);

      expect(mConversationCtrl.sendBarMarginBottom).assertEqual(0);
    })

    it('ConversationControllerTest_setTabOperationStatus_true', 0, () => {
      mConversationCtrl.setTabOperationStatus(true);

      expect(mConversationCtrl.sendBarMarginBottom).assertEqual(550);
    })

    it('ConversationControllerTest_setSelectStatus', 0, () => {
      mConversationCtrl.setSelectStatus(true);

      expect(mConversationCtrl.isSelectStatus).assertTrue();
    })

    it('ConversationControllerTest_mmsListLongPress_isSelectStatus_true', 0, () => {
      mConversationCtrl.isSelectStatus = true;
      let listTyp: mmsListType = new mmsListType();
      listTyp.isCbChecked = false;
      listTyp.isMsm = true;
      listTyp.hasReport = false;
      listTyp.isShowMsgLongMenu = false;
      mConversationCtrl.mmsList = [listTyp, listTyp];

      mocker.mockFunc(mConversationCtrl, mConversationCtrl.setMessageCheckAll);

      mConversationCtrl.mmsListLongPress(0);

      expect(mConversationCtrl.mmsIndex).assertEqual(0);
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_mmsListLongPress_isSelectStatus_false_isMsm_true', 0, () => {
      mConversationCtrl.isSelectStatus = false;
      let listTyp: mmsListType = new mmsListType();
      listTyp.isCbChecked = false;
      listTyp.isMsm = true;
      listTyp.hasReport = false;
      listTyp.isShowMsgLongMenu = false;
      mConversationCtrl.mmsList = [listTyp];

      mocker.mockFunc(mConversationCtrl, mConversationCtrl.setMessageCheckAll);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.setGroupMoreMenu);

      mConversationCtrl.mmsListLongPress(0);

      expect(mConversationCtrl.hasImage).assertFalse();
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_mmsListLongPress_isSelectStatus_false_isMsm_false', 0, () => {
      mConversationCtrl.isSelectStatus = false;
      let listTyp: mmsListType = new mmsListType();
      listTyp.isCbChecked = false;
      listTyp.isMsm = false;
      listTyp.hasReport = false;
      listTyp.isShowMsgLongMenu = false;
      mConversationCtrl.mmsList = [listTyp];

      mocker.mockFunc(mConversationCtrl, mConversationCtrl.setGroupMoreMenu);

      mConversationCtrl.mmsListLongPress(0);

      expect(mConversationCtrl.audioStatus).assertEqual(-1);
      mocker.clear(mConversationCtrl);
      mocker.clear(ConversationDataSource.getInstance());
    })

    it('ConversationControllerTest_mmsListLongPress_index_1', 0, () => {
      mConversationCtrl.isSelectStatus = false;
      let listTyp: mmsListType = new mmsListType();
      listTyp.isCbChecked = false;
      listTyp.isMsm = false;
      listTyp.hasReport = false;
      listTyp.isShowMsgLongMenu = false;
      mConversationCtrl.mmsList = [listTyp];

      mConversationCtrl.mmsListLongPress(0);

      expect(mConversationCtrl.audioStatus).assertEqual(-1);
    })

    it('ConversationControllerTest_setNewMessageStatus_length_0', 0, () => {
      mConversationCtrl.mmsList = [];

      mocker.mockFunc(mConversationCtrl, mConversationCtrl.initNewPageContacts);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.changeReceiveInputStatus);

      mConversationCtrl.setNewMessageStatus();

      expect(mConversationCtrl.isNewMsg).assertTrue();
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_setNewMessageStatus_length_1', 0, () => {
      let listTyp: mmsListType = new mmsListType();
      listTyp.isCbChecked = false;
      listTyp.isMsm = false;
      listTyp.hasReport = false;
      listTyp.isShowMsgLongMenu = false;
      mConversationCtrl.mmsList = [listTyp];

      mConversationCtrl.setNewMessageStatus();

      expect(mConversationCtrl.isNewMsg).assertTrue();
    })

    it('ConversationControllerTest_deleteMessageByMsgId_mmsItem_undefined', 0, () => {
      mocker.mockFunc(ConversationService.getInstance(), ConversationService.getInstance().deleteSmsMmsInfoByCondition);
      mConversationCtrl.deleteMessageByMsgId(context, '');
      expect(mConversationCtrl.isNewMsg).assertTrue();
      mocker.clear(ConversationService.getInstance());
    })

    it('ConversationControllerTest_deleteMessageByMsgId_groupId_undefined', 0, () => {
      mocker.mockFunc(ConversationService.getInstance(), ConversationService.getInstance().deleteSmsMmsInfoByCondition);
      mConversationCtrl.deleteMessageByMsgId(context, '', {
        groupId: undefined
      } as LooseObject);
      expect(mConversationCtrl.isNewMsg).assertTrue();
      mocker.clear(ConversationService.getInstance());
    })

    it('ConversationControllerTest_deleteMessageByMsgId_isRcs_1', 0, () => {
      mocker.mockFunc(ConversationService.getInstance(), ConversationService.getInstance().deleteSmsMmsInfoByCondition);
      mConversationCtrl.deleteMessageByMsgId(context, '', {
        groupId: 1,
        isRcs: 1
      } as LooseObject);
      expect(mConversationCtrl.isNewMsg).assertTrue();
      mocker.clear(ConversationService.getInstance());
    })

    it('ConversationControllerTest_deleteMessageByMsgId_isRcs_0', 0, () => {
      mocker.mockFunc(ConversationService.getInstance(), ConversationService.getInstance().deleteSmsMmsInfoByCondition);
      mConversationCtrl.deleteMessageByMsgId(context, '', {
        groupId: 1,
        isRcs: 0
      } as LooseObject);
      expect(mConversationCtrl.isNewMsg).assertTrue();
      mocker.clear(ConversationService.getInstance());
    })

    it('ConversationControllerTest_deleteMessageByMsgId_isRcs_minus1', 0, () => {
      let listTyp: mmsListType = new mmsListType();
      listTyp.isCbChecked = false;
      listTyp.isMsm = false;
      listTyp.hasReport = false;
      listTyp.isShowMsgLongMenu = false;
      listTyp.isRcs = -1;
      mConversationCtrl.mmsList = [listTyp];

      mocker.mockFunc(ConversationListController.getInstance(),
        ConversationListController.getInstance().resetLastIndexValue);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.selectStatusOnDeleteMsg);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.cancelCheckedAll);

      mConversationCtrl.deleteDialogConfirm(context);
      expect(mConversationCtrl.mmsIndex).assertEqual(0);
      mocker.clear(ConversationListController.getInstance());
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_deleteMessageByMsgId_isRcs_0_mmsListLength_2', 0, () => {
      let listTyp: mmsListType = new mmsListType();
      listTyp.isCbChecked = false;
      listTyp.isMsm = false;
      listTyp.hasReport = false;
      listTyp.isShowMsgLongMenu = false;
      listTyp.isRcs = 0;
      listTyp.msgItemIndex = 0;
      mConversationCtrl.mmsList = [listTyp, listTyp];
      mConversationCtrl.isSelectStatus = false;
      mConversationCtrl.mmsIndex = 0;

      mocker.mockFunc(ConversationListController.getInstance(),
        ConversationListController.getInstance().resetLastIndexValue);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.setDateShow);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.cancelCheckedAll);
      mocker.mockFunc(ConversationDataSource.getInstance(), ConversationDataSource.getInstance().deleteByIndex);
      mocker.mockFunc(ConversationDataSource.getInstance(), ConversationDataSource.getInstance().notifyDataReload);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.updateLastItemContent);

      mConversationCtrl.deleteDialogConfirm(context);
      expect(mConversationCtrl.mmsIndex).assertEqual(0);
      mocker.clear(ConversationListController.getInstance());
      mocker.clear(ConversationDataSource.getInstance());
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_deleteMessageByMsgId_isRcs_0_mmsListLength_0', 0, () => {
      let listTyp: mmsListType = new mmsListType();
      listTyp.isCbChecked = false;
      listTyp.isMsm = false;
      listTyp.hasReport = false;
      listTyp.isShowMsgLongMenu = false;
      listTyp.isRcs = 0;
      listTyp.msgItemIndex = 0;
      mConversationCtrl.mmsList = [listTyp, listTyp];
      mConversationCtrl.isSelectStatus = false;
      mConversationCtrl.mmsIndex = 0;
      mConversationCtrl.textValue = '';

      mocker.mockFunc(ConversationListController.getInstance(),
        ConversationListController.getInstance().resetLastIndexValue);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.setDateShow);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.cancelCheckedAll);
      mocker.mockFunc(ConversationDataSource.getInstance(), ConversationDataSource.getInstance().deleteByIndex);
      mocker.mockFunc(ConversationDataSource.getInstance(), ConversationDataSource.getInstance().notifyDataReload);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.deleteMessageById);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.pageNeedChange);

      mConversationCtrl.deleteDialogConfirm(context);
      expect(mConversationCtrl.mmsIndex).assertEqual(0);
      mocker.clear(ConversationListController.getInstance());
      mocker.clear(ConversationDataSource.getInstance());
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_showReportToast', 0, () => {
      mConversationCtrl.showReportToast('', 0);
      expect(mConversationCtrl.mmsIndex).assertEqual(0);
    })

    it('ConversationControllerTest_createNewSourcePath_9', 0, () => {
      let addressInfo = new AddressInfo(1, 1, 'name', 'address');
      let mmsSource: mmsSourceItem[] = [{
        mms: [{
          type: 10,
          path: '',
          name: '',
          address: addressInfo,
        } as Mms],
        content: ''
      } as mmsSourceItem];
      let res = false;
      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.readFileContent))(ArgumentMatchers.any)
        .afterAction(() => {
          res = true;
        });

      mConversationCtrl.createNewSourcePath(context, mmsSource, false, '');

      expect(res).assertFalse();
      mocker.clear(mConversationCtrl);
    })
  })
}