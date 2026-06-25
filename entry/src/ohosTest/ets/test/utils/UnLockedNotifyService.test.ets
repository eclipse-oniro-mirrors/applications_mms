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

import { UnLockedNotifyService } from '../../../../main/ets/utils/UnLockedNotifyService'
import { BaseDataParameters, DataParameters } from '../../../../main/ets/utils/TypesUtils'
import { DTGlobalContext } from '../../testability/TestAbility'
import HiLog from '../../../../main/ets/utils/HiLog'
import { afterAll, afterEach,
  ArgumentMatchers,
  beforeAll, beforeEach, describe, expect, it, MockKit, when } from '@ohos/hypium'
import { ValuesBucket } from '@kit.ArkData'
import { Context } from '@kit.AbilityKit'
import { GlobalContext } from '../../../../main/ets/MainAbility/GlobalHelper'

export default function UnLockedNotifyServiceTest() {
  describe('UnLockedNotifyServiceTest', () => {
    let mocker: MockKit;
    beforeAll(() => {
      // Presets an action, which is performed only once before all test cases of the test suite start.
      // This API supports only one parameter: preset action function.
    })
    beforeEach(() => {
      mocker = new MockKit();
    })
    afterEach(() => {
      mocker.clear(HiLog);
    })
    afterAll(() => {
      // Presets a clear action, which is performed after all test cases of the test suite end.
      // This API supports only one parameter: clear action function.
    })

    it('UnLockedNotifyService_getInstance', 0, async () => {
      let instance1: UnLockedNotifyService = UnLockedNotifyService.getInstance();
      let instance2: UnLockedNotifyService = UnLockedNotifyService.getInstance();
      expect(instance1).assertEqual(instance2);

    })

    it('UnLockedNotifyService_insertUnLockedNotify', 0, async () => {
      let data: DataParameters = {
        data: 'RCS_RECEIVE_FILE_FAILED',
        parameters: {
          msgId: '1',
          isShow: true,
          mobilePhoneNumber: '570977632',
          action: '',
          isCdma: false,
          isNotificationFlag: false,
          moduleName: '',
          pdus: [],
          slotId: 0,
          id: 0,
          telephone: '570977632',
          type: '',
          code: 0,
          status: '',
          clurSize: 0,
          totalSize: 1,
          fileName: '',
          filePath: '',
          fileType: '',
          duration: '',
          isFlashMessage: false,
          serviceKind: 0
        } as BaseDataParameters,
        bundleName: '',
        code: 0,
        event: '',
        isFirstUnlocked: false,
        isAfterNoReadButton: false,
        isAfterReSendNotification: false,
        deliveryTime: 0
      }
      let unLockedNotifyModel: ValuesBucket = {
        'pdu_content': JSON.stringify(data)
      }
      let context: Context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      UnLockedNotifyService.getInstance().insertUnLockedNotify(unLockedNotifyModel, () => {

      }, context)
      let res = false;
      expect(res).assertFalse();
    })

    it('UnLockedNotifyService_deleteUnLockedNotify', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      UnLockedNotifyService.getInstance().deleteUnLockedNotify(() => {}, context)
      let res = false;
      expect(res).assertFalse();
    })

    it('UnLockedNotifyService_queryUnLockedNotify', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      UnLockedNotifyService.getInstance().queryUnLockedNotify(() => {
      }, context)
      let res = false;
      expect(res).assertFalse();
    });

    it('UnLockedNotifyService_insertUnLockedNotify_context_null', 0, async () => {
      let data: DataParameters = {
        data: 'RCS_RECEIVE_FILE_FAILED',
        parameters: {
          msgId: '1',
          isShow: true,
          mobilePhoneNumber: '570977632',
          action: '',
          isCdma: false,
          isNotificationFlag: false,
          moduleName: '',
          pdus: [],
          slotId: 0,
          id: 0,
          telephone: '570977632',
          type: '',
          code: 0,
          status: '',
          clurSize: 0,
          totalSize: 1,
          fileName: '',
          filePath: '',
          fileType: '',
          duration: '',
          isFlashMessage: false,
          serviceKind: 0
        } as BaseDataParameters,
        bundleName: '',
        code: 0,
        event: '',
        isFirstUnlocked: false,
        isAfterNoReadButton: false,
        isAfterReSendNotification: false,
        deliveryTime: 0
      }
      let unLockedNotifyModel: ValuesBucket = {
        'pdu_content': JSON.stringify(data)
      }
      let context: Context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('mmsContext')
        .afterReturn(context);
      UnLockedNotifyService.getInstance().insertUnLockedNotify(unLockedNotifyModel, () => {

      }, undefined)
      let res = false;
      expect(res).assertFalse();
      mocker.clear(GlobalContext.getContext())
    })

    it('UnLockedNotifyService_deleteUnLockedNotify_context_null', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('mmsContext')
        .afterReturn(context);
      UnLockedNotifyService.getInstance().deleteUnLockedNotify(() => {}, undefined)
      let res = false;
      expect(res).assertFalse();
      mocker.clear(GlobalContext.getContext())
    })

    it('UnLockedNotifyService_queryUnLockedNotify_context_null', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('mmsContext')
        .afterReturn(context);
      UnLockedNotifyService.getInstance().queryUnLockedNotify(() => {
      }, undefined)
      let res = false;
      when(mocker.mockFunc(UnLockedNotifyService, UnLockedNotifyService.getInstance().deleteUnLockedNotify))(ArgumentMatchers.any)
      expect(res).assertFalse();
      mocker.clear(GlobalContext.getContext())
    });
  })
}