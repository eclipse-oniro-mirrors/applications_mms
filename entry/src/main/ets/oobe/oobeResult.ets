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
import settings from '@ohos.settings';
import StaticSubscriberExtensionContext from '@ohos.application.StaticSubscriberExtensionContext';
import HiLog from '../utils/HiLog';
import { GlobalContext } from '../MainAbility/GlobalHelper';

const TAG = 'OobeResult';
const DEVICE_PROVISIONED: string = 'device_provisioned';

export default class OobeResult {
  private static mInstance: OobeResult | undefined = undefined;

  public static getInstance() {
    if (!OobeResult.mInstance) {
      OobeResult.mInstance = new OobeResult();
    }
    return OobeResult.mInstance;
  }

  public static release() {
    OobeResult.mInstance = undefined;
  }

  // get isOobe status
  public getGuideOobeStatue(context: Context): boolean {
    let mContext: Context = context as Context;
    const value: string = settings.getValueSync(mContext, DEVICE_PROVISIONED, '0');
    let oobeStr: boolean = this.getGuideOobeStatueResult(value);
    HiLog.i(TAG, 'oobeStr:' + JSON.stringify(oobeStr));
    return oobeStr;
  }

  // get isOobe status
  public getGuideOobeStatueFromUI(context: Context): boolean {
    if (context == null) {
      HiLog.e(TAG, 'getGuideOobeStatueFromUI context is null');
      context = GlobalContext.getContext().getObject('mmsStaticContext') as Context;
    }
    if (context == null) {
      HiLog.e(TAG, 'getGuideOobeStatueFromUI context is null again');
      return false;
    }
    let isOobe: boolean = false;
    try {
      const value: string = settings.getValueSync(context, DEVICE_PROVISIONED, '0');
      isOobe = this.getGuideOobeStatueResult(value);
    } catch (error) {
      HiLog.e(TAG, 'getGuideOobeStatueFromUI error : ' + JSON.stringify(error));
    }
    HiLog.i(TAG, 'isOobe:' + isOobe);
    return isOobe;
  }

  public getGuideOobeStatueResult(status: string): boolean {
    let isOobeStatus: boolean = true;
    if (status === '1') {
      isOobeStatus = false;
    } else if (status === '0' || status == undefined) {
      isOobeStatus = true;
    }
    return isOobeStatus;
  }

  public getMmsNoticeOobe(context: StaticSubscriberExtensionContext): boolean {
    return this.getGuideOobeStatue(context);
  }

  public getMmsNoticeOobeFromUI(context: Context): boolean {
    return this.getGuideOobeStatueFromUI(context);
  }
}