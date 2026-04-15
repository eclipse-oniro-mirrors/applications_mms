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
import HiLog from './HiLog';
import display from '@ohos.display';
import window from '@ohos.window';
import { BusinessError } from '@ohos.base';
import ConversationListController from '../pages/conversationlist/conversationListController';
import SettingsModel from '../model/SettingsModel'
import { GlobalContext } from '../MainAbility/GlobalHelper';
import common from '../data/commonData'
import call from '@ohos.telephony.call';
import { deviceInfo } from '@kit.BasicServicesKit';

const TAG = 'DeviceUtil';

export default class DeviceUtil {

  constructor() {
  }

  /**
   * Querying the Device Type
   *
   * default：Smartphones
   * tablet：flat plate
   * tv：Smart screen
   * wearable：Smart Wear
   * liteWearable：Lightweight intelligent wearable
   * smartVision：Smart Vision Devices
   */

  public static padPortraitMargin: number = 16;
  public static padLandSpaceMargin: number = 24;
  // 最大分栏宽度，小于600间距为16，大于600间距为24
  private static maxTabWidth: number = 600;
  private static isPadMaxTabWidthLess600():boolean {

    // divisor：因为返回的分栏比例是一个百分比的字符串，如"50%",在参入计算后需要转换回来
    let divisor = 100;
    let windowWidth = AppStorage.get('windowWidth') as number;
    let percentage = AppStorage.get('mmsScreenPercentage') as string;
    let percentageValue = Number.parseInt(percentage);
    if (windowWidth > 0 && percentageValue > 0) {
      // 获取分栏中较大的一边，如横屏状态下分栏比例为"60%",这里获取到的值就是 Math.max(60, 40)
      let maxPercentage = Math.max(percentageValue, divisor - percentageValue);
      let maxWidth = maxPercentage * windowWidth / divisor;
      return maxWidth < DeviceUtil.maxTabWidth;
    }
    return true;
  }

  static padMargin(): number {
    if (DeviceUtil.isPadMaxTabWidthLess600()) {
      return DeviceUtil.padPortraitMargin;
    }
    return DeviceUtil.padLandSpaceMargin;
  }

  static isTablet(): boolean {
    const deviceTypeInfo = deviceInfo.deviceType;
    return deviceTypeInfo === 'tablet';
  }

  static isPhone(): boolean {
    const deviceTypeInfo = deviceInfo.deviceType;
    return deviceTypeInfo === 'phone' || deviceTypeInfo === 'default';
  }

  static isPC(): boolean {
    const deviceTypeInfo = deviceInfo.deviceType;
    return deviceTypeInfo === '2in1';
  }

  static isTabletOrPC(): boolean {
    const deviceTypeInfo = deviceInfo.deviceType;
    return deviceTypeInfo === 'tablet' || deviceTypeInfo === '2in1' ? true : false;
  }

  static isFoldable(): boolean {
    let ret: boolean = false;
    try {
      ret = display.isFoldable();
    } catch (exception) {
      HiLog.e(TAG, 'Failed to check is foldable or not. exp=' + JSON.stringify(exception));
    }
    if (ret === undefined || !ret) {
      HiLog.i(TAG, 'Failed to check is foldable or not.');
      return false;
    }
    return true;
  }

  /**
   * param none
   * @returns boolean
   * 判断pad是否具有蜂窝能力
   */
  static hasCellularCapability(): boolean {
    return call.hasVoiceCapability();
  }

  static isCellularTablet(): boolean {
    return DeviceUtil.isTablet() && DeviceUtil.hasCellularCapability();
  }

  static isCellularPhone(): boolean {
    return DeviceUtil.isPhone() && DeviceUtil.hasCellularCapability();
  }

  static isWifiOnlyTablet(): boolean {
    return DeviceUtil.isTablet() && !DeviceUtil.hasCellularCapability();
  }

  static setPreferredOrientation(windowObj: window.Window): void {
    if (!windowObj || DeviceUtil.isTablet()) {
      return;
    }
    let promise: Promise<void>;
    if (!DeviceUtil.isFoldable() || DeviceUtil.getScreenFoldStatus() === 2) {
      promise = windowObj.setPreferredOrientation(window.Orientation.PORTRAIT);
      HiLog.i(TAG, 'setting the window orientation PORTRAIT');
    } else {
      promise = windowObj.setPreferredOrientation(window.Orientation.AUTO_ROTATION_RESTRICTED);
      HiLog.i(TAG, 'setting the window orientation AUTO_ROTATION_RESTRICTED');
    }
    promise.then(() => {
      HiLog.i(TAG, 'setting the window orientation Succeeded');
    }).catch((err: BusinessError) => {
      HiLog.e(TAG, 'set the window orientation Failed, Cause: ' + JSON.stringify(err));
    });
  }

