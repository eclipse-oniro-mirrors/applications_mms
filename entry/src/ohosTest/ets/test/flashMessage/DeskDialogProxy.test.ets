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
import { rpc } from '@kit.IPCKit';
import DeskDialogProxy from '../../../../main/ets/flashMessage/DeskDialogProxy';
import LooseObject from '../../../../main/ets/data/LooseObject';


class LooseObjectTest implements LooseObject {
}

export default function DeskDialogProxyTest() {
  describe('DeskDialogProxyTest', () => {

    it('DeskDialogProxyTest_bannerStart_01', 0, async () => {
      let proxy: rpc.RemoteObject = new rpc.RemoteObject("rpcTestAbility");
      let dialogInfo: LooseObject = new LooseObjectTest();
      let deskdialogproxy: DeskDialogProxy = new DeskDialogProxy(proxy, dialogInfo);
      await deskdialogproxy.bannerStart();
      expect().assertUndefined();
    });
  })
}