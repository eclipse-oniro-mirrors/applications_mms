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
import groupDetailService from '../../../main/js/default/service/GroupDetailService.js';
import {describe, beforeAll, beforeEach, afterEach, afterAll, it, expect} from 'deccjsunit/index';

describe('groupDetailServiceTest', function () {
    it('judgeIsAllSendFail', 0, function () {
        let contactList = [
            {
                contactName: 'aaedd',
                date: '4月23日星期五',
                isDraft: false,
                isLock: false,
                isReceive: false,
                sendStatus: 2,
                telephone: '1003',
                telephoneFormat: '1003',
                time: '上午10:20',
                timeMillisecond: 1619144409755
            }
        ];
        groupDetailService.judgeIsAllSendFail(contactList, res => {
            expect(res.isAllSendFail).assertEqual(true);
        });

        let contactListTwo = [
            {
                contactName: 'tosaa',
                date: '4月23日星期五',
                isDraft: false,
                isLock: false,
                isReceive: false,
                sendStatus: 0,
                telephone: '2323',
                telephoneFormat: '213232',
                time: '上午10:16',
                timeMillisecond: 1619144179154
            }
        ];
        groupDetailService.judgeIsAllSendFail(contactListTwo, res => {
            expect(res.isAllSendFail).assertEqual(false);
        });
    })
    it('queryContactSendDetail', 0, function () {
        // 获取收件人信息
        let isDetail = false;
        let actionData = {};
        actionData.threadId = 1;
        groupDetailService.queryContactSendDetail(isDetail, actionData, res=>{
            if(res.code == 0) {
                expect(res.code).assertEqual('0');
                expect(res.contactList.length).assertEqual('5');
            } else {
                expect(res.code).assertEqual('-1');
            }
        });

        // 获取群发详情
        isDetail = true;
        let actionDataTwo = {};
        actionDataTwo.groupId = 1;
        groupDetailService.queryContactSendDetail(isDetail, actionData, res=>{
            if(res.code == 0) {
                expect(res.code).assertEqual('0');
                expect(res.contactList.length).assertEqual('4');
            } else {
                expect(res.code).assertEqual('-1');
            }
        });
    })
})