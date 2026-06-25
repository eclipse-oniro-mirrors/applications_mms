/**
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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
import HiLog from './HiLog';
import { BusinessError } from '@ohos.base';
import { commonEventManager } from '@kit.BasicServicesKit';
import lazy commonEvent from '@ohos.commonEvent';
import commonData from '../data/commonData'
const TAG = 'TimeTickUtil';

/**
 * Handle file data
 */
export default class TimeTickUtil {
  private timeTickEventData?: commonEventManager.CommonEventSubscriber;
  private function?: Function;

  constructor(fun: Function) {
    this.function = fun;
  }

  public subscribeTimeTickEvent() {
    let subscribeInfo: commonEventManager.CommonEventSubscribeInfo = {
      events: [commonData.STR.COMMON_EVENT_TIME_TICK]
    };
    commonEventManager.createSubscriber(subscribeInfo,
      (arg1, arg2) => {
        this.createTimeTickSubscriberCallBack(arg1, arg2)
      })
  }

  public unSubscribeTimeTickEvent() {
    if (this.timeTickEventData != null) {
      commonEvent.unsubscribe(this.timeTickEventData, () => {
        HiLog.i(TAG, 'unsubscribe timeTickEventData, success');
      });
    }
  }

  public createTimeTickSubscriberCallBack(err: BusinessError, data: commonEventManager.CommonEventSubscriber) {
    if (!err) {
      HiLog.i(TAG, `createTimeTickSubscriber`)
      this.timeTickEventData = data;
      commonEventManager.subscribe(this.timeTickEventData, (err, data) => {
        HiLog.i(TAG, 'createTimeTickSubscriberCallBack,err : ' + err?.code)
        if (data == null) {
          HiLog.w(TAG, 'refreshEventData, data or data.data is null, return');
          return;
        }
        HiLog.i(TAG, `TimeTick`)
        if (this.function) {
          this.function();
        }
      });
    } else {
      HiLog.e(TAG, `createTimeTickSubscriber failed, code is ${err.code}, message is ${err.message}`);
    }
  }
}