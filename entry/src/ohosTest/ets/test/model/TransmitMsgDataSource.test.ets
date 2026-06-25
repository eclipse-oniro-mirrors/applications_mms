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
import { beforeEach, describe, expect, it, MockKit } from '@ohos/hypium'
import TransmitMsgDataSource, { listDataType } from '../../../../main/ets/model/TransmitMsgDataSource'
import { mmsListType } from '../../../../main/ets/pages/conversation/conversationController';

export default function transmitMsgDataSourceTest() {
  describe('MtransmitMsgDataSourceTest', () => {

    let transmitMsgDataSource:TransmitMsgDataSource;

    beforeEach(()=>{
      transmitMsgDataSource = new TransmitMsgDataSource();
    })

    it('transmitMsgDataSourceTest_listDataType', 0, () => {
      let listData:listDataType= new listDataType();
      expect(listData.index).assertEqual(0);
    })

    it('transmitMsgDataSourceTest_totalCount', 0, () => {
      expect(transmitMsgDataSource.totalCount()).assertEqual(0);
    })

    it('transmitMsgDataSourceTest_getData_if', 0, () => {
      expect(transmitMsgDataSource.getData(0)).assertNull();
    })

    it('transmitMsgDataSourceTest_getData_else', 0, () => {
      let mocker:MockKit = new MockKit();
      mocker.mockFunc(transmitMsgDataSource,transmitMsgDataSource.notifyDataReload);
      let mmsListType:mmsListType= {
      } as mmsListType;
      transmitMsgDataSource.refresh([mmsListType]);

      expect(JSON.stringify(transmitMsgDataSource.getData(0))).assertEqual(JSON.stringify({
        index: 0
      }));

      mocker.clear(transmitMsgDataSource);
    })
  })
}