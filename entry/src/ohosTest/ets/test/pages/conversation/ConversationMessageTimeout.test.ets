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
import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect, MockKit, when,
  ArgumentMatchers } from '@ohos/hypium'
import { GlobalContext } from '../../../../../main/ets/MainAbility/GlobalHelper'
import { mmsListType } from '../../../../../main/ets/pages/conversation/conversationController'
import { MessageTimeout } from '../../../../../main/ets/pages/conversation/ConversationMessageTimeout'
import myCommon from '@ohos.app.ability.common';
import DataShareHelper from '../../../../../main/ets/model/repository/DataShareHelper'
import { dataShare, dataSharePredicates, DataShareResultSet, ValuesBucket } from '@kit.ArkData'
import { BusinessError } from '@kit.BasicServicesKit'
import SharedPreferencesUtils from '../../../../../main/ets/utils/SharedPreferencesUtils'
import { StorageMessage } from '../../../../../main/ets/pages/conversation/StorageMessageTimeout'
import MySet from '../../MySet'
import ConversationModel from '../../../../../main/ets/model/ConversationModel'
import LooseObject from '../../../../../main/ets/data/LooseObject'
import ConversationService from '../../../../../main/ets/service/ConversationService'
import HiLog from '../../../../../main/ets/utils/HiLog';

