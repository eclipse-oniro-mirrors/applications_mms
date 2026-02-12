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
import { describe, it, expect, MockKit,
  when} from '@ohos/hypium'
import LooseObject from '../../../../main/ets/data/LooseObject';
import UnlockConversationModel from '../../../../main/ets/model/UnlockConversationModel';
import DataShareHelper from '../../../../main/ets/model/repository/DataShareHelper';
import { DTGlobalContext } from '../../testability/TestAbility';
import dataShare from '@ohos.data.dataShare';
import DataShareResultSet from '@ohos.data.DataShareResultSet';
import MySet from '../MySet';
import dataSharePredicates from '@ohos.data.dataSharePredicates';
import { BusinessError } from '@kit.BasicServicesKit';

export default function UnlockConversationModelTest() {
  describe('UnlockConversationModelTest', () => {
    let unlockconversationmodel: UnlockConversationModel = new UnlockConversationModel();
    it('UnlockConversationModelTest_statisticalData_if1', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();
      let callback: Function = (result: LooseObject) => {
        expect(result.code).assertEqual(-1);
      };
      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(undefined)));
      await unlockconversationmodel.statisticalData(undefined, context);
      await unlockconversationmodel.statisticalData(callback, context);

      mocker.clear(DataShareHelper.getInstance());
    })

    it('UnlockConversationModelTest_statisticalData_success', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let callback: Function = (result: LooseObject) => {
        expect(result.code).assertEqual(0);
      };
      let mocker: MockKit = new MockKit();
      let mySet: DataShareResultSet = new MySet();
      mySet.rowCount = 1;
      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve(mySet))
        } as dataShare.DataShareHelper)));

      await unlockconversationmodel.statisticalData(callback, context);

      mocker.clear(DataShareHelper.getInstance());
    })

    it('UnlockConversationModelTest_statisticalData_success_goToLastRow_false', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let callback: Function = (result: LooseObject) => {
      };
      let mocker: MockKit = new MockKit();
      let resultSet: DataShareResultSet = {
        rowCount: 3,
        goToLastRow: () => false,
        getLong: (columnIndex: number): number => -1
      } as DataShareResultSet;
      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve(resultSet))
        } as dataShare.DataShareHelper)));

      await unlockconversationmodel.statisticalData(callback, context);
      expect(unlockconversationmodel).not().assertUndefined();

      mocker.clear(DataShareHelper.getInstance());
    })

    it('UnlockConversationModelTest_statisticalData_success_getLong_lt_1', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let callback: Function = (result: LooseObject) => {
      };
      let mocker: MockKit = new MockKit();
      let resultSet: DataShareResultSet = {
        rowCount: 3,
        goToLastRow: () => true,
        getLong: (columnIndex: number): number => -1
      } as DataShareResultSet;
      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve(resultSet))
        } as dataShare.DataShareHelper)));

      await unlockconversationmodel.statisticalData(callback, context);
      expect(unlockconversationmodel).not().assertUndefined();

      mocker.clear(DataShareHelper.getInstance());
    })

    it('UnlockConversationModelTest_statisticalData_success_rowCount_0', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let callback: Function = (result: LooseObject) => {
        expect(result.code).assertEqual(0);
      };
      let mocker: MockKit = new MockKit();
      let mySet: DataShareResultSet = new MySet();
      mySet.rowCount = 0;
      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve(mySet))
        } as dataShare.DataShareHelper)));

      await unlockconversationmodel.statisticalData(callback, context);

      mocker.clear(DataShareHelper.getInstance());
    })

    it('UnlockConversationModelTest_statisticalData_error', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let callback: Function = (result: LooseObject) => {
        expect(result.code).assertEqual(-1);
      };
      let mocker: MockKit = new MockKit();
      let mySet: DataShareResultSet = new MySet();
      mySet.rowCount = 1;
      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>((resolve: (value: DataShareResultSet | PromiseLike<DataShareResultSet>) => void,
            reject: (reason?: BusinessError) => void) =>
          reject({
            code: 1, message: 'error'
          } as BusinessError))
        } as dataShare.DataShareHelper)));

      await unlockconversationmodel.statisticalData(callback, context);

      mocker.clear(DataShareHelper.getInstance());
    })
  })
}