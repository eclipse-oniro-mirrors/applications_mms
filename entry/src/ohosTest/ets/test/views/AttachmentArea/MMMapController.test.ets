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
import { describe, beforeEach, it, expect, MockKit, when, ArgumentMatchers } from '@ohos/hypium';
import MMMapController from '../../../../../main/ets/views/AttachmentArea/MMMapController';
import { DTGlobalContext } from '../../../testability/TestAbility';

export default function MMMapControllerTest() {
  describe('MMMapControllerTest', () => {
    let mapCtrl: MMMapController;
    let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;


    beforeEach(() => {
      mapCtrl = new MMMapController();
    })

    it('MMMapControllerTest_getInstance', 0, () => {
      expect(typeof MMMapController.getInstance()).assertEqual(typeof mapCtrl);
    })

    it('MMMapControllerTest_getLocationAndOpenMap', 0, () => {
      mapCtrl.getLocationAndOpenMap(context);
      expect(mapCtrl).not().assertNull();
    })

  })
}