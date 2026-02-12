/**
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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
// import {
//   HdsNavigationBackButtonItemOptions,
//   HdsNavigationBadgeIconOptions, HdsNavigationTitleBarOptions, IconType } from '@kit.UIDesignKit';
import { LengthMetrics, SymbolGlyphModifier } from '@kit.ArkUI';
import DeviceUtil from './DeviceUtil';
import LocationUtil from './LocationUtil';

export interface titleBarParams {
  mainTitle?: ResourceStr,
  subTitle?: ResourceStr,
  stackBuilder?: CustomBuilder,
  //subIcon?: HdsNavigationBadgeIconOptions,
  iconType?: number,
  firstName?: string,
  backgroundColor?: ResourceColor,
  isMultipleSelectState?: boolean,
  selectedNumber?: number,
  //menuValue?: HdsNavigationBadgeIconOptions[],
  //bottomBuilder?: BottomBuilderParams,
  start?: LengthMetrics,
  end?: LengthMetrics,
  callback?: Function,
  avoidLayoutSafeArea?: boolean,
  enableComponentSafeArea?: boolean
}

class TitleBarUtil {
  // 是否是平板、PC、折叠机
  public isShowTitle: boolean = (DeviceUtil.isTabletOrPC() || DeviceUtil.isFoldable())

  /**
   * 提取titleBar
   */
  // getTitleBar(params?: titleBarParams): HdsNavigationTitleBarOptions {
  //   let titleBar: HdsNavigationTitleBarOptions = {
  //     style: {
  //       scrollEffectOpts: {
  //         enableScrollEffect: DeviceUtil.isPC() ? false : true
  //       },
  //       originalStyle: {
  //         backgroundStyle: {
  //           backgroundColor: params?.backgroundColor ?? $r('sys.color.ohos_id_color_toolbar_sub_bg'),
  //         }
  //       },
  //       scrollEffectStyle: {
  //         backgroundStyle: {
  //           backgroundColor: params?.backgroundColor ?? $r('sys.color.ohos_id_color_toolbar_sub_bg'),
  //         }
  //       },
  //       blurStrategy: BlurStrategy.DISABLE
  //     },
  //     padding: {
  //       start: params?.start,
  //       end: params?.end
  //     },
  //     avoidLayoutSafeArea: params?.avoidLayoutSafeArea ?? true,
  //     enableComponentSafeArea: params?.enableComponentSafeArea ?? false,
  //     content: {
  //       stackBuilder: params?.stackBuilder,
  //       title: {
  //         mainTitle: this.getMainTitle(params?.mainTitle, params?.isMultipleSelectState, params?.selectedNumber),
  //         subTitle: params?.subTitle ?? ''
  //       },
  //       subIcon: params?.subIcon,
  //       backIcon:{
  //         icon: (params?.isMultipleSelectState || DeviceUtil.isPC() ?
  //           new SymbolGlyphModifier($r('sys.symbol.xmark')) :
  //           new SymbolGlyphModifier($r('sys.symbol.chevron_backward'))).fontSize('24vp')
  //           .fontColor([$r('sys.color.ohos_id_color_primary')]),
  //         action: () => {
  //           if (params?.callback) {
  //             params.callback()
  //           }
  //         },
  //         label: (params?.isMultipleSelectState || DeviceUtil.isPC() ?
  //           $r('app.string.disable') :
  //           $r('app.string.guide_action_text_previous')),
  //       },
  //       bottomBuilder: params?.bottomBuilder,
  //       menu: {
  //         value: !params?.isMultipleSelectState ? params?.menuValue : []
  //       }
  //     }
  //   }
  //   return titleBar
  // }

  /**
   * 获取标题
   */
  getMainTitle(mainTitle?: ResourceStr, isMultipleSelectState?: boolean, selectedNumber?: number): ResourceStr {
    if (!mainTitle) {
      return ''
    }
    if (isMultipleSelectState && selectedNumber != undefined) {
      if (selectedNumber === 0) {
        return $r('app.string.msg_unselected_tip')
      } else {
        return $r('app.plural.msg_selected_tip_new', selectedNumber, LocationUtil.numFormat(selectedNumber));
      }
    }
    return mainTitle
  }
}

export default new TitleBarUtil()
