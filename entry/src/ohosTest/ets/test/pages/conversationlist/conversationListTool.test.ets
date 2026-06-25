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
import { afterEach, ArgumentMatchers, beforeEach, describe, expect, it, MockKit, when } from '@ohos/hypium';
import commonData, { GlobalContextKey } from '../../../../../main/ets/data/commonData';
import LooseObject from '../../../../../main/ets/data/LooseObject';
import { GlobalContext } from '../../../../../main/ets/MainAbility/GlobalHelper';
import {
    ContactsUpdateRecords,
    queryFirstPageMessagesDataBaseActionData
} from '../../../../../main/ets/pages/conversationlist/conversationListTool';
import SharedPreferencesUtils from '../../../../../main/ets/utils/SharedPreferencesUtils';


export default function ConversationListToolTest() {
    describe('ConversationListToolTest', () => {

        let mocker: MockKit;

        beforeEach(() => {
            mocker = new MockKit();
        })

        afterEach(() => {
            AppStorage.clear();
        })

        it('queryFirstPageMessagesDataBaseActionData_1', 0, () => {
            let actionData: LooseObject = {}
            let hasAggregate = true
            actionData.smsType = 'x'
            let retData = queryFirstPageMessagesDataBaseActionData(actionData, hasAggregate, 0)
            expect(retData.smsType).assertEqual(commonData.sms_type.COMMON)
        })

        it('queryFirstPageMessagesDataBaseActionData_2', 0, () => {
            let actionData: LooseObject = {}
            let hasAggregate = false
            actionData.smsType = 'x'
            let retData = queryFirstPageMessagesDataBaseActionData(actionData, hasAggregate, 0)
            expect(retData.smsType).assertEqual('x')
        })

        it('queryFirstPageMessagesDataBaseActionData_3', 0, () => {
            let actionData: LooseObject = {}
            let hasAggregate = false
            actionData.smsType = 'x'
            let getFromPreferences =
                mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.getFromPreferences);
            when(getFromPreferences)(ArgumentMatchers.any).afterReturn(true);
            when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().hasKey))(ArgumentMatchers.any).afterReturn(true);
            when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))(ArgumentMatchers.any).afterReturn(true);

            let retData = queryFirstPageMessagesDataBaseActionData(actionData, hasAggregate, 0)
            expect(retData.useWorker).assertEqual(false)
            mocker.clear(SharedPreferencesUtils);
            mocker.clear(GlobalContext.getContext());
        })

        it('ContactsUpdateRecords_contactsUpdateEvent', 0, () => {
            let delayNumber =ContactsUpdateRecords.getInstance().contactsUpdateEvent()
            expect(delayNumber).assertEqual(ContactsUpdateRecords.contactManualUpdateMicroseconds)
        })

    })
}