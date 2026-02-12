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
import { describe, beforeEach, afterEach, it, expect, MockKit, when, ArgumentMatchers } from '@ohos/hypium';
import LooseObject from '../../../../main/ets/data/LooseObject';
import ConversationListService, { ResponseType } from '../../../../main/ets/service/ConversationListService';
import { ValuesBucket } from '@ohos.data.ValuesBucket';
import { GlobalContext } from '../../../../main/ets/MainAbility/GlobalHelper';
import DataShareHelper from '../../../../main/ets/model/repository/DataShareHelper';
import { DTGlobalContext } from '../../testability/TestAbility';
import { window } from '@kit.ArkUI';
import myCommon from '@ohos.app.ability.common';
import { dataShare, dataSharePredicates, DataShareResultSet } from '@kit.ArkData';
import { ConversationListInfo } from '../../../../main/ets/model/conversationlist/ConversationListInfo';
import { BusinessError } from '@kit.BasicServicesKit';
import ConversationService from '../../../../main/ets/service/ConversationService';
import { AddressInfo, Mms } from '../../../../main/ets/utils/TypesUtils';
import TelephoneUtil from '../../../../main/ets/utils/TelephoneUtil';
import { resourceManager } from '@kit.LocalizationKit';
import MySet from '../MySet';

