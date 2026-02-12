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
import ConversationDataSource from '../../../../main/ets/model/ConversationDataSource';
import { mmsListType } from '../../../../main/ets/pages/conversation/conversationController';

export default function ConversationDataSourceTest() {
  describe('ConversationDataSourceTest', () => {

    let conversationDataSource:ConversationDataSource;

    beforeEach(() => {
      conversationDataSource = new ConversationDataSource();
      conversationDataSource.mmsList=[];
    })

    it('conversationDataSource_getInstance',0,()=>{
      expect(typeof ConversationDataSource.getInstance()).assertEqual(typeof conversationDataSource);
    })

    it('conversationDataSource_setIsSendingAnimate_true',0,()=>{
      let mocker:MockKit = new MockKit();
      conversationDataSource.setIsSendingAnimate(true);
      conversationDataSource.refresh([]);
      mocker.verify('notifyDataReload',[]).never();
    })

    it('conversationDataSource_setIsSendingRCSAnimate_1',0,()=>{
      let mocker:MockKit = new MockKit();
      conversationDataSource.setIsSendingRCSAnimate(1);
      mocker.verify('Restore',[]).never();
    })

    it('conversationDataSource_setIsSendingAnimate_false',0,()=>{
      let mocker:MockKit = new MockKit();
      conversationDataSource.setIsSendingAnimate(false);
      conversationDataSource.refresh([]);
      mocker.verify('notifyDataReload',[]).never();
    })

    it('conversationDataSource_refreshPartial',0,()=>{
      let mocker:MockKit = new MockKit();
      let listData: Array<mmsListType> = [];
      conversationDataSource.refreshPartial(listData, -1, -2);
      mocker.verify('refreshPartial',[]).never();
    })

    it('conversationDataSource_totalCount', 0, () => {
      expect(conversationDataSource.totalCount()).assertEqual(0)
    })

    it('conversationDataSource_getData_if', 0, () => {
      expect(conversationDataSource.getData(0)).assertNull();
    })

    it('conversationDataSource_getData_else', 0, () => {
      let listData = new Array<mmsListType>();
      listData.push(new mmsListType());
      conversationDataSource.refreshList(listData);

      expect(conversationDataSource.getData(0)?.id).assertEqual(0);
    })

    it('conversationDataSource_refresh', 0, () => {
      let mocker:MockKit = new MockKit();
      mocker.mockFunc(conversationDataSource,conversationDataSource.notifyDataReload);

      let listData1 = new Array<mmsListType>();
      conversationDataSource.refresh(listData1);

      mocker.verify('notifyDataReload',[]).once();

      mocker.clear(conversationDataSource);
    })

    it('conversationDataSource_addDataByIndexes', 0, () => {
      let mocker:MockKit = new MockKit();
      mocker.mockFunc(conversationDataSource,conversationDataSource.notifyDataAdd);

      conversationDataSource.addDataByIndexes([0]);

      mocker.verify('notifyDataAdd',[0]).once();

      mocker.clear(conversationDataSource);
    })

    it('conversationDataSource_updateByIndex', 0, () => {
      let mocker:MockKit = new MockKit();
      mocker.mockFunc(conversationDataSource,conversationDataSource.notifyDataChange);

      conversationDataSource.updateByIndex(0);

      mocker.verify('notifyDataChange',[0]).once();

      mocker.clear(conversationDataSource);
    })

    it('conversationDataSource_refreshList', 0, () => {
      let listData = new Array<mmsListType>();
      listData.push(new mmsListType());

      conversationDataSource.refreshList(listData);

      expect(JSON.stringify(conversationDataSource.mmsList)).assertEqual(JSON.stringify(listData));
    })

    it('conversationDataSource_deleteByIndex', 0, () => {
      let listData = new Array<mmsListType>();
      listData.push(new mmsListType());
      conversationDataSource.refreshList(listData);

      let mocker:MockKit = new MockKit();
      mocker.mockFunc(conversationDataSource,conversationDataSource.notifyDataDelete);

      conversationDataSource.deleteByIndex(0);

      mocker.verify('notifyDataDelete',[0]).once();

      mocker.clear(conversationDataSource);
    })

    it('conversationDataSource_clear', 0, () => {
      let mocker:MockKit = new MockKit();
      mocker.mockFunc(conversationDataSource,conversationDataSource.notifyDataReload);

      conversationDataSource.clear();

      mocker.verify('notifyDataReload',[]).once();

      mocker.clear(conversationDataSource);
    })
  })
}