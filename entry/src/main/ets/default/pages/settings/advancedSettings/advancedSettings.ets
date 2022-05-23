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
import { MmsSimpleDialog } from '../../../views/MmsDialogs';
import { MmsMenu } from "../../../views/MmsMenu";
import router from "@system.router";
import { SettingItemJump } from "../../../views/SettingItem";

@Entry
@Component
struct AdvancedSettings {
    @State mAdvancedSettingsCtrl: AdvancedSettingsController = AdvancedSettingsController.getInstance();
    @State gridColumns: number = DeviceUtil.isTablet() ? 12 : 4;
    @State gridSizeType: SizeType = DeviceUtil.isTablet() ? SizeType.LG : SizeType.SM;
    @State gridGutter: string = "12vp";
    @State gridMargin: string = "12vp";
    dialogAlignment: DialogAlignment = DeviceUtil.isTablet() ? DialogAlignment.Center : DialogAlignment.Bottom;
    dialogOffset: Offset = DeviceUtil.isTablet() ? { dx: 0, dy: 0 } : { dx: 0, dy: -12 };
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
        offset: this.dialogOffset
    })

    /**
     * 函数在创建自定义组件的新实例后，在执行其build函数之前执行。
     * 允许在aboutToAppear函数中改变状态变量，这些更改将在后续执行build函数中生效。
     */
    aboutToAppear() {
        this.mAdvancedSettingsCtrl.onInit();
    }
    /**
     * 当此页面显示时触发一次。包括路由过程、应用进入前后台等场景，仅@Entry修饰的自定义组件生效。
     */
    onPageShow() {
        this.mAdvancedSettingsCtrl.onShow()
    }
    /**
     * 当此页面消失时触发一次。包括路由过程、应用进入前后台等场景，仅@Entry修饰的自定义组件生效。
     */
    onPageHide() {
    }
    /**
     * 函数在自定义组件析构消耗之前执行。
     * 不允许在aboutToDisappear函数中改变状态变量，特别是@Link变量的修改可能会导致应用程序行为不稳定。
     */
    aboutToDisappear() {
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

                    Text($r("app.string.advanced"))
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
                        // 送达报告
                        SettingItemJump({
                            primaryTitle: $r("app.string.delivery_reports"),
                            secondaryTitle: $r("app.string.delivery_reports_hint"),
                            statusTitle: this.mAdvancedSettingsCtrl.deliveryReportSwitchInText,
                            showBottomDivider: false,
                            onClick: (event?: ClickEvent) => {
                                this.deliveryReportsDialogCtrl.open();
                            }
                        })
                        // 自动下载彩信
                        SettingItemJump({
                            primaryTitle: $r("app.string.auto_retrieve_mms"),
                            statusTitle: this.mAdvancedSettingsCtrl.autoRetrieveMmsSwitchInText,
                            visibility: Visibility.None,
                            onClick: (event?: ClickEvent) => {
                                this.mAdvancedSettingsCtrl.showAutoRetrieveMmsDialog();
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

                    // 第二组设置项
                    Column() {
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

                    // 第三组设置项
                    Column() {
                        // 短信中心
                        SettingItemJump({
                            primaryTitle: $r("app.string.sms_center"),
                            showBottomDivider: true,
                            onClick: (event?: ClickEvent) => {
                                this.mAdvancedSettingsCtrl.jumpToSmsCenterPage(1);
                            }
                        })
                        // 管理SIM卡中的信息
                        SettingItemJump({
                            primaryTitle: $r("app.string.manage_sim_card_messages"),
                            onClick: (event?: ClickEvent) => {
                                this.mAdvancedSettingsCtrl.jumpToManageSimPage(1);
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

/**
 * 送达报告选择框
 */
@CustomDialog
struct DeliveryReportsDialog {
    controller: CustomDialogController;
    cancel: () => void;
    confirm: (isOnOfSms: boolean, isOnOfMms: boolean) => void;
    @State isOnOfSms: boolean = false;
    @State isOnOfMms: boolean = false;

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
                        .enabled(false)
                }
                .width("100%")
                .height(48)
                .onClick((event: ClickEvent) => {
                    this.isOnOfSms = !this.isOnOfSms;
                })

                Divider().vertical(false).strokeWidth(1).width("100%").color($r("app.color.divider_color"))

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
                        .enabled(false)
                }
                .width("100%")
                .height(48)
                .onClick((event: ClickEvent) => {
                    this.isOnOfMms = !this.isOnOfMms;
                })

                Divider().vertical(false).strokeWidth(1).width("100%").color($r("app.color.divider_color"))
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
                .backgroundColor($r("app.color.back_Transparent"))
                .layoutWeight(1)
                .height(40)
                .onClick(() => {
                    this.controller.close();
                    this.cancel();
                })

                Divider().vertical(true).strokeWidth(0.5).height(24).color($r("app.color.divider_color"))
                Button() {
                    Text($r("app.string.ok"))
                        .textAlign(TextAlign.Center)
                        .fontSize(16)
                        .fontColor($r("sys.color.ohos_id_color_activated"))
                        .fontWeight(FontWeight.Medium)
                        .fontFamily("HarmonyHeiTi")
                        .lineHeight(22)
                }
                .backgroundColor($r("app.color.back_Transparent"))
                .layoutWeight(1)
                .height(40)
                .onClick(() => {
                    this.controller.close();
                    this.confirm(this.isOnOfSms, this.isOnOfMms);
                })
            }
            .width('100%')
            .height(56)
            .padding({ left: 16, right: 16, bottom: 16 })
        }
        .width(DeviceUtil.isTablet() ? 622 : "100%")
        .borderRadius($r("app.float.settings_items_radius"))
        .backgroundColor($r("app.color.white"))
    }
}
