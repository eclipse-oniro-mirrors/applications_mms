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
import { describe, it, expect, when, MockKit } from '@ohos/hypium'
import UserUtil from '../../../../main/ets/utils/UserUtil'
import { osAccount } from '@kit.BasicServicesKit';

export default function UserUtilTest() {
  describe('UserUtilTest', () => {

    it('UserUtilTest_isMainUser_false', 0, async () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(UserUtil, UserUtil.isPrimaryAccount))().afterReturn(
        new Promise<boolean>((resole) => {
          resole(false);
        }));
      let res = await UserUtil.isMainUser();
      expect(res).assertEqual(false)
      mocker.clear(UserUtil);
    })

    it('UserUtilTest_isPrimaryAccount_false', 0, async () => {
      let result = 0;
      try {
        await UserUtil.isPrimaryAccount();
      } catch (e) {
        result = -1;
      }
      expect(result).assertEqual(0)
    })

    it('UserUtilTest_isMainUser_case_success', 0, async () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(UserUtil, UserUtil.isPrimaryAccount))().afterReturn(
        new Promise<boolean>((resole) => {
          resole(true);
        }));
      let res = await UserUtil.isMainUser();
      expect(res).assertEqual(true)
      mocker.clear(UserUtil);
    })

    it('UserUtilTest_isPrivateAccount_true', 0, async () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(UserUtil, UserUtil.getAccountType))().afterReturn(
        new Promise<osAccount.OsAccountType>((resole) => {
          resole(osAccount.OsAccountType.PRIVATE);
        }));
      let res = await UserUtil.isPrivateAccount();
      expect(res).assertEqual(true)
      mocker.clear(UserUtil);
    })

    it('UserUtilTest_isPrivateAccount_false', 0, async () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(UserUtil, UserUtil.getAccountType))().afterReturn(
        new Promise<osAccount.OsAccountType>((resole) => {
          resole(-1);
        }));
      let res = await UserUtil.isPrivateAccount();
      expect(res).assertEqual(false)
      mocker.clear(UserUtil);
    })

    it('UserUtilTest_getAccountType_case_success', 0, async () => {
      let result = 0;
      try {
        await UserUtil.getAccountType();
      } catch (e) {
        result = -1;
      }
      expect(result).assertEqual(0);
    })
  })
}