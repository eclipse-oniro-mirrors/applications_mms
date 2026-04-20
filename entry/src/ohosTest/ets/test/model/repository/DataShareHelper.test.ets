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
import { beforeEach, describe, expect, it, MockKit } from '@ohos/hypium';
import DataShareHelper from '../../../../../main/ets/model/repository/DataShareHelper';
import dataShare from '@ohos.data.dataShare';
import HiLog from '../../../../../main/ets/utils/HiLog';

export default function DataShareHelperTest() {
  describe('dataShareHelperTest', () => {

    let dataShareHelper: DataShareHelper;
    const TAG = 'DataShareHelper';

    beforeEach(() => {
      dataShareHelper = DataShareHelper.getInstance();
    })

    it('dataShareHelper_initCallLogDB', 0, async () => {
      let result:dataShare.DataShareHelper | undefined = await dataShareHelper.initCallLogDB({} as Context);
      expect(result).assertUndefined();
    })

    it('dataShareHelper_unInitSmsDB', 0, () => {
      let mocker:MockKit = new MockKit();
      mocker.mockFunc(HiLog,HiLog.i);

      dataShareHelper.unInitSmsDB();

      mocker.verify('i',[TAG, 'contactDbHelper success.']);

      mocker.clear(HiLog);
    })

    it('dataShareHelper_unInitContactDB', 0, () => {
      let mocker:MockKit = new MockKit();
      mocker.mockFunc(HiLog,HiLog.i);

      dataShareHelper.unInitContactDB();

      mocker.verify('i',[TAG, 'contactDbHelper success.']);

      mocker.clear(HiLog);
    })

    it('dataShareHelper_unInitCallLogDB', 0, () => {
      let mocker:MockKit = new MockKit();
      mocker.mockFunc(HiLog,HiLog.i);

      dataShareHelper.unInitCallLogDB();

      mocker.verify('i',[TAG, 'callLogDbHelper success.']);

      mocker.clear(HiLog);
    })

  })
}