export default function ConversationMessageTimeoutTest() {
  describe('ConversationMessageTimeoutTest', () => {
    const TAG = 'ConversationMessageTimeout';
    it('messageTimeoutProcessing', 0, () => {
      let conversationMessageTimeout: MessageTimeout = new MessageTimeout();
      let listArray:Array<mmsListType> = [];
      let mmsList:Array<mmsListType> = [];
      (conversationMessageTimeout as object)['threadId'] = 0;
      conversationMessageTimeout.messageTimeoutProcessing(listArray, true, 1, true);
      (conversationMessageTimeout as object)['threadId'] = 1;
      (conversationMessageTimeout as object)['mmsList'] = listArray;
      conversationMessageTimeout.messageTimeoutProcessing(listArray, true, 1, false);
      conversationMessageTimeout.messageTimeoutProcessing(listArray, true, 0);
      listArray.push({} as mmsListType);
      let currentTime = new Date().getTime();
      mmsList.push({
        isRcs: 1,
        msgState: 0,
      } as mmsListType, {
        msgState: 1,
        isRcs: 1,
      } as mmsListType, {
        msgState: 1,
        isRcs: 0,
        isMsm: false,
        timeMillisecond: currentTime + 1,
      } as mmsListType, {
        id: 1,
        msgState: 1,
        isRcs: 0,
        isMsm: false,
        timeMillisecond: currentTime + 1,
      } as mmsListType, {
        id: 1,
        msgState: 1,
        sendStatus: 1,
        isRcs: 0,
        isMsm: true,
        timeMillisecond: currentTime - 120 * 1000 - 1000,
      } as mmsListType);
      (conversationMessageTimeout as object)['threadId'] = 1;
      (conversationMessageTimeout as object)['mmsList'] = listArray;
      conversationMessageTimeout.messageTimeoutProcessing(mmsList, false, 1, false);
      (conversationMessageTimeout as object)['threadId'] = 1;
      let context = GlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext;
      conversationMessageTimeout.context = context;
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
      (conversationMessageTimeout as object)['mmsList'] = listArray;
      conversationMessageTimeout.messageTimeoutProcessing(mmsList, false, 1, true);
      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve({
          update: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            value: ValuesBucket): Promise<number> =>
          new Promise<number>(resolve => resolve(1))
        } as dataShare.DataShareHelper))));
      (conversationMessageTimeout as object)['mmsList'] = listArray;
      conversationMessageTimeout.messageTimeoutProcessing(mmsList, false, 1, false);
      expect(conversationMessageTimeout).not().assertUndefined();
      mocker.clear(DataShareHelper.getInstance());
    })

    it('messageDownloadTimeout', 0, () =>{
      let conversationMessageTimeout: MessageTimeout = new MessageTimeout();
      let item: mmsListType = new mmsListType();
      item.id = 1;
      let map: Map<number | string, number> = new Map<number | string, number>()
      map.set(1,1);
      (conversationMessageTimeout as object)['messageTimer'] = map;
      conversationMessageTimeout.messageDownloadTimeout(item);
      item.id = 2;
      conversationMessageTimeout.messageDownloadTimeout(item);
      expect(conversationMessageTimeout).not().assertUndefined();
    })

    it('checkMessageDownloadTimeout', 0, () =>{
      let conversationMessageTimeout: MessageTimeout = new MessageTimeout();
      let storageMessageList: string[] = [];
      let currentTime = new Date().getTime();
      storageMessageList.push(JSON.stringify(new StorageMessage(1,currentTime - 5 * 60 * 1000,true,true)));
      storageMessageList.push(JSON.stringify(new StorageMessage(1,currentTime - 7 * 60 * 1000,true,true)));
      storageMessageList.push(JSON.stringify(new StorageMessage(1,1,false,false)));
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences))(ArgumentMatchers.any)
        .afterReturn(storageMessageList);
      conversationMessageTimeout.context = null;
      conversationMessageTimeout.checkMessageDownloadTimeout();
      let context = GlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext;
      conversationMessageTimeout.context = context;
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
      storageMessageList.push(JSON.stringify(new StorageMessage(1,currentTime - 7 * 60 * 1000,true,true)));
      conversationMessageTimeout.checkMessageDownloadTimeout();
      let mySet: DataShareResultSet = new MySet();
      mySet.rowCount = 0;
      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve(mySet))
        } as dataShare.DataShareHelper)));
      let result: LooseObject = {};
      result.code = 0;
      result.abilityResult = [];
      result.abilityResult[0] = undefined;
      let conversationModel: ConversationModel = (ConversationService.getInstance() as object)['conversationModel'];
      when(mocker.mockFunc(conversationModel, conversationModel.encapsulateReturnResult))(ArgumentMatchers.any).afterReturn(result);
      storageMessageList.push(JSON.stringify(new StorageMessage(1,currentTime - 7 * 60 * 1000,true,true)));
      conversationMessageTimeout.checkMessageDownloadTimeout();
      result.abilityResult[0] = {
        msgState: 4,
        sendStatus: 1
      } as LooseObject;
      when(mocker.mockFunc(conversationModel, conversationModel.encapsulateReturnResult))(ArgumentMatchers.any).afterReturn(result);
      storageMessageList.push(JSON.stringify(new StorageMessage(1,currentTime - 7 * 60 * 1000,true,true)));
      conversationMessageTimeout.checkMessageDownloadTimeout();
      result.abilityResult[0] = {
        msgState: 1
      } as LooseObject;
      when(mocker.mockFunc(conversationModel, conversationModel.encapsulateReturnResult))(ArgumentMatchers.any).afterReturn(result);
      let mmsList:Array<mmsListType> = [];
      mmsList.push({
        id: 1,
        msgState: 1,
        sendStatus: 1,
        isRcs: 1,
        isMsm: true,
        timeMillisecond: currentTime + 120 * 1000 + 1000
      } as mmsListType);
      (conversationMessageTimeout as object)['mmsList'] = mmsList;
      storageMessageList.push(JSON.stringify(new StorageMessage(1,currentTime - 7 * 60 * 1000,true,true)));
      conversationMessageTimeout.checkMessageDownloadTimeout();
      let mmsListCopy:Array<mmsListType> = [];
      mmsListCopy.push({
        id: 2,
        msgState: 1,
        sendStatus: 1,
        isRcs: 1,
        isMsm: true,
        timeMillisecond: currentTime + 120 * 1000 + 1000
      } as mmsListType);
      (conversationMessageTimeout as object)['mmsList'] = mmsListCopy;
      storageMessageList.push(JSON.stringify(new StorageMessage(1,currentTime - 7 * 60 * 1000,true,true)));
      conversationMessageTimeout.checkMessageDownloadTimeout();
      expect(conversationMessageTimeout).not().assertUndefined();
      mocker.clear(DataShareHelper.getInstance());
      mocker.clear(conversationModel);
      mocker.clear(SharedPreferencesUtils);
    })

    it('updateMessageStatusForMsgIDs', 0, () =>{
      let mocker: MockKit = new MockKit();
      let conversationMessageTimeout: MessageTimeout = new MessageTimeout();
      (conversationMessageTimeout as object)['updateMessageStatusForMsgIDs']([])
      conversationMessageTimeout.context = null;
      (conversationMessageTimeout as object)['updateMessageStatusForMsgIDs']([])
      mocker.mockFunc(HiLog, HiLog.e);
      mocker.verify('e', [TAG, 'context is null']).never();
      let context = GlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext;
      conversationMessageTimeout.context = context;
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
      (conversationMessageTimeout as object)['updateMessageStatusForMsgIDs']([1,2])
      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve({
          update: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            value: ValuesBucket): Promise<number> =>
          new Promise<number>(resolve => resolve(1))
        } as dataShare.DataShareHelper))));
      (conversationMessageTimeout as object)['updateMessageStatusForMsgIDs']([1,2])
      expect(conversationMessageTimeout.context).not().assertUndefined();
      mocker.clear(DataShareHelper.getInstance());
      mocker.clear(HiLog);
    })

    it('updateMessageStatusForSmsMmsInfoWithItme', 0, () =>{
      let conversationMessageTimeout: MessageTimeout = new MessageTimeout();
      let item: mmsListType = new mmsListType();
      item.id = 1;
      item.sendStatus = 1;
      (conversationMessageTimeout as object)['updateMessageStatusForSmsMmsInfoWithItme']({} as mmsListType);
      conversationMessageTimeout.context = null;
      (conversationMessageTimeout as object)['updateMessageStatusForSmsMmsInfoWithItme'](item);
      let context = GlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext;
      conversationMessageTimeout.context = context;
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
      (conversationMessageTimeout as object)['updateMessageStatusForSmsMmsInfoWithItme'](item);
      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve({
          update: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            value: ValuesBucket): Promise<number> =>
          new Promise<number>(resolve => resolve(1))
        } as dataShare.DataShareHelper))));
      (conversationMessageTimeout as object)['updateMessageStatusForSmsMmsInfoWithItme'](item);
      expect(conversationMessageTimeout.context).not().assertUndefined()
      mocker.clear(DataShareHelper.getInstance());
    })

    it('updateMessageStatusForSessionWithItem', 0, () =>{
      let conversationMessageTimeout: MessageTimeout = new MessageTimeout();
      let item: mmsListType = new mmsListType();
      item.id = 1;
      item.sendStatus = 1;
      (conversationMessageTimeout as object)['threadId'] = 0;
      (conversationMessageTimeout as object)['updateMessageStatusForSessionWithItem'](item);
      (conversationMessageTimeout as object)['threadId'] = 1;
      conversationMessageTimeout.context = null;
      (conversationMessageTimeout as object)['updateMessageStatusForSessionWithItem'](item);
      let context = GlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext;
      conversationMessageTimeout.context = context;
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
      (conversationMessageTimeout as object)['updateMessageStatusForSessionWithItem'](item);
      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(context)
        .afterReturn((new Promise<dataShare.DataShareHelper>(resolve => resolve({
          update: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            value: ValuesBucket): Promise<number> =>
          new Promise<number>(resolve => resolve(1))
        } as dataShare.DataShareHelper))));
      (conversationMessageTimeout as object)['updateMessageStatusForSessionWithItem'](item);
      expect(conversationMessageTimeout.context).not().assertUndefined()
      mocker.clear(DataShareHelper.getInstance());
    })

    it('clearAllTimer', 0, () =>{
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.i);
      let conversationMessageTimeout: MessageTimeout = new MessageTimeout();
      (conversationMessageTimeout as object)['clearAllTimer']();
      mocker.verify('i', [TAG, 'clearAllTimer']).once();
      mocker.clear(HiLog)
    })
  })
}