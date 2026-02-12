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
import { describe, expect, it, when } from '@ohos/hypium';
import MmsContactHandler from '../../../../../../main/ets/ServiceExtension/servers/service/MmsContactHandler';
import ResultRPCCallback from '../../../../../../main/ets/ServiceExtension/callback/ResultRPCCallback';
import { Context } from '@kit.AbilityKit';
import { rpc } from '@kit.IPCKit';
import { window } from '@kit.ArkUI';
import { GlobalContext } from '../../../../../../main/ets/MainAbility/GlobalHelper';
import { MockKit } from '@ohos/hypium/src/main/module/mock/MockKit';
import LooseObject from '../../../../../../main/ets/data/LooseObject';
import MmsContactStub from '../../../../../../main/ets/ServiceExtension/servers/stub/MmsContactStub';
import MmsContactProxyInterface
  from '../../../../../../main/ets/ServiceExtension/servers/interface/MmsContactInterface';
import { DTGlobalContext } from '../../../../testability/TestAbility';
import HiLog from '../../../../../../main/ets/utils/HiLog';

class ResultRPCCallbackImpl implements ResultRPCCallback {
  onResult(errCode: number, result: string): void {
    expect(errCode).assertEqual(0);
  }

  asObject(): rpc.IRemoteObject {
    return {} as rpc.IRemoteObject;
  }
}

class MessageSequenceImpl extends rpc.MessageSequence {
  readInterfaceToken(): string {
    return 'idl.SpamShieldMmsService';
  }

  readRemoteObject(): rpc.IRemoteObject {
    return {} as rpc.IRemoteObject;
  }
}

export default function mmsContactHandlerTest() {
  describe('mmsContactHandlerTest', () => {
    let context = DTGlobalContext.getContext().getObject('mmsContext') as Context;

    it('MmsContactStubTest_asInterface', 0, () => {
      let object: rpc.IRemoteObject = {
        getLocalInterface:(descriptor: string): rpc.IRemoteBroker => {
          return {} as rpc.IRemoteBroker;
        }
      } as rpc.IRemoteObject;
      let res: MmsContactProxyInterface = MmsContactStub.asInterface(object);
      expect(JSON.stringify(res)).assertEqual('{}');
    })

    it('MmsContactStubTest_onRemoteMessageRequest_SpamShieldMmsService', 0, async () => {
      let res: boolean = await new MmsContactHandler('MmsContactHandler', context).onRemoteMessageRequest(0, {
        readInterfaceToken: (): string => 'idl.SpamShieldMmsService'
      } as rpc.MessageSequence,
        {} as rpc.MessageSequence, {} as rpc.MessageOption);
      expect(res).assertFalse();
    })

    it('MmsContactStubTest_onRemoteMessageRequest_code_2', 0, async () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('mmsContext')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: -1
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve());
          }
        } as object | window.WindowStage);
      let res: boolean =
        await new MmsContactHandler('MmsContactHandler', context).onRemoteMessageRequest(2, new MessageSequenceImpl(),
          {} as rpc.MessageSequence, {} as rpc.MessageOption);
      expect(res).assertFalse();
      mocker.clear(GlobalContext.getContext());
    })

    it('MmsContactStubTest_onRemoteMessageRequest_code_1', 0, async () => {
      let res: boolean =
        await new MmsContactHandler('MmsContactHandler', context).onRemoteMessageRequest(1, new MessageSequenceImpl(),
          {} as rpc.MessageSequence, {} as rpc.MessageOption);
      expect(res).assertFalse();
    })

    it('mmsContactHandlerTest_noticeToUpdateDeletedContact1', 0, () => {
      let mocker: MockKit = new MockKit();
      let callback: ResultRPCCallback = new ResultRPCCallbackImpl();
      mocker.mockFunc(HiLog, HiLog.i);
      new MmsContactHandler('MmsContactHandler', context).noticeToUpdateDeletedContact([], callback);
      mocker.verify('i', ['MmsContactHandler', 'noticeToUpdateSessionDeletedContactInfo']).never();
      mocker.clear(HiLog);

    })

    it('mmsContactHandlerTest_noticeToUpdateDeletedContact2', 0, () => {
      let callback: ResultRPCCallback = new ResultRPCCallbackImpl();
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('mmsContext')
        .afterReturn({
          sendRequest: (request: string, requestData?: Object | undefined,
            callBack?: ((result: Object) => void) | undefined): Promise<void> => {
            callBack ? callBack({
              code: 0, abilityResult: [1]
            } as LooseObject) : '';
            return new Promise<void>(resolve => resolve());
          }
        } as object | window.WindowStage);
      mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().setObject);
      new MmsContactHandler('MmsContactHandler', context).noticeToUpdateDeletedContact([''], callback);
      mocker.clear(GlobalContext.getContext());
    })
  })
}