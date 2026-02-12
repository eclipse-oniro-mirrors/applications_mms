/*
 * Copyright (c) 2023-2024 Huawei Device Co., Ltd.
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

import { BusinessError } from '@ohos.base';
import hilog from '@ohos.hilog';
import { KeyCode } from '@ohos.multimodalInput.keyCode';
import resourceManager from '@ohos.resourceManager';

export enum EditableLeftIconType {
  Back,
  Cancel,
}

export declare interface EditableTitleBarMenuItem {
  value: ResourceStr | Resource;
  isEnabled: boolean;
  id: string;
  action?: () => void;
}

export type EditableTitleBarItem = EditableTitleBarMenuItem;

export declare interface EditableTitleBarOptions {
  backgroundColor?: ResourceColor;
  backgroundBlurStyle?: BlurStyle;
  safeAreaTypes?: Array<SafeAreaType>;
  safeAreaEdges?: Array<SafeAreaEdge>;
}

enum ItemType {
  Image,
  Icon,
  LeftIcon,
}

const PUBLIC_CANCEL = $r('sys.media.ohos_ic_public_cancel');

const PUBLIC_OK = $r('sys.media.ohos_ic_public_cancel');

const PUBLIC_BACK = $r('sys.symbol.chevron_backward');

@Component
export struct EditableTitleBar {
  leftIconStyle: EditableLeftIconType = EditableLeftIconType.Back;
  title: ResourceStr = '';
  subtitle?: ResourceStr = '';
  isSaveIconRequired: boolean = true;
  imageItem?: EditableTitleBarItem;
  menuItems: Array<EditableTitleBarMenuItem> | undefined = undefined;
  options: EditableTitleBarOptions = {
    safeAreaTypes: [SafeAreaType.SYSTEM],
    safeAreaEdges: [SafeAreaEdge.TOP],
  };
  onSave?: () => void;
  onCancel?: () => void;
  @State titleMaxWidth: number = 0;
  @State backActive: boolean = false;
  static maxCountOfExtraItems = 3;
  static maxOtherCountOfExtraItems = 2;
  static countOfImageItem = 0;
  static countOfSaveIcon = 0;
  static readonly commonOne = 1;
  static readonly commonZero = 0;
  static readonly noneColor = '#00000000';
  private static readonly totalHeight = getNumberByResource('titlebar_default_height');
  private static readonly leftMargin = getNumberByResource('titlebar_title_margin_left');
  private static readonly rightMargin = getNumberByResource('titlebar_title_margin_right');
  private static readonly titlePadding = getNumberByResource('titlebar_icon_background_space_horizontal');

  build() {
  }
}

@Component
struct EditableTitleBarMenuSection {
  menuItems: Array<EditableTitleBarMenuItem> | undefined = undefined;
  onSave?: () => void;
  isSaveEnabled: boolean = true;

  build() {
  }
}

@Component
export struct ImageMenuItem {
  item: EditableTitleBarMenuItem = {
    value: '',
    isEnabled: true,
    id: ''
  };
  attribute: ItemType = ItemType.Image;
  static readonly imageHotZoneWidth = getNumberByResource('titlebar_icon_background_width');
  static readonly imageHotZoneHeight = getNumberByResource('titlebar_icon_background_height');
  static readonly iconBackgroundSpaceHorizontal = getNumberByResource('titlebar_icon_background_space_horizontal');
  @State isOnFocus: boolean = false;
  @State isOnHover: boolean = false;
  @State isOnClick: boolean = false;

  @Styles focusedStyle() {
    .border({
      radius: $r('sys.float.titlebar_icon_background_shape'),
      width: $r('sys.float.titlebar_icon_background_focus_outline_weight'),
      color: $r('sys.color.titlebar_icon_background_focus_outline_color'),
      style: BorderStyle.Solid,
    })
  }

  @Styles notInFocusedStyle() {
    .border({
      radius: $r('sys.float.titlebar_icon_background_shape'),
      width: EditableTitleBar.commonZero,
    })
  }

  @Styles buttonStateStyles() {
    .stateStyles({
      focused: this.focusedStyle,
      normal: this.notInFocusedStyle,
      pressed: this.notInFocusedStyle,
    })
  }

  @Styles buttonEventStyle() {
    .onFocus(() => {
      if (!this.item.isEnabled) {
        return;
      }
      this.isOnFocus = true;
    })
    .onBlur(() => this.isOnFocus = false)
    .onHover((isOn) => {
      if (!this.item.isEnabled) {
        return;
      }
      this.isOnHover = isOn;
    })
    .onKeyEvent((event) => {
      if (!this.item.isEnabled) {
        return;
      }
      if (event.keyCode !== KeyCode.KEYCODE_ENTER && event.keyCode !== KeyCode.KEYCODE_SPACE) {
        return;
      }
      if (event.type === KeyType.Down) {
        this.isOnClick = true;
      }
      if (event.type === KeyType.Up) {
        this.isOnClick = false;
      }
    })
    .onTouch((event) => {
      if (!this.item.isEnabled) {
        return;
      }
      if (event.type === TouchType.Down) {
        this.isOnClick = true;
      }
      if (event.type === TouchType.Up) {
        this.isOnClick = false;
      }
    })
  }

  @Styles backgroundButtonStyle() {
    .width(ImageMenuItem.imageHotZoneWidth)
    .height(ImageMenuItem.imageHotZoneHeight)
    .focusable(this.item.isEnabled)
    .enabled(this.item.isEnabled)
  }

  getFgColor(): ResourceStr {
    if (this.isOnClick) {
      return $r('sys.color.titlebar_icon_background_pressed_color');
    } else if (this.isOnHover) {
      return $r('sys.color.titlebar_icon_background_hover_color');
    } else {
      return EditableTitleBar.noneColor;
    }
  }

  @Builder
  IconBuilder(): void {
    Button({ type: ButtonType.Normal, stateEffect: this.item.isEnabled }) {
      SymbolGlyph(this.item.value as Resource)
        .width($r('sys.float.titlebar_icon_width'))
        .height($r('sys.float.titlebar_icon_height'))
        .fontSize('24vp')
        .fontColor([$r('sys.color.titlebar_icon_color')])
        .focusable(this.item.isEnabled)
        .enabled(this.item.isEnabled)
        .draggable(false)
        .id(this.item.id)
    }
    .backgroundButtonStyle()
    .borderRadius($r('sys.float.titlebar_icon_background_shape'))
    .foregroundColor(this.getFgColor())
    .backgroundColor($r('sys.color.titlebar_icon_background_color'))
    .buttonStateStyles()
    .buttonEventStyle()
    .id(this.item.id)
  }

  @Builder
  ImageBuilder() {
    Stack({ alignContent: Alignment.Center }) {
      Image(this.item.value)
        .width(ImageMenuItem.imageHotZoneWidth)
        .height(ImageMenuItem.imageHotZoneHeight)
        .borderRadius($r('sys.float.corner_radius_level10'))
        .focusable(false)
        .enabled(this.item.isEnabled)
        .objectFit(ImageFit.Cover)
        .id(this.item.id)

      Button({ type: ButtonType.Circle })
        .backgroundButtonStyle()
        .foregroundColor(this.getFgColor())
        .backgroundColor(EditableTitleBar.noneColor)
        .buttonStateStyles()
        .buttonEventStyle()
        .id(this.item.id)
    }
    .margin({
      left: ImageMenuItem.iconBackgroundSpaceHorizontal,
    })
  }

  build() {
    this.IconBuilder();
  }
}

/**
 * get resource size
 *
 * @param resourceName resource name
 * @return resource size
 */
function getNumberByResource(resourceName: string): number {
  try {
    return resourceManager.getSystemResourceManager().getNumberByName(resourceName);
  } catch (error) {
    let code: number = (error as BusinessError).code;
    let message: string = (error as BusinessError).message;
    hilog.error(0x3900, 'Ace', `EditableTitleBar getNumberByResource error, code: ${code},message:${message}`);
    return EditableTitleBar.commonZero;
  }
}