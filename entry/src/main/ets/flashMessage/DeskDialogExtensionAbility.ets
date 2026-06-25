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
import { UIExtensionAbility, UIExtensionContentSession } from '@kit.AbilityKit';
import HiLog from '../utils/HiLog';
import { BusinessError } from '@kit.BasicServicesKit';
import LooseObject from '../data/LooseObject';
import { GlobalContext } from '../MainAbility/GlobalHelper';
import { window } from '@kit.ArkUI';

const TAG = 'DeskDialogExtensionAbility'

export default class DeskDialogExtensionAbility extends UIExtensionAbility {
    onSessionCreate(want: Want, session: UIExtensionContentSession) {
        GlobalContext.getContext().setObject('mmsContext', this.context);
        let dialogInfo: LooseObject = want.parameters?.dialogInfo as LooseObject;
        let param: LooseObject = {
            'session': session,
            'dialogInfo': dialogInfo
        };
        HiLog.i(TAG, 'CallBannerExtensionAbility start');
        let storage: LocalStorage = new LocalStorage(param);
        try {
            session.loadContent('pages/DeskDialog', storage);
            session?.setWindowBackgroundColor('#33000000');
        } catch (exception) {
            HiLog.e(TAG, 'Failed to setWindowBackgroundColor ' + JSON.stringify(exception));
        }
        let windowClass: window.Window | undefined = undefined;
        let config: window.Configuration = {
            name: 'wakeup',
            windowType: window.WindowType.TYPE_DIALOG,
            ctx: this.context
        };
        // 唤醒屏幕
        try {
            window.createWindow(config, (err: BusinessError, data) => {
                const errCode: number = err.code;
                if (errCode) {
                    HiLog.e(TAG, `Failed to create the window. Cause code: ${err.code}, message: ${err.message}`);
                    return;
                }
                windowClass = data;
                HiLog.i(TAG, 'Succeeded in creating the window. Data: ');
                windowClass.setWakeUpScreen(true)
                windowClass.destroyWindow((err) => {
                    const errCode: number = err.code;
                    if (errCode) {
                        HiLog.e(TAG, `Failed to destroy the window. Cause code: ${err.code}, message: ${err.message}`);
                        return;
                    }
                    HiLog.i(TAG, 'Succeeded in destroying the window.');
                });
            });
        } catch (exception) {
            HiLog.e(TAG, `Failed to create the window. Cause code: ${exception.code}, message: ${exception.message}`);
        }
    }

    onSessionDestroy(session: UIExtensionContentSession) {
        HiLog.i(TAG, `UIExtAbility onSessionDestroy`);
    }
}