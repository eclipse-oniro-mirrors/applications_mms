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
import ConversationController, {
  ActionDataType,
  InitData,
  mmsListType,
  selectContactType,
  BaseAbilityResult,
  MmsSourceType,
  pictureListFromGalleryType
} from '../../../../../main/ets/pages/conversation/conversationController';
import DataShareHelper from '../../../../../main/ets/model/repository/DataShareHelper';
import { dataShare } from '@kit.ArkData';
import ConversationDataSource from '../../../../../main/ets/model/ConversationDataSource';
import { AddressInfo, Mms, SessionContentTypeOfRcs } from '../../../../../main/ets/utils/TypesUtils';
import ConversationService from '../../../../../main/ets/service/ConversationService';
import MessageUtil from '../../../../../main/cust/utils/MessageUtil';
import ConversationListService from '../../../../../main/ets/service/ConversationListService';
import settingService from '../../../../../main/ets/service/SettingService';
import { DateUtil } from '../../../../../main/ets/utils/DateUtil';
import MmsUtil from '../../../../../main/ets/utils/MmsUtil';
import ConversationListController from '../../../../../main/ets/pages/conversationlist/conversationListController';
import MmsPreferences from '../../../../../main/ets/utils/MmsPreferences';
import SharedPreferencesUtils from '../../../../../main/ets/utils/SharedPreferencesUtils';
import DotUtil from '../../../../../main/ets/utils/MmsDot/DotUtils';
import MMAttachmentAreaController from '../../../../../main/ets/views/AttachmentArea/MMAttachmentAreaController';
import LooseObject from '../../../../../main/ets/data/LooseObject';
import { window } from '@kit.ArkUI';
import TelephoneUtil from '../../../../../main/ets/utils/TelephoneUtil';
import FileUtil from '../../../../../main/ets/utils/FileUtil';
import { DTGlobalContext } from '../../../testability/TestAbility';
import { ChatbotParameters } from '../../../../../main/ets/chatbot/utils/ChatbotEntitys';

