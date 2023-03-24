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
import DeviceUtil from "../utils/DeviceUtil";

/**
 * Custom pop-up menu buttons
 */
@Component
export struct MoreMenu {
    @StorageLink('curBp') curBp: string = 'sm'
    @Consume menuItems:Array<any>;
    private menuImage: Resource = $rawfile("icon/ic_public_more.svg");
    private placement: Placement = Placement.Bottom;
    private defaultColor: Resource = $r("sys.color.ohos_id_color_dialog_bg");
    private menuText: Resource = null;
    private menuTextColor: Resource = $r("sys.color.ohos_id_color_text_primary");

    @Builder PopupBuilder() {
        Column() {
            List() {
                ForEach(this.menuItems, (item, index) => {
                    ListItem() {
                        Button({ type: ButtonType.Normal, stateEffect: item.enabled }) {
                            Text(item.value)
                                .fontSize(16)
                                .lineHeight(21)
                                .width("100%")
                                .height(48)
                                .padding({ left: 12, right: 12 })
                                .fontWeight(FontWeight.Regular)
                                .fontColor(item.enabled ? $r("sys.color.ohos_id_color_text_primary") :
                                $r("sys.color.ohos_id_color_text_tertiary"))
                        }
                        .width("100%")
                        .height(48)
                        .borderRadius(16)
                        .backgroundColor($r("sys.color.ohos_id_color_foreground_contrary"))
                        .onClick(() => {
                            if (item.enabled) {
                                item.action();
                            }
                        })
                    }
                }, item => JSON.stringify(item))
            }
            .listDirection(Axis.Vertical) // Arrange Direction
            .divider({
                strokeWidth: 0.5,
                color: $r("sys.color.ohos_id_color_list_separator"),
                startMargin: 12,
                endMargin: 12
            }) // Demarcation line between each row
            .edgeEffect(EdgeEffect.Spring) // Slide to Edge Effect
            .chainAnimation(false) // Disable linkage special effects.
        }
        .backgroundColor(this.defaultColor)
        .width(this.curBp == 'lg' ? 186 : 144)
        .borderRadius(16)
        .padding({ top: 4, bottom: 4, left: 4, right: 4 })
    }

    build() {
        Column() {
            Image(this.menuImage)
                .width(24)
                .height(24)
            if (this.menuText != null) {
                Text(this.menuText)
                    .fontSize(10)
                    .lineHeight(14)
                    .fontColor(this.menuTextColor)
                    .margin({ top: 3 })
                    .fontSize($r("sys.float.ohos_id_text_size_caption"))
                    .fontWeight(FontWeight.Medium)
                    .fontColor($r("sys.color.ohos_id_color_toolbar_text"))
            }
        }
        .bindMenu(this.PopupBuilder)
    }
}