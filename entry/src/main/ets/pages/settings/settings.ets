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
import { MmsSimpleDialog } from "../../views/MmsDialogs";
import { MoreMenu } from "../../views/MmsMenu";
import router from "@system.router";
import { SettingItemSwitch, SettingItemJump } from "../../views/SettingItem";
import SettingsController from "./settingsController";
import HiLog from "../../utils/HiLog";
import WantUtil from "../../utils/WantUtil";
import AdvancedSettingsController from "./advancedSettings/advancedSettingsController"

const TAG = "Settings";
@Entry
@Component
struct Settings {
    @StorageLink("SettingsController") @Watch("changeSelectState") mSettingsCtrl:
        SettingsController = SettingsController.getInstance()
    @StorageLink("AdvancedSettingsController") @Watch("changeSelectState") mAdvancedSettingsCtrl:
        AdvancedSettingsController = AdvancedSettingsController.getInstance();
    private gridColumns: GridRowColumnOption = { sm: 4, md: 8, lg: 12 };
    private girdSpan: GridColColumnOption = { sm: 4, md: 6, lg: 8 };
    private gridColOffset: GridColColumnOption = { md: 1, lg: 2 };
    private gridGutter: string = "12vp";
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
                this.mAdvancedSettingsCtrl.restoreSettingPageSwitchValue();
            }
        }
    });

    changeSelectState(){
    }

    @Provide menuItems: Array<any> = [
        {
            value: $r("app.string.restore_default_settings"),
            action: () => {
                this.restoreDialog.show();
            },
            enabled: true
        }
    ];
    @Provide statusTitle: any = '' ;

    /**
     * The function executes after a new instance of the custom component is created and before its build function
     * is executed.
     * Allows state variables to be changed in the aboutToAppear function, and these changes will take effect in
     * subsequent executions of the build function.
     */
    aboutToAppear() {
        this.mSettingsCtrl.onInit()
    }

    /**
     * Function executes before custom component destructor consumption.
     * Changing state variables in the aboutToDisappear function is not allowed, especially changes to the @Link
     * variable may cause unstable application behavior.
     */
    aboutToDisappear() {
    }

    /**
     * Triggers once when this page is displayed. In scenarios such as routing and application access to the foreground
     * and background, only customized components modified by @Entry take effect.
     */
    onPageShow() {
        this.mSettingsCtrl.onShow();
        WantUtil.getWant();
    }

    /**
     * Triggers once when this page disappears. In scenarios such as routing and application access to the foreground
     * and background, only customized components modified by @Entry take effect.
     */
    onPageHide() {
    }

    /**
     * Triggered when a user clicks the back button. Only the customized component modified by @Entry takes effect.
     * If true is returned, the page processes the return logic and does not route the page.
     * If false is returned, the default return logic is used.
     * If no value is returned, the value is treated as false.
     */
    onBackPress() {
    }

    build() {
        Column() {
            // Top Device Title
            Row() {
                Image($rawfile("icon/ic_message_back.svg"))
                    .width($r("app.float.icon_side_length_medium"))
                    .height($r("app.float.icon_side_length_medium"))
                    .margin({
                        left: $r("app.float.action_bar_margin_left")
                    })
                    .onClick(() => {
                        router.back()
                    })

                Row().width($r("app.float.space_16"))

                Text($r("app.string.settings"))
                    .fontSize($r("app.float.action_bar_text_size"))
                    .fontColor(Color.Black)
                    .fontWeight(FontWeight.Bold)

                Row().width("100%").flexShrink(1)

                Column() {
                    MoreMenu()
                }
                .margin({ right: $r("app.float.action_bar_margin_right") })
            }
            .width("100%")
            .height($r("app.float.action_bar_height"))

            Scroll() {
                GridRow({ columns: this.gridColumns, gutter: this.gridGutter }) {
                    GridCol({ span: this.girdSpan, offset: this.gridColOffset }) {
                        // All settings
                        Column() {
                            // Setting items of the first group
                            Column() {
                                // Enhanced Information
                                SettingItemJump({
                                    primaryTitle: $r("app.string.enhanced_information"),
                                    visibilityShow: this.isEnhanceShow,
                                    OnClick: (event?: ClickEvent) => {
                                        // The page for setting enhanced information is displayed.
                                    }
                                })

                                // Intelligent information
                                SettingItemJump({
                                    primaryTitle: $r("app.string.intelligent_information"),
                                    OnClick: (event?: ClickEvent) => {
                                        // The ringtone setting page is displayed.
                                    }
                                })
                            }
                            .width("100%")
                            .padding({
                                top: $r("app.float.settings_item_padding_top"),
                                bottom: $r("app.float.settings_item_padding_bottom"),
                                left: $r("app.float.settings_item_padding_left"),
                                right: $r("app.float.settings_item_padding_right")
                            })
                            .border({
                                radius: $r("app.float.settings_items_radius"),
                                color: $r("sys.color.ohos_id_color_text_field_bg")
                            })
                            .backgroundColor($r("sys.color.ohos_id_color_text_field_bg"))
                            .visibility(Visibility.None)

                            // Setting items of the second group
                            Column() {
                                // Notification information integration
                                SettingItemSwitch({
                                    primaryTitle: $r("app.string.archive_info_messages"),
                                    secondaryTitle: $r("app.string.archive_info_messages_hint"),
                                    isEnable: this.mSettingsCtrl.integrationSwitch,
                                    showBottomDivider: false,
                                    onChange: (isOn: boolean) => {
                                        this.mSettingsCtrl.integration(isOn)
                                    }
                                })
                            }
                            .width("100%")
                            .padding({
                                top: $r("app.float.settings_item_padding_top"),
                                bottom: $r("app.float.settings_item_padding_bottom"),
                                left: $r("app.float.settings_item_padding_left"),
                                right: $r("app.float.settings_item_padding_right")
                            })
                            .border({
                                radius: $r("app.float.settings_items_radius"),
                                color: $r("sys.color.ohos_id_color_text_field_bg")
                            })
                            .backgroundColor($r("sys.color.ohos_id_color_text_field_bg"))

                            // Setting items of the third group
                            Column() {
                                // Message ringtone
                                SettingItemJump({
                                    primaryTitle: $r("app.string.message_tone"),
                                    showBottomDivider: true,
                                    visibilityShow: Visibility.None,
                                    OnClick: (event?: ClickEvent) => {
                                        // The ringtone setting page is displayed.
                                        this.mSettingsCtrl.jumpToMessageTonePage()
                                    }
                                })
                                // Advanced
                                SettingItemJump({
                                    primaryTitle: $r("app.string.advanced"),
                                    OnClick: (event?: ClickEvent) => {
                                        // Go to the advanced settings screen.
                                        this.mSettingsCtrl.advancedSetting()
                                    }
                                })
                            }
                            .width("100%")
                            .padding({
                                top: $r("app.float.settings_item_padding_top"),
                                bottom: $r("app.float.settings_item_padding_bottom"),
                                left: $r("app.float.settings_item_padding_left"),
                                right: $r("app.float.settings_item_padding_right")
                            })
                            .margin({ top: 12 })
                            .border({
                                radius: $r("app.float.settings_items_radius"),
                                color: $r("sys.color.ohos_id_color_text_field_bg")
                            })
                            .backgroundColor($r("sys.color.ohos_id_color_text_field_bg"))
                        }
                        .margin({
                            top: $r("app.float.settings_items_margin_top"),
                            bottom: $r("app.float.settings_items_margin_bottom")
                        })
                    }
                }
            }
            .layoutWeight(1)
            .align(Alignment.Top)
        }
        .width("100%")
        .height("100%")
        .padding({ left: $r("app.float.page_padding_left"), right: $r("app.float.page_padding_right") })
        .backgroundColor($r("sys.color.ohos_id_color_sub_background"))
    }
}