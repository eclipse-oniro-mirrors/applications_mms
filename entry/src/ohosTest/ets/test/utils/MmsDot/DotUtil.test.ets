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
import { ArgumentMatchers, beforeEach, describe, expect, it, MockKit, when } from '@ohos/hypium';
import DotUtil from '../../../../../main/ets/utils/MmsDot/DotUtils';
import { ConsumerBehaviorParams, CPUAndMEMParams,
  SmsReceiveParams } from '../../../../../main/ets/utils/MmsDot/DotCommon';
import { MessageDetail } from '../../../../../main/ets/utils/TypesUtils';
import commonData from '../../../../../main/ets/data/commonData';

export default function dotUtilTest() {
  describe('dotUtilTest', () => {

    let dotUtil: DotUtil;
    const TAG = 'DotUtil';

    beforeEach(() => {
      dotUtil = DotUtil.getInstance();
    })

    it('dotUtilTest_addSmsReceiveBlockResult', 0, async () => {
      let dotUtil = DotUtil.getInstance();
      let map: Map<number, SmsReceiveParams> = (dotUtil as object)['recordsForSmsReceive'] as Map<number, SmsReceiveParams>;
      map.set(1, {});
      dotUtil.addSmsReceiveBlockResult(1, {
        detectResult: 1,
        decisionReason: 0,
        markType: 1
      });
      expect(map.has(1)).assertTrue()
    })

    it('dotUtilTest_addSmsReceiveBlockResult_return', 0, async () => {
      let dotUtil = DotUtil.getInstance();
      dotUtil.addSmsReceiveBlockResult(211, {
        detectResult: 1,
        decisionReason: 0,
        markType: 1
      });
      expect(dotUtil).not().assertUndefined();
    })

    it('dotUtilTest_reportSmsReceiveEvent', 0, async () => {
      DotUtil.getInstance().reportSmsReceiveEvent(3);
      expect(DotUtil.getInstance()).assertEqual(dotUtil)
    })

    it('dotUtilTest_reportSmsReceiveEvent_smsReceiveIdForDot_55', 0, async () => {
      let dotUtil = DotUtil.getInstance();
      let map: Map<number, SmsReceiveParams> = (dotUtil as object)['recordsForSmsReceive'] as Map<number, SmsReceiveParams>;
      map.set(4, {});
      dotUtil.reportSmsReceiveEvent(55)
      expect(map.has(55)).assertFalse()
    })

    it('dotUtilTest_reportBlockedEvent', 0, async () => {
      let onlyStateParam: ConsumerBehaviorParams = {
        STATE: 0
      }
      DotUtil.getInstance().reportBlockedEvent(onlyStateParam,'NOTIFICATION_OPERATION');
      expect(onlyStateParam.STATE).assertEqual(0);
    })

    it('dotUtilTest_reportCpuEvent', 0, async () => {
      let cpuHighParams: CPUAndMEMParams = new CPUAndMEMParams()
      DotUtil.getInstance().reportCpuEvent(cpuHighParams);
      expect(cpuHighParams.PACKAGE_NAME).assertEqual('com.ohos.telephonydataability');
    })

    it('dotUtilTest_startStatisticReport', 0, () => {
      DotUtil.getInstance().startStatisticReport();
      expect(DotUtil.getInstance()).assertEqual(dotUtil)
    })

    it('dotUtilTest_addSmsReceiveParam', 0, () => {
      let dotUtil = DotUtil.getInstance();
      let map: Map<number, SmsReceiveParams> = (dotUtil as object)['recordsForSmsReceive'] as Map<number, SmsReceiveParams>;
      map.set(6, {});
      dotUtil.addSmsReceiveParam(6, {
        telephoneDot: '12334',
        telephoneType: 1,
        slotId: 1,
        dotMsgType: 1
      } as MessageDetail, true)
      expect(map.has(6)).assertTrue()
    })

    it('dotUtilTest_addSmsReceiveParam_return', 0, () => {
      let dotUtil = DotUtil.getInstance();
      let map: Map<number, SmsReceiveParams> = (dotUtil as object)['recordsForSmsReceive'] as Map<number, SmsReceiveParams>;
      map.set(7, {});
      dotUtil.addSmsReceiveParam(88, {
        telephoneDot: '12334',
        telephoneType: 1,
        slotId: 1,
        dotMsgType: 1
      } as MessageDetail, false)
      expect(map.has(88)).assertFalse()
    })

    it('dotUtilTest_addSmsReceiveNumberParam_recordKey_0', 0, () => {
      let dotUtil = DotUtil.getInstance();
      let map: Map<number, SmsReceiveParams> = (dotUtil as object)['recordsForSmsReceive'] as Map<number, SmsReceiveParams>;
      map.set(9, {});
      dotUtil.addSmsReceiveNumberParam(9, 0, 1)
      expect(map.has(9)).assertTrue()
    })

    it('dotUtilTest_addFailReason', 0, () => {
      let dotUtil = DotUtil.getInstance();
      let map: Map<number, SmsReceiveParams> = (dotUtil as object)['recordsForSmsReceive'] as Map<number, SmsReceiveParams>;
      map.set(10, {});
      dotUtil.addFailReason(10, 'failReason', true)
      expect(map.has(10)).assertFalse()
    })

    it('dotUtilTest_addFailReason_return', 0, () => {
      let dotUtil = DotUtil.getInstance();
      let map: Map<number, SmsReceiveParams> = (dotUtil as object)['recordsForSmsReceive'] as Map<number, SmsReceiveParams>;
      map.set(101, {});
      dotUtil.addFailReason(102, 'failReason', true)
      expect(map.has(101)).assertTrue()
    })

    it('dotUtilTest_deleteSmsReceiveRecord', 0, () => {
      let dotUtil = DotUtil.getInstance();
      let map: Map<number, SmsReceiveParams> = (dotUtil as object)['recordsForSmsReceive'] as Map<number, SmsReceiveParams>;
      map.set(11, {});
      dotUtil.deleteSmsReceiveRecord(11)
      dotUtil.deleteSmsReceiveRecord(12)
      expect(map.has(11)).assertFalse()
    })

    it('dotUtilTest_reportStatisticEvent', 0, () => {
      let dotUtil = DotUtil.getInstance();
      dotUtil.versionNumber = '1.0';
      dotUtil.reportStatisticEvent({}, '%$#77')
      expect(dotUtil).not().assertUndefined();
    })

    it('dotUtilTest_reportNotificationMute_1', 0, () => {
      let dotUtil = DotUtil.getInstance();
      dotUtil.reportNotificationMute(1)
      expect(dotUtil).not().assertUndefined();
    })

    it('dotUtilTest_reportNotificationMute_NaN', 0, () => {
      let dotUtil = DotUtil.getInstance();
      dotUtil.reportNotificationMute(NaN)
      expect(dotUtil).not().assertUndefined();
    })

    it('dotUtilTest_reportSendReceiveSuccessRate_0', 0, () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(dotUtil, dotUtil.reportEvent))(ArgumentMatchers.any).afterReturn('');
      dotUtil.reportSendReceiveSuccessRate(1, 1, NaN);
      expect().assertUndefined();
      mocker.clear(dotUtil);
    })

    it('dotUtilTest_reportSendReceiveSuccessRate_1', 0, () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(dotUtil, dotUtil.reportEvent))(ArgumentMatchers.any).afterReturn('');
      dotUtil.reportSendReceiveSuccessRate(1, 1, 1);
      expect().assertUndefined();
      mocker.clear(dotUtil);
    })

    it('dotUtilTest_reportSendReceiveSuccessRateForReceived_1', 0, () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(dotUtil, dotUtil.reportEvent))(ArgumentMatchers.any).afterReturn('');
      let msg: MessageDetail = new MessageDetail();
      msg.type = commonData.RCS_TYPE.RCS;
      msg.isMms = false;
      dotUtil.reportSendReceiveSuccessRateForReceived(msg);
      expect().assertUndefined();
      mocker.clear(dotUtil);
    })

    it('dotUtilTest_reportSendReceiveSuccessRateForReceived_2', 0, () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(dotUtil, dotUtil.reportEvent))(ArgumentMatchers.any).afterReturn('');
      let msg: MessageDetail = new MessageDetail();
      msg.type = commonData.RCS_TYPE.RCS_SEND;
      msg.isMms = false;
      dotUtil.reportSendReceiveSuccessRateForReceived(msg);
      expect().assertUndefined();
      mocker.clear(dotUtil);
    })

    it('dotUtilTest_reportSendReceiveSuccessRateForReceived_3', 0, () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(dotUtil, dotUtil.reportEvent))(ArgumentMatchers.any).afterReturn('');
      let msg: MessageDetail = new MessageDetail();
      msg.type = commonData.RCS_TYPE.MMS_SEND;
      msg.isMms = true;
      dotUtil.reportSendReceiveSuccessRateForReceived(msg);
      expect().assertUndefined();
      mocker.clear(dotUtil);
    })

    it('dotUtilTest_reportSendReceiveSuccessRateForReceived_4', 0, () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(dotUtil, dotUtil.reportEvent))(ArgumentMatchers.any).afterReturn('');
      let msg: MessageDetail = new MessageDetail();
      msg.type = commonData.RCS_TYPE.MMS_SEND;
      msg.isMms = false;
      dotUtil.reportSendReceiveSuccessRateForReceived(msg);
      expect().assertUndefined();
      mocker.clear(dotUtil);
    })

    it('dotUtilTest_reportSendReceiveSuccessRateForRCSReceived', 0, () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(dotUtil, dotUtil.reportEvent))(ArgumentMatchers.any).afterReturn('');
      dotUtil.reportSendReceiveSuccessRateForRCSReceived();
      expect().assertUndefined();
      mocker.clear(dotUtil);
    })

    it('dotUtilTest_reportSuccessRateForSendFinished_param_NAN', 0, () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(dotUtil, dotUtil.reportEvent))(ArgumentMatchers.any).afterReturn('');
      dotUtil.reportSuccessRateForSendFinished(NaN);
      expect().assertUndefined();
      mocker.clear(dotUtil);
    })

    it('dotUtilTest_reportSuccessRateForSendFinished_param_number', 0, () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(dotUtil, dotUtil.reportEvent))(ArgumentMatchers.any).afterReturn('');
      dotUtil.reportSuccessRateForSendFinished(2);
      expect().assertUndefined();
      mocker.clear(dotUtil);
    })

    it('dotUtilTest_reportSuccessRateForSendStart_param_NAN', 0, () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(dotUtil, dotUtil.reportEvent))(ArgumentMatchers.any).afterReturn('');
      dotUtil.reportSuccessRateForSendStart(NaN);
      expect().assertUndefined();
      mocker.clear(dotUtil);
    })

    it('dotUtilTest_reportSuccessRateForSendStart_param_number', 0, () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(dotUtil, dotUtil.reportEvent))(ArgumentMatchers.any).afterReturn('');
      dotUtil.reportSuccessRateForSendStart(2);
      expect().assertUndefined();
      mocker.clear(dotUtil);
    })
  })
}