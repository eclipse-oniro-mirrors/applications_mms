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
import HiLog from '../../utils/HiLog';
import PrivacyState from './PrivacyState';
import { GlobalContext } from '../../MainAbility/GlobalHelper';
import myCommon from '@ohos.app.ability.common';
import { ability, common, UIExtensionContentSession, ConfigurationConstant } from '@kit.AbilityKit';
import { sim } from '@kit.TelephonyKit';
import DeviceUtil from '../../utils/DeviceUtil';
import { PrivacyUtils } from './PrivacyUtils';

const TAG = 'PrivacyIndex';
const PRIVACY_PC_DIR: string = 'pc';
const PRIVACY_CELLULAR_TABLE_DIR: string = 'CellularTablet';
const PRIVACY_RESOURCE_DIR: string = 'resource://rawfile';

@Entry
@Component
struct PrivacyIndex {

  @StorageProp('currentColorMode') @Watch('replaceUrl') currentMode: number = 0;
  @StorageProp('currentLanguage') @Watch('replaceUrl') currentLanguage: string = 'zh_Hans_CN';
  // @Provide('Paf.WebViewController') pafController: PafWebViewController = new PafWebViewController();
  private context = (GlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext);
  @State privacyStateUrl: string = this.context.resourceManager.getStringSync($r('app.string.privacy_state_url').id);
  private code: string = 'CN';
  private branchId: string = '500';
  private contentTag: string = 'prilab';
  private protocol: string = 'messaging';
  private prefix: string = '/privacy-statement.htm';

  aboutToAppear(): void {
    HiLog.i(TAG, 'aboutToAppear.');
    this.replaceUrl();
  }

  aboutToDisappear(): void {
    HiLog.i(TAG, 'aboutToDisappear.');
    AppStorage.delete('currentColorMode.');
    AppStorage.delete('currentLanguage.');
  }

  replaceUrl() {
    HiLog.w(TAG, `[replaceUrl] currentColorMode: ${this.currentMode}`);
    if (DeviceUtil.isPC()) {
      this.setPcPrivacyUrl();
    } else if (DeviceUtil.isTablet()) {
      this.setTabletPrivacyUrl();
    } else {
      this.setPhonePrivacyUrl();
    }
    // 进入隐私页面记录当前匹配的隐私文件路径，关键日志，不会频繁打印
    HiLog.w(TAG, `[replaceUrl] currentColorMode: ${this.privacyStateUrl}`);
  }

  setPcPrivacyUrl() {
    let localFname = PrivacyUtils.getPrivacyLocalPath(this.currentMode);
    this.privacyStateUrl = `${PRIVACY_RESOURCE_DIR}/${PRIVACY_PC_DIR}/${this.contentTag}/${localFname}`;
  }

  setTabletPrivacyUrl() {
    let privacyDir = PRIVACY_CELLULAR_TABLE_DIR;
    if ( DeviceUtil.isWifiOnlyTablet()) {
      privacyDir = PRIVACY_PC_DIR;
    }
    let localFname = PrivacyUtils.getPrivacyLocalPath(this.currentMode);
    this.privacyStateUrl = `${PRIVACY_RESOURCE_DIR}/${privacyDir}/${this.contentTag}/${localFname}`;
  }

  setPhonePrivacyUrl() {
    let url = getContext().resourceManager.getStringSync($r('app.string.privacy_state_url'));
    let bgmode = this.currentMode ? 'white' : 'dark';
    this.privacyStateUrl = `${url}${this.protocol}${this.prefix}?code=${this.code}&language=${this.currentLanguage}`+
      `&branchid=${this.branchId}&contenttag=${this.contentTag}&version=${PrivacyState.VERSION}&bgmode=${bgmode}`+
      `&trsp=true`;
  }

  build() {
    Navigation() {
      Column() {
        Row() {
          // PafPrivacyStatement({
          //   webViewUrl: this.privacyStateUrl,
          //   isNav: true,
          //   fullPage: false,
          //   needShowNavigation: false,
          //   hideTitleBar: true,
          //   navigationEvent: () => {
          //     this.onBack();
          //   },
          // })
        }
        .layoutWeight(1)
      }
    }
    .titleMode(NavigationTitleMode.Mini)
    .mode(NavigationMode.Stack)
  }

  onBackPress(): void | boolean {
    HiLog.i(TAG, 'onBackPress.');
    // return this.pafController.onBackPress();
  }

  onBack(): void {
    this.terminateSelfWithResult();
  }

  terminateSelfWithResult(): void {
    let session: UIExtensionContentSession = LocalStorage.getShared()
      .get<UIExtensionContentSession>('session') as UIExtensionContentSession;
    let result: ability.AbilityResult = {
      'resultCode': 0
    };
    session?.terminateSelfWithResult(result).then((data) => {
      HiLog.i(TAG, 'terminateSelfCallBack');
    });
  }
}