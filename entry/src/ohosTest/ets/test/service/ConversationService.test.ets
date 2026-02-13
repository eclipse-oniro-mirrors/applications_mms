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
import ConversationService, {
  ExpireQuerySessionCache,
  queryMmsInfoResult
} from "../../../../main/ets/service/ConversationService";
import { resType } from '../../../../main/ets/service/MmsSearchService';
import { DTGlobalContext } from '../../testability/TestAbility';
import myCommon from '@ohos.app.ability.common';
import { dataShare, dataSharePredicates, DataShareResultSet, ValuesBucket } from '@kit.ArkData';
import { GlobalContext } from '../../../../main/ets/MainAbility/GlobalHelper';
import Window from '@ohos.window';
import DataShareHelper from '../../../../main/ets/model/repository/DataShareHelper';
import MySet from '../MySet';
import MmsUtil from '../../../../main/ets/utils/MmsUtil';
import SsmUtils from '../../../../main/ets/utils/SsmUtils';
import TelephoneUtil from '../../../../main/ets/utils/TelephoneUtil';
import ConversationListService, { ResponseType } from '../../../../main/ets/service/ConversationListService';
import { EnhancedInfoTemporaryDataSource } from '../../../../main/ets/model/EnhancedInfoTemporaryDataSource';
import ContactsService from '../../../../main/ets/service/ContactsService';
import { Mms } from '../../../../main/ets/utils/TypesUtils';
import { resourceManager } from '@kit.LocalizationKit';
import HiLog from '../../../../main/ets/utils/HiLog';
import { ConversationRcsInfo } from '../../../../main/ets/model/conversationlist/ConversationRcsInfo';
import { SessionContactInfoForDB } from '../../../../main/ets/pages/conversation/conversationController';
import ConversationModel from '../../../../main/ets/model/ConversationModel';

