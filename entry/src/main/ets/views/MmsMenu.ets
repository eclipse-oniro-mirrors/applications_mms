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
import commonData from '../data/commonData';
import { Settings } from '../pages/settings/settings';
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import HiLog from '../utils/HiLog';
import DeviceUtil from '../utils/DeviceUtil';
import DotUtil from '../utils/MmsDot/DotUtils';
import dotCommon, { dotNoNeedParmas } from '../utils/MmsDot/DotCommon';

const TAG = 'MmsMenu'


/**
 * Custom pop-up menu buttons
 */
class menuItemsObj {
    public value?: ResourceStr
    public action: () => void = () => {}
    public enabled: boolean = false
    public visible: boolean = true;
    public color: ResourceColor = $r('sys.color.ohos_id_color_text_primary')
}
@Component
export struct MoreMenu {
    @StorageLink('curBp') curBp: string = commonData.STR.DEVICE_MOBILE_PHONE;
    @Consume menuItems:Array<menuItemsObj>;
    @Prop isInfoMsg: boolean = false;
    private menuImage: Resource = $r('sys.symbol.dot_grid_2x2');
    private placement: Placement = Placement.Bottom;
    private defaultColor: Resource = $r('sys.color.ohos_id_color_dialog_bg');
    private menuText: Resource | null = null;
    private curHeight: Length = 40;
    private curWidth: Length = 40;
    private menuTextColor: Resource = $r('sys.color.ohos_id_color_text_primary');

    @Styles
    iconNormalStyles(){
        .backgroundColor(this.defaultColor)
    }

    @Styles
    iconPressedStyles(){
        .backgroundColor($r('sys.color.ohos_id_color_click_effect'))
        .borderRadius($r('sys.float.ohos_id_corner_radius_clicked'))
    }

    @Styles
    buttonNormalStyles(){
        .backgroundColor(Color.Transparent)
    }

    @Styles
    buttonPressedStyles(){
        .backgroundColor(this.isInfoMsg ? Color.Transparent : $r('sys.color.ohos_id_color_click_effect'))
        .borderRadius(this.isInfoMsg ? 0 : 20)
    }

    private getVisibleMenuItems() {
        return this.menuItems.filter((item) => {
            return item.visible
        });
    }

    @Builder
    PopupBuilder() {
        Menu() {
            ForEach(this.getVisibleMenuItems(), (item: menuItemsObj, index?: number) => {
                if (index !== 0 && !DeviceUtil.isPC()) {
                  this.multDivider()
                }
                MenuItem({ content: item.value })
                    .constraintSize({ minHeight: $r('app.float.id_item_height_mid') })
                    .contentFont({ weight: FontWeight.Medium, size: $r('sys.float.Body_L') })
                    .contentFontColor(item.color)
                    .enabled(item.enabled)
                    .onClick(() => {
                        if (item.enabled) {
                            item.action();
                        }
                    })
            }, (item: menuItemsObj) => JSON.stringify(item))
        }.width(DeviceUtil.isPC() ? 160 : this.curBp == commonData.STR.DEVICE_FLAT_PLATE ? 198 : 224)
    }
    @Builder
    multDivider() {
        Divider()
            .color($r('sys.color.ohos_id_color_list_separator'))
            .height($r('app.float.settings_divider_strokeWidth'))
            .margin({ left: 12, right: 12 })
    }
    build() {
        Button() {
            Column() {
                SymbolGlyph(this.menuImage)
                    .width('24vp')
                    .height('24vp')
                    .draggable(false)
                    .id('settingMoreButton')
                    .fontSize('24vp')
                    .margin({top: '5vp' })
                    .fontColor([$r('sys.color.ohos_id_color_primary')])
                if (this.menuText != null) {
                    Text(this.menuText)
                        .fontSize('10vp')
                        .fontColor(this.menuTextColor)
                        .fontSize($r('sys.float.ohos_id_text_size_caption'))
                        .fontWeight(FontWeight.Medium)
                        .fontColor($r('sys.color.ohos_id_color_toolbar_text'))
                        .accessibilityLevel('no')
                        .margin({top: '2vp' })
                }
            }
            .backgroundColor(this.isInfoMsg ? Color.Transparent : $r('sys.color.ohos_id_color_button_normal'))
            .width(this.isInfoMsg ? '100%' : this.curWidth)
            .height('100%')
            .alignItems(HorizontalAlign.Center)
            .justifyContent(FlexAlign.Center)
            .borderRadius(20)
        }
        .onClick(
            () => {
                let applicationContext: common.ApplicationContext = getContext(this).getApplicationContext();
                let want: Want = {
                    bundleName: 'com.ohos.spamshield',
                    abilityName: 'SmsProtectRecordAbility',
                    parameters: {
                        'ability.want.params.uiExtensionType': 'sys/commonUI'
                    }
                }
                try {
                    applicationContext.preloadUIExtensionAbility(want).then(() => {
                        HiLog.i(TAG, '[block list] preloadUIExtensionAbility succeed');
                    }).catch((err: BusinessError) => {
                        HiLog.e(TAG, `[block list] preloadUIExtensionAbility failed: ${err}`);
                    })
                } catch (err) {
                    let code = (err as BusinessError).code;
                    let message = (err as BusinessError).message;
                    HiLog.e(TAG,
                        `preloadUIExtensionAbility BusinessError.code ${code} and BusinessError.message ${message}`)
                }
            })
        .accessibilityText(getContext(this).resourceManager.getStringSync($r('app.string.more_options_button').id))
        .bindMenu(this.PopupBuilder, {
            placement: DeviceUtil.isPC() ? Placement.TopLeft : (this.curBp === commonData.STR.DEVICE_MOBILE_PHONE ||
            this.isInfoMsg ? Placement.Bottom : Placement.BottomRight)
        })
        .width(this.isInfoMsg ? '100%' : this.curWidth)
        .height(this.isInfoMsg ? 52 : 40)
        .align(Alignment.Center)
        .buttonStyle(ButtonStyleMode.TEXTUAL)
        .stateEffect(false)
    }
}

