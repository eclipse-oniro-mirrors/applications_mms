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
import { beforeEach, describe, expect, it, MockKit, when } from '@ohos/hypium';
import LooseObject from '../../../../main/ets/data/LooseObject';
import ContactsModel from '../../../../main/ets/model/ContactsModel';
import { DTGlobalContext } from '../../testability/TestAbility';
import DataShareHelper from '../../../../main/ets/model/repository/DataShareHelper';
import { dataShare, dataSharePredicates, DataShareResultSet } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';
import MySet from '../MySet';

export default function contactsModelTest() {
  describe('contactsModelTest', () => {

    let contactsModel: ContactsModel;

    beforeEach(() => {
      contactsModel = new ContactsModel();
    })

    it('contactsModelTest_queryContactDataByCondition_if1_if2', 0, async () => {
      let mocker: MockKit = new MockKit();
      let actionData: LooseObject = {
        'hasDelete': '',
        'contactIds': ['1'],
        'telephones': ['570977632'],
        'page': 1,
        'limit': 1,
        'searchName': 'roxy',
        'transmitSearchInput': 'hi',
        'startUpdateTime': '',
        'endUpdateTime': ''
      };
      let callback: Function = (result: LooseObject) => {
        expect(JSON.stringify(result)).assertEqual('{"code":-1}');
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initContactDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(undefined)));

      await contactsModel.queryContactDataByCondition(actionData, callback, context);

      mocker.clear(DataShareHelper.getInstance());
      mocker.clear(contactsModel);
    })

    it('contactsModelTest_queryContactDataByCondition_if3_buildQueryContactDataCondition_ifs', 0, async () => {
      let mySet:DataShareResultSet = new MySet();
      mySet.rowCount = 1;

      let mocker: MockKit = new MockKit();
      let actionData: LooseObject = {
        'hasDelete': '',
        'contactIds': ['1'],
        'telephones': ['570977632'],
        'page': 1,
        'limit': 1,
        'searchName': 'roxy',
        'transmitSearchInput': 'hi',
        'startUpdateTime': '0',
        'endUpdateTime': '0'
      };
      let callback: Function = (result: LooseObject) => {
        expect(result.code).assertEqual(0);
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initContactDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve(mySet))
        } as dataShare.DataShareHelper)));

      await contactsModel.queryContactDataByCondition(actionData, callback, context);

      mocker.clear(DataShareHelper.getInstance());
      mocker.clear(contactsModel);
    })

    it('contactsModelTest_queryContactDataByCondition_noIf3_buildQueryContactDataCondition_noIfs', 0, async () => {
      let mocker: MockKit = new MockKit();
      let actionData: LooseObject = {
        'hasDelete': null,
        'contactIds': [],
        'telephones': [],
        'page': null,
        'limit': null,
        'searchName': '',
        'transmitSearchInput': '',
        'startUpdateTime': null,
        'endUpdateTime': null
      };
      let callback: Function = (result: LooseObject) => {
        expect(result.code).assertEqual(0);
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initContactDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve(new MySet()))
        } as dataShare.DataShareHelper)));

      await contactsModel.queryContactDataByCondition(actionData, callback, context);

      mocker.clear(DataShareHelper.getInstance());
      mocker.clear(contactsModel);
    })

    it('contactsModelTest_queryContactDataByCondition_businessError', 0, async () => {
      let mocker: MockKit = new MockKit();
      let actionData: LooseObject = {
        'hasDelete': null,
        'contactIds': [],
        'telephones': [],
        'page': null,
        'limit': null,
        'searchName': '',
        'transmitSearchInput': '',
        'startUpdateTime': null,
        'endUpdateTime': null
      };
      let callback: Function = (result: LooseObject) => {
        expect(JSON.stringify(result)).assertEqual('{"code":-1}');
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initContactDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>((resolve: (value: DataShareResultSet | PromiseLike<DataShareResultSet>) => void, reject: (reason?: BusinessError) => void) =>
          reject({
            code: 1, message: 'error'
          } as BusinessError))
        } as dataShare.DataShareHelper)));

      await contactsModel.queryContactDataByCondition(actionData, callback, context);

      mocker.clear(DataShareHelper.getInstance());
      mocker.clear(contactsModel);
    })

    it('contactsModelTest_queryCallLogByCondition_if1_if2', 0, async () => {
      let mocker: MockKit = new MockKit();
      let actionData: LooseObject = {
        'phoneNumber': '570977632',
      };
      let callback: Function = (result: LooseObject) => {
        expect(JSON.stringify(result)).assertEqual('{"code":-1}');
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initCallLogDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(undefined)));

      await contactsModel.queryCallLogByCondition(actionData, callback, context);

      mocker.clear(DataShareHelper.getInstance());
      mocker.clear(contactsModel);
    })

    it('contactsModelTest_queryCallLogByCondition_if3', 0, async () => {
      let mySet:DataShareResultSet = new MySet();
      mySet.rowCount = 1;

      let mocker: MockKit = new MockKit();
      let actionData: LooseObject = {
        'phoneNumber': '570977632',
      };
      let callback: Function = (result: LooseObject) => {
        expect(result.code).assertEqual(0);
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initCallLogDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve(mySet))
        } as dataShare.DataShareHelper)));

      await contactsModel.queryCallLogByCondition(actionData, callback, context);

      mocker.clear(DataShareHelper.getInstance());
      mocker.clear(contactsModel);
    })

    it('contactsModelTest_queryCallLogByCondition_businessError', 0, async () => {
      let mocker: MockKit = new MockKit();
      let actionData: LooseObject = {
        'phoneNumber': '570977632',
      };
      let callback: Function = (result: LooseObject) => {
        expect(JSON.stringify(result)).assertEqual('{"code":-1}');
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initCallLogDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>((resolve: (value: DataShareResultSet | PromiseLike<DataShareResultSet>) => void, reject: (reason?: BusinessError) => void) =>
          reject({
            code: 1, message: 'error'
          } as BusinessError))
        } as dataShare.DataShareHelper)));

      await contactsModel.queryCallLogByCondition(actionData, callback, context);

      mocker.clear(DataShareHelper.getInstance());
      mocker.clear(contactsModel);
    })

    it('contactsModelTest_queryContactDataSizeByCondition_if1_if2', 0, async () => {
      let mocker: MockKit = new MockKit();
      let actionData: LooseObject = {
        'hasDelete': '',
        'contactIds': ['1'],
        'telephones': ['570977632'],
        'page': 1,
        'limit': 1,
        'searchName': 'roxy',
        'transmitSearchInput': 'hi',
        'startUpdateTime': '',
        'endUpdateTime': ''
      };
      let callback: Function = (result: LooseObject) => {
        expect(JSON.stringify(result)).assertEqual('{"code":-1}');
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initContactDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(undefined)));

      await contactsModel.queryContactDataSizeByCondition(actionData, callback, context);

      mocker.clear(DataShareHelper.getInstance());
      mocker.clear(contactsModel);
    })

    it('contactsModelTest_queryContactDataSizeByCondition_if3_buildQueryContactDataCondition_ifs', 0, async () => {
      let mySet:DataShareResultSet = new MySet();
      mySet.rowCount = 1;

      let mocker: MockKit = new MockKit();
      let actionData: LooseObject = {
        'hasDelete': '',
        'contactIds': ['1'],
        'telephones': ['570977632'],
        'page': 1,
        'limit': 1,
        'searchName': 'roxy',
        'transmitSearchInput': 'hi',
        'startUpdateTime': '0',
        'endUpdateTime': '0'
      };
      let callback: Function = (result: LooseObject) => {
        expect(result.code).assertEqual(0);
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initContactDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve(mySet))
        } as dataShare.DataShareHelper)));

      await contactsModel.queryContactDataSizeByCondition(actionData, callback, context);

      mocker.clear(DataShareHelper.getInstance());
      mocker.clear(contactsModel);
    })

    it('contactsModelTest_queryContactDataSizeByCondition_noIf3_buildQueryContactDataCondition_noIfs', 0, async () => {
      let mocker: MockKit = new MockKit();
      let actionData: LooseObject = {
        'hasDelete': null,
        'contactIds': [],
        'telephones': [],
        'page': null,
        'limit': null,
        'searchName': '',
        'transmitSearchInput': '',
        'startUpdateTime': null,
        'endUpdateTime': null
      };
      let callback: Function = (result: LooseObject) => {
        expect(result.code).assertEqual(0);
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initContactDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve(new MySet()))
        } as dataShare.DataShareHelper)));

      await contactsModel.queryContactDataSizeByCondition(actionData, callback, context);

      mocker.clear(DataShareHelper.getInstance());
      mocker.clear(contactsModel);
    })

    it('contactsModelTest_queryContactDataSizeByCondition_businessError', 0, async () => {
      let mocker: MockKit = new MockKit();
      let actionData: LooseObject = {
        'hasDelete': null,
        'contactIds': [],
        'telephones': [],
        'page': null,
        'limit': null,
        'searchName': '',
        'transmitSearchInput': '',
        'startUpdateTime': null,
        'endUpdateTime': null
      };
      let callback: Function = (result: LooseObject) => {
        expect(JSON.stringify(result)).assertEqual('{"code":-1}');
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initContactDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>((resolve: (value: DataShareResultSet | PromiseLike<DataShareResultSet>) => void, reject: (reason?: BusinessError) => void) =>
          reject({
            code: 1, message: 'error'
          } as BusinessError))
        } as dataShare.DataShareHelper)));

      await contactsModel.queryContactDataSizeByCondition(actionData, callback, context);

      mocker.clear(DataShareHelper.getInstance());
      mocker.clear(contactsModel);
    })

    it('contactsModelTest_queryContactByCondition_if1_if2', 0, async () => {
      let mocker: MockKit = new MockKit();
      let actionData: LooseObject = {
        'telephone': '570977632',
        'page': 1,
        'limit': 1,
        'orderByTimeDesc': ''
      };
      let callback: Function = (result: LooseObject) => {
        expect(JSON.stringify(result)).assertEqual('{"code":-1}');
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initContactDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(undefined)));

      await contactsModel.queryContactByCondition(actionData, callback, context);

      mocker.clear(DataShareHelper.getInstance());
      mocker.clear(contactsModel);
    })

    it('contactsModelTest_queryContactByCondition_if3_buildQueryContactDataCondition_ifs', 0, async () => {
      let mySet:DataShareResultSet = new MySet();
      mySet.rowCount = 1;

      let mocker: MockKit = new MockKit();
      let actionData: LooseObject = {
        'telephone': '570977632',
        'page': 1,
        'limit': 1,
        'orderByTimeDesc': ''
      };
      let callback: Function = (result: LooseObject) => {
        expect(result.code).assertEqual(0);
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initContactDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve(mySet))
        } as dataShare.DataShareHelper)));

      await contactsModel.queryContactByCondition(actionData, callback, context);

      mocker.clear(DataShareHelper.getInstance());
      mocker.clear(contactsModel);
    })

    it('contactsModelTest_queryContactByCondition_noIf3_buildQueryContactDataCondition_noIfs', 0, async () => {
      let mocker: MockKit = new MockKit();
      let actionData: LooseObject = {
        'telephone': null,
        'page': null,
        'limit': null,
        'orderByTimeDesc': null
      };
      let callback: Function = (result: LooseObject) => {
        expect(result.code).assertEqual(0);
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initContactDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve(new MySet()))
        } as dataShare.DataShareHelper)));

      await contactsModel.queryContactByCondition(actionData, callback, context);

      mocker.clear(DataShareHelper.getInstance());
      mocker.clear(contactsModel);
    })

    it('contactsModelTest_queryContactByCondition_businessError', 0, async () => {
      let mocker: MockKit = new MockKit();
      let actionData: LooseObject = {
        'hasDelete': null,
        'contactIds': [],
        'telephones': [],
        'page': null,
        'limit': null,
        'searchName': '',
        'transmitSearchInput': '',
        'startUpdateTime': null,
        'endUpdateTime': null
      };
      let callback: Function = (result: LooseObject) => {
        expect(JSON.stringify(result)).assertEqual('{"code":-1}');
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initContactDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>((resolve: (value: DataShareResultSet | PromiseLike<DataShareResultSet>) => void, reject: (reason?: BusinessError) => void) =>
          reject({
            code: 1, message: 'error'
          } as BusinessError))
        } as dataShare.DataShareHelper)));

      await contactsModel.queryContactByCondition(actionData, callback, context);

      mocker.clear(DataShareHelper.getInstance());
      mocker.clear(contactsModel);
    })

    it('contactsModelTest_queryContactSizeByCondition_if1_if2', 0, async () => {
      let mocker: MockKit = new MockKit();
      let actionData: LooseObject = {
        'telephone': '570977632',
        'page': 1,
        'limit': 1,
        'orderByTimeDesc': ''
      };
      let callback: Function = (result: LooseObject) => {
        expect(JSON.stringify(result)).assertEqual('{"code":-1}');
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initContactDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(undefined)));

      await contactsModel.queryContactSizeByCondition(actionData, callback, context);

      mocker.clear(DataShareHelper.getInstance());
      mocker.clear(contactsModel);
    })

    it('contactsModelTest_queryContactSizeByCondition_if3_buildQueryContactDataCondition_ifs', 0, async () => {
      let mySet:DataShareResultSet = new MySet();
      mySet.rowCount = 1;

      let mocker: MockKit = new MockKit();
      let actionData: LooseObject = {
        'telephone': '570977632',
        'page': 1,
        'limit': 1,
        'orderByTimeDesc': ''
      };
      let callback: Function = (result: LooseObject) => {
        expect(result.code).assertEqual(0);
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initContactDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve(mySet))
        } as dataShare.DataShareHelper)));

      await contactsModel.queryContactSizeByCondition(actionData, callback, context);

      mocker.clear(DataShareHelper.getInstance());
      mocker.clear(contactsModel);
    })

    it('contactsModelTest_queryContactSizeByCondition_noIf3_buildQueryContactDataCondition_noIfs', 0, async () => {
      let mocker: MockKit = new MockKit();
      let actionData: LooseObject = {
        'telephone': null,
        'page': null,
        'limit': null,
        'orderByTimeDesc': null
      };
      let callback: Function = (result: LooseObject) => {
        expect(result.code).assertEqual(0);
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initContactDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve(new MySet()))
        } as dataShare.DataShareHelper)));

      await contactsModel.queryContactSizeByCondition(actionData, callback, context);

      mocker.clear(DataShareHelper.getInstance());
      mocker.clear(contactsModel);
    })

    it('contactsModelTest_queryContactSizeByCondition_businessError', 0, async () => {
      let mocker: MockKit = new MockKit();
      let actionData: LooseObject = {
        'telephone': null,
        'page': null,
        'limit': null,
        'orderByTimeDesc': null
      };
      let callback: Function = (result: LooseObject) => {
        expect(JSON.stringify(result)).assertEqual('{"code":-1}');
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initContactDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>((resolve: (value: DataShareResultSet | PromiseLike<DataShareResultSet>) => void, reject: (reason?: BusinessError) => void) =>
          reject({
            code: 1, message: 'error'
          } as BusinessError))
        } as dataShare.DataShareHelper)));

      await contactsModel.queryContactSizeByCondition(actionData, callback, context);

      mocker.clear(DataShareHelper.getInstance());
      mocker.clear(contactsModel);
    })

    it('contactsModelTest_queryRawContactSizeByCondition_if1_if2', 0, async () => {
      let mocker: MockKit = new MockKit();
      let actionData: LooseObject = {};
      let callback: Function = (result: LooseObject) => {
        expect(JSON.stringify(result)).assertEqual('{"code":-1}');
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initContactDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(undefined)));

      await contactsModel.queryRawContactSizeByCondition(actionData, callback, context);

      mocker.clear(DataShareHelper.getInstance());
      mocker.clear(contactsModel);
    })

    it('contactsModelTest_queryRawContactSizeByCondition', 0, async () => {
      let mySet:DataShareResultSet = new MySet();
      mySet.rowCount = 1;

      let mocker: MockKit = new MockKit();
      let actionData: LooseObject = {};
      let callback: Function = (result: LooseObject) => {
        expect(result.code).assertEqual(0);
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initContactDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve(mySet))
        } as dataShare.DataShareHelper)));

      await contactsModel.queryRawContactSizeByCondition(actionData, callback, context);

      mocker.clear(DataShareHelper.getInstance());
      mocker.clear(contactsModel);
    })

    it('contactsModelTest_queryRawContactSizeByCondition_businessError', 0, async () => {
      let mocker: MockKit = new MockKit();
      let actionData: LooseObject = {};
      let callback: Function = (result: LooseObject) => {
        expect(JSON.stringify(result)).assertEqual('{"code":-1}');
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initContactDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>((resolve: (value: DataShareResultSet | PromiseLike<DataShareResultSet>) => void, reject: (reason?: BusinessError) => void) =>
          reject({
            code: 1, message: 'error'
          } as BusinessError))
        } as dataShare.DataShareHelper)));

      await contactsModel.queryRawContactSizeByCondition(actionData, callback, context);

      mocker.clear(DataShareHelper.getInstance());
      mocker.clear(contactsModel);
    })

    it('contactsModelTest_queryRecentContactByRow_if1_if2', 0, async () => {
      let mocker: MockKit = new MockKit();
      let actionData: LooseObject = {
        'type': 'recent_contacts'
      };
      let callback: Function = (result: LooseObject) => {
        expect(JSON.stringify(result)).assertEqual('{"code":-1}');
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initContactDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(undefined)));

      await contactsModel.queryRecentContactByRow(actionData, callback, context);

      mocker.clear(DataShareHelper.getInstance());
      mocker.clear(contactsModel);
    })

    it('contactsModelTest_queryRecentContactByRow_if3_buildQueryRecentContactByRowCondition_case', 0, async () => {
      let mySet:DataShareResultSet = new MySet();
      mySet.rowCount = 1;

      let mocker: MockKit = new MockKit();
      let actionData: LooseObject = {
        'type': 'recent_contacts'
      };
      let callback: Function = (result: LooseObject) => {
        expect(result.code).assertEqual(0);
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initContactDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve(mySet))
        } as dataShare.DataShareHelper)));

      await contactsModel.queryRecentContactByRow(actionData, callback, context);

      mocker.clear(DataShareHelper.getInstance());
      mocker.clear(contactsModel);
    })

    it('contactsModelTest_queryRecentContactByRow_noIf3_buildQueryRecentContactByRowCondition_default', 0, async () => {
      let mocker: MockKit = new MockKit();
      let actionData: LooseObject = {
        'type': 'raw_recent_contacts'
      };
      let callback: Function = (result: LooseObject) => {
        expect(result.code).assertEqual(0);
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initContactDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve(new MySet()))
        } as dataShare.DataShareHelper)));

      await contactsModel.queryRecentContactByRow(actionData, callback, context);

      mocker.clear(DataShareHelper.getInstance());
      mocker.clear(contactsModel);
    })

    it('contactsModelTest_queryRecentContactByRow_businessError', 0, async () => {
      let mocker: MockKit = new MockKit();
      let actionData: LooseObject = {
        'type': 'raw_recent_contacts'
      };
      let callback: Function = (result: LooseObject) => {
        expect(JSON.stringify(result)).assertEqual('{"code":-1}');
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initContactDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>((resolve: (value: DataShareResultSet | PromiseLike<DataShareResultSet>) => void, reject: (reason?: BusinessError) => void) =>
          reject({
            code: 1, message: 'error'
          } as BusinessError))
        } as dataShare.DataShareHelper)));

      await contactsModel.queryRecentContactByRow(actionData, callback, context);

      mocker.clear(DataShareHelper.getInstance());
      mocker.clear(contactsModel);
    })

    it('contactsModelTest_queryContactViewByCondition_if1_if2', 0, async () => {
      let mocker: MockKit = new MockKit();
      let actionData: LooseObject = {
        'telephone': '570977632',
      };
      let callback: Function = (result: LooseObject) => {
        expect(JSON.stringify(result)).assertEqual('{"code":-1}');
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initContactDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(undefined)));

      await contactsModel.queryContactViewByCondition(actionData, callback, context);

      mocker.clear(DataShareHelper.getInstance());
      mocker.clear(contactsModel);
    })

    it('contactsModelTest_queryContactViewByCondition_if3', 0, async () => {
      let mySet:DataShareResultSet = new MySet();
      mySet.rowCount = 1;

      let mocker: MockKit = new MockKit();
      let actionData: LooseObject = {
        'telephone': '570977632',
      };
      let callback: Function = (result: LooseObject) => {
        expect(result.code).assertEqual(0);
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initContactDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve(mySet))
        } as dataShare.DataShareHelper)));

      await contactsModel.queryContactViewByCondition(actionData, callback, context);

      mocker.clear(DataShareHelper.getInstance());
      mocker.clear(contactsModel);
    })

    it('contactsModelTest_queryContactViewByCondition_noIf3', 0, async () => {
      let mocker: MockKit = new MockKit();
      let actionData: LooseObject = {
        'telephone': '570977632',
      };
      let callback: Function = (result: LooseObject) => {
        expect(result.code).assertEqual(0);
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initContactDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve(new MySet()))
        } as dataShare.DataShareHelper)));

      await contactsModel.queryContactViewByCondition(actionData, callback, context);

      mocker.clear(DataShareHelper.getInstance());
      mocker.clear(contactsModel);
    })

    it('contactsModelTest_queryContactViewByCondition_businessError', 0, async () => {
      let mocker: MockKit = new MockKit();
      let actionData: LooseObject = {
        'telephone': '570977632',
      };
      let callback: Function = (result: LooseObject) => {
        expect(JSON.stringify(result)).assertEqual('{"code":-1}');
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initContactDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>((resolve: (value: DataShareResultSet | PromiseLike<DataShareResultSet>) => void, reject: (reason?: BusinessError) => void) =>
          reject({
            code: 1, message: 'error'
          } as BusinessError))
        } as dataShare.DataShareHelper)));

      await contactsModel.queryContactViewByCondition(actionData, callback, context);

      mocker.clear(DataShareHelper.getInstance());
      mocker.clear(contactsModel);
    })
  })
}