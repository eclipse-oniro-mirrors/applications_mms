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
import conversationListService from '../../../main/js/default/service/ConversationListService.js';
import {describe, beforeAll, beforeEach, afterEach, afterAll, it, expect} from 'deccjsunit/index'

describe('conversationListServiceTest', function () {
    it('queryAllMms', 0, function () {
        // 不传参数,只有分页数,查询所有的信息会话列表
        let actionData = {};
        actionData.page = 0;
        actionData.limit = 10;
        conversationListService.queryAllMms(actionData, res => {
            if(res.code == 0) {
                expect(res.code).assertEqual('0');
                expect(res.hasInfoMsg).assertEqual(true);
                expect(res.total).assertEqual('7');
                expect(res.isShowContactHeadIcon).assertEqual(true);
            } else {
                expect(res.code).assertEqual('-1');
            }
        });

        // 查询通知信息会话列表
        let actionDataTwo = {};
        actionDataTwo.numberType = 2;
        actionData.page = 0;
        actionData.limit = 10;
        conversationListService.queryAllMms(actionDataTwo, res => {
            if(res.code == 0) {
                expect(res.code).assertEqual('0');
                expect(res.hasInfoMsg).assertEqual(true);
                expect(res.total).assertEqual('3');
                expect(res.isShowContactHeadIcon).assertEqual(true);
            } else {
                expect(res.code).assertEqual('-1');
            }
        });
    })
    it('statisticalData', 0, function () {
        let actionData = {};
        // 统计未读短信的数量
        conversationListService.statisticalData(actionData, res => {
            if(res.code == 0) {
                expect(res.code).assertEqual('0');
                expect(res.response.totalListCount).assertEqual('10');
                expect(res.response.unreadCount).assertEqual('1');
                expect(res.response.unreadTotalOfInfo).assertEqual('0');
            } else {
                expect(res.code).assertEqual('-1');
            }
        });
    })
    it('deleteMessage', 0, function () {
        let actionData = {};
        // 会话主键ID
        actionData.threadIds = ['1','2','3'];
        // 删除会话列表
        conversationListService.deleteMessage(actionData);
    })
    it('markAllAsRead', 0, function () {
        let actionData = {};
        actionData.threadIds = ['1','2','3'];
        conversationListService.markAllAsRead(actionData);
    })
    it('searchMessageWithLike', 0, function () {
        // 根据手机号模糊查询
        let actionData = {};
        actionData.inputValue = '123';
        conversationListService.searchMessageWithLike(actionData, res => {
            if(res.code == 0) {
                expect(res.code).assertEqual('0');
                expect(res.response.sessionList.length).assertEqual('0');
                expect(res.response.contentList.length).assertEqual('2');
                expect(res.response.searchText).assertEqual(actionData.inputValue);
            } else {
                expect(res.code).assertEqual('-1');
            }
        });

        // 根据联系人名称模糊查询
        let actionDataTwo = {};
        actionDataTwo.inputValue = 'a';
        conversationListService.searchMessageWithLike(actionDataTwo, res => {
            if(res.code == 0) {
                expect(res.code).assertEqual('0');
                expect(res.response.sessionList.length).assertEqual('0');
                expect(res.response.contentList.length).assertEqual('1');
                expect(res.response.searchText).assertEqual(actionData.inputValue);
            } else {
                expect(res.code).assertEqual('-1');
            }
        });

        // 根据短信内容模糊查询
        let actionDataThird = {};
        actionDataTwo.inputValue = 'b';
        conversationListService.searchMessageWithLike(actionDataThird, res => {
            if(res.code == 0) {
                expect(res.code).assertEqual('0');
                expect(res.response.sessionList.length).assertEqual('3');
                expect(res.response.contentList.length).assertEqual('2');
                expect(res.response.searchText).assertEqual(actionData.inputValue);
            } else {
                expect(res.code).assertEqual('-1');
            }
        });
    })
    it('getSessionList', 0, function () {
        // 根据手机号，模糊查询会话列表的数据
        let searchText = '213';
        let sessionList = conversationListService.getSessionList(searchText);
        if(sessionList.length > 0) {
            expect(sessionList.length).assertEqual('1.0');
        } else {
            expect(sessionList.length).assertEqual('0');
        }
    })
    it('getContentList', 0, function () {
        // 根据短信内容，模糊查询短信列表的数据
        let searchText = 'sa';
        let contentList = conversationListService.getContentList(searchText);
        if(contentList.length > 0) {
            expect(contentList.length).assertEqual('1.0');
        } else {
            expect(contentList.length).assertEqual('0');
        }
    })
})