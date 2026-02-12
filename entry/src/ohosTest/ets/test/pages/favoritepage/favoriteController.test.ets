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
import { describe, beforeEach, it, expect, MockKit, when, ArgumentMatchers, afterEach } from '@ohos/hypium';
import FavoriteController from '../../../../../main/ets/pages/favoritepage/favoriteController';
import { GroupIdsInfos } from '../../../../../main/ets/pages/favoritepage/favoriteController';
import MySet from '../../MySet';
import { dataShare, dataSharePredicates, DataShareResultSet } from '@kit.ArkData';
import DataShareHelper from '../../../../../main/ets/model/repository/DataShareHelper';
import ConversationListService from '../../../../../main/ets/service/ConversationListService';
import { AsyncCallback, BusinessError } from '@kit.BasicServicesKit';
import HiLog from '../../../../../main/ets/utils/HiLog';
import { GlobalContext } from '../../../../../main/ets/MainAbility/GlobalHelper';
import ConversationListController, {
  messageType
} from '../../../../../main/ets/pages/conversationlist/conversationListController';
import LooseObject from '../../../../../main/ets/data/LooseObject';
import { mmsListType } from '../../../../../main/ets/pages/conversation/conversationController';
import { Mms } from '../../../../../main/ets/utils/TypesUtils';
import ConversationService from '../../../../../main/ets/service/ConversationService';
import { commonPasteboard } from '../../../../../main/ets/data/Pasteboard';
import { systemShare } from '@kit.ShareKit';
import { resourceManager } from '@kit.LocalizationKit';
import { window } from '@kit.ArkUI';
import TelephoneUtil from '../../../../../main/ets/utils/TelephoneUtil';
import { DTGlobalContext } from '../../../testability/TestAbility';
import { isSameTel } from '../../../../../main/ets/utils/TelephoneUtilEnhancde';

class Message {
  msgId: number = 0;
  type: number = 0;
  name: string = "";
  telephone: string = "";
}

