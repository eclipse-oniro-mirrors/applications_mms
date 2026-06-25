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
import DataShareHelper from '../../../../main/ets/model/repository/DataShareHelper';
import YellowPageModel from '../../../../main/ets/model/yellowPageModel';
import { dataShare, dataSharePredicates, DataShareResultSet } from '@kit.ArkData';
import { DTGlobalContext } from '../../testability/TestAbility';
import LooseObject from '../../../../main/ets/data/LooseObject';
import { BusinessError } from '@kit.BasicServicesKit';
import MySet from '../MySet';

export default function yellowPageModelTest() {
  describe('yellowPageModelTest', () => {

    let yellowPageModel: YellowPageModel;

    beforeEach(() => {
      yellowPageModel = new YellowPageModel();
    })

    it('yellowPageModelTest_queryYellowPageInfoByCondition_dataHelper_undefined', 0, async () => {
      let actionData: LooseObject = {
        'telephone': '570977632'
      };

      let mocker: MockKit = new MockKit();
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initYellowPageDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(undefined)));

      let result: LooseObject = await yellowPageModel.queryYellowPageInfoByCondition(actionData, context);

      expect(result.code).assertEqual(-1);

      mocker.clear(yellowPageModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('yellowPageModelTest_queryYellowPageInfoByCondition_buildQueryYellowPageInfoByCondition_if', 0, async () => {
      let mySet:DataShareResultSet = new MySet();
      mySet.rowCount = 1;
      let actionData: LooseObject = {
        'telephone': '570977632',
        'yellowPageIds':['1'],
        'telephones':['570977632'],
        'page':1,
        'limit':10,
        'searchName':'name',
        'transmitSearchInput':'n',
      };

      let mocker: MockKit = new MockKit();
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initYellowPageDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve(mySet))
        } as dataShare.DataShareHelper)));

      let result: LooseObject = await yellowPageModel.queryYellowPageInfoByCondition(actionData, context);

      expect(result.code).assertEqual(0);

      mocker.clear(yellowPageModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('yellowPageModelTest_queryYellowPageInfoByCondition_buildQueryYellowPageInfoByCondition_noIf', 0, async () => {
      let actionData: LooseObject = {
        'telephone': null,
        'yellowPageIds':[],
        'telephones':null,
        'page':null,
        'limit':null,
        'searchName':null,
        'transmitSearchInput':'',
      };

      let mocker: MockKit = new MockKit();
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initYellowPageDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve(new MySet()))
        } as dataShare.DataShareHelper)));

      let result: LooseObject = await yellowPageModel.queryYellowPageInfoByCondition(actionData, context);

      expect(result.code).assertEqual(0);

      mocker.clear(yellowPageModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('BlockedListModelTest_queryYellowPageInfoByCondition_businessError', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initYellowPageDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>((resolve: (value: DataShareResultSet | PromiseLike<DataShareResultSet>) => void, reject: (reason?: BusinessError) => void) =>
          reject({
            code: 1, message: 'error'
          } as BusinessError))
        } as dataShare.DataShareHelper)));

      let result: LooseObject = await yellowPageModel.queryYellowPageInfoByCondition({}, context);

      expect(result.code).assertEqual(-1);

      mocker.clear(yellowPageModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('yellowPageModelTest_queryYellowPageListInfoByCondition_dataHelper_undefined', 0, async () => {
      let actionData: LooseObject = {
        'telephone': '570977632'
      };
      let callback: Function = (res: LooseObject) => {
        expect(res.code).assertEqual(-1);
      };
      let mocker: MockKit = new MockKit();
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initYellowPageDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(undefined)));
      yellowPageModel.queryYellowPageListInfoByCondition(actionData, callback, context);
      mocker.clear(yellowPageModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('yellowPageModelTest_queryYellowPageListInfoByCondition_buildQueryYellowPageListCondition_if', 0, async () => {
      let mySet:DataShareResultSet = new MySet();
      mySet.rowCount = 1;
      let actionData: LooseObject = {
        'telephone': '570977632',
        'yellowPageIds':['1'],
        'telephones':['570977632'],
        'page':1,
        'limit':10,
        'searchName':'name',
        'transmitSearchInput':'n',
      };
      let callback: Function = (res: LooseObject) => {
        expect(res.code).assertEqual(0);
      };
      let mocker: MockKit = new MockKit();
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initYellowPageDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve(mySet))
        } as dataShare.DataShareHelper)));
      yellowPageModel.queryYellowPageListInfoByCondition(actionData, callback, context);
      mocker.clear(yellowPageModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('yellowPageModelTest_queryYellowPageListInfoByCondition_buildQueryYellowPageListCondition_noIf', 0, async () => {
      let actionData: LooseObject = {
        'telephone': null,
        'yellowPageIds':[],
        'telephones':null,
        'page':null,
        'limit':null,
        'searchName':null,
        'transmitSearchInput':'',
      };
      let callback: Function = (res: LooseObject) => {
        expect(res.code).assertEqual(0);
      };
      let mocker: MockKit = new MockKit();
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initYellowPageDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve(new MySet()))
        } as dataShare.DataShareHelper)));
      yellowPageModel.queryYellowPageListInfoByCondition(actionData, callback, context);
      mocker.clear(yellowPageModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('yellowPageModelTest_queryYellowPageListInfoByCondition_buildQueryYellowPageListCondition_error', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();
      let callback: Function = (res: LooseObject) => {
        expect(res.code).assertEqual(-1);
      };
      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initYellowPageDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates, columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>((resolve: (value: DataShareResultSet | PromiseLike<DataShareResultSet>) => void, reject: (reason?: BusinessError) => void) =>
          reject({
            code: 1, message: 'error'
          } as BusinessError))
        } as dataShare.DataShareHelper)));
      yellowPageModel.queryYellowPageListInfoByCondition({},callback, context);
      mocker.clear(yellowPageModel);
      mocker.clear(DataShareHelper.getInstance());
    })

  })
}