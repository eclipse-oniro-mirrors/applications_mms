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
import { afterEach, ArgumentMatchers, beforeEach, describe, expect, it, MockKit, when } from '@ohos/hypium';
import { GlobalContext } from '../../../../../main/ets/MainAbility/GlobalHelper';
import ConversationController, {
  ActionDataType,
  InsertResult,
  mmsListType,
  TransmitInfoType,
  TransmitSourceType,
  updateFavorite} from '../../../../../main/ets/pages/conversation/conversationController';
import { window } from '@kit.ArkUI';
import { resourceManager } from '@kit.LocalizationKit';
import { DTGlobalContext } from '../../../testability/TestAbility';
import DataShareHelper from '../../../../../main/ets/model/repository/DataShareHelper';
import { dataShare, dataSharePredicates, DataShareResultSet, ValuesBucket } from '@kit.ArkData';
import { ActionData, DraftModel, DraftUtils } from '../../../../../main/ets/utils/DraftUtils';
import { Context } from '@kit.AbilityKit';
import SharedPreferencesUtils from '../../../../../main/ets/utils/SharedPreferencesUtils';
import {DateUtil} from '../../../../../main/ets/utils/DateUtil';
import ConversationDataSource from '../../../../../main/ets/model/ConversationDataSource';
import LooseObject from '../../../../../main/ets/data/LooseObject';
import ConversationService from '../../../../../main/ets/service/ConversationService';
import common from "../../../../../main/ets/data/commonData";
import { aiDetectCallback, AiFaceChangeUtils } from '../../../../../main/ets/utils/AiFaceChangeUtils';
import { Action } from '@kit.InputKit';
import commonData from '../../../../../main/ets/data/commonData';
import ReportConnectServiceManager from '../../../../../main/ets/report/ReportConnectServiceManager';
import ReportSpamMessageManager from '../../../../../main/ets/report/ReportSpamMessageManager';
import { IQueryMessageDetailAll, IQueryMessageDetailInfo } from '../../../../../main/ets/model/type/ConversationParams';
import { StorageMessageTimeout } from '../../../../../main/ets/pages/conversation/StorageMessageTimeout';
import ContactsService from '../../../../../main/ets/service/ContactsService';
import DeviceUtil from '../../../../../main/ets/utils/DeviceUtil';
import MessageUtil from '../../../../../main/cust/utils/MessageUtil';
import DotUtil from '../../../../../main/ets/utils/MmsDot/DotUtils';
import DataService from '../../../../../main/ets/service/DataService';
import { Mms } from '../../../../../main/ets/utils/TypesUtils';

