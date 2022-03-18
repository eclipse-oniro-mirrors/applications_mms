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
import appStorage from '../../../utils/AppStorageUtil';
import LooseObject from '../../../data/LooseObject'
import HiLog from '../../../utils/HiLog';
import router from '@system.router';
import prompt from '@system.prompt';
import settingService from '../../../service/SettingService'
import common from '../../../data/commonData';

const TAG = 'AdvancedSettingsController';

let sAdvancedSettingsCtrl;

export default class AdvancedSettingsController {
  // 送达报告短信
  checkedValueOfSms: boolean = false;
  // 送达报告彩信
  checkedValueOfMms: boolean = false;
  // 送达报告开关的值
  deliveryReportSwitch: string = common.DELIVERY_REPORTS.DISABLED;
  // 送达报告文本
  deliveryReportSwitchInText: Resource | string = $r('app.string.disabled');
  // 自动下载彩信开关
  autoRetrieveMmsSwitch: string = common.AUTO_RETRIEVE_MMS.OFF;
  // 自动下载彩信开关文本
  autoRetrieveMmsSwitchInText: Resource | string = $r('app.string.off');
  // 取消发送开关
  recallMessageSwitch: string = common.bool.FALSE;
  // 自动删除通知信息开关
  autoDeleteInfoSwitch: string = common.bool.FALSE;
  // 自动删除通知信息开关，临时变量
  tempAutoDeleteInfoSwitch: string = common.bool.FALSE;
  // 中国电信
  snpNameOfChinaTelecom : string = '';
  // sim卡的数量
  simCount: number = 0;
  // 如果是1张卡，运营商的名字
  spnNameOfOneSimCard: string = '';
  // 如果是2张卡，卡1运营商的名字
  firstSpnNameOfTwoSimCard: string = '';
  // 如果是2张卡，卡2运营商的名字
  secondSpnNameOfTwoSimCard: string = '';

  static getInstance() {
    sAdvancedSettingsCtrl = appStorage.Link('AdvancedSettingsController');
    if (sAdvancedSettingsCtrl == null) {
      sAdvancedSettingsCtrl = new AdvancedSettingsController();
      appStorage.setAndLink('AdvancedSettingsController', sAdvancedSettingsCtrl);
    }
    return sAdvancedSettingsCtrl;
  }

  constructor() {
    HiLog.i(TAG, 'constructor, start');
    this.getAdvancedPageSwitchValue();
  }

