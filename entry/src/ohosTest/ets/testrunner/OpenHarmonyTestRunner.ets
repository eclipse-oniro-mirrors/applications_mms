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
import { abilityDelegatorRegistry, TestRunner } from '@kit.TestKit';
import { UIAbility } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

let abilityDelegator: abilityDelegatorRegistry.AbilityDelegator;
let abilityDelegatorArguments: abilityDelegatorRegistry.AbilityDelegatorArgs;
let tag: string = 'testTag';
const UNLOCK_ERROR = -3;
const global: object = new Function("return this")();

async function onAbilityCreateCallback(data: UIAbility) {
    hilog.info(0x0000, tag, 'onAbilityCreateCallback, data: ${}', JSON.stringify(data));
}

async function addAbilityMonitorCallback(err: BusinessError) {
    hilog.info(0x0000, tag, 'addAbilityMonitorCallback : %{public}s', JSON.stringify(err) ?? '');
}

export default class OpenHarmonyTestRunner implements TestRunner {
    constructor() {
    }

    onPrepare() {
        hilog.info(0x0000, tag, '%{public}s', 'OpenHarmonyTestRunner OnPrepare ');
    }

    async onRun() {
        hilog.info(0x0000, tag, '%{public}s', 'OpenHarmonyTestRunner onRun run 00');
        abilityDelegatorArguments = abilityDelegatorRegistry.getArguments()
        abilityDelegator = abilityDelegatorRegistry.getAbilityDelegator()
        let moduleName = abilityDelegatorArguments.parameters['-m'];

        const savePath: string = '__savePath__';
        const readPath: string = '__readPath__';
        const testMode: string = '__testMode__';
        let uid: number = Math.floor(abilityDelegator.getAppContext().applicationInfo.uid / 200000);
        const bundleName = abilityDelegatorArguments.bundleName;
        global[savePath] = '/data/storage/el2/base/js_coverage.json';
        global[readPath] = '/data/app/el2/' + uid + '/base/' + bundleName + '/js_coverage.json';
        global[testMode] = 'ohostest';


        const testAbilityName = 'TestAbility';
        hilog.info(0x0000, tag, '%{public}s', 'OpenHarmonyTestRunner onRun run 01');
        let lMonitor: abilityDelegatorRegistry.AbilityMonitor = {
            abilityName: testAbilityName,
            onAbilityCreate: onAbilityCreateCallback,
            moduleName: moduleName
        };
        hilog.info(0x0000, tag, `%{public}s`, `OpenHarmonyTestRunner onRun run 02   bundleName: ${bundleName}    abilityName: ${testAbilityName}   moduleName: ${moduleName}`);
        abilityDelegator.addAbilityMonitor(lMonitor, addAbilityMonitorCallback)

        hilog.info(0x0000, tag, '%{public}s', 'OpenHarmonyTestRunner onRun run 03');

        hilog.info(0x0000, tag, '%{public}s', 'OpenHarmonyTestRunner onRun run 04');
        await startAbility(bundleName, testAbilityName, moduleName);
        hilog.info(0x0000, tag, '%{public}s', 'OpenHarmonyTestRunner onRun end');
    }
}

async function startAbility(bundleName: string, abilityName: string, moduleName: string) {
    hilog.info(0x0000, tag, '%{public}s', `startAbility bundleName: ${bundleName}    abilityName: ${abilityName}   moduleName: ${moduleName}`);
    await abilityDelegator.executeShellCommand(`aa start -b ${bundleName} -a ${abilityName} -m ${moduleName}`).then(result => {
        if (result.stdResult.includes("error: unlock screen failed in developer mode")) {
            hilog.info(0x0000, tag, '%{public}s', `startAbility failed ${result.stdResult}`);
            abilityDelegator.finishTest("", UNLOCK_ERROR, () => {});
            return;
        }
    }).catch((err: string) => {
        hilog.info(0x0000, tag, '%{public}s', `startAbility error: ${err}`);
    })
}