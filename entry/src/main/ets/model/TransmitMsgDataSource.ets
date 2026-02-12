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
import BaseDataSource from './BaseDataSource';
import HiLog from '../utils/HiLog';
import LooseObject from '../data/LooseObject';
import { mmsListType } from '../pages/conversation/conversationController';

export class listDataType {
    index: number = 0
    conversation?: mmsListType
}

const TAG = 'transmitMsgDataSource';

export default class TransmitMsgDataSource extends BaseDataSource {
    public mmsList: Array<mmsListType> = [];

    public totalCount(): number {
        return this.mmsList.length;
    }

    public getData(index: number): mmsListType | null {
        if (this.mmsList == null || index >= this.mmsList.length) {
            HiLog.i(TAG, 'getData is empty');
            return null;
        } else {
            this.mmsList[index].index = index;
            return this.mmsList[index];
        }
    }

    public refresh(listData: Array<mmsListType>) {
        HiLog.i(TAG, ' refresh!');
        this.mmsList = listData;
        this.notifyDataReload();
    }
}