@Reusable
@Component
export struct SettingMenu {
  @StorageLink('curBp') curBp: string = commonData.STR.DEVICE_MOBILE_PHONE;
  @Link moreMenuItems: Array<menuItemsObj>;
  //组件复用，通知消息更多组件提供复用，暂不开启。
  isInfoMsg: boolean = false;
  private menuImage: Resource = $r('sys.symbol.dot_grid_2x2');
  private defaultColor: Resource = $r('sys.color.ohos_id_color_dialog_bg');
  private menuText: Resource | null = null;
  private curWidth: Length = 40;
  private menuTextColor: Resource = $r('sys.color.ohos_id_color_text_primary');

  @Builder
  settingsBuilder() {
    Settings()
      .width('100%')
      .height('100%')
  }

  @Styles
  iconNormalStyles(){
    .backgroundColor(this.defaultColor)
  }

  @Styles
  iconPressedStyles(){
    .backgroundColor($r('sys.color.ohos_id_color_click_effect'))
    .borderRadius($r('sys.float.ohos_id_corner_radius_clicked'))
  }

  @Styles
  buttonNormalStyles(){
    .backgroundColor(Color.Transparent)
  }

  @Styles
  buttonPressedStyles(){
    .backgroundColor(this.isInfoMsg ? Color.Transparent : $r('sys.color.ohos_id_color_click_effect'))
    .borderRadius(this.isInfoMsg ? 0 : 20)
  }

  private getVisibleMenuItems() {
    return this.moreMenuItems.filter((item) => {
      return item.visible
    });
  }

  @Builder
  PopupBuilder() {
    Menu() {
      ForEach(this.getVisibleMenuItems(), (item: menuItemsObj, index?: number) => {
        if (index !== 0 && !DeviceUtil.isPC()) {
          this.multDivider()
        }
        if (index !== 0 && DeviceUtil.isPC()) {
          this.pcMultDivider()
        }
        MenuItem({ content: item.value })
            .constraintSize({ minHeight: DeviceUtil.isPC() ? '' : $r('app.float.id_item_height_mid') })
            .height(DeviceUtil.isPC() ? 40 : '')
            .contentFont({ weight: FontWeight.Medium, size: $r('sys.float.Body_L') })
            .contentFontColor(item.color)
            .enabled(item.enabled)
            .onClick(() => {
                if (item.enabled) {
                    item.action();
                }
            })
          .align(Alignment.Center)
      }, (item: menuItemsObj) => JSON.stringify(item))
    }
    .align(Alignment.Center)
    .width(DeviceUtil.isPC() ? 160 : this.curBp == commonData.STR.DEVICE_FLAT_PLATE ? 198 : 224)
  }

  @Builder
  multDivider() {
    Divider()
      .color($r('sys.color.ohos_id_color_list_separator'))
      .height($r('app.float.settings_divider_strokeWidth'))
      .margin({ left: 12, right: 12 })
  }

  @Builder
  pcMultDivider() {
    Row() {}
    .width('100%')
    .height(2)
  }

  build() {
    Button() {
      Column() {
        SymbolGlyph(this.menuImage)
          .width('24vp')
          .height('24vp')
          .draggable(false)
          .id('settingMoreButton')
          .fontSize('24vp')
          .fontColor([$r('sys.color.ohos_id_color_primary')])
        if (this.menuText != null) {
          Text(this.menuText)
            .fontSize('10vp')
            .lineHeight('14vp')
            .fontColor(this.menuTextColor)
            .fontSize($r('sys.float.ohos_id_text_size_caption'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.ohos_id_color_toolbar_text'))
            .margin({ top: '4vp' })
            .accessibilityLevel('no')
        }
      }
      .backgroundColor(this.isInfoMsg || DeviceUtil.isPC() ? Color.Transparent :
      $r('sys.color.ohos_id_color_button_normal'))
      .width(this.isInfoMsg ? '100%' : this.curWidth)
      .height('100%')
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.Center)
      .borderRadius(20)
    }
    .accessibilityText(getContext(this).resourceManager.getStringSync($r('app.string.more_options_button').id))
    .bindMenu(this.PopupBuilder, {
      placement: this.curBp === commonData.STR.DEVICE_MOBILE_PHONE ||
      this.isInfoMsg ? Placement.Bottom : Placement.BottomRight
    })
    .width(this.isInfoMsg ? '100%' : this.curWidth)
    .height(this.isInfoMsg ? 52 : 40)
    .align(Alignment.Center)
    .buttonStyle(ButtonStyleMode.TEXTUAL)
    .stateEffect(false)
    .type(ButtonType.Circle)
    .onClick(() => {
      if (!this.isInfoMsg) {
        DotUtil.getInstance().reportEvent(dotNoNeedParmas, dotCommon.eventName.SMSLIST_SETTING);
      }
    })
  }
}