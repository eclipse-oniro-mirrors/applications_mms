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
import { beforeEach, describe, expect, it, MockKit } from '@ohos/hypium'
import LooseObject from '../../../../main/ets/data/LooseObject';
import TransmitSearchListDataSource from '../../../../main/ets/model/TransmitSearchListDataSource';

export default function transmitSearchListDataSourceTest() {
  describe('transmitSearchListDataSourceTest', () => {

    let transmitSearchListDataSource: TransmitSearchListDataSource;

    beforeEach(() => {
      transmitSearchListDataSource = new TransmitSearchListDataSource();
    })

    it('TransmitSearchListDataSourceTest_totalCount', 0, () => {
      expect(transmitSearchListDataSource.totalCount()).assertEqual(0);
    })

    it('TransmitSearchListDataSourceTest_getData_if', 0, () => {
      expect(transmitSearchListDataSource.getData(0)).assertNull();
    })

    it('TransmitSearchListDataSourceTest_getData_else_refresh_if_if', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(transmitSearchListDataSource, transmitSearchListDataSource.notifyDataReload);
      let looseObject1: LooseObject = {
        'telephone': '570977631'
      };
      let looseObject2: LooseObject = {
        'telephone': '570977632'
      };
      let looseObject3: LooseObject = {
        'telephone': '570977633'
      };
      let looseObject4: LooseObject = {
        'telephone': '570977634'
      };
      transmitSearchListDataSource.refresh([looseObject1, looseObject2, looseObject3, looseObject4], false);

      expect(JSON.stringify(transmitSearchListDataSource.getData(0))).assertEqual(JSON.stringify({
        index: 0,
        search: looseObject1
      }));

      mocker.clear(transmitSearchListDataSource);
    })

    it('TransmitSearchListDataSourceTest_getData_else_refresh_if_else', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(transmitSearchListDataSource, transmitSearchListDataSource.notifyDataReload);
      let looseObject1: LooseObject = {
        'telephone': '570977631'
      };
      let looseObject2: LooseObject = {
        'telephone': '570977632'
      };
      let looseObject3: LooseObject = {
        'telephone': '570977633'
      };
      let looseObject4: LooseObject = {
        'telephone': '570977634'
      };
      transmitSearchListDataSource.refresh([looseObject1, looseObject2, looseObject3, looseObject4], true);

      expect(JSON.stringify(transmitSearchListDataSource.getData(0))).assertEqual(JSON.stringify({
        index: 0,
        search: looseObject1
      }));

      mocker.clear(transmitSearchListDataSource);
    })

    it('TransmitSearchListDataSourceTest_getData_else_refresh_else', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(transmitSearchListDataSource, transmitSearchListDataSource.notifyDataReload);
      let looseObject: LooseObject = {};
      transmitSearchListDataSource.refresh([looseObject], false);

      expect(JSON.stringify(transmitSearchListDataSource.getData(0))).assertEqual(JSON.stringify({
        index: 0,
        search: looseObject
      }));

      mocker.clear(transmitSearchListDataSource);
    })

    it('TransmitSearchListDataSourceTest_refreshData', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(transmitSearchListDataSource, transmitSearchListDataSource.notifyDataReload);

      transmitSearchListDataSource.refreshData();

      mocker.verify('notifyDataReload',[]).once();

      mocker.clear(transmitSearchListDataSource);
    })
  })
}