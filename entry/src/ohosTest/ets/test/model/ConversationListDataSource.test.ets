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
import { describe, beforeEach, it, expect, MockKit } from '@ohos/hypium';
import ConversationListDataSource from '../../../../main/ets/model/ConversationListDataSource';
import { messageType } from '../../../../main/ets/pages/conversationlist/conversationListController';
import HiLog from '../../../../main/ets/utils/HiLog';

export default function ConversationListDataSourceTest() {
  describe('ConversationListDataSourceTest', () => {

    const TAG = 'ConversationListDataSource';
    let conversationListDataSource: ConversationListDataSource;

    beforeEach(() => {
      conversationListDataSource = new ConversationListDataSource();
    })

    it('conversationListDataSource_getDataType', 0, () => {
      expect(new messageType().index).assertEqual(0);
    })

    it('conversationListDataSource_totalCount', 0, () => {
      expect(conversationListDataSource.totalCount()).assertEqual(0)
    })

    it('conversationListDataSource_getData_if', 0, () => {
      expect(conversationListDataSource.getData(0)).assertNull()
    })

    it('conversationListDataSource_getData_else', 0, () => {
      let mmsList = new Array<messageType>();
      mmsList.push(new messageType());
      conversationListDataSource.refreshList(mmsList);

      let data: messageType | null = conversationListDataSource.getData(0);

      expect(data?.index).assertEqual(0);
      expect(data?.id).assertEqual(0);
    })

    it('conversationListDataSource_refreshPage_page_0', 0, () => {
      let mmsList = new Array<messageType>();
      mmsList.push(new messageType());
      conversationListDataSource.refreshList(mmsList);
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(HiLog, HiLog.i);

      conversationListDataSource.refreshPage([], 0, 0, true);

      mocker.verify('i', [TAG, 'page is Zero']).times(1);

      mocker.clear(HiLog);
    })

    it('conversationListDataSource_refreshPage_page_1_isEnd_true', 0, () => {
      let mmsList = new Array<messageType>();
      mmsList.push(new messageType());
      conversationListDataSource.refreshList(mmsList);

      let mocker: MockKit = new MockKit();
      mocker.mockFunc(conversationListDataSource, conversationListDataSource.notifyDataReload);

      conversationListDataSource.refreshPage([], 0, 1, true);

      mocker.verify('notifyDataReload', []).once();

      mocker.clear(conversationListDataSource);
    })

    it('conversationListDataSource_refreshPage_page_1_isEnd_false', 0, () => {
      let mmsList = new Array<messageType>();
      mmsList.push(new messageType());
      conversationListDataSource.refreshList(mmsList);

      let mocker: MockKit = new MockKit();
      mocker.mockFunc(conversationListDataSource, conversationListDataSource.notifyDataReload);

      conversationListDataSource.refreshPage([], 0, 1, false);

      mocker.verify('notifyDataReload', []).once();

      mocker.clear(conversationListDataSource);
    })

    it('conversationListDataSource_refresh', 0, () => {
      let mocker: MockKit = new MockKit();
      mocker.mockFunc(conversationListDataSource, conversationListDataSource.notifyDataReload);

      conversationListDataSource.refresh([]);

      mocker.verify('notifyDataReload', []).never();

      mocker.clear(conversationListDataSource);
    })

    it('conversationListDataSource_refreshList', 0, () => {
      conversationListDataSource.refreshList([]);
      expect(conversationListDataSource.mmsList.length).assertEqual(0);
    })

    it('conversationListDataSource_deleteByIndex', 0, () => {
      let mmsList = new Array<messageType>();
      mmsList.push(new messageType());
      conversationListDataSource.refreshList(mmsList);

      let mocker: MockKit = new MockKit();
      mocker.mockFunc(conversationListDataSource, conversationListDataSource.notifyDataDelete);

      conversationListDataSource.deleteByIndex(0);

      mocker.verify('notifyDataDelete', [0]).once();

      mocker.clear(conversationListDataSource);
    })

    it('conversationListDataSource_setIndex', 0, () => {
      conversationListDataSource.setIndex(0, 1);
      expect(conversationListDataSource.showIndex[0]).assertEqual(0);
      expect(conversationListDataSource.showIndex[1]).assertEqual(1);
    })

    it('conversationListDataSource_needNotifyDataReload', 0, () => {
      conversationListDataSource.setIndex(0, 1);
      let flag = conversationListDataSource.needNotifyDataReload(9, 2);
      expect(flag).assertEqual(false);

      let flag1 = conversationListDataSource.needNotifyDataReload(0, 2);
      expect(flag1).assertEqual(true);
    })
  })
}