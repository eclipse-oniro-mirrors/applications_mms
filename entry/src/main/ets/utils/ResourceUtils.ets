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
import HiLog from './HiLog';
import util from '@ohos.util';
import { BusinessError } from '@ohos.base';
import resmgr from '@ohos.resourceManager';
import myCommon from '@ohos.app.ability.common';
import { GlobalContext } from '../MainAbility/GlobalHelper';

const TAG = 'ResourceUtils';
const UNICODE: string = 'utf-8';

/**
 * Handle file data
 */
export default class ResourceUtils {

  /**
   * Copy file util
   *
   * @param srcPath copy from this path
   * @param dstPath copy to this path
   * @returns if copy success
   */
  static getStringSync(resource: Resource, context?: myCommon.Context): string {
    let mmsContext: Context = context ? context : GlobalContext.getContext().getObject('mmsContext') as myCommon.UIAbilityContext;
    try {
      return mmsContext.resourceManager.getStringSync(resource);
    } catch (error) {
      HiLog.i(TAG, 'getStringSync error: ' + JSON.stringify(error));
      return '';
    }
  }

  /**
   * Get the object of the specified JSON file
   *
   * @param resourceManager Explorer
   * @param fileName The file name in the rawfile directory
   * @returns File content in string format
   */
  public static getStringByFile(resourceManager: resmgr.ResourceManager, fileName: string): Promise<string> {
    return new Promise((resolve, reject) => {
      console.info(TAG, `getFileContent. fileName：${fileName}`);
      if (resourceManager === null || fileName === null) {
        console.error(TAG, `getFileContent failed. resourceManager or fileName is null. fileName:${fileName}`);
        return reject('param err');
      }
      try {
        resourceManager.getRawFileContent(fileName).then((value) => {
          let content = util.TextDecoder.create(UNICODE).decodeWithStream(value);
          resolve(content);
        }).catch((err: BusinessError) => {
          console.error(TAG, `getFileContent of ${fileName} failed. ${err?.code} ${err?.message}`);
          reject(err);
        });
      } catch (jsonError) {
        console.error(TAG, `JSON parse error:${jsonError?.code} ${jsonError?.message}`);
        reject(jsonError);
      }
    });
  }
}