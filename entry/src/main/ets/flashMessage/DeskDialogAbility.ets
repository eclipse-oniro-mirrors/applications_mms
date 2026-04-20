
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

import ServiceExtensionAbility from '@ohos.app.ability.ServiceExtensionAbility';
import { GlobalContext } from '../MainAbility/GlobalHelper';
import HiLog from '../utils/HiLog';
import DeskDialogConnection from './DeskDialogConnection';
import { DataParameters } from '../utils/TypesUtils';
import ReceiveService from '../StaticSubscriber/ReceiveService';

const TAG = 'DeskDialogAbility';

export default class DeskDialogAbility extends ServiceExtensionAbility {

  onCreate(want: Want) {
    HiLog.i(TAG, 'DeskDialogExAbility onCreate');
    GlobalContext.getContext().setObject('DeskDialogContext', this.context);
  }

  onRequest(want: Want, startId: number) {
    HiLog.i(TAG, 'DeskDialogExAbility onRequest');
    if (want.parameters != null) {
      if (want.parameters.event == 'FLASH_SAVE_MESSAGE') {
        let context = this.context
        let data : DataParameters = want.parameters.data as DataParameters
        let receiveService = ReceiveService.getInstance()
        receiveService.sendAndReceiveRcsBroadcast(data, context);
        receiveService.sendRcsSendBroadcast(data, context);
        receiveService.sendRcsRecvBroadcast(data, context);
        if (!data.parameters.isNotificationFlag) {
          HiLog.i(TAG, 'dealSmsReceiveData');
          receiveService.dealSmsReceiveData(data, context);
        }
      } else {
        DeskDialogConnection.getInstance(this.context).flashMessageShowLogic(want.parameters!)
      }
    }
  }

  onDisconnect(want: Want) {
    HiLog.i(TAG, 'DeskDialogExAbility onDisconnect');
  }

  onDestroy() {
    HiLog.i(TAG, 'DeskDialogExAbility onDestroy');
  }
}