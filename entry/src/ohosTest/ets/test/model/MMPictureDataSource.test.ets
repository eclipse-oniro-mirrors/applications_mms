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
import { beforeEach, describe, expect, it, MockKit } from '@ohos/hypium';
import MMPictureDataSource from '../../../../main/ets/model/MMPictureDataSource';
import { PictureListData } from '../../../../main/ets/utils/TypesUtils';

export default function mMPictureDataSourceTest() {
  describe('mMPictureDataSourceTest', () => {

    let mMPictureDataSource: MMPictureDataSource;

    beforeEach(() => {
      mMPictureDataSource = new MMPictureDataSource();
    })

    it('mMPictureDataSourceTest_totalCount', 0, () => {
      expect(mMPictureDataSource.totalCount()).assertEqual(0);
    })

    it('mMPictureDataSourceTest_getData_if', 0, () => {
      expect(mMPictureDataSource.getData(0)).assertNull();
    })

    it('mMPictureDataSourceTest_getData_else', 0, () => {
      let mocker:MockKit = new MockKit();
      mocker.mockFunc(mMPictureDataSource,mMPictureDataSource.notifyDataReload);
      let pictureListData:PictureListData= {
        image: '',
        selected: false,
        photoType: 0
      };
      mMPictureDataSource.refresh([pictureListData]);

      expect(JSON.stringify(mMPictureDataSource.getData(0))).assertEqual(JSON.stringify(pictureListData));

      mocker.clear(mMPictureDataSource);
    })

    it('mMPictureDataSourceTest_deleteByIndex', 0, () => {
      let mocker:MockKit = new MockKit();
      mocker.mockFunc(mMPictureDataSource,mMPictureDataSource.notifyDataDelete);

      mMPictureDataSource.deleteByIndex(0);

      mocker.verify('notifyDataDelete',[0]).once();

      mocker.clear(mMPictureDataSource);
    })
  })
}