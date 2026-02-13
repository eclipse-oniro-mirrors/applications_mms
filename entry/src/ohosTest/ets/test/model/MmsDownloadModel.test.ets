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
import { describe, expect, it, MockKit, when } from '@ohos/hypium'
import MmsDownloadModel from '../../../../main/ets/model/MmsDownloadModel';
import { DTGlobalContext } from '../../testability/TestAbility';
import DataShareResultSet from '@ohos.data.DataShareResultSet';
import MySet from '../MySet';
import DataShareHelper from '../../../../main/ets/model/repository/DataShareHelper';
import dataShare from '@ohos.data.dataShare';
import dataSharePredicates from '@ohos.data.dataSharePredicates';
import { BusinessError } from '@kit.BasicServicesKit';

export default function MmsDownloadModelTest() {
  describe('MmsDownloadModelTest', () => {
    let infomsgautodeletemodel: MmsDownloadModel = new MmsDownloadModel();
    it('MmsDownloadModelTest_queryUnDownloadMms_success', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();
      let mySet: DataShareResultSet = new MySet();
      mySet.rowCount = 1;
      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve(mySet))
        } as dataShare.DataShareHelper)));

      await infomsgautodeletemodel.queryUnDownloadMms(context);
      expect(context).not().assertNull();
      mocker.clear(DataShareHelper.getInstance());
    })

    it('MmsDownloadModelTest_queryUnDownloadMms_error', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
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

      await infomsgautodeletemodel.queryUnDownloadMms(context);
      expect(context).not().assertNull();
      mocker.clear(DataShareHelper.getInstance());
    })
  })
}