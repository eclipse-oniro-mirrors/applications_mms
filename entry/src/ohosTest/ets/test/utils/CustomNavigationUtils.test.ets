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
import { AnimateCallback, CustomNavigationUtils } from '../../../../main/ets/utils/CustomNavigationUtils';

export default function customNavigationUtilsTest() {
  describe('customNavigationUtilsTest', () => {

    it('customNavigationUtilsTest_getAnimateParam', 0, () => {
      let customNavigationUtils: CustomNavigationUtils = CustomNavigationUtils.getInstance();
      //customTransitionMap没有name
      customNavigationUtils.registerNavParam(0, (operation: boolean, isExit: boolean) => {
      }, (operation: boolean, isExit: boolean) => {
      },
        (opeation: boolean, isExit: boolean) => {
        }, 0);

      //customTransitionMap有name
      customNavigationUtils.registerNavParam(0, (operation: boolean, isExit: boolean) => {
      }, (operation: boolean, isExit: boolean) => {
      },
        (opeation: boolean, isExit: boolean) => {
        }, 0);

      let res: AnimateCallback = customNavigationUtils.getAnimateParam(0);

      expect(JSON.stringify(res))
        .assertEqual('{"timeout":0}')
      customNavigationUtils.unRegisterNavParam(0);
    })
  })
}