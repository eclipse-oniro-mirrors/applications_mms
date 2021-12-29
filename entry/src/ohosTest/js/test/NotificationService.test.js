/**
 * Copyright (c) 2021 Huawei Device Co., Ltd.
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
import notificationService from '../../../main/js/default/service/NotificationService.js';
import {describe, beforeAll, beforeEach, afterEach, afterAll, it, expect} from 'deccjsunit/index'

describe('NotificationServiceTest', function () {
    it('sendNotify', 0, function () {
        var params = [];
        params.push({
            contactsName: 'asasaa',
            telephone: '18720910689',
            telephoneFormat: '18720910689',
        });
        var contactObjects = JSON.stringify(params);

        let actionData = {};
        actionData.contactObjects = JSON.stringify(contactObjects);
        actionData.message = {
            title: 'woweweew',
            text: 'I Love',
        };
        notificationService.sendNotify(actionData);
    })
})