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
import simCardService from '../../../main/js/default/service/SimCardService.js';
import {describe, beforeAll, beforeEach, afterEach, afterAll, it, expect} from 'deccjsunit/index';

describe('conversationTest', function () {
    it('simInfoHandler', 0, function () {
        simCardService.simInfoHandler();
    })
    it('querySmscNumber', 0, function () {
        let actionData = {};
        simCardService.querySmscNumber(actionData, res => {
            if(res.code == 0) {
                expect(res.code).assertEqual('0');
                expect(res.smsNumber).assertEqual('1990923445');
            } else {
                expect(res.code).assertEqual('-1');
            }
        });
    })
    it('queryMessageInSimCard', 0, function () {
        let actionData = {};
        actionData.simCount = 1;
        actionData.index = 0;
        simCardService.queryMessageInSimCard(actionData, res => {
            if(res.code == 0) {
                expect(res.code).assertEqual('0');
                expect(res.content).assertEqual('');
            } else {
                expect(res.code).assertEqual('-1');
            }
        });
    })
    it('delSimMessage',0,function(){
        let actionData= {}
        actionData.index = 0;
        actionData.indexOnSim = 0;
        simCardService.delSimMessage(actionData);
    })
})