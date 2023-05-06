/**
 * Copyright (c) 2023 Huawei Device Co., Ltd.
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
import HiLog from "../utils/HiLog";

const TAG: string = "StringUtil";
const NON_ALPHABET_REG: RegExp = /[^\x00-\x80]/g;

class StringUtil {
  public countNonAlphabet(str: string): number {
    let match: RegExpMatchArray | null = str.match(NON_ALPHABET_REG);
    return (!match ? 0 : match.length);
  }

  public getOffsetForSession(page: number): number {
    let offset: number = 0;
    if (page < 3) {
      offset = (page - 1) * 50;
    } else {
      offset = (page - 2) * 100 + 50;
    }
    return offset;
  }

  public getLimitForSession(page: number): number {
    let limit: number = 0;
    if (page == 1) {
      limit = 50;
    } else {
      limit = 100;
    }
    return limit;
  }

  public getGroupIdsFromResultList(resultList): Array<number> {
    let groupIds: Array<number> = [];
    if (resultList != null) {
      for (let item of resultList) {
        if (item.groupId != null) {
          groupIds.push(item.groupId);
        }
      }
    }
    return groupIds;
  }
}

// Singleton
export default new StringUtil();