  /**
   * get screen foldStatus
   *
   * @returns {number} 1：折叠完全展开 2：折叠状态 3：完全展开和折叠之间 4：未知
   */
  static getScreenFoldStatus(): number {
    let status: number = 0;
    try {
      switch (display.getFoldStatus()) {
        case display.FoldStatus.FOLD_STATUS_EXPANDED:
          status = 1;
          break;
        case display.FoldStatus.FOLD_STATUS_FOLDED:
          status = 2;
          break;
        case display.FoldStatus.FOLD_STATUS_HALF_FOLDED:
          status = 3;
          break;
        case display.FoldStatus.FOLD_STATUS_UNKNOWN:
          status = 4;
          break;
        default:
          status = 0;
          break;
      }
    } catch (exception) {
      HiLog.e(TAG, 'Failed to obtain the fold status. Code: ' + JSON.stringify(exception));
    }
    return status;
  }

  /**
   * 判断当前是否是浮窗状态
   * FLOATING 值为1 表示APP自由悬浮形式窗口模式， 0	表示APP未定义窗口模式。
   * @returns true 为悬浮窗状态，否则为false
   */
  public static isFloatingScreen(): boolean {
    let ret: number = AppStorage.get('windowStatusType') || 0;
    return ret === window.WindowStatusType.FLOATING;
  }

  /**
   * 判断当前是否是三折叠展开态
   * FOLD_STATUS_EXPANDED_WITH_SECOND_EXPANDED 折叠状态展开与第二次展开(三折叠为全展开态)
   * FOLD_STATUS_EXPANDED_WITH_SECOND_HALF_FOLDED 折叠状态展开，同时折叠下半部分(三折叠即将展开第三面)
   */
  public static isTrifoldExpandedState(): boolean {
    try {
      return display.getFoldStatus() === display.FoldStatus.FOLD_STATUS_EXPANDED_WITH_SECOND_EXPANDED ||
        display.getFoldStatus() === display.FoldStatus.FOLD_STATUS_EXPANDED_WITH_SECOND_HALF_FOLDED
    } catch (err) {
      HiLog.e(TAG, `isTrifoldExpandedState error, code: ${err.code}, message: ${err.message},`);
      return false
    }
  }

  /**
   * 判断当前是否是分屏状态
   * SPLIT_SCREEN	值为5 表示APP分屏模式。
   * @returns true 为分屏状态，否则为false
   */
  public static isSplitScreen(): boolean {
    let ret: number = AppStorage.get('windowStatusType') || 0;
    return ret === window.WindowStatusType.SPLIT_SCREEN;
  }

  static getDeviceScaledDensity(): number {
    try {
      return display.getDefaultDisplaySync().scaledDensity;
    } catch (err) {
      HiLog.i(TAG, `getDefaultDisplaySync error, code: ${err.code}, message: ${err.message},`);
      return 0
    }
  }

  /**
   * 分栏设备 Menu跳转页面返回(我的收藏、信息防护记录、设置)
   * Menu中的页面为互相替换关系,返回应返回跳转前查看的会话页面
   */
  static foldMenuPageBack(pageInfos: NavPathStack) {
    if (pageInfos.getIndexByName('Conversation').length === 0) {
      pageInfos.clear()
      ConversationListController.getInstance().showFirstMessage()
    } else {
      pageInfos.removeByName('Settings')
      pageInfos.removeByName('BlockedPage')
      pageInfos.removeByName('Favorites')
    }
  }

  /**
   * 分布式场景
   * Menu中的页面为互相替换关系,返回应返回跳转前查看的会话页面
   */
  static getdistributedModemState(context: Context): string {
    let state = SettingsModel.getDistributedModemState(context);
    HiLog.i(TAG, `getdistributedModemState ${state}`);
    return state;
  }

  static isSubDevice(context: Context) {
    let ret = DeviceUtil.getdistributedModemState(context).includes(common.STR.SUB_DEVICE);
    HiLog.i(TAG, `isSubDevice ${ret}`);
    return ret;
  }

  static isSubDeviceWithConnected(context: Context) {
    return DeviceUtil.getdistributedModemState(context) === common.STR.SUB_DEVICE_WITH_CONNECTED;
  }

  static getdistributedSwitchState(context: Context): number {
    let distributedSwitchState = Number(SettingsModel.getDistributedSwitchState(context));
    return distributedSwitchState;
  }
}