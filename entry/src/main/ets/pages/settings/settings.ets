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
import DeviceUtil from '../../utils/DeviceUtil';
import { MoreMenu } from '../../views/MmsMenu';
import { SettingItemJump, SettingItemRcsJump, SettingItemSmartJump, SettingItemSwitch, SettingItemFilingNo, SettingItemBlockedJump } from '../../views/SettingItem';
import SettingsController from './settingsController';
import HiLog from '../../utils/HiLog';
import WantUtil from '../../utils/WantUtil';
import AdvancedSettingsController from './advancedSettings/advancedSettingsController';
import { AgreeNetworkDialog } from '../../views/dialogs/AgreeNetworkDialog';
import DotUtil from '../../utils/MmsDot/DotUtils';
import dotCommon, { dotNoNeedParmas, stateParam } from '../../utils/MmsDot/DotCommon';
import LooseObject from '../../data/LooseObject';
import { AlertDialog, CustomContentDialog } from '@ohos.arkui.advanced.Dialog';
import ResourceUtils from '../../utils/ResourceUtils';
import SharedPreferencesUtils from '../../utils/SharedPreferencesUtils';
import MmsBoolean from '../../data/MmsBoolean';
import { FilingNo } from '../privacy/FilingNo';
import { Configuration, LengthMetrics, SymbolGlyphModifier } from '@kit.ArkUI';
import settings from '@ohos.settings';
import { GlobalContext } from '../../MainAbility/GlobalHelper';
import myCommon from '@ohos.app.ability.common';
import common from '../../data/commonData';
import { emitter } from '@kit.BasicServicesKit';
import EmitterConstant from '../../data/EmitterConstant';
import StringUtil from '../../utils/StringUtil';
import prompt from '@ohos.promptAction';
import { SystemMode } from '../../utils/SystemMode';
import Prompt from '@ohos.promptAction';
import Constant from '../../data/Constant';
import { CustomSettingsNavBar } from './settingsNavBar';
import { AnimationViewModel } from './NavBarAnimationViewModel';
import { ApplicationStateChange } from './ApplicationStateChange';

const TAG = 'Settings';

class menuItemsObj{
    public value?: ResourceStr
    public action: () => void = () => {}
    public enabled: boolean = false
    public visible: boolean = true;
}

@Builder
export function SettingsLoader(param: LooseObject): void {
    Settings();
}

@Component
export struct Settings {
    // 设置页模态展示状态
    @StorageLink('isSettingShow') isSettingShow: boolean = false;
    @Provide('pageInfosSetting') pageInfosSetting : NavPathStack = new NavPathStack()
    @LocalStorageProp('fullScreenPadding') fullScreenPadding:Padding | null = null;
    private context = getContext(this) as myCommon.UIAbilityContext;
    @StorageLink('SettingsController') mSettingsCtrl:
        SettingsController = SettingsController.getInstance();
    @StorageLink('AdvancedSettingsController') mAdvancedSettingsCtrl:
        AdvancedSettingsController = AdvancedSettingsController.getInstance();

    @Provide stateTitle: Resource = $r('app.string.enabled') ;
    isEnhanceShow: Visibility = DeviceUtil.isTablet() ? Visibility.None : Visibility.Visible;
    private isAdvancedMode: boolean = SharedPreferencesUtils.getFromPreferences('isAdvancedMode', false) as boolean;
    /* 是否启用rcs能力 */
    private isEnableRcsAbility: boolean = SystemMode.getInstance().isEnableRcsAbility;
    /* 设备是否为pad,并判断是否具有蜂窝能力 */
    @State isPad: boolean = DeviceUtil.isTablet();
    @State isPC: boolean = DeviceUtil.isPC();
    @StorageLink('mmsPadMargin') padMargin: number = DeviceUtil.padMargin();
    @State isCellularTablet: boolean = DeviceUtil.isCellularTablet();
    @State isWifiOnlyTablet: boolean = DeviceUtil.isWifiOnlyTablet();
    @State isSubDeviceWithConnected: boolean = DeviceUtil.isSubDeviceWithConnected(this.context);
    @State animationViewModel: AnimationViewModel = new AnimationViewModel('50%', 0, 0);
    @StorageProp('fontSizeScale') fontSizeScale: number = 1;
    onClose?: () => void;

    @Styles
    normalStyles(){
        .backgroundColor(Color.Transparent)
    }

    @Styles
    pressedStyles(){
        .backgroundColor($r('sys.color.interactive_click'))
        .borderRadius($r('sys.float.corner_radius_level4'))
    }

