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
import ConversationController, { groupIdsInfos,
  mmsListType,
  selectContactType } from '../../../../main/ets/pages/conversation/conversationController';
import { ActionData, DraftModel, DraftUtils } from '../../../../main/ets/utils/DraftUtils'
import { Mms } from '../../../../main/ets/utils/TypesUtils';
import { DTGlobalContext } from '../../testability/TestAbility';
import common from '../../../../main/ets/data/commonData';
import ConversationListService from '../../../../main/ets/service/ConversationListService';
import LooseObject from '../../../../main/ets/data/LooseObject';
import ConversationService from '../../../../main/ets/service/ConversationService';
import { ValuesBucket } from '@kit.ArkData';
import { GlobalContext } from '../../../../main/ets/MainAbility/GlobalHelper';
import ConversationListController from '../../../../main/ets/pages/conversationlist/conversationListController';

export default function DraftUtilsTest() {
  describe('DraftUtilsTest', () => {
    let emptyContext: Context;
    let context: Context = DTGlobalContext.getContext().getObject('mmsContext') as Context;

    it('DraftUtilsTest_saveDraftTest', 0, () => {
      let draftUtils = DraftUtils.getInstance();
      draftUtils.saveDraft(emptyContext);
      let item: DraftModel = {
        initialDraftText: '',
        initialDraftAttachments: [],
        initialSelectContacts: [],
        isHasSetValueForInitialDraftAttachments: false,
        isHasSetValueForInitialDraftText: false,
        isHasGetContacts: false,
        hasGetContactsThreadID: 0,
        needDeleteSession: {
          isLoaded: false, isNeedDelete: false
        },
        attachmentAreaHasSetValue: false,
        isForwardingDraftModel: false,
        newCreatDrafts: [],
        mmsList: [],
        actionData: new ActionData
      };
      let arr: DraftModel[] = [item];
      let mms: Mms = {
        duration: '',
        type: 0,
        path: '',
        name: ''
      };
      let mmsArr: Mms[] = [mms, mms, mms];
      let mmsArr1: Mms[] = [mms, mms, mms, mms];
      let selectContacts: selectContactType = {
        telephone: '',
        telephoneFormat: '',
        contactName: ''
      };
      let selectContactsArr = [selectContacts, selectContacts];
      let selectContactsArr1 = [selectContacts, selectContacts, selectContacts];
      draftUtils.draftModelArray = arr;
      draftUtils.saveDraft(context);

      item.actionData.isNewMsg = true;
      item.actionData.content = '';
      item.actionData.mmsSource = [];
      draftUtils.draftModelArray = arr;
      draftUtils.saveDraft(context);

      item.actionData.threadId = 1;
      draftUtils.draftModelArray = arr;
      draftUtils.saveDraft(context);

      item.actionData.threadId = 0;
      item.actionData.mmsSource = mmsArr;
      item.actionData.selectContacts = [];
      draftUtils.draftModelArray = arr;
      draftUtils.saveDraft(context);

      item.actionData.selectContacts = selectContactsArr;
      item.actionData.content = '';
      item.actionData.mmsSource = [];
      draftUtils.draftModelArray = arr;
      draftUtils.saveDraft(context);

      item.actionData.content = 'test';
      item.isHasGetContacts = true;
      item.hasGetContactsThreadID = 0;
      item.initialSelectContacts = selectContactsArr1;
      draftUtils.draftModelArray = arr;
      draftUtils.saveDraft(context);

      item.hasGetContactsThreadID = 1;
      draftUtils.draftModelArray = arr;
      draftUtils.saveDraft(context);

      item.isHasGetContacts = false;
      item.actionData.threadId = 1;
      draftUtils.draftModelArray = arr;
      draftUtils.saveDraft(context, () => {
      });

      item.actionData.selectContacts.length = 0;
      item.actionData.content = '';
      item.actionData.mmsSource.length = 0;
      draftUtils.draftModelArray = arr;
      draftUtils.saveDraft(context);

      item.actionData.isNewMsg = false;
      item.actionData.content = '';
      item.actionData.mmsSource = mmsArr;
      item.needDeleteSession.isLoaded = true;
      item.needDeleteSession.isNeedDelete = true;
      draftUtils.draftModelArray = arr;
      draftUtils.saveDraft(context);

      item.actionData.mmsSource = [];
      draftUtils.draftModelArray = arr;
      draftUtils.saveDraft(context);

      item.needDeleteSession.isLoaded = false;
      draftUtils.draftModelArray = arr;
      draftUtils.saveDraft(context);

      item.initialDraftAttachments = mmsArr;
      item.attachmentAreaHasSetValue = false;
      draftUtils.draftModelArray = arr;
      draftUtils.saveDraft(context);

      item.initialDraftAttachments = [];
      item.actionData.isDraft = true;
      item.isHasSetValueForInitialDraftText = true;
      draftUtils.draftModelArray = arr;
      draftUtils.saveDraft(context);

      item.actionData.isDraft = false;
      draftUtils.draftModelArray = arr;
      draftUtils.saveDraft(context);

      draftUtils.draftModelArray = [];
      draftUtils.saveDraft(context, undefined);

      item.initialDraftAttachments = mmsArr1;
      draftUtils.draftModelArray = arr;
      let res = draftUtils.saveDraft(context);
      expect(res === undefined).assertTrue();
    })

    it('DraftUtilsTest_saveDraftTest_mms_type_10', 0, () => {
      let draftUtils = DraftUtils.getInstance();
      (draftUtils as object)['rcsMapStatus'] = 2;
      let selectContact: selectContactType = {
        telephone: '12306',
        telephoneFormat: '1-1-1',
        contactName: 'text'
      };
      let data = new ActionData();
      data.threadId = 1;
      data.groupId = 7;
      data.isDraft = false;
      data.isNewMsg = true;
      data.content = 'DraftText';
      data.mmsSource = [{
        duration: '',
        type: 10,
        path: '',
        name: ''
      }];
      data.selectContacts = [selectContact];
      let draftModel: DraftModel = {
        isHasGetContacts: true,
        initialDraftText: 'DraftText',
        initialDraftAttachments: [],
        initialSelectContacts: [],
        isHasSetValueForInitialDraftAttachments: false,
        isHasSetValueForInitialDraftText: false,
        hasGetContactsThreadID: 1,
        needDeleteSession: {
          isLoaded: true, isNeedDelete: true
        },
        attachmentAreaHasSetValue: false,
        isForwardingDraftModel: false,
        newCreatDrafts: [],
        mmsList: [],
        actionData: data
      }
      draftUtils.draftModelArray = [draftModel];
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(ConversationListService, ConversationListService.getInstance))().afterReturn({
        insertSessionDraft: (actionData: LooseObject, callback: Function, context: Context) => {
          callback()
        }
      })
      draftUtils.saveDraft(context, () => {}, true, true);
      expect(context).not().assertUndefined();
      mocker.clear(ConversationListService);
    })

    it('DraftUtilsTest_saveDraftTest_mms_type_10_deleteDraft_groupId_1_callback_undefined', 0, () => {
      let draftUtils = DraftUtils.getInstance();
      (draftUtils as object)['rcsMapStatus'] = 2;
      let selectContact: selectContactType = {
        telephone: '12306',
        telephoneFormat: '1-1-1',
        contactName: 'text'
      };
      let data = new ActionData();
      data.threadId = 1;
      data.groupId = 7;
      data.isDraft = true;
      data.isNewMsg = true;
      data.content = 'DraftText';
      data.mmsSource = [{
        duration: '',
        type: 10,
        path: '',
        name: ''
      }];
      data.selectContacts = [selectContact];
      let draftModel: DraftModel = {
        isHasGetContacts: true,
        initialDraftText: 'DraftText',
        initialDraftAttachments: [],
        initialSelectContacts: [],
        isHasSetValueForInitialDraftAttachments: false,
        isHasSetValueForInitialDraftText: false,
        hasGetContactsThreadID: 1,
        needDeleteSession: {
          isLoaded: true, isNeedDelete: true
        },
        attachmentAreaHasSetValue: false,
        isForwardingDraftModel: false,
        newCreatDrafts: [],
        mmsList: [],
        actionData: data
      }
      draftUtils.draftModelArray = [draftModel];
      AppStorage.setOrCreate('IsChangeDraft', false);
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(ConversationListService, ConversationListService.getInstance))().afterReturn({
        insertSessionDraft: (actionData: LooseObject, callback: Function, context: Context) => {
          callback()
        },
        updateSessionByCondition: (context: Context, actionData: LooseObject, valueBucket: ValuesBucket,
          callback: Function | null, needUpdateSessionList?: boolean) => {
          if (callback) {
            callback()
          }
        }
      });
      when(mocker.mockFunc(ConversationService.getInstance(), ConversationService.getInstance().deleteSmsMmsInfoByCondition))()
        .afterReturnNothing();
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().setObject))(ArgumentMatchers.any).afterReturnNothing();
      when(mocker.mockFunc(ConversationListController,
        ConversationListController.getInstance))(ArgumentMatchers.any).afterReturn({
        refreshConversationListData: (context: Context) => {},
        lastIndex: -1
      }
      );
      when(mocker.mockFunc(ConversationController, ConversationController.getInstance))()
        .afterReturn({ draftModel: draftModel, textValue: '', draftContent: '' });
      draftUtils.saveDraft(context, undefined, false, true);
      expect((draftUtils as object)['rcsMapStatus']).assertLess(2);
      mocker.clear(ConversationService.getInstance());
      mocker.clear(ConversationListService);
      mocker.clear(ConversationController);
      mocker.clear(GlobalContext.getContext());
      mocker.clear(ConversationListController);
      AppStorage.clear();
    })

    it('DraftUtilsTest_saveDraftTest_mms_type_10_deleteDraft_groupId_1', 0, () => {
      let draftUtils = DraftUtils.getInstance();
      (draftUtils as object)['rcsMapStatus'] = 2;
      let selectContact: selectContactType = {
        telephone: '12306',
        telephoneFormat: '1-1-1',
        contactName: 'text'
      };
      let data = new ActionData();
      data.threadId = 1;
      data.groupId = 7;
      data.isDraft = true;
      data.isNewMsg = true;
      data.content = 'DraftText';
      data.mmsSource = [{
        duration: '',
        type: 10,
        path: '',
        name: ''
      }];
      data.selectContacts = [selectContact];
      let draftModel: DraftModel = {
        isHasGetContacts: true,
        initialDraftText: 'DraftText',
        initialDraftAttachments: [],
        initialSelectContacts: [],
        isHasSetValueForInitialDraftAttachments: false,
        isHasSetValueForInitialDraftText: false,
        hasGetContactsThreadID: 1,
        needDeleteSession: {
          isLoaded: true, isNeedDelete: true
        },
        attachmentAreaHasSetValue: false,
        isForwardingDraftModel: false,
        newCreatDrafts: [],
        mmsList: [],
        actionData: data
      }
      draftUtils.draftModelArray = [draftModel];
      AppStorage.setOrCreate('IsChangeDraft', false);
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(ConversationListService, ConversationListService.getInstance))().afterReturn({
        insertSessionDraft: (actionData: LooseObject, callback: Function, context: Context) => {
          callback()
        },
        updateSessionByCondition: (context: Context, actionData: LooseObject, valueBucket: ValuesBucket,
          callback: Function | null, needUpdateSessionList?: boolean) => {
          if (callback) {
            callback()
          }
        }
      });
      when(mocker.mockFunc(ConversationService.getInstance(), ConversationService.getInstance().deleteSmsMmsInfoByCondition))()
        .afterReturnNothing();
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().setObject))(ArgumentMatchers.any).afterReturnNothing();
      when(mocker.mockFunc(ConversationListController,
        ConversationListController.getInstance))(ArgumentMatchers.any).afterReturn({
        refreshConversationListData: (context: Context) => {},
        lastIndex: -1
      }
      );
      when(mocker.mockFunc(ConversationController, ConversationController.getInstance))()
        .afterReturn({ draftModel: draftModel, textValue: '', draftContent: '' });
      draftUtils.saveDraft(context, () => {}, true, true);
      expect((draftUtils as object)['rcsMapStatus']).assertLess(2);
      mocker.clear(ConversationService.getInstance());
      mocker.clear(ConversationListService);
      mocker.clear(ConversationController);
      mocker.clear(GlobalContext.getContext());
      mocker.clear(ConversationListController);
      AppStorage.clear();
    })

    it('DraftUtilsTest_saveDraftTest_mms_type_10_callback_undefined_isWindowStageSave_true', 0, () => {
      let draftUtils = DraftUtils.getInstance();
      (draftUtils as object)['rcsMapStatus'] = 2;
      let selectContact: selectContactType = {
        telephone: '12306',
        telephoneFormat: '1-1-1',
        contactName: 'text'
      };
      let data = new ActionData();
      data.threadId = 1;
      data.groupId = 7;
      data.isDraft = false;
      data.isNewMsg = true;
      data.content = '';
      data.mmsSource = [{
        duration: '',
        type: 0,
        path: '',
        name: ''
      }];
      data.selectContacts = [selectContact];
      let draftModel: DraftModel = {
        isHasGetContacts: true,
        initialDraftText: 'DraftText',
        initialDraftAttachments: [
          {
            duration: '',
            type: 0,
            path: 'path1',
            name: ''
          }
        ],
        initialSelectContacts: [selectContact],
        isHasSetValueForInitialDraftAttachments: false,
        isHasSetValueForInitialDraftText: false,
        hasGetContactsThreadID: 1,
        needDeleteSession: {
          isLoaded: true, isNeedDelete: true
        },
        attachmentAreaHasSetValue: false,
        isForwardingDraftModel: false,
        newCreatDrafts: [],
        mmsList: [],
        actionData: data
      }
      draftUtils.draftModelArray = [draftModel];
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(ConversationListService, ConversationListService.getInstance))().afterReturn({
        insertSessionDraft: (actionData: LooseObject, callback: Function, context: Context) => {
          callback()
        }
      });
      draftUtils.saveDraft(context, undefined, false, true);
      expect((draftUtils as object)['rcsMapStatus']).assertLess(2);
      mocker.clear(ConversationListService);
      AppStorage.clear();
    })

    it('DraftUtilsTest_saveDraftTest_mms_type_10_callback_undefined_isDraft_true_groupId_1', 0, () => {
      let draftUtils = DraftUtils.getInstance();
      (draftUtils as object)['rcsMapStatus'] = 2;
      let selectContact: selectContactType = {
        telephone: '12306',
        telephoneFormat: '1-1-1',
        contactName: 'text'
      };
      let data = new ActionData();
      data.threadId = 1;
      data.groupId = 1;
      data.isDraft = false;
      data.isNewMsg = true;
      data.content = 'content';
      data.mmsSource = [{
        duration: '',
        type: 10,
        path: '',
        name: ''
      }];
      data.selectContacts = [selectContact];
      let draftModel: DraftModel = {
        isHasGetContacts: true,
        initialDraftText: 'DraftText',
        initialDraftAttachments: [],
        initialSelectContacts: [selectContact],
        isHasSetValueForInitialDraftAttachments: false,
        isHasSetValueForInitialDraftText: false,
        hasGetContactsThreadID: 1,
        needDeleteSession: {
          isLoaded: true, isNeedDelete: true
        },
        attachmentAreaHasSetValue: false,
        isForwardingDraftModel: false,
        newCreatDrafts: [],
        mmsList: [],
        actionData: data
      }
      draftUtils.draftModelArray = [draftModel];
      AppStorage.setOrCreate('IsChangeDraft', false);
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(ConversationListService, ConversationListService.getInstance))().afterReturnNothing();
      when(mocker.mockFunc(ConversationService, ConversationService.getInstance))().afterReturn({
        deleteSmsMmsInfoByCondition: (context: Context, actionData: LooseObject, callback: Function) => {
          callback()
        }
      });
      draftUtils.saveDraft(context, undefined, false, true);
      expect((draftUtils as object)['rcsMapStatus']).assertLess(2);
      mocker.clear(ConversationListService);
      mocker.clear(ConversationService);
      AppStorage.clear();
    })

    it('DraftUtilsTest_saveDraftTest_mms_callback_undefined_isDraft_true_groupId_1_content_empty', 0, () => {
      let draftUtils = DraftUtils.getInstance();
      (draftUtils as object)['rcsMapStatus'] = 2;
      let selectContact: selectContactType = {
        telephone: '12306',
        telephoneFormat: '1-1-1',
        contactName: 'text'
      };
      let data = new ActionData();
      data.threadId = 1;
      data.groupId = 1;
      data.isDraft = false;
      data.isNewMsg = true;
      data.content = '';
      data.mmsSource = [];
      data.selectContacts = [selectContact];
      let draftModel: DraftModel = {
        isHasGetContacts: true,
        initialDraftText: 'DraftText',
        initialDraftAttachments: [],
        initialSelectContacts: [selectContact],
        isHasSetValueForInitialDraftAttachments: false,
        isHasSetValueForInitialDraftText: false,
        hasGetContactsThreadID: 1,
        needDeleteSession: {
          isLoaded: true, isNeedDelete: true
        },
        attachmentAreaHasSetValue: false,
        isForwardingDraftModel: false,
        newCreatDrafts: [],
        mmsList: [],
        actionData: data
      }
      draftUtils.draftModelArray = [draftModel];
      AppStorage.setOrCreate('IsChangeDraft', false);
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(ConversationListService, ConversationListService.getInstance))().afterReturnNothing();
      when(mocker.mockFunc(ConversationService, ConversationService.getInstance))().afterReturn({
        deleteSmsMmsInfoByCondition: (context: Context, actionData: LooseObject, callback: Function) => {
          callback()
        }
      });
      draftUtils.saveDraft(context, undefined, false, true);
      expect((draftUtils as object)['rcsMapStatus']).assertLess(2);
      mocker.clear(ConversationListService);
      mocker.clear(ConversationService);
      AppStorage.clear();
    })

    it('DraftUtilsTest_deleteMessageByGroupIdsTest', 0, () => {
      let draftUtils = DraftUtils.getInstance();
      let item: groupIdsInfos = {
        groupId: '111',
        isRcs: '',
        msgId: '111'
      };
      let infoArr = [item];
      item.isRcs = common.MESSAGE_TYPE.RCS;
      draftUtils.deleteMessageByGroupIds([1], context, () => {
      }, infoArr);
      infoArr.push(item);
      item.isRcs = common.MESSAGE_TYPE.SMS_OR_MMS;
      draftUtils.deleteMessageByGroupIds([], context, () => {
      }, infoArr);
      let res = draftUtils.deleteMessageByGroupIds([], context, () => {
      }, infoArr, true);
      expect(res === undefined).assertTrue();
    })

    it('DraftUtilsTest_deleteMessageByGroupIds_IsChangeDraft_true_abilityResult_null', 0, () => {
      let draftUtils = DraftUtils.getInstance();
      AppStorage.setOrCreate('IsChangeDraft', true);
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(ConversationService, ConversationService.getInstance))().afterReturn({
        querySmsMmsInfoByCondition: (context: Context, actionData: LooseObject, callback: Function) => {
          callback({abilityResult: [null, null]})
        }
      });
      draftUtils.deleteMessageByGroupIds([], context, () => {}, undefined);
      expect(context).not().assertUndefined();
      mocker.clear(ConversationService);
      AppStorage.clear();
    })

    it('DraftUtilsTest_deleteMessageByGroupIds_IsChangeDraft_true', 0, () => {
      let draftUtils = DraftUtils.getInstance();
      AppStorage.setOrCreate('IsChangeDraft', true);
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(ConversationService, ConversationService.getInstance))().afterReturn({
        querySmsMmsInfoByCondition: (context: Context, actionData: LooseObject, callback: Function) => {
          callback({ abilityResult: [{ msgId: 1, receiverNumber: 302 } as LooseObject] })
        },
        deleteSmsMmsInfoByCondition: (context: Context, actionData: LooseObject, callback: Function | null) => {}
      });
      draftUtils.deleteMessageByGroupIds([], context, () => {}, undefined);
      expect(context).not().assertUndefined();
      mocker.clear(ConversationService);
      AppStorage.clear();
    })

    it('DraftUtilsTest_isNeedUpdateDraft_draftModel_null', 0, () => {
      let draftUtils = DraftUtils.getInstance();
      let res: boolean = (draftUtils as object)['isNeedUpdateDraft'](context, null, false) as boolean;
      expect(res).assertFalse();
    })

    it('DraftUtilsTest_isNeedUpdateDraft_selectContactsCount_0_threadId_1', 0, () => {
      let draftUtils = DraftUtils.getInstance();
      let data = new ActionData();
      data.threadId = 1;
      data.isNewMsg = true;
      data.content = '';
      data.mmsSource = [];
      data.selectContacts = [];
      let draftModel: DraftModel = {
        isHasGetContacts: true,
        initialDraftText: '',
        initialDraftAttachments: [],
        initialSelectContacts: [],
        isHasSetValueForInitialDraftAttachments: false,
        isHasSetValueForInitialDraftText: false,
        hasGetContactsThreadID: 0,
        needDeleteSession: {
          isLoaded: false, isNeedDelete: false
        },
        attachmentAreaHasSetValue: false,
        isForwardingDraftModel: false,
        newCreatDrafts: [],
        mmsList: [],
        actionData: data
      }
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(ConversationListService.getInstance(),
        ConversationListService.getInstance().deleteSessionByCondition))(ArgumentMatchers.any).afterReturnNothing();
      when(mocker.mockFunc(DraftUtils.getInstance(),
        DraftUtils.getInstance().deleteMessageByGroupIds))(ArgumentMatchers.any).afterReturnNothing();
      let res: boolean = (draftUtils as object)['isNeedUpdateDraft'](context, draftModel, false) as boolean;
      expect(res).assertFalse();
      mocker.clear(DraftUtils.getInstance());
      mocker.clear(ConversationListService.getInstance());
    })

    it('DraftUtilsTest_isNeedUpdateDraft_selectContactsCount_0_threadId_0', 0, () => {
      let draftUtils = DraftUtils.getInstance();
      let data = new ActionData();
      data.threadId = 0;
      data.isNewMsg = true;
      data.content = '';
      data.mmsSource = [];
      data.selectContacts = [];
      let draftModel: DraftModel = {
        isHasGetContacts: true,
        initialDraftText: '',
        initialDraftAttachments: [],
        initialSelectContacts: [],
        isHasSetValueForInitialDraftAttachments: false,
        isHasSetValueForInitialDraftText: false,
        hasGetContactsThreadID: 0,
        needDeleteSession: {
          isLoaded: false, isNeedDelete: false
        },
        attachmentAreaHasSetValue: false,
        isForwardingDraftModel: false,
        newCreatDrafts: [],
        mmsList: [],
        actionData: data
      }
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(draftUtils, draftUtils.clearDirtyNoReceiverDraft))(ArgumentMatchers.any).afterReturnNothing();
      let res: boolean = (draftUtils as object)['isNeedUpdateDraft'](context, draftModel, false) as boolean;
      mocker.clear(draftUtils);
      expect(res).assertFalse();
    })

    it('DraftUtilsTest_isNeedUpdateDraft_selectContactsCount_0_draftText_eq_initialDraftText_threadId_1', 0, () => {
      let draftUtils = DraftUtils.getInstance();
      let data = new ActionData();
      data.threadId = 1;
      data.isNewMsg = true;
      data.content = 'DraftText';
      data.mmsSource = [];
      data.selectContacts = [];
      let draftModel: DraftModel = {
        isHasGetContacts: true,
        initialDraftText: 'DraftText',
        initialDraftAttachments: [],
        initialSelectContacts: [],
        isHasSetValueForInitialDraftAttachments: false,
        isHasSetValueForInitialDraftText: false,
        hasGetContactsThreadID: 0,
        needDeleteSession: {
          isLoaded: false, isNeedDelete: false
        },
        attachmentAreaHasSetValue: false,
        isForwardingDraftModel: false,
        newCreatDrafts: [],
        mmsList: [],
        actionData: data
      }
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(draftUtils, draftUtils.clearDirtyNoReceiverDraft))(ArgumentMatchers.any).afterReturnNothing();
      let res: boolean = (draftUtils as object)['isNeedUpdateDraft'](context, draftModel, false) as boolean;
      mocker.clear(draftUtils);
      expect(res).assertFalse();
    })

    it('DraftUtilsTest_isNeedUpdateDraft_selectContactsCount_1_draftText_empty_mmsSourceCount_0_threadId_1', 0, () => {
      let draftUtils = DraftUtils.getInstance();
      let selectContact: selectContactType = {
        telephone: '12306',
        telephoneFormat: '1-1-1',
        contactName: 'text'
      };
      let data = new ActionData();
      data.threadId = 1;
      data.isNewMsg = true;
      data.content = '';
      data.mmsSource = [];
      data.selectContacts = [selectContact];
      let draftModel: DraftModel = {
        isHasGetContacts: true,
        initialDraftText: 'DraftText',
        initialDraftAttachments: [],
        initialSelectContacts: [],
        isHasSetValueForInitialDraftAttachments: false,
        isHasSetValueForInitialDraftText: false,
        hasGetContactsThreadID: 0,
        needDeleteSession: {
          isLoaded: false, isNeedDelete: false
        },
        attachmentAreaHasSetValue: false,
        isForwardingDraftModel: false,
        newCreatDrafts: [],
        mmsList: [],
        actionData: data
      }
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(draftUtils, draftUtils.clearDirtyNoReceiverDraft))(ArgumentMatchers.any).afterReturnNothing();
      let res: boolean = (draftUtils as object)['isNeedUpdateDraft'](context, draftModel, false) as boolean;
      mocker.clear(draftUtils);
      expect(res).assertFalse();
    })

    it('DraftUtilsTest_isNeedUpdateDraft_selectContactsCount_2_draftText_empty_mmsSourceCount_1_threadId_1', 0, () => {
      let draftUtils = DraftUtils.getInstance();
      let selectContact: selectContactType = {
        telephone: '12306',
        telephoneFormat: '1-1-1',
        contactName: 'text'
      };
      let selectContact1: selectContactType = {
        telephone: '110',
        telephoneFormat: '1-1-1',
        contactName: '110'
      };
      let selectContact2: selectContactType = {
        telephone: '911',
        telephoneFormat: '1-1-1',
        contactName: '911'
      };
      let data = new ActionData();
      data.threadId = 1;
      data.isNewMsg = true;
      data.content = '';
      data.mmsSource = [{
        duration: '',
        type: 0,
        path: '',
        name: ''
      }];
      data.selectContacts = [selectContact, selectContact1];
      let draftModel: DraftModel = {
        isHasGetContacts: true,
        initialDraftText: 'DraftText',
        initialDraftAttachments: [],
        initialSelectContacts: [selectContact, selectContact2],
        isHasSetValueForInitialDraftAttachments: false,
        isHasSetValueForInitialDraftText: false,
        hasGetContactsThreadID: 1,
        needDeleteSession: {
          isLoaded: false, isNeedDelete: false
        },
        attachmentAreaHasSetValue: false,
        isForwardingDraftModel: false,
        newCreatDrafts: [],
        mmsList: [],
        actionData: data
      }
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(draftUtils, draftUtils.clearDirtyNoReceiverDraft))(ArgumentMatchers.any).afterReturnNothing();
      let res: boolean = (draftUtils as object)['isNeedUpdateDraft'](context, draftModel, false) as boolean;
      mocker.clear(draftUtils);
      expect(res).assertTrue();
    })

    it('DraftUtilsTest_deleteDraft_groupId_0', 0, () => {
      let draftUtils = DraftUtils.getInstance();
      let selectContact: selectContactType = {
        telephone: '12306',
        telephoneFormat: '1-1-1',
        contactName: 'text'
      };
      let data = new ActionData();
      data.threadId = 1;
      data.groupId = 0;
      data.isNewMsg = false;
      data.isDraft = true;
      data.content = '';
      data.mmsSource = [];
      data.selectContacts = [selectContact];
      let draftModel: DraftModel = {
        isHasGetContacts: true,
        initialDraftText: 'DraftText',
        initialDraftAttachments: [],
        initialSelectContacts: [selectContact],
        isHasSetValueForInitialDraftAttachments: false,
        isHasSetValueForInitialDraftText: true,
        hasGetContactsThreadID: 1,
        needDeleteSession: {
          isLoaded: true, isNeedDelete: true
        },
        attachmentAreaHasSetValue: false,
        isForwardingDraftModel: false,
        newCreatDrafts: [],
        mmsList: [],
        actionData: data
      };
      (draftUtils as object)['isPausedStatus'] = false;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().setObject))(ArgumentMatchers.any).afterReturnNothing();
      when(mocker.mockFunc(ConversationListController,
        ConversationListController.getInstance))(ArgumentMatchers.any).afterReturn({
        refreshConversationListData: (context: Context) => {},
        lastIndex: -1
      }
      );
      when(mocker.mockFunc(ConversationController, ConversationController.getInstance))()
        .afterReturn({ draftModel: draftModel, textValue: '', draftContent: '' });
      when(mocker.mockFunc(ConversationListService, ConversationListService.getInstance))().afterReturn({
        updateSessionByCondition: (context: Context, actionData: LooseObject, valueBucket: ValuesBucket,
          callback: Function | null, needUpdateSessionList?: boolean) => {
          if (callback) {
            (draftUtils as object)['isPausedStatus'] = false;
            callback()
          }
        }
      });
      let res: boolean = (draftUtils as object)['isNeedUpdateDraft'](context, draftModel,false) as boolean;
      mocker.clear(ConversationListService);
      mocker.clear(ConversationController);
      mocker.clear(GlobalContext.getContext());
      mocker.clear(ConversationListController);
      expect(res).assertFalse();
    })

    it('DraftUtilsTest_deleteDraft_groupId_1', 0, () => {
      let draftUtils = DraftUtils.getInstance();
      let selectContact: selectContactType = {
        telephone: '12306',
        telephoneFormat: '1-1-1',
        contactName: 'text'
      };
      let data = new ActionData();
      data.threadId = 1;
      data.groupId = 1;
      data.isNewMsg = false;
      data.isDraft = true;
      data.content = '';
      data.mmsSource = [];
      data.selectContacts = [selectContact];
      let type1 = new mmsListType();
      type1.sendStatus = 3;
      type1.groupId = 3;
      type1.isMsm = false;
      type1.rcsType = 10;
      type1.timeMillisecond = 1000;
      type1.mmsSource = [{
        duration: '',
        type: 10,
        path: 'path1',
        name: ''
      },{
        duration: '',
        type: 10,
        path: 'path2',
        name: ''
      }];
      let draftModel: DraftModel = {
        isHasGetContacts: true,
        initialDraftText: 'DraftText',
        initialDraftAttachments: [],
        initialSelectContacts: [selectContact],
        isHasSetValueForInitialDraftAttachments: false,
        isHasSetValueForInitialDraftText: true,
        hasGetContactsThreadID: 1,
        needDeleteSession: {
          isLoaded: false, isNeedDelete: false
        },
        attachmentAreaHasSetValue: false,
        isForwardingDraftModel: false,
        newCreatDrafts: [],
        mmsList: [type1],
        actionData: data
      };
      (draftUtils as object)['isPausedStatus'] = false;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().setObject))(ArgumentMatchers.any).afterReturnNothing();
      when(mocker.mockFunc(ConversationListController,
        ConversationListController.getInstance))(ArgumentMatchers.any).afterReturn({
        refreshConversationListData: (context: Context) => {},
        lastIndex: -1
      }
      );
      when(mocker.mockFunc(ConversationController, ConversationController.getInstance))()
        .afterReturn({ draftModel: draftModel, textValue: '', draftContent: '' });
      when(mocker.mockFunc(ConversationListService, ConversationListService.getInstance))().afterReturn({
        updateSessionByCondition: (context: Context, actionData: LooseObject, valueBucket: ValuesBucket,
          callback: Function | null, needUpdateSessionList?: boolean) => {
          if (callback) {
            (draftUtils as object)['isPausedStatus'] = false;
            callback()
          }
        }
      });
      let res: boolean = (draftUtils as object)['isNeedUpdateDraft'](context, draftModel, false) as boolean;
      expect(res).assertFalse();
      type1.rcsType = 1;
      expect((draftUtils as object)['isNeedUpdateDraft'](context, draftModel, false) as boolean).assertFalse();
      type1.rcsType =3;
      expect((draftUtils as object)['isNeedUpdateDraft'](context, draftModel, false) as boolean).assertFalse();
      type1.rcsType =4;
      expect((draftUtils as object)['isNeedUpdateDraft'](context, draftModel, false) as boolean).assertFalse();
      type1.rcsType =7;
      expect((draftUtils as object)['isNeedUpdateDraft'](context, draftModel, false) as boolean).assertFalse();
      type1.rcsType =8;
      expect((draftUtils as object)['isNeedUpdateDraft'](context, draftModel, false) as boolean).assertFalse();
      type1.rcsType =9;
      expect((draftUtils as object)['isNeedUpdateDraft'](context, draftModel, false) as boolean).assertFalse();
      mocker.clear(ConversationListService);
      mocker.clear(ConversationController);
      mocker.clear(GlobalContext.getContext());
      mocker.clear(ConversationListController);
      AppStorage.clear();
    })

    it('DraftUtilsTest_deleteDraft_groupId_1_rcsType_8_isMsm_true', 0, () => {
      let draftUtils = DraftUtils.getInstance();
      let selectContact: selectContactType = {
        telephone: '12306',
        telephoneFormat: '1-1-1',
        contactName: 'text'
      };
      let data = new ActionData();
      data.threadId = 1;
      data.groupId = 0;
      data.isNewMsg = false;
      data.isDraft = true;
      data.content = '';
      data.mmsSource = [];
      data.selectContacts = [selectContact];
      let type1 = new mmsListType();
      type1.sendStatus = 3;
      type1.groupId = 3;
      type1.isMsm = true;
      type1.rcsType = 8;
      type1.timeMillisecond = 1000;
      type1.mmsSource = [{
        duration: '',
        type: 10,
        path: 'path1',
        name: ''
      },{
        duration: '',
        type: 10,
        path: 'path2',
        copyPath: 'copyPath2',
        name: ''
      }];
      let draftModel: DraftModel = {
        isHasGetContacts: true,
        initialDraftText: 'DraftText',
        initialDraftAttachments: [],
        initialSelectContacts: [selectContact],
        isHasSetValueForInitialDraftAttachments: false,
        isHasSetValueForInitialDraftText: true,
        hasGetContactsThreadID: 1,
        needDeleteSession: {
          isLoaded: false, isNeedDelete: false
        },
        attachmentAreaHasSetValue: false,
        isForwardingDraftModel: false,
        newCreatDrafts: [],
        mmsList: [type1],
        actionData: data
      };
      (draftUtils as object)['isPausedStatus'] = false;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().setObject))(ArgumentMatchers.any).afterReturnNothing();
      when(mocker.mockFunc(ConversationListController,
        ConversationListController.getInstance))(ArgumentMatchers.any).afterReturn({
        refreshConversationListData: (context: Context) => {},
        lastIndex: -1
      }
      );
      when(mocker.mockFunc(ConversationController, ConversationController.getInstance))()
        .afterReturn({ draftModel: draftModel, textValue: '', draftContent: '' });
      when(mocker.mockFunc(ConversationListService, ConversationListService.getInstance))().afterReturn({
        updateSessionByCondition: (context: Context, actionData: LooseObject, valueBucket: ValuesBucket,
          callback: Function | null, needUpdateSessionList?: boolean) => {
          if (callback) {
            (draftUtils as object)['isPausedStatus'] = false;
            callback()
          }
        }
      });
      let res: boolean = (draftUtils as object)['isNeedUpdateDraft'](context, draftModel, false) as boolean;
      expect(res).assertFalse();
      mocker.clear(ConversationListService);
      mocker.clear(ConversationController);
      mocker.clear(GlobalContext.getContext());
      mocker.clear(ConversationListController);
      AppStorage.clear();
    })

    it('DraftUtilsTest_isNeedUpdateDraft_selectContactsCount_1_draftText_empty_mmsSourceCount_1_initialDraftAttachments_0', 0, () => {
      let draftUtils: ESObject = DraftUtils.getInstance();
      let selectContact: selectContactType = {
        telephone: '12306',
        telephoneFormat: '1-1-1',
        contactName: 'text'
      };
      let data = new ActionData();
      data.threadId = 1;
      data.isNewMsg = true;
      data.content = '';
      data.mmsSource = [{
        duration: '',
        type: 0,
        path: '',
        name: ''
      }];
      data.selectContacts = [selectContact];
      let draftModel: DraftModel = {
        isHasGetContacts: true,
        initialDraftText: 'DraftText',
        initialDraftAttachments: [{
          duration: '',
          type: 0,
          path: 'path1',
          name: ''
        }],
        initialSelectContacts: [selectContact],
        isHasSetValueForInitialDraftAttachments: false,
        isHasSetValueForInitialDraftText: false,
        hasGetContactsThreadID: 1,
        needDeleteSession: {
          isLoaded: true, isNeedDelete: true
        },
        attachmentAreaHasSetValue: false,
        isForwardingDraftModel: false,
        newCreatDrafts: [],
        mmsList: [],
        actionData: data
      }
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(draftUtils, draftUtils.clearDirtyNoReceiverDraft))(ArgumentMatchers.any).afterReturnNothing();
      let res: boolean = (draftUtils as object)['isNeedUpdateDraft'](context, draftModel) as boolean;
      mocker.clear(draftUtils);
      expect(res).assertFalse();
    })

    it('DraftUtilsTest_isNeedUpdateDraft_selectContactsCount_1_draftText_empty_mmsSourceCount_2_initialDraftAttachments_2', 0, () => {
      let draftUtils = DraftUtils.getInstance();
      let selectContact: selectContactType = {
        telephone: '12306',
        telephoneFormat: '1-1-1',
        contactName: 'text'
      };
      let data = new ActionData();
      data.threadId = 1;
      data.isNewMsg = true;
      data.content = 'DraftText';
      data.mmsSource = [{
        duration: '',
        type: 0,
        path: 'path1',
        name: ''
      },{
        duration: '',
        type: 0,
        path: 'path2',
        name: ''
      }];
      data.selectContacts = [selectContact];
      let draftModel: DraftModel = {
        isHasGetContacts: true,
        initialDraftText: 'DraftText',
        initialDraftAttachments: [{
          duration: '',
          type: 0,
          path: 'path1',
          name: ''
        },{
          duration: '',
          type: 0,
          path: 'path0',
          name: ''
        }],
        initialSelectContacts: [selectContact],
        isHasSetValueForInitialDraftAttachments: false,
        isHasSetValueForInitialDraftText: false,
        hasGetContactsThreadID: 1,
        needDeleteSession: {
          isLoaded: true, isNeedDelete: true
        },
        attachmentAreaHasSetValue: true,
        isForwardingDraftModel: false,
        newCreatDrafts: [],
        mmsList: [],
        actionData: data
      }
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(draftUtils, draftUtils.clearDirtyNoReceiverDraft))(ArgumentMatchers.any).afterReturnNothing();
      let res: boolean = (draftUtils as object)['isNeedUpdateDraft'](context, draftModel, false) as boolean;
      mocker.clear(draftUtils);
      expect(res).assertTrue();
    })

    it('DraftUtilsTest_clearDirtyNoReceiverDraft', 0, () => {
      let draftUtils = DraftUtils.getInstance();
      let type1 = new mmsListType();
      type1.sendStatus = 3;
      type1.groupId = 3;
      let type2 = new mmsListType();
      type2.sendStatus = 0;
      type2.groupId = 0;

      let draftItemList: mmsListType[] = [type1, type2];
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(draftUtils, draftUtils.deleteMessageByGroupIds))(ArgumentMatchers.any).afterReturnNothing();
      let res: number = draftUtils.clearDirtyNoReceiverDraft(draftItemList, context, () => {});
      mocker.clear(draftUtils);
      expect(res).assertEqual(1);
    })

    it('DraftUtilsTest_insertNewCreatMessageDraft', 0, () => {
      let draftUtils = DraftUtils.getInstance();
      let data = new ActionData();
      data.threadId = 1;
      data.isDraft = true;
      data.content = 'DraftText';
      data.mmsSource = [];
      data.selectContacts = [];
      let draftModel: DraftModel = {
        isHasGetContacts: true,
        initialDraftText: 'DraftText',
        initialDraftAttachments: [],
        initialSelectContacts: [],
        isHasSetValueForInitialDraftAttachments: false,
        isHasSetValueForInitialDraftText: false,
        hasGetContactsThreadID: 1,
        needDeleteSession: {
          isLoaded: true, isNeedDelete: true
        },
        attachmentAreaHasSetValue: false,
        isForwardingDraftModel: false,
        newCreatDrafts: [],
        mmsList: [],
        actionData: data
      }
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(draftUtils, draftUtils.clearDirtyNoReceiverDraft))(ArgumentMatchers.any).afterReturnNothing();
      when(mocker.mockFunc(ConversationService.getInstance(),
        ConversationService.getInstance().insertNoReceiverDraft))(ArgumentMatchers.any).afterReturnNothing();
      (draftUtils as object)['insertNewCreatMessageDraft'](context, draftModel);
      expect(context).not().assertUndefined();
      mocker.clear(draftUtils);
      mocker.clear(ConversationService.getInstance());
    })

    it('DraftUtilsTest_updateConversationControllerDraftModel', 0, () => {
      let draftUtils = DraftUtils.getInstance();
      (draftUtils as object)['isNeedClearTextArea'] = true;
      let data = new ActionData();
      data.threadId = 1;
      data.isDraft = true;
      data.content = 'DraftText';
      data.mmsSource = [];
      data.selectContacts = [];
      let draftModel: DraftModel = {
        isHasGetContacts: true,
        initialDraftText: 'DraftText',
        initialDraftAttachments: [],
        initialSelectContacts: [],
        isHasSetValueForInitialDraftAttachments: false,
        isHasSetValueForInitialDraftText: false,
        hasGetContactsThreadID: 1,
        needDeleteSession: {
          isLoaded: true, isNeedDelete: true
        },
        attachmentAreaHasSetValue: false,
        isForwardingDraftModel: false,
        newCreatDrafts: [],
        mmsList: [],
        actionData: data
      }
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(ConversationController, ConversationController.getInstance))()
        .afterReturn({ draftModel: draftModel, textValue: '', draftContent: '' });
      (draftUtils as object)['updateConversationControllerDraftModel'](draftModel);
      expect(context).not().assertUndefined();
      mocker.clear(ConversationController);
    })

    it('DraftUtilsTest_updateConversationControllerDraftModel_isNeedClearTextArea_false', 0, () => {
      let draftUtils = DraftUtils.getInstance();
      (draftUtils as object)['isNeedClearTextArea'] = false;
      let data = new ActionData();
      data.threadId = 1;
      data.isDraft = true;
      data.content = 'DraftText';
      data.mmsSource = [];
      data.selectContacts = [];
      let draftModel: DraftModel = {
        isHasGetContacts: true,
        initialDraftText: 'DraftText',
        initialDraftAttachments: [],
        initialSelectContacts: [],
        isHasSetValueForInitialDraftAttachments: false,
        isHasSetValueForInitialDraftText: false,
        hasGetContactsThreadID: 1,
        needDeleteSession: {
          isLoaded: true, isNeedDelete: true
        },
        attachmentAreaHasSetValue: false,
        isForwardingDraftModel: false,
        newCreatDrafts: [],
        mmsList: [],
        actionData: data
      }
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(ConversationController, ConversationController.getInstance))()
        .afterReturn({ draftModel: null, textValue: '', draftContent: '' });
      (draftUtils as object)['updateConversationControllerDraftModel'](draftModel);
      expect(context).not().assertUndefined();
      mocker.clear(ConversationController);
    })
  })
}