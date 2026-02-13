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
import { GlobalContext } from '../MainAbility/GlobalHelper';
import HiLog from '../utils/HiLog';
import { rpc } from '@kit.IPCKit';
import myCommon from '@ohos.app.ability.common';
import DeskDialogProxy from './DeskDialogProxy';
import { JSON, taskpool } from '@kit.ArkTS';
import { notificationManager } from '@kit.NotificationKit';
import { DataParameters } from '../utils/TypesUtils';

const TAG = 'Banner_CLASS';
let mServiceBannerProxy: DeskDialogProxy | undefined;
let mContext: Context;

export default class DeskDialogConnection {
    private connectionId: number | undefined = undefined;
    private static sInstance: DeskDialogConnection;

    static getInstance(context?: Context) {
        mContext = context as Context
        if (DeskDialogConnection.sInstance == null) {
            DeskDialogConnection.sInstance = new DeskDialogConnection();
        }
        return DeskDialogConnection.sInstance;
    }

    // 检查闪信是否以通知的形式展示
    flashMessageNeedShowNotification(): boolean {
        let isGameON : boolean = AppStorage.get('isGameModeOn') as boolean;
        let isNavigationON : boolean = AppStorage.get('isNavigationOn') as boolean;
        return isGameON || isNavigationON
    }
    // 短信展示逻辑处理
    flashMessageShowLogic(dialogInfo: LooseObject) {
        if (this.flashMessageNeedShowNotification()) {
            HiLog.i(TAG, 'handleTypeCheck yes')
            this.notificationShow(dialogInfo)
        } else {
            HiLog.i(TAG, 'handleTypeCheck no')
            this.bannerStart(dialogInfo)
        }
    }
    // 拉起一个自定义的
    jumpToConv(dialogInfo: LooseObject) {
        HiLog.i(TAG, 'connectService entry');
        let want: Want = {
            bundleName: 'com.ohos.mms',
            abilityName: 'DeskDialogAbility',
            parameters: dialogInfo
        };
        let context = (GlobalContext.getContext()
            .getObject('mmsContext') ?? mContext) as myCommon.UIAbilityContext;
        context.startAbility(want)
            .then(() => {
                HiLog.i(TAG, 'connectService startAbility');
            })
            .catch((e: Error) => {
                HiLog.i(TAG, 'connectService error' + JSON.stringify(e));
            });
        HiLog.i(TAG, 'connectService end');
    }
    // 用推送通知展示闪信
    notificationShow(dialogInfo: LooseObject) {
        let data : DataParameters = dialogInfo.data as DataParameters
        let result : LooseObject = dialogInfo.result as LooseObject
        HiLog.e(TAG, `notificationShow`);
        let notificationRequest: notificationManager.NotificationRequest = {
            content: {
                notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_LONG_TEXT,
                longText: {
                    title: result.telephone,
                    text:  result.content,
                    longText: result.content,
                    briefText:  result.content,
                    expandedTitle:  result.telephone,
                },
            },
            notificationSlotType: notificationManager.SlotType.SOCIAL_COMMUNICATION,
            deliveryTime: new Date().getTime(),
            groupName: 'MMS',
            autoDeletedTime : Number.MAX_VALUE,
        };
        notificationManager.publish(notificationRequest).then(() => { // 发布通知
        }).catch((err: Error) => {
            HiLog.e(TAG, `publish failed,message is ${err}`);
        });
    }
    /// 用系统弹窗的形式，展示闪信
    bannerStart(dialogInfo: LooseObject) {
        let want: Want = {
            bundleName: 'com.ohos.sceneboard',
            abilityName: 'com.ohos.sceneboard.systemdialog'
        };
        let context = (GlobalContext.getContext()
            .getObject('mmsContext') ?? mContext) as myCommon.UIAbilityContext;
        try {
            this.connectionId = context?.connectServiceExtensionAbility(want, {
                onConnect(elementName:undefined, remote: rpc.RemoteObject) {
                    if (remote === null) {
                        return;
                    }
                    HiLog.i(TAG, 'onConnect success')
                    mServiceBannerProxy = new DeskDialogProxy(remote, dialogInfo);
                    mServiceBannerProxy.bannerStart();
                },
                onDisconnect(elementName) {
                  HiLog.i(TAG, 'onDisconnect === ' + elementName)
                },
                onFailed(code: number) {
                    mServiceBannerProxy = undefined;
                    HiLog.i(TAG, 'onConnect === ' + code)
                }
            });
        } catch (error ) {
            HiLog.i(TAG, 'onConnect catch error===' + error.tolocaleString())
        }
    }
}