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
import LooseObject from '../data/LooseObject';
import HiLog from '../utils/HiLog';
import { UIExtensionContentSession } from '@kit.AbilityKit';
import { DataParameters } from '../utils/TypesUtils';
import ReceiveService from '../StaticSubscriber/ReceiveService';
import { GlobalContext } from '../MainAbility/GlobalHelper';
import myCommon from '@ohos.app.ability.common';
import { AlertDialog } from '@kit.ArkUI'

const TAG = 'DeskDialog';

@Entry
@Component
export default struct DeskDialog {
    public receiveService = ReceiveService.getInstance();
    localStorage = this.getUIContext().getSharedLocalStorage();
    dialogInfo: LooseObject | undefined = this.localStorage?.get('dialogInfo')
    result : LooseObject = this.dialogInfo?.result as LooseObject
    data : DataParameters = this.dialogInfo?.data as DataParameters
    session: UIExtensionContentSession | undefined = this.localStorage?.get('session');
    dialogControllerConfirm: CustomDialogController = new CustomDialogController({
        builder: AlertDialog({
            primaryTitle: this.result?.contactName ?? this.result?.telephone ?? '',
            content: this.result?.content ?? '',
            primaryButton: {
                value: $r('app.string.msg_know'),
                action: () => {
                    this.cancel()
                },
            },
            secondaryButton: {
                value: $r('app.string.save'),
                action: () => {
                    this.confirm()
                }
            },
        }
        ),
        autoCancel: false,
    }
    )
    /**
     * Cancel an event
     */
    cancel: () => void = () => {
        this.session?.terminateSelf()
    };
    /**
     * Acknowledgment Events
     */
    confirm: () => void = () => {
        if (this.dialogInfo != null) {
            let copyDia = this.dialogInfo!
            copyDia.event = 'FLASH_SAVE_MESSAGE'
            let want: Want = {
                bundleName: 'com.ohos.mms',
                abilityName: 'DeskDialogAbility',
                parameters: copyDia,
            };
            let context = GlobalContext.getContext()
                .getObject('mmsContext') as myCommon.UIAbilityContext;
            context.startAbility(want)
                .then(() => {
                    HiLog.i(TAG, 'connectService startAbility');
                })
                .catch((e: Error) => {
                    HiLog.i(TAG, 'connectService error' + JSON.stringify(e));
                });
            HiLog.i(TAG, 'connectService end');
        }
        this.session?.terminateSelf()
    };


    aboutToAppear() {
        HiLog.i(TAG, 'aboutToAppear')
        this.dialogControllerConfirm.open()
    }

    aboutToDisappear() {
        HiLog.i(TAG, 'aboutToDisappear')
    }

    build() {}
}
