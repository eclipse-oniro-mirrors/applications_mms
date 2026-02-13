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
import SearchUtil, { ContactsSchema, IdLabelValueSchema } from '../../../../../main/ets/utils/SearchUtil';
import LooseObject from '../../../../../main/ets/data/LooseObject';
import ReceiveController, { callType } from '../../../../../main/ets/views/receive/receiveController';
import commonService from '../../../../../main/ets/service/CommonService'
import { GlobalContext } from '../../../../../main/ets/MainAbility/GlobalHelper';
import { ability, StartOptions } from '@kit.AbilityKit';
import myCommon from '@ohos.app.ability.common';
import { BusinessError } from '@kit.BasicServicesKit';
import DataShareHelper from '../../../../../main/ets/model/repository/DataShareHelper';
import { dataShare, dataSharePredicates, DataShareResultSet } from '@kit.ArkData';
import MySet from '../../MySet';
import StringUtil from '../../../../../main/ets/utils/StringUtil';
import TelephoneUtil from '../../../../../main/ets/utils/TelephoneUtil';
import ConversationController, { rcsFileInfo } from '../../../../../main/ets/pages/conversation/conversationController';
import { window } from '@kit.ArkUI';
import CreateNewConversationViewModle from '../../../../../main/ets/pages/conversation/CreateNewConversationViewModle';
import { isSameTel } from '../../../../../main/ets/utils/TelephoneUtilEnhancde';
import { DTGlobalContext } from '../../../testability/TestAbility';
import { Contact } from '../../../../../main/ets/utils/TypesUtils';
import AccessibilityUtil from '../../../../../main/ets/utils/AccessibilityUtil';

