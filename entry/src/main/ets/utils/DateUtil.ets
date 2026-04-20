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
import LooseObject from '../data/LooseObject';
import { mmsListType } from '../pages/conversation/conversationController';
import { messageType } from '../pages/conversationlist/conversationListController';
import HiLog from './HiLog';
import I18n from '@ohos.i18n';
import { BusinessError } from '@ohos.base';
import Intl from '@ohos.intl';
import { GlobalContext } from '../MainAbility/GlobalHelper';
import { ConversationListViewInfo } from '../model/conversationlist/ConversationListInfo';
import ObjectUtil from './ObjectUtil';
import LocationUtil from './LocationUtil';

// Time constant
const ONE_MINUTE_IN_MILLISECOND = 60000;
const ONE_HOUR_IN_MILLISECOND = 3600000;

const TAG = 'DateUtil';

/**
 *
 */
export class DateFormatFactory {
    private static autoRelativeTimeFormatNow: Intl.RelativeTimeFormat;
    private static dateTimeShortFormat: Intl.DateTimeFormat;
    private static dateFormatWeek: Intl.DateTimeFormat;
    private static isNot24HourTimeFormat: Intl.DateTimeFormat;
    private static is24HourTimeFormat: Intl.DateTimeFormat;

    //其中涉及的各个format的options在下面对应的create函数中也有，如果修改需要一起修改
    //后续如再有新增要写这些options的地方，可以抽出来，但是需要额外import一些类
    public static updateDateFactoryFormatters(intlLocale: Intl.Locale) {
        DateFormatFactory.autoRelativeTimeFormatNow = new Intl.RelativeTimeFormat(
          [intlLocale.language, intlLocale.region],
          {
            numeric: 'auto'
          }
        );
        DateFormatFactory.dateTimeShortFormat = new Intl.DateTimeFormat(
          [intlLocale.language, intlLocale.region],
          {
            dateStyle: 'short'
          }
        );
        DateFormatFactory.dateFormatWeek = new Intl.DateTimeFormat(
          [intlLocale.language, intlLocale.region],
          {
            weekday: 'long'
          }
        );
        DateFormatFactory.isNot24HourTimeFormat = new Intl.DateTimeFormat(
          [intlLocale.language, intlLocale.region],
          {
            hour12: true,
            hour: '2-digit',
            minute: '2-digit'
          }
        );
        DateFormatFactory.is24HourTimeFormat = new Intl.DateTimeFormat(
          [intlLocale.language, intlLocale.region],
          {
            hour12: false,
            hour: 'numeric',
            minute: '2-digit'
          }
        );
    }

    public static createAutoRelativeTimeFormat(locale: string | Array<string>): Intl.RelativeTimeFormat {
        if (!DateFormatFactory.autoRelativeTimeFormatNow) {
            DateFormatFactory.autoRelativeTimeFormatNow = new Intl.RelativeTimeFormat(locale, {
                numeric: 'auto'
            });
        }
        return DateFormatFactory.autoRelativeTimeFormatNow;
    }

    public static createDateTimeShortFormat(locale: string | Array<string>): Intl.DateTimeFormat {
        if (!DateFormatFactory.dateTimeShortFormat) {
            DateFormatFactory.dateTimeShortFormat = new Intl.DateTimeFormat(locale, {
                dateStyle: 'short'
            });
        }
        return DateFormatFactory.dateTimeShortFormat;
    }

    public static createDateFormatWeek(locale: string | Array<string>): Intl.DateTimeFormat {
        if (!DateFormatFactory.dateFormatWeek) {
            DateFormatFactory.dateFormatWeek = new Intl.DateTimeFormat(locale, {
                weekday: 'long'
            });
        }
        return DateFormatFactory.dateFormatWeek;
    }

    public static createIsNot24HourTimeFormat(locale: string | Array<string>): Intl.DateTimeFormat {
        if (!DateFormatFactory.isNot24HourTimeFormat) {
            DateFormatFactory.isNot24HourTimeFormat = new Intl.DateTimeFormat(locale, {
                hour12: true,
                hour: '2-digit',
                minute: '2-digit'
            });
        }
        return DateFormatFactory.isNot24HourTimeFormat;
    }

