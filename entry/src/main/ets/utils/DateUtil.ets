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
import common from "../data/commonData";
import HiLog from "./HiLog";
// Time constant
const ONE_MINUTE_IN_MILLISECOND = 60000;
const ONE_HOUR_IN_MILLISECOND = 3600000;

const TAG = "DateUtil";

export default {

    /**
     * Converts the timestamp of an item to a time (for the SMS message list).
     *
     * @param messageItem
     * @param is24HourTime
     * @return
     */
    convertDateFormatForItem(messageItem, is24HourTime) {
        let now = new Date();
        let currentDate = {
            timeOfNow: now.getTime(),
            yearOfNow: now.getFullYear(),
            monthOfNow: now.getMonth() + 1,
            dayOfNow: now.getDate()
        };
        let timeMillisecond = messageItem.timeMillisecond;
        messageItem.time = this.convertTimeStampToTime(timeMillisecond, currentDate, is24HourTime);
    },

    /**
     * Converting a Timestamp to a Time (for SMS List)
     *
     * @param timeStampFromDb Timeline to be converted
     * @param currentDate Current Time
     * @param is24HourTime
     * @return
     */
    convertTimeStampToTime(timeStampFromDb, currentDate, is24HourTime) {
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
                return $r("app.string.justNow");
            } else if (diff < ONE_HOUR_IN_MILLISECOND) {
                return $r("app.string.minAgo", Math.floor(diff / ONE_MINUTE_IN_MILLISECOND));
            } else {
                let hoursOfSmsStr: string = '' + hoursOfSms;
                let minutesOfSmsStr: string = '' + minutesOfSms;
                if (hoursOfSms < 10) {
                    hoursOfSmsStr = "0" + hoursOfSms;
                }
                if (minutesOfSms < 10) {
                    minutesOfSmsStr = "0" + minutesOfSms;
                }
                if (is24HourTime) {
                    return $r("app.string.hourAndMinute", hoursOfSmsStr, minutesOfSmsStr);
                } else {
                    return this.timeTwelveHourSystem(hoursOfSms, minutesOfSmsStr, hoursOfSmsStr);
                }
            }
        } else if (currentDate.yearOfNow == yearOfSms && currentDate.monthOfNow == monthOfSms
        && currentDate.dayOfNow - dayOfSms == 1) {
            return $r("app.string.yesterday");
        } else if (currentDate.yearOfNow == yearOfSms) {
            return $r("app.string.monthDay", monthOfSms, dayOfSms);
        } else {
            return $r("app.string.yearMonthDay", yearOfSms, monthOfSms, dayOfSms);
        }
    },

    timeTwelveHourSystem(hoursOfSms, minutesOfSmsStr, hoursOfSmsStr) {
        let time: Resource = null;
        if (hoursOfSms <= 12) {
            time = this.morningTimeTwelveHourSystem(hoursOfSms, minutesOfSmsStr, hoursOfSmsStr);
        } else {
            time = this.afterTimeTwelveHourSystem(hoursOfSms, minutesOfSmsStr, hoursOfSmsStr);
        }
        return time;
    },

    morningTimeTwelveHourSystem(hoursOfSms, minutesOfSmsStr, hoursOfSmsStr) {
        let time: Resource = null;
        // 12-hour clock
        if (hoursOfSms < 1) {
            time = $r("app.string.postMidnight", 12 + '', minutesOfSmsStr);
        }
        if (hoursOfSms >= 1 && hoursOfSms < 4) {
            time = $r("app.string.beforeDawn", hoursOfSmsStr, minutesOfSmsStr);
        }
        if (hoursOfSms >= 4 && hoursOfSms < 6) {
            time = $r("app.string.earlyMorning", hoursOfSmsStr, minutesOfSmsStr);
        }
        if (hoursOfSms >= 6 && hoursOfSms < 9) {
            time = $r("app.string.morning", hoursOfSmsStr, minutesOfSmsStr);
        }
        if (hoursOfSms >= 9 && hoursOfSms < 11) {
            time = $r("app.string.forenoon", hoursOfSmsStr, minutesOfSmsStr);
        }
        if (hoursOfSms >= 11 && hoursOfSms <= 12) {
            time = $r("app.string.preNoon", hoursOfSms + '', minutesOfSmsStr);
        }
        return time;
    },

    afterTimeTwelveHourSystem(hoursOfSms, minutesOfSmsStr, hoursOfSmsStr) {
        let time: Resource = null;
        if (hoursOfSms > 12 && hoursOfSms < 13) {
            time = $r("app.string.postNoon", hoursOfSms + '', minutesOfSmsStr);
        }
        if (hoursOfSms >= 13 && hoursOfSms < 17) {
            time = $r("app.string.afternoon", (hoursOfSms - 12) + '', minutesOfSmsStr);
        }
        if (hoursOfSms >= 17 && hoursOfSms < 19) {
            time = $r("app.string.towardEvening", (hoursOfSms - 12) + '', minutesOfSmsStr);
        }
        if (hoursOfSms >= 19 && hoursOfSms < 23) {
            time = $r("app.string.evening", (hoursOfSms - 12) + '', minutesOfSmsStr);
        }
        if (hoursOfSms >= 23) {
            time = $r("app.string.preMidnight", (hoursOfSms - 12) + '', minutesOfSmsStr);
        }
        return time;
    },

    /**
     * Converting Time
     * @param messageItem
     * @param is24HourTime
     * @param that
     * @return
     */
    convertTimeStampToDateWeek(messageItem, is24HourTime) {
        let now = new Date();
        let yearOfNow = now.getFullYear();
        let monthOfNow = now.getMonth() + 1;
        let dayOfNow = now.getDate();
        let timeMillisecond = messageItem.timeMillisecond;
        this.convertTimeStampToDate(messageItem, timeMillisecond, yearOfNow, monthOfNow, dayOfNow);
    },

    /**
     * Converts the timestamp form to the date form.
     */
    convertTimeStampToDate(messageItem, timeStampFromDb, yearOfNow, monthOfNow, dayOfNow) {
        let date: Resource = null;
        let sms = new Date(timeStampFromDb);
        let yearOfSms = sms.getFullYear();
        let monthOfSms = sms.getMonth() + 1;
        let dayOfSms = sms.getDate();
        let weekOfSms = sms.getDay();
        if (yearOfNow == yearOfSms && monthOfNow == monthOfSms && dayOfNow == dayOfSms) {
            date = $r("app.string.recentDateToday", '');
        } else if (yearOfNow == yearOfSms && monthOfNow == monthOfSms && dayOfNow - dayOfSms == 1) {
            date = $r("app.string.recentDateYesterday", '');
        } else if (yearOfNow == yearOfSms) {
            date = $r("app.string.monthDayDate", monthOfSms, dayOfSms, '');
        } else {
            date = $r("app.string.yearMonthDayDate", yearOfSms, monthOfSms, dayOfSms, '');
        }
        messageItem.date = date;
        messageItem.week = this.getWeek(weekOfSms);
    },

    /**
     * Get Week/Day of the Week
     * @param day
     * @param that
     * @return
     */
    getWeek(day) {
        let week: Resource = null;
        switch (day) {
            case 0:
                week = $r("app.string.Sunday");
                break;
            case 1:
                week = $r("app.string.Monday");
                break;
            case 2:
                week = $r("app.string.Tuesday");
                break;
            case 3:
                week = $r("app.string.Wednesday");
                break;
            case 4:
                week = $r("app.string.Thursday");
                break;
            case 5:
                week = $r("app.string.Friday");
                break;
            case 6:
                week = $r("app.string.Saturday");
                break;

        }
        return week;
    },

    convertTimeStampDate(timeStampFromDb) {
        let date : Resource = null;
        let sms = new Date(Number(timeStampFromDb));
        let yearOfSms = sms.getFullYear();
        let monthOfSms = sms.getMonth() + 1;
        let dayOfSms = sms.getDate();
        let weekOfSms = sms.getDay();
        date = $r("app.string.yearMonthDayDate", yearOfSms, monthOfSms, dayOfSms, '');
        //        let time = this.convertTimeStampTime(timeStampFromDb, false);
        //        return date + " " + time;
        return date;
    },

    /**
     *
     * @param timeStampFromDb
     * @param is24HourTime
     * @param that
     * @return
     */
    convertTimeStampTime(timeStampFromDb, is24HourTime) {
        let sms = new Date(Number(timeStampFromDb));
        let hoursOfSms = sms.getHours();
        let minutesOfSms = sms.getMinutes();
        let hoursOfSmsStr: string = hoursOfSms + '';
        let minutesOfSmsStr: string = minutesOfSms + '';
        if (hoursOfSms < 10) {
            hoursOfSmsStr = "0" + hoursOfSms;
        }
        if (minutesOfSms < 10) {
            minutesOfSmsStr = "0" + minutesOfSms;
        }
        if (is24HourTime) {
            // 24-hour clock
            return $r("app.string.hourAndMinute", hoursOfSmsStr, minutesOfSmsStr);
        }
        return this.timeTwelveHourSystem(hoursOfSms, minutesOfSmsStr, hoursOfSmsStr);
    },

    fullDate(item) {
                let timeOfSms: Resource = null;
        let fullDate: Resource = null;
        let sms = new Date(item.timeMillisecond);
        let yearOfSms = sms.getFullYear();
        let monthOfSms = sms.getMonth() + 1;
        let dayOfSms = sms.getDate();
        let hoursOfSms = sms.getHours();
        let minutesOfSms = sms.getMinutes();
        let hoursOfSmsStr: string = hoursOfSms + '';
        let minutesOfSmsStr: string = minutesOfSms + '';
        if (hoursOfSms > 12) {
            hoursOfSmsStr = "" + (hoursOfSms - 12);
        }
        if (minutesOfSms < 10) {
            minutesOfSmsStr = "0" + minutesOfSms;
        }
        if( hoursOfSms < 12) {
            timeOfSms = $r("app.string.forenoon", hoursOfSmsStr, minutesOfSmsStr);
        } else {
            timeOfSms = $r("app.string.afternoon", hoursOfSmsStr, minutesOfSmsStr);
        }
        fullDate = $r("app.string.yearMonthDayDate", yearOfSms, monthOfSms, dayOfSms, '');
        item.fullDate = fullDate;
        item.timeOfSms = timeOfSms;
    }
}