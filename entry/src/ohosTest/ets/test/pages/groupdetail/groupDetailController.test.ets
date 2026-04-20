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
import LooseObject from '../../../../../main/ets/data/LooseObject';
import DataShareHelper from '../../../../../main/ets/model/repository/DataShareHelper';
import ConversationController, { mmsListType, ResultInfo } from '../../../../../main/ets/pages/conversation/conversationController';
import { ActionData } from '../../../../../main/ets/pages/conversationlist/conversationListController';
import GroupDetailController from '../../../../../main/ets/pages/groupdetail/groupDetailController';
import SharedPreferencesUtils from '../../../../../main/ets/utils/SharedPreferencesUtils';
import { dataShare, dataSharePredicates, DataShareResultSet } from '@kit.ArkData';
import MySet from '../../MySet';
import  { DateUtil } from '../../../../../main/ets/utils/DateUtil';
import conversationService from '../../../../../main/ets/service/ConversationService';
import MmsPreferences from '../../../../../main/ets/utils/MmsPreferences';
import { GlobalContext } from '../../../../../main/ets/MainAbility/GlobalHelper';
import ConversationListService from '../../../../../main/ets/service/ConversationListService';
import HiLog from '../../../../../main/ets/utils/HiLog';
import DotUtil from '../../../../../main/ets/utils/MmsDot/DotUtils';
import commonService, { StrTypeSet } from '../../../../../main/ets/service/CommonService';
import AvatarColor from '../../../../../main/ets/model/common/AvatarColor';
import { StartOptions, Want } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { DTGlobalContext } from '../../../testability/TestAbility';

