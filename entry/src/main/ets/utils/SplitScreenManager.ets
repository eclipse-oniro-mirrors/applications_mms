/**
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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
import window from '@ohos.window';
import { display } from '@kit.ArkUI';
import deviceInfo from '@ohos.deviceInfo';
import DeviceUtil from './DeviceUtil';

const TAG = 'SplitScreenManager';
const ONE_HALF = 1 / 2
const ONE_THREE = 1 / 3
const TWO_THREE = 2 / 3

export enum SplitScreenType {
    DEFAULT = 0, // 默认全屏
    SMALL = 1, // 直板手机竖屏1:2
    MEDIUM = 2, // 直板手机竖屏1:1
    BIG = 3, // 直板手机竖屏2:1
}

@Observed
export class SplitInfoModel {
    public isSmall: boolean = false;
    public isMediumAndSmall: boolean = false;
    public isNoLongPress: boolean = false;
    public isEmojiLow: boolean = false;
    //conversation页面输入框最大高度随分屏变化而变化
    public inputMaxLine: number = 10;
    public inputMaxheight: number = 10 * 21 + 16;
    //conversation页面 附件区弹出的时候，是否要把输入框限制到一行
    public isLimitOne: boolean = false;
    public isAboveScreen: boolean = true;//分屏的时候。短信应用是否在上面
}

/**
 * class SplitScreenManager
 */
export class SplitScreenManager {
    private static splitScreenManager: SplitScreenManager;
    private fullScreenHeight: number = 0
    public fullScreenHeightVP: number = 0
    private fullScreenWidth: number = 0
    private screenWidth: number = 0
    private screenHeight: number = 0
    private windowStatusType = window.WindowStatusType.UNDEFINED
    private orientation = display.Orientation.PORTRAIT
    public isLandscapeAndPhone = false;
    private isPad: boolean = false
    public infoModel: SplitInfoModel = new SplitInfoModel();


    /**
     * create splite screen manager
     *
     * @returns {Object} - SplitScreenManager object
     */
    public static getInstance(): SplitScreenManager {
        if (!SplitScreenManager.splitScreenManager) {
            SplitScreenManager.splitScreenManager = new SplitScreenManager()
        }
        return SplitScreenManager.splitScreenManager;
    }

    // 判断是否分屏
    updateWindowStatusType(type: WindowStatusType) {
        HiLog.i(TAG, 'updateWindowStatusType ' + type)
        this.windowStatusType = type
    }

    updateSplitScreenPosition(rect: window.Rect) {
        if (DeviceUtil.isSplitScreen()) {
            this.infoModel.isAboveScreen = rect.top < 200;
            AppStorage.setOrCreate('isAboveScreen', this.infoModel.isAboveScreen);
        }
    }

    updateScreenSize(width: number, height: number) {
        this.screenWidth = width
        this.screenHeight = height
        try {
            let displayInfo = display.getDefaultDisplaySync();
            this.fullScreenWidth = displayInfo.width
            this.fullScreenHeight = displayInfo.height
            this.orientation = displayInfo.orientation
            this.fullScreenHeightVP = this.screenHeight / displayInfo.densityPixels;
        } catch (err) {
            HiLog.e(TAG, `Failed to getDefaultDisplaySync, Code: ${err.code}, message: ${err.message}`);
        }
        if (this.windowStatusType === window.WindowStatusType.UNDEFINED) {
            if ((width == this.fullScreenWidth && height != this.fullScreenHeight) ||
                (height == this.fullScreenHeight && width != this.fullScreenWidth)) {
                this.windowStatusType = window.WindowStatusType.SPLIT_SCREEN;
                AppStorage.setOrCreate('windowStatusType', this.windowStatusType)
            }
        }

        this.infoModel.isSmall = this.isSplitScreenSmall();
        this.infoModel.isMediumAndSmall = this.isSplitScreenMediumAndSmall();
        this.infoModel.isNoLongPress = this.isSplitScreenLongPress();
        this.infoModel.isEmojiLow = this.isSplitScreenEmojiLow();
        this.infoModel.inputMaxLine = this.getInputMaxLine()
        this.infoModel.inputMaxheight = this.infoModel.inputMaxLine * 21 + 16;
        this.infoModel.isLimitOne = this.isLimitOneInputHieght();
        AppStorage.setOrCreate('SplitScreenType', this.getSplitScreenType());

    }

