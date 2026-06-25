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
import { messageType } from '../pages/conversationlist/conversationListController';
import Constant from '../data/Constant';
import EmitterConstant from '../data/EmitterConstant';
import { emitter } from '@kit.BasicServicesKit';
import { ThreadObjectUtils } from './conversationlist/ThreadObjectUtils';
import DeviceUtil from '../utils/DeviceUtil';

const TAG = 'ConversationListDataSource';

export default class ConversationListDataSource extends BaseDataSource {
  mmsList: Array<messageType> = [];
  public selectList: Array<messageType> = [];
  showIndex: Array<number> = [];
  cachedCount = 3;

    public totalCount(): number {
        return this.mmsList.length;
    }

  public getData(index: number): messageType | null {
    if (this.mmsList == null || index >= this.mmsList.length) {
      HiLog.i(TAG, 'getData is empty');
      return null;
    } else {
      this.mmsList[index].index = index;
      return this.mmsList[index];
    }
  }

  public refreshPage(listData: Array<messageType>, startIndex: number, page: number | null, isEnd?: boolean) {
    HiLog.i(TAG, ' refreshPage this.mmsList length: ' + this.mmsList.length + 'listData length: ' + listData.length);
    HiLog.i(TAG, ' refreshPage startIndex: ' + startIndex + 'page ' + page);
    if (page == 0) {
      HiLog.i(TAG, 'page is Zero');
      return;
    }
    let totalCount = listData.length + startIndex;
    let curLen = this.mmsList.length;
    if (totalCount > curLen) {
      for (let i = startIndex; i < totalCount; i++) {
        if (i >= curLen) {
          let newObj = new messageType();
          this.pushData(newObj);
        }
      }
    } else if (totalCount < curLen) {
      this.mmsList.splice(startIndex, isEnd ? this.mmsList.length : listData.length, ...listData);
    }
    ThreadObjectUtils.deepCopyThreadArrayInterval(this.mmsList, listData, startIndex,
      isEnd ? this.mmsList.length : listData.length);
    this.notifyDataReload();
  }

  public refreshIndexPage(listData: Array<messageType>, page: number | null, queryOffset: number) {
    HiLog.i(TAG, ` refreshIndexPage:${listData.length}`);
    if (page == 0) {
      HiLog.i(TAG, 'page is Zero');
    }
    if (this.mmsList.length > queryOffset) {
      HiLog.w(TAG, 'invalids queryOffset : ' + queryOffset);
      this.mmsList.splice(queryOffset);
    }
    this.mmsList = this.mmsList.concat(listData);
    this.notifyDataReload();
  }

  public selectData(index: number, isCbChecked: boolean, listLength?: number): void {
    this.mmsList[index].isCbChecked = isCbChecked;
    if (listLength) {
      this.selectList = []
      for(let i = 0; i < listLength; i++) {
        this.selectList.push(this.mmsList[i])
      }
    } else {
      if (!this.selectList.includes(this.mmsList[index]) && isCbChecked) {
        this.selectList.push(this.mmsList[index])
      } else if (this.selectList.includes(this.mmsList[index]) && !isCbChecked) {
        this.selectList.splice(this.selectList.indexOf(this.mmsList[index]), 1)
      }
    }
    AppStorage.setOrCreate('selectLength', this.selectList.length)
    emitter.emit(EmitterConstant.EVENT_CHECK_BOX_CHANGED);
  }

  public reload(listData: Array<messageType>, from?: string) {
    HiLog.i(TAG,
      'reload  sessionList, old length: ' + this.mmsList.length + ', new length: ' + listData.length + ',from:' + from);
    this.mmsList = listData;
    this.notifyDataReload();
  }