    restoreDiaLogController: CustomDialogController = new CustomDialogController({
        builder: AlertDialog({
            content: $r('app.string.restore_all_default_settings'),
            primaryButton: {
                value: $r('app.string.cancel'),
                action: () => {
                    HiLog.i(TAG, 'Cancel Settings')
                    // 还原默认设置-取消打点
                    stateParam.STATE = 1;
                    DotUtil.getInstance().reportEvent(stateParam, dotCommon.eventName.MORE_RESTORE_DEFAULT);
                }
            },
            secondaryButton: {
                value: $r('app.string.restore'),
                action: () => {
                    HiLog.i(TAG, 'Restore Settings')
                    this.mAdvancedSettingsCtrl.restoreSettingPageSwitchValue();
                    this.mSettingsCtrl.restoreSettingsPageSwitchValue();
                    this.mSettingsCtrl.reStoreSmartMmsInfo()
                    this.mSettingsCtrl.reStoreDeleteDialog();
                    this.mSettingsCtrl.restoreMmsRingtone();
                    // 还原默认设置-还原打点
                    stateParam.STATE = 2;
                    DotUtil.getInstance().reportEvent(stateParam, dotCommon.eventName.MORE_RESTORE_DEFAULT);
                }
            }
        }),
        autoCancel: false,
    })

    @Provide statusTitle: Resource | null = null;
    @Provide deliverStatusTitle: Resource | null = null;
    @Provide newPrivacyStatement: boolean = false;
    @Provide harassmentInterceptionStatus: Resource | null = $r('app.string.disabled');
    @State isVisibleSmart: boolean = false;
    applicationStateChangeCallback: ApplicationStateChange = new ApplicationStateChange()

    aboutToAppear() {
        this.destinationShow();
        this.mSettingsCtrl.onInit(this.pageInfosSetting);

        try {
            let context = getContext(this) as myCommon.UIAbilityContext;
            let self = this
            this.applicationStateChangeCallback.callback = () => {
                self.destinationShow();
            }
            context.getApplicationContext().on('applicationStateChange', this.applicationStateChangeCallback)
        } catch (exception) {
            HiLog.e(TAG, 'Failed code');
        }
        // 在页面显示和消失时使用标记位标记
        AppStorage.setOrCreate('isSettingsAppear', true);
    }

    aboutToDisappear(): void {
        this.destinationHide();
        AppStorage.setOrCreate('tipsJumpToRcsSetting', false);
        let context = getContext(this) as myCommon.UIAbilityContext;
        // //回调为空会导致crash
        this.applicationStateChangeCallback.callback = () => {
        }
        context.getApplicationContext().off('applicationStateChange', this.applicationStateChangeCallback);
        AppStorage.setOrCreate('isSettingsAppear', false);
    }

    @Builder
    agreeNetworkDialogBuildContent(): void {
        AgreeNetworkDialog({
            msg: $r('app.string.mms_need_network'),
            msgDescription: $r('app.string.mms_need_network_description')
        })
    }

    /**
     * Triggers once when this page is displayed. In scenarios such as routing and application access to the foreground
     * and background, only customized components modified by @Entry take effect.
     */
    destinationShow() {
        this.mSettingsCtrl.onShow();
        this.newPrivacyStatement =
         SharedPreferencesUtils.getFromPreferences(common.STR.KEY_OF_NEW_PRIVACY_STATEMENT, true) as boolean;
        WantUtil.getWant(this.context,this.pageInfosSetting);
        this.getHarassmentInterceptionStatus();
        HiLog.i(TAG, `destinationShow = ${JSON.stringify(this.stateTitle)}`);
    }

    destinationHide() {
      HiLog.i(TAG, `destinationHide start`);
    }

    // 查询 [陌生号码识别与骚扰拦截] 的开关状态
    private getHarassmentInterceptionStatus() {
        if (!this.context) {
            HiLog.e(TAG, 'setting: getHarassmentInterceptionStatus context is null!');
            return;
        }
        let status: string = settings.getValueSync(this.context, common.STR.NUMBER_IDENTITY_SEITCH, common.bool.FALSE);
        if (status == common.bool.FALSE) {
            this.harassmentInterceptionStatus = $r('app.string.disabled')
        } else {
            this.harassmentInterceptionStatus = $r('app.string.enabled');
        }
        HiLog.i(TAG, 'HarassmentInterceptionStatus: ' + status)
    }

