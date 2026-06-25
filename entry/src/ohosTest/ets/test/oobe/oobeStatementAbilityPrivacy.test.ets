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
import { beforeEach, describe, it, MockKit } from '@ohos/hypium';
import OobeStatementAbilityPrivacy from '../../../../main/ets/oobe/OobeStatementAbilityPrivacy';
import HiLog from '../../../../main/ets/utils/HiLog';
import { UIExtensionContentSession } from '@kit.AbilityKit';
import { uiExtensionHost, window } from '@kit.ArkUI';

export default function oobeStatementAbilityPrivacyTest() {
  describe('oobeStatementAbilityPrivacyTest', () => {

    let oobeStatementAbilityPrivacy: OobeStatementAbilityPrivacy;
    const TAG = 'OobeStatementAbilityPrivacy';

    beforeEach(() => {
      oobeStatementAbilityPrivacy = new OobeStatementAbilityPrivacy();
      AppStorage.clear();
    })

    it('oobeStatementAbilityPrivacyTest_onForeground', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.i);
      oobeStatementAbilityPrivacy.onForeground();
      mocker.verify('i', [TAG, `Ability onForeground`]).never();
      mocker.clear(HiLog);
    })

    it('oobeStatementAbilityPrivacyTest_onBackground', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.i);
      oobeStatementAbilityPrivacy.onBackground();
      mocker.verify('i', [TAG, `Ability onBackground`]).never();
      mocker.clear(HiLog);
    })

    it('oobeStatementAbilityPrivacyTest_onDestroy', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.i);
      oobeStatementAbilityPrivacy.onDestroy();
      mocker.verify('i', [TAG, `Ability onDestroy`]).never();
      mocker.clear(HiLog);
    })

    it('oobeStatementAbilityPrivacyTest_setSafeAreaInfo', 0, () => {
      let statusBarHeight: window.AvoidArea = {
        visible: false,
        topRect: {
          left: 0,
          top: 0,
          width: 100,
          height: 100
        },
        leftRect:{
          left: 0,
          top: 0,
          width: 100,
          height: 100
        },
        rightRect: {
          left: 0,
          top: 0,
          width: 100,
          height: 100
        },
        bottomRect: {
          left: 0,
          top: 0,
          width: 100,
          height: 100
        }
      };
      let session: UIExtensionContentSession = {
        getUIExtensionHostWindowProxy: (): uiExtensionHost.UIExtensionHostWindowProxy => {
          return {
            getWindowAvoidArea: (type: window.AvoidAreaType): window.AvoidArea => {
              return statusBarHeight
            }
          } as uiExtensionHost.UIExtensionHostWindowProxy
        }
      } as UIExtensionContentSession;
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.i);
      oobeStatementAbilityPrivacy.setSafeAreaInfo( session);
      mocker.verify('i',[TAG, `setSafeAreaInfo`]).never();
      mocker.clear(HiLog);
    })

    it('oobeStatementAbilityPrivacyTest_onSessionDestroy', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.i);
      oobeStatementAbilityPrivacy.onSessionDestroy({} as UIExtensionContentSession);
      mocker.verify('i', [TAG, `Ability onSessionDestroy`]).never();
      mocker.clear(HiLog);
    })
  })
}