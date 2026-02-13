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
import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect } from '@ohos/hypium'
import HiLog from '../../../../main/ets/utils/HiLog'
import { StringBuilder } from '../../../../main/ets/utils/VCardParser'

export default function StringBuilderTest() {
  describe('StringBuilderTest', () => {
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

    it('StringBuilderTest_append_is_called_with_string', 0, () => {
      let stringBuilder: StringBuilder = new StringBuilder();
      let result: StringBuilder = stringBuilder.append("Hello, World!");
      expect(result.toString()).assertEqual("Hello, World!");
    })

    it('StringBuilderTest_append_is_called_with_empty_string', 0, () => {
      let stringBuilder: StringBuilder = new StringBuilder();
      let result: StringBuilder = stringBuilder.append("");
      expect(result.toString()).assertEqual("");
    })

    it('should_return_empty_string_when_mBuffer_is_empty', 0, () => {
      let stringBuilder: StringBuilder = new StringBuilder();
      let result: string = stringBuilder.toString();
      expect(result).assertEqual('');
    })

    it('StringBuilderTest_toString_when_mBuffer_has_elements', 0, () => {
      let stringBuilder: ESObject = new StringBuilder();
      stringBuilder.mBuffer = ['Hello', 'World'];
      stringBuilder.mIndex = 1;
      let result: string = stringBuilder.toString();
      expect(result).assertEqual('Hello');
    })

    it('StringBuilderTest_toString_when_mIndex_is_less_than_0', 0, () => {
      let stringBuilder: ESObject = new StringBuilder();
      stringBuilder.mBuffer = ['Hello', 'World'];
      stringBuilder.mIndex = -1;
      let result: string = stringBuilder.toString();
      expect(result).assertEqual('Hello');
    })

    it('StringBuilderTest_toString_when_mIndex_is_greater_than_mBuffer_length', 0, () => {
      let stringBuilder: ESObject = new StringBuilder();
      stringBuilder.mBuffer = ['Hello', 'World'];
      stringBuilder.mIndex = 5;
      let result: string = stringBuilder.toString();
      expect(result).assertEqual('HelloWorld');
    })
  })
}