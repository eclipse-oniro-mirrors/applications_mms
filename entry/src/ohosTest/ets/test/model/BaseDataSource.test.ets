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
import { describe, beforeEach, afterEach, it, expect, MockKit } from '@ohos/hypium';
import BasicDataSource from '../../../../main/ets/model/BaseDataSource';
import HiLog from '../../../../main/ets/utils/HiLog';

class DataChangeListenerImpl implements DataChangeListener {
  onDatasetChange(dataOperations: DataOperation[]): void {
    throw new Error('Method not implemented.');
  }

  count: number = 0;

  onDataReloaded() {
    this.count = 0;
  }

  onDataAdded(index: number) {
    this.count = index;
  }

  onDataAdd(index: number) {
    this.count = index;
  }

  onDataMoved(from: number, to: number) {
    this.count = from + to;
  }

  onDataMove(from: number, to: number) {
    this.count = from + to;
  }

  onDataDeleted(index: number) {
    this.count = index;
  }

  onDataDelete(index: number) {
    this.count = index;
  }

  onDataChanged(index: number) {
    this.count = index;
  }

  onDataChange(index: number) {
    this.count = index;
  }
}

export default function BaseDataSourceTest() {
  describe('BaseDataSourceTest', () => {

    let basicDataSource = new BasicDataSource();
    let listener: DataChangeListenerImpl = new DataChangeListenerImpl();
    const TAG = 'BasicDataSource'

    beforeEach(() => {
      basicDataSource.registerDataChangeListener(listener);
    })

    afterEach(() => {
      basicDataSource.unregisterDataChangeListener(listener);
    })

    it('BasicDataSource_registerDataChangeListener_noIf', 0, () => {
      let mocker:MockKit = new MockKit();
      mocker.mockFunc(HiLog,HiLog.i);

      basicDataSource.registerDataChangeListener(listener);

      mocker.verify('i',[TAG, 'add listener']).never();

      mocker.clear(HiLog);
    })

    it('BasicDataSource_unRegisterDataChangeListener_noIf', 0, () => {
      basicDataSource.unregisterDataChangeListener(listener);

      let mocker:MockKit = new MockKit();
      mocker.mockFunc(HiLog,HiLog.i);

      basicDataSource.unregisterDataChangeListener(listener);

      mocker.verify('i',[TAG, 'remove listener']).never();

      mocker.clear(HiLog);
    })

    it('BasicDataSource_totalCount', 0, () => {
      let result = basicDataSource.totalCount();
      expect(result).assertEqual(0);
    })

    it('BasicDataSource_getData', 0, () => {
      let result = basicDataSource.getData(1);
      expect(result).assertNull();
    })

    it('BasicDataSource_notifyDataReload', 0, () => {
      basicDataSource.notifyDataReload();
      expect(listener.count).assertEqual(0);
    })

    it('BasicDatasource_notifyDataAdd', 0, () => {
      basicDataSource.notifyDataAdd(1);
      expect(listener.count).assertEqual(1);
    })

    it('BasicDatasource_notifyDataChange', 0, () => {
      basicDataSource.notifyDataChange(1);
      expect(listener.count).assertEqual(1);
    })

    it('BasicDatasource_notifyDataDelete', 0, () => {
      basicDataSource.notifyDataDelete(1);
      expect(listener.count).assertEqual(1);
    })

    it('BasicDatasource_notifyDataMove', 0, () => {
      basicDataSource.notifyDataMove(0, 1);
      expect(listener.count).assertEqual(1);
    })
  })
}