    public static createIs24HourTimeFormat(locale: string | Array<string>): Intl.DateTimeFormat {
        if (!DateFormatFactory.is24HourTimeFormat) {
            DateFormatFactory.is24HourTimeFormat = new Intl.DateTimeFormat(locale, {
                hour12: false,
                hour: 'numeric',
                minute: '2-digit'
            });
        }
        return DateFormatFactory.is24HourTimeFormat;
    }
}

export class CurrentDate {
    timeOfNow: number = 0
    yearOfNow: number = 0
    monthOfNow: number = 0
    dayOfNow: number = 0
}

/**
 * 重要：请尽可能不要在主线程以外的线程使用此工具类中的静态属性或方法
 */
export class DateUtil {
    private timeGetCount: number = 0;
    private static readonly MAX_TIME_GET_COUNT: number = 1000;
    public static intlLocale: Intl.Locale = new Intl.Locale();
    private static dateTimeLongFormat: Intl.DateTimeFormat = new Intl.DateTimeFormat(
      [DateUtil.intlLocale.language, DateUtil.intlLocale.region],
      {
        dateStyle: 'long'
      }
    );
    private static monthAndDayFormat: Intl.DateTimeFormat = new Intl.DateTimeFormat(
      [DateUtil.intlLocale.language, DateUtil.intlLocale.region],
      {
        month: 'long',
        day: 'numeric'
      }
    );
    private static dateFormatYear: Intl.DateTimeFormat = new Intl.DateTimeFormat(
      [DateUtil.intlLocale.language, DateUtil.intlLocale.region],
      {
        month: 'long',
        day: 'numeric',
        weekday: 'long'
      }
    );
    private static dateFormatFull: Intl.DateTimeFormat = new Intl.DateTimeFormat(
      [DateUtil.intlLocale.language, DateUtil.intlLocale.region],
      {
        dateStyle: 'full'
      }
    );

    // 其中涉及的各个format的options在上面对应属性的初始化中也有，如果修改需要一起修改
    // 后续如再有新增要写这些options的地方，可以抽出来，但是需要额外import一些类
    /**
     * update system Locale info
     * @param intlLocale
     */
    public static updateIntlLocalAndFormatters(intlLocale: Intl.Locale) {
        if (DateUtil.intlLocale.baseName == intlLocale.baseName) {
            return;
        }
        DateUtil.intlLocale = intlLocale;
        DateUtil.dateTimeLongFormat = new Intl.DateTimeFormat([intlLocale.language, intlLocale.region], {
            dateStyle: 'long'
        });
        DateUtil.monthAndDayFormat = new Intl.DateTimeFormat([intlLocale.language, intlLocale.region], {
            month: 'long',
            day: 'numeric'
        });
        DateUtil.dateFormatYear = new Intl.DateTimeFormat([intlLocale.language, intlLocale.region], {
            month: 'long',
            day: 'numeric',
            weekday: 'long'
        });
        DateUtil.dateFormatFull = new Intl.DateTimeFormat([intlLocale.language, intlLocale.region], {
            dateStyle: 'full'
        });
        DateFormatFactory.updateDateFactoryFormatters(intlLocale);
        AppStorage.setOrCreate('sysLocaleChanged', true);
        AppStorage.setOrCreate('smcSysLocaleChanged', true);
    }

    public static compareCalendarDates(dateOne: Date, dateTwo: Date): boolean {
        if (!dateOne || !dateTwo) {
            return false;
        }

        let dateOneYear = dateOne.getFullYear();
        let dateOneMonth = dateOne.getMonth();
        let dateOneDay = dateOne.getDate();

        let dateTwoYear = dateTwo.getFullYear();
        let dateTwoMonth = dateTwo.getMonth();
        let dateTwoDay = dateTwo.getDate();
        if (dateOneYear === dateTwoYear && dateOneMonth === dateTwoMonth && dateOneDay === dateTwoDay) {
            return true;
        } else {
            return false;
        }
    }

