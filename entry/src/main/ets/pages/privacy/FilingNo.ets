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

import HiLog from '../../utils/HiLog';
import { common, Want } from '@kit.AbilityKit';
import Constant from '../../data/Constant';

const TAG = 'FilingNo';

export class FilingNo {

  private static instance: FilingNo;

  private constructor() {
  }

  public static getInstance(): FilingNo {
    if (!FilingNo.instance) {
      FilingNo.instance = new FilingNo();
    }
    return FilingNo.instance;
  }

  /**
   * start browser ability
   */
  async implicitStartBrowserAbility() {
    try {
      let want: Want = {
        'action': 'ohos.want.action.viewData',
        'entities': ['entity.system.browsable'],
        'uri': getContext().resourceManager.getStringSync($r('app.string.filing_no_url')),
        'type': 'text/plain'
      }

      let context = getContext(this) as common.UIAbilityContext;
      await context.startAbility(want);
      HiLog.i(TAG, 'explicit start browser ability succeed');
    } catch (err) {
      HiLog.e(TAG, 'explicit start browser ability error: ' + err.message);
    }
  }
}