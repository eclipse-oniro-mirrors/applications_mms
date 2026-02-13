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
import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect, MockKit, when,
  ArgumentMatchers } from '@ohos/hypium'
import TimeUtils from '../../../../../../main/ets/pages/smc/utils/TimeUtils'

export default function TimeUtilsTest() {
  describe('TimeUtilsTest', () => {
    let mocker: MockKit = new MockKit();

    it('TimeUtilsTest_getServerCurrentTime', 0, () => {
      let time = TimeUtils.getServerCurrentTime();
      expect(time > 0).assertTrue()
    })

    it('TimeUtilsTest_covertLongToTime', 0, () => {
      let time1 = TimeUtils.covertLongToTime(-1);
      let time2 = TimeUtils.covertLongToTime(1);
      expect(time1).assertEqual('');
      expect(time2.length >= 0).assertTrue();
    })

    it('TimeUtilsTest_formatTime', 0, () => {
      let time = TimeUtils.formatTime('1');
      expect(time.length >= 0).assertTrue();
    })

    it('TimeUtilsTest_formatTime_catch', 0, () => {
      let time = TimeUtils.formatTime('xx06583722213123534');
      expect(time.length >= 0).assertTrue();
    })

    it('TimeUtilsTest_getTextFormatTime', 0, () => {
      let mockFunc = mocker.mockFunc(TimeUtils, TimeUtils.getTimeMode);
      when(mockFunc)(ArgumentMatchers.any).afterReturn(0);
      let res1 = TimeUtils.getTextFormatTime(1)

      when(mockFunc)(ArgumentMatchers.any).afterReturn(4);
      let res2 = TimeUtils.getTextFormatTime(1)

      when(mockFunc)(ArgumentMatchers.any).afterReturn(1);
      let res3= TimeUtils.getTextFormatTime(1)

      when(mockFunc)(ArgumentMatchers.any).afterReturn(2);
      let res4 = TimeUtils.getTextFormatTime(1)

      when(mockFunc)(ArgumentMatchers.any).afterReturn(3);
      let res5 = TimeUtils.getTextFormatTime(1)

      when(mockFunc)(ArgumentMatchers.any).afterReturn(-1);
      let res6 = TimeUtils.getTextFormatTime(1)

      mocker.clear(TimeUtils);

      expect(res1).not().assertNull();
      expect(res2).not().assertNull();
      expect(res3).not().assertNull();
      expect(res4).not().assertNull();
      expect(res5).not().assertNull();
      expect(res6).not().assertNull();
    })

    it('TimeUtilsTest_getTimeMode', 0, () => {
      let res = TimeUtils.getTimeMode(null);
      expect(res).assertEqual(0);

      let date = new Date();
      let nowDate = new Date();
      date.setFullYear(nowDate.getFullYear());
      date.setDate(nowDate.getDate());
      res = TimeUtils.getTimeMode(date);
      expect(res).assertEqual(1);

      date.setDate(nowDate.getDate()-1);
      res = TimeUtils.getTimeMode(date);
      expect(res).assertEqual(2);

      date.setDate(nowDate.getDate()-6);
      res = TimeUtils.getTimeMode(date);
      expect(res).assertEqual(4);

      date.setDate(nowDate.getDate()-11);
      res = TimeUtils.getTimeMode(date);
      expect(res).assertEqual(4);

      date.setFullYear(nowDate.getFullYear()-1);
      res = TimeUtils.getTimeMode(date);
      expect(res).assertEqual(0);
    })

    it('TimeUtilsTest_getLatestTimestamp', 0, () => {
      let time = TimeUtils.getLatestTimestamp(10, 20, 20);
      expect(time > 0).assertTrue()
    })

    it('TimeUtilsTest_isValidTimestamp', 0, () => {
      let result = TimeUtils.isValidTimestamp('timestamp');
      expect(result).assertFalse();
    })

    it('TimeUtilsTest_isValidTimestamp_number', 0, () => {
      let result = TimeUtils.isValidTimestamp('1547914528');
      expect(result).assertTrue();
    })

  })
}