    /**
     * Converts the timestamp of an item to a time (for the SMS message list).
     *
     * @param messageItem
     * @return
     */
    public static convertDateFormatForItem(messageItem: LooseObject | messageType | ConversationListViewInfo) {
        let now = new Date();
        let currentDate: CurrentDate = {
            timeOfNow: now.getTime(),
            yearOfNow: now.getFullYear(),
            monthOfNow: now.getMonth() + 1,
            dayOfNow: now.getDate()
        };
        let timeMillisecond: number = Number(messageItem.timeMillisecond);
        messageItem.time = DateUtil.convertTimeStampToTime(timeMillisecond, currentDate, false);
        messageItem.detailTime = DateUtil.convertTimeStampToTime(timeMillisecond, currentDate, true);
        messageItem.itemTime = DateUtil.getMsmItemTime(timeMillisecond, currentDate);
    }

  public static getBlockedListDateFormat(blockedProps: number) {
    let isSevenDaysAgo: boolean = false;
    let sms = new Date(Number(blockedProps));
    let now = new Date();
    let todayTime: number = new Date(now.getFullYear() + '-' + (now.getMonth() + 1) + '-' + now.getDate()).getTime();
    if (todayTime - sms.getTime() > 7 * 24 * 3600 * 1000) {
      isSevenDaysAgo = true;
    }
    if (isSevenDaysAgo) {
      if (sms.getFullYear() == new Date().getFullYear()) {
        return DateUtil.monthAndDayFormat.format(sms);
      }
      let timeDetail: string = sms.getFullYear() + '/' + (sms.getMonth() + 1) + '/' + sms.getDate();
      return timeDetail;
    } else {
      return DateUtil.convertTimeStampTime(blockedProps);
    }
  }

    public getTimeWithCount() {
        this.timeGetCount = (this.timeGetCount + 1) % DateUtil.MAX_TIME_GET_COUNT;
        return Date.now() * DateUtil.MAX_TIME_GET_COUNT + this.timeGetCount;
    }

    /**
     * 处于骚扰拦截页面，切换系统语言，需要重新初始化，否则时间会不刷新
     *
     * @param intlLocale
     */
    public blockLocalChange(intlLocale: Intl.Locale) {
        DateUtil.updateIntlLocalAndFormatters(intlLocale)
    }

  /**
   * 判断会话列表时间显示是否为XX分钟前
   *
   * @param item 消息列表数据
   * @returns 是否时间显示XX分钟前
   */
  public static isDateDiffOneHour(item: messageType | mmsListType): boolean {
    if (!item || ObjectUtil.isUndefAndNull(item?.timeMillisecond)) {
      HiLog.w(TAG, `isDateDiffOneHour param invalid`);
      return false;
    }
    try {
      let sms = new Date(Number(item.timeMillisecond));
      let timeStampOfSms = sms.getTime();
      let now = new Date().getTime();
      if (now - timeStampOfSms < ONE_HOUR_IN_MILLISECOND) {
        HiLog.i(TAG, `isDateDiffOneHour threadId :${item?.threadId},msgId :${item?.id}`);
        return true;
      }
      return false;
    } catch (err) {
      HiLog.e(TAG, `isDateDiffOneHour failed, error code: ${err.code}, message: ${err.message}.`);
      return false;
    }
  }

  /**
   * 判断时间是否为两天内
   *
   * @param time 时间
   * @returns 时间是否为两天内
   */
  public static isDateInTwoDays(time: number): boolean {
    if (!time) {
      return false;
    }
    let nowDate = new Date();
    let curDate = new Date(time);
    if (DateUtil.calculateDiffInDay(curDate, nowDate) < 2) {
      return true;
    }
    return false;
  }

  /**
   * 计算两个日期的天数差
   * @param date1 日期1
   * @param date2 日期2
   * @returns 两个日期的天数差
   */
  public static calculateDiffInDay(date1: Date, date2: Date): number {
    let diffInDays = 0;
    try {

      // 去除时间部分（只保留日期）
      const strippedDate1 = new Date(date1.getFullYear(), date1.getMonth(), date1.getDate());
      const strippedDate2 = new Date(date2.getFullYear(), date2.getMonth(), date2.getDate());

      // 计算毫秒差值
      const diffInMs = Math.abs(strippedDate1.getTime() - strippedDate2.getTime());

      // 换算为天数
      const msPerDay = 24 * 60 * 60 * 1000;
      diffInDays = Math.floor(diffInMs / msPerDay);

    } catch (err) {
      HiLog.e(TAG, `calculateDiffInDay failed, error code: ${err?.code}, message: ${err?.message}.`);
      return diffInDays;
    }
    return diffInDays;
  }

