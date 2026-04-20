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
import { describe, it, expect, MockKit, when,
  ArgumentMatchers } from '@ohos/hypium'
import Constant from '../../../../../main/ets/data/Constant';
import LooseObject, { getAllKeyOfLooseObject } from '../../../../../main/ets/data/LooseObject';
import {
  QuerySmsMmsInfoActionDataFactory,
  QuerySmsMmsInfoByConditionAllActionData } from '../../../../../main/ets/model/type/QuerySmsMmsInfoActionData';
import StringUtil from '../../../../../main/ets/utils/StringUtil';
import { dataSharePredicates } from '@kit.ArkData';

export default function QuerySmsMmsInfoActionDataTest() {
  describe('QuerySmsMmsInfoActionDataTest', () => {
    it('QuerySmsMmsInfoActionDataTest_constructor_constructor', 0, () => {
      let querysmsmmsinfobyconditionallactiondata: QuerySmsMmsInfoByConditionAllActionData = new QuerySmsMmsInfoByConditionAllActionData();
      expect(querysmsmmsinfobyconditionallactiondata.fields).assertDeepEquals(['threadId', 'page', 'actionDataName', 'contactsNum', 'limit', 'offset', 'isCustomSearch']);
      expect(querysmsmmsinfobyconditionallactiondata.actionData).assertDeepEquals({});
      expect(querysmsmmsinfobyconditionallactiondata.actionDataName).assertEqual(Constant.ACTION_DATA_NAME_QUERY_SMS_MMS_INFO_ALL);
    });
    it('QuerySmsMmsInfoActionDataTest_checkLegality_keyNameSet_size_is_not_same_with_fields', 0, () => {
      let querysmsmmsinfobyconditionallactiondata: QuerySmsMmsInfoByConditionAllActionData = new QuerySmsMmsInfoByConditionAllActionData();
      querysmsmmsinfobyconditionallactiondata.actionDataName = Constant.ACTION_DATA_NAME_QUERY_SMS_MMS_INFO_ALL;
      querysmsmmsinfobyconditionallactiondata.actionData = {};
      querysmsmmsinfobyconditionallactiondata.fields = ['threadId', 'page', 'actionDataName', 'contactsNum', 'limit', 'offset', 'isCustomSearch'];
      const result: ESObject = querysmsmmsinfobyconditionallactiondata.checkLegality();
      expect(result).assertEqual(false);
    });

    it('QuerySmsMmsInfoActionDataTest_checkLegality_keyNameSet_does_not_have_all_fields', 0, () => {
      let querysmsmmsinfobyconditionallactiondata: QuerySmsMmsInfoByConditionAllActionData = new QuerySmsMmsInfoByConditionAllActionData();
      querysmsmmsinfobyconditionallactiondata.actionDataName = Constant.ACTION_DATA_NAME_QUERY_SMS_MMS_INFO_ALL;
      querysmsmmsinfobyconditionallactiondata.actionData = { threadId: 1, page: 1, contactsNum: 1 };
      querysmsmmsinfobyconditionallactiondata.fields = ['threadId', 'page', 'actionDataName'];
      const result: ESObject = querysmsmmsinfobyconditionallactiondata.checkLegality();
      expect(result).assertEqual(false);
    });

    it('QuerySmsMmsInfoActionDataTest_checkLegality_actionDataName_is_not_same_with_class_actionDataName', 0, () => {
      let querysmsmmsinfobyconditionallactiondata: QuerySmsMmsInfoByConditionAllActionData = new QuerySmsMmsInfoByConditionAllActionData();
      querysmsmmsinfobyconditionallactiondata.actionDataName = Constant.ACTION_DATA_NAME_QUERY_SMS_MMS_INFO_ALL;
      querysmsmmsinfobyconditionallactiondata.actionData = { threadId: 1, page: 1, actionDataName: 'test', contactsNum: 1 };
      querysmsmmsinfobyconditionallactiondata.fields = ['threadId', 'page', 'actionDataName', 'contactsNum'];
      const result: ESObject = querysmsmmsinfobyconditionallactiondata.checkLegality();
      expect(result).assertEqual(true);
    });

    it('QuerySmsMmsInfoActionDataTest_checkLegality_all_conditions_are_met', 0, () => {
      let querysmsmmsinfobyconditionallactiondata: QuerySmsMmsInfoByConditionAllActionData = new QuerySmsMmsInfoByConditionAllActionData();
      querysmsmmsinfobyconditionallactiondata.actionDataName = Constant.ACTION_DATA_NAME_QUERY_SMS_MMS_INFO_ALL;
      querysmsmmsinfobyconditionallactiondata.actionData = { threadId: 1, page: 1, actionDataName: Constant.ACTION_DATA_NAME_QUERY_SMS_MMS_INFO_ALL, contactsNum: 1 };
      querysmsmmsinfobyconditionallactiondata.fields = ['threadId', 'page', 'actionDataName', 'contactsNum'];
      const result: ESObject = querysmsmmsinfobyconditionallactiondata.checkLegality();
      expect(result).assertEqual(true);
    });
    it('QuerySmsMmsInfoActionDataTest_loadData_checkLegality_returns_false', 0, async () => {
      let querysmsmmsinfobyconditionallactiondata: QuerySmsMmsInfoByConditionAllActionData = new QuerySmsMmsInfoByConditionAllActionData();
      let mocker: MockKit = new MockKit();
      let mockfunc: Function = mocker.mockFunc(querysmsmmsinfobyconditionallactiondata, querysmsmmsinfobyconditionallactiondata.checkLegality);
      when(mockfunc)([]).afterReturn(false);
      let actionData: LooseObject = {};
      const result: ESObject = querysmsmmsinfobyconditionallactiondata.loadData(actionData);
      expect(result).assertUndefined();
      mocker.ignoreMock(querysmsmmsinfobyconditionallactiondata, querysmsmmsinfobyconditionallactiondata.checkLegality);
    });

    it('QuerySmsMmsInfoActionDataTest_loadData_checkLegality_returns_true', 0, async () => {
      let querysmsmmsinfobyconditionallactiondata: QuerySmsMmsInfoByConditionAllActionData = new QuerySmsMmsInfoByConditionAllActionData();
      let mocker: MockKit = new MockKit();
      let mockfunc: Function = mocker.mockFunc(querysmsmmsinfobyconditionallactiondata, querysmsmmsinfobyconditionallactiondata.checkLegality);
      when(mockfunc)([]).afterReturn(true);
      let actionData: LooseObject = {'msgId': 0,};
      const result: boolean = querysmsmmsinfobyconditionallactiondata.loadData(actionData);
      expect(result).assertUndefined();
      mocker.ignoreMock(querysmsmmsinfobyconditionallactiondata, querysmsmmsinfobyconditionallactiondata.checkLegality);
    });

    it('QuerySmsMmsInfoActionDataTest_loadData_actionData_is_valid', 0, async () => {
      let querysmsmmsinfobyconditionallactiondata: QuerySmsMmsInfoByConditionAllActionData = new QuerySmsMmsInfoByConditionAllActionData();
      let mocker: MockKit = new MockKit();
      let mockfunc: Function = mocker.mockFunc(querysmsmmsinfobyconditionallactiondata, querysmsmmsinfobyconditionallactiondata.checkLegality);
      when(mockfunc)([]).afterReturn(true);
      let actionData: LooseObject = {
        key1: 'value1',
        key2: 'value2'
      };
      querysmsmmsinfobyconditionallactiondata.checkLegality();
      const result: boolean = querysmsmmsinfobyconditionallactiondata.loadData(actionData);
      expect(result).assertUndefined()
      mocker.ignoreMock(querysmsmmsinfobyconditionallactiondata, querysmsmmsinfobyconditionallactiondata.checkLegality);
    });
    it('QuerySmsMmsInfoActionDataTest_buildQueryCondition', 0, async () => {
      let querysmsmmsinfobyconditionallactiondata: QuerySmsMmsInfoByConditionAllActionData = new QuerySmsMmsInfoByConditionAllActionData();
      querysmsmmsinfobyconditionallactiondata.actionData = {
        threadId: 123,
        page: 2,
        contactsNum: 50
      };
      querysmsmmsinfobyconditionallactiondata.fields = ['threadId', 'page', 'actionDataName', 'contactsNum', 'limit', 'offset', 'isCustomSearch'];

      let mocker: MockKit = new MockKit();

      let mockGetLimitForSmsMmsInfo: Function = mocker.mockFunc(StringUtil, StringUtil.getLimitForSmsMmsInfo);
      when(mockGetLimitForSmsMmsInfo)([ArgumentMatchers.anyNumber, ArgumentMatchers.anyNumber]).afterReturn(10);

      let mockGetOffsetForSmsMmsInfo: Function = mocker.mockFunc(StringUtil, StringUtil.getOffsetForSmsMmsInfo);
      when(mockGetOffsetForSmsMmsInfo)([ArgumentMatchers.anyNumber, ArgumentMatchers.anyNumber]).afterReturn(0);

      let mockEqualTo: Function = mocker.mockFunc(dataSharePredicates.DataSharePredicates, dataSharePredicates.DataSharePredicates.prototype.equalTo);
      when(mockEqualTo)([ArgumentMatchers.anyString, ArgumentMatchers.any]).afterReturn(new dataSharePredicates.DataSharePredicates());

      let mockAnd: Function = mocker.mockFunc(dataSharePredicates.DataSharePredicates, dataSharePredicates.DataSharePredicates.prototype.and);
      when(mockAnd)([]).afterReturn(new dataSharePredicates.DataSharePredicates());

      let mockLimit: Function = mocker.mockFunc(dataSharePredicates.DataSharePredicates, dataSharePredicates.DataSharePredicates.prototype.limit);
      when(mockLimit)([ArgumentMatchers.anyNumber, ArgumentMatchers.anyNumber]).afterReturn(new dataSharePredicates.DataSharePredicates());
      let res = querysmsmmsinfobyconditionallactiondata.buildQueryCondition();
      expect(res).not().assertUndefined()
      mocker.ignoreMock(StringUtil, StringUtil.getLimitForSmsMmsInfo);
      mocker.ignoreMock(StringUtil, StringUtil.getOffsetForSmsMmsInfo);
      mocker.ignoreMock(dataSharePredicates.DataSharePredicates, dataSharePredicates.DataSharePredicates.prototype.equalTo);
      mocker.ignoreMock(dataSharePredicates.DataSharePredicates, dataSharePredicates.DataSharePredicates.prototype.and);
      mocker.ignoreMock(dataSharePredicates.DataSharePredicates, dataSharePredicates.DataSharePredicates.prototype.limit);
    });
    it('QuerySmsMmsInfoActionDataTest_create_actionData_actionDataName_is_ACTION_DATA_NAME_QUERY_SMS_MMS_INFO_ALL', 0, () => {
      let actionData: LooseObject = {
        actionDataName: Constant.ACTION_DATA_NAME_QUERY_SMS_MMS_INFO_ALL
      };
      QuerySmsMmsInfoActionDataFactory.create(actionData);
      expect(actionData.actionDataName).assertEqual(Constant.ACTION_DATA_NAME_QUERY_SMS_MMS_INFO_ALL);
    });

    it('QuerySmsMmsInfoActionDataTest_create_actionData_actionDataName_is_not_ACTION_DATA_NAME_QUERY_SMS_MMS_INFO_ALL', 0, () => {
      let actionData: LooseObject = {
        actionDataName: 'some_other_name'
      };
      const result: ESObject = QuerySmsMmsInfoActionDataFactory.create(actionData);
      expect(result).assertUndefined();
    });

    it('QuerySmsMmsInfoActionDataTest_create_actionData_is_null', 0, () => {
      let actionData: LooseObject = {};
      const result: ESObject = QuerySmsMmsInfoActionDataFactory.create(actionData);
      expect(result).assertUndefined();
    });

  })
}