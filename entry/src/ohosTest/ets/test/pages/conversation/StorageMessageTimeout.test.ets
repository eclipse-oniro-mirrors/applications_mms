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
import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect, MockKit,
  ArgumentMatchers,
  when} from '@ohos/hypium'
import { GlobalContext } from '../../../../../main/ets/MainAbility/GlobalHelper';
import { mmsListType } from '../../../../../main/ets/pages/conversation/conversationController';
import {
  StorageMessage,
  StorageMessageTimeout } from '../../../../../main/ets/pages/conversation/StorageMessageTimeout';
import myCommon from '@ohos.app.ability.common';
import SharedPreferencesUtils from '../../../../../main/ets/utils/SharedPreferencesUtils';
import { dataShare, dataSharePredicates, DataShareResultSet, ValuesBucket } from '@kit.ArkData';
import DataShareHelper from '../../../../../main/ets/model/repository/DataShareHelper';

export default function StorageMessageTimeoutTest() {
  describe('StorageMessageTimeoutTest', () => {

    it('checkOutMessageStorageByTaskPool_if0', 0, () => {
      let storageMessageList: string[] = []
      // storageMessageList.push(JSON.stringify(new StorageMessage(1, 0, true, true)));
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences))(ArgumentMatchers.any)
        .afterReturn(storageMessageList);
      let storageMessageTimeout = StorageMessageTimeout.getInstance();
      storageMessageTimeout.context =  GlobalContext.getContext()
        .getObject('mmsContext') as myCommon.UIAbilityContext;
      storageMessageTimeout.checkOutMessageStorageByTaskPool();
      expect(storageMessageTimeout).not().assertUndefined();
      mocker.clear(SharedPreferencesUtils);
    })

    it('checkOutMessageStorageByTaskPool_if1', 0, () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences))(ArgumentMatchers.any)
        .afterReturn([]);
      let storageMessageTimeout = new StorageMessageTimeout();
      storageMessageTimeout.context =  GlobalContext.getContext()
        .getObject('mmsContext') as myCommon.UIAbilityContext;
      storageMessageTimeout.checkOutMessageStorageByTaskPool();
      mocker.verify('getFromPreferences',['StorageMessageIDList', []]).never();
      mocker.clear(SharedPreferencesUtils);
    })

    it('sendMessageStorageAndTimeout_if1', 0, async () => {
      let storageMessageTimeout = new StorageMessageTimeout();
      storageMessageTimeout.context =  GlobalContext.getContext()
        .getObject('mmsContext') as myCommon.UIAbilityContext;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(DataShareHelper.getInstance(),
        DataShareHelper.getInstance().initSmsDB))(ArgumentMatchers.any)
        .afterReturn(new Promise<dataShare.DataShareHelper | undefined>(resolve => resolve(undefined)));
      when(mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences))(ArgumentMatchers.any)
        .afterReturn([]);
      let item: mmsListType = new mmsListType();
      item.id = 1;
      let map = new Map<number | string, number>();
      map.set(1,1);
      (storageMessageTimeout as object)['messageTimer'] = map;
      storageMessageTimeout.sendMessageStorageAndTimeout(item,true);
      (storageMessageTimeout as object)['searchForSmsMmsInfo'](item,()=>{});
      (storageMessageTimeout as object)['updateMessageStatusForSmsMmsInfoWithItem'](item);
      expect(storageMessageTimeout).not().assertUndefined();
      mocker.clear(DataShareHelper.getInstance());
      mocker.clear(SharedPreferencesUtils);
    })

    it('sendMessageStorageAndTimeout_if2', 0, async () => {
      let storageMessageTimeout = StorageMessageTimeout.getInstance();
      storageMessageTimeout = StorageMessageTimeout.getInstance();
      new StorageMessage(1,1,true,true);
      new StorageMessage(1,1,true);
      let map = new Map<number | string, number>();
      (storageMessageTimeout as object)['messageTimer'] = map;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(DataShareHelper.getInstance(),
        DataShareHelper.getInstance().initSmsDB))(ArgumentMatchers.any)
        .afterReturn(new Promise<dataShare.DataShareHelper | undefined>(resolve => resolve(undefined)));
      when(mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences))(ArgumentMatchers.any)
        .afterReturn([]);
      let item: mmsListType = new mmsListType();
      item.id = 1;
      item.isMsm  = true;
      storageMessageTimeout.sendMessageStorageAndTimeout(item,true);
      storageMessageTimeout.sendMessageStorageAndTimeout(item,false);
      item.isMsm  = false;
      storageMessageTimeout.sendMessageStorageAndTimeout(item);
      storageMessageTimeout.context = null;
      (storageMessageTimeout as object)['searchForSmsMmsInfo'](item,()=>{});
      (storageMessageTimeout as object)['updateMessageStatusForSmsMmsInfoWithItem'](item);
      expect(storageMessageTimeout).not().assertUndefined();
      mocker.clear(DataShareHelper.getInstance());
      mocker.clear(SharedPreferencesUtils);
    })

    it('sendMessageStorageAndTimeout_if3', 0, async () => {
      let storageMessageTimeout = StorageMessageTimeout.getInstance();
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(DataShareHelper.getInstance(),
        DataShareHelper.getInstance().initSmsDB))(ArgumentMatchers.any)
        .afterReturn(new Promise<dataShare.DataShareHelper | undefined>(resolve => resolve(undefined)));
      when(mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences))(ArgumentMatchers.any)
        .afterReturn([]);
      let item: mmsListType = {} as mmsListType;
      (storageMessageTimeout as object)['searchForSmsMmsInfo'](item,()=>{});
      (storageMessageTimeout as object)['updateMessageStatusForSmsMmsInfoWithItem'](item);
      expect(storageMessageTimeout).not().assertUndefined();
      mocker.clear(DataShareHelper.getInstance());
      mocker.clear(SharedPreferencesUtils);
    })

  })
}