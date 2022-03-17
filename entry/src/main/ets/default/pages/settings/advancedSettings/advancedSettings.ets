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
import mediaquery from '@ohos.mediaquery'
import router from '@system.router';
import AdvancedSettingsController from './advancedSettingsController'
import common from '../../../data/commonData'
import {RestoreDialogs} from '../../../views/MmsDialogs'
import {SettingItemSwitch, SettingItemJump} from '../../../views/SettingItem'

let portraitFunc = null

@Entry
@Component
struct AdvancedSettings {
  @StorageLink('AdvancedSettingsController') mAdvancedSettingsCtrl: AdvancedSettingsController = AdvancedSettingsController.getInstance();
  @State gridColumns: number = 12;
  @State gridSizeType: SizeType = SizeType.LG;
  @State gridGutter: string = '12vp';
  @State gridMargin: string = '12vp';

  listener = mediaquery.matchMediaSync('(orientation: landscape)');

  onPortrait(mediaQueryResult) {
    if (mediaQueryResult.matches) {
      console.log("mediaQuery landScape")
    } else {
      console.log("mediaQuery vert")
      this.gridColumns = 4;
      this.gridSizeType = SizeType.SM;
      this.gridGutter = '20vp';
      this.gridMargin = '20vp';
    }
  }

  restoreDialogCtrl : CustomDialogController = new CustomDialogController({
    builder : RestoreDialogs({
      cancel : () => {
      },
      confirm : () => {
        this.mAdvancedSettingsCtrl.restoreSettingPageSwitchValue();
      },
      msg : $r("app.string.restore_all_default_settings"),
    }),
    autoCancel: false,
    alignment: DialogAlignment.Bottom,
    offset: { dx: 0, dy: '-20vp' }
  })

  deliveryReportsDialogCtrl : CustomDialogController = new CustomDialogController({
    builder : DeliveryReportsDialog({
      cancel : () => {
        this.mAdvancedSettingsCtrl.cancelRestore();
      },
      confirm : () => {
        this.mAdvancedSettingsCtrl.setRestore();
      },
      ctrl : $mAdvancedSettingsCtrl
    }),
    autoCancel: false,
    alignment: DialogAlignment.Bottom,
    offset: { dx: 0, dy: '-20vp' }
  })

