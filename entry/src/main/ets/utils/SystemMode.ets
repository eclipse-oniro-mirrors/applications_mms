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
import { systemParameterEnhance } from '@kit.BasicServicesKit';
import HiLog from './HiLog';

const TAG: string = 'SystemMode';

export enum SystemModeType {
  NORMAL_MODE = 'normal',
  PENGLAI_MODE = 'penglai'
}

export class SystemMode {
  private static instance: SystemMode | undefined = undefined;
  public mode: string = SystemModeType.NORMAL_MODE;
  public isEnableRcsAbility: boolean = true; //增强信息能力
  public isEnableBroadcast: boolean = true; //语音播报
  /** 是否显示全部附件区功能, 否则在蓬莱下只显示位置和联系人 */
  public isEnableMessage: boolean = true;
  public isEnableNlu: boolean = true; //NLU能力
  public isEnablePickerCamera: boolean = true; //拍照使用Picker
  public attachmentBottomHeight: number = 0; //附件区底部高度

  public static getInstance() {
    if (!SystemMode.instance) {
      SystemMode.instance = new SystemMode();
    }
    return SystemMode.instance;
  }

  public async getSystemMode() {
    try {
      let mode = await systemParameterEnhance.get('ohos.boot.minisys.mode');
      if (mode === SystemModeType.PENGLAI_MODE) {
        this.mode = mode;
        this.isEnableRcsAbility = false;
        this.isEnableBroadcast = false;
        this.isEnableMessage = false;
        this.isEnableNlu = false;
        this.isEnablePickerCamera = false;
        this.attachmentBottomHeight = 96;
      }
    } catch (err) {
      HiLog.e(TAG, 'getSystemMode is error: ' + err?.code);
    }
  }
}