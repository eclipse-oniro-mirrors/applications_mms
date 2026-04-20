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
import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect, MockKit,
  ArgumentMatchers,
  when} from '@ohos/hypium'
import IdlServiceProxy from '../../../../../../main/ets/report/hsdr/model/IdlServiceProxy';
import { DTGlobalContext } from '../../../../testability/TestAbility';
import { rpc } from '@kit.IPCKit';
import { AsyncCallback } from '@kit.BasicServicesKit';
import IConnectCloudResultCallback, {
  onResultCallback
} from '../../../../../../main/ets/report/hsdr/interface/IConnectCloudResultCallback';
import { ucsCallback } from '../../../../../../main/ets/report/hsdr/interface/IdlService';

export default function IdlServiceProxyTest() {
  let context: Context = DTGlobalContext.getContext().getObject('mmsContext') as Context;
  describe('IdlServiceProxyTest', () => {
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

    it('IdlServiceProxyTest_asObject', 0, () => {
      let proxy: rpc.IRemoteObject = new rpc.RemoteObject('test');
      let idlServiceProxy = new IdlServiceProxy(proxy);
      let result = idlServiceProxy.asObject();
      expect(result).assertEqual(proxy)
    })

    it('IdlServiceProxyTest_cloudConnect', 0, () => {
      let proxy: rpc.IRemoteObject = new rpc.RemoteObject('test');
      let idlServiceProxy = new IdlServiceProxy(proxy);
      let result = idlServiceProxy.asObject();
      let callback: IConnectCloudResultCallback = {
        onResult: (errCode: number, result: string[], callback: onResultCallback): void => {
          throw new Error('Function not implemented.');
        },
        asObject: (): rpc.IRemoteObject => {
          return new rpc.RemoteObject('asObject');
        }
      };
      idlServiceProxy.cloudConnect('serviceName', 'requestId', ['requestJsonStr'], callback);
      expect(result).assertEqual(proxy)
    })

    it('IdlServiceProxyTest_requestUcs', 0, () => {
      let proxy: rpc.IRemoteObject = new rpc.RemoteObject('test');
      let idlServiceProxy = new IdlServiceProxy(proxy);
      let result = idlServiceProxy.asObject();
      let callback: ucsCallback = (errCode: number, result: string[]) => {};
      idlServiceProxy.requestUcs('serviceName', 'requestId', ['requestJsonStr'], callback);
      expect(result).assertEqual(proxy)
    })

    it('IdlServiceProxyTest_requestUcs_catch', 0, () => {
      let proxy: TestRemoteObjectRequestUcsCatch = new TestRemoteObjectRequestUcsCatch('test');
      let idlServiceProxy = new IdlServiceProxy(proxy);
      let result = idlServiceProxy.asObject();
      let callback: ucsCallback = (errCode: number, result: string[]) => {};
      idlServiceProxy.requestUcs('serviceName', 'requestId', ['requestJsonStr'], callback);
      expect(result).assertEqual(proxy)
    })

    it('IdlServiceProxyTest_requestUcs_then', 0, () => {
      let proxy: TestRemoteObjectRequestUcsThen = new TestRemoteObjectRequestUcsThen('test');
      let idlServiceProxy = new IdlServiceProxy(proxy);
      let result = idlServiceProxy.asObject();
      let callback: ucsCallback = (errCode: number, result: string[]) => {};
      idlServiceProxy.requestUcs('serviceName', 'requestId', ['requestJsonStr'], callback);
      expect(result).assertEqual(proxy)
    })

    it('IdlServiceProxyTest_cloudConnect_catch', 0, () => {
      let proxy: TestRemoteObjectCloudConnectCatch = new TestRemoteObjectCloudConnectCatch('test');
      let idlServiceProxy = new IdlServiceProxy(proxy);
      let result = idlServiceProxy.asObject();
      let callback: IConnectCloudResultCallback = {
        onResult: (errCode: number, result: string[], callback: onResultCallback): void => {
          throw new Error('Function not implemented.');
        },
        asObject: (): rpc.IRemoteObject => {
          return new rpc.RemoteObject('asObject');
        }
      };
      idlServiceProxy.cloudConnect('serviceName', 'requestId', ['requestJsonStr'], callback);
      expect(result).assertEqual(proxy)
    })

    it('IdlServiceProxyTest_cloudConnect_then', 0, () => {
      let proxy: TestRemoteObjectCloudConnectThen = new TestRemoteObjectCloudConnectThen('test');
      let idlServiceProxy = new IdlServiceProxy(proxy);
      let result = idlServiceProxy.asObject();
      let callback: IConnectCloudResultCallback = {
        onResult: (errCode: number, result: string[], callback: onResultCallback): void => {
          throw new Error('Function not implemented.');
        },
        asObject: (): rpc.IRemoteObject => {
          return new rpc.RemoteObject('asObject');
        }
      };
      idlServiceProxy.cloudConnect('serviceName', 'requestId', ['requestJsonStr'], callback);
      expect(result).assertEqual(proxy)
    })
  })
}

class TestRemoteObjectRequestUcsThen extends rpc.RemoteObject {
  sendMessageRequest(
    code: number,
    data: rpc.MessageSequence,
    reply: rpc.MessageSequence,
    options: rpc.MessageOption
  ): Promise<rpc.RequestResult> {
    return new Promise((resolve, result) => {
      let re: rpc.RequestResult = {
        errCode: 0,
        code: 5000,
        data: new rpc.MessageSequence,
        reply: new rpc.MessageSequence
      }
      resolve(re)
    }
    );
  };
}

class TestRemoteObjectRequestUcsCatch extends rpc.RemoteObject {
  sendMessageRequest(
    code: number,
    data: rpc.MessageSequence,
    reply: rpc.MessageSequence,
    options: rpc.MessageOption
  ): Promise<rpc.RequestResult> {
    return new Promise((resolve, result) => {
      throw new Error('TestRemoteObjectRequestUcsCatch Function not implemented.');
    }
    );
  };
}


class TestRemoteObjectCloudConnectThen extends rpc.RemoteObject {
  sendMessageRequest(
    code: number,
    data: rpc.MessageSequence,
    reply: rpc.MessageSequence,
    options: rpc.MessageOption
  ): Promise<rpc.RequestResult> {
    return new Promise((resolve, result) => {
      let re: rpc.RequestResult = {
        errCode: 3,
        code: 5000,
        data: new rpc.MessageSequence,
        reply: new rpc.MessageSequence
      }
      resolve(re)
    }
    );
  };
}

class TestRemoteObjectCloudConnectCatch extends rpc.RemoteObject {
  sendMessageRequest(
    code: number,
    data: rpc.MessageSequence,
    reply: rpc.MessageSequence,
    options: rpc.MessageOption
  ): Promise<rpc.RequestResult> {
    return new Promise((resolve, result) => {
      throw new Error('TestRemoteObjectCloudConnectCatch Function not implemented.');
    }
    );
  };
}
