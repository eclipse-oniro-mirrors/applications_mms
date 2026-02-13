/**
 * Copyright (c) 2022 Huawei Device Co., Ltd.
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

import emitter from '@ohos.events.emitter';
import LooseObject from '../data/LooseObject';
import cardModel from '../model/CardModel'
import HiLog from '../utils/HiLog';
import commonEventManager from '@ohos.commonEventManager';
import EmitterConstant from '../data/EmitterConstant';

const TAG: string = 'SimCardService';

class SimCardService {
  public SIM_STATE_CHANGE_EVENT: emitter.InnerEvent = {
    eventId: EmitterConstant.EVENT_SIM_STATE_CHANGE,
    priority: emitter.EventPriority.HIGH
  }
  public SLOTID_CHANGE_EVENT: emitter.InnerEvent = {
    eventId: EmitterConstant.EVENT_SLOTID_CHANGE,
    priority: emitter.EventPriority.HIGH
  }

  public init(ctx: Context): void {
    if (!cardModel) {
      HiLog.e(TAG, 'cardModel is null');
      return;
    }
    cardModel.init(ctx);
  }

  public deInit(): void {
    if (!cardModel) {
      HiLog.e(TAG, 'cardModel is null');
      return;
    }
    cardModel.deInit();
  }

  public isSimReady(slotId: number): boolean {
    if (!cardModel) {
      HiLog.e(TAG, 'cardModel is null');
      return false;
    }
    return cardModel.isSimReady(slotId);
  }
}

// Singleton
export default new SimCardService();