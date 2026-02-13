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
import { cardMmsListType } from '../../../../../main/ets/pages/conversation/conversationController';
import ManageSimController from '../../../../../main/ets/pages/managesim/ManageSimController';
import { DateUtil } from '../../../../../main/ets/utils/DateUtil';

export default function manageSimControllerTest() {
  describe('manageSimControllerTest', () => {
    let manageSimController: ManageSimController = ManageSimController.getInstance();

    beforeAll(() => {
      manageSimController = ManageSimController.getInstance();
    })

    it('ManageSimControllerTest_onInit', 0, () => {
      let pageInfos: NavPathStack = new NavPathStack();
      let dialog = {
        open: () => {
        }
      } as CustomDialogController;
      pageInfos.pushPathByName('ManageSim', {
        groupId: 1,
        threadId: 1,
        content: "1111",
        slotId: 1
      } as LooseObject)

      let mocker: MockKit = new MockKit();
      mocker.mockFunc(manageSimController, manageSimController.cardMmsQuery);
      mocker.mockFunc(manageSimController, manageSimController.resetList);

      manageSimController.onInit(pageInfos, dialog);

      mocker.verify('cardMmsQuery', []).once();

      mocker.clear(manageSimController);
    })

    it('ManageSimControllerTest_resetList', 0, () => {
      manageSimController.resetList();

      expect(manageSimController.showContent).assertFalse();
      expect(JSON.stringify(manageSimController.cardMmsList)).assertEqual('[]');
    })

    it('ManageSimControllerTest_goBack', 0, () => {
      let pageInfos: NavPathStack = new NavPathStack();
      pageInfos.pushPathByName('ManageSim', {
        groupId: 1,
        threadId: 1,
        content: "1111",
        slotId: 1
      } as LooseObject)

      manageSimController.goBack();

      expect(JSON.stringify(manageSimController.pageInfos.getParamByName('ManageSim'))).assertEqual('[]');
    })

    it('ManageSimControllerTest_convertTime', 0, () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(DateUtil, DateUtil.convertTimeStampTime))(ArgumentMatchers.any)
        .afterReturn('下午03:00');
      expect(manageSimController.convertTime(1699010047).substring(0,2)).assertEqual('下午');
      mocker.clear(DateUtil);
    })

    it('ManageSimControllerTest_pushToCopyController', 0, () => {
      manageSimController.cardMmsList = [];
      let card: cardMmsListType = new cardMmsListType();
      card.content = "111"
      manageSimController.cardMmsList.push(card);

      manageSimController.pushToCopyController(0);

      expect(JSON.stringify(manageSimController.pageInfos.getParamByName('CopyView')))
        .assertEqual('[{"info":"111","isFromConversation":true}]');
    })

    it('ManageSimControllerTest_cardMmsQuery', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(manageSimController.cardMmsListDataSource, manageSimController.cardMmsListDataSource.refresh);

      manageSimController.cardMmsQuery();

      expect(manageSimController.showContent).assertFalse();

      mocker.clear(manageSimController.cardMmsListDataSource);
    })
  })
}