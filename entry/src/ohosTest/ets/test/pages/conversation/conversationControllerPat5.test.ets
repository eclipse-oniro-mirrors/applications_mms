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
  SendMsgIndexes,
  MmsSourceType,
  BaseItemType,
  itemType,
  ResultInfo
} from '../../../../../main/ets/pages/conversation/conversationController';
import DataShareHelper from '../../../../../main/ets/model/repository/DataShareHelper';
import { dataShare, dataSharePredicates, DataShareResultSet } from '@kit.ArkData';
import ConversationDataSource from '../../../../../main/ets/model/ConversationDataSource';
import { Mms } from '../../../../../main/ets/utils/TypesUtils';
import ConversationService from '../../../../../main/ets/service/ConversationService';
import ConversationListService from '../../../../../main/ets/service/ConversationListService';
import dateUtil, { DateUtil } from '../../../../../main/ets/utils/DateUtil';
import ConversationListController from '../../../../../main/ets/pages/conversationlist/conversationListController';
import MmsPreferences from '../../../../../main/ets/utils/MmsPreferences';
import DotUtil from '../../../../../main/ets/utils/MmsDot/DotUtils';
import LooseObject from '../../../../../main/ets/data/LooseObject';
import { window } from '@kit.ArkUI';
import TelephoneUtil from '../../../../../main/ets/utils/TelephoneUtil';
import CheckUtil from '../../../../../main/ets/utils/CheckUtil';
import { BusinessError, commonEventManager } from '@kit.BasicServicesKit';
import MySet from '../../MySet';
import simCardService from '../../../../../main/ets/service/SimCardService';
import { commonPasteboard } from '../../../../../main/ets/data/Pasteboard';
import { StartOptions } from '@kit.AbilityKit';
import { CallService } from '../../../../../main/ets/service/CallService';
import { MultiSimCardItems, SelectDialogBuilder } from '../../../../../main/ets/views/MultiSimCardCallDialog';
import { resourceManager } from '@kit.LocalizationKit';
import ContactsService from '../../../../../main/ets/service/ContactsService';
import ImageUtil from '../../../../../main/ets/utils/ImageUtil';
import MmsUtil from '../../../../../main/ets/utils/MmsUtil';
import ObjectUtil from '../../../../../main/ets/utils/ObjectUtil';
import FileUtil from '../../../../../main/ets/utils/FileUtil';
import SmilFile from '../../../../../main/ets/utils/SmilFile';
import { isSameTel } from '../../../../../main/ets/utils/TelephoneUtilEnhancde';
import { DTGlobalContext } from '../../../testability/TestAbility';

