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
import fs from '@ohos.file.fs';

import IModel from '../IModel';
import zlib from '@ohos.zlib';
import common from '@ohos.app.ability.common';
import BackupExtensionContext from '@ohos.file.BackupExtensionContext';
import contextConstant from '@ohos.app.ability.contextConstant';
import lazy convertXml from '@ohos.convertxml';
import { BusinessError } from '@ohos.base';
import PreferenceUtil from '../../util/PreferenceUtil';
import HiLog from '../../../utils/HiLog';
import FileUtils from '../../../utils/FileUtils';
import FileUtil from '../../../utils/FileUtil';
import constants from '../../../data/commonData'
import mmsCommon from '../../../data/commonData';
import SharedPreferencesUtils from '../../../utils/SharedPreferencesUtils';
import LooseObject from '../../../data/LooseObject';
import settings from '@ohos.settings';
import commonData from '../../../data/commonData';
import { copyDbDataHelper } from '../../copyData/DbHelper';
import DbConstants from '../../copyData/DbConstants';
import PreferenceConstant from '../../../data/PreferenceConstant';

const TAG = 'MmsModel';

export interface AttributesObject {
  name: string,
  value: string
}

export interface CovertObject {
  _name: string,
  _text: string,
  _type: string,
  _attributes: AttributesObject,
  _declaration: Object,
  _elements: CovertObject[]
}

interface Option {
  recursion?: boolean
}

export default class MmsModel implements IModel {
  /**
   * Start migrate database file in upgrade1
   */
  async migrateDbFile(context: BackupExtensionContext) {
    HiLog.i(TAG, `migrateDbFile start`)
    const newPath: string = context.filesDir;
    if (context.area !== contextConstant.AreaMode.EL1) {
      context.area = contextConstant.AreaMode.EL1;
    }
    const partResPath = context.backupDir + '/restore/com.xxx.providers.telephony/de/app_parts/';
    try {
      const bol2 = fs.accessSync(partResPath);
      HiLog.i(TAG, `onRestore accessSync old Part: ${bol2}`)

      const bol1 = fs.accessSync(newPath);
      HiLog.i(TAG, `onRestore accessSync new: ${bol1}`);

      if (bol1 && bol2) {
        HiLog.i(TAG, 'onRestore result: success');
        let ret1 = FileUtils.copyDir(partResPath, newPath);
        HiLog.i(TAG, `ret1: ${ret1}`);
        if (ret1) {
          const videoPath = FileUtils.getFileInDir(newPath);
          if (videoPath.length > 0) {
            await this.generateVideoPixmap(context, newPath, videoPath);
          }
        }
      }
      context.area = contextConstant.AreaMode.EL2;
      let dbResPath = '/' + context.backupDir + 'restore/com.and' + 'roid.providers.telephony/ce/databases/mmssms.db';
      let dbDestPath: string = context.databaseDir;
      let resRet = fs.accessSync(dbResPath);
      let destRet = fs.accessSync(dbDestPath);
      HiLog.w(TAG, 'db source result: ' + resRet + ', dest result: ' + destRet);
      if (resRet && destRet) {
        dbDestPath = dbDestPath + '/rdb/';
        if (fs.accessSync(dbDestPath)) {
          fs.rmdirSync(dbDestPath);
        }
        if (!fs.accessSync(dbDestPath)) {
          fs.mkdirSync(dbDestPath);
        }
        dbDestPath = dbDestPath + DbConstants.UPGRADE_DATABASE_NAME;
        if (FileUtils.copyFile(dbResPath, dbDestPath)) {
          await copyDbDataHelper.handleSmilFile(context);
        } else {
          HiLog.e(TAG, 'upgrade copy old db failed');
        }
      }
    } catch (e) {
      HiLog.i(TAG, `onRestore accessSync: false ${JSON.stringify(e)}`);
    }
  }

  /**
   * Start migrate database file in clone
   */
  async migratePrefFile(context: common.ExtensionContext) {
    if (!context) {
      HiLog.e(TAG, 'context is undefined!')
      return
    }
    HiLog.i(TAG, 'migratePrefFile start.')
    let prefPath: string = context.preferencesDir + '/pref';
    await this.decompressMigrateFile(context, prefPath);
    HiLog.i(TAG, 'migratePrefFile end.');
  }

  private async decompressMigrateFile(context: common.ExtensionContext, prefPath: string): Promise<void> {
    HiLog.i(TAG, 'decompress MmsPref start.');
    try {
      let isPrefFileExist: boolean = fs.accessSync(prefPath);
      if (!isPrefFileExist) {
        HiLog.e(TAG, `The file decompression destination path does not exist`);
        return;
      }
      let compressedFilePath: string = prefPath + '/shared_pref.zip';
      let isCompressedFileExist: boolean = fs.accessSync(compressedFilePath);
      if (!isCompressedFileExist) {
        HiLog.e(TAG, `The decompressed source file dose not exist`);
        return;
      }
      let callBackData = await zlib.decompressFile(compressedFilePath, prefPath);
      if (callBackData == null) {
        HiLog.i(TAG, 'mmsPreferences file decompress succeed.');
        this.migrateMmsPref(context, prefPath, false);
      } else {
        HiLog.e(TAG, `mmsPreferences file decompress failed, error : ${JSON.stringify(callBackData)}`);
      }
    } catch (errData) {
      let code = (errData as BusinessError).code;
      let message = (errData as BusinessError).message;
      HiLog.e(TAG, `decompressFile failed. Error code is ${code}, message is ${message}`);
    }
    HiLog.i(TAG, 'decompress MmsPref end.');
    return;
  }

  public async migrateMmsPref(context: common.ExtensionContext, prefPath: string, isMigrate: boolean): Promise<void> {
    HiLog.i(TAG, 'migrate mmsPreferences start. isMigrate : ' + isMigrate);
    let mmsPrefFilePath: string = prefPath + '/com.xxx.mms_preferences.xml';
    let isMmsPrefFileExist: boolean = fs.accessSync(mmsPrefFilePath);
    if (!isMmsPrefFileExist) {
      HiLog.e(TAG, 'The mms_preferences.xml file dose not exist.');
      return;
    }

    let mmsFileContent: string = fs.readTextSync(mmsPrefFilePath);
    // The backup data contains garbled characters, causing XML parsing failure.
    let reg = new RegExp('pref_key_encrypt_key.*string');
    mmsFileContent = mmsFileContent.replace(reg, 'pref_key_encrypt_key"></string');
    if (PreferenceUtil.getInstance().isEmpty(mmsFileContent)) {
      HiLog.w(TAG, 'The mms_preferences.xml is an empty file.');
      return;
    }
    let convertOptions: convertXml.ConvertOptions = this.buildConvertOptions();
    try {
      PreferenceUtil.getInstance().init(context);
      let convertXmlObj = new convertXml.ConvertXML();
      let resObj: CovertObject = convertXmlObj.convertToJSObject(mmsFileContent, convertOptions) as CovertObject;
      let elementList = this.findElementsByTag(resObj._elements, 'map');
      let actionData: LooseObject = { 'isChangeIntegrationSwitch': false }
      for (let i = 0; i < elementList.length; i++){
        let item = elementList[i];
        if (!item || !item._name || !item._attributes) {
          continue;
        }
        if (isMigrate) {
          await this.migrateMmsPreNext(context, item, actionData);
        } else {
          await this.cloneMmsPreNext(context, item, actionData);
        }
      }
      let isChangeIntegrationSwitch: boolean = actionData.isChangeIntegrationSwitch;
      if (!isChangeIntegrationSwitch) {
        HiLog.i(TAG, `The user not set the notification integration.`);
        SharedPreferencesUtils.saveToPreferences(PreferenceUtil.INTEGRATION_SWITCH, '1');
      }
      // 短信通知提醒需要在克隆和升级时置空，避免未覆盖新机的值导致还继续使用新机的旧值。
      SharedPreferencesUtils.saveToPreferences(PreferenceConstant.IS_REMINDED_ENABLE_NOTIFICATION, '');
    } catch (err) {
      HiLog.e(TAG, `convert mmsPreferences xml failed, error: ${err}`);
    }
    HiLog.i(TAG, 'migrate mmsPreferences end.');
    try {
      fs.unlinkSync(mmsPrefFilePath);
    } catch (err) {
      HiLog.e(TAG, `remove xml failed, error: ${err}`);
    }
  }

  private buildConvertOptions(): convertXml.ConvertOptions {
    return {
      trim: false,
      declarationKey: '_declaration',
      instructionKey: '_instruction',
      attributesKey: '_attributes',
      textKey: '_text',
      cdataKey: '_cdata',
      doctypeKey: '_doctype',
      commentKey: '_comment',
      parentKey: '_parent',
      typeKey: '_type',
      nameKey: '_name',
      elementsKey: '_elements'
    };
  }

  public findElementsByTag(elements: CovertObject[], findTag: String): CovertObject[] {
    if (!elements) {
      HiLog.i(TAG, 'elements is empty, return emptyList');
      return new Array<CovertObject>();
    }
    for (let i = 0; i < elements.length; i++) {
      if (elements[i]._name === findTag) {
        return elements[i]._elements;
      }
    }
    HiLog.i(TAG, 'Can not find elements, return emptyList');
    return new Array<CovertObject>();
  }

  private getAutoRecMmsMapping(attributeValue: string): string{
    let result: string = '';
    switch (attributeValue){
      // 2 - 0
      case constants.AUTO_RETRIEVE_MMS.ALWAYS:
        result = constants.AUTO_RETRIEVE_MMS.OFF
        break;
      // 0 - 2
      case constants.AUTO_RETRIEVE_MMS.OFF:
        result = constants.AUTO_RETRIEVE_MMS.ALWAYS;
        break;
      default:
        result = attributeValue;
        break;
    }
    return result
  }

  public async cloneMmsPreNext(ctx: Context, item: CovertObject, actionData: LooseObject) {
    SharedPreferencesUtils.init(ctx);
    let isBoolean: boolean = item._name === 'boolean';
    let isInt: boolean = item._name === 'int';
    let attributeName: string = item._attributes.name;
    let attributeValue: string = item._attributes.value;
    if (isBoolean && attributeName == PreferenceUtil.CLONE_SHOW_CONTACT_SWITCH) {
      attributeValue = attributeValue === 'true' ? '1' : '0';
      HiLog.i(TAG, `attributeName is ${attributeName}, attributeValue is ${attributeValue}`);
      SharedPreferencesUtils.saveToPreferences(PreferenceUtil.SHOW_CONTACT_SWITCH, attributeValue);
    } else if (isInt && attributeName == PreferenceUtil.CLONE_DELIVERY_REPORT_SWITCH) {
      HiLog.i(TAG, `attributeName is ${attributeName}, attributeValue is ${attributeValue}`);
      SharedPreferencesUtils.saveToPreferences(PreferenceUtil.DELIVERY_REPORT_SWITCH, attributeValue);
    } else if (isBoolean && attributeName == PreferenceUtil.CLONE_INTEGRATION_SWITCH) {
      attributeValue = attributeValue === 'true' ? '1' : '0';
      HiLog.i(TAG, `attributeName is ${attributeName}, attributeValue is ${attributeValue}`);
      SharedPreferencesUtils.saveToPreferences(PreferenceUtil.INTEGRATION_SWITCH, attributeValue);
      actionData.isChangeIntegrationSwitch = true;
    } else {
      attributeValue = this.cloneMmsPreNextPart(ctx, isBoolean, attributeName, attributeValue);
    }
  }

  public cloneMmsPreNextPart(context: Context, isBoolean: boolean, attributeName: string,
    attributeValue: string) {
    return attributeValue;
  }

  public async migrateMmsPreNext(ctx: Context, item: CovertObject, actionData: LooseObject) {
    HiLog.i(TAG, `migrateMmsPreNext start`);
    SharedPreferencesUtils.init(ctx);
    let isBoolean: boolean = item._name === 'boolean';
    let isInt: boolean = item._name === 'int';
    let isString: boolean = item._name === 'string';
    let attributeName: string = item._attributes.name;
    let attributeValue: string = item._attributes.value;
    if (isString && attributeName == PreferenceUtil.SIM_CENTER_ADDRESS_ONE_UPDATE) {
      attributeValue = (item._elements)[0]._text;
      HiLog.i(TAG, `attributeName is ${attributeName}, attributeValue is ${attributeValue}`);
      SharedPreferencesUtils.saveToPreferences(mmsCommon.STR.KEY_OF_NEW_SIM_0_SMSC, attributeValue);
    } else if (isString && attributeName == PreferenceUtil.SIM_CENTER_ADDRESS_TWO_UPDATE) {
      attributeValue = (item._elements)[0]._text;
      HiLog.i(TAG, `attributeName is ${attributeName}, attributeValue is ${attributeValue}`);
      SharedPreferencesUtils.saveToPreferences(mmsCommon.STR.KEY_OF_NEW_SIM_1_SMSC, attributeValue);
    } else if (isInt && attributeName == PreferenceUtil.DELIVERY_REPORT_SWITCH_UPDATE) {
      HiLog.i(TAG, `attributeName is ${attributeName}, attributeValue is ${attributeValue}`);
      SharedPreferencesUtils.saveToPreferences(PreferenceUtil.DELIVERY_REPORT_SWITCH, attributeValue);
    } else if (isBoolean && attributeName == PreferenceUtil.MMS_RCS_SETTINGS_UPDATE) {
      HiLog.i(TAG, `attributeName is ${attributeName}, attributeValue is ${attributeValue}`);
      SharedPreferencesUtils.saveToPreferences(PreferenceUtil.IS_OPEN_RCS, attributeValue === 'true' ? true : false);
      SharedPreferencesUtils.saveToPreferences(PreferenceUtil.IS_UI_OPEN_RCS, attributeValue === 'true' ? true : false);
      SharedPreferencesUtils.saveToPreferences(PreferenceUtil.OPEN_CHATBOT, attributeValue === 'true' ? true : false);
    } else {
      attributeValue = this.migrateMmsPreNextPart(ctx, isBoolean, attributeName, attributeValue, actionData);
    }
  }

  private migrateMmsPreNextPart(context: Context, isBoolean: boolean, attributeName: string,
    attributeValue: string, actionData: LooseObject) {
    if (isBoolean && attributeName == PreferenceUtil.IM_ENABLE_DISPLAY_REPORT_UPDATE) {
      HiLog.i(TAG, `attributeName is ${attributeName}, attributeValue is ${attributeValue}`);
      SharedPreferencesUtils.saveToPreferences(PreferenceUtil.RCS_READ_FLAG, attributeValue === 'true' ? true : false);
    } else if (isBoolean && attributeName == PreferenceUtil.CLONE_INTEGRATION_SWITCH) {
      attributeValue = attributeValue === 'true' ? '1' : '0';
      HiLog.i(TAG, `attributeName is ${attributeName}, attributeValue is ${attributeValue}`);
      SharedPreferencesUtils.saveToPreferences(PreferenceUtil.INTEGRATION_SWITCH, attributeValue);
      actionData.isChangeIntegrationSwitch = true;
    } else if (isBoolean && attributeName == PreferenceUtil.PREF_KEY_AVATAR_DISPLAY) {
      HiLog.i(TAG, `attributeName is ${attributeName}, attributeValue is ${attributeValue}`);
      attributeValue = attributeValue === 'true' ? '1' : '0';
      SharedPreferencesUtils.saveToPreferences(PreferenceUtil.SHOW_CONTACT_SWITCH, attributeValue);
    }
    return attributeValue;
  }

  async generateVideoPixmap(context: Context, sourcePath: string, paths: string[]) {
    for (let i = 0; i < paths.length; i++) {
      let videoName = FileUtil.getFileName(paths[i]);
      let imagePath: string = sourcePath + '/IMG_' + videoName.replace('mp4', 'jpeg');
      if (!fs.accessSync(imagePath)) {
        HiLog.i(TAG, `first frame is not exist so need to generate`);
        await FileUtil.writeVideoFirstFrameImageToSandBoxSync(context, sourcePath, paths[i], videoName);
        HiLog.i(TAG, `first frame generate success`);
      }
    }
  }
}