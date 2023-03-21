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
import MmsBoolean from "../data/MmsBoolean"
/**
 * Options: dual title, 1 switch
 */
@Component
export struct SettingItemSwitch {
    primaryTitle: string | Resource;
    secondaryTitle?: string | Resource;
    @ObjectLink isEnable: MmsBoolean;
    showBottomDivider ?: boolean = false;
    visibilityShow ?: Visibility = Visibility.Visible;
    onChange: (isOn: boolean) => void;

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
                        .height($r("app.float.settings_item_primary_title_height"))
                        .fontWeight(FontWeight.Medium)
                        .fontSize($r("app.float.settings_item_primary_title_font_size"))
                        .fontColor($r("sys.color.ohos_id_color_text_primary"))

                    if (this.secondaryTitle != undefined) {
                        Text(this.secondaryTitle)
                            .height($r("app.float.settings_item_secondary_title_height"))
                            .margin({ top: $r("app.float.settings_item_title_space") })
                            .fontWeight(FontWeight.Regular)
                            .fontSize($r("app.float.settings_item_secondary_title_font_size"))
                            .fontColor($r("sys.color.ohos_id_color_text_tertiary"))
                    }
                }
                .layoutWeight(1)

                Toggle({ type: ToggleType.Switch, isOn: this.isEnable.value })
                    .width($r("app.float.settings_item_switch_width"))
                    .offset({ x: 4, y: 0 })
                    .selectedColor($r("sys.color.ohos_id_color_activated"))
                    .onChange((isOn: boolean) => {
                        if (typeof isOn === "number") {
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
            .layoutWeight(1)

            if (this.showBottomDivider) {
                Divider()
                    .vertical(false)
                    .strokeWidth(1)
                    .color($r("sys.color.ohos_id_color_list_separator"))
                    .lineCap(LineCapStyle.Round)
            }
        }
        .width("100%")
        .height(this.secondaryTitle != undefined ? $r("app.float.settings_item_height_2") :
        $r("app.float.settings_item_height_1"))
        .visibility(this.visibilityShow)
    }
}

/**
 * Setting items: double title, one status, and one next icon
 */
@Component
export struct SettingItemJump {
    primaryTitle: string | Resource;
    secondaryTitle ?: string | Resource;
    @Consume statusTitle : Resource;
    showBottomDivider ?: boolean = false;
    visibilityShow ?: Visibility = Visibility.Visible;
    OnClick: (event?: ClickEvent) => void;

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
                        .height($r("app.float.settings_item_primary_title_height"))
                        .fontWeight(FontWeight.Medium)
                        .fontSize($r("app.float.settings_item_primary_title_font_size"))
                        .fontColor($r("sys.color.ohos_id_color_text_primary"))

                    if (this.secondaryTitle != undefined) {
                        Text(this.secondaryTitle)
                            .height($r("app.float.settings_item_secondary_title_height"))
                            .margin({ top: $r("app.float.settings_item_title_space") })
                            .fontWeight(FontWeight.Regular)
                            .fontSize($r("app.float.settings_item_secondary_title_font_size"))
                            .fontColor($r("sys.color.ohos_id_color_text_tertiary"))
                    }
                }
                .layoutWeight(1)

                Row() {
                    if (this.statusTitle != undefined) {
                        Text(this.statusTitle)
                            .height($r("app.float.settings_item_secondary_title_height"))
                            .margin({ right: $r("app.float.settings_item_status_title_margin_right") })
                            .fontWeight(FontWeight.Regular)
                            .fontSize($r("app.float.settings_item_secondary_title_font_size"))
                            .fontColor($r("sys.color.ohos_id_color_text_secondary"))
                    }

                    Image($rawfile("icon/ic_next.svg"))
                        .width($r("app.float.settings_item_next_image_width"))
                        .height($r("app.float.settings_item_next_image_height"))
                }
            }
            .layoutWeight(1)
            .onClick(this.OnClick)

            if (this.showBottomDivider) {
                Divider()
                    .vertical(false)
                    .strokeWidth(1)
                    .color($r("sys.color.ohos_id_color_list_separator"))
                    .lineCap(LineCapStyle.Round)
            }
        }
        .width("100%")
        .height(this.secondaryTitle != undefined ? $r("app.float.settings_item_height_2") :
        $r("app.float.settings_item_height_1"))
        .visibility(this.visibilityShow)
    }
}