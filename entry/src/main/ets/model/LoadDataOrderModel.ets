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
import HiLog from '../utils/HiLog';

const TAG = 'LoadDataOrderModel';

/**
 * 此类用于控制信息详情页的加载顺序
 */
export class LoadDataOrderModel {
  public static readonly FIRST_LOAD_DATA_COUNT = 90;
  public static readonly BATCH_LOAD_DATA_COUNT = 300;
  // list总共大小
  private totalSize: number = -1;
  //  第一次要加载的index
  private searchIndex: number = 0;
  // 当前已加载的data区间
  private loadedIntervalList: Interval[] = [];
  // 是否是第一次加载
  private isFirstLoad: boolean = true;

  /**
   * 初始化相关数据
   *
   * @param searchIndex 第一次要加载的index
   * @param totalSize 总共大小
   */
  public initParam(searchIndex: number, totalSize: number) {
    HiLog.i(TAG, ` initParam searchIndex:${searchIndex}, totalSize:${totalSize}`);
    this.reset();
    // searchIndex需要reverse
    this.searchIndex = searchIndex < 0 ? searchIndex : totalSize - searchIndex;
    this.totalSize = totalSize;
  }

  /**
   * 重置参数
   */
  public reset() {
    this.isFirstLoad = true;
    this.totalSize = -1;
    this.searchIndex = -1;
    this.loadedIntervalList = [];
  }

  /**
   * 是否加载完成
   * @returns true:是
   */
  public isLoadFinished(): boolean {
    HiLog.i(TAG,
      `isLoadFinished，${this.loadedIntervalList.length},${JSON.stringify(this.loadedIntervalList)},${this.totalSize}`);
    if (this.loadedIntervalList.length === 1 &&
      (this.loadedIntervalList[0].end - this.loadedIntervalList[0].start >= this.totalSize)) {
      return true;
    }
    return false;
  }


  /**
   * 获取其余数据需要加载的数据区间
   * 规则是：先加载头部min(剩余, BATCH_LOAD_DATA_COUNT )条，再加载尾部min(剩余, BATCH_LOAD_DATA_COUNT )条，
   * 再从头部加载剩余的 BATCH_LOAD_DATA_COUNT 一批次(延时)
   * 以 BATCH_LOAD_DATA_COUNT = 200 为例：
   * 1. totalSize = 1000，第一次跳转加载的index为900
   *    1. 第一次加载index附近20条：890-910
   *    2. 再从头部：0-200
   *    3. 再加载尾部200条：910-1000
   *    4.然后加载剩余：200-290,290-490,490-690,690-890,
   * 2. totalSize = 1000，第一次跳转加载的index为500
   *    1. 第一次加载index附近20条：490-510
   *    2. 再从头部：0-200
   *    3. 再加载尾部200条：800-1000
   *    4. 然后加载剩余：200-290,290-490,510-600,600-800
   * 3. totalSize = 1000，第一次跳转加载的index为0
   *    1. 第一次加载index附近20条：0-20
   *    2. 再从头部：20-220
   *    3. 再加载尾部200条：800-1000
   *    4. 然后加载剩余：220-420,420-620,620-820,820-1000
   *
   * @returns Interval：需要加载的区间
   */
  public getNextLoadDataInterval(): Interval {
    let res: Interval = new Interval(0, 0);
    try {
      if (this.isFirstLoad) {
        res = this.getFirstLoadData();
      } else {
        res = this.getOtherLoadDataInterval();
      }
    } catch (err) {
      HiLog.e(TAG, `getNextLoadDataInterval failed, code is ${err?.code}, message is ${err?.message}.`);
    }
    HiLog.i(TAG, `getNextLoadDataInterval interval start:${res.start}, end:${res.end}.`);
    return res;
  }

