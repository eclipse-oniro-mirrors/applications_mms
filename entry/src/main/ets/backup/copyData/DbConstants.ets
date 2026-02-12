/**
 * Copyright (c) 2022-2023 Huawei Device Co., Ltd.
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

export default class DbConstants {
  // Clone database name
  static readonly ClONE_DATABASE_NAME = 'sms.db';
  // Upgrade database name
  public static readonly UPGRADE_DATABASE_NAME = 'mmssms.db';
  // Clone path for clone
  static readonly CLONE_DATABASE_PATH = '/data/storage/el2/backup/restore';
  /**
   * The table 'sms' name in old database
   */
  public static readonly PART_NAME = 'part';
  static readonly OLD_PART_NAME = 'part_tb';
  static readonly OLD_FILES_NAME = 'files_mms_tb';

  static readonly UPDATE_VERSION_NAME: string = '0.0.0.0';
  static readonly CLONE_VERSION_NAME: string = '99.99.99.999';
  public static readonly I_CLONE_VERSION_NAME: string = '99.99.99.997';
  public static readonly ARD_CLONE_VERSION_NAME: string = '99.99.99.998';

}