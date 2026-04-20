/**
 * Copyright (c) 2022 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import MmsBoolean from '../data/MmsBoolean'
import AdvancedSettingsController from '../pages/settings/advancedSettings/advancedSettingsController';
import MmsPreferences from '../utils/MmsPreferences';
import DeviceUtil from '../utils/DeviceUtil';
import { LengthMetrics } from '@kit.ArkUI';
import Configuration from '@system.configuration';

/**
 * Options: dual title, 1 switch
 */
@Component
export struct SettingItemSwitch {
    primaryTitle?: string | Resource;
    secondaryTitle?: string | Resource;
    @ObjectLink isEnable: MmsBoolean;
    showBottomDivider ?: boolean = false;
    visibilityShow: Visibility = Visibility.Visible;
    onChange: (isOn: boolean) => void = () => {};
    isAdvanceSetting?: boolean = false;
    isSetGray?: boolean = false;

    @Styles
    normalStyles(){
      .backgroundColor(Color.Transparent)
    }

    @Styles
    pressedStyles(){
      .backgroundColor($r('sys.color.ohos_id_color_click_effect'))
      .borderRadius(14)
    }
    build() {
        Column() {
            Flex({
                direction: FlexDirection.Row,
                justifyContent: FlexAlign.SpaceBetween,
                alignItems: ItemAlign.Center
            }) {
                Flex({
                    direction: FlexDirection.Column,
                    justifyContent: FlexAlign.Center,
                    alignItems: ItemAlign.Start
                }) {
                    Text(this.primaryTitle)
                        .fontWeight(FontWeight.Medium)
                        .fontSize($r('sys.float.ohos_id_text_size_body1'))
                        .fontColor($r('sys.color.ohos_id_color_text_primary'))
                        .opacity(this.isSetGray ? $r('sys.float.interactive_disable') : 1)

                    if (this.secondaryTitle != undefined) {
                        Text(this.secondaryTitle)
                            .margin({ top: $r('app.float.settings_item_title_space') })
                            .fontWeight(FontWeight.Regular)
                            .fontSize($r('sys.float.ohos_id_text_size_body2'))
                            .fontColor($r('sys.color.ohos_id_color_text_secondary'))
                            .opacity(this.isSetGray ? $r('sys.float.interactive_disable') : 1)
                    }
                }
                .margin({ end: LengthMetrics.vp(16) })

                Toggle({ type: ToggleType.Switch, isOn: this.isEnable.value })
                    .flexShrink(0)
                    .width($r('app.float.settings_item_switch_width'))
                    .height(20)
                    .selectedColor($r('sys.color.comp_background_emphasize'))
                    .switchPointColor($r('sys.color.ohos_id_color_foreground_contrary'))
                    .hoverEffect(HoverEffect.None)
                    .accessibilityLevel('yes')
                    .onChange((isOn: boolean) => {
                        if (typeof isOn === 'number') {
                            let newIsOn: number = isOn;
                            switch (newIsOn) {
                                case 1:
                                    isOn = true;
                                    break;
                                case 0:
                                    isOn = false;
                                    break;
                                default:
                                    break;
                            }
                        }
                        this.onChange(isOn);
                    })
                  .enabled(!this.isSetGray)
            }

            if (this.showBottomDivider) {
                Divider()
                    .vertical(false)
                    .height($r('app.float.settings_divider_strokeWidth'))
                    .color($r('sys.color.ohos_id_color_list_separator'))
                    .lineCap(LineCapStyle.Round)
                    .offset({y: 13})
            }
        }
        .accessibilityGroup(true)
        .width('100%')
        .visibility(this.visibilityShow)
        .padding({ left: 8, right: this.isAdvanceSetting ? 12 : 8, top: 13, bottom: 13 })
    }
}

@Component
export struct SettingItemSwitchAutoDelete {
  @Styles normalStyles(){
    .backgroundColor(Color.Transparent)
  }
  @Styles pressedStyles(){
    .backgroundColor($r('sys.color.ohos_id_color_click_effect'))
    .borderRadius(14)
  }
  primaryTitle?: string | Resource;
  secondaryTitle?: string | Resource;
  @ObjectLink isEnable: MmsBoolean;
  canOperation: boolean = false;
  showBottomDivider ?: boolean = false;
  visibilityShow: Visibility = Visibility.Visible;
  onChange: (isOn: boolean) => void = () => {
  };