export default function receiveControllerTest() {
  describe('ReceiveControllerTest', () => {
    let receiveCtrl: ReceiveController;

    let mocker: MockKit;
    let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;

    beforeEach(() => {
      receiveCtrl = new ReceiveController();
      mocker = new MockKit()
    })

    afterEach(() => {
      AppStorage.clear();
      mocker.clear(receiveCtrl);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('ReceiveControllerTest_getInstance', 0, () => {
      expect(typeof ReceiveController.getInstance()).assertEqual(typeof receiveCtrl);
    })

    it('ReceiveControllerTest_deleteContactItem', 0, () => {
      receiveCtrl.deleteContactItem(() => {});
      expect(receiveCtrl).not().assertUndefined();
    })

    it('ReceiveControllerTest_getContactsByFuzzMatch', 0, () => {
      let list: Contact[] = [{
        detailInfo: '123456',
        displayName: 'displayName',
        id: 1,
        rawContactId: 'rawContactId',
        contactId: 'contactId'
      }]
      let info = receiveCtrl.getContactsByFuzzMatch(list, '123456');
      expect(info.detailInfo).assertEqual('123456');
    })

    it('ReceiveControllerTest_getContactsByFuzzMatch_format', 0, () => {
      let list: Contact[] = [{
        detailInfo: '133 2964 5813',
        displayName: 'displayName',
        id: 1,
        rawContactId: 'rawContactId',
        contactId: 'contactId'
      }]
      let info = receiveCtrl.getContactsByFuzzMatch(list, '13329645813');
      expect(info.detailInfo).assertEqual('133 2964 5813');
    })

    it('ReceiveControllerTest_getContactsByFuzzMatch_no', 0, () => {
      let list: Contact[] = [{
        detailInfo: '13329645877',
        displayName: 'displayName',
        id: 1,
        rawContactId: 'rawContactId',
        contactId: 'contactId'
      }]
      let info = receiveCtrl.getContactsByFuzzMatch(list, '13329645813');
      expect(info.detailInfo).assertEqual('13329645813');
    })

    it('ReceiveControllerTest_onInit_selectContacts', 0, () => {
      receiveCtrl.refresh = false;
      receiveCtrl.commonCtrl.paramContact = {
        transmitContacts: [{} as LooseObject]
      } as LooseObject;
      mocker.mockFunc(receiveCtrl, receiveCtrl.setContactValue);
      mocker.mockFunc(receiveCtrl, receiveCtrl.setInputStatus);
      mocker.mockFunc(receiveCtrl, receiveCtrl.queryRecentContacts);
      mocker.mockFunc(receiveCtrl, receiveCtrl.requestItem);

      receiveCtrl.onInit(context, () => {
      });

      expect(receiveCtrl.refresh).assertTrue();
    })

    it('ReceiveControllerTest_onInit_selectContacts_length_0', 0, () => {
      receiveCtrl.refresh = false;
      receiveCtrl.commonCtrl.paramContact = {
        transmitContacts: []
      } as LooseObject;
      mocker.mockFunc(receiveCtrl, receiveCtrl.setContactValue);
      mocker.mockFunc(receiveCtrl, receiveCtrl.setInputStatus);
      mocker.mockFunc(receiveCtrl, receiveCtrl.queryRecentContacts);
      mocker.mockFunc(receiveCtrl, receiveCtrl.requestItem);

      receiveCtrl.onInit(context, () => {
      });

      expect(receiveCtrl.refresh).assertTrue();
    })

    it('ReceiveControllerTest_refreshContactDataOnPageShow', 0, () => {
      mocker.mockFunc(receiveCtrl, receiveCtrl.requestItem);
      receiveCtrl.refreshContactDataOnPageShow(context);
      mocker.verify('requestItem', []).never();
    })

    it('ReceiveControllerTest_emitOnchangeInputStatus', 0, () => {
      receiveCtrl.emitOnchangeInputStatus();
      expect(receiveCtrl.isShowSearch).assertTrue();
    })

    it('ReceiveControllerTest_requestItem', 0, () => {
      receiveCtrl.page = 0;
      mocker.mockFunc(receiveCtrl, receiveCtrl.queryContacts);

      receiveCtrl.requestItem(context);

      expect(receiveCtrl.page).assertEqual(1);
    })

    it('ReceiveControllerTest_requestItem_page_1', 0, () => {
      receiveCtrl.page = 1;
      receiveCtrl.totalMessage = 10;
      receiveCtrl.limit = 1;
      receiveCtrl.contacts = [{} as LooseObject, {} as LooseObject, {} as LooseObject];
      mocker.mockFunc(receiveCtrl, receiveCtrl.queryContacts);

      receiveCtrl.requestItem(context);

      expect(receiveCtrl.page).assertEqual(2);
    })

    it('ReceiveControllerTest_queryContacts_fail', 0, () => {
      receiveCtrl.totalMessage = 0;
      when(mocker.mockFunc(DataShareHelper.getInstance(),
        DataShareHelper.getInstance().initContactDB))(ArgumentMatchers.any)
        .afterReturn(new Promise<dataShare.DataShareHelper | undefined>(resolve => resolve(undefined)));

      receiveCtrl.queryContacts(context);
      expect(receiveCtrl).not().assertUndefined();
    })

    it('ReceiveControllerTest_queryContacts_success', 0, () => {
      receiveCtrl.totalMessage = 0;
      let myset: DataShareResultSet = new MySet();
      myset.rowCount = 1;
      when(mocker.mockFunc(DataShareHelper.getInstance(),
        DataShareHelper.getInstance().initContactDB))(ArgumentMatchers.any)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve(myset))
        } as dataShare.DataShareHelper)));

      receiveCtrl.queryContacts(context);
      expect(receiveCtrl).not().assertUndefined();
    })

    it('ReceiveControllerTest_queryRecentContacts_success', 0, () => {
      when(mocker.mockFunc(StringUtil, StringUtil.getFirstName))(ArgumentMatchers.any)
        .afterReturn([]);
      let myset: DataShareResultSet = new MySet();
      myset.rowCount = 1;
      when(mocker.mockFunc(DataShareHelper.getInstance(),
        DataShareHelper.getInstance().initContactDB))(ArgumentMatchers.any)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve(myset))
        } as dataShare.DataShareHelper)));
      mocker.mockFunc(receiveCtrl, receiveCtrl.deleteRepetitionContacts);
      when(mocker.mockFunc(TelephoneUtil, TelephoneUtil.formatDisplayPhoneNum))(ArgumentMatchers.any)
        .afterReturn('');

      receiveCtrl.queryRecentContacts(context);

      expect(receiveCtrl.contactsTemp.length).assertEqual(0);

      mocker.clear(StringUtil);
      mocker.clear(TelephoneUtil);
    })

    it('ReceiveControllerTest_queryRecentContacts_fail', 0, () => {
      when(mocker.mockFunc(StringUtil, StringUtil.getFirstName))(ArgumentMatchers.any)
        .afterReturn([]);
      let myset: DataShareResultSet = new MySet();
      myset.rowCount = 1;
      when(mocker.mockFunc(DataShareHelper.getInstance(),
        DataShareHelper.getInstance().initContactDB))(ArgumentMatchers.any)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve( {}as dataShare.DataShareHelper)));

      receiveCtrl.queryRecentContacts(context);

      expect(receiveCtrl.contactsTemp.length).assertEqual(0);

      mocker.clear(StringUtil);
      mocker.clear(TelephoneUtil);
    })

    it('ReceiveControllerTest_filterContacts_contactName', 0, () => {
      receiveCtrl.contactsTemp = [{
        contactName: 'xxxx',
        telephone: '122222'
      }];
      receiveCtrl.filterContacts('xx');
      expect(receiveCtrl.contacts.length).assertEqual(1);
    })

    it('ReceiveControllerTest_filterContacts_none', 0, () => {
      receiveCtrl.contactsTemp = [{
        contactName: 'xxxx',
        telephone: '122222'
      }];
      receiveCtrl.filterContacts('33');
      expect(receiveCtrl.contacts.length).assertEqual(0);
    })

    it('ReceiveControllerTest_filterContacts_catch', 0, () => {
      receiveCtrl.contactsTemp = [{
        contactName: 'xxxx',
        telephone: '122222'
      }];
      when(mocker.mockFunc(receiveCtrl.contactsTemp, receiveCtrl.contactsTemp.filter))(ArgumentMatchers.any)
        .afterThrow('error');

      receiveCtrl.filterContacts('33');

      expect(receiveCtrl.contacts.length).assertEqual(0);

      mocker.clear(receiveCtrl.contactsTemp);
    })

    it('ReceiveControllerTest_filterContacts_telephone', 0, () => {
      receiveCtrl.contactsTemp = [{
        contactName: 'xxxx',
        telephone: '122222'
      }];
      receiveCtrl.filterContacts('12');
      expect(receiveCtrl.contacts.length).assertEqual(1);
    })

    it('ReceiveControllerTest_setInputStatus', 0, () => {
      receiveCtrl.setInputStatus(true);
      expect(receiveCtrl.isInputStatus).assertTrue();
    })

    it('ReceiveControllerTest_setInputStatus_not_str', 0, () => {
      receiveCtrl.selectContacts = [{
        telephone: '10086'
      } as LooseObject,{
        telephone: '10000'
      } as LooseObject];
      receiveCtrl.strSelectContact = {
        bundleName: '',
        moduleName: '',
        id: 1,
        params: []
      }
      receiveCtrl.setInputStatus(true);
      let p = receiveCtrl.setShowContactName();
      if (typeof p !== 'string') {
        expect('[2,"10086",1]').assertEqual(JSON.stringify(p.params));
      }
    })

    it('ReceiveControllerTest_checkDuplicates_isSameTel_true', 0, () => {
      receiveCtrl.myText = 'xxxxxxx';
      receiveCtrl.selectContacts = [{
        telephone: '1111'
      } as LooseObject];
      when(mocker.mockFunc(TelephoneUtil, isSameTel))(ArgumentMatchers.any)
        .afterReturn(true);

      expect(receiveCtrl.checkDuplicates()).assertFalse();

      mocker.clear(TelephoneUtil);
    })

    it('ReceiveControllerTest_checkDuplicates_false', 0, () => {
      receiveCtrl.myText = 'xxxxxxx';
      receiveCtrl.selectContacts = [{
        telephone: '1111'
      } as LooseObject];
      when(mocker.mockFunc(TelephoneUtil, isSameTel))(ArgumentMatchers.any)
        .afterReturn(false);

      expect(receiveCtrl.checkDuplicates()).assertFalse();

      mocker.clear(TelephoneUtil);
    })

    it('ReceiveControllerTest_checkReceive_myText_empty', 0, async () => {
      receiveCtrl.myText = '';
      when(mocker.mockFunc(receiveCtrl, receiveCtrl.setShowContactName))()
        .afterReturn('');

      await receiveCtrl.checkReceive(() => {
      });

      expect(receiveCtrl.strSelectContact).assertEqual('');
    })

    it('ReceiveControllerTest_checkReceive_isRcsMms_true_selectContacts_length_1_maxOneToManyRecipients_0', 0,
      async () => {
        receiveCtrl.selectContacts = [{} as LooseObject];
        receiveCtrl.myText = 'xxxx';
        ConversationController.getInstance().isRcsMms = true;
        let mocker: MockKit = new MockKit();
        mocker.mockFunc(receiveCtrl, receiveCtrl.showUpperLimitToast);

        await receiveCtrl.checkReceive(() => {
        });
        expect(receiveCtrl.myText).assertEqual('');
      })

    it('ReceiveControllerTest_checkReceive_isRcsMms_true_selectContacts_length_1000', 0, async () => {
      receiveCtrl.selectContacts.length = 1000;
      receiveCtrl.myText = 'xxxx';
      ConversationController.getInstance().isRcsMms = true;
      mocker.mockFunc(receiveCtrl, receiveCtrl.showUpperLimitToast);

      await receiveCtrl.checkReceive(() => {
      });

      expect(receiveCtrl.myText).assertEqual('');
    })

    it('ReceiveControllerTest_checkReceive_isRcsMms_true_selectContacts_length_1_isPhoneNumber_true_checkDuplicates_true',
      0, async () => {
        receiveCtrl.selectContacts = [{} as LooseObject];
        receiveCtrl.myText = 'xxxx';
        ConversationController.getInstance().isRcsMms = true;
        let mocker: MockKit = new MockKit();
        mocker.mockFunc(receiveCtrl, receiveCtrl.showUpperLimitToast);
        when(mocker.mockFunc(TelephoneUtil, TelephoneUtil.isPhoneNumber))(ArgumentMatchers.any)
          .afterReturn(true);
        when(mocker.mockFunc(receiveCtrl, receiveCtrl.checkDuplicates))().afterReturn(true);

        await receiveCtrl.checkReceive(() => {
        });

        expect(receiveCtrl.myText).assertEqual('');
        mocker.clear(TelephoneUtil);
      })

    it('ReceiveControllerTest_checkReceive_isRcsMms_true_selectContacts_length_1_isPhoneNumber_true_checkDuplicates_false',
      0, async () => {
        receiveCtrl.selectContacts = [{} as LooseObject];
        receiveCtrl.myText = 'xxxx';
        ConversationController.getInstance().isRcsMms = true;
        let mocker: MockKit = new MockKit();
        mocker.mockFunc(receiveCtrl, receiveCtrl.showUpperLimitToast);
        when(mocker.mockFunc(TelephoneUtil, TelephoneUtil.isPhoneNumber))(ArgumentMatchers.any)
          .afterReturn(true);
        when(mocker.mockFunc(receiveCtrl, receiveCtrl.checkDuplicates))().afterReturn(false);

        await receiveCtrl.checkReceive(() => {
        });

        expect(receiveCtrl.myText).assertEqual('');
        mocker.clear(TelephoneUtil);
      })

    it('ReceiveControllerTest_checkReceive_isRcsMms_true_selectContacts_length_1_isPhoneNumber_false', 0, async () => {
      receiveCtrl.selectContacts = [{} as LooseObject];
      receiveCtrl.myText = 'xxxx';
      ConversationController.getInstance().isRcsMms = true;
      mocker.mockFunc(receiveCtrl, receiveCtrl.showUpperLimitToast);
      when(mocker.mockFunc(TelephoneUtil, TelephoneUtil.isPhoneNumber))(ArgumentMatchers.any)
        .afterReturn(false);
      mocker.mockFunc(receiveCtrl, receiveCtrl.setContactValue);

      await receiveCtrl.checkReceive(() => {
      });

      expect(receiveCtrl.isShowSearch).assertTrue();
      mocker.clear(TelephoneUtil);
    })

    it('ReceiveControllerTest_checkReceive_isRcsMms_false_selectContacts_length_1_isPhoneNumber_false', 0, async () => {
      receiveCtrl.selectContacts = [{} as LooseObject];
      receiveCtrl.myText = 'xxxx';
      ConversationController.getInstance().isRcsMms = false;
      mocker.mockFunc(receiveCtrl, receiveCtrl.showUpperLimitToast);
      when(mocker.mockFunc(TelephoneUtil, TelephoneUtil.isPhoneNumber))(ArgumentMatchers.any)
        .afterReturn(false);
      mocker.mockFunc(receiveCtrl, receiveCtrl.setContactValue);

      await receiveCtrl.checkReceive(() => {
      });

      expect(receiveCtrl.isShowSearch).assertTrue();
      mocker.clear(TelephoneUtil);
    })

    it('ReceiveControllerTest_getInfomationFromContact_isSameTel_true', 0, () => {
      receiveCtrl.selectContacts = [{
        telephone: '11111111',
        contactName: 'name',
        rawContactId: '1'
      } as LooseObject];
      receiveCtrl.contacts = [{
        telephone: '11111111',
        contactName: 'name',
        rawContactId: '1'
      } as LooseObject];
      receiveCtrl.myText = 'xxxx';

      mocker.mockFunc(receiveCtrl, receiveCtrl.setInputStatus);
      mocker.mockFunc(receiveCtrl, receiveCtrl.setContactValue);
      mocker.mockFunc(receiveCtrl, receiveCtrl.requestMmsInputFocus);

      receiveCtrl.getInfomationFromContact(() => {
      });

      expect(receiveCtrl.isShowSearch).assertTrue();

      mocker.clear(TelephoneUtil);
    })

    it('ReceiveControllerTest_getInfomationFromContact_isSameTel_false', 0, () => {
      receiveCtrl.selectContacts = [];
      receiveCtrl.contacts = [{
        telephone: '11111111',
        contactName: 'name',
        rawContactId: '1'
      } as LooseObject];
      receiveCtrl.myText = 'xxxx';

      mocker.mockFunc(receiveCtrl, receiveCtrl.setInputStatus);
      mocker.mockFunc(receiveCtrl, receiveCtrl.setContactValue);
      mocker.mockFunc(receiveCtrl, receiveCtrl.requestMmsInputFocus);

      receiveCtrl.getInfomationFromContact(() => {
      });

      expect(receiveCtrl.isShowSearch).assertFalse();

      mocker.clear(TelephoneUtil);
    })

    it('ReceiveControllerTest_searchChange_text_empty', 0, () => {
      let controller: TextAreaController = new TextAreaController();
      when(mocker.mockFunc(SearchUtil, SearchUtil.searchContact))(ArgumentMatchers.any)
        .afterReturn(new Promise<ContactsSchema[]>((resolve: (value: ContactsSchema[] | PromiseLike<ContactsSchema[]>) => void,
          reject: (reason?: BusinessError) => void) => reject({
          code: -1
        } as BusinessError)));
      when(mocker.mockFunc(TelephoneUtil, TelephoneUtil.dynamicFormatPhone))(ArgumentMatchers.any).afterReturn('')
      mocker.mockFunc(receiveCtrl, receiveCtrl.setContactValue);

      receiveCtrl.searchChange('', () => {
      }, controller);

      expect(receiveCtrl.isShowSearch).assertTrue();

      mocker.clear(SearchUtil);
      mocker.clear(TelephoneUtil);
    })

    it('ReceiveControllerTest_searchChange_isNaN_true_isInputStatus_true_fail', 0, () => {
      let controller: TextAreaController = new TextAreaController();
      when(mocker.mockFunc(SearchUtil, SearchUtil.searchContact))(ArgumentMatchers.any)
        .afterReturn(new Promise<ContactsSchema[]>((resolve: (value: ContactsSchema[] | PromiseLike<ContactsSchema[]>) => void,
          reject: (reason?: BusinessError) => void) => reject({
          code: -1
        } as BusinessError)));
      mocker.mockFunc(receiveCtrl, receiveCtrl.setContactValue);

      receiveCtrl.searchChange("a", () => {
      }, controller);

      expect(receiveCtrl.isShowSearch).assertTrue();

      mocker.clear(SearchUtil);
    })

    it('ReceiveControllerTest_searchChange_isNaN_false_isInputStatus_false', 0, async () => {
      receiveCtrl.caretPointFlag = true;
      receiveCtrl.isInputStatus = false;
      let controller: TextAreaController = {
        getCaretOffset: (): CaretOffset => {
          return {
            index: 0, x:
            0, y:
            0
          }
        },
        caretPosition: (value: number): void => {
        }
      } as TextAreaController;

      mocker.mockFunc(receiveCtrl, receiveCtrl.setInputStatus);
      mocker.mockFunc(receiveCtrl, receiveCtrl.setContactValue);
      mocker.mockFunc(receiveCtrl, receiveCtrl.requestMmsInputFocus);
      when(mocker.mockFunc(TelephoneUtil, TelephoneUtil.dynamicFormatPhone))(ArgumentMatchers.any)
        .afterReturn('1');

      receiveCtrl.searchChange("1", () => {
      }, controller);

      expect(receiveCtrl.caretPointFlag).assertFalse();
      mocker.clear(TelephoneUtil);
    })

    it('ReceiveControllerTest_searchChange_isNaN_false_isInputStatus_true_caretPointFlag_False', 0, async () => {
      receiveCtrl.caretPointFlag = false;
      receiveCtrl.isInputStatus = true;
      let controller: TextAreaController = {
        getCaretOffset: (): CaretOffset => {
          return {
            index: 0, x:
            0, y:
            0
          }
        },
        caretPosition: (value: number): void => {
        }
      } as TextAreaController;

      mocker.mockFunc(receiveCtrl, receiveCtrl.setInputStatus);
      mocker.mockFunc(receiveCtrl, receiveCtrl.dealSearchData);
      mocker.mockFunc(receiveCtrl, receiveCtrl.setContactValue);
      mocker.mockFunc(receiveCtrl, receiveCtrl.requestMmsInputFocus);
      mocker.mockFunc(receiveCtrl, receiveCtrl.formatContactData);
      mocker.mockFunc(receiveCtrl, receiveCtrl.deleteRepetitionContacts);
      when(mocker.mockFunc(TelephoneUtil, TelephoneUtil.dynamicFormatPhone))(ArgumentMatchers.any)
        .afterReturn('1');
      when(mocker.mockFunc(SearchUtil, SearchUtil.searchContact))(ArgumentMatchers.any)
        .afterReturn(new Promise<ContactsSchema[]>(resolve => resolve([])))

      receiveCtrl.searchChange("1", () => {
      }, controller);

      expect(receiveCtrl.caretPointFlag).assertFalse();
      mocker.clear(TelephoneUtil);
    })

    it('ReceiveControllerTest_searchChange_isNaN_false_isInputStatus_false_text_notEqual', 0, async () => {
      receiveCtrl.caretPointFlag = false;
      receiveCtrl.isInputStatus = false;
      let controller: TextAreaController = {
        getCaretOffset: (): CaretOffset => {
          return {
            index: 0, x:
            0, y:
            0
          }
        },
        caretPosition: (value: number): void => {
        }
      } as TextAreaController;

      mocker.mockFunc(receiveCtrl, receiveCtrl.searchChangeCodex);
      mocker.mockFunc(receiveCtrl, receiveCtrl.setInputStatus);
      mocker.mockFunc(receiveCtrl, receiveCtrl.setContactValue);
      mocker.mockFunc(receiveCtrl, receiveCtrl.requestMmsInputFocus);
      when(mocker.mockFunc(TelephoneUtil, TelephoneUtil.dynamicFormatPhone))(ArgumentMatchers.any)
        .afterReturn('2');

      receiveCtrl.searchChange("1", () => {
      }, controller);

      expect(receiveCtrl.caretPointFlag).assertFalse();
      mocker.clear(TelephoneUtil);
    })

    it('ReceiveControllerTest_searchChangeCodex', 0, async () => {
      receiveCtrl.searchChangeCodex("a", 1);
      expect(receiveCtrl.caretPointFlag).assertTrue();
    })

    it('ReceiveControllerTest_searchChangeCodex_charAt_empty', 0, async () => {
      when(mocker.mockFunc(TelephoneUtil, TelephoneUtil.dynamicFormatPhone))(ArgumentMatchers.any)
        .afterReturn(' xxx')
      receiveCtrl.searchChangeCodex(" xxx", 1);
      expect(receiveCtrl.caretPointFlag).assertTrue();
      mocker.clear(TelephoneUtil);
    })

    it('ReceiveControllerTest_formatContactData1', 0, async () => {
      receiveCtrl.contacts = [{
        displayName: 'name x',
        contactName: '',
        detailInfo: '',
        telephone: '',
        rawContactId: '',
        nameHighlights: '',
        phoneHighlights: '',
      }];
      when(mocker.mockFunc(StringUtil, StringUtil.getFirstName))()
        .afterReturn('name');

      receiveCtrl.formatContactData();

      expect(receiveCtrl.contacts[0].contactName).assertEqual('name x');

      mocker.clear(StringUtil);
    })

    it('ReceiveControllerTest_formatContactData2', 0, async () => {
      receiveCtrl.contacts = [{
        displayName: null,
        contactName: 'xx',
        detailInfo: null,
        telephone: '',
        rawContactId: null,
        nameHighlights: '',
        phoneHighlights: '',
      }];
      when(mocker.mockFunc(StringUtil, StringUtil.getFirstName))()
        .afterReturn('name');

      receiveCtrl.formatContactData();

      expect(receiveCtrl.contacts[0].contactName).assertEqual('xx');

      mocker.clear(StringUtil);
    })

    it('ReceiveControllerTest_dealSearchData', 0, () => {
      receiveCtrl.dealSearchData();
      expect(receiveCtrl.isShowSearch).assertTrue();
    })

    it('ReceiveControllerTest_setContactValue', 0, () => {
      receiveCtrl.setContactValue(() => {
      });
      expect(receiveCtrl.isShowSearch).assertTrue();
    })

    it('ReceiveControllerTest_addContact_isRcsMms_true_length_2', 0, async () => {
      receiveCtrl.selectContacts = [{
        select: false,
        Telephone: '1111'
      } as LooseObject, {
        select: false,
        Telephone: '1111'
      } as LooseObject];
      receiveCtrl.contacts = [{
        select: false,
        Telephone: '1111'
      } as LooseObject];
      receiveCtrl.contactsTemp = [{
        select: false,
        Telephone: '1111'
      } as LooseObject];
      ConversationController.getInstance().isRcsMms = true;
      mocker.mockFunc(receiveCtrl, receiveCtrl.showUpperLimitToast);

      await receiveCtrl.addContact(0, () => {
      });

      expect(receiveCtrl.hasBlur).assertFalse();
    })

    it('ReceiveControllerTest_addContact_isRcsMms_true_selectContactsLength_0', 0, async () => {
      receiveCtrl.selectContacts = [];
      receiveCtrl.contacts = [{
        select: false,
        Telephone: '1111'
      } as LooseObject];
      receiveCtrl.contactsTemp = [{
        select: false,
        Telephone: '1111'
      } as LooseObject];
      ConversationController.getInstance().isRcsMms = true;

      await receiveCtrl.addContact(0, () => {
      });

      expect(receiveCtrl.hasBlur).assertFalse();
    })

    it('ReceiveControllerTest_addContact_isnotBeidou', 0, async () => {
      receiveCtrl.selectContacts = [{
        telephone: ''
      } as LooseObject];
      receiveCtrl.contacts = [{} as LooseObject];
      ConversationController.getInstance().isRcsMms = false;

      await receiveCtrl.addContact(0, () => {
      }, false);

      expect(receiveCtrl.hasBlur).assertFalse();
    })

    it('ReceiveControllerTest_addContact_isBeidou', 0, async () => {
      receiveCtrl.selectContacts = [{
        telephone: ''
      } as LooseObject,{
        telephone: ''
      } as LooseObject,{
        telephone: ''
      } as LooseObject,{
        telephone: ''
      } as LooseObject,{
        telephone: ''
      } as LooseObject,{
        telephone: ''
      } as LooseObject];
      receiveCtrl.contacts = [{} as LooseObject];
      ConversationController.getInstance().isRcsMms = false;

      await receiveCtrl.addContact(0, () => {
      }, true);

      expect(receiveCtrl.hasBlur).assertFalse();
    })

    it('ReceiveControllerTest_addContact_isRcsMms_false_telephone_empty', 0, async () => {
      receiveCtrl.selectContacts = [{
        telephone: ''
      } as LooseObject];
      receiveCtrl.contacts = [{} as LooseObject];
      ConversationController.getInstance().isRcsMms = false;

      await receiveCtrl.addContact(0, () => {
      });

      expect(receiveCtrl.hasBlur).assertFalse();
    })

    it('ReceiveControllerTest_addContact_isRcsMms_false_selectContactsLength_1', 0, async () => {
      receiveCtrl.selectContacts = [{
        telephone: '1111111'
      } as LooseObject];
      receiveCtrl.contacts = [{
        select: false,
        telephone: '1111111'
      } as LooseObject];
      receiveCtrl.contactsTemp = [{
        select: false,
        telephone: '1111111'
      } as LooseObject];
      when(mocker.mockFunc(TelephoneUtil, isSameTel))(ArgumentMatchers.any)
        .afterReturn(false);
      ConversationController.getInstance().isRcsMms = false;
      mocker.mockFunc(receiveCtrl, receiveCtrl.setInputStatus);
      mocker.mockFunc(receiveCtrl, receiveCtrl.setContactValue);
      mocker.mockFunc(receiveCtrl, receiveCtrl.requestMmsInputFocus);

      await receiveCtrl.addContact(0, () => {
      });

      expect(receiveCtrl.isShowSearch).assertTrue();

      mocker.clear(TelephoneUtil);
    })

    it('ReceiveControllerTest_addContact_isRcsMms_false_selectContactsLength_2', 0, async () => {
      receiveCtrl.selectContacts = [{
        telephone: '1111111'
      } as LooseObject, {
        telephone: '1111111'
      } as LooseObject];
      receiveCtrl.contacts = [{
        select: false,
        telephone: '1111111'
      } as LooseObject];
      receiveCtrl.contactsTemp = [{
        select: false,
        telephone: '1111111'
      } as LooseObject];
      when(mocker.mockFunc(TelephoneUtil, isSameTel))(ArgumentMatchers.any)
        .afterReturn(true);
      ConversationController.getInstance().isRcsMms = false;
      mocker.mockFunc(receiveCtrl, receiveCtrl.setInputStatus);
      mocker.mockFunc(receiveCtrl, receiveCtrl.setContactValue);
      mocker.mockFunc(receiveCtrl, receiveCtrl.requestMmsInputFocus);

      receiveCtrl.addContact(0, () => {
      });

      expect(receiveCtrl.isShowSearch).assertTrue();

      mocker.clear(TelephoneUtil);
    })

    it('ReceiveControllerTest_setShowContactName', 0, () => {
      receiveCtrl.selectContacts = [{
        telephone: '1111111',
        contactName: ''
      } as LooseObject];
      receiveCtrl.contacts = [{
        select: false,
        telephone: '1111111',
        contactName: ''
      } as LooseObject];
      when(mocker.mockFunc(TelephoneUtil, TelephoneUtil.isPhoneNumber))(ArgumentMatchers.any)
        .afterReturn(false);

      let str: string | Resource = receiveCtrl.setShowContactName();

      expect(str).assertEqual('1111111');

      mocker.clear(TelephoneUtil);
    })

    it('ReceiveControllerTest_setShowContactName_selectContactsLength_2', 0, () => {
      receiveCtrl.selectContacts = [{
        telephone: '1111111',
        contactName: ''
      } as LooseObject, {
        telephone: '1111111',
        contactName: ''
      } as LooseObject];
      receiveCtrl.contacts = [{
        select: false,
        telephone: '1111111',
        contactName: ''
      } as LooseObject];
      when(mocker.mockFunc(TelephoneUtil, TelephoneUtil.isPhoneNumber))(ArgumentMatchers.any)
        .afterReturn(true);

      let str: string | Resource = receiveCtrl.setShowContactName();

      expect(JSON.stringify(str).includes('[2,"1111111",1]')).assertTrue();

      mocker.clear(TelephoneUtil);
    })

    it('ReceiveControllerTest_myContactFocus', 0, () => {
      mocker.mockFunc(receiveCtrl, receiveCtrl.setInputStatus);

      receiveCtrl.myContactFocus();

      expect(receiveCtrl.isShowSearch).assertTrue();
    })

    it('ReceiveControllerTest_myContactFocus_isFromContactPage_true', 0, () => {
      receiveCtrl.isFromContactPage = true;
      receiveCtrl.myContactFocus();
      expect(receiveCtrl.isFromContactPage).assertFalse();
    })

    it('ReceiveControllerTest_myContactClick', 0, () => {
      let scroller: Scroller = new Scroller();
      receiveCtrl.myContactClick(scroller);
      expect(receiveCtrl.isInputStatus).assertTrue();
    })

    it('ReceiveControllerTest_myContactClick_isInputStatus_false', 0, () => {
      receiveCtrl.isInputStatus = false;
      let scroller: Scroller = new Scroller();

      mocker.mockFunc(receiveCtrl, receiveCtrl.setInputStatus);
      mocker.mockFunc(scroller, scroller.scrollEdge);

      receiveCtrl.myContactClick(scroller, () => {
      });
      expect(receiveCtrl.isInputStatus).assertFalse();
    })

    it('ReceiveControllerTest_nameClick', 0, () => {
      receiveCtrl.nameClick(0, () => {
      });
      expect(receiveCtrl.isInputStatus).assertTrue();
    })

    it('ReceiveControllerTest_nameClick_select_false', 0, () => {
      receiveCtrl.selectContacts = [{
        select: false,
      } as LooseObject];
      receiveCtrl.refresh = true;

      receiveCtrl.nameClick(0, () => {
      });

      expect(receiveCtrl.refresh).assertFalse();
    })

    it('ReceiveControllerTest_clickToContacts_isRcsMms_true', 0, async () => {
      receiveCtrl.selectContacts = [{} as LooseObject];
      receiveCtrl.myText = 'xxxx';
      ConversationController.getInstance().isRcsMms = true;
      mocker.mockFunc(receiveCtrl, receiveCtrl.showUpperLimitToast);

      await receiveCtrl.clickToContacts(() => {
      });

      expect(receiveCtrl.myText).assertEqual('xxxx');
    })

    it('ReceiveControllerTest_clickToContacts_isRcsMms_true_length', 0, async () => {
      receiveCtrl.selectContacts = [{} as LooseObject];
      receiveCtrl.myText = 'xxxx';
      ConversationController.getInstance().isRcsMms = true;
      mocker.mockFunc(receiveCtrl, receiveCtrl.showUpperLimitToast);

      await receiveCtrl.clickToContacts(() => {
      });
      expect(receiveCtrl.myText).assertEqual('xxxx');
    })

    it('ReceiveControllerTest_clickToContacts_isRcsMms_false_1000', 0, async () => {
      receiveCtrl.selectContacts.length = 1000;
      receiveCtrl.myText = 'xxxx';
      ConversationController.getInstance().isRcsMms = false;
      mocker.mockFunc(receiveCtrl, receiveCtrl.showUpperLimitToast);

      await receiveCtrl.clickToContacts(() => {
      });
      expect(receiveCtrl.myText).assertEqual('xxxx');
    })

    it('ReceiveControllerTest_clickToContacts_isRcsMms_false_0', 0, async () => {
      receiveCtrl.selectContacts = [];
      receiveCtrl.myText = 'xxxx';
      ConversationController.getInstance().isRcsMms = false;
      mocker.mockFunc(receiveCtrl, receiveCtrl.showUpperLimitToast);
      mocker.mockFunc(receiveCtrl, receiveCtrl.jumpToContactForResult);

      await receiveCtrl.clickToContacts(() => {
      });

      expect(receiveCtrl.myText).assertEqual('xxxx');
    })

    it('ReceiveControllerTest_titleBarAvatar', 0, () => {
      mocker.mockFunc(receiveCtrl, receiveCtrl.jumpToContact);
      receiveCtrl.titleBarAvatar(1);
      expect(receiveCtrl.isInputStatus).assertTrue();
    })

    it('ReceiveControllerTest_jumpToContact', 0, () => {
      when(mocker.mockFunc(commonService, commonService.commonContactParam))(ArgumentMatchers.any)
        .afterReturn('');
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))(ArgumentMatchers.any)
        .afterReturn({
          startAbility: (want: Want, options?: StartOptions | undefined): Promise<void> =>
          new Promise<void>(resolve => resolve())
        } as myCommon.UIAbilityContext);
      let actionData: LooseObject = {};

      receiveCtrl.jumpToContact(actionData);

      expect(receiveCtrl.isInputStatus).assertTrue();

      mocker.clear(commonService);
      mocker.clear(GlobalContext.getContext());
    })

    it('ReceiveControllerTest_jumpToContact_catch', 0, () => {
      when(mocker.mockFunc(commonService, commonService.commonContactParam))(ArgumentMatchers.any)
        .afterReturn('');
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))(ArgumentMatchers.any)
        .afterReturn({
          startAbility: (want: Want, options?: StartOptions | undefined): Promise<void> =>
          new Promise<void>((resolve: () => void, reject: (res: BusinessError) => void) => reject({
            code: -1, message: 'error'
          } as BusinessError))
        } as myCommon.UIAbilityContext);
      let actionData: LooseObject = {};

      receiveCtrl.jumpToContact(actionData);

      expect(receiveCtrl.isInputStatus).assertTrue();

      mocker.clear(commonService);
      mocker.clear(GlobalContext.getContext());
    })

    it('ReceiveControllerTest_jumpToContactForResult', 0, async () => {
      let params: LooseObject = [{
        contactName: 'name',
        telephone: '11111',
        rawContactId: '0',
        contactId: '0'
      }];
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('mmsContext')
        .afterReturn({
          startAbilityForResult: (want: Want, options?: StartOptions | undefined): Promise<ability.AbilityResult> =>
          new Promise<ability.AbilityResult>(resolve => resolve({
            resultCode: -1, want: {
              parameters: {
                'contactObjects': JSON.stringify(params)
              } as Record<string, Object> | undefined
            } as Want
          } as ability.AbilityResult))
        } as Object | window.WindowStage);

      let actionData: LooseObject = {};
      await receiveCtrl.jumpToContactForResult(actionData, () => {
      });
      expect(receiveCtrl.isInputStatus).assertTrue();

      mocker.clear(GlobalContext.getContext());
    })

    it('ReceiveControllerTest_jumpToContactForResult_resultCode_0', 0, async () => {
      ConversationController.getInstance().isRcsMms = true;
      let params: LooseObject = [{
        contactName: 'name',
        telephone: '11111',
        rawContactId: '0',
        contactId: '0'
      }];
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('mmsContext')
        .afterReturn({
          startAbilityForResult: (want: Want, options?: StartOptions | undefined): Promise<ability.AbilityResult> =>
          new Promise<ability.AbilityResult>(resolve => resolve({
            resultCode: 0, want: {
              parameters: {
                'contactObjects': JSON.stringify(params)
              } as Record<string, Object> | undefined
            } as Want
          } as ability.AbilityResult))
        } as Object | window.WindowStage);
      let actionData: LooseObject = {};
      when(mocker.mockFunc(commonService, commonService.commonContactParam))(ArgumentMatchers.any)
        .afterReturn('');
      mocker.mockFunc(receiveCtrl, receiveCtrl.deleteRepetitionContacts);
      mocker.mockFunc(receiveCtrl, receiveCtrl.setInputStatus);
      mocker.mockFunc(receiveCtrl, receiveCtrl.setContactValue);
      mocker.mockFunc(TelephoneUtil, TelephoneUtil.formatDisplayPhoneNum);

      await receiveCtrl.jumpToContactForResult(actionData, () => {
      });
      expect(receiveCtrl.isInputStatus).assertTrue();

      mocker.clear(TelephoneUtil);
      mocker.clear(GlobalContext.getContext());
    })

    it('ReceiveControllerTest_batchSelectContactForResult_resultCode_0', 0, () => {
      let params: LooseObject = [{
        contactName: 'name',
        telephone: '11111',
        rawContactId: '0',
        contactId: '0'
      }];
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('mmsContext')
        .afterReturn({
          startAbilityForResult: (want: Want, options?: StartOptions | undefined): Promise<ability.AbilityResult> =>
          new Promise<ability.AbilityResult>(resolve => resolve({
            resultCode: 0, want: {
              parameters: {
                'contactObjects': JSON.stringify(params)
              } as Record<string, Object> | undefined
            } as Want
          } as ability.AbilityResult))
        } as Object | window.WindowStage);
      when(mocker.mockFunc(commonService, commonService.commonContactParam))(ArgumentMatchers.any)
        .afterReturn('');
      mocker.mockFunc(receiveCtrl, receiveCtrl.deleteRepetitionContacts);
      mocker.mockFunc(receiveCtrl, receiveCtrl.setInputStatus);
      mocker.mockFunc(receiveCtrl, receiveCtrl.setContactValue);
      mocker.mockFunc(TelephoneUtil, TelephoneUtil.formatDisplayPhoneNum);

      let actionData: LooseObject = {
        resultCode: 0
      } as LooseObject;
      receiveCtrl.batchSelectContactForResult(actionData, () => {
      });
      expect(receiveCtrl.isFromContactPage).assertFalse();

      mocker.clear(TelephoneUtil);
      mocker.clear(GlobalContext.getContext());
    })

    it('ReceiveControllerTest_batchSelectContactForResult_resultCode_0_getMaxOneToManyRecipients_0', 0, () => {
      let params: LooseObject = [{
        contactName: 'name',
        telephone: '11111',
        rawContactId: '0',
        contactId: '0'
      }];
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('mmsContext')
        .afterReturn({
          startAbilityForResult: (want: Want, options?: StartOptions | undefined): Promise<ability.AbilityResult> =>
          new Promise<ability.AbilityResult>(resolve => resolve({
            resultCode: 0, want: {
              parameters: {
                'contactObjects': JSON.stringify(params)
              } as Record<string, Object> | undefined
            } as Want
          } as ability.AbilityResult))
        } as Object | window.WindowStage);
      when(mocker.mockFunc(commonService, commonService.commonContactParam))(ArgumentMatchers.any)
        .afterReturn('');
      mocker.mockFunc(receiveCtrl, receiveCtrl.deleteRepetitionContacts);
      mocker.mockFunc(receiveCtrl, receiveCtrl.setInputStatus);
      mocker.mockFunc(receiveCtrl, receiveCtrl.setContactValue);
      mocker.mockFunc(TelephoneUtil, TelephoneUtil.formatDisplayPhoneNum);

      let actionData: LooseObject = {
        resultCode: 0
      } as LooseObject;
      receiveCtrl.batchSelectContactForResult(actionData, () => {
      });
      expect(receiveCtrl.isFromContactPage).assertFalse();

      mocker.clear(TelephoneUtil);
      mocker.clear(GlobalContext.getContext());
    })

    it('ReceiveControllerTest_batchSelectContactForResult_code_0', 0, () => {
      let params: LooseObject = [{
        contactName: 'name',
        telephone: '11111',
        rawContactId: '0',
        contactId: '0'
      }];
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('mmsContext')
        .afterReturn({
          startAbilityForResult: (want: Want, options?: StartOptions | undefined): Promise<ability.AbilityResult> =>
          new Promise<ability.AbilityResult>(resolve => resolve({
            resultCode: 0, want: {
              parameters: {
                'contactObjects': JSON.stringify(params)
              } as Record<string, Object> | undefined
            } as Want
          } as ability.AbilityResult))
        } as Object | window.WindowStage);
      when(mocker.mockFunc(commonService, commonService.commonContactParam))(ArgumentMatchers.any)
        .afterReturn('');
      mocker.mockFunc(receiveCtrl, receiveCtrl.deleteRepetitionContacts);
      mocker.mockFunc(receiveCtrl, receiveCtrl.setInputStatus);
      mocker.mockFunc(receiveCtrl, receiveCtrl.setContactValue);
      mocker.mockFunc(TelephoneUtil, TelephoneUtil.formatDisplayPhoneNum);

      let actionData: LooseObject = {
        code: 0
      } as LooseObject;
      receiveCtrl.batchSelectContactForResult(actionData, () => {
      });
      expect(receiveCtrl.isFromContactPage).assertFalse();

      mocker.clear(TelephoneUtil);
      mocker.clear(GlobalContext.getContext());
    })

    it('ReceiveControllerTest_batchSelectContactForResult', 0, () => {
      let actionData: LooseObject = {};
      receiveCtrl.batchSelectContactForResult(actionData, () => {
      });
      expect(receiveCtrl.isInputStatus).assertTrue();
    })

    it('ReceiveControllerTest_batchSelectContactForResult_length_9', 0, () => {
      let actionData: LooseObject = {
        length: 9
      } as LooseObject;
      receiveCtrl.batchSelectContactForResult(actionData, () => {
      });
      expect(receiveCtrl.isInputStatus).assertTrue();
    })

    it('ReceiveControllerTest_contactsDeduplication', 0, () => {
      let selectContacts: LooseObject[] = [{}];
      let contacts: LooseObject[] = [{}];
      receiveCtrl.contactsDeduplication(selectContacts, contacts);
      expect(receiveCtrl.isInputStatus).assertTrue();
    })


    it('ReceiveControllerTest_deleteRepetitionContacts_true', 0, () => {
      let contacts: LooseObject[] = [];
      let selectContacts: LooseObject[] = [{
        telephone: '11111'
      }];
      when(mocker.mockFunc(TelephoneUtil, isSameTel))(ArgumentMatchers.any)
        .afterReturn(true);
      when(mocker.mockFunc(receiveCtrl, receiveCtrl.contactsDeduplication))(ArgumentMatchers.any)
        .afterReturn(contacts);

      receiveCtrl.deleteRepetitionContacts(selectContacts, contacts);

      expect(receiveCtrl.isInputStatus).assertTrue();

      mocker.clear(TelephoneUtil);
    })

    it('ReceiveControllerTest_deleteRepetitionContacts_false', 0, () => {
      let contacts: LooseObject[] = [];
      let selectContacts: LooseObject[] = [{
        telephone: '11111'
      }];
      when(mocker.mockFunc(TelephoneUtil, isSameTel))(ArgumentMatchers.any)
        .afterReturn(false);
      when(mocker.mockFunc(receiveCtrl, receiveCtrl.contactsDeduplication))(ArgumentMatchers.any)
        .afterReturn(contacts);

      receiveCtrl.deleteRepetitionContacts(selectContacts, contacts);

      expect(receiveCtrl.isInputStatus).assertTrue();

      mocker.clear(TelephoneUtil);
    })

    it('ReceiveControllerTest_showUpperLimitToast', 0, () => {
      let message: Resource = $r('app.string.rcs_file_name_extra_long');
      mocker.mockFunc(receiveCtrl, receiveCtrl.setInputStatus);

      receiveCtrl.showUpperLimitToast(message);

      expect(receiveCtrl.isShowSearch).assertFalse();

    })

    it('ReceiveControllerTest_InputTextClear', 0, () => {
      mocker.mockFunc(receiveCtrl, receiveCtrl.setInputStatus);

      receiveCtrl.InputTextClear();
      expect(receiveCtrl.isInputStatus).assertTrue();

    })

    it('ReceiveControllerTest_setIsShowSearch', 0, () => {
      receiveCtrl.setIsShowSearch(true);
      expect(receiveCtrl.isShowSearch).assertTrue();
    })

    it('ReceiveControllerTest_setContacts', 0, () => {
      receiveCtrl.setContacts([]);
      expect(receiveCtrl.contacts.length).assertEqual(0);
    })

    it('ReceiveControllerTest_dealRefreshContact_length_1_success', 0, () => {
      receiveCtrl.selectContacts = [{
        select: true,
        telephone: '111111'
      } as LooseObject];


      let myset: DataShareResultSet = new MySet();
      myset.rowCount = 1;
      when(mocker.mockFunc(DataShareHelper.getInstance(),
        DataShareHelper.getInstance().initContactDB))(ArgumentMatchers.any)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve(myset))
        } as dataShare.DataShareHelper)));
      mocker.mockFunc(receiveCtrl, receiveCtrl.queryRecentContacts);
      mocker.mockFunc(receiveCtrl, receiveCtrl.setInputStatus);

      receiveCtrl.dealRefreshContact(context);

      expect(receiveCtrl.contacts.length).assertEqual(0);
    })

    it('ReceiveControllerTest_dealRefreshContact_length_1_fail', 0, () => {
      receiveCtrl.selectContacts = [{
        select: true,
        telephone: '111111'
      } as LooseObject];


      let myset: DataShareResultSet = new MySet();
      myset.rowCount = 1;
      when(mocker.mockFunc(DataShareHelper.getInstance(),
        DataShareHelper.getInstance().initContactDB))(ArgumentMatchers.any)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({}as dataShare.DataShareHelper)));
      mocker.mockFunc(receiveCtrl, receiveCtrl.queryRecentContacts);
      mocker.mockFunc(receiveCtrl, receiveCtrl.setInputStatus);

      receiveCtrl.dealRefreshContact(context);

      expect(receiveCtrl.contacts.length).assertEqual(0);
    })

    it('ReceiveControllerTest_dealRefreshContact_length_0', 0, () => {
      receiveCtrl.selectContacts = [];
      receiveCtrl.dealRefreshContact(context);

      expect(receiveCtrl.contacts.length).assertEqual(0);
    })

    it('ReceiveControllerTest_selectContactsByPicker', 0, () => {
      receiveCtrl.selectContactsByPicker();
      expect(receiveCtrl.contacts.length).assertEqual(0);
    })

    it('ReceiveControllerTest_jumpToContactForResultForMore', 0, async () => {
      receiveCtrl.myText = '';
      when(mocker.mockFunc(commonService, commonService.commonContactParam))(ArgumentMatchers.any)
        .afterReturn('');
      let params: LooseObject = [{
        contactName: 'name',
        telephone: '11111',
        rawContactId: '0',
        contactId: '0'
      }];
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('mmsContext')
        .afterReturn({
          startAbilityForResult: (want: Want, options?: StartOptions | undefined): Promise<ability.AbilityResult> =>
          new Promise<ability.AbilityResult>(resolve => resolve({
            resultCode: 0,
            want: {
              parameters: {
                'contactObjects': JSON.stringify(params)
              } as Record<string, Object> | undefined
            } as Want
          } as ability.AbilityResult))
        } as Object | window.WindowStage);

      await receiveCtrl.jumpToContactForResultForMore((res: callType) => {
        expect(res.contactValue).assertEqual('');
      });
      mocker.clear(commonService);
      mocker.clear(GlobalContext.getContext());
    })

    it('ReceiveControllerTest_jumpToContactForResultForMore_catch', 0, async () => {
      receiveCtrl.myText = '';
      when(mocker.mockFunc(commonService, commonService.commonContactParam))(ArgumentMatchers.any)
        .afterReturn('');
      let params: LooseObject = [{
        contactName: 'name',
        telephone: '11111',
        rawContactId: '0',
        contactId: '0'
      }];
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('mmsContext')
        .afterReturn({
          startAbilityForResult: (want: Want, options?: StartOptions | undefined): Promise<ability.AbilityResult> =>
          new Promise<ability.AbilityResult>(resolve => resolve({
            resultCode: 0,
            want: {
              parameters: {
                'contactObjects': JSON.stringify(params)
              } as Record<string, Object> | undefined
            } as Want
          } as ability.AbilityResult))
        } as Object | window.WindowStage);
      when(mocker.mockFunc(JSON, JSON.parse))(ArgumentMatchers.any)
        .afterThrow('error');

      await receiveCtrl.jumpToContactForResultForMore((res: callType) => {
      });

      expect(receiveCtrl.contacts.length).assertEqual(0);

      mocker.clear(commonService);
      mocker.clear(GlobalContext.getContext());
      mocker.clear(JSON);
    })

    it('ReceiveControllerTest_jumpToFileManagementForResultForMore', 0, async () => {
      await receiveCtrl.jumpToFileManagementForResultForMore(true,
        new CreateNewConversationViewModle(), ConversationController.getInstance(),
        (res: rcsFileInfo) => {
          expect(res.name).assertEqual('');
        }, () => {});
    })
  })
}