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
import lazy {globalReleaseAppResource} from './indexReleaseTools';
import HiLog from '../utils/HiLog';
import { notificationManager } from '@kit.NotificationKit';
import SharedPreferencesUtils from '../utils/SharedPreferencesUtils';
import PreferenceConstant from '../data/PreferenceConstant';
import { BusinessError } from '@kit.BasicServicesKit';
import MmsUtil from '../utils/MmsUtil';
import StringUtil from '../utils/StringUtil';
import TimeUtils from './smc/utils/TimeUtils';
import ObjectUtil from '../utils/ObjectUtil';
import commonData from '../data/commonData';
import DotCommon, {
    NotificationSlotStatus,
    RemindEnableNotificationKey,
    RemindEnableNotificationParams
} from '../utils/MmsDot/DotCommon';
import DotUtil from '../utils/MmsDot/DotUtils';
import AppStorageKeyConstant from '../data/AppStorageKeyConstant';
import { SystemPropertyUtils } from '../utils/SystemPropertyUtils';

const TAG = 'IndexController';
const REMIND_SPILT = '_';
// 短信应用发送通知消息的渠道集合，调用notificationManager.publish时参数notificationRequest中notificationSlotType指定
// 社交通讯类渠道开关会影响正常通知显示，客服消息类渠道开关会影响骚扰拦截通知显示，此处只需检测社交通讯类渠道开关状态
const MMS_NOTIFICATION_SLOT_TYPES = [notificationManager.SlotType.SOCIAL_COMMUNICATION];
// 通知开关打开最大提醒次数
const REMIND_FIRST = 1;
const REMIND_SECOND = 2;
const REMIND_THIRD = 3;
const MMS_BUNDLE: notificationManager.BundleOption = { bundle: commonData.STR.BUNDLE_NAME };

let sIndexController: IndexController;

export default class IndexController {
    showConList: boolean = true;
    // 通知中心中已关闭的应用通知渠道
    public notEnableSlots: notificationManager.NotificationSlot[] = [];
    // 应用通知总开关状态
    public isEnableNotification: boolean = true;
    // 应用通知开关提醒次数
    public enableNotificationRemindTimes: number = 0;
    // 上次提醒时间
    public lastRemindTime: number = 0;

    static getInstance(): IndexController {
        if (sIndexController == null) {
            sIndexController = new IndexController();
        }
        return sIndexController;
    }

    onInit() {
        HiLog.i(TAG, 'onInit');
    }
    onShow() {
        HiLog.i(TAG, 'onShow');
    }
    onHide() {
        HiLog.i(TAG, 'onConceal');
    }

    onDestroy() {
        globalReleaseAppResource();
        HiLog.i(TAG, 'onDestroy');
    }

    /**
     * 检查短信通知是否打开，用户关闭后仅检测一次
     *
     * @param context 上下文
     * @param callback 回调方法，打开提醒弹窗
     */
    public async checkNotificationEnabled(context: Context, callback: Function) {
        if (!context) {
            HiLog.w(TAG, `checkNotificationEnabled param invalid`);
            return;
        }
        // 如果是ADU门店演示样机。不需要弹出提醒
        if (SystemPropertyUtils.isRetailDevice()) {
            HiLog.w(TAG, `checkNotificationEnabled isRetailDevice`);
            return;
        }
        // 如果不是桌面点击进入。不需要弹出提醒
        if (!AppStorage.get(AppStorageKeyConstant.IS_START_FROM_HOME)) {
            HiLog.w(TAG, `checkNotificationEnabled isStartFromHome false`);
            return;
        }
        // 检查是否需要提醒用户开启通知
        let isNeedRemind: boolean = this.checkIsNeedRemind(context);
        HiLog.w(TAG, `checkNotificationEnabled checkIsNeedRemind： ${isNeedRemind}`);
        if (!isNeedRemind) {
            return;
        }
        // 检查应用通知总开关是否开启
        try {
            this.isEnableNotification = await notificationManager.isNotificationEnabled();
            HiLog.w(TAG, `checkNotificationEnabled isNotificationEnabled success: ${this.isEnableNotification}`);
        } catch (err) {
            HiLog.e(TAG, `checkNotificationEnabled isNotificationEnabledSync fail：${JSON.stringify(err)}`);
            this.reportEnableNotificationFailEvent(`isNotificationEnabledSync fail：${JSON.stringify(err)}`);
            this.resetEnableNotificationParams();
            return;
        }
        // 检查应用通知渠道开关是否开启
        this.notEnableSlots = [];
        notificationManager.getSlotsByBundle(MMS_BUNDLE).then((data: Array<notificationManager.NotificationSlot>) => {
            data.forEach((slot) => {
                HiLog.w(TAG,
                    `checkNotificationEnabled getSlotsByBundle,type:${slot?.notificationType}.enabled:${slot?.enabled}`);
                // 社交通讯类渠道开关会影响正常通知显示，客服消息类渠道开关会影响骚扰拦截通知显示
                if (!slot?.enabled && MMS_NOTIFICATION_SLOT_TYPES.includes(slot?.notificationType ?? -1)) {
                    this.notEnableSlots.push(slot);
                }
            })
            HiLog.w(TAG, `checkNotificationEnabled notEnableSlots.length: ${this.notEnableSlots?.length}`);
            if ((this.notEnableSlots?.length > 0 || !this.isEnableNotification) && callback) {
                callback();
            }
        }).catch((err: BusinessError) => {
            HiLog.e(TAG, `checkNotificationEnabled getSlotsfailed,code is:${err?.code},message is ${err?.message}`);
            this.reportEnableNotificationFailEvent(`getSlotsfailed fail：${JSON.stringify(err)}`);
            this.resetEnableNotificationParams();
        });
    }