  build() {
    Column() {
      Flex({
        direction: FlexDirection.Row,
        justifyContent: FlexAlign.SpaceBetween,
        alignItems: ItemAlign.Center
      }) {
        Flex({
          direction: FlexDirection.Column,
          justifyContent: FlexAlign.Center,
          alignItems: ItemAlign.Start
        }) {
          Text(this.primaryTitle)
            .fontWeight(FontWeight.Medium)
            .fontSize($r('sys.float.ohos_id_text_size_body1'))
            .fontColor($r('sys.color.ohos_id_color_text_primary'));

          if (this.secondaryTitle != undefined) {
            Text(this.secondaryTitle)
              .margin({ top: $r('app.float.settings_item_title_space') })
              .fontWeight(FontWeight.Regular)
              .fontSize($r('sys.float.ohos_id_text_size_body2'))
              .fontColor($r('sys.color.ohos_id_color_text_secondary'));
          }
        }

        Toggle({ type: ToggleType.Switch, isOn: this.isEnable.value })
          .width($r('app.float.settings_item_switch_width'))
          .selectedColor($r('sys.color.comp_background_emphasize'))
          .hoverEffect(HoverEffect.None)
          .accessibilityLevel('yes')
          .onChange((isOn: boolean) => {
            if (typeof isOn === 'number') {
              let newIsOn: number = isOn;
              switch (newIsOn) {
                case 1:
                  isOn = true;
                  break;
                case 0:
                  isOn = false;
                  break;
                default:
                  break;
              }
            }
            this.onChange(isOn);
          })
      }

      if (this.showBottomDivider) {
        Divider()
          .height($r('app.float.settings_divider_strokeWidth'))
          .vertical(false)
          .color($r('sys.color.ohos_id_color_list_separator'))
          .lineCap(LineCapStyle.Round)
          .offset({y: 13})
      }
    }
    .accessibilityGroup(true)
    .padding({ left: 8, right: 8, top: 13, bottom: 13 })
    .width('100%')
    .visibility(this.visibilityShow)
  }
}

/**
 * Setting items: double title, one status, and one next icon
 */
@Component
export struct SettingItemJump {
    primaryTitle?: string | Resource;
    secondaryTitle ?: string | Resource;
    @Consume statusTitle : Resource;
    showBottomDivider ?: boolean = false;
    showCircle ?: boolean = false;
    isHideChevronRight ?: boolean = false;
    @Consume newPrivacyStatement : boolean;
    visibilityShow: Visibility = Visibility.Visible;
    /* 是否置灰 */
    isSetGray ?: boolean = false;
    OnClick: (event?: ClickEvent) => void = () => {};
    @Styles normalStyles(){
      .backgroundColor(Color.Transparent)
    }
    @Styles pressedStyles(){
      .backgroundColor($r('sys.color.ohos_id_color_click_effect'))
      .borderRadius($r('sys.float.corner_radius_level8'))
    }

