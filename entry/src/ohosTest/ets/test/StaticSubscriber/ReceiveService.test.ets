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
import { ArgumentMatchers, beforeEach, describe, expect, it, MockKit, when } from '@ohos/hypium';
import ReceiveService, { RcsMessage } from '../../../../main/ets/StaticSubscriber/ReceiveService';
import {
  AbilityResult,
  BaseAbilityResult,
  BaseDataParameters,
  Contact,
  ContactType,
  DataParameters,
  MessageDetail,
  sessionResult,
} from '../../../../main/ets/utils/TypesUtils';
import DotUtil from '../../../../main/ets/utils/MmsDot/DotUtils';
import { DTGlobalContext } from '../../testability/TestAbility';
import DataShareHelper from '../../../../main/ets/model/repository/DataShareHelper';
import { dataShare, dataSharePredicates, DataShareResultSet, ValuesBucket } from '@kit.ArkData';
import LooseObject from '../../../../main/ets/data/LooseObject';
import HiLog from '../../../../main/ets/utils/HiLog';
import mmsUtilCtr from '../../../../main/ets/utils/MmsUtil';
import { Response, BaseResponse } from '../../../../main/ets/utils/TypesUtils';
import commonData from '../../../../main/ets/data/commonData';
import { resourceManager } from '@kit.LocalizationKit';
import ResourceUtils from '../../../../main/ets/utils/ResourceUtils';
import { GlobalContext } from '../../../../main/ets/MainAbility/GlobalHelper';
import { window } from '@kit.ArkUI';
import ConversationListService from '../../../../main/ets/service/ConversationListService';
import NotificationService from '../../../../main/ets/service/NotificationService';
import oobeResult from '../../../../main/ets/oobe/oobeResult';
import SharedPreferencesUtils from '../../../../main/ets/utils/SharedPreferencesUtils';
import myCommon from '@ohos.app.ability.common';
import { StartOptions } from '@kit.AbilityKit';
import common from '../../../../main/ets/data/commonData';
import { AudioPlayerService } from '../../../../main/ets/service/AudioPlayerService';
import { BusinessError, StaticSubscriberExtensionContext } from '@kit.BasicServicesKit';
import commonService from '../../../../main/ets/service/CommonService';
import SsmUtils from '../../../../main/ets/utils/SsmUtils';
import ConversationService from '../../../../main/ets/service/ConversationService';
import { SessionContactInfoForDB } from '../../../../main/ets/pages/conversation/conversationController';
import {
  BotMessage,
  ChatbotCardContent,
  ChatbotCardMessageType, ChatbotParameters,
  RcsChatbotServiceKind } from '../../../../main/ets/chatbot/utils/ChatbotEntitys';
import SettingsDataUtils from '../../../../main/ets/utils/SettingsDataUtils';
import MmsRingtoneManager from '../../../../main/ets/utils/SystemSoundManagerUtil';

