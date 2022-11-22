// @ts-nocheck
/**
 * Copyright (c) 2022 Huawei Device Co., Ltd.
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
import BaseDataSource from "./BaseDataSource";
import HiLog from "../utils/HiLog";

const TAG = "ConversationListDataSource";

export default class ConversationListDataSource extends BaseDataSource {
    private mmsList: Array = [];

    public totalCount(): number {
        HiLog.i(TAG, "totalCount is %s", this.mmsList.length);
        return this.mmsList.length;
    }

    public getData(index: number): any {
        if (this.mmsList == null || index >= this.mmsList.length) {
            HiLog.i(TAG, "getData Conversationlist is empty");
            return null;
        } else {
            let conversation = this.mmsList[index];
            return {
                index: index,
                conversation: conversation
            };
        }
    }

    public refresh(conversationList) {
        HiLog.i(TAG, " refresh!");
        this.mmsList = conversationList;
        this.notifyDataReload();
    }
}