    build() {
        Column() {
            Flex({
                direction: FlexDirection.Row,
                justifyContent: FlexAlign.SpaceBetween,
                alignItems: ItemAlign.Center
            }) {
                Flex({
                    direction: FlexDirection.Column,
                    justifyContent: FlexAlign.Center,
                    alignItems: ItemAlign.Start
                }) {
                  Row(){
                    Text(this.primaryTitle)
                      .fontWeight(FontWeight.Medium)
                      .fontSize($r('sys.float.ohos_id_text_size_body1'))
                      .fontColor($r('sys.color.ohos_id_color_text_primary'))
                    if (this.showCircle && this.newPrivacyStatement) {
                      Circle({ width: 6, height: 6 })
                        .fill($r('sys.color.ohos_id_color_badge_red'))
                        .margin(Configuration.getLocale().dir === 'rtl' ? {right: 8} : {left: 8})
                        .accessibilityRole(AccessibilityRoleType.TEXT)
                        .accessibilityText(getContext(this).resourceManager
                          .getStringSync($r('app.string.has_new_message').id))
                    }
                  }
                    if (this.secondaryTitle != undefined) {
                        Text(this.secondaryTitle)
                            .margin({ top: $r('app.float.settings_item_title_space') })
                            .fontWeight(FontWeight.Regular)
                            .fontSize($r('sys.float.ohos_id_text_size_body2'))
                            .fontColor($r('sys.color.ohos_id_color_text_secondary'))
                    }
                }

                Row() {
                    if (this.statusTitle != undefined) {
                        Text(this.statusTitle)
                            .margin({ right: $r('app.float.settings_item_status_title_margin_right') })
                            .fontWeight(FontWeight.Regular)
                            .fontSize($r('sys.float.ohos_id_text_size_body2'))
                            .fontColor($r('sys.color.ohos_id_color_text_secondary'))
                    }

                    if (!this.isHideChevronRight){
                      SymbolGlyph($r('sys.symbol.chevron_right'))
                        .width($r('app.float.settings_item_next_image_width'))
                        .draggable(false)
                        .fontColor([$r('sys.color.ohos_id_color_fourth')])
                        .fontSize('24vp')
                    }
                }
            }
            .opacity(this.isSetGray ? $r('sys.float.interactive_disable') : 1)

            if (this.showBottomDivider) {
                Divider()
                    .height($r('app.float.settings_divider_strokeWidth'))
                    .vertical(false)
                    .color($r('sys.color.ohos_id_color_list_separator'))
                    .lineCap(LineCapStyle.Round)
                    .offset({y: 13})
            }
        }
        .onClick(this.OnClick)
        .width('100%')
        .visibility(this.visibilityShow)
        .padding({ left: 8, right: 8, top: 13, bottom: 13 })
        .stateStyles({
          normal:this.normalStyles,
          pressed:this.pressedStyles
        })
  }
}

/**
 * Setting items: FilingNo
 */
@Component
export struct SettingItemFilingNo {
  primaryTitle?: string | Resource;
  OnClick: (event?: ClickEvent) => void = () => {};
  /* 设备是否为pad */
  @State isPad: boolean = DeviceUtil.isTablet();
  @StorageProp('fontSizeScale') fontSizeScale: number = 1;

  build() {
      Text(this.primaryTitle)
        .fontSize(this.fontSizeScale <= 1.3 ? (this.fontSizeScale * 12) + 'vp' : '15.6vp')
        .lineHeight('16vp')
        .fontColor($r('sys.color.ohos_id_color_text_primary_activated'))
        .onClick(this.OnClick)
        .width('100%')
        .height('16vp')
        .margin({ bottom: this.isPad ? '40vp' : '32vp', top: '24vp'})
        .textAlign(TextAlign.Center)
  }
}

@Component
export struct SettingItemJumpDeliveryReport {
  @Styles normalStyles(){
    .backgroundColor(Color.Transparent)
  }
  @Styles pressedStyles(){
    .backgroundColor($r('sys.color.ohos_id_color_click_effect'))
    .borderRadius($r('sys.float.corner_radius_level8'))
  }
  primaryTitle?: string | Resource;
  secondaryTitle ?: string | Resource;
  @Consume deliverStatusTitle : Resource;
  showBottomDivider ?: boolean = false;
  visibilityShow: Visibility = Visibility.Visible;
  OnClick: (event?: ClickEvent) => void = () => {};
  @StorageProp('fontSizeScale') fontSizeScale: number = 1;

