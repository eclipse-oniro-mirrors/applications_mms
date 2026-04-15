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
import Ability from '@ohos.app.ability.UIAbility';
import Window from '@ohos.window';
import HiLog from '../utils/HiLog';
import Want from '@ohos.app.ability.Want';
import AbilityConstant from '@ohos.app.ability.AbilityConstant';
import { BusinessError } from '@ohos.base';
import { Configuration } from '@ohos.app.ability.Configuration';
//import { pushCommon, pushService } from '@kit.PushKit';
import LooseObject from '../data/LooseObject';

const TAG = 'PushMessageAbility';

export default class PushMessageAbility extends Ability {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    HiLog.i(TAG, 'Ability onCreate com.ohos.mms');
    // SmartMmsClient.init(null, null, this.context);
    this.receiveMessage()
  }

  receiveMessage() {
    try {
      // pushService.receiveMessage('BACKGROUND', this, (payload: pushCommon.PushPayload) => {
      //   HiLog.w(TAG, '[receiveMessage] success');
      //   try {
      //     const payloadData: LooseObject = JSON.parse(payload?.data) ?? {}
      //     // IpProcessorApi.parseIpMsg(this.context, payloadData.data)
      //   } catch (e) {
      //     let errRes: BusinessError = e as BusinessError;
      //     HiLog.e(TAG, `[receiveMessage] deal msg failed: ${errRes.code} ${errRes.message}`);
      //   }
      // });
    } catch (err) {
      let e: BusinessError = err as BusinessError;
      HiLog.e(TAG, `[receiveMessage] Get msg failed: ${e.code} ${e.message}`);
    }
  }

  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    HiLog.i(TAG, 'Application onNewWant');
  }

  onWindowStageCreate(windowStage: Window.WindowStage): void {
    HiLog.i(TAG, 'Ability onWindowStageCreate');
  }

  onConfigurationUpdate(newConfig: Configuration): void {
    HiLog.w(TAG, '[Ability onConfigurationUpdate] colorMode : ' + newConfig.colorMode);
  }

  onWindowStageDestroy(): void {
    HiLog.i(TAG, 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    HiLog.i(TAG, 'Ability onForeground');
  }

  onBackground(): void {
    HiLog.i(TAG, 'Ability onBackground');
  }

  onDestroy(): void {
    HiLog.i(TAG, 'Ability onDestroy');
  }

  onBackPressed(): boolean {
    HiLog.i(TAG, 'onBackPresssd start!')
    return true
  }
}