export default function conversationListServiceTest() {
  describe('conversationListServiceTest', () => {

    let mConversationListSe: ConversationListService;
    let mocker: MockKit;
    let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;

    beforeEach(() => {
      mConversationListSe = ConversationListService.getTestInstance();
      mocker = new MockKit();
    })

    afterEach(() => {
      mocker.clear(mConversationListSe);
      mocker.clear(GlobalContext.getContext());
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationListServiceTest_getInstance', 0, () => {
      expect(typeof mConversationListSe).assertEqual(typeof ConversationListService.getInstance());
    })

    it('conversationListServiceTest_insertSession_context', 0, () => {
      let actionData: LooseObject = {
        "rcsType": 1,
        "rcsId": 1,
        "isMms": false
      };
      let callback: Function = (res: Object) => {
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext;
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            return new Promise<void>(resolve => resolve());
          }
        } as Object | window.WindowStage);
      mConversationListSe.insertSession(actionData, callback, context);
      expect(mConversationListSe).not().assertUndefined();
      mocker.clear(GlobalContext.getContext())
    })

    it('conversationListServiceTest_insertSession_context_undefined', 0, () => {
      let actionData: LooseObject = {
        "rcsType": 1,
        "rcsId": 1,
        "isMms": false
      };
      let callback: Function = (res: LooseObject) => {
        expect(res.code).assertEqual(-1);
      };
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn(null);
      when(mocker.mockFunc(DataShareHelper.getInstance(),
        DataShareHelper.getInstance().initSmsDB))(ArgumentMatchers.any)
        .afterReturn(new  Promise<dataShare.DataShareHelper | undefined>(resolve => resolve(undefined)));
      mConversationListSe.insertSession(actionData, callback, context);
      mocker.clear(GlobalContext.getContext())
      mocker.clear(DataShareHelper.getInstance())
    })

    it('conversationListServiceTest_deleteSessionByCondition_context', 0, () => {
      let actionData: LooseObject = {
        "rcsType": 1,
        "rcsId": 1,
        "isMms": false
      };
      let callback: Function = (res: LooseObject) => {};
      let context = DTGlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext;
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: 0
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve());
          }
        } as Object | window.WindowStage);
      mConversationListSe.deleteSessionByCondition(actionData, callback, context);
      mocker.clear(GlobalContext.getContext())
    })

    it('conversationListServiceTest_deleteSessionByCondition_context_undefined', 0, () => {
      let actionData: LooseObject = {
        "rcsType": 1,
        "rcsId": 1,
        "isMms": false
      };
      let callback: Function = (res: LooseObject) => {
        expect(res.code).assertEqual(-1);
      };
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn(null);
      when(mocker.mockFunc(DataShareHelper.getInstance(),
        DataShareHelper.getInstance().initSmsDB))(ArgumentMatchers.any)
        .afterReturn(new  Promise<dataShare.DataShareHelper | undefined>(resolve => resolve(undefined)));
      mConversationListSe.deleteSessionByCondition(actionData, callback, context);
      mocker.clear(GlobalContext.getContext())
      mocker.clear(DataShareHelper.getInstance())
    })

    it('conversationListServiceTest_updateSessionByCondition_context', 0, () => {
      let actionData: LooseObject = {
        "rcsType": 1,
        "rcsId": 1,
        "isMms": false
      };
      let valueBucket: ValuesBucket = {};
      let callback: Function = (res: Object) => {
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext;
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            return new Promise<void>(resolve => resolve());
          }
        } as Object | window.WindowStage);
      mConversationListSe.updateSessionByCondition(context, actionData, valueBucket, callback);
      expect(mConversationListSe).not().assertUndefined();
      mocker.clear(GlobalContext.getContext())
    })

    it('conversationListServiceTest_updateSessionByCondition_context_undefined', 0, () => {
      let actionData: LooseObject = {
        "rcsType": 1,
        "rcsId": 1,
        "isMms": false
      };
      let valueBucket: ValuesBucket = {};
      let callback: Function = (res: LooseObject) => {
        expect(res.code).assertEqual(-1);
      };
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn(null);
      when(mocker.mockFunc(DataShareHelper.getInstance(),
        DataShareHelper.getInstance().initSmsDB))(ArgumentMatchers.any)
        .afterReturn(new  Promise<dataShare.DataShareHelper | undefined>(resolve => resolve(undefined)));
      mConversationListSe.updateSessionByCondition(context, actionData, valueBucket, callback, undefined);
      mocker.clear(GlobalContext.getContext())
      mocker.clear(DataShareHelper.getInstance())
    })

    it('conversationListServiceTest_fetchRecentContactsAndBatchUpdateSession', 0, () => {
      let callback: Function = (res: LooseObject) => {
        expect(res.code).assertEqual(0);
      };
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: 0
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve());
          }
        } as Object | window.WindowStage);
      mConversationListSe.fetchRecentContactsAndBatchUpdateSession(context, '0', '0', callback);
      mocker.clear(GlobalContext.getContext())
    })

    it('conversationListServiceTest_fetchRecentContactsAndBatchUpdateSession_else', 0, () => {
      let callback: Function = (res: LooseObject) => {
        expect(res.code).assertUndefined();
      };
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn(null);
      when(mocker.mockFunc(DataShareHelper.getInstance(),
        DataShareHelper.getInstance().initContactDB))(ArgumentMatchers.any)
        .afterReturn(new  Promise<dataShare.DataShareHelper | undefined>(resolve => resolve(undefined)));
      mConversationListSe.fetchRecentContactsAndBatchUpdateSession(context, '', '', callback);
      mocker.clear(GlobalContext.getContext())
      mocker.clear(DataShareHelper.getInstance())
    })

    it('conversationListServiceTest_fetchDeleteContactsAndUpdateSession', 0, () => {
      let callback: Function = (res: LooseObject) => {
        expect(res.code).assertEqual(0);
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext;
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: 0
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve());
          }
        } as Object | window.WindowStage);

      mConversationListSe.fetchDeleteContactsAndUpdateSession(['0'], context, callback);

      mocker.clear(GlobalContext.getContext())
    })

    it('conversationListServiceTest_fetchDeleteContactsAndUpdateSession_else', 0, () => {
      let callback: Function = (res: LooseObject) => {
        expect(res.code).assertUndefined();
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext;
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn(null);
      when(mocker.mockFunc(DataShareHelper.getInstance(),
        DataShareHelper.getInstance().initContactDB))(ArgumentMatchers.any)
        .afterReturn(new  Promise<dataShare.DataShareHelper | undefined>(resolve => resolve(undefined)));
      mConversationListSe.fetchDeleteContactsAndUpdateSession([''], context, callback);
      mocker.clear(GlobalContext.getContext())
      mocker.clear(DataShareHelper.getInstance())
    })

    it('conversationListServiceTest_markAsReadFromReceive_context', 0, () => {
      let actionData: LooseObject = {
        "rcsType": 1,
        "rcsId": 1,
        "isMms": false
      };
      let callback: Function = (res: LooseObject) => {
        expect(res.code).assertEqual(0);
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext;
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: 0
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve());
          }
        } as Object | window.WindowStage);
      mConversationListSe.markAsReadFromReceive(actionData, callback, context);
      mocker.clear(GlobalContext.getContext())
    })

    it('conversationListServiceTest_markAsReadFromReceive_context_undefined', 0, () => {
      let actionData: LooseObject = {
        "rcsType": 1,
        "rcsId": 1,
        "isMms": false
      };
      let callback: Function = (res: LooseObject) => {
        expect(res.code).assertEqual(-1);
      };
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn(null);
      when(mocker.mockFunc(DataShareHelper.getInstance(),
        DataShareHelper.getInstance().initSmsDB))(ArgumentMatchers.any)
        .afterReturn(new  Promise<dataShare.DataShareHelper | undefined>(resolve => resolve(undefined)));
      mConversationListSe.markAsReadFromReceive(actionData, callback, context);
      mocker.clear(GlobalContext.getContext())
      mocker.clear(DataShareHelper.getInstance())
    })

    it('conversationListServiceTest_querySessionByCondition_context', 0, () => {
      let actionData: LooseObject = {
        "rcsType": 1,
        "rcsId": 1,
        "isMms": false
      };
      let callback: Function = (res: LooseObject) => {
        expect(res.code).assertEqual(0);
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext;
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: 0
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve());
          }
        } as Object | window.WindowStage);
      mConversationListSe.querySessionByCondition(context, actionData, callback);
      mocker.clear(GlobalContext.getContext())
    })

    it('conversationListServiceTest_querySessionByCondition_context_undefined', 0, () => {
      let actionData: LooseObject = {
        "rcsType": 1,
        "rcsId": 1,
        "isMms": false
      };
      let callback: Function = (res: LooseObject) => {
        expect(res.code).assertEqual(-1);
      };
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn(null);
      when(mocker.mockFunc(DataShareHelper.getInstance(),
        DataShareHelper.getInstance().initSmsDB))(ArgumentMatchers.any)
        .afterReturn(new  Promise<dataShare.DataShareHelper | undefined>(resolve => resolve(undefined)));
      mConversationListSe.querySessionByCondition(context, actionData, callback);
      mocker.clear(GlobalContext.getContext())
      mocker.clear(DataShareHelper.getInstance())
    })

    it('conversationListServiceTest_querySessionTelPhoneByThreadId_context_undefined', 0, () => {
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn(null);
      when(mocker.mockFunc(DataShareHelper.getInstance(),
        DataShareHelper.getInstance().initSmsDB))(ArgumentMatchers.any)
        .afterReturn(new  Promise<dataShare.DataShareHelper | undefined>(resolve => resolve(undefined)));
      mConversationListSe.querySessionTelPhoneByThreadId(context, 1);
      expect(mConversationListSe).not().assertUndefined();
      mocker.clear(GlobalContext.getContext())
      mocker.clear(DataShareHelper.getInstance())
    })

    it('conversationListServiceTest_querySessionTelPhoneByThreadId_context', 0, () => {
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn(null);
      when(mocker.mockFunc(DataShareHelper.getInstance(),
        DataShareHelper.getInstance().initSmsDB))(ArgumentMatchers.any)
        .afterReturn(new  Promise<dataShare.DataShareHelper | undefined>(resolve => resolve(undefined)));
      mConversationListSe.querySessionTelPhoneByThreadId(context, undefined);
      expect(mConversationListSe).not().assertUndefined();
      mocker.clear(GlobalContext.getContext())
      mocker.clear(DataShareHelper.getInstance())
    })

    it('conversationListServiceTest_querySessionResultByCondition_context', 0, () => {
      let actionData: LooseObject = {
        "rcsType": 1,
        "rcsId": 1,
        "isMms": false
      };
      let callback: Function = (res: LooseObject) => {
        expect(res.code).assertEqual(0);
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext;
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: 0
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve());
          }
        } as Object | window.WindowStage);
      mConversationListSe.querySessionResultByCondition(actionData, callback, context);
      mocker.clear(GlobalContext.getContext())
    })

    it('conversationListServiceTest_querySessionResultByCondition_context_undefined', 0, () => {
      let actionData: LooseObject = {
        "rcsType": 1,
        "rcsId": 1,
        "isMms": false
      };
      let callback: Function = (res: LooseObject) => {
        expect(res.response.length).assertEqual(0);
      };
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn(null);
      when(mocker.mockFunc(DataShareHelper.getInstance(),
        DataShareHelper.getInstance().initSmsDB))(ArgumentMatchers.any)
        .afterReturn(new  Promise<dataShare.DataShareHelper | undefined>(resolve => resolve(undefined)));
      when(mocker.mockFunc(DataShareHelper.getInstance(),
        DataShareHelper.getInstance().initSilenceSmsDBSessionTable))(ArgumentMatchers.any)
        .afterReturn(new  Promise<dataShare.DataShareHelper | undefined>(resolve => resolve(undefined)));
      mConversationListSe.querySessionResultByCondition(actionData, callback, context);
      mocker.clear(GlobalContext.getContext())
      mocker.clear(DataShareHelper.getInstance())
    })

    it('conversationListServiceTest_querySessionSizeByCondition_context', 0, () => {
      let actionData: LooseObject = {
        "rcsType": 1,
        "rcsId": 1,
        "isMms": false
      };
      let callback: Function = (res: LooseObject) => {
        expect(res.code).assertEqual(0);
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext;
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: 0
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve());
          }
        } as Object | window.WindowStage);
      mConversationListSe.querySessionSizeByCondition(actionData, callback, context);
      mocker.clear(GlobalContext.getContext())
    })

    it('conversationListServiceTest_querySessionSizeByCondition_context_undefined', 0, () => {
      let actionData: LooseObject = {
        "rcsType": 1,
        "rcsId": 1,
        "isMms": false
      };
      let callback: Function = (res: LooseObject) => {
        expect(res.code).assertEqual(-1);
      };
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn(null);
      when(mocker.mockFunc(DataShareHelper.getInstance(),
        DataShareHelper.getInstance().initSmsDB))(ArgumentMatchers.any)
        .afterReturn(new  Promise<dataShare.DataShareHelper | undefined>(resolve => resolve(undefined)));
      mConversationListSe.querySessionSizeByCondition(actionData, callback, context);
      mocker.clear(GlobalContext.getContext())
      mocker.clear(DataShareHelper.getInstance())
    })

    it('conversationListServiceTest_getSessionListSize_fail', 0, async () => {
      let actionData: LooseObject = {
        "rcsType": 1,
        "rcsId": 1,
        "isMms": false
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext;
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: -1,
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve());
          }
        } as Object | window.WindowStage);
      let res = await mConversationListSe.getSessionListSize(actionData, context);
      expect(res).assertEqual(0);
      mocker.clear(GlobalContext.getContext())
    })

    it('conversationListServiceTest_getSessionListSize_success', 0, async () => {
      let actionData: LooseObject = {
        "rcsType": 1,
        "rcsId": 1,
        "isMms": false
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext;
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: 0,
              abilityResult: 1
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve());
          }
        } as Object | window.WindowStage);
      let res = await mConversationListSe.getSessionListSize(actionData, context);
      expect(res).assertEqual(1);
      mocker.clear(GlobalContext.getContext())
    })

    it('conversationListServiceTest_getSessionListResult_success', 0, async () => {
      let actionData: LooseObject = {
        "rcsType": 1,
        "rcsId": 1,
        "isMms": false
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext;
      let conversationInfo = new ConversationListInfo(1, 1, "1", "1", 0, 0, 1, 2, 1, 1, 1, '1', '1', 1, "1", '1');
      conversationInfo.hasMms = 1;
      conversationInfo.hasAttachment = 1;
      conversationInfo.telephone = '77777,77779';
      let conversationInfo1 = new ConversationListInfo(1, 1, "1", "1", 2, 1, 1, 3, 2, 2, 2, '1', '1', 2, "1", '1');
      conversationInfo1.hasMms = 2;
      conversationInfo1.hasAttachment = 2;
      conversationInfo.telephone = '777';
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: 0,
              abilityResult: [conversationInfo]
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve());
          }
        } as Object | window.WindowStage);
      let res: LooseObject = await mConversationListSe.getSessionListResult(actionData, context);
      expect(res.telephones.length).assertEqual(1);
      mocker.clear(GlobalContext.getContext())
    })

    it('conversationListServiceTest_getSessionListResult_fail', 0, async () => {
      let actionData: LooseObject = {
        "rcsType": 1,
        "rcsId": 1,
        "isMms": false
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext;
      let conversationInfo = new ConversationListInfo(1, 1, "1", "1", 0, 0, 1, 2, 1, 1, 1, '1', '1', 1, "1", '1');
      conversationInfo.hasMms = 1;
      conversationInfo.hasAttachment = 1;
      conversationInfo.telephone = '77777,77779';
      let conversationInfo1 = new ConversationListInfo(1, 1, "1", "1", 2, 1, 1, 3, 2, 2, 2, '1', '1', 2, "1", '1');
      conversationInfo1.hasMms = 2;
      conversationInfo1.hasAttachment = 2;
      conversationInfo.telephone = '777';
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: -1,
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve());
          }
        } as Object | window.WindowStage);
      let res: LooseObject = await mConversationListSe.getSessionListResult(actionData, context);
      expect(res.telephones.length).assertEqual(0);
      mocker.clear(GlobalContext.getContext())
    })

    it('conversationListServiceTest_isExistNoticeMessage_success', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext;
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: 0,
              abilityResult: [{} as LooseObject]
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve());
          }
        } as Object | window.WindowStage);
      let res: boolean = await mConversationListSe.isExistNoticeMessage(context);
      expect(res).assertFalse();
      mocker.clear(GlobalContext.getContext())
    })

    it('conversationListServiceTest_isExistNoticeMessage_fail', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext;
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: -1,
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve());
          }
        } as Object | window.WindowStage);
      let res: boolean = await mConversationListSe.isExistNoticeMessage(context);
      expect(res).assertFalse();
      mocker.clear(GlobalContext.getContext())
    })

    it('conversationListServiceTest_querySessionList_total_1', 0, async () => {
      let actionData: LooseObject = {
        "rcsType": 1,
        "rcsId": 1,
        "isMms": false
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext;
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: 0,
              abilityResult: []
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve());
          }
        } as Object | window.WindowStage);
      when(mocker.mockFunc(mConversationListSe, mConversationListSe.getSessionListResult))(actionData)
        .afterReturn({});
      when(mocker.mockFunc(mConversationListSe, mConversationListSe.getSessionListSize))(actionData)
        .afterReturn({});
      when(mocker.mockFunc(mConversationListSe, mConversationListSe.isExistNoticeMessage))(actionData)
        .afterReturn({});
      when(mocker.mockFunc(Promise, Promise.all))(ArgumentMatchers.any)
        .afterReturn(new Promise<LooseObject>(resolve => resolve({
          0: {
            messageList: [],
            telephones: ['6666']
          },
          1: 1,
          2: true
        })));
      mConversationListSe.querySessionList(actionData, (res: LooseObject) => {
        expect(res.code).assertEqual(0);
      }, context);
      mocker.clear(GlobalContext.getContext());
      mocker.clear(mConversationListSe);
      mocker.clear(Promise);
    })

    it('conversationListServiceTest_querySessionList_total_0', 0, async () => {
      let actionData: LooseObject = {
        "rcsType": 1,
        "rcsId": 1,
        "isMms": false
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext;
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: 0,
              abilityResult: []
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve());
          }
        } as Object | window.WindowStage);
      when(mocker.mockFunc(mConversationListSe, mConversationListSe.getSessionListResult))(actionData)
        .afterReturn({});
      when(mocker.mockFunc(mConversationListSe, mConversationListSe.getSessionListSize))(actionData)
        .afterReturn({});
      when(mocker.mockFunc(mConversationListSe, mConversationListSe.isExistNoticeMessage))(actionData)
        .afterReturn({});
      when(mocker.mockFunc(Promise, Promise.all))(ArgumentMatchers.any)
        .afterReturn(new Promise<LooseObject>(resolve => resolve({
          0: {
            messageList: [],
            telephones: ['6666']
          },
          1: 0,
          2: true
        })));
      mConversationListSe.querySessionList(actionData, (res: LooseObject) => {
        expect(res.code).assertEqual(0);
      }, context);
      mocker.clear(GlobalContext.getContext());
      mocker.clear(mConversationListSe);
      mocker.clear(Promise);
    })

    it('conversationListServiceTest_querySessionList_catch', 0, async () => {
      let actionData: LooseObject = {
        "rcsType": 1,
        "rcsId": 1,
        "isMms": false
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext;
      when(mocker.mockFunc(mConversationListSe, mConversationListSe.getSessionListResult))(actionData)
        .afterReturn({});
      when(mocker.mockFunc(mConversationListSe, mConversationListSe.getSessionListSize))(actionData)
        .afterReturn({});
      when(mocker.mockFunc(mConversationListSe, mConversationListSe.isExistNoticeMessage))(actionData)
        .afterReturn({});
      when(mocker.mockFunc(Promise, Promise.all))(ArgumentMatchers.any)
        .afterReturn(new Promise<LooseObject>((resolve: (value: LooseObject | PromiseLike<LooseObject>) => void,
          reject: (reason: BusinessError) => void) => reject({
          code: -1
        } as BusinessError)));
      mConversationListSe.querySessionList(actionData, (res: LooseObject) => {
        expect(res.code).assertEqual(-1);
      }, context);
      mocker.clear(Promise);
      mocker.clear(mConversationListSe);
    })

    it('conversationListServiceTest_dealContactsName_telephones_length_0', 0, async () => {
      let actionData: LooseObject = {
        "rcsType": 1,
        "rcsId": 1,
        "isMms": false
      };
      let sessionLists: LooseObject[] = [];
      let context = DTGlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext;
      mConversationListSe.dealContactsName([], actionData, sessionLists, (res: LooseObject) => {
        expect(JSON.stringify(res)).assertEqual('[]');
      }, context);
    })

    it('conversationListServiceTest_dealContactsName_buildSessionNames_empty', 0, async () => {
      let actionData: LooseObject = {
        "rcsType": 1,
        "rcsId": 1,
        "isMms": false
      };
      let sessionLists: LooseObject[] = [];
      let context = DTGlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext;
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: 0,
              abilityResult: []
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve());
          }
        } as Object | window.WindowStage);
      mConversationListSe.dealContactsName(['570977632'], actionData, sessionLists, (res: LooseObject[]) => {
        expect(res.length).assertEqual(0);
      }, context);
      mocker.clear(GlobalContext.getContext());
    })

    it('conversationListServiceTest_dealContactsName_buildSessionNames_notEmpty', 0, async () => {
      let actionData: LooseObject = {
        "rcsType": 1,
        "rcsId": 1,
        "isMms": false
      };
      let sessionLists: LooseObject[] = [{}];
      let context = DTGlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext;
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: 0,
              abilityResult: [{
                id: '1',
                rawContactId: '1',
                displayName: 'name',
                detailInfo: '570977632'
              } as LooseObject]
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve());
          }
        } as Object | window.WindowStage);
      mConversationListSe.dealContactsName(['570977632'], actionData, sessionLists, (res: LooseObject[]) => {
        expect(res.length).assertEqual(0);
      }, context);
      mocker.clear(GlobalContext.getContext());
    })

    it('conversationListServiceTest_dealYellowPageNameSecond_telephones_length_0', 0, async () => {
      let actionData: LooseObject = {
        "rcsType": 1,
        "rcsId": 1,
        "isMms": false
      };
      let sessionLists: LooseObject[] = [];
      let context = DTGlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext;
      mConversationListSe.dealYellowPageNameSecond([], actionData, sessionLists, (res: LooseObject) => {
        expect(JSON.stringify(res)).assertEqual('[]');
      }, context);
    })

    it('conversationListServiceTest_dealYellowPageNameSecond_buildSessionNames_empty', 0, async () => {
      let actionData: LooseObject = {
        "rcsType": 1,
        "rcsId": 1,
        "isMms": false
      };
      let sessionLists: LooseObject[] = [];
      let context = DTGlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext;
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: 0,
              abilityResult: []
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve());
          }
        } as Object | window.WindowStage);
      mConversationListSe.dealYellowPageNameSecond(['570977632'], actionData, sessionLists, (res: LooseObject[]) => {
        expect(res.length).assertEqual(0);
      }, context);
      mocker.clear(GlobalContext.getContext());
    })

    it('conversationListServiceTest_dealYellowPageNameSecond_buildSessionNames_notEmpty', 0, async () => {
      let actionData: LooseObject = {
        "rcsType": 1,
        "rcsId": 1,
        "isMms": false
      };
      let sessionLists: LooseObject[] = [{}];
      let context = DTGlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext;
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: 0,
              abilityResult: [{
                id: '1',
                photo: '',
                name: '',
                number: '570977632'
              } as LooseObject]
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve());
          }
        } as Object | window.WindowStage);
      mConversationListSe.dealYellowPageNameSecond(['570977632'], actionData, sessionLists, (res: LooseObject[]) => {
        expect(res.length).assertEqual(1);
      }, context);
      mocker.clear(GlobalContext.getContext());
    })

    it('conversationListServiceTest_statisticalData_success', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext;
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: 0,
              abilityResult: {
                totalListCount: 1,
                unreadCount: 0,
                unreadInfo: 0,
                unreadTotalOfInfo: 0,
              } as LooseObject
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve());
          }
        } as Object | window.WindowStage);
      mConversationListSe.statisticalData((res: LooseObject) => {
        expect(res.code).assertEqual(0);
      }, context);
      mocker.clear(GlobalContext.getContext());
    })

    it('conversationListServiceTest_statisticalData_fail', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext;
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: -1,
              abilityResult: {} as LooseObject
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve());
          }
        } as Object | window.WindowStage);
      mConversationListSe.statisticalData((res: LooseObject) => {
        expect(res.code).assertEqual(-1);
      }, context);
      mocker.clear(GlobalContext.getContext());
    })

    it('conversationListServiceTest_deleteMessageById', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext;
      let res = false;
      mocker.mockFunc(mConversationListSe, mConversationListSe.deleteSessionByConditionPagination);
      when(mocker.mockFunc(ConversationService.getInstance(),
        ConversationService.getInstance().deleteSmsMmsInfoPagination))
      (ArgumentMatchers.any).afterAction(() => {
        res = true
      });
      mConversationListSe.deleteMessageById({
        threadIds: [0]
      } as LooseObject, () => {
      }, context);
      expect(res).assertTrue();
      mocker.clear(mConversationListSe);
      mocker.clear(ConversationService.getInstance());
    })

    it('conversationListServiceTest_markAllToRead_threadIds', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext;
      let actionData: LooseObject = {
        threadId: null,
        threadIds: ['1'],
        unreadCount_greaterThan: 0,
        markReadType: 1
      };
      mConversationListSe.markAllToRead(context, actionData, (res: LooseObject) => {
      });
      expect(actionData.unreadCount_greaterThan).assertEqual(0);
    })

    it('conversationListServiceTest_markAllToRead', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext;
      let actionData: LooseObject = {
        threadId: null,
        threadIds: null,
        unreadCount_greaterThan: 0,
        markReadType: 1
      };
      mConversationListSe.markAllToRead(context, actionData, (res: LooseObject) => {
      });
      expect(actionData.unreadCount_greaterThan).assertEqual(0);
    })


    it('conversationListServiceTest_insertSessionDraft_success_responseId_minus1', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext;
      let actionData: LooseObject = {
        selectContacts: [{
          telephone: '570977632',
          telephoneFormat: '570977632',
          contactName: 'name',
          rawContactId: '1',
        }, {
          telephone: '570977633',
          telephoneFormat: '570977633',
          contactName: 'name1',
          rawContactId: '2',
        }],
        threadId: 1,
        isDraft: true,
        isNewMsg: true
      };
      when(mocker.mockFunc(mConversationListSe, mConversationListSe.dealSendResults))(ArgumentMatchers.any)
        .afterReturn({
          telephone: '570977632,570977633'
        } as LooseObject);
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: 0,
              abilityResult: [{
                id: -1,
              } as ResponseType]
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve());
          }
        } as Object | window.WindowStage);
      mocker.mockFunc(mConversationListSe, mConversationListSe.deleteSessionByCondition);
      let res = false;
      when(mocker.mockFunc(mConversationListSe, mConversationListSe.dealInsertSession))(ArgumentMatchers.any)
        .afterAction(() => {
          res = true;
        });
      mConversationListSe.insertSessionDraft(actionData, (res: LooseObject) => {
      }, context);
      expect(res).assertTrue();
      mocker.clear(mConversationListSe);
      mocker.clear(GlobalContext.getContext());
    })

    it('conversationListServiceTest_insertSessionDraft_success_responseId_minus1_isDraft_false', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext;
      let actionData: LooseObject = {
        selectContacts: [{
          telephone: '570977632',
          telephoneFormat: '570977632',
          contactName: 'name',
          rawContactId: '1',
        }, {
          telephone: '570977633',
          telephoneFormat: '570977633',
          contactName: 'name1',
          rawContactId: '2',
        }],
        threadId: 1,
        isDraft: false,
        isNewMsg: true
      };
      when(mocker.mockFunc(mConversationListSe, mConversationListSe.dealSendResults))(ArgumentMatchers.any)
        .afterReturn({
          telephone: '570977632,570977633'
        } as LooseObject);
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: 0,
              abilityResult: [{
                id: -1,
              } as ResponseType]
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve());
          }
        } as Object | window.WindowStage);
      mocker.mockFunc(mConversationListSe, mConversationListSe.deleteSessionByCondition);
      let res = false;
      when(mocker.mockFunc(mConversationListSe, mConversationListSe.dealInsertSession))(ArgumentMatchers.any)
        .afterAction(() => {
          res = true;
        });
      mConversationListSe.insertSessionDraft(actionData, (res: LooseObject) => {
      }, context);
      expect(res).assertTrue();
      mocker.clear(mConversationListSe);
      mocker.clear(GlobalContext.getContext());
    })

    it('conversationListServiceTest_insertSessionDraft_success_responseId_2_isNewMsg_false', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext;
      let actionData: LooseObject = {
        selectContacts: [{
          telephone: '570977632',
          telephoneFormat: '570977632',
          contactName: 'name',
          rawContactId: '1',
        }, {
          telephone: '570977633',
          telephoneFormat: '570977633',
          contactName: 'name1',
          rawContactId: '2',
        }],
        threadId: 1,
        isDraft: false,
        isNewMsg: false,
        sendResults: [{}],
        mmsSource: [],
        start_time: '',
        type: 0,
        isReceive: false,
        endTime: '',
        expiresTime: '',
        isMms: null,
        isSender: null,
        hasReport: null,
        isAdvancedSecurity: null,
        isBlocked: null,
        blockedReason: null,
        blockedSources: null,
        blockedType: null,
        blockedTypeText: null
      };
      when(mocker.mockFunc(mConversationListSe, mConversationListSe.dealSendResults))(ArgumentMatchers.any)
        .afterReturn({
          telephone: '570977632,570977633'
        } as LooseObject);
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: 0,
              abilityResult: [{
                id: 2,
              } as ResponseType]
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve());
          }
        } as Object | window.WindowStage);
      mocker.mockFunc(mConversationListSe, mConversationListSe.deleteSessionByCondition);
      let res = false;
      when(mocker.mockFunc(mConversationListSe, mConversationListSe.dealInsertSession))(ArgumentMatchers.any)
        .afterAction(() => {
          res = true;
        });
      mConversationListSe.insertSessionDraft(actionData, (res: LooseObject) => {
      }, context);
      expect(res).assertFalse();
      mocker.clear(mConversationListSe);
      mocker.clear(GlobalContext.getContext());
    })

    it('conversationListServiceTest_insertSessionDraft_success_responseId_2_isNewMsg_true', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext;
      let actionData: LooseObject = {
        selectContacts: [],
        threadId: 1,
        isDraft: false,
        isNewMsg: true,
        sendResults: [{}],
        mmsSource: [],
        start_time: '',
        type: 0,
        isReceive: false,
        endTime: '',
        expiresTime: '',
        isMms: null,
        isSender: null,
        hasReport: null,
        isAdvancedSecurity: null,
        isBlocked: null,
        blockedReason: null,
        blockedSources: null,
        blockedType: null,
        blockedTypeText: null
      };
      when(mocker.mockFunc(mConversationListSe, mConversationListSe.dealSendResults))(ArgumentMatchers.any)
        .afterReturn({
          telephone: '570977632,570977633'
        } as LooseObject);
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: 0,
              abilityResult: [{
                id: 2,
              } as ResponseType]
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve());
          }
        } as Object | window.WindowStage);
      mocker.mockFunc(mConversationListSe, mConversationListSe.deleteSessionByCondition);
      let res = false;
      when(mocker.mockFunc(mConversationListSe, mConversationListSe.dealInsertSession))(ArgumentMatchers.any)
        .afterAction(() => {
          res = true;
        });
      mConversationListSe.insertSessionDraft(actionData, (res: LooseObject) => {
      }, context);
      expect(res).assertFalse();
      mocker.clear(mConversationListSe);
      mocker.clear(GlobalContext.getContext());
    })

    it('conversationListServiceTest_insertSessionDraft_fail', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext;
      let actionData: LooseObject = {
        selectContacts: [{
          telephone: '570977632',
          telephoneFormat: '570977632',
          contactName: '',
          rawContactId: '1',
        }, {
          telephone: '570977633',
          telephoneFormat: '570977633',
          contactName: 'name1',
          rawContactId: '2',
        }],
        threadId: 1,
        isDraft: false,
        isNewMsg: true
      };
      let res = false;
      when(mocker.mockFunc(mConversationListSe, mConversationListSe.dealSendResults))(ArgumentMatchers.any)
        .afterAction(() => {
          res = true;
          return {
            telephone: null
          } as LooseObject
        });
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: -1,
              abilityResult: []
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve());
          }
        } as Object | window.WindowStage);
      mConversationListSe.insertSessionDraft(actionData, (res: LooseObject) => {
      }, context);
      expect(res).assertTrue();
      mocker.clear(mConversationListSe);
      mocker.clear(GlobalContext.getContext());
    })

    it('conversationListServiceTest_dealInsertSession_rawContactId_notNull', 0, async () => {
      let param: LooseObject = {
        telephone: '',
        content: '',
        contactsNum: [],
        smsType: 0,
        timestamp: '',
        hasMms: true,
        hasAttachment: true,
      };
      let actionData: LooseObject = {
        selectContacts: [{
          rawContactId: 0,
          contactName: 'name'
        }]
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext;
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: 0,
              abilityResult: 1
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve());
          }
        } as Object | window.WindowStage);
      let res = false;
      when(mocker.mockFunc(ConversationService.getInstance(),
        ConversationService.getInstance().dealInsertMessageDetail))
      (ArgumentMatchers.any).afterAction(() => {
        res = true;
      });
      mConversationListSe.dealInsertSession(param, actionData, (res: LooseObject) => {
      }, context);
      expect(res).assertTrue();
      mocker.clear(GlobalContext.getContext());
      mocker.clear(ConversationService.getInstance());
    })

    it('conversationListServiceTest_dealInsertSession_rawContactId_null', 0, async () => {
      let param: LooseObject = {
        telephone: '',
        content: '',
        contactsNum: [],
        smsType: 0,
        timestamp: '',
        hasMms: true,
        hasAttachment: true,
      };
      let actionData: LooseObject = {
        selectContacts: [{
          rawContactId: null,
          contactName: null
        }]
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext;
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: 0,
              abilityResult: 1
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve());
          }
        } as Object | window.WindowStage);
      let res = false;
      when(mocker.mockFunc(ConversationService.getInstance(),
        ConversationService.getInstance().dealInsertMessageDetail))
      (ArgumentMatchers.any).afterAction(() => {
        res = true;
      });
      mConversationListSe.dealInsertSession(param, actionData, (res: LooseObject) => {
      }, context);
      expect(res).assertTrue();
      mocker.clear(GlobalContext.getContext());
      mocker.clear(ConversationService.getInstance());
    })

    it('conversationListServiceTest_dealInsertSession_selectContacts_null', 0, async () => {
      let param: LooseObject = {
        telephone: '',
        content: '',
        contactsNum: [],
        smsType: 0,
        timestamp: '',
        hasMms: true,
        hasAttachment: true,
      };
      let actionData: LooseObject = {
        selectContacts: null
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext;
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: 0,
              abilityResult: 1
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve());
          }
        } as Object | window.WindowStage);
      let res = false;
      when(mocker.mockFunc(ConversationService.getInstance(),
        ConversationService.getInstance().dealInsertMessageDetail))
      (ArgumentMatchers.any).afterAction(() => {
        res = true;
      });
      mConversationListSe.dealInsertSession(param, actionData, (res: LooseObject) => {
      }, context);
      expect(res).assertTrue();
      mocker.clear(GlobalContext.getContext());
      mocker.clear(ConversationService.getInstance());
    })

    it('conversationListServiceTest_deleteDraftDataOrUpdate_groupId_1', 0, () => {
      let actionData: LooseObject = {
        groupId: 1,
        content: 'xx',
        mmsSource: []
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext;
      mocker.mockFunc(ConversationService.getInstance(), ConversationService.getInstance().deleteSmsMmsInfoByCondition);
      let res = false;
      when(mocker.mockFunc(mConversationListSe, mConversationListSe.updateDraftData))(ArgumentMatchers.any)
        .afterAction(() => {
          res = true;
        });
      mConversationListSe.deleteDraftDataOrUpdate(actionData, {} as ResponseType, {}, () => {
      }, context);
      expect(res).assertTrue();
      mocker.clear(mConversationListSe);
      mocker.clear(ConversationService.getInstance());
    })

    it('conversationListServiceTest_deleteDraftDataOrUpdate_groupId_0_content_empty', 0, () => {
      let actionData: LooseObject = {
        groupId: 0,
        content: '',
        mmsSource: [{} as Mms]
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext;
      mocker.mockFunc(ConversationService.getInstance(), ConversationService.getInstance().deleteSmsMmsInfoByCondition);
      let res = false;
      when(mocker.mockFunc(mConversationListSe, mConversationListSe.updateDraftData))(ArgumentMatchers.any)
        .afterAction(() => {
          res = true;
        });
      mConversationListSe.deleteDraftDataOrUpdate(actionData, {} as ResponseType, {}, () => {
      }, context);
      expect(res).assertTrue();
      mocker.clear(mConversationListSe);
      mocker.clear(ConversationService.getInstance());
    })

    it('conversationListServiceTest_deleteDraftDataOrUpdate_callback', 0, () => {
      let actionData: LooseObject = {
        groupId: 0,
        content: '',
        mmsSource: []
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext;
      mocker.mockFunc(ConversationService.getInstance(), ConversationService.getInstance().deleteSmsMmsInfoByCondition);
      let res = false;
      when(mocker.mockFunc(mConversationListSe, mConversationListSe.updateDraftData))(ArgumentMatchers.any)
        .afterAction(() => {
          res = true;
        });
      mConversationListSe.deleteDraftDataOrUpdate(actionData, {} as ResponseType, {}, () => {
      }, context);
      expect(res).assertFalse();
      mocker.clear(mConversationListSe);
      mocker.clear(ConversationService.getInstance());
    })

    it('conversationListServiceTest_updateDraftData', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext;
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: 0,
              abilityResult: {
                totalListCount: 1,
                unreadCount: 0,
                unreadInfo: 0,
                unreadTotalOfInfo: 0,
              } as LooseObject
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve());
          }
        } as Object | window.WindowStage);
      let conversationService: ConversationService = ConversationService.getTestInstance();
      when(mocker.mockFunc(ConversationService, ConversationService.getInstance))(ArgumentMatchers.any)
        .afterReturn(conversationService);
      mocker.mockFunc(conversationService, conversationService.deleteSmsMmsInfoByCondition);
      let res = false;
      when(mocker.mockFunc(conversationService, conversationService.insertMmsInfoList))(ArgumentMatchers.any)
        .afterAction(() => {
          expect(res).assertTrue();
        });
      mConversationListSe.updateDraftData({
        id: 1
      } as ResponseType, {
        content: '',
        hasAttachment: true,
        hasMms: true,
        telephone: '570977632',
      }, {
        sendResults: [{}],
        mmsSource: [],
        start_time: '',
        type: 0,
        isReceive: false,
        endTime: '',
        expiresTime: '',
        isMms: null,
        isSender: null,
        hasReport: null,
        isAdvancedSecurity: null,
        isBlocked: null,
        blockedReason: null,
        blockedSources: null,
        blockedType: null,
        blockedTypeText: null
      }, () => {
        res = true;
      }, context);
      mocker.clear(GlobalContext.getContext());
      mocker.clear(conversationService);
      mocker.clear(ConversationService);
    })

    it('conversationListServiceTest_dealSendResults', 0, async () => {
      when(mocker.mockFunc(TelephoneUtil, TelephoneUtil.dealTelephoneSort))(ArgumentMatchers.any)
        .afterReturn('666666');
      let res: LooseObject = mConversationListSe.dealSendResults({
        isNewMsg: true,
        selectContacts: [{
          telephone: '66666'
        }, {
          telephone: '66667'
        }],
        receiveContactValue: '6666666',
        telephone: '',
        content: '',
        sendResults: [],
        isMms: true,
        hasAttachment: true
      });
      expect(res.hasMms).assertEqual(1);
      mocker.clear(TelephoneUtil);
    })

    it('conversationListServiceTest_dealSendResults_hasMms_false', 0, async () => {
      when(mocker.mockFunc(TelephoneUtil, TelephoneUtil.dealTelephoneSort))(ArgumentMatchers.any)
        .afterReturn('666666');
      when(mocker.mockFunc(TelephoneUtil, TelephoneUtil.judgeIsInfoMsg))(ArgumentMatchers.any)
        .afterReturn(true);
      let res: LooseObject = mConversationListSe.dealSendResults({
        isNewMsg: true,
        selectContacts: [{
          telephone: '66666'
        }],
        receiveContactValue: '',
        telephone: '',
        content: '',
        sendResults: [],
        isMms: false,
        hasAttachment: false
      });
      expect(res.hasMms).assertEqual(0);
      mocker.clear(TelephoneUtil);
    })

    it('conversationListServiceTest_dealSendResults_isNewMsg_false', 0, async () => {
      when(mocker.mockFunc(TelephoneUtil, TelephoneUtil.dealTelephoneSort))(ArgumentMatchers.any)
        .afterReturn('666666');
      let res: LooseObject = mConversationListSe.dealSendResults({
        isNewMsg: false,
        selectContacts: [],
        receiveContactValue: '',
        telephone: '',
        content: '',
        sendResults: [],
        isMms: false,
        hasAttachment: false
      });
      expect(res.hasMms).assertEqual(0);
      mocker.clear(TelephoneUtil);
    })

    it('conversationListServiceTest_querySessionByTelephone_success', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext;
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: 0,
              abilityResult: [{} as ResponseType]
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve());
          }
        } as Object | window.WindowStage);
      mConversationListSe.querySessionByTelephone('570977632', (res: LooseObject) => {
        expect(res.code).assertEqual(0);
      }, context);
      mocker.clear(GlobalContext.getContext());
    })

    it('conversationListServiceTest_querySessionByTelephone_fail', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext;
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: -1,
              abilityResult: []
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve());
          }
        } as Object | window.WindowStage);
      mConversationListSe.querySessionByTelephone('570977632', (res: LooseObject) => {
        expect(res.code).assertEqual(-1);
      }, context);
      mocker.clear(GlobalContext.getContext());
    })

    it('conversationListServiceTest_updateLastItemContent_rcsType_0', 0, async () => {
      let context = {
        resourceManager: {
          getStringSync: (resource: Resource, ...args: (string | number)[]): string => ''
        } as resourceManager.ResourceManager
      } as Context;
      let res = false;
      when(mocker.mockFunc(mConversationListSe, mConversationListSe.updateSessionByCondition))(ArgumentMatchers.any)
        .afterAction(() => {
          res = true;
        })
      mConversationListSe.updateLastItemContent({
        mmsList: [{
          idRcs: true,
          timeMillisecond: '',
          sendStatus: 0,
          isMsm: true,
          content: '',
          rcsType: 0
        } as LooseObject],
        threadId: 0
      }, (res: LooseObject) => {
      }, context);
      expect(res).assertTrue();
      mocker.clear(mConversationListSe);
    })

    it('conversationListServiceTest_updateLastItemContent_mmsSource_length0', 0, async () => {
      let context = {
        resourceManager: {
          getStringSync: (resource: Resource, ...args: (string | number)[]): string => ''
        } as resourceManager.ResourceManager
      } as Context;
      let res = false;
      when(mocker.mockFunc(mConversationListSe, mConversationListSe.updateSessionByCondition))(ArgumentMatchers.any)
        .afterAction(() => {
          res = true;
        })
      mConversationListSe.updateLastItemContent({
        mmsList: [{
          idRcs: true,
          timeMillisecond: '',
          sendStatus: 0,
          isMsm: true,
          content: '',
          rcsType: 1,
          mmsSource: []
        } as LooseObject],
        threadId: 0
      }, (res: LooseObject) => {
      }, context);
      expect(res).assertTrue();
      mocker.clear(mConversationListSe);
    })

    it('conversationListServiceTest_updateLastItemContent_mmsSource_length0_type_0', 0, async () => {
      let context = {
        resourceManager: {
          getStringSync: (resource: Resource, ...args: (string | number)[]): string => ''
        } as resourceManager.ResourceManager
      } as Context;
      let res = false;
      when(mocker.mockFunc(mConversationListSe, mConversationListSe.updateSessionByCondition))(ArgumentMatchers.any)
        .afterAction(() => {
          res = true;
        })
      mConversationListSe.updateLastItemContent({
        mmsList: [{
          idRcs: true,
          timeMillisecond: '',
          sendStatus: 0,
          isMsm: true,
          content: '',
          rcsType: 1,
          mmsSource: [{
            type: 0
          } as Mms]
        } as LooseObject],
        threadId: 0
      }, (res: LooseObject) => {
      }, context);
      expect(res).assertTrue();
      mocker.clear(mConversationListSe);
    })

    it('conversationListServiceTest_updateLastItemContent_mmsSource_length0_type_3', 0, async () => {
      let context = {
        resourceManager: {
          getStringSync: (resource: Resource, ...args: (string | number)[]): string => ''
        } as resourceManager.ResourceManager
      } as Context;
      let res = false;
      when(mocker.mockFunc(mConversationListSe, mConversationListSe.updateSessionByCondition))(ArgumentMatchers.any)
        .afterAction(() => {
          res = true;
        })
      mConversationListSe.updateLastItemContent({
        mmsList: [{
          idRcs: true,
          timeMillisecond: '',
          sendStatus: 0,
          isMsm: true,
          content: '',
          rcsType: 1,
          mmsSource: [{
            type: 3
          } as Mms]
        } as LooseObject],
        threadId: 0
      }, (res: LooseObject) => {
      }, context);
      expect(res).assertTrue();
      mocker.clear(mConversationListSe);
    })

    it('conversationListServiceTest_updateLastItemContent_mmsSource_length0_type_9', 0, async () => {
      let context = {
        resourceManager: {
          getStringSync: (resource: Resource, ...args: (string | number)[]): string => ''
        } as resourceManager.ResourceManager
      } as Context;
      let res = false;
      when(mocker.mockFunc(mConversationListSe, mConversationListSe.updateSessionByCondition))(ArgumentMatchers.any)
        .afterAction(() => {
          res = true;
        })
      mConversationListSe.updateLastItemContent({
        mmsList: [{
          idRcs: true,
          timeMillisecond: '',
          sendStatus: 0,
          isMsm: true,
          content: '',
          rcsType: 1,
          mmsSource: [{
            type: 9
          } as Mms]
        } as LooseObject],
        threadId: 0
      }, (res: LooseObject) => {
      }, context);
      expect(res).assertTrue();
      mocker.clear(mConversationListSe);
    })

    it('conversationListServiceTest_updateLastItemContent_mmsSource_length0_type_1', 0, async () => {
      let context = {
        resourceManager: {
          getStringSync: (resource: Resource, ...args: (string | number)[]): string => ''
        } as resourceManager.ResourceManager
      } as Context;
      let res = false;
      when(mocker.mockFunc(mConversationListSe, mConversationListSe.updateSessionByCondition))(ArgumentMatchers.any)
        .afterAction(() => {
          res = true;
        })
      mConversationListSe.updateLastItemContent({
        mmsList: [{
          idRcs: true,
          timeMillisecond: '',
          sendStatus: 0,
          isMsm: true,
          content: '',
          rcsType: 1,
          mmsSource: [{
            type: 1
          } as Mms]
        } as LooseObject],
        threadId: 0
      }, (res: LooseObject) => {
      }, context);
      expect(res).assertTrue();
      mocker.clear(mConversationListSe);
    })

    it('conversationListServiceTest_updateLastItemContent_mmsSource_length0_type_4', 0, async () => {
      let context = {
        resourceManager: {
          getStringSync: (resource: Resource, ...args: (string | number)[]): string => ''
        } as resourceManager.ResourceManager
      } as Context;
      let res = false;
      when(mocker.mockFunc(mConversationListSe, mConversationListSe.updateSessionByCondition))(ArgumentMatchers.any)
        .afterAction(() => {
          res = true;
        })
      mConversationListSe.updateLastItemContent({
        mmsList: [{
          idRcs: true,
          timeMillisecond: '',
          sendStatus: 0,
          isMsm: true,
          content: '',
          rcsType: 1,
          mmsSource: [{
            type: 4
          } as Mms]
        } as LooseObject],
        threadId: 0
      }, (res: LooseObject) => {
      }, context);
      expect(res).assertTrue();
      mocker.clear(mConversationListSe);
    })

    it('conversationListServiceTest_updateLastItemContent_mmsSource_length0_type_7', 0, async () => {
      let context = {
        resourceManager: {
          getStringSync: (resource: Resource, ...args: (string | number)[]): string => ''
        } as resourceManager.ResourceManager
      } as Context;
      let res = false;
      when(mocker.mockFunc(mConversationListSe, mConversationListSe.updateSessionByCondition))(ArgumentMatchers.any)
        .afterAction(() => {
          res = true;
        })
      mConversationListSe.updateLastItemContent({
        mmsList: [{
          idRcs: true,
          timeMillisecond: '',
          sendStatus: 0,
          isMsm: true,
          content: '',
          rcsType: 1,
          mmsSource: [{
            type: 10,
            address: new AddressInfo(0, 0, 'name', 'address')
          } as Mms]
        } as LooseObject],
        threadId: 0
      }, (res: LooseObject) => {
      }, context);
      expect(res).assertTrue();
      mocker.clear(mConversationListSe);
    })

    it('conversationListServiceTest_querySessionLikeTelephone', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext;
      let conversationInfo: ConversationListInfo =
        new ConversationListInfo(1, 0, '570977632', 'content', 0, 0, 0, 0, 0, 0, 0, '1', 'name',
          0, '570977632', '');
      conversationInfo.smsType = 0;
      conversationInfo.sendStatus = 1;
      conversationInfo.hasDraft = 1;
      conversationInfo.hasMms = 1;
      conversationInfo.contactsNum = 2;
      conversationInfo.telephone = '570988763,560977333';
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: 0,
              abilityResult: [conversationInfo]
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve());
          }
        } as Object | window.WindowStage);
      let res = false;
      when(mocker.mockFunc(mConversationListSe, mConversationListSe.updateSessionByCondition))(ArgumentMatchers.any)
        .afterAction(() => {
          res = true;
        })
      mConversationListSe.querySessionLikeTelephone({
        smsType: 1
      }, (res: LooseObject) => {
        expect(res.code).assertEqual(0);
      }, context);
      mocker.clear(GlobalContext.getContext());
      mocker.clear(mConversationListSe);
    })

    it('conversationListServiceTest_querySessionLikeTelephone1', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext;
      let conversationInfo: ConversationListInfo =
        new ConversationListInfo(1, 0, '570977632', 'content', 0, 0, 0, 0, 0, 0, 0, '1', 'name',
          0, '570977632', '');
      conversationInfo.smsType = 1;
      conversationInfo.sendStatus = 2;
      conversationInfo.hasDraft = 2;
      conversationInfo.hasMms = 2;
      conversationInfo.contactsNum = 1;
      conversationInfo.telephone = '570988763';
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: 0,
              abilityResult: [conversationInfo]
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve());
          }
        } as Object | window.WindowStage);
      let res = false;
      when(mocker.mockFunc(mConversationListSe, mConversationListSe.updateSessionByCondition))(ArgumentMatchers.any)
        .afterAction(() => {
          res = true;
        })
      mConversationListSe.querySessionLikeTelephone({
        smsType: 1
      }, (res: LooseObject) => {
        expect(res.code).assertEqual(0);
      }, context);
      mocker.clear(GlobalContext.getContext());
      mocker.clear(mConversationListSe);
    })

    it('conversationListServiceTest_querySessionLikeTelephone2', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext;
      let conversationInfo: ConversationListInfo =
        new ConversationListInfo(1, 0, '570977632', 'content', 0, 0, 0, 0, 0, 0, 0, '1', 'name',
          0, '570977632', '');
      conversationInfo.smsType = 1;
      conversationInfo.sendStatus = 2;
      conversationInfo.hasDraft = 2;
      conversationInfo.hasMms = 2;
      conversationInfo.contactsNum = 1;
      conversationInfo.telephone = '570988763';
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: 0,
              abilityResult: null
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve());
          }
        } as Object | window.WindowStage);
      let res = false;
      when(mocker.mockFunc(mConversationListSe, mConversationListSe.updateSessionByCondition))(ArgumentMatchers.any)
        .afterAction(() => {
          res = true;
        })
      mConversationListSe.querySessionLikeTelephone({
        smsType: 1
      }, (res: LooseObject) => {
        expect(res.code).assertEqual(0);
      }, context);
      mocker.clear(GlobalContext.getContext());
      mocker.clear(mConversationListSe);
    })

    it('conversationListServiceTest_querySessionLikeTelephone_fail', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext;
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: -1,
              abilityResult: []
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve());
          }
        } as Object | window.WindowStage);
      mConversationListSe.querySessionLikeTelephone({
        smsType: 1
      }, (res: LooseObject) => {
        expect(res.code).assertEqual(-1);
      }, context);
      mocker.clear(GlobalContext.getContext())
    })

    it('conversationListServiceTest_querySessionByTelephones', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext;
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: -1,
              abilityResult: []
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve());
          }
        } as Object | window.WindowStage);
      mConversationListSe.querySessionByTelephones([{
        detailInfo: '570977632'
      }], {
        smsType: 1
      }, (res: LooseObject) => {
        expect(res.code).assertEqual(-1);
      }, context);
      mocker.clear(GlobalContext.getContext())
    })

    it('conversationListServiceTest_querySessionByTelephones1', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext;
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: -1,
              abilityResult: []
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve());
          }
        } as Object | window.WindowStage);
      mConversationListSe.querySessionByTelephones([{
        detailInfo: '570977632'
      }], {
        smsType: 0
      }, (res: LooseObject) => {
        expect(res.code).assertEqual(-1);
      }, context);
      mocker.clear(GlobalContext.getContext())
    })


    it('conversationListServiceTest_updateSessionUnReadBySessionId', 0, () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext;
      let callback: Function = (res: LooseObject) => {
        expect(res.code).assertEqual(0);
      };
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: 0
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve());
          }
        } as Object | window.WindowStage);
      let valueBucket: Record<string, number> = {
        'unread_count': 0
      }
      mConversationListSe.updateSessionUnReadBySessionId({}, valueBucket, callback, context);
      mocker.clear(GlobalContext.getContext());
    })

    it('conversationListServiceTest_updateSessionUnReadBySessionId_else', 0, () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext;
      let callback: Function = (res: LooseObject) => {
        expect(res.code).assertEqual(-1);
      };
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn(null);
      when(mocker.mockFunc(DataShareHelper.getInstance(),
        DataShareHelper.getInstance().initContactDB))(ArgumentMatchers.any)
        .afterReturn(new  Promise<dataShare.DataShareHelper | undefined>(resolve => resolve(undefined)));
      let valueBucket: Record<string, number> = {
        'unread_count': 0
      }
      mConversationListSe.updateSessionUnReadBySessionId({}, valueBucket, callback, context);
      mocker.clear(GlobalContext.getContext());
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationListServiceTest_batchUpdateSessionByCondition', 0, () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext;
      let callback: Function = (res: LooseObject) => {
        expect(res.code).assertEqual(0);
      };
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: 0
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve());
          }
        } as Object | window.WindowStage);
      mConversationListSe.batchUpdateSessionByCondition([], [], callback, context);
      mocker.clear(GlobalContext.getContext());
    })

    it('conversationListServiceTest_batchUpdateSessionByCondition_else', 0, () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext;
      let callback: Function = (res: LooseObject) => {
        expect(res.code).assertUndefined();
      };
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn(null);
      when(mocker.mockFunc(DataShareHelper.getInstance(),
        DataShareHelper.getInstance().initContactDB))(ArgumentMatchers.any)
        .afterReturn(new  Promise<dataShare.DataShareHelper | undefined>(resolve => resolve(undefined)));
      mConversationListSe.batchUpdateSessionByCondition([], [], callback, context);
      mocker.clear(GlobalContext.getContext());
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationListServiceTest_batchUpdateSessionByCondition_context_undefined', 0, () => {
      let callback: Function = (res: LooseObject) => {
        expect(res.code).assertUndefined();
      };
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn(null);
      when(mocker.mockFunc(DataShareHelper.getInstance(),
        DataShareHelper.getInstance().initContactDB))(ArgumentMatchers.any)
        .afterReturn(new  Promise<dataShare.DataShareHelper | undefined>(resolve => resolve(undefined)));
      mConversationListSe.batchUpdateSessionByCondition([], [], callback, context);
      mocker.clear(GlobalContext.getContext());
      mocker.clear(DataShareHelper.getInstance());
    })

    it('conversationListServiceTest_updatePinningTime', 0, () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext;
      let callback: Function = (res: LooseObject) => {
        expect(res.code).assertEqual(0);
      };
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn(null);
      when(mocker.mockFunc(DataShareHelper.getInstance(),
        DataShareHelper.getInstance().initContactDB))(ArgumentMatchers.any)
        .afterReturn(new  Promise<dataShare.DataShareHelper | undefined>(resolve => resolve(undefined)));
      mConversationListSe.updateSessionPinningTime(1, 0, callback, context);
      mocker.clear(GlobalContext.getContext());
      mocker.clear(DataShareHelper.getInstance());
    })
  })
}