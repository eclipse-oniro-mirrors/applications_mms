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
import { describe, beforeEach, it, expect, MockKit, when, ArgumentMatchers } from '@ohos/hypium';
import OobeResult from '../../../../main/ets/oobe/oobeResult';
import StaticSubscriberExtensionContext from '@ohos.application.StaticSubscriberExtensionContext';
import { DTGlobalContext } from '../../testability/TestAbility';
import { GlobalContext } from '../../../../main/ets/MainAbility/GlobalHelper';
import { resourceManager } from '@kit.LocalizationKit';

export default function oobeResultTest() {
  describe('oobeResultTest', () => {
    
    let oobeResult: OobeResult;
    
    beforeEach(() => {
      oobeResult = new OobeResult();
    })

    it('oobeResultTest_getInstance', 0, () => {
      expect(typeof oobeResult).assertEqual(typeof OobeResult.getInstance());
    })
  
    it('oobeResultTest_getGuideOobeStatue', 0, () => {
      let context = GlobalContext.getContext().getObject('mmsContext') as Context;
      let mocker:MockKit = new MockKit();
      when(mocker.mockFunc(oobeResult,oobeResult.getGuideOobeStatue))(ArgumentMatchers.any)
        .afterReturn(false);
      expect(oobeResult.getGuideOobeStatue(context)).assertFalse();
      mocker.clear(oobeResult);
    })

    it("oobeResultTest_getGuideOobeStatueFromUI", 0, () => {
      let context = {
        resourceManager: {
          getStringSync: (resource: Resource, ...args: (string | number)[]): string => 'xxx'
        } as resourceManager.ResourceManager
      } as Context;
      let mocker:MockKit = new MockKit();
      when(mocker.mockFunc(oobeResult,oobeResult.getGuideOobeStatue))(ArgumentMatchers.any)
        .afterReturn(false);
      let valueFalse = oobeResult.getGuideOobeStatueFromUI(context);
      expect(valueFalse).assertTrue();
      mocker.clear(oobeResult);
    })

    it("oobeResultTest_getGuideOobeStatueFromUI_context_null", 0, () => {
      let context = null;
      let mocker:MockKit = new MockKit();
      when(mocker.mockFunc(oobeResult,oobeResult.getGuideOobeStatue))(ArgumentMatchers.any)
        .afterReturn(false);
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('mmsStaticContext')
        .afterReturn(null);
      let valueFalse = oobeResult.getGuideOobeStatueFromUI(context);
      expect(valueFalse).assertFalse();
      mocker.clear(oobeResult);
      mocker.clear(GlobalContext.getContext());
    })

    it("oobeResultTest_getGuideOobeStatueFromUI_catch", 0, () => {
      let context = GlobalContext.getContext().getObject('mmsContext') as Context;
      let error:Error = new Error('error');
      let mocker:MockKit = new MockKit();
      when(mocker.mockFunc(oobeResult,oobeResult.getGuideOobeStatueResult))(ArgumentMatchers.any)
        .afterAction(()=>{
          throw error;
        });
      let valueFalse = oobeResult.getGuideOobeStatueFromUI(context);
      expect(valueFalse).assertEqual(false);
      mocker.clear(oobeResult);
    })

    it('oobeResultTest_getGuideOobeStatueResult_status_1', 0, () => {
      let isOobe = oobeResult.getGuideOobeStatueResult('1');
      expect(isOobe).assertFalse();
    })

    it('oobeResultTest_getGuideOobeStatueResult_status_0', 0, () => {
      let isOobe = oobeResult.getGuideOobeStatueResult('0');
      expect(isOobe).assertTrue();
    })

    it('oobeResultTest_getGuideOobeStatueResult_status_2', 0, () => {
      let isOobe = oobeResult.getGuideOobeStatueResult('2');
      expect(isOobe).assertTrue();
    })

    it("oobeResultTest_getMmsNoticeOobe", 0, () => {
      let context = DTGlobalContext.getContext().getObject("mmsContext") as StaticSubscriberExtensionContext;
      let mocker:MockKit = new MockKit();
      when(mocker.mockFunc(oobeResult,oobeResult.getGuideOobeStatue))(context)
        .afterAction(false);
      oobeResult.getMmsNoticeOobe(context);
      mocker.verify('getGuideOobeStatue',[context]).once();
      mocker.clear(oobeResult);
    })

    it("oobeResultTest_getMmsNoticeOobeFromUI", 0, () => {
      let context = DTGlobalContext.getContext().getObject("mmsContext") as Context;
      let mocker:MockKit = new MockKit();
      when(mocker.mockFunc(oobeResult,oobeResult.getGuideOobeStatueFromUI))(context)
        .afterAction(false);
      oobeResult.getMmsNoticeOobeFromUI(context)
      mocker.verify('getGuideOobeStatueFromUI',[context]).once();
      mocker.clear(oobeResult);
    })
  })
}