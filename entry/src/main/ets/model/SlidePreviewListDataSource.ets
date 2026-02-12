/**
 * Copyright (c) 2024-2024 Huawei Device Co., Ltd.
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
import { SlideMmsItem } from '../utils/TypesUtils';

const TAG = 'SlidePreviewListDataSource';

export default class SlidePreviewListDataSource extends BaseDataSource {
  public slidePreviewList: Array<SlideMmsItem> = [];

  public totalCount(): number {
    return this.slidePreviewList.length;
  }

  public getData(index: number): SlideMmsItem | null {
    if (this.slidePreviewList == null || index >= this.slidePreviewList.length) {
      HiLog.i(TAG, 'getData is empty');
      return null;
    } else {
      return this.slidePreviewList[index];
    }
  }

  public refresh(listData: Array<SlideMmsItem>) {
    HiLog.i(TAG, ' refresh!');
    this.slidePreviewList = listData;
    this.notifyDataReload();
  }
}