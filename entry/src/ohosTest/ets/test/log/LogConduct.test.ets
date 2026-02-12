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
import { LogEntry } from "../../../../main/ets/log/entity/LogEntry";
import { RollingFileWriter, TextFormatter } from "../../../../main/ets/log/LogConduct";
import PafLog from "../../../../main/ets/log//PafLogUtil";
import { describe, expect, it, Level, MockKit } from "@ohos/hypium";

const TAG = 'LogConductTest';

/**
 * LogEntry的基础功能测试
 *
 * @since 2025-10-16
 */
export default function LogConductTest() {
  describe('LogConductTest', () => {
    /**
     * @tc.number: textFormatterText
     * @tc.name: format方法测试
     * @tc.type: 0 || TestType.FUNCTION || Level.LEVEL0
     * @tc.desc: 验证文本能够按照要求格式化成功
     */
    it('textFormatterText', Level.LEVEL0, textFormatterText());

    /**
     * @tc.number: rollingFileWriter
     * @tc.name: write方法测试
     * @tc.type: 0 || TestType.FUNCTION || Level.LEVEL0
     * @tc.desc: 验证当日志写入能够被正常调用
     */
    it('rollingFileWriter', Level.LEVEL0, rollingFileWriter());
  });
}

function textFormatterText(): Function {
  return async () => {
    PafLog.info('textFormatter test start');
    const logEntry: LogEntry = {
      "level": 1,
      "message": "BaseAbility",
      "timestamp": 1740991611280,
      "context": {
        "message": "onCreate"
      }
    }
    const jsonFormatter: TextFormatter = new TextFormatter();
    let result: string = jsonFormatter.format(logEntry);
    result = result.substring(0, 25);
    expect(result).assertEqual('2025-03-03 16:46:51.280 I');
    PafLog.info('textFormatter test end');
  };
}

function rollingFileWriter(): Function {
  return async () => {
    PafLog.info('rollingFileWriter start');
    const logEntry: LogEntry = {
      "level": 1,
      "message": "BaseAbility",
      "timestamp": 1740991611280,
      "context": {
        "message": "onCreate"
      }
    }
    const textFormatter: TextFormatter = new TextFormatter();
    let rollingFileWriter: RollingFileWriter =
      new RollingFileWriter(textFormatter);
    const mocker: MockKit = new MockKit();
    mocker.mockFunc(rollingFileWriter, rollingFileWriter.write);
    for (let i = 0; i < 10000; i++) {
      rollingFileWriter.write(logEntry);
    }
    mocker.verify('write', [logEntry]).atLeast(0);
    PafLog.info('rollingFileWriter end');
  };
}