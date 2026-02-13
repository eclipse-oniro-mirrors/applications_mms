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
import { ArgumentMatchers, beforeEach, describe, expect, it, MockKit, when } from '@ohos/hypium';
import { GlobalContext } from '../../../../../../main/ets/MainAbility/GlobalHelper';
import {
  SmartMmsServiceRpcService,
  ExtRemoteObjectSub
} from '../../../../../../main/ets/ServiceExtension/smartRpc/SmartMmsServiceRpcService';
import { common, StartOptions, Want } from '@kit.AbilityKit';
import { StaticSubscriberExtensionContext } from '@kit.BasicServicesKit';
import { MessageDetail } from '../../../../../../main/ets/utils/TypesUtils';
import HiLog from '../../../../../../main/ets/utils/HiLog';
import { rpc } from '@kit.IPCKit';
import LooseObject from '../../../../../../main/ets/data/LooseObject';
import {
  ParseSmsTypeRsp,
  SmartMMSNotiTypeRsp
} from '../../../../../../main/ets/ServiceExtension/smartRpc/SmartMmsRpcService';

class SmartMMSNotiTypeRspImpl implements SmartMMSNotiTypeRsp {
  title: string;
  content: string;
  code?: number;
  slotId: number;
  private _msgType: number = 1;

  public set msgType(value: number) {
    this._msgType = value;
  }

  constructor(title: string, content: string, code: number, slotId: number) {
    this.title = title;
    this.content = content;
    this.code = code;
    this.slotId = slotId;
  }
}

