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
import { describe, beforeEach, it, expect, MockKit} from '@ohos/hypium';
import LooseObject from '../../../../../main/ets/data/LooseObject';
import FullImageDisplayControler from '../../../../../main/ets/pages/FullImage/FullImageDisplayControler';
import { PictureListData } from '../../../../../main/ets/utils/TypesUtils';
import { DTGlobalContext } from '../../../testability/TestAbility';


export default function fullImageDisplayControlerTest() {
  describe('fullImageDisplayControlerTest', () => {

    let fullImageDisplay: FullImageDisplayControler;
    let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;

    beforeEach(() => {
      fullImageDisplay = FullImageDisplayControler.getInstance()
    })

    it('FullImageDisplayControlerTest_onInit', 0, ()=>{
      let pageInfos: NavPathStack = new NavPathStack();
      pageInfos.pushPathByName('FullImageDisplay', {
        showIdx: 1
      } as LooseObject);

      fullImageDisplay.onInit(pageInfos);

      expect(fullImageDisplay.showIdx).assertEqual(1);
    })

    it('FullImageDisplayControlerTest_onShow', 0, ()=>{
      fullImageDisplay.onShow();

      expect(fullImageDisplay.showIdx).assertEqual(1);
    })

    it('FullImageDisplayControlerTest_checkBoxChange', 0, ()=>{
      let mocker:MockKit = new MockKit();
      mocker.mockFunc(fullImageDisplay.pictureCtrl,fullImageDisplay.pictureCtrl.clickPictureCheckbox);

      fullImageDisplay.pictureCtrl.pictureList = [];
      let data:PictureListData = {
        image: "string",
        selected: false,
        photoType: 1,
      };

      fullImageDisplay.pictureCtrl.pictureList.push(data);

      fullImageDisplay.checkBoxChange(context, true, 0);

      mocker.verify('clickPictureCheckbox',[true,data,0]).never();

      mocker.clear(fullImageDisplay.pictureCtrl);
    })

    it('FullImageDisplayControlerTest_checkBoxChange1', 0, ()=>{
      let mocker:MockKit = new MockKit();
      mocker.mockFunc(fullImageDisplay.pictureCtrl,fullImageDisplay.pictureCtrl.clickPictureCheckbox);

      fullImageDisplay.pictureCtrl.pictureList = [];
      let data:PictureListData = {
        image: "string",
        selected: true,
        photoType: 1,
      }
      fullImageDisplay.pictureCtrl.pictureList.push(data)

      fullImageDisplay.checkBoxChange(context, true, 1);

      mocker.verify('clickPictureCheckbox',[true,data,0]).never();

      mocker.clear(fullImageDisplay.pictureCtrl);
    })
  })
}
