/**
 * Copyright (c) 2023 Huawei Device Co., Ltd.
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

const TAG = 'TransmitSearchListDataSource';

export interface searchType {
  index: number,
  search: LooseObject
}

export default class TransmitSearchListDataSource extends BaseDataSource {
  private searchList: Array<LooseObject> = [];

  public totalCount(): number {
    return this.searchList.length;
  }

  public getData(index: number): searchType | null {
    if (this.searchList == null || index >= this.searchList.length) {
      HiLog.i(TAG, 'search list is empty');
      return null;
    } else {
      let search = this.searchList[index];
      return {
        index: index,
        search: search
      };
    }
  }

  public refresh(searchList: LooseObject[], isAll: boolean) {
    HiLog.i(TAG, ' refresh!');
    if (searchList.length > 3) {
      if (!isAll) {
        this.searchList = searchList.slice(0, 3);
      } else {
        this.searchList = searchList;
      }
    } else {
      this.searchList = searchList;
    }
    this.notifyDataReload();
  }

  public refreshData() {
    this.notifyDataReload();
  }
}