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
import SettingsController from './settingsController'
import {RestoreDialogs} from '../../views/MmsDialogs'
import {SettingItemSwitch, SettingItemJump} from '../../views/SettingItem'

let portraitFunc = null

@Entry
@Component
struct Settings {
  @StorageLink('SettingsController') mSettingsCtrl : SettingsController = SettingsController.getInstance();
  @State gridColumns: number = 12;
  @State gridSizeType: SizeType = SizeType.LG;
  @State gridGutter: string = '12vp';
  @State gridMargin: string = '12vp';
  @State isMoreShow: Visibility = Visibility.Visible;
  isEnhanceShow: Visibility = Visibility.None;
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
      this.isMoreShow = Visibility.None;
      this.isEnhanceShow = Visibility.Visible;
    }
  }

  delDialogController : CustomDialogController = new CustomDialogController({
    builder : RestoreDialogs({
      cancel : () => {
      },
      confirm : () => {
        this.mSettingsCtrl.restoreSettingsPageSwitchValue()
      },
      msg : $r("app.string.restore_all_default_settings"),
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
    this.mSettingsCtrl.onInit()
    this.onPortrait(this.listener)
    portraitFunc = this.onPortrait.bind(this)
    this.listener.on('change', portraitFunc)
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

          Text($r("app.string.settings"))
            .fontSize($r('app.float.action_bar_text_size'))
            .fontColor(Color.Black)
            .fontWeight(FontWeight.Bold)

          Blank()

          Image($rawfile("icon/ic_public_more.svg"))
            .visibility(this.isMoreShow)
            .width($r('app.float.icon_side_length_medium'))
            .height($r('app.float.icon_side_length_medium'))
            .margin({ left: $r('app.float.action_bar_space'), right: $r('app.float.action_bar_margin_right') })
            .bindMenu([
              {
                // @ts-ignore
                value : $r('app.string.restore_default_settings'),
                action : () => {
                  this.delDialogController.open()
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
            // 增强信息
            SettingItemJump({
              primaryTitle: $r("app.string.enhanced_information"),
              statusTitle: $r("app.string.enabled"),
              isVisible: this.isEnhanceShow,
              onClick: (event?: ClickEvent) => {
                // 跳转增强信息设置页面
              }
            })

            // 智能信息
            SettingItemJump({
              primaryTitle : $r("app.string.intelligent_information"),
              statusTitle : $r("app.string.enabled"),
              onClick : (event?: ClickEvent) => {
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

          // 第二组设置项
          Column() {
            // 通知信息整合
            SettingItemSwitch({
              primaryTitle: $r('app.string.archive_info_messages'),
              secondaryTitle: $r('app.string.archive_info_messages_hint'),
              isEnable: this.mSettingsCtrl.integrationSwitch,
              showBottomDivider: true,
              onChange: (isOn: boolean) => {
                this.mSettingsCtrl.integration(this)
              }
            })
            // 恶意网址识别
            SettingItemSwitch({
              primaryTitle: $r('app.string.malicious_website_identification'),
              secondaryTitle: $r('app.string.malicious_website_identification_hint'),
              isEnable: this.mSettingsCtrl.maliciousWebSwitch,
              showBottomDivider: true,
              onChange: (isOn: boolean) => {
                this.mSettingsCtrl.maliciousWeb(this)
              }
            })
            // 验证码安全保护
            SettingItemSwitch({
              primaryTitle: $r('app.string.verification_code_security'),
              secondaryTitle: $r('app.string.verification_code_security_hint'),
              isEnable: true,
              onChange: (isOn: boolean) => {
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
              primaryTitle : $r("app.string.message_tone"),
              showBottomDivider: true,
              onClick : (event?: ClickEvent) => {
                // 跳转铃声设置页面
                this.mSettingsCtrl.jumpToMessageTonePage()
              }
            })
            // 显示联系人头像
            SettingItemSwitch({
              primaryTitle: $r('app.string.show_contact_profile_pics'),
              isEnable: true,
              showBottomDivider: true,
              onChange: (isOn: boolean) => {
              }
            })
            // 高级
            SettingItemJump({
              primaryTitle : $r("app.string.advanced"),
              onClick : (event?: ClickEvent) => {
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