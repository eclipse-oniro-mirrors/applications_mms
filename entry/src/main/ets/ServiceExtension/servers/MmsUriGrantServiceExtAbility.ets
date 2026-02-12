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
import MmsUriGrantHandler from './service/MmsUriGrantHandler';

const TAG = 'MmsUriGrantServiceExtAbility';

export default class MmsUriGrantServiceExtAbility extends ServiceExtensionAbility {
  onCreate(want: Want) {
    HiLog.i(TAG, 'MmsUriGrantServiceExtAbility onCreate');
  }

  onRequest(want: Want, startId: number) {
    HiLog.i(TAG, 'MmsUriGrantServiceExtAbility onRequest');
  }

  onConnect(want: Want): rpc.RemoteObject | Promise<rpc.RemoteObject> {
    HiLog.i(TAG, 'MmsUriGrantServiceExtAbility onConnect');
    let targetBundleName: string = String(want?.parameters?.['ohos.aafwk.param.callerBundleName']);
    let grantHandler = new MmsUriGrantHandler('GrantHandler', targetBundleName);
    return grantHandler;
  }

  onDisconnect(want: Want) {
    HiLog.i(TAG, 'MmsUriGrantServiceExtAbility onDisconnect');
  }

  onDestroy() {
    HiLog.i(TAG, 'MmsUriGrantServiceExtAbility onDestroy');
  }
}