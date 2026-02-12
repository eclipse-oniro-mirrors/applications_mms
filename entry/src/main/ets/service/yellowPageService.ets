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
import LooseObject from '../data/LooseObject';
import { GlobalContext } from '../MainAbility/GlobalHelper';
import common from '../data/commonData';
import YellowPageModel from '../model/yellowPageModel';
import { WorkerWrapper } from '../workers/base/WorkerWrapper';
import { ValuesBucket } from '@ohos.data.ValuesBucket';
import HiLog from '../utils/HiLog';
import { resType } from './MmsSearchService';

interface YellowPageServiceParamType {
  valueBucket: ValuesBucket,
  context: Context
  actionData: LooseObject
}

const TAG: string = 'YellowPageService';

export default class YellowPageService {
  private static instance: YellowPageService;
  private yellowPageModel: YellowPageModel = new YellowPageModel();

  public static getInstance(): YellowPageService {
    if (YellowPageService.instance == null) {
      YellowPageService.instance = new YellowPageService();
    }
    return YellowPageService.instance;
  }

  public static getTestInstance(): YellowPageService {
    return new YellowPageService();
  }

  public async queryYellowPageListInfoByCondition(actionData: LooseObject, callback: Function,
    context: Context): Promise<void> {
    if (GlobalContext.getContext().getObject('DataWorker') != null) {
      (GlobalContext.getContext()
        .getObject('DataWorker') as WorkerWrapper)
        .sendRequest(common.RUN_IN_WORKER_METHOD.queryYellowPageListInfoByCondition,
        {
          actionData: actionData,
          context: context
        } as YellowPageServiceParamType, (res: LooseObject) => {
          callback(res);
        });
    } else {
      this.yellowPageModel.queryYellowPageListInfoByCondition(actionData, callback, context);
    }
  }

  public async judgeYellowPageByTelephone(telephone: string | undefined | LooseObject,
    context: Context): Promise<LooseObject> {
    let actionData: LooseObject = {};
    actionData.telephone = telephone;
    let res = await YellowPageService.getInstance().queryYellowPageInfoByCondition(actionData, context);
    if (res?.code == common.int.SUCCESS && res?.abilityResult?.length !== 0) {
      return {
        name: res.abilityResult[0].name,
        photo: res.abilityResult[0].photo,
        yellowPageId: res.abilityResult[0].id
      };
    } else {
      return {name: '', photo: '', yellowPageId: '', hasYellowPageIcon: ''};
    }
  }

  public async judgeNewPageHasYellowPageExist(param: LooseObject, context: Context): Promise<LooseObject> {
    let actionData: LooseObject = {};
    actionData.telephone = param.telephone;
    let res = await YellowPageService.getInstance().queryYellowPageInfoByCondition(actionData, context);
    if (res?.code == common.int.SUCCESS && res?.abilityResult?.length !== 0) {
      return {
        name: res.abilityResult[0].name,
        photo: res.abilityResult[0].photo != '' ? res.abilityResult[0].photo : param.icon,
        yellowPageId: res.abilityResult[0].id
      };
    } else {
      return {name: param.contactName, photo: param.headImage, yellowPageId: '', hasYellowPageIcon: ''};
    }
  }

  public async judgeYellowPageExist(param: LooseObject, context: Context): Promise<LooseObject> {
    let actionData: LooseObject = {};
    actionData.telephone = param.telephone;
    let res = await YellowPageService.getInstance().queryYellowPageInfoByCondition(actionData,
      context);
    if (res?.code == common.int.SUCCESS && res?.abilityResult?.length !== 0) {
      return {
        name: res.abilityResult[0].name,
        photo: res.abilityResult[0].photo != '' ? res.abilityResult[0].photo : param.icon,
        yellowPageId: res.abilityResult[0].id
      };
    } else {
      return {name: param.name, photo: param.icon, yellowPageId: '', hasYellowPageIcon: ''};
    }
  }

  public async judgeNoticeYellowPageExist(param: LooseObject,
    context: Context): Promise<LooseObject> {
    HiLog.i(TAG, 'judgeNoticeYellowPageExist')
    let actionData_: LooseObject = {};
    actionData_.telephone = param.message.title
    let res = await this.yellowPageModel.queryYellowPageInfoByCondition(actionData_, context);
    if (res?.code == common.int.SUCCESS && res?.abilityResult?.length !== 0) {
      return {
        name: res.abilityResult[0].name,
        photo: res.abilityResult[0].photo = res.abilityResult[0].photo,
        yellowPageId: res.abilityResult[0].id
      };
    } else {
      return {name: param.message.title, photo: '', yellowPageId: '', hasYellowPageIcon: ''};
    }
  }

  public async queryYellowPageInfoByCondition(actionData: LooseObject, context: Context): Promise<LooseObject | null> {
    if (GlobalContext.getContext().getObject('DataWorker') != null) {
      return await this.dealYellowPageInfoByConditionResult(actionData, context);
    } else {
      return this.yellowPageModel.queryYellowPageInfoByCondition(actionData, context);
    }
  }

  private async dealYellowPageInfoByConditionResult(actionData: LooseObject,
    mmsContext: Context):Promise<Object | null> {
    let res = await new Promise<Object | null>((resolve) => {
      (GlobalContext.getContext().getObject('DataWorker') as WorkerWrapper)
        .sendRequest(common.RUN_IN_WORKER_METHOD.queryYellowPageInfoByCondition, {
          actionData: actionData,
          context: mmsContext
        } as YellowPageServiceParamType, (res?: Object) => {
          if (res == null) {
            HiLog.e(TAG, 'dealYellowPageInfoByConditionResult returns null')
            resolve(null);
          } else {
            resolve(res);
          }
        });
    });
    return res;
  }

  public async hasYellowPageInfo(telephone: string, context: Context): Promise<boolean> {
    let actionData: LooseObject = {};
    let telephones: string[] = [];
    telephones[0] = telephone;
    actionData.telephones = telephones;
    let hasYellowPage = false;
    let res = await new Promise<boolean>((resolve) => {
      YellowPageService.getInstance().queryYellowPageListInfoByCondition(actionData, (res: resType) => {
        if (res.code == common.int.FAILURE || res.abilityResult.length == 0) {
          HiLog.i(TAG, 'hasYellowPageInfo, no YellowPage');
          hasYellowPage = false;
          resolve(hasYellowPage);
        } else {
          HiLog.i(TAG, 'hasYellowPageInfo, has YellowPage');
          hasYellowPage = true;
          resolve(hasYellowPage);
        }
      }, context);
    });
    return res;
  }
}