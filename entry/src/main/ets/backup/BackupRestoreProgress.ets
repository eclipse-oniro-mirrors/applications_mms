/**
 * Copyright (c) 2024-2024 Huawei Device Co., Ltd.
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
import HiLog from '../utils/HiLog';

@Sendable
export default class BackupRestoreProgress {
  private isFinished: boolean = false;
  private progress: string = '';
  private totalCount: number = 10000; // 10000次，每次等待2s，共20000s
  private processCount: number = 0;

  public setTotalCount(value: number) {
    this.totalCount = value;
  }

  public getTotalCount(): number {
    return this.totalCount;
  }

  public updateProcessCount(value: number) {
    this.processCount = value;
  }

  public getProcessCount(): number {
    return this.processCount;
  }

  public finish() {
    this.isFinished = true;
  }

  public isFinish(): boolean {
    return this.isFinished;
  }

  public getProgress(): string {
    if (this.processCount > this.totalCount) {
      HiLog.e('BackupRestoreProgress', 'Progress is greater than total');
      this.processCount = this.totalCount;
    }
    this.progress = `{"progressInfo":[{"name":"mms","processed": ${this.processCount},"total": ${this.totalCount}}]}`;
    return this.progress;
  }

}