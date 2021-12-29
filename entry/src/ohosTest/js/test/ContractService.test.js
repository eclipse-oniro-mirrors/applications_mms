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
import contractService from '../../../main/js/default/service/ContractService.js';
import featureAbility from '@ohos.ability.featureAbility';
import ohosDataAbility from '@ohos.data.dataability';
import {describe, beforeAll, beforeEach, afterEach, afterAll, it, expect} from 'deccjsunit/index'

describe('contractServiceTest', function () {
    it('queryContact', 0, function () {
        let page = 0 ;
        let limit  = 10;
        // 全量查询
        let actionData = {
            featureAbility: featureAbility,
            ohosDataAbility: ohosDataAbility,
            page: page,
            limit:limit
        };
        contractService.queryContact(actionData, res => {
            expect(res.code).assertEqual('0');
            expect(res.response.length).assertEqual('4');
        });
    });
    it('queryContactDataByTelephone',0,function() {
        // 根据手机号精确查询
        let actionDataTwo = {
            featureAbility: featureAbility,
            ohosDataAbility: ohosDataAbility,
            telephones : ['10086','1008611']
        };
        contractService.queryContactDataByTelephone(actionDataTwo, res => {
            expect(res.code).assertEqual('0');
            expect(res.response.length).assertEqual('4');
        });
    });
    it('searchContracts',0,function() {
      // 模糊查询
      let actionData = {
          featureAbility: featureAbility,
          ohosDataAbility: ohosDataAbility,
          phone:'177'
      };
      contractService.searchContracts(actionData, res => {
          expect(res.code).assertEqual('0');
          expect(res.response.length).assertEqual('4');
      });
    });
    it('judgeIsExitProfile',0,function() {
        // 查询我的名片
        let actionData = {
            featureAbility: this.$app.$def.featureAbility,
            ohosDataAbility: this.$app.$def.ohosDataAbility,
        };
        contractService.judgeIsExitProfile(actionData,flag => {
            expect(flag).assertEqual(false);
            expect(flag).assertEqual(true);
        })
    })
})