  build() {
    Column() {
      Flex({
        direction: FlexDirection.Row,
        justifyContent: FlexAlign.SpaceBetween,
        alignItems: ItemAlign.Center
      }) {
        Column() {
          Flex({
            direction: FlexDirection.Column,
            justifyContent: FlexAlign.Center,
            alignItems: ItemAlign.Start
          }) {
            Text(this.primaryTitle)
              .fontWeight(FontWeight.Medium)
              .fontSize($r('sys.float.ohos_id_text_size_body1'))
              .fontColor($r('sys.color.ohos_id_color_text_primary'))

            if (this.secondaryTitle != undefined) {
              Text(this.secondaryTitle)
                .width(this.fontSizeScale > 3 ? '100%' : '65%')
                .margin({ top: $r('app.float.settings_item_title_space') })
                .fontWeight(FontWeight.Regular)
                .fontSize($r('sys.float.ohos_id_text_size_body2'))
                .fontColor($r('sys.color.ohos_id_color_text_secondary'))
            }
          }
        }
        .alignItems(HorizontalAlign.Start)

        Row() {
          if (this.deliverStatusTitle != undefined) {
            Text(this.deliverStatusTitle)
              .constraintSize({ maxWidth: this.fontSizeScale > 3 ? '100%' : '30%' })
              .margin({ right: $r('app.float.settings_item_status_title_margin_right') })
              .fontWeight(FontWeight.Regular)
              .fontSize($r('sys.float.ohos_id_text_size_body2'))
              .fontColor($r('sys.color.ohos_id_color_text_secondary'))
          }
          SymbolGlyph($r('sys.symbol.chevron_right'))
            .draggable(false)
            .fontColor([$r('sys.color.ohos_id_color_fourth')])
            .fontSize('24vp')
        }
        .justifyContent(FlexAlign.End)
      }

      if (this.showBottomDivider) {
        Divider()
          .vertical(false)
          .height($r('app.float.settings_divider_strokeWidth'))
          .color($r('sys.color.ohos_id_color_list_separator'))
          .lineCap(LineCapStyle.Round)
          .offset({ y: 13 })
      }
    }
    .onClick(this.OnClick)
    .accessibilityGroup(true)
    .width('100%')
    .visibility(this.visibilityShow)
    .padding({
      left: 8,
      right: 12,
      top: 13,
      bottom: 13
    })
  }
}

@Component
export struct SettingItemJumpAutoRetrieve {
  @Styles normalStyles(){
    .backgroundColor(Color.Transparent)
  }
  @Styles pressedStyles(){
    .backgroundColor($r('sys.color.ohos_id_color_click_effect'))
    .borderRadius($r('sys.float.corner_radius_level8'))
  }
  @StorageLink('AdvancedSettingsController') mAdvancedSettingsCtrl:
    AdvancedSettingsController = AdvancedSettingsController.getInstance();
  primaryTitle?: string | Resource;
  secondaryTitle ?: string | Resource;
  @Consume statusTitleSec: Resource;
  showBottomDivider ?: boolean = false;
  visibilityShow: Visibility = Visibility.Visible;
  OnClick: (event?: ClickEvent) => void = () => {
  };
  @StorageProp('fontSizeScale') fontSizeScale: number = 1;

  build() {
    Column() {
      Flex({
        justifyContent: FlexAlign.SpaceBetween,
        alignItems: ItemAlign.Center,
        wrap: FlexWrap.Wrap,
        alignContent: FlexAlign.Start
      }) {
        Column(){
          Text(this.primaryTitle)
            .fontWeight(FontWeight.Medium)
            .fontSize($r('sys.float.ohos_id_text_size_body1'))
            .fontColor($r('sys.color.ohos_id_color_text_primary'))
        }

        Row() {
          if (this.statusTitleSec != undefined) {
            Text(this.statusTitleSec)
              .margin({ right: $r('app.float.settings_item_status_title_margin_right') })
              .fontWeight(FontWeight.Regular)
              .fontSize($r('sys.float.ohos_id_text_size_body2'))
              .fontColor($r('sys.color.ohos_id_color_text_secondary'))
          }
          SymbolGlyph($r('sys.symbol.arrowtriangle_down_fill'))
            .width($r('app.float.settings_item_next_image_width'))
            .draggable(false)
            .fontColor([$r('sys.color.ohos_id_color_tertiary')])
            .fontSize('16vp')
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .width(this.fontSizeScale <= 1 ? 'auto' : '100%')
      }

      if (this.showBottomDivider) {
        Divider()
          .height($r('app.float.settings_divider_strokeWidth'))
          .vertical(false)
          .color($r('sys.color.ohos_id_color_list_separator'))
          .lineCap(LineCapStyle.Round)
          .offset({y: 13})
      }
    }
    .onClick(this.OnClick)
    .width('100%')
    .visibility(this.visibilityShow)
    .padding({ left: 8, right: 12, top: 13, bottom: 13 })
    .stateStyles({
      normal: this.normalStyles,
    })
  }
}

@Component
export struct SettingItemJumpSimCardManage {
  @Styles normalStyles(){
    .backgroundColor(Color.Transparent)
  }
  @Styles pressedStyles(){
    .backgroundColor($r('sys.color.ohos_id_color_click_effect'))
    .borderRadius($r('sys.float.corner_radius_level8'))
  }
  @Prop primaryTitle?: string | Resource;
  secondaryTitle ?: string | Resource;
  @Prop @Watch('changeCardstatus') haveSimCard: boolean = MmsPreferences.getInstance().haveSimCardReady();
  showBottomDivider ?: boolean = false;
  visibilityShow: Visibility = Visibility.Visible;
  OnClick: (event?: ClickEvent) => void = () => {
  };

