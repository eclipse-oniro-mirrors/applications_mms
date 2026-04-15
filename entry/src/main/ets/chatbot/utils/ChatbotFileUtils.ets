/**
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import HiLog from '../../utils/HiLog';
import { fileIo as fs } from '@kit.CoreFileKit';
import FileUtil from '../../utils/FileUtil';

const TAG = 'ChatbotFileUtils';

export const writeFileToPathSync = (context: Context, data: ArrayBuffer, dir: string, fileName: string) => {
  HiLog.i(TAG, 'writeFileToPathSync');
  if (!context || !data || !fileName) {
    HiLog.e(TAG, 'writeFileToPathSync: param is empty');
    return;
  }
  try {
    const sandboxPath = FileUtil.getSandboxPath(context);
    let fileDir = sandboxPath;
    if (dir) {
      fileDir = fileDir + OBLIQUE + dir;
    }
    const filePath = fileDir + OBLIQUE + fileName;
    if (!fs.accessSync(fileDir)) {
      const dirList = dir.split(OBLIQUE);
      let tempPath = sandboxPath;
      for (let i = 0; i < dirList.length; i++) {
        tempPath = tempPath + OBLIQUE + dirList[i];
        HiLog.i(TAG, 'writeFileToPathSync dirList index: ' + i);
        if (!fs.accessSync(tempPath)) {
          HiLog.i(TAG, 'writeFileToPathSync mkdir dirList index: ' + i);
          fs.mkdirSync(tempPath);
        }
      }
    }
    const file = fs.openSync(filePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
    fs.writeSync(file.fd, data);
    fs.closeSync(file);
  } catch (e) {
    HiLog.e(TAG, 'writeFileToPathSync error: ' + JSON.stringify(e));
  }
}

export const OBLIQUE = '/';

export const getNameFromPath = (path: string) => {
  if (path.lastIndexOf(OBLIQUE) === -1) {
    return '';
  }
  return path.slice(path.lastIndexOf(OBLIQUE) + 1);
}