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
import myStarService from '../../../main/js/default/service/MyStarService.js';
import {describe, beforeAll, beforeEach, afterEach, afterAll, it, expect} from 'deccjsunit/index';

describe('myStarServiceTest', function () {
    it('queryFavoriteMessageList', 0, function () {
        let actionData = {};
        myStarService.queryFavoriteMessageList(actionData, res => {
            if(res.code == 0) {
                expect(res.code).assertEqual('0');
                expect(res.abilityResult.length).assertEqual('8');
            } else {
                expect(res.code).assertEqual('-1');
            }
        });
    })
    it('calculateChecked', 0, function () {
        let mmsList = [
            {
                image: '/common/icon/pin.png',
                date: '12月23日',
                time: '下午4:28',
                content: 'bcndfisdas',
                isCbChecked: false,
                msgType: [0],
                type: 1,
                address: '12324',
                isMsm: false
            },{
                image: '/common/icon/pin.png',
                date: '12月24日',
                time: '下午5:28',
                content: 'uasbajkka',
                isCbChecked: false,
                msgType: [0],
                type: 1,
                address: '12324',
                isMsm: false
            }
        ];
        let isAllSelect = false;
        let result = myStarService.calculateChecked(mmsList, isAllSelect);
        if(result) {
            expect(result.count).assertEqual('2');
            expect(result.textCount).assertEqual('1');
            expect(result.mmsCount).assertEqual('0');
        }
    })
    it('textCopy', 0, function () {
        let mmCheckedList = [
            {
                image: '/common/icon/pin.png',
                date: '12月23日',
                time: '14:28',
                content: 'asasa',
                isCbChecked: true,
                msgType: [0,1],
                msgUriPath: '/common/icon/test.jpg',
                type: 0,
                address: '',
                isMsm: true
            }
        ];
        myStarService.textCopy(mmCheckedList);
    })
    it('saveImage', 0, function () {
        let actionData = {};
        myStarService.saveImage(actionData, res => {
            if(res.code == 0) {
                expect(res.code).assertEqual('0');
                expect(res.filePath).assertEqual('/common/icon/test.jpg');
            } else {
                expect(res.code).assertEqual('-1');
            }
        });
    })
    it('favoriteShare', 0, function () {
        let actionData = {}
        myStarService.favoriteShare(actionData, res => {
            if(res.code == 0) {
                expect(res.code).assertEqual('0');
            } else {
                expect(res.code).assertEqual('-1');
            }
        });
    })
})