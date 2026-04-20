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
import { describe, it, expect, MockKit, when, ArgumentMatchers } from '@ohos/hypium';
import SearchUtil, {
  ContactsSchema,
  GroupSearchResult,
  MessagesSchema,
  SearchType,
  splitMessagesSchema
} from '../../../../main/ets/utils/SearchUtil';

export default function SearchUtilTest() {
  describe('SearchUtilTest', () => {

    it('SearchUtilTest_dealCollectRecords', 0, async () => {
      let messageRecord: MessagesSchema[] = [
        {
          hasYellowPageIcon: '',
          entityId: '11',
          entityName: '234',
          content: '23',
          messageType: 1,
          createDate: 12536546,
          phoneNumber: '1234534',
          contactId: '352364',
          contactName: '135346',
          direction: 0,
          state: 0,
          sessionId: '35',
          isCollect: 0,
        }];
      let result = SearchUtil.dealCollectRecords(messageRecord);
      expect(result.length).assertEqual(1);
    })

    it('SearchUtilTest_splitMessagesSchema', 0, () => {
      let schema: MessagesSchema = {
        hasYellowPageIcon: '',
        entityId: '11',
        entityName: '234',
        content: '23',
        messageType: 1,
        createDate: 12536546,
        phoneNumber: '1234534',
        contactId: '352364',
        contactName: '135346',
        direction: 0,
        state: 0,
        sessionId: '35',
        isCollect: 0,
      };
      let result = splitMessagesSchema(schema);
      expect(result.length).assertEqual(1);
    })

    it('SearchUtilTest_sortMessages', 0, () => {
      let message1: MessagesSchema = {
        hasYellowPageIcon: '',
        entityId: '1',
        entityName: '1',
        content: '1',
        messageType: 1,
        createDate: 1,
        phoneNumber: '1',
        contactId: '1',
        contactName: '1',
        direction: 0,
        state: 0,
        sessionId: '1',
        isCollect: 1,
      };
      let message2: MessagesSchema = {
        hasYellowPageIcon: '',
        entityId: '2',
        entityName: '2',
        content: '2',
        messageType: 2,
        createDate: 2,
        phoneNumber: '2',
        contactId: '2',
        contactName: '2',
        direction: 0,
        state: 0,
        sessionId: '2',
        isCollect: 0,
      };

      let messages: MessagesSchema[] = [message1, message2];
      SearchUtil.sortMessages(messages);
      expect(messages[0].entityId).assertEqual(message1.entityId);
    });

    it('SearchUtilTest_sortMessages1', 0, () => {
      let message2: MessagesSchema = {
        hasYellowPageIcon: '',
        entityId: '2',
        entityName: '2',
        content: '2',
        messageType: 2,
        createDate: 2,
        phoneNumber: '2',
        contactId: '2',
        contactName: '2',
        direction: 0,
        state: 0,
        sessionId: '2',
        isCollect: 0,
      }
      let message3: MessagesSchema = {
        hasYellowPageIcon: '',
        entityId: '3',
        entityName: '3',
        content: '3',
        messageType: 3,
        createDate: 3,
        phoneNumber: '3',
        contactId: '3',
        contactName: '3',
        direction: 0,
        state: 0,
        sessionId: '3',
        isCollect: 0,
      }

      let messages: MessagesSchema[] = [message2, message3];
      SearchUtil.sortMessages(messages);
      expect(messages[0].entityId).assertEqual('3');
    });

    it('SearchUtilTest_sortMessages2', 0, () => {
      let message1: MessagesSchema = {
        hasYellowPageIcon: '',
        entityId: '1',
        entityName: '1',
        content: '1',
        messageType: 1,
        createDate: 1,
        phoneNumber: '1',
        contactId: '1',
        contactName: '1',
        direction: 0,
        state: 0,
        sessionId: '1',
        isCollect: 1,
      };
      let message2: MessagesSchema = {
        hasYellowPageIcon: '',
        entityId: '2',
        entityName: '2',
        content: '2',
        messageType: 2,
        phoneNumber: '2',
        contactId: '2',
        contactName: '2',
        direction: 0,
        state: 0,
        sessionId: '2',
        isCollect: 0,
      } as MessagesSchema;
      let message3: MessagesSchema = {
        hasYellowPageIcon: '',
        entityId: '3',
        entityName: '3',
        content: '3',
        messageType: 3,
        phoneNumber: '3',
        contactId: '3',
        contactName: '3',
        direction: 0,
        state: 0,
        sessionId: '3',
        isCollect: 1,
      } as MessagesSchema;

      let messages: MessagesSchema[] = [message3, message2, message1];
      SearchUtil.sortMessages(messages);
      expect(messages[0].entityId).assertEqual('1');
    });

  })
}