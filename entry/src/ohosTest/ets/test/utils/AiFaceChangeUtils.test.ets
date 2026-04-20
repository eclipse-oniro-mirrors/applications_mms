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
import { describe, it, expect, MockKit,
  ArgumentMatchers,
  when} from '@ohos/hypium'
import { aiDetectCallback, AiFaceChangeUtils } from '../../../../main/ets/utils/AiFaceChangeUtils';
import { ChatbotUtils } from '../../../../main/ets/chatbot/utils/ChatbotUtils';

export default function AiFaceChangeUtilsTest() {
  describe('AiFaceChangeUtilsTest', () => {

    it('AiFaceChangeUtilsTest_getInstance_properties_are_not_valid', 0, async () => {
      const result: AiFaceChangeUtils = await AiFaceChangeUtils.getInstance();
      expect(result.getDetectionResult('')).assertFalse()
    });

    it('AiFaceChangeUtilsTest_getInstance_isInit_is_false', 0, async () => {
      let aifacechangeutils: AiFaceChangeUtils = AiFaceChangeUtils.getInstance();
      let mocker: MockKit = new MockKit();
      let mockfunc: Function = mocker.mockFunc(aifacechangeutils, aifacechangeutils.initializeModel);
      when(mockfunc)().afterReturnNothing();
      let fileLocalPath: string = 'file://test.jpg';
      let fileId: number = 1;
      let callback: aiDetectCallback = (result: string, fileId: number) => {
        expect(result).assertUndefined()
      };

      await aifacechangeutils.startAiFaceChange(fileLocalPath, fileId, callback);
      mocker.ignoreMock(aifacechangeutils, aifacechangeutils.initializeModel);
    });

    it('AiFaceChangeUtilsTest_getInstance_all_conditions_are_met', 0, async () => {
      let aifacechangeutils: ESObject = AiFaceChangeUtils.getInstance();
      let mocker: MockKit = new MockKit();
      let mockfunc: Function = mocker.mockFunc(ChatbotUtils, ChatbotUtils.isExistFile);
      when(mockfunc)(ArgumentMatchers.anyString).afterReturn(true);
      let fileLocalPath: string = 'file://test.jpg';
      let fileId: number = 1;
      let callback: aiDetectCallback = (result: string, fileId: number) => {
        expect(result).assertUndefined()
      };
      let mockInitFunc: Function = mocker.mockFunc(aifacechangeutils, aifacechangeutils.initializeModel);
      when(mockInitFunc)().afterReturnNothing();
      let mockHandelDetectFunc: Function = mocker.mockFunc(aifacechangeutils, aifacechangeutils.handelDetect);
      when(mockHandelDetectFunc)(ArgumentMatchers.anyFunction).afterReturnNothing();
      await aifacechangeutils.startAiFaceChange(fileLocalPath, fileId, callback);
      mocker.ignoreMock(ChatbotUtils, ChatbotUtils.isExistFile);
      mocker.ignoreMock(aifacechangeutils, aifacechangeutils.initializeModel);
    });

    it('AiFaceChangeUtilsTest_finalizeModel_model_is_already_finalized', 0, async () => {
      let aifacechangeutils: ESObject = AiFaceChangeUtils.getInstance();
      aifacechangeutils.isInit = true;
      await aifacechangeutils.initializeModel();
      expect(aifacechangeutils.isInit).assertTrue();
    });

    it('AiFaceChangeUtilsTest_finalizeModel_isInit_is_false', 0, async () => {
      let aifacechangeutils: ESObject = AiFaceChangeUtils.getInstance();
      aifacechangeutils.isInit = false;
      aifacechangeutils.isDetecting = false;

      await aifacechangeutils.finalizeModel();

      expect(aifacechangeutils.isInit).assertEqual(false);
      expect(aifacechangeutils.isDetecting).assertEqual(false);
    });
  })
}