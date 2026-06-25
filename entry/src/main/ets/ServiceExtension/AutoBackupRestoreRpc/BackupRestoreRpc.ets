/**
 * Copyright (c) 2024-2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { common, Want } from '@kit.AbilityKit'
import { GlobalContext } from '../../MainAbility/GlobalHelper';
import rpc from '@ohos.rpc';
import HiLog from '../../utils/HiLog';
const TAG: string = 'BackupRestoreRpc';

// request code
const START_BACKUP_RESTORE_REQUEST: number = 100;
const MMS_MGR_INTERFACE_TOKEN: string = 'OHOS.MMS.BackupRestoreServiceStub';

export default class BackupRestoreRpc {
  private readonly want: Want = {
    bundleName: 'com.ohos.telephonydataability',
    abilityName: 'BackupRestoreServiceAbility'
  }
  private static instance: BackupRestoreRpc;
  public proxy: rpc.IRemoteObject | undefined;
  private connectNumber: number = 0;

  constructor() {
  }

  public getCurrentContext(): common.UIAbilityContext {
    let context = (GlobalContext.getContext().getObject('mmsContext') as common.UIAbilityContext);
    if (!context) {
      context = (GlobalContext.getContext()
        .getObject('mmsServiceContext') as common.UIAbilityContext) as common.UIAbilityContext;
    }
    return context;
  }

  public static getInstance() {
    if (BackupRestoreRpc.instance == null) {
      BackupRestoreRpc.instance = new BackupRestoreRpc();
    }
    return BackupRestoreRpc.instance;
  }

  async connect(): Promise<boolean> {
    return new Promise((resolve, reject) => {
      let connectOp: common.ConnectOptions = {
        onConnect: (elementName, remoteProxy) => {
          HiLog.e(TAG, 'onConnect Backup-Restore Ability');
          this.proxy = remoteProxy;
          this.sendMessage('request remote service start backup restore task', START_BACKUP_RESTORE_REQUEST);
          resolve(true);
        },
        onDisconnect: (elementName) => {
          this.proxy = undefined
          this.connectNumber = 0;
          resolve(false);
        },
        onFailed: () => {
          resolve(false);
        }
      };
      let context: common.UIAbilityContext = this.getCurrentContext();
      if (!context) {
        resolve(false);
        return;
      }
      HiLog.e(TAG, 'connect to Backup-Restore Ability');
      this.connectNumber = context.connectServiceExtensionAbility(this.want, connectOp);
    })
  }

  async sendMessage(msg: string, code: number): Promise<void> {
    const message = rpc.MessageSequence.create();
    const delay = rpc.MessageSequence.create();
    message.writeInterfaceToken(MMS_MGR_INTERFACE_TOKEN);
    message.writeString(msg);
    message.writeRemoteObject(new ExtRemoteObjectSub());
    const option: rpc.MessageOption = new rpc.MessageOption;
    option.setAsync(true);
    this.proxy?.sendMessageRequest(code, message, delay, option)
      .then((result: rpc.RequestResult) => {
      HiLog.e(TAG, 'send request result.code ' + result.code + ' errCode ' + result.errCode);
    }).catch((err: Error) => {
      HiLog.e(TAG, 'send request err ' + JSON.stringify(err));
    }).finally(() => {
      message.reclaim();
      delay.reclaim();
    });
  }

}

class ExtRemoteObjectSub extends rpc.RemoteObject {
  private static readonly DESCRIPTOR: string = 'BackupResultDescriptor';

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

export { ExtRemoteObjectSub }