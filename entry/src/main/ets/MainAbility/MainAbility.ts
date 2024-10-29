/**
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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
import Ability from '@ohos.app.ability.UIAbility'
import Window from '@ohos.window'

import HiLog from "../utils/HiLog";
import MmsPreferences from "../utils/MmsPreferences";
import WorkFactory, { WorkerType } from "../workers/WorkFactory";
import simCardService from "../service/SimCardService";

const TAG = "app";

export default class MainAbility extends Ability {
    onCreate(want, launchParam) {
        HiLog.i(TAG, "Ability onCreate com.ohos.mms version: 1.0.0.41");
        globalThis.mmsContext = this.context;
        globalThis.abilityWant = want;
        globalThis.needToUpdate = true;
        MmsPreferences.getInstance().initPreferences();
        globalThis.DataWorker = WorkFactory.getWorker(WorkerType.DataWorker);
    }

    onNewWant(want, launchParam) {
        HiLog.i(TAG, 'Application onNewWant');
        globalThis.abilityWant = want;
    }

    onWindowStageCreate(windowStage: Window.WindowStage) {
        // Main window is created, set main page for this ability
        windowStage.loadContent('pages/index', (err, data) => {
            if (err.code) {
                HiLog.e(TAG, 'testTag', 'Failed to load the content.');
                return;
            }
            HiLog.i(TAG, 'testTag', 'Succeeded in loading the content. Data: %{public}s');
        });
    }

    onWindowStageDestroy() {
        // Main window is destroyed, release UI related resources
        HiLog.i(TAG, 'Ability onWindowStageDestroy');
    }

    onForeground() {
        // Ability has brought to foreground
        HiLog.i(TAG, 'Ability onForeground');
        simCardService.init();
    }

    onBackground() {
        // Ability has back to background
        HiLog.i(TAG, 'Ability onBackground');
        simCardService.deInit();
    }

    onDestroy() {
        HiLog.i(TAG, 'Ability onDestroy');
        if (globalThis.DataWorker == null || globalThis.DataWorker == undefined) {
            return;
        }
        globalThis.DataWorker.close();
    }
}
