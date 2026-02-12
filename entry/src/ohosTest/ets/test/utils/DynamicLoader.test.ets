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
import { beforeEach, describe, expect, it } from '@ohos/hypium';
import { DynamicLoader } from '../../../../main/ets/utils/DynamicLoader';

export default function dynamicLoaderTest() {
  describe('dynamicLoaderTest', () => {
    let dynamicLoader: DynamicLoader;

    beforeEach(() => {
      dynamicLoader = DynamicLoader.getInstance();
    })

    it('dynamicLoaderTest_register', 0, async () => {
      let loaderCallback: (key: string) => Promise<boolean> =
        (key: string) => new Promise<boolean>(resolve => resolve(true))
      dynamicLoader.register(loaderCallback);

      expect(JSON.stringify(dynamicLoader.dynamicLoaderCB)).assertEqual(JSON.stringify(loaderCallback));
    })

    it('dynamicLoaderTest_fire_if', 0, async () => {
      dynamicLoader.dynamicLoaderCB = null;
      let result: boolean = await dynamicLoader.fire('');
      expect(result).assertTrue();
    })

    it('dynamicLoaderTest_fire_noIf', 0, async () => {
      dynamicLoader.register((key: string) => new Promise<boolean>(resolve => resolve(false)));
      let result: boolean = await dynamicLoader.fire('');
      expect(result).assertFalse();
    })
  })
}