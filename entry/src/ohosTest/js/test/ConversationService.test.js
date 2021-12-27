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
import conversationService from '../../../main/js/default/service/ConversationService.js';
import {describe, beforeAll, beforeEach, afterEach, afterAll, it, expect} from 'deccjsunit/index'

describe('conversationServiceTest', function () {
    it('queryMessageDetail', 0, function () {
        let params = {};
        params.telephone = '10086';
        params.page = 0;
        params.limit = 10;
        // 根据手机号精确查询短信列表
        conversationService.queryMessageDetail(params, res => {
            if(res.code == 0) {
                expect(res.code).assertEqual('0');
                expect(res.canSendMessage).assertEqual(true);
                expect(res.response.length).assertEqual('5');
            } else {
                expect(res.code).assertEqual('-1');
            }
        });
    })
    it('getTransmitContracts', 0, function () {
        let params = {};
        conversationService.getTransmitContracts(params, res => {
            if(res.code == 0) {
                expect(res.code).assertEqual('0');
                expect(res.isSelectContact).assertEqual(true);
                expect(res.transmitContracts.length).assertEqual('5');
                expect(res.strSelectContact).assertEqual('张三以及其他2个');
            } else {
                expect(res.code).assertEqual('-1');
            }
        });
    })
    it('judgeContactExists', 0, function () {
        let params = {};
        params.telephone = '13643893489';
        // 判断联系人是否存在
        conversationService.judgeContactExists(params, res => {
            if(res.code == 0) {
                expect(res.code).assertEqual('0');
                expect(res.hasExitContract).assertEqual(true);
            } else {
                expect(res.code).assertEqual('-1');
            }
        });
    })
    it('saveImage', 0, function () {
        let params = {};
        // 保存图片
        conversationService.saveImage(params, res => {
            if(res != '') {
                expect(res).assertEqual('附件已保存到 path://sss ,请妥善保存');
            } else {
                expect(res).assertEqual('保存图片失败');
            }
        });
    })
    it('gotoShare', 0, function () {
        let params = {};
        // 分享
        conversationService.gotoShare(params, res => {
            if(res.code == 0) {
                expect(res.code).assertEqual('0');
            } else {
                expect(res.code).assertEqual('-1');
            }
        });
    })
    it('updateLock', 0, function () {
        let params = {};
        // 更新锁定状态
        conversationService.updateLock(params, res => {
            if(res.code == 0) {
                expect(res.code).assertEqual('0');
            } else {
                expect(res.code).assertEqual('-1');
            }
        });
    })
    it('queryFromGallery', 0, function () {
        let params = {};
        // 查询图片
        conversationService.queryFromGallery(params, res => {
            if(res.code == 0) {
                expect(res.code).assertEqual('0');
                expect(res.pictureListFromGallery.length).assertEqual('1');
            } else {
                expect(res.code).assertEqual('-1');
            }
        });
    })
})