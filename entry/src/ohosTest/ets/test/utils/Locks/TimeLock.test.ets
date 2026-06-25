/**
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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
import { ArgumentMatchers, describe, expect, it, MockKit, when } from '@ohos/hypium';
import { CancelNotificationTimeLock } from '../../../../../main/ets/utils/Locks/TimeLock';


export default function TimeLockTest() {
    describe("TimeLockTest", () => {

        const TAG: string = 'TimeLock';

        it('blockedUtilTest_CancelNotificationTimeLock', 0, () => {
            let tarLock: CancelNotificationTimeLock = CancelNotificationTimeLock.getInstance();
            expect(tarLock.lockName).assertEqual('CancelNotificationTimeLock');
            let nextTarLock: CancelNotificationTimeLock = CancelNotificationTimeLock.getInstance();
            //测试是否是单实例
            expect(tarLock).assertEqual(nextTarLock);
        })

        it('blockedUtilTest_queryIsUnlocked_locked', 0, () => {
            let tarLock: CancelNotificationTimeLock = CancelNotificationTimeLock.getInstance();
            tarLock.setLock('TimeLockTest')
            //测试锁已经被锁上了，无法执行后续操作。
            expect(tarLock.queryIsUnlocked('TimeLockTest')).assertFalse();
        })


        it('blockedUtilTest_queryIsUnlocked_unlocked', 0, () => {
            let tarLock: CancelNotificationTimeLock = CancelNotificationTimeLock.getInstance();
            tarLock.freeLock('TimeLockTest')
            //测试锁能否被正确释放。
            expect(tarLock.queryIsUnlocked('TimeLockTest')).assertTrue();
        })

    })
}