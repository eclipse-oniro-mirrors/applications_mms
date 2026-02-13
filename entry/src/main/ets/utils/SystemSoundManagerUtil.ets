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

import lazy SystemSoundManager from '@ohos.multimedia.systemSoundManager';
import lazy fs from '@ohos.file.fs';
import buffer from '@ohos.buffer';
import myCommon from '@ohos.app.ability.common';
import lazy configPolicy from '@ohos.configPolicy'
import HiLog from './HiLog';
import { BusinessError } from '@ohos.base';
import LooseObject from '../data/LooseObject';

const TAG: string = 'SystemSoundManager';

class MmsRingtoneManager {
  type1: SystemSoundManager.SystemToneType = SystemSoundManager.SystemToneType.SYSTEM_TONE_TYPE_SIM_CARD_0;
  type2: SystemSoundManager.SystemToneType = SystemSoundManager.SystemToneType.SYSTEM_TONE_TYPE_SIM_CARD_1;
  path: string = ''

  public getRingtoneUri(): Promise<string>{
    return new Promise((resolve) => {
      configPolicy.getOneCfgFile('resource/media/audio/').then(path => {
        this.path = path;
        try {
          const defaultRington: string = path + 'ringtone_sms-notification.json';
          const stat: fs.Stat = fs.statSync(defaultRington);
          const arrayBuffer: ArrayBuffer = new ArrayBuffer(stat.size);
          const file: fs.File = fs.openSync(defaultRington, fs.OpenMode.READ_ONLY);
          const readLen: number = fs.readSync(file.fd, arrayBuffer)
          HiLog.i(TAG, 'read file data succeed:' + readLen);
          const buf: buffer.Buffer = buffer.from(arrayBuffer, 0, readLen);
          fs.closeSync(file);
          const jsonObj: LooseObject = JSON.parse(buf.toString());
          const defaultUri:string = jsonObj.path + '/' + jsonObj.preset_ringtone_sms;
          HiLog.i(TAG, `default rington uri: ${defaultUri}`);
          resolve(defaultUri);
        } catch (err) {
          const error: BusinessError = err as BusinessError;
          HiLog.e(TAG, 'error message: ' + error.message + ', error code: ' + error.code);
        }
      })
    })
  }

  public setSystemRingtoneUri(context: myCommon.UIAbilityContext, ringName: string, cardId: number): void {
    let systemSoundManagerInstance: SystemSoundManager.SystemSoundManager =
    SystemSoundManager.getSystemSoundManager();
    const oggUri = this.path + ringName + '.ogg';
    HiLog.i(TAG, 'rington uri: ${oggUri}');
    systemSoundManagerInstance.setSystemToneUri(context,oggUri,cardId === 0 ? this.type1 : this.type2).then(() => {
      HiLog.i(TAG, 'Promise returned to indicate a successful setting of the system tone uri.');
    }).catch ((err: BusinessError) => {
      HiLog.e(TAG, 'Failed to set the system tone uri ${err}');
    });
  }
}

export default MmsRingtoneManager