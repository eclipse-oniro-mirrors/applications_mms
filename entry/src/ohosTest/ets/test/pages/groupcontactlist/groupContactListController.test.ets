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
import { describe, beforeAll, it, expect, MockKit, when, ArgumentMatchers } from '@ohos/hypium';
import LooseObject from '../../../../../main/ets/data/LooseObject';
import DataShareHelper from '../../../../../main/ets/model/repository/DataShareHelper';
import GroupContactListController from '../../../../../main/ets/pages/groupcontactlist/groupContactListController';
import { dataShare, dataSharePredicates, DataShareResultSet } from '@kit.ArkData';
import MySet from '../../MySet';
import { GlobalContext } from '../../../../../main/ets/MainAbility/GlobalHelper';
import { StartOptions, Want } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { ActionData } from '../../../../../main/ets/pages/conversationlist/conversationListController';
import YellowPageService from '../../../../../main/ets/service/yellowPageService';
import { DTGlobalContext } from '../../../testability/TestAbility';
import ConversationListService from '../../../../../main/ets/service/ConversationListService';

class Params {
  strContactsNumber?: string | null
  strContactsNumberFormat?: string | null
  strContactsName?: string | null
  contactsNum?: number | null
  threadId?: number | null
  isDraft?: boolean | null
  draftContent?: string | Resource | null
  searchContent?: string | null
  isFromInfoMsgView?: boolean | null
}

