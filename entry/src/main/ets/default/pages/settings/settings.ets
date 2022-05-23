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
import DeviceUtil from "../../utils/DeviceUtil";
import { MmsSimpleDialog } from '../../views/MmsDialogs';
import { MmsMenu } from '../../views/MmsMenu';
import router from '@system.router';
import { SettingItemSwitch, SettingItemJump } from '../../views/SettingItem';
import SettingsController from './settingsController';

@Entry
@Component
struct Settings {
    @State mSettingsCtrl: SettingsController = SettingsController.getInstance();
    @State gridColumns: number = DeviceUtil.isTablet() ? 12 : 4;
    @State gridSizeType: SizeType = DeviceUtil.isTablet() ? SizeType.LG : SizeType.SM;
    @State gridGutter: string = '12vp';
    @State gridMargin: string = '12vp';
    isEnhanceShow: Visibility = DeviceUtil.isTablet() ? Visibility.None : Visibility.Visible;
    private restoreDialog = new MmsSimpleDialog({
        message: $r("app.string.restore_all_default_settings"),
        primaryButton: {
            value: $r("app.string.cancel"),
            action: () => {
            }
        },
        secondaryButton: {
            value: $r("app.string.restore"),
            action: () => {
                this.mSettingsCtrl.restoreSettingsPageSwitchValue();
            }
        }
    });
    private menuItems: Array<any> = [
        {
            value: $r("app.string.restore_default_settings"),
            action: () => {
                this.restoreDialog.show();
            },
            enabled: true
        }
    ];

    /**
     * 函数在创建自定义组件的新实例后，在执行其build函数之前执行。
     * 允许在aboutToAppear函数中改变状态变量，这些更改将在后续执行build函数中生效。
     */
    aboutToAppear() {
        this.mSettingsCtrl.onInit()
    }

    /**
     * 函数在自定义组件析构消耗之前执行。
     * 不允许在aboutToDisappear函数中改变状态变量，特别是@Link变量的修改可能会导致应用程序行为不稳定。
     */
    aboutToDisappear() {
    }

    /**
     * 当此页面显示时触发一次。包括路由过程、应用进入前后台等场景，仅@Entry修饰的自定义组件生效。
     */
    onPageShow() {
        this.mSettingsCtrl.onShow()
    }

    /**
     * 当此页面消失时触发一次。包括路由过程、应用进入前后台等场景，仅@Entry修饰的自定义组件生效。
     */
    onPageHide() {
    }

    /**
     * 当用户点击返回按钮时触发，，仅@Entry修饰的自定义组件生效。
     * 返回true表示页面自己处理返回逻辑, 不进行页面路由。
     * 返回false表示使用默认的返回逻辑。
     * 不返回值会作为false处理。
     */
    onBackPress() {
    }

