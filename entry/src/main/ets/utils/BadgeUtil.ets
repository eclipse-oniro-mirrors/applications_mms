/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
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
import { i18n } from '@kit.LocalizationKit';
import Constant, { FontSizeScale } from '../data/Constant';

export class BadgeUtil {
  public static getBadgePosition(countOfUnread: number, fontSizeScale: number, content: UIContext): Position {
    if (countOfUnread < 1) {
      return {};
    }
    const paddingSize: number = 4;
    const isRTL: boolean = i18n.isRTL(i18n.System.getSystemLanguage());
    if (isRTL) {
      return { x: -paddingSize, y : -paddingSize };
    }
    let xPosition = 0;
    let text = countOfUnread >= 100 ? '99+' : countOfUnread.toString();
    const avatarWidth: number = 40;
    const badgeSize: number =
      fontSizeScale > FontSizeScale.HUGE_2 ? Constant.BADGE_SIZE_MAX : Constant.BADGE_SIZE_NORMAL;
    const badgePaddingSize: number = 6;
    if (text?.length > 1) {
      let textSizeOptions = content.getMeasureUtils().measureTextSize({ textContent: text,
        fontSize: fontSizeScale > FontSizeScale.HUGE_2 ? Constant.BADGE_FONT_MAX : Constant.BADGE_FONT_NORMAL });
      let textSize = px2vp(textSizeOptions.width as number);
      xPosition = avatarWidth + paddingSize - (badgePaddingSize * 2 + Math.round(textSize));
    } else {
      xPosition = avatarWidth + paddingSize - badgeSize;
    }
    return { x: xPosition, y : -paddingSize };
  }

  public static getBadgeStyle(fontSizeScale: number): BadgeStyle {
    return {
      badgeColor: $r('sys.color.ohos_id_color_badge_red'),
      borderColor: $r('sys.color.ohos_id_color_background'),
      borderWidth: 0,
      badgeSize: fontSizeScale > FontSizeScale.HUGE_2 ? Constant.BADGE_SIZE_MAX : Constant.BADGE_SIZE_NORMAL,
      fontSize: fontSizeScale > FontSizeScale.HUGE_2 ? Constant.BADGE_FONT_MAX : Constant.BADGE_FONT_NORMAL
    }
  }
}