    @Builder
    NavMenu() {
        Column() {
            MoreMenu()
        }
        .padding({right: this.isPad ? this.padMargin : 16, top: 8 })
    }

    build() {
        Navigation(this.pageInfosSetting) {
            // Top Device Title
            CustomSettingsNavBar({
                animationViewModel: this.animationViewModel,
                isShowBackBtn: false,
                title: $r('app.string.settings'),
                isNeedAnimation: false,
                onClose: this.onClose
            });

            Scroll() {
              // All settings
              Column() {
                    // Setting items of the second group
                    Column() {
                        // Notification information integration
                        SettingItemSwitch({
                            primaryTitle: $r('app.string.archive_info_messages'),
                            secondaryTitle: $r('app.string.archive_info_messages_hint'),
                            isEnable: this.mSettingsCtrl.integrationSwitch,
                            showBottomDivider: false,
                            onChange: (isOn: boolean) => {
                                this.mSettingsCtrl.integration(isOn)
                            }
                        })
                            .height(this.fontSizeScale < 1 ? '64' : 'auto')
                    }
                    .width('100%')
                    .margin({ top: DeviceUtil.isPC() ? '' : 12 })
                    .padding({
                        top: $r('app.float.settings_item_padding_top'),
                        bottom: $r('app.float.settings_item_padding_bottom'),
                        left: 4,
                        right: 4
                    })
                    .border({
                        radius: $r('sys.float.corner_radius_level10'),
                        color: $r('sys.color.comp_background_list_card')
                    })
                    .backgroundColor($r('sys.color.comp_background_list_card'))

                    // Setting items of the third group
                  Column() {
                      // Message ringtone
                      SettingItemJump({
                          primaryTitle: $r('app.string.message_tone'),
                          showBottomDivider: true,
                          OnClick: (event?: ClickEvent) => {
                              // The ringtone setting page is displayed.
                              this.mSettingsCtrl.jumpToMessageTonePage();
                              DotUtil.getInstance().reportEvent(dotNoNeedParmas,
                                  dotCommon.eventName.NOTIFICATION_RING_AND_SONG);
                          }
                      })
                          .height(this.fontSizeScale < 1 ? '48' : 'auto')
                          .visibility(DeviceUtil.isPC() ? Visibility.None : Visibility.Visible)
                      SettingItemSwitch({
                          primaryTitle: $r('app.string.show_contact_profile_pics'),
                          isEnable: this.mSettingsCtrl.showContactSwitch,
                          showBottomDivider: false,
                          onChange: (isOn: boolean) => {
                              this.mSettingsCtrl.showContact(isOn)
                          }
                      })
                          .height(this.fontSizeScale < 1 ? '48' : 'auto')
                  }
                  .width('100%')
                  .margin({ top: 12 })
                  .padding({
                      top: $r('app.float.settings_item_padding_top'),
                      bottom: $r('app.float.settings_item_padding_bottom'),
                      left: 4,
                      right: 4
                  })
                  .border({
                      radius: $r('sys.float.corner_radius_level10'),
                      color: $r('sys.color.comp_background_list_card')
                  })
                  .backgroundColor($r('sys.color.comp_background_list_card'))

                    // privacy state
                  // Column() {
                  //     // mms privacy state
                  //     SettingItemJump({
                  //         primaryTitle: $r('app.string.privacy_statements'),
                  //         showCircle: true,
                  //         OnClick: (event?: ClickEvent) => {
                  //             HiLog.i(TAG, 'privacyStateRedirection')
                  //             this.mSettingsCtrl.privacyStateRedirection();
                  //             SharedPreferencesUtils.saveToPreferences(
                  //                 common.STR.KEY_OF_NEW_PRIVACY_STATEMENT, false
                  //                 );
                  //             this.newPrivacyStatement = false
                  //             DotUtil.getInstance().reportEvent(dotNoNeedParmas,
                  //                 dotCommon.eventName.SETTING_MMS_PRIVACY_STATE);
                  //         },
                  //         showBottomDivider: true
                  //     })
                  //         .height(this.fontSizeScale < 1 ? '48' : 'auto')
                  //     // mms personal information list
                  //     SettingItemJump({
                  //         primaryTitle: $r('app.string.mms_personal_information_list'),
                  //         OnClick: (event?: ClickEvent) => {
                  //             HiLog.i(TAG, 'personalInformationListRedirection')
                  //             this.mSettingsCtrl.personalInformationListRedirection();
                  //             DotUtil.getInstance().reportEvent(dotNoNeedParmas,
                  //                 dotCommon.eventName.SETTING_MMS_PERSONAL_LIST);
                  //         }
                  //     })
                  //         .height(this.fontSizeScale < 1 ? '48' : 'auto')
                  // }
                  // .width('100%')
                  // .margin({ top: 12 })
                  // .padding({
                  //     top: $r('app.float.settings_item_padding_top'),
                  //     bottom: $r('app.float.settings_item_padding_bottom'),
                  //     left: 4,
                  //     right: 4
                  // })
                  // .border({
                  //     radius: $r('sys.float.corner_radius_level10'),
                  //     color: $r('sys.color.comp_background_list_card')
                  // })
                  // .backgroundColor($r('sys.color.comp_background_list_card'))

                    Column() {
                        // Advanced
                        SettingItemJump({
                            primaryTitle: $r('app.string.advanced'),
                            OnClick: (event?: ClickEvent) => {
                                // Go to the advanced settings screen.
                                this.mSettingsCtrl.advancedSetting()
                                // 更多-设置-高级打点
                                DotUtil.getInstance()
                                    .reportEvent(dotNoNeedParmas, dotCommon.eventName.SETTING_ADVANCED_BUTTON);
                            }
                        })
                            .height(this.fontSizeScale < 1 ? '48' : 'auto')
                    }
                    .width('100%')
                    .margin({ top: 12 })
                    .padding({
                        top: $r('app.float.settings_item_padding_top'),
                        bottom: $r('app.float.settings_item_padding_bottom'),
                        left: 4,
                        right: 4
                    })
                    .border({
                        radius: $r('sys.float.corner_radius_level10'),
                        color: $r('sys.color.comp_background_list_card')
                    })
                    .backgroundColor($r('sys.color.comp_background_list_card'))
                    .visibility(DeviceUtil.isPC() ? Visibility.None : Visibility.Visible)

                  Column() {
                      //restore_default_settings
                      SettingItemJump({
                          primaryTitle: $r('app.string.restore_default_settings'),
                          isHideChevronRight: true,
                          OnClick: () => {
                              this.restoreDiaLogController.open();
                              // 更多-设置-更多-还原默认设置打点
                              DotUtil.getInstance()
                                  .reportEvent(dotNoNeedParmas, dotCommon.eventName.MORE_RESTORE_DEFAULT_DIALOG);
                          }
                      })
                          .height(this.fontSizeScale < 1 ? '48' : 'auto')
                  }
                  .width('100%')
                  .margin({ top: 12 })
                  .padding({
                      top: $r('app.float.settings_item_padding_top'),
                      bottom: $r('app.float.settings_item_padding_bottom'),
                      left: 4,
                      right: 4
                  })
                  .border({
                      radius: $r('sys.float.corner_radius_level10'),
                      color: $r('sys.color.comp_background_list_card')
                  })
                  .backgroundColor($r('sys.color.comp_background_list_card'))

                    Blank().layoutWeight(1)

                    // FilingNo
                    // Column() {
                    //     SettingItemFilingNo({
                    //         primaryTitle: $r('app.string.FilingNo'),
                    //         OnClick: (event?: ClickEvent) => {
                    //             HiLog.i(TAG, 'filingNoRedirection')
                    //             FilingNo.getInstance().implicitStartBrowserAbility();
                    //         }
                    //     })
                    //         .height(this.fontSizeScale < 1 ? '48' : 'auto')
                    // }
                    // .width('100%')
                    // .alignItems(HorizontalAlign.Center)
                    // .justifyContent(FlexAlign.End)
                }
                .margin({
                    top: $r('app.float.settings_items_margin_top'),
                    bottom: $r('app.float.settings_items_margin_bottom')
                })
            }
            .align(Alignment.Top)
            .scrollBar(BarState.Off)
            .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
            .width('100%')
            .height('calc(100% - 64vp)')
            .padding({
                left: DeviceUtil.isPC() ? 16 : this.isPad ? this.padMargin : $r('sys.float.margin_left'),
                right: DeviceUtil.isPC() ? 16 : this.isPad ? this.padMargin : $r('sys.float.margin_left')
            })
        }
        .hideBackButton(true)
        .hideTitleBar(true)
        .backgroundColor(DeviceUtil.isPC() ? $r('app.color.color_bind_sheet_background_pc') :
        $r('app.color.color_bind_sheet_background_phone'))
        .onAppear(() => {
            this.animationViewModel.enterAnimation();
        })
        .onDisAppear(() => {
            this.animationViewModel.backAnimation();
        })
    }
}