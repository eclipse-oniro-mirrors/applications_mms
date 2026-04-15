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
import { workScheduler, WorkSchedulerExtensionAbility } from '@kit.BackgroundTasksKit';
import dotStateFunc from './dotStateFunc';
import HiLog from '../HiLog';

const TAG = 'workScheduler';

export default class MmsReporterWorkSchedulerAbility extends WorkSchedulerExtensionAbility {
  // 延迟任务开始回调
  onWorkStart(workInfo: workScheduler.WorkInfo) {
    HiLog.i(TAG, `onWorkStart, workInfo-mms = ${JSON.stringify(workInfo)}`);
    dotStateFunc.getInstance().getSmartSwitchValue();
    dotStateFunc.getInstance().getRcsSwitchValue();
    dotStateFunc.getInstance().getAggregateSwitchValue();
    dotStateFunc.getInstance().showContactIconValue();
    dotStateFunc.getInstance().getDeliverReportSwitchValue();
  }

  // 延迟任务结束回调
  onWorkStop(workInfo: workScheduler.WorkInfo) {
    HiLog.i(TAG, `onWorkStop, workInfo is ${JSON.stringify(workInfo)}`);
  }
}