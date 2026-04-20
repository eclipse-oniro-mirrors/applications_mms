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

import HiLog from '../../utils/HiLog';
import { GlobalContext } from '../../MainAbility/GlobalHelper';
import myCommon from '@ohos.app.ability.common';
import LooseObject from '../../data/LooseObject';
import { ConfigurationConstant } from '@kit.AbilityKit';
import DeviceUtil from '../../utils/DeviceUtil';
import { CustomSettingsNavBar } from '../settings/settingsNavBar';
import { AnimationViewModel } from '../settings/NavBarAnimationViewModel';
import { PrivacyUtils } from './PrivacyUtils';

const TAG = 'PrivacyState';
@Builder
export function PrivacyStateLoader(param: LooseObject): void {
    PrivacyState();
}

@Component
export default struct PrivacyState {
  public static readonly VERSION: string = '20240106';
  @LocalStorageProp('fullScreenPadding') fullScreenPadding: Padding | null = null;
  pageInfosSetting: NavPathStack = new NavPathStack();

  @Styles
  normalStyles(){
    .backgroundColor(Color.Transparent)
  }

  @Styles
  pressedStyles(){
    .backgroundColor($r('sys.color.ohos_id_color_click_effect'))
  }

  @State language: string = 'zh_Hans_CN';
  @StorageProp('currentColorMode') @Watch('replaceUrl') currentMode: ConfigurationConstant.ColorMode =
    ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT;
  @State refreshLanguageCount: number = 0;
  @State alwaysDarkMode: boolean = false;
  // 使用 PafPrivacyStatement 组件，需要在@Entry页面中定义 PafWebViewController ，并重写onBackPress，以达到逐个返回网页的效果，而不是一下全部返回多层网页
  // @Provide('Paf.WebViewController') pafController: PafWebViewController = new PafWebViewController();
  private context = (GlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext);
  @State privacyStateUrl: string = this.context.resourceManager.getStringSync($r('app.string.privacy_state_url').id);
  private code: string = 'CN';
  private branchId: string = '500';
  private contentTag: string = 'prilab';
  private contentTagOld: string = 'prilab';
  private protocol: string = 'messaging';
  private prefix: string = '/privacy-statement.htm';
  backPressCallback?: () => boolean;
  // 标记是否应用内部页面(PrivacyIndex对外提供入口调用时为false)调用
  @State isFromInner: boolean = true;
  @State animationViewModel: AnimationViewModel = new AnimationViewModel('50%', 0, 0);
  private privacyPCDir: string = 'pc';
  private privacyCellularTabletDir: string = 'CellularTablet';
  private readonly privacyResourceDir: string = 'resource://rawfile';
  @State localPrivacyUrl: string = '';
  private readonly supportLanguage: Array<string> = ['zh_Hans', 'zh_Hant', 'bo_Tibt', 'ug_Arab', 'en_Latn'];

  destinationBackPress(): boolean {
    HiLog.i(TAG, 'onBackPress')
    // let accessBackward = this.pafController.getWebNode()?.getParams()?.controller?.accessBackward();
    let accessBackward = null;
    HiLog.i(TAG, `onBackPress accessBackward: ${accessBackward}`);
    // if (accessBackward) {
    //   return this.pafController.onBackPress();
    // }
    if (this.backPressCallback) {
      return this.backPressCallback();
    } else {
      this.onBack();
      return true;
    }
  }

