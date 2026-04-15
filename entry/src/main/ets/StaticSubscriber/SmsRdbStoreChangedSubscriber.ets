/**
 * Copyright (c) 2025-2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import NotificationService, { IBadgeContextInfo } from '../service/NotificationService';
import HiLog from '../utils/HiLog';
import { StaticSubscriberExtensionAbility, systemDateTime } from '@kit.BasicServicesKit';
import commonData from '../data/commonData';
import { commonEventManager } from '@kit.BasicServicesKit';

const TAG: string = 'SmsRdbStoreChangedSubscriber';

export default class MmsStaticSubscriber extends StaticSubscriberExtensionAbility {

    public onReceiveEvent(event: commonEventManager.CommonEventData): void {

        HiLog.w(TAG, `onReceiveEvent, event: ${event.event}`);
        if (event.event === commonData.STR.KEY_DATA_TO_EL5) {
            HiLog.i(TAG, 'onReceiveEvent, store change event: ' + event.event);
            // 如果前端进程是活跃状态，需要更新页面
            let want: Want = {
                bundleName: 'com.ohos.mms',
                abilityName: 'ServiceExtAbility',
                parameters: {
                    'serviceEvent': commonData.STR.KEY_DATA_TO_EL5,
                }
            };
            this.context.startAbility(want);
        }
        HiLog.w(TAG, `onReceiveEvent end`);
    }
}
