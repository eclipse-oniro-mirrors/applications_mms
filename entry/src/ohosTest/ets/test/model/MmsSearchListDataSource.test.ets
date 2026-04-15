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
import { describe, beforeEach, it, expect, MockKit } from '@ohos/hypium';
import LooseObject from '../../../../main/ets/data/LooseObject';
import MmsSearchListDataSource from '../../../../main/ets/model/MmsSearchListDataSource';
import { searchType } from '../../../../main/ets/model/TransmitSearchListDataSource';

export default function MmsSearchListDataSourceTest() {
  describe('MmsSearchListDataSourceTest', () => {

    let mmsSearchListDataSource: MmsSearchListDataSource;

    beforeEach(() => {
      mmsSearchListDataSource = new MmsSearchListDataSource();
    })

    it('mmsSearchListDataSource_totalCount', 0, () => {
      expect(mmsSearchListDataSource.totalCount()).assertEqual(0);
    })

    it('mmsSearchListDataSource_getData_searchList_length0', 0, () => {
      expect(mmsSearchListDataSource.getData(0)).assertNull();
    })

    it('mmsSearchListDataSource_getData', 0, () => {
      let searchList = new Array<LooseObject>();
      let search: LooseObject = {
        index: 1
      };
      searchList.push(search);

      let mocker:MockKit = new MockKit();
      mocker.mockFunc(mmsSearchListDataSource,mmsSearchListDataSource.notifyDataReload);

      mmsSearchListDataSource.refresh(searchList);

      let data: searchType | null = mmsSearchListDataSource.getData(0);

      expect(data?.index).assertEqual(0);
      expect(JSON.stringify(data?.search)).assertEqual(JSON.stringify(search));

      mocker.clear(mmsSearchListDataSource);
    })
  })
}