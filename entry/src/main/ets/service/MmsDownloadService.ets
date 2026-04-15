/**
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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

import MmsDownloadModel from '../model/MmsDownloadModel';
import { mmsInfo } from '../utils/TypesUtils';
import commonData from '../data/commonData';
import HiLog from '../utils//HiLog';
import LooseObject from '../data/LooseObject';

const TAG: string = 'MmsDownloadService';

export default class MmsDownloadService {
  private static instance: MmsDownloadService;
  private mmsDownloadModel: MmsDownloadModel = new MmsDownloadModel();

  public static getInstance(): MmsDownloadService {
    if (MmsDownloadService.instance == null) {
      MmsDownloadService.instance = new MmsDownloadService();
    }
    return MmsDownloadService.instance;
  }

  public async queryUnDownloadMms(context: Context): Promise<mmsInfo[]> {
    let list: LooseObject[] = [];
    await this.mmsDownloadModel.queryUnDownloadMms(context).then((res) => {
      if (res.code == commonData.int.SUCCESS && res.abilityResult && res.abilityResult.length > 0) {
        HiLog.i(TAG, 'queryUnDownloadMms success');
        list = res.abilityResult;
        return list;
      } else {
        HiLog.i(TAG, 'queryUnDownloadMms failed');
        return list;
      }
    });
    return list as mmsInfo[];
  }
}