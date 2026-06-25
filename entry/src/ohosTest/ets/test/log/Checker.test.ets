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
import Checker from "../../../../main/ets/log/Checker";
import { afterAll, beforeAll, describe, expect, it } from "@ohos/hypium";
import { ArrayList } from "@kit.ArkTS";
import PafLog from "../../../../main/ets/log/PafLogUtil";

const TAG = 'Checker';

/**
 * 测试Checker
 */
export default function CheckerUnitTest() {
  describe('CheckerUnitTest', () => {
    beforeAll(() => {
      PafLog.info(TAG, 'beforeAll');
    });
    afterAll(() => {
      PafLog.info(TAG, 'afterAll');
    });

    /**
     * @tc.number: checkerUnitTest_isEmpty
     * @tc.name: isEmpty方法测试
     * @tc.type: 0 || TestType.FUNCTION || Level.LEVEL0
     * @tc.desc: 验证判空是否能够正常执行
     */
    it('checkerUnitTest_isEmpty', 0, () => {
      expect(Checker.isEmpty(0)).assertFalse();
      expect(Checker.isEmpty([])).assertTrue();
      expect(Checker.isEmpty([1])).assertFalse();
      const arrList: ArrayList<number> = new ArrayList();
      expect(Checker.isEmpty(arrList)).assertTrue();
      arrList.add(0);
      expect(Checker.isEmpty(arrList)).assertFalse();
      expect(Checker.isEmpty('')).assertTrue();
      expect(Checker.isEmpty('0')).assertFalse();
      const map: Map<number, number> = new Map();
      expect(Checker.isEmpty(map)).assertTrue();
      map.set(0, 0);
      expect(Checker.isEmpty(map)).assertFalse();
      const set: Set<number> = new Set();
      expect(Checker.isEmpty(set)).assertTrue();
      set.add(0);
      expect(Checker.isEmpty(set)).assertFalse();
    });
  });
}