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
import DeviceUtil from '../utils/DeviceUtil';
import common from '../data/commonData';
/**
 * Custom pop-up menu buttons
 */
class menuItemsObj{
    value?: ResourceStr
    action: () => void = () => {}
    enabled: boolean = false
}
@Component
export struct RcsNewMoreMenu {
    @StorageLink('curBp') curBp: string = 'sm'
    @Consume menuItemList:Array<menuItemsObj>;
    private menuImage: Resource = $r('sys.symbol.dot_grid_2x2');
    private placement: Placement = Placement.Bottom;
    private defaultColor: Resource = $r('sys.color.ohos_id_color_dialog_bg');
    private menuText: Resource | null = null;
    private curHeight: Length = 40;
    private curWidth: Length = 40;
    private menuTextColor: Resource = $r('sys.color.ohos_id_color_text_primary');
    @Styles
    buttonNormalStyles(){
        .backgroundColor(Color.Transparent)
    }

    @Styles
    buttonPressedStyles(){
        .backgroundColor( $r('sys.color.ohos_id_color_click_effect'))
        .borderRadius(20)
    }

    @Builder PopupBuilder() {
        Menu() {
            ForEach(this.menuItemList, (item: menuItemsObj, index?: number) => {
                MenuItem({content: item.value})
                    .constraintSize({ minHeight: $r('app.float.id_item_height_mid') })
                    .contentFont({ weight: FontWeight.Medium, size: $r('sys.float.Body_L') })
                    .contentFontColor(item.enabled ? $r('sys.color.ohos_id_color_text_primary') :
                    $r('sys.color.ohos_id_color_text_tertiary'))
                    .onClick(() => {
                        if (item.enabled) {
                            item.action();
                        }
                    })
            }, (item: menuItemsObj) => JSON.stringify(item))
        }.width(this.curBp == common.STR.DEVICE_FLAT_PLATE ? 198 : 224)
    }

    build() {
        Column() {
            Button(){
                SymbolGlyph(this.menuImage)
                    .width('24vp')
                    .height('24vp')
                    .id('settingMoreButton')
                    .fontSize('24vp')
                    .fontColor([$r('sys.color.ohos_id_color_primary')])
            }
            .accessibilityText(getContext(this).resourceManager.getStringSync($r('app.string.more_options_button').id))
            .bindMenu(this.PopupBuilder)
            .width('40vp')
            .height( '40vp')
            .draggable(false)
            .backgroundColor( $r('sys.color.ohos_id_color_button_normal'))
            .type(ButtonType.Circle)
            .stateEffect(false)
            if (this.menuText != null) {
                Text(this.menuText)
                    .fontSize(10)
                    .lineHeight(14)
                    .fontColor(this.menuTextColor)
                    .margin({ top: 3 })
                    .fontSize($r('sys.float.ohos_id_text_size_caption'))
                    .fontWeight(FontWeight.Medium)
                    .fontColor($r('sys.color.ohos_id_color_toolbar_text'))
            }
        }
        .width(this.curWidth)
        .height(this.curHeight)
        .stateStyles({
            normal: this.buttonNormalStyles,
            pressed: this.buttonPressedStyles
        })
    }
}