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
  value: ResourceStr;
  isEnabled: boolean;
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

  build() {
  }
}

@Component
export struct ImageMenuItem {
  item: EditableTitleBarMenuItem = {
    value: '',
    isEnabled: true,
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
      radius: 24,
      width: 48,
      color: 48,
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

  // instrument ignore next
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
    .onClick(() => this.item.isEnabled && this.item.action && this.item.action())
  }

  @Styles backgroundButtonStyle() {
    .width(48)
    .height(48)
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
  CancelBuilder(): void {
    Button({ type: ButtonType.Circle, stateEffect: this.item.isEnabled }) {
      Image(this.item.value)
        .width(24)
        .height(24)
        .fillColor('#DBFFFFFF')
        .focusable(this.item.isEnabled)
        .enabled(this.item.isEnabled)
    }
    .backgroundButtonStyle()
    .foregroundColor(this.getFgColor())
    .backgroundColor('#33FFFFFF')
    .buttonStateStyles()
    .buttonEventStyle()
  }

  build() {
    this.CancelBuilder();
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