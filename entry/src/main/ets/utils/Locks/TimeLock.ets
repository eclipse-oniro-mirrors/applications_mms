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
import { systemDateTime } from '@kit.BasicServicesKit';
import HiLog from '../HiLog';
import { DataShareExtensionAbility } from '@kit.ArkData';

const TAG = 'TimeLock'


class CancelTimeLockBase {
    public readonly lockName: string = 'unKnow'
    //超时保护锁，当超时之后自动放行。
    public timeThresholdMillisecond: number = 1500
    protected lastLockTime: number = -1;
    private lockFlag: boolean = false;

    protected constructor(lockName: string, timeThresholdMillisecond: number) {
        this.lockName = lockName
        this.timeThresholdMillisecond = timeThresholdMillisecond
    }

    /*
      applicant: 申请锁的调用者信息
     * */
    public setLock(applicant: string) {
        //设置锁之后，约定的时间范围之内锁都不会被释放掉。
        this.lastLockTime = systemDateTime.getTime(false)
        this.lockFlag = true
        HiLog.i(TAG, '' + applicant + ' want add lock to ' + this.lockName + 'lock time: ' + this.lastLockTime)
    }

    /*
      applicant: 释放锁的调用者信息
     * */
    public freeLock(applicant: string) {
        HiLog.i(TAG, '' + applicant + ' want free ' + this.lockName)
        this.lockFlag = false
    }

    /*
        调用: applicant: 获得锁的调用者信息
      * 返回: ture表示没有被锁，可以执行取消通知操作。
     * */
    public queryIsUnlocked(applicant: string): boolean {
        let nowTimeMillisecond = systemDateTime.getTime(false)
        if (nowTimeMillisecond >= this.lastLockTime + this.timeThresholdMillisecond || !this.lockFlag) {
            HiLog.i(TAG,
                '' + applicant + ' query ' + this.lockName + ' status , query time: ' + nowTimeMillisecond +
                    ' success ' +
                    ' interval time is(ms): ' + (nowTimeMillisecond - this.lastLockTime))
            return true
        }
        HiLog.i(TAG,
            '' + applicant + ' query ' + this.lockName + '  status , query time: ' + nowTimeMillisecond + ' failure ' +
                ' interval time is(ms): ' + (nowTimeMillisecond - this.lastLockTime))
        return false
    }
}

export class CancelNotificationTimeLock extends CancelTimeLockBase {
    private static mInstance: CancelNotificationTimeLock | undefined = undefined;

    public static getInstance(): CancelNotificationTimeLock {
        if (!CancelNotificationTimeLock.mInstance) {
            CancelNotificationTimeLock.mInstance = new CancelNotificationTimeLock('CancelNotificationTimeLock', 1500)
        }
        return CancelNotificationTimeLock.mInstance as CancelNotificationTimeLock
    }
}