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
import Constant from '../data/Constant';
import LooseObject from '../data/LooseObject';
import HiLog from './HiLog';
import { MessageDetail } from './TypesUtils';
import myCommon from '@ohos.app.ability.common';
import ReceiveService from '../StaticSubscriber/ReceiveService';
import StringUtil from './StringUtil';
import TelephoneUtil from './TelephoneUtil';
import { Want } from '@kit.AbilityKit';
import { StaticSubscriberExtensionContext } from '@kit.BasicServicesKit';
import PatternControl from '../pages/PatternControl';
import YellowPageService from '../service/yellowPageService';
import { TelephoneTypeFlag } from '../utils/TypesUtils'
import settings from '@ohos.settings';
import commonData from '../data/commonData';
import call from '@ohos.telephony.call';
import ResourceUtils from './ResourceUtils';
import { i18n } from '@kit.LocalizationKit';

const TAG: string = 'BlockedUtil';

export interface SmsRequestParams {
  phoneNumber: string,
  slotId: number,
  flag: number,
  sendTime?: number,
  spName?: string,
  isVerificationCode?: boolean
}

class BlockedUtil {

  private patternControl: PatternControl = PatternControl.getInstance();

  checkBlockMms(actionData: LooseObject, flag: number, context: StaticSubscriberExtensionContext): void {
    HiLog.w(TAG, 'checkBlockMessage start');
    let want: Want = {
      bundleName: 'com.ohos.mms',
      abilityName: 'ServiceExtAbility',
      parameters: {
        'serviceEvent': Constant.BLOCKED_SERVICE_MMS_DETECT_EVENT,
        'data': actionData,
        'flag': flag
      }
    };
    context.startAbility(want);
    HiLog.w(TAG, 'checkBlockMessage end');
  }

  public async getFlag(telephone: string, context: Context): Promise<TelephoneTypeFlag> {
    HiLog.i(TAG, 'getFlag start');
    let flag: TelephoneTypeFlag = {
      telephoneFlag: Constant.BLOCKED_NOT_TO_CLOUD,
      telephoneType: Constant.TELEPHONE_TYPE_COMMON,
    };
    if (StringUtil.isEmpty(telephone)) {
      HiLog.e(TAG, 'getFlag telephone is null');
      return flag;
    }
    try {
      flag = await this.flagCase(telephone, context, flag);
    } catch (e) {
      HiLog.e(TAG, 'getFlag err');
    }
    return flag;
  }

  public async flagCase(telephone: string, context: Context, flag: TelephoneTypeFlag): Promise<TelephoneTypeFlag> {
    if (TelephoneUtil.judgeIsInfoMsg(telephone)) {
      HiLog.i(TAG, 'getFlag is SP mms, judgeIsInfoMsg is true');
      flag.telephoneFlag = Constant.BLOCKED_TO_CLOUD;
      flag.telephoneType = Constant.TELEPHONE_TYPE_NOTICE;
      if (await YellowPageService.getInstance().hasYellowPageInfo(telephone, context)) {
        HiLog.i(TAG, 'getFlag is yellowPage');
        flag.telephoneFlag = Constant.BLOCKED_NOT_TO_CLOUD;
        flag.telephoneType = Constant.TELEPHONE_TYPE_YELLOW_PAGE;
      }
    } else {
      let systemLanguage = i18n.System.getSystemLanguage();
      let formatPhoneNumber: string = telephone;
      // 阿拉伯语的数字不是阿拉伯数字
      if (systemLanguage.toLowerCase() == 'ar') {
        formatPhoneNumber = telephone;
      } else {
        formatPhoneNumber = TelephoneUtil.formatDisplayPhoneNumE164(telephone);
      }
      if (!StringUtil.isEmpty(formatPhoneNumber)) {
        HiLog.i(TAG, 'getFlag formatPhoneNumber not is null');
        telephone = formatPhoneNumber;
      }
      if (!TelephoneUtil.isDomesticTelephone(telephone)) {
        HiLog.i(TAG, 'getFlag is over sea');
        flag.telephoneFlag = Constant.BLOCKED_TO_CLOUD;
      } else {
        flag.telephoneType = Constant.TELEPHONE_TYPE_PERSONAL_NUMBER;
      }
    }
    return flag;
  }

  isBlockLooseObject(actionData: LooseObject | null): boolean {
    if (actionData == null) {
      HiLog.e(TAG, 'isBlockLooseObject actionData is null');
      return false;
    }
    if (actionData.isBlocked == Constant.BLOCK) {
      HiLog.i(TAG, 'isBlockLooseObject is Blocked');
      return true;
    }
    return false;
  }

  isNationalAntiFraud(context: Context): boolean {
    let nationalAntiFraud: string = '0';
    try {
      nationalAntiFraud = settings.getValueSync(context, Constant.BLOCKED_FRAUD_SETTINGS_SWITCH, '0');
    } catch (error) {
      HiLog.e(TAG, 'isNationalAntiFraud error:' + JSON.stringify(error));
    }
    let isNationalAntiFraud: boolean = false;
    if (nationalAntiFraud == commonData.bool.TRUE) {
      isNationalAntiFraud = true;
    }
    HiLog.i(TAG, 'isNationalAntiFraud : ' + isNationalAntiFraud);
    return isNationalAntiFraud;
  }