  onInit() {
    HiLog.i(TAG, 'onInit, start');
  }
  onShow() {
    HiLog.i(TAG, 'onShow, start');
  }
  getAdvancedPageSwitchValue() {
    HiLog.i(TAG, 'getAdvancedPageSwitchValue, start');
    let that = this;
    settingService.getAdvancedPageSwitchValue(function (result) {
      if (result.code === common.int.SUCCESS) {
        let switchValue = result.abilityResult;
        that.deliveryReportSwitch = switchValue.deliveryReportSwitch;
        that.returnDeliveryReportResultInText(that.deliveryReportSwitch);
        that.autoRetrieveMmsSwitch = switchValue.autoRetrieveMmsSwitch;
        that.returnAutoRetrieveMmsResultInText(that.autoRetrieveMmsSwitch);
        that.recallMessageSwitch = switchValue.recallMessageSwitch;
        that.autoDeleteInfoSwitch = switchValue.autoDeleteInfoSwitch;
        that.tempAutoDeleteInfoSwitch = that.autoDeleteInfoSwitch;
        // 等sim卡功能好,需要换成 switchValue.simCount;
        that.simCount = switchValue.simCount;
        if (that.simCount === 2) {
          that.firstSpnNameOfTwoSimCard = switchValue.firstSpnNameOfTwoSimCard;
          that.secondSpnNameOfTwoSimCard = switchValue.secondSpnNameOfTwoSimCard;
        } else {
          that.spnNameOfOneSimCard = switchValue.spnNameOfOneSimCard;
        }
      } else {
        HiLog.w(TAG, 'getAdvancedPageSwitchValue, failed');
      }
    });
  }
  // 根据整数值返回文本版的送达报告结果
  returnDeliveryReportResultInText(intValue) {
    let tempValue;
    if (intValue == common.DELIVERY_REPORTS.DISABLED) {
      tempValue = $r('app.string.disabled');
      this.checkedValueOfSms = false;
      this.checkedValueOfMms = false;
    } else if (intValue == common.DELIVERY_REPORTS.SMS) {
      tempValue = $r('app.string.sms');
      this.checkedValueOfSms = true;
      this.checkedValueOfMms = false;
    } else if (intValue == common.DELIVERY_REPORTS.MMS) {
      tempValue = $r('app.string.mms');
      this.checkedValueOfSms = false;
      this.checkedValueOfMms = true;
    } else {
      tempValue = $r('app.string.sms_and_mms');
      this.checkedValueOfSms = true;
      this.checkedValueOfMms = true;
    }
    this.deliveryReportSwitchInText = tempValue;
  }
  // 根据整数值返回文本版的送达报告结果
  returnAutoRetrieveMmsResultInText(intValue) {
    let tempValue;
    if (intValue == common.AUTO_RETRIEVE_MMS.OFF) {
      tempValue = $r('app.string.off');
    } else if (intValue == common.AUTO_RETRIEVE_MMS.NOT_WHEN_ROAMING) {
      tempValue = $r('app.string.not_when_roaming');
    } else {
      tempValue = $r('app.string.always');
    }
    this.autoRetrieveMmsSwitchInText = tempValue;
  }
  // 返回按键
  back() {
    router.back();
  }
  // 还原设置页面的默认值
  restoreSettingPageSwitchValue() {
    HiLog.i(TAG, 'restoreSettingPageSwitchValue');
    let that = this;
    settingService.restoreSwitchValue(function (result) {
      if (result.code === common.int.SUCCESS) {
        that.deliveryReportSwitch = common.DELIVERY_REPORTS.DISABLED;
        that.returnDeliveryReportResultInText(common.DELIVERY_REPORTS.DISABLED);
        that.autoRetrieveMmsSwitch = common.AUTO_RETRIEVE_MMS.NOT_WHEN_ROAMING;
        that.returnAutoRetrieveMmsResultInText(common.AUTO_RETRIEVE_MMS.NOT_WHEN_ROAMING);
        that.recallMessageSwitch = common.bool.FALSE;
        that.autoDeleteInfoSwitch = common.bool.FALSE;
        that.tempAutoDeleteInfoSwitch = common.bool.FALSE;
        HiLog.i(TAG, 'restoreSettingPageSwitchValue, success');
      } else {
        HiLog.w(TAG, 'restoreSettingPageSwitchValue, failed');
      }
    });
  }
  // 点击短信那行
  clickSmsDiv() {
    this.checkedValueOfSms = !this.checkedValueOfSms;
  }
  // 点击短信那行的checkbox
  clickSmsCheckbox(e) {
    this.checkedValueOfSms = e.checked;
  }
  // 点击彩信那行
  clickMmsDiv() {
    this.checkedValueOfMms = !this.checkedValueOfMms;
  }
  // 点击彩信那行的checkbox
  clickMmsCheckbox(e) {
    this.checkedValueOfMms = e.checked;
  }
  // 取消还原配置的弹框
  cancelRestore() {
    this.returnDeliveryReportResultInText(this.deliveryReportSwitch);
  }
  // 送达报告dialog，确定
  setRestore() {
    this.deliveryReportSwitch = common.string.EMPTY_STR;
    if (this.checkedValueOfSms && this.checkedValueOfMms) {
      this.deliveryReportSwitch = common.DELIVERY_REPORTS.SMS_AND_MMS;
    } else if(this.checkedValueOfSms) {
      this.deliveryReportSwitch = common.DELIVERY_REPORTS.SMS;
    } else if(this.checkedValueOfMms) {
      this.deliveryReportSwitch = common.DELIVERY_REPORTS.MMS;
    } else {
      this.deliveryReportSwitch = common.DELIVERY_REPORTS.DISABLED;
    }
    this.returnDeliveryReportResultInText(this.deliveryReportSwitch);
    this.autoHandleDeliveryReportValueChange(this.deliveryReportSwitch);
  }
  // 当deliveryReportSwitch开关的值变化时，由该方法处理
  autoHandleDeliveryReportValueChange(newValue) {
    HiLog.i(TAG, 'autoHandleDeliveryReportValueChange, newValue = ' + newValue);
    let messageCode = common.route.MESSAGE_CODE_UPDATE_DELIVERY_REPORTS_VALUE;
    let actionData: LooseObject = {};
    actionData.intValue = newValue;
    this.updateAdvancedPageSwitchValue(messageCode, actionData);
  }
  // 显示'自动下载彩信'dialog
  showAutoRetrieveMmsDialog() {
//    this.$element('auto-retrieve-mms-dialog').show();
  }
  // 点击'自动下载彩信'dialog内相应的选项
  clickDiv(idx) {
    this.autoRetrieveMmsSwitch = idx + common.string.EMPTY_STR;
    this.returnAutoRetrieveMmsResultInText(idx);
//    this.$element('auto-retrieve-mms-dialog').close();
    this.autoHandleAutoRetrieveMmsValueChange(this.autoRetrieveMmsSwitch);
  }
  // 关闭'自动下载彩信'dialog
  closeAutoRetrieveMmsDialog() {
//    this.$element('auto-retrieve-mms-dialog').close();
  }
  // 当autoRetrieveMmsSwitch开关的值变化时，由该方法处理
  autoHandleAutoRetrieveMmsValueChange(newValue) {
    HiLog.i(TAG, 'autoHandleAutoRetrieveMmsValueChange, newValue = ' + newValue);
    let messageCode = common.route.MESSAGE_CODE_UPDATE_AUTO_RETRIEVE_MMS_VALUE;
    let actionData: LooseObject = {};
    actionData.intValue = newValue;
    this.updateAdvancedPageSwitchValue(messageCode, actionData);
  }
  // 取消发送
  recallMsg(e) {
    let messageCode = common.route.MESSAGE_CODE_UPDATE_RECALL_MESSAGES_VALUE;
    let actionData: LooseObject = {};
    this.recallMessageSwitch = e.checked;
    if (this.recallMessageSwitch) {
      actionData.booleanValue = common.bool.TRUE;
    } else {
      actionData.booleanValue = common.bool.FALSE;
    }
    this.updateAdvancedPageSwitchValue(messageCode, actionData);
  }
  // 自动删除通知信息
  autoDeleteInfo(e) {
    let that = this;
    that.tempAutoDeleteInfoSwitch = e.checked;
    if (e.checked) {
      prompt.showDialog({
        title: $r('app.string.enable_auto_delete') + '',
        message: $r('app.string.enable_auto_delete_hint') + '',
        buttons: [
          {text: $r('app.string.cancel') + '', color: '#007DFF'},
          {text: $r('app.string.enable') + '', color: '#007DFF'}
        ],
        success: function (data) {
          that.autoDeleteSuccess(data);
        },
        cancel: function () {
          HiLog.i(TAG, 'autoDeleteInfo, cancel');
          that.tempAutoDeleteInfoSwitch = common.bool.FALSE;
          that.autoDeleteInfoSwitch = common.bool.FALSE;
        }
      });
    } else {
      that.autoDeleteInfoSwitch = common.bool.FALSE;
      that.autoHandleAutoDeleteInfoValueChange(common.bool.FALSE);
    }
  }
  autoDeleteSuccess(data) {
    if (data.index == 0) {
      this.tempAutoDeleteInfoSwitch = common.bool.FALSE;
    } else {
      this.autoDeleteInfoSwitch = common.bool.TRUE;
      this.autoHandleAutoDeleteInfoValueChange(common.bool.TRUE);
    }
  }
  // 当autoDeleteInfoSwitch开关的值变化时，由该方法处理
  autoHandleAutoDeleteInfoValueChange(newValue) {
    HiLog.i(TAG, 'autoHandleAutoDeleteInfoValueChange, newValue = ' + newValue);
    let messageCode = common.route.MESSAGE_CODE_UPDATE_AUTO_DELETE_INFO_MESSAGES_VALUE;
    let actionData: LooseObject = {};
    actionData.booleanValue = newValue;
    this.updateAdvancedPageSwitchValue(messageCode, actionData);
  }
  // 跳转至'短信中心'页面
  jumpToSmsCenterPage(index) {
    if (this.simCount == 0) {
      return;
    }
    router.push({
      uri: 'pages/sms_center/sms_center',
      params: {
        idx: index,
        countOfSim: this.simCount
      }
    });
  }
  // 跳转至'管理Sim卡'页面
  jumpToManageSimPage(index) {
    if (this.simCount == 0) {
      return;
    }
    router.push({
      uri: 'pages/manage_sim/manage_sim',
      params: {
        idx: index,
        countOfSim: this.simCount
      }
    });
  }
  // 更新开关值
  updateAdvancedPageSwitchValue(messageCode, actionData) {
    settingService.updateSettingValue(messageCode, actionData, function (result) {
      if (result.code == common.int.SUCCESS) {
        HiLog.i(TAG, 'updateAdvancedPageSwitchValue, success');
      } else {
        HiLog.w(TAG, 'updateAdvancedPageSwitchValue, failed');
      }
    });
  }
}