export default function smartMmsServiceRpcServiceTest() {
  describe('smartMmsServiceRpcServiceTest', () => {

    const TAG: string = 'SmartMmsRpcService';
    let smartMmsServiceRpcService: SmartMmsServiceRpcService;

    beforeEach(() => {
      smartMmsServiceRpcService = SmartMmsServiceRpcService.serviceInstance();
      AppStorage.clear();
    })

    it('SmartMmsServiceRpcService_getCurrentContext_isBackProcess_true', 0, () => {
      AppStorage.setOrCreate('isBackProcess', true);

      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('mmsServiceContext')
        .afterReturn({} as common.UIAbilityContext);

      let result: common.UIAbilityContext = smartMmsServiceRpcService.getCurrentContext();

      expect(JSON.stringify(result)).assertEqual('{}');

      mocker.clear(GlobalContext.getContext());
    })

    it('SmartMmsServiceRpcService_getCurrentContext_isBackProcess_false', 0, () => {
      AppStorage.setOrCreate('isBackProcess', false);

      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('mmsContext')
        .afterReturn({} as common.UIAbilityContext);

      let result: common.UIAbilityContext = smartMmsServiceRpcService.getCurrentContext();

      expect(JSON.stringify(result)).assertEqual('{}');

      mocker.clear(GlobalContext.getContext());
    })

    it('SmartMmsServiceRpcService_serviceConnect_ipcProxy', 0, async () => {
      let context: common.ServiceExtensionContext = {
        connectServiceExtensionAbility: (want: Want, options: common.ConnectOptions): number => {
          options.onConnect({
            bundleName: '', abilityName: ''
          }, {} as rpc.IRemoteObject);
          return 1;
        }
      } as common.ServiceExtensionContext;

      smartMmsServiceRpcService.ipcProxy = {} as rpc.IRemoteObject;

      let result: boolean = await smartMmsServiceRpcService.serviceConnect(context);

      expect(result).assertTrue();
    })

    it('SmartMmsServiceRpcService_connect_onDisconnect', 0, async () => {
      AppStorage.setOrCreate('isBackProcess', false);

      smartMmsServiceRpcService.ipcProxy = undefined;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(SmartMmsServiceRpcService.serviceInstance(),
        SmartMmsServiceRpcService.serviceInstance().getCurrentContext))()
        .afterReturn({
          connectServiceExtensionAbility: (want: Want, options: common.ConnectOptions): number => {
            options.onDisconnect({
              bundleName: '', abilityName: ''
            });
            options.onFailed(1);
            return 1;
          }
        } as common.UIAbilityContext);

      await smartMmsServiceRpcService.connect();

      expect(smartMmsServiceRpcService.ipcProxy).assertUndefined();

      mocker.clear(SmartMmsServiceRpcService.serviceInstance());
    })

    it('SmartMmsServiceRpcService_connect_onFailed', 0, async () => {
      AppStorage.setOrCreate('isBackProcess', false);

      smartMmsServiceRpcService.ipcProxy = undefined;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(SmartMmsServiceRpcService.serviceInstance(),
        SmartMmsServiceRpcService.serviceInstance().getCurrentContext))()
        .afterReturn({
          connectServiceExtensionAbility: (want: Want, options: common.ConnectOptions): number => {
            options.onFailed(1);
            return 1;
          }
        } as common.UIAbilityContext);

      await smartMmsServiceRpcService.connect();

      expect(smartMmsServiceRpcService.ipcProxy).assertUndefined();

      mocker.clear(SmartMmsServiceRpcService.serviceInstance());
    })

    it('SmartMmsServiceRpcService_disconnect', 0, async () => {
      smartMmsServiceRpcService.ipcProxy = undefined;

      let context: common.ServiceExtensionContext = {
        disconnectServiceExtensionAbility: (connection: number): Promise<void> => {
          expect(connection).assertEqual(1);
          return new Promise<void>(resolve => resolve());
        }
      } as common.ServiceExtensionContext;

      await smartMmsServiceRpcService.disConnect();
    })

    it('SmartMmsServiceRpcService_realRequest', 0, async () => {
      smartMmsServiceRpcService.ipcProxy = {
        sendMessageRequest: (code: number, data: rpc.MessageSequence, reply: rpc.MessageSequence,
          options: rpc.MessageOption): Promise<rpc.RequestResult> =>
        new Promise<rpc.RequestResult>(resolve => resolve({
          errCode: 1,
          code: 1,
          data: {} as rpc.MessageSequence,
          reply: {} as rpc.MessageSequence
        }))
      } as rpc.IRemoteObject;

      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog);

      let result: LooseObject = await smartMmsServiceRpcService.realRequest(0, {
        'msgType': 0
      } as LooseObject);

      mocker.verify('i', [TAG, 'sendMessageRequest ends, reclaim parcel']).once();

      mocker.clear(HiLog);
    })

    it('smartMmsServiceRpcService_realRequest_errorCode_0', 0, async () => {
      let info: LooseObject = {
        key1: 'value'
      };
      let infoStr: string = JSON.stringify(info);

      smartMmsServiceRpcService.ipcProxy = {
        sendMessageRequest: (code: number, data: rpc.MessageSequence, reply: rpc.MessageSequence,
          options: rpc.MessageOption): Promise<rpc.RequestResult> =>
        new Promise<rpc.RequestResult>(resolve => resolve({
          errCode: 0,
          code: 1,
          data: {} as rpc.MessageSequence,
          reply: {
            readString: (): string => infoStr
          } as rpc.MessageSequence
        }))
      } as rpc.IRemoteObject;

      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog);

      let result: LooseObject = await smartMmsServiceRpcService.realRequest(0, {
        'msgType': 0
      } as LooseObject);

      expect(result.key1).assertEqual('value');

      mocker.clear(HiLog);
    })

    it('smartMmsServiceRpcService_realRequest_errorCode_0_info_null', 0, async () => {
      smartMmsServiceRpcService.ipcProxy = {
        sendMessageRequest: (code: number, data: rpc.MessageSequence, reply: rpc.MessageSequence,
          options: rpc.MessageOption): Promise<rpc.RequestResult> =>
        new Promise<rpc.RequestResult>(resolve => resolve({
          errCode: 0,
          code: 1,
          data: {} as rpc.MessageSequence,
          reply: {
            readString: (): string => '{}'
          } as rpc.MessageSequence
        }))
      } as rpc.IRemoteObject;

      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog);
      when(mocker.mockFunc(JSON, JSON.parse))('{}').afterReturn(null);

      let result: LooseObject = await smartMmsServiceRpcService.realRequest(0, {
        'msgType': 0
      } as LooseObject);

      mocker.verify('i', [TAG, 'sendMessageRequest ends, reclaim parcel']).once();

      mocker.clear(HiLog);
      mocker.clear(JSON);
    })

    it('SmartMmsServiceRpcService_smartCheck_if', 0, () => {
      let data: SmartMMSNotiTypeRsp = new SmartMMSNotiTypeRspImpl('title1118358', '【客服】content', 0, 0);

      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(SmartMmsServiceRpcService.serviceInstance(),
        SmartMmsServiceRpcService.serviceInstance().getCurrentContext))()
        .afterReturn({
          startAbility: (want: Want, options?: StartOptions | undefined): Promise<void> => {
            expect(want.bundleName).assertEqual('com.ohos.hiviewcare');
            return new Promise<void>(resolve => resolve());
          }
        } as common.UIAbilityContext);

      smartMmsServiceRpcService.smartCheck(data);

      mocker.clear(SmartMmsServiceRpcService.serviceInstance());
    })

    it('SmartMmsServiceRpcService_ExtRemoteObjectSub_onRemoteMessageRequest', 0, async () => {
      let result: boolean =
        await new ExtRemoteObjectSub().onRemoteMessageRequest(0, {
          readInterfaceToken: (): string => ''
        } as rpc.MessageSequence, {} as rpc.MessageSequence,
          {} as rpc.MessageOption);
      expect(result).assertFalse();

      result = await new ExtRemoteObjectSub().onRemoteMessageRequest(0, {
        readInterfaceToken: (): string => 'SmartResultDESCRIPTOR'
      } as rpc.MessageSequence, {} as rpc.MessageSequence,
        {} as rpc.MessageOption);
      expect(result).assertTrue();
    })
  })
}