export default function groupDetailControllerTest() {
  describe('groupDetailControllerTest', () => {

    const TAG = 'GroupDetailController';
    let groupDetailCtrl: GroupDetailController;
    let mocker: MockKit;
    let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;

    beforeEach(() => {
      groupDetailCtrl = GroupDetailController.getInstance();
      mocker = new MockKit();
    })

    afterEach(() => {
      mocker.clear(groupDetailCtrl);
    })

    it('GroupDetailController_onInit', 0, () => {
      mocker.mockFunc(groupDetailCtrl, groupDetailCtrl.initRouterData);

      groupDetailCtrl.onInit(new NavPathStack());

      mocker.verify('initRouterData', []).once();
    })

    it('GroupDetailController_onShow', 0, () => {
      mocker.mockFunc(groupDetailCtrl, groupDetailCtrl.queryContactSendDetail);

      groupDetailCtrl.onShow(context);

      mocker.verify('queryContactSendDetail', []).never();
    })

    it('GroupDetailController_onBackPress', 0, () => {
      let res = groupDetailCtrl.onBackPress(context);

      expect(res).assertEqual(true)
    })

    it('GroupDetailController_initRouterData', 0, () => {
      let pageInfos: NavPathStack = new NavPathStack();
      pageInfos.pushPathByName('GroupDetail', {
        groupId: 1,
        threadId: 1,
        content: "1111",
        slotId: 1
      } as LooseObject);
      groupDetailCtrl.pageInfos = pageInfos;

      groupDetailCtrl.initRouterData();

      expect(groupDetailCtrl.slotId).assertEqual(1);
    })

    it('GroupDetailController_queryContactSendDetail_success', 0, () => {
      let myset: DataShareResultSet = new MySet();
      myset.rowCount = 1;

      when(mocker.mockFunc(DataShareHelper.getInstance(),
        DataShareHelper.getInstance().initSmsDB))(ArgumentMatchers.any)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve(myset))
        } as dataShare.DataShareHelper)));

      when(mocker.mockFunc(DataShareHelper.getInstance(),
        DataShareHelper.getInstance().initContactDB))(ArgumentMatchers.any)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve(myset))
        } as dataShare.DataShareHelper)));

      mocker.mockFunc(groupDetailCtrl, groupDetailCtrl.convertTime);
      when(mocker.mockFunc(groupDetailCtrl, groupDetailCtrl.setAllResendBtnState))()
        .afterAction(() => {
          expect(groupDetailCtrl.groupList.length).assertEqual(1);
        });

      groupDetailCtrl.queryContactSendDetail(context);

      mocker.clear(DataShareHelper.getInstance());
    })

    it('GroupDetailController_queryContactSendDetail_fail', 0, () => {
      let myset: DataShareResultSet = new MySet();
      myset.rowCount = 1;

      when(mocker.mockFunc(DataShareHelper.getInstance(),
        DataShareHelper.getInstance().initSmsDB))(ArgumentMatchers.any)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(undefined)));

      mocker.mockFunc(groupDetailCtrl, groupDetailCtrl.convertTime);

      groupDetailCtrl.queryContactSendDetail(context);

      mocker.verify('convertTime', []).never();

      mocker.clear(DataShareHelper.getInstance());
    })

    it('GroupDetailController_convertTime', 0, () => {
      when(mocker.mockFunc(DateUtil, DateUtil.convertTimeStampToDateWeek))(ArgumentMatchers.any).afterReturnNothing;
      when(mocker.mockFunc(DateUtil, DateUtil.convertDateFormatForItem))(ArgumentMatchers.any).afterReturnNothing;

      let mmsListType: mmsListType = {} as mmsListType;
      let groupList: mmsListType[] = [mmsListType];
      groupDetailCtrl.convertTime(groupList);

      mocker.verify('convertDateFormatForItem', [mmsListType]).once();

      mocker.clear(DateUtil);
    })

    it('GroupDetailController_setAllResendBtnState_sendStatus_2', 0, () => {
      let listType: mmsListType = new mmsListType()
      listType.sendStatus = 2;
      groupDetailCtrl.groupList = [listType];

      groupDetailCtrl.setAllResendBtnState();

      expect(groupDetailCtrl.isAllResendBtnShow).assertTrue();
    })

    it('GroupDetailController_setAllResendBtnState_sendStatus_1', 0, () => {
      let listType: mmsListType = new mmsListType()
      listType.sendStatus = 1;
      groupDetailCtrl.groupList = [listType];

      groupDetailCtrl.setAllResendBtnState();

      expect(groupDetailCtrl.isAllResendBtnShow).assertFalse();
    })

    it('GroupDetailController_resendAll_sendStatus_2', 0, () => {
      let listType: mmsListType = new mmsListType();
      listType.sendStatus = 2;
      listType.telephone = "18812345678";
      groupDetailCtrl.groupList = [listType];

      mocker.mockFunc(groupDetailCtrl, groupDetailCtrl.updateItemStatus);
      mocker.mockFunc(groupDetailCtrl, groupDetailCtrl.refreshGroupList);
      mocker.mockFunc(groupDetailCtrl, groupDetailCtrl.updateConversationListStatus);
      mocker.mockFunc(groupDetailCtrl, groupDetailCtrl.resendSms);

      groupDetailCtrl.resendAll(context);

      expect(groupDetailCtrl.resendCount).assertEqual(0);
    })

    it('GroupDetailController_resendAll_sendStatus_1', 0, () => {
      let listType: mmsListType = new mmsListType();
      listType.sendStatus = 1;
      listType.telephone = "18812345678";
      groupDetailCtrl.groupList = [listType];

      mocker.mockFunc(groupDetailCtrl, groupDetailCtrl.updateItemStatus);
      mocker.mockFunc(groupDetailCtrl, groupDetailCtrl.refreshGroupList);
      mocker.mockFunc(groupDetailCtrl, groupDetailCtrl.updateConversationListStatus);
      mocker.mockFunc(groupDetailCtrl, groupDetailCtrl.resendSms);

      groupDetailCtrl.resendAll(context);

      expect(groupDetailCtrl.resendCount).assertEqual(0);
    })

    it('GroupDetailController_updateItemStatus_deliveryReportSwitch_3', 0, () => {
      let listType: mmsListType = new mmsListType();
      listType.sendStatus = 1;
      listType.telephone = "18812345678";
      groupDetailCtrl.groupList = [listType];

      mocker.mockFunc(conversationService.getInstance(), conversationService.getInstance().updateSmsMmsInfoByCondition);
      mocker.mockFunc(groupDetailCtrl, groupDetailCtrl.showToast);
      when(mocker.mockFunc(MmsPreferences.getInstance(), MmsPreferences.getInstance().getValueOfDeliveryReportSwitch))()
        .afterReturn('3');

      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('mmsContext')
        .afterReturn({
          resourceManager: {
            getStringSync: (resource: Resource, ...args: (string | number)[]): string => ''
          }
        });

      groupDetailCtrl.updateItemStatus(context, {} as LooseObject, 0, 0);

      mocker.verify('showToast', ['']).once();

      mocker.clear(conversationService.getInstance());
      mocker.clear(MmsPreferences.getInstance());
      mocker.clear(GlobalContext.getContext());
    })

    it('GroupDetailController_updateItemStatus_deliveryReportSwitch_1', 0, () => {
      let listType: mmsListType = new mmsListType();
      listType.sendStatus = 1;
      listType.telephone = "18812345678";
      groupDetailCtrl.groupList = [listType];

      mocker.mockFunc(conversationService.getInstance(), conversationService.getInstance().updateSmsMmsInfoByCondition);
      mocker.mockFunc(groupDetailCtrl, groupDetailCtrl.showToast);
      when(mocker.mockFunc(MmsPreferences.getInstance(), MmsPreferences.getInstance().getValueOfDeliveryReportSwitch))()
        .afterReturn('1');

      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('mmsContext')
        .afterReturn({
          resourceManager: {
            getStringSync: (resource: Resource, ...args: (string | number)[]): string => ''
          }
        });

      groupDetailCtrl.updateItemStatus(context, {} as LooseObject, 0, 0);

      mocker.verify('showToast', ['']).once();

      mocker.clear(conversationService.getInstance());
      mocker.clear(MmsPreferences.getInstance());
      mocker.clear(GlobalContext.getContext());
    })

    it('GroupDetailController_updateItemStatus_deliveryReportSwitch_0', 0, () => {
      let listType: mmsListType = new mmsListType();
      listType.sendStatus = 1;
      listType.telephone = "18812345678";
      groupDetailCtrl.groupList = [listType];

      mocker.mockFunc(conversationService.getInstance(), conversationService.getInstance().updateSmsMmsInfoByCondition);
      mocker.mockFunc(groupDetailCtrl, groupDetailCtrl.showToast);
      when(mocker.mockFunc(MmsPreferences.getInstance(), MmsPreferences.getInstance().getValueOfDeliveryReportSwitch))()
        .afterReturn('0');

      groupDetailCtrl.updateItemStatus(context, {} as LooseObject, 0, 1);

      mocker.verify('showToast', ['']).never();

      mocker.clear(conversationService.getInstance());
      mocker.clear(MmsPreferences.getInstance());
    })

    it('GroupDetailController_updateConversationListStatus', 0, () => {
      mocker.mockFunc(ConversationListService.getInstance(),
        ConversationListService.getInstance().updateSessionByCondition);
      mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().setObject);

      groupDetailCtrl.updateConversationListStatus(context, 2);

      mocker.verify('setObject', ['needToUpdate', true]).once();

      mocker.clear(ConversationListService.getInstance());
      mocker.clear(GlobalContext.getContext());
    })

    it('GroupDetailController_updateConversationListStatus_time', 0, () => {
      mocker.mockFunc(ConversationListService.getInstance(),
        ConversationListService.getInstance().updateSessionByCondition);
      mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().setObject);

      groupDetailCtrl.updateConversationListStatus(context, 2,1);

      mocker.verify('setObject', ['needToUpdate', true]).once();

      mocker.clear(ConversationListService.getInstance());
      mocker.clear(GlobalContext.getContext());
    })

    it('GroupDetailController_resendSms_isRcsStateOpen_true', 0, () => {
      let listType: mmsListType = new mmsListType();
      listType.telephone = "18812345678";
      listType.isRcs = 1;
      let content: string = "hello";
      let telephoneLength: number = 11;
      SharedPreferencesUtils.saveToPreferences('isOpenRcs', true)
      groupDetailCtrl.slotId = 1;

      let mConversationCtrl = ConversationController.getInstance();
      mConversationCtrl.isRcsMms = true;

      mocker.mockFunc(groupDetailCtrl, groupDetailCtrl.dealSendResult);
      mocker.mockFunc(groupDetailCtrl, groupDetailCtrl.setAllResendBtnState);
      mocker.mockFunc(HiLog, HiLog.i);

      groupDetailCtrl.resendSms(context, listType, content, telephoneLength);

      mConversationCtrl.isRcsMms = false;
      mocker.verify('i', [TAG, `resendSms IsRcsStateOpen: true`]).once();
      mocker.clear(HiLog);
    })

    it('GroupDetailController_resendSms_isRcsStateOpen_false', 0, () => {
      let listType: mmsListType = new mmsListType();
      listType.telephone = "18812345678";
      listType.rcsType = 1;
      listType.isRcs = 1;
      let content: string = "hello";
      let telephoneLength: number = 11;
      SharedPreferencesUtils.saveToPreferences('isOpenRcs', true)
      groupDetailCtrl.slotId = 1;

      let getFromPreferences: Function =
        mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences);

      when(getFromPreferences)('isOpenRcs').afterReturn(false);

      when(getFromPreferences)('deliveryReportSwitch').afterThrow('error');

      let mConversationCtrl = ConversationController.getInstance();
      mConversationCtrl.isRcsMms = true;
      mocker.mockFunc(groupDetailCtrl, groupDetailCtrl.dealSendResult);
      mocker.mockFunc(groupDetailCtrl, groupDetailCtrl.setAllResendBtnState);
      mocker.mockFunc(DotUtil.getInstance(), DotUtil.getInstance().reportFaultEvent);
      mocker.mockFunc(HiLog, HiLog.i);

      groupDetailCtrl.resendSms(context, listType, content, telephoneLength);

      mocker.verify('i', [TAG, `resendSms IsRcsStateOpen: true`]).once();

      mConversationCtrl.isRcsMms = false;
      mocker.clear(SharedPreferencesUtils);
      mocker.clear(DotUtil.getInstance());
      mocker.clear(HiLog);
    })

    it('GroupDetailController_refreshGroupList', 0, () => {
      let listType: mmsListType = new mmsListType();
      groupDetailCtrl.groupList = [listType];

      groupDetailCtrl.refreshGroupList();

      expect(groupDetailCtrl.groupList.length).assertEqual(1);
    })

    it('GroupDetailController_dealSendResult_if', 0, () => {
      let listType: mmsListType = new mmsListType();
      listType.telephone = "18812345678";
      listType.sendStatus = 1;

      let listType1: mmsListType = new mmsListType();
      listType1.telephone = "18812345678";
      listType1.sendStatus = 1;

      let listType2: mmsListType = new mmsListType();
      listType2.telephone = "18812345678";
      listType2.sendStatus = 2;

      groupDetailCtrl.groupList = [listType, listType1, listType2];
      groupDetailCtrl.resendIndex = 1;

      mocker.mockFunc(DateUtil, DateUtil.convertTimeStampToDateWeek);
      mocker.mockFunc(DateUtil, DateUtil.fullDate);
      mocker.mockFunc(groupDetailCtrl, groupDetailCtrl.updateItemStatus);
      mocker.mockFunc(groupDetailCtrl, groupDetailCtrl.updateConversationListStatus);

      groupDetailCtrl.dealSendResult(context, 1, listType, 1);

      expect(groupDetailCtrl.resendIndex).assertEqual(-1);

      mocker.clear(DateUtil);
    })

    it('GroupDetailController_dealSendResult_failedNumber_0', 0, () => {
      let listType: mmsListType = new mmsListType();
      listType.telephone = "18812345678";
      listType.sendStatus = 3;

      groupDetailCtrl.groupList = [listType];
      groupDetailCtrl.resendIndex = 1;

      mocker.mockFunc(DateUtil, DateUtil.convertTimeStampToDateWeek);
      mocker.mockFunc(DateUtil, DateUtil.fullDate);
      mocker.mockFunc(groupDetailCtrl, groupDetailCtrl.updateItemStatus);
      mocker.mockFunc(groupDetailCtrl, groupDetailCtrl.updateConversationListStatus);
      mocker.mockFunc(groupDetailCtrl, groupDetailCtrl.refreshGroupList);

      groupDetailCtrl.dealSendResult(context, 1, listType, 0);

      expect(groupDetailCtrl.resendIndex).assertEqual(-1);

      mocker.clear(DateUtil);
    })

    it('GroupDetailController_dealSendResult_failedNumber_1', 0, () => {
      let listType: mmsListType = new mmsListType();
      listType.telephone = "18812345678";
      listType.sendStatus = 2;

      groupDetailCtrl.groupList = [listType];
      groupDetailCtrl.resendIndex = 0;

      mocker.mockFunc(DateUtil, DateUtil.convertTimeStampToDateWeek);
      mocker.mockFunc(DateUtil, DateUtil.fullDate);
      mocker.mockFunc(groupDetailCtrl, groupDetailCtrl.updateItemStatus);
      mocker.mockFunc(groupDetailCtrl, groupDetailCtrl.updateConversationListStatus);
      mocker.mockFunc(groupDetailCtrl, groupDetailCtrl.refreshGroupList);

      groupDetailCtrl.dealSendResult(context, 1, listType, 1);

      expect(groupDetailCtrl.resendIndex).assertEqual(-1);

      mocker.clear(DateUtil);
    })

    it('GroupDetailController_dealSendResult_telephoneLength_3', 0, () => {
      let listType: mmsListType = new mmsListType();
      listType.telephone = "18812345678";
      listType.sendStatus = 2;

      groupDetailCtrl.groupList = [listType];
      groupDetailCtrl.resendIndex = 1;

      mocker.mockFunc(DateUtil, DateUtil.convertTimeStampToDateWeek);
      mocker.mockFunc(DateUtil, DateUtil.fullDate);
      mocker.mockFunc(groupDetailCtrl, groupDetailCtrl.updateItemStatus);
      mocker.mockFunc(groupDetailCtrl, groupDetailCtrl.refreshGroupList);

      groupDetailCtrl.dealSendResult(context, 1, listType, 3);

      expect(groupDetailCtrl.resendIndex).assertEqual(-1);

      mocker.clear(DateUtil);
    })

    it('GroupDetailController_getPhotoName_index_0', 0, () => {
      groupDetailCtrl.groupList = [new mmsListType()];
      let group: LooseObject = groupDetailCtrl.groupList[0];
      group.photoFirstNames = ['name'];

      expect(groupDetailCtrl.getPhotoName(0)).assertUndefined();
    })

    it('GroupDetailController_getPhotoName_index_0_photoFirstNames_empty', 0, () => {
      groupDetailCtrl.groupList = [new mmsListType()];
      let group: LooseObject = groupDetailCtrl.groupList[0];
      group.photoFirstNames = [];

      expect(groupDetailCtrl.getPhotoName(0)).assertEqual('');
    })

    it('GroupDetailController_getPhotoName_index_1', 0, () => {
      groupDetailCtrl.groupList = [new mmsListType()];
      let group: LooseObject = groupDetailCtrl.groupList[0];
      group.photoFirstNames = [];

      expect(groupDetailCtrl.getPhotoName(1)).assertEqual('');
    })

    it('GroupDetailController_getPortraitColor_index_0', 0, () => {
      let listType: mmsListType = new mmsListType();
      listType.telephone = '777';
      groupDetailCtrl.groupList = [listType];
      let group: LooseObject = groupDetailCtrl.groupList[0];
      group.photoFirstNames = [{
        portraitColor: 'xx',
      }];
      groupDetailCtrl.threadId = 1;

      expect(groupDetailCtrl.getPortraitColor(0)).assertEqual('xx');
    })

    it('GroupDetailController_getPortraitColor_portraitColor_empty', 0, () => {
      let listType: mmsListType = new mmsListType();
      groupDetailCtrl.groupList = [listType];
      let group: LooseObject = groupDetailCtrl.groupList[0];
      group.photoFirstNames = [{
        portraitColor: '',
      }];
      groupDetailCtrl.threadId = 1;

      expect(JSON.stringify(groupDetailCtrl.getPortraitColor(0)))
        .assertEqual(JSON.stringify(AvatarColor.background.Color[1]));
    })

    it('GroupDetailController_getPortraitColor_telephone', 0, () => {
      let listType: mmsListType = new mmsListType();
      listType.telephone = '11111';
      groupDetailCtrl.groupList = [listType];
      let group: LooseObject = groupDetailCtrl.groupList[0];
      group.photoFirstNames = [{
        portraitColor: '',
      }];
      groupDetailCtrl.threadId = 1;

      expect(JSON.stringify(groupDetailCtrl.getPortraitColor(0)))
        .assertEqual(JSON.stringify(AvatarColor.background.Color[1]));
    })

    it('GroupDetailController_getPortraitColor_photoNames_empty', 0, () => {
      let listType: mmsListType = new mmsListType();
      groupDetailCtrl.groupList = [listType];
      let group: LooseObject = groupDetailCtrl.groupList[0];
      group.photoFirstNames = [];
      groupDetailCtrl.threadId = 1;

      expect(JSON.stringify(groupDetailCtrl.getPortraitColor(0)))
        .assertEqual(JSON.stringify(AvatarColor.background.Color[1]));
    })

    it('GroupDetailController_getPortraitColor_index_2', 0, () => {
      let listType: mmsListType = new mmsListType();
      groupDetailCtrl.groupList = [listType];
      let group: LooseObject = groupDetailCtrl.groupList[0];
      group.photoFirstNames = [];
      groupDetailCtrl.threadId = 1;

      expect(JSON.stringify(groupDetailCtrl.getPortraitColor(2)))
        .assertEqual(JSON.stringify(AvatarColor.background.Color[1]));
    })

    it('GroupDetailController_setResendIndex', 0, () => {
      groupDetailCtrl.setResendIndex(0);

      expect(groupDetailCtrl.resendIndex).assertEqual(0);
    })

    it('GroupDetailController_resendMsg_resendIndex_minus1', 0, () => {
      groupDetailCtrl.resendIndex = -1;

      groupDetailCtrl.resendMsg(context);

      expect(groupDetailCtrl.resendCount).assertEqual(4);
    })

    it('GroupDetailController_resendMsg_resendIndex_0', 0, () => {
      groupDetailCtrl.resendIndex = 0;
      let listType: mmsListType = new mmsListType()

      groupDetailCtrl.groupList = [listType];

      mocker.mockFunc(groupDetailCtrl, groupDetailCtrl.refreshGroupList);
      mocker.mockFunc(groupDetailCtrl, groupDetailCtrl.setAllResendBtnState);
      mocker.mockFunc(groupDetailCtrl, groupDetailCtrl.updateItemStatus);
      mocker.mockFunc(groupDetailCtrl, groupDetailCtrl.updateConversationListStatus);
      mocker.mockFunc(groupDetailCtrl, groupDetailCtrl.resendSms);

      groupDetailCtrl.resendMsg(context);

      expect(groupDetailCtrl.resendCount).assertEqual(0);
    })

    it('GroupDetailController_clickToContactDetail', 0, () => {
      let listType: mmsListType = new mmsListType();
      groupDetailCtrl.groupList = [listType];

      let res = false;
      when(mocker.mockFunc(groupDetailCtrl, groupDetailCtrl.jumpToContactDetail))(ArgumentMatchers.any)
        .afterAction(() => {
          res = true;
        });

      groupDetailCtrl.clickToContactDetail(0);

      expect(res).assertTrue();
    })

    it('GroupDetailController_jumpToContactDetail', 0, async () => {
      let strTypeSet: StrTypeSet = {} as StrTypeSet;
      let actionData: ActionData = new ActionData();

      when(mocker.mockFunc(commonService, commonService.commonContactParam))(actionData)
        .afterReturn(strTypeSet);

      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('mmsContext')
        .afterReturn({
          startAbility: (want: Want,
            options?: StartOptions | undefined): Promise<void> => new Promise<void>(resolve => {
            mocker.verify('commonContactParam', [actionData]).never();
            resolve()
          })
        });

      await groupDetailCtrl.jumpToContactDetail(actionData);

      mocker.clear(commonService);
      mocker.clear(GlobalContext.getContext());
    })

    it('GroupDetailController_jumpToContactDetail_catch', 0, async () => {
      let strTypeSet: StrTypeSet = {} as StrTypeSet;
      let actionData: ActionData = new ActionData();

      when(mocker.mockFunc(commonService, commonService.commonContactParam))(actionData)
        .afterReturn(strTypeSet);

      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('mmsContext')
        .afterReturn({
          startAbility: (want: Want,
            options?: StartOptions | undefined): Promise<void> => new Promise<void>((resolve: () => void,
            reject: (reason: BusinessError) => void) => {
            mocker.verify('commonContactParam', [actionData]).never();
            reject({
              code: 1, message: 'error'
            } as BusinessError)
          })
        });

      await groupDetailCtrl.jumpToContactDetail(actionData);

      mocker.clear(commonService);
      mocker.clear(GlobalContext.getContext());
    })
  })
}