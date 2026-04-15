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

import common from '../data/commonData';
import LooseObject from '../data/LooseObject';
import { GlobalContext } from '../MainAbility/GlobalHelper';
import { WorkerWrapper } from '../workers/base/WorkerWrapper';
import { ValuesBucket } from '@ohos.data.ValuesBucket';
import UnlockConversationModel from '../model/UnlockConversationModel';

interface ConversationServiceParamType {
  valueBucket: ValuesBucket,
  context: Context
  actionData: LooseObject
}

export interface queryMmsInfoResult {
  code: number,
  abilityResult: Array<Record<string, number | string>>
}

const TAG: string = 'UnlockConversationService';

// 适配屏幕解锁公共事件性能优化，请勿增加其他业务
export default class UnlockConversationService {
  private static instance: UnlockConversationService;
  private unlockConversationModel: UnlockConversationModel = new UnlockConversationModel();
  public maxGroupId: number = 0;


  public static getInstance(): UnlockConversationService {
    if (UnlockConversationService.instance == null) {
      UnlockConversationService.instance = new UnlockConversationService();
    }
    return UnlockConversationService.instance;
  }

  public statisticalData(callback: Function, context: Context) {
    if (GlobalContext.getContext().getObject('DataWorker') != null) {
      (GlobalContext.getContext()
        .getObject('DataWorker') as WorkerWrapper).sendRequest(common.RUN_IN_WORKER_METHOD.statisticalData, {
        context: context
      } as ConversationServiceParamType, (res?: Object) => {
        callback(res);
      });
    } else {
      this.unlockConversationModel.statisticalData(callback, context);
    }
  }
}