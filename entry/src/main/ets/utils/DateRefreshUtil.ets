/**
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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

import { BusinessError, commonEventManager } from '@kit.BasicServicesKit';
import commonData from '../data/commonData';
import { DateUtil } from './DateUtil';
import HiLog from './HiLog';
import { HashMap } from '@kit.ArkTS';

const TAG = 'DateRefreshUtil';

/**
 * 当用户一直停留在页面时，需要一个定时刷新日期的方式
 */
export class DateRefreshUtil {
  private static sInstance: DateRefreshUtil | undefined = undefined;
  private refreshMap: HashMap<string, Function> = new HashMap();
  private timeTickEventData?: commonEventManager.CommonEventSubscriber;
  private hasRegisteredCommonEvent: boolean = false;
  public static readonly TYPE_OF_CONVERSATION_LIST: string = 'TYPE_OF_CONVERSATION_LIST';
  public static readonly TYPE_OF_CONVERSATION: string = 'TYPE_OF_CONVERSATION';
  public static readonly TYPE_OF_NORMAL: string = 'TYPE_OF_NORMAL';

  static getInstance() {
    if (!DateRefreshUtil.sInstance) {
      DateRefreshUtil.sInstance = new DateRefreshUtil();
    }
    return DateRefreshUtil.sInstance;
  }

  private publishRefresh() {
    this.refreshMap.forEach((callback: Function, key: string) => {
      if (callback) {
        HiLog.i(TAG, ` callback,${key}`);
        callback();
      }
    })
  }

  /**
   * 注册系统公共事件，每分钟进行回调
   */
  private async subscribeTimeTickEvent() {
    this.hasRegisteredCommonEvent = true;
    try {
      let subscribeInfo: commonEventManager.CommonEventSubscribeInfo = {
        events: [commonData.STR.COMMON_EVENT_TIME_TICK]
      };
      let res: commonEventManager.CommonEventSubscriber = await commonEventManager.createSubscriber(subscribeInfo);
      HiLog.i(TAG, `subscribeTimeTickEvent`)
      this.timeTickEventData = res;
      commonEventManager.subscribe(this.timeTickEventData, (err, data) => {
        if (data == null) {
          HiLog.w(TAG, 'subscribeTimeTickEvent, data or data.data is null, return');
          return;
        }
        this.publishRefresh();
      });
    } catch (err) {
      HiLog.e(TAG, `subscribeTimeTickEvent failed, code is ${err?.code}, message is ${err?.message}`);
    }
  }

  /**
   * 解注册系统公共事件
   */
  private unSubscribeTimeTickEvent() {
    if (this.timeTickEventData) {
      try {
        commonEventManager.unsubscribe(this.timeTickEventData, () => {
          HiLog.i(TAG, 'unsubscribe timeTickEventData, success');
          this.timeTickEventData = undefined;
          this.hasRegisteredCommonEvent = false;
        });
      } catch (err) {
        HiLog.e(TAG, `unSubscribeTimeTickEvent failed, code is ${err?.code}, message is ${err?.message}`);
      }
    }
  }

  /**
   * 注册时间刷新监听
   *
   * @param key 唯一元素
   * @param callback 回调
   */
  public subscribeTimeRefresh(key: string, callback: Function) {
    HiLog.i(TAG, `subscribeTimeRefresh: ${key}`);
    if (!this.hasRegisteredCommonEvent) {
      this.subscribeTimeTickEvent();
    }
    this.refreshMap.set(key, callback)
  }

  /**
   * 注册时间刷新监听，仅刷新两天内的
   * @param key 唯一元素
   * @param time 对应时间
   * @param callback 回调
   */
  public subscribeTimeRefreshFilter(key: string, time: number, callback: Function) {
    let isInTwoDays = DateUtil.isDateInTwoDays(time);
    if (isInTwoDays) {
      this.subscribeTimeRefresh(key, callback);
    }
  }

  /**
   * 解注册时间刷新监听
   * @param key 唯一元素
   */
  public unsubscribeTimeRefresh(key: string) {
    this.refreshMap.remove(key);
  }

  /**
   * 当首页销毁时，清理数据
   */
  public onDestroy() {
    this.unSubscribeTimeTickEvent();
    this.refreshMap.clear();
  }
}