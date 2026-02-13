/**
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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

import { BusinessError } from '@ohos.base';
import { calendarManager } from '@kit.CalendarKit';
import myCommon from '@ohos.app.ability.common';
import { abilityAccessCtrl, PermissionRequestResult, Permissions } from '@kit.AbilityKit';
import { Action } from '../../chatbot/utils/ChatbotEntitys';
import HiLog from '../../utils/HiLog';
import commonData from '../../data/commonData';

const TAG = 'ChatbotCalendarUtil';

export let calendarMgr: calendarManager.CalendarManager | null = null;

export async function onCreateCalendarMgr(action: Action, context: myCommon.UIAbilityContext) {
  const permissions: Permissions[] = ['ohos.permission.READ_CALENDAR', 'ohos.permission.WRITE_CALENDAR'];
  let atManager = abilityAccessCtrl.createAtManager();
  atManager.requestPermissionsFromUser(context, permissions).then((result: PermissionRequestResult) => {
    HiLog.e(TAG, `get Permission success, result: ${JSON.stringify(result)}`);
    calendarMgr = calendarManager.getCalendarManager(context);
    addEvent(action);
    return true;
  }).catch((error: BusinessError) => {
    HiLog.e(TAG, `get Permission error, error: ${JSON.stringify(error)}`);
    return false;
  })
}

function addEvent(action: Action): void {
  let startTime =
    action.calendarAction?.createCalendarEvent?.startTime ? action.calendarAction?.createCalendarEvent?.startTime : '';
  const startDate = new Date(startTime);
  let endtTime =
    action.calendarAction?.createCalendarEvent?.endTime ? action.calendarAction?.createCalendarEvent?.endTime : '';
  const endDate = new Date(endtTime);
  const event: calendarManager.Event = {
    type: calendarManager.EventType.NORMAL,
    title: action.calendarAction?.createCalendarEvent?.title,
    startTime: Math.floor(startDate.getTime()) - commonData.WEBVIEW_MENU_ID.TIME_ZONE_TIME,
    endTime: Math.floor(endDate.getTime()) - commonData.WEBVIEW_MENU_ID.TIME_ZONE_TIME,
    description: action.calendarAction?.createCalendarEvent?.description
  };
  calendarMgr?.editEvent(event).then((eventId: number): void => {
    HiLog.i(TAG, `create Event id = ${eventId}`);
  }).catch((err: BusinessError) => {
    HiLog.e(TAG, `Failed to create Event. Code: ${err.code}, message: ${err.message}`);
  });
}
