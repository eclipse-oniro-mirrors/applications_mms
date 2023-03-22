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
import LooseObject from "../../data/LooseObject"
import MmsBoolean from "../../data/MmsBoolean"
import HiLog from "../../utils/HiLog";
import router from "@system.router";
// JS Common constants
import common from "../../data/commonData";
import settingService from "../../service/SettingService"

const TAG = "SettingsController";

export default class SettingsController {
    private static sInstance: SettingsController;
    // Notification information integration
    integrationSwitch: MmsBoolean = new MmsBoolean(true);
    // Malicious website selection
    maliciousWebSwitch: boolean = false;
    // Verification code security protection
    verificationCodeSwitch: boolean = false;
    // Display contact avatar
    showContactSwitch: boolean = true

    static getInstance() {
        if (SettingsController.sInstance == null) {
            SettingsController.sInstance = new SettingsController();
        }
        return SettingsController.sInstance;
    }

    constructor() {
        HiLog.i(TAG, "constructor, start");
        this.getSettingPageSwitchValue();
    }

    onInit() {
        HiLog.i(TAG, "onInit, start");
    };

    onShow() {
        HiLog.i(TAG, "onShow, start");
    };

    // Indicates whether to initialize the setting page.
    getSettingPageSwitchValue() {
        HiLog.i(TAG, "getSettingPageSwitchValue, start");
        let that = this;
        settingService.setOnSettingValueListener(function (result) {
            that.integrationSwitch.value = result.integrationSwitch;
            that.maliciousWebSwitch = result.maliciousWebSwitch;
            that.showContactSwitch = result.showContactSwitch;
        });
    };

    // Notification information integration
    integration(isOn: boolean) {
        let messageCode = common.route.MESSAGE_CODE_UPDATE_ARCHIVE_INFO_MESSAGES_VALUE;
        if (this.integrationSwitch.value != isOn) {
            globalThis.needToUpdate = true;
        }
        let actionData: LooseObject = {};
        this.integrationSwitch.value = isOn;
        if (this.integrationSwitch.value) {
            actionData.booleanValue = common.bool.TRUE;
        } else {
            actionData.booleanValue = common.bool.FALSE;
        }
        this.updateSettingPageSwitchValue(messageCode, actionData);
    };

    // Malicious website selection
    maliciousWeb(e) {
        HiLog.i(TAG, "maliciousWeb, checked = " + e.checked);
        let messageCode = common.route.MESSAGE_CODE_UPDATE_MALICIOUS_WEBSITE_IDENTIFICATION_VALUE;
        let actionData: LooseObject = {};
        this.maliciousWebSwitch = e.checked;
        if (this.maliciousWebSwitch) {
            actionData.booleanValue = common.bool.TRUE;
        } else {
            actionData.booleanValue = common.bool.FALSE;
        }
        this.updateSettingPageSwitchValue(messageCode, actionData);
    };

    // Go to the Message Ring page. Choose Settings > Sound and Vibration > Message Ring.
    jumpToMessageTonePage() {
        HiLog.i(TAG, "jumpToMessageTonePage")
    };

    // Display a contact's avatar
    showContact(e) {
        HiLog.i(TAG, "showContact, checked = " + e.checked);
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

    // Restore the default values on the settings page.
    restoreSettingsPageSwitchValue() {
        let that = this;
        settingService.restoreSwitchValue(function (result) {
            if (result.code === common.int.SUCCESS) {
                that.integrationSwitch.value = true;
                that.maliciousWebSwitch = false;
                that.showContactSwitch = true;
                globalThis.needToUpdate = true;
                HiLog.i(TAG, "restoreSettingsPageSwitchValue, success");
            } else {
                HiLog.w(TAG, "restoreSettingsPageSwitchValue, failed");
            }
        });
    };

    // Back button
    back() {
        router.back();
    };

    // Advanced page redirection
    advancedSetting() {
        HiLog.i(TAG, "advancedSetting")
        router.push({
            uri: "pages/settings/advancedSettings/advancedSettings"
        });
    };

    // Update Switch Value
    updateSettingPageSwitchValue(messageCode, actionData) {
        HiLog.i(TAG, "updateSettingPageSwitchValue,  messageCode = " + messageCode);
        settingService.updateSettingValue(messageCode, actionData, function (result) {
            if (result.code == common.int.SUCCESS) {
                HiLog.i(TAG, "updateSettingPageSwitchValue, success");
            } else {
                HiLog.w(TAG, "updateSettingPageSwitchValue, failed");
            }
        });
    };
}