export default function conversationControllerPart5Test() {
  describe('conversationControllerTest5', () => {

    let mConversationCtrl: ConversationController;
    let mocker: MockKit;
    let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;

    beforeEach(() => {
      mocker = new MockKit();
      mConversationCtrl = ConversationController.getInstance();
    })

    afterEach(() => {
      mocker.clear(mConversationCtrl);
      AppStorage.clear();
    })

    it('ConversationControllerTest_sendInterval_recallMessageSwitch_0_isRcsMms_false_mmsListLength_1', 0, () => {
      mConversationCtrl.isRcsMms = false;
      let actionData: ActionDataType = {
        resendStateIsRcs: true,
        destinationHost: 'destinationHost'
      } as ActionDataType;
      let item: mmsListType = new mmsListType();
      item.isRcs = 1;
      item.showTitle = true;
      item.isMsm = true;
      let mmsList: Array<mmsListType> = [item];
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.handleWithSend);
      when(mocker.mockFunc(MmsUtil, MmsUtil.checkRcsTransmitToMms))(ArgumentMatchers.any)
        .afterReturn(true);

      mConversationCtrl.sendInterval(context, actionData, mmsList, () => {});

      item.isMsm = false;
      mConversationCtrl.sendInterval(context, actionData, mmsList, () => {});

      mocker.clear(MmsUtil);
      mocker.clear(mConversationCtrl);

      expect(mConversationCtrl).not().assertUndefined();
    })

    it('ConversationControllerTest_changeValue_e_empty_isEditMms_true_isNewMsg_true_receiveContactValue_empty',
      0, () => {
        mConversationCtrl.isEditMms = true;
        mConversationCtrl.isRcsMms = true;
        mConversationCtrl.isNewMsg = true;
        mConversationCtrl.isFlightMode = false;
        mConversationCtrl.receiveContactValue = '';
        mConversationCtrl.selectContacts = [{} as selectContactType];
        mConversationCtrl.selectContactsMap = new Map();

        when(mocker.mockFunc(MmsPreferences.getInstance(), MmsPreferences.getInstance().haveSimCardReady))()
          .afterReturn(true);
        mocker.mockFunc(mConversationCtrl, mConversationCtrl.setCanSendMsgStatus);

        mConversationCtrl.changeValue('');

        expect(mConversationCtrl.canSendMessage).assertFalse();

        mocker.clear(MmsPreferences.getInstance());
        mocker.clear(mConversationCtrl);
      })

    it('ConversationControllerTest_changeValue_e_empty_isEditMms_true_isNewMsg_true',
      0, () => {
        mConversationCtrl.isEditMms = true;
        mConversationCtrl.isRcsMms = true;
        mConversationCtrl.isNewMsg = true;
        mConversationCtrl.isFlightMode = false;
        mConversationCtrl.receiveContactValue = 'xx';
        mConversationCtrl.selectContacts = [{} as selectContactType];
        mConversationCtrl.selectContactsMap.set(mConversationCtrl.threadId, [{
          telephone: '670988763'
        } as selectContactType]);

        when(mocker.mockFunc(MmsPreferences.getInstance(), MmsPreferences.getInstance().haveSimCardReady))()
          .afterReturn(true);
        mocker.mockFunc(mConversationCtrl, mConversationCtrl.setCanSendMsgStatus);

        mConversationCtrl.changeValue('');

        expect(mConversationCtrl.canSendMessage).assertTrue();

        mocker.clear(MmsPreferences.getInstance());
        mocker.clear(mConversationCtrl);
      })

    it('ConversationControllerTest_changeValue_e_empty_isEditMms_false', 0, () => {
      mConversationCtrl.isEditMms = false;
      mConversationCtrl.selectContactsMap = new Map();
      mConversationCtrl.changeValue('');
      expect(mConversationCtrl.canSendMessage).assertFalse();
    })

    it('ConversationControllerTest_changeValue_e_notEmpty_isNewMsg_true_receiveContactValue_empty_selectContacts_empty',
      0, () => {
        mConversationCtrl.isNewMsg = true;
        mConversationCtrl.receiveContactValue = '';
        mConversationCtrl.selectContacts = [];
        mConversationCtrl.changeValue('xxxx');
        expect(mConversationCtrl.canSendMessage).assertFalse();
      })

    it('ConversationControllerTest_changeValue_isNewMsg_false_receiveContactValue_empty',
      0, () => {
        mConversationCtrl.isNewMsg = false;
        mConversationCtrl.receiveContactValue = '';
        mConversationCtrl.selectContacts = [{} as selectContactType];

        when(mocker.mockFunc(MmsPreferences.getInstance(), MmsPreferences.getInstance().haveSimCardReady))()
          .afterReturn(true);
        mocker.mockFunc(mConversationCtrl, mConversationCtrl.setCanSendMsgStatus);

        mConversationCtrl.changeValue('');

        expect(mConversationCtrl.canSendMessage).assertFalse();

        mocker.clear(MmsPreferences.getInstance());
        mocker.clear(mConversationCtrl);
      })

    it('ConversationControllerTest_changeValue_isNewMsg_true', 0, () => {
      mConversationCtrl.isNewMsg = true;
      mConversationCtrl.receiveContactValue = 'xxx';
      mConversationCtrl.selectContacts = [{} as selectContactType];

      when(mocker.mockFunc(MmsPreferences.getInstance(), MmsPreferences.getInstance().haveSimCardReady))()
        .afterReturn(true);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.setCanSendMsgStatus);

      mConversationCtrl.changeValue('');

      expect(mConversationCtrl.canSendMessage).assertFalse();

      mocker.clear(MmsPreferences.getInstance());
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_setTabTitleText_tabIndex_2', 0, () => {
      mConversationCtrl.tabIndex = 2;
      mConversationCtrl.tabTextList =
        [$r('app.string.converting_sms'), $r('app.string.msg_unselected_tip'), $r('app.string.sms')];

      mConversationCtrl.setTabTitleText();

      expect(JSON.stringify(mConversationCtrl.tabTitleText))
        .assertEqual(JSON.stringify(mConversationCtrl.tabTextList[2]));
    })

    it('ConversationControllerTest_setTabTitleText_tabIndex_1_checkedValue_true', 0, () => {
      mConversationCtrl.tabIndex = 1;
      mConversationCtrl.tabTextList =
        [$r('app.string.msg_unselected_tip'), $r('app.string.msg_unselected_tip'), $r('app.string.msg_unselected_tip')];
      mConversationCtrl.pictureListFromGallery = [{
        checkedValue: true, path: ''
      }];

      mConversationCtrl.setTabTitleText();

      expect(JSON.stringify(mConversationCtrl.tabTitleText))
        .assertEqual(JSON.stringify($r('app.plural.msg_selected_tip_new', 1, {
          number: '1'
        })));
    })

    it('ConversationControllerTest_setTabTitleText_tabIndex_1_checkedValue_false', 0, () => {
      mConversationCtrl.tabIndex = 1;
      mConversationCtrl.tabTextList =
        [$r('app.string.msg_unselected_tip'), $r('app.string.msg_unselected_tip'), $r('app.string.msg_unselected_tip')];
      mConversationCtrl.pictureListFromGallery = [{
        checkedValue: true, path: ''
      }];

      mConversationCtrl.setTabTitleText();

      expect(JSON.stringify(mConversationCtrl.tabTitleText?.params)).assertEqual('[1,{"number":"1"}]');
    })

    it('ConversationControllerTest_judgeSendBtnCanClicked_isNewMsg_true_receiveContactValue_notEmpty_haveSimCardReady_true',
      0, () => {
        mConversationCtrl.isNewMsg = true;
        mConversationCtrl.receiveContactValue = '570977632';
        when(mocker.mockFunc(TelephoneUtil, TelephoneUtil.isPhoneNumber))()
          .afterReturn(true);

        when(mocker.mockFunc(MmsPreferences.getInstance(), MmsPreferences.getInstance().haveSimCardReady))()
          .afterReturn(true);

        mConversationCtrl.judgeSendBtnCanClicked();

        expect(mConversationCtrl.canSendMessage).assertFalse();

        mocker.clear(TelephoneUtil);
        mocker.clear(MmsPreferences.getInstance());
      })

    it('ConversationControllerTest_judgeSendBtnCanClicked_isNewMsg_true', 0, () => {
      mConversationCtrl.isNewMsg = true;
      mConversationCtrl.receiveContactValue = '570977632';
      when(mocker.mockFunc(TelephoneUtil, TelephoneUtil.isPhoneNumber))()
        .afterReturn(false);

      when(mocker.mockFunc(MmsPreferences.getInstance(), MmsPreferences.getInstance().haveSimCardReady))()
        .afterReturn(false);
      mConversationCtrl.mmsEditList = [{} as MmsSourceType];
      mConversationCtrl.selectContacts = [{} as selectContactType];

      mConversationCtrl.judgeSendBtnCanClicked();

      expect(mConversationCtrl.canSendMessage).assertFalse();

      mocker.clear(TelephoneUtil);
      mocker.clear(MmsPreferences.getInstance());
    })

    it('ConversationControllerTest_judgeSendBtnCanClicked_isNewMsg_false_textValue_notEmpty', 0, () => {
      mConversationCtrl.isNewMsg = false;
      mConversationCtrl.receiveContactValue = '570977632';

      when(mocker.mockFunc(MmsPreferences.getInstance(), MmsPreferences.getInstance().haveSimCardReady))()
        .afterReturn(false);
      mConversationCtrl.mmsEditList = [{} as MmsSourceType];
      mConversationCtrl.selectContacts = [{} as selectContactType];
      mConversationCtrl.textValue = 'xxx';

      mConversationCtrl.judgeSendBtnCanClicked();

      expect(mConversationCtrl.canSendMessage).assertTrue();

      mocker.clear(MmsPreferences.getInstance());
    })

    it('ConversationControllerTest_judgeSendBtnCanClicked_isNewMsg_false_textValue_notEmpty_mmsEditList_empty', 0,
      () => {
        mConversationCtrl.isNewMsg = false;
        mConversationCtrl.receiveContactValue = '570977632';

        when(mocker.mockFunc(MmsPreferences.getInstance(), MmsPreferences.getInstance().haveSimCardReady))()
          .afterReturn(false);
        mConversationCtrl.mmsEditList = [];
        mConversationCtrl.selectContacts = [];
        mConversationCtrl.textValue = 'xxx';

        mConversationCtrl.judgeSendBtnCanClicked();

        expect(mConversationCtrl.canSendMessage).assertTrue();

        mocker.clear(MmsPreferences.getInstance());
      })

    it('ConversationControllerTest_judgeSendBtnCanClicked_isNewMsg_false_mmsEditList_notEmpty', 0, () => {
      mConversationCtrl.isNewMsg = false;
      mConversationCtrl.receiveContactValue = '570977632';
      mConversationCtrl.textareaDatasource = [{} as LooseObject];

      when(mocker.mockFunc(MmsPreferences.getInstance(), MmsPreferences.getInstance().haveSimCardReady))()
        .afterReturn(false);
      mConversationCtrl.mmsEditList = [{} as MmsSourceType];
      mConversationCtrl.selectContacts = [];
      mConversationCtrl.textValue = '';

      mConversationCtrl.judgeSendBtnCanClicked();

      expect(mConversationCtrl.canSendMessage).assertTrue();

      mocker.clear(MmsPreferences.getInstance());
    })

    it('ConversationControllerTest_judgeSendBtnCanClicked_isNewMsg_false_textareaDatasource_empty', 0, () => {
      mConversationCtrl.isNewMsg = false;
      mConversationCtrl.receiveContactValue = '570977632';
      mConversationCtrl.textareaDatasource = [];

      when(mocker.mockFunc(MmsPreferences.getInstance(), MmsPreferences.getInstance().haveSimCardReady))()
        .afterReturn(false);
      mConversationCtrl.mmsEditList = [];
      mConversationCtrl.selectContacts = [{} as selectContactType];
      mConversationCtrl.textValue = '';

      mConversationCtrl.judgeSendBtnCanClicked();

      expect(mConversationCtrl.canSendMessage).assertTrue();

      mocker.clear(MmsPreferences.getInstance());
    })

    it('ConversationControllerTest_subscriberCallBack_hasBarProperty_false', 0, () => {
      when(mocker.mockFunc(CheckUtil, CheckUtil.hasBarProperty))(ArgumentMatchers.any)
        .afterReturn(false);
      mConversationCtrl.subscriberCallBack(context, {} as BusinessError, {} as commonEventManager.CommonEventData,
        false);
      expect(mConversationCtrl.canSendMessage).assertTrue();
      mocker.clear(CheckUtil);
    })

    it('ConversationControllerTest_subscriberCallBack_hasBarProperty_true', 0, () => {
      when(mocker.mockFunc(CheckUtil, CheckUtil.hasBarProperty))(ArgumentMatchers.any)
        .afterReturn(true);
      let mmsList: mmsListType = new mmsListType();
      mmsList.id = '1';
      mmsList.rcsId = 1;
      mmsList.isCbChecked = true;
      let mmsList1: mmsListType = new mmsListType();
      mmsList1.id = '2';
      mmsList1.rcsId = 1;
      mmsList1.isCbChecked = false;
      mConversationCtrl.mmsList = [mmsList, mmsList1];
      mConversationCtrl.subscriberCallBack(context, {} as BusinessError, {} as commonEventManager.CommonEventData,
        false);
      expect(mConversationCtrl.canSendMessage).assertTrue();
      mocker.clear(CheckUtil);
    })

    it('ConversationControllerTest_unSubscribeDetail', 0, () => {
      mConversationCtrl.unSubscribeDetail();
      expect(mConversationCtrl.commonEventData).assertUndefined();
    })

    it('ConversationControllerTest_jumpToIndex_searchContent_notEmpty', 0, async () => {
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
        'msgId': '1',
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

      mConversationCtrl.searchContent = 'xx';

      let mmsList: mmsListType = new mmsListType();
      mmsList.id = '1';
      mmsList.rcsId = 1;
      let mmsList1: mmsListType = new mmsListType();
      mmsList1.id = '2';
      mmsList1.rcsId = 1;
      mConversationCtrl.mmsList = [mmsList, mmsList1];

      mocker.mockFunc(mConversationCtrl.scroller, mConversationCtrl.scroller.scrollToIndex);

      let myset: DataShareResultSet = new MySet();
      myset.rowCount = 1;
      when(mocker.mockFunc(DataShareHelper.getInstance(),
        DataShareHelper.getInstance().initSmsDB))(ArgumentMatchers.any)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve(myset))
        } as dataShare.DataShareHelper)));

      await mConversationCtrl.jumpToIndex(context);

      mocker.verify('scrollToIndex', [1]).never();

      mocker.clear(DataShareHelper.getInstance());
      mocker.clear(mConversationCtrl.scroller);
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_jumpToIndex_searchContent_empty', 0, async () => {
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
        'msgId': 1,
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

      mConversationCtrl.searchContent = '';

      let mmsList: mmsListType = new mmsListType();
      mmsList.id = '1';
      mmsList.rcsId = 1;
      let mmsList1: mmsListType = new mmsListType();
      mmsList1.id = '2';
      mmsList1.rcsId = 1;
      mConversationCtrl.mmsList = [mmsList, mmsList1];

      mocker.mockFunc(mConversationCtrl.scroller, mConversationCtrl.scroller.scrollEdge);

      let myset: DataShareResultSet = new MySet();
      myset.rowCount = 1;
      when(mocker.mockFunc(DataShareHelper.getInstance(),
        DataShareHelper.getInstance().initSmsDB))(ArgumentMatchers.any)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve(myset))
        } as dataShare.DataShareHelper)));

      await mConversationCtrl.jumpToIndex(context);

      mocker.verify('scrollEdge', [Edge.End]).never();

      mocker.clear(DataShareHelper.getInstance());
      mocker.clear(mConversationCtrl.scroller);
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_scrollToEnd', 0, () => {
      mConversationCtrl.searchContent = '';
      mocker.mockFunc(mConversationCtrl.scroller, mConversationCtrl.scroller.scrollEdge);
      mConversationCtrl.scrollToEnd();
      mocker.verify('scrollEdge', [Edge.End]).never();
      mocker.clear(mConversationCtrl.scroller);
    })

    it('ConversationControllerTest_scrollToEnd_searchContent_notEmpty', 0, () => {
      mConversationCtrl.searchContent = 'xx';
      mocker.mockFunc(mConversationCtrl.scroller, mConversationCtrl.scroller.scrollEdge);
      mConversationCtrl.scrollToEnd();
      mocker.verify('scrollEdge', [Edge.End]).never();
      mocker.clear(mConversationCtrl.scroller);
    })

    it('ConversationControllerTest_moreSelected_case_0', 0, () => {
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.copyText);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.exitMultiselect);

      mConversationCtrl.moreSelected(context, '0');

      mocker.verify('copyText', []).once();
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_moreSelected_case_1', 0, () => {
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.share);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.exitMultiselect);

      mConversationCtrl.moreSelected(context, 1);

      mocker.verify('share', []).never();
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_moreSelected_case_2', 0, () => {
      mConversationCtrl.mmsIndex = 0;
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.gotoTextSelect);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.exitMultiselect);

      mConversationCtrl.moreSelected(context, 2);

      mocker.verify('gotoTextSelect', [0]).once();
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_moreSelected_case_3', 0, () => {
      mConversationCtrl.mmsIndex = 0;
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.gotoTextSelect);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.exitMultiselect);

      mConversationCtrl.moreSelected(context, 3);

      mocker.verify('gotoTextSelect', [0]).never();
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_moreSelected_case_4', 0, () => {
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.showDetails);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.exitMultiselect);

      mConversationCtrl.moreSelected(context, 4);

      mocker.verify('showDetails', []).once();
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_moreSelected_case_5', 0, () => {
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.showDetails);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.exitMultiselect);

      mConversationCtrl.moreSelected(context, 5);

      mocker.verify('gotoTextSelect', []).never();
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_moreSelected_case_6', 0, () => {
      mConversationCtrl.mmsIndex = 0;
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.showReport);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.exitMultiselect);

      mConversationCtrl.moreSelected(context, 6);

      mocker.verify('showReport', [0]).once();
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_moreSelected_case_7', 0, () => {
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.saveImage);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.exitMultiselect);

      mConversationCtrl.moreSelected(context, 7);

      mocker.verify('saveImage', []).never();
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_moreSelected_case_8', 0, () => {
      mConversationCtrl.mmsIndex = 0;
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.showVcarDetail);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.exitMultiselect);

      mConversationCtrl.moreSelected(context, 8);

      mocker.verify('showVcarDetail', [0]).once();
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_moreSelected_case_default', 0, () => {
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.exitMultiselect);

      mConversationCtrl.moreSelected(context, 10);

      mocker.verify('exitMultiselect', []).once();
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_copyText', 0, () => {
      let item: mmsListType = new mmsListType();
      item.isRcs = 1;
      item.content = '';
      mConversationCtrl.mmsList = [item];
      mConversationCtrl.mmsIndex = 0;
      mocker.mockFunc(commonPasteboard, commonPasteboard.setPasteboard);

      mConversationCtrl.copyText();

      mocker.clear(commonPasteboard);
    })

    it('ConversationControllerTest_copyMultipeText', 0, () => {
      let item: mmsListType = new mmsListType();
      item.isCbChecked = true;
      item.content = '';
      let item1: mmsListType = new mmsListType();
      item1.isCbChecked = false;
      item1.content = '';
      mConversationCtrl.mmsList = [item, item1];

      mocker.mockFunc(commonPasteboard, commonPasteboard.setPasteboard);

      mConversationCtrl.copyMultipeText();

      let pasteData: LooseObject = [''];
      let copyText: string = '';
      copyText = pasteData.join('\n');

      mocker.clear(commonPasteboard);
    })

    it('ConversationControllerTest_share', 0, () => {
      let item: mmsListType = new mmsListType();
      item.isCbChecked = true;
      item.content = '';
      let item1: mmsListType = new mmsListType();
      item1.isCbChecked = false;
      item1.content = '';
      mConversationCtrl.mmsList = [item, item1];
      let res = false;

      when(mocker.mockFunc(ConversationService.getInstance(),
        ConversationService.getInstance().gotoShare))(ArgumentMatchers.any)
        .afterAction(() => {
          res = true;
        });

      mConversationCtrl.share(context);

      expect(res).assertTrue();

      mocker.clear(ConversationService.getInstance());
    })

    it('ConversationControllerTest_gotoTextSelect', 0, () => {
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.pushToCopyController);

      mConversationCtrl.gotoTextSelect(1);

      mocker.verify('pushToCopyController', [1]).never();
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_showDetails', 0, () => {
      let item1: mmsListType = new mmsListType();
      item1.isCbChecked = true;
      item1.timeMillisecond = 0;
      item1.time = '';
      item1.msgType = 0;
      item1.isReceive = true;
      let item2: mmsListType = new mmsListType();
      item2.isCbChecked = true;
      item2.timeMillisecond = 0;
      item2.time = '';
      item2.msgType = 1;
      item2.isReceive = false;
      let item3: mmsListType = new mmsListType();
      item3.isCbChecked = false;
      mConversationCtrl.mmsList = [item1, item2, item3];

      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.getTime))(ArgumentMatchers.any)
        .afterReturn(0);
      mConversationCtrl.showDetails();
      expect(mConversationCtrl.isSendRecipient).assertFalse();
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_showReport', 0, () => {
      mConversationCtrl.strContactsNumber = '7777777';
      let item1: mmsListType = new mmsListType();
      item1.isMsm = true;
      item1.timeMillisecond = '';
      item1.sendStatus = 0;
      mConversationCtrl.mmsList = [item1];

      mConversationCtrl.showReport(0);
      expect(mConversationCtrl.pageInfos.getAllPathName()[0]).assertEqual('');
    })

    it('ConversationControllerTest_saveImage', 0, () => {
      mConversationCtrl.mmsIndex = 0;
      let item1: mmsListType = new mmsListType();
      item1.threadId = 0;
      item1.pduId = 0;
      mConversationCtrl.mmsList = [item1];
      mocker.mockFunc(ConversationService.getInstance(), ConversationService.getInstance().saveImage);
      mConversationCtrl.saveImage(context);
      expect(mConversationCtrl.isSendRecipient).assertFalse();
      mocker.clear(ConversationService.getInstance());
    })

    it('ConversationControllerTest_showVcarDetail', 0, () => {
      mConversationCtrl.showVcarDetail(0);
      expect(mConversationCtrl.isSendRecipient).assertFalse();
    })

    it('ConversationControllerTest_exitMultiselect', 0, () => {
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.setSelectStatus);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.cancelCheckedAll);
      mConversationCtrl.exitMultiselect();
      mocker.verify('cancelCheckedAll', []).once();
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_longPressMore_case0', 0, () => {
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.deleteDetail);
      mConversationCtrl.longPressMore(context, 0);
      mocker.verify('deleteDetail', []).once();
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_longPressMore_case1', 0, () => {
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.createNewContact);
      mConversationCtrl.longPressMore(context, 1);
      mocker.verify('createNewContact', [context, mConversationCtrl.strContactsNumber]).once();
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_longPressMore_case2', 0, () => {
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.existingContact);
      mConversationCtrl.longPressMore(context, 2);
      mocker.verify('existingContact', [context, mConversationCtrl.strContactsNumber]).once();
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_longPressMore_case3', 0, () => {
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.callEditor);
      mConversationCtrl.longPressMore(context, 3);
      mocker.verify('callEditor', [context, mConversationCtrl.strContactsNumber]).once();
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_longPressMore_case4', 0, () => {
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.callEditor);
      mConversationCtrl.longPressMore(context, 4);
      mocker.verify('callEditor', [context, mConversationCtrl.strContactsNumber]).once();
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_longPressMore_case5', 0, () => {
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.titleBarAvatar);
      mConversationCtrl.longPressMore(context, 5);
      mocker.verify('titleBarAvatar', [context]).once();
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_longPressMore_caseDefault', 0, () => {
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.titleBarAvatar);
      mConversationCtrl.longPressMore(context, 6);
      mocker.verify('titleBarAvatar', [context]).never();
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_deleteDetail_length_1', 0, () => {
      mConversationCtrl.mmsIndex = 0;
      let item1: mmsListType = new mmsListType();
      item1.threadId = 0;
      item1.pduId = 0;
      mConversationCtrl.mmsList = [item1];
      mConversationCtrl.deleteDetail();
      expect(JSON.stringify(mConversationCtrl.strMsgDeleteDialogTip))
        .assertEqual(JSON.stringify($r('app.string.msg_delete_dialog_con_tip3')));
    })

    it('ConversationControllerTest_deleteDetail_length_0', 0, () => {
      mConversationCtrl.mmsList = [];
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.setSelectStatus);
      mConversationCtrl.deleteDetail();
      expect(mConversationCtrl.hasDetailDelete).assertFalse();
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_createNewContact', 0, () => {
      mConversationCtrl.mmsList = [];
      let res = false;
      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.jumpToContact))(ArgumentMatchers.any)
        .afterAction(() => {
          res = true;
        });
      mConversationCtrl.createNewContact(context, '0');
      expect(res).assertTrue();
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_callEditor', 0, () => {
      mConversationCtrl.mmsList = [];
      let res = false;
      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.jumpToContact))(ArgumentMatchers.any)
        .afterAction(() => {
          res = true;
        });
      mConversationCtrl.callEditor(context, '0');
      expect(res).assertTrue();
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_existingContact', 0, () => {
      mConversationCtrl.mmsList = [];
      let res = false;
      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.jumpToContact))(ArgumentMatchers.any)
        .afterAction(() => {
          res = true;
        });
      mConversationCtrl.existingContact(context, '0');
      expect(res).assertTrue();
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_jumpToContact', 0, () => {
      mConversationCtrl.mmsList = [];
      let res = false;
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('mmsContext')
        .afterReturn({
          startAbility: (want: Want, options?: StartOptions | undefined): Promise<void> => {
            res = true;
            return new Promise<void>(resolve => resolve())
          }
        } as Object | window.WindowStage);
      mConversationCtrl.jumpToContact(context, {
        pageFlag: true
      } as LooseObject);
      expect(res).assertFalse();
      mocker.clear(GlobalContext.getContext());
    })

    it('ConversationControllerTest_jumpToContact_catch', 0, () => {
      mConversationCtrl.mmsList = [];
      let res = false;
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('mmsContext')
        .afterReturn({
          startAbility: (want: Want, options?: StartOptions | undefined): Promise<void> => {
            res = true;
            return new Promise<void>((resolve: () => void, reject: (res: BusinessError) => void) => reject({
              message: 'error'
            } as BusinessError))
          }
        } as Object | window.WindowStage);
      mConversationCtrl.jumpToContact(context, {
        pageFlag: true
      } as LooseObject);
      expect(res).assertFalse();
      mocker.clear(GlobalContext.getContext());
    })

    it('ConversationControllerTest_jumpToContact_pageFlag_null', 0, () => {
      mConversationCtrl.mmsList = [];
      let res = false;
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('mmsContext')
        .afterReturn({
          startAbility: (want: Want, options?: StartOptions | undefined): Promise<void> => {
            res = true;
            return new Promise<void>((resolve: () => void, reject: (res: BusinessError) => void) => reject({
              message: 'error'
            } as BusinessError))
          }
        } as Object | window.WindowStage);
      mConversationCtrl.jumpToContact(context, {
        pageFlag: null
      } as LooseObject);
      expect(res).assertFalse();
      mocker.clear(GlobalContext.getContext());
    })

    it('ConversationControllerTest_titleBarAvatar', 0, () => {
      let res = false;
      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.jumpToContact))(ArgumentMatchers.any)
        .afterAction(() => {
          res = true;
        });
      mConversationCtrl.titleBarAvatar(context);
      expect(res).assertTrue();
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_clickCall_haveSimCardReady_false', 0, () => {
      when(mocker.mockFunc(MmsPreferences.getInstance(), MmsPreferences.getInstance().haveSimCardReady))()
        .afterReturn(false);
      let callService: CallService = new CallService(mConversationCtrl.strContactsNumber);
      let res = false;
      when(mocker.mockFunc(CallService, CallService.fromString))(ArgumentMatchers.any)
        .afterAction(() => {
          res = true;
          return callService;
        });
      mocker.mockFunc(callService, callService.call);
      mConversationCtrl.clickCall(context);

      expect(res).assertTrue();

      mocker.clear(callService);
      mocker.clear(CallService);
      mocker.clear(MmsPreferences.getInstance());
    })

    it('ConversationControllerTest_clickCall_isAllCardActive_true', 0, () => {
      let context = {
        resourceManager: {
          getStringSync: (resource: Resource, ...args: (string | number)[]): string => ''
        } as resourceManager.ResourceManager
      } as Context;
      let builder: SelectDialogBuilder = {
        title: '',
        multiSimCardItems: [{
          name: '',
          phone: ''
        } as MultiSimCardItems, {
          name: '',
          phone: ''
        } as MultiSimCardItems],
        callback: () => {
        },
        controller: {
          close: () => {
          },
          open: () => {
          }
        },
        lastSimId: -1
      } as SelectDialogBuilder;
      mConversationCtrl.strContactsNumber = '570977632';
      when(mocker.mockFunc(MmsPreferences.getInstance(), MmsPreferences.getInstance().haveSimCardReady))()
        .afterReturn(true);
      mConversationCtrl.isAllCardActive = true;
      let getObject: Function = mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject);
      when(getObject)(ArgumentMatchers.any).afterReturn({
        resourceManager: {
          getStringSync: (resource: Resource, ...args: (string | number)[]): string => ''
        } as resourceManager.ResourceManager
      } as Object | window.WindowStage);

      when(mocker.mockFunc(MmsPreferences.getInstance(), MmsPreferences.getInstance().getDispalyNameOfSim1))()
        .afterReturn('name');
      when(mocker.mockFunc(MmsPreferences.getInstance(), MmsPreferences.getInstance().getDispalyNameOfSim2))()
        .afterReturn('name');
      when(mocker.mockFunc(MmsPreferences.getInstance(), MmsPreferences.getInstance().getTelephoneNumberOfSim1))()
        .afterReturn('570988765');
      when(mocker.mockFunc(MmsPreferences.getInstance(), MmsPreferences.getInstance().getTelephoneNumberOfSim2))()
        .afterReturn('6709775544');
      let callService: CallService = new CallService(mConversationCtrl.strContactsNumber);
      when(mocker.mockFunc(CallService, CallService.fromString))(ArgumentMatchers.any)
        .afterReturn(callService);
      mocker.mockFunc(callService, callService.dial);
      when(mocker.mockFunc(ContactsService.getInstance(),
        ContactsService.getInstance().queryCallLogByCondition))(ArgumentMatchers.any)
        .afterReturn(new Promise<void>((resolve: () => void, reject: (res: BusinessError) => void) => resolve()));

      mConversationCtrl.clickCall(context, builder);

      expect(builder.title).assertEqual('');

      mocker.clear(callService);
      mocker.clear(CallService);
      mocker.clear(GlobalContext.getContext());
      mocker.clear(MmsPreferences.getInstance());
      mocker.clear(ContactsService.getInstance());
    })

    it('ConversationControllerTest_clickCall_catch', 0, () => {
      let context = {
        resourceManager: {
          getStringSync: (resource: Resource, ...args: (string | number)[]): string => ''
        } as resourceManager.ResourceManager
      } as Context;
      let builder: SelectDialogBuilder = {
        title: '',
        multiSimCardItems: [{
          name: '',
          phone: ''
        } as MultiSimCardItems, {
          name: '',
          phone: ''
        } as MultiSimCardItems],
        callback: () => {
        },
        controller: {
          close: () => {
          },
          open: () => {
          }
        },
        lastSimId: -1
      } as SelectDialogBuilder;
      mConversationCtrl.strContactsNumber = '570977632';
      when(mocker.mockFunc(MmsPreferences.getInstance(), MmsPreferences.getInstance().haveSimCardReady))()
        .afterReturn(true);
      mConversationCtrl.isAllCardActive = true;
      let getObject: Function = mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject);
      when(getObject)(ArgumentMatchers.any).afterReturn({
        resourceManager: {
          getStringSync: (resource: Resource, ...args: (string | number)[]): string => ''
        } as resourceManager.ResourceManager
      } as Object | window.WindowStage);

      when(mocker.mockFunc(MmsPreferences.getInstance(), MmsPreferences.getInstance().getDispalyNameOfSim1))()
        .afterReturn('name');
      when(mocker.mockFunc(MmsPreferences.getInstance(), MmsPreferences.getInstance().getDispalyNameOfSim2))()
        .afterReturn('name');
      when(mocker.mockFunc(MmsPreferences.getInstance(), MmsPreferences.getInstance().getTelephoneNumberOfSim1))()
        .afterReturn('570988765');
      when(mocker.mockFunc(MmsPreferences.getInstance(), MmsPreferences.getInstance().getTelephoneNumberOfSim2))()
        .afterReturn('6709775544');
      let callService: CallService = new CallService(mConversationCtrl.strContactsNumber);
      when(mocker.mockFunc(CallService, CallService.fromString))(ArgumentMatchers.any)
        .afterReturn(callService);
      mocker.mockFunc(callService, callService.dial);

      when(mocker.mockFunc(ContactsService.getInstance(),
        ContactsService.getInstance().queryCallLogByCondition))(ArgumentMatchers.any)
        .afterReturn(new Promise<void>((resolve: () => void, reject: (res: BusinessError) => void) => reject({
        } as BusinessError)));

      mConversationCtrl.clickCall(context, builder);

      expect(builder.lastSimId).assertEqual(-1);

      mocker.clear(callService);
      mocker.clear(CallService);
      mocker.clear(GlobalContext.getContext());
      mocker.clear(ContactsService.getInstance());
      mocker.clear(MmsPreferences.getInstance());
    })

    it('ConversationControllerTest_clickCall_isAllCardActive_false', 0, () => {
      let builder: SelectDialogBuilder = {
        title: '',
        multiSimCardItems: [],
        callback: () => {
        },
        controller: {
          close: () => {
          },
          open: () => {
          }
        },
        lastSimId: -1
      } as SelectDialogBuilder;
      mConversationCtrl.strContactsNumber = '570977632';
      mConversationCtrl.isAllCardActive = false;
      when(mocker.mockFunc(MmsPreferences.getInstance(), MmsPreferences.getInstance().haveSimCardReady))()
        .afterReturn(true);

      let callService: CallService = new CallService(mConversationCtrl.strContactsNumber);
      when(mocker.mockFunc(CallService, CallService.fromString))(ArgumentMatchers.any)
        .afterReturn(callService);
      mocker.mockFunc(callService, callService.call);

      mConversationCtrl.clickCall(context, builder);

      expect(builder.lastSimId).assertEqual(-1);

      mocker.clear(callService);
      mocker.clear(CallService);
      mocker.clear(MmsPreferences.getInstance());
    })

    it('ConversationControllerTest_getTime', 0, () => {
      let nS: string = '1722507324';
      let date = new Date(Number.parseInt(nS));
      let year = date.getFullYear();
      expect(mConversationCtrl.getTime(nS)).assertEqual(year);
    })

    it('ConversationControllerTest_setReceiveContactValue_length_0', 0, () => {
      let receiverData: BaseItemType = {
        contactValue: 'xx1',
        selectContacts: [],
        hasBlur: true
      };
      mConversationCtrl.strContactsName = 'xx2';

      mocker.mockFunc(mConversationCtrl, mConversationCtrl.setCanSendMessage);

      mConversationCtrl.setReceiveContactValue(context, receiverData);

      expect(mConversationCtrl.selectContacts.length).assertEqual(1);
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_setReceiveContactValue_length_2', 0, () => {
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
      mConversationCtrl.strContactsName = 'xx2';

      mocker.mockFunc(mConversationCtrl, mConversationCtrl.setCanSendMessage);
      let isPhoneNumber: Function = mocker.mockFunc(TelephoneUtil, TelephoneUtil.isPhoneNumber);
      when(isPhoneNumber)('570977632').afterReturn(true);
      when(isPhoneNumber)('570977633').afterReturn(false);

      mConversationCtrl.setReceiveContactValue(context, receiverData);

      expect(mConversationCtrl.selectContacts.length).assertEqual(1);
      mocker.clear(mConversationCtrl);
      mocker.clear(TelephoneUtil);
    })

    it('ConversationControllerTest_setCanSendMessage_length_0', 0, () => {
      mConversationCtrl.textValue = 'xx';
      mConversationCtrl.isEditMms = false;
      mConversationCtrl.canSendMessage = true;
      mConversationCtrl.setCanSendMessage([], '');
      expect(mConversationCtrl.canSendMessage).assertFalse();
    })

    it('ConversationControllerTest_setCanSendMessage_receiveContactValue_notEmpty', 0, () => {
      let receiveContactValue: string = 'xx';
      mConversationCtrl.textValue = 'xx';
      mConversationCtrl.isEditMms = false;
      mConversationCtrl.canSendMessage = true;
      mConversationCtrl.setCanSendMessage([], receiveContactValue);
      expect(mConversationCtrl.canSendMessage).assertTrue();
    })

    it('ConversationControllerTest_setCanSendMessage_canSendMessage_false', 0, () => {
      let receiveContactValue: string = 'xx';
      mConversationCtrl.textValue = 'xx';
      mConversationCtrl.isEditMms = false;
      mConversationCtrl.canSendMessage = false;
      when(mocker.mockFunc(MmsPreferences.getInstance(),MmsPreferences.getInstance().haveSimCardReady))()
        .afterReturn(true);
      mConversationCtrl.setCanSendMessage([], receiveContactValue);
      expect(mConversationCtrl.canSendMessage).assertTrue();
      mocker.clear(MmsPreferences.getInstance());
    })

    it('ConversationControllerTest_setCanSendMessage_isEditMms_true', 0, () => {
      let receiveContactValue: string = 'xx';
      mConversationCtrl.textValue = '';
      mConversationCtrl.isEditMms = true;
      mConversationCtrl.canSendMessage = false;
      when(mocker.mockFunc(MmsPreferences.getInstance(),MmsPreferences.getInstance().haveSimCardReady))()
        .afterReturn(false);
      mConversationCtrl.setCanSendMessage([], receiveContactValue);
      expect(mConversationCtrl.canSendMessage).assertFalse();
      mocker.clear(MmsPreferences.getInstance());
    })

    it('ConversationControllerTest_setCanSendMessage_length_1', 0, () => {
      let selectContacts: itemType[] = [{} as itemType];
      let receiveContactValue: string = 'xx';
      mConversationCtrl.textValue = '';
      mConversationCtrl.isEditMms = false;
      mConversationCtrl.canSendMessage = false;
      mConversationCtrl.setCanSendMessage(selectContacts, receiveContactValue);
      expect(mConversationCtrl.canSendMessage).assertFalse();
    })

    it('ConversationControllerTest_setCanSendMessage_haveSimCardReady_true', 0, () => {
      let selectContacts: itemType[] = [];
      let receiveContactValue: string = 'xx';
      mConversationCtrl.textValue = '';
      mConversationCtrl.isEditMms = false;
      mConversationCtrl.canSendMessage = false;
      when(mocker.mockFunc(MmsPreferences.getInstance(), MmsPreferences.getInstance().haveSimCardReady))()
        .afterReturn(true);
      mConversationCtrl.setCanSendMessage(selectContacts, receiveContactValue);
      expect(mConversationCtrl.canSendMessage).assertFalse();
      mocker.clear(MmsPreferences.getInstance());
    })

    it('ConversationControllerTest_setCanSendMessage', 0, () => {
      let selectContacts: itemType[] = [];
      let receiveContactValue: string = 'xx';
      mConversationCtrl.textValue = 'xx';
      mConversationCtrl.isEditMms = false;
      when(mocker.mockFunc(MmsPreferences.getInstance(), MmsPreferences.getInstance().haveSimCardReady))()
        .afterReturn(false);
      mConversationCtrl.setCanSendMessage(selectContacts, receiveContactValue);
      expect(mConversationCtrl.canSendMessage).assertTrue();
      mocker.clear(MmsPreferences.getInstance());
    })

    it('ConversationControllerTest_setResendIndex', 0, () => {
      mConversationCtrl.setResendIndex(0);
      expect(mConversationCtrl.resendIndex).assertEqual(0);
    })

    it('ConversationControllerTest_resendMsg_resendStateIsRcs_true', 0, () => {
      mocker.mockFunc(MmsUtil, MmsUtil.showToast);
      mConversationCtrl.resendMsg(context, true, false);
      expect(mConversationCtrl.resendIndex).assertEqual(0);
      mocker.clear(MmsUtil);
    })

    it('ConversationControllerTest_resendMsg_resendStateIsRcs_false', 0, () => {
      let item1: mmsListType = new mmsListType();
      mConversationCtrl.mmsList = [item1];
      mConversationCtrl.resendIndex = 2;
      mConversationCtrl.resendMsg(context, false, false);
      expect(mConversationCtrl.resendIndex).assertEqual(2);
    })

    it('ConversationControllerTest_resendMsg_deleteItem_undefined', 0, () => {
      let item1: mmsListType = new mmsListType();
      mConversationCtrl.mmsList = [item1];
      mConversationCtrl.resendIndex = 1;
      mConversationCtrl.resendMsg(context, false, false);
      expect(mConversationCtrl.resendIndex).assertEqual(1);
    })

    it('ConversationControllerTest_resendMsg_resendStateIsRcs_false_deleteItem_notUndefined', 0, () => {
      let item1: mmsListType = new mmsListType();
      mConversationCtrl.mmsList = [item1];
      mConversationCtrl.resendIndex = 0;
      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.initResendItem))(ArgumentMatchers.any)
        .afterReturn(new mmsListType());
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.resendSms);
      mConversationCtrl.resendMsg(context, false, false);
      expect(mConversationCtrl.mmsList.length).assertEqual(0);
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_resendMsg_resendStateIsRcs_true_deleteItem_notUndefined', 0, () => {
      let item1: mmsListType = new mmsListType();
      mConversationCtrl.mmsList = [item1];
      mConversationCtrl.resendIndex = 0;
      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.initResendItem))(ArgumentMatchers.any)
        .afterReturn(new mmsListType());
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.resendSms);
      mocker.mockFunc(MmsUtil, MmsUtil.showToast);
      mConversationCtrl.resendMsg(context, true, true);
      expect(mConversationCtrl.mmsList.length).assertEqual(1);
      mocker.clear(MmsUtil);
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_getSelectMmsStatus_resendIndex_2', 0, () => {
      let item1: mmsListType = new mmsListType();
      mConversationCtrl.mmsList = [item1];
      mConversationCtrl.resendIndex = 2;
      mConversationCtrl.getSelectMmsStatus();
      expect(mConversationCtrl.mmsList.length).assertEqual(1);
    })

    it('ConversationControllerTest_getSelectMmsStatus_resendIndex_0', 0, () => {
      let item1: mmsListType = new mmsListType();
      mConversationCtrl.mmsList = [item1];
      mConversationCtrl.resendIndex = 0;
      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.initResendItem))(ArgumentMatchers.any)
        .afterReturn(new mmsListType());
      mConversationCtrl.getSelectMmsStatus();
      expect(mConversationCtrl.mmsList.length).assertEqual(1);
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_initResendItem', 0, () => {
      let item1: mmsListType = new mmsListType();
      mConversationCtrl.mmsList = [item1];
      mConversationCtrl.resendIndex = 0;
      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.initByDeleteItem))(ArgumentMatchers.any)
        .afterReturn(new mmsListType());
      mocker.mockFunc(ConversationDataSource.getInstance(), ConversationDataSource.getInstance().refresh);
      expect(mConversationCtrl.initResendItem(item1).isRcs).assertEqual(0);
      mocker.clear(ConversationDataSource.getInstance());
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_initByDeleteItem_contactsNum_2', 0, () => {
      mConversationCtrl.contactsNum = 2;
      let item1: mmsListType = new mmsListType();
      mConversationCtrl.mmsList = [item1];
      mConversationCtrl.resendIndex = 0;
      mocker.mockFunc(DateUtil, DateUtil.convertTimeStampToDateWeek);
      mocker.mockFunc(DateUtil, DateUtil.fullDate);
      mConversationCtrl.initByDeleteItem(item1);
      expect(mConversationCtrl.initByDeleteItem(item1).isRcs).assertEqual(0);
      mocker.clear(DateUtil);
    })

    it('ConversationControllerTest_initByDeleteItem_contactsNum_1', 0, () => {
      mConversationCtrl.contactsNum = 1;
      let item1: mmsListType = new mmsListType();
      item1.isMsm = true;
      mConversationCtrl.mmsList = [item1];
      mConversationCtrl.resendIndex = 0;
      mocker.mockFunc(DateUtil, DateUtil.convertTimeStampToDateWeek);
      mocker.mockFunc(DateUtil, DateUtil.fullDate);
      mConversationCtrl.initByDeleteItem(item1);
      expect(mConversationCtrl.initByDeleteItem(item1).isRcs).assertEqual(0);
      mocker.clear(DateUtil);
    })

    it('ConversationControllerTest_initRendContent', 0, () => {
      let context = {
        resourceManager: {
          getStringSync: (resource: Resource, ...args: (string | number)[]): string => 'initRendContent_test'
        } as resourceManager.ResourceManager
      } as Context;
      mConversationCtrl.contactsNum = 1;
      let item1: mmsListType = new mmsListType();
      item1.position = '';
      mConversationCtrl.initRendContent(context, item1);
      mConversationCtrl.initRendContent(context, item1);
      item1.position = 'position';
      mConversationCtrl.initRendContent(context, item1);
      expect(mConversationCtrl).not().assertUndefined();
    })

    it('ConversationControllerTest_resendSms', 0, () => {
      let item1: mmsListType = new mmsListType();
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.initRendContent);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.sendInterval);
      mConversationCtrl.resendSms(context, '57097', item1, [], true);
      item1.isMsm = true;
      mConversationCtrl.resendSms(context, '57097', item1, []);
      item1.isMsm = false;
      mConversationCtrl.resendSms(context, '57097', item1, []);
      mocker.clear(mConversationCtrl);
      expect(mConversationCtrl).not().assertUndefined();
    })

    it('ConversationControllerTest_pushToCopyController', 0, () => {
      let item1: mmsListType = new mmsListType();
      item1.id = 1;
      item1.isMsm = true;
      mConversationCtrl.pushToCopyController(0);
      mConversationCtrl.pushToCopyController(0, item1);
      expect(mConversationCtrl.pageInfos.getAllPathName()[0]).assertEqual('');
    })

    it('ConversationControllerTest_pushToGroupContactListController', 0, () => {
      mConversationCtrl.pushToGroupContactListController();
      expect(mConversationCtrl.pageInfos.getAllPathName()[0]).assertEqual('');
    })

    it('ConversationControllerTest_markAllAsReadByItem_threadId', 0, () => {
      mConversationCtrl.pageInfos.pushPathByName('info', {
        threadId: 1,
        isFromTransmitView: true
      } as LooseObject);
      mocker.mockFunc(ConversationListController.getInstance(),
        ConversationListController.getInstance().handleMarkAllAsRead);

      mConversationCtrl.markAllAsReadByItem(context);
      mocker.verify('handleMarkAllAsRead', [1]).never();
      mocker.clear(ConversationListController.getInstance());
    })

    it('ConversationControllerTest_markAllAsReadByItem_threadId_minus1', 0, () => {
      mConversationCtrl.pageInfos.pushPathByName('info', {
        threadId: -1,
        isFromTransmitView: true
      } as LooseObject);
      mocker.mockFunc(ConversationListController.getInstance(),
        ConversationListController.getInstance().handleMarkAllAsRead);

      mConversationCtrl.markAllAsReadByItem(context);
      mocker.verify('handleMarkAllAsRead', [-1]).never();
      mocker.clear(ConversationListController.getInstance());
    })

    it('ConversationControllerTest_markAllAsReadByItem_isFromTransmitView_true', 0, () => {
      mConversationCtrl.pageInfos.pushPathByName('info', {
        threadId: undefined,
        isFromTransmitView: true
      } as LooseObject);
      mocker.mockFunc(ConversationListController.getInstance(),
        ConversationListController.getInstance().handleMarkAllAsRead);

      mConversationCtrl.markAllAsReadByItem(context);
      mocker.verify('handleMarkAllAsRead', [0]).never();
      mocker.clear(ConversationListController.getInstance());
    })

    it('ConversationControllerTest_refreshSendMessageStatus_receiveContactValue_notEmpty', 0, () => {
      mConversationCtrl.mAttachAreaCtrl.mmDisplaySource = [{} as Mms];
      mConversationCtrl.canSendMessage = false;
      mConversationCtrl.isEditMms = false;
      mConversationCtrl.textValue = '';
      mConversationCtrl.isNewMsg = true;
      mConversationCtrl.receiveContactValue = 'xx';
      mConversationCtrl.selectContacts = [];
      mConversationCtrl.refreshSendMessageStatus();
      expect(mConversationCtrl.isEditMms).assertFalse();
    })

    it('ConversationControllerTest_refreshSendMessageStatus_selectContacts_notEmpty', 0, () => {
      mConversationCtrl.mAttachAreaCtrl.mmDisplaySource = [{} as Mms];
      mConversationCtrl.canSendMessage = false;
      mConversationCtrl.isEditMms = false;
      mConversationCtrl.textValue = '';
      mConversationCtrl.isNewMsg = true;
      mConversationCtrl.receiveContactValue = '';
      mConversationCtrl.selectContacts = [{} as selectContactType];
      mConversationCtrl.refreshSendMessageStatus();
      expect(mConversationCtrl.isEditMms).assertFalse();
    })

    it('ConversationControllerTest_refreshSendMessageStatus_isNewMsg_false', 0, () => {
      mConversationCtrl.mAttachAreaCtrl.mmDisplaySource = [{} as Mms];
      mConversationCtrl.canSendMessage = false;
      mConversationCtrl.isEditMms = false;
      mConversationCtrl.textValue = '';
      mConversationCtrl.isNewMsg = false;
      mConversationCtrl.receiveContactValue = '';
      mConversationCtrl.selectContacts = [{} as selectContactType];
      mConversationCtrl.refreshSendMessageStatus();
      expect(mConversationCtrl.isEditMms).assertFalse();
    })

    it('ConversationControllerTest_refreshSendMessageStatus_textValue_empty', 0, () => {
      mConversationCtrl.mAttachAreaCtrl.mmDisplaySource = [];
      mConversationCtrl.canSendMessage = true;
      mConversationCtrl.isEditMms = false;
      mConversationCtrl.textValue = '';
      mConversationCtrl.isNewMsg = false;
      mConversationCtrl.receiveContactValue = '';
      mConversationCtrl.selectContacts = [{} as selectContactType];
      mConversationCtrl.refreshSendMessageStatus();
      expect(mConversationCtrl.isEditMms).assertFalse();
    })

    it('ConversationControllerTest_refreshSendMessageStatus_textValue_notEmpty', 0, () => {
      mConversationCtrl.mAttachAreaCtrl.mmDisplaySource = [];
      mConversationCtrl.canSendMessage = true;
      mConversationCtrl.isEditMms = false;
      mConversationCtrl.textValue = 'xx';
      mConversationCtrl.isNewMsg = false;
      mConversationCtrl.receiveContactValue = '';
      mConversationCtrl.selectContacts = [{} as selectContactType];
      mConversationCtrl.refreshSendMessageStatus();
      expect(mConversationCtrl.isEditMms).assertFalse();
    })

    it('ConversationControllerTest_sendMmsMessage_sendNumbersLength_2', 0, () => {
      let actionData: ActionDataType = {
        slotId: -1,
        destinationHost: '',
        content: 'xxx',
        isEditMms: false,
        contactId: '',
        contactName: 'name1,name2',
        hosts: ['1111', '2222'],
        isReSend: true,
        id: '1',
        isRcs: 1,
        resendStateIsRcs: true,
        threadId: undefined,
        groupId: 0,
      };
      let item: mmsListType = new mmsListType();
      item.isRcs = 1;
      item.threadId = 1;
      item.rcsType = 7;
      item.mmsSource = [{} as Mms, {
        type: 3,
        content: 'content'
      } as Mms]
      let initDatas: InitData[] = [];
      when(mocker.mockFunc(ImageUtil, ImageUtil.convertImageToThumbnails))(ArgumentMatchers.any)
        .afterReturn(new Promise<string>(resolve => resolve('/')));
      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.getSendMessageId))(ArgumentMatchers.any)
        .afterReturn(1);
      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.findMmsListItemByRcsIdOfRcs))(ArgumentMatchers.any)
        .afterReturn(new mmsListType());

      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.getSmilSource))(ArgumentMatchers.any)
        .afterReturn({});
      when(mocker.mockFunc(MmsUtil, MmsUtil.getSmilMmsSourceDelEmptyPar))(ArgumentMatchers.any)
        .afterReturn([]);

      mConversationCtrl.textValue = 'textValue';
      mConversationCtrl.sendMmsMessage(context, actionData, item, initDatas);

      expect(mConversationCtrl.canSendMessage).assertTrue();
      mocker.clear(mConversationCtrl);
      mocker.clear(ImageUtil);
      mocker.clear(MmsUtil);
    })

    it('ConversationControllerTest_sendMmsMessage_sendNumbersLength_1', 0, () => {
      let actionData: ActionDataType = {
        slotId: -1,
        destinationHost: '',
        content: 'xxx',
        isEditMms: false,
        contactId: '',
        contactName: 'name1,name2',
        hosts: ['1111'],
        isReSend: true,
        id: '1',
        isRcs: 1,
        resendStateIsRcs: true,
        threadId: undefined,
        groupId: 0,
      };
      let item: mmsListType = new mmsListType();
      item.isRcs = 1;
      item.threadId = 1;
      item.rcsType = 7;
      item.mmsSource = [{} as Mms, {
        type: 3,
        content: 'content'
      } as Mms];
      mConversationCtrl.mmsList = [item];
      let initDatas: InitData[] = [];
      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.getSendMessageId))(ArgumentMatchers.any)
        .afterReturn(1);
      mocker.mockFunc(ConversationListService.getInstance(),
        ConversationListService.getInstance().updateSessionByCondition);
      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.findMmsListItemByRcsIdOfRcs))(ArgumentMatchers.any)
        .afterReturn(item);

      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.getSmilSource))(ArgumentMatchers.any)
        .afterReturn({});
      when(mocker.mockFunc(MmsUtil, MmsUtil.getSmilMmsSourceDelEmptyPar))(ArgumentMatchers.any)
        .afterReturn([]);
      mConversationCtrl.textValue = 'textValue';
      mConversationCtrl.sendMmsMessage(context, actionData, item, initDatas);

      expect(mConversationCtrl.mmsList.length).assertEqual(1);

      mocker.clear(MmsUtil);
      mocker.clear(ConversationListService.getInstance());
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_sendMmsMessage_isRcs_0', 0, () => {
      let actionData: ActionDataType = {
        slotId: -1,
        destinationHost: '',
        content: 'xxx',
        isEditMms: false,
        contactId: '',
        contactName: 'name1,name2',
        hosts: ['1111'],
        isReSend: true,
        id: '1',
        isRcs: 0,
        resendStateIsRcs: true,
        threadId: undefined,
        groupId: 0,
      };
      let item: mmsListType = new mmsListType();
      item.isRcs = 0;
      item.threadId = 1;
      item.rcsType = 7;
      item.mmsSource = [{
        type: 3,
        name: 'name1',
        content: 'content'
      } as Mms, {
        type: 3,
        name: 'name',
        content: 'content'
      } as Mms];
      mConversationCtrl.mmsList = [item];
      let initDatas: InitData[] = [];
      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.getSendMessageId))(ArgumentMatchers.any)
        .afterReturn(1);
      when(mocker.mockFunc(MmsPreferences.getInstance(), MmsPreferences.getInstance().getTelephoneNumberOfSim1))()
        .afterReturn('');
      when(mocker.mockFunc(MmsPreferences.getInstance(), MmsPreferences.getInstance().getTelephoneNumberOfSim2))()
        .afterReturn('');
      mocker.mockFunc(DotUtil.getInstance(), DotUtil.getInstance().reportEvent);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.resetItem);
      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.getSmilSource))(ArgumentMatchers.any)
        .afterReturn({});
      let res = false;
      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.updateMmsSession))(ArgumentMatchers.any)
        .afterAction(() => {
          res = true;
        });
      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.dealMmsMessageResult))(ArgumentMatchers.any)
        .afterAction(() => {
          expect(res).assertTrue();
        });
      mocker.mockFunc(ConversationDataSource.getInstance(), ConversationDataSource.getInstance().refresh);
      mConversationCtrl.textValue = 'textValue';
      when(mocker.mockFunc(MmsUtil, MmsUtil.getSmilMmsSourceDelEmptyPar))(ArgumentMatchers.any)
        .afterReturn([]);
      mConversationCtrl.sendMmsMessage(context, actionData, item, initDatas);

      expect(mConversationCtrl.canSendMessage).assertTrue();

      mocker.clear(MmsUtil);
      mocker.clear(MmsPreferences.getInstance());
      mocker.clear(ConversationDataSource.getInstance());
      mocker.clear(DotUtil.getInstance());
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_buildAttachmentSendItemOfEnhancedInfo_copySource_length_1', 0, () => {
      let mms: Mms = {} as Mms;
      mConversationCtrl.mAttachAreaCtrl.copySource = [{
        duration: '0',
        type: 1,
        name: 'name'
      } as Mms];
      mocker.mockFunc(DateUtil, DateUtil.convertTimeStampToDateWeek);
      mocker.mockFunc(DateUtil, DateUtil.fullDate);
      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.getSmilSource))(ArgumentMatchers.any)
        .afterReturn(mms);
      when(mocker.mockFunc(MmsUtil, MmsUtil.getMmsContentType))(ArgumentMatchers.any)
        .afterReturn(mms);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.setDateShow);

      let res: mmsListType = mConversationCtrl.buildAttachmentSendItemOfEnhancedInfo(context, 0, false, 0,
        mConversationCtrl.mAttachAreaCtrl.copySource);

      expect(res.isRcs >= 0).assertTrue();

      mocker.clear(DateUtil);
      mocker.clear(MmsUtil);
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_buildAttachmentSendItemOfEnhancedInfo_copySource_length_0', 0, () => {
      let mms: Mms = {
        duration: '0',
        type: 1,
        name: 'name'
      } as Mms;
      mConversationCtrl.mAttachAreaCtrl.copySource = [];
      mocker.mockFunc(DateUtil, DateUtil.convertTimeStampToDateWeek);
      mocker.mockFunc(DateUtil, DateUtil.fullDate);
      when(mocker.mockFunc(MmsUtil, MmsUtil.getMmsContentType))(ArgumentMatchers.any)
        .afterReturn(mms);
      mocker.mockFunc(mConversationCtrl, mConversationCtrl.setDateShow);

      let res: mmsListType = mConversationCtrl.buildAttachmentSendItemOfEnhancedInfo(context, 0, false, 0,
        mConversationCtrl.mAttachAreaCtrl.copySource);

      expect(res.isRcs >= 0).assertTrue();

      mocker.clear(DateUtil);
      mocker.clear(MmsUtil);
      mocker.clear(mConversationCtrl);
    })

    it('ConversationControllerTest_initRcsSource_rcsDisplaySource_length_0', 0, async () => {
      let mms: Mms = {
        duration: '0',
        type: 1,
        name: 'name',
        path: ''
      } as Mms;
      mConversationCtrl.mAttachAreaCtrl.rcsDisplaySource = [];
      when(mocker.mockFunc(FileUtil, FileUtil.getFileName))(ArgumentMatchers.any)
        .afterReturn('name');
      when(mocker.mockFunc(ObjectUtil, ObjectUtil.getCopyObject))(ArgumentMatchers.any)
        .afterReturn(mms);

      await mConversationCtrl.initRcsSource(false, 0, []);

      mocker.verify('getFileName', ['']).never();

      mocker.clear(FileUtil);
      mocker.clear(ObjectUtil);
    })

    it('ConversationControllerTest_initRcsSource_rcsDisplaySource_length_1_type_2_galleryPath', 0, async () => {
      let mms: Mms = {
        duration: '0',
        type: 2,
        galleryPath: '',
        name: 'name',
        path: ''
      } as Mms;
      mConversationCtrl.mAttachAreaCtrl.rcsDisplaySource = [mms];
      when(mocker.mockFunc(FileUtil, FileUtil.getFileName))(ArgumentMatchers.any)
        .afterReturn('name');
      when(mocker.mockFunc(ObjectUtil, ObjectUtil.getCopyObject))(ArgumentMatchers.any)
        .afterReturn(mms);

      await mConversationCtrl.initRcsSource(false, 0, []);

      mocker.verify('getFileName', ['']).never();

      mocker.clear(FileUtil);
      mocker.clear(ObjectUtil);
    })

    it('ConversationControllerTest_initRcsSource_rcsDisplaySource_length_2_type_2_galleryPath_undefined', 0,
      async () => {
        let mms: Mms = {
          duration: '0',
          type: 1,
          galleryPath: undefined,
          name: 'name',
          path: ''
        } as Mms;
        mConversationCtrl.mAttachAreaCtrl.rcsDisplaySource = [mms, mms];
        when(mocker.mockFunc(FileUtil, FileUtil.getFileName))(ArgumentMatchers.any)
          .afterReturn('name');
        when(mocker.mockFunc(ObjectUtil, ObjectUtil.getCopyObject))(ArgumentMatchers.any)
          .afterReturn(mms);

        await mConversationCtrl.initRcsSource(false, 0, []);

        mocker.verify('getFileName', ['']).never();

        mocker.clear(FileUtil);
        mocker.clear(ObjectUtil);
      })

    it('conversationController_getSmiledRcsSource', 0, async () => {
      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.initRcsSource))(false)
        .afterAction(() => {
          mConversationCtrl.copySource = [{} as Mms];
          return new Promise<void>(resolve => resolve());
        });
      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.getSmilSourceForMore))(ArgumentMatchers.any)
        .afterReturn({} as Mms);
      await mConversationCtrl.getSmiledRcsSource(context);
      expect(mConversationCtrl).not().assertUndefined();
      mocker.clear(mConversationCtrl);
    })

    it('conversationController_getSmilSourceForMore', 0, () => {
      when(mocker.mockFunc(SmilFile, SmilFile.buildSmilFile))(ArgumentMatchers.any)
        .afterReturn('');
      when(mocker.mockFunc(FileUtil,
        FileUtil.writeTextToSandBox))(ArgumentMatchers.any)
        .afterReturn({
          'path': '',
          'name': ''
        } as Record<string, string>);

      mConversationCtrl.getSmilSourceForMore(context, []);

      expect(mConversationCtrl).not().assertUndefined();

      mocker.clear(SmilFile);
      mocker.clear(FileUtil);
    })

    it('conversationController__updateMmsSession', 0, () => {
      let res = false;
      mocker.mockFunc(ConversationListService.getInstance(),
        ConversationListService.getInstance().updateSessionByCondition);
      when(mocker.mockFunc(ConversationService.getInstance(),
        ConversationService.getInstance().updateSmsMmsInfoByCondition))(ArgumentMatchers.any)
        .afterAction(() => {
          res = true;
        });

      mConversationCtrl.updateMmsSession(context, new mmsListType());

      expect(res).assertTrue();

      mocker.clear(ConversationListService.getInstance());
      mocker.clear(ConversationService.getInstance());
    })
  })
}