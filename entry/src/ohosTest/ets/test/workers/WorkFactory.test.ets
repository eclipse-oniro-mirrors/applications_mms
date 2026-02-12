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
import { describe, it, MockKit } from '@ohos/hypium';
import { MessageEvents, ThreadWorkerGlobalScope } from '@kit.ArkTS';
import WorkFactory, { WorkerType } from '../../../../main/ets/workers/WorkFactory';
import DataWorkerWrapper, { DataWorkerTask } from '../../../../main/ets/workers/DataWorkerWrapper';

export default function workFactoryTest() {
  describe('workFactoryTest', () => {

    it('workFactoryTest_getTask_if', 0, () => {
      let workerPort: ThreadWorkerGlobalScope = {} as ThreadWorkerGlobalScope;
      let message: MessageEvents = {
        data: {
          type: WorkerType.DataWorker
        }
      } as MessageEvents;

      let mocker: MockKit = new MockKit();
      mocker.mockFunc(DataWorkerTask, DataWorkerTask.getInstance);

      WorkFactory.getTask(workerPort, message);

      mocker.verify('getInstance', [workerPort]).once();

      mocker.clear(DataWorkerTask);
    })

    it('workFactoryTest_getTask_noIf', 0, () => {
      let workerPort: ThreadWorkerGlobalScope = {} as ThreadWorkerGlobalScope;
      let message: MessageEvents = {
        data: {
          type: 2
        }
      } as MessageEvents;

      let mocker: MockKit = new MockKit();
      mocker.mockFunc(DataWorkerTask, DataWorkerTask.getInstance);

      WorkFactory.getTask(workerPort, message);

      mocker.verify('getInstance', [workerPort]).never();

      mocker.clear(DataWorkerTask);
    })

    it('workFactoryTest_getWorker_if', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(DataWorkerWrapper, DataWorkerWrapper.getInstance);

      WorkFactory.getWorker(WorkerType.DataWorker);

      mocker.verify('getInstance', []).once();

      mocker.clear(DataWorkerWrapper);
    })

    it('workFactoryTest_getWorker_noIf', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(DataWorkerWrapper, DataWorkerWrapper.getInstance);

      WorkFactory.getWorker(1);

      mocker.verify('getInstance', []).never();

      mocker.clear(DataWorkerWrapper);
    })
  })
}