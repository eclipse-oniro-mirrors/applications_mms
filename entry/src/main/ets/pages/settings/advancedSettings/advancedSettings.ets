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
import AdvancedSettingsController from './advancedSettingsController';
import DeviceUtil from '../../../utils/DeviceUtil';
import { MoreMenu } from '../../../views/MmsMenu';
import {
    SettingItemJumpAutoRetrieve,
    SettingItemJumpDeliveryReport,
    SettingItemJumpSimCardManage,
    SettingItemSwitch,
    SettingItemSwitchAutoDelete,
} from '../../../views/SettingItem';
import WantUtil from '../../../utils/WantUtil';
import SettingsController from '../settingsController';
import LooseObject from '../../../data/LooseObject';
import MmsBoolean from '../../../data/MmsBoolean';
import common from '../../../data/commonData';
import MmsPreferences from '../../../utils/MmsPreferences';
import emitter from '@ohos.events.emitter';
import simCardService from '../../../service/SimCardService';
import DotUtil from '../../../utils/MmsDot/DotUtils';
import dotCommon, { dotNoNeedParmas, selectStateParams, seleteParam, stateParam
} from '../../../utils/MmsDot/DotCommon';
import { AlertDialog, CustomContentDialog } from '@ohos.arkui.advanced.Dialog';
import ResourceUtils from '../../../utils/ResourceUtils';
import HiLog from '../../../utils/HiLog';
import ConversationController from '../../conversation/conversationController';
import { SymbolGlyphModifier } from '@kit.ArkUI';
import myCommon from '@ohos.app.ability.common';
import Prompt from '@ohos.promptAction';
import { SystemMode } from '../../../utils/SystemMode';
import { CustomSettingsNavBar } from '../settingsNavBar';
import { AnimationViewModel } from '../NavBarAnimationViewModel';

const TAG = 'AdvancedSettings';

class menuItemObj {
    public value?: Resource;
    public action: () => void = () => {
    };
    public enabled: boolean = false;
    public visible: boolean = true;
}

@Builder
export function AdvancedSettingsLoader(param: LooseObject): void {
    AdvancedSettings();
}

@Component
export struct AdvancedSettings {
    @Consume('pageInfosSetting') pageInfosSetting: NavPathStack
    @LocalStorageProp('fullScreenPadding') fullScreenPadding: Padding | null = null;
    private context = getContext(this) as myCommon.UIAbilityContext;
    @StorageLink('AdvancedSettingsController') @Watch('changeSelectState') mAdvancedSettingsCtrl:
        AdvancedSettingsController = AdvancedSettingsController.getInstance();
    @StorageLink('SettingsController') @Watch('changeSelectState') mSettingsCtrl:
        SettingsController = SettingsController.getInstance();
    @State mConversationCtrl: ConversationController = ConversationController.getInstance();
    dialogAlignment: DialogAlignment = DeviceUtil.isTablet() ? DialogAlignment.Center : DialogAlignment.Bottom;
    dialogOffset: Offset = DeviceUtil.isTablet() ? { dx: 0, dy: 0 } : {
        dx: 0,
        dy: $r('app.float.dialog_bottom_margin')
    };
    /* 设备是否为pad,并判断是否具有蜂窝能力 */
    @State isPad: boolean = DeviceUtil.isTablet();
    @State isCellularTablet: boolean = DeviceUtil.isCellularTablet();
    @State isWifiOnlyTablet: boolean = DeviceUtil.isWifiOnlyTablet();
    @State isSubDeviceWithConnected: boolean = DeviceUtil.isSubDeviceWithConnected(this.context);
    @StorageLink('curBp') curBp: string = common.STR.DEVICE_MOBILE_PHONE;
    @State startIconModifier: SymbolGlyphModifier = new SymbolGlyphModifier($r('sys.symbol.checkmark')).fontSize('24vp')
    @State isShowMenu: boolean = false;
    @State animationViewModel: AnimationViewModel = new AnimationViewModel('50%', 0, 0);
    @StorageProp('fontSizeScale') fontSizeScale: number = 1;
    backPressCallback?: () => boolean; //自定义返回逻辑
    @Styles
    normalStyles(){
        .backgroundColor(Color.Transparent)
    }

