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
import { describe, beforeEach, it, expect, MockKit, when, ArgumentMatchers } from '@ohos/hypium';
import LooseObject from '../../../../main/ets/data/LooseObject';
import ConversationListModel from '../../../../main/ets/model/ConversationListModel';
import { DTGlobalContext } from '../../testability/TestAbility';
import DataShareHelper from '../../../../main/ets/model/repository/DataShareHelper';
import { dataShare, dataSharePredicates, DataShareResultSet, ValuesBucket } from '@kit.ArkData';
import { AsyncCallback, BusinessError } from '@kit.BasicServicesKit';
import { SessionContactInfoForDB } from '../../../../main/ets/pages/conversation/conversationController';
import MySet from '../MySet';
import YellowPageService from '../../../../main/ets/service/yellowPageService';
import dateUtil, { DateUtil } from '../../../../main/ets/utils/DateUtil';
import ConversationListResponse from '../../../../main/ets/model/conversationlist/ConversationListResponse';
import { ConversationListInfo,
  ConversationListViewInfo } from '../../../../main/ets/model/conversationlist/ConversationListInfo';
import { HashMap } from '@kit.ArkTS';
import TelephoneUtil from '../../../../main/ets/utils/TelephoneUtil';

export default function ConversationListModelTest() {
  describe('ConversationListModelTest', () => {

    let conversationListModel: ConversationListModel;

    beforeEach(() => {
      conversationListModel = new ConversationListModel();
    })

    it('ConversationListModel_insertSession_dataHelper_undefined', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve(undefined))));

      await conversationListModel.insertSession({} as ValuesBucket, (data: LooseObject) => {
        expect(data.code).assertEqual(-1);
      }, context);

      mocker.clear(conversationListModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('ConversationListModel_insertSession_insert', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve({
          insert: (uri: string, value: ValuesBucket): Promise<number> =>
          new Promise<number>(resolve => resolve(1))
        } as dataShare.DataShareHelper))));

      await conversationListModel.insertSession({} as ValuesBucket, (data: LooseObject) => {
        expect(data.code).assertEqual(0);
      }, context);

      mocker.clear(conversationListModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('ConversationListModel_insertSession_catch', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve({
          insert: (uri: string, value: ValuesBucket): Promise<number> =>
          new Promise<number>((resolve: (value: number | PromiseLike<number>) => void,
            reject: (reason?: BusinessError) => void) =>
          reject({
            code: 1, message: 'error'
          } as BusinessError))
        } as dataShare.DataShareHelper))));

      await conversationListModel.insertSession({} as ValuesBucket, (data: LooseObject) => {
        expect(data.code).assertEqual(-1);
      }, context);

      mocker.clear(conversationListModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('ConversationListModel_insertSession_dataHelper_undefined_callback_null', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve(undefined))));

      await conversationListModel.insertSession({} as ValuesBucket, null, context);

      mocker.clear(conversationListModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('ConversationListModel_insertSession_insert_callback_null', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve({
          insert: (uri: string, value: ValuesBucket): Promise<number> =>
          new Promise<number>(resolve => resolve(1))
        } as dataShare.DataShareHelper))));

      await conversationListModel.insertSession({} as ValuesBucket, null, context);

      mocker.clear(conversationListModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('ConversationListModel_insertSession_catch_callback_null', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve({
          insert: (uri: string, value: ValuesBucket): Promise<number> =>
          new Promise<number>((resolve: (value: number | PromiseLike<number>) => void,
            reject: (reason?: BusinessError) => void) =>
          reject({
            code: 1, message: 'error'
          } as BusinessError))
        } as dataShare.DataShareHelper))));

      await conversationListModel.insertSession({} as ValuesBucket, null, context);

      mocker.clear(conversationListModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('ConversationListModel_deleteSessionByCondition_dataHelper_undefined', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve(undefined))));

      await conversationListModel.deleteSessionByCondition({} as ValuesBucket, (data: LooseObject) => {
        expect(data.code).assertEqual(-1);
      }, context);

      mocker.clear(conversationListModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('ConversationListModel_deleteSessionByCondition_delete', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve({
          delete: (uri: string, predicates: dataSharePredicates.DataSharePredicates): Promise<number> =>
          new Promise<number>(resolve => resolve(1))
        } as dataShare.DataShareHelper))));

      await conversationListModel.deleteSessionByCondition({} as ValuesBucket, (data: LooseObject) => {
        expect(data.code).assertEqual(0);
      }, context);

      mocker.clear(conversationListModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('ConversationListModel_deleteSessionByCondition_catch', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve({
          delete: (uri: string, predicates: dataSharePredicates.DataSharePredicates): Promise<number> =>
          new Promise<number>((resolve: (value: number | PromiseLike<number>) => void,
            reject: (reason?: BusinessError) => void) =>
          reject({
            code: 1, message: 'error'
          } as BusinessError))
        } as dataShare.DataShareHelper))));

      await conversationListModel.deleteSessionByCondition({} as ValuesBucket, (data: LooseObject) => {
        expect(data.code).assertEqual(-1);
      }, context);

      mocker.clear(conversationListModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('ConversationListModel_deleteSessionByCondition_dataHelper_undefined_callback_null', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve(undefined))));

      await conversationListModel.deleteSessionByCondition({} as ValuesBucket, null, context);

      mocker.clear(conversationListModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('ConversationListModel_deleteSessionByCondition_delete_callback_null', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve({
          delete: (uri: string, predicates: dataSharePredicates.DataSharePredicates): Promise<number> =>
          new Promise<number>(resolve => resolve(1))
        } as dataShare.DataShareHelper))));

      await conversationListModel.deleteSessionByCondition({} as ValuesBucket, null, context);

      mocker.clear(conversationListModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('ConversationListModel_deleteSessionByCondition_catch_callback_null', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve({
          delete: (uri: string, predicates: dataSharePredicates.DataSharePredicates): Promise<number> =>
          new Promise<number>((resolve: (value: number | PromiseLike<number>) => void,
            reject: (reason?: BusinessError) => void) =>
          reject({
            code: 1, message: 'error'
          } as BusinessError))
        } as dataShare.DataShareHelper))));

      await conversationListModel.deleteSessionByCondition({} as ValuesBucket, null, context);

      mocker.clear(conversationListModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('ConversationListModel_fetchRecentContactsAndBatchUpdateSession_contacts_length0', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;

      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(conversationListModel, conversationListModel.fetchRecentContacts))(context)
        .afterReturn(new  Promise<SessionContactInfoForDB[]>(resolve => resolve([])));

      await conversationListModel.fetchRecentContactsAndBatchUpdateSession(context, '', '', (results: number[]) => {
        expect(results.length).assertEqual(0);
      });

      mocker.clear(conversationListModel);
    })

    it('ConversationListModel_fetchRecentContactsAndBatchUpdateSession_contacts_length0_callback_null', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;

      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(conversationListModel, conversationListModel.fetchRecentContacts))(context)
        .afterReturn(new  Promise<SessionContactInfoForDB[]>(resolve => resolve([])));

      await conversationListModel.fetchRecentContactsAndBatchUpdateSession(context, '', '', null);

      mocker.clear(conversationListModel);
    })

    it('ConversationListModel_fetchRecentContactsAndBatchUpdateSession_abilityResult_length1', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mySet: DataShareResultSet = new MySet();
      mySet.rowCount = 1;

      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(conversationListModel, conversationListModel.fetchRecentContacts))(context)
        .afterReturn(new  Promise<SessionContactInfoForDB[]>(resolve => resolve([{
          rawContactId: '1',
          contactId: '1',
          contactPhone: '570977632',
          contactName: 'roxy'
        }])));

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve(mySet)),
          update: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            value: ValuesBucket): Promise<number> =>
          new Promise<number>(resolve => resolve(1))
        } as dataShare.DataShareHelper)));

      await conversationListModel.fetchRecentContactsAndBatchUpdateSession(context, '', '', (results: number[]) => {
        expect(results.length).assertEqual(1);
      });

      mocker.clear(conversationListModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('ConversationListModel_fetchRecentContactsAndBatchUpdateSession_abilityResult_length1_callback_null', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mySet: DataShareResultSet = new MySet();
      mySet.rowCount = 1;

      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(conversationListModel, conversationListModel.fetchRecentContacts))(context)
        .afterReturn(new  Promise<SessionContactInfoForDB[]>(resolve => resolve([{
          rawContactId: '1',
          contactId: '1',
          contactPhone: '570977632',
          contactName: 'roxy'
        }])));

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve(mySet)),
          update: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            value: ValuesBucket): Promise<number> =>
          new Promise<number>(resolve => resolve(1))
        } as dataShare.DataShareHelper)));

      await conversationListModel.fetchRecentContactsAndBatchUpdateSession(context, '', '', null);

      mocker.clear(conversationListModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('ConversationListModel_fetchRecentContactsAndBatchUpdateSession_abilityResult_length0', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mySet: DataShareResultSet = new MySet();

      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(conversationListModel, conversationListModel.fetchRecentContacts))(context)
        .afterReturn(new  Promise<SessionContactInfoForDB[]>(resolve => resolve([{
          rawContactId: '1',
          contactId: '1',
          contactPhone: '570977632',
          contactName: 'roxy'
        }])));

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve(mySet)),
          update: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            value: ValuesBucket): Promise<number> =>
          new Promise<number>(resolve => resolve(1))
        } as dataShare.DataShareHelper)));

      when(mocker.mockFunc(Promise, Promise.allSettled))(ArgumentMatchers.any)
        .afterReturn(new Promise<LooseObject[]>(resolve => resolve([])));

      await conversationListModel.fetchRecentContactsAndBatchUpdateSession(context, '', '', (results: number[]) => {
        expect(results.length).assertEqual(1);
      });

      mocker.clear(conversationListModel);
      mocker.clear(DataShareHelper.getInstance());
      mocker.clear(Promise);
    })

    it('ConversationListModel_fetchDeleteContactsAndUpdateSession_contacts_length0', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;

      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(conversationListModel, conversationListModel.fetchDeleteContacts))(context)
        .afterReturn(new  Promise<SessionContactInfoForDB[]>(resolve => resolve([])));

      await conversationListModel.fetchDeleteContactsAndUpdateSession(context, [''], (results: number[]) => {
        expect(results.length).assertEqual(0);
      });

      mocker.clear(conversationListModel);
    })

    it('ConversationListModel_fetchDeleteContactsAndUpdateSession_abilityResult_length1', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mySet: DataShareResultSet = new MySet();
      mySet.rowCount = 1;

      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(conversationListModel, conversationListModel.fetchDeleteContacts))(context)
        .afterReturn(new  Promise<SessionContactInfoForDB[]>(resolve => resolve([{
          rawContactId: '1',
          contactId: '1',
          contactPhone: '570977632',
          contactName: 'roxy'
        }])));

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve(mySet)),
          update: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            value: ValuesBucket): Promise<number> =>
          new Promise<number>(resolve => resolve(1))
        } as dataShare.DataShareHelper)));

      await conversationListModel.fetchDeleteContactsAndUpdateSession(context, [''], (results: number[]) => {
        expect(results.length).assertEqual(0);

        mocker.clear(conversationListModel);
        mocker.clear(DataShareHelper.getInstance());
      })
    })

    it('ConversationListModel_fetchDeleteContactsAndUpdateSession_abilityResult_length0', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mySet: DataShareResultSet = new MySet();

      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(conversationListModel, conversationListModel.fetchDeleteContacts))(context)
        .afterReturn(new  Promise<SessionContactInfoForDB[]>(resolve => resolve([{
          rawContactId: '1',
          contactId: '1',
          contactPhone: '570977632',
          contactName: 'roxy'
        }])));

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve(mySet)),
          update: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            value: ValuesBucket): Promise<number> =>
          new Promise<number>(resolve => resolve(1))
        } as dataShare.DataShareHelper)));

      await conversationListModel.fetchDeleteContactsAndUpdateSession(context, [''], (results: number[]) => {
        expect(results.length).assertEqual(0);
      });

      mocker.clear(conversationListModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('ConversationListModel_fetchRecentContacts_fail', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;

      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initContactDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve(undefined))));

      let result: SessionContactInfoForDB[] = await conversationListModel.fetchRecentContacts(context, '', '');

      expect(result.length).assertEqual(0);

      mocker.clear(DataShareHelper.getInstance());
    })

    it('ConversationListModel_fetchRecentContacts_abilityResult_length0', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;

      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initContactDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve(new MySet()))
        } as dataShare.DataShareHelper)));

      let result: SessionContactInfoForDB[] = await conversationListModel.fetchRecentContacts(context, '', '');

      expect(result.length).assertEqual(0);

      mocker.clear(DataShareHelper.getInstance());
    })

    it('ConversationListModel_fetchRecentContacts_abilityResult_length1', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mySet: DataShareResultSet = new MySet();
      mySet.rowCount = 1;

      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initContactDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve(mySet))
        } as dataShare.DataShareHelper)));

      let result: SessionContactInfoForDB[] = await conversationListModel.fetchRecentContacts(context, '', '');

      expect(result.length).assertEqual(10);

      mocker.clear(DataShareHelper.getInstance());
    })

    it('ConversationListModel_fetchDeleteContacts', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;

      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initContactDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve(undefined))));

      let result: SessionContactInfoForDB[] = await conversationListModel.fetchDeleteContacts(context, ['1']);

      expect(result.length).assertEqual(0);

      mocker.clear(DataShareHelper.getInstance());
    })

    it('ConversationListModel_fetchDeleteContacts_abilityResult_length0', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;

      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initContactDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve(new MySet()))
        } as dataShare.DataShareHelper)));

      let result: SessionContactInfoForDB[] = await conversationListModel.fetchDeleteContacts(context, ['1']);

      expect(result.length).assertEqual(0);

      mocker.clear(DataShareHelper.getInstance());
    })

    it('ConversationListModel_fetchDeleteContacts_abilityResult_length10', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mySet: DataShareResultSet = new MySet();
      mySet.rowCount = 1;

      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initContactDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve(mySet))
        } as dataShare.DataShareHelper)));

      when(mocker.mockFunc(YellowPageService.getInstance(),
        YellowPageService.getInstance().judgeYellowPageByTelephone))(ArgumentMatchers.any)
        .afterReturn({
          'yellowPageId': '1',
          'name': 'roxy'
        });

      let result: SessionContactInfoForDB[] = await conversationListModel.fetchDeleteContacts(context, ['1']);

      expect(result.length).assertEqual(10);

      mocker.clear(DataShareHelper.getInstance());
      mocker.clear(YellowPageService.getInstance());
    })

    it('ConversationListModel_batchUpdateSessionByCondition_conditionsValueBuckets_length_noEqual', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let conditions: Record<string, string | number>[] = [{
        'telephone': '570977632'
      },
        {
          'telephone': '570977633'
        }];
      let valueBuckets: ValuesBucket[] = [{
        'telephone': '570977632'
      }];

      await conversationListModel.batchUpdateSessionByCondition(context, conditions, valueBuckets,
        (results: number[]) => {
          expect(results.length).assertEqual(1);
        });
    })

    it('ConversationListModel_batchUpdateSessionByCondition_valueBuckets_length0', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let conditions: Record<string, string | number>[] = [];
      let valueBuckets: ValuesBucket[] = [];

      await conversationListModel.batchUpdateSessionByCondition(context, conditions, valueBuckets,
        (results: number[]) => {
          expect(results.length).assertEqual(0);
        });
    })

    it('ConversationListModel_batchUpdateSessionByCondition_dataHelper_undefined', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let conditions: Record<string, string | number>[] = [{
        'telephone': '570977632'
      }];
      let valueBuckets: ValuesBucket[] = [{
        'telephone': '570977632'
      }];

      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve(undefined))));

      await conversationListModel.batchUpdateSessionByCondition(context, conditions, valueBuckets,
        (results: number[]) => {
          expect(results.length).assertEqual(1);
        });

      mocker.clear(DataShareHelper.getInstance());
    })

    it('ConversationListModel_batchUpdateSessionByCondition_dataHelper_update', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let conditions: Record<string, string | number>[] = [{
        'telephone': '570977632'
      }];
      let valueBuckets: ValuesBucket[] = [{
        'telephone': '570977632'
      }];

      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve({
          update: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            value: ValuesBucket): Promise<number> =>
          new Promise<number>(resolve => resolve(1))
        } as dataShare.DataShareHelper))));

      when(mocker.mockFunc(Promise, Promise.allSettled))(ArgumentMatchers.any)
        .afterReturn(new Promise<LooseObject[]>(resolve => resolve([{
          value: 1
        }])));

      await conversationListModel.batchUpdateSessionByCondition(context, conditions, valueBuckets,
        (results: number[]) => {
          expect(results.length).assertEqual(1);
        });

      mocker.clear(DataShareHelper.getInstance());
      mocker.clear(Promise);
    })

    it('ConversationListModel_batchUpdateSessionByCondition_dataHelper_catch', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let conditions: Record<string, string | number>[] = [{
        'telephone': '570977632'
      }];
      let valueBuckets: ValuesBucket[] = [{
        'telephone': '570977632'
      }];

      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve({
          update: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            value: ValuesBucket): Promise<number> =>
          new Promise<number>(resolve => resolve(1))
        } as dataShare.DataShareHelper))));

      when(mocker.mockFunc(Promise, Promise.allSettled))(ArgumentMatchers.any)
        .afterReturn(new Promise<LooseObject[]>((resolve: (value: LooseObject[] | PromiseLike<LooseObject[]>) => void,
          reject: (reason?: BusinessError) => void) => reject({
          code: 1, message: 'error'
        } as BusinessError)));

      await conversationListModel.batchUpdateSessionByCondition(context, conditions, valueBuckets,
        (results: number[]) => {
          expect(results.length).assertEqual(1);
        });

      await conversationListModel.batchUpdateSessionByCondition(context, conditions, valueBuckets, null);

      mocker.clear(DataShareHelper.getInstance());
      mocker.clear(Promise);
    })

    it('ConversationListModel_updateSessionByCondition_dataHelper_undefined', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let actionData: LooseObject = {};
      let valueBucket: ValuesBucket = {
        'telephone': '570977632'
      };

      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve(undefined))));

      await conversationListModel.updateSessionByCondition(actionData, valueBucket, (result: LooseObject) => {
        expect(result.code).assertEqual(-1);
      }, context);

      mocker.clear(DataShareHelper.getInstance());
    })

    it('ConversationListModel_updateSessionByCondition_update', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let actionData: LooseObject = {
        'telephone': '570977632',
        'smsType': '',
        'telephone_like': '',
        'threadId': '',
        'threadIds': [''],
        'messageCount': 1,
        'unreadCount_greaterThan': '',
        'telephones': ['570977632'],
        'orderByTimeDesc': '',
        'page': 1,
        'limit': 1
      };
      let valueBucket: ValuesBucket = {
        'telephone': '570977632'
      };

      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve({
          update: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            value: ValuesBucket): Promise<number> =>
          new Promise<number>(resolve => resolve(1))
        } as dataShare.DataShareHelper))));

      await conversationListModel.updateSessionByCondition(actionData, valueBucket, (result: LooseObject) => {
        expect(result.code).assertEqual(0);
      }, context);

      mocker.clear(DataShareHelper.getInstance());
    })

    it('ConversationListModel_updateSessionByCondition_update_actionData_nulls', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let actionData: LooseObject = {
        'telephone': null,
        'smsType': null,
        'telephone_like': null,
        'threadId': null,
        'threadIds': null,
        'messageCount': null,
        'unreadCount_greaterThan': null,
        'telephones': null,
        'orderByTimeDesc': null,
        'page': null,
        'limit': null
      };
      let valueBucket: ValuesBucket = {
        'telephone': '570977632'
      };

      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve({
          update: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            value: ValuesBucket): Promise<number> =>
          new Promise<number>(resolve => resolve(1))
        } as dataShare.DataShareHelper))));

      await conversationListModel.updateSessionByCondition(actionData, valueBucket, (result: LooseObject) => {
        expect(result.code).assertEqual(0);
      }, context);

      mocker.clear(DataShareHelper.getInstance());
    })

    it('ConversationListModel_updateSessionByCondition_valueBucket_null_callback_null', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let actionData: LooseObject = {
        'telephone': null,
        'smsType': '1'
      };
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve({
          update: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            value: ValuesBucket): Promise<number> =>
          new Promise<number>(resolve => resolve(1))
        } as dataShare.DataShareHelper))));

      await conversationListModel.updateSessionByCondition(actionData, null, null, context);

      mocker.clear(DataShareHelper.getInstance());
    })

    it('ConversationListModel_updateSessionByCondition_valueBucket_null_callback_not_null', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let actionData: LooseObject = {
        'telephone': '1223',
        'smsType': '1'
      };
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve({
          update: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            value: ValuesBucket): Promise<number> =>
          new Promise<number>(resolve => resolve(1))
        } as dataShare.DataShareHelper))));
      await conversationListModel.updateSessionByCondition(actionData, null, (result: LooseObject) => { }, context);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('ConversationListModel_updateSessionByCondition_update_actionData_smsType_notNull', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let actionData: LooseObject = {
        'telephone': null,
        'smsType': '',
        'telephone_like': null,
        'threadId': null,
        'threadIds': [],
        'messageCount': null,
        'unreadCount_greaterThan': null,
        'telephones': [],
        'orderByTimeDesc': null,
        'page': null,
        'limit': null
      };
      let valueBucket: ValuesBucket = {
        'telephone': '570977632'
      };

      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve({
          update: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            value: ValuesBucket): Promise<number> =>
          new Promise<number>(resolve => resolve(1))
        } as dataShare.DataShareHelper))));

      await conversationListModel.updateSessionByCondition(actionData, valueBucket, (result: LooseObject) => {
        expect(result.code).assertEqual(0);
      }, context);

      mocker.clear(DataShareHelper.getInstance());
    })

    it('ConversationListModel_updateSessionByCondition_catch', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let actionData: LooseObject = {
        'telephone': null,
        'smsType': null,
        'telephone_like': null,
        'threadId': null,
        'threadIds': null,
        'messageCount': null,
        'unreadCount_greaterThan': null,
        'telephones': null,
        'orderByTimeDesc': null,
        'page': null,
        'limit': null
      };
      let valueBucket: ValuesBucket = {
        'telephone': '570977632'
      };

      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve({
          update: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            value: ValuesBucket): Promise<number> =>
          new Promise<number>((resolve: (value: number | PromiseLike<number>) => void,
            reject: (reason?: BusinessError) => void) =>
          reject({
            code: 1, message: 'error'
          } as BusinessError))
        } as dataShare.DataShareHelper))));

      await conversationListModel.updateSessionByCondition(actionData, valueBucket, (result: LooseObject) => {
        expect(result.code).assertEqual(-1);
      }, context);

      await conversationListModel.updateSessionByCondition(actionData, valueBucket, null, context);

      mocker.clear(DataShareHelper.getInstance());
    })

    it('ConversationListModel_markAsReadFromReceive_dataHelper_undefined', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let actionData: LooseObject = {};

      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve(undefined))));

      await conversationListModel.markAsReadFromReceive(actionData, (result: LooseObject) => {
        expect(result.code).assertEqual(-1);
      }, context);

      mocker.clear(DataShareHelper.getInstance());
    })

    it('ConversationListModel_markAsReadFromReceive_dataHelper_undefined_callback_null', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let actionData: LooseObject = {
        'telephone': '570977632',
        'smsType': ''
      };

      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve(undefined))));
      await conversationListModel.markAsReadFromReceive(actionData, undefined, context);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('ConversationListModel_markAsReadFromReceive_query_rowCount0', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let actionData: LooseObject = {
        'isAfterNoReadButton': true,
        'telephone': '16452843156',
        'msgContent': 'msgContent',
        'startTime': '19880523',
        'threadIds': ['124']
      };

      let mocker: MockKit = new MockKit();
      let businessError: BusinessError = {
        code: 1,
        message: 'dataShare error'
      } as BusinessError
      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          update: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            value: ValuesBucket, callback: AsyncCallback<number>): Promise<number> =>
          new Promise<number>(resolve => {
            callback(businessError, 1);
            resolve(1)
          })
        } as dataShare.DataShareHelper)));

      await conversationListModel.markAsReadFromReceive(actionData, (result: LooseObject) => {
        expect(result.code).assertUndefined();
      }, context);
      await conversationListModel.markAsReadFromReceive(actionData, null, context);

      mocker.clear(DataShareHelper.getInstance());
    })

    it('ConversationListModel_markAsReadFromReceive_query_rowCount1', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let actionData: LooseObject = {
        'telephone': '570977632',
        'smsType': '',
        'telephone_like': '',
        'threadId': '',
        'threadIds': [''],
        'messageCount': 1,
        'unreadCount_greaterThan': '',
        'telephones': ['570977632'],
        'orderByTimeDesc': '',
        'page': 1,
        'limit': 1
      };
      let mySet: DataShareResultSet = new MySet();
      mySet.rowCount = 1;

      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve(mySet)),
          update: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            value: ValuesBucket): Promise<number> =>
          new Promise<number>(resolve => resolve(1))
        } as dataShare.DataShareHelper)));

      await conversationListModel.markAsReadFromReceive(actionData, (result: LooseObject) => {
        expect(result.code).assertUndefined();
      }, context);

      mocker.clear(DataShareHelper.getInstance());
    })

    it('ConversationListModel_markAsReadFromReceive_catch', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let actionData: LooseObject = {
        'telephone': '570977632',
        'smsType': '',
        'telephone_like': '',
        'threadId': '',
        'threadIds': [''],
        'messageCount': 1,
        'unreadCount_greaterThan': '',
        'telephones': ['570977632'],
        'orderByTimeDesc': '',
        'page': 1,
        'limit': 1
      };
      let mySet: DataShareResultSet = new MySet();
      mySet.rowCount = 1;

      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>((resolve: (value: DataShareResultSet | PromiseLike<DataShareResultSet>) => void,
            reject: (reason?: BusinessError) => void) =>
          reject({
            code: 1, message: 'error'
          } as BusinessError)),
          update: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            value: ValuesBucket): Promise<number> =>
          new Promise<number>(resolve => resolve(1))
        } as dataShare.DataShareHelper)));

      await conversationListModel.markAsReadFromReceive(actionData, (result: LooseObject) => {
        expect(result.code).assertEqual(-1);
      }, context);

      mocker.clear(DataShareHelper.getInstance());
    })

    it('ConversationListModel_getBestSessionDataHelper_useSilenceDB_true_initSilenceSmsDBSessionTable', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let actionData: LooseObject = {
        'telephone': '570977632',
        'smsType': '',
        'telephone_like': '',
        'threadId': '',
        'threadIds': [''],
        'messageCount': 1,
        'unreadCount_greaterThan': '',
        'telephones': ['570977632'],
        'orderByTimeDesc': '',
        'page': 1,
        'limit': 1,
        'useSilenceDB': true
      };
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve(undefined))));
      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSilenceSmsDBSessionTable))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve(new MySet()))
        } as dataShare.DataShareHelper)));
      await conversationListModel.querySessionByCondition(actionData, (result: LooseObject) => {
        expect(result.code).assertEqual(0);
      }, context);

      mocker.clear(DataShareHelper.getInstance());
    })

    it('ConversationListModel_getBestSessionDataHelper_useSilenceDB_true', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let actionData: LooseObject = {
        'telephone': '570977632',
        'smsType': '',
        'telephone_like': '',
        'threadId': '',
        'threadIds': [''],
        'messageCount': 1,
        'unreadCount_greaterThan': '',
        'telephones': ['570977632'],
        'orderByTimeDesc': '',
        'page': 1,
        'limit': 1,
        'useSilenceDB': true
      };
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve(undefined))));
      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSilenceSmsDBSessionTable))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve(undefined))));
      await conversationListModel.querySessionByCondition(actionData, (result: LooseObject) => {
        expect(result.code).assertEqual(-1);
      }, context);

      mocker.clear(DataShareHelper.getInstance());
    })

    it('ConversationListModel_querySessionByCondition_dataHelper_undefined', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let actionData: LooseObject = {
        'telephone': '570977632',
        'smsType': '',
        'telephone_like': '',
        'threadId': '',
        'threadIds': [''],
        'messageCount': 1,
        'unreadCount_greaterThan': '',
        'telephones': ['570977632'],
        'orderByTimeDesc': '',
        'page': 1,
        'limit': 1,
        'useSilenceDB': false
      };

      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve(undefined))));

      await conversationListModel.querySessionByCondition(actionData, (result: LooseObject) => {
        expect(result.code).assertEqual(-1);
      }, context);

      mocker.clear(DataShareHelper.getInstance());
    })

    it('ConversationListModel_querySessionByCondition_query_rowCount0', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let actionData: LooseObject = {
        'telephone': '570977632',
        'smsType': '',
        'telephone_like': null,
        'threadId': '',
        'threadIds': [''],
        'messageCount': 1,
        'unreadCount_greaterThan': '',
        'telephones': null,
        'orderByTimeDesc': '',
        'page': 1,
        'limit': 1
      };

      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve(new MySet()))
        } as dataShare.DataShareHelper)));

      await conversationListModel.querySessionByCondition(actionData, (result: LooseObject) => {
        expect(result.code).assertEqual(0);
      }, context);

      mocker.clear(DataShareHelper.getInstance());
    })

    it('ConversationListModel_querySessionByCondition_query_rowCount1', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mySet: DataShareResultSet = new MySet();
      mySet.rowCount = 1;
      let actionData: LooseObject = {
        'telephone': '570977632',
        'smsType': '',
        'telephone_like': null,
        'threadId': '',
        'threadIds': [''],
        'messageCount': 1,
        'unreadCount_greaterThan': '',
        'telephones': null,
        'orderByTimeDesc': '',
        'page': 1,
        'limit': 1
      };

      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve(mySet))
        } as dataShare.DataShareHelper)));

      await conversationListModel.querySessionByCondition(actionData, (result: LooseObject) => {
        expect(result.code).assertEqual(0);
      }, context);

      mocker.clear(DataShareHelper.getInstance());
    })

    it('ConversationListModel_querySessionByCondition_catch', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mySet: DataShareResultSet = new MySet();
      mySet.rowCount = 1;
      let actionData: LooseObject = {
        'telephone': '570977632',
        'smsType': '',
        'telephone_like': null,
        'threadId': '',
        'threadIds': [''],
        'messageCount': 1,
        'unreadCount_greaterThan': '',
        'telephones': null,
        'orderByTimeDesc': '',
        'page': 1,
        'limit': 1
      };

      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>((resolve: (value: DataShareResultSet | PromiseLike<DataShareResultSet>) => void,
            reject: (reason?: BusinessError) => void) =>
          reject({
            code: 1, message: 'error'
          } as BusinessError)),
        } as dataShare.DataShareHelper)));

      await conversationListModel.querySessionByCondition(actionData, (result: LooseObject) => {
        expect(result.code).assertEqual(-1);
      }, context);

      mocker.clear(DataShareHelper.getInstance());
    })

    it('ConversationListModel_querySessionResultByCondition_dataHelper_undefined', 0, () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let actionData: LooseObject = {
        'telephone': '570977632',
        'smsType': '',
        'telephone_like': '',
        'threadId': '',
        'threadIds': [''],
        'messageCount': 1,
        'unreadCount_greaterThan': '',
        'telephones': ['570977632'],
        'orderByTimeDesc': '',
        'page': 1,
        'limit': 1
      };

      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve(undefined))));

      when(mocker.mockFunc(DataShareHelper.getInstance(),
        DataShareHelper.getInstance().initContactDB))(ArgumentMatchers.any)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(undefined)));

      conversationListModel.querySessionResultByCondition(actionData, (result: LooseObject) => {
        expect(result.response.length).assertEqual(0);
      }, context);

      mocker.clear(DataShareHelper.getInstance());
    })

    it('ConversationListModel_querySessionResultByCondition_query_rowCount1', 0, () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mySet: DataShareResultSet = new MySet();
      mySet.rowCount = 1;
      let actionData: LooseObject = {
        'telephone': '570977632',
        'smsType': '',
        'telephone_like': null,
        'threadId': '',
        'threadIds': [''],
        'messageCount': 1,
        'unreadCount_greaterThan': '',
        'telephones': null,
        'orderByTimeDesc': '',
        'page': 1,
        'limit': 1
      };

      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve(mySet))
        } as dataShare.DataShareHelper)));

      when(mocker.mockFunc(DataShareHelper.getInstance(),
        DataShareHelper.getInstance().initContactDB))(ArgumentMatchers.any)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve(mySet))
        } as dataShare.DataShareHelper)));

      mocker.mockFunc(dateUtil, DateUtil.convertDateFormatForItem);

      when(mocker.mockFunc(YellowPageService.getInstance(),
        YellowPageService.getInstance().judgeYellowPageByTelephone))(ArgumentMatchers.any)
        .afterReturn(new Promise<LooseObject>(resolve => resolve({
          'yellowPageId': '1',
          'photo': '',
          'name': 'roxy'
        })));

      conversationListModel.querySessionResultByCondition(actionData, (result: LooseObject) => {
        expect(result.messageList.length).assertEqual(10);
      }, context);

      mocker.clear(DataShareHelper.getInstance());
      mocker.clear(dateUtil);
    })

    it('ConversationListModel_querySessionSizeByCondition_dataHelper_undefined', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let actionData: LooseObject = {};

      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve(undefined))));

      await conversationListModel.querySessionSizeByCondition(actionData, (result: LooseObject) => {
        expect(result.code).assertEqual(-1);
      }, context);

      await conversationListModel.querySessionSizeByCondition(actionData, null, context);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('ConversationListModel_querySessionSizeByCondition_query_rowCount_0', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mySet: DataShareResultSet = new MySet();
      mySet.rowCount = 0;
      let actionData: LooseObject = {
        'telephone': '570977632',
        'smsType': '',
        'telephone_like': null,
        'threadId': '',
        'threadIds': [''],
        'messageCount': 1,
        'unreadCount_greaterThan': '',
        'telephones': null,
        'orderByTimeDesc': '',
        'page': 1,
        'limit': 1
      };

      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve(mySet))
        } as dataShare.DataShareHelper)));

      await conversationListModel.querySessionSizeByCondition(actionData, (result: LooseObject) => {
      }, context);

      mocker.clear(DataShareHelper.getInstance());
    })

    it('ConversationListModel_querySessionSizeByCondition_query', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mySet: DataShareResultSet = new MySet();
      mySet.rowCount = 1;
      let actionData: LooseObject = {
        'telephone': '570977632',
        'smsType': '',
        'telephone_like': null,
        'threadId': '',
        'threadIds': [''],
        'messageCount': 1,
        'unreadCount_greaterThan': '',
        'telephones': null,
        'orderByTimeDesc': '',
        'page': 1,
        'limit': 1
      };

      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve(mySet))
        } as dataShare.DataShareHelper)));

      await conversationListModel.querySessionSizeByCondition(actionData, (result: LooseObject) => {
        expect(result.code).assertEqual(0);
      }, context);

      mocker.clear(DataShareHelper.getInstance());
    })

    it('ConversationListModel_querySessionSizeByCondition_catch', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mySet: DataShareResultSet = new MySet();
      mySet.rowCount = 1;
      let actionData: LooseObject = {
        'telephone': '570977632',
        'smsType': '',
        'telephone_like': null,
        'threadId': '',
        'threadIds': [''],
        'messageCount': 1,
        'unreadCount_greaterThan': '',
        'telephones': null,
        'orderByTimeDesc': '',
        'page': 1,
        'limit': 1
      };

      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>((resolve: (value: DataShareResultSet | PromiseLike<DataShareResultSet>) => void,
            reject: (reason?: BusinessError) => void) =>
          reject({
            code: 1, message: 'error'
          } as BusinessError))
        } as dataShare.DataShareHelper)));

      await conversationListModel.querySessionSizeByCondition(actionData, (result: LooseObject) => {
        expect(result.code).assertEqual(-1);
      }, context);

      mocker.clear(DataShareHelper.getInstance());
    })

    it('ConversationListModel_buildSessionNames_dealMultiName_if_telephoneMapHas_contactsNum_2', 0, () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let contacts: Array<LooseObject> = [{
        'id': '1',
        'rawContactId': null,
        'displayName': 'roxy',
        'detailInfo': '570977632'
      }];

      let sessionLists: Array<LooseObject> = [{
        'contactsNum': 2,
        'telephone': '570977632,123456',
        'name': 'roxy',
        'rawContactId': '1',
        'yellowPageId': '1',
        'yellowPageName': 'name',
        'tempIcon': '',
        'hasYellowPageIcon': '',
        'isDelShow': false,
        'itemLeft': 0,
        'photoFirstNames': [''],
        'photoSize': 10
      }];

      let result: Array<LooseObject> = conversationListModel.buildSessionNames(contacts, sessionLists, context);

      expect(result[0].name).assertEqual('roxy, 123456');
    })

    it('ConversationListModel_buildSessionNames_dealMultiName_if_telephoneMapHas', 0, () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let contacts: Array<LooseObject> = [{
        'id': '1',
        'rawContactId': null,
        'displayName': 'roxy',
        'detailInfo': '570977632'
      }];

      let sessionLists: Array<LooseObject> = [{
        'contactsNum': 1,
        'telephone': '570977632',
        'name': 'roxy',
        'rawContactId': '1',
        'yellowPageId': '1',
        'yellowPageName': 'name',
        'tempIcon': '',
        'hasYellowPageIcon': '',
        'isDelShow': false,
        'itemLeft': 0,
        'photoFirstNames': [''],
        'photoSize': 10
      }];

      let result: Array<LooseObject> = conversationListModel.buildSessionNames(contacts, sessionLists, context);

      expect(result[0].name).assertEqual('roxy');
    })

    it('ConversationListModel_deleteSessionSlice_dataHelper_undefined', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve(undefined))));

      await conversationListModel.deleteSessionSlice({} as ValuesBucket, (data: LooseObject) => {
        expect(data.code).assertEqual(-1);
      }, context);

      mocker.clear(conversationListModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('ConversationListModel_deleteSessionSlice_dataHelper_undefined_callback_null', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve(undefined))));

      await conversationListModel.deleteSessionSlice({} as ValuesBucket, null, context);

      mocker.clear(conversationListModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('ConversationListModel_deleteSessionSlice_delete', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve({
          delete: (uri: string, predicates: dataSharePredicates.DataSharePredicates): Promise<number> =>
          new Promise<number>(resolve => resolve(1))
        } as dataShare.DataShareHelper))));

      await conversationListModel.deleteSessionSlice({} as LooseObject, (data: LooseObject) => {
        expect(data.code).assertEqual(0);
      }, context);

      mocker.clear(conversationListModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('ConversationListModel_deleteSessionSlice_delete_smsType', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve({
          delete: (uri: string, predicates: dataSharePredicates.DataSharePredicates): Promise<number> =>
          new Promise<number>(resolve => resolve(1))
        } as dataShare.DataShareHelper))));

      await conversationListModel.deleteSessionSlice({smsType: '1'} as LooseObject, undefined, context);

      mocker.clear(conversationListModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('ConversationListModel_deleteSessionSlice_catch', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve({
          delete: (uri: string, predicates: dataSharePredicates.DataSharePredicates): Promise<number> =>
          new Promise<number>((resolve: (value: number | PromiseLike<number>) => void,
            reject: (reason?: BusinessError) => void) =>
          reject({
            code: 1, message: 'error'
          } as BusinessError))
        } as dataShare.DataShareHelper))));

      await conversationListModel.deleteSessionSlice({} as ValuesBucket, (data: LooseObject) => {
        expect(data.code).assertEqual(-1);
      }, context);

      mocker.clear(conversationListModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('ConversationListModel_deleteSessionSlice_catch_callback_null', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve({
          delete: (uri: string, predicates: dataSharePredicates.DataSharePredicates): Promise<number> =>
          new Promise<number>((resolve: (value: number | PromiseLike<number>) => void,
            reject: (reason?: BusinessError) => void) =>
          reject({
            code: 1, message: 'error'
          } as BusinessError))
        } as dataShare.DataShareHelper))));

      await conversationListModel.deleteSessionSlice({} as ValuesBucket, null, context);

      mocker.clear(conversationListModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('ConversationListModel_queryInChunks', 0, async () => {
      let conversationlistmodel: ConversationListModel = new ConversationListModel();
      let contacts: SessionContactInfoForDB[] = [{
        rawContactId: '1',
        contactId: '1',
        contactPhone: '570977632',
        contactName: 'roxy'
      }];
      let chunkSize: number = 1;
      let callback: Function = (result: [[1, 2], [3, 4], [5, 6]]) => {
        expect(result.length >= 0).assertTrue();
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      conversationlistmodel.queryInChunks(contacts, chunkSize, callback, context);
    });

    it('ConversationListModel_queryInChunks_callback_null', 0, async () => {
      let conversationlistmodel: ConversationListModel = new ConversationListModel();
      let contacts: SessionContactInfoForDB[] = [{
        rawContactId: '1',
        contactId: '1',
        contactPhone: '570977632',
        contactName: 'roxy'
      }];
      let chunkSize: number = 1;
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      conversationlistmodel.queryInChunks(contacts, chunkSize, null, context);
    });

    it('ConversationListModel_fetchDeleteContactList', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let rawContactIdList: String[] = ['123', '456'];
      await conversationListModel.fetchDeleteContactList(context, rawContactIdList);
    });

    it('ConversationListModel_buildSessionNamesByYellowPage', 0, () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let yellowPages: Array<LooseObject> = [{
        'yellowPageId': '1',
        'id': '3',
        'photo': '',
        'name': 'roxy',
        'number' : '570977632'
      }];
      let sessionLists: Array<LooseObject> = [{
        'contactsNum': 1,
        'telephone': '570977632',
        'name': 'roxy',
        'rawContactId': '',
        'yellowPageId': '1',
        'yellowPageName': 'name',
        'tempIcon': '',
        'hasYellowPageIcon': '',
        'isDelShow': false,
        'itemLeft': 0,
        'photoFirstNames': [''],
        'photoSize': 10
      },{
        'contactsNum': 10,
        'telephone': '570977632,456,789',
        'name': 'roxy',
        'rawContactId': '1,2,3',
        'yellowPageId': '1',
        'yellowPageName': 'name',
        'tempIcon': '',
        'hasYellowPageIcon': '',
        'isDelShow': false,
        'itemLeft': 0,
        'photoFirstNames': [''],
        'photoSize': 10
      },{
        'contactsNum': 10,
        'telephone': '570977632',
        'name': 'roxy',
        'rawContactId': '1',
        'yellowPageId': '1',
        'yellowPageName': 'name',
        'tempIcon': '',
        'hasYellowPageIcon': '',
        'isDelShow': false,
        'itemLeft': 0,
        'photoFirstNames': [''],
        'photoSize': 10
      },{
        'contactsNum': 10,
        'telephone': '',
        'name': 'roxy',
        'rawContactId': '1',
        'yellowPageId': '3',
        'yellowPageName': 'name',
        'tempIcon': '',
        'hasYellowPageIcon': '',
        'isDelShow': false,
        'itemLeft': 0,
        'photoFirstNames': [''],
        'photoSize': 10
      }];
      let result: Array<LooseObject> = conversationListModel.buildSessionNamesByYellowPage(yellowPages, sessionLists, context);
      expect(result[0].name).assertEqual('roxy');
    })

    it('ConversationListModel_updateYellowData_sessionArray_is_empty', 0, async () => {
      let sessionArray: LooseObject[] = [];
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      await conversationListModel.updateYellowData(sessionArray, context);
      expect(true).assertTrue();
    });

    it('ConversationListModel_updateYellowData_sessionArray_is_not_empty', 0, async () => {
      let sessionArray: LooseObject[] = [
        { telephone: '1234567890' },
        { telephone: '0987654321' }
      ];
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      await conversationListModel.updateYellowData(sessionArray, context);
      expect(true).assertTrue();
    });

    it('ConversationListModel_updateAttachmentByCondition_dataHelper_undefined', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let actionData: LooseObject = {
        'telephone': '570977632',
        'smsType': '',
        'telephone_like': '',
        'threadId': '',
        'threadIds': [''],
        'messageCount': 1,
        'unreadCount_greaterThan': '',
        'telephones': ['570977632'],
        'orderByTimeDesc': '',
        'page': 1,
        'limit': 1
      };
      let valueBucket: ValuesBucket = {
        'telephone': '570977632'
      };
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve(undefined))));
      await conversationListModel.updateAttachmentByCondition(actionData, valueBucket, context);

      mocker.clear(DataShareHelper.getInstance());
    })

    it('ConversationListModel_updateAttachmentByCondition_valueBucket_null', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let actionData: LooseObject = {};
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve({
          update: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            value: ValuesBucket): Promise<number> =>
          new Promise<number>(resolve => resolve(1))
        } as dataShare.DataShareHelper))));
      await conversationListModel.updateAttachmentByCondition(actionData, null, context);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('ConversationListModel_updateAttachmentByCondition_update', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let actionData: LooseObject = {
        'telephone': '570977632',
        'smsType': '',
        'telephone_like': '',
        'threadId': '',
        'threadIds': [''],
        'messageCount': 1,
        'unreadCount_greaterThan': '',
        'telephones': ['570977632'],
        'orderByTimeDesc': '',
        'page': 1,
        'limit': 1
      };
      let valueBucket: ValuesBucket = {
        'telephone': '570977632'
      };
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve({
          update: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            value: ValuesBucket): Promise<number> =>
          new Promise<number>(resolve => resolve(1))
        } as dataShare.DataShareHelper))));
      await conversationListModel.updateAttachmentByCondition(actionData, valueBucket, context);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('ConversationListModel_updateAttachmentByCondition_catch', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let actionData: LooseObject = {
        'telephone': null,
        'smsType': null,
        'telephone_like': null,
        'threadId': null,
        'threadIds': null,
        'messageCount': null,
        'unreadCount_greaterThan': null,
        'telephones': null,
        'orderByTimeDesc': null,
        'page': null,
        'limit': null
      };
      let valueBucket: ValuesBucket = {
        'telephone': '570977632'
      };
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve({
          update: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            value: ValuesBucket): Promise<number> =>
          new Promise<number>((resolve: (value: number | PromiseLike<number>) => void,
            reject: (reason?: BusinessError) => void) =>
          reject({
            code: 1, message: 'error'
          } as BusinessError))
        } as dataShare.DataShareHelper))));
      await conversationListModel.updateAttachmentByCondition(actionData, valueBucket, context);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('ConversationListModel_updateSessionByPinningTime_dataHelper_undefined', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let actionData: LooseObject = {
        'sessionId': '5321'
      };
      let valueBucket: ValuesBucket = {
        'telephone': '570977632'
      };
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve(undefined))));
      await conversationListModel.updateSessionByPinningTime(actionData, valueBucket, () => {}, context);

      mocker.clear(DataShareHelper.getInstance());
    })

    it('ConversationListModel_updateSessionByPinningTime_dataHelper', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let actionData: LooseObject = {
        'sessionId': '5321'
      };
      let valueBucket: ValuesBucket = {
        'telephone': '570977632'
      };
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve({
          update: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            value: ValuesBucket): Promise<number> =>
          new Promise<number>(resolve => resolve(0))
        } as dataShare.DataShareHelper))));
      await conversationListModel.updateSessionByPinningTime(actionData, valueBucket, () => {}, context);

      mocker.clear(DataShareHelper.getInstance());
    })

    it('ConversationListModel_updateSessionUnReadBySessionId_dataHelper_not_undefined_markReadType_1', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let actionData: LooseObject = {
        markReadType: 1,
        threadId: '3287'
      };
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve({
          update: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            value: ValuesBucket): Promise<number> =>
          new Promise<number>(resolve => resolve(1))
        } as dataShare.DataShareHelper))));
      const va: ValuesBucket = {
        'unread_count': 0
      }
      await conversationListModel.updateSessionUnReadBySessionId(actionData, va, () => {}, context);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('ConversationListModel_updateSessionUnReadBySessionId_dataHelper_not_undefined_markReadType_2', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let actionData: LooseObject = {
        markReadType: 2,
        threadId: '1287'
      };
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve({
          update: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            value: ValuesBucket): Promise<number> =>
          new Promise<number>(resolve => resolve(1))
        } as dataShare.DataShareHelper))));
      const va: ValuesBucket = {
        'unread_count': 0
      }
      await conversationListModel.updateSessionUnReadBySessionId(actionData, va, () => {}, context);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('ConversationListModel_updateSessionUnReadBySessionId_dataHelper_not_undefined_markReadType_3', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let actionData: LooseObject = {
        markReadType: 3,
        threadId: '3217'
      };
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve({
          update: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            value: ValuesBucket): Promise<number> =>
          new Promise<number>(resolve => resolve(1))
        } as dataShare.DataShareHelper))));
      const va: ValuesBucket = {
        'unread_count': 0
      }
      await conversationListModel.updateSessionUnReadBySessionId(actionData, va, () => {}, context);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('ConversationListModel_updateSessionUnReadBySessionId_dataHelper_not_undefined_markReadType_9', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let actionData: LooseObject = {
        markReadType: 9,
        threadId: '3187'
      };
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve({
          update: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            value: ValuesBucket): Promise<number> =>
          new Promise<number>(resolve => resolve(1))
        } as dataShare.DataShareHelper))));
      const va: ValuesBucket = {
        'unread_count': 0
      }
      await conversationListModel.updateSessionUnReadBySessionId(actionData, va, () => {}, context);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('ConversationListModel_queryConversionSessionByCondition_dataHelper_undefined', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let actionData: LooseObject = {
        'smsType': '102'
      };
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve(undefined))));
      await conversationListModel.queryConversionSessionByCondition(actionData, () => {}, context);

      mocker.clear(DataShareHelper.getInstance());
    })

    it('ConversationListModel_queryConversionSessionByCondition_dataHelper', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mySet: DataShareResultSet = new MySet();
      mySet.rowCount = 1;
      let actionData: LooseObject = {
        'smsType': '102'
      };
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve(mySet))
        } as dataShare.DataShareHelper)));
      await conversationListModel.queryConversionSessionByCondition(actionData, () => {}, context);

      mocker.clear(DataShareHelper.getInstance());
    })

    it('ConversationListModel_queryConversionSessionByCondition_dataHelper_rowCount_0', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mySet: DataShareResultSet = new MySet();
      let actionData: LooseObject = {
        'telephone_like': 'stt',
        'telephones': ['123456']
      };
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve(mySet))
        } as dataShare.DataShareHelper)));
      await conversationListModel.queryConversionSessionByCondition(actionData, () => {}, context);

      mocker.clear(DataShareHelper.getInstance());
    })

    it('ConversationListModel_queryConversionSessionByCondition_dataHelper_rowCount_0_telephones_undefined', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mySet: DataShareResultSet = new MySet();
      let actionData: LooseObject = {
        'telephone_like': 'stt'
      };
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve(mySet))
        } as dataShare.DataShareHelper)));
      await conversationListModel.queryConversionSessionByCondition(actionData, () => {}, context);

      mocker.clear(DataShareHelper.getInstance());
    })

    it('ConversationListModel_batchSessionContactInfo', 0, () => {
      let re = new ConversationListInfo();
      re.telephone = '1234567,12947395573';
      re.contactName = 'contactName';
      let res: ConversationListResponse = {
        code: 0,
        abilityResult: [re]
      } as ConversationListResponse;
      let telephones: string[] = [];
      let contacts: SessionContactInfoForDB[] = [];
      let context: Context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let callback: Function = () => {};
      (conversationListModel as object)['batchSessionContactInfo'](
        res, telephones, contacts, context, callback)
    })

    it('ConversationListModel_fetchFirstContactName', 0, () => {
      let context: Context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      (conversationListModel as object)['fetchFirstContactName']('123456', context)
    })

    it('ConversationListModel_buildMultiContactValueBucket', 0, () => {
      let item: ConversationListInfo = new ConversationListInfo();
      item.contactId = '12,34';
      item.contactName = 'contactName,110';
      item.telephone = '13482567491, 110';
      let contactMap: Map<string, Record<string, string>> = new Map<string, Record<string, string>>();
      contactMap.set('13482567491', {'contactName': 'WX', 'rawContactId': '1275'});
      (conversationListModel as object)['buildMultiContactValueBucket'](item, contactMap);
    })

    it('ConversationListModel_buildMultiContactValueBucket_length', 0, () => {
      let item: ConversationListInfo = new ConversationListInfo();
      item.contactId = '12,34';
      item.contactName = 'contactName,110';
      item.telephone = '13482567491,110';
      let contactMap: Map<string, Record<string, string>> = new Map<string, Record<string, string>>();
      contactMap.set('13482567491', {'contactName': 'WX', 'rawContactId': '1275'});
      (conversationListModel as object)['buildMultiContactValueBucket'](item, contactMap);
    })

    it('ConversationListModel_dealDeleteContactsInfo', 0, async () => {
      let context: Context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(YellowPageService.getInstance(),
        YellowPageService.getInstance().judgeYellowPageByTelephone))(ArgumentMatchers.any)
        .afterReturn({name: '', photo: '', yellowPageId: '', hasYellowPageIcon: ''});
      await (conversationListModel as object)['dealDeleteContactsInfo']({ code: 0, abilityResult: [{detailInfo: 'detailInfo'}]}, context, [])
      mocker.clear(YellowPageService.getInstance())
    })

    it('ConversationListModel_dealContactsName', 0, () => {
      let context: Context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let result: Promise<Array<LooseObject>> = (conversationListModel as object)['dealContactsName']([], [], context)
      result.then((res) => {})
    })

    it('ConversationListModel_dealContactsName_telephones', 0, () => {
      let context: Context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let result: Promise<Array<LooseObject>> = (conversationListModel as object)['dealContactsName']([
        '110', '110', '12738654930'
      ], [], context)
      result.then((res) => {})
    })

    it('ConversationListModel_dealContactsName_telephones_991', 0, () => {
      let context: Context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let telephones: string[] = [];
      for (let i = 0; i < 1000; i++) {
        telephones.push('134' + i)
      }
      let result: Promise<Array<LooseObject>> =
        (conversationListModel as object)['dealContactsName'](telephones, [], context)
      result.then((res) => {})
    })

    it('ConversationListModel_dealYellowPageName', 0, () => {
      let context: Context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let result: Promise<Array<LooseObject>> = (conversationListModel as object)['dealYellowPageName']([
        '110', '12738654930'
      ], [], context)
      result.then((res) => {})
    })

    it('ConversationListModel_buildQuerySessionCondition', 0, () => {
      (conversationListModel as object)['buildQuerySessionCondition']({
        telephone: '12345',
        isChatbotMessage: true,
        uncheckedThreadIds: ['12', '122'],
        orderByTimeDesc: 'desc',
        sessionIds: ['', ''],
        queryPinSessionSize: 2
      })
    })

    it('ConversationListModel_sessionFiledTelephone', 0, () => {
      (conversationListModel as object)['sessionFiledTelephone']({
        telephone: '12345578654'
      }, new dataSharePredicates.DataSharePredicates(), true)
    })

    it('ConversationListModel_sessionFiledTelephone_isFuzzyMatch', 0, () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(TelephoneUtil, TelephoneUtil.judgeIsInfoMsg))('13845626439').afterReturn(false);
      (conversationListModel as object)['sessionFiledTelephone']({
        telephone: '13845626439',
        telephoneFuzzyMatch: '13845626439'
      }, new dataSharePredicates.DataSharePredicates(), true);
      mocker.clear(TelephoneUtil)
    })

    it('ConversationListModel_buildSessionResult', 0, () => {
      let i = 2;
      let resultSet: DataShareResultSet = {
        rowCount: 1,
        goToNextRow: () => {
          i--
          return i >= 0;
        },
        close: () => {
        },
        getString: (columnIndex: number): string => '6',
        getColumnIndex: (columnName: string): number => 0,
        columnNames: ['contact_id', 'contact_name']
      } as DataShareResultSet
      (conversationListModel as object)['buildSessionResult'](resultSet)
    })

    it('ConversationListModel_getConvertSessionListResult_sessionList_null', 0, () => {
      let context: Context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      (conversationListModel as object)['getConvertSessionListResult'](null, context)
    })

    it('ConversationListModel_getConvertSessionListResult_isNeedMessageSort', 0, () => {
      let re = new ConversationListInfo();
      re.telephone = '1234567,12947395573';
      re.contactName = 'contactName,34';
      re.contactsNum = 2;
      let context: Context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      (conversationListModel as object)['getConvertSessionListResult']([re], context, true)
    })

    it('ConversationListModel_getConvertSessionListResult_smsType_1', 0, () => {
      let re = new ConversationListInfo();
      re.telephone = '12947395573';
      re.contactName = 'contactName';
      re.contactsNum = 1;
      re.smsType = 1;
      let context: Context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      (conversationListModel as object)['getConvertSessionListResult']([re], context)
    })

    it('ConversationListModel_getConvertSessionListResult_startsWith_sip', 0, () => {
      let re = new ConversationListInfo();
      re.telephone = 'sip:12947395573botplatform0';
      re.contactName = 'contactName';
      re.contactsNum = 1;
      re.smsType = 1;
      let context: Context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      (conversationListModel as object)['getConvertSessionListResult']([re], context)
    })

    it('ConversationListModel_dealMmsListContent', 0, () => {
      let re = new ConversationListInfo();
      re.telephone = 'sip:12947395573botplatform0';
      re.contactName = 'contactName';
      re.contactsNum = 1;
      re.smsType = 1;
      re.hasMms = 1;
      re.hasAttachment = 1;
      re.content = '/data/storage/el2/base/haps/entry/files/filename.123';
      let conversationListViewInfo = new ConversationListViewInfo(re);
      let context: Context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      (conversationListModel as object)['dealMmsListContent'](conversationListViewInfo, context)
    })

    it('ConversationListModel_dealMmsListContent_jpeg_else', 0, () => {
      let re = new ConversationListInfo();
      re.telephone = 'sip:12947395573botplatform0';
      re.contactName = 'contactName';
      re.contactsNum = 1;
      re.smsType = 1;
      re.hasMms = 1;
      re.hasAttachment = 1;
      re.content = 'files/filename.123';
      let conversationListViewInfo = new ConversationListViewInfo(re);
      let context: Context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      (conversationListModel as object)['dealMmsListContent'](conversationListViewInfo, context)
    })

    it('ConversationListModel_dealMmsListContent_jpeg', 0, () => {
      let re = new ConversationListInfo();
      re.telephone = 'sip:12947395573botplatform0';
      re.contactName = 'contactName';
      re.contactsNum = 1;
      re.smsType = 1;
      re.hasMms = 1;
      re.hasAttachment = 1;
      re.content = '/data/storage/el2/base/haps/entry/files/filename.jpeg';
      let conversationListViewInfo = new ConversationListViewInfo(re);
      let context: Context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      (conversationListModel as object)['dealMmsListContent'](conversationListViewInfo, context)
    })

    it('ConversationListModel_dealMmsListContent_mp3', 0, () => {
      let re = new ConversationListInfo();
      re.telephone = 'sip:12947395573botplatform0';
      re.contactName = 'contactName';
      re.contactsNum = 1;
      re.smsType = 1;
      re.hasMms = 1;
      re.hasAttachment = 1;
      re.content = '/data/storage/el2/base/haps/entry/files/filename.mp3';
      let conversationListViewInfo = new ConversationListViewInfo(re);
      let context: Context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      (conversationListModel as object)['dealMmsListContent'](conversationListViewInfo, context)
    })

    it('ConversationListModel_dealMmsListContent_txt', 0, () => {
      let re = new ConversationListInfo();
      re.telephone = 'sip:12947395573botplatform0';
      re.contactName = 'contactName';
      re.contactsNum = 1;
      re.smsType = 1;
      re.hasMms = 1;
      re.hasAttachment = 1;
      re.content = '/data/storage/el2/base/haps/entry/files/filename.txt';
      let conversationListViewInfo = new ConversationListViewInfo(re);
      let context: Context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      (conversationListModel as object)['dealMmsListContent'](conversationListViewInfo, context)
    })

    it('ConversationListModel_dealMmsListContent_mp4', 0, () => {
      let re = new ConversationListInfo();
      re.telephone = 'sip:12947395573botplatform0';
      re.contactName = 'contactName';
      re.contactsNum = 1;
      re.smsType = 1;
      re.hasMms = 1;
      re.hasAttachment = 1;
      re.content = '/data/storage/el2/base/haps/entry/files/filename.mp4';
      let conversationListViewInfo = new ConversationListViewInfo(re);
      let context: Context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      (conversationListModel as object)['dealMmsListContent'](conversationListViewInfo, context)
    })

    it('ConversationListModel_dealMmsListContent_content_empty', 0, () => {
      let re = new ConversationListInfo();
      re.telephone = 'sip:12947395573botplatform0';
      re.contactName = 'contactName';
      re.contactsNum = 1;
      re.smsType = 1;
      re.hasMms = 1;
      re.hasAttachment = 1;
      re.content = '';
      let conversationListViewInfo = new ConversationListViewInfo(re);
      let context: Context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      (conversationListModel as object)['dealMmsListContent'](conversationListViewInfo, context)
    })

    it('ConversationListModel_dealMmsListContent_isJSONString', 0, () => {
      let re = new ConversationListInfo();
      re.telephone = 'sip:12947395573botplatform0';
      re.contactName = 'contactName';
      re.contactsNum = 1;
      re.smsType = 1;
      re.hasMms = 1;
      re.hasAttachment = 1;
      re.content = '{"path": "/data/storage/el2/base/haps/entry/files/filename.jpeg"}';
      let conversationListViewInfo = new ConversationListViewInfo(re);
      let context: Context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      (conversationListModel as object)['dealMmsListContent'](conversationListViewInfo, context)
    })

    it('ConversationListModel_dealMmsListContent_hasAttachment_0_content_empty', 0, () => {
      let re = new ConversationListInfo();
      re.telephone = 'sip:12947395573botplatform0';
      re.contactName = 'contactName';
      re.contactsNum = 1;
      re.smsType = 1;
      re.hasMms = 1;
      re.hasAttachment = 0;
      re.content = '';
      let conversationListViewInfo = new ConversationListViewInfo(re);
      let context: Context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      (conversationListModel as object)['dealMmsListContent'](conversationListViewInfo, context)
    })

    it('ConversationListModel_dealMmsListContent_hasAttachment_0', 0, () => {
      let re = new ConversationListInfo();
      re.telephone = 'sip:12947395573botplatform0';
      re.contactName = 'contactName';
      re.contactsNum = 1;
      re.smsType = 1;
      re.hasMms = 1;
      re.hasAttachment = 0;
      re.content = 'filename.jpeg';
      let conversationListViewInfo = new ConversationListViewInfo(re);
      let context: Context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      (conversationListModel as object)['dealMmsListContent'](conversationListViewInfo, context)
    })

    it('ConversationListModel_dealMmsListContent_hasAttachment_0_isJSONString', 0, () => {
      let re = new ConversationListInfo();
      re.telephone = 'sip:12947395573botplatform0';
      re.contactName = 'contactName';
      re.contactsNum = 1;
      re.smsType = 1;
      re.hasMms = 1;
      re.hasAttachment = 0;
      re.content = '{"path": "/data/storage/el2/base/haps/entry/files/filename.jpeg"}';
      let conversationListViewInfo = new ConversationListViewInfo(re);
      let context: Context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      (conversationListModel as object)['dealMmsListContent'](conversationListViewInfo, context)
    })

    it('ConversationListModel_getConversationLastRcsVCardMessageTips_item_empty', 0, () => {
      (conversationListModel as object)['getConversationLastRcsVCardMessageTips']({}, {})
    })

    it('ConversationListModel_getConversationLastRcsVCardMessageTips_contactNum_0', 0, () => {
      (conversationListModel as object)['getConversationLastRcsVCardMessageTips']({ contactNum: 0 },
        { contactName: '12', telephone: '18246737834' })
    })

    it('ConversationListModel_getConversationLastRcsVCardMessageTips', 0, () => {
      (conversationListModel as object)['getConversationLastRcsVCardMessageTips']({ contactNum: 1, isSendMessage: 1 },
        { contactName: '12', telephone: '18246737834', contactsNum: 1 })
    })

    it('ConversationListModel_getConversationLastRcsVCardMessageTips_isSendMessage_0', 0, () => {
      (conversationListModel as object)['getConversationLastRcsVCardMessageTips']({ contactNum: 1, isSendMessage: 0 },
        { contactName: '12', telephone: '18246737834', contactsNum: 1 })
    })

    it('ConversationListModel_getConversationLastRcsVCardMessageTips_item_contactsNum_0', 0, () => {
      (conversationListModel as object)['getConversationLastRcsVCardMessageTips']({ contactNum: 1, isSendMessage: 1 },
        { contactName: '', telephone: '', contactsNum: 0 })
    })

    it('ConversationListModel_getConversationLastRcsVCardMessageTips_item_contactsNum_2', 0, () => {
      (conversationListModel as object)['getConversationLastRcsVCardMessageTips']({
        contactName: 'contactName',
        contactNum: 1,
        isSendMessage: 1
      },
        { contactName: '', telephone: '', contactsNum: 0 })
    })

    it('ConversationListModel_getConversationLastMessageTips_content_empty', 0, () => {
      let context: Context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      (conversationListModel as object)['getConversationLastMessageTips']({
        content: ''
      }, context)
    })

    it('ConversationListModel_getConversationLastMessageTips', 0, () => {
      let context: Context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      (conversationListModel as object)['getConversationLastMessageTips']({
        content: '{"name": "content"}'
      }, context)
    })

    it('ConversationListModel_getLastMessageTips_value_empty', 0, () => {
      let result: boolean = (conversationListModel as object)['getLastMessageTips']({}) as boolean;
      expect(result).assertFalse()
    })

    it('ConversationListModel_getLastMessageTips', 0, () => {
      let result: boolean = (conversationListModel as object)['getLastMessageTips']({
        body: 'body',
        latitude: 'latitude',
        longitude: 'longitude',
        accuracy: 'accuracy'
      }) as boolean;
      expect(result).assertTrue()
    })

    it('ConversationListModel_getSessionFormatPhoneNumber', 0, () => {
      let telephoneMap: Map<string, LooseObject> = new Map<string, LooseObject>();
      telephoneMap.set('detailInfo', {  });
      (conversationListModel as object)['getSessionFormatPhoneNumber']([{
        detailInfo: 'detailInfo',
        id: 1,
        rawContactId: '1',
        contactId: '1',
        displayName: '',
      }], [], telephoneMap);
    })

    it('ConversationListModel_dealMultiNameByYellowPage_telephones_null', 0, () => {
      let yellowPageMap: Map<string, LooseObject> = new Map<string, LooseObject>();
      yellowPageMap.set('detailInfo', {  });
      (conversationListModel as object)['dealMultiNameByYellowPage']({
        telephone: '',
        rawContactId: '',
        name: '1'
      }, yellowPageMap, []);
    })

    it('ConversationListModel_dealMultiNameByYellowPage', 0, () => {
      let yellowPageMap: Map<string, LooseObject> = new Map<string, LooseObject>();
      yellowPageMap.set('110', { rawYellowPageId: '2354' });
      yellowPageMap.set('120', {  });
      (conversationListModel as object)['dealMultiNameByYellowPage']({
        telephone: '110,120,911',
        rawContactId: '',
        name: '110, 120, 911',
        yellowPageId: '2354'
      }, yellowPageMap, []);
    })

    it('ConversationListModel_dealMultiName_telephones_empty', 0, () => {
      let telephoneMap: Map<string, LooseObject> = new Map<string, LooseObject>();
      telephoneMap.set('detailInfo', {  });
      (conversationListModel as object)['dealMultiName']({
        telephone: '',
        rawContactId: '',
        name: '1'
      }, telephoneMap);
    })

    it('ConversationListModel_dealMultiName', 0, () => {
      let telephoneMap: Map<string, LooseObject> = new Map<string, LooseObject>();
      telephoneMap.set('110', {  });
      (conversationListModel as object)['dealMultiName']({
        telephone: '11 0,12 0,9 11',
        rawContactId: '110,120,911',
        name: '110, 120, 911',
        yellowPageId: '2354'
      }, telephoneMap);
    })

    it('ConversationListModel_processSessionName', 0, () => {
      (conversationListModel as object)['processSessionName']({
        name: '110, 120, 911, 122',
        rawContactId: '110,120,911, 122',
        contactId: '110,120,911, 122',
        photoFirstNames: []
      });
    })
  })
}