export default function conversationControllerPart8Test() {
  describe('conversationControllerTest8', () => {

    let mConversationCtrl: ConversationController;
    let mocker: MockKit;
    let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;

    beforeEach(() => {
      mocker = new MockKit();
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('mmsContext')
        .afterReturn({
          resourceManager: {
            getStringSync: (resource: Resource, ...args: (string | number)[]): string => {
              return '' + args[0] + ' ' + args[1];
            }
          } as resourceManager.ResourceManager
        } as Object | window.WindowStage);
      mConversationCtrl = ConversationController.getInstance();
    })

    afterEach(() => {
      mocker.clear(mConversationCtrl);
      mocker.clear(GlobalContext.getContext());
      AppStorage.clear();
    })

    it('ConversationControllerTest_isCbChecked_isIpMsg_isSimpleIpMsg', 0, () => {
      let mmsList = [
        {
          isRcs: 1,
          threadId: 2,
          isCbChecked: true,
          is_collect: false,
          isIpMsg: false,
          isSimpleIpMsg: false
        } as mmsListType,
        {
          isRcs: 1,
          threadId: 2,
          isCbChecked: true,
          is_collect: true,
          isIpMsg: true,
          isSimpleIpMsg: false
        } as mmsListType,
        {
          isRcs: 1,
          threadId: 2,
          isCbChecked: true,
          is_collect: true,
          isIpMsg: true,
          isSimpleIpMsg: true
        } as mmsListType,
        {
          isRcs: 0,
          threadId: 2,
          isCbChecked: true,
          is_collect: false
        } as mmsListType,
        {
          isRcs: 0,
          threadId: 2,
          isCbChecked: true,
          is_collect: true
        } as mmsListType];
      mConversationCtrl.mmsList = mmsList;
      expect(mConversationCtrl.isSelectedContainIpCardMsgItems())
        .message('isSelectedContainIpCardMsgItems test contains card ip msg failed.')
        .assertTrue();

      // 模拟未选中ip卡片消息场景
      mmsList[1].isCbChecked = false;
      expect(mConversationCtrl.isSelectedContainIpCardMsgItems())
        .message('isSelectedContainIpCardMsgItems test not contains card ip msg failed.')
        .assertFalse();
    })

    it('ConversationControllerTest_clearDirtyNoReceiverDraft', 0, () => {
      let mmsList0: mmsListType = new mmsListType();
      mmsList0.isRcs = 0;
      mmsList0.timeMillisecond = 0;
      mmsList0.sendStatus = 1;
      mmsList0.dateShow = true;
      mmsList0.showTitle = true;
      let mmsList1: mmsListType = new mmsListType();
      mmsList1.isRcs = 0;
      mmsList1.timeMillisecond = 1;
      mmsList1.sendStatus = 2;
      mmsList1.dateShow = true;
      mmsList1.showTitle = true;
      let mmsList2: mmsListType = new mmsListType();
      mmsList2.isRcs = 0;
      mmsList2.timeMillisecond = 1;
      mmsList2.sendStatus = 3;
      mmsList2.dateShow = true;
      mmsList2.showTitle = true;
      let draftItemList: mmsListType[] = [mmsList0, mmsList1, mmsList2];
      when(mocker.mockFunc(DraftUtils.getInstance(), DraftUtils.getInstance().deleteMessageByGroupIds))(ArgumentMatchers.any)
        .afterReturnNothing();
      let res: number = (mConversationCtrl as object)['clearDirtyNoReceiverDraft'](context, draftItemList);
      mocker.clear(DraftUtils.getInstance());
      expect(res).assertEqual(1);
    })

    it('ConversationControllerTest_fromNewConversationSend', 0, () => {
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))(ArgumentMatchers.any)
        .afterReturn(false);
      mConversationCtrl.fromNewConversationSend(context);
      mocker.clear(GlobalContext.getContext());
      expect(mConversationCtrl).not().assertUndefined();
    })

    it('ConversationControllerTest_getDraftTextData', 0, () => {
      when(mocker.mockFunc(DraftUtils, DraftUtils.getInstance))()
        .afterReturn({
          getDraftTextData:(context: Context, threadId: number, callback: Function) => {
            callback(['1','2','3','4'])
          }
        });
      mConversationCtrl.getDraftTextData(context);
      mocker.clear(DraftUtils);

      when(mocker.mockFunc(DraftUtils, DraftUtils.getInstance))()
        .afterReturn({
          getDraftTextData:(context: Context, threadId: number, callback: Function) => {
            callback(['1','2','3','4'])
          }
        });
      let dra = new DraftModel();
      mConversationCtrl.draftModel = dra;
      mConversationCtrl.getDraftTextData(context, false);
      mocker.clear(DraftUtils);
      expect(mConversationCtrl).not().assertUndefined();
    })

    it('ConversationControllerTest_checkIfNeedRefresh', 0, () => {
      AppStorage.setOrCreate('receiveSessionArray', ['110', '321']);
      when(mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences))(ArgumentMatchers.any)
        .afterReturn(true);
      mConversationCtrl.threadId = 321;
      mConversationCtrl.checkIfNeedRefresh(context);
      mocker.clear(SharedPreferencesUtils);
      expect(mConversationCtrl).not().assertUndefined();
      AppStorage.clear();
    })

    it('ConversationControllerTest_checkIfNeedRefresh_empty', 0, () => {
      AppStorage.setOrCreate('receiveSessionArray', []);
      when(mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences))(ArgumentMatchers.any)
        .afterReturn(false);
      mConversationCtrl.isBackHome = false;
      mConversationCtrl.threadId = 321;
      mConversationCtrl.checkIfNeedRefresh(context);
      mocker.clear(SharedPreferencesUtils);
      expect(mConversationCtrl).not().assertUndefined();
      AppStorage.clear();
    })

    it('ConversationControllerTest_onlyRefreshTime', 0, () => {
      let mmsList0: mmsListType = new mmsListType();
      mmsList0.isRcs = 0;
      mmsList0.timeMillisecond = 0;
      mmsList0.sendStatus = 1;
      mmsList0.dateShow = true;
      mmsList0.showTitle = true;
      let mmsList1: mmsListType = new mmsListType();
      mmsList1.isRcs = 0;
      mmsList1.timeMillisecond = 1;
      mmsList1.sendStatus = 2;
      mmsList1.dateShow = true;
      mmsList1.showTitle = true;
      let mmsList2: mmsListType = new mmsListType();
      mmsList2.isRcs = 0;
      mmsList2.timeMillisecond = new Date().getTime();
      mmsList2.sendStatus = 3;
      mmsList2.dateShow = true;
      mmsList2.showTitle = true;
      let mmsList: mmsListType[] = [mmsList0, mmsList1, mmsList2];
      AppStorage.setOrCreate('sysLocaleChanged', false);
      when(mocker.mockFunc(DateUtil, DateUtil.onlyUpdateSmsItemTime))(ArgumentMatchers.any)
        .afterReturnNothing();
      when(mocker.mockFunc(ConversationDataSource.getInstance(), ConversationDataSource.getInstance().refresh))(ArgumentMatchers.any)
        .afterReturnNothing();
      mConversationCtrl.mmsList = mmsList;
      mConversationCtrl.onlyRefreshTime();
      mocker.clear(SharedPreferencesUtils);
      mocker.clear(ConversationDataSource.getInstance());
      expect(mConversationCtrl).not().assertUndefined();
      AppStorage.clear();
    })

    it('ConversationControllerTest_dealWithOneContact', 0, () => {
      mConversationCtrl.strContactsName = '';
      mConversationCtrl.strContactsNumber = '110';
      mConversationCtrl.rawContactId = '1';
      mConversationCtrl.strContactsNumberFormat = '';
      (mConversationCtrl as object)['dealWithOneContact']([]);

      mConversationCtrl.strContactsNumberFormat = '911';
      (mConversationCtrl as object)['dealWithOneContact']([]);
      expect(mConversationCtrl).not().assertUndefined();
    })

    it('ConversationControllerTest_dealWithMultiContacts', 0, () => {
      mConversationCtrl.strContactsName = ', 911';
      mConversationCtrl.strContactsNumber = '110,911';
      mConversationCtrl.rawContactId = '1,3';
      mConversationCtrl.strContactsNumberFormat = ',911';
      mConversationCtrl.contactsNum = 2;
      mConversationCtrl.contactsNameList = ['110', '911'];
      (mConversationCtrl as object)['dealWithMultiContacts']([]);

      mConversationCtrl.strContactsName = '110,911';
      mConversationCtrl.strContactsNumber = '110,911';
      mConversationCtrl.rawContactId = '1,3';
      mConversationCtrl.strContactsNumberFormat = '110,911';
      mConversationCtrl.contactsNum = 1;
      mConversationCtrl.contactsNameList = ['110'];
      (mConversationCtrl as object)['dealWithMultiContacts']([]);
      expect(mConversationCtrl).not().assertUndefined();
    })

    it('ConversationControllerTest_initNewPageContacts', 0, () => {
      mConversationCtrl.strContactsName = '';
      mConversationCtrl.strContactsNumber = '110';
      mConversationCtrl.rawContactId = '1';
      mConversationCtrl.strContactsNumberFormat = '';
      mConversationCtrl.contactsNum = 1;
      mConversationCtrl.initNewPageContacts();

      mConversationCtrl.strContactsName = ', 911';
      mConversationCtrl.strContactsNumber = '110,911';
      mConversationCtrl.rawContactId = '1,3';
      mConversationCtrl.strContactsNumberFormat = ',911';
      mConversationCtrl.contactsNum = 2;
      mConversationCtrl.contactsNameList = ['110', '911'];
      mConversationCtrl.initNewPageContacts();
      expect(mConversationCtrl).not().assertUndefined();
    })

    it('ConversationControllerTest_getNetConnectType', 0, () => {
      let res = mConversationCtrl.getNetConnectType();
      expect(res).assertEqual('noNet');
    })

    it('ConversationControllerTest_checkRcsImageFaceDetect_faceDetectStatus_0', 0, () => {
      when(mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences))(ArgumentMatchers.any)
        .afterReturn(0);
      (mConversationCtrl as object)['checkRcsImageFaceDetect']('', context);
      mocker.clear(SharedPreferencesUtils);
      expect(mConversationCtrl).not().assertUndefined();
    })

    it('ConversationControllerTest_checkRcsImageFaceDetect_result_empty', 0, () => {
      when(mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences))(ArgumentMatchers.any)
        .afterReturn(1);
      (mConversationCtrl as object)['checkRcsImageFaceDetect']('', context);
      mocker.clear(SharedPreferencesUtils);
      expect(mConversationCtrl).not().assertUndefined();
    })

    it('ConversationControllerTest_checkRcsImageFaceDetect_partResult_empty', 0, () => {
      when(mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences))(ArgumentMatchers.any)
        .afterReturn(1);
      when(mocker.mockFunc(ConversationService, ConversationService.getInstance))(ArgumentMatchers.any)
        .afterReturn({
          queryMmsPartInfo: (actionData: LooseObject, callback: Function, context: Context) => {
            callback([])
          }
        });
      (mConversationCtrl as object)['checkRcsImageFaceDetect']('', context);
      mocker.clear(SharedPreferencesUtils);
      mocker.clear(ConversationService);
      expect(mConversationCtrl).not().assertUndefined();
    })

    it('ConversationControllerTest_checkRcsImageFaceDetect', 0, () => {
      when(mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences))(ArgumentMatchers.any)
        .afterReturn(1);
      when(mocker.mockFunc(ConversationService, ConversationService.getInstance))(ArgumentMatchers.any)
        .afterReturn({
          queryMmsPartInfo: (actionData: LooseObject, callback: Function, context: Context) => {
            callback([{locationPath: 'locationPath'} as LooseObject])
          }
        });
      (mConversationCtrl as object)['checkRcsImageFaceDetect']('', context);
      mocker.clear(SharedPreferencesUtils);
      mocker.clear(ConversationService);
      expect(mConversationCtrl).not().assertUndefined();
    })

    it('ConversationControllerTest_setDraftModel', 0, () => {
      let mmsList0: mmsListType = new mmsListType();
      mmsList0.isRcs = 0;
      mmsList0.timeMillisecond = 0;
      mmsList0.sendStatus = 1;
      mmsList0.dateShow = true;
      mmsList0.showTitle = true;
      let mmsList1: mmsListType = new mmsListType();
      mmsList1.isRcs = 0;
      mmsList1.timeMillisecond = 1;
      mmsList1.sendStatus = 2;
      mmsList1.dateShow = true;
      mmsList1.showTitle = true;
      let mmsList2: mmsListType = new mmsListType();
      mmsList2.isRcs = 0;
      mmsList2.timeMillisecond = new Date().getTime();
      mmsList2.sendStatus = 3;
      mmsList2.dateShow = true;
      mmsList2.showTitle = true;
      let mmsList: mmsListType[] = [mmsList0, mmsList1, mmsList2];
      let dra = new DraftModel();
      dra.actionData = new ActionData();
      dra.needDeleteSession = {isNeedDelete: false } as LooseObject;
      mConversationCtrl.draftModel = dra;
      mConversationCtrl.mmsList = mmsList;
      (mConversationCtrl as object)['timeoutID'] = 0;
      mConversationCtrl.setDraftModel((flag: boolean) => {});
      expect(mConversationCtrl).not().assertUndefined();
    })

    it('ConversationControllerTest_setDraftModel_else', 0, () => {
      let dra = new DraftModel();
      dra.actionData = new ActionData();
      dra.needDeleteSession = {isNeedDelete: false } as LooseObject;
      mConversationCtrl.draftModel = dra;
      mConversationCtrl.mmsList = [];
      (mConversationCtrl as object)['timeoutID'] = 0;
      mConversationCtrl.setDraftModel((flag: boolean) => {}, false);
      expect(mConversationCtrl).not().assertUndefined();
    })

    it('ConversationControllerTest_clearSelectContacts', 0, () => {
      mConversationCtrl.threadId = 1;
      mConversationCtrl.clearSelectContacts(true);
      mConversationCtrl.threadId = 0;
      mConversationCtrl.clearSelectContacts(true);
      expect(mConversationCtrl).not().assertUndefined();
    })

    it('ConversationControllerTest_gesTureListCheckBox', 0, () => {
      let mmsList0: mmsListType = new mmsListType();
      mmsList0.isRcs = 0;
      mmsList0.timeMillisecond = 0;
      mmsList0.sendStatus = 1;
      mmsList0.dateShow = true;
      mmsList0.isCbChecked = true;
      mmsList0.showTitle = true;
      let mmsList2: mmsListType = new mmsListType();
      mmsList2.isRcs = 0;
      mmsList2.timeMillisecond = new Date().getTime();
      mmsList2.sendStatus = 3;
      mmsList2.dateShow = true;
      mmsList0.isCbChecked = false;
      mmsList2.showTitle = true;
      let mmsList: mmsListType[] = [mmsList0, mmsList2];
      mConversationCtrl.mmsList = mmsList;
      mConversationCtrl.isMessageCheckAll = true;
      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.setGroupMoreMenu))(ArgumentMatchers.any).afterReturnNothing();
      mConversationCtrl.gesTureListCheckBox(1);
      mocker.clear(mConversationCtrl);
      expect(mConversationCtrl).not().assertUndefined();
    })

    it('ConversationControllerTest_gesTureListCheckBox_selectDeleteMsgCount_1', 0, () => {
      let mmsList0: mmsListType = new mmsListType();
      mmsList0.isRcs = 0;
      mmsList0.timeMillisecond = 0;
      mmsList0.sendStatus = 1;
      mmsList0.dateShow = true;
      mmsList0.isCbChecked = false;
      mmsList0.showTitle = true;
      let mmsList2: mmsListType = new mmsListType();
      mmsList2.isRcs = 0;
      mmsList2.timeMillisecond = new Date().getTime();
      mmsList2.sendStatus = 3;
      mmsList2.dateShow = true;
      mmsList0.isCbChecked = false;
      mmsList2.showTitle = true;
      let mmsList: mmsListType[] = [mmsList0, mmsList2];
      mConversationCtrl.mmsList = mmsList;
      mConversationCtrl.isMessageCheckAll = false;
      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.setGroupMoreMenu))(ArgumentMatchers.any).afterReturnNothing();
      mConversationCtrl.gesTureListCheckBox(1);
      mocker.clear(mConversationCtrl);
      expect(mConversationCtrl).not().assertUndefined();
    })

    it('ConversationControllerTest_gesTureListCheckBox_selectDeleteMsgCount_2', 0, () => {
      let mmsList0: mmsListType = new mmsListType();
      mmsList0.isRcs = 0;
      mmsList0.timeMillisecond = 0;
      mmsList0.sendStatus = 1;
      mmsList0.dateShow = true;
      mmsList0.isCbChecked = true;
      mmsList0.showTitle = true;
      let mmsList2: mmsListType = new mmsListType();
      mmsList2.isRcs = 0;
      mmsList2.timeMillisecond = new Date().getTime();
      mmsList2.sendStatus = 3;
      mmsList2.dateShow = true;
      mmsList0.isCbChecked = false;
      mmsList2.showTitle = true;
      let mmsList: mmsListType[] = [mmsList0, mmsList2];
      mConversationCtrl.mmsList = mmsList;
      mConversationCtrl.isMessageCheckAll = true;
      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.setGroupMoreMenu))(ArgumentMatchers.any).afterReturnNothing();
      mConversationCtrl.gesTureListCheckBox(2);
      mocker.clear(mConversationCtrl);
      expect(mConversationCtrl).not().assertUndefined();
    })

    it('ConversationControllerTest_judgeTheRcsMsgSourceFileDownloaded_mmsItem_undefined', 0, () => {
      mConversationCtrl.judgeTheRcsMsgSourceFileDownloaded(undefined);
      expect(mConversationCtrl).not().assertUndefined();
    })

    it('ConversationControllerTest_judgeTheRcsMsgSourceFileDownloaded_FILE', 0, () => {
      let mmsList0: mmsListType = new mmsListType();
      mmsList0.isRcs = 1;
      mmsList0.rcsType = commonData.ENHANCED_INFO_ITEM_TYPE.FILE;
      mmsList0.timeMillisecond = 0;
      mmsList0.sendStatus = 12;
      mmsList0.dateShow = true;
      mmsList0.isCbChecked = true;
      mmsList0.showTitle = true;
      mmsList0.mmsSource = [{
        duration: '',
        type: common.MM_ATTACHMENT_TYPE.IMAGE,
        path: 'data/file/123.png',
        name: '123'
      }];
      mConversationCtrl.judgeTheRcsMsgSourceFileDownloaded(mmsList0);
      expect(mConversationCtrl).not().assertUndefined();
    })

    it('ConversationControllerTest_judgeTheRcsMsgSourceFileDownloaded_AUDIO_FILE', 0, () => {
      let mmsList0: mmsListType = new mmsListType();
      mmsList0.isRcs = 1;
      mmsList0.rcsType = commonData.ENHANCED_INFO_ITEM_TYPE.FILE;
      mmsList0.timeMillisecond = 0;
      mmsList0.sendStatus = 1;
      mmsList0.dateShow = true;
      mmsList0.isCbChecked = true;
      mmsList0.showTitle = true;
      mmsList0.mmsSource = [{
        duration: '',
        type: common.MM_ATTACHMENT_TYPE.IMAGE,
        path: 'data/file/123.png',
        name: '123'
      }];
      mConversationCtrl.judgeTheRcsMsgSourceFileDownloaded(mmsList0);
      expect(mConversationCtrl).not().assertUndefined();
    })

    it('ConversationControllerTest_judgeTheRcsMsgSourceFileDownloaded_AUDIO', 0, () => {
      let mmsList0: mmsListType = new mmsListType();
      mmsList0.isRcs = 1;
      mmsList0.rcsType = commonData.ENHANCED_INFO_ITEM_TYPE.AUDIO;
      mmsList0.timeMillisecond = 0;
      mmsList0.sendStatus = 1;
      mmsList0.dateShow = true;
      mmsList0.isCbChecked = true;
      mmsList0.showTitle = true;
      mmsList0.mmsSource = [{
        duration: '',
        type: common.MM_ATTACHMENT_TYPE.IMAGE,
        path: 'data/file/123.png',
        name: '123'
      }];
      mConversationCtrl.judgeTheRcsMsgSourceFileDownloaded(mmsList0);
      expect(mConversationCtrl).not().assertUndefined();
    })

    it('ConversationControllerTest_judgeTheRcsMsgSourceFileDownloaded_VIDEO', 0, () => {
      let mmsList0: mmsListType = new mmsListType();
      mmsList0.isRcs = 1;
      mmsList0.rcsType = commonData.ENHANCED_INFO_ITEM_TYPE.VIDEO;
      mmsList0.timeMillisecond = 0;
      mmsList0.sendStatus = 1;
      mmsList0.dateShow = true;
      mmsList0.isCbChecked = true;
      mmsList0.showTitle = true;
      mmsList0.mmsSource = [{
        duration: '',
        type: common.MM_ATTACHMENT_TYPE.IMAGE,
        path: 'data/file/123.png',
        name: '123'
      }];
      mConversationCtrl.judgeTheRcsMsgSourceFileDownloaded(mmsList0);
      expect(mConversationCtrl).not().assertUndefined();
    })

    it('ConversationControllerTest_judgeTheRcsMsgSourceFileDownloaded_TEXT', 0, () => {
      let mmsList0: mmsListType = new mmsListType();
      mmsList0.isRcs = 1;
      mmsList0.rcsType = commonData.ENHANCED_INFO_ITEM_TYPE.TEXT;
      mmsList0.timeMillisecond = 0;
      mmsList0.sendStatus = 1;
      mmsList0.dateShow = true;
      mmsList0.isCbChecked = true;
      mmsList0.showTitle = true;
      mmsList0.mmsSource = [{
        duration: '',
        type: common.MM_ATTACHMENT_TYPE.IMAGE,
        path: 'data/file/123.png',
        name: '123'
      }];
      mConversationCtrl.judgeTheRcsMsgSourceFileDownloaded(mmsList0);
      expect(mConversationCtrl).not().assertUndefined();
    })

    it('ConversationControllerTest_judgeRcsFileNotDownload', 0, () => {
      let mmsList0: mmsListType = new mmsListType();
      mmsList0.isRcs = 0;
      mmsList0.rcsType = commonData.ENHANCED_INFO_ITEM_TYPE.VIDEO;
      mmsList0.timeMillisecond = 0;
      mmsList0.sendStatus = 1;
      mmsList0.dateShow = true;
      mmsList0.isCbChecked = true;
      mmsList0.showTitle = true;
      mmsList0.mmsSource = [{
        duration: '',
        type: common.MM_ATTACHMENT_TYPE.IMAGE,
        path: 'data/file/0.png',
        name: '0'
      }];
      let mmsList1: mmsListType = new mmsListType();
      mmsList1.isRcs = 0;
      mmsList1.rcsType = commonData.ENHANCED_INFO_ITEM_TYPE.AUDIO_FILE;
      mmsList1.timeMillisecond = 0;
      mmsList1.sendStatus = commonData.int.RCS_RECEIVING;
      mmsList1.dateShow = true;
      mmsList1.isCbChecked = true;
      mmsList1.showTitle = true;
      mmsList1.mmsSource = [{
        duration: '',
        type: common.MM_ATTACHMENT_TYPE.IMAGE,
        path: 'data/file/1.png',
        name: '1'
      }];
      let mmsList2: mmsListType = new mmsListType();
      mmsList2.isRcs = 0;
      mmsList2.rcsType = commonData.ENHANCED_INFO_ITEM_TYPE.FILE;
      mmsList2.timeMillisecond = 0;
      mmsList2.sendStatus = 3;
      mmsList2.dateShow = true;
      mmsList2.isCbChecked = true;
      mmsList2.showTitle = true;
      mmsList2.mmsSource = [{
        duration: '',
        type: common.MM_ATTACHMENT_TYPE.IMAGE,
        path: 'data/file/2.png',
        name: '2'
      }];
      let mmsList3: mmsListType = new mmsListType();
      mmsList3.isRcs = 0;
      mmsList3.rcsType = commonData.ENHANCED_INFO_ITEM_TYPE.TEXT;
      mmsList3.timeMillisecond = 0;
      mmsList3.sendStatus = 1;
      mmsList3.dateShow = true;
      mmsList3.isCbChecked = true;
      mmsList3.showTitle = true;
      mmsList3.mmsSource = [{
        duration: '',
        type: common.MM_ATTACHMENT_TYPE.IMAGE,
        path: 'data/file/0.txt',
        name: '3'
      }];
      let mmsList: mmsListType[] = [mmsList0, mmsList1, mmsList2, mmsList3];
      mConversationCtrl.mmsList = mmsList;
      mConversationCtrl.judgeRcsFileNotDownload();
      expect(mConversationCtrl).not().assertUndefined();
    })

    it('ConversationControllerTest_deleteRcsTypeIfNoSupport', 0, () => {
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
          mms: []
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
        mmsStatus: 0
      }
      let res = mConversationCtrl.deleteRcsTypeIfNoSupport(params);
      expect(res).not().assertUndefined();
    })

    it('ConversationControllerTest_deleteRcsTypeIfNoSupport_isOnlineRcs_true', 0, () => {
      AppStorage.setOrCreate('isOnlineRcs', true);
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
          mms: []
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
        mmsStatus: 0
      }
      mConversationCtrl.slotId = 1;
      mConversationCtrl.simSlotId = 1;
      let res = mConversationCtrl.deleteRcsTypeIfNoSupport(params);
      expect(res).not().assertUndefined();
    })

    it('ConversationControllerTest_formateDuration', 0, () => {
      let res1 = mConversationCtrl.formateDuration('63000');
      let res2 = mConversationCtrl.formateDuration('73000');
      let res3 = mConversationCtrl.formateDuration('350000');
      let res4 = mConversationCtrl.formateDuration('772000');
      let res5 = mConversationCtrl.formateDuration('728000');
      let res6 = mConversationCtrl.formateDuration('8040000');
      let res7 = mConversationCtrl.formateDuration('38660000');
      expect(res1 + res2 + res3 + res4 + res5 + res6 + res7).assertEqual('01:0301:1305:5012:5212:0802:14:0010:44:20');
    })

    it('ConversationControllerTest_shareMmsMessage', 0, () => {
      let res = mConversationCtrl.shareMmsMessage({
        isRcs: 0,
        threadId: 2,
        isCbChecked: true,
        is_collect: true,
        mmsSource:[
          {
            duration: '',
            type: 0,
            path: '',
            name: '123'
          },
          {
            duration: '',
            type: commonData.ENHANCED_INFO_ITEM_TYPE.FILE,
            path: '',
            name: '123'
          }
        ]
      } as mmsListType);
      expect(res).assertUndefined();
    })

    it('ConversationControllerTest_shareMmsMessage_FILE', 0, () => {
      let res = mConversationCtrl.shareMmsMessage({
        isRcs: 0,
        threadId: 2,
        isCbChecked: true,
        is_collect: true,
        mmsSource:[
          {
            duration: 'duration',
            type: commonData.ENHANCED_INFO_ITEM_TYPE.FILE,
            path: 'data/file/123.png',
            name: '123'
          }
        ]
      } as mmsListType);
      expect(res).assertUndefined();
    })

    it('ConversationControllerTest_shareMmsMessage_AUDIO', 0, () => {
      let res = mConversationCtrl.shareMmsMessage({
        isRcs: 0,
        threadId: 2,
        isCbChecked: true,
        is_collect: true,
        mmsSource:[
          {
            duration: 'duration',
            type: commonData.MM_ATTACHMENT_TYPE.AUDIO,
            path: 'data/file/123.png',
            name: '123'
          }
        ]
      } as mmsListType);
      expect(res).assertUndefined();
    })

    it('ConversationControllerTest_shareMmsMessage_IMAGE', 0, () => {
      let res = mConversationCtrl.shareMmsMessage({
        isRcs: 0,
        threadId: 2,
        isCbChecked: true,
        is_collect: true,
        mmsSource:[
          {
            duration: 'duration',
            type: commonData.MM_ATTACHMENT_TYPE.IMAGE,
            path: 'data/file/123.png',
            name: '123'
          }
        ]
      } as mmsListType);
      expect(res).not().assertUndefined();
    })

    it('ConversationControllerTest_shareMmsMessage_VIDEO', 0, () => {
      let res = mConversationCtrl.shareMmsMessage({
        isRcs: 0,
        threadId: 2,
        isCbChecked: true,
        is_collect: true,
        mmsSource:[
          {
            duration: 'duration',
            type: commonData.MM_ATTACHMENT_TYPE.VIDEO,
            path: 'data/file/123.png',
            name: '123'
          }
        ]
      } as mmsListType);
      expect(res).not().assertUndefined();
    })

    it('ConversationControllerTest_shareMessage_target_empty', 0, async () => {
      mConversationCtrl.mmsList = [{
        isRcs: 0,
        threadId: 2,
        isCbChecked: false,
        is_collect: true,
        mmsSource:[
          {
            duration: 'duration',
            type: commonData.ENHANCED_INFO_ITEM_TYPE.VIDEO,
            path: 'data/file/123.png',
            name: '123'
          }
        ]
      } as mmsListType];
      await mConversationCtrl.shareMessage(context);
      expect(mConversationCtrl).not().assertUndefined();
    })

    it('ConversationControllerTest_shareMessage_isMsm_true', 0, async () => {
      mConversationCtrl.mmsList = [{
        isRcs: 0,
        threadId: 2,
        isCbChecked: true,
        is_collect: true,
        isMsm: true,
        mmsSource:[
          {
            duration: 'duration',
            type: commonData.ENHANCED_INFO_ITEM_TYPE.VIDEO,
            path: 'data/file/123.png',
            name: '123'
          }
        ]
      } as mmsListType];
      await mConversationCtrl.shareMessage(context);
      expect(mConversationCtrl).not().assertUndefined();
    })

    it('ConversationControllerTest_shareMessage_isMsm_false', 0, async () => {
      mConversationCtrl.mmsList = [{
        isRcs: 0,
        threadId: 2,
        isCbChecked: true,
        is_collect: true,
        isMsm: false,
        mmsSource:[
          {
            duration: 'duration',
            type: commonData.ENHANCED_INFO_ITEM_TYPE.VIDEO,
            path: 'data/file/123.png',
            name: '123'
          }
        ]
      } as mmsListType];
      await mConversationCtrl.shareMessage(context);
      expect(mConversationCtrl).not().assertUndefined();
    })

    it('ConversationControllerTest_judgmentRemainingSpace', 0, () => {
      let res1: boolean = (mConversationCtrl as object)['judgmentRemainingSpace'](1);
      expect(res1).assertFalse();
      let res2: boolean = (mConversationCtrl as object)['judgmentRemainingSpace'](21);
      expect(res2).assertTrue();
    })

    it('ConversationControllerTest_dataCorrectionForPagingQuery', 0, () => {
      (mConversationCtrl as object)['dataCorrectionForPagingQuery'](-1);
      expect(mConversationCtrl).not().assertUndefined();
    })

    it('ConversationControllerTest_queryMessageDetailPreFillItem', 0, () => {
      let context = {
        resourceManager: {
          getStringSync: (resource: Resource, ...args: (string | number)[]): string => ''
        } as resourceManager.ResourceManager
      } as Context;
      let queryInfoObj: IQueryMessageDetailInfo = {
        isDraft: true,
        currentPage: 1,
        threadId: 0,
        contactsNum: 0,
        isDownloadQuery: false,
        notNeedScrollToEnd: false,
        resultTotal: 10,
        lastListSize: 1,
        queryTimeID: 0,
        startIndex: 0
      };
      mConversationCtrl.mmsList = [{
        dateShow: true,
        timeMillisecond: 0,
        showTitle: true,
        isSender: 0,
        isRcs: 0,
      } as mmsListType, {
        dateShow: true,
        timeMillisecond: 0,
        showTitle: true,
        isSender: 0,
        isRcs: 0,
      } as mmsListType];
      let queryActionData: IQueryMessageDetailAll = {
        threadId: queryInfoObj.threadId,
        page: queryInfoObj.currentPage,
        contactsNum: queryInfoObj.contactsNum,
        actionDataName: ''
      };
      mConversationCtrl.threadId = 1;
      AppStorage.setOrCreate('curBp', 'sm');
      mConversationCtrl.queryTerminate.set(0, 0);
      mConversationCtrl.vCardJumpBack = false;
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.setDraft)
      when(mocker.mockFunc(ConversationService, ConversationService.getInstance))(ArgumentMatchers.any)
        .afterReturn({
          queryMessageDetailAll: (context: Context, actionData: LooseObject, callback: Function, rcsCount:number) => {
            callback({code: 0} as LooseObject)
          }
        });
      when(mocker.mockFunc(ConversationDataSource.getInstance(), ConversationDataSource.getInstance().refreshPartial))(ArgumentMatchers.any)
        .afterReturnNothing();
      (mConversationCtrl as object)['queryMessageDetailPreFillItem'](context, queryInfoObj, queryActionData);

      mConversationCtrl.threadId = 0;
      (mConversationCtrl as object)['queryMessageDetailPreFillItem'](context, queryInfoObj, queryActionData);

      queryInfoObj.currentPage = 2;
      queryInfoObj.notNeedScrollToEnd = true;
      (mConversationCtrl as object)['queryMessageDetailPreFillItem'](context, queryInfoObj, queryActionData);
      mocker.clear(ConversationDataSource.getInstance());
      mocker.clear(ConversationService);
      mocker.clear(mConversationCtrl);
      expect(mConversationCtrl).not().assertUndefined();
    })

    it('ConversationControllerTest_sendMassMessage', 0, () => {
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

      when(mocker.mockFunc(ConversationService, ConversationService.getInstance))(ArgumentMatchers.any)
        .afterReturn({
          insertSessionAndDetail: (actionData: LooseObject, callback: Function, context: Context) => {
            callback({rowId: 1, initDatas:[{id: 0, telephone: '110'}], groupId:1} as InsertResult)
          }
        });
      AppStorage.setOrCreate('curBp', 'sm');
      mConversationCtrl.threadId = 1;
      mConversationCtrl.contactsNum = 0;
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.sendMessage)
      mocker.mockFunc(StorageMessageTimeout.getInstance(), StorageMessageTimeout.getInstance().sendMessageStorageAndTimeout)
      mConversationCtrl.sendMassMessage(context, actionData, {
        dateShow: true,
        timeMillisecond: 0,
        showTitle: true,
        isMsm: false,
        rcsType: 0,
        isSender: 0,
        isRcs: 1,
      } as mmsListType);
      mocker.clear(ConversationService);
      mocker.clear(mConversationCtrl);
      expect(mConversationCtrl).not().assertUndefined();
      AppStorage.clear();
    })

    it('ConversationControllerTest_reSortMmsList', 0, () => {
      mConversationCtrl.reSortMmsList(true, [{
        dateShow: true,
        timeMillisecond: 0,
        showTitle: true,
        isMsm: false,
        rcsType: 0,
        isSender: 0,
        isRcs: 1,
      } as mmsListType,{
        dateShow: true,
        timeMillisecond: 0,
        showTitle: true,
        isMsm: false,
        rcsType: 0,
        isSender: 0,
        isRcs: 1,
      } as mmsListType]);
      expect(mConversationCtrl).not().assertUndefined();
    })

    it('ConversationControllerTest_reSortMmsList_len2', 0, () => {
      mConversationCtrl.reSortMmsList(true, [{
        dateShow: true,
        timeMillisecond: 1000,
        showTitle: true,
        isMsm: false,
        rcsType: 0,
        isSender: 0,
        isRcs: 1,
      } as mmsListType,{
        dateShow: true,
        timeMillisecond: 0,
        showTitle: true,
        isMsm: false,
        rcsType: 0,
        isSender: 0,
        isRcs: 1,
      } as mmsListType]);
      expect(mConversationCtrl).not().assertUndefined();
    })

    it('ConversationControllerTest_checkFaceMmsStatus_faceDetectStatus_0', 0, async () => {
      when(mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences))(ArgumentMatchers.any)
        .afterReturn(0);
      await (mConversationCtrl as object)['checkFaceMmsStatus']('11', context);
      mocker.clear(SharedPreferencesUtils);
      expect(mConversationCtrl).not().assertUndefined();
    })

    it('ConversationControllerTest_checkFaceMmsStatus_faceDetectStatus_1_result_length_0', 0, async () => {
      when(mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences))(ArgumentMatchers.any)
        .afterReturn(1);
      when(mocker.mockFunc(ConversationService, ConversationService.getInstance))(ArgumentMatchers.any)
        .afterReturn({
          queryMmsPartInfo: (actionData: LooseObject, callback: Function, context: Context) => {
            callback([])
          }
        });
      await (mConversationCtrl as object)['checkFaceMmsStatus']('11', context);
      mocker.clear(SharedPreferencesUtils);
      mocker.clear(ConversationService);
      expect(mConversationCtrl).not().assertUndefined();
    })

    it('ConversationControllerTest_buildRcsSendMultipartyOptions', 0, async () => {
      let mmsList: mmsListType = new mmsListType();
      mmsList.isRcs = 1;
      mmsList.rcsType = commonData.ENHANCED_INFO_ITEM_TYPE.MAP;
      mmsList.timeMillisecond = 0;
      mmsList.sendStatus = 12;
      mmsList.dateShow = true;
      mmsList.isCbChecked = true;
      mmsList.showTitle = true;
      mmsList.mmsSource = [{
        duration: '01:00',
        type: common.ENHANCED_INFO_ITEM_TYPE.AUDIO_FILE,
        path: 'data/file/123.png',
        name: '123'
      },{
        duration: '01:00',
        type: common.ENHANCED_INFO_ITEM_TYPE.AUDIO_FILE,
        path: 'data/file/123.png',
        name: '123'
      }];
      let actionData: ActionDataType = {
        slotId: 1,
        destinationHost: '',
        content: 'xx',
        isEditMms: false,
        contactId: '1',
        contactName: 'xx',
        hosts: ['1111', '2222'],
        isReSend: false,
        id: undefined,
        isRcs: 1,
        resendStateIsRcs: true,
        threadId: 1,
        groupId: 0,
      } as ActionDataType;
      await (mConversationCtrl as object)['buildRcsSendMultipartyOptions'](mmsList, 'cc', ['1', '2'], actionData);
      expect(mConversationCtrl).not().assertUndefined();
    })

    it('ConversationControllerTest_generateLocalThumbnailForDisplay', 0, async () => {
      await (mConversationCtrl as object)['generateLocalThumbnailForDisplay']('', '');
      expect(mConversationCtrl).not().assertUndefined();
    })

    it('ConversationControllerTest_getRcsVideoThumbnailItemToMmsSource', 0, () => {
      (mConversationCtrl as object)['getRcsVideoThumbnailItemToMmsSource'](context, '');
      expect(mConversationCtrl).not().assertUndefined();
    })

    it('ConversationControllerTest_refreshUserInfoWithUpdateIdStr_updateIdStr_not_empty', 0, () => {
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.onContactDataChangeObserver);
      mConversationCtrl.refreshUserInfoWithUpdateIdStr(context, 't', ()=>{});
      mocker.clear(mConversationCtrl);
      expect(mConversationCtrl).not().assertUndefined();
    })

    it('ConversationControllerTest_refreshUserInfoWithUpdateIdStr_updateIdStr_empty_objc_undefined', 0, () => {
      when(mocker.mockFunc(ContactsService, ContactsService.getInstance))(ArgumentMatchers.any)
        .afterReturn({
          queryContactDataByCondition: async (actionData: LooseObject, callback: Function,
            context: Context) => {
            callback(undefined)
          }
        });
      mConversationCtrl.refreshUserInfoWithUpdateIdStr(context, '', ()=>{});
      mocker.clear(ContactsService);
      expect(mConversationCtrl).not().assertUndefined();
    })

    it('ConversationControllerTest_refreshUserInfoWithUpdateIdStr_updateIdStr_empty', 0, () => {
      when(mocker.mockFunc(DeviceUtil, DeviceUtil.isPC))().afterReturn(false);
      when(mocker.mockFunc(ContactsService, ContactsService.getInstance))(ArgumentMatchers.any)
        .afterReturn({
          queryContactDataByCondition: async (actionData: LooseObject, callback: Function,
            context: Context) => {
            callback({ abilityResult: [] } as LooseObject)
          }
        });
      mConversationCtrl.refreshUserInfoWithUpdateIdStr(context, '', ()=>{});

      when(mocker.mockFunc(DeviceUtil, DeviceUtil.isPC))().afterReturn(true);
      mConversationCtrl.refreshUserInfoWithUpdateIdStr(context, '', ()=>{});
      mocker.clear(ContactsService);
      mocker.clear(DeviceUtil);
      expect(mConversationCtrl).not().assertUndefined();
    })

    it('ConversationControllerTest_handleProtocolChange_content_empty', 0, async () => {
      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.isNeedChangeFromMmsToSms))(ArgumentMatchers.any)
        .afterReturn(false);
      when(mocker.mockFunc(MessageUtil, MessageUtil.replaceForLossy7Bit))(ArgumentMatchers.any).afterReturn('');
      when(mocker.mockFunc(MessageUtil, MessageUtil.isMmsText))(ArgumentMatchers.any)
        .afterReturn(new Promise<boolean>(resolve => resolve(false)));
      mConversationCtrl.handleProtocolChange('');
      mocker.clear(mConversationCtrl);

      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.isNeedChangeFromMmsToSms))(ArgumentMatchers.any)
        .afterReturn(true);
      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.changeValue))(ArgumentMatchers.any)
        .afterReturnNothing();
      mConversationCtrl.handleProtocolChange('');
      mocker.clear(MessageUtil);
      mocker.clear(mConversationCtrl);
      expect(mConversationCtrl).not().assertUndefined();
    })

    it('ConversationControllerTest_handleProtocolChange_content_not_empty', 0, async () => {
      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.isNeedChangeFromSmsToMms))(ArgumentMatchers.any)
        .afterReturn(true);
      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.showToast))(ArgumentMatchers.any)
        .afterReturnNothing();
      when(mocker.mockFunc(MessageUtil, MessageUtil.replaceForLossy7Bit))(ArgumentMatchers.any).afterReturn('');
      when(mocker.mockFunc(MessageUtil, MessageUtil.isMmsText))(ArgumentMatchers.any)
        .afterReturn(new Promise<boolean>(resolve => resolve(true)));
      mConversationCtrl.handleProtocolChange('f');
      mocker.clear(mConversationCtrl);

      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.isNeedChangeFromSmsToMms))(ArgumentMatchers.any)
        .afterReturn(false);
      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.isNeedChangeFromMmsToSms))(ArgumentMatchers.any)
        .afterReturn(true);
      mConversationCtrl.handleProtocolChange('f');
      mocker.clear(mConversationCtrl);

      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.isNeedChangeFromSmsToMms))(ArgumentMatchers.any)
        .afterReturn(false);
      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.isNeedChangeFromMmsToSms))(ArgumentMatchers.any)
        .afterReturn(false);
      mConversationCtrl.handleProtocolChange('f');
      mocker.clear(MessageUtil);
      mocker.clear(mConversationCtrl);
      expect(mConversationCtrl).not().assertUndefined();
    })

    it('ConversationControllerTest_sendChatbot_inRepairMode', 0, () => {
      when(mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences))(ArgumentMatchers.any)
        .afterReturn(true);
      mConversationCtrl.sendChatbot(context, '', '');
      mocker.clear(mConversationCtrl);
      mocker.clear(SharedPreferencesUtils);
      expect(mConversationCtrl).not().assertUndefined();
    })

    it('ConversationControllerTest_sendChatbot_isAirPlaneMode', 0, () => {
      mConversationCtrl.isAirPlaneMode = true;
      mConversationCtrl.isNewMsg = true;
      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.newSend))(ArgumentMatchers.any)
        .afterReturnNothing();
      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.showToast))(ArgumentMatchers.any)
        .afterReturnNothing();
      when(mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences))(ArgumentMatchers.any)
        .afterReturn(false);
      mConversationCtrl.sendChatbot(context, '', '');
      mocker.clear(mConversationCtrl);
      mocker.clear(SharedPreferencesUtils);
      expect(mConversationCtrl).not().assertUndefined();
    })

    it('ConversationControllerTest_sendChatbot_isNewMsg', 0, () => {
      mConversationCtrl.isAirPlaneMode = false;
      mConversationCtrl.isNewMsg = true;
      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.newSend))(ArgumentMatchers.any)
        .afterReturnNothing();
      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.sendChatbotDataRefresh))(ArgumentMatchers.any)
        .afterReturnNothing();
      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.publishData))(ArgumentMatchers.any)
        .afterReturnNothing();
      when(mocker.mockFunc(DotUtil.getInstance(), DotUtil.getInstance().reportSuccessRateForSendStart))(ArgumentMatchers.any)
        .afterReturnNothing();
      when(mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences))(ArgumentMatchers.any)
        .afterReturn(false);
      mConversationCtrl.sendChatbot(context, '', '');
      mocker.clear(mConversationCtrl);
      mocker.clear(DotUtil.getInstance());
      mocker.clear(SharedPreferencesUtils);
      expect(mConversationCtrl).not().assertUndefined();
    })

    it('ConversationControllerTest_sendChatbot_isNewMsg_false', 0, () => {
      mConversationCtrl.isAirPlaneMode = false;
      mConversationCtrl.isNewMsg = false;
      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.sendChatbotDataRefresh))(ArgumentMatchers.any)
        .afterReturnNothing();
      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.publishData))(ArgumentMatchers.any)
        .afterReturnNothing();
      when(mocker.mockFunc(DotUtil.getInstance(), DotUtil.getInstance().reportSuccessRateForSendStart))(ArgumentMatchers.any)
        .afterReturnNothing();
      when(mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences))(ArgumentMatchers.any)
        .afterReturn(false);
      mConversationCtrl.sendChatbot(context, '', '');
      mocker.clear(DotUtil.getInstance());
      mocker.clear(mConversationCtrl);
      mocker.clear(SharedPreferencesUtils);
      expect(mConversationCtrl).not().assertUndefined();
    })

    it('ConversationControllerTest_sendChatbotDataRefresh', 0, async () => {
      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.updateSimSlotId))(ArgumentMatchers.any)
        .afterReturnNothing();
      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.initChatbotItem))(ArgumentMatchers.any)
        .afterReturnNothing();
      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.sendInterval))(ArgumentMatchers.any)
        .afterReturnNothing();
      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.resetMmsSource))(ArgumentMatchers.any)
        .afterReturnNothing();
      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.setTabOperationStatus))(ArgumentMatchers.any)
        .afterReturnNothing();
      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.clearSelectContacts))(ArgumentMatchers.any)
        .afterReturnNothing();
      when(mocker.mockFunc(DotUtil.getInstance(), DotUtil.getInstance().reportSuccessRateForSendStart))(ArgumentMatchers.any)
        .afterReturnNothing();
      when(mocker.mockFunc(DataService, DataService.getDefaultCellularDataSlotId))(ArgumentMatchers.any)
        .afterReturn(new Promise<number>(resolve => resolve(1)));
      await mConversationCtrl.sendChatbotDataRefresh(context, '', '');
      await mConversationCtrl.sendChatbotDataRefresh(context, '', '', 'data', true, 'trafficType', 'contributionId');
      mocker.clear(DotUtil.getInstance());
      mocker.clear(mConversationCtrl);
      mocker.clear(DataService);
      expect(mConversationCtrl).not().assertUndefined();
    })

    it('ConversationControllerTest_scrollToSlideIndex', 0, () => {
      mConversationCtrl.slideMmsIndex = 1;
      mConversationCtrl.slideYOffset = 1;
      mConversationCtrl.scrollToSlideIndex();

      mConversationCtrl.slideMmsIndex = -1;
      mConversationCtrl.scrollToSlideIndex();
      expect(mConversationCtrl).not().assertUndefined();
    })

    it('ConversationControllerTest_sendMessageIsHasMap', 0, () => {
      mConversationCtrl.mAttachAreaCtrl.mmDisplaySource = [];
      mConversationCtrl.sendMessageIsHasMap();

      let mms: Mms = {
        type: 1,
        copyPath: '',
        name: 'name',
        galleryPath: '',
        path: '',
        size: '1'
      } as Mms;
      let mms1: Mms = {
        type: commonData.ENHANCED_INFO_ITEM_TYPE.MAP,
        copyPath: '',
        name: 'name',
        galleryPath: undefined,
        path: '/',
        size: '1'
      } as Mms;
      mConversationCtrl.mAttachAreaCtrl.mmDisplaySource = [mms, mms1];
      mConversationCtrl.sendMessageIsHasMap();
      expect(mConversationCtrl).not().assertUndefined();
    })

    it('ConversationControllerTest_updateFavorite', 0, () => {
      updateFavorite('');
      updateFavorite('test');
      AppStorage.clear();
      expect(mConversationCtrl).not().assertUndefined();
    })

    it('ConversationControllerTest_setMessageData', 0, () => {
      let actionData: ActionDataType = {
        slotId: 1,
        destinationHost: '',
        content: '{}',
        isEditMms: false,
        contactId: '1',
        contactName: 'xx',
        data: '',
        hosts: ['1111', '2222'],
        isReSend: true,
        id: undefined,
        isRcs: 1,
        resendStateIsRcs: true,
        threadId: 1,
        groupId: 0,
      } as ActionDataType;
      mConversationCtrl.setMessageData(actionData);

      actionData.data = 'data';
      mConversationCtrl.setMessageData(actionData);
      expect(mConversationCtrl).not().assertUndefined();
    })
  })
}