    @Styles
    pressedStyles(){
        .backgroundColor($r('sys.color.interactive_click'))
        .borderRadius($r('sys.float.corner_radius_level8'))
    }

    restoreDiaLogController: CustomDialogController = new CustomDialogController({
        builder: AlertDialog({
            content: $r('app.string.restore_all_default_settings'),
            primaryButton: {
                value: $r('app.string.cancel'),
                action: () => {
                    HiLog.i(TAG, 'Cancel AdvancedSettings')
                }
            },
            secondaryButton: {
                value: $r('app.string.restore'),
                action: () => {
                    HiLog.i(TAG, 'Restore AdvancedSettings')
                    this.mAdvancedSettingsCtrl.restoreSettingPageSwitchValue();
                    this.mSettingsCtrl.restoreSettingsPageSwitchValue();
                    this.mSettingsCtrl.reStoreDeleteDialog();
                    this.mSettingsCtrl.restoreMmsRingtone();
                }
            }
        }),
        autoCancel: false,
    })

    @Consume deliverStatusTitle: Resource;

    changeSelectState() {
        this.deliverStatusTitle = this.mAdvancedSettingsCtrl.deliveryReportSwitchInText;
    }

    deliveryReportsDialogCtrl: CustomDialogController = new CustomDialogController({
        builder: CustomContentDialog({
            primaryTitle: $r('app.string.delivery_reports'),
            contentAreaPadding: { left: 12, right: 12 },
            contentBuilder: () => {
                this.deliveryReportsDialogBuildContent()
            },
            buttons: [
                {
                    value: $r('app.string.cancel'),
                    buttonStyle: ButtonStyleMode.TEXTUAL,
                    action: () => {
                        this.mAdvancedSettingsCtrl.cancelRestore();
                        // 送达报告-取消-打点
                        selectStateParams.STATE = 2;
                        DotUtil.getInstance().reportEvent(selectStateParams,
                            dotCommon.eventName.DELIVERY_REPORT_DIALOG_EVENT);
                    }
                },
                {
                    value: $r('app.string.ok'),
                    buttonStyle: ButtonStyleMode.TEXTUAL,
                    action: () => {
                        this.mAdvancedSettingsCtrl.setRestore(this.mAdvancedSettingsCtrl.checkedValueOfSms,
                            this.mAdvancedSettingsCtrl.checkedValueOfMms);
                        selectStateParams.STATE = 1;
                        DotUtil.getInstance().reportEvent(selectStateParams,
                            dotCommon.eventName.DELIVERY_REPORT_DIALOG_EVENT);
                    }
                }
            ],
        }),
        autoCancel: false,
        alignment: DialogAlignment.Center
    });

    @Builder
    deliveryReportsDialogBuildContent(): void {
        DeliveryReportsDialog()
    }

    /**
     * The function executes after a new instance of the custom component is created and before its build function
     * is executed.
     * Allows state variables to be changed in the aboutToAppear function, and these changes will take effect in
     * subsequent executions of the build function.
     */
    destinationAppear() {
        this.mAdvancedSettingsCtrl.onInit(this.pageInfosSetting);
    }

    /**
     * Triggers once when this page is displayed. In scenarios such as routing and application access to the foreground
     * and background, only customized components modified by @Entry take effect.
     */
    destinationShow() {
        HiLog.i(TAG, `destinationShow`);
        this.mAdvancedSettingsCtrl = AdvancedSettingsController.getInstance()
        this.mAdvancedSettingsCtrl.onShow();
        WantUtil.getWant(this.context, this.pageInfosSetting);
    }