  /**
   * 全民反诈
   */
  isBestmindAntiFraud(context: Context): boolean {
    let bestMindAntiFraud: string = settings.getValueSync(context, Constant.BLOCKED_BEST_MIND_SETTINGS_SWITCH, '0');
    let isBestmindAntiFraud: boolean = false;
    if (bestMindAntiFraud == commonData.bool.TRUE) {
      isBestmindAntiFraud = true;
    }
    HiLog.i(TAG, 'isBestmindAntiFraud : ' + isBestmindAntiFraud);
    return isBestmindAntiFraud;
  }

  isNumberIdentity(context: Context): boolean {
    let numberIdentity: string = settings.getValueSync(context, Constant.BLOCKED_NUMBER_IDENTITY_SWITCH, '0');
    let isNumberIdentity: boolean = false;
    if (numberIdentity == commonData.bool.TRUE) {
      isNumberIdentity = true;
    }
    HiLog.i(TAG, 'isNumberIdentity : ' + isNumberIdentity);
    return isNumberIdentity;
  }

  isSpamSwitch(slotId: number, context: Context): boolean {
    let spamSwitch: string = '0';
    if (slotId == 0) {
      spamSwitch = settings.getValueSync(context, Constant.BLOCKED_INTELL_SPAM_SIM1_SWITCH, '0');
    } else {
      spamSwitch = settings.getValueSync(context, Constant.BLOCKED_INTELL_SPAM_SIM2_SWITCH, '0');
    }
    let isSpamSwitch: boolean = false;
    if (spamSwitch == commonData.bool.TRUE) {
      isSpamSwitch = true;
    }
    HiLog.i(TAG, 'isSpamSwitch : ' + isSpamSwitch);
    return isSpamSwitch;
  }

  public disconnectAbility(context: myCommon.ServiceExtensionContext, connectionId: number) {
    if (context == null) {
      HiLog.e(TAG, 'disconnectAbility context is null');
      return;
    }
    if (connectionId === -1) {
      HiLog.i(TAG, `no connected not needed disconnect`);
      return;
    }
    HiLog.w(TAG, `disconnectAbility connectionId : ` + connectionId);
    setTimeout(() => {
      context.disconnectServiceExtensionAbility(connectionId, (err, data) => {
        if (err.code === 0) {
          HiLog.i(TAG, `disconnectServiceExtensionAbility success connectionId : ` + connectionId);
        } else {
          HiLog.i(TAG, `disconnectServiceExtensionAbility error ${JSON.stringify(err)}`);
        }
      });
    }, 30000);
  }

  /**
   * Get number mark info.
   *
   * @param context The context of application.
   * @param phoneNumber The phone number.
   * @returns The number mark info.
   */
  public async getNumberMarkInfo(context: Context, phoneNumber: string): Promise<call.NumberMarkInfo> {
    let numberMarkInfo: call.NumberMarkInfo = {
      markType: 0,
      markSource: '0',
    };
    if (context == null || StringUtil.isEmpty(phoneNumber)) {
      HiLog.e(TAG, 'getNumberMarkInfo: invalid context or phoneNumber');
      return numberMarkInfo;
    }
    try {
      let beginTime = Date.now();
      // numberMarkInfo = await numberLookup.getNumberMarkInfo(context, phoneNumber);
      // HiLog.w(TAG, 'getNumberMarkInfo, markType: ' + numberMarkInfo.markType + ', markCount: ' +
      //   numberMarkInfo.markCount + ', markSource: ' + numberMarkInfo.markSource + ', isCloud: ' +
      //   numberMarkInfo.isCloud + ', time consume: ' + (Date.now() - beginTime) + 'ms');
      return numberMarkInfo;
    } catch (error) {
      HiLog.e(TAG, `getNumberMarkInfo failed, error : ` + JSON.stringify(error));
    }
    return numberMarkInfo;
  }

  public dealBlockedFraudName(telephones: string[], sessionLists: LooseObject[], context: Context):
    Promise<Array<LooseObject>> {
    return new Promise((resolve, reject) => {
      if (telephones.length === 0) {
        HiLog.w(TAG, 'dealBlockedFraudName, has no telephones');
        resolve(sessionLists);
        return;
      }
      resolve(this.buildFraudName(sessionLists, context));
    });
  }

  public buildFraudName(sessionLists: LooseObject[], context: Context) {
    HiLog.w(TAG, 'buildFraudName');
    //把会话内容设置为疑似诈骗
    let isNationalAntiFraud: boolean = this.isNationalAntiFraud(context);
    let isBestMindAntiFraud: boolean = this.isBestmindAntiFraud(context);
    for (let session of sessionLists) {
      if (session.blockedType == Constant.SESSION_BLOCKED_FRAUD && (isNationalAntiFraud || isBestMindAntiFraud)) {
        HiLog.i(TAG, `isNationalAntiFraud: ${isNationalAntiFraud}, isBestMindAntiFraud: ${isBestMindAntiFraud}`);
        session.name = ResourceUtils.getStringSync($r('app.string.fraud_session'), context);
      }
    }
    return sessionLists;
  }
}

// Singleton
export default new BlockedUtil();