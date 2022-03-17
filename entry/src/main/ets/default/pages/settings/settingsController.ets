/**
 * Copyright (c) 2022 Huawei Device Co., Ltd.
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
import appStorage from '../../utils/AppStorageUtil';
import LooseObject from '../../data/LooseObject'
import HiLog from '../../utils/HiLog';
import router from '@system.router';
import prompt from '@system.prompt';
// JS公共常量
import common from '../../data/commonData';
import settingService from '../../service/SettingService'

let sSettingsCtrl;

const TAG = 'SettingsController';

export default class SettingsController{
  // 通知信息整合
  integrationSwitch: boolean = false;
  // 恶意网站选择
  maliciousWebSwitch: boolean = false;
  // 显示联系人头像
  showContactSwitch: boolean = false

  static getInstance() {
    if(sSettingsCtrl == null) {
      sSettingsCtrl = new SettingsController();
      appStorage.setAndLink(TAG, sSettingsCtrl);
    }
    return sSettingsCtrl;
  }

  onInit() {
    HiLog.i(TAG, 'onInit, start');
  };

  onShow() {
    this.getSettingPageSwitchValue();
  };

  // 初始化setting页面的开关
  getSettingPageSwitchValue() {
    HiLog.i(TAG, 'getSettingPageSwitchValue, start');
    settingService.setOnSettingValueListener(this.initializeSettingData);
  };

  // 初始化setting数据
  initializeSettingData(data) {
    this.integrationSwitch = data.integrationSwitch;
    this.maliciousWebSwitch = data.maliciousWebSwitch;
    this.showContactSwitch = data.showContactSwitch;
  };

  // 通知信息整合
  integration(e) {
    let messageCode = common.route.MESSAGE_CODE_UPDATE_ARCHIVE_INFO_MESSAGES_VALUE;
    let actionData: LooseObject = {};
    this.integrationSwitch = e.checked;
    if(this.integrationSwitch) {
      actionData.booleanValue = common.bool.TRUE;
    } else {
      actionData.booleanValue = common.bool.FALSE;
    }
    this.updateSettingPageSwitchValue(messageCode, actionData);
  };

  // 恶意网站选择
  maliciousWeb(e) {
    HiLog.i(TAG, 'maliciousWeb, checked = ' + e.checked);
    let messageCode = common.route.MESSAGE_CODE_UPDATE_MALICIOUS_WEBSITE_IDENTIFICATION_VALUE;
    let actionData: LooseObject = {};
    this.maliciousWebSwitch = e.checked;
    if(this.maliciousWebSwitch) {
      actionData.booleanValue = common.bool.TRUE;
    } else {
      actionData.booleanValue = common.bool.FALSE;
    }
    this.updateSettingPageSwitchValue(messageCode, actionData);
  };

  // 跳转至'信息铃声页面，在设置->声音和振动->信息铃声'
  jumpToMessageTonePage() {
    HiLog.i(TAG, 'jumpToMessageTonePage')
  };

  // 显示联系人的头像
  showContact(e) {
    HiLog.i(TAG, 'showContact, checked = ' + e.checked);
    let messageCode = common.route.MESSAGE_CODE_UPDATE_SHOW_CONTACT_PROFILE_PICS_VALUE;
    let actionData: LooseObject = {};
    this.showContactSwitch = e.checked;
    if (this.showContactSwitch) {
      actionData.booleanValue = common.bool.TRUE;
    } else {
      actionData.booleanValue = common.bool.FALSE;
    }
    this.updateSettingPageSwitchValue(messageCode, actionData);
  };

  // 还原设置页面的默认值
  restoreSettingsPageSwitchValue() {
    settingService.restoreSwitchValue(function (result) {
      if (result.code === common.int.SUCCESS) {
        this.integrationSwitch = true;
        this.maliciousWebSwitch = false;
        this.showContactSwitch = true;
        HiLog.i(TAG, 'restoreSettingsPageSwitchValue, success');
      } else {
        HiLog.w(TAG, 'restoreSettingsPageSwitchValue, failed');
      }
    });
  };

  // 返回按钮
  back() {
    router.back();
  };

  // 高级 页目跳转
  advancedSetting() {
    HiLog.i(TAG, 'advancedSetting')
    router.push({
      uri: 'pages/settings/advancedSettings/advancedSettings'
    });
  };

  // 更新开关值
  updateSettingPageSwitchValue(messageCode, actionData) {
    HiLog.i(TAG, 'updateSettingPageSwitchValue,  messageCode = ' + messageCode);
    settingService.updateSettingValue(messageCode, actionData, function (result) {
      if (result.code == common.int.SUCCESS) {
        HiLog.i(TAG, 'updateSettingPageSwitchValue, success');
      } else {
        HiLog.w(TAG, 'updateSettingPageSwitchValue, failed');
      }
    });
  };
}