/**
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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

/**
 * 首选项key常量类
 */
export default class PreferenceConstant {

  /**
   * 是否在用户关闭短信通知开关后已提醒过用户开启通知开关.
   */
  public static readonly IS_REMINDED_ENABLE_NOTIFICATION: string = 'is_reminded_enable_notification';
  /**
   * 是否在用户关闭短信通知开关后已提醒过用户开启通知开关-允许
   */
  public static readonly IS_REMINDED_ENABLE_NOTIFICATION_ALLOWED: string = '_allowed_';
  /**
   * 是否在用户关闭短信通知开关后已提醒过用户开启通知开关-不允许
   */
  public static readonly IS_REMINDED_ENABLE_NOTIFICATION_NOT_ALLOWED: string = '_notAllowed_';
}