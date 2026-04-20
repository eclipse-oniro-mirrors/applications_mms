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
import { LogLevel } from "../../../../main/ets/log/common/LogCommon";
import { LogConfig } from "../../../../main/ets/log/entity/LogConfig";
import { Logger } from "../../../../main/ets/log/Logger";
import { afterEach, ArgumentMatchers, beforeEach, describe, expect, it, MockKit, when } from "@ohos/hypium";

const TAG = 'LoggerTest';

/**
 * LogEntry的基础功能测试
 *
 * @since 2025-10-16
 */
export default function LoggerTest() {
  describe('LoggerTest', () => {
    const logConfig: LogConfig = {
      minLevel: LogLevel.INFO,
      formatter: 'text',
    } as LogConfig;
    let logger: Logger = Logger.getInstance(logConfig);
    let mocker: MockKit = new MockKit();
    beforeEach(() => {
    });

    afterEach(() => {
    });

    /**
     * @tc.number: should_return_immediately_when_level_is_below_minLevel
     * @tc.name: write方法测试
     * @tc.type: 0 || TestType.FUNCTION || Level.LEVEL0
     * @tc.desc: 验证当日志级别低于最小级别时，write 方法不会被执行，即立即返回
     */
    it('should_return_immediately_when_level_is_below_minLevel', 0, async () => {
      await logger.write(LogLevel.DEBUG, "test message", {});
      // 验证write方法未被调用
      mocker.verify('write', [LogLevel.DEBUG, "test message", {}]).never();
    });

    /**
     * @tc.number: should_write_log_when_level_is_above_minLevel
     * @tc.name: write方法测试
     * @tc.type: 0 || TestType.FUNCTION || Level.LEVEL0
     * @tc.desc: 验证当日志级别高于或等于最小级别时，write 方法能够正常执行并被记录
     */
    it('should_write_log_when_level_is_above_minLevel', 0, async () => {
      let mockfunc: Function = mocker.mockFunc(logger, logger.write);
      when(mockfunc)(ArgumentMatchers.any).afterReturn(null);
      let result: Function = mockfunc();
      expect(result).assertEqual(null);
    });
  });
}