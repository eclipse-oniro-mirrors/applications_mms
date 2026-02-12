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
import { describe, beforeEach, it, expect, MockKit, when } from '@ohos/hypium';
import LooseObject from '../../../../../main/ets/data/LooseObject';
import { GlobalContext } from '../../../../../main/ets/MainAbility/GlobalHelper';
import MmsAvatarController from '../../../../../main/ets/views/MmsAvatar/MmsAvatarController';
import { StartOptions, Want } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import HiLog from '../../../../../main/ets/utils/HiLog';

export default function mmsAvatarControllerTest() {
  describe('mmsAvatarControllerTest', () => {
    let mMmsAvatarCtrl: MmsAvatarController;
    const TAG = 'MmsSearchController';

    beforeEach(() => {
      mMmsAvatarCtrl = MmsAvatarController.getInstance();
    })

    it('mmsAvatarController_onShow', 0, () => {
      let pageInfos: NavPathStack | null = new NavPathStack();
      mMmsAvatarCtrl.onShow(pageInfos);

      expect(JSON.stringify(mMmsAvatarCtrl.pageInfos)).assertEqual(JSON.stringify(pageInfos));
    })

    it('mmsAvatarController_clickAvatar_else', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(mMmsAvatarCtrl, mMmsAvatarCtrl.jumpToGroupContactList);

      let message1: LooseObject = {
        "contactsNum": 2,
        "telephone": '13569856654',
        "threadId": 3,
      };
      mMmsAvatarCtrl.clickAvatar(message1);

      mocker.verify('jumpToGroupContactList', [3]).once();

      mocker.clear(mMmsAvatarCtrl);
    })

    it('mmsAvatarController_clickAvatar_if', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(mMmsAvatarCtrl, mMmsAvatarCtrl.jumpToContact);

      let message1: LooseObject = {
        "contactsNum": 1,
        "telephone": '13569856654',
        "threadId": 3,
      };

      mMmsAvatarCtrl.clickAvatar(message1);

      mocker.verify('jumpToContact', [{
        'phoneNumber': '13569856654',
        'pageFlag': 'page_flag_contact_details'
      }]).once();

      mocker.clear(mMmsAvatarCtrl);
    })

    it('mmsAvatarController_clickAvatar_jumpToContact', 0, () => {
      let mocker: MockKit = new MockKit();

      mocker.mockFunc(HiLog, HiLog.i);

      let getObject: Function = mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject);
      when(getObject)('mmsContext').afterReturn({
        startAbility: (want: Want,
          options?: StartOptions | undefined): Promise<void> => new Promise<void>(resolve => resolve())
      });

      mMmsAvatarCtrl.jumpToContact({});

      mocker.verify('i', [TAG, 'jump to contact']).once();

      mocker.clear(HiLog);
      mocker.clear(GlobalContext.getContext());
    })

    it('mmsAvatarController_clickAvatar_jumpToContact_catch', 0, () => {
      let mocker: MockKit = new MockKit();


      let error: BusinessError = {
        code: 1, message: 'error'
      } as BusinessError;
      let getObject: Function = mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject);
      when(getObject)('mmsContext').afterReturn({
        startAbility: (want: Want,
          options?: StartOptions | undefined): Promise<void> => new Promise<void>((resolve: () => void,
          reject: (reason: BusinessError) => void) => reject(error))
      });
      mocker.mockFunc(HiLog, HiLog.i);
      mMmsAvatarCtrl.jumpToContact({});

      mocker.verify('i', [TAG, 'jump to contact']).times(1);

      mocker.clear(HiLog);
      mocker.clear(GlobalContext.getContext());
    })

    it('mmsAvatarController_jumpToGroupContactList_pathInfos_null', 0, () => {
      let mocker: MockKit = new MockKit();

      mocker.mockFunc(HiLog, HiLog.i);

      mMmsAvatarCtrl.pageInfos = new NavPathStack();

      mMmsAvatarCtrl.jumpToGroupContactList(1);

      mocker.verify('i', [TAG, 'jump to contact list view']).once();

      mocker.clear(HiLog);
    })

    it('mmsAvatarController_jumpToGroupContactList', 0, () => {
      let mocker: MockKit = new MockKit();

      mocker.mockFunc(HiLog, HiLog.i);

      mMmsAvatarCtrl.pageInfos = new NavPathStack();

      mMmsAvatarCtrl.jumpToGroupContactList(1);

      mocker.verify('i', [TAG, 'jump to contact list view']).once();

      mocker.clear(HiLog);
    })
  })
}