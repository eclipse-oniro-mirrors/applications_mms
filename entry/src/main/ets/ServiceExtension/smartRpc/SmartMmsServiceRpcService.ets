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
import { BusinessError, StaticSubscriberExtensionContext } from '@kit.BasicServicesKit';
import { ParseSmsTypeRsp, SmartMMSNotiTypeRsp } from './SmartMmsRpcService';
import Constant from '../../data/Constant';
import { MessageDetail } from '../../utils/TypesUtils';
import MessageUtil from '../../../cust/utils/MessageUtil';
import StringUtil from '../../utils/StringUtil';
import commonData from '../../data/commonData'

const TAG:string = 'SmartMmsServiceRpcService';
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


class SmartMmsServiceRpcService {
  private static sInstance: SmartMmsServiceRpcService;
  public ipcProxy: rpc.IRemoteObject | undefined;
  private connectId: number = -1
  private remoteDiagnosisMinNumber: number = 12;
  private remoteDiagnosisPrefix: string = '【终端】';
  private remoteDiagnosisKeyWord: string = '远程诊断';
  private status: 'connected' | 'disconnected' | 'connecting' | 'failed' | 'init' = 'init'

  constructor() {
    this.status = 'init';
  }
  static serviceInstance() {
    if (SmartMmsServiceRpcService.sInstance == null) {
      SmartMmsServiceRpcService.sInstance = new SmartMmsServiceRpcService();
    }
    return SmartMmsServiceRpcService.sInstance;
  }

  public getCurrentContext():common.UIAbilityContext {
    let context = (GlobalContext.getContext().getObject('mmsContext') as common.UIAbilityContext);
    let isBackProcess = AppStorage.get('isBackProcess') as boolean;
    if (!context || isBackProcess) {
      context = (GlobalContext.getContext().getObject('mmsServiceContext') as common.UIAbilityContext) as common.UIAbilityContext;
    }
    return context;
  }
  /* 启动service 的连接服务 */
  connectService(actionData: MessageDetail, flag: number, context: common.ServiceExtensionContext) {
    HiLog.w(TAG, 'connectService entry');
    let want: Want = {
      bundleName: 'com.ohos.mms',
      abilityName: 'ServiceExtAbility',
      parameters: {
        'serviceEvent': Constant.VERCODE_SERVICE_EVENT,
        'data': actionData,
        'flag': flag,
      }
    };
    context.startAbility(want)
      .then(() => {
        HiLog.w(TAG, 'connectService startAbility');
      })
      .catch((e: Error) => {
        HiLog.e(TAG, 'connectService error' + JSON.stringify(e));
      });
    HiLog.w(TAG, 'connectService end');
  }
  /* service 服务连接 */
  public async serviceConnect(context: common.ServiceExtensionContext): Promise<boolean> {
    if (SmartMmsServiceRpcService.serviceInstance().ipcProxy) {
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
      if (!context) {
        HiLog.i(TAG, 'RpcClient: serviceConnect context = null');
        resole(false);
        return;
      }
      HiLog.i(TAG, 'RpcClient  : mmsContext');
      try {
        this.connectId = context.connectServiceExtensionAbility(want, connect);
      } catch (exception) {
        HiLog.e(TAG, 'RpcClient : failed get connectId');
        resole(false);
      }
    });
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
    let context = SmartMmsServiceRpcService.serviceInstance().getCurrentContext()
    if (!context) {
      return;
    }
    this.connectId = context.connectServiceExtensionAbility(want, connect);
  }

  public disConnect = async (): Promise<void> => {
    let context = SmartMmsServiceRpcService.serviceInstance().getCurrentContext()
    if (!context) {
      return;
    }
    context.disconnectServiceExtensionAbility(this.connectId, (err: BusinessError, data: void) => {
      if (err.code === 0) {
        HiLog.i(TAG, 'disconnect ServiceExtension success');
      } else {
        HiLog.e(TAG, `disconnect ServiceExtension error: ${err.message}`);
      }
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
        reject();
        return;
      }
      this.ipcProxy.sendMessageRequest(code, data, reply, option)
        .then((result: rpc.RequestResult) => {
          HiLog.e(TAG, 'sendMessageRequest start');
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
  /**
   * send info to smart mms
   *
   * @param actionData the info para
   * @returns result with verification code
   */
  public async sendInfoToSmart(actionData: MessageDetail): Promise<MessageDetail> {
    let cenNumber: string = await MessageUtil.getSMSCAddress(Number(actionData.slotId));
    return await new Promise<MessageDetail>((resole) => {
      let infoData: LooseObject = {
        phoneNum: actionData.telephone,
        msgId: actionData.msgId,
        msg: actionData.content,
        msgTime: new Date().getTime(),
        simIndex: actionData.slotId,
        centerNumber: !StringUtil.isEmpty(cenNumber) ? cenNumber : ''
      }
      SmartMmsServiceRpcService.serviceInstance()
        .realRequest<SmartMMSNotiTypeRsp>(RpcEventActionCode.NOTIFICATION_INFO_GET.valueOf(), infoData)
        .then((rspData: SmartMMSNotiTypeRsp) => {
          SmartMmsServiceRpcService.serviceInstance().smartCheck(rspData);
          actionData.verCode = `${rspData.code}`;
          HiLog.i(TAG, 'notification info get');
          return resole(actionData);
        })
        .catch((e: Error) => {
          HiLog.e(TAG, 'sendInfoToSmart got exception NOTIFICATION_INFO_GET: ' + e.message);
          return resole(actionData)
        })
    })
  }
  /**
   * 智能检测的接口调用, 如果是验证码, 并且满足下面条件, 则调用智能检测的接口
   * @param data
   */
  public smartCheck(data: SmartMMSNotiTypeRsp) {
    HiLog.i(TAG, 'smartCheck start');
    if ((data.title.length > this.remoteDiagnosisMinNumber) && data.content.startsWith(this.remoteDiagnosisPrefix) && 
      data.content.includes(this.remoteDiagnosisKeyWord)) {
      let want: Want = {
        bundleName: 'com.ohos.hiviewcare',
        abilityName: 'SmsDiagnosisAbility',
        parameters: {
          code: `${data.code}`
        }
      };
      let context = SmartMmsServiceRpcService.serviceInstance().getCurrentContext()
      HiLog.i(TAG, 'smartCheck enrty startAbility');
      context.startAbility(want);
    }
    HiLog.i(TAG, 'smartCheck end');
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
    HiLog.i(TAG, 'onRemoteMessageRequest done');
    return true
  }
}


export { SmartMmsServiceRpcService, ExtRemoteObjectSub }