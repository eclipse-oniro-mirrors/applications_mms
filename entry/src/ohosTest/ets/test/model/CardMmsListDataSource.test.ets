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
import { cardMmsListType } from '../../../../main/ets/pages/conversation/conversationController';
import CardMmsListDataSource, { listDataType } from '../../../../main/ets/model/CardMmsListDataSource';

export default function cardMmsListDataSourceTest() {
  describe('cardMmsListDataSourceTest', () => {

    let cardMmsListDataSource: CardMmsListDataSource;

    beforeEach(() => {
      cardMmsListDataSource = new CardMmsListDataSource();
    })

    it('cardMmsListDataSourceTest_listDataType', 0, () => {
      expect(new listDataType().name).assertEqual('');
      expect(new listDataType().content).assertEqual('');
      expect(new listDataType().timeRange).assertEqual('');
    })

    it('cardMmsListDataSourceTest_totalCount', 0, () => {
      expect(cardMmsListDataSource.totalCount()).assertEqual(0);
    })

    it('cardMmsListDataSourceTest_getData_if', 0, () => {
      expect(cardMmsListDataSource.getData(0)).assertNull();
    })

    it('cardMmsListDataSourceTest_getData_else', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(cardMmsListDataSource, cardMmsListDataSource.notifyDataReload);
      let carMms: cardMmsListType = new cardMmsListType();
      carMms.name = 'roxy';
      carMms.content = 'hi';

      cardMmsListDataSource.refresh([carMms]);

      expect(cardMmsListDataSource.getData(0)?.name).assertEqual('roxy');

      mocker.clear(cardMmsListDataSource);
    })
  })
}