  /**
   * 获取第一次需要加载的数据区间，第一次加载对应index上下FIRST_LOAD_DATA_COUNT条
   *
   * @returns Interval：需要加载的区间
   */
  private getFirstLoadData(): Interval {
    let startIndex = 0;
    let endIndex = 0;
    if (this.searchIndex <= 0) {
      startIndex = 0;
      endIndex = LoadDataOrderModel.FIRST_LOAD_DATA_COUNT;
    } else if (this.searchIndex === this.totalSize) {
      startIndex = Math.max(0, this.totalSize - LoadDataOrderModel.FIRST_LOAD_DATA_COUNT);
      endIndex = this.totalSize;
    } else {
      startIndex = Math.max(0, this.searchIndex - LoadDataOrderModel.FIRST_LOAD_DATA_COUNT / 2);
      endIndex = Math.max(0, Math.min(this.totalSize, this.searchIndex + LoadDataOrderModel.FIRST_LOAD_DATA_COUNT / 2));
    }
    let initInterval: Interval = new Interval(startIndex, endIndex);
    this.loadedIntervalList = [];
    this.loadedIntervalList.push(initInterval);
    this.isFirstLoad = false;
    return initInterval;
  }

  private getOtherLoadDataInterval(): Interval {
    let loadedLen = this.loadedIntervalList.length;
    if (this.totalSize < 1 || loadedLen <= 0) {
      return new Interval(0, 0);
    }
    if (loadedLen <= 1 && this.loadedIntervalList[0].start === 0 &&
      this.loadedIntervalList[0].end === this.totalSize) {
      return new Interval(0, 0);
    }
    // 检查头部是否load
    let startInterval: Interval = this.loadedIntervalList[0];
    if (startInterval.start !== 0) {
      // 头部未加载，需要加载头部
      let curEnd = Math.min(LoadDataOrderModel.BATCH_LOAD_DATA_COUNT, startInterval.start);
      let curInterval = new Interval(0, curEnd);
      this.insertLoadedInterval(curInterval);
      return curInterval;
    }
    // 检查尾部是否load
    let endInterval: Interval = this.loadedIntervalList[loadedLen-1];
    if (endInterval.end !== this.totalSize) {
      // 尾部未加载，需要加载尾部
      let curEnd = Math.max(this.totalSize - LoadDataOrderModel.BATCH_LOAD_DATA_COUNT, endInterval.end);
      let curInterval = new Interval(curEnd, this.totalSize);
      this.insertLoadedInterval(curInterval);
      return curInterval;
    }
    // 从头部开始 BATCH_LOAD_DATA_COUNT 一批次
    let tailStart = this.loadedIntervalList[0].end;
    let tailEnd =
      Math.min(tailStart + LoadDataOrderModel.BATCH_LOAD_DATA_COUNT, this.loadedIntervalList[1].start);
    let nextInterval: Interval = new Interval(tailStart, tailEnd);
    this.insertLoadedInterval(nextInterval);
    return nextInterval;
  }

  /**
   * 插入已加载的数据区间
   *
   * @param loadedInterval 需要插入的区间
   */
  private insertLoadedInterval(loadedInterval: Interval) {
    let loadedLen = this.loadedIntervalList.length;
    let isOverlap: boolean = false;
    // 插入区间
    for (let i = 0; i < loadedLen; ++i) {
      let curStart = loadedInterval.start;
      let curEnd = loadedInterval.end;
      let curLoadedInterval = this.loadedIntervalList[i];
      if (curLoadedInterval.end >= curStart && curLoadedInterval.start <= curEnd) {
        curLoadedInterval.start = Math.min(curLoadedInterval.start, curStart);
        curLoadedInterval.end = Math.max(curLoadedInterval.end, curEnd);
        if (i + 1 < loadedLen) {
          // 不是最后一个区间时需要考虑是否能和后一个区间合并
          if (curLoadedInterval.end >= this.loadedIntervalList[i+1].start) {
            curLoadedInterval.end = Math.max(this.loadedIntervalList[i+1].end, curLoadedInterval.end);
            this.loadedIntervalList.splice(i + 1, 1);
          }
        }
        isOverlap = true;
        break;
      }
    }
    if (!isOverlap) {
      this.loadedIntervalList.push(loadedInterval);
    }
    this.loadedIntervalList.sort((interval1: Interval, interval2: Interval) => {
      return interval1.start - interval2.start;
    })
  }
}

/**
 * 加载区间
 */
export class Interval {
  public start: number = 0;
  public end: number = 0;

  constructor(start?: number, end?: number) {
    this.start = start ?? 0;
    this.end = end ?? 0;
  }
}