export default function conversationServiceTest() {
  describe('ConversationServiceTest', () => {

    const TAG: string = 'ConversationService';
    let conversationService: ConversationService;
    let mmsContext = DTGlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext;
    let mocker: MockKit;

    beforeEach(() => {
      conversationService = ConversationService.getTestInstance();
      mocker = new MockKit();
    })

    afterEach(() => {
      mocker.clear(GlobalContext.getContext());
      mocker.clear(DataShareHelper.getInstance());
      mocker.clear(conversationService);
      mocker.clear(ConversationService.getInstance());
      mocker.clear(ConversationListService.getInstance());
      mocker.clear(ContactsService.getInstance());
    })

    it('ConversationService_isNeedWait500MS', 0, () => {
      let expireQuerySessionCache: ExpireQuerySessionCache = new ExpireQuerySessionCache();
      expireQuerySessionCache.isNeedWait500MS('666666');
      setTimeout(() => {
        let res = expireQuerySessionCache.isNeedWait500MS('666666');
        expect(res).assertFalse();
      }, 500);
    })

    it('ConversationService_getInstance', 0, () => {
      expect(typeof conversationService).assertEqual(typeof ConversationService.getInstance());
    })

    it('ConversationService_insertSmsMmsInfo_getObject', 0, () => {
      let valueBucket: ValuesBucket = {};
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
            return new Promise<void>(resolve => resolve())
          }
        } as Object | Window.WindowStage);

      conversationService.insertSmsMmsInfo(valueBucket, callback, mmsContext);
    })

    it('ConversationService_insertSmsMmsInfo_insertSmsMmsInfo', 0, () => {
      let valueBucket: ValuesBucket = {};
      let callback: Function = (res: LooseObject) => {
        expect(res.code).assertEqual(-1);
      };
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn(null);
      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(mmsContext)
        .afterReturn(undefined);

      conversationService.insertSmsMmsInfo(valueBucket, callback, mmsContext);
    })

    it('ConversationService_deleteSmsMmsInfoPagination_if', 0, () => {
      let actionData: LooseObject = {
        threadIds: []
      };
      for (let i = 0; i < 4002; i++) {
        actionData.threadIds.push(i + '');
      }
      mocker.mockFunc(conversationService, conversationService.deleteSmsMmsInfoByThreadId);
      conversationService.deleteSmsMmsInfoPagination(mmsContext, actionData, () => {
      });
      expect(actionData.threadIds.length).assertEqual(2);
    })

    it('ConversationService_deleteSmsMmsInfoPagination_else', 0, () => {
      let actionData: LooseObject = {
        threadIds: []
      };
      mocker.mockFunc(conversationService, conversationService.deleteSmsMmsInfoByThreadId);
      conversationService.deleteSmsMmsInfoPagination(mmsContext, actionData, () => {
      });
      expect(actionData.threadIds.length).assertEqual(0);
    })

    it('ConversationService_deleteSmsMmsInfoByThreadId_threadIds_null', 0, () => {
      let actionData: LooseObject = {
        threadIds: null
      };
      mocker.mockFunc(HiLog, HiLog.i);
      conversationService.deleteSmsMmsInfoByThreadId(mmsContext, actionData, () => {
      });
      mocker.verify('i',
        [TAG, 'deleteSmsMmsInfoByCondition delete thread id is:' + JSON.stringify(actionData.threadIds)]).never();
      mocker.clear(HiLog);
    })

    it('ConversationService_deleteSmsMmsInfoByThreadId_threadIds_length_0', 0, () => {
      let actionData: LooseObject = {
        threadIds: []
      };
      mocker.mockFunc(HiLog, HiLog.i);
      conversationService.deleteSmsMmsInfoByThreadId(mmsContext, actionData, () => {
      });
      mocker.verify('i',
        [TAG, 'deleteSmsMmsInfoByCondition delete thread id is:' + JSON.stringify(actionData.threadIds)]).never();
      mocker.clear(HiLog);
    })

    it('ConversationService_deleteSmsMmsInfoByThreadId_success', 0, () => {
      let actionData: LooseObject = {
        threadIds: ['1'],
        listOfGroupSessionId: [1]
      };
      let conversationRcsInfo: ConversationRcsInfo = new ConversationRcsInfo(1, 1, '666666', '888888', 0,
        '0', 1, 'msgTitle', 'msgContent', 0, 0, 1, 1, 1, '1', 1, 0, '0', '0', 0, 0, 0, 0, ' 0', '0', 0, 0, 0, '0', 0,
        '1');
      let conversationRcsInfo1: ConversationRcsInfo = new ConversationRcsInfo(1, 1, '666666', '888888', 0,
        '0', 2, 'msgTitle', 'msgContent', 0, 0, 1, 1, 1, '1', 1, 0, '0', '0', 0, 0, 0, 0, ' 0', '0', 0, 0, 0, '0', 0,
        '1');
      let conversationRcsInfo2: ConversationRcsInfo = new ConversationRcsInfo(0, 1, '666666', '888888', 0,
        '0', 3, 'msgTitle', 'msgContent', 0, 0, 1, 1, 1, '1', 1, 0, '0', '0', 0, 0, 0, 0, ' 0', '0', 0, 0, 0, '0', 0,
        '1');
      let res = false;
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            res = true
            callBack ? callBack({
              code: 0,
              response: {},
              abilityResult: [conversationRcsInfo, conversationRcsInfo1, conversationRcsInfo2]
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve());
          }
        } as Object | Window.WindowStage);
      mocker.mockFunc(conversationService, conversationService.deleteMmsInfoByCondition);
      when(mocker.mockFunc(conversationService, conversationService.deleteSmsInfoByCondition))(ArgumentMatchers.any)
        .afterAction(() => {
          expect(res).assertTrue();
        });
      conversationService.deleteSmsMmsInfoByThreadId(context, actionData, () => {
      });
      mocker.clear(GlobalContext.getContext());
    })

    it('ConversationService_deleteSmsMmsInfoByThreadId_fail', 0, () => {
      let actionData: LooseObject = {
        threadIds: ['1'],
        listOfGroupSessionId: undefined
      };
      let conversationRcsInfo: ConversationRcsInfo = new ConversationRcsInfo(1, 1, '666666', '888888', 0,
        '0', 1, 'msgTitle', 'msgContent', 0, 0, 1, 1, 1, '1', 1, 0, '0', '0', 0, 0, 0, 0, ' 0', '0', 0, 0, 0, '0', 0,
        '1');
      let res = false;
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            res = true;
            callBack ? callBack({
              code: -1,
              response: {},
              abilityResult: [conversationRcsInfo]
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve());
          }
        } as Object | Window.WindowStage);
      mocker.mockFunc(conversationService, conversationService.deleteMmsInfoByCondition);
      when(mocker.mockFunc(conversationService, conversationService.deleteSmsInfoByCondition))(ArgumentMatchers.any)
        .afterAction(() => {
          expect(res).assertTrue();
        });
      conversationService.deleteSmsMmsInfoByThreadId(context, actionData, () => {
      });
      mocker.clear(GlobalContext.getContext());
    })

    it('ConversationService_deleteSmsMmsInfoByCondition_threadIds_msgType_1', 0, () => {
      let actionData: LooseObject = {
        threadIds: ['1'],
        isGroupSession: true,
        msgIdsRcs: [''],
        listOfGroupSessionId: undefined
      };
      let callback: Function = (res: LooseObject) => {
      };
      let res = false;
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            res = true;
            callBack ? callBack({
              code: 0,
              abilityResult: [{
                msgType: 1,
                groupId: 1,
                msgId: 1,
                sessionId: 1,
                rcsId: 1,
                rcsType: 0
              }]
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve())
          }
        } as Object | Window.WindowStage);

      mocker.mockFunc(conversationService, conversationService.deleteMmsInfoByCondition);
      when(mocker.mockFunc(conversationService, conversationService.deleteSmsInfoByCondition))(ArgumentMatchers.any)
        .afterAction(() => {
          expect(res).assertTrue();
        });

      conversationService.deleteSmsMmsInfoByCondition(mmsContext, actionData, callback);
    })

    it('ConversationService_deleteSmsMmsInfoByCondition_threadIds_msgType_0', 0, () => {
      let actionData: LooseObject = {
        threadIds: ['1'],
        isGroupSession: true,
        msgIdsRcs: [''],
        listOfGroupSessionId: undefined
      };
      let callback: Function = (res: LooseObject) => {
      };
      let res = false;
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            res = true;
            callBack ? callBack({
              code: 0,
              abilityResult: [{
                msgType: 0,
                groupId: 1,
                msgId: 1,
                sessionId: 1,
                rcsId: 1,
                rcsType: 0
              }]
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve())
          }
        } as Object | Window.WindowStage);

      mocker.mockFunc(conversationService, conversationService.deleteMmsInfoByCondition);
      when(mocker.mockFunc(conversationService, conversationService.deleteSmsInfoByCondition))(ArgumentMatchers.any)
        .afterAction(() => {
          expect(res).assertTrue();
        });

      conversationService.deleteSmsMmsInfoByCondition(mmsContext, actionData, callback);
    })

    it('ConversationService_deleteSmsMmsInfoByCondition_threadIds_fail', 0, () => {
      let actionData: LooseObject = {
        threadIds: ['1'],
        isGroupSession: true,
        msgIdsRcs: [''],
        listOfGroupSessionId: undefined
      };
      let callback: Function = (res: LooseObject) => {
      };
      let res = false;
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            res = true;
            callBack ? callBack({
              code: -1,
              abilityResult: [{
                msgType: 0,
                groupId: 1,
                msgId: 1,
                sessionId: 1,
                rcsId: 1,
                rcsType: 0
              }]
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve())
          }
        } as Object | Window.WindowStage);

      mocker.mockFunc(conversationService, conversationService.deleteMmsInfoByCondition);
      when(mocker.mockFunc(conversationService, conversationService.deleteSmsInfoByCondition))(ArgumentMatchers.any)
        .afterAction(() => {
          expect(res).assertTrue();
        });

      conversationService.deleteSmsMmsInfoByCondition(mmsContext, actionData, callback);
    })

    it('ConversationService_deleteSmsMmsInfoByCondition_isDraft', 0, () => {
      let actionData: LooseObject = {
        threadIds: [],
        isDraft: true,
        listOfGroupSessionId: undefined
      };
      let callback: Function = (res: LooseObject) => {
      };
      mocker.mockFunc(conversationService, conversationService.deleteSmsInfoByCondition);
      conversationService.deleteSmsMmsInfoByCondition(mmsContext, actionData, callback);
      mocker.verify('deleteSmsInfoByCondition', [actionData, callback, mmsContext]).never();
    })

    it('ConversationService_deleteSmsMmsInfoByCondition_groupIds_smsType_groupIdsRcs', 0, () => {
      let actionData: LooseObject = {
        threadIds: [],
        isDraft: false,
        groupIds: [''],
        smsType: '',
        groupIdsRcs: [''],
        currentTimeStamp: 0,
        isGroupSession: true,
        msgIdsRcs: ['']
      };
      let callback: Function = (res: LooseObject) => {
      };
      mocker.mockFunc(conversationService, conversationService.deleteSmsInfoByCondition);
      mocker.mockFunc(conversationService, conversationService.deleteMmsInfoByCondition);
      conversationService.deleteSmsMmsInfoByCondition(mmsContext, actionData, callback);
      mocker.verify('deleteSmsInfoByCondition', [actionData, callback, mmsContext]).times(0);
    })

    it('ConversationService_deleteSmsMmsInfoByCondition_groupId_currentTimeStamp_groupIdRcs', 0, () => {
      let actionData: LooseObject = {
        threadIds: [],
        isDraft: false,
        groupIds: [],
        groupId: '',
        smsType: undefined,
        currentTimeStamp: '',
        groupIdsRcs: [],
        groupIdRcs: ''
      };
      let callback: Function = (res: LooseObject) => {
      };
      mocker.mockFunc(conversationService, conversationService.deleteSmsInfoByCondition);
      mocker.mockFunc(conversationService, conversationService.deleteMmsInfoByCondition);
      conversationService.deleteSmsMmsInfoByCondition(mmsContext, actionData, callback);
      mocker.verify('deleteSmsInfoByCondition', [actionData, callback, mmsContext]).times(0);
    })

    it('ConversationService_deleteSmsMmsInfoByCondition_msgId', 0, () => {
      let actionData: LooseObject = {
        threadIds: [],
        isDraft: false,
        groupIds: [],
        groupId: undefined,
        msgId: '',
        smsType: undefined,
        currentTimeStamp: undefined,
        groupIdsRcs: [],
        groupIdRcs: undefined
      };
      let callback: Function = (res: LooseObject) => {
      };
      mocker.mockFunc(conversationService, conversationService.deleteSmsInfoByCondition);
      mocker.mockFunc(conversationService, conversationService.deleteMmsInfoByCondition);
      conversationService.deleteSmsMmsInfoByCondition(mmsContext, actionData, callback);
      mocker.verify('deleteSmsInfoByCondition', [actionData, callback, mmsContext]).never();
    })

    it('ConversationService_deleteSmsMmsInfoByCondition', 0, () => {
      let actionData: LooseObject = {
        threadIds: [],
        isDraft: false,
        groupIds: [],
        groupId: undefined,
        msgId: undefined,
        smsType: undefined,
        currentTimeStamp: undefined,
        groupIdsRcs: [],
        groupIdRcs: undefined
      };
      let callback: Function = (res: LooseObject) => {
      };
      mocker.mockFunc(conversationService, conversationService.deleteSmsInfoByCondition);
      mocker.mockFunc(conversationService, conversationService.deleteMmsInfoByCondition);
      conversationService.deleteSmsMmsInfoByCondition(mmsContext, actionData, callback);
      mocker.verify('deleteSmsInfoByCondition', [actionData, callback, mmsContext]).never();
    })

    it('ConversationService_deleteSmsInfoByCondition_getObject', 0, () => {
      let valueBucket: ValuesBucket = {};
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
            return new Promise<void>(resolve => resolve())
          }
        } as Object | Window.WindowStage);

      conversationService.deleteSmsInfoByCondition(mmsContext, valueBucket, callback);
    })

    it('ConversationService_deleteSmsInfoByCondition', 0, () => {
      let valueBucket: ValuesBucket = {};
      let callback: Function = (res: LooseObject) => {
        expect(res.code).assertEqual(-1);
      };
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn(null);
      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(mmsContext)
        .afterReturn(undefined);

      conversationService.deleteSmsInfoByCondition(mmsContext, valueBucket, callback);
    })

    it('ConversationService_updateSmsMmsInfoByCondition_getObject', 0, () => {
      let actionData: LooseObject = {};
      let valueBucket: ValuesBucket = {};
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
            return new Promise<void>(resolve => resolve())
          }
        } as Object | Window.WindowStage);

      conversationService.updateSmsMmsInfoByCondition(mmsContext, actionData, valueBucket, callback);
    })

    it('ConversationService_updateSmsMmsInfoByCondition', 0, () => {
      let actionData: LooseObject = {};
      let valueBucket: ValuesBucket = {};
      let callback: Function = (res: LooseObject) => {
        expect(res.code).assertEqual(-1);
      };
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn(null);
      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(mmsContext)
        .afterReturn(undefined);

      conversationService.updateSmsMmsInfoByCondition(mmsContext, actionData, valueBucket, callback);
    })

    it('ConversationService_querySmsMmsInfoSlotIdByCondition_getObject', 0, () => {
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
            return new Promise<void>(resolve => resolve())
          }
        } as Object | Window.WindowStage);

      conversationService.querySmsMmsInfoSlotIdByCondition(mmsContext, '55555', callback);
    })

    it('ConversationService_querySmsMmsInfoSlotIdByCondition', 0, () => {
      let callback: Function = (res: LooseObject) => {
        expect(res.code).assertEqual(-1);
      };
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn(null);
      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(mmsContext)
        .afterReturn(undefined);

      conversationService.querySmsMmsInfoSlotIdByCondition(mmsContext, '55555', callback);
    })

    it('ConversationService_querySmsMmsInfoByCondition_getObject', 0, () => {
      let actionData: LooseObject = {};
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
            return new Promise<void>(resolve => resolve())
          }
        } as Object | Window.WindowStage);

      conversationService.querySmsMmsInfoByCondition(mmsContext, actionData, callback);
    })

    it('ConversationService_querySmsMmsInfoByCondition', 0, () => {
      let actionData: LooseObject = {};
      let callback: Function = (res: LooseObject) => {
        expect(res.code).assertEqual(-1);
      };
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn(null);
      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(mmsContext)
        .afterReturn(undefined);

      conversationService.querySmsMmsInfoByCondition(mmsContext, actionData, callback);
    })

    it('ConversationService_querySmsMmsInfoByConditionAll_getObject', 0, () => {
      let actionData: LooseObject = {};
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
            return new Promise<void>(resolve => resolve())
          }
        } as Object | Window.WindowStage);

      conversationService.querySmsMmsInfoByConditionAll(mmsContext, actionData, callback);
    })

    it('ConversationService_querySmsMmsInfoByConditionAll', 0, () => {
      let actionData: LooseObject = {};
      let callback: Function = (res: LooseObject) => {
        expect(res.code).assertEqual(-1);
      };
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn(null);
      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(mmsContext)
        .afterReturn(undefined);

      conversationService.querySmsMmsInfoByConditionAll(mmsContext, actionData, callback);
    })

    it('ConversationService_queryMmsInfoByFavoriteCondition_getObject', 0, () => {
      let actionData: LooseObject = {};
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
            return new Promise<void>(resolve => resolve())
          }
        } as Object | Window.WindowStage);

      conversationService.queryMmsInfoByFavoriteCondition(mmsContext, actionData, callback);
    })

    it('ConversationService_queryMmsInfoByFavoriteCondition', 0, () => {
      let actionData: LooseObject = {};
      let callback: Function = (res: LooseObject) => {
        expect(res.code).assertEqual(-1);
      };
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn(null);
      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(mmsContext)
        .afterReturn(undefined);

      conversationService.queryMmsInfoByFavoriteCondition(mmsContext, actionData, callback);
    })

    it('ConversationService_queryAllInfoByFavorite', 0, () => {
      let actionData: LooseObject = {};
      let callback: Function = (res: LooseObject) => {
        expect(res.code).assertEqual(0);
      };
      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(mmsContext)
        .afterReturn(undefined);
      when(mocker.mockFunc(conversationService,
        conversationService.queryFavoriteMessageDetailResultAll))(ArgumentMatchers.any)
        .afterAction(() => {
          callback({
            code: 0
          } as LooseObject)
        });

      conversationService.queryAllInfoByFavorite(mmsContext, actionData, callback);
    })

    it('ConversationService_queryAllInfoByFavoriteCondition_getObject', 0, () => {
      let actionData: LooseObject = {};
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
            return new Promise<void>(resolve => resolve())
          }
        } as Object | Window.WindowStage);

      conversationService.queryAllInfoByFavoriteCondition(mmsContext, actionData, callback);
    })

    it('ConversationService_queryAllInfoByFavoriteCondition', 0, () => {
      let actionData: LooseObject = {};
      let callback: Function = (res: LooseObject) => {
        expect(res.code).assertEqual(-1);
      };
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn(null);
      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(mmsContext)
        .afterReturn(undefined);

      conversationService.queryAllInfoByFavoriteCondition(mmsContext, actionData, callback);
    })

    it('ConversationService_queryMmsInfoFirstCondition_getObject', 0, () => {
      let actionData: LooseObject = {};
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
            return new Promise<void>(resolve => resolve())
          }
        } as Object | Window.WindowStage);

      conversationService.queryMmsInfoLastReadCondition(mmsContext, actionData, callback);
    })

    it('ConversationService_queryMmsInfoFirstCondition', 0, () => {
      let actionData: LooseObject = {};
      let callback: Function = (res: LooseObject) => {
        expect(res.code).assertEqual(-1);
      };
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn(null);
      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(mmsContext)
        .afterReturn(undefined);

      conversationService.queryMmsInfoLastReadCondition(mmsContext, actionData, callback);
    })

    it('ConversationService_querySmsMmsInfoSizeByCondition_getObject', 0, () => {
      let actionData: LooseObject = {};
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
            return new Promise<void>(resolve => resolve())
          }
        } as Object | Window.WindowStage);

      conversationService.querySmsMmsInfoSizeByCondition(actionData, callback, mmsContext);
    })

    it('ConversationService_querySmsMmsInfoSizeByCondition_getObject_context_null_callback_null', 0, () => {
      let actionData: LooseObject = {};
      let callback: Function = (res: LooseObject) => {
        expect(res.code).assertEqual(0);
      };
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('mmsContext')
        .afterReturn(mmsContext);
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: 0
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve())
          }
        } as Object | Window.WindowStage);

      conversationService.querySmsMmsInfoSizeByCondition(actionData, callback, mmsContext);
    })

    it('ConversationService_querySmsMmsInfoSizeByCondition', 0, () => {
      let actionData: LooseObject = {};
      let callback: Function = (res: LooseObject) => {
        expect(res.code).assertEqual(-1);
      };
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn(null);
      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(mmsContext)
        .afterReturn(undefined);

      conversationService.querySmsMmsInfoSizeByCondition(actionData, callback, mmsContext);
    })

    it('ConversationService_queryAllInfoSizeByCondition_context_null', 0, async () => {
      let actionData: LooseObject = {};
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('mmsContext')
        .afterReturn(mmsContext);
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: 0,
              abilityResult: 1
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve())
          }
        } as Object | Window.WindowStage);

      let res = await conversationService.queryAllInfoSizeByCondition(mmsContext, actionData);
      expect(res === null).assertFalse();
    })

    it('ConversationService_getSmsMmsInfoSizeByCondition_fail', 0, async () => {
      let actionData: LooseObject = {};
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn(null);
      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(mmsContext)
        .afterReturn(undefined);

      let res = await conversationService.getSmsMmsInfoSizeByCondition(actionData, mmsContext);
      expect(res).assertEqual(0);
    })

    it('ConversationService_getSmsMmsInfoSizeByCondition_success', 0, async () => {
      let actionData: LooseObject = {};
      let mySet: DataShareResultSet = new MySet();
      mySet.rowCount = 1;
      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(mmsContext)
        .afterReturn(new Promise<dataShare.DataShareHelper | undefined>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve(mySet)),
          delete: (uri: string, predicates: dataSharePredicates.DataSharePredicates): Promise<number> =>
          new Promise<number>(resolve => resolve(1))
        } as dataShare.DataShareHelper)));

      let res = await conversationService.getSmsMmsInfoSizeByCondition(actionData, mmsContext);
      expect(res).assertEqual(1);
    })

    it('ConversationService_getRcsMmsInfoSizeByCondition_fail', 0, async () => {
      let actionData: LooseObject = {};
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn(null);
      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(mmsContext)
        .afterReturn(undefined);

      let res = await conversationService.getRcsMmsInfoSizeByCondition(actionData, mmsContext);
      expect(res).assertEqual(0);
    })

    it('ConversationService_getRcsMmsInfoSizeByCondition_success', 0, async () => {
      let actionData: LooseObject = {};
      let mySet: DataShareResultSet = new MySet();
      mySet.rowCount = 1;
      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(mmsContext)
        .afterReturn(new Promise<dataShare.DataShareHelper | undefined>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve(mySet)),
          delete: (uri: string, predicates: dataSharePredicates.DataSharePredicates): Promise<number> =>
          new Promise<number>(resolve => resolve(1))
        } as dataShare.DataShareHelper)));

      let res = await conversationService.getRcsMmsInfoSizeByCondition(actionData, mmsContext);
      expect(res).assertEqual(1);
    })

    it('ConversationService_statisticalData_getObject', 0, () => {
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
            return new Promise<void>(resolve => resolve())
          }
        } as Object | Window.WindowStage);

      conversationService.statisticalData(callback, mmsContext);
    })

    it('ConversationService_statisticalData_statisticalData', 0, () => {
      let callback: Function = (res: LooseObject) => {
        expect(res.code).assertEqual(-1);
      };
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn(null);
      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(mmsContext)
        .afterReturn(undefined);

      conversationService.statisticalData(callback, mmsContext);
    })

    it('ConversationService_statisticalData_statisticalData_context_null', 0, () => {
      let callback: Function = (res: LooseObject) => {
        expect(res.code).assertEqual(-1);
      };
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn(null);
      when(mocker.mockFunc(DataShareHelper.getInstance(),
        DataShareHelper.getInstance().initSmsDB))(ArgumentMatchers.any)
        .afterReturn(undefined);

      conversationService.statisticalData(callback, mmsContext);
    })

    it('ConversationService_selectInfoCount_getObject', 0, () => {
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
            return new Promise<void>(resolve => resolve())
          }
        } as Object | Window.WindowStage);

      conversationService.selectInfoCount(callback, mmsContext);
    })

    it('ConversationService_selectInfoCount_selectInfoCount', 0, () => {
      let callback: Function = (res: LooseObject) => {
        expect(res.code).assertEqual(-1);
      };
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn(null);
      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(mmsContext)
        .afterReturn(undefined);

      conversationService.selectInfoCount(callback, mmsContext);
    })

    it('ConversationService_selectInfoCount_selectInfoCount_context_null', 0, () => {
      let callback: Function = (res: LooseObject) => {
        expect(res.code).assertEqual(-1);
      };
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn(null);
      when(mocker.mockFunc(DataShareHelper.getInstance(),
        DataShareHelper.getInstance().initSmsDB))(ArgumentMatchers.any)
        .afterReturn(undefined);

      conversationService.selectInfoCount(callback, mmsContext);
    })

    it('ConversationService_getSmsInfoCount_fail', 0, async () => {
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn(null);
      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(mmsContext)
        .afterReturn(undefined);

      let res = await conversationService.getSmsInfoCount(mmsContext);
      expect(res).assertEqual(0);
    })

    it('ConversationService_getSmsInfoCount_success', 0, async () => {
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: 0,
              abilityResult: {
                msgNumTotal: 1
              }
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve())
          }
        } as Object | Window.WindowStage);

      let res = await conversationService.getSmsInfoCount(mmsContext);
      expect(res).assertEqual(1);
    })

    it('ConversationService_getSmsInfoCount_success_abilityResult_null', 0, async () => {
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: 0,
              abilityResult: null
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve())
          }
        } as Object | Window.WindowStage);

      let res = await conversationService.getSmsInfoCount(mmsContext);
      expect(res).assertEqual(0);
    })

    it('ConversationService_selectContactId_getObject', 0, () => {
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
            return new Promise<void>(resolve => resolve())
          }
        } as Object | Window.WindowStage);

      conversationService.selectContactId(callback, mmsContext);
    })

    it('ConversationService_selectContactId_selectInfoCount', 0, () => {
      let callback: Function = (res: LooseObject) => {
        expect(res.code).assertEqual(-1);
      };
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn(null);
      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(mmsContext)
        .afterReturn(undefined);

      conversationService.selectContactId(callback, mmsContext);
    })

    it('ConversationService_selectContactId_selectContactId_context_null', 0, () => {
      let callback: Function = (res: LooseObject) => {
        expect(res.code).assertEqual(-1);
      };
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn(null);
      when(mocker.mockFunc(DataShareHelper.getInstance(),
        DataShareHelper.getInstance().initSmsDB))(ArgumentMatchers.any)
        .afterReturn(undefined);

      conversationService.selectContactId(callback, mmsContext);
    })

    it('ConversationService_getContactId_fail', 0, async () => {
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn(null);
      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(mmsContext)
        .afterReturn(undefined);

      let res = await conversationService.getContactId(mmsContext);
      expect(JSON.stringify(res)).assertEqual('{}');
    })

    it('ConversationService_getContactId_success', 0, async () => {
      let mySet: DataShareResultSet = new MySet();
      mySet.rowCount = 1;
      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(mmsContext)
        .afterReturn(new Promise<dataShare.DataShareHelper | undefined>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve(mySet)),
          delete: (uri: string, predicates: dataSharePredicates.DataSharePredicates): Promise<number> =>
          new Promise<number>(resolve => resolve(1))
        } as dataShare.DataShareHelper)));

      let res = await conversationService.getContactId(mmsContext);
      expect(JSON.stringify(res)).assertEqual('{}');
    })

    it('ConversationService_queryMaxGroupId_getObject', 0, () => {
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
            return new Promise<void>(resolve => resolve())
          }
        } as Object | Window.WindowStage);

      conversationService.queryMaxGroupId(callback, mmsContext);
    })

    it('ConversationService_queryMaxGroupId_queryMaxGroupId', 0, () => {
      let callback: Function = (res: LooseObject) => {
        expect(res.code).assertEqual(-1);
      };
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn(null);
      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(mmsContext)
        .afterReturn(undefined);

      conversationService.queryMaxGroupId(callback, mmsContext);
    })

    it('ConversationService_queryMaxGroupIdInMmsInfoTable_getObject', 0, () => {
      let callback = (res: LooseObject) => {
        expect(res.code).assertEqual(0);
      };
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: 0
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve())
          }
        } as Object | Window.WindowStage);

      conversationService.queryMaxGroupIdInMmsInfoTable(callback, mmsContext);
    })

    it('ConversationService_queryMaxGroupIdInMmsInfoTable_getObject_context_null', 0, () => {
      let callback = (res: LooseObject) => {
        expect(res.code).assertEqual(0);
      };
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn(mmsContext);
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: 0
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve())
          }
        } as Object | Window.WindowStage);

      conversationService.queryMaxGroupIdInMmsInfoTable(callback, mmsContext);
    })

    it('ConversationService_queryDraftBySessionId', 0, () => {
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn(mmsContext);
      when(mocker.mockFunc(DataShareHelper.getInstance(),
        DataShareHelper.getInstance().initSmsDB))(ArgumentMatchers.any)
        .afterReturn(undefined);
      conversationService.queryDraftBySessionId(1001, mmsContext);
      mocker.verify('getObject', ['mmsContext']).never();
    })

    it('ConversationService_queryDraftBySessionId_context_null', 0, () => {
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn(mmsContext);
      when(mocker.mockFunc(DataShareHelper.getInstance(),
        DataShareHelper.getInstance().initSmsDB))(ArgumentMatchers.any)
        .afterReturn(undefined);
      conversationService.queryDraftBySessionId(1001, mmsContext);
      mocker.verify('getObject', ['mmsContext']).never();
    })

    it('ConversationService_queryMaxGroupIdInMmsInfoTable', 0, () => {
      let callback = (res: LooseObject) => {
        expect(res.code).assertEqual(-1);
      };
      when(mocker.mockFunc(GlobalContext.getContext(),GlobalContext.getContext().getObject))('mmsContext')
        .afterReturn(null);
      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(mmsContext)
        .afterReturn(undefined);

      conversationService.queryMaxGroupIdInMmsInfoTable(callback, mmsContext);
    })

    it('ConversationService_queryMessageDetailAll', 0, () => {
      let actionData: LooseObject = {};
      let callback = (res: LooseObject) => {
        expect(res.code).assertEqual(-1);
      };
      when(mocker.mockFunc(GlobalContext.getContext(),GlobalContext.getContext().getObject))('mmsContext')
        .afterReturn(null);
      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(mmsContext)
        .afterReturn(undefined);
      when(mocker.mockFunc(conversationService, conversationService.queryMessageDetailResultAll))(ArgumentMatchers.any)
        .afterAction(() => {
          callback({
            code: -1
          } as LooseObject)
        });

      conversationService.queryMessageDetailAll(mmsContext, actionData, callback, 0);
    })

    it('ConversationService_queryFavoriteMessageDetailResultAll_fail', 0, async () => {
      let res1: resType = {
        code: -1,
        response: {},
        abilityResult: [],
      };
      let actionData: LooseObject = {};
      let callback: Function = (res: LooseObject) => {
        expect(res.code).assertEqual(-1);
      };

      when(mocker.mockFunc(conversationService, conversationService.queryMessageDetailFail))(ArgumentMatchers.any)
        .afterAction(() => {
          callback({
            code: -1
          } as LooseObject)
        });

      conversationService.queryFavoriteMessageDetailResultAll(res1, actionData, callback, mmsContext, 0);
    })

    it('ConversationService_queryFavoriteMessageDetailResultAll_success', 0, async () => {
      let res1: resType = {
        code: 0,
        response: {},
        abilityResult: [{
          msgType: 1,
          mmsList: [],
          rcsType: 0,
          rcsId: 1,
          msgId: 1,
        }],
      };
      let actionData: LooseObject = {};
      let callback: Function = (res: LooseObject) => {
        expect(res.code).assertEqual(0);
      };
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: -1
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve())
          }
        } as Object | Window.WindowStage);

      when(mocker.mockFunc(conversationService, conversationService.getFavoriteDetailItem))(ArgumentMatchers.any)
        .afterReturn({});

      conversationService.queryFavoriteMessageDetailResultAll(res1, actionData, callback, mmsContext, 0);
    })

    it('ConversationService_getFavoriteDetailItem_rcsId_undefined_isRcs_0_mmsList', 0, async () => {
      let item1: LooseObject = {
        rcsId: undefined,
        isRcs: 0,
        mmsList: [],
        mmsSource: '',
        isMsm: true,
        isSender: 0,
        msgType: 1
      };
      when(mocker.mockFunc(MmsUtil, MmsUtil.getMmsSourceFromRequest))(ArgumentMatchers.any)
        .afterReturn([]);
      when(mocker.mockFunc(MmsUtil, MmsUtil.getMmsContentType))(ArgumentMatchers.any)
        .afterReturn([]);
      let res: LooseObject = conversationService.getFavoriteDetailItem(item1);
      expect(res.hasMms).assertTrue();
      mocker.clear(MmsUtil);
    })

    it('ConversationService_getFavoriteDetailItem_rcsId_0_isRcs_0_mmsList', 0, async () => {
      let item1: LooseObject = {
        rcsId: 0,
        isRcs: 0,
        mmsList: undefined,
        mmsSource: '',
        isMsm: true,
        isSender: 1,
        msgType: 0
      };
      let res: LooseObject = conversationService.getFavoriteDetailItem(item1);
      expect(res.hasMms).assertFalse();
      mocker.clear(MmsUtil);
    })

    it('ConversationService_getFavoriteDetailItem_rcsId_empty_isRcs_1_mmsList', 0, async () => {
      let item1: LooseObject = {
        rcsId: '',
        isRcs: 1,
        mmsList: undefined,
        mmsSource: '',
        isMsm: true,
        isSender: 1,
        msgType: 0
      };
      let res: LooseObject = conversationService.getFavoriteDetailItem(item1);
      expect(res.hasMms).assertFalse();
      mocker.clear(MmsUtil);
    })

    it('ConversationService_getFavoriteDetailItem_rcsId_1_isRcs_1_mmsList', 0, async () => {
      let item1: LooseObject = {
        rcsId: 1,
        isRcs: 1,
        mmsList: undefined,
        mmsSource: '',
        isMsm: true,
        isSender: 1,
        msgType: 0
      };
      let res: LooseObject = conversationService.getFavoriteDetailItem(item1);
      expect(res.hasMms).assertFalse();
      mocker.clear(MmsUtil);
    })

    it('ConversationService_queryMessageDetailResultAll_success', 0, async () => {
      let res1: resType = {
        code: 0,
        response: {},
        abilityResult: [{
          rcsId: 1,
          isRcs: 1,
          smsType: '98'
        }],
      };
      mocker.mockFunc(conversationService, conversationService.queryMmsInfoResponse);
      when(mocker.mockFunc(conversationService, conversationService.convertConversationList))(ArgumentMatchers.any)
        .afterReturn([{}]);
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: -1
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve());
          }
        } as Object | Window.WindowStage);
      conversationService.queryMessageDetailResultAll(res1, {
        contactsNum: 1
      }, (res: LooseObject) => {
        expect(res.code).assertEqual(0);
      }, mmsContext, 0);
    })

    it('ConversationService_queryMessageDetailResultAll_success_rcsId_undefined', 0, async () => {
      let res1: resType = {
        code: 0,
        response: {},
        abilityResult: [],
      };
      let actionData: LooseObject = {
        contactsNum: 1
      };
      mocker.mockFunc(conversationService, conversationService.queryMmsInfoResponse);
      when(mocker.mockFunc(conversationService, conversationService.convertConversationList))(ArgumentMatchers.any)
        .afterReturn([{}]);
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
        } as Object | Window.WindowStage);
      conversationService.queryMessageDetailResultAll(res1, actionData, (res: LooseObject) => {
        expect(res.code).assertEqual(0);
      }, mmsContext, 0);
    })

    it('ConversationService_queryMessageDetailResultAll_success_rcsId_0', 0, async () => {
      let res1: resType = {
        code: 0,
        response: {},
        abilityResult: [{
          rcsId: 0,
          msgId: 0
        }],
      };
      let actionData: LooseObject = {
        contactsNum: 1
      };
      mocker.mockFunc(conversationService, conversationService.queryMmsInfoResponse);
      when(mocker.mockFunc(conversationService, conversationService.convertConversationList))(ArgumentMatchers.any)
        .afterReturn([{}]);
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
        } as Object | Window.WindowStage);
      conversationService.queryMessageDetailResultAll(res1, actionData, (res: LooseObject) => {
        expect(res.code).assertEqual(0);
      }, mmsContext, 0);
    })

    it('ConversationService_queryMessageDetailResultAll_success_rcsId_empty', 0, async () => {
      let res1: resType = {
        code: 0,
        response: {},
        abilityResult: [{
          rcsId: '',
          msgId: 0
        }],
      };
      let actionData: LooseObject = {
        contactsNum: 1
      };
      mocker.mockFunc(conversationService, conversationService.queryMmsInfoResponse);
      when(mocker.mockFunc(conversationService, conversationService.convertConversationList))(ArgumentMatchers.any)
        .afterReturn([{}]);
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
        } as Object | Window.WindowStage);
      conversationService.queryMessageDetailResultAll(res1, actionData, (res: LooseObject) => {
        expect(res.code).assertEqual(0);
      }, mmsContext, 0);
    })

    it('ConversationService_queryMessageDetailResultAll_fail', 0, async () => {
      let res1: resType = {
        code: -1,
        response: {},
        abilityResult: [],
      };
      let actionData: LooseObject = {
        contactsNum: 1
      };
      let res = false;
      when(mocker.mockFunc(conversationService, conversationService.queryMessageDetailFail))(ArgumentMatchers.any)
        .afterAction(() => {
          res = true;
        });
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
        } as Object | Window.WindowStage);
      conversationService.queryMessageDetailResultAll(res1, actionData, () => {
      }, mmsContext, 0);
      expect(res).assertTrue();
    })

    it('ConversationService_queryMessageDetailFail', 0, async () => {
      conversationService.queryMessageDetailFail({}, (res: LooseObject) => {
        expect(res.code).assertEqual(-1);
      });
    })

    it('ConversationService_queryRcsInfoByConditionResult_success', 0, async () => {
      let res2: resType = {
        code: 0,
        response: {},
        abilityResult: [{
          isRcs: 0, rcsId: 0
        }],
      };
      when(mocker.mockFunc(conversationService, conversationService.convertConversationList))(ArgumentMatchers.any)
        .afterReturn([]);
      conversationService.queryRcsInfoByConditionResult(mmsContext, res2, {}, (res: LooseObject) => {
        expect(res.response.length).assertEqual(0);
      }, [{
        startTime: 0
      }, {
        startTime: 1
      }], {
        contactsNum: 1
      });
    })

    it('ConversationService_queryRcsInfoByConditionResult_fail', 0, () => {
      let res2: resType = {
        code: -1,
        response: {},
        abilityResult: [{
          isRcs: 0, rcsId: 0
        }],
      };
      conversationService.queryRcsInfoByConditionResult(mmsContext, res2, {}, (res: LooseObject) => {
        expect(res.code).assertEqual(-1);
      }, [{
        startTime: 0
      }, {
        startTime: 1
      }], {});
    })

    it('ConversationService_convertConversationList', 0, () => {
      when(mocker.mockFunc(conversationService,
        conversationService.convertConversationListResult))(ArgumentMatchers.any)
        .afterReturn({
          isRcs: 0,
        } as LooseObject);
      let res: Array<LooseObject> = conversationService.convertConversationList(mmsContext, [{}]);
      expect(res[0].isRcs).assertEqual(0);
    })

    it('ConversationService_groupDetailMessage', 0, () => {
      let maps: Map<string, Record<string, Object>[]> = new Map();
      maps.set('', [{
        'timeMillisecond': 0, 'sendStatus': 2, 'isRcs': true
      }]);
      when(mocker.mockFunc(conversationService, conversationService.convertConversationMap))(ArgumentMatchers.any)
        .afterReturn(maps);
      conversationService.groupDetailMessage(mmsContext, [{}], {}, (res: LooseObject[]) => {
        expect(res[0].timeMillisecond).assertEqual(0);
      });
    })

    it('ConversationService_groupDetailMessage_handleItemSendStatusInGroupSendSession_sendStatus_1', 0, () => {
      let maps: Map<string, Record<string, Object>[]> = new Map();
      maps.set('', [{
        'timeMillisecond': 0, 'sendStatus': 1, 'isRcs': false
      }]);
      when(mocker.mockFunc(conversationService, conversationService.convertConversationMap))(ArgumentMatchers.any)
        .afterReturn(maps);
      conversationService.groupDetailMessage(mmsContext, [{}], {}, (res: LooseObject[]) => {
        expect(res[0].timeMillisecond).assertEqual(0);
      });
    })

    it('ConversationService_groupDetailMessage_handleItemSendStatusInGroupSendSession_sendStatus_2', 0, () => {
      let maps: Map<string, Record<string, Object>[]> = new Map();
      maps.set('', [{
        'timeMillisecond': 0, 'sendStatus': 2, 'isRcs': false
      }]);
      when(mocker.mockFunc(conversationService, conversationService.convertConversationMap))(ArgumentMatchers.any)
        .afterReturn(maps);
      conversationService.groupDetailMessage(mmsContext, [{}], {}, (res: LooseObject[]) => {
        expect(res[0].timeMillisecond).assertEqual(0);
      });
    })

    it('ConversationService_groupDetailMessage_handleItemSendStatusInGroupSendSession_sendStatus_4', 0, () => {
      let maps: Map<string, Record<string, Object>[]> = new Map();
      maps.set('', [{
        'timeMillisecond': 0, 'sendStatus': 4, 'isRcs': false
      }]);
      when(mocker.mockFunc(conversationService, conversationService.convertConversationMap))(ArgumentMatchers.any)
        .afterReturn(maps);
      conversationService.groupDetailMessage(mmsContext, [{}], {}, (res: LooseObject[]) => {
        expect(res[0].timeMillisecond).assertEqual(0);
      });
    })

    it('ConversationService_groupDetailMessage_handleItemSendStatusInGroupSendSession_sendStatus_3', 0, () => {
      let maps: Map<string, Record<string, Object>[]> = new Map();
      maps.set('', [{
        'timeMillisecond': 0, 'sendStatus': 3, 'isRcs': false
      }, {
        'timeMillisecond': 0, 'sendStatus': 3, 'isRcs': false
      }]);
      when(mocker.mockFunc(conversationService, conversationService.convertConversationMap))(ArgumentMatchers.any)
        .afterReturn(maps);
      conversationService.groupDetailMessage(mmsContext, [{}], {}, (res: LooseObject[]) => {
        expect(res[0].timeMillisecond).assertEqual(0);
      });
    })

    it('ConversationService_groupDetailMessage_contactsNum_1', 0, () => {
      let maps: Map<string, Record<string, Object>[]> = new Map();
      maps.set('', [{
        'timeMillisecond': 0, 'sendStatus': 2
      }, {
        'timeMillisecond': 1, 'sendStatus': 1
      }]);
      when(mocker.mockFunc(conversationService, conversationService.convertConversationList))(ArgumentMatchers.any)
        .afterReturn([]);
      conversationService.groupDetailMessage(mmsContext, [{}], {
        contactsNum: 1
      }, (res: LooseObject[]) => {
        expect(res.length).assertEqual(0);
      });
    })

    it('ConversationService_convertConversationMap', 0, () => {
      let res: Map<string, Record<string, Object>[]> = conversationService.convertConversationMap([{
        'groupId': '1'
      }, {
        'groupId': '1'
      }]);

      expect(res.get('1')?.length).assertEqual(2);
    })

    it('ConversationService_insertSessionAndDetail_sendResults_empty', 0, () => {
      let actionData: LooseObject = {
        sendResults: [],
        isReceive: true
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      mocker.mockFunc(conversationService, conversationService.dealSendResults);
      conversationService.insertSessionAndDetail(actionData, () => {
      }, context);
      mocker.verify('dealSendResults', [[]]).never();
    })

    it('ConversationService_insertSessionAndDetail_success_responseId_0_sessionContacts', 0, () => {
      let actionData: LooseObject = {
        sendResults: [{}],
        isReceive: true,
        sessionContacts: [{
          contactPhone: '6666', rawContactId: '1'
        } as SessionContactInfoForDB, {
          contactPhone: '7777', rawContactId: '2', contactName: 'name2'
        } as SessionContactInfoForDB]
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      when(mocker.mockFunc(conversationService, conversationService.dealSendResults))(ArgumentMatchers.any)
        .afterReturn({
          telephone: '666666',
          contactName: 'name',
          contactId: '1'
        });
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: 0,
              abilityResult: [{
                id: 0,
              } as ResponseType]
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve());
          }
        } as Object | Window.WindowStage);
      when(mocker.mockFunc(TelephoneUtil, TelephoneUtil.getTelephoneByFuzzMatch))(ArgumentMatchers.any).afterReturn({
        id: 0,
      } as ResponseType);
      when(mocker.mockFunc(conversationService, conversationService.dealNoExistSession))(ArgumentMatchers.any)
        .afterAction(() => {
          mocker.verify('dealSendResults', [actionData.sendResults]).never();
        });
      conversationService.insertSessionAndDetail(actionData, () => {
      }, context);

      mocker.clear(TelephoneUtil);
    })

    it('ConversationService_insertSessionAndDetail_success_responseId_0_params_telephone_undefined', 0, () => {
      let actionData: LooseObject = {
        sendResults: [{}],
        isReceive: true,
        sessionContacts: [{
          contactPhone: '6666', rawContactId: '1'
        } as SessionContactInfoForDB, {
          contactPhone: '7777', rawContactId: '2', contactName: 'name2'
        } as SessionContactInfoForDB]
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      when(mocker.mockFunc(conversationService, conversationService.dealSendResults))(ArgumentMatchers.any)
        .afterReturn({
          telephone: undefined,
          contactName: 'name',
          contactId: '1'
        } as LooseObject);
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: 0,
              abilityResult: [{
                id: 0
              } as ResponseType]
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve());
          }
        } as Object | Window.WindowStage);
      when(mocker.mockFunc(conversationService, conversationService.dealNoExistSession))(ArgumentMatchers.any)
        .afterAction(() => {
          mocker.verify('dealSendResults', [actionData.sendResults]).once();
        });
      when(mocker.mockFunc(TelephoneUtil, TelephoneUtil.getTelephoneByFuzzMatch))(ArgumentMatchers.any).afterReturn({
        id: 0,
      } as ResponseType);
      conversationService.insertSessionAndDetail(actionData, () => {
      }, context);
      mocker.clear(TelephoneUtil);
    })

    it('ConversationService_insertSessionAndDetail_success_responseId_0_sessionContacts_empty', 0, () => {
      let actionData: LooseObject = {
        sendResults: [{}],
        isReceive: true,
        sessionContacts: []
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      when(mocker.mockFunc(conversationService, conversationService.dealSendResults))(ArgumentMatchers.any)
        .afterReturn({
          telephone: '666666',
          contactName: 'name',
          contactId: '1',
        });
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: 0,
              abilityResult: [{
                id: 0
              } as ResponseType]
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve());
          }
        } as Object | Window.WindowStage);
      when(mocker.mockFunc(conversationService, conversationService.dealNoExistSession))(ArgumentMatchers.any)
        .afterAction(() => {
          mocker.verify('dealSendResults', [actionData.sendResults]).never();
        });
      when(mocker.mockFunc(TelephoneUtil, TelephoneUtil.getTelephoneByFuzzMatch))(ArgumentMatchers.any).afterReturn({
        id: 0,
      } as ResponseType);
      conversationService.insertSessionAndDetail(actionData, () => {
      }, context);
      mocker.clear(TelephoneUtil);
    })

    it('ConversationService_insertSessionAndDetail_success_responseId_1', 0, () => {
      let actionData: LooseObject = {
        sendResults: [{}],
        isReceive: true,
        sessionContacts: []
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      when(mocker.mockFunc(conversationService, conversationService.dealSendResults))(ArgumentMatchers.any)
        .afterReturn({
          telephone: '666666',
          contactName: 'name',
          contactId: '1',
        });
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: 0,
              abilityResult: [{
                id: 1
              } as ResponseType]
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve());
          }
        } as Object | Window.WindowStage);
      when(mocker.mockFunc(conversationService, conversationService.dealExistSession))(ArgumentMatchers.any)
        .afterAction(() => {
          mocker.verify('dealSendResults', [actionData.sendResults]).never();
        });
      when(mocker.mockFunc(TelephoneUtil, TelephoneUtil.getTelephoneByFuzzMatch))(ArgumentMatchers.any).afterReturn({
        id: 1,
      } as ResponseType);
      conversationService.insertSessionAndDetail(actionData, () => {
      }, context);
      mocker.clear(TelephoneUtil);
    })

    it('ConversationService_insertSessionAndDetail_fail', 0, () => {
      let actionData: LooseObject = {
        sendResults: [{}],
        isReceive: true,
        sessionContacts: []
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      when(mocker.mockFunc(conversationService, conversationService.dealSendResults))(ArgumentMatchers.any)
        .afterReturn({
          telephone: null
        });
      conversationService.insertSessionAndDetail(actionData, () => {
      }, context);
      mocker.verify('dealSendResults', [actionData.sendResults]).never();
    })

    it('ConversationService_dealNoExistSession_isBlockLooseObject_initDatas_false', 0, () => {
      let actionData: LooseObject = {
        sendResults: [],
        isReceive: true
      };
      let res = false;
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      when(mocker.mockFunc(conversationService, conversationService.dealInsertMessageDetail))(ArgumentMatchers.any)
        .afterAction(() => {
          res = true;
        });
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: -1,
              initDatas: false
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve());
          }
        } as Object | Window.WindowStage);
      mocker.mockFunc(conversationService, conversationService.insertMessageDetailByMaxGroupId);
      conversationService.dealNoExistSession(false, {}, actionData, () => {
      }, context);
      expect(res).assertTrue();
    })

    it('ConversationService_dealNoExistSession_isBlockLooseObject_initDatas_true', 0, () => {
      let actionData: LooseObject = {
        sendResults: [],
        isReceive: true,
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: -1,
              initDatas: true
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve());
          }
        } as Object | Window.WindowStage);
      mocker.mockFunc(conversationService, conversationService.insertMessageDetailByMaxGroupId);
      mocker.mockFunc(conversationService, conversationService.insertMmsInfoList);
      conversationService.dealNoExistSession(false, {
        smsType: 1
      }, actionData, (res: Record<string, number | LooseObject[]>) => {
        expect(res.smsType).assertEqual(1);
      }, context);
    })

    it('ConversationService_dealNoExistSession_isMms_true_hasAttachment_true', 0, () => {
      let actionData: LooseObject = {
        sendResults: [],
        isReceive: true,
        isMms: true,
        hasAttachment: true,
        groupId: '1'
      };
      let res = false;
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      when(mocker.mockFunc(conversationService, conversationService.dealInsertMessageDetail))(ArgumentMatchers.any)
        .afterAction(() => {
          res = true;
        });
      conversationService.dealNoExistSession(false, {}, actionData, () => {
      }, context);
      expect(res).assertTrue();
    })

    it('ConversationService_dealNoExistSession_isBlockLooseObject_false_fail', 0, () => {
      let actionData: LooseObject = {
        sendResults: [],
        isReceive: false
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      when(mocker.mockFunc(GlobalContext.getContext(),GlobalContext.getContext().getObject))('mmsContext')
        .afterReturn(null);
      when(mocker.mockFunc(DataShareHelper.getInstance(),
        DataShareHelper.getInstance().initSmsDB))(ArgumentMatchers.any)
        .afterReturn(new Promise<dataShare.DataShareHelper | undefined>(resolve => resolve(undefined)));
      conversationService.dealNoExistSession(false, {}, actionData, (res: Record<string, number>) => {
        expect(res.code).assertEqual(-1);
      }, context);
    })

    it('ConversationService_dealNoExistSession_isBlockLooseObject_false_success', 0, () => {
      let actionData: LooseObject = {
        sendResults: [],
        isReceive: true
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      when(mocker.mockFunc(GlobalContext.getContext(),GlobalContext.getContext().getObject))('mmsContext')
        .afterReturn(null);
      when(mocker.mockFunc(DataShareHelper.getInstance(),
        DataShareHelper.getInstance().initSmsDB))(ArgumentMatchers.any)
        .afterReturn(new Promise<dataShare.DataShareHelper | undefined>(resolve => resolve({
          insert: (uri: string, value: ValuesBucket): Promise<number> => new Promise<number>(resolve => resolve(1))
        } as dataShare.DataShareHelper)));

      mocker.mockFunc(conversationService, conversationService.dealInsertMessageDetail);
      conversationService.dealNoExistSession(false, {}, actionData, (res: Record<string, number>) => {
      }, context);
      expect(conversationService).not().assertUndefined();
    })

    it('ConversationService_dealExistSession_isBlockLooseObject_true', 0, () => {
      let response: LooseObject = {
        unreadCount: 0,
        hasDraft: 1,
        messageCount: 0,
        id: 1,
      };
      let actionData: LooseObject = {
        sendResults: [],
        isNeedSendNotice: false,
        isReceive: true,
        hasDraft: 1
      };
      let res = false;
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      when(mocker.mockFunc(conversationService, conversationService.dealInsertMessageDetail))(ArgumentMatchers.any)
        .afterAction(() => {
          res = true;
        });
      conversationService.dealExistSession(response, {}, actionData, () => {
      }, context);
      expect(res).assertTrue();
    })

    it('ConversationService_dealExistSession_isMms_true', 0, () => {
      let response: LooseObject = {
        unreadCount: 0,
        hasDraft: 1,
        messageCount: 0,
        id: 1,
        telephone: '11111'
      };
      let actionData: LooseObject = {
        sendResults: [],
        isNeedSendNotice: false,
        isReceive: true,
        hasDraft: 1,
        hasAttachment: true,
        isMms: true
      };
      let res = false;
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      when(mocker.mockFunc(conversationService, conversationService.dealInsertMessageDetail))(ArgumentMatchers.any)
        .afterAction(() => {
          res = true;
        });
      conversationService.dealExistSession(response, {
        telephone: '33333'
      }, actionData, () => {
      }, context);
      expect(res).assertTrue();
    })

    it('ConversationService_dealExistSession_isBlockLooseObject_false_fail', 0, () => {
      let response: LooseObject = {
        unreadCount: 0,
        hasDraft: 1,
        messageCount: 0,
        id: 1,
      };
      let actionData: LooseObject = {
        sendResults: [],
        isNeedSendNotice: true,
        isReceive: true,
        hasDraft: 0,
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: -1,
              abilityResult: 0
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve());
          }
        } as Object | Window.WindowStage);
      mocker.mockFunc(conversationService, conversationService.dealInsertMessageDetail);
      conversationService.dealExistSession(response, {}, actionData, (res: Record<string, number>) => {
      }, context);
      expect(conversationService).not().assertUndefined();
    })

    it('ConversationService_dealInsertMessageDetail_type_RCS', 0, () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let param: LooseObject = {
        content: 'xx'
      };
      let actionData: LooseObject = {
        groupId: 1,
        sendResults: [{
          telephone: '570977632', sendStatus: 1
        } as LooseObject],
        start_time: null,
        type: 'rcs',
        isReceive: false,
        ownNumber: false,
        mmsPdu: true,
        endTime: undefined,
        expiresTime: undefined,
        isRcsType: 0,
        isNeedSendNotice: true,
        slotId: 1,
        smsType: 1,
        sendStatus: 1
      };
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              'code': 0,
              'abilityResult': 0
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve());
          }
        } as Object | Window.WindowStage);
      conversationService.dealInsertMessageDetail(param, actionData, 1, (result: LooseObject) => {
        expect(result.initDatas.length).assertEqual(1);
      }, context);
    })

    it('ConversationService_dealInsertMessageDetail_type_RCS_SEND', 0, () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let param: LooseObject = {
        content: 'xx'
      };
      let actionData: LooseObject = {
        groupId: 1,
        sendResults: [{
          telephone: '570977632', sendStatus: 1
        } as LooseObject],
        start_time: null,
        type: 'rcs_send',
        isReceive: false,
        ownNumber: false,
        mmsPdu: true,
        endTime: undefined,
        expiresTime: undefined,
        isRcsType: 0,
        isNeedSendNotice: true,
        slotId: 1,
        smsType: 1,
        sendStatus: 1
      };
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              'code': 0,
              'abilityResult': 0
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve());
          }
        } as Object | Window.WindowStage);
      conversationService.dealInsertMessageDetail(param, actionData, 1, (result: LooseObject) => {
        expect(result.initDatas.length).assertEqual(1);
      }, context);
    })

    it('ConversationService_dealInsertMessageDetail_type_MMS_SEND', 0, () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let param: LooseObject = {
        content: 'xx'
      };
      let actionData: LooseObject = {
        groupId: '1',
        sendResults: [{
          telephone: '570977632', sendStatus: 1
        } as LooseObject],
        start_time: null,
        type: 'mms_send',
        isReceive: false,
        ownNumber: false,
        mmsPdu: false,
        endTime: undefined,
        expiresTime: undefined,
        isRcsType: 0,
        isNeedSendNotice: true,
        slotId: 1,
        smsType: 1,
        sendStatus: 1
      };
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              'code': 0,
              'abilityResult': 0
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve());
          }
        } as Object | Window.WindowStage);
      conversationService.dealInsertMessageDetail(param, actionData, 1, (result: LooseObject) => {
        expect(result.initDatas.length).assertEqual(1);
      }, context);
    })


    it('ConversationService_dealInsertDraftData_type_mms_send', 0, () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      mocker.mockFunc(conversationService, conversationService.deleteSmsMmsInfoByCondition);
      when(mocker.mockFunc(DataShareHelper.getInstance(),
        DataShareHelper.getInstance().initSmsDB))(ArgumentMatchers.any)
        .afterReturn(new Promise<dataShare.DataShareHelper | undefined>(resolve => resolve(undefined)));
      when(mocker.mockFunc(conversationService, conversationService.buildInsertRcsMmsRow))(ArgumentMatchers.any)
        .afterReturn(new Promise<LooseObject>(resolve => resolve({})));
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: 0,
              abilityResult: 0
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve());
          }
        } as Object | Window.WindowStage);

      conversationService.dealInsertDraftData({}, {
        sendResults: [{
          telephone: '570977632'
        } as LooseObject],
        start_time: '',
        type: 'mms_send',
        isReceive: true,
        ownNumber: true,
        mmsPdu: true,
        endTime: '',
        expiresTime: '',
        isRcsType: 0,
      }, 0, (res: LooseObject) => {
        expect(res.initDatas[0].id).assertEqual(0);
      }, context);
    })

    it('ConversationService_dealInsertDraftData_length_0', 0, () => {
      conversationService.maxGroupId = 1;
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      mocker.mockFunc(conversationService, conversationService.deleteSmsMmsInfoByCondition);
      when(mocker.mockFunc(DataShareHelper.getInstance(),
        DataShareHelper.getInstance().initSmsDB))(ArgumentMatchers.any)
        .afterReturn(new Promise<dataShare.DataShareHelper | undefined>(resolve => resolve(undefined)));
      when(mocker.mockFunc(conversationService, conversationService.buildInsertRcsMmsRow))(ArgumentMatchers.any)
        .afterReturn(new Promise<LooseObject>(resolve => resolve({})));
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: 0,
              abilityResult: 0
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve());
          }
        } as Object | Window.WindowStage);

      conversationService.dealInsertDraftData({}, {
        sendResults: [],
        start_time: '',
        type: 'mms_send',
        isReceive: true,
        ownNumber: true,
        mmsPdu: true,
        endTime: '',
        expiresTime: '',
        isRcsType: 0,
      }, 0, (res: LooseObject) => {
        expect(res.code).assertEqual(-1);
      }, context);
    })

    it('ConversationService_dealInsertDraftData_fail', 0, () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      mocker.mockFunc(conversationService, conversationService.deleteSmsMmsInfoByCondition);
      when(mocker.mockFunc(DataShareHelper.getInstance(),
        DataShareHelper.getInstance().initSmsDB))(ArgumentMatchers.any)
        .afterReturn(new Promise<dataShare.DataShareHelper | undefined>(resolve => resolve(undefined)));
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              'code': -1,
              'abilityResult': 1
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve());
          }
        } as Object | Window.WindowStage);

      conversationService.dealInsertDraftData({
        content: 'xx'
      }, {
        sendResults: [{
          slotId: 1,
          sendStatus: 1,
          telephone: '11111'
        }],
        start_time: '',
        type: 'mms_send',
        isReceive: true,
        ownNumber: true,
        mmsPdu: true,
        endTime: '',
        expiresTime: '',
        isRcsType: 0
      }, 0, (res: LooseObject) => {
        expect(res.code).assertEqual(-1);
      }, context);
    })

    it('ConversationService_buildInsertRcsMmsRow', 0, async () => {
      let param: LooseObject = {
        content: ''
      };
      let actionData: LooseObject = {
        isRcsType: true,
        isSender: 1,
        totalSize: 0,
        isReceive: true,
        ownNumber: true,
        isNeedSendNotice: true,
        hasReport: '0',
        type: 'rcs',
        msgId: '0',
        isAdvancedSecurity: '',
        receiveState: '',
        failReceiveContext: '',
        isBlocked: 1,
        blockedReason: '',
        blockedSources: '',
        blockedType: '',
        blockedTypeText: ''
      };
      let sendResult: LooseObject = {
        slotId: 0,
        telephone: '9999',
        time: 0,
        sendStatus: 0,
      };
      when(mocker.mockFunc(SsmUtils, SsmUtils.formatPhoneNumber))()
        .afterReturn(new Promise<string>(resolve => resolve('9999')));
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let res: LooseObject =
        await conversationService.buildInsertRcsMmsRow(param, actionData, sendResult, 0, 0, context);
      expect(res.msg_state).assertEqual(0);
      mocker.clear(SsmUtils);
    })

    it('ConversationService_dealSendResults', 0, () => {
      when(mocker.mockFunc(TelephoneUtil, TelephoneUtil.judgeIsInfoMsg))(ArgumentMatchers.any)
        .afterReturn(true);
      when(mocker.mockFunc(TelephoneUtil, TelephoneUtil.dealTelephoneSort))(ArgumentMatchers.any)
        .afterReturn('8889');
      let res: LooseObject = conversationService.dealSendResults([{
        telephone: '8889',
        content: '',
        sendStatus: 1,
        time: null,
        isMessageSim: false
      }]);
      expect(res.smsType).assertEqual(1);
      mocker.clear(TelephoneUtil);
    })

    it('ConversationService_dealSendResults_sendStatus_2', 0, () => {
      when(mocker.mockFunc(TelephoneUtil, TelephoneUtil.judgeIsInfoMsg))(ArgumentMatchers.any)
        .afterReturn(false);
      when(mocker.mockFunc(TelephoneUtil, TelephoneUtil.dealTelephoneSort))(ArgumentMatchers.any)
        .afterReturn('8889');
      let res: LooseObject = conversationService.dealSendResults([{
        telephone: '8889',
        content: '',
        sendStatus: 2,
        time: 0,
        isMessageSim: true
      }]);
      expect(res.smsType).assertEqual(0);
      mocker.clear(TelephoneUtil);
    })

    it('ConversationService_updateSessionAndDetail_length_0', 0, () => {
      mocker.mockFunc(conversationService, conversationService.dealSendResults);
      conversationService.updateSessionAndDetail(mmsContext, false, {
        sendResults: []
      } as LooseObject, 0, '0', false);
      mocker.verify('dealSendResults', [[]]).never();
    })

    it('ConversationService_updateSessionAndDetail_length_1_sendStatus_2', 0, () => {
      EnhancedInfoTemporaryDataSource.getInstance().mapImageMsgIdToData.set('0', {
        clurSize: 0,
        totalSize: 0,
        isExistInfoInRcsInfoWithMsgId: false
      });
      let sendResult: LooseObject = [{
        sendStatus: 2
      }];
      when(mocker.mockFunc(conversationService, conversationService.dealSendResults))(ArgumentMatchers.any)
        .afterReturn({
          sendStatus: 0, content: ''
        });
      mocker.mockFunc(ConversationListService.getInstance(),
        ConversationListService.getInstance().updateSessionByCondition);
      conversationService.updateSessionAndDetail(mmsContext, false, {
        sendResults: sendResult
      } as LooseObject, 1, '0', true);
      mocker.verify('dealSendResults', [sendResult]).once();
      mocker.clear(ConversationListService.getInstance());
    })

    it('ConversationService_updateSessionAndDetail_length_1_sendStatus_0', 0, () => {
      EnhancedInfoTemporaryDataSource.getInstance().mapImageMsgIdToData.set('0', {
        clurSize: 0,
        totalSize: 0,
        isExistInfoInRcsInfoWithMsgId: true
      });
      let sendResult: LooseObject = [{
        sendStatus: 0
      }];
      when(mocker.mockFunc(conversationService, conversationService.dealSendResults))(ArgumentMatchers.any)
        .afterReturn({
          sendStatus: 0, content: ''
        });
      mocker.mockFunc(conversationService, conversationService.updateSmsMmsInfoByCondition);
      mocker.mockFunc(ConversationListService.getInstance(),
        ConversationListService.getInstance().updateSessionByCondition);
      conversationService.updateSessionAndDetail(mmsContext, false, {
        sendResults: sendResult
      } as LooseObject, 1, '0', false);
      mocker.verify('dealSendResults', [sendResult]).once();
      mocker.clear(ConversationListService.getInstance());
    })

    it('ConversationService_updateSessionAndDetail_length_1_sendStatus_9', 0, () => {
      EnhancedInfoTemporaryDataSource.getInstance().mapImageMsgIdToData.set('0', {
        clurSize: 0,
        totalSize: 0,
        isExistInfoInRcsInfoWithMsgId: false
      });
      let sendResult: LooseObject = [{
        sendStatus: 9
      }];
      when(mocker.mockFunc(conversationService, conversationService.dealSendResults))(ArgumentMatchers.any)
        .afterReturn({
          sendStatus: 0, content: ''
        });
      mocker.mockFunc(conversationService, conversationService.updateSmsMmsInfoByCondition);
      mocker.mockFunc(ConversationListService.getInstance(),
        ConversationListService.getInstance().updateSessionByCondition);
      conversationService.updateSessionAndDetail(mmsContext, true, {
        sendResults: sendResult
      } as LooseObject, 1, '0', undefined);
      mocker.verify('dealSendResults', [sendResult]).once();
      mocker.clear(ConversationListService.getInstance());
    })

    it('ConversationService_updateSessionAndDetail_length_1_sendStatus_10', 0, () => {
      EnhancedInfoTemporaryDataSource.getInstance().mapImageMsgIdToData.set('0', {
        clurSize: 0,
        totalSize: 0,
        isExistInfoInRcsInfoWithMsgId: false
      });
      let sendResult: LooseObject = [{
        sendStatus: 10
      }];
      when(mocker.mockFunc(conversationService, conversationService.dealSendResults))(ArgumentMatchers.any)
        .afterReturn({
          sendStatus: 0, content: ''
        });
      mocker.mockFunc(conversationService, conversationService.updateSmsMmsInfoByCondition);
      mocker.mockFunc(ConversationListService.getInstance(),
        ConversationListService.getInstance().updateSessionByCondition);
      conversationService.updateSessionAndDetail(mmsContext, false, {
        sendResults: sendResult
      } as LooseObject, 1, '0', undefined);
      mocker.verify('dealSendResults', [sendResult]).once();
      mocker.clear(ConversationListService.getInstance());
    })

    it('ConversationService_saveImage', 0, () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      conversationService.saveImage({}, (res: string) => {
        expect(res).assertEqual('saveImage function to be developed!');
      }, context);
    })

    it('ConversationService_gotoShare', 0, () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      conversationService.gotoShare({}, (res: string) => {
        expect(res).assertEqual('gotoShare function to be developed!');
      }, context);
    })

    it('ConversationService_dealContactsName_telephones_empty', 0, () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      mocker.mockFunc(ContactsService.getInstance(), ContactsService.getInstance().queryContactDataByCondition);
      conversationService.dealContactsName(mmsContext, [], {}, [], (res: LooseObject[]) => {
        expect(res.length).assertEqual(0);
      });
      mocker.clear(ContactsService.getInstance());
    })

    it('ConversationService_dealContactsName_fail1', 0, () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: -1
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve())
          }
        } as Object | Window.WindowStage);
      when(mocker.mockFunc(conversationService, conversationService.convertingMessageByGroup))(ArgumentMatchers.any)
        .afterReturn({
          'key': {
            telephone: '1111,2222', contactsNum: '1111', isFavorite: true
          },
          'key2': {
            telephone: '1111,2222', contactsNum: '1111', isFavorite: false
          }
        });
      conversationService.dealContactsName(mmsContext, ['5555'], {}, [], (res: LooseObject[]) => {
        expect(res.length).assertEqual(3);
      });
    })

    it('ConversationService_dealContactsName_fail2', 0, () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: 0,
              abilityResult: []
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve())
          }
        } as Object | Window.WindowStage);
      when(mocker.mockFunc(conversationService, conversationService.convertingMessageByGroup))(ArgumentMatchers.any)
        .afterReturn({});
      conversationService.dealContactsName(mmsContext, ['5555'], {}, [], (res: LooseObject[]) => {
        expect(res.length).assertEqual(0);
      });
    })

    it('ConversationService_dealContactsName_success', 0, () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: 0,
              abilityResult: [{
                displayName: '',
                detailInfo: '11111'
              }, {
                displayName: 'name',
                detailInfo: '222'
              }]
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve())
          }
        } as Object | Window.WindowStage);
      when(mocker.mockFunc(conversationService, conversationService.getGroupIdMap))(ArgumentMatchers.any)
        .afterReturn({});
      conversationService.dealContactsName(mmsContext, ['5555'], {}, [], (res: LooseObject[]) => {
        expect(res.length).assertEqual(0);
      });
    })

    it('ConversationService_getGroupIdMap', 0, () => {
      let resultList: LooseObject[] = [{
        telephone: '8888',
        telephoneFormat: '',
        name: 'name',
        groupId: '0',
        nameFormatter: ''
      }, {
        telephone: '8888',
        telephoneFormat: '',
        name: 'name',
        groupId: '0',
        nameFormatter: ''
      }, {
        telephone: '8888',
        telephoneFormat: '',
        name: 'name',
        groupId: '1',
        nameFormatter: ''
      }];
      let telephoneMap: Map<string, LooseObject> = new Map();
      let res: LooseObject = conversationService.getGroupIdMap(resultList, telephoneMap);
      expect(res['0'].telephone).assertEqual('8888,8888');
    })

    it('ConversationService_getGroupIdMap1', 0, () => {
      let resultList: LooseObject[] = [{
        telephone: '8888',
        telephoneFormat: '',
        name: 'name',
        groupId: '0',
        nameFormatter: ''
      }];
      let telephoneMap: Map<string, LooseObject> = new Map();
      telephoneMap.set('8888', {});
      let res: LooseObject = conversationService.getGroupIdMap(resultList, telephoneMap);
      expect(res['0'].telephone).assertEqual('8888');
    })

    it('ConversationService_convertingMessageByGroup', 0, () => {
      let resultList: LooseObject[] = [{
        telephone: '8888',
        telephoneFormat: '',
        name: 'name',
        groupId: '0',
        nameFormatter: ''
      }, {
        telephone: '8888',
        telephoneFormat: '',
        name: 'name',
        groupId: '0',
        nameFormatter: ''
      }, {
        telephone: '8888',
        telephoneFormat: '',
        name: 'name',
        groupId: '1',
        nameFormatter: ''
      }];
      let res: LooseObject = conversationService.convertingMessageByGroup(resultList);
      expect(res['0'].telephone).assertEqual('8888');
    })

    it('ConversationService_statisticsUnreadNotify', 0, () => {
      let callback: Function = (res: number) => {
        expect(res).assertEqual(0);
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: 0,
              abilityResult: 0
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve())
          }
        } as Object | Window.WindowStage);
      conversationService.statisticsUnreadNotify(callback, context);
    })

    it('ConversationService_statisticsUnreadNotify_fail', 0, () => {
      let callback: Function = (res: number) => {
        expect(res).assertEqual(0);
      };
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: -1,
              abilityResult: 0
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve())
          }
        } as Object | Window.WindowStage);
      conversationService.statisticsUnreadNotify(callback, context);
    })

    it('ConversationService_insertMmsInfoList', 0, () => {
      let smsRes: LooseObject = {
        initDatas: [{
          rcs_id: 0,
          id: 0
        }]
      };
      let mmsSource: Array<Mms> = [{
        size: '0',
        duration: '0',
        type: 0,
        path: '',
        text: ''
      } as Mms];
      let res = false;
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            res = true;
            callBack ? callBack({
              code: 0,
              abilityResult: []
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve())
          }
        } as Object | Window.WindowStage);
      conversationService.insertMmsInfoList(smsRes, mmsSource, context);
      expect(res).assertTrue();
    })

    it('ConversationService_insertMmsInfoList1', 0, () => {
      let smsRes: LooseObject = {
        initDatas: [{
          rcs_id: undefined,
          id: 0
        }]
      };
      let mmsSource: Array<Mms> = [{
        duration: '0',
        type: 0,
        path: '',
        text: ''
      } as Mms]
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let res = false;
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            res=true;
            callBack ? callBack({
              code: -1,
              abilityResult: []
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve())
          }
        } as Object | Window.WindowStage);
      conversationService.insertMmsInfoList(smsRes, mmsSource, context);
      expect(res).assertTrue();
    })

    it('ConversationService_insertMmsInfoList2', 0, () => {
      let smsRes: LooseObject = {
        initDatas: [{
          rcs_id: 2,
          id: 0
        }]
      };
      let mmsSource: Array<Mms> = [{
        size: '0',
        duration: '0',
        type: 0,
        path: '',
        text: ''
      } as Mms]
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let res = false;
      when(mocker.mockFunc(conversationService, conversationService.insertMmsInfo))(ArgumentMatchers.any)
        .afterAction(() => {
          res = true;
        });
      conversationService.insertMmsInfoList(smsRes, mmsSource, context);
      expect(res).assertTrue();
    })

    it('ConversationService_insertMmsInfo_getObject', 0, () => {
      let valueBucket: ValuesBucket = {};
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
            return new Promise<void>(resolve => resolve())
          }
        } as Object | Window.WindowStage);

      conversationService.insertMmsInfo(valueBucket, callback, mmsContext);
    })

    it('ConversationService_insertMmsInfo_insertMmsInfo', 0, () => {
      let valueBucket: ValuesBucket = {};
      let callback: Function = (res: LooseObject) => {
        expect(res.code).assertEqual(-1);
      };
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn(null);
      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(mmsContext)
        .afterReturn(undefined);

      conversationService.insertMmsInfo(valueBucket, callback, mmsContext);
    })

    it('ConversationService_queryMmsInfoResponse', 0, () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let callback: Function = (res: LooseObject) => {
        expect(res.code).assertEqual(-1);
      };
      when(mocker.mockFunc(conversationService, conversationService.queryMmsInfo))(ArgumentMatchers.any)
        .afterAction(() => {
          callback({
            code: -1
          } as LooseObject)
        });
      mocker.mockFunc(conversationService, conversationService.queryMmsInfoResult);
      conversationService.queryMmsInfoResponse([{
        rcsId: 0,
        msgId: '1'
      }], callback, context);
    })

    it('ConversationService_queryMmsInfoResponse1', 0, () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let callback: Function = (res: LooseObject) => {
        expect(res.code).assertEqual(-1);
      };
      when(mocker.mockFunc(conversationService, conversationService.queryMmsInfo))(ArgumentMatchers.any)
        .afterAction(() => {
          callback({
            code: -1
          } as LooseObject)
        });
      mocker.mockFunc(conversationService, conversationService.queryMmsInfoResult);
      conversationService.queryMmsInfoResponse([{
        rcsId: 0,
        msgId: 1
      }], callback, context);
    })

    it('ConversationService_queryMmsInfoResponse2', 0, () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      let callback: Function = (res: LooseObject) => {
        expect(res.code).assertEqual(-1);
      };
      when(mocker.mockFunc(conversationService, conversationService.queryMmsInfo))(ArgumentMatchers.any)
        .afterAction(() => {
          callback({
            code: -1
          } as LooseObject)
        });
      mocker.mockFunc(conversationService, conversationService.queryMmsInfoResult);
      conversationService.queryMmsInfoResponse([{
        rcsId: 1,
        msgId: 1
      }], callback, context);
    })

    it('ConversationService_queryMmsInfoResult', 0, () => {
      let smsData: Array<LooseObject> = [{
        msgType: 1,
        rcsType: 1,
        msgId: 1,
        type: 2,
        mmsList: [],
        rcsId: 1
      } as LooseObject, {
        msgType: 1,
        rcsType: 1,
        msgId: 0,
        type: 2,
        mmsList: [],
        rcsId: 2
      } as LooseObject, {
        msgType: 0,
        rcsType: 1,
        msgId: 0,
        type: 2,
        mmsList: [],
        rcsId: 0
      } as LooseObject];
      let res: queryMmsInfoResult = {
        abilityResult: [{
          'msgId': 0,
          'rcsType': 0,
          'type': 2,
          'path': 'VIDEO.mp4',
          'imagePath': '',
          'rcsId': 1
        } as Record<string, string | number>, {
          'msgId': 1,
          'rcsType': 1,
          'type': 2,
          'path': 'xxx.mp4',
          'imagePath': '',
          'rcsId': 0
        } as Record<string, string | number>, {
          'msgId': 1,
          'rcsType': 1,
          'type': 1,
          'path': 'xxx.mp4',
          'imagePath': '',
          'rcsId': 0
        } as Record<string, string | number>]
      } as queryMmsInfoResult;
      conversationService.queryMmsInfoResult(smsData, res);
      expect(res.abilityResult[0].msgId).assertEqual(0);
    })

    it('ConversationService_queryMmsInfo_getObject', 0, () => {
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
            return new Promise<void>(resolve => resolve())
          }
        } as Object | Window.WindowStage);

      conversationService.queryMmsInfo([], [], callback, mmsContext);
    })

    it('ConversationService_queryMmsInfo_queryMmsInfo', 0, () => {
      let callback: Function = (res: LooseObject) => {
        expect(res.code).assertEqual(-1);
      };
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn(null);
      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(mmsContext)
        .afterReturn(undefined);

      conversationService.queryMmsInfo([], [], callback, mmsContext);
    })

    it('ConversationService_deleteMmsInfoByCondition_getObject', 0, () => {
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: 0
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve())
          }
        } as Object | Window.WindowStage);
      mocker.verify('getObject', ['DataWorker']).never();

      conversationService.deleteMmsInfoByCondition(mmsContext, {}, null);
    })

    it('ConversationService_deleteMmsInfoByCondition_getObject_context_null', 0, () => {
      let callback: Function = (res: LooseObject) => {
        expect(res.code).assertEqual(0);
      };
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('mmsContext')
        .afterReturn(mmsContext);
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: 0
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve())
          }
        } as Object | Window.WindowStage);

      conversationService.deleteMmsInfoByCondition(mmsContext, {}, callback);
    })

    it('ConversationService_deleteMmsInfoByCondition_deleteMmsInfoByCondition', 0, () => {
      let callback: Function = (res: LooseObject) => {
        expect(res.code).assertEqual(-1);
      };
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn(null);
      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(mmsContext)
        .afterReturn(undefined);

      conversationService.deleteMmsInfoByCondition(mmsContext, {}, callback);
    })

    it('ConversationService_checkWhetherHasMms', 0, () => {
      let res = conversationService.checkWhetherHasMms([{
        msgType: 1
      }, {
        msgType: 0
      }]);
      expect(res).assertTrue();
    })

    it('ConversationService_insertNoReceiverDraft_success', 0, () => {
      conversationService.maxGroupId = 1;
      let res = false;
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            res = true;
            callBack ? callBack({
              code: 0,
              abilityResult: '1'
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve())
          }
        } as Object | Window.WindowStage);
      when(mocker.mockFunc(ConversationListService.getInstance(),
        ConversationListService.getInstance().dealSendResults))(ArgumentMatchers.any)
        .afterReturn({
          smsType: 1,
          content: ''
        });
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('mmsContext')
        .afterReturn(mmsContext);
      when(mocker.mockFunc(ConversationService.getInstance(),
        ConversationService.getInstance().insertMmsInfoList))(ArgumentMatchers.any)
        .afterAction(() => {
          expect(res).assertTrue();
        });
      conversationService.insertNoReceiverDraft(mmsContext, {
        isReceive: false,
        ownNumber: '',
        start_time: '0',
        endTime: '',
        expiresTime: '',
        isMms: null,
        isSender: null,
        hasReport: null,
        isAdvancedSecurity: null,
        isBlocked: 1,
        blockedReason: '',
        blockedSources: '',
        blockedType: 0,
        blockedTypeText: ''
      });
    })

    it('ConversationService_insertNoReceiverDraft_fail', 0, () => {
      conversationService.maxGroupId = 1;
      let res = false;
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            res = true;
            callBack ? callBack({
              code: -1,
              abilityResult: '1'
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve())
          }
        } as Object | Window.WindowStage);
      conversationService.insertNoReceiverDraft(mmsContext, {});
      expect(res).assertTrue();
    })

    it('ConversationService_queryMessageNoReceiverDraft_fail', 0, () => {
      let res = false;
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            res = true;
            callBack ? callBack({
              code: -1,
              abilityResult: '1'
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve())
          }
        } as Object | Window.WindowStage);
      conversationService.queryMessageNoReceiverDraft(mmsContext, {}, () => {
      }, 0);
      expect(res).assertTrue();
    })

    it('ConversationService_queryMessageNoReceiverDraft_success', 0, () => {
      let res = false;
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            res = true;
            callBack ? callBack({
              code: 0,
              abilityResult: [{
                receiverNumber: '',
                senderNumber: ''
              }, {
                receiverNumber: '666666',
                senderNumber: '555555'
              }]
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve())
          }
        } as Object | Window.WindowStage);
      when(mocker.mockFunc(conversationService, conversationService.queryMessageDetailResultAll))(ArgumentMatchers.any)
        .afterAction(() => {
          expect(res).assertTrue();
        });
      conversationService.queryMessageNoReceiverDraft(mmsContext, {}, () => {
      }, 0);
    })

    it('ConversationService_queryCtFromMmsInfo', 0, () => {
      let res = conversationService.queryCtFromMmsInfo({
        mmsList: [{
          ct: ''
        }]
      } as LooseObject, {});
      expect(JSON.stringify(res)).assertEqual('{}');
    })

    it('ConversationService_buildInsertSmsMmsRowValueBucket', 0, () => {
      let res = conversationService.buildInsertSmsMmsRowValueBucket(0, 0);
      expect(res.slot_id).assertEqual(0);
    })

    it('ConversationService_convertConversationListResult', 0, () => {
      let context = {
      resourceManager: {
        getStringSync: (resource: Resource, ...args: (string | number)[]): string => ''
      } as resourceManager.ResourceManager
    } as Context;
      let item: LooseObject = {
        isRcs: 0,
        msgId: 0,
        rcsId: 0,
        msgContent: 'position：2\nlatitudeAndLongitude=2',
        detectResContent: '',
        smsType: 0,
        isCollect: true,
        isStared: true,
        msgType: 0,
        isReport: true,
        senderNumbe: '',
        msgState: 0,
        receiveState: 0,
        failReceiveContext: '',
        slotId: 0,
        msgCode: '',
        startTime: 0,
        groupId: 0,
        isSender: 0,
        isAdvancedSecurity: 1,
        isSendReport: 0,
        mmsPdu: '',
        expiresTime: 0,
        rcsType: 0,
        clurSize: 0,
        totalSize: 0,
        riskUrlBody: '',
        isMsm: false
      };
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('mmsContext')
        .afterReturn({
          resourceManager: {
            getStringSync: (resId: number): string => 'position：'
          } as resourceManager.ResourceManager
        } as Object | Window.WindowStage)
      let res = conversationService.convertConversationListResult(context, item, 0, 0);
      expect(res.msgCode).assertEqual('');

      item.isCollect = false;
      item.isRead = 0;
      item.msgType = 1;
      item.rcsType = 1;
      item.isSendReport = 0;
      item.isMsm = true;
      item.isRcs = 0;
      when(mocker.mockFunc(MmsUtil, MmsUtil.getMmsSourceFromRequest))(ArgumentMatchers.any).afterReturn(1);
      when(mocker.mockFunc(MmsUtil, MmsUtil.getMmsContentType))(ArgumentMatchers.any).afterReturn(1);
      res = conversationService.convertConversationListResult(context, item, 0, 0);
      expect(res.msgCode).assertEqual('');

      item.isSendReport = 1;
      item.isMsm = true;
      item.isRcs = 1;
      item.rcsType = 1;
      when(mocker.mockFunc(MmsUtil, MmsUtil.getRcsSourceFromRequest))(ArgumentMatchers.any).afterReturn(1);
      res = conversationService.convertConversationListResult(context, item, 0, 0);
      expect(res.msgCode).assertEqual('');

      item.isSendReport = 1;
      item.isMsm = true;
      item.isRcs = 1;
      item.rcsType = 4;
      when(mocker.mockFunc(MmsUtil, MmsUtil.getRcsSourceFromRequest))(ArgumentMatchers.any).afterReturn(1);
      res = conversationService.convertConversationListResult(context, item, 0, 0);
      expect(res.msgCode).assertEqual('');

      item.isSendReport = 1;
      item.isMsm = true;
      item.isRcs = 1;
      item.rcsType = 8;
      when(mocker.mockFunc(MmsUtil, MmsUtil.getRcsSourceFromRequest))(ArgumentMatchers.any).afterReturn(1);
      res = conversationService.convertConversationListResult(context, item, 0, 0);
      expect(res.msgCode).assertEqual('');

      item.isSendReport = 1;
      item.isMsm = true;
      item.isRcs = 1;
      item.rcsType = 2;
      item.isReceive = true;
      when(mocker.mockFunc(MmsUtil, MmsUtil.getRcsSourceFromRequest))(ArgumentMatchers.any).afterReturn(1);
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('mmsContext')
        .afterReturn({
          resourceManager: {
            getStringSync: (resId: number): string => 'xx：xx'
          } as resourceManager.ResourceManager
        } as Object | Window.WindowStage);
      res = conversationService.convertConversationListResult(context, item, 0, 0);
      expect(res.msgCode).assertEqual('');
      mocker.clear(MmsUtil);
    })

    it('ConversationService_queryNotDownloadInfo_getObject', 0, () => {
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
            return new Promise<void>(resolve => resolve())
          }
        } as Object | Window.WindowStage);

      conversationService.queryNotDownloadInfo({}, callback, mmsContext);
    })

    it('ConversationService_queryNotDownloadInfo_queryNotDownloadInfo', 0, () => {
      let callback: Function = (res: LooseObject) => {
        expect(res.code).assertEqual(-1);
      };
      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(mmsContext)
        .afterReturn(undefined);

      conversationService.queryNotDownloadInfo({}, callback, mmsContext);
    })

    it('ConversationService_queryMmsNotDownloadInfo_success', 0, () => {
      let callback: Function = (res: LooseObject) => {
        expect(res.id).assertEqual(1);
      };
      let mySet: DataShareResultSet = new MySet();
      mySet.rowCount = 1;

      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: 0,
              abilityResult: [{
                id: 1
              } as LooseObject]
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve());
          }
        } as Object | Window.WindowStage);

      conversationService.queryMmsNotDownloadInfo({}, callback, mmsContext);
    })

    it('ConversationService_queryMmsNotDownloadInfo_fail', 0, () => {
      let callback: Function = (res: LooseObject) => {
        expect(res).assertUndefined();
      };

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
        } as Object | Window.WindowStage);

      conversationService.queryMmsNotDownloadInfo({}, callback, mmsContext);
    })

    it('ConversationService_updateSmsIsReadBySessionId', 0, () => {
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
        } as Object | Window.WindowStage);
      conversationService.updateSmsIsReadBySessionId(mmsContext, {}, (res: LooseObject) => {
        expect(res.code).assertEqual(0);
      });
    })

    it('ConversationService_updateSmsIsReadBySessionId_callback_null', 0, () => {
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('mmsContext')
        .afterReturn(mmsContext);
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
        } as Object | Window.WindowStage);
      mocker.verify('getObject', ['mmsContext']).never();
      conversationService.updateSmsIsReadBySessionId(mmsContext, {}, null);
    })

    it('ConversationService_updateSmsIsReadBySessionId_fail', 0, () => {
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('DataWorker')
        .afterReturn(null);
      when(mocker.mockFunc(DataShareHelper.getInstance(), DataShareHelper.getInstance().initSmsDB))(mmsContext)
        .afterReturn(undefined);
      mocker.verify('getObject', ['mmsContext']).never();
      conversationService.updateSmsIsReadBySessionId(mmsContext, {}, (res: LooseObject) => {
        expect(res.code).assertEqual(-1);
      });
    })

    it('ConversationService_batchUpdateMsgContentByRcsIds', 0, async () => {
      let res: number = 0;
      let conversationModel: ConversationModel = (ConversationService.getInstance() as object)['conversationModel'];
      when(mocker.mockFunc(conversationModel, conversationModel.batchUpdateSmsMmsInfo))(ArgumentMatchers.any).afterReturn(res);


      let rcsInfoMap = new Map<number, string>();
      rcsInfoMap.set(1, 'content1');
      rcsInfoMap.set(2, 'content2');

      let result = await conversationService.batchUpdateMsgContentByRcsIds(rcsInfoMap, mmsContext);
      expect(result).assertEqual(0);

    })

  })
}