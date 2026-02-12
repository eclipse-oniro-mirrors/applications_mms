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
import SharedPreferencesUtils from '../SharedPreferencesUtils';
import common from '../../data/commonData';
import dotCommon, { settingSmartStatus, settingRcsStatus, settingAutoDelStatus, settingDownStatus, maliciousCheckStatus,
  settingReportStatus, settingAggregateStatus, settingShowHeadStatus } from './DotCommon';
import DotUtil from './DotUtils';
import Constant from '../../data/Constant';
import StringUtil from '../StringUtil';
import HiLog from '../HiLog';
const TAG:string = 'DotStateFunc';

export default class DotStateFunc {
  private static instance: DotStateFunc;

  public static getInstance(): DotStateFunc {
    if (!DotStateFunc.instance) {
      DotStateFunc.instance = new DotStateFunc();
    }
    return DotStateFunc.instance;
  }

  public getPreferenceSwitchValue(settingEventName: string, defaultValue: string): boolean {
    let getPreferenceSwitch = SharedPreferencesUtils.getFromPreferences(settingEventName, defaultValue) as string;
    let preferenceBoolean = false;
    if (getPreferenceSwitch == common.bool.TRUE) {
      preferenceBoolean = true;
    } else {
      preferenceBoolean = false;
    }
    return preferenceBoolean;
  }

  public getRcsSwitchValue() {
    let rcsSwitchValue: boolean = SharedPreferencesUtils.getFromPreferences('isUIOpenRcs', '') as boolean;
    if (rcsSwitchValue) {
      settingRcsStatus.RCS_SWITCH = 1;
    } else {
      settingRcsStatus.RCS_SWITCH = 2;
    }
    DotUtil.getInstance().reportStatisticEvent(settingRcsStatus, dotCommon.eventName.SETTING_RCS_MMS_STATE);
  }

  public async getSmartSwitchValue() {
    // let isOpenSmart = await SmartMmsSettingUtils.getSmartMmsValue('');
    let isOpenSmart = null;
    HiLog.i(TAG, 'getSmartSwitchValue isOpenSmart : ' + isOpenSmart);
    if (!StringUtil.isEmpty(isOpenSmart)) {
      // 首页智能短信的协议的弹窗: status true: 已经开启了,  false 没有开启
      if (isOpenSmart == Constant.SMART_SWITCH_OPEN) {
        settingSmartStatus.SMART_SWITCH = 1;
      } else {
        settingSmartStatus.SMART_SWITCH = 2;
      }
      DotUtil.getInstance().reportStatisticEvent(settingSmartStatus, dotCommon.eventName.SETTING_SMART_MMS_STATE);
    }
  }

  public getAggregateSwitchValue() {
    let aggregateSwitchValue = this.getPreferenceSwitchValue(common.STR.KEY_OF_INTEGRATION_SWITCH, common.bool.FALSE);
    if (aggregateSwitchValue) {
      settingAggregateStatus.AGGREGATE_STATE = 1;
    } else {
      settingAggregateStatus.AGGREGATE_STATE = 2;
    }
    DotUtil.getInstance().reportStatisticEvent(settingAggregateStatus, dotCommon.eventName.SETTING_AGGREGATE_STATUS);
  }

  public showContactIconValue() {
    let showContactHeadValue = this.getPreferenceSwitchValue(common.STR.KEY_OF_SHOW_CONTACT_SWITCH, common.bool.TRUE);
    if (showContactHeadValue) {
      settingShowHeadStatus.SHOW_HEAD_ICON = 1;
    } else {
      settingShowHeadStatus.SHOW_HEAD_ICON = 2;
    }
    DotUtil.getInstance().reportStatisticEvent(settingShowHeadStatus, dotCommon.eventName.SETTING_SHOW_HEAD_ICON_STATE);
  }

  public getDeliverReportSwitchValue() {
    // delivery_reports
    let deliveryReportSwitchValue = SharedPreferencesUtils.getFromPreferences(common.STR.KEY_OF_DELIVERY_REPORT_SWITCH,
      common.DELIVERY_REPORTS.DISABLED) as string;
    if (deliveryReportSwitchValue === common.DELIVERY_REPORTS.DISABLED) {
      settingReportStatus.DELIVERY_REPORT = 0;
    } else if (deliveryReportSwitchValue === common.DELIVERY_REPORTS.SMS) {
      settingReportStatus.DELIVERY_REPORT = 1;
    } else if (deliveryReportSwitchValue === common.DELIVERY_REPORTS.MMS) {
      settingReportStatus.DELIVERY_REPORT = 2;
    } else {
      settingReportStatus.DELIVERY_REPORT = 3;
    }
    DotUtil.getInstance().reportStatisticEvent(settingReportStatus, dotCommon.eventName.SETTING_DELIVERY_REPORT_STATE);
  }
}