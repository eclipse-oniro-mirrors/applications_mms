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
import ServiceExtensionAbility from '@ohos.app.ability.ServiceExtensionAbility';
import Want from '@ohos.app.ability.Want';
import rpc from '@ohos.rpc';
import HiLog from '../../utils/HiLog';
import { GlobalContext } from '../../MainAbility/GlobalHelper';
import MmsContactHandler from './service/MmsContactHandler';

const TAG = 'MmsContactServiceExtAbility';

export default class MmsContactServiceExtAbility extends ServiceExtensionAbility {

  onCreate(want: Want) {
    HiLog.i(TAG, 'MmsContactServiceExtAbility onCreate');
  }

  onRequest(want: Want, startId: number) {
    HiLog.i(TAG, 'MmsContactServiceExtAbility onRequest');
  }

  onConnect(want: Want): rpc.RemoteObject | Promise<rpc.RemoteObject> {
    HiLog.i(TAG, 'MmsContactServiceExtAbility onConnect');
    let mmsContactHandler = new MmsContactHandler('MmsContactHandler', this.context);
    return mmsContactHandler;
  }

  onDisconnect(want: Want) {
    HiLog.i(TAG, 'MmsContactServiceExtAbility onDisconnect');
  }

  onDestroy() {
    HiLog.i(TAG, 'MmsContactServiceExtAbility onDestroy');
  }
}