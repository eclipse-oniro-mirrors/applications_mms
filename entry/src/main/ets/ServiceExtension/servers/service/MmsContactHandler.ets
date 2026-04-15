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
import ResultRPCCallback from 'ets/ServiceExtension/callback/ResultRPCCallback';
import { GlobalContext } from '../../../MainAbility/GlobalHelper';
import ConversationListService from '../../../service/ConversationListService';
import HiLog from '../../../utils/HiLog';
import MmsContactServiceStub from '../stub/MmsContactStub';
import { JSON } from '@kit.ArkTS';
import Constant from '../../../data/Constant';
import DeviceUtil from '../../../utils/DeviceUtil';

const TAG = 'MmsContactHandler';

export default class MmsContactHandler extends MmsContactServiceStub {
  private mContext: Context;

  constructor(handler: string, context: Context) {
    super(handler);
    this.mContext = context;
  }

  noticeToUpdateDeletedContact(delIdArr: string[], callback: ResultRPCCallback): void {
    new Promise<void>(async (resolve) => {
      HiLog.i(TAG, 'noticeToUpdateSessionDeletedContactInfo');
      this.dealEachDeleteContactDetails(delIdArr, this.mContext);
      callback.onResult(0, 'success');
      resolve();
    })
  }

    private dealEachDeleteContactDetails(delIdArr: string[], context: Context) {
        if (delIdArr.length <= 0) {
            HiLog.e(TAG, 'No delIdArr ');
            return
        }
        for (let i = 0; i < delIdArr.length; i += Constant.MAX_NUMBER_OF_PARAMS_IN_SQL) {
            // 分批处理，每批处理的数据不超过300
            let currentDelContactIds =
                delIdArr.slice(i, Math.min(i + Constant.MAX_NUMBER_OF_PARAMS_IN_SQL, delIdArr.length))
            ConversationListService.getInstance()
                .fetchDeleteContactsAndUpdateSession(currentDelContactIds, context, (results: number[]) => {
                    GlobalContext.getContext().setObject('needToUpdate', true);
                    if ((i === delIdArr.length - 1) && DeviceUtil.isPC()) {
                      AppStorage.setOrCreate('isPCPageRefresh', !AppStorage.get('isPCPageRefresh'));
                    }
                    HiLog.i(TAG,
                        'noticeToUpdateSessionDeletedContactInfo end. results: ' + JSON.stringify(results) +
                            ', update count: ' + results.length);
                })
        }
    }
}
