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

import HiLog from '../../../utils/HiLog';
import { systemDateTime } from '@kit.BasicServicesKit';

// import caas from '@ohos.caas';

const TAG = '[MEETIME_MessageBaseLib] TimeUtils';

/**
 * 显示时间规则：yyyy/MM/dd
 */
const SHOW_TIME_RULE_ONY_DATE: number = 0;
/**
 * 显示时间规则：HH:mm
 */
const SHOW_TIME_RULE_ONY_TIME: number = 1;
/**
 * 显示时间规则：Yesterday
 */
const SHOW_TIME_RULE_YESTERDAY: number = 2;
/**
 * 显示时间规则：week
 */
const SHOW_TIME_RULE_ONLY_WEEK: number = 3;
/**
 * 显示时间规则：MM/dd
 */
const SHOW_TIME_RULE_IN_ONE_YEAR: number = 4;

/**
 * periodSleep方法中最大循环次数
 */
const PERIOD_SLEEP_MAX_TIME = 500;

const TIME_ORIGIN_STR = '1970-01-01';
/**
 * 时间工具类
 *
 * @since 2023-09-27
 */
export default class TimeUtils {
  // 事件进制60
  public static readonly TIME_SIXTY = 60;
  // 事件进制60
  public static readonly TIME_TWENTY_FOUR = 24;
  // 数字3
  public static readonly TIME_THREE = 3;
  // 数字5
  public static readonly TIME_FIVE = 5;
  // 一周7天
  public static readonly TIME_SEVEN = 7;
  // 一秒
  public static readonly ONE_SECOND = 1000;
  // 一分钟
  public static readonly ONE_MINUTE = TimeUtils.TIME_SIXTY * TimeUtils.ONE_SECOND;
  // 一小时
  public static readonly ONE_HOUR = TimeUtils.TIME_SIXTY * TimeUtils.ONE_MINUTE;
  // 一天
  public static readonly ONE_DAY = TimeUtils.TIME_TWENTY_FOUR * TimeUtils.ONE_HOUR;
  // 三天
  public static readonly THREE_DAY = TimeUtils.TIME_THREE * TimeUtils.ONE_DAY;
  // 五天
  public static readonly FIVE_DAY = TimeUtils.TIME_FIVE * TimeUtils.ONE_DAY;
  // 一周
  public static readonly ONE_WEEK = TimeUtils.TIME_SEVEN * TimeUtils.ONE_DAY;

  /**
   * 获取服务器当前时间
   *
   * @returns 服务器当前时间
   */
  static getServerCurrentTime(): number {
    let currentServerTime: number = new Date().getTime();
    HiLog.d(TAG, `current server time is: ${currentServerTime}`);
    return currentServerTime === 0 ? new Date().getTime() : currentServerTime;
  }

  /**
   * 时间转换
   *
   * @param number long类型时间戳
   */
  static covertLongToTime(time: number): string {
    if (typeof time === 'number' && time > 0 && time % 1 === 0) {
      let date = new Date(time);
      let year = date.getFullYear();
      let month = date.getMonth() + 1;
      let day = date.getDate();
      let hour = date.getHours();
      let minute = date.getMinutes();
      let standardTime = year + '-' + month + '-' + day + ' ' + hour + ':' + minute;
      return standardTime;
    } else {
      HiLog.e(TAG, 'covertLongToTime time is invalid');
      return '';
    }
  }

  /**
   * 格式化日期
   *
   * @param time 时间
   * @returns like 2021/09/17 13:04:00
   */
  static formatTime(time: number | string): string {
    let formatResult = '';
    try {
      if (typeof (time) === 'string') {
        time = Number(time);
      }
      const date = new Date();
      date.setTime(time);
    } catch (err) {
      HiLog.e(TAG, ` formatTime err code:${err?.code},msg:${err?.message} `);
    }
    return formatResult;
  }

  static getTextFormatTime(time: number): string {
    const TEN_RATE = 10;
    let messageDate = new Date();
    messageDate.setTime(time);
    let Y = messageDate.getFullYear();
    let M = (messageDate.getMonth() + 1 < TEN_RATE ? '0' + (messageDate.getMonth() + 1) : messageDate.getMonth() + 1);
    let D = (messageDate.getDate() < TEN_RATE ? '0' + messageDate.getDate() : messageDate.getDate());
    let h = (messageDate.getHours() < TEN_RATE ? '0' + messageDate.getHours() : messageDate.getHours());
    let m = (messageDate.getMinutes() < TEN_RATE ? '0' + messageDate.getMinutes() : messageDate.getMinutes());
    let mode = TimeUtils.getTimeMode(messageDate);
    HiLog.i(TAG, 'getTimeMode mode: ' + mode + ', time: ' + time);
    switch (mode) {
      case SHOW_TIME_RULE_ONY_DATE:
        return Y + '年' + M + '月' + D + '日 ';
      case SHOW_TIME_RULE_IN_ONE_YEAR:
        return M + '月' + D + '日 ';
      case SHOW_TIME_RULE_ONY_TIME:
        return h + ':' + m;
      case SHOW_TIME_RULE_YESTERDAY:
        return '昨天';
      case SHOW_TIME_RULE_ONLY_WEEK:
        return Y + '年' + M + '月' + D + '日 ';
      default:
        return h + ':' + m;
    }
  }

  static getTimeMode(messageDate: Date): number {
    if (!messageDate) {
      return SHOW_TIME_RULE_ONY_DATE;
    }
    let nowDate = new Date();
    HiLog.i(TAG, `getTimeMode messageDate: ${messageDate.toString()}, nowDate: ${nowDate}`);
    if ((messageDate.getFullYear() === nowDate.getFullYear()) && (messageDate.getDate() === nowDate.getDate())) {
      // 当天
      return SHOW_TIME_RULE_ONY_TIME;
    } else if ((messageDate.getFullYear() === nowDate.getFullYear()) &&
      (messageDate.getDate() === nowDate.getDate() - 1)) {
      // 昨天
      return SHOW_TIME_RULE_YESTERDAY;
    } else if ((messageDate.getFullYear() === nowDate.getFullYear()) &&
      (messageDate.getDate() > nowDate.getDate() - 7)) {
      // 一周内
      return SHOW_TIME_RULE_IN_ONE_YEAR;
    } else if (messageDate.getFullYear() === nowDate.getFullYear()) {
      // 一年内
      return SHOW_TIME_RULE_IN_ONE_YEAR;
    } else {
      return SHOW_TIME_RULE_ONY_DATE;
    }
  }

  /**
   * 获取最新一天指定时间点的timestamp
   *
   * @param hour 时
   * @param minute 分
   * @param second 秒
   * @returns number
   */
  static getLatestTimestamp(hour: number, minute: number, second: number): number {
    let date: Date = new Date();
    return Math.floor(Date.now() / TimeUtils.ONE_DAY) * TimeUtils.ONE_DAY +
      hour * TimeUtils.ONE_HOUR +
      minute * TimeUtils.ONE_MINUTE +
      date.getTimezoneOffset() * TimeUtils.ONE_MINUTE +
      second * TimeUtils.ONE_SECOND;
  }

  static isValidTimestamp(timestamp: string): boolean {
    if (!timestamp || isNaN(Number(timestamp))) {
      HiLog.i(TAG, 'timestamp is invalid' + ((timestamp)));
      return false;
    }
    let timestampNum = Number.parseInt(timestamp);
    if (timestampNum.toString().length === 10) {
      timestampNum *= 1000;
    }
    const minTimestamp = new Date(TIME_ORIGIN_STR).getTime();
    const maxTimestamp = Date.now();
    return timestampNum >= minTimestamp && timestampNum <= maxTimestamp;
  }

}