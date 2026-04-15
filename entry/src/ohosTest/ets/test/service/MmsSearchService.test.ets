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

import {
  describe,
  beforeEach,
  it,
  expect,
  MockKit,
  when,
  ArgumentMatchers
} from '@ohos/hypium';
import LooseObject from '../../../../main/ets/data/LooseObject'
import MmsSearchService from '../../../../main/ets/service/MmsSearchService'
import { dataShare, dataSharePredicates, DataShareResultSet } from '@kit.ArkData'
import MySet from '../MySet'
import DataShareHelper from '../../../../main/ets/model/repository/DataShareHelper'
import ConversationListService from '../../../../main/ets/service/ConversationListService'
import { BusinessError } from '@kit.BasicServicesKit'
import { ConversationListInfo } from '../../../../main/ets/model/conversationlist/ConversationListInfo'
import { DTGlobalContext } from '../../testability/TestAbility';

export default function MmsSearchServiceTest() {
  describe('MmsSearchServiceTest', () => {

    let mmsSearchService: MmsSearchService;
    let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;

    beforeEach(() => {
      mmsSearchService = new MmsSearchService();
    })

    it('MmsSearchService_getInstance(', 0, () => {
      expect(typeof mmsSearchService).assertEqual(typeof MmsSearchService.getInstance());
    })

    it('MmsSearchService_searchMessage', 0, async () => {
      let object: LooseObject = {};
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(mmsSearchService, mmsSearchService.querySessionLikeTelephone))(object)
        .afterReturn({});
      when(mocker.mockFunc(mmsSearchService, mmsSearchService.querySessionByContact))(object)
        .afterReturn({});

      when(mocker.mockFunc(Promise, Promise.all))(ArgumentMatchers.any)
        .afterReturn(new Promise<LooseObject[]>(resolve => resolve([{
          sessionList: [{
            id: 1,
            timeMillisecond: 0
          }],
          messageList: []
        }, {
          sessionList: [{
            id: 1,
            timeMillisecond: 0
          }],
          messageList: []
        }])));

      let mySet: DataShareResultSet = new MySet();
      mySet.rowCount = 1;
      when(mocker.mockFunc(DataShareHelper.getInstance(),
        DataShareHelper.getInstance().initSmsDB))(ArgumentMatchers.any)
        .afterReturn(new Promise<dataShare.DataShareHelper | undefined>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve(mySet))
        } as dataShare.DataShareHelper)));

      mocker.mockFunc(ConversationListService.getInstance(), ConversationListService.getInstance().dealContactsName);

      await mmsSearchService.searchMessage(context, object, (res: LooseObject) => {
        expect(res.code).assertEqual(0)
      });

      mocker.clear(DataShareHelper.getInstance());
      mocker.clear(mmsSearchService);
      mocker.clear(ConversationListService.getInstance());
    })

    it('MmsSearchService_searchMessage_fail', 0, async () => {
      let object: LooseObject = {};
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(mmsSearchService, mmsSearchService.querySessionLikeTelephone))(object)
        .afterReturn({});
      when(mocker.mockFunc(mmsSearchService, mmsSearchService.querySessionByContact))(object)
        .afterReturn({});

      when(mocker.mockFunc(Promise, Promise.all))(ArgumentMatchers.any)
        .afterReturn(new Promise<LooseObject[]>((resolve: (value: LooseObject[] | PromiseLike<LooseObject[]>) => void,
          reject: (reason?: BusinessError) => void) => reject({
          code: -1, message: 'error'
        } as BusinessError)));

      when(mocker.mockFunc(DataShareHelper.getInstance(),
        DataShareHelper.getInstance().initSmsDB))(ArgumentMatchers.any)
        .afterReturn(new Promise<dataShare.DataShareHelper | undefined>(resolve => resolve(undefined)));

      mocker.mockFunc(ConversationListService.getInstance(), ConversationListService.getInstance().dealContactsName);

      await mmsSearchService.searchMessage(context, object, (res: LooseObject) => {
        expect(res.code).assertEqual(-1)
      });

      mocker.clear(DataShareHelper.getInstance());
      mocker.clear(mmsSearchService);
      mocker.clear(ConversationListService.getInstance());
    })

    it('MmsSearchService_querySessionByContact', 0, async () => {
      let object: LooseObject = {
        input: 'xx',
        smsType: 1
      };
      let mocker: MockKit = new MockKit();

      let mySet: DataShareResultSet = new MySet();
      mySet.rowCount = 1;
      when(mocker.mockFunc(DataShareHelper.getInstance(),
        DataShareHelper.getInstance().initSmsDB))(ArgumentMatchers.any)
        .afterReturn(new Promise<dataShare.DataShareHelper | undefined>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve(mySet))
        } as dataShare.DataShareHelper)));

      mocker.mockFunc(ConversationListService.getInstance(),
        ConversationListService.getInstance().querySessionByTelephones);

      let res = await mmsSearchService.querySessionByContact(context, object);

      expect(res.code).assertEqual(0);

      mocker.clear(DataShareHelper.getInstance());
      mocker.clear(mmsSearchService);
      mocker.clear(ConversationListService.getInstance());
    })

    it('MmsSearchService_getConversationSession', 0, async () => {
      let object: LooseObject = {
        input: 'xx',
        smsType: 1
      };
      let callback = (res: ConversationListInfo) => {
        expect(res.hasDraft).assertFalse();
      };
      let mocker: MockKit = new MockKit();

      let mySet: DataShareResultSet = new MySet();
      mySet.rowCount = 1;
      when(mocker.mockFunc(DataShareHelper.getInstance(),
        DataShareHelper.getInstance().initSmsDB))(ArgumentMatchers.any)
        .afterReturn(new Promise<dataShare.DataShareHelper | undefined>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve(mySet))
        } as dataShare.DataShareHelper)));

      mocker.mockFunc(ConversationListService.getInstance(),
        ConversationListService.getInstance().querySessionByTelephones);

      await mmsSearchService.getConversationSession(context, object, callback);

      mocker.clear(DataShareHelper.getInstance());
      mocker.clear(ConversationListService.getInstance());
    })
  })
}