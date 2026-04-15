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

import HiLog from './HiLog';
import { taskpool } from '@kit.ArkTS';
import LooseObject from '../data/LooseObject';
// import rcs from '@ohos.telephony.rcs';

const TAG = 'RcsLoginUtil';

@Concurrent
export async function rcsLoggedIn(isRcsSetting: boolean): Promise<boolean> {
  try {
    //如果关闭isRcsOpen就为false 否则走isRcsLoggedIn的逻辑
    // return isRcsSetting ? rcs.isRcsLoggedIn() : false;
    return  false;
  } catch (err) {
    HiLog.e('RcsLoginUtil', 'onRcsStateChange err: ' + err);
  }
  return false;
}


export class RcsLoginUtil {
  private static sInstance: RcsLoginUtil;

  static getInstance() {
    if (RcsLoginUtil.sInstance == null) {
      HiLog.i(TAG, 'getInstance');
      RcsLoginUtil.sInstance = new RcsLoginUtil();
    }
    return RcsLoginUtil.sInstance;
  }

  public getRcsLoggedInTaskPool(isRcsSetting: boolean, callback: Function) {
    let task = new taskpool.Task(rcsLoggedIn, isRcsSetting);
    taskpool.execute(task).then((res: LooseObject) => {
      callback(res);
    })
  }
}