  changeCardstatus(){}

  build() {
    Column() {
      Flex({
        direction: FlexDirection.Row,
        justifyContent: FlexAlign.SpaceBetween,
        alignItems: ItemAlign.Center
      }) {
        Flex({
          direction: FlexDirection.Column,
          justifyContent: FlexAlign.Center,
          alignItems: ItemAlign.Start
        }) {
          Text(this.primaryTitle)
            .fontWeight(FontWeight.Medium)
            .fontSize($r('sys.float.ohos_id_text_size_body1'))
            .fontColor($r('sys.color.ohos_id_color_text_primary'))

          if (this.secondaryTitle != undefined) {
            Text(this.secondaryTitle)
              .margin({ top: $r('app.float.settings_item_title_space') })
              .fontWeight(FontWeight.Regular)
              .fontSize($r('sys.float.ohos_id_text_size_body2'))
              .fontColor($r('sys.color.ohos_id_color_text_secondary'))
          }
        }

        Row() {
          SymbolGlyph($r('sys.symbol.chevron_right'))
            .draggable(false)
            .fontColor([$r('sys.color.ohos_id_color_fourth')])
            .fontSize('24vp')
        }
      }

      if (this.showBottomDivider) {
        Divider()
          .height($r('app.float.settings_divider_strokeWidth'))
          .vertical(false)
          .color($r('sys.color.ohos_id_color_list_separator'))
          .lineCap(LineCapStyle.Round)
          .offset({y: 13})
      }

    }
    .onClick(this.OnClick)
    .stateStyles({
      normal:this.normalStyles,
      pressed:this.pressedStyles
    })
    .padding({ left: 8, right: 8, top: 13, bottom: 13 })
    .width('100%')
    .visibility(this.visibilityShow)


  }
}


@Component
export struct SmsCenterItem {
  @Link primaryTitle:string;
  OnClick: (event?: ClickEvent) => void = () => {
  };

