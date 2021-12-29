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

import common from '../pages/common_constants.js';

// 时间常量
const ONE_MINUTE_IN_MILLISECOND = 60000;
const ONE_HOUR_IN_MILLISECOND = 3600000;

export default {

    /**
     * 将时间进行转化
     * @param messageItem 单个item
     * @param is24HourTime 是否是24小时
     * @param that
     * @return
     */
    convertDateFormatForItem(messageItem, is24HourTime, that) {
        let now = new Date();
        let currentDate = {
            timeOfNow: now.getTime(),
            yearOfNow: now.getFullYear(),
            monthOfNow: now.getMonth() + 1,
            dayOfNow: now.getDate()
        };
        let timeMillisecond = messageItem.timeMillisecond;
        messageItem.time = this.convertTimeStampToTime(timeMillisecond, currentDate, is24HourTime, that);
    },

    /**
     * 把时间戳形式转换为时间形式
     * @param timeStampFromDb
     * @param timeStampOfNow
     * @param yearOfNow
     * @param monthOfNow
     * @param dayOfNow
     * @param is24HourTime
     * @param that
     * @return
     */
    convertTimeStampToTime(timeStampFromDb, currentDate, is24HourTime, that) {
        let time = common.string.EMPTY_STR;
        let sms = new Date(timeStampFromDb);
        let timeStampOfSms = sms.getTime();
        let yearOfSms = sms.getFullYear();
        let monthOfSms = sms.getMonth() + 1;
        let dayOfSms = sms.getDate();
        let hoursOfSms = sms.getHours();
        let minutesOfSms = sms.getMinutes();
        let diff = currentDate.timeOfNow - timeStampOfSms;
        if (currentDate.yearOfNow == yearOfSms && currentDate.monthOfNow == monthOfSms
        && currentDate.dayOfNow == dayOfSms) {
            if (diff < ONE_MINUTE_IN_MILLISECOND) {
                time = that.$t('strings.justNow');
                return time;
            } else if (diff < ONE_HOUR_IN_MILLISECOND) {
                time = that.$t('strings.minAgo', {
                    minute: Math.floor(diff / ONE_MINUTE_IN_MILLISECOND)
                });
                return time;
            }
        }
        let tempHoursOfSms = hoursOfSms;
        if (hoursOfSms < 10) {
            tempHoursOfSms = '0' + hoursOfSms;
        }
        if (minutesOfSms < 10) {
            minutesOfSms = '0' + minutesOfSms;
        }
        if (is24HourTime) {
            // 24小时制
            time = that.$t('strings.hourAndMinute', {
                hour: tempHoursOfSms,
                minute: minutesOfSms
            });
            return time;
        }
        return this.timeTwelveHourSystem(hoursOfSms, minutesOfSms, tempHoursOfSms, that);
    },
    timeTwelveHourSystem(hoursOfSms, minutesOfSms, tempHoursOfSms, that) {
        let time = common.string.EMPTY_STR;
        if (hoursOfSms <= 12) {
            time = this.morningTimeTwelveHourSystem(hoursOfSms, minutesOfSms, tempHoursOfSms, that);
        } else {
            time = this.afterTimeTwelveHourSystem(hoursOfSms, minutesOfSms, tempHoursOfSms, that);
        }
        return time;
    },
    morningTimeTwelveHourSystem(hoursOfSms, minutesOfSms, tempHoursOfSms, that) {
        let time = common.string.EMPTY_STR;
        // 12小时制
        if (hoursOfSms < 1) {
            time = that.$t('strings.postMidnight', {
                hour: 12,
                minute: minutesOfSms
            });
        }
        if (hoursOfSms >= 1 && hoursOfSms < 4) {
            time = that.$t('strings.beforeDawn', {
                hour: tempHoursOfSms,
                minute: minutesOfSms
            });
        }
        if (hoursOfSms >= 4 && hoursOfSms < 6) {
            time = that.$t('strings.earlyMorning', {
                hour: tempHoursOfSms,
                minute: minutesOfSms
            });
        }
        if (hoursOfSms >= 6 && hoursOfSms < 9) {
            time = that.$t('strings.morning', {
                hour: tempHoursOfSms,
                minute: minutesOfSms
            });
        }
        if (hoursOfSms >= 9 && hoursOfSms < 11) {
            time = that.$t('strings.forenoon', {
                hour: tempHoursOfSms,
                minute: minutesOfSms
            });
        }
        if (hoursOfSms >= 11 && hoursOfSms <= 12) {
            time = that.$t('strings.preNoon', {
                hour: hoursOfSms,
                minute: minutesOfSms
            });
        }
        return time;
    },
    afterTimeTwelveHourSystem(hoursOfSms, minutesOfSms, tempHoursOfSms, that) {
        let time = common.string.EMPTY_STR;
        if (hoursOfSms > 12 && hoursOfSms < 13) {
            time = that.$t('strings.postNoon', {
                hour: hoursOfSms,
                minute: minutesOfSms
            });
        }
        if (hoursOfSms >= 13 && hoursOfSms < 17) {
            time = that.$t('strings.afternoon', {
                hour: hoursOfSms - 12,
                minute: minutesOfSms
            });
        }
        if (hoursOfSms >= 17 && hoursOfSms < 19) {
            time = that.$t('strings.towardEvening', {
                hour: hoursOfSms - 12,
                minute: minutesOfSms
            });
        }
        if (hoursOfSms >= 19 && hoursOfSms < 23) {
            time = that.$t('strings.evening', {
                hour: hoursOfSms - 12,
                minute: minutesOfSms
            });
        }
        if (hoursOfSms >= 23) {
            time = that.$t('strings.preMidnight', {
                hour: hoursOfSms - 12,
                minute: minutesOfSms
            });
        }
        return time;
    },

    /**
     * 将时间进行转化
     * @param messageItem 单个item
     * @param is24HourTime 是否是24小时
     * @param that
     * @return
     */
    convertTimeStampToDateWeek(messageItem, is24HourTime, that) {
        let now = new Date();
        let yearOfNow = now.getFullYear();
        let monthOfNow = now.getMonth() + 1;
        let dayOfNow = now.getDate();
        let timeMillisecond = messageItem.timeMillisecond;
        messageItem.date = this.convertTimeStampToDate(timeMillisecond, yearOfNow, monthOfNow, dayOfNow, that);
    },

    /**
     * 把时间戳形式转换为日期形式
     */
    convertTimeStampToDate(timeStampFromDb, yearOfNow, monthOfNow, dayOfNow, that) {
        let date = common.string.EMPTY_STR;
        let sms = new Date(timeStampFromDb);
        let yearOfSms = sms.getFullYear();
        let monthOfSms = sms.getMonth() + 1;
        let dayOfSms = sms.getDate();
        let weekOfSms = sms.getDay();
        if (yearOfNow == yearOfSms && monthOfNow == monthOfSms && dayOfNow == dayOfSms) {
            date = that.$t('strings.recentDate', {
                recent: that.$t('strings.today'),
                week: this.getWeek(weekOfSms, that)
            });
        } else if (yearOfNow == yearOfSms && monthOfNow == monthOfSms && dayOfNow - dayOfSms == 1) {
            date = that.$t('strings.recentDate', {
                recent: that.$t('strings.yesterday'),
                week: this.getWeek(weekOfSms, that)
            });
        } else if (yearOfNow == yearOfSms) {
            date = that.$t('strings.monthDayDate', {
                month: this.getMonth(monthOfSms, that),
                day: dayOfSms,
                week: this.getWeek(weekOfSms, that)
            });
        } else {
            date = that.$t('strings.yearMonthDayDate', {
                year: yearOfSms,
                month: this.getMonth(monthOfSms, that),
                day: dayOfSms,
                week: this.getWeek(weekOfSms, that)
            });
        }
        return date;
    },

    /**
     * 获取星期/周几
     * @param day
     * @param that
     * @return
     */
    getWeek(day, that) {
        let week = common.string.EMPTY_STR;
        switch (day) {
            case 0:
                week = that.$t('strings.Sunday');
                break;
            case 1:
                week = that.$t('strings.Monday');
                break;
            case 2:
                week = that.$t('strings.Tuesday');
                break;
            case 3:
                week = that.$t('strings.Wednesday');
                break;
            case 4:
                week = that.$t('strings.Thursday');
                break;
            case 5:
                week = that.$t('strings.Friday');
                break;
            case 6:
                week = that.$t('strings.Saturday');
                break;

        }
        return week;
    },

    /**
     * 获取月份
     * @param mon
     * @param that
     * @return
     */
    getMonth(mon, that) {
        let month = common.string.EMPTY_STR;
        switch (mon) {
            case 1:
                month = that.$t('strings.january');
                break;
            case 2:
                month = that.$t('strings.february');
                break;
            case 3:
                month = that.$t('strings.march');
                break;
            case 4:
                month = that.$t('strings.april');
                break;
            case 5:
                month = that.$t('strings.may');
                break;
            case 6:
                month = that.$t('strings.june');
                break;
            case 7:
                month = that.$t('strings.july');
                break;
            case 8:
                month = that.$t('strings.august');
                break;
            case 9:
                month = that.$t('strings.september');
                break;
            case 10:
                month = that.$t('strings.october');
                break;
            case 11:
                month = that.$t('strings.november');
                break;
            case 12:
                month = that.$t('strings.december');
                break;
        }
        return month;
    },

    convertTimeStampDate(timeStampFromDb, that) {
        let date = common.string.EMPTY_STR;
        let sms = new Date(timeStampFromDb);
        let yearOfSms = sms.getFullYear();
        let monthOfSms = sms.getMonth() + 1;
        let dayOfSms = sms.getDate();
        date = that.$t('strings.yearMonthDayDate', {
            year: yearOfSms,
            month: this.getMonth(monthOfSms, that),
            day: dayOfSms,
        });
        let time = this.convertTimeStampTime(timeStampFromDb, false, that);
        return date + ' ' + time;
    },

    /**
     *
     * @param timeStampFromDb
     * @param is24HourTime
     * @param that
     * @return
     */
    convertTimeStampTime(timeStampFromDb, is24HourTime, that) {
        let timeStr = common.string.EMPTY_STR;
        let sms = new Date(timeStampFromDb);
        let hoursOfSms = sms.getHours();
        let minutesOfSms = sms.getMinutes();
        let tempHoursOfSms = hoursOfSms;
        if (minutesOfSms < 10) {
            minutesOfSms = '0' + minutesOfSms;
        }
        if (hoursOfSms < 10) {
            tempHoursOfSms = '0' + hoursOfSms;
        }
        if (is24HourTime) {
            // 24小时制
            timeStr = that.$t('strings.hourAndMinute', {
                hour: tempHoursOfSms,
                minute: minutesOfSms
            });
            return timeStr;
        }
        return this.timeTwelveHourSystem(hoursOfSms, minutesOfSms, tempHoursOfSms, that);
    }
}