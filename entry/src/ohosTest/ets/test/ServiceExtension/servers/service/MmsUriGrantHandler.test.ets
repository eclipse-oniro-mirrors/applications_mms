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
  when, beforeEach, afterEach} from '@ohos/hypium'
import MmsUriGrantController from '../../../../../../main/ets/pages/mmsurigrant/MmsUriGrantController';
import ResultRPCCallback from '../../../../../../main/ets/ServiceExtension/callback/ResultRPCCallback';
import MmsUriGrantHandler from '../../../../../../main/ets/ServiceExtension/servers/service/MmsUriGrantHandler';
import { rpc } from '@kit.IPCKit';
import HiLog from '../../../../../../main/ets/utils/HiLog';

export class ResultCallbackImpl implements ResultRPCCallback {
  onResult(errCode: number, result: string): void {

  }

  asObject(): rpc.IRemoteObject {
    return {} as rpc.IRemoteObject;
  }
}

export default function MmsUriGrantHandlerTest() {
  describe('MmsUriGrantHandlerTest', () => {
    let mocker: MockKit;
    const TAG = 'MmsUriGrantHandler';

    beforeEach(() => {
      mocker = new MockKit();
      mocker.mockFunc(HiLog, HiLog.i);
      mocker.mockFunc(HiLog, HiLog.e);
    })

    afterEach(() => {
      mocker.clear(HiLog);
    })

    it('MmsUriGrantHandlerTest_constructor_targetBundleName_is_undefined', 0, () => {
      let handler: string = "testHandler";
      let mmsurigranthandler = new MmsUriGrantHandler(handler);
      expect(mmsurigranthandler == null).assertFalse();
    });

    it('MmsUriGrantHandlerTest_constructor_targetBundleName_is_provided', 0, () => {
      let handler: string = "testHandler";
      let targetBundleName: string = "com.example.app";
      let mmsurigranthandler = new MmsUriGrantHandler(handler, targetBundleName);
      expect((mmsurigranthandler as object)['targetBundleName']).assertEqual(targetBundleName);
    });
    it('MmsUriGrantHandlerTest_grantAccessAttachmentUrisPermission_uriArray_is_null_or_undefined_or_length_0', 0, async () => {
      let mmsurigranthandler: MmsUriGrantHandler = new MmsUriGrantHandler('handler');
      let callback: ResultRPCCallback = new ResultCallbackImpl();
      await mmsurigranthandler.grantAccessAttachmentUrisPermission([], callback);
      mocker.verify('e', [TAG, 'grantAccessAttachmentUrisPermission uriArr is null or length 0']).once();
    });

    it('MmsUriGrantHandlerTest_grantAccessAttachmentUrisPermission_targetBundleName_is_undefined_or_null', 0, async () => {
      let mmsurigranthandler: ESObject = new MmsUriGrantHandler('handler');
      mmsurigranthandler.targetBundleName = undefined;
      let callback: ResultRPCCallback = new ResultCallbackImpl();
      await mmsurigranthandler.grantAccessAttachmentUrisPermission(['uri'], callback);
      mocker.verify('e', [TAG, 'grantAccessAttachmentUrisPermission targetBundleName is undefined or null']).once();
    });

    it('MmsUriGrantHandlerTest_grantAccessAttachmentUrisPermission_return_grant_fail_when_failedUriArray_length_not_0', 0, async () => {
      let mmsurigranthandler: ESObject = new MmsUriGrantHandler('handler', 'targetBundleName');
      let grantController: ESObject = new MmsUriGrantController();
      mmsurigranthandler.grantController = grantController;
      let callback: ResultRPCCallback = new ResultCallbackImpl();
      let mockfunc: Function = mocker.mockFunc(grantController, grantController.grantUrisPermission);
      when(mockfunc)(ArgumentMatchers.any).afterReturn(Promise.resolve(['failedUri']));
      await mmsurigranthandler.grantAccessAttachmentUrisPermission(['uri'], callback);
      mocker.clear(grantController);
      mocker.verify('i', [TAG, 'grantAccessAttachmentUrisPermission end']).once();
    });

    it('MmsUriGrantHandlerTest_grantAccessAttachmentUrisPermission_success_and_failedUriArray_length_0', 0, async () => {
      let mmsurigranthandler: ESObject = new MmsUriGrantHandler('handler', 'targetBundleName');
      let grantController: ESObject = new MmsUriGrantController();
      mmsurigranthandler.grantController = grantController;
      let callback: ResultRPCCallback = new ResultCallbackImpl();
      let mockfunc: Function = mocker.mockFunc(grantController, grantController.grantUrisPermission);
      when(mockfunc)(ArgumentMatchers.any).afterReturn(Promise.resolve([]));
      await mmsurigranthandler.grantAccessAttachmentUrisPermission(['uri'], callback);
      mocker.clear(grantController);
      mocker.verify('i', [TAG, 'grantAccessAttachmentUrisPermission uriArray.length: 1']).once();
    });

    it('MmsUriGrantHandlerTest_getInstance_sInstance_is_null', 0, async () => {
      let grantController: ESObject  = MmsUriGrantController.getInstance();
      let sInstance: ESObject  = MmsUriGrantController.getInstance();
      expect(sInstance == null).assertFalse();
    });

    it('atc_should_return_empty_array_when_uriArray_is_null_or_undefined_or_length_is_0', 0, async () => {
      let mmsurigrantcontroller: ESObject  = MmsUriGrantController.getInstance();
      let result: ESObject = await mmsurigrantcontroller.grantUrisPermission(null, "targetBundleName");
      expect(result).assertDeepEquals([]);
      result = await mmsurigrantcontroller.grantUrisPermission([], "targetBundleName");
      expect(result).assertDeepEquals([]);
    });

    it('atc_should_return_failedUriArray_when_uriPermissionManager_throws_error', 0, async () => {
      let mmsurigrantcontroller: ESObject  = MmsUriGrantController.getInstance();
      let uriArray: Array<string> = ["uri1", "uri2"];
      let result: ESObject = await mmsurigrantcontroller.grantUrisPermission(uriArray, "targetBundleName");
      expect(result).assertDeepEquals(["uri1", "uri2"]);
    });
  })
}