    /**
     * 触发条件（周期性触发）
     * 第1次，用户关闭通知权限后，首次打开短信App提醒（若用户点击允许，重新开始累计时机规则。若用户点击不允许，则再触发2次提醒）
     * 第2次，距离第1次≥3天，用户打开短信App提醒
     * 第3次，距离第2次≥7天，用户打开短信App提醒
     *
     * @param context 上下文
     * @returns 是否查询应用通知状态以提醒用户开始通知
     */
    private checkIsNeedRemind(context: Context): boolean {
        // 查询之前是否已询问过用户.如果之前已允许/不允许过，则不再继续查询
        SharedPreferencesUtils.init(context);
        let isRemind: string =
            SharedPreferencesUtils.getFromPreferences(PreferenceConstant.IS_REMINDED_ENABLE_NOTIFICATION, '') as string;
        HiLog.w(TAG, `checkIsNeedRemind is reminded： ${isRemind}`);
        // 未提醒过用户打开通知
        if (StringUtil.isEmpty(isRemind)) {
            return true;
        }
        // 之前点击允许的用户重置首选项
        if (isRemind.includes(PreferenceConstant.IS_REMINDED_ENABLE_NOTIFICATION_ALLOWED)) {
            SharedPreferencesUtils.saveToPreferences(PreferenceConstant.IS_REMINDED_ENABLE_NOTIFICATION, '');
            return true;
        }
        // 之前提醒用户 用户已点击允许，则不会再提醒
        if (!isRemind.includes(PreferenceConstant.IS_REMINDED_ENABLE_NOTIFICATION_NOT_ALLOWED)) {
            return false;
        }
        // 首选项中存储格式为 提示时间戳+用户操作类型（允许/不允许:前后均有下划线_)+提醒次数（最多三次）
        let remindArray: string[] = isRemind.split(REMIND_SPILT);
        if (remindArray.length !== 3) {
            HiLog.w(TAG, `checkIsNeedRemind, remindArray length is invalid`);
            return true;
        }
        const lastRemindTime: number = Number(remindArray[0]);
        const remindTimes: number = Number(remindArray[2]);
        HiLog.w(TAG, `checkIsNeedRemind, lastRemindTime: ${lastRemindTime},remindTimes:${remindTimes}`);
        if (ObjectUtil.isUndefAndNull(lastRemindTime) || Number.isNaN(lastRemindTime)) {
            HiLog.w(TAG, `checkIsNeedRemind, lastRemindTime is invalid`);
            return true;
        }
        if (ObjectUtil.isUndefAndNull(remindTimes) || Number.isNaN(remindTimes)) {
            HiLog.w(TAG, `checkIsNeedRemind, lastRemindTime is invalid`);
            return true;
        }
        // 提醒次数超过三次不在提醒
        this.enableNotificationRemindTimes = remindTimes;
        this.lastRemindTime = lastRemindTime;
        if (remindTimes >= REMIND_THIRD) {
            return false;
        }
        const sinceLastRemindDays: number = (Date.now() - lastRemindTime) / TimeUtils.ONE_DAY;
        HiLog.w(TAG, `checkIsNeedRemind, sinceLastRemindDays is: ${sinceLastRemindDays}`);
        // 第2次，距离第1次≥3天，用户打开短信App提醒
        // 第3次，距离第2次≥7天，用户打开短信App提醒
        if ((remindTimes === REMIND_FIRST && sinceLastRemindDays >= 3) ||
            (remindTimes === REMIND_SECOND && sinceLastRemindDays >= 7)) {
            return true;
        }
        return false;
    }

