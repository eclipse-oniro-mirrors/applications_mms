/**
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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
import rpc from '@ohos.rpc';
import Want from '@ohos.app.ability.Want';
import common from '@ohos.app.ability.common';
import { GlobalContext } from '../../MainAbility/GlobalHelper';
import HiLog from '../../utils/HiLog';
import LooseObject from '../../data/LooseObject';

const TAG: string = 'SmartMmsRpcService';
/**
 * 和 SmartMMS 交互的 RPC 事件的操作
 */
const enum RpcEventActionCode {
  /**
   * 解析短信类型
   */
  PARSE_SMS_TYPE = 102,

  /**
   * 获取通知栏信息
   */
  NOTIFICATION_INFO_GET = 107,
  /**
   * 获取配置项
   */
  SMART_MMS_CONFIG_GET = 100,

}

/**
 * 查询是否开启过的 配置项查询响应
 */
interface QuerySmartMmsConfigRsp {
  /**
   * 配置项key
   */
  configKey: string,

  /**
   * 配置项value
   */
  configValue: string | number | boolean
}

class SmartMmsRpcService {
  private static sInstance: SmartMmsRpcService;
  public ipcProxy: rpc.IRemoteObject | undefined;
  private connectId: number = -1
  private remoteDiagnosisMinNumber: number = 12;
  private remoteDiagnosisPrefix: string = '【终端】';
  private remoteDiagnosisKeyWord: string = '远程诊断';
  private status: 'connected' | 'disconnected' | 'connecting' | 'failed' | 'init' = 'init'

  constructor() {
    this.status = 'init';
  }

  static getInstance() {
    if (SmartMmsRpcService.sInstance == null) {
      SmartMmsRpcService.sInstance = new SmartMmsRpcService();
    }
    return SmartMmsRpcService.sInstance;
  }

  public getCurrentContext(): common.UIAbilityContext {
    let context = (GlobalContext.getContext().getObject('mmsContext') as common.UIAbilityContext);
    let isBackProcess = AppStorage.get('isBackProcess') as boolean;
    if (!context || isBackProcess) {
      context = (GlobalContext.getContext()
        .getObject('mmsServiceContext') as common.UIAbilityContext) as common.UIAbilityContext;
    }
    return context;
  }

  public async connect2(): Promise<boolean> {
    if (SmartMmsRpcService.getInstance().ipcProxy) {
      return await new Promise<boolean>((resole) => {
        resole(true);
      });
    }
    return await new Promise<boolean>((resole) => {
      let want: Want = {
        bundleName: 'com.ohos.smartmmsservice',
        abilityName: 'ServiceExtAbility',
      };
      let connect: common.ConnectOptions = {
        onConnect: (elementName, remoteProxy) => {
          HiLog.i(TAG, 'RpcClient: js onConnect called');
          this.ipcProxy = remoteProxy;
          this.status = 'connected';
          resole(true);
        },
        onDisconnect: (elementName) => {
          this.status = 'disconnected';
          this.ipcProxy = undefined
          HiLog.i(TAG, 'RpcClient: onDisconnect');
          resole(false);
        },
        onFailed: () => {
          this.status = 'failed';
          HiLog.i(TAG, 'RpcClient: onFailed');
          resole(false);
        }
      };
      let context = SmartMmsRpcService.getInstance().getCurrentContext()
      if (!context) {
        resole(false);
        return;
      }
      HiLog.i(TAG, 'RpcClient: mmsContext');
      this.connectId = context.connectServiceExtensionAbility(want, connect);
    })
  }

  public connect = async () => {
    let want: Want = {
      bundleName: 'com.ohos.smartmmsservice',
      abilityName: 'ServiceExtAbility',
    };
    let connect: common.ConnectOptions = {
      onConnect: (elementName, remoteProxy) => {
        HiLog.i(TAG, 'RpcClient: js onConnect called');
        this.ipcProxy = remoteProxy;
        this.status = 'connected';
      },
      onDisconnect: (elementName) => {
        this.status = 'disconnected';
        this.ipcProxy = undefined
        HiLog.i(TAG, 'RpcClient: onDisconnect');
      },
      onFailed: () => {
        this.status = 'failed';
        HiLog.i(TAG, 'RpcClient: onFailed');
      }
    };
    let context = SmartMmsRpcService.getInstance().getCurrentContext()
    if (!context) {
      return;
    }
    this.connectId = context.connectServiceExtensionAbility(want, connect);
  }
  public disConnect = async (): Promise<void> => {
    let context = SmartMmsRpcService.getInstance().getCurrentContext()
    if (!context) {
      return;
    }
    await context.disconnectServiceExtensionAbility(this.connectId);
  }

