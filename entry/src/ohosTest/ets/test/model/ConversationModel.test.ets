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
import { ArgumentMatchers, beforeEach, describe, expect, it, MockKit, when } from '@ohos/hypium';
import ConversationModel, {
  queryContactsAvatarInContactDataDataBase
} from '../../../../main/ets/model/ConversationModel';
import { dataShare, dataSharePredicates, DataShareResultSet, ValuesBucket } from '@kit.ArkData';
import LooseObject from '../../../../main/ets/data/LooseObject';
import { DTGlobalContext } from '../../testability/TestAbility';
import DataShareHelper from '../../../../main/ets/model/repository/DataShareHelper';
import { BusinessError } from '@kit.BasicServicesKit';
import mmsTable from '../../../../main/ets/data/tableData';
import MySet from '../MySet';
import { MarkRead } from '../../../../main/ets/data/commonData';

export default function conversationModelTest() {
  describe('conversationModelTest', () => {

    let conversationModel: ConversationModel;

    beforeEach(() => {
      conversationModel = new ConversationModel();
    })

    it('conversationModelTest_deleteTemporaryDb_dataHelper_null', 0, async () => {
      let callback: Function = (result: LooseObject) => { };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper | undefined>(resolve => resolve(undefined))));
      await conversationModel.deleteTemporaryDb(callback, context);
      mocker.clear(DataShareHelper.getInstance());
      expect(context).not().assertUndefined();
    })

    it('conversationModelTest_deleteTemporaryDb_dataHelper_null_callback_null', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper | undefined>(resolve => resolve(undefined))));
      await conversationModel.deleteTemporaryDb(undefined, context);
      mocker.clear(DataShareHelper.getInstance());
      expect(context).not().assertUndefined();
    })

    it('conversationModelTest_deleteTemporaryDb_dataHelper_not_null', 0, async () => {
      let callback: Function = (result: LooseObject) => { };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve({
          delete: (uri: string, predicates: dataSharePredicates.DataSharePredicates): Promise<number> =>
          new Promise<number>(resolve => resolve(1))
        } as dataShare.DataShareHelper))));
      await conversationModel.deleteTemporaryDb(callback, context);
      mocker.clear(DataShareHelper.getInstance());
      expect(context).not().assertUndefined();
    })

    it('conversationModelTest_deleteTemporaryDb_dataHelper_not_null_callback_null', 0, async () => {
      let callback: Function = (result: LooseObject) => { };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve({
          delete: (uri: string, predicates: dataSharePredicates.DataSharePredicates): Promise<number> =>
          new Promise<number>(resolve => resolve(1))
        } as dataShare.DataShareHelper))));
      await conversationModel.deleteTemporaryDb(undefined, context);
      mocker.clear(DataShareHelper.getInstance());
      expect(context).not().assertUndefined();
    })

    it('conversationModelTest_deleteTemporaryDb_dataHelper_not_null_catch', 0, async () => {
      let callback: Function = (result: LooseObject) => { };
      let error: BusinessError = {
        code: 1, message: 'error'
      } as BusinessError;
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve({
          delete: (uri: string, predicates: dataSharePredicates.DataSharePredicates): Promise<number> =>
          new Promise<number>((resolve: (value: number | PromiseLike<number>) => void,
            reject: (reason?: BusinessError) => void) =>
          reject(error))
        } as dataShare.DataShareHelper))));
      await conversationModel.deleteTemporaryDb(callback, context);
      mocker.clear(DataShareHelper.getInstance());
      expect(context).not().assertUndefined();
    })

    it('conversationModelTest_deleteTemporaryDb_dataHelper_not_null_catch_callback_null', 0, async () => {
      let callback: Function = (result: LooseObject) => { };
      let error: BusinessError = {
        code: 1, message: 'error'
      } as BusinessError;
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve({
          delete: (uri: string, predicates: dataSharePredicates.DataSharePredicates): Promise<number> =>
          new Promise<number>((resolve: (value: number | PromiseLike<number>) => void,
            reject: (reason?: BusinessError) => void) =>
          reject(error))
        } as dataShare.DataShareHelper))));
      await conversationModel.deleteTemporaryDb(undefined, context);
      mocker.clear(DataShareHelper.getInstance());
      expect(context).not().assertUndefined();
    })

    it('conversationModelTest_insertSmsMmsInfo_if1_if2', 0, async () => {
      let valueBucket: ValuesBucket = {
        'telephone': '570977632'
      };
      let callback: Function = (result: LooseObject) => {
        expect(JSON.stringify(result)).assertEqual('{}');
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve(undefined))));

      let encapsulateReturnCode: Function = mocker.mockFunc(conversationModel, conversationModel.encapsulateReturnCode);
      when(encapsulateReturnCode)(-1).afterReturn({});

      await conversationModel.insertSmsMmsInfo(valueBucket, callback, context);
      expect(context).not().assertUndefined();
      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_insertSmsMmsInfo_if1_if2_callback_null', 0, async () => {
      let valueBucket: ValuesBucket = {
        'telephone': '570977632'
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve(undefined))));

      let encapsulateReturnCode: Function = mocker.mockFunc(conversationModel, conversationModel.encapsulateReturnCode);
      when(encapsulateReturnCode)(-1).afterReturn({});

      await conversationModel.insertSmsMmsInfo(valueBucket, undefined, context);
      expect(context).not().assertUndefined();
      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_insertSmsMmsInfo_if3', 0, async () => {
      let valueBucket: ValuesBucket = {
        'telephone': '570977632'
      };
      let callback: Function = (result: LooseObject) => {
        expect(JSON.stringify(result)).assertEqual('{}');
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve({
          insert: (uri: string, value: ValuesBucket): Promise<number> =>
          new Promise<number>(resolve => resolve(1))
        } as dataShare.DataShareHelper))));

      let encapsulateReturnResult: Function =
        mocker.mockFunc(conversationModel, conversationModel.encapsulateReturnResult);
      when(encapsulateReturnResult)(0).afterReturn({});

      await conversationModel.insertSmsMmsInfo(valueBucket, callback, context);
      expect(context).not().assertUndefined();
      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_insertSmsMmsInfo_if3_callback_null', 0, async () => {
      let valueBucket: ValuesBucket = {
        'telephone': '570977632'
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve({
          insert: (uri: string, value: ValuesBucket): Promise<number> =>
          new Promise<number>(resolve => resolve(1))
        } as dataShare.DataShareHelper))));

      let encapsulateReturnResult: Function =
        mocker.mockFunc(conversationModel, conversationModel.encapsulateReturnResult);
      when(encapsulateReturnResult)(0).afterReturn({});

      await conversationModel.insertSmsMmsInfo(valueBucket, undefined, context);
      expect(context).not().assertUndefined();
      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_insertSmsMmsInfo_businessError', 0, async () => {
      let valueBucket: ValuesBucket = {
        'telephone': '570977632'
      };
      let callback: Function = (result: LooseObject) => {
        expect(result.code).assertEqual(-1);
      };
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

      await conversationModel.insertSmsMmsInfo(valueBucket, callback, context);
      expect(context).not().assertUndefined();
      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_insertSmsMmsInfo_businessError_callBack_null', 0, async () => {
      let valueBucket: ValuesBucket = {
        'telephone': '570977632'
      };
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

      await conversationModel.insertSmsMmsInfo(valueBucket, undefined, context);
      expect(context).not().assertUndefined();
      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_deleteSmsMmsInfoByCondition_if1_if2', 0, async () => {
      let actionData: LooseObject = {
        'isNoReceiverDraft': true,
        'threadId': '1789',
        'needDistinct': '',
        'page': 1,
        'content': '50',
        'smsType': '',
        'currentTimeStamp': 0,
        'orderByTimeDesc': true,
        'limit': 10,
        'hasRead': '',
        'msgId': '',
        'isDraft': '',
        'groupId': '',
        'sendStatus': '',
        'threadIds': ['9091'],
        'msgIds': [''],
        'groupIds': ['']
      };
      let callback: Function = (result: LooseObject) => {
        expect(JSON.stringify(result)).assertEqual('{}');
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve(undefined))));

      let encapsulateReturnCode: Function = mocker.mockFunc(conversationModel, conversationModel.encapsulateReturnCode);
      when(encapsulateReturnCode)(-1).afterReturn({});

      await conversationModel.deleteSmsMmsInfoByCondition(actionData, callback, context);
      expect(context).not().assertUndefined();
      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_deleteSmsMmsInfoByCondition_if1_if2_callback_null', 0, async () => {
      let actionData: LooseObject = {};
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve(undefined))));

      let encapsulateReturnCode: Function = mocker.mockFunc(conversationModel, conversationModel.encapsulateReturnCode);
      when(encapsulateReturnCode)(-1).afterReturn({});

      await conversationModel.deleteSmsMmsInfoByCondition(actionData, undefined, context);
      expect(context).not().assertUndefined();
      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_deleteSmsMmsInfoByCondition_if3_buildQuerySmsMmsInfoCondition_if1', 0, async () => {
      let actionData: LooseObject = {
        'isNoReceiverDraft': true,
        'threadId': '1789',
        'needDistinct': '',
        'page': 1,
        'content': '50',
        'smsType': '',
        'currentTimeStamp': 0,
        'orderByTimeDesc': true,
        'limit': 10,
        'hasRead': '',
        'msgId': '',
        'isDraft': '',
        'groupId': '',
        'sendStatus': '',
        'threadIds': ['9091'],
        'msgIds': [''],
        'groupIds': [''],
        'deleteMessage': 0
      };
      let callback: Function = (result: LooseObject) => {
        expect(JSON.stringify(result)).assertEqual('{}');
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve({
          delete: (uri: string, predicates: dataSharePredicates.DataSharePredicates): Promise<number> =>
          new Promise<number>(resolve => resolve(1))
        } as dataShare.DataShareHelper))));

      let encapsulateReturnResult: Function =
        mocker.mockFunc(conversationModel, conversationModel.encapsulateReturnResult);
      when(encapsulateReturnResult)(0).afterReturn({});

      await conversationModel.deleteSmsMmsInfoByCondition(actionData, callback, context);
      expect(context).not().assertUndefined();
      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_deleteSmsMmsInfoByCondition_if3_buildQuerySmsMmsInfoCondition_else_if2_ifs', 0,
      async () => {
        let actionData: LooseObject = {
          'isNoReceiverDraft': false,
          'threadId': '1789',
          'needDistinct': '',
          'page': 1,
          'content': '50',
          'smsType': '',
          'currentTimeStamp': 0,
          'orderByTimeDesc': true,
          'limit': 10,
          'hasRead': '',
          'msgId': '',
          'isDraft': '',
          'groupId': '',
          'sendStatus': '',
          'threadIds': ['9091'],
          'msgIds': [''],
          'groupIds': [''],
          'deleteMessage': 1
        };
        let callback: Function = (result: LooseObject) => {
          expect(JSON.stringify(result)).assertEqual('{}');
        };
        let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
        let mocker: MockKit = new MockKit();

        when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
          .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve({
            delete: (uri: string, predicates: dataSharePredicates.DataSharePredicates): Promise<number> =>
            new Promise<number>(resolve => resolve(1))
          } as dataShare.DataShareHelper))));

        let encapsulateReturnResult: Function =
          mocker.mockFunc(conversationModel, conversationModel.encapsulateReturnResult);
        when(encapsulateReturnResult)(0).afterReturn({});

        await conversationModel.deleteSmsMmsInfoByCondition(actionData, callback, context);
        expect(context).not().assertUndefined();
        mocker.clear(conversationModel);
        mocker.clear(DataShareHelper.getInstance());
      })

    it('conversationModelTest_deleteSmsMmsInfoByCondition_if3_buildQuerySmsMmsInfoCondition_else_else_else', 0,
      async () => {
        let actionData: LooseObject = {
          'isNoReceiverDraft': false,
          'threadId': null,
          'needDistinct': null,
          'page': null,
          'content': '',
          'smsType': null,
          'currentTimeStamp': undefined,
          'orderByTimeDesc': true,
          'limit': null,
          'hasRead': null,
          'msgId': null,
          'isDraft': null,
          'groupId': null,
          'sendStatus': '',
          'threadIds': ['9091'],
          'msgIds': [],
          'groupIds': [],
          'deleteMessage': 2
        };
        let callback: Function = (result: LooseObject) => {
          expect(JSON.stringify(result)).assertEqual('{}');
        };
        let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
        let mocker: MockKit = new MockKit();

        when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
          .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve({
            delete: (uri: string, predicates: dataSharePredicates.DataSharePredicates): Promise<number> =>
            new Promise<number>(resolve => resolve(1))
          } as dataShare.DataShareHelper))));

        let encapsulateReturnResult: Function =
          mocker.mockFunc(conversationModel, conversationModel.encapsulateReturnResult);
        when(encapsulateReturnResult)(0).afterReturn({});

        await conversationModel.deleteSmsMmsInfoByCondition(actionData, callback, context);
        expect(context).not().assertUndefined();
        mocker.clear(conversationModel);
        mocker.clear(DataShareHelper.getInstance());
      })

    it('conversationModelTest_deleteSmsMmsInfoByCondition_if3_buildConditionFromQuerySmsMmsInfo_if4_if7', 0,
      async () => {
        let actionData: LooseObject = {
          'isNoReceiverDraft': false,
          'threadId': '1',
          'needDistinct': null,
          'page': null,
          'content': '',
          'smsType': '1',
          'isDraft':true,
          'currentTimeStamp': '',
          'orderByTimeDesc': true,
          'limit': null,
          'hasLock': null,
          'hasRead': null,
          'msgId': null,
          'groupId': null,
          'sendStatus': '',
          'threadIds': ['9091'],
          'msgIds': [],
          'groupIds': []
        };
        let callback: Function = (result: LooseObject) => {
          expect(JSON.stringify(result)).assertEqual('{}');
        };
        let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
        let mocker: MockKit = new MockKit();

        when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
          .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve({
            delete: (uri: string, predicates: dataSharePredicates.DataSharePredicates): Promise<number> =>
            new Promise<number>(resolve => resolve(1))
          } as dataShare.DataShareHelper))));

        let encapsulateReturnResult: Function =
          mocker.mockFunc(conversationModel, conversationModel.encapsulateReturnResult);
        when(encapsulateReturnResult)(0).afterReturn({});

        await conversationModel.deleteSmsMmsInfoByCondition(actionData, callback, context);
        expect(context).not().assertUndefined();
        mocker.clear(conversationModel);
        mocker.clear(DataShareHelper.getInstance());
      })

    it('conversationModelTest_deleteSmsMmsInfoByCondition_businessError', 0, async () => {
      let actionData: LooseObject = {
        'isNoReceiverDraft': true,
        'threadId': null,
        'needDistinct': null,
        'page': null,
        'content': '',
        'smsType': null,
        'currentTimeStamp': undefined,
        'orderByTimeDesc': true,
        'limit': null,
        'hasRead': null,
        'msgId': null,
        'isDraft': null,
        'groupId': null,
        'sendStatus': '',
        'threadIds': ['9091'],
        'msgIds': [],
        'groupIds': []
      };
      let callback: Function = (result: LooseObject) => {
        expect(result.code).assertEqual(-1);
      };
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

      await conversationModel.deleteSmsMmsInfoByCondition(actionData, callback, context);
      expect(context).not().assertUndefined();
      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_deleteSmsMmsInfoByCondition_businessError_callback_null', 0, async () => {
      let actionData: LooseObject = {
        'isNoReceiverDraft': true,
        'threadId': null,
        'needDistinct': null,
        'page': null,
        'content': '',
        'smsType': null,
        'currentTimeStamp': undefined,
        'orderByTimeDesc': true,
        'limit': null,
        'hasRead': null,
        'msgId': null,
        'isDraft': null,
        'groupId': null,
        'sendStatus': '',
        'threadIds': ['9091'],
        'msgIds': [],
        'groupIds': []
      };
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

      await conversationModel.deleteSmsMmsInfoByCondition(actionData, undefined, context);
      expect(context).not().assertUndefined();
      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_updateSmsMmsInfoByCondition_if1_if2', 0, async () => {
      let actionData: LooseObject = {
        'isNoReceiverDraft': true,
        'threadId': '1789',
        'needDistinct': '',
        'page': 1,
        'content': '50',
        'smsType': '',
        'currentTimeStamp': 0,
        'orderByTimeDesc': true,
        'limit': 10,
        'hasRead': '',
        'msgId': '',
        'isDraft': '',
        'groupId': '',
        'sendStatus': '',
        'threadIds': ['9091'],
        'msgIds': [''],
        'groupIds': ['']
      };
      let valueBucket: ValuesBucket = {
        'telephone': '570977632'
      };
      let callback: Function = (result: LooseObject) => {
        expect(JSON.stringify(result)).assertEqual('{}');
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve(undefined))));

      let encapsulateReturnCode: Function = mocker.mockFunc(conversationModel, conversationModel.encapsulateReturnCode);
      when(encapsulateReturnCode)(-1).afterReturn({});

      await conversationModel.updateSmsMmsInfoByCondition(actionData, valueBucket, callback, context);
      expect(context).not().assertUndefined();
      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_updateSmsMmsInfoByCondition_if1_if2_callback_null', 0, async () => {
      let actionData: LooseObject = {};
      let valueBucket: ValuesBucket = {
        'telephone': '570977632'
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve(undefined))));

      let encapsulateReturnCode: Function = mocker.mockFunc(conversationModel, conversationModel.encapsulateReturnCode);
      when(encapsulateReturnCode)(-1).afterReturn({});

      await conversationModel.updateSmsMmsInfoByCondition(actionData, valueBucket, undefined, context);
      expect(context).not().assertUndefined();
      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_updateSmsMmsInfoByCondition_if3_buildQuerySmsMmsInfoCondition_if1', 0, async () => {
      let actionData: LooseObject = {
        'isNoReceiverDraft': true,
        'threadId': '1789',
        'needDistinct': '',
        'page': 1,
        'content': '50',
        'smsType': '',
        'currentTimeStamp': 0,
        'orderByTimeDesc': true,
        'limit': 10,
        'hasRead': '',
        'msgId': '',
        'isDraft': '',
        'groupId': '',
        'sendStatus': '',
        'threadIds': ['9091'],
        'msgIds': [''],
        'groupIds': ['']
      };
      let valueBucket: ValuesBucket = {
        'isNoReceiverDraft': true
      };
      let callback: Function = (result: LooseObject) => {
        expect(JSON.stringify(result)).assertEqual('{}');
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve({
          update: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            value: ValuesBucket): Promise<number> =>
          new Promise<number>(resolve => resolve(1))
        } as dataShare.DataShareHelper))));

      let encapsulateReturnResult: Function =
        mocker.mockFunc(conversationModel, conversationModel.encapsulateReturnResult);
      when(encapsulateReturnResult)(0).afterReturn({});

      await conversationModel.updateSmsMmsInfoByCondition(actionData, valueBucket, callback, context);
      expect(context).not().assertUndefined();
      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_updateSmsMmsInfoByCondition_if3_buildQuerySmsMmsInfoCondition_if1_callback_null', 0, async () => {
      let actionData: LooseObject = {
        'isNoReceiverDraft': true,
        'threadId': '1789',
        'needDistinct': '',
        'page': 1,
        'content': '50',
        'smsType': '',
        'currentTimeStamp': 0,
        'orderByTimeDesc': true,
        'limit': 10,
        'hasRead': '',
        'msgId': '',
        'isDraft': '',
        'groupId': '',
        'sendStatus': '',
        'threadIds': ['9091'],
        'msgIds': [''],
        'groupIds': ['']
      };
      let valueBucket: ValuesBucket = {
        'isNoReceiverDraft': true
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve({
          update: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            value: ValuesBucket): Promise<number> =>
          new Promise<number>(resolve => resolve(1))
        } as dataShare.DataShareHelper))));

      let encapsulateReturnResult: Function =
        mocker.mockFunc(conversationModel, conversationModel.encapsulateReturnResult);
      when(encapsulateReturnResult)(0).afterReturn({});

      await conversationModel.updateSmsMmsInfoByCondition(actionData, valueBucket, undefined, context);
      expect(context).not().assertUndefined();
      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_updateSmsMmsInfoByCondition_if3_buildQuerySmsMmsInfoCondition_else_if2_ifs', 0,
      async () => {
        let actionData: LooseObject = {
          'isNoReceiverDraft': false,
          'threadId': '1789',
          'needDistinct': '',
          'page': 1,
          'content': '50',
          'smsType': '',
          'currentTimeStamp': 0,
          'orderByTimeDesc': true,
          'limit': 10,
          'hasRead': '',
          'msgId': '',
          'isDraft': '',
          'groupId': '',
          'sendStatus': '',
          'threadIds': ['9091'],
          'msgIds': [''],
          'groupIds': ['']
        };
        let valueBucket: ValuesBucket = {
          'telephone': '570977632'
        };
        let callback: Function = (result: LooseObject) => {
          expect(JSON.stringify(result)).assertEqual('{}');
        };
        let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
        let mocker: MockKit = new MockKit();

        when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
          .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve({
            update: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
              value: ValuesBucket): Promise<number> =>
            new Promise<number>(resolve => resolve(1))
          } as dataShare.DataShareHelper))));

        let encapsulateReturnResult: Function =
          mocker.mockFunc(conversationModel, conversationModel.encapsulateReturnResult);
        when(encapsulateReturnResult)(0).afterReturn({});

        await conversationModel.updateSmsMmsInfoByCondition(actionData, valueBucket, callback, context);
        expect(context).not().assertUndefined();
        mocker.clear(conversationModel);
        mocker.clear(DataShareHelper.getInstance());
      })

    it('conversationModelTest_updateSmsMmsInfoByCondition_if3_buildQuerySmsMmsInfoCondition_else_else_else', 0,
      async () => {
        let actionData: LooseObject = {
          'isNoReceiverDraft': false,
          'threadId': null,
          'needDistinct': null,
          'page': null,
          'content': '',
          'smsType': null,
          'currentTimeStamp': undefined,
          'orderByTimeDesc': true,
          'limit': null,
          'hasRead': null,
          'msgId': null,
          'isDraft': null,
          'groupId': null,
          'sendStatus': '',
          'threadIds': ['9091'],
          'msgIds': [],
          'groupIds': []
        };
        let valueBucket: ValuesBucket = {
          'telephone': '570977632'
        };
        let callback: Function = (result: LooseObject) => {
          expect(JSON.stringify(result)).assertEqual('{}');
        };
        let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
        let mocker: MockKit = new MockKit();

        when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
          .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve({
            update: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
              value: ValuesBucket): Promise<number> =>
            new Promise<number>(resolve => resolve(1))
          } as dataShare.DataShareHelper))));

        let encapsulateReturnResult: Function =
          mocker.mockFunc(conversationModel, conversationModel.encapsulateReturnResult);
        when(encapsulateReturnResult)(0).afterReturn({});

        await conversationModel.updateSmsMmsInfoByCondition(actionData, valueBucket, callback, context);
        expect(context).not().assertUndefined();
        mocker.clear(conversationModel);
        mocker.clear(DataShareHelper.getInstance());
      })

    it('conversationModelTest_updateSmsMmsInfoByCondition_businessError', 0, async () => {
      let actionData: LooseObject = {
        'isNoReceiverDraft': true,
        'threadId': null,
        'needDistinct': null,
        'page': null,
        'content': '',
        'smsType': null,
        'currentTimeStamp': undefined,
        'orderByTimeDesc': true,
        'limit': null,
        'hasRead': null,
        'msgId': null,
        'isDraft': null,
        'groupId': null,
        'sendStatus': '',
        'threadIds': ['9091'],
        'msgIds': [],
        'groupIds': []
      };
      let valueBucket: ValuesBucket = {
        'telephone': '570977632'
      };
      let callback: Function = (result: LooseObject) => {
        expect(result.code).assertEqual(-1);
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
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

      await conversationModel.updateSmsMmsInfoByCondition(actionData, valueBucket, callback, context);
      expect(context).not().assertUndefined();
      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_updateSmsMmsInfoByCondition_businessError_callback_null', 0, async () => {
      let actionData: LooseObject = {
        'isNoReceiverDraft': true,
        'threadId': null,
        'needDistinct': null,
        'page': null,
        'content': '',
        'smsType': null,
        'currentTimeStamp': undefined,
        'orderByTimeDesc': true,
        'limit': null,
        'hasRead': null,
        'msgId': null,
        'isDraft': null,
        'groupId': null,
        'sendStatus': '',
        'threadIds': ['9091'],
        'msgIds': [],
        'groupIds': []
      };
      let valueBucket: ValuesBucket = {
        'telephone': '570977632'
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
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

      await conversationModel.updateSmsMmsInfoByCondition(actionData, valueBucket, undefined, context);
      expect(context).not().assertUndefined();
      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_querySmsMmsInfoSlotIdByCondition_if1_if2', 0, async () => {
      let callback: Function = (result: LooseObject) => {
        expect(JSON.stringify(result)).assertEqual('{}');
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve(undefined))));

      let encapsulateReturnCode: Function = mocker.mockFunc(conversationModel, conversationModel.encapsulateReturnCode);
      when(encapsulateReturnCode)(-1).afterReturn({});

      await conversationModel.querySmsMmsInfoSlotIdByCondition('570977632', callback, context);
      expect(context).not().assertUndefined();
      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_querySmsMmsInfoSlotIdByCondition_if1_if2_callback_null', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve(undefined))));

      let encapsulateReturnCode: Function = mocker.mockFunc(conversationModel, conversationModel.encapsulateReturnCode);
      when(encapsulateReturnCode)(-1).afterReturn({});

      await conversationModel.querySmsMmsInfoSlotIdByCondition('570977632', undefined, context);
      expect(context).not().assertUndefined();
      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_querySmsMmsInfoSlotIdByCondition_if3_buildSmsMmsInfoSlotIdCondition_if', 0, async () => {
      let callback: Function = (result: LooseObject) => {
        expect(JSON.stringify(result)).assertEqual('{}');
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve({
            rowCount: 1,
            close: () => {
            },
            goToFirstRow: () => true,
            goToNextRow: () => false,
            getString: (columnIndex: number): string => 'xxx',
            getColumnIndex: (columnName: string): number => 0,
            getLong: (columnIndex: number): number => 0
          } as DataShareResultSet))
        } as dataShare.DataShareHelper)));

      let encapsulateReturnResult: Function =
        mocker.mockFunc(conversationModel, conversationModel.encapsulateReturnResult);
      when(encapsulateReturnResult)(0).afterReturn({});

      await conversationModel.querySmsMmsInfoSlotIdByCondition('570977632', callback, context);
      expect(context).not().assertUndefined();
      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_querySmsMmsInfoSlotIdByCondition_if3_buildSmsMmsInfoSlotIdCondition_noIf', 0,
      async () => {
        let callback: Function = (result: LooseObject) => {
          expect(JSON.stringify(result)).assertEqual('{}');
        };
        let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
        let mocker: MockKit = new MockKit();

        when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
          .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
            query: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
              columns: string[]): Promise<DataShareResultSet> =>
            new Promise<DataShareResultSet>(resolve => resolve({
              rowCount: 0,
              close: () => {
              },
              goToFirstRow: () => true,
              goToNextRow: () => false,
              getString: (columnIndex: number): string => 'xxx',
              getColumnIndex: (columnName: string): number => 0,
              getLong: (columnIndex: number): number => 0
            } as DataShareResultSet))
          } as dataShare.DataShareHelper)));

        let encapsulateReturnResult: Function =
          mocker.mockFunc(conversationModel, conversationModel.encapsulateReturnResult);
        when(encapsulateReturnResult)(0).afterReturn({});

        await conversationModel.querySmsMmsInfoSlotIdByCondition('', callback, context);
        expect(context).not().assertUndefined();
        mocker.clear(conversationModel);
        mocker.clear(DataShareHelper.getInstance());
      })

    it('conversationModelTest_querySmsMmsInfoSlotIdByCondition_businessError', 0, async () => {
      let callback: Function = (result: LooseObject) => {
        expect(result.code).assertEqual(-1);
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
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

      await conversationModel.querySmsMmsInfoSlotIdByCondition('', callback, context);

      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_querySmsMmsInfoByCondition_if1_if2', 0, async () => {
      let actionData: LooseObject = {
        'isNoReceiverDraft': true,
        'threadId': '1789',
        'needDistinct': '',
        'page': 1,
        'content': '50',
        'smsType': '',
        'currentTimeStamp': 0,
        'orderByTimeDesc': true,
        'limit': 10,
        'hasRead': '',
        'msgId': '',
        'isDraft': '',
        'groupId': '',
        'sendStatus': '',
        'threadIds': ['9091'],
        'msgIds': [''],
        'groupIds': ['']
      };
      let callback: Function = (result: LooseObject) => {
        expect(JSON.stringify(result)).assertEqual('{}');
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve(undefined))));

      let encapsulateReturnCode: Function = mocker.mockFunc(conversationModel, conversationModel.encapsulateReturnCode);
      when(encapsulateReturnCode)(-1).afterReturn({});

      await conversationModel.querySmsMmsInfoByCondition(actionData, callback, context);

      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_querySmsMmsInfoByCondition_if1_if2_callback_null', 0, async () => {
      let actionData: LooseObject = {};
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve(undefined))));

      let encapsulateReturnCode: Function = mocker.mockFunc(conversationModel, conversationModel.encapsulateReturnCode);
      when(encapsulateReturnCode)(-1).afterReturn({});

      await conversationModel.querySmsMmsInfoByCondition(actionData, undefined, context);
      expect(context).not().assertUndefined();
      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_querySmsMmsInfoByCondition_if3', 0, async () => {
      let actionData: LooseObject = {
        'isNoReceiverDraft': true,
        'threadId': '1789',
        'needDistinct': '',
        'page': 1,
        'content': '50',
        'smsType': '',
        'currentTimeStamp': 0,
        'orderByTimeDesc': true,
        'limit': 10,
        'hasRead': '',
        'msgId': '',
        'isDraft': '',
        'groupId': '',
        'sendStatus': '',
        'threadIds': ['9091'],
        'msgIds': [''],
        'groupIds': ['']
      };
      let callback: Function = (result: LooseObject) => {
        expect(JSON.stringify(result)).assertEqual('{}');
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();
      let mySet = new MySet();
      mySet.rowCount = 1;

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve(mySet))
        } as dataShare.DataShareHelper)));

      let encapsulateReturnResult: Function =
        mocker.mockFunc(conversationModel, conversationModel.encapsulateReturnResult);
      when(encapsulateReturnResult)(0).afterReturn({});

      await conversationModel.querySmsMmsInfoByCondition(actionData, callback, context);

      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_querySmsMmsInfoByCondition_noIf3', 0, async () => {
      let actionData: LooseObject = {
        'isNoReceiverDraft': true,
        'threadId': '1789',
        'needDistinct': '',
        'page': 1,
        'content': '50',
        'smsType': '',
        'currentTimeStamp': 0,
        'orderByTimeDesc': true,
        'limit': 10,
        'hasRead': '',
        'msgId': '',
        'isDraft': '',
        'groupId': '',
        'sendStatus': '',
        'threadIds': ['9091'],
        'msgIds': [''],
        'groupIds': ['']
      };
      let callback: Function = (result: LooseObject) => {
        expect(JSON.stringify(result)).assertEqual('{}');
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve(new MySet()))
        } as dataShare.DataShareHelper)));

      let encapsulateReturnResult: Function =
        mocker.mockFunc(conversationModel, conversationModel.encapsulateReturnResult);
      when(encapsulateReturnResult)(0).afterReturn({});

      await conversationModel.querySmsMmsInfoByCondition(actionData, callback, context);

      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_querySmsMmsInfoByCondition_businessError', 0, async () => {
      let actionData: LooseObject = {
        'isNoReceiverDraft': true,
        'threadId': null,
        'needDistinct': null,
        'page': null,
        'content': '',
        'smsType': null,
        'currentTimeStamp': undefined,
        'orderByTimeDesc': true,
        'limit': null,
        'hasRead': null,
        'msgId': null,
        'isDraft': null,
        'groupId': null,
        'sendStatus': '',
        'threadIds': ['9091'],
        'msgIds': [],
        'groupIds': []
      };
      let callback: Function = (result: LooseObject) => {
        expect(result.code).assertEqual(-1);
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
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

      await conversationModel.querySmsMmsInfoByCondition(actionData, callback, context);

      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_querySmsMmsInfoByConditionAll_if1_if2', 0, async () => {
      let actionData: LooseObject = {
        'isNoReceiverDraft': true,
        'threadId': '1789',
        'needDistinct': '',
        'page': 1,
        'content': '50',
        'smsType': '',
        'currentTimeStamp': 0,
        'orderByTimeDesc': true,
        'limit': 10,
        'hasRead': '',
        'msgId': '',
        'isDraft': '',
        'groupId': '',
        'sendStatus': '',
        'threadIds': ['9091'],
        'msgIds': [''],
        'groupIds': ['']
      };
      let callback: Function = (result: LooseObject) => {
        expect(JSON.stringify(result)).assertEqual('{}');
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve(undefined))));

      let encapsulateReturnCode: Function = mocker.mockFunc(conversationModel, conversationModel.encapsulateReturnCode);
      when(encapsulateReturnCode)(-1).afterReturn({});

      await conversationModel.querySmsMmsInfoByConditionAll(actionData, callback, context);

      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_querySmsMmsInfoByConditionAll_if1_if2_callback_null', 0, async () => {
      let actionData: LooseObject = {};
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve(undefined))));

      let encapsulateReturnCode: Function = mocker.mockFunc(conversationModel, conversationModel.encapsulateReturnCode);
      when(encapsulateReturnCode)(-1).afterReturn({});

      await conversationModel.querySmsMmsInfoByConditionAll(actionData, undefined, context);
      expect(context).not().assertNull();
      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_querySmsMmsInfoByConditionAll_if3', 0, async () => {
      let actionData: LooseObject = {
        'isNoReceiverDraft': true,
        'threadId': '1789',
        'needDistinct': '',
        'page': 1,
        'content': '50',
        'smsType': '',
        'currentTimeStamp': 0,
        'orderByTimeDesc': true,
        'limit': 10,
        'hasRead': '',
        'msgId': '',
        'isDraft': '',
        'groupId': '',
        'sendStatus': '',
        'threadIds': ['9091'],
        'msgIds': [''],
        'groupIds': ['']
      };
      let callback: Function = (result: LooseObject) => {
        expect(JSON.stringify(result)).assertEqual('{}');
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();
      let mySet: DataShareResultSet = new MySet();
      mySet.rowCount = 1;

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve(mySet))
        } as dataShare.DataShareHelper)));

      let encapsulateReturnResult: Function =
        mocker.mockFunc(conversationModel, conversationModel.encapsulateReturnResult);
      when(encapsulateReturnResult)(0).afterReturn({});

      await conversationModel.querySmsMmsInfoByConditionAll(actionData, callback, context);

      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_querySmsMmsInfoByConditionAll_noIf3', 0, async () => {
      let actionData: LooseObject = {
        'isNoReceiverDraft': true,
        'threadId': '1789',
        'needDistinct': '',
        'page': 1,
        'content': '50',
        'smsType': '',
        'currentTimeStamp': 0,
        'orderByTimeDesc': true,
        'limit': 10,
        'hasRead': '',
        'msgId': '',
        'isDraft': '',
        'groupId': '',
        'sendStatus': '',
        'threadIds': ['9091'],
        'msgIds': [''],
        'groupIds': ['']
      };
      let callback: Function = (result: LooseObject) => {
        expect(JSON.stringify(result)).assertEqual('{}');
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve(new MySet()))
        } as dataShare.DataShareHelper)));

      let encapsulateReturnResult: Function =
        mocker.mockFunc(conversationModel, conversationModel.encapsulateReturnResult);
      when(encapsulateReturnResult)(0).afterReturn({});

      await conversationModel.querySmsMmsInfoByConditionAll(actionData, callback, context);

      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_querySmsMmsInfoByConditionAll_businessError', 0, async () => {
      let actionData: LooseObject = {
        'isNoReceiverDraft': true,
        'threadId': null,
        'needDistinct': null,
        'page': null,
        'content': '',
        'smsType': null,
        'currentTimeStamp': undefined,
        'orderByTimeDesc': true,
        'limit': null,
        'hasRead': null,
        'msgId': null,
        'isDraft': null,
        'groupId': null,
        'sendStatus': '',
        'threadIds': ['9091'],
        'msgIds': [],
        'groupIds': []
      };
      let callback: Function = (result: LooseObject) => {
        expect(result.code).assertEqual(-1);
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
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

      await conversationModel.querySmsMmsInfoByConditionAll(actionData, callback, context);

      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_queryMmsInfoByFavoriteCondition_if1_if2', 0, async () => {
      let actionData: LooseObject = {
        'isCollect': ''
      };
      let callback: Function = (result: LooseObject) => {
        expect(JSON.stringify(result)).assertEqual('{}');
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve(undefined))));

      let encapsulateReturnCode: Function = mocker.mockFunc(conversationModel, conversationModel.encapsulateReturnCode);
      when(encapsulateReturnCode)(-1).afterReturn({});

      await conversationModel.queryMmsInfoByFavoriteCondition(actionData, callback, context);

      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_queryMmsInfoByFavoriteCondition_if1_if2_callback_null', 0, async () => {
      let actionData: LooseObject = {
        'isCollect': ''
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve(undefined))));

      let encapsulateReturnCode: Function = mocker.mockFunc(conversationModel, conversationModel.encapsulateReturnCode);
      when(encapsulateReturnCode)(-1).afterReturn({});

      await conversationModel.queryMmsInfoByFavoriteCondition(actionData, undefined, context);
      expect(context).not().assertNull();
      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_queryMmsInfoByFavoriteCondition_if3', 0, async () => {
      let actionData: LooseObject = {
        'isCollect': ''
      };
      let callback: Function = (result: LooseObject) => {
        expect(JSON.stringify(result)).assertEqual('{}');
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();
      let mySet: DataShareResultSet = new MySet();
      mySet.rowCount = 1;

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve(mySet))
        } as dataShare.DataShareHelper)));

      let encapsulateReturnResult: Function =
        mocker.mockFunc(conversationModel, conversationModel.encapsulateReturnResult);
      when(encapsulateReturnResult)(0).afterReturn({});

      await conversationModel.queryMmsInfoByFavoriteCondition(actionData, callback, context);

      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_queryMmsInfoByFavoriteCondition_noIf3', 0, async () => {
      let actionData: LooseObject = {
        'isCollect': ''
      };
      let callback: Function = (result: LooseObject) => {
        expect(JSON.stringify(result)).assertEqual('{}');
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve(new MySet()))
        } as dataShare.DataShareHelper)));

      let encapsulateReturnResult: Function =
        mocker.mockFunc(conversationModel, conversationModel.encapsulateReturnResult);
      when(encapsulateReturnResult)(0).afterReturn({});

      await conversationModel.queryMmsInfoByFavoriteCondition(actionData, callback, context);

      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_queryMmsInfoByFavoriteCondition_businessError', 0, async () => {
      let actionData: LooseObject = {
        'isCollect': ''
      };
      let callback: Function = (result: LooseObject) => {
        expect(result.code).assertEqual(-1);
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
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

      await conversationModel.queryMmsInfoByFavoriteCondition(actionData, callback, context);

      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_queryMmsInfoFirstMsgCondition_if0_if0', 0, async () => {
      let actionData: LooseObject = {
        'isCollect': ''
      };
      let callback: Function = (result: LooseObject) => {
        expect(JSON.stringify(result)).assertEqual('{}');
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve(undefined))));

      let encapsulateReturnCode: Function = mocker.mockFunc(conversationModel, conversationModel.encapsulateReturnCode);
      when(encapsulateReturnCode)(-1).afterReturn({});

      await conversationModel.queryMmsInfoLastReadMsgCondition(actionData, callback, context);

      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_queryMmsInfoFirstMsgCondition_if3', 0, async () => {
      let actionData: LooseObject = {
        'isCollect': ''
      };
      let callback: Function = (result: LooseObject) => {
        expect(JSON.stringify(result)).assertEqual('{}');
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();
      let mySet: DataShareResultSet = new MySet();
      mySet.rowCount = 1;

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve(mySet))
        } as dataShare.DataShareHelper)));

      let encapsulateReturnResult: Function =
        mocker.mockFunc(conversationModel, conversationModel.encapsulateReturnResult);
      when(encapsulateReturnResult)(0).afterReturn({});

      await conversationModel.queryMmsInfoLastReadMsgCondition(actionData, callback, context);

      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_queryMmsInfoFirstMsgCondition_noIf3', 0, async () => {
      let actionData: LooseObject = {
        'isCollect': ''
      };
      let callback: Function = (result: LooseObject) => {
        expect(JSON.stringify(result)).assertEqual('{}');
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve(new MySet()))
        } as dataShare.DataShareHelper)));

      let encapsulateReturnResult: Function =
        mocker.mockFunc(conversationModel, conversationModel.encapsulateReturnResult);
      when(encapsulateReturnResult)(0).afterReturn({});

      await conversationModel.queryMmsInfoLastReadMsgCondition(actionData, callback, context);

      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_queryMmsInfoFirstMsgCondition_businessError', 0, async () => {
      let actionData: LooseObject = {
        'isCollect': ''
      };
      let callback: Function = (result: LooseObject) => {
        expect(result.code).assertEqual(-1);
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
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

      await conversationModel.queryMmsInfoLastReadMsgCondition(actionData, callback, context);

      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_queryAllInfoByFavoriteCondition_if1_if2', 0, async () => {
      let actionData: LooseObject = {
        'threadId': '4555',
        'needDistinct': 'false'
      };
      let callback: Function = (result: LooseObject) => {
        expect(JSON.stringify(result)).assertEqual('{}');
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve(undefined))));

      let encapsulateReturnCode: Function = mocker.mockFunc(conversationModel, conversationModel.encapsulateReturnCode);
      when(encapsulateReturnCode)(-1).afterReturn({});

      await conversationModel.queryAllInfoByFavoriteCondition(actionData, callback, context);

      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_queryAllInfoByFavoriteCondition_if1_if2_callback_null', 0, async () => {
      let actionData: LooseObject = {
        'threadId': '4555',
        'needDistinct': 'false'
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve(undefined))));

      let encapsulateReturnCode: Function = mocker.mockFunc(conversationModel, conversationModel.encapsulateReturnCode);
      when(encapsulateReturnCode)(-1).afterReturn({});

      await conversationModel.queryAllInfoByFavoriteCondition(actionData, undefined, context);
      expect(context).not().assertNull();
      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_queryAllInfoByFavoriteCondition_if3_if4', 0, async () => {
      let actionData: LooseObject = {
        'threadId': '4555',
        'needDistinct': 'false'
      };
      let callback: Function = (result: LooseObject) => {
        expect(JSON.stringify(result)).assertEqual('{}');
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();
      let mySet: DataShareResultSet = new MySet();
      mySet.rowCount = 1;

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve(mySet))
        } as dataShare.DataShareHelper)));

      let encapsulateReturnResult: Function =
        mocker.mockFunc(conversationModel, conversationModel.encapsulateReturnResult);
      when(encapsulateReturnResult)(0).afterReturn({});

      await conversationModel.queryAllInfoByFavoriteCondition(actionData, callback, context);
      expect(context).not().assertNull();
      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_queryAllInfoByFavoriteCondition_if3_else', 0, async () => {
      let actionData: LooseObject = {
        'threadId': '4555',
        'needDistinct': null
      };
      let callback: Function = (result: LooseObject) => {
        expect(JSON.stringify(result)).assertEqual('{}');
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve(new MySet()))
        } as dataShare.DataShareHelper)));

      let encapsulateReturnResult: Function =
        mocker.mockFunc(conversationModel, conversationModel.encapsulateReturnResult);
      when(encapsulateReturnResult)(0).afterReturn({});

      await conversationModel.queryAllInfoByFavoriteCondition(actionData, callback, context);

      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_queryAllInfoByFavoriteCondition_noIf3', 0, async () => {
      let actionData: LooseObject = {
        'threadId': null,
        'needDistinct': null
      };
      let callback: Function = (result: LooseObject) => {
        expect(JSON.stringify(result)).assertEqual('{}');
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve(new MySet()))
        } as dataShare.DataShareHelper)));

      let encapsulateReturnResult: Function =
        mocker.mockFunc(conversationModel, conversationModel.encapsulateReturnResult);
      when(encapsulateReturnResult)(0).afterReturn({});

      await conversationModel.queryAllInfoByFavoriteCondition(actionData, callback, context);

      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_queryAllInfoByFavoriteCondition_businessError', 0, async () => {
      let actionData: LooseObject = {
        'threadId': null,
        'needDistinct': null
      };
      let callback: Function = (result: LooseObject) => {
        expect(result.code).assertEqual(-1);
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
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

      await conversationModel.queryAllInfoByFavoriteCondition(actionData, callback, context);

      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_querySmsMmsInfoSizeByCondition_if1_if2_callback_null', 0, async () => {
      let actionData: LooseObject = {};
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve(undefined))));

      let encapsulateReturnCode: Function = mocker.mockFunc(conversationModel, conversationModel.encapsulateReturnCode);
      when(encapsulateReturnCode)(-1).afterReturn({});

      await conversationModel.querySmsMmsInfoSizeByCondition(actionData, undefined, context);
      expect(context).not().assertUndefined();
      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_querySmsMmsInfoSizeByCondition_if1_if2', 0, async () => {
      let actionData: LooseObject = {
        'isNoReceiverDraft': true,
        'threadId': '1789',
        'needDistinct': '',
        'page': 1,
        'content': '50',
        'smsType': '',
        'currentTimeStamp': 0,
        'orderByTimeDesc': true,
        'limit': 10,
        'hasRead': '',
        'msgId': '',
        'isDraft': '',
        'groupId': '',
        'sendStatus': '',
        'threadIds': ['9091'],
        'msgIds': [''],
        'groupIds': ['']
      };
      let callback: Function = (result: LooseObject) => {
        expect(JSON.stringify(result)).assertEqual('{}');
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve(undefined))));

      let encapsulateReturnCode: Function = mocker.mockFunc(conversationModel, conversationModel.encapsulateReturnCode);
      when(encapsulateReturnCode)(-1).afterReturn({});

      await conversationModel.querySmsMmsInfoSizeByCondition(actionData, callback, context);
      expect(context).not().assertUndefined();
      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_querySmsMmsInfoSizeByCondition_if3', 0, async () => {
      let actionData: LooseObject = {
        'isNoReceiverDraft': true,
        'threadId': '1789',
        'needDistinct': '',
        'page': 1,
        'content': '50',
        'smsType': '',
        'currentTimeStamp': 0,
        'orderByTimeDesc': true,
        'limit': 10,
        'hasRead': '',
        'msgId': '',
        'isDraft': '',
        'groupId': '',
        'sendStatus': '',
        'threadIds': ['9091'],
        'msgIds': [''],
        'groupIds': [''],
        'contactsNum': 1
      };
      let callback: Function = (result: LooseObject) => {
        expect(JSON.stringify(result)).assertEqual('{}');
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();
      let mySet: DataShareResultSet = new MySet();
      mySet.rowCount = 1;

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve(mySet))
        } as dataShare.DataShareHelper)));

      let encapsulateReturnResult: Function =
        mocker.mockFunc(conversationModel, conversationModel.encapsulateReturnResult);
      when(encapsulateReturnResult)(0).afterReturn({});

      await conversationModel.querySmsMmsInfoSizeByCondition(actionData, callback, context);

      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_querySmsMmsInfoSizeByCondition_noIf3', 0, async () => {
      let actionData: LooseObject = {
        'isNoReceiverDraft': true,
        'threadId': '1789',
        'needDistinct': '',
        'page': 1,
        'content': '50',
        'smsType': '',
        'currentTimeStamp': 0,
        'orderByTimeDesc': true,
        'limit': 10,
        'hasRead': '',
        'msgId': '',
        'isDraft': '',
        'groupId': '',
        'sendStatus': '',
        'threadIds': ['9091'],
        'msgIds': [''],
        'groupIds': ['']
      };
      let callback: Function = (result: LooseObject) => {
        expect(result.code).assertEqual(-1);
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve(new MySet()))
        } as dataShare.DataShareHelper)));

      let encapsulateReturnResult: Function =
        mocker.mockFunc(conversationModel, conversationModel.encapsulateReturnResult);
      when(encapsulateReturnResult)(0).afterReturn({});

      await conversationModel.querySmsMmsInfoSizeByCondition(actionData, callback, context);

      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_querySmsMmsInfoSizeByCondition_businessError', 0, async () => {
      let actionData: LooseObject = {
        'isNoReceiverDraft': true,
        'threadId': null,
        'needDistinct': null,
        'page': null,
        'content': '',
        'smsType': null,
        'currentTimeStamp': undefined,
        'orderByTimeDesc': true,
        'limit': null,
        'hasRead': null,
        'msgId': null,
        'isDraft': null,
        'groupId': null,
        'sendStatus': '',
        'threadIds': ['9091'],
        'msgIds': [],
        'groupIds': []
      };
      let callback: Function = (result: LooseObject) => {
        expect(result.code).assertEqual(-1);
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
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

      await conversationModel.querySmsMmsInfoSizeByCondition(actionData, callback, context);

      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_queryMaxGroupId_if1_if2', 0, async () => {
      let callback: Function = (result: LooseObject) => {
        expect(JSON.stringify(result)).assertEqual('{}');
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve(undefined))));

      let encapsulateReturnCode: Function = mocker.mockFunc(conversationModel, conversationModel.encapsulateReturnCode);
      when(encapsulateReturnCode)(-1).afterReturn({});

      await conversationModel.queryMaxGroupId(callback, context);

      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_queryMaxGroupId_if1_if2_callback_null', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve(undefined))));

      let encapsulateReturnCode: Function = mocker.mockFunc(conversationModel, conversationModel.encapsulateReturnCode);
      when(encapsulateReturnCode)(-1).afterReturn({});

      await conversationModel.queryMaxGroupId(undefined, context);
      expect(context).not().assertNull();
      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_queryMaxGroupId_if3_if4_EMPTY_STR', 0, async () => {
      let callback: Function = (result: LooseObject) => {
        expect(JSON.stringify(result)).assertEqual('{}');
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();
      let mySet: DataShareResultSet = new MySet();
      mySet.rowCount = 1;

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve(mySet))
        } as dataShare.DataShareHelper)));

      let encapsulateReturnResult: Function =
        mocker.mockFunc(conversationModel, conversationModel.encapsulateReturnResult);
      when(encapsulateReturnResult)(0).afterReturn({});

      await conversationModel.queryMaxGroupId(callback, context);

      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_queryMaxGroupId_if3_if4_xxx', 0, async () => {
      let callback: Function = (result: LooseObject) => {
        expect(JSON.stringify(result)).assertEqual('{}');
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();
      let mySet: DataShareResultSet = new MySet();
      mySet.rowCount = 1;

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve(mySet))
        } as dataShare.DataShareHelper)));

      let encapsulateReturnResult: Function =
        mocker.mockFunc(conversationModel, conversationModel.encapsulateReturnResult);
      when(encapsulateReturnResult)(0).afterReturn({});

      await conversationModel.queryMaxGroupId(callback, context);

      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_queryMaxGroupId_if3_noIf4', 0, async () => {
      let callback: Function = (result: LooseObject) => {
        expect(JSON.stringify(result)).assertEqual('{}');
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();
      let mySet: DataShareResultSet = new MySet();
      mySet.rowCount = 1;

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve(mySet))
        } as dataShare.DataShareHelper)));

      let encapsulateReturnResult: Function =
        mocker.mockFunc(conversationModel, conversationModel.encapsulateReturnResult);
      when(encapsulateReturnResult)(0).afterReturn({});

      await conversationModel.queryMaxGroupId(callback, context);

      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_queryMaxGroupId_noIf3', 0, async () => {
      let callback: Function = (result: LooseObject) => {
        expect(JSON.stringify(result)).assertEqual('{}');
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve(new MySet()))
        } as dataShare.DataShareHelper)));

      let encapsulateReturnResult: Function =
        mocker.mockFunc(conversationModel, conversationModel.encapsulateReturnResult);
      when(encapsulateReturnResult)(0).afterReturn({});

      await conversationModel.queryMaxGroupId(callback, context);

      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_queryMaxGroupId_businessError', 0, async () => {
      let callback: Function = (result: LooseObject) => {
        expect(result.code).assertEqual(-1);
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
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

      await conversationModel.queryMaxGroupId(callback, context);

      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_statisticalData_if1_if2', 0, async () => {
      let callback: Function = (result: LooseObject) => {
        expect(JSON.stringify(result)).assertEqual('{}');
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve(undefined))));

      let encapsulateReturnCode: Function = mocker.mockFunc(conversationModel, conversationModel.encapsulateReturnCode);
      when(encapsulateReturnCode)(-1).afterReturn({});

      await conversationModel.statisticalData(callback, context);

      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_statisticalData_if1_if2_callback_null', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve(undefined))));

      let encapsulateReturnCode: Function = mocker.mockFunc(conversationModel, conversationModel.encapsulateReturnCode);
      when(encapsulateReturnCode)(-1).afterReturn({});

      await conversationModel.statisticalData(undefined, context);
      expect(context).not().assertNull();
      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_statisticalData_if3_if4_getLong_minus1', 0, async () => {
      let callback: Function = (result: LooseObject) => {
        expect(JSON.stringify(result)).assertEqual('{}');
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();
      let mySet: DataShareResultSet = new MySet();
      mySet.rowCount = 1;

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve(mySet))
        } as dataShare.DataShareHelper)));

      let encapsulateReturnResult: Function =
        mocker.mockFunc(conversationModel, conversationModel.encapsulateReturnResult);
      when(encapsulateReturnResult)(0).afterReturn({});

      await conversationModel.statisticalData(callback, context);

      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_statisticalData_if3_if4_getLong_1', 0, async () => {
      let callback: Function = (result: LooseObject) => {
        expect(JSON.stringify(result)).assertEqual('{}');
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();
      let mySet: DataShareResultSet = new MySet();
      mySet.rowCount = 1;

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve(mySet))
        } as dataShare.DataShareHelper)));

      let encapsulateReturnResult: Function =
        mocker.mockFunc(conversationModel, conversationModel.encapsulateReturnResult);
      when(encapsulateReturnResult)(0).afterReturn({});

      await conversationModel.statisticalData(callback, context);

      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_statisticalData_if3_noIf4', 0, async () => {
      let callback: Function = (result: LooseObject) => {
        expect(JSON.stringify(result)).assertEqual('{}');
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();
      let mySet: DataShareResultSet = new MySet();
      mySet.rowCount = 1;

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve(mySet))
        } as dataShare.DataShareHelper)));

      let encapsulateReturnResult: Function =
        mocker.mockFunc(conversationModel, conversationModel.encapsulateReturnResult);
      when(encapsulateReturnResult)(0).afterReturn({});

      await conversationModel.statisticalData(callback, context);

      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_statisticalData_noIf3', 0, async () => {
      let callback: Function = (result: LooseObject) => {
        expect(result.code).assertEqual(-1);
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve(new MySet()))
        } as dataShare.DataShareHelper)));

      let encapsulateReturnResult: Function =
        mocker.mockFunc(conversationModel, conversationModel.encapsulateReturnResult);
      when(encapsulateReturnResult)(0).afterReturn({});

      await conversationModel.statisticalData(callback, context);

      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_statisticalData_businessError', 0, async () => {
      let callback: Function = (result: LooseObject) => {
        expect(result.code).assertEqual(-1);
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
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

      await conversationModel.statisticalData(callback, context);

      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_selectInfoCount_if1_if2', 0, async () => {
      let callback: Function = (result: LooseObject) => {
        expect(result.code).assertEqual(-1);
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve(undefined))));

      await conversationModel.selectInfoCount(callback, context);

      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_selectInfoCount_if1_if2_callback_null', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve(undefined))));

      await conversationModel.selectInfoCount(undefined, context);
      expect(context).not().assertNull();
      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_selectInfoCount_if3_if4', 0, async () => {
      let callback: Function = (result: LooseObject) => {
        expect(result.code).assertEqual(0);
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();
      let mySet: DataShareResultSet = new MySet();
      mySet.rowCount = 1;

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve(mySet))
        } as dataShare.DataShareHelper)));

      await conversationModel.selectInfoCount(callback, context);

      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_selectInfoCount_businessError', 0, async () => {
      let callback: Function = (result: LooseObject) => {
        expect(result.code).assertEqual(-1);
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
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

      await conversationModel.selectInfoCount(callback, context);

      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_buildQuerySmsMmsInfoFavoriteCondition_if', 0, () => {
      let actionData: LooseObject = {
        'isCollect': ''
      };

      let condition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
      condition.isNotNull(mmsTable.messageInfo.msgId);
      condition.equalTo(mmsTable.messageInfo.isCollect, 1);
      condition.and();
      condition.orderByDesc(mmsTable.messageInfo.startTime);

      let result: dataSharePredicates.DataSharePredicates =
        conversationModel.buildQuerySmsMmsInfoFavoriteCondition(actionData);

      expect(JSON.stringify(result)).assertEqual('{}');
    })

    it('conversationModelTest_buildQuerySmsMmsInfoFavoriteCondition_noIf', 0, () => {
      let actionData: LooseObject = {
        'isCollect': null
      };
      let condition: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
      condition.isNotNull(mmsTable.messageInfo.msgId)

      let result: dataSharePredicates.DataSharePredicates =
        conversationModel.buildQuerySmsMmsInfoFavoriteCondition(actionData);

      expect(JSON.stringify(result)).assertEqual('{}');
    })

    it('conversationModelTest_insertMmsInfo_if1_if2', 0, async () => {
      let callback: Function = (result: LooseObject) => {
        expect(result.code).assertEqual(-1);
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve(undefined))));

      await conversationModel.insertMmsInfo({}, callback, context);

      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_insertMmsInfo_if3', 0, async () => {
      let callback: Function = (result: LooseObject) => {
        expect(result.code).assertEqual(0);
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          insert: (uri: string, value: ValuesBucket): Promise<number> => new Promise<number>(resolve => resolve(1))
        } as dataShare.DataShareHelper)));

      await conversationModel.insertMmsInfo({}, callback, context);

      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_insertMmsInfo_businessError', 0, async () => {
      let callback: Function = (result: LooseObject) => {
        expect(result.code).assertEqual(-1);
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          insert: (uri: string,
            value: ValuesBucket): Promise<number> => new Promise<number>((resolve: (value: number | PromiseLike<number>) => void,
            reject: (reason?: BusinessError) => void) => reject({
            code: 1, message: 'error'
          } as BusinessError))
        } as dataShare.DataShareHelper)));

      await conversationModel.insertMmsInfo({}, callback, context);

      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_insertMmsInfo_if1_if2_callback_null', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve(undefined))));

      await conversationModel.insertMmsInfo({}, undefined, context);
      expect(context).not().assertNull();
      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_insertMmsInfo_if3_callback_null', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          insert: (uri: string, value: ValuesBucket): Promise<number> => new Promise<number>(resolve => resolve(1))
        } as dataShare.DataShareHelper)));

      await conversationModel.insertMmsInfo({}, undefined, context);
      expect(context).not().assertNull();
      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_insertMmsInfo_businessError_callback_null', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          insert: (uri: string,
            value: ValuesBucket): Promise<number> => new Promise<number>((resolve: (value: number | PromiseLike<number>) => void,
            reject: (reason?: BusinessError) => void) => reject({
            code: 1, message: 'error'
          } as BusinessError))
        } as dataShare.DataShareHelper)));

      await conversationModel.insertMmsInfo({}, undefined, context);
      expect(context).not().assertNull();
      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_queryMmsInfo_if1_if2', 0, async () => {
      let callback: Function = (result: LooseObject) => {
        expect(result.code).assertEqual(-1);
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve(undefined))));

      let actionData: LooseObject = {};
      actionData.queryMsgIds = ['1', '2', '3'];
      actionData.queryRcsIds = ['4', '5', '6']
      await conversationModel.queryMmsInfo(actionData, callback, context);

      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_queryMmsInfo_if3_if4', 0, async () => {
      let callback: Function = (result: LooseObject) => {
        expect(result.code).assertEqual(0);
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();
      let mySet: DataShareResultSet = new MySet();
      mySet.rowCount = 1;

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve(mySet))
        } as dataShare.DataShareHelper)));

      let actionData: LooseObject = {};
      actionData.queryMsgIds = ['1', '2', '3'];
      actionData.queryRcsIds = ['4', '5', '6']
      await conversationModel.queryMmsInfo(actionData, callback, context);

      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_queryMmsInfo_businessError', 0, async () => {
      let callback: Function = (result: LooseObject) => {
        expect(result.code).assertEqual(-1);
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
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

      let actionData: LooseObject = {};
      actionData.queryMsgIds = ['1', '2', '3'];
      actionData.queryRcsIds = ['4', '5', '6']
      await conversationModel.queryMmsInfo(actionData, callback, context);

      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_deleteMmsInfoByCondition_if1_if2', 0, async () => {
      let actionData: LooseObject = {
        groupId: '1',
        groupIds: ['1'],
        rcsId: '',
        rcsIds: [''],
        msgId: ''
      };
      let callback: Function = (result: LooseObject) => {
        expect(result.code).assertEqual(-1);
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve(undefined))));

      await conversationModel.deleteMmsInfoByCondition(actionData, callback, context);

      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_deleteMmsInfoByCondition_if1_if2_callback_null', 0, async () => {
      let actionData: LooseObject = {};
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve(undefined))));

      await conversationModel.deleteMmsInfoByCondition(actionData, undefined, context);
      expect(context).not().assertNull();
      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_deleteMmsInfoByCondition_if3_if8', 0, async () => {
      let actionData: LooseObject = {
        groupId: '1',
        groupIds: ['1'],
        rcsId: '',
        rcsIds: [''],
        msgId: ''
      };
      let callback: Function = (result: LooseObject) => {
        expect(result.code).assertEqual(0);
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          delete: (uri: string,
            predicates: dataSharePredicates.DataSharePredicates): Promise<number> => new Promise<number>(resolve => resolve(1))
        } as dataShare.DataShareHelper)));

      await conversationModel.deleteMmsInfoByCondition(actionData, callback, context);

      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_deleteMmsInfoByCondition_if4_if8', 0, async () => {
      let actionData: LooseObject = {
        groupId: null,
        groupIds: ['1'],
        rcsId: '',
        rcsIds: [''],
        msgId: ''
      };
      let callback: Function = (result: LooseObject) => {
        expect(result.code).assertEqual(0);
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          delete: (uri: string,
            predicates: dataSharePredicates.DataSharePredicates): Promise<number> => new Promise<number>(resolve => resolve(1))
        } as dataShare.DataShareHelper)));

      await conversationModel.deleteMmsInfoByCondition(actionData, callback, context);

      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_deleteMmsInfoByCondition_if5_if8', 0, async () => {
      let actionData: LooseObject = {
        groupId: null,
        rcsId: '1',
        rcsIds: [''],
        msgId: ''
      };
      let callback: Function = (result: LooseObject) => {
        expect(result.code).assertEqual(0);
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          delete: (uri: string,
            predicates: dataSharePredicates.DataSharePredicates): Promise<number> => new Promise<number>(resolve => resolve(1))
        } as dataShare.DataShareHelper)));

      await conversationModel.deleteMmsInfoByCondition(actionData, callback, context);

      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_deleteMmsInfoByCondition_if6_if8', 0, async () => {
      let actionData: LooseObject = {
        groupId: null,
        groupIds: [],
        rcsId: null,
        rcsIds: ['1'],
        msgId: ''
      };
      let callback: Function = (result: LooseObject) => {
        expect(result.code).assertEqual(0);
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          delete: (uri: string,
            predicates: dataSharePredicates.DataSharePredicates): Promise<number> => new Promise<number>(resolve => resolve(1))
        } as dataShare.DataShareHelper)));

      await conversationModel.deleteMmsInfoByCondition(actionData, callback, context);

      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_deleteMmsInfoByCondition_if7_if8', 0, async () => {
      let actionData: LooseObject = {
        groupId: null,
        groupIds: [],
        rcsId: null,
        msgId: '1'
      };
      let callback: Function = (result: LooseObject) => {
        expect(result.code).assertEqual(0);
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          delete: (uri: string,
            predicates: dataSharePredicates.DataSharePredicates): Promise<number> => new Promise<number>(resolve => resolve(1))
        } as dataShare.DataShareHelper)));

      await conversationModel.deleteMmsInfoByCondition(actionData, callback, context);

      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_deleteMmsInfoByCondition_else_if8', 0, async () => {
      let actionData: LooseObject = {
        groupId: null,
        groupIds: [],
        rcsId: null,
        rcsIds: [],
        msgId: null
      };
      let callback: Function = (result: LooseObject) => {
        expect(result.code).assertEqual(0);
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          delete: (uri: string,
            predicates: dataSharePredicates.DataSharePredicates): Promise<number> => new Promise<number>(resolve => resolve(1))
        } as dataShare.DataShareHelper)));

      await conversationModel.deleteMmsInfoByCondition(actionData, callback, context);

      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_deleteMmsInfoByCondition_else_if8_callback_null', 0, async () => {
      let actionData: LooseObject = {
        groupId: null,
        groupIds: [],
        rcsId: null,
        rcsIds: [],
        msgId: null
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          delete: (uri: string,
            predicates: dataSharePredicates.DataSharePredicates): Promise<number> => new Promise<number>(resolve => resolve(1))
        } as dataShare.DataShareHelper)));

      await conversationModel.deleteMmsInfoByCondition(actionData, undefined, context);
      expect(context).not().assertNull();
      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_deleteMmsInfoByCondition_businessError', 0, async () => {
      let actionData: LooseObject = {
        groupId: '1',
        groupIds: ['1'],
        rcsId: '',
        rcsIds: [''],
        msgId: ''
      };
      let callback: Function = (result: LooseObject) => {
        expect(result.code).assertEqual(-1);
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          delete: (uri: string,
            predicates: dataSharePredicates.DataSharePredicates): Promise<number> => new Promise<number>((resolve: (value: number | PromiseLike<number>) => void,
            reject: (reason?: BusinessError) => void) => reject({
            code: 1, message: 'error'
          } as BusinessError))
        } as dataShare.DataShareHelper)));

      await conversationModel.deleteMmsInfoByCondition(actionData, callback, context);

      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_deleteMmsInfoByCondition_businessError_callback_null', 0, async () => {
      let actionData: LooseObject = {
        groupId: '1',
        groupIds: ['1'],
        rcsId: '',
        rcsIds: [''],
        msgId: ''
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          delete: (uri: string,
            predicates: dataSharePredicates.DataSharePredicates): Promise<number> => new Promise<number>((resolve: (value: number | PromiseLike<number>) => void,
            reject: (reason?: BusinessError) => void) => reject({
            code: 1, message: 'error'
          } as BusinessError))
        } as dataShare.DataShareHelper)));

      await conversationModel.deleteMmsInfoByCondition(actionData, undefined, context);
      expect(context).not().assertNull();
      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_queryMmsNotDownloadInfo_if1_if2', 0, async () => {
      let actionData: Record<string, string> = {
        'mmsPdu': '1',
      };
      let callback: Function = (result: LooseObject) => {
        expect(result.code).assertEqual(-1);
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve(undefined))));

      await conversationModel.queryMmsNotDownloadInfo(actionData, callback, context);

      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_queryMmsNotDownloadInfo_if1_if2_callback_undefined', 0, async () => {
      let actionData: Record<string, string> = {
        'mmsPdu': '1',
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve(undefined))));

      await conversationModel.queryMmsNotDownloadInfo(actionData, undefined, context);
      expect(context).not().assertNull();
      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_queryMmsNotDownloadInfo_if3', 0, async () => {
      let actionData: Record<string, string> = {
        'mmsPdu': '1',
      };
      let callback: Function = (result: LooseObject) => {
        expect(result.code).assertEqual(0);
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();
      let mySet: DataShareResultSet = new MySet();
      mySet.rowCount = 1;

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve(mySet))
        } as dataShare.DataShareHelper)));

      await conversationModel.queryMmsNotDownloadInfo(actionData, callback, context);

      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_queryMmsNotDownloadInfo_businessError', 0, async () => {
      let actionData: Record<string, string> = {
        'mmsPdu': '1',
      };
      let callback: Function = (result: LooseObject) => {
        expect(result.code).assertEqual(-1);
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
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

      await conversationModel.queryMmsNotDownloadInfo(actionData, callback, context);

      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_insertMsgFavorite_BusinessError', 0, async () => {
      let actionData: Record<string, string> = {
        'mmsPdu': '1',
      };
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
      let encapsulateReturnCode: Function =
        mocker.mockFunc(conversationModel, conversationModel.encapsulateReturnCode);
      when(encapsulateReturnCode)(0).afterReturn({});

      await conversationModel.insertMsgFavorite(actionData, ()=>{}, context);
      expect(conversationModel).not().assertUndefined();

      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_insertMsgFavorite_BusinessError_callback_null', 0, async () => {
      let actionData: Record<string, string> = {
        'mmsPdu': '1',
      };
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
      let encapsulateReturnCode: Function =
        mocker.mockFunc(conversationModel, conversationModel.encapsulateReturnCode);
      when(encapsulateReturnCode)(0).afterReturn({});

      await conversationModel.insertMsgFavorite(actionData, undefined, context);
      expect(conversationModel).not().assertUndefined();

      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_insertMsgFavorite_if1', 0, async () => {
      let actionData: Record<string, string> = {
        'mmsPdu': '1',
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve(undefined))));
      let encapsulateReturnCode: Function =
        mocker.mockFunc(conversationModel, conversationModel.encapsulateReturnCode);
      when(encapsulateReturnCode)(0).afterReturn({});

      await conversationModel.insertMsgFavorite(actionData, ()=>{}, context);
      expect(conversationModel).not().assertUndefined();

      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_insertMsgFavorite_if1_callback_null', 0, async () => {
      let actionData: Record<string, string> = {
        'mmsPdu': '1',
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve(undefined))));
      let encapsulateReturnCode: Function =
        mocker.mockFunc(conversationModel, conversationModel.encapsulateReturnCode);
      when(encapsulateReturnCode)(0).afterReturn({});

      await conversationModel.insertMsgFavorite(actionData, undefined, context);
      expect(conversationModel).not().assertUndefined();

      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_insertMsgFavorite_if2', 0, async () => {
      let actionData: Record<string, string> = {
        'mmsPdu': '1',
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve(undefined))));
      let encapsulateReturnCode: Function =
        mocker.mockFunc(conversationModel, conversationModel.encapsulateReturnCode);
      when(encapsulateReturnCode)(0).afterReturn({});

      await conversationModel.insertMsgFavorite(actionData, null, context);
      expect(conversationModel).not().assertUndefined();

      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_insertMsgFavorite_if3', 0, async () => {
      let actionData: Record<string, string> = {
        'mmsPdu': '1',
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          insert: (uri: string, value: ValuesBucket): Promise<number> => new Promise<number>(resolve => resolve(1))
        } as dataShare.DataShareHelper)));
      let encapsulateReturnResult: Function =
        mocker.mockFunc(conversationModel, conversationModel.encapsulateReturnResult);
      when(encapsulateReturnResult)(0).afterReturn({});

      await conversationModel.insertMsgFavorite(actionData, ()=>{}, context);
      expect(conversationModel).not().assertUndefined();

      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_insertMsgFavorite_if3_callback_null', 0, async () => {
      let actionData: Record<string, string> = {
        'mmsPdu': '1',
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          insert: (uri: string, value: ValuesBucket): Promise<number> => new Promise<number>(resolve => resolve(1))
        } as dataShare.DataShareHelper)));
      let encapsulateReturnResult: Function =
        mocker.mockFunc(conversationModel, conversationModel.encapsulateReturnResult);
      when(encapsulateReturnResult)(0).afterReturn({});

      await conversationModel.insertMsgFavorite(actionData, undefined, context);
      expect(conversationModel).not().assertUndefined();

      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_insertMsgFavorite_catch', 0, async () => {
      let actionData: Record<string, string> = {
        'mmsPdu': '1',
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          insert: (uri: string, value: ValuesBucket): Promise<number> => {
            throw new Error('error')
          }
        } as dataShare.DataShareHelper)));
      let encapsulateReturnResult: Function =
        mocker.mockFunc(conversationModel, conversationModel.encapsulateReturnResult);
      when(encapsulateReturnResult)(0).afterReturn({});
      await conversationModel.insertMsgFavorite(actionData, ()=>{}, context);
      expect(context).not().assertNull();
      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_insertMsgFavorite_catch_callback_null', 0, async () => {
      let actionData: Record<string, string> = {
        'mmsPdu': '1',
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          insert: (uri: string, value: ValuesBucket): Promise<number> => {
            throw new Error('error')
          }
        } as dataShare.DataShareHelper)));
      await conversationModel.insertMsgFavorite(actionData, undefined, context);
      expect(conversationModel).not().assertUndefined();
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_deleteFavorite_BusinessError', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          delete: (uri: string,
            predicates: dataSharePredicates.DataSharePredicates): Promise<number> => new Promise<number>((resolve: (value: number | PromiseLike<number>) => void,
            reject: (reason?: BusinessError) => void) => reject({
            code: 1, message: 'error'
          } as BusinessError))
        } as dataShare.DataShareHelper)));
      let encapsulateReturnCode: Function =
        mocker.mockFunc(conversationModel, conversationModel.encapsulateReturnCode);
      when(encapsulateReturnCode)(0).afterReturn({});

      await conversationModel.deleteFavorite(1, ()=>{}, context);
      expect(conversationModel).not().assertUndefined();

      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_deleteFavorite_BusinessError_callback_null', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          delete: (uri: string,
            predicates: dataSharePredicates.DataSharePredicates): Promise<number> => new Promise<number>((resolve: (value: number | PromiseLike<number>) => void,
            reject: (reason?: BusinessError) => void) => reject({
            code: 1, message: 'error'
          } as BusinessError))
        } as dataShare.DataShareHelper)));
      let encapsulateReturnCode: Function =
        mocker.mockFunc(conversationModel, conversationModel.encapsulateReturnCode);
      when(encapsulateReturnCode)(0).afterReturn({});

      await conversationModel.deleteFavorite(1, undefined, context);
      expect(conversationModel).not().assertUndefined();

      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_deleteFavorite_if1', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve(undefined))));
      let encapsulateReturnCode: Function =
        mocker.mockFunc(conversationModel, conversationModel.encapsulateReturnCode);
      when(encapsulateReturnCode)(0).afterReturn({});

      await conversationModel.deleteFavorite(1, ()=>{}, context);
      expect(conversationModel).not().assertUndefined();

      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_deleteFavorite_if2', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve(undefined))));
      let encapsulateReturnCode: Function =
        mocker.mockFunc(conversationModel, conversationModel.encapsulateReturnCode);
      when(encapsulateReturnCode)(0).afterReturn({});

      await conversationModel.deleteFavorite(1, null, context);
      expect(conversationModel).not().assertUndefined();

      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_deleteFavorite_if3', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          delete: (uri: string,
            predicates: dataSharePredicates.DataSharePredicates): Promise<number> => new Promise<number>(resolve => resolve(1))
        } as dataShare.DataShareHelper)));
      let encapsulateReturnResult: Function =
        mocker.mockFunc(conversationModel, conversationModel.encapsulateReturnResult);
      when(encapsulateReturnResult)(0).afterReturn({});

      await conversationModel.deleteFavorite(1, ()=>{}, context);
      expect(conversationModel).not().assertUndefined();

      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_deleteFavorite_if3_callback_null', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          delete: (uri: string,
            predicates: dataSharePredicates.DataSharePredicates): Promise<number> => new Promise<number>(resolve => resolve(1))
        } as dataShare.DataShareHelper)));
      let encapsulateReturnResult: Function =
        mocker.mockFunc(conversationModel, conversationModel.encapsulateReturnResult);
      when(encapsulateReturnResult)(0).afterReturn({});

      await conversationModel.deleteFavorite(1, undefined, context);
      expect(conversationModel).not().assertUndefined();

      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_queryFavoriteAllInfoByCondition_BusinessError', 0, async () => {
      let actionData: Record<string, string> = {
        'mmsPdu': '1',
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
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
      let encapsulateReturnCode: Function =
        mocker.mockFunc(conversationModel, conversationModel.encapsulateReturnCode);
      when(encapsulateReturnCode)(0).afterReturn({});

      await conversationModel.queryFavoriteAllInfoByCondition(actionData, ()=>{}, context);
      expect(conversationModel).not().assertUndefined();

      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_queryFavoriteAllInfoByCondition_if1', 0, async () => {
      let actionData: Record<string, string> = {
        'mmsPdu': '1',
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve(undefined))));
      let encapsulateReturnCode: Function =
        mocker.mockFunc(conversationModel, conversationModel.encapsulateReturnCode);
      when(encapsulateReturnCode)(0).afterReturn({});

      await conversationModel.queryFavoriteAllInfoByCondition(actionData, ()=>{}, context);
      expect(conversationModel).not().assertUndefined();

      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_queryFavoriteAllInfoByCondition_if1_callback_null', 0, async () => {
      let actionData: Record<string, string> = {
        'mmsPdu': '1',
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve(undefined))));
      let encapsulateReturnCode: Function =
        mocker.mockFunc(conversationModel, conversationModel.encapsulateReturnCode);
      when(encapsulateReturnCode)(0).afterReturn({});

      await conversationModel.queryFavoriteAllInfoByCondition(actionData, undefined, context);
      expect(conversationModel).not().assertUndefined();

      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_updateSmsMmsInfoStateByCondition_if1_if2', 0, async () => {
      let actionData: LooseObject = {
        'isNoReceiverDraft': true,
        'threadId': '1789',
        'needDistinct': '',
        'page': 1,
        'content': '50',
        'smsType': '',
        'currentTimeStamp': 0,
        'orderByTimeDesc': true,
        'limit': 10,
        'hasRead': '',
        'msgId': '',
        'isDraft': '',
        'groupId': '',
        'sendStatus': '',
        'threadIds': ['9091'],
        'msgIds': [''],
        'groupIds': ['']
      };
      let valueBucket: ValuesBucket = {
        'telephone': '570977632'
      };
      let callback: Function = (result: LooseObject) => {
        expect(JSON.stringify(result)).assertEqual('{}');
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve(undefined))));

      let encapsulateReturnCode: Function = mocker.mockFunc(conversationModel, conversationModel.encapsulateReturnCode);
      when(encapsulateReturnCode)(-1).afterReturn({});

      await conversationModel.updateSmsMmsInfoStateByCondition(actionData, valueBucket, callback, context);

      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_updateSmsMmsInfoStateByCondition_if1_if2_callback_null', 0, async () => {
      let actionData: LooseObject = {};
      let valueBucket: ValuesBucket = {
        'telephone': '570977632'
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve(undefined))));

      let encapsulateReturnCode: Function = mocker.mockFunc(conversationModel, conversationModel.encapsulateReturnCode);
      when(encapsulateReturnCode)(-1).afterReturn({});

      await conversationModel.updateSmsMmsInfoStateByCondition(actionData, valueBucket, undefined, context);
      expect(conversationModel).not().assertUndefined();
      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })
    it('conversationModelTest_updateSmsMmsInfoStateByCondition_if3_buildQuerySmsMmsInfoCondition_if1', 0, async () => {
      let actionData: LooseObject = {
        'isNoReceiverDraft': true,
        'threadId': '1789',
        'needDistinct': '',
        'page': 1,
        'content': '50',
        'smsType': '',
        'currentTimeStamp': 0,
        'orderByTimeDesc': true,
        'limit': 10,
        'hasRead': '',
        'msgId': '',
        'isDraft': '',
        'groupId': '',
        'sendStatus': '',
        'threadIds': ['9091'],
        'msgIds': [''],
        'groupIds': ['']
      };
      let valueBucket: ValuesBucket = {
        'isNoReceiverDraft': true
      };
      let callback: Function = (result: LooseObject) => {
        expect(JSON.stringify(result)).assertEqual('{}');
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve({
          update: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            value: ValuesBucket): Promise<number> =>
          new Promise<number>(resolve => resolve(1))
        } as dataShare.DataShareHelper))));

      let encapsulateReturnResult: Function =
        mocker.mockFunc(conversationModel, conversationModel.encapsulateReturnResult);
      when(encapsulateReturnResult)(0).afterReturn({});

      await conversationModel.updateSmsMmsInfoStateByCondition(actionData, valueBucket, callback, context);

      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_updateSmsMmsInfoStateByCondition_if3_buildQuerySmsMmsInfoCondition_else_if2_ifs_callback_null', 0,
      async () => {
        let actionData: LooseObject = {
          'isNoReceiverDraft': false,
          'threadId': '1789',
          'needDistinct': '',
          'page': 1,
          'content': '50',
          'smsType': '',
          'currentTimeStamp': 0,
          'orderByTimeDesc': true,
          'limit': 10,
          'hasRead': '',
          'msgId': '',
          'isDraft': '',
          'groupId': '',
          'sendStatus': '',
          'threadIds': ['9091'],
          'msgIds': [''],
          'groupIds': ['']
        };
        let valueBucket: ValuesBucket = {
          'telephone': '570977632'
        };
        let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
        let mocker: MockKit = new MockKit();

        when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
          .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve({
            update: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
              value: ValuesBucket): Promise<number> =>
            new Promise<number>(resolve => resolve(1))
          } as dataShare.DataShareHelper))));

        let encapsulateReturnResult: Function =
          mocker.mockFunc(conversationModel, conversationModel.encapsulateReturnResult);
        when(encapsulateReturnResult)(0).afterReturn({});

        await conversationModel.updateSmsMmsInfoStateByCondition(actionData, valueBucket, undefined, context);
        expect(conversationModel).not().assertUndefined();
        mocker.clear(conversationModel);
        mocker.clear(DataShareHelper.getInstance());
      })

    it('conversationModelTest_updateSmsMmsInfoStateByCondition_if3_buildQuerySmsMmsInfoCondition_else_else_else', 0,
      async () => {
        let actionData: LooseObject = {
          'isNoReceiverDraft': false,
          'threadId': null,
          'needDistinct': null,
          'page': null,
          'content': '',
          'smsType': null,
          'currentTimeStamp': undefined,
          'orderByTimeDesc': true,
          'limit': null,
          'hasRead': null,
          'msgId': null,
          'isDraft': null,
          'groupId': null,
          'sendStatus': '',
          'threadIds': ['9091'],
          'msgIds': [],
          'groupIds': []
        };
        let valueBucket: ValuesBucket = {
          'telephone': '570977632'
        };
        let callback: Function = (result: LooseObject) => {
          expect(JSON.stringify(result)).assertEqual('{}');
        };
        let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
        let mocker: MockKit = new MockKit();

        when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
          .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve({
            update: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
              value: ValuesBucket): Promise<number> =>
            new Promise<number>(resolve => resolve(1))
          } as dataShare.DataShareHelper))));

        let encapsulateReturnResult: Function =
          mocker.mockFunc(conversationModel, conversationModel.encapsulateReturnResult);
        when(encapsulateReturnResult)(0).afterReturn({});

        await conversationModel.updateSmsMmsInfoStateByCondition(actionData, valueBucket, callback, context);

        mocker.clear(conversationModel);
        mocker.clear(DataShareHelper.getInstance());
      })

    it('conversationModelTest_updateSmsMmsInfoStateByCondition_businessError', 0, async () => {
      let actionData: LooseObject = {
        'isNoReceiverDraft': true,
        'threadId': null,
        'needDistinct': null,
        'page': null,
        'content': '',
        'smsType': null,
        'currentTimeStamp': undefined,
        'orderByTimeDesc': true,
        'limit': null,
        'hasRead': null,
        'msgId': null,
        'isDraft': null,
        'groupId': null,
        'sendStatus': '',
        'threadIds': ['9091'],
        'msgIds': [],
        'groupIds': []
      };
      let valueBucket: ValuesBucket = {
        'telephone': '570977632'
      };
      let callback: Function = (result: LooseObject) => {
        expect(result.code).assertEqual(-1);
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
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

      await conversationModel.updateSmsMmsInfoStateByCondition(actionData, valueBucket, callback, context);

      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_updateSmsMmsInfoStateByCondition_businessError_callback_null', 0, async () => {
      let actionData: LooseObject = {
        'isNoReceiverDraft': true,
        'threadId': null,
        'needDistinct': null,
        'page': null,
        'content': '',
        'smsType': null,
        'currentTimeStamp': undefined,
        'orderByTimeDesc': true,
        'limit': null,
        'hasRead': null,
        'msgId': null,
        'isDraft': null,
        'groupId': null,
        'sendStatus': '',
        'threadIds': ['9091'],
        'msgIds': [],
        'groupIds': []
      };
      let valueBucket: ValuesBucket = {
        'telephone': '570977632'
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
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

      await conversationModel.updateSmsMmsInfoStateByCondition(actionData, valueBucket, undefined, context);
      expect(context).not().assertUndefined();
      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_updateSmsMmsInfoByRcsID_if1_callback_null', 0, async () => {
      let actionData: LooseObject = {};
      let valueBucket: ValuesBucket = {
        'telephone': '570977632'
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve(undefined))));

      let encapsulateReturnCode: Function = mocker.mockFunc(conversationModel, conversationModel.encapsulateReturnCode);
      when(encapsulateReturnCode)(-1).afterReturn({});

      await conversationModel.updateSmsMmsInfoByRcsID(actionData, valueBucket, undefined, context);
      expect(context).not().assertUndefined();
      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_updateSmsMmsInfoByRcsID_if1', 0, async () => {
      let actionData: LooseObject = {
        'isNoReceiverDraft': true,
        'threadId': '1789',
        'needDistinct': '',
        'page': 1,
        'content': '50',
        'smsType': '',
        'currentTimeStamp': 0,
        'orderByTimeDesc': true,
        'limit': 10,
        'hasRead': '',
        'msgId': '',
        'isDraft': '',
        'groupId': '',
        'sendStatus': '',
        'threadIds': ['9091'],
        'msgIds': [''],
        'groupIds': ['']
      };
      let valueBucket: ValuesBucket = {
        'telephone': '570977632'
      };
      let callback: Function = (result: LooseObject) => {
        expect(JSON.stringify(result)).assertEqual('{}');
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve(undefined))));

      let encapsulateReturnCode: Function = mocker.mockFunc(conversationModel, conversationModel.encapsulateReturnCode);
      when(encapsulateReturnCode)(-1).afterReturn({});

      await conversationModel.updateSmsMmsInfoByRcsID(actionData, valueBucket, callback, context);

      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_updateSmsMmsInfoByRcsID_if3_buildQuerySmsMmsInfoCondition_if1', 0, async () => {
      let actionData: LooseObject = {
        'isNoReceiverDraft': true,
        'threadId': '1789',
        'needDistinct': '',
        'page': 1,
        'content': '50',
        'smsType': '',
        'currentTimeStamp': 0,
        'orderByTimeDesc': true,
        'limit': 10,
        'hasRead': '',
        'msgId': '',
        'isDraft': '',
        'groupId': '',
        'sendStatus': '',
        'threadIds': ['9091'],
        'msgIds': [''],
        'groupIds': ['']
      };
      let valueBucket: ValuesBucket = {
        'isNoReceiverDraft': true
      };
      let callback: Function = (result: LooseObject) => {
        expect(JSON.stringify(result)).assertEqual('{}');
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve({
          update: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            value: ValuesBucket): Promise<number> =>
          new Promise<number>(resolve => resolve(1))
        } as dataShare.DataShareHelper))));

      let encapsulateReturnResult: Function =
        mocker.mockFunc(conversationModel, conversationModel.encapsulateReturnResult);
      when(encapsulateReturnResult)(0).afterReturn({});

      await conversationModel.updateSmsMmsInfoByRcsID(actionData, valueBucket, callback, context);

      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_updateSmsMmsInfoByRcsID_if3_buildQuerySmsMmsInfoCondition_else_if2_ifs', 0,
      async () => {
        let actionData: LooseObject = {
          'isNoReceiverDraft': false,
          'threadId': '1789',
          'needDistinct': '',
          'page': 1,
          'content': '50',
          'smsType': '',
          'currentTimeStamp': 0,
          'orderByTimeDesc': true,
          'limit': 10,
          'hasRead': '',
          'msgId': '',
          'isDraft': '',
          'groupId': '',
          'sendStatus': '',
          'threadIds': ['9091'],
          'msgIds': [''],
          'groupIds': ['']
        };
        let valueBucket: ValuesBucket = {
          'telephone': '570977632'
        };
        let callback: Function = (result: LooseObject) => {
          expect(JSON.stringify(result)).assertEqual('{}');
        };
        let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
        let mocker: MockKit = new MockKit();

        when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
          .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve({
            update: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
              value: ValuesBucket): Promise<number> =>
            new Promise<number>(resolve => resolve(1))
          } as dataShare.DataShareHelper))));

        let encapsulateReturnResult: Function =
          mocker.mockFunc(conversationModel, conversationModel.encapsulateReturnResult);
        when(encapsulateReturnResult)(0).afterReturn({});

        await conversationModel.updateSmsMmsInfoByRcsID(actionData, valueBucket, callback, context);

        mocker.clear(conversationModel);
        mocker.clear(DataShareHelper.getInstance());
      })

    it('conversationModelTest_updateSmsMmsInfoByRcsID_if3_buildQuerySmsMmsInfoCondition_else_else_else_callback_null', 0,
      async () => {
        let actionData: LooseObject = {
          'isNoReceiverDraft': false,
          'threadId': null,
          'needDistinct': null,
          'page': null,
          'content': '',
          'smsType': null,
          'currentTimeStamp': undefined,
          'orderByTimeDesc': true,
          'limit': null,
          'hasRead': null,
          'msgId': null,
          'isDraft': null,
          'groupId': null,
          'sendStatus': '',
          'threadIds': ['9091'],
          'msgIds': [],
          'groupIds': []
        };
        let valueBucket: ValuesBucket = {
          'telephone': '570977632'
        };
        let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
        let mocker: MockKit = new MockKit();

        when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
          .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve({
            update: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
              value: ValuesBucket): Promise<number> =>
            new Promise<number>(resolve => resolve(1))
          } as dataShare.DataShareHelper))));

        let encapsulateReturnResult: Function =
          mocker.mockFunc(conversationModel, conversationModel.encapsulateReturnResult);
        when(encapsulateReturnResult)(0).afterReturn({});

        await conversationModel.updateSmsMmsInfoByRcsID(actionData, valueBucket, undefined, context);
        expect(context).not().assertUndefined();
        mocker.clear(conversationModel);
        mocker.clear(DataShareHelper.getInstance());
      })

    it('conversationModelTest_updateSmsMmsInfoByRcsID_if3_buildQuerySmsMmsInfoCondition_else_else_else', 0,
      async () => {
        let actionData: LooseObject = {
          'isNoReceiverDraft': false,
          'threadId': null,
          'needDistinct': null,
          'page': null,
          'content': '',
          'smsType': null,
          'currentTimeStamp': undefined,
          'orderByTimeDesc': true,
          'limit': null,
          'hasRead': null,
          'msgId': null,
          'isDraft': null,
          'groupId': null,
          'sendStatus': '',
          'threadIds': ['9091'],
          'msgIds': [],
          'groupIds': []
        };
        let valueBucket: ValuesBucket = {
          'telephone': '570977632'
        };
        let callback: Function = (result: LooseObject) => {
          expect(JSON.stringify(result)).assertEqual('{}');
        };
        let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
        let mocker: MockKit = new MockKit();

        when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
          .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve({
            update: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
              value: ValuesBucket): Promise<number> =>
            new Promise<number>(resolve => resolve(1))
          } as dataShare.DataShareHelper))));

        let encapsulateReturnResult: Function =
          mocker.mockFunc(conversationModel, conversationModel.encapsulateReturnResult);
        when(encapsulateReturnResult)(0).afterReturn({});

        await conversationModel.updateSmsMmsInfoByRcsID(actionData, valueBucket, callback, context);
        expect(context).not().assertUndefined();
        mocker.clear(conversationModel);
        mocker.clear(DataShareHelper.getInstance());
      })

    it('conversationModelTest_updateSmsMmsInfoByRcsID_businessError_callback_null', 0, async () => {
      let actionData: LooseObject = {
        'isNoReceiverDraft': true,
        'threadId': null,
        'needDistinct': null,
        'page': null,
        'content': '',
        'smsType': null,
        'currentTimeStamp': undefined,
        'orderByTimeDesc': true,
        'limit': null,
        'hasRead': null,
        'msgId': null,
        'isDraft': null,
        'groupId': null,
        'sendStatus': '',
        'threadIds': ['9091'],
        'msgIds': [],
        'groupIds': []
      };
      let valueBucket: ValuesBucket = {
        'telephone': '570977632'
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
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

      await conversationModel.updateSmsMmsInfoByRcsID(actionData, valueBucket, undefined, context);
      expect(context).not().assertUndefined();
      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_updateSmsMmsInfoByRcsID_businessError', 0, async () => {
      let actionData: LooseObject = {
        'isNoReceiverDraft': true,
        'threadId': null,
        'needDistinct': null,
        'page': null,
        'content': '',
        'smsType': null,
        'currentTimeStamp': undefined,
        'orderByTimeDesc': true,
        'limit': null,
        'hasRead': null,
        'msgId': null,
        'isDraft': null,
        'groupId': null,
        'sendStatus': '',
        'threadIds': ['9091'],
        'msgIds': [],
        'groupIds': []
      };
      let valueBucket: ValuesBucket = {
        'telephone': '570977632'
      };
      let callback: Function = (result: LooseObject) => {
        expect(result.code).assertEqual(-1);
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
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

      await conversationModel.updateSmsMmsInfoByRcsID(actionData, valueBucket, callback, context);
      expect(context).not().assertUndefined();
      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_querySmsMmsInfoRcsIdByCondition_if', 0, async () => {
      let conversationmodel: ConversationModel = new ConversationModel();
      let mocker: MockKit = new MockKit();
      let mockInitSmsDB: Function = mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB);
      when(mockInitSmsDB)(ArgumentMatchers.any).afterReturn(Promise.resolve(undefined));
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let result = await conversationmodel.querySmsMmsInfoRcsIdByCondition("123", context);
      expect(result).assertEqual(0);
      mocker.ignoreMock(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB);
    });

    it('conversationModelTest_querySmsMmsInfoRcsIdByCondition_succeed', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve({
          update: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            value: ValuesBucket): Promise<number> =>
          new Promise<number>(resolve => resolve(1))
        } as dataShare.DataShareHelper))));

      let encapsulateReturnResult: Function =
        mocker.mockFunc(conversationModel, conversationModel.encapsulateReturnResult);
      when(encapsulateReturnResult)(0).afterReturn({});

      await conversationModel.querySmsMmsInfoRcsIdByCondition('123', context);
      expect(context).not().assertUndefined();
      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_queryAllInfoSizeByCondition_if1_if2', 0, async () => {
      let actionData: LooseObject = {
        'threadId': '4555',
        'needDistinct': 'false'
      };
      let callback: Function = (result: LooseObject) => {
        expect(JSON.stringify(result)).assertEqual('{}');
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve(undefined))));

      let encapsulateReturnCode: Function = mocker.mockFunc(conversationModel, conversationModel.encapsulateReturnCode);
      when(encapsulateReturnCode)(-1).afterReturn({});

      await conversationModel.queryAllInfoSizeByCondition(actionData, callback, context);

      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_queryAllInfoSizeByCondition_if1_if2_callback_null', 0, async () => {
      let actionData: LooseObject = {
        'threadId': '4555',
        'needDistinct': 'false'
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve(undefined))));

      let encapsulateReturnCode: Function = mocker.mockFunc(conversationModel, conversationModel.encapsulateReturnCode);
      when(encapsulateReturnCode)(-1).afterReturn({});

      await conversationModel.queryAllInfoSizeByCondition(actionData, undefined, context);
      expect(context).not().assertUndefined();
      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_queryAllInfoSizeByCondition_if3_if4', 0, async () => {
      let actionData: LooseObject = {
        'threadId': '4555',
        'needDistinct': 'false'
      };
      let callback: Function = (result: LooseObject) => {
        expect(JSON.stringify(result)).assertEqual('{}');
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();
      let mySet: DataShareResultSet = new MySet();
      mySet.rowCount = 1;

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve(mySet))
        } as dataShare.DataShareHelper)));

      let encapsulateReturnResult: Function =
        mocker.mockFunc(conversationModel, conversationModel.encapsulateReturnResult);
      when(encapsulateReturnResult)(0).afterReturn({});

      await conversationModel.queryAllInfoSizeByCondition(actionData, callback, context);

      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_queryAllInfoSizeByCondition_if3_else', 0, async () => {
      let actionData: LooseObject = {
        'threadId': '4555',
        'needDistinct': null
      };
      let callback: Function = (result: LooseObject) => {
        expect(JSON.stringify(result)).assertEqual('{}');
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve(new MySet()))
        } as dataShare.DataShareHelper)));

      let encapsulateReturnResult: Function =
        mocker.mockFunc(conversationModel, conversationModel.encapsulateReturnResult);
      when(encapsulateReturnResult)(0).afterReturn({});

      await conversationModel.queryAllInfoSizeByCondition(actionData, callback, context);

      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_queryAllInfoSizeByCondition_noIf3', 0, async () => {
      let actionData: LooseObject = {
        'threadId': null,
        'needDistinct': null
      };
      let callback: Function = (result: LooseObject) => {
        expect(JSON.stringify(result)).assertEqual('{}');
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve(new MySet()))
        } as dataShare.DataShareHelper)));

      let encapsulateReturnResult: Function =
        mocker.mockFunc(conversationModel, conversationModel.encapsulateReturnResult);
      when(encapsulateReturnResult)(0).afterReturn({});

      await conversationModel.queryAllInfoSizeByCondition(actionData, callback, context);

      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_queryAllInfoSizeByCondition_businessError', 0, async () => {
      let actionData: LooseObject = {
        'threadId': null,
        'needDistinct': null
      };
      let callback: Function = (result: LooseObject) => {
        expect(result.code).assertEqual(-1);
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
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

      await conversationModel.queryAllInfoSizeByCondition(actionData, callback, context);

      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_selectContactId_if1_if2', 0, async () => {
      let callback: Function = (result: LooseObject) => {
        expect(result.code).assertEqual(-1);
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve(undefined))));

      await conversationModel.selectContactId(callback, context);

      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_selectContactId_if1_if2_callback_null', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve(undefined))));

      await conversationModel.selectContactId(undefined, context);
      expect(context).not().assertUndefined();
      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_selectContactId_if3_if4', 0, async () => {
      let callback: Function = (result: LooseObject) => {
        expect(result.code).assertEqual(0);
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();
      let mySet: DataShareResultSet = new MySet();
      mySet.rowCount = 1;

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve(mySet))
        } as dataShare.DataShareHelper)));

      await conversationModel.selectContactId(callback, context);

      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_selectContactId_businessError', 0, async () => {
      let callback: Function = (result: LooseObject) => {
        expect(result.code).assertEqual(-1);
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
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

      await conversationModel.selectContactId(callback, context);

      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_queryMmsPartInfo_if1_if2', 0, async () => {
      let callback: Function = (result: LooseObject) => {
        expect(result.code).assertEqual(-1);
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve(undefined))));

      let actionData: LooseObject = {};
      actionData.queryMsgIds = ['1', '2', '3'];
      actionData.queryRcsIds = ['4', '5', '6']
      await conversationModel.queryMmsPartInfo(actionData, callback, context);

      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_queryMmsPartInfo_if3_if4', 0, async () => {
      let callback: Function = (result: LooseObject) => {
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();
      let mySet: DataShareResultSet = new MySet();
      mySet.rowCount = 1;

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve(mySet))
        } as dataShare.DataShareHelper)));

      let actionData: LooseObject = {};
      actionData.msgId = 5;
      actionData.rcsId = 6;
      await conversationModel.queryMmsPartInfo(actionData, callback, context);
      expect(context).not().assertUndefined();
      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_queryMmsPartInfo_if3_if4_callback_null', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();
      let mySet: DataShareResultSet = new MySet();
      mySet.rowCount = 1;

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve(mySet))
        } as dataShare.DataShareHelper)));

      let actionData: LooseObject = {};
      actionData.msgId = 5;
      actionData.rcsId = 6;
      await conversationModel.queryMmsPartInfo(actionData, undefined, context);
      expect(context).not().assertUndefined();
      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_updateMmsPartById_if', 0, async () => {
      let callback: Function = (result: LooseObject) => {
        expect(result.code).assertEqual(-1);
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve(undefined))));

      let actionData: LooseObject = {};
      await conversationModel.updateMmsPartById(actionData, callback, context);

      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_updateMmsPartById_complete', 0, async () => {
      let callback: Function = (result: LooseObject) => { };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();
      let mySet: DataShareResultSet = new MySet();
      mySet.rowCount = 1;

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve({
          update: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            value: ValuesBucket): Promise<number> =>
          new Promise<number>(resolve => resolve(1))
        } as dataShare.DataShareHelper))));

      let actionData: LooseObject = {};
      actionData.mmsPartId = 5;
      actionData.isFraud = true;
      await conversationModel.updateMmsPartById(actionData, callback, context);
      expect(context).not().assertUndefined();
      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_updateMmsPartById_complete_callback_null', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();
      let mySet: DataShareResultSet = new MySet();
      mySet.rowCount = 1;

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve({
          update: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            value: ValuesBucket): Promise<number> =>
          new Promise<number>(resolve => resolve(1))
        } as dataShare.DataShareHelper))));

      let actionData: LooseObject = {};
      actionData.mmsPartId = 5;
      actionData.isFraud = true;
      await conversationModel.updateMmsPartById(actionData, undefined, context);
      expect(context).not().assertUndefined();
      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_updateMmsPartById_catch', 0, async () => {
      let callback: Function = (result: LooseObject) => { };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();
      let mySet: DataShareResultSet = new MySet();
      mySet.rowCount = 1;
      let error: BusinessError = {
        code: 1, message: 'error'
      } as BusinessError;
      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve({
          update: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            value: ValuesBucket): Promise<number> =>
          new Promise<number>((resolve: (value: number | PromiseLike<number>) => void,
            reject: (reason?: BusinessError) => void) => reject(error))
        } as dataShare.DataShareHelper))));

      let actionData: LooseObject = {};
      actionData.mmsPartId = 5;
      actionData.isFraud = true;
      await conversationModel.updateMmsPartById(actionData, callback, context);
      expect(context).not().assertUndefined();
      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_updateMmsPartById_catch_callback_undefined', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();
      let mySet: DataShareResultSet = new MySet();
      mySet.rowCount = 1;
      let error: BusinessError = {
        code: 1, message: 'error'
      } as BusinessError;
      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve({
          update: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            value: ValuesBucket): Promise<number> =>
          new Promise<number>((resolve: (value: number | PromiseLike<number>) => void,
            reject: (reason?: BusinessError) => void) => reject(error))
        } as dataShare.DataShareHelper))));

      let actionData: LooseObject = {};
      actionData.mmsPartId = 5;
      actionData.isFraud = true;
      await conversationModel.updateMmsPartById(actionData, undefined, context);
      expect(context).not().assertUndefined();
      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_updateSmsIsReadBySessionId_if', 0, async () => {
      let callback: Function = (result: LooseObject) => {
        expect(result.code).assertEqual(-1);
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve(undefined))));

      let actionData: LooseObject = {};
      await conversationModel.updateSmsIsReadBySessionId(actionData, context, callback);

      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_updateSmsIsReadBySessionId_dataHelper_undefined_callback_null', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve(undefined))));

      let actionData: LooseObject = {};
      await conversationModel.updateSmsIsReadBySessionId(actionData, context, undefined);
      expect(actionData).not().assertUndefined();
      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_updateSmsIsReadBySessionId_complete', 0, async () => {
      let callback: Function = (result: LooseObject) => {
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();
      let mySet: DataShareResultSet = new MySet();
      mySet.rowCount = 1;

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve({
          update: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            value: ValuesBucket): Promise<number> =>
          new Promise<number>(resolve => resolve(1))
        } as dataShare.DataShareHelper))));

      let actionData: LooseObject = {};
      actionData.markReadType = MarkRead.single;
      await conversationModel.updateSmsIsReadBySessionId(actionData, context, callback);
      expect(actionData).not().assertUndefined();
      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_updateSmsIsReadBySessionId_complete_callback_null', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();
      let mySet: DataShareResultSet = new MySet();
      mySet.rowCount = 1;

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve({
          update: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            value: ValuesBucket): Promise<number> =>
          new Promise<number>(resolve => resolve(1))
        } as dataShare.DataShareHelper))));

      let actionData: LooseObject = {};
      actionData.markReadType = MarkRead.allInfo;
      await conversationModel.updateSmsIsReadBySessionId(actionData, context, undefined);
      expect(actionData).not().assertUndefined();
      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_updateSmsIsReadBySessionId_dataHelper_catch', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();
      let mySet: DataShareResultSet = new MySet();
      mySet.rowCount = 1;
      let error: BusinessError = {
        code: 1, message: 'error'
      } as BusinessError;
      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve({
          update: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            value: ValuesBucket): Promise<number> =>
          new Promise<number>((resolve: (value: number | PromiseLike<number>) => void,
            reject: (reason?: BusinessError) => void) => reject(error))
        } as dataShare.DataShareHelper))));

      let actionData: LooseObject = {};
      actionData.markReadType = MarkRead.all;
      await conversationModel.updateSmsIsReadBySessionId(actionData, context, undefined);
      expect(actionData).not().assertUndefined();
      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_updateSmsIsReadBySessionId_dataHelper_catch_callback', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();
      let mySet: DataShareResultSet = new MySet();
      mySet.rowCount = 1;
      let error: BusinessError = {
        code: 1, message: 'error'
      } as BusinessError;
      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve({
          update: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            value: ValuesBucket): Promise<number> =>
          new Promise<number>((resolve: (value: number | PromiseLike<number>) => void,
            reject: (reason?: BusinessError) => void) => reject(error))
        } as dataShare.DataShareHelper))));

      let actionData: LooseObject = {};
      actionData.markReadType = 9;
      await conversationModel.updateSmsIsReadBySessionId(actionData, context, () => {});
      expect(context).not().assertUndefined();
      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_updateSmsIsReadBySessionId_dataHelper_try_catch', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();
      let mySet: DataShareResultSet = new MySet();
      mySet.rowCount = 1;
      let error: BusinessError = {
        code: 1, message: 'error'
      } as BusinessError;
      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve({
          update: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            value: ValuesBucket): Promise<number> => {
            throw new Error('error');
          }
        } as dataShare.DataShareHelper))));

      let actionData: LooseObject = {};
      actionData.markReadType = MarkRead.all;
      await conversationModel.updateSmsIsReadBySessionId(actionData, context, undefined);
      expect(context).not().assertUndefined();
      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_queryDraftByCondition_if', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve(undefined))));

      let threadId: number = -1;
      await conversationModel.queryDraftByCondition(threadId, context);
      expect(context).not().assertUndefined();
      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_queryDraftByCondition_complete', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();
      let mySet: DataShareResultSet = new MySet();
      mySet.rowCount = 1;

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve(mySet))
        } as dataShare.DataShareHelper)));

      let threadId: number = 1;
      await conversationModel.queryDraftByCondition(threadId, context);
      expect(context).not().assertUndefined();
      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_updateSmsInfoSmsTypeBySessionIds_if', 0, async () => {
      let callback: Function = (result: LooseObject) => {
        expect(result.code).assertEqual(-1);
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve(undefined))));

      let actionData: LooseObject = {};
      await conversationModel.updateSmsInfoSmsTypeBySessionIds(actionData, callback, context);

      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_updateSmsInfoSmsTypeBySessionIds_complete', 0, async () => {
      let callback: Function = (result: LooseObject) => {
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();
      let mySet: DataShareResultSet = new MySet();
      mySet.rowCount = 1;

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve({
          update: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            value: ValuesBucket): Promise<number> =>
          new Promise<number>(resolve => resolve(1))
        } as dataShare.DataShareHelper))));

      let actionData: LooseObject = {};
      actionData.threadIds = ['1', '2', '3'];
      await conversationModel.updateSmsInfoSmsTypeBySessionIds(actionData, callback, context);
      expect(context).not().assertUndefined();
      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_updateSmsInfoSmsTypeBySessionIds_catch', 0, async () => {
      let callback: Function = (result: LooseObject) => {
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();
      let mySet: DataShareResultSet = new MySet();
      mySet.rowCount = 1;

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve({
          update: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            value: ValuesBucket): Promise<number> => {
            throw new Error('error')
          }
        } as dataShare.DataShareHelper))));

      let actionData: LooseObject = {};
      actionData.threadIds = ['1', '2', '3'];
      await conversationModel.updateSmsInfoSmsTypeBySessionIds(actionData, callback, context);
      expect(context).not().assertUndefined();
      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_updateSmsInfoSmsTypeBySessionIds_if_callback_undefined', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve(undefined))));

      let actionData: LooseObject = {};
      await conversationModel.updateSmsInfoSmsTypeBySessionIds(actionData, undefined, context);
      expect(context).not().assertUndefined();
      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_updateSmsInfoSmsTypeBySessionIds_complete_callback_undefined', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();
      let mySet: DataShareResultSet = new MySet();
      mySet.rowCount = 1;

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve({
          update: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            value: ValuesBucket): Promise<number> =>
          new Promise<number>(resolve => resolve(1))
        } as dataShare.DataShareHelper))));

      let actionData: LooseObject = {};
      actionData.threadIds = ['1', '2', '3'];
      await conversationModel.updateSmsInfoSmsTypeBySessionIds(actionData, undefined, context);
      expect(context).not().assertUndefined();
      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_updateSmsInfoSmsTypeBySessionIds_catch_callback_undefined', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();
      let mySet: DataShareResultSet = new MySet();
      mySet.rowCount = 1;

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve({
          update: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            value: ValuesBucket): Promise<number> => {
            throw new Error('error')
          }
        } as dataShare.DataShareHelper))));

      let actionData: LooseObject = {};
      actionData.threadIds = ['1', '2', '3'];
      await conversationModel.updateSmsInfoSmsTypeBySessionIds(actionData, undefined, context);
      expect(context).not().assertUndefined();
      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_querySessionId_if', 0, async () => {
      let callback: Function = (result: LooseObject) => {
        expect(result.code).assertUndefined();
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve(undefined))));

      let actionData: LooseObject = {};
      await conversationModel.querySessionId(actionData, callback, context);
      expect(context).not().assertUndefined();
      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_querySessionId_if_callback_undefined', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve(undefined))));

      let actionData: LooseObject = {};
      await conversationModel.querySessionId(actionData, undefined, context);
      expect(context).not().assertUndefined();
      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_querySessionId_complete', 0, async () => {
      let callback: Function = (result: LooseObject) => {
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();
      let mySet: DataShareResultSet = new MySet();
      mySet.rowCount = 1;

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve(mySet))
        } as dataShare.DataShareHelper)));

      let actionData: LooseObject = {};
      actionData.msgId = ['1', '2', '3'];
      await conversationModel.querySessionId(actionData, callback, context);
      expect(context).not().assertUndefined();
      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_queryContactsAvatarInContactDataData', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();
      let mySet: DataShareResultSet = new MySet();
      mySet.rowCount = 1;

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve(mySet))
        } as dataShare.DataShareHelper)));

      let actionData: LooseObject = {};
      actionData.msgId = ['1', '2', '3'];
      queryContactsAvatarInContactDataDataBase(context, [1, 2], () => {});
      expect(context).not().assertUndefined();
      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_getInvalidDataFromDb', 0, async () => {
      let callback: Function = (result: LooseObject) => {
        expect(result.code).assertUndefined();
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();
      let counts: number[] = [];
      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve(undefined))));

      await conversationModel.getInvalidDataFromDb(context, '/sms_mms/invalid_part_info', counts);

      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_batchInsertSmsMmsInfo', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();
      let mySet: DataShareResultSet = new MySet();
      mySet.rowCount = 1;

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          batchInsert: (uri: string, buckets: ValuesBucket[]): Promise<number> =>
          new Promise<number>(resolve => resolve(1))
        } as dataShare.DataShareHelper)));

      let buckets: ValuesBucket[] = [
        {'msg_id': 1, 'msg_content': 'content1'},
        {'msg_id': 2, 'msg_content': 'content2'}
      ];
      await conversationModel.batchInsertSmsMmsInfo(buckets, context);
      expect(context).not().assertUndefined();
      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationModelTest_batchUpdateSmsMmsInfo', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker: MockKit = new MockKit();
      let mySet: DataShareResultSet = new MySet();
      mySet.rowCount = 1;

      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve({
          update: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            value: ValuesBucket): Promise<number> =>
          new Promise<number>(resolve => resolve(1))
        } as dataShare.DataShareHelper))));

      let buckets: ValuesBucket[] = [
        {'rcs_id': 1, 'msg_content': 'content1'},
        {'rcs_id': 2, 'msg_content': 'content2'}
      ];
      await conversationModel.batchUpdateSmsMmsInfo(buckets, context);
      expect(context).not().assertUndefined();
      mocker.clear(conversationModel);
      mocker.clear(DataShareHelper.getInstance());
    })
  })
}