    build() {
        Row() {
            GridContainer({
                columns: this.gridColumns,
                sizeType: this.gridSizeType,
                gutter: this.gridGutter,
                margin: this.gridMargin
            }) {
                // 顶部设备标题
                Row() {
                    Image($rawfile("icon/ic_message_back.svg"))
                        .width($r('app.float.icon_side_length_medium'))
                        .height($r('app.float.icon_side_length_medium'))
                        .margin({
                            left: $r('app.float.action_bar_margin_left'),
                            right: $r('app.float.action_bar_space')
                        })
                        .onClick(() => {
                            router.back()
                        })

                    Text($r("app.string.settings"))
                        .fontSize($r('app.float.action_bar_text_size'))
                        .fontColor(Color.Black)
                        .fontWeight(FontWeight.Bold)

                    Blank()

                    Column() {
                        MmsMenu({
                            menuItems: this.menuItems,
                            sizeType: this.gridSizeType
                        })
                    }
                    .margin({ left: $r('app.float.action_bar_space'), right: $r('app.float.action_bar_margin_right') })
                }
                .width('100%')
                .height($r('app.float.action_bar_height'))
                .useSizeType({
                    xs: { span: 12, offset: 0 },
                    sm: { span: 4, offset: 0 },
                    md: { span: 12, offset: 0 },
                    lg: { span: 12, offset: 0 }
                })

                // 所有设置项
                Column({ space: 12 }) {
                    // 第一组设置项
                    Column() {
                        // 增强信息
                        SettingItemJump({
                            primaryTitle: $r("app.string.enhanced_information"),
                            statusTitle: $r("app.string.enabled"),
                            visibility: this.isEnhanceShow,
                            onClick: (event?: ClickEvent) => {
                                // 跳转增强信息设置页面
                            }
                        })

                        // 智能信息
                        SettingItemJump({
                            primaryTitle: $r("app.string.intelligent_information"),
                            statusTitle: $r("app.string.enabled"),
                            onClick: (event?: ClickEvent) => {
                                // 跳转铃声设置页面
                            }
                        })
                    }
                    .width('100%')
                    .padding({
                        top: $r('app.float.settings_item_padding_top'),
                        bottom: $r('app.float.settings_item_padding_bottom'),
                        left: $r('app.float.settings_item_padding_left'),
                        right: $r('app.float.settings_item_padding_right')
                    })
                    .border({ radius: $r('app.float.settings_items_radius'), color: $r("app.color.white") })
                    .backgroundColor($r("app.color.white"))
                    .visibility(Visibility.None)

                    // 第二组设置项
                    Column() {
                        // 通知信息整合
                        SettingItemSwitch({
                            primaryTitle: $r('app.string.archive_info_messages'),
                            secondaryTitle: $r('app.string.archive_info_messages_hint'),
                            isEnable: this.mSettingsCtrl.integrationSwitch,
                            showBottomDivider: false,
                            onChange: (isOn: boolean) => {
                                this.mSettingsCtrl.integration(isOn)
                            }
                        })
                    }
                    .width('100%')
                    .padding({
                        top: $r('app.float.settings_item_padding_top'),
                        bottom: $r('app.float.settings_item_padding_bottom'),
                        left: $r('app.float.settings_item_padding_left'),
                        right: $r('app.float.settings_item_padding_right')
                    })
                    .border({ radius: $r('app.float.settings_items_radius'), color: $r("app.color.white") })
                    .backgroundColor($r("app.color.white"))

                    // 第三组设置项
                    Column() {
                        // 信息铃声
                        SettingItemJump({
                            primaryTitle: $r("app.string.message_tone"),
                            showBottomDivider: true,
                            visibility: Visibility.None,
                            onClick: (event?: ClickEvent) => {
                                // 跳转铃声设置页面
                                this.mSettingsCtrl.jumpToMessageTonePage()
                            }
                        })
                        // 高级
                        SettingItemJump({
                            primaryTitle: $r("app.string.advanced"),
                            onClick: (event?: ClickEvent) => {
                                // 跳转高级设置界面
                                this.mSettingsCtrl.advancedSetting()
                            }
                        })
                    }
                    .width('100%')
                    .padding({
                        top: $r('app.float.settings_item_padding_top'),
                        bottom: $r('app.float.settings_item_padding_bottom'),
                        left: $r('app.float.settings_item_padding_left'),
                        right: $r('app.float.settings_item_padding_right')
                    })
                    .border({ radius: $r('app.float.settings_items_radius'), color: $r("app.color.white") })
                    .backgroundColor($r("app.color.white"))
                }
                .margin({
                    top: $r('app.float.settings_items_margin_top'),
                    bottom: $r('app.float.settings_items_margin_bottom')
                })
                .useSizeType({
                    xs: { span: 8, offset: 2 },
                    sm: { span: 4, offset: 0 },
                    md: { span: 8, offset: 2 },
                    lg: { span: 8, offset: 2 }
                })
            }
            .height('100%')
        }
        .width('100%')
        .height('100%')
        .backgroundColor($r("app.color.setting_background"))
    }
}