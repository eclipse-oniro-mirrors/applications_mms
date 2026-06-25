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

import { BusinessError } from '@ohos.base';
import lazy hiSysEvent from '@ohos.hiSysEvent';
import lazy { DateUtil } from '../../utils/DateUtil';
import HiLog from '../../utils/HiLog';
import StringUtil from '../../utils/StringUtil';
import { ReportSmsContentFailParam } from '../common/ReportParams';
import HiSysEventConstant from './HiSysEventConstant';

const TAG = 'HiFaultEventUtil';

export default class HiFaultEventUtil {
  private constructor() {
  }

  /**
   * SmsContent report fails and error message is reported
   *
   * @param { ReportSmsContentFailParam } reportParam - the reportParam.
   */
  public static reportSmsContentFail(reportParam: ReportSmsContentFailParam): void {
    if (!DateUtil.isDataValid(reportParam)) {
      HiLog.e(TAG, 'reportSmsContentFail reportParam is invalid ');
      return;
    }
    let eventParams: Record<string, string | number> = {
      'APPEAL_SENDER_NUMBER': StringUtil.mask(reportParam.senderNumber),
      'APPEAL_SMS_CONTENT': reportParam.reportContent,
      'CLOUD_CHECK_DURATION': reportParam.reportDuration,
      'APEAL_FAIL_REASON': reportParam.reportFailReason
    }
    HiFaultEventUtil.report(HiSysEventConstant.FAULT_EVENT_DOMAIN, HiSysEventConstant.REPORT_SMS_CONTENT_FAIL,
      hiSysEvent.EventType.FAULT, eventParams);
  }

  /**
   * Fail event report
   *
   * @param { string } domain - the domain.
   * @param { string } name - the event name.
   * @param { hiSysEvent.EventType } eventType - the event type.
   * @param { Object } params - the  params need to report.
   */

  public static report(domain: string, name: string, eventType: hiSysEvent.EventType, params: Object): void {
    HiLog.d(TAG, `start to report domain: ${domain}, eventName: ${name}, eventType ${eventType}`);
    const sysEventInfo: hiSysEvent.SysEventInfo = {
      domain: domain,
      name: name,
      eventType: eventType,
      params: params
    };
    hiSysEvent.write(sysEventInfo).then(() => {
      HiLog.d(TAG, `reportHiSysEvent ${sysEventInfo.name} success.`);
    }).catch((err: BusinessError) => {
      HiLog.e(TAG, `reportHiSysEvent ${sysEventInfo.name}, error msg: ${err.message}`);
    }
    );
  }
}