export default function conversationControllerPart4Test() {
  describe('conversationControllerTest4', () => {

    let mConversationCtrl: ConversationController;
    let mocker: MockKit;
    let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;

    beforeEach(() => {
      mocker = new MockKit();
      ConversationController.release();
      mConversationCtrl = ConversationController.getInstance();
    })

    afterEach(() => {
      mocker.clear(mConversationCtrl);
      AppStorage.clear();
    })

    it('ConversationControllerTest_initSendParams', 0, () => {
      let actionData: ActionDataType = {
        slotId: 1,
        destinationHost: '',
        content: 'xx',
        isEditMms: false,
        contactId: '',
        contactName: '',
        hosts: ['', ''],
        isReSend: true,
        id: undefined,
        isRcs: 1,
        resendStateIsRcs: true,
        threadId: 1,
        groupId: 0,
      } as ActionDataType;

      let res: Record<string, number | number[] | string | boolean> =
        mConversationCtrl.initSendParams(actionData, '111111', 'xxx', 0);

      expect(res.slotId).assertEqual(1);
    })

    it('ConversationControllerTest_initSendResult', 0, () => {
      let initDatas: InitData[] = [];
      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.getSendMessageId))(ArgumentMatchers.any)
        .afterReturn(1);
      let res: Record<string, number | string[] | string> =
        mConversationCtrl.initSendResult(initDatas, '111111', 'xxx', 'xxx', {
          slotId: -1,
          destinationHost: '',
          content: '',
          isEditMms: false
        });
      expect(res.id).assertEqual(1);
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_initAndSend_isMms_false', 0, () => {
      let res = false;
      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.dealSmsSendResult))(ArgumentMatchers.any)
        .afterAction(() => {
          res = true;
        });
      let item: mmsListType = new mmsListType();
      item.isMsm = false;
      mConversationCtrl.initAndSend(context, item, {}, {}, 0, () => {
      });
      expect(res).assertTrue();
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_initAndSend_isMms_true', 0, () => {
      let res = false;
      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.dealSmsSendResult))(ArgumentMatchers.any)
        .afterAction(() => {
          res = true;
        });
      let item: mmsListType = new mmsListType();
      item.isMsm = true;
      mConversationCtrl.initAndSend(context, item, {}, {}, 0, () => {
      });
      expect(res).assertFalse();
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_insertInitData', 0, () => {
      let actionData: ActionDataType = {
        slotId: 1,
        destinationHost: '',
        content: 'xx',
        isEditMms: false,
        contactId: '1',
        contactName: 'xx',
        hosts: ['1111', '2222'],
        isReSend: true,
        id: undefined,
        isRcs: 1,
        resendStateIsRcs: true,
        threadId: 1,
        groupId: 0,
      } as ActionDataType;

      when(mocker.mockFunc(settingService, settingService.judgeIsDeliveryReport))(ArgumentMatchers.any)
        .afterReturn(true);

      let res = false;
      when(mocker.mockFunc(ConversationService.getInstance(),
        ConversationService.getInstance().insertSessionAndDetail))(ArgumentMatchers.any)
        .afterAction(() => {
          res = true;
        });
      let item: mmsListType = new mmsListType();
      item.isMsm = true;
      mConversationCtrl.insertInitData(context, actionData, new mmsListType(), () => {
      });

      expect(res).assertTrue();

      mocker.clear(settingService);
      mocker.clear(ConversationService.getInstance());
    })

    it('ConversationControllerTest_insertInitData2', 0, () => {
      let actionData: ActionDataType = {
        slotId: 1,
        destinationHost: '',
        content: 'xx',
        isEditMms: false,
        contactId: '1',
        contactName: 'xx',
        hosts: ['1111', '2222'],
        isReSend: true,
        id: undefined,
        isRcs: 1,
        resendStateIsRcs: true,
        threadId: 1,
        groupId: 0,
      } as ActionDataType;

      when(mocker.mockFunc(settingService, settingService.judgeIsDeliveryReport))(ArgumentMatchers.any)
        .afterReturn(false);

      let res = false;
      when(mocker.mockFunc(ConversationService.getInstance(),
        ConversationService.getInstance().insertSessionAndDetail))(ArgumentMatchers.any)
        .afterAction(() => {
          res = true;
        });
      let item: mmsListType = new mmsListType();
      item.isMsm = false;
      item.isRcs = 1;
      mConversationCtrl.insertInitData(context, actionData, item, () => {
      });
      expect(res).assertTrue();
      mocker.clear(settingService);
      mocker.clear(ConversationService.getInstance());
    })

    it('ConversationControllerTest_insertInitData_isRcs_0', 0, () => {
      let actionData: ActionDataType = {
        slotId: 1,
        destinationHost: '',
        content: 'xx',
        isEditMms: false,
        contactId: '1',
        contactName: 'xx',
        hosts: ['1111', '2222'],
        isReSend: true,
        id: undefined,
        isRcs: 0,
        resendStateIsRcs: false,
        threadId: 1,
        groupId: undefined,
      } as ActionDataType;

      when(mocker.mockFunc(settingService, settingService.judgeIsDeliveryReport))(ArgumentMatchers.any)
        .afterReturn(true);

      let res = false;
      when(mocker.mockFunc(ConversationService.getInstance(),
        ConversationService.getInstance().insertSessionAndDetail))(ArgumentMatchers.any)
        .afterAction(() => {
          res = true;
        });
      let item: mmsListType = new mmsListType();
      item.isMsm = true;
      mConversationCtrl.insertInitData(context, actionData, new mmsListType(), () => {
      });

      expect(res).assertTrue();

      mocker.clear(settingService);
      mocker.clear(ConversationService.getInstance());
    })

    it('ConversationControllerTest_buildTextSendItemOfEnhancedInfo_mmsEditList_empty', 0, () => {
      mConversationCtrl.mmsEditList = [];
      mConversationCtrl.contactsNum = 1;
      when(mocker.mockFunc(settingService, settingService.judgeIsDeliveryReport))(ArgumentMatchers.any)
        .afterReturn(true);
      mocker.mockFunc(DateUtil, DateUtil.convertTimeStampToDateWeek);
      mocker.mockFunc(DateUtil, DateUtil.fullDate);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.setDateShow);
      let item: mmsListType = mConversationCtrl.buildTextSendItemOfEnhancedInfo(true);
      expect(item.isRcs).assertEqual(1);
      mocker.clear(settingService);
      mocker.clear(DateUtil);
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_buildTextSendItemOfEnhancedInfo_mmsEditList_length_1_type_3', 0, () => {
      mConversationCtrl.mmsEditList = [{
        type: 3,
        uriPath: '',
        time: '',
        fileSize: 10
      } as MmsSourceType];
      mConversationCtrl.contactsNum = 1;

      when(mocker.mockFunc(settingService, settingService.judgeIsDeliveryReport))(ArgumentMatchers.any)
        .afterReturn(true);
      mocker.mockFunc(DateUtil, DateUtil.convertTimeStampToDateWeek);
      mocker.mockFunc(DateUtil, DateUtil.fullDate);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.setDateShow);

      let item: mmsListType = mConversationCtrl.buildTextSendItemOfEnhancedInfo(true);

      expect(item.isRcs).assertEqual(1);

      mocker.clear(settingService);
      mocker.clear(DateUtil);
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_buildTextSendItemOfEnhancedInfo_mmsEditList_length_1_type_5', 0, () => {
      mConversationCtrl.mmsEditList = [{
        type: 5,
        uriPath: '',
        time: '',
        fileSize: 10
      } as MmsSourceType];
      mConversationCtrl.contactsNum = 1;

      when(mocker.mockFunc(settingService, settingService.judgeIsDeliveryReport))(ArgumentMatchers.any)
        .afterReturn(true);
      mocker.mockFunc(DateUtil, DateUtil.convertTimeStampToDateWeek);
      mocker.mockFunc(DateUtil, DateUtil.fullDate);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.setDateShow);

      let item: mmsListType = mConversationCtrl.buildTextSendItemOfEnhancedInfo(true);

      expect(item.isRcs).assertEqual(1);

      mocker.clear(settingService);
      mocker.clear(DateUtil);
    })

    it('ConversationControllerTest_buildTextSendItemOfEnhancedInfo_mmsEditList_length_1_type_0', 0, () => {
      mConversationCtrl.mmsEditList = [{
        type: 0,
        uriPath: '',
        time: '',
        fileSize: 10
      } as MmsSourceType];
      mConversationCtrl.contactsNum = 2;

      when(mocker.mockFunc(settingService, settingService.judgeIsDeliveryReport))(ArgumentMatchers.any)
        .afterReturn(true);
      mocker.mockFunc(DateUtil, DateUtil.convertTimeStampToDateWeek);
      mocker.mockFunc(DateUtil, DateUtil.fullDate);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.setDateShow);

      let item: mmsListType = mConversationCtrl.buildTextSendItemOfEnhancedInfo(true);

      expect(item.isRcs).assertEqual(1);

      mocker.clear(settingService);
      mocker.clear(DateUtil);
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_changeReceiveContactValue', 0, () => {
      mConversationCtrl.changeReceiveContactValue('2222');

      expect(mConversationCtrl.receiveContactValue).assertEqual('2222');
    })

    it('ConversationControllerTest_updatePreview_length_1_type_1', 0, () => {
      mConversationCtrl.mmsEditList = [{
        type: 1,
        uriPath: '',
        time: '',
        fileSize: 10
      } as MmsSourceType];
      mConversationCtrl.pictureListFromGallery = [{
        checkedValue: true,
        path: ''
      } as pictureListFromGalleryType, {
        checkedValue: true,
        path: '/'
      } as pictureListFromGalleryType];

      mConversationCtrl.updatePreview(0);

      expect(mConversationCtrl.isOnlyAudio).assertFalse();
    })

    it('ConversationControllerTest_updatePreview_length_1_type_3', 0, () => {
      mConversationCtrl.mmsEditList = [{
        type: 3,
        uriPath: '',
        time: '',
        fileSize: 10
      } as MmsSourceType];
      mConversationCtrl.pictureListFromGallery = [{
        checkedValue: true,
        path: ''
      } as pictureListFromGalleryType, {
        checkedValue: true,
        path: '/'
      } as pictureListFromGalleryType];

      mConversationCtrl.updatePreview(0);

      expect(mConversationCtrl.isOnlyAudio).assertTrue();
    })

    it('ConversationControllerTest_initSendItem_mmsEditList_empty', 0, () => {
      mConversationCtrl.mmsEditList = [];
      mConversationCtrl.contactsNum = 1;
      mConversationCtrl.isEditMms = false;

      when(mocker.mockFunc(settingService, settingService.judgeIsDeliveryReport))(ArgumentMatchers.any)
        .afterReturn(true);
      mocker.mockFunc(DateUtil, DateUtil.convertTimeStampToDateWeek);
      mocker.mockFunc(DateUtil, DateUtil.fullDate);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.setDateShow);
      mocker.mockFunc(ConversationDataSource.getInstance(), ConversationDataSource.getInstance().refresh);
      let item: mmsListType = new mmsListType();
      mConversationCtrl.initSendItem(context, item, '');
      expect(mConversationCtrl.mmsList[0].isMsm).assertFalse();

      mocker.clear(settingService);
      mocker.clear(ConversationDataSource.getInstance());
      mocker.clear(DateUtil);
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_initSendItem_mmsEditList_length_1_type_3', 0, () => {
      mConversationCtrl.mmsEditList = [{
        type: 3,
        uriPath: '',
        time: '',
        fileSize: 10
      }];
      mConversationCtrl.contactsNum = 1;
      mConversationCtrl.isEditMms = false;

      when(mocker.mockFunc(settingService, settingService.judgeIsDeliveryReport))(ArgumentMatchers.any)
        .afterReturn(true);
      mocker.mockFunc(DateUtil, DateUtil.convertTimeStampToDateWeek);
      mocker.mockFunc(DateUtil, DateUtil.fullDate);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.setDateShow);
      mocker.mockFunc(ConversationDataSource.getInstance(), ConversationDataSource.getInstance().refresh)
      let item: mmsListType = new mmsListType();
      mConversationCtrl.initSendItem(context, item, '');

      expect(mConversationCtrl.mmsList[0].isMsm).assertFalse();

      mocker.clear(settingService);
      mocker.clear(ConversationDataSource.getInstance());
      mocker.clear(DateUtil);
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_initSendItem_mmsEditList_length_1_type_5', 0, () => {
      mConversationCtrl.mmsEditList = [{
        type: 5,
        uriPath: '',
        time: '',
        fileSize: 10
      }];
      mConversationCtrl.contactsNum = 1;
      mConversationCtrl.isEditMms = false;

      when(mocker.mockFunc(settingService, settingService.judgeIsDeliveryReport))(ArgumentMatchers.any)
        .afterReturn(true);
      mocker.mockFunc(DateUtil, DateUtil.convertTimeStampToDateWeek);
      mocker.mockFunc(DateUtil, DateUtil.fullDate);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.setDateShow);
      mocker.mockFunc(ConversationDataSource.getInstance(), ConversationDataSource.getInstance().refresh)

      let item: mmsListType = new mmsListType();
      mConversationCtrl.initSendItem(context, item, '');

      expect(mConversationCtrl.mmsList[0].isMsm).assertFalse();

      mocker.clear(settingService);
      mocker.clear(ConversationDataSource.getInstance());
      mocker.clear(DateUtil);
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_initSendItem_mmsEditList_length_1_type_0', 0, () => {
      mConversationCtrl.mmsEditList = [{
        type: 0,
        uriPath: '',
        time: '',
        fileSize: 10
      }];
      mConversationCtrl.contactsNum = 1;
      mConversationCtrl.isEditMms = false;

      when(mocker.mockFunc(settingService, settingService.judgeIsDeliveryReport))(ArgumentMatchers.any)
        .afterReturn(true);
      mocker.mockFunc(DateUtil, DateUtil.convertTimeStampToDateWeek);
      mocker.mockFunc(DateUtil, DateUtil.fullDate);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.setDateShow);
      mocker.mockFunc(ConversationDataSource.getInstance(), ConversationDataSource.getInstance().refresh)

      let item: mmsListType = new mmsListType();
      mConversationCtrl.initSendItem(context, item, '');

      expect(mConversationCtrl.mmsList[0].isMsm).assertFalse();

      mocker.clear(settingService);
      mocker.clear(ConversationDataSource.getInstance());
      mocker.clear(DateUtil);
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_setDateShow_index_minus1_length_0', 0, () => {
      let currentItem: mmsListType = new mmsListType();
      let list: mmsListType[] = [];

      mConversationCtrl.setDateShow(undefined, undefined, -1);
      mConversationCtrl.setDateShow(currentItem, list, -1);

      expect(currentItem.dateShow).assertTrue();
    })

    it('ConversationControllerTest_setDateShow_index_minus1_length_1', 0, () => {
      let currentItem: mmsListType = new mmsListType();
      let list: mmsListType[] = [currentItem];
      when(mocker.mockFunc(DateUtil, DateUtil.isNotSameDay))(ArgumentMatchers.any)
        .afterReturn(true)

      mConversationCtrl.setDateShow(currentItem, list, -1);

      expect(currentItem.dateShow).assertTrue();

      mocker.clear(DateUtil);
    })

    it('ConversationControllerTest_setDateShow_index_0_length_1', 0, () => {
      let currentItem: mmsListType = new mmsListType();
      let list: mmsListType[] = [currentItem];
      when(mocker.mockFunc(DateUtil, DateUtil.isNotSameDay))(ArgumentMatchers.any)
        .afterReturn(true)

      mConversationCtrl.setDateShow(currentItem, list, 0);

      expect(currentItem.dateShow).assertTrue();

      mocker.clear(DateUtil);
    })

    it('ConversationControllerTest_setDateShow_index_1_length_1', 0, () => {
      let currentItem: mmsListType = new mmsListType();
      let list: mmsListType[] = [currentItem];
      when(mocker.mockFunc(DateUtil, DateUtil.isNotSameDay))(ArgumentMatchers.any)
        .afterReturn(true)

      mConversationCtrl.setDateShow(currentItem, list, 1);

      expect(currentItem.dateShow).assertTrue();

      mocker.clear(DateUtil);
    })

    it('ConversationControllerTest_setDateShow_catch', 0, () => {
      let currentItem: mmsListType = new mmsListType();
      let list: mmsListType[] = [currentItem];
      when(mocker.mockFunc(DateUtil, DateUtil.isNotSameDay))(ArgumentMatchers.any)
        .afterThrow('error')

      mConversationCtrl.setDateShow(currentItem, list, 1);

      expect(currentItem.dateShow).assertFalse();

      mocker.clear(DateUtil);
    })

    it('ConversationControllerTest_getThemeContent_first_text_notEmpty', 0, () => {
      mConversationCtrl.textareaDatasource = [{
        textValue: 'xx'
      } as LooseObject, {
        textValue: 'xx'
      } as LooseObject];

      mConversationCtrl.getThemeContent();

      expect(mConversationCtrl.getThemeContent()).assertEqual($r('app.string.msg_theme') + ': ' + 'xx' + '\n' + 'xx');
    })

    it('ConversationControllerTest_getThemeContent_first_empty_text_notEmpty', 0, () => {
      mConversationCtrl.textareaDatasource = [{
        textValue: ''
      } as LooseObject, {
        textValue: 'xx'
      } as LooseObject];

      mConversationCtrl.getThemeContent();

      expect(mConversationCtrl.getThemeContent()).assertEqual('xx');
    })

    it('ConversationControllerTest_getThemeContent_first_notEmpty_text_empty', 0, () => {
      mConversationCtrl.textareaDatasource = [{
        textValue: 'xx'
      } as LooseObject, {
        textValue: ''
      } as LooseObject];

      mConversationCtrl.getThemeContent();

      expect(mConversationCtrl.getThemeContent()).assertEqual($r('app.string.msg_theme') + ': ' + 'xx');
    })

    it('ConversationControllerTest_sendMessage_isMsm_true_isRcsMap_true', 0, async () => {
      let item: mmsListType = new mmsListType();
      item.id = 1;
      item.isRcs = 0;
      item.threadId = 1;
      item.isMsm = true;
      let actionData: ActionDataType = {
        slotId: 1,
        destinationHost: 'sip:botplatform@1242',
        content: 'xx',
        isEditMms: false,
        contactId: '1',
        contactName: 'xx',
        hosts: ['1111'],
        isReSend: true,
        id: undefined,
        isRcs: 0,
        resendStateIsRcs: false,
        threadId: 1,
        groupId: undefined,
      } as ActionDataType;
      when(mocker.mockFunc(MmsUtil, MmsUtil.isRcsMap))(ArgumentMatchers.any)
        .afterReturn(true);

      mocker.mockFunc(mConversationCtrl, mConversationCtrl.dealSendResult);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.sendMmsMessage);
      mConversationCtrl.chatbotMmsNumber = '';
      await mConversationCtrl.sendMessage(context, actionData, item, [], () => {
      });

      mConversationCtrl.chatbotMmsNumber = '110';
      await mConversationCtrl.sendMessage(context, actionData, item, [], () => {
      });

      expect(item.isMsm).assertFalse();

      mocker.clear(MmsUtil);
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_sendMessage_isMsm_false_isRcsMap_false', 0, async () => {
      let item: mmsListType = new mmsListType();
      item.id = 1;
      item.isRcs = 1;
      item.threadId = 1;
      item.isMsm = false;
      let actionData: ActionDataType = {
        slotId: 1,
        destinationHost: 'aweg1:botplatform',
        content: 'xx',
        isEditMms: false,
        contactId: '1',
        contactName: 'xx',
        hosts: ['1111'],
        isReSend: true,
        id: undefined,
        isRcs: 0,
        resendStateIsRcs: false,
        threadId: 1,
        groupId: undefined,
      } as ActionDataType;
      when(mocker.mockFunc(MmsUtil, MmsUtil.isRcsMap))(ArgumentMatchers.any)
        .afterReturn(false);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.sendMmsMessage);

      await mConversationCtrl.sendMessage(context, actionData, item, [], () => {
      });

      expect(item.isMsm).assertFalse();

      mocker.clear(MmsUtil);
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_sendMessage_isMsm_true_isChatbot', 0, async () => {
      let item: mmsListType = new mmsListType();
      item.id = 1;
      item.isRcs = 1;
      item.rcsType = 1;
      item.threadId = 1;
      item.isMsm = true;
      let actionData: ActionDataType = {
        slotId: 1,
        destinationHost: 'aweg1:botplatform',
        content: 'xx',
        isEditMms: false,
        contactId: '1',
        contactName: 'xx',
        hosts: ['1111'],
        isReSend: true,
        isChatbot: true,
        id: undefined,
        isRcs: 0,
        resendStateIsRcs: false,
        threadId: 1,
        groupId: undefined,
      } as ActionDataType;
      when(mocker.mockFunc(MmsUtil, MmsUtil.isRcsMap))(ArgumentMatchers.any)
        .afterReturn(false);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.sendMmsMessage);

      await mConversationCtrl.sendMessage(context, actionData, item, [], () => {
      });

      expect(item.isMsm).assertTrue();

      mocker.clear(MmsUtil);
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_clearMsm_list_empty', 0, () => {
      mConversationCtrl.isEditMms = true;
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.updatePreview);

      mConversationCtrl.clearMsm();

      expect(mConversationCtrl.isEditMms).assertFalse();
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_clearMsm_list', 0, () => {
      mConversationCtrl.isEditMms = false;
      mConversationCtrl.mmsEditList.push({
        type: 3,
        uriPath: '',
        time: '',
        fileSize: 10
      } as MmsSourceType);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.updatePreview);

      mConversationCtrl.clearMsm();

      expect(mConversationCtrl.mmsEditList.length).assertEqual(0);
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_resetMmsSource', 0, () => {
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.resetAttachAreaPicture);
      mocker.mockFunc(mConversationCtrl.mAttachAreaCtrl, mConversationCtrl.mAttachAreaCtrl.resetMms);

      mConversationCtrl.resetMmsSource();

      expect(mConversationCtrl.canSendMessage).assertFalse();

      mocker.clear(mConversationCtrl.mAttachAreaCtrl);
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_resetMmsSourceOfRcsMessageNotInAttachmentArea', 0, () => {
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.resetAttachAreaPicture);
      mocker.mockFunc(mConversationCtrl.mAttachAreaCtrl, mConversationCtrl.mAttachAreaCtrl.refreshDisplay);

      mConversationCtrl.resetMmsSourceOfRcsMessageNotInAttachmentArea();

      expect(mConversationCtrl.canSendMessage).assertFalse();

      mocker.clear(mConversationCtrl.mAttachAreaCtrl);
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_resetMmsSourceOfRcsMessageNotInAttachmentArea_mmDisplaySource', 0, () => {
      mConversationCtrl.mAttachAreaCtrl.mmDisplaySource = [{
        text: 'xx'
      } as Mms];
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.resetAttachAreaPicture);
      mocker.mockFunc(mConversationCtrl.mAttachAreaCtrl, mConversationCtrl.mAttachAreaCtrl.refreshDisplay);


      mConversationCtrl.resetMmsSourceOfRcsMessageNotInAttachmentArea();

      expect(mConversationCtrl.canSendMessage).assertTrue();

      mocker.clear(mConversationCtrl.mAttachAreaCtrl);
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_sendAudio', 0, async () => {
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.showToast);
      await mConversationCtrl.sendAudio(context);
      mocker.verify('showToast', []).never();

      when(mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences))('inRepairMode')
        .afterReturn(true);
      await mConversationCtrl.sendAudio(context);
      expect(mConversationCtrl.isChangeInputPlaceholder).assertTrue();

      mocker.clear(SharedPreferencesUtils);
      mConversationCtrl.isAirPlaneMode = true;
      when(mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences))('inRepairMode')
        .afterReturn(false);
      await mConversationCtrl.sendAudio(context);
      expect(mConversationCtrl.isChangeInputPlaceholder).assertTrue();

      mConversationCtrl.isAirPlaneMode = false;
      mConversationCtrl.canSendMessage = false;
      mConversationCtrl.isNewMsg = true;
      mConversationCtrl.receiveContactValue = '111';
      await mConversationCtrl.sendAudio(context);
      expect(mConversationCtrl.canSendMessage).assertTrue();

      mConversationCtrl.receiveContactValue = '';
      mConversationCtrl.selectContacts = [{} as selectContactType];
      mConversationCtrl.threadId = 100001;
      mConversationCtrl.setSelectContacts(mConversationCtrl.selectContacts);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.initNewSelectContacts);
      await mConversationCtrl.sendAudio(context);
      expect(mConversationCtrl.canSendMessage).assertTrue();

      mConversationCtrl.receiveContactValue = '';
      mConversationCtrl.selectContacts = [];
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.newSend);
      await mConversationCtrl.sendAudio(context);
      expect(mConversationCtrl.canSendMessage).assertTrue();

      mConversationCtrl.isNewMsg = false;
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.publishData);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.newSend);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.sendRcsDataRefreshNoWithImgAndText);
      await mConversationCtrl.sendAudio(context);
      expect(mConversationCtrl.vCardJumpBack).assertFalse();

      mConversationCtrl.canSendMessage = true;
      await mConversationCtrl.sendAudio(context);
      expect(mConversationCtrl.vCardJumpBack).assertFalse();

      mConversationCtrl.isNewMsg = true;
      await mConversationCtrl.sendAudio(context);
      expect(mConversationCtrl.vCardJumpBack).assertFalse();
      mocker.clear(SharedPreferencesUtils);
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_sendRcsDataRefreshNoWithImgAndText_recallMessageSwitch_0', 0, async () => {
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.initAudioItem);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.sendInterval);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.clearMsm);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.resetMmsSourceOfRcsMessageNotInAttachmentArea);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.setTabOperationStatus);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.clearSelectContacts);
      mocker.mockFunc(mConversationCtrl.scroller, mConversationCtrl.scroller.scrollEdge);

      when(mocker.mockFunc(MmsPreferences.getInstance(), MmsPreferences.getInstance().getSendMessageSlotIdOfRcs))()
        .afterReturn(0);

      await mConversationCtrl.sendRcsDataRefreshNoWithImgAndText(context);

      expect(mConversationCtrl.isNewMsg).assertFalse();

      mocker.clear(mConversationCtrl.scroller);
      mocker.clear(MmsPreferences.getInstance());
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_initAudioItem_rcsDisplaySource_empty_contentType_3', 0, async () => {
      MMAttachmentAreaController.getInstance().rcsDisplaySource = [];

      mocker.mockFunc(mConversationCtrl, mConversationCtrl.setDateShow);
      mocker.mockFunc(DateUtil, DateUtil.convertTimeStampToDateWeek);
      mocker.mockFunc(DateUtil, DateUtil.fullDate);
      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.getSmiledRcsSource))(ArgumentMatchers.any)
        .afterReturn(new Promise<Mms[]>(resolve => resolve([])));
      mocker.mockFunc(ConversationDataSource.getInstance(), ConversationDataSource.getInstance().refresh);

      when(mocker.mockFunc(MmsUtil, MmsUtil.getRcsContentType))(ArgumentMatchers.any)
        .afterReturn(3);

      await mConversationCtrl.initAudioItem(context);

      expect(mConversationCtrl).not().assertUndefined();

      mocker.clear(ConversationDataSource.getInstance());
      mocker.clear(DateUtil);
      mocker.clear(mConversationCtrl);
      mocker.clear(MmsUtil);
    })

    it('ConversationControllerTest_sendOfEnhancedInfo_inRepairMode_true', 0, () => {
      mConversationCtrl.mAttachAreaCtrl.mmDisplaySource.length = 1;
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.showToast);
      when(mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences))(ArgumentMatchers.any)
        .afterReturn(true);

      mConversationCtrl.sendOfEnhancedInfo(context);

      expect(mConversationCtrl.isChangeInputPlaceholder).assertTrue();

      mocker.clear(SharedPreferencesUtils);
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_sendOfEnhancedInfo_isAirPlaneMode_true', 0, () => {
      mConversationCtrl.mAttachAreaCtrl.mmDisplaySource.length = 1;
      mConversationCtrl.isAirPlaneMode = true;
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.showToast);
      when(mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences))(ArgumentMatchers.any)
        .afterReturn(false);

      mConversationCtrl.sendOfEnhancedInfo(context);

      expect(mConversationCtrl.isChangeInputPlaceholder).assertTrue();

      mocker.clear(SharedPreferencesUtils);
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_sendOfEnhancedInfo_canSendMessage_false', 0, () => {
      mConversationCtrl.mAttachAreaCtrl.mmDisplaySource.length = 1;
      mConversationCtrl.isAirPlaneMode = false;
      mConversationCtrl.canSendMessage = false;
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.showToast);
      when(mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences))(ArgumentMatchers.any)
        .afterReturn(false);

      mConversationCtrl.sendOfEnhancedInfo(context);

      expect(mConversationCtrl.isChangeInputPlaceholder).assertTrue();

      mocker.clear(SharedPreferencesUtils);
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_sendOfEnhancedInfo_isNewMsg_false', 0, () => {
      mConversationCtrl.mAttachAreaCtrl.mmDisplaySource.length = 1;
      mConversationCtrl.isAirPlaneMode = false;
      mConversationCtrl.canSendMessage = true;
      mConversationCtrl.isNewMsg = false;
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.showToast);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.sendDataRefreshOfEnhancedInfo);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.publishData);
      when(mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences))(ArgumentMatchers.any)
        .afterReturn(false);
      mocker.mockFunc(DotUtil.getInstance(), DotUtil.getInstance().reportEvent);

      mConversationCtrl.sendOfEnhancedInfo(context);

      expect(mConversationCtrl).not().assertUndefined();

      mocker.clear(SharedPreferencesUtils);
      mocker.clear(DotUtil.getInstance());
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_sendOfEnhancedInfo_isNewMsg_true', 0, () => {
      mConversationCtrl.mAttachAreaCtrl.mmDisplaySource.length = 1;
      mConversationCtrl.isAirPlaneMode = false;
      mConversationCtrl.canSendMessage = true;
      mConversationCtrl.isNewMsg = true;
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.showToast);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.newSend);
      when(mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences))(ArgumentMatchers.any)
        .afterReturn(false);

      mConversationCtrl.sendOfEnhancedInfo(context);

      expect(mConversationCtrl).not().assertUndefined();

      mocker.clear(SharedPreferencesUtils);
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_resetValuesOfEnhancedInfo', 0, () => {
      mConversationCtrl.isAirPlaneMode = false;
      mConversationCtrl.canSendMessage = true;
      mConversationCtrl.isNewMsg = true;
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.clearMsm);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.resetMmsSource);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.setTabOperationStatus);
      mocker.mockFunc(mConversationCtrl.scroller, mConversationCtrl.scroller.scrollEdge);

      mConversationCtrl.resetValuesOfEnhancedInfo();

      expect(mConversationCtrl.textValue).assertEqual('');

      mocker.clear(mConversationCtrl.scroller);
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_resetValuesOfSwitchingCard', 0, () => {
      mConversationCtrl.isAirPlaneMode = false;
      mConversationCtrl.canSendMessage = true;
      mConversationCtrl.isNewMsg = true;
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.clearMsm);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.resetMmsSource);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.setTabOperationStatus);

      mConversationCtrl.resetValuesOfSwitchingCard();

      expect(mConversationCtrl.canSendMessage).assertTrue();
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_sendDataRefreshOfEnhancedInfo_copySource_length_1_mmsList_length_1_msgType_4', 0,
      async () => {
        mConversationCtrl.mAttachAreaCtrl.mmDisplaySource = [{} as Mms];
        mConversationCtrl.mAttachAreaCtrl.copySource = [{} as Mms];
        let listType: mmsListType = new mmsListType();
        listType.msgType = 4;
        mConversationCtrl.mmsList = [];

        when(mocker.mockFunc(MmsPreferences.getInstance(), MmsPreferences.getInstance().getSendMessageSlotIdOfRcs))()
          .afterReturn(0);
        when(mocker.mockFunc(MessageUtil, MessageUtil.replaceForLossy7Bit))(ArgumentMatchers.any)
          .afterReturn('0');
        when(mocker.mockFunc(mConversationCtrl,
          mConversationCtrl.buildTextSendItemOfEnhancedInfo))(ArgumentMatchers.any)
          .afterReturn(new mmsListType());
        mocker.mockFunc(mConversationCtrl.mAttachAreaCtrl, mConversationCtrl.mAttachAreaCtrl.initSourceOfEnhancedInfo);
        when(mocker.mockFunc(mConversationCtrl,
          mConversationCtrl.buildAttachmentSendItemOfEnhancedInfo))(ArgumentMatchers.any)
          .afterReturn(new mmsListType());
        mocker.mockFunc(ConversationDataSource.getInstance(), ConversationDataSource.getInstance().addDataByIndexes);
        mocker.mockFunc(mConversationCtrl, mConversationCtrl.sendInterval);
        mocker.mockFunc(mConversationCtrl, mConversationCtrl.resetValuesOfEnhancedInfo);

        await mConversationCtrl.sendDataRefreshOfEnhancedInfo(context, 'abc');

        expect(mConversationCtrl.isNewMsg).assertFalse();

        mocker.clear(mConversationCtrl.mAttachAreaCtrl);
        mocker.clear(ConversationDataSource.getInstance());
        mocker.clear(MmsPreferences.getInstance());
        mocker.clear(MessageUtil);
        mocker.clear(mConversationCtrl);
      })

    it('ConversationControllerTest_sendDataRefreshOfEnhancedInfo_copySource_length_1_mmsList_length_1_msgType_5_groupId_null',
      0, async () => {
        mConversationCtrl.mAttachAreaCtrl.mmDisplaySource = [{} as Mms];
        mConversationCtrl.mAttachAreaCtrl.copySource = [{} as Mms];
        let listType: mmsListType = new mmsListType();
        listType.msgType = 5;
        mConversationCtrl.mmsList = [listType];

        when(mocker.mockFunc(MmsPreferences.getInstance(), MmsPreferences.getInstance().getSendMessageSlotIdOfRcs))()
          .afterReturn(0);
        when(mocker.mockFunc(MessageUtil, MessageUtil.replaceForLossy7Bit))(ArgumentMatchers.any)
          .afterReturn('0');
        when(mocker.mockFunc(mConversationCtrl,
          mConversationCtrl.buildTextSendItemOfEnhancedInfo))(ArgumentMatchers.any)
          .afterReturn(new mmsListType());
        mocker.mockFunc(mConversationCtrl.mAttachAreaCtrl, mConversationCtrl.mAttachAreaCtrl.initSourceOfEnhancedInfo);
        when(mocker.mockFunc(mConversationCtrl,
          mConversationCtrl.buildAttachmentSendItemOfEnhancedInfo))(ArgumentMatchers.any)
          .afterReturn(new mmsListType());
        when(mocker.mockFunc(DataShareHelper.getInstance(),
          DataShareHelper.getInstance().initSmsDB))(ArgumentMatchers.any)
          .afterReturn(new Promise<dataShare.DataShareHelper | undefined>(resolve => resolve(undefined)));
        mocker.mockFunc(ConversationDataSource.getInstance(), ConversationDataSource.getInstance().addDataByIndexes);
        mocker.mockFunc(mConversationCtrl, mConversationCtrl.sendInterval);
        mocker.mockFunc(mConversationCtrl, mConversationCtrl.resetValuesOfEnhancedInfo);

        await mConversationCtrl.sendDataRefreshOfEnhancedInfo(context, 'abc');

        expect(mConversationCtrl.isNewMsg).assertFalse();

        mocker.clear(mConversationCtrl.mAttachAreaCtrl);
        mocker.clear(ConversationDataSource.getInstance());
        mocker.clear(MmsPreferences.getInstance());
        mocker.clear(MessageUtil);
        mocker.clear(DataShareHelper.getInstance());
      })

    it('ConversationControllerTest_sendDataRefreshOfEnhancedInfo_copySource_length_1_mmsList_length_0', 0, async () => {
      mConversationCtrl.mAttachAreaCtrl.mmDisplaySource = [{} as Mms];
      mConversationCtrl.mAttachAreaCtrl.copySource = [{} as Mms];
      mConversationCtrl.mmsList = [];

      when(mocker.mockFunc(MmsPreferences.getInstance(), MmsPreferences.getInstance().getSendMessageSlotIdOfRcs))()
        .afterReturn(0);
      when(mocker.mockFunc(MessageUtil, MessageUtil.replaceForLossy7Bit))(ArgumentMatchers.any)
        .afterReturn('0');
      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.buildTextSendItemOfEnhancedInfo))(ArgumentMatchers.any)
        .afterReturn(new mmsListType());
      mocker.mockFunc(mConversationCtrl.mAttachAreaCtrl, mConversationCtrl.mAttachAreaCtrl.initSourceOfEnhancedInfo);
      when(mocker.mockFunc(mConversationCtrl,
        mConversationCtrl.buildAttachmentSendItemOfEnhancedInfo))(ArgumentMatchers.any)
        .afterReturn(new mmsListType());
      when(mocker.mockFunc(DataShareHelper.getInstance(),
        DataShareHelper.getInstance().initSmsDB))(ArgumentMatchers.any)
        .afterReturn(new Promise<dataShare.DataShareHelper | undefined>(resolve => resolve(undefined)));
      mocker.mockFunc(ConversationDataSource.getInstance(), ConversationDataSource.getInstance().addDataByIndexes);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.sendInterval);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.resetValuesOfEnhancedInfo);

      await mConversationCtrl.sendDataRefreshOfEnhancedInfo(context, 'abc');

      expect(mConversationCtrl.isNewMsg).assertFalse();

      mocker.clear(mConversationCtrl.mAttachAreaCtrl);
      mocker.clear(ConversationDataSource.getInstance());
      mocker.clear(MmsPreferences.getInstance());
      mocker.clear(MessageUtil);
      mocker.clear(DataShareHelper.getInstance());
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_sendDataRefreshOfEnhancedInfo_copySource_length_0', 0, async () => {
      mConversationCtrl.mAttachAreaCtrl.mmDisplaySource = [{} as Mms];
      mConversationCtrl.mAttachAreaCtrl.copySource = [];
      mConversationCtrl.mmsList = [];

      when(mocker.mockFunc(MmsPreferences.getInstance(), MmsPreferences.getInstance().getSendMessageSlotIdOfRcs))()
        .afterReturn(0);
      when(mocker.mockFunc(MessageUtil, MessageUtil.replaceForLossy7Bit))(ArgumentMatchers.any)
        .afterReturn('0');
      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.buildTextSendItemOfEnhancedInfo))(ArgumentMatchers.any)
        .afterReturn(new mmsListType());
      mocker.mockFunc(mConversationCtrl.mAttachAreaCtrl, mConversationCtrl.mAttachAreaCtrl.initSourceOfEnhancedInfo);
      when(mocker.mockFunc(mConversationCtrl,
        mConversationCtrl.buildAttachmentSendItemOfEnhancedInfo))(ArgumentMatchers.any)
        .afterReturn(new mmsListType());
      when(mocker.mockFunc(DataShareHelper.getInstance(),
        DataShareHelper.getInstance().initSmsDB))(ArgumentMatchers.any)
        .afterReturn(new Promise<dataShare.DataShareHelper | undefined>(resolve => resolve(undefined)));
      mocker.mockFunc(ConversationDataSource.getInstance(), ConversationDataSource.getInstance().addDataByIndexes);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.sendInterval);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.resetValuesOfEnhancedInfo);

      await mConversationCtrl.sendDataRefreshOfEnhancedInfo(context, 'abc');

      expect(mConversationCtrl.isNewMsg).assertFalse();

      mocker.clear(mConversationCtrl.mAttachAreaCtrl);
      mocker.clear(ConversationDataSource.getInstance());
      mocker.clear(MmsPreferences.getInstance());
      mocker.clear(MessageUtil);
      mocker.clear(mConversationCtrl);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('ConversationControllerTest_sendPublish_isNewMsg_true', 0, () => {
      mConversationCtrl.isNewMsg = true;

      mocker.mockFunc(mConversationCtrl, mConversationCtrl.newSend);

      mConversationCtrl.sendPublish(context);

      expect(mConversationCtrl.isNewMsgWithDraft).assertFalse();
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_sendPublish_isNewMsg_false', 0, () => {
      mConversationCtrl.isNewMsg = false;

      mocker.mockFunc(mConversationCtrl, mConversationCtrl.sendDataRefresh);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.publishData);
      mocker.mockFunc(DotUtil.getInstance(), DotUtil.getInstance().reportEvent);

      mConversationCtrl.sendPublish(context);

      expect(mConversationCtrl.isChangeInputPlaceholder).assertFalse();
      mocker.clear(mConversationCtrl);
      mocker.clear(DotUtil.getInstance());
    })

    it('ConversationControllerTest_sendDataRefresh_textValue_isEditMms_false', 0, async () => {
      mConversationCtrl.textValue = 'xx';
      mConversationCtrl.isEditMms = false;
      when(mocker.mockFunc(MmsPreferences.getInstance(), MmsPreferences.getInstance().getSendMessageSlotIdOfRcs))()
        .afterReturn(0);
      when(mocker.mockFunc(MessageUtil, MessageUtil.replaceForLossy7Bit))(ArgumentMatchers.any)
        .afterReturn('0');
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.initSendItem);
      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.getSendText))(ArgumentMatchers.any)
        .afterReturn('xx')

      mocker.mockFunc(mConversationCtrl, mConversationCtrl.sendInterval);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.resetMmsSource);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.isFoldSend);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.setTabOperationStatus);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.clearMsm);
      mocker.mockFunc(mConversationCtrl.scroller, mConversationCtrl.scroller.scrollEdge);

      await mConversationCtrl.sendDataRefresh(context, () => {
      });

      expect(mConversationCtrl.isNewMsg).assertFalse();

      mocker.clear(mConversationCtrl.scroller);
      mocker.clear(MmsPreferences.getInstance());
      mocker.clear(mConversationCtrl);
      mocker.clear(MessageUtil);
    })

    it('ConversationControllerTest_sendDataRefresh_textValue_empty_isEditMms_true', 0,
      async () => {
        mConversationCtrl.textValue = '';
        mConversationCtrl.isEditMms = true;
        when(mocker.mockFunc(MmsPreferences.getInstance(), MmsPreferences.getInstance().getSendMessageSlotIdOfRcs))()
          .afterReturn(0);
        when(mocker.mockFunc(MessageUtil, MessageUtil.replaceForLossy7Bit))(ArgumentMatchers.any)
          .afterReturn('0');
        mocker.mockFunc(mConversationCtrl, mConversationCtrl.initSendItem);
        when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.getSendText))(ArgumentMatchers.any)
          .afterReturn('xx');
        when(mocker.mockFunc(FileUtil, FileUtil.writeTextToSandBox))(ArgumentMatchers.any)
          .afterReturn({
            'path': '',
            'name': 'name'
          } as Record<string, string>);

        mocker.mockFunc(mConversationCtrl, mConversationCtrl.sendInterval);
        mocker.mockFunc(mConversationCtrl, mConversationCtrl.resetMmsSource);
        mocker.mockFunc(mConversationCtrl, mConversationCtrl.isFoldSend);
        mocker.mockFunc(mConversationCtrl, mConversationCtrl.setTabOperationStatus);
        mocker.mockFunc(mConversationCtrl, mConversationCtrl.clearMsm);
        mocker.mockFunc(mConversationCtrl.scroller, mConversationCtrl.scroller.scrollEdge);
        when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.getSmilSource))(ArgumentMatchers.any).afterReturn({});
        when(mocker.mockFunc(MmsUtil, MmsUtil.getMmsContentType))(ArgumentMatchers.any).afterReturnNothing;

        await mConversationCtrl.sendDataRefresh(context, () => {
        });
        expect(mConversationCtrl.isNewMsg).assertFalse();
        mocker.clear(mConversationCtrl.scroller);
        mocker.clear(MmsPreferences.getInstance());
        mocker.clear(MessageUtil);
        mocker.clear(MmsUtil);
        mocker.clear(FileUtil);
        mocker.clear(mConversationCtrl);
      })

    it('ConversationControllerTest_isFoldSend_curBp_bp', 0, () => {
      AppStorage.setOrCreate('curBp', 'bp');
      mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().setObject);
      mocker.mockFunc(ConversationListController.getInstance(),
        ConversationListController.getInstance().refreshConversationListData);
      mConversationCtrl.isFoldSend(context, '111111');
      expect(ConversationListController.getInstance().lastIndex).assertEqual(-1);
      mocker.clear(GlobalContext.getContext());
      mocker.clear(ConversationListController.getInstance());
    })

    it('ConversationControllerTest_isFoldSend_curBp_sm', 0, () => {
      AppStorage.setOrCreate('curBp', 'sm');
      mConversationCtrl.isFoldSend(context, '111111');
      expect(ConversationListController.getInstance().lastIndex).assertEqual(-1);
    })

    it('ConversationControllerTest_queryContactId_abilityResultLength_1', 0, () => {
      mConversationCtrl.rawContactId = '1';
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: 0,
              abilityResult: [{
                rawContactId: '0',
                displayName: 'name',
                detailInfo: 'xx',
                id: 0
              } as BaseAbilityResult]
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve());
          }
        } as Object | window.WindowStage);

      mConversationCtrl.queryContactId(context);
      expect(mConversationCtrl.sessionContactsInfo.length).assertEqual(1);
      mocker.clear(GlobalContext.getContext());
    })

    it('ConversationControllerTest_queryContactId_abilityResultLength_0', 0, () => {
      mConversationCtrl.rawContactId = '1';
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: 0,
              abilityResult: []
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve());
          }
        } as Object | window.WindowStage);

      mConversationCtrl.queryContactId(context);
      expect(mConversationCtrl.portraitColor).assertEqual('');
      mocker.clear(GlobalContext.getContext());
    })

    it('ConversationControllerTest_queryContactId_fail', 0, () => {
      mConversationCtrl.rawContactId = '1';
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: -1,
              abilityResult: []
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve());
          }
        } as Object | window.WindowStage);

      mConversationCtrl.queryContactId(context);
      expect(mConversationCtrl.portraitColor).assertEqual('');
      mocker.clear(GlobalContext.getContext());
    })

    it('ConversationControllerTest_newSend_isPhoneNumber_false', 0, () => {
      mConversationCtrl.receiveContactValue = 'xdf';
      when(mocker.mockFunc(TelephoneUtil, TelephoneUtil.isPhoneNumber))(mConversationCtrl.receiveContactValue)
        .afterReturn(false);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.showToast);

      mConversationCtrl.newSend(context, () => {
      });
      expect(mConversationCtrl.contactsNum).assertEqual(0);
      mocker.clear(TelephoneUtil);
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_newSend_selectContacts_length_1_selectContacts_receiveContactValue_empty', 0, () => {
      mConversationCtrl.receiveContactValue = '';
      mConversationCtrl.selectContacts = [{} as selectContactType];
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.initNewSelectContacts);
      mConversationCtrl.newSend(context, () => {
      });
      expect(mConversationCtrl.contactsNum).assertEqual(0);
    })

    it('ConversationControllerTest_newSend_selectContacts_length_0_selectContacts_receiveContactValue_notEmpty', 0,
      () => {
        mConversationCtrl.receiveContactValue = '570977632';
        mConversationCtrl.selectContacts = [];
        when(mocker.mockFunc(TelephoneUtil, TelephoneUtil.isPhoneNumber))(mConversationCtrl.receiveContactValue)
          .afterReturn(true);
        mocker.mockFunc(mConversationCtrl, mConversationCtrl.initNewSelectContacts);
        mConversationCtrl.newSend(context, () => {
        });
        expect(mConversationCtrl.contactsNum).assertEqual(1);
        mocker.clear(TelephoneUtil);
        mocker.clear(mConversationCtrl);
      })

    it('ConversationControllerTest_newSend_selectContacts_length_0_selectContacts_receiveContactValue_empty', 0, () => {
      mConversationCtrl.receiveContactValue = '';
      mConversationCtrl.selectContacts = [];
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.initNewSelectContacts);
      mConversationCtrl.newSend(context, () => {
      });
      expect(mConversationCtrl.contactsNum).assertEqual(0);
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_queryOldMessageList_threadId_2_resId_1', 0, () => {
      mConversationCtrl.threadId = 2;
      when(mocker.mockFunc(TelephoneUtil, TelephoneUtil.dealTelephoneSort))('570977632')
        .afterReturn('570977632');
      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.queryMessageDetail))(ArgumentMatchers.any)
        .afterAction(() => {
          expect(mConversationCtrl.isDraft).assertFalse();
        });
      when(mocker.mockFunc(ConversationListService, ConversationListService.getInstance))().afterReturn({
        querySessionByTelephone: (telephone: string, callback: Function, context: Context,
          isFuzzyMatch = false, chatbotParameters?: ChatbotParameters) => {
          if (callback) {
            callback({ code: 1, response: { id: 1, hasDraft: false } as LooseObject })
          }
        },
        deleteSessionByCondition: (actionData: LooseObject, callback: Function, context: Context) => {}
      });

      mConversationCtrl.queryOldMessageList(context, '570977632');

      mocker.clear(TelephoneUtil);
      mocker.clear(ConversationListService);
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_queryOldMessageList_threadId_1_res_id_1', 0, () => {
      mConversationCtrl.threadId = 1;
      when(mocker.mockFunc(TelephoneUtil, TelephoneUtil.dealTelephoneSort))('570977632')
        .afterReturn('570977632');
      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.queryMessageDetail))(ArgumentMatchers.any)
        .afterAction(() => {
          expect(mConversationCtrl.isDraft).assertFalse();
        });
      when(mocker.mockFunc(ConversationListService, ConversationListService.getInstance))().afterReturn({
        querySessionByTelephone: (telephone: string, callback: Function, context: Context,
          isFuzzyMatch = false, chatbotParameters?: ChatbotParameters) => {
          if (callback) {
            callback({ code: 0, response: { id: 1, hasDraft: false } as LooseObject })
          }
        },
        deleteSessionByCondition: (actionData: LooseObject, callback: Function, context: Context) => {}
      });

      mConversationCtrl.queryOldMessageList(context, '570977632', () => {
      });

      mocker.clear(TelephoneUtil);
      mocker.clear(ConversationListService);
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_queryOldMessageList_threadId_1_res_id_0_callback', 0, () => {
      mConversationCtrl.threadId = 1;
      when(mocker.mockFunc(TelephoneUtil, TelephoneUtil.dealTelephoneSort))('570977632')
        .afterReturn('570977632');
      when(mocker.mockFunc(ConversationListService, ConversationListService.getInstance))().afterReturn({
        querySessionByTelephone: (telephone: string, callback: Function, context: Context,
          isFuzzyMatch = false, chatbotParameters?: ChatbotParameters) => {
          if (callback) {
            callback({ code: 0, response: { id: 2, hasDraft: false} as LooseObject })
          }
        },
        deleteSessionByCondition: (actionData: LooseObject, callback: Function, context: Context) => {}
      });

      mConversationCtrl.queryOldMessageList(context, '570977632', () => {
      });
      mocker.clear(TelephoneUtil);
      mocker.clear(ConversationListService);
      expect(mConversationCtrl).not().assertUndefined();
    })

    it('ConversationControllerTest_queryOldMessageList_res_code_minus1_callback_undefined', 0, () => {
      mConversationCtrl.threadId = 1;
      when(mocker.mockFunc(TelephoneUtil, TelephoneUtil.dealTelephoneSort))('570977632')
        .afterReturn('570977632');
      when(mocker.mockFunc(ConversationListService, ConversationListService.getInstance))().afterReturn({
        querySessionByTelephone: (telephone: string, callback: Function, context: Context,
          isFuzzyMatch = false, chatbotParameters?: ChatbotParameters) => {
          if (callback) {
            callback({ code: 0, response: { id: 2, hasDraft: false } as LooseObject })
          }
        },
        deleteSessionByCondition: (actionData: LooseObject, callback: Function, context: Context) => {}
      });

      mConversationCtrl.queryOldMessageList(context, '570977632');

      expect(mConversationCtrl.isDraft).assertFalse();

      mocker.clear(TelephoneUtil);
      mocker.clear(ConversationListService);
    })

    it('ConversationControllerTest_queryOldMessageList_telephone_empty', 0, () => {
      mConversationCtrl.queryOldMessageList(context, '');

      expect(mConversationCtrl.isDraft).assertFalse();
    })

    it('ConversationControllerTest_initNewSelectContacts_contactName_notEmpty', 0, () => {
      mConversationCtrl.strContactsName = 'name';
      let contacts: LooseObject[] = [{
        telephone: '569876533',
        rawContactId: '0',
        telephoneFormat: '569876533',
        contactName: 'name',
      }];
      when(mocker.mockFunc(TelephoneUtil, TelephoneUtil.dealSelectContactsSort))(ArgumentMatchers.any)
        .afterReturn(contacts);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.photoFirstNameDeal);

      mConversationCtrl.initNewSelectContacts([{
        telephone: '569876533',
        telephoneFormat: '569876533',
        contactName: 'name',
        rawContactId: '0'
      }]);
      expect(mConversationCtrl.contactsNum).assertEqual(1);
      mocker.clear(TelephoneUtil);
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_initNewSelectContacts_contactName_empty', 0, () => {
      mConversationCtrl.strContactsName = 'name';
      let contacts: LooseObject[] = [{
        telephone: '569876533',
        rawContactId: '0',
        telephoneFormat: '569876533',
        contactName: '',
      }];
      when(mocker.mockFunc(TelephoneUtil, TelephoneUtil.dealSelectContactsSort))(ArgumentMatchers.any)
        .afterReturn(contacts);
      when(mocker.mockFunc(TelephoneUtil, TelephoneUtil.formatDisplayPhoneNum))(ArgumentMatchers.any)
        .afterReturn('570977632');
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.photoFirstNameDeal);

      mConversationCtrl.initNewSelectContacts([{
        telephone: '569876533',
        telephoneFormat: '569876533',
        contactName: '',
        rawContactId: '0'
      }]);
      expect(mConversationCtrl.contactsNum).assertEqual(1);
      mocker.clear(TelephoneUtil);
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_handleWithSend', 0, () => {
      let actionData: ActionDataType = {
        destinationHost: '99999,88888',
        hosts: ['0000']
      } as ActionDataType;
      let item: mmsListType = new mmsListType();
      item.isRcs = 0;
      item.mmsSource = [{
        type: 0
      } as Mms];

      mocker.mockFunc(mConversationCtrl, mConversationCtrl.setRcsMsgType);
      let res = false;
      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.sendMassMessage))(ArgumentMatchers.any)
        .afterAction(() => {
          res = true;
        });

      mConversationCtrl.handleWithSend(context, actionData, item, () => {
      }, 0);
      expect(res).assertTrue();
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_handleWithSend_indexOf_minus1', 0, () => {
      let actionData: ActionDataType = {
        destinationHost: '9999',
        hosts: ['0000']
      } as ActionDataType;
      let item: mmsListType = new mmsListType();
      item.isRcs = 0;
      item.mmsSource = [{
        type: 0
      } as Mms];
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.setRcsMsgType);
      let res = false;
      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.sendMassMessage))(ArgumentMatchers.any)
        .afterAction(() => {
          res = true;
        });
      mConversationCtrl.handleWithSend(context, actionData, item, () => {
      }, 0);
      expect(res).assertTrue();
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_setRcsMsgType_type_3', 0, () => {
      let actionData: ActionDataType = {
        destinationHost: '9999',
        hosts: ['0000']
      } as ActionDataType;
      let item: mmsListType = new mmsListType();
      item.mmsSource = [{
        type: 3
      } as Mms, {
        type: 3
      } as Mms];
      mConversationCtrl.setRcsMsgType(actionData, item);
      expect(item.msgType >= 0).assertTrue();
    })

    it('ConversationControllerTest_setRcsMsgType_type_9', 0, () => {
      let actionData: ActionDataType = {
        destinationHost: '9999',
        hosts: ['0000']
      } as ActionDataType;
      let item: mmsListType = new mmsListType();
      item.mmsSource = [{
        type: 3
      } as Mms, {
        type: 9
      } as Mms];
      mConversationCtrl.setRcsMsgType(actionData, item);
      expect(item.msgType).assertEqual(3);
    })

    it('ConversationControllerTest_setRcsMsgType_type_4', 0, () => {
      let actionData: ActionDataType = {
        destinationHost: '9999',
        hosts: ['0000']
      } as ActionDataType;
      let item: mmsListType = new mmsListType();
      item.mmsSource = [{
        type: 3
      } as Mms, {
        type: 4
      } as Mms];
      let tempObj: SessionContentTypeOfRcs = {
        isSendMessage: 1,
        contactNum: 0,
        contactName: ''
      }
      mConversationCtrl.setRcsMsgType(actionData, item);
      expect(actionData.content).assertEqual(JSON.stringify(tempObj));
    })

    it('ConversationControllerTest_setRcsMsgType_type_8', 0, () => {
      let actionData: ActionDataType = {
        destinationHost: '9999',
        hosts: ['0000']
      } as ActionDataType;
      let item: mmsListType = new mmsListType();
      item.mmsSource = [{
        type: 3
      } as Mms, {
        type: 8
      } as Mms];
      mConversationCtrl.setRcsMsgType(actionData, item);
      expect(item.msgType).assertEqual(8);
    })

    it('ConversationControllerTest_setRcsMsgType_rcsType_1_path', 0, () => {
      let actionData: ActionDataType = {
        destinationHost: '9999',
        hosts: ['0000']
      } as ActionDataType;
      let item: mmsListType = new mmsListType();
      item.rcsType = 1;
      item.mmsSource = [{
        type: 3
      } as Mms, {
        type: 1,
        path: ''
      } as Mms];
      mConversationCtrl.setRcsMsgType(actionData, item);
      expect(actionData.content).assertEqual('');
    })

    it('ConversationControllerTest_setRcsMsgType_rcsType_1', 0, () => {
      let actionData: ActionDataType = {
        destinationHost: '9999',
        hosts: ['0000']
      } as ActionDataType;
      let item: mmsListType = new mmsListType();
      item.rcsType = 1;
      item.mmsSource = [{
        type: 3
      } as Mms, {
        type: 1,
      } as Mms];
      mConversationCtrl.setRcsMsgType(actionData, item);
      expect(actionData.content).assertEqual('');
    })

    it('ConversationControllerTest_setRcsMsgType_type_7', 0, () => {
      let addressInfo: AddressInfo = new AddressInfo(1, 1, 'name', 'address');
      let actionData: ActionDataType = {
        destinationHost: '9999',
        hosts: ['0000']
      } as ActionDataType;
      let item: mmsListType = new mmsListType();
      item.mmsSource = [{
        type: 3
      } as Mms, {
        type: 10,
        address: addressInfo
      } as Mms];

      mConversationCtrl.setRcsMsgType(actionData, item);

      let accuracy: number = 0;
      let arrLocInfo: string = item?.mmsSource[1]?.address?.name + ';' + item?.mmsSource[1]?.address?.address;
      let arrAddressInfo: [LooseObject] = [{
        'body': arrLocInfo,
        'longitude': item?.mmsSource[1]?.address?.longitude.toString(),
        'latitude': item?.mmsSource[1]?.address?.latitude.toString(),
        'accuracy': accuracy.toString(),
      }];
      let addressJson: string = JSON.stringify(arrAddressInfo);
      addressJson = addressJson.slice(1, -1);

      expect(actionData.content).assertEqual(addressJson);
    })

    it('ConversationControllerTest_setRcsMsgType_type_10', 0, () => {
      let actionData: ActionDataType = {
        destinationHost: '9999',
        hosts: ['0000']
      } as ActionDataType;
      let item: mmsListType = new mmsListType();
      item.mmsSource = [{
        type: 3
      } as Mms, {
        type: 10,
        content: '{"body":"name;address","longitude":"1","latitude":"1","accuracy":"0"}'
      } as Mms];

      mConversationCtrl.setRcsMsgType(actionData, item);
      let addressJson = '{"body":"name;address","longitude":"1","latitude":"1","accuracy":"0"}';

      expect(actionData.content).assertEqual(addressJson);
    })
  })
}