export default function favoriteControllerTest() {
  describe('favoriteControllerTest', () => {

    let favoriteController: FavoriteController;
    let mocker: MockKit;
    const TAG = '[Hypium]';
    let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;

    beforeEach(() => {
      favoriteController = FavoriteController.getTestInstance();
      mocker = new MockKit();
    })

    afterEach(() => {
      mocker.clear(favoriteController);
      mocker.clear(DataShareHelper.getInstance());
      mocker.clear(GlobalContext.getContext());
    })

    it('favoriteController_getInstance', 0, () => {
      expect(typeof favoriteController).assertEqual(typeof FavoriteController.getInstance());
    })

    it('favoriteController_GroupIdsInfos', 0, () => {
      let groupIdsInfos: GroupIdsInfos = {
        groupId: '',
        isRcs: '',
        msgId: ''
      };

      expect(groupIdsInfos.groupId).assertEqual('');
      expect(groupIdsInfos.isRcs).assertEqual('');
      expect(groupIdsInfos.msgId).assertEqual('');
    })

    it('favoriteController_sorting', 0, () => {
      expect(favoriteController.sorting({
        startTime: 1
      }, {
        startTime: 0
      })).assertEqual(-1);
    })

    let flag = 0;
    it('favoriteController_getFavoriteData_success', 0, () => {
      let myset: DataShareResultSet = new MySet();
      myset.rowCount = 1;

      when(mocker.mockFunc(DataShareHelper.getInstance(),
        DataShareHelper.getInstance().initSmsDB))(ArgumentMatchers.any)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve({
            rowCount: 1,
            goToNextRow: (): boolean => {
              flag++;
              return flag > 1 ? false : true
            },
            getLong: (columnIndex: number) => 1,
            getColumnIndex: (columnName: string): number => 1,
            getString: (columnIndex: number): string => 'ss'
          } as DataShareResultSet))
        } as dataShare.DataShareHelper)));

      favoriteController.getFavoriteData(context);

      expect(favoriteController.isFavorite).assertFalse();
    })

    it('favoriteController_getFavoriteData_fail', 0, () => {
      let myset: DataShareResultSet = new MySet();
      myset.rowCount = 1;

      when(mocker.mockFunc(DataShareHelper.getInstance(),
        DataShareHelper.getInstance().initSmsDB))(ArgumentMatchers.any)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(undefined)));

      favoriteController.getFavoriteData(context);

      expect(favoriteController.isFavorite).assertFalse();
    })

    it('favoriteController_registerDataChangeObserver', 0, () => {
      let context: Context = GlobalContext.getContext().getObject('mmsContext') as Context;

      let myset: DataShareResultSet = new MySet();
      myset.rowCount = 1;

      when(mocker.mockFunc(DataShareHelper.getInstance(),
        DataShareHelper.getInstance().initContactDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          on: (type: "dataChange", uri: string, callback: AsyncCallback<void, void>): void => {
            callback({
              code: 1
            } as BusinessError);
          }
        } as dataShare.DataShareHelper)));

      mocker.mockFunc(HiLog, HiLog.i);

      favoriteController.registerDataChangeObserver((res: BusinessError) => {
        expect(res.code).assertEqual(1);
      }, context);

      mocker.clear(ConversationListService.getInstance());
    })

    it('favoriteController_registerDataChangeObserver_catch', 0, () => {
      let context: Context = GlobalContext.getContext().getObject('mmsContext') as Context;

      let myset: DataShareResultSet = new MySet();
      myset.rowCount = 1;

      when(mocker.mockFunc(DataShareHelper.getInstance(),
        DataShareHelper.getInstance().initContactDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>((resolve: (value: dataShare.DataShareHelper | PromiseLike<dataShare.DataShareHelper>) => void,
          reject: (reason?: BusinessError) => void) => reject({
          code: 1, message: 'error'
        } as BusinessError)));

      favoriteController.registerDataChangeObserver(() => {
      }, context);

      expect(favoriteController.isFavorite).assertFalse();

      mocker.clear(ConversationListService.getInstance());
    })

    it('favoriteController_unregisterDataChangeObserver', 0, () => {
      let context: Context = GlobalContext.getContext().getObject('mmsContext') as Context;

      let myset: DataShareResultSet = new MySet();
      myset.rowCount = 1;

      when(mocker.mockFunc(DataShareHelper.getInstance(),
        DataShareHelper.getInstance().initContactDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          off: (type: "dataChange", uri: string, callback?: AsyncCallback<void, void> | undefined): void => {
            expect(uri).assertEqual('datashare:///com.ohos.contactsdataability/contacts/contact_data');
          }
        } as dataShare.DataShareHelper)));

      mocker.mockFunc(HiLog, HiLog.i);

      favoriteController.unregisterDataChangeObserver((res: BusinessError) => {
      }, context);

      mocker.clear(ConversationListService.getInstance());
    })

    it('favoriteController_unregisterDataChangeObserver_catch', 0, () => {
      let context: Context = GlobalContext.getContext().getObject('mmsContext') as Context;

      let myset: DataShareResultSet = new MySet();
      myset.rowCount = 1;

      when(mocker.mockFunc(DataShareHelper.getInstance(),
        DataShareHelper.getInstance().initContactDB))(context)
        .afterReturn(new Promise<dataShare.DataShareHelper>((resolve: (value: dataShare.DataShareHelper | PromiseLike<dataShare.DataShareHelper>) => void,
          reject: (reason?: BusinessError) => void) => reject({
          code: 1, message: 'error'
        } as BusinessError)));

      favoriteController.unregisterDataChangeObserver(() => {
      }, context);

      expect(favoriteController.isFavorite).assertFalse();

      mocker.clear(ConversationListService.getInstance());
    })

    it('favoriteController_clickGroupDelete0', 0, () => {
      favoriteController.mmsListFromFavo = [new messageType(), new messageType()];
      favoriteController.selectDeleteMsgCount = 0;

      favoriteController.clickGroupDelete();

      expect(favoriteController.strMsgDeleteDialogTip).assertUndefined();
    })

    it('favoriteController_clickGroupDelete1', 0, () => {
      favoriteController.mmsListFromFavo = [new messageType(), new messageType()];
      favoriteController.selectDeleteMsgCount = 1;

      favoriteController.clickGroupDelete();

      expect(JSON.stringify(favoriteController.strMsgDeleteDialogTip))
        .assertEqual(JSON.stringify($r('app.string.msg_delete_dialog_con_tip1')));
    })

    it('favoriteController_clickGroupDelete2', 0, () => {
      favoriteController.mmsListFromFavo = [new messageType(), new messageType()];
      favoriteController.selectDeleteMsgCount = 2;

      favoriteController.clickGroupDelete();

      expect(JSON.stringify(favoriteController.strMsgDeleteDialogTip))
        .assertEqual(JSON.stringify($r('app.string.msg_delete_dialog_con_tip3')));
    })

    it('favoriteController_clickGroupDelete3', 0, () => {
      favoriteController.mmsListFromFavo = [new messageType(), new messageType()];
      favoriteController.selectDeleteMsgCount = 3;

      favoriteController.clickGroupDelete();

      expect(JSON.stringify(favoriteController.strMsgDeleteDialogTip))
        .assertEqual(JSON.stringify($r('app.plural.msg_delete_dialog_con_tip2', 3, 3)));
    })

    it('favoriteController_getInfoMsgData', 0, async () => {
      let context: Context = GlobalContext.getContext().getObject('mmsContext') as Context;
      let getSessionListResultNew: Function = mocker.mockFunc(ConversationListService.getInstance(),
        ConversationListService.getInstance().getSessionListResultNew);
      when(getSessionListResultNew)(ArgumentMatchers.any).afterReturn(new Promise<LooseObject>(resolve => resolve({
        response: []
      })));

      await favoriteController.getInfoMsgData(context, new Array());

      expect(favoriteController.msgListForFav.length).assertEqual(0);

      mocker.clear(ConversationListService.getInstance());
    })

    it('favoriteController_titleBarAvatar', 0, () => {
      let res = false;
      when(mocker.mockFunc(favoriteController.mFavoriteController,
        favoriteController.mFavoriteController.jumpToContact))(ArgumentMatchers.any)
        .afterAction(() => {
          res = true;
        });

      favoriteController.titleBarAvatar(context, "111");

      expect(res).assertTrue();

      mocker.clear(favoriteController.mFavoriteController);
    })

    it('favoriteController_mmsScreening', 0, () => {
      favoriteController.mmsMessage = [];
      let obj: Message = new Message();
      obj.msgId = 0;
      obj.type = 1;
      favoriteController.mmsMessage.push(obj);

      favoriteController.mmsScreening(0, 1);

      expect(favoriteController.mmsScreening(0, 1).msgId).assertEqual(0);
    })

    it('favoriteController_mmsRcsScreening', 0, () => {
      favoriteController.mmsMessage = [];
      let obj: Message = new Message();
      obj.msgId = 0;
      obj.type = 1;
      favoriteController.mmsMessage.push(obj);

      favoriteController.mmsRcsScreening(0, 1);

      expect(favoriteController.mmsScreening(0, 1).msgId).assertEqual(0);
    })

    it('favoriteController_nameAndPicture', 0, () => {
      let type: messageType = new messageType();
      type.name = 'xx';
      type.telephone = '11';
      favoriteController.msgListForFav = [type];
      when(mocker.mockFunc(TelephoneUtil, isSameTel))('xx')
        .afterReturn(false);
      when(mocker.mockFunc(TelephoneUtil, isSameTel))('11')
        .afterReturn(true);
      expect(favoriteController.nameAndPicture("11").name).assertEqual('xx');
    })

    it('favoriteController_nameNoPicture', 0, () => {
      let type: messageType = new messageType();
      type.name = 'xx';
      type.telephone = '111';
      favoriteController.msgListForFav = [type];
      when(mocker.mockFunc(TelephoneUtil, isSameTel))('111')
        .afterReturn(true);

      expect(favoriteController.nameNoPicture("111").name).assertEqual('xx');
    })

    it('favoriteController_showBubbleOrEmoji', 0, () => {
      let res = false;
      when(mocker.mockFunc(favoriteController.mFavoriteController,
        favoriteController.mFavoriteController.showBubbleOrEmoji))(ArgumentMatchers.any)
        .afterAction(() => {
          res = true;
        });

      favoriteController.showBubbleOrEmoji("11");

      expect(res).assertTrue();

      mocker.clear(favoriteController.mFavoriteController);
    })

    it('favoriteController_cancelFavorites', 0, () => {
      let type: messageType = new messageType();
      type.isCbChecked = true;
      let type1: messageType = new messageType();
      type1.isCbChecked = false;

      favoriteController.mmsListFromFavo = [type, type1]
      let res = false;
      when(mocker.mockFunc(favoriteController,
        favoriteController.cancelFavorite))(ArgumentMatchers.any)
        .afterAction(() => {
          res = true;
        });

      favoriteController.cancelFavorites(context);

      expect(res).assertTrue();
    })

    it('favoriteController_cancelFavorites1', 0, () => {
      when(mocker.mockFunc(DataShareHelper.getInstance(),
        DataShareHelper.getInstance().initSmsDB))(ArgumentMatchers.any)
        .afterReturn(new Promise<dataShare.DataShareHelper>((resolve: (value: dataShare.DataShareHelper | PromiseLike<dataShare.DataShareHelper>) => void,
          reject: (reason?: BusinessError) => void) => reject({
          code: 1, message: 'error'
        } as BusinessError)));

      mocker.mockFunc(favoriteController, favoriteController.getFavoriteData);

      favoriteController.cancelFavorite(context, {
        conversation: {
          isRcs: 1
        }
      } as LooseObject);

      expect(favoriteController.isFavorite).assertFalse();
    })

    it('favoriteController_cancelFavorites0', 0, () => {
      when(mocker.mockFunc(DataShareHelper.getInstance(),
        DataShareHelper.getInstance().initSmsDB))(ArgumentMatchers.any)
        .afterReturn(new Promise<dataShare.DataShareHelper>((resolve: (value: dataShare.DataShareHelper | PromiseLike<dataShare.DataShareHelper>) => void,
          reject: (reason?: BusinessError) => void) => reject({
          code: 1, message: 'error'
        } as BusinessError)));

      mocker.mockFunc(favoriteController, favoriteController.getFavoriteData);

      favoriteController.cancelFavorite(context, {
        conversation: {
          isRcs: 0
        }
      } as LooseObject);

      expect(favoriteController.isFavorite).assertFalse();
    })

    it('favoriteController_onBackPress_isSelectStatus_true', 0, () => {
      favoriteController.isSelectStatus = true;

      mocker.mockFunc(favoriteController, favoriteController.resetSelectData);
      mocker.mockFunc(favoriteController, favoriteController.resetMmsCount);
      mocker.mockFunc(favoriteController, favoriteController.cancelCheckedAll);
      mocker.mockFunc(favoriteController.conversationDataSource, favoriteController.conversationDataSource.refresh);

      expect(favoriteController.onBackPress()).assertTrue();

      mocker.clear(favoriteController.conversationDataSource);
    })

    it('favoriteController_onBackPress_isSelectStatus_false', 0, () => {
      favoriteController.isSelectStatus = false;

      mocker.mockFunc(favoriteController, favoriteController.resetSelectData);
      mocker.mockFunc(favoriteController, favoriteController.resetMmsCount);
      mocker.mockFunc(favoriteController, favoriteController.cancelCheckedAll);
      mocker.mockFunc(favoriteController.conversationDataSource, favoriteController.conversationDataSource.refresh);

      expect(favoriteController.onBackPress()).assertFalse();

      mocker.clear(favoriteController.conversationDataSource);
    })

    it('favoriteController_resetMmsCount', 0, () => {
      favoriteController.resetMmsCount()

      expect(favoriteController.mmsCount).assertEqual(0);
    })

    it('favoriteController_deleteDialogConfirm_groupIds_length1', 0, () => {
      let type: messageType = new messageType();
      type.isCbChecked = true;
      type.groupId = 1;
      favoriteController.mmsListFromFavo = [type];
      favoriteController.mmsList = [{
        groupId: 1, isRcs: 1, id: '1'
      } as mmsListType];

      mocker.mockFunc(ConversationListController.getInstance(),
        ConversationListController.getInstance().resetLastIndexValue);
      mocker.mockFunc(favoriteController, favoriteController.cancelCheckedAll);
      mocker.mockFunc(favoriteController, favoriteController.resetSelectData);
      mocker.mockFunc(favoriteController, favoriteController.deleteMessageByGroupIds);
      mocker.mockFunc(favoriteController.favoriteList, favoriteController.favoriteList.refresh);

      favoriteController.deleteDialogConfirm(context);

      expect(favoriteController.mmsIndex).assertEqual(0);

      mocker.clear(ConversationListController.getInstance());
      mocker.clear(favoriteController.favoriteList);
    })

    it('favoriteController_deleteDialogConfirm_groupIds_length_0', 0, () => {
      let type: messageType = new messageType();
      type.isCbChecked = false;
      type.groupId = 1;
      favoriteController.mmsListFromFavo = [type];
      favoriteController.mmsList = [{
        groupId: 1, isRcs: 1, id: '1'
      } as mmsListType];

      mocker.mockFunc(ConversationListController.getInstance(),
        ConversationListController.getInstance().resetLastIndexValue);
      mocker.mockFunc(favoriteController, favoriteController.cancelCheckedAll);
      mocker.mockFunc(favoriteController, favoriteController.resetSelectData);
      mocker.mockFunc(favoriteController, favoriteController.deleteMessageByGroupIds);
      mocker.mockFunc(favoriteController.favoriteList, favoriteController.favoriteList.refresh);

      favoriteController.deleteDialogConfirm(context);

      expect(favoriteController.mmsIndex).assertEqual(0);

      mocker.clear(ConversationListController.getInstance());
      mocker.clear(favoriteController.favoriteList);
    })

    it('favoriteController_clickGroupCheckAll_isMessageCheckAll_true', 0, () => {
      let type: messageType = new messageType();
      type.isCbChecked = false;
      type.groupId = 1;
      favoriteController.mmsListFromFavo = [type];

      favoriteController.isMessageCheckAll = true;

      mocker.mockFunc(favoriteController, favoriteController.setMessageCheckAll);
      mocker.mockFunc(favoriteController.favoriteList, favoriteController.favoriteList.refresh);
      when(mocker.mockFunc(favoriteController.favoriteList,
        favoriteController.favoriteList.selectData))(ArgumentMatchers.any).afterReturnNothing();

      favoriteController.clickGroupCheckAll();

      mocker.verify('setMessageCheckAll', [2]).once();

      mocker.clear(favoriteController.favoriteList);
    })

    it('favoriteController_clickGroupCheckAll_isMessageCheckAll_false', 0, () => {
      let type: messageType = new messageType();
      type.isCbChecked = false;
      type.groupId = 1;
      favoriteController.mmsListFromFavo = [type];

      favoriteController.isMessageCheckAll = false;

      mocker.mockFunc(favoriteController, favoriteController.setMessageCheckAll);
      mocker.mockFunc(favoriteController.favoriteList, favoriteController.favoriteList.refresh);
      when(mocker.mockFunc(favoriteController.favoriteList,
        favoriteController.favoriteList.selectData))(ArgumentMatchers.any).afterReturnNothing();

      favoriteController.clickGroupCheckAll();

      mocker.verify('setMessageCheckAll', [1]).once();

      mocker.clear(favoriteController.favoriteList);
    })

    it('favoriteController_selectStatusOnDeleteMsg_isSelectStatus_true_isCbChecked_false', 0, () => {
      let groupIds: number[] = [];
      let type: messageType = new messageType();
      type.isCbChecked = false;
      type.groupId = 1;
      favoriteController.mmsListFromFavo = [type];

      favoriteController.isSelectStatus = true;

      mocker.mockFunc(favoriteController.favoriteList, favoriteController.favoriteList.deleteByIndex);
      mocker.mockFunc(favoriteController, favoriteController.resetSelectData);

      favoriteController.selectStatusOnDeleteMsg(groupIds, [], 0);

      expect(groupIds.length).assertEqual(0);

      mocker.clear(favoriteController.favoriteList);
    })

    it('favoriteController_multiSelectMmsMsg_isCbChecked_true_hasMms_true', 0, () => {
      let type: messageType = new messageType();
      type.isCbChecked = true;
      type.groupId = 1;
      type.hasMms = true;
      favoriteController.mmsListFromFavo = [type];

      favoriteController.mmsCount = 1;


      favoriteController.multiSelectMmsMsg(0);

      expect(favoriteController.mmsCount).assertEqual(0);
    })

    it('favoriteController_multiSelectMmsMsg_isCbChecked_true_hasMms_false', 0, () => {
      let type: messageType = new messageType();
      type.isCbChecked = true;
      type.groupId = 1;
      type.hasMms = false;
      favoriteController.mmsListFromFavo = [type];

      favoriteController.mmsCount = 1;


      favoriteController.multiSelectMmsMsg(0);

      expect(favoriteController.mmsCount).assertEqual(1);
    })

    it('favoriteController_multiSelectMmsMsg_isCbChecked_false_hasMms_false', 0, () => {
      let type: messageType = new messageType();
      type.isCbChecked = false;
      type.groupId = 1;
      type.hasMms = false;
      favoriteController.mmsListFromFavo = [type];

      favoriteController.mmsCount = 1;

      favoriteController.multiSelectMmsMsg(0);

      expect(favoriteController.mmsCount).assertEqual(1);
    })

    it('favoriteController_multiSelectMmsMsg_isCbChecked_false_hasMms_true', 0, () => {
      let type: messageType = new messageType();
      type.isCbChecked = false;
      type.groupId = 1;
      type.hasMms = true;
      favoriteController.mmsListFromFavo = [type];

      favoriteController.mmsCount = 1;


      favoriteController.multiSelectMmsMsg(0);

      expect(favoriteController.mmsCount).assertEqual(2);
    })

    it('favoriteController_listCheckBoxChange_isCbChecked_true', 0, () => {
      let type: messageType = new messageType();
      type.isCbChecked = true;
      type.groupId = 1;
      let type1: messageType = new messageType();
      type1.isCbChecked = false;
      type1.groupId = 1;
      favoriteController.mmsListFromFavo = [type, type1];

      favoriteController.selectDeleteMsgCount = 1;

      mocker.mockFunc(favoriteController.favoriteList, favoriteController.favoriteList.refresh);
      mocker.mockFunc(favoriteController, favoriteController.setSelectStatus);
      mocker.mockFunc(favoriteController, favoriteController.setMessageCheckAll);
      mocker.mockFunc(favoriteController, favoriteController.setGroupMoreMenu);
      mocker.mockFunc(favoriteController, favoriteController.judgeOnlyAudio);
      when(mocker.mockFunc(favoriteController.favoriteList,
        favoriteController.favoriteList.selectData))(ArgumentMatchers.any).afterReturnNothing();

      favoriteController.listCheckBoxChange(0, true);

      expect(favoriteController.mmsIndex).assertEqual(0);

      mocker.clear(favoriteController.favoriteList);
    })

    it('favoriteController_listCheckBoxChange_isCbChecked_false', 0, () => {
      let type: messageType = new messageType();
      type.isCbChecked = false;
      type.groupId = 1;
      favoriteController.mmsListFromFavo = [type];

      favoriteController.selectDeleteMsgCount = 1;

      mocker.mockFunc(favoriteController.favoriteList, favoriteController.favoriteList.refresh);
      mocker.mockFunc(favoriteController, favoriteController.setSelectStatus);
      mocker.mockFunc(favoriteController, favoriteController.setMessageCheckAll);
      mocker.mockFunc(favoriteController, favoriteController.setGroupMoreMenu);
      mocker.mockFunc(favoriteController, favoriteController.judgeOnlyAudio);
      when(mocker.mockFunc(favoriteController.favoriteList,
        favoriteController.favoriteList.selectData))(ArgumentMatchers.any).afterReturnNothing();

      favoriteController.listCheckBoxChange(0, false);

      expect(favoriteController.mmsIndex).assertEqual(0);

      mocker.clear(favoriteController.favoriteList);
    })

    it('favoriteController_listCheckBoxChange_selectDeleteMsgCount_0', 0, () => {
      let type: messageType = new messageType();
      type.isCbChecked = false;
      type.groupId = 1;
      favoriteController.mmsListFromFavo = [type];

      favoriteController.selectDeleteMsgCount = 0;

      mocker.mockFunc(favoriteController.favoriteList, favoriteController.favoriteList.refresh);
      mocker.mockFunc(favoriteController, favoriteController.setSelectStatus);
      mocker.mockFunc(favoriteController, favoriteController.setMessageCheckAll);
      mocker.mockFunc(favoriteController, favoriteController.judgeOnlyAudio);
      when(mocker.mockFunc(favoriteController.favoriteList,
        favoriteController.favoriteList.selectData))(ArgumentMatchers.any).afterReturnNothing();

      favoriteController.listCheckBoxChange(0, false);

      expect(favoriteController.mmsIndex).assertEqual(0);

      mocker.clear(favoriteController.favoriteList);
    })

    it('favoriteController_setGroupMoreMenu_hasMms_false', 0, () => {
      let type: messageType = new messageType();
      type.hasMms = false;

      favoriteController.setGroupMoreMenu(type);

      expect(favoriteController.hasContent).assertTrue();
    })

    it('favoriteController_setGroupMoreMenu_hasMms_true', 0, () => {
      let type: messageType = new messageType();
      type.hasMms = true;

      mocker.mockFunc(favoriteController, favoriteController.judgeOnlyAudio);

      favoriteController.setGroupMoreMenu(type);

      mocker.verify('judgeOnlyAudio', []).once();
    })

    it('favoriteController_judgeOnlyAudio_isCbChecked_true_mmsSource_empty', 0, () => {
      let type: messageType = new messageType();
      type.isCbChecked = true;
      type.groupId = 1;
      type.mmsSource = [];
      favoriteController.mmsListFromFavo = [type];

      mocker.mockFunc(favoriteController, favoriteController.judgeOnlyAudio);

      favoriteController.judgeOnlyAudio();

      expect(favoriteController.audioStatus).assertEqual(-1);
    })

    it('favoriteController_judgeOnlyAudio_isCbChecked_true', 0, () => {
      let type: messageType = new messageType();
      type.isCbChecked = true;
      type.groupId = 1;
      type.mmsSource = [{
        type: 1,
      } as Mms];
      favoriteController.mmsListFromFavo = [type];

      mocker.mockFunc(favoriteController, favoriteController.checkOnlyAudio);

      favoriteController.judgeOnlyAudio();

      expect(favoriteController.audioStatus).assertEqual(1);
    })

    it('favoriteController_judgeOnlyAudio_isCbChecked_false', 0, () => {
      let type: messageType = new messageType();
      type.isCbChecked = false;
      type.groupId = 1;
      favoriteController.mmsListFromFavo = [type];

      mocker.mockFunc(favoriteController, favoriteController.judgeOnlyAudio);

      favoriteController.judgeOnlyAudio();

      expect(favoriteController.audioStatus).assertEqual(-1);
    })

    it('favoriteController_checkOnlyAudio_type_3', 0, () => {
      let type: messageType = new messageType();
      type.isCbChecked = false;
      type.groupId = 1;
      type.content = 'xx';
      type.mmsSource = [{
        type: 3
      } as Mms];
      favoriteController.mmsListFromFavo = [type];

      mocker.mockFunc(favoriteController, favoriteController.judgeOnlyAudio);

      favoriteController.checkOnlyAudio(type);

      expect(favoriteController.audioStatus).assertEqual(-1);
    })

    it('favoriteController_checkOnlyAudio_type_3_content_empty', 0, () => {
      let type: messageType = new messageType();
      type.isCbChecked = false;
      type.content = '';
      type.mmsSource = [{
        type: 3
      } as Mms];
      favoriteController.mmsListFromFavo = [type];

      mocker.mockFunc(favoriteController, favoriteController.judgeOnlyAudio);

      favoriteController.checkOnlyAudio(type);

      expect(favoriteController.audioStatus).assertEqual(-1);
    })

    it('favoriteController_checkOnlyAudio_type_2', 0, () => {
      let type: messageType = new messageType();
      type.isCbChecked = false;
      type.content = 'xx';
      type.mmsSource = [{
        type: 2
      } as Mms];
      favoriteController.mmsListFromFavo = [type];

      mocker.mockFunc(favoriteController, favoriteController.judgeOnlyAudio);

      favoriteController.checkOnlyAudio(type);

      expect(favoriteController.audioStatus).assertEqual(-1);
    })

    it('favoriteController_resetSelectData', 0, () => {
      favoriteController.resetSelectData();

      expect(favoriteController.isSelectStatus).assertFalse();
      expect(favoriteController.selectDeleteMsgCount).assertEqual(0);
    })

    it('favoriteController_cancelCheckedAll', 0, () => {
      let type: messageType = new messageType();
      type.isCbChecked = false;
      type.groupId = 1;
      type.content = 'xx';
      type.mmsSource = [{
        type: 3
      } as Mms];
      favoriteController.mmsListFromFavo = [type];

      mocker.mockFunc(favoriteController.favoriteList, favoriteController.favoriteList.refresh);

      favoriteController.cancelCheckedAll();

      expect(favoriteController.isSelectStatus).assertFalse();
    })

    it('favoriteController_deleteMessageByGroupIds_isRcs_1', 0, () => {
      let type: messageType = new messageType();
      type.isCbChecked = false;
      type.groupId = 1;
      type.content = 'xx';
      type.mmsSource = [{
        type: 3
      } as Mms];
      favoriteController.mmsListFromFavo = [type];

      mocker.mockFunc(favoriteController.favoriteList, favoriteController.favoriteList.refresh);
      let res = false;
      when(mocker.mockFunc(ConversationService.getInstance(),
        ConversationService.getInstance().deleteSmsMmsInfoByCondition))
      (ArgumentMatchers.any).afterAction(() => {
        res = true;
      });

      favoriteController.deleteMessageByGroupIds(context, [], [{
        groupId: '',
        isRcs: 1,
        msgId: ''
      }], false);

      expect(res).assertTrue();
    })

    it('favoriteController_deleteMessageByGroupIds_isRcs_0', 0, () => {
      let type: messageType = new messageType();
      type.isCbChecked = false;
      type.groupId = 1;
      type.content = 'xx';
      type.mmsSource = [{
        type: 3
      } as Mms];
      favoriteController.mmsListFromFavo = [type];

      mocker.mockFunc(favoriteController.favoriteList, favoriteController.favoriteList.refresh);
      mocker.mockFunc(ConversationService.getInstance(), ConversationService.getInstance().deleteSmsMmsInfoByCondition);

      favoriteController.deleteMessageByGroupIds(context, [], [{
        groupId: '',
        isRcs: 0,
        msgId: ''
      }], false);

      expect(favoriteController.isSelectStatus).assertFalse();
    })

    it('favoriteController_deleteMessageByGroupIds_groupInfos_undefined_isReSend_false', 0, () => {
      let type: messageType = new messageType();
      type.isCbChecked = false;
      type.groupId = 1;
      type.content = 'xx';
      type.mmsSource = [{
        type: 3
      } as Mms];
      favoriteController.mmsListFromFavo = [type];

      mocker.mockFunc(favoriteController.favoriteList, favoriteController.favoriteList.refresh);
      let res = false;
      when(mocker.mockFunc(ConversationService.getInstance(),
        ConversationService.getInstance().deleteSmsMmsInfoByCondition))
      (ArgumentMatchers.any).afterAction(() => {
        res = true;
      });

      favoriteController.deleteMessageByGroupIds(context, [], undefined, false);

      expect(res).assertTrue();
    })

    it('favoriteController_deleteMessageByGroupIds_groupInfos_undefined_isReSend_true', 0, () => {
      let type: messageType = new messageType();
      type.isCbChecked = false;
      type.groupId = 1;
      type.content = 'xx';
      type.mmsSource = [{
        type: 3
      } as Mms];
      favoriteController.mmsListFromFavo = [type];

      mocker.mockFunc(favoriteController.favoriteList, favoriteController.favoriteList.refresh);
      let res = false;
      when(mocker.mockFunc(ConversationService.getInstance(),
        ConversationService.getInstance().deleteSmsMmsInfoByCondition))
      (ArgumentMatchers.any).afterAction(() => {
        res = true;
      });

      favoriteController.deleteMessageByGroupIds(context, [], undefined, true);

      expect(res).assertTrue();
    })

    it('favoriteController_setMessageCheckAll_isSelectStatus_false', 0, () => {
      favoriteController.isSelectStatus = false;

      favoriteController.setMessageCheckAll(1);

      expect(favoriteController.hasReport).assertFalse();
    })

    it('favoriteController_setMessageCheckAll_type_1_isCbChecked_false', 0, () => {
      let type: messageType = new messageType();
      type.isCbChecked = false;
      type.hasMms = false;
      type.groupId = 1;
      type.content = 'xx';
      type.mmsSource = [{
        type: 3
      } as Mms];
      favoriteController.mmsListFromFavo = [type];
      favoriteController.isSelectStatus = true;
      favoriteController.selectDeleteMsgCount = 0;
      mocker.mockFunc(favoriteController.favoriteList, favoriteController.favoriteList.selectData);

      favoriteController.setMessageCheckAll(1);
      mocker.clear(favoriteController.favoriteList)

      expect(favoriteController.hasReport).assertFalse();
    })

    it('favoriteController_setMessageCheckAll_type_1_isCbChecked_true', 0, () => {
      let type: messageType = new messageType();
      type.isCbChecked = true;
      type.hasMms = true;
      type.groupId = 1;
      type.content = 'xx';
      type.mmsSource = [{
        type: 3
      } as Mms];
      favoriteController.mmsListFromFavo = [type];
      favoriteController.isSelectStatus = true;
      favoriteController.selectDeleteMsgCount = 3;

      mocker.mockFunc(favoriteController, favoriteController.checkBoxSelectUnknow);
      mocker.mockFunc(favoriteController.favoriteList, favoriteController.favoriteList.selectData);

      favoriteController.setMessageCheckAll(1);
      mocker.clear(favoriteController.favoriteList)
      expect(favoriteController.isMessageCheckAll).assertTrue();
    })

    it('favoriteController_setMessageCheckAll_type_2', 0, () => {
      let type: messageType = new messageType();
      type.isCbChecked = true;
      type.hasMms = true;
      type.groupId = 1;
      type.content = 'xx';
      type.mmsSource = [{
        type: 3
      } as Mms];
      favoriteController.mmsListFromFavo = [type];
      favoriteController.isSelectStatus = true;
      favoriteController.selectDeleteMsgCount = 3;

      mocker.mockFunc(favoriteController, favoriteController.checkBoxSelectUnknow);

      favoriteController.setMessageCheckAll(2);

      expect(favoriteController.isSelectStatus).assertTrue();
    })

    it('favoriteController_setMessageCheckAll_type_3', 0, () => {
      mocker.mockFunc(favoriteController, favoriteController.checkBoxSelectUnknow);

      favoriteController.setMessageCheckAll(3);

      expect(favoriteController.hasReport).assertFalse();
    })

    it('favoriteController_checkBoxSelectUnknow', 0, () => {
      let type: messageType = new messageType();
      type.isCbChecked = true;
      type.hasReport = true;
      favoriteController.mmsListFromFavo = [type];

      favoriteController.selectDeleteMsgCount = 1;

      favoriteController.checkBoxSelectUnknow();

      expect(favoriteController.hasReport).assertTrue();
    })

    it('favoriteController_checkBoxSelectUnknow_isCbChecked_false', 0, () => {
      let type: messageType = new messageType();
      type.isCbChecked = false;
      type.hasReport = false;

      favoriteController.mmsListFromFavo = [type];

      favoriteController.selectDeleteMsgCount = 1;

      favoriteController.checkBoxSelectUnknow();

      expect(favoriteController.hasReport).assertFalse();
    })

    it('favoriteController_getMmsCount', 0, () => {
      let type: messageType = new messageType();
      type.isCbChecked = false;
      type.mmsPdu = '';
      type.hasReport = false;

      let type1: messageType = new messageType();
      type1.isCbChecked = true;
      type1.mmsPdu = 'xx';
      type1.hasReport = false;

      favoriteController.mmsListFromFavo = [type, type1];

      favoriteController.selectDeleteMsgCount = 1;

      expect(favoriteController.getMmsCount()).assertTrue();
    })

    it('favoriteController_onInit', 0, () => {
      let pageInfo: NavPathStack = new NavPathStack();
      pageInfo.pushPathByName('name', {} as LooseObject);

      favoriteController.onInit(pageInfo);

      expect(JSON.stringify(favoriteController.pageInfos.getIndexByName('name'))).assertEqual('[0]');
    })

    it('favoriteController_copyText_selectDeleteMsgCount_2', 0, () => {
      mocker.mockFunc(favoriteController, favoriteController.copyMultipeText);

      favoriteController.selectDeleteMsgCount = 2;
      let selectList1: Array<messageType> = [new messageType(), new messageType(), new messageType()];
      favoriteController.favoriteList.selectList = selectList1;
      favoriteController.copyText();

      mocker.verify('copyMultipeText', []).once();
    })

    it('favoriteController_copyText_selectDeleteMsgCount_0', 0, () => {
      let type: messageType = new messageType();
      type.content = '';

      favoriteController.mmsListFromFavo = [type];
      favoriteController.mmsIndex = 0;

      mocker.mockFunc(commonPasteboard, commonPasteboard.setPasteboard);

      favoriteController.selectDeleteMsgCount = 0;

      favoriteController.copyText();

      mocker.clear(commonPasteboard);
      mocker.verify('copyMultipeText', []).never();
    })

    it('favoriteController_copyMultipeText', 0, () => {
      let type: messageType = new messageType();
      type.isCbChecked = false;
      type.msgContent = '';

      let type1: messageType = new messageType();
      type1.isCbChecked = true;
      type1.msgContent = '';

      favoriteController.mmsListFromFavo = [type, type1];
      favoriteController.mmsIndex = 0;

      let result = false;
      when(mocker.mockFunc(commonPasteboard, commonPasteboard.setPasteboard))(ArgumentMatchers.any)
        .afterAction(() => {
          result = true;
        });

      favoriteController.selectDeleteMsgCount = 0;

      favoriteController.copyMultipeText();

      expect(result).assertTrue();
      mocker.clear(commonPasteboard);
    })

    it('favoriteController_pushToCopyController', 0, () => {
      favoriteController.mmsListFromFavo = [{
        msgContent: ''
      } as messageType];
      favoriteController.pushToCopyController(0);

      expect(JSON.stringify(favoriteController.pageInfos.getParamByName('CopyView')))
        .assertEqual('[{"info":"","isFromConversation":true}]');
    })

    it('favoriteController_gotoTextSelect', 0, () => {
      mocker.mockFunc(favoriteController, favoriteController.pushToCopyController);

      favoriteController.gotoTextSelect(0);

      mocker.verify('pushToCopyController', [0]).once();
    })

    it('favoriteController_longPressSelected_index_0', 0, () => {
      mocker.mockFunc(favoriteController, favoriteController.copyText);

      favoriteController.longPressSelected(0);

      mocker.verify('copyText', []).once();
    })

    it('favoriteController_longPressSelected_index_1', 0, () => {
      favoriteController.mmsIndex = 1;

      mocker.mockFunc(favoriteController, favoriteController.transmitMsg);

      favoriteController.longPressSelected(1);

      mocker.verify('transmitMsg', [1]).never();
    })

    it('favoriteController_longPressSelected_index_3', 0, () => {
      favoriteController.mmsIndex = 1;

      mocker.mockFunc(favoriteController, favoriteController.gotoTextSelect);

      favoriteController.longPressSelected(3);

      mocker.verify('gotoTextSelect', [1]).once();
    })

    it('favoriteController_longPressSelected_index_4', 0, () => {
      mocker.mockFunc(favoriteController, favoriteController.more);

      favoriteController.longPressSelected(4);

      mocker.verify('more', []).once();
    })

    it('favoriteController_longPressSelected_index_2', 0, () => {
      mocker.mockFunc(favoriteController, favoriteController.more);

      favoriteController.longPressSelected(2);

      mocker.verify('more', []).never();
    })

    it('favoriteController_more_isCbChecked_false_hasMms_true', 0, () => {
      let type: messageType = new messageType();
      type.isCbChecked = false;
      type.msgContent = '';
      type.hasReport = false;

      let type1: messageType = new messageType();
      type1.isCbChecked = false;
      type1.hasMms = true;
      type.hasReport = false;

      favoriteController.mmsListFromFavo = [type, type1];

      mocker.mockFunc(favoriteController, favoriteController.setTabOperationStatus);

      favoriteController.more();

      expect(favoriteController.mmsCount).assertEqual(1);
    })

    it('favoriteController_more_isCbChecked_false_hasMms_false', 0, () => {
      let type: messageType = new messageType();
      type.isCbChecked = false;
      type.msgContent = '';
      type.hasReport = false;

      let type1: messageType = new messageType();
      type1.isCbChecked = false;
      type1.hasMms = false;
      type1.hasReport = false;

      favoriteController.mmsListFromFavo = [type, type1];
      favoriteController.mmsCount = 0;

      mocker.mockFunc(favoriteController, favoriteController.setTabOperationStatus);
      mocker.mockFunc(favoriteController, favoriteController.setSelectStatus);
      mocker.mockFunc(favoriteController, favoriteController.setMessageCheckAll);
      mocker.mockFunc(favoriteController, favoriteController.setGroupMoreMenu);
      mocker.mockFunc(favoriteController.conversationListDataSource,
        favoriteController.conversationListDataSource.refresh);

      favoriteController.more();

      expect(favoriteController.mmsCount).assertEqual(0);

      mocker.clear(favoriteController.conversationListDataSource);
    })

    it('favoriteController_setTabOperationStatus_flag_true', 0, () => {
      favoriteController.setTabOperationStatus(true);

      expect(favoriteController.sendBarMarginBottom).assertEqual(550);
    })

    it('favoriteController_setTabOperationStatus_flag_false', 0, () => {
      favoriteController.setTabOperationStatus(false);

      expect(favoriteController.sendBarMarginBottom).assertEqual(0);
    })

    it('favoriteController_shareMmsMessage', 0, () => {
      let target: messageType = new messageType();
      target.mmsSource = [{
        type: 1,
        path: ''
      } as Mms, {
        type: 0,
        path: 'xx'
      } as Mms,
        {
          type: -1,
          path: 'xx'
        } as Mms];

      favoriteController.shareMmsMessage(target);

      expect(favoriteController.shareMmsMessage(target)).assertUndefined();
    })

    it('favoriteController_shareMessagee_undefined', 0, () => {
      let type: messageType = new messageType();
      type.isCbChecked = false;
      type.msgContent = '';
      type.hasReport = false;
      favoriteController.mmsListFromFavo = [type];

      let res = false;
      when(mocker.mockFunc(favoriteController, favoriteController.shareMmsMessage))(ArgumentMatchers.any)
        .afterAction(() => {
          res = true;
          return {} as systemShare.SharedData;
        })

      favoriteController.shareMessage();

      expect(res).assertFalse();
    })

    it('favoriteController_shareMessagee_isMsm_true', 0, () => {
      let type: messageType = new messageType();
      type.isCbChecked = true;
      type.isMsm = true;
      favoriteController.mmsListFromFavo = [type];

      let res = false;
      when(mocker.mockFunc(favoriteController, favoriteController.shareMmsMessage))(ArgumentMatchers.any)
        .afterAction(() => {
          res = true;
          return {} as systemShare.SharedData;
        });

      favoriteController.shareMessage();

      expect(res).assertTrue();
    })

    it('favoriteController_shareMessagee_isMsm_false', 0, () => {
      let type: messageType = new messageType();
      type.isCbChecked = true;
      type.isMsm = false;
      favoriteController.mmsListFromFavo = [type];

      let res = false;
      when(mocker.mockFunc(favoriteController, favoriteController.shareMmsMessage))(ArgumentMatchers.any)
        .afterAction(() => {
          res = true;
          return {} as systemShare.SharedData;
        });

      favoriteController.shareMessage();

      expect(res).assertFalse();
    })

    it('favoriteController_isNeedTransmitTip_hasMms_true', 0, () => {
      let type: messageType = new messageType();
      type.isCbChecked = true;
      type.hasMms = true;
      type.mmsSource = [{
        type: 3
      } as Mms];

      let type1: messageType = new messageType();
      type1.isCbChecked = true;
      type1.hasMms = false;
      type1.mmsSource = [{
        type: 2
      } as Mms];

      favoriteController.mmsListFromFavo = [type, type1];

      expect(favoriteController.isNeedTransmitTip()).assertTrue();
    })

    it('favoriteController_isNeedTransmitTip_hasMms_true_return_true', 0, () => {
      let type: messageType = new messageType();
      type.isCbChecked = true;
      type.hasMms = true;
      type.mmsSource = [{
        type: 3
      } as Mms, {
        type: 3
      } as Mms, {
        type: 3
      } as Mms];

      let type1: messageType = new messageType();
      type1.isCbChecked = true;
      type1.hasMms = false;
      type1.mmsSource = [{
        type: 2
      } as Mms];

      favoriteController.mmsListFromFavo = [type, type1];

      expect(favoriteController.isNeedTransmitTip()).assertFalse();
    })

    it('favoriteController_isNeedTransmitTip_hasMms_false', 0, () => {
      let type1: messageType = new messageType();
      type1.isCbChecked = true;
      type1.hasMms = false;
      type1.mmsSource = [{
        type: 2
      } as Mms];

      favoriteController.mmsListFromFavo = [type1];

      expect(favoriteController.isNeedTransmitTip()).assertFalse();
    })

    it('favoriteController_filterAudio_type_3', 0, () => {
      let mmsArr: Mms[] = [{
        type: 3
      } as Mms];

      expect(favoriteController.filterAudio(mmsArr)).assertFalse();
    })

    it('favoriteController_filterAudio_type_2', 0, () => {
      let mmsArr: Mms[] = [{
        type: 2
      } as Mms];

      expect(favoriteController.filterAudio(mmsArr)).assertTrue();
    })

    it('favoriteController_filterAttachmentAndSmil_mmsArr_length_3', 0, () => {
      let item: messageType = new messageType();
      item.isCbChecked = true;
      item.hasMms = true;
      item.mmsSource = [{
        type: 2
      } as Mms, {
        type: 2
      } as Mms, {
        type: 2
      } as Mms];

      favoriteController.audioStatus = 0;

      expect(favoriteController.filterAttachmentAndSmil(item)).assertTrue();
    })

    it('favoriteController_filterAttachmentAndSmil_mmsArr_length_1', 0, () => {
      let item: messageType = new messageType();
      item.isCbChecked = true;
      item.hasMms = true;
      item.mmsSource = [{
        type: 2
      } as Mms];

      when(mocker.mockFunc(favoriteController, favoriteController.filterAudio))(ArgumentMatchers.any)
        .afterReturn(true);

      favoriteController.audioStatus = 0;

      expect(favoriteController.filterAttachmentAndSmil(item)).assertTrue();
    })

    it('favoriteController_filterAttachmentAndSmil_hasMms_false', 0, () => {
      let item: messageType = new messageType();
      item.isCbChecked = true;
      item.hasMms = false;
      item.mmsSource = [{
        type: 2
      } as Mms];

      favoriteController.audioStatus = 0;

      expect(favoriteController.filterAttachmentAndSmil(item)).assertTrue();
    })

    it('favoriteController_filterAttachmentAndSmil_isCbChecked_false', 0, () => {
      let item: messageType = new messageType();
      item.isCbChecked = false;
      item.hasMms = false;
      item.mmsSource = [{
        type: 2
      } as Mms];

      favoriteController.audioStatus = 0;

      expect(favoriteController.filterAttachmentAndSmil(item)).assertFalse();
    })

    it('favoriteController_filerSelected', 0, () => {
      let type1: messageType = new messageType();
      type1.isCbChecked = true;
      type1.hasMms = false;
      type1.mmsSource = [{
        type: 2
      } as Mms];

      favoriteController.mmsListFromFavo = [type1];

      expect(favoriteController.filerSelected(0).length).assertEqual(1);
    })

    it('favoriteController_filerSelected_index_4_filterAttachmentAndSmil_true', 0, () => {
      let type1: messageType = new messageType();
      type1.isCbChecked = true;
      type1.hasMms = false;
      type1.mmsSource = [{
        type: 2
      } as Mms];

      when(mocker.mockFunc(favoriteController, favoriteController.filterAttachmentAndSmil))(ArgumentMatchers.any)
        .afterReturn(true);

      favoriteController.mmsListFromFavo = [type1];

      expect(favoriteController.filerSelected(4).length).assertEqual(1);
    })

    it('favoriteController_filerSelected_index_4_filterAttachmentAndSmil_false', 0, () => {
      let type1: messageType = new messageType();
      type1.isCbChecked = true;
      type1.hasMms = false;
      type1.mmsSource = [{
        type: 2
      } as Mms];

      when(mocker.mockFunc(favoriteController, favoriteController.filterAttachmentAndSmil))(ArgumentMatchers.any)
        .afterReturn(false);

      favoriteController.mmsListFromFavo = [type1];

      expect(favoriteController.filerSelected(4).length).assertEqual(0);
    })

    it('favoriteController_createTransmitContentDetail_index_0', 0, () => {
      let type1: messageType = new messageType();
      type1.msgContent = '';

      expect(favoriteController.createTransmitContentDetail(type1, 0)).assertEqual('');
    })

    it('favoriteController_createTransmitContentDetail_index_1', 0, () => {
      let type1: messageType = new messageType();
      type1.msgContent = '';

      expect(favoriteController.createTransmitContentDetail(type1, 1)).assertEqual('\n' + ' ' + '\n');
    })

    it('favoriteController_transmitMsg_isReceive_True', 0, () => {
      let type1: messageType = new messageType();
      type1.senderNumber = '570977632';
      type1.name = 'name';
      type1.isReceive = true;
      type1.hasMms = true;

      let getObject: Function = mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject);
      when(getObject)('mmsContext').afterReturn({
        resourceManager: {
          getStringSync: (resource: Resource, ...args: (string | number)[]): string => 'title'
        } as resourceManager.ResourceManager
      } as Object | window.WindowStage);

      when(mocker.mockFunc(favoriteController, favoriteController.filerSelected))(ArgumentMatchers.any)
        .afterReturn([type1, type1]);
      when(mocker.mockFunc(favoriteController, favoriteController.nameNoPicture))(ArgumentMatchers.any)
        .afterReturn(type1);
      when(mocker.mockFunc(favoriteController, favoriteController.transmitObj))(ArgumentMatchers.any).afterReturn({
        info: ''
      } as LooseObject);
      when(mocker.mockFunc(favoriteController, favoriteController.createStatus))(ArgumentMatchers.any).afterReturn(1);
      mocker.mockFunc(favoriteController, favoriteController.jumpTransmitMsg);

      favoriteController.transmitMsg(0);

      mocker.verify('filerSelected', [0]).once();
    })

    it('favoriteController_transmitMsg_isReceive_false', 0, () => {
      let type1: messageType = new messageType();
      type1.senderNumber = '570977632';
      type1.name = 'name';
      type1.isReceive = false;
      type1.hasMms = true;

      let getObject: Function = mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject);
      when(getObject)('mmsContext').afterReturn({
        resourceManager: {
          getStringSync: (resource: Resource): string => 'title'
        } as resourceManager.ResourceManager
      } as Object | window.WindowStage);

      when(mocker.mockFunc(favoriteController, favoriteController.filerSelected))(ArgumentMatchers.any)
        .afterReturn([type1, type1]);
      when(mocker.mockFunc(favoriteController, favoriteController.nameNoPicture))(ArgumentMatchers.any)
        .afterReturn(type1);
      when(mocker.mockFunc(favoriteController, favoriteController.transmitObj))(ArgumentMatchers.any).afterReturn({
        info: ''
      } as LooseObject);
      when(mocker.mockFunc(favoriteController, favoriteController.createStatus))(ArgumentMatchers.any).afterReturn(1);
      mocker.mockFunc(favoriteController, favoriteController.jumpTransmitMsg);

      favoriteController.transmitMsg(0);

      mocker.verify('filerSelected', [0]).once();
    })

    it('favoriteController_transmitObj', 0, () => {
      let type1: messageType = new messageType();
      type1.isRcs = 1;
      type1.msgContent = '';
      type1.hasMms = false;
      type1.contentType = 1;

      when(mocker.mockFunc(favoriteController, favoriteController.getTransmitSource))(ArgumentMatchers.any)
        .afterReturn([{} as Mms]);

      let res: LooseObject = favoriteController.transmitObj(type1, null)

      expect(res.contentType).assertEqual(1);
    })

    it('favoriteController_createStatus_mmsNumber_1', 0, () => {
      let type1: messageType = new messageType();
      type1.isRcs = 1;
      type1.msgContent = '';
      type1.hasMms = false;
      type1.contentType = 1;

      let res: number = favoriteController.createStatus([type1], 1)

      expect(res).assertEqual(1);
    })

    it('favoriteController_createStatus_mmsNumber_1_selectedArr_length_2', 0, () => {
      let type1: messageType = new messageType();
      type1.isRcs = 1;
      type1.msgContent = '';
      type1.hasMms = false;
      type1.contentType = 1;

      let res: number = favoriteController.createStatus([type1, type1], 1)

      expect(res).assertEqual(2);
    })

    it('favoriteController_createStatus_mmsNumber_0', 0, () => {
      let type1: messageType = new messageType();
      type1.isRcs = 1;
      type1.msgContent = '';
      type1.hasMms = false;
      type1.contentType = 1;

      let res: number = favoriteController.createStatus([type1], 0)

      expect(res).assertEqual(0);
    })

    it('favoriteController_getTransmitInfo_isReceive_true', 0, () => {
      let type1: messageType = new messageType();
      type1.isRcs = 1;
      type1.msgContent = '';
      type1.hasMms = false;
      type1.contentType = 1;
      type1.isReceive = true;

      let res: string = favoriteController.getTransmitInfo(type1, '');

      expect(res.substring(0, 4)).assertEqual('1970');
    })

    it('favoriteController_getTransmitInfo_isReceive_false', 0, () => {
      let type1: messageType = new messageType();
      type1.isRcs = 1;
      type1.msgContent = '';
      type1.hasMms = false;
      type1.contentType = 1;
      type1.isReceive = false;
      let getObject: Function = mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject);
      when(getObject)('mmsContext').afterReturn({
        resourceManager: {
          getStringSync: (resource: Resource): string => 'title'
        } as resourceManager.ResourceManager
      } as Object | window.WindowStage);

      let res: string = favoriteController.getTransmitInfo(type1, '');

      expect(res.substring(0, 4)).assertEqual('1970');
    })

    it('favoriteController_getTransmitSource', 0, () => {
      let res: Mms[] = favoriteController.getTransmitSource([]);
      expect(res.length).assertEqual(0);
    })

    it('favoriteController_getTransmitSource_type_0', 0, () => {
      let res: Mms[] = favoriteController.getTransmitSource([{
        type: 0
      } as Mms]);
      expect(res.length).assertEqual(0);
    })

    it('favoriteController_getTransmitSource_type_1', 0, () => {
      let res: Mms[] = favoriteController.getTransmitSource([{
        type: 1
      } as Mms]);
      expect(res.length).assertEqual(1);
    })

    it('favoriteController_jumpTransmitMsg', 0, () => {
      favoriteController.jumpTransmitMsg('', '', [], 0);
      expect(JSON.stringify(favoriteController.pageInfos.getParamByName('TransmitMsg')))
        .assertEqual('[{"threadId":0,"doubleCard":false,"transmitContent":"","transmitContentList":[],"isMulti":true,"mmsStatus":0,"isMyStartPage":false,"transmitContentDetail":""}]');
    })
  })
}