  /**
     * Converting a Timestamp to a Time (for SMS List)+
     * 小于60秒，展示：刚刚
     * 小于一小时，展示：x分钟前
     * 当天内，展示：上午 10:30
     * 昨天内，展示：昨天
     * 当年内，展示：6月6日
     * 其他展示： 2024/01/01
     *
     * @param timeStampFromDb Timeline to be converted
     * @param currentDate Current Time
     * @param flag
     * @return
     */
    public static convertTimeStampToTime(timeStampFromDb: number,
      currentDate: CurrentDate, flag: boolean): Resource | string | null {
        let sms = new Date(timeStampFromDb);
        let timeStampOfSms = sms.getTime();
        let yearOfSms = sms.getFullYear();
        let monthOfSms = sms.getMonth() + 1;
        let dayOfSms = sms.getDate();
        let diff = currentDate.timeOfNow - timeStampOfSms;
        if ((currentDate.yearOfNow == yearOfSms && currentDate.monthOfNow == monthOfSms &&
            currentDate.dayOfNow == dayOfSms) || flag) {
            if (diff < ONE_MINUTE_IN_MILLISECOND) {
                return $r('app.string.justNow');
            } else if (diff < ONE_HOUR_IN_MILLISECOND) {
                return $r('app.plural.minAgo_new', Math.floor(diff / ONE_MINUTE_IN_MILLISECOND),
                  LocationUtil.numFormat(Math.floor(diff / ONE_MINUTE_IN_MILLISECOND)));
            } else {
                return DateUtil.convertTimeStampTime(timeStampFromDb);
            }
        } else if (currentDate.yearOfNow == yearOfSms && currentDate.monthOfNow == monthOfSms &&
            currentDate.dayOfNow - dayOfSms == 1) {
            return $r('app.string.yesterday');
        } else if (currentDate.yearOfNow == yearOfSms) {
            return DateUtil.monthAndDayFormat.format(sms);
        } else {
            return DateFormatFactory
                .createDateTimeShortFormat([DateUtil.intlLocale.language, DateUtil.intlLocale.region]).format(sms);
        }
    }

    public static getMsmItemTime(timeStampFromDb: number, currentDate: CurrentDate): number {
        let sms = new Date(timeStampFromDb);
        let timeStampOfSms = sms.getTime();
        let diff = currentDate.timeOfNow - timeStampOfSms;
        if (diff > ONE_MINUTE_IN_MILLISECOND && diff < ONE_HOUR_IN_MILLISECOND) {
            return Math.floor(diff / ONE_MINUTE_IN_MILLISECOND)
        }
        return 0;
    }

    public getTime(favoriteProps: number) {
        let detailTimeStr = DateUtil.convertTimeStampTime(Number(favoriteProps));
        let now = new Date();
        let yearOfNow = now.getFullYear();
        let monthOfNow = now.getMonth() + 1;
        let dayOfNow = now.getDate();
        let sms = new Date(favoriteProps);
        let yearOfSms = sms.getFullYear();
        let monthOfSms = sms.getMonth() + 1;
        let dayOfSms = sms.getDate();
        let dateStr = '';
        if (yearOfNow == yearOfSms && monthOfNow == monthOfSms && dayOfNow == dayOfSms) {
            dateStr = getContext(this).resourceManager.getStringSync($r('app.string.today').id);
        } else if (yearOfNow == yearOfSms && monthOfNow == monthOfSms && dayOfNow - dayOfSms == 1) {
            dateStr = getContext(this).resourceManager.getStringSync($r('app.string.yesterday').id);
        } else if (yearOfNow == yearOfSms) {
            dateStr = DateUtil.monthAndDayFormat.format(sms);
        } else {
            dateStr = DateUtil.dateTimeLongFormat.format(sms);
        }
        return `${dateStr} ${detailTimeStr}`
    }

