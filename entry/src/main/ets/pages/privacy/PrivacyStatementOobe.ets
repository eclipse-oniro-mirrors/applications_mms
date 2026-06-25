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
import web_webview from '@ohos.web.webview';
import HiLog from '../../utils/HiLog';
import { UIExtensionContentSession } from '@kit.AbilityKit';

const storage: LocalStorage = LocalStorage.getShared();
const TAG = 'PrivacyStatementOobe';

@Component
export default struct PrivacyStatementOobe {
  private readonly session: UIExtensionContentSession | undefined = storage.get<UIExtensionContentSession>('session');
  controller: web_webview.WebviewController = new web_webview.WebviewController();
  @State mode: WebDarkMode = WebDarkMode.Auto;
  @State access: boolean = true;
  @State infoTitle: string = '';
  @State language: string = '';
  @State fileDir: string = '';

  aboutToAppear() {
    HiLog.i(TAG, 'aboutToAppear');
    this.language = getContext().resourceManager.getConfigurationSync().locale;
    HiLog.i(this.language, 'language my select is:');
    if (this.language.startsWith('zh_Hans')) {
      this.infoTitle = 'privacy-statement-zh-cn.htm';
    } else if (this.language.startsWith('zh_Hant')) {
      if (this.language == 'zh_Hant_TW') {
        this.infoTitle = 'privacy-statement-zh-tw.htm';
      } else {
        this.infoTitle = 'privacy-statement-zh-hk.htm';
      }
    } else if (this.language.startsWith('bo_Tibt')) {
      this.infoTitle = 'privacy-statement-bo-cn.htm';
    } else if (this.language.startsWith('ug_Arab')) {
      this.infoTitle = 'privacy-statement-ug-cn.htm';
    } else {
      this.infoTitle = 'privacy-statement-en-us.htm';
    }
  }

  build() {
    NavDestination() {
      Column() {
        Web({
          src: $rawfile(this.infoTitle),
          controller: this.controller
        })
          .width('100%')
          .height('100%')
          .backgroundColor($r('sys.color.ohos_id_color_card_bg'))
          .zoomAccess(false)
      }
      .padding({ top: 64 })
      .width('100%')
      .height('100%')
    }
    .hideTitleBar(true)
    .width('100%')
    .height('100%')
    .backgroundColor($r('sys.color.ohos_id_color_card_bg'))
    .onBackPressed(() => {
      if (this.controller?.accessBackward()) {
        this.controller.backward();
      }
      this.session?.terminateSelf();
      return true;
    })
    .padding({})
  }
}