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
import common from '../data/commonData';
import lazy { ImageMenuItem } from './editableTitleBar';
import ConversationController from '../pages/conversation/conversationController';
import HiLog from '../utils/HiLog';
import DeviceUtil from '../utils/DeviceUtil';
import { LengthMetrics } from '@kit.ArkUI';

@Extend(MenuItem)
function menuItemStyle(item: menuItemsObj, isPC: boolean) {
    .constraintSize({ minHeight: isPC ? $r('app.float.id_card_image_mid') : $r('app.float.id_item_height_mid') })
    .contentFont({ weight: FontWeight.Medium, size: $r('sys.float.Body_L') })
    .contentFontColor(item.enabled ? $r('sys.color.ohos_id_color_text_primary') :
    $r('sys.color.ohos_id_color_text_tertiary'))
    .onClick(() => {
        if (item.enabled) {
            item.action();
        }
    })
    .align(Alignment.Center)
}

const TAG = 'RcsMoreMenu ';
/**
 * Custom pop-up menu buttons
 */
class menuItemsObj {
    public value?: ResourceStr
    public action: () => void = () => {
    }
    public enabled: boolean = false
    public visible: boolean = true
}

@Component
export struct RcsMoreMenu {
    @StorageLink('curBp') curBp: string = 'sm'
    @Consume menuItems: Array<menuItemsObj>;
    private menuImage: Resource = $r('sys.symbol.dot_grid_2x2');
    private placement: Placement = Placement.Bottom;
    private menuText: Resource | null = null;
    private curHeight: Length = 40;
    private curWidth: Length = 40;
    @State mConversationCtrl: ConversationController = ConversationController.getInstance();
    private isPC: boolean = DeviceUtil.isPC();

    @Styles
    normalStylesOfBack(){
        .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
    }

    @Styles
    pressedStylesOfBack(){
        .backgroundColor($r('sys.color.ohos_id_color_click_effect'))
        .borderRadius($r('sys.float.ohos_id_corner_radius_clicked'))
    }

    @Styles
    buttonNormalStyles(){
        .backgroundColor(Color.Transparent)
    }

    @Styles
    buttonPressedStyles(){
        .backgroundColor($r('sys.color.ohos_id_color_click_effect'))
        .borderRadius($r('sys.float.ohos_id_corner_radius_default_m'))
    }

    private getVisibleMenuItems() {
        return this.menuItems.filter((item) => {
            return item.visible
        });
    }

    resourceToString(item: menuItemsObj) {
        if (typeof (item) === 'string') {
            return item
        } else {
            return item.value as Resource
        }
    }

    getItemAccessibilityText(item: menuItemsObj): string {
        try {
            return getContext(this).resourceManager.getStringSync(this.resourceToString(item)?.id)
        } catch (err) {
            HiLog.e(TAG, `getItemAccessibilityText error: code: ${err.code}, message: ${err.message} `);
            return '';
        }
    }

    @Builder
    showPCMenuItem(value: ResourceStr) {
        Text(value)
            .fontSize($r('sys.float.Body_L'))
            .fontWeight(FontWeight.Medium)
            .textAlign(TextAlign.Start)
            .padding({ start: LengthMetrics.vp(12) })
            .width('100%')
    }

    @Builder
    PopupBuilder() {
        Menu() {
            ForEach(this.getVisibleMenuItems(), (item: menuItemsObj, index?: number) => {
                if (index !== 0 && !this.isPC) {
                    this.multDivider()
                }
                if (index !== 0 && this.isPC) {
                    this.pcMultDivider()
                }
                if (this.isPC) {
                    MenuItem(this.showPCMenuItem(item.value as Resource))
                        .menuItemStyle(item, this.isPC)
                        .accessibilityText(this.getItemAccessibilityText(item))
                        .padding({ top: 8, bottom: 8 })
                } else {
                    MenuItem({ content: item.value })
                        .menuItemStyle(item, this.isPC)
                        .accessibilityText(this.getItemAccessibilityText(item))
                }
            }, (item: menuItemsObj) => JSON.stringify(item))
        }
        .align(Alignment.Center)
        .width(this.curBp == common.STR.DEVICE_FLAT_PLATE ? 198 : 224)
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
                if (this.isPC) {
                    SymbolGlyph(this.menuImage)
                        .width($r('sys.float.titlebar_icon_width'))
                        .height($r('sys.float.titlebar_icon_height'))
                        .fontSize('24vp')
                        .fontColor([$r('sys.color.titlebar_icon_color')])
                        .focusable(true)
                        .enabled(true)
                        .draggable(false)
                        .id('conversationMoreButton')
                } else {
                    ImageMenuItem({
                        item: {
                            value: this.menuImage,
                            isEnabled: true,
                            id: 'conversationMoreButton'
                        }
                    })
                }
                if (this.menuText != null) {
                    Text(this.menuText)
                        .fontSize(10)
                        .lineHeight(14)
                        .fontColor($r('sys.color.ohos_id_color_text_primary'))
                        .margin({ top: 3 })
                        .fontSize($r('sys.float.ohos_id_text_size_caption'))
                        .fontWeight(FontWeight.Medium)
                        .fontColor($r('sys.color.ohos_id_color_toolbar_text'))
                }
            }
            .width(this.curWidth)
            .height(this.curHeight)
            .alignItems(HorizontalAlign.Center)
            .justifyContent(FlexAlign.Center)
            .borderRadius(20)
        }
        .accessibilityText(getContext(this).resourceManager.getStringSync($r('app.string.more_options_button').id))
        .bindMenu(this.PopupBuilder, { placement: DeviceUtil.isPC() ? Placement.BottomRight : undefined })
        .width(this.curWidth)
        .height(this.curHeight)
        .align(Alignment.Center)
        .buttonStyle(ButtonStyleMode.TEXTUAL)
        .borderRadius(20)
    }
}