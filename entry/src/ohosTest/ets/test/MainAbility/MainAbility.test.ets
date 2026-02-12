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
import { ArgumentMatchers, beforeEach, describe, expect, it, MockKit, when } from '@ohos/hypium';
import MainAbility, { SetOrCreateParams } from '../../../../main/ets/MainAbility/MainAbility';
import { GlobalContext, pxs2vps } from '../../../../main/ets/MainAbility/GlobalHelper';
import { AbilityConstant, Want } from '@kit.AbilityKit';
import myCommon from '@ohos.app.ability.common';
import WantUtil from '../../../../main/ets/utils/WantUtil';
import Window from '@ohos.window';
import { AsyncCallback, BusinessError } from '@kit.BasicServicesKit';
import HiLog from '../../../../main/ets/utils/HiLog';
import { Configuration } from '@ohos.app.ability.Configuration';
import { MmsWindowsManager } from '../../../../main/ets/utils/WindowsManager';
import DeviceUtil from '../../../../main/ets/utils/DeviceUtil';
import simCardService from '../../../../main/ets/service/SimCardService';
import RcsDataPreferences from '../../../../main/ets/utils/RcsDataPreferences';
import SharedPreferencesUtils from '../../../../main/ets/utils/SharedPreferencesUtils';
import DataShareHelper from '../../../../main/ets/model/repository/DataShareHelper';
import MmsPreferences from '../../../../main/ets/utils/MmsPreferences';
import OperatorConfigUtil from '../../../../main/cust/utils/OperatorConfigUtil';
import WorkFactory from '../../../../main/ets/workers/WorkFactory';
import mmsUitlCtr from '../../../../main/ets/utils/MmsUtil';
import { AudioPlayerService } from '../../../../main/ets/service/AudioPlayerService';
import { dataShare } from '@kit.ArkData';
import { DTGlobalContext } from '../../testability/TestAbility';

export default function mainAbilityTest() {
  describe('mainAbilityTest', () => {

    const TAG = 'app';
    let mainAbility: MainAbility;

    beforeEach(() => {
      mainAbility = new MainAbility();
      AppStorage.clear();
    })

    it('MainAbilityTest_onCreate', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(RcsDataPreferences.getInstance(), RcsDataPreferences.getInstance().loadRcsInfoPreferences);
      mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().setObject);
      mocker.mockFunc(WorkFactory, WorkFactory.getWorker);
      mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.saveToPreferences);
      mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.init);
      let helper: Promise<dataShare.DataShareHelper | undefined> =
        new Promise<dataShare.DataShareHelper | undefined>(resolve => resolve({} as dataShare.DataShareHelper));
      when(mocker.mockFunc(DataShareHelper.getInstance(),
        DataShareHelper.getInstance().initSmsDB))(ArgumentMatchers.any)
        .afterReturn(helper);

      mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initContactDB);
      mocker.mockFunc(MmsPreferences.getInstance(), MmsPreferences.getInstance().initPreferences);
      mocker.mockFunc(OperatorConfigUtil.getInstance(), OperatorConfigUtil.getInstance().initOperatorConfig);
      mocker.mockFunc(mmsUitlCtr, mmsUitlCtr.checkAdvancedMode);

      mocker.mockFunc(mainAbility, mainAbility.enableSuggestCache);
      mocker.mockFunc(mainAbility, mainAbility.delayOnCreateWorker);

      mainAbility.onCreate({} as Want, {} as AbilityConstant.LaunchParam);

      expect(JSON.stringify(AppStorage.get(AudioPlayerService.AUDIO_FILE_PLAY_STATE)))
        .assertEqual(JSON.stringify(new Map()));

      mocker.clear(RcsDataPreferences.getInstance());
      mocker.clear(GlobalContext.getContext());
      mocker.clear(WorkFactory);
      mocker.clear(mainAbility);
      mocker.clear(SharedPreferencesUtils);
      mocker.clear(DataShareHelper.getInstance());
      mocker.clear(MmsPreferences.getInstance());
      mocker.clear(OperatorConfigUtil.getInstance());
      mocker.clear(mmsUitlCtr);
    })

    it('MainAbilityTest_onNewWant', 0, () => {
      let want: Want = {};
      let launchParam: AbilityConstant.LaunchParam = {
        launchReason: 0,
        lastExitReason: 0,
        lastExitMessage: ''
      };
      let pageInfos: NavPathStack = new NavPathStack();

      let mocker: MockKit = new MockKit();
      mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().setObject);
      mocker.mockFunc(WantUtil, WantUtil.getWant);

      AppStorage.setOrCreate('pageInfos', pageInfos);

      mainAbility.onNewWant(want, launchParam);

      mocker.verify('getWant', [pageInfos]).never();

      mocker.clear(GlobalContext.getContext());
      mocker.clear(WantUtil);
    })

    it('MainAbilityTest_updateWindow_TYPE_SYSTEM', 0, async () => {
      let windowObj: Window.Window = {
        getWindowProperties: (): Window.WindowProperties => {
          return {
            windowRect: {
              width: 100,
              height: 100
            }
          } as Window.WindowProperties
        },
        getWindowAvoidArea: (type: Window.AvoidAreaType): Window.AvoidArea => {
          return {
            topRect: {
              height: 100
            },
            bottomRect: {
              height: 100
            }
          } as Window.AvoidArea;
        },
        on: (type: "avoidAreaChange", callback: Callback<Window.AvoidAreaOptions>): void => {
          callback({
            type: Window.AvoidAreaType.TYPE_SYSTEM,
            area: {
              topRect: {
                height: 100
              },
              bottomRect: {
                height: 100
              }
            }
          } as Window.AvoidAreaOptions);
        }
      } as Window.Window;

      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(MainAbility, pxs2vps))(ArgumentMatchers.any)
        .afterReturn(new Promise<number[]>(resolve => resolve([1, 2, 3, 4])));

      mocker.mockFunc(mainAbility, mainAbility.handleWindowSizeChange);
      mocker.mockFunc(mainAbility, mainAbility.updateWindowHeight);
      mocker.mockFunc(mainAbility, mainAbility.handleAvoidAreaChange);
      mocker.mockFunc(MmsWindowsManager.getInstance(), MmsWindowsManager.getInstance().initForPhone);

      mocker.mockFunc(HiLog, HiLog.i);


      await mainAbility.updateWindow(windowObj);

      expect(AppStorage.get('bottomAvoidHeight')).assertEqual(100);

      mocker.clear(MainAbility);
      mocker.clear(mainAbility);
      mocker.clear(MmsWindowsManager.getInstance());
      mocker.clear(HiLog);
    })

    it('MainAbilityTest_updateWindow_TYPE_NAVIGATION_INDICATOR', 0, async () => {
      let windowObj: Window.Window = {
        getWindowProperties: (): Window.WindowProperties => {
          return {
            windowRect: {
              width: 100,
              height: 100
            }
          } as Window.WindowProperties
        },
        getWindowAvoidArea: (type: Window.AvoidAreaType): Window.AvoidArea => {
          return {
            topRect: {
              height: 100
            },
            bottomRect: {
              height: 100
            }
          } as Window.AvoidArea;
        },
        on: (type: "avoidAreaChange", callback: Callback<Window.AvoidAreaOptions>): void => {
          callback({
            type: Window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR,
            area: {
              topRect: {
                height: 100
              },
              bottomRect: {
                height: 100
              }
            }
          } as Window.AvoidAreaOptions);
        }
      } as Window.Window;

      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(MainAbility, pxs2vps))(ArgumentMatchers.any)
        .afterReturn(new Promise<number[]>(resolve => resolve([1, 2, 3, 4])));

      mocker.mockFunc(mainAbility, mainAbility.handleWindowSizeChange);
      mocker.mockFunc(mainAbility, mainAbility.updateWindowHeight);
      mocker.mockFunc(mainAbility, mainAbility.handleAvoidAreaChange);
      mocker.mockFunc(MmsWindowsManager.getInstance(), MmsWindowsManager.getInstance().initForPhone);

      mocker.mockFunc(HiLog, HiLog.i);


      await mainAbility.updateWindow(windowObj);

      expect(AppStorage.get('bottomAvoidHeight')).assertEqual(100);

      mocker.clear(MainAbility);
      mocker.clear(mainAbility);
      mocker.clear(MmsWindowsManager.getInstance());
      mocker.clear(HiLog);
    })

    it('MainAbilityTest_updateWindow_catch', 0, async () => {
      let exception: Error = new Error('error');
      let windowObj: Window.Window = {
        getWindowProperties: (): Window.WindowProperties => {
          throw exception;
        }
      } as Window.Window;

      let mocker: MockKit = new MockKit();

      mocker.mockFunc(MmsWindowsManager.getInstance(), MmsWindowsManager.getInstance().initForPhone);

      mocker.mockFunc(console, console.error);


      await mainAbility.updateWindow(windowObj);

      mocker.verify('error', [TAG, 'Failed to obtain the area. Cause:' + JSON.stringify(exception)]);

      mocker.clear(MmsWindowsManager.getInstance());
      mocker.clear(console);
    })

    it('MainAbilityTest_handleAvoidAreaChange_top', 0, async () => {
      let topRectH: number = -10;
      let bottomRectH: number = -10;
      mainAbility.storage.setOrCreate('fullScreenPadding', {
        top: 1, bottom: 1
      });

      mainAbility.handleAvoidAreaChange(topRectH, bottomRectH);

      let prePadding = mainAbility.storage.get<SetOrCreateParams>('fullScreenPadding');
      let setOrCreateParams: SetOrCreateParams = {
        top: 1,
        bottom: 1,
        left: 0,
        right: 0
      };

      expect(JSON.stringify(prePadding)).assertEqual(JSON.stringify(setOrCreateParams));
    })

    it('MainAbilityTest_handleAvoidAreaChange_0', 0, async () => {
      let topRectH: number = -10;
      let bottomRectH: number = -10;
      mainAbility.storage.setOrCreate('fullScreenPadding', {});

      mainAbility.handleAvoidAreaChange(topRectH, bottomRectH);

      let prePadding = mainAbility.storage.get<SetOrCreateParams>('fullScreenPadding');
      let setOrCreateParams: SetOrCreateParams = {
        top: 0,
        bottom: 0,
        left: 0,
        right: 0
      };

      expect(JSON.stringify(prePadding)).assertEqual(JSON.stringify(setOrCreateParams));
    })

    it('MainAbilityTest_handleAvoidAreaChange_topRectH', 0, async () => {
      let topRectH: number = 10;
      let bottomRectH: number = 10;
      mainAbility.storage.setOrCreate('fullScreenPadding', {});

      mainAbility.handleAvoidAreaChange(topRectH, bottomRectH);

      let prePadding = mainAbility.storage.get<SetOrCreateParams>('fullScreenPadding');
      let setOrCreateParams: SetOrCreateParams = {
        top: topRectH,
        bottom: bottomRectH,
        left: 0,
        right: 0
      };

      expect(JSON.stringify(prePadding)).assertEqual(JSON.stringify(setOrCreateParams));
    })

    it('MainAbilityTest_handleWindowSizeChange_500_if3', 0, async () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(DeviceUtil, DeviceUtil.setPreferredOrientation);

      AppStorage.setOrCreate('curBp', 'md');

      mainAbility.handleWindowSizeChange(500, {} as Window.Window);

      expect(AppStorage.get('curBp')).assertEqual('sm');
    })

    it('MainAbilityTest_handleWindowSizeChange_800', 0, async () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(DeviceUtil, DeviceUtil.setPreferredOrientation);

      AppStorage.setOrCreate('curBp', 'md');

      mainAbility.handleWindowSizeChange(800, {} as Window.Window);

      expect(AppStorage.get('windowWidth')).assertEqual(800);
    })

    it('MainAbilityTest_handleWindowSizeChange_900', 0, async () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(DeviceUtil, DeviceUtil.setPreferredOrientation);

      AppStorage.setOrCreate('curBp', 'md');

      mainAbility.handleWindowSizeChange(900, {} as Window.Window);

      expect(AppStorage.get('windowWidth')).assertEqual(900);
    })

    it('MainAbilityTest_onBackground', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().setObject);
      mocker.mockFunc(simCardService, simCardService.deInit);

      mainAbility.onBackground();

      mocker.verify('deInit', []).once();

      mocker.clear(GlobalContext.getContext());
      mocker.clear(simCardService);
    })

    it('MainAbilityTest_updateWindowHeight', 0, () => {
      mainAbility.updateWindowHeight(100);

      expect(mainAbility.storage.get('windowHeight')).assertEqual(100);
      expect(AppStorage.get('windowHeight')).assertEqual(100);
    })

    it('MainAbilityTest_onBackPressed', 0, () => {
      expect(mainAbility.onBackPressed()).assertTrue();
    })
  })
}