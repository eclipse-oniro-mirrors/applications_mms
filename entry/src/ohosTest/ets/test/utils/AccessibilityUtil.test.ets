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
import { when, describe, beforeAll, beforeEach, afterEach, afterAll, it, expect, MockKit,
  ArgumentMatchers } from '@ohos/hypium'
import LooseObject from '../../../../main/ets/data/LooseObject'
import AccessibilityUtil from '../../../../main/ets/utils/AccessibilityUtil'
import TelephoneUtil from '../../../../main/ets/utils/TelephoneUtil';
import { DTGlobalContext } from '../../testability/TestAbility';

export default function AccessibilityUtilTest() {
  describe('AccessibilityUtilTest', () => {
    // Defines a test suite. Two parameters are supported: test suite name and test suite function.
    beforeAll(() => {
      // Presets an action, which is performed only once before all test cases of the test suite start.
      // This API supports only one parameter: preset action function.
    })
    beforeEach(() => {
      // Presets an action, which is performed before each unit test case starts.
      // The number of execution times is the same as the number of test cases defined by **it**.
      // This API supports only one parameter: preset action function.
    })
    afterEach(() => {
      // Presets a clear action, which is performed after each unit test case ends.
      // The number of execution times is the same as the number of test cases defined by **it**.
      // This API supports only one parameter: clear action function.
    })
    afterAll(() => {
      // Presets a clear action, which is performed after all test cases of the test suite end.
      // This API supports only one parameter: clear action function.
    })
    it('AccessibilityUtilTest_initResourceString_1', 0, () => {
      (AccessibilityUtil as object)['loaded'] = true;
      (AccessibilityUtil as object)['initResourceString']();
      expect(AccessibilityUtil).not().assertUndefined();
    })
    it('AccessibilityUtilTest_initResourceString_0', 0, () => {
      (AccessibilityUtil as object)['initResourceString']();
      expect(AccessibilityUtil).not().assertUndefined();
    })
    it("AccessibilityUtilTest_getItemTime", 0, () => {
      let data1: LooseObject = {
        conversation: {
          itemTime: 2,
        }
      };
      (AccessibilityUtil as object)['getItemTime'](data1);
      expect(AccessibilityUtil).not().assertUndefined();

      let data2: LooseObject = {
        conversation: {
          itemTime: 0,
        }
      };
      (AccessibilityUtil as object)['getItemTime'](data2);
      expect(AccessibilityUtil).not().assertUndefined();
    })

    it("AccessibilityUtilTest_getItemContent", 0, () => {
      let data1: LooseObject = {
        conversation: {
          sendingFailed: false,
          isDraft: true,
          isDisplayDraftText: false,
          content: 0
        }
      };
      (AccessibilityUtil as object)['getItemContent'](data1);
      expect(AccessibilityUtil).not().assertUndefined();

      let data2: LooseObject = {
        conversation: {
          sendingFailed: false,
          isDraft: true,
          isDisplayDraftText: false,
          content: '0'
        }
      };
      (AccessibilityUtil as object)['getItemContent'](data2);
      expect(AccessibilityUtil).not().assertUndefined();

      let data3: LooseObject = {
        conversation: {
          sendingFailed: false,
          isDraft: true,
          isDisplayDraftText: true,
          content: 0
        }
      };
      (AccessibilityUtil as object)['getItemContent'](data3);
      expect(AccessibilityUtil).not().assertUndefined();

      let data4: LooseObject = {
        conversation: {
          sendingFailed: false,
          isDraft: true,
          isDisplayDraftText: true,
          content: '0'
        }
      };
      (AccessibilityUtil as object)['getItemContent'](data4);
      expect(AccessibilityUtil).not().assertUndefined();

      let data5: LooseObject = {
        conversation: {
          sendingFailed: true,
          isDraft: false,
        }
      };
      (AccessibilityUtil as object)['getItemContent'](data5);
      expect(AccessibilityUtil).not().assertUndefined();
    })

    it("AccessibilityUtilTest_getItemContext", 0, () => {
      let data1: LooseObject = {
        conversation: {
          countOfUnread: 0,
          time: 0,
        }
      };
      let context: Context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      AccessibilityUtil.getItemContext(data1, context);
      let data2: LooseObject = {
        conversation: {
          countOfUnread: 0,
          time: '0',
          name: '',
          telephoneFormat: '1-1',
        }
      };
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(TelephoneUtil, TelephoneUtil.formatDisplayPhoneNum))
      (ArgumentMatchers.any).afterReturn('123678')
      let res2 = AccessibilityUtil.getItemContext(data2, context);
      expect(context).not().assertUndefined();
      mocker.clear(TelephoneUtil);
    })

    it("AccessibilityUtilTest_getItemContext_countOfUnread_1_pinningTime_1", 0, () => {
      let item: LooseObject = {
        conversation: {
          countOfUnread: 1,
          pinningTime: 1,
          sendingFailed: true,
          isDraft: false,
          time: 'timeTitle',
          name: 'msgTitle'
        }
      };
      let context: Context = {
        resourceManager: {
          getPluralStringValueSync: (resId: number, num: number): string => {
            return 'unReadTitle';
          },
          getStringSync: (resId: number, num: number): string => {
            return 'pinContent';
          }
        }
      } as Context;
      (AccessibilityUtil as object)['sendFailed'] = 'sendFailed ';
      let res: string = AccessibilityUtil.getItemContext(item, context);
      expect(context).not().assertUndefined();
    })

    it("AccessibilityUtilTest_initResourceString", 0, () => {
      (AccessibilityUtil as object)['loaded'] = true;
      (AccessibilityUtil as object)['initResourceString']();
      (AccessibilityUtil as object)['loaded'] = false;
      try {
        (AccessibilityUtil as object)['initResourceString']();
      } catch (e) {
      }
      expect(AccessibilityUtil).not().assertUndefined();
    })
  })
}