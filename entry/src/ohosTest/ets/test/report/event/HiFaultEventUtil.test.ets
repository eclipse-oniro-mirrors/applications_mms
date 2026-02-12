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
import { ArgumentMatchers, describe, it, when } from '@ohos/hypium'
import { MockKit } from '@ohos/hypium/src/main/module/mock/MockKit'
import { ReportSmsContentFailParam } from '../../../../../main/ets/report/common/ReportParams'
import HiFaultEventUtil from '../../../../../main/ets/report/event/HiFaultEventUtil'
import { DateUtil } from '../../../../../main/ets/utils/DateUtil'

export default function hiFaultEventUtilTest() {
  describe('HiFaultEventUtilTest', () => {
    it('HiFaultEventUtilTest_reportSmsContentFail', 0, () => {
      let eventParam: ReportSmsContentFailParam = {
        senderNumber: '',
        reportContent: '',
        reportDuration: 0,
        reportFailReason: 0
      } as ReportSmsContentFailParam;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(DateUtil, DateUtil.isDataValid))(ArgumentMatchers.any).afterReturn(false);
      HiFaultEventUtil.reportSmsContentFail(eventParam);
      when(mocker.mockFunc(DateUtil, DateUtil.isDataValid))(ArgumentMatchers.any).afterReturn(true);
      mocker.mockFunc(HiFaultEventUtil, HiFaultEventUtil.report);
      HiFaultEventUtil.reportSmsContentFail(eventParam);
      mocker.verify('report', ['MMS', 'APPEAL_SMSCONTENT_FAIL', 1, eventParam]);
      mocker.clear(DateUtil);
      mocker.clear(HiFaultEventUtil);
    })
  })
}