  public refresh(listData: Array<messageType>, from?: string) {
    HiLog.iw(TAG,
      'refresh sessionList, old length: ' + this.mmsList.length + ', new length: ' + listData.length + ',from:' + from);
    let isOldListEmpty = this.mmsList.length === 0;
    if (this.mmsList.length === 0 && listData.length === 0) {
      HiLog.w(TAG, ` refresh wrong`);
      return;
    }
    let curBp: string = AppStorage.get('curBp') as string;
    let strContactsNumber: number = AppStorage.get('selectPhoneNumber') ?? -1;
    if (curBp !== 'sm' && (DeviceUtil.isPC() || !DeviceUtil.isFloatingScreen())) {
      //通过赋值selectPhoneNumber为-1，后面再重新赋值selectPhoneNumber为原有的值为了使其选中会话重新刷新（折叠屏），防止新来消息或者生成草稿导致选中会话出现移位
      AppStorage.setOrCreate('selectPhoneNumber', -1);
    }

    if (!isOldListEmpty) {
      AppStorage.setOrCreate('isListReload', false);
    }
    if (!this.mmsList || (this.mmsList.length === 0)) {
      this.mmsList = listData;
    } else {
      this.makeArraysEqual(listData);
      ThreadObjectUtils.deepCopyThreadArray(this.mmsList, listData);
    }
    this.notifyDataReload();
    if (!isOldListEmpty) {
      AppStorage.setOrCreate('isListReload', true);
    }
    if (curBp !== 'sm' && (DeviceUtil.isPC() || !DeviceUtil.isFloatingScreen())) {
      AppStorage.setOrCreate('selectPhoneNumber', strContactsNumber);
    }
  }

  private makeArraysEqual(source: messageType[]) {
    let msgLen = this.mmsList.length;
    if (msgLen !== source.length) {
      if (msgLen > source.length) {
        let diffCount = msgLen - source.length;
        this.multiDelete(source.length, diffCount);
      } else {
        let diffCount = source.length - msgLen;
        for (let index = 0; index < diffCount; index++) {
          let newObj = new messageType();
          ThreadObjectUtils.deepCopyThread(newObj, source[index+msgLen]);
          this.pushData(newObj);
        }
      }
    }
  }

  public multiDelete(start: number, deleteCount: number) {
    HiLog.i(TAG, ` multiDelete ${start},${deleteCount}`);
    this.mmsList.splice(start, deleteCount);
    for (let index = 0; index < deleteCount; index++) {
      this.deleteByIndex(start);
    }
  }

  public pushData(data: messageType): void {
    HiLog.i(TAG, ` pushData ${data?.threadId}`);
    this.mmsList.push(data);
    this.notifyDataAdd(this.mmsList.length - 1);
  }

  public refreshList(listData: Array<messageType>) {
    HiLog.i(TAG, ' refreshList this.mmsList length: ' + this.mmsList.length + 'listData length: ' + listData.length);
    this.mmsList = listData;
  }

  public deleteByIndex(index: number) {
    HiLog.i(TAG, ' deleteByIndex this.mmsList length: ' + this.mmsList.length + 'index: ' + index);
    this.mmsList.splice(index, 1);
    this.notifyDataDelete(index);
  }

  public multiDeleteByThreadId(threadIdSet: Set<number>) {
    if (!(threadIdSet.size > 0)) {
      return;
    }
    HiLog.i(TAG, 'multiDeleteByThreadId start; length: ' + threadIdSet.size);
    for (let threadId of threadIdSet) {
      let targetIndex: number = this.mmsList.findIndex(data => data.threadId === threadId);
      if (targetIndex !== -1) {
        this.mmsList.splice(targetIndex, 1);
        this.notifyDataDelete(targetIndex);
      }
    }
    setTimeout(() => {
      this.notifyDataReload();
    }, 200);
  }

  public setIndex(start: number, end: number) {
    this.showIndex = [start, end];
  }

  public needNotifyDataReload(index: number, len: number) {
    if (this.showIndex.length >= 2) {
      if (index > (this.showIndex[1] + this.cachedCount) || (index + len) < this.showIndex[0] - this.cachedCount) {
        return false;
      }
    }
    return true;
  }
}