  build() {
    Column() {
      Row() {
        Text(this.primaryTitle)
          .direction(Direction.Ltr)
          .fontWeight(FontWeight.Medium)
          .fontSize($r('sys.float.ohos_id_text_size_body1'))
          .fontFamily('HarmonyHeiTi')
          .fontColor($r('sys.color.ohos_id_color_text_primary'))
        SymbolGlyph($r('sys.symbol.chevron_right'))
          .draggable(false)
          .fontColor([$r('sys.color.ohos_id_color_fourth')])
          .fontSize('24vp')
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .onClick(this.OnClick)
    .padding({ top: 13, bottom: 13 })
    .width('100%')
  }
}


@Component
export struct SettingItemRcsJump {
    primaryTitle?: string | Resource;
    secondaryTitle ?: string | Resource;
    @Consume stateTitle : Resource;
    showBottomDivider ?: boolean = false;
    visibilityShow: Visibility = Visibility.Visible;
    /* 是否置灰 */
    isSetGray ?: boolean = false;
    OnClick: (event?: ClickEvent) => void = () => {};
    @StorageProp('fontSizeScale') fontSizeScale: number = 1;
    @Styles normalStyles(){
      .backgroundColor(Color.Transparent)
    }
    @Styles pressedStyles(){
      .backgroundColor($r('sys.color.ohos_id_color_click_effect'))
      .borderRadius($r('sys.float.corner_radius_level8'))
    }

    build() {
        Column() {
            Flex({
                justifyContent: FlexAlign.SpaceBetween,
                alignItems: ItemAlign.Center,
                wrap: FlexWrap.Wrap,
                alignContent: FlexAlign.Start
            }) {
                Column(){
                  Text(this.primaryTitle)
                    .fontWeight(FontWeight.Medium)
                    .fontSize($r('sys.float.ohos_id_text_size_body1'))
                    .fontColor($r('sys.color.ohos_id_color_text_primary'))

                  if (this.secondaryTitle != undefined) {
                    Text(this.secondaryTitle)
                      .margin({ top: $r('app.float.settings_item_title_space') })
                      .fontWeight(FontWeight.Regular)
                      .fontSize($r('sys.float.ohos_id_text_size_body2'))
                      .fontColor($r('sys.color.ohos_id_color_text_secondary'))
                  }
                }

                Row() {
                    if (this.stateTitle != undefined) {
                        Text(this.stateTitle)
                            .margin({ right: $r('app.float.settings_item_status_title_margin_right') })
                            .fontWeight(FontWeight.Regular)
                            .fontSize($r('sys.float.ohos_id_text_size_body2'))
                            .fontColor($r('sys.color.ohos_id_color_text_secondary'))
                    }
                  SymbolGlyph($r('sys.symbol.chevron_right'))
                    .draggable(false)
                    .fontColor([$r('sys.color.ohos_id_color_fourth')])
                        .fontSize('24vp')
                }
                .justifyContent(FlexAlign.SpaceBetween)
                .width(this.fontSizeScale < 1.75 ? 'auto' : '100%')

            }

            if (this.showBottomDivider) {
                Divider()
                    .height($r('app.float.settings_divider_strokeWidth'))
                    .vertical(false)
                    .color($r('sys.color.ohos_id_color_list_separator'))
                    .lineCap(LineCapStyle.Round)
                    .offset({y: 13})
            }
        }
        .onClick(this.OnClick)
        .width('100%')
        .visibility(this.visibilityShow)
        .padding({ left: 8, right: 8, top: 13, bottom: 13 })
        .stateStyles({
          normal:this.normalStyles,
          pressed:this.pressedStyles
        })
        .opacity(this.isSetGray ? $r('sys.float.interactive_disable') : 1)
    }
}

@Component
export struct SettingItemSmartJump {
  primaryTitle?: string | Resource;
  secondaryTitle ?: string | Resource;
  @Consume smartStatusTitle: Resource;
  showBottomDivider ?: boolean = false;
  visibilityShow: Visibility = Visibility.Visible;
  OnClick: (event?: ClickEvent) => void = () => {};
  @StorageProp('fontSizeScale') fontSizeScale: number = 1;

  @Styles
  normalStyles(){
    .backgroundColor(Color.Transparent)
  }
  @Styles
  pressedStyles(){
    .backgroundColor($r('sys.color.ohos_id_color_click_effect'))
    .borderRadius($r('sys.float.corner_radius_level8'))
  }

  build() {
    Column() {
      Flex({
        justifyContent: FlexAlign.SpaceBetween,
        alignItems: ItemAlign.Center,
        wrap: FlexWrap.Wrap,
        alignContent: FlexAlign.Start
      }) {
        Column() {
          Text(this.primaryTitle)
            .fontWeight(FontWeight.Medium)
            .fontSize($r('sys.float.ohos_id_text_size_body1'))
            .fontColor($r('sys.color.ohos_id_color_text_primary'))

          if (this.secondaryTitle != undefined) {
            Text(this.secondaryTitle)
              .margin({ top: $r('app.float.settings_item_title_space') })
              .fontWeight(FontWeight.Regular)
              .fontSize($r('sys.float.ohos_id_text_size_body2'))
              .fontColor($r('sys.color.ohos_id_color_text_secondary'))
          }
        }

        Row() {
          if (this.smartStatusTitle != undefined) {
            Text(this.smartStatusTitle)
              .margin({ right: $r('app.float.settings_item_status_title_margin_right') })
              .fontWeight(FontWeight.Regular)
              .fontSize($r('sys.float.ohos_id_text_size_body2'))
              .fontColor($r('sys.color.ohos_id_color_text_secondary'))
          }
          SymbolGlyph($r('sys.symbol.chevron_right'))
            .draggable(false)
            .fontColor([$r('sys.color.ohos_id_color_fourth')])
            .fontSize('24vp')
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .width(this.fontSizeScale < 1.75 ? 'auto' : '100%')
      }

      if (this.showBottomDivider) {
        Divider()
          .height($r('app.float.settings_divider_strokeWidth'))
          .vertical(false)
          .color($r('sys.color.ohos_id_color_list_separator'))
          .lineCap(LineCapStyle.Round)
          .offset({y: 13})
      }
    }
    .onClick(this.OnClick)
    .width('100%')
    .visibility(this.visibilityShow)
    .padding({ left: 8, right: 8, top: 13, bottom: 13 })
    .stateStyles({
      normal: this.normalStyles,
      pressed: this.pressedStyles
    })
  }

}

@Component
export struct SettingItemBlockedJump {
  primaryTitle?: string | Resource;
  secondaryTitle ?: string | Resource;
  @Consume harassmentInterceptionStatus: Resource;
  showBottomDivider ?: boolean = false;
  visibilityShow: Visibility = Visibility.Visible;
  OnClick: (event?: ClickEvent) => void = () => {};
  @StorageProp('fontSizeScale') fontSizeScale: number = 1;

  @Styles
  normalStyles(){
    .backgroundColor(Color.Transparent)
  }
  @Styles
  pressedStyles(){
    .backgroundColor($r('sys.color.ohos_id_color_click_effect'))
    .borderRadius($r('sys.float.corner_radius_level8'))
  }

  build() {
    Column() {
      Flex({
        justifyContent: FlexAlign.SpaceBetween,
        alignItems: ItemAlign.Center,
        wrap: FlexWrap.Wrap,
        alignContent: FlexAlign.Start
      }) {
        Column(){
          Text(this.primaryTitle)
            .fontWeight(FontWeight.Medium)
            .fontSize($r('sys.float.ohos_id_text_size_body1'))
            .fontColor($r('sys.color.ohos_id_color_text_primary'))

          if (this.secondaryTitle != undefined) {
            Text(this.secondaryTitle)
              .margin({ top: $r('app.float.settings_item_title_space') })
              .fontWeight(FontWeight.Regular)
              .fontSize($r('sys.float.ohos_id_text_size_body2'))
              .fontColor($r('sys.color.ohos_id_color_text_secondary'))
          }
        }

        Row() {
          if (this.harassmentInterceptionStatus != undefined) {
            Text(this.harassmentInterceptionStatus)
              .margin({ right: $r('app.float.settings_item_status_title_margin_right') })
              .fontWeight(FontWeight.Regular)
              .fontSize($r('sys.float.ohos_id_text_size_body2'))
              .fontColor($r('sys.color.ohos_id_color_text_secondary'))
          }
          SymbolGlyph($r('sys.symbol.chevron_right'))
            .draggable(false)
            .fontColor([$r('sys.color.ohos_id_color_fourth')])
            .fontSize('24vp')
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .width(this.fontSizeScale < 1.45 ? 'auto' : '100%')
      }

      if (this.showBottomDivider) {
        Divider()
          .height($r('app.float.settings_divider_strokeWidth'))
          .vertical(false)
          .color($r('sys.color.ohos_id_color_list_separator'))
          .lineCap(LineCapStyle.Round)
          .offset({y: 13})
      }
    }
    .onClick(this.OnClick)
    .width('100%')
    .visibility(this.visibilityShow)
    .padding({ left: 8, right: 8, top: 13, bottom: 13 })
    .stateStyles({
      normal: this.normalStyles,
      pressed: this.pressedStyles
    })
  }

}