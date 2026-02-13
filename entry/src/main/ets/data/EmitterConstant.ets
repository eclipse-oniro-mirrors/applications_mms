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

export default class EmitterConstant {
  public static readonly EVENT_FAVORITE: number = 99;
  public static readonly EVENT_SIM_STATE_CHANGE: number = 1;
  public static readonly EVENT_SLOTID_CHANGE: number = 2;
  public static readonly EVENT_CHANGE_NEW_INPUT_STATUS: number = 3;
  public static readonly EVENT_CHANGE_RCS_STATUS: number = 66;
  public static readonly EVENT_CHANGE_RCS_SETTING_STATUS: number = 67;
  public static readonly EVENT_CHANGE_SUBID_STATUS: number = 70;
  public static readonly EVENT_CHANGE_ALL_ACTIVE: number = 74
  public static readonly EVENT_INTEGRATION_STATUS: number = 10;
  public static readonly EVENT_SHOW_CONTACT_STATUS: number = 11;
  public static readonly EVENT_IS_INPUT_STATUS: number = 12;
  public static readonly EVENT_RELOAD_SETTING_SMART_MMS_STATUS: number = 88;
  public static readonly EVENT_CONVERSATION_LIST_SELECT_STATUES_CHANGE: number = 101;
  public static readonly EVENT_CONVERSATION_LIST_ACCESSIBILITY_TEXT_CHANGE: number = 102;
  public static readonly EVENT_SYS_STATUS_ANGLE: number = 14;
  public static readonly EVENT_CLICK_STATUSBAR: string = 'EVENT_CLICK_STATUSBAR';
  public static readonly EVENT_ON_SHOW_INDEX: string = 'EVENT_ON_SHOW_INDEX';
  public static readonly EVENT_CHECK_BOX_CHANGED: string = 'EVENT_CHECK_BOX_CHANGED';
  /**
   * Constant value on the Conversation.
   */
  public static readonly EVENT_RECEIVE_ADD_CONTACT: number = 68;
  public static readonly EVENT_RECEIVE_IN_CONTACT: number = 69;
  public static readonly EVENT_IN_BLOCKED_LIST: number = 71;
  public static readonly EVENT_IN_BLOCKED_NUM_CHANGE: number = 72;
  public static readonly EVENT_CHANGE_RCS_ACCEPT_FAIL: number = 683;
  public static readonly EVENT_BLACK_LIST_REFRESH: number = 684;
  public static readonly EVENT_BLACK_PAGE_REFRESH: number = 685;
  public static readonly EVENT_CHANGE_MESSAGE_STATUS: number = 73;
  public static readonly EVENT_CONVERSION_IS_SELECT: number = 75;
  public static readonly EVENT_CHANGE_BUBBLE_MODE: number = 100;

  public static readonly EVENT_SWIPE_ACTION_CLOSE: number = 686;
}