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
import { describe, it, expect, MockKit, when, beforeEach, afterEach } from '@ohos/hypium';
import common from '@ohos.app.ability.common';
import MmsModel, { AttributesObject, CovertObject } from '../../../../main/ets/backup/model/mms/MmsModel';
import { DTGlobalContext } from '../../testability/TestAbility';
import BackupExtensionContext from '@ohos.file.BackupExtensionContext';
import HiLog from '../../../../main/ets/utils/HiLog';
import SharedPreferencesUtils from '../../../../main/ets/utils/SharedPreferencesUtils';
import FileUtil from '../../../../main/ets/utils/FileUtil';
import LooseObject from '../../../../main/ets/data/LooseObject';
import PreferenceUtil from '../../../../main/ets/backup/util/PreferenceUtil';

export default function MmsModelTest() {
  let mmsModel = new MmsModel();
  let actionData: LooseObject = {};
  describe('MmsModelTest', () => {

    const TAG = 'MmsModel';
    let mocker: MockKit;

    beforeEach(() => {
      mocker = new MockKit();
      mocker.mockFunc(HiLog, HiLog.i);
    })

    afterEach(() => {
      mocker.clear(HiLog);
    })

    it('mmsModelTest_migrateDbFile_if1', 0, async () => {

      let context = DTGlobalContext.getContext().getObject('mmsContext') as BackupExtensionContext;
      context.area = 1;

      await mmsModel.migrateDbFile(context);

      mocker.verify('i', [TAG, 'destPath : ' + context.filesDir]);
    })

    it('mmsModelTest_migrateDbFile_noIf1', 0, async () => {

      let context = DTGlobalContext.getContext().getObject('mmsContext') as BackupExtensionContext;
      context.area = 0;

      await mmsModel.migrateDbFile(context);

      mocker.verify('i', [TAG, 'destPath : ' + context.filesDir]);

    })

    it('mmsModelTest_migratePrefFile', 0, async () => {

      let context = DTGlobalContext.getContext().getObject('mmsContext') as common.ExtensionContext;

      await mmsModel.migratePrefFile(context);

      mocker.verify('i', [TAG, 'migratePrefFile end.']);

    })

    it('mmsModelTest_findElementsByTag_if2', 0, () => {
      let elements: CovertObject[] = [{
        _name: 'name',
        _elements: [{}]
      } as CovertObject];

      let result: CovertObject[] = mmsModel.findElementsByTag(elements, 'name');

      expect(result.length).assertEqual(1);
    })

    it('mmsModelTest_findElementsByTag', 0, () => {
      let elements: CovertObject[] = [{
        _name: 'name',
        _elements: [{}]
      } as CovertObject];

      let result: CovertObject[] = mmsModel.findElementsByTag(elements, '');

      expect(result.length).assertEqual(0);
    })

    it('mmsModelTest_cloneMmsPreNext_elseIf1_pref_key_avatar_display_true', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as common.ExtensionContext;
      let item: CovertObject = {
        _name: 'boolean',
        _elements: [{}],
        _attributes: {
          name: 'pref_key_avatar_display',
          value: 'true'
        } as AttributesObject,
      } as CovertObject;

      mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.saveToPreferences);

      await mmsModel.cloneMmsPreNext(context, item, actionData);

      mocker.verify('saveToPreferences', ['showContactSwitch', 1]).once();

      mocker.clear(SharedPreferencesUtils);
    })

    it('mmsModelTest_cloneMmsPreNext_elseIf1_pref_key_avatar_display_false', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as common.ExtensionContext;
      let item: CovertObject = {
        _name: 'boolean',
        _elements: [{}],
        _attributes: {
          name: 'pref_key_avatar_display',
          value: 'false'
        } as AttributesObject,
      } as CovertObject;

      mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.saveToPreferences);

      await mmsModel.cloneMmsPreNext(context, item, actionData);

      mocker.verify('saveToPreferences', ['showContactSwitch', 0]).once();

      mocker.clear(SharedPreferencesUtils);
    })

    it('mmsModelTest_cloneMmsPreNext_elseIf2_autoReceiveMms_2', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as common.ExtensionContext;
      let item: CovertObject = {
        _name: 'int',
        _elements: [{}],
        _attributes: {
          name: 'autoReceiveMms',
          value: '2'
        } as AttributesObject,
      } as CovertObject;

      mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.saveToPreferences);

      await mmsModel.cloneMmsPreNext(context, item, actionData);

      mocker.verify('saveToPreferences', ['autoRetrieveMmsSwitch', 0]).once();

      mocker.clear(SharedPreferencesUtils);
    })

    it('mmsModelTest_cloneMmsPreNext_elseIf2_autoReceiveMms_0', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as common.ExtensionContext;
      let item: CovertObject = {
        _name: 'int',
        _elements: [{}],
        _attributes: {
          name: 'autoReceiveMms',
          value: '0'
        } as AttributesObject,
      } as CovertObject;

      mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.saveToPreferences);

      await mmsModel.cloneMmsPreNext(context, item, actionData);

      mocker.verify('saveToPreferences', ['autoRetrieveMmsSwitch', 2]).once();

      mocker.clear(SharedPreferencesUtils);
    })

    it('mmsModelTest_cloneMmsPreNext_elseIf2_autoReceiveMms_1', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as common.ExtensionContext;
      let item: CovertObject = {
        _name: 'int',
        _elements: [{}],
        _attributes: {
          name: 'autoReceiveMms',
          value: '1'
        } as AttributesObject,
      } as CovertObject;

      mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.saveToPreferences);

      await mmsModel.cloneMmsPreNext(context, item, actionData);

      mocker.verify('saveToPreferences', ['autoRetrieveMmsSwitch', 1]).once();

      mocker.clear(SharedPreferencesUtils);
    })

    it('mmsModelTest_cloneMmsPreNext_elseIf3_pref_key_delivery_reports_1', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as common.ExtensionContext;
      let item: CovertObject = {
        _name: 'int',
        _elements: [{}],
        _attributes: {
          name: 'pref_key_delivery_reports',
          value: '1'
        } as AttributesObject,
      } as CovertObject;

      mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.saveToPreferences);

      await mmsModel.cloneMmsPreNext(context, item, actionData);

      mocker.verify('saveToPreferences', ['deliveryReportSwitch', 1]).once();

      mocker.clear(SharedPreferencesUtils);
    })

    it('mmsModelTest_cloneMmsPreNext_elseIf4_pref_key_smart_archive_auto_delete_true', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as common.ExtensionContext;
      let item: CovertObject = {
        _name: 'boolean',
        _elements: [{}],
        _attributes: {
          name: 'pref_key_smart_archive_auto_delete',
          value: 'true'
        } as AttributesObject,
      } as CovertObject;

      mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.saveToPreferences);

      await mmsModel.cloneMmsPreNext(context, item, actionData);

      mocker.verify('saveToPreferences', ['autoDeleteInfoSwitch', 1]).once();

      mocker.clear(SharedPreferencesUtils);
    })

    it('mmsModelTest_cloneMmsPreNext_elseIf4_pref_key_smart_archive_auto_delete_false', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as common.ExtensionContext;
      let item: CovertObject = {
        _name: 'boolean',
        _elements: [{}],
        _attributes: {
          name: 'pref_key_smart_archive_auto_delete',
          value: 'false'
        } as AttributesObject,
      } as CovertObject;

      mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.saveToPreferences);

      await mmsModel.cloneMmsPreNext(context, item, actionData);

      mocker.verify('saveToPreferences', ['autoDeleteInfoSwitch', 0]).once();

      mocker.clear(SharedPreferencesUtils);
    })

    it('mmsModelTest_cloneMmsPreNext_elseIf5_pref_key_smart_archive_enable_true', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as common.ExtensionContext;
      let item: CovertObject = {
        _name: 'boolean',
        _elements: [{}],
        _attributes: {
          name: 'pref_key_smart_archive_enable',
          value: 'true'
        } as AttributesObject,
      } as CovertObject;

      mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.saveToPreferences);

      await mmsModel.cloneMmsPreNext(context, item, actionData);

      mocker.verify('saveToPreferences', ['integrationSwitch', 1]).once();

      mocker.clear(SharedPreferencesUtils);
    })

    it('mmsModelTest_cloneMmsPreNext_elseIf5_pref_key_smart_archive_enable_false', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as common.ExtensionContext;
      let item: CovertObject = {
        _name: 'boolean',
        _elements: [{}],
        _attributes: {
          name: 'pref_key_smart_archive_enable',
          value: 'false'
        } as AttributesObject,
      } as CovertObject;

      mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.saveToPreferences);

      await mmsModel.cloneMmsPreNext(context, item, actionData);

      mocker.verify('saveToPreferences', ['integrationSwitch', 0]).once();

      mocker.clear(SharedPreferencesUtils);
    })

    it('mmsModelTest_cloneMmsPreNext_elseIf6_pref_key_mms_text_speak_true', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as common.ExtensionContext;
      let item: CovertObject = {
        _name: 'boolean',
        _elements: [{}],
        _attributes: {
          name: 'pref_key_mms_text_speak',
          value: 'true'
        } as AttributesObject,
      } as CovertObject;

      mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.saveToPreferences);

      await mmsModel.cloneMmsPreNext(context, item, actionData);
      mocker.verify('i', [TAG, `attributeName is pref_key_mms_text_speak, attributeValue is 1`]).once();
      mocker.clear(SharedPreferencesUtils);
    })

    it('mmsModelTest_cloneMmsPreNext_elseIf6_pref_key_mms_text_speak_false', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as common.ExtensionContext;
      let item: CovertObject = {
        _name: 'boolean',
        _elements: [{}],
        _attributes: {
          name: 'pref_key_mms_text_speak',
          value: 'false'
        } as AttributesObject,
      } as CovertObject;

      mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.saveToPreferences);

      await mmsModel.cloneMmsPreNext(context, item, actionData);
      mocker.verify('i', [TAG, `attributeName is pref_key_mms_text_speak, attributeValue is 0`]).once();
      mocker.clear(SharedPreferencesUtils);
    })

    it('mmsModelTest_cloneMmsPreNext_elseIf7_pref_key_mms_rcs_settings_true', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as common.ExtensionContext;
      let item: CovertObject = {
        _name: 'boolean',
        _elements: [{}],
        _attributes: {
          name: 'pref_key_mms_rcs_settings',
          value: 'true'
        } as AttributesObject,
      } as CovertObject;

      mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.saveToPreferences);

      await mmsModel.cloneMmsPreNext(context, item, actionData);
      mocker.verify('i', [TAG, `attributeName is pref_key_mms_rcs_settings, attributeValue is true`]).once();

      mocker.clear(SharedPreferencesUtils);
    })

    it('mmsModelTest_cloneMmsPreNext_elseIf7_pref_key_mms_rcs_settings_false', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as common.ExtensionContext;
      let item: CovertObject = {
        _name: 'boolean',
        _elements: [{}],
        _attributes: {
          name: 'pref_key_mms_rcs_settings',
          value: 'false'
        } as AttributesObject,
      } as CovertObject;

      mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.saveToPreferences);

      await mmsModel.cloneMmsPreNext(context, item, actionData);
      mocker.verify('i', [TAG, `attributeName is pref_key_mms_rcs_settings, attributeValue is false`]).once();

      mocker.clear(SharedPreferencesUtils);
    })

    it('mmsModelTest_cloneMmsPreNext_elseIf8_pref_key_risk_url_check_true', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as common.ExtensionContext;
      let item: CovertObject = {
        _name: 'boolean',
        _elements: [{}],
        _attributes: {
          name: 'pref_key_risk_url_check',
          value: 'true'
        } as AttributesObject,
      } as CovertObject;

      mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.saveToPreferences);

      await mmsModel.cloneMmsPreNext(context, item, actionData);
      mocker.verify('i', [TAG, `attributeName is pref_key_risk_url_check, attributeValue is true`]).once();

      mocker.clear(SharedPreferencesUtils);
    })

    it('mmsModelTest_cloneMmsPreNext_elseIf8_pref_key_risk_url_check_false', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as common.ExtensionContext;
      let item: CovertObject = {
        _name: 'boolean',
        _elements: [{}],
        _attributes: {
          name: 'pref_key_risk_url_check',
          value: 'false'
        } as AttributesObject,
      } as CovertObject;

      mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.saveToPreferences);

      await mmsModel.cloneMmsPreNext(context, item, actionData);
      mocker.verify('i', [TAG, `attributeName is pref_key_risk_url_check, attributeValue is false`]).once();

      mocker.clear(SharedPreferencesUtils);
    })

    it('mmsModelTest_migrateMmsPreNext_if1_sim_center_address_0', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as common.ExtensionContext;
      let item: CovertObject = {
        _name: 'string',
        _elements: [{
          _text: 'xx'
        }],
        _attributes: {
          name: 'sim_center_address_0',
          value: 'str'
        } as AttributesObject,
      } as CovertObject;

      mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.saveToPreferences);

      await mmsModel.migrateMmsPreNext(context, item, actionData);

      mocker.verify('saveToPreferences', ['newSimSmsc0', 'xx']).once();

      mocker.clear(SharedPreferencesUtils);
    })

    it('mmsModelTest_migrateMmsPreNext_elseIf1_sim_center_address_1', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as common.ExtensionContext;
      let item: CovertObject = {
        _name: 'string',
        _elements: [{
          _text: 'xx'
        }],
        _attributes: {
          name: 'sim_center_address_1',
          value: 'str'
        } as AttributesObject,
      } as CovertObject;

      mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.saveToPreferences);

      await mmsModel.migrateMmsPreNext(context, item, actionData);

      mocker.verify('saveToPreferences', ['newSimSmsc1', 'xx']).once();

      mocker.clear(SharedPreferencesUtils);
    })

    it('mmsModelTest_migrateMmsPreNext_elseIf2_pref_key_delivery_reports', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as common.ExtensionContext;
      let item: CovertObject = {
        _name: 'int',
        _elements: [{
          _text: 'xx'
        }],
        _attributes: {
          name: 'pref_key_delivery_reports',
          value: '1'
        } as AttributesObject,
      } as CovertObject;

      mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.saveToPreferences);

      await mmsModel.migrateMmsPreNext(context, item, actionData);

      mocker.verify('saveToPreferences', ['deliveryReportSwitch', '1']).once();

      mocker.clear(SharedPreferencesUtils);
    })

    it('mmsModelTest_migrateMmsPreNext_elseIf4_pref_key_smart_archive_auto_delete_true', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as common.ExtensionContext;
      let item: CovertObject = {
        _name: 'boolean',
        _elements: [{
          _text: 'xx'
        }],
        _attributes: {
          name: 'pref_key_smart_archive_auto_delete',
          value: 'true'
        } as AttributesObject,
      } as CovertObject;

      mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.saveToPreferences);

      await mmsModel.migrateMmsPreNext(context, item, actionData);

      mocker.verify('saveToPreferences', ['autoDeleteInfoSwitch', '1']).once();

      mocker.clear(SharedPreferencesUtils);
    })

    it('mmsModelTest_migrateMmsPreNext_elseIf4_pref_key_smart_archive_auto_delete_false', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as common.ExtensionContext;
      let item: CovertObject = {
        _name: 'boolean',
        _elements: [{
          _text: 'xx'
        }],
        _attributes: {
          name: 'pref_key_smart_archive_auto_delete',
          value: 'false'
        } as AttributesObject,
      } as CovertObject;

      mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.saveToPreferences);

      await mmsModel.migrateMmsPreNext(context, item, actionData);

      mocker.verify('saveToPreferences', ['autoDeleteInfoSwitch', '0']).once();

      mocker.clear(SharedPreferencesUtils);
    })

    it('mmsModelTest_migrateMmsPreNext_elseIf5_pref_key_mms_rcs_settings_true', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as common.ExtensionContext;
      let item: CovertObject = {
        _name: 'boolean',
        _elements: [{
          _text: 'xx'
        }],
        _attributes: {
          name: 'pref_key_mms_rcs_settings',
          value: 'true'
        } as AttributesObject,
      } as CovertObject;

      mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.saveToPreferences);

      await mmsModel.migrateMmsPreNext(context, item, actionData);

      mocker.verify('saveToPreferences', ['isOpenRcs', true]).once();

      mocker.clear(SharedPreferencesUtils);
    })

    it('mmsModelTest_migrateMmsPreNext_elseIf5_pref_key_mms_rcs_settings_false', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as common.ExtensionContext;
      let item: CovertObject = {
        _name: 'boolean',
        _elements: [{
          _text: 'xx'
        }],
        _attributes: {
          name: 'pref_key_mms_rcs_settings',
          value: 'false'
        } as AttributesObject,
      } as CovertObject;

      mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.saveToPreferences);

      await mmsModel.migrateMmsPreNext(context, item, actionData);

      mocker.verify('saveToPreferences', ['isOpenRcs', false]).once();

      mocker.clear(SharedPreferencesUtils);
    })

    it('mmsModelTest_migrateMmsPreNext_elseIf6_pref_key_im_enable_display_report_true', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as common.ExtensionContext;
      let item: CovertObject = {
        _name: 'boolean',
        _elements: [{
          _text: 'xx'
        }],
        _attributes: {
          name: 'pref_key_im_enable_display_report',
          value: 'true'
        } as AttributesObject,
      } as CovertObject;

      mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.saveToPreferences);

      await mmsModel.migrateMmsPreNext(context, item, actionData);

      mocker.verify('saveToPreferences', ['readFlag', true]).once();

      mocker.clear(SharedPreferencesUtils);
    })

    it('mmsModelTest_migrateMmsPreNext_elseIf6_pref_key_im_enable_display_report_false', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as common.ExtensionContext;
      let item: CovertObject = {
        _name: 'boolean',
        _elements: [{
          _text: 'xx'
        }],
        _attributes: {
          name: 'pref_key_im_enable_display_report',
          value: 'false'
        } as AttributesObject,
      } as CovertObject;

      mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.saveToPreferences);

      await mmsModel.migrateMmsPreNext(context, item, actionData);

      mocker.verify('saveToPreferences', ['readFlag', false]).once();

      mocker.clear(SharedPreferencesUtils);
    })

    it('mmsModelTest_migrateMmsPreNext_elseIf7_pref_key_smart_archive_enable_true', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as common.ExtensionContext;
      let item: CovertObject = {
        _name: 'boolean',
        _elements: [{
          _text: 'xx'
        }],
        _attributes: {
          name: 'pref_key_smart_archive_enable',
          value: 'true'
        } as AttributesObject,
      } as CovertObject;

      mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.saveToPreferences);

      await mmsModel.migrateMmsPreNext(context, item, actionData);
      mocker.verify('i', [TAG, `attributeName is pref_key_smart_archive_enable, attributeValue is 1`]).once();

      mocker.clear(SharedPreferencesUtils);
    })

    it('mmsModelTest_migrateMmsPreNext_elseIf7_pref_key_smart_archive_enable_false', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as common.ExtensionContext;
      let item: CovertObject = {
        _name: 'boolean',
        _elements: [{
          _text: 'xx'
        }],
        _attributes: {
          name: 'pref_key_smart_archive_enable',
          value: 'false'
        } as AttributesObject,
      } as CovertObject;

      mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.saveToPreferences);

      await mmsModel.migrateMmsPreNext(context, item, actionData);
      mocker.verify('i', [TAG, `attributeName is pref_key_smart_archive_enable, attributeValue is 0`]).once();

      mocker.clear(SharedPreferencesUtils);
    })

    it('mmsModelTest_migrateMmsPreNext_elseIf8_pref_key_a2p_switch_settings_true', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as common.ExtensionContext;
      let item: CovertObject = {
        _name: 'boolean',
        _elements: [{
          _text: 'xx'
        }],
        _attributes: {
          name: 'pref_key_a2p_switch_settings',
          value: 'true'
        } as AttributesObject,
      } as CovertObject;

      mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.saveToPreferences);

      await mmsModel.migrateMmsPreNext(context, item, actionData);
      mocker.verify('i', [TAG, `attributeName is pref_key_a2p_switch_settings, attributeValue is true`]).once();

      mocker.clear(SharedPreferencesUtils);
    })

    it('mmsModelTest_migrateMmsPreNext_elseIf8_pref_key_a2p_switch_settings_false', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as common.ExtensionContext;
      let item: CovertObject = {
        _name: 'boolean',
        _elements: [{
          _text: 'xx'
        }],
        _attributes: {
          name: 'pref_key_a2p_switch_settings',
          value: 'false'
        } as AttributesObject,
      } as CovertObject;

      mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.saveToPreferences);

      await mmsModel.migrateMmsPreNext(context, item, actionData);
      mocker.verify('i', [TAG, `attributeName is pref_key_a2p_switch_settings, attributeValue is false`]).once();

      mocker.clear(SharedPreferencesUtils);
    })

    it('mmsModelTest_migrateMmsPreNext_elseIf9_pref_key_risk_url_check_true', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as common.ExtensionContext;
      let item: CovertObject = {
        _name: 'boolean',
        _elements: [{
          _text: 'xx'
        }],
        _attributes: {
          name: 'pref_key_risk_url_check',
          value: 'true'
        } as AttributesObject,
      } as CovertObject;

      mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.saveToPreferences);

      await mmsModel.migrateMmsPreNext(context, item, actionData);
      mocker.verify('i', [TAG, `attributeName is pref_key_risk_url_check, attributeValue is true`]).once();

      mocker.clear(SharedPreferencesUtils);
    })

    it('mmsModelTest_migrateMmsPreNext_elseIf9_pref_key_risk_url_check_false', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as common.ExtensionContext;
      let item: CovertObject = {
        _name: 'boolean',
        _elements: [{
          _text: 'xx'
        }],
        _attributes: {
          name: 'pref_key_risk_url_check',
          value: 'false'
        } as AttributesObject,
      } as CovertObject;

      mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.saveToPreferences);

      await mmsModel.migrateMmsPreNext(context, item, actionData);
      mocker.verify('i', [TAG, `attributeName is pref_key_risk_url_check, attributeValue is false`]).once();

      mocker.clear(SharedPreferencesUtils);
    })

    it('mmsModelTest_migrateMmsPreNext_elseIf10_pref_key_avatar_display_true', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as common.ExtensionContext;
      let item: CovertObject = {
        _name: 'boolean',
        _elements: [{
          _text: 'xx'
        }],
        _attributes: {
          name: 'pref_key_avatar_display',
          value: 'true'
        } as AttributesObject,
      } as CovertObject;

      mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.saveToPreferences);

      await mmsModel.migrateMmsPreNext(context, item, actionData);
      mocker.verify('i', [TAG, `attributeName is pref_key_avatar_display, attributeValue is true`]).once();

      mocker.clear(SharedPreferencesUtils);
    })

    it('mmsModelTest_migrateMmsPreNext_elseIf10_pref_key_avatar_display_false', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as common.ExtensionContext;
      let item: CovertObject = {
        _name: 'boolean',
        _elements: [{
          _text: 'xx'
        }],
        _attributes: {
          name: 'pref_key_avatar_display',
          value: 'false'
        } as AttributesObject,
      } as CovertObject;

      mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.saveToPreferences);

      await mmsModel.migrateMmsPreNext(context, item, actionData);
      mocker.verify('i', [TAG, `attributeName is pref_key_avatar_display, attributeValue is false`]).once();

      mocker.clear(SharedPreferencesUtils);
    })

    it('mmsModelTest_migrateMmsPreNext_elseIf11_pref_key_mms_text_speak_true', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as common.ExtensionContext;
      let item: CovertObject = {
        _name: 'boolean',
        _elements: [{
          _text: 'xx'
        }],
        _attributes: {
          name: 'pref_key_mms_text_speak',
          value: 'true'
        } as AttributesObject,
      } as CovertObject;

      mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.saveToPreferences);

      await mmsModel.migrateMmsPreNext(context, item, actionData);
      mocker.verify('i', [TAG, `attributeName is pref_key_mms_text_speak, attributeValue is 1`]).once();

      mocker.clear(SharedPreferencesUtils);
    })

    it('mmsModelTest_migrateMmsPreNext_elseIf11_pref_key_mms_text_speak_false', 0, async () => {
      let context = DTGlobalContext.getContext().getObject('mmsContext') as common.ExtensionContext;
      let item: CovertObject = {
        _name: 'boolean',
        _elements: [{
          _text: 'xx'
        }],
        _attributes: {
          name: 'pref_key_mms_text_speak',
          value: 'false'
        } as AttributesObject,
      } as CovertObject;

      mocker.mockFunc(SharedPreferencesUtils, SharedPreferencesUtils.saveToPreferences);

      await mmsModel.migrateMmsPreNext(context, item, actionData);
      mocker.verify('i', [TAG, `attributeName is pref_key_mms_text_speak, attributeValue is 0`]).once();

      mocker.clear(SharedPreferencesUtils);
    })

    it('mmsModelTest_migrateMmsPref_isMigrate_false', 0, async () => {

      let context = DTGlobalContext.getContext().getObject('mmsContext') as common.ExtensionContext;

      await mmsModel.migrateMmsPref(context, context.preferencesDir, false);

      mocker.verify('i', [TAG, 'migrate mmsPreferences start. isMigrate : ' + false]);

    })

    it('mmsModelTest_migrateMmsPref_isMigrate_true', 0, async () => {

      let context = DTGlobalContext.getContext().getObject('mmsContext') as common.ExtensionContext;

      await mmsModel.migrateMmsPref(context, context.preferencesDir, true);

      mocker.verify('i', [TAG, 'migrate mmsPreferences start. isMigrate : ' + true]);

    })

    it('mmsModelTest_generateVideoPixmap', 0, async () => {
      when(mocker.mockFunc(FileUtil,FileUtil.getFileName))('xx').afterReturn('xx');

      let context = DTGlobalContext.getContext().getObject('mmsContext') as common.ExtensionContext;

      await mmsModel.generateVideoPixmap(context, context.preferencesDir, ['xx']);

      mocker.verify('getFileName', ['xx']).times(1);

      mocker.clear(FileUtil);
    })
  })
}