    /**
     * Triggers once when this page disappears. In scenarios such as routing and application access to the foreground
     * and background, only customized components modified by @Entry take effect.
     */
    destinationPageHide() {
    }

    /**
     * Function executes before custom component destructor consumption.
     * Changing state variables in the aboutToDisappear function is not allowed, especially changes to the @Link
     * variable may cause unstable application behavior.
     */
    destinationDisappear() {
    }

    /**
     * Triggered when a user clicks the back button. Only the customized component modified by @Entry takes effect.
     * If true is returned, the page processes the return logic and does not route the page.
     * If false is returned, the default return logic is used.
     * If no value is returned, the value is treated as false.
     */
    onBackPress() {
    }

    @Builder
    NavMenu() {
        Column() {
            MoreMenu()
        }
        .margin({ right: 16, top: 8 })
    }

    destinationBackPress(): boolean {
        HiLog.i(TAG, 'onBackPress')
        // let accessBackward = this.pafController.getWebNode()?.getParams()?.controller?.accessBackward();
        // let accessBackward = null;
        // HiLog.i(TAG, `onBackPress accessBackward: ${accessBackward}`);
        // if (accessBackward) {
        //   return this.pafController.onBackPress();
        // }
        if (this.backPressCallback) {
            return this.backPressCallback();
        } else {
            this.pageInfosSetting.pop();
            return true;
        }
    }

    aboutToAppear() {
        this.isPad = DeviceUtil.isTablet();
        this.mAdvancedSettingsCtrl.getAdvancedPageSwitchValue();
    }

    build() {
        NavDestination() {
            // Top Device Title
            CustomSettingsNavBar({
                animationViewModel: this.animationViewModel,
                isShowBackBtn: true,
                title: $r('app.string.advanced'), //弹窗里面的text
                onCancel: () => {
                    this.destinationBackPress();
                }
            });
            Column() {
                Scroll() {
                    // All settings
                    Column({ space: 12 }) {
                        // Setting items of the first group
                        Column() {
                            // Delivery Report
                            SettingItemJumpDeliveryReport({
                                primaryTitle: $r('app.string.delivery_reports'),
                                secondaryTitle: $r('app.string.delivery_reports_hint'),
                                showBottomDivider: false,
                                OnClick: (event?: ClickEvent) => {
                                    this.deliveryReportsDialogCtrl.open();
                                    // 高级-送达报告打点
                                    seleteParam.SELECT_STATE = 1;
                                    DotUtil.getInstance().reportEvent(seleteParam,
                                        dotCommon.eventName.SET_ADVANCED_SELECT_EVENT);
                                }
                            })
                                .height(this.fontSizeScale < 1 ? '64' : 'auto')
                        }
                        .width('100%')
                        .padding({
                            top: $r('app.float.settings_item_padding_top'),
                            bottom: $r('app.float.settings_item_padding_bottom'),
                            left: 4,
                            right: 0
                        })
                        .border({
                            radius: $r('sys.float.corner_radius_level10'),
                            color: $r('sys.color.comp_background_list_card')
                        })
                        .backgroundColor($r('sys.color.comp_background_list_card'))
                        .visibility(this.isWifiOnlyTablet ? Visibility.None : Visibility.Visible)
                        .opacity(this.isCellularTablet && this.isSubDeviceWithConnected ? 0.4 : 1)
                        .enabled(this.isCellularTablet && this.isSubDeviceWithConnected ? false : true)

                    }
                    .margin({
                        top: $r('app.float.settings_items_margin_top'),
                        bottom: $r('app.float.settings_items_margin_bottom')
                    })
                }
                .layoutWeight(1)
                .align(Alignment.Top)
                .scrollBar(BarState.Off)
                .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
            }
            .width('100%')
            .height('calc(100% - 64vp)')
            .padding({ left: $r('sys.float.margin_left'), right: $r('sys.float.margin_right') })
        }
        .onShown(() => {
            this.destinationShow();
        })
        .onAppear(() => {
            this.destinationAppear();
            this.animationViewModel.enterAnimation();
        })
        .onWillDisappear(()=>{
            this.animationViewModel.backAnimation();
        })
        .onDisAppear(() => {
            this.destinationDisappear();
        })
        .onHidden(() => {
            this.destinationPageHide();
        })
        .hideTitleBar(true)
        .backgroundColor(DeviceUtil.isPC() ? $r('app.color.color_bind_sheet_background_pc') :
        $r('app.color.color_bind_sheet_background_phone'))
    }