  async doRequest<T>(code: number, reqData: object): Promise<T> {
    let proxy = SmartMmsRpcService.getInstance().ipcProxy
    if (proxy) {
      return SmartMmsRpcService.getInstance().realRequest(code, reqData);
    }
    let con = await SmartMmsRpcService.getInstance().connect2()
    if (con) {
      HiLog.i(TAG, 'rpc - is connneted ')
      return SmartMmsRpcService.getInstance().realRequest(code, reqData);
    } else {
      let reConnect = await SmartMmsRpcService.getInstance().connect2()
      if (reConnect) {
        return SmartMmsRpcService.getInstance().realRequest(code, reqData);
      } else {
        return new Promise<T>((resole) => {
          let infoStr = `{'msgType':0}`
          let resp: T = JSON.parse(infoStr);
          resole(resp);
        });
      }
    }
    return await new Promise<T>((resole) => {
      let infoStr = `{'msgType':-1}`
      let resp: T = JSON.parse(infoStr);
      resole(resp);
    });
  }

  async realRequest<T>(code: number, reqData: object): Promise<T> {
    return await new Promise<T>((resolve, reject) => {
      let option = new rpc.MessageOption();
      let data = rpc.MessageSequence.create();
      let reply = rpc.MessageSequence.create();
      if (code == 100) {
        let extRemoteObjectSub = new ExtRemoteObjectSub();
        data.writeRemoteObject(extRemoteObjectSub);
      }
      data.writeString(JSON.stringify(reqData))
      HiLog.i(TAG, 'sendMessageRequest code');
      if (this.ipcProxy === undefined) {
        HiLog.e(TAG, 'realRequest ipcProxy is undefined');
        data.reclaim();
        reply.reclaim();
        reject(0);
        return;
      }
      this.ipcProxy.sendMessageRequest(code, data, reply, option)
        .then((result: rpc.RequestResult) => {
          HiLog.i(TAG, 'sendMessageRequest start');
          if (result.errCode != 0) {
            HiLog.e(TAG, 'sendMessageRequest failed, errCode: ' + result.errCode);
            reject();
            return;
          }
          if (result.reply == null) {
            HiLog.e(TAG, 'sendMessageRequest result.reply is null');
            reject();
            return;
          }
          let infoStr = result.reply.readString();
          let info: T | null = JSON.parse(infoStr);
          if (info == null) {
            HiLog.e(TAG, 'sendMessageRequest info is null');
            reject();
          } else {
            resolve(info);
          }
        })
        .catch((e: Error) => {
          HiLog.i(TAG, 'sendMessageRequest got exception: ' + JSON.stringify(e));
          reject();
        })
        .finally(() => {
          HiLog.i(TAG, 'sendMessageRequest ends, reclaim parcel')
          data.reclaim();
          reply.reclaim();
        })
    })
  }

}

class ExtRemoteObjectSub extends rpc.RemoteObject {
  private static readonly DESCRIPTOR: string = 'SmartResultDESCRIPTOR';

  constructor() {
    super('ExtRemoteObjectSub')
  }

  async onRemoteMessageRequest(
    code: number,
    data: rpc.MessageSequence,
    reply: rpc.MessageSequence,
    option: rpc.MessageOption): Promise<boolean> {
    if (data.readInterfaceToken() !== ExtRemoteObjectSub.DESCRIPTOR) {
      HiLog.e(TAG, 'DESCRIPTOR unmatched.');
      return false;
    }
    return true;
  }
}

interface ParseSmsTypeRsp {
  /**
   * 消息类型  1:验证码 2:来去电提醒
   */
  msgType: number;
}

interface SmartMMSNotiTypeRsp {
  /**
   * 通知栏标题
   */
  title: string,

  /**
   * 通知栏内容
   */
  content: string,

  /**
   * 验证码
   */
  code?: number,

  /**
   * 短信的 slotId, 从原始数据中拿过来的
   */
  slotId: number
}

export { SmartMmsRpcService,
  RpcEventActionCode,
  ParseSmsTypeRsp,
  SmartMMSNotiTypeRsp,
  QuerySmartMmsConfigRsp,
  ExtRemoteObjectSub }