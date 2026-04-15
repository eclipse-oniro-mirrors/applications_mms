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
import { emitter } from '@kit.BasicServicesKit';
import EmitterConstant from '../data/EmitterConstant';
import HiLog from '../utils/HiLog';
import { mmsListType } from '../pages/conversation/conversationController';

const TAG = 'ConversationDataSource';

export default class ConversationDataSource extends BaseDataSource {
    private static sInstance: ConversationDataSource;
    public mmsList: Array<mmsListType> = [];
    //用于计算多选框选中数量
    public selectList: Array<mmsListType> = [];
    //发送动画执行的时候，刷新列表会导致动画中断，直接跳到最终位置
    private isNeedRefresh: boolean = false; //记录是否调用了刷新
    private isSendingAnimate: boolean = false; //记录是否在执行发送动画

    constructor() {
        super();
    }

    public static getInstance() {
        if (!ConversationDataSource.sInstance) {
            ConversationDataSource.sInstance = new ConversationDataSource();
        }
        return ConversationDataSource.sInstance
    }

    public setIsSendingAnimate(isAnimate: boolean) {
        this.isSendingAnimate = isAnimate;
        if (isAnimate) {
            setTimeout(() => {
                //防止意外导致阻断刷新值不更新，延迟一秒后恢复
                this.setIsSendingAnimate(false)
                HiLog.i(TAG, 'Restore the refresh.');
            }, 1000)
        }
        //发送动画结束的时候，如果期间有调用刷新。则触发一次刷新
        if (!isAnimate && this.isNeedRefresh) {
            HiLog.i(TAG, 'Refresh at the end of the animation')
            this.refresh(this.mmsList)
        }
    }

    public setIsSendingRCSAnimate(index: number) {
        if (this.isSendingAnimate) {
            setTimeout(() => {
                //防止意外导致阻断刷新值不更新，延迟一秒后恢复
                this.setIsSendingRCSAnimate(index);
                HiLog.i(TAG, 'Restore the refresh.');
            }, 1000)
        }
        //发送动画结束的时候，如果期间有调用刷新。则触发一次刷新
        if (!this.isSendingAnimate) {
            HiLog.i(TAG, 'Refresh at the end of the animation')
            this.notifyDataChange(index);
        }
    }

    public totalCount(): number {
        return this.mmsList.length;
    }

    public getData(index: number): mmsListType | null {
        if (this.mmsList == null || index >= this.mmsList.length) {
            HiLog.i(TAG, 'getData is empty');
            return null;
        } else {
            return this.mmsList[index];
        }
    }

    public refresh(listData: Array<mmsListType>) {
        HiLog.i(TAG, 'refresh');
        this.mmsList = listData;
        //发送动画期间，刷新只记录数据不刷新页面
        if (this.isSendingAnimate) {
            this.isNeedRefresh = true;
            return;
        }
        this.isNeedRefresh = false;
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
        AppStorage.setOrCreate('conversationSelectNumber', this.selectList.length);
        emitter.emit(EmitterConstant.EVENT_CHECK_BOX_CHANGED);
    }

    public refreshPartial(listData: Array<mmsListType>, start: number, end: number) {
        HiLog.i(TAG, 'refreshPartial start ' + start + ' ,end' + end);
        if (start < 0 || end < 0 || start > end) {
            start = Math.max(start, 0);
            end = Math.max(end, 0);
        }
        this.mmsList = listData;
        for (let index = end; index >= start; index--) {
            if (index < this.mmsList.length && this.mmsList[index] != undefined) {
                this.notifyDataChange(index);
            } else {
                HiLog.i(TAG, 'not notifyDataChange ' + index);
                break; // 防止数据不一致。如果[start, end]打印这个，就看不到信息
            }
        }
    }

    public addDataByIndexes(indexes: Array<number>) {
        for (let v of indexes.values()) {
            this.notifyDataAdd(v);
        }
    }

    public updateByIndex(index: number) {
        this.notifyDataChange(index)
    }

    public refreshList(listData: Array<mmsListType>) {
        HiLog.i(TAG, ' refreshList!');
        this.mmsList = listData;
    }

    public deleteByIndex(index: number) {
        HiLog.i(TAG, 'deleteByIndex ' + index);
        this.mmsList.splice(index, 1);
        this.notifyDataDelete(index);
    }

    public clear() {
        this.mmsList = [];
        this.selectList = []
        this.notifyDataReload();
    }
}