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
import AbilityStage from '@ohos.app.ability.UIAbility';
import HiLog from '../utils/HiLog';
import { SystemMode } from '../utils/SystemMode';
import type { Configuration } from '@ohos.app.ability.Configuration';

const TAG = 'MyAbilityStage';

export default class MyAbilityStage extends AbilityStage {
  onCreate(): void {
    HiLog.i(TAG, 'AbilityStage onCreate');
    // 获取系统模式
    SystemMode.getInstance().getSystemMode();
  }

  // Environment change notification interface,which is called back when global configuration changes.
  onConfigurationUpdate(newConfig: Configuration): void {
    HiLog.w(TAG, '[onConfigurationUpdate] currentColorMode: ' + newConfig.colorMode);
    AppStorage.setOrCreate('currentColorMode', newConfig.colorMode);
  }
}