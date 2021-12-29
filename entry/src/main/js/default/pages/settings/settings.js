/**
 * Copyright (c) 2021 Huawei Device Co., Ltd.
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
import mmsLog from '../../../default/utils/MmsLog.js';
import router from '@system.router';
import prompt from '@system.prompt';
// JS公共常量
import common from '../common_constants.js';
import settingService from '../../service/SettingService.js'

const TAG = 'JS->setting.js->';

export default {
    data: {
        // 通知信息整合
        integrationSwitch: null,
        // 恶意网站选择
        maliciousWebSwitch: null,
        // 显示联系人头像
        showContactSwitch: null,
    },
    onInit() {
        mmsLog.info(TAG + 'onInit(): start');
    },
    onShow() {
        this.getSettingPageSwitchValue();
    },
    // 初始化setting页面的开关
    getSettingPageSwitchValue() {
        mmsLog.info(TAG + 'initializeSettingPage(): start');
        let preferences = this.$app.$def.preferences;
        settingService.setOnSettingValueListener(preferences, this.initializeSettingData);
    },
    // 初始化setting数据
    initializeSettingData(data) {
        let that = this;
        that.integrationSwitch = data.integrationSwitch;
        that.maliciousWebSwitch = data.maliciousWebSwitch;
        that.showContactSwitch = data.showContactSwitch;
    },
    // 通知信息整合
    integration(e) {
        let messageCode = common.route.MESSAGE_CODE_UPDATE_ARCHIVE_INFO_MESSAGES_VALUE;
        let actionData = {};
        this.integrationSwitch = e.checked;
        if(this.integrationSwitch) {
            actionData.booleanValue = common.bool.TRUE;
        } else {
            actionData.booleanValue = common.bool.FALSE;
        }
        actionData.preferences = this.$app.$def.preferences;
        this.updateSettingPageSwitchValue(messageCode, actionData);
    },
    // 恶意网站选择
    maliciousWeb(e) {
        mmsLog.info(TAG + 'maliciousWeb(): value = ' + e.checked);
        let messageCode = common.route.MESSAGE_CODE_UPDATE_MALICIOUS_WEBSITE_IDENTIFICATION_VALUE;
        let actionData = {};
        this.maliciousWebSwitch = e.checked;
        if(this.maliciousWebSwitch) {
            actionData.booleanValue = common.bool.TRUE;
        } else {
            actionData.booleanValue = common.bool.FALSE;
        }
        actionData.preferences = this.$app.$def.preferences;
        this.updateSettingPageSwitchValue(messageCode, actionData);
    },
    // 跳转至'信息铃声页面，在设置->声音和振动->信息铃声'
    jumpToMessageTonePage() {
    },
    // 显示联系人的头像
    showContact(e) {
        mmsLog.info(TAG + 'showContact(): value = ' + e.checked);
        let messageCode = common.route.MESSAGE_CODE_UPDATE_SHOW_CONTACT_PROFILE_PICS_VALUE;
        let actionData = {};
        this.showContactSwitch = e.checked;
        actionData.preferences = this.$app.$def.preferences;
        if (this.showContactSwitch) {
            actionData.booleanValue = common.bool.TRUE;
        } else {
            actionData.booleanValue = common.bool.FALSE;
        }
        this.updateSettingPageSwitchValue(messageCode, actionData);
    },
    // 展示还原配置的弹框
    showDialog() {
        let that = this;
        prompt.showDialog({
            message: this.$t('strings.restore_all_default_settings'),
            buttons: [
                {text: this.$t('strings.cancel'), color: '#007DFF'},
                {text: this.$t('strings.restore'), color: '#007DFF'}
            ],
            success: function (data) {
                if (data.index == 1) {
                    that.restoreSettingsPageSwitchValue();
                }
            }
        });
    },
    // 还原设置页面的默认值
    restoreSettingsPageSwitchValue() {
        let that = this;
        let preferences = this.$app.$def.preferences;
        settingService.restoreSwitchValue(preferences, function (result) {
            if (result.code === common.int.SUCCESS) {
                that.integrationSwitch = true;
                that.maliciousWebSwitch = false;
                that.showContactSwitch = true;
                mmsLog.info(TAG + 'restoreSettingsPageSwitchValue(): success');
            } else {
                mmsLog.info(TAG + 'restoreSettingsPageSwitchValue(): fail');
            }
        });
    },
    // 返回按钮
    back() {
        router.back();
    },
    // 高级 页目跳转
    advancedSetting() {
        router.push({
            uri: 'pages/advanced_settings/advanced_settings'
        });
    },
    // 更新开关值
    updateSettingPageSwitchValue(messageCode, actionData) {
        mmsLog.info(TAG + 'updateSettingPageSwitchValue(): start, msgCode = ' + messageCode);
        settingService.updateSettingValue(messageCode, actionData, function (result) {
            if (result.code == common.int.SUCCESS) {
                mmsLog.info(TAG + 'updateSettingPageSwitchValue(): success');
            } else {
                mmsLog.info(TAG + 'updateSettingPageSwitchValue(): fail');
            }
        });
    }
}
