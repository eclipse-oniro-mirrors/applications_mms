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
import { beforeEach, describe, expect, it, MockKit, when } from '@ohos/hypium';
import LooseObject from '../../../../main/ets/data/LooseObject';
import DataShareHelper from '../../../../main/ets/model/repository/DataShareHelper';
import GroupDetailService from '../../../../main/ets/service/GroupDetailService';
import { DTGlobalContext } from '../../testability/TestAbility';
import myCommon from '@ohos.app.ability.common';
import { dataShare, dataSharePredicates, DataShareResultSet } from '@kit.ArkData';

export default function groupDetailServiceTest() {
  describe('groupDetailServiceTest', () => {

    let groupDetailService: GroupDetailService;
    let flag = 1;

    beforeEach(() => {
      groupDetailService = GroupDetailService.getTestInstance();
    })
    it('groupDetailServiceTest_getInstance', 0, () => {
      expect(typeof groupDetailService).assertEqual(typeof  GroupDetailService.getInstance());
    })

    it('groupDetailServiceTest_queryContactGroupDetail_else', 0, () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn(undefined);
      groupDetailService.queryContactGroupDetail(context, {}, (result: LooseObject) => {
        expect(result.code).assertEqual(-1);
      });
      mocker.clear(DataShareHelper.getInstance());
    })

    it('groupDetailServiceTest_queryContactGroupDetail_if', 0, () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(groupDetailService, groupDetailService.dealGroupDetail))([]).afterReturn([]);
      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve({
            rowCount: 0,
            goToNextRow: () => true,
            close: () => {
            }
          } as DataShareResultSet))
        } as dataShare.DataShareHelper);groupDetailService.queryContactGroupDetail(context, {}, (result: LooseObject) => {
        expect(result.code).assertEqual(0);
      });
      mocker.clear(groupDetailService);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('groupDetailServiceTest_dealGroupDetail', 0, () => {
      let groupDetails: Array<LooseObject> = [{
        'msgState': 0,
        'receiverNumber': '570977631',
        'startTime': '',
        'msgId': '1'
      }, {
        'msgState': 1,
        'receiverNumber': '570977632',
        'startTime': '',
        'msgId': '2'
      }, {
        'msgState': 2,
        'receiverNumber': '570977633',
        'startTime': '',
        'msgId': '3'
      }]
      let results: Array<LooseObject> = groupDetailService.dealGroupDetail(groupDetails, []);
      expect(results.length).assertEqual(3);
    })

    it('groupDetailServiceTest_queryContactList_if1_noIf2', 0, () => {
      flag = 1;
      let context = DTGlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve({
            rowCount: 1,
            goToNextRow: () => flag-- == 0 ? false : true,
            close: () => {
            },
            getString: (columnIndex: number): string => '',
            getColumnIndex: (columnName: string): number => 0,
            columnNames: ['']
          } as DataShareResultSet))
        });
      groupDetailService.queryContactList(context, {}, (result: LooseObject) => {});
      expect(groupDetailService).not().assertUndefined();
      mocker.clear(DataShareHelper.getInstance());
    })

    it('groupDetailServiceTest_queryContactList_if1_if2', 0, () => {
      flag = 1;
      let context = DTGlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve({
            rowCount: 1,
            goToNextRow: () => flag-- == 0 ? false : true,
            close: () => {
            },
            getString: (columnIndex: number): string => '888,999',
            getColumnIndex: (columnName: string): number => 0,
            columnNames: ['']
          } as DataShareResultSet))
        });
      groupDetailService.queryContactList(context, {}, (result: LooseObject) => {
        expect(result.code).assertEqual(0);
      });
      mocker.clear(DataShareHelper.getInstance());
    })

    it('groupDetailServiceTest_queryContactList_if1_else', 0, () => {
      flag = 1;
      let context = DTGlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve({
            rowCount: 0,
            goToNextRow: () => flag-- == 0 ? false : true,
            close: () => {
            },
            getString: (columnIndex: number): string => '',
            getColumnIndex: (columnName: string): number => 0,
            goToFirstRow: () => true,
            columnNames: ['']
          } as DataShareResultSet))
        });
      groupDetailService.queryContactList(context, {
        'telephone_like': '',
        'telephones': ['888']
      }, (result: LooseObject) => {
        expect(result.code).assertEqual(0);
      });
      mocker.clear(DataShareHelper.getInstance());
    })

    it('groupDetailServiceTest_queryContactList_else', 0, () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn(undefined);
      groupDetailService.queryContactList(context, {}, (result: LooseObject) => {
        expect(result.code).assertEqual(-1);
        expect(result.contactList.length).assertEqual(0);
      });
      mocker.clear(DataShareHelper.getInstance());
    })
  })
}