export default function receiveServiceTest() {
  describe('receiveServiceTest', () => {

    const TAG: string = 'ReceiveService';
    let receiveService: ReceiveService;

    beforeEach(() => {
      receiveService = ReceiveService.getInstance();
    })


    it('receiveServiceTest_extractFileName_if', 0, () => {
      let result: string = receiveService.extractFileName('path/xxx');
      expect(result).assertEqual('xxx');
    })

    it('receiveServiceTest_extractFileName_else', 0, () => {
      let result: string = receiveService.extractFileName('path');
      expect(result).assertEqual('path');
    })


    it('receiveServiceTest_addData_msgType_1', 0, () => {
      let context = {
        resourceManager: {
          getStringSync: (resource: Resource, ...args: (string | number)[]): string => ''
        } as resourceManager.ResourceManager
      } as Context;
      let data: DataParameters = {
        data: 'RCS_RECEIVE_FILE_FAILED',
        parameters: {
          msgId: '1',
          isShow: true,
          mobilePhoneNumber: '570977632',
          action: '',
          isCdma: false,
          isNotificationFlag: false,
          moduleName: '',
          pdus: [],
          slotId: 0,
          id: 0,
          telephone: '570977632',
          type: '',
          code: 0,
          status: '',
          clurSize: 0,
          totalSize: 1,
          fileName: '',
          filePath: '',
          fileType: '',
          duration: '',
          isFlashMessage: false,
          serviceKind: 0
        } as BaseDataParameters,
        bundleName: '',
        code: 0,
        event: '',
        isFirstUnlocked: false,
        isAfterNoReadButton: false,
        isAfterReSendNotification: false,
        deliveryTime: 0
      };
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(mmsUtilCtr, mmsUtilCtr.checkAdvancedMode))().afterReturn(true);
      mocker.mockFunc(receiveService, receiveService.publishAcceptFailureEvent);
      when(mocker.mockFunc(ResourceUtils, ResourceUtils.getStringSync))(ArgumentMatchers.any).afterReturn('');
      mocker.mockFunc(receiveService, receiveService.handleSendMsgWithRepairMode);

      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('mmsStaticContext')
        .afterReturn({
          startAbility:(want: Want): Promise<void> => {
            return new Promise<void>(resolve => resolve());
          }
        } as StaticSubscriberExtensionContext);

      receiveService.addData({
        dstFileName: '',
        data: data,
        rcsMessageValue: {
          msgId: '',
          slotId: 0,
          address: 'address',
          date: '',
          content: ''
        } as RcsMessage,
        msgType: 1,
        fileSize: '',
        remainingSpace: 30,
        context: context,
        chatbotParameters: undefined
      });

      mocker.verify('checkAdvancedMode', []).once();

      when(mocker.mockFunc(mmsUtilCtr, mmsUtilCtr.checkAdvancedMode))().afterReturn(false);
      receiveService.addData({
        dstFileName: '',
        data: data,
        rcsMessageValue: {
          msgId: '',
          slotId: 0,
          address: 'address',
          date: '',
          content: ''
        } as RcsMessage,
        msgType: 8,
        fileSize: '',
        remainingSpace: 30,
        context: context,
        chatbotParameters: undefined
      });
      mocker.verify('checkAdvancedMode', []).once();

      receiveService.addData({
        dstFileName: '',
        data: data,
        rcsMessageValue: {
          msgId: '',
          slotId: 0,
          address: 'address',
          date: '',
          content: ''
        } as RcsMessage,
        msgType: 9,
        fileSize: '',
        remainingSpace: 30,
        context: context,
        chatbotParameters: undefined
      });

      mocker.verify('checkAdvancedMode', []).once();

      receiveService.addData({
        dstFileName: '132154654316554654654654513',
        data: data,
        rcsMessageValue: {
          msgId: '',
          slotId: 0,
          address: 'address',
          date: '',
          content: ''
        } as RcsMessage,
        msgType: 2,
        fileSize: '',
        remainingSpace: 19,
        context: context,
        chatbotParameters: undefined
      });
      mocker.verify('checkAdvancedMode', []).once();
      let botMessage: BotMessage = {
        message: {
          generalPurposeCard: {
            content: {
              title: 'aa'
            }
          }
        }
      }
      let chatbotParam: ChatbotParameters = new ChatbotParameters();
      chatbotParam.isChatbotMessage = true;
      chatbotParam.isNotifyUserMessage = true;
      chatbotParam.cardType = ChatbotCardMessageType.SINGLE_CARD;
      chatbotParam.mmsSource = [];
      chatbotParam.cardContent = botMessage;
      receiveService.addData({
        dstFileName: '',
        data: data,
        rcsMessageValue: {
          msgId: '',
          slotId: 0,
          address: 'address',
          date: '',
          content: ''
        } as RcsMessage,
        msgType: 11,
        fileSize: '',
        remainingSpace: 30,
        context: context,
        chatbotParameters: chatbotParam
      });
      mocker.verify('checkAdvancedMode', []).once();
      chatbotParam.cardType = ChatbotCardMessageType.MULTI_CARD;
      receiveService.addData({
        dstFileName: '',
        data: data,
        rcsMessageValue: {
          msgId: '',
          slotId: 0,
          address: 'address',
          date: '',
          content: ''
        } as RcsMessage,
        msgType: 11,
        fileSize: '',
        remainingSpace: 30,
        context: context,
        chatbotParameters: chatbotParam
      });
      mocker.verify('checkAdvancedMode', []).once();
      chatbotParam.cardType = undefined;
      receiveService.addData({
        dstFileName: '',
        data: data,
        rcsMessageValue: {
          msgId: '',
          slotId: 0,
          address: 'address',
          date: '',
          content: ''
        } as RcsMessage,
        msgType: 11,
        fileSize: '',
        remainingSpace: 30,
        context: context,
        chatbotParameters: chatbotParam
      });
      mocker.verify('checkAdvancedMode', []).once();
      receiveService.addData({
        dstFileName: '',
        data: data,
        rcsMessageValue: {
          msgId: '',
          slotId: 0,
          address: 'address',
          date: '',
          content: ''
        } as RcsMessage,
        msgType: 1,
        fileSize: '',
        remainingSpace: 30,
        context: context,
        chatbotParameters: chatbotParam
      });
      mocker.verify('checkAdvancedMode', []).once();

      mocker.clear(receiveService);
      mocker.clear(mmsUtilCtr);
      mocker.clear(ResourceUtils);
      mocker.clear(GlobalContext.getContext());
    })

    it('receiveServiceTest_addDataAfterClickPart_if', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();
      let initSmsDB: Function = mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB);
      when(initSmsDB)(context).afterReturn(undefined);

      mocker.mockFunc(receiveService, receiveService.updateRcsReceivedMmsInfoByConditionHandleCreate);
      when(mocker.mockFunc(receiveService, receiveService.extractFileName))('').afterReturn('');

      await receiveService.addDataAfterClickPart('', '', context);
      expect(context).not().assertUndefined();
      mocker.clear(receiveService);
    })

    it('receiveServiceTest_addDataAfterClickPart_noIf', 0, async () => {
      let context = {
        resourceManager: {
          getStringSync: (resource: Resource, ...args: (string | number)[]): string => ''
        } as resourceManager.ResourceManager,
        filesDir:'x'
      } as Context;

      let mocker: MockKit = new MockKit();
      let dataHelper: dataShare.DataShareHelper = {} as dataShare.DataShareHelper;

      let initSmsDB: Function = mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB);
      when(initSmsDB)(context)
        .afterReturn(new Promise<dataShare.DataShareHelper | undefined>(resolve => resolve(dataHelper)));

      mocker.mockFunc(receiveService, receiveService.updateRcsReceivedMmsInfoByConditionHandleCreate);
      when(mocker.mockFunc(receiveService, receiveService.extractFileName))('').afterReturn('');

      await receiveService.addDataAfterClickPart('', '', context);
      expect(context).not().assertUndefined();
      mocker.clear(receiveService);
    })

    it('receiveServiceTest_addDataAfterClickNext_if1_if2_audioTime_10', 0, async () => {
      let context = {
        resourceManager: {
          getStringSync: (resource: Resource, ...args: (string | number)[]): string => ''
        } as resourceManager.ResourceManager
      } as Context;
      let data: DataParameters = {
        data: 'RCS_RECEIVE_FILE_FAILED',
        parameters: {
          msgId: '1',
          isShow: true,
          mobilePhoneNumber: '570977632',
          action: '',
          isCdma: false,
          isNotificationFlag: false,
          moduleName: '',
          pdus: [],
          slotId: 0,
          id: 0,
          telephone: '570977632',
          type: '',
          code: 0,
          status: '',
          clurSize: 0,
          totalSize: 1,
          fileName: '',
          filePath: '',
          fileType: 'image/jpeg',
          duration: '10000',
          isFlashMessage: false,
          serviceKind: 0
        } as BaseDataParameters,
        bundleName: '',
        code: 0,
        event: '',
        isFirstUnlocked: false,
        isAfterNoReadButton: false,
        isAfterReSendNotification: false,
        deliveryTime: 0
      };

      let mocker: MockKit = new MockKit();
      mocker.mockFunc(mmsUtilCtr, mmsUtilCtr.checkAdvancedMode);
      mocker.mockFunc(receiveService, receiveService.handleSendMsgWithRepairMode);

      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('mmsStaticContext')
        .afterReturn({
          startAbility:(want: Want): Promise<void> => {
            return new Promise<void>(resolve => resolve());
          }
        } as StaticSubscriberExtensionContext);

      await receiveService.addDataAfterClickNext('', data, {
        msgId: '',
        slotId: 0,
        address: '',
        date: '',
        content: ''
      }, 3, '', 21, context);
      expect(context).not().assertUndefined();
      mocker.verify('checkAdvancedMode', []).never();

      mocker.clear(mmsUtilCtr);
      mocker.clear(receiveService);
      mocker.clear(GlobalContext.getContext());
    })

    it('receiveServiceTest_addDataAfterClickNext_ifaudio_ifdur_nospace', 0, async () => {
      let context = {
        resourceManager: {
          getStringSync: (resource: Resource, ...args: (string | number)[]): string => ''
        } as resourceManager.ResourceManager
      } as Context;
      let data: DataParameters = {
        data: 'RCS_RECEIVE_FILE_FAILED',
        parameters: {
          msgId: '1',
          isShow: true,
          mobilePhoneNumber: '570977632',
          action: '',
          isCdma: false,
          isNotificationFlag: false,
          moduleName: '',
          pdus: [],
          slotId: 0,
          id: 0,
          telephone: '570977632',
          type: '',
          code: 0,
          status: '',
          clurSize: 0,
          totalSize: 1,
          fileName: '',
          filePath: '',
          fileType: 'image/jpeg',
          duration: '10000',
          isFlashMessage: false,
          serviceKind: 0
        } as BaseDataParameters,
        bundleName: '',
        code: 0,
        event: '',
        isFirstUnlocked: false,
        isAfterNoReadButton: false,
        isAfterReSendNotification: false,
        deliveryTime: 0
      };
      let mocker = new MockKit();
      when(mocker.mockFunc(ResourceUtils, ResourceUtils.getStringSync))(ArgumentMatchers.any).afterReturn('');

      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('mmsStaticContext')
        .afterReturn({
          startAbility:(want: Want): Promise<void> => {
            return new Promise<void>(resolve => resolve());
          }
        } as StaticSubscriberExtensionContext);

      await receiveService.addDataAfterClickNext('', data, {
        msgId: '',
        slotId: 0,
        address: '',
        date: '',
        content: ''
      }, commonData.ENHANCED_INFO_ITEM_TYPE.AUDIO, '', 30, context);
      expect(context).not().assertUndefined();
      mocker.clear(ResourceUtils);
      mocker.clear(GlobalContext.getContext());
    })

    it('receiveServiceTest_addDataAfterClickNext_ifvcard_ifnodur_nospace', 0, async () => {
      let context = {
        resourceManager: {
          getStringSync: (resource: Resource, ...args: (string | number)[]): string => ''
        } as resourceManager.ResourceManager,

      } as Context;
      let data: DataParameters = {
        data: 'RCS_RECEIVE_FILE_FAILED',
        parameters: {
          msgId: '1',
          isShow: true,
          mobilePhoneNumber: '570977632',
          action: '',
          isCdma: false,
          isNotificationFlag: false,
          moduleName: '',
          pdus: [],
          slotId: 0,
          id: 0,
          telephone: '570977632',
          type: '',
          code: 0,
          status: '',
          clurSize: 0,
          totalSize: 1,
          fileName: '',
          filePath: '',
          fileType: 'image/jpeg',
          duration: '0',
          isFlashMessage: false,
          serviceKind: 0
        } as BaseDataParameters,
        bundleName: '',
        code: 0,
        event: '',
        isFirstUnlocked: false,
        isAfterNoReadButton: false,
        isAfterReSendNotification: false,
        deliveryTime: 0
      };
      let mocker = new MockKit();
      when(mocker.mockFunc(ResourceUtils, ResourceUtils.getStringSync))(ArgumentMatchers.any).afterReturn('');

      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('mmsStaticContext')
        .afterReturn({
          startAbility:(want: Want): Promise<void> => {
            return new Promise<void>(resolve => resolve());
          }
        } as StaticSubscriberExtensionContext);

      await receiveService.addDataAfterClickNext('', data, {
        msgId: '',
        slotId: 0,
        address: '',
        date: '',
        content: ''
      }, commonData.ENHANCED_INFO_ITEM_TYPE.VCARD, '', 30, context);
      expect(context).not().assertUndefined();
      mocker.clear(ResourceUtils);
      mocker.clear(GlobalContext.getContext());
    })

    it('receiveServiceTest_addDataAfterClickNext_duration_minus1', 0, async () => {
      let context = {
        resourceManager: {
          getStringSync: (resource: Resource, ...args: (string | number)[]): string => ''
        } as resourceManager.ResourceManager
      } as Context;
      let data: DataParameters = {
        data: 'RCS_RECEIVE_FILE_FAILED',
        parameters: {
          msgId: '1',
          isShow: true,
          mobilePhoneNumber: '570977632',
          action: '',
          isCdma: false,
          isNotificationFlag: false,
          moduleName: '',
          pdus: [],
          slotId: 0,
          id: 0,
          telephone: '570977632',
          type: '',
          code: 0,
          status: '',
          clurSize: 0,
          totalSize: 1,
          fileName: '',
          filePath: '',
          fileType: 'image/jpeg',
          duration: '-1',
          isFlashMessage: false,
          serviceKind: 0
        } as BaseDataParameters,
        bundleName: '',
        code: 0,
        event: '',
        isFirstUnlocked: false,
        isAfterNoReadButton: false,
        isAfterReSendNotification: false,
        deliveryTime: 0
      };
      let mocker = new MockKit();
      when(mocker.mockFunc(ResourceUtils, ResourceUtils.getStringSync))(ArgumentMatchers.any).afterReturn('');
      when(mocker.mockFunc(AudioPlayerService.getInstance(),
        AudioPlayerService.getInstance().getAudioDuration))(ArgumentMatchers.any)
        .afterReturn(new Promise<string>(resolve => resolve('70000')));
      when(mocker.mockFunc(mmsUtilCtr, mmsUtilCtr.checkAdvancedMode))().afterReturn(true);
      let res = false;
      when(mocker.mockFunc(receiveService, receiveService.handleSendMsgWithRepairMode))(ArgumentMatchers.any)
        .afterAction(() => {
          res = true;
        });

      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('mmsStaticContext')
        .afterReturn({
          startAbility:(want: Want): Promise<void> => {
            return new Promise<void>(resolve => resolve());
          }
        } as StaticSubscriberExtensionContext);

      await receiveService.addDataAfterClickNext('', data, {
        msgId: '',
        slotId: 0,
        address: '',
        date: '',
        content: ''
      }, commonData.ENHANCED_INFO_ITEM_TYPE.AUDIO, '', 30, context);
      expect(context).not().assertUndefined();
      expect(res).assertFalse();
      mocker.clear(mmsUtilCtr);
      mocker.clear(AudioPlayerService.getInstance());
      mocker.clear(GlobalContext.getContext());
      mocker.clear(ResourceUtils);
      mocker.clear(receiveService);
    })

    it('receiveServiceTest_addDataAfterClickNext_audioDuration_9', 0, async () => {
      let context = {
        resourceManager: {
          getStringSync: (resource: Resource, ...args: (string | number)[]): string => ''
        } as resourceManager.ResourceManager
      } as Context;
      let data: DataParameters = {
        data: 'RCS_RECEIVE_FILE_FAILED',
        parameters: {
          msgId: '1',
          isShow: true,
          mobilePhoneNumber: '570977632',
          action: '',
          isCdma: false,
          isNotificationFlag: false,
          moduleName: '',
          pdus: [],
          slotId: 0,
          id: 0,
          telephone: '570977632',
          type: '',
          code: 0,
          status: '',
          clurSize: 0,
          totalSize: 1,
          fileName: '',
          filePath: '',
          fileType: 'image/jpeg',
          duration: '-1',
          isFlashMessage: false,
          serviceKind: 0
        } as BaseDataParameters,
        bundleName: '',
        code: 0,
        event: '',
        isFirstUnlocked: false,
        isAfterNoReadButton: false,
        isAfterReSendNotification: false,
        deliveryTime: 0
      };
      let mocker = new MockKit();
      when(mocker.mockFunc(ResourceUtils, ResourceUtils.getStringSync))(ArgumentMatchers.any).afterReturn('');
      when(mocker.mockFunc(AudioPlayerService.getInstance(),
        AudioPlayerService.getInstance().getAudioDuration))(ArgumentMatchers.any)
        .afterReturn(new Promise<string>(resolve => resolve('9000')));
      when(mocker.mockFunc(mmsUtilCtr, mmsUtilCtr.checkAdvancedMode))().afterReturn(true);
      let res = false;
      when(mocker.mockFunc(receiveService, receiveService.handleSendMsgWithRepairMode))(ArgumentMatchers.any)
        .afterAction(() => {
          res = true;
        });

      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('mmsStaticContext')
        .afterReturn({
          startAbility:(want: Want): Promise<void> => {
            return new Promise<void>(resolve => resolve());
          }
        } as StaticSubscriberExtensionContext);

      await receiveService.addDataAfterClickNext('', data, {
        msgId: '',
        slotId: 0,
        address: 'sip:125200201211000319@botplatform.rcs.chinamobile.com',
        date: '',
        content: ''
      }, commonData.ENHANCED_INFO_ITEM_TYPE.AUDIO, '', 30, context);

      expect(res).assertFalse();
      mocker.clear(mmsUtilCtr);
      mocker.clear(AudioPlayerService.getInstance());
      mocker.clear(GlobalContext.getContext());
      mocker.clear(ResourceUtils);
      mocker.clear(receiveService);
    })


    it('receiveServiceTest_getVcardContactInfo', 0, async () => {
      let contactType: ContactType = new ContactType();
      contactType.contactName = 'name1';
      contactType.telephone = '582648254';
      contactType.telephoneFormat = '185 2586 4563';
      contactType.headImage = '';
      contactType.select = true;
      let contactArr: ContactType[] = [contactType];

      let vcard: string = 'BEGIN:VCARD\nPHOTO:456\nPATH:src\nFN:001.\nTEL:002.37\nVERSION:0.1\nPHOTO;\n=768END:VCARDer';
      let res = (receiveService as object)['getVcardContactInfo'](vcard, contactArr) as string;
      expect(res.length >= 1).assertTrue();
    })


    it('receiveServiceTest_dealSmsReceiveData_if', 0, () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let data: DataParameters = {
        data: 'TEXT_RCS_RECEIVE',
        parameters: {
          msgId: '1',
          isShow: true,
          mobilePhoneNumber: '570977632',
          action: '',
          isCdma: false,
          isNotificationFlag: false,
          moduleName: '',
          pdus: [],
          slotId: 0,
          id: 0,
          telephone: '570977632',
          type: '',
          code: 0,
          status: '',
          clurSize: 0,
          totalSize: 1,
          fileName: '',
          filePath: '',
          fileType: '',
          duration: '',
          isFlashMessage: false,
          serviceKind: 0
        },
        bundleName: '',
        code: 0,
        event: '',
        isFirstUnlocked: false,
        isAfterNoReadButton: false,
        isAfterReSendNotification: false,
        deliveryTime: 0
      };
      let mocker: MockKit = new MockKit();

      receiveService.dealSmsReceiveData(data, context);
      expect(context).not().assertUndefined();
      mocker.verify('handleRcsReceive', [data, context]).once();

      mocker.clear(receiveService);
    })

    it('receiveServiceTest_dealSmsReceiveData_else', 0, () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let data: DataParameters = {
        data: 'EXT_RCS_READ_RECEIVE',
        parameters: {
          msgId: '1',
          isShow: true,
          mobilePhoneNumber: '570977632',
          action: '',
          isCdma: false,
          isNotificationFlag: false,
          moduleName: '',
          pdus: [],
          slotId: 0,
          id: 0,
          telephone: '570977632',
          type: '',
          code: 0,
          status: '',
          clurSize: 0,
          totalSize: 1,
          fileName: '',
          filePath: '',
          fileType: '',
          duration: '',
          isFlashMessage: false,
          serviceKind: 0
        },
        bundleName: '',
        code: 0,
        event: '',
        isFirstUnlocked: false,
        isAfterNoReadButton: false,
        isAfterReSendNotification: false,
        deliveryTime: 0
      };
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(receiveService, receiveService.handleSmsReceive);

      receiveService.dealSmsReceiveData(data, context);
      expect(context).not().assertUndefined();
      mocker.verify('handleSmsReceive', [data, context]).once();

      mocker.clear(receiveService);
    })


    it('receiveServiceTest_setReceiveLocIndo_if', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let chatbotParm: ChatbotParameters = {
        isChatbotMessage: true
      };
      let actionData: MessageDetail = new MessageDetail();
      actionData.chatbotParameters = chatbotParm;
      let rcsMessageValue: RcsMessage = {
        msgId: '1',
        slotId: 0,
        address: 'sip:125200201211000319@botplatform.rcs.chinamobile.com',
        date: '15928648325566522',
        content: '{"body":"aaaaaaaaaa","latitude":"39.959836","longitude":"116.31985","accuracy":"abc"}'
      };
      await receiveService.setReceiveLocIndo(actionData, rcsMessageValue, context);
      expect(context).not().assertUndefined();
    })

    it('receiveServiceTest_setReceiveLocIndo_else', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let chatbotParm: ChatbotParameters = {
        isChatbotMessage: false
      };
      let actionData: MessageDetail = new MessageDetail();
      actionData.chatbotParameters = chatbotParm;
      let rcsMessageValue: RcsMessage = {
        msgId: '1',
        slotId: 0,
        address: 'sip:125200201211000319@botplatform.rcs.chinamobile.com',
        date: '15928648325566522',
        content: '{"body":"aaaaaaaaaa","latitude":"39.959836","longitude":"116.31985","accuracy":"abc"}'
      };
      await receiveService.setReceiveLocIndo(actionData, rcsMessageValue, context);
      expect(context).not().assertUndefined();
    })

    it('receiveServiceTest_mergeSmsAndMmsMessageToChatbotSession_if', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let actionData: MessageDetail = new MessageDetail();
      actionData.telephone = 'sip:125200201211000319@botplatform.rcs.chinamobile.com';
      (receiveService as object)['mergeSmsAndMmsMessageToChatbotSession'](actionData, context);
      expect(context).not().assertUndefined();
    })

    it('receiveServiceTest_oobeNeedSendNotice_if', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let actionData: LooseObject = {
        smsType: 1,
        telephone: '125200201211000319'
      };
      (receiveService as object)['oobeNeedSendNotice'](false, actionData, context, false, true, 1);
      expect(context).not().assertUndefined();
    })

    it('receiveServiceTest_oobeNeedSendNotice_else', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let actionData: LooseObject = {
        smsType: 1,
        telephone: '125200201211000319'
      };
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(receiveService, receiveService.handleMsgList);
      (receiveService as object)['oobeNeedSendNotice'](true, actionData, context, false, true, 1);
      expect(context).not().assertUndefined();
      mocker.clear(receiveService);
    })

    it('receiveServiceTest_rcsSendReadReceipt', 0, () => {
      (receiveService as object)['rcsSendReadReceipt'](null);
      expect(receiveService).not().assertUndefined();
    })

    it('receiveServiceTest_convertStrArray_if', 0, () => {
      let result: Array<number> = receiveService.convertStrArray('57097763');

      expect(JSON.stringify(result)).assertEqual('[87,9,119,99]');
    })

    it('receiveServiceTest_convertStrArray_else', 0, () => {
      let result: Array<number> = receiveService.convertStrArray('570977631');

      expect(JSON.stringify(result)).assertEqual('[87,9,119,99,1]');
    })

    it('receiveServiceTest_sendNotification_success', 0, () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;

      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('mmsContext')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: 0, abilityResult: [{
                displayName: 'displayName'
              } as Contact]
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve());
          }
        } as object | window.WindowStage);
      let res = false;
      when(mocker.mockFunc(receiveService, receiveService.dealContactParams))(ArgumentMatchers.any).afterAction(() => {
        res = true;
        return {
          message: '',
          msgId: '',
          unreadTotal: 0,
          telephone: '',
          slotId: '',
          smsType: '',
          type: '0',
        } as LooseObject;
      });
      when(mocker.mockFunc(ConversationListService.getInstance(),
        ConversationListService.getInstance().statisticalData))(ArgumentMatchers.any)
        .afterAction(() => {
          expect(res).assertTrue();
        });
      receiveService.sendNotification({
        telephone: '570977632',
        msgId: 1,
        content: 'content',
        context: context,
        smsType: 0,
        isFlashMms: false,
        deliveryTime: 0,
        isFirstUnlocked: true,
        startTime: '1.0'
      }, context);
      mocker.clear(GlobalContext.getContext());

      when(mocker.mockFunc(ConversationListService.getInstance(),
        ConversationListService.getInstance().statisticalData))(ArgumentMatchers.any)
        .afterAction(() => {
          expect(res).assertFalse();
        });
      receiveService.sendNotification({
        telephone: '570977632',
        msgId: 1,
        content: 'content',
        context: context,
        smsType: 0,
        isFlashMms: false,
        deliveryTime: -1,
        isFirstUnlocked: false,
        startTime: ''
      }, context);
      expect(context).not().assertNull();
      mocker.clear(GlobalContext.getContext());
      mocker.clear(receiveService);
      mocker.clear(HiLog);
    })

    it('receiveServiceTest_sendNotification_fail', 0, () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('mmsContext')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: -1, abilityResult: []
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve());
          }
        } as object | window.WindowStage);

      let res = false;
      when(mocker.mockFunc(receiveService, receiveService.dealContactParams))(ArgumentMatchers.any).afterAction(() => {
        res = true;
        return {
          message: '',
          msgId: '',
          unreadTotal: 0,
          telephone: '',
          slotId: '',
          smsType: '',
          type: '0',
        } as LooseObject;
      });
      when(mocker.mockFunc(ConversationListService.getInstance(),
        ConversationListService.getInstance().statisticalData))(ArgumentMatchers.any)
        .afterAction(() => {
          expect(res).assertFalse();
        });

      receiveService.sendNotification({
        telephone: '570977632',
        msgId: 1,
        content: 'content',
        context: context,
        smsType: 0,
        isFlashMms: false,
        type: '',
        deliveryTime: 0,
        isFirstUnlocked: true,
        startTime: '1.0'
      }, context);
      expect().assertUndefined();
      mocker.clear(DataShareHelper.getInstance());
      mocker.clear(receiveService);
    })

    it('receiveServiceTest_sendNotification_noIf', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initContactDB))(context)
        .afterReturn({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve({
            rowCount: 0,
            goToNextRow: () => true,
            getString: (columnIndex: number) => '',
            getColumnIndex: (columnName: string) => 0
          } as DataShareResultSet))
        });

      mocker.mockFunc(HiLog, HiLog.i);

      mocker.mockFunc(receiveService, receiveService.noticeData);

      when(mocker.mockFunc(receiveService, receiveService.dealContactParams))(ArgumentMatchers.any).afterAction(() => {
        mocker.verify('i', [TAG, 'sendNotification, success']).once();
        return {} as LooseObject;
      });

      receiveService.sendNotification({
        telephone: '570977632',
        msgId: 1,
        content: 'content',
        context: context,
        smsType: 0,
        isFlashMms: false,
        type: '1',
        deliveryTime: 0,
        isFirstUnlocked: false,
        startTime: ''
      }, context);
      expect(context).not().assertUndefined();
      mocker.clear(GlobalContext.getContext());
      mocker.clear(receiveService);
      mocker.clear(HiLog);
    })

    it('receiveServiceTest_noticeData_SUCCESS', 0, () => {
      let context: myCommon.UIAbilityContext = {
        startAbility: (want: Want, options?: StartOptions | undefined): Promise<void> => {
          return new Promise<void>(resolve => resolve());
        }
      } as myCommon.UIAbilityContext;
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(NotificationService.getInstance(context),
        NotificationService.getInstance(context).setBadgeNumber);
      when(mocker.mockFunc(oobeResult.getInstance(),
        oobeResult.getInstance().getMmsNoticeOobeFromUI))(ArgumentMatchers.any)
        .afterReturn(false);
      let getFromPreferences: Function =
        mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences);
      when(getFromPreferences)('notificationIsShow').afterReturn(false);
      when(getFromPreferences)('currentThreadId').afterReturn('570977632');
      mocker.mockFunc(NotificationService.getInstance(context), NotificationService.getInstance(context).sendNotify);
      mocker.mockFunc(DotUtil.getInstance(), DotUtil.getInstance().reportEvent);
      mocker.mockFunc(receiveService, receiveService.reduceEfficiencyResources);

      receiveService.noticeData({
        code: 0, response: {
          totalListCount: 0,
          unreadCount: 0,
          unreadTotalOfInfo: 0
        } as BaseResponse
      } as Response, {
        telephone: '570977632'
      }, context);

      when(getFromPreferences)('notificationIsShow').afterReturn(true);
      mocker.mockFunc(receiveService, receiveService.rcsSendReadReceipt);
      when(getFromPreferences)('msgList').afterReturn([1]);
      receiveService.noticeData({
        code: 0, response: {
          totalListCount: 0,
          unreadCount: 0,
          unreadTotalOfInfo: 0
        } as BaseResponse
      } as Response, {
        telephone: '570977632'
      }, context);

      mocker.clear(NotificationService.getInstance(context));
      mocker.clear(SharedPreferencesUtils);
      mocker.clear(oobeResult.getInstance());
      mocker.clear(receiveService);
      AppStorage.clear();
    })

    it('receiveServiceTest_noticeData_fail', 0, () => {
      let context: myCommon.UIAbilityContext = {
        startAbility: (want: Want, options?: StartOptions | undefined): Promise<void> => {
          return new Promise<void>(resolve => resolve());
        }
      } as myCommon.UIAbilityContext;
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(receiveService, receiveService.reduceEfficiencyResources);

      receiveService.noticeData({
        code: -1, response: {
          totalListCount: 0,
          unreadCount: 0,
          unreadTotalOfInfo: 0
        } as BaseResponse
      } as Response, {
        telephone: '570977632'
      }, context);

      mocker.clear(receiveService);
      AppStorage.clear();
    })

    it('receiveServiceTest_dealContactParams', 0, () => {
      let telephone: string = '570977632';
      let contacts: Contact[] = [];
      let params: LooseObject[] = [{
        'telephone': telephone,
      }];
      let res: LooseObject = receiveService.dealContactParams(contacts, telephone);
      expect(res.contactObjects).assertEqual(JSON.stringify(params));
    })

    it('receiveServiceTest_dealContactParams_length_1', 0, () => {
      let telephone: string = '570977632';
      let contacts: Contact[] = [{
        displayName: 'name',
        detailInfo: 'info',
        rawContactId: '',
        id: 0
      }];
      let params: LooseObject[] = [{
        'contactName': contacts[0].displayName,
        'telephone': telephone,
        'telephoneFormat': contacts[0].detailInfo,
        'contactId': contacts[0].rawContactId
      }];
      let res: LooseObject = receiveService.dealContactParams(contacts, telephone);
      expect(res.contactObjects).assertEqual(JSON.stringify(params));
    })

    it('receiveServiceTest_handleNormalSMSForNoLockedScreen_if', 0, () => {
      let data: DataParameters = {
        data: 'RCS_SEND_FILE_CANCELED',
        parameters: {
          msgId: '1',
          isShow: true,
          mobilePhoneNumber: '570977632',
          action: '',
          isCdma: false,
          isNotificationFlag: false,
          moduleName: '',
          pdus: [],
          slotId: 0,
          id: 0,
          telephone: '570977632',
          type: '',
          code: 0,
          status: '',
          clurSize: 0,
          totalSize: 1,
          fileName: '',
          filePath: '',
          fileType: '',
          duration: '',
          isFlashMessage: false,
          serviceKind: 0
        } as BaseDataParameters,
        bundleName: '',
        code: 0,
        event: '',
        isFirstUnlocked: false,
        isAfterNoReadButton: false,
        isAfterReSendNotification: false,
        deliveryTime: 0
      };
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('mmsStaticContext')
        .afterReturn({
          startAbility:(want: Want): Promise<void> => {
            return new Promise<void>(resolve => resolve());
          }
        } as StaticSubscriberExtensionContext);
      receiveService.handleNormalSMSForNoLockedScreen(data);
      expect(data).not().assertNull();
      mocker.clear(GlobalContext.getContext());
    })

    it('receiveServiceTest_handleNormalSMSForNoLockedScreen_else', 0, () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('mmsStaticContext')
        .afterReturn({
          startAbility:(want: Want): Promise<void> => {
            return new Promise<void>(resolve => resolve());
          }
        } as StaticSubscriberExtensionContext);
      receiveService.handleNormalSMSForNoLockedScreen(null);
      expect(mocker).not().assertUndefined();
      mocker.clear(GlobalContext.getContext());
    })

    it('receiveServiceTest_startMmsAbilityAndSendNotify_if', 0, () => {
      let data: DataParameters = {
        data: 'RCS_SEND_FILE_CANCELED',
        parameters: {
          msgId: '1',
          isShow: true,
          mobilePhoneNumber: '570977632',
          action: '',
          isCdma: false,
          isNotificationFlag: false,
          moduleName: '',
          pdus: [],
          slotId: 0,
          id: 0,
          telephone: '570977632',
          type: '',
          code: 0,
          status: '',
          clurSize: 0,
          totalSize: 1,
          fileName: '',
          filePath: '',
          fileType: '',
          duration: '',
          isFlashMessage: false,
          serviceKind: 0
        } as BaseDataParameters,
        bundleName: '',
        code: 0,
        event: '',
        isFirstUnlocked: false,
        isAfterNoReadButton: false,
        isAfterReSendNotification: false,
        deliveryTime: 0
      };
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('mmsStaticContext')
        .afterReturn({
          startAbility:(want: Want): Promise<void> => {
            return new Promise<void>(resolve => resolve());
          }
        } as StaticSubscriberExtensionContext);
      receiveService.startMmsAbilityAndSendNotify(data);
      expect(data).not().assertUndefined();
      mocker.clear(GlobalContext.getContext());
    })

    it('receiveServiceTest_startMmsAbilityAndSendNotify_else', 0, () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('mmsStaticContext')
        .afterReturn({
          startAbility:(want: Want): Promise<void> => {
            return new Promise<void>(resolve => resolve());
          }
        } as StaticSubscriberExtensionContext);
      receiveService.startMmsAbilityAndSendNotify(null);
      expect().assertUndefined();
      mocker.clear(GlobalContext.getContext());
    })

    it('receiveServiceTest_reduceEfficiencyResources', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(receiveService, receiveService.releaseEfficiencyResources);
      receiveService.reduceEfficiencyResources();

      receiveService.releaseResourceNumber = 2;
      receiveService.reduceEfficiencyResources();
      expect(receiveService.releaseResourceNumber >= 0).assertTrue();
      expect().assertUndefined();
      mocker.clear(receiveService);
    })

    it('receiveServiceTest_judgeGeneralOrChatbot', 0, () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let data: MessageDetail = new MessageDetail();
      data.rcsMsgContent = '1';
      receiveService.judgeGeneralOrChatbot(2, data, context);
      expect(context).not().assertNull();
    })


    it('receiveServiceTest_addDataAfterClick_image', 0, () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let res = false;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(receiveService, receiveService.addDataAfterClickPart))(ArgumentMatchers.any)
        .afterAction(() => {
          res = true;
        });
      receiveService.addDataAfterClick('', {} as DataParameters, {} as RcsMessage, common.MSG_ITEM_TYPE.IMAGE, '', 0,
        context);
      expect(res).assertTrue();
      mocker.clear(receiveService);
    })

    it('receiveServiceTest_addDataAfterClick_audio', 0, () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let res = false;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(receiveService, receiveService.addDataAfterClickNext))(ArgumentMatchers.any)
        .afterAction(() => {
          res = true;
        });
      receiveService.addDataAfterClick('', {} as DataParameters, {} as RcsMessage, common.MSG_ITEM_TYPE.AUDIO, '', 0,
        context);
      expect(res).assertTrue();
      mocker.clear(receiveService);
    })


    it('receiveServiceTest_updateMsgCode_success', 0, () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(HiLog, HiLog.i))(TAG).afterAction(() => {
        mocker.verify('getObject', ['DataWorker']).never();
      });
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: 0
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve())
          }
        } as Object | window.WindowStage);
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let actionData: MessageDetail = new MessageDetail();
      actionData.verCode = '1.0';
      receiveService.updateMsgCode(actionData, context);
      expect(context).not().assertUndefined();
      mocker.clear(GlobalContext.getContext());
      mocker.clear(HiLog);
    })

    it('receiveServiceTest_updateMsgCode_rcs', 0, () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(HiLog, HiLog.i))(TAG).afterAction(() => {
        mocker.verify('getObject', ['DataWorker']).never();
      });
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: 0
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve())
          }
        } as Object | window.WindowStage);
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let actionData: MessageDetail = new MessageDetail();
      actionData.verCode = '1.0';
      actionData.type = 'rcs';
      actionData.rcsId = 1;
      receiveService.updateMsgCode(actionData, context);
      mocker.clear(GlobalContext.getContext());
      mocker.clear(HiLog);
    })

    it('receiveServiceTest_updateMsgCode_fail', 0, () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(HiLog, HiLog.i))(TAG).afterAction(() => {
        mocker.verify('getObject', ['DataWorker']).never();
      });
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: -1
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve())
          }
        } as Object | window.WindowStage);
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let actionData: MessageDetail = new MessageDetail();
      actionData.verCode = undefined;
      receiveService.updateMsgCode(actionData, context);
      expect(context).not().assertUndefined();
      mocker.clear(GlobalContext.getContext());
      mocker.clear(HiLog);
    })

    it('receiveServiceTest_handleNotification_isBlockMessageDetail_true', 0, () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let resultData: MessageDetail = new MessageDetail();
      let res: sessionResult = {} as sessionResult;
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.i);
      mocker.mockFunc(receiveService, receiveService.updateMsgCode);
      mocker.mockFunc(receiveService, receiveService.reduceEfficiencyResources);
      receiveService.handleNotification(resultData, res, context);
      expect(context).not().assertUndefined();
      mocker.clear(receiveService);
    })

    it('receiveServiceTest_handleNotification_id_0', 0, () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let resultData: MessageDetail = new MessageDetail();
      resultData.type = commonData.RCS_TYPE.RCS;
      resultData.rcsMsgContent = 'xx';
      resultData.telephone = '55555';
      resultData.slotId = 0;
      resultData.verCode = '1.1';
      resultData.type = '1';
      let res: sessionResult = {
        initDatas: [{}],
        smsType: 0,
      } as sessionResult;
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(receiveService, receiveService.updateMsgCode);
      let res1=false;
      when(mocker.mockFunc(receiveService, receiveService.sendNotification))(ArgumentMatchers.any).afterAction(()=>{
        res1=true;
      });
      mocker.mockFunc(receiveService, receiveService.publishData);
      receiveService.handleNotification(resultData, res, context);
      expect(res1).assertTrue();
      mocker.clear(receiveService);
    })

    it('receiveServiceTest_handleNotification_id_1', 0, () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let resultData: MessageDetail = new MessageDetail();
      resultData.type = commonData.RCS_TYPE.RCS_SEND;
      resultData.rcsMsgContent = 'xx';
      resultData.telephone = '55555';
      resultData.slotId = 0;
      resultData.verCode = '1.1';
      resultData.type = '1';
      let res: sessionResult = {
        initDatas: [{
          id: 1
        }],
        smsType: 0,
      } as sessionResult;
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(receiveService, receiveService.updateMsgCode);
      let res1=false;
      when(mocker.mockFunc(receiveService, receiveService.sendNotification))(ArgumentMatchers.any).afterAction(()=>{
        res1=true;
      });
      mocker.mockFunc(receiveService, receiveService.publishData);
      receiveService.handleNotification(resultData, res, context);
      expect(res1).assertTrue();
      mocker.clear(receiveService);
    })

    it('receiveServiceTest_handleNotification_rcs', 0, () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let resultData: MessageDetail = new MessageDetail();
      resultData.type = commonData.RCS_TYPE.RCS_SEND;
      resultData.rcsMsgContent = 'xx';
      resultData.telephone = 'sip:125200201211000319@botplatform.rcs.chinamobile.com';
      resultData.slotId = 0;
      resultData.verCode = '1.1';
      resultData.type = 'rcs';
      resultData.isBlocked = 0;
      resultData.blockedReason = 1001;
      resultData.blockedType = 1200;
      let res: sessionResult = {
        initDatas: [{
          id: 1,
          telephone: '',
          start_time: ''
        }],
        smsType: 0,
        rowId: 0,
        groupId: 0
      } as sessionResult;
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(receiveService, receiveService.updateMsgCode);
      let res1=false;
      when(mocker.mockFunc(receiveService, receiveService.sendNotification))(ArgumentMatchers.any).afterAction(()=>{
        res1=true;
      });
      mocker.mockFunc(receiveService, receiveService.publishData);
      receiveService.handleNotification(resultData, res, context);
      expect(res).not().assertNull();
      mocker.clear(receiveService);
    })

    it('receiveServiceTest_notContactDealYellowPageInfo', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let contactInfo: SessionContactInfoForDB = {
        rawContactId: '',
        contactName: '',
        contactPhone: '95588'
      } as SessionContactInfoForDB;
      (receiveService as object)['notContactDealYellowPageInfo'](contactInfo, context);
      expect(context).not().assertUndefined();
    })

    it('receiveServiceTest_insertMessageDetailBy', 0, () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let resultData: MessageDetail = new MessageDetail();
      resultData.content = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx';
      resultData.telephone = '55555';
      resultData.slotId = 0;
      resultData.isAdvancedSecurity = 0;
      resultData.msgType = common.int.RCS_FIRST_RECEIVING;
      resultData.mmsSource = [];
      resultData.type = commonData.RCS_TYPE.RCS;
      resultData.msgId = '1';
      resultData.rcsType = 0;
      resultData.clurSize = 0;
      resultData.totalSize = 0;
      resultData.isBlocked = 0;
      resultData.blockedReason = 0;
      resultData.blockedSources = '1';
      resultData.blockedType = 0;
      resultData.blockedTypeText = '0';

      let mocker: MockKit = new MockKit();
      let res=false;
      when(mocker.mockFunc(commonService, commonService.judgeIsAttachment))(ArgumentMatchers.any).afterReturn(true);
      when(mocker.mockFunc(receiveService, receiveService.queryContactByPhone))(ArgumentMatchers.any).afterReturn(
        new Promise<SessionContactInfoForDB>(resolve => resolve({} as SessionContactInfoForDB)));
      when(mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences))('notificationIsShow')
        .afterReturn(true);
      when(mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences))('currentThreadId')
        .afterReturn('55555');
      when(mocker.mockFunc(ConversationService.getInstance(), ConversationService.getInstance().insertSessionAndDetail))(ArgumentMatchers.any)
        .afterAction(()=>{
          res=true;
        });

      receiveService.insertMessageDetailBy(resultData, () => {
      }, context);
      expect(context).not().assertUndefined();
      mocker.clear(SsmUtils);
      mocker.clear(commonData);
      mocker.clear(ConversationService.getInstance());
      mocker.clear(SharedPreferencesUtils);
    })

    it('receiveServiceTest_insertMessageDetailBy2', 0, () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let resultData: MessageDetail = new MessageDetail();
      resultData.content = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx';
      resultData.telephone = '55555';
      resultData.slotId = 0;
      resultData.isAdvancedSecurity = 0;
      resultData.msgType = common.int.RCS_RECEIVING_CANCEL;
      resultData.mmsSource = [];
      resultData.type = commonData.RCS_TYPE.RCS_SEND;
      resultData.msgId = '1';
      resultData.rcsType = 0;
      resultData.clurSize = 0;
      resultData.totalSize = 0;
      resultData.isBlocked = 0;
      resultData.blockedReason = 0;
      resultData.blockedSources = '1';
      resultData.blockedType = 0;
      resultData.blockedTypeText = '0';

      let mocker: MockKit = new MockKit();
      let res=false;
      when(mocker.mockFunc(commonService, commonService.judgeIsAttachment))(ArgumentMatchers.any).afterReturn(true);
      when(mocker.mockFunc(ConversationService.getInstance(), ConversationService.getInstance().insertSessionAndDetail))(ArgumentMatchers.any)
        .afterAction(()=>{
          res=true;
        });
      when(mocker.mockFunc(receiveService, receiveService.queryContactByPhone))(ArgumentMatchers.any).afterReturn(
        new Promise<SessionContactInfoForDB>(resolve => resolve({} as SessionContactInfoForDB)));
      when(mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences))('notificationIsShow')
        .afterReturn(false);
      when(mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences))('currentThreadId')
        .afterReturn('55555');

      receiveService.insertMessageDetailBy(resultData, () => {
      }, context);

      expect(res).assertFalse();

      mocker.clear(SsmUtils);
      mocker.clear(commonData);
      mocker.clear(ConversationService.getInstance());
      mocker.clear(SharedPreferencesUtils);
    })

    it('receiveServiceTest_queryContactDataByConditionResult', 0, () => {
      let res: AbilityResult = {
        code: 0,
        abilityResult: [{
          rawContactId: '1',
          displayName: 'name1'
        } as Contact]
      } as AbilityResult;
      let contactInfo:SessionContactInfoForDB={
        rawContactId: '0',
        contactName: 'name', contactPhone: ''
      } as SessionContactInfoForDB;
      receiveService.queryContactDataByConditionResult(res, contactInfo);
      expect(contactInfo).not().assertUndefined();
    })

    it('receiveServiceTest_queryContactDataByConditionResult1', 0, () => {
      let res: AbilityResult = {
        code: 0,
        abilityResult: [{
        } as Contact]
      } as AbilityResult;
      let contactInfo:SessionContactInfoForDB={
        rawContactId: '0',
        contactName: 'name', contactPhone: ''
      } as SessionContactInfoForDB;
      receiveService.queryContactDataByConditionResult(res, contactInfo);
      expect(contactInfo).not().assertUndefined();
    })

    it('applyEfficiencyResourcesUnSetTimeOut_success', 0, () => {
      let mocker: MockKit = new MockKit();
      let num = receiveService.releaseResourceNumber;
      receiveService.applyEfficiencyResourcesUnSetTimeOut();
      let afterNum = receiveService.releaseResourceNumber;
      expect(afterNum).assertEqual(num + 1);
      mocker.clear(receiveService);
    })

    it('receiveServiceTest_queryContactDataByConditionResult2', 0, () => {
      let contactInfo:SessionContactInfoForDB={
        rawContactId: '0',
        contactName: 'name', contactPhone: ''
      } as SessionContactInfoForDB;
      let res: AbilityResult = {
        code: 0,
        abilityResult: []
      } as AbilityResult;
      receiveService.queryContactDataByConditionResult(res, contactInfo);
      expect(contactInfo.rawContactId).assertEqual('0');
    })

    it('receiveServiceTest_queryContactDataByConditionResult_if', 0, () => {
      let contactInfo:SessionContactInfoForDB={
        rawContactId: '0',
        contactName: 'name', contactPhone: ''
      } as SessionContactInfoForDB;
      let res: AbilityResult = {
        code: -1,
        abilityResult: []
      } as AbilityResult;
      receiveService.queryContactDataByConditionResult(res, contactInfo);
      expect(contactInfo.rawContactId).assertEqual('0');
    })

    it('receiveServiceTest_dealSmsReceiveData_2', 0, () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let data: DataParameters = {
        data: 'RCS_LOCATION_RECEIVE',
        parameters: {
          msgId: '1',
          isShow: true,
          mobilePhoneNumber: '570977632',
          action: '',
          isCdma: false,
          isNotificationFlag: false,
          moduleName: '',
          pdus: [],
          slotId: 0,
          id: 0,
          telephone: '570977632',
          type: '',
          code: 0,
          status: '',
          clurSize: 0,
          totalSize: 1,
          fileName: '',
          filePath: '',
          fileType: '',
          duration: '',
          isFlashMessage: false,
          serviceKind: 0
        },
        bundleName: '',
        code: 0,
        event: '',
        isFirstUnlocked: false,
        isAfterNoReadButton: false,
        isAfterReSendNotification: false,
        deliveryTime: 0
      };
      let mocker: MockKit = new MockKit();

      receiveService.dealSmsReceiveData(data, context);
      mocker.verify('handleRcsReceive', [data, context]).once();

      mocker.clear(receiveService);
    })

    it('ResourceUtilsTest_getStringSync', 0, () => {
      let context = {
        resourceManager: {
          getStringSync: (resource: Resource): string => 'ResourceUtilsTest_getStringSync'
        } as resourceManager.ResourceManager
      } as myCommon.Context;
      let res = ResourceUtils.getStringSync({} as Resource, context);
      expect(res).assertEqual('ResourceUtilsTest_getStringSync');
    })

    it('ResourceUtilsTest_getStringSync_context_null', 0, () => {
      let mocker: MockKit = new MockKit();
      let context = {
        resourceManager: {
          getStringSync: (resource: Resource): string => 'ResourceUtilsTest_getStringSync'
        } as resourceManager.ResourceManager
      } as myCommon.Context;
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('mmsContext')
        .afterReturn(context);
      let res = ResourceUtils.getStringSync({} as Resource);
      mocker.clear(GlobalContext.getContext())
      expect(res).assertEqual('ResourceUtilsTest_getStringSync');
    })

    it('ResourceUtilsTest_getStringByFile', 0, () => {
      ResourceUtils.getStringByFile(null, null);
      expect().assertUndefined();
    })

    it('SettingsDataUtilsTest_getInstance', 0, () => {
      SettingsDataUtils.getInstance();
      let instance = SettingsDataUtils.getInstance();
      expect(instance == null).assertFalse();
    })

    it('MmsRingtoneManagerTest_setSystemRingtoneUri', 0, () => {
      let context = {
        resourceManager: {
          getStringSync: (resource: Resource): string => 'ResourceUtilsTest_getStringSync'
        } as resourceManager.ResourceManager
      } as myCommon.UIAbilityContext;
      new MmsRingtoneManager().setSystemRingtoneUri(context, '', 0);
      new MmsRingtoneManager().setSystemRingtoneUri(context, '', 1);
      expect(context).not().assertUndefined();
    })

    it('receiveServiceTest_updateMarkInfoContactName', 0, () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(HiLog, HiLog.i))(TAG).afterAction(() => {
        mocker.verify('getObject', ['DataWorker']).never();
      });
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: 0
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve())
          }
        } as Object | window.WindowStage);
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      receiveService.updateMarkInfoContactName(context,'111', 'test');
      mocker.clear(GlobalContext.getContext());
      mocker.clear(HiLog);
    })
  })
}