    isLimitOneInputHieght(): boolean {
        let type = this.getSplitScreenType();
        if (type != SplitScreenType.DEFAULT) {
            if (this.isPad) {
                if (type == SplitScreenType.SMALL) {
                    return true;
                } else {
                    return false
                }
            } else {
                return true;
            }
        }

        return false
    }

    getInputMaxLine(): number {
        let type = this.getSplitScreenType();
        let inputMaxLine: number = 10;
        if (type == SplitScreenType.SMALL) {
            inputMaxLine = this.isPad ? 6 : 4;
        } else if (type == SplitScreenType.MEDIUM) {
            inputMaxLine = this.isPad ? 10 : 6;
        } else if (type == SplitScreenType.BIG) {
            inputMaxLine = this.isPad ? 10 : 8;
        }
        return inputMaxLine
    }

    // 小屏处理规则：同时存在导航和底部功能区的时候，小屏情况下不显示导航
    isSplitScreenSmall(): boolean {
        let type = this.getSplitScreenType()
        //pad 小屏等价中屏
        if (!this.isPad && type === SplitScreenType.SMALL) {
            return true
        }
        return false
    }

    // 半屏、小屏处理规则：导航一级标题缩小为二级标题 pad半屏等价于大屏
    isSplitScreenMediumAndSmall(): boolean {
        let type = this.getSplitScreenType()
        if (type === SplitScreenType.SMALL || type === SplitScreenType.MEDIUM) {
            if (this.isPad && type === SplitScreenType.MEDIUM) {
                return false
            }

            return true
        }
        return false
    }
//长按事件规则
    isSplitScreenLongPress(): boolean {
        let type = this.getSplitScreenType();
        if (type === SplitScreenType.SMALL || type === SplitScreenType.MEDIUM) {
            if (this.isPad) {
                return false
            }
            if (this.isFoldableScreenAndFullyUnfolded()) {
                return false
            }
            return true
        }

        return false

    }

    private isFoldableScreenAndFullyUnfolded(): boolean {
        try {
            return DeviceUtil.isFoldable() && display.getFoldStatus() === display.FoldStatus.FOLD_STATUS_EXPANDED;
        } catch (err) {
            HiLog.e(TAG, `Failed to get isFoldableScreenAndFullyUnfolded, Code: ${err.code}, message: ${err.message}`);
        }
        return false;
    }

    //表情键盘高度规则：分屏下边矮，pad大屏下例外
    isSplitScreenEmojiLow(): boolean {
        if (DeviceUtil.isSplitScreen()) {
            let type = this.getSplitScreenType()
            if (type == SplitScreenType.DEFAULT) {
                return false;
            }
            if (this.isPad && type == SplitScreenType.BIG) {
                return false
            } else {
                return true
            }
        }
        return false
    }

    getSplitScreenType(): SplitScreenType {
        //判断是否在分屏模式下
        this.isLandscapeAndPhone = false;
        if (this.windowStatusType == window.WindowStatusType.SPLIT_SCREEN) {
            let scale = this.screenHeight / this.fullScreenHeight;
            const deviceTypeInfo = deviceInfo.deviceType;
            // pad
            if (deviceTypeInfo === 'tablet') {
                this.isPad = true;
            }
            // 折叠屏且完全展开
            if (this.isFoldableScreenAndFullyUnfolded()) {
                //根据高度判断 是否为上下分屏。折叠机上下分屏只有1:1模式
                if (scale < ONE_HALF && scale > ONE_THREE) {
                    return SplitScreenType.MEDIUM
                }
                return SplitScreenType.DEFAULT
            }

            // landscape
            if (this.orientation === display.Orientation.LANDSCAPE ||
                this.orientation === display.Orientation.LANDSCAPE_INVERTED) {
                this.isLandscapeAndPhone = !this.isPad;
                return SplitScreenType.MEDIUM
            }
            //根据高度计算分屏 大 中 小
            if (scale < ONE_THREE && scale > 0) {
                return SplitScreenType.SMALL
            } else if (scale < ONE_HALF && scale > ONE_THREE) {
                return SplitScreenType.MEDIUM
            } else if (scale < TWO_THREE && scale > ONE_HALF) {
                return SplitScreenType.BIG
            } else {
                return SplitScreenType.DEFAULT
            }
        }
        return SplitScreenType.DEFAULT
    }
}