    /**
     * 不同意打开短信通知
     */
    public notAllowedSetEnableNotification() {
        // 记录用户操作至首选项-时间戳+操作结果
        HiLog.w(TAG, `notAllowedSetEnableNotification, RemindTimes: ${this.enableNotificationRemindTimes + 1}`);
        SharedPreferencesUtils.saveToPreferences(PreferenceConstant.IS_REMINDED_ENABLE_NOTIFICATION,
            Date.now().toString() + PreferenceConstant.IS_REMINDED_ENABLE_NOTIFICATION_NOT_ALLOWED +
                (this.enableNotificationRemindTimes + 1));
        this.reportEnableNotificationEvent(RemindEnableNotificationKey.BEHAVIOR_DENY);
        this.resetEnableNotificationParams();
    }

    /**
     * 点击允许后，通过通知信息ANS系统接口打开短信通知总开关、通知渠道社交通讯类开关
     */
    public async setNotificationEnable() {
        // 1调用系统接口打开应用通知总开关
        if (!this.isEnableNotification) {
            try {
                await notificationManager.setNotificationEnable(MMS_BUNDLE, true);
                HiLog.w(TAG, 'setNotificationEnable success');
            } catch (err) {
                HiLog.e(TAG, `setNotificationEnable failed, code is ${err?.code}, message is ${err?.message}`);
                this.reportEnableNotificationFailEvent(`setNotificationEnable failed,${JSON.stringify(err)}`);
                this.resetEnableNotificationParams();
                return;
            }
        }
        // 2调用系统接口打开应用通知渠道开关
        if (this.notEnableSlots?.length > 0) {
            for (let slot of this.notEnableSlots) {
                try {
                    await notificationManager.setNotificationEnableSlot(MMS_BUNDLE, slot?.notificationType, true);
                    HiLog.w(TAG, `setNotificationEnableSlot success: ${slot?.notificationType}`);
                } catch (err) {
                    HiLog.e(TAG, `setNotificationEnableSlot failed, code is ${err?.code}, message is ${err?.message}`);
                    this.reportEnableNotificationFailEvent(`setNotificationEnableSlot failed,${JSON.stringify(err)}`);
                    this.resetEnableNotificationParams();
                    return;
                }
            }
        }
        MmsUtil.showToast({
            message: $r('app.string.enabled_notification'),
            duration: 2000
        });
        // 3记录用户操作至首选项-点击允许后.设置首选项为空
        SharedPreferencesUtils.saveToPreferences(PreferenceConstant.IS_REMINDED_ENABLE_NOTIFICATION, '');
        HiLog.w(TAG, `setNotificationEnable end, RemindTimes: ${this.enableNotificationRemindTimes + 1}`);
        this.reportEnableNotificationEvent(RemindEnableNotificationKey.BEHAVIOR_ALLOW);
        this.resetEnableNotificationParams();
    }

    /**
     * 重置通知中心提醒参数为初始状态
     */
    private resetEnableNotificationParams() {
        this.isEnableNotification = true;
        this.notEnableSlots = [];
        this.enableNotificationRemindTimes = 0;
        this.lastRemindTime = 0;
    }


    /**
     * 短信通知提醒上报行为打点
     *
     * @param behavior 行为
     */
    private reportEnableNotificationEvent(behavior: number) {
        let eventParams: RemindEnableNotificationParams = new RemindEnableNotificationParams();
        eventParams.TIMES = this.enableNotificationRemindTimes;
        eventParams.BEHAVIOR = behavior;
        eventParams.SWITCH_STATUS =
            this.isEnableNotification ? RemindEnableNotificationKey.SWITCH_ON : RemindEnableNotificationKey.SWITCH_OFF;
        eventParams.LAST_REMIND_TIME = this.lastRemindTime.toString();
        if (this.notEnableSlots?.length > 0) {
            let slotsStatus: NotificationSlotStatus[] = [];
            let slotStatus: NotificationSlotStatus;
            for (let slot of this.notEnableSlots) {
                slotStatus = new NotificationSlotStatus();
                slotStatus.slotType = slot.notificationType as number;
                slotStatus.switchStatus =
                    slot.enabled ? RemindEnableNotificationKey.SWITCH_ON : RemindEnableNotificationKey.SWITCH_OFF;
                slotsStatus.push(slotStatus);
            }
            eventParams.SLOT_STATUS = JSON.stringify(slotsStatus);
        }
        DotUtil.getInstance().reportEvent(eventParams, DotCommon.eventName.REMIND_ENABLE_NOTIFICATION);
    }

    /**
     * 短信通知提醒失败上报行为打点
     *
     * @param failReason 失败原因
     */
    private reportEnableNotificationFailEvent(failReason: string) {
        let eventParams: RemindEnableNotificationParams = new RemindEnableNotificationParams();
        eventParams.DETAIL_ERROR = failReason;
        DotUtil.getInstance().reportEvent(eventParams, DotCommon.eventName.REMIND_ENABLE_NOTIFICATION);
    }
}