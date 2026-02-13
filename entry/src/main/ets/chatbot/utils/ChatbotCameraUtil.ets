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
import { router } from '@kit.ArkUI';
import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { abilityAccessCtrl, common, Permissions } from '@kit.AbilityKit';
import bundleManager from '@ohos.bundle.bundleManager';
import { BusinessError } from '@kit.BasicServicesKit';

const APPROVAL: number = 0
const TAG = 'ChatbotCameraUtil';
const permissionsList: Permissions[] = ['ohos.permission.CAMERA']

export default class EntryAbility extends UIAbility {
  // 冷启动场景通过onCreate回调获取码值信息
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    // 从want中获取传入的链接信息。
    // 如传入的url为：https://www.example.com/programs?router=Access
    this.getRouterUri(want);
  }

  // 热启动场景通过onNewWant回调获取码值信息
   onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    // 从want中获取传入的链接信息
    this.getRouterUri(want);
  }

  // 解析扫码结果，跳转相应页面
  private getRouterUri(want: Want) {
    let uri: string | undefined = want?.uri;
    if (uri) {
      // 开发者根据解析的uri跳转至响应页面，例如需要跳转页面为"pages/Access"
      let status: router.RouterState = router.getState();
      if (status && status.name !== 'Access' && uri) {
        // 根据uri参数做业务处理
        router.pushUrl({
          url: 'pages/Access'
        });
      }
    }
  }
}

export async function requestCameraPermissionFromUsers(context: common.UIAbilityContext) {
  let isFinished: boolean = false
  let atManager = abilityAccessCtrl.createAtManager()
  await atManager.requestPermissionsFromUser(context, permissionsList).then((result) => {
    let grantStatus: number[] = result.authResults
    for (let i = 0; i < grantStatus.length; i++) {
      if (grantStatus[i] === APPROVAL) {
        isFinished = true
      } else {
        HiLog.i(TAG, 'User denies providing the permissions')
      }
    }
  }).catch((err: Error) => {
    HiLog.e(TAG, 'request Permissions From User' + err.message)
  })
  return isFinished
}