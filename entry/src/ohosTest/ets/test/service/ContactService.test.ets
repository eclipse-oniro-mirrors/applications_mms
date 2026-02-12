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
import { describe, beforeEach, afterEach, it, expect, when, MockKit, ArgumentMatchers } from '@ohos/hypium';
import LooseObject from '../../../../main/ets/data/LooseObject';
import ContactsService from '../../../../main/ets/service/ContactsService';
import { DTGlobalContext } from '../../testability/TestAbility';
import { GlobalContext } from '../../../../main/ets/MainAbility/GlobalHelper';
import { window } from '@kit.ArkUI';
import DataShareHelper from '../../../../main/ets/model/repository/DataShareHelper';
import { dataShare, dataSharePredicates, DataShareResultSet } from '@kit.ArkData';
import myCommon from '@ohos.app.ability.common';
import MySet from '../MySet';
import TelephoneUtil from '../../../../main/ets/utils/TelephoneUtil';

export default function contactsServiceTest() {
  describe('contactsServiceTest', () => {
    let mContactsService: ContactsService;
    let mocker: MockKit;
    let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;

    beforeEach(() => {
      mocker = new MockKit();
      mContactsService = ContactsService.getTestInstance();
    })

    afterEach(() => {
      mocker.clear(mContactsService);
      mocker.clear(GlobalContext.getContext());
      mocker.clear(DataShareHelper.getInstance());
    })

    it('ContactsServiceTest_getInstance', 0, () => {
      expect(typeof mContactsService).assertEqual(typeof ContactsService.getInstance());
    })

    it('contactsServiceTest_queryContactDataByCondition_context', 0, async () => {
      let actionData: LooseObject = {
        "rcsType": 1,
        "rcsId": 1,
        "isMms": false
      };
      let callback: Function = (res: Object) => {
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext;
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            return new Promise<void>(resolve => resolve());
          }
        } as Object | window.WindowStage);
      await mContactsService.queryContactDataByCondition(actionData, callback, context);
      mocker.verify('getObject', ['DataWorker']).times(0);
    })

    it('contactsServiceTest_queryContactDataByCondition_context_null', 0, async () => {
      let actionData: LooseObject = {
        "rcsType": 1,
        "rcsId": 1,
        "isMms": false
      };
      let callback: Function = (res: LooseObject) => {
        expect(res.code).assertEqual(-1);
      };
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn(null);
      when(mocker.mockFunc(DataShareHelper.getInstance(),
        DataShareHelper.getInstance().initContactDB))(ArgumentMatchers.any)
        .afterReturn(new  Promise<dataShare.DataShareHelper | undefined>(resolve => resolve(undefined)));
      await mContactsService.queryContactDataByCondition(actionData, callback, context);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('contactsServiceTest_queryCallLogByCondition_context', 0, async () => {
      let actionData: LooseObject = {
        "rcsType": 1,
        "rcsId": 1,
        "isMms": false
      };
      let callback: Function = (res: Object) => {
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext;
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            return new Promise<void>(resolve => resolve());
          }
        } as Object | window.WindowStage);
      await mContactsService.queryCallLogByCondition(actionData, callback, context);
      mocker.verify('getObject', ['DataWorker']).times(0);
    })

    it('contactsServiceTest_queryCallLogByCondition_context_null', 0, async () => {
      let actionData: LooseObject = {
        "rcsType": 1,
        "rcsId": 1,
        "isMms": false
      };
      let callback: Function = (res: LooseObject) => {
        expect(res.code).assertEqual(-1);
      };
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn(null);
      when(mocker.mockFunc(DataShareHelper.getInstance(),
        DataShareHelper.getInstance().initCallLogDB))(ArgumentMatchers.any)
        .afterReturn(new  Promise<dataShare.DataShareHelper | undefined>(resolve => resolve(undefined)));
      await mContactsService.queryCallLogByCondition(actionData, callback, context);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('contactsServiceTest_queryContactDataSizeByCondition_context', 0, async () => {
      let actionData: LooseObject = {
        "rcsType": 1,
        "rcsId": 1,
        "isMms": false
      };
      let callback: Function = (res: Object) => {
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext;
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            return new Promise<void>(resolve => resolve());
          }
        } as Object | window.WindowStage);
      await mContactsService.queryContactDataSizeByCondition(actionData, callback, context);
      mocker.verify('getObject', ['DataWorker']).times(0);
    })

    it('contactsServiceTest_queryContactDataSizeByCondition_context_null', 0, async () => {
      let actionData: LooseObject = {
        "rcsType": 1,
        "rcsId": 1,
        "isMms": false
      };
      let callback: Function = (res: LooseObject) => {
        expect(res.code).assertEqual(-1);
      };
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn(null);
      when(mocker.mockFunc(DataShareHelper.getInstance(),
        DataShareHelper.getInstance().initContactDB))(ArgumentMatchers.any)
        .afterReturn(new  Promise<dataShare.DataShareHelper | undefined>(resolve => resolve(undefined)));
      await mContactsService.queryContactDataSizeByCondition(actionData, callback, context);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('contactsServiceTest_queryContactByCondition_context', 0, async () => {
      let actionData: LooseObject = {
        "rcsType": 1,
        "rcsId": 1,
        "isMms": false
      };
      let callback: Function = (res: Object) => {
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext;
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            return new Promise<void>(resolve => resolve());
          }
        } as Object | window.WindowStage);
      await mContactsService.queryContactByCondition(actionData, callback, context);
      mocker.verify('getObject', ['DataWorker']).times(0);
    })

    it('contactsServiceTest_queryContactByCondition_context_null', 0, async () => {
      let actionData: LooseObject = {
        "rcsType": 1,
        "rcsId": 1,
        "isMms": false
      };
      let callback: Function = (res: LooseObject) => {
        expect(res.code).assertEqual(-1);
      };
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn(null);
      when(mocker.mockFunc(DataShareHelper.getInstance(),
        DataShareHelper.getInstance().initContactDB))(ArgumentMatchers.any)
        .afterReturn(new  Promise<dataShare.DataShareHelper | undefined>(resolve => resolve(undefined)));
      await mContactsService.queryContactByCondition(actionData, callback, context);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('contactsServiceTest_queryRecentContactByRow_context', 0, async () => {
      let actionData: LooseObject = {
        "rcsType": 1,
        "rcsId": 1,
        "isMms": false
      };
      let callback: Function = (res: Object) => {
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext;
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            return new Promise<void>(resolve => resolve());
          }
        } as Object | window.WindowStage);
      await mContactsService.queryRecentContactByRow(actionData, callback, context);
      mocker.verify('getObject', ['DataWorker']).times(0);
    })

    it('contactsServiceTest_queryRecentContactByRow_context_null', 0, async () => {
      let actionData: LooseObject = {
        "rcsType": 1,
        "rcsId": 1,
        "isMms": false
      };
      let callback: Function = (res: LooseObject) => {
        expect(res.code).assertEqual(-1);
      };
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn(null);
      when(mocker.mockFunc(DataShareHelper.getInstance(),
        DataShareHelper.getInstance().initContactDB))(ArgumentMatchers.any)
        .afterReturn(new  Promise<dataShare.DataShareHelper | undefined>(resolve => resolve(undefined)));
      await mContactsService.queryRecentContactByRow(actionData, callback, context);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('contactsServiceTest_queryContactSizeByCondition_context', 0, async () => {
      let actionData: LooseObject = {
        "rcsType": 1,
        "rcsId": 1,
        "isMms": false
      };
      let callback: Function = (res: Object) => {
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext;
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            return new Promise<void>(resolve => resolve());
          }
        } as Object | window.WindowStage);
      await mContactsService.queryContactSizeByCondition(actionData, callback, context);
      mocker.verify('getObject', ['DataWorker']).times(0);
    })

    it('contactsServiceTest_queryContactSizeByCondition_context_null', 0, async () => {
      let actionData: LooseObject = {
        "rcsType": 1,
        "rcsId": 1,
        "isMms": false
      };
      let callback: Function = (res: LooseObject) => {
        expect(res.code).assertEqual(-1);
      };
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn(null);
      when(mocker.mockFunc(DataShareHelper.getInstance(),
        DataShareHelper.getInstance().initContactDB))(ArgumentMatchers.any)
        .afterReturn(new  Promise<dataShare.DataShareHelper | undefined>(resolve => resolve(undefined)));
      await mContactsService.queryContactSizeByCondition(actionData, callback, context);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('contactsServiceTest_queryRawContactSizeByCondition_context', 0, async () => {
      let actionData: LooseObject = {
        "rcsType": 1,
        "rcsId": 1,
        "isMms": false
      };
      let callback: Function = (res: Object) => {
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext;
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            return new Promise<void>(resolve => resolve());
          }
        } as Object | window.WindowStage);
      await mContactsService.queryRawContactSizeByCondition(actionData, callback, context);
      mocker.verify('getObject', ['DataWorker']).times(0);
    })

    it('contactsServiceTest_queryRawContactSizeByCondition_context_null', 0, async () => {
      let actionData: LooseObject = {
        "rcsType": 1,
        "rcsId": 1,
        "isMms": false
      };
      let callback: Function = (res: LooseObject) => {
        expect(res.code).assertEqual(-1);
      };
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn(null);
      when(mocker.mockFunc(DataShareHelper.getInstance(),
        DataShareHelper.getInstance().initContactDB))(ArgumentMatchers.any)
        .afterReturn(new  Promise<dataShare.DataShareHelper | undefined>(resolve => resolve(undefined)));
      await mContactsService.queryRawContactSizeByCondition(actionData, callback, context);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('contactsServiceTest_queryContactViewByCondition_context', 0, async () => {
      let actionData: LooseObject = {
        "rcsType": 1,
        "rcsId": 1,
        "isMms": false
      };
      let callback: Function = (res: Object) => {
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext;
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            return new Promise<void>(resolve => resolve());
          }
        } as Object | window.WindowStage);
      await mContactsService.queryContactViewByCondition(actionData, callback, context);
      mocker.verify('getObject', ['DataWorker']).times(0);
    })

    it('contactsServiceTest_queryContactViewByCondition_context_null', 0, async () => {
      let actionData: LooseObject = {
        "rcsType": 1,
        "rcsId": 1,
        "isMms": false
      };
      let callback: Function = (res: LooseObject) => {
        expect(res.code).assertEqual(-1);
      };
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn(null);
      when(mocker.mockFunc(DataShareHelper.getInstance(),
        DataShareHelper.getInstance().initContactDB))(ArgumentMatchers.any)
        .afterReturn(new  Promise<dataShare.DataShareHelper | undefined>(resolve => resolve(undefined)));
      await mContactsService.queryContactViewByCondition(actionData, callback, context);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('contactsServiceTest_queryContact_queryContactByCondition_fail', 0, async () => {
      let actionData: LooseObject = {
        "rcsType": 1,
        "rcsId": 1,
        "isMms": false
      };
      let callback: Function = (res: LooseObject) => {
        expect(res.code).assertEqual(-1);
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext;
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn(null);
      when(mocker.mockFunc(DataShareHelper.getInstance(),
        DataShareHelper.getInstance().initContactDB))(ArgumentMatchers.any)
        .afterReturn(new  Promise<dataShare.DataShareHelper | undefined>(resolve => resolve(undefined)));
      mContactsService.queryContact(actionData, callback, context);
    })

    it('contactsServiceTest_queryContact_queryContactDataByCondition', 0, async () => {
      let actionData: LooseObject = {
        "rcsType": 1,
        "rcsId": 1,
        "isMms": false
      };
      let callback: Function = (res: LooseObject) => {
        expect(res.code).assertEqual(0);
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext;
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn(null);
      let mySet: DataShareResultSet = new MySet();
      mySet.rowCount = 1;
      when(mocker.mockFunc(DataShareHelper.getInstance(),
        DataShareHelper.getInstance().initContactDB))(ArgumentMatchers.any)
        .afterReturn(new  Promise<dataShare.DataShareHelper | undefined>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve(mySet))
        } as dataShare.DataShareHelper)));
      mContactsService.queryContact(actionData, callback, context);
    })

    it('contactsServiceTest_queryRecentContact_fail', 0, async () => {
      let callback: Function = (res: LooseObject) => {
        expect(res.code).assertEqual(-1);
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext;
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn(null);
      when(mocker.mockFunc(DataShareHelper.getInstance(),
        DataShareHelper.getInstance().initContactDB))(ArgumentMatchers.any)
        .afterReturn(new  Promise<dataShare.DataShareHelper | undefined>(resolve => resolve(undefined)));
      mContactsService.queryRecentContact(callback, context);
    })

    it('contactsServiceTest_queryRecentContact_success', 0, async () => {
      let callback: Function = (res: LooseObject) => {
        expect(res.code).assertEqual(0);
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext;
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn(null);
      let mySet: DataShareResultSet = new MySet();
      mySet.rowCount = 1;
      when(mocker.mockFunc(DataShareHelper.getInstance(),
        DataShareHelper.getInstance().initContactDB))(ArgumentMatchers.any)
        .afterReturn(new  Promise<dataShare.DataShareHelper | undefined>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve(mySet))
        } as dataShare.DataShareHelper)));
      mContactsService.queryRecentContact(callback, context);
    })

    it('contactsServiceTest_dealContactParams_empty', 0, async () => {
      expect(JSON.stringify(mContactsService.dealContactParams(''))).assertEqual('{}');
    })

    it('contactsServiceTest_dealContactParams_contactName', 0, async () => {
      let item: LooseObject = {
        telephone: '',
        contactName: 'name',
        contactId: ''
      };
      let contactObjects: string = JSON.stringify([item, item]);
      when(mocker.mockFunc(TelephoneUtil, TelephoneUtil.dealTelephoneSort))(ArgumentMatchers.any)
        .afterReturn('570977632');
      expect(mContactsService.dealContactParams(contactObjects).strContactsNumber).assertEqual('570977632');
      mocker.clear(TelephoneUtil);
    })

    it('contactsServiceTest_dealContactParams_contactName_undefined', 0, async () => {
      let item: LooseObject = {
        telephone: '',
        contactId: ''
      };
      let contactObjects: string = JSON.stringify([item, item]);
      when(mocker.mockFunc(TelephoneUtil, TelephoneUtil.dealTelephoneSort))(ArgumentMatchers.any)
        .afterReturn('570977632');
      expect(mContactsService.dealContactParams(contactObjects).strContactsNumber).assertEqual('570977632');
      mocker.clear(TelephoneUtil);
    })

    it('contactsServiceTest_dealContactParams_catch', 0, async () => {
      let item: LooseObject = {
        telephone: '',
        contactId: ''
      };
      let contactObjects: string = JSON.stringify([item]);
      when(mocker.mockFunc(TelephoneUtil, TelephoneUtil.dealTelephoneSort))(ArgumentMatchers.any)
        .afterThrow('error');
      expect(JSON.stringify(mContactsService.dealContactParams(contactObjects))).assertEqual('{}');
      mocker.clear(TelephoneUtil);
    })

    it('contactsServiceTest_judgeContactExist_fail', 0, async () => {
      let actionData: LooseObject = {
        "rcsType": 1,
        "rcsId": 1,
        "isMms": false
      };
      let callback: Function = (res: boolean) => {
        expect(res).assertFalse();
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext;
      when(mocker.mockFunc(DataShareHelper.getInstance(),
        DataShareHelper.getInstance().initContactDB))(ArgumentMatchers.any)
        .afterReturn(new  Promise<dataShare.DataShareHelper | undefined>(resolve => resolve(undefined)));
      mContactsService.judgeContactExist(actionData, callback, context);
    })

    it('contactsServiceTest_judgeContactExist', 0, async () => {
      let actionData: LooseObject = {
        "rcsType": 1,
        "rcsId": 1,
        "isMms": false
      };
      let callback: Function = (res: boolean) => {};
      let context = DTGlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext;
      let mySet: DataShareResultSet = new MySet();
      mySet.rowCount = 1;
      when(mocker.mockFunc(DataShareHelper.getInstance(),
        DataShareHelper.getInstance().initContactDB))(ArgumentMatchers.any)
        .afterReturn(new  Promise<dataShare.DataShareHelper | undefined>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve(mySet))
        } as dataShare.DataShareHelper)));
      mContactsService.judgeContactExist(actionData, callback, context);
      expect(mContactsService).not().assertUndefined();
    })

    it('contactsServiceTest_getStrContactsName', 0, async () => {
      let actionData: LooseObject = {};
      let contactParams: LooseObject = {};
      contactParams.strContactsName = "";
      actionData.telephones = ['123456789'];
      actionData.isFuzzyMatch = true;
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn(null);
      when(mocker.mockFunc(DataShareHelper.getInstance(),
        DataShareHelper.getInstance().initContactDB))(ArgumentMatchers.any)
        .afterReturn(new  Promise<dataShare.DataShareHelper | undefined>(resolve => resolve(undefined)));
      let isError = 0;
      try {
        await mContactsService.getStrContactsName(context, actionData, contactParams);
      } catch (e) {
        isError = 1;
      }
      expect(isError).assertEqual(0);
      mocker.clear(DataShareHelper.getInstance());
    })
  })
}