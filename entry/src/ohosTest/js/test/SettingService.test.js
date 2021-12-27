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
import settingService from '../../../main/js/default/service/SettingService.js';
import {describe, beforeAll, beforeEach, afterEach, afterAll, it, expect} from 'deccjsunit/index';

describe('settingServiceTest', function () {
    it('setOnSettingValueListener', 0, function () {
        settingService.setOnSettingValueListener(res => {
            expect(res.integrationSwitch).assertEqual(false);
            expect(res.maliciousWebSwitch).assertEqual(false);
            expect(res.showContactSwitch).assertEqual(false);
            expect(res.integrationSwitch).assertEqual(true);
            expect(res.maliciousWebSwitch).assertEqual(true);
            expect(res.showContactSwitch).assertEqual(true);
        });
    })
    it('restoreSwitchValue', 0, function () {
        settingService.restoreSwitchValue(res => {
            if(res.code == 0) {
                expect(res.code).assertEqual('0');
            } else {
                expect(res.code).assertEqual('-1');
            }
        });
    })
    it('updateSettingValue', 0, function () {
        let actionData = {};
        actionData.intValue = true;
        // 送达报告
        let code = 32001;
        actionData.intValue = false;
        settingService.updateSettingValue(code, actionData, res => {
            if(res.code == 0) {
                expect(res.code).assertEqual('0');
            } else {
                expect(res.code).assertEqual('-1');
            }
        });

        // 自动下载彩信
        code = 32002;
        settingService.updateSettingValue(code, actionData, res => {
            if(res.code == 0) {
                expect(res.code).assertEqual('0');
            } else {
                expect(res.code).assertEqual('-1');
            }
        });

        // 取消发送
        code = 32003;
        settingService.updateSettingValue(code, actionData, res => {
            if(res.code == 0) {
                expect(res.code).assertEqual('0');
            } else {
                expect(res.code).assertEqual('-1');
            }
        });

        // 自动删除通知信息
        code = 32004;
        settingService.updateSettingValue(code, actionData, res => {
            if(res.code == 0) {
                expect(res.code).assertEqual('0');
            } else {
                expect(res.code).assertEqual('-1');
            }
        });
    })
    it('getAdvancedPageSwitchValue', 0, function () {
        settingService.getAdvancedPageSwitchValue(res => {
            expect(res.deliveryReportSwitch).assertEqual(false);
            expect(res.autoRetrieveMmsSwitch).assertEqual(false);
            expect(res.recallMessageSwitch).assertEqual(false);
            expect(res.autoDeleteInfoSwitch).assertEqual(true);
            expect(res.simCount).assertEqual(false);
            expect(res.firstSpnNameOfTwoSimCard).assertEqual(false);
            expect(res.secondSpnNameOfTwoSimCard).assertEqual(false);
        });
    })
    it('updateSmscNumber', 0, function () {
        let actionData = {};
        actionData.telephone = '1093389945';
        settingService.updateSmscNumber(actionData);
    })
    it('shareSmsEnterSelectedText', 0, function () {
        let actionData = {};
        actionData.content = 'I love you';
        settingService.shareSmsEnterSelectedText(actionData);
    })
    it('getSettingFlagForConvListPage', 0, function () {
        let result = settingService.getSettingFlagForConvListPage();
        if(result) {
            expect(result.isShowContactHeadIcon).assertEqual(false);
            expect(result.hasAggregate).assertEqual(false);
            expect(result.recallMessagesFlag).assertEqual(false);
        }
    })
})