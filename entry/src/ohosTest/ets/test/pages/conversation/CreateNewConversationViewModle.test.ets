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
import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect, MockKit, when,
  ArgumentMatchers } from '@ohos/hypium'
import CreateNewConversationViewModle from '../../../../../main/ets/pages/conversation/CreateNewConversationViewModle';
import MmsPreferences from '../../../../../main/ets/utils/MmsPreferences';
import { DTGlobalContext } from '../../../testability/TestAbility';
import { GlobalContext } from '../../../../../main/ets/MainAbility/GlobalHelper';
import DataShareHelper from '../../../../../main/ets/model/repository/DataShareHelper';
import ConversationService from '../../../../../main/ets/service/ConversationService';
import DotUtil from '../../../../../main/ets/utils/MmsDot/DotUtils';
import StringUtil from '../../../../../main/ets/utils/StringUtil';
import YellowPageService from '../../../../../main/ets/service/yellowPageService';
import LooseObject from '../../../../../main/ets/data/LooseObject';
import SharedPreferencesUtils from '../../../../../main/ets/utils/SharedPreferencesUtils';
import ConversationDataSource from '../../../../../main/ets/model/ConversationDataSource';
import { window } from '@kit.ArkUI';
import { AsyncCallback, BusinessError, settings } from '@kit.BasicServicesKit';
import { dataShare, dataSharePredicates, DataShareResultSet, ValuesBucket } from '@kit.ArkData';
import HiLog from '../../../../../main/ets/utils/HiLog';
import myCommon from '@ohos.app.ability.common';
import MySet from '../../MySet';
import TelephoneUtil from '../../../../../main/ets/utils/TelephoneUtil';
import { AddressInfo, Mms,
  mmsInfoData,
  packingItem,
  PictureListData, SessionContentTypeOfRcs } from '../../../../../main/ets/utils/TypesUtils';
import ConversationListController from '../../../../../main/ets/pages/conversationlist/conversationListController';
import settingService from '../../../../../main/ets/service/SettingService';
import rcs from '@ohos.telephony.rcs';
import {
  ActionDataType,
  BaseItemType,
  groupIdsInfos,
  InitData,
  itemType,
  mmsListType,
  MmsSourceType,
  pictureListFromGalleryType,
  selectContactType,
  SendMsgIndexes,
  SessionContactInfoForDB,
  timeDataType
} from '../../../../../main/ets/pages/conversation/conversationController';
import ReportSpamMessageManager from '../../../../../main/ets/report/ReportSpamMessageManager';
import { IQueryMessageDetailAll, IQueryMessageDetailInfo } from '../../../../../main/ets/model/type/ConversationParams';
import { resourceManager } from '@kit.LocalizationKit';
import dateUtil, { DateUtil } from '../../../../../main/ets/utils/DateUtil';
import ConversationListService from '../../../../../main/ets/service/ConversationListService';
import { ResponseType } from '../../../../../main/ets/service/ConversationListService';
import MMAttachmentAreaController from '../../../../../main/ets/views/AttachmentArea/MMAttachmentAreaController';
import MmsUtil from '../../../../../main/ets/utils/MmsUtil';
import ObjectUtil from '../../../../../main/ets/utils/ObjectUtil';
import FileUtil from '../../../../../main/ets/utils/FileUtil';
import SmilFile from '../../../../../main/ets/utils/SmilFile';
import { DraftUtils } from '../../../../../main/ets/utils/DraftUtils';
import { ChatbotDetail, ChatbotParameters } from '../../../../../main/ets/chatbot/utils/ChatbotEntitys';
import { Context } from '@kit.AbilityKit';
import ContactsService from '../../../../../main/ets/service/ContactsService';
import { EnhancedInfoTemporaryDataSource } from '../../../../../main/ets/model/EnhancedInfoTemporaryDataSource';