  build() {
    NavDestination() {
      // top title
      CustomSettingsNavBar({
        isShowBackBtn: true,
        isShowCloseBtn: this.isFromInner,
        animationViewModel: this.animationViewModel,
        onCancel: () => {
          this.destinationBackPress();
        }
      });
      Column() {
        //协议
        if (DeviceUtil.isPC() || DeviceUtil.isTablet()) {
          // PafPrivacyStatement({
          //   webViewUrl: this.localPrivacyUrl,
          //   isNav: false,
          //   needShowNavigation: false,
          //   hideBackButton: true,
          //   forceDarkAccess: true,
          //   hideTitleBar: true,
          //   autoAvoid: false,
          //   fullPage: false,
          //   customBackgroundColor: Color.Transparent,
          //   navigationEvent: () => {
          //     this.pageInfosSetting.pop()
          //   },
          // })
        } else {
          // PafPrivacyStatement({
          //   webViewUrl: this.privacyStateUrl,
          //   isNav: false,
          //   needShowNavigation: false,
          //   hideBackButton: true,
          //   forceDarkAccess: true,
          //   hideTitleBar: true,
          //   autoAvoid: false,
          //   fullPage: false,
          //   customBackgroundColor: Color.Transparent,
          //   navigationEvent: () => {
          //     this.pageInfosSetting.pop()
          //   },
          // })
        }
      }.layoutWeight(1)
    }
    .onReady((context: NavDestinationContext) => {
      this.pageInfosSetting = context.pathStack;
      if (this.pageInfosSetting.size() == 0) {
        return;
      }
      let routerParams: LooseObject =
        this.pageInfosSetting.getParamByIndex(this.pageInfosSetting.size() - 1) as LooseObject;
      if (routerParams) {
        this.privacyStateUrl = getContext().resourceManager.getStringSync($r('app.string.privacy_state_url').id);
        this.replaceUrl(routerParams);
        this.updateLocalPrivacyUrl();
      }
    })
    .onBackPressed((): boolean => {
      return this.destinationBackPress();
    })
    .onAppear(() => {
      this.animationViewModel.enterAnimation();
    })
    .onWillDisappear(()=> {
      this.animationViewModel.backAnimation();
    })
    .hideTitleBar(true)
    .backgroundColor(DeviceUtil.isPC() || DeviceUtil.isWifiOnlyTablet() ?
    $r('app.color.color_bind_sheet_background_pc') : $r('app.color.color_bind_sheet_background_phone'))

  }

  private getLanguage(): string {
    let locale: string = getContext().resourceManager.getConfigurationSync().locale;
    let language = 'en_Latn_CN'; // 当前不支持的语言统一呈现英文版本
    for (const item of this.supportLanguage) {
      if (locale.startsWith(item)) {
        language = locale;
        break;
      }
    }
    return language;
  }

  replaceUrl(routerParams: LooseObject) {
    this.language = this.getLanguage();
    if (routerParams.contentTag) {
      this.contentTag = routerParams.contentTag;
      this.contentTagOld = routerParams.contentTag
    } else {
      this.contentTag = this.contentTagOld;
    }
    HiLog.w(TAG, '[replaceUrl] currentColorMode: ' + this.currentMode);
    if (Number(this.currentMode) === ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT) {
      this.alwaysDarkMode = false;
    } else {
      this.alwaysDarkMode = true;
    }
    HiLog.i(TAG,
      'replaceUrl contentTag : ' + routerParams.contentTag + ' language : ' + this.language + ' alwaysDarkMode : ' +
      this.alwaysDarkMode);
    let url =
      getContext().resourceManager.getStringSync($r('app.string.privacy_state_url')) + this.protocol + this.prefix;
    url = url + '?code=' + this.code + '&language=' + this.language +
      '&branchid=' + this.branchId + '&contenttag=' + this.contentTag + '&version=' + PrivacyState.VERSION;
    url = url + `${this.alwaysDarkMode ? '&bgmode=black' : ''}`;
    this.privacyStateUrl = url + '&trsp=true';
    this.refreshLanguageCount++;
    this.updateLocalPrivacyUrl()
  }

  updateLocalPrivacyUrl() {
    HiLog.i(TAG, 'updateLocalPrivacyUrl start');
    let localFname = PrivacyUtils.getPrivacyLocalPath(this.currentMode);
    let privacyDir = this.privacyPCDir;
    if (DeviceUtil.isPC() || DeviceUtil.isWifiOnlyTablet()) {
      HiLog.i(TAG, 'updateLocalPrivacyUrl privacyDir is PC or WifiOnly');
      privacyDir = this.privacyPCDir;
    } else {
      HiLog.i(TAG, 'updateLocalPrivacyUrl privacyDir is PrivacyCellular');
      privacyDir = this.privacyCellularTabletDir;
    }
    let LocalPrivacyUrl = `${this.privacyResourceDir}/${privacyDir}/${this.contentTag}/${localFname}`;
    if (this.localPrivacyUrl !== LocalPrivacyUrl) {
      this.localPrivacyUrl = LocalPrivacyUrl;
    }
  }

  onBack() {
      this.pageInfosSetting.pop();
  }
}