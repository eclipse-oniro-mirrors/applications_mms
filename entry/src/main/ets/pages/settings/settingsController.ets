/**
 * Copyright (c) 2022 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import LooseObject from '../../data/LooseObject';
import MmsBoolean from '../../data/MmsBoolean';
import HiLog from '../../utils/HiLog';
import { BusinessError } from '@ohos.base';
// JS Common constants
import common from '../../data/commonData';
import settingService from '../../service/SettingService';
import { GlobalContext } from '../../MainAbility/GlobalHelper';
import myCommon from '@ohos.app.ability.common';
// import rcs from '@ohos.telephony.rcs';
import SharedPreferencesUtils from '../../utils/SharedPreferencesUtils';
import MmsPreferences from '../../utils/MmsPreferences';
import Want from '@ohos.app.ability.Want';
import MmsRingtoneManager from '../../utils/SystemSoundManagerUtil'
import emitter from '@ohos.events.emitter';
import EmitterConstant from '../../data/EmitterConstant';
import DotUtil from '../../utils/MmsDot/DotUtils';
import dotCommon, { onlyStateParam, seleteParam, stateParam } from '../../utils/MmsDot/DotCommon';
import settings from '@ohos.settings';
import AdvancedSettingsController from './advancedSettings/advancedSettingsController';
import SettingsDataUtils from '../../utils/SettingsDataUtils';
import StringUtil from '../../utils/StringUtil';


const TAG = 'SettingsController';

class Result {
    code: number = -1;
    integrationSwitch: boolean = false;
    showContactSwitch: boolean = false;
}
interface PreErr{
    code: number;
    message: string
}
export default class SettingsController {
    private static sInstance: SettingsController | undefined = undefined;
    // Notification information integration
    integrationSwitch: MmsBoolean = new MmsBoolean(true);
    integrationSwitchSec:MmsBoolean = new MmsBoolean(false);
    // Verification code security protection
    verificationCodeSwitch: boolean = false;
    // Display contact avatar
    showContactSwitch: MmsBoolean = new MmsBoolean(true);
    pageInfos: NavPathStack = new NavPathStack();
    private advancedSettingsController: AdvancedSettingsController = AdvancedSettingsController.getInstance();
    private settingsDataUtils: SettingsDataUtils = SettingsDataUtils.getInstance();

    private context = (GlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext);

    static getInstance() {
        if (!SettingsController.sInstance) {
            SettingsController.sInstance = new SettingsController();
        }
        return SettingsController.sInstance;
    }

    public static release() {
        SettingsController.sInstance = undefined;
    }

    constructor() {
        HiLog.i(TAG, 'constructor, start');
        this.getSettingPageSwitchValue();
    }

    onInit(pageInfos: NavPathStack) {
        HiLog.i(TAG, 'onInit, start');
        this.pageInfos = pageInfos;
        let isJumpToRcs = AppStorage.get('tipsJumpToRcsSetting') as boolean
        if (isJumpToRcs) {
            this.pageInfos.pushPathByName('RcsSettings', {} as LooseObject, false)
        }
    };

    onShow(): void {
        HiLog.i(TAG, 'onShow, start');
        this.getSettingPageSwitchValue();
    };

    // Indicates whether to initialize the setting page.
    getSettingPageSwitchValue() {
        HiLog.i(TAG, 'getSettingPageSwitchValue, start');
        let that = this;
        settingService.setOnSettingValueListener((result: Result) => {
            that.integrationSwitch.value = result.integrationSwitch;
            that.showContactSwitch.value = result.showContactSwitch;
            HiLog.iw(TAG, `result.integrationSwitch ${result.integrationSwitch}`);
            HiLog.iw(TAG, `result.showContactSwitch ${result.showContactSwitch}`);
        });
    };

    // Notification information integration
    integration(isOn: boolean) {
        let messageCode = common.route.MESSAGE_CODE_UPDATE_ARCHIVE_INFO_MESSAGES_VALUE;
        if (this.integrationSwitch.value != isOn) {
            GlobalContext.getContext().setObject('needToUpdate', true);
        }
        let actionData: LooseObject = {};
        this.integrationSwitch.value = isOn;
        HiLog.iw(TAG, `notification information integration ${isOn}`);
        if (this.integrationSwitch.value) {
            actionData.booleanValue = common.bool.TRUE;
            // 通知信息整合-开打点
            stateParam.STATE = 1;
            DotUtil.getInstance().reportEvent(stateParam, dotCommon.eventName.SETTING_ARCHIVE_INFO_SMS);
        } else {
            actionData.booleanValue = common.bool.FALSE;
            // 通知信息整合-关打点
            stateParam.STATE = 2;
            DotUtil.getInstance().reportEvent(stateParam, dotCommon.eventName.SETTING_ARCHIVE_INFO_SMS);
        }
        let curBp: string = AppStorage.get('curBp') as string;
        if (curBp !== common.STR.DEVICE_MOBILE_PHONE) {
            let innerEvent: emitter.InnerEvent = {
                eventId: EmitterConstant.EVENT_INTEGRATION_STATUS,
            };
            let eventData: emitter.EventData = {
                data: {
                    'notificationIntegration': true,
                    'integrationSwitchState':  this.integrationSwitch.value
                }
            }
            emitter.emit(innerEvent, eventData);
        }
        this.updateSettingPageSwitchValue(messageCode, actionData);
    };

    /**
     * 根据key获取settings数据库中对应的值
     *
     * @param context 上下文
     * @param settings数据库中对应的key值
     * @param defaultValue 默认值
     *
     * @returns settings数据库中key对应的值
     */
    static getSettingsData(context: Context, key: string, defaultValue: string): string {
        if (context === null || context === undefined) {
            HiLog.w(TAG, `getSettingsData failed context is invalid`);
            return '';
        }
        if (StringUtil.isEmpty(key)) {
            HiLog.w(TAG, `getSettingsData failed key is invalid`);
            return '';
        }
        try {
            let settingStatusStr: string = settings.getValueSync(context, key, defaultValue);
            return settingStatusStr;
        } catch (error) {
            HiLog.e(TAG, `getSettingsData failed code: ${error?.code} message: code: ${error?.message}`);
            return ''
        }
    }


    // Go to the Message Ring page. Choose Settings > Sound and Vibration > Message Ring.
    jumpToMessageTonePage() {
        HiLog.i(TAG, 'jumpToMessageTonePage')
        let context = getContext(this) as myCommon.UIAbilityContext;
        let want: Want = {
            bundleName: 'com.ohos.settings',
            abilityName: 'com.ohos.settings.MainAbility',
            uri: 'Messaging_tone_settings', // NavEntryKey.WIFI_ENTRY
        }
        context?.startAbility(want);
    };

    // Display a contact's avatar
    showContact(isOn: boolean) {
        HiLog.iw(TAG, 'showContact, checked = ' + isOn);
        let messageCode = common.route.MESSAGE_CODE_UPDATE_SHOW_CONTACT_PROFILE_PICS_VALUE;
        let actionData: LooseObject = {};
        this.showContactSwitch.value = isOn;
        if (this.showContactSwitch.value) {
            actionData.booleanValue = common.bool.TRUE;
            // Indicates whether to display contact avatars(DOT)
            seleteParam.SELECT_STATE = 1;
            DotUtil.getInstance().reportEvent(seleteParam, dotCommon.eventName.SHOW_CONTACT_AVATAR);
        } else {
            actionData.booleanValue = common.bool.FALSE;
            // Indicates whether to display contact avatars(DOT)
            seleteParam.SELECT_STATE = 2;
            DotUtil.getInstance().reportEvent(seleteParam, dotCommon.eventName.SHOW_CONTACT_AVATAR);
        }
        let curBp: string = AppStorage.get('curBp') as string;
        if (curBp !== common.STR.DEVICE_MOBILE_PHONE) {
            let innerEvent: emitter.InnerEvent = {
                eventId: EmitterConstant.EVENT_SHOW_CONTACT_STATUS,
            };
            let eventData: emitter.EventData = {
                data: {
                    'showContact': true
                }
            }
            emitter.emit(innerEvent, eventData);
        }
        this.updateSettingPageSwitchValue(messageCode, actionData);
    };

    // Revert the default value of whether the delete button popup box appears.
    reStoreDeleteDialog():void{
        MmsPreferences.getInstance().setShowDelDialog(common.bool.TRUE);
        return;
    }

    reStoreSmartMmsInfo(): void {
    }

    // restore message ringtone
    restoreMmsRingtone(): void {
        const mmsRingtoneManager: MmsRingtoneManager = new MmsRingtoneManager();
        mmsRingtoneManager.getRingtoneUri().then((defaultUri: string) => {
            const context: myCommon.UIAbilityContext = GlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext;
            mmsRingtoneManager.setSystemRingtoneUri(context, defaultUri, 0);
            mmsRingtoneManager.setSystemRingtoneUri(context, defaultUri, 1);
        });
    }

    // Restore the default values on the settings page.
    restoreSettingsPageSwitchValue() {
        let that = this;
        settingService.restoreSwitchValue((result: Result) => {
            if (result.code === common.int.SUCCESS) {
                that.integrationSwitch.value = false;
                that.showContactSwitch.value = true;
                GlobalContext.getContext().setObject('needToUpdate', true);
                HiLog.i(TAG, 'restoreSettingsPageSwitchValue, success');
            } else {
                HiLog.w(TAG, 'restoreSettingsPageSwitchValue, failed');
            }
        });
    };

    // Advanced page redirection
    advancedSetting() {
        HiLog.i(TAG, 'advancedSetting')
        this.pageInfos?.pushPathByName('AdvancedSettings', {} as LooseObject)
    };

    // Mms Privacy State Page Redirection
    privacyStateRedirection() {
        HiLog.i(TAG, 'privacyStateRedirection')
        this.pageInfos?.pushPathByName('PrivacyState', {
            contentTag: 'prilab'
        } as LooseObject)
    };

    // Mms Personal Information List Page Redirection
    personalInformationListRedirection() {
        HiLog.i(TAG, 'personalInformationListRedirection')
        this.pageInfos?.pushPathByName('PrivacyState', {
            contentTag: 'di'
        } as LooseObject)
    };

    // Update Switch Value
    updateSettingPageSwitchValue(messageCode: number, actionData: LooseObject) {
        HiLog.i(TAG, 'updateSettingPageSwitchValue,  messageCode = ' + messageCode);
        settingService.updateSettingValue(messageCode, actionData, (result: Result) => {
            if (result.code == common.int.SUCCESS) {
                HiLog.i(TAG, 'updateSettingPageSwitchValue, success');
            } else {
                HiLog.w(TAG, 'updateSettingPageSwitchValue, failed');
            }
        });
    };

}