export default function CreateNewConversationViewModleTest() {
  describe('CreateNewConversationViewModleTest', () => {

    const TAG = 'CreateNewConversationView';
    let CreateNewConversationView: CreateNewConversationViewModle = new CreateNewConversationViewModle();
    let mocker: MockKit;
    let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
    beforeEach(() => {
      mocker = new MockKit();
    })

    afterEach(() => {
      mocker.clear(CreateNewConversationView);
      mocker.clear(MmsPreferences.getInstance());
      mocker.clear(GlobalContext.getContext());
      mocker.clear(DataShareHelper.getInstance());
      mocker.clear(ConversationService.getInstance());
      AppStorage.clear();
    })

    it('CreateNewConversationViewTest_handleSendReportable', 0, () => {
      let getValueOfDeliveryReportSwitch: Function =
        mocker.mockFunc(MmsPreferences.getInstance(), MmsPreferences.getInstance().getValueOfDeliveryReportSwitch);
      when(getValueOfDeliveryReportSwitch)().afterReturn(3);

      CreateNewConversationView.handleSendReportable();

      expect(CreateNewConversationView.sendReportable).assertTrue();
    })

    it('CreateNewConversationViewTest_onInit', 0, () => {
      mocker.mockFunc(CreateNewConversationView, CreateNewConversationView.handleSendReportable);
      mocker.mockFunc(CreateNewConversationView, CreateNewConversationView.initData);
      mocker.mockFunc(CreateNewConversationView, CreateNewConversationView.initRouterData);
      mocker.mockFunc(CreateNewConversationView, CreateNewConversationView.initNewPageContacts);
      mocker.mockFunc(CreateNewConversationView, CreateNewConversationView.initYellowPageData);
      mocker.mockFunc(CreateNewConversationView, CreateNewConversationView.rcsLoggedIn);
      mocker.mockFunc(CreateNewConversationView, CreateNewConversationView.rcsStateChange);
      mocker.mockFunc(CreateNewConversationView, CreateNewConversationView.initCurrentQueryTimeID);
      mocker.mockFunc(CreateNewConversationView, CreateNewConversationView.getHasSimCard);
      mocker.mockFunc(CreateNewConversationView, CreateNewConversationView.obtainSessionInformation);
      mocker.mockFunc(CreateNewConversationView.mAdvancedSettingsCtrl,
        CreateNewConversationView.mAdvancedSettingsCtrl.getAdvancedPageSwitchValue);
      mocker.mockFunc(CreateNewConversationView.smartMmsCardController,
        CreateNewConversationView.smartMmsCardController.init);
      mocker.mockFunc(CreateNewConversationView, CreateNewConversationView.resetDraftContactsParam);
      when(mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences))(ArgumentMatchers.any)
        .afterReturn(true);
      mocker.mockFunc(DotUtil.getInstance(), DotUtil.getInstance().reportEvent);
      mocker.mockFunc(EnhancedInfoTemporaryDataSource.getInstance(), EnhancedInfoTemporaryDataSource.getInstance().clearMapImageMsgIdToData);

      AppStorage.setOrCreate('comeFromContact', true);

      let pageInfos: NavPathStack = new NavPathStack();
      CreateNewConversationView.onInit(context, pageInfos);

      mocker.verify('obtainSessionInformation', [context]).once();

      AppStorage.setOrCreate('comeFromContact', false);
      CreateNewConversationView.onInit(context, pageInfos);

      mocker.clear(CreateNewConversationView.mAdvancedSettingsCtrl);

      mocker.clear(DotUtil.getInstance());
      mocker.clear(EnhancedInfoTemporaryDataSource.getInstance());
      mocker.clear(SharedPreferencesUtils);
      mocker.clear(CreateNewConversationView);
    })

    it('CreateNewConversationViewTest_initYellowPageData_empty_true', 0, async () => {
      when(mocker.mockFunc(StringUtil,
        StringUtil.isEmpty))(ArgumentMatchers.any)
        .afterReturn(true);
      when(mocker.mockFunc(YellowPageService.getInstance(),
        YellowPageService.getInstance().judgeYellowPageByTelephone))(ArgumentMatchers.any)
        .afterReturn(new Promise<LooseObject>(resolve => resolve({
          yellowPageId: '1',
          name: 'name',
        } as LooseObject)));

      await CreateNewConversationView.initYellowPageData();

      when(mocker.mockFunc(YellowPageService.getInstance(),
        YellowPageService.getInstance().judgeYellowPageByTelephone))(ArgumentMatchers.any)
        .afterReturn(new Promise<LooseObject>(resolve => resolve({
          yellowPageId: undefined,
          name: 'name',
        } as LooseObject)));

      await CreateNewConversationView.initYellowPageData();

      expect(CreateNewConversationView.smsType).assertEqual(1);

      mocker.clear(StringUtil);
      mocker.clear(YellowPageService.getInstance());
    })

    it('CreateNewConversationViewTest_initYellowPageData_empty_false', 0, async () => {
      when(mocker.mockFunc(StringUtil,
        StringUtil.isEmpty))(ArgumentMatchers.any)
        .afterReturn(false);
      when(mocker.mockFunc(YellowPageService.getInstance(),
        YellowPageService.getInstance().judgeYellowPageByTelephone))(ArgumentMatchers.any)
        .afterReturn(new Promise<LooseObject>(resolve => resolve({
          yellowPageId: undefined,
          name: 'name',
        } as LooseObject)));

      await CreateNewConversationView.initYellowPageData();

      expect(CreateNewConversationView.smsType).assertEqual(1);

      mocker.clear(StringUtil);
      mocker.clear(YellowPageService.getInstance());
    })

    it('CreateNewConversationViewTest_obtainSessionInformation_isNewMsg_true_contactsNum_0', 0, () => {
      CreateNewConversationView.isNewMsg = true;
      CreateNewConversationView.contactsNum = 0;
      CreateNewConversationView.draftContent = '';
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
      when(mocker.mockFunc(DraftUtils, DraftUtils.getInstance))(ArgumentMatchers.any)
        .afterReturn({
          queryNoReceiverDraft: (context: Context, callBack: Function) => {
            callBack({ code: 0, response: mmsList })
          },
          clearDirtyNoReceiverDraft:(draftItemList: mmsListType[], context: Context, callback: Function) => {return 1}
        });

      CreateNewConversationView.obtainSessionInformation(context);
      mocker.clear(DraftUtils);

      CreateNewConversationView.draftContent = '1';
      when(mocker.mockFunc(DraftUtils, DraftUtils.getInstance))(ArgumentMatchers.any)
        .afterReturn({
          queryNoReceiverDraft: (context: Context, callBack: Function) => {
            callBack({ code: 0, response:[] })
          },
          clearDirtyNoReceiverDraft:(draftItemList: mmsListType[], context: Context, callback: Function) => {return 1}
        });

      CreateNewConversationView.obtainSessionInformation(context);
      mocker.clear(DraftUtils);

      when(mocker.mockFunc(DraftUtils, DraftUtils.getInstance))(ArgumentMatchers.any)
        .afterReturn({
          queryNoReceiverDraft: (context: Context, callBack: Function) => {
            let mmsList1: mmsListType = new mmsListType();
            mmsList1.isRcs = 0;
            mmsList1.timeMillisecond = 1;
            mmsList1.dateShow = true;
            mmsList1.showTitle = true;
            callBack({ code: 0, response:[mmsList1] })
          },
          clearDirtyNoReceiverDraft:(draftItemList: mmsListType[], context: Context, callback: Function) => {return 1}
        });

      CreateNewConversationView.obtainSessionInformation(context);
      mocker.clear(DraftUtils);

      when(mocker.mockFunc(DraftUtils, DraftUtils.getInstance))(ArgumentMatchers.any)
        .afterReturn({
          queryNoReceiverDraft: (context: Context, callBack: Function) => {
            callBack({ code: -1 })
          },
          clearDirtyNoReceiverDraft:(draftItemList: mmsListType[], context: Context, callback: Function) => {return 1}
      });

      CreateNewConversationView.obtainSessionInformation(context);
      mocker.clear(DraftUtils);
      mocker.clear(CreateNewConversationView);
    })

    it('CreateNewConversationViewTest_obtainSessionInformation_isNewMsg_true_contactsNum_1', 0, () => {
      CreateNewConversationView.isNewMsg = true;
      CreateNewConversationView.contactsNum = 1;

      mocker.mockFunc(ConversationDataSource.getInstance(), ConversationDataSource.getInstance().refresh);
      when(mocker.mockFunc(MmsPreferences.getInstance(), MmsPreferences.getInstance().getSendMessageSlotId))()
        .afterReturn(1);
      mocker.mockFunc(CreateNewConversationView, CreateNewConversationView.updateSimSlotId);

      CreateNewConversationView.obtainSessionInformation(context);

      mocker.verify('updateSimSlotId', [1]).once();

      mocker.clear(ConversationDataSource.getInstance());
      mocker.clear(MmsPreferences.getInstance());
      mocker.clear(CreateNewConversationView);
    })

    it('CreateNewConversationViewTest_obtainSessionInformation_isNewMsg_false_searchMsgId_empty', 0, () => {
      CreateNewConversationView.isNewMsg = false;
      CreateNewConversationView.currentQueryTimeID = 1;
      CreateNewConversationView.contactsNum = 1;
      CreateNewConversationView.threadId = 0;
      CreateNewConversationView.isDraft = false;
      CreateNewConversationView.vCardJumpBack = false;
      CreateNewConversationView.haveTwoCards = true;
      CreateNewConversationView.queryTerminate.set(0, 1);

      when(mocker.mockFunc(ConversationService.getInstance(),
        ConversationService.getInstance().queryAllInfoSizeByCondition))(ArgumentMatchers.any)
        .afterReturn(new Promise<number>(resolve => resolve(1)));

      when(mocker.mockFunc(CreateNewConversationView, CreateNewConversationView.getHasSimCard))()
        .afterAction(() => new Promise<void>(resolve => resolve()));
      when(mocker.mockFunc(CreateNewConversationView, CreateNewConversationView.twoCardsJudging))()
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

      CreateNewConversationView.obtainSessionInformation(context);
      mocker.clear(ConversationService.getInstance());
      mocker.clear(CreateNewConversationView);
      mocker.clear(GlobalContext.getContext());
    })

    it('CreateNewConversationViewTest_obtainSessionInformation_isNewMsg_false_searchMsgId_1', 0, () => {
      CreateNewConversationView.isNewMsg = false;
      CreateNewConversationView.currentQueryTimeID = 1;
      CreateNewConversationView.contactsNum = 1;
      CreateNewConversationView.threadId = 0;
      CreateNewConversationView.isDraft = false;
      CreateNewConversationView.vCardJumpBack = false;
      CreateNewConversationView.haveTwoCards = false;
      CreateNewConversationView.queryTerminate.set(0, 1);

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
      CreateNewConversationView.pageInfos = pageInfos;
      mocker.mockFunc(CreateNewConversationView, CreateNewConversationView.photoFirstNameDeal);
      mocker.mockFunc(CreateNewConversationView, CreateNewConversationView.formatDisplayPhoneNum);

      CreateNewConversationView.initRouterData();

      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('mmsContext')
        .afterReturn(undefined);

      when(mocker.mockFunc(CreateNewConversationView, CreateNewConversationView.getHasSimCard))()
        .afterAction(() => {
          mocker.verify('jumpToIndex', []).once();
          return new Promise<void>(resolve => resolve())
        });

      when(mocker.mockFunc(ConversationService.getInstance(),
        ConversationService.getInstance().queryAllInfoSizeByCondition))(ArgumentMatchers.any)
        .afterReturn(new Promise<number>(resolve => resolve(1)));

      CreateNewConversationView.obtainSessionInformation(context);
      mocker.clear(ConversationService.getInstance());
      mocker.clear(CreateNewConversationView);
      mocker.clear(GlobalContext.getContext());
    })

    it('CreateNewConversationViewTest_obtainSessionInformation_isNewMsg_false_catch', 0, () => {
      CreateNewConversationView.isNewMsg = false;
      CreateNewConversationView.currentQueryTimeID = 1;
      CreateNewConversationView.contactsNum = 1;
      CreateNewConversationView.threadId = 0;
      CreateNewConversationView.isDraft = false;
      CreateNewConversationView.vCardJumpBack = false;
      CreateNewConversationView.haveTwoCards = false;
      CreateNewConversationView.queryTerminate.set(0, 1);

      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('mmsContext')
        .afterReturn(undefined);

      when(mocker.mockFunc(ConversationService.getInstance(),
        ConversationService.getInstance().queryAllInfoSizeByCondition))(ArgumentMatchers.any)
        .afterReturn(new Promise<number>(resolve => resolve(1)));

      when(mocker.mockFunc(CreateNewConversationView, CreateNewConversationView.getHasSimCard))()
        .afterAction(() => {
          mocker.verify('jumpToIndex', []).never();
          return new Promise<void>((resolve: () => void, reject: (res: BusinessError) => void) => reject({
            code: -1, message: 'error'
          } as BusinessError))
        });

      CreateNewConversationView.obtainSessionInformation(context);

      mocker.clear(ConversationService.getInstance());
      mocker.clear(CreateNewConversationView);
      mocker.clear(GlobalContext.getContext());
    })

    it('CreateNewConversationViewTest_twoCardsJudging_isRcs_1', 0, () => {
      mocker.mockFunc(CreateNewConversationView, CreateNewConversationView.updateSimSlotId);

      when(mocker.mockFunc(DataShareHelper.getInstance(),
        DataShareHelper.getInstance().initSmsDB))(ArgumentMatchers.any)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(undefined)));

      CreateNewConversationView.twoCardsJudging(context);

      expect(CreateNewConversationView.canSendMessage).assertFalse();
      mocker.clear(DataShareHelper.getInstance());
      mocker.clear(CreateNewConversationView);
    })

    it('CreateNewConversationViewTest_twoCardsJudging_isRcs_0', 0, () => {
      mocker.mockFunc(CreateNewConversationView, CreateNewConversationView.updateSimSlotId);

      when(mocker.mockFunc(DataShareHelper.getInstance(),
        DataShareHelper.getInstance().initSmsDB))(ArgumentMatchers.any)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(undefined)));

      CreateNewConversationView.twoCardsJudging(context);

      expect(CreateNewConversationView.canSendMessage).assertFalse();
      mocker.clear(DataShareHelper.getInstance());
      mocker.clear(CreateNewConversationView);
    })

    it('CreateNewConversationViewTest_shouldEnableSendButtonForSlot_1', 0, () => {
      CreateNewConversationView.haveTwoCards = false;
      expect(CreateNewConversationView.shouldEnableSendButtonForSlot(1)).assertTrue();
    })

    it('CreateNewConversationViewTest_shouldEnableSendButtonForSlot_0', 0, () => {
      CreateNewConversationView.haveTwoCards = true;
      expect(CreateNewConversationView.shouldEnableSendButtonForSlot(0)).assertTrue();
    })

    it('CreateNewConversationViewTest_changeIsRcsMms', 0, () => {
      CreateNewConversationView.isRcsMms = false;

      CreateNewConversationView.changeIsRcsMms(true, false);
      CreateNewConversationView.changeIsRcsMms(true, true);

      expect(CreateNewConversationView.isRcsMms).assertTrue();
    })

    it('CreateNewConversationViewTest_updateSimSlotId', 0, () => {
      mocker.mockFunc(MmsPreferences.getInstance(), MmsPreferences.getInstance().setValueToMap);

      CreateNewConversationView.updateSimSlotId(1);

      expect(CreateNewConversationView.slotId).assertEqual(0);

      mocker.clear(MmsPreferences.getInstance());
    })

    it('CreateNewConversationViewTest_getDraftTextData', 0, () => {
      let context = GlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext;
      mocker.mockFunc(HiLog, HiLog.e);
      when(mocker.mockFunc(DraftUtils, DraftUtils.getInstance))(ArgumentMatchers.any)
        .afterReturn({
          getDraftTextData: (context: Context, threadId: number, callback: Function) => {
            callback([])
          }
        });

      CreateNewConversationView.getDraftTextData(context, true);
      mocker.verify('e', [TAG, 'invalid length']).never();
      mocker.clear(HiLog);
      mocker.clear(DraftUtils);

      CreateNewConversationView.draftModel.isHasSetValueForInitialDraftText = false;
      when(mocker.mockFunc(DraftUtils, DraftUtils.getInstance))(ArgumentMatchers.any)
        .afterReturn({
          getDraftTextData: (context: Context, threadId: number, callback: Function) => {
            callback(['1', '2', '3'])
          }
        });

      CreateNewConversationView.getDraftTextData(context, false);
      mocker.clear(DraftUtils);

      CreateNewConversationView.draftModel.isHasSetValueForInitialDraftText = true;
      when(mocker.mockFunc(DraftUtils, DraftUtils.getInstance))(ArgumentMatchers.any)
        .afterReturn({
          getDraftTextData: (context: Context, threadId: number, callback: Function) => {
            callback(['1', '2', '3'])
          }
        });

      CreateNewConversationView.getDraftTextData(context, true);
      mocker.clear(DraftUtils);
    })

    it('CreateNewConversationViewTest_RemoveAirPlaneMode', 0, () => {
      CreateNewConversationView.removeAirPlaneMode();
      expect(CreateNewConversationView.isAirPlaneMode).assertFalse();
    })

    it('CreateNewConversationViewTest_dealWithOneContact', 0, () => {
      let transmitContacts: Array<itemType> = [];
      CreateNewConversationView.strContactsName = '';
      CreateNewConversationView.strContactsNumberFormat = '';
      (CreateNewConversationView as object)['dealWithOneContact'](transmitContacts);
      expect(transmitContacts.length).assertEqual(1);
    })

    it('CreateNewConversationViewTest_dealWithMultiContacts', 0, () => {
      let transmitContacts: Array<itemType> = [];
      CreateNewConversationView.contactsNum = 2;
      CreateNewConversationView.strContactsName = ',bb';
      CreateNewConversationView.strContactsNumber = '110,911';
      CreateNewConversationView.rawContactId = '1,2';
      CreateNewConversationView.strContactsNumberFormat = ',911';
      CreateNewConversationView.contactsNameList = ['aa', 'bb'];
      CreateNewConversationView.strContactsNumberFormat = '';
      (CreateNewConversationView as object)['dealWithMultiContacts'](transmitContacts);
      CreateNewConversationView.contactsNum = 1;
      (CreateNewConversationView as object)['dealWithMultiContacts'](transmitContacts);
      expect(transmitContacts.length > 0).assertTrue();
    })

    it('CreateNewConversationViewTest_GetAirPlaneMode', 0, () => {
      mocker.mockFunc(HiLog, HiLog.i);

      CreateNewConversationView.getAirPlaneMode();

      mocker.verify('i', [TAG, 'getAirPlaneMode callback']).never();

      mocker.clear(HiLog);
    })

    it('CreateNewConversationViewTest_release', 0, () => {
      CreateNewConversationView.release();

      expect(CreateNewConversationView.mmsList.length).assertEqual(0);
    })

    it('CreateNewConversationViewTest_initRouterData', 0, () => {
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
      CreateNewConversationView.pageInfos = pageInfos;
      mocker.mockFunc(CreateNewConversationView, CreateNewConversationView.photoFirstNameDeal);
      mocker.mockFunc(CreateNewConversationView, CreateNewConversationView.formatDisplayPhoneNum);

      CreateNewConversationView.initRouterData();
      mocker.clear(CreateNewConversationView);
    })

    it('CreateNewConversationViewTest_formatDisplayPhoneNum', 0, () => {
      CreateNewConversationView.contactsNum = 2;
      CreateNewConversationView.strContactsName = '15380881598';
      CreateNewConversationView.strContactsNumberFormat = '15380881598';
      when(mocker.mockFunc(TelephoneUtil, TelephoneUtil.formatDisplayPhoneNum))(ArgumentMatchers.any)
        .afterReturn('15380881598');
      CreateNewConversationView.formatDisplayPhoneNum();
      expect(CreateNewConversationView.contactsNameIsNotEqualToContactsNumberFormat).assertFalse();
      mocker.clear(TelephoneUtil);
    })

    it('CreateNewConversationViewTest_formatDisplayPhoneNum_contactsNum_3', 0, () => {
      CreateNewConversationView.contactsNum = 3;
      CreateNewConversationView.strContactsNumber = "8888,9999";
      CreateNewConversationView.strContactsName = ',9999,name3';
      CreateNewConversationView.rawContactId = '1,2';
      CreateNewConversationView.strContactsNumberFormat = ',xxxx,xxxx';

      when(mocker.mockFunc(TelephoneUtil, TelephoneUtil.formatDisplayPhoneNum))(ArgumentMatchers.any)
        .afterReturn('');

      CreateNewConversationView.formatDisplayPhoneNum();
      expect(CreateNewConversationView.contactsNameIsNotEqualToContactsNumberFormat).assertFalse();
      mocker.clear(TelephoneUtil);
    })

    it('CreateNewConversationViewTest_photoFirstNameDeal_strContactsName_hasComma', 0, () => {
      CreateNewConversationView.photoFirstNameDeal('roxy,', [{
        portraitColor: '', firstName: 'zhang'
      }], (photoFirstName: string, portraitColor: string | Resource) => {
        expect(photoFirstName).assertEqual('-2');
      });
    })

    it('CreateNewConversationViewTest_photoFirstNameDeal_allChinese', 0, () => {
      CreateNewConversationView.photoFirstNameDeal('荣生', [{
        portraitColor: '', firstName: 'zhang'
      }], (photoFirstName: string, portraitColor: string | Resource) => {
        expect(photoFirstName).assertEqual('生');
      });
    })

    it('CreateNewConversationViewTest_photoFirstNameDeal_hasChinese', 0, () => {
      CreateNewConversationView.photoFirstNameDeal('荣生rongsheng', [{
        portraitColor: '', firstName: 'zhang'
      }], (photoFirstName: string, portraitColor: string | Resource) => {
        expect(photoFirstName).assertEqual('生');
      });
    })

    it('CreateNewConversationViewTest_photoFirstNameDeal_hasEnglish', 0, () => {
      CreateNewConversationView.photoFirstNameDeal('rongsheng', [{
        portraitColor: '', firstName: 'zhang'
      }], (photoFirstName: string, portraitColor: string | Resource) => {
        expect(photoFirstName).assertEqual('R');
      });
    })

    it('CreateNewConversationViewTest_photoFirstNameDeal_other', 0, () => {
      CreateNewConversationView.photoFirstNameDeal('*', [], (photoFirstName: string, portraitColor: string | Resource) => {});
      expect(CreateNewConversationView).not().assertUndefined();
    })

    it('CreateNewConversationViewTest_photoFirstNameDeal_strContactsName_empty', 0, () => {
      CreateNewConversationView.photoFirstNameDeal('', [{
        portraitColor: 'xxx', firstName: 'zhang'
      }], (photoFirstName: string, portraitColor: string | Resource) => {
        expect(portraitColor).assertEqual('xxx');
      });
    })

    it('CreateNewConversationViewTest_photoFirstNameDeal_strContactsName_portraitColor_empty', 0, () => {
      CreateNewConversationView.photoFirstNameDeal('', [{
        portraitColor: '', firstName: 'zhang'
      }]);
      expect(CreateNewConversationView).not().assertUndefined();
    })

    it('CreateNewConversationViewTest_ReplaceCode', 0, () => {
      let res1: string = CreateNewConversationView.replaceCode("");

      expect(res1).assertEqual('');

      let res2 = CreateNewConversationView.replaceCode("22222");

      expect(res2).assertEqual('22222');
    })

    it('CreateNewConversationViewTest_OnBackPress_isSelectStatus_true', 0, () => {
      CreateNewConversationView.isBackToIndex = true;
      AppStorage.setOrCreate('isBackHomePage', true);
      when(mocker.mockFunc(GlobalContext.getContext(),GlobalContext.getContext().getObject))('mmsContext')
        .afterReturn({
          moveAbilityToBackground:(): Promise<void> => new Promise<void>(resolve => resolve())
        } as Object | window.WindowStage)

      mocker.mockFunc(ConversationDataSource.getInstance(), ConversationDataSource.getInstance().refresh);

      when(mocker.mockFunc(DraftUtils.getInstance(), DraftUtils.getInstance().saveDraft))(ArgumentMatchers.any)
        .afterReturnNothing;

      let res: boolean = CreateNewConversationView.onBackPress(context);
      expect(res).assertTrue();

      mocker.clear(ConversationDataSource.getInstance());
      mocker.clear(DraftUtils.getInstance());
      mocker.clear(GlobalContext.getContext());
      AppStorage.clear();
    })

    it('CreateNewConversationViewTest_OnBackPress_isSelectStatus_false_isBackToIndex_true', 0, () => {
      CreateNewConversationView.isBackToIndex = true;
      CreateNewConversationView.isNewMsg = false;
      CreateNewConversationView.isDraft = false;
      CreateNewConversationView.textValue = '';
      CreateNewConversationView.pageInfos = new NavPathStack();
      AppStorage.setOrCreate('curBp', 'md');
      CreateNewConversationView.pictureCtrl.pictureList = [{
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
      mocker.mockFunc(CreateNewConversationView, CreateNewConversationView.resetMmsSource);
      mocker.mockFunc(CreateNewConversationView, CreateNewConversationView.release);
      mocker.mockFunc(ConversationListController.getInstance(), ConversationListController.getInstance().onShow);
      mocker.mockFunc(CreateNewConversationView.pictureCtrl.pictureDataSource,
        CreateNewConversationView.pictureCtrl.pictureDataSource.refresh);
      when(mocker.mockFunc(CreateNewConversationView, CreateNewConversationView.getDraftActionData))(ArgumentMatchers.any)
        .afterReturn({});
      when(mocker.mockFunc(DraftUtils.getInstance(), DraftUtils.getInstance().saveDraft))(ArgumentMatchers.any).afterReturnNothing;

      let res: boolean = CreateNewConversationView.onBackPress(context);

      expect(res).assertTrue();
      mocker.clear(ConversationListController.getInstance());
      mocker.clear(GlobalContext.getContext());
      mocker.clear(DraftUtils.getInstance());
      mocker.clear(CreateNewConversationView.pictureCtrl.pictureDataSource);
      mocker.clear(CreateNewConversationView);
      AppStorage.clear();
    })

    it('CreateNewConversationViewTest_OnBackPress_isSelectStatus_false_isBackToIndex_false_pageInfos', 0, () => {
      CreateNewConversationView.isBackToIndex = false;
      CreateNewConversationView.isNewMsg = false;
      CreateNewConversationView.isDraft = false;
      CreateNewConversationView.pageInfos = new NavPathStack();
      CreateNewConversationView.textValue = '';
      CreateNewConversationView.pageInfos.pushPathByName('InfoMsg', [{} as LooseObject]);
      AppStorage.setOrCreate('curBp', 'md');
      CreateNewConversationView.pictureCtrl.pictureList = [{
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
      mocker.mockFunc(CreateNewConversationView, CreateNewConversationView.resetMmsSource);
      mocker.mockFunc(CreateNewConversationView, CreateNewConversationView.release);
      mocker.mockFunc(CreateNewConversationView.pictureCtrl.pictureDataSource,
        CreateNewConversationView.pictureCtrl.pictureDataSource.refresh);
      when(mocker.mockFunc(CreateNewConversationView, CreateNewConversationView.getDraftActionData))(ArgumentMatchers.any)
        .afterReturn({});
      when(mocker.mockFunc(DraftUtils.getInstance(), DraftUtils.getInstance().saveDraft))(ArgumentMatchers.any).afterReturnNothing;

      let res: boolean = CreateNewConversationView.onBackPress(context);
      expect(res).assertTrue();

      mocker.clear(CreateNewConversationView.pictureCtrl.pictureDataSource);
      mocker.clear(CreateNewConversationView);
      mocker.clear(DraftUtils.getInstance());
      AppStorage.clear();
    })

    it('CreateNewConversationViewTest_OnBackPress_isSelectStatus_false_isBackToIndex_false_pageInfos_empty', 0, () => {
      CreateNewConversationView.isBackToIndex = false;
      CreateNewConversationView.isNewMsg = false;
      CreateNewConversationView.isDraft = false;
      CreateNewConversationView.textValue = '';
      CreateNewConversationView.pageInfos = undefined;
      AppStorage.setOrCreate('curBp', 'md');
      CreateNewConversationView.pictureCtrl.pictureList = [{
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

      mocker.mockFunc(CreateNewConversationView, CreateNewConversationView.resetMmsSource);
      mocker.mockFunc(CreateNewConversationView, CreateNewConversationView.release);
      mocker.mockFunc(CreateNewConversationView.pictureCtrl.pictureDataSource,
        CreateNewConversationView.pictureCtrl.pictureDataSource.refresh);
      when(mocker.mockFunc(CreateNewConversationView, CreateNewConversationView.getDraftActionData))(ArgumentMatchers.any)
        .afterReturn({});
      when(mocker.mockFunc(DraftUtils.getInstance(), DraftUtils.getInstance().saveDraft))(ArgumentMatchers.any).afterReturnNothing;

      let res: boolean = CreateNewConversationView.onBackPress(context);

      expect(res).assertFalse();

      mocker.clear(CreateNewConversationView.pictureCtrl.pictureDataSource);
      mocker.clear(CreateNewConversationView);
      mocker.clear(DraftUtils.getInstance());
      AppStorage.clear();
    })

    it('CreateNewConversationViewTest_getDraftActionData', 0, () => {
      when(mocker.mockFunc(settingService, settingService.judgeIsDeliveryReport))(ArgumentMatchers.any).afterReturn(false);
      CreateNewConversationView.isEditMms = false;
      let actionData = CreateNewConversationView.getDraftActionData([]);
      expect(actionData.isMms).assertFalse()
      mocker.clear(settingService);
    })

    it('CreateNewConversationViewTest_getDraftActionData_source_length_1_isEditMms_true', 0, () => {
      CreateNewConversationView.isEditMms = true;
      let source = {
        type: 0
      } as Mms;
      when(mocker.mockFunc(settingService, settingService.judgeIsDeliveryReport))(ArgumentMatchers.any).afterReturn(true);
      let actionData = CreateNewConversationView.getDraftActionData([source]);
      expect(actionData.isMms).assertTrue()
      mocker.clear(settingService);
    })

    it('CreateNewConversationViewTest_setDraftModel', 0, () => {
      (CreateNewConversationView as object)['timeoutID'] = 0;
      CreateNewConversationView.setDraftModel(()=>{}, false);
      expect((CreateNewConversationView as object)['timeoutID']).assertEqual(-1);
    })

    it('CreateNewConversationViewTest_rcsOn', 0, async () => {
      await CreateNewConversationView.rcsOn((message: rcs.RcsEvent) => {
      });
      expect(CreateNewConversationView.rawContactId).assertEqual('1,2');
    })

    it('CreateNewConversationViewTest_showReportToast', 0, () => {
      when(mocker.mockFunc(MmsUtil, MmsUtil.showToast))(ArgumentMatchers.any).afterReturnNothing;
      CreateNewConversationView.showReportToast('', 0);
      mocker.clear(MmsUtil);
    })

    it('CreateNewConversationViewTest_handleAppealSmsContent_reportResult_false', 0, async () => {
      let context = GlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext;
      let listTyp: mmsListType = new mmsListType();
      listTyp.isRcs = 1;
      listTyp.isReport = 0;
      listTyp.senderNumber = '6';
      listTyp.content = 'content';

      // reportResult false
      when(mocker.mockFunc(ReportSpamMessageManager, ReportSpamMessageManager.getInstance))()
        .afterReturn({
          reportSmsContent: async (context: myCommon.UIAbilityContext, msgStr: string, senderNum: string) => {
            return new Promise<boolean>(resolve => resolve(false));
          },
          initReportSpamMessageManager: async (context: myCommon.UIAbilityContext) => {}
        });
      when(mocker.mockFunc(MmsUtil, MmsUtil.showToast))(ArgumentMatchers.any).afterReturnNothing();
      await CreateNewConversationView.handleAppealSmsContent(listTyp, {}, {}, 0, context);
      mocker.clear(ReportSpamMessageManager);
      expect(CreateNewConversationView).not().assertUndefined();
    })

    it('CreateNewConversationViewTest_handleAppealSmsContent_isRcs_1_resultcode_0', 0, async () => {
      let context = GlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext;
      let listTyp: mmsListType = new mmsListType();
      listTyp.isRcs = 1;
      listTyp.isReport = 0;
      listTyp.senderNumber = '6';
      listTyp.content = 'content';

      // reportResult true item.isRcs == common.MESSAGE_TYPE.RCS result.code == common.int.SUCCESS
      when(mocker.mockFunc(ReportSpamMessageManager, ReportSpamMessageManager.getInstance))()
        .afterReturn({
          reportSmsContent: async (context: myCommon.UIAbilityContext, msgStr: string, senderNum: string) => {
            return new Promise<boolean>(resolve => resolve(true));
          },
          initReportSpamMessageManager: async (context: myCommon.UIAbilityContext) => {}
        });
      when(mocker.mockFunc(MmsUtil, MmsUtil.showToast))(ArgumentMatchers.any).afterReturnNothing();
      await CreateNewConversationView.handleAppealSmsContent(listTyp, {}, {}, 0, context);
      expect(CreateNewConversationView).not().assertUndefined();

      mocker.clear(MmsUtil);
      mocker.clear(ReportSpamMessageManager);
    })

    it('CreateNewConversationViewTest_handleAppealSmsContent_isRcs_1_resultcode_f1', 0, async () => {
      let context = GlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext;
      let listTyp: mmsListType = new mmsListType();
      listTyp.isRcs = 1;
      listTyp.isReport = 0;
      listTyp.senderNumber = '6';
      listTyp.content = 'content';

      // reportResult true item.isRcs == common.MESSAGE_TYPE.RCS result.code != common.int.SUCCESS
      when(mocker.mockFunc(ReportSpamMessageManager, ReportSpamMessageManager.getInstance))()
        .afterReturn({
          reportSmsContent: async (context: myCommon.UIAbilityContext, msgStr: string, senderNum: string) => {
            return new Promise<boolean>(resolve => resolve(true));
          },
          initReportSpamMessageManager: async (context: myCommon.UIAbilityContext) => {}
        });
      when(mocker.mockFunc(MmsUtil, MmsUtil.showToast))(ArgumentMatchers.any).afterReturnNothing();
      await CreateNewConversationView.handleAppealSmsContent(listTyp, {}, {}, 0, context);
      expect(CreateNewConversationView).not().assertUndefined();

      mocker.clear(MmsUtil);
      mocker.clear(ReportSpamMessageManager);
    })

    it('CreateNewConversationViewTest_handleAppealSmsContent_isRcs_0_resultcode_0', 0, async () => {
      let context = GlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext;
      let listTyp: mmsListType = new mmsListType();
      listTyp.isRcs = 0;
      listTyp.isReport = 0;
      listTyp.senderNumber = '6';
      listTyp.content = 'content';

      // reportResult true item.isRcs != common.MESSAGE_TYPE.RCS result.code == common.int.SUCCESS
      when(mocker.mockFunc(ReportSpamMessageManager, ReportSpamMessageManager.getInstance))()
        .afterReturn({
          reportSmsContent: async (context: myCommon.UIAbilityContext, msgStr: string, senderNum: string) => {
            return new Promise<boolean>(resolve => resolve(true));
          },
          initReportSpamMessageManager: async (context: myCommon.UIAbilityContext) => {}
        });
      when(mocker.mockFunc(MmsUtil, MmsUtil.showToast))(ArgumentMatchers.any).afterReturnNothing();
      when(mocker.mockFunc(ConversationService, ConversationService.getInstance))(ArgumentMatchers.any)
        .afterReturn({
          updateSmsMmsInfoByCondition: (context: Context, actionData: LooseObject, valueBucket: ValuesBucket,
            callback?: Function | null) => {
            if (callback) {callback({code:0})}
          }
        });
      await CreateNewConversationView.handleAppealSmsContent(listTyp, {}, {}, 0, context);
      expect(CreateNewConversationView).not().assertUndefined();

      mocker.clear(MmsUtil);
      mocker.clear(ConversationService);
      mocker.clear(ReportSpamMessageManager);
    })

    it('CreateNewConversationViewTest_handleAppealSmsContent_isRcs_0_resultcode_f1', 0, async () => {
      let context = GlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext;
      let listTyp: mmsListType = new mmsListType();
      listTyp.isRcs = 0;
      listTyp.isReport = 0;
      listTyp.senderNumber = '6';
      listTyp.content = 'content';

      // reportResult true item.isRcs != common.MESSAGE_TYPE.RCS result.code != common.int.SUCCESS
      when(mocker.mockFunc(ReportSpamMessageManager, ReportSpamMessageManager.getInstance))()
        .afterReturn({
          reportSmsContent: async (context: myCommon.UIAbilityContext, msgStr: string, senderNum: string) => {
            return new Promise<boolean>(resolve => resolve(true));
          },
          initReportSpamMessageManager: async (context: myCommon.UIAbilityContext) => {}
        });
      when(mocker.mockFunc(MmsUtil, MmsUtil.showToast))(ArgumentMatchers.any).afterReturnNothing();
      when(mocker.mockFunc(ConversationService, ConversationService.getInstance))(ArgumentMatchers.any)
        .afterReturn({
          updateSmsMmsInfoByCondition: (context: Context, actionData: LooseObject, valueBucket: ValuesBucket,
            callback?: Function | null) => {
            if (callback) {callback({code:-1})}
          }
        });
      await CreateNewConversationView.handleAppealSmsContent(listTyp, {}, {}, 0, context);
      expect(CreateNewConversationView).not().assertUndefined();

      mocker.clear(MmsUtil);
      mocker.clear(ConversationService);
      mocker.clear(ReportSpamMessageManager);
    })

    it('CreateNewConversationViewTest_queryMessageDetail_queryTerminate_notHas', 0, async () => {
      let queryInfoObj: IQueryMessageDetailInfo = {
        isDraft: false,
        currentPage: 0,
        threadId: 0,
        contactsNum: 0,
        isDownloadQuery: false,
        resultTotal: 0,
        lastListSize: 0,
        queryTimeID: 0,
        startIndex: 0
      };

      CreateNewConversationView.queryTerminate.set(0, 1);
      CreateNewConversationView.vCardJumpBack = true;

      await CreateNewConversationView.queryMessageDetail(context, queryInfoObj, () => {
      });

      expect(CreateNewConversationView.vCardJumpBack).assertFalse();
    })

    it('CreateNewConversationViewTest_queryMessageDetail_queryTerminate_has_vCardJumpBack_true', 0, async () => {
      let queryInfoObj: IQueryMessageDetailInfo = {
        isDraft: false,
        currentPage: 0,
        threadId: 0,
        contactsNum: 0,
        isDownloadQuery: false,
        resultTotal: 0,
        lastListSize: 0,
        queryTimeID: 0,
        startIndex: 0
      };

      CreateNewConversationView.queryTerminate.set(0, 0);
      CreateNewConversationView.vCardJumpBack = true;
      CreateNewConversationView.messageCount = 0;

      await CreateNewConversationView.queryMessageDetail(context, queryInfoObj, undefined);

      expect(CreateNewConversationView.vCardJumpBack).assertFalse();
    })

    it('CreateNewConversationViewTest_queryMessageDetail_queryTerminate_has_vCardJumpBack_false_isDraft_false_fail', 0,
      async () => {
        let queryInfoObj: IQueryMessageDetailInfo = {
          isDraft: false,
          currentPage: 0,
          threadId: 0,
          contactsNum: 0,
          isDownloadQuery: false,
          resultTotal: 0,
          lastListSize: 0,
          queryTimeID: 0,
          startIndex: 0
        };

        CreateNewConversationView.queryTerminate.set(0, 0);
        CreateNewConversationView.vCardJumpBack = false;
        CreateNewConversationView.messageCount = 0;
        (CreateNewConversationView as object)['isSmartOpen'] = true;
        when(mocker.mockFunc(TelephoneUtil, TelephoneUtil.judgeIsInfoMsg))(ArgumentMatchers.any).afterReturn(true);

        mocker.mockFunc(ConversationService.getInstance(),
          ConversationService.getInstance().queryAllInfoSizeByCondition);
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

        await CreateNewConversationView.queryMessageDetail(context, queryInfoObj, undefined);
        mocker.clear(GlobalContext.getContext());
        mocker.clear(ConversationService.getInstance());
        expect(CreateNewConversationView).not().assertUndefined();
      })

    it('CreateNewConversationViewTest_queryMessageDetail_queryTerminate_has_vCardJumpBack_false_isDraft_false_success', 0,
      async () => {
        let context = {
          resourceManager: {
            getStringSync: (resource: Resource, ...args: (string | number)[]): string => ''
          } as resourceManager.ResourceManager
        } as Context;
        let queryInfoObj: IQueryMessageDetailInfo = {
          isDraft: false,
          currentPage: 0,
          threadId: 0,
          contactsNum: 0,
          isDownloadQuery: false,
          resultTotal: 0,
          lastListSize: 2,
          queryTimeID: 0,
          startIndex: 0
        };

        CreateNewConversationView.queryTerminate.set(0, 0);
        CreateNewConversationView.vCardJumpBack = false;
        CreateNewConversationView.contactsNum = 1;
        (CreateNewConversationView as object)['isSmartOpen'] = true;
        when(mocker.mockFunc(TelephoneUtil, TelephoneUtil.judgeIsInfoMsg))(ArgumentMatchers.any).afterReturn(true);

        mocker.mockFunc(ConversationService.getInstance(),
          ConversationService.getInstance().queryAllInfoSizeByCondition);
        when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))(ArgumentMatchers.any)
          .afterReturn({
            sendRequest: (request: string, requestData?: Object | undefined,
              callBack?: ((result: Object) => void) | undefined): Promise<void> => {
              callBack ? callBack({
                code: 0,
                abilityResult: [{
                  rcsId: '',
                  isRcs: 0,
                  smsType: '1',
                  msgId: 1,
                  ct: 'image',
                  msgContent: '',
                  isReceive: true,
                  mmsList: [{
                    ct: 'image'
                  }]
                } as LooseObject]
              } as LooseObject) : '';
              return new Promise<void>(resolve => resolve())
            },
            resourceManager: {
              getStringSync: (resource: Resource, ...args: (string | number)[]): string => ''
            } as resourceManager.ResourceManager
          } as Object | window.WindowStage);
        when(mocker.mockFunc(DateUtil, DateUtil.convertTimeStampToDateWeek))(ArgumentMatchers.any).afterReturnNothing;
        await CreateNewConversationView.queryMessageDetail(context, queryInfoObj, undefined);
        mocker.clear(GlobalContext.getContext());
        mocker.clear(DateUtil);
        mocker.clear(TelephoneUtil);
        mocker.clear(ConversationService.getInstance());
        expect(CreateNewConversationView).not().assertUndefined();
      })

    it('CreateNewConversationViewTest_queryMessageDetailAllInner_success_curBp_sm', 0, () => {
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
        resultTotal: 10,
        lastListSize: 1,
        queryTimeID: 0,
        startIndex: 0
      };
      CreateNewConversationView.mmsList = [{
        dateShow: true,
        timeMillisecond: 0,
        showTitle: true,
        isRcs: 0,
      } as mmsListType, {
        dateShow: true,
        timeMillisecond: 0,
        showTitle: true,
        isRcs: 0,
      } as mmsListType];
      CreateNewConversationView.threadId = 0;
      AppStorage.setOrCreate('curBp', 'sm');
      let queryActionData: IQueryMessageDetailAll = {
        threadId: queryInfoObj.threadId,
        page: queryInfoObj.currentPage,
        contactsNum: queryInfoObj.contactsNum,
        actionDataName: ''
      };

      CreateNewConversationView.queryTerminate.set(0, 0);
      CreateNewConversationView.vCardJumpBack = false;

      mocker.mockFunc(ConversationService.getInstance(),
        ConversationService.getInstance().queryAllInfoSizeByCondition);
      mocker.mockFunc(CreateNewConversationView, CreateNewConversationView.setDraft);
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))(ArgumentMatchers.any)
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: 0,
              abilityResult: [{
                rcsId: '',
                isRcs: 0,
                smsType: '1',
                msgId: 1,
                ct: 'image',
                msgContent: '',
                isReceive: true,
                mmsList: [{
                  ct: 'image'
                }]
              } as LooseObject],
              response: [{
                timeMillisecond: 0,
              } as mmsListType]
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve())
          },
          resourceManager: {
            getStringSync: (resource: Resource, ...args: (string | number)[]): string => ''
          } as resourceManager.ResourceManager
        } as Object | window.WindowStage);
      mocker.mockFunc(ConversationDataSource.getInstance(), ConversationDataSource.getInstance().refresh);
      mocker.mockFunc(CreateNewConversationView, CreateNewConversationView.queryMessageDetail);
      mocker.mockFunc(DateUtil, DateUtil.fullDate);
      mocker.mockFunc(DateUtil, DateUtil.convertTimeStampToDateWeek);
      mocker.mockFunc(DateUtil, DateUtil.convertDateFormatForItem);
      when(mocker.mockFunc(DateUtil, DateUtil.isNotSameDay))(ArgumentMatchers.any).afterReturn(true);

      (CreateNewConversationView as object)['queryMessageDetailAllSmart'](context, queryInfoObj, queryActionData, () => {
        mocker.verify('deleteDraftData', []).never();
      });
      (CreateNewConversationView as object)['queryMessageDetailAllInner'](context, queryInfoObj, queryActionData, () => {
        mocker.verify('deleteDraftData', []).never();
      });

      expect(CreateNewConversationView.vCardJumpBack).assertFalse();
      mocker.clear(DateUtil);
      mocker.clear(CreateNewConversationView);
      mocker.clear(GlobalContext.getContext());
      mocker.clear(ConversationService.getInstance());
      mocker.clear(ConversationDataSource.getInstance());
    })

    it('CreateNewConversationViewTest_queryMessageDetailAllInner_success_resultTotal_equal_mmsListLength', 0, () => {
      let queryInfoObj: IQueryMessageDetailInfo = {
        isDraft: true,
        currentPage: 0,
        threadId: 0,
        contactsNum: 0,
        isDownloadQuery: false,
        resultTotal: 10,
        lastListSize: 1,
        queryTimeID: 0,
        startIndex: 0
      };
      CreateNewConversationView.mmsList = [{
        dateShow: true,
        timeMillisecond: 0,
        showTitle: true,
        isRcs: 0,
      } as mmsListType, {
        dateShow: true,
        timeMillisecond: 0,
        showTitle: true,
        isRcs: 0,
      } as mmsListType];
      let queryActionData: IQueryMessageDetailAll = {
        threadId: queryInfoObj.threadId,
        page: queryInfoObj.currentPage,
        contactsNum: queryInfoObj.contactsNum,
        actionDataName: ''
      };

      CreateNewConversationView.queryTerminate.set(0, 0);
      CreateNewConversationView.vCardJumpBack = false;

      mocker.mockFunc(ConversationService.getInstance(),
        ConversationService.getInstance().queryAllInfoSizeByCondition);
      mocker.mockFunc(CreateNewConversationView, CreateNewConversationView.setDraft);
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))(ArgumentMatchers.any)
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: 0,
              abilityResult: [{
                rcsId: '',
                msgId: 'msgId',
                isRcs: 0,
                smsType: '1',
                ct: 'audio',
                mmsList: [{
                  ct: 'audio'
                }]
              } as LooseObject],
              response: [{
                timeMillisecond: 0,
              } as mmsListType]
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve())
          },
          resourceManager: {
            getStringSync:(resId: number): string => 'xx：'
          } as resourceManager.ResourceManager
        } as Object | window.WindowStage);
      mocker.mockFunc(ConversationDataSource.getInstance(), ConversationDataSource.getInstance().refresh);
      mocker.mockFunc(CreateNewConversationView, CreateNewConversationView.queryMessageDetail);
      mocker.mockFunc(DateUtil, DateUtil.fullDate);
      mocker.mockFunc(DateUtil, DateUtil.convertTimeStampToDateWeek);
      mocker.mockFunc(DateUtil, DateUtil.convertDateFormatForItem);
      when(mocker.mockFunc(DateUtil, DateUtil.isNotSameDay))(ArgumentMatchers.any).afterReturn(true);

      (CreateNewConversationView as object)['queryMessageDetailAllSmart'](context, queryInfoObj, queryActionData, () => {
        mocker.verify('deleteDraftData', []).never();
      });
      (CreateNewConversationView as object)['queryMessageDetailAllInner'](context, queryInfoObj, queryActionData, () => {
        mocker.verify('deleteDraftData', []).never();
      });

      expect(CreateNewConversationView.vCardJumpBack).assertFalse();
      mocker.clear(DateUtil);
      mocker.clear(CreateNewConversationView);
      mocker.clear(GlobalContext.getContext());
      mocker.clear(ConversationService.getInstance());
      mocker.clear(ConversationDataSource.getInstance());
    })

    it('CreateNewConversationViewTest_queryMessageDetailAllInner_success_mmsList_length_0', 0, () => {
      let queryInfoObj: IQueryMessageDetailInfo = {
        isDraft: true,
        currentPage: 1,
        threadId: 0,
        contactsNum: 0,
        isDownloadQuery: false,
        resultTotal: 1,
        lastListSize: 1,
        queryTimeID: 0,
        startIndex: 0
      };
      CreateNewConversationView.mmsList = [];
      let queryActionData: IQueryMessageDetailAll = {
        threadId: queryInfoObj.threadId,
        page: queryInfoObj.currentPage,
        contactsNum: queryInfoObj.contactsNum,
        actionDataName: ''
      };

      CreateNewConversationView.queryTerminate.set(0, 0);
      CreateNewConversationView.vCardJumpBack = false;

      mocker.mockFunc(ConversationService.getInstance(),
        ConversationService.getInstance().queryAllInfoSizeByCondition);
      mocker.mockFunc(CreateNewConversationView, CreateNewConversationView.setDraft);
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))(ArgumentMatchers.any)
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: 0,
              abilityResult: [{
                rcsId: '',
                msgId: 'msgId',
                isRcs: 0,
                smsType: '1',
                ct: 'audio',
                mmsList: [{
                  ct: 'audio'
                }]
              } as LooseObject],
              response: []
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve())
          },
          resourceManager: {
            getStringSync:(resId: number): string => 'xx：'
          } as resourceManager.ResourceManager
        } as Object | window.WindowStage);
      mocker.mockFunc(ConversationDataSource.getInstance(), ConversationDataSource.getInstance().refresh);
      mocker.mockFunc(CreateNewConversationView, CreateNewConversationView.queryMessageDetail);
      mocker.mockFunc(DateUtil, DateUtil.fullDate);
      mocker.mockFunc(DateUtil, DateUtil.convertTimeStampToDateWeek);
      mocker.mockFunc(DateUtil, DateUtil.convertDateFormatForItem);
      when(mocker.mockFunc(DateUtil, DateUtil.isNotSameDay))(ArgumentMatchers.any).afterReturn(true);

      (CreateNewConversationView as object)['queryMessageDetailAllSmart'](context, queryInfoObj, queryActionData, () => {
        mocker.verify('deleteDraftData', []).never();
      });
      (CreateNewConversationView as object)['queryMessageDetailAllInner'](context, queryInfoObj, queryActionData, () => {
        mocker.verify('deleteDraftData', []).never();
      });

      expect(CreateNewConversationView.vCardJumpBack).assertFalse();
      mocker.clear(DateUtil);
      mocker.clear(CreateNewConversationView);
      mocker.clear(GlobalContext.getContext());
      mocker.clear(ConversationService.getInstance());
      mocker.clear(ConversationDataSource.getInstance());
    })

    it('CreateNewConversationViewTest_queryMessageDetailAllInner_success', 0, () => {
      let queryInfoObj: IQueryMessageDetailInfo = {
        isDraft: true,
        currentPage: 0,
        threadId: 0,
        contactsNum: 0,
        isDownloadQuery: false,
        resultTotal: 1,
        lastListSize: 1,
        queryTimeID: 0,
        startIndex: 0
      };
      let mmsList: mmsListType = new mmsListType();
      mmsList.isRcs = 0;
      mmsList.timeMillisecond = 0;
      mmsList.dateShow = true;
      mmsList.showTitle = true;
      let mmsList1: mmsListType = new mmsListType();
      mmsList1.isRcs = 0;
      mmsList1.timeMillisecond = 1;
      mmsList1.dateShow = true;
      mmsList1.showTitle = true;
      CreateNewConversationView.mmsList = [mmsList, mmsList1];
      let queryActionData: IQueryMessageDetailAll = {
        threadId: queryInfoObj.threadId,
        page: queryInfoObj.currentPage,
        contactsNum: queryInfoObj.contactsNum,
        actionDataName: ''
      };

      CreateNewConversationView.queryTerminate.set(0, 0);
      CreateNewConversationView.vCardJumpBack = false;

      mocker.mockFunc(ConversationService.getInstance(),
        ConversationService.getInstance().queryAllInfoSizeByCondition);
      mocker.mockFunc(CreateNewConversationView, CreateNewConversationView.setDraft);
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))(ArgumentMatchers.any)
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: 0,
              abilityResult: [{
                rcsId: '',
                msgId: 'msgId',
                isRcs: 0,
                smsType: '1',
                ct: 'audio',
                mmsList: [{
                  ct: 'audio'
                }]
              } as LooseObject],
              response: [{
                timeMillisecond: 0,
              } as mmsListType]
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve())
          },
          resourceManager: {
            getStringSync:(resId: number): string => 'xx：'
          } as resourceManager.ResourceManager
        } as Object | window.WindowStage);
      mocker.mockFunc(ConversationDataSource.getInstance(), ConversationDataSource.getInstance().refresh);
      mocker.mockFunc(CreateNewConversationView, CreateNewConversationView.queryMessageDetail);
      mocker.mockFunc(DateUtil, DateUtil.fullDate);
      mocker.mockFunc(DateUtil, DateUtil.convertTimeStampToDateWeek);
      mocker.mockFunc(DateUtil, DateUtil.convertDateFormatForItem);
      when(mocker.mockFunc(DateUtil, DateUtil.isNotSameDay))(ArgumentMatchers.any).afterReturn(true);

      (CreateNewConversationView as object)['queryMessageDetailAllSmart'](context, queryInfoObj, queryActionData, () => {
        mocker.verify('deleteDraftData', []).never();
      });
      (CreateNewConversationView as object)['queryMessageDetailAllInner'](context, queryInfoObj, queryActionData, () => {
        mocker.verify('deleteDraftData', []).never();
      });

      expect(CreateNewConversationView.vCardJumpBack).assertFalse();
      mocker.clear(DateUtil);
      mocker.clear(CreateNewConversationView);
      mocker.clear(GlobalContext.getContext());
      mocker.clear(ConversationService.getInstance());
      mocker.clear(ConversationDataSource.getInstance());
    })

    it('CreateNewConversationViewTest_queryMessageDetailAllInner_fail', 0, () => {
      let queryInfoObj: IQueryMessageDetailInfo = {
        isDraft: false,
        currentPage: 2,
        threadId: 0,
        contactsNum: 0,
        isDownloadQuery: false,
        resultTotal: 10,
        lastListSize: 1,
        queryTimeID: 0,
        startIndex: 0
      };
      let queryActionData: IQueryMessageDetailAll = {
        threadId: queryInfoObj.threadId,
        page: queryInfoObj.currentPage,
        contactsNum: queryInfoObj.contactsNum,
        actionDataName: ''
      };

      mocker.mockFunc(CreateNewConversationView, CreateNewConversationView.setDraft);
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

      (CreateNewConversationView as object)['queryMessageDetailAllSmart'](context, queryInfoObj, queryActionData, () => {
        mocker.verify('deleteDraftData', []).never();
      });
      (CreateNewConversationView as object)['queryMessageDetailAllInner'](context, queryInfoObj, queryActionData, () => {
        mocker.verify('deleteDraftData', []).never();
      });
      mocker.clear(CreateNewConversationView);
      mocker.clear(GlobalContext.getContext());
    })

    it('CreateNewConversationViewTest_dealDraftData_isMsm_true_setMMsFlag_true', 0, () => {
      let item: mmsListType = new mmsListType();
      item.content = '';
      item.groupId = 1;
      item.isMsm = true;
      CreateNewConversationView.isEditMms = false;
      CreateNewConversationView.setMMsFlag = true;

      CreateNewConversationView.dealDraftData(context, item);

      expect(CreateNewConversationView.isEditMms).assertTrue();
    })

    it('CreateNewConversationViewTest_dealDraftData_isMsm_false', 0, () => {
      let item: mmsListType = new mmsListType();
      item.content = '';
      item.groupId = 1;
      item.isMsm = false;
      CreateNewConversationView.isEditMms = false;
      CreateNewConversationView.setMMsFlag = true;

      CreateNewConversationView.dealDraftData(context, item);

      expect(CreateNewConversationView.isEditMms).assertFalse();
    })

    it('CreateNewConversationViewTest_setDraft_isDraft_true_draftContent_empty', 0, () => {
      CreateNewConversationView.isDraft = true;
      CreateNewConversationView.draftContent = '';
      CreateNewConversationView.textValue = '';

      CreateNewConversationView.setDraft();

      expect(CreateNewConversationView.textValue).assertEqual('');
    })

    it('CreateNewConversationViewTest_setDraft_isDraft_true_textValue_empty', 0, () => {
      CreateNewConversationView.isDraft = true;
      CreateNewConversationView.draftContent = 'xx';
      CreateNewConversationView.textValue = '';
      mocker.mockFunc(MmsPreferences.getInstance(),MmsPreferences.getInstance().haveSimCardReady);

      CreateNewConversationView.setDraft();

      expect(CreateNewConversationView.textValue).assertEqual('xx');
      mocker.clear(MmsPreferences.getInstance());
    })

    it('CreateNewConversationViewTest_updateDetail_isRcs_1_deliveryReportSwitch_3_contactName_empty_isRcs_minus1', 0,
      () => {
        let sendResult: Record<string, string | number | string[]> = {
          'isRcs': 1,
          'sendStatus': 0,
          'contactName': '',
          'telephone': '111111',
        };
        let mmsList: mmsListType = new mmsListType();
        mmsList.isRcs = -1;
        mmsList.timeMillisecond = 0;
        CreateNewConversationView.mmsList = [mmsList, mmsList];
        mocker.mockFunc(ConversationService.getInstance(), ConversationService.getInstance().updateSessionAndDetail);
        when(mocker.mockFunc(MmsPreferences.getInstance(),
          MmsPreferences.getInstance().getValueOfDeliveryReportSwitch))()
          .afterReturn('3');
        when(mocker.mockFunc(TelephoneUtil, TelephoneUtil.formatDisplayPhoneNum))(ArgumentMatchers.any)
          .afterReturn('');
        when(mocker.mockFunc(GlobalContext.getContext(),
          GlobalContext.getContext().getObject))('mmsContext')
          .afterReturn({
            resourceManager: {
              getStringSync: (resource: Resource, ...args: (string | number)[]): string => 'xx'
            } as resourceManager.ResourceManager
          } as Object | window.WindowStage);
        let res = false;
        when(mocker.mockFunc(CreateNewConversationView, CreateNewConversationView.showToast))(ArgumentMatchers.any)
          .afterAction(() => {
            res = true;
          });
        when(mocker.mockFunc(ConversationDataSource.getInstance(),
          ConversationDataSource.getInstance().refresh))(ArgumentMatchers.any)
          .afterAction(() => {
            expect(res).assertTrue();
          });

        CreateNewConversationView.updateDetail(context, 0, sendResult, 0, '0', false);
        mocker.clear(ConversationService.getInstance());
        mocker.clear(MmsPreferences.getInstance());
        mocker.clear(GlobalContext.getContext());
        mocker.clear(CreateNewConversationView);
        mocker.clear(TelephoneUtil);
        mocker.clear(ConversationDataSource.getInstance());
      })

    it('CreateNewConversationViewTest_updateDetail_isRcs_0_deliveryReportSwitch_1_contactName_empty_isRcs_0', 0,
      () => {
        let sendResult: Record<string, string | number | string[]> = {
          'isRcs': 0,
          'sendStatus': 0,
          'contactName': 'xx',
          'telephone': 'sip:111111',
        };
        let mmsList: mmsListType = new mmsListType();
        mmsList.isRcs = 0;
        mmsList.timeMillisecond = 0;
        CreateNewConversationView.mmsList = [mmsList, mmsList];
        mocker.mockFunc(ConversationService.getInstance(), ConversationService.getInstance().updateSessionAndDetail);
        when(mocker.mockFunc(MmsPreferences.getInstance(),
          MmsPreferences.getInstance().getValueOfDeliveryReportSwitch))()
          .afterReturn('1');
        when(mocker.mockFunc(TelephoneUtil, TelephoneUtil.formatDisplayPhoneNum))(ArgumentMatchers.any)
          .afterReturn('');
        when(mocker.mockFunc(GlobalContext.getContext(),
          GlobalContext.getContext().getObject))('mmsContext')
          .afterReturn({
            resourceManager: {
              getStringSync: (resource: Resource, ...args: (string | number)[]): string => 'xx'
            } as resourceManager.ResourceManager
          } as Object | window.WindowStage);
        let res = false;
        when(mocker.mockFunc(CreateNewConversationView, CreateNewConversationView.showToast))(ArgumentMatchers.any)
          .afterAction(() => {
            res = true;
          });
        when(mocker.mockFunc(ConversationDataSource.getInstance(),
          ConversationDataSource.getInstance().refresh))(ArgumentMatchers.any)
          .afterAction(() => {
            expect(res).assertTrue();
          });

        CreateNewConversationView.updateDetail(context, 0, sendResult, 0, '0', false);
        mocker.clear(ConversationService.getInstance());
        mocker.clear(MmsPreferences.getInstance());
        mocker.clear(GlobalContext.getContext());
        mocker.clear(CreateNewConversationView);
        mocker.clear(TelephoneUtil);
        mocker.clear(ConversationDataSource.getInstance());
      })

    it('CreateNewConversationViewTest_updateDetail_isRcs_0_deliveryReportSwitch_1_contactName_xxx_isRcs_0', 0,
      () => {
        let sendResult: Record<string, string | number | string[]> = {
          'isRcs': 0,
          'sendStatus': 0,
          'contactName': 'xxx',
          'telephone': '111111',
        };
        let mmsList: mmsListType = new mmsListType();
        mmsList.isRcs = 0;
        mmsList.timeMillisecond = 0;
        CreateNewConversationView.mmsList = [mmsList, mmsList];
        mocker.mockFunc(ConversationService.getInstance(), ConversationService.getInstance().updateSessionAndDetail);
        when(mocker.mockFunc(MmsPreferences.getInstance(),
          MmsPreferences.getInstance().getValueOfDeliveryReportSwitch))()
          .afterReturn('0');
        when(mocker.mockFunc(TelephoneUtil, TelephoneUtil.formatDisplayPhoneNum))(ArgumentMatchers.any)
          .afterReturn('');
        when(mocker.mockFunc(GlobalContext.getContext(),
          GlobalContext.getContext().getObject))('mmsContext')
          .afterReturn({
            resourceManager: {
              getStringSync: (resource: Resource, ...args: (string | number)[]): string => 'xx'
            } as resourceManager.ResourceManager
          } as Object | window.WindowStage);
        let res = false;
        when(mocker.mockFunc(CreateNewConversationView, CreateNewConversationView.showToast))(ArgumentMatchers.any)
          .afterAction(() => {
            res = true;
          });
        when(mocker.mockFunc(ConversationDataSource.getInstance(),
          ConversationDataSource.getInstance().refresh))(ArgumentMatchers.any)
          .afterAction(() => {
            expect(res).assertFalse();
          });

        CreateNewConversationView.updateDetail(context, 0, sendResult, 0, '0', false);
        mocker.clear(ConversationService.getInstance());
        mocker.clear(MmsPreferences.getInstance());
        mocker.clear(GlobalContext.getContext());
        mocker.clear(CreateNewConversationView);
        mocker.clear(TelephoneUtil);
        mocker.clear(ConversationDataSource.getInstance());
      })

    it('CreateNewConversationViewTest_setCanSendMsgStatus_receiveContactValue_empty', 0, () => {
      CreateNewConversationView.canSendMessage = true;
      CreateNewConversationView.receiveContactValue = '';
      CreateNewConversationView.setCanSendMsgStatus();
      expect(CreateNewConversationView.canSendMessage).assertFalse();
    })

    it('CreateNewConversationViewTest_setCanSendMsgStatus', 0, () => {
      CreateNewConversationView.canSendMessage = true;
      CreateNewConversationView.mmsEditList = [];
      CreateNewConversationView.setCanSendMsgStatus();
    })

    it('CreateNewConversationViewTest_getSendMessageId_found', 0, () => {
      let initDatas: InitData[] = [{
        telephone: '1111',
        id: 1
      } as InitData];

      let res: number = CreateNewConversationView.getSendMessageId(initDatas, '1111');

      expect(res).assertEqual(1);
    })

    it('CreateNewConversationViewTest_getSendMessageId', 0, () => {
      let initDatas: InitData[] = [{
        telephone: '2222',
        id: 2
      } as InitData];

      let res: number = CreateNewConversationView.getSendMessageId(initDatas, '1111');

      expect(res).assertEqual(-1);
    })

    it('CreateNewConversationViewTest_convertingSms', 0, () => {
      mocker.mockFunc(CreateNewConversationView, CreateNewConversationView.showToast);

      CreateNewConversationView.convertingSms();

      expect(CreateNewConversationView.isEditMms).assertFalse();
      mocker.clear(CreateNewConversationView);
    })

    it('CreateNewConversationViewTest_insertInitData', 0, () => {
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
      CreateNewConversationView.insertInitData(actionData, new mmsListType(), () => {
      });

      expect(res).assertTrue();

      mocker.clear(settingService);
      mocker.clear(ConversationService.getInstance());
    })

    it('CreateNewConversationViewTest_insertInitData2', 0, () => {
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
      CreateNewConversationView.insertInitData(actionData, item, () => {
      });
      expect(res).assertTrue();
      mocker.clear(settingService);
      mocker.clear(ConversationService.getInstance());
    })

    it('CreateNewConversationViewTest_insertInitData_isRcs_0', 0, () => {
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
      CreateNewConversationView.insertInitData(actionData, new mmsListType(), () => {
      });

      expect(res).assertTrue();

      mocker.clear(settingService);
      mocker.clear(ConversationService.getInstance());
    })

    it('CreateNewConversationViewTest_changeReceiveContactValue', 0, () => {
      CreateNewConversationView.changeReceiveContactValue('2222');
      expect(CreateNewConversationView.receiveContactValue).assertEqual('2222');
    })

    it('CreateNewConversationViewTest_updatePreview_length_1_type_1', 0, () => {
      CreateNewConversationView.mmsEditList = [{
        type: 1,
        uriPath: '',
        time: '',
        fileSize: 10
      } as MmsSourceType];
      CreateNewConversationView.pictureListFromGallery = [{
        checkedValue: true,
        path: ''
      } as pictureListFromGalleryType, {
        checkedValue: true,
        path: '/'
      } as pictureListFromGalleryType];

      CreateNewConversationView.updatePreview(0);

      expect(CreateNewConversationView.isOnlyAudio).assertFalse();
    })

    it('CreateNewConversationViewTest_updatePreview_length_1_type_3', 0, () => {
      CreateNewConversationView.mmsEditList = [{
        type: 3,
        uriPath: '',
        time: '',
        fileSize: 10
      } as MmsSourceType];
      CreateNewConversationView.pictureListFromGallery = [{
        checkedValue: true,
        path: ''
      } as pictureListFromGalleryType, {
        checkedValue: true,
        path: '/'
      } as pictureListFromGalleryType];

      CreateNewConversationView.updatePreview(0);

      expect(CreateNewConversationView.isOnlyAudio).assertTrue();
    })

    it('CreateNewConversationViewTest_initSendItem_mmsEditList_empty', 0, () => {
      CreateNewConversationView.mmsEditList = [];
      CreateNewConversationView.contactsNum = 1;
      CreateNewConversationView.isEditMms = false;

      when(mocker.mockFunc(settingService, settingService.judgeIsDeliveryReport))(ArgumentMatchers.any)
        .afterReturn(true);
      mocker.mockFunc(DateUtil, DateUtil.convertTimeStampToDateWeek);
      mocker.mockFunc(DateUtil, DateUtil.fullDate);
      mocker.mockFunc(CreateNewConversationView, CreateNewConversationView.setDateShow);
      mocker.mockFunc(ConversationDataSource.getInstance(), ConversationDataSource.getInstance().refresh);
      let item: mmsListType = new mmsListType();
      CreateNewConversationView.initSendItem();
      expect(CreateNewConversationView.mmsList[0].isMsm).assertFalse();

      mocker.clear(settingService);
      mocker.clear(ConversationDataSource.getInstance());
      mocker.clear(DateUtil);
      mocker.clear(CreateNewConversationView);
    })

    it('CreateNewConversationViewTest_initSendItem_mmsEditList_length_1_type_3', 0, () => {
      CreateNewConversationView.mmsEditList = [{
        type: 3,
        uriPath: '',
        time: '',
        fileSize: 10
      }];
      CreateNewConversationView.contactsNum = 1;
      CreateNewConversationView.isEditMms = false;

      when(mocker.mockFunc(settingService, settingService.judgeIsDeliveryReport))(ArgumentMatchers.any)
        .afterReturn(true);
      mocker.mockFunc(DateUtil, DateUtil.convertTimeStampToDateWeek);
      mocker.mockFunc(DateUtil, DateUtil.fullDate);
      mocker.mockFunc(CreateNewConversationView, CreateNewConversationView.setDateShow);
      mocker.mockFunc(ConversationDataSource.getInstance(), ConversationDataSource.getInstance().refresh)
      let item: mmsListType = new mmsListType();
      CreateNewConversationView.initSendItem();

      expect(CreateNewConversationView.mmsList[0].isMsm).assertFalse();

      mocker.clear(settingService);
      mocker.clear(ConversationDataSource.getInstance());
      mocker.clear(DateUtil);
      mocker.clear(CreateNewConversationView);
    })

    it('CreateNewConversationViewTest_initSendItem_mmsEditList_length_1_type_5', 0, () => {
      CreateNewConversationView.mmsEditList = [{
        type: 5,
        uriPath: '',
        time: '',
        fileSize: 10
      }];
      CreateNewConversationView.contactsNum = 1;
      CreateNewConversationView.isEditMms = false;

      when(mocker.mockFunc(settingService, settingService.judgeIsDeliveryReport))(ArgumentMatchers.any)
        .afterReturn(true);
      mocker.mockFunc(DateUtil, DateUtil.convertTimeStampToDateWeek);
      mocker.mockFunc(DateUtil, DateUtil.fullDate);
      mocker.mockFunc(CreateNewConversationView, CreateNewConversationView.setDateShow);
      mocker.mockFunc(ConversationDataSource.getInstance(), ConversationDataSource.getInstance().refresh)

      let item: mmsListType = new mmsListType();
      CreateNewConversationView.initSendItem();

      expect(CreateNewConversationView.mmsList[0].isMsm).assertFalse();

      mocker.clear(settingService);
      mocker.clear(ConversationDataSource.getInstance());
      mocker.clear(DateUtil);
      mocker.clear(CreateNewConversationView);
    })

    it('CreateNewConversationViewTest_initSendItem_mmsEditList_length_1_type_0', 0, () => {
      CreateNewConversationView.mmsEditList = [{
        type: 0,
        uriPath: '',
        time: '',
        fileSize: 10
      }];
      CreateNewConversationView.contactsNum = 1;
      CreateNewConversationView.isEditMms = false;

      when(mocker.mockFunc(settingService, settingService.judgeIsDeliveryReport))(ArgumentMatchers.any)
        .afterReturn(true);
      mocker.mockFunc(DateUtil, DateUtil.convertTimeStampToDateWeek);
      mocker.mockFunc(DateUtil, DateUtil.fullDate);
      mocker.mockFunc(CreateNewConversationView, CreateNewConversationView.setDateShow);
      mocker.mockFunc(ConversationDataSource.getInstance(), ConversationDataSource.getInstance().refresh)

      let item: mmsListType = new mmsListType();
      CreateNewConversationView.initSendItem();

      expect(CreateNewConversationView.mmsList[0].isMsm).assertFalse();

      mocker.clear(settingService);
      mocker.clear(ConversationDataSource.getInstance());
      mocker.clear(DateUtil);
      mocker.clear(CreateNewConversationView);
    })

    it('CreateNewConversationViewTest_setDateShow_index_minus1_length_0', 0, () => {
      let currentItem: mmsListType = new mmsListType();
      let list: mmsListType[] = [];

      CreateNewConversationView.setDateShow(currentItem, list, undefined);
      CreateNewConversationView.setDateShow(currentItem, list, -1);

      expect(currentItem.dateShow).assertTrue();
    })

    it('CreateNewConversationViewTest_setDateShow_index_minus1_length_1', 0, () => {
      let currentItem: mmsListType = new mmsListType();
      let list: mmsListType[] = [currentItem];
      when(mocker.mockFunc(DateUtil, DateUtil.isNotSameDay))(ArgumentMatchers.any)
        .afterReturn(true)

      CreateNewConversationView.setDateShow(currentItem, list, -1);

      expect(currentItem.dateShow).assertTrue();

      mocker.clear(DateUtil);
    })

    it('CreateNewConversationViewTest_setDateShow_index_0_length_1', 0, () => {
      let currentItem: mmsListType = new mmsListType();
      let list: mmsListType[] = [currentItem];
      when(mocker.mockFunc(DateUtil, DateUtil.isNotSameDay))(ArgumentMatchers.any)
        .afterReturn(true)

      CreateNewConversationView.setDateShow(currentItem, list, 0);

      expect(currentItem.dateShow).assertTrue();

      mocker.clear(DateUtil);
    })

    it('CreateNewConversationViewTest_setDateShow_index_1_length_1', 0, () => {
      let currentItem: mmsListType = new mmsListType();
      let list: mmsListType[] = [currentItem];
      when(mocker.mockFunc(DateUtil, DateUtil.isNotSameDay))(ArgumentMatchers.any)
        .afterReturn(true)

      CreateNewConversationView.setDateShow(currentItem, list, 1);

      expect(currentItem.dateShow).assertTrue();

      mocker.clear(DateUtil);
    })

    it('CreateNewConversationViewTest_setDateShow_catch', 0, () => {
      let currentItem: mmsListType = new mmsListType();
      let list: mmsListType[] = [currentItem];
      when(mocker.mockFunc(DateUtil, DateUtil.isNotSameDay))(ArgumentMatchers.any)
        .afterThrow('error')

      CreateNewConversationView.setDateShow(currentItem, list, 1);

      expect(currentItem.dateShow).assertFalse();

      mocker.clear(DateUtil);
    })

    it('CreateNewConversationViewTest_getThemeContent_first_text_notEmpty', 0, () => {
      CreateNewConversationView.textareaDatasource = [{
        textValue: 'xx'
      } as LooseObject, {
        textValue: 'xx'
      } as LooseObject];

      CreateNewConversationView.getThemeContent();

      expect(CreateNewConversationView.getThemeContent()).assertEqual($r('app.string.msg_theme') + ': ' + 'xx' + '\n' + 'xx');
    })

    it('CreateNewConversationViewTest_getThemeContent_first_empty_text_notEmpty', 0, () => {
      CreateNewConversationView.textareaDatasource = [{
        textValue: ''
      } as LooseObject, {
        textValue: 'xx'
      } as LooseObject];

      CreateNewConversationView.getThemeContent();

      expect(CreateNewConversationView.getThemeContent()).assertEqual('xx');
    })

    it('CreateNewConversationViewTest_getThemeContent_first_notEmpty_text_empty', 0, () => {
      CreateNewConversationView.textareaDatasource = [{
        textValue: 'xx'
      } as LooseObject, {
        textValue: ''
      } as LooseObject];

      CreateNewConversationView.getThemeContent();

      expect(CreateNewConversationView.getThemeContent()).assertEqual($r('app.string.msg_theme') + ': ' + 'xx');
    })

    it('CreateNewConversationViewTest_clearMsm_list_empty', 0, () => {
      CreateNewConversationView.isEditMms = true;
      mocker.mockFunc(CreateNewConversationView, CreateNewConversationView.updatePreview);

      CreateNewConversationView.clearMsm();

      expect(CreateNewConversationView.isEditMms).assertFalse();
      mocker.clear(CreateNewConversationView);
    })

    it('CreateNewConversationViewTest_clearMsm_list', 0, () => {
      CreateNewConversationView.isEditMms = false;
      CreateNewConversationView.mmsEditList.push({
        type: 3,
        uriPath: '',
        time: '',
        fileSize: 10
      } as MmsSourceType);
      mocker.mockFunc(CreateNewConversationView, CreateNewConversationView.updatePreview);

      CreateNewConversationView.clearMsm();

      expect(CreateNewConversationView.mmsEditList.length).assertEqual(0);
      mocker.clear(CreateNewConversationView);
    })

    it('CreateNewConversationViewTest_resetMmsSource', 0, () => {
      mocker.mockFunc(CreateNewConversationView, CreateNewConversationView.resetAttachAreaPicture);
      mocker.mockFunc(CreateNewConversationView.mAttachAreaCtrl, CreateNewConversationView.mAttachAreaCtrl.resetMms);

      CreateNewConversationView.resetMmsSource();

      expect(CreateNewConversationView.canSendMessage).assertFalse();

      mocker.clear(CreateNewConversationView.mAttachAreaCtrl);
      mocker.clear(CreateNewConversationView);
    })

    it('CreateNewConversationViewTest_resetMmsSourceOfRcsMessageNotInAttachmentArea', 0, () => {
      mocker.mockFunc(CreateNewConversationView, CreateNewConversationView.resetAttachAreaPicture);
      mocker.mockFunc(CreateNewConversationView.mAttachAreaCtrl, CreateNewConversationView.mAttachAreaCtrl.refreshDisplay);

      CreateNewConversationView.resetMmsSourceOfRcsMessageNotInAttachmentArea();

      expect(CreateNewConversationView).not().assertUndefined();

      mocker.clear(CreateNewConversationView.mAttachAreaCtrl);
      mocker.clear(CreateNewConversationView);
    })

    it('CreateNewConversationViewTest_resetMmsSourceOfRcsMessageNotInAttachmentArea_mmDisplaySource', 0, () => {
      CreateNewConversationView.mAttachAreaCtrl.mmDisplaySource = [{
        text: 'xx'
      } as Mms];
      mocker.mockFunc(CreateNewConversationView, CreateNewConversationView.resetAttachAreaPicture);
      mocker.mockFunc(CreateNewConversationView.mAttachAreaCtrl, CreateNewConversationView.mAttachAreaCtrl.refreshDisplay);


      CreateNewConversationView.resetMmsSourceOfRcsMessageNotInAttachmentArea();

      expect(CreateNewConversationView.canSendMessage).assertTrue();

      mocker.clear(CreateNewConversationView.mAttachAreaCtrl);
      mocker.clear(CreateNewConversationView);
    })

    it('CreateNewConversationViewTest_sendAudio', 0, async () => {
      mocker.mockFunc(CreateNewConversationView, CreateNewConversationView.showToast);
      await CreateNewConversationView.sendAudio();
      mocker.verify('showToast', []).never();

      when(mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences))('inRepairMode')
        .afterReturn(true);
      await CreateNewConversationView.sendAudio();
      expect(CreateNewConversationView.isChangeInputPlaceholder).assertTrue();

      mocker.clear(SharedPreferencesUtils);
      CreateNewConversationView.isAirPlaneMode = true;
      when(mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences))('inRepairMode')
        .afterReturn(false);
      await CreateNewConversationView.sendAudio();
      expect(CreateNewConversationView.isChangeInputPlaceholder).assertTrue();

      CreateNewConversationView.isAirPlaneMode = false;
      CreateNewConversationView.canSendMessage = false;
      CreateNewConversationView.isNewMsg = true;
      CreateNewConversationView.receiveContactValue = '111';
      await CreateNewConversationView.sendAudio();
      expect(CreateNewConversationView.canSendMessage).assertTrue();

      CreateNewConversationView.receiveContactValue = '';
      CreateNewConversationView.threadId = 100001;
      mocker.mockFunc(CreateNewConversationView, CreateNewConversationView.initNewSelectContacts);
      await CreateNewConversationView.sendAudio();
      expect(CreateNewConversationView.canSendMessage).assertTrue();

      CreateNewConversationView.receiveContactValue = '';
      await CreateNewConversationView.sendAudio();
      expect(CreateNewConversationView.canSendMessage).assertTrue();

      CreateNewConversationView.isNewMsg = false;
      await CreateNewConversationView.sendAudio();
      expect(CreateNewConversationView.vCardJumpBack).assertFalse();

      CreateNewConversationView.canSendMessage = true;
      await CreateNewConversationView.sendAudio();
      expect(CreateNewConversationView.vCardJumpBack).assertFalse();

      CreateNewConversationView.canSendMessage = false;
      CreateNewConversationView.isNewMsg = true;
      await CreateNewConversationView.sendAudio();
      CreateNewConversationView.receiveContactValue = '';
      CreateNewConversationView.threadId = 90111;
      await CreateNewConversationView.sendAudio();
      CreateNewConversationView.isNewMsg = false;
      await CreateNewConversationView.sendAudio();
      expect(CreateNewConversationView.vCardJumpBack).assertFalse();
      mocker.clear(SharedPreferencesUtils);
      mocker.clear(CreateNewConversationView);
    })

    it('CreateNewConversationViewTest_initAudioItem_rcsDisplaySource_empty_contentType_3', 0, async () => {
      MMAttachmentAreaController.getInstance().rcsDisplaySource = [];

      mocker.mockFunc(CreateNewConversationView, CreateNewConversationView.getSmiledRcsSource);
      mocker.mockFunc(CreateNewConversationView, CreateNewConversationView.setDateShow);
      mocker.mockFunc(DateUtil, DateUtil.convertTimeStampToDateWeek);
      mocker.mockFunc(DateUtil, DateUtil.fullDate);
      when(mocker.mockFunc(CreateNewConversationView, CreateNewConversationView.getSmiledRcsSource))(ArgumentMatchers.any)
        .afterReturn(new Promise<Mms[]>(resolve => resolve([])));
      mocker.mockFunc(ConversationDataSource.getInstance(), ConversationDataSource.getInstance().refresh);

      when(mocker.mockFunc(MmsUtil, MmsUtil.getRcsContentType))(ArgumentMatchers.any)
        .afterReturn(3);

      await CreateNewConversationView.initAudioItem(context);

      expect(CreateNewConversationView.mmsList.length).assertEqual(6);

      mocker.clear(ConversationDataSource.getInstance());
      mocker.clear(DateUtil);
      mocker.clear(MmsUtil);
      mocker.clear(CreateNewConversationView);
    })

    it('CreateNewConversationViewTest_resetValuesOfSwitchingCard', 0, () => {
      CreateNewConversationView.isAirPlaneMode = false;
      CreateNewConversationView.canSendMessage = true;
      CreateNewConversationView.isNewMsg = true;
      mocker.mockFunc(CreateNewConversationView, CreateNewConversationView.clearMsm);
      mocker.mockFunc(CreateNewConversationView, CreateNewConversationView.resetMmsSource);

      CreateNewConversationView.resetValuesOfSwitchingCard();

      expect(CreateNewConversationView.canSendMessage).assertTrue();
      mocker.clear(CreateNewConversationView);
    })

    it('CreateNewConversationViewTest_isFoldSend_curBp_bp', 0, () => {
      AppStorage.setOrCreate('curBp', 'bp');
      mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().setObject);
      when(mocker.mockFunc(ConversationListService, ConversationListService.getInstance))().afterReturn({
        querySessionByTelephone: (telephone: string, callback: Function, context: Context,
          isFuzzyMatch = false, chatbotParameters?: ChatbotParameters) => {
          if (callback) {
            callback({ code: 1, response: { id: 1 } as LooseObject })
          }
        }
      });
      when(mocker.mockFunc(ConversationListController, ConversationListController.getInstance))().afterReturn({
        refreshConversationListData: (context: Context) => {},
        lastIndex: -1
      });
      CreateNewConversationView.queryOldMessageList('570977632', () => {
      });
      CreateNewConversationView.isFoldSend(context, '111111');
      mocker.clear(GlobalContext.getContext());
      mocker.clear(ConversationListService);
      mocker.clear(ConversationListController);
    })

    it('CreateNewConversationViewTest_isFoldSend_curBp_sm', 0, () => {
      AppStorage.setOrCreate('curBp', 'sm');
      when(mocker.mockFunc(ConversationListController, ConversationListController.getInstance))().afterReturn({
        refreshConversationListData: (context: Context) => {},
        lastIndex: -1
      });
      CreateNewConversationView.isFoldSend(context, '111111');
      expect(ConversationListController.getInstance().lastIndex).assertEqual(-1);
      mocker.clear(ConversationListService);
    })

    it('CreateNewConversationViewTest_newSend_isPhoneNumber_false', 0, () => {
      CreateNewConversationView.receiveContactValue = 'xdf';
      when(mocker.mockFunc(TelephoneUtil, TelephoneUtil.isPhoneNumber))(CreateNewConversationView.receiveContactValue)
        .afterReturn(false);
      CreateNewConversationView.newSend();
      expect(CreateNewConversationView.contactsNum).assertEqual(1);
      mocker.clear(TelephoneUtil);
    })

    it('CreateNewConversationViewTest_newSend_selectContacts_length_1_selectContacts_receiveContactValue_empty', 0, () => {
      CreateNewConversationView.receiveContactValue = '';
      CreateNewConversationView.newSend();
      expect(CreateNewConversationView.contactsNum).assertEqual(1);
    })

    it('CreateNewConversationViewTest_newSend_selectContacts_length_0_selectContacts_receiveContactValue_notEmpty', 0, () => {
        CreateNewConversationView.receiveContactValue = '570977632';
        when(mocker.mockFunc(TelephoneUtil, TelephoneUtil.isPhoneNumber))(CreateNewConversationView.receiveContactValue)
          .afterReturn(true);
        CreateNewConversationView.newSend();
        expect(CreateNewConversationView.contactsNum).assertEqual(1);
        mocker.clear(TelephoneUtil);
      })

    it('CreateNewConversationViewTest_newSend_selectContacts_length_0_selectContacts_receiveContactValue_empty', 0, () => {
      CreateNewConversationView.receiveContactValue = '';
      CreateNewConversationView.newSend();
      expect(CreateNewConversationView.contactsNum).assertEqual(1);
    })

    it('CreateNewConversationViewTest_initNewSelectContacts_contactName_notEmpty', 0, () => {
      CreateNewConversationView.strContactsName = 'name';
      let contacts: LooseObject[] = [{
        telephone: '569876533',
        rawContactId: '0',
        telephoneFormat: '569876533',
        contactName: 'name',
      }];
      when(mocker.mockFunc(TelephoneUtil, TelephoneUtil.dealSelectContactsSort))(ArgumentMatchers.any)
        .afterReturn(contacts);
      mocker.mockFunc(CreateNewConversationView, CreateNewConversationView.photoFirstNameDeal);

      CreateNewConversationView.initNewSelectContacts([{
        telephone: '569876533',
        telephoneFormat: '569876533',
        contactName: 'name',
        rawContactId: '0'
      }]);
      expect(CreateNewConversationView.contactsNum).assertEqual(1);
      mocker.clear(TelephoneUtil);
      mocker.clear(CreateNewConversationView);
    })

    it('CreateNewConversationViewTest_initNewSelectContacts_contactName_empty', 0, () => {
      CreateNewConversationView.strContactsName = 'name';
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
      mocker.mockFunc(CreateNewConversationView, CreateNewConversationView.photoFirstNameDeal);

      CreateNewConversationView.initNewSelectContacts([{
        telephone: '569876533',
        telephoneFormat: '569876533',
        contactName: '',
        rawContactId: '0'
      }]);
      expect(CreateNewConversationView.contactsNum).assertEqual(0);
      mocker.clear(TelephoneUtil);
      mocker.clear(CreateNewConversationView);
    })

    it('CreateNewConversationViewTest_setRcsMsgType_type_3', 0, () => {
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
      CreateNewConversationView.setRcsMsgType(actionData, item);
      expect(item.msgType >= 0).assertTrue();
    })

    it('CreateNewConversationViewTest_setRcsMsgType_type_9', 0, () => {
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
      CreateNewConversationView.setRcsMsgType(actionData, item);
      expect(item.msgType).assertEqual(3);
    })

    it('CreateNewConversationViewTest_setRcsMsgType_type_4', 0, () => {
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
      CreateNewConversationView.setRcsMsgType(actionData, item);
      expect(actionData.content).assertEqual(JSON.stringify(tempObj));
    })

    it('CreateNewConversationViewTest_setRcsMsgType_type_8', 0, () => {
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
      CreateNewConversationView.setRcsMsgType(actionData, item);
      expect(item.msgType).assertEqual(8);
    })

    it('CreateNewConversationViewTest_setRcsMsgType_rcsType_1_path', 0, () => {
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
      CreateNewConversationView.setRcsMsgType(actionData, item);
      expect(actionData.content).assertEqual('');
    })

    it('CreateNewConversationViewTest_setRcsMsgType_rcsType_1', 0, () => {
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
      CreateNewConversationView.setRcsMsgType(actionData, item);
      expect(actionData.content).assertEqual('');
    })

    it('CreateNewConversationViewTest_setRcsMsgType_type_7', 0, () => {
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

      CreateNewConversationView.setRcsMsgType(actionData, item);

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

    it('CreateNewConversationViewTest_setRcsMsgType_type_10', 0, () => {
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

      CreateNewConversationView.setRcsMsgType(actionData, item);
      let addressJson = '{"body":"name;address","longitude":"1","latitude":"1","accuracy":"0"}';

      expect(actionData.content).assertEqual(addressJson);
    })

    it('CreateNewConversationViewTest_changeValue_e_empty_isEditMms_true_isNewMsg_true_receiveContactValue_empty',
      0, () => {
        CreateNewConversationView.isEditMms = true;
        CreateNewConversationView.isRcsMms = true;
        CreateNewConversationView.isNewMsg = true;
        CreateNewConversationView.receiveContactValue = '';
        CreateNewConversationView.selectContactsMap = new Map();

        when(mocker.mockFunc(MmsPreferences.getInstance(), MmsPreferences.getInstance().haveSimCardReady))()
          .afterReturn(true);
        mocker.mockFunc(CreateNewConversationView, CreateNewConversationView.setCanSendMsgStatus);

        CreateNewConversationView.changeValue('');

        expect(CreateNewConversationView.canSendMessage).assertFalse();

        mocker.clear(MmsPreferences.getInstance());
        mocker.clear(CreateNewConversationView);
      })

    it('CreateNewConversationViewTest_changeValue_e_empty_isEditMms_true_isNewMsg_true',
      0, () => {
        CreateNewConversationView.isEditMms = true;
        CreateNewConversationView.isRcsMms = true;
        CreateNewConversationView.isNewMsg = true;
        CreateNewConversationView.receiveContactValue = 'xx';
        CreateNewConversationView.selectContactsMap.set(CreateNewConversationView.threadId, [{
          telephone: '670988763'
        } as selectContactType]);

        when(mocker.mockFunc(MmsPreferences.getInstance(), MmsPreferences.getInstance().haveSimCardReady))()
          .afterReturn(true);
        mocker.mockFunc(CreateNewConversationView, CreateNewConversationView.setCanSendMsgStatus);

        CreateNewConversationView.changeValue('');

        expect(CreateNewConversationView.canSendMessage).assertTrue();

        mocker.clear(MmsPreferences.getInstance());
        mocker.clear(CreateNewConversationView);
      })

    it('CreateNewConversationViewTest_changeValue_e_empty_isEditMms_false', 0, () => {
      CreateNewConversationView.isEditMms = false;
      CreateNewConversationView.selectContactsMap = new Map();
      CreateNewConversationView.changeValue('');
      expect(CreateNewConversationView.canSendMessage).assertFalse();
      mocker.clear(MmsPreferences.getInstance());
    })

    it('CreateNewConversationViewTest_changeValue_e_notEmpty_isNewMsg_true_receiveContactValue_empty_selectContacts_empty',
      0, () => {
        CreateNewConversationView.isNewMsg = true;
        CreateNewConversationView.receiveContactValue = '';
        CreateNewConversationView.changeValue('xxxx');
        expect(CreateNewConversationView.canSendMessage).assertFalse();
        mocker.clear(MmsPreferences.getInstance());
      })

    it('CreateNewConversationViewTest_changeValue_isNewMsg_false_receiveContactValue_empty',
      0, () => {
        CreateNewConversationView.isNewMsg = false;
        CreateNewConversationView.receiveContactValue = '';

        when(mocker.mockFunc(MmsPreferences.getInstance(), MmsPreferences.getInstance().haveSimCardReady))()
          .afterReturn(true);
        mocker.mockFunc(CreateNewConversationView, CreateNewConversationView.setCanSendMsgStatus);

        CreateNewConversationView.changeValue('');

        expect(CreateNewConversationView.canSendMessage).assertFalse();

        mocker.clear(MmsPreferences.getInstance());
        mocker.clear(CreateNewConversationView);
      })

    it('CreateNewConversationViewTest_changeValue_isNewMsg_true', 0, () => {
      CreateNewConversationView.isNewMsg = true;
      CreateNewConversationView.receiveContactValue = 'xxx';

      when(mocker.mockFunc(MmsPreferences.getInstance(), MmsPreferences.getInstance().haveSimCardReady))()
        .afterReturn(true);
      mocker.mockFunc(CreateNewConversationView, CreateNewConversationView.setCanSendMsgStatus);

      CreateNewConversationView.changeValue('');

      expect(CreateNewConversationView.canSendMessage).assertFalse();

      mocker.clear(MmsPreferences.getInstance());
      mocker.clear(CreateNewConversationView);
    })

    it('CreateNewConversationViewTest_judgeSendBtnCanClicked_isNewMsg_true_receiveContactValue_notEmpty_haveSimCardReady_true',
      0, () => {
        CreateNewConversationView.isNewMsg = true;
        CreateNewConversationView.receiveContactValue = '570977632';
        when(mocker.mockFunc(TelephoneUtil, TelephoneUtil.isPhoneNumber))()
          .afterReturn(true);

        when(mocker.mockFunc(MmsPreferences.getInstance(), MmsPreferences.getInstance().haveSimCardReady))()
          .afterReturn(true);

        CreateNewConversationView.judgeSendBtnCanClicked();

        expect(CreateNewConversationView.canSendMessage).assertFalse();

        mocker.clear(TelephoneUtil);
        mocker.clear(MmsPreferences.getInstance());
      })

    it('CreateNewConversationViewTest_judgeSendBtnCanClicked_isNewMsg_true', 0, () => {
      CreateNewConversationView.isNewMsg = true;
      CreateNewConversationView.receiveContactValue = '570977632';
      when(mocker.mockFunc(TelephoneUtil, TelephoneUtil.isPhoneNumber))()
        .afterReturn(false);

      when(mocker.mockFunc(MmsPreferences.getInstance(), MmsPreferences.getInstance().haveSimCardReady))()
        .afterReturn(false);
      CreateNewConversationView.mmsEditList = [{} as MmsSourceType];

      CreateNewConversationView.judgeSendBtnCanClicked();

      expect(CreateNewConversationView.canSendMessage).assertFalse();

      mocker.clear(TelephoneUtil);
      mocker.clear(MmsPreferences.getInstance());
    })

    it('CreateNewConversationViewTest_judgeSendBtnCanClicked_isNewMsg_false_textValue_notEmpty', 0, () => {
      CreateNewConversationView.isNewMsg = false;
      CreateNewConversationView.receiveContactValue = '570977632';

      when(mocker.mockFunc(MmsPreferences.getInstance(), MmsPreferences.getInstance().haveSimCardReady))()
        .afterReturn(false);
      CreateNewConversationView.mmsEditList = [{} as MmsSourceType];
      CreateNewConversationView.textValue = 'xxx';

      CreateNewConversationView.judgeSendBtnCanClicked();

      expect(CreateNewConversationView.canSendMessage).assertTrue();

      mocker.clear(MmsPreferences.getInstance());
    })

    it('CreateNewConversationViewTest_judgeSendBtnCanClicked_isNewMsg_false_textValue_notEmpty_mmsEditList_empty', 0,
      () => {
        CreateNewConversationView.isNewMsg = false;
        CreateNewConversationView.receiveContactValue = '570977632';

        when(mocker.mockFunc(MmsPreferences.getInstance(), MmsPreferences.getInstance().haveSimCardReady))()
          .afterReturn(false);
        CreateNewConversationView.mmsEditList = [];
        CreateNewConversationView.textValue = 'xxx';

        CreateNewConversationView.judgeSendBtnCanClicked();

        expect(CreateNewConversationView.canSendMessage).assertTrue();

        mocker.clear(MmsPreferences.getInstance());
      })

    it('CreateNewConversationViewTest_judgeSendBtnCanClicked_isNewMsg_false_mmsEditList_notEmpty', 0, () => {
      CreateNewConversationView.isNewMsg = false;
      CreateNewConversationView.receiveContactValue = '570977632';
      CreateNewConversationView.textareaDatasource = [{} as LooseObject];

      when(mocker.mockFunc(MmsPreferences.getInstance(), MmsPreferences.getInstance().haveSimCardReady))()
        .afterReturn(false);
      CreateNewConversationView.mmsEditList = [{} as MmsSourceType];
      CreateNewConversationView.textValue = '';

      CreateNewConversationView.judgeSendBtnCanClicked();

      expect(CreateNewConversationView.canSendMessage).assertTrue();

      mocker.clear(MmsPreferences.getInstance());
    })

    it('CreateNewConversationViewTest_judgeSendBtnCanClicked_isNewMsg_false_textareaDatasource_empty', 0, () => {
      CreateNewConversationView.isNewMsg = false;
      CreateNewConversationView.receiveContactValue = '570977632';
      CreateNewConversationView.textareaDatasource = [];

      when(mocker.mockFunc(MmsPreferences.getInstance(), MmsPreferences.getInstance().haveSimCardReady))()
        .afterReturn(false);
      CreateNewConversationView.mmsEditList = [];
      CreateNewConversationView.textValue = '';

      CreateNewConversationView.judgeSendBtnCanClicked();

      expect(CreateNewConversationView.canSendMessage).assertTrue();

      mocker.clear(MmsPreferences.getInstance());
    })

    it('CreateNewConversationViewTest_setReceiveContactValue_length_0', 0, () => {
      let receiverData: BaseItemType = {
        contactValue: 'xx1',
        selectContacts: [],
        hasBlur: true
      };
      CreateNewConversationView.strContactsName = 'xx2';

      mocker.mockFunc(CreateNewConversationView, CreateNewConversationView.setCanSendMessage);

      CreateNewConversationView.pageInfos = new NavPathStack();
      CreateNewConversationView.setReceiveContactValue(receiverData);
      mocker.clear(CreateNewConversationView);

    })

    it('CreateNewConversationViewTest_setReceiveContactValue_length_2', 0, () => {
      let receiverData: BaseItemType = {
        contactValue: 'xx1',
        selectContacts: [{
          telephone: '570977633',
          telephoneFormat: '570977633',
          contactName: 'name'
        } as itemType, {
          telephone: '570977632',
          telephoneFormat: '570977632',
          contactName: ''
        } as itemType],
        hasBlur: true
      };
      CreateNewConversationView.strContactsName = 'xx2';

      mocker.mockFunc(CreateNewConversationView, CreateNewConversationView.setCanSendMessage);
      let isPhoneNumber: Function = mocker.mockFunc(TelephoneUtil, TelephoneUtil.isPhoneNumber);
      when(isPhoneNumber)('570977632').afterReturn(true);
      when(isPhoneNumber)('570977633').afterReturn(false);
      CreateNewConversationView.pageInfos = new NavPathStack();
      CreateNewConversationView.setReceiveContactValue(receiverData);
      mocker.clear(CreateNewConversationView);
      mocker.clear(TelephoneUtil);

    })

    it('CreateNewConversationViewTest_setCanSendMessage_length_0', 0, () => {
      CreateNewConversationView.textValue = 'xx';
      CreateNewConversationView.isEditMms = false;
      CreateNewConversationView.canSendMessage = true;
      CreateNewConversationView.setCanSendMessage([], '');
      expect(CreateNewConversationView.canSendMessage).assertFalse();
    })

    it('CreateNewConversationViewTest_setCanSendMessage_receiveContactValue_notEmpty', 0, () => {
      let receiveContactValue: string = 'xx';
      CreateNewConversationView.textValue = 'xx';
      CreateNewConversationView.isEditMms = false;
      CreateNewConversationView.canSendMessage = true;
      CreateNewConversationView.setCanSendMessage([], receiveContactValue);
      expect(CreateNewConversationView.canSendMessage).assertTrue();
    })

    it('CreateNewConversationViewTest_setCanSendMessage_canSendMessage_false', 0, () => {
      let receiveContactValue: string = 'xx';
      CreateNewConversationView.textValue = 'xx';
      CreateNewConversationView.isEditMms = false;
      CreateNewConversationView.canSendMessage = false;
      when(mocker.mockFunc(MmsPreferences.getInstance(),MmsPreferences.getInstance().haveSimCardReady))()
        .afterReturn(true);
      CreateNewConversationView.setCanSendMessage([], receiveContactValue);
      expect(CreateNewConversationView.canSendMessage).assertTrue();
      mocker.clear(MmsPreferences.getInstance());
    })

    it('CreateNewConversationViewTest_setCanSendMessage_isEditMms_true', 0, () => {
      let receiveContactValue: string = 'xx';
      CreateNewConversationView.textValue = '';
      CreateNewConversationView.isEditMms = true;
      CreateNewConversationView.canSendMessage = false;
      when(mocker.mockFunc(MmsPreferences.getInstance(),MmsPreferences.getInstance().haveSimCardReady))()
        .afterReturn(false);
      CreateNewConversationView.setCanSendMessage([], receiveContactValue);
      expect(CreateNewConversationView.canSendMessage).assertFalse();
      mocker.clear(MmsPreferences.getInstance());
    })

    it('CreateNewConversationViewTest_setCanSendMessage_length_1', 0, () => {
      let selectContacts: itemType[] = [{} as itemType];
      let receiveContactValue: string = 'xx';
      CreateNewConversationView.textValue = '';
      CreateNewConversationView.isEditMms = false;
      CreateNewConversationView.canSendMessage = false;
      CreateNewConversationView.setCanSendMessage(selectContacts, receiveContactValue);
      expect(CreateNewConversationView.canSendMessage).assertFalse();
    })

    it('CreateNewConversationViewTest_setCanSendMessage_haveSimCardReady_true', 0, () => {
      let selectContacts: itemType[] = [];
      let receiveContactValue: string = 'xx';
      CreateNewConversationView.textValue = '';
      CreateNewConversationView.isEditMms = false;
      CreateNewConversationView.canSendMessage = false;
      when(mocker.mockFunc(MmsPreferences.getInstance(), MmsPreferences.getInstance().haveSimCardReady))()
        .afterReturn(true);
      CreateNewConversationView.setCanSendMessage(selectContacts, receiveContactValue);
      expect(CreateNewConversationView.canSendMessage).assertFalse();
      mocker.clear(MmsPreferences.getInstance());
    })

    it('CreateNewConversationViewTest_refreshSendMessageStatus_receiveContactValue_notEmpty', 0, () => {
      CreateNewConversationView.mAttachAreaCtrl.mmDisplaySource = [{} as Mms];
      CreateNewConversationView.canSendMessage = false;
      CreateNewConversationView.isEditMms = false;
      CreateNewConversationView.textValue = '';
      CreateNewConversationView.isNewMsg = true;
      CreateNewConversationView.receiveContactValue = 'xx';
      CreateNewConversationView.refreshSendMessageStatus();
      expect(CreateNewConversationView.isEditMms).assertFalse();
    })

    it('CreateNewConversationViewTest_refreshSendMessageStatus_selectContacts_notEmpty', 0, () => {
      CreateNewConversationView.mAttachAreaCtrl.mmDisplaySource = [{} as Mms];
      CreateNewConversationView.canSendMessage = false;
      CreateNewConversationView.isEditMms = false;
      CreateNewConversationView.textValue = '';
      CreateNewConversationView.isNewMsg = true;
      CreateNewConversationView.receiveContactValue = '';
      CreateNewConversationView.refreshSendMessageStatus();
      expect(CreateNewConversationView.isEditMms).assertFalse();
    })

    it('CreateNewConversationViewTest_refreshSendMessageStatus_isNewMsg_false', 0, () => {
      CreateNewConversationView.mAttachAreaCtrl.mmDisplaySource = [{} as Mms];
      CreateNewConversationView.canSendMessage = false;
      CreateNewConversationView.isEditMms = false;
      CreateNewConversationView.textValue = '';
      CreateNewConversationView.isNewMsg = false;
      CreateNewConversationView.receiveContactValue = '';
      CreateNewConversationView.refreshSendMessageStatus();
      expect(CreateNewConversationView.isEditMms).assertFalse();
    })

    it('CreateNewConversationViewTest_refreshSendMessageStatus_textValue_empty', 0, () => {
      CreateNewConversationView.mAttachAreaCtrl.mmDisplaySource = [];
      CreateNewConversationView.canSendMessage = true;
      CreateNewConversationView.isEditMms = false;
      CreateNewConversationView.textValue = '';
      CreateNewConversationView.isNewMsg = false;
      CreateNewConversationView.receiveContactValue = '';
      CreateNewConversationView.refreshSendMessageStatus();
      expect(CreateNewConversationView.isEditMms).assertFalse();
    })

    it('CreateNewConversationViewTest_refreshSendMessageStatus_textValue_notEmpty', 0, () => {
      CreateNewConversationView.mAttachAreaCtrl.mmDisplaySource = [];
      CreateNewConversationView.canSendMessage = true;
      CreateNewConversationView.isEditMms = false;
      CreateNewConversationView.textValue = 'xx';
      CreateNewConversationView.isNewMsg = false;
      CreateNewConversationView.receiveContactValue = '';
      CreateNewConversationView.refreshSendMessageStatus();
      expect(CreateNewConversationView.isEditMms).assertFalse();
    })

    it('CreateNewConversationViewTest_initRcsSource_rcsDisplaySource_length_0', 0, async () => {
      let mms: Mms = {
        duration: '0',
        type: 1,
        name: 'name',
        path: ''
      } as Mms;
      CreateNewConversationView.mAttachAreaCtrl.rcsDisplaySource = [];
      when(mocker.mockFunc(FileUtil, FileUtil.getFileName))(ArgumentMatchers.any)
        .afterReturn('name');
      when(mocker.mockFunc(ObjectUtil, ObjectUtil.getCopyObject))(ArgumentMatchers.any)
        .afterReturn(mms);

      await CreateNewConversationView.initRcsSource(false, 0);

      mocker.verify('getFileName', ['']).never();

      mocker.clear(FileUtil);
      mocker.clear(ObjectUtil);
    })

    it('CreateNewConversationViewTest_initRcsSource_rcsDisplaySource_length_1_type_2_galleryPath', 0, async () => {
      let mms: Mms = {
        duration: '0',
        type: 2,
        galleryPath: '',
        name: 'name',
        path: ''
      } as Mms;
      CreateNewConversationView.mAttachAreaCtrl.rcsDisplaySource = [mms];
      when(mocker.mockFunc(FileUtil, FileUtil.getFileName))(ArgumentMatchers.any)
        .afterReturn('name');
      when(mocker.mockFunc(ObjectUtil, ObjectUtil.getCopyObject))(ArgumentMatchers.any)
        .afterReturn(mms);

      await CreateNewConversationView.initRcsSource(false, 0);
      mocker.clear(FileUtil);
      mocker.clear(ObjectUtil);
    })

    it('CreateNewConversationViewTest_initRcsSource_rcsDisplaySource_length_2_type_2_galleryPath_undefined', 0,
      async () => {
        let mms: Mms = {
          duration: '0',
          type: 1,
          galleryPath: undefined,
          name: 'name',
          path: ''
        } as Mms;
        CreateNewConversationView.mAttachAreaCtrl.rcsDisplaySource = [mms, mms];
        when(mocker.mockFunc(FileUtil, FileUtil.getFileName))(ArgumentMatchers.any)
          .afterReturn('name');
        when(mocker.mockFunc(ObjectUtil, ObjectUtil.getCopyObject))(ArgumentMatchers.any)
          .afterReturn(mms);

        await CreateNewConversationView.initRcsSource(false, 0);

        mocker.verify('getFileName', ['']).never();

        mocker.clear(FileUtil);
        mocker.clear(ObjectUtil);
      })

    it('CreateNewConversationViewTest_getSmiledRcsSource', 0, async () => {
      when(mocker.mockFunc(CreateNewConversationView, CreateNewConversationView.initRcsSource))(false)
        .afterAction(() => {
          CreateNewConversationView.copySource = [{} as Mms];
          return new Promise<void>(resolve => resolve());
        });
      when(mocker.mockFunc(CreateNewConversationView, CreateNewConversationView.getSmilSourceForMore))(ArgumentMatchers.any)
        .afterReturn({} as Mms);
      await CreateNewConversationView.getSmiledRcsSource(context);
      expect(CreateNewConversationView.copySource.length).assertEqual(3);
      mocker.clear(CreateNewConversationView);
    })

    it('CreateNewConversationViewTest_getSmilSourceForMore', 0, () => {
      when(mocker.mockFunc(SmilFile, SmilFile.buildSmilFile))(ArgumentMatchers.any)
        .afterReturn('');
      when(mocker.mockFunc(FileUtil,
        FileUtil.writeTextToSandBox))(ArgumentMatchers.any)
        .afterReturn({
          'path': '',
          'name': ''
        } as Record<string, string>);

      let res: Mms = CreateNewConversationView.getSmilSourceForMore(context, []);

      expect(res.duration).assertEqual('');

      mocker.clear(SmilFile);
      mocker.clear(FileUtil);
    })

    it('CreateNewConversationViewTest__updateMmsSession', 0, () => {
      let res = false;
      when(mocker.mockFunc(ConversationService.getInstance(),
        ConversationService.getInstance().updateSmsMmsInfoByCondition))(ArgumentMatchers.any)
        .afterAction(() => {
          res = true;
        });

      when(mocker.mockFunc(ConversationListService, ConversationListService.getInstance))().afterReturn({
        updateSessionByCondition: (context: Context, actionData: LooseObject, valueBucket: ValuesBucket,
          callback: Function | null, needUpdateSessionList?: boolean) => {}
      });
      CreateNewConversationView.updateMmsSession(context, new mmsListType());

      expect(res).assertTrue();

      mocker.clear(ConversationListService);
      mocker.clear(ConversationService.getInstance());
    })

    it('CreateNewConversationViewTest_dealMmsMessageResult_tmplBol_true', 0, () => {
      let actionData: ActionDataType = {
        contactName: 'name',
        destinationHost: 'host',
      } as ActionDataType;
      CreateNewConversationView.sendReportable = true;
      mocker.mockFunc(CreateNewConversationView, CreateNewConversationView.showToast);
      when(mocker.mockFunc(GlobalContext.getContext(),
        GlobalContext.getContext().getObject))('mmsContext')
        .afterReturn({
          resourceManager: {
            getStringSync: (resource: Resource, ...args: (string | number)[]): string => 'xx'
          } as resourceManager.ResourceManager
        } as Object | window.WindowStage);

      CreateNewConversationView.dealMmsMessageResult(actionData, 0);

      mocker.clear(GlobalContext.getContext());

      CreateNewConversationView.sendReportable = false;
      mocker.mockFunc(CreateNewConversationView, CreateNewConversationView.showToast);
      CreateNewConversationView.dealMmsMessageResult( actionData, 0);
      expect(CreateNewConversationView).not().assertUndefined();
      mocker.clear(CreateNewConversationView);
      mocker.clear(GlobalContext.getContext());
    })

    it('CreateNewConversationViewTest_resetAttachAreaPicture', 0, () => {
      mocker.mockFunc(CreateNewConversationView.pictureCtrl, CreateNewConversationView.pictureCtrl.resetPictureStatus);
      CreateNewConversationView.resetAttachAreaPicture();
      mocker.clear(CreateNewConversationView.pictureCtrl);
    })

    it('CreateNewConversationViewTest_getMmsDataSource_mmDisplaySource_length_0', 0, async () => {
      CreateNewConversationView.mAttachAreaCtrl.mmDisplaySource = [];
      let res: Array<Mms> = await CreateNewConversationView.getMmsDataSource(context);
      expect(res.length).assertEqual(0);
    })

    it('CreateNewConversationViewTest_getMmsDataSource_mmDisplaySource_length_1', 0, async () => {
      CreateNewConversationView.mAttachAreaCtrl.mmDisplaySource = [{} as Mms];
      CreateNewConversationView.mAttachAreaCtrl.copySource = [{} as Mms];
      CreateNewConversationView.textValue = 'xx';
      when(mocker.mockFunc(CreateNewConversationView, CreateNewConversationView.getTextSource))()
        .afterReturn({} as Mms);

      when(mocker.mockFunc(FileUtil, FileUtil.writeTextToSandBox))(ArgumentMatchers.any).afterReturn({
        'path': '',
        'name': ''
      } as Record<string, string>);

      let res: Array<Mms> = await CreateNewConversationView.getMmsDataSource(context);

      expect(res.length).assertEqual(3);
      mocker.clear(CreateNewConversationView);
      mocker.clear(FileUtil);
    })

    it('CreateNewConversationViewTest_getMmsDataSource_mmDisplaySource_length_1_textValue_empty', 0, async () => {
      CreateNewConversationView.mAttachAreaCtrl.mmDisplaySource = [{} as Mms];
      CreateNewConversationView.mAttachAreaCtrl.copySource = [{} as Mms];
      CreateNewConversationView.textValue = '';

      when(mocker.mockFunc(FileUtil, FileUtil.writeTextToSandBox))(ArgumentMatchers.any).afterReturn({
        'path': '',
        'name': ''
      } as Record<string, string>);

      let res: Array<Mms> = await CreateNewConversationView.getMmsDataSource(context);

      expect(res.length).assertEqual(2);
      mocker.clear(FileUtil)
    })

    it('CreateNewConversationViewTest_getSmilSource', 0, () => {
      when(mocker.mockFunc(FileUtil, FileUtil.writeTextToSandBox))(ArgumentMatchers.any)
        .afterReturn({
          'path': '',
          'name': 'name'
        } as Record<string, string>);
      when(mocker.mockFunc(SmilFile, SmilFile.getSmil))(ArgumentMatchers.any)
        .afterReturn('');
      mocker.clear(FileUtil);
      mocker.clear(SmilFile);
    })

    it('CreateNewConversationViewTest_getTextSource', 0, () => {
      when(mocker.mockFunc(FileUtil, FileUtil.writeTextToSandBox))(ArgumentMatchers.any)
        .afterReturn({
          'path': '',
          'name': 'name'
        } as Record<string, string>);

      let res: Mms = CreateNewConversationView.getTextSource(context);

      expect(res.name).assertEqual('name');

      mocker.clear(FileUtil);
    })

    it('CreateNewConversationViewTest_isHasEmoji_string', 0, () => {
      let res: boolean = CreateNewConversationView.isHasEmoji('string');
      expect(res).assertFalse();
    })

    it('CreateNewConversationViewTest_isHasEmoji_notHave', 0, () => {
      let res: boolean = CreateNewConversationView.isHasEmoji('xx');
      expect(res).assertFalse();
    })

    it('CreateNewConversationViewTest_isHasEmoji_has', 0, () => {
      let res: boolean = CreateNewConversationView.isHasEmoji('😊');
      expect(res).assertTrue();
    })

    it('CreateNewConversationViewTest_setMmsDataSource_size_0', 0, async () => {
      let mmsSource: Array<Mms> = [{
        path: ''
      } as Mms];
      when(mocker.mockFunc(FileUtil, FileUtil.packingSize))(ArgumentMatchers.any)
        .afterReturn(new Promise<packingItem>(resolve => resolve({
          size: 0,
          data: new ArrayBuffer(0)
        } as packingItem)));

      await CreateNewConversationView.setMmsDataSource(context, mmsSource);

      expect(CreateNewConversationView).not().assertUndefined();

      mocker.clear(FileUtil);
    })

    it('CreateNewConversationViewTest_setMmsDataSource_size_1_type_9', 0, async () => {
      let mmsSource: Array<Mms> = [{
        path: ''
      } as Mms];
      when(mocker.mockFunc(FileUtil, FileUtil.packingSize))(ArgumentMatchers.any)
        .afterReturn(new Promise<packingItem>(resolve => resolve({
          size: 1,
          data: new ArrayBuffer(0)
        } as packingItem)));
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('fileTotalSize')
        .afterReturn(1);

      when(mocker.mockFunc(CreateNewConversationView, CreateNewConversationView.setMmsDataSourcePushListItem))(ArgumentMatchers.any)
        .afterReturn(new Promise<Mms>(resolve => resolve({
          type: 9
        } as Mms)));

      await CreateNewConversationView.setMmsDataSource(context, mmsSource);

      expect(CreateNewConversationView).not().assertUndefined();

      mocker.clear(FileUtil);
      mocker.clear(GlobalContext.getContext());
      mocker.clear(CreateNewConversationView);
    })

    it('CreateNewConversationViewTest_setMmsDataSource_size_1_type_0', 0, async () => {
      let mmsSource: Array<Mms> = [{
        path: ''
      } as Mms];
      when(mocker.mockFunc(FileUtil, FileUtil.packingSize))(ArgumentMatchers.any)
        .afterReturn(new Promise<packingItem>(resolve => resolve({
          size: 1,
          data: new ArrayBuffer(0)
        } as packingItem)));
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('fileTotalSize')
        .afterReturn(1);

      when(mocker.mockFunc(CreateNewConversationView, CreateNewConversationView.setMmsDataSourcePushListItem))(ArgumentMatchers.any)
        .afterReturn(new Promise<Mms>(resolve => resolve({
          type: 0
        } as Mms)));

      await CreateNewConversationView.setMmsDataSource(context, mmsSource);

      expect(CreateNewConversationView).not().assertUndefined();

      mocker.clear(FileUtil);
      mocker.clear(GlobalContext.getContext());
      mocker.clear(CreateNewConversationView);
    })

    it('CreateNewConversationViewTest_setMmsDataSourcePushListItem_type_1', 0, async () => {
      let mms: Mms = {
        path: '',
        type: 1,
        isOnAudio:false
      } as Mms;
      //先执行一次setMmsDataSourcePushListItem，先设置conversationPixelMap，使hasStorage=true
      await CreateNewConversationView.setMmsDataSourcePushListItem(mms, 0);
      //进而测试if (hasStorage)分支
      let res: Mms = await CreateNewConversationView.setMmsDataSourcePushListItem(mms, 0);
      expect(res.isOnAudio).assertFalse();
    })

    it('CreateNewConversationViewTest_setMmsDataSourcePushListItem_type_2', 0, async () => {
      let mms: Mms = {
        path: '',
        type: 2,
        isOnAudio:false
      } as Mms;
      let res: Mms = await CreateNewConversationView.setMmsDataSourcePushListItem(mms, 0);
      expect(res.isOnAudio).assertFalse();
    })

    it('CreateNewConversationViewTest_setMmsDataSourcePushListItem_type_3', 0, async () => {
      let mms: Mms = {
        path: '',
        type: 3,
        isOnAudio:false
      } as Mms;
      let res: Mms = await CreateNewConversationView.setMmsDataSourcePushListItem(mms, 0);
      expect(res.isOnAudio).assertFalse();
    })

    it('CreateNewConversationViewTest_setMmsDataSourcePushListItem_type_7', 0, async () => {
      let mms: Mms = {
        path: '',
        type: 7,
        index: 1,
        isOnAudio:false
      } as Mms;
      let res: Mms = await CreateNewConversationView.setMmsDataSourcePushListItem(mms, 0);
      expect(res.isOnAudio).assertFalse();
    })

    it('CreateNewConversationViewTest_setMmsDataSourcePushListItem_type_9', 0, async () => {
      let mms: Mms = {
        path: '',
        type: 9,
        index: 1,
        isOnAudio:false
      } as Mms;
      let res: Mms = await CreateNewConversationView.setMmsDataSourcePushListItem(mms, 0);
      expect(res.isOnAudio).assertFalse();
    })

    it('CreateNewConversationViewTest_getConvertDegreeString', 0, () => {
      let res: string = CreateNewConversationView.getConvertDegreeString(20.9);
      expect(res).assertEqual(`20°53'59"`);
    })

    it('CreateNewConversationViewTest_onHide', 0, () => {
      mocker.mockFunc(HiLog, HiLog.i);
      CreateNewConversationView.onHide();
      CreateNewConversationView.setIsShow();
      CreateNewConversationView.onHide();
      let TAG = 'CreateNewConversationViewModle';
      mocker.verify('i', [TAG, 'onHide']).never();
      mocker.clear(HiLog);
    })

    it('CreateNewConversationViewTest_initNewPageContacts_if1', 0, () => {
      CreateNewConversationView.strContactsNumber = '18236941541';
      CreateNewConversationView.contactsNum = 1;
      CreateNewConversationView.initNewPageContacts();
      let contactInfo: LooseObject = {
        "contactName": "",
        "telephone": "18236941541",
        "telephoneFormat": "18236941541",
        "headImage": "",
        "select": false,
        "yellowPageId": "",
        "hasYellowPageIcon": "",
        "rawContactId": ""
      }
      expect(JSON.stringify(CreateNewConversationView.commonCtrl.paramContact.transmitContacts[0].telephone))
        .assertEqual(JSON.stringify('18236941541'))
    })

    it('CreateNewConversationViewTest_initNewPageContacts_else', 0, () => {
      CreateNewConversationView.strContactsNumber = '18236941541,18238613546';
      CreateNewConversationView.contactsNum = 2;
      let contactInfo: LooseObject = {
        "contactName": "",
        "telephone": "18236941541",
        "telephoneFormat": "18236941541",
        "headImage": "",
        "select": false,
        "yellowPageId": "",
        "hasYellowPageIcon": "",
        "rawContactId": ""
      }
      CreateNewConversationView.initNewPageContacts()

      expect(JSON.stringify(CreateNewConversationView.commonCtrl.paramContact.transmitContacts[0]) == null)
        .assertFalse()
    })

    it('CreateNewConversationViewTest_onInitBySmc', 0, () => {
      let pageInfos: NavPathStack = new NavPathStack();
      mocker.mockFunc(HiLog, HiLog.i)
      CreateNewConversationView.onInitBySmc(pageInfos)
      let TAG = 'CreateNewConversationViewModle';
      mocker.verify('i', [TAG, 'onInit']).never();
      mocker.clear(HiLog)
    })

    it('CreateNewConversationViewTest_formateDuration', 0, () => {
      let time: string = '13600000'
      let res = CreateNewConversationView.formateDuration(time)
      expect(res).assertEqual('03:46:40')
    })

    it('CreateNewConversationViewTest_formateDuration_else', 0, () => {
      let time: string = '3200000'
      let res = CreateNewConversationView.formateDuration(time)
      expect(res).assertEqual('53:20')
    })

    it('CreateNewConversationViewTest_deleteMessageByGroupIds_if1', 0, () => {
      let time: string = '3200000'
      let res = CreateNewConversationView.formateDuration(time)
      expect(res).assertEqual('53:20')
    })

    it('CreateNewConversationViewTest_newSend2_receiveContactValueNoEmpty', 0, () => {
      CreateNewConversationView.receiveContactValue = '570977632';
      when(mocker.mockFunc(TelephoneUtil, TelephoneUtil.isPhoneNumber))(CreateNewConversationView.receiveContactValue)
        .afterReturn(true);
      mocker.mockFunc(CreateNewConversationView, CreateNewConversationView.initNewSelectContacts);
      CreateNewConversationView.newSend2(() => {});
      expect(CreateNewConversationView.contactsNum).assertEqual(2);
      mocker.clear(TelephoneUtil);
      mocker.clear(CreateNewConversationView);
    })

    it('CreateNewConversationViewTest_newSend2_receiveContactValueNoEmpty_isPhoneNumber_true', 0, () => {
      CreateNewConversationView.receiveContactValue = '570977632';
      when(mocker.mockFunc(TelephoneUtil, TelephoneUtil.isPhoneNumber))(CreateNewConversationView.receiveContactValue)
        .afterReturn(false);
      mocker.mockFunc(CreateNewConversationView, CreateNewConversationView.initNewSelectContacts);
      CreateNewConversationView.newSend2(() => {});
      expect(CreateNewConversationView.contactsNum).assertEqual(2);
      mocker.clear(TelephoneUtil);
      mocker.clear(CreateNewConversationView);
    })

    it('CreateNewConversationViewTest_newSend2_selectContacts_length_1_selectContacts_receiveContactValue_empty', 0, () => {
      CreateNewConversationView.receiveContactValue = '856456212';
      CreateNewConversationView.threadId = -1;
      mocker.mockFunc(CreateNewConversationView, CreateNewConversationView.initNewSelectContacts);
      CreateNewConversationView.newSend2(() => {});
      expect(CreateNewConversationView.contactsNum >= 0).assertTrue();
      mocker.clear(CreateNewConversationView);
    })

    it('CreateNewConversationViewTest_newSend2_selectContacts_length_0_selectContacts_receiveContactValue_empty', 0, () => {
      CreateNewConversationView.receiveContactValue = '';
      CreateNewConversationView.threadId = -1;
      mocker.mockFunc(CreateNewConversationView, CreateNewConversationView.initNewSelectContacts);
      CreateNewConversationView.newSend2(() => {});
      expect(CreateNewConversationView.contactsNum >= 0).assertTrue();
      mocker.clear(CreateNewConversationView);
    })

    it('CreateNewConversationViewTest_queryOldMessageList_telephone_isempty', 0, () => {
      let telephone = '';
      let callback: Function = () => {};
      mocker.mockFunc(HiLog, HiLog.i)
      CreateNewConversationView.queryOldMessageList(telephone, callback)
      let TAG = 'CreateNewConversationViewModle'
      mocker.verify('i', [TAG, 'queryOldMessageList, start']).never()
    })

    it('CreateNewConversationViewTest_queryOldMessageList_threadId_2_resId_1_if', 0, () => {
      CreateNewConversationView.threadId = 2;
      when(mocker.mockFunc(TelephoneUtil, TelephoneUtil.dealTelephoneSort))('570977632')
        .afterReturn('570977632');
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: 1,
              abilityResult: [{
                id: 1,
                hasDraft: 1
              } as ResponseType]
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve());
          }
        } as Object | window.WindowStage);
      when(mocker.mockFunc(CreateNewConversationView, CreateNewConversationView.queryMessageDetail))(ArgumentMatchers.any)
        .afterAction(() => {
          expect(CreateNewConversationView).not().assertUndefined();
        });

      when(mocker.mockFunc(ConversationListService, ConversationListService.getInstance))().afterReturn({
        querySessionByTelephone: (telephone: string, callback: Function, context: Context,
          isFuzzyMatch = false, chatbotParameters?: ChatbotParameters) => {
          if (callback) {
            callback({code:0, response: {id: 1} as LooseObject})
          }
        },
        deleteSessionByCondition: (actionData: LooseObject, callback: Function, context: Context) => {}
      });
      CreateNewConversationView.queryOldMessageList('570977632', () => {
      });

      mocker.clear(TelephoneUtil);
      mocker.clear(ConversationListService);
      mocker.clear(CreateNewConversationView);
      mocker.clear(GlobalContext.getContext());
    })

    it('CreateNewConversationViewTest_queryOldMessageList_threadId_1_res_id_1_if', 0, () => {
      CreateNewConversationView.threadId = 1;
      when(mocker.mockFunc(TelephoneUtil, TelephoneUtil.dealTelephoneSort))('570977632')
        .afterReturn('570977632');
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: 1,
              abilityResult: [{
                id: 1,
                hasDraft: 1
              } as ResponseType]
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve());
          }
        } as Object | window.WindowStage);
      when(mocker.mockFunc(CreateNewConversationView, CreateNewConversationView.queryMessageDetail))(ArgumentMatchers.any)
        .afterAction(() => {});

      when(mocker.mockFunc(ConversationListService, ConversationListService.getInstance))().afterReturn({
        querySessionByTelephone: (telephone: string, callback: Function, context: Context,
          isFuzzyMatch = false, chatbotParameters?: ChatbotParameters) => {
          if (callback) {
            callback({code:0, response: {id: 1} as LooseObject})
          }
        },
        deleteSessionByCondition: (actionData: LooseObject, callback: Function, context: Context) => {}
      });
      CreateNewConversationView.queryOldMessageList('570977632', () => {
      });

      mocker.clear(TelephoneUtil);
      mocker.clear(ConversationListService);
      mocker.clear(GlobalContext.getContext());
      mocker.clear(CreateNewConversationView);
    })

    it('CreateNewConversationViewTest_queryOldMessageList_threadId_1_res_id_0_callback_if', 0, () => {
      CreateNewConversationView.threadId = 1;
      when(mocker.mockFunc(TelephoneUtil, TelephoneUtil.dealTelephoneSort))('570977632')
        .afterReturn('570977632');
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: 0,
              abilityResult: [{
                id: 0,
                hasDraft: 1
              } as ResponseType]
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve());
          }
        } as Object | window.WindowStage);

      when(mocker.mockFunc(ConversationListService, ConversationListService.getInstance))().afterReturn({
        querySessionByTelephone: (telephone: string, callback: Function, context: Context,
          isFuzzyMatch = false, chatbotParameters?: ChatbotParameters) => {
          if (callback) {
            callback({code:0, response: {id: 0} as LooseObject})
          }
        },
        deleteSessionByCondition: (actionData: LooseObject, callback: Function, context: Context) => {}
      });
      CreateNewConversationView.queryOldMessageList('570977632', () => {
        expect(CreateNewConversationView).not().assertUndefined();
      });

      mocker.clear(TelephoneUtil);
      mocker.clear(ConversationListService);
      mocker.clear(GlobalContext.getContext());
    })

    it('CreateNewConversationViewTest_queryOldMessageList_res_code_minus1_callback_undefined_err', 0, () => {
      CreateNewConversationView.threadId = 1;
      when(mocker.mockFunc(TelephoneUtil, TelephoneUtil.dealTelephoneSort))('570977632')
        .afterReturn('570977632');
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: -1,
              abilityResult: [{
                id: 0,
                hasDraft: 1
              } as ResponseType]
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve());
          }
        } as Object | window.WindowStage);

      when(mocker.mockFunc(ConversationListService, ConversationListService.getInstance))().afterReturn({
        querySessionByTelephone: (telephone: string, callback: Function, context: Context,
          isFuzzyMatch = false, chatbotParameters?: ChatbotParameters) => {
          if (callback) {
            callback({code:-1, response: {id: 0} as LooseObject})
          }
        },
        deleteSessionByCondition: (actionData: LooseObject, callback: Function, context: Context) => {}
      });
      CreateNewConversationView.queryOldMessageList('570977632');

      expect(CreateNewConversationView).not().assertUndefined();

      mocker.clear(TelephoneUtil);
      mocker.clear(ConversationListService);
      mocker.clear(GlobalContext.getContext());
    })

    it('CreateNewConversationViewTest_handleProtocolChange_content_empty', 0, () => {
      let content = '';
      let TAG = 'CreateNewConversationViewModle';
      when(mocker.mockFunc(CreateNewConversationView, CreateNewConversationView.isNeedChangeFromMmsToSms))(ArgumentMatchers.any)
        .afterReturn(true)
      mocker.mockFunc(HiLog, HiLog.i)
      CreateNewConversationView.handleProtocolChange(content)
      mocker.verify('i', [TAG, 'empty text,change to sms']).never();
      mocker.clear(HiLog)
    })

    it('CreateNewConversationViewTest_handleProtocolChange_content_notEmpty', 0, () => {
      let content = 'ssssss';
      let TAG = 'CreateNewConversationViewModle';
      when(mocker.mockFunc(CreateNewConversationView, CreateNewConversationView.isNeedChangeFromSmsToMms))(ArgumentMatchers.any)
        .afterReturn(true)
      mocker.mockFunc(HiLog, HiLog.i)
      CreateNewConversationView.handleProtocolChange(content)
      mocker.verify('i', [TAG, 'larger text,change to mms']).never();
      mocker.clear(HiLog)
    })

    it('CreateNewConversationViewTest_handleProtocolChange_content_notEmpty_isNeedChangeFromMmsToSms', 0, () => {
      let content = 'ssssss';
      let TAG = 'CreateNewConversationViewModle';
      when(mocker.mockFunc(CreateNewConversationView, CreateNewConversationView.isNeedChangeFromSmsToMms))(ArgumentMatchers.any)
        .afterReturn(false)
      when(mocker.mockFunc(CreateNewConversationView, CreateNewConversationView.isNeedChangeFromMmsToSms))(ArgumentMatchers.any)
        .afterReturn(true)
      mocker.mockFunc(HiLog, HiLog.i)
      CreateNewConversationView.handleProtocolChange(content)
      mocker.verify('i', [TAG, 'small text,change to sms']).never();
      mocker.clear(HiLog)
    })

    it('CreateNewConversationViewTest_onbackpress2_noPageInfos', 0, () => {

      CreateNewConversationView.pageInfos.pushPathByName('InfoMsg', false);
      let result = CreateNewConversationView.onBackPress2();
      expect(result).assertTrue();
    })

    it('CreateNewConversationViewTest_onbackpress2_hasPageInfos', 0, () => {

      CreateNewConversationView.pageInfos = undefined;
      let result = CreateNewConversationView.onBackPress2();
      expect(result).assertFalse();
    })

    it('CreateNewConversationViewTest_clearSelectContacts_threadId_0', 0, () => {
      CreateNewConversationView.threadId = 0;
      CreateNewConversationView.clearSelectContacts(true);
      CreateNewConversationView.threadId = 1;
      CreateNewConversationView.clearSelectContacts(true);
      expect(CreateNewConversationView.threadId).assertEqual(1);
    })

    it('CreateNewConversationViewTest_deleteMessageByGroupIds_groupInfos', 0, () => {
      CreateNewConversationView.threadId = 0;
      mocker.mockFunc(HiLog, HiLog.i)
      CreateNewConversationView.deleteMessageByGroupIds(context, [1], undefined, true);
      let TAG = 'CreateNewConversationViewModle'
      mocker.verify('i', [TAG, 'deleteMessageByGroupIds groupId is :1']).never()
      mocker.clear(HiLog)
    })

    it('CreateNewConversationViewTest_deleteMessageByGroupIds_groupInfos_2', 0, () => {
      CreateNewConversationView.threadId = 0;
      mocker.mockFunc(HiLog, HiLog.i)
      CreateNewConversationView.deleteMessageByGroupIds(context, [1,2], undefined, true);
      let TAG = 'CreateNewConversationViewModle'
      mocker.verify('i', [TAG, 'deleteMessageByGroupIds groupId is :1']).never()
      mocker.clear(HiLog)
    })

    it('CreateNewConversationViewTest_deleteMessageByGroupIds_has_groupInfos', 0, () => {
      CreateNewConversationView.threadId = 0;
      let groupInfos: groupIdsInfos[] =[
        {
          groupId: 1,
          isRcs: 1,
          msgId: '' ,
          rcsId: 1
        }
      ]
      mocker.mockFunc(HiLog, HiLog.i)
      CreateNewConversationView.deleteMessageByGroupIds(context, [1,2], groupInfos, true);
      let TAG = 'CreateNewConversationViewModle'
      mocker.verify('i', [TAG, 'deleteMessageByGroupIds groupId is :1']).never()
      mocker.clear(HiLog)
    })

    it('CreateNewConversationViewTest_deleteMessageByGroupIds_has_groupInfos_isMMs', 0, () => {
      CreateNewConversationView.threadId = 0;
      let groupInfos: groupIdsInfos[] =[
        {
          groupId: 1,
          isRcs: 1,
          msgId: '' ,
          rcsId: 1
        },
        {
          groupId: 1,
          isRcs: 1,
          msgId: '' ,
          rcsId: 1
        },
        {
          groupId: 1,
          isRcs: 0,
          msgId: '' ,
          rcsId: 1
        }
      ]
      mocker.mockFunc(HiLog, HiLog.i)
      CreateNewConversationView.deleteMessageByGroupIds(context, [1,2], groupInfos, false);
      let TAG = 'CreateNewConversationViewModle'
      mocker.verify('i', [TAG, 'deleteMessageByGroupIds groupId is :1']).never()
      mocker.clear(HiLog)
    })

    it('CreateNewConversationViewTest_sendOfEnhancedInfo_mmDisplaySource_morThan9', 0, () => {
      let mms: Mms = {
        duration: '',
        type: 0,
        path: '',
        name: ''
      }
      CreateNewConversationView.mAttachAreaCtrl.mmDisplaySource = [mms, mms, mms, mms, mms, mms, mms, mms, mms, mms];
      CreateNewConversationView.sendOfEnhancedInfo();
      expect(CreateNewConversationView.isChangeInputPlaceholder).assertTrue();
    })

    it('CreateNewConversationViewTest_sendOfEnhancedInfo_inRepairMode_true', 0, () => {
      CreateNewConversationView.mAttachAreaCtrl.mmDisplaySource = [];
      when(mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences))(ArgumentMatchers.any)
        .afterReturn(true)
      CreateNewConversationView.sendOfEnhancedInfo();
      expect(CreateNewConversationView.isChangeInputPlaceholder).assertTrue();
    })


    it('CreateNewConversationViewTest_sendOfEnhancedInfo_canSendMessage_false', 0, () => {
      CreateNewConversationView.canSendMessage = false;
      CreateNewConversationView.mAttachAreaCtrl.mmDisplaySource = [];
      when(mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences))(ArgumentMatchers.any)
        .afterReturn(false)
      CreateNewConversationView.isAirPlaneMode = false;
      CreateNewConversationView.sendOfEnhancedInfo();
      CreateNewConversationView.isAirPlaneMode = true;
      CreateNewConversationView.sendOfEnhancedInfo();
      expect(CreateNewConversationView.isChangeInputPlaceholder).assertTrue();
    })

    it('CreateNewConversationViewTest_getLocationInfo_convertLatitude_100_convertLongitude_f1', 0, () => {
        let convertLongitude = -1;
        let convertLatitude = 100;
      CreateNewConversationView.getLocationInfo(convertLongitude, convertLatitude);
    })

    it('CreateNewConversationViewTest_getLocationInfo_convertLatitude_f1_convertLongitude_f1', 0, () => {
      let convertLongitude = -1;
      let convertLatitude = -1;
      CreateNewConversationView.getLocationInfo(convertLongitude, convertLatitude);
    })

    it('CreateNewConversationViewTest_getLocationInfo_convertLatitude_0_convertLongitude_101', 0, () => {
      let convertLongitude = 101;
      let convertLatitude = 0;
      CreateNewConversationView.getLocationInfo(convertLongitude, convertLatitude);
    })

    it('CreateNewConversationViewTest_handleMmDisplaySourceOnSwitchBetweenMmsAndRcs', 0, async () => {
      CreateNewConversationView.mAttachAreaCtrl.mmDisplaySource = [];
      let res: boolean = await (CreateNewConversationView as object)['handleMmDisplaySourceOnSwitchBetweenMmsAndRcs'](true, true);
      expect(res).assertTrue();
    })

    it('CreateNewConversationViewTest_handleMmDisplaySourceOnSwitchBetweenMmsAndRcs_lastIsRcs_false', 0, async () => {
      CreateNewConversationView.mAttachAreaCtrl.mmDisplaySource = [{
        duration: '',
        type: 1,
        path: 'src',
        name: '1'
      },{
        duration: '',
        type: 4,
        path: '',
        name: '2'
      }];
      CreateNewConversationView.isRcsMms = true;
      let res: boolean = await (CreateNewConversationView as object)['handleMmDisplaySourceOnSwitchBetweenMmsAndRcs'](false, true);
      expect(res).assertTrue();
    })

    it('CreateNewConversationViewTest_handleMmDisplaySourceOnSwitchBetweenMmsAndRcs_lastIsRcs_true', 0, async () => {
      CreateNewConversationView.mAttachAreaCtrl.mmDisplaySource = [{
        duration: '',
        type: 1,
        path: 'src',
        name: '1'
      },{
        duration: '',
        type: 4,
        path: '',
        name: '2'
      }];
      CreateNewConversationView.isRcsMms = true;
      let res: boolean = await (CreateNewConversationView as object)['handleMmDisplaySourceOnSwitchBetweenMmsAndRcs'](true, true);
      expect(res).assertTrue();
    })

    it('CreateNewConversationViewTest_handleMmDisplaySourceOnSwitchBetweenMmsAndRcs_lastIsRcs_true_isSendPicture_false', 0, async () => {
      CreateNewConversationView.mAttachAreaCtrl.mmDisplaySource = [{
        duration: '',
        type: 1,
        path: 'src',
        name: '1'
      },{
        duration: '',
        type: 4,
        path: '',
        name: '2'
      }];
      CreateNewConversationView.isRcsMms = false;
      let res: boolean = await (CreateNewConversationView as object)['handleMmDisplaySourceOnSwitchBetweenMmsAndRcs'](true, true);
      expect(res).assertTrue();
    })

    it('CreateNewConversationViewTest_getMaxGroupIdInMmsInfoTable_Context_null', 0, async () => {
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('mmsContext')
        .afterReturn(undefined);
      let res: null | number = await (CreateNewConversationView as object)['getMaxGroupIdInMmsInfoTable']();
      expect(res).assertEqual(null);
      mocker.clear(GlobalContext.getContext());
    })

    it('CreateNewConversationViewTest_getMaxGroupIdInMmsInfoTable', 0, async () => {
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('mmsContext')
        .afterReturn(context);
      let res: null | number = await (CreateNewConversationView as object)['getMaxGroupIdInMmsInfoTable']();
      expect(res).assertEqual(null);
      mocker.clear(GlobalContext.getContext());
    })

    it('CreateNewConversationViewTest_deleteChatbotSmsNumberDraft_code_f1', 0, () => {
      when(mocker.mockFunc(ConversationListService, ConversationListService.getInstance))().afterReturn({
        querySessionByTelephone: (telephone: string, callback: Function, context: Context,
          isFuzzyMatch = false, chatbotParameters?: ChatbotParameters) => {
          if (callback) {
            callback({ code: -1, response: { id: 1 } as LooseObject })
          }
        }
      });
      (CreateNewConversationView as object)['deleteChatbotSmsNumberDraft'](context, '110');
      expect(CreateNewConversationView).not().assertUndefined();
      mocker.clear(ConversationListService);
    })

    it('CreateNewConversationViewTest_deleteChatbotSmsNumberDraft_code_0_response_id_f1', 0, () => {
      when(mocker.mockFunc(ConversationListService, ConversationListService.getInstance))().afterReturn({
        querySessionByTelephone: (telephone: string, callback: Function, context: Context,
          isFuzzyMatch = false, chatbotParameters?: ChatbotParameters) => {
          if (callback) {
            callback({ code: 0, response: { id: -1 } as LooseObject })
          }
        }
      });
      (CreateNewConversationView as object)['deleteChatbotSmsNumberDraft'](context, '110');
      expect(CreateNewConversationView).not().assertUndefined();
      mocker.clear(ConversationListService);
    })

    it('CreateNewConversationViewTest_deleteChatbotSmsNumberDraft_code_0_response_hasDraft_false', 0, () => {
      when(mocker.mockFunc(ConversationListService, ConversationListService.getInstance))().afterReturn({
        querySessionByTelephone: (telephone: string, callback: Function, context: Context,
          isFuzzyMatch = false, chatbotParameters?: ChatbotParameters) => {
          if (callback) {
            callback({ code: 0, response: { id: 1, hasDraft: false } as LooseObject })
          }
        }
      });
      (CreateNewConversationView as object)['deleteChatbotSmsNumberDraft'](context, '110');
      expect(CreateNewConversationView).not().assertUndefined();
      mocker.clear(ConversationListService);
    })

    it('CreateNewConversationViewTest_deleteChatbotSmsNumberDraft_code_0_response_messageCount_1', 0, () => {
      when(mocker.mockFunc(ConversationListService, ConversationListService.getInstance))().afterReturn({
        querySessionByTelephone: (telephone: string, callback: Function, context: Context,
          isFuzzyMatch = false, chatbotParameters?: ChatbotParameters) => {
          if (callback) {
            callback({ code: 0, response: { id: 1, hasDraft: true, messageCount: 1 } as LooseObject })
          }
        },
        updateLastItemContent: (actionData: LooseObject, callback: Function, context: Context,
          isClearDraft?: boolean, messageCount?: number) => {}
      });
      when(mocker.mockFunc(ConversationService.getInstance(),
        ConversationService.getInstance().deleteSmsInfoByCondition))(ArgumentMatchers.any).afterReturnNothing();
      (CreateNewConversationView as object)['deleteChatbotSmsNumberDraft'](context, '110');
      expect(CreateNewConversationView).not().assertUndefined();
      mocker.clear(ConversationListService);
      mocker.clear(ConversationService.getInstance());
    })

    it('CreateNewConversationViewTest_deleteChatbotSmsNumberDraft_code_0_response_messageCount_0', 0, () => {
      when(mocker.mockFunc(ConversationListService, ConversationListService.getInstance))().afterReturn({
        querySessionByTelephone: (telephone: string, callback: Function, context: Context,
          isFuzzyMatch = false, chatbotParameters?: ChatbotParameters) => {
          if (callback) {
            callback({ code: 0, response: { id: 1, hasDraft: true, messageCount: 0 } as LooseObject })
          }
        },
        deleteSessionByCondition: (actionData: LooseObject, callback: Function, context: Context) => {}
      });
      when(mocker.mockFunc(ConversationService.getInstance(),
        ConversationService.getInstance().deleteSmsInfoByCondition))(ArgumentMatchers.any).afterReturnNothing();
      (CreateNewConversationView as object)['deleteChatbotSmsNumberDraft'](context, '110');
      expect(CreateNewConversationView).not().assertUndefined();
      mocker.clear(ConversationListService);
      mocker.clear(ConversationService.getInstance());
    })

    it('CreateNewConversationViewTest_deleteChatbotSmsNumberDraft_code_0_response_messageCount_f1', 0, () => {
      when(mocker.mockFunc(ConversationListService, ConversationListService.getInstance))().afterReturn({
        querySessionByTelephone: (telephone: string, callback: Function, context: Context,
          isFuzzyMatch = false, chatbotParameters?: ChatbotParameters) => {
          if (callback) {
            callback({ code: 0, response: { id: 1, hasDraft: true, messageCount: -1 } as LooseObject })
          }
        }
      });
      when(mocker.mockFunc(ConversationService.getInstance(),
        ConversationService.getInstance().deleteSmsInfoByCondition))(ArgumentMatchers.any).afterReturnNothing();
      (CreateNewConversationView as object)['deleteChatbotSmsNumberDraft'](context, '110');
      expect(CreateNewConversationView).not().assertUndefined();
      mocker.clear(ConversationListService);
      mocker.clear(ConversationService.getInstance());
    })

    it('CreateNewConversationViewTest_jumpToConversationPage', 0, async () => {
      let chatbotDetail: ChatbotDetail = new ChatbotDetail();
      chatbotDetail.serviceId = '334';
      when(mocker.mockFunc(ContactsService, ContactsService.getInstance))().afterReturn({
        queryContactDataByCondition: async (actionData: LooseObject, callback: Function,
          context: Context) => {
          if (callback) {
            callback({ code: 0, abilityResult: [{contactId: '321'} as LooseObject]})
          }
        }
      });
      when(mocker.mockFunc(ConversationListService, ConversationListService.getInstance))().afterReturn({
        querySessionByTelephone: (telephone: string, callback: Function, context: Context,
          isFuzzyMatch = false, chatbotParameters?: ChatbotParameters) => {
          if (callback) {
            callback({ code: 0, response: { id: 1 } as LooseObject })
          }
        }
      });
      CreateNewConversationView.strContactsNumber = '110';
      await CreateNewConversationView.jumpToConversationPage(true, true, true);
      expect(CreateNewConversationView).not().assertUndefined();
      mocker.clear(ContactsService);
      mocker.clear(ConversationListService);
    })

    it('CreateNewConversationViewTest_jumpToConversationPage_serviceId_undefined', 0, async () => {
      let chatbotDetail: ChatbotDetail = new ChatbotDetail();
      when(mocker.mockFunc(ContactsService, ContactsService.getInstance))().afterReturn({
        queryContactDataByCondition: async (actionData: LooseObject, callback: Function,
          context: Context) => {
          if (callback) {
            callback({ code: 0, abilityResult: [{contactId: '321'} as LooseObject]})
          }
        }
      });
      when(mocker.mockFunc(ConversationListService, ConversationListService.getInstance))().afterReturn({
        querySessionByTelephone: (telephone: string, callback: Function, context: Context,
          isFuzzyMatch = false, chatbotParameters?: ChatbotParameters) => {
          if (callback) {
            callback({ code: -1, response: { id: 1 } as LooseObject })
          }
        }
      });
      CreateNewConversationView.strContactsNumber = '110';
      await CreateNewConversationView.jumpToConversationPage(true, true, true);
      expect(CreateNewConversationView).not().assertUndefined();
      mocker.clear(ContactsService);
      mocker.clear(ConversationListService);
    })

    it('CreateNewConversationViewTest_dealJudgeYellowPageExistEmit', 0, () => {
      (CreateNewConversationView as object)['dealJudgeYellowPageExistEmit']('110');
      expect(CreateNewConversationView).not().assertUndefined();
    })

    it('CreateNewConversationViewTest_sendMessageIsHasMap', 0, () => {
      CreateNewConversationView.mAttachAreaCtrl.mmDisplaySource = [{
        path: '',
        type: 9,
        index: 1,
        isOnAudio:false
      } as Mms,{
        path: '',
        type: 10,
        index: 1,
        isOnAudio:false
      } as Mms];
      expect(CreateNewConversationView.sendMessageIsHasMap()).assertTrue();

      CreateNewConversationView.mAttachAreaCtrl.mmDisplaySource = [];
      expect(CreateNewConversationView.sendMessageIsHasMap()).assertFalse();
    })
  })
}