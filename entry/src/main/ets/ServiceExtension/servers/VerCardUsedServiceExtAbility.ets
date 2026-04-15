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
import { bundleManager, ServiceExtensionAbility, Want } from '@kit.AbilityKit';
import commonData from '../../data/commonData';
import LooseObject from '../../data/LooseObject';
import ConversationService from '../../service/ConversationService';
import NotificationService from '../../service/NotificationService';
import HiLog from '../../utils/HiLog';
import DotCommon from '../../utils/MmsDot/DotCommon';
import DotUtil from '../../utils/MmsDot/DotUtils';
import SharedPreferencesUtils from '../../utils/SharedPreferencesUtils';

const TAG = 'VerCardUsedServiceExtAbility';
const WHITE_APP_BUNDLE = 'com.ohos.inputmethod';
const WHITE_APP_IDENTIFIER = '1265956504964495936';

export default class VerCardUsedServiceExtAbility extends ServiceExtensionAbility {

  onCreate(want: Want): void {
    HiLog.i(TAG, `onCreate`);
  };

  onRequest(want: Want, startId: number): void {
    HiLog.i(TAG, `onRequest startId ${startId}`)
    const bundleName: string = String(want?.parameters?.['ohos.aafwk.param.callerBundleName']);
    const apIdentifier: string = String(want?.parameters?.['ohos.aafwk.param.callerAppIdentifier']);
    this.checkCaller(bundleName, apIdentifier).then(() => {
      const event: string = String(want?.parameters?.['serviceEvent']);
      switch (event) {
        case 'VerCode_use_status': {
          SharedPreferencesUtils.init(this.context);
          const msgId: string = String(want?.parameters?.['msgId']);
          this.markMessageAsRead(msgId);
          break;
        }
        default: {
          HiLog.e(TAG, 'unknown eventName ${event}');
          break;
        }
      }
    });
  };

  onDestroy(): void {
    HiLog.i(TAG, 'onDestroy');
  };

  checkCaller(bundleName: string, appIdentifier: string): Promise<void> {
    HiLog.d(TAG, `checkerCaller ${bundleName}`)
    return new Promise((resolve, reject) => {
      if (bundleName !== WHITE_APP_BUNDLE || appIdentifier !== WHITE_APP_IDENTIFIER) {
        HiLog.e(TAG, `checkerCaller ${bundleName} is invalid`);
        reject();
        return;
      }
      resolve();
    });
  }

  markMessageAsRead(msgId: string): Promise<void> {
    return new Promise((resolve, reject) => {
      if (!msgId) {
        HiLog.e(TAG, `mark vercode msg id is empty`);
        reject();
        return;
      }

      let condition: LooseObject = {'msgId': msgId};
      ConversationService.getInstance().querySmsMmsInfoByCondition(this.context, condition, (result : LooseObject ) => {
        if (result.code !== commonData.int.SUCCESS || !result.abilityResult) {
          HiLog.e(TAG, `mark vercode msg, query message ${msgId} failed code=${result?.code }`);
          reject();
          return;
        }

        if (result.abilityResult.length === 0) {
          HiLog.e(TAG, `mark vercode msg ${msgId} , query empty`);
          reject();
          return;
        }

        if (result.abilityResult.length > 1) {
          HiLog.w(TAG, `mark vercode msg ${msgId} , query num ${result.abilityResult.length}`);
        }
        // 标记消息已读
        // 未读个数刷新
        // 短信页面、通知列表、大桌面角标刷新
        let actionData: LooseObject = {};
        const item : LooseObject = result.abilityResult[0];
        if (item.isRead && !item.rcsId) {
          HiLog.w(TAG, `mark vercode msg, ${msgId} already read`);
          actionData.threadIds = item.msgId;
        } else {
          actionData.telephone = item.senderNumber;
          actionData.hasRead = commonData.is_read.UN_READ;
            actionData.threadIds = item.msgId;
            actionData.msgType = 'sms_mms_info';
            NotificationService.getInstance(this.context).markAsReadFromReceive(actionData);
        }

        // 删除通知
        // 日志记录msgId和时间
        // 记录打点
        NotificationService.getInstance(this.context).cancelNotify(Number(actionData.threadIds), (code : number)=> {
          if (code == commonData.int.SUCCESS) {
            DotUtil.getInstance().reportEvent({STATE: 0} , DotCommon.eventName.MARK_VER_MSG_READ);
            HiLog.i(TAG, `mark vercode msg ${msgId} success`);
            resolve();
          } else {
            DotUtil.getInstance().reportEvent({STATE: 1} , DotCommon.eventName.MARK_VER_MSG_READ);
            HiLog.i(TAG, `mark vercode msg ${msgId}, cancel notify failed code=${code}`);
            reject();
          }
        })
      });
    });
  }
};