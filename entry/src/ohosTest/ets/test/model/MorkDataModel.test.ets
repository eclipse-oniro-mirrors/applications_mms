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
import { describe, expect, it } from '@ohos/hypium';
import MorkDataModel from '../../../../main/ets/model/MorkDataModel';

export default function morkDataModelTest() {
  describe('morkDataModelTest', () => {

    it('morkDataModelTest_saveImage', 0, () => {
      expect(new MorkDataModel().saveImage().filePath).assertEqual('');
    })

    it('morkDataModelTest_queryFromGallery', 0, () => {
      expect(new MorkDataModel().queryFromGallery()[0].path).assertEqual('/common/icon/add.png');
    })
  })
}