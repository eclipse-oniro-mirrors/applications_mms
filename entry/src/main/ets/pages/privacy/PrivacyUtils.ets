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
import { ConfigurationConstant } from '@kit.AbilityKit';
import HiLog from '../../utils/HiLog';
const TAG = 'PrivacyUtils';
const BLACK_MODE: string = '?bgmode=black';
const TITLE_ACETATE_BLACK: string = '&trsp=true';
const TITLE_ACETATE: string = '?trsp=true';
const LANGUAGE_LIST: PrivacyFileInfo[] = [
  {
    language: 'zh_Hans',
    fileName: 'zh-cn.htm'
  },
  {
    language: 'zh_Hant_TW',
    fileName: 'zh-tw.htm'
  },
  {
    language: 'zh_Hant',
    fileName: 'zh-hk.htm'
  },
  {
    language: 'bo_Tibt',
    fileName: 'bo-cn.htm'
  },
  {
    language: 'ug_Arab',
    fileName: 'ug-cn.htm'
  }
];
interface PrivacyFileInfo {
  language: string;
  fileName: string;
}
export class PrivacyUtils {
  /**
   * 获取本地隐私地址.
   *
   * @param currentMode 系统神色模式
   * @returns 隐私地址
   */
  public static getPrivacyLocalPath(currentMode: number): string {
    let language = getContext().resourceManager.getConfigurationSync().locale;
    HiLog.i(TAG, `getPrivacyLocalPath language : ${language}`);
    let privacyFileName = 'privacy-statement-en-us.htm';
    for (const item of LANGUAGE_LIST) {
      if (language.startsWith(item.language)) {
        privacyFileName = `privacy-statement-${item.fileName}`;
        break;
      }
    }
    const alwaysDarkMode = Number(currentMode) !== ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT;
    let localFname = alwaysDarkMode ? privacyFileName + BLACK_MODE +
        TITLE_ACETATE_BLACK : privacyFileName + TITLE_ACETATE;
    // 根据语言、深色模式匹配的隐私文件名，关键日志，不会频繁打印
    HiLog.w(TAG, `localFname: ${localFname}`);
    return localFname;
  }
}