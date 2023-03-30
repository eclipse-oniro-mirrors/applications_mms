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
import AdvancedSettingsController from "./advancedSettingsController";
import DeviceUtil from "../../../utils/DeviceUtil";
import { MmsSimpleDialog } from "../../../views/MmsDialogs";
import { MoreMenu } from "../../../views/MmsMenu";
import router from "@system.router";
import { SettingItemJump } from "../../../views/SettingItem";
import WantUtil from "../../../utils/WantUtil";
import SettingsController from  "../settingsController"

@Entry
@Component
struct AdvancedSettings {
    @StorageLink("AdvancedSettingsController") @Watch("changeSelectState") mAdvancedSettingsCtrl:
        AdvancedSettingsController = AdvancedSettingsController.getInstance();
    @StorageLink("SettingsController") @Watch("changeSelectState") mSettingsCtrl:
        SettingsController = SettingsController.getInstance()
    private gridColumns: GridRowColumnOption = { sm: 4, md: 8, lg: 12 };
    private girdSpan: GridColColumnOption = { sm: 4, md: 6, lg: 8 };
    private gridColOffset: GridColColumnOption = { md: 1, lg: 2 };
    private gridGutter: string = "12vp";
    private dialogGridCount: number = 4;
    dialogAlignment: DialogAlignment = DeviceUtil.isTablet() ? DialogAlignment.Center : DialogAlignment.Bottom;
    dialogOffset: Offset = DeviceUtil.isTablet() ? { dx: 0, dy: 0 } : { dx: 0, dy: -16 };
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
                this.mAdvancedSettingsCtrl.restoreSettingPageSwitchValue();
                this.mSettingsCtrl.restoreSettingsPageSwitchValue();
            }
        }
    });
    @Provide menuItems: Array<any> = [
        {
            value: $r("app.string.restore_default_settings"),
            action: () => {
                this.restoreDialog.show();
            },
            enabled: true
        }
    ];
    @Provide statusTitle: Resource = this.mAdvancedSettingsCtrl.deliveryReportSwitchInText;
    changeSelectState(){
        this.statusTitle = this.mAdvancedSettingsCtrl.deliveryReportSwitchInText
    }
    deliveryReportsDialogCtrl: CustomDialogController = new CustomDialogController({
        builder: DeliveryReportsDialog({
            cancel: () => {
                this.mAdvancedSettingsCtrl.cancelRestore();
            },
            confirm: (isOnOfSms: boolean, isOnOfMms: boolean) => {
                this.mAdvancedSettingsCtrl.setRestore(isOnOfSms, isOnOfMms);
            },
            isOnOfSms: this.mAdvancedSettingsCtrl.checkedValueOfSms,
            isOnOfMms: this.mAdvancedSettingsCtrl.checkedValueOfMms
        }),
        autoCancel: false,
        alignment: this.dialogAlignment,
        offset: this.dialogOffset,
        gridCount: this.dialogGridCount
    })

    /**
     * The function executes after a new instance of the custom component is created and before its build function
     * is executed.
     * Allows state variables to be changed in the aboutToAppear function, and these changes will take effect in
     * subsequent executions of the build function.
     */
    aboutToAppear() {
        this.mAdvancedSettingsCtrl.onInit();
    }
    /**
     * Triggers once when this page is displayed. In scenarios such as routing and application access to the foreground
     * and background, only customized components modified by @Entry take effect.
     */
    onPageShow() {
        this.mAdvancedSettingsCtrl.onShow();
        WantUtil.getWant();
    }
    /**
     * Triggers once when this page disappears. In scenarios such as routing and application access to the foreground
     * and background, only customized components modified by @Entry take effect.
     */
    onPageHide() {
    }
    /**
     * Function executes before custom component destructor consumption.
     * Changing state variables in the aboutToDisappear function is not allowed, especially changes to the @Link
     * variable may cause unstable application behavior.
     */
    aboutToDisappear() {
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

                Text($r("app.string.advanced"))
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
                        Column({ space: 12 }) {
                            // Setting items of the first group
                            Column() {
                                // Delivery Report
                                SettingItemJump({
                                    primaryTitle: $r("app.string.delivery_reports"),
                                    secondaryTitle: $r("app.string.delivery_reports_hint"),
                                    showBottomDivider: false,
                                    OnClick: (event?: ClickEvent) => {
                                        this.deliveryReportsDialogCtrl.open();
                                    }
                                })
                                // Automatically downloading MMs
                                SettingItemJump({
                                    primaryTitle: $r("app.string.auto_retrieve_mms"),
//                                    statusTitle: this.mAdvancedSettingsCtrl.autoRetrieveMmsSwitchInText,
                                    visibilityShow: Visibility.None,
                                    OnClick: (event?: ClickEvent) => {
                                        this.mAdvancedSettingsCtrl.showAutoRetrieveMmsDialog();
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

                            // Setting items of the second group
                            Column() {
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

                            // Setting items of the third group
                            Column() {
                                // SMSC
                                SettingItemJump({
                                    primaryTitle: $r("app.string.sms_center"),
                                    showBottomDivider: true,
                                    OnClick: (event?: ClickEvent) => {
                                        this.mAdvancedSettingsCtrl.jumpToSmsCenterPage(1);
                                    }
                                })
                                // Managing SIM Card Information
                                SettingItemJump({
                                    primaryTitle: $r("app.string.manage_sim_card_messages"),
                                    OnClick: (event?: ClickEvent) => {
                                        this.mAdvancedSettingsCtrl.jumpToManageSimPage(1);
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

/**
 * Delivery report selection box
 */
@CustomDialog
struct DeliveryReportsDialog {
    controller: CustomDialogController;
    cancel: () => void;
    confirm: (isOnOfSms: boolean, isOnOfMms: boolean) => void;
    private isOnOfSms: boolean = false;
    private isOnOfMms: boolean = false;

    build() {
        Column() {
            Column() {
                Text($r("app.string.delivery_reports"))
                    .width("100%")
                    .height(56)
                    .textAlign(TextAlign.Start)
                    .fontSize(20)
                    .fontColor($r("sys.color.ohos_id_color_foreground"))
                    .lineHeight(28)
                    .fontWeight(FontWeight.Medium)
                    .fontFamily("HarmonyHeiTi")
                Flex({
                    direction: FlexDirection.Row,
                    justifyContent: FlexAlign.SpaceBetween,
                    alignItems: ItemAlign.Center
                }) {
                    Text($r("app.string.sms"))
                        .fontSize(16)
                        .fontColor($r("sys.color.ohos_id_color_foreground"))
                        .lineHeight(22)
                        .fontWeight(FontWeight.Medium)
                        .fontFamily("HarmonyHeiTi")
                    Toggle({ type: ToggleType.Checkbox, isOn: this.isOnOfSms })
                        .width(20)
                        .height(20)
                        .offset({ x: 16, y: 0 })
                        .selectedColor($r("sys.color.ohos_id_color_activated"))
                        .onChange((isOn: boolean) => {
                            this.isOnOfSms = isOn
                        })
                }
                .width("100%")
                .height(48)

                Divider()
                    .vertical(false)
                    .strokeWidth(0.5)
                    .width("100%")
                    .color($r("sys.color.ohos_id_color_list_separator"))

                Flex({
                    direction: FlexDirection.Row,
                    justifyContent: FlexAlign.SpaceBetween,
                    alignItems: ItemAlign.Center
                }) {
                    Text($r("app.string.mms"))
                        .fontSize(16)
                        .fontColor($r("sys.color.ohos_id_color_foreground"))
                        .lineHeight(22)
                        .fontWeight(FontWeight.Medium)
                        .fontFamily("HarmonyHeiTi")
                    Toggle({ type: ToggleType.Checkbox, isOn: this.isOnOfMms })
                        .width(20)
                        .height(20)
                        .offset({ x: 16, y: 0 })
                        .selectedColor($r("sys.color.ohos_id_color_activated"))
                        .onChange((isOn: boolean) => {
                            this.isOnOfMms = isOn
                        })
                }
                .width("100%")
                .height(48)

            }
            .padding({ left: 24, right: 24, bottom: 9 })

            Flex({
                direction: FlexDirection.Row,
                justifyContent: FlexAlign.SpaceEvenly,
                alignItems: ItemAlign.Center
            }) {
                Button() {
                    Text($r("app.string.cancel"))
                        .textAlign(TextAlign.Center)
                        .fontSize(16)
                        .fontColor($r("sys.color.ohos_id_color_activated"))
                        .fontWeight(FontWeight.Medium)
                        .fontFamily("HarmonyHeiTi")
                        .lineHeight(22)
                }
                .backgroundColor($r("sys.color.ohos_id_color_background_transparent"))
                .layoutWeight(1)
                .height(40)
                .onClick(() => {
                    this.controller.close();
                    this.cancel();
                })

                Divider().vertical(true).strokeWidth(0.5).height(24).color($r("sys.color.ohos_id_color_list_separator"))
                Button() {
                    Text($r("app.string.ok"))
                        .textAlign(TextAlign.Center)
                        .fontSize(16)
                        .fontColor($r("sys.color.ohos_id_color_activated"))
                        .fontWeight(FontWeight.Medium)
                        .fontFamily("HarmonyHeiTi")
                        .lineHeight(22)
                }
                .backgroundColor($r("sys.color.ohos_id_color_background_transparent"))
                .layoutWeight(1)
                .height(40)
                .onClick(() => {
                    this.controller.close();
                    this.confirm(this.isOnOfSms, this.isOnOfMms);
                })
            }
            .width("100%")
            .height(56)
            .padding({ left: 16, right: 16, bottom: 16 })
        }
        .width("100%")
        .borderRadius(16)  // Customdialog need to set borderRadius
        .backgroundColor($r("sys.color.ohos_id_color_dialog_bg"))
    }
}
