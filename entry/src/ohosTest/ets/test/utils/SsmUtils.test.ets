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
import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect, MockKit,
  ArgumentMatchers,
  when} from '@ohos/hypium'
import SsmUtils from '../../../../main/ets/utils/SsmUtils'
import { JSON } from '@kit.ArkTS'

export default function SsmUtilsTest() {
  describe('SsmUtilsTest', () => {
    // Defines a test suite. Two parameters are supported: test suite name and test suite function.
    beforeAll(() => {
      // Presets an action, which is performed only once before all test cases of the test suite start.
      // This API supports only one parameter: preset action function.
    })
    beforeEach(() => {
      // Presets an action, which is performed before each unit test case starts.
      // The number of execution times is the same as the number of test cases defined by **it**.
      // This API supports only one parameter: preset action function.
    })
    afterEach(() => {
      // Presets a clear action, which is performed after each unit test case ends.
      // The number of execution times is the same as the number of test cases defined by **it**.
      // This API supports only one parameter: clear action function.
    })
    afterAll(() => {
      // Presets a clear action, which is performed after all test cases of the test suite end.
      // This API supports only one parameter: clear action function.
    })
    it('SsmUtils_getLocalNumber', 0, () => {
      // Defines a test case. This API supports three parameters: test case name, filter parameter, and test case function.
      let a = 'test'
      // Defines a variety of assertion methods, which are used to declare expected boolean conditions.
      expect(a).assertEqual('test')
    })

    it("SsmUtils_stringToHex_01", 0, () => {
      let str = '';

      let result = SsmUtils.stringToHex(str);

      expect(result).assertEqual('')
    })

    it("SsmUtils_getPhoneNumberLast_01", 0, () => {
      let phoneNumber = '15040452546';
      let lastPhoneNumber: string = phoneNumber;
      let lastNum = 1;
      let result = SsmUtils.getPhoneNumberLast(phoneNumber, lastNum);

      expect(result).assertEqual('6')
    })

    it("SsmUtils_getPhoneNumberLast_02", 0, () => {
      let phoneNumber = '15040452546';
      let lastPhoneNumber: string = phoneNumber;
      let lastNum = 11;
      let result = SsmUtils.getPhoneNumberLast(phoneNumber, lastNum);

      expect(result).assertEqual('15040452546')
    })

    it("SsmUtils_stringToHex_02", 0, () => {
      let str = 'A';
      let result = SsmUtils.stringToHex(str);
      expect(result).assertEqual('41');
    })

    it("SsmUtils_stringToHex_03", 0, () => {
      let str = 'Hello';
      let result = SsmUtils.stringToHex(str);
      expect(result).assertEqual('48656c6c6f');
    })

    it("SsmUtils_stringToHex_04", 0, () => {
      let str = '#$&';
      let result = SsmUtils.stringToHex(str);
      expect(result).assertEqual('232426');
    })

    it("SsmUtils_uint8ArrayToHex_01", 0, () => {
      const bytes = new Uint8Array([10, 20, 30, 40]);
      let result = SsmUtils.uint8ArrayToHex(bytes);
      expect(result).assertEqual('0a141e28');
    })

    it("SsmUtils_uint8ArrayToHex_02", 0, () => {
      const bytes = new Uint8Array([1, 2, 3, 4]);
      let result = SsmUtils.uint8ArrayToHex(bytes);
      expect(result).assertEqual('01020304');
    })

    it("SsmUtils_stringToUint8Array", 0, () => {
      let str = 'Hello, World!'
      let result = SsmUtils.stringToUint8Array(str);
      const expected = new Uint8Array([72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]);
      expect(JSON.stringify(result)).assertEqual(JSON.stringify(expected));
    })

    it("SsmUtils_formatPhoneNumber_empty_1", 1, async () => {
      let result = await SsmUtils.formatPhoneNumber('',0);
      expect(result).assertEqual('');
    })

    it("SsmUtils_stringToSha256", 1, async () => {
      let result = await SsmUtils.stringToSha256('');
      expect(result).assertEqual('');
    })

    it("SsmUtils_uint8ToHex", 0, () => {
      const uint8arr = new Uint8Array([10, 20, 30, 40, 50]);
      const expectedResult = '0a141e2832';
      let result = SsmUtils.uint8ToHex(uint8arr);
      expect(result).assertEqual(expectedResult);
    })

    it("SsmUtils_uint8ToHex2", 0, () => {
      const uint8arr = new Uint8Array([1, 2, 3, 4, 5]);
      const expectedResult = '0102030405';
      let result = SsmUtils.uint8ToHex(uint8arr);
      expect(result).assertEqual(expectedResult);
    })

    it("SsmUtils_uint8ToHex_empty", 0, () => {
      const uint8arr = new Uint8Array([]);
      const expectedResult = '';
      let result = SsmUtils.uint8ToHex(uint8arr);
      expect(result).assertEqual(expectedResult);
    })
  })
}