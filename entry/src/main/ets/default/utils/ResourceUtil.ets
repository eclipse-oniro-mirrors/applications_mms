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
import ResMgr from '@ohos.resourceManager';

/**
 * Resource util
 */
export class ResourceUtil {
  private resMgr;

  /**
   * Initialize ResourceManager
   */
  async initResourceManager(): Promise<void> {
    if (!this.resMgr) {
      this.resMgr = await ResMgr.getResourceManager('com.ohos.mms');
    }
    return this.resMgr;
  }

  /**
   * Get string value from NormalResource instance
   *
   * @param resource - NormalResource instance
   */
  async getString(resource): Promise<string> {
    await this.initResourceManager();
    let result:string = await this.resMgr.getString(resource.id);
    return result;
  }

  /**
   * Get getPluralString value from NormalResource instance
   *
   * @param resource - NormalResource instance
   */
  async getStringReplace(resource, list): Promise<string> {
    await this.initResourceManager();
    let result:string = await this.resMgr.getString(resource.id);
    for (let i = 0; i < list.length; i++) {
      if (typeof (list[i]) == 'object') {
        let value = await this.resMgr.getString(list[i].id)
        result = result.replace('%s', value) || result.replace('%d', value);
      } else {
        result = result.replace('%s', list[i]) || result.replace('%d', list[i]);
      }
    }
    return result;
  }

  /**
   * Get direction value from NormalResource instance
   *
   * @param resource - NormalResource instance
   */
  async getConfiguration(): Promise<string> {
    await this.initResourceManager();
    return await this.resMgr.getConfiguration();
  }
}

let resourceUtil = new ResourceUtil();

export default resourceUtil as ResourceUtil;