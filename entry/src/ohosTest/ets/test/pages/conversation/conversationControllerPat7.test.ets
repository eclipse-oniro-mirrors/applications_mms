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
import { describe, beforeEach, it, expect, MockKit, when, ArgumentMatchers, afterEach, } from '@ohos/hypium';
import { GlobalContext } from '../../../../../main/ets/MainAbility/GlobalHelper';
import ConversationController, { mmsListType } from '../../../../../main/ets/pages/conversation/conversationController';
import { window } from '@kit.ArkUI';
import { resourceManager } from '@kit.LocalizationKit';
import { DTGlobalContext } from '../../../testability/TestAbility';
import DataShareHelper from '../../../../../main/ets/model/repository/DataShareHelper';
import { dataShare } from '@kit.ArkData';

export default function conversationControllerPart7Test() {
  describe('conversationControllerTest7', () => {

    let mConversationCtrl: ConversationController;
    let mocker: MockKit;
    let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;

    beforeEach(() => {
      mocker = new MockKit();
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('mmsContext').afterReturn({
        resourceManager: {
          getStringSync: (resource: Resource, ...args: (string | number)[]): string => {
            return '' + args[0] + ' ' + args[1];
          }
        } as resourceManager.ResourceManager
      } as Object | window.WindowStage);
      mConversationCtrl = ConversationController.getInstance();
    })

    afterEach(() => {
      mocker.clear(mConversationCtrl);
      mocker.clear(GlobalContext.getContext());
      AppStorage.clear();
    })
    it('conversationController_getLocationInfo_convertLongitude', 0, () => {
      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.getConvertDegreeString))(ArgumentMatchers.any)
        .afterReturn("'20°53'59");
      let res1: string = mConversationCtrl.getLocationInfo(context, 20.9, 20.9);
      expect(res1).assertEqual(`北纬'20°53'59 东经'20°53'59`);
      mocker.clear(mConversationCtrl);
      mocker.clear(GlobalContext.getContext());
    })

    it('conversationController_getLocationInfo_convertLongitude_convertLongitude', 0, () => {
      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.getConvertDegreeString))(ArgumentMatchers.any)
        .afterReturn("'20°53'59");
      let res2: string = mConversationCtrl.getLocationInfo(context, -20.9, 20.9);
      expect(res2).assertEqual(`北纬'20°53'59 西经'20°53'59`);
      mocker.clear(mConversationCtrl);
      mocker.clear(GlobalContext.getContext());
    })

    it('conversationController_getLocationInfo_convertLatitude_minus', 0, () => {
      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.getConvertDegreeString))(ArgumentMatchers.any)
        .afterReturn("'20°53'59");
      let res: string = mConversationCtrl.getLocationInfo(context, 20.9, -20.9);
      expect(res).assertEqual(`南纬'20°53'59 东经'20°53'59`);
      mocker.clear(mConversationCtrl);
      mocker.clear(GlobalContext.getContext());
    })

    it('conversationController_getLocationInfo_convertLatitude_minus_convertLongitude', 0, () => {
      when(mocker.mockFunc(mConversationCtrl, mConversationCtrl.getConvertDegreeString))(ArgumentMatchers.any)
        .afterReturn("'20°53'59");
      let res: string = mConversationCtrl.getLocationInfo(context, -20.9, -20.9);
      expect(res).assertEqual(`南纬'20°53'59 西经'20°53'59`);
      mocker.clear(mConversationCtrl);
      mocker.clear(GlobalContext.getContext());
    })

    it('ConversationControllerTest_mmsFavorite_isCbChecked_isRcs_isCollect', 0, () => {
      let mmsList = [{
        isRcs: 1,
        threadId: 2,
        isCbChecked: true,
        is_collect: false
      } as mmsListType,
        {
          isRcs: 1,
          threadId: 2,
          isCbChecked: true,
          is_collect: true
        } as mmsListType,
        {
          isRcs: 0,
          threadId: 2,
          isCbChecked: true,
          is_collect: false
        } as mmsListType,
        {
          isRcs: 0,
          threadId: 2,
          isCbChecked: true,
          is_collect: true
        } as mmsListType];
      mConversationCtrl.mmsList = mmsList;
      when(mocker.mockFunc(DataShareHelper.getInstance(),
        DataShareHelper.getInstance().initSmsDB))(ArgumentMatchers.any)
        .afterReturn(new Promise<dataShare.DataShareHelper | undefined>(resolve => resolve(undefined)));
      mConversationCtrl.mmsFavorite(context);
      expect(mConversationCtrl).not().assertUndefined();
      mocker.clear(DataShareHelper.getInstance());
    })
  })
}