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
import HiLog from '../utils/HiLog';
import Want from '@ohos.app.ability.Want';
import UIExtensionAbility from '@ohos.app.ability.UIExtensionAbility';
import UIExtensionContentSession from '@ohos.app.ability.UIExtensionContentSession';
import LooseObject from '../data/LooseObject';
import { GlobalContext } from '../MainAbility/GlobalHelper';
import SharedPreferencesUtils from '../utils/SharedPreferencesUtils';

const TAG = 'BlockedListExtAbility';

export default class BlockedListExtAbility extends UIExtensionAbility {

  onCreate() {
    HiLog.i(TAG, 'BlockedListExtAbility onCreate');
  }

  onSessionCreate(want: Want, session: UIExtensionContentSession) {
    HiLog.i(TAG, 'BlockedListExtAbility onSessionCreate');
    let storageParamObj: LooseObject = {
      'uiExtensionSession': session
    };

    GlobalContext.getContext().setObject('mmsContext', this.context);
    let storage: LocalStorage = new LocalStorage(storageParamObj);
    HiLog.i(TAG, 'load Mms BlockedList ');
    session.loadContent('pages/blocked/blockedList/blockedList', storage);
  }

  onSessionDestroy(session: UIExtensionContentSession) {
    HiLog.i(TAG, 'BlockedListExtAbility onSessionDestroy');
  }

  onForeground() {
    HiLog.i(TAG, 'BlockedListExtAbility onForeground');
  }

  onBackground() {
    HiLog.i(TAG, 'BlockedListExtAbility onBackground');
  }

  onDestroy() {
    // 骚扰拦截列表页面是否在前台显示值在ability 销毁时兜底置为false.防止一直为true收不到骚扰拦截信息通知
    SharedPreferencesUtils.saveToPreferences('blockedNotificationIsShow', false);
    HiLog.i(TAG, 'BlockedListExtAbility onDestroy');
  }

}