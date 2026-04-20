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
import { ArgumentMatchers, describe, expect, it, MockKit, when} from '@ohos/hypium';
import {
  maliciousCheckStatus,
  settingAggregateStatus,
  settingAutoDelStatus,
  settingDownStatus,
  settingRcsStatus,
  settingReportStatus,
  settingShowHeadStatus,
  settingSmartStatus} from '../../../../../main/ets/utils/MmsDot/DotCommon';
import DotStateFunc from '../../../../../main/ets/utils/MmsDot/dotStateFunc';
import StringUtil from '../../../../../main/ets/utils/StringUtil';
import Constant from '../../../../../main/ets/data/Constant';
import DotUtil from '../../../../../main/ets/utils/MmsDot/DotUtils';
import SharedPreferencesUtils from '../../../../../main/ets/utils/SharedPreferencesUtils';

export default function dotStateFuncTest() {
  describe('dotStateFuncTest', () => {
    it('dotStateFuncTest_getPreferenceSwitchValue_getPreferenceSwitch_is_true', 0, async () => {
      let dotstatefunc: DotStateFunc = new DotStateFunc();
      let mocker: MockKit = new MockKit();
      let mockfunc: Function = mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences);
      when(mockfunc)(ArgumentMatchers.any).afterReturn(true);
      const result: ESObject = dotstatefunc.getPreferenceSwitchValue('key', '1');
      expect(result).assertEqual(true);
      mocker.ignoreMock(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences);
    });

    it('dotStateFuncTest_getPreferenceSwitchValue_getPreferenceSwitch_is_false', 0, async () => {
      let dotstatefunc: DotStateFunc = new DotStateFunc();
      let mocker: MockKit = new MockKit();
      let mockfunc: Function = mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences);
      when(mockfunc)(ArgumentMatchers.any).afterReturn(false);
      const result: ESObject = dotstatefunc.getPreferenceSwitchValue('key', '0');
      expect(result).assertEqual(false);
      mocker.ignoreMock(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences);
    });

    it('dotStateFuncTest_getPreferenceSwitchValue_getPreferenceSwitch_is_null', 0, async () => {
      let dotstatefunc: DotStateFunc = new DotStateFunc();
      let mocker: MockKit = new MockKit();
      let mockfunc: Function = mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences);
      when(mockfunc)(ArgumentMatchers.any).afterReturn(null);
      const result: ESObject = dotstatefunc.getPreferenceSwitchValue('key', '1');
      expect(result).assertEqual(false);
      mocker.ignoreMock(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences);
    });

    it('dotStateFuncTest_getPreferenceSwitchValue_getPreferenceSwitch_true_for_settingRcsStatus', 0, async () => {
      let dotstatefunc: DotStateFunc = new DotStateFunc();
      let mocker: MockKit = new MockKit();
      let mockfunc: Function = mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences);
      when(mockfunc)(ArgumentMatchers.any).afterReturn(true);
      const result: ESObject = dotstatefunc.getPreferenceSwitchValue('key', '0');
      expect(result).assertEqual(true);
      mocker.ignoreMock(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences);
    });

    it('dotStateFuncTest_getPreferenceSwitchValue_getPreferenceSwitch_false_for_settingRcsStatus', 0, async () => {
      let dotstatefunc: DotStateFunc = new DotStateFunc();
      let mocker: MockKit = new MockKit();
      let mockfunc: Function = mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences);
      when(mockfunc)(ArgumentMatchers.any).afterReturn(false);
      const result: ESObject = dotstatefunc.getPreferenceSwitchValue('key', '1');
      expect(result).assertEqual(false);
      mocker.ignoreMock(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences);
    });

    it('dotStateFuncTest_getPreferenceSwitchValue_getPreferenceSwitch_null_for_settingRcsStatus', 0, async () => {
      let dotstatefunc: DotStateFunc = new DotStateFunc();
      let mocker: MockKit = new MockKit();
      let mockfunc: Function = mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences);
      when(mockfunc)(ArgumentMatchers.any).afterReturn(null);
      const result: ESObject = dotstatefunc.getPreferenceSwitchValue('key', '1');
      expect(result).assertEqual(false);
      mocker.ignoreMock(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences);
    });

    it('dotStateFuncTest_getPreferenceSwitchValue_getPreferenceSwitch_true_for_settingAutoDelStatus', 0, async () => {
      let dotstatefunc: DotStateFunc = new DotStateFunc();
      let mocker: MockKit = new MockKit();
      let mockfunc: Function = mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences);
      when(mockfunc)(ArgumentMatchers.any).afterReturn(true);
      const result: ESObject = dotstatefunc.getPreferenceSwitchValue('key', '0');
      expect(result).assertEqual(true);
      mocker.ignoreMock(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences);
    });

    it('dotStateFuncTest_getPreferenceSwitchValue_getPreferenceSwitch_false_for_settingAutoDelStatus', 0, async () => {
      let dotstatefunc: DotStateFunc = new DotStateFunc();
      let mocker: MockKit = new MockKit();
      let mockfunc: Function = mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences);
      when(mockfunc)(ArgumentMatchers.any).afterReturn(false);
      const result: ESObject = dotstatefunc.getPreferenceSwitchValue('key', '1');
      expect(result).assertEqual(false);
      mocker.ignoreMock(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences);
    });

    it('dotStateFuncTest_getPreferenceSwitchValue_getPreferenceSwitch_null_for_settingAutoDelStatus', 0, async () => {
      let dotstatefunc: DotStateFunc = new DotStateFunc();
      let mocker: MockKit = new MockKit();
      let mockfunc: Function = mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences);
      when(mockfunc)(ArgumentMatchers.any).afterReturn(null);
      const result: ESObject = dotstatefunc.getPreferenceSwitchValue('key', '1');
      expect(result).assertEqual(false);
      mocker.ignoreMock(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences);
    });

    it('dotStateFuncTest_getPreferenceSwitchValue_getPreferenceSwitch_true_for_settingDownStatus', 0, async () => {
      let dotstatefunc: DotStateFunc = new DotStateFunc();
      let mocker: MockKit = new MockKit();
      let mockfunc: Function = mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences);
      when(mockfunc)(ArgumentMatchers.any).afterReturn(true);
      const result: ESObject = dotstatefunc.getPreferenceSwitchValue('key', '0');
      expect(result).assertEqual(true);
      mocker.ignoreMock(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences);
    });

    it('dotStateFuncTest_getPreferenceSwitchValue_getPreferenceSwitch_false_for_settingDownStatus', 0, async () => {
      let dotstatefunc: DotStateFunc = new DotStateFunc();
      let mocker: MockKit = new MockKit();
      let mockfunc: Function = mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences);
      when(mockfunc)(ArgumentMatchers.any).afterReturn(false);
      const result: ESObject = dotstatefunc.getPreferenceSwitchValue('key', '1');
      expect(result).assertEqual(false);
      mocker.ignoreMock(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences);
    });
    it('dotStateFuncTest_getRcsSwitchValue_rcsSwitchValue_is_true', 0, async () => {
      let dotstatefunc: DotStateFunc = DotStateFunc.getInstance();
      let mocker: MockKit = new MockKit();
      let mockGetFromPreferences: Function = mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences);
      when(mockGetFromPreferences)(ArgumentMatchers.any).afterReturn(true);

      dotstatefunc.getRcsSwitchValue();
      expect(settingRcsStatus.RCS_SWITCH).assertEqual(1);
      mocker.ignoreMock(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences);
    });

    it('dotStateFuncTest_getRcsSwitchValue_rcsSwitchValue_is_false', 0, async () => {
      let dotstatefunc: DotStateFunc = DotStateFunc.getInstance();
      let mocker: MockKit = new MockKit();
      let mockGetFromPreferences: Function = mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences);
      when(mockGetFromPreferences)(ArgumentMatchers.any).afterReturn(false);
      dotstatefunc.getRcsSwitchValue();
      expect(settingRcsStatus.RCS_SWITCH).assertEqual(2);

      mocker.ignoreMock(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences);
    });

    it('dotStateFuncTest_getAggregateSwitchValue_aggregateSwitchValue_is_true', 0, async () => {
      let dotstatefunc: DotStateFunc = DotStateFunc.getInstance();
      let mocker: MockKit = new MockKit();
      let dotUtil: ESObject = DotUtil.getInstance();
      let mockGetPreferenceSwitchValue: Function = mocker.mockFunc(dotstatefunc, dotstatefunc.getPreferenceSwitchValue);
      when(mockGetPreferenceSwitchValue)(ArgumentMatchers.any).afterReturn(true);

      let mockReportStatisticEvent: Function = mocker.mockFunc(dotUtil, dotUtil.reportStatisticEvent);
      when(mockReportStatisticEvent)(ArgumentMatchers.any).afterReturnNothing();
      dotstatefunc.getAggregateSwitchValue();

      expect(settingAggregateStatus.AGGREGATE_STATE).assertEqual(1);
      mocker.ignoreMock(dotstatefunc, dotstatefunc.getPreferenceSwitchValue);
    });

    it('dotStateFuncTest_getAggregateSwitchValue_aggregateSwitchValue_is_false', 0, async () => {
      let dotstatefunc: DotStateFunc = DotStateFunc.getInstance();
      let mocker: MockKit = new MockKit();
      let dotUtil: ESObject = DotUtil.getInstance();
      let mockGetPreferenceSwitchValue: Function = mocker.mockFunc(dotstatefunc, dotstatefunc.getPreferenceSwitchValue);
      when(mockGetPreferenceSwitchValue)(ArgumentMatchers.any).afterReturn(false);

      let mockReportStatisticEvent: Function = mocker.mockFunc(dotUtil, dotUtil.reportStatisticEvent);
      when(mockReportStatisticEvent)(ArgumentMatchers.any).afterReturnNothing();

      dotstatefunc.getAggregateSwitchValue();

      expect(settingAggregateStatus.AGGREGATE_STATE).assertEqual(2);
      mocker.ignoreMock(dotstatefunc, dotstatefunc.getPreferenceSwitchValue);
    });
    it('dotStateFuncTest_showContactIconValue_getPreferenceSwitchValue_returns_true', 0, async () => {
      let dotstatefunc: DotStateFunc = DotStateFunc.getInstance();
      let mocker: MockKit = new MockKit();
      let mockfunc: Function = mocker.mockFunc(dotstatefunc, dotstatefunc.getPreferenceSwitchValue);
      when(mockfunc)(ArgumentMatchers.any).afterReturn(true);
      let dotUtil: ESObject = DotUtil.getInstance();
      let mockReportFunc: Function = mocker.mockFunc(dotUtil, dotUtil.reportStatisticEvent);
      when(mockReportFunc)(ArgumentMatchers.any).afterReturnNothing();

      dotstatefunc.showContactIconValue();

      expect(settingShowHeadStatus.SHOW_HEAD_ICON).assertEqual(1);
      mocker.ignoreMock(dotstatefunc, dotstatefunc.getPreferenceSwitchValue);
    });

    it('dotStateFuncTest_showContactIconValue_getPreferenceSwitchValue_returns_false', 0, async () => {
      let dotstatefunc: DotStateFunc = DotStateFunc.getInstance();
      let mocker: MockKit = new MockKit();
      let mockfunc: Function = mocker.mockFunc(dotstatefunc, dotstatefunc.getPreferenceSwitchValue);
      when(mockfunc)(ArgumentMatchers.any).afterReturn(false);
      let dotUtil: ESObject = DotUtil.getInstance();
      let mockReportFunc: Function = mocker.mockFunc(dotUtil, dotUtil.reportStatisticEvent);
      when(mockReportFunc)(ArgumentMatchers.any).afterReturnNothing();

      dotstatefunc.showContactIconValue();

      expect(settingShowHeadStatus.SHOW_HEAD_ICON).assertEqual(2);
      mocker.ignoreMock(dotstatefunc, dotstatefunc.getPreferenceSwitchValue);
    });
    it('dotStateFuncTest_getDeliverReportSwitchValue_deliveryReportSwitchValue_is_DISABLED', 0, async () => {
      let mocker: MockKit = new MockKit();
      let mockGetFromPreferences: Function = mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences);
      when(mockGetFromPreferences)(ArgumentMatchers.any).afterReturn('0');

      let dotstatefunc: DotStateFunc = DotStateFunc.getInstance();
      dotstatefunc.getDeliverReportSwitchValue();

      expect(settingReportStatus.DELIVERY_REPORT).assertEqual(0);
      mocker.ignoreMock(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences);
    });

    it('dotStateFuncTest_getDeliverReportSwitchValue_deliveryReportSwitchValue_is_SMS', 0, async () => {
      let mocker: MockKit = new MockKit();
      let mockGetFromPreferences: Function = mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences);
      when(mockGetFromPreferences)(ArgumentMatchers.any).afterReturn('1');

      let dotstatefunc: DotStateFunc = DotStateFunc.getInstance();
      dotstatefunc.getDeliverReportSwitchValue();

      expect(settingReportStatus.DELIVERY_REPORT).assertEqual(1);
      mocker.ignoreMock(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences);
    });

    it('dotStateFuncTest_getDeliverReportSwitchValue_deliveryReportSwitchValue_is_MMS', 0, async () => {
      let mocker: MockKit = new MockKit();
      let mockGetFromPreferences: Function = mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences);
      when(mockGetFromPreferences)(ArgumentMatchers.any).afterReturn('2');

      let dotstatefunc: DotStateFunc = DotStateFunc.getInstance();
      dotstatefunc.getDeliverReportSwitchValue();

      expect(settingReportStatus.DELIVERY_REPORT).assertEqual(2);
      mocker.ignoreMock(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences);
    });

    it('dotStateFuncTest_getDeliverReportSwitchValue_deliveryReportSwitchValue_is_other_value', 0, async () => {
      let mocker: MockKit = new MockKit();
      let mockGetFromPreferences: Function = mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences);
      when(mockGetFromPreferences)(ArgumentMatchers.any).afterReturn("OTHER_VALUE");

      let dotstatefunc: DotStateFunc = DotStateFunc.getInstance();
      dotstatefunc.getDeliverReportSwitchValue();

      expect(settingReportStatus.DELIVERY_REPORT).assertEqual(3);
      mocker.ignoreMock(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences);
    });

    it('dotStateFuncTest_getDeliverReportSwitchValue_deliveryReportSwitchValue_is_not_DISABLED', 0, async () => {
      let mocker: MockKit = new MockKit();
      let dotUtil: ESObject = DotUtil.getInstance();
      let mockGetFromPreferences: Function = mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences);
      when(mockGetFromPreferences)(ArgumentMatchers.any).afterReturn('1');

      let mockReportStatisticEvent: Function = mocker.mockFunc(dotUtil, dotUtil.reportStatisticEvent);
      when(mockReportStatisticEvent)(ArgumentMatchers.any).afterReturnNothing();

      let dotstatefunc: DotStateFunc = DotStateFunc.getInstance();
      dotstatefunc.getDeliverReportSwitchValue();
      expect(dotstatefunc).not().assertUndefined();

      mocker.ignoreMock(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences);
    });
  })
}