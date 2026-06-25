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
import { rpc } from '@kit.IPCKit';
import { BusinessError, screenLock } from '@kit.BasicServicesKit';
import HiLog from '../utils/HiLog';
import LooseObject from '../data/LooseObject';
import { JSON } from '@kit.ArkTS';

const TAG = 'DeskDialogProxy';
const RPC_TIME: number = 1000;
export default class DeskDialogProxy {
    private dialogInfo: LooseObject;
    private static readonly PROXY_DATA_LENGTH = 3;
    private proxy: rpc.RemoteObject;

    constructor(proxy:rpc.RemoteObject, dialogInfo: LooseObject) {
        this.proxy = proxy;
        this.dialogInfo = dialogInfo;
    }

    bannerStart(): void {
        let option = new rpc.MessageOption();
        option.setWaitTime(RPC_TIME);
        let data = rpc.MessageSequence.create();
        let reply = rpc.MessageSequence.create();
        data.writeInt(DeskDialogProxy.PROXY_DATA_LENGTH);
        data.writeString('bundleName');
        data.writeString('com.ohos.mms');
        data.writeString('abilityName');
        data.writeString('DeskDialogExtensionAbility');
        data.writeString('parameters');
        let dialogStr = JSON.stringify(this.dialogInfo)
        let parameter: Record<string, Object> = {
            'ability.want.params.uiExtensionType' : 'sysDialog/common',
            'dialogInfo' : this.dialogInfo,
            'sysDialogZOrder' : screenLock.isLocked() ? 2 : 1, //sysDialogZOrder （1为默认层级，2可以显示在锁屏之上）
        }
        data.writeString(JSON.stringify(parameter));
        HiLog.i(TAG, `bannerFirstStart `);
        this.proxy.sendMessageRequest(1, data, reply, option).then(
            result => {
                HiLog.i(TAG, `startdialog success`);
            },
            (error: BusinessError): void => HiLog.i(TAG, `startdialog error ${JSON.stringify(error)}`)
        ).finally(() => {
            data.reclaim();
            reply.reclaim();
        });
        return;
    }
}