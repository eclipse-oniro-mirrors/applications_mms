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
import { describe, it, expect, MockKit, when, } from '@ohos/hypium'
import { NetUtils } from '../../../../main/ets/utils/NetUtils'

export default function NetUtilsTest() {
  describe('NetUtilsTest', () => {

    it('NetUtilsTest_isConnectWifiNetSync_false', 0, () => {
      let isConnectWifi: boolean = NetUtils.isConnectWifiNetSync();
      expect(isConnectWifi).assertFalse();
    })

    it('NetUtilsTest_isConnectCellularNetSync', 0, () => {
      let isConnectCellular: boolean = NetUtils.isConnectCellularNetSync();
      expect(isConnectCellular).assertFalse();
    })
  })
}