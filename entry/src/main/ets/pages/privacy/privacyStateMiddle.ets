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
import UIExtensionContentSession from '@ohos.app.ability.UIExtensionContentSession';
import PrivacyStatementOobe from './PrivacyStatementOobe';

const storage: LocalStorage = LocalStorage.getShared();
const TAG = 'PrivacyStateMiddle';

@Entry
@Component
struct PrivacyPage {
  build() {
    Column() {
      PrivacyDefault()
    }
    .width('100%')
    .height('100%')
  }
}

@Component
struct PrivacyDefault {
  @Provide('pathInfos') pathInfos: NavPathStack = new NavPathStack();
  private session: UIExtensionContentSession | undefined = storage.get<UIExtensionContentSession>('session');

  @Builder
  myRouter(name: string) {
    if (name === 'privacyStatementOobe') {
      PrivacyStatementOobe();
    }
  }

  aboutToAppear() {
    this.pathInfos.pushPath({ name: 'privacyStatementOobe' }, false);
  }

  build() {
    Navigation(this.pathInfos)
      .hideTitleBar(true)
      .navDestination(this.myRouter)
      .mode(NavigationMode.Stack)
  }
}