  /**
   * 函数在创建自定义组件的新实例后，在执行其build函数之前执行。
   * 允许在aboutToAppear函数中改变状态变量，这些更改将在后续执行build函数中生效。
   */
  aboutToAppear() {
    this.mAdvancedSettingsCtrl.onInit();
    this.onPortrait(this.listener)
    portraitFunc = this.onPortrait.bind(this)
    this.listener.on('change', portraitFunc)
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
  onBackPress() {}

  build() {
    Row() {
      GridContainer({ columns: this.gridColumns, sizeType: this.gridSizeType, gutter: this.gridGutter, margin: this.gridMargin }) {
        // 顶部设备标题
        Row() {
          Image($rawfile("icon/ic_message_back.svg"))
            .width($r('app.float.icon_side_length_medium'))
            .height($r('app.float.icon_side_length_medium'))
            .margin({ left: $r('app.float.action_bar_margin_left'), right: $r('app.float.action_bar_space') })
            .onClick(() => {
              router.back()
            })

          Text($r("app.string.advanced"))
            .fontSize($r('app.float.action_bar_text_size'))
            .fontColor(Color.Black)
            .fontWeight(FontWeight.Bold)

          Blank()

          Image($rawfile("icon/ic_public_more.svg"))
            .width($r('app.float.icon_side_length_medium'))
            .height($r('app.float.icon_side_length_medium'))
            .margin({ left: $r('app.float.action_bar_space'), right: $r('app.float.action_bar_margin_right') })
            .bindMenu([
              {
                // @ts-ignore
                value : $r('app.string.restore_default_settings'),
                action : () => {
                  this.restoreDialogCtrl.open()
                }
              }
            ])
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
        Column({space: 12}) {
          // 第一组设置项
          Column() {
            // 送达报告
            SettingItemJump({
                primaryTitle : $r("app.string.delivery_reports"),
                secondaryTitle : $r("app.string.delivery_reports_hint"),
                statusTitle : this.mAdvancedSettingsCtrl.deliveryReportSwitchInText,
                showBottomDivider: true,
                onClick : (event?: ClickEvent) => {
                  this.deliveryReportsDialogCtrl.open();
              }
            })
            // 自动下载彩信
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
            // 取消发送
            SettingItemSwitch({
              primaryTitle: $r('app.string.recall_messages'),
              secondaryTitle: $r('app.string.recall_messages_hint'),
              isEnable: this.mAdvancedSettingsCtrl.recallMessageSwitch == common.bool.TRUE ? true : false,
              showBottomDivider: true,
              onChange: (isOn: boolean) => {
                this.mAdvancedSettingsCtrl.recallMsg(this);
              }
            })
            // 自动删除通知信息
            SettingItemSwitch({
              primaryTitle: $r('app.string.auto_delete_info_messages'),
              secondaryTitle: $r('app.string.auto_delete_info_messages_hint'),
              isEnable: this.mAdvancedSettingsCtrl.tempAutoDeleteInfoSwitch == common.bool.TRUE ? true : false,
              onChange: (isOn: boolean) => {
                this.mAdvancedSettingsCtrl.autoDeleteInfo(this);
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
          .visibility(Visibility.None)
          .border({ radius: $r('app.float.settings_items_radius'), color: $r("app.color.white") })
          .backgroundColor($r("app.color.white"))

          // 第三组设置项
          Column() {
            // 短信中心
            SettingItemJump({
              primaryTitle : $r("app.string.sms_center"),
              showBottomDivider: true,
              onClick : (event?: ClickEvent) => {
                this.mAdvancedSettingsCtrl.jumpToSmsCenterPage(1);
              }
            })
            // 管理SIM卡中的信息
            SettingItemJump({
              primaryTitle : $r("app.string.manage_sim_card_messages"),
              onClick : (event?: ClickEvent) => {
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
          .visibility(Visibility.None)
          .border({ radius: $r('app.float.settings_items_radius'), color: $r("app.color.white") })
          .backgroundColor($r("app.color.white"))
        }
        .margin({top: $r('app.float.settings_items_margin_top'), bottom: $r('app.float.settings_items_margin_bottom')})
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
    .backgroundColor($r("app.color.default_main_background"))
  }
}

/**
 * 送达报告选择框
 */
@CustomDialog
struct DeliveryReportsDialog {
  controller: CustomDialogController
  /**
   * 取消事件
   */
  cancel: () => void
  /**
   * 确认事件
   */
  confirm: () => void

  @Link ctrl: any;

  build() {
    Column() {
      Text($r('app.string.delivery_reports')).width('100%').margin({ bottom: 8 }).fontSize(16)
        .fontColor('#182431').lineHeight(22).fontWeight(FontWeight.Regular).fontFamily('HarmonyHeiTi')
      Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
        Text($r('app.string.sms'))
        Toggle({ type: ToggleType.Checkbox, isOn: this.ctrl.checkedValueOfSms})
          .width('20vp')
          .height('20vp')
          .enabled(false)
      }
      .width('100%')
      .height('32vp')
      .onClick((event: ClickEvent) => {
        this.ctrl.clickSmsDiv();
      })
      Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
        Text($r('app.string.mms'))
        Toggle({ type: ToggleType.Checkbox, isOn: this.ctrl.checkedValueOfMms })
          .width('20vp')
          .height('20vp')
          .enabled(false)
      }
      .width('100%')
      .height('32vp')
      .onClick((event: ClickEvent) => {
        this.ctrl.clickMmsDiv();
      })
      Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceEvenly, alignItems: ItemAlign.Center }) {
        Button() {
          Text($r("app.string.cancel"))
            .textAlign(TextAlign.Center)
            .fontSize(16)
            .fontColor('#007DFF')
            .fontWeight(FontWeight.Medium)
            .fontFamily('HarmonyHeiTi')
            .lineHeight(22)
            .onClick(() => {
              this.controller.close();
              this.cancel();
            })
        }.backgroundColor($r("app.color.back_Transparent")).layoutWeight(1)
        Divider().vertical(true).strokeWidth('2px').height('20vp').color(Color.Gray)
        Button() {
          Text($r("app.string.ok"))
            .textAlign(TextAlign.Center)
            .fontSize(16)
            .fontColor('#007DFF')
            .fontWeight(FontWeight.Medium)
            .fontFamily('HarmonyHeiTi')
            .lineHeight(22)
            .onClick(() => {
              this.controller.close();
              this.confirm();
            })
        }.backgroundColor($r("app.color.back_Transparent")).layoutWeight(1)
      }
      .width('100%')
      .height(40)
    }
    .width('100%')
    .padding( {left: 24, right: 24, top: 24, bottom: 16} )
  }
}