    @Builder
    MenuDivider() {
        Divider()
            .vertical(false)
            .width('100%')
            .color($r('sys.color.ohos_id_color_list_separator'))
            .padding({ left: 8, right: 8 })
    }
}

@Component
struct DeliveryReportsDialog {

    @StorageLink('AdvancedSettingsController') mAdvancedSettingsCtrl:
        AdvancedSettingsController = AdvancedSettingsController.getInstance();

    @Styles
    normalStyles(){
        .backgroundColor(Color.Transparent)
    }

    @Styles
    pressedStyles(){
        .backgroundColor($r('sys.color.interactive_click'))
        .borderRadius($r('sys.float.corner_radius_level8'))
    }
    build() {
        Column() {
            Stack({ alignContent: Alignment.End }) {
                Text($r('app.string.sms'))
                    .fontSize($r('sys.float.ohos_id_text_size_body1'))
                    .fontColor($r('sys.color.ohos_id_color_text_primary'))
                    .lineHeight(21)
                    .fontWeight(FontWeight.Medium)
                    .fontFamily('HarmonyHeiTi')
                    .align(Alignment.Start)
                    .width('100%')
                Toggle({ type: ToggleType.Checkbox, isOn: this.mAdvancedSettingsCtrl.checkedValueOfSms })
                    .height('20vp')
                    .width('20vp')
                    .margin('2vp')
                    .selectedColor($r('sys.color.comp_background_emphasize'))
                    .align(Alignment.End)
                    .onChange((isOn: boolean) => {
                        this.mAdvancedSettingsCtrl.checkedValueOfSms = isOn
                    })
            }
            .constraintSize({ minHeight: 48 })
            .padding({ left: 12, right: 12 })
            .stateStyles({
                pressed: this.pressedStyles,
                normal: this.normalStyles
            })
            .onClick(() => {
                this.mAdvancedSettingsCtrl.checkedValueOfSms = !this.mAdvancedSettingsCtrl.checkedValueOfSms;
            })

            Divider()
                .vertical(false)
                .width('100%')
                .padding({ left: 12, right: 12 })
                .color($r('sys.color.ohos_id_color_list_separator'))

            Stack({alignContent:Alignment.End}) {
                Text($r('app.string.mms'))
                    .fontSize($r('sys.float.ohos_id_text_size_body1'))
                    .fontColor($r('sys.color.ohos_id_color_text_primary'))
                    .lineHeight(21)
                    .fontWeight(FontWeight.Medium)
                    .fontFamily('HarmonyHeiTi')
                    .align(Alignment.Start)
                    .width('100%')
                Toggle({ type: ToggleType.Checkbox, isOn: this.mAdvancedSettingsCtrl.checkedValueOfMms })
                    .height('20vp')
                    .width('20vp')
                    .margin('2vp')
                    .selectedColor($r('sys.color.comp_background_emphasize'))
                    .align(Alignment.End)
                    .onChange((isOn: boolean) => {
                        this.mAdvancedSettingsCtrl.checkedValueOfMms = isOn
                    })
            }
            .constraintSize({ minHeight: 48 })
            .padding({ left: 12, right: 12 })
            .stateStyles({
                pressed: this.pressedStyles,
                normal: this.normalStyles
            })
            .onClick(() => {
                this.mAdvancedSettingsCtrl.checkedValueOfMms = !this.mAdvancedSettingsCtrl.checkedValueOfMms;
            })
        }
    }
}