export default function groupContactListControllerTest() {
  describe('groupContactListControllerTest', () => {

    let mGroupContactListCtr: GroupContactListController;
    let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;

    beforeAll(() => {
      mGroupContactListCtr = GroupContactListController.getInstance()
    })

    it('GroupContactListControllerTest_onBackPress', 0, () => {
      let result = mGroupContactListCtr.onBackPress();
      expect(result).assertEqual(true);
    })

    it('GroupContactListControllerTest_onInit', 0, () => {
      let pageInfos: NavPathStack = new NavPathStack();
      pageInfos.pushPathByName('groupContactList', {
        threadId: 7
      } as Params);

      let mocker: MockKit = new MockKit();
      mocker.mockFunc(mGroupContactListCtr, mGroupContactListCtr.queryContactListDetail);

      mGroupContactListCtr.onInit(context, pageInfos);

      mocker.verify('queryContactListDetail', [context]).once();

      mocker.clear(mGroupContactListCtr);
    })

    it('GroupContactListControllerTest_queryContactListDetail_success', 0, () => {
      let mySet: DataShareResultSet = new MySet();
      mySet.rowCount = 1;

      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(),
        DataShareHelper.getInstance().initSmsDB))(ArgumentMatchers.any)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve({
          query: (uri: string, predicates: dataSharePredicates.DataSharePredicates,
            columns: string[]): Promise<DataShareResultSet> =>
          new Promise<DataShareResultSet>(resolve => resolve(mySet))
        } as dataShare.DataShareHelper)));

      mocker.mockFunc(YellowPageService.getInstance(), YellowPageService.getInstance().judgeYellowPageExist);

      when(mocker.mockFunc(ConversationListService.getInstance(),
        ConversationListService.getInstance().querySessionByCondition))(ArgumentMatchers.any)
        .afterReturnNothing();

      mGroupContactListCtr.queryContactListDetail(context);

      expect(mGroupContactListCtr.contactList.length).assertEqual(0);

      mocker.clear(DataShareHelper.getInstance());
      mocker.clear(ConversationListService.getInstance());
    })

    it('GroupContactListControllerTest_queryContactListDetail_fail', 0, () => {
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(DataShareHelper.getInstance(),
        DataShareHelper.getInstance().initSmsDB))(ArgumentMatchers.any)
        .afterReturn(new Promise<dataShare.DataShareHelper>(resolve => resolve(undefined)));

      when(mocker.mockFunc(ConversationListService.getInstance(),
        ConversationListService.getInstance().querySessionByCondition))(ArgumentMatchers.any)
        .afterReturnNothing();

      mGroupContactListCtr.queryContactListDetail(context);

      expect(mGroupContactListCtr.contactList.length).assertEqual(0);

      mocker.clear(DataShareHelper.getInstance())
      mocker.clear(ConversationListService.getInstance())
    })

    it('GroupContactListControllerTest_getContactPhotoName', 0, () => {
      let contactList = [{
        'photoFirstNames': [{
          'firstName': 'aa'
        } as LooseObject]
      } as LooseObject, {
        'photoFirstNames': [{
          'firstName': 'bb'
        } as LooseObject]
      } as LooseObject]
      mGroupContactListCtr.contactList = contactList;

      let result = mGroupContactListCtr.getContactPhotoName(0);

      expect(result).assertEqual('aa');
    })

    it('GroupContactListControllerTest_getContactPhotoName_contactList_empty', 0, () => {
      mGroupContactListCtr.contactList = [];
      let result = mGroupContactListCtr.getContactPhotoName(0);

      expect(result).assertEqual('');
    })

    it('GroupContactListControllerTest_getContactPortraitColor', 0, () => {
      let contactList = [{
        'telephone': '18351440964',
        'photoFirstNames': [{
          'firstName': 'aa',
          'portraitColor': '#3300CB87'
        } as LooseObject]
      } as LooseObject, {
        'telephone': '18351440964',
        'photoFirstNames': [{
          'firstName': 'bb',
          'portraitColor': ''
        } as LooseObject]
      } as LooseObject]
      mGroupContactListCtr.contactList = contactList;

      let result = mGroupContactListCtr.getContactPortraitColor(0);

      expect(result).assertEqual('#3300CB87')

      mGroupContactListCtr.contactList = contactList
      let result1 = mGroupContactListCtr.getContactPortraitColor(1)
      expect(result1).not().assertUndefined()
    })

    it('GroupContactListControllerTest_clickToContactDetail', 0, () => {
      let result = false;
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(mGroupContactListCtr,
        mGroupContactListCtr.jumpToContactDetailForResult))(ArgumentMatchers.any)
        .afterAction(() => {
          result = true;
        });

      let contactList = [{
        'telephone': '18351440964',
        'photoFirstNames': [{
          'firstName': 'aa',
          'portraitColor': '#3300CB87'
        } as LooseObject]
      } as LooseObject];
      mGroupContactListCtr.contactList = contactList;

      mGroupContactListCtr.clickToContactDetail(0);

      expect(result).assertTrue();

      mocker.clear(mGroupContactListCtr);
    })

    it('GroupContactListControllerTest_jumpToContactDetailForResult', 0, async () => {
      let actionData: ActionData = {
        phoneNumber: '570977632',
        pageFlag: 'page_flag_contact_details'
      };
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('mmsContext')
        .afterReturn({
          startAbility: (want: Want,
            options?: StartOptions | undefined): Promise<void> => {
            expect(want.parameters?.phoneNumber).assertEqual('570977632');
            return new Promise<void>(resolve => resolve());
          }
        });
      await mGroupContactListCtr.jumpToContactDetailForResult(actionData);

      mocker.clear(GlobalContext.getContext());
    })

    it('GroupContactListControllerTest_clickToContactDetail_catch', 0, async () => {
      let error: BusinessError = {
        code: 1, message: 'error'
      } as BusinessError;
      let actionData: ActionData = {
        phoneNumber: '570977632',
        pageFlag: 'page_flag_contact_details'
      };
      let mocker: MockKit = new MockKit();

      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('mmsContext')
        .afterReturn({
          startAbility: (want: Want,
            options?: StartOptions | undefined): Promise<void> => {
            expect(want.parameters?.phoneNumber).assertEqual('570977632');
            return new Promise<void>((resolve: () => void,
              reject: (reason: BusinessError) => void) => reject(error))
          }
        });

      await mGroupContactListCtr.jumpToContactDetailForResult(actionData);

      mocker.clear(GlobalContext.getContext());
    })
  })
}