    /**
     * Converting Time
     * @param messageItem
     * @param is24HourTime
     * @return
     */
    public static convertTimeStampToDateWeek(messageItem: mmsListType, is24HourTime: boolean) {
        let now = new Date();
        let yearOfNow = now.getFullYear();
        let monthOfNow = now.getMonth() + 1;
        let dayOfNow = now.getDate();
        let timeMillisecond: number = Number(messageItem.timeMillisecond);
        DateUtil.convertTimeStampToDate(messageItem, timeMillisecond, yearOfNow, monthOfNow, dayOfNow);
    }

    /**
     * Converts the timestamp form to the date form.
     */
    public static convertTimeStampToDate(messageItem: LooseObject, timeStampFromDb: number,
      yearOfNow: number, monthOfNow: number, dayOfNow: number) {
        let dateString: string = '';
        let sms = new Date(timeStampFromDb);
        let yearOfSms = sms.getFullYear();
        let monthOfSms = sms.getMonth() + 1;
        let dayOfSms = sms.getDate();
        let yesterday = new Date(new Date().getTime() - 24 * 60 * 60 * 1000);
        let yesterdayMonth = yesterday.getMonth() + 1;
        let yesterdayDay = yesterday.getDate();
        if (yearOfNow == yearOfSms && monthOfNow == monthOfSms && dayOfNow == dayOfSms) {
            dateString = DateFormatFactory
                .createAutoRelativeTimeFormat([DateUtil.intlLocale.language, DateUtil.intlLocale.region]).format(0, 'day');
            dateString = dateString.substring(0, 1).toUpperCase() + dateString.substring(1);
        } else if (yearOfNow == yearOfSms && monthOfSms == yesterdayMonth && dayOfSms == yesterdayDay) {
            dateString = DateFormatFactory
                .createAutoRelativeTimeFormat([DateUtil.intlLocale.language, DateUtil.intlLocale.region]).format(-1, 'day');
            dateString = dateString.substring(0, 1).toUpperCase() + dateString.substring(1);
        } else if (yearOfNow == yearOfSms) {
            dateString = DateUtil.dateFormatYear.format(sms);
        } else {
            dateString = DateUtil.dateFormatFull.format(sms);
        }
        messageItem.week = DateUtil.getWeek(timeStampFromDb);
        messageItem.dateString = dateString;
    }

    public static getMonthDayDate(timeStampFromDb: number): string {
      let sms = new Date(timeStampFromDb);
      let intlLocale: Intl.Locale = new Intl.Locale();
      let dateFormatYear = new Intl.DateTimeFormat(
        [intlLocale.language, intlLocale.region],
        {
          month: 'long',
          day: 'numeric',
          weekday: 'long'
        }
      );
        return dateFormatYear.format(sms);
    }

    /**
     * Get Week/Day of the Week
     * @param timeStampFromDb
     * @return
     */
    public static getWeek(timeStampFromDb: number) {
        let sms = new Date(timeStampFromDb);
        let week = DateFormatFactory
            .createDateFormatWeek([DateUtil.intlLocale.language, DateUtil.intlLocale.region]).format(sms);
        return week;
    }

    public static convertTimeStampDate(timeStampFromDb: number) {
        let sms = new Date(timeStampFromDb);
        let mmsTime = DateUtil.dateFormatFull.format(sms);
        return mmsTime;
    }

    /**
     *
     * @param timeStampFromDb
     * @return
     */
    public static convertTimeStampTime(timeStampFromDb: number): string {
        let is24HourTime: boolean = GlobalContext.getContext().getObject('is24HourTime') as boolean;
        let sms = new Date(timeStampFromDb);
        if (is24HourTime) {
            // 24-hour clock
            return DateFormatFactory
                .createIs24HourTimeFormat([DateUtil.intlLocale.language, DateUtil.intlLocale.region]).format(sms);
        }
        return DateFormatFactory
            .createIsNot24HourTimeFormat([DateUtil.intlLocale.language, DateUtil.intlLocale.region]).format(sms);
    }

