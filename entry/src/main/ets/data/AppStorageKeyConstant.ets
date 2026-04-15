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

/**
 * AppStorageKeyConstant
 */
export default class AppStorageKeyConstant {
  /**
   * 是否点击状态栏触发了详情页回顶
   */
  public static readonly CONVERSATION_BACK_TO_UP = 'isConversationBackToUp';
  /**
   * 是否从桌面点击方式热启动进入短信
   */
  public static readonly IS_NEW_WANT_FROM_HOME = 'isNewWantFromHome';
  /**
   * 是否从桌面点击方式冷启动进入短信
   */
  public static readonly IS_START_FROM_HOME = 'isStartFromHome';
}