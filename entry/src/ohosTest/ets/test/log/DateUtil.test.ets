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
import DateUtil from "../../../../main/ets/log/DateUtil";
import PafLog from "../../../../main/ets/log//PafLogUtil";
import { afterAll, beforeAll, describe, expect, it } from "@ohos/hypium";

const TAG = 'DateUtil';

/**
 * 测试DateUtil
 */
export default function DateUtilUnitTest() {
  describe('DateUtilUnitTest', () => {
    beforeAll(() => {
      PafLog.info(TAG, 'beforeAll');
    });
    afterAll(() => {
      PafLog.info(TAG, 'afterAll');
    });

    /**
     * @tc.number: dateFormat
     * @tc.name: dateFormat方法测试
     * @tc.type: 0 || TestType.FUNCTION || Level.LEVEL0
     * @tc.desc: 验证日期格式是否正常转换
     */
    it('dateFormat', 0, () => {
      expect(DateUtil.dateFormat('YYYYMMddHHmmssSSS', 1688095406084)).assertEqual('20230630112326084');
      expect(DateUtil.dateFormat('YYYY-MM-dd HH:mm:ss', 1688095406084)).assertEqual('2023-06-30 11:23:26');
      const date1 = new Date(2023, 6, 7, 11, 22, 33, 444);
      expect(DateUtil.dateFormat('YYYYMMddHHmmssSSS', date1)).assertEqual('20230707112233444');
    });
  });
}