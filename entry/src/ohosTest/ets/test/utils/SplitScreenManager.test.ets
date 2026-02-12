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
import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect, MockKit, when } from '@ohos/hypium'
import { SplitScreenManager, SplitInfoModel , SplitScreenType} from '../../../../main/ets/utils/SplitScreenManager';
import { window } from '@kit.ArkUI';
import DeviceUtil from '../../../../main/ets/utils/DeviceUtil';
import display from '@ohos.display';
import deviceInfo from '@ohos.deviceInfo';


export default function SplitScreenManagerTest() {
    describe('SplitScreenManagerTest', () => {
        let splitScreenManager: SplitScreenManager;

        // Defines a test suite. Two parameters are supported: test suite name and test suite function.
        beforeAll(() => {
            // Presets an action, which is performed only once before all test cases of the test suite start.
            // This API supports only one parameter: preset action function.
        })
        beforeEach(() => {
            // Presets an action, which is performed before each unit test case starts.
            // The number of execution times is the same as the number of test cases defined by **it**.
            // This API supports only one parameter: preset action function.
        })
        afterEach(() => {
            // Presets a clear action, which is performed after each unit test case ends.
            // The number of execution times is the same as the number of test cases defined by **it**.
            // This API supports only one parameter: clear action function.
        })
        afterAll(() => {
            // Presets a clear action, which is performed after all test cases of the test suite end.
            // This API supports only one parameter: clear action function.
        })

        it('SplitScreenManager_getInstance', 0, () => {
            splitScreenManager = new SplitScreenManager()
            expect(typeof SplitScreenManager.getInstance()).assertEqual(typeof splitScreenManager);
        })

        it('SplitScreenManager_updateWindowStatusType', 0, () => {
            splitScreenManager = new SplitScreenManager()
            splitScreenManager.updateWindowStatusType(window.WindowStatusType.SPLIT_SCREEN)
            expect((splitScreenManager as object)['windowStatusType']).assertEqual(window.WindowStatusType.SPLIT_SCREEN);
        })

        it('SplitScreenManager_isLimitOneInputHieght_0', 0, () => {
            splitScreenManager = SplitScreenManager.getInstance();
            let mocker: MockKit = new MockKit();
            when(mocker.mockFunc(splitScreenManager,splitScreenManager.getSplitScreenType))()
                .afterReturn(SplitScreenType.SMALL);
            expect(splitScreenManager.isLimitOneInputHieght()).assertEqual(true);
            mocker.clear(splitScreenManager)
        })

        it('SplitScreenManager_isLimitOneInputHieght_1', 0, () => {
            splitScreenManager = SplitScreenManager.getInstance();
            let mocker: MockKit = new MockKit();
            when(mocker.mockFunc(splitScreenManager,splitScreenManager.getSplitScreenType))()
                .afterReturn(SplitScreenType.DEFAULT);
            expect(splitScreenManager.isLimitOneInputHieght()).assertEqual(false);
            mocker.clear(splitScreenManager)
        })

        it('SplitScreenManager_isLimitOneInputHieght_2', 0, () => {
            splitScreenManager = SplitScreenManager.getInstance();
            (splitScreenManager as object)['isPad'] = true;
            let mocker: MockKit = new MockKit();
            when(mocker.mockFunc(splitScreenManager,splitScreenManager.getSplitScreenType))()
                .afterReturn(SplitScreenType.SMALL);
            expect(splitScreenManager.isLimitOneInputHieght()).assertEqual(true);
            mocker.clear(splitScreenManager)
        })

        it('SplitScreenManager_isLimitOneInputHieght_3', 0, () => {
            splitScreenManager = SplitScreenManager.getInstance();
            (splitScreenManager as object)['isPad'] = true;
            let mocker: MockKit = new MockKit();
            when(mocker.mockFunc(splitScreenManager,splitScreenManager.getSplitScreenType))()
                .afterReturn(SplitScreenType.MEDIUM);
            expect(splitScreenManager.isLimitOneInputHieght()).assertEqual(false);
            mocker.clear(splitScreenManager)
        })

        it('SplitScreenManager_isSplitScreenSmall_0', 0, () => {
            splitScreenManager = SplitScreenManager.getInstance();
            (splitScreenManager as object)['isPad'] = true;
            let mocker: MockKit = new MockKit();
            when(mocker.mockFunc(splitScreenManager,splitScreenManager.getSplitScreenType))()
                .afterReturn(SplitScreenType.SMALL);
            expect(splitScreenManager.isSplitScreenSmall()).assertEqual(false);
            mocker.clear(splitScreenManager)
        })

        it('SplitScreenManager_isSplitScreenSmall_1', 0, () => {
            splitScreenManager = SplitScreenManager.getInstance();
            (splitScreenManager as object)['isPad'] = false;
            let mocker: MockKit = new MockKit();
            when(mocker.mockFunc(splitScreenManager,splitScreenManager.getSplitScreenType))()
                .afterReturn(SplitScreenType.SMALL);
            expect(splitScreenManager.isSplitScreenSmall()).assertEqual(true);
            mocker.clear(splitScreenManager)
        })

        it('SplitScreenManager_isSplitScreenSmall_2', 0, () => {
            splitScreenManager = SplitScreenManager.getInstance();
            let mocker: MockKit = new MockKit();
            when(mocker.mockFunc(splitScreenManager,splitScreenManager.getSplitScreenType))()
                .afterReturn(SplitScreenType.MEDIUM);
            expect(splitScreenManager.isSplitScreenSmall()).assertEqual(false);
            mocker.clear(splitScreenManager)
        })

        it('SplitScreenManager_isSplitScreenMediumAndSmall_0', 0, () => {
            splitScreenManager = SplitScreenManager.getInstance();
            (splitScreenManager as object)['isPad'] = true;
            let mocker: MockKit = new MockKit();
            when(mocker.mockFunc(splitScreenManager,splitScreenManager.getSplitScreenType))()
                .afterReturn(SplitScreenType.SMALL);
            expect(splitScreenManager.isSplitScreenMediumAndSmall()).assertEqual(true);
            mocker.clear(splitScreenManager)
        })

        it('SplitScreenManager_isSplitScreenMediumAndSmall_1', 0, () => {
            splitScreenManager = SplitScreenManager.getInstance();
            (splitScreenManager as object)['isPad'] = true;
            let mocker: MockKit = new MockKit();
            when(mocker.mockFunc(splitScreenManager,splitScreenManager.getSplitScreenType))()
                .afterReturn(SplitScreenType.MEDIUM);
            expect(splitScreenManager.isSplitScreenMediumAndSmall()).assertEqual(false);
            mocker.clear(splitScreenManager)
        })

        it('SplitScreenManager_isSplitScreenMediumAndSmall_2', 0, () => {
            splitScreenManager = SplitScreenManager.getInstance();
            (splitScreenManager as object)['isPad'] = false;
            let mocker: MockKit = new MockKit();
            when(mocker.mockFunc(splitScreenManager,splitScreenManager.getSplitScreenType))()
                .afterReturn(SplitScreenType.MEDIUM);
            expect(splitScreenManager.isSplitScreenMediumAndSmall()).assertEqual(true);
            mocker.clear(splitScreenManager)
        })

        it('SplitScreenManager_isSplitScreenMediumAndSmall_3', 0, () => {
            splitScreenManager = SplitScreenManager.getInstance();
            (splitScreenManager as object)['isPad'] = false;
            let mocker: MockKit = new MockKit();
            when(mocker.mockFunc(splitScreenManager,splitScreenManager.getSplitScreenType))()
                .afterReturn(SplitScreenType.BIG);
            expect(splitScreenManager.isSplitScreenMediumAndSmall()).assertEqual(false);
            mocker.clear(splitScreenManager)
        })

        it('SplitScreenManager_isSplitScreenLongPress_0', 0, () => {
            splitScreenManager = SplitScreenManager.getInstance();
            (splitScreenManager as object)['isPad'] = false;
            let mocker: MockKit = new MockKit();
            when(mocker.mockFunc(splitScreenManager,splitScreenManager.getSplitScreenType))()
                .afterReturn(SplitScreenType.BIG);
            expect(splitScreenManager.isSplitScreenLongPress()).assertEqual(false);
            mocker.clear(splitScreenManager)
        })

        it('SplitScreenManager_isSplitScreenLongPress_1', 0, () => {
            let mocker: MockKit = new MockKit();
            when(mocker.mockFunc(DeviceUtil, DeviceUtil.isFoldable))()
                .afterReturn(false);
            splitScreenManager = SplitScreenManager.getInstance();
            (splitScreenManager as object)['isPad'] = false;
            when(mocker.mockFunc(splitScreenManager,splitScreenManager.getSplitScreenType))()
                .afterReturn(SplitScreenType.SMALL);
            expect(splitScreenManager.isSplitScreenLongPress()).assertEqual(true);
            mocker.clear(splitScreenManager)
            mocker.clear(DeviceUtil)
        })

        it('SplitScreenManager_isSplitScreenLongPress_2', 0, () => {
            splitScreenManager = SplitScreenManager.getInstance();
            (splitScreenManager as object)['isPad'] = true;
            let mocker: MockKit = new MockKit();
            when(mocker.mockFunc(splitScreenManager,splitScreenManager.getSplitScreenType))()
                .afterReturn(SplitScreenType.SMALL);
            expect(splitScreenManager.isSplitScreenLongPress()).assertEqual(false);
            mocker.clear(splitScreenManager)
        })

        it('SplitScreenManager_isSplitScreenEmojiLow_0', 0, () => {
            let windowStatusType = AppStorage.get('windowStatusType') || 0
            AppStorage.setOrCreate('windowStatusType',window.WindowStatusType.SPLIT_SCREEN)
            splitScreenManager = SplitScreenManager.getInstance();
            (splitScreenManager as object)['isPad'] = false;
            let mocker: MockKit = new MockKit();
            when(mocker.mockFunc(splitScreenManager,splitScreenManager.getSplitScreenType))()
                .afterReturn(SplitScreenType.DEFAULT);
            expect(splitScreenManager.isSplitScreenEmojiLow()).assertEqual(false);
            mocker.clear(splitScreenManager)
            AppStorage.setOrCreate('windowStatusType',windowStatusType)
        })

        it('SplitScreenManager_isSplitScreenEmojiLow_1', 0, () => {
            let windowStatusType = AppStorage.get('windowStatusType') || 0
            AppStorage.setOrCreate('windowStatusType',window.WindowStatusType.SPLIT_SCREEN)
            splitScreenManager = SplitScreenManager.getInstance();
            (splitScreenManager as object)['isPad'] = true;
            let mocker: MockKit = new MockKit();
            when(mocker.mockFunc(splitScreenManager,splitScreenManager.getSplitScreenType))()
                .afterReturn(SplitScreenType.BIG);
            expect(splitScreenManager.isSplitScreenEmojiLow()).assertEqual(false);
            mocker.clear(splitScreenManager)
            AppStorage.setOrCreate('windowStatusType',windowStatusType)
        })

        it('SplitScreenManager_isSplitScreenEmojiLow_2', 0, () => {
            let windowStatusType = AppStorage.get('windowStatusType') || 0
            AppStorage.setOrCreate('windowStatusType',window.WindowStatusType.FULL_SCREEN)
            splitScreenManager = SplitScreenManager.getInstance();
            (splitScreenManager as object)['isPad'] = false;
            let mocker: MockKit = new MockKit();
            when(mocker.mockFunc(splitScreenManager,splitScreenManager.getSplitScreenType))()
                .afterReturn(SplitScreenType.MEDIUM);
            expect(splitScreenManager.isSplitScreenEmojiLow()).assertEqual(false);
            mocker.clear(splitScreenManager)
            AppStorage.setOrCreate('windowStatusType',windowStatusType)
        })

        it('SplitScreenManager_isSplitScreenEmojiLow_3', 0, () => {
            let windowStatusType = AppStorage.get('windowStatusType') || 0
            AppStorage.setOrCreate('windowStatusType',window.WindowStatusType.SPLIT_SCREEN)
            splitScreenManager = SplitScreenManager.getInstance();
            (splitScreenManager as object)['isPad'] = false;
            let mocker: MockKit = new MockKit();
            when(mocker.mockFunc(splitScreenManager,splitScreenManager.getSplitScreenType))()
                .afterReturn(SplitScreenType.MEDIUM);
            expect(splitScreenManager.isSplitScreenEmojiLow()).assertEqual(true);
            mocker.clear(splitScreenManager)
            AppStorage.setOrCreate('windowStatusType',windowStatusType)
        })

        it('SplitScreenManager_isSplitScreenEmojiLow_4', 0, () => {
            let windowStatusType = AppStorage.get('windowStatusType') || 0
            AppStorage.setOrCreate('windowStatusType',window.WindowStatusType.SPLIT_SCREEN)
            splitScreenManager = SplitScreenManager.getInstance();
            (splitScreenManager as object)['isPad'] = false;
            let mocker: MockKit = new MockKit();
            when(mocker.mockFunc(splitScreenManager,splitScreenManager.getSplitScreenType))()
                .afterReturn(SplitScreenType.SMALL);
            expect(splitScreenManager.isSplitScreenEmojiLow()).assertEqual(true);
            mocker.clear(splitScreenManager)
            AppStorage.setOrCreate('windowStatusType',windowStatusType)
        })

        it('SplitScreenManager_getInputMaxLine_0', 0, () => {
            splitScreenManager = SplitScreenManager.getInstance();
            (splitScreenManager as object)['isPad'] = true;
            let mocker: MockKit = new MockKit();
            when(mocker.mockFunc(splitScreenManager,splitScreenManager.getSplitScreenType))()
                .afterReturn(SplitScreenType.SMALL);
            expect(splitScreenManager.getInputMaxLine()).assertEqual(6);
            mocker.clear(splitScreenManager)
        })

        it('SplitScreenManager_getInputMaxLine_1', 0, () => {
            splitScreenManager = SplitScreenManager.getInstance();
            (splitScreenManager as object)['isPad'] = true;
            let mocker: MockKit = new MockKit();
            when(mocker.mockFunc(splitScreenManager,splitScreenManager.getSplitScreenType))()
                .afterReturn(SplitScreenType.MEDIUM);
            expect(splitScreenManager.getInputMaxLine()).assertEqual(10);
            mocker.clear(splitScreenManager)
        })

        it('SplitScreenManager_getInputMaxLine_2', 0, () => {
            splitScreenManager = SplitScreenManager.getInstance();
            (splitScreenManager as object)['isPad'] = true;
            let mocker: MockKit = new MockKit();
            when(mocker.mockFunc(splitScreenManager,splitScreenManager.getSplitScreenType))()
                .afterReturn(SplitScreenType.BIG);
            expect(splitScreenManager.getInputMaxLine()).assertEqual(10);
            mocker.clear(splitScreenManager)
        })

        it('SplitScreenManager_getInputMaxLine_3', 0, () => {
            splitScreenManager = SplitScreenManager.getInstance();
            (splitScreenManager as object)['isPad'] = false;
            let mocker: MockKit = new MockKit();
            when(mocker.mockFunc(splitScreenManager,splitScreenManager.getSplitScreenType))()
                .afterReturn(SplitScreenType.BIG);
            expect(splitScreenManager.getInputMaxLine()).assertEqual(8);
            mocker.clear(splitScreenManager)
        })

        it('SplitScreenManager_getInputMaxLine_4', 0, () => {
            splitScreenManager = SplitScreenManager.getInstance();
            (splitScreenManager as object)['isPad'] = false;
            let mocker: MockKit = new MockKit();
            when(mocker.mockFunc(splitScreenManager,splitScreenManager.getSplitScreenType))()
                .afterReturn(SplitScreenType.MEDIUM);
            expect(splitScreenManager.getInputMaxLine()).assertEqual(6);
            mocker.clear(splitScreenManager)
        })

        it('SplitScreenManager_getInputMaxLine_5', 0, () => {
            splitScreenManager = SplitScreenManager.getInstance();
            (splitScreenManager as object)['isPad'] = false;
            let mocker: MockKit = new MockKit();
            when(mocker.mockFunc(splitScreenManager,splitScreenManager.getSplitScreenType))()
                .afterReturn(SplitScreenType.SMALL);
            expect(splitScreenManager.getInputMaxLine()).assertEqual(4);
            mocker.clear(splitScreenManager)
        })

        it('SplitScreenManager_getInputMaxLine_6', 0, () => {
            splitScreenManager = SplitScreenManager.getInstance();
            let mocker: MockKit = new MockKit();
            when(mocker.mockFunc(splitScreenManager,splitScreenManager.getSplitScreenType))()
                .afterReturn(SplitScreenType.DEFAULT);
            expect(splitScreenManager.getInputMaxLine()).assertEqual(10);
            mocker.clear(splitScreenManager)
        })

        it('SplitScreenManager_updateSplitScreenPosition_0', 0, () => {
            let windowStatusType = AppStorage.get('windowStatusType') || 0
            AppStorage.setOrCreate('windowStatusType',window.WindowStatusType.SPLIT_SCREEN)
            splitScreenManager = SplitScreenManager.getInstance();
            let rect: window.Rect = {
                left: 0,
                top: 0,
                width: 320,
                height: 500
            }
            splitScreenManager.updateSplitScreenPosition(rect)
            expect(splitScreenManager.infoModel.isAboveScreen).assertEqual(true);
            AppStorage.setOrCreate('windowStatusType',windowStatusType)
        })

        it('SplitScreenManager_updateSplitScreenPosition_1', 0, () => {
            let windowStatusType = AppStorage.get('windowStatusType') || 0
            AppStorage.setOrCreate('windowStatusType',window.WindowStatusType.FULL_SCREEN)
            splitScreenManager = SplitScreenManager.getInstance();
            let rect: window.Rect = {
                left: 0,
                top: 0,
                width: 320,
                height: 500
            }
            splitScreenManager.updateSplitScreenPosition(rect)
            expect(splitScreenManager.infoModel.isAboveScreen).assertEqual(true);
            AppStorage.setOrCreate('windowStatusType',windowStatusType)
        })

        it('SplitScreenManager_updateSplitScreenPosition_2', 0, () => {
            let windowStatusType = AppStorage.get('windowStatusType') || 0
            AppStorage.setOrCreate('windowStatusType',window.WindowStatusType.SPLIT_SCREEN)
            splitScreenManager = SplitScreenManager.getInstance();
            let rect: window.Rect = {
                left: 0,
                top: 300,
                width: 320,
                height: 500
            }
            splitScreenManager.updateSplitScreenPosition(rect)
            expect(splitScreenManager.infoModel.isAboveScreen).assertEqual(false);
            AppStorage.setOrCreate('windowStatusType',windowStatusType)
        })

        it('SplitScreenManager_updateScreenSize', 0, () => {
            splitScreenManager = SplitScreenManager.getInstance();
            (splitScreenManager as object)['windowStatusType'] = window.WindowStatusType.SPLIT_SCREEN;
            splitScreenManager.updateScreenSize(0, 10);
            expect((splitScreenManager as object)['screenWidth']).assertEqual(0);
            expect((splitScreenManager as object)['screenHeight']).assertEqual(10);
        })

        it('SplitScreenManager_getSplitScreenType_0', 0, () => {
            let mocker: MockKit = new MockKit();
            when(mocker.mockFunc(DeviceUtil, DeviceUtil.isFoldable))()
                .afterReturn(false);
            splitScreenManager = SplitScreenManager.getInstance();
            (splitScreenManager as object)['windowStatusType'] = window.WindowStatusType.SPLIT_SCREEN;
            (splitScreenManager as object)['screenHeight'] = 500;
            (splitScreenManager as object)['fullScreenHeight'] = 1100;
            expect(splitScreenManager.getSplitScreenType()).assertEqual(SplitScreenType.MEDIUM);
            mocker.clear(DeviceUtil)
        })

        it('SplitScreenManager_getSplitScreenType_1', 0, () => {
            splitScreenManager = SplitScreenManager.getInstance();
            (splitScreenManager as object)['windowStatusType'] = window.WindowStatusType.SPLIT_SCREEN;
            (splitScreenManager as object)['screenHeight'] = 300;
            (splitScreenManager as object)['fullScreenHeight'] = 1100;
            expect(splitScreenManager.getSplitScreenType()).assertEqual(SplitScreenType.SMALL);
        })

        it('SplitScreenManager_getSplitScreenType_2', 0, () => {
            splitScreenManager = SplitScreenManager.getInstance();
            (splitScreenManager as object)['windowStatusType'] = window.WindowStatusType.SPLIT_SCREEN;
            (splitScreenManager as object)['screenHeight'] = 500;
            (splitScreenManager as object)['fullScreenHeight'] = 1100;
            expect(splitScreenManager.getSplitScreenType()).assertEqual(SplitScreenType.MEDIUM);
        })

        it('SplitScreenManager_getSplitScreenType_3', 0, () => {
            splitScreenManager = SplitScreenManager.getInstance();
            (splitScreenManager as object)['windowStatusType'] = window.WindowStatusType.SPLIT_SCREEN;
            (splitScreenManager as object)['screenHeight'] = 700;
            (splitScreenManager as object)['fullScreenHeight'] = 1100;
            expect(splitScreenManager.getSplitScreenType()).assertEqual(SplitScreenType.BIG);
        })

        it('SplitScreenManager_getSplitScreenType_4', 0, () => {
            splitScreenManager = SplitScreenManager.getInstance();
            (splitScreenManager as object)['windowStatusType'] = window.WindowStatusType.SPLIT_SCREEN;
            (splitScreenManager as object)['screenHeight'] = 900;
            (splitScreenManager as object)['fullScreenHeight'] = 1100;
            expect(splitScreenManager.getSplitScreenType()).assertEqual(SplitScreenType.DEFAULT);
        })

        it('SplitScreenManager_getSplitScreenType_5', 0, () => {
            splitScreenManager = SplitScreenManager.getInstance();
            (splitScreenManager as object)['windowStatusType'] = window.WindowStatusType.SPLIT_SCREEN;
            (splitScreenManager as object)['orientation'] = 1;
            (splitScreenManager as object)['screenHeight'] = 500;
            (splitScreenManager as object)['fullScreenHeight'] = 1100;
            expect(splitScreenManager.getSplitScreenType()).assertEqual(SplitScreenType.MEDIUM);
        })

        it('SplitScreenManager_getSplitScreenType_6', 0, () => {
            splitScreenManager = SplitScreenManager.getInstance();
            (splitScreenManager as object)['windowStatusType'] = window.WindowStatusType.FULL_SCREEN;
            (splitScreenManager as object)['screenHeight'] = 900;
            (splitScreenManager as object)['fullScreenHeight'] = 1100;
            expect(splitScreenManager.getSplitScreenType()).assertEqual(SplitScreenType.DEFAULT);
        })

    })
}