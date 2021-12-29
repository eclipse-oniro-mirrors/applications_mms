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
import Router from '@system.router';

export default {
    data: {
        // 图标
        icon: 'ic_avatar_default.svg',
        // 名称
        name: '',
        // 手机号
        telephoneNum: []
    },
    onInit() {
        this.icon = this.iconFromConvPage;
        this.name = this.nameFromConvPage;
        this.telephoneNum = this.telephoneNumFromConvPage;
    },
    // 点击X号
    backToConversationPage() {
        Router.back({
            uri: 'pages/conversation/conversation'
        })
    },
    // 点击√号
    clickToSelectThisContact() {
        var oneContact = {};
        oneContact.icon = this.icon;
        oneContact.name = this.name;
        oneContact.telephoneNum = this.telephoneNum;
        this.$app.$def.oneContactInContactItemPickPage = oneContact;
        this.backToConversationPage();
    },
    // 点击checkbox
    changeOfCheckedValue(index, e) {
        this.telephoneNum[index].checked = e.checked;
    }
}
