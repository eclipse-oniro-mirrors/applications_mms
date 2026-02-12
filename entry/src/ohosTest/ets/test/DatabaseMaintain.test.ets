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
import DatabaseMaintain from '../../../main/ets/DatabaseMaintain/DatabaseMaintain';
import { GlobalContext } from '../../../main/ets/MainAbility/GlobalHelper';
import HiLog from '../../../main/ets/utils/HiLog';
import { common } from '@kit.AbilityKit';
import SharedPreferencesUtils from '../../../main/ets/utils/SharedPreferencesUtils';
import PreferenceUtil from '../../../main/ets/backup/util/PreferenceUtil';
import { DTGlobalContext } from '../testability/TestAbility';
import { dataShare } from '@kit.ArkData';
import DataShareHelper from '../../../main/ets/model/repository/DataShareHelper';
import { rpc } from '@kit.IPCKit';
import { isObjectType } from '../../../main/ets/data/LooseObject';
import { commonPasteboard } from '../../../main/ets/data/Pasteboard';

export default function DatabaseMaintainTest() {
  describe('DatabaseMaintainTest', () => {
    let databaseMaintain: DatabaseMaintain;
    let mocker: MockKit;
    const Tag = 'DatabaseMaintain';
    beforeEach(() => {
      databaseMaintain = new DatabaseMaintain();
      mocker = new MockKit();
    })
    it('DatabaseMaintainTest_getInstance', 0, () => {
      expect(typeof databaseMaintain).assertEqual(typeof DatabaseMaintain.getInstance());
    })
    it('DatabaseMaintainTest_release', 0, async () => {
      DatabaseMaintain.release();
      mocker.verify('HiLog',[Tag, 'release']).never();
      mocker.clear(HiLog);
    })
    it('DatabaseMaintainTest_getCurrentContext', 0, () => {
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('mmsServiceContext')
        .afterReturn({} as common.UIAbilityContext);

      let result: common.UIAbilityContext = databaseMaintain.getCurrentContext();

      expect(JSON.stringify(result)).assertEqual('{}');

      mocker.clear(GlobalContext.getContext());
    })
    it('DatabaseMaintainTest_getCurrentContext_not_null', 0, () => {
      let c = {
        connectServiceExtensionAbility: (want: Want, options: common.ConnectOptions): number => {
          return 1;
        }
      } as common.UIAbilityContext;
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('mmsContext')
        .afterReturn(c);

      let result: common.UIAbilityContext = databaseMaintain.getCurrentContext();

      expect(result.connectServiceExtensionAbility({} as Want, {} as common.ConnectOptions)).assertEqual(1);

      mocker.clear(GlobalContext.getContext());
    })
    it('DatabaseMaintainTest_checkNeedClean_true', 0, async () => {
      let curTime: number = new Date().getTime() - 80 * 60 * 1000;
      when(mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences))(PreferenceUtil.DATABASE_CLONE_START_TIME)
        .afterReturn(curTime);
      let res = (databaseMaintain as object)['checkNeedClean']() as boolean;
      expect(res).assertEqual(true);
      mocker.clear(SharedPreferencesUtils);
    })
    it('DatabaseMaintainTest_checkNeedClean_false', 0, async () => {
      let curTime: number = new Date().getTime() - 60 * 60 * 1000;
      when(mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences))(PreferenceUtil.DATABASE_CLONE_START_TIME)
        .afterReturn(curTime);
      let res = (databaseMaintain as object)['checkNeedClean']() as boolean;
      expect(res).assertEqual(false);
      mocker.clear(SharedPreferencesUtils);
    })

    it('DatabaseMaintainTest_checkNeedClean_false1', 0, async () => {
      let context = DTGlobalContext.getContext().getObject("mmsContext") as Context;
      DatabaseMaintain.getInstance().databaseCleanup(context);
      expect(context).not().assertNull();
    })

    it('DatabaseMaintainTest_checkNeedClean_false2', 0, async () => {
      let curTime: number = new Date().getTime() - 60 * 60 * 1000;
      when(mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences))(PreferenceUtil.DATABASE_CLONE_START_TIME)
        .afterReturn(curTime);
      let context = DTGlobalContext.getContext().getObject("mmsContext") as Context;
      DatabaseMaintain.getInstance().databaseCleanup(context);
      expect(context).not().assertNull();
      mocker.clear(SharedPreferencesUtils);
    })

    it('LooseObjectTest_isObjectType_false', 0, async () => {
      expect(isObjectType(1)).assertEqual(false);
    })

    it('PasteboardTest_commonPasteboard', 0, async () => {
      commonPasteboard.setPasteboard('');
      commonPasteboard.setPasteboard('test');
      expect(commonPasteboard.getPasteboard).not().assertNull();
    })
  })
}