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

import { WorkerType } from '../WorkFactory';
import worker from '@ohos.worker';
import HiLog from '../../utils/HiLog';

const TAG = 'WorkerWrapper';

export class WorkerMessage {
  request: string = '';
  callBackId: number = -1;
  type?: WorkerType;
  param?: Object;
}

/*
 * WorkerWrapper
 *
 * Processes sending tasks to workers and receiving work processing results.
 */
export abstract class WorkerWrapper {
  protected mWorker?: worker.ThreadWorker | null;
  private callBacks: Map<string, (result: Object) => void> = new Map();
  private requestIndex: number = 0;

  constructor() {
    this.initWorker();
  }

  async initWorker() {
    HiLog.i(TAG, `WorkerWrapper initWorker ${WorkerType[this.getWorkerType()]}`);
    let initWorker = await new worker.ThreadWorker('entry/ets/workers/base/Worker.ets', {
      name: WorkerType[this.getWorkerType()]
    });
    let that = this;
    initWorker.onexit = (message) => {
      HiLog.w(TAG, 'onexit');
      that.mWorker = null;
    };
    initWorker.onerror = (e) => {
      HiLog.w(TAG, 'onerror:' + JSON.stringify(e));
    };
    initWorker.onmessageerror = (e) => {
      HiLog.w(TAG, 'onmessageerror:' + JSON.stringify(e));
    };
    initWorker.onmessage = (message) => {
      let data = message.data as WorkerMessage;
      const key = that.getCallBackKey(data);
      if (that.callBacks.has(key)) {
        const callback = that.callBacks.get(key);
        if (callback) {
          callback(data.param as Object);
        }
        that.callBacks.delete(key);
      }
    };
    this.mWorker = initWorker;
    HiLog.i(TAG, 'WorkerWrapper initWorker end');
  }

  public abstract getWorkerType(): WorkerType;

  /**
   * SendRequest to worker thread.
   *
   * @param {string} request the request worker to do
   * @param {Object} requestData  request param Data
   * @param {Object} callBack Call back from worker
   */
  public async sendRequest(request: string, requestData?: Object, callBack?: (result: Object) => void) {
    if (this.mWorker) {
      const message: WorkerMessage = {
        request: request,
        callBackId: this.requestIndex,
        type: this.getWorkerType(),
        param: requestData
      }
      if (callBack) {
        this.callBacks.set(this.getCallBackKey(message), callBack);
      }
      try {
        this.mWorker?.postMessage(message);
        HiLog.d(TAG, `${this.getWorkerType()} ${request} send succ!`);
        this.requestIndex++;
      } catch (e) {
        HiLog.e(TAG, `sendRequest err : ${JSON.stringify(e)}`);
      }
    } else {
      HiLog.w(TAG, `${this.getWorkerType()} ${request} send fail, worker has been closed!`);
    }
  }

  /**
   * Close  close worker thread.
   */
  public close(): void {
    HiLog.i(TAG, `${this.getWorkerType()} worker close!`);
    if (this.mWorker != null) {
      this.mWorker.terminate();
    }
    this.mWorker = null;
    this.callBacks.clear();
  }

  private getCallBackKey(message: WorkerMessage): string {
    return message.request + message.callBackId;
  }
}

export default WorkerWrapper;