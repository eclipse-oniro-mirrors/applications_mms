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

import data_preferences from '@ohos.data.preferences';

const NAME: string = 'MmsStore';

export default class PreferenceUtil {

  static readonly SHOW_CONTACT_SWITCH = 'showContactSwitch';

  static readonly CLONE_SHOW_CONTACT_SWITCH = 'pref_key_avatar_display';

  static readonly AUTO_RETRIEVE_MMS_SWITCH = 'autoRetrieveMmsSwitch';

  static readonly CLONE_AUTO_RETRIEVE_MMS_SWITCH = 'autoReceiveMms';

  static readonly DELIVERY_REPORT_SWITCH = 'deliveryReportSwitch';

  static readonly CLONE_DELIVERY_REPORT_SWITCH = 'pref_key_delivery_reports';

  public static readonly INTEGRATION_SWITCH = 'integrationSwitch';

  public static readonly CLONE_INTEGRATION_SWITCH = 'pref_key_smart_archive_enable';

  public static readonly SIM_CENTER_ADDRESS_ONE_UPDATE = 'sim_center_address_0';

  public static readonly SIM_CENTER_ADDRESS_TWO_UPDATE = 'sim_center_address_1';

  public static readonly DELIVERY_REPORT_SWITCH_UPDATE = 'pref_key_delivery_reports';

  public static readonly SMART_ARCHIVE_AUTO_DELETE_UPDATE = 'pref_key_smart_archive_auto_delete';

  public static readonly MMS_RCS_SETTINGS_UPDATE = 'pref_key_mms_rcs_settings';

  public static readonly CLONE_BROADCAST_SWITCH = 'pref_key_mms_text_speak';

  public static readonly IS_OPEN_RCS = 'isOpenRcs';

  public static readonly IS_UI_OPEN_RCS = 'isUIOpenRcs';

  public static readonly OPEN_CHATBOT = 'isUIChatbotOpenRcs';

  public static readonly PREF_KEY_RISK_URL_CHECK = 'pref_key_risk_url_check';

  public static readonly PREF_KEY_AVATAR_DISPLAY = 'pref_key_avatar_display';

  public static readonly IS_OPEN_SMART = 'isOpenSmart';

  public static readonly IS_FIRST_START_SMART_MMSIN_PRE = 'isFirstStartSmartMMSinPre';

  public static readonly IM_ENABLE_DISPLAY_REPORT_UPDATE = 'pref_key_im_enable_display_report';

  public static readonly RCS_READ_FLAG = 'readFlag';

  public static readonly DATABASE_CLONE_START_TIME: string = '0';

  private static sInstance: PreferenceUtil;

  private mPreferences: data_preferences.Preferences| undefined = undefined;

  private mContext: Context| undefined = undefined;

  public static getInstance(): PreferenceUtil {
    if (PreferenceUtil.sInstance == undefined) {
      PreferenceUtil.sInstance = new PreferenceUtil();
    }
    return PreferenceUtil.sInstance;
  }

  public static getTestInstance(): PreferenceUtil {
    return new PreferenceUtil();
  }

  init(context: Context| undefined) {
    this.mContext = context;
    this.getPreferences().then((data) => {
      this.mPreferences = data;
    })
  }

  /**
   * getFromPreferences
   *
   * @return the value get from Preferences
   */
  public async getFromPreferences(key: string,
    defValue: data_preferences.ValueType):Promise<data_preferences.ValueType> {
    let preferences: data_preferences.Preferences| undefined = await this.getPreferences();
    if (preferences === undefined) {
      return defValue;
    }
    return await preferences.get(key, defValue);
  }

  /**
   * saveToPreferences
   *
   * @param key save to Preferences
   * @param value save to Preferences
   */
  public async saveToPreferences(key: string, value: data_preferences.ValueType) {
    let preferences: data_preferences.Preferences| undefined = await this.getPreferences();
    if (preferences === undefined || this.isEmpty(key)) {
      return;
    }
    preferences.putSync(key, value);
    await preferences.flush();
  }

  public isEmpty(str: string): boolean {
    return str === undefined || str === null || str.length === 0;
  }

  private async getPreferences(): Promise<data_preferences.Preferences| undefined> {
    if (this.mPreferences) {
      return this.mPreferences;
    }
    if (this.mContext === undefined) {
      return undefined;
    }
    try {
      return await data_preferences.getPreferences(this.mContext, NAME);
    } catch (error) {

    }
    return undefined;
  }
}