    public static fullDate(item: mmsListType, params?: boolean) {
        let is24HourTime: boolean = false;
        try {
            is24HourTime = I18n.System.is24HourClock(); //系统24小时开关是否开启
        } catch (error) {
            let err: BusinessError = error as BusinessError;
            HiLog.e(TAG, `call System.is24HourClock failed, error code: ${err.code}, message: ${err.message}.`);
        }
        let sms = new Date(Number(item.timeMillisecond));
        let yearOfSms = sms.getFullYear();
        let monthOfSms = sms.getMonth() + 1;
        let dayOfSms = sms.getDate();
        let hoursOfSms = sms.getHours();
        let minutesOfSms = sms.getMinutes();
        let hoursOfSmsStr: string = hoursOfSms + '';
        let minutesOfSmsStr: string = minutesOfSms + '';
        if (hoursOfSms > 12) {
            hoursOfSmsStr = '' + (hoursOfSms - 12);
        }
        if (minutesOfSms < 10) {
            minutesOfSmsStr = '0' + minutesOfSms;
        }
        let fullDate = DateUtil.dateTimeLongFormat.format(sms);
        item.fullDate = fullDate;
        item.timeOfSms = DateUtil.convertTimeStampTime(Number(item.timeMillisecond));
        if (params) {
            item.fullDateParams = [yearOfSms, monthOfSms, dayOfSms, ''] as string[];
            if (is24HourTime) {
                item.timeOfSmsParams = [hoursOfSms + '', minutesOfSmsStr]
            } else {
                item.timeOfSmsParams = [hoursOfSmsStr, minutesOfSmsStr];
            }
        }
    }

    public static fullDates(item: messageType, params?: boolean) {
        let is24HourTime: boolean = false;
        try {
            is24HourTime = I18n.System.is24HourClock(); // 系统24小时开关是否开启
        } catch (error) {
            let err: BusinessError = error as BusinessError;
            HiLog.e(TAG, `call System.is24HourClock failed, error code: ${err.code}, message: ${err.message}.`);
        }
        let sms = new Date(Number(item.startTime));
        let yearOfSms = sms.getFullYear();
        let monthOfSms = sms.getMonth() + 1;
        let dayOfSms = sms.getDate();
        let hoursOfSms = sms.getHours();
        let minutesOfSms = sms.getMinutes();
        let hoursOfSmsStr: string = hoursOfSms + '';
        let minutesOfSmsStr: string = minutesOfSms + '';
        if (hoursOfSms > 12) {
            hoursOfSmsStr = '' + (hoursOfSms - 12);
        }
        if (minutesOfSms < 10) {
            minutesOfSmsStr = '0' + minutesOfSms;
        }
        let fullDate = DateUtil.dateTimeLongFormat.format(sms);
        item.fullDate = fullDate;
        item.timeOfSms = DateUtil.convertTimeStampTime(Number(item.timeMillisecond));

        if (params) {
            item.fullDateParams = [yearOfSms, monthOfSms, dayOfSms, ''] as string[];
            if (is24HourTime) {
                item.timeOfSmsParams = [hoursOfSms + '', minutesOfSmsStr]
            } else {
                item.timeOfSmsParams = [hoursOfSmsStr, minutesOfSmsStr];
            }
        }
    }

    public static formatMilliseconds(value: string) {
        let second = Math.floor((Number(value) / 1000)); // second
        if (Number.isNaN(second)) {
            second = 0;
        }
        let minute = 0; // minute
        if (second >= 60) {
            minute = Math.floor((second / 60));
            second = second % 60;
        }
        let timeStr: string = ((minute >= 10) ? minute : ('0' + minute)) + ':' +
            ((second >= 10) ? second : ('0' + second));
        return timeStr;
    }

    public static getDuration(durationString: string): number {
        HiLog.i(TAG, 'getDuration');
        if (durationString === '') {
            return 0;
        }
        let durationArr = durationString.split(':');
        let minterStr = durationArr[0];
        let secondStr = durationArr[1];
        let duration: number = (Number(minterStr) * 60 + Number(secondStr));
        return duration;
    }

    public static onlyUpdateSmsItemTime(smsItem: mmsListType, yearOfNow: number, monthOfNow: number, dayOfNow: number,
      yesterdayMonth: number, yesterdayDay: number, diff: number) {
      let timeStampFromDb: number = Number(smsItem.timeMillisecond);
      let itemTime = new Date(timeStampFromDb);
      let yearOfSms = itemTime.getFullYear();
      let monthOfSms = itemTime.getMonth() + 1;
      let dayOfSms = itemTime.getDate();

      let dateString: string = '';
      if (yearOfNow == yearOfSms && monthOfNow == monthOfSms && dayOfNow == dayOfSms) {
        dateString = DateFormatFactory
          .createAutoRelativeTimeFormat([DateUtil.intlLocale.language, DateUtil.intlLocale.region]).format(0, 'day');
        dateString = dateString.substring(0, 1).toUpperCase() + dateString.substring(1);
      } else if (yearOfNow == yearOfSms && monthOfSms == yesterdayMonth && dayOfSms == yesterdayDay) {
        dateString = DateFormatFactory
          .createAutoRelativeTimeFormat([DateUtil.intlLocale.language, DateUtil.intlLocale.region]).format(-1, 'day');
        dateString = dateString.substring(0, 1).toUpperCase() + dateString.substring(1);
      } else if (yearOfNow == yearOfSms) {
        dateString = DateUtil.dateFormatYear.format(itemTime);
      } else {
        dateString = DateUtil.dateFormatFull.format(itemTime);
      }
      smsItem.dateString = dateString;

      let showTimeStr: string | Resource = '';
      if (diff < ONE_MINUTE_IN_MILLISECOND) {
        showTimeStr = $r('app.string.justNow');
      } else if (diff < ONE_HOUR_IN_MILLISECOND) {
        showTimeStr = $r('app.plural.minAgo_new', Math.floor(diff / ONE_MINUTE_IN_MILLISECOND),
          LocationUtil.numFormat(Math.floor(diff / ONE_MINUTE_IN_MILLISECOND)));
      } else {
        let is24HourTime: boolean = GlobalContext.getContext().getObject('is24HourTime') as boolean;
        if (is24HourTime) {
          // 24-hour clock
          showTimeStr = DateFormatFactory
            .createIs24HourTimeFormat([DateUtil.intlLocale.language, DateUtil.intlLocale.region]).format(itemTime);
        } else {
          showTimeStr = DateFormatFactory
            .createIsNot24HourTimeFormat([DateUtil.intlLocale.language, DateUtil.intlLocale.region]).format(itemTime);
        }
      }
      smsItem.detailTime = showTimeStr;
    }

    /*
     * 判断两个unix时间，是否是同一天
     * 同一天返回false
     * 否则返回true
     * 参数不正确返回false
     * */
    public static isNotSameDay(aTimeMillisecond: number | string, bTimeMillisecond: number | string): boolean {
        let previousTime = Number(aTimeMillisecond);
        let currentItemTime = Number(bTimeMillisecond);
        if (isNaN(currentItemTime) || isNaN(previousTime) || previousTime === currentItemTime) {
            return false;
        }
        if (DateUtil.compareCalendarDates(new Date(previousTime), new Date(currentItemTime))) {
            return false;
        }
        return true
    }
    /**
     * Check if data is valid.
     *
     * @param data The data to be checked.
     */
    public static isDataValid<T>(data: T): boolean {
        return (data !== undefined) && (data !== null);
    }

    public getAudioAccessibilityText(duration: string): string {
        let minute: number = 0;
        let sencond: number = 0;
        let arrayTime = duration.split(':')
        minute = Number.parseFloat(arrayTime[0]);
        if (arrayTime.length > 1) {
            sencond = Number.parseFloat(arrayTime[1]);
        }
        let stringAudio: string = getContext(this).resourceManager.getStringSync($r('app.string.accessibility_audio'))
        let stringMinute: string = getContext(this).resourceManager.
        getPluralStringValueSync($r('app.plural.accessibility_audio_time_minute').id, minute);
        let stringSencond: string = getContext(this).resourceManager.
        getPluralStringValueSync($r('app.plural.accessibility_audio_time_second').id, sencond);
        let resultString = stringAudio + stringMinute + stringSencond;
        return resultString;
    }

}

export default new DateUtil()