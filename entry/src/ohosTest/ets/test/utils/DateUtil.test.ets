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
import { describe, it, expect, when, ArgumentMatchers } from '@ohos/hypium';
import { GlobalContext } from '../../../../main/ets/MainAbility/GlobalHelper';
import { mmsListType } from '../../../../main/ets/pages/conversation/conversationController';
import dateUtil, { CurrentDate, DateFormatFactory, DateUtil } from '../../../../main/ets/utils/DateUtil';
import { MockKit } from '@ohos/hypium/src/main/module/mock/MockKit';
import I18n from '@ohos.i18n';
import { messageType } from '../../../../main/ets/pages/conversationlist/conversationListController';
import LooseObject from '../../../../main/ets/data/LooseObject';
import Intl from '@ohos.intl';
import HiLog from '../../../../main/ets/utils/HiLog';

export default function DateUtilTest() {
  describe('DateUtilTest', () => {
    const TAG = 'DateUtilTest';

    it('DateUtilTest_createIs24HourTimeFormat', 0, () => {
      DateFormatFactory.createIs24HourTimeFormat('');
      let res = DateFormatFactory.createIs24HourTimeFormat('');
      expect(JSON.stringify(res)).assertEqual('{}');
    })

    it('DateUtilTest_compareCalendarDates', 0, () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(DateUtil, DateUtil.convertTimeStampToTime))(ArgumentMatchers.any).afterReturn('');
      let res: boolean = DateUtil.compareCalendarDates(new Date(), new Date());
      expect(res).assertTrue();
      mocker.clear(DateUtil);
    })

    it('DateUtilTest_compareCalendarDates_param_undefined', 0, () => {
      let res: boolean = DateUtil.compareCalendarDates(undefined, undefined);
      expect(res).assertFalse();
    })

    it('DateUtilTest_compareCalendarDates1', 0, () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(DateUtil, DateUtil.convertTimeStampToTime))(ArgumentMatchers.any).afterReturn('');
      let res: boolean = DateUtil.compareCalendarDates(new Date(), new Date(1699010047));
      expect(res).assertFalse();
      mocker.clear(DateUtil);
    })

    it('DateUtilTest_convertDateFormatForItem2', 0, () => {
      let messageItem: LooseObject | messageType = {
        timeMillisecond: 1699010047,
        time: '',
        detailTime: '',
        itemTime: ''
      } as LooseObject;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(DateUtil, DateUtil.convertTimeStampToTime))(ArgumentMatchers.any).afterReturn('');
      DateUtil.convertDateFormatForItem(messageItem);
      expect(messageItem.itemTime).assertEqual(0);
      mocker.clear(DateUtil);
    })

    it('DateUtilTest_getTimeWithCount', 0, () => {
      let res = dateUtil.getTimeWithCount();
      expect((res/1000000).toFixed(0)).assertEqual((Date.now()/1000).toFixed(0));
    })

    it('DateUtilTest_convertTimeStampToTime', 0, () => {
      let timeStampFromDb: number = 1699010047;
      let sms = new Date(timeStampFromDb);
      let yearOfSms = sms.getFullYear();
      let monthOfSms = sms.getMonth() + 1;
      let dayOfSms = sms.getDate();
      let currentDate: CurrentDate = {
        yearOfNow: yearOfSms,
        monthOfNow: monthOfSms,
        dayOfNow: dayOfSms,
        timeOfNow: sms.getTime()
      } as CurrentDate;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('is24HourTime')
        .afterReturn(false);
      let res = DateUtil.convertTimeStampToTime(timeStampFromDb, currentDate, true);
      mocker.clear(GlobalContext.getContext())
      expect(res == null).assertFalse();
    })

    it('DateUtilTest_convertTimeStampToTime1', 0, () => {
      let timeStampFromDb: number = 1699010047;
      let sms = new Date(timeStampFromDb);
      let yearOfSms = sms.getFullYear();
      let monthOfSms = sms.getMonth() + 1;
      let dayOfSms = sms.getDate();
      let currentDate: CurrentDate = {
        yearOfNow: yearOfSms,
        monthOfNow: monthOfSms,
        dayOfNow: dayOfSms,
        timeOfNow: sms.getTime() + 80001
      } as CurrentDate;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('is24HourTime')
        .afterReturn(false);
      let res = DateUtil.convertTimeStampToTime(timeStampFromDb, currentDate, true);
      mocker.clear(GlobalContext.getContext())
      expect(res == null).assertFalse();
    })

    it('DateUtilTest_convertTimeStampToTime2', 0, () => {
      let timeStampFromDb: number = 1699010047;
      let sms = new Date(timeStampFromDb);
      let yearOfSms = sms.getFullYear();
      let monthOfSms = sms.getMonth() + 1;
      let dayOfSms = sms.getDate();
      let currentDate: CurrentDate = {
        yearOfNow: yearOfSms,
        monthOfNow: monthOfSms,
        dayOfNow: dayOfSms,
        timeOfNow: sms.getTime() + 3600001
      } as CurrentDate;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(DateUtil, DateUtil.convertTimeStampTime))(ArgumentMatchers.any).afterReturn('');
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('is24HourTime')
        .afterReturn(false);
      let res = DateUtil.convertTimeStampToTime(timeStampFromDb, currentDate, true);
      mocker.clear(DateUtil)
      mocker.clear(GlobalContext.getContext())
      expect(res).assertEqual('');
    })

    it('DateUtilTest_convertTimeStampToTime3', 0, () => {
      let timeStampFromDb: number = 1699010047;
      let sms = new Date(timeStampFromDb);
      let yearOfSms = sms.getFullYear();
      let monthOfSms = sms.getMonth() + 1;
      let dayOfSms = sms.getDate();
      let currentDate: CurrentDate = {
        yearOfNow: yearOfSms + 1,
        monthOfNow: monthOfSms,
        dayOfNow: dayOfSms,
        timeOfNow: sms.getTime() + 3600001
      } as CurrentDate;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('is24HourTime')
        .afterReturn(false);
      when(mocker.mockFunc(DateUtil, DateUtil.convertTimeStampTime))(ArgumentMatchers.any).afterReturn('');
      let res = DateUtil.convertTimeStampToTime(timeStampFromDb, currentDate, true);
      mocker.clear(DateUtil)
      mocker.clear(GlobalContext.getContext())
      expect(res).assertEqual('');
    })

    it('DateUtilTest_convertTimeStampToTime4', 0, () => {
      let timeStampFromDb: number = 1699010047;
      let sms = new Date(timeStampFromDb);
      let yearOfSms = sms.getFullYear();
      let monthOfSms = sms.getMonth() + 1;
      let dayOfSms = sms.getDate();
      let currentDate: CurrentDate = {
        yearOfNow: yearOfSms,
        monthOfNow: monthOfSms,
        dayOfNow: dayOfSms + 1,
        timeOfNow: sms.getTime() + 3600001
      } as CurrentDate;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(DateUtil, DateUtil.convertTimeStampTime))(ArgumentMatchers.any).afterReturn('');
      let res = DateUtil.convertTimeStampToTime(timeStampFromDb, currentDate, true);
      expect(JSON.stringify((res as Resource).params)).assertUndefined();
      mocker.clear(DateUtil);
    })

    it('DateUtilTest_convertTimeStampToTime5', 0, () => {
      let timeStampFromDb: number = 1699010047;
      let sms = new Date(timeStampFromDb);
      let yearOfSms = sms.getFullYear();
      let monthOfSms = sms.getMonth() + 1;
      let dayOfSms = sms.getDate();
      let currentDate: CurrentDate = {
        yearOfNow: yearOfSms,
        monthOfNow: monthOfSms + 1,
        dayOfNow: dayOfSms,
        timeOfNow: sms.getTime() + 3600001
      } as CurrentDate;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('is24HourTime')
        .afterReturn(false);
      let res = DateUtil.convertTimeStampToTime(timeStampFromDb, currentDate, true);
      mocker.clear(GlobalContext.getContext())
      expect(res).assertEqual('下午11:56');
    })

    it('DateUtilTest_convertTimeStampToTime6', 0, () => {
      let timeStampFromDb: number = 1699010047;
      let sms = new Date(timeStampFromDb);
      let yearOfSms = sms.getFullYear();
      let monthOfSms = sms.getMonth() + 1;
      let dayOfSms = sms.getDate();
      let currentDate: CurrentDate = {
        yearOfNow: yearOfSms + 1,
        monthOfNow: monthOfSms,
        dayOfNow: dayOfSms,
        timeOfNow: sms.getTime() + 3600001
      } as CurrentDate;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(DateFormatFactory, DateFormatFactory.createDateTimeShortFormat))(ArgumentMatchers.any)
        .afterReturn('');
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('is24HourTime')
        .afterReturn(false);
      let res = DateUtil.convertTimeStampToTime(timeStampFromDb, currentDate, true);
      expect(res).assertEqual('下午11:56');
      mocker.clear(DateFormatFactory);
      mocker.clear(GlobalContext.getContext());
    })

    it('DateUtilTest_convertTimeStampToTime_277', 0, () => {
      let timeStampFromDb: number = 1699010047;
      let sms = new Date(timeStampFromDb);
      let yearOfSms = sms.getFullYear();
      let monthOfSms = sms.getMonth() + 1;
      let dayOfSms = sms.getDate();
      let currentDate: CurrentDate = {
        yearOfNow: yearOfSms,
        monthOfNow: monthOfSms,
        dayOfNow: dayOfSms + 1,
        timeOfNow: sms.getTime() + 3600001
      } as CurrentDate;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(DateFormatFactory, DateFormatFactory.createDateTimeShortFormat))(ArgumentMatchers.any)
        .afterReturn('');
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('is24HourTime')
        .afterReturn(false);
      let res = DateUtil.convertTimeStampToTime(timeStampFromDb, currentDate, false);
      expect(res == null).assertFalse();
      mocker.clear(DateFormatFactory);
      mocker.clear(GlobalContext.getContext());
    })

    it('DateUtilTest_getMsmItemTime', 0, () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(DateUtil, DateUtil.convertTimeStampTime))(ArgumentMatchers.any).afterReturn('');
      let res = DateUtil.getMsmItemTime(0, {
        timeOfNow: 60001
      } as CurrentDate);
      expect(res).assertEqual(1);
      mocker.clear(DateUtil);
    })

    it('DateUtilTest_getMsmItemTime1', 0, () => {
      let mocker: MockKit = new MockKit();
      let sms = new Date('1699010047');
      when(mocker.mockFunc(DateUtil, DateUtil.convertTimeStampTime))(ArgumentMatchers.any).afterReturn('');
      let res = DateUtil.getMsmItemTime(0, {
        timeOfNow: 600
      } as CurrentDate);
      expect(res).assertEqual(0);
      mocker.clear(DateUtil);
    })

    it('DateUtilTest_convertTimeStampToDateWeek', 0, () => {
      let messageItem = {
        date: '',
        week: {},
        timeMillisecond: '1699010047'
      } as mmsListType;
      let mocker: MockKit = new MockKit();
      let res = false;
      when(mocker.mockFunc(DateUtil, DateUtil.convertTimeStampToDate))(ArgumentMatchers.any).afterAction(() => {
        res = true;
      });
      DateUtil.convertTimeStampToDateWeek(messageItem, false)
      expect(res).assertTrue();
      mocker.clear(DateUtil);
    })

    it('DateUtilTest_convertTimeStampToDate1', 0, () => {
      let timeStampFromDb = 1699010047;
      let sms = new Date(timeStampFromDb);
      let yearOfSms = sms.getFullYear();
      let monthOfSms = sms.getMonth() + 1;
      let dayOfSms = sms.getDate();

      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(DateFormatFactory, DateFormatFactory.createAutoRelativeTimeFormat))(ArgumentMatchers.any)
        .afterReturn(new Intl.RelativeTimeFormat(I18n.System.getSystemLocale(), {
          numeric: 'auto'
        }));
      when(mocker.mockFunc(DateUtil, DateUtil.getWeek))(ArgumentMatchers.any).afterReturn('1');

      let messageItem = {
        date: '',
        week: {}
      } as mmsListType
      DateUtil.convertTimeStampToDate(messageItem, timeStampFromDb, yearOfSms, monthOfSms, dayOfSms);
      expect(messageItem.week).assertEqual('1');

      mocker.clear(DateFormatFactory);
      mocker.clear(messageItem);
      mocker.clear(DateUtil);
    })

    it('DateUtilTest_convertTimeStampToDate2', 0, () => {
      let timeStampFromDb = 1699010047;
      let sms = new Date(timeStampFromDb);
      let yearOfSms = sms.getFullYear();
      let yesterday = new Date(new Date().getTime() - 24 * 60 * 60 * 1000);
      let yesterdayMonth = yesterday.getMonth() + 1;
      let yesterdayDay = yesterday.getDate();

      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(DateFormatFactory, DateFormatFactory.createAutoRelativeTimeFormat))(ArgumentMatchers.any)
        .afterReturn(new Intl.DateTimeFormat(I18n.System.getSystemLocale(), {
          hour12: false,
          hour: 'numeric',
          minute: '2-digit'
        }));
      when(mocker.mockFunc(DateUtil, DateUtil.getWeek))(ArgumentMatchers.any).afterReturn('1');

      let messageItem = {
        date: '',
        week: {}
      } as mmsListType
      DateUtil.convertTimeStampToDate(messageItem, timeStampFromDb, yearOfSms, yesterdayMonth, yesterdayDay);
      expect(messageItem.week).assertEqual('1');

      mocker.clear(DateFormatFactory);
      mocker.clear(DateUtil);
      mocker.clear(messageItem);
    })

    it('DateUtilTest_convertTimeStampToDate3', 0, () => {
      let timeStampFromDb = 1699010047;
      let sms = new Date(timeStampFromDb);
      let yearOfSms = sms.getFullYear();
      let yesterday = new Date(new Date().getTime() - 24 * 60 * 60 * 1000);
      let yesterdayMonth = yesterday.getMonth() + 1;
      let yesterdayDay = yesterday.getDate();

      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(DateFormatFactory, DateFormatFactory.createAutoRelativeTimeFormat))(ArgumentMatchers.any)
        .afterReturn(new Intl.DateTimeFormat(I18n.System.getSystemLocale(), {
          hour12: false,
          hour: 'numeric',
          minute: '2-digit'
        }));
      when(mocker.mockFunc(DateUtil, DateUtil.getWeek))(ArgumentMatchers.any).afterReturn('1');

      let messageItem = {
        date: '',
        week: {}
      } as mmsListType
      DateUtil.convertTimeStampToDate(messageItem, timeStampFromDb, yearOfSms, yesterdayMonth, yesterdayDay - 1);
      expect(messageItem.week).assertEqual('1');

      mocker.clear(DateFormatFactory);
      mocker.clear(DateUtil);
      mocker.clear(messageItem);
    })

    it('DateUtilTest_convertTimeStampToDate4', 0, () => {
      let timeStampFromDb = new Date().getTime() - 24 * 60 * 60 * 1000;
      let sms = new Date(timeStampFromDb);
      let yearOfSms = sms.getFullYear();
      let yesterday = new Date(new Date().getTime() - 24 * 60 * 60 * 1000);
      let yesterdayMonth = yesterday.getMonth() + 1;
      let yesterdayDay = yesterday.getDate();

      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(DateFormatFactory, DateFormatFactory.createAutoRelativeTimeFormat))(ArgumentMatchers.any)
        .afterReturn(new Intl.DateTimeFormat(I18n.System.getSystemLocale(), {
          hour12: false,
          hour: 'numeric',
          minute: '2-digit'
        }));
      when(mocker.mockFunc(DateUtil, DateUtil.getWeek))(ArgumentMatchers.any).afterReturn('1');

      let messageItem = {
        date: '',
        week: {}
      } as mmsListType
      DateUtil.convertTimeStampToDate(messageItem, timeStampFromDb / 1000, yearOfSms, yesterdayMonth + 1, yesterdayDay + 2);
      expect(messageItem.week).assertEqual('1');

      mocker.clear(DateFormatFactory);
      mocker.clear(DateUtil);
    })

    it('DateUtilTest_convertTimeStampToDate_monthOfSms_equal_yesterdayMonth', 0, () => {
      let timeStampFromDb = new Date().getTime() - 24 * 60 * 60 * 1000;
      let sms = new Date(timeStampFromDb);
      let yearOfSms = sms.getFullYear();
      let yesterday = new Date(new Date().getTime() - 24 * 60 * 60 * 1000);
      let yesterdayMonth = yesterday.getMonth() + 1;
      let yesterdayDay = yesterday.getDate();

      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(DateFormatFactory, DateFormatFactory.createAutoRelativeTimeFormat))(ArgumentMatchers.any)
        .afterReturn(new Intl.RelativeTimeFormat(I18n.System.getSystemLocale(), {
          numeric: 'auto'
        }));
      when(mocker.mockFunc(DateUtil, DateUtil.getWeek))(ArgumentMatchers.any).afterReturn('1');

      let messageItem = {
        date: '',
        week: {}
      } as mmsListType
      DateUtil.convertTimeStampToDate(messageItem, timeStampFromDb, yearOfSms, yesterdayMonth + 1, yesterdayDay + 2);
      expect(messageItem.week).assertEqual('1');

      mocker.clear(DateFormatFactory);
      mocker.clear(DateUtil);
    })

    it('DateUtilTest_getMonthDayDate', 0, () => {
      const time: string = DateUtil.getMonthDayDate(1699010047) //1970,1,20
      expect(time).assertEqual('1月20日星期二')
    })

    it('DateUtilTest_getWeek', 0, () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('is24HourTime')
        .afterReturn(true);
      when(mocker.mockFunc(DateFormatFactory, DateFormatFactory.createDateFormatWeek))(ArgumentMatchers.any)
        .afterReturn(new Intl.DateTimeFormat(I18n.System.getSystemLocale(), {
          hour12: false,
          hour: 'numeric',
          minute: '2-digit'
        }));
      const time: string = DateUtil.getWeek(1699010047) //1970,1,20
      mocker.clear(GlobalContext.getContext());
      mocker.clear(DateFormatFactory);
      expect(time.length > 0).assertTrue()
    })

    it('DateUtilTest_convertTimeStampDate', 0, () => {
      const time: string = DateUtil.getMonthDayDate(1699010047) //1970,1,20
      expect(time).assertEqual('1月20日星期二')
    })

    it('DateUtilTest_convertTimeStampTime1', 0, () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('is24HourTime')
        .afterReturn(true);
      when(mocker.mockFunc(DateFormatFactory, DateFormatFactory.createIs24HourTimeFormat))(ArgumentMatchers.any)
        .afterReturn(new Intl.DateTimeFormat(I18n.System.getSystemLocale(), {
          hour12: false,
          hour: 'numeric',
          minute: '2-digit'
        }));
      const time: string = DateUtil.convertTimeStampTime(1699010047) //2023-11-03 19:14:07
      expect(time).assertEqual('23:56');
      mocker.clear(GlobalContext.getContext());
      mocker.clear(DateFormatFactory);
    })

    it('DateUtilTest_convertTimeStampTime2', 0, () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('is24HourTime')
        .afterReturn(false);
      when(mocker.mockFunc(DateFormatFactory, DateFormatFactory.createIs24HourTimeFormat))(ArgumentMatchers.any)
        .afterReturn(new Intl.DateTimeFormat(I18n.System.getSystemLocale(), {
          hour12: false,
          hour: 'numeric',
          minute: '2-digit'
        }));
      const time: string = DateUtil.convertTimeStampTime(1699010047) //2023-11-03 19:14:07
      expect(time).assertEqual('下午11:56');
      mocker.clear(GlobalContext.getContext());
      mocker.clear(DateFormatFactory);
    })

    it('DateUtilTest_fullDate', 0, () => {
      let mmsItem: mmsListType = new mmsListType();
      mmsItem.timeMillisecond = '1699010047';
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(DateUtil, DateUtil.convertTimeStampTime))(ArgumentMatchers.any)
        .afterReturn('');
      DateUtil.fullDate(mmsItem)
      expect(mmsItem.timeOfSmsParams.length).assertEqual(0);
      mocker.clear(DateUtil);
    })

    it('DateUtilTest_fullDate_params_true', 0, () => {
      let mmsItem: mmsListType = new mmsListType();
      mmsItem.timeMillisecond = '1699010047';
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(DateUtil, DateUtil.convertTimeStampTime))(ArgumentMatchers.any)
        .afterReturn('');
      DateUtil.fullDate(mmsItem, true)
      expect(mmsItem.timeOfSmsParams.length).assertEqual(2);
      mocker.clear(DateUtil);
    })

    it('DateUtilTest_fullDates', 0, () => {
      let mmsItem: messageType = new messageType();
      mmsItem.timeMillisecond = '1725971246';
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(DateUtil, DateUtil.convertTimeStampTime))(ArgumentMatchers.any)
        .afterReturn('');
      DateUtil.fullDates(mmsItem, undefined)
      expect(mmsItem.timeOfSmsParams.length).assertEqual(0);
      mocker.clear(DateUtil);
    })

    it('DateUtilTest_fullDates_params_true', 0, () => {
      let mmsItem: messageType = new messageType();
      mmsItem.timeMillisecond = '1725971246';
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(DateUtil, DateUtil.convertTimeStampTime))(ArgumentMatchers.any)
        .afterReturn('');
      DateUtil.fullDates(mmsItem, true)
      expect(mmsItem.timeOfSmsParams.length).assertEqual(2);
      mocker.clear(DateUtil);
    })

    it('DateUtilTest_fullDates_params_true_hoursOfSms_14', 0, () => {
      let mmsItem: messageType = new messageType();
      mmsItem.timeMillisecond = '1725977246';
      mmsItem.startTime = '1750063326041';
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(DateUtil, DateUtil.convertTimeStampTime))(ArgumentMatchers.any)
        .afterReturn('');
      DateUtil.fullDates(mmsItem, true)
      expect(mmsItem.timeOfSmsParams.length).assertEqual(2);
      mocker.clear(DateUtil);
    })

    it('DateUtilTest_convertDateFormatForItem', 0, () => {
      let mocker:MockKit = new MockKit();
      when(mocker.mockFunc(DateUtil, DateUtil.convertTimeStampToTime))(ArgumentMatchers.any)
        .afterReturn('');
      when(mocker.mockFunc(DateUtil, DateUtil.getMsmItemTime))(ArgumentMatchers.any)
        .afterReturn('');
      let messageItem = {
        timeMillisecond: '1699010047'
      } as LooseObject;
      DateUtil.convertDateFormatForItem(messageItem)
      expect(messageItem.itemTime).assertEqual('');
      mocker.clear(DateUtil);
    })

    it('DateUtilTest_isDateDiffOneHour_false', 0, () => {
      let mmsItem: messageType = new messageType();
      mmsItem.timeMillisecond = 1699010047;
      let isDateDiffOneHour: boolean = DateUtil.isDateDiffOneHour(mmsItem);
      expect(isDateDiffOneHour).assertEqual(false);
    })

    it('DateUtilTest_isDateDiffOneHour_true', 0, () => {
      let mmsItem: messageType = new messageType();
      mmsItem.timeMillisecond = new Date().getTime() - 10000;
      let isDateDiffOneHour: boolean = DateUtil.isDateDiffOneHour(mmsItem);
      expect(isDateDiffOneHour).assertEqual(true);
    })

    it('DateUtilTest_isDateDiffOneHour_null', 0, () => {
      let mmsItem: messageType = new messageType();
      mmsItem.timeMillisecond = undefined;
      let result: number = 1;
      let isDateDiffOneHour: boolean = false;
      try {
        isDateDiffOneHour = DateUtil.isDateDiffOneHour(mmsItem);
      } catch (err) {
        HiLog.e(TAG, `isDateDiffOneHour error :${err?.message}`);
        result = 0;
      }
      expect(result).assertEqual(1);
      expect(isDateDiffOneHour).assertEqual(false);
    })

    it('DateUtilTest_formatMilliseconds', 0, () => {
      let result = DateUtil.formatMilliseconds('4560');
      expect(result).assertEqual('00:04');

      let result1 = DateUtil.formatMilliseconds('456250');
      expect(result1).assertEqual('07:36');

      let result2 = DateUtil.formatMilliseconds('700000');
      expect(result2).assertEqual('11:40');

      let result3 = DateUtil.formatMilliseconds('723000');
      expect(result3).assertEqual('12:03');
    })

    it('DateUtilTest_getDuration', 0, () => {
      let result = DateUtil.getDuration('');
      expect(result).assertEqual(0);

      let result1 = DateUtil.getDuration('3:02');
      expect(result1).assertEqual(182);
    })

    it('DateUtilTest_formatMilliseconds_letter', 0, () => {
      let result = DateUtil.formatMilliseconds('ry');
      expect(result).assertEqual('00:00');

      result = DateUtil.formatMilliseconds('abc');
      expect(result).assertEqual('00:00');

      result = DateUtil.formatMilliseconds('smil');
      expect(result).assertEqual('00:00');
    })

    it('DateUtilTest_isNotSameDay', 0, () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(DateUtil, DateUtil.compareCalendarDates))(ArgumentMatchers.any)
        .afterReturn(true);
      let res: boolean = DateUtil.isNotSameDay(1725971246, 1725971247);
      expect(res).assertFalse();
      mocker.clear(DateUtil);
    })

    it('DateUtilTest_isNotSameDay1', 0, () => {
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(DateUtil, DateUtil.compareCalendarDates))(ArgumentMatchers.any)
        .afterReturn(false);
      let res: boolean = DateUtil.isNotSameDay(1725971246, 1725971247);
      expect(res).assertTrue();
      mocker.clear(DateUtil);
    })

    it('DateUtilTest_isDataValid', 0, () => {
      let res: boolean = DateUtil.isDataValid(new Date());
      expect(res).assertTrue();
    })

    it('DateUtilTest_updateIntlLocalAndFormatters', 0, () => {
      let intlLocale: Intl.Locale = new Intl.Locale();
      DateUtil.intlLocale = new Intl.Locale();
      intlLocale.baseName = 'test_error';
      DateUtil.intlLocale.baseName = 'DateUtil_test_error';
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(DateFormatFactory, DateFormatFactory.updateDateFactoryFormatters))(ArgumentMatchers.any)
        .afterReturnNothing();
      DateUtil.updateIntlLocalAndFormatters(intlLocale);
      expect(DateUtil).not().assertUndefined();
      mocker.clear(DateFormatFactory);
    })

    it('DateUtilTest_getTime_today', 0, () => {
      let now = new Date();
      let favoriteProps: number = now.getTime();
      try {
        let res: string = dateUtil.getTime(favoriteProps);
        expect(res).assertEqual('');
      } catch (e) {
      }
    })

    it('DateUtilTest_getTime_yesterday', 0, () => {
      let now = new Date();
      let favoriteProps: number = now.getTime() - 86400001;
      try {
        let res: string = dateUtil.getTime(favoriteProps);
        expect(res).assertEqual('');
      } catch (e) {
      }
    })

    it('DateUtilTest_getTime_yesterday_else_if', 0, () => {
      let now = new Date();
      let favoriteProps: number = now.getTime() - 86400000 * 2;
      let res: string = dateUtil.getTime(favoriteProps);
      expect(res.length > 0).assertTrue();
    })

    it('DateUtilTest_getTime_yesterday_else', 0, () => {
      let now = new Date();
      let favoriteProps: number = now.getTime() - 86400000 * 366;
      let res: string = dateUtil.getTime(favoriteProps);
      expect(res.length > 0).assertTrue();
    })

    it('DateUtilTest_getAudioAccessibilityText', 0, () => {
      try {
        let res: string = dateUtil.getAudioAccessibilityText('12:37:43');
        expect(res).assertEqual('');
      } catch (e) {
      }
    })

    it('DateUtilTest_getAudioAccessibilityText1', 0, () => {
      try {
        let res: string = dateUtil.getAudioAccessibilityText('12');
        expect(res).assertEqual('');
      } catch (e) {
      }
    })

    it('DateUtilTest_onlyUpdateSmsItemTime', 0, () => {
      let now = new Date();
      let messageItem = {
        date: '',
        week: {},
        timeMillisecond: now.getTime()
      } as mmsListType;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(DateFormatFactory, DateFormatFactory.createAutoRelativeTimeFormat))(ArgumentMatchers.any)
        .afterReturn(new Intl.RelativeTimeFormat(I18n.System.getSystemLocale(), {
          numeric: 'auto'
        }));
      DateUtil.onlyUpdateSmsItemTime(messageItem, now.getFullYear(),
        now.getMonth() + 1, now.getDate(), now.getMonth() + 1, now.getDate(), 1800);
      expect(DateUtil).not().assertUndefined();
      mocker.clear(DateFormatFactory);
    })

    it('DateUtilTest_onlyUpdateSmsItemTime_yesterday', 0, () => {
      let now = new Date();
      let messageItem = {
        date: '',
        week: {},
        timeMillisecond: now.getTime() - 24 * 60 * 60 * 1000
      } as mmsListType;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(DateFormatFactory, DateFormatFactory.createAutoRelativeTimeFormat))(ArgumentMatchers.any)
        .afterReturn(new Intl.RelativeTimeFormat(I18n.System.getSystemLocale(), {
          numeric: 'auto'
        }));
      let sms = new Date(messageItem.timeMillisecond);
      DateUtil.onlyUpdateSmsItemTime(messageItem, now.getFullYear(),
        now.getMonth() + 1, now.getDate(), sms.getMonth() + 1, sms.getDate(), 80001);
      expect(DateUtil).not().assertUndefined();
      mocker.clear(DateFormatFactory);
    })

    it('DateUtilTest_onlyUpdateSmsItemTime_yearOfNow_equal_yearOfSms_only', 0, () => {
      let now = new Date();
      let messageItem = {
        date: '',
        week: {},
        timeMillisecond: now.getTime() - 24 * 60 * 60 * 1000
      } as mmsListType;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(DateFormatFactory, DateFormatFactory.createAutoRelativeTimeFormat))(ArgumentMatchers.any)
        .afterReturn(new Intl.RelativeTimeFormat(I18n.System.getSystemLocale(), {
          numeric: 'auto'
        }));
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('is24HourTime')
        .afterReturn(true);
      let sms = new Date(messageItem.timeMillisecond);
      DateUtil.onlyUpdateSmsItemTime(messageItem, now.getFullYear(),
        now.getMonth() + 1, now.getDate(), sms.getMonth() + 3, sms.getDate(), 3600007);
      expect(DateUtil).not().assertUndefined();
      mocker.clear(DateFormatFactory);
      mocker.clear(GlobalContext.getContext());
    })

    it('DateUtilTest_onlyUpdateSmsItemTime_is24HourTime_false', 0, () => {
      let now = new Date();
      let messageItem = {
        date: '',
        week: {},
        timeMillisecond: now.getTime() - 24 * 60 * 60 * 1000
      } as mmsListType;
      let mocker: MockKit = new MockKit();
      when(mocker.mockFunc(DateFormatFactory, DateFormatFactory.createAutoRelativeTimeFormat))(ArgumentMatchers.any)
        .afterReturn(new Intl.RelativeTimeFormat(I18n.System.getSystemLocale(), {
          numeric: 'auto'
        }));
      when(mocker.mockFunc(GlobalContext.getContext(), GlobalContext.getContext().getObject))('is24HourTime')
        .afterReturn(false);
      let sms = new Date(messageItem.timeMillisecond);
      DateUtil.onlyUpdateSmsItemTime(messageItem, now.getFullYear() + 2,
        now.getMonth() + 1, now.getDate(), sms.getMonth() + 3, sms.getDate(), 3600007);
      expect(DateUtil).not().assertUndefined();
      mocker.clear(DateFormatFactory);
      mocker.clear(GlobalContext.getContext());
    })
  })
}
