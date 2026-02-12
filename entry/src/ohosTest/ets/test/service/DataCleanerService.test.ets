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
import { describe, MockKit, it, expect, beforeEach, ArgumentMatchers, when, afterEach } from '@ohos/hypium'
import { messageType } from '../../../../main/ets/pages/conversationlist/conversationListController';
import SharedPreferencesUtils from '../../../../main/ets/utils/SharedPreferencesUtils';
import ConversationService from '../../../../main/ets/service/ConversationService';
import DataCleanerService from '../../../../main/ets/service/DataCleanerService';
import { dataShare, dataSharePredicates, DataShareResultSet, ValuesBucket } from '@kit.ArkData';
import MySet from '../MySet';
import DataShareHelper from '../../../../main/ets/model/repository/DataShareHelper';
import { BusinessError } from '@kit.BasicServicesKit';
import { DTGlobalContext } from '../../testability/TestAbility';

export default function dataCleanerServiceTest() {
  describe('dataCleanerServiceTest', () => {

    const KEY_NORAML: string = 'last_clean_unread_time_normal';
    const KEY_INFO: string = 'last_clean_unread_time_info';
    let dataCleanerService: DataCleanerService;
    let mocker: MockKit;
    let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;

    beforeEach(() => {
      mocker = new MockKit();
    })

    afterEach(() => {
      mocker.clear(ConversationService.getInstance());
      mocker.clear(SharedPreferencesUtils);
      mocker.clear(DataShareHelper.getInstance());
    })

    it('dataCleanerServiceTest_getInstance', 0, () => {
      let getFromPreferences: Function =
        mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences);
      when(getFromPreferences)(KEY_NORAML).afterReturn(-1);
      when(getFromPreferences)(KEY_INFO).afterReturn(-1);
      dataCleanerService = DataCleanerService.getTestInstance();
      expect(typeof DataCleanerService.getInstance()).assertEqual(typeof dataCleanerService);
      mocker.clear(SharedPreferencesUtils);
    })

    it('dataCleanerServiceTest_unReadClean1_type_0', 0, () => {
      let getFromPreferences: Function =
        mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences);
      when(getFromPreferences)(KEY_NORAML).afterReturn(-1);
      when(getFromPreferences)(KEY_INFO).afterReturn(-1);
      dataCleanerService = DataCleanerService.getTestInstance();
      let callback: Function = (res: boolean) => {
        expect(res).assertTrue();
      };
      let messageList: Array<messageType> = [{
        threadId: 0,
        countOfUnread: 0
      } as messageType];
      when(mocker.mockFunc(ConversationService.getInstance(),
        ConversationService.getInstance().querySmsMmsInfoByConditionAll))(ArgumentMatchers.any)
        .afterAction(() => {
          callback(true)
        });
      mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.saveToPreferences);

      dataCleanerService.unReadClean(context, messageList, 0, callback);
      mocker.clear(SharedPreferencesUtils);
    })

    it('dataCleanerServiceTest_unReadClean1_type_0_success', 0, () => {
      let getFromPreferences: Function =
        mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences);
      when(getFromPreferences)(KEY_NORAML).afterReturn(-1);
      when(getFromPreferences)(KEY_INFO).afterReturn(-1);
      dataCleanerService = DataCleanerService.getTestInstance();
      let callback: Function = (res: boolean) => {
        expect(res).assertTrue();
      };
      let messageList: Array<messageType> = [{
        threadId: 0,
        countOfUnread: 0
      } as messageType];
      let mySet: DataShareResultSet = new MySet();
      mySet.rowCount = 1;
      when(mocker.mockFunc(DataShareHelper.getInstance(),
        DataShareHelper.getInstance().initSmsDB))(ArgumentMatchers.any)
        .afterReturn(new Promise<dataShare.DataShareHelper | undefined>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve(mySet)),
          update: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            value: ValuesBucket): Promise<number> =>
          new Promise<number>(resolve => resolve(1))
        } as dataShare.DataShareHelper)));
      mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.saveToPreferences);

      dataCleanerService.unReadClean(context, messageList, 0, callback);
      mocker.clear(SharedPreferencesUtils);
    })

    it('dataCleanerServiceTest_unReadClean1_type_0_update_fail', 0, () => {
      let getFromPreferences: Function =
        mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences);
      when(getFromPreferences)(KEY_NORAML).afterReturn(-1);
      when(getFromPreferences)(KEY_INFO).afterReturn(-1);
      dataCleanerService = DataCleanerService.getTestInstance();
      let callback: Function = (res: boolean) => {
        expect(res).assertTrue();
      };
      let messageList: Array<messageType> = [{
        threadId: 0,
        countOfUnread: 0
      } as messageType];
      let mySet: DataShareResultSet = new MySet();
      mySet.rowCount = 1;
      when(mocker.mockFunc(DataShareHelper.getInstance(),
        DataShareHelper.getInstance().initSmsDB))(ArgumentMatchers.any)
        .afterReturn(new Promise<dataShare.DataShareHelper | undefined>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve(mySet)),
          update: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            value: ValuesBucket): Promise<number> =>
          new Promise<number>((resolve: (value: number | PromiseLike<number>) => void,
            reject: (reason?: BusinessError) => void) => reject({
            code: -1, message: 'error'
          } as BusinessError))
        } as dataShare.DataShareHelper)));
      mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.saveToPreferences);

      dataCleanerService.unReadClean(context, messageList, 0, callback);
      mocker.clear(SharedPreferencesUtils);
    })

    it('dataCleanerServiceTest_unReadClean1_type_0_query_fail', 0, () => {
      let getFromPreferences: Function =
        mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences);
      when(getFromPreferences)(KEY_NORAML).afterReturn(-1);
      when(getFromPreferences)(KEY_INFO).afterReturn(-1);
      dataCleanerService = DataCleanerService.getTestInstance();
      let callback: Function = (res: boolean) => {
        expect(res).assertTrue();
      };
      let messageList: Array<messageType> = [{
        threadId: 0,
        countOfUnread: 0
      } as messageType];
      when(mocker.mockFunc(DataShareHelper.getInstance(),
        DataShareHelper.getInstance().initSmsDB))(ArgumentMatchers.any)
        .afterReturn(new Promise<dataShare.DataShareHelper | undefined>(resolve => resolve(undefined)));
      mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.saveToPreferences);

      dataCleanerService.unReadClean(context, messageList, 0, callback);
    })

    it('dataCleanerServiceTest_unReadClean2_type_0', 0, () => {
      let getFromPreferences: Function =
        mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences);
      when(getFromPreferences)(KEY_NORAML).afterReturn(Date.now() - 3592000000);
      when(getFromPreferences)(KEY_INFO).afterReturn(-1);
      dataCleanerService = DataCleanerService.getTestInstance();
      let callback: Function = () => {
      };
      let messageList: Array<messageType> = [{
        threadId: 0,
        countOfUnread: 0
      } as messageType];
      when(mocker.mockFunc(ConversationService.getInstance(),
        ConversationService.getInstance().querySmsMmsInfoByConditionAll))(ArgumentMatchers.any)
        .afterAction(() => {
          callback(true)
        });
      mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.saveToPreferences);
      dataCleanerService.unReadClean(context, messageList, 0, callback);
    })

    it('dataCleanerServiceTest_unReadClean1_type_1', 0, () => {
      let getFromPreferences: Function =
        mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences);
      when(getFromPreferences)(KEY_NORAML).afterReturn(-1);
      when(getFromPreferences)(KEY_INFO).afterReturn(-1);
      dataCleanerService = DataCleanerService.getTestInstance();
      let callback: Function = (res: boolean) => {
        expect(res).assertTrue();
      };
      let messageList: Array<messageType> = [{
        threadId: 0,
        countOfUnread: 0
      } as messageType];
      when(mocker.mockFunc(ConversationService.getInstance(),
        ConversationService.getInstance().querySmsMmsInfoByConditionAll))(ArgumentMatchers.any)
        .afterAction(() => {
          callback(true)
        });
      mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.saveToPreferences);

      dataCleanerService.unReadClean(context, messageList, 1, callback);
    })

    it('dataCleanerServiceTest_unReadClean2_type_1', 0, () => {
      let getFromPreferences: Function =
        mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences);
      when(getFromPreferences)(KEY_NORAML).afterReturn(-1);
      when(getFromPreferences)(KEY_INFO).afterReturn(Date.now() - 3592000000);
      dataCleanerService = DataCleanerService.getTestInstance();
      let callback: Function = (res: boolean) => {
        expect(res).assertTrue();
      };
      let messageList: Array<messageType> = [{
        threadId: 0,
        countOfUnread: 0
      } as messageType];
      when(mocker.mockFunc(ConversationService.getInstance(),
        ConversationService.getInstance().querySmsMmsInfoByConditionAll))(ArgumentMatchers.any)
        .afterAction(() => {
          callback(true)
        });
      mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.saveToPreferences);

      dataCleanerService.unReadClean(context, messageList, 1, callback);
    })

    it('dataCleanerServiceTest_unReadClean2_type_2', 0, () => {
      let getFromPreferences: Function =
        mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences);
      when(getFromPreferences)(KEY_NORAML).afterReturn(-1);
      when(getFromPreferences)(KEY_INFO).afterReturn(-1);
      dataCleanerService = DataCleanerService.getTestInstance();
      let callback: Function = (res: boolean) => {
        expect(res).assertTrue();
      };
      let messageList: Array<messageType> = [{
        threadId: 0,
        countOfUnread: 0
      } as messageType];
      mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.saveToPreferences);
      dataCleanerService.unReadClean(context, messageList, 2, callback);
      mocker.verify('saveToPreferences', [KEY_NORAML, Date.now()]).never();
    })
  })
}