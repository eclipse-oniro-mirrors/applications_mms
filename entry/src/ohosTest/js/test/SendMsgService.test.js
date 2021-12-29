/**
 * Copyright (c) 2021 Huawei Device Co., Ltd.
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
import sendMsgService from '../../../main/js/default/service/SendMsgService.js';
import {describe, beforeAll, beforeEach, afterEach, afterAll, it, expect} from 'deccjsunit/index';

describe('sendMsgServiceTest', function () {
    it('sendMessage', 0, function () {
        let params = {
            slotId: 1,
            destinationHost: '10032322',
            content: 'I love you',
        };
        sendMsgService.sendMessage(params, sendStatus => {
            if (sendStatus === 0) {
                // 发送成功
                expect(sendStatus).assertEqual('0');
            } else {
                // 发送失